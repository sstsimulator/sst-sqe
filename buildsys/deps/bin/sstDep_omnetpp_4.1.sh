# !/bin/bash
# sstDep_omnetpp_4.1.sh

# Description: 

# A bash script containing functions to process SST's Qsim dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Qsim
export SST_BUILD_OMNET=1
# Environment variable uniquely identifying this script
export SST_BUILD_OMNET_4_1=1

#===============================================================================
# Omnet++
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_omnet
# Purpose:
#     Prepare Omnet++ code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged Omnet++ code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_OMNET=${SST_DEPS_SRC_STAGING}/omnetpp-4.1
sstDepsStage_omnet ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging Omnet++ 4.1"

    tar xfz ${SST_DEPS_SRC_PRISTINE}/omnetpp-4.1-src.tgz -C ${SST_DEPS_SRC_STAGING}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_omnetpp_4.1.sh: Omnet++ untar failure"
        return $retval
    fi

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_omnet
# Purpose:
#     Build and install SST Omnet++ dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed Omnet++ dependency
# Caveats:
#    Omnet++ needed for PhoenixSim component
#-------------------------------------------------------------------------------
sstDepsDeploy_omnet ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying Omnet++ 4.1"

    pushd ${SST_DEPS_SRC_STAGED_OMNET}
    # configure Omnet++
    export SST_DEPS_OMNET_ROOT_DIR=${SST_DEPS_SRC_STAGED_OMNET}/omnetpp-4.1
    export SST_DEPS_INSTALL_OMNET=${SST_DEPS_SRC_STAGING}/omnetpp-4.1
	##setenv##
if [ ! -f configure.user -o ! -f include/omnetpp.h ]; then
    echo "Error: current working directory does not look like an OMNeT++ root directory"
    # no exit -- it would close the shell
else
    omnetpp_root=`pwd`

    export PATH=$omnetpp_root/bin:$PATH
    export LD_LIBRARY_PATH=$omnetpp_root/lib:$LD_LIBRARY_PATH
echo "Setting LD path to ${LD_LIBRARY_PATH}"
fi


	##configure##
    NO_TCL=1 ./configure --prefix=${SST_DEPS_OMNET_ROOT_DIR}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_omnetpp_4.1.sh: Omnet++ configure failure"
        return $retval
    fi

    # !!!  NOTE: At this point, configure may report 'Please add
    # !!!  "<some path>" to your path'. 

	##make## 
    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_omnetpp_4.1.sh: make failure"
        return $retval
    fi
	#make directory if it does not exist
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/lib ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/lib
    fi  

    cp $omnetpp_root/lib/libopp*.so ${SST_INSTALL_DEPS}/lib

    popd

}

# Installation location of Omnet++ for PhoenixSim (installation root)
export SST_DEPS_INSTALL_OMNET=${SST_DEPS_SRC_STAGING}/omnetpp-4.1

#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_omnet
# Purpose:
#     Query SST PhoenixSim dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported PhoenixSim dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_omnet ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_OMNET=\"4.1\""
    echo "export SST_DEPS_INSTALL_OMNET=\"${SST_DEPS_INSTALL_OMNET}\""
}
