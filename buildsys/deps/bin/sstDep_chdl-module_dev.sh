# !/bin/bash
# sstDep_chdl-module_dev.sh

# Description: 

# A bash script containing functions to process SST's CHDL-module dependency.

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
   echo "# chdl-module requires C++11.  NOTE:  c++0x will NOT suffice."
   echo '# ' ; echo "# Will not build CHDL-module"; echo '# '
   return
fi


PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to CHDL-module
export SST_BUILD_CHDL_MODULE=1
# Environment variable uniquely identifying this script
export SST_BUILD_CHDL_MODULE_DEV=1
#===============================================================================
# CHDL-module
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_chdl_module
# Purpose:
#     Prepare CHDL-module code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged CHDL-module code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_CHDL_MODULE=${SST_DEPS_SRC_STAGING}/chdl-module_dev
sstDepsStage_chdl_module ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging CHDL-module dev"

    pushd ${SST_DEPS_SRC_STAGING}

    git clone https://github.com/cdkersey/chdl-module.git chdl-module_dev

    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_chdl-module_dev.sh:" \
	     "CHDL-module dev git fetch failure"
        sstDepsAnnounce -h $FUNCNAME -m \
          "Is http_proxy configured properly in $HOME/.wgetrc?"
        popd
        return $retval
    fi

    sstDepsAnnounce -h $FUNCNAME -m "Fetched CHDL-module from github"
    pushd $SST_DEPS_SRC_STAGED_CHDL_MODULE
    echo "chdl-module.git" `git log HEAD | sed 4q` >&2
    popd

    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_chdl_module
# Purpose:
#     Build and install SST CHDL-module dependency.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed CHDL-module dependency
# Caveats:
#     Depends on G++ >= 4.7
#-------------------------------------------------------------------------------
sstDepsDeploy_chdl_module ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying CHDL-module dev"

    pushd ${SST_DEPS_SRC_STAGED_CHDL_MODULE}

#    sstDepsAnnounce -h $FUNCNAME -m "Patching CHDL-module dev Makefile"
#######  Patch the Make file

#    patch -p1 -i ${SST_DEPS_PATCHFILES}/chdl-module-Makefile.patch

#      Remove the ldconfig
#    sed -i'.0sed' -e'/ldconfig/d' Makefile
    ls -la

    # Build and install chdl-module
    mkdir -p ${SST_DEPS_INSTALL_DEPS}/packages/chdl-module/include/chdl

    make install PREFIX=${SST_DEPS_INSTALL_DEPS}/packages/chdl PACKAGES=${SST_DEPS_INSTALL_DEPS}/packages
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_chdl-module_dev.sh:" \
	     "CHDL-module make install failure"
        popd
        return $retval
    fi

    popd
}

# Installation location of CHDL-module (installation root)
export SST_DEPS_INSTALL_CHDL_MODULE=${SST_DEPS_INSTALL_DEPS}/packages/chdl-module
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_chdl_module
# Purpose:
#     Query SST CHDL-module dependency. Export information about this
#     installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported CHDL-module dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_chdl_module ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_CHDL_MODULE=\"dev\""
    echo "export SST_DEPS_INSTALL_CHDL_MODULE=\"${SST_DEPS_INSTALL_CHDL}\""
}
