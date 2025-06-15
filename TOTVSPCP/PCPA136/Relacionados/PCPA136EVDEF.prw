#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA136.CH"

/*/{Protheus.doc} PCPA136EVDEF
Eventos padr�es do Cadastro de Demandas do MRP
@author Marcelo Neumann
@since 17/01/2019
@version P12
/*/
CLASS PCPA136EVDEF FROM FWModelEvent

	DATA oGrade AS OBJECT

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()
	METHOD GridLinePosVld()
	METHOD ModelPosVld()
	METHOD BeforeTTS()
	METHOD Activate()

ENDCLASS

METHOD New(oModel) CLASS PCPA136EVDEF
	//Instancia classe Grade
	If SVR->(FieldPos("VR_GRADE")) > 0
		::oGrade := PCPGRADE():New(oModel, "SVR_DETAIL", "SVR_GRADE", "VR_PROD", "VR_DSCPROD", "VR_QUANT", "VR_IDGRADE", "VR_ITEMGRD", "VR_REFGRD", "VR_GRADE", "VR_FILIAL|VR_SEQUEN|VR_CODIGO|VR_REGORI", {"VR_OPC","VR_OPCGRD"}, {"VR_MOPC","VR_MOPCGRD"})
	EndIf
Return


METHOD Activate() CLASS PCPA136EVDEF

	Pergunte("PCPA136", .F.)

Return

/*/{Protheus.doc} GridLinePreVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o da linha do Grid
@author lucas.franca
@since 28/01/2019
@version 1.0
@param 01 oSubModel    , Objeto  , Modelo principal
@param 02 cModelId     , Caracter, Id do submodelo
@param 03 nLine        , Num�rico, Linha do grid
@param 04 cAction      , Caracter, A��o executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param 05 cId          , Caracter, nome do campo
@param 06 xValue       , Vari�vel, Novo valor do campo
@param 07 xCurrentValue, Vari�vel, Valor atual do campo
@return lOK
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS PCPA136EVDEF
	Local lOk      := .T.

	If cModelID == "SVR_DETAIL"
		If cAction == "CANSETVALUE"
			If cId $ "|VR_PROD|VR_DATA|VR_QUANT|VR_OPC|VR_MOPC|VR_LOCAL|"
				If cId $ "|VR_PROD|"
					If oSubModel:GetDataID(nLine) > 0 .OR. SVR->(FieldPos("VR_GRADE")) = 0 .Or. ::oGrade:gravadoNoBanco(oSubModel, nLine, "SVR_GRADE", "VR_IDGRADE")
						lOk := .F.
					EndIf
				EndIf
				If cId $ "|VR_OPC|VR_MOPC|"
					lOk := .F.
				EndIf
				If cId $ "|VR_LOCAL|" .And. oSubModel:GetValue("VR_TIPO") != "9"
					// N�o permite alterar o armaz�m de registros que n�o sejam manual
					lOk := .F.
				EndIf
				If lOk .And. oSubModel:GetValue("VR_TIPO") != "9"
					//N�o permite alterar o c�digo do produto, a data e a quantidade da demanda
					//de registros que foram importados.
					lOk := .F.
				EndIf
			EndIf
		ElseIf cAction == "SETVALUE"
			If xValue <> xCurrentValue
				If cId $ "|VR_PROD|VR_DATA|VR_QUANT|VR_DOC|"
					oSubModel:LoadValue("VR_NRMRP", "")
					
					If cId $ "|VR_PROD|VR_DATA|"
						oSubModel:LoadValue("VR_OPC" , " ")
						oSubModel:LoadValue("VR_MOPC", " ")
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lOk

/*/{Protheus.doc} GridLinePosVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o da linha do Grid
@author douglas.heydt
@since 30/04/2019
@version 1.0
@param 01 oSubModel    , Objeto  , Modelo principal
@param 02 cModelId     , Caracter, Id do submodelo
@param 03 nLine        , Num�rico, Linha do grid
@return lOK
/*/
METHOD GridLinePosVld(oSubModel, cModelID, nLine) CLASS PCPA136EVDEF
	Local lOk := .T.

	If cModelID == "SVR_DETAIL"
		If !oSubModel:GetValue("VLDOPC")
			lOk := .F.
			Help(' ',1,"Help" ,,STR0083,2,0,,,,,, {STR0084}) //"Este item possui grupos de opcionais obrigat�rios." //"Atualizando o campo 'Quantidade' � aberta a tela para atualiza��o dos opcionais"
		EndIf
	EndIf

	If SVR->(FieldPos("VR_GRADE")) > 0 .And. lOk
		//Realiza operacoes GridLinePosVld relacionadas a grade
		lOk := ::oGrade:xGridLinePosVld(oSubModel, cModelID, nLine)
	EndIf
Return lOk

/*/{Protheus.doc} ModelPosVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de p�s-valida��o do Model
Esse evento ocorre uma vez no contexto do modelo principal

@author lucas.franca
@since 24/01/2019
@version P12
@param oModel  , object    , modelo principal
@param cModelId, characters, ID do submodelo de dados
@return Nil
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS PCPA136EVDEF
	Local lRet    := .T.
	Local nIndex  := 0
	Local oMdlSVB := oModel:GetModel("SVB_MASTER")
	Local oMdlSVR := oModel:GetModel("SVR_DETAIL")

	If oModel:GetOperation() != MODEL_OPERATION_DELETE
		For nIndex := 1 To oMdlSVR:Length()
			If oMdlSVR:IsDeleted(nIndex)
				Loop
			EndIf

			//Valida se a data dos itens da demanda est�o dentro do per�odo da demanda.
			If oMdlSVR:GetValue("VR_DATA",nIndex) > oMdlSVB:GetValue("VB_DTFIM")
				lRet := .F.
				Help(' ',1,"Help" ,,STR0041,; //"Data do produto da demanda n�o pode ser maior que a data final da demanda."
					2,0,,,,,, {STR0042 + DtoC(oMdlSVB:GetValue("VB_DTFIM")) + "." }) //"Para os itens da demanda, informe uma data menor que "
				Exit
			EndIf
			If oMdlSVR:GetValue("VR_DATA",nIndex) < oMdlSVB:GetValue("VB_DTINI")
				lRet := .F.
				Help(' ',1,"Help" ,,STR0043,; //"Data do produto da demanda n�o pode ser menor que a data inicial da demanda."
					2,0,,,,,, {STR0044 + DtoC(oMdlSVB:GetValue("VB_DTINI")) + "." }) //"Para os itens da demanda, informe uma data maior que "
				Exit
			EndIf
		Next nIndex
	EndIf
Return lRet

/*/{Protheus.doc} BeforeTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes da transa��o.
@author Marcelo Neumann
@since 17/01/2019
@version P12
@param oModel  , object    , modelo principal
@param cModelId, characters, ID do submodelo de dados
@return Nil
/*/
METHOD BeforeTTS(oModel, cModelId) CLASS PCPA136EVDEF
	If oModel:GetOperation() != MODEL_OPERATION_DELETE
		//Realiza operacoes beforeTTS relacionadas a grade
		If SVR->(FieldPos("VR_GRADE")) > 0
			::oGrade:xBeforeTTS(oModel, cModelID)
		EndIf

		//Faz a atualiza��o das sequ�ncias das demandas.
		A136AtuSeq(oModel)
	EndIf
Return

/*/{Protheus.doc} A136AtuSeq
Fun��o para atualizar as sequ�ncias das demandas (VR_SEQUEN)
@author lucas.franca
@since 29/01/2019
@version P12
@param oModel , object , Modelo do programa PCPA136
@param nUltSeq, numeric, �ltima sequ�ncia utilizada
@return Nil
/*/
Function A136AtuSeq(oModel, nUltSeq)
	Local oMdlSVR
	Local oMdlGrade
	Local nLinha     := 0

	Default nUltSeq  := 0

	oMdlSVR    := oModel:GetModel("SVR_DETAIL")
	If SVR->(FieldPos("VR_GRADE")) > 0
		oMdlGrade  := oModel:GetModel("SVR_GRADE")
	EndIf

	If oModel:GetOperation() <> MODEL_OPERATION_DELETE
		//Percorre as linhas do modelo para pegar qual � a maior sequ�ncia j� utilizada para o per�odo.
		For nLinha := 1 To oMdlSVR:Length()
			If oMdlSVR:GetValue("VR_SEQUEN", nLinha) > nUltSeq
				nUltSeq := oMdlSVR:GetValue("VR_SEQUEN", nLinha)
			EndIf
		Next nLinha

		//Percorre as linhas do modelo grade para pegar qual � a maior sequ�ncia j� utilizada para o per�odo.
		If SVR->(FieldPos("VR_GRADE")) > 0
			For nLinha := 1 To oMdlGrade:Length()
				If oMdlGrade:GetValue("VR_SEQUEN", nLinha) > nUltSeq
					nUltSeq := oMdlGrade:GetValue("VR_SEQUEN", nLinha)
				EndIf
			Next nLinha
		EndIf

		//Percorre as linhas inseridas buscando e atribuindo o sequencial
		For nLinha := 1 To oMdlSVR:Length()
			oMdlSVR:GoLine(nLinha)
			If oMdlSVR:IsDeleted()
				Loop
			EndIf

			If Empty(oMdlSVR:GetValue("VR_SEQUEN")) .AND. !Empty(oMdlSVR:GetValue("VR_PROD"))
				//Incrementa o sequ�ncial e carrega no campo VR_SEQUEN
				nUltSeq++
				oMdlSVR:LoadValue("VR_SEQUEN", nUltSeq)
			EndIf
		Next nLinha

		//Percorre as linhas inseridas na grade buscando e atribuindo o sequencial
		If SVR->(FieldPos("VR_GRADE")) > 0
			For nLinha := 1 To oMdlGrade:Length()
				oMdlGrade:GoLine(nLinha)
				If oMdlGrade:IsDeleted()
					Loop
				EndIf

				If Empty(oMdlGrade:GetValue("VR_SEQUEN")) .AND. !Empty(oMdlGrade:GetValue("VR_PROD"))
					//Incrementa o sequ�ncial e carrega no campo VR_SEQUEN
					nUltSeq++
					oMdlGrade:LoadValue("VR_SEQUEN", nUltSeq)
				EndIf
			Next nLinha
		EndIf
	EndIf
Return Nil
