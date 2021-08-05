//VTPVIEW JOB ,
// MSGCLASS=H,MSGLEVEL=(1,1),TIME=(,4),REGION=144M,COND=(16,LT)
//*//***************************************************************
//*//***************************************************************
//* Covert into format for VTP Viewer
//***************************************************************
//CPYJSON EXEC PGM=BZUPLAY,COND=(4,LT),REGION=0M,
// PARM='RUN=BZURCP'
//STEPLIB  DD DISP=SHR,DSN=BZU.SBZULOAD      Test Runner common
//BZUMETA DD DISP=SHR,DSN=<USERID>.FEATURE.METAT1
//BZUJSON DD PATH='/u/<USERID>/vtp/R&TESTNAME..vtptc',
//           PATHDISP=(KEEP,DELETE),
//           PATHOPTS=(OCREAT,ORDWR),
//           PATHMODE=(SIRUSR,SIWUSR),
//           FILEDATA=TEXT
//BZUMSG  DD SYSOUT=*
