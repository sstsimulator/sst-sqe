# !/bin/bash
# sstDep_hbm_dramsim2_stabledevel.sh

# Description:

# A bash script containing functions to process SST's HBM_DRAMSim2
# dependency.

echo "# Loading Deps File sstDep_hbm_dramsim2_stabledevel.sh"

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to HBM_DRAMSim2
export SST_BUILD_HBM_DRAMSIM2=1
# Environment variable uniquely identifying this script
export SST_BUILD_HBM_DRAMSIM2_STABLEDEVEL=1
#===============================================================================
# HBM_DRAMSim2
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_hbm_dramsim2
# Purpose:
#     Prepare HBM_DRAMSim2 code
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged HBM_DRAMSim2 code
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_HBM_DRAMSIM2=${SST_DEPS_SRC_STAGING}/hbm_dramsim2
sstDepsStage_hbm_dramsim2 ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging hbm_dramsim2 stabledevel"

    pushd ${SST_DEPS_SRC_STAGING}

   Num_Tries_remaing=3
   while [ $Num_Tries_remaing -gt 0 ]
   do
      echo " "
      echo "git clone https://github.com/tactcomplabs/HBM.git hbm_dramsim2"
      git clone https://github.com/tactcomplabs/HBM.git hbm_dramsim2

      retVal=$?
      if [ $retVal == 0 ] ; then
         Num_Tries_remaing=-1
      else
         echo "\"git clone of hbm_dramsim2 \" FAILED.  retVal = $retVal"
         Num_Tries_remaing=$(($Num_Tries_remaing - 1))
         if [ $Num_Tries_remaing -gt 0 ] ; then
             echo "    ------   RETRYING    $Num_Tries_remaing "
             rm -rf hbm_dramsim2
             continue
         fi
         return $retVal
      fi
   done
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_hbm_dramsim2_stabledevel.sh: hbm_dramsim2 git fetch failure"
        sstDepsAnnounce -h $FUNCNAME -m \
          "Is http_proxy configured properly in $HOME/.wgetrc?"
        popd
        return $retval
    fi

    #  Move into the hbm_dramsim2 directory
    pushd ${SST_DEPS_SRC_STAGED_HBM_DRAMSIM2}
    git checkout hbm-1.0.0-release


    echo "HBM.git" `git log HEAD | sed 4q` >&2

    popd
    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_hbm_dramsim2
# Purpose:
#     Build and install SST HBM_DRAMSim2 dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed HBM_DRAMSim2 dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_hbm_dramsim2 ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying HBM_DRAMSim2 stabledevel"

    pushd ${SST_DEPS_SRC_STAGED_HBM_DRAMSIM2}

    # Build and install HBM_DRAMSIM2
    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_hbm_dramsim2_stabledevel.sh: hbm_dramsim2 make failure"
        popd
        return $retval
    fi

    popd

    # NOTE: There is no "make install" for HBM_DRAMSim2.  Instead make a
    #       link to the compilied directory
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_HBM_DRAMSIM2} ${SST_DEPS_INSTALL_DEPS}/packages/HBM_DRAMSim2

}

# Installation location as used by SST's "./configure --with-hbmdramsim=..."
export SST_DEPS_INSTALL_HBM_DRAMSIM2=${SST_DEPS_INSTALL_DEPS}/packages/HBM_DRAMSim2
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_hbm_dramsim2
# Purpose:
#     Query SST HBM_DRAMSim2 dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported HBM_DRAMSim2 dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_hbm_dramsim2 ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_HBM_DRAMSIM2=\"REPOSITORY\""
    echo "export SST_DEPS_INSTALL_HBM_DRAMSIM2=\"${SST_DEPS_INSTALL_HBM_DRAMSIM2}\""
}
