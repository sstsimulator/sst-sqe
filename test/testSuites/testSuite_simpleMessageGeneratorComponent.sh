# !/bin/bash
# testSuite_simpleMessageGeneratorComponent.sh

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
L_SUITENAME="SST_messageGenerator_suite" # Name of this test suite; will be used to
                                # identify this suite in XML file. This
                                # should be a single string, no spaces
                                # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
# Use the new shunit2 option only
#===============================================================================

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_simpleMessageGeneratorComponent
# Purpose:
#     Exercise the simpleMessageGeneratorComponent
# Inputs:
#     None
# Outputs:
#     test_simpleMessageGeneratorComponent.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_simpleMessageGeneratorComponent() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    
    testDataFileBase="test_simpleMessageGeneratorComponent"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_REFERENCE_ELEMENTS}/simpleElementExample/tests/refFiles/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/simpleElementExample/tests/test_simpleMessageGeneratorComponent.py"
    rm -f ${outFile}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        (${sut} ${sutArgs} > $outFile)
        RetVal=$? 
        TIME_FLAG=$SSTTESTTEMPFILES/TimeFlag_$$_${__timerChild} 
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
             sed 10q $outFile
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             RemoveComponentWarning
             return
        fi
        RemoveComponentWarning
        wc $referenceFile $outFile
        diff -b $referenceFile $outFile > ${SSTTESTTEMPFILES}/_raw_diff
        if [ $? != 0 ]
        then
           wc ${SSTTESTTEMPFILES}/_raw_diff
           compare_sorted $referenceFile $outFile
           if [ $? == 0 ] ; then
              echo " Sorted match with Reference File"
              rm ${SSTTESTTEMPFILES}/_raw_diff
              return
           else
              fail " Reference does not Match Output"
              diff -b $referenceFile $outFile
           fi
        else
           echo "Exact match with Reference File"
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
}

export SST_TEST_ONE_TEST_TIMEOUT=30     # 30 seconds is plenty.  One second is normal.
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
