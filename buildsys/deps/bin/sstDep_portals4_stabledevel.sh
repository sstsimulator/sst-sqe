#!/bin/bash
# sstDep_portals4.sh

# Description

# A bash script that does next to nothing.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to portals4
export SST_BUILD_PORTALS4=1

# ====================================================================
# PORTALS4
# ====================================================================

# There Currently is no staging routine.


# There Currently is no Deploying routine


# It is possible that the build of the user test program will get in here.
