# !/bin/bash
# sstDep_sstmacro_2.4.0-beta1.sh

# Description: 

# A bash script containing functions to process SST's sstmacro
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to sstmacro
export SST_BUILD_SSTMACRO=1
# Environment variable uniquely identifying this script
export SST_BUILD_SSTMACRO_2_4_0_BETA1=1
#===============================================================================
# SSTMACRO
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_sstmacro
# Purpose:
#     Prepare sstmacro for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged sstmacro code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_SSTMACRO_2_4_0_BETA1=${SST_DEPS_SRC_STAGING}/sstmacro-2.4.0-beta1
sstDepsStage_sstmacro ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging sstmacro 2.4.0-beta1"

    # Extract tarfile. Once unpacked, files should be available in
    # $SST_DEPS_SRC_STAGED_SSTMACRO
    tar xfz ${SST_DEPS_SRC_PRISTINE}/sstmacro-2.4.0-beta1.tar.gz -C ${SST_DEPS_SRC_STAGING}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_sstmacro_2.4.0-beta1.sh: sstmacro untar failure"
        return $retval
    fi

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_sstmacro
# Purpose:
#     Build and install SST sstmacro dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed sstmacro dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_sstmacro ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying sstmacro 2.4.0-beta1"
    pushd ${SST_DEPS_SRC_STAGED_SSTMACRO_2_4_0_BETA1}

    ./bootstrap.sh
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_sstmacro_2.4.0-beta1.sh: sstmacro bootstrap.sh failure"
        return $retval
    fi

    # Follow sstmacro installation directions (bootstrap.sh, configure, make, make install)
    ./configure --prefix=${SST_DEPS_INSTALL_DEPS} --with-boost=${SST_DEPS_INSTALL_BOOST} --with-sst CC=`which gcc` CXX=`which g++`
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_sstmacro_2.4.0-beta1.sh: sstmacro configure failure"
        echo "       sstmacro requires boost. Is Boost installed?"
        return $retval
    fi

    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_sstmacro_2.4.0-beta1.sh: sstmacro make failure"
        echo "       sstmacro requires boost. Is Boost installed?"
        return $retval
    fi

    make install
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_sstmacro_2.4.0-beta1.sh: sstmacro install failure"
        return $retval
    fi

    popd

}

# Installation location 
export SST_DEPS_INSTALL_SSTMACRO=${SST_DEPS_INSTALL_DEPS}
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_sstmacro
# Purpose:
#     Query sstmacro dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported sstmacrodependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_sstmacro ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_SSTMACRO=\"2.4.0-beta1\""
    echo "export SST_DEPS_INSTALL_SSTMACRO=\"${SST_DEPS_INSTALL_SSTMACRO}\""
}

