#! /bin/bash

die () {
    rm -rf $FTC_DIRECTORY/$NAME
    echo "$@"
    exit 1
}

BATCH_NNODES=$(flux resource list -n -o {nnodes})
BATCH_NCORES=$(flux resource list -n -o {ncores})
COMPILER=$1
MPI=$2
export NAME=$(echo "$COMPILER"_"$MPI" | sed "s/\///")

test -n $COMPILER || die "COMPILER (argument 1) not set"
test -n $MPI || die "MPI (argument 2) not set"
if [[ $MPI == "openmpi/5" ]]; then
    ## This is the Corona OpenMPI5 side-installed modulefile. Only load when
    ## openmpi5 is needed.
    module use -q /usr/global/tools/mpi/toss_4_x86_64_ib/modulefiles/Core/
fi
module load $COMPILER || die "Compiler $COMPILER is unavailable on $LCSCHEDCLUSTER"
module load $MPI || die "MPI implementation $MPI is unavailable on $LCSCHEDCLUSTER"
test -n $FTC_DIRECTORY || die "FTC_DIRECTORY not set"
mkdir $FTC_DIRECTORY/$NAME || die "Unable to create directory for $FTC_DIRECTORY/$NAME"
cp -r $MPI_TESTS_DIRECTORY/* $FTC_DIRECTORY/$NAME
cd $FTC_DIRECTORY/$NAME || die "Could not find $FTC_DIRECTORY/$NAME"
echo "Running with $COMPILER compiler and $MPI MPI"
flux bulksubmit -n1 --watch mpicc -o {} {}.c ::: $TESTS || die "Compilation failure in tests"
flux bulksubmit --watch -N $BATCH_NNODES -n $BATCH_NCORES $EXTRA_FLUX_SUBMIT_OPTIONS --output=kvs ./{} ::: $TESTS
RC=$?
rm -rf $FTC_DIRECTORY/$NAME
exit $RC
