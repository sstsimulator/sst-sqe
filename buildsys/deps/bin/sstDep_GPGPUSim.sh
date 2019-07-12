# !/bin/bash
# sstDep_GPGPUSim.sh

# Description:

# A bash script containing functions to process SST's GPGPUSim
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to GPGPUSim
export SST_BUILD_GPGPUSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_GPGPUSIM_V_9_1_85=1
#===============================================================================
# GPGPUSim
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_GPGPUSim-cuda
# Purpose:
#     Prepare patching.
# Inputs:
#     None
# Outputs:
#
# Expected Results
#
# Caveats:
#     No patching is anticipated!  Cuda library is from module.
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_GPGPUSIM="${SST_ROOT}/sst-elements/src/sst/elements/Gpgpusim/sst-gpgpusim"
sstDepsStage_GPGPUSim-cuda ()
{

      sstDepsAnnounce -h $FUNCNAME -m "Staging cuda/9.1.85"

      module add cuda/9.1.85
      module list

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_GPGPUSim-cuda
# Purpose:
#     Build and install GPGPUSim
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed DRAMSim dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_GPGPUSim-cuda ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying GPGPUSim"

    pushd $SST_DEPS_SRC_STAGED_GPGPUSIM

    module li

    source setup_environment
    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        pwd
        echo "ERROR: sstDep_GPGPUSim.sh: make failure"
        return $retval
    fi

    echo "Copying shared object to element directory ${SST_ROOT}/sst-elements/src/sst/elements/Gpgpusim"
    cp --preserve=links lib/$GPGPUSIM_CONFIG/libcudart_mod.so ${SST_ROOT}/sst-elements/src/sst/elements/Gpgpusim

    ls -l ${SST_ROOT}/sst-elements/src/sst/elements/Gpgpusim

    popd

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_GPGPUSim-cuda
# Purpose:
#
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_GPGPUSim-cuda ()
{
    # provide version and installation location info
   echo "export SST_DEPS_VERSION_GPGPUSIM_CUDA=\"${CUDA_VERS}\""
   export SST_DEPS_VERSION_GPGPUSIM_CUDA=${CUDA_VERS}
   echo "export SST_DEPS_INSTALL_GPGPUSIM=\"${SST_DEPS_SRC_STAGED_GPGPUSIM}\""
   export SST_DEPS_INSTALL_GPGPUSIM=${SST_DEPS_SRC_STAGED_GPGPUSIM}

}
