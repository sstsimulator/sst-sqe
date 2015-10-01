include ../Makefile.inc

ompfibtask.x: ompfibtask.o
	$(CC) $(CFLAGS) -o $@ $< -lgomp -L ../pthread/m5threads -lpthread

ompfibtask.o: ompfibtask.c
	$(CC) $(CFLAGS) $(OMP) -o $@ -c $<

clean:
	rm -f ompfibtask.x *.o
