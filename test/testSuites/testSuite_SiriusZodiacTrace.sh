#!/bin/bash 
# testSuite_Sirius.sh

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


#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_Sirius_suite" # Name of this test suite; will be used to
                                 # identify this suite in XML file. This
                                 # should be a single string, no spaces
                                 # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
#     Subroutine to run many of the Sirius tests without reproducing the script.
#      First parameter is the name of the test, must match test_Sirius_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 500.)
#      Special case:  if second parameter is "lineWordCt",
#                          accept a line/word count match.
#     These are all reduce tests only initially.

#       Download the tar file of traces   and untar it into the sst/elements tree
#
     echo "wget https://github.com/sstsimulator/sst-downloads/releases/download/TestFiles/sst-Sirius-Allreduce-traces.tar.gz --no-check-certificate"
     wget "https://github.com/sstsimulator/sst-downloads/releases/download/TestFiles/sst-Sirius-Allreduce-traces.tar.gz"
     if [ $? != 0 ] ; then
        echo "wget failed"
        preFail "wget failed"
     fi

     tar -xzf sst-Sirius-Allreduce-traces.tar.gz

     rm sst-Sirius-Allreduce-traces.tar.gz

##   Right now this feels to me like the "allreduce template", rather than "Sirius".
allReduce_template() {
Sirius_case=$1
Tol=$2    ##  curTick tolerance,  or  "lineWordCt" 

    startSeconds=`date +%s`
    testDataFileBase="test_Sirius_allred_$Sirius_case"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    tmpFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.tmp"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    pushd $SST_ROOT/sst/elements/zodiac/test/allreduce

    sut="${SST_TEST_INSTALL_BIN}/sst"

    sutArgs="--model-options \"--shape=${Sirius_case}\" ${SST_ROOT}/sst/elements/zodiac/test/allreduce/allreduce.py" 

echo Need sutArgs
echo $sutArgs
echo "------------------------------"

    (${sut} ${sutArgs} > ${tmpFile}) 2>${errFile}
        RetVal=$? 
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
         wc ${tmpFile} ${referenceFile}
         fail " WARNING: sst did not finish normally, RetVal=$RetVal" 
         grep -v Warning:..Param $errFile
         return
    fi

    if [ -s $errFile ] ; then
        ctundoc=`grep -c Warning:..Param $errFile`
        if [ $? == 0 ] ; then
            echo "*******************************************************"
            echo "      $ctundoc lines of Undocumented Parameters" 
            echo "*******************************************************"
        fi
        echo "       Error File:"
        grep -v Warning:..Param $errFile
        echo ' '
    fi
    grep -e Total.Allreduce.Count -e Total.Allreduce.Bytes $tmpFile | awk -F: '{$1="";$6=""; print }' | sort -n > $outFile
    wc ${outFile} ${referenceFile} $tmpFile
    if [ -s $outFile ] ; then
        diff ${referenceFile} ${outFile}
        if [ $? -ne 0 ] ; then
             echo "Request lines not matched in output"
             fail "Request lines not matched in output"
        else
             echo "    Output matches requested lines of Reference File "
        fi
    else
        echo "ERROR:  Output file is empty"
        fail "ERROR:  Output file is empty"
    fi

    popd
    grep Simulation $tmpFile

    endSeconds=`date +%s`
    echo " "
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "${Sirius_case}: Wall Clock Time  $elapsedSeconds seconds"
}


#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_Sirius
# Purpose:
#     Exercise the GESirius code in SST
#            Hello World
# Inputs:
#     None
# Outputs:
#     test_Sirius_Hw.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     For shunit2, the output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
# Exception for Sirius tests:
#     A fuzzy compare has been inserted here.   The only thing that varies is
#     the value of the total Ticks simulated.  With binaries shared from SVN, 
#     there should be no need for fuzziness.  When the static binary is build
#     using compiler and libraries on the host, the exact number of Ticks in the 
#     program may vary from that reported in the reference file checked into SVN.
# Does not use subroutine because it invokes the build of all test binaries.
#-------------------------------------------------------------------------------

#
#	Sirius Zodiac Traces 16
#
XXtest_Sirius_Zodiac_16() {
allReduce_template 4x4 lineWordCt

}


#
#	Sirius Zodiac Traces 27
#
test_Sirius_Zodiac_27() {

   if [[ ${SST_MULTI_CORE:+isSet} == isSet ]] ; then
       echo " Uses an event that does not implement serialization    OMIT"    
       skip_this_test
       return
   fi

allReduce_template 27 lineWordCt

}


#
#	Sirius Zodiac Traces 64
#
test_Sirius_Zodiac_64() {
allReduce_template 8x8 lineWordCt

}


#
#	Sirius Zodiac Traces 16
#
test_Sirius_Zodiac_16() {
allReduce_template 4x4 lineWordCt

}


#
#	Sirius Zodiac Traces 128
#
test_Sirius_Zodiac_128() {
allReduce_template 8x8x2 lineWordCt

}


export SST_TEST_ONE_TEST_TIMEOUT=300         # 5 minutes 300 seconds

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)

