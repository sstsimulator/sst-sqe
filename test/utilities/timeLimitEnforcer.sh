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
ps -f -p ${TL_MY_PID},${TL_CALLER},${TL_PPID}
echo ' '
echo "  NODE NAME is $NODE_NAME"
touch ttt       # empty greps

if [ "$SST_TEST_HOST_OS_KERNEL" != "Darwin" ] ; then    ######   LINUX #####

    . $SST_ROOT/test/include/TimeLimit-Linux.sh

else    ###   This is the El Capitan  (pstree path)      ####    macOS 

    . $SST_ROOT/test/include/TimeLimit-MacOS.sh

fi ####   End of El Capitan  pstree path
echo "        End of TL Enforcer   - - -  $CASE "
