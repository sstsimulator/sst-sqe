#! /bin/bash
# testSuite_sst_info_test.sh

# Description:

# This Suite initial will just verify the sst.info finds and reports some elements

#=============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_sst_into_suite" # Name of this test suite;


L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================

sst_info_Template() {
   elname_case=$1
   testDataFileBase="test_info_$elname_case"
   outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
   errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
   
   sst-info $elname_case > $outFile 2>$errFile
   
   if [ -s $errFile ] ; then
      cat $errFile
      fail " Non-empty Error File  $elname_case "
   fi

   wc $outFile

   echo ' '
   grep 'ELEMENT ' $outFile

}


test_merlin_sst_info() {

sst_info_Template merlin

}

test_memH_sst_info() {

sst_info_Template memHierarchy

}

test_simpleExample_sst_info() {

sst_info_Template simpleElementExample

}

test_external_sst_info() {

sst_info_Template simpleExternalElement

}

xxtest_fail_sst_info() {

sst_info_Template fail

}

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
#         Located here this timeout will override the multithread value

(. ${SHUNIT2_SRC}/shunit2)


