//VTPVIEW JOB ,
// MSGCLASS=H,MSGLEVEL=(1,1),TIME=(,4),REGION=144M,COND=(16,LT)
//*//***************************************************************
//*//* JOB TO EXTRACT A RECORDED PLAYBACK FILE IN JSON FORMAT
//*//*//***************************************************************
//*// SET DSNPLBC=DMJTA1.FEATURE.VIEW.ZPROJ100
//*// SET DSNSRC=DMJTA1.FEATURE.ZPROJ100
//*//*//***************************************************************
//*//*//* TESTCASE NAME
//*//*//***************************************************************
// SET TESTNAME=GENAPPF
//***************************************************************
//* COPY THE JSON
//***************************************************************
//CPYJSON EXEC PGM=BZUPLAY,
// PARM='RUN=BZURCP'
//STEPLIB  DD DISP=SHR,DSN=BZU.SBZULOAD      Test Runner common
//         DD DISP=SHR,DSN=BZU.SBZULMOD      Test Runner replay
//         DD DISP=SHR,DSN=BZU.SBZULLEP      Test Runner replay
//         DD DISP=SHR,DSN=DMJTA1.LOAD
//BZUMETA DD DISP=SHR,DSN=DMJTA1.FEATURE.META11
//BZUJSON DD PATH='/u/DMJTA1/vtp/&TESTNAME..vtptc',
//           PATHDISP=(KEEP,DELETE),
//           PATHOPTS=(OCREAT,ORDWR),
//           PATHMODE=(SIRUSR,SIWUSR),
//           FILEDATA=TEXT
//BZUMSG  DD SYSOUT=*
