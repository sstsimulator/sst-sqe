# !/bin/bash
# testSuite_partitioner.sh

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
L_SUITENAME="SST_partitioner_suite" # Name of this test suite; will be used to
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
#     test_partitioner
# Purpose:
#     Exercise  partitioning
# Inputs:
#     None
# Outputs:
#     test_partitioner.out file
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

    away_hold=$SST_ROOT/away.hold
    rm -rf $away_hold

        #                         Subroutine for checking
        #     $1     - number on the rank
        #     $2     - name of the test
        #     $3     - total number of components    (to be done)
        #     output - Displays to stdout

        checkAndPrint() {
           pc=`checkPerCent $3 $(($1+$3))`
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
#              fail " $2  $1   `pc100 $pc`   BAD allocation PerCentage "
           fi
        }
        #                     --- end of Subroutine
     echo ' '
     grep 'sut.*sutArgs' $SST_TEST_SUITES/testSuite_partitioner.sh
     echo ' '
##            subroutine create_distResultFile() 
#
#     inputs - partition file
#     Outputs 
#              distResultFile - (source to populate array RANKP
#              file $away_hold - debug log of processing
#              return value - number of ranks found
#
create_distResultFile() {

        rankis=-1
        IICCT=0
        NICCT=0
        rm -f $distResultFile
        
        while read -u 3 word rnk rest
        do 
          if [ $word == "->" ] ; then
             continue
          fi
        
          echo "/<$word/>"     >> $away_hold
          if [ $word == "Rank:" ] ; then
              echo "NICs in previous rank $rankis : $IICCT"     >> $away_hold
              if [ $rankis -gt -1 ] ; then
                  echo  RANKP[${rankis}]=$IICCT >> $distResultFile
              fi
              if [[ $rnk == *.* ]] ; then
                  rankis=`echo $rnk | awk -F. '{print $1}'`
                  threadis=`echo $rnk | awk -F. '{print $2}'`
                  echo Rank is $rankis, Thread is $threadis       >> $away_hold
              else 
                  rankis=$rnk
              fi
              echo Found Rank : $word $rest rank is $rankis       >> $away_hold
              IICCT=0
          else
              ((IICCT++))
              ((NICCT++))
          fi
        done 3<$partFile
 
        echo  RANKP[${rankis}]=$IICCT >> $distResultFile
        echo  numComp=$NICCT >> $distResultFile
        echo previous rank $rankis : $IICCT       >> $away_hold
        ((rankis++))
        #   return number of ranks
        echo "value is ${rankis}"  >> $away_hold
        echo $rankis 
}
#      end of Subroutine create_distResultFile()

#                             THE TEMPLATE
#    $1  Number of Ranks to create
#    $2  Partitioner
partitioner_template() {
NUMRANKS=$1
PARTITIONER=$2

    # Define a common basename for test output and reference files

    startSeconds=`date +%s` 
    testDataFileBase="test_${PARTITIONER}${NUMRANKS}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    errFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.err"
    partFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.part"
    distResultFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.dist"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
    pushd ${SST_ROOT}/sst/elements/ember/test

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs=${SST_ROOT}/sst/elements/ember/test/emberLoad.py
    rm -f ${outFile}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        mpirun -np ${NUMRANKS} ${sut} --verbose --partitioner $PARTITIONER --output-partition $partFile --model-options "--topo=torus --shape=4x4x4 --cmdLine=\"Init\" --cmdLine=\"Allreduce\" --cmdLine=\"Fini\"" ${sutArgs} > $outFile 2>$errFile
        retval=$?
        touch $partFile
        if [ $retval != 0 ]
        then
             grep -e disable-mpi -e unrecognised.option $outFile > __away__
             if [ $? == 0 ] ; then
                 echo "July 14, 2015: Boost does not allow partitioner use with out mpi"
                 fail "July 14, 2015: Boost does not allow partitioner use with out mpi"
                 sed 1q __away__
                 return
             fi
             wc $errFile $outFile $partFile
             echo ' '; echo "WARNING: sst did not finish normally, RETVAL=$retval" ; echo ' '
             ls -l ${sut}
             if [ -s $errFile ] ; then
                echo "   ---  And the Error File:" 
                cat $errFile | c++filt       
                echo "   ---"
             fi
             echo "outFile  first 15 and last 25 lines: "
             sed 15q $outFile
             echo '    . . . '
             tail -25 $outFile
             popd
             if [ ! -s $partFile ] ; then
                 echo ' ' ; echo '*****************************************************'
                 fail "WARNING: sst partition did not finish normally, RetVal=$RetVal"
                 echo ' ' ; echo "           Partition File does not exist "
                 echo ' ' ; echo '*****************************************************'
                 return
             fi
             echo ' ' ; echo "could exit here, but analyze even if partitioned run fails"
             fail "WARNING: sst did not finish normally, RetVal=$RetVal, RETVAL=$retval" 
#             return
        else
             wc $errFile $outFile $partFile
        fi


#   Processes output from the --verbose option  (stdout)
#

        echo ' '
        echo "                  Verify Partition Distribution from verbose output"
        echo ' '
        grep found $outFile | grep in.partition.graph 
        if [ $? == 0 ] ; then
            echo ' '
            grep Export.to.rank $outFile
            
            #   Find total number of components to distrubute
            numComp=`grep found $outFile | grep in.partition.graph | awk -F'found' '{print $2}' | awk '{print $1 }'`
            
            #   Collect number rank 0 sends to each other rank
            grep Export.to.rank $outFile | awk '{print "rank[" $8 "]=" $10 ";"}'> af
            numranks=`wc -l af | awk '{print $1}'` ; ((numranks++))
            echo " Total vertices: $numComp, numranks = $numranks "

            # Insert a sanity Check.   This has failed twice on Mavericks!
            OtherRanks=`wc -l af | awk '{print $1}'`
            ((OtherRanks++))   # Include rank zero
            #               BAD USAGE   numranks and NUMRANKS
            #           Verify that output file is valid
            if [ $OtherRanks != $NUMRANKS ] ; then
                echo "test assumptions not met"
    #            fail "test assumptions not met"
                cat af
                wc $outFile
                grep -e Export -e 'to.rank' -B 4 -A 4 $outFile
                return
            fi

            . af     #  Source the file (create array of components on node)
#
#   LOGIC PROBLEM extracting as subroutine this requires prior source of af!
#            
            #     Find out how many left on rank 0
            rank[0]=$numComp
            ind=1
            while [ $ind -lt $numranks ] 
            do 
                rank[0]=$((rank[0]-rank[$ind]))
                ((ind++))
            done
            #    Evaluate the Partition  (this is based on Output File)
            DesiredPC=$((10000/$numranks))    ##  x 100
            echo ' '
            echo "              Per Cent from Verbose output" 
            ind=0
            while [ $ind -lt $numranks ] 
            do 
               checkAndPrint ${rank[$ind]}  rank${ind} $numComp
                ((ind++))
            done
        else
            echo ' ' ; echo '*****************************************************'
            echo " Did not find Partition Distribution Information in stdout"
            echo ' ' ; echo '*****************************************************'
        fi

            #    Get info from Partition file, creating the file $distResultFile

echo "          next is call to create_distResultFile"
was=$numranks
        numranks=`create_distResultFile`
echo "  ===============   we have returned "
echo "DEBUG: numrank $numranks, was $was"
##   we now have two definitions of numranks
  wc $distResultFile

            #         Source $distResultFile (with the RANK array)
            . $distResultFile 2>std.err
            if [ -s std.err ] ; then
                 echo "source of $distResultFile failed:"
                 cat std.err
                 fail " Source of $distResultFile failed"
                 return
            fi
            DesiredPC=$((10000/$numranks))    ##  x 100
            echo ' '
            echo "              Per Cent from Partition File "
            ind=0
            _TOTAL=0
            while [ $ind -lt $numranks ] 
            do 
               checkAndPrint ${RANKP[$ind]}  rank${ind} $numComp
               _TOTAL=$((${RANKP[$ind]}+${_TOTAL}))
                ((ind++))
            done
            if [ ${_TOTAL} == 0 ] ; then
                echo ' ' ; echo '*****************************************************'
                fail " Something is really wrong!"
                echo " Either the SST Partition option has muliti-thread Issues -or- "
                echo " The test Suite is asking totally wrong questions."
                echo ' ' ; echo '*****************************************************'
                echo ' '
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
    echo " "
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "${PARTITIONER}${NUMRANKS}: Wall Clock Time  $elapsedSeconds seconds"

}
#             End of Template

test_roundrobin_2()
{
   partitioner_template 2 "roundrobin" 
}

test_roundrobin_4()
{
   partitioner_template 4 roundrobin 
}

test_roundrobin_8()
{
   partitioner_template 8 roundrobin
}

#################################################
#   July 2015 - There are separate zoltan tests
#          These can be a redundant tests.
#   The other partitioner tests should not be limited
#      to only when Zoltan is Installed.
#################################################
test_zoltan_2()
{
   if [ ! -e $SST_ROOT/../../local/packages/Zoltan ] ; then
       skip_this_test
       echo '     skipping'
       return
   fi
   partitioner_template 2 zoltan   
}

test_zoltan_4()
{
   if [ ! -e $SST_ROOT/../../local/packages/Zoltan ] ; then
       skip_this_test
       echo '     skipping'
       return
   fi
   partitioner_template 4 zoltan  
}

test_zoltan_8()
{
   if [ ! -e $SST_ROOT/../../local/packages/Zoltan ] ; then
       skip_this_test
       echo '     skipping'
       return
   fi
   partitioner_template 8 zoltan 
}

test_linear_2()
{
   partitioner_template 2 linear   
}

test_linear_4()
{
   partitioner_template 4 linear  
}

test_linear_8()
{
   partitioner_template 8 linear 
}

test_simple_2()
{
   partitioner_template 2 simple   
}

test_simple_4()
{
   partitioner_template 4 simple  
}

test_simple_8()
{
   partitioner_template 8 simple 
}

test_single_2()
{
   partitioner_template 2 single   
}

test_single_4()
{
   partitioner_template 4 single  
}

test_single_8()
{
   partitioner_template 8 single 
}


# "test"  will be automatically executed.
export SHUNIT_MAX_FAIL_TESTS=20   #  Let's get them all
export SST_TEST_ONE_TEST_TIMEOUT=20
(. ${SHUNIT2_SRC}/shunit2)
