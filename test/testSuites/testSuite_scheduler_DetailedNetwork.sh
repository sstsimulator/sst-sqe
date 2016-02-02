#!/bin/bash
# testSuite_scheduler_DetailedNetwork.sh

# Description:

# A shell script that defines a shunit2 test suite. This will be
# invoked by the Bamboo script.

# Preconditions:

# 1) The SUT (software under test) must have built successfully.
# 2) A test success reference file is available.
#  There is no sutArgs= statement.  SST is python wrapped.

TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="scheduler_DetailedNetwork_suite" # Name of this test suite; will be used to
                                        # identify this suite in XML file. This
                                        # should be a single string, no spaces
                                        # please.

L_TESTFILE=()  # Empty list, used to hold test file names

    if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] ; then
       if [ $SST_MULTI_THREAD_COUNT -gt 1 ] ; then
           echo '           SKIP '
           preFail " Scheduler tests do not work with threading" "skip"
       fi
    fi     

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     scheduler_DetailedNetwork
# Purpose:
#     Exercise the scheduler_DetailedNetwork
# Inputs:
#     None
# Outputs:
#     test_scheduler_DetailedNetwork.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------Above is 50 lines of boiler plate --

# set
if [ "x$SST_SRC" == "x" ] ; then

##-John
    SST_SRC=$SST_ROOT
##-John

    #source ~/SST/set_sst_env.sh

    # Set the path to the source code of SST
    # For me $SST_SRC=/home/fkaplan/SST/scratch/src/sst-simulator
    echo $SST_SRC
fi

echo ' '
echo "   Started at `date`"
echo "   Be Patient.  This test runs over 4 minutes on sst-test"
echo "   IGNORE the word \"FATAL\" in output messages"

test_scheduler_DetailedNetwork() {
# Path to the testReferenceFiles

# SST_TEST_REFERENCE=$SST_SRC/sqe/test/testReferenceFiles

# Path to the testInputFiles. There is nothing in that folder yet. I copy all inputs from the scheduler/simulations folder below.
##DEL  TEST_INPUTS=$SST_SRC/sqe/test/testInputFiles
# Path to the test folder that I run the tests from.

##-John
# TEST_FOLDER=$HOME/SST/local/test
TEST_FOLDER=${SST_TEST_SUITES}/testFolder_scheduler
mkdir -p $TEST_FOLDER
##-John

# I think there are 5 other tests created for the scheduler. This one must be TEST #6.
##### TEST 6 ####################

TEST_NAME=test_DetailedNetwork
# OUTFILE=test.temp
outFile=${SST_TEST_OUTPUTS}/${TEST_NAME}.out
rm -f $outFile

# copy all necessary files to run this test

cd $TEST_FOLDER

cp $SST_SRC/sst/elements/scheduler/simulations/${TEST_NAME}.sim .
cp $SST_SRC/sst/elements/scheduler/simulations/*.phase .

# cp $SST_SRC/sst/elements/scheduler/simulations/emberLoad.py .
# The path to other python files (ember defaults, network defaults etc.) included by emberLoad.py.

##-John
# emberpath="/home/fkaplan/SST/scratch/src/sst-simulator/sst/elements/ember/test"
emberpath="$SST_SRC/sst/elements/ember/test"
# echo ' '; echo                        "emberpath is $emberpath " ; echo ' '
##-John

# Insert the ember path in emberLoad.py.  
#sed -i "s|PATH|$emberpath|g" emberLoad.py
sed "s|PATH|$emberpath|g" $SST_SRC/sst/elements/scheduler/simulations/emberLoad.py > emberLoad.py

##  John 2016
## cp $SST_SRC/sst/elements/scheduler/simulations/run_DetailedNetworkSim.py .
cp $SST_TEST_ROOT/testInputFiles/run_DetailedNetworkSim.py .
##  John 2016
cp $SST_SRC/sst/elements/scheduler/simulations/snapshotParser_sched.py .
cp $SST_SRC/sst/elements/scheduler/simulations/snapshotParser_ember.py .
cp $SST_SRC/sst/elements/scheduler/simulations/${TEST_NAME}.py .
#cp $TEST_INPUTS/testSdlFiles/${TEST_NAME}.py .
if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] && [ $SST_MULTI_THREAD_COUNT -gt 0 ] ; then
   echo "Setting Multi thread count to $SST_MULTI_THREAD_COUNT"
   sed -i'.x' '/init_cmd  = "sst/s/sst/sst -n '"$SST_MULTI_THREAD_COUNT"/ run_DetailedNetworkSim.py
fi    
grep 'sst ' run_DetailedNetworkSim.py

# run sst
 
## ./run_DetailedNetworkSim.py --emberOut ember.out --schedPy ${TEST_NAME}.py > /dev/null
./run_DetailedNetworkSim.py --emberOut ember.out --schedPy ${TEST_NAME}.py | sed 900q
retVal=$?
if [ $retVal -ne 0 ] ; then
#    FAIL and BAIL
    fail "Scheduler test 6 execution Failed: retVal = $retVal"
    return
fi

# combine results to match reference

tail -n +2 "$TEST_NAME.sim.alloc" >> $outFile
tail -n +2 "$TEST_NAME.sim.time" >> $outFile

# compare with reference

diff -u $SST_TEST_REFERENCE/test_scheduler_DetailedNetwork.out $outFile > $TEST_NAME.tmp

if [ "`cat $TEST_NAME.tmp`x" == "x" ]
then
    echo "Test 6 PASSED"
else
    wc $SST_TEST_REFERENCE/test_scheduler_DetailedNetwork.out $outFile
    echo "Test 6 FAILED"
    fail " Scheduler Test 6 FAILED"
    return
fi
    
# remove all files

rm ${TEST_NAME}.py
rm ${TEST_NAME}.sim
rm ${TEST_NAME}.sim.snapshot.xml
rm "$TEST_NAME.sim.alloc"
rm "$TEST_NAME.sim.time"
rm *.phase
rm emberLoad.py
rm run_DetailedNetworkSim.py
rm snapshotParser_sched.py
rm snapshotParser_ember.py
rm $TEST_NAME.tmp
rm ember.out
rm loadfile
rm emberCompleted.txt
rm emberRunning.txt
}

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
export SST_TEST_ONE_TEST_TIMEOUT=800

(. ${SHUNIT2_SRC}/shunit2)
