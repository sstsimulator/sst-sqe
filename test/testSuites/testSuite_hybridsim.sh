# !/bin/bash
# testSuite_hybridsim.sh

# Description:

# A shell script that defines a shunit2 test suite. This will be
# invoked by the Bamboo script.

# Preconditions:
# 2) A test success reference file is available.

TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_hybridsim_suite" # Name of this test suite; will be used to
                                # identify this suite in XML file. This
                                # should be a single string, no spaces
                                # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

OPWD=`pwd`    # Save Original PWD

if [[ ${SST_DEPS_INSTALL_HYBRIDSIM:+isSet} != isSet ]] ; then
    echo "HybridSim requires manual definition of environment variable:"
    echo "      SST_DEPS_INSTALL_HYBRIDSIM"
    preFail "HybridSim requires SST_DEPS_INSTALL_HYBRIDSIM"
fi

# Initialize the test environment, if needed
if [ ! -d ${TEST_SUITE_ROOT}/testHybridSim/runtests ] ; then
    mkdir -p $TEST_SUITE_ROOT/testHybridSim/HybridSim
    cd $TEST_SUITE_ROOT/testHybridSim/HybridSim
    ln -s $SST_DEPS_INSTALL_HYBRIDSIM/ini ini
    mkdir ../runtests
    cd ../runtests
else
    cd $TEST_SUITE_ROOT/testHybridSim/runtests
fi

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_hybridsim
# Purpose:
#     Exercise the hybridsim
# Inputs:
#     None
# Outputs:
#     test_hybridsim.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_hybridsim() {

    cd $TEST_SUITE_ROOT/testHybridSim/runtests
    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_hybridsim"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    tmpFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.tmp"
    memH_test_dir=${SST_REFERENCE_ELEMENTS}/memHierarchy/tests
    referenceFile="${memH_test_dir}/refFiles/${testDataFileBase}.out"
ls -l $referenceFile 
if [ $? .ne. 0 ] ; then 
    echo " " ; echo "  Ref File is not there" ; echo " " 
    return 
fi 
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_TEST_INPUTS}/testSdlFiles/HybridSim/sdl3-2-edit.py"

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
    ###################################
    grep -v 'cpu.:' $outFile > $tmpFile
    wc $referenceFile  $outFile $tmpFile
    cp $tmpFile $outFile

    RemoveComponentWarning

    diff ${outFile} ${referenceFile} > /dev/null;
    if [ $? -ne 0 ]
    then
        ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
        new=`wc ${outFile}       | awk '{print $1, $2}'`;
        if [ "$ref" == "$new" ];
        then
            echo "OutFile word/line count matches Reference"
        else
            echo "OutFile word/line count DOES NOT matches Reference"
            fail "OutFile word/line count DOES NOT matches Reference"
            echo "      ---  EXPECTED:"
            cat ${referenceFile}
            echo "      ---  Received:"
            cat ${outFile}
            echo "testSuite:   --- DONE ---"
        fi
    else
        echo OutFile is an exact match of ReferenceFile
    fi 
}

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS



# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
cd $OPWD        # Restore entry PWD
(. ${SHUNIT2_SRC}/shunit2)
