#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"


/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSI070ABP  � Autor � TIAGO DOS SANTOS   � Data � 23-09-2016 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � INTEGRACAO EAI GERA TITULO PAGAR - CONTROLE DE DIARIAS       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSI070ABP()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function TMSI070ABP(cXML,nType,cMsgType,cVersion)
Local    aResult      := {}
Local    cRotina      := "TMSA070"
Local    aAdapter     := {}
default  cVersion     := "1.000"

      If type("oDTClass") == "U"
          private oDTClass := TransportDocumentClass():New()
      EndIf

      aAdapter := FwAdapterInfo(cRotina, oDTClass:cEntityName)

      If Len(aAdapter) > 0
        cVersion := aAdapter[/*ADAPTER_INFO_VERSION*/8]
      EndIf

      //| Define o tipo da mensagem.
      //| 4-SEGURO;401-PREMIACAO
      If Empty(oDTClass:cTIPOMSG)
         oDTClass:SetTipoMsg("5","501") //| 5-CUSTO DE TRANSP.;501-CUSTO TRANSP - NORM
      EndIf
      oDTClass:cVersion := cVersion
      
      //- Trata o Envio/Recebimento do XML
      If   nType == TRANS_SEND
           aResult := oDTClass:send()
           
      ElseIf nType == TRANS_RECEIVE
           aResult := oDTClass:receive(cXML,cMsgType)
           
      EndIf
      
      //- Adiciona o nome da Transa��o da mensagem no cadastro do Adapter EAI
      //- Gatilha o campo XX4_MODEL
      AAdd(aResult,oDTClass:cEntityName)

      aSize(aAdapter, 0)
	  aAdapter := Nil

Return aResult