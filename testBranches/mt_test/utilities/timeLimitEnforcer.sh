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
 echo I am $MY_PID,  I was called from $1, my parent PID is $PPID

echo ' ' ; echo "            TIME LIMIT     $CASE "
echo test has exceed alloted time of $SST_TEST_ONE_TEST_TIMEOUT seconds.
echo ' '

SSTX_PID=`ps -ef | grep 'sst ' | grep $PPID | awk '{ print $2 }'`

ps -f -p $SSTX_PID | grep $SSTX_PID
if [ $? == 1 ] ; then
    echo " Can not find SST to terminate,  pid = $SSTX_PID "
    echo "     I am $MY_PID,   my parent was $PPID" 
    ps -f U $USER
else
echo ' ##################### Before the kill'
ps -f
echo ' '

    SST_CHILD=`ps -f | grep $SSTX_PID | awk -v var=$SSTX_PID '{ if (var==$3) print $2 }'`
    if [ "`cat $SST_CHILD`x" == "x" ] ; then
        CHILD_FOUND=0     # none
    else
        echo SST_CHILD = $SST_CHILD
        ps -p $SST_CHILD
        CHILD_FOUND=1     # yes
    fi
 
    kill -s SIGKILL $SSTX_PID
    if [ $? == 1 ] ; then
        echo " Kill of $SST_PIDX for TIME OUT   FAILED"
        echo "     I am $MY_PID,   my parent was $PPID" 
        ps -f U $USER
    fi

    if [ $CHILD_FOUND == 1 ] ; then
        ps -f -p $SST_CHILD | grep $SST_CHILD
        if [ $? == 0 ] ; then
ps -f | grep stream
            kill -s SIGKILL $SST_CHILD
        fi
    fi

#######   Add package to clean up shared memory
        ipcs | grep $USER > tmp_file__
        ipcsFile=tmp_file__
        while read -r -u 3 key  shmid owner perms bytes nattch rest
        do 
           if [ "$key" == "" ] ; then
              return   
           fi     
           echo $key, $shmid, $owner, $perms, $bytes, $nattch
           if [ "$owner" != $USER ] ; then
               continue
           fi
           if [[ $nattch != 0 ]] ; then
               continue
           fi
           echo "        remove $shmid $owner $nattch"
           ipcrm -m $shmid
        done 3<$ipcsFile
        rm -f tmp_file__
 ###########
fi

