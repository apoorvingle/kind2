/*
################################################################################
#  THIS FILE IS 100% GENERATED BY ZPROJECT; DO NOT EDIT EXCEPT EXPERIMENTALLY  #
#  Please refer to the README for information about making permanent changes.  #
################################################################################
*/

#include "qczmq.h"

///
//  Copy-construct to return the proper wrapped c types
QZtrie::QZtrie (ztrie_t *self, QObject *qObjParent) : QObject (qObjParent)
{
    this->self = self;
}


///
//  Creates a new ztrie.
QZtrie::QZtrie (char delimiter, QObject *qObjParent) : QObject (qObjParent)
{
    this->self = ztrie_new (delimiter);
}

///
//  Destroy the ztrie.
QZtrie::~QZtrie ()
{
    ztrie_destroy (&self);
}

///
//  Inserts a new route into the tree and attaches the data. Returns -1     
//  if the route already exists, otherwise 0. This method takes ownership of
//  the provided data if a destroy_data_fn is provided.                     
int QZtrie::insertRoute (const QString &path, void *data, ztrie_destroy_data_fn destroyDataFn)
{
    int rv = ztrie_insert_route (self, path.toUtf8().data(), data, destroyDataFn);
    return rv;
}

///
//  Removes a route from the trie and destroys its data. Returns -1 if the
//  route does not exists, otherwise 0.                                   
//  the start of the list call zlist_first (). Advances the cursor.       
int QZtrie::removeRoute (const QString &path)
{
    int rv = ztrie_remove_route (self, path.toUtf8().data());
    return rv;
}

///
//  Returns true if the path matches a route in the tree, otherwise false.
bool QZtrie::matches (const QString &path)
{
    bool rv = ztrie_matches (self, path.toUtf8().data());
    return rv;
}

///
//  Returns the data of a matched route from last ztrie_matches. If the path
//  did not match, returns NULL. Do not delete the data as it's owned by    
//  ztrie.                                                                  
void * QZtrie::hitData ()
{
    void * rv = ztrie_hit_data (self);
    return rv;
}

///
//  Returns the count of parameters that a matched route has.
size_t QZtrie::hitParameterCount ()
{
    size_t rv = ztrie_hit_parameter_count (self);
    return rv;
}

///
//  Returns the parameters of a matched route with named regexes from last   
//  ztrie_matches. If the path did not match or the route did not contain any
//  named regexes, returns NULL.                                             
QZhashx * QZtrie::hitParameters ()
{
    QZhashx *rv = new QZhashx (ztrie_hit_parameters (self));
    return rv;
}

///
//  Returns the asterisk matched part of a route, if there has been no match
//  or no asterisk match, returns NULL.                                     
const QString QZtrie::hitAsteriskMatch ()
{
    const QString rv = QString (ztrie_hit_asterisk_match (self));
    return rv;
}

///
//  Print the trie
void QZtrie::print ()
{
    ztrie_print (self);
    
}

///
//  Self test of this class.
void QZtrie::test (bool verbose)
{
    ztrie_test (verbose);
    
}
/*
################################################################################
#  THIS FILE IS 100% GENERATED BY ZPROJECT; DO NOT EDIT EXCEPT EXPERIMENTALLY  #
#  Please refer to the README for information about making permanent changes.  #
################################################################################
*/