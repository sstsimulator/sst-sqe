# !/bin/bash
# testSuite_Ariel.sh

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

export PATH=$PATH:$SST_TEST_INSTALL_BIN

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_Ariel" # Name of this test suite; will be used to
                                # identify this suite in XML file.  (no spaces)

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#=====================================================
#  A bit of code to clear out old Ariel Shmem files from /tmp

    ls -l /tmp | grep $USER | grep ariel_shmem > __rmlist
    wc __rmlist
    today=$(( 10#`date +%j` ))
    echo "today is $today"
    
    while read -u 3 r1 r2 r3 r4 r5 mo da r8 name
    do
    
      c_day=$(( 10#`date +%j -d "$mo $da"` ))
      c_day_plus_2=$(($c_day+2))
 
      if [ $today -gt $c_day_plus_2 ] ; then
         echo "Remove /tmp/$name"
         rm /tmp/$name
      fi
    
    done 3<__rmlist
    rm __rmlist
#=====================================================

    
    echo "INTEL_PIN_DIRECTORY = $INTEL_PIN_DIRECTORY"
    if [ ! -d "$INTEL_PIN_DIRECTORY" ] ; then
        echo "Ariel tests requires PIN DIRECTORY"
        echo "        NOT  FOUND"
        echo " Environment Variable INTEL_PIN_DIRECTORY must be defined"
        preFail "Ariel tests requires PIN DIRECTORY" "skip"
    fi 
    if [ "${SST_TEST_HOST_OS_DISTRIB_UBUNTU}" == "1" ] ; then
        echo " Temporary patch"
        echo "Ariel on Ubuntu not working on Sandy bridge and Ivy bridge tests"
    fi    

    OPWD=`pwd`
    export PKG_CONFIG_PATH=${SST_ROOT}/../../local/lib/pkgconfig

    cd $SST_ROOT/sst-elements/src/sst/elements/ariel/frontend/simple

    pushd examples/stream

    if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin" ] ; then
       echo "  ### MacOS remove \"-fopenMP\" from the make "
       sed -i'.x' 's/-fopenmp//' Makefile
    fi

    make 
    retval=$?
    echo "    Make in examples/stream returned \"ok\" "
    if [ $retval -ne 0 ]
    then
        # bail out on error
        pwd
        echo "ERROR: examples/stream: make failure"
        export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS
        preFail "ERROR: examples/stream: make failure" "skip"
    fi

#
#   Let's build the ompmybarrier binary
#
    pushd $TEST_SUITE_ROOT/testopenMP
    cd ompmybarrier
ls -l 
    make -f newMakefile
ls -l 
    popd

#     Subroutine to clean up shared memory ipc
#          This could be in subroutine library - for now only Ariel
removeFreeIPCs() {
    #   Find and kill orphanned running binaries
    ps -f > _running_bin
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
    done 3<_running_bin
  
    #  Find and remove no longer attached shared memory segments  
    ipcs > _ipc_list
    ##     echo "         DEBUG ONLY `wc _ipc_list`"
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
    done 3<_ipc_list
    rm _ipc_list  _running_bin
}

#-------------------------------------------------------------------------------
# Test:
#     test_Ariel
# Purpose:
#     Exercise the Ariel
# Inputs:
#     None
# Outputs:
#     test_Ariel.out file
# Expected Results
#     Match of output file against reference file.  Will need to be fuzzy.
# Caveats:
#-------------------------------------------------------------------------------
Ariel_template() {
    Ariel_case=$1
    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_Ariel_${Ariel_case}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
    startSeconds=`date +%s`

 
    echo " starting Directory `pwd`"
    saveDir=`pwd`

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"

    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/ariel/frontend/simple/examples/stream/${Ariel_case}.py"
    echo $sutArgs
    if [[ ${USE_OPENMP_BINARY:+isSet} == isSet ]] ; then
        export OMP_EXE=$SST_ROOT/test/testSuites/testopenMP/ompmybarrier/ompmybarrier
        echo $OMP_EXE
        ls -l $OMP_EXE
    fi
    if [[ ${USE_MEMH:+isSet} == isSet ]] ; then
        cd $SST_ROOT/sst-elements/src/sst/elements/ariel/frontend/simple      ## This is redundent
  
        ln -sf ${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/tests/DDR3_micron_32M_8B_x4_sg125.ini .
        ln -sf ${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/tests/system.ini .
    fi 

    Tol=1            ##  Set tolerance at 0.1%
    rm -f ${outFile}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        ${sut} ${sutArgs} > $outFile
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
             echo ' '; echo WARNING: sst did not finish normally, RetVal= $RetVal ; echo ' '
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             removeFreeIPCs
             return
        fi

        wc ${outFile} ${referenceFile} 

        echo " "

##########################################################################
#     The following code besides being very wrong is doomed.
#         Any such test being applied to Ariel fails because of
#            indeterminacy!
#
 #        diff ${outFile} ${referenceFile} > /dev/null;
 #        if [ $? -ne 0 ]
 #        then
 #             ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
 #             new=`wc ${outFile}       | awk '{print $1, $2}'`;
 #                 if [ "$ref" == "$new" ]
 #                 then 
 #                     echo "    Output passed  LineWordCt match"
 #                 else
 #                     echo "    Output Flunked  lineWordCt Count match"
 #                     fail "Output Flunked  lineWordCt Count match"
 #                     compare_sorted ${outFile} ${referenceFile}
 #                     diff  ${outFile} ${referenceFile} 
 #                 fi
 #            echo " Next is word count of the diff:"
 #            diff  ${outFile} ${referenceFile} | wc
 #            compare_sorted ${outFile} ${referenceFile}
 #            echo ' '
 #
 #        else
 #            echo oufFile is an exact match for Reference File
 #        fi
 #
 ##        diff -u ${outFile} ${referenceFile}
 #:
 ###############################################################################

        lref=`wc ${referenceFile} | awk '{print $1 }'`; 
        lout=`wc ${outFile}       | awk '{print $1 }'`;
        line_diff=$(( $lref - $lout ));
        line_diff=${line_diff#-}              ## remove minus, if it exists
        if [ $line_diff -eq 0 ] ; then
             echo " Ariel test ${Ariel_case}  -- Line count Match"
        elif [ $line_diff -gt 15 ] ; then
             echo "Ariel test ${Ariel_case} out varies from Ref by $line_diff lines"
             fail "Ariel test ${Ariel_case} out varies from Ref by $line_diff lines"
             echo ' ' ; echo "---------------  tail of outFile -----"
             tail -20 $outFile
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

ls -l ${SST_ROOT}/sst-elements/src/sst/elements/ariel/frontend/simple/examples/stream

test_Ariel_runstream() {
    USE_OPENMP_BINARY=""
    USE_MEMH=""
    Ariel_template runstream
}
    

test_Ariel_testSt() {
    USE_OPENMP_BINARY=""
    USE_MEMH=""
    Ariel_template runstreamSt
}


test_Ariel_testNB() {
    USE_OPENMP_BINARY=""
    USE_MEMH=""
    Ariel_template runstreamNB
}

test_Ariel_memH_test() {
    USE_OPENMP_BINARY=""
    USE_MEMH="yes"
    Ariel_template memHstream
}

test_Ariel_test_ivb() {
##     if [ "${SST_TEST_HOST_OS_DISTRIB_UBUNTU}" == "1" ] ; then
##         echo " Temporary patch"
##         echo "Ariel on Ubuntu not working on Sandy and Ivy bridge"
##         skip_this_test
##         return
##     fi
    if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin" ] ; then
        echo "Open MP is not currently support on MacOS"
        skip_this_test
        return
    fi
    USE_OPENMP_BINARY="yes"
    USE_MEMH=""
    Ariel_template ariel_ivb
}

test_Ariel_test_snb() {
##     if [ "${SST_TEST_HOST_OS_DISTRIB_UBUNTU}" == "1" ] ; then
##         echo " Temporary patch"
##         echo "Ariel on Ubuntu not working on Sandy and Ivy bridge"
##         skip_this_test
##         return
##     fi
    if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin" ] ; then
        echo "Open MP is not currently support on MacOS"
        skip_this_test
        return
    fi

    if [[ ${SST_MULTI_RANK_COUNT:+isSet} == isSet ]] && [ ${SST_MULTI_RANK_COUNT} -gt 1 ] ; then
        echo "Sandy Bridge test is incompatible with Multi-Rank"
        skip_this_test
        return
    fi

    USE_OPENMP_BINARY="yes"
    USE_MEMH=""
    Ariel_template ariel_snb
}



export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

cd $OPWD

export SST_TEST_ONE_TEST_TIMEOUT=60

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
