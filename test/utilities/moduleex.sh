#!/bin/bash

set -eo pipefail

# Utility script to launch `module` command and check for errors.  module is slightly funky in that 
# it does not return an error when it fails, but does normally output errors to stderr (this is due 
# to its odd design of part bash and part tcl).  However it can generate errors if the tcl script 
# calls exit [N] (see http://modules.sourceforge.net/man/modulefile.html for more info).
#
# This script redirects the output of module to a temp file, and then scans the file for the 
# module error signature (indicated by "ERROR:").  It also watches the return value of module
# for any possible error values being returned.  It then outputs the temp file and lastly checks 
# the results.  If an error is detected, it will return an error value. 

# Make sure this script is "sourced" not "executed"
#if [[ $0 != "-bash" ]]; then
#    echo "ERROR: This script ($0) must be sourced not executed."
#    exit -1
#fi

module_ex() {
# Verify that 'module' is runnable
retval=0
2>/dev/null 1>&2 module || retval=$?
if [ $retval -ne 0 ] && [ $retval -ne 1 ]; then 
    echo "'module' command not found by shell"
    return $retval
fi

# Create a Temp file
TEMPOUTFILE="$(mktemp /tmp/moduleex_XXXXXX)"

# Execute the module command and record the output
#echo "---Running module $@"
module $@ 2>$TEMPOUTFILE || retval=$?

# Get the retvalue, and scan the temp file for the "ERROR:" (Tcl) or "No
# module" (Lmod/Lua) signature
errcount="$(grep -E -c 'ERROR:|No module' $TEMPOUTFILE)" || tmp=$?

# Output what was recorded
cat $TEMPOUTFILE

# NOTE: If an error occurs, it will ALWAYS be output by "ERROR:" in module's stderr.
#           However, the return from module will most likely be 0, Hence the reason for this script.

#Debug
#echo "retval = $retval"          
#echo "errcount = $errcount"  

final=0
# Check if the errcount or retval of the module call has indicated an error, 
# return one of them and also echo the stored module cmd results to stderr.
if [ $errcount != 0  ]; then
    if [ $retval -ne 0 ]; then 
        final=$retval
    else
        final=$errcount
    fi
fi

# final cleanup & return 
rm $TEMPOUTFILE
return $final
}
