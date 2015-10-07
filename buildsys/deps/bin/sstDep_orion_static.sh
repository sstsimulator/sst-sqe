# !/bin/bash
# sstDep_orion_static.sh

# Description: 

# A bash script containing functions to process SST's ORION
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to ORION
export SST_BUILD_ORION=1
# Environment variable uniquely identifying this script
export SST_BUILD_ORION_STATIC=1
#===============================================================================
# ORION
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_orion
# Purpose:
#     Prepare ORION for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged ORION code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_ORION=${SST_DEPS_SRC_STAGING}/libORION
sstDepsStage_orion ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging ORION static"

    # Copy source tree from working copy. Once completed, files should be available in
    # $SST_DEPS_SRC_STAGED_ORION
    cp -R ${SST_ROOT}/deps/src/orion ${SST_DEPS_SRC_STAGED_ORION}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_orion_static.sh: ORION source copy failure"
        return $retval
    fi

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_orion
# Purpose:
#     Build and install SST ORION dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed ORION dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_orion ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying ORION static"

    pushd ${SST_DEPS_SRC_STAGED_ORION}

    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_orion_static.sh: ORION make failure"
        return $retval
    fi



    # NOTE: There should be a "make install", but due to
    # idiosyncrasies of DRAMSim integration, this is how it is
    # installed
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_ORION} ${SST_DEPS_INSTALL_DEPS}/packages/ORION
    mkdir -p ${SST_DEPS_INSTALL_DEPS}/lib
    ln -s ${SST_DEPS_SRC_STAGED_ORION}/*.so ${SST_DEPS_INSTALL_DEPS}/lib

    popd

}


# Installation location as used by SST's "./configure --with-orion=..."
export SST_DEPS_INSTALL_ORION=${SST_DEPS_INSTALL_DEPS}/packages/ORION
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_orion
# Purpose:
#     Query SST ORION dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported ORION dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_orion ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_ORION=\"UNKNOWN STATIC VERSION\""
    echo "export SST_DEPS_INSTALL_ORION=\"${SST_DEPS_INSTALL_ORION}\""
}

