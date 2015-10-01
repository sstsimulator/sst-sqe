include ../Makefile.inc

CFLAGS=-std=c99 -static

bjmtest.x: bjmtest.o
	$(CC) $(CFLAGS) -o $@ $< -lgomp -L ../pthread/m5threads -lpthread

bjmtest.o: bjmtest.c
	$(CC) $(CFLAGS) $(OMP) -o $@ -c $<

clean:
	rm -f bjmtest.x *.o
