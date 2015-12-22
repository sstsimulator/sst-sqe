# !/bin/bash
# testSuite_simpleClockerComponent.sh

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
L_SUITENAME="SST_simpleClockerComponent_suite" # Name of this test suite; will be used to
                                               # identify this suite in XML file. This
                                               # should be a single string, no spaces
                                               # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
# Use the new shunit2 option only
#===============================================================================

        export SHUNIT_DISABLE_DIFFTOXML=1
        export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

##       A local Subroutine
##           to convert a number like  834.91 to 83491
##              There is NO CHECK that the input number has correct format!
##

intFrom2places() {
   whole=`echo $1 | awk -F. '{ print $1}'`
   frac=`echo $1 | awk -F. '{ print $2}'`
   dfrac=$((1$frac-100))     # This force it to be decimal even with a leading zero
   result=$(($whole*100+$dfrac))
   echo $result
}

intFromnplaces() {
# This is bailing wire to reduce to two place after the decimal point.
#    Am not going to bother to round

whole=`echo $1 | awk -F. '{print $1}'`
frac=`echo $1 | awk -F. '{print $2}'`
frac2=${frac:0:2}
result=${whole}${frac2}
echo $result
#echo $whole, $frac, $frac2, $result
}

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================


#-------------------------------------------------------------------------------
# Test:
#     test_simpleClockerComponent
# Purpose:
#     Exercise the simpleClockerComponent of the simpleElementExample
# Inputs:
#     None
# Outputs:
#     test_simpleClockerComponent.out file
# Expected Results
#     Reference File is not a Gold File!  Host dependent line contains expected Total Time 
#     from sst --verbose option.   Will be a Fuzzy compare.
#      NOTE:  Does not impose word/line-count match as elsewhere!
# Caveats:
#
#-------------------------------------------------------------------------------

#------------------------------------
#
#   template for multi attempt timing test
#
#------------------------------------
Clocker_template() {
    rm -f ${outFile}
    # Run SUT
    (${sut} --verbose  ${sutArgs} > $outFile)
        RetVal=$? 
        TIME_FLAG=/tmp/TimeFlag_$$_${__timerChild} 
echo "                                             TIME_FLAG is $TIME_FLAG" 
ls $TIME_FLAG 
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
         sed 10q $outFile
         fail "sst did not finish normally, RetVal=$RetVal"
         return 1
    else
        echo "                Scale factor is $FAC"    
        Ttime=`grep 'Total time' $outFile | awk '{print $5}'`
        Ttime="$(echo "scale=4; $Ttime/$FAC" |bc)"
##        intTtime=`intFrom2places $Ttime`
        intTtime=`intFromnplaces $Ttime`
        perc=`checkPerCent $intRtime $intTtime`
        val=`pc100 $perc`
        if [ $perc -gt $Told ] && [ $perc -lt $Tolu ]
        then
            echo Scaled Time $Ttime seconds vs. Ref $Rtime seconds,  $val percent simple_Clocker
        else
            echo Flunk Scaled Time $Ttime vs. Ref $Rtime seconds,  $val  percent simple_Clocker
            FAIL_COUNT=$(($FAIL_COUNT+1))
##        fail  "TOTAL Time changed too much"
        fi
    fi
    return 0
}

test_simpleClockerComponent() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_simpleClockerComponent"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs_orig="${SST_ROOT}/sst/elements/simpleElementExample/tests/test_simpleClockerComponent.py"
    sutArgs=${SST_TEST_ROOT}/testInputFiles/testInputsTemporary/test_simpleClockerComponent.py

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        echo "Run the new simple Clocker test"
    else
        # Problem encountered: can't find or can't run SUT.
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
        return
    fi

#  Do the once only preliminaries

    TOKEN=$SST_TEST_HOST_OS_DISTRIB
    if [ $TOKEN == "MacOS" ] ; then
        TOKEN=${SST_TEST_HOST_OS_DISTRIB}_${SST_TEST_HOST_OS_DISTRIB_VERSION}
    elif [ $TOKEN == "CentOS" ] ; then
        TOKEN=${TOKEN}_`uname -n | awk -F. '{print $1}'`
    fi
    echo "Using Host dependent Reference info for $TOKEN"
    Tolu=2000            ##  Set tolerance up at 20%
    Told=-3500            ##  Set tolerance down at -35%
    if [ $TOKEN == "Ubuntu" ] ; then
        echo ' '; echo "reseting tolerance VERY large for Ubuntu" ; echo ' '
        Tolu=5000            ##  Set tolerance up at 50%
        Told=-5000            ##  Set tolerance down at -50%
    fi
    RefLine=`grep $TOKEN $referenceFile`
    if [ $? != 0 ] ; then
         echo " ***** No Reference Information for $TOKEN found"
         echo "    =========== Reference File ============"
         cat $referenceFile
         fail "No Reference Information for $TOKEN found"
         return
    fi
    Rtime=`echo $RefLine | awk '{print $2}'`
    intRtime=`intFrom2places $Rtime`


RUNNING_INDEX=0
LAST_INDEX=5
FAIL_COUNT=0
FAC=1

    while [ $RUNNING_INDEX -lt $LAST_INDEX ]
    do
        RUNNING_INDEX=$(($RUNNING_INDEX+1))
        sed  "/clockcount/s/1/$FAC/" $sutArgs_orig > $sutArgs
        Clocker_template
        rc=$?
        if [ $rc != 0 ] ; then
            return $rc
        fi 
        FAC=$(($FAC+$FAC))    
    done
    if [ $FAIL_COUNT == $LAST_INDEX ] ; then
        echo " Clock failed $FAIL_COUNT attempts"
        fail " Clock failed $FAIL_COUNT attempts"
    else
        echo "PASS!   $FAIL_COUNT attempts of $LAST_INDEX  were out of tolerence"
    fi
}

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
