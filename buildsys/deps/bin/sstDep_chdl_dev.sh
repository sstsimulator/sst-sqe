# !/bin/bash
# sstDep_chdl_dev.sh

# Description: 

# A bash script containing functions to process SST's CHDL dependency.

#    Warning:   Progress echos are not permited in sstDep_ routine!

cat > __dd.cc << EOF
void dummy_test() {
}
EOF

if [[ ${CXX:+isSet} != isSet ]] ; then
   CXX=g++
fi

echo "#   TEMP"
##echo "#    `$CXX --version | grep -i clang`"
linexx=`$CXX --version | sed 1q`
echo "# $linexx"
if [[ ${RUN_CHDL_ON_CLANG:+isSet} != isSet ]] ; then
echo $linexx | grep -i clang > /dev/null

     if [ $? == 0 ] ; then
          echo "# chdl will not build with Clang  June 25, 2015"
          echo '# ' ; echo "# Will not build CHDL"; echo '# '
          return
     fi
echo "#   TEMP"
fi
$CXX -std=c++11 -c __dd.cc 
retval=$?
rm -f __dd.cc dd.o
if [ $retval == 1 ] ; then
   echo "# chdl requires C++11.  NOTE:  c++0x will NOT suffice."
   echo '# ' ; echo "# Will not build CHDL"; echo '# '
   return
fi


PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to CHDL
export SST_BUILD_CHDL=1
# Environment variable uniquely identifying this script
export SST_BUILD_CHDL_DEV=1
#===============================================================================
# CHDL
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_chdl
# Purpose:
#     Prepare CHDL code for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged CHDL code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_CHDL=${SST_DEPS_SRC_STAGING}/chdl_dev
sstDepsStage_chdl ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Staging CHDL dev"

    pushd ${SST_DEPS_SRC_STAGING}

    git clone https://github.com/cdkersey/chdl.git chdl_dev

    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_chdl_dev.sh: CHDL dev git fetch failure"
        sstDepsAnnounce -h $FUNCNAME -m \
          "Is http_proxy configured properly in $HOME/.wgetrc?"
        popd
        return $retval
    fi

    #  Move into the chdl_dev directory
    pushd ${SST_DEPS_SRC_STAGED_CHDL}
    echo "chdl.git" `git log HEAD | sed 4q` >&2

#    #  Move back to December 8, 2014 position in Repository.
#    #  (The gcc-4-7 test on Jenkins was apparently broken on January 6th.)
#
#    git reset --hard ba3cbe3d63fcae84f6fb39d0c6d4eace524c364a

    popd

#   sstDepsAnnounce -h $FUNCNAME -m "Fetched CHDL from github rev ba3cbe3d63fcae84f6fb39d0c6d4eace524c364a"

    popd
}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_chdl
# Purpose:
#     Build and install SST CHDL dependency.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed CHDL dependency
# Caveats:
#     Depends on G++ >= 4.7
#-------------------------------------------------------------------------------
sstDepsDeploy_chdl ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying CHDL dev"

    pushd ${SST_DEPS_SRC_STAGED_CHDL}

    # Build and install chdl
    make install PREFIX=${SST_DEPS_INSTALL_DEPS}/packages/chdl
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_chdl_dev.sh: CHDL make install failure"
        popd
        return $retval
    fi

    popd
}

# Installation location of CHDL (installation root)
export SST_DEPS_INSTALL_CHDL=${SST_DEPS_INSTALL_DEPS}/packages/chdl
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_chdl
# Purpose:
#     Query SST CHDL dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported CHDL dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_chdl ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_CHDL=\"dev\""
    echo "export SST_DEPS_INSTALL_CHDL=\"${SST_DEPS_INSTALL_CHDL}\""
}
