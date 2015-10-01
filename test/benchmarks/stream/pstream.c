
/*
	STREAM Benchmark Implementation for the Structural Simulation Toolkit
	based on the original STREAM code by John D. McCalpin.
	
	Original code is (C) Copyright 1991 - 2005, John D. McCalpin.
*/

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define N 10000000
#define NTIMES 10
#define OFFSET 0

void copy_kernel(double* c, double* a, int start, int stop) {
	int counter;

	for(counter = start; counter < stop; counter++) {
		c[counter] = a[counter];
	}
}

void scale_kernel(double* b, double* c, double scalar, int start, int stop) {
	int counter = 0;

	for(counter = start; counter < stop; counter++) {
		b[counter] = scalar * c[counter];
	}
}

void add_kernel(double* c, double* a, double* b, int start, int stop) {
	int counter = 0;

	for(counter = start; counter < stop; counter++) {
		c[counter] = a[counter] + b[counter];
	}
}

void triad_kernel(double* a, double* b, double* c, double scalar, int start, int stop) {
	int counter;

	for(counter = start; counter < stop; counter++) {
		a[counter] = b[counter] + scalar * c[counter];
	}
}

void check_results(double* a, double* b, double* c, double scalar, int start, int stop) {

	double aj, bj, cj;
	double asum, bsum, csum;
	double epsilon;

	aj = 1.0;
	bj = 2.0;
	cj = 0.0;

	aj = 2.0e0 * aj;

	int counter;

	for(counter = 0; counter < NTIMES; counter++) {
		cj = aj;
		bj = scalar * cj;
		cj = aj + bj;
		aj = bj + scalar * cj;
	}

	aj = aj * (double) N;
	bj = bj * (double) N;
	cj = cj * (double) N;

	asum = 0.0;
	bsum = 0.0;
	csum = 0.0;

	for(counter = 0; counter < N; counter++) {
		asum += a[counter];
		bsum += b[counter];
		csum += c[counter];
	}

	epsilon = 1.0e-8;

	if( abs( aj - asum ) / asum > epsilon ) {
		printf("Failed results check\n");
		exit(-1);
	}

	if( abs( bj - bsum ) / bsum > epsilon ) {
		printf("Failed result check\n");
		exit(-1);
	}

	if( abs( cj - csum) / csum > epsilon ) {
		printf("Failed result check\n");
		exit(-1);
	}

	printf("Validation succeeded\n");
}

void init_kernel(double* a, double* b, double* c, int start, int stop) {
	int counter = 0;

	for(counter = start; counter < N; counter++) {
		a[counter] = 1.0;
		b[counter] = 2.0;
		c[counter] = 0.0;
	}
}

double getseconds() {
	struct timeval tp;
	struct timezone tzone;
	
	gettimeofday( &tp, &tzone );
	return ((double) tp.tv_sec) + ((double) tp.tv_usec * 1.0e-6);
}

int main(int argc, char* argv[]) {

	printf("----------------------------------------------------------\n");
	printf("STREAM pthread Implementation for SST\n");
	printf("----------------------------------------------------------\n");
	
	printf("Size of a double is: %lu bytes\n", sizeof(double));
	printf("Size of an array is: %lu bytes\n", sizeof(double) * (N+OFFSET));
	printf("For all arrays:      %lu bytes\n", 
		sizeof(double) * (N+OFFSET) * 3);
	
	#ifdef DYNAMIC_ALLOC
	double* a = (double*) malloc(sizeof(double) * (N + OFFSET));
	double* b = (double*) malloc(sizeof(double) * (N + OFFSET));
	double* c = (double*) malloc(sizeof(double) * (N + OFFSET));
	#else
	double a[N+OFFSET];
	double b[N+OFFSET];
	double c[N+OFFSET];
	#endif

	int counter;
	double scalar = 3.0;
	
	double kernel_times[NTIMES];
	double kernel_bytes[NTIMES];
	
	for(counter = 0; counter < 4; counter++) {
		kernel_times[counter] = 0.0;
		kernel_bytes[counter] = 0.0;
	}
	
	printf("----------------------------------------------------------\n");
	
	printf("Performing benchmarks...\n");
	double start, end;
	for(counter = 0; counter < NTIMES; counter++) {
	
		start = getseconds();  
		copy_kernel(c, a, OFFSET, N);
		end = getseconds();
		kernel_times[0] += (end - start);
		kernel_bytes[0] += 2 * N * sizeof(double);
		
		start = getseconds();
		scale_kernel(b, c, scalar, OFFSET, N);
		end = getseconds();
		kernel_times[1] += (end - start);
		kernel_bytes[1] += 2 * N * sizeof(double);
		
		start = getseconds();
		add_kernel(c, a, b, OFFSET, N);
		end = getseconds();
		kernel_times[2] += (end - start);
		kernel_bytes[2] += 3 * N * sizeof(double);
		
		start = getseconds();
		triad_kernel(a, b, c, scalar, OFFSET, N);
		end = getseconds();
		kernel_times[3] += (end - start);
		kernel_bytes[3] += 3 * N * sizeof(double);

	}
	printf("Benchmarks completed.\n");
	
	const double GB_scale = (1.0 / (1024.0 * 1024.0 * 1024.0));
	
	printf("Copy Kernel:\n");
	printf(" -> %f seconds\n", kernel_times[0]);
	printf(" -> %f GB/seconds\n", (kernel_bytes[0] * GB_scale) / kernel_times[0]);
	
	printf("Scale Kernel:\n");
	printf(" -> %f seconds\n", kernel_times[1]);
	printf(" -> %f GB/seconds\n", (kernel_bytes[1] * GB_scale) / kernel_times[1]);
	
	printf("Add Kernel:\n");
	printf(" -> %f seconds\n", kernel_times[2]);
	printf(" -> %f GB/seconds\n", (kernel_bytes[2] * GB_scale) / kernel_times[2]);
	
	printf("Triad Kernel:\n");
	printf(" -> %f seconds\n", kernel_times[3]);
	printf(" -> %f GB/seconds\n", (kernel_bytes[3] * GB_scale) / kernel_times[3]);
	
	printf("----------------------------------------------------------\n");
	printf("Checking for valid results...\n");
	check_results(a, b, c, scalar, 0, N);
	printf("----------------------------------------------------------\n");
	
}
