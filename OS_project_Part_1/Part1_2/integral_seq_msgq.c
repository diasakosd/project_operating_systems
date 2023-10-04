//Γρηγόρης Δελημπαλταδάκης, ΑΜ: 1084647
//Δαμιανός Διασάκος, ΑΜ: 1084632
//Αλκιβιάδης Δασκαλάκης, ΑΜ: 1084673
//Ιάσων Ράικος, ΑΜ: 1084552



#include <stdio.h>
#include <math.h>
#include <sys/time.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

double get_wtime(void)
{
    struct timeval t;
    gettimeofday(&t, NULL);
    return (double)t.tv_sec + (double)t.tv_usec*1.0e-6;
}

double f(double x)
{
    return log(x)*sqrt(x);
}

// WolframAlpha: integral_1^4 log(x) sqrt(x) dx = 4/9 (4 log(64)-7) ~= 4.28245881486164

int main(int argc, char *argv[])
{
    int N;
    printf("Please enter the number of processes: ");
    scanf("%d", &N);
    if(N>0){
        double a = 1.0;
        double b = 4.0;
        unsigned long const n = 1e9;
        const double dx = (b-a)/n;

        double S = 0;

        double t0 = get_wtime();

        int msgid;

        key_t key;

        struct msg_buf {
            long mtype;
            double mtext;
        } buf;

        key = ftok(".", 'S');

        msgid = msgget(key, 0666 | IPC_CREAT);

        pid_t pid;

        int i;
        for (i = 0; i < N; i++) {
            pid = fork();
            if (pid == 0) {
                //child process
                unsigned long start = i*n/N;

                unsigned long end = (i+1)*n/N;

                double S_local = 0;

                for (unsigned long j = start; j < end; j++) {
                    double xi = a + (j + 0.5)*dx;
                    S_local += f(xi);
                }
                buf.mtype = 1;
                buf.mtext = S_local*dx;

                msgsnd(msgid, &buf, sizeof(buf), 0);

                exit(0);
            }
        }


        for (i = 0; i < N; i++) {
            msgrcv(msgid, &buf, sizeof(buf), 1, 0);
            S += buf.mtext;
        }


        double t1 = get_wtime();
        printf("Time=%lf seconds, Result=%.8f\n", t1-t0, S);
        printf("Number of processes: %d\n",N);

        //close the queue
        msgctl(msgid, IPC_RMID, NULL);
    }else{
        printf("Error: You cannot compute the integral using 0 or less processes!\n");
    }

    return 0;
}
