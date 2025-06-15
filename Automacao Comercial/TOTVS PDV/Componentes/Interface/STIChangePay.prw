#Include 'Protheus.ch'
#Include "POSCSS.CH"
#Include 'STIChangePay.ch'

Static cCodCli		:= ""
Static oDlgFrmPagto	:= Nil

//------------------------------------------------------------------------------
/*{Protheus.doc} STIChangePay
Fun��o para montar tela para mudan�a de pagamento
@param   	aPagtos     
@author     F�bio Siqueira dos Santos
@version    P12
@since      28/05/2018
@return     Nil
/*/
//------------------------------------------------------------------------------
Function STIChangePay(aPagtos)
Local oLblOrc		:= Nil
Local oLblNroOrc	:= Nil
Local oLblCli		:= Nil
Local oLblCodCli	:= Nil
Local oLblFrmPagto	:= Nil
Local oBtnOk		:= Nil
Local oBtnConf		:= Nil
Local oBtnCanc		:= Nil
Local oBtnLimpar	:= Nil
Local aAlter		:= {"L4_NVFORM","L4_QTDCART","L4_NVPARC"}
Local nCont			:= 0
Local nPosOrc		:= 0
Local nPosCodCli	:= 0
Local nPosLojaCli	:= 0
Local nPosForma		:= 0
Local nPosValor		:= 0
Local nPosIDCard	:= 0
Local cForma		:= ""
Local cParc			:= ""
Local cIdCard		:= ""
Local cFieldOk		:= "STIVldFrm()"
 
Private aHeadPagto 	:= {}
Private aColsPagto	:= {}
Private aPagtosMHI	:= {}
Private aHeadResumo	:= {}
Private aColsResumo	:= {}
Private oGetPagtos	:= Nil
Private oGetCards	:= Nil
Private oGetResumo	:= Nil
Private cNumOrc		:= ""

Default aPagtos		:= {}

If Len(aPagtos) > 0
	//Desabilita controles da tela principal. Motivo: Se o usu�rio utilizar uma tecla de atalho
	STIBtnDeActivate()
	
	nPosOrc := aScan(aPagtos[1],{ |x| AllTrim(x[1]) == "L4_NUM"} )
	nPosCodCli := aScan(aImported[4][1][1],{ |x| AllTrim(x[1]) == "L1_CLIENTE"} )
	nPosLojaCli := aScan(aImported[4][1][1],{ |x| AllTrim(x[1]) == "L1_LOJA"} )
	nPosForma := aScan(aPagtos[1],{ |x| AllTrim(x[1]) == "L4_FORMA"} )
	nPosValor := aScan(aPagtos[1],{ |x| AllTrim(x[1]) == "L4_VALOR"} )
	nPosIDCard := aScan(aPagtos[1],{ |x| AllTrim(x[1]) == "L4_FORMAID"} )
	
	//aHeader da grid de pagamentos do or�amento
	Aadd( aHeadPagto, { STR0001, "L4_FORMA"		, "@!", 35, 0, , , "C",, "V", } ) //"Forma de Pagamento"
	Aadd( aHeadPagto, { STR0002, "L4_VALOR"		, "@E 9,999,999,999,999.99", 16, 2, , , "N",, "V", } ) //"Valor"
	Aadd( aHeadPagto, { STR0003, "L4_PARCELA"	, "@!", 2, 0, , , "C",, "V", } ) //"Parcelas"
	Aadd( aHeadPagto, { STR0004, "L4_FORMAID"	, "@!", 2, 0, , , "C",, "V", } ) //"ID Cart�o"
	Aadd( aHeadPagto, { STR0005, "L4_NVFORM"	, "@!", 35, 0, , , "C","MHICHG", "A", } ) //"Nova Forma"
	Aadd( aHeadPagto, { STR0006, "L4_QTDCART"	, "@99", 2, 0, , , "N",, "A", } ) //"Qtde. Cart�es"
	Aadd( aHeadPagto, { STR0007, "L4_NVPARC"	, "@99", 2, 0, , , "C",, "A", } ) //"Nova Parcela"
	
	//aHeader da grid de pagamentos depois das altera��es - Resumo
	Aadd( aHeadResumo, { STR0001, "L4_FORMA"	, "@!", 35, 0, , , "C",, "V", } ) //"Forma de Pagamento"
	Aadd( aHeadResumo, { STR0002, "L4_VALOR"	, "@E 9,999,999,999,999.99", 16, 2, , , "N",, "V", } ) //"Valor"
	Aadd( aHeadResumo, { STR0003, "L4_NVPARC"	, "@99", 2, 0, , , "C",, "V", } ) //"Parcelas"
	Aadd( aHeadResumo, { STR0004, "L4_FORMAID"	, "@!", 2, 0, , , "C",, "V", } ) //"ID Cart�o"
	
	//aCols do Resumo		
	aAdd(aColsResumo,Array(Len(aHeadResumo)+1))
	
	For nCont := 1 To Len(aHeadResumo)
		If aHeadResumo[nCont][2] == "L4_NVPARC" //Tratamento para esse campo que n�o existe no SX3
			aColsResumo[1][nCont] := "00"
		Else 
			aColsResumo[1][nCont] := CriaVar(aHeadResumo[nCont][2],.T.)
		EndIf
	Next nCont
	aColsResumo[1][Len(aHeadResumo)+1] := .F.
				
	cIdCard := aPagtos[1][nPosIDCard][2]
	cNumOrc	:= aPagtos[1][nPosOrc][2]
	cCodCli := aImported[4][1][1][nPosCodCli][2] + "/" + aImported[4][1][1][nPosLojaCli][2] + " - " + Posicione("SA1",1,xFilial("SA1")+aImported[4][1][1][nPosCodCli][2]+aImported[4][1][1][nPosLojaCli][2],"A1_NOME")
	
	//aCols dos Pagamentos do or�amento
	For nCont := 1 To Len(aPagtos)	
	
		If AllTrim(aPagtos[nCont][nPosForma][2]) <> cForma
			cParc := "01"
			Aadd(aPagtosMHI,{AllTrim(aPagtos[nCont][nPosForma][2]),STDChgPay(aPagtos[nCont][nPosForma][2])})
		
			Aadd(aColsPagto,{AllTrim(aPagtos[nCont][nPosForma][2]) + " - " + POSICIONE( "SX5", 1, xFilial( "SX5" ) + "24" + AllTrim(aPagtos[nCont][nPosForma][2]), "X5_DESCRI" ),;
              aPagtos[nCont][nPosValor][2],;
              Iif(AllTrim(aPagtos[nCont][nPosForma][2]) = "R$","",cParc),;
              AllTrim(aPagtos[nCont][nPosIDCard][2]),;
              Space(35),;
              Space(0),;
              Space(0),;
              .F.})
			cForma := AllTrim(aPagtos[nCont][nPosForma][2])
		Else
			//Quando o pagamento � em cart�o e parcelado
			If AllTrim(aPagtos[nCont][nPosForma][2]) $ "CC|CD" .And. aPagtos[nCont][nPosIDCard][2] == cIdCard
				nPos :=	AScan(aColsPagto,{|x| SubStr(x[1],1,2) == SubStr(aPagtos[nCont][nPosForma][2],1,2) .And. AllTrim(x[4]) == AllTrim(aPagtos[nCont][nPosIDCard][2])})
				aColsPagto[nPos][2] += aPagtos[nCont][nPosValor][2]
				cParc := Soma1(cParc) 
				aColsPagto[nPos][3]	:= cParc
			Else
				//Pagamento em mais de um cart�o
				cParc := "01"
				Aadd(aColsPagto,{AllTrim(aPagtos[nCont][nPosForma][2]) + " - " + POSICIONE( "SX5", 1, xFilial( "SX5" ) + "24" + AllTrim(aPagtos[nCont][nPosForma][2]), "X5_DESCRI" ),;
					aPagtos[nCont][nPosValor][2],;
					Iif(AllTrim(aPagtos[nCont][nPosForma][2]) = "R$","",cParc),;
					AllTrim(aPagtos[nCont][nPosIDCard][2]),;
					Space(35),;
					Space(0),;
					Space(0),;
					.F.})
				cForma	:= AllTrim(aPagtos[nCont][nPosForma][2])
				cIdCard	:= aPagtos[nCont][nPosIDCard][2] 
			EndIf
		EndIf
	Next nCont

	DEFINE MSDIALOG oDlgFrmPagto TITLE STR0008 STYLE DS_MODALFRAME FROM 0,0 TO 650,850 PIXEL OF oMainWnd	//"Troca de Pagamento"
							
		oDlgFrmPagto:lEscClose     := .F. //Nao permite sair ao pressionar a tecla ESC.
		
		oLblOrc := TSay():New(010,009,{|| STR0009 },oDlgFrmPagto,,,,,,.T.,,,,) //"Or�amento:"
		oLblOrc:SetCSS( POSCSS (GetClassName(oLblOrc), CSS_LABEL_FOCAL )) 
		
		oLblNroOrc := TSay():New(010,050,{|| cNumOrc },oDlgFrmPagto,,,,,,.T.,,,,) //"Nro. Or�amento"
		oLblNroOrc:SetCSS( POSCSS (GetClassName(oLblNroOrc), CSS_LABEL_NORMAL ))
		
		oLblCli := TSay():New(025,009,{|| STR0010  },oDlgFrmPagto,,,,,,.T.,,,,) //"Cliente:"
		oLblCli:SetCSS( POSCSS (GetClassName(oLblCli), CSS_LABEL_FOCAL )) 
		
		oLblCodCli := TSay():New(025,050,{|| cCodCli },oDlgFrmPagto,,,,,,.T.,,,,) //"C�d. Cliente"
		oLblCodCli:SetCSS( POSCSS (GetClassName(oLblCodCli), CSS_LABEL_NORMAL ))
		
		oLblFrmPagto := TSay():New(045,009,{|| STR0011 },oDlgFrmPagto,,,,,,.T.,,,,) //"Forma de Pagamento Original:"
		oLblFrmPagto:SetCSS( POSCSS (GetClassName(oLblFrmPagto), CSS_LABEL_FOCAL )) 
		
		oGetPagtos := MsNewGetDados():New( 060, 009, 140, 420, GD_UPDATE, "AllwaysTrue", "AllwaysTrue",, aAlter,,999, cFieldOk, "", "AllwaysTrue", oDlgFrmPagto, aHeadPagto, aColsPagto)
		
		oBtnOk		:= TButton():New( 150,275, STR0012, oDlgFrmPagto,{|| lRet := STBValidPay()},50,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Ok" 
		oBtnOk:SetCSS(  POSCSS (GetClassName(oBtnOk)    , CSS_BTN_FOCAL ))
		
		oLblResumo := TSay():New(170,009,{|| STR0013 },oDlgFrmPagto,,,,,,.T.,,,,) //"Forma de Pagamento Atualizada:"
		oLblResumo:SetCSS( POSCSS (GetClassName(oLblResumo), CSS_LABEL_FOCAL )) 
		
		oGetResumo := MsNewGetDados():New( 185, 009, 265, 420, , "AllwaysTrue", "AllwaysTrue",,,,999, "AllwaysTrue", "", "AllwaysTrue", oDlgFrmPagto, aHeadResumo, aColsResumo)
		
		oBtnConf	:= TButton():New( 300,155, STR0014, oDlgFrmPagto,{|| lRet := STBChangePay(@aPagtos), IIF(lRet,oDlgFrmPagto:End(),Nil), lChkAtiv := .F.},50,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Confirmar" 
		oBtnConf:SetCSS(  POSCSS (GetClassName(oBtnConf)    , CSS_BTN_FOCAL ))
		
		oBtnCanc	:= TButton():New( 300,215, STR0015, oDlgFrmPagto,{|| IIf( ApMsgYesNo( STR0016 + Chr(13) + Chr(10)+ STR0017),oDlgFrmPagto:End(),Nil), lChkAtiv := .T. },50,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Cancela"/"Deseja CANCELAR a troca de pagamento?"/"(Se confirmado, ser� considerado as formas de pagamento do Or�amento.)"  
		oBtnCanc:SetCSS(  POSCSS (GetClassName(oBtnCanc)    , CSS_BTN_FOCAL ))
		
		oBtnLimpar	:= TButton():New( 300,275, STR0018, oDlgFrmPagto, {|| IIf( ApMsgYesNo( STR0019 + Chr(13) + Chr(10)+ STR0020),STILimpaPgto(aColsResumo),Nil) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Limpar" //"Deseja limpar TODAS as formas de pagamentos informada?"	//"(Se confirmado, as novas formas de pagamento ser�o apagadas.)"  
		oBtnLimpar:SetCSS(  POSCSS (GetClassName(oBtnLimpar)    , CSS_BTN_FOCAL ))
					
	ACTIVATE MSDIALOG oDlgFrmPagto CENTERED
Else
	STFMessage( STR0021 , STR0022 , STR0023 ) 		//"STIChangePay"/"STOP"/"Or�amento n�o cont�m pagamentos"
	LjGrvLog(STR0024,STR0025)	//"Importa_Orcamento:STIChangePay"/"Or�amento n�o cont�m pagamentos"
EndIf
Return Nil

//------------------------------------------------------------------------------
/*{Protheus.doc} STILimpaPgto
Fun��o para limpar as formas de pagamentos da grid de Resumo
@param   	aColsResumo     
@author     F�bio Siqueira dos Santos
@version    P12
@since      26/06/2018
@return     .T.
/*/
//------------------------------------------------------------------------------
Function STILimpaPgto(aColsResumo)
Local nCont := 0 
aColsResumo := {}
aAdd(aColsResumo,Array(Len(aHeadResumo)+1))
For nCont := 1 To Len(aHeadResumo)
	If aHeadResumo[nCont][2] == "L4_NVPARC" //Tratamento para esse campo que n�o existe no SX3
		aColsResumo[1][nCont] := 0
	Else 
		aColsResumo[1][nCont] := CriaVar(aHeadResumo[nCont][2],.T.)
	EndIf
Next nCont
aColsResumo[1][Len(aHeadResumo)+1] := .F.
oGetResumo:SetArray(aColsResumo,.T.)
oGetResumo:Refresh()
Return .T.

//------------------------------------------------------------------------------
/*{Protheus.doc} STIVldFrm
Fun��o para validar o campo nova forma, parcelas e qtde de cart�es
@param   	     
@author     F�bio Siqueira dos Santos
@version    P12
@since      02/07/2018
@return     .T. ou .F.
/*/
//------------------------------------------------------------------------------
Function STIVldFrm()
Local lRet			:= .T.
Local nPos			:= 0
Local aFormas		:= {}
Local nPosForma		:= aScan( oGetPagtos:aHeader, { |x| Alltrim(x[2])=="L4_FORMA" } )
Local nPosNvFrm		:= aScan( oGetPagtos:aHeader, { |x| Alltrim(x[2])=="L4_NVFORM" } )
Local nPosQtdCard	:= aScan( oGetPagtos:aHeader, { |x| Alltrim(x[2])=="L4_QTDCART" } )
Local nPosNvParc	:= aScan( oGetPagtos:aHeader, { |x| Alltrim(x[2])=="L4_NVPARC" } ) 

If StrTran(Alltrim(ReadVar()),'M->','') == "L4_NVFORM" .Or. StrTran(Alltrim(ReadVar()),'M->','') == "L4_QTDCART" .OR. StrTran(Alltrim(ReadVar()),'M->','') == "L4_NVPARC"  
	If StrTran(Alltrim(ReadVar()),'M->','') == "L4_NVFORM" 
		//Valida a forma de pagamento informada
		nPos := aScan( aPagtosMHI, { |x| Alltrim(x[1]) == SubStr(oGetPagtos:aCols[oGetPagtos:nAt][nPosForma],1,2) } )
		If nPos > 0
			aFormas := StrToKarr(aPagtosMHI[nPos][2], ";") 
			If aScan( aFormas, { |x| SubStr(x,1,2) == SubStr(&(StrTran(Alltrim(ReadVar()),'M->','')),1,2)} ) > 0 
				M->L4_NVFORM := SubStr(&(StrTran(Alltrim(ReadVar()),'M->','')),1,2) + " - " + POSICIONE( "SX5", 1, xFilial( "SX5" ) + "24" + SubStr(&(StrTran(Alltrim(ReadVar()),'M->','')),1,2), "X5_DESCRI" )
				oGetPagtos:aCols[oGetPagtos:nAt][nPosNvFrm] := SubStr(&(StrTran(Alltrim(ReadVar()),'M->','')),1,2) + " - " + POSICIONE( "SX5", 1, xFilial( "SX5" ) + "24" + SubStr(&(StrTran(Alltrim(ReadVar()),'M->','')),1,2), "X5_DESCRI" )
				If SubStr(&(StrTran(Alltrim(ReadVar()),'M->','')),1,2) $ "CC|CD" 
					oGetPagtos:aCols[oGetPagtos:nAt][nPosQtdCard] := 0
				ElseIf !Empty(&(StrTran(Alltrim(ReadVar()),'M->','')))
					If SubStr(&(StrTran(Alltrim(ReadVar()),'M->','')),1,2) == "R$" 
						oGetPagtos:aCols[oGetPagtos:nAt][nPosQtdCard] := Space(0)
						oGetPagtos:aCols[oGetPagtos:nAt][nPosNvParc] := Space(0)
					Else
						oGetPagtos:aCols[oGetPagtos:nAt][nPosQtdCard] := Space(0)
						oGetPagtos:aCols[oGetPagtos:nAt][nPosNvParc] := Space(02)
					EndIf
				Else
					oGetPagtos:aCols[oGetPagtos:nAt][nPosQtdCard] := Space(0)
					oGetPagtos:aCols[oGetPagtos:nAt][nPosNvParc] := Space(0)	
				EndIf
			Else
				MsgInfo(STR0026,STR0027) //"Essa forma de pagamento n�o est� cadastrada para a forma de pagamento original, favor verificar!"/"Aten��o"	
				lRet := .F.
			EndIf
		EndIf
	Else 
		If StrTran(Alltrim(ReadVar()),'M->','') == "L4_QTDCART"
			If Empty(oGetPagtos:aCols[oGetPagtos:nAt][nPosNvFrm]) .Or. !SubStr(oGetPagtos:aCols[oGetPagtos:nAt][nPosNvFrm],1,2) $ "CC|CD"
				M->L4_QTDCART := Space(0)
				oGetPagtos:aCols[oGetPagtos:nAt][nPosQtdCard] := Space(0)
			ElseIf SubStr(oGetPagtos:aCols[oGetPagtos:nAt][nPosNvFrm],1,2) $ "CC|CD"
				oGetPagtos:aCols[oGetPagtos:nAt][nPosQtdCard] := &(StrTran(Alltrim(ReadVar()),'M->',''))
				If &(StrTran(Alltrim(ReadVar()),'M->','')) > 1
					M->L4_NVPARC := Space(0)
					oGetPagtos:aCols[oGetPagtos:nAt][nPosNvParc] := Space(0)
				Else
					M->L4_NVPARC := "00"
					oGetPagtos:aCols[oGetPagtos:nAt][nPosNvParc] := "00"
				EndIf 
			EndIf
		EndIf
		If StrTran(Alltrim(ReadVar()),'M->','') == "L4_NVPARC"
			If Empty(oGetPagtos:aCols[oGetPagtos:nAt][nPosNvFrm]) .Or. SubStr(oGetPagtos:aCols[oGetPagtos:nAt][nPosNvFrm],1,2) $ "CC|CD"
				If oGetPagtos:aCols[oGetPagtos:nAt][nPosQtdCard] > 1
					M->L4_NVPARC := Space(0)
					oGetPagtos:aCols[oGetPagtos:nAt][nPosNvParc] := Space(0)
				Else
					oGetPagtos:aCols[oGetPagtos:nAt][nPosNvParc] := &(StrTran(Alltrim(ReadVar()),'M->',''))
				EndIf 
			ElseIf !SubStr(oGetPagtos:aCols[oGetPagtos:nAt][nPosNvFrm],1,2) $ "CC|CD"
				oGetPagtos:aCols[oGetPagtos:nAt][nPosNvParc] := &(StrTran(Alltrim(ReadVar()),'M->',''))
			EndIf	
		EndIf
	EndIf
EndIf
oGetPagtos:Refresh()
Return lRet

//------------------------------------------------------------------------------
/*{Protheus.doc} STIChgCard
Fun��o para montar tela para pagamento com cart�o e que foi definido que ser� pago com mais de 1 cart�o
@param   	aCartoes 
			aCartoes[1] = ID Cart�o
			aCartoes[2] = Nova Forma de Pagamento
			aCartoes[3] = Valor
			aCartoes[4] = Parcela
			aCartoes[5] = Qtde de Cart�es
			aCartoes[6] = Forma Original    
@author     F�bio Siqueira dos Santos
@version    P12
@since      26/06/2018
@return     .T. ou .F.
/*/
//------------------------------------------------------------------------------
Function STIChgCard(aCartoes)
Local oDlgFrmCard	:= Nil
Local aAlter		:= {"L4_VALOR","L4_NVPARC"}
Local aHeadCard		:= {}
Local aColsCard		:= {} 
Local nCont			:= 0
Local nCont2		:= 0
Local cIdCardCD		:= "00"
Local cIdCardCC		:= "00"
Local cFieldOk		:= "STIVldCard()"
Local lRet			:= .T.

Aadd( aHeadCard, { STR0001, "L4_FORMA"	, "@!", 35, 0, , , "C",, "V", } ) //"Forma de Pagamento"
Aadd( aHeadCard, { STR0002, "L4_VALOR"	, "@E 9,999,999,999,999.99", 16, 2, , , "N",, "A", } ) //"Valor"
Aadd( aHeadCard, { STR0003, "L4_NVPARC"	, "@E 99", 2, 0, , , "N",, "A", } ) //"Parcelas"
Aadd( aHeadCard, { STR0028, "L4_OLDID"	, "@!", 2, 0, , , "C",, "V", } ) //"ID Original"
Aadd( aHeadCard, { STR0029, "L4_NEWID"	, "@!", 2, 0, , , "C",, "V", } ) //"ID Atualizado"
Aadd( aHeadCard, { STR0030, "L4_OLDFRM", "@!", 35, 0, , , "C",, "V", } ) //"Forma de Pagto Anterior"
Aadd( aHeadCard, { STR0031, "L4_OLDVLR"	, "@E 9,999,999,999,999.99", 16, 2, , , "N",, "V", } ) //"Valor Original"	
Aadd( aHeadCard, { STR0032, "L4_OLDPAR"	, "@E 99", 2, 0, , , "N",, "V", } ) //"Parc. Original"

For nCont := 1 To Len(aCartoes)
	For nCont2 := 1 To aCartoes[nCont][5]
		//Aqui verifico tipo de cart�o e ID, para carregar o ID certo para cada tipo de cart�o
		If SubStr(aCartoes[nCont][2],1,2) == "CD"
			cIdCardCD := Soma1(cIdCardCD) 
		Else
			cIdCardCC := Soma1(cIdCardCC) 
		EndIf
		
		aAdd(aColsCard,{AllTrim(aCartoes[nCont][2]),;
              0,;
              0,;
              AllTrim(aCartoes[nCont][1]),;
              Iif(SubStr(aCartoes[nCont][2],1,2) == "CD", cIdCardCD, cIdCardCC),;
              aCartoes[nCont][6],;
              aCartoes[nCont][3],;
              aCartoes[nCont][4],;
              .F.})	
	Next nCont2
Next nCont 

DEFINE MSDIALOG oDlgFrmCard TITLE STR0033 STYLE DS_MODALFRAME FROM 90,0 TO 550,850 PIXEL OF oDlgFrmPagto	//"Pagamentos com mais cart�es"
								
	oDlgFrmCard:lEscClose     := .F. //Nao permite sair ao pressionar a tecla ESC.
	
	oLblOrc := TSay():New(010,009,{|| STR0009 },oDlgFrmCard,,,,,,.T.,,,,) //"Or�amento:"
	oLblOrc:SetCSS( POSCSS (GetClassName(oLblOrc), CSS_LABEL_FOCAL )) 
	
	oLblNroOrc := TSay():New(010,050,{|| cNumOrc },oDlgFrmCard,,,,,,.T.,,,,) //"Nro. Or�amento"
	oLblNroOrc:SetCSS( POSCSS (GetClassName(oLblNroOrc), CSS_LABEL_NORMAL ))
	
	oLblCli := TSay():New(025,009,{|| STR0010 },oDlgFrmCard,,,,,,.T.,,,,) //"Cliente:"
	oLblCli:SetCSS( POSCSS (GetClassName(oLblCli), CSS_LABEL_FOCAL )) 
	
	oLblCodCli := TSay():New(025,050,{|| cCodCli },oDlgFrmCard,,,,,,.T.,,,,) //"C�d. Cliente"
	oLblCodCli:SetCSS( POSCSS (GetClassName(oLblCodCli), CSS_LABEL_NORMAL ))
	
	oLblFrmPagto := TSay():New(045,009,{|| STR0034 },oDlgFrmCard,,,,,,.T.,,,,) //"Defina os pagamentos:"
	oLblFrmPagto:SetCSS( POSCSS (GetClassName(oLblFrmPagto), CSS_LABEL_FOCAL )) 
	
	oGetCards := MsNewGetDados():New( 060, 009, 140, 420, GD_UPDATE, "AllwaysTrue", "AllwaysTrue",, aAlter,,99, cFieldOk, "", "AllwaysTrue", oDlgFrmCard, aHeadCard, aColsCard)
			
	oBtnConf	:= TButton():New( 200,155, STR0014, oDlgFrmCard,{|| lRet := STBVldCard(oGetCards:aHeader, oGetCards:aCols), IIF(lRet,oDlgFrmCard:End(),Nil)},50,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Confirmar" 
	oBtnConf:SetCSS(  POSCSS (GetClassName(oBtnConf)    , CSS_BTN_FOCAL ))
	
	oBtnCanc	:= TButton():New( 200,215, STR0015, oDlgFrmCard,{|| IIf( ApMsgYesNo( STR0035 + Chr(13) + Chr(10)+ STR0036),oDlgFrmCard:End(),Nil), lRet := .F.},50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"/"Deseja CANCELAR o pagamento com mais cart�es?"/"(Se confirmado, ser� necess�rio redefinir as formas de pagamento informadas.)"  
	oBtnCanc:SetCSS(  POSCSS (GetClassName(oBtnCanc)    , CSS_BTN_FOCAL ))
	
	oBtnLimpar	:= TButton():New( 200,275, STR0018, oDlgFrmCard, {|| IIf( ApMsgYesNo( STR0019 + Chr(13) + Chr(10)+ STR0020),STIClearCard(),Nil) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Limpar" //"Deseja limpar TODAS as formas de pagamentos informada?"	//"(Se confirmado, as novas formas de pagamento ser�o apagadas.)"  
	oBtnLimpar:SetCSS(  POSCSS (GetClassName(oBtnLimpar)    , CSS_BTN_FOCAL ))
				
ACTIVATE MSDIALOG oDlgFrmCard CENTERED

Return lRet

//------------------------------------------------------------------------------
/*{Protheus.doc} STIVldCard
Fun��o para validar o campo valor e parcelas da tela de cart�es
@param   	     
@author     F�bio Siqueira dos Santos
@version    P12
@since      02/07/2018
@return     .T. ou .F.
/*/
//------------------------------------------------------------------------------
Function STIVldCard()
Local lRet			:= .T.
Local nPos			:= 0
Local nVlrTot		:= 0
Local nCont			:= 0
Local cFormaOri		:= ""
Local cFormaNew		:= ""
Local cIdCardOld	:= ""
Local aFormas		:= {}
Local nPosForma		:= aScan(oGetCards:aHeader,{ |x| AllTrim(x[2]) == "L4_FORMA"} )
Local nPosValor		:= aScan(oGetCards:aHeader,{ |x| AllTrim(x[2]) == "L4_VALOR"} )
Local nPosNvParc	:= aScan(oGetCards:aHeader,{ |x| AllTrim(x[2]) == "L4_NVPARC"} )
Local nPosOldID		:= aScan(oGetCards:aHeader,{ |x| AllTrim(x[2]) == "L4_OLDID"} )
Local nPosVlrPgt	:= aScan(oGetCards:aHeader,{ |x| AllTrim(x[2]) == "L4_OLDVLR"} )
Local nPosForOld	:= aScan(oGetCards:aHeader,{ |x| AllTrim(x[2]) == "L4_OLDFRM"} )
Local nPosParcPgt	:= aScan(oGetCards:aHeader,{ |x| AllTrim(x[2]) == "L4_OLDPAR"} )

If StrTran(Alltrim(ReadVar()),'M->','') == "L4_VALOR" .Or. StrTran(Alltrim(ReadVar()),'M->','') == "L4_NVPARC" 
	If StrTran(Alltrim(ReadVar()),'M->','') == "L4_VALOR" 
		//Valida se o valor informado � maior que o original
		If &(StrTran(Alltrim(ReadVar()),'M->','')) >= oGetCards:aCols[oGetCards:nAt][nPosVlrPgt]
			MsgInfo(STR0037,STR0027)	//"Valor informado maior ou igual que o valor original do pagamento, favor verificar!"/"Aten��o"
			lRet := .F.
		Else
			cFormaOri := oGetCards:aCols[oGetCards:nAt][nPosForOld]
			cFormaNew := oGetCards:aCols[oGetCards:nAt][nPosForma]
			cIdCardOld := oGetCards:aCols[oGetCards:nAt][nPosOldID]
			For nCont := 1 To Len(oGetCards:aCols)
				If oGetCards:aCols[nCont][nPosForOld] == cFormaOri .And. oGetCards:aCols[nCont][nPosForma] == cFormaNew .And. oGetCards:aCols[nCont][nPosOldID] == cIdCardOld
					If nCont == oGetCards:nAt
						nVlrTot+= &(StrTran(Alltrim(ReadVar()),'M->',''))
					Else	
						nVlrTot+= oGetCards:aCols[nCont][nPosValor]
					EndIf
				EndIf
			Next nCont
						
			If nVlrTot > oGetCards:aCols[oGetCards:nAt][nPosVlrPgt]
				MsgInfo(STR0038,STR0027) //"Valor informado maior que o valor original do pagamento, favor verificar!"/"Aten��o"	
				lRet := .F.
			EndIf
		EndIf
	ElseIf StrTran(Alltrim(ReadVar()),'M->','') == "L4_NVPARC"
		//Valida se a parcela informada � maior que o original
		If &(StrTran(Alltrim(ReadVar()),'M->','')) > Iif(SubStr(oGetCards:aCols[oGetCards:nAt][nPosForOld],1,2) == "R$", 1, Val(oGetCards:aCols[oGetCards:nAt][nPosParcPgt]))
			MsgInfo(STR0039,STR0027) ///"Aten��o"	
			lRet := .F.
		EndIf
	EndIf
EndIf
oGetPagtos:Refresh()
Return lRet

//------------------------------------------------------------------------------
/*{Protheus.doc} STIClearCard
Fun��o para limpar as formas de pagamentos definidos na tela de Cart�es
@param   	     
@author     F�bio Siqueira dos Santos
@version    P12
@since      11/07/2018
@return     Nil
/*/
//------------------------------------------------------------------------------
Function STIClearCard()
Local nCont		:= 0
Local nPosValor	:= aScan(oGetCards:aHeader,{ |x| AllTrim(x[2]) == "L4_VALOR"} )
Local nPosNvParc:= aScan(oGetCards:aHeader,{ |x| AllTrim(x[2]) == "L4_NVPARC"} )

For nCont := 1 To Len(oGetCards:aCols)
	oGetCards:aCols[nCont][nPosValor]	:= 0
	oGetCards:aCols[nCont][nPosNvParc]	:= 0
Next nCont
oGetCards:Refresh()
Return Nil