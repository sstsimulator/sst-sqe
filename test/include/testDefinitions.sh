#!/bin/bash

set -o pipefail

# Test definitions

# NOTE: User may override SST installation location by setting the
# SST_INSTALL_BIN_USER environment variable to a non-NULL directory.

_SUITE_NAME=$(echo "$0" | awk -F/ '{print $NF}')
if [[ $_SUITE_NAME == *testSuite_* ]] ; then
    echo "SST_BEGIN_NEW_SUITE  $_SUITE_NAME"
fi
#===============================================================================
# Directories
#===============================================================================

if [[ ${SST_ROOT:+isSet} != isSet ]]
then
    # If SST_ROOT has NOT been set, assume SST_ROOT is up 2 levels from
    # the directory that this file (testDefinitions.sh) resides in.
    SST_ROOT="$( cd -P "$( dirname "$0" )"/../.. && pwd )"
    export SST_ROOT
fi

# Check SST installation preferences
if [[ ${SST_INSTALL_BIN_USER:+isSet} = isSet ]]
then
    # Let user's environment determine value
    export SST_TEST_INSTALL_BIN=$SST_INSTALL_BIN_USER

elif [[ ${SST_INSTALL_BIN:+isSet} = isSet ]] && [[ ${SST_INSTALL_BIN_USER:+isSet} != isSet ]]
then
    # Use SST_INSTALL_BIN since user has not specified an override
    export SST_TEST_INSTALL_BIN=$SST_INSTALL_BIN

elif [[ ${SST_INSTALL_BIN:+isSet} != isSet ]] && [[ ${SST_INSTALL_BIN_USER:+isSet} != isSet ]]
then
    # Neither value has been set, attempt to set it in the tree the test Suite is in
    if [ -d "${SST_ROOT}/../../local/bin" ] ; then
        export SST_TEST_INSTALL_BIN=${SST_ROOT}/../../local/bin
    else
        echo " ****** Can not locate directory for SST ******"
        echo " Set SST_INSTALL_BIN to location of SST   (and export)"
        exit 1
    fi

fi
# Find location of SST externals installation
    if [[ ${SST_TEST_INSTALL_PACKAGES:+isSet} != isSet ]] ; then
        SST_TEST_INSTALL_PACKAGES=$SST_TEST_INSTALL_BIN/../packages
    fi

# Location of test directory in SVN tree
#    Honor alternate user defined location of SST_TEST_ROOT
if [[ ${SST_TEST_ROOT:+isSet} != isSet ]]
then
    export SST_TEST_ROOT=${SST_ROOT}/test
fi
# Location of various test driver include files
export SST_TEST_INCLUDE=${SST_TEST_ROOT}/include
# Location of test suite scripts
export SST_TEST_SUITES=${SST_TEST_ROOT}/testSuites
# Location of reference files; SUT output files will be compared
# against files in this directory
export SST_TEST_REFERENCE=${SST_TEST_ROOT}/testReferenceFiles
# Location of miscellaneous SUT input files, if needed
export SST_TEST_INPUTS=${SST_TEST_ROOT}/testInputFiles
# Location of SDL input files, if needed
export SST_TEST_SDL_FILES=${SST_TEST_INPUTS}/testSdlFiles
# Location of various temporary SUT input files
export SST_TEST_INPUTS_TEMP=${SST_TEST_INPUTS}/testInputsTemporary
# Location where SUT output files will be placed
export SST_TEST_OUTPUTS=${SST_TEST_ROOT}/testOutputs
# Location where XML test reports will be placed for Bamboo
export SST_TEST_RESULTS=${SST_TEST_ROOT}/test-reports
# Location of test utility scripts
export SST_TEST_UTILITIES=${SST_TEST_ROOT}/utilities
# Location of shunit2 root
export SHUNIT2_ROOT=${SST_TEST_UTILITIES}/shunit2 #link to actual shunit2 dir
# Location of shunit2 source files
export SHUNIT2_SRC=${SHUNIT2_ROOT}/src
# Adjust path for Bamboo install preferences
export PATH=${PATH}:/usr/local/bin

# Define the path to the Elements Reference files
if [[ ${SST_REFERENCE_ELEMENTS:+isSet} != isSet ]] ; then
   export SST_REFERENCE_ELEMENTS=$SST_ROOT/sst-elements/src/sst/elements
fi

# Location of external test files
export SST_TEST_EXTERNAL_INPUT_FILES=${HOME}/sstDeps/test/inputFiles
# Location of external test input files for prospero
export SST_TEST_EXTERNAL_INPUT_FILES_PROSPERO=${SST_TEST_EXTERNAL_INPUT_FILES}/prospero

#===============================================================================
# System definitions
#===============================================================================

SST_TEST_HOST_OS_KERNEL="$(uname -s)"
SST_TEST_HOST_OS_KERNEL_VERSION="$(uname -r)"
SST_TEST_HOST_OS_KERNEL_ARCH="$(uname -p)"
export SST_TEST_HOST_OS_KERNEL
export SST_TEST_HOST_OS_KERNEL_VERSION
export SST_TEST_HOST_OS_KERNEL_ARCH

# Get distrib and version
if [[ "${SST_TEST_HOST_OS_KERNEL}" == "Darwin" ]]
then
    # This is Darwin. Always check for Darwin first, since the checks
    # for Linux platform information contin GNU-isms that may not be
    # supported on MacOS
    export SST_TEST_HOST_OS_DISTRIB="MacOS"
    SST_TEST_HOST_OS_DISTRIB_VERSION="$(sw_vers -productVersion)"
    export SST_TEST_HOST_OS_DISTRIB_VERSION
    export SST_TEST_HOST_OS_DISTRIB_MACOS=1

elif [ -r /etc/centos-release ]
then
    # The presence of this file means this is CentOS, a Red Hat derivative
    SST_TEST_HOST_OS_DISTRIB="$(cut -d " " -f1 /etc/centos-release)"
    export SST_TEST_HOST_OS_DISTRIB
    SST_TEST_HOST_OS_DISTRIB_VERSION="$(cut -d " " -f3 /etc/centos-release)"
    export SST_TEST_HOST_OS_DISTRIB_VERSION
    export SST_TEST_HOST_OS_DISTRIB_CENTOS=1

elif [ -r /etc/toss-release ]
then
    # The presence of this file means this is TOSS, a Red Hat derivative
    SST_TEST_HOST_OS_DISTRIB="$(< /etc/toss-release sed 's|\([^-]\+\)\(-release.*\)|\1|')"
    export SST_TEST_HOST_OS_DISTRIB
    SST_TEST_HOST_OS_DISTRIB_VERSION="$(< /etc/toss-release sed 's|toss-release-\(.\+\)|\1|')"
    export SST_TEST_HOST_OS_DISTRIB_VERSION
    export SST_TEST_HOST_OS_DISTRIB_TOSS=1

elif   [ -r /etc/lsb-release ]
then
    # The presence of this file (after checking for
    # distribution-specific platform information files) indicates an
    # attempt at Linux Standards Base (LSB) compliance.

    # Always check for distribution-specific platform information
    # files before checking for /etc/lsb-release, as a distribution
    # may contain both, and distribution-specific platform files
    # typically contain more detailed information.

    # !!! It seems there is no agreement on the content and format of
    # !!! the "lsb-release" file! The following logic is only known to
    # !!! work on Ubuntu's "lsb-release" file.

    SST_TEST_HOST_OS_DISTRIB=$(< /etc/lsb-release grep DISTRIB_ID | sed 's|\(^DISTRIB_ID=\)\(.\+\)|\2|')
    export SST_TEST_HOST_OS_DISTRIB
    SST_TEST_HOST_OS_DISTRIB_VERSION=$(< /etc/lsb-release grep DISTRIB_RELEASE | sed 's|\(^DISTRIB_RELEASE=\)\(.\+\)|\2|')
    export SST_TEST_HOST_OS_DISTRIB_VERSION
    if [[ "${SST_TEST_HOST_OS_DISTRIB}" == "Ubuntu" ]]
    then
        # Set this if this is Ubuntu, a Debian derivative
        export SST_TEST_HOST_OS_DISTRIB_UBUNTU=1

        # Of course, add other LSB-compliant Linuxes here...
    else
        export SST_TEST_HOST_OS_UNKNOWN=1
    fi

else
    # worst case
    export SST_TEST_HOST_OS_DISTRIB="unknown"
    export SST_TEST_HOST_OS_DISTRIB_VERSION="unknown"
    export SST_TEST_HOST_OS_DISTRIB_UNKNOWN=1

fi

#===============================================================================
# Build type definitions
#===============================================================================

# Check SST build type preferences
if [[ ${SST_BUILD_TYPE_USER:+isSet} = isSet ]]
then
    # Let user's environment determine value
    # NOTE: if you create a new build type, be sure to update bamboo.sh also!
    export SST_TEST_BUILD_TYPE=$SST_BUILD_TYPE_USER

elif [[ ${SST_BUILD_TYPE:+isSet} = isSet ]] && [[ ${SST_BUILD_TYPE_USER:+isSet} != isSet ]]
then
    # Use SST_BUILD_TYPE since user has not specified an override
    export SST_TEST_BUILD_TYPE=$SST_BUILD_TYPE

elif [[ ${SST_BUILD_TYPE:+isSet} != isSet ]] && [[ ${SST_BUILD_TYPE_USER:+isSet} != isSet ]]
then
    # Worst case scenario: Neither value has been set, so assume a
    # default SST build type
    export SST_TEST_BUILD_TYPE=default

fi


# DEBUG <begin>
# echo "DBG testDefinitions.sh:  SST_ROOT = ${SST_ROOT}"
# echo "DBG testDefinitions.sh:  SST_TEST_INSTALL_BIN = ${SST_TEST_INSTALL_BIN}"
# echo "DBG testDefinitions.sh:  SST_TEST_BUILD_TYPE = ${SST_TEST_BUILD_TYPE}"
# echo "DBG testDefinitions.sh:  SST_TEST_ROOT = ${SST_TEST_ROOT}"
# echo "DBG testDefinitions.sh:  SST_TEST_INCLUDE = ${SST_TEST_INCLUDE}"
# echo "DBG testDefinitions.sh:  SST_TEST_SUITES = ${SST_TEST_SUITES}"
# echo "DBG testDefinitions.sh:  SST_TEST_REFERENCE = ${SST_TEST_REFERENCE}"
# echo "DBG testDefinitions.sh:  SST_TEST_INPUTS = ${SST_TEST_INPUTS}"
# echo "DBG testDefinitions.sh:  SST_TEST_SDL_FILES = ${SST_TEST_SDL_FILES}"
# echo "DBG testDefinitions.sh:  SST_TEST_INPUTS_TEMP = ${SST_TEST_INPUTS_TEMP}"
# echo "DBG testDefinitions.sh:  SST_TEST_OUTPUTS = ${SST_TEST_OUTPUTS}"
# echo "DBG testDefinitions.sh:  SST_TEST_RESULTS = ${SST_TEST_RESULTS}"
# echo "DBG testDefinitions.sh:  SST_TEST_UTILITIES = ${SST_TEST_UTILITIES}"
# echo "DBG testDefinitions.sh:  SHUNIT2_ROOT = ${SHUNIT2_ROOT}"
# echo "DBG testDefinitions.sh:  SHUNIT2_SRC = ${SHUNIT2_SRC}"
# DEBUG <end>

###############
# This is the wrong place for this.
#   Better in bamboo.sh than here.
#     I tried to put it in testSubroutines,
#        but testSubroutines is loaded only in Suites.
#           testDefinitions is loaded in bamboo.sh
#
#     Revised  October 30, 2015, Sept. 27, 2017
######################################
multithread_multirank_patch_Suites() {
    echo "multithread_multirank_patch_Suites: "
    SET_TL=0
    if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] ; then
        if [ "${SST_MULTI_THREAD_COUNT}" -eq 0 ] ; then
            echo " There is a zero -n count, Set to 1 "
            export SST_MULTI_THREAD_COUNT=1
        else
            if [ "${SST_MULTI_THREAD_COUNT}" -gt 1 ] ; then
                SET_TL=1
            fi
        fi
    fi


    if [[ ${SST_MULTI_RANK_COUNT:+isSet} == isSet ]] ; then

        if [ "${SST_MULTI_RANK_COUNT}" -eq 0 ] ; then
            echo " There is a zero rank count, Set to 1 "
            export SST_MULTI_RANK_COUNT=1
        fi
        if [ "${SST_MULTI_RANK_COUNT}" -gt 1 ] ; then
            SET_TL=1
        fi
    fi

    if [ $SET_TL -eq 1 ] ; then
        echo "Set SST_MULTI_CORE=1"
        export SST_MULTI_CORE=1
    fi
}

set_map-by_parameter() {
    if [[ "${SST_TEST_HOST_OS_KERNEL}" == "Darwin" ]] ; then
        ncores="$(sysctl -n hw.ncpu)"
    else
        ncores="$(< /proc/cpuinfo grep -c processor)"
    fi

    echo "  Number of cores = ${ncores}"

    if [ "$ncores" -eq 1 ] ; then
        NUMA_PARAM=" "
    elif [ "$ncores" -ge 2 ] && [ "$ncores" -le 4 ] ; then
        NUMA_PARAM="-map-by numa:pe=2 -oversubscribe"
    elif [ "$ncores" -ge 4 ] ; then
        NUMA_PARAM="-map-by numa:pe=2"
    fi
    export NUMA_PARAM
    echo "   NUMA PARAM = ${NUMA_PARAM}"
}
