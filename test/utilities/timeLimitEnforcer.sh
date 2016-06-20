##   Default time out is set to 1800 seconds (30 minutes) per test.
##   This can be Globally changed by setting the Environment variable
##   This can be Locally changed for an entire Suite by exporting the
##      environment variable from in that Suite before shunit2 is invoked.

if [[ ${SST_TEST_ONE_TEST_TIMEOUT:+isSet} != isSet ]] ; then
    SST_TEST_ONE_TEST_TIMEOUT=1800         # 30 minutes 1800 seconds
fi
SST_TEST_ONE_TEST_TIMEOUT=3
CASE=$2

sleep $SST_TEST_ONE_TEST_TIMEOUT 

echo ' ' ; echo "TL Enforcer:            TIME LIMIT     $CASE "
echo "TL Enforcer: test has exceed alloted time of $SST_TEST_ONE_TEST_TIMEOUT seconds."
MY_PID=$$
TIME_FLAG=/tmp/TimeFlag_${1}_${MY_PID}
echo $SST_TEST_ONE_TEST_TIMEOUT >> $TIME_FLAG
chmod 777 $TIME_FLAG
echo "         Create Time Limit Flag file, $TIME_FLAG"

echo I am $MY_PID,  I was called from $1, my parent PID is $PPID

date
echo ' '

KILL_PID=`ps -ef | grep 'sst ' | grep $PPID | awk '{ print $2 }'`

if [ -z $KILL_PID ] ; then
    echo I am $MY_PID,  I was called from $1, my parent PID is $PPID
    echo "No corresponding child named \"sst\" "
    ps -f | grep $PPID
    echo ' '
    #   Is there a Python running from the Parent PID
    echo " Look for a child named \"python\""
    PY_PID=`ps -ef | grep 'python ' | grep $PPID | awk '{ print $2 }'`
    if [ -z $PY_PID ] ; then
        echo "No corresponding child named \"python\" "
        echo ' '
    fi
    KILL_PID=$PY_PID
fi

ps -f -p $KILL_PID | grep $KILL_PID
if [ $? == 1 ] ; then
    echo " Can not find process to terminate,  pid = $KILL_PID "
    echo "     I am $MY_PID,   my parent was $PPID" 
    ps -f U $USER
    echo ' '
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
        ps -f U $USER
        echo " Try a \"kill -9\"  "
        kill -9 $KILL_PID
    fi
fi
ps -f -p $KILL_PID | grep $KILL_PID
if [ $? == 0 ] ; then
    echo " It's still there!  ($KILL_PID)"
    echo " Try a \"kill -9\" "
    kill -9 $KILL_PID
fi
