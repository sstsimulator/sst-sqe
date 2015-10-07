# !/bin/bash
# sstDep_boost_1.50.sh

# Description: 

# A bash script containing functions to process SST's Boost
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Boost
export SST_BUILD_BOOST=1
# Environment variable uniquely identifying this script
export SST_BUILD_BOOST_1_50_0=1
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
export SST_DEPS_SRC_STAGED_BOOST=${SST_DEPS_SRC_STAGING}/boost_1_50_0
sstDepsStage_boost ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging Boost 1.50: using prebuilt static version, no action taken"
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

    if [ $SST_DEPS_OS_NAME = "Linux" ]
    then

        sstDepsAnnounce -h $FUNCNAME -m "Deploying Boost 1.50, selecting prebuilt static version"
        # See if Boost 1.50 isn't already loaded by default
        echo ${LOADEDMODULES} | egrep boost-1\.50\.0
        if [ $? -ne 0 ]
        then
            echo "Boost 1.50 is not currently loaded, attempting to load."
            # Boost 1.50 is not already loaded, so unload existing and load it.
            module unload boost # make sure any default Boost has been unloaded
            module add boost/boost-1.50.0
        else
            echo "Boost 1.50 is already loaded."
        fi

    elif [ $SST_DEPS_OS_NAME = "Darwin" ]
    then
        sstDepsAnnounce -h $FUNCNAME -m "Selection of Boost 1.50 on MacOS handled in bamboo.sh. Doing nothing."
    fi

}


# Installation location as used by SST's "./configure --with-boost=..."
export SST_DEPS_INSTALL_BOOST=${BOOST_HOME}
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
    echo "export SST_DEPS_VERSION_BOOST=\"1.50.0\""
    # BOOST_HOME gets set by module manager
    echo "export SST_DEPS_INSTALL_BOOST=\"${SST_DEPS_INSTALL_BOOST}\""
}
