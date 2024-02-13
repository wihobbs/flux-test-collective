#!/bin/bash

## REQUIRES: $MPI_TESTS_DIRECTORY $FTC_DIRECTORY $LCSCHEDCLUSTER

corona_COMPILERS="
gcc
clang
intel-classic
"

corona_MPIS="
mvapich2
openmpi
"

export TESTS="hello
abort
version
"

tioga_COMPILERS="
gcc
cce
"

tioga_MPIS="
cray-mpich
"

MPIS="${LCSCHEDCLUSTER}_MPIS"
COMPILERS="${LCSCHEDCLUSTER}_COMPILERS"

for mpi in ${!MPIS}; do
    for compiler in ${!COMPILERS}; do
        if [[ $mpi == "cray-mpich" ]]; then
            EXTRA_FLUX_SUBMIT_OPTIONS="-o pmi=cray-pals" flux batch -N2 -n4 --flags=waitable --output=kvs $MPI_TESTS_DIRECTORY/inner_script.sh $mpi $compiler
        elif [[ $mpi == "openmpi" ]]; then
            EXTRA_FLUX_SUBMIT_OPTIONS="-o pmi=pmix" flux batch -N2 -n4 --flags=waitable --output=kvs $MPI_TESTS_DIRECTORY/inner_script.sh $mpi $compiler
        else
            flux batch -N2 -n4 --flags=waitable --output=kvs $MPI_TESTS_DIRECTORY/inner_script.sh $mpi $compiler
        fi 
    done
done
flux job wait --all
RC=$?
for id in $(flux jobs -a -no {id}); do
    printf "\033[31mjob $id completed:\033[0m\n"
    flux job attach $id
done

exit $RC
