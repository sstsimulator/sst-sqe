#!/bin/bash 
# testSuite_VaultSim.sh

# Description: 

# A shell script that defines a shunit2 test suite. This will be
# invoked by the Bamboo script.

# Preconditions:

# 1) The SUT (software under test) must have built successfully.
# 2) A test success reference file is available.

TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh


#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_VaultSim_suite" # Name of this test suite; will be used to
                                 # identify this suite in XML file. This
                                 # should be a single string, no spaces
                                 # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names


OPWD=`pwd`    # Save Original PWD

#===============================================================================
#     Subroutine to run many of the VaultSim tests without reproducing the script.
#      First parameter is the name of the test, must match test_VaultSim_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 500.)
#      Special case:  if second parameter is "lineWordCt",
#                          accept a line/word count match.

VaultSim_Template() {
VSim_case=$1
Tol=$2    ##  curTick tolerance,  or  "lineWordCt" 

    cd $SST_ROOT/sst/elements/VaultSimC/tests
    startSeconds=`date +%s`
    testDataFileBase="test_VaultSim_$VSim_case"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
##    referenceFile="./${VSim_case}.ref"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    sut="${SST_TEST_INSTALL_BIN}/sst"

    sutArgs=${SST_ROOT}/sst-elements/src/sst/elements/VaultSimC/tests/${VSim_case}.py

    (${sut} ${sutArgs} > ${outFile})
        RetVal=$? 
        TIME_FLAG=/tmp/TimeFlag_$$_${__timerChild} 
        if [ -e $TIME_FLAG ] ; then 
             echo " Time Limit detected at `cat $TIME_FLAG` seconds" 
             fail " Time Limit detected at `cat $TIME_FLAG` seconds" 
             rm $TIME_FLAG 
             return 
        fi 
        if [ $RetVal != 0 ]  
    then
         echo ' '; echo WARNING: sst did not finish normally ; echo ' '
         ls -l ${sut}
         fail "sst did not finish normally, RetVal=$RetVal"
         return
    fi

         sed -i'.3sed' -e'/ nan$/d' $outFile        ## This is needed 11/21/13
         sed -i'.4sed' -e'/ -nan$/d' $outFile       ## This is needed 11/21/13

         diff ${referenceFile} ${outFile} > /dev/null;
         if [ $? -ne 0 ]
         then
             ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
             new=`wc ${outFile}       | awk '{print $1, $2}'`;
             if [ "lineWordCt" == "$Tol" ]
             then
                 if [ "$ref" == "$new" ]
                 then 
                     echo "    Output passed  LineWordCt match"
                 else
                     echo "    Output Flunked  lineWordCt Count match"
                     fail "Output Flunked  lineWordCt Count match"
                 fi
             fi
         else
             echo "    Output matches Reference File exactly"
         fi

    diff -u ${referenceFile} ${outFile} 
    endSeconds=`date +%s`
    echo " "
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "${VSim_case}: Wall Clock Time  $elapsedSeconds seconds  VaultSim"

}

   

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_VaultSim
# Purpose:
# Inputs:
#     None
# Outputs:
#     test_VaultSim_.new file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     For shunit2, the output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------



#
#     sdl1
#
test_VaultSim_sdl1() {    
VaultSim_Template sdl1 lineWordCt

}

#
#     sdl2
#
test_VaultSim_sdl2() {    
VaultSim_Template sdl2 lineWordCt

}


###################################################
#
#     sdl3
##
##    Don't attempt this test without GEM5
##
#
test_VaultSim_sdl3() {    
if [[ ${SST_DEPS_INSTALL_GEM5SST:+isSet} != isSet ]] ; then
      echo " "; echo "Can NOT run VaultSim sdl3 test without GEM5"; echo " "
      skip_this_test     # Skip function in shunit2
      echo ' '
      return
fi
VaultSim_Template sdl3 500

}
#########################################################

export SST_TEST_ONE_TEST_TIMEOUT=90

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

cd $OPWD        # Restore entry PWD

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)


