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

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
	printf("#SSTTEST Allocating memory...\n");

	const int ELEMENT_COUNT = 8192;
	char* big_array = (char*) malloc(sizeof(char) * ELEMENT_COUNT);
	int i;

	if(big_array == NULL) {
		printf("#SSTTEST ERROR: MEMORY ALLOCATION FAILED PTR==NULL\n"); 
		exit(-1);
	}

	for(i = 0; i < ELEMENT_COUNT; i++) {
		big_array[i] = (char) (i % 64);
	}

	int sum = 0;
	for(i = 0; i < ELEMENT_COUNT; i++) {
		sum = sum + (int) big_array[i];
	}

	printf("#SSTTEST Sum of elements is %d\n", sum);

	printf("#SSTTEST Freeing memory...\n");
	free(big_array);
	printf("#SSTTEST Completed.\n");

	return 0;
}
