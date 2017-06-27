##   timeLimitEnforcer.sh

. $SST_ROOT/test/include/testSubroutines.sh

##   Default time out is set to 1800 seconds (30 minutes) per test.
##   This can be Globally changed by setting the Environment variable
##   This can be Locally changed for an entire Suite by exporting the
##      environment variable from in that Suite before shunit2 is invoked.
##   September 2016: most Suites set it; thus over-riding the Environment
##      value.  The utility that inserts Valgrind in things, jams a
##      value directly in here, over riding the Suite.
##   The new environment variable, SST_TEST_TIMEOUT_OVERRIDE, trumps all. 
              
if [[ ${SST_TEST_ONE_TEST_TIMEOUT:+isSet} != isSet ]] ; then
    SST_TEST_ONE_TEST_TIMEOUT=1800         # 30 minutes 1800 seconds
fi
CASE=$2

####                    The OverRide
if [[ ${SST_TEST_TIMEOUT_OVERRIDE:+isSet} == isSet ]] ; then
    SST_TEST_ONE_TEST_TIMEOUT=$SST_TEST_TIMEOUT_OVERRIDE
fi 

startSeconds=`date +%s`
####                    The Sleep
sleep $SST_TEST_ONE_TEST_TIMEOUT 

echo ' ' ; echo "TL Enforcer:            TIME LIMIT     $CASE "
endSeconds=`date +%s`
elapsedSeconds=$(($endSeconds -$startSeconds))
echo "TL Enforcer: awakened after $elapsedSeconds seconds."

export TL_MY_PID=$$
export TL_PPID=$PPID
export TL_CALLER=$1

####                     The Time Limit flag
TIME_FLAG=/tmp/TimeFlag_${1}_${TL_MY_PID}
echo $SST_TEST_ONE_TEST_TIMEOUT >> $TIME_FLAG
chmod 777 $TIME_FLAG
echo "         Create Time Limit Flag file, $TIME_FLAG"

echo ' '
echo I am $TL_MY_PID,  I was called from $TL_CALLER, my parent PID is $TL_PPID
ps -f -p ${1},${TL_PPID}
echo ' '

date
echo ' '
#          Prooced to attempt the kill
#
#          Begin findChild() subroutine
#
findChild()
{
   SPID=$1
   if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin" ] ; then
       KILL_PID=`ps -ef | grep 'sst ' | grep $SPID | awk '{ print $2 }'`
   else
       KILL_PID=`ps -f | grep 'sst ' | grep $SPID | awk '{ print $2 }'`
   fi

   if [ -z "$KILL_PID" ] ; then
echo "------------------   Debug ------/$SPID is $SPID -------"
   ps -ef | grep bin/sst
echo "------------------   Debug -------------"
       KILL_PID=`ps -ef | grep bin/sst  | grep $SPID | awk '{ print $2 }'`
   fi
      
   if [ -z "$KILL_PID" ] ; then
       echo I am $TL_MY_PID,  findChild invoked with $1, my parent PID is $TL_PPID
       echo "No corresponding child named \"sst\" "
       ps -f | grep $SPID
       echo ' '
       #   Is there a Python running from the Parent PID
       echo " Look for a child named \"python\""
       PY_PID=`ps -ef | grep 'python ' | grep $SPID | awk '{ print $2 }'`
       if [ -z "$PY_PID" ] ; then
           echo "No corresponding child named \"python\" "
           echo ' '
           #   Is there a Valgrind running from the Parent PID
           echo " Look for a child named \"valgrind\""
           VG_PID=`ps -ef | grep ' valgrind ' | grep $SPID | awk '{ print $2 }'`
           if [ -z "$VG_PID" ] ; then
               echo "No corresponding child named \"valgrind\" "
               echo ' '
           else
               KILL_PID=$VG_PID
           fi
       else
           KILL_PID=$PY_PID
       fi
   fi
}   
#
#          End findChild() subroutine
#

echo " ###############################################################"
echo "  JOHNS sanity check"
ps -ef | grep bin/sst | grep -v grep 
echo " ----------- first"
ps -ef | grep bin/sst | grep -v grep | grep -v mpirun | sed 1q
echo " ----------- all  "
ps -ef | grep bin/sst | grep -v grep | grep -v mpirun 
ps -ef | grep bin/sst | grep -v grep | grep -v mpirun | sed 1q | awk '{ print $2 }'
if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin" ] ; then
    SST_PID=`ps -ef | grep bin/sst | grep -v grep | grep -v mpirun | sed 1q | awk '{ print $2 }'`
    MPIRUN_PID=`ps -ef | grep bin/sst | grep -v grep | grep -v mpirun | sed 1q | awk '{ print $3 }'`
else       # - LINUX -
    SST_PID=`ps -f | grep -e bin/sst -e ' sst' -e sstsim.x | grep -v grep | grep -v mpirun | sed 1q | awk '{ print $2 }'`
    MPIRUN_PID=`ps -f | grep -e bin/sst -e ' sst' -e sstsim.x | grep -v grep | grep -v mpirun | sed 1q | awk '{ print $3 }'`
fi
echo " the pid of an sst is $SST_PID "
echo " the pid of the mpirun is $MPIRUN_PID "

if [[ ${SST_MULTI_CORE:+isSet} == isSet ]] ; then
    echo " Check for Dead Lock"
    kill -USR1 $SST_PID
    sleep 1
    kill -USR1 $SST_PID
    
    grep -i signal $SST_ROOT/test/testOutputs/*
    grep -i CurrentSimCycle $SST_ROOT/test/testOutputs/*
    echo " ###############################################################"
fi

findChild $TL_PPID


if [ -z "$KILL_PID" ] ; then
#
#          Look for child of my siblings
#
   ps -ef > full_ps__
    while read -u 3 _who _task _paren _rest
    do
       if [ $_paren != $TL_PPID ] ; then
          continue
       fi 
       if [ $_task == $TL_MY_PID ] ; then
          continue
       fi 
    
       echo "Sibling is $_task"
       findChild $_task
       break
    done 3< full_ps__
fi

echo Kill pid is $KILL_PID

echo ' '
#   -----          Invoke the traceback routine  ----- "
    ps -f -p $KILL_PID | grep mpirun
    if [ $? == 0 ] ; then
        TRACEBACK_PARAM="--mpi $MPIRUN_PID"
    else
        TRACEBACK_PARAM=$KILL_PID
    fi
#          Invoke the traceback routine
echo "          Invoke the traceback routine "

echo "\$SST_ROOT/test/utilities/stackback.py $TRACEBACK_PARAM" ; echo
$SST_ROOT/test/utilities/stackback.py $TRACEBACK_PARAM

echo ' '
date
echo "   Return to timeLimitEnforcer"
echo ' '

kill $KILL_PID
#                     Believe I remember that this always return zero
if [ $? == 1 ] ; then
    echo " Kill of $KILL_PID for TIME OUT   FAILED"
    echo "     I am $TL_MY_PID,   my parent was $TL_PPID" 
    ps -f -U $USER
    echo " Try a \"kill -9\"  "
    kill -9 $KILL_PID
fi
ps -f -p $KILL_PID | grep $KILL_PID
if [ $? == 0 ] ; then
    echo " It's still there!  ($KILL_PID)"
ps -ef | grep ompsievetest
    echo " Try a \"kill -9\" "
    kill -9 $KILL_PID
ps -f -p $KILL_PID | grep $KILL_PID
ps -ef | grep ompsievetest
    Remove_old_ompsievetest_task
ps -ef | grep ompsievetest
fi
