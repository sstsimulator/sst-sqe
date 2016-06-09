# !/bin/bash
# testSuite_prospero.sh

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

OPWD=`pwd`       #  starting location

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_prospero_suite" # Name of this test suite; will be used to
                                # identify this suite in XML file. This
                                # should be a single string, no spaces
                                # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

echo " ugly debut ====================================================="
ls ${SST_ROOT}/sst-elements/src/sst/elements/prospero/
tail ${SST_ROOT}/sst-elements/src/sst/elements/prospero/Makefile
ls -l ${SST_ROOT}/sst-elements/src/sst/elements/prospero/tracetool
echo ' '
if [[ ${SST_BUILD_PROSPERO_TRACE_FILE:+isSet} == isSet ]] ; then
   # ==================  Create program "array"

   # ----------------- compile the file array   
   echo "## ----------------- compile the file array   "
       cd ${SST_ROOT}/sst-elements/src/sst/elements/prospero/tests/array
   echo PWD `pwd`
       make clean
       make
   ls -l 
   echo "target file follows"
   ls -l array
   # --------------------------- run the pin trace program
   #    Build the compress, uncompressed and binary
   rm -f *.trace
   echo "## --------------------------- run the pin trace program"
   which sst-prospero-trace

       sst-prospero-trace -t 1 -f compressed -o sstprospero -- ./array
       echo " pin return flag is from compressed: $?"   

       sst-prospero-trace -t 1 -f text  -o sstprospero -- ./array
   
       sst-prospero-trace -t 1 -f binary -o sstprospero -- ./array
       PIN_TAR="Pin"
else
   #  Download the trace files from sst-simulator.org
       cd ${SST_ROOT}/sst-elements/src/sst/elements/prospero/tests/array
       echo "wget https://github.com/sstsimulator/sst-downloads/releases/download/TestFiles/Prospero-trace-files.tar.gz --no-check-certificate"
       wget "https://github.com/sstsimulator/sst-downloads/releases/download/TestFiles/Prospero-trace-files.tar.gz" 
       if [ $? != 0 ] ; then
          echo "wget failed"
          preFail "wget failed"
       fi

       tar -xzf Prospero-trace-files.tar.gz
       PIN_TAR="Tar"
fi   
echo " ---------------  Three files are expected: "
cksum *.trace
if [ $? != 0 ] ; then
   echo "No trace files found"
   preFail "No trace files found"
fi
echo ' '

ln -sf ${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/tests/DDR3_micron_32M_8B_x4_sg125.ini
ln -sf ${SST_ROOT}/sst-elements/src/sst/elements/memHierarchy/tests/system.ini

# --------------------------------------------------
#    Subroutine to yield integers with commas
wcomma() {
   printf "%'d" $1
}
# --------------------------------------------------

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
#           Parameters are 
#              trace file type:  (text, binary, compressed)
#              with or without DramSim  ("DramSim" or other, "none", blank)
template_prospero() {
    ls ${SST_ROOT}/sst-elements/src/sst/elements/prospero/tests/array/*.trace > /dev/null 2>&1
    rt=$?
    if [ 0 != $rt ] ; then
        fail "No trace file found (rt = $rt)"
        return
    fi
    TYPE=$1
    startSeconds=`date +%s`
    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    if [ "$2" != "DramSim" ] ; then
         testDataFileBase="test_prospero_wo_dramsim"
         # echo ' ' ; echo "        entering test  $TYPE  without DramSim" ; pwd ; echo ' '
         useDRAMSIM="no"
    else
         testDataFileBase="test_prospero_with_dramsim"
         # echo ' ' ; echo "        entering test  $TYPE  with DramSim" ; pwd ; echo ' '
         useDRAMSIM="yes"
         echo ' '
    fi
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}_${TYPE}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}_${TYPE}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/prospero/tests/array/trace-common.py"
    cd ${SST_ROOT}/sst-elements/src/sst/elements/prospero/tests/array


    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        ${sut} ${sutArgs} --model-options "--TraceType=$TYPE --UseDramSim=$useDRAMSIM"  > $outFile
        rc=$?
        echo ' ' ; grep simulated $outFile   ; echo ' '
        
        if [ $rc != 0 ]
        then
             echo ' '; echo ERROR: sst did not finish normally ; echo ' '
             ls -l ${sut}
             wc $outFile
             fail "ERROR: sst did not finish normally, RetVal=$RetVal"
             RemoveComponentWarning
             return
        fi
        RemoveComponentWarning
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    diff -w $referenceFile $outFile > /dev/null
    if [ $? != 0 ]
    then 
        #   Exact match is only expected from tar, i.e., identical input to SST 
        if [ $PIN_TAR == "Tar" ] ; then
            lref=`cat ${referenceFile} | grep Cycles.with.no.ops.issued | awk '{print $9}'`
            lout=`cat ${outFile} | grep Cycles.with.no.ops.issued | awk '{print $9}'`
            perc=`checkPerCent $lref $lout`
            val=`pc100 $perc`
            echo "    \"Cycles with no ops issued\""
            echo " Reference `wcomma $lref` "
            echo " Output    `wcomma $lout`"
            echo "          ${val}% difference"
            echo ' '
        fi

        wc $outFile $referenceFile
        ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
        new=`wc ${outFile}       | awk '{print $1, $2}'`;
        if [ "$ref" == "$new" ];
        then
            echo "OutFile word/line count matches Reference"
        else
            echo "OutFile word/line count DOES NOT matches Reference"
            fail "OutFile word/line count DOES NOT matches Reference"
        fi
    else
        echo OutFile is an exact match of ReferenceFile
    fi
     endSeconds=`date +%s`
     elapsedSeconds=$(($endSeconds -$startSeconds))
     echo "${testDataFileBase}: Wall Clock Time  $elapsedSeconds seconds"
     echo " "


}
script6=${SST_TEST_INPUTS_TEMP}/__prospero_tmp_${PIN_TAR}
cat > $script6 << ..EOF.
test_prospero_compressed_${PIN_TAR}() {

    template_prospero compressed none
}


test_prospero_compressed_withdramsim_${PIN_TAR}() {

    template_prospero compressed DramSim

} 

test_prospero_text_${PIN_TAR}(){

    template_prospero text none
}


test_prospero_text_withdramsim_${PIN_TAR}() {

    template_prospero text DramSim

}

test_prospero_binary_${PIN_TAR}(){

    template_prospero binary none
}


test_prospero_binary_withdramsim_${PIN_TAR}() {
 
    template_prospero binary DramSim
}
..EOF.

export SST_TEST_ONE_TEST_TIMEOUT=30         #  30 seconds

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS
 
# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
cd $OPWD      #  Restore Original PWD for shunit2
(. ${SHUNIT2_SRC}/shunit2 $script6 )
