# !/bin/bash
# sstDep_dramsim3_stabledevel.sh

# Description:

# A bash script containing functions to process SST's Dramsim3
# dependency.

echo "# Loading Deps File sstDep_dramsim3_stabledevel.sh"

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Dramsim3
export SST_BUILD_DRAMSIM3=1
# Environment variable uniquely identifying this script
export SST_BUILD_DRAMSIM3_STABLEDEVEL=1

#===============================================================================
# DRAMsim3
#===============================================================================

#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_dramsim3
# Purpose:
#     Prepare DRAMsim3 code
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged DRAMsim3 code
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_DRAMSIM3=${SST_DEPS_SRC_STAGING}/DRAMsim3

sstDepsStage_dramsim3 ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging dramsim3 stabledevel"

    pushd ${SST_DEPS_SRC_STAGING}

    # Attempt to clone the repo up to 3 times
    Num_Tries_remaing=3
    while [ $Num_Tries_remaing -gt 0 ]
    do
        echo ' '
        date
        echo ' '
        echo "git clone https://github.com/CMU-SAFARI/dramsim3.git dramsim3"
        git clone https://github.com/umd-memsys/DRAMsim3.git DRAMsim3
        retVal=$?
        echo ' '
        date
        echo ' '
        if [ $retVal == 0 ] ; then
            Num_Tries_remaing=-1
        else
            echo "\"git clone of dramsim3 \" FAILED.  retVal = $retVal"
            Num_Tries_remaing=$(($Num_Tries_remaing - 1))
            if [ $Num_Tries_remaing -gt 0 ] ; then
                echo "    ------   RETRYING    $Num_Tries_remaing "
                rm -rf DRAMsim3
                continue                        ## Try another
            fi
            return $retVal
        fi
    done
    echo " "

    # Now checking that we successfully cloneed
    if [ $retVal -ne 0 ]                     ## retVal from git clone
    then
        # bail out on error
        echo "ERROR: sstDep_dramsim3_stabledevel.sh: DRAMsim3 git fetch failure"
        sstDepsAnnounce -h $FUNCNAME -m \
            "Is http_proxy configured properly in $HOME/.wgetrc?"
        popd
        return $retVal
    fi

    #  Move into the DRAMsim3 directory and checkout a specific SHA or TAG
    pushd ${SST_DEPS_SRC_STAGED_DRAMSIM3}
#    git checkout 29817593b3389f1337235d63cac515024ab8fd6e
    git checkout 1.0.0
    echo "DRAMsim3.git" `git log HEAD | sed 4q` >&2

    popd
    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_dramsim3
# Purpose:
#     Build and install SST DRAMsim3 dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed DRAMsim3 dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_dramsim3 ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying DRAMsim3 stabledevel"

    pushd ${SST_DEPS_SRC_STAGED_DRAMSIM3}

    # Build and install DRAMsim3
    ls -lia
    mkdir build
    cd build
    pwd

    cmake ..   # NOTE: CMake version 3 or greater required
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        cmake --version
        echo "ERROR: sstDep_dramsim3_stabledevel.sh: cmake failure - is CMake Ver3 or greater???"
        popd
        return $retval
    fi

    make

    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_dramsim3_stabledevel.sh: dramsim3 make failure"
        popd
        return $retval
    fi

    popd

    # NOTE: There is no "make install" for DRAMsim3.  Instead make a
    #       link to the compilied directory
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_DRAMSIM3} ${SST_DEPS_INSTALL_DEPS}/packages/DRAMsim3
}

# Installation location as used by SST's "./configure --with-dramsim3=..."
export SST_DEPS_INSTALL_DRAMSIM3=${SST_DEPS_INSTALL_DEPS}/packages/DRAMsim3

#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_dramsim3
# Purpose:
#     Query SST DRAMsim3 dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported DRAMsim3 dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_dramsim3 ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_DRAMSIM3=\"REPOSITORY\""
    echo "export SST_DEPS_INSTALL_DRAMSIM3=\"${SST_DEPS_INSTALL_DRAMSIM3}\""
}
