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

module_ex() {
# Verify that 'module' is runnable
retval=0
2>/dev/null 1>&2 module || retval=$?
if [ $retval -ne 0 ] && [ $retval -ne 1 ]; then 
    echo "'module' command not found by shell"
    return $retval
fi

# Create a Temp file
TEMPOUTFILE="$(mktemp /tmp/moduleex_out_XXXXXX)"
TEMPERRFILE="$(mktemp /tmp/moduleex_err_XXXXXX)"

# Execute the module command and record the output
module $@ 1>"$TEMPOUTFILE" 2>"$TEMPERRFILE" || retval=$?

# Get the retvalue, and scan the temp file for the "ERROR:" (Tcl) or "No
# module" (Lmod/Lua) signature
errcount="$(grep -E -c 'ERROR:|No module' $TEMPERRFILE)" || tmp=$?

# Output what was recorded
if [[ -s "$TEMPOUTFILE" ]]; then cat "$TEMPOUTFILE"; fi
if [[ -s "$TEMPERRFILE" ]]; then cat "$TEMPERRFILE"; fi

# NOTE: If an error occurs, it will ALWAYS be output by "ERROR:" in module's stderr.
#           However, the return from module will most likely be 0, Hence the reason for this script.

# echo "retval = $retval errcount = $errcount"

final=0
# Check if the errcount or retval of the module call has indicated an error, 
# return one of them and also echo the stored module cmd results to stderr.
if [ $errcount != 0  ]; then
    if [ $retval -ne 0 ]; then 
        final=$retval
    else
        final=$errcount
    fi
elif [[ "$1" == "avail" ]]; then
    # Ensure that "module avail" returns non-zero if there's no match.  The
    # Lua and Tcl versions behave differently.
    if [[ "$LMOD_VERSION" ]]; then
        # For the Lua version, the error of "No module" should have matched.
        final=$errcount
    else
        # For the Tcl version, if nothing was printed, then there was no match.
        if [[ "$2" ]] && [[ ! -s "$TEMPERRFILE" ]]; then final=1; fi
    fi
fi

# final cleanup & return 
rm "$TEMPOUTFILE" "$TEMPERRFILE"
return $final
}
