      echo "$LINENO - This is TimeLimit-Linux"
      date
      echo ' '
#          Proceed to attempt the kill
#
#          Begin findChild() subroutine
#
findChild()
{
   SPID=$1
       KILL_PID=`ps -f | grep 'sst ' | grep $SPID | awk '{ print $2 }'`

   if [ -z "$KILL_PID" ] ; then
echo "$LINENO findChild -  - ------------------   Debug ------\$SPID is $SPID -------"
   ps -ef | grep 'bin/sst '
echo "$LINENO findChild -  - ------------------   Debug -------------"
       KILL_PID=`ps -f | grep 'bin/sst '  | grep $SPID | awk '{ print $2 }'`
   fi
      
   if [ -z "$KILL_PID" ] ; then
       echo "$LINENO findChild -  - I am $TL_MY_PID,  findChild invoked with $1, my parent PID is $TL_PPID"
       echo "$LINENO findChild -  - No corresponding child named \"sst\" "
       ps -f | grep $SPID
       echo ' '
       #   Is there a Python running from the Parent PID
       echo "$LINENO findChild -  -  Look for a child named \"python\""
       PY_PID=`ps -f | grep 'python ' | grep $SPID | awk '{ print $2 }'`
       if [ -z "$PY_PID" ] ; then
           echo "$LINENO findChild -  - No corresponding child named \"python\" "
           echo ' '
           #   Is there a Valgrind running from the Parent PID
           echo "$LINENO findChild -  -  Look for a child named \"valgrind\""
           VG_PID=`ps -f | grep ' valgrind ' | grep $SPID | awk '{ print $2 }'`
           if [ -z "$VG_PID" ] ; then
               echo "$LINENO findChild -  - No corresponding child named \"valgrind\" "
               echo ' '
           else
               echo "$LINENO findChild -  - wc from \"ps -fe\" `ps -fe | wc` "
               echo "$LINENO findChile -  - There is no pid for SST! !"
               
               echo "$LINENO findChild -  - at line $LINENO,  kill Valgrind $VG_PID"
               kill -9 $VG_PID
               echo "$LINENO findChild -  - kill issued"
               echo "$LINENO findChild -  - wc from \"ps -fe\" `ps -fe | wc` "
               echo ' '
               echo "$LINENO findChild -  -    -- Time Limit Processing is done"
               exit    
           fi
       else
           KILL_PID=$PY_PID
       fi
   fi
}   
#
#          End findChild() subroutine
#

    echo "$LINENO -  ###############################################################"
    MY_TREE=`pwd | awk -F 'devel/trunk' '{print $1 }'`
    echo "$LINENO - DEBUG?   MY_TREE is $MY_TREE "
    echo "$LINENO -   JOHNS sanity check   --  all bin/sst"
    ps -ef | grep 'bin/sst ' | grep -v grep 
    echo "$LINENO -  ----------- all  "
    ps -f | grep 'bin/sst ' | grep -v grep | grep -v mpirun 
    ps -f | grep 'bin/sst ' | grep -v grep | grep -v mpirun | sed 1q | awk '{ print $2 }'
    echo "$LINENO -       finding SST_PID and MPIRUN_PID"
    ps -f | grep -e 'bin/sst ' -e sstsim.x | grep -v grep | grep -v mpirun
    SST_PID=`ps -f | awk '{print $1,$2,$3,$4,$5,$6,$7,$8," "}' | \
                   grep -e 'bin/sst ' -e sstsim.x | grep -v grep | \
                   grep -v mpirun | grep $MY_TREE | sed 1q | awk '{ print $2 }'`
    SSTPAR_PID=`ps -f | awk '{print $1,$2,$3,$4,$5,$6,$7,$8," "}' | \
                   grep -e 'bin/sst ' -e sstsim.x | grep -v grep | \
                   grep -v mpirun | grep $MY_TREE | sed 1q | awk '{ print $3 }'`
echo "$LINENO -  ################################ temporary    SSTPAR= $SSTPAR_PID. TL_PPID= $TL_PPID"
    if [ -z $SSTPAR_PID ] || [ "$SSTPAR_PID" == $TL_PPID ] ; then
       echo "$LINENO -  No mpirun as parent of sst"
       MPIRUN_PID=0
    else
       ps -f -p $SSTPAR_PID > ttt ; grep mpirun ttt
       if [ 0 == $? ] ; then
           MPIRUN_PID=$SSTPAR_PID
           echo "$LINENO -  the pid of the mpirun is $MPIRUN_PID "
       else 
           echo "$LINENO - SST parent is not mpirun"
           ps -f -p $SSTPAR_PID
           MPIRUN_PID=0
       fi
    fi
    echo "$LINENO -  the pid of an sst is $SST_PID "
    
    if [ $MPIRUN_PID -eq 0 ] ; then
        KILL_PID=$SST_PID
    else
        KILL_PID=$MPIRUN_PID
    fi
    
    if [[ ${SST_MULTI_CORE:+isSet} == isSet ]] && [[ ${SST_PID:+isSet} == isSet ]] ; then
        echo "$LINENO -  Check for Dead Lock"
        kill -USR1 $SST_PID
        sleep 1
        kill -USR1 $SST_PID
        
        touch $SST_ROOT/test/testOutputs/${CASE}dummy
        grep -i signal $SST_ROOT/test/testOutputs/${CASE}*
        grep -i CurrentSimCycle $SST_ROOT/test/testOutputs/${CASE}*
        echo "$LINENO -  ###############################################################"
    fi
    
    if [ -z $KILL_PID ] ; then
        findChild $TL_PPID
        if [ ! -z $KILL_PID ] ; then
            echo found KILL_PID $KILL_PID
            ps -f -p $KILL_PID
        fi
    fi 
    
    
    if [ -z "$KILL_PID" ] ; then
    #
    #          Look for child of my siblings
    #
       ps -f > full_ps__
        while read -u 3 _who _task _paren _rest
        do
           if [ $_paren != $TL_PPID ] ; then
              continue
           fi 
           if [ $_task == $TL_MY_PID ] ; then
              continue
           fi 
        
           echo "$LINENO - Sibling is $_task"
           findChild $_task
           break
        done 3< full_ps__
    fi
    
    echo "$LINENO - Kill pid is $KILL_PID"
    #                     The following code assumes Kill pid is set
    #                            and never sets it
    
    if [ -z "$KILL_PID" ] ; then
        echo "$LINENO - Failed to define a KILL_PID "
        echo "$LINENO -    The timeLimitEnforcer has fail!   "
        exit
    else
        #   -----          Invoke the traceback routine  ----- "
            ps -f -p $KILL_PID > ttt ; grep mpirun ttt
            if [ $? == 0 ] ; then
                TRACEBACK_PARAM="--mpi $MPIRUN_PID"
            else
                TRACEBACK_PARAM=$KILL_PID
            fi
        #          Invoke the traceback routine
        date
        echo "$LINENO -    Invoke the traceback routine  ---- $CASE"
        
        echo "$LINENO - \$SST_ROOT/test/utilities/stackback.py $TRACEBACK_PARAM" ; echo
        $SST_ROOT/test/utilities/stackback.py $TRACEBACK_PARAM
        
        echo ' '
        date
        echo "$LINENO -    Return to timeLimitEnforcer"
        echo ' '
        
        echo "$LINENO -   tLE ==== $LINENO   KILL_PID is $KILL_PID"
        kill $KILL_PID
        #                     Believe I remember that this always return zero
        if [ $? == 1 ] ; then
            echo "$LINENO -  Kill of $KILL_PID for TIME OUT   FAILED"
            echo "$LINENO -      I am $TL_MY_PID,   my parent was $TL_PPID" 
            ps -f -U $USER
            echo "$LINENO -  Try a \"kill -9\"  "
            kill -9 $KILL_PID
        fi
        echo "$LINENO -   tLE ==== $LINENO   "
        ps -f -p $KILL_PID > ttt ; grep $KILL_PID ttt
        if [ $? == 0 ] ; then
 echo $LINENO       
            echo "$LINENO -  It is still there!  KILL_PID = $KILL_PID"
 echo $LINENO
            echo "$LINENO -   tLE ==== $LINENO   "
            ps -ef | grep ompsievetest | grep -v -e grep
            echo "$LINENO -  Try a \"kill -9\" "
            kill -9 $KILL_PID
            echo "$LINENO -   tLE ==== $LINENO   "
            ps -f -p $KILL_PID > ttt ; grep $KILL_PID ttt
        fi
    
        echo "$LINENO -   tLE ==== $LINENO   "
        ps -ef | grep ompsievetest | grep -v -e grep
        echo "$LINENO -   tLE ==== $LINENO   "
        date
        Remove_old_ompsievetest_task
        date
        ps -ef | grep ompsievetest | grep -v -e grep
        echo "$LINENO -   tLE ==== $LINENO   "
    fi
    echo "$LINENO -   tLE ==== $LINENO   Issue the kill of $KILL_PID  "
    kill -9 $KILL_PID
    echo "$LINENO -   tLE ==== $LINENO   "
    ps -ef | grep ompsievetest | grep -v -e grep
    echo "$LINENO -   tLE ==== $LINENO   "
    date
    Remove_old_ompsievetest_task
    date
    ps -ef | grep ompsievetest | grep -v -e grep
    echo "$LINENO -   tLE ==== $LINENO   "
