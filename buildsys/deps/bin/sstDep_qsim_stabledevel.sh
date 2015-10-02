# !/bin/bash
# sstDep_qsim_stabledevel.sh

# Description: 

# A bash script containing functions to process SST's Qsim dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Qsim
export SST_BUILD_QSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_QSIM_STABLEDEVEL=1
#===============================================================================
# Qsim
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_qsim
# Purpose:
#     Prepare Qsim code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged Qsim code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_QSIM=${SST_DEPS_SRC_STAGING}/Qsim_stabledevel
sstDepsStage_qsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging Qsim stabledevel"

    # fetch latest from Qsim repository
    pushd ${SST_DEPS_SRC_STAGING}

    # if [[ ${SST_DEPS_BUILD_WITH_ORIG_REPOS:+isSet} != isSet ]]
    # then
    #     # if SST_DEPS_BUILD_WITH_ORIG_REPOS is not set or is empty, clone from mirror
    #     svn co svn://s917191.sandia.gov/qsim/trunk Qsim_stabledevel
    # else
    #     # checkout from the original source repository
    #     svn co https://sst-simulator.googlecode.com/svn/qsim/trunk Qsim_stabledevel
    # fi
    git clone https://github.com/cdkersey/qsim.git Qsim_stabledevel

    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_qsim_stabledevel.sh: Qsim repository fetch failure"
        sstDepsAnnounce -h $FUNCNAME -m "Is the SVN http proxy configured properly?"
        popd
        return $retval
    fi

    cp Qsim_stabledevel/remote/client/qsim-client.h  Qsim_stabledevel
    cp Qsim_stabledevel/remote/qsim-net.h            Qsim_stabledevel

    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_qsim
# Purpose:
#     Build and install SST Qsim dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed Qsim dependency
# Caveats:
#     Depends on Boost, and Boost depends on an MPI selection, so both need to
#     to be built before successful build of Qsim.
#-------------------------------------------------------------------------------
sstDepsDeploy_qsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying Qsim stabledevel"

    pushd ${SST_DEPS_SRC_STAGED_QSIM}

    # Configure qsim client installation root
    export QSIM_PREFIX=${SST_DEPS_INSTALL_DEPS}

    # QSim requries QEMU. NOTE: getqemu.sh will either use a local
    # copy of the QEMU tarfile if a usable one is available, or it
    # will attempt to fetch one from the network.

    local tarfile="qemu-0.12.3.tar.gz"
    if [ -r ${SST_DEPS_SRC_PRISTINE}/${tarfile} ]
    then
        # If a local copy exists, create a link to it
        sstDepsAnnounce -h $FUNCNAME -m "Local copy of ${tarfile} found, getqemu.sh will attempt to use it."
        ln -s ${SST_DEPS_SRC_PRISTINE}/${tarfile} ./${tarfile}
        ls -l ./${tarfile}
    else
        sstDepsAnnounce -h $FUNCNAME -m "Local copy of ${tarfile} NOT found in ${SST_DEPS_SRC_PRISTINE}, getqemu.sh will try to fetch one from network."
    fi
    
    ./getqemu.sh
    pushd qemu-0.12.3
    make
    popd

    # Configure qsim client installation root
    export QSIM_PREFIX=${SST_DEPS_INSTALL_DEPS}/packages/Qsim

    # Build and install qsim client
    sstDepsAnnounce -h $FUNCNAME -m "Installing qsim stabledevel"
    make install
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_qsim_stabledevel.sh: qsim make install failure"
        popd
        return $retval
    fi

    popd
}

# Installation location of Qsim (installation root)
export SST_DEPS_INSTALL_QSIM=${SST_DEPS_INSTALL_DEPS}/packages/Qsim
export SST_DEPS_SRC_STAGED_QSIM=${SST_DEPS_SRC_STAGING}/Qsim_stabledevel
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_qsim
# Purpose:
#     Query SST Qsim dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported Qsim dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_qsim ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_QSIM=\"REPOSITORY\""
    echo "export SST_DEPS_INSTALL_QSIM=\"${SST_DEPS_INSTALL_QSIM}\""
}
