# !/bin/bash
# sstDep_gpgpusim.sh

# Description:

# A bash script containing functions to process SST's GPGPUSim
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to GPGPUSim
export SST_BUILD_GPGPUSIM=1

GPGPU_BRANCH=$1
#===============================================================================
# GPGPUSim
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_GPGPUSim
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
export SST_DEPS_SRC_STAGED_GPGPUSIM=${SST_DEPS_SRC_STAGING}/sst-gpgpusim

sstDepsStage_GPGPUSim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging sst-gpgpusim branch ${GPGPU_BRANCH}"

    pushd ${SST_DEPS_SRC_STAGING}

    Num_Tries_remaing=3
    while [ $Num_Tries_remaing -gt 0 ]
    do
        echo " "
        date
        echo ' '
        echo "git clone https://github.com/accel-sim/gpgpu-sim_distribution.git"
        git clone https://github.com/accel-sim/gpgpu-sim_distribution.git
        retVal=$?
        echo ' '
        date
        echo ' '
        if [ $retVal == 0 ] ; then
            Num_Tries_remaing=-1
        else
            echo "\"git clone of sst-gpgpusim \" FAILED.  retVal = $retVal"
            Num_Tries_remaing=$(($Num_Tries_remaing - 1))
            if [ $Num_Tries_remaing -gt 0 ] ; then
                echo "    ------   RETRYING    $Num_Tries_remaing "
                rm -rf sst-gpgpusim
                continue                        ## Try another
            fi
            return $retVal
        fi
    done
    echo " "

    if [ $retVal -ne 0 ]                     ## retVal from git clone
    then
        # bail out on error
        echo "ERROR: sstDep_gpgpusim.sh: sst-gpgpusim git fetch failure"
        sstDepsAnnounce -h $FUNCNAME -m \
          "Is http_proxy configured properly in $HOME/.wgetrc?"
        popd
        return $retVal
    fi

    #  Move into the sst-gpgpusim directory
    pushd ${SST_DEPS_SRC_STAGED_GPGPUSIM}
    git checkout $GPGPU_BRANCH
    echo "sst-gpgpusim.git" `git log HEAD | sed 4q` >&2
    ls -l

    popd
    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_GPGPUSim
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
sstDepsDeploy_GPGPUSim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying GPGPUSim"

    pushd $SST_DEPS_SRC_STAGED_GPGPUSIM

    module li

    source setup_environment sst
    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        pwd
        echo "ERROR: sstDep_gpgpusim.sh: make failure"
        return $retval
    fi

    echo "Copying libcudart_mod.so shared object to element directory ${SST_ROOT}/sst-elements/src/sst/elements/balar"
    cp --preserve=links lib/$GPGPUSIM_CONFIG/libcudart_mod.so ${SST_ROOT}/sst-elements/src/sst/elements/balar

    ls -l ${SST_ROOT}/sst-elements/src/sst/elements/balar

    popd

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_GPGPUSim
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
sstDepsQuery_GPGPUSim ()
{
    # provide version and installation location info
   echo "export SST_DEPS_VERSION_GPGPUSIM_BRACH=\"${GPGPU_BRANCH}\""
   export SST_DEPS_VERSION_GPGPUSIM_BRANCH=${GPGPU_BRANCH}

   echo "export SST_DEPS_INSTALL_GPGPUSIM=\"${SST_DEPS_SRC_STAGED_GPGPUSIM}\""
   export SST_DEPS_INSTALL_GPGPUSIM=${SST_DEPS_SRC_STAGED_GPGPUSIM}

}
