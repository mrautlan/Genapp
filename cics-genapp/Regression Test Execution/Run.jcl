//GENAPLAY  JOB ,NOTIFY=&SYSUID,REGION=0M
//PLAYBK   EXEC PGM=BZUPLAY,PARM='TRACE=N'
//STEPLIB  DD DISP=SHR,DSN=BZU.SBZULOAD
//         DD DISP=SHR,DSN=DMJTA1.LOAD  (GENAPP application)
//BZUPLAY  DD DISP=SHR,DSN= (regression pack name for development)
//*BZUCBK   DD DISP=SHR,DSN=CICSCOB1.CICS.LOAD
//SYSOUT   DD SYSOUT=*       (this keeps LE output in one spool file)
//BZUMSG  DD SYSOUT=*        (optional, can be a VB output dataset)
//*//BZUNEXT   DD  DSN=(regression pack name for development)
//*//             DISP=(NEW,CATLG,DELETE),
//*//             SPACE=(TRK,5),
//*//             DCB=(RECFM=VB,LRECL=32756,BLKSIZE=32760,DSORG=PS)