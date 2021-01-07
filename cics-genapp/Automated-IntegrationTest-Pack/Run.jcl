//GENAPLAY  JOB ,NOTIFY=&SYSUID,REGION=0M
//PLAYBK   EXEC PGM=BZUPLAY,PARM='TRACE=N'
//STEPLIB  DD DISP=SHR,DSN=BZU.SBZULOAD
//         DD DISP=SHR,DSN=<LOAD LIBRARY + CHANGED MODULE>
//BZUPLAY  DD DISP=SHR,DSN=<TESTPACK PLAYBACK/RECORDING FILE>
//SYSOUT   DD SYSOUT=*       (this keeps LE output in one spool file)
//BZUMSG  DD SYSOUT=*        (optional, can be a VB output dataset)
//*
//*If the change is disruptive, then use DD BZUNEXT to update test pack
//*
//*//BZUNEXT   DD  DSN=<TESTPACK PLAYBACK/RECORDING FILE NEW>
//*//             DISP=(NEW,CATLG,DELETE),
//*//             SPACE=(TRK,5),
//*//             DCB=(RECFM=VB,LRECL=32756,BLKSIZE=32760,DSORG=PS)
//*//CEEOPTS  DD *
//*TEST(,,,DBMDT%DMJTA1:*)
//*ENVAR(
//*"EQA_STARTUP_KEY=CC")
