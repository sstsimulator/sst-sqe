# !/bin/bash
# testSuite_patterns.sh

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
L_SUITENAME="SST_patterns_suite" # Name of this test suite; will be used to
                                # identify this suite in XML file.  (no spaces)

L_TESTFILE=()  # Empty list, used to hold test file names

if [ -e $SST_ROOT/sst/elements/patterns/.ignore ] ; then
    echo " Patterns is not supported due to .ignore file "
    preFail  " Patterns is not supported due to .ignore file "
fi

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===========================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_patterns_allreduce_deep_4096
# Purpose:
#     Exercise the patterns allreduce deep_4096case
# Inputs:
#     None
# Outputs:
#     test_patterns_allreduce_deep_4096.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_patterns_allreduce_deep_4096() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    startSeconds=`date +%s`
    testDataFileBase="test_patterns_allreduce_deep_4096"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_TEST_INPUTS}/testSdlFiles/test_patterns_allreduce_deep_4096.xml"
    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        (${sut} ${sutArgs} > $outFile)
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
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             RemoveComponentWarning
             return
        fi

        RemoveComponentWarning 
        diff -b $referenceFile $outFile
        if [ $? != 0 ]
        then  
             fail " Reference does not Match Output"
        fi

###        sed -i'.4sed' -e'/ .nan /d' $outFile
        wc $referenceFile $outFile

        
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi

    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "patterns_allreduce_deep_4096: Wall Clock Time  $elapsedSeconds seconds"
    echo " "
         
}

#-------------------------------------------------------------------------------
# Test:
#     test_patterns_ping_M_XE
# Purpose:
#     Exercise the pattern generator and test pattern ping with M_XE Machine
# Inputs:
#     None
# Outputs:
#     test_patterns_ping_M_XE.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_patterns_ping_M_XE() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    startSeconds=`date +%s`
    testDataFileBase="test_patterns_ping_M_XE"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Generate an SDL file for SST to load for testing
    sdlGeneratorArgsDataPath="sst/elements/patterns/config_files"
    sdlGenerator="${SST_TEST_INSTALL_BIN}/genPatterns"
    sdlFile="${SST_TEST_SDL_FILES}/${testDataFileBase}.xml"
    sdlGeneratorArgs="-p ${sdlGeneratorArgsDataPath}/ping.in -m ${sdlGeneratorArgsDataPath}/M_XE.in -o ${sdlFile}"
    (${sdlGenerator} ${sdlGeneratorArgs})
    
    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${sdlFile}"
    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        (${sut} ${sutArgs} > $outFile)
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
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             RemoveComponentWarning
             return
        fi
        RemoveComponentWarning
        diff -b $referenceFile $outFile > _raw_diff
        if [ $? != 0 ]
        then  
           wc _raw_diff
           compare_sorted $referenceFile $outFile
           if [ $? == 0 ] ; then
              echo " Sorted match with Reference File"
              rm _raw_diff
              return
           else
              fail " Reference does not Match Output"
           fi
        else
           echo "Passed with exact match"
        fi

###        sed -i'.4sed' -e'/ .nan /d' $outFile
        wc $referenceFile $outFile

        
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi

    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "patterns_ping_M_XE: Wall Clock Time  $elapsedSeconds seconds"
    echo " "
         
}

#-------------------------------------------------------------------------------
# Test:
#     test_patterns_alltoall_M_Shamrock
# Purpose:
#     Exercise the pattern generator and test pattern alltoall with M_Shamrock Machine
# Inputs:
#     None
# Outputs:
#     test_patterns_alltoall_M_Shamrock.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_patterns_alltoall_M_Shamrock() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    startSeconds=`date +%s`
    testDataFileBase="test_patterns_alltoall_M_Shamrock"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Generate an SDL file for SST to load for testing
    sdlGeneratorArgsDataPath="sst/elements/patterns/config_files"
    sdlGenerator="${SST_TEST_INSTALL_BIN}/genPatterns"
    sdlFile="${SST_TEST_SDL_FILES}/${testDataFileBase}.xml"
    sdlGeneratorArgs="-p ${sdlGeneratorArgsDataPath}/alltoall.in -m ${sdlGeneratorArgsDataPath}/M_Shamrock.in -o ${sdlFile}"
    (${sdlGenerator} ${sdlGeneratorArgs})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${sdlFile}"
    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        (${sut} ${sutArgs} > $outFile)
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
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             RemoveComponentWarning
             return
        fi
        RemoveComponentWarning

        diff -b $referenceFile $outFile
        if [ $? != 0 ]
        then  
             fail " Reference does not Match Output"
        fi

###        sed -i'.4sed' -e'/ .nan /d' $outFile
        wc $referenceFile $outFile

        
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi

    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "patterns_alltoall_M_Shamrock: Wall Clock Time  $elapsedSeconds seconds"
    echo " "
         
}

HOST=`uname -n | awk -F. '{print $1}'`
if [ $HOST == "sst-test" ] ; then
    export SST_TEST_ONE_TEST_TIMEOUT=250         # 4+ minutes 250 seconds
fi

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
