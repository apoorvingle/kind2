(* This file is part of the Kind 2 model checker.

   Copyright (c) 2014 by the Board of Trustees of the University of Iowa

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

(** An interface to any SMT solver that accepts the SMTLIB2 command
    language 

    Use this module as input to the {!SMTSolver.Make} functor 

    @author Christoph Sticksel
 *)

(** {1 Basic types} *)

(** A solver instance *)
type t 


(** Configuration *)
type config = 
    { solver_cmd : string array;  (** Command line for the solver
                                      
                                      The executable must be the first
                                      element in the array, each
                                      subsequent string is an argument
                                      that is passed to
                                      [Unix.open_process] as is. *)

    }


(** {1 Managing solver instances} *)

(** [create_instance c l id] creates a new instance of the a generic
    SMTLIB solver that is executed as [c], initialized to the logic
    [l] and produces assignments if the optional labelled argument
    [produce_assignments] is [true], models if [produce_models] is
    true, proofs if [produce_proofs] is true and unsatisfiable cores
    if [produce_cores] is true. It is identified by a unique [id].*)
val create_instance : 
  ?produce_assignments:bool -> 
  ?produce_models:bool -> 
  ?produce_proofs:bool -> 
  ?produce_cores:bool -> 
  SMTExpr.logic ->
  int ->
  t

(** [delete_instance s] deletes the solver instance [s] by sending the
    exit command and waiting for the solver process to exit *)
val delete_instance : t -> unit


(** {1 Declaring Sorts and Functions} *)

(** Declare a new function symbol *)
val declare_fun : t -> string -> SMTExpr.sort list -> SMTExpr.sort -> SMTExpr.response

(** Define a new function symbol as an abbreviation for an expression *)
val define_fun : t -> string -> SMTExpr.var list -> SMTExpr.sort -> SMTExpr.t -> SMTExpr.response


(** {1 Commands} *)

(** Assert the expression *)
val assert_expr : t -> SMTExpr.t -> SMTExpr.response

(** Push a number of empty assertion sets to the stack *)
val push : t -> int -> SMTExpr.response 

(** Pop a number of assertion sets from the stack *)
val pop : t -> int -> SMTExpr.response 

(** Check satisfiability of the asserted expressions

    The optional parameter [timeout] limits the maximum runtime to the
    given number of milliseconds *)
val check_sat : ?timeout:int -> t -> SMTExpr.check_sat_response

(** Check satisfiability of the asserted expressions assuming the
    input list of literals. *)
val check_sat_assuming :
  t -> SMTExpr.t list -> SMTExpr.check_sat_response

(** Get the assigned values of expressions in the current model *)
val get_value : t -> SMTExpr.t list -> SMTExpr.response * (SMTExpr.t * SMTExpr.t) list


(** Get an unsatisfiable core of named terms *)
val get_unsat_core : t -> SMTExpr.response * string list


(** Execute a custom command and return its result

    [execute_custom_command s c a r] sends a custom command [s] with
    the arguments [a] to the solver instance [s]. The command
    expects [r] S-expressions as result in case of success and
    returns a pair of the success response and a list of
    S-expressions. *)
val execute_custom_command : t -> string -> SMTExpr.custom_arg list -> int -> SMTExpr.response * HStringSExpr.t list

(** Execute a custom check-sat command and return its result *)
val execute_custom_check_sat_command : string -> t -> SMTExpr.check_sat_response

(** {2 Solver features} *)


(** Indicates whether the solver supports the check-sat-assuming
    command. *)
val check_sat_assuming_supported: unit -> bool


(** {2 Solver specific features }*)

module Conv : SMTExpr.Conv
                                            
(* 
   Local Variables:
   compile-command: "make -C .. -k"
   tuareg-interactive-program: "./kind2.top -I ./_build -I ./_build/SExpr"
   indent-tabs-mode: nil
   End: 
*)
