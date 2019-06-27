#!/bin/bash
# testSuite_sst_GNA.sh

# Description:

# This Suite is minimal test of GNA element
TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh


#=============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_sst_GNA" # Name of this test suite;


L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
echo " this is b4 template"

template_sst_GNA() {
   testN="test${1}"
   testDataFileBase="test_sst_GNA"
   outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}${testN}.out"
   errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}${testN}.err"
   refFile=${SST_REFERENCE_ELEMENTS}/GNA/tests/refFiles/${testN}.out
ls -l $refFile
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs=${SST_REFERENCE_ELEMENTS}/GNA/tests/${testN}.py
ls -l $sutArgs

 echo  ${SST_REFERENCE_ELEMENTS}/GNA/tests
ls -l ${SST_REFERENCE_ELEMENTS}/GNA/tests
    $sut $sutArgs > $outFile 2>$errFile

   if [ -s $errFile ] ; then
      cat $errFile
      fail " Non-empty Error File, $testN  sst_GNA" 
   fi

   wc $outFile

   diff $outFile $refFile
   if [ $? -ne 0 ] ; then
       fail " Out Put does not match reference"
   fi

   echo "       Pass  Exact match"
   echo ' '

}

test_Sanity_check() {
echo "this id Duumy test "
}

test_1() {
echo  call first
template_sst_GNA  1
}


test_2() {
echo call second
template_sst_GNA  2
}
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.

(. ${SHUNIT2_SRC}/shunit2)

