# !/bin/bash
# testSuite_embernightly.sh

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
L_SUITENAME="SST_embernightly_suite" # Name of this test suite; will be used to
                                # identify this suite in XML file. This
                                # should be a single string, no spaces
                                # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#=====================================================
#  A bit of code to clear out old openmpi files from /tmp

    ls -ld /tmp/openmpi-sessions*/* |grep $USER > __rmlist
    wc __rmlist
#    cat __rmlist | sed 10q

    today=$(( 10#`date +%j` ))
    echo "today is $today"
if [ $SST_TEST_HOST_OS_KERNEL != "Darwin" ] ; then
#   --This is Linux code and MacOS can't handle this date syntax--
    
    while read -u 3 r1 r2 r3 r4 r5 mo da r8 name
    do
      c_day=$(( 10#`date +%j -d "$mo $da"` ))
      if [ "$mo" == "Dec" ] && [ $c_day -lt 360 ] ; then
         echo found Dec
         echo "Remove $name"
         rm -rf $name
      fi 
      c_day_plus_2=$(($c_day+2))
      if [ $today -gt $c_day_plus_2 ] ; then
         echo "Remove $name"
         rm -rf $name
      fi
    
    done 3<__rmlist
fi
    rm __rmlist
#=====================================================

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_embernightly
# Purpose:
#     Exercise the embernightly
# Inputs:
#     None
# Outputs:
#     test_embernightly.out file
# Expected Results
#     Match of output file against reference file
#-------------------------------------------------------------------------------
test_embernightly() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_embernightly"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    referenceFile="${SST_REFERENCE_ELEMENTS}/ember/tests/refFiles/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
    pushd $SST_ROOT/sst-elements/src/sst/elements/ember/test

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/ember/test/emberLoad.py"

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
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             wc $referenceFile $outFile
             echo "   Tail of outFile"
             tail -10 $outFile
             popd
             return
        fi
        wc $referenceFile $outFile

        RemoveComponentWarning

        diff ${referenceFile} ${outFile} > ${SSTTESTTEMPFILES}/full.diff 
        if [ $? -ne 0 ]
        then
            ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
            new=`wc ${outFile}       | awk '{print $1, $2}'`;
            if [ "$ref" == "$new" ]
            then 
                echo "    Output passed  LineWordCt match"
            else
                echo "    Output Flunked  lineWordCt Count match"
                fail "    Output Flunked  lineWordCt Count match"
            fi
            wc ${SSTTESTTEMPFILES}/full.diff
            lcr=`wc -l $referenceFile | awk '{print $1}'`
            lco=`wc -l $outFile | awk '{print $1}'`
            if [ $lco -gt $lcr ] ; then
                echo "     $(($lco-$lcr)) lines more in output"
            else
                echo "     $(($lcr-$lco)) lines less in output"
            fi
            echo "            *** Tail of Diff ***"
            tail -10 ${SSTTESTTEMPFILES}/full.diff
        else
            grep 'Simulation is complete' $outFile
            echo "    Output matches Reference File exactly"
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    popd
}

test_ember_params() {

    
    testDataFileBase="test_ember_params"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
    pushd ${SST_ROOT}/sst-elements/src/sst/elements/ember/test

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/ember/test/emberLoad.py"
    rm -f ${outFile}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        ${sut} --verbose --model-options "--topo=torus --shape=4x4x4 --cmdLine=\"Init\" --cmdLine=\"Allreduce\" --cmdLine=\"Fini\"" ${sutArgs} > $outFile 2>$errFile
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
             echo "And the Error File  (first 10 lines):"
             sed 10q $errFile
             echo "       - - -    (and the last 10 line)"
             tail -10 $errFile
             popd
             return
        fi
        wc $errFile $outFile $partFile
    fi    
    grep 'Simulation is complete' $outFile
    popd
}

export SST_TEST_ONE_TEST_TIMEOUT=100

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
