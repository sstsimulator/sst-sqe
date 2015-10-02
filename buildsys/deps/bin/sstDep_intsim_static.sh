# !/bin/bash
# sstDep_intsim_static.sh

# Description: 

# A bash script containing functions to process SST's IntSim
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to IntSim
export SST_BUILD_INTSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_INTSIM_STATIC=1
#===============================================================================
# IntSim
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_intsim
# Purpose:
#     Prepare IntSim for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged IntSim code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_INTSIM=${SST_DEPS_SRC_STAGING}/libIntSim
sstDepsStage_intsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging IntSim static"

    # Copy source tree from working copy. Once completed, files should be available in
    # $SST_DEPS_SRC_STAGED_INTSIM
    cp -R ${SST_ROOT}/deps/src/intsim ${SST_DEPS_SRC_STAGED_INTSIM}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_intsim_static.sh: IntSim source copy failure"
        return $retval
    fi

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_intsim
# Purpose:
#     Build and install SST IntSim dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed IntSim dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_intsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying IntSim static"

    pushd ${SST_DEPS_SRC_STAGED_INTSIM}

    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_intsim_static.sh: IntSim make failure"
        return $retval
    fi


    # NOTE: There should be a "make install", but due to
    # idiosyncrasies of DRAMSim integration, this is how it is
    # installed
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_INTSIM} ${SST_DEPS_INSTALL_DEPS}/packages/IntSim
    mkdir -p ${SST_DEPS_INSTALL_DEPS}/lib
    ln -s ${SST_DEPS_SRC_STAGED_INTSIM}/*.so ${SST_DEPS_INSTALL_DEPS}/lib


    popd

}


# Installation location as used by SST's "./configure --with-IntSim=..."
export SST_DEPS_INSTALL_INTSIM=${SST_DEPS_INSTALL_DEPS}/packages/IntSim
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_intsim
# Purpose:
#     Query SST IntSim dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported IntSim dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_intsim ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_INTSIM=\"UNKNOWN STATIC VERSION\""
    echo "export SST_DEPS_INSTALL_INTSIM=\"${SST_DEPS_INSTALL_INTSIM}\""
}
