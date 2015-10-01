# !/bin/bash 
# testSuite_portals.sh

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
L_SUITENAME="SST_portals_suite" # Name of this test suite; will be used to
                                # identify this suite in XML file. This
                                # should be a single string, no spaces
                                # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

    if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] ; then
       if [ $SST_MULTI_THREAD_COUNT -gt 1 ] ; then
           echo '           SKIP '
           preFail " portals_sm does not work with threading" "skip"

       fi
    fi     

#-------------------------------------------------------------------------------
# Test:
#     test_portals_0001
# Purpose:
#     Exercise the sst executable
# Inputs:
#     None
# Outputs:
#     test_portals_0001.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_portals_0001() {

    # Define a common basename for test output and reference
    # files, and ".out" extension. XML postprocessing requires this.
    startSeconds=`date +%s`
    testDataFileBase="test_portals_0001"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    # This is the expected name and location of the reference file
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Generate an SDL file for SST to load for testing
    sdlGenerator="${SST_TEST_INSTALL_BIN}/portals4_sm_sdlgen"
    sdlFile="${SST_TEST_SDL_FILES}/${testDataFileBase}.sdl"
    sdlGeneratorArgs="-x 16 -y 16 -z 16 -r 16 --application allreduce.tree_triggered --noise_runs 0 --new_format --output ${sdlFile} --ranks 2"

    (${sdlGenerator} ${sdlGeneratorArgs})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    file $sut
    ls -l $sut
    size $sut
    sutArgs="${sdlFile}"

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT and capture its output
        (${sut} ${sutArgs} > ${outFile} 2>$errFile)
        if [ $? != 0 ]
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             cat $errFile
             ls -l ${sut}
             fail "WARNING: sst did not finish normally"
             RemoveComponentWarning
             return
        fi
        cat $errFile | grep -v 'Warning:.*undoc'
        echo "          ----------"
        RemoveComponentWarning

        notAlignedCt=`grep -c 'Warning:.*undoc' $errFile`
        if [ $notAlignedCt != 0 ] ; then
            echo ' ' ; echo "* * * *   $notAlignedCt \"undocumented\" messages from portals_0001 test   * * * *" ; echo ' '
        fi
#       grep -v Warn $errFile
#       if [ $? != 0 ] ; then
#            grep Warn $errFile | sort -u 
#       fi
    fi

    diff -b $referenceFile $outFile
    if [ $? != 0 ]
    then
        echo "Output did NOT match Reference"
        fail "Output did NOT match Reference"
    fi

    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "portals_0001: Wall Clock Time  $elapsedSeconds seconds"
    echo " "
         
}

#-------------------------------------------------------------------------------
# Test:
#     test_portals_0002
# Purpose:
#     Exercise the sst executable
# Inputs:
#     None
# Outputs:
#     test_portals_0002.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
NORUNtest_portals_0002() {

    # Define a common basename for test output and reference
    # files, and ".out" extension. XML postprocessing requires this.
    startSeconds=`date +%s`
    testDataFileBase="test_portals_0002"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    # This is the expected name and location of the reference file
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Generate an SDL file for SST to load for testing
    sdlGenerator="${SST_TEST_INSTALL_BIN}/portals4_sm_sdlgen"
    sdlFile="${SST_TEST_SDL_FILES}/${testDataFileBase}.sdl"
    sdlGeneratorArgs="-z 1 --application=bw.eager --new_format --output ${sdlFile}"

    (${sdlGenerator} ${sdlGeneratorArgs})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${sdlFile}"

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT and capture its output
# <DEBUG start>
        echo  "test start: "; date
        echo  "test sut: ${sut} "
        echo  "test sut: ${sutArgs}"
        echo  "test outFile: ${outFile}"
# <DEBUG end>
        (/usr/local/bin/mpirun ${sut} ${sutArgs} 2> ${outFile})
        if [ $? != 0 ]
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             ls -l ${sut}
             fail "WARNING: sst did not finish normally"
             RemoveComponentWarning
             return
        fi
        RemoveComponentWarning
# <DEBUG start>
#        echo -n "test end: "; date
# <DEBUG end>
    fi

    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "portals_0002: Wall Clock Time  $elapsedSeconds seconds"
    echo " "
         
}

#-------------------------------------------------------------------------------
# Test:
#     test_portals_0003
# Purpose:
#     Exercise the sst executable
# Inputs:
#     None
# Outputs:
#     test_portals_0003.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_portals_0003() {

    # Define a common basename for test output and reference
    # files, and ".out" extension. XML postprocessing requires this.
    startSeconds=`date +%s`
    testDataFileBase="test_portals_0003"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    # This is the expected name and location of the reference file
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Generate an SDL file for SST to load for testing
    sdlGenerator="${SST_TEST_INSTALL_BIN}/portals4_sm_sdlgen"
    sdlFile="${SST_TEST_SDL_FILES}/${testDataFileBase}.sdl"
    sdlGeneratorArgs="-x 4 -y 4 -z 16 -r 8 --application allreduce.tree_triggered --noise_runs 0 --new_format --output ${sdlFile} --ranks 2"

    (${sdlGenerator} ${sdlGeneratorArgs})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${sdlFile}"

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT and capture its output
        (${sut} ${sutArgs} > ${outFile} 2>$errFile)
        if [ $? != 0 ]
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             cat $errFile
             ls -l ${sut}
             fail "WARNING: sst did not finish normally" 
             RemoveComponentWarning
             return
        fi
        cat $errFile | grep -v 'Warning:.*undoc'
        echo "          ----------"

        notAlignedCt=`grep -c 'Warning:.*undoc' $errFile`
        if [ $notAlignedCt != 0 ] ; then
            echo ' ' ; echo "* * * *   $notAlignedCt \"undocumented\" messages from portals_0003 test   * * * *" ; echo ' '
        fi
wc $outFile
        RemoveComponentWarning
wc $outFile
    fi

    diff -b $referenceFile $outFile 
    if [ $? != 0 ]
    then
        echo "Output did NOT match Reference"
        fail "Output did NOT match Reference"
    fi

    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "portals_0003: Wall Clock Time  $elapsedSeconds seconds"
    echo " "
         

}

#-------------------------------------------------------------------------------
# Test:
#     test_portals_0004
# Purpose:
#     Exercise the sst executable
# Inputs:
#     None
# Outputs:
#     test_portals_0004.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_portals_0004() {

    # Define a common basename for test output and reference
    # files, and ".out" extension. XML postprocessing requires this.
    startSeconds=`date +%s`
    testDataFileBase="test_portals_0004"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    # This is the expected name and location of the reference file
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Generate an SDL file for SST to load for testing
    sdlGenerator="${SST_TEST_INSTALL_BIN}/portals4_sm_sdlgen"
    sdlFile="${SST_TEST_SDL_FILES}/${testDataFileBase}.sdl"
    sdlGeneratorArgs="-x 8 -y 2 -z 8 -r 8 --application allreduce.tree_triggered --noise_runs 0 --new_format --output ${sdlFile} --ranks 2"

    (${sdlGenerator} ${sdlGeneratorArgs})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${sdlFile}"

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT and capture its output
        (${sut} ${sutArgs} > ${outFile} 2>$errFile)
        if [ $? != 0 ]
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             cat $errFile
             ls -l ${sut}
             fail "WARNING: sst did not finish normally"
             return
        fi
        cat $errFile | grep -v 'Warning:.*undoc'
        echo "          ----------"

        notAlignedCt=`grep -c 'Warning:.*undoc' $errFile`
        if [ $notAlignedCt != 0 ] ; then
            echo ' ' ; echo "* * * *   $notAlignedCt \"undocumented\" messages from portals_0004 test   * * * *" ; echo ' '
        fi
wc $outFile
        RemoveComponentWarning
wc $outFile
    fi

    diff -b $referenceFile $outFile 
    if [ $? != 0 ]
    then
        echo "Output did NOT match Reference"
        fail "Output did NOT match Reference"
    fi

    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "portals_0004: Wall Clock Time  $elapsedSeconds seconds"
    echo " "
         

}

#-------------------------------------------------------------------------------
# Test:
#     test_portals4_sm
# Purpose:
#     Exercise the sst executable
# Inputs:
#     None
# Outputs:
#     test_portals4_sm.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_portals4_sm() {

    # Define a common basename for test output and reference
    # files, and ".out" extension. XML postprocessing requires this.
    startSeconds=`date +%s`
    testDataFileBase="test_portals4_sm"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    # This is the expected name and location of the reference file
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})



    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"

    #   There was a minor issue with defining the Arguments to SUT for shunit2
    #   The corresponding stand-alone statement is:
    #   >sst --generator portals4_sm.generator --gen-options "-x 16 -y 8 -z 8 --application allreduce.tree_triggered"
    #   The grouping by the quotation marks are important.

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT and capture its output
        (${sut} --generator portals4_sm.generator --gen-options $'-x 16 -y 8 -z 8 --application allreduce.tree_triggered' > ${outFile} 2>$errFile)
        if [ $? != 0 ]
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             cat $errFile
             fail "WARNING: sst did not finish normally"
             return
        fi
        cat $errFile | grep -v 'Warning:.*undoc'
        echo "          ----------"

        notAlignedCt=`grep -c 'Warning:.*undoc' $errFile`
        if [ $notAlignedCt != 0 ] ; then
            echo ' ' ; echo "* * * *   $notAlignedCt \"undocumented\" messages from portals4_sm test   * * * *" ; echo ' '
        fi
    fi
 echo RESULT

    diff -b $referenceFile $outFile
    if [ $? != 0 ]
    then
        echo "Output did NOT match Reference"
        fail "Output did NOT match Reference"
    fi

    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "portals4_sm: Wall Clock Time  $elapsedSeconds seconds"
    echo " "
         
}


export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)

