#include "eADVPL.ch"

Function ACFecha(aClientes,nCliente,oCliente)
    CloseDialog()
	SetArray(oCliente,aClientes)    
    //Reposiciona no elemento do browse
	GridSetRow(oCliente,nCliente)
Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � InitContato         �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Inicia Modulo de Contato                 	 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nOpCon:Indica a Operacao (1=Inclusao,2=Alteracao,3=Detalhe)���
���          � cCodCli: Codigo do Cliente; cLojaCli: Loja do Cliente	  ���
���          � cCodCon: Codigo do Conatato, lAt        	                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function InitContato(nOpCon,cCodCli, cLojaCli,cCodCon,lAt)
Local oDlg , oSay    
Local cContat	:= space(30), cCpf :=space(14)
//cCodCon := space(6)
Local cFone	:=space(15), cCelular :=space(15), cEmail	:=space(30)
Local aFuncao:={}, nFuncao:= 1
Local oDtNasc,dDtNasc, oBtnDt
Local oCodCon , oContat , oCpf , oFuncao
Local oFone	, oCelular , oEmail, oBtnRetornar, oBtnGravar, oBtnExcluir

lAt :=.F.
CrgFuncao(aFuncao)

If nOpCon == 1 
	CrgProxCon(@cCodCon)
Else
	dbSelectArea("HU5")
	dbSetOrder(1)
	dbSeek(cCodCli + cLojaCli + cCodCon)
	If HU5->(Found())
		cCodCon		:= HU5->U5_CODCON
		cContat		:= HU5->U5_CONTAT
		cCpf		:= HU5->U5_CPF
        nFuncao		:= ProcFuncao(aFuncao,AllTrim(HU5->U5_FUNCAO))                  
		cFone		:= HU5->U5_FONE
		cCelular	:= HU5->U5_CELULAR
		cEmail		:= HU5->U5_EMAIL
		if !Empty(HU5->U5_DTNASC)
			dDtNasc	:= HU5->U5_DTNASC
		Endif
	Else
		MsgStop("Contato n�o encontrado!","Aviso")
		Return Nil
	EndIf			
EndIf

If nOpCon == 1 
	DEFINE DIALOG oDlg TITLE "Inclus�o do Contato"
ElseIf nOpCon == 2
	DEFINE DIALOG oDlg TITLE "Altera��o do Contato"
ElseIf nOpCon == 3
	DEFINE DIALOG oDlg TITLE "Detalhe do Contato"
EndIf

@ 018,02  SAY oSay PROMPT "Codigo: "  of oDlg
@ 032,02  SAY oSay PROMPT "Contato: " of oDlg
@ 046,02  SAY oSay PROMPT "CPF: " 	  of oDlg
@ 060,02  SAY oSay PROMPT "Fun��o: "  of oDlg
@ 074,02  SAY oSay PROMPT "Fone: " 	  of oDlg
@ 088,02  SAY oSay PROMPT "Celular: " of oDlg
@ 102,02  SAY oSay PROMPT "E-mail: "  of oDlg
If nOpCon != 3
	@ 116,002 BUTTON oBtnDt CAPTION "Nasc." ACTION DtNasc(oDtNasc,dDtNasc) SIZE 30,12 of oDlg 
Else
	@ 116,002 SAY oSay PROMPT "Nasc." of oDlg 
EndIf
@ 142,108 BUTTON oBtnRetornar CAPTION "Cancelar" ACTION CloseDialog() SIZE 50,12 of oDlg

If nOpCon == 3
	@ 18,42  GET  oCodCon 	VAR cCodCon  READONLY NO UNDERLINE of oDlg
	@ 32,42  GET  oContat  	VAR cContat  READONLY NO UNDERLINE of oDlg
	@ 46,42  GET  oCpf 	   	VAR cCpf 	 READONLY NO UNDERLINE of oDlg
	@ 60,42  COMBOBOX oFuncao VAR nFuncao  ITEMS aFuncao SIZE 90,40 of oDlg
	@ 74,42  GET  oFone 	VAR cFone 	 READONLY NO UNDERLINE of oDlg
	@ 88,42  GET  oCelular 	VAR cCelular READONLY NO UNDERLINE of oDlg
	@ 102,42 GET  oEmail 	VAR cEmail   READONLY NO UNDERLINE of oDlg
	@ 116,42 GET  oDtNasc	VAR dDtNasc  READONLY NO UNDERLINE SIZE 50,12 of oDlg
	@ 142,01 BUTTON oBtnExcluir CAPTION "Excluir" ACTION ExcContato(cCodCli,cLojaCli,@cCodCon, @lAt) SIZE 50,12 of oDlg
Else
	@ 18,42  GET 	oCodCon  VAR cCodCon  READONLY of oDlg
	@ 32,42  GET 	oContat  VAR cContat  of oDlg
	@ 46,42  GET 	oCpf 	 VAR cCpf 	  of oDlg
	@ 60,42  COMBOBOX oFuncao 	VAR nFuncao  ITEMS aFuncao SIZE 90,40 of oDlg
	@ 74,42  GET 	oFone 	 VAR cFone 	  of oDlg
	@ 88,42  GET 	oCelular VAR cCelular of oDlg
	@ 102,42 GET 	oEmail 	 VAR cEmail   of oDlg
	@ 116,42 GET 	oDtNasc	 VAR dDtNasc  SIZE 50,12 of oDlg
	@ 142,55 BUTTON oBtnGravar CAPTION "Gravar" ACTION GrvContato(nOpCon,cCodCli,cLojaCli,@cCodCon, cContat,cCpf,aFuncao,nFuncao,cFone,cCelular,cEmail,dDtNasc,@lAt) SIZE 50,12 of oDlg
EndIf

ACTIVATE DIALOG oDlg

Return Nil