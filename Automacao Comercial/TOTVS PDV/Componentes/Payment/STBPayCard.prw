#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STBPAYCARD.CH"

Static oRetTef	:= Nil
Static aIDTEF	:= {'0','0'}	//[1]ID Cart�o Cr�dito(CC) [2]ID Cart�o D�bito(CD)

//-------------------------------------------------------------------
/*/{Protheus.doc} STBRetTef
Valida a transacao

@param   	oRetTran - Objeto de retorno da transacao TEF
@param   	oTEF20 - Objeto TEF
@author  	Varejo
@version 	P11.8
@since   	20/02/2013
@return  	lRet - Retorna se validou a transacao
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STBRetTef( oRetTran, oTEF20 )   
  
Local nPosAdmin	:= 1	// Posicao da administradora
Local lRetAux	:= .F.
Local lRet		:= .T.	// TODO: se .F., desfaz a transacao TEF
Local aAdmSel	:= {}	// Administradora financeira selecionada manualmente
Local aAuxAdmin	:= {}	// Administradoras financeiras filtradas pela forma de pagamento
Local aAdminDesc:= {}	// Administradoras financeiras selecionadas com base em duas descricao
Local aAdmin	:= {}
Local lSelAdm	:= ExistFunc("STICrdSlAdm")
Local cFirst	:= STFGetCfg("cIntegration", "DEFAULT")
Local lFirst	:= .F.
Local nParcs	:= 1
Local nAdmRet	:= 0	//quantidade adm fin retornadas automaticamente
Local nI		:= 0	//contador
Local nTamAECOD := TamSX3("AE_COD")[1]
Local nTamL4ADM := TamSX3("L4_ADMINIS")[1]

Default oRetTran:= Nil
Default oTEF20	:= Nil

LjGrvLog(Nil, "Transa��o TEF bem sucedida: ", oRetTran:oRetorno:lTransOk)

//se a transa��o TEF foi bem sucedida
If oRetTran:oRetorno:lTransOk                                                       
	
	//Alimenta o atributo da Administradora Financeira, seja retornada automaticamente ou selecionada pelo usu�rio.
	STBGetAdmF(oRetTran, oTEF20)

	If ExistFunc("IsPDOrPix") .AND. IsPDOrPix(oRetTran:cFormaPgto)
		oTEF20:Cupom():Inserir(	"V"	,;
								oRetTran:oRetorno:oViaCaixa,; 
								oRetTran:oRetorno:oViaCliente,; 
								"D",;
								oTEF20:PgtoDigital():GetTotalizador(),; 
								oTEF20:PgtoDigital():GetFormaPgto(oRetTran, oTEF20:Formas()),;
								oRetTran:nValor,; 
								1,;
								0,;
								oRetTran:oRetorno:nVlrSaque,;
								oRetTran:oRetorno:nVlrVndcDesc,;
								oRetTran:oRetorno:nVlrDescTEF )
	Else
		
		oTEF20:Cupom():Inserir(	"V"	,;
								oRetTran:oRetorno:oViaCaixa,; 
								oRetTran:oRetorno:oViaCliente,; 
								"C",;
								oTEF20:Cartao():GetTotalizador(),; 
								oTEF20:Cartao():GetFormaPgto(oRetTran, oTEF20:Formas()),;
								oRetTran:nValor,; 
								1,;
								0,;
								oRetTran:oRetorno:nVlrSaque,;
								oRetTran:oRetorno:nVlrVndcDesc,;
								oRetTran:oRetorno:nVlrDescTEF )
	EndIf 

   	lRet 		:= .T.
	oRetTef 	:= oRetTran:oRetorno
	If ExistFunc("STIBlqTlTef")
		STIBlqTlTef()
	EndIf
	
Else
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetRetTef
Faz o retorno das variaveis do TEF

@param   	
@author  	Varejo
@version 	P11.8
@since   	20/02/2013
@return  	oRetTef - Retorno do TEF com a transacao
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetRetTef()
Return oRetTef


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetRetTef
Limpa o array de retorno do TEF

@param   	lCancTrs - Cancela a transacoa TEF
@author  	Varejo
@version 	P11.8
@since   	20/02/2013
@return  lRet - Retorna se executou corretamente  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetRetTef(lCancTrs)

Local oTEF20			:= Nil									// Objeto TEF

Default lCancTrs := .F.

/*/
	Se cancelar a transa��o, Desfaz Transa��o TEF
/*/
If lCancTrs
	oTEF20 := STBGetTef()
	If ValType(oTEF20) == 'O'
		oTEF20:Desfazer()   
	EndIf
EndIf	

If oRetTef <> Nil
	// -- N�o utilizar FreeObj, o FreeObj limparar o conteudo da unidade de memoria, porem neste exemplo precisamos limpar apenas da variavel oRetTef removendo a refencia da variavel. 
	oRetTef := Nil
EndIf

Return .T.


//------------------------------------------------------------
/*/{Protheus.doc} STBSetIdTF
Controla os contadores dos IDs de cart�es,
alimentando o array estatico aIDTEF

@param   	cTipoTEF - tipo do cart�o (CC/CD)
@author  	Varejo
@version 	P11.8
@since   	11/08/2015
@return  	Nil  	
@obs     	Se passar cTipoTEF em branco, ele reseta todos IDs
/*/
//------------------------------------------------------------
Function STBSetIdTF(cTipoTEF)

Default cTipoTEF := ""

If cTipoTEF == "CC"
	aIDTEF[1] = SOMA1(cValToChar(aIDTEF[1])) 
ElseIf cTipoTEF == "CD"
	aIDTEF[2] = SOMA1(cValToChar(aIDTEF[2])) 
Else
	aIDTEF[1] := '0'
	aIDTEF[2] := '0'
EndIf

Return Nil


//-------------------------------------------------
/*/{Protheus.doc} STBGetIdTF
Retorna o ID atual do tipo de cart�o requisitado

@param   	cTipoTEF - tipo do cart�o (CC/CD)
@author  	Varejo
@version 	P11.8
@since   	11/08/2015
@return  	cIDTEF - ID atual do Cart�o  	

/*/
//-------------------------------------------------
Function STBGetIdTF(cTipoTEF)

Local cIDTEF := '0'

Default cTipoTEF := ""

If cTipoTEF == "CC"
	cIDTEF := aIDTEF[1]
ElseIf cTipoTEF == "CD"
	cIDTEF := aIDTEF[2]
EndIf

Return cIDTEF


//----------------------------------------------------------------------
/*/{Protheus.doc} STBGetAdmF
Alimenta o atributo da Administradora Financeira, seja retornada automaticamente ou selecionada pelo usu�rio.

@author  Alberto Deviciente
@since   20/11/2020
@version P12

@param 	 oRetTran, Objeto, Objeto com informa��es do retorno da transa��o TEF.
@param 	 oTEF20	 , Objeto, Objeto do TEF 2.0.

@return  Nil, Nulo
/*/
//----------------------------------------------------------------------
Function STBGetAdmF(oRetTran, oTEF20)
Local nAdmRet	:= 0
Local nI		:= 0
Local lRetAux	:= .F.
Local aAdmin	:= {}
Local aAuxAdmin	:= {}						//Administradoras financeiras filtradas pela forma de pagamento
Local nParcs	:= 1
Local nPosAdmin	:= 1
Local aAdminDesc:= {}						//Administradoras financeiras selecionadas com base em duas descricao
Local cFirst	:= STFGetCfg("cIntegration", "DEFAULT")
Local lFirst	:= ValType(cFirst) = "C" .AND. cFirst == "FIRST"
Local lSelAdm	:= !lFirst 					//Integra��o com o FIRST n�o necessita de adm financeira
Local aAdmSel	:= {}						//Administradora financeira selecionada manualmente
Local nTamAECOD := TamSX3("AE_COD")[1]
Local nTamL4ADM := TamSX3("L4_ADMINIS")[1]
Local aAdmsSelec:= {} 						//Lista com as Adm. Financeiras para apresentar na tela para sele��o manual

//Quantidade de Administradoras Financeiras retornadas de forma automatica
nAdmRet := Len(oRetTran:oRetorno:aAdmin)

/*
Se foi retornada uma UNICA administradora, houve sucesso na obten��o automatica,
j� se NENHUMA ou MAIS DE UMA administradora foi retornada, a administradora deve ser selecionada manualmente.
*/
If nAdmRet == 1

	oRetTran:oRetorno:cAdmFin := PadR( PadR(oRetTran:oRetorno:aAdmin[1][1], nTamAECOD) + " - " + oRetTran:oRetorno:aAdmin[1][7], nTamL4ADM )
	lRetAux := .T.
	
	LjGrvLog(Nil, "Adm.Fin. retornada automaticamente: ", oRetTran:oRetorno:cAdmFin)

Else

	If nAdmRet == 0
	
		LjGrvLog(Nil, "Nenhuma Adm.Fin. foi retornada")
		
		//obtemos todas as administradoras financeiras cadastradas
		aAdmin := aClone( oTEF20:Administradoras() )
		
		//filtramos as Administradora pela forma de pagamento da transa��o TEF
		For nI := 1 to Len(aAdmin)
			If AllTrim(aAdmin[nI][2]) == AllTrim(oRetTran:cFormaPgto)
				aAdd( aAuxAdmin, aAdmin[nI] )
			EndIf
		Next

	ElseIf nAdmRet > 1
		LjGrvLog(Nil, "Foi retornado mais de uma Adm.Fin.: ", oRetTran:oRetorno:aAdmin)
		
		//obtemos somente as administradoras retornadas automaticamente
		aAuxAdmin := oRetTran:oRetorno:aAdmin
	EndIf

	/*
	Buscamos a Adm.Fin. comparando sua descri��o [AE_DESC ou MDE_DESC(se AE_ADMCART estiver preenchida)]
	com a descri��o da bandeira obtida pelo HashTable do LOJA1926.
	Caso nenhuma administradora seja encontrado, a administradora (L4_ADMINIS) ter� como prefixo a string "TEF: ", 
	assim essa venda n�o ser� processada pelo LjGrvBatch, at� que esse campo seja ajustado (AE_COD + ' - ' + AE_DESC')
	*/
	If !lRetAux .AND. Len(aAuxAdmin) > 0
		
		//
		//Sele��o da Administradora Financeira pela Descricao da Bandeira
		//
		LjGrvLog(Nil, "Busca pela Adm.Fin. usando a descri��o da bandeira", oRetTran:oRetorno:cAdmFin)

		If oRetTran:oRetorno:nParcs > 0
			nParcs := oRetTran:oRetorno:nParcs
		EndIf
		LjGrvLog(Nil, "Quantidade de Parcelas: ", nParcs )

		/*
		Para os casos onde a busca pela administradora financeira nao foi feita pelo MDE_CODSIT,
		a busca ser� feita comparando a descri��o da bandeira retornada com MDE_DESC(se AE_ADMCART prenchida)/AE_DESC,
		al�m de comparar se a parcela retornada esta no range de parcelas configurada da administrada
		*/
		While nPosAdmin > 0
			nPosAdmin := Ascan( aAuxAdmin, {|x| oRetTran:oRetorno:cAdmFin $ x[7] .AND. (nParcs >= x[4] .AND. nParcs <= x[5])}, nPosAdmin )		
			If nPosAdmin > 0
				Aadd( aAdminDesc, aAuxAdmin[nPosAdmin] )
				nPosAdmin++
			EndIf
		EndDo
		
		If Len(aAdminDesc) == 1
			oRetTran:oRetorno:cAdmFin := PadR( PadR(aAdminDesc[1][1], nTamAECOD) + " - " + aAdminDesc[1][7], nTamL4ADM )
			lRetAux := .T.

			LjGrvLog(Nil, "Adm.Fin. retornada automaticamente pela descri��o da bandeira: ", oRetTran:oRetorno:cAdmFin)
		ElseIf Len(aAdminDesc) == 0
			LjGrvLog( Nil, "Adm.Fin. nao encontrada ou as parcelas configuradas nao condizem com a retornada" )
		Else
			//filtramos pelas administradoras que tem a mesma descricao, para que o usuario possa selecionar uma delas
			aAuxAdmin := aClone( aAdminDesc )

			LjGrvLog( Nil, "Retornado mais de uma Adm. Fin com a mesma descri��o (AE_DESC/MDE_DESC)", aAdminDesc )
		EndIf


		//
		//Sele��o Manual da Administradora Financeira
		//
		LjGrvLog(Nil, "Escolha manual da Adm.Fin.: ", lSelAdm )

		If !lRetAux .AND. lSelAdm

			//-----------------------------------------------------------------------------------------------------
			// Abre a tela para Sele��o da administradora Financeira, caso n�o tenha identificado automaticamente.
			//-----------------------------------------------------------------------------------------------------
			If nModulo == 23 //SIGAFRT (Totvs PDV)
				aAdmSel := STICrdSlAdm( aAuxAdmin, oRetTran:nValor, oRetTran:cAdmFin )
			Else
				//SIGALOJA (Venda Assistida) / SIGAFAT (Venda Direta)
				If ExistFunc("FRgTelaSAE")
					For nI:=1 To Len(aAuxAdmin)
						//Constroi o array no formato que a fun��o FRgTelaSAE est� esperando
						aAdd( aAdmsSelec,  {.F., aAuxAdmin[nI][2], aAuxAdmin[nI][3]} )
					Next nI
					nPosAdmin := FRgTelaSAE(aAdmsSelec,oRetTran:cAdmFin,.T.,oRetTran:cIdPagto)
					aAdmSel := aClone( { aAuxAdmin[nPosAdmin] } )
				EndIf
			EndIf

			If Len(aAdmSel) == 1
				oRetTran:oRetorno:aAdmin := aClone(aAdmSel)
				oRetTran:oRetorno:cAdmFin := PadR( PadR(aAdmSel[1][1], nTamAECOD) + " - " + aAdmSel[1][7], nTamL4ADM )
				
				lRetAux := .T.

				LjGrvLog(Nil, "Adm.Fin. escolhida: ", aAdmSel[1][3])
			Else
				LjGrvLog(Nil, "Nenhuma Adm.Fin. escolhida" )
			EndIf

		EndIf
		
		If !lRetAux
			oRetTran:oRetorno:cAdmFin := "TEF: " + oRetTran:oRetorno:cAdmFin

			LjGrvLog(Nil, "Nenhuma Adm.Fin. foi utilizada, portanto sera gravado TEF: + descri��o, para que a venda possa ser ajustada")
		EndIf

	Else
		oRetTran:oRetorno:cAdmFin := "TEF: " + oRetTran:oRetorno:cAdmFin

		LjGrvLog(Nil, "Nenhuma Adm.Fin. disponivel para busca, portanto sera gravado TEF: + descri��o, para que a venda possa ser ajustada")
	EndIf

EndIf

Return

/*/{Protheus.doc} STBCalcJur
Atualiza valores de taxa da Adm Financiera caso exista

@type  Function
@author joao.marcos
@since 08/06/2021
@version V12
@param nil	
@return nil
/*/
Function STBCalcJur()
Local aJurosAdm	:=  STIGetAJur() // Dados do juros da Adm Fin
Local lMVLJJURCC	:= SuperGetMV( "MV_LJJURCC",,.F. ) // calcula juros da Adm financeira

If lMVLJJURCC
	STWAddIncrease(aJurosAdm[4],aJurosAdm[3])
Endif

Return

/*/{Protheus.doc} STBCalcTax
Calcula valores de taxa da Adm Financiera caso exista

@type  Function
@author joao.marcos
@since 08/06/2021
@version V12
@param	cCodAdmin	, character	, c�digo da Adm Financeira
		nParc	 	, numeric	, numero da parcela
		nValCC		, numeric 	, valor da forma de pagamento
		nVlJuroAdm	, numeric 	, valor dos juros, para ser� atualizado na tela
@return
/*/
Function STBCalcTax(cCodAdmin, nParc, nValCC, nVlJuroAdm )
Local aValTax		:= {} // Valores das taxas
Local lMVLJJURCC	:= SuperGetMV( "MV_LJJURCC",,.F. ) // calcula juros da Adm financeira

Default cCodAdmin	:= ""
Default nParc		:= 1
Default nValCC		:= 0

/*
aValTax[1] -> Taxa de Juros
aValTax[2] -> Valor dos Juros COM Imposto nTxVal  //Valor do Juros COM Imposto
aValTax[3] -> Taxa da Adm Fin
aValTax[4] -> Valor do Juros SEM Imposto, no caso de ( LOCALIZACAO <> Brasil)
*/

If lMVLJJURCC .AND. !Empty(nValCC) .AND. !Empty(cCodAdmin)

	cCodAdmin := SubStr( cCodAdmin, 1, TamSX3("AE_COD")[1] )

	nValCC:=StrTran(IIf(ValType(nValCC)<>"C", Str(nValCC),nValCC),".",",")
	
	aValTax := LJ7_TxAdm( cCodAdmin, nParc, nValCC )

	nVlJuroAdm :=  aValTax[2]

	If nVlJuroAdm > 0
		STISetAJur({.T.,cCodAdmin,aValTax[1],aValTax[2]})
	Else
		STISetAJur({.F.,"",0,0})
	EndIf

EndIf	

Return
