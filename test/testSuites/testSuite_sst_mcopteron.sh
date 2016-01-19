# !/bin/bash
# testSuite_sst_mcopteron.sh

# Description:

# A shell script that defines a shunit2 test suite. This will be
# invoked by the Bamboo script.

# Preconditions:

# 1) The "SUT", sst,  must have built successfully.
# 2) A test success reference file is available.

TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_sst_mcopteron" # Name of this test suite; will be used to
                                # identify this suite in XML file.  (no spaces)

L_TESTFILE=()  # Empty list, used to hold test file names

    if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] ; then
       if [ $SST_MULTI_THREAD_COUNT -gt 1 ] ; then
           echo '           SKIP '
           preFail "McOpteron tests do not work with threading (#76)" "skip"
       fi
    fi     

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_sst_mcopteron
# Purpose:
#     Exercise the sst_mcopteron
# Inputs:
#     None
# Outputs:
#     test_sst_mcopteron.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------

#
#       Download the tar file of traces, trace.txt,
#                 and untar it into the sst/elements tree
#
     echo " wget sst-simulator.org/downloads/sst-mcopteron-traces.tar.gz --no-check-certificate"
     wget sst-simulator.org/downloads/sst-mcopteron-traces.tar.gz --no-check-certificate
     if [ $? != 0 ] ; then
        echo "wget failed"
        preFail "wget failed"
     fi


     tar -xzf sst-mcopteron-traces.tar.gz

     rm sst-mcopteron-traces.tar.gz

test_sst_mcopteron_test1() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_sst_mcopteron_test1"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
    startSeconds=`date +%s`

 
    cd ${SST_ROOT}/sst/elements/sst_mcopteron

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst/elements/sst_mcopteron/test1.py"

    Tol=1            ##  Set tolerance at 0.1%
    rm -f ${outFile}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        ${sut} -n 2  ${sutArgs} > $outFile 
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
             wc $outFile
             echo "       THE outFile    first <= 15 lines "
             sed 15q $outFile
             echo '                  . . . '; echo " tail last <= 15 lines "
             tail -15 $outFile
             echo '             - - - - - '
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             RemoveComponentWarning
             return
        fi
        RemoveComponentWarning
        sed -i'.3sed' -e'/ nan /d' $outFile        ## This is still needed 6/10/13
        sed -i'.4sed' -e'/ -nan /d' $outFile       ## This is still needed 6/10/13
        diff ${outFile}.3sed $outFile
        if [ $? == 0 ] 
        then
            echo 'No nan was removed from outFile'
        fi

        grep Predicted.CPI -A 3 ${outFile}

        diff ${referenceFile} ${outFile} > /dev/null;
        if [ $? -ne 0 ]
        then
            lout=`cat ${outFile} | grep Predicted.CPI |awk  '{print $4}'`
echo "\$lout is $lout ############################################"
                #Example lout = 1.24983
            if [[ ${lout:+isSet} != isSet ]]
            then
                echo "Did NOT find \"Predicted.CPI\" in outFile"
                fail "Did NOT find \"Predicted.CPI\" in outFile"
                return
            fi
#           h=${lout: -5}
#               #Example  h = 24983
#           hd=$((1$h-100000))
#               #Example  hd = 24983    (This step was to deal with leading zeros)
#                    ##   if h had a leading zero then it was octal and 8 or 9 makes it invalid
#                                  ## as well as incorrect.
#           valo=$((${lout%.$h}*100000+$hd))
#               #Example  valo = 124983   (now it's an integer)
         #  use bc to do the multiply and awk to discard the fractional part, if any
            valo=`bc <<< $lout*100000 | awk -F. '{print $1}'`
            lref=`cat ${referenceFile} | grep Predicted.CPI |awk '{print $4}'`
            h=${lref: -5}
            hd=$((1$h-100000))
            valr=$((${lref%.$h}*100000+$hd))
            perc=`checkPerCent $valr $valo` 
            ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
            new=`wc ${outFile}       | awk '{print $1, $2}'`;
            val=`pc100 $perc` 
            perc=${perc#-}              ## remove minus, if it exists
            if [ $perc -le $Tol ] &&  [ "$ref" == "$new" ]
            then
                echo Predicted CPI $lout vs. Ref $lref,  $val  percent mcopteron test1
            else
                echo "wc (ref vs. new)   ($ref vs. $new) "
                echo Flunk Predicted CPI $lout vs. Ref $lref,  $val  percent mcopteron test1
                fail "Flunk Predicted CPI $lout vs. Ref $lref,  $val  percent mcopteron test1"
                wc  ${referenceFile}  ${outFile} 
            fi
        else
            echo oufFile is an exact match for Reference File
        fi

        diff -u ${referenceFile} ${outFile}

    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi

    cd ../../..

    endSeconds=`date +%s`

    echo " "
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "mcopteron test1: Wall Clock Time  $elapsedSeconds seconds"
}

##
##    Don't run this test on MacOS
##
if [ -n "${SST_TEST_HOST_OS_DISTRIB_MACOS}" ]
then
   sed -i'.xsed' -e s/^test_sst_mcopteron_test2/xxtest_sst_mcopteron_test2/ test/testSuites/testSuite_sst_mcopteron.sh
fi

xxtest_sst_mcopteron_test2() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_sst_mcopteron_test2"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    startSeconds=`date +%s`
 
    cd ${SST_ROOT}/sst/elements/sst_mcopteron

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst/elements/sst_mcopteron/test2.py"

    Tol=1            ##  Set tolerance at 0.1%
    rm -f ${outFile}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        ${sut} -n 2  ${sutArgs} > $outFile 
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
             wc $outFile
             echo "       THE outFile    first <= 15 lines "
             sed 15q $outFile
             echo '                  . . . '; echo " tail last <= 15 lines "
             tail -15 $outFile
             echo '             - - - - - '
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             return
        fi
        sed -i'.3sed' -e'/ nan /d' $outFile
        sed -i'.4sed' -e'/ -nan /d' $outFile

        grep Predicted.CPI -A 3 ${outFile}

        diff ${referenceFile} ${outFile} > /dev/null;
        if [ $? -ne 0 ]
        then
            lout=`cat ${outFile} | grep Predicted.CPI |awk  '{print $4}'`
            if [[ ${lout:+isSet} != isSet ]]
            then
                echo "Did NOT find \"Predicted.CPI\" in outFile"
                fail "Did NOT find \"Predicted.CPI\" in outFile"
                return
            fi
#           h=${lout: -5}
#           hd=$((1$h-100000))
#           valo=$((${lout%.$h}*100000+$hd))
         #  use bc to do the multiply and awk to discard the fractional part, if any
            valo=`bc <<< $lout*100000 | awk -F. '{print $1}'`
            lref=`cat ${referenceFile} | grep Predicted.CPI |awk '{print $4}'`
            h=${lref: -5}
            hd=$((1$h-100000))
            valr=$((${lref%.$h}*100000+$hd))
            perc=`checkPerCent $valr $valo` 
            ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
            new=`wc ${outFile}       | awk '{print $1, $2}'`;
            val=`pc100 $perc` 
            perc=${perc#-}              ## remove minus, if it exists
            if [ $perc -le $Tol ] &&  [ "$ref" == "$new" ]
            then
                echo Predicted CPI $lout vs. Ref $lref,  $val  percent mcopteron test2
            else
                echo Flunk Predicted CPI $lout vs. Ref $lref,  $val  percent mcopteron test2
                fail "Flunk Predicted CPI $lout vs. Ref $lref,  $val  percent mcopteron test2"
                wc ${outFile} ${referenceFile}
            fi 
        fi
        diff -u ${referenceFile} ${outFile}
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    cd ../../..

    endSeconds=`date +%s`

    echo " "
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "mcopteron test2: Wall Clock Time  $elapsedSeconds seconds"
}

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
