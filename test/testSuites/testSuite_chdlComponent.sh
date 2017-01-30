#!/bin/bash 
# testSuite_chdlComponent.sh

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
L_SUITENAME="SST_chdlComponent_suite" # Name of this test suite; will be used to
                                      # identify this suite in XML file. This
                                      # should be a single string, no spaces
                                      # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

    if [[ ${SST_MULTI_CORE:+isSet} == isSet ]] ; then
           echo '           SKIP '
           preFail " CHDL test does not work with threading (#75)" "skip"
    fi     

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

    if [[ ${SST_DEPS_INSTALL_CHDL:+isSet} != isSet ]] ; then
        SST_DEPS_INSTALL_CHDL=${SST_TEST_INSTALL_PACKAGES}/chdl
        if [ ! -d ${SST_DEPS_INSTALL_CHDL} ] ; then
            echo " Did NOT find CHDL in ${SST_TEST_INSTALL_PACKAGES} "
            preFail " Did NOT find CHDL in ${SST_TEST_INSTALL_PACKAGES} " "skip"
        fi
    fi

#    
#     Download and unpack the test netlist and memory initialization file into
#     our test input directory.
    pushd $SST_TEST_INPUTS
    echo " wget http://sst-simulator.org/downloads/iqyax.nand.bz2"
    # wget http://sst-simulator.org/downloads/iqyax.nand.bz2
    wget http://cdkersey.com/secret/iqyax.nand.bz2
    if [ $? != 0 ] ; then
       echo "wget failed"
       preFail
    fi
    echo " wget http://sst-simulator.org/downloads/partest.bin.bz2"
    # wget http://sst-simulator.org/downloads/partest.bin.bz2
    wget http://cdkersey.com/secret/partest.bin.bz2
    if [ $? != 0 ] ; then
        echo "wget failed"
        preFail
    fi

    bunzip2 iqyax.nand.bz2
    bunzip2 partest.bin.bz2
    popd

#-------------------------------------------------------------------------------
# Test:
#     test_chdlComponent
# Purpose:
#     Exercise the chdlComponent code in SST
# Inputs:
#     iqyax.nand, partest.bin.bz2
# Outputs:
#     test_chdlComponent.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_chdlComponent() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_chdlComponent"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    referenceFile="${SST_REFERENCE_ELEMENTS}/chdlComponent/tests/refFiles/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

   
#    export CHDL_PREFIX=$SST_DEPS_INSTALL_CHDL
#    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SST_DEPS_INSTALL_CHDL/lib
#    echo LD_LIBRARY_PATH is ${LD_LIBRARY_PATH}
#    if [ $SST_TEST_HOST_OS_KERNEL == "Darwin" ] ; then
#        export DYLD_LIBRARY_PATH=$LD_LIBRARY_PATH
#        echo ' '
#        echo $DYLD_LIBRARY_PATH
#    fi
    
    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    
    echo SUT PATH is ${sut}

    sutArgs=${SST_TEST_SDL_FILES}/test_chdl.py

##    export ARG1=" "
##    export ARG2=" "
##    export ARG3=" "
echo ' '
df /tmp
ls -l $SST_DEPS_INSTALL_CHDL/lib
echo ' '   
    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
echo SUT `which ${sut}`
echo ARGS `/bin/ls -l ${sutArgs}`
 
        (${sut} ${sutArgs} > ${outFile}) 
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
             return
        fi
echo ' '
df /tmp
echo ' '   
               wc ${outFile} ${referenceFile};
               echo "                   Line and Word count of the diff: "
               echo "                              `diff ${outFile} ${referenceFile} | wc `"
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
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
}

export SST_TEST_ONE_TEST_TIMEOUT=600         # 10 minutes (600 seconds)

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS



# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)

