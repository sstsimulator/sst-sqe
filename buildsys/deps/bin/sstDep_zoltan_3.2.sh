# !/bin/bash
# sstDep_zoltan_3.2.sh

# Description: 

# A bash script containing functions to process SST's Zoltan
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Zoltan
export SST_BUILD_ZOLTAN=1
# Environment variable uniquely identifying this script
export SST_BUILD_ZOLTAN_3_2=1
#===============================================================================
# Zoltan
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_zoltan
# Purpose:
#     Prepare Zoltan for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged Zoltan code that is ready for patching
# Caveats:
#     Zoltan requires ParMetis to be built and installed first
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_ZOLTAN=${SST_DEPS_SRC_STAGING}/Zoltan_v3.2
sstDepsStage_zoltan ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging Zoltan 3.2"

    # Extract tarfile. Once unpacked, files should be available in
    # $SST_DEPS_SRC_STAGED_ZOLTAN
    tar xfz ${SST_DEPS_SRC_PRISTINE}/zoltan_distrib_v3.2.tar.gz -C ${SST_DEPS_SRC_STAGING}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_zoltan_3.2.sh: Zoltan untar failure"
        return $retval
    fi

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_zoltan
# Purpose:
#     Build and install SST Zoltan dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed Zoltan dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_zoltan ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying Zoltan 3.2"

    mkdir ${SST_DEPS_SRC_STAGED_ZOLTAN}/build
    pushd ${SST_DEPS_SRC_STAGED_ZOLTAN}/build

    # For now, just assume a typical MPI installation in
    # /usr/local. This could later become a user-overrideable
    # variable.

    ../configure --with-cflags="-fPIC" --with-cxxflags="-fPIC" --with-parmetis \
       --with-parmetis-incdir=${SST_DEPS_INSTALL_DEPS}/include \
       --with-parmetis-libdir=${SST_DEPS_INSTALL_DEPS}/lib \
       --prefix=${SST_DEPS_INSTALL_DEPS}

    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_zoltan_3.2.sh: zoltan configure failure"
        echo "       Zoltan requires ParMetis. Is ParMetis installed?"
        return $retval
    fi

    make everything
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_zoltan_3.2.sh: Zoltan make everything failure"
        echo "       Zoltan requires ParMetis. Is ParMetis installed?"
        return $retval
    fi

    make install
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_zoltan_3.2.sh: Zoltan make install failure"
        echo "       Zoltan requires ParMetis. Is ParMetis installed?"
        return $retval
    fi


    popd

}

# Installation location as used by SST's "./configure --with-zoltan=..."
export SST_DEPS_INSTALL_ZOLTAN=${SST_DEPS_INSTALL_DEPS}
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_zoltan
# Purpose:
#     Query SST Zoltan dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported Zoltan dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_zoltan ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_ZOLTAN=\"3.2\""
    echo "export SST_DEPS_INSTALL_ZOLTAN=\"${SST_DEPS_INSTALL_ZOLTAN}\""
}
