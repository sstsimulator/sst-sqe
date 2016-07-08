# !/bin/bash
# testSuite_memHSieve.sh

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
L_SUITENAME="SST_memHSieve_suite" # Name of this test suite; will be used to
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
if [[ ! -s $SST_BASE/local/sst-elements/lib/sst-elements-library/libariel.so ]] ; then
    preFail "Skipping memHSieve, (no Ariel )"  "skip"
else
     echo "Found the Ariel file! "
fi

#-------------------------------------------------------------------------------
# Test:
#     test_memHSieve
# Purpose:
#     Exercise the memHSieve of the simpleElementExample
# Inputs:
#     None
# Outputs:
#     test_memHSieve.csv file
# Expected Results
#     Match of output csv file against reference file
# Caveats:
#     The csvput files must match the reference file *exactly*,
#     requiring that the command lines for creating both the csvput
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------

    #          allows overriding Darwin as determination of OPENMP
    if [[ ${SST_WITH_OPENMP:+isSet} != isSet ]] ; then
        SST_WITH_OPENMP=1;
        if [ $SST_TEST_HOST_OS_KERNEL == "Darwin" ] ; then
           SST_WITH_OPENMP=0;
        fi
    fi

        
pushd $SST_ROOT/sst-elements/src/sst/elements/memHierarchy/Sieve/tests
#   Remove old files if any
rm -f ompsievetest.o ompsievetest backtrace_* StatisticOutput.csv mallocRank.txt-0.txt 23_43.ref 23_43.out

#   Build ompsievetest
    #      Optionally remove openmp from the build
    if [ $SST_WITH_OPENMP == 0 ] ; then
        echo "         ### Remove \"-fopenmp\" from the make"
        sed -i'.x' 's/-fopenmp//' Makefile
    fi
    make
    ls -l ompsievetest

popd

test_memHSieve() {

    # Define a common basename for test csv and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_memHSieve"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    csvFile="${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/Sieve/tests/StatisticOutput.csv"
    csvFileBase="${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/Sieve/tests/StatisticOutput"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/Sieve/tests/sieve-test.py"
    pushd ${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/Sieve/tests
    rm -f StatisticOutput*csv
    rm -f mallocRank.txt-0*

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        (${sut}  ${sutArgs} | tee $outFile)
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
             wc $referenceFile $csvFileBase*.csv
             ls -l ${sut}
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             popd
             return
        fi
#  Look at what we'e got
echo "  Check the result"
ls -ltr
##########################  the very fuzzy pass criteria  (four)
        FAIL=0
# all of the backtrace_*txt files have something in them.
        echo "         1 - Check the Backtrace files"
        ls backtrace_*txt.gz > /dev/null
        if [ $? != 0 ] ; then
           FAIL=1
        fi
        if [ $SST_WITH_OPENMP == 1 ] ; then
           for gzfn in `ls backtrace_*txt.gz`
           do
              fn=`echo $gzfn | awk -F'.gz' '{print $1}'`
              gzip -d $gzfn
              if [[ ! -s $fn ]] ; then
                 echo "$fn is empty, test fails"
                 FAIL=1
              fi
           done
           wc *.txt
         fi

#  mallocRank.0 is not empty
   echo "         2 - Check mallockRank"
   ls -l mallocRank*
       mR_len=`wc -w mallocRank.txt* | awk '{print $1}'`
       if [ $mR_len -ge 0 ] ; then
          echo "mallocRank.txt has $mR_len words"
       else
          echo "mallocRank.txt-0 is empty, test fails"
          FAIL=1
       fi

# the six sieve statics in StatisticOutput.csv are non zero
       echo "         3 - Check the stats"
       SievecheckStats() {
       notz=`grep -w $1 StatisticOutput*.csv | awk '{print $NF*($NF-1)*$NF-2}'`
       if [ $notz == 0 ] ; then
          echo "stat $1 has a zero"
          FAIL=1
       fi
       }
       SievecheckStats "ReadHits"
       SievecheckStats "ReadMisses"
       SievecheckStats "WriteHits"
       SievecheckStats "WriteMisses"
       SievecheckStats "UnassociatedReadMisses"
       SievecheckStats "UnassociatedWriteMisses"

#   Refeference file should be exact match lines 23 to 43 of StatisticOutput.csv.gold
#           Line numbers change slightly on Multi Rank.
   echo  "         4 - Look at StatisticOutput.csv"
        wc $referenceFile $outFile

        grep -w -e '^.$' -e '^..$' $referenceFile  > 23_43.ref
        grep -w -e '^.$' -e '^..$' $outFile > 23_43.out 
        wc 23_43.???

        diff 23_43.ref 23_43.out
        if [ $? != 0 ] ; then
           echo " lines 23 to 43 of csv gold did not match"
           FAIL=1
        fi

        if [ $FAIL == 0 ] ; then
           echo "Sieve test PASSED"
        else
           fail " Sieve test did NOT meet required conditions"
        fi

            echo ' '
            grep 'Simulation is complete' $outFile ; echo ' '
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    popd
}
export SST_TEST_ONE_TEST_TIMEOUT=50
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
