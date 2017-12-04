#! /bin/bash
# testSuite_juno.sh

# Description:

# This Suite does minumum test on the juno element

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
   refFile="${SST_ROOT}/juno/tests/refFiles/${testDataFileBase}.csv"

   cd $SST_ROOT/juno/test/asm           #4
echo "      -------   done the cd to test/asm "
    ../../asm/sst-juno-asm -i ${testname_case}.juno -o ${testname_case}.bin   #5-6
echo '    ---  '
   cd ../sst                                                 #7

   JUNO_EXE="../asm/${testname_case}.bin" sst juno-test.py > $outFile 2>$errFile    #8
   
   retVal=$?
echo "Return Code is $retVal"

   if [ -s $errFile ] ; then
      cat $errFile
      fail " Non-empty Error File  $testname_case "
      cat $outFile
      return
   fi

   wc $outFile

  ls -l $refFile output.csv
   diff $refFile output.csv
   if [ $? == 0 ] ; then
      echo " Exact Match"
   else
      fail " Output did not match Reference"
   fi


}


test_juno_sum() {

echo " --------------- start test invocation "
sst_info_Template sum

}

test_juno_modulo() {

echo " --------------- start test invocation "
sst_info_Template modulo

}

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
#         Located here this timeout will override the multithread value

(. ${SHUNIT2_SRC}/shunit2)


