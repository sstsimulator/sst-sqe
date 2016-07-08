#!/bin/bash 
# testSuite_qsimComponent.sh

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
L_SUITENAME="SST_qsimComponent_suite" # Name of this test suite; will be used to
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

    if [[ ${SST_DEPS_INSTALL_QSIM:+isSet} != isSet ]] ; then
        SST_DEPS_INSTALL_QSIM=${SST_TEST_INSTALL_PACKAGES}/Qsim
        if [ ! -d ${SST_DEPS_INSTALL_QSIM} ] ; then
            echo " Did NOT find QSIM in ${SST_TEST_INSTALL_PACKAGES} "
            preFail "Did NOT find QSIM in ${SST_TEST_INSTALL_PACKAGES}" "skip"
        fi
    fi
    if [[ ${SST_MULTI_RANK_COUNT:+isSet} == isSet ]] && [ ${SST_MULTI_RANK_COUNT} -gt 1 ] ; then
        preFail "Qsim fails with time-limit on Multi Rank" "skip"
    fi

#-------------------------------------------------------------------------------
# Test:
#     test_qsimComponent
# Purpose:
#     Exercise the qsimComponent code in SST
# Inputs:
#     None
# Outputs:
#     test_qsimComponent.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_qsimComponent() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_qsimComponent"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
    #  Remove previous temp files
    rm -f /tmp/qsim_??????    ## -f Says don't ask about files belonging to somebody else

   
##   build the xml file
echo ' ';  echo "            build the xml file"
    pushd ${SST_ROOT}/sst-elements/src/sst/elements/qsimComponent/test
file test-app
ls -l test-app
./test-app | wc
    make
    popd
    #  there is code above that sets a default value if possible.
    if [[ ${SST_DEPS_INSTALL_QSIM:+isSet} != isSet ]] ; then 
       echo "                ---"
       echo " Qsim test requires environment variable, SST_DEPS_INSTALL_QSIM"
       echo " which points to the Qsim install directory.   For example,"
       echo "\"export SST_DEPS_INSTALL_QSIM=~/local/packages/Qsim\""
       echo "                ---"
       fail " SST_DEPS_INSTALL_QSIM is not defined"
       return
    fi
    export QSIM_PREFIX=$SST_DEPS_INSTALL_QSIM
    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    
echo SUT PATH is ${sut}

    sutArgs=${SST_ROOT}/sst-elements/src/sst/elements/qsimComponent/test/test.xml
appj=${SST_ROOT}/sst-elements/src/sst/elements/qsimComponent/test/test-app

##    export ARG1=" "
##    export ARG2=" "
##    export ARG3=" "
echo ' '
df /tmp
ls -l $SST_DEPS_INSTALL_QSIM/lib
echo ' '   
    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
echo SUT `which ${sut}`
echo ARGS `/bin/ls -l ${sutArgs}`
echo ' '
echo "                      RUN SST " ; echo ' '
echo "            `date +%r`" > ps.before
ps -ef | grep ^$USER >> ps.before

if [ "${SST_TEST_HOST_OS_DISTRIB}" != "toss" ] ; then 
        (${sut} ${sutArgs} > ${outFile}) 
        rt=$?
        TIME_FLAG=/tmp/TimeFlag_$$_${__timerChild} 
        if [ -e $TIME_FLAG ] ; then 
             echo " Time Limit detected at `cat $TIME_FLAG` seconds" 
             fail " Time Limit detected at `cat $TIME_FLAG` seconds" 
             rm $TIME_FLAG 
             return 
        fi 
else
   cat > inF << .EOF
   run ${sutArgs} > ${outFile}
   where
   q
   yes
.EOF

   gdb $sut  < inF
   rt=0

   diff ${outFile} ${referenceFile}
fi 

        if [ $rt != 0 ]
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             ls -l ${sut}
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
echo ' ' ; wc ${outFile} ${referenceFile}
echo ' ' ; echo "   ----------   list the Running tasks BEFORE)"
cat ps.before
echo ' ' ; echo "   ----------   list the Running tasks AFTER)  `date +%r`"
ps -ef | grep ^$USER 
echo ' ' ; echo "   ----------   list the  outFile  (stdout only)"
cat $outFile
echo " ---------------------------------- end-of-outFile"
             return
        fi
echo ' ' ; echo "        Completed sst execution" ; echo ' '
df /tmp
echo ' '   
               myWC ${outFile} ${referenceFile};
               echo ' '
               echo " Ignore \"IPI arrived\" messages"
               echo " From the outFile: "
               grep -n IPI.arrived ${outFile}
               sed -i'.with-IPI' '/IPI arrived/d' ${outFile}
               echo ' '
               myWC ${outFile} ${referenceFile};
               echo "                   Line and Word count of the diff: "
               echo "                              `diff ${outFile} ${referenceFile} | wc `"
               if [ `diff ${outFile} ${referenceFile} | wc -l ` -lt 51 ] ; then
                   diff ${outFile} ${referenceFile}
               fi
               ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
               new=`wc ${outFile}       | awk '{print $1, $2}'`;
               if [ "$ref" != "$new" ];
               then
                   wc ${outFile} ${referenceFile};
                   ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
                   new=`wc ${outFile}       | awk '{print $1, $2}'`;
                   if [ "$ref" != "$new" ];
                   then
                       fail "FAILED: line/word count does NOT match"
                       echo " word count of diff follows:"
                       diff ${referenceFile} ${outFile} | wc
                   fi
                   echo "                              `diff ${outFile} ${referenceFile} | wc `"
               fi
        # Remove temp files created by this run
        rm -f /tmp/qsim_??????
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
}

export SST_TEST_ONE_TEST_TIMEOUT=180         # 3 minutes is plenty  (180 seconds)

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS



# Invoke shunit2. Any function in this file whose name starts with

export SST_TEST_ONE_TEST_TIMEOUT=240         # 3 minutes is not enough for Multi-thread=4 (180 seconds)
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)

