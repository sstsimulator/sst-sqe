        echo "This is the MacOS (Darwin)  path with pstree "

date
echo ' '

   echo "                                      STARTING PID $TL_CALLER"
   ps -fp $TL_CALLER
   pstree -p $TL_CALLER 
   pstree -p $TL_CALLER | sed 's/--=/-=-/' | awk -F'- ' '{print $2}' > raw-list
   cat raw-list | awk '{print $1, "/", $3}' | awk -F/ '{print $1 $NF}' > display-file
   echo " Display File "
   cat display-file

   while read -u 3 _tokill _name _rest
   do
       echo $_name | grep -w -e sst -e pinbin -e ompsievetest
       if [ $? == 0 ] ; then
          echo Task to be killed $_tokill $_name 
          kill -9 $_tokill
       fi
   done 3< display-file

echo   "this is for a Sanity check -- Not required(?)"

   pstree -p $TL_CALLER 
echo   "This was for a Sanity check -- Not required"

    MPIRUN_PID=`grep mpirun display-file | awk '{print $1}'`
    ps -f -p $MPIRUN_PID > ttt ; grep mpirun ttt
    if [ $? == 0 ] ; then
       echo " the pid of the mpirun is $MPIRUN_PID "
       kill -9 $MPIRUN_PID
    fi 

exit       #  END FOR NOW   ######################################

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
    
    touch $SST_ROOT/test/testOutputs/dummy
    grep -i signal $SST_ROOT/test/testOutputs/*
    grep -i CurrentSimCycle $SST_ROOT/test/testOutputs/*
    echo " ###############################################################"
fi


echo ' '
#   -----          Invoke the traceback routine  ----- "
    ps -f -p $KILL_PID > ttt ; grep mpirun ttt
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
