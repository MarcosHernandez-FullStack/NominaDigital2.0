//*  %%INCLIB MBVC.PROD.SYMBOLS %%INCMEM GLOBALES                       00010025
//BGJCFID1 JOB CLASS=J,
//             MSGCLASS=X,
//             MSGLEVEL=1,
//             REGION=0M
//JOBLIB   DD DSN=PEBC.ALTAMIRA.LOADLIB.BATCH,DISP=SHR                  00040026
//         DD DSN=PEBC.ALTAMIRA.LOADLIB.RUTINAS,DISP=SHR
//         DD DSN=LDB2DTDB.SDSNEXIT,DISP=SHR
//         DD DSN=LDB2DTDB.SDSNLOAD,DISP=SHR
//         DD DISP=SHR,DSN=CEE.SCEERUN
//*------- VARIABLES DE PROCESO --------------*                         00144025
//**********************************************************************01392804
//*         FORMARTEO DE DESCARGAS DE TABLAS COMEX                     *01392962
//**********************************************************************01393004
//**********************************************************************01392804
//*         MODIFICACIONES/ACTUALIZACIONES                             *01392962
//**********************************************************************01393004
//* SDADYNA2 09-06-2023  XP62350    DESEMPAQUETAMIENTO Y FORMATEO DE
//*                                 TABLAS CGDTGA00 Y BGDTABO
//*SDADYNA2-I***********************************************************00420000
//* PASO    : BGTL0591                                                 *
//* PGM/UTIL: SORT                                                     *
//* OBJETIVO: DESCARGA TABLA BGDTABO                                   *
//**********************************************************************
//BGFID168 EXEC PGM=ADUUMAIN,COND=(4,LT),
//             PARM='DTDB,BGTL0590,NEW,,MSGLEVEL(1)'
//SYSPRINT DD  SYSOUT=*
//UTPRINT  DD  SYSOUT=*
//SYSOUT   DD  SYSOUT=*
//SYSCNTL  DD  DUMMY
//SYSREC   DD  DSN=PEBC.BGFD.FIX.UNLDYNAM.BGDTABO.D1%%ODATE,
//             DISP=(NEW,CATLG,DELETE),
//             UNIT=3390,BLKSIZE=0,
//             SPACE=(CYL,(800,450),RLSE)
//SYSIN    DD  *
     UNLOAD SHRLEVEL CHANGE
     DIRECT AUTO
     SELECT *                                                           00004705
     FROM  GPBC.BGDTABO
//**********************************************************************
//* PASO    : BGFID162                                                 *
//* PGM/UTIL: SORT                                                     *
//* OBJETIVO: DESEMPAQUETAMIENTO CAMPOS COMPRIMIDOS BGDTABO            *
//**********************************************************************
//BGFID169 EXEC  PGM=ICEMAN,COND=(4,LT)
//SYSOUT   DD SYSOUT=*
//SORTIN   DD DSN=PEBC.BGFD.FIX.UNLDYNAM.BGDTABO.D1%%ODATE,DISP=SHR
//SORTOUT  DD DSN=PEBC.BGFD.FIX.UNLDYNAM.BGDTABO.D2%%ODATE,
//            DISP=(NEW,CATLG,DELETE),UNIT=3390,
//            SPACE=(CYL,(700,350),RLSE),
//            DCB=(RECFM=FB,LRECL=198,BLKSIZE=0,DSORG=PS)
//SYSIN    DD  *
  SORT FIELDS=COPY
  OUTREC FIELDS=(1,03,PD,TO=ZD,LENGTH=5,
                      4,03,PD,TO=ZD,LENGTH=4,
                 7,26,33,3,PD,TO=ZD,LENGTH=5,
                 36,20,56,7,PD,TO=ZD,LENGTH=12,
                       63,5,PD,TO=ZD,LENGTH=08,
                       68,7,PD,TO=ZD,LENGTH=12,
                 75,88,163,5,PD,TO=ZD,LENGTH=09,
                       168,5,PD,TO=ZD,LENGTH=09)
//**********************************************************************
//* PASO    : BGFID162                                                 *
//* PGM/UTIL: SORT                                                     *
//* OBJETIVO: DESEMPAQUETAMIENTO CAMPOS COMPRIMIDOS BGDTABO            *
//**********************************************************************
//BGFID170 EXEC  PGM=ICEMAN,COND=(4,LT)
//SYSOUT   DD SYSOUT=*
//SORTIN   DD DSN=PEBC.BGFD.FIX.UNLDYNAM.BGDTABO.D2%%ODATE,DISP=SHR
//SORTOUT  DD DSN=PEBC.BGFD.FIX.UNLDYN1M.BGDTABO.D3%%ODATE,
//            DISP=(NEW,CATLG,DELETE),UNIT=3390,
//            SPACE=(CYL,(500,250),RLSE),
//            DCB=(RECFM=FB,LRECL=209,BLKSIZE=0,DSORG=PS)
//SYSIN    DD  *
  SORT FIELDS=COPY
  OUTREC FIELDS=(1,05,ZD,EDIT=(STTTTT),SIGNS(+,-),
                 6,04,ZD,EDIT=(STTTT),SIGNS(+,-),10,26,
                36,05,ZD,EDIT=(STTTTT),SIGNS(+,-),41,20,
                61,12,ZD,EDIT=(STTTTTTTTTT.TT),SIGNS(+,-),
                73,08,ZD,EDIT=(STTT.TTTTT),SIGNS(+,-),
                81,12,ZD,EDIT=(STTTTTTTTTT.TT),SIGNS(+,-),93,88,
               181,09,ZD,EDIT=(STTTTTTTTT),SIGNS(+,-),
               190,09,ZD,EDIT=(STTTTTTTTT),SIGNS(+,-))
//**********************************************************************
//* PASO    : BGFID160                                                 *
//* PGM/UTIL: SORT                                                     *
//* OBJETIVO: REEMPLAZA CARACTERES EXTRA¦OS POR ESPACIOS BGDTABO *
//**********************************************************************
//BGFID171 EXEC  PGM=ICEMAN,COND=(4,LT)
//SYSOUT   DD SYSOUT=*
//SORTIN   DD DSN=PEBC.BGFD.FIX.UNLDYN1M.BGDTABO.D3%%ODATE,DISP=SHR
//SORTOUT  DD DSN=PEBC.IL.FIX.DX.UNLDYNAM.BGDTABO.D1%%ODATE,
//            DISP=(NEW,CATLG,DELETE),UNIT=3390,
//            SPACE=(CYL,(500,250),RLSE),
//            DCB=(RECFM=FB,LRECL=209,BLKSIZE=0,DSORG=PS)
//SYSIN    DD  *
  SORT FIELDS=COPY
  OUTREC FINDREP=(INOUT=(X'00',X'40',X'01',X'40',X'02',X'40',
                         X'03',X'40',X'04',X'40',X'05',X'40',
                         X'06',X'40',X'07',X'40',X'08',X'40',
                         X'09',X'40',X'0A',X'40',
                         X'0B',X'40',X'0C',X'40',X'0D',X'40',
                         X'0E',X'40',X'0F',X'40',X'10',X'40',
                         X'11',X'40',X'12',X'40',X'13',X'40',
                         X'14',X'40',X'15',X'40',X'16',X'40',
                         X'17',X'40',X'18',X'40',X'19',X'40',
                         X'1A',X'40',X'1B',X'40',X'1C',X'40',
                         X'1D',X'40',X'1E',X'40',X'1F',X'40',
                         X'20',X'40',X'21',X'40',X'22',X'40',
                         X'23',X'40',X'24',X'40',X'25',X'40',
                         X'26',X'40',X'27',X'40',X'28',X'40',
                         X'29',X'40',X'2A',X'40',X'2B',X'40',
                         X'2C',X'40',X'2D',X'40',X'2E',X'40',
                         X'2F',X'40',X'30',X'40',X'31',X'40',
                         X'32',X'40',X'33',X'40',X'34',X'40',
                         X'35',X'40',X'36',X'40',X'37',X'40',
                         X'38',X'40',X'39',X'40',X'3A',X'40',
                         X'3B',X'40',X'3C',X'40',X'3D',X'40',
                         X'3E',X'40',X'3F',X'40',X'41',X'40',
                         X'FF',X'40'))
//**********************************************************************00420000
//*GENERA ARCHIVO BACKUP DE TABLA CGDTGA00                              00420000
//**********************************************************************00420000
//*BGFID172 EXEC PGM=ADUUMAIN,COND=(4,LT),
//*             PARM='DTDB,CGTHIS90,NEW,,MSGLEVEL(1)'
//*SYSPRINT DD  SYSOUT=*
//*UTPRINT  DD  SYSOUT=*
//*SYSOUT   DD  SYSOUT=*
//*SYSCNTL  DD  DUMMY
//*SYSREC   DD  DSN=PEBC.CGFD.FIX.CGDTGA00.UNLOAD.D1%%ODATE,
//*             DISP=(NEW,CATLG,DELETE),UNIT=3390,
//*             SPACE=(CYL,(400,200),RLSE),
//*             DCB=(LRECL=395,RECFM=FB,BLKSIZE=0,DSORG=PS)
//*SYSIN    DD  *
//*UNLOAD
//*    SHRLEVEL CHANGE CONSISTENT YES XBMID XBM
//*    DIRECT AUTO
//*    FIXEDVARCHAR YES
//*    SELECT *                                                         00004705
//*    FROM  GPBC.CGDTGA00
//*    ORDER BY GA00_PAIS, GA00_PRODUCTO, GA00_CLIENTE, GA00_FECHRECEP,
//*             GA00_FOLIORECEP
//**********************************************************************
//* PASO    : CGFID159                                                 *
//* PGM/UTIL: SORT                                                     *
//* OBJETIVO: DESEMPAQUETACION DE CAMPOS COMPRIMIDOS CGDTGA00          *
//**********************************************************************
//*BGFID173 EXEC  PGM=ICEMAN,COND=(4,LT)
//*SYSOUT   DD SYSOUT=*
//*SORTIN   DD DSN=PEBC.CGFD.FIX.CGDTGA00.UNLOAD.D1%%ODATE,DISP=SHR
//*SORTOUT  DD DSN=PEBC.CGFD.FIX.CGDTGA00.UNLOAD.D2%%ODATE,
//*            DISP=(NEW,CATLG,DELETE),UNIT=3390,
//*            SPACE=(CYL,(400,200),RLSE),
//*            DCB=(RECFM=FB,LRECL=408,BLKSIZE=0,DSORG=PS)
//*SYSIN    DD  *
//*SORT FIELDS=COPY
//*OUTREC FIELDS=(1,24,25,4,PD,TO=ZD,LENGTH=6,
//*                    29,2,PD,TO=ZD,LENGTH=2,
//*              31,20,51,8,PD,TO=ZD,LENGTH=15,
//*                    59,5,PD,TO=ZD,LENGTH=9,64,332)
//**********************************************************************
//* PASO    : CGFID160                                                 *
//* PGM/UTIL: SORT                                                     *
//* OBJETIVO: FORMATEO DE CAMPOS COMPRIMIDOS CGDTGA00          *
//**********************************************************************
//*BGFID174 EXEC  PGM=ICEMAN,COND=(4,LT)
//*SYSOUT   DD SYSOUT=*
//*SORTIN   DD DSN=PEBC.CGFD.FIX.CGDTGA00.UNLOAD.D2%%ODATE,DISP=SHR
//*SORTOUT  DD DSN=PEBC.CGFD.FIX.CGDTGA00.UNL1AD.D3%%ODATE,
//*            DISP=(NEW,CATLG,DELETE),UNIT=3390,
//*            SPACE=(CYL,(400,200),RLSE),
//*            DCB=(RECFM=FB,LRECL=413,BLKSIZE=0,DSORG=PS)
//*SYSIN    DD  *
//*SORT FIELDS=COPY
//*OUTREC FIELDS=(1,24,25,06,ZD,EDIT=(STTTTTT),SIGNS(+,-),
//*                    31,02,ZD,EDIT=(STT),SIGNS(+,-),
//*              33,20,53,15,ZD,EDIT=(STTTTTTTTTTTTT.TT),SIGNS(+,-),
//*                    68,09,ZD,EDIT=(STTTTTTTTT),SIGNS(+,-),77,332)
//**********************************************************************
//* PASO    : BGFID160                                                 *
//* PGM/UTIL: SORT                                                     *
//* OBJETIVO: REEMPLAZA CARACTERES EXTRA¦OS POR ESPACIOS BGDTABO *
//**********************************************************************
//*BGFID175 EXEC  PGM=ICEMAN,COND=(4,LT)
//*SYSOUT   DD SYSOUT=*
//*SORTIN   DD DSN=PEBC.CGFD.FIX.CGDTGA00.UNL1AD.D3%%ODATE,DISP=SHR
//*SORTOUT  DD DSN=PEBC.CGFD.FIX.CGDTGA00.UNLOAD.D3%%ODATE,
//*            DISP=(NEW,CATLG,DELETE),UNIT=3390,
//*            SPACE=(CYL,(500,250),RLSE),
//*            DCB=(RECFM=FB,LRECL=413,BLKSIZE=0,DSORG=PS)
//*SYSIN    DD  *
//*SORT FIELDS=COPY
//*OUTREC FINDREP=(INOUT=(X'00',X'40',X'01',X'40',X'02',X'40',
//*                      X'03',X'40',X'04',X'40',X'05',X'40',
//*                      X'06',X'40',X'07',X'40',X'08',X'40',
//*                      X'09',X'40',X'0A',X'40',
//*                      X'0B',X'40',X'0C',X'40',X'0D',X'40',
//*                      X'0E',X'40',X'0F',X'40',X'10',X'40',
//*                      X'11',X'40',X'12',X'40',X'13',X'40',
//*                      X'14',X'40',X'15',X'40',X'16',X'40',
//*                      X'17',X'40',X'18',X'40',X'19',X'40',
//*                      X'1A',X'40',X'1B',X'40',X'1C',X'40',
//*                      X'1D',X'40',X'1E',X'40',X'1F',X'40',
//*                      X'20',X'40',X'21',X'40',X'22',X'40',
//*                      X'23',X'40',X'24',X'40',X'25',X'40',
//*                      X'26',X'40',X'27',X'40',X'28',X'40',
//*                      X'29',X'40',X'2A',X'40',X'2B',X'40',
//*                      X'2C',X'40',X'2D',X'40',X'2E',X'40',
//*                      X'2F',X'40',X'30',X'40',X'31',X'40',
//*                      X'32',X'40',X'33',X'40',X'34',X'40',
//*                      X'35',X'40',X'36',X'40',X'37',X'40',
//*                      X'38',X'40',X'39',X'40',X'3A',X'40',
//*                      X'3B',X'40',X'3C',X'40',X'3D',X'40',
//*                      X'3E',X'40',X'3F',X'40',X'41',X'40',
//*                      X'FF',X'40'))
//*SDADYNA2-F***********************************************************00420000
