(* This file is part of the Kind 2 model checker.

   Copyright (c) 2015 by the Board of Trustees of the University of Iowa

   Licensed under the Apache License, Version 2.0 (the "License"); you
   may not use this file except in compliance with the License.  You
   may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0 

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
   implied. See the License for the specific language governing
   permissions and limitations under the License. 

*)

open Lib
open Lexing
open MenhirLib.General
   
module LA = LustreAst
module LI = LustreIdent
module LN = LustreNode
module LC = LustreContext
module LD = LustreDeclarations
module SS = SubSystem

module LPI = LustreParser.Incremental
module LL = LustreLexer          
module LPMI = LustreParser.MenhirInterpreter
module LPE = LustreParserErrors

(* The parser has succeeded and produced a semantic value.*)
let success (v : LustreAst.t): LustreAst.t =
  Log.log L_debug "Parsed :\n=========\n\n%a\n@." LustreAst.pp_print_program v;
  v

(* obtain the position of the token from the lexer buffer *)
let get_lexing_position lexbuf =
  let lpos = Lexing.lexeme_start_p lexbuf in
  let lno = lpos.Lexing.pos_lnum in
  let col = lpos.Lexing.pos_cnum - lpos.Lexing.pos_bol + 1 in
  (lno, col)

(* Generates the appropriate parser error message *)
let get_parse_error env =
    match LPMI.stack env with
    | lazy Nil -> "Syntax Error"
    | lazy (Cons (LPMI.Element (state, _, _, _), _)) ->
       let pstate = LPMI.number state in
        try (LPE.message pstate) with
        | Not_found -> "Syntax Error (Parser State: "^ (string_of_int pstate) ^ ")" 
                       ^ "Please report this issue with a minimum working example."

(* Raises the [Parser_error] exception with appropriate position and error message *)
let fail env lexbuf =
  let err = get_parse_error env in
  let pos = position_of_lexing lexbuf.lex_curr_p in
  LC.fail_at_position pos err

(* Incremental Parsing *)
let rec parse lexbuf (chkpnt : LA.t LPMI.checkpoint) =
  match chkpnt with
  | LPMI.InputNeeded _ ->
     let token = LL.token lexbuf in
     let startp = lexbuf.lex_start_p
     and endp = lexbuf.lex_curr_p in
     let chkpnt = LPMI.offer chkpnt (token, startp, endp) in
     parse lexbuf chkpnt
  | LPMI.Shifting _
  | LPMI.AboutToReduce _ ->
     let chkpnt = LPMI.resume chkpnt in
     parse lexbuf chkpnt
  | LPMI.HandlingError env ->
     fail env lexbuf
  | LPMI.Accepted v -> success v
  | LPMI.Rejected ->
     LC.fail_no_position "Parser Error: Parser rejected the input."  

(* Parses input channel to generate an AST *)
let ast_of_channel(in_ch: in_channel): LustreAst.t =
  (* Create lexing buffer *)
  let lexbuf = Lexing.from_function LustreLexer.read_from_lexbuf_stack in
  (* Initialize lexing buffer with channel *)
  LustreLexer.lexbuf_init 
    in_ch
    (try Filename.dirname (Flags.input_file ())
     with Failure _ -> Sys.getcwd ());
  (* Create lexing buffer and incrementally parse it*)
  parse lexbuf (LPI.main lexbuf.lex_curr_p)
         
(* Parse from input channel *)
let of_channel in_ch =
  (* Get declarations from channel. *)
  let declarations = ast_of_channel in_ch in
  (* Simplify declarations to a list of nodes *)
  let nodes, globals = LD.declarations_to_nodes declarations in
  (* Name of main node *)
  let main_node = 
    (* Command-line flag for main node given? *)
    match Flags.lus_main () with 
      (* Use given identifier to choose main node *)
      | Some s -> LustreIdent.mk_string_ident s
      (* No main node name given on command-line *)
      | None -> 
        (try 
           (* Find main node by annotation, or take last node as
              main *)
           LustreNode.find_main nodes 
         (* No main node found
            This only happens when there are no nodes in the input. *)
         with Not_found -> 
           raise (Invalid_argument "No main node defined in input"))
  in
  (* Put main node at the head of the list of nodes *)
  let nodes' = 
    try 
      (* Get main node by name and copy it at the head of the list of
         nodes *)
      LN.node_of_name main_node nodes :: nodes
    with Not_found -> 
      (* Node with name of main not found 
         This can only happens when the name is passed as command-line
         argument *)
      raise (Invalid_argument "Main node not found")
  in
  (* Return a subsystem tree from the list of nodes *)
  LN.subsystem_of_nodes nodes', globals, declarations

(* Returns the AST from a file. *)
let ast_of_file filename =
  (* Open the given file for reading *)
  let in_ch = match filename with
    | "" -> stdin
    | _ -> open_in filename
  in
  ast_of_channel in_ch


(* Open and parse from file *)
let of_file filename =
  (* Open the given file for reading *)
  let in_ch = match filename with
    | "" -> stdin
    | _ -> open_in filename
  in
  of_channel in_ch


(* 
   Local Variables:
   compile-command: "make -C .. -k"
   indent-tabs-mode: nil
   End: 
*)
