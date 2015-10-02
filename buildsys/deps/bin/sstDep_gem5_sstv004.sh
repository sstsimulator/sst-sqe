# !/bin/bash
# sstDep_gem5_sstv004.sh

# Description: 

# A bash script containing functions to process SST's gem5
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to gem5
export SST_BUILD_GEM5=1
# Environment variable uniquely identifying this script
export SST_BUILD_GEM5_SSTV004=1
#===============================================================================
# GEM5
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_gem5
# Purpose:
#     Prepare gem5 for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged gem5 code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_GEM5_VERSION_LOCAL="004"
export SST_DEPS_SRC_STAGED_GEM5=${SST_DEPS_SRC_STAGING}/gem5-patched-v${SST_DEPS_GEM5_VERSION_LOCAL}
sstDepsStage_gem5 ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging sstgem5 v004"

    # Extract tarfile. Once unpacked, files should be available in
    # $SST_DEPS_SRC_STAGED_GEM5
    tar xfz ${SST_DEPS_SRC_PRISTINE}/gem5-patched-v${SST_DEPS_GEM5_VERSION_LOCAL}.tar.gz -C ${SST_DEPS_SRC_STAGING}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_gem5_sstv004.sh: gem5 untar failure"
        return $retval
    fi

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_gem5
# Purpose:
#     Build and install SST gem5 dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed gem5 dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_gem5 ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying sstgem5 v004"

    pushd ${SST_DEPS_SRC_STAGED_GEM5}

    # gem5 needs to use SST's nicMmu.h file
    mv src/sim/nicMmu.h src/sim/nicMmu.h.bak
    ln -s ${SST_ROOT}/sst/elements/portals4/ptlNic/nicMmu.h src/sim/nicMmu.h

    # Use "software construct" (scons) to create libgem5_opt.so
    scons -j8 build/X86_SE/libgem5_opt.so
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_gem5_sstv004.sh: gem5 scons failure"
        return $retval
    fi

    # NOTE: There should be a "make install", but due to
    # idiosyncrasies of gem5-sst integration, this is how it is
    # installed
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_GEM5} ${SST_DEPS_INSTALL_DEPS}/packages/gem5-sst

    popd

}

# Installation location as used by SST's "./configure --with-gem5=..."
export SST_DEPS_INSTALL_GEM5SST=${SST_DEPS_INSTALL_DEPS}/packages/gem5-sst/build/X86_SE
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_gem5
# Purpose:
#     Query SST gem5 dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported gem5 dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_gem5 ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_GEM5SST=\"v004\""
    echo "export SST_DEPS_INSTALL_GEM5SST=\"${SST_DEPS_INSTALL_GEM5SST}\""
}

