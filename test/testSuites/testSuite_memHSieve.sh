# !/bin/bash
# testSuite_memHSieve.sh

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
L_SUITENAME="SST_memHSieve_suite" # Name of this test suite; will be used to
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
#     test_memHSieve
# Purpose:
#     Exercise the memHSieve of the simpleElementExample
# Inputs:
#     None
# Outputs:
#     test_memHSieve.csv file
# Expected Results
#     Match of output csv file against reference file
# Caveats:
#     The csvput files must match the reference file *exactly*,
#     requiring that the command lines for creating both the csvput
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_memHSieve() {

    # Define a common basename for test csv and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_memHSieve"
    referenceFile="${SST_ROOT}/sst/elements/memHierarchy/Sieve/tests/StatisticOutput.csv.gold"
    csvFile="${SST_ROOT}/sst/elements/memHierarchy/Sieve/tests/StatisticOutput.csv"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst/elements/memHierarchy/Sieve/tests/trace-text.py"
    pushd ${SST_ROOT}/sst/elements/memHierarchy/Sieve/tests

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        (${sut} ${sutArgs} > $outFile)
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
             wc $referenceFile $csvFile
             ls -l ${sut}
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             popd
             return
        fi
        # Ignore the time field in the answer, which has strange multi thread behavor
        sed 's/Histogram,....../Histogram,/' $referenceFile > Tgold
        sed 's/Histogram,....../Histogram,/' $csvFile > Tcsv 
        wc $referenceFile $csvFile
        diff -b Tgold Tcsv
        if [ $? != 0 ]
        then  
             fail " Reference does not Match Output"
        fi
        rm Tgold Tcsv
        echo ' '
        grep 'Simulation is complete' $outFile ; echo ' '
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    popd
}
export SST_TEST_ONE_TEST_TIMEOUT=30
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
