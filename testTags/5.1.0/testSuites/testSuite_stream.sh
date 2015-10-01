#!/bin/bash 
# testSuite_stream.sh

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

    
#     ---------------------------------------------------------------
#
#        INDEX_RUNNING is 1 based index of case to process.
#
#     ---------------------------------------------------------------
#     ---------------------------------------------------------------

OPWD=`pwd`    # Save Original PWD

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_stream_suite" # Name of this test suite; will be used to
                                 # identify this suite in XML file. This
                                 # should be a single string, no spaces
                                 # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names


matchFail=0    ## Unused, but referenced
#===============================================================================
#     Subroutine to run many of the stream tests without reproducing the script.
#      First parameter is the name of the test, must match test_stream_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 9000.)
#      Special case:  if second parameter is "lineWordCt",
#                          accept a line/word count match.
#     ---------------------------------------------------------------
#
#        Begin the template, which is mostly just like a standard stream test.
#            It does bump the index, INDEX_RUNNING, which marches thru cases.
#
#     ---------------------------------------------------------------
OMP_Template() {
OMP_case=$1
Tol=9000    ##  curTick tolerance,  or  "lineWordCt" 

#
#    Consult Revision # 9094 to restore the build of binary
#    Not going to preserve history or conditionalize it here.
#
    if [ $2 == 0 ] ; then
       ##  Option was available because MacOS required SVN Binary
       echo "Skipping test"
       skip_this_test            # function call to ignore this test
       echo ' '
       return
    fi
    cd $TEST_SUITE_ROOT/teststream
    export ARRAY_SIZE=$2

    ln -sf CentOS-bins/stream.${ARRAY_SIZE}
    echo "use CentOS  stream.${ARRAY_SIZE}"
    
    startSeconds=`date +%s`
    testDataFileBase="test_stream_${ARRAY_SIZE}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}${INDEX_RUNNING}.out"
    tmpFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.tmp"
    wrkFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.wrk"
    sutArgs=stream.py
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    sut="${SST_TEST_INSTALL_BIN}/sst"
    export OMP_EXE=stream.${ARRAY_SIZE}

     
    if [ -x $OMP_EXE  ]
    then
        (${sut} ${sutArgs} > ${outFile})
        if [ $? != 0 ]
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             sed 5q $outFile
             echo ' '
             fail "WARNING: sst did not finish normally"
             return
        fi

        grep -e "Solution Validates" -e simulated.time $outFile
        wc $referenceFile $outFile

        diff ${outFile} ${referenceFile} > /dev/null;
        if [ $? -ne 0 ]
        then
            ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
            new=`wc ${outFile}       | awk '{print $1, $2}'`;
            if [ "$ref" == "$new" ]
            then 
                echo "    Output passed  LineWordCt match"
            else
                echo "    Output Flunked  lineWordCt Count match"
                fail "    Output Flunked  lineWordCt Count match"
                echo "              Follows the output file:"
                cat $outFile
            fi
        fi


        endSeconds=`date +%s`
        echo " "
        elapsedSeconds=$(($endSeconds -$startSeconds))
        echo "${OMP_case}: Wall Clock Time  $elapsedSeconds seconds"

    else
        echo testSuite: ERROR no binary found for $OMP_case
        fail "testSuite: ERROR no binary found for $OMP_case"
    fi
}
#     ---------------------------------------------------------------
#        End of template
#     ---------------------------------------------------------------


########################################### get rid of the build
##  # Build Test app
##  ##    The following code already explictly assume we're at trunk.   WRONG!!!!!
##  ##    The actual build is in the template.
##  if [ `uname` != "Darwin" ] ; then
##  ##     Make sure there is a M5pthreads available.
##    
##     cd $TEST_SUITE_ROOT/teststream
##      
##     if [ ! -d pthread ] ; then
##        if [ ! -d ../testopenMP/pthread/m5pthreads ] ; then
##           pushd ../testopenMP
##           ./buildall.sh
##           popd
##        fi
##        ln -s ../testopenMP/pthread .
##     fi    
##  fi
##################################################################

##  Common Reference file
referenceFile="${SST_TEST_REFERENCE}/test_stream.out"


#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#     ---------------------------------------------------------------
#
#        The Real test subroutine, which will be executed multiple times.
#
#     ---------------------------------------------------------------

if [ `uname` == "Darwin" ] ; then
   T1=256
   T2=0
   T3=0
   T4=4096
   T5=777
else
echo ' ' ;  echo "code to randomize array size goes here at line $LINENO" ; echo ' '
   T1=256
   T2=512
   T3=1024
   T4=4096
   T5=777
fi
#
########### Must be my doing.   selectBin is nothing so test1 is the FIRST parameter.
#
test_stream_1() {    
OMP_Template $selectBin test1  $T1

}

test_stream_2() {    
OMP_Template $selectBin test2  $T2

}

test_stream_3() {    
OMP_Template $selectBin test3  $T3

}

test_stream_4() {    
OMP_Template $selectBin test4  $T4

}

test_stream_5() {    
OMP_Template $selectBin test5  $T5

}




export SST_TEST_ONE_TEST_TIMEOUT=1800

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
cd $OPWD        # Restore entry PWD
(. ${SHUNIT2_SRC}/shunit2)

