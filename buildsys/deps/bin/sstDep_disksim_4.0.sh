# !/bin/bash
# sstDep_disksim_4.0.sh

# Description: 

# A bash script containing functions to process SST's DiskSim
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to DiskSim
export SST_BUILD_DISKSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_DISKSIM_4_0=1
#===============================================================================
# DiskSim dependencies
#    DiskSim
#      |
#      +--TAU
#           |
#           +--PDT
#           |
#           +--OTF
#===============================================================================


#===============================================================================
# PDT
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_pdt
# Purpose:
#     Prepare PDT (Program Database Toolkit) code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged PDT code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_PDT=${SST_DEPS_SRC_STAGING}/pdtoolkit-3.16
sstDepsStage_pdt ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging PDT 3.16"
    # Extract tarfile. Once unpacked, files should be available in
    # $SST_DEPS_SRC_STAGED_PDT
    tar xfz ${SST_DEPS_SRC_PRISTINE}/pdt-3.16.tar.gz -C ${SST_DEPS_SRC_STAGING}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: PDT untar failure"
        return $retval
    fi

}

#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_pdt
# Purpose:
#     Build and install SST DiskSim PDT dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed DiskSim PDT dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_pdt ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying PDT 3.16"
    pushd ${SST_DEPS_SRC_STAGED_PDT}
    # configure PDT
    export SST_DEPS_PDT_ROOT_DIR=${SST_DEPS_INSTALL_DEPS}/packages/pdt
    ./configure -prefix=${SST_DEPS_PDT_ROOT_DIR}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: PDT configure failure"
        return $retval
    fi

    # !!!  NOTE: At this point, configure will report 'Please add
    # !!!  "<some path>" to your path'. This has been optional so far.

    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: PDT make failure"
        return $retval
    fi

    make install
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: PDT make install failure"
        return $retval
    fi

    popd

}

#===============================================================================
# OTF
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_otf
# Purpose:
#     Prepare OTF (Open Trace Format) code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged OTF code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_OTF=${SST_DEPS_SRC_STAGING}/OTF-1.2.18
sstDepsStage_otf ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging OTF 1.2.18"
    # Extract tarfile. Once unpacked, files should be available in
    # $SST_DEPS_SRC_STAGED_OTF
    tar xfz ${SST_DEPS_SRC_PRISTINE}/OTF-SRC-1.2.18.tar.gz -C ${SST_DEPS_SRC_STAGING}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: OTF untar failure"
        return $retval
    fi
}

#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_otf
# Purpose:
#     Build and install SST DiskSim OTF dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed DiskSim OTF dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_otf ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying OTF 1.2.18"
    pushd ${SST_DEPS_SRC_STAGED_OTF}
    # configure OTF
    export SST_DEPS_OTF_ROOT_DIR=${SST_DEPS_INSTALL_DEPS}
    ./configure --prefix=${SST_DEPS_OTF_ROOT_DIR}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: OTF configure failure"
        return $retval
    fi

    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: OTF make failure"
        return $retval
    fi

    make install
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: OTF make install failure"
        return $retval
    fi

    popd
}

#===============================================================================
# TAU
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_tau
# Purpose:
#     Prepare TAU code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged TAU code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_TAU=${SST_DEPS_SRC_STAGING}/tau-2.20.1
sstDepsStage_tau ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging TAU 2.20.1"
    # Extract tarfile. Once unpacked, files should be available in
    # $SST_DEPS_SRC_STAGED_TAU
    tar xfz ${SST_DEPS_SRC_PRISTINE}/tau-2.20.1.tar.gz -C ${SST_DEPS_SRC_STAGING}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: PDT untar failure"
        return $retval
    fi

}

#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_tau
# Purpose:
#     Build and install SST DiskSim TAU dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed DiskSim TAU dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_tau ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying TAU 2.20.1"
    pushd ${SST_DEPS_SRC_STAGED_TAU}

    # Try to find libbfd... just use the first one found.
    SST_DEPS_LIBS_LIBBFD=`locate libbfd.a | head -1`
    if [ ! ${SST_DEPS_LIBS_LIBBFD} == "" ]
    then
        # $SST_DEPS_LIBS_LIBBFD is not null, so a libbfd.a has been found.
        SST_DEPS_LIBS_LIBBFD_DIR=`dirname ${SST_DEPS_LIBS_LIBBFD}`
    else
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: libbfd not found"
        return $retval
    fi

    # !!!  Notes on this configure operation indicate that this
    # !!!  requires root privileges to complete successfully for some
    # !!!  reason.

    ./configure -prefix=${SST_DEPS_INSTALL_DEPS} -useropt=-g \
       -otfinc=${SST_DEPS_OTF_ROOT_DIR}/include -otflib=${SST_DEPS_OTF_ROOT_DIR}/lib \
       -iowrapper -TRACE -PROFILE \
       -bfd=${SST_DEPS_LIBS_LIBBFD_DIR} -pdt=${SST_DEPS_PDT_ROOT_DIR}

    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: TAU configure failure"
        return $retval
    fi

    make install
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: TAU make install failure"
        return $retval
    fi

    popd
}

# Installation location as used by SST's "./configure --with-tau=..."
export SST_DEPS_INSTALL_TAU=${SST_DEPS_INSTALL_DEPS}
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_tau
# Purpose:
#     Query SST TAU dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported TAU dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_tau ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_TAU=\"2.20.1\""
    echo "export SST_DEPS_INSTALL_TAU=\"${SST_DEPS_INSTALL_TAU}\""
}

#===============================================================================
# DiskSim
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_disksim
# Purpose:
#     Prepare DiskSim code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged DiskSim code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
# Define location for staged DiskSim code
export SST_DEPS_SRC_STAGED_DISKSIM=${SST_DEPS_SRC_STAGING}/disksim-4.0
sstDepsStage_disksim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging DiskSim 4.0"
    # Extract tarfile. Once unpacked, files should be available in
    # $SST_DEPS_SRC_STAGED_DISKSIM
    tar xfz ${SST_DEPS_SRC_PRISTINE}/disksim-4.0.tar.gz -C ${SST_DEPS_SRC_STAGING}
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: DiskSim staging failure"
        return $retval
    fi

    #---------------------------------------------------------------------------
    # Stage the remainder of the DiskSim dependencies
    #---------------------------------------------------------------------------

    # Stage PDT
    sstDepsStage_pdt
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: PDT staging failure"
        return $retval
    fi

    # Stage OTF
    sstDepsStage_otf
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: OTF staging failure"
        return $retval
    fi

    # Stage TAU
    sstDepsStage_tau
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: TAU staging failure"
        return $retval
    fi

}

#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_disksim
# Purpose:
#     Build and install SST DiskSim dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed DiskSim dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_disksim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying DiskSim 4.0"
    #---------------------------------------------------------------------------
    # PDT
    #---------------------------------------------------------------------------
    # Deploy PDT
    sstDepsDeploy_pdt
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: PDT deployment failure"
        return $retval
    fi

    #---------------------------------------------------------------------------
    # OTF
    #---------------------------------------------------------------------------
    # Deploy OTF
    sstDepsDeploy_otf
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: OTF deployment failure"
        return $retval
    fi

    #---------------------------------------------------------------------------
    # TAU
    #---------------------------------------------------------------------------
    # Deploy TAU
    sstDepsDeploy_tau
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: TAU deployment failure"
        return $retval
    fi

    #---------------------------------------------------------------------------
    # DiskSim
    #---------------------------------------------------------------------------
    # Make DiskSim
    pushd ${SST_DEPS_SRC_STAGED_DISKSIM}
    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_disksim_4.0.sh: make failure"
        return $retval
    fi


    # NOTE: There should be a "make install", but due to
    # idiosyncrasies of DiskSim integration, this is how it is
    # installed
    if [ ! -d ${SST_DEPS_INSTALL_DEPS}/packages ]
    then
        mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages
    fi

    ln -s ${SST_DEPS_SRC_STAGED_DISKSIM} ${SST_DEPS_INSTALL_DEPS}/packages/DiskSim


    popd

   
}


# Installation location as used by SST's "./configure --with-disksim=..."
export SST_DEPS_INSTALL_DISKSIM=${SST_DEPS_INSTALL_DEPS}/packages/DiskSim
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_disksim
# Purpose:
#     Query SST DiskSim dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported DiskSim dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_disksim ()
{
    # since TAU is a dependency of DiskSim, query it here
    sstDepsQuery_tau
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_DISKSIM=\"4.0\""
    echo "export SST_DEPS_INSTALL_DISKSIM=\"${SST_DEPS_INSTALL_DISKSIM}\""
}


