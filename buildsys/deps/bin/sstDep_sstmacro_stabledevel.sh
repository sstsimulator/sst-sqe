# !/bin/bash
# sstDep_sstmacro_stabledevel.sh

# Description: 

# A bash script containing functions to process SST's sstmacro
# dependency.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to sstmacro
export SST_BUILD_SSTMACRO=1
# Environment variable uniquely identifying this script
export SST_BUILD_SSTMACRO_STABLEDEVEL=1
#===============================================================================
# SSTMACRO
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_sstmacro
# Purpose:
#     Prepare sstmacro for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged sstmacro code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_SSTMACRO_STABLEDEVEL=${SST_DEPS_SRC_STAGING}/sstmacro
sstDepsStage_sstmacro ()
{

    # NOTE: Mercurial only half-heartedly respects the "http_proxy"
    # environment variable.  At this point, there are 2 options:
    #
    # 1) Specify proxy in "hg clone" operation
    #    - Doing this will make this script particular to our local
    #      which will make it unusable by external users.
    #
    # 2) Specify proxy in hg's local configuration file ~/.hgrc or in
    #    systemwide /etc/mercurial/hgrc file
    #    - This script will respect this convention so that users can
    #      specify a proxy as needed.
    #    - Example .hgrc section for proxy, where 8030 is the proxy port
    #      [http_proxy]
    #      host = hostnameOfYourHttpProxy:8030
    #

    # Fetch latest sstmacro from their repository. Once fetched, files
    # should be available in $SST_DEPS_SRC_STAGED_SSTMACRO
    sstDepsAnnounce -h $FUNCNAME -m "Staging latest sstmacro"
    pushd ${SST_DEPS_SRC_STAGING}
    hg clone https://bitbucket.org/ghendry/sstmacro
    retval=$?
## pwd
## ls
##     cd sstmacro
##     hg update d5f8be1a71e430553f849a05f4ef2fa436d19604
    popd
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_sstmacro_stabledevel.sh: sstmacro hg repository clone failure."
        echo "       Is the parent repository host available and online?"
        echo "       Do you need to configure an HTTP proxy in your ~/.hgrc?"
        echo "       Example ~/.hgrc section, where 8030 is an example proxyport:"
        echo "       [http_proxy]"
        echo "       host = yourHttpProxyHostname:8030"
        return $retval
    fi

    # get branch and working copy rev info
    pushd ${SST_DEPS_SRC_STAGING}
    globalrev=`hg id --id sstmacro/`
    branch=`hg id --branch sstmacro/`
    popd
    echo "  sstmacro global rev:  $globalrev"
    echo "  sstmacro     branch:  $branch"

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_sstmacro
# Purpose:
#     Build and install SST sstmacro dependency
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed sstmacro dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_sstmacro ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Deploying latest sstmacro"
    pushd ${SST_DEPS_SRC_STAGED_SSTMACRO_STABLEDEVEL}

    ./bootstrap.sh
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_sstmacro_stabledevel.sh: sstmacro bootstrap.sh failure"
        return $retval
    fi

    # Follow sstmacro installation directions (bootstrap.sh, configure, make, make install)
    ./configure --prefix=${SST_DEPS_INSTALL_DEPS} --with-boost=${SST_DEPS_INSTALL_DEPS} --with-sst CC=`which gcc` CXX=`which g++`
    retval=$?
    if [ $retval -ne 0 ]
    then

        # Something went wrong
        echo "ERROR: sstDep_sstmacro_stabledevel.sh: sstmacro configure failure"
        echo "       sstmacro requires boost. Is Boost installed?"

        # Something went wrong in configure, so dump config.log
        echo "bamboo.sh: dumping sstmacro config.log"
        echo "--------------------dump of config.log--------------------"
        sed -e 's/^/#dump /' ./config.log
        echo "--------------------dump of config.log--------------------"

        return $retval
    fi

    make
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_sstmacro_stabledevel.sh: sstmacro make failure"
        echo "       sstmacro requires boost. Is Boost installed?"
        return $retval
    fi

    make install
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: sstDep_sstmacro_stabledevel.sh: sstmacro install failure"
        return $retval
    fi

    popd

}


# Installation location 
export SST_DEPS_INSTALL_SSTMACRO=${SST_DEPS_INSTALL_DEPS}
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_sstmacro
# Purpose:
#     Query sstmacro dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported sstmacrodependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_sstmacro ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_SSTMACRO=\"REPOSITORY\""
    echo "export SST_DEPS_INSTALL_SSTMACRO=\"${SST_DEPS_INSTALL_SSTMACRO}\""
}
