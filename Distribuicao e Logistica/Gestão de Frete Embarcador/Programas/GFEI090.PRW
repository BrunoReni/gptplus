#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
��� Funcao   � GFEI090 � Autor � Hercilio Henning Neto  � Data � 18/07/2017 ���
���������������������������������������������������������������������������͹��
��� Desc.    � Funcao de integracao com o adapter EAI para recebimento  e   ���
���          � envio do XML de Cadastro de Conta Contabeis ,usando a tabela GUE
���          � Conceito de mensagem unica.                                  ���
���������������������������������������������������������������������������͹��
��� Param.   � cXML - Variavel com conteudo xml para envio/recebimento.     ���
���          � nTypeTrans - Tipo de transacao. (Envio/Recebimento)          ���
���          � cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) ���
���������������������������������������������������������������������������͹��
��� Retorno  � aRet - Array contendo o resultado da execucao e a mensagem   ���
���          �        Xml de retorno.                                       ���
���          � aRet[1] - (boolean) Indica o resultado da execu��o da fun��o ���
���          � aRet[2] - (caracter) Mensagem Xml para envio                 ���
���          � aRet[3] - (caracter) Nome da Mensagem Transacional que iden- ���
���          �           tifica a integracao para execu��o pelo adapter EAI.���
���������������������������������������������������������������������������͹��
��� Uso      � GFEA090                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
 
Function GFEI090(cXml,nType,cTypeMsg)
	Local aResult           := {}
	Private cEntityName    := ""
	Private aAreaXX4        := {}

	//--Obt�m a vers�o caso seja necess�rio realizar algum tratamento por vers�o
	dbSelectArea('XX4')
	aAreaXX4 := XX4->(GetArea())

//+---------------------------------------------------------------------
//| Mensagem - Recebimento
//+---------------------------------------------------------------------
	If nType == TRANS_RECEIVE
		aResult := GFEA090REC(cXml,cTypeMsg)
	EndIf

	RestArea(aAreaXX4)

	//- Adiciona o nome da Transa��o da mensagem no cadastro do Adapter EAI
	//- Gatilha o campo XX4_MODEL
	AAdd(aResult,cEntityName)

Return aResult

/*/
=================================================================================
{Protheus.doc} _FReceive(cXml,cTypeMsg)

//TODO Descri��o : Funcao para tratar o xml de recebimento
@since 13/11/2017
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
/*/
Static Function GFEA090REC(cXml,cTypeMsg)

	Local cXmlRet    	:= ""
	Local lResult    	:= .T.
	Local lDelete			:= .F.
	Local oModel
	Local oXml        	:= ""
	Local cAction     	:= ""
	Local cMarca      	:= ""
	Local aErrsList   	:= {}
	Local lRet 			:= .T.
	Local aErro 			:= {}
	Local cCodeInt 		:= ""
	Local cCodeExt 		:= ""
	Local cAlias 			:= "GUE"
	Local cCampo 			:= "GUE_CTACTB"
	Local nOpcx 			:= 0

//+--------------------------------------------------------------+
//| Trata a mensagem de Negocio/BusinessMessage					 |
//+--------------------------------------------------------------+
	If cTypeMsg == EAI_MESSAGE_BUSINESS
	
		oXml := TXmlManager():new()
		If !oXml:Parse(cXml)

			lResult:= .F.
			Aadd(aErrsList, {"", 1, ""}) // Description | nType: 1-ERROR;2-WARNING | cCode : Generic Code

			cXmlRet := FWEAILOfMessages(aErrsList)

			Return {lResult,cXmlRet}
		EndIf
	
		//Inicio do processamento do XML de Endere�o de Entrega.
		cAction    := Upper(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessEvent/Event"))
		cCodeExt   := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessEvent/Identification")
		cMarca     := oXml:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )

		//Obt�m o c�digo interno da tabela de/para atrav�s de um c�digo externo
		cCodeInt := PadR(CFGA070INT( cMarca, cAlias, cCampo, cCodeExt ), TamSX3('GUE_CTACTB')[1])

		If Empty(cCodeInt)
			cCodeInt := cCodeExt
		EndIf

		cCTACTB 	:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ListOfAccountantAccount/AccountantAccount/Code")
		cTITULO 	:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/ListOfAccountantAccount/AccountantAccount/Description")

    //Valida a a��o sendo: upsert=inclus�o/altera��o ou delete=exclus�o
		If cAction == "UPSERT"
			GUE->(dbSetOrder(1))
			If !GUE->(dbSeek(xFilial("GUE")+cCTACTB))
				nOpcx := 3
			Else
				nOpcx := 4
			EndIf
		ElseIf cAction == "DELETE"
			GUE->(dbSetOrder(1))
			GUE->(dbSeek(xFilial("GUE")+cCTACTB))
			lDelete := .T.
			nOpcx := 4 // Mudar de 5 para 4 para aceitar ajustar o sit para inativo		
		Endif
    
		oModel := FWLoadModel( "GFEA090" )
		oModel:SetOperation( nOpcx )
		oModel:Activate()
	
		If nOpcx != 5
				If lDelete
					oModel:LoadValue("GFEA090_GUE",'GUE_SIT' 		, "2"	)  //Inativo
				Else
					oModel:SetValue("GFEA090_GUE",'GUE_FILIAL'	, " "	)
					oModel:SetValue("GFEA090_GUE",'GUE_CTACTB'	, cCTACTB 	)
					oModel:SetValue("GFEA090_GUE",'GUE_TITULO' 	, cTITULO	)
					oModel:LoadValue("GFEA090_GUE",'GUE_SIT' 		, "1"	)  //Ativo
				EndIf
		EndIf

		lRet := oModel:VldData()
	
		If lRet
			oModel:CommitData()
		// Monta xml com status do processamento da rotina automatica OK.
			cXMLRet +=      "<ListOfInternalId>"
			cXMLRet +=            "<InternalId>"
			cXMLRet +=                  "<Name>CodeInternalId</Name>"
			cXMLRet +=                  "<Origin>"      + cCodeExt + "</Origin>"
			cXMLRet +=                  "<Destination>" + cCodeInt + "</Destination>"
			cXMLRet +=            "</InternalId>"
			cXMLRet +=      "</ListOfInternalId>"
		Else
		//Recupera as mensagens de erro
			aErro := oModel:GetErrorMessage()
			oModel:DeActivate()
			cXmlRet := ""
		
			cXmlRet += _NoTags(aErro[6])
        
			lResult := .F.
		EndIf
    
    //+--------------------------------------------------------------
    //| Trata a mensagem de Resposta/Devolve Mensagem.
    //+--------------------------------------------------------------
	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE

    //+--------------------------------------------------------------
    //| Mensagem: responde com a Vers�o
    //+--------------------------------------------------------------
	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
		cXmlRet := "1.000|1.001"

    //+--------------------------------------------------------------
    //| Trata a mensagem de Negocio/BusinessMessage
    //+--------------------------------------------------------------
	ElseIf cTypeMsg == EAI_MESSAGE_RECEIPT

	EndIf

//Monta a mensagem de erro
	If !Empty(aErrsList)
		lResult := .F.
		cXmlRet := FWEAILOfMessages( aErrsList )
	EndIf

Return {lResult,cXmlRet}