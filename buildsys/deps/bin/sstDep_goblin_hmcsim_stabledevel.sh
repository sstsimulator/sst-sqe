# !/bin/bash
# sstDep_goblin_hmcsim_stabledevel.sh

# Description: 

# A bash script containing functions to process SST's Goblin_HMCSIM
# dependency.

echo "# Loading Deps File sstDep_goblin_hmcsim_stabledevel.sh"

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Goblin_HMCSIM
export SST_BUILD_GOBLIN_HMCSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_GOBLIN_HMCSIM_STABLEDEVEL=1
#===============================================================================
# Goblin_HMCSIM
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_goblin_hmcsim
# Purpose:
#     Prepare Goblin_HMCSIM code
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged Goblin_HMCSIM code 
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_GOBLIN_HMCSIM=${SST_DEPS_SRC_STAGING}/goblin_hmcsim
sstDepsStage_goblin_hmcsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging goblin_hmcsim stabledevel"
    
    pushd ${SST_DEPS_SRC_STAGING}

#    git clone -b sst-8.0.0-release https://github.com/tactcomplabs/gc64-hmcsim.git goblin_hmcsim
    git clone -b sst-7.2.0-release https://github.com/tactcomplabs/gc64-hmcsim.git goblin_hmcsim
    
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_goblin_hmcsim_stabledevel.sh: goblin_hmcsim git fetch failure"
        sstDepsAnnounce -h $FUNCNAME -m \
          "Is http_proxy configured properly in $HOME/.wgetrc?"
        popd
        return $retval
    fi
    
    #  Move into the goblin_hmcsim directory
    pushd ${SST_DEPS_SRC_STAGED_GOBLIN_HMCSIM}
    echo "gc64-hmcsim.git" `git log HEAD | sed 4q` >&2

    popd
    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_goblin_hmcsim
# Purpose:
#     Build and install SST Goblin_HMCSIM dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed Goblin_HMCSIM dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_goblin_hmcsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying Goblin_HMCSIM stabledevel"

    pushd ${SST_DEPS_SRC_STAGED_GOBLIN_HMCSIM}

    # Build and install GOBLIN_HMCSIM
    make 
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_goblin_hmcsim_stabledevel.sh: goblin_hmcsim make failure"
        popd
        return $retval
    fi
    
    popd
    
    # NOTE: There is no "make install" for Goblin_HMCSIM.  Instead make a 
    #       link to the compilied directory
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_GOBLIN_HMCSIM} ${SST_DEPS_INSTALL_DEPS}/packages/Goblin_HMCSIM
    
}

# Installation location as used by SST's "./configure --with-goblin_hmcsim=..."
export SST_DEPS_INSTALL_GOBLIN_HMCSIM=${SST_DEPS_INSTALL_DEPS}/packages/Goblin_HMCSIM
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_goblin_hmcsim
# Purpose:
#     Query SST Goblin_HMCSIM dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported Goblin_HMCSIM dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_goblin_hmcsim ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_GOBLIN_HMCSIM=\"REPOSITORY\""
    echo "export SST_DEPS_INSTALL_GOBLIN_HMCSIM=\"${SST_DEPS_INSTALL_GOBLIN_HMCSIM}\""
}
