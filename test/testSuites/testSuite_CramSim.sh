#!/bin/bash 
# testSuite_CramSim.sh

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


#=============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_CramSim_suite" # Name of this test suite; will be used to
                                 # identify this suite in SDL file. This
                                 # should be a single string, no spaces
                                 # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
#                     Set up

    ls -d $SST_TEST_SUITES/testCramSim 
    Ret_Val=$?
echo " Return from ls -d is $Ret_Val"
    if [ $Ret_Val == 0 ] ; then
        rm -rf $SST_TEST_SUITES/testCramSim
    fi
mkdir -p $SST_TEST_SUITES/testCramSim
cd $SST_TEST_SUITES/testCramSim
pwd

ln -s $SST_ROOT/sst-elements/src/sst/elements/CramSim/ddr4_verimem.cfg .
ls -l $SST_ROOT/sst-elements/src/sst/elements/CramSim/ddr4_verimem.cfg  > /dev/null
if [ $? != 0 ] ; then
   ls $SST_ROOT/sst-elements/src/sst/elements/CramSim
   exit
fi
mkdir tests

ln -s $SST_ROOT/sst-elements/src/sst/elements/CramSim/tests/* tests
ls -l ddr4_verimem.cfg
if [ $? != 0 ] ; then
   echo "############################################## $LINENO "
   exit
fi
cd tests

#                       TEMPLATE
#     Subroutine to run many similiar tests without reproducing the script.
#      First parameter is the name of the test, must match test_CramSim_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 500.)

CramSim_Template() {
trc=$1
Tol=$2    ##  curTick tolerance

cd $SST_TEST_SUITES/testCramSim

    startSeconds=`date +%s`
    testDataFileBase="test_CramSim_$trc"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    newOut="${SST_TEST_OUTPUTS}/${testDataFileBase}.newout"
    newRef="${SST_TEST_OUTPUTS}/${testDataFileBase}.newref"
    testOutFiles="${SST_TEST_OUTPUTS}/${testDataFileBase}.testFile"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    sut="${SST_TEST_INSTALL_BIN}/sst"

pushd tests
	wget https://github.com/sstsimulator/sst-downloads/releases/download/TestFiles/sst-CramSim-trace_verimem_${trc}.trc.gz >o${trc} 2>e${trc} 
	if [ $? != 0 ] ; then
            echo " Download of trace file failed for sst-CramSim-trace_verimem_${trc}.trc.gz "
            fail " Download of trace file failed for sst-CramSim-trace_verimem_${trc}.trc.gz "
            echo "           ----- stdout -----"
            cat o${trc}
            echo "           ----- stderr -----"
            cat e${trc}
            return
        fi
        gunzip sst-CramSim-trace_verimem_${trc}.trc.gz
popd

  ls -l tests/sst-CramSim-trace_verimem_${trc}.trc
#
#          Warning the text appended to the next line after the ## is required for multiThread auto configuration.
#
      ${sut} tests/test_txntrace4.py --model-options="--configfile=ddr4_verimem.cfg --tracefile=tests/sst-CramSim-trace_verimem_${trc}.trc" >$outFile   ##  ${sutArgs
      RetVal=$?

        echo " Running from `pwd`"

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
             wc $outFile
             echo " 20 line tail of \$outFile"
             tail -20 $outFile
             echo "    --------------------"
             return
        fi
        wc ${outFile} ${referenceFile} | awk -F/ '{print $1, $(NF-1) "/" $NF}'


        diff ${referenceFile} ${outFile} > /dev/null;
        if [ $? -ne 0 ]
        then
##  Follows some bailing wire to allow serialization branch to work
##          with same reference files  (Vestigal -- Not Added for CramSim)
     sed s/' (.*)'// $referenceFile > $newRef
     ref=`wc ${newRef} | awk '{print $1, $2}'`; 
     ##        ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
     sed s/' (.*)'// $outFile > $newOut
     new=`wc ${newOut} | awk '{print $1, $2}'`; 
     ##          new=`wc ${outFile}       | awk '{print $1, $2}'`;
        wc $newOut       
               if [ "$ref" == "$new" ];
               then
                   echo "outFile word/line count matches Reference"
               else
                   echo "CramSim_${trc} test Fails"
                   fail "outFile word/line count does NOT matches Reference"
                   diff ${referenceFile} ${outFile} 
               fi
        else
                echo ReferenceFile is an exact match of outFile
        fi

        endSeconds=`date +%s`
        echo " "
        elapsedSeconds=$(($endSeconds -$startSeconds))
        echo "CramSim_${trc}: Wall Clock Time  $elapsedSeconds seconds"

}


#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_CramSim
# Purpose:
#     Exercise the CramSim code in SST
# Inputs:
#     None
# Outputs:
#     test_CramSim_xxx.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     For shunit2, the output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
# Exception for tests   (History note not CramSim):
#     A fuzzy compare has been inserted here.   The only thing that varies is
#     the value of the total Ticks simulated.  With binaries shared from SVN, 
#     there should be no need for fuzziness.  When the static binary is build
#     using compiler and libraries on the host, the exact number of Ticks in the 
#     program may vary from that reported in the reference file checked into SVN.
#-------------------------------------------------------------------------------
test_CramSim_1_R() {          
CramSim_Template 1_R 500

}

test_CramSim_1_RW() {          
CramSim_Template 1_RW 500

}

test_CramSim_1_W() {          
CramSim_Template 1_W 500

}

test_CramSim_2_R() {          
CramSim_Template 2_R 500

}

test_CramSim_2_W() {          
CramSim_Template 2_W 500

}

test_CramSim_4_R() {          
CramSim_Template 4_R 500

}

test_CramSim_4_W() {          
CramSim_Template 4_W 500

}

test_CramSim_5_R() {          
CramSim_Template 5_R 500

}

test_CramSim_5_W() {          
CramSim_Template 5_W 500

}

test_CramSim_6_R() {          
CramSim_Template 6_R 500

}

test_CramSim_6_W() {          
CramSim_Template 6_W 500

}


export SST_TEST_ONE_TEST_TIMEOUT=3000         #  3000 seconds

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


export SST_TEST_ONE_TEST_TIMEOUT=200 
 
# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
#         Located here this timeout will override the multithread value
export SST_TEST_ONE_TEST_TIMEOUT=750
(. ${SHUNIT2_SRC}/shunit2)

