#! /bin/bash
# testSuite_juno.sh

# Description:

# This Suite does minumum test on the juno element

TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
#==========================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_JUNO_suite" # Name of this test suite;


L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================

   cd juno/asm                 #2
   make
echo "  the make is done -----------------"

sst_info_Template() {
   testname_case=$1    # "sum" or "modulo"
   testDataFileBase="juno_${testname_case}"
   outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
   errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
   refFile="${SST_ROOT}/juno/tests/refFiles/${testDataFileBase}.out"

   cd $SST_ROOT/juno/test/asm           #4
echo "      -------   done the cd to test/asm "
    ../../asm/sst-juno-asm -i ${testname_case}.juno -o ${testname_case}.bin   #5-6
echo '    ---  '
   cd ../sst                                     #7

##    pyFileName=`echo test${memHA_case}.py | sed s/_/-/`

    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs=${SST_ROOT}/juno/test/sst/juno-test.py

   export JUNO_EXE="../asm/${testname_case}.bin"
   ${sut} ${sutArgs} > $outFile 2>$errFile                  #8

   retVal=$?
   if [ $retVal != 0 ] ; then
       fail "Return Code is $retVal"
       echo " ---  Stderr:"
       cat $errFile
       echo " ---  Stdout:"
       cat $outFile
       echo "   "
       wc *csv
       return
   fi

   if [ -s $errFile ] ; then
      cat $errFile
      fail " Non-empty Error File  $testname_case "
      cat $outFile
      return
   fi
   TS=`grep "Simulation is complete" $outFile`
   if [ $? != 0 ] ; then
       fail "Did not find completion message"
       echo " ---  Stderr:"
       cat $errFile
       echo " ---  Stdout:"
       cat $outFile
       echo "   "
       wc *csv
       return
   fi

   RS=`grep "Simulation is complete" $refFile`
   if [ "$RS" == "$TS" ] ; then
      echo "    Exact Match"
      echo "$TS"
   else
      fail " Output did not match Reference"
      echo "Output: $TS"
      echo "  Ref:  $RS"
   fi

}


test_juno_sum() {

sst_info_Template sum

}

test_juno_modulo() {

sst_info_Template modulo

}

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
#         Located here this timeout will override the multithread value

(. ${SHUNIT2_SRC}/shunit2)


