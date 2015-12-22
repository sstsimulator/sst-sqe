# !/bin/bash 
# testSuite_scheduler.sh
# currently is not working but is close

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
L_SUITENAME="SST_scheduler_suite" # Name of this test suite; will be used to
                                # identify this suite in XML file. This
                                # should be a single string, no spaces
                                # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

    if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] ; then
       if [ $SST_MULTI_THREAD_COUNT -gt 1 ] ; then
           echo '           SKIP '
           preFail " Scheduler tests do not work with threading" "skip"
       fi
    fi     

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_scheduler_0001
# Purpose:
#     Exercise the sst executable
# Inputs:
#     ${SST_TEST_INPUTS}/test_scheduler_0001.sim
# Outputs:
#     test_scheduler_0001.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_scheduler_0001() {

    # Define a common basename for test output and reference
    # files, and ".out" extension. XML postprocessing requires this.
    testDataFileBase="test_scheduler_0001"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    # This is the expected name and location of the reference file
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Generate an SDL file for SST to load for testing
    sdlGenerator="${SST_ROOT}/sst/elements/scheduler/simulations/makeSDL.pl"
    sdlFile="${SST_TEST_SDL_FILES}/${testDataFileBase}.sdl"
    sdlGeneratorArgs="128 ${SST_TEST_INPUTS}/test_scheduler_0001.sim easy mesh[16,8] sortedfreelist none"

    (${sdlGenerator} ${sdlGeneratorArgs} > ${sdlFile})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="--sdl-file=${sdlFile}"

    cd ${SST_TEST_OUTPUTS}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT and capture its output
        (${sut} ${sutArgs} > ${outFile})
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
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             return
        fi
         tail -n +2 ${SST_TEST_OUTPUTS}/test_scheduler_0001.sim.alloc >> ${outFile};
         tail -n +2 ${SST_TEST_OUTPUTS}/test_scheduler_0001.sim.time >> ${outFile};

         diff -b ${outFile} ${referenceFile} > /dev/null
         if [ $? -ne 0 ]
         then
             wc ${outFile} ${referenceFile};
             echo word count of diff is:
             diff ${outFile} ${referenceFile} | wc
             fail "Output does NOT match Reference"
         fi
    fi
}

#-------------------------------------------------------------------------------
# Test:
#     test_scheduler_0002
# Purpose:
#     Test yumyum-specific functionality in the scheduler element
# Inputs:
#     None
# Outputs:
#     test_scheduler_0002.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------

test_scheduler_0002() {
    # Define a common basename for test output and reference
    # files, and ".out" extension. XML postprocessing requires this.
    testDataFileBase="test_scheduler_0002"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    jobLog="${SST_TEST_OUTPUTS}/${testDataFileBase}_joblog.csv"
    faultLog="${SST_TEST_OUTPUTS}/${testDataFileBase}_faultlog.csv"
    errorLog="${SST_TEST_OUTPUTS}/${testDataFileBase}_errorlog.csv"
    # This is the expected name and location of the reference file
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    joblogReferenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}_joblog.csv"
    faultlogReferenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}_faultlog.csv"
    errorlogReferenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}_errorlog.csv"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})


    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_TEST_SDL_FILES}/${testDataFileBase}.py"


    cd ${SST_TEST_OUTPUTS}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT and capture its output
        (${sut} ${sutArgs} > ${outFile})
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
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             return
        fi
         echo "===JOB LOG===" >> ${outFile};
         cat $jobLog >> ${outFile};
         echo "===FAULT LOG===" >> ${outFile};
         cat $faultLog >> ${outFile};
         echo "===ERROR LOG===" >> ${outFile};
         cat $errorLog >> ${outFile};

         diff -b ${outFile} ${referenceFile} > /dev/null
         if [ $? -ne 0 ]
         then
             wc ${outFile} ${referenceFile};
             echo word count of diff is:
             diff ${outFile} ${referenceFile} | wc
             fail "Output does NOT match Reference"
         fi
       
    fi

}

#-------------------------------------------------------------------------------
# Test:
#     test_scheduler_0003
# Purpose:
#     Test GLPK allocators for sst
# Inputs:
#     ${SST_TEST_INPUTS}/test_scheduler_0003.sim
# Outputs:
#     test_scheduler_0003.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_scheduler_0003() {

    # Define a common basename for test output and reference
    # files, and ".out" extension. XML postprocessing requires this.
    testDataFileBase="test_scheduler_0003"

    # This test requires that sst be built with GLPK
    grep "^#define.HAVE_GLPK.1" ${SST_ROOT}/config.log > /dev/null
    if [ $? == 1 ] ; then
        echo "     SST NOT configured with GLPK,  skipping $testDataFileBase"
        skip_this_test     # Skip function in shunit2
        echo ' '
        return
    fi

    # This test does not work with multithread (Sept. 21, 2015)
    if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] ; then
       if [ $SST_MULTI_THREAD_COUNT -gt 1 ] ; then
          echo '           SKIP '
          echo "    $testDataFileBase  configuration not valid for threading"
          skip_this_test     # Skip function in shunit2
          echo ' '
          return
       fi
    fi

    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    # This is the expected name and location of the reference file
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    configFile="${SST_TEST_SDL_FILES}/sdl-3.py"

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${configFile}"

    cd ${SST_TEST_OUTPUTS}
    ln -s ${SST_ROOT}/sst/elements/scheduler/simulations/DMatrix4_5_2 .
    ln -s ${SST_TEST_INPUTS}/test_scheduler_0003.sim .

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
echo ' ' ; echo " MY path is $PATH "
echo ''
        # Run SUT and capture its output
        (${sut} ${sutArgs} > /dev/null)
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
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             return
        fi
        echo "" > ${outFile}

         tail -n +2 ${SST_TEST_OUTPUTS}/test_scheduler_0003.sim.alloc >> ${outFile};
         tail -n +2 ${SST_TEST_OUTPUTS}/test_scheduler_0003.sim.time >> ${outFile};

         diff -b ${outFile} ${referenceFile} > /dev/null
         if [ $? -ne 0 ]
         then
             wc ${outFile} ${referenceFile};
             echo word count of diff is:
             diff ${outFile} ${referenceFile} | wc
             fail "Output does NOT match Reference"
         fi
    fi
}

#-------------------------------------------------------------------------------
# Test:
#     test_scheduler_0004
# Purpose:
#     Test coordinate-based task mapping
# Inputs:
#     None
# Outputs:
#     test_scheduler_0004.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_scheduler_0004() {

    # Define a common basename for test output and reference
    # files, and ".out" extension. XML postprocessing requires this.
    testDataFileBase="test_scheduler_0004"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    # This is the expected name and location of the reference file
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    configFile="${SST_TEST_SDL_FILES}/test_scheduler_0004.py"

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${configFile}"

    cd ${SST_TEST_OUTPUTS}
    ln -s ${SST_ROOT}/sst/elements/scheduler/simulations/sphere3.mtx .
    ln -s ${SST_ROOT}/sst/elements/scheduler/simulations/sphere3_coord.mtx .
    ln -s ${SST_ROOT}/sst/elements/scheduler/simulations/test_scheduler_Atlas.sim .

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT and capture its output
        (${sut} ${sutArgs} > /dev/null)
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
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             return
        fi
        echo "" > ${outFile}

         tail -n +2 ${SST_TEST_OUTPUTS}/test_scheduler_Atlas.sim.alloc >> ${outFile};
         tail -n +2 ${SST_TEST_OUTPUTS}/test_scheduler_Atlas.sim.time >> ${outFile};

         diff -b ${outFile} ${referenceFile} > /dev/null
         if [ $? -ne 0 ]
         then
             wc ${outFile} ${referenceFile};
             echo word count of diff is:
             diff ${outFile} ${referenceFile} | wc
             fail "Output does NOT match Reference"
         fi
    fi
}

#-------------------------------------------------------------------------------
# Test:
#     test_scheduler_0005
# Purpose:
#     Test METIS and simultaneous allocation & mapping
# Inputs:
#     None
# Outputs:
#     test_scheduler_0005.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_scheduler_0005() {


      
    # Define a common basename for test output and reference
    # files, and ".out" extension. XML postprocessing requires this.
    testDataFileBase="test_scheduler_0005"
    # This test requires that sst be built with METIS
    grep "^#define.HAVE_METIS.1" ${SST_ROOT}/config.log > /dev/null
    if [ $? == 1 ] ; then
        echo "     SST NOT configured with METIS,  skipping $testDataFileBase"
        skip_this_test     # Skip function in shunit2
        echo ' '
        return
    fi
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    # This is the expected name and location of the reference file
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    ####################
    #      Intel compiler requires unique Reference file
    $CXX --version > check-comp 2>&1
    if [ $? != 0 ] ; then
        echo "  Not a special case, no compiler specification found"
    else
        grep Intel check-comp > /dev/null
        if [ $? == 0 ] ; then
            echo " Intel compiler special case"
            referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}_Intel_comp.out"
        fi
    fi
    rm -f check-comp
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    configFile="${SST_TEST_SDL_FILES}/test_scheduler_0005.py"

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${configFile}"

    cd ${SST_TEST_OUTPUTS}
    #These are already linked in Test 4:
    #ln -s ${SST_ROOT}/sst/elements/scheduler/simulations/sphere3.mtx .
    #ln -s ${SST_ROOT}/sst/elements/scheduler/simulations/sphere3_coord.mtx .
    #ln -s ${SST_ROOT}/sst/elements/scheduler/simulations/test_scheduler_Atlas.sim .

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT and capture its output
        (${sut} ${sutArgs} > /dev/null)
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
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             return
        fi
        echo "" > ${outFile}

         tail -n +2 ${SST_TEST_OUTPUTS}/test_scheduler_Atlas.sim.alloc >> ${outFile};
         tail -n +2 ${SST_TEST_OUTPUTS}/test_scheduler_Atlas.sim.time >> ${outFile};

         diff -b ${outFile} ${referenceFile} > /dev/null
         if [ $? -ne 0 ]
         then
             wc ${outFile} ${referenceFile};
             echo word count of diff is:
             diff ${outFile} ${referenceFile} | wc
             diff ${outFile} ${referenceFile}    ###   TEMP ?
             fail "Output does NOT match Reference"
         fi
    fi
}


export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)

