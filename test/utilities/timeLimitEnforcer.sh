##   Default time out is set to 1800 seconds (30 minutes) per test.
##   This can be Globally changed by setting the Environment variable
##   This can be Locally changed for an entire Suite by exporting the
##      environment variable from in that Suite before shunit2 is invoked.
##   September 2016: most Suites set it; thus over-riding the Environment
##      value.  The utility that inserts Valgrind in things, jams a
##      value directly in here, over riding the Suite.
##   The new environment variable, SST_TEST_TIMEOUT_OVERRIDE, trumps all. 
              

CASE=$2

####                    The OverRide
if [[ ${SST_TEST_TIMEOUT_OVERRIDE:+isSet} == isSet ]] ; then
    SST_TEST_ONE_TEST_TIMEOUT=$SST_TEST_TIMEOUT_OVERRIDE
elif [[ ${SST_TEST_ONE_TEST_TIMEOUT:+isSet} != isSet ]] ; then
####                    The Default
    SST_TEST_ONE_TEST_TIMEOUT=1800         # 30 minutes 1800 seconds
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
ps -ef | grep $USER

####                     The Time Limit flag
TIME_FLAG=/tmp/TimeFlag_${1}_${TL_MY_PID}
echo $SST_TEST_ONE_TEST_TIMEOUT >> $TIME_FLAG
chmod 777 $TIME_FLAG
echo "         Create Time Limit Flag file, $TIME_FLAG"

echo ' '
echo I am $TL_MY_PID,  I was called from $TL_CALLER, my parent PID is $TL_PPID
ps -f -p ${TL_CALLER},${TL_PPID}
echo ' '

####                 Remove old ompsievetest tasks with parent 1
  ##########    this might better go in the Suite
ps -ef | grep ompsievetest | grep -v -e grep > omps_list
wc omps_list
while read -u 3 _who _anOMP _own _rest
do
    if [ $_own == 1 ] ; then
        echo " Attempt to remove $_anOMP "
        kill -9 $_anOMP
    fi
done 3<omps_list

####                 Darwin using pstree
if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin" ] ; then
  if [ "$SST_TEST_HOST_OS_KERNEL" == "Darwin-xcode7" ] ; then

   echo "                                      STARTING PID $TL_CALLER"
   ps -fp $TL_CALLER
   pstree -p $TL_CALLER 
   pstree -p $TL_CALLER | awk -F'- ' '{print $2}' > raw-list
   cat raw-list | awk '{print $1, "/", $3}' | awk -F/ '{print $1 $NF}' > display-file
   echo " Display File "
   cat display-file

   
   cat raw-list | awk '{print $1}' | tail -r | sed /$TL_CALLER/q > kill-these
   cat kill-these
   for kpid in `cat kill-these | grep -v $TL_CALLER`
   do
      echo " task to be killed   $kpid"
      grep $kpid display-file
   
      kill -9 $kpid
      echo " Return from kill $?"
   done
  else
    ####                  Find Pid of my ompsievetest
    OMP_PID=`ps -ef | awk '{print $1,$2,$3,$4,$5,$6,$7,$8}' | grep ompsievetest | grep -v -e grep | awk '{print $2}'`
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
           echo I am $TL_MY_PID,  I was called from $TL_CALLER, my parent PID is $TL_PPID
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
    
    findChild $TL_PPID
    
    
    if [ -z $KILL_PID ] ; then
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
        echo " Try a \"kill -9\" "
        kill -9 $KILL_PID
    ps -f -p $KILL_PID | grep $KILL_PID
    fi
  fi

else  

   ####                    LINUX
   echo "begin ------------  Linux --------------------"
   
   ####                 Create the killChildren script
   rm -f killChildren.sh
   
cat >> killChildren.sh << ..EOF..
   # killChildren (level, thispid)
   level=\$1
   thisPid=\$2
   echo Entered TLsub  pid= \$thisPid lev= \$level
   grep \$thisPid __tmp_TheFile.timeL > F\${level}.tmp
   wc F\${level}.tmp

   while read -u 3 _who _ch _pa rest
   do
           echo READ: \$_who, \$_ch ,\$_pa  \$rest
      if [ \$_who != \$USER ] ; then
               echo " \$_who does not match \$USER "
          continue
      fi
      if [ \$_ch == \$thisPid ] || [ \$_ch == \$TL_MY_PID ] ; then
                echo " Parent or me entry  (skip)"
          continue
      else
                echo " THIS IS A child  \$_ch "
      fi
            echo    this is level  \$level
      nlevel=\$(( \$level + 1 ))
      if [ \$level -gt 10 ] ; then
          echo \$level is greater than 10
          exit
      fi
   # ASSERT    \$_pa is \$thisPid
      if [ \$_pa -eq \$thisPid ] ; then
         echo passed Sanity check
      fi
   
      ./killChildren.sh \$nlevel \$_ch
      echo    Return to level \$level \$thisPid
   done 3<F\${level}.tmp
   echo "DEBUG  loop \$level is done"
   if [ \$thisPid == \$TL_PPID ] ; then
       echo "timeLimitEnforcer parent,  \"Done\""
       exit
   fi
   ps -fp \$thisPid
   if [ \$? -eq 0 ] ; then
                            #          no-header option is Linux only
   echo " -------------thisPid is \$thisPid "
      if [ \$thisPid != \$TL_PPID ] && [ \$thisPid != \$TL_CALLER ] ; then
         echo "Time to kill \`ps --no-headers -fp \$thisPid\`"
         kill -9 \$thisPid
      fi
   else
      echo \$thisPid was already gone
   fi
   
   exit
..EOF..
   ####             End of killChildren script
   
   ls -l killChildren.sh
   chmod +x killChildren.sh
   ps -ef | grep -v -e '  1 ' -e '  2 ' > __tmp_TheFile.timeL
   echo ' ' ;  echo " this is supposed to be the relevent tree"   # ??
   wc __tmp_TheFile.timeL
   
   ##--
   echo ' ' ;  echo "              this in temporary "     > tmp.instrum.$$
      echo "                    STARTING PID $TL_CALLER" >> tmp.instrum.$$
   pstree -p $TL_CALLER >> tmp.instrum.$$ 
   echo ' ' ;  echo "              this in temporary " >> tmp.instrum.$$
   cat __tmp_TheFile.timeL >> tmp.instrum.$$
   echo ' ' ;  echo "              this in temporary " >> tmp.instrum.$$
   ##--
   
   ####                  Invoke killChildren
      ./killChildren.sh 1 $TL_CALLER
   
   echo ' ' ; echo " The list " >> tmp.instrum.$$
   cat __tmp_TheFile.timeL >> tmp.instrum.$$	
   
fi
