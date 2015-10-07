# !/bin/bash
# sstDep_chdl-stl_dev.sh

# Description: 

# A bash script containing functions to process SST's CHDL-STL dependency.

#    Warning:   Progress echos are not permited in sstDep_ routine!

cat > __dd.cc << EOF
void dummy_test() {
}
EOF

if [[ ${CXX:+isSet} != isSet ]] ; then
   CXX=g++
fi
$CXX -std=c++11 -c __dd.cc 
if [ $? == 1 ] ; then
   echo "# chdl-stl requires C++11.  NOTE:  c++0x will NOT suffice."
   echo '# ' ; echo "# Will not build CHDL-STL"; echo '# '
   return
fi


PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to CHDL-STL
export SST_BUILD_CHDL_STL=1
# Environment variable uniquely identifying this script
export SST_BUILD_CHDL_STL_DEV=1
#===============================================================================
# CHDL-STL
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_chdl_stl
# Purpose:
#     Prepare CHDL-STL code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged CHDL-STL code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_CHDL_STL=${SST_DEPS_SRC_STAGING}/chdl-stl_dev
sstDepsStage_chdl_stl ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging CHDL-STL dev"

    pushd ${SST_DEPS_SRC_STAGING}

    git clone https://github.com/cdkersey/chdl-stl.git chdl-stl_dev

    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_chdl-stl_dev.sh: CHDL-STL dev git fetch failure"
        sstDepsAnnounce -h $FUNCNAME -m \
          "Is http_proxy configured properly in $HOME/.wgetrc?"
        popd
        return $retval
    fi

    sstDepsAnnounce -h $FUNCNAME -m "Fetched CHDL-STL from github"

    pushd $SST_DEPS_SRC_STAGED_CHDL_STL
    echo "chdl-stl:git" `git log HEAD | sed 4q` >&2
    popd
    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_chdl_stl
# Purpose:
#     Build and install SST CHDL-STL dependency.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed CHDL-STL dependency
# Caveats:
#     Depends on G++ >= 4.7
#-------------------------------------------------------------------------------
sstDepsDeploy_chdl_stl ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying CHDL-STL dev"

    pushd ${SST_DEPS_SRC_STAGED_CHDL_STL}

    # Build and install chdl-stl
    make install PREFIX=${SST_DEPS_INSTALL_DEPS}/packages/chdl
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_chdl-stl_dev.sh: CHDL-STL make install failure"
        popd
        return $retval
    fi

    popd
}

# Installation location of CHDL-STL (installation root)
export SST_DEPS_INSTALL_CHDL_STL=${SST_DEPS_INSTALL_DEPS}/packages/chdl-stl
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_chdl_stl
# Purpose:
#     Query SST CHDL-STL dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported CHDL-STL dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_chdl_stl ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_CHDL_STL=\"dev\""
    echo "export SST_DEPS_INSTALL_CHDL_STL=\"${SST_DEPS_INSTALL_CHDL_STL}\""
}
