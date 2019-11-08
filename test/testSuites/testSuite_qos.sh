# !/bin/bash
# testSuite_qos.sh

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
L_SUITENAME="SST_qos_suite" # Name of this test suite; will be used to
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
#     test_qosCases
#-------------------------------------------------------------------------------
export LOADFILE="qos.load"
export PYTHONPATH="../test"
## pushd  ${SST_REFERENCE_ELEMENTS}/ember/tests
Match="lineWordCt"

qos_Template() {
qos_case=$1

    startSeconds=`date +%s`
     pushd  ${SST_REFERENCE_ELEMENTS}/ember/tests
    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_qos-${qos_case}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_REFERENCE_ELEMENTS}/ember/tests/refFiles/${testDataFileBase}.out"
wc $referenceFile
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    LOADFILE="qos.load"
    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
#    ls ${SST_ROOT}/sst-elements/src/sst/elements/
#    ls ${SST_ROOT}/sst-elements/src/sst/elements/ember/
#    ls ${SST_ROOT}/sst-elements/src/sst/elements/ember/tests/
    qostest="${SST_ROOT}/sst-elements/src/sst/elements/ember/tests/qos-${qos_case}.sh"
echo "DB $LINENO qostest = $qostest"

    echo sst \\ > thetest
    sed -n /'--'/p $qostest >> thetest
    echo '" ../test/emberLoad.py' >> thetest

echo "     thetest:"
cat thetest
echo "     ------"    
echo "line $LINENO  `pwd`"
    chmod +x thetest 
ls -l ../test/emberLoad.py


    if [ -f ${sut} ] && [ -x ${sut} ]
    then
ls -l thetest
        # Run SUT
        ./thetest > $outFile

        RetVal=$? 
        TIME_FLAG=$SSTTESTTEMPFILES/TimeFlag_$$_${__timerChild} 
        if [ -e $TIME_FLAG ] ; then 
             fail " Time Limit detected at `cat $TIME_FLAG` seconds" 
             rm $TIME_FLAG 
             return 
        fi 
        if [ $RetVal != 0 ]  
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             ls -l ${sut}
             fail " WARNING: sst did not finish normally, RetVal=$RetVal"
             wc $referenceFile $outFile
             return
        fi
        myWC $outFile $referenceFile

    myWC ${outFile} ${referenceFile}

    pushd ${SSTTESTTEMPFILES}

    diff -b $referenceFile $outFile > ${SSTTESTTEMPFILES}/_raw_diff
    if [ $? == 0 ] ; then
         echo "PASS:  Exact match $qos_case"
         rm ${SSTTESTTEMPFILES}/_raw_diff
    else
         myWC $referenceFile $outFile ${SSTTESTTEMPFILES}/_raw_diff
         rm diff_sorted
         compare_sorted $referenceFile $outFile
         if [ $? == 0 ] ; then
             echo "PASS:  Sorted match $qos_case"
             rm ${SSTTESTTEMPFILES}/_raw_diff
         else
             ref=`wc ${referenceFile} | awk '{print $1, $2}'`;
             new=`wc ${outFile}       | awk '{print $1, $2}'`;
             if [ "$ref" != "$new" ] ; then
                 echo "$qos_case test Fails"
                 echo "   tail of $outFile  ---- "
                 tail $outFile
                 fail "outFile word/line count does NOT match Reference"
                 diff ${referenceFile} ${outFile}
             else
                 if [ "lineWordCt" == "$Match" ] ; then
                     echo "PASS: word/line count match $qos_case"
                 else
                  fail "output does not match Reference"

                   echo "   ---- Here is the sorted diff ---"
                   cat ${SSTTESTTEMPFILES}/diff_sorted 


                 fi
             fi
         fi
    fi
echo "line $LINENO  `pwd`"
    popd
echo "line $LINENO  `pwd`"

    grep "Simulation is complete, simulated time:" $outFile
    if [ $? != 0 ] ; then 
        fail "Completion test message not found"
        echo ' '; grep -i complet $outFile ; echo ' '
    fi
  
    endSeconds=`date +%s`
    echo " "
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "${qos_case}: Wall Clock Time  $elapsedSeconds seconds"

# echo "This is the end of the Template"
   fi
}

test_qos_dragonfly() {
qos_Template dragonfly
}

test_qos_fattree() {
qos_Template fattree
}

test_qos_hyperx() {
qos_Template hyperx 
}

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
