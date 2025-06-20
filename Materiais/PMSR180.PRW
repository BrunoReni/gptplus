#INCLUDE "Protheus.ch"
#INCLUDE "pmsr180.ch"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

#DEFINE DTINICIAL      1
#DEFINE DTFINAL        2
#DEFINE PERIODO        3
#DEFINE PEDCOMPRA      4
#DEFINE DESPESAS       5
#DEFINE PEDVENDA       6
#DEFINE RECEITAS       7
#DEFINE SALDODIA       8
#DEFINE VARIACAODIA    9
#DEFINE SAIDASACUM     10 
#DEFINE ENTRADASACUM   11 
#DEFINE VARIACAOACUM   12 
#DEFINE SALDOACUM      13


//---------------------------------RELEASE 4---------------------------------------//

Function PMSR180(aArrayFlx,aTotais,aMv_Par)

If PMSBLKINT()
	Return Nil
EndIf

oReport := ReportDef(aArrayFlx,aTotais)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� PARAMETROS                                                             �
//� MV_PAR01 : Projeto   de ?                                              �
//� MV_PAR02 : Ate?                                                        �
//� MV_PAR03 : Data projeto de                                             �
//� MV_PAR04 : Data projeto ate                                            �
//� MV_PAR05 : Numero de dias                                              �
//� MV_PAR06 : Periodo                                                     �
//� MV_PAR07 : Acumular Antecipados ?                                      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf	

If aArrayFlx!=Nil
	Mv_Par01 := aMv_Par[1]
	Mv_Par02 := aMv_Par[2]
	Mv_Par03 := aMv_Par[3]
	Mv_Par04 := aMv_Par[4]
	Mv_Par05 := aMv_Par[5]
	Mv_Par06 := aMv_Par[6]
EndIf

oReport:PrintDialog()

Return

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿝eportDef 튍utor  쿛aulo Carnelossi    � Data �  18/08/06   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝elease 4                                                   볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Static Function ReportDef(aArrayFlx,aTotais)
Local cPerg		:= "PMR180"
Local cDesc1   := STR0001 //"Este relatorio ira imprimir o fluxo de caixa do projeto considerando todas receitas (pedido de venda,titulos a receber e movimentacao bancaria) e despesas (pedido de compra,autorizacao de entrega,nota fiscal de entrada,titulos a pagar e movimentos bancarios) vinculadas ao projeto."
Local cDesc2   := "" 
Local cDesc3   := ""
Local oReport
Local oProjeto
Local oFluxo
Local nX
Local aOrdem  := {}

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎riacao do componente de impressao                                      �
//�                                                                        �
//쿟Report():New                                                           �
//쿐xpC1 : Nome do relatorio                                               �
//쿐xpC2 : Titulo                                                          �
//쿐xpC3 : Pergunte                                                        �
//쿐xpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//쿐xpC5 : Descricao                                                       �
//�                                                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

oReport := TReport():New("PMSR180",STR0002, cPerg, ;
			{|oReport| ReportPrint(oReport, aArrayFlx, aTotais, Mv_Par06, MV_PAR05, MV_PAR03)},;
			cDesc1 )
//STR0002 //"Fluxo de caixa"

oReport:SetPortrait()

If aArrayFlx!=Nil
	oReport:ParamReadOnly()
	oReport:HideParamPage() 
EndIf

oProjeto := TRSection():New(oReport, STR0029, { "AF8", "SA1", "AFE" }, aOrdem /*{}*/, .F., .F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎riacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//쿟RSection():New                                                         �
//쿐xpO1 : Objeto TReport que a secao pertence                             �
//쿐xpC2 : Descricao da se�ao                                              �
//쿐xpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se豫o.                   �
//쿐xpA4 : Array com as Ordens do relat�rio                                �
//쿐xpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//쿐xpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
TRCell():New(oProjeto,	"AF8_PROJET"	,"AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"AF8_DESCRI"	,"AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

TRPosition():New(oProjeto, "AFE", 1, {|| xFilial("AFE") + AF8->AF8_PROJET + AF8->AF8_REVISA})
TRPosition():New(oProjeto, "SA1", 1, {|| xFilial("SA1") + AF8->AF8_CLIENT})

//-------------------------------------------------------------
oFluxo := TRSection():New(oReport, STR0030, , /*{aOrdem}*/, .F., .F.)
TRCell():New(oFluxo, "PERIODO"			,""	,STR0016/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)  //"Periodo"
TRCell():New(oFluxo, "VALOR_PREV_PC"	,""	,STR0019/*Titulo*/,"@E 99,999,999.99"/*Picture*/,13/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Vlr. Prev. PC"
TRCell():New(oFluxo, "VALOR_DESPESAS"	,""	,STR0020/*Titulo*/,"@E 99,999,999.99"/*Picture*/,13/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Vlr. Despesas"
TRCell():New(oFluxo, "VALOR_PREV_PV"	,""	,STR0021/*Titulo*/,"@E 99,999,999.99"/*Picture*/,13/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Vlr. Prev PV"
TRCell():New(oFluxo, "VALOR_RECEITAS"	,""	,STR0022/*Titulo*/,"@E 99,999,999.99"/*Picture*/,13/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Vlr. Receitas"
TRCell():New(oFluxo, "SALDO_DIA"      ,""   ,STR0023/*Titulo*/,"@E 999,999,999,999.99"/*Picture*/,17/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Saldo do Dia"
TRCell():New(oFluxo, "VARIACAO_DIA"		,""	,STR0025/*Titulo*/,"@E 9999.99%"/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Var. Dia"
TRCell():New(oFluxo, "SAIDAS_ACUM"		,""	,STR0026/*Titulo*/,"@E 999,999,999,999.99"/*Picture*/,17/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Saidas. Acum."
TRCell():New(oFluxo, "ENTRADAS_ACUM"	,""	,STR0027/*Titulo*/,"@E 999,999,999,999.99"/*Picture*/,17/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Entradas Acum."
TRCell():New(oFluxo, "SALDO_ACUM"		,""	,STR0024/*Titulo*/,"@E 999,999,999,999.99"/*Picture*/,17/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Saldo Acumulado"
TRCell():New(oFluxo, "VARIACAO_ACUM"	,""	,STR0028/*Titulo*/,"@E 9999.99%"/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")  //"Var. Acum."

oFluxo:SetHeaderPage()
oFluxo:SetColSpace(0) 

Return(oReport)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴敲굇
굇튡rograma  쿝eportPrint 튍utor  쿛aulo Carnelossi    � Data � 18/08/06  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴묽�
굇튒esc.     쿝elease 4                                                   볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Static Function ReportPrint(oReport, aArrayFlx, aTotais, nPeriodo, nDiasTot, dDataInic)
Local oProjeto      := oReport:Section(1)
Local aArea         := GetArea()
Local aHandle
Local aFluxo
Local nTotRec       := 0
Local nTotDesp      := 0
Local nDespAnt      := 0
Local nReceAnt      := 0
Local nSaldo        := 0
Local nSaldoAcm     := 0
Local nSaldoDia     := 0
Local lFirst        := .T.
Local dDataTrab     := dDataInic
Local nDias         := 0
Local nQtdePer      := 0
Local aDias         := {1,7,10,15,30}
Local dData
Local nSaidasDia    := 0
Local nSaidasAcum   := 0
Local nEntradasAcum := 0
Local nEntradasDia  := 0
Local nRestPer      := 0
Local nQtdDias      := 0
Local nI            := 0
Local nX            := 0
Local aTitAntec     := {}
Local nValAux       := 0
Local nReceAntDia   := 0
Local nDespAntDia   := 0
Local lLoop := .T.

If aArrayFlx == Nil
	nDias := aDias[MV_PAR06]
	dbSelectArea("AF8")
	dbSetOrder(1)
	dbSeek(xFilial("AF8") + mv_par01,.T.)
	While !Eof() .And. xFilial("AF8") == AF8->AF8_FILIAL ;
				 .And. AF8->AF8_PROJET <= mv_par02 .AND. lLoop
				 
		If lFirst .And. dDataInic < AF8->AF8_DATA
			dDataInic := AF8->AF8_DATA
			lFirst    := .F.
		EndIf
			
		If !Empty(oProjeto:GetAdvplExp()) .And. !&(oProjeto:GetAdvplExp())
			dbSelectArea("AF8")
			dbSkip()
			Loop
		EndIf

		nTotRec   := 0
		nTotDesp  := 0
		nSaldo    := 0
		nSaldoAcm := 0
		nSaldoDia := 0
		aArrayFlx := {}

		nSaidasAcum   := 0
		nEntradasAcum := 0
		nEntradasDia  := 0
		nSaidasDia    := 0

		If (MV_PAR06 <> 5)
			If nDiasTot < nDias
				nQtdePer := 0
				nRestPer := nDiasTot
				nDias    := nDiasTot
			Else
				nQtdePer := Int(nDiasTot / nDias)
				nRestPer := nDiasTot - (nQtdePer * nDias)
			Endif
		
			// Gera os registros para todas as datas do periodo, inclusive a database
			dDataTrab := dDataInic
			For nX := 1 To nQtdePer
				If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
					Aadd(aArrayFlx, {dDataTrab,(dDataTrab + nDias - 1),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0,0,0,0,0})
				Endif
		
				dDataTrab += nDias
			Next nX
			
			// calcula o restante do periodo, se houver
			If nRestPer > 0
				If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
					Aadd(aArrayFlx, {dDataTrab,(dDataTrab+nRestPer),PMC100DescPer(dDataTrab, nRestPer),0,0,0,0,0,0,0,0,0,0,0,0})
				Endif
			EndIf
		
		Else
			nQtdDias := 0  
			dDataTrab:= dDataInic
			nMes     := Month(dDataTrab)		
			For dData:= dDataInic To dDataInic+nDiasTot
				If (nMes <> Month(dData))
					nQtdePer++
					nMes := Month(dData)		
		      
					If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
						Aadd(aArrayFlx, {dDataTrab,(dDataTrab+nQtdDias-1),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0,0,0,0,0})
		        		dDataTrab+= nQtdDias
						nQtdDias:= 0
					EndIf
				EndIf
		
				nQtdDias++
			Next dData
			
			If (nQtdDias > 0)
				If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
					Aadd(aArrayFlx, {dDataTrab,(dDataTrab+nQtdDias),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0,0,0,0,0})
				EndIf
			EndIf
		EndIf

		AFC->(dbSetOrder(1))
		AFC->(MsSeek(xFilial("AFC") + AF8->AF8_PROJET + AF8->AF8_REVISA))
		
		aHandle := PmsIniFin(AFC->AFC_PROJET,AFC->AFC_REVISA,Padr(AFC->AFC_PROJET,Len(AFC->AFC_EDT)),.T.)
		aFluxo  := PmsRetFinVal(aHandle,4,Padr(AFC->AFC_PROJET,Len(AFC->AFC_EDT)))
 
		dDataTrab := dDataInic
				
		// calcula o saldo da despesa antecipada
		For nI:= 1 To Len(aFluxo[2])
			If aFluxo[2,nI,3] > 0
				nDespAnt += aFluxo[2,nI,3]
				If Mv_par07==2 //Acumular Antecipados
					aAdd(aTitAntec,{aFluxo[2,nI,1], 'PA', aFluxo[2,nI,3] })
				EndIf
			EndIf
		Next nI
	
		// calcula o saldo da receita antecipada
		For nI:= 1 To Len(aFluxo[5])
			If aFluxo[5,nI,3] > 0
				nReceAnt += aFluxo[5,nI,3]
				If Mv_par07==2 //Acumular Antecipados
					aAdd(aTitAntec,{aFluxo[5,nI,1], 'RA', aFluxo[5,nI,3] })
				EndIf
			EndIf
		Next nI

		aSort(aFluxo[5],,,{|x,y| x[1]<y[1]} )
		aSort(aFluxo[2],,,{|x,y| x[1]<y[1]} )
		aSort(aTitAntec,,,{|x,y| x[1]<y[1]} )

		// calcula o saldo inicial
		nSaldo := aFluxo[6] - aFluxo[3] // Receita - Despesa
		nSaldoAcm := nSaldo
		
		For nX := 1 To Len(aArrayFlx)
			nSaldoDia   := 0
			nReceAntDia := 0
			nDespAntDia := 0

			//titulos a pagar
			For nI:= 1 To Len(aFluxo[2])
				If (aFluxo[2,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[2,nI,1] <= aArrayFlx[nX,DTFINAL])
					aArrayFlx[nX,DESPESAS] += aFluxo[2,nI,2]

					//Se Acumular Antecipados e o registro do fluxo nao eh antecipado entao
					//a variavel nValAux pega o valor do titulo, abate os valores antecipados e depois totaliza no saldo do dia,saldo acumulado,etc
					If (Mv_par07==2) .And. (aFluxo[2,nI,3]==0)
						nValAux := aFluxo[2,nI,2]
						nPos := aScan(aTitAntec,{|x| x[1]<=aFluxo[2,nI,1] .And. x[2]=='PA' .And. x[3]>0 })
						While (nPos > 0) .And. (nValAux > 0)
							If aTitAntec[nPos,3] >= nValAux
								aTitAntec[nPos,3] -= nValAux
								nDespAntDia += nValAux
								nValAux     := 0
								Loop
							Else
								nDespAntDia += aTitAntec[nPos,3]
								nValAux     -= aTitAntec[nPos,3]
								aTitAntec[nPos,3] := 0
							EndIf
							nPos := aScan(aTitAntec,{|x| x[1]<=aFluxo[2,nI,1] .And. x[2]=='PA' .And. x[3]>0 })
						EndDo

						nTotDesp  += nValAux
						nSaldoDia -= nValAux
						nSaldoAcm -= nValAux
					Else
						nTotDesp  += aFluxo[2,nI,2]
						nSaldoDia -= aFluxo[2,nI,2]
						nSaldoAcm -= aFluxo[2,nI,2]
					EndIf

				EndIf
			Next nI

			//pedidos de compra
			For nI:= 1 To Len(aFluxo[1])
				If (aFluxo[1,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[1,nI,1] <= aArrayFlx[nX,DTFINAL])
					aArrayFlx[nX,PEDCOMPRA] += aFluxo[1,nI,2]
		
					//Se Acumular Antecipados
					//a variavel nValAux pega o valor do titulo, abate os valores antecipados e depois totaliza no saldo do dia,saldo acumulado,etc
					If (Mv_par07==2)
						nValAux := aFluxo[1,nI,2]
						nPos := aScan(aTitAntec,{|x| x[1]<=aFluxo[1,nI,1] .And. x[2]=='PA' .And. x[3]>0 })
						While (nPos > 0) .And. (nValAux > 0)
							If aTitAntec[nPos,3] >= nValAux
								aTitAntec[nPos,3] -= nValAux
								nDespAntDia += nValAux
								nValAux     := 0
								Loop
							Else
								nDespAntDia += aTitAntec[nPos,3]
								nValAux     -= aTitAntec[nPos,3]
								aTitAntec[nPos,3] := 0
							EndIf
							nPos := aScan(aTitAntec,{|x| x[1]<=aFluxo[1,nI,1] .And. x[2]=='PA' .And. x[3]>0 })
						EndDo
		
						nTotDesp  += nValAux
						nSaldoDia -= nValAux
						nSaldoAcm -= nValAux
					Else
						nTotDesp  += aFluxo[1,nI,2]
						nSaldoDia -= aFluxo[1,nI,2]
						nSaldoAcm -= aFluxo[1,nI,2]
					EndIf
		
				EndIf
			Next nI
		
			//titulos a receber
			For nI:= 1 To Len(aFluxo[5])
				If (aFluxo[5,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[5,nI,1] <= aArrayFlx[nX,DTFINAL])
					aArrayFlx[nX,RECEITAS] += aFluxo[5,nI,2]
		
					//Se Acumular Antecipados e o registro do fluxo nao eh antecipado entao
					//a variavel nValAux pega o valor do titulo, abate os valores antecipados e depois totaliza no saldo do dia,saldo acumulado,etc
					If (Mv_par07==2) .And. (aFluxo[5,nI,3]==0)
						nValAux := aFluxo[5,nI,2]
						nPos := aScan(aTitAntec,{|x| x[1]<=aFluxo[5,nI,1] .And. x[2]=='RA' .And. x[3]>0 })
						While (nPos > 0) .And. (nValAux > 0)
							If aTitAntec[nPos,3] >= nValAux
								aTitAntec[nPos,3] -= nValAux
								nReceAntDia += nValAux
								nValAux     := 0
								Loop
							Else
								nReceAntDia += aTitAntec[nPos,3]
								nValAux     -= aTitAntec[nPos,3]
								aTitAntec[nPos,3] := 0
							EndIf
							nPos := aScan(aTitAntec,{|x| x[1]<=aFluxo[5,nI,1] .And. x[2]=='RA' .And. x[3]>0 })
						EndDo
		
						nTotRec   += nValAux
						nSaldoDia += nValAux
						nSaldoAcm += nValAux
					Else
						nTotRec   += aFluxo[5,nI,2]
						nSaldoDia += aFluxo[5,nI,2]
						nSaldoAcm += aFluxo[5,nI,2]
					EndIf
		
				EndIf
			Next nI

			//pedidos de venda
			For nI:= 1 To Len(aFluxo[4])
				If (aFluxo[4,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[4,nI,1] <= aArrayFlx[nX,DTFINAL])
					aArrayFlx[nX,PEDVENDA] += aFluxo[4,nI,2]

					//Se Acumular Antecipados
					//a variavel nValAux pega o valor do titulo, abate os valores antecipados e depois totaliza no saldo do dia,saldo acumulado,etc
					If (Mv_par07==2)
						nValAux := aFluxo[4,nI,2]
						nPos := aScan(aTitAntec,{|x| x[1]<=aFluxo[4,nI,1] .And. x[2]=='RA' .And. x[3]>0 })
						While (nPos > 0) .And. (nValAux > 0)
							If aTitAntec[nPos,3] >= nValAux
								aTitAntec[nPos,3] -= nValAux
								nReceAntDia += nValAux
								nValAux     := 0
								Loop
							Else
								nReceAntDia += aTitAntec[nPos,3]
								nValAux     -= aTitAntec[nPos,3]
								aTitAntec[nPos,3] := 0
							EndIf
							nPos := aScan(aTitAntec,{|x| x[1]<=aFluxo[4,nI,1] .And. x[2]=='RA' .And. x[3]>0 })
						EndDo

						nTotRec   += nValAux
						nSaldoDia += nValAux
						nSaldoAcm += nValAux
					Else
						nTotRec   += aFluxo[4,nI,2]
						nSaldoDia += aFluxo[4,nI,2]
						nSaldoAcm += aFluxo[4,nI,2]
					EndIf

				EndIf
			Next nI

			nSaidasDia    := aArrayFlx[nX,PEDCOMPRA] +  aArrayFlx[nX,DESPESAS] - nDespAntDia
			nEntradasDia  := aArrayFlx[nX,PEDVENDA] +  aArrayFlx[nX,RECEITAS] - nReceAntDia
			nSaidasAcum   += nSaidasDia
			nEntradasAcum += nEntradasDia
		
			aArrayFlx[nX,SALDODIA]     := nSaldoDia
			aArrayFlx[nX,VARIACAODIA]  := (nSaidasDia/nEntradasDia) * 100
			aArrayFlx[nX,SAIDASACUM]   := nSaidasAcum
			aArrayFlx[nX,ENTRADASACUM] := nEntradasAcum
			aArrayFlx[nX,VARIACAOACUM] := (nSaidasAcum/nEntradasAcum) * 100
			aArrayFlx[nX,SALDOACUM]    := nSaldoAcm
		Next nX
        
		lLoop := Pmr180_Imp(oReport, aArrayFlx, {nTotDesp,nTotRec,nSaldo,nSaldoAcm,nDespAnt,nReceAnt}, MV_PAR06)
		dbSelectArea("AF8")
		dbSkip()
		oReport:EndPage()
	End
Else
	Pmr180_Imp(oReport, aArrayFlx, aTotais, nPeriodo)
EndIf

RestArea(aArea)
Return( NIL )

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇쿛rograma  쿛MR180_Imp � Autor � Edson Maricate              � Data �19.06.2002낢�
굇�          �           �       � Paulo Carnelossi (R4)       � Data �18.08.2006낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escricao 쿑az a Impressao do relatorio                                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Function PMR180_Imp(oReport, aArrayFlx, aTotais, nPeriodo)
Local aPeriodos := {STR0011,; //"Diario"
					STR0012,; //"Semanal"
					STR0013,; //"Decendial"
					STR0014,; //"Quinzenal"
					STR0015}  //"Mensal"
Local nX       := 0
Local lRet := .T.
Local oProjeto := oReport:Section(1)
Local oFluxo   := oReport:Section(2)

oFluxo:Cell("PERIODO"       ):SetBlock( {|| aArrayFlx[nx][PERIODO] })
oFluxo:Cell("VALOR_PREV_PC" ):SetBlock( {|| aArrayFlx[nx][PEDCOMPRA] })
oFluxo:Cell("VALOR_DESPESAS"):SetBlock( {|| aArrayFlx[nx][DESPESAS] })
oFluxo:Cell("VALOR_PREV_PV" ):SetBlock( {|| aArrayFlx[nx][PEDVENDA] })
oFluxo:Cell("VALOR_RECEITAS"):SetBlock( {|| aArrayFlx[nx][RECEITAS] })
oFluxo:Cell("SALDO_DIA"     ):SetBlock( {|| aArrayFlx[nx][SALDODIA] })
oFluxo:Cell("VARIACAO_DIA"  ):SetBlock( {|| aArrayFlx[nx][VARIACAODIA] })
oFluxo:Cell("SAIDAS_ACUM"   ):SetBlock( {|| aArrayFlx[nx][SAIDASACUM] })
oFluxo:Cell("ENTRADAS_ACUM" ):SetBlock( {|| aArrayFlx[nx][ENTRADASACUM] })
oFluxo:Cell("SALDO_ACUM"    ):SetBlock( {|| aArrayFlx[nx][SALDOACUM] })
oFluxo:Cell("VARIACAO_ACUM" ):SetBlock( {|| aArrayFlx[nx][VARIACAOACUM] })

oFluxo:Cell("PERIODO"       ):SetTitle(STR0016+CRLF+PadR(aPeriodos[nPeriodo], 11)) //"Periodo "

oProjeto:Init()
oProjeto:PrintLine()
oProjeto:Finish()

oReport:SkipLine()

oReport:PrintText(STR0031+" "+STR0032+" : ", oReport:Row(), 10) //"Despesas Antecipadas : "
oReport:PrintText(Transform(aTotais[5], "@E 99,999,999,999.99"), oReport:Row(), 270)
oReport:SkipLine()

oReport:PrintText(STR0033+" "+STR0032+" : ", oReport:Row(), 10) //"Receitas Antecipadas : "
oReport:PrintText(Transform(aTotais[6], "@E 99,999,999,999.99"), oReport:Row(), 270)
oReport:SkipLine()

oReport:PrintText(STR0007, oReport:Row(), 10) //"Saldo Inicial : "
oReport:PrintText(Transform(aTotais[3], "@E 99,999,999,999.99"), oReport:Row(), 270)
oReport:SkipLine()

oReport:PrintText(STR0008, oReport:Row(), 10) //"Total a Pagar : "
oReport:PrintText(Transform(aTotais[1], "@E 99,999,999,999.99"), oReport:Row(), 270)
oReport:SkipLine()

oReport:PrintText(STR0009, oReport:Row(), 10) //"Total a Receber : "
oReport:PrintText(Transform(aTotais[2], "@E 99,999,999,999.99"), oReport:Row(), 270)
oReport:SkipLine()

oReport:PrintText(STR0010, oReport:Row(), 10) //"Saldo Final : "
oReport:PrintText(Transform(aTotais[4], "@E 99,999,999,999.99"), oReport:Row(), 270)
oReport:SkipLine()
oReport:SkipLine()

oReport:SetMeter(len(aArrayFlx))
oFluxo:Init()

For nX := 1 To Len(aArrayFlx)
	oReport:IncMeter()
	oFluxo:PrintLine()
	
	If oReport:Cancel()
		oReport:SkipLine()
		oReport:PrintText(STR0034) //"*** CANCELADO PELO OPERADOR ***"
		lRet := .F.
		Exit
	EndIf
Next nX

oFluxo:Finish()

Return lRet