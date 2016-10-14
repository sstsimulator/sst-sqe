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

if [[ ${SST_TEST_TIMEOUT_OVERRIDE:+isSet} == isSet ]] ; then
    SST_TEST_ONE_TEST_TIMEOUT=$SST_TEST_TIMEOUT_OVERRIDE
fi 

sleep $SST_TEST_ONE_TEST_TIMEOUT 

echo ' ' ; echo "TL Enforcer:            TIME LIMIT     $CASE "
echo "TL Enforcer: test has exceed alloted time of $SST_TEST_ONE_TEST_TIMEOUT seconds."
MY_PID=$$
TIME_FLAG=/tmp/TimeFlag_${1}_${MY_PID}
echo $SST_TEST_ONE_TEST_TIMEOUT >> $TIME_FLAG
chmod 777 $TIME_FLAG
echo "         Create Time Limit Flag file, $TIME_FLAG"

echo ' '
echo I am $MY_PID,  I was called from $1, my parent PID is $PPID
ps -f -p ${1},${PPID}
echo ' '

ps -f | grep ompsievetest
echo " this might better go in the Suite"
ps -f | grep ompsievetest | grep -v -e grep > omps_list
wc omps_list
while read -u 3 _who _anOMP _own _rest
do
    if [ $_own == 1 ] ; then
        echo " Attempt to remove $_anOMP "
        kill -9 $_anOMP
    fi
done 3<omps_list

OMP_PID=`ps -f | awk '{print $1,$2,$3,$4,$5,$6,$7,$8}' | grep ompsievetest | grep -v -e grep | awk '{print $2}'`
echo "OMP_PID = $OMP_PID"
if [ ! -z $OMP_PID ] ; then
echo " Line $LINENO   -- kill ompsievetest "
    kill -9 $OMP_PID
fi

date
echo ' '
#
#          Begin findChild() subroutine
#
findChild()
{
   SPID=$1
   
   KILL_PID=`ps -ef | grep 'sst ' | grep $SPID | awk '{ print $2 }'`
   
   if [ -z $KILL_PID ] ; then
       echo I am $MY_PID,  I was called from $1, my parent PID is $PPID
       echo "No corresponding child named \"sst\" "
       ps -f | grep $SPID
       echo ' '
       #   Is there a Python running from the Parent PID
       echo " Look for a child named \"python\""
       PY_PID=`ps -ef | grep 'python ' | grep $SPID | awk '{ print $2 }'`
       if [ -z $PY_PID ] ; then
           echo "No corresponding child named \"python\" "
           echo ' '
           #   Is there a Valgrind running from the Parent PID
           echo " Look for a child named \"valgrind\""
           VG_PID=`ps -ef | grep 'valgrind ' | grep $SPID | awk '{ print $2 }'`
           if [ -z $VG_PID ] ; then
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

findChild $PPID


if [ -z $KILL_PID ] ; then
#
#          Look for child of my siblings
#
   ps -ef > full_ps__
    while read -u 3 _who _task _paren _rest
    do
       if [ $_paren != $PPID ] ; then
          continue
       fi 
       if [ $_task == $MY_PID ] ; then
          continue
       fi 
    
       echo "Sibling is $_task"
       findChild $_task
       break
    done 3< full_ps__
fi

echo Kill pid is $KILL_PID

KILL_PARENT=0
if [ -z $KILL_PID ] ; then
    KILL_PARENT=1
else
    ps -f -p $KILL_PID | grep $KILL_PID
    if [ $? == 1 ] ; then
        KILL_PARENT=1
    fi
fi
if [ $KILL_PARENT == 1 ] ; then
    echo " Can not find process to terminate,  pid = $KILL_PID "
    echo "     I am $MY_PID,   my parent was $PPID" 
    ps -f -U $USER
    echo ' '
    echo "                EXIT without killing my parents "
    exit               ###################################################3
    echo "kill my parents"
    kill -9 $1
    kill -9 $PPID
    exit
else

    kill $KILL_PID
#                     Believe I remember that this always return zero
    if [ $? == 1 ] ; then
        echo " Kill of $KILL_PID for TIME OUT   FAILED"
        echo "     I am $MY_PID,   my parent was $PPID" 
        ps -f -U $USER
        echo " Try a \"kill -9\"  "
        kill -9 $KILL_PID
    fi
fi
ps -f -p $KILL_PID | grep $KILL_PID
if [ $? == 0 ] ; then
    echo " It's still there!  ($KILL_PID)"
    echo " Try a \"kill -9\" "
    kill -9 $KILL_PID
ps -f -p $KILL_PID | grep $KILL_PID
fi
