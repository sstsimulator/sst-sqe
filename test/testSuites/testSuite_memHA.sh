#!/bin/bash 
# testSuite_memHA.sh

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
L_SUITENAME="SST_memHA_suite" # Name of this test suite; will be used to
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
#      First parameter is the name of the test, must match test_memHA_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 500.)

memHA_Template() {
memHA_case=$1
Tol=$2    ##  curTick tolerance


    startSeconds=`date +%s`
    testDataFileBase="test_memHA_$memHA_case"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    newOut="${SST_TEST_OUTPUTS}/${testDataFileBase}.newout"
    newRef="${SST_TEST_OUTPUTS}/${testDataFileBase}.newref"
    testOutFiles="${SST_TEST_OUTPUTS}/${testDataFileBase}.testFile"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    sut="${SST_TEST_INSTALL_BIN}/sst"

    pyFileName=`echo test${memHA_case}.py | sed s/_/-/`
    sutArgs=${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/tests/$pyFileName
##        pyFileName=${memHA_case}.py
 ##       sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/memHA/tests/${pyFileName}"
        ls $sutArgs

        echo " Running from `pwd`"
        if [[ ${SST_MULTI_RANK_COUNT:+isSet} != isSet ]] ; then
           ${sut} ${sutArgs} > ${outFile}
           RetVal=$? 
        else
           mpirun -np ${SST_MULTI_RANK_COUNT} -output-filename $testOutFiles ${sut} ${sutArgs}
           RetVal=$? 
           cat ${testOutFiles}* > $outFile
        fi

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

        RemoveComponentWarning

        pushd ${SSTTESTTEMPFILES}

        diff -b $referenceFile $outFile > _raw_diff
        if [ $? == 0 ] ; then
             echo ReferenceFile is an exact match of outFile
             rm _raw_diff
        else
             wc $referenceFile $outFile
             wc _raw_diff
             rm diff_sorted
             compare_sorted $referenceFile $outFile
             if [ $? == 0 ] ; then
                 echo " Sorted match with Reference File is EXACT"
                 rm _raw_diff
             else
##    echo "Preliminary ---------------"
#################### This is much too profuse (some times 30k lines)
## cat ${SSTTESTTEMPFILES}/diff_sorted
##    echo " ----------------- "
                 ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
                 new=`wc ${outFile}       | awk '{print $1, $2}'`;
                 if [ "$ref" == "$new" ] ; then
                     echo "outFile word/line count matches Reference"
                 else
                     echo "$memHA_case test Fails"
                     echo "   tail of $outFile  ---- "
                     tail $outFile
                     fail "outFile word/line count does NOT match Reference"
                     diff ${referenceFile} ${outFile} 
                 fi
             fi
        fi
        popd

##  Follows some bailing wire to allow serialization branch to work
##          with same reference files
##     sed s/' (.*)'// $referenceFile > $newRef
##     ref=`wc ${newRef} | awk '{print $1, $2}'`; 
##     ##        ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
##     sed s/' (.*)'// $outFile > $newOut
##     new=`wc ${newOut} | awk '{print $1, $2}'`; 
##     ##          new=`wc ${outFile}       | awk '{print $1, $2}'`;
##        wc $newOut       
##               if [ "$ref" == "$new" ];
##               then
##                   echo "outFile word/line count matches Reference"
##               else
##                   echo "$memHA_case test Fails"
##                   echo "   tail of $outFile  ---- "
##                   tail $outFile
##                   fail "outFile word/line count does NOT match Reference"
##                   diff ${referenceFile} ${outFile} 
##               fi
##        else
##                echo ReferenceFile is an exact match of outFile
##        fi

        endSeconds=`date +%s`
        echo " "
        elapsedSeconds=$(($endSeconds -$startSeconds))
        echo "${memHA_case}: Wall Clock Time  $elapsedSeconds seconds"

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
#     test_memHA
# Purpose:
#     Exercise the memHA code in SST
# Inputs:
#     None
# Outputs:
#     test_memHA_xxx.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     For shunit2, the output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
# Exception for memHA tests:
#     A fuzzy compare has been inserted here.   The only thing that varies is
#     the value of the total Ticks simulated.  With binaries shared from SVN, 
#     there should be no need for fuzziness.  When the static binary is build
#     using compiler and libraries on the host, the exact number of Ticks in the 
#     program may vary from that reported in the reference file checked into SVN.
# Does not use subroutine because it invokes the build of all test binaries.
## -- test_gupsgen() {
## -- test_gupsgen_mmu() {
## -- test_stencil3dbench() {
## -- test_stencil3dbench_mmu() {
## -- test_streambench() {
## -- test_streambench_mmu() {
## -- stats-snb-ariel-dram.csv
#-------------------------------------------------------------------------------

        ln -sf ${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/tests/DDR3_micron_32M_8B_x4_sg125.ini .
        ln -sf ${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/tests/system.ini .

test_memHA_BackendChaining () {
    memHA_Template BackendChaining
}

test_memHA_BackendDelayBuffer  () {
    memHA_Template BackendDelayBuffer
}



test_memHA_BackendPagedMulti () {
    memHA_Template BackendPagedMulti
}


test_memHA_BackendReorderRow () {
    memHA_Template BackendReorderRow
}


test_memHA_BackendReorderSimple () {
    memHA_Template BackendReorderSimple
}


test_memHA_BackendSimpleDRAM_1 () {
    memHA_Template BackendSimpleDRAM_1
}


test_memHA_BackendSimpleDRAM_2 () {
    memHA_Template BackendSimpleDRAM_2
}


test_memHA_BackendVaultSim () {
    memHA_Template BackendVaultSim
}


test_memHA_DistributedCaches () {
    memHA_Template DistributedCaches
}


test_memHA_Flushes_2 () {
    memHA_Template Flushes_2
}


test_memHA_Flushes () {
    memHA_Template Flushes
}


test_memHA_HashXor () {
    memHA_Template HashXor
}


test_memHA_Incoherent () {
    memHA_Template Incoherent
}


test_memHA_Noninclusive_1 () {
    memHA_Template Noninclusive_1
}


test_memHA_Noninclusive_2 () {
    memHA_Template Noninclusive_2
}


test_memHA_PrefetchParams () {
    memHA_Template PrefetchParams
}


test_memHA_ThroughputThrottling () {
    memHA_Template ThroughputThrottling
}


export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


export SST_TEST_ONE_TEST_TIMEOUT=200 
 
# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
#         Located here this timeout will override the multithread value

(. ${SHUNIT2_SRC}/shunit2)

