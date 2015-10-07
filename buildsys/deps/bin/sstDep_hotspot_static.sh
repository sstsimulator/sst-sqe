# !/bin/bash
# sstDep_hotspot_static.sh

# Description: 

# A bash script containing functions to process SST's HotSpot
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to HotSpot
export SST_BUILD_HOTSPOT=1
# Environment variable uniquely identifying this script
export SST_BUILD_HOTSPOT_STATIC=1
#===============================================================================
# HotSpot
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_hotspot
# Purpose:
#     Prepare HotSpot for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged HotSpot code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_HOTSPOT=${SST_DEPS_SRC_STAGING}/libHotSpot
sstDepsStage_hotspot ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging HotSpot static"

    # Copy source tree from working copy. Once completed, files should be available in
    # $SST_DEPS_SRC_STAGED_HOTSPOT
    cp -R ${SST_ROOT}/deps/src/hotspot ${SST_DEPS_SRC_STAGED_HOTSPOT}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_hotspot_static.sh: HotSpot source copy failure"
        return $retval
    fi

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_hotspot
# Purpose:
#     Build and install SST HotSpot dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed HotSpot dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_hotspot ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying HotSpot static"

    pushd ${SST_DEPS_SRC_STAGED_HOTSPOT}

    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_hotspot_static.sh: HotSpot make failure"
        return $retval
    fi

    # NOTE: There should be a "make install", but due to
    # idiosyncrasies of DRAMSim integration, this is how it is
    # installed
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_HOTSPOT} ${SST_DEPS_INSTALL_DEPS}/packages/HotSpot
    mkdir -p ${SST_DEPS_INSTALL_DEPS}/lib
    ln -s ${SST_DEPS_SRC_STAGED_HOTSPOT}/*.so ${SST_DEPS_INSTALL_DEPS}/lib

    popd

}

# Installation location as used by SST's "./configure --with-zoltan=..."
export SST_DEPS_INSTALL_HOTSPOT=${SST_DEPS_INSTALL_DEPS}/packages/HotSpot
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_hotspot
# Purpose:
#     Query SST HotSpot dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported HotSpot dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_hotspot ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_HOTSPOT=\"UNKNOWN STATIC VERSION\""
    echo "export SST_DEPS_INSTALL_HOTSPOT=\"${SST_DEPS_INSTALL_HOTSPOT}\""
}
