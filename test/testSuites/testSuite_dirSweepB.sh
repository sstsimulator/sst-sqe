#!/bin/bash 
# testSuite_dirSweep.sh

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
#          Determine which test object (binary) to use.
#               Sweep will use just one
#
#     ---------------------------------------------------------------
#####################################################
#choices are:
#                     secs
#     ompatomic		 1
#     ompapi		 1
#     ompbarrier	11     
#     ompcritical	 1
#     ompdynamic	 2	
#     ompfort		17    
#     ompreduce		 2
#     ompthrcount	 1
#     omptriangle	 7
#
#    To select a particular one, use SST_SWEEP_OPENMP
#     For example:
#       export SST_SWEEP_OPENMP=atomic
#
#    Default is a pseudo random selection based on time in seconds.
########################################################
LONGER_COUNT=0
SHORTER_COUNT=0
FAIL_COUNT=0
Secs=`date +%s`
JND=`expr $Secs % 7`
if [[ ${SST_SWEEP_OPENMP:+isSet} == isSet ]]
then 
    selectBin="omp"${SST_SWEEP_OPENMP}
else 
    OMPLIST[0]="ompatomic"
    OMPLIST[1]="ompapi"
    OMPLIST[2]="ompcritical"
    OMPLIST[3]="ompdynamic"
    OMPLIST[4]="ompreduce"
    OMPLIST[5]="omptriangle"
    OMPLIST[6]="ompbarrier"
##    OMPLIST[7]="ompfort"

    echo $Secs  $JND
    selectBin=${OMPLIST[$JND]}
fi

## Adjust the time limit if running ompfort
export SST_TEST_ONE_TEST_TIMEOUT=500
if [ $selectBin == "ompfort" ] ; then
    export SST_TEST_ONE_TEST_TIMEOUT=1300
fi

##############################################################

#    New Code for singling out which index to run

#############################################################


DO_SP_LIST="no"
if [[ ${DIR_SP_LIST:+isSet} == isSet ]]
then 
    DO_SP_LIST="yes"
    CASES=($DIR_SP_LIST)
    echo ${CASES}
    nCASES=`echo $DIR_SP_LIST | wc -w`
fi

if [[ ${DIR_SP_BIN_LIST:+isSet} == isSet ]]
then 
   nBINS=`echo $DIR_SP_BIN_LIST | wc -w`
   BINLIST=${DIR_SP_BIN_LIST}
else
   if [[ ${SST_SWEEP_OPENMP:+isSet} == isSet ]]
   then 
       BINLIST=${SST_SWEEP_OPENMP}
       nBINS=1
   else
       BINLIST="atomic api critical dynamic reduce triangle barrier fort"
       nBINS=8
   fi
fi
echo Number of binaries = $nBINS $BINLIST
echo "JND =  $JND " 

echo Directory SWEEP will use ${BINLIST} 
    
#     ---------------------------------------------------------------
#
#      Subroutine to select a set of Sweep parameters
#        INDEX_RUNNING is 1 based index of case to process.
#
#     ---------------------------------------------------------------
do_sweep() {
    INDEX_MATCH=0
    JD=""

#         Select OMP case
    for bin in $BINLIST  
    do
      OMP_case=omp${bin}
#         Size of L1 cache
      for s1 in "8 KB" "32 KB"
      do
#         Size of L2 cache
        for s2 in "32 KB" "512 KB" 
        do
#         Associativity of L1 cache
          for a1 in 2 
          do
#         Replacement policy for both caches
            for r in lru 
            do
              if [[ ${SST_SWEEP_REPLACE_OPT:+isSet} == isSet ]] ; then
                  if [ $r == "lru" ] ; then
                      r=${SST_SWEEP_REPLACE_OPT}
                  else
                      break
                  fi
              fi

#           Associativity of L2 cache
              for a2 in 16
              do
#                L2 MSHR size
                for ml2 in  16
                do         
#                  MSI / MESI
                  for c in MSI MESI
                  do         
#                     Prefetcher or not                   
                    for pf in "yes" "no"
                    do         
                      INDEX_MATCH=$(($INDEX_MATCH+1))
                      
                      if [ $INDEX_MATCH == $INDEX_RUNNING ] ; then
                           echo "     $c, $r, $a1, $a2, $s1, $s2, $ml2, $pf"
                           JD="done"
                              break
                      fi
                      if [ "$JD" == "done" ] ; then
                          break
                      fi
                    done
                    if [ "$JD" == "done" ] ; then
                        break
                    fi
                  done
                  if [ "$JD" == "done" ] ; then
                      break
                  fi
                done
                if [ "$JD" == "done" ] ; then
                    break
                fi
            done
                  if [ "$JD" == "done" ] ; then
                      break
                  fi
            done
                if [ "$JD" == "done" ] ; then
                    break
                fi
          done
                  if [ "$JD" == "done" ] ; then
                      break
                  fi
        done
                  if [ "$JD" == "done" ] ; then
                      break
                  fi
      done
                if [ "$JD" == "done" ] ; then
                    break
                fi
    done
    echo SWEEP INDEX = "$INDEX_MATCH , $FAIL_COUNT failures thus far"   ##  Do NOT OMIT this echo!
                                                                      ## Modify with extreme care!
}

barrier_checks() {
     if [ $OMP_case == "ompbarrier" ] ; then
         itct=`grep -c 'Performing iteration' $outFile`
         if [ $itct != 128 ] ; then
             echo "  F-A-I-L  : only $itct lines were printed vs. 128 expected"
#               fail could go here
         fi 
check8() {
   eight=`grep -cw $1 just128`
   if [ $eight != 8 ] ; then
       echo "For interation $1, there were $eight entries"
#          fail  or miss counter could go here
   fi
# echo DBG  $eight
}
         grep 'Performing iteration' $outFile > just128
         check8 0 just128
         check8 1 just128
         check8 2 just128
         check8 3 just128
         check8 4 just128
         check8 5 just128
         check8 6 just128
         check8 7 just128
         check8 8 just128
         check8 9 just128
         check8 10 just128
         check8 11 just128
         check8 12 just128
         check8 13 just128
         check8 14 just128
         check8 15 just128
         
     fi
}
#    ------------------------------------------------------------
# This subroutine assumes units are not equal. Do early test first or include.
# This would not work passing arguments instead of having names externally defined.
# This does not handle the case of seconds vs. microseconds.
#    ------------------------------------------------------------

matchUnits(){
   I=1
   for U in "us" "ms" "s"
   do
 #                echo $U   starting Loop $INDEX_RUNNING >> Backup-output
 #                echo "I must be defined $I, yes?" >> Backup-output
      if [ $U == "$saveSimU" ] ; then 
         saveN=${I}
 #                echo $saveSimU yields ${I} >> Backup-output
      fi 
      if [ $U == "$nowSimU" ] ; then 
         nowN=${I}
 #                echo $nowSimU yields ${I} >> Backup-output
      fi 
      I=$(( $I + 1 ))
   done
#                echo to compare >> Backup-output
#                echo "nowN is $nowN, saveN is $saveN" >> Backup-output
   if (($saveN > $nowN)) ; then
#                echo "Path one" >> Backup-output
#                echo saveSimT  $saveSimT $saveSimU before >> Backup-output
      saveSimT=`bc <<< $saveSimT*1000`
#                echo saveSimT  $saveSimT After >> Backup-output
      commonU=$nowSimU
   else
#                echo "Path two" >> Backup-output
#                echo nowSimT  $nowSimT $nowSimU before >> Backup-output
      nowSimT=`bc <<< $nowSimT*1000`
#                echo nowSimT  $nowSimT After >> Backup-output
      commonU=$saveSimU

   fi
#                echo compare over >> Backup-output
#                echo $commonU  >> Backup-output
}


#     ---------------------------------------------------------------
#         End of Subroutines
#     ---------------------------------------------------------------


#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#     ---------------------------------------------------------------
#
#     Shunit2 runs as many tests as there are subroutines starting with "test".  
#     However, when names duplicate, it re-invokes that last one.
#     The following section insures that we have the correct number of tests.
#     The complexity automatically allows for (1) changing the sweep loops, 
#     (2) rerunning the test without reverting the test Suite.
#
#     ---------------------------------------------------------------
if [ $DO_SP_LIST == "yes" ] ; then
    SWEEP_WIDTH=$nCASES
else
    INDEX_RUNNING=0
    SWEEP_WIDTH=`do_sweep | grep SWEEP.INDEX | awk '{print $4}'`
fi
echo  SWEEP WIDTH $SWEEP_WIDTH

rm -f $SST_TEST_SUITES/testopenMP/__testlist

I=1
while [ $I -lt $SWEEP_WIDTH ]
do
   echo "test_dirSweep() { echo This is Dummy subroutine ; }" >> $SST_TEST_SUITES/testopenMP/__testlist
   I=$(( $I + 1 ))
done

  wc $SST_TEST_SUITES/testopenMP/__testlist

INDEX_RUNNING=0
iCASE=0

#===============================================================================
#     Subroutine to run many of the tests without reproducing the script.
#      First parameter is the name of the test, must match test_dir_<name>()
#      Second parameter is the execution cycle tolerance in hundredths of a
#         percent.   (5% therefore is 9000.)
#      Special case:  if second parameter is "lineWordCt",
#                          accept a line/word count match.
#     ---------------------------------------------------------------
#
#        Begin the template, which is mostly just like a standard openMP test.
#            It does bump the index, INDEX_RUNNING, which marches thru cases.
#
#     ---------------------------------------------------------------
Dir_Template() {
Tol=9000    ##  curTick tolerance,  or  "lineWordCt" 

    if [ $DO_SP_LIST == "yes" ] ; then
        INDEX_RUNNING=${CASES[$iCASE]}
        iCASE=$(($iCASE+1))
    else
        INDEX_RUNNING=$(($INDEX_RUNNING+1))
    fi
    startSeconds=`date +%s`

    sutArgs=$SST_TEST_ROOT/testSuites/testopenMP/sweepdirectory-8cores-2nodes.py

    L_TESTFILE+=(${testDataFileBase})

    sut="${SST_TEST_INSTALL_BIN}/sst"

           ##  do_sweep increaments through the values of eight
           ##  parameters being swept.   The python input file has been 
           ##  modified to receive these values as parameters.

    do_sweep

    # Add basename to list for XML processing later
#                             OMP_case get defined in do_sweep
    testDataFileBase="test_dirSweep_$OMP_case"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}${INDEX_RUNNING}.out"
    tmpFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.tmp"
    wrkFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.wrk"
    referenceFile="${SST_TEST_REFERENCE}/test_OMP_${OMP_case}.out"
    export OMP_EXE=${OMP_case}/${OMP_case}.x

    cd $TEST_SUITE_ROOT/testopenMP
     

    if [ -f $OMP_case/$OMP_case.x ]
    then
        (${sut} ${sutArgs} --model-options "--L1cachesz=\"$s1\" --L2cachesz=\"$s2\" --L1assoc=$a1 --Replacp=$r --L2assoc=$a2 --L2MSHR=$ml2 --MSIMESI=$c --Pref1=$pf --Pref2=$pf" > ${outFile})
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
             echo ' '; echo WARNING: No. $INDEX_RUNNING sst did not finish normally ; echo ' '
             wc $outFile
             sed 15q $outFile
             echo '            . . . '
             tail -15 $outFile
             FAIL_COUNT=$(($FAIL_COUNT+1))
             fail "WARNING: No. $INDEX_RUNNING sst did not finish normally, RetVal=$RetVal"
             barrier_checks
             endSeconds=`date +%s`
             echo " "
             elapsedSeconds=$(($endSeconds -$startSeconds))
             echo "${OMP_case}: Wall Clock Time  $elapsedSeconds sec. $c, $r, $a1, $a2, $s1, $s2, $ml2, $pf"
             return
        fi

if [ -s "$referenceFile" ] && [ "$(tail -c1 "$referenceFile"; echo x)" != $'\nx' ] ; then
    echo >> $referenceFile
fi

grep 'Simulation is complete' $outFile

barrier_checks

matchFail=0
matchct=0
while read -u 3 line 
do
   ## check for curTick   
   ##   This is a memHierarchy test.
   ##    memHierarchy tests ignore curTick!
   ##
   if [[ $line == *curTick* ]] ; then
                     lref=`cat ${referenceFile} | grep curTick |awk -F= '{print $2}' |awk '{print $1}'`
                     lout=`cat ${outFile} | grep curTick |awk -F= '{print $2}' |awk '{print $1}'`
                     if [ "$lref" == "" ]
                     then
                         echo "    No curTick found in Reference File"
                     fi
                     perc=`checkPerCent $lref $lout` 
                     val=`pc100 $perc` 
                     perc=${perc#-}              ## remove minus, if it exists
                     if [ $perc -lt $Tol ] 
                     then
                         echo curTick $lout vs. Ref $lref,  $val  percent $OMP_case
                     else
                         echo Ignoring curTick $lout vs. Ref $lref, $val  percent $OMP_case
                     fi
    elif [ "$line" == "" ] ; then
         #  Do nothing
         echo
    else
       ct=`grep -cw "$line" $referenceFile`
       if [ "$ct" == 0 ] ; then
           echo "OPPS   grep can't handle this line:"
           echo ">> $line <<"
           echo Ignoring
       fi
    
       outct=`grep -cw "$line" $outFile`
       if [ $outct == $ct ] ; then
           matchct=$(($matchct+1))
       else
           echo "No match for reference file line: $line : $outct vs. $ct"
           matchFail=$(($matchFail+1))
       fi 
   fi 
done 3< $referenceFile

        echo "                $matchct lines matched  for $OMP_case" 
        if [ $matchFail != 0 ] ; then
           fail " $MatchFail lines of Reference file not matched exactly"
           FAIL_COUNT=$(($FAIL_COUNT+1))
        fi

        endSeconds=`date +%s`
        echo " "
        elapsedSeconds=$(($endSeconds -$startSeconds))
        echo "${OMP_case}: Wall Clock Time  $elapsedSeconds sec. $c, $r, $a1, $a2, $s1, $s2, $ml2, $pf"

        if [ $(($INDEX_RUNNING % 2 )) == 1 ] ; then
            saveWall=$elapsedSeconds
            saveSimT=`grep simulated.time $outFile | awk '{ print $6}'`
            saveSimU=`grep simulated.time $outFile | awk '{ print $7}'`
            saveInd=$(( $INDEX_RUNNING + 1 ))
        elif [ $saveInd == $INDEX_RUNNING ] ; then
            nowSimT=`grep simulated.time $outFile | awk '{ print $6}'`
            nowSimU=`grep simulated.time $outFile | awk '{ print $7}'`
            if [ $saveSimU != $nowSimU ] ; then
                echo UNIT ISSUE s, ms, us 
                echo UNIT ISSUE s, ms, us >> Backup-output

# This does not handle the case of seconds vs. microseconds.
                matchUnits                #  Call subroutine to match units

            else
                commonU=$saveSimU
            fi

            sW=$(( $elapsedSeconds - $saveWall ))
            sT=`bc <<< $nowSimT-$saveSimT`
            pC=`echo "scale=2;100*${sT}/${nowSimT}" | bc`

            echo $sT | grep -e '-' > /dev/null 
            if [ $? !=  0 ] ; then
                echo " $INDEX_RUNNING  $sW Sec.  $sT $commonU Shorter with preFetcher ${pC}%"
                SHORTER_COUNT=$(($SHORTER_COUNT+1))
            else 
                sT=`bc <<< $saveSimT-$nowSimT`
                pC=`echo "scale=2;100*${sT}/${nowSimT}" | bc`
                echo " $INDEX_RUNNING  $sW Sec.  $sT $commonU LONGER  with preFetcher ${pC}%"
                LONGER_COUNT=$(($LONGER_COUNT+1))
            fi
        fi
    else
        echo "testSuite: ERROR no binary found for $OMP_case"
        FAIL_COUNT=$(($FAIL_COUNT+1))
        fail "testSuite: ERROR no binary found for $OMP_case"
    fi
    if [ $INDEX_RUNNING == $SWEEP_WIDTH ] ; then
        echo ' '
        echo "     $SHORTER_COUNT Shorter and $LONGER_COUNT Longer with prefetcher"
        echo ' ' 
    fi
}
#     ---------------------------------------------------------------
#        End of template
#     ---------------------------------------------------------------

# Build Test app
##    The following code already explictly assume we're at trunk
  
cd $TEST_SUITE_ROOT/testopenMP
    
./buildall.sh 

#     ---------------------------------------------------------------
  

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#     ---------------------------------------------------------------
#
#        The Real test subroutine, which will be executed multiple times.
#        Add to __testlist.  The correct number of dummy test are there already.
#     ---------------------------------------------------------------

#
#     dirSweep
#
cat >> $SST_TEST_SUITES/testopenMP/__testlist << ..EOF..
test_dirSweep() {    
Dir_Template $selectBin 9000
}
..EOF..

echo $LINENO   Ready to call shunit2

##   Time limit SST_TEST_ONE_TEST_TIMEOUT is set near line 65

export SHUNIT_DISABLE_DIFFTOXML=1
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2 $SST_TEST_SUITES/testopenMP/__testlist)

    
