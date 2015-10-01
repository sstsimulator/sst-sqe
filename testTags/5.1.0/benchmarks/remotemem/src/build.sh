#!/bin/bash

if [ `uname` = "Darwin" ]; then
	clang++ -O3 -o lulesh lulesh-OPTIM-OMP-ALLOC-VEC3-AGA.cc
else
	g++ -o lulesh -O3 lulesh-OPTIM-OMP-ALLOC-VEC3-AGA.cc
fi
