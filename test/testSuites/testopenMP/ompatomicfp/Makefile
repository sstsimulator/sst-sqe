include ../Makefile.inc

ompatomicfp.x: ompatomicfp.o
	$(CC) $(CFLAGS) -o $@ $< -lgomp -L ../pthread/m5threads -lpthread

ompatomicfp.o: ompatomicfp.c
	$(CC) $(CFLAGS) $(OMP) -o $@ -c $<

clean:
	rm -f ompatomicfp.x *.o
