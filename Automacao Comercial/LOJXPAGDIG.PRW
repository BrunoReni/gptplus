#INCLUDE "TOTVS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "LOJXPAGDIG.CH"

/*/{Protheus.doc} LjPgtoDig
Processa transa��es de Pagamentos Digitais da venda.

@type 	 Function
@author  Alberto Deviciente
@since 	 28/10/2020
@version 12.1.27

@param lTemPagDig, L�gico, Par�metro por refer�ncia: Indica se na venda tem Pagamento Digital.
@param aPgtoDigit, Array, Par�metro por refer�ncia: Array onde ser� guardadas as informa��es do Pagamento Digital processado.

@return lRet, L�gico, Indica se processou os pagamentos digitais da venda com sucesso.
/*/
Function LjPgtoDig(lTemPagDig, aPgtoDigit)
Local lRet 		:= .F.
Local nValor 	:= 0
Local nQtdParcel:= 0
Local nI		:= 0
Local nPos 		:= 0
Local cAdmFin	:= ""
Local oDados    := Nil			//Dados para a transacao de pagamentos digitais
Local oTEF20    := STBGetTEF()
Local nInd 		:= 0
Local cIdPagto	:= ""
Local oRetTran	:= Nil
Local cDataTrans:= ""
Local cHoraTrans:= ""
Local cFormPgto := ""
Local cTotaliz	:= GetPvProfString("Comprovante TEF", "Totalizador", "01", GetClientDir()+"SIGALOJA.INI")

LjGrvLog(Nil, "Processamento da transa��o de Pagamento Digital da venda. Inicio",,,.T. ) 

aPgtoDigit := {}

For nI := 1 To Len(aPgtosSint)
	If AllTrim(aPgtosSint[nI][1]) $ _FORMATPD
		lTemPagDig := .T.

		//Verifica o valor a ser enviada para processamento
		nPos 		:= Ascan(aPgtos,{|x| AllTrim(x[3])+AllTrim(x[8]) == AllTrim(aPgtosSint[nI][1])+AllTrim(aPgtosSint[nI][4]) } )
		nValor 		:= aPgtos[nPos][2]
		nQtdParcel 	:= aPgtosSint[nI][2]
		cIdPagto 	:= aPgtosSint[nI][4]

		If Len(aPgtosSint[nI]) > 5 .AND. Len(aPgtosSint[nI][6]) > 4
			cAdmFin := aPgtosSint[nI][6][5]
		Else
			cAdmFin := ""
		EndIf

		If ValType(oTEF20) <> "O"
			lRet := .F.
			Exit
		EndIf
	
		oDados		:= LJDadosTransacaoPgtoDigitais():New(nValor, AllTrim(aPgtosSint[nI][1]) , nQtdParcel, 14, cIdPagto )

		oRetTran 	:= oTEF20:PgtoDigital():Digitais(oDados)

		LjGrvLog(Nil, "Processamento da transa��o de Pagamento Digital da venda. Dados da transa��o:", oDados,,.T.)
		LjGrvLog(Nil, " :", oRetTran:oRetorno:lTransOk,,.T.)
		LjGrvLog(Nil, "Processamento da transa��o de Pagamento Digital da venda. Dados do Retorno da transa��o:", oRetTran,,.T.)

		If oRetTran:oRetorno:lTransOk

			lRet := .T.

			//Alimenta o atributo da Administradora Financeira, seja retornada automaticamente ou selecionada pelo usu�rio.
			STBGetAdmF(oRetTran, oTEF20)

			//Descricao da condicao de pagamento a ser impressa no Comprovante
			cFormPgto := AllTrim(Upper(RetDescri(oRetTran:cFormaPgto)))

			oTEF20:Cupom():Inserir(	"V"	,;
									oRetTran:oRetorno:oViaCaixa,; 
									oRetTran:oRetorno:oViaCliente,; 
									"C",;
									cTotaliz,; 
									cFormPgto,;
									oRetTran:nValor,; 
									1,;
									0,;
									oRetTran:oRetorno:nVlrSaque,;
									oRetTran:oRetorno:nVlrVndcDesc,;
									oRetTran:oRetorno:nVlrDescTEF )

			AAdd( aPgtoDigit, {} )

			nInd := Len(aPgtoDigit)

			If ValType(oRetTran:oRetorno:DDATA) == "D"
				cDataTrans := DTOS(oRetTran:oRetorno:DDATA)
			Else
				oRetTran:oRetorno:DDATA := StrTran(oRetTran:oRetorno:DDATA, "/")
				If Left(oRetTran:oRetorno:DDATA,4)  == Str(Year(Date()),4)
					cDataTrans := oRetTran:oRetorno:DDATA
				Else
					cDataTrans := Right(oRetTran:oRetorno:DDATA,4) + Substr(oRetTran:oRetorno:DDATA,3,2)+ Left(oRetTran:oRetorno:DDATA,2)
				EndIf
			EndIf

			If !Empty(oRetTran:oRetorno:cAdmFin)
				aPgtos[nPos][4][05] := oRetTran:oRetorno:cAdmFin //Atualiza a Administradora Financeira retornada da transa��o
			EndIf

			cHoraTrans := Replace(oRetTran:oRetorno:CHORA,":","")

			aAdd( aPgtoDigit[nInd], { "FORMAID" , cIdPagto  					} )
			aAdd( aPgtoDigit[nInd], { "DATATEF" , cDataTrans		    		} )
			aAdd( aPgtoDigit[nInd], { "HORATEF" , cHoraTrans					} )
			aAdd( aPgtoDigit[nInd], { "DOCTEF"  , oRetTran:oRetorno:CNSUAUTOR	} )				
			aAdd( aPgtoDigit[nInd], { "AUTORIZ" , oRetTran:oRetorno:CAUTORIZ	} )
			aAdd( aPgtoDigit[nInd], { "INSTITU" , oRetTran:oRetorno:CREDE 		} )
			aAdd( aPgtoDigit[nInd], { "NSUTEF"  , oRetTran:oRetorno:CNSU		} )
			aAdd( aPgtoDigit[nInd], { "ADMINIS" , oRetTran:oRetorno:cAdmFin		} )
			aAdd( aPgtoDigit[nInd], { "BANDEIR" , oRetTran:oRetorno:cCodBand	} )
			AAdd( aPgtoDigit[nInd], { "REDEAUT" , oRetTran:oRetorno:cTipCart 	} )
			AAdd( aPgtoDigit[nInd], { "NOMECLI" , PadR( "RD: " + Alltrim(oRetTran:oRetorno:CREDE) + " / BD: " + Alltrim(oRetTran:oRetorno:cAdmFin), TamSX3("L4_NOMECLI")[1]) } )
			
			//Sempre limpa os campos de cancelamento da transa��o, pois pode ter ocorrido cancelamento das transa��es da venda e o or�amento pode ter sido finalizado novamente.
			aAdd( aPgtoDigit[nInd], { "DOCCANC" , ""	} )
			aAdd( aPgtoDigit[nInd], { "DATCANC" , ""	} )
			aAdd( aPgtoDigit[nInd], { "HORCANC" , ""	} )

			If SL4->(ColumnPos("L4_TRNID")) > 0 .And. AttIsMemberOf(oRetTran:oRetorno, "cExternalTransactionId", .T.) //Verifica se existe o campo e o Atributo da classe LJARetTransacaoTef (LOJA1934)
				aAdd( aPgtoDigit[nInd], { "TRNID" , oRetTran:oRetorno:cIdtransaction	        	} )
			EndIf
			If SL4->(ColumnPos("L4_TRNPCID")) > 0 .And. AttIsMemberOf(oRetTran:oRetorno, "cProcessorTransactionId", .T.) //Verifica se existe o campo e o Atributo da classe LJARetTransacaoTef (LOJA1934)
				aAdd( aPgtoDigit[nInd], { "TRNPCID" , oRetTran:oRetorno:cProcessorTransactionId	} )
			EndIf
			If SL4->(ColumnPos("L4_TRNEXID")) > 0 .And. AttIsMemberOf(oRetTran:oRetorno, "cExternalTransactionId", .T.) //Verifica se existe o campo e o Atributo da classe LJARetTransacaoTef (LOJA1934)
				aAdd( aPgtoDigit[nInd], { "TRNEXID" , oRetTran:oRetorno:cExternalTransactionId	} )
			EndIf

		Else
			lRet := .F.
			Exit
		EndIf

	EndIf
Next nI

If lTemPagDig
	If lRet
		//Grava na SL4 os dados da transa��o de Pagamento Digital.
		If !lRecebe //Somente grava se n�o for Recebimento de T�tulo (LOJXREC), pois s� tem SL4 qdo. for uma venda
			LjGrvPagDg(aPgtoDigit)
		EndIf
	Else
		LjGrvLog(Nil, "Desfaz transa��o de Pagamento Digital da venda.",,,.T.)
		//Desfaz Transa��es do TEF 2.0
		oTEF20:Desfazer()
	EndIf
EndIf

LjGrvLog(Nil, "Processamento da transa��o de Pagamento Digital da venda. Fim do processo", lRet,,.T. ) 

Return lRet

/*/{Protheus.doc} LjGrvPagDg
Grava dados da Transa��o de Pagamento Digital.

@type 	 Function
@author  Alberto Deviciente
@since 	 28/10/2020
@version 12.1.27
@param	aPgtoDigit, array, dados do pagamentos digital

@return Nil, Nulo
/*/
Function LjGrvPagDg(aPgtoDigit)
Local nX  		:= 0
Local nPosPD	:= 0
Local cCampo 	:= ""
Local uConteudo	:= Nil

If Len(aPgtoDigit) > 0 .And. !lRecebe //Somente grava se n�o for Recebimento de T�tulo (LOJXREC), pois s� tem SL4 qdo. for uma venda

	//Grava na SL4 as informa��es retornadas do Pagamento Digital
	nX := 1
	DbSelectArea( "SL4" )
	SL4->(DbSetOrder( 1 )) //L4_FILIAL+L4_NUM+L4_ORIGEM
	If SL4->(DbSeek( xFilial( "SL4" ) + SL1->L1_NUM ))
		
		LjGrvLog(SL1->L1_NUM, "Grava na SL4 os dados da Transa��o de Pagamento Digital.", aPgtoDigit,,.T.)
		
		While !SL4->(EOF()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + SL1->L1_NUM
			If AllTrim(SL4->L4_FORMA) $ _FORMATPD
				nPosPD := aScan(aPgtoDigit, {|x| AllTrim(x[1,2]) == AllTrim(SL4->L4_FORMAID) })
				If nPosPD > 0
					RecLock("SL4", .F.)
					For nX:=1 To Len(aPgtoDigit[nPosPD])
						cCampo 		:= "SL4->L4_" + aPgtoDigit[nPosPD][nX][1]
						uConteudo	:= aPgtoDigit[nPosPD][nX][2]
						&(cCampo) 	:= uConteudo
					Next nX
					SL4->(MsUnLock())
				EndIf
			EndIf
			SL4->(DbSkip())
			nX ++
		End
	EndIf
EndIf

Return

/*/{Protheus.doc} LjImprimPD
Imprime comprovante de Pagamento Digital.

@type 	 Function
@author  Alberto Deviciente
@since 	 28/10/2020
@version 12.1.27

@return lRet, L�gico, Indica se imprimiu com sucesso o comprovante de pagamento digitai da venda.
/*/
Function LjImprimPD()
Local lRet 		:= .T.
Local oTEF20    := Nil
Local lImpComp	:= .F.	// Impressao do comprovante

oTEF20 := STBGetTEF()

//Imprime o comprovante
If ValType(oTEF20) == "O"

	LjGrvLog(Nil, "Imprime comprovante de Pagamento Digital.",,,.T.)

	lImpComp := oTEF20:Cupom():Imprimir(  /*lRelGer*/, /*lSTDSatRecovery*/, /*lPagDigPix*/ .T. )

	If !lImpComp
		LjGrvLog(Nil, "Falha na impressao do comprovante oe Pagamento Digital.",,,.T.)
		If !Isblind()
			MsgInfo(STR0015 + CHR(10)+CHR(13) + STR0016,STR0014)
		EndIf
		lImpComp := .T.
	EndIf

	If lImpComp
		//Confirma a transacao
		oTEF20:Confirmar()
		LjGrvLog(Nil, "Confirma a transa��o do Pagamento Digital.",,,.T.)
	Else
		//Se necessario, cancela a transacao
		lRet := .F.

		oTEF20:Desfazer()
		LjGrvLog(Nil, "Desfaz a transa��o do Pagamento Digital.",,,.T.)
		Alert(STR0001) //"Transa��o n�o foi efetuada. Favor reter o cupom."
	EndIf

	LjGrvLog(Nil, "Retorno da impress�o do comprovante de Pagamento Digital.", lRet,,.T.)
EndIf

Return lRet

/*/{Protheus.doc} LjImpPDNFis
Imprime comprovante de Pagamento Digital em Impressora N�o-Fiscal.

@type 	 Function
@author  Alberto Deviciente
@since 	 28/10/2020
@version 12.1.27

@param cTexto, Caractere, Texto a ser impresso na impressora.

@return lRet, L�gico, Indica se imprimiu com sucesso.
/*/
Function LjImpPDNFis(cTexto)
Local lRet 			:= .T.
Local lContinua 	:= .T.
Local nRetImp 		:= 0

LjGrvLog(Nil, "Imprime comprovante de Pagamento Digital em impressora n�o-fiscal.",,,.T.)

While lContinua
	nRetImp := INFTexto(cTexto)	
	
	If nRetImp < 0
		If MsgYesNo(STR0002, STR0003 ) //"Deseja imprimir novamente?"###"Aten��o"
			Sleep(1000)
			Loop
		Else			
			lRet := .F.
			lContinua := .F.
		EndIf
	Else
		lContinua := .F.
	EndIf
End

LjGrvLog(Nil, "Retorno da impress�o do comprovante de Pagamento Digital em impressora n�o-fiscal.", lRet,,.T.)

Return lRet

/*/{Protheus.doc} LjImpPDFis
Imprime comprovante de Pagamento Digital em Impressora Fiscal.

@type 	 Function
@author  Alberto Deviciente
@since 	 28/10/2020
@version 12.1.27

@param cTexto, Caractere, Texto a ser impresso na impressora.

@return lRet, L�gico, Indica se imprimiu com sucesso.
/*/
Function LjImpPDFis(cTexto, nValor, cFormaPgto, cTotalizad, lRelGer )
Local lRet 			:= .T.
Local lContinua 	:= .T.
Local nRetImp 		:= 0
Local nVias			:= 1

If Type("lRecebe") == "L" .And. lRecebe //Se for Recebimento de Titulo, troca a Forma de Pagamento para que seja impresso o comprovante vinculado de Cr�dito/D�bito
	cFormaPgto := &(SuperGetMV("MV_NATRECE"))
EndIf

LjGrvLog(Nil, "Imprime comprovante de Pagamento Digital em Impressora Fiscal.",,,.T.)

While lContinua

	If lRelGer
		//Imprime o texto do comprovante
		nRetImp := IFTxtNFis( nHdlECF, cTexto, nVias, , lRelGer )
	Else
		//Faz a abertura do comprovante de CREDITO e DEBITO
		nRetImp := IFAbrCNFis( nHdlECF, cFormaPgto , Str(nValor,14,2) , cTotalizad, cTexto )

		//Imprime o texto do comprovante
		nRetImp := IFTxtNFis( nHdlECF, cTexto, nVias )

		//Fecha o comprovante
		nRetImp := IFFchCNFis( nHdlECF )
	EndIf
	
	If nRetImp < 0
		If MsgYesNo(STR0002, STR0003 ) //"Deseja imprimir novamente?"###"Aten��o"
			Sleep(1000)
			Loop
		Else			
			lRet := .F.
			lContinua := .F.
		EndIf
	Else
		lContinua := .F.
	EndIf
End

LjGrvLog(Nil, "Retorno da impress�o do comprovante de Pagamento Digital em Impressora Fiscal.", lRet,,.T.)

Return lRet

/*/{Protheus.doc} LjTefAdmPD
Fun��o Administrativa do TEF para Pagamentos Digitais.

@type 	 Function
@author  Alberto Deviciente
@since 	 11/11/2020
@version 12.1.27

@return lRet, L�gico, Indica se imprimiu com sucesso.
/*/
Function LjTefAdmPD()
Local lRet			:= .F.
Local oTEF20		:= STBGetTEF()
Local oRetTran		:= Nil
Local oDados 		:= Nil
Local aDadosTran 	:= {}
Local aDadosCanc	:= {}
Local lRelGerECF	:= IIF(ISBLIND(),.F.,Lj121IsFisc(LjGetStation("LG_IMPFISC"))) //Verifica se � impressora fiscal, relat�rio Gerencial
Local lGerencial	:= FWIsInCallStack("LJRotTEF")

LjGrvLog(Nil, "INICIO - Acessada a rotina de fun��es Administrativas do Totvs Pagamento Digital.",,,.T.)

//Verifica se o TEF 2.0 est� ativo e se a opera��o de Pagamento Digital tbm est� ativa
If oTEF20 <> Nil .AND. STWChkTef("PD") //Verifica se esta��o esta configurada para operar transa��es de Pagamentos Digitais

	oDados := LJCDadosTransacaoADM():New(0,0, Date(), Time(), .T.) 

	LjGrvLog(Nil, "Abrindo a rotina de fun��es Administrativas do Totvs Pagamento Digital.",,,.T.)

	oRetTran := oTEF20:PgtoDigital():FuncoesAdm(oDados,@aDadosTran)

	LjGrvLog(Nil, "Dados da transa��o Administrativa do Totvs Pagamento Digital."	, aDadosTran				,,.T.)
	LjGrvLog(Nil, "Retorno da fun��o Administrativa do Totvs Pagamento Digital."	, oRetTran					,,.T.)
	LjGrvLog(Nil, "Retorno da transa��o Administrativa do Totvs Pagamento Digital."	, oRetTran:oRetorno:lTransOk,,.T.)
	/*
	Estrutura do array aDadosTran retornado por refer�ncia:
		01-DOCTEF da transa��o
		02-Valor Total da transa��o
		03-ID da Transa��o
		04-ID Transa��o Processador
		05-ID da Transa��o Externa
		06-Data da Transa��o
		07-Forma de Pagamento
		08-Recnos da SL4 relacionados a transa��o
	*/

	If oRetTran:oRetorno:lTransOk
		oTEF20:Cupom():Inserir("G"	,	oRetTran:oRetorno:oViaCaixa	, oRetTran:oRetorno:oViaCliente	, "A"	,;
								""	,		""						, oRetTran:nValor				, 1		,;
								0	)

		LjGrvLog(Nil, "Efetua a impress�o referente a transa��o Administrativa do Totvs Pagamento Digital.",,,.T.)

		If oTEF20:Cupom():Imprimir(( lRelGerECF .AND. lGerencial ))
			//Se a impressao for OK, confirma a transacao
			oTEF20:Confirmar()
			LjGrvLog(Nil, "Confirma a transa��o Administrativa do Totvs Pagamento Digital.",,,.T.)
			lRet := .T.
		Else
			//Para transacoes administrativas de cancelamento tem q reimprimir o ultimo
			//comprovante em caso de erro de impressao e confirmar a transacao mesmo com erro de impressao.
			If !Empty(oRetTran:oRetorno:cDocCanc)
				oTEF20:Confirmar()
				LjGrvLog(Nil, "Confirma a transa��o Administrativa do Totvs Pagamento Digital.",,,.T.)
				Alert( STR0004 ) // "Transa��o confirma. Favor reimprimir �ltimo comprovante."
				lRet := .T.
			Else
				LjGrvLog(Nil, "Desfazendo a transa��o Administrativa do Totvs Pagamento Digital.",,,.T.)
				oTEF20:Desfazer()
				Alert(STR0005) // "Transa��o n�o foi efetuada."
				lRet := .F.
			EndIf
		EndIf
	Else
		LjGrvLog(Nil, "Desfazendo a transa��o Administrativa do Totvs Pagamento Digital.",,,.T.)
		oTEF20:Desfazer()
		Alert(STR0005) // "Transa��o n�o foi efetuada."
		lRet := .F.
	EndIf

	If lRet .And. !Empty(oRetTran:oRetorno:cDocCanc)
		//Atualiza campos da SL4 com informacoes do cancelamento
		AAdd( aDadosCanc, { "L4_DOCCANC", oRetTran:oRetorno:cDocCanc } )
		AAdd( aDadosCanc, { "L4_DATCANC", StrTran(DToC(oRetTran:oRetorno:dDataCanc), "/") } )
		AAdd( aDadosCanc, { "L4_HORCANC", StrTran(oRetTran:oRetorno:cHora, ":") } )

		LjGrvLog(, "Grava na SL4 os dados da opera��o de cancelamento de Pagamento Digital:", aDadosCanc,,.T.)
		
		If ExistFunc("STDUpdDocC") .AND. !Empty(aDadosCanc[1][2]) .And. !Empty(aDadosCanc[2][2])
			STDUpdDocC(aDadosCanc,aDadosTran[8])
		EndIf
	EndIf

	FreeObj(oRetTran)
	FreeObj(oDados)
	
	oRetTran := Nil
	oDados 	 := Nil
Else
	MsgAlert(STR0006) // "Esta esta��o n�o est� com a configura��o do Totvs Pagamento Digital habilitada."
EndIf

LjGrvLog(Nil, "FIM - Retorno da fun��o Administrativa do Totvs Pagamento Digital.", lRet,,,.T.)

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LjPDGtPGrv
Retorna array com informacoes de Pagamentos Digitais da venda existente na tabela SL4.

@type 	 Function
@author  Alberto Deviciente
@since   02/11/2020
@version P12.1.27

@param cNumOrc, Caractere, N�mero do Or�amento
@param lTransAtiv, L�gico, Determina se deve considerar apenas transa��es ativas que ainda n�o foram canceladas.

@return  aRet, Array, Array com informacoes de Pagamentos Digitais realizados na venda.
/*/
//----------------------------------------------------------------------
Function LjPDGtPGrv(cNumOrc, lTransAtiv)
Local aRet 			:= {}
Local aArea 		:= GetArea()
Local aAreaSL4 		:= SL4->(GetArea())
Local nInd			:= 0
Local cFormaPDPX	:= _FORMATPD // "PD/PX" Forma de Pagamento Digital e PIX

Default lTransAtiv	:= .F.

DbSelectArea("SL4")
SL4->( DbSetOrder(1) )	//L4_FILIAL, L4_NUM, L4_ORIGEM
If SL4->( DbSeek(xFilial("SL4") + cNumOrc ) )
	While !SL4->( Eof() ) .AND. xFilial("SL4") + cNumOrc == SL4->L4_FILIAL + SL4->L4_NUM

		If AllTrim(SL4->L4_FORMA) $ cFormaPDPX
			
			//Verifica se considera todas as transa��es ou apenas as transa��es ativas que ainda n�o est�o canceladas
			If !lTransAtiv .Or. Empty(SL4->L4_DATCANC)

				nInd := aScan( aRet, { |x| AllTrim(x[1])+AllTrim(x[4]) == Alltrim(SL4->L4_DOCTEF)+Alltrim(SL4->L4_TRNPCID)} )

				If nInd == 0
					Aadd(aRet, {} )
					nInd := Len(aRet)
					Aadd(aRet[nInd], Alltrim(SL4->L4_DOCTEF) ) 		//01-N�mero do DOCTEF
					Aadd(aRet[nInd], SL4->L4_VALOR )				//02-Valor total da transa��o
					Aadd(aRet[nInd], Alltrim(SL4->L4_TRNID	) ) 	//03-ID da Transa��o (Payment Hub)
					Aadd(aRet[nInd], Alltrim(SL4->L4_TRNPCID) )		//04-ID Transa��o Processador (Payment Hub)
					Aadd(aRet[nInd], Alltrim(SL4->L4_TRNEXID) )		//05-ID da Transa��o Externa (Payment Hub)
					Aadd(aRet[nInd], SL4->L4_DATATEF )				//06-Data da Transa��o
					Aadd(aRet[nInd], Alltrim(SL4->L4_FORMA) )		//07-Forma de pagamento
					Aadd(aRet[nInd], SL4->L4_FORMAID )				//08-Id da forma de pagamento (Multi-TEF)
					Aadd(aRet[nInd], Alltrim(SL4->L4_DOCCANC) )		//09-DOC Cancelamento da Transa��o
					Aadd(aRet[nInd], Alltrim(SL4->L4_DATCANC) )		//10-Data Cancelamento da Transa��o
					Aadd(aRet[nInd], Alltrim(SL4->L4_HORCANC) )		//11-Hora Cancelamento da Transa��o
					Aadd(aRet[nInd], { SL4->(Recno()) } )			//12-Recnos da SL4 referente a transa��o
				Else
					aRet[nInd][2] += SL4->L4_VALOR					//Aglutina o valor total da transa��o
					aAdd( aRet[nInd][12], SL4->(Recno()) )			//Recnos da SL4 referente a transa��o
				Endif

			EndIf

		EndIf				
		SL4->( DbSkip() )
	End
EndIf

RestArea(aAreaSL4)
RestArea(aArea)

LjGrvLog(cNumOrc, Iif(Len(aRet)>0,"Foram","N�o foram") + " encontradas informacoes de Pagamentos Digitais ou PIX da venda na tabela SL4, orcamento: " + cNumOrc, aRet,,.T.)

Return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LjPDCanTrn
Cancela transa��es de Pagamento Digital.

@author  Alberto Deviciente
@since   03/11/2020
@version P12

@param aPagDig, Array, Array passado por refer�ncia para setar informa��es das transa��o de Pagamento Digital que foram canceladas.
- A estrutura do array deve ser:
	01-N�mero do DOCTEF da transa��o
	02-Valor total da transa��o
	03-ID da Transa��o (Payment Hub)
	04-ID Transa��o Processador (Payment Hub)
	05-ID da Transa��o Externa (Payment Hub)
	06-Data da Transa��o
	07-Forma de pagamento
	08-Id da forma de pagamento (Multi-TEF)
	09-DOC Cancelamento da Transa��o (posi��o reservada para ser alimentada nesta fun��o)
	10-Data Cancelamento da Transa��o (posi��o reservada para ser alimentada nesta fun��o)
	11-Hora Cancelamento da Transa��o (posi��o reservada para ser alimentada nesta fun��o)
	12-Recnos da tabela referente a transa��o - SL4 (venda) ou SLV (se for receb. titulo)

@param nOperacao, Num�rico, Indica a opera��o em execu��o (1=Cancelamento/estorno de Venda, 2=Estorno de Recebimento de T�tulo)

@return  lRet, L�gico, Retorna se cancelou a transa��o de Pagamento Digital com sucesso.
/*/
//----------------------------------------------------------------------
Function LjPDCanTrn(aPagDigPix, nOperacao)
Local lRet 			:= .T.
Local aArea 		:= GetArea()
Local aAreaSL4 		:= SL4->(GetArea())
Local aAreaSLV 		:= SLV->(GetArea())
Local nInd			:= 0
Local oTEF20    	:= Nil
Local oDados 		:= Nil
Local oRetTran 		:= Nil
Local cMsg 			:= ""
Local aDadosCanc 	:= {}
Local cDocCanc		:= ""
Local cDataCanc		:= ""
Local cHoraCanc		:= ""
Local cAliasTab		:= ""
Local cForma		:= ""
Local lRelGerECF	:= IIF(ISBLIND(),.F.,Lj121IsFisc(LjGetStation("LG_IMPFISC")))	//Verifica se � impressora fiscal, relat�rio Gerencial

Default aPagDigPix	:= {}	// Pagamento Digital e PIX | PD e PX
Default nOperacao 	:= 1 	//1=Cancelamento/estorno de Venda, 2=Estorno de Recebimento de T�tulo

cAliasTab := Iif(nOperacao==1,"SL4","SLV")

If !IsBlind()
	If Len(aPagDigPix) > 0 //Verifica se a venda tem Pagamento Digital que precisa ser cancelado.

		LjGrvLog(Nil, "Foram encontradas " + cValToChar(Len(aPagDigPix)) + " transacoes de Pagamento Digital para serem canceladas", aPagDigPix,,.T.)
		
		oTEF20 := STBGetTEF()

		If STWChkTef("PD") //Verifica se esta��o esta configurada para realiza��o de transa��es de Pagamentos Digitais

			For nInd := 1 To Len(aPagDigPix)
				aDadosCanc := {}

				If AllTrim( aPagDigPix[nInd][07] ) == "PD"
					cForma := "PAGTO DIGITAL"
				Else
					cForma := "PAGTO PIX"
				EndIf

				cMsg := STR0007 +CHR(10)+Chr(13)+CHR(10)+Chr(13) 						// "Transacao de Pagamento Digital a ser cancelada:"
				cMsg += "- " + STR0008 + ": " + aPagDigPix[nInd][07] + Chr(13)			// "Forma de Pagamento"
				cMsg += "- " + STR0009 + ": " + AllTrim(Str(aPagDigPix[nInd][02],12,2)) // "Valor"
				
				LjGrvLog(Nil, cMsg,,,.T. )

				If nOperacao == 1
					//Somente exibe a mensagem se for cancelamento/estorno de venda.
					MsgInfo(cMsg)
				EndIf
				
				LjGrvLog(Nil, "Dados da transacao de Pagamento Digital enviado para cancelamento:", aPagDigPix[nInd],,.T.)

				//Envia cancelamento de transa��o de Pagamento Digital
				oDados := LJCDadosTransacaoADM():New(0,0, Date(), Time(), .T.) 
				oRetTran := oTEF20:PgtoDigital():FuncoesAdm(oDados,aPagDigPix[nInd])

				LjGrvLog(Nil,"Retorno da operacao de cancelamento de Pagamento Digital (lTransOk)", oRetTran:oRetorno:lTransOk,,.T.)
				LjGrvLog(Nil,"Dados do Retorno da opera��o de cancelamento de Pagamento Digital", oRetTran,,.T.)

				If oRetTran:oRetorno:lTransOk  
					lRet := .T.

					LjGrvLog(Nil,"Comprovante de cancelamento da transacao de Pagamento Digital (Via do Cliente)", oRetTran:oRetorno:cViacliente,,.T.)
					LjGrvLog(Nil,"Comprovante de cancelamento da transacao de Pagamento Digital (Via do Estabelecimento)", oRetTran:oRetorno:cViaCaixa,,.T.)

					If !Empty(oRetTran:oRetorno:cViacliente) .OR. !Empty(oRetTran:oRetorno:cViaCaixa)
						
						oTEF20:Cupom():Inserir( "G"		, oRetTran:oRetorno:oViaCaixa	, oRetTran:oRetorno:oViaCliente	, "A"	,;
												"01"	, cForma 						, oRetTran:nValor				, 1		,;
												0	) 

						LjGrvLog(Nil,"Executa a impressao do Comprovante de cancelamento da transacao de Pagamento Digital",,,.T.)

						If oTEF20:Cupom():Imprimir(lRelGerECF)
							LjGrvLog(Nil,"Impressao do Comprovante de cancelamento da transacao de Pagamento Digital realizada com sucesso",,,.T.)

							//Se a impressao for OK, confirma a transacao
							oTEF20:Confirmar()
						Else
							LjGrvLog(Nil,"Ocorreu problema de impressao do comprovante de cancelamento da transacao de Pagamento Digital.",,,.T.)

							oTEF20:Desfazer()
							MsgInfo(STR0010) // "Ocorreu problema de impress�o do comprovante de cancelamento da transa��o de Pagamento Digital."
							lRet := .F.
						EndIf
					
					Else
						LjGrvLog(Nil,"Nao ha comprovante de cancelamento da transacao de Pagamento Digital para ser impresso.",,,.T.)

						//Confirma transacao OK, caso nao tenha dados p/ impressao
						oTEF20:Confirmar()
					EndIf
				Else
					LjGrvLog(Nil,"Dados do Retorno da opera��o de cancelamento de Pagamento Digital", oRetTran,,.T.)
					oTEF20:Desfazer()
					lRet := .F.
				EndIf
				
				If lRet
					cDocCanc	:= oRetTran:oRetorno:cDocCanc
					cDataCanc	:= StrTran( DToC(oRetTran:oRetorno:dDataCanc), "/" )
					cHoraCanc	:= StrTran( oRetTran:oRetorno:cHora, ":" )

					//Atualiza o array com as informa��es do Cancelamento da transa��o
					aPagDigPix[nInd][09] := cDocCanc 	//09-DOC Cancelamento da Transa��o
					aPagDigPix[nInd][10] := cDataCanc	//10-Data Cancelamento da Transa��o
					aPagDigPix[nInd][11] := cHoraCanc	//11-Hora Cancelamento da Transa��o

					//Atualiza campos da tabela SL4 ou SLV com informacoes do cancelamento da transa��o de Pagamento Digital.
					AAdd(aDadosCanc,{SubStr(cAliasTab,2,2) + "_DOCCANC",cDocCanc})
					AAdd(aDadosCanc,{SubStr(cAliasTab,2,2) + "_DATCANC",cDataCanc})
					AAdd(aDadosCanc,{SubStr(cAliasTab,2,2) + "_HORCANC",cHoraCanc})

					LjGrvLog(Nil, "Grava na tabela " + cAliasTab + " os dados da opera��o de cancelamento de Pagamento Digital:", aDadosCanc,,.T.)
					
					If ExistFunc("STDUpdDocC") .AND. !Empty(aDadosCanc[1][2]) .And. !Empty(aDadosCanc[2][2])
						STDUpdDocC(aDadosCanc,aPagDigPix[nInd][12],cAliasTab)
					EndIf
				Else
					Exit
				EndIf

				FreeObj(oRetTran)
				FreeObj(oDados)
				
				oRetTran := Nil
				oDados 	 := Nil
				
			Next nInd
		Else

			If nOperacao == 1 //1=Cancelamento/estorno de Venda
				cMsg := STR0011 // "A venda n�o poder� ser cancelada, pois"
			ElseIf nOperacao == 2 //2=Estorno de Recebimento de T�tulo
				cMsg := STR0012 //"O estorno do t�tulo n�o poder� ser realizado, pois"
			EndIf

			cMsg := cMsg + " " + STR0013 // "esta esta��o n�o est� configurada para relizar transa��o/cancelamento de Pagamento Digital."
			LjGrvLog(Nil, cMsg,,,.T.)
			MsgStop(cMsg)
			lRet := .F.

		EndIf

		LjGrvLog(Nil, "Retorno da funcao de cancelamento de transacoes de Pagamento Digital", lRet,,.T.)

	EndIf
EndIf

RestArea(aAreaSLV)
RestArea(aAreaSL4)
RestArea(aArea)

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LjIniTEF20
Inicia o TEF 2.0 apenas com a configura��o do Totvs Pagamento Digital.

@author  Alberto Deviciente
@since   17/11/2020
@version P12

@param 	 oTEF20, Objeto, Objeto do TEF 2.0 passado por refer�ncia  para ser atualizado. (N�o � obrigat�rio)

@return  lRet, L�gico, Retorna se conseguiu iniciar o TEF 2.0
/*/
//----------------------------------------------------------------------
Function LjIniTEF20(oTEF20)
Local lRet 	:= .F.
Local lBkpINCLUI	:= .T.			// Backup da variavel INCLUI, pois ao intanciar o objeto oModelMarte esta invertendo o seu status
Local lBkpALTERA	:= .F.			// Backup da variavel ALTERA, pois ao intanciar o objeto oModelMarte esta invertendo o seu status

LjGrvLog("TPD", "Inicio - Antes da verifica��o se existe configura��o dos Pagamentos Digitais.",,,.T.)

If Type("INCLUI") == "L" .AND. Type("ALTERA") == "L"
	lBkpINCLUI	:= INCLUI
	lBkpALTERA	:= ALTERA
EndIf

//--------------------
// Instancia o TEF 2.0
//--------------------
If ExistFunc("LjUsePayHub") .And. LjUsePayHub()
	oTEF20 := STBGetTEF()
	If ValType(oTEF20) == "O"
		If oTEF20:lAtivo
			oTEF20:Fechar()
		EndIf
		FreeObj(oTEF20)
	EndIf

	LjGrvLog("TPD", "Inicia o TEF 2.0 caso esteja configurado.",,,.T.)

	oTEF20 := LJC_TEF():New(STFGetStat("CODIGO"), .F.)
	STBSetTef(oTEF20)
	If ValType(oTEF20) == "O"
		lRet := .T.
		LjGrvLog("TPD", "TEF 2.0 iniciado.", oTEF20,,.T.)
	Else
		LjGrvLog("TPD", "TEF 2.0 n�o iniciado.",,,.T.)
	EndIf

Else

	LjGrvLog("TPD", " oTEF20 n�o instanciado, ambiente sem configura��o para Pagamentos Digitais.",,,.T.)

EndIf

If Type("INCLUI") == "L" .AND. Type("ALTERA") == "L"
	INCLUI := lBkpINCLUI
	ALTERA := lBkpALTERA
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjL1Situa()
Funcao responsavel por retornar se permite estornar a transacao da venda conforme a SL1 L1_SITUA
Caso esteja como T3 nao permite estornar, pois com esse status a venda ja foi transmitida e autorizada, faltando apenas a impressao.
@param1		, cIdTransaction			, caracter, ID da transa��o
@param2		, cProcessorTransactionId	, caracter, ID do processador
@param3		, cExternalTransactionId	, caracter, ID externo
@param5		, cCodOrc					, caracter, codigo do orcamento
@return		, aRet						, array		, aRet[01] pode ou n�o estornar a transa��o
													  aRet[02] L1_NUM
													  aRet[03] L1_DOC
													  aRet[04] L1_SERIE
													  aRet[05] L1_VLRTOT 
													  aRet[06] L1_HORA
													  aRet[07] L1_EMISSAO
@author		joao.marocs
@version	12.1.33
@since		08/02/2022
/*/
//-------------------------------------------------------------------

Function LjL1Situa( cIdTransac, cProcTrnId, cExtTrnId, cCodOrc )

Local aRet			:= {.T.,"","","",0,"00:00:00",CtoD("00/00/00")} // {Cancela? S/N,Orcamento, Doc, Serie}
Local lCamposTPD	:= SL1->(ColumnPos("L1_VLRPGDG")) > 0 .AND. SL1->(ColumnPos("L1_VLRPGPX")) > 0 .AND.;
						SL4->(ColumnPos("L4_TRNID")) > 0 .AND. SL4->(ColumnPos("L4_TRNPCID")) > 0 .AND. SL4->(ColumnPos("L4_TRNEXID")) > 0
Local aAreaSL1		:= SL1->(GetArea())
Local aAreaSL4		:= SL4->( GetArea()) 

If lCamposTPD

	SL4->(dbSetOrder(1)) // L4_FILIAL+L4_NUM+L4_ORIGEM
	SL1->(dbSetOrder(9)) //L1_FILIAL+L1_SITUA+L1_PDV+L1_DOC

	If SL1->(dbSeek( xFilial("SL1") + "T3" )) 

		While SL1->( !EoF() ) .AND. SL1->L1_FILIAL + SL1->L1_SITUA == xFilial("SL1") + "T3"
			If (!Empty(SL1->L1_VLRPGPX) .OR. !Empty(SL1->L1_VLRPGDG)) .AND. SL4->( dbSeek( xFilial("SL4")  + SL1->L1_NUM ) ) 

				While SL4->(!EOF()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + SL1->L1_NUM
					If AllTrim(SL4->L4_TRNID) == AllTrim(cIdTransac)	.AND.;
						AllTrim(SL4->L4_TRNPCID) == AllTrim(cProcTrnId)	.AND.;
						AllTrim(SL4->L4_TRNEXID) == AllTrim(cExtTrnId)

						aRet[01] := .F.
						LjGrvLog(SL1->L1_NUM, " TPD - LjL1Situa - Orcamento Status T3, transacao TPD nao sera cancelada.",,,.T.)
						Exit
					EndIf					

					SL4->(dbSkip())
				EndDo
			EndIf

			SL1->(dbSkip())
			
			If !aRet[01]
				Exit
			EndIf
			
		EndDo	

	EndIf

	SL1->(dbSetOrder(1)) //L1_FILIAL+L1_NUM
	If !Empty(cCodOrc) .AND. SL1->(dbSeek( xFilial("SL1") + cCodOrc ))
		aRet[02] := SL1->L1_NUM
		aRet[03] := SL1->L1_DOC
		aRet[04] := SL1->L1_SERIE
		aRet[05] := SL1->L1_VLRTOT 
		aRet[06] := SL1->L1_HORA
		aRet[07] := SL1->L1_EMISSAO
	EndIf

EndIF 

RestArea(aAreaSL1)
RestArea(aAreaSL4)

return aRet
