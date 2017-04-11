# !/bin/bash
# testSuite_BadPort.sh

# Description:

# A shell script that defines a shunit2 test suite. This will be
# invoked by the Bamboo script.

TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_BadPort_suite" # Name of this test suite; will be used to
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
#     test_BadPort
# Purpose:
#     Verify that issue #289 is fixed.
#     Verify that a mispelled port name issues a message before seg fault
# Inputs:
#     
# Outputs:
#          
# Expected Results
#     A result other than Segfault   (11)  or 128 + 11 
# Caveats:
#    
#-------------------------------------------------------------------------------

PreFail " Skip BadPort test for now "  "skip"

test_BadPort() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    
    testDataFileBase="test_BadPort"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    L_TESTFILE+=(${testDataFileBase})

    sut="${SST_TEST_INSTALL_BIN}/sst"
    #  BadPort.py was created as a copy of merlin_dragon_12 with one character changed.
    sutArgs="${SST_TEST_INPUTS}/BadPort.py"
    rm -f ${outFile}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        # Because we expect a segfault, turn off stdout buffering so we get the full output
        if [ "$SST_TEST_HOST_OS_KERNEL" != "Darwin" ] ; then
             stdbuf -o0 -e0 ${sut} ${sutArgs} > $outFile 2>$errFile
        else
             script -a $outFile ${sut} ${sutArgs} 2>$errFile   #### this is MacOS version 
        fi
        retval=$?
        TIME_FLAG=/tmp/TimeFlag_$$_${__timerChild} 
        if [ -e $TIME_FLAG ] ; then 
             echo " Time Limit detected at `cat $TIME_FLAG` seconds" 
             fail " Time Limit detected at `cat $TIME_FLAG` seconds" 
             rm $TIME_FLAG 
             return 
        fi 

        if [ $retval != 0 ]
        then
            echo ' '; echo "WARNING: sst did not finish normally, RETVAL=$retval" ; echo ' '
            if [ $retval == 139 ] || [ $retval == 11 ] ; then
                echo "     SEG FAULT    This is the expected output from this test!" ; echo  ' '
                grep 'undocumented port' $outFile
                if [ $? != 0 ] ; then
                    echo "     The Error File:"
                    cat $errFile | c++filt       
                    echo "         Output File"
                    cat $outFile
                    fail " SEG FAULT"
                    return
                else
                    echo "     Detected missing or mis-matched Port"
                    #   Issue #289 has been fixed
                fi  
                echo ' '
            else
                echo "Error detected, but not SEG FAULT"
                echo "     The Error File:"
                cat $errFile | c++filt       
                echo "         Output File"
                cat $outFile
                fail "Is test faulty?"
                echo ' '
                return
            fi
        else
            grep 'undocumented port' $outFile
            if [ $? == 0 ] ; then
                echo " Test should have passed."
                if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin" ] ; then
                    echo " MacOS \"script\" sometimes misses  seg fault"
                fi
            else
                echo "Test is FLAWED.   Bad Input must be detected"
                echo "     The Error File:"
                cat $errFile | c++filt       
                echo "         Output File"
                cat $outFile
                fail "Test is FLAWED.   Bad Input must be detected"
            fi
        fi

    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
}

export SST_TEST_ONE_TEST_TIMEOUT=5

# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
