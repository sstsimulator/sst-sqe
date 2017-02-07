# !/bin/bash
# testSuite_cassini_prefetch.sh

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
L_SUITENAME="SST_cassini_prefetch_suite" # Name of this test suite; will be used to
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
#     test_cassini_prefetch
# Outputs:
#     test_cassini_prefetch
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
cassini_prefetch_template() {
CP_case=$1
    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_cassini_prefetch_${CP_case}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    tmpFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.tmp"
    referenceFile="${SST_REFERENCE_ELEMENTS}/cassini/tests/refFiles/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/cassini/tests/streamcpu-${CP_case}.py"

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        ${sut} ${sutArgs}  > $outFile
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
             wc  $outFile $referenceFile
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             return
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
        return
    fi

     RemoveComponentWarning
     grep "simulated.time" $outFile ; echo ' '
     wc  $outFile $referenceFile
     diff -b $referenceFile $outFile > ${SSTTESTTEMPFILES}/_raw_diff
     if [ $? != 0 ] ; then
        wc ${SSTTESTTEMPFILES}/_raw_diff
        compare_sorted $referenceFile $outFile
        if [ $? == 0 ] ; then
           echo " Sorted match with Reference File"
           rm ${SSTTESTTEMPFILES}/_raw_diff
           return
        else
           echo "Output does not match Reference File"
           cat ${SSTTESTTEMPFILES}/_raw_diff
#           echo " Reference File "
#           cat $referenceFile
#           echo "       ------  "
#           echo "   Output File "
#           cat $outFile
#           echo "       ------  "
           fail "Output does not match Reference File"
           rm ${SSTTESTTEMPFILES}/_raw_diff
        fi
     else
        echo ' '
        echo " Statistics information matches exactly"
     fi

}

test_cassini_prefetcher_none()
{
    cassini_prefetch_template "nopf"
}

test_cassini_prefetcher_stride()
{
    cassini_prefetch_template "sp"
}

test_cassini_prefetcher_nextblock()
{
    cassini_prefetch_template "nbp"
}

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
