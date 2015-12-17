# !/bin/bash
# testSuite_sst_mcniagara.sh

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
L_SUITENAME="SST_sst_mcniagara" # Name of this test suite; will be used to
                                # identify this suite in XML file.  (no spaces)

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_sst_mcniagara
# Purpose:
#     Exercise the sst_mcniagara
# Inputs:
#     None
# Outputs:
#     test_sst_mcniagara.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_sst_mcniagara_test1() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_sst_mcniagara_test1"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

 
    cd ${SST_ROOT}/sst/elements/sst_mcniagara

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst/elements/sst_mcniagara/test1.py"
    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        ${sut} ${sutArgs} > $outFile  
        RetVal=$? 
        TIME_FLAG=/tmp/TimeFlag_$$_${__timerChild} 
        if [ -e $TIME_FLAG ] ; then 
             echo "Suite: Time Limit detected at `cat $TIME_FLAG` seconds, RT=$RetVal" 
             fail " Time Limit detected at `cat $TIME_FLAG` seconds, RT=$RetVal" 
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
             fail "WARNING: sst did not finish normally"
             return
        fi

        wc $referenceFile $outFile
        echo ' '
        cksum $outFile $referenceFile

        diff ${outFile} ${referenceFile} > /dev/null;
        if [ $? -ne 0 ]
        then
               ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
               new=`wc ${outFile}       | awk '{print $1, $2}'`;
               if [ "$ref" == "$new" ];
               then
                   echo "outFile word/line count matches Reference"
               else
                   echo "outFile word/line count DOES NOT matches Reference"
                   fail "outFile word/line count DOES NOT matches Reference"
               fi
        else
                echo outFile is an exact match of ReferenceFile
        fi

        diff $referenceFile $outFile
        
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    cd ../../..
}

test_sst_mcniagara_test2() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_sst_mcniagara_test2"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
 
    cd ${SST_ROOT}/sst/elements/sst_mcniagara

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst/elements/sst_mcniagara/test2.py"
    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        ${sut} ${sutArgs} > $outFile  
        RetVal=$? 
        TIME_FLAG=/tmp/TimeFlag_$$_${__timerChild} 
        if [ -e $TIME_FLAG ] ; then 
             echo "Suite: Time Limit detected at `cat $TIME_FLAG` seconds, RT=$RetVal" 
             fail " Time Limit detected at `cat $TIME_FLAG` seconds, RT=$RetVal" 
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
             fail "WARNING: sst did not finish normally"
             return
        fi

        wc $referenceFile $outFile
        echo ' '
        cksum  $outFile $referenceFile

        diff ${outFile} ${referenceFile} > /dev/null;
        if [ $? -ne 0 ]
        then
               ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
               new=`wc ${outFile}       | awk '{print $1, $2}'`;
               if [ "$ref" == "$new" ];
               then
                   echo "outFile word/line count matches Reference"
               else
                   echo "outFile word/line count DOES NOT matches Reference"
                   fail "outFile word/line count DOES NOT matches Reference"
               fi
        else
                echo outFile is an exact match of ReferenceFile
        fi

        diff $referenceFile $outFile
        
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    cd ../../..
}

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
