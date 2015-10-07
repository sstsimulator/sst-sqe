# !/bin/bash
# sstDep_boost_1.43.sh

# Description: 

# A bash script containing functions to process SST's Boost
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Boost
export SST_BUILD_BOOST=1
# Environment variable uniquely identifying this script
export SST_BUILD_BOOST_1_43=1
#===============================================================================
# Boost
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_boost
# Purpose:
#     Prepare Boost for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged Boost code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_BOOST=${SST_DEPS_SRC_STAGING}/boost_1_43_0
sstDepsStage_boost ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging Boost 1.43"

    # Extract tarfile. Once unpacked, files should be available in
    # $SST_DEPS_SRC_STAGED_BOOST
    tar xfz ${SST_DEPS_SRC_PRISTINE}/boost_1_43_0.tar.gz -C ${SST_DEPS_SRC_STAGING}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_boost_1.43.sh: Boost untar failure"
        return $retval
    fi

    # !!! NOTE: There is an intermediate step (bootstrap.sh) to
    # !!! generate additional files needed for compilation. This will
    # !!! be done in the sstDepsDeploy_boost function for now.
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_boost
# Purpose:
#     Build and install SST Boost dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed Boost dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_boost ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying Boost 1.43"

    pushd ${SST_DEPS_SRC_STAGED_BOOST}
    # !!! The intermediate boostrap step creates files used in the
    # !!! Boost build system (some of which require modfication), so it
    # !!! is done here. Setup Boost build to install in
    # !!! ${SST_DEPS_INSTALL_DEPS}
    ./bootstrap.sh --prefix=${SST_DEPS_INSTALL_DEPS}

    # Modify the project-cofig.jam file so that Boost.MPI gets built

    # !!! NOTE: This could be done via a patch if the ./bootstrap.sh
    # !!! step was moved to the sstDepsStage_boost function. However,
    # !!! it is done here to keep the staging behavior consistent

    sed -i.bak -e '16 a\
# Add MPI so that Boost.MPI gets built.\
using mpi ;\
' project-config.jam

    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_boost_1.43.sh: Boost project-config.jam modification failure"
        return $retval
    fi

    ./bjam install
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_boost_1.43.sh: Boost deployment failure (bjam)"
        return $retval
    fi

    popd

}


# Installation location as used by SST's "./configure --with-boost=..."
export SST_DEPS_INSTALL_BOOST=${SST_DEPS_INSTALL_DEPS}
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_boost
# Purpose:
#     Query SST Boost dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported Boost dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_boost ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_BOOST=\"1.43\""
    echo "export SST_DEPS_INSTALL_BOOST=\"${SST_DEPS_INSTALL_BOOST}\""
}
