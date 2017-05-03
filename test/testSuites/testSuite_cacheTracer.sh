# !/bin/bash
# testSuite_cacheTracer.sh

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
L_SUITENAME="SST_cacheTracer_suite" # Name of this test suite; will be used to
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
#     test_cacheTracer
# Purpose:
#     Exercise the cacheTracer 
# Inputs:
#     None
# Outputs:
#     test_cacheTracer.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_cacheTracer_1() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_cacheTracer_1"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    testOutFiles="${SST_TEST_OUTPUTS}/${testDataFileBase}.testFiles"
    referenceFile="${SST_REFERENCE_ELEMENTS}/cacheTracer/tests/refFiles/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    cd ${SST_ROOT}/sst-elements/src/sst/elements/cacheTracer/tests

    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/cacheTracer/tests/test_cacheTracer_1.py"

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        if [[ ${SST_MULTI_RANK_COUNT:+isSet} != isSet ]] || [ ${SST_MULTI_RANK_COUNT} -lt 2 ] ; then
             ${sut} ${sutArgs} > ${outFile}  2>${errFile}
             RetVal=$? 
             cat $errFile >> $outFile
        else
             #   This merges stderr with stdout
             mpirun -np ${SST_MULTI_RANK_COUNT} $NUMA_PARAM -output-filename $testOutFiles ${sut} ${sutArgs} 2>${errFile}
             RetVal=$?
             wc ${testOutFiles}*
             cat ${testOutFiles}* > $outFile
        fi

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
           fi
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
}

test_cacheTracer_2() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_cacheTracer_2"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    memRefFile="${SST_TEST_OUTPUTS}/${testDataFileBase}_memRef.out"
    referenceFile="${SST_REFERENCE_ELEMENTS}/cacheTracer/tests/refFiles/${testDataFileBase}_memRef.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    mkdir $SST_TEST_SUITES/cacheTracer_folder
    pushd $SST_TEST_SUITES/cacheTracer_folder

    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/cacheTracer/tests/test_cacheTracer_2.py"

touch $outFile
ls $outFile
    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
pwd
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
ls $outFile
        cat test_cacheTracer_2_mem_ref_trace.txt test_cacheTracer_2_mem_ref_stats.txt > $memRefFile
        wc $referenceFile test_cacheTracer_2*.txt $outFile $memRefFile
        diff -b $referenceFile $memRefFile
        if [ $? != 0 ]
        then  
             fail " Reference does not Match trace/stats file"
        else
             echo " test output matches Reference file"
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
(. ${SHUNIT2_SRC}/shunit2)
