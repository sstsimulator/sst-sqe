# !/bin/bash
# testSuite_zoltan.sh

# Description:

# A shell script that defines a shunit2 test suite. This will be
# invoked by the Bamboo script.

# Preconditions:

# 1) The SUT (software under test) must have built successfully.
# 2) A test success reference file is available.

TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_zoltan_suite" # Name of this test suite; will be used to
                                # identify this suite in XML file. This
                                # should be a single string, no spaces
                                # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
# Use the new shunit2 option only
#===============================================================================

        export SHUNIT_DISABLE_DIFFTOXML=1
        export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_zoltan
# Purpose:
#     Exercise the Zoltan partitioning
# Inputs:
#     None
# Outputs:
#     test_zoltan.out file
# Expected Results
#     TBD
# Caveats:
#    
#-------------------------------------------------------------------------------
    if [ "`which mpirun | awk -F/ '{print $NF}'`" != "mpirun" ] ; then
        echo "    MPIRUN not FOUND "
        echo "    Add the appropriate mpi module or"
        echo "      make sure your path includes a pointer to mpirun."
#        Omitting the forced fail in case the above test rejects valid mpiruns
    fi

zoltan_template() {
NUMRANKS=$1

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    
    startSeconds=`date +%s`
    testDataFileBase="test_zoltan${NUMRANKS}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    partFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.part"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
    pushd ${SST_ROOT}/sst-elements/src/sst/elements/ember/test

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs=${SST_ROOT}/sst-elements/src/sst/elements/ember/test/emberLoad.py
    rm -f ${outFile}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        mpirun -np ${NUMRANKS} ${sut} --verbose --partitioner zoltan --output-partition $partFile --model-options "--topo=torus --shape=4x4x4 --cmdLine=\"Init\" --cmdLine=\"Allreduce\" --cmdLine=\"Fini\"" ${sutArgs} > $outFile 2>$errFile
        RetVal=$?
        if [ $RetVal != 0 ]
        then
             echo ' '; echo "WARNING: sst did not finish normally, RETVAL=$RetVal" ; echo ' '
             ls -l ${sut}
        #     sed 10q $outFile
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             echo "And the Error File  (first 10 lines):"
             cat $errFile | c++filt       
#     sed 10q $errFile
 #            echo "       - - -    (and the last 10 line)"
  #           tail -10 $errFile
             popd
             return
        fi
        wc $errFile $outFile $partFile

#                         Subroutine for checking
checkAndPrint() {
   pc=`checkPerCent $alln $(($1+$alln))`
   pc10=$(($DesiredPC/10))
   Pl10=$(($DesiredPC+$pc10)) ; M10=$(($DesiredPC-$pc10))
   pc50=$(($DesiredPC/2))
   Pl50=$(($DesiredPC+$pc50)) ; M50=$(($DesiredPC-$pc50))
   if [ $pc -gt $M10 ]  && [ $pc -lt $Pl10 ] ; then
       echo "$2  ${1}   `pc100 $pc`   (Good) "
   elif [ $pc -gt $M50 ]  && [ $pc -lt $Pl50 ] ; then
       echo "$2  ${1}   `pc100 $pc`   (Working but lousy) "
   else
       echo "$2  $1   `pc100 $pc`   BAD    "
       fail " $2  $1   `pc100 $pc`   BAD allocation PerCentage "
   fi
}
#                     --- end of Subroutine

#   Processes output from the --verbose option
#

        echo ' '
        echo "                  Verify Partition Distribution "
        echo ' '
        grep found $outFile | grep in.partition.graph 
        if [ $? == 0 ] ; then
            echo ' '
            grep Export.to.rank $outFile
            
            alln=`grep found $outFile | grep in.partition.graph | awk -F'found' '{print $2}' | awk '{print $1 }'`
            
            grep 'rank .* (assigned .* components)' $outFile | awk -F'rank' '{print $2}' | awk '{print "rank[" $1 "]=" $3}' > af
#            grep Export.to.rank $outFile | awk '{print "rank[" $8 "]=" $10 ";"}'> af
            numranks=`wc -l af | awk '{print $1}'` ; ((numranks++))
            echo " Total vertices: $alln, numranks = $numranks "

            # Insert a sanity Check.   This has failed twice on Mavericks!
            OtherRanks=`wc -l af | awk '{print $1}'`
            ((OtherRanks++))   # Include rank zero
            #               BAD USAGE   numranks and NUMRANKS
            if [ $OtherRanks != $NUMRANKS ] ; then
                fail "test assumptions not met"
                cat af
                wc $outFile
                grep -e Export -e 'to.rank' -B 4 -A 4 $outFile
                return
            fi

            . af
            
            rank[0]=$alln
            ind=1
            while [ $ind -lt $numranks ] 
            do 
                rank[0]=$((rank[0]-rank[$ind]))
                ((ind++))
            done
            
            DesiredPC=$((10000/$numranks))    ##  x 100
            echo ' '
            echo "              Per Cent"
            ind=0
            while [ $ind -lt $numranks ] 
            do 
               checkAndPrint ${rank[$ind]}  Rank${ind}
                ((ind++))
            done
        else
            echo " Did not find Partition Distribution Information in outFile"
            fail " Did not find Partition Distribution Information in outFile"
            echo " Looking for \"found <nnn> in partition graph\""
            grep -e found -e in.partition.graph -A 2 -B 1 $outFile 
            return
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    popd

    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo " Zoltan ${NUMRANKS}: Wall Clock Time  $elapsedSeconds seconds"
}

test_zoltan_2()
{
   zoltan_template 2
}

test_zoltan_4()
{
   zoltan_template 4
}

test_zoltan_8()
{
   zoltan_template 8
}

# "test"  will be automatically executed.

export SST_TEST_ONE_TEST_TIMEOUT=30         # 1/2 minute is plenty  (30 seconds)
if [[ ${SST_MULTI_CORE+isSet} == isSet ]] ; then
    export SST_TEST_ONE_TEST_TIMEOUT=900         # 15 minute for multithread
fi
(. ${SHUNIT2_SRC}/shunit2)
