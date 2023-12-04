#! /bin/bash

cd $MPI_TESTS_DIRECTORY
module load $1 $2
cd $MPI_TESTS_DIRECTORY && make
flux run -n2 ./mpi_tests
make clean
