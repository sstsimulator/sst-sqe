#!/bin/bash
# testSuite_macro.sh

set -o pipefail

# Description:

# A shell script that defines a shunit2 test suite. This will be
# invoked by the Bamboo script.

# Preconditions:

# 1) The "SUT", sst,  must have built successfully.
# 2) A test success reference file is available.

TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_macro_suite" # Name of this test suite; will be used to
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

# Check to see if we are supposed to build out of the source
if [[ ${SST_BUILDOUTOFSOURCE:+isSet} == isSet ]] ; then
    echo "NOTICE: TESTING SST-MACRO OUT OF SOURCE DIR"
    macrobuilddir="sst-macro-builddir"
else
    echo "NOTICE: TESTING SST-MACRO IN SOURCE DIR"
    macrobuilddir="sst-macro"
fi

#-------------------------------------------------------------------------------
# Test:
#     test_macro_make_check
# Purpose:
#     Exercise the sst-macro make check test from the build directory
# Inputs:
#     None
# Outputs:
#     test_macro_make_check.out file
# Expected Results
#     zero result from command make check
# Caveats:
#     None
#-------------------------------------------------------------------------------
test_macro_make_check() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    local testDataFileBase="test_macro_make_check"
    local outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    # NOTE: sst-macro Tests are run from the source directory,
    #       NOT from the install directory
    local macrodir=${SST_ROOT}/${macrobuilddir}
    local sut="Makefile"
    local sutArgs="check"

    pushd ${macrodir}

    local RetVal=0

    if [ -f ${sut} ]
    then
        # Run SUT
#        (make ${sutArgs} > $outFile)
        # TODO parameterize number of build threads
        (make -j4 ${sutArgs})
        RetVal=$?
        local TIME_FLAG=$SSTTESTTEMPFILES/TimeFlag_$$_${__timerChild}
        if [ -e $TIME_FLAG ] ; then
             echo " Time Limit detected at $(cat $TIME_FLAG) seconds"
             fail " Time Limit detected at $(cat $TIME_FLAG) seconds"
             rm $TIME_FLAG
             return
        fi
        if [[ $RetVal -ne 0 ]]
        then
             echo ' '; echo WARNING: sst-macro failed the test ; echo ' '
             ls -l ${sut}
             fail "sst-macro: Failed make check test; RetVal=$RetVal"
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    popd
}

#-------------------------------------------------------------------------------
# Test:
#     test_macro_make_installcheck
# Purpose:
#     Exercise the sst-macro make installcheck test from the build directory
# Inputs:
#     None
# Outputs:
#     test_macro_make_installcheck.out file
# Expected Results
#     zero result from command make check
# Caveats:
#     None
#-------------------------------------------------------------------------------
test_macro_make_installcheck() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    local testDataFileBase="test_macro_make_installcheck"
    local outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    # NOTE: sst-macro Tests are run from the source directory,
    #       NOT from the install directory
    local macrodir=${SST_ROOT}/${macrobuilddir}
    local sut="Makefile"
    local sutArgs="installcheck"

    pushd ${macrodir}

    local RetVal=0

    if [ -f ${sut} ]
    then
        # Run SUT
#        (make ${sutArgs} > $outFile)
        # TODO parameterize number of build threads
        (make -j4 ${sutArgs})
        RetVal=$?
        local TIME_FLAG=$SSTTESTTEMPFILES/TimeFlag_$$_${__timerChild}
        if [ -e $TIME_FLAG ] ; then
             echo " Time Limit detected at $(cat $TIME_FLAG) seconds"
             fail " Time Limit detected at $(cat $TIME_FLAG) seconds"
             rm $TIME_FLAG
             return
        fi
        if [[ $RetVal -ne 0 ]]
        then
             echo ' '; echo WARNING: sst-macro failed the test ; echo ' '
             ls -l ${sut}
             fail "sst-macro: Failed make installcheck test; RetVal=$RetVal"
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    popd
}


export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
