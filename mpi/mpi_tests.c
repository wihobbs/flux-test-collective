#include <unistd.h>
#include <stdio.h>

#include "mpi.h"

int HelloWorld() {
    int tasks, rank, len, rc;
    MPI_Init(NULL, NULL);
    MPI_Comm_size(MPI_COMM_WORLD, &tasks);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    char processor[MPI_MAX_PROCESSOR_NAME];
    MPI_Get_processor_name(processor, &len);
    printf("tasks=%d host=%s rank=%d\n", tasks, processor, rank);
    MPI_Finalize();
    return 0;
}

int main(void) {
    int rc;
    if ((rc = HelloWorld()) != 0) {
        printf("HelloWorld failed with return code %d\n", rc);
    }
}
