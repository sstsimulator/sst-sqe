      echo "This is the non-Mac path"
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
echo "------------------   Debug ------\$SPID is $SPID -------"
   ps -ef | grep 'bin/sst '
echo "------------------   Debug -------------"
       KILL_PID=`ps -f | grep 'bin/sst '  | grep $SPID | awk '{ print $2 }'`
   fi
      
   if [ -z "$KILL_PID" ] ; then
       echo I am $TL_MY_PID,  findChild invoked with $1, my parent PID is $TL_PPID
       echo "No corresponding child named \"sst\" "
       ps -f | grep $SPID
       echo ' '
       #   Is there a Python running from the Parent PID
       echo " Look for a child named \"python\""
       PY_PID=`ps -f | grep 'python ' | grep $SPID | awk '{ print $2 }'`
       if [ -z "$PY_PID" ] ; then
           echo "No corresponding child named \"python\" "
           echo ' '
           #   Is there a Valgrind running from the Parent PID
           echo " Look for a child named \"valgrind\""
           VG_PID=`ps -f | grep ' valgrind ' | grep $SPID | awk '{ print $2 }'`
           if [ -z "$VG_PID" ] ; then
               echo "No corresponding child named \"valgrind\" "
               echo ' '
           else
               echo "  at line $LINENO,  kill Valgrind $VG_PID"
               ps -f 
#              SST_PID=`ps -f | grep 'sstsim.x ' | grep $VG_PID | grep -v $SPID | awk '{ print $3 }'`
               ps -f | grep 'sstsim.x ' 
               kill -9 $VG_PID
               echo "kill issued"
               ps -f 
               echo "   -- Time Limit Processing is done"
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

    echo " ###############################################################"
    MY_TREE=`pwd | awk -F 'devel/trunk' '{print $1 }'`
    echo  "DEBUG?   MY_TREE is $MY_TREE "
    echo "  JOHNS sanity check   --  all bin/sst"
    ps -ef | grep 'bin/sst ' | grep -v grep 
    echo " ----------- all  "
    ps -f | grep 'bin/sst ' | grep -v grep | grep -v mpirun 
    ps -f | grep 'bin/sst ' | grep -v grep | grep -v mpirun | sed 1q | awk '{ print $2 }'
    echo "      finding SST_PID and MPIRUN_PID"
    ps -f | grep -e 'bin/sst ' -e sstsim.x | grep -v grep | grep -v mpirun
    SST_PID=`ps -f | awk '{print $1,$2,$3,$4,$5,$6,$7,$8," "}' | \
                   grep -e 'bin/sst ' -e sstsim.x | grep -v grep | \
                   grep -v mpirun | grep $MY_TREE | sed 1q | awk '{ print $2 }'`
    SSTPAR_PID=`ps -f | awk '{print $1,$2,$3,$4,$5,$6,$7,$8," "}' | \
                   grep -e 'bin/sst ' -e sstsim.x | grep -v grep | \
                   grep -v mpirun | grep $MY_TREE | sed 1q | awk '{ print $3 }'`
echo " ################################ temporary    SSTPAR= $SSTPAR_PID. TL_PPID= $TL_PPID"
    if [ -z $SSTPAR_PID ] || [ "$SSTPAR_PID" == $TL_PPID ] ; then
       echo " No mpirun as parent of sst"
       MPIRUN_PID=0
    else
       ps -f -p $SSTPAR_PID > ttt ; grep mpirun ttt
       if [ 0 == $? ] ; then
           MPIRUN_PID=$SSTPAR_PID
           echo " the pid of the mpirun is $MPIRUN_PID "
       else 
           echo "SST parent is not mpirun"
           ps -f -p $SSTPAR_PID
           MPIRUN_PID=0
       fi
    fi
    echo " the pid of an sst is $SST_PID "
    
    if [ $MPIRUN_PID -eq 0 ] ; then
        KILL_PID=$SST_PID
    else
        KILL_PID=$MPIRUN_PID
    fi
    
    if [[ ${SST_MULTI_CORE:+isSet} == isSet ]] && [[ ${SST_PID:+isSet} == isSet ]] ; then
        echo " Check for Dead Lock"
        kill -USR1 $SST_PID
        sleep 1
        kill -USR1 $SST_PID
        
        touch $SST_ROOT/test/testOutputs/${CASE}dummy
        grep -i signal $SST_ROOT/test/testOutputs/${CASE}*
        grep -i CurrentSimCycle $SST_ROOT/test/testOutputs/${CASE}*
        echo " ###############################################################"
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
        
           echo "Sibling is $_task"
           findChild $_task
           break
        done 3< full_ps__
    fi
    
    echo Kill pid is $KILL_PID
    #                     The following code assumes Kill pid is set
    #                            and never sets it
    
    if [ -z "$KILL_PID" ] ; then
        echo "Failed to define a KILL_PID "
        echo "   The timeLimitEnforcer has fail!   "
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
        echo "   Invoke the traceback routine  ---- $CASE"
        
        echo "\$SST_ROOT/test/utilities/stackback.py $TRACEBACK_PARAM" ; echo
        $SST_ROOT/test/utilities/stackback.py $TRACEBACK_PARAM
        
        echo ' '
        date
        echo "   Return to timeLimitEnforcer"
        echo ' '
        
        echo "  tLE ==== $LINENO   KILL_PID is $KILL_PID"
        kill $KILL_PID
        #                     Believe I remember that this always return zero
        if [ $? == 1 ] ; then
            echo " Kill of $KILL_PID for TIME OUT   FAILED"
            echo "     I am $TL_MY_PID,   my parent was $TL_PPID" 
            ps -f -U $USER
            echo " Try a \"kill -9\"  "
            kill -9 $KILL_PID
        fi
        echo "  tLE ==== $LINENO   "
        ps -f -p $KILL_PID > ttt ; grep $KILL_PID ttt
        if [ $? == 0 ] ; then
            echo " It's still there!  ($KILL_PID)"
            echo "  tLE ==== $LINENO   "
            ps -ef | grep ompsievetest | grep -v -e grep
            echo " Try a \"kill -9\" "
            kill -9 $KILL_PID
            echo "  tLE ==== $LINENO   "
            ps -f -p $KILL_PID > ttt ; grep $KILL_PID ttt
        fi
    
        echo "  tLE ==== $LINENO   "
        ps -ef | grep ompsievetest | grep -v -e grep
        echo "  tLE ==== $LINENO   "
        date
        Remove_old_ompsievetest_task
        date
        ps -ef | grep ompsievetest | grep -v -e grep
        echo "  tLE ==== $LINENO   "
    fi
    echo "  tLE ==== $LINENO   Issue the kill of $KILL_PID  "
    kill -9 $KILL_PID
    echo "  tLE ==== $LINENO   "
    ps -ef | grep ompsievetest | grep -v -e grep
    echo "  tLE ==== $LINENO   "
    date
    Remove_old_ompsievetest_task
    date
    ps -ef | grep ompsievetest | grep -v -e grep
    echo "  tLE ==== $LINENO   "
