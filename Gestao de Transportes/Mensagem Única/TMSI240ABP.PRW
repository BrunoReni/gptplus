#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"


/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSI240ABP  � Autor � TIAGO DOS SANTOS   � Data � 23-09-2016 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � INTEGRACAO EAI GERA TITULO PAGAR - ADIANTAMENTO FRETE        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSI240ABP()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function TMSI240ABP(cXML,nType,cMsgType,cVersion)
Local    aResult      := {}
Local    cRotina      := "TMSA240"
Local    cAsinc       := "1"
Local    cXmlRet      := ""

Default  cVersion     := "1.000"

If type("oDTClass") == "U"
    private oDTClass := TransportDocumentClass():New()
EndIf 

    
//| Define o tipo da mensagem.
//| 4-SEGURO;401-PREMIACAO
//oDTClass:SetTipoMsg("1","101") //| 1-VIAGEM;101-VIAGEM ADIANTAMENTO
oDTClass:cVersion := cVersion

//- Trata o Envio/Recebimento do XML
If   nType == TRANS_SEND
    aResult := oDTClass:Send() // TMI240SND()
    
ElseIf nType == TRANS_RECEIVE
    aResult := oDTClass:Receive(cXML,cMsgType) //TMI240REC(cXML,cMsgType)
    
EndIf

//- Adiciona o nome da Transa��o da mensagem no cadastro do Adapter EAI
//- Gatilha o campo XX4_MODEL
AAdd(aResult,oDTClass:cEntityName)

Return aResult
