//*  %%INCLIB MBVP.PROD.SYMBOLS %%INCMEM GLOBALES
//BGJPNDG5 JOB (EEBG,1),'BG',
//             CLASS=C,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             REGION=0M
//JOBLIB   DD DSN=PEBP.ALTAMIRA.LOADLIB.BATCH,DISP=SHR
//         DD DSN=PEBP.ALTAMIRA.LOADLIB.RUTINAS,DISP=SHR
//         DD DSN=LDB2DPPA.SDSNEXIT,DISP=SHR
//         DD DSN=LDB2DPPA.SDSNLOAD,DISP=SHR
//         DD DSN=CEE.SCEERUN,DISP=SHR
//* ================================================================== *
//*  DESCRIPCION : REPORTE CSV DE PREAPERTURAS FORMALIZADAS DE BGDTAPE *
//*                (PRODUCTO 02 / SUBPRODUCTO 0046-0047). EL NOMBRE DE *
//*                LA OFICINA SALE DE LA DESCARGA DE TCDT052           *
//*--------------------------------------------------------------------*
//*                                                                    *
//*  SISTEMA     : BG                                                  *
//*  TABLA       : BGDTAPE / TCDT052                                   *
//*  JOB         : BGJPNDG5                                            *
//*  PROCESO     : DIARIO                                              *
//*  RESPONSABLE : BBVA                                                *
//*  FECHA       : 16 11 2026                                          *
//* ================================================================== *
//*--------------------------------------------------------------------*
//**********************************************************************
//*             L O G   D E   M O D I F I C A C I O N E S              *
//*--------------------------------------------------------------------*
//*   MARCA   AUTOR    FECHA   DESCRIPCION                             *
//*   ------  ------  -------  -------------------------------------   *
//* SDA-54046  XP79253 16-11-26 CREACION                               *
//*                                                                    *
//*--------------------------------------------------------------------*
//* DEFINICION DE VARIABLES
//* FECHAD = ODATE - 1 DIA EN AAAA-MM-DD. EL JOB CORRE EN LA MADRUGADA
//* Y TRAE LO FORMALIZADO EL DIA ANTERIOR
//* %%SET %%FECANT = %%$CALCDTE %%$ODATE -1
//* %%SET %%AAAA = %%SUBSTR %%FECANT 1 4
//* %%SET %%MM = %%SUBSTR %%FECANT 5 2
//* %%SET %%DD = %%SUBSTR %%FECANT 7 2
//* %%SET %%FECHAD = %%AAAA-%%MM-%%DD
//*--------------------------------------------------------------------*
//* PASO    : BGNDG010                                                 *
//* PGM/UTIL: IDCAMS                                                   *
//* OBJETIVO: BORRA LOS ARCHIVOS DEL DIA SI EXISTEN (PERMITE RELANZAR) *
//*           SI ALGUNO NO EXISTE (RC 8) DEJA EL MAXCC EN 0            *
//*--------------------------------------------------------------------*
//BGNDG010 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE PEBP.BGFD.FIX.BGJPNDG5.BGDTAPE.D0%%ODATE NONVSAM PURGE
  DELETE PEBP.BGFD.FIX.BGJPNDG5.TCDT052M.D1%%ODATE NONVSAM PURGE
  DELETE PEBP.BGFD.FIX.DX.BGDTAPE.UNLDIA1.D1%%ODATE NONVSAM PURGE
  IF MAXCC <= 8 THEN SET MAXCC = 0
//*--------------------------------------------------------------------*
//* PASO    : BGNDG020                                                 *
//* PGM/UTIL: ADUUMAIN (BMC UNLOAD PLUS)                               *
//* OBJETIVO: DESCARGA EN CRUDO LAS PREAPERTURAS FORMALIZADAS DE       *
//*           BGDTAPE. TRAE LA FOTO COMPLETA; PARA TRAER SOLO LO       *
//*           FORMALIZADO EL DIA ANTERIOR AL ODATE, QUITAR EL -- DEL   *
//*           FILTRO FECHAD.                                           *
//*           LAYOUT DE SALIDA (LRECL 134):                            *
//*           001-10 APE_FECHA_FORMAL     011-10 APE_FECHA_APE         *
//*           021-04 APE_ENTIDAD          025-04 APE_CENTRO_ALTA       *
//*           029-01 APE_DIGICCC1         030-01 APE_DIGICCC2          *
//*           031-10 APE_CUENTA           041-04 APE_DIVISA            *
//*           045-40 APE_CONCEPTO         085-04 APE_CENTRO_UMO        *
//*           089-08 APE_USERID_UMO       097-08 APE_NETNAME_UMO       *
//*           105-26 APE_TIMEST_UMO       131-04 APE_ENTIDAD_UMO       *
//*--------------------------------------------------------------------*
//BGNDG020 EXEC PGM=ADUUMAIN,COND=(4,LT),
//             PARM='DSNP,BGJPNDG5,NEW,,MSGLEVEL(1)'
//STEPLIB  DD DSN=BMC.DB2.LOAD,DISP=SHR
//         DD DSN=LDB2DPPA.SDSNEXIT,DISP=SHR
//         DD DSN=LDB2DPPA.SDSNLOAD,DISP=SHR
//SYSPRINT DD SYSOUT=*
//UTPRINT  DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSCNTL  DD SYSOUT=*
//SYSREC   DD DSN=PEBP.BGFD.FIX.BGJPNDG5.BGDTAPE.D0%%ODATE,
//            UNIT=3390,BLKSIZE=0,
//            SPACE=(CYL,(400,200),RLSE),
//            DISP=(NEW,CATLG,DELETE)
//SYSIN    DD *
  UNLOAD SHRLEVEL CHANGE
  FIXEDVARCHAR YES
  DIRECT AUTO
  SELECT APE_FECHA_FORMAL, APE_FECHA_APE,
         APE_ENTIDAD,APE_CENTRO_ALTA,APE_DIGICCC1,APE_DIGICCC2,
         APE_CUENTA, APE_DIVISA,APE_CONCEPTO,APE_CENTRO_UMO,
         APE_USERID_UMO, APE_NETNAME_UMO,APE_TIMEST_UMO,
         APE_ENTIDAD_UMO
  FROM MBVP.BGDTAPE
  WHERE APE_PRODUCTO = '02'
     AND APE_SUBPRODU IN ('0046', '0047')
--   AND APE_FECHA_FORMAL ='%%FECHAD'
     AND APE_IND_SITU='F';
//*--------------------------------------------------------------------*
//* PASO    : BGNDG030                                                 *
//* PGM/UTIL: ICEMAN                                                   *
//* OBJETIVO: OBTIENE CAMPOS DE LA DESCARGA DE TCDT052 (LRECL 46)      *
//*           001-03 TCCENTIT ENTIDAD (EMPAQUETADO)                    *
//*           004-03 TCCOFICI OFICINA (EMPAQUETADO)                    *
//*           007-40 TCMOFICI DESCRIPCION OFICINA                      *
//*--------------------------------------------------------------------*
//BGNDG030 EXEC PGM=ICEMAN,COND=(4,LT)
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SORTIN   DD DSN=PEBP.TC.FIX.TCDT052M.D1%%ODATE,DISP=SHR
//SORTOUT  DD DSN=PEBP.BGFD.FIX.BGJPNDG5.TCDT052M.D1%%ODATE,
//            DISP=(NEW,CATLG,DELETE),UNIT=3390,
//            SPACE=(CYL,(800,400),RLSE),
//            DCB=(RECFM=FB,LRECL=46,BLKSIZE=0,DSORG=PS)
//SYSIN    DD *
  SORT FIELDS=COPY
  OUTREC FIELDS=(01,03,04,03,07,40)
//*--------------------------------------------------------------------*
//* PASO    : BGNDG040                                                 *
//* PGM/UTIL: ICEMAN (JOINKEYS)                                        *
//* OBJETIVO: CRUZA BGDTAPE CON TCDT052 POR ENTIDAD Y OFICINA (COMO UN *
//*           LEFT JOIN: SIN CRUCE, LA OFICINA SALE VACIA), ARMA EL    *
//*           CANAL, ORDENA Y GRABA EL REPORTE CSV SEPARADO POR ;      *
//*           CON CABECERA.                                            *
//*           REGISTRO DEL CRUCE: 001-134 BGDTAPE, 135-40 TCMOFICI,    *
//*           175-18 CANAL_DESC                                        *
//*--------------------------------------------------------------------*
//BGNDG040 EXEC PGM=ICEMAN,COND=(4,LT)
//SYSOUT   DD SYSOUT=*
//SORTJNF1 DD DSN=PEBP.BGFD.FIX.BGJPNDG5.BGDTAPE.D0%%ODATE,DISP=SHR
//SORTJNF2 DD DSN=PEBP.BGFD.FIX.BGJPNDG5.TCDT052M.D1%%ODATE,DISP=SHR
//SORTOUT  DD DSN=PEBP.BGFD.FIX.DX.BGDTAPE.UNLDIA1.D1%%ODATE,
//            DISP=(NEW,CATLG,DELETE),UNIT=3390,
//            SPACE=(CYL,(10,10),RLSE),
//            DCB=(RECFM=FB,LRECL=191,BLKSIZE=0,DSORG=PS)
//JNF2CNTL DD *
* ENTIDAD Y OFICINA EMPAQUETADAS A TEXTO DE 4 DIGITOS (0011, 0486)
  INREC BUILD=(1,3,PD,EDIT=(TTTT),4,3,PD,EDIT=(TTTT),7,40)
//SYSIN    DD *
* CRUCE: BGDTAPE (ENTIDAD_UMO + CENTRO_UMO) CON TCDT052 (ENTIDAD +
* OFICINA). LAS FILAS DE BGDTAPE SIN CRUCE TAMBIEN SALEN.
  JOINKEYS FILE=F1,FIELDS=(131,4,A,85,4,A)
  JOINKEYS FILE=F2,FIELDS=(1,4,A,5,4,A)
  JOIN UNPAIRED,F1
  REFORMAT FIELDS=(F1:1,134,F2:9,40)
* REEMPLAZA NO IMPRIMIBLES, ; Y " POR ESPACIOS Y ARMA EL CANAL
  INREC IFTHEN=(WHEN=INIT,
         FINDREP=(INOUT=(X'00',X'40',X'01',X'40',X'02',X'40',
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
                         X'FF',X'40',C';',C' ',C'"',C' '))),
        IFTHEN=(WHEN=INIT,OVERLAY=(175:C'RED DE OFICINAS   ')),
        IFTHEN=(WHEN=(89,8,CH,EQ,C'BG7CAPEU'),
         OVERLAY=(175:C'NOMINA DIGITAL 2.0')),
        IFTHEN=(WHEN=(89,8,CH,EQ,C'ZG13003 '),
         OVERLAY=(175:C'NOMINA DIGITAL 1.0'))
* ORDEN: FECHA_FORMAL, FECHA_APE, NRO_CUENTA, TIMEST
  SORT FIELDS=(1,10,CH,A,11,10,CH,A,21,20,CH,A,105,26,CH,A)
* ARMA LA LINEA CON CADA CAMPO ENTRE " PARA QUE SQZ SOLO QUITE LOS
* BLANCOS DE RELLENO Y NO LOS DE ADENTRO; LUEGO QUITA LAS ".
* TIMEST: AAAA-MM-DD-HH.MM.SS.NNNNNN -> AAAA-MM-DD HH:MM:SS
  OUTREC IFTHEN=(WHEN=INIT,
         BUILD=(C'"',1,10,C'";"',11,10,C'";"',21,20,C'";',
          41,4,JFY=(SHIFT=LEFT,LEAD=C'"',TRAIL=C'";',LENGTH=7),
          45,40,JFY=(SHIFT=LEFT,LEAD=C'"',TRAIL=C'";',LENGTH=43),
          C'"',85,4,C'";',
          135,40,JFY=(SHIFT=LEFT,LEAD=C'"',TRAIL=C'";',LENGTH=43),
          89,8,JFY=(SHIFT=LEFT,LEAD=C'"',TRAIL=C'";',LENGTH=11),
          97,8,JFY=(SHIFT=LEFT,LEAD=C'"',TRAIL=C'";',LENGTH=11),
          175,18,JFY=(SHIFT=LEFT,LEAD=C'"',TRAIL=C'";',LENGTH=21),
          C'"',105,10,C' ',116,2,C':',119,2,C':',122,2,C'"')),
        IFTHEN=(WHEN=INIT,OVERLAY=(1,213,SQZ=(SHIFT=LEFT,PAIR=QUOTE))),
        IFTHEN=(WHEN=INIT,FINDREP=(IN=C'"',OUT=C''))
  OUTFIL FNAMES=SORTOUT,REMOVECC,BUILD=(1,191),
         HEADER1=(C'FECHA_FORMAL;FECHA_APE;NRO_CUENTA;DIVISA;',
                  C'CONCEPTO;CENTRO_UMO;NOMBRE_OFICINA;USERID_UMO;',
                  C'NETNAME_UMO;CANAL_DESC;TIMEST')
