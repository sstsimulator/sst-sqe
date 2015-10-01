

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define NTHREADS 8
#ifndef NCOUNT
#define NCOUNT 100000
#endif
#define TARGET (NTHREADS*NCOUNT)

static int counter;
static int counter2;

static inline void atomic_add(int * operand, int incr)
{
#if 0
    __asm__ volatile (
            "lock xaddl %1, (%0)\n" // add incr to operand
            : // no output
            : "r" (operand), "r" (incr)
            );
#else
    __sync_fetch_and_add(operand, incr);
#endif
}


void* threadFunc(void *id)
{
    int tid = (int)id;
    printf("Hello from thread %d\n", id);
    for ( int i = 0 ; i < NCOUNT ; i++ ) {
        atomic_add(&counter, 1);
        atomic_add(&counter2, -1);
        if((NCOUNT % 250) == 0) printf(".");
    }
}

int main(int argc, char **argv)
{

    pthread_t threads[NTHREADS];

    counter = 0;
    counter2 = TARGET;

    for ( int t = 0 ; t < NTHREADS-1 ; t++ ) {
        printf("Creating thread %d\n", t+1);
        int rc = pthread_create(&threads[t], NULL, threadFunc, (void*)(t+1));
        if ( rc ) {
            printf("Error creating thread.  Code:  %d\n", rc);
            exit(-1);
        }
    }

    threadFunc((void*)0);

    printf("Waiting for threads to finish.");
    for ( int t = 0 ; t < NTHREADS-1 ; t++ ) {
        pthread_join(threads[t], NULL);
        printf("."); fflush(stdout);
    }

    printf("\nEnd result:  %d, %d.  Expected Result:  %d, %d.   %s\n",
            counter, counter2, TARGET, 0,
            (counter == TARGET && counter2 == 0) ? "PASS" : "FAIL");

    pthread_exit(NULL);

    return 0;
}
