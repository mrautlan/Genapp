//CREATET JOB ,
// MSGCLASS=H,MSGLEVEL=(1,1),TIME=(,4),REGION=144M,COND=(16,LT)
//*
//* Action: Run Test Case...
//*
//MYS1 JCLLIB ORDER=IDZ15.BZU00.#CUST.PROCLIB
//*
//RUNNER EXEC PROC=BZUPPLAY,
//        PRM='TRACE=N',
//        BZULOD2=DMJTA1.LOAD,
//        BZULOD=DMJTA1.GENAPP.APP.LOAD,
//        BZUPLAY=DMJTA1.DOB.DEFECT
//STEPLIB  DD DISP=SHR,DSN=&BZU..SBZULOAD
//*         DD DISP=SHR,DSN=&BZU..SBZULMOD      Test Runner replay
//*         DD DISP=SHR,DSN=&BZU..SBZULLEP      Test Runner replay
//         DD DISP=SHR,DSN=&CEE..SCEERUN       LE
//         DD DISP=SHR,DSN=&CEE..SCEERUN2      LE
//         DD DISP=SHR,DSN=DMJTA1.DLAYDBG.LOADDBG
//         DD DISP=SHR,DSN=&EQA..SEQAMOD       Debugger
//         DD DISP=SHR,DSN=&BZULOD2             caller provided
//         DD DISP=SHR,DSN=&BZULOD
//         DD DISP=SHR,DSN=&BZUCBK             caller provided
//         DD DISP=SHR,DSN=&BZUEXTRA           caller provided
//*//************************************************************
//*// SET DSNSRC=DMJTA1.FEATURE.ZPROJ100
//*//************************************************************
//REPLAY.BZUMETA DD DSN=DMJTA1.FEATURE.METAT1,
//     DISP=(NEW,CATLG),SPACE=(TRK,(100,50)),
//     DCB=(BLKSIZE=8196,LRECL=8192,RECFM=VB)
//CEEOPTS  DD  *
  TRAP(OFF),STORAGE(EE,NONE,00),
  STACK(4K,4080,ANYWHERE,KEEP,4K,4080)
  RPTOPTS(OFF)
  TEST
//SYSOUT DD SYSOUT=*
//
