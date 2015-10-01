// Copyright 2009-2015 Sandia Corporation. Under the terms
// of Contract DE-AC04-94AL85000 with Sandia Corporation, the U.S.
// Government retains certain rights in this software.
// 
// Copyright (c) 2009-2015, Sandia Corporation
// All rights reserved.
// 
// This file is part of the SST software package. For license
// information, see the LICENSE file in the top level directory of the
// distribution.

#include <stdlib.h>
#include <stdio.h>


int main(int argc, char* argv[]) {

	int MATRIX_N = 100;

	if(argc > 1) {
		MATRIX_N = atoi(argv[1]);
	}

	printf("Generating matrices of size %d x %d\n",
		MATRIX_N, MATRIX_N);
	printf("Memory estimate per matrix: %lu\n",
		sizeof(double) * MATRIX_N * MATRIX_N);
	printf("Memory estimate total:      %lu\n",
		sizeof(double) * MATRIX_N * MATRIX_N * 3);

	double** matrixA = (double**) malloc(sizeof(double*) * MATRIX_N);
	double** matrixB = (double**) malloc(sizeof(double*) * MATRIX_N);
	double** matrixC = (double**) malloc(sizeof(double*) * MATRIX_N);

	int i, j, k;
	for(i = 0; i < MATRIX_N; i++) {
		matrixA[i] = (double*) malloc(sizeof(double) * MATRIX_N);
		matrixB[i] = (double*) malloc(sizeof(double) * MATRIX_N);
		matrixC[i] = (double*) malloc(sizeof(double) * MATRIX_N);

		for(j = 0; j < MATRIX_N; j++) {
			matrixA[i][j] = i + j;
			matrixB[i][j] = i * j;
			matrixC[i][j] = 0;
		}
	}

	for(i = 0; i < MATRIX_N; i++) {
		for(j = 0; j < MATRIX_N; j++) {
			for(k = 0; k < MATRIX_N; k++) {
				matrixC[i][j] += matrixA[i][k] * matrixB[k][j];
			}
		}
	}

	double sum = 0;
	double count = 0;

	for(i = 0; i < MATRIX_N; i++) {
		for(j = 0; j < MATRIX_N; j++) {
			count += 1.0;
			sum += matrixC[i][j];
		}
	}

	printf("Matrix avg value is: %f \n", (sum/count));

	free(matrixA);
	free(matrixB);
	free(matrixC);

	return 0;
}
