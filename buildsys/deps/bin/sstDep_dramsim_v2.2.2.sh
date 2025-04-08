# !/bin/bash

# **** UNUSED ****

# sstDep_dramsim_v2.2.2.sh

# Description:

# A bash script containing functions to process SST's DRAMSim
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to DRAMSim
export SST_BUILD_DRAMSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_DRAMSIM_V_2_2_2=1
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
export SST_DEPS_SRC_STAGED_DRAMSIM=${SST_DEPS_SRC_STAGING}/DRAMSim2-2.2.2
sstDepsStage_dramsim ()
{

    tarFile="v2.2.2.tar.gz"
    knownSha1=f3ac3b5c733c9a2c4832f8b751a459f3db5a162b

    sstDepsAnnounce -h $FUNCNAME -m "Staging ${tarFile}."

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
    sstDepsAnnounce -h $FUNCNAME -m "Deploying DRAMSim v2.2.2"

    pushd ${SST_DEPS_SRC_STAGED_DRAMSIM}

    export SST_DEPS_DRAMSIM_ROOT_DIR=${SST_DEPS_INSTALL_DEPS}/packages

    # Patch for Intel and CLANG/LLVM compilers
    # ASSUMPTIONS:
    # 1) CC and CXX env vars have been set (probably by Modules) and are available
    # 2) Linux has GNU sed
    # 3) Mac OS X has BSD sed

    local compiler=`basename "${CXX}"`

    if [ ${SST_DEPS_OS_NAME} = "Darwin" ]
    then
        sstDepsAnnounce -h $FUNCNAME -m "CXX=${CXX}"

        if [[ ${compiler} =~ clang.* ]]
        then
            # patch Makefile for CLANG compiler on Mac OS X
            echo "INFO: (${FUNCNAME})  CLANG compiler detected in CXX. Patching Makefile for clang/clang++..."
            sed -i .bak1 -e 's/g++/$(CXX)/' Makefile
            # I know the alignment looks awful here.
            # DON'T MESS WITH IT! sed wants it that way.
            sed -i .bak2 -e '1i\
CXX=clang++\
' Makefile
        fi
    elif [ ${SST_DEPS_OS_NAME} = "Linux" ]
    then
        # if using Intel compiler
        if [[ ${compiler} =~ icpc.* ]]
        then
            # patch Makefile for Intel compiler on Linux
            echo "INFO: (${FUNCNAME})  Intel compiler detected in CXX. Patching Makefile for icc/icpc..."
            sed -i.bak1 -e 's/g++/$(CXX)/' Makefile
            # I know the alignment looks awful here.
            # DON'T MESS WITH IT! sed wants it that way.
            sed -i.bak2 -e '1i\
CXX=icpc\
' Makefile

        fi
    fi


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
        echo "ERROR: sstDep_dramsim_v2.2.2.sh: libdramsim make failure"
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
    echo "export SST_DEPS_VERSION_DRAMSIM=\"2.2.2\""
    echo "export SST_DEPS_INSTALL_DRAMSIM=\"${SST_DEPS_INSTALL_DRAMSIM}\""
}
