#!/bin/bash

# get_and_build_pebil.sh: Clone and install
# https://github.com/epanalytics/PEBIL/tree/feature/sst
#
# This is intentionally more procedural than the sstDep_*.sh scripts, since
# PEBIL must be built after SST.

set -euo pipefail

export SST_DEPS_SRC_STAGED_PEBIL="${SST_DEPS_SRC_STAGING}"/pebil
git clone -b feature/sst https://github.com/epanalytics/PEBIL.git "${SST_DEPS_SRC_STAGED_PEBIL}"
pushd "${SST_DEPS_SRC_STAGED_PEBIL}"
git submodule init external/epa-inst-libs
git submodule update
SST_CONFIG="${SST_CORE_INSTALL_BIN}"/sst-config
configure \
    --with-sst-core="$("${SST_CONFIG}" --prefix)" \
    --with-sst-elements="$("${SST_CONFIG}" SST_ELEMENT_LIBRARY SST_ELEMENT_LIBRARY_SOURCE_ROOT)"
# shellcheck disable=SC1091
source "${SST_DEPS_SRC_STAGED_PEBIL}"/bashrc
make all install
popd
