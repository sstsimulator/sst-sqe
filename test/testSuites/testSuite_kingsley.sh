#!/bin/bash 
# testSuite_kingsley.sh

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
L_SUITENAME="SST_kingsley_suite" # Name of this test suite; will be used to
                                 # identify this suite in SDL file. This
                                 # should be a single string, no spaces
                                 # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
#                       TEMPLATE
#     Subroutine to run many similiar tests without reproducing the script.
#      First parameter is the name of the test, must match test_kingsley_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 500.)

kingsley_Template() {
kingsley_case=$1
Tol=$2    ##  curTick tolerance


    startSeconds=`date +%s`
    testDataFileBase="test_kingsley_$kingsley_case"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    newOut="${SST_TEST_OUTPUTS}/${testDataFileBase}.newout"
    newRef="${SST_TEST_OUTPUTS}/${testDataFileBase}.newref"
    testOutFiles="${SST_TEST_OUTPUTS}/${testDataFileBase}.testFile"
    referenceFile="${SST_REFERENCE_ELEMENTS}/kingsley/tests/refFiles/test_kingsley_${kingsley_case}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    sut="${SST_TEST_INSTALL_BIN}/sst"

        pyFileName=${kingsley_case}.py
        sutArgs="${SST_REFERENCE_ELEMENTS}/kingsley/tests/$pyFileName"
        ls $sutArgs
        if [ $? != 0 ]
        then
          echo ' '
          ls -d ${SST_TEST_SDL_FILES}/kingsleySdls
          ls ${SST_TEST_SDL_FILES}/kingsleySdls
          echo ' '
        fi

        echo " Running from `pwd`"
        if [[ ${SST_MULTI_RANK_COUNT:+isSet} == isSet ]] && [ ${SST_MULTI_RANK_COUNT} -gt 1 ] ; then
           mpirun -np ${SST_MULTI_RANK_COUNT} $NUMA_PARAM -output-filename $testOutFiles ${sut} ${sutArgs}
           RetVal=$? 
           # Call routine to cat the output together
           #cat ${testOutFiles}* > $outFile
           cat_multirank_output
        else
           ${sut} ${sutArgs} > ${outFile}
           RetVal=$? 
        fi

        TIME_FLAG=$SSTTESTTEMPFILES/TimeFlag_$$_${__timerChild} 
        if [ -e $TIME_FLAG ] ; then 
             echo " Time Limit detected at `cat $TIME_FLAG` seconds" 
             fail " Time Limit detected at `cat $TIME_FLAG` seconds" 
             rm $TIME_FLAG 
             return 
        fi 
        if [ $RetVal != 0 ] ; then
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


        compare_sorted ${referenceFile} ${outFile} 
        if [ $? -ne 0 ] ; then
##  Follows some bailing wire to allow serialization branch to work
##          with same reference files
     sed s/' (.*)'// $referenceFile > $newRef
     ref=`wc ${newRef} | awk '{print $1, $2}'`; 
     ##        ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
     sed s/' (.*)'// $outFile > $newOut
     new=`wc ${newOut} | awk '{print $1, $2}'`; 
     ##          new=`wc ${outFile}       | awk '{print $1, $2}'`;
     wc $newOut       
               fail " Output does not match exactly (Required)"
               if [ "$ref" == "$new" ]; then
                   echo "outFile word/line count matches Reference"
               else
                   echo "$kingsley_case test Fails"
                   echo "   tail of $outFile  ---- "
                   tail $outFile
                   # fail "outFile word/line count does NOT matches Reference"
                   echo "outFile word/line count does NOT matches Reference"
                   diff ${referenceFile} ${outFile} 
               fi
        else
                echo ReferenceFile is an exact match of outFile
        fi

        endSeconds=`date +%s`
        echo " "
        elapsedSeconds=$(($endSeconds -$startSeconds))
        echo "${kingsley_case}: Wall Clock Time  $elapsedSeconds seconds"
         

}


# Build Test app
##    The following code already explictly assume we are at trunk
  
   

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_kingsley
# Purpose:
#     Exercise the kingsley code in SST
# Inputs:
#     None
# Outputs:
#     test_kingsley_xxx.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     For shunit2, the output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
# Does not use subroutine because it invokes the build of all test binaries.
#-------------------------------------------------------------------------------
test_kingsly_noc_mesh_32() {          
kingsley_Template noc_mesh_32_test 500

}


export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

export SST_TEST_ONE_TEST_TIMEOUT=200 
 
# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
#         Located here this timeout will override the multithread value
(. ${SHUNIT2_SRC}/shunit2)

