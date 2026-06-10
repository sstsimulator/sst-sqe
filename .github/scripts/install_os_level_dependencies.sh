#!/bin/bash

# install_os_level_dependencies.sh: Install dependencies at the operating
# system level needed for GitHub CI runs.

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
if command -v brew; then
    brew install \
         autoconf \
         automake \
         coreutils \
         doxygen \
         libtool \
         lmod \
         lit \
         llvm@22 \
         ncurses \
         open-mpi \
         pygments
    python -m pip install blessings
    p="source /opt/homebrew/opt/lmod/init/profile"
    echo "${p}" >> ~/.bash_profile
    echo "${p}" >> ~/.bashrc
elif command -v apt-get; then
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y update
    sudo apt-get -y install \
         autoconf \
         automake \
         build-essential \
         ccache \
         doxygen \
         libopenmpi-dev \
         libtool-bin \
         lmod \
         python3-blessings \
         python3-pip \
         python3-pygments \
         wget
    if [[ "${SST_INSTALL_LLVM:-0}" == "1" ]]; then
        wget https://apt.llvm.org/llvm.sh
        chmod +x llvm.sh
        sudo ./llvm.sh 22
        sudo apt-get -y install \
             clang-22 \
             libclang-22-dev \
             libclang-cpp22-dev \
             llvm-22-dev
        python3 -m pip install lit
        if [[ -n "${GITHUB_PATH:-}" ]]; then
            echo "/usr/lib/llvm-22/bin" >> "${GITHUB_PATH}"
        fi
        if [[ -n "${GITHUB_ENV:-}" ]]; then
            echo "LLVM_ROOT=/usr/lib/llvm-22" >> "${GITHUB_ENV}"
            echo "FILECHECK=/usr/lib/llvm-22/bin/FileCheck" >> "${GITHUB_ENV}"
        fi
    fi
    p="source /etc/profile.d/lmod.sh"
    echo "${p}" >> ~/.bash_profile
    echo "${p}" >> ~/.bashrc
fi
