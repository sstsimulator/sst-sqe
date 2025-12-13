#!/bin/bash

# run-bamboo-like-github.sh: Just like it says on the tin.  Runs
# call_bamboo.sh in a way as close as possible to the GitHub Actions workflow.
# Bamboo command-line args are hardcoded in this file for convenience.
#
# How to use:
#
# - Manually edit the BUILD_TYPE, MPI_TYPE, and COMPILER_TYPE environment
#   variables at the bottom of the file.  These are the arguments that end up
#   getting passed directly to bamboo.sh.  (Try to avoid commiting any changes
#   to version control.)
#
# - From the top-level SQE directory, run something like
#   `./dev/run-bamboo-like-github.sh >& bamboo.log`.  (Standard out and error
#   need to be redirected, otherwise there are problems with commands
#   somewhere inside of bamboo.)  If you want to use `tee`, you need to add
#   the redirection for standard error like so:
#   `./dev/run-bamboo-like-github.sh 2>&1 | tee bamboo2.log`.

set -euo pipefail

if [[ -t 1 ]]; then
    echo "stdout is interactive but must be redirected for this script to run properly"
    exit 1
fi
if [[ -t 2 ]]; then
    echo "stderr is interactive but must be redirected for this script to run properly"
    exit 1
fi

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x

tmpdir="$(mktemp --directory)"
echo "tmpdir: ${tmpdir}"

# GITHUB_WORKSPACE is /home/runner/work/sst-sqe/sst-sqe which is the location
# of this repo.
GITHUB_WORKSPACE_PRE="${tmpdir}/home/runner/work/sst-sqe"
mkdir -p "${GITHUB_WORKSPACE_PRE}"
repo_dir="$(realpath "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/..")"
cp -a "${repo_dir}" "${GITHUB_WORKSPACE_PRE}"
clone_name="$(basename "${repo_dir}")"
export GITHUB_WORKSPACE="${GITHUB_WORKSPACE_PRE}"/"${clone_name}"
pushd "${GITHUB_WORKSPACE}"

# "set env and prepare dir structure"
# In GH, /home/runner/work/sst-sqe/sst-deps-user-dir
sst_deps_user_dir="${GITHUB_WORKSPACE}/../sst-deps-user-dir"
mkdir -p "${sst_deps_user_dir}"
SST_DEPS_USER_DIR="$(realpath "${sst_deps_user_dir}")"
export SST_DEPS_USER_DIR

# "fetch elements dependencies"
pristine="${SST_DEPS_USER_DIR}"/sstDeps/src/pristine
mkdir -p "${pristine}"
pushd "${pristine}"
wget --no-verbose https://github.com/umd-memsys/DRAMSim2/archive/refs/tags/v2.2.2.tar.gz
popd

unset BUILD_TYPE
unset MPI_TYPE
unset COMPILER_TYPE
unset CUDA_TYPE

# "run bamboo"
#
# sstmainline_config | sstmainline_coreonly_config |
# sstmainline_coreonly_config_no_mpi | ...
export BUILD_TYPE=sstmainline_coreonly_config
export MPI_TYPE=openmpi-4.1.4
export COMPILER_TYPE=none

# Example for balar:
# export BUILD_TYPE=sstmainline_config_linux_with_cuda
# export MPI_TYPE=openmpi-4.1.4
# export COMPILER_TYPE=gcc-11.5.0
# export CUDA_TYPE=aue/cuda/11.8.0-gcc-10.3.0

bash ./.github/scripts/call_bamboo.sh
