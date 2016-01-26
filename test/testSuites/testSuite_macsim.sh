# !/bin/bash
# testSuite_macsim.sh

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
L_SUITENAME="testSuite_macsim" # Name of this test suite; will be used to
                                # identify this suite in XML file. This
                                # should be a single string, no spaces
                                # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names


    if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] ; then
       if [ $SST_MULTI_THREAD_COUNT -gt 1 ] ; then
           echo '           SKIP '
           preFail " MacSim tests do not work with threading (#74)" "skip"
       fi
    fi 
    
    if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin" ] ; then
           echo '           SKIP '
           preFail " MacSim tests do not work on MacOS (#43)" "skip"
    fi


#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_macsim
# Purpose:
#     Exercise  macsim
#         with two version of the test (macsim, macsim_sdl1 and macsimsdl2)
# Inputs:
#     None
# Outputs:
#     2-line  pass/fail file for the original test
#     12 files to compare for each of the other tests
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*, with one 
#     exception,requiring that the command lines for creating both the 
#     output file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_macsim() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_macsim"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    cd ${SST_ROOT}/sst/elements/macsimComponent/sst-unit-test
    if [ $? != 0 ]
    then
         echo ' '; echo WARNING: Could not cd to location for MacSim  ; echo ' '
         return
    fi

    # Define Software Under Test (SUT) 
    sut="${SST_TEST_INSTALL_BIN}/sst"

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        ./runTests.py | sort > ${outFile}

        # Don't bother to look at $?, it is the return from sort!
        #     return from sst must be checked in the Python script

        wc ${referenceFile} ${outFile}
        diff ${referenceFile} ${outFile}
        if [ $? != 0 ]
        then
           echo ' '; echo "MACSIM TEST FAILED"
           fail "TEST FAILED"
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        fail "Problem with SUT: ${sut}"
    fi
}

macsim_Template() {
macsim_case=$1

    startSeconds=`date +%s`
    # Define a common basename for test output and reference files.
    testDataFileBase="test_macsim_${macsim_case}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst/elements/macsimComponent/sst-unit-test/${macsim_case}.py"
    cd ${SST_ROOT}/sst/elements/macsimComponent/sst-unit-test

    echo "   Examine sutArgs"
    echo ${sutArgs}
    ls -l ${sutArgs}
    echo "PWD    `pwd`"
    ls
    echo ' '

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
             ls -l ${sut}
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             return
        fi
        pushd ./references/vectoradd/${macsim_case}
        fileList=`ls *`
        popd

        matchFail=0
        for ref in $fileList
        do
            wc  ./references/vectoradd/${macsim_case}/$ref ./results/$ref 
            diff  ./references/vectoradd/${macsim_case}/$ref ./results/$ref > /dev/null
            if [ $? != 0 ] ; then
               echo "   ---  Reviewing  ${macsim_case}   $ref"
               grep -v EXE_TIME ./references/vectoradd/${macsim_case}/$ref > _r
               grep -v EXE_TIME ./results/$ref > _o
               diff _r _o
               if [ $? == 0 ] ; then
                  echo "Pass"
                  continue
               fi 
               echo "Output does not match Reference for macsim ${macsim_case} $ref"         
               matchFail=1
            fi
        done
        if [ $matchFail == 1 ] ; then
           fail "Output does not match Reference for macsim ${macsim_case}"         
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    grep 'Simulation is complete' $outFile
  
    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "macsim_${macsim_case}: Wall Clock Time  $elapsedSeconds seconds"
    echo " "

}

test_macsim_sdl1() {
macsim_Template sdl1

}

test_macsim_sdl2() {
macsim_Template sdl2

}

cd $SST_ROOT

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
