#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
��� Funcao   � GFEI020 � Autor � Hercilio Henning Neto  � Data � 18/07/2017 ���
���������������������������������������������������������������������������͹��
��� Desc.    � Funcao de integracao com o adapter EAI para recebimento  e   ���
���          � envio do XML de Cadastro de cidades,usando a tabela cidade.  ���
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
��� Uso      � GFEA020                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/ 
Function GFEI020(cXml,nType,cTypeMsg)
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
    aResult := GFEA020REC(cXml,cTypeMsg)
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
@author Hercilio Henning Neto
@since 18/07/2017
@version undefined
@param cXml, characters, descricao
@type function
=================================================================================
/*/
Static Function GFEA020REC(cXml,cTypeMsg)

Local cXmlRet     := ""
Local lResult     := .T.
Local oModel 
Local oXml        := ""
Local cAction     := ""
Local cMarca      := ""
Local aErrsList   := {}
Local cCodIBGE := ""
Local cNomeCidade := ""
Local cUF := ""
Local lRet := .T.
Local aErro := {}
Local cCodeInt := ""
Local cCodeExt := ""
Local cAlias := "GU7"
Local cCampo := "GU7_NRCID"
Local nx := 0
Local nOpcx := 0

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
    cCodeInt := PadR(CFGA070INT( cMarca, cAlias, cCampo, cCodeExt ), TamSX3('GU7_NRCID')[1])

    If Empty(cCodeInt)
        cCodeInt := cCodeExt
    EndIf

    cCodIBGE 	:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/OfficialCode")
    cNomeCidade := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Description")
    cUF 		:= oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/FederalUnit")

    //Valida a a��o sendo: upsert=inclus�o/altera��o ou delete=exclus�o
    If cAction == "UPSERT" 
    	GU7->(dbSetOrder(1))
    	If !GU7->(dbSeek(xFilial("GU7")+cCodIBGE))
    		nOpcx := 3
    	Else
    		nOpcx := 4
    	EndIf
    ElseIf cAction == "DELETE"
    	GU7->(dbSetOrder(1))
    	GU7->(dbSeek(xFilial("GU7")+cCodIBGE))
    	nOpcx := 5
    Endif
    
	oModel := FWLoadModel( "GFEA020" )
	oModel:SetOperation( nOpcx )
	oModel:Activate()
	
	If nOpcx != 5
		oModel:SetValue("GFEA020_GU7",'GU7_NRCID' , cCodIBGE	)
		oModel:SetValue("GFEA020_GU7",'GU7_NMCID' , cNomeCidade )
		oModel:SetValue("GFEA020_GU7",'GU7_CDUF'  , cUF			)
		oModel:SetValue("GFEA020_GU7",'GU7_CDPAIS', "105"		)
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