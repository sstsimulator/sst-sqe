# !/bin/bash
# sstDep_dramsim_r4b00b22.sh

# Description:

# A bash script containing functions to process SST's DRAMSim
# dependency.

# 2012-DEC-12
#     Repository revision 4b00b228abaa9d9dcd27ffbb48cfa71db53d520f of
#     DRAMSim is used by SST version 2.2.x in lieu of a tagged release
#     version.  See 4b00b22... commit comments for further information.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to DRAMSim
export SST_BUILD_DRAMSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_DRAMSIM_R4B00B22=1
#===============================================================================
# DRAMSim
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_dramsim
# Purpose:
#     Prepare DRAMSim (DRAM simulator) code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged DRAMSim code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_DRAMSIM=${SST_DEPS_SRC_STAGING}/DRAMSim2
sstDepsStage_dramsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging DRAMSim rev 4b00b228abaa9d9dcd27ffbb48cfa71db53d520f"

    # fetch latest from DRAMSim2 repository
    pushd ${SST_DEPS_SRC_STAGING}
    git clone https://github.com/dramninjasUMD/DRAMSim2.git

    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_dramsim_r4b00b22.sh: DRAMSim repository fetch failure"
        sstDepsAnnounce -h $FUNCNAME -m "Try setting git's http.proxy attribute to your proxy. $ git config --global http.proxy http://myhttproxy:proxyport"
        return $retval
    fi

    # Obtain DRAMSim2 git HEAD commit info
    pushd ${SST_DEPS_SRC_STAGED_DRAMSIM}

    git reset --hard 4b00b228abaa9d9dcd27ffbb48cfa71db53d520f

#    local dramsimHeadRevision=`git log -1 HEAD | head -1`
    popd
    sstDepsAnnounce -h $FUNCNAME -m "Fetched DRAMSim2 rev 4b00b228abaa9d9dcd27ffbb48cfa71db53d520f"

    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_dramsim
# Purpose:
#     Build and install SST DRAMSim dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed DRAMSim dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_dramsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying DRAMSim rev 4b00b228abaa9d9dcd27ffbb48cfa71db53d520f"

    pushd ${SST_DEPS_SRC_STAGED_DRAMSIM}

    export SST_DEPS_DRAMSIM_ROOT_DIR=${SST_DEPS_INSTALL_DEPS}/packages

    make clean
    if [ $SST_DEPS_OS_NAME = "Darwin" ]
    then
        # MacOSX idiosyncrasy
        targetlib="libdramsim.dylib"
    else
        targetlib="libdramsim.so"
    fi
    make $targetlib
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_dramsim_r4b00b22.sh: libdramsim make failure"
        return $retval
    fi

    # NOTE: There should be a "make install", but due to
    # idiosyncrasies of DRAMSim integration, this is how it is
    # installed
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_DRAMSIM} ${SST_DEPS_INSTALL_DEPS}/packages/DRAMSim

    popd

}

# Installation location as used by SST's "./configure --with-dramsim=..."
export SST_DEPS_INSTALL_DRAMSIM=${SST_DEPS_INSTALL_DEPS}/packages/DRAMSim
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_dramsim
# Purpose:
#     Query SST DRAMSim dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported DRAMSim dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_dramsim ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_DRAMSIM=\"REV_4b00b228abaa9d9dcd27ffbb48cfa71db53d520f\""
    echo "export SST_DEPS_INSTALL_DRAMSIM=\"${SST_DEPS_INSTALL_DRAMSIM}\""
}
