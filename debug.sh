#!/bin/bash

set -euo pipefail
set -x

IFS=$'\n\t'
SST_DEPS_USER_DIR=$(mktemp -d)
GITHUB_WORKSPACE=$(pwd)

export SST_DEPS_USER_DIR
export GITHUB_WORKSPACE
export BUILD_TYPE=sstmainline_config_no_mpi
export COMPILER_TYPE=none
export MPI_TYPE=none
export CUDA_TYPE=none

# shellcheck disable=SC1091
source .github/scripts/call_bamboo.sh
