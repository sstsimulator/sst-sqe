#!/bin/bash 
# testSuite_memHierarchy2.sh    *** NOTE 2   TWO   ****
#         This Suite uses binaries from the M5 Suite

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
L_SUITENAME="SST_memHierarchy_bin_suite" # Name of this test suite; will be used to
                                 # identify this suite in XML file. This
                                 # should be a single string, no spaces
                                 # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
#                       TEMPLATE
#     Subroutine to run many of the memHierarchy tests without reproducing the script.
#      First parameter is the name of the test, must match test_memHierarchy_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 500.)

memHierarchy_Template() {
memH_case=$1
Tol=$2    ##  curTick tolerance

    startSeconds=`date +%s`
    testDataFileBase="test_memHierarchy_$memH_case"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    tmpFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.tmp"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
    memH_dir=$SST_ROOT/sst/elements/memHierarchy/tests
    cd $memH_dir

    sut="${SST_TEST_INSTALL_BIN}/sst"
#
#               set   M5_EXE
#
    dirbin=$SST_TEST_ROOT/testSuites/testM5

    binfile=$SST_TEST_ROOT/testSuites/testM5/$memH_case/${memH_case}.x
    if [ ! -e $binfile ] 
    then
        pushd $dirbin
        ./buildall.sh
        popd
    fi
    
    export M5_EXE=$binfile
    sutArgs=example.py
    if [ ! -e $sutArgs ]
    then
        echo ' '
        echo "Did not find Python input file $sutArgs,   PWD:"
        pwd
        ls
        echo ' '
        fail "Did not find Python input file $sutArg"
        return
    fi

    ${sut} ${sutArgs} > ${outFile}
        RetVal=$? 
        TIME_FLAG=$SSTTESTTEMPFILES/TimeFlag_$$_${__timerChild} 
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
        wc $outFile
        sed 10q $outFile
        echo "           . . ."
        tail -10 $outFile
        fail "WARNING: sst did not finish normally, RetVal=$RetVal   $memH_case"
        return
    fi

    if [ -s "$referenceFile" ] && [ "$(tail -c1 "$referenceFile"; echo x)" != $'\nx' ] ; then
        echo >> $referenceFile
    echo "   Found file with no eol!    $memH_case"
    fi

    matchFail=0
    matchct=0
    while read -u 3 line 
    do
##        ## check for curTick   
##        if [[ $line == *curTick* ]] ; then
##           lref=`cat ${referenceFile} | grep curTick |awk -F= '{print $2}' |awk '{print $1}'`
##           lout=`cat ${outFile} | grep curTick |awk -F= '{print $2}' |awk '{print $1}'`
##           if [ "$lref" == "" ]
##           then
##               echo "    No curTick found in Reference File"
##               fail "    No curTick found in Reference File"
##           fi
##           perc=`checkPerCent $lref $lout` 
##           val=`pc100 $perc` 
##           perc=${perc#-}              ## remove minus, if it exists
##           if [ $perc -lt $Tol ] 
##           then
##               echo curTick $lout vs. Ref $lref,  $val  percent $memH_case
##           else
##               echo Flunk curTick $lout vs. Ref $lref, $val  percent $memH_case
##               fail "Flunk curTick $lout vs. Ref $lref, $val  percent $memH_case"
##           fi
       if [ "$line" == "" ] ; then
         #  Do nothing
          echo
       else
           ct=`grep -c "$line" $referenceFile`
           if [ $ct == 0 ] ; then
               echo OPPS   subtle mismatch
               echo "line is ($line)"
               echo "Entire Reference File is:"
               cat $referenceFile
               echo NOW DO WHAT ???
               fail "Suite vs. Reference File error"
               return
           fi
    
           outct=`grep -c "$line" $outFile`
           if [ $outct == $ct ] ; then
               matchct=$(($matchct+1))
           else
               first=${line:0:15}
               grep -q "$first" $outFile
               if [ $? == 0 ] ; then
                   echo "        ---- Not an Exact match ----"
                   echo "Ref:  $line"
                   echo "Here: `grep "$first" $outFile`"
                   echo "                  ----"
               else
                   s=$((${#line}-20))
                   last=${line:$s:20}
                   grep -q "$last" $outFile
                   if [ $? == 0 ] ; then
                       echo "   ---- Not an Exact match ----"
                       echo $line
                       grep "$last" $outFile
                       echo "             ----"
                   else 
                       echo No match for reference file line: $line
                       matchFail=$(($matchFail+1))
                   fi
               fi
           fi 
        fi
    done 3< $referenceFile

   echo "                $matchct lines matched  for $memH_case"
   if [ $matchFail != 0 ] ; then
       fail " $MatchFail lines of Reference file not matched exactly"
   fi

   endSeconds=`date +%s`
   echo " "
   elapsedSeconds=$(($endSeconds -$startSeconds))
   echo "${memH_case}: Wall Clock Time  $elapsedSeconds seconds"
          

}


# Build Test app
##    The following code already explictly assume we are at trunk
  
   

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

test_memHierarchy_hwcpp() {          
echo Begin first memH test of Second group
memHierarchy_Template hwcpp 500

}

test_memHierarchy_argv() {          
memHierarchy_Template argv 500

}

test_memHierarchy_pi() {
memHierarchy_Template pi 500

}

test_memHierarchy_fpmath() {          
memHierarchy_Template fpmath 500

}

test_memHierarchy_multialloc() {          
memHierarchy_Template multialloc 500

}


test_memHierarchy_timers() {          
memHierarchy_Template timers 500

}

test_memHierarchy_memalloc() {          
memHierarchy_Template memalloc 500

}

test_memHierarchy_CentOSmatrix() {          
memHierarchy_Template CentOSmatrix 500

}

xxtest_memHierarchy_matrix() {
    memHierarchy_Template matrix 500
}


export SST_TEST_ONE_TEST_TIMEOUT=250         # 250 seconds

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)

