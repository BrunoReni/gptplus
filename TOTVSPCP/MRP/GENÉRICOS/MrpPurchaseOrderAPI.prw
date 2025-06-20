#INCLUDE "TOTVS.CH"

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a fun��o SOLCAPICnt
//para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na fun��o SOLCAPICnt
#DEFINE ARRAY_SOLCOM_POS_FILIAL   1
#DEFINE ARRAY_SOLCOM_POS_NUM      2
#DEFINE ARRAY_SOLCOM_POS_ITEM     3
#DEFINE ARRAY_SOLCOM_POS_PROD     4
#DEFINE ARRAY_SOLCOM_POS_OP       5
#DEFINE ARRAY_SOLCOM_POS_DATPRF   6
#DEFINE ARRAY_SOLCOM_POS_QTD      7
#DEFINE ARRAY_SOLCOM_POS_QUJE     8
#DEFINE ARRAY_SOLCOM_POS_LOCAL    9
#DEFINE ARRAY_SOLCOM_POS_TIPO    10
#DEFINE ARRAY_SOLCOM_POS_CODE    11
#DEFINE ARRAY_SOLCOM_POS_ITGRD   12
#DEFINE ARRAY_SOLCOM_POS_RESIDUO 13
#DEFINE ARRAY_SOLCOM_RECNO       14
#DEFINE ARRAY_SOLCOM_SIZE        14

/*/{Protheus.doc} SOLCAPICnt
Recupera o valor das constantes utilizadas para
auxiliar na montagem do array de pedido de compra para integra��o.

@type  Function
@author marcelo.neumann
@since 05/08/2019
@version P12.1.27
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function SOLCAPICnt(cInfo)
	Local nValue := ARRAY_SOLCOM_SIZE
	Do Case
		Case cInfo == "ARRAY_SOLCOM_POS_FILIAL"
			nValue := ARRAY_SOLCOM_POS_FILIAL
		Case cInfo == "ARRAY_SOLCOM_POS_CODE"
			nValue := ARRAY_SOLCOM_POS_CODE
		Case cInfo == "ARRAY_SOLCOM_POS_NUM"
			nValue := ARRAY_SOLCOM_POS_NUM
		Case cInfo == "ARRAY_SOLCOM_POS_ITEM"
			nValue := ARRAY_SOLCOM_POS_ITEM
		Case cInfo == "ARRAY_SOLCOM_POS_PROD"
			nValue := ARRAY_SOLCOM_POS_PROD
		Case cInfo == "ARRAY_SOLCOM_POS_OP"
			nValue := ARRAY_SOLCOM_POS_OP
		Case cInfo == "ARRAY_SOLCOM_POS_DATPRF"
			nValue := ARRAY_SOLCOM_POS_DATPRF
		Case cInfo == "ARRAY_SOLCOM_POS_QTD"
			nValue := ARRAY_SOLCOM_POS_QTD
		Case cInfo == "ARRAY_SOLCOM_POS_QUJE"
			nValue := ARRAY_SOLCOM_POS_QUJE
		Case cInfo == "ARRAY_SOLCOM_POS_LOCAL"
			nValue := ARRAY_SOLCOM_POS_LOCAL
		Case cInfo == "ARRAY_SOLCOM_POS_TIPO"
			nValue := ARRAY_SOLCOM_POS_TIPO
		Case cInfo == "ARRAY_SOLCOM_POS_ITGRD"
			nValue := ARRAY_SOLCOM_POS_ITGRD
		Case cInfo == "ARRAY_SOLCOM_POS_RESIDUO"
			nValue := ARRAY_SOLCOM_POS_RESIDUO
		Case cInfo == "ARRAY_SOLCOM_SIZE"
			nValue := ARRAY_SOLCOM_SIZE
		Case cInfo == "ARRAY_SOLCOM_RECNO"
			nValue := ARRAY_SOLCOM_RECNO
		Otherwise
			nValue := ARRAY_SOLCOM_SIZE
	EndCase
Return nValue

/*/{Protheus.doc} PCPSOLCINT
Fun��o que executa a integra��o do pedido de compra com o MRP.

@type  Function
@author marcelo.neumann
@since 05/08/2019
@version P12.1.27
@param cOperation, Caracter, Opera��o que ser� executada ('DELETE'/'INSERT'/'SYNC')
@param aDados    , Array   , Array com os dados que devem ser integrados com o MRP.
@param aSuccess  , Array   , Carrega os registros que foram integrados com sucesso.
@param aError    , Array   , Carrega os registros que n�o foram integrados por erro.
@param cUUID     , Caracter, Identificador do processo do SCHEDULE. Utilizado para atualiza��o de pend�ncias.
@param lOnlyDel  , Logic   , Indica que est� sendo executada uma opera��o de Sincroniza��o apenas excluindo os dados existentes (envia somente filial).
@param lBuffer   , Logic   , Define a sincroniza��o em processo de buffer.

@return Nil
/*/
Function PCPSOLCINT(cOperation, aDados, aSuccess, aError, cUUID, lOnlyDel,lBuffer)
	Local aReturn   := {}
	Local lAllError := .F.
	Local nIndex    := 0
	Local nTotal    := 0
	Local oJsonData := Nil
	Local cApi 		:= "MRPPURCHASEORDER"

	Default aSuccess := {}
	Default aError   := {}
	Default lOnlyDel := .F.
	Default lBuffer  := .F.

	nTotal := Len(aDados)
	oJsonData := JsonObject():New()

	oJsonData["items"] := Array(nTotal)

	For nIndex := 1 To nTotal
		oJsonData["items"][nIndex] := JsonObject():New()
		oJsonData["items"][nIndex]["branchId"] := aDados[nIndex][ARRAY_SOLCOM_POS_FILIAL]
		If ! (lOnlyDel .And. cOperation == "SYNC")
			oJsonData["items"][nIndex]["code"    ] := aDados[nIndex][ARRAY_SOLCOM_RECNO]
			
			If cOperation $ "|INSERT|SYNC|"
				oJsonData["items"][nIndex]["purchase"        ] := aDados[nIndex][ARRAY_SOLCOM_POS_NUM]
				oJsonData["items"][nIndex]["sequence"        ] := aDados[nIndex][ARRAY_SOLCOM_POS_ITEM]
				oJsonData["items"][nIndex]["product"         ] := aDados[nIndex][ARRAY_SOLCOM_POS_PROD]
				oJsonData["items"][nIndex]["productionOrder" ] := aDados[nIndex][ARRAY_SOLCOM_POS_OP]

				If !Empty(aDados[nIndex][ARRAY_SOLCOM_POS_DATPRF])
					oJsonData["items"][nIndex]["deliveryDate"] := convDate(aDados[nIndex][ARRAY_SOLCOM_POS_DATPRF])
				EndIf

				oJsonData["items"][nIndex]["quantity"        ] := aDados[nIndex][ARRAY_SOLCOM_POS_QTD]
				oJsonData["items"][nIndex]["receivedQuantity"] := aDados[nIndex][ARRAY_SOLCOM_POS_QUJE]
				oJsonData["items"][nIndex]["warehouse"       ] := aDados[nIndex][ARRAY_SOLCOM_POS_LOCAL]

				If aDados[nIndex][ARRAY_SOLCOM_POS_TIPO] == "F" .Or. Empty(aDados[nIndex][ARRAY_SOLCOM_POS_TIPO])
					oJsonData["items"][nIndex]["type"            ] := '1'
				Else
					oJsonData["items"][nIndex]["type"            ] := '2'
				EndIf
			EndIf
		EndIf
	Next nIndex

	If cOperation $ "|INSERT|SYNC|"
		If cOperation == "INSERT"
			aReturn := MrpSCPost(oJsonData)
		Else
			aReturn := MrpSCSync(oJsonData,lBuffer)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '3', cUUID)
	Else
		aReturn := MrpSCDel(oJsonData)
		PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '3', cUUID)
	EndIf

	FreeObj(oJsonData)
	oJsonData := Nil

Return Nil

/*/{Protheus.doc} convDate
Converte uma data do tipo DATE para o formato string AAAA-MM-DD

@type  Static Function
@author marcelo.neumann
@since 05/08/2019
@version P12.1.27
@param dData, Date, Data que ser� convertida
@return cData, Caracter, Data convertida para o formato utilizado na integra��o.
/*/
Static Function convDate(dData)
	Local cData := ""

	cData := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)
Return cData
