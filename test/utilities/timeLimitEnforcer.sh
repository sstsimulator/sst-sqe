##   Default time out is set to 1800 seconds (30 minutes) per test.
##   This can be Globally changed by setting the Environment variable
##   This can be Locally changed for an entire Suite by exporting the
##      environment variable from in that Suite before shunit2 is invoked.

if [[ ${SST_TEST_ONE_TEST_TIMEOUT:+isSet} != isSet ]] ; then
    SST_TEST_ONE_TEST_TIMEOUT=1800         # 30 minutes 1800 seconds
fi
CASE=$2

sleep $SST_TEST_ONE_TEST_TIMEOUT 

MY_PID=$$
## echo I am $MY_PID,  I was called from $1, my parent PID is $PPID

echo ' ' ; echo "            TIME LIMIT     $CASE "
echo test has exceed alloted time of $SST_TEST_ONE_TEST_TIMEOUT seconds.
date
echo ' '

SSTX_PID=`ps -ef | grep 'sst ' | grep $PPID | awk '{ print $2 }'`

if [ -z $SSTX_PID ] ; then
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
    SSTX_PID=`ps -ef | grep 'sst ' | grep $PY_PID | awk '{ print $2 }'`
fi
ps -f -p $SSTX_PID | grep $SSTX_PID

if [ $? == 1 ] ; then
    echo " Can not find SST to terminate,  pid = $SSTX_PID "
    echo "     I am $MY_PID,   my parent was $PPID" 
    ps -f U $USER
else

    kill $SSTX_PID
#                     Believe I remember that this always return zero
    if [ $? == 1 ] ; then
        echo " Kill of $SST_PIDX for TIME OUT   FAILED"
        echo "     I am $MY_PID,   my parent was $PPID" 
        ps -f U $USER
        echo " Try a \"kill -9\"  "
        kill -9 $SSTX_PID
    fi
fi
ps -f -p $SSTX_PID | grep $SSTX_PID
if [ $? == 0 ] ; then
    echo " It's still there!  ($SSTX_PID)"
    echo " Try a \"kill -9\" "
    kill -9 $SSTX_PID
fi
