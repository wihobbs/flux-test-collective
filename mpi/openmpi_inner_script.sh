#! /bin/bash

die () {
    echo "$@"
    exit 1
}

BATCH_NNODES=$(flux resource list -n -o {nnodes})
BATCH_NCORES=$(flux resource list -n -o {ncores})
COMPILER=$1
MPI=$2
export NAME="$COMPILER"_"$MPI"

test -n $COMPILER || die "COMPILER (argument 1) not set"
test -n $MPI || die "MPI (argument 2) not set"
module load $COMPILER || die "Compiler $COMPILER is unavailable on $LCSCHEDCLUSTER"
module load $MPI || die "MPI implementation $MPI is unavailable on $LCSCHEDCLUSTER"
test -n $FTC_DIRECTORY || die "FTC_DIRECTORY not set"
mkdir $FTC_DIRECTORY/$NAME || die "Unable to create directory for $FTC_DIRECTORY/$NAME"
cp -r $MPI_TESTS_DIRECTORY/* $FTC_DIRECTORY/$NAME
cd $FTC_DIRECTORY/$NAME || die "Could not find $FTC_DIRECTORY/$NAME"
echo "Running with $1 compiler and $2 MPI"
flux bulksubmit -n1 --watch mpicc -o {} {}.c ::: $TESTS || die "Compilation failure in tests"
flux bulksubmit --watch -N $BATCH_NNODES -n $BATCH_NCORES -o pmi=pmix --output=kvs ./{} ::: $TESTS
RC=$?
exit $RC
