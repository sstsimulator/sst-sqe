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

  long long int iterations = 100000;

  double pi_guess = 4.0f;

  long long unsigned int i = 0;
  long long unsigned int j = 0;

  if(argc > 1) {
      iterations = atol(argv[1]);

      int argc_counter = 0;

      printf("Main has: %d arguments\n", argc);
      for(argc_counter = 0; argc_counter < argc; argc_counter++) {
	printf("Argument[%5d] is: %s\n", argc_counter,
		argv[argc_counter]);
      }
  }

  for (i=1, j=3; i<=iterations; i++, j+=2) {
    if (i % 2 != 0) {
	pi_guess -= (4.0/j);
    } else {
        pi_guess += (4.0/j);
    }
  }

  printf("Estimate of Pi is: %20.30f\n", pi_guess);

}
