
      PROGRAM TESTOMP

      INTEGER :: N, I
      PARAMETER (N=32768)
      DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:) :: X, Y
      DOUBLE PRECISION :: SUM

      PRINT *, 'Allocating Arrays...'
      ALLOCATE(X(N))
      ALLOCATE(Y(N))

      SUM = 0

!$OMP PARALLEL DO
      DO I = 1, N
	    X(I) = I
	    Y(I) = N - X(I)
      END DO
!$OMP END PARALLEL DO

!$OMP PARALLEL DO
      DO I = 1, N
            X(I) = X(I) + Y(I)
      END DO
!$OMP END PARALLEL DO

      DO I = 1, N
            SUM = SUM + X(I)
      END DO

      PRINT *, 'Sum is', SUM

      END
