#!/bin/bash 
# testSuite_M5.sh

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

OPWD=`pwd`    # Save Original PWD

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_M5_suite" # Name of this test suite; will be used to
                                 # identify this suite in XML file. This
                                 # should be a single string, no spaces
                                 # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#     Subroutine to run many of the M5 tests without reproducing the script.
#      First parameter is the name of the test, must match test_M5_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 500.)

M5_Template() {
M5_case=$1
Tol=$2    ##  curTick tolerance
    startSeconds=`date +%s`
    testDataFileBase="test_M5_$M5_case"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    if [ ${UBUNTU_FLAG} == "yes" ] ; then
        referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.Ubuntu.out"
    fi

    sut="${SST_TEST_INSTALL_BIN}/sst"

    cd $TEST_SUITE_ROOT/testM5/$M5_case
    if [ -f $M5_case.x ]
    then
       sutArgs=${M5_case}.py
       export ARG1=" "
       export ARG2=" "
       export ARG3=" "

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
          fail "WARNING: sst did not finish normally"
          return
       fi
#
#   UGLY UTTER Bailing wire for LULESH   with gcc-8.4.1
# 
    sed -i'.sed1' -e '/^iteration = 4/d' $outFile
#   
       diff ${outFile} ${referenceFile} > /dev/null;
       if [ $? -ne 0 ]
       then
          ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
          new=`wc ${outFile}       | awk '{print $1, $2}'`;
          if [ "$ref" != "$new" ]
          then 
             echo "    Output Flunked  lineWordCt Count match"
             wc ${referenceFile} ${outFile}
             diff -u ${referenceFile} ${outFile}
             fail "    Output Flunked  lineWordCt Count match"
          else
             if [ "lineWordCt" == "$Tol" ]
             then
                echo "    Output passed  LineWordCt match"
             else
                lref=`cat ${referenceFile} | grep curTick |awk -F= '{print $2}' |awk '{print $1}'`
                lout=`cat ${outFile} | grep curTick |awk -F= '{print $2}' |awk '{print $1}'`
                if [ "$lref" == "" ]
                then
                   echo "    No curTick found in Reference File"
                   fail "    No curTick found in Reference File"
                else
                   perc=`checkPerCent $lref $lout` 
                   val=`pc100 $perc` 
                   perc=${perc#-}              ## remove minus, if it exists
                   if [ $perc -lt $Tol ] 
                   then
                      echo curTick $lout vs. Ref $lref,  $val  percent $M5_case
                   else
                      echo Flunk curTick $lout vs. Ref $lref, $val  percent $M5_case
                      wc ${outFile} ${referenceFile}
                      fail "Flunk curTick $lout vs. Ref $lref, $val  percent $M5_case"
                   fi
                fi
             fi 
          fi
       else
          echo "    Output matches Reference File exactly"
       fi

       endSeconds=`date +%s`
       echo " "
       elapsedSeconds=$(($endSeconds -$startSeconds))
       echo "${M5_case}: Wall Clock Time  $elapsedSeconds seconds"

    else
        echo ERROR no binary found for $M5_case
        fail "ERROR no binary found for $M5_case"
    fi
}


# Build Test app
##    The following code already explictly assume we're at trunk
  
cd $TEST_SUITE_ROOT/testM5
UBUNTU_FLAG="false"
./buildall.sh 
   

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_M5
# Purpose:
#     Exercise the GEM5 code in SST
#            Hello World
# Inputs:
#     None
# Outputs:
#     test_M5_Hw.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     For shunit2, the output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
# Exception for M5 tests:
#     A fuzzy compare has been inserted here.   The only thing that varies is
#     the value of the total Ticks simulated.  With binaries shared from SVN, 
#     there should be no need for fuzziness.  When the static binary is build
#     using compiler and libraries on the host, the exact number of Ticks in the 
#     program may vary from that reported in the reference file checked into SVN.
# Does not use subroutine because it invokes the build of all test binaries.
#-------------------------------------------------------------------------------
test_M5_helloWorld() {    
M5_Template helloWorld 500

}

test_M5_hwcpp() {
M5_Template hwcpp 500

}

#-------------------------------------------------------------------------------
# Test:
#     test_M5_fpmath
# Purpose:
#     Exercise the the GEM5 code in SST
#           Floating point Arithmetic
# Inputs:
#     None
# Outputs:
#     test_M5_fpmath.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     See first test comment block
#-------------------------------------------------------------------------------

test_M5_fpmath() {
M5_Template  fpmath 500

}

test_M5_timers() {
M5_Template timers 500

}

test_M5_memalloc() {
M5_Template  memalloc 500

}

test_M5_multialloc() {
M5_Template  multialloc 2000

}

test_M5_pi() {
M5_Template  pi 500

}

test_M5_vecpp() {
M5_Template vecpp 500

}
 
test_M5_hwfort() {
M5_Template hwfort 500

}

test_M5_heatfort() {
M5_Template heatfort 1200

}

test_M5_lulesh() {
M5_Template lulesh lineWordCt
}

#   matrix needs a different reference file  for Ubuntu
test_M5_matrix() {
#===============================================================================
##            Initialize the Ubuntu flag for the Matrix test
##     The static binary built on Ubuntu takes ~15% more ticks in its execution
##     than the nominal one supplied from CentOS.    The tolerance currently
##     allowed is 5%.   Ergo here a special reference file for Ubuntu.
##     This is as of  November 16, 2012.  It is likely to change with OS or
##     compiler or library upgrades or changes.
##
    UBUNTU_FLAG="no"
    SST_DEPS_OS_NAME=`uname -s`     # uname OS name
    if [ $SST_DEPS_OS_NAME = "Linux" ]
    then
        /bin/ls /etc/*release > /dev/null 2>&1
        if [ $? -eq 0 ]
        then
            # Check if this is Ubuntu (for 10.04, 10.10, and 11.04)
            cat /etc/*release | egrep  -i "ubuntu" > /dev/null
            retval=$?
            if [ $retval -eq 0 ]
            then
                UBUNTU_FLAG="yes"
            fi
        fi
    fi
#===============================================================================

M5_Template matrix 500
UBUNTU_FLAG="Done"
}

test_M5_argv() {
M5_Template  argv 500

}


test_M5_env() {
M5_Template  env 500

}


test_M5_fixedbinary() {
M5_Template  fixedbinary  2

}

test_M5_CentOSmatrix() {
M5_Template  CentOSmatrix 500

}

export SST_TEST_ONE_TEST_TIMEOUT=300

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
cd $OPWD        # Restore entry PWD
(. ${SHUNIT2_SRC}/shunit2)

