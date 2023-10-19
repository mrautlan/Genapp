       IDENTIFICATION DIVISION.
       PROGRAM-ID. lgacdb01.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY LGPOLICY.
      * THE FOLLOWING VARIABLES ARE USED FROM THE COPYBOOK :
      * PATH : .../Copybooks/LGPOLICY.cpy
      *01 WS-POLICY-LENGTHS.
      *    03 WS-CUSTOMER-LEN PIC S9(4) VALUE 72.
      * PATH : .../CobolPrograms/LGACUS01.cbl
       01 DFHCOMMAREA.
           COPY LGCMAREA.
      * THE FOLLOWING VARIABLES ARE USED FROM THE COPYBOOK :
      * PATH : .../PublicCopybooks/LGCMAREA.cpy
      *    03 CA-REQUEST-ID PIC X(6).
      *    03 CA-RETURN-CODE PIC 9(2).
      *    03 CA-CUSTOMER-NUM PIC 9(10).
      *    03 CA-CUSTOMER-REQUEST.
      *       05 CA-PHONE-MOBILE PIC X(20).
      *       05 CA-PHONE-HOME PIC X(20).
      *       05 CA-EMAIL-ADDRESS PIC X(100).
      *       05 CA-FIRST-NAME PIC X(10).
      *       05 CA-LAST-NAME PIC X(20).
      *       05 CA-DOB PIC X(10).
      *       05 CA-HOUSE-NAME PIC X(20).
      *       05 CA-HOUSE-NUM PIC X(4).
      *       05 CA-POSTCODE PIC X(8).
      * PATH : .../CobolPrograms/LGACUS01.cbl
       01 CA-ERROR-MSG.
           03 CA-DATA PIC X(90) VALUE SPACES.
       01 WS-RESP PIC S9(8).
       01 LastCustNum PIC S9(8).
       01 DB2-OUT-INTEGERS.
           03 DB2-CUSTOMERNUM-INT PIC S9(9).
       01 GENAcount PIC X(16) VALUE 'GENACUSTNUM'.
       77 LGACDB02 PIC X(8) VALUE 'LGACDB02'.
       01 GENApool PIC X(8) VALUE 'GENA'.
       77 LGACVS01 PIC X(8) VALUE 'LGACVS01'.
       01 WS-ABSTIME PIC S9(8) VALUE 0.
       77 LGAC-NCS PIC X(2) VALUE 'ON'.
       01 WS-TIME PIC X(8) VALUE SPACES.
       01 WS-DATE PIC X(10) VALUE SPACES.
       01 ERROR-MSG.
           03 EM-TIME PIC X(6) VALUE SPACES.
           03 EM-VARIABLE.
             05 EM-SQLREQ PIC X(16) VALUE SPACES.
           03 EM-DATE PIC X(8) VALUE SPACES.
       01 WS-COMMAREA-LENGTHS.
           03 WS-CA-HEADER-LEN PIC S9(4) VALUE 18.
           03 WS-REQUIRED-CA-LEN PIC S9(4) VALUE 0.
       01 CDB2AREA.
           03 D2-CUSTSECR-COUNT PIC X(4).
           03 D2-CUSTSECR-STATE PIC X.
           03 D2-REQUEST-ID PIC X(6).
           03 D2-CUSTOMER-NUM PIC 9(10).
           03 D2-CUSTSECR-PASS PIC X(32).
        01 WS-HEADER.
           03 WS-TRANSID PIC X(4).
           03 WS-TERMID PIC X(4).
           03 WS-TASKNUM PIC 9(7).
           03 WS-ADDR-DFHCOMMAREA.
           03 WS-CALEN PIC S9(4).
           EXEC SQL
               INCLUDE SQLCA
           END-EXEC.
      * THE FOLLOWING VARIABLES ARE USED FROM THE COPYBOOK :
      * PATH : .../Shared/SQLCA
      * 01 SQLCA.
      *     05 SQLCODE PIC S9(9).

       LINKAGE SECTION.

       PROCEDURE DIVISION.
      ******************************************************************
      * PROGRAM NAME : Program:COBOL:LGACUS01
      * PROGRAM PATH : .../Cobol Programs/LGACUS01.cbl
      * STMT START LINE NUMBER : 194
      * STMT END LINE NUMBER : 197
           WHEN ACTION-CODE = '1'
      * Call routine to Insert row in DB2 Customer table
                MOVE '01ICUST' TO CA-REQUEST-ID
                PERFORM ONBOARD-CUSTOMER
      ******************************************************************
      * PROGRAM NAME : Program:COBOL:LGACUS01
      * PROGRAM PATH : .../Cobol Programs/LGACUS01.cbl
      * STMT START LINE NUMBER : 228
      * STMT END LINE NUMBER : 297
      * TODO : CHECK IF THE PROGRAM CALL IS VALID
       ONBOARD-CUSTOMER.


      *----------------------------------------------------------------*
      * Common code                                                    *
      *----------------------------------------------------------------*
      * initialize working storage variables
           INITIALIZE WS-HEADER.
      * set up general variable
           MOVE EIBTRNID TO WS-TRANSID.
           MOVE EIBTRMID TO WS-TERMID.
           MOVE EIBTASKN TO WS-TASKNUM.
      *----------------------------------------------------------------*


      * initialize DB2 host variables
           INITIALIZE DB2-OUT-INTEGERS.

      *----------------------------------------------------------------*
      * Process incoming commarea                                      *
      *----------------------------------------------------------------*
      * If NO commarea received issue an ABEND
           IF EIBCALEN IS EQUAL TO ZERO
               MOVE ' NO COMMAREA RECEIVED' TO EM-VARIABLE
               PERFORM WRITE-ERROR-MESSAGE
               EXEC CICS ABEND ABCODE('LGCA') NODUMP END-EXEC
           END-IF

      * initialize commarea return code to zero
           MOVE '00' TO CA-RETURN-CODE
           MOVE EIBCALEN TO WS-CALEN.
           SET WS-ADDR-DFHCOMMAREA TO ADDRESS OF DFHCOMMAREA.

      * check commarea length
           ADD WS-CA-HEADER-LEN TO WS-REQUIRED-CA-LEN
           ADD WS-CUSTOMER-LEN  TO WS-REQUIRED-CA-LEN

      * if less set error return code and return to caller
           IF EIBCALEN IS LESS THAN WS-REQUIRED-CA-LEN
             MOVE '98' TO CA-RETURN-CODE
      * TODO : CHECK THE FOLLOWING <CONTINUE/NEXT SENTENCE/GO TO/GO BACK
      *    /RETURN/STOP RUN/EXIT/EXIT PROGRAM> STATEMENT
             EXEC CICS RETURN END-EXEC
           END-IF

      * Call routine to Insert row in Customer table                   *
           PERFORM OBTAIN-CUSTOMER-NUMBER.
           PERFORM INSERT-CUSTOMER.

           EXEC CICS LINK Program(LGACVS01)
                Commarea(DFHCOMMAREA)
                LENGTH(225)
           END-EXEC.

           MOVE DB2-CUSTOMERNUM-INT TO D2-CUSTOMER-NUM.
           Move '02ACUS'     To  D2-REQUEST-ID.
           move '5732fec825535eeafb8fac50fee3a8aa'
                             To  D2-CUSTSECR-PASS.
           Move '0000'       To  D2-CUSTSECR-COUNT.
           Move 'N'          To  D2-CUSTSECR-STATE.

           EXEC CICS LINK Program(LGACDB02)
                Commarea(CDB2AREA)
                LENGTH(32500)
           END-EXEC.

           IF CA-RETURN-CODE NOT EQUAL 0
      * TODO : CHECK THE FOLLOWING <CONTINUE/NEXT SENTENCE/GO TO/GO BACK
      *    /RETURN/STOP RUN/EXIT/EXIT PROGRAM> STATEMENT
             EXEC CICS RETURN END-EXEC
           END-IF


      * TODO : CHECK THE FOLLOWING <CONTINUE/NEXT SENTENCE/GO TO/GO BACK
      *    /RETURN/STOP RUN/EXIT/EXIT PROGRAM> STATEMENT
           EXIT.
      ******************************************************************
      * PROGRAM NAME : Program:COBOL:LGACUS01
      * PROGRAM PATH : .../Cobol Programs/LGACUS01.cbl
      * STMT START LINE NUMBER : 303
      * STMT END LINE NUMBER : 316
       OBTAIN-CUSTOMER-NUMBER.

           Exec CICS Get Counter(GENAcount)
                         Pool(GENApool)
                         Value(LastCustNum)
                         Resp(WS-RESP)
           End-Exec.
           If WS-RESP Not = DFHRESP(NORMAL)
             MOVE 'NO' TO LGAC-NCS
             Initialize DB2-CUSTOMERNUM-INT
           ELSE
             Move LastCustNum  To DB2-CUSTOMERNUM-INT
           End-If.
      * TODO : CHECK THE FOLLOWING <CONTINUE/NEXT SENTENCE/GO TO/GO BACK
      *    /RETURN/STOP RUN/EXIT/EXIT PROGRAM> STATEMENT
           EXIT.
      ******************************************************************
      * PROGRAM NAME : Program:COBOL:LGACUS01
      * PROGRAM PATH : .../Cobol Programs/LGACUS01.cbl
      * STMT START LINE NUMBER : 319
      * STMT END LINE NUMBER : 391
       INSERT-CUSTOMER.
      *================================================================*
      * Insert row into Customer table based on customer number        *
      *================================================================*
           MOVE ' INSERT CUSTOMER' TO EM-SQLREQ
      *================================================================*
           IF LGAC-NCS = 'ON'
             EXEC SQL
               INSERT INTO CUSTOMER
                         ( CUSTOMERNUMBER,
                           FIRSTNAME,
                           LASTNAME,
                           DATEOFBIRTH,
                           HOUSENAME,
                           HOUSENUMBER,
                           POSTCODE,
                           PHONEMOBILE,
                           PHONEHOME,
                           EMAILADDRESS )
                  VALUES ( :DB2-CUSTOMERNUM-INT,
                           :CA-FIRST-NAME,
                           :CA-LAST-NAME,
                           :CA-DOB,
                           :CA-HOUSE-NAME,
                           :CA-HOUSE-NUM,
                           :CA-POSTCODE,
                           :CA-PHONE-MOBILE,
                           :CA-PHONE-HOME,
                           :CA-EMAIL-ADDRESS )
             END-EXEC
             IF SQLCODE NOT EQUAL 0
               MOVE '90' TO CA-RETURN-CODE
               PERFORM WRITE-ERROR-MESSAGE
      * TODO : CHECK THE FOLLOWING <CONTINUE/NEXT SENTENCE/GO TO/GO BACK
      *    /RETURN/STOP RUN/EXIT/EXIT PROGRAM> STATEMENT
               EXEC CICS RETURN END-EXEC
             END-IF
           ELSE
             EXEC SQL
               INSERT INTO CUSTOMER
                         ( CUSTOMERNUMBER,
                           FIRSTNAME,
                           LASTNAME,
                           DATEOFBIRTH,
                           HOUSENAME,
                           HOUSENUMBER,
                           POSTCODE,
                           PHONEMOBILE,
                           PHONEHOME,
                           EMAILADDRESS )
                  VALUES ( DEFAULT,
                           :CA-FIRST-NAME,
                           :CA-LAST-NAME,
                           :CA-DOB,
                           :CA-HOUSE-NAME,
                           :CA-HOUSE-NUM,
                           :CA-POSTCODE,
                           :CA-PHONE-MOBILE,
                           :CA-PHONE-HOME,
                           :CA-EMAIL-ADDRESS )
             END-EXEC
             IF SQLCODE NOT EQUAL 0
               MOVE '90' TO CA-RETURN-CODE
               PERFORM WRITE-ERROR-MESSAGE
      * TODO : CHECK THE FOLLOWING <CONTINUE/NEXT SENTENCE/GO TO/GO BACK
      *    /RETURN/STOP RUN/EXIT/EXIT PROGRAM> STATEMENT
               EXEC CICS RETURN END-EXEC
             END-IF
      *    get value of assigned customer number
               EXEC SQL
                 SET :DB2-CUSTOMERNUM-INT = IDENTITY_VAL_LOCAL()
               END-EXEC
           END-IF.

           MOVE DB2-CUSTOMERNUM-INT TO CA-CUSTOMER-NUM.

      * TODO : CHECK THE FOLLOWING <CONTINUE/NEXT SENTENCE/GO TO/GO BACK
      *    /RETURN/STOP RUN/EXIT/EXIT PROGRAM> STATEMENT
           EXIT.
      ******************************************************************
      * PROGRAM NAME : Program:COBOL:LGACUS01
      * PROGRAM PATH : .../Cobol Programs/LGACUS01.cbl
      * STMT START LINE NUMBER : 582
      * STMT END LINE NUMBER : 614
      * TODO : CHECK IF THE PROGRAM CALL IS VALID
       WRITE-ERROR-MESSAGE.
      * Save SQLCODE in message
      * Obtain and format current time and date
           EXEC CICS ASKTIME ABSTIME(WS-ABSTIME)
           END-EXEC
           EXEC CICS FORMATTIME ABSTIME(WS-ABSTIME)
                     MMDDYYYY(WS-DATE)
                     TIME(WS-TIME)
           END-EXEC
           MOVE WS-DATE TO EM-DATE
           MOVE WS-TIME TO EM-TIME
      * Write output message to TDQ
           EXEC CICS LINK PROGRAM('LGSTSQ')
                     COMMAREA(ERROR-MSG)
                     LENGTH(LENGTH OF ERROR-MSG)
           END-EXEC.
      * Write 90 bytes or as much as we have of commarea to TDQ
           IF EIBCALEN > 0 THEN
             IF EIBCALEN < 91 THEN
               MOVE DFHCOMMAREA(1:EIBCALEN) TO CA-DATA
               EXEC CICS LINK PROGRAM('LGSTSQ')
                         COMMAREA(CA-ERROR-MSG)
                         LENGTH(LENGTH OF CA-ERROR-MSG)
               END-EXEC
             ELSE
               MOVE DFHCOMMAREA(1:90) TO CA-DATA
               EXEC CICS LINK PROGRAM('LGSTSQ')
                         COMMAREA(CA-ERROR-MSG)
                         LENGTH(LENGTH OF CA-ERROR-MSG)
               END-EXEC
             END-IF
           END-IF.
      * TODO : CHECK THE FOLLOWING <CONTINUE/NEXT SENTENCE/GO TO/GO BACK
      *    /RETURN/STOP RUN/EXIT/EXIT PROGRAM> STATEMENT
           EXIT.
      ******************************************************************
           EXIT PROGRAM.
