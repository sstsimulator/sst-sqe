#!/bin/bash 
# testSuite_Samba.sh

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
L_SUITENAME="SST_Samba_suite" # Name of this test suite; will be used to
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
#      First parameter is the name of the test, must match test_Samba_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 500.)

Samba_Template() {
Samba_case=$1
Tol=$2    ##  curTick tolerance


    startSeconds=`date +%s`
    testDataFileBase="test_Samba_$Samba_case"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    newOut="${SST_TEST_OUTPUTS}/${testDataFileBase}.newout"
    newRef="${SST_TEST_OUTPUTS}/${testDataFileBase}.newref"
    testOutFiles="${SST_TEST_OUTPUTS}/${testDataFileBase}.testFile"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    sut="${SST_TEST_INSTALL_BIN}/sst"

        pyFileName=${Samba_case}.py
        sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/Samba/tests/${pyFileName}"
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
             tail -20 $outfile
             echo "    --------------------"
             return
        fi
        wc ${outFile} ${referenceFile} | awk -F/ '{print $1, $(NF-1) "/" $NF}'

        RemoveComponentWarning

        diff ${referenceFile} ${outFile} > /dev/null;
        if [ $? -ne 0 ]
        then
##  Follows some bailing wire to allow serialization branch to work
##          with same reference files
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
                   echo "$Samba_case test Fails"
                   echo "   tail of $outFile  ---- "
                   tail $outFile
                   fail "outFile word/line count does NOT matches Reference"
                   diff ${referenceFile} ${outFile} 
               fi
        else
                echo ReferenceFile is an exact match of outFile
        fi

        endSeconds=`date +%s`
        echo " "
        elapsedSeconds=$(($endSeconds -$startSeconds))
        echo "${Samba_case}: Wall Clock Time  $elapsedSeconds seconds"
         

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
#     test_Samba
# Purpose:
#     Exercise the Samba code in SST
# Inputs:
#     None
# Outputs:
#     test_Samba_xxx.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     For shunit2, the output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
# Exception for Samba tests:
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
test_Samba_gupsgen() {
Samba_Template gupsgen 500

}

test_Samba_gupsgen_mmu() {

   if [[ ${SST_MULTI_CORE:+isSet} == isSet ]] ; then
       echo " November 15th, this test is not happpy with MULTI      OMIT"    
       skip_this_test
       return
   fi

Samba_Template gupsgen_mmu 500

}

test_Samba_stencil3dbench() {
Samba_Template stencil3dbench 500

}

test_Samba_stencil3dbench_mmu() {
Samba_Template stencil3dbench_mmu 500

}

test_Samba_streambench() {
Samba_Template streambench 500

}

test_Samba_streambench_mmu() {
Samba_Template streambench_mmu 500

}


export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


export SST_TEST_ONE_TEST_TIMEOUT=200 
 
# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
#         Located here this timeout will override the multithread value

(. ${SHUNIT2_SRC}/shunit2)

