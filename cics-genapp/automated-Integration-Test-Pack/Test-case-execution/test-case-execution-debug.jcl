//VTPEXEC JOB ,
// MSGCLASS=H,MSGLEVEL=(1,1),TIME=(,4),REGION=144M,COND=(16,LT)
//*
//* Action: Run Test Case...
//*
//MYS1 JCLLIB ORDER=IDZ15.BZU00.#CUST.PROCLIB
// SET DSNMETA=DMJTA1.MY.META
// SET PLAYBACK=DMJTA1.DEFECT.DOB
// SET LOAD=DMJTA1.LOAD
//*
//STEP001 EXEC PGM=IEFBR14
//BZUMETA DD DSN=&DSNMETA,
//           DISP=(MOD,DELETE),SPACE=(TRK,1)
//*
//RUNNER EXEC PROC=BZUPPLAY,
//        PRM='TRACE=N',
//*        BZULOD2=DMJTA1.LOAD,
//        BZULOD=&LOAD,
//        BZUPLAY=&PLAYBACK
//STEPLIB  DD DISP=SHR,DSN=&BZU..SBZULOAD
//*         DD DISP=SHR,DSN=&BZU..SBZULMOD      Test Runner replay
//*         DD DISP=SHR,DSN=&BZU..SBZULLEP      Test Runner replay
//         DD DISP=SHR,DSN=&CEE..SCEERUN       LE
//         DD DISP=SHR,DSN=&CEE..SCEERUN2      LE
//         DD DISP=SHR,DSN=DMJTA1.DLAYDBG.LOADDBG
//         DD DISP=SHR,DSN=&EQA..SEQAMOD       Debugger
//*         DD DISP=SHR,DSN=&BZULOD2             caller provided
//         DD DISP=SHR,DSN=&BZULOD
//         DD DISP=SHR,DSN=&BZUCBK             caller provided
//         DD DISP=SHR,DSN=&BZUEXTRA           caller provided
//*//************************************************************
//*// SET DSNSRC=DMJTA1.FEATURE.ZPROJ100
//*//************************************************************
//REPLAY.BZUMETA DD DSN=&DSNMETA,
//     DISP=(NEW,CATLG),SPACE=(TRK,(100,50)),
//     DCB=(BLKSIZE=8196,LRECL=8192,RECFM=VB)
//CEEOPTS  DD  *
  TRAP(OFF),STORAGE(EE,NONE,00),
  STACK(4K,4080,ANYWHERE,KEEP,4K,4080)
  RPTOPTS(OFF)
  TEST
//SYSOUT DD SYSOUT=*
