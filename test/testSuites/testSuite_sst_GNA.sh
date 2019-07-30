#! /bin/bash
# testSuite_sst_GNA.sh

# Description:

# This Suite is minimal test of GNA element

#=============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_sst_GNA" # Name of this test suite;


L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================

test_sst_GNA() {
   testDataFileBase="test_sst_GNA"
   outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
   errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
   refFile=${SST_REFERENCE_ELEMENTS}/GNA/tests/test.ref.out

    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs=${SST_REFERENCE_ELEMENTS}/GNA/tests/test.py
   
    $sut $sutArgs > $outFile 2>$errFile

   if [ -s $errFile ] ; then
      cat $errFile
      fail " Non-empty Error File  sst_GNA" 
   fi

   wc $outFile

   diff $outFile $refFile
   if [ $? -ne 0 ] ; then
       fail " Out Put does no match reference"
   fi

   echo ' '

}


export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
#         Located here this timeout will override the multithread value

(. ${SHUNIT2_SRC}/shunit2)


