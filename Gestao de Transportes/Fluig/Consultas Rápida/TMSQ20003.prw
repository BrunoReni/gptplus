#include "protheus.ch"
#include "quicksearch.ch"
#include "tmsq20003.ch"

QSSTRUCT TMSQ20003 DESCRIPTION STR0001 MODULE 43 //DOCUMENTOS A FATURAR
 
QSMETHOD INIT QSSTRUCT TMSQ20003

Local dData := Date()	

QSTABLE "DT6" LEFT JOIN "DUD" ON "DUD_FILDOC = DT6_FILDOC AND DUD_DOC = DT6_DOC"
QSTABLE "DT6" LEFT JOIN "SA1" ON "A1_COD = DT6_CLIDEV AND A1_LOJA = DT6_LOJDEV"	
		  
// campos do SX3 e indices do SIX	
QSPARENTFIELD "A1_NOME" INDEX ORDER 2 SET RELATION TO "DT6_CLIDEV","DT6_LOJDEV" WITH "A1_COD","A1_LOJA" LABEL STR0002 //"Nome Devedor"
	 
// campos do SX3 e indices do SIX
QSPARENTFIELD "DT6_FILDOC","DT6_DOC"	INDEX ORDER 1 LABEL STR0003 //"Fil.Docto+Docto"
QSPARENTFIELD "DT6_CLIREM"				INDEX ORDER 6		//Remetente
QSPARENTFIELD "DT6_CLIDES"				INDEX ORDER 7		//Destinatário	
QSPARENTFIELD "DT6_CLIDEV"				INDEX ORDER 10	//Devedor
		
// campos do SX3
QSFIELD "DT6_FILDOC "			LABEL STR0004 //"Fil.Origem "
QSFIELD "DT6_DOC "				LABEL STR0005 //"Num.Docto. "
QSFIELD "DT6_SERIE" 			LABEL STR0006 //"Serie"
QSFIELD "DT6_DATEMI"			LABEL STR0007 //"Data"	
QSFIELD "DT6_STATUS"			LABEL STR0009 //"Status"	
	
QSACTION MENUDEF "TMSA500" OPERATION 2 LABEL STR0010 //"Visualizar"
		
QSFILTER STR0011 WHERE "DT6_SERTMS <> '1' AND DT6_NUM = '' AND DT6_DATEMI = '"+DTOS(dData)		+"'" //"Ultimo dia"
QSFILTER STR0012 WHERE "DT6_SERTMS <> '1' AND DT6_NUM = '' AND DT6_DATEMI > '"+DTOS(dData-7)  	+"'" //"Ultimos 7 dias"
QSFILTER STR0013 WHERE "DT6_SERTMS <> '1' AND DT6_NUM = '' AND DT6_DATEMI > '"+DTOS(dData-30)	+"'" //"Ultimos 30 dias"
QSFILTER STR0014 WHERE "DT6_SERTMS <> '1' AND DT6_NUM = '' AND DT6_DATEMI > '"+DTOS(dData-360)	+"'" //"Ultimos 365 dias"
			
Return