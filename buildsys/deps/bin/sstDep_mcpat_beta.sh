# !/bin/bash
# sstDep_mcpat_beta.sh

# Description: 

# A bash script containing functions to process SST's McPAT
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to McPAT
export SST_BUILD_MCPAT=1
# Environment variable uniquely identifying this script
export SST_BUILD_MCPAT_BETA=1
#===============================================================================
# McPAT
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_mcpat
# Purpose:
#     Prepare McPAT for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged McPAT code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_MCPAT=${SST_DEPS_SRC_STAGING}/libMcPATbeta
sstDepsStage_mcpat ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging McPAT beta"

    # Copy source tree from working copy. Once completed, files should be available in
    # $SST_DEPS_SRC_STAGED_MCPAT
    cp -R ${SST_ROOT}/deps/src/mcpat ${SST_DEPS_SRC_STAGED_MCPAT}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_mcpat_beta.sh: McPAT source copy failure"
        return $retval
    fi

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_mcpat
# Purpose:
#     Build and install SST McPAT dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed McPAT dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_mcpat ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying McPAT beta"

    pushd ${SST_DEPS_SRC_STAGED_MCPAT}

    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_mcpat_beta.sh: McPAT make failure"
        return $retval
    fi

    # NOTE: There should be a "make install", but due to
    # idiosyncrasies of DRAMSim integration, this is how it is
    # installed
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_MCPAT} ${SST_DEPS_INSTALL_DEPS}/packages/McPAT
    mkdir -p ${SST_DEPS_INSTALL_DEPS}/lib
    ln -s ${SST_DEPS_SRC_STAGED_MCPAT}/*.so ${SST_DEPS_INSTALL_DEPS}/lib


    popd

}

# Installation location as used by SST's "./configure --with-McPAT=..."
export SST_DEPS_INSTALL_MCPAT=${SST_DEPS_INSTALL_DEPS}/packages/McPAT
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_mcpat
# Purpose:
#     Query SST McPAT dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported McPAT dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_mcpat ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_MCPAT=\"BETA\""
    echo "export SST_DEPS_INSTALL_MCPAT=\"${SST_DEPS_INSTALL_MCPAT}\""
}
