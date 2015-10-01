include ../Makefile.inc

ompfort.x: ompfort.o
	$(FC) $(FFLAGS) $(LDFLAGS) -o $@ $< -lgomp -L ../pthread/m5threads -lpthread -lrt

ompfort.o: ompfort.f90
	$(FC) $(FFLAGS) $(OMP) -o $@ -c $<

clean:
	rm -f ompfort.x *.o
