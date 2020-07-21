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

# Looking for the Ariel/Pin Library
echo "INTEL_PIN_DIRECTORY = $INTEL_PIN_DIRECTORY"
if [ ! -d "$INTEL_PIN_DIRECTORY" ] ; then
    echo "MemHSieve tests requires PIN DIRECTORY"
    echo "        NOT  FOUND"
    echo " Environment Variable INTEL_PIN_DIRECTORY must be defined"
    preFail "MemHSieve tests requires PIN DIRECTORY" "skip"
fi 

# Count the Streams
echo " First call to countStreams follow: "
countStreams

# allows overriding Darwin as determination of OPENMP
if [[ ${SST_WITH_OPENMP:+isSet} != isSet ]] ; then
    SST_WITH_OPENMP=1;
    if [ $SST_TEST_HOST_OS_KERNEL == "Darwin" ] ; then
        SST_WITH_OPENMP=0;
    fi
fi

#### Remove old ompsievetest task
Remove_old_ompsievetest_task

rm -fr $SST_TEST_SUITES/memHS_folder
mkdir $SST_TEST_SUITES/memHS_folder
pushd $SST_TEST_SUITES/memHS_folder
#   Remove old files if any
rm -f ompsievetest.o ompsievetest backtrace_* StatisticOutput.csv mallocRank.txt-0.txt ${SSTTESTTEMPFILES}/23_43.ref ${SSTTESTTEMPFILES}/23_43.out

#   Build ompsievetest
cp $SST_ROOT/sst-elements/src/sst/elements/memHierarchy/Sieve/tests/Makefile .
ln -sf $SST_ROOT/sst-elements/src/sst/elements/memHierarchy/Sieve/tests/ompsievetest.c .
#      Optionally remove openmp from the build
if [ $SST_WITH_OPENMP == 0 ] ; then
    echo "         ### Remove \"-fopenmp\" from the make"
    sed -i'.x' 's/-fopenmp//' Makefile
fi
make
ls -l ompsievetest

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

test_memHSieve() {

    # Define a common basename for test csv and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_memHSieve"
    referenceFile="${SST_REFERENCE_ELEMENTS}/memHierarchy/Sieve/tests/refFiles/${testDataFileBase}.out"
    csvFile="${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/Sieve/tests/StatisticOutput.csv"
    csvFileBase="${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/Sieve/tests/StatisticOutput"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/Sieve/tests/sieve-test.py"
    rm -f StatisticOutput*csv
    rm -f mallocRank.txt-0*

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        (${sut}  ${sutArgs} | tee $outFile)
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
            wc $referenceFile $csvFileBase*.csv
            ls -l ${sut}
            fail "WARNING: sst did not finish normally, RetVal=$RetVal"
            popd
            return
        fi

##########################  the very fuzzy pass criteria  (four)
        #  Look at what we'e got
        echo "---- Check the result"
        ls -ltr
        FAIL=0

        #####

        # all of the backtrace_*txt files have something in them.
        echo ""
        echo "---- 1 - Check the Backtrace files"
        LOCALFAIL=0
        if [[ ${SST_USING_PIN3:+isSet} == isSet ]] ; then
            echo "NOTE: BACKTRACE GZ FILES ARE NOT GENERATED WHEN USING PIN3..."
            ls backtrace_*txt > /dev/null
            if [ $? != 0 ] ; then
                FAIL=1
                LOCALFAIL=1
            fi
            ls backtrace_*txt
            wc *.txt
        else
            ls backtrace_*txt.gz > /dev/null
            if [ $? != 0 ] ; then
                FAIL=1
                LOCALFAIL=1
            fi

            if [ $SST_WITH_OPENMP == 1 ] ; then
                echo "Checking backtrace files for SST_WITH_OPENMP"
                for gzfn in `ls backtrace_*txt.gz`
                do
                    fn=`echo $gzfn | awk -F'.gz' '{print $1}'`
                    gzip -d $gzfn
                    if [[ ! -s $fn ]] ; then
                        echo "$fn is empty, test fails"
                        FAIL=1
                        LOCALFAIL=1
                    fi
                done
                wc *.txt
            fi
        fi

        if [[ $LOCALFAIL == 1 ]]; then
            echo "---- 1 - Check the Backtrace files ---- FAILED"
        else
            echo "---- 1 - Check the Backtrace files ---- PASSED"
        fi

        #####

        #  mallocRank.0 is not empty
        echo ""
        echo "---- 2 - Check mallockRank"
        LOCALFAIL=0
        ls -l mallocRank*
        mR_len=`wc -w mallocRank.txt* | awk '{print $1}'`
        if [ $mR_len -ge 0 ] ; then
            echo "mallocRank.txt has $mR_len words"
        else
            echo "mallocRank.txt-0 is empty, test fails"
            FAIL=1
            LOCALFAIL=1
        fi

        if [[ $LOCALFAIL == 1 ]]; then
            echo "---- 2 - Check mallockRank ---- FAILED"
        else
            echo "---- 2 - Check mallockRank ---- PASSED"
        fi

        #####

        # the six sieve statics in StatisticOutput.csv are non zero
        echo ""
        echo "---- 3 - Check the stats"
        LOCALFAIL=0

        SievecheckStats() {
            notz=`grep -w $1 StatisticOutput*.csv | awk '{print $NF*($NF-1)*$NF-2}'`
            if [ $notz == 0 ] ; then
                echo "stat $1 has a zero"
                FAIL=1
                LOCALFAIL=1
            fi
        }

        SievecheckStats "ReadHits"
        SievecheckStats "ReadMisses"
        SievecheckStats "WriteHits"
        SievecheckStats "WriteMisses"
        SievecheckStats "UnassociatedReadMisses"
        SievecheckStats "UnassociatedWriteMisses"

        if [[ $LOCALFAIL == 1 ]]; then
            echo "---- 3 - Check the stats ---- FAILED"
        else
            echo "---- 3 - Check the stats ---- PASSED"
        fi

        #####

        #   Refeference file should be exact match lines 23 to 43 of StatisticOutput.csv.gold
        #           Line numbers change slightly on Multi Rank.
        echo ""
        echo  "---- 4 - Look at StatisticOutput.csv"
        LOCALFAIL=0
        wc $referenceFile $outFile

        grep -w -e '^.$' -e '^..$' $referenceFile  > ${SSTTESTTEMPFILES}/23_43.ref
        grep -w -e '^.$' -e '^..$' $outFile > ${SSTTESTTEMPFILES}/23_43.out
        wc ${SSTTESTTEMPFILES}/23_43.???

        diff ${SSTTESTTEMPFILES}/23_43.ref ${SSTTESTTEMPFILES}/23_43.out
        if [ $? != 0 ] ; then
            echo " lines 23 to 43 of csv gold did not match"
            FAIL=1
            LOCALFAIL=1
        fi

        if [[ $LOCALFAIL == 1 ]]; then
            echo  "---- 4 - Look at StatisticOutput.csv ---- FAILED"
        else
            echo  "---- 4 - Look at StatisticOutput.csv ---- PASSED"
        fi

        #######################################

        if [ $FAIL == 0 ] ; then
            echo "Sieve test PASSED"
        else
            fail " Sieve test FAILED - did NOT meet required conditions"
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

export SST_TEST_ONE_TEST_TIMEOUT=200
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)

Remove_old_ompsievetest_task
echo "                --- returned from Remove_old_omps...   "
echo " memHS $LINENO ----------------"

MY_TREE=`pwd | awk -F 'devel/trunk' '{print $1 }'`
echo  "DEBUG?   MY_TREE is $MY_TREE "
PAIR_PID=`ps -f | awk '{print $1,$2,$3,$4,$5,$6,$7,$8}' | grep -v -e grep | grep ompsievetest | awk '{print $2, $3}'`
echo "$PAIR_PID ++++ PAIR_PID +++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
TREE_PID=`echo $PAIR_PID | awk '{print $2}'`
OMP_PID=`echo $PAIR_PID | awk '{print $1}'`

if [ ! -z $TREE_PID ] && [ ! -z $OMP_PID ] ; then
    ps -f -p $TREE_PID | grep $MY_TREE
    if [ $? == 0 ] ; then
        echo " Line $LINENO   -- kill ompsievetest "
        ps -f -p $OMP_PID
        kill -9 $OMP_PID
    else
        echo "$OMP_PID - ompsievetest is not on current tree"
    fi
fi

date
echo ' '

echo " Call to countStreams \"Delete\"follows: "

countStreams "Delete"
