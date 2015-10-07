# !/bin/bash
# sstDep_parmetis_3.1.1.sh

# Description: 

# A bash script containing functions to process SST's ParMetis
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to ParMETIS
export SST_BUILD_PARMETIS=1
# Environment variable uniquely identifying this script
export SST_BUILD_PARMETIS_3_1_1=1
#===============================================================================
# ParMetis
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_parmetis
# Purpose:
#     Prepare ParMetis for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged ParMetis code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_PARMETIS=${SST_DEPS_SRC_STAGING}/ParMetis-3.1.1
sstDepsStage_parmetis ()
{

    tarFile="ParMetis-3.1.1.tar.gz"
    knownSha1=e01fc35fb7f05ea1c265ac96fbc465d615385945

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
#     sstDepsDeploy_parmetis
# Purpose:
#     Build and install SST ParMetis dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed ParMetis dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_parmetis ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying ParMetis 3.1.1"

    pushd ${SST_DEPS_SRC_STAGED_PARMETIS}

    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_parmetis_3.1.1.sh: ParMetis make failure"
        return $retval
    fi

    # Install include file
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/include ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/include
    fi

    cp ${SST_DEPS_SRC_STAGED_PARMETIS}/parmetis.h ${SST_DEPS_INSTALL_DEPS}/include
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_parmetis_3.1.1.sh: ParMetis include file installation failure"
        return $retval
    fi

    # Instal libraries
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/lib ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/lib
    fi

    cp ${SST_DEPS_SRC_STAGED_PARMETIS}/*.a  ${SST_DEPS_INSTALL_DEPS}/lib
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_parmetis_3.1.1.sh: ParMetis library installation failure"
        return $retval
    fi

    popd

}

# Installation location as used by SST's "./configure --with-parmetis=..."
export SST_DEPS_INSTALL_PARMETIS=${SST_DEPS_INSTALL_DEPS}
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_parmetis
# Purpose:
#     Query SST ParMetis dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported ParMetis dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_parmetis ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_PARMETIS=\"3.1.1\""
    echo "export SST_DEPS_INSTALL_PARMETIS=\"${SST_DEPS_INSTALL_PARMETIS}\""
}
