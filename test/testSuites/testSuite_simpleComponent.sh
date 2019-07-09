# !/bin/bash
# testSuite_simpleComponent.sh

# Description:

# A shell script that defines a shunit2 test suite. This will be
# invoked by the Bamboo script.


TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_simpleComponent_suite" # Name of this test suite; will be used to
                                        # identify this suite in XML file. This
                                        # should be a single string, no spaces
                                        # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

#-------------------------------------------------------------------------------
# Test:
#     test_simpleComponent
# Purpose:
#     Exercise the simpleComponent of the simpleElementExample
# Inputs:
#     None
# Outputs:
#     test_simpleComponent.out file
# Expected Results
#     Match of output file against reference file
# Caveats:
#     The output files must match the reference file *exactly*,
#     requiring that the command lines for creating both the output
#     file and the reference file be exactly the same.
#-------------------------------------------------------------------------------
simpleComponent_Template() {
simpleC_case=$1
Type=$2

echo "   BBBEGIN template    $1   $2   "
    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
if [ $simpleC_case == "Component" ] ; then
            echoo "This is COMPONNT PATH"
    testDataFileBase="test_simple${simpleC_case}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    testOutFiles="${SST_TEST_OUTPUTS}/${testDataFileBase}.testFile"
    referenceFile="${SST_REFERENCE_ELEMENTS}/simpleElementExample/tests/refFiles/${testDataFileBase}.out"

    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/simpleElementExample/tests/test_simple${simpleC_case}.py"
    # Add basename to list for XML processing later

    L_TESTFILE+=(${testDataFileBase})
elif [ $simpleC_case == "SubComponent" ] ; then
             echo "  this is SUB COMPONNT PATH"
    testDataFileBase="test_simple${simpleC_case}$type"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    testOutFiles="${SST_TEST_OUTPUTS}/${testDataFileBase}.testFile"
    referenceFile="${SST_REFERENCE_ELEMENTS}/simpleElementExample/tests/subcomponent_tests/refFiles/test_${Type}.out"
ls -l $referenceFile

echo ' ' ; echo look at sutArgs
    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/simpleElementExample/tests/subcomponent_tests/test_${Type}.py"
ls -l $sutArgs
echo ' '
    # Add basename to list for XML processing later

    L_TESTFILE+=(${testDataFileBase})

else 
             echo "  THIS IS LEGACY PATH"
##                 Legacy
    testDataFileBase="test_simple${simpleC_case}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    testOutFiles="${SST_TEST_OUTPUTS}/${testDataFileBase}.testFile"

    referenceFile="${SST_REFERENCE_ELEMENTS}/simpleElementExample/tests/subcomponent_tests/legacy/refFiles/test_${Type}.out"

    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/simpleElementExample/tests/subcomponent_tests/legacy/test_${Type}.py"
    # Add basename to list for XML processing later

    L_TESTFILE+=(${testDataFileBase})
fi

#    Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        if [[ ${SST_MULTI_RANK_COUNT:+isSet} == isSet ]] && [ ${SST_MULTI_RANK_COUNT} -gt 1 ] ; then
           mpirun -np ${SST_MULTI_RANK_COUNT} $NUMA_PARAM -output-filename $testOutFiles ${sut} ${sutArgs}
           RetVal=$? 
           cat ${testOutFiles}* > $outFile
        else
           ${sut} ${sutArgs} > ${outFile}
           RetVal=$? 
        fi

        TIME_FLAG=$SSTTESTTEMPFILES/TimeFlag_$$_${__timerChild} 
        if [ -e $TIME_FLAG ] ; then 
             echo " Time Limit detected at `cat $TIME_FLAG` seconds" 
             fail " Time Limit detected at `cat $TIME_FLAG` seconds" 
             rm $TIME_FLAG 
             return 
        fi 
        if [ $RetVal != 0 ]  
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             ls -l ${sut}
             fail "WARNING: sst did not finish normally, RetVal=$RetVal"
             return
        fi

        RemoveComponentWarning

        wc $referenceFile $outFile
        diff -b $referenceFile $outFile > ${SSTTESTTEMPFILES}/_raw_diff
        if [ $? != 0 ]
        then  
           wc ${SSTTESTTEMPFILES}/_raw_diff
           compare_sorted $referenceFile $outFile
           if [ $? == 0 ] ; then
              echo " Sorted match with Reference File"
              rm ${SSTTESTTEMPFILES}/_raw_diff
              return
           else
              fail " Reference does not Match Output"
              diff -b $referenceFile $outFile 
           fi
        else
           echo "Exact match with Reference File"
        fi
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
}

test_simpleComponent() {

simpleComponent_Template  Component

}


test_simpleSubComponent_sc_2a() {
simpleComponent_Template SubComponent sc_2a
}
test_simpleSubComponent_sc_2u2u() {
simpleComponent_Template SubComponent sc_2u2u
}
test_simpleSubComponent_sc_2u() {
simpleComponent_Template SubComponent sc_2u
}
test_simpleSubComponent_sc_a() {
simpleComponent_Template SubComponent sc_a
}
test_simpleSubComponent_sc_u2u() {
simpleComponent_Template SubComponent sc_u2u
}
test_simpleSubComponent_sc_u() {
simpleComponent_Template SubComponent sc_u
}
test_simpleSubComponent_sc_2u2a() {
simpleComponent_Template SubComponent sc_2u2a
}
test_simpleSubComponent_sc_2ua() {
simpleComponent_Template SubComponent sc_2ua
}
test_simpleSubComponent_sc_2uu() {
simpleComponent_Template SubComponent sc_2uu
}
test_simpleSubComponent_sc_u2a() {
simpleComponent_Template SubComponent sc_u2a
}
test_simpleSubComponent_sc_ua() {
simpleComponent_Template SubComponent sc_ua
}
test_simpleSubComponent_sc_uu() {
simpleComponent_Template SubComponent sc_uu
}


test_simpleSubComponent_sc_legacy_2nl() {
simpleComponent_Template Legacy sc_legacy_2nl
}
test_simpleSubComponent_sc_legacy_n2l() {
simpleComponent_Template Legacy sc_legacy_n2l
}
test_simpleSubComponent_sc_legacy_n() {
simpleComponent_Template Legacy sc_legacy_n
}
test_simpleSubComponent_sc_legacy_2l() {
simpleComponent_Template Legacy sc_legacy_2l
}
test_simpleSubComponent_sc_legacy_2nn() {
simpleComponent_Template Legacy sc_legacy_2nn
}
test_simpleSubComponent_sc_legacy_n2n() {
simpleComponent_Template Legacy sc_legacy_n2n
}
test_simpleSubComponent_sc_legacy_2n2l() {
simpleComponent_Template Legacy sc_legacy_2n2l
}
test_simpleSubComponent_sc_legacy_2n() {
simpleComponent_Template Legacy sc_legacy_2n
}
test_simpleSubComponent_sc_legacy_nl() {
simpleComponent_Template Legacy sc_legacy_nl
}
test_simpleSubComponent_sc_legacy_2n2n() {
simpleComponent_Template Legacy sc_legacy_2n2n
}
test_simpleSubComponent_sc_legacy_l() {
simpleComponent_Template Legacy sc_legacy_l
}
test_simpleSubComponent_sc_legacy_nn() {
simpleComponent_Template Legacy sc_legacy_nn
}

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
