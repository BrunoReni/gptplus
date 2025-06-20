#INCLUDE "Protheus.ch"
#INCLUDE "FWADAPTEREAI.CH"

Static aVetGNRE := {}

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSAE78  � Autor � Valdemar Roberto    � Data � 02.03.2017 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envio de GNRE - Integra��o com Datasul                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE78()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSAE78(aParam)
Local cTMSERP := SuperGetMV("MV_TMSERP",," ")	//-- Condi��o de integra��o com ERP (0 - Protheus, 1 - Datasul)

DEFAULT aParam := {}

aVetGNRE := aParam

If cTMSERP == "1"
	SetRotInteg("TMSAE78")
	FWINTEGDEF("TMSAE78")
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IntegDef � Autor � Valdemar Roberto   � Data � 02/03/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Integra��o via Mensagem �nica                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � IntegDef(cExp01,nExp01,cExp02)                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 - Variavel com conteudo xml para envio/recebimento  ���
���          � nExp01 - Tipo de transacao (Envio/Recebimento)             ���
���          � cExp02 - Tipo de mensagem (Business Type, WhoIs, Etc)      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE78                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function IntegDef(cXML,nTypeTrans,cTypeMessage)
Local aRet := {}

If nTypeTrans == TRANS_SEND
	aRet := TMSIE78(cXML,nTypeTrans,cTypeMessage)
EndIf

aVetGNRE := {}

Return aRet    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE78Sta � Autor � Valdemar Roberto � Data � 02/03/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna vari�veis estaticas                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE78Sta(cExp01)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 - Vari�vel que ser� retornada                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE78                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSAE78Sta(cNomVar)
Local cRet := ""

DEFAULT cNomVar := ""

If !Empty(cNomVar)
	cRet := &(cNomVar)
EndIf

Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GetIdEnt � Autor � Valdemar Roberto   � Data � 27/12/2016  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca identificador para busca do XML                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GetIdEnt(lExp01)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lExp01 - Indicada se usa Totvs Colabora��o                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cRet - Identificador                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSIE76                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function GetIdEnt(lUsaColab)
Local aArea      := GetArea()
Local cIdEnt     := ""
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lUsaGesEmp := IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
Local lEnvCodEmp := GetNewPar("MV_ENVCDGE",.F.)
Local oWs

Default lUsaColab := .F.

If !lUsaColab
	//������������������������������������������������������������������������Ŀ
	//�Obtem o codigo da entidade                                              �
	//��������������������������������������������������������������������������
	
	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"
		
	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := IIF(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""

	If lUsaGesEmp .And. lEnvCodEmp
		oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
	EndIf

	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt := oWs:cADMEMPRESASRESULT
	EndIf
	
	FreeObj(oWs)
	oWs := Nil
Else
	If ColCheckUpd()
		cIdEnt := "000000"
	Endif	 
EndIf	

RestArea(aArea)

Return cIdEnt
