
# sstDep_nvdimmsim.sh

# Description: 

# A bash script containing functions to process SST's NVDIMMSim
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to NVDIMMSim
export SST_BUILD_NVDIMMSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_NVDIMMSIM_master=1
#===============================================================================
# NVDIMMSim
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_nvdimmsim
# Purpose:
#     Prepare NVDIMMSim (NVDIMM simulator) code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged NVDIMMSim code that is ready for patching
# Caveats:
#     The down load file is a tar with no identification except the version name (v2.0.0)
#     It must be renamed by appending a type (.tar.gz)
#     It untars as a tree with a name and version (NVDIMMSim-2.0.0)
#     The tree is moved to version-less NVDIMMSim because hybridsim Makefile has an
#         explicit reference.
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_NVDIMMSIM=${SST_DEPS_SRC_STAGING}/NVDIMMSim
sstDepsStage_nvdimmsim ()
{


#      New May 5, 2014  using 2.0.0 release
  
    tarFile="NVDIMMSim-2.0.0.tar.gz"
    sstDepsAnnounce -h $FUNCNAME -m "Staging ${tarFile}."

echo "##### SST_DEPS_SRC_PRISTINE is ${SST_DEPS_SRC_PRISTINE}"
ls ${SST_DEPS_SRC_PRISTINE}
echo "##### tarFile is ${tarFile}"
ls -l ${SST_DEPS_SRC_PRISTINE}/${tarFile}
    if [ ! -r ${SST_DEPS_SRC_PRISTINE}/${tarFile} ] ; then

        gitRepo="https://github.com/jimstevens2001/NVDIMMSim/archive/v2.0.0.tar.gz"
        sstDepsAnnounce -h $FUNCNAME -m "Staging from ${gitRepo}."

        pushd ${SST_DEPS_SRC_PRISTINE}
        wget ${gitRepo} -O ${tarFile} --no-check-certificate
        retval=$?
        popd
        if [ $retval -ne 0 ] ; then
            # bail out on error
            echo "ERROR: (${FUNCNAME})  ${release}  download failed"
            return $retval
        fi
    fi

    pushd ${SST_DEPS_SRC_STAGING}
    tar -xzf ${SST_DEPS_SRC_PRISTINE}/NVDIMMSim-2.0.0.tar.gz
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: (${FUNCNAME})  untar failed"
        return $retval
    fi
    mv NVDIMMSim-2.0.0 NVDIMMSim

#     Create Link to DramSim where NVDIMMSim expects it to be
    ln -s $SST_DEPS_SRC_STAGED_DRAMSIM DRAMSim2

    cd NVDIMMSim
    ls
    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_nvdimmsim
# Purpose:
#     Build and install SST NVDIMMSim dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed NVDIMMSim dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_nvdimmsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying NVDIMMSim"

    pushd ${SST_DEPS_SRC_STAGED_NVDIMMSIM}/src

    export SST_DEPS_NVDIMMSIM_ROOT_DIR=${SST_DEPS_INSTALL_DEPS}/packages

    # Patch for Intel and CLANG/LLVM compilers
    # ASSUMPTIONS:
    # 1) CC and CXX env vars have been set (probably by Modules) and are available
    # 2) Linux has GNU sed
    # 3) Mac OS X has BSD sed

    local compiler=`basename "${CXX}"`

    if [ ${SST_DEPS_OS_NAME} = "Linux" ]
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

##    make clean     ## make clean is not supported by NVDIMMSim
    if [ $SST_DEPS_OS_NAME = "Darwin" ]
    then
        # MacOSX idiosyncrasy
        targetlib="libnvdsim.dylib"
        if [[ ${compiler} =~ clang.* ]] ; then
            CC=/usr/bin/clang
            CXX=/usr/bin/clang++
            LDFLAGS="lstdc++"
        fi
    else
        targetlib="libnvdsim.so"
    fi
    echo " Verify c++ compiler \$CXX = $CXX"
    echo "   ------------------  do the make"
    make $targetlib
##     make lib   ###this does not include Darwin
    retval=$?
    echo "   --------------------  after the make"
    ls       ##    Display the result of the make
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_nvdimmsim.sh: libnvdimmsim make failure"
        return $retval
    fi

    # NOTE: There should be a "make install", but due to
    # idiosyncrasies of NVDIMMSim integration, this is how it is
    # installed
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_NVDIMMSIM} ${SST_DEPS_INSTALL_DEPS}/packages/NVDIMMSim

    popd

}

# Installation location as used by SST's "./configure --with-nvdimmsim=..."
export SST_DEPS_INSTALL_NVDIMMSIM=${SST_DEPS_INSTALL_DEPS}/packages/NVDIMMSim/src
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_nvdimmsim
# Purpose:
#     Query SST NVDIMMSim dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported NVDIMMSim dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_nvdimmsim ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_NVDIMMSIM=\"master\""
    echo "export SST_DEPS_INSTALL_NVDIMMSIM=\"${SST_DEPS_INSTALL_NVDIMMSIM}\""
}
