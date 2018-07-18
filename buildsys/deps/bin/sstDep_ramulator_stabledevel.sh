# !/bin/bash
# sstDep_ramulator_stabledevel.sh

# Description: 

# A bash script containing functions to process SST's Ramulator
# dependency.

echo "# Loading Deps File sstDep_ramulator_stabledevel.sh"

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Ramulator
export SST_BUILD_RAMULATOR=1
# Environment variable uniquely identifying this script
export SST_BUILD_RAMULATOR_STABLEDEVEL=1
#===============================================================================
# Ramulator
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_ramulator
# Purpose:
#     Prepare Ramulator code
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged Ramulator code 
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_RAMULATOR=${SST_DEPS_SRC_STAGING}/ramulator
sstDepsStage_ramulator ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging ramulator stabledevel"
    
    pushd ${SST_DEPS_SRC_STAGING}

   Num_Tries_remaing=3
   while [ $Num_Tries_remaing -gt 0 ]
   do
      echo " "
      echo "git clone https://github.com/CMU-SAFARI/ramulator.git ramulator"
      git clone https://github.com/CMU-SAFARI/ramulator.git ramulator

      retVal=$?
      if [ $retVal == 0 ] ; then
         Num_Tries_remaing=-1
      else
         echo "\"git clone of ramulato \" FAILED.  retVal = $retVal"
         Num_Tries_remaing=$(($Num_Tries_remaing - 1))
         if [ $Num_Tries_remaing -gt 0 ] ; then
             echo "    ------   RETRYING    $Num_Tries_remaing "
             rm -rf sst-core
             continue
         fi
         exit
      fi
   done
   echo " "
    
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_ramulator_stabledevel.sh: ramulator git fetch failure"
        sstDepsAnnounce -h $FUNCNAME -m \
          "Is http_proxy configured properly in $HOME/.wgetrc?"
        popd
        return $retval
    fi
    
    #  Move into the ramulator directory
    pushd ${SST_DEPS_SRC_STAGED_RAMULATOR}
    git checkout 7d2e72306c6079768e11a1867eb67b60cee34a1c
    echo "ramulator.git" `git log HEAD | sed 4q` >&2

    # NOTE: There are 2 patches to be applied to this sha = 7d2e72 to get 
    #       ramulator library to build properly on gcc
    #       ramulator_gcc48Patch.patch - Fixes compile for gcc 4.8
    #       ramulator_libPatch.patch   - Adds library build for gcc
    
    popd
    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_ramulator
# Purpose:
#     Build and install SST Ramulator dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed Ramulator dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_ramulator ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying Ramulator stabledevel"

    pushd ${SST_DEPS_SRC_STAGED_RAMULATOR}

    # Build and install RAMULATOR
    if [ $SST_DEPS_OS_NAME = "Darwin" ]
    then
        # MacOS is special
        make libramulator.a
    else
        # Linux
        make CXX=g++ libramulator.so
    fi
    
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_ramulator_stabledevel.sh: ramulator make failure"
        popd
        return $retval
    fi
    
    popd
    
    # NOTE: There is no "make install" for Ramulator.  Instead make a 
    #       link to the compilied directory
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_RAMULATOR} ${SST_DEPS_INSTALL_DEPS}/packages/Ramulator
    
}

# Installation location as used by SST's "./configure --with-ramulator=..."
export SST_DEPS_INSTALL_RAMULATOR=${SST_DEPS_INSTALL_DEPS}/packages/Ramulator
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_ramulator
# Purpose:
#     Query SST Ramulator dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported Ramulator dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_ramulator ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_RAMULATOR=\"REPOSITORY\""
    echo "export SST_DEPS_INSTALL_RAMULATOR=\"${SST_DEPS_INSTALL_RAMULATOR}\""
}
