#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FINR906.CH"
                                                                                 
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
굇튡rograma  쿑INR906   튍utor  쿌lvaro Camillo Neto � Data �  04/01/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝elatorio de conferencia de Processo de Ajuste - Contas a   볍�
굇�          쿾agar                                                       볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGAFIN                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function FINR906()
Local oReport		:= nil

Private cTitulo		:= STR0001//"Conferencia de Processo de AVP Contas a Pagar"
Private cPerg	 	:= "FIN906"

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
굇튧so       � ATFR350                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function ReportDef()  

Local oReport	:= nil
Local oFIR   	:= nil
Local oColFis	:= Nil
Local oFIS		:= nil
Local cDesc		:= STR0003//"Esse relat�rio tem o objetivo de listar os titulos ajustados no processo, para fins de conferencia."
Local nX		:= 0

DEFINE REPORT oReport NAME "FINR906" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| RepFR906(oReport,cPerg)} DESCRIPTION cDesc
	oReport:DisableOrientation()
	oReport:SetLandScape()
	
	DEFINE SECTION oFIR OF oReport TITLE STR0004 TABLES "FIR" //"Cabe�alho do Processamento"
		DEFINE CELL NAME "FIR_PROC"			OF oFIR ALIAS "FIR"
		DEFINE CELL NAME "FIR_DTAVP"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_STATUS"		OF oFIR ALIAS "FIR"  SIZE 15  
		DEFINE CELL NAME "FIR_VLRDE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_VLRATE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_VENDE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_VENATE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_NATDE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_NATATE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_PORDE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_PORATE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_FORDE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_FORATE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_LOJDE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_LOJATE"		OF oFIR ALIAS "FIR" 
		DEFINE CELL NAME "FIR_METODO"		OF oFIR ALIAS "FIR"  SIZE 15 
		
		DEFINE SECTION oFIS OF oFIR TITLE STR0005 TABLES "FIS" //"Movimentos do processamento"			
			DEFINE CELL NAME "FIS_PREFIX" 	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_NUM" 	  	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_PARCEL" 	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_TIPO" 	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_FORNEC"	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_LOJA"		OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_TIPAVP"	OF oFIS ALIAS "FIS" SIZE 15
			DEFINE CELL NAME "FIS_DTAVP"	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_VLRAVP"	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_TAXAVP"	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_FORMUL"	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_CODIND"	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_VLRIND"	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_CRITIC"	OF oFIS ALIAS "FIS"
			DEFINE CELL NAME "FIS_PERIOD"	OF oFIS ALIAS "FIS" 
			DEFINE CELL NAME "FIS_STATUS"	OF oFIS ALIAS "FIS" SIZE 15
				
	   	DEFINE COLLECTION oColFis OF oFIS FUNCTION SUM FORMULA oFIS:Cell("FIS_TIPAVP") CONTENT oFIS:Cell("FIS_VLRAVP")
	   	  	  	
	oFIR:SetAutoSize()
	oFIR:SetHeaderPage(.T.)
	oFIR:SetLinesBefore(2)
	For nX := 1 To Len(oFIR:aCell)
		oFIR:Cell(nX):SetBorder("BOTTOM")
	Next
	/*-*/
	oFIS:SetTotalText({|| " "})
	oFIS:SetAutoSize()
	oFIS:SetHeaderPage(.T.)
	oFIS:SetLinesBefore(0)

Return oReport


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿝epFR906  튍utor  � Alvaro Camillo Neto� Data �  13/02/09   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Realiza a query dos dados                                  볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � FINR906                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function RepFR906(oReport,cPerg)
Local oFIR		:= oReport:Section(1)
Local oFIS		:= oReport:Section(1):Section(1)
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
 
BEGIN REPORT QUERY oFIR
	BeginSql Alias cAliasQry	
		SELECT
	  		FIR_FILIAL,
			FIR_PROC ,	 
			FIR_DTAVP, 	 
			FIR_STATUS, 	
			FIR_VLRDE, 	
			FIR_VLRATE, 	
			FIR_VENDE, 	
			FIR_VENATE, 	
			FIR_NATDE, 	
			FIR_NATATE, 	
			FIR_PORDE, 	
			FIR_PORATE, 	
			FIR_FORDE, 	
			FIR_FORATE, 	
			FIR_LOJDE, 	
			FIR_LOJATE, 	
			FIR_METODO, 
			FIS_FILIAL,
			FIS_PROC,
			FIS.R_E_C_N_O_ FISRECNO,
			FIS_PREFIX ,	
			FIS_NUM	 ,	
			FIS_PARCEL,	
			FIS_TIPO,		
			FIS_FORNEC,	
			FIS_LOJA	,	
			FIS_TIPAVP,	
			FIS_DTAVP,	
			FIS_VLRAVP,	
			FIS_TAXAVP,	
			FIS_FORMUL,	
			FIS_CODIND,	
			FIS_VLRIND,	
			FIS_CRITIC,	
			FIS_PERIOD,	
			FIS_STATUS			
		FROM  %table:FIR% FIR
		INNER JOIN %table:FIS% FIS ON
			FIR_FILIAL = FIS_FILIAL AND	 
			FIR_PROC   = FIS_PROC AND 	 	
			FIS_STATUS 	IN (%exp:cStatus%) AND 	 		
			FIS_TIPAVP 	IN (%exp:cTipoMov%) AND
			FIS.%notDel% 	
		WHERE
			FIR_FILIAL =  %xfilial:FIR% AND
			FIR_PROC 	>= %exp:cProcDe% 	AND
			FIR_PROC 	<= %exp:cProcAte%	AND
			FIR.%notDel% 		 
		ORDER BY FIR_PROC
	EndSql	
END REPORT QUERY oFIR
	
oFIS:SetParentQuery()
oFIS:SetParentFilter({|cParam| (cAliasQry)->( FIR_FILIAL + FIR_PROC ) == cParam},{|| (cAliasQry)->(FIS_FILIAL + FIS_PROC)})

oFIR:Print()
Return
