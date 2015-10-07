# !/bin/bash
# sstDep_macsim.sh

# Description: 

# A bash script containing functions to process SST's Macsim external
# element.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Macsim
export SST_BUILD_MACSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_MACSIM_STATIC=1
#===============================================================================
# Macsim
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_macsim
# Purpose:
#     Prepare Macsim for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged Macsim code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_MACSIM=${SST_ROOT}/sst/elements/macsim
sstDepsStage_macsim ()
{

    tarFile="macsim.tar.gz"
    knownSha1=3c39c1c56c9a96c6b840dfb089d6c45e679d116c

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
#     sstDepsDeploy_macsim
# Purpose:
#     Build and install SST Macsim dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed Macsim dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_macsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Macsim will be built with SST"

#    pushd ${SST_DEPS_SRC_STAGED_MACSIM}
#
#    make
#    retval=$?
#    if [ $retval -ne 0 ]
#    then
#        # bail out on error
#        echo "ERROR: sstDep_macsim_static.sh: Macsim make failure"
#        return $retval
#    fi
#
#    # NOTE: There should be a "make install", but due to
#    # idiosyncrasies of DRAMSim integration, this is how it is
#    # installed
#    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
#    then
#        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
#    fi
#
#    ln -s ${SST_DEPS_SRC_STAGED_MACSIM} ${SST_DEPS_INSTALL_DEPS}/packages/Macsim
#    mkdir -p ${SST_DEPS_INSTALL_DEPS}/lib
#    ln -s ${SST_DEPS_SRC_STAGED_MACSIM}/*.so ${SST_DEPS_INSTALL_DEPS}/lib
#
#    popd

}

# Installation location as used by SST's "./configure --with-zoltan=..."
## export SST_DEPS_INSTALL_MACSIM=${SST_DEPS_INSTALL_DEPS}/packages/Macsim
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_macsim
# Purpose:
#     Query SST Macsim dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported Macsim dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_macsim ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_MACSIM=\"UNKNOWN STATIC VERSION\""
    echo "export SST_DEPS_INSTALL_MACSIM=\"${SST_DEPS_INSTALL_MACSIM}\""
}
