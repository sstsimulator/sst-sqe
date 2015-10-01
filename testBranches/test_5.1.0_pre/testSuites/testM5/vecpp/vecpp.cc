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

#include <iostream>
#include <vector>

int main(int argc, char* argv[]) {

	const int elements = 1024;
	std::vector<double> big_vector(elements);

	for(int i = 0; i < elements; i++) {
		big_vector[i] = i;
	}

	big_vector[elements/2] = 4;

	double sum = 0;
	for(int i = 0; i < elements; i++) {
		sum += big_vector[i];
	}

	std::cout << "Summed: " << elements << " sum is: " << sum << std::endl;

	return 0;
}
