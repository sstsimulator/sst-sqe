#!/bin/bash 
# testSuite_diropenMP.sh

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
L_SUITENAME="SST_diropenMP_suite" # Name of this test suite; will be used to
                                 # identify this suite in XML file. This
                                 # should be a single string, no spaces
                                 # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
#     Subroutine to run many of the diropenMP tests without reproducing the script.
#      First parameter is the name of the test, must match test_openMP_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 9000.)
#      Special case:  if second parameter is "lineWordCt",
#                          accept a line/word count match.

OMP_Template() {
OMP_case=$1
Tol=$2    ##  curTick tolerance,  or  "lineWordCt" 
    if [ ! -e $SST_TEST_ROOT/testSuites/testopenMP/pthread/m5threads/libpthread.a ] &&
                       [ "$SST_TEST_HOST_OS_KERNEL" != "Darwin" ] ; then
        echo "no thread library directory"
        fail "no thread library directory"
        return
    fi

    startSeconds=`date +%s`
    testDataFileBase="test_OMP_dir${OMP_case}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    tmpFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.tmp"
    wrkFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.wrk"
#           Modified to use openMP Reference files
    referenceFile="${SST_TEST_REFERENCE}/test_OMP_${OMP_case}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    sut="${SST_TEST_INSTALL_BIN}/sst"
    export OMP_EXE=${OMP_case}/${OMP_case}.x

    cd $TEST_SUITE_ROOT/testopenMP
    sutArgs=./directory-8cores-2nodes.py
     
    if [ -f $OMP_case/$OMP_case.x ]
    then
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
             wc $outFile
             echo "       THE outFile    first <= 15 lines "
             sed 15q $outFile
             echo '                  . . . '; echo " tail last <= 15 lines "
             tail -15 $outFile
             echo '             - - - - - '
             fail "WARNING: sst did not finish normally   $OMP_case"
             return
        fi

if [ -s "$referenceFile" ] && [ "$(tail -c1 "$referenceFile"; echo x)" != $'\nx' ] ; then
    echo >> $referenceFile
fi

matchFail=0
matchct=0
while read -u 3 line 
do
   ## check for curTick   
   if [[ $line == *curTick* ]] ; then
                     lref=`cat ${referenceFile} | grep curTick |awk -F= '{print $2}' |awk '{print $1}'`
                     lout=`cat ${outFile} | grep curTick |awk -F= '{print $2}' |awk '{print $1}'`
                     if [ "$lref" == "" ]
                     then
                         echo "    No curTick found in Reference File"
                         fail "    No curTick found in Reference File"
                     fi
                     perc=`checkPerCent $lref $lout` 
                     val=`pc100 $perc` 
                     perc=${perc#-}              ## remove minus, if it exists
                     if [ $perc -lt $Tol ] 
                     then
                         echo curTick $lout vs. Ref $lref,  $val  percent $OMP_case
                     else
                         echo Flunk curTick $lout vs. Ref $lref, $val  percent $OMP_case
                         fail "Flunk curTick $lout vs. Ref $lref, $val  percent $OMP_case"
                     fi
    elif [ "$line" == "" ] ; then
         #  Do nothing
         echo
    else
       ct=`grep -c "$line" $referenceFile`
       if [ $ct == 0 ] ; then
           echo OPPS   subtle mismatch
    echo NOW DO WHAT ???
           fail "Suite vs. Reference File error"
       fi
    
       outct=`grep -c "$line" $outFile`
       if [ $outct == $ct ] ; then
           matchct=$(($matchct+1))
       else
           echo No match for reference file line: $line
           matchFail=$(($matchFail+1))
       fi 
   fi 
done 3< $referenceFile

echo "                $matchct lines matched  for $OMP_case" ; echo ' '
        if [ $matchFail != 0 ] ; then
           fail " $MatchFail lines of Reference file not matched exactly"
        fi

        endSeconds=`date +%s`
        echo " "
        elapsedSeconds=$(($endSeconds -$startSeconds))
        echo "dir${OMP_case}: Wall Clock Time  $elapsedSeconds seconds"

    else
        echo testSuite: ERROR no binary found for dir$OMP_case
        fail "testSuite: ERROR no binary found for dir$OMP_case"
    fi
}


# Build Test app
##    The following code already explictly assume we're at trunk
  
cd $TEST_SUITE_ROOT/testopenMP
    
./buildall.sh 
   

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#
#     _ompatomic
#
test_dirompatomic() {    
OMP_Template ompatomic 9000

}

#
#     _ompatomicShort
#
test_dirompatomicShort() {    
OMP_Template ompatomicShort 30000

}

#
#     ompapi
#
test_dirompapi() {
OMP_Template ompapi  9000

}


#
#     _ompbarrier
#
test_dirompbarrier() {    
OMP_Template ompbarrier 9000

}





#
#     _ompcritical
#
test_dirompcritical() {    
OMP_Template ompcritical 9000

}


#
#     _ompdynamic
#
test_dirompdynamic() {    
OMP_Template ompdynamic 9000

export SST_TEST_ONE_TEST_TIMEOUT=300
echo "setting time limit to $SST_TEST_ONE_TEST_TIMEOUT for the OMP fort test that follows"

}

#
#     _ompfort
#
test_dirompfort() {    
OMP_Template ompfort 11000

}


#
#     _ompreduce
#
test_dirompreduce() {    
OMP_Template ompreduce 9000

}


#
#     _ompthrcount
#
test_dirompthrcount() {    
OMP_Template ompthrcount 9000

}


#
#     _omptriangle
#
test_diromptriangle() {    
OMP_Template omptriangle 9000

}


export SST_TEST_ONE_TEST_TIMEOUT=200

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
cd $OPWD        # Restore entry PWD
(. ${SHUNIT2_SRC}/shunit2)

