#!/bin/bash

# call_bamboo.sh: wrapper for calling bamboo.sh inside of a GitHub Action
# workflow.

set -euo pipefail

# needed for ncurses part of interactive sst-info
export TERM=dumb
MAKEFLAGS="-j$(nproc)"
export MAKEFLAGS
if [[ "$(uname)" == "Darwin" ]]; then
    export PMIX_MCA_gds=hash
fi
export SST_DEPS_USER_MODE=1
mkdir -p "${SST_DEPS_USER_DIR}/devel/trunk"
mv "${GITHUB_WORKSPACE}" "${SST_DEPS_USER_DIR}/devel/sqe"
cd "${SST_DEPS_USER_DIR}/devel/trunk"
if [[ "${COMPILER_TYPE}" != "none" ]]; then
    if [[ "${COMPILER_TYPE}" == "clang" ]]; then
        CC="$(command -v clang)"
        CXX="$(command -v clang++)"
        # No need for this and unavailable with macOS-provided compiler
        # CXXFLAGS="-stdlib=libstdc++"
    elif [[ "${COMPILER_TYPE}" == "clang-libc++" ]]; then
        CC="$(command -v clang)"
        CXX="$(command -v clang++)"
        CXXFLAGS="-stdlib=libc++"
    fi
    export CC
    export CXX
    export CXXFLAGS
fi
# passing the compiler as the fourth argument isn't necessary if no `module
# load` is desired, in which case COMPILER_TYPE should be "none"
../sqe/buildsys/bamboo.sh \
    "${BUILD_TYPE}" \
    "${MPI_TYPE}" \
    none \
    "${COMPILER_TYPE}" \
    none \
    none
