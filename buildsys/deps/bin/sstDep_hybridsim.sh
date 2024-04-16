# !/bin/bash
# sstDep_hybridsim.sh

# Description: 

# A bash script containing functions to process SST's HybridSim
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to HybridSim
export SST_BUILD_HYBRIDSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_HYBRIDSIM_sandia=1
#===============================================================================
# HybridSim
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_hybridsim
# Purpose:
#     Prepare HybridSim (NVDIMM simulator) code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged HybridSim code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_HYBRIDSIM="${SST_DEPS_SRC_STAGING}/HybridSim"
echo "SST STAGING = $SST_DEPS_SRC_STAGING"  >&2
echo "First EXPORT $SST_DEPS_SRC_STAGED_HYBRIDSIM"  >&2
sstDepsStage_hybridsim ()
{

#     New June 24, 2014 using 2.0.1 Release

    tarFile="HybridSim-2.0.1.tar.gz"
    sstDepsAnnounce -h $FUNCNAME -m "Staging ${tarFile}."

    if [ ! -r ${SST_DEPS_SRC_PRISTINE}/${tarFile} ] ; then
echo "##### SST_DEPS_SRC_PRISTINE is ${SST_DEPS_SRC_PRISTINE}"
ls ${SST_DEPS_SRC_PRISTINE}
echo "##### tarFile is ${tarFile}"
        gitRepo="https://github.com/jimstevens2001/HybridSim/archive/v2.0.1.tar.gz"
        sstDepsAnnounce -h $FUNCNAME -m "Staging from ${gitRepo}."

        pushd ${SST_DEPS_SRC_PRISTINE}


        wget ${gitRepo} -O ${tarFile} --no-check-certificate
        retval=$?
        popd
        if [ $retval -ne 0 ] ; then
            # bail out on error
            echo "ERROR: (${FUNCNAME})  wget of tar failed, RETVAL = $retval"
            return $retval
        fi
    fi

    pushd ${SST_DEPS_SRC_STAGING}
    tar -xzf ${SST_DEPS_SRC_PRISTINE}/HybridSim-2.0.1.tar.gz
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: (${FUNCNAME})  untar failed"
        popd
        return $retval
    fi

    mv HybridSim-2.0.1 HybridSim
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: (${FUNCNAME}) move failed"
        ls -l
        popd
        return $retval
    fi

    cd HybridSim
    ls

    popd

    return 0

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_hybridsim
# Purpose:
#     Build and install SST HybridSim dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed HybridSim dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_hybridsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying HybridSim"

    pushd ${SST_DEPS_SRC_STAGED_HYBRIDSIM}

    export SST_DEPS_HYBRIDSIM_ROOT_DIR=${SST_DEPS_INSTALL_DEPS}/packages

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
        targetlib="libhybridsim.dylib"
    else
        targetlib="libhybridsim.so"
    fi
#    make lib
    make $targetlib
    retval=$?
    ls
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_hybridsim.sh: libhybridsim make failure"
        popd
        return $retval
    fi

    # NOTE: There should be a "make install", but due to
    # idiosyncrasies of HybridSim integration, this is how it is
    # installed
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_HYBRIDSIM} ${SST_DEPS_INSTALL_DEPS}/packages/HybridSim

    popd

}

# Installation location as used by SST's "./configure --with-hybridsim=..."
export SST_DEPS_INSTALL_HYBRIDSIM=${SST_DEPS_INSTALL_DEPS}/packages/HybridSim
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_hybridsim
# Purpose:
#     Query SST HybridSim dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported HybridSim dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_hybridsim ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_HYBRIDSIM=\"sandia\""
    echo "export SST_DEPS_INSTALL_HYBRIDSIM=\"${SST_DEPS_INSTALL_HYBRIDSIM}\""
}
