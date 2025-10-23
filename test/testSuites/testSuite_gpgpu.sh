#!/bin/bash

TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

export PATH=$PATH:$SST_TEST_INSTALL_BIN

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_GPU" # Name of this test suite; will be used to
                                # identify this suite in XML file.  (no spaces)

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

    echo "INTEL_PIN_DIRECTORY = $INTEL_PIN_DIRECTORY"
    if [ ! -d "$INTEL_PIN_DIRECTORY" ] ; then
        echo "Ariel tests requires PIN DIRECTORY"
        echo "        NOT  FOUND"
        echo " Environment Variable INTEL_PIN_DIRECTORY must be defined"
        preFail "Ariel tests requires PIN DIRECTORY" "skip"
    fi

    mkdir $SSTTESTTEMPFILES/$$gpu_run
    cd $SSTTESTTEMPFILES/$$gpu_run

    echo " First call to countStreams follow: "
    countStreams

    OPWD=`pwd`
    export PKG_CONFIG_PATH=${SST_ROOT}/../../local/lib/pkgconfig

#     Subroutine to clean up shared memory ipc
#          This could be in subroutine library - for now only Ariel
removeFreeIPCs() {
    #   Find and kill orphanned running binaries
    ps -f > ${SSTTESTTEMPFILES}/_running_bin
    while read -u 3 uid pid ppid p4 p5 p6 p7 cmd
    do
##        echo "          DEBUG ONLY $uid $pid $ppid $cmd"
        if [ $uid == $USER ] && [ ${ppid} == 1 ] ; then
           if [[ $cmd == *stream/stream* ]] || [[ $cmd == *ompmybarrier* ]] ; then
               echo "Going to kill: $cmd"
               kill -9 $pid
           else
               echo " Omitting kill of $uid $ppid $cmd"
           fi
        fi
    done 3<${SSTTESTTEMPFILES}/_running_bin

    #  Find and remove no longer attached shared memory segments
    ipcs > ${SSTTESTTEMPFILES}/_ipc_list
    ##     echo "         DEBUG ONLY `wc ${SSTTESTTEMPFILES}/_ipc_list`"
    while read -u 3 key shmid own perm size n_att rest
    do
         if [[ $key == "" ]] || [[ $n_att == "" ]] ; then
             continue
         fi
    ##     echo "         DEBUG ONLY $key, $shmid, $own, $n_att"
       if [ $own == $USER ] && [ $n_att == 0 ] ; then
          echo " Removing an idle Shared Mem allocation"
          ipcrm -m $shmid
       fi
    done 3<${SSTTESTTEMPFILES}/_ipc_list
    rm ${SSTTESTTEMPFILES}/_ipc_list  ${SSTTESTTEMPFILES}/_running_bin
}

#===============================================================================
# Function to source the GPGPUSim environment to set up
# GPGPUSIM_ROOT, PATH, LD_LIBRARY_PATH, DYLD_LIBRARY_PATH
# OPENCL_REMOTE_GPU_HOST, GPGPUSIM_POWER_MODEL, PTXAS_CUDA_INSTALL_PATH
# CUDA_VERSION_NUMBER, GPGPUSIM_CONFIG, GPGPUSIM_SETUP_ENVIRONMENT_WAS_RUN
#===============================================================================
GPGPU_environment() {
    echo -e "LD_LIBRARY_PATH ${LD_LIBRARY_PATH}\n"
    echo ""
    module li
    echo ""
    echo ". ${SST_DEPS_INSTALL_GPGPUSIM}/setup_environment sst"
    . ${SST_DEPS_INSTALL_GPGPUSIM}/setup_environment sst

    echo -e "GPGPUSIM_CONFIG ${GPGPUSIM_CONFIG}\n"
    echo -e "LD_LIBRARY_PATH ${LD_LIBRARY_PATH}\n"
}


#-------------------------------------------------------------------------------
# Test:
#     test_gpgpu
# Purpose:
#     Exercise the GPGPUSim component
# Inputs:
#     None
# Outputs:
#     test_gpgpu.out file
# Expected Results
#     Match of output file against reference file.  Will need to be fuzzy.
# Caveats:
#-------------------------------------------------------------------------------
GPGPU_template() {
    GPGPU_case=$1
    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_gpgpu_${GPGPU_case}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.stdout"
    statsFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_REFERENCE_ELEMENTS}/balar/tests/refFiles/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
    startSeconds=`date +%s`

    echo ""
    echo "Starting directory `pwd`"
    saveDir=`pwd`

    # Setup GPGPUSim environment
    # Sourcing from within a function inheirits function arguments so need seperate call
    GPGPU_environment

    # Copy relevant test files
    echo -e "Copying configuration files from ${SST_ROOT}/sst-elements/src/sst/elements/balar/tests \n"
    cp -r ${SST_ROOT}/sst-elements/src/sst/elements/balar/tests/* .
    ls -l

    # Build target application
    echo "Building application $1"
    pushd vectorAdd

    if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin" ] ; then
       echo "  ### MacOS remove \"-fopenMP\" from the make "
       sed -i'.x' 's/-fopenmp//' Makefile
    fi

    make
    retval=$?
    echo "    Make in tests/vecAdd returned \"ok\" "
    if [ $retval -ne 0 ]
    then
        # bail out on error
        pwd
        echo "ERROR: tests/vecAdd: make failure"
        export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS
        preFail "ERROR: tests/vecAdd: make failure" "skip"
    fi

    popd

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="cuda-test.py"

    Tol=1            ##  Set tolerance at 0.1%
    rm -f ${outFile}
    rm -f ${statsFile}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        echo "Running:"
        echo "${sut} --model-options=\"-c ariel-gpu-v100.cfg -s ${statsFile}\" ${sutArgs}"
        ${sut} --model-options="-c ariel-gpu-v100.cfg -s ${statsFile}" ${sutArgs} > $outFile
        RetVal=$?
        TIME_FLAG=$SSTTESTTEMPFILES/TimeFlag_$$_${__timerChild}
        if [ -e $TIME_FLAG ] ; then
             echo " Time Limit detected at `cat $TIME_FLAG` seconds"
             fail " Time Limit detected at `cat $TIME_FLAG` seconds"
             rm $TIME_FLAG
             removeFreeIPCs
             return
        fi

        if [ $RetVal != 0 ]
        then
             echo ' '; echo WARNING: sst did not finish normally, RetVal= $RetVal ; echo ' '
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             removeFreeIPCs
             return
        fi

        # Fix-up multirank
        if [[ $SST_MULTI_RANK_COUNT -gt 1 ]]
        then
            echo "Cleaning up multi-rank results for ${SST_MULTI_RANK_COUNT} ranks..."
            for (( rankNum = 0; rankNum < $SST_MULTI_RANK_COUNT; rankNum++ ))
            do
                  ls  ${SST_TEST_OUTPUTS}/${testDataFileBase}_${rankNum}.out
                  cat ${SST_TEST_OUTPUTS}/${testDataFileBase}_${rankNum}.out >> $statsFile
            done
        fi

        wc ${statsFile} ${referenceFile}
        RemoveComponentWarning

        echo " "

        grep FATAL ${statsFile}
        if [ $? == 0 ] ; then
            fail "Fatal error detected"
            return
        fi

        lref=`wc ${referenceFile}   | awk '{print $1 }'`;
        lout=`wc ${statsFile}       | awk '{print $1 }'`;
        line_diff=$(( $lref - $lout ));
        line_diff=${line_diff#-}              ## remove minus, if it exists
        if [ $line_diff -eq 0 ] ; then
             echo " Ariel test ${Ariel_case}  -- Line count Match"
        elif [ $line_diff -gt 15 ] ; then
             echo "Ariel test ${Ariel_case} out varies from Ref by $line_diff lines"
             fail "Ariel test ${Ariel_case} out varies from Ref by $line_diff lines"
             echo ' ' ; echo "---------------  tail of statsFile -----"
             tail -20 $statsFile
             echo "     -------------  "
        else
             echo "Output file within $line_diff lines of Reference File"
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi

    cd $saveDir

    endSeconds=`date +%s`
    echo "     `grep 'Simulation is complete' $outFile`"
    echo "Ref: `grep 'Simulation is complete' $referenceFile`"
    echo " "
    removeFreeIPCs           # probably unneeded
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "Ariel ${Ariel_case}: Wall Clock Time  $elapsedSeconds seconds"
}

test_gpgpu_runvecadd() {
    USE_OPENMP_BINARY=""
    USE_MEMH=""

    GPGPU_environment
    GPGPU_template vectorAdd
}


export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

cd $OPWD

## export SST_TEST_ONE_TEST_TIMEOUT=60
## if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin" ] ; then
##     export SST_TEST_ONE_TEST_TIMEOUT=100            # Bump MacOS time limit to 100 seconds
## fi

# Invoke shunit2. Any function in this file whose name starts with
  export SST_TEST_ONE_TEST_TIMEOUT=600
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)

echo " Test ENV VAR  $SST_TEST_HOST_OS_KERNEL"
    if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin" ] ; then

echo " Call to countStreams \"Delete\"follows: "
         countStreams "Delete"
    fi
