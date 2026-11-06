//*  %%INCLIB MBVD.PROD.SYMBOLS %%INCMEM GLOBALES
//BGJDNDG2 JOB CLASS=J,
//             MSGCLASS=X,
//             MSGLEVEL=1,
//             REGION=0M
//JOBLIB   DD DSN=PEBD.ALTAMIRA.LOADLIB.BATCH,DISP=SHR
//         DD DSN=PEBD.ALTAMIRA.LOADLIB.RUTINAS,DISP=SHR
//         DD DSN=LDB2DTDB.SDSNEXIT,DISP=SHR
//         DD DSN=LDB2DTDB.SDSNLOAD,DISP=SHR
//         DD DISP=SHR,DSN=CEE.SCEERUN
//*------- VARIABLES DE PROCESO --------------*
//**********************************************************************
//*         REPORTE DE PREAPERTURAS FORMALIZADAS DE BGDTAPE            *
//*         PRODUCTO 02 / SUBPRODUCTO 0046-0047 - CSV SEPARADO POR ;   *
//**********************************************************************
//**********************************************************************
//*         MODIFICACIONES/ACTUALIZACIONES                             *
//**********************************************************************
//* XXXXXXXX 03-11-2026  XXXXXXX    CREACION DEL JOB. REPORTE CSV DE
//*                                 BGDTAPE PARA NOMINA DIGITAL 2.0
//**********************************************************************
//* PASO    : BGNDG010                                                 *
//* PGM/UTIL: IDCAMS                                                   *
//* OBJETIVO: BORRA EL REPORTE DEL DIA SI EXISTE (PERMITE RELANZAR)    *
//**********************************************************************
//BGNDG010 EXEC PGM=IDCAMS
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
  DELETE PEBD.BGFD.FIX.DX.BGDTAPE.UNLDIA1.D1%%ODATE NONVSAM PURGE
  IF LASTCC = 8 THEN SET MAXCC = 0
//**********************************************************************
//* PASO    : BGNDG020                                                 *
//* PGM/UTIL: ADUUMAIN (BMC UNLOAD PLUS)                               *
//* OBJETIVO: EJECUTA SEL_BGDTAPE Y ARMA CADA FILA COMO LINEA CSV (;)  *
//*           LA QUERY ORIGINAL VA COMO SUBCONSULTA X; ORDER OF X      *
//*           CONSERVA EL ORDEN DE SU ORDER BY.                        *
//*           TRAE LA FOTO COMPLETA. PARA TRAER SOLO LO FORMALIZADO EN *
//*           LA FECHA DE PROCESO, QUITAR EL -- DE LA LINEA DEL FILTRO *
//*           APE_FECHA_FORMAL.                                        *
//**********************************************************************
//BGNDG020 EXEC PGM=ADUUMAIN,COND=(4,LT),
//             PARM='DTDB,BGJDNDG2,NEW,,MSGLEVEL(1)'
//SYSPRINT DD  SYSOUT=*
//UTPRINT  DD  SYSOUT=*
//SYSOUT   DD  SYSOUT=*
//SYSCNTL  DD  DUMMY
//SYSREC   DD  DSN=&&BGDTAPE,
//             DISP=(NEW,PASS,DELETE),
//             UNIT=3390,
//             SPACE=(CYL,(10,10),RLSE)
//SYSIN    DD  *
     UNLOAD SHRLEVEL CHANGE
     DIRECT NO
     SELECT CAST(
                   COALESCE(CHAR(X.FECHA_FORMAL, ISO), '')
            CONCAT ';' CONCAT COALESCE(CHAR(X.FECHA_APE, ISO), '')
            CONCAT ';' CONCAT COALESCE(RTRIM(X.NRO_CUENTA), '')
            CONCAT ';' CONCAT COALESCE(RTRIM(X.DIVISA), '')
            CONCAT ';' CONCAT COALESCE(RTRIM(REPLACE(X.CONCEPTO,
                                                     ';', ' ')), '')
            CONCAT ';' CONCAT COALESCE(RTRIM(X.CENTRO_UMO), '')
            CONCAT ';' CONCAT COALESCE(RTRIM(REPLACE(X.NOMBRE_OFICINA,
                                                     ';', ' ')), '')
            CONCAT ';' CONCAT COALESCE(RTRIM(X.USERID_UMO), '')
            CONCAT ';' CONCAT COALESCE(RTRIM(X.NETNAME_UMO), '')
            CONCAT ';' CONCAT COALESCE(X.CANAL_DESC, '')
            CONCAT ';' CONCAT COALESCE(X.TIMEST, '')
            AS CHAR(171)) AS LINEA
     FROM (
     SELECT
      TAPE.APE_FECHA_FORMAL AS FECHA_FORMAL,
      TAPE.APE_FECHA_APE AS FECHA_APE,
      TAPE.APE_ENTIDAD CONCAT TAPE.APE_CENTRO_ALTA
      CONCAT TAPE.APE_DIGICCC1 CONCAT TAPE.APE_DIGICCC2
      CONCAT TAPE.APE_CUENTA AS NRO_CUENTA,
      TAPE.APE_DIVISA AS DIVISA,
      TAPE.APE_CONCEPTO AS CONCEPTO,
      TAPE.APE_CENTRO_UMO AS CENTRO_UMO,
      TCDT.TCMOFCUR AS NOMBRE_OFICINA,
      TAPE.APE_USERID_UMO AS USERID_UMO,
      TAPE.APE_NETNAME_UMO AS NETNAME_UMO,
      CASE
           WHEN TAPE.APE_USERID_UMO = 'BG7CAPEU'
                THEN 'NOMINA DIGITAL 2.0'
           WHEN TAPE.APE_USERID_UMO = 'ZG13003'
                THEN 'NOMINA DIGITAL 1.0'
           ELSE 'RED DE OFICINAS'
      END AS CANAL_DESC,
      VARCHAR_FORMAT(TAPE.APE_TIMEST_UMO, 'YYYY-MM-DD HH24:MI:SS')
                                                          AS TIMEST
     FROM GPBD.BGDTAPE TAPE
     LEFT JOIN GPBD.TCDT050 TCDT
            ON TAPE.APE_CENTRO_UMO=TCDT.TCCOFICI
     WHERE TAPE.APE_PRODUCTO = '02'
     AND TAPE.APE_SUBPRODU IN ('0046', '0047')
     AND TAPE.APE_IND_SITU='F'
--   AND TAPE.APE_FECHA_FORMAL = DATE(TO_DATE('%%$ODATE', 'YYYYMMDD'))
     ORDER BY TAPE.APE_FECHA_FORMAL, TAPE.APE_FECHA_APE,
              NRO_CUENTA, TIMEST
     ) X
     ORDER BY ORDER OF X
//**********************************************************************
//* PASO    : BGNDG030                                                 *
//* PGM/UTIL: SORT                                                     *
//* OBJETIVO: REEMPLAZA CARACTERES NO IMPRIMIBLES POR ESPACIOS, AGREGA *
//*           LA CABECERA Y GRABA EL REPORTE DEL DIA                   *
//**********************************************************************
//BGNDG030 EXEC  PGM=ICEMAN,COND=(4,LT)
//SYSOUT   DD SYSOUT=*
//SORTIN   DD DSN=&&BGDTAPE,DISP=(OLD,DELETE,DELETE)
//SORTOUT  DD DSN=PEBD.BGFD.FIX.DX.BGDTAPE.UNLDIA1.D1%%ODATE,
//            DISP=(NEW,CATLG,DELETE),UNIT=3390,
//            SPACE=(CYL,(10,10),RLSE),
//            DCB=(RECFM=FB,LRECL=171,BLKSIZE=0,DSORG=PS)
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
  OUTFIL FNAMES=SORTOUT,REMOVECC,
         HEADER1=(C'FECHA_FORMAL;FECHA_APE;NRO_CUENTA;DIVISA;',
                  C'CONCEPTO;CENTRO_UMO;NOMBRE_OFICINA;USERID_UMO;',
                  C'NETNAME_UMO;CANAL_DESC;TIMEST')
