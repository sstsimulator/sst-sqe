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

####                    The Sleep
sleep $SST_TEST_ONE_TEST_TIMEOUT 

echo ' ' ; echo "TL Enforcer:            TIME LIMIT     $CASE "
echo "TL Enforcer: test has exceed alloted time of $SST_TEST_ONE_TEST_TIMEOUT seconds."
MY_PID=$$

####                     The Time Limit flag
TIME_FLAG=/tmp/TimeFlag_${1}_${MY_PID}
echo $SST_TEST_ONE_TEST_TIMEOUT >> $TIME_FLAG
chmod 777 $TIME_FLAG
echo "         Create Time Limit Flag file, $TIME_FLAG"

echo ' '
echo I am $MY_PID,  I was called from $1, my parent PID is $PPID
ps -f -p ${1},${PPID}
echo ' '

####                 Remove old ompsievetest tasks with parent 1
ps -ef | grep ompsievetest
echo " this might better go in the Suite"
ps -ef | grep ompsievetest | grep -v -e grep > omps_list
wc omps_list
while read -u 3 _who _anOMP _own _rest
do
    if [ $_own == 1 ] ; then
        echo " Attempt to remove $_anOMP "
        kill -9 $_anOMP
    fi
done 3<omps_list
starting_pid=$1     ### Enforcer was called from

echo "begin ----------------------------------------"
####                 Create the killChildren script
ls -l killChildren.sh     # un-needed
rm killChildren.sh
ls -l killChildren.sh       #  really un-needed

cat >> killChildren.sh << ..EOF..
# killChildren (thispid, level)
thisPid=\$1
level=\$2
           echo Entered subroutine \$thisPid \$level
grep \$thisPid /tmp/TheFile.timeL > F\${level}.tmp
        wc F\${level}.tmp
while read -u 3 _who _ch _pa rest
do
        echo READ: \$_who, \$_ch ,\$_pa  \$rest
   if [ \$_ch == \$thisPid ] ; then
             echo " Parent entry  (skip)"
       continue
   else
             echo " THIS IS A child  \$_ch \$thisPid "
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

   ./killChildren.sh \$_ch \$nlevel
         echo    Return to \$thisPid at level \$level
done 3<F\${level}.tmp
echo "DEBUG  loop \$level is done
ps -fp \$thisPid
if [ \$? -eq 0 ] ; then
   echo Time to kill \$thisPid
# ps -fp \$thisPid
   kill -9 \$thisPid
else
   echo \$thisPid is gone
fi

exit
..EOF..

ls -l killChildren.sh
chmod +x killChildren.sh
ps -ef | grep -v -e ' 1 ' -e ' 2 ' > /tmp/TheFile.timeL
wc /tmp/TheFile.timeL
echo ' ' ;  echo "              this in temporary "
pstree -p $starting_pid
echo ' ' ;  echo "              this in temporary "
cat /tmp/TheFile.timeL
echo ' ' ;  echo "              this in temporary "

   ./killChildren.sh $starting_pid 1

echo ' ' ; echo " The list "
cat /tmp/TheFile.timeL

