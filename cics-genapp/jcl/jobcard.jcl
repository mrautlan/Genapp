//JOBTEST JOB ,
// MSGCLASS=H,MSGLEVEL=(1,1),TIME=(,4),REGION=144M,COND=(16,LT)
//*
//* testcase generation needs compiler v6.2 to prevent IGYPS2112
//*     FEL.#CUST.PROCLIB
//* but recompile of EPSPDB2 needs compiler 4.2 for static calls
//*   to stubs: OLIVIER.IDZ141.PROCLIB
//* on link step, SDFHLOAD needs to come before SDSNLOAD for
//*    SQLCA override to work
//*PROCS JCLLIB ORDER=(FEL.#CUST.PROCLIB)
//       EXEC PGM=IEFBR14