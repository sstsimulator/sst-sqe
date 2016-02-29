# !/bin/bash
# testSuite_miranda_singlestream.sh

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
L_SUITENAME="SST_miranda_suite" # Name of this test suite; will be used to
                                # identify this suite in XML file. This
                                # should be a single string, no spaces
                                # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_miranda_singlestream
# Purpose:
#     Exercise miranda CPU
# Inputs:
#     None
# Outputs:
#     test_miranda_<case>.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
miranda_Template() {
miranda_case=$1

    startSeconds=`date +%s`
    # Define a common basename for test output and reference files.
    testDataFileBase="test_miranda_${miranda_case}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst/elements/miranda/tests/${miranda_case}.py"

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        (${sut} -n 2  ${sutArgs} > $outFile)
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
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             RemoveComponentWarning
             return
        fi
        RemoveComponentWarning
        myWC $referenceFile $outFile
        diff -b $referenceFile $outFile  > raw_diff
        if [ $? != 0 ]
        then  
            compare_sorted $referenceFile $outFile
            if [ $? == 0 ] ; then
               echo " Sorted match with Reference File"
               rm raw_diff
            elif [ "lineWordCt" == "$2" ] ; then
               ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
               new=`wc ${outFile}       | awk '{print $1, $2}'`;
               if [ "$ref" == "$new" ]
               then 
                   echo "    Output passed  LineWordCt match"
               else
                   echo "    Output Flunked  lineWordCt Count match"
                   fail "Output Flunked  lineWordCt Count match"
               fi
            else
               echo "Output does not match Reference File"
               fail "Output does not match Reference File"
               cat raw_diff
            fi
        else
            echo " Exact match Output and Reference"
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    grep 'Simulation is complete' $outFile
  
    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "miranda_${miranda_case}: Wall Clock Time  $elapsedSeconds seconds"
    echo " "

}

test_miranda_singlestream() {
miranda_Template singlestream

}

test_miranda_revsinglestream() {
miranda_Template revsinglestream

##     set time limit for randomgen()
    export SST_TEST_ONE_TEST_TIMEOUT=1500
}    


test_miranda_randomgen() {
    if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] ; then
       if [ $SST_MULTI_THREAD_COUNT -gt 1 ] && \
          [[ `uname -n` != sst-test* ]] ; then
             skip_this_test
             echo " skipping randomgen on multi-thread"   
##  Reset the Time Limit for reamainer of tests
             export SST_TEST_ONE_TEST_TIMEOUT=$SST_TEST_MIRANDA_NORMAL
             return
       fi
    fi
miranda_Template randomgen

##  Reset the Time Limit for reamainer of tests
             export SST_TEST_ONE_TEST_TIMEOUT=$SST_TEST_MIRANDA_NORMAL
}

test_miranda_stencil3dbench() {
miranda_Template stencil3dbench

}

test_miranda_streambench() {
miranda_Template streambench "lineWordCt"

}


test_miranda_copybench() {
miranda_Template copybench

}

test_miranda_inorderstream() {
miranda_Template inorderstream

}

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

 
# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.

#         Located here this timeout will override the multithread value
export SST_TEST_ONE_TEST_TIMEOUT=$SST_TEST_MIRANDA_NORMAL_TL
export SST_TEST_MIRANDA_NORMAL_TL=200
export SST_TEST_MIRANDA_RANGET_TL=1500

(. ${SHUNIT2_SRC}/shunit2)
