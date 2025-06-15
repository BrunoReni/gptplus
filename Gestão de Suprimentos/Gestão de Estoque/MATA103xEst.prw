#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA103.CH"
/*
Fonte desenvolvido para receber funções de validação para o documento de entrada
*/

/*/{Protheus.doc} MatEst175
//
@author andre. Maximo 
@since 23/09/2019
@version 1.0
@return logico
@param item posicionado na SD1 de origem da nota
@type function
/*/

Function MatEst175(cTabSd1)
Local aAreaSD1 := (cTabSd1)->(GetArea())
Local aQtd := {}
Local lRet := .F.
Local cCq      := SuperGetMV("MV_CQ")

dbSelectArea("SD1")
dbSetOrder(1)
If MsSeek(xFilial("SD1")+(cTabSd1)->D1_NFORI+(cTabSd1)->D1_SERIORI+(cTabSd1)->D1_FORNECE+(cTabSd1)->D1_LOJA+(cTabSd1)->D1_COD+(cTabSd1)->D1_ITEMORI,.F.)
    If alltrim((cTabSd1)->D1_LOCAL) == alltrim(cCq)
        SD7->(DbSetorder(1))
        If SD7->(dbSeek(xfilial("SD7")+(cTabSd1)->(D1_NUMCQ+D1_COD) ))
            aQtd := A175CalcQt((cTabSd1)->D1_NUMCQ, (cTabSd1)->D1_COD, (cTabSd1)->D1_LOCAL)
            If len(aQtd) > 0 .And. (QtdComp(aQtd[6])==QtdComp(0) .Or. !Empty(SD7->D7_LIBERA))
                lRet:=.F.
            else
                lRet:= .T.
            EndIf
        EndIf
    EndIf
EndIf
RestArea(aAreaSD1)

return(lRet)

/*/{Protheus.doc} A103Usado
	@type  Function
	@author miqueias.coelho
	@since 21/10/2022
    @descricao 'Funcao criada para realizar validacao e verificacao de campos que estao com uso desabilitado'
	@return lRet
	/*/
Function A103Usado()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local lRastro	:= .F.
Local lGrade	:= .F.
Local lSegUM	:= .F.
Local nPosCod	:= GetPosSD1("D1_COD")
Local nI		:= 0
Local cMsg		:= ""

If nPosCod > 0
	aCpoSD1 := FWSX3Util():GetAllFields("SD1")

	lRastro := Rastro(aCols[n][nPosCod])
	lGrade	:= MatGrdPrrf(aCols[n][nPosCod],.T.)

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+aCols[n][nPosCod]))
	If !Empty(SB1->B1_SEGUM) .And. SB1->B1_CONV > 0
		lSegUM := .T.
	Endif

	If lRastro .Or. lGrade .Or. lSegUM
		For nI := 1 To Len(aCpoSD1)
			
			//Valida se o produto controla lote e se os campos D1_LOTECTL, D1_LOTEFOR, D1_NUMLOTE e D1_DTVALID
			If lRastro .And. AllTrim(aCpoSD1[nI]) $ "D1_LOTECTL|D1_LOTEFOR|D1_NUMLOTE|D1_DTVALID|" .And. !X3Uso(GetSx3Cache(aCpoSD1[nI],'X3_USADO'))
				cMsg := STR0385 + Alltrim(aCols[n][nPosCod]) + " " + STR0563 + TRIM(GetSx3Cache(aCpoSD1[nI],'X3_TITULO')) + " (" + Alltrim(aCpoSD1[nI]) + ")" + STR0566
				lRet := .F.
				Exit
			Endif

			//Valida se o produto tem grade
			If lGrade .And. AllTrim(aCpoSD1[nI]) $ "D1_GRADE|D1_ITEMGRD" .And. !X3Uso(GetSx3Cache(aCpoSD1[nI],'X3_USADO'))
				cMsg := STR0385 + Alltrim(aCols[n][nPosCod]) + " " + STR0564 + TRIM(GetSx3Cache(aCpoSD1[nI],'X3_TITULO')) + " (" + Alltrim(aCpoSD1[nI]) + ")" + STR0566
				lRet := .F.
				Exit
			Endif

			//Valida se o produto utiliza segunda unidade de medida no cadastro (SB1)
			If lSegUM .And. AllTrim(aCpoSD1[nI]) $ "D1_SEGUM|D1_QTSEGUM" .And. !X3Uso(GetSx3Cache(aCpoSD1[nI],'X3_USADO'))
				cMsg := STR0385 + Alltrim(aCols[n][nPosCod]) + " " + STR0565 + TRIM(GetSx3Cache(aCpoSD1[nI],'X3_TITULO')) + " (" + Alltrim(aCpoSD1[nI]) + ")" + STR0566
				lRet := .F.
				Exit
			Endif
		Next nI
	Endif

	If !lRet
		Help(" ",1,"ESTUSADO",,cMsg,1,0)
	Endif
Endif

RestArea(aArea)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A103xETrSl³ Autor ³ Microsiga S/A         ³ Data ³22/03/2023³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao utilizada para transferir o saldo classificado para  ³±±
±±³          ³o Armazem de Transito definido pelo parametro MV_LOCTRAN.   ³±±
±±³          ³ Função migrada do mata103 A103TrfSld mantida por compatil. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lDeleta - .T. = Exclusao NFE                                ³±±
±±³          ³          .F. = Classificao da Pre-Nota                     ³±±
±±³          ³nTipo   - 1 = Transferencia para Armazem de Transito        ³±±
±±³          ³          2 = Retorno do saldo para o armazem orginal       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A103xETrSl(lDeleta,nTipo)

Local aAreaAnt   := GetArea()
Local aAreaSF4   := SF4->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local aAreaSD3   := SD3->(GetArea())
Local aAreaSB2   := SD3->(GetArea())
Local cLocTran   := SuperGetMV("MV_LOCTRAN",.F.,"95")
Local cLocCQ     := SuperGetMV("MV_CQ",.F.,"98")
Local aArray     := {}
Local aStruSD3   := {}
Local cSeek      := ''
Local cQuery     := ''
Local cAliasSD3  := 'SD3'
Local cChave     := Space(TamSX3("D3_CHAVE")[1])
Local nX         := 0
Local lQuery     := .F.
Local lContinua  := .F.
Local lVldPE  	 := .T.
Local lTransit   := .F.

Default lDeleta     := .F.
Default nTipo       := 1

Private lMsErroAuto := .F.

//Ponto de Entrada para validar se permite a operacao
If ExistBlock("A103TRFVLD")
	lVldPE:= ExecBlock("A103TRFVLD",.F.,.F.,{nTipo,lDeleta})
	If Valtype (lVldPE) != "L"
		lVldPE:= .T.
	EndIf
EndIf

//Remessa para o Armazem de Transito
If nTipo == 1 .And. lVldPE
		If !Localiza(SD1->D1_COD) .And. Empty(SD1->D1_OP) .And. AllTrim(SD1->D1_LOCAL) # AllTrim(cLocCQ)
			dbSelectArea("SF4")
			dbSetOrder(1)
			//-- Tratamento para Transferencia de Saldos
		If cPaisLoc == "BRA"
			If dbSeek(xFilial("SF4")+SD1->D1_TES) .And. SF4->F4_ESTOQUE == 'S' .And. ;
	           SF4->F4_TRANSIT == 'S' .And. SF4->F4_CODIGO <= '500'
				//Estorno da transferencia para o Armazem de Terceiros
				If lDeleta 
					if !Empty(SD1->D1_TRANSIT)
						lTransit:=.T.
					EndIf
					//-- Retira o Flag que indica produto em transito
					RecLock("SD1",.F.)
					SD1->D1_TRANSIT := " "
					MsUnLock()
					lMsErroAuto := .F.
					cSeek:=xFilial("SD3")+SD1->D1_NUMSEQ+cChave+SD1->D1_COD

						aStruSD3 := SD3->(dbStruct())
						//Selecionar os registros da SD3 pertencentes a movimentacao de transferencia
						//e recebimento do armazem de transito. Pode ser que a nota ja tenha sido recebida
						//atraves do botao "Docto. em transito" e entao o saldo do armazem de transito tambem
						//deve ser estornado. Primeiro as saidas, depois as entradas.
						cQuery := "SELECT D3_FILIAL, D3_COD, D3_LOCAL, D3_NUMSEQ, D3_CF, D3_TM, D3_ESTORNO "
						cQuery +=  " FROM "+RetSQLTab('SD3')
						cQuery += " WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
						cQuery +=   " AND D_E_L_E_T_  = ' ' "
						cQuery +=   " AND D3_ESTORNO <> 'S' "
						cQuery += 	" AND D3_COD      = '"+SD1->D1_COD+"' "
						cQuery += 	" AND D3_NUMSEQ   = '"+SD1->D1_NUMSEQ+"' "
						If !lTransit
							cQuery += 	" AND D3_LOCAL = '"+cLocTran+"' "
						EndIf 
						cQuery += " ORDER BY D3_FILIAL, D3_COD, D3_TM DESC "

						//--Executa a Query
						lQuery    := .T.
						cAliasSD3 := GetNextAlias()
						cQuery    := ChangeQuery( cQuery )
						DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasSD3, .T., .F. )
						For nX := 1 To Len(aStruSD3)
							If aStruSD3[nX,2]<>"C"
								TcSetField(cAliasSD3,aStruSD3[nX,1],aStruSD3[nX,2],aStruSD3[nX,3],aStruSD3[nX,4])
							EndIf
						Next nX

					Do While !(cAliasSD3)->(Eof()) .And. cSeek == xFilial("SD3")+(cAliasSD3)->D3_NUMSEQ+cChave+(cAliasSD3)->D3_COD
						aAdd(aArray,{{"D3_FILIAL"	,(cAliasSD3)->D3_FILIAL , NIL},;
									 {"D3_COD"		,(cAliasSD3)->D3_COD	, NIL},;
								     {"D3_LOCAL"	,(cAliasSD3)->D3_LOCAL	, NIL},;
									 {"D3_NUMSEQ"	,(cAliasSD3)->D3_NUMSEQ , NIL},;
									 {"D3_CF"		,(cAliasSD3)->D3_CF     , NIL},;
									 {"D3_TM"		,(cAliasSD3)->D3_TM     , NIL},;
									 {"INDEX"		,3						, NIL} })

						(cAliasSD3)->(dbSkip())
					EndDo

					// Ordenar o vetor para que as saidas sejam estornadas primeiro
					aSort(aArray,,,{|x,y| x[1,2]+x[2,2]+x[5,2] > y[1,2]+y[2,2]+y[5,2]})

					// Percorre todo o vetor com os registros a estornar
					For nX := 1 to Len(aArray)

						// Se for movimento de entrada e do armazem de transito
						If (aArray[nX][6][2] <= "500") .And. (aArray[nX][3][2] == cLocTran)
							//-- Desbloqueia o armazem de terceiro
							dbSelectArea("SB2")
							dbSetOrder(1)
							If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
								RecLock("SB2",.F.)
								Replace B2_STATUS With "1"
								MsUnLock()
							EndIf
						EndIf

						MSExecAuto({|x,y| MATA240(x,y)},aArray[nX],5) // Operacao de estorno do movimento interno (SD3)

						//-- Tratamento de erro para rotina automatica
						If lMsErroAuto
							DisarmTransaction()
							MostraErro()
							Break
						EndIf

						// Se for movimento de entrada e do armazem de transito
						If (aArray[nX][6][2] <= "500") .And. (aArray[nX][3][2] == cLocTran)
							//-- Bloqueia o armazem de terceiro
							dbSelectArea("SB2")
							dbSetOrder(1)
							If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
								RecLock("SB2",.F.)
								Replace B2_STATUS With "2"
								MsUnLock()
							EndIf
						EndIf
					Next nX

					If lQuery
						//--Fecha a area corrente
						dbSelectArea(cAliasSD3)
						dbCloseArea()
						dbSelectArea("SD3")
					EndIf

				//Transferencia para o Armazem de Terceiros
				ElseIf !lDeleta
					//-- Grava Flag que indica produto em transito
					RecLock("SD1",.F.)
					SD1->D1_TRANSIT := "S"
					MsUnLock()
					//-- Requisita o produto do armazem origem (Valorizado)
					dbSelectArea("SB2")
					dbSetOrder(1)
					If dbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
						RecLock("SD3",.T.)
						SD3->D3_FILIAL	:= xFilial("SD3")
						SD3->D3_COD		:= SD1->D1_COD
						SD3->D3_QUANT	:= SD1->D1_QUANT
						SD3->D3_TM		:= "999"
						SD3->D3_OP		:= SD1->D1_OP
						SD3->D3_LOCAL	:= SD1->D1_LOCAL
						SD3->D3_DOC		:= SD1->D1_DOC
						SD3->D3_EMISSAO	:= SD1->D1_DTDIGIT
						SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
						SD3->D3_UM		:= SD1->D1_UM
						SD3->D3_GRUPO	:= SD1->D1_GRUPO
						SD3->D3_TIPO	:= SD1->D1_TP
						SD3->D3_SEGUM	:= SD1->D1_SEGUM
						SD3->D3_CONTA	:= SD1->D1_CONTA
						SD3->D3_CF		:= "RE6"
						SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
						SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
						SD3->D3_CUSTO1	:= SD1->D1_CUSTO
						SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
						SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
						SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
						SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
						SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
						SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
						SD3->D3_DTVALID	:= SD1->D1_DTVALID
						SD3->D3_POTENCI	:= SD1->D1_POTENCI
						MsUnLock()
						dbSelectArea("SB2")
						B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
						lContinua := .T.
					EndIf
					//-- Devolucao do produto para o armazem destino (Valorizado)
					If lContinua
						dbSelectArea("SB2")
						dbSetOrder(1)
						If !dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
							CriaSB2(SD1->D1_COD,cLocTran)
						EndIf
						//-- Desbloqueia o armazem de terceiro
						dbSelectArea("SB2")
						dbSetOrder(1)
						If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
							RecLock("SB2",.F.)
							Replace B2_STATUS With "1"
							MsUnLock()
						EndIf
						RecLock("SD3",.T.)
						SD3->D3_FILIAL	:= xFilial("SD3")
						SD3->D3_COD		:= SD1->D1_COD
						SD3->D3_QUANT	:= SD1->D1_QUANT
						SD3->D3_TM		:= "499"
						SD3->D3_LOCAL	:= cLocTran
						SD3->D3_DOC		:= SD1->D1_DOC
						SD3->D3_EMISSAO	:= SD1->D1_DTDIGIT
						SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
						SD3->D3_UM		:= SD1->D1_UM
						SD3->D3_GRUPO	:= SD1->D1_GRUPO
						SD3->D3_TIPO	:= SD1->D1_TP
						SD3->D3_SEGUM	:= SD1->D1_SEGUM
						SD3->D3_CONTA	:= SD1->D1_CONTA
						SD3->D3_CF		:= "DE6"
						SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
						SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
						SD3->D3_CUSTO1	:= SD1->D1_CUSTO
						SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
						SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
						SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
						SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
						SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
						SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
						SD3->D3_DTVALID	:= SD1->D1_DTVALID
						SD3->D3_POTENCI	:= SD1->D1_POTENCI
						MsUnLock()
						dbSelectArea("SB2")
						B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
						//-- Bloqueia o armazem de terceiro
						dbSelectArea("SB2")
						dbSetOrder(1)
						If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
							RecLock("SB2",.F.)
							Replace B2_STATUS With "2"
							MsUnLock()
						EndIf
			    	EndIf
			    EndIf
			EndIf
		EndIf
	EndIf
//Retorno para o Armazem Original
ElseIf nTipo == 2 .And. lVldPE
	//-- Grava Flag que indica produto em transito
	RecLock("SD1",.F.)
	SD1->D1_TRANSIT := " "
	MsUnLock()
	//-- Desbloqueia o armazem de terceiro
	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
		RecLock("SB2",.F.)
		Replace B2_STATUS With "1"
		MsUnLock()
	EndIf
	//-- Requisita o produto do armazem de transito (Valorizado)
	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
		RecLock("SD3",.T.)
		SD3->D3_FILIAL	:= xFilial("SD3")
		SD3->D3_COD		:= SD1->D1_COD
		SD3->D3_QUANT	:= SD1->D1_QUANT
		SD3->D3_TM		:= "999"
		SD3->D3_OP		:= SD1->D1_OP
		SD3->D3_LOCAL	:= cLocTran
		SD3->D3_DOC		:= SD1->D1_DOC
		SD3->D3_EMISSAO	:= dDataBase
		SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
		SD3->D3_UM		:= SD1->D1_UM
		SD3->D3_GRUPO	:= SD1->D1_GRUPO
		SD3->D3_TIPO	:= SD1->D1_TP
		SD3->D3_SEGUM	:= SD1->D1_SEGUM
		SD3->D3_CONTA	:= SD1->D1_CONTA
		SD3->D3_CF		:= "RE6"
		SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
		SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
		SD3->D3_CUSTO1	:= SD1->D1_CUSTO
		SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
		SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
		SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
		SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
		SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
		SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
		SD3->D3_DTVALID	:= SD1->D1_DTVALID
		SD3->D3_POTENCI	:= SD1->D1_POTENCI
		MsUnLock()
		dbSelectArea("SB2")
		B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
		MsUnLock()
		//-- Bloqueia o armazem de terceiro
		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
			RecLock("SB2",.F.)
			Replace B2_STATUS With "2"
			MsUnLock()
		EndIf
		lContinua := .T.
	EndIf
	//-- Devolucao do produto para o armazem destino (Valorizado)
	dbSelectArea("SB2")
	dbSetOrder(1)
	If lContinua .And. dbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
		RecLock("SD3",.T.)
		SD3->D3_FILIAL	:= xFilial("SD3")
		SD3->D3_COD		:= SD1->D1_COD
		SD3->D3_QUANT	:= SD1->D1_QUANT
		SD3->D3_TM		:= "499"
		SD3->D3_LOCAL	:= SD1->D1_LOCAL
		SD3->D3_DOC		:= SD1->D1_DOC
		SD3->D3_EMISSAO	:= dDataBase
		SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
		SD3->D3_UM		:= SD1->D1_UM
		SD3->D3_GRUPO	:= SD1->D1_GRUPO
		SD3->D3_TIPO	:= SD1->D1_TP
		SD3->D3_SEGUM	:= SD1->D1_SEGUM
		SD3->D3_CONTA	:= SD1->D1_CONTA
		SD3->D3_CF		:= "DE6"
		SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
		SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
		SD3->D3_CUSTO1	:= SD1->D1_CUSTO
		SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
		SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
		SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
		SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
		SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
		SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
		SD3->D3_DTVALID	:= SD1->D1_DTVALID
		SD3->D3_POTENCI	:= SD1->D1_POTENCI
		MsUnLock()
		dbSelectArea("SB2")
		B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
		MsUnLock()
	EndIf
EndIf

//Ponto de entrada finalidades diversas na rotina de transferência de Armazem de Trânsito
If ExistBlock("MT103TRF")
	ExecBlock("MT103TRF",.F.,.F.,{nTipo,SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD,SD1->D1_ITEM})
EndIf

RestArea(aAreaSB2)
RestArea(aAreaSD1)
RestArea(aAreaSD3)
RestArea(aAreaSF4)
RestArea(aAreaAnt)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103Custo³ Autor ³ Edson Maricate         ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o custo de entrada do Item                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Custo(nItem)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Item da NF                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 , A103Grava()                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103xCusto(nItem,aHeadSE2,aColsSE2,lTxNeg,aNFCompra)

Local aCusto     := {}
Local aRet       := {}
Local aSM0       := {}
Local nPos       := 0
Local nValIV     := 0
Local nX         := 0
Local nZ         := 0
Local nFatorPS2  := 1
Local nFatorCF2  := 1
Local nValPS2    := 0
Local nValCF2    := 0
Local nValNCalc  := 0
Local lCustPad   := .T.
Local uRet       := Nil
Local lCredICM   := SuperGetMV("MV_CREDICM", .F., .F.) // Parametro que indica o abatimento do credito de ICMS no custo do item, ao utilizar o campo F4_AGREG = "I"
Local lCredPis   := SuperGetMV("MV_CREDPIS", .F., .F.)
Local lCredCof   := SuperGetMV("MV_CREDCOF", .F., .F.)
Local lDEDICMA   := SuperGetMV("MV_DEDICMA", .F., .F.) // Efetua deducao do ICMS anterior nao calculado pelo sistema
Local lDedIcmAnt := .F.
Local lValCMaj   := !Empty(MaFisScan("IT_VALCMAJ",.F.)) // Verifica se a MATXFIS possui a referentcia IT_VALCMAJ
Local lValPMaj   := !Empty(MaFisScan("IT_VALPMAJ",.F.)) // Verifica se a MATXFIS possui a referentcia IT_VALCMAJ
Local nPosItOri  := GetPosSD1("D1_ITEMORI")
Local cCodFil    := ""
Local cAliasAux  := ""
Local lCustRon   := SuperGetMV("MV_CUSTRON",.F.,.T.)
Local lSimpNac   := MaFisRet(,"NF_SIMPNAC") == "1" .Or. MaFisRet(,"NF_UFORIGEM") == "EX"

Default lTxNeg := .F.

//Calcula o percentual para credito do PIS / COFINS
If !Empty( SF4->F4_BCRDPIS )
	nFatorPS2 := SF4->F4_BCRDPIS / 100
EndIf

If !Empty( SF4->F4_BCRDCOF )
	nFatorCF2 := SF4->F4_BCRDCOF / 100
EndIf

nValPS2 := MaFisRet(nItem,"IT_VALPS2") * nFatorPS2
nValCF2 := MaFisRet(nItem,"IT_VALCF2") * nFatorCF2

If SF4->(FieldPos("F4_CRDICMA")) > 0 .And. !Empty(SF4->F4_CRDICMA)
	lDedIcmAnt := SF4->F4_CRDICMA == '1'
Else
	lDedIcmAnt := lDEDICMA
EndIf
If lDedIcmAnt
	nValNCalc := MaFisRet(nItem,"IT_ICMNDES")
EndIf

l103Auto := Type("l103Auto") <> "U" .And. l103Auto

If l103Auto .And. (nPos:= aScan(aAutoItens[nItem],{|x|Trim(x[1])== "D1_CUSTO" })) > 0
	aADD(aCusto,{	aAutoItens[nItem,nPos,2],;
					0.00,;
					0.00,;
					SF4->F4_CREDIPI,;
					SF4->F4_CREDICM,;
					MaFisRet(nItem,"IT_NFORI"),;
					MaFisRet(nItem,"IT_SERORI"),;
					SD1->D1_COD,;
					SD1->D1_LOCAL,;
					SD1->D1_QUANT,;
					If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0) ,;
					SF4->F4_CREDST,;
					MaFisRet(nItem,"IT_VALSOL"),;
					MaRetIncIV(nItem,"1"),;
					SF4->F4_PISCOF,;
					SF4->F4_PISCRED,;
					nValPS2 - (IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),;
					nValCF2 - (IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),;
					IIf(SF4->F4_ESTCRED>0,MaFisRet(nItem,"IT_ESTCRED"),0)   ,;
					IIf(lSimpNac,MaFisRet(nItem, "LF_CRDPRES"),0),;
					MaFisRet(nItem,"IT_VALANTI"),;
					If(nPosItOri > 0, aCols[nItem][nPosItOri], ""),;
					MaFisRet(nItem, "IT_VALFEEF"); // Issue DMANMAT01-21311 - Apropriação do imposto FEEF ao custo de entrada
				})
Else
	nValIV	:=	MaRetIncIV(nItem,"2")

	If SD1->D1_COD == Left(SuperGetMV("MV_PRODIMP"), Len(SD1->D1_COD))
		aADD(aCusto,{	MaFisRet(nItem,"IT_TOTAL")-IIF(cTipo=="P".Or.SF4->F4_IPI=="R",0,MaFisRet(nItem,"IT_VALIPI"))+MaFisRet(nItem,"IT_VALICM")+If((SF4->F4_CIAP=="S".And.SF4->F4_CREDICM=="S").Or.SF4->F4_ANTICMS=="1",0,MaFisRet(nItem,"IT_VALCMP"))-If(SF4->F4_INCSOL<>"N",MaFisRet(nItem,"IT_VALSOL"),0)-nValIV+IF(SF4->F4_ICM=="S" .And. SF4->F4_AGREG$'A|C',MaFisRet(nItem,"IT_VALICM"),0)+IF(SF4->F4_AGREG=='D' .And. SF4->F4_BASEICM == 0,MaFisRet(nItem,"IT_DEDICM"),0)-MaFisRet(nItem,"IT_CRPRESC")-MaFisRet(nItem,"IT_CRPREPR")+MaFisRet(nItem,"IT_VLINCMG")+IIf(!lCredPis .And. SF4->F4_AGRPIS=="2" .And. SF4->F4_AGREG$"I|B",nValPS2-(IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),0)+IIf(!lCredCof .And. SF4->F4_AGRCOF=="2" .And. SF4->F4_AGREG$"I|B",nValCF2-(IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),0) - nValNCalc,;
						MaFisRet(nItem,"IT_VALIPI"),;
						MaFisRet(nItem,"IT_VALICM"),;
						SF4->F4_CREDIPI,;
						SF4->F4_CREDICM,;
						MaFisRet(nItem,"IT_NFORI"),;
						MaFisRet(nItem,"IT_SERORI"),;
						SD1->D1_COD,;
						SD1->D1_LOCAL,;
						SD1->D1_QUANT,;
						If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0) ,;
						SF4->F4_CREDST,;
						MaFisRet(nItem,"IT_VALSOL"),;
						MaRetIncIV(nItem,"1"),;
						SF4->F4_PISCOF,;
						SF4->F4_PISCRED,;
						nValPS2 - (IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),;
						nValCF2 - (IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),;
						IIf(SF4->F4_ESTCRED>0,MaFisRet(nItem,"IT_ESTCRED"),0)   ,;
						IIf(lSimpNac,MaFisRet(nItem, "LF_CRDPRES"),0),;
						MaFisRet(nItem,"IT_VALANTI"),;
						If(nPosItOri > 0, aCols[nItem][nPosItOri], ""),;
						MaFisRet(nItem, "IT_VALFEEF"); // Issue DMANMAT01-21311 - Apropriação do imposto FEEF ao custo de entrada
					})
	Else
		aADD(aCusto,{	MaFisRet(nItem,"IT_TOTAL")-IIf(cTipo=="P".Or.SF4->F4_IPI=="R",0,MaFisRet(nItem,"IT_VALIPI"))+IIf((SF4->F4_CIAP=="S" .And. SF4->F4_CREDICM=="S").Or. SF4->F4_ANTICMS=="1",0,MaFisRet(nItem,"IT_VALCMP"))-IIf(SF4->F4_INCSOL<>"N",MaFisRet(nItem,"IT_VALSOL"),0)-nValIV+IIf(SF4->F4_ICM=="S" .And. SF4->F4_AGREG$'A|C',MaFisRet(nItem,"IT_VALICM"),0)+IIf(SF4->F4_AGREG=='D' .And. SF4->F4_BASEICM == 0,MaFisRet(nItem,"IT_DEDICM"),0)-MaFisRet(nItem,"IT_CRPRESC")-MaFisRet(nItem,"IT_CRPREPR")+MaFisRet(nItem,"IT_VLINCMG")-IIf(lCredICM .And. SF4->F4_AGREG$"I|B",MaFisRet(nItem,"IT_VALICM"),0)-IIf(SF4->F4_AGREG == "B",MaFisRet(nItem,"IT_VALSOL"),0)+IIf(!lCredPis .And.SF4->F4_AGRPIS=="2" .And. SF4->F4_AGREG$"I|B",nValPS2-(IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),0)+IIf(!lCredCof .And. SF4->F4_AGRCOF=="2" .And. SF4->F4_AGREG$"I|B",nValCF2-(IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),0) - nValNCalc,;
						MaFisRet(nItem,"IT_VALIPI"),;
						MaFisRet(nItem,"IT_VALICM"),;
						SF4->F4_CREDIPI,;
						SF4->F4_CREDICM,;
						MaFisRet(nItem,"IT_NFORI"),;
						MaFisRet(nItem,"IT_SERORI"),;
						SD1->D1_COD,;
						SD1->D1_LOCAL,;
						SD1->D1_QUANT,;
						If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0),;
						SF4->F4_CREDST,;
						MaFisRet(nItem,"IT_VALSOL"),;
						MaRetIncIV(nItem,"1"),;
						SF4->F4_PISCOF,;
						SF4->F4_PISCRED,;
						nValPS2 - (IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),;
						nValCF2 - (IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),;
						IIf(SF4->F4_ESTCRED > 0,MaFisRet(nItem,"IT_ESTCRED"),0) ,;
						IIf(lSimpNac,MaFisRet(nItem, "LF_CRDPRES"),0),;
						Iif(SF4->F4_CREDST != '2' .And. SF4->F4_ANTICMS == '1',MaFisRet(nItem,"IT_VALANTI"),0),;
						If(nPosItOri > 0, aCols[nItem][nPosItOri], ""),;
						MaFisRet(nItem, "IT_VALFEEF"); // Issue DMANMAT01-21311 - Apropriação do imposto FEEF ao custo de entrada
					})
	EndIf
EndIf

//Nao considerar o custo de uma entrada por devolucao ou bonificacao
If (SD1->D1_TIPO == "D" .And. SF4->F4_DEVZERO == "2") .Or. Iif(cPaisLoc == "BRA", (SF4->F4_BONIF == "S" .And. SF4->F4_CREDICM != "S"),.F.)
	aRet := {{0,0,0,0,0}}
ElseIf SF4->F4_TRANFIL == "1" .And. lCustRon .And. SD1->D1_TIPO == "N" //-- Para transferencia entre filiais, obtem o custo da origem
	SA2->(DbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA))

	If UsaFilTrf() //-- Procura pelo campo
		cCodFil := SA2->A2_FILTRF
	Else //-- Procura pelo CNPJ
		aSM0 := FwLoadSM0(.T.)
		If Len(aSM0) > 0
			nX := aScan(aSM0,{|x| AllTrim(x[SM0_CGC]) == AllTrim(SA2->A2_CGC)})
			If nX > 0
				cCodFil := aSM0[nX, SM0_CODFIL]
			EndIf
		EndIf
	EndIf

	If !Empty(cCodFil)
		cAliasAux := GetNextAlias()
		BeginSQL Alias cAliasAux
            SELECT
                D2_CUSTO1,
                D2_CUSTO2,
                D2_CUSTO3,
                D2_CUSTO4,
                D2_CUSTO5
            FROM
                %Table:SD2% SD2
            WHERE
                D2_FILIAL = %Exp:xFilial("SD2", cCodFil)%
                AND D2_DOC = %Exp:SD1->D1_DOC%
                AND D2_SERIE = %Exp:SD1->D1_SERIE%
                AND D2_ITEM = %Exp:CodeSomax1(SD1->D1_ITEM, FwTamSX3("D2_ITEM")[1])%
                AND SD2.%NotDel%
		EndSQL

		aRet := {{0,0,0,0,0}}

		If !(cAliasAux)->(Eof())
			aRet := {{(cAliasAux)->D2_CUSTO1, (cAliasAux)->D2_CUSTO2, (cAliasAux)->D2_CUSTO3, (cAliasAux)->D2_CUSTO4, (cAliasAux)->D2_CUSTO5}}
			// Permite agregar o valor do ICMS ST (Retido) ao custo de entrada das notas fiscais de entrada,
			// geradas pelo processo de Transferência de Filiais.
			If SF4->F4_TRFICST == '1'
				For nX := 1 to len(aRet[01])
					If aRet[01,nX]>0
						If nX == 1
							aRet[01,nX] := aRet[01,nX]+SD1->D1_ICMSRET
						Else
							aRet[01,nX] := aRet[01,nX]+xMoeda(SD1->D1_ICMSRET,1,nX,SD1->D1_DTDIGIT)
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf
		(cAliasAux)->(DbCloseArea())
	EndIf
Else
	aRet := RetCusEnt(aDupl,aCusto,cTipo,,,aNFCompra,,,,,lTxNeg)
	If SF4->F4_AGREG == "N"
		For nX := 1 to Len(aRet[1])
			aRet[1][nX] := If(aRet[1][nX]>0,aRet[1][nX],0)
		Next nX
	EndIf
EndIf

//A103CUST - Ponto de entrada utilizado para manipular os valores
//           do custo de entrada nas 5 moedas.
If ExistBlock("A103CUST")
	uRet := ExecBlock("A103CUST",.F.,.F.,{aRet})
	If Valtype(uRet) == "A" .And. Len(uRet) > 0
		For nX := 1 To Len(uRet)
			For nZ:=1 To 5
				If Valtype(uRet[nX,nZ]) != "N"	//Uso o array original se retorno nao for numerico
					lCustPad := .F.
					Exit
				EndIf
			Next nZ
		Next nX
		If lCustPad
			aRet := aClone(uRet)
		EndIf
	EndIf
EndIf

Return aRet[1]

/*/{Protheus.doc} CodeSoma1 
//TODO Converte o valor do campo D1_ITEM para o campo D2_ITEM. 
Devido ao tamanho dos campos serem diferente e ter o uso da função SOMA1()
@author reynaldo
@since 08/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cItem, characters, Conteudo do campo D1_ITEM
@param nTamanho, numeric, Tamanho do campo D2_ITEM
@type function
/*/
Static Function CodeSomax1(cItem,nTamanho)
Local cResult
Local nLoop
Local nValor
		
nValor := DecodSoma1(cItem)

cResult := strzero(0,nTamanho)
For nLoop := 1 to nValor
	cResult := Soma1(cResult)
Next nLoop

Return cResult
