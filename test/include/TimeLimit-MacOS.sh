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

#    Find SST_PID ##################
   while read -u 3 _pid_  _name _rest
   do
       echo $_name | grep -w -e sst 
       if [ $? == 0 ] ; then
          SST_PID=$_pid_
          break
       fi
   done 3< display-file
echo line $LINENO    SST_PID is $SST_PID
ps -p $SST_PID

#   Look for mpirun  ##  MPIRUN_PID
   while read -u 3 _pid_  _name _rest
   do
       echo $_name | grep -w -e mpirun 
       if [ $? == 0 ] ; then
          MPIRUN_PID=$_pid_
          break
       fi
   done 3< display-file
echo line $LINENO    MPIRUN_PID is $MPIRUN_PID
ps -p $MPIRUN_PID
    echo ' '
#   -----          Invoke the traceback routine  ----- "
ps -p $SST_PID
    if [ ! -z $MPIRUN_PID ] ; then
        TRACEBACK_PARAM="--mpi $MPIRUN_PID"
    else
        TRACEBACK_PARAM=$SST_PID
    fi
#          Invoke the traceback routine
    echo "          Invoke the traceback routine "

    echo "\$SST_ROOT/test/utilities/stackback.py $TRACEBACK_PARAM" ; echo
    $SST_ROOT/test/utilities/stackback.py $TRACEBACK_PARAM

echo ' '
date
echo "   Return to timeLimitEnforcer"
echo ' '

    if [[ ${SST_MULTI_CORE:+isSet} == isSet ]] ; then
        echo " Check for Dead Lock"
        kill -USR1 $SST_PID
        sleep 1
        kill -USR1 $SST_PID
        
        touch $SST_ROOT/test/testOutputs/${CASE}dummy
        grep -i signal $SST_ROOT/test/testOutputs/${CASE}*
        grep -i CurrentSimCycle $SST_ROOT/test/testOutputs/${CASE}*
        echo " ###############################################################"
    fi
    

    while read -u 3 _tokill _name _rest
    do
       echo $_name | grep -w -e sst -e pinbin -e ompsievetest -e mpirun
       if [ $? == 0 ] ; then
          echo Task to be killed $_tokill $_name 
          kill -9 $_tokill
       fi
    done 3< display-file

echo   "this is for a Sanity check -- Not required(?)"

    pstree -p $TL_CALLER 
echo   "This was for a Sanity check -- Not required"

