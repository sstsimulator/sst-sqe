#!/bin/bash
# testSuite_hgcc.sh
# shellcheck disable=SC1091,SC2034,SC2154

set -o pipefail

# A shunit2 suite for sst-hgcc, invoked by buildsys/bamboo.sh. This intentionally
# runs only the non-MV2 hgcc tests: make check and make installcheck.

TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# shellcheck source=../include/testDefinitions.sh
. "$TEST_SUITE_ROOT/../include/testDefinitions.sh"
# shellcheck source=../include/testSubroutines.sh
. "$TEST_SUITE_ROOT/../include/testSubroutines.sh"

# These names are consumed by the sourced SQE shunit2 harness.
# shellcheck disable=SC2034
L_SUITENAME="SST_hgcc_suite"
# shellcheck disable=SC2034
L_BUILDTYPE=$1
L_TESTFILE=()

if [[ ${SST_BUILDOUTOFSOURCE:+isSet} == isSet ]] ; then
    echo "NOTICE: TESTING SST-HGCC OUT OF SOURCE DIR"
    hgccbuilddir="sst-hgcc-builddir"
else
    echo "NOTICE: TESTING SST-HGCC IN SOURCE DIR"
    hgccbuilddir="sst-hgcc"
fi

_hgcc_test_env() {
    export PATH="${SST_HGCC_INSTALL}/bin:${SST_CORE_INSTALL}/bin:${PATH}"
    if [[ -n "${LLVM_ROOT}" ]]; then
        export PATH="${LLVM_ROOT}/bin:${PATH}"
        export FILECHECK="${FILECHECK:-${LLVM_ROOT}/bin/FileCheck}"
    fi
}

test_hgcc_make_check() {
    local testDataFileBase="test_hgcc_make_check"
    local outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    L_TESTFILE+=("${testDataFileBase}")

    local hgccdir="${SST_ROOT}/${hgccbuilddir}"
    local RetVal=0

    if [ ! -f "${hgccdir}/Makefile" ]; then
        ls -l "${hgccdir}"
        fail "sst-hgcc: Could not find Makefile in ${hgccdir}"
        return
    fi

    pushd "${hgccdir}"
    _hgcc_test_env
    make check 2>&1 | tee "${outFile}"
    RetVal=${PIPESTATUS[0]}
    popd

    local TIME_FLAG=$SSTTESTTEMPFILES/TimeFlag_$$_${__timerChild}
    if [ -e "$TIME_FLAG" ] ; then
        echo " Time Limit detected at $(cat "$TIME_FLAG") seconds"
        fail " Time Limit detected at $(cat "$TIME_FLAG") seconds"
        rm "$TIME_FLAG"
        return
    fi
    if [[ $RetVal -ne 0 ]]; then
        fail "sst-hgcc: Failed make check; RetVal=$RetVal"
    fi
}

test_hgcc_make_installcheck() {
    local testDataFileBase="test_hgcc_make_installcheck"
    local outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    L_TESTFILE+=("${testDataFileBase}")

    local hgccdir="${SST_ROOT}/${hgccbuilddir}"
    local RetVal=0

    if [ ! -f "${hgccdir}/Makefile" ]; then
        ls -l "${hgccdir}"
        fail "sst-hgcc: Could not find Makefile in ${hgccdir}"
        return
    fi

    pushd "${hgccdir}"
    _hgcc_test_env
    make installcheck 2>&1 | tee "${outFile}"
    RetVal=${PIPESTATUS[0]}
    popd

    local TIME_FLAG=$SSTTESTTEMPFILES/TimeFlag_$$_${__timerChild}
    if [ -e "$TIME_FLAG" ] ; then
        echo " Time Limit detected at $(cat "$TIME_FLAG") seconds"
        fail " Time Limit detected at $(cat "$TIME_FLAG") seconds"
        rm "$TIME_FLAG"
        return
    fi
    if [[ $RetVal -ne 0 ]]; then
        fail "sst-hgcc: Failed make installcheck; RetVal=$RetVal"
    fi
}

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

# shellcheck source=/dev/null
(. "${SHUNIT2_SRC}/shunit2")
