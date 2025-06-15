#INCLUDE "loca080.ch"  
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH" 

/*/{PROTHEUS.DOC} LOCA080.PRW
Duplica as Linhas de Loca��es FPA
@TYPE user Function
@AUTHOR Jose Eulalio
@SINCE 12/05/2022
@VERSION P12
@HISTORY 12/05/2022, Jose Eulalio, Cria��o da Fun��o  
/*/

Function LOCA080()
Local nPosSeqGru	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQGRU"})
Local nPosAS		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AS"    })
Local nPosViagem	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VIAGEM"})
Local nPosEquip		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_GRUA"  })
Local nPosDescEq	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DESGRU"})
Local nPosUltFat	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ULTFAT"})
Local nPosNfRem		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NFREM" })
Local nPosdNfRem	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DNFREM"})
Local nPosSerRem	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SERREM"})
Local nPosIteRem	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ITEREM"})
Local nPosNfRet		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NFRET" })
Local nPosdNfRet	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DNFRET"})
Local nPosProdut	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})
Local nPosNfEnt		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DNFENT"})
Local nPosReboq		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_REBOQI"})
Local nPosDtScr		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTSCRT"})
Local nPosMotRe		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_MOTRET"})
Local nPosNMotR		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NMOTRE"})
Local nPosAjust		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AJUSTE"})
Local nPosDAjus		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DAJUST"})
Local nPosNiver		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NIVER"})
Local nPosSeqEst	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"}) // Frank em 24/05/23
Local nQtdCopias	:= 0
Local nX			:= 0
Local nLinhaAtu		:= 0
Local nUltimaLn		:= 0
Local nFim01		:= 0
Local nFim02		:= 0
Local nLenPla		:= 0
Local cListNoBem	:= ""
Local cBemDisp		:= Space(TamSx3("T9_CODBEM")[1])
Local cBemNome		:= Space(TamSx3("T9_NOME")[1])
Local cVazioAs		:= Space(TamSx3("FPA_AS")[1])
Local cVazioViag	:= Space(TamSx3("FPA_VIAGEM")[1])
Local cVazioNFRe	:= Space(TamSx3("FPA_NFREM")[1])
Local cVazioSeRe	:= Space(TamSx3("FPA_SERREM")[1])
Local cVazioItRe	:= Space(TamSx3("FPA_ITEREM")[1])
Local cVazioNfRt	:= Space(TamSx3("FPA_NFRET")[1])
Local cVazioRebo	:= Space(TamSx3("FPA_REBOQI")[1])
Local cVazioMotr	:= Space(TamSx3("FPA_MOTRET")[1])
Local cVazioNMot	:= Space(TamSx3("FPA_NMOTRE")[1])
Local cVazioAjus	:= Space(TamSx3("FPA_AJUSTE")[1])
Local cVazioDAju	:= Space(TamSx3("FPA_DAJUST")[1])
Local cVazioEstr	:= Space(TamSx3("FPA_SEQEST")[1]) // Frank em 24/05/23
Local aCoors		:= FwGetDialogSize()
Local aRetBem		:= {}
Local lContinua 	:= .T.
Local lOk 			:= .F.
LOCAL ODLGQ
Local nZ
Local cSeq
Local cSeqOld
Local cSeqCopy
Local cSeqNew

IF !OFOLDER:NOPTION == nFolderPla 
	Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
	   				Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsist�ncia nos dados."
	 				{STR0003}) //"Selecionar a aba Loca��o."
	lContinua := .F.
ENDIF 

If lContinua
	nLinhaAtu		:= oDlgPla:nAt
	//adequa para a resolu��o da tela
	//If GetScreenRes()[1] < 1500
		nFim01			:= aCoors[3] / 6
		nFim02			:= aCoors[4] / 5
	//Else
	//	nFim01			:= aCoors[3] / 8
	//	nFim02			:= aCoors[4] / 6
	//EndIf 
	DEFINE MSDIALOG ODLGQ TITLE STR0009 + oDlgPla:aCols[nLinhaAtu][nPosSeqGru] FROM aCoors[1], aCoors[2] To nFim01, nFim02 Pixel Style DS_MODALFRAME //OF ODLG3 PIXEL //"Duplica o Item " ### [SEQGRU]
		@ 00,01 TO 03,05
		@ 012,022 SAY STR0004 //"Quantidade de linhas a duplicar:"
		@ 010,102 GET nQtdCopias PICTURE "999" WHEN FWHEN()
		@ 025,022 BUTTON "OK"   		SIZE 30,15 PIXEL OF ODLGQ ACTION ( lOk := .T., ODLGQ:End() ) // 240 //"OK"
		@ 025,055 BUTTON STR0010   	SIZE 30,15 PIXEL OF ODLGQ ACTION ODLGQ:End()             // 240 //"Cancelar"
	ACTIVATE MSDIALOG ODLGQ CENTERED
EndIf

If lOk .And. nQtdCopias > 0
	If MSGYESNO(STR0005 + oDlgPla:aCols[nLinhaAtu][nPosSeqGru] + STR0006 + cValtoChar(nQtdCopias) + STR0007, STR0008) //"Deseja copiar o Item " + #### + " por " + #### + " vezes ?" ### Rental
		For nX := 1 To nQtdCopias
			//pega SegGru da �ltima linha
			nUltimaLn := oDlgPla:ACOLS[LEN(oDlgPla:ACOLS)][nPosSeqGru]
			//adiciona linha nova
			AADD(oDlgPla:ACOLS,ACLONE(oDlgPla:ACOLS[nLinhaAtu]))
			//pega nova ultima linha
			nLenPla := Len(ODLGPLA:aCols)
			//atualiza campos
			// se o bem estiver preenchido, preenche com pr�ximo dispon�vel
			If !Empty(oDlgPla:ACOLS[nLenPla][nPosEquip])
				If Empty(cListNoBem)
					cListNoBem := ListNoBem(AClone(oDlgPla:ACOLS),nPosAS,nPosEquip)
				EndIf
				aRetBem := RetBemDisp(oDlgPla:ACOLS[nLenPla][nPosProdut], @cListNoBem)
				oDlgPla:ACOLS[nLenPla][nPosEquip] 	:= aRetBem[1]
				oDlgPla:ACOLS[nLenPla][nPosDescEq] 	:= aRetBem[2]
			Else
				oDlgPla:ACOLS[nLenPla][nPosEquip] 	:= cBemDisp
				oDlgPla:ACOLS[nLenPla][nPosDescEq] 	:= cBemNome
			EndIf
			//campos que n�o s�o copiados
			oDlgPla:ACOLS[nLenPla][nPosSeqGru] 	:= Soma1(nUltimaLn)
			oDlgPla:ACOLS[nLenPla][nPosAS] 		:= cVazioAs
			oDlgPla:ACOLS[nLenPla][nPosViagem] 	:= cVazioViag
			oDlgPla:ACOLS[nLenPla][nPosUltFat] 	:= StoD("")
			oDlgPla:ACOLS[nLenPla][nPosNfRem] 	:= cVazioNFRe
			oDlgPla:ACOLS[nLenPla][nPosDNfRem] 	:= StoD("")
			oDlgPla:ACOLS[nLenPla][nPosSerRem] 	:= cVazioSeRe
			oDlgPla:ACOLS[nLenPla][nPosIteRem] 	:= cVazioItRe
			oDlgPla:ACOLS[nLenPla][nPosNfRet] 	:= cVazioNfRt
			oDlgPla:ACOLS[nLenPla][nPosDNfRet] 	:= StoD("")
			oDlgPla:ACOLS[nLenPla][nPosNfEnt] 	:= StoD("")
			oDlgPla:ACOLS[nLenPla][nPosDtScr] 	:= StoD("")
			oDlgPla:ACOLS[nLenPla][nPosReboq] 	:= cVazioRebo
			oDlgPla:ACOLS[nLenPla][nPosMotRe] 	:= cVazioMotr
			oDlgPla:ACOLS[nLenPla][nPosNMotR] 	:= cVazioNMot
			oDlgPla:ACOLS[nLenPla][nPosAjust] 	:= cVazioAjus
			oDlgPla:ACOLS[nLenPla][nPosDAjus] 	:= cVazioDAju
			oDlgPla:ACOLS[nLenPla][nPosNiver] 	:= StoD("")
			// Frank em 24/05/23. 
			// Se for estrutura e item filho n�o preencher na c�pia.
			If substr(oDlgPla:ACOLS[nLenPla][nPosSeqEst],5,1) <> " "
				oDlgPla:ACOLS[nLenPla][nPosSeqEst] := cVazioEstr
			EndIF
			//adiciona no array oPla_cols
			AADD(OPLA_COLS, Aclone(ODLGPLA:ACOLS[nLenPla])) 
			// Frank em 24/05/23. 
			// Se for estrutura e item pai refazer todos os itens filhos com nova estrutura
			If substr(oDlgPla:ACOLS[nLenPla][nPosSeqEst],5,1) == " " .and. substr(oDlgPla:ACOLS[nLenPla][nPosSeqEst],1,1) <> " "
				// Passo 1 - identificar qual a numeracao maior para criar um item pai novo
				// Passo 2 - trocar na linha copiada pai a nova numeracao
				// Passo 3 - identificar todos os itens filhos e
				// gerar os novos itens filhos, limpar os campos que n�o devem ser copiados, j� com a nova estrutura pai x filho

				// Passo 1
				cSeq := "000"
				For nZ := 1 to len(oDlgPla:ACOLS)
					If substr(oDlgPla:ACOLS[nZ][nPosSeqEst],1,3) > cSeq
						cSeq := substr(oDlgPla:ACOLS[nZ][nPosSeqEst],1,3)
					EndIF
				Next
				cSeq := Soma1(cSeq)

				// Passo 2
				cSeqOld := substr(oDlgPla:ACOLS[nLenPla][nPosSeqEst],1,3)
				oDlgPla:ACOLS[nLenPla][nPosSeqEst] := cSeq

				// Passo 3
				For nZ := 1 to len(oDlgPla:ACOLS)
					If substr(oDlgPla:ACOLS[nZ][nPosSeqEst],1,3) == cSeqOld
						If substr(oDlgPla:ACOLS[nZ][nPosSeqEst],5,1) <> " "
							cSeqCopy := substr(oDlgPla:ACOLS[nZ][nPosSeqEst],5,len(oDlgPla:ACOLS[nZ][nPosSeqEst]))
							// Trata-se de um item filho e que deve ser replicado
							//pega SegGru da �ltima linha
							nUltimaLn := oDlgPla:ACOLS[LEN(oDlgPla:ACOLS)][nPosSeqGru]
							//adiciona linha nova
							AADD(oDlgPla:ACOLS,ACLONE(oDlgPla:ACOLS[nZ]))
							//pega nova ultima linha
							nLenPla := Len(ODLGPLA:aCols)
							//atualiza campos
							// se o bem estiver preenchido, preenche com pr�ximo dispon�vel
							If !Empty(oDlgPla:ACOLS[nLenPla][nPosEquip])
								If Empty(cListNoBem)
									cListNoBem := ListNoBem(AClone(oDlgPla:ACOLS),nPosAS,nPosEquip)
								EndIf
								aRetBem := RetBemDisp(oDlgPla:ACOLS[nLenPla][nPosProdut], @cListNoBem)
								oDlgPla:ACOLS[nLenPla][nPosEquip] 	:= aRetBem[1]
								oDlgPla:ACOLS[nLenPla][nPosDescEq] 	:= aRetBem[2]
							Else
								oDlgPla:ACOLS[nLenPla][nPosEquip] 	:= cBemDisp
								oDlgPla:ACOLS[nLenPla][nPosDescEq] 	:= cBemNome
							EndIf
							//campos que n�o s�o copiados
							oDlgPla:ACOLS[nLenPla][nPosSeqGru] 	:= Soma1(nUltimaLn)
							oDlgPla:ACOLS[nLenPla][nPosAS] 		:= cVazioAs
							oDlgPla:ACOLS[nLenPla][nPosViagem] 	:= cVazioViag
							oDlgPla:ACOLS[nLenPla][nPosUltFat] 	:= StoD("")
							oDlgPla:ACOLS[nLenPla][nPosNfRem] 	:= cVazioNFRe
							oDlgPla:ACOLS[nLenPla][nPosDNfRem] 	:= StoD("")
							oDlgPla:ACOLS[nLenPla][nPosSerRem] 	:= cVazioSeRe
							oDlgPla:ACOLS[nLenPla][nPosIteRem] 	:= cVazioItRe
							oDlgPla:ACOLS[nLenPla][nPosNfRet] 	:= cVazioNfRt
							oDlgPla:ACOLS[nLenPla][nPosDNfRet] 	:= StoD("")
							oDlgPla:ACOLS[nLenPla][nPosNfEnt] 	:= StoD("")
							oDlgPla:ACOLS[nLenPla][nPosDtScr] 	:= StoD("")
							oDlgPla:ACOLS[nLenPla][nPosReboq] 	:= cVazioRebo
							oDlgPla:ACOLS[nLenPla][nPosMotRe] 	:= cVazioMotr
							oDlgPla:ACOLS[nLenPla][nPosNMotR] 	:= cVazioNMot
							oDlgPla:ACOLS[nLenPla][nPosAjust] 	:= cVazioAjus
							oDlgPla:ACOLS[nLenPla][nPosDAjus] 	:= cVazioDAju
							oDlgPla:ACOLS[nLenPla][nPosNiver] 	:= StoD("")
							cSeqNew := cSeq + "." + cSeqCopy
							oDlgPla:ACOLS[nLenPla][nPosSeqEst]  := cSeqNew
						EndIF 
					EndIf
				Next
				

			EndIF
		Next nX
		oDlgPla:oBrowse:Refresh()
	EndIf
EndIf

Return



/*/{PROTHEUS.DOC} RetBemDisp.PRW
Fun��o que retorna o Bem Dispon�vel, baseada na consulta FPAST9
@TYPE Static Function
@AUTHOR Jose Eulalio
@SINCE 08/06/2022
@VERSION P12
@HISTORY 08/06/2022, Jose Eulalio, Cria��o da Fun��o
/*/
Static Function RetBemDisp(cProdut, cListNoBem)
Local cBemDisp	:= Space(TamSx3("T9_CODBEM")[1])
Local cBemNome	:= Space(TamSx3("T9_NOME")[1])
Local cQuery 	:= ""
Local cAlias 	:= GetNextAlias()
Local aBemDisp	:= {cBemDisp,cBemNome}

//Verifica a disponibilidade por data FIFO na FQ4
cQuery	:= " SELECT DISTINCT FQ4_STATUS, FQ4_DESTAT, FQ4_DTFIM, T9_CODBEM, T9_NOME,T9_CODESTO FROM " + RetSqlName("ST9") + " ST9 "
cQuery	+= " INNER JOIN  " + RetSqlName("FQ4") + " FQ4 "
cQuery	+= " ON T9_CODBEM = FQ4_CODBEM "
cQuery	+= " AND FQ4_STATUS = '00' "
cQuery	+= " AND FQ4.D_E_L_E_T_ = ' '   "
cQuery	+= " WHERE T9_FILIAL = '" + xFilial("ST9") + "' "
cQuery	+= " AND ST9.D_E_L_E_T_ = ' '   "
cQuery	+= " AND T9_SITMAN = 'A'  "
cQuery	+= " AND T9_SITBEM = 'A'  "
//cQuery	+= " AND T9_STATUS = '00'  "
cQuery	+= " AND ( T9_STATUS = '00' OR T9_STATUS = '  ' )" 
cQuery	+= " AND T9_CODESTO = '" + cProdut + "' "
//exclui do retorno bens que j� est�o em linhas anteriores
cQuery	+= " AND T9_CODBEM NOT IN (" + cListNoBem +") "
cQuery	+= " ORDER BY FQ4_DTFIM "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If (cAlias)->(!EOF())
	cBemDisp 	:= (cAlias)->T9_CODBEM
	cBemNome	:= (cAlias)->T9_NOME
EndIf

(cAlias)->(dbCloseArea())

//Caso n�o ache, procura pela ST9
If Empty(cBemDisp)
	//Procura direto na ST9
	cQuery	:= " SELECT DISTINCT T9_CODBEM, T9_NOME,T9_CODESTO FROM " + RetSqlName("ST9") + " ST9 "
	cQuery	+= " WHERE T9_FILIAL = '" + xFilial("ST9") + "' "
	cQuery	+= " AND ST9.D_E_L_E_T_ = ' '   "
	cQuery	+= " AND T9_SITMAN = 'A'  "
	cQuery	+= " AND T9_SITBEM = 'A'  "
	cQuery	+= " AND T9_STATUS = '00'  "
	cQuery	+= " AND T9_CODESTO = '" + cProdut + "' "
	//exclui do retorno bens que j� est�o em linhas anteriores
	If !Empty(cListNoBem)
		cQuery	+= " AND T9_CODBEM NOT IN (" + cListNoBem +") "
	EndIf 

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	If (cAlias)->(!EOF())
		cBemDisp 	:= (cAlias)->T9_CODBEM
		cBemNome	:= (cAlias)->T9_NOME
	EndIf

	(cAlias)->(dbCloseArea())
EndIf
 
//adiciona � lista de itens que j� foram para itens anteriores
If !Empty(cBemDisp)
	If !Empty(cListNoBem)
		cListNoBem += ","
	EndIf
	cListNoBem += "'" + cBemDisp + "'"
	aBemDisp[1] := cBemDisp
	aBemDisp[2] := cBemNome
EndIf

Return aBemDisp

/*/{PROTHEUS.DOC} RetBemDisp.PRW
Retorna lista de bens que n�o dever�o ser copiados
@TYPE Static Function
@AUTHOR Jose Eulalio
@SINCE 09/06/2022
@VERSION P12
@HISTORY 09/06/2022, Jose Eulalio, Cria��o da Fun��o
/*/
Static Function ListNoBem(aColsFpa,nPosAS,nPosEquip)
Local cListNoBem	:= ""
Local nX			:= 0

For nX := 1 To Len(aColsFpa)
	If !Empty(aColsFpa[nX][nPosEquip]) .And. Empty(aColsFpa[nX][nPosAS])
		If !Empty(cListNoBem)
			cListNoBem += ","
		EndIf
		cListNoBem += "'" + aColsFpa[nX][nPosEquip] + "'"
	EndIf
Next nX

Return cListNoBem
