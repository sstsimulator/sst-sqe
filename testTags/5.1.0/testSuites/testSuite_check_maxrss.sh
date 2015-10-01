# !/bin/bash
# testSuite_check-maxrss

# Description:  Check that the inconsistancy patched in sst for MacOS does not get resolved.

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
L_SUITENAME="SST_check_maxrss"  # Name of this test suite; will be used to
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
#     test_check_maxrss
# Outputs:
#     test_check_maxrss.out file
# Expected Results
#     Match value returned against Reference Value
#     Linux returns value in KB.   Some places Apple claims to do the same.
#     July 2013, Lion and Mt. Lion are returning bytes.
#     sst/core/main.cc has been patched to convert MacOS values to KB in printing
#     This test is an attempt to detect it, if Apple changes to KB. 
#-------------------------------------------------------------------------------
test_check_maxrss() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_check_maxrss"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst/elements/simpleElementExample/tests/test_simpleRNGComponent_mersenne.py"

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        ${sut} --verbose ${sutArgs} > $outFile
        if [ $? != 0 ]
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             fail "WARNING: sst did not finish normally"
             return
        fi

        newVal=`grep Max.Resident.Set $outFile | awk '{print $7}'`
#     Bailing wire to support enhanced format of verbose
#         For bash to do simple compare original KB units were convenient.
#            Convert MB to KB.
        MB=`grep Max.Resident.Set $outFile | awk '{print $8}'`
        if [ $MB == "MB" ] ; then
           newVal="$(echo "$newVal*1000" | bc)"
           newVal=`echo $newVal | awk -F. '{print $1}'`
        else
           echo "verbose format changed again"
           grep Max.Resident.Set $outFile
           echo " expect \"MB\", found $MB"
           fail "verbose format changed again"
        fi

        if [ ! -e referenceFile ] && [ ! -s $referenceFile ] ; then
            echo "No valid Reference file"
            fail "No valid Reference file"
            return 1
        fi

        refVal=`cat $referenceFile`
        if [ $newVal -gt $refVal ] ; then
            ratio=$((newVal/$refVal))
        else
            ratio=$((refVal/$newVal))
        fi
        echo " Ratio of maxrss values $ratio   (verify values are all KB)" 
        if [ $ratio -gt 500 ] ; then
            echo "This is a failure, expected KB value was about $refVal, found $newVal"
            echo " maxrss value assumed to KB"
            echo "  SST patch attempts correcting on MacOS    (see core/main.cc)"; echo " "
            fail "  SST patch attempts correcting on MacOS    (see core/main.cc)"
        else
            echo "Pass:  found $newVal, expected $refVal"
        fi

    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
}

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
    echo " Invoke SHUNIT "
(. ${SHUNIT2_SRC}/shunit2)
