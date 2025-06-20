#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FINR904.CH"

//旼컴컴컴컴컴컴컴�
//쿟ipos de Movimentos�
//읕컴컴컴컴컴컴컴�
#DEFINE TODOS_MOV				 	1
#DEFINE CONSTITUICAO	       	2
#DEFINE APROPRIACAO          	3
#DEFINE REALIZACAO          	4
#DEFINE BAIXA             		5

//旼컴컴컴컴컴컴컴컴컴� �
//쿞tatus de Movimentos�
//읕컴컴컴컴컴컴컴컴컴� �
#DEFINE TODOS_ESTATUS		 	1
#DEFINE SIMULADO	       		2
#DEFINE EFETIVADO          	3
#DEFINE ESTORNADO          	4

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿑INR904   튍utor  쿌lvaro Camillo Neto � Data �  04/01/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝elatorio de conferencia de Processo de Ajuste Contas       볍�
굇�          쿪 receber                                                   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGAFIN                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function FINR904()
Local oReport	:= nil

Private cTitulo	:= STR0001//"Conferencia de Processo de AVP Contas a Receber"
Private cPerg	:= "FIN904"

#IFNDEF TOP
	Help(" ",1,"FINNAOTOP",,STR0002,1,0)//"Processo dispon�vel apenas para ambiente TOPCONNECT / TOTVSDBACCESS"
	Return( .F. ) 
#ENDIF

oReport := ReportDef() 
oReport:PrintDialog()  

Return

	
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿝eportDef 튍utor  쿌lvaro Camillo Neto � Data �  04/01/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿏efini豫o do Relatorio                                      볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � FINR904                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function ReportDef()  

Local oReport	:= nil
Local oFIO   	:= nil
Local oFIP		:= nil
Local oColFip	:= Nil
Local cDesc		:= STR0003//"Esse relat�rio tem o objetivo de listar os titulos ajustados no processo, para fins de conferencia."
Local nX		:= 0

DEFINE REPORT oReport NAME "FINR904" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| RepFR904(oReport,cPerg)} DESCRIPTION cDesc
	oReport:DisableOrientation()
	oReport:SetLandScape()  
	DEFINE SECTION oFIO OF oReport TITLE STR0004 TABLES "FIO" //"Cabe�alho do Processamento"
		DEFINE CELL NAME "FIO_PROC"			OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_DTAVP"	  	OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_STATUS"		OF oFIO ALIAS "FIO"  SIZE 15  
		DEFINE CELL NAME "FIO_VLRDE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_VLRATE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_VENDE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_VENATE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_NATDE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_NATATE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_PORDE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_PORATE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_CLIDE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_CLIATE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_LOJDE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_LOJATE"		OF oFIO ALIAS "FIO" 
		DEFINE CELL NAME "FIO_METODO"		OF oFIO ALIAS "FIO"  SIZE 15 
		
		DEFINE SECTION oFIP OF oFIO TITLE STR0005 TABLES "FIP" //"Movimentos do processamento"			
			DEFINE CELL NAME "FIP_PREFIX"	OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_NUM"		OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_PARCEL"	OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_TIPO"		OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_CLIENT"	OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_LOJA"		OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_TIPAVP"	OF oFIP ALIAS "FIP" SIZE 15
			DEFINE CELL NAME "FIP_DTAVP"	OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_VLRAVP"	OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_TAXAVP"	OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_FORMUL"	OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_CODIND"	OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_VLRIND"	OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_CRITIC"	OF oFIP ALIAS "FIP"
			DEFINE CELL NAME "FIP_PERIOD"	OF oFIP ALIAS "FIP" 
			DEFINE CELL NAME "FIP_STATUS"	OF oFIP ALIAS "FIP" SIZE 15
			 
	   	DEFINE COLLECTION OF oFIP FUNCTION SUM FORMULA oFIP:Cell("FIP_TIPAVP") CONTENT oFIP:Cell("FIP_VLRAVP") 
	oFIO:SetAutoSize()
	oFIO:SetHeaderPage(.T.)
	oFIO:SetLinesBefore(2)
	For nX := 1 To Len(oFIO:aCell)
		oFIO:Cell(nX):SetBorder("BOTTOM")
	Next
	/*-*/
	oFIP:SetTotalText({|| " "})
	oFIP:SetAutoSize()
	oFIP:SetHeaderPage(.T.)
	oFIP:SetLinesBefore(0)

Return oReport


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿝epFR904  튍utor  � Alvaro Camillo Neto� Data �  13/02/09   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Realiza a query dos dados                                  볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � FINR904                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function RepFR904(oReport,cPerg)
Local oFIO		:= oReport:Section(1)
Local oFIP		:= oReport:Section(1):Section(1)
Local cProcDe	:= ""
Local cProcAte	:= ""
Local cTipoMov	:= ""
Local cStatus	:= ""
Local cAliasQry	:= ""

Pergunte(cPerg,.F.)
cProcDe	:= MV_PAR01
cProcAte	:= MV_PAR02 
If MV_PAR03 == CONSTITUICAO
	cTipoMov := "% 'C' %"
ElseIf MV_PAR03 == APROPRIACAO
	cTipoMov := "% 'A' %"
ElseIf MV_PAR03 == REALIZACAO
	cTipoMov := "% 'R' %"
ElseIf MV_PAR03 == BAIXA
	cTipoMov := "% 'B' %"
Else
	cTipoMov := "% 'C','A','R','B' %"
EndIf  

If MV_PAR04 == SIMULADO
	cStatus := "% 'S' %"
ElseIf MV_PAR04 == EFETIVADO
	cStatus := "% 'E' %"
ElseIf MV_PAR04 == ESTORNADO
	cStatus := "% 'X' %"
Else
	cStatus := "% 'E','S','X' %"
EndIf

cAliasQry	:= GetNextAlias()

BEGIN REPORT QUERY oFIO
	BeginSql Alias cAliasQry	
		SELECT
	  		FIO_FILIAL,
			FIO_PROC ,	 
			FIO_DTAVP, 	 
			FIO_STATUS, 	
			FIO_VLRDE, 	
			FIO_VLRATE, 	
			FIO_VENDE, 	
			FIO_VENATE, 	
			FIO_NATDE, 	
			FIO_NATATE, 	
			FIO_PORDE, 	
			FIO_PORATE, 	
			FIO_CLIDE, 	
			FIO_CLIATE, 	
			FIO_LOJDE, 	
			FIO_LOJATE, 	
			FIO_METODO, 	
			FIP_FILIAL,
			FIP_PROC,
			FIP.R_E_C_N_O_ FIPRECNO,
			FIP_PREFIX ,	
			FIP_NUM	 ,	
			FIP_PARCEL,	
			FIP_TIPO,		
			FIP_CLIENT,	
			FIP_LOJA	,	
			FIP_TIPAVP,	
			FIP_DTAVP,	
			FIP_VLRAVP,	
			FIP_TAXAVP,	
			FIP_FORMUL,	
			FIP_CODIND,	
			FIP_VLRIND,	
			FIP_CRITIC,	
			FIP_PERIOD,	
			FIP_STATUS			
		FROM  %table:FIO% FIO
		INNER JOIN %table:FIP% FIP ON
			FIO_FILIAL = FIP_FILIAL AND	 
			FIO_PROC   = FIP_PROC AND 	
			FIP_STATUS 	IN (%exp:cStatus%) AND 	 		
			FIP_TIPAVP 	IN (%exp:cTipoMov%) AND 	 	
			FIP.%notDel%
		WHERE
			FIO_FILIAL =  %xfilial:FIO% AND
			FIO_PROC 	>= %exp:cProcDe% AND
			FIO_PROC 	<= %exp:cProcAte% AND
			FIO.%notDel% 		 
		ORDER BY FIO_PROC
	EndSql	
END REPORT QUERY oFIO
	
oFIP:SetParentQuery()
oFIP:SetParentFilter({|cParam| (cAliasQry)->( FIO_FILIAL + FIO_PROC ) == cParam},{|| (cAliasQry)->(FIP_FILIAL + FIP_PROC)})

oFIO:Print()
Return
