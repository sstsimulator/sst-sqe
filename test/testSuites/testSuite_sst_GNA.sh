#!/bin/bash
# testSuite_sst_GNA.sh

# Description:

# This Suite is minimal test of GNA element

#=============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_sst_GNA" # Name of this test suite;


L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================

template_sst_GNA() {
   testN="test${1}"
   testDataFileBase="test_sst_GNA"
   outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}${testN}.out"
   errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}${testN}.err"
   refFile=${SST_REFERENCE_ELEMENTS}/GNA/tests/ref/${testN}.out

    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs=${SST_REFERENCE_ELEMENTS}/GNA/tests/$testN}.py
   
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

   echo ' '

}

test1( ) {
template_sst_GNA  1
}


test2( ) {
template_sst_GNA  2
}
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.

(. ${SHUNIT2_SRC}/shunit2)


