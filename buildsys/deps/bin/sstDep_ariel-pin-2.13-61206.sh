# !/bin/bashsstDep_ariel-pin-2.13-61206.sh
# sstDep_ariel-pin-2.13-61206.sh

# Description: 

# A bash script containing functions to process SST's Ariel dependence
# on the Intel PIN library.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Ariel-pin
export SST_BUILD_ARIEL_PIN=1
# Environment variable uniquely identifying this script
export SST_BUILD_ARIEL_PIN_2_13_61206=1
#===============================================================================
# Ariel Pin
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_ariel-pin
# Purpose:
#     Prepare patching.
# Inputs:
#     None
# Outputs:
#    
# Expected Results
#     
# Caveats:
#     No patching is anticipated!  Pin library is from module. 
#     Ariel is SST SVN Repository. 
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_DRAMSIM=${SST_DEPS_SRC_STAGING}/DRAMSim2-2.2.2
sstDepsStage_ariel-pin ()
{

#     May insert the PIN module load here. 
 
echo "##################################################"
echo "#"
echo "#            NOT LOADING MODULE"
echo "#"
echo "##################################################"
      module list

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_ariel-pin
# Purpose:
#     Build and install SST  the Ariel PIN TOOL library
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed DRAMSim dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_ariel-pin ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying PINTOOL 2.13-61206 for Ariel"

    pushd ${SST_ROOT}/tools/ariel/fesimple

    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        pwd
        echo "ERROR: sstDep_ariel-pin-2.13-61206.sh: make failure"
        return $retval
    fi

    ls -l
 
    popd

}

# Installation location as used by SST's "./configure --with-ariel-pin=..."
#     What is needed already installed by module
#  export SST_DEPS_INSTALL_DRAMSIM=${SST_DEPS_INSTALL_DEPS}/packages/DRAMSim
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_ariel-pin
# Purpose:
#     Query SST Arial Pin dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Ariel Pin dependency information for exporting
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_ariel-pin ()
{
    # provide version and installation location info
#    echo "export SST_DEPS_VERSION_DRAMSIM=\"2.2.2\""
#    echo "export SST_DEPS_INSTALL_DRAMSIM=\"${SST_DEPS_INSTALL_DRAMSIM}\""
    echo " Ariel Pin:   No version or installation location exported" >&2
}
