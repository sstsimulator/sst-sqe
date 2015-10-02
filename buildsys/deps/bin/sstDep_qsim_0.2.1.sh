# !/bin/bash
# sstDep_qsim_0.2.1.sh

# Description: 

# A bash script containing functions to process SST's Qsim dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Qsim
export SST_BUILD_QSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_QSIM_0_2_1=1
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
export SST_DEPS_SRC_STAGED_QSIM=${SST_DEPS_SRC_STAGING}/qsim-0.2.1
sstDepsStage_qsim ()
{
    local tarFile="0.2.1.tar.gz"
    knownSha1=11c20eef50581d2ec051220abddd05c7b9b89e14

    sstDepsAnnounce -h $FUNCNAME -m "Staging qsim from ${tarFile}."

    if [ ! -r "${SST_DEPS_SRC_PRISTINE}/${tarFile}" ]
    then
        # Tarfile can't be read, exit.
        echo "ERROR: (${FUNCNAME})  Can't read ${SST_DEPS_SRC_PRISTINE}/${tarFile}. Is it installed?"
        return 1
    fi

    # Validate tar file against known SHA1
    sstDepsCheckSha1 -f ${SST_DEPS_SRC_PRISTINE}/${tarFile} -h ${knownSha1}
    if [ $? -ne 0 ]
    then
        return 1
    fi

    # Extract tarfile. The directory created by this operation is
    # captured in the environment variable preceeding this function
    tar xfz ${SST_DEPS_SRC_PRISTINE}/${tarFile} -C ${SST_DEPS_SRC_STAGING}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: (${FUNCNAME})  ${tarFile} untar failure"
        return $retval
    fi
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
    sstDepsAnnounce -h $FUNCNAME -m "Deploying Qsim 0.2.1"

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


    local compiler=`basename "${CXX}"`

    # Based on compiler, patch getqemu.sh to build QEMU with
    # compiler defined in CC environment variable
    if [ ${SST_DEPS_OS_NAME} = "Darwin" ]
    then
        sstDepsAnnounce -h $FUNCNAME -m "CC=${CC}"

        if [[ ${compiler} =~ clang.* ]]
        then
            # patch configure line in getqemu.sh for CLANG compiler on Mac OS X
            echo "INFO: (${FUNCNAME})  CLANG compiler detected in CC. Patching getqemu.sh for clang/clang++..."
            sed -i .bak1 -e 's/configure/configure --cc=${CC} --host-cc=${CC} /' getqemu.sh
        fi
    elif [ ${SST_DEPS_OS_NAME} = "Linux" ]
    then
        # if using Intel compiler
        if [[ ${compiler} =~ icpc.* ]]
        then
            # patch Makefile for Intel compiler on Linux 
            echo "INFO: (${FUNCNAME})  Intel compiler detected in CC. Patching getqemu.sh for icc/icpc..."
            sed -i.bak1 -e 's/configure/configure --cc=${CC} --host-cc=${CC} /' getqemu.sh

        fi
    fi

    # Apply patch for file open problem
    echo "INFO: (${FUNCNAME})  Patching qsim-0.2.1/mgzd.h..."
    patch -i ${SST_DEPS_PATCHFILES}/qsim-0.2.1-fileOpenCheck.patch
    
    ./getqemu.sh
    pushd qemu-0.12.3
    make > qemu.output 2>1
    popd

    # Configure qsim client installation root
    export QSIM_PREFIX=${SST_DEPS_INSTALL_DEPS}/packages/Qsim

    # Build and install qsim client
    sstDepsAnnounce -h $FUNCNAME -m "Installing qsim 0.2.1"


    make install
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_qsim_0.2.1.sh: qsim make install failure"
        popd
        return $retval
    fi

    popd
}

# Installation location of Qsim (installation root)
export SST_DEPS_INSTALL_QSIM=${SST_DEPS_INSTALL_DEPS}/packages/Qsim
export SST_DEPS_SRC_STAGED_QSIM=${SST_DEPS_SRC_STAGING}/qsim-0.2.1
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
    echo "export SST_DEPS_VERSION_QSIM=0.2.1"
    echo "export SST_DEPS_INSTALL_QSIM=\"${SST_DEPS_INSTALL_QSIM}\""
}
