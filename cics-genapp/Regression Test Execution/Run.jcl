//GENAPLAY  JOB ,NOTIFY=&SYSUID,REGION=0M
//PLAYBK   EXEC PGM=BZUPLAY,PARM='TRACE=N'
//STEPLIB  DD DISP=SHR,DSN=BZU.SBZULOAD
//         DD DISP=SHR,DSN=<load lib for application + changes>
//BZUPLAY  DD DISP=SHR,DSN=<Regression Pack seq. file>
//SYSOUT   DD SYSOUT=*       (this keeps LE output in one spool file)
//BZUMSG  DD SYSOUT=*        (optional, can be a VB output dataset)
//*
//*   If the change is disruptive, then use DD BZUNEXT to update pack
//*
//*//BZUNEXT   DD  DSN=<Feature Regression Test Pack>
//*//             DISP=(NEW,CATLG,DELETE),
//*//             SPACE=(TRK,5),
//*//             DCB=(RECFM=VB,LRECL=32756,BLKSIZE=32760,DSORG=PS)
