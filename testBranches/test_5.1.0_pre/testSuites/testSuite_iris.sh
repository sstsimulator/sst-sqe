#!/bin/bash 
# testSuite_iris.sh

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
L_SUITENAME="SST_iris_suite" # Name of this test suite; will be used to
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

#-------------------------------------------------------------------------------
# Test:
#     test_iris
# Purpose:
#     Exercise the iris code in SST
# Inputs:
#     None
# Outputs:
#     test_iris.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
test_iris() {

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_iris"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    
    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs=${SST_ROOT}/sst/elements/iris/test_v2.py
    export ARG1=" "
    export ARG2=" "
    export ARG3=" "


    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
echo SUT `which ${sut}`
echo ARGS `/bin/ls -l ${sutArgs}`
        ${sut} ${sutArgs} > ${outFile} 2>$errFile
        if [ $? != 0 ]
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             fail  "WARNING: sst did not finish normally"
             echo The Error File   first 10 and last 10 lines:
             sed 10q $errFile
             echo "       - - -"
             tail -10 $errFile
             echo ' '
             return
        fi
        cat $errFile | grep -v 'Warning:.*undoc'
        echo "          ----------"

        notAlignedCt=`grep -c 'Warning:.*undoc' $errFile`
        if [ $notAlignedCt != 0 ] ; then
            echo ' ' ; echo "* * * *   $notAlignedCt \"undocumented\" messages from iris test   * * * *" ; echo ' '
        fi

        
               wc ${outFile} ${referenceFile};
               ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
               new=`wc ${outFile}       | awk '{print $1, $2}'`;
               if [ "$ref" != "$new" ];
               then
                   echo "         FAILED: word/line-count test"
                   lines_of_diff=`diff $referenceFile $outFile | wc -l`
                   if [ $lines_of_diff == 12 ] ; then
                        echo "           Ports not define???"
                   else
                        echo " ------  DIFF vs. reference"
                        diff $referenceFile $outFile 
                        fail "FAILED: word/line-count test"
                   fi
               fi

    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
}

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)

