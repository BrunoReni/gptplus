#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"


/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSI240ABP  � Autor � TIAGO DOS SANTOS   � Data � 23-09-2016 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � INTEGRACAO EAI GERA TITULO PAGAR - FRETE TERCEIRO,           ���
���          � PEDAGIO e ADIANTAMENTO FRETE.                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSI310ABP()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function TMSI310ABP(cXML,nType,cMsgType,cVersion)
Local    aResult      := {}
Local    cRotina      := "TMSA310"

Default  cVersion     := "1.000"

      If type("oDTClass") == "U"
          private oDTClass := TransportDocumentClass():New()
      EndIf 

      oDTClass:cVersion := cVersion
      
      //- Trata o Envio/Recebimento do XML
      If   nType == TRANS_SEND
           aResult := oDTClass:Send()
           
      ElseIf nType == TRANS_RECEIVE
           aResult := oDTClass:Receive(cXML,cMsgType)
           
      EndIf
      
      //- Adiciona o nome da Transa��o da mensagem no cadastro do Adapter EAI
      //- Gatilha o campo XX4_MODEL
      AAdd(aResult,oDTClass:cEntityName)

Return aResult
