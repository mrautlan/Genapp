//GENAPLAY  JOB ,NOTIFY=&SYSUID,REGION=0M
//PLAYBK   EXEC PGM=BZUPLAY,PARM='TRACE=N'
//STEPLIB  DD DISP=SHR,DSN=BZU.SBZULOAD
//         DD DISP=SHR,DSN=DMJTA1.DLAYDBG.LOADDBG
//*         DD DISP=SHR,DSN=DMJTA1.DEFECT.LOAD
//         DD DISP=SHR,DSN=DMJTA1.LOAD
//BZUPLAY  DD DISP=SHR,DSN=DMJTA1.MYDEFECT.DOB.CUST1
//*BZUPLAY  DD DISP=SHR,DSN=DMJTA1.REGRESS.INQTEST
//*        DD DISP=SHR,DSN=DMJTA1.REGRESS.NOCUST
//SYSOUT   DD SYSOUT=*       (this keeps LE output in one spool file)
//BZUMSG  DD SYSOUT=*        (optional, can be a VB output dataset)
//*
//*If the change is disruptive, then use DD BZUNEXT to update test pack
//*
//*//BZUNEXT   DD  DSN=<TESTPACK PLAYBACK/RECORDING FILE NEW>
//*//             DISP=(NEW,CATLG,DELETE),
//*//             SPACE=(TRK,5),
//*//             DCB=(RECFM=VB,LRECL=32756,BLKSIZE=32760,DSORG=PS)
//CEEOPTS  DD  *
TEST
//*TEST(ALL,,PROMPT,TCPIP&9.145.50.118%8001:*)
//*TEST(,,,DBMDT%DMJTA1:*)
//*ENVAR(
//*"EQA_STARTUP_KEY=CC")
//*//CEEOPTS  DD  *
//*  TRAP(OFF),STORAGE(EE,NONE,00),
//*  STACK(4K,4080,ANYWHERE,KEEP,4K,4080)
//*  RPTOPTS(OFF)
//*  TEST
//*//SYSOUT DD SYSOUT=*

