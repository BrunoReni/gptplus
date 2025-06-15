#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA010.ch'
#include "FWEVENTVIEWCONSTS.CH"


/*/{Protheus.doc} MATA010EVDEF
Eventos padr�o do Produto, as regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Todas as valida��es de modelo, linha, pr� e pos, tamb�m todas as intera��es com a grava��o
s�o definidas nessa classe.

Importante: Use somente a fun��o Help para exibir mensagens ao usuario, pois apenas o help
� tratado pelo MVC. 

Documenta��o sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
CLASS MATA010EVDEF FROM FWModelEvent
	
	DATA lDCL
	DATA lTAF
	DATA lDAmarCt
	DATA lHistFiscal
	DATA lHistTab 
	DATA lPIMSINT
	DATA lIntACD
	DATA lIntPms
	DATA lIntRMSOL
	DATA lGrade
	
	DATA nOpc
	
	DATA aCmps
	DATA aSM0
	
	DATA bCampoSB1
	
	DATA cCodProduto
	DATA cCodGrupo
	DATA cTipo
	DATA cArmazem
	DATA cDescr
	DATA cUniMed
	
	METHOD New() CONSTRUCTOR
	
	METHOD InTTS()
	METHOD ModelPosVld()
	METHOD Before()
	METHOD After()
	
	METHOD HistAlt()
	METHOD InitFiliais()
	METHOD HaveSaldoInicial()
	METHOD HaveSaldoFisFin()
	METHOD CommitAfterDel()
	METHOD VldDelete()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA010EVDEF
	::lDCL 		:= SuperGetMv("MV_DCLNEW",.F.,.F.) .And. ( "DH5" $ SuperGetMv("MV_CADPROD",,"|SBZ|SB5|SGI|") )
	::lTAF 		:= TAFExstInt()
	::lDAmarCt		:= SuperGetMV("MV_DAMARCT",.F.,.F.)
	::lHistTab		:= SuperGetMV("MV_HISTTAB", .F., .F.)
	::lHistFiscal := HistFiscal()
	::lPIMSINT 	:= (SuperGetMV("MV_PIMSINT",.F.,.F.))
	::lIntACD	   	:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
	::lIntPms     := GetMv("MV_INTPMS",.F.,"N")=="S"
	::lIntRMSOL   := iif(GetMv("MV_RMCOLIG",.F.,0)==0,.F.,.T.)
	::lGrade 		:= .F. 
	
	::aCmps := {}
	::aSM0 := {}
	
	::bCampoSB1 := { |x| SB1->(Field(x)) }
	
	::InitFiliais()
Return

METHOD InitFiliais() CLASS MATA010EVDEF
Local aEmpr := FwLoadSm0()

Self:aSM0 := {}
AEval( aEmpr, { | x | IIf( FwGrpCompany() == x[ 1 ], Aadd( Self:aSM0, x[ 02 ] ), Nil ) } )

Return

/*/{Protheus.doc} ModelPosVld
Metodo executado na p�s valida��o do modelo, antes de realizar a grava��o

@type metodo
 
@author Juliane Venteu
@since 27/03/2017
@version P12.1.17
/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA010EVDEF
Local lRet := .T.
Local nRecnoSB1 := 0
Local oModelSB1 := oModel:GetModel('SB1MASTER')
	
	::cCodProduto := oModel:GetValue("SB1MASTER", "B1_COD")
	::cCodGrupo	  := oModel:GetValue("SB1MASTER", "B1_GRUPO")
	::cTipo		  := oModel:GetValue("SB1MASTER", "B1_TIPO")
	::cArmazem	  := oModel:GetValue("SB1MASTER", "B1_LOCPAD")
	::cDescr	  := oModel:GetValue("SB1MASTER", "B1_DESC")
	::cUniMed	  := oModel:GetValue("SB1MASTER", "B1_UM")
	
	::nOpc := oModel:GetOperation()
	
	If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
		If ::nOpc == MODEL_OPERATION_INSERT 
			lRet := ExistChav("SB1",::cCodProduto)
		EndIf
		
		If lRet .And. ::lDCL
			lRet := DCLA010TOK(oModel)
		EndIf
		
		If lRet .And. M->B1_LOCALIZ <> "S" .And. M->B1_LOCALIZ <> "N"
			Help(" ",1,"B1_LOCALIZ")
			lRet := .F.
		EndIf
			
		//Consiste amarra��o da Conta Cont�bil X Centro de Custo
		If lRet .And. ::lDAmarCt
			If !Empty(M->B1_CONTA) .And. !Empty(M->B1_CC) .And. (!CtbAmarra(M->B1_CONTA,M->B1_CC,M->B1_ITEMCC,M->B1_CLVL))
				lRet:=.F.
			EndIf
		EndIf
		
		// Valida Custeio de OP com produto de Apropriacao Indireta		
		If lRet .And. M->B1_APROPRI = "I" .And. M->B1_AGREGCU = "1"
			Help(" ",1,"M010APR")
			lRet := .F.
		EndIf
	EndIf
	
	If ::nOpc == MODEL_OPERATION_UPDATE .Or. ::nOpc == MODEL_OPERATION_DELETE
		If ::lHistFiscal
			nRecnoSB1 := SB1->(RECNO())
			SB1->(dbSeek(xFilial("SB1")+::cCodProduto))
			::aCmps := RetCmps("SB1",::bCampoSB1)

			If ::nOpc == MODEL_OPERATION_UPDATE .And. X3Uso(GetSX3Cache('B1_IDHIST', "X3_USADO"))
				oModelSB1:SetValue("B1_IDHIST",IdHistFis())
			EndIf
			
			SB1->(dbGoTo(nRecnoSB1))
		EndIf
	EndIf

	If lRet .And. ::nOpc == MODEL_OPERATION_UPDATE
		nRecnoSB1 := SB1->(RECNO())
		SB1->(dbSeek(xFilial("SB1")+::cCodProduto))
		A013GrvLog("SB1",::cCodProduto)
		SB1->(dbGoTo(nRecnoSB1))
	EndIf

	If ::nOpc == MODEL_OPERATION_DELETE
		lRet := ::VldDelete()		
	EndIf
	
Return lRet

METHOD After(oModel, cID) CLASS MATA010EVDEF
Local nX	:= 0
Local cVar	:= ""
	
	//Grava os campos Memos Virtuais
	If Type("aMemos") == "A"
		For nX := 1 to Len(aMemos)
			cVar := aMemos[nX][2]
			MSMM(,TamSx3(aMemos[nX][2])[1],,&cVar,1,,,"SB1",aMemos[nX][1])
		Next nX
	EndIf
	
Return

/*/{Protheus.doc} InTTS
Metodo executado logo ap�s a grava��o completa do modelo, mas dentro da transa��o

@type metodo
 
@author Juliane Venteu
@since 27/03/2017
@version P12.1.17
 
/*/
METHOD InTTS(oModel) CLASS MATA010EVDEF

Local aArea      := GetArea()
Local oModelAct  := FwModelActive()
Local aCampos    := {}
Local aAreaSBM   := SBM->(GetArea())
Local cEventId   := "033"
Local oStruSB1   := FWFormStruct(1, 'SB1')
Local cSx3Cpo    := 'BM_CLASGRU'
Local nPos		 := 0

If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE

	If oModel:GetModel("MdGridSA5") == NIL
		// Faz as Consistencias entre o F.D. do Canal com o SA5.
		If B1_MONO == 'S'
			A010FDCANAL()
		EndIf
	EndIf

	If ::lPIMSINT
		// Tratamento para adicinar o campo BM_CLASGRU no layout do arquivo XML
		Aadd( aCampos, { FwX3Titulo( cSx3Cpo ), ESTFwSx3Util():xGetDescription( cSx3Cpo ), cSx3Cpo, TamSx3( cSx3Cpo )[ 3 ], TamSx3( cSx3Cpo )[ 1 ], TamSx3( cSx3Cpo )[ 2 ],NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
		If ::nOpc == MODEL_OPERATION_UPDATE
			SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
		EndIf
			
		PIMSGeraXML(STR0129,STR0047,"2","SB1",aCampos) //"Item"--## Cadastro de produtos
	EndIf
		
	If ::lTAF
		TAFIntOnLn("T007",::nOpc,cFilAnt)
	EndIf
						
EndIf
	
	If ::nOpc == MODEL_OPERATION_UPDATE
		A013GrvLog("SB1",::cCodProduto)
				
		// Atualiza a tabela QE6 - Especificacao de Produtos                     		
		QAtuB12QE6()	//SIGAQIE
		
		// Atualiza a tabela QP6 - Especificacao de Produtos                     
		QAtuB12QP6()	//SIGAQIP
	
		// Atualiza o campo B5_INTDI - Integra��o DI	
		SB5->(DbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+::cCodProduto))
			RecLock("SB5",.F.)
			SB5->B5_INTDI := '2'
			MsUnlock()
		EndIf
	EndIf
	
	If ::nOpc == MODEL_OPERATION_INSERT
				
		// Se for codigo inteligente acrescenta estrutura
		A093VldCod(::cCodProduto,.T.,,,,,,,,,.T.)

		//Event Viewer
		cMensagem	:= CRLF	//"Produto : "
		cMensagem	+= oStruSb1:GetProperty("B1_COD"	,MODEL_FIELD_TITULO) + ": " + ::cCodProduto	+ CRLF
		cMensagem	+= oStruSb1:GetProperty("B1_DESC"	,MODEL_FIELD_TITULO) + ": " + ::cDescr		+ CRLF
		cMensagem	+= oStruSb1:GetProperty("B1_TIPO"	,MODEL_FIELD_TITULO) + ": " + ::cTipo		+ CRLF
		cMensagem	+= oStruSb1:GetProperty("B1_LOCPAD"	,MODEL_FIELD_TITULO) + ": " + ::cArmazem	+ CRLF
		cMensagem	+= oStruSb1:GetProperty("B1_UM"		,MODEL_FIELD_TITULO) + ": " + ::cUniMed		+ CRLF
		EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID, FW_EV_LEVEL_INFO, "" /*cCargo*/, STR0047, cMensagem, .T.)
		
		// Envia e-mail ref. Inclusao de novos produtos - 033 
		MEnviaMail("033",{B1_FILIAL,B1_COD,B1_DESC,B1_TIPO,B1_LOCPAD,B1_UM,CUSERNAME})
	EndIf
	
	If ::nOpc == MODEL_OPERATION_DELETE
		::CommitAfterDel(oModel)
	EndIf
		
	If ::nOpc == MODEL_OPERATION_UPDATE .Or. ::nOpc == MODEL_OPERATION_DELETE
		// Gravacao do historico das alteracoes.		
		If ::lHistFiscal .And. Len(::aCmps) > 0
			nPos := Ascan(::aCmps,{ |x| x[1] == 'B1_IDHIST' } )
			::aCmps[nPos][2] := SB1->B1_IDHIST
			GrvHistFis("SB1", "SS4", ::aCmps)
		EndIf
	EndIf
	
	LJ110AltOk()

FwModelActive(oModelAct)
RestArea(aAreaSBM)
RestArea(aArea)

Return

/*/{Protheus.doc} HistAlt
Grava historico de altera��o dos campos "B1_DESC","B1_PICMENT","B1_PICMRET", se existir

@type metodo
 
@author Juliane Venteu
@since 02/03/2017
@version P12.1.17
 
/*/
METHOD HistAlt(oFieldSA2) CLASS MATA010EVDEF
Local dDataAlt := Date()
Local cHoraAlt := Time()
Local lProcess	:=	.F.
local linsert := ::nOpc == MODEL_OPERATION_INSERT
Local lUpdat := ::nOpc == MODEL_OPERATION_UPDATE 
Local cFilialAIF := xFilial("AIF")
Local cFilialSB1 := xFilial("SB1")
Local aFields 
Local nX


	//-------------------------------------------------------------------------------//
	//Verifico a Operacao para gravar os dados na inclusao conforme legado.          //
	//-------------------------------------------------------------------------------//
	 If lUpdat
	 		aFields		:= {"B1_DESC","B1_PICMENT","B1_PICMRET","B1_CODANT"}
	 		lProcess	:= .T.
	 Else 
	 		IiF (!Empty(M->B1_CODANT),lProcess := .T.,lProcess)
	 		aFields:={{"B1_CODANT",""}}
	 EndIF
	
	//--------------------------------------------------------------------------------
	// Cria o historico das alteracoes antes de gravar os novos dados do fornecedor.
	// Se deixa pra fazer depois de gravar, n�o tem como pegar os valores que estavam
	// nos campos antes da altera��o
	//--------------------------------------------------------------------------------	
	If lProcess
		For nX:=1 to Len(aFields)
			If  lInsert .or. (SB1->&(aFields[nX]) <> M->&(aFields[nX])) 
				MSGrvHist(cFilialAIF,;			// Filial de AIF
				cFilialSB1,;					// Filial da tabela SB1
				"SB1",;							// Tabela SB1
				"",;							// Codigo do cliente
				"",;							// Loja do cliente
				If (lUpdat,aFields[nX],aFields[nX][1]),;			// Campo alterado
				If (lUpdat,SB1->&(aFields[nX]),aFields[nX][2]),;	// Conteudo antes da alteracao
				dDataAlt,;						// Data da alteracao
				cHoraAlt,;						// Hora da alteracao
				::cCodProduto)					// Codigo do produto
			EndIf
		Next nX
	EndIf
	
Return

/*/{Protheus.doc} Before
Executado dentro da transa��o, antes da grava��o dos dados do fornecedor.

@type metodo
 
@author Juliane Venteu
@since 02/03/2017
@version P12.1.17
 
/*/
METHOD Before(oModel, cID) CLASS MATA010EVDEF

local lInsert := ::nOpc == MODEL_OPERATION_INSERT
Local lUpdate := ::nOpc == MODEL_OPERATION_UPDATE

	If cID == "SB1MASTER"
		If (lInsert .Or. lUpdate) .and. ::lHistTab
			::HistAlt(oModel:getModel("SB1MASTER"))
		EndIf
	EndIf
Return

METHOD HaveSaldoFisFin() CLASS MATA010EVDEF
Local lRet		:= .T.
Local cQuery	:= ""
Local cAliasAux	:= GetNextAlias()
	
	cQuery := " SELECT B2_QATU FROM " + RetSqlName("SB2")
	cQuery += " WHERE D_E_L_E_T_  = ' ' "
	cQuery += " AND B2_COD = '" + ::cCodProduto + "' "
	cQuery += " AND B2_QATU <> 0 "
	If !(Empty(FwFilial("SB1")))
		cQuery += " AND B2_FILIAL = '" + xFilial("SB2") + "' "
	EndIf 
	
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasAux,.T.,.T.)

	If !(cAliasAux)->(Eof())
		Help(" ",1,"MA0101")
		lRet := .F.
	EndIf
	
	(cAliasAux)->(DbCloseArea())
	
Return lRet

METHOD HaveSaldoInicial() CLASS MATA010EVDEF
Local lRet		:= .T.
Local lDadosSBZ	:= .F.
Local cQuery	:= ""
Local cAliasAux	:= GetNextAlias()

	lDadosSBZ := !RetArqProd(::cCodProduto)
	
	cQuery := " SELECT B9_QINI "
	cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += " INNER JOIN " + RetSqlName("SB9") + " SB9 "
	cQuery += " ON B1_COD = B9_COD "
	If lDadosSBZ
		cQuery += " INNER JOIN " + RetSqlName("SBZ") + " SBZ "
		cQuery += " ON BZ_COD = B9_COD "
	EndIf
	cQuery += " WHERE SB1.D_E_L_E_T_  = ' ' "
	cQuery += " AND SB9.D_E_L_E_T_  = ' ' "
	cQuery += " AND B9_COD = '" + ::cCodProduto + "' "
	cQuery += " AND B9_QINI <> 0 "
	If lDadosSBZ
		cQuery += " AND BZ_FANTASM = 'S' "
		cQuery += " AND SBZ.D_E_L_E_T_  = ' ' "
	Else
		cQuery += " AND B1_FANTASM = 'S' "
	EndIf
	If !(Empty(FwFilial("SB1")))
		cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += " AND B9_FILIAL = '" + xFilial("SB9") + "' "
		If lDadosSBZ
			cQuery += " AND BZ_FILIAL = '" + xFilial("SBZ") + "' "
		EndIf
	EndIf 
	
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasAux,.T.,.T.)

	If !(cAliasAux)->(Eof())
		Help(" ",1,"MA0101")
		lRet := .F.
	EndIf
	
	(cAliasAux)->(DbCloseArea())
	
Return lRet

METHOD CommitAfterDel(oModel) CLASS MATA010EVDEF
Local nTamRef     := Val(Substr(GetMv("MV_MASCGRD"),1,2))
Local cCodGr
Local aArea := GetArea()
Local aAreaSB1 := SB1->(getArea())
Local aAreaSB4 := SB4->(getArea())
Local aAreaSB2 := SB2->(getArea())
Local aAreaSB3 := SB3->(getArea())
Local aAreaSA5 := SA5->(getArea())
Local aFiliais
Local nX
Local lApagaSB5
Local lApagaDH5
Local cSeek
Local lFantasma := (RetFldProd(::cCodProduto,"B1_FANTASM") == "S")

	//Deletando informa��es complementares do Produto (SIGAEIC/SIGAEDC/SIGAEEC) - Trade Easy
	If (nModulo == 17 .Or. nModulo == 50  .Or. nModulo == 29)
		EYJ->(DbSetOrder(1))
		If EYJ->(DbSeek(xFilial("EYJ") + ::cCodProduto))
			If EYJ->(RecLock("EYJ",.F.))
				EYJ->(DbDelete())
				EYJ->(MsUnlock())
			EndIf
		EndIf
	EndIf
				
	If ::lGrade
		cCodGr := Substr(::cCodProduto,1,nTamRef)
		
		If SB1->(!DbSeek(xFilial("SB1")+cCodGr))
			aFiliais := If(! Empty(FwFilial("SB4")) .and. Empty(FwFilial("SB1")), aClone(::aSM0), {xFilial("SB4")})
			For nX := 1 to Len(aFiliais)
				If SB4->(dbSeek(aFiliais[nX]+cCodGr))
					RecLock("SB4",.F.,.T.)
					SB4->(DbDelete())
				EndIf
			Next
		EndIf
	EndIf
	
	dbSelectArea("SB2")
	aFiliais := If(! Empty(FwFilial("SB2")) .and. Empty(FwFilial("SB1")), aClone(::aSM0), {xFilial("SB2")})
	For nX := 1 to Len(aFiliais)
		dbSeek(aFiliais[nX]+::cCodProduto)
		While !EOF() .And. aFiliais[nX]+::cCodProduto == SB2->(B2_FILIAL+B2_COD)
			RecLock("SB2",.F.,.T.)
			dbDelete()
			dbSkip()
		EndDo
	Next
	
	dbSelectArea("SB3")	
	aFiliais := If(! Empty(FwFilial("SB3")) .and. Empty(FwFilial("SB1")), aClone(::aSM0), {xFilial("SB3")})
	For nX := 1 to Len(aFiliais)
		dbSeek(aFiliais[nX]+::cCodProduto)
		If Found()
			RecLock("SB3",.F.,.T.)
			dbDelete()
		EndIf
	Next
	
	//Verifica se a tabela SB5 n�o existe no modelo de dados
	//Se ela foi carregada pelo modelo, o modelo j� apagou a mesma
	If oModel:GetModel("SB5DETAIL") == NIL 
		lApagaSB5 := .T.
		
		dbSelectArea("SB5")
		If Empty(FwFilial("SB5")) .And. !Empty(FwFilial("SB1"))
			cSeek := SB1->B1_FILIAL+AllTrim(::cCodProduto)
			For nX := 1 to Len(::aSM0)
				dbSelectArea("SB1")
				dbSetOrder(1)
				If dbSeek(::aSM0[nX]+::cCodProduto)
					If cSeek <> (::aSM0[nX]+AllTrim(::cCodProduto))
						lApagaSB5 := .F.
						Exit
					EndIf
				EndIf
			Next nX
		EndIf
		
		If lApagaSB5
			dbSelectArea("SB5")
			aFiliais := If(! Empty(FwFilial("SB5")) .and. Empty(FwFilial("SB1")), aClone(::aSM0), {xFilial("SB5")})
			For nX := 1 to Len(aFiliais)
				dbSeek(aFiliais[nX]+::cCodProduto)
				If Found()
					RecLock("SB5",.F.,.T.)
					dbDelete()
				EndIf
			Next
		EndIf
	EndIf
	
	// Se o DCL esta ativado e n�o foi carregado no modelo, apaga os dados
	If ::lDCL .And. oModel:GetModel("DH5DETAIL") == NIL
		lApagaDH5 := .T.
		dbSelectArea("DH5")
		If Empty(FwFilial("DH5")) .And. !Empty(FwFilial("SB1"))
			cSeek := SB1->B1_FILIAL+AllTrim(::cCodProduto)
			For nX := 1 to Len(::aSM0)
				dbSelectArea("SB1")
				dbSetOrder(1)
				If dbSeek(aSM0CodFil[nX]+::cCodProduto)
					If cSeek <> (aSM0CodFil[nX]+AllTrim(::cCodProduto))
						lApagaDH5 := .F.
						Exit
					EndIf
				EndIf
			Next nX
		EndIf
		If lApagaDH5
			dbSelectArea("DH5")
			aFiliais := If(! Empty(FwFilial("DH5")) .and. Empty(FwFilial("SB1")), aClone(::aSM0), {xFilial("DH5")})
			For nX := 1 to Len(aFiliais)
				dbSeek(aFiliais[nX]+::cCodProduto)
				If Found()
					RecLock("DH5",.F.,.T.)
					dbDelete()
				EndIf
			Next
		EndIf
	EndIf
	
	If lFantasma
		dbSelectArea("SB9")
		aFiliais := If(! Empty(FwFilial("SB9")) .and. Empty(FwFilial("SB1")), aClone(::aSM0), {xFilial("SB9")})
		For nX := 1 to Len(aFiliais)
			dbSeek(aFiliais[nX]+::cCodProduto)
			While !Eof() .And. aFiliais[nX]+::cCodProduto==B9_FILIAL+B9_COD
				If B9_QINI == 0
					RecLock("SB9",.F.,.T.)
					dbDelete()
				Endif
				dbSkip()
			EndDo
		Next
	EndIf
	
	If oModel:GetModel("SA5DETAIL") == NIL
		dbSelectArea("SA5")
		dbSetOrder(2)
		aFiliais := If(! Empty(FwFilial("SA5")) .and. Empty(FwFilial("SB1")), aClone(::aSM0), {xFilial("SA5")})
		For nX := 1 to Len(aFiliais)
			dbSeek(aFiliais[nX]+::cCodProduto)
			While !EOF() .And. aFiliais[nX] == SA5->A5_FILIAL .and. ::cCodProduto == SA5->A5_PRODUTO
				RecLock("SA5",.F.,.T.)
				dbDelete()
				dbSkip()
			EndDo
		Next		
	EndIf
	
	// Remove a amarracao cod. Externo X cod. Interno - tabela XXF - De/Para
	If FWXX4Seek("MATA010")
   		CFGA070Mnt( , 'SB1', 'B1_COD', , ::cCodProduto, .T. )
	EndIf
	
	// Funcao Especifica SIGAEIC - AVERAGE
	MTA010E()

RestArea(aAreaSA5)
RestArea(aAreaSB3)	
RestArea(aAreaSB2)
RestArea(aAreaSB4)
RestArea(aAreaSB1)
RestArea(aArea)
Return

METHOD VldDelete() CLASS MATA010EVDEF
Local lRet := .T.
	
	lRet := ::HaveSaldoFisFin()
		
	If lRet
		lRet :=!MdtValESb1(::cCodProduto) //Inverte o resultado, pois a fun��o retorna VERDADEIRO caso n�o possa apagar o produto
	EndIf
		
	If lRet
		lRet := ::HaveSaldoInicial()
	EndIf
		
	If lRet .And. ::lIntACD
		// Verifica se existe Produto x Endere�o cadastrado (ACD)              
		lRet := !MTA010PXE(::cCodProduto)
		
		If lRet
		//Verifica se existe Mestre de Inventario cadastrado para o produto (ACD)  
			lRet := !MTA010MI(::cCodProduto)
		EndIf
	EndIf
		
	If lRet .And. ::lIntPms
		// VERIFICA SE O PRODUTO ESTA CADASTRADO E EM USO POR ALGUMA COMPOSICAO NO PMS
		lRet := PmsVerComp(::cCodProduto)
	EndIf
		
	If lRet
		lRet := !MA10VerAV()
	EndIf
		
	// Fun��o usada para validar se existe integra��o do Protheus com o RM Solum e
	// Para chamar a valida��o espec�fica do RM Solum na dele��o do Produto. (PMSXFUNB)
	If lRet .And. ::lIntRMSOL
		lRet := PmsSlmPrd("PRD")
	EndIf
	
	::lGrade := SB1->B1_GRADE=="S"
		
Return lRet
