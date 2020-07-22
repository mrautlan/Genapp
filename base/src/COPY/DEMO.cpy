
       01  WS-FLAG-TSQE              PIC X.
       01  WS-FLAG-TSQH              PIC X.
       01  WS-FLAG-TSQL              PIC X.
       01  WS-FLAG                   PIC X.
       01  WS-RANDOM-Seed            PIC S9(4) Comp.
       01  WS-RANDOM-Number          PIC 9(8) Comp.
       01  WS-RESP                   PIC S9(8) COMP.
       01  WS-STARTCODE              PIC XX Value spaces.
       01  WS-SYSID                  PIC X(4) Value spaces.
       01  WS-Invokeprog             PIC X(8) Value spaces.
       01  WS-COMMAREA               PIC X(80).
       01  WS-RECV.
         03 WS-RECV-TRANID           PIC X(5).
         03 WS-RECV-DATA             PIC X(74).
       01  WS-RECV-LEN               PIC S9(4) COMP Value 80.
      ******************************
       01  READ-MSG.
         03 READ-MSG-MSG             PIC X(80).
       01  FILLER REDEFINES Read-MSG.
         03 FILLER                   PIC X(13).
         03 READ-CUST-LOW            PIC 9(10).
       01  FILLER REDEFINES Read-MSG.
         03 FILLER                   PIC X(14).
         03 READ-CUST-HIGH           PIC 9(10).
      ******************************
       01  WS-Cust-Low               Pic S9(10).
       01  WS-Cust-High              Pic S9(10).
       01  WS-Cust-Number            Pic X(10).
      