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
	printf("#SSTTEST Performing repeated allocate, deallocate routines...\n");

	const int ELEMENT_COUNT   = 8192;
	const int ITERATION_COUNT = 64;
	char* big_array;
	int i, itr;

	for(itr = 0; itr < ITERATION_COUNT; itr++) {
		printf("#SSTTEST Allocating memory...\n");
		big_array = (char*) malloc(ELEMENT_COUNT * sizeof(char));
		
		if(big_array == NULL) {
			printf("#SSTTEST Allocation results in NULL. Error.\n");
			exit(-2);
		} else {
			printf("#SSTTEST Allocation successful.\n");
		}

		for(i = 0; i < ELEMENT_COUNT; i++) {
			big_array[i] = (char) ((i + itr) % 64);
		}

		unsigned int sum = 0;
		for(i = 0; i < ELEMENT_COUNT; i++) {
			sum = sum + (int) big_array[i];
		}

		printf("#SSTTEST Sum of elements iteration %d = %d\n",
			itr, sum);
		printf("#SSTTEST Freeing memory...\n");
		free(big_array);
		printf("#SSTTEST Memory free call completed.\n");
	}

	printf("#SSTTEST Completed.\n");

	return 0;
}
