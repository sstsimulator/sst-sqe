# !/bin/bash
# sstDep_zoltan_3.83.sh

# Description: 

# A bash script containing functions to process SST's Zoltan
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Zoltan
export SST_BUILD_ZOLTAN=1
# Environment variable uniquely identifying this script
export SST_BUILD_ZOLTAN_3.83=1
#===============================================================================
# Zoltan
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_zoltan
# Purpose:
#     Prepare Zoltan for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged Zoltan code that is ready for patching
# Caveats:
#     Zoltan requires ParMetis to be built and installed first
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_ZOLTAN=${SST_DEPS_SRC_STAGING}/Zoltan_v3.83
sstDepsStage_zoltan ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging Zoltan 3.83"

    # Extract tarfile. Once unpacked, files should be available in
    # $SST_DEPS_SRC_STAGED_ZOLTAN
    tar xfz ${SST_DEPS_SRC_PRISTINE}/zoltan_distrib_v3.83.tar.gz -C ${SST_DEPS_SRC_STAGING} 2> errFile
    retval=$?
    touch errFile
    if [ -s errFile ] ; then
        grep -v 'Ignoring unknown extended header keyword' errFile
        IgnoreCT=`grep -c 'Ignoring unknown extended header keyword' errFile`
        if [ 0 != IgnoreCT ] ; then
             echo " Suppressing $IgnoreCT \"Ignoring\" messages from Zoltan tar"
        fi
    fi
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_zoltan_3.83.sh: Zoltan untar failure"
        return $retval
    fi

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_zoltan
# Purpose:
#     Build and install SST Zoltan dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed Zoltan dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
# Installation location as used by SST's "./configure --with-zoltan=..."
export SST_DEPS_INSTALL_ZOLTAN=${SST_DEPS_INSTALL_DEPS}/packages/Zoltan
sstDepsDeploy_zoltan ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying Zoltan 3.83"

    mkdir ${SST_DEPS_SRC_STAGED_ZOLTAN}/build
    pushd ${SST_DEPS_SRC_STAGED_ZOLTAN}/build

    # For now, just assume a typical MPI installation in
    # /usr/local. This could later become a user-overrideable
    # variable.

    CC=`which mpicc` CXX=`which mpicxx` ../configure --with-cflags="-fPIC" --with-cxxflags="-fPIC" \
       --prefix=${SST_DEPS_INSTALL_ZOLTAN}


    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_zoltan_3.83.sh: zoltan configure failure"
        return $retval
    fi

    make everything > Zoltan-make-everything-stdout
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_zoltan_3.83.sh: Zoltan make everything failure"
        cat Zoltan-make-everything-stdout
        return $retval
    fi

    make install
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_zoltan_3.83.sh: Zoltan make install failure"
        return $retval
    fi


    popd

}

#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_zoltan
# Purpose:
#     Query SST Zoltan dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported Zoltan dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_zoltan ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_ZOLTAN=\"3.83\""
    echo "export SST_DEPS_INSTALL_ZOLTAN=\"${SST_DEPS_INSTALL_ZOLTAN}\""
}
