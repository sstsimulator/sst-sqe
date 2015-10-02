# !/bin/bash
# sstDep_qsim_SST-3.0.sh

# Description: 

# A bash script containing functions to process SST's Qsim dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Qsim
export SST_BUILD_QSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_QSIM_SST_3_0=1
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
export SST_DEPS_SRC_STAGED_QSIM=${SST_DEPS_SRC_STAGING}/Qsim_SST-3.0
sstDepsStage_qsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging Qsim SST-3.0"

    # fetch latest from Qsim repository
    pushd ${SST_DEPS_SRC_STAGING}
    svn co svn://s917191.sandia.gov/qsim/tags/SST-3.0 Qsim_SST-3.0

    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_qsim_SST-3.0.sh: Qsim repository fetch failure"
        sstDepsAnnounce -h $FUNCNAME -m "Is the SVN http proxy configured properly?"
        popd
        return $retval
    fi

    cp ${SST_DEPS_SRC_PRISTINE}/qemu-0.12.3.tar.gz  Qsim_SST-3.0
    cp Qsim_SST-3.0/remote/client/qsim-client.h     Qsim_SST-3.0
    cp Qsim_SST-3.0/remote/qsim-net.h               Qsim_SST-3.0

    popd
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
    sstDepsAnnounce -h $FUNCNAME -m "Deploying Qsim SST-3.0"

    pushd ${SST_DEPS_SRC_STAGED_QSIM}

    # Configure qsim client installation root
    export QSIM_PREFIX=${SST_DEPS_INSTALL_DEPS}

    # qsim requries QEMU. NOTE: getqemu.sh expects wget to be installed
    # and properly configured for any proxies.

    ./getqemu.sh
    pushd qemu-0.12.3
    make
    popd

    # Configure qsim client installation root
    export QSIM_PREFIX=${SST_DEPS_INSTALL_DEPS}

    # Build and install qsim client
    make install
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_qsim_SST-3.0.sh: qsim make install failure"
        popd
        return $retval
    fi

    sstDepsAnnounce -h $FUNCNAME -m "Installing qsim SST-3.0"
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_QSIM} ${SST_DEPS_INSTALL_DEPS}/packages/Qsim

    # Building QSim Server       (Not clear to me we need the server)
    # --------------------

    # This makefile also uses the QSIM_PREFIX variable, if it is set, otherwise QSIM
    # is assumed to reside in /usr/local. Remember to set LD_LIBRARY_PATH before
    # running the server, if the installation libary path is not in the library
    # search path.

    cd remote/server
    make
    cd ../..

    # There is currently no "install" target for the QSim server, so it must be run
    # in place or manually copied as desired.

    # Building/Installing QSim Client Library
    #---------------------------------------

    # This also respects QSIM_PREFIX, and will install libqsim-client.so and
    # qsim-client.h in $QSIM_PREFIX/lib and $QSIM_PREFIX/include respectively.

    cd remote/client
    make install
    cd ../..

    # Put the client library where zesto looks.
    ln -s remote/client/libqsim-client.so .

    popd

}

# Installation location of Qsim (installation root)
export SST_DEPS_INSTALL_QSIM=${SST_DEPS_SRC_STAGING}/Qsim_SST-3.0
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
    echo "export SST_DEPS_VERSION_QSIM=\"SST-3.0\""
    echo "export SST_DEPS_INSTALL_QSIM=\"${SST_DEPS_INSTALL_QSIM}\""
}
