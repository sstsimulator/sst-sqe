#!/bin/bash 
# testSuite_simpleDistribComponent.sh

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

#=============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_simpleDistribComponent_suite" # Name of this test suite; will be used to
                                               # identify this suite in SDL file. This
                                               # should be a single string, no spaces
                                               # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
#                       TEMPLATE
#     Subroutine to run multiple similiar tests without reproducing the script.
#      First parameter is the name of the test, must match test_simpleDistribComponent_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 500.)

simpleDistribComponent_Template() {
simpleDistrib_case=$1
Tol=$2    ##  curTick tolerance


    startSeconds=`date +%s`
    testDataFileBase="test_simpleDistribComponent_$simpleDistrib_case"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    tmpFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.tmp"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    sut="${SST_TEST_INSTALL_BIN}/sst"

        sutArgs="${SST_ROOT}/sst/elements/simpleElementExample/tests/test_simpleDistribComponent_${simpleDistrib_case}.py"
        ls $sutArgs
        if [ $? != 0 ]
        then
          echo ' '
          ls -d ${SST_ROOT}/sst/elements/simpleElementExample
          ls ${SST_ROOT}/sst/elements/simpleElementExample
          echo ' '
        fi

        ${sut} ${sutArgs} > ${outFile}
        RetVal=$? 
        TIME_FLAG=/tmp/TimeFlag_$$_${__timerChild} 
echo "                                             TIME_FLAG is $TIME_FLAG" 
ls $TIME_FLAG 
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
             fail "WARNING: sst did not finish normally"
             RemoveComponentWarning
             return
        fi
        RemoveComponentWarning
        wc ${outFile} ${referenceFile} | awk -F/ '{print $1, $(NF-1) "/" $NF}'


        diff ${referenceFile} ${outFile} > /dev/null;
        if [ $? -ne 0 ]
        then
               ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
               new=`wc ${outFile}       | awk '{print $1, $2}'`;
               if [ "$ref" == "$new" ];
               then
                   echo "outFile word/line count matches Reference"
               else
                   echo "$simpleDistrib_case test Fails"
                   tail $outFile
                   fail "outFile word/line count does NOT matches Reference"
               fi
        else
                echo ReferenceFile is an exact match of outFile
        fi

        endSeconds=`date +%s`
        echo " "
        elapsedSeconds=$(($endSeconds -$startSeconds))
        echo "${simpleDistrib_case}: Wall Clock Time  $elapsedSeconds seconds"
         

}


# Build Test app
##    The following code already explictly assume we are at trunk
  
   

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_simpleDistribComponent_xxxx
# Purpose:
#     Exercise the simpleDistribComponent of the simpleElementExample
# Inputs:
#     None
# Outputs:
#     test_simpleDistrib_xxx.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     For shunit2, the output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
# Exception for simpleDistrib tests:
#     Line Word count match also passes
#-------------------------------------------------------------------------------
test_simpleDistribComponent_expon() {          
simpleDistribComponent_Template expon 500

}

test_simpleDistribComponent_gaussian() {          
simpleDistribComponent_Template gaussian 500

}

test_simpleDistribComponent_discrete() {          
simpleDistribComponent_Template discrete 500

}

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

 
# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
