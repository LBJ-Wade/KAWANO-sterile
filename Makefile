# https://gcc.gnu.org/onlinedocs/gfortran/Fortran-Dialect-Options.html

FLAGS = -freal-4-real-8 -fno-align-commons -Ofast

all: clean python kawano test

python:
	f2py -c -m interpolation interpolation.f90 --f90flags="$(FLAGS)"

kawano:
	gfortran kawano_steriles.f newint.f nuccom.f nucrat.f interpolation.f90 $(FLAGS) -o kawano

clean:
	rm -f *.o *.so *.mod kawano

test:
	pip install -U pytest
	py.test -v