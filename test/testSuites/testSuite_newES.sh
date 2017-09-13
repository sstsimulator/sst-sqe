
TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

L_SUITENAME="SST__newES_suite" # Name of this test suite; will be used to
                             # identify this suite in XML file. This
                             # should be a single string, no spaces
                             # please.

L_TESTFILE=()  # Empty list, used to hold test file names

mkdir -p $SST_TEST_ROOT/testSuites/newES_folder

cd $SST_TEST_ROOT/testSuites/newES_folder
cp $SST_ROOT/sst-elements/src/sst/elements/ember/test/emberLoad.py .
cp $SST_ROOT/sst-elements/src/sst/elements/ember/test/loadInfo.py .
cp $SST_ROOT/sst-elements/src/sst/elements/ember/test/networkConfig.py .
cp $SST_ROOT/sst-elements/src/sst/elements/ember/test/defaultParams.py .
pwd ; ls -ltr  | tail -5

ES_after() {
grep 'simulated time' outFile
    if [ $? != 0 ] ; then
        fail "test failed"
        cat outFile
    fi
    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo ": Wall Clock Time  $elapsedSeconds seconds"
    export startSeconds=$endSeconds
}


ln -s $SST_TEST_ROOT/testInputFiles/newES_List-of-Tests ./List-of-Tests
rm SHU.in
ind=1
while [ $ind -lt 127 ] 
do
   sed -n ${ind},${ind}p ./List-of-Tests > _tmp_${ind}
    
   if [ $ind -eq 0 ] ; then    ##  NOP -- model for limiting tests
       ind=$(( ind + 1 ))
       continue
   fi
   hash=`md5sum _tmp_${ind} | awk '{print $1}'`
   indx=$(printf "%03d" $ind)
   echo "test_ES2_${indx}_${hash} () {" >> SHU.in
   echo "L_TESTFILE+=testnewES_${indx}" >> SHU.in
   echo "cd $SST_TEST_ROOT/testSuites/newES_folder" >> SHU.in
   echo "echo \"sut == \$sut \" " >> SHU.in
   sed -i'.x' 's/$/ > outFile/' _tmp_${ind}
   sed -i'.z' 's/sst/${sut}/' _tmp_${ind}
   cat _tmp_${ind} >> SHU.in
   echo ES_after >> SHU.in
   echo "}"  >> SHU.in

   ind=$(( ind + 1 ))

done


wc SHU.in
echo  SST_MULTI_THREAD_COUNT   = ${SST_MULTI_THREAD_COUNT}
if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] && [ ${SST_MULTI_THREAD_COUNT} -gt 1 ] ; then
   sed -i'.x' '/^${sut}/s/${sut}/${sut} -n ${SST_MULTI_THREAD_COUNT}/' SHU.in
fi
wc SHU.in
echo  SST_MULTI_RANK_COUNT   = ${SST_MULTI_RANK_COUNT}

if [[ ${SST_MULTI_RANK_COUNT:+isSet} == isSet ]] && [ ${SST_MULTI_RANK_COUNT} -gt 1 ] ; then
 sed -i'.y' '/^${sut}/s/${sut}/mpirun -np ${SST_MULTI_RANK_COUNT} ${sut}/' SHU.in
fi    
wc SHU.in

sed 20q SHU.in

cd $SST_ROOT
export sut=${SST_TEST_INSTALL_BIN}/sst
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS
export SST_TEST_ONE_TEST_TIMEOUT=200
export startSeconds=`date +%s`

(. ${SHUNIT2_SRC}/shunit2 $SST_TEST_ROOT/testSuites/newES_folder/SHU.in)
