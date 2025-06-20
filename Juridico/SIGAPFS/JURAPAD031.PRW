#INCLUDE "JURAPAD031.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD031
Relatorio Crystal de WO

@param lAutomato, Se verdadeiro indica execu��o via automa��o
@param cNameAuto, Nome do arquivo do relat�rio via a ser gerado atrav�s da automa��o

@Return lRet    , Indica se o relat�rio foi emitido com sucesso

@author Jorge Luis Branco Martins Junior
@since 22/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURAPAD031(lAutomato, cNameAuto)
	Local lRet      := .F.
	Local aArea     := GetArea()
	Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usu�rio possui acesso a dados sens�veis ou pessoais (LGPD)
	
	If lPDUserAc
		If lAutomato .Or. Pergunte('JURAPAD031')
			JR031Relat(MV_PAR01, MV_PAR02, Str(MV_PAR03, 1), Str(MV_PAR04, 1), lAutomato, cNameAuto)
		EndIf
	Else
		MsgInfo(STR0018, STR0019) // "Usu�rio com restri��o de acesso a dados pessoais/sens�veis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JR031VldDt
Valida a data

@Param nData   Indica data para valida��o(1-Data Inicial;2-Data Final)
@Param dDtIni  Indica data inicial do filtro
@Param dDtFim  Indica data final do filtro

@Return lRet  Indica se o filtro de data est� correto

@author Jorge Luis Branco Martins Junior
@since 22/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR031VldDt(nData,dDtIni,dDtFim)

Local lRet := .T.

If  (nData == 1)
    If  (dTos(dDtIni) > dTos(Date()))
		 lRet := .F.
		 ApMsgAlert(STR0013) // "Data Inicial para consulta n�o pode ser maior que a data atual!"
    EndIf
EndIf	
                                                                                 
If  lRet .And. !Empty(dTos(dDtIni)) .And. !Empty(dTos(dDtFim))
    If  (dTos(dDtFim) < dTos(dDtIni))
		 lRet := .F.
		 ApMsgAlert(STR0014) // "Data Final deve ser maior que a inicial. Verifique!"
    EndIf
EndIf

If  lRet .And. (nData == 2)
    If  (dTos(dDtFim) > dTos(Date()))
		 lRet := .F.
		 ApMsgAlert(STR0015) // "N�o � poss�vel emitir relat�rio com dados futuros"
    EndIf
EndIf

Return lRet   

//-------------------------------------------------------------------
/*/{Protheus.doc} JR031Relat
Rotina para o processamento do relatorio em Crystal.

@Param dDtIni   , Indica data inicial do filtro
@Param dDtFim   , Indica data final do filtro
@Param cSAtivos , Indica se ser� emitido apenas WOs ativos(1-Sim;2-N�o)
@Param cResult  , Indica se o relat�rio ser� enviado para 
                  (1-Tela;2-Impressora)
@param lAutomato, Se verdadeiro indica execu��o via automa��o
@param cNameAuto, Nome do arquivo do relat�rio via a ser gerado atrav�s da automa��o

@Return lRet  Indica se o os par�metros foram preenchidos corretamente
                para emiss�o do relat�rio. 

@author Jorge Luis Branco Martins Junior
@since 22/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JR031Relat(dDtIni, dDtFim, cSAtivos, cResult, lAutomato, cNameAuto)
Local lRet       := .T.
Local cRelatorio := "JURAPAD031"
Local cArquivo   := "JURAPAD031" 
Local aTables    := {'NXV','NW4','NWE','NW0','NVZ','NWD','RD0'}
Local cModRel     := SuperGetMV('MV_JMODREL',,'1')  // TIPO DE RELATORIO 1 CRYSTAL, 2 FWMSPRINT
Local lJURRPAD031 := ExistBlock('JURRPAD031')

Begin Sequence

	If  Empty(dDtIni) .Or. Empty(dDtFim) .Or. Empty(cSAtivos) .Or. Empty(cResult)
		lRet := .F.
		ApMsgAlert(STR0016) // "Alguns dos par�metros n�o foram preenchidos! Verifique!"
		Break
	EndIf

    If cModRel == '1' .And. !lAutomato // CRYSTAL
    	/*
    	CALLCRYS (rpt , params, options), onde:
    	rpt = Nome do relat?rio, sem o caminho.
    	params = Par?metros do relat?rio, separados por v?rgula ou ponto e v?rgula. Caso seja marcado este par?metro, ser?o desconsiderados os par?metros marcados no SX1.
    	options = Op??es para n?o se mostrar a tela de configura??o de impress?o , no formato x;y;z;w ,onde:
    	x = Impress?o em V?deo(1), Impressora(2), Impressora(3), Excel (4), Excel Tabular(5), PDF(6) e?Texto?(7)?.
    	y = Atualiza Dados  ou n?o(1)
    	z = N?mero de C?pias, para exporta??o este valor sempre ser? 1.
    	w =T?tulo do Report, para exporta??o este ser? o nome do arquivo sem extens?o.
    	*/

    	cOptions := cResult + ";0;1;"
	
    	cParams  := dtos(dDtIni) + ";" + dtos(dDtFim) + ";" + ;
    				cSAtivos + ";"
		
    	JCallCrys( cRelatorio, cParams, cOptions + cArquivo, .T., .T., .F., aTables)
    Else
    	If lJURRPAD031
    		ExecBlock('JURRPAD031', .F., .F.)
    	Else
    		JURRPAD031(dDtIni, dDtFim, cSAtivos, cRelatorio, lAutomato, cNameAuto)
    	Endif	
    Endif	 

End Sequence

Return lRet
