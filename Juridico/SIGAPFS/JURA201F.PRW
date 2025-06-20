#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA201F.CH"

Static __xFilNX6 := xFilial("NX6")
Static __xFilNXQ := xFilial("NXQ")
Static __xFilCTP := xFilial("CTP")
Static __xFilNXR := xFilial("NXR")
Static __xFilNXF := xFilial("NXF")

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201FConv()
Rotina obter as taxas e o valor de convers�o utilizadas no faturamento

@Param cMoeda1    Moeda do Faturamento
@Param cMoeda2    Moeda da Condi��o (Ex: moeda do lan�amento a ser convertido)
@Param nVlOrig    Valor na Moeda de condi��o (valor � ser convertido)
@Param cTpExec    Tipo de Execu��o da Rotina de Faturamento:
                    1 - Pr�-Fatura
                    2 - Regerar Pr�
                    3 - Minuta de Pr�
                    4 - Minuta da Fatura
                    5 - Fatura
                    6 - Reemitir Pr� Fatura de fatura cancelada
                    7 - Confer�ncia / Fatura
                    8 - Gerar Tittulo
                    9 - Fatura SISCOSERV
                    A - Utiliza a cota��o enviada por par�metro "nTaxaConv"
@Param dCotacao   Data da Cota��o di�ria ou para cota��o mensal
@Param cCodFImpr  C�digo da Fila de Impress�o de Fatura (Convers�o feita pelas cota��es da Fila)
@Param cPreFt     C�digo da Pr�-Fatura (Convers�o feita pelas cota��es da Pr�-Fatura)
@Param cXFilial   C�digo da Filial usada para convers�o
@Param cEscr      C�digo do Escrit�rio da Fatura
@Param cFatura    C�digo da Fatura (Convers�o feita pelas cota��es da Fatura)
@Param cTipoConf  Ignora o parametro MV_JTPCONF e for�a a cota��o '1' = Mesma da Fatura / '2' = Cota��o Di�ria
@Param nDecimal   Controla a precis�o de casas decimais que ser� feita a conver��o
@Param nTaxaConv  Taxa para convers�o (cMoeda2) dos valores
@Param nTaxaMoe1  Taxa para convers�o (cMoeda1) dos valores

@Return    aRet    [1] Valor Convertido
                    [2] Taxa 1 (Taxa do faturamento)
                    [3] Taxa 2 (Taxa da condi��o)
                    [4] Texto com o erro ao obter cota��o
                    [5] fator de convers�o com precis�o de decimal de ponto fixo

@author David G. Fernandes
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201FConv(cMoeda1, cMoeda2, nVlOrig, cTpExec, ;
					dCotacao, cCodFImpr, cPreFt, cXFilial, ;
					cEscr, cFatura, cTipoConf, nDecimal, ;
					nTaxaConv, nTaxaMoe1 )
Local aArea       := GetArea()
Local aRet        := {}
Local cMoedaNac   := SuperGetMv('MV_JMOENAC',, '01')
Local cTipoConv   := SuperGetMv('MV_JTPCONV',, '1' )  // Cota��o '1' = Di�ria / '2' = Mensal
Local nValorConv  := 0
Local nTaxa1      := 1.0
Local nTaxa2      := 1.0
Local lCotac1     := .F. // Busca a cota��o do per�odo
Local lCotac2     := .F.
Local lMensal     := .F.
Local cErro       := ""
Local pFatorConv  := DEC_CREATE('1', 64, 18) //Decimal de ponto fixo para aumentar a precis�o da convers�o
Local pValorConv  := DEC_CREATE('0', 64, 18) //Decimal de ponto fixo para aumentar a precis�o da convers�o
Local aCotac      := {}

Default cXFilial  := __xFilCTP
Default cTipoConf := SuperGetMv('MV_JTPCONF',, '1' )  // Cota��o usada nos titulos '1' = Mesma da Fatura / '2' = Cota��o Di�ria
Default nVlOrig   := 0
Default dCotacao  := Date()
Default nDecimal  := 18
Default nTaxaConv := 1
Default nTaxaMoe1 := 1

If Empty(__xFilCTP) //Verifica se a tabela � compartilhada
	cXFilial  := __xFilCTP
EndIf

If ((cMoeda1 == cMoeda2) .And. (cMoeda1 == cMoedaNac)) .Or. (nVlOrig == 0)
	
	aRet := {nVlOrig, nTaxa2, nTaxa1, cErro, pFatorConv}
	
Else

	If (cTipoConv == "2") .And. (cTpExec != "9")
		lMensal := .T.
	EndIf
	
	If (cTipoConf == "2") .And. (cTpExec == "8")
		lMensal := .F.
	
	ElseIf (cTpExec == "8") //Cota��o da Fatura
		aCotac  := J201FCotFat(cMoeda1, cMoedaNac, cEscr, cFatura)
		nTaxa1  := aCotac[1]
		lCotac1 := aCotac[2]

		aCotac  := J201FCotFat(cMoeda2, cMoedaNac, cEscr, cFatura)
		nTaxa2  := aCotac[1]
		lCotac2 := aCotac[2]
	
	ElseIf !Empty(cCodFImpr) //Fila de Emiss�o de Fatura

		aCotac  := J201FCotFil(cMoeda1, cMoedaNac, cCodFImpr)
		nTaxa1  := aCotac[1]
		lCotac1 := aCotac[2]

		aCotac := J201FCotFil(cMoeda2, cMoedaNac, cCodFImpr)
		nTaxa2  := aCotac[1]
		lCotac2 := aCotac[2]
		
	ElseIf cTpExec $ "2|6" // Refazer  pr�-fatura | Refazer  pr�-fatura de Fatura cancelada 
		
		aCotac  := J201FCotPre(cMoeda1, cMoedaNac, cPreFt)
		nTaxa1  := aCotac[1]
		lCotac1 := aCotac[2]

		aCotac  := J201FCotPre(cMoeda2, cMoedaNac, cPreFt)
		nTaxa2  := aCotac[1]
		lCotac2 := aCotac[2]

	ElseIf cTpExec == "A" // Taxa Moeda 2 recebida por par�metro
		nTaxa1  := nTaxaMoe1
		nTaxa2  := nTaxaConv
		lCotac1 := .T.
		lCotac2 := .T.
		
	Else //For�a a busca pela cota��o do periodo (di�ria / mensal)
		
		lCotac1 := .F.
		lCotac2 := .F.
		
	EndIf
	
	If !lCotac1 .Or. !lCotac2 //Se n�o localizou umas das cota��es, faz a busca conforme o aparametro MV_JTPCONV
		If !lMensal
			If !lCotac1
				aCotac  := J201FCotDia(cMoeda1, cMoedaNac, dCotacao, cXFilial)
				nTaxa1  := aCotac[1]
				lCotac1 := aCotac[2]
				cErro   := aCotac[3]
			EndIf

			If !lCotac2
				aCotac  := J201FCotDia(cMoeda2, cMoedaNac, dCotacao, cXFilial)
				nTaxa2  := aCotac[1]
				lCotac2 := aCotac[2]
				cErro   += Iif(!Empty(aCotac[3]), +CRLF, "") + aCotac[3]
			EndIf
		Else
			If !lCotac1
				aCotac  := J201FCotMes(cMoeda1, cMoedaNac, dCotacao)
				nTaxa1  := aCotac[1]
				lCotac1 := aCotac[2]
				cErro   := aCotac[3]
			EndIf

			If !lCotac2
				aCotac  := J201FCotMes(cMoeda2, cMoedaNac, dCotacao)
				nTaxa2  := aCotac[1]
				lCotac2 := aCotac[2]
				cErro   += Iif(!Empty(aCotac[3]), + CRLF, "") + aCotac[3]
			EndIf
		EndIf
	EndIf
	
	If (lCotac1 .And. lCotac2)
		If (cMoeda1 == cMoeda2)
			nValorConv := nVlOrig
			
			If (cMoeda1 == cMoedaNac)
				nTaxa1 := 1.0
				nTaxa2 := 1.0
			Else
				nTaxa1 := IIf(nTaxa1 == 0, 1.0, nTaxa1)
				nTaxa2 := IIf(nTaxa2 == 0, 1.0, nTaxa2)
			EndIf
		Else
			If (nTaxa1 > 0) .And. (nTaxa2 > 0)
				pFatorConv := DEC_DIV(DEC_CREATE(cValToChar(nTaxa2), 64, nDecimal), DEC_CREATE(cValToChar(nTaxa1), 64, nDecimal))
				pValorConv := DEC_CREATE(cValToChar(nVlOrig), 64, nDecimal)
				nValorConv := Val(cValToChar(DEC_RESCALE(DEC_MUL(pFatorConv, pValorConv), nDecimal, 0)))
			Else //Sem Taxa
				nValorConv := nVlOrig
				nTaxa1 := 1.0
				nTaxa2 := 1.0
			EndIf
		EndIf
		
	Else
		nValorConv := nVlOrig
		nTaxa1     := 1.0
		nTaxa2     := 1.0
	EndIf
	
	aRet := {nValorConv, nTaxa2, nTaxa1, cErro, pFatorConv}
	
EndIf

RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FCotFat()
Rotina para buscar a cota��o da moeda a partir das cota�oes da fatura.

@param  cMoeCot   Moeda da cota��o desejada
@param  cMoedaNac  Moeda Nacional (Moeda forte)
@param  cEscr     Escrit�rio da Fatura 
@param  cFatura   C�digo do escrit�rio da fatura.

@Return aCotac    Array com cota��o da aturas (NXF)
        aCotac[1] Valor da cota��o da moeda cMoeCot
        aCotac[2] .F. Se n�o localizou a cota��o e precisa buscar na di�ria ou mensal

@author  Luciano Pereira dos Santos
@since   12/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201FCotFat(cMoeCot, cMoedaNac, cEscr, cFatura)
Local aCotac := {0, .F.}

If (cMoeCot != cMoedaNac)
	NXF->(DbSetOrder(2)) ///NXF_FILIAL+NXF_CFATUR+NXF_CESCR+NXF_CMOEDA
	If NXF->(DbSeek( __xFilNXF + cFatura + cEscr + cMoeCot))
		aCotac := {NXF->NXF_COTAC1, .T.}
	EndIf
Else
	aCotac := {1, .T.}
EndIf

Return aCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FCotFil(cMoeCot, cMoedaNac, cFila)
Rotina buscar a cota��o da moeda a partir da fila de emiss�o da fatura

@param  cMoeCot   Moeda da cota��o desejada
@param  cMoedaNac  Moeda Nacional (Moeda forte)
@param  cFila     Fila de emiss�o da fatura 


@Return aCotac    Array com cota��o da aturas (NX6)
        aCotac[1] Valor da cota��o da moeda cMoeCot
        aCotac[2] .F. Se n�o localizou a cota��o e precisa buscar na di�ria ou mensal

@author  Luciano Pereira dos Santos
@since   12/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201FCotFil(cMoeCot, cMoedaNac, cFila)
Local aCotac := {0, .F.}

If (cMoeCot != cMoedaNac)
	NX6->(DbSetOrder(1)) //NX6_FILIAL+NX6_CFILA+NX6_CMOEDA
	If NX6->(DbSeek( __xFilNX6 + cFila + cMoeCot))
		aCotac := {NX6->NX6_COTAC1, .T.}
	EndIf
Else
	aCotac := {1, .T.}
EndIf

Return aCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FCotPre(cMoeCot, cMoedaNac, cPreFt)
Rotina buscar a cota��o da moeda a partir das cota��es da pr�-fatura

@param  cMoeFat   Moeda da fatura
@param  cMoedaNac  Moeda Nacional (Moeda forte)
@param  cPreFt    C�digo da pr�-fatura 

@Return aCotac    Array com cota��o da aturas (NXR)
        aCotac[1] Valor da cota��o da moeda cMoeCot
        aCotac[2] .F. Se n�o localizou a cota��o e precisa buscar na di�ria ou mensal

@author  Luciano Pereira dos Santos
@since   12/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201FCotPre(cMoeCot, cMoedaNac, cPreFt)
Local aCotac := {0, .F.}

If (cMoeCot != cMoedaNac)
	NXR->(DbSetOrder(1)) //NXR_FILIAL+NXR_CPREFT+NXR_CMOEDA
	If NXR->(DbSeek( __xFilNXR + cPreFt + cMoeCot))
		aCotac := {NXR->NXR_COTAC, .T.}
	EndIf
Else
	aCotac := {1, .T.}
EndIf

Return aCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FCotDia
Rotina buscar a cota��o di�ria da moeda.

@param  cMoeCot   Moeda da cota��o
@param  cMoedaNac Moeda Nacional (Moeda forte)
@param  dCotacao  Data da cota��o
@param  cCTPFil   Filial da tabela de c�mbio CTP

@Return aCotac    Array com cota��o da aturas (NXF)
        aCotac[1] Valor da cota��o da moeda cMoeCot
        aCotac[2] .F. Se busca retornou com algum erro
        aCotac[3] Mensagem de critica

@author  Luciano Pereira dos Santos
@since   12/11/2018
/*/
//-------------------------------------------------------------------
Function J201FCotDia(cMoeCot, cMoedaNac, dCotacao, cCTPFil)
Local cDtCotac := DtoS(dCotacao)
Local aCotac   := {}

	CTP->(DbSetOrder(1)) //CTP_FILIAL+DTOS(CTP_DATA)+CTP_MOEDA
	If CTP->(DbSeek( cCTPFil + cDtCotac + cMoeCot))
		If CTP->CTP_BLOQ == "2"
			aCotac := {CTP->CTP_TAXA, .T., ""}
		Else
			aCotac := {1, .F., I18n(STR0006, {cMoeCot}) } //# "A moeda '#1' est� bloqueada."
		EndIf
	Else
		If (cMoeCot == cMoedaNac)
			aCotac := {1, .T., ""}
		Else
			aCotac := {1, .F., I18n(STR0007, {cMoeCot, DtoC(dCotacao)}) } //# "N�o existe cota��o di�ria na moeda '#1' para a data '#2'."
		EndIf
	EndIf

Return aCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FCotMes(cMoeCot, cMoedaNac, dCotacao)
Rotina buscar a cota��o di�ria da moeda.

@param  cMoeCot   Moeda da cota��o
@param  cMoedaNac  Moeda Nacional (Moeda forte)
@param  dCotacao  Data da cota��o 

@return aCotac    Array com cota��o da aturas (NXF)
        aCotac[1]  Valor da cota��o da moeda cMoeCot
        aCotac[2]  .F. Se busca retornou com algum erro
        aCotac[3]  Mensagem de critica

@author  Luciano Pereira dos Santos
@since   12/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201FCotMes(cMoeCot, cMoedaNac, dCotacao)
Local cAnoMes := SubStr(DtoS(dCotacao), 1, 6)
Local aCotac  := {}

NXQ->(DbSetOrder(1)) // NXQ_FILIAL + NXQ_ANOMES + NXQ_CMOEDA
If NXQ->(DbSeek( __xFilNXQ + cAnoMes + cMoeCot))
	aCotac := {NXQ->NXQ_COTAC, .T., ""}
Else
	If (cMoeCot == cMoedaNac)
		aCotac := {1, .T., ""}
	Else
		aCotac := {1, .F., I18n(STR0008, {cMoeCot, Transform(cAnoMes, PesqPict("NXQ", "NXQ_ANOMES"))}) } //# "N�o existe cota��o mensal na moeda '#1' para o ano-m�s '#2'."
	EndIf
EndIf

Return aCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FVlCot
Rotina que retorna se h� cota��o cadastrada para a moeda e data.

@param  cMoeda      Moeda da cota��o
@param  dCotacao    Data da cota��o
@param  lExibeErro  Indica se devem ser exibidas mensagens 

@return lRet        .T. se houver cota��o cadastrada

@author  Jorge Martins
@since   16/12/2019
/*/
//-------------------------------------------------------------------
Function J201FVlCot(cMoeda, dCotacao, lExibeErro)
	Local lRet         := .T.
	Local cTipoConv    := SuperGetMv('MV_JTPCONV',, '1' ) // Cota��o '1' = Di�ria / '2' = Mensal
	Local nCotac       := 0
	Local cProblema    := ""
	Local cSolucao     := ""
	Local cCampo       := ""
	Local aCotac       := {}

	Default dCotacao   := Date()
	Default lExibeErro := .T.

	If cTipoConv == '1'
		
		aCotac := JurGetDados("CTP", 1, xFilial("CTP") + DtoS(dCotacao) + cMoeda, {"CTP_BLOQ", "CTP_TAXA"})
		
		If Empty(aCotac)
			cProblema := I18n(STR0007, {cMoeda, DtoC(dCotacao)}) //# "N�o existe cota��o di�ria na moeda '#1' para a data '#2'."
			lRet      := .F.
			
		ElseIf Len(aCotac) == 2
			If aCotac[1] == "1"
				cProblema := I18n(STR0006, {cMoeCot}) //# "A moeda '#1' est� bloqueada."
				lRet      := .F.
			
			ElseIf aCotac[2] == 1
			
				// Verifica se a cota��o � 1 tamb�m na SM2, ou se est� zerada
				cCampo := "M2_MOEDA" + SubStr(cMoeda, 2, 1)
				nCotac := JurGetDados("SM2", 1, DtoS(dCotacao), cCampo)
				
				If nCotac == 0
					cProblema := I18n(STR0010, {DToC(dCotacao), cMoeda}) //"A cota��o do dia #1 para a moeda #2 est� com valor zerado."
					lRet      := .F.
				EndIf
			Else
				nCotac := aCotac[2]
			EndIf
		EndIf

	ElseIf cTipoConv == '2'
		aCotac := JurGetDados("NXQ", 1, xFilial("NXQ") + AnoMes(dCotacao) + cMoeda, {"NXQ_COTAC", "NXQ_CMOEDA"})

		If Empty(aCotac)
			cProblema := I18n(STR0012, {MesExtenso(Month(dCotacao)), cValToChar(Year(dCotacao)), cMoeda}) // "Cota��o do m�s de #1 de #2 para a moeda #3 n�o existe."
			lRet      := .F.
		ElseIf Len(aCotac) == 2 
			nCotac := aCotac[1]
			If nCotac == 0
				cProblema := I18n(STR0013, {MesExtenso(Month(dCotacao)), cValToChar(Year(dCotacao)), cMoeda}) // "Cota��o do m�s de #1 de #2 para a moeda #3 est� com valor zerado."
				lRet      := .F.
			EndIf
		EndIf

	EndIf

	If !Empty(cProblema)
		lRet     := .F.
		cSolucao := STR0011 // "Indique uma cota��o v�lida para a moeda e data indicadas, e realize a opera��o novamente."
	EndIf

	If !lRet .And. lExibeErro
		JurMsgErro(cProblema, , cSolucao)
	EndIf

Return {lRet, nCotac}
