# !/bin/bash
# sstDep_qsim_0.1.4.sh

# Description: 

# A bash script containing functions to process SST's Qsim dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Qsim
export SST_BUILD_QSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_QSIM_0_1_4=1
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
export SST_DEPS_SRC_STAGED_QSIM=${SST_DEPS_SRC_STAGING}/qsim-0.1.4
sstDepsStage_qsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging Qsim 0.1.4"

    # fetch 0.1.4 from Qsim web page
    #    http://www.cdkersey.com/qsim-web/releases
    pushd ${SST_DEPS_SRC_PRISTINE}
    if [ -f qsim-0.1.4.tar.bz2 ]  
    then
        # Use local copy
        sstDepsAnnounce -h $FUNCNAME -m "INFO: Using local copy of qsim-0.1.4.tar.bz2."
    else
        # fetch using wget
        wget http://www.cdkersey.com/qsim-web/releases/qsim-0.1.4.tar.bz2
        retval=$?
        if [ $retval -ne 0 ]
        then
        # bail out on error
            echo "ERROR: sstDep_qsim_0.1.4.sh: Qsim 0.1.4 wget fetch failure"
            sstDepsAnnounce -h $FUNCNAME -m "Is http_proxy configured properly in $HOME/.wgetrc?"
            popd
            return $retval
        fi
    fi


    tar xfj qsim-0.1.4.tar.bz2 -C ${SST_DEPS_SRC_STAGING}

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
    sstDepsAnnounce -h $FUNCNAME -m "Deploying Qsim 0.1.4"

    pushd ${SST_DEPS_SRC_STAGED_QSIM}

    # qsim requries QEMU. NOTE: getqemu.sh expects wget to be installed
    # and properly configured for any proxies
    
    # UPDATE (2012-08-09): getqemu script has bad URL
    #   OLD URL: http://download.savannah.gnu.org/releases/qemu/qemu-0.12.3.tar.gz
    #   NEW URL: http://savannah.spinellicreations.com/qemu/qemu-0.12.3.tar.gz
    # Fix getqemu.sh to use updated URL
    sed -i.bak 's/download.savannah.gnu.org\/releases/savannah.spinellicreations.com/' ./getqemu.sh

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
        echo "ERROR: sstDep_qsim_0.1.4.sh: Qsim make install failure"
        popd
        return $retval
    fi

    popd

}

# Installation location of Qsim (installation root)
export SST_DEPS_INSTALL_QSIM=${SST_DEPS_INSTALL_DEPS}
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
    echo "export SST_DEPS_VERSION_QSIM=\"0.1.4\""
    echo "export SST_DEPS_INSTALL_QSIM=\"${SST_DEPS_INSTALL_QSIM}\""
}
