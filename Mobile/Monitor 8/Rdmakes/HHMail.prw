#INCLUDE "HHMail.ch"
#include "ap5mail.ch"
#include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �HHMail    �Autor  �Cleber Martinez     � Data �  08/09/04   ���
�������������������������������������������������������������������������͹��
���Descr.    � Envia e-mail apos importacao dos dados    				  ���
���          � ou quando ocorrer algum erro de importacao                 ���
�������������������������������������������������������������������������͹��
���Parametros� cEmail => tipos de mensagem no e-mail 		              ���
���          � cNumPed => Nr. do pedido importado no Protheus             ���
���          � cNumPedPalm => Nr. do pedido (temporario) gravado no Palm  ���
���          � cArqLog => Nome do arq. de log gerado (SC*.LOG)		      ���
���          � cAttach => Caminho completo do log a ser anexado no mail   ���
���          � cCodCli => Cod do novo cliente importado no Protheus       ���
�������������������������������������������������������������������������͹��
���Uso       � PalmJob (rotinas de importacao)                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HHSendMail(aTo, aCC, aAttach, cSubject, cMail)
Local cSmtpServer := GETMV("MV_RELSERV",,"")
Local cFrom       := GetMV("MV_RELACNT",,"")
Local cPwd        := GetMV("MV_RELPSW",,"")
Local cError      := ""
Local ni          := 1 
Local lSendOk
Local lOk

Private cTo     := ""
Private cCC     := ""
Private cAttach := ""

DEFAULT aTo     := {}
DEFAULT aCC     := {}
DEFAULT aAttach := {}

If !Empty(cSmtpServer) .And. !Empty(cFrom) .And.  !Empty(cPwd)
	//IP do servidor de envio de e-mail(smtp), conta e password
	CONNECT SMTP SERVER cSmtpServer ACCOUNT cFrom PASSWORD "" RESULT lOk
	
	For ni := 1 To Len(aTo)
		cTo += aTo[ni] + ";"
	Next	

	For ni := 1 To Len(aCc)
		cCC += aCc[ni] + ";"
	Next		

	For ni := 1 To Len(aAttach)
		cAttach += aAttach[ni] + ";"
	Next		

	If ( (ExistBlock("HHMAIL01")) )
		ExecBlock("HHMAIL01",.F.,.F.)
	EndIf

	If lOk
		SEND MAIL FROM cFrom to cTo;
		CC cCC;	
		SUBJECT cSubject;
		BODY cMail ATTACHMENT cAttach RESULT lSendOk
		If !lSendOk
			GET MAIL ERROR cError
			ConOut(STR0001 + cError) //"1 - Erro no envio do e-mail: "
		Endif
	Else
		GET MAIL ERROR cError
		ConOut(STR0002 + cError) //"2 - Erro de conex�o do o servidor SMTP: "
	EndIf
Endif
If lOk		
	DISCONNECT SMTP SERVER
Endif
		
Return Nil