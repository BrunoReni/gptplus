#INCLUDE "SFVN005.ch"
#include "eADVPL.ch"

Function ACFecha(aClientes,nCliente,oCliente)
    aSize(aGrupo,0)
    aSize(aProduto,0)
    nGrupo:=1
    cUltGrupo:=""
    CloseDialog()
	//SetArray(oCliente,aClientes)    
    //Reposiciona no elemento do browse
	GridSetRow(oCliente,nCliente)
Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � InitContato         矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Inicia Modulo de Contato                 	 			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nOpCon:Indica a Operacao (1=Inclusao,2=Alteracao,3=Detalhe)潮�
北�          � cCodCli: Codigo do Cliente; cLojaCli: Loja do Cliente	  潮�
北�          � cCodCon: Codigo do Conatato, lAt        	                  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function InitContato(nOpCon,cCodCli, cLojaCli,cCodCon,lAt)
Local oDlg , oSay    
Local cContat	:= space(30), cCpf :=space(14)
//cCodCon := space(6)
Local cFone	:=space(15), cCelular :=space(15), cEmail	:=space(30)
Local aFuncao:={}, nFuncao:= 1, nTam := 0
Local oDtNasc,dDtNasc, oBtnDt
Local oCodCon , oContat , oCpf , oFuncao
Local oFone	, oCelular , oEmail, oBtnRetornar, oBtnGravar, oBtnExcluir

lAt :=.F.
CrgFuncao(aFuncao)

If nOpCon == 1 
	CrgProxCon(@cCodCon)
Else                                      
	nTam := 6 - Len(cCodCli)
	dbSelectArea("HU5")
	dbSetOrder(1)
	If nTam > 0 
		dbSeek(cCodCli+space(nTam)+cLojaCli+cCodCon)	           
	Else
		dbSeek(cCodCli + cLojaCli + cCodCon)
	Endif
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
		MsgStop(STR0001,STR0002) //"Contato n鉶 encontrado!"###"Aviso"
		Return Nil
	EndIf			
EndIf

If nOpCon == 1 
	DEFINE DIALOG oDlg TITLE STR0003 //"Inclus鉶 do Contato"
ElseIf nOpCon == 2
	If HU5->U5_STATUS == "N" .And. !HU5->(IsDirty()) //Transmitido
		MsgAlert(STR0004,STR0002)		 //"Contato novo j� transmitido, n鉶 ser� poss韛el alter�-lo."###"Aviso"
		return nil	
	Endif
	DEFINE DIALOG oDlg TITLE STR0005 //"Altera玢o do Contato"
ElseIf nOpCon == 3
	DEFINE DIALOG oDlg TITLE STR0006 //"Detalhe do Contato"
EndIf

@ 018,02  SAY oSay PROMPT STR0007  of oDlg //"Codigo: "
@ 032,02  SAY oSay PROMPT STR0008 of oDlg //"Contato: "
@ 046,02  SAY oSay PROMPT STR0009 	  of oDlg //"CPF: "
@ 060,02  SAY oSay PROMPT STR0010  of oDlg //"Fun玢o: "
@ 074,02  SAY oSay PROMPT STR0011 	  of oDlg //"Fone: "
@ 088,02  SAY oSay PROMPT STR0012 of oDlg //"Celular: "
@ 102,02  SAY oSay PROMPT STR0013  of oDlg //"E-mail: "
If nOpCon != 3
	@ 116,002 BUTTON oBtnDt CAPTION STR0014 ACTION DtNasc(oDtNasc,dDtNasc) SIZE 30,12 of oDlg  //"Nasc."
Else
	@ 116,002 SAY oSay PROMPT STR0014 of oDlg  //"Nasc."
EndIf
@ 142,108 BUTTON oBtnRetornar CAPTION STR0015 ACTION CloseDialog() SIZE 50,12 of oDlg //"Cancelar"

If nOpCon == 3
	@ 18,42  GET  oCodCon 	VAR cCodCon  READONLY NO UNDERLINE of oDlg
	@ 32,42  GET  oContat  	VAR cContat  READONLY NO UNDERLINE of oDlg
	@ 46,42  GET  oCpf 	   	VAR cCpf 	 READONLY NO UNDERLINE of oDlg
	@ 60,42  COMBOBOX oFuncao VAR nFuncao  ITEMS aFuncao SIZE 90,40 of oDlg
	@ 74,42  GET  oFone 	VAR cFone 	 READONLY NO UNDERLINE of oDlg
	@ 88,42  GET  oCelular 	VAR cCelular READONLY NO UNDERLINE of oDlg
	@ 102,42 GET  oEmail 	VAR cEmail   READONLY NO UNDERLINE of oDlg
	@ 116,42 GET  oDtNasc	VAR dDtNasc  READONLY NO UNDERLINE SIZE 50,12 of oDlg
Else
	@ 18,42  GET 	oCodCon  VAR cCodCon  READONLY of oDlg
	@ 32,42  GET 	oContat  VAR cContat  of oDlg
	@ 46,42  GET 	oCpf 	 VAR cCpf 	  of oDlg
	@ 60,42  COMBOBOX oFuncao 	VAR nFuncao  ITEMS aFuncao SIZE 90,40 of oDlg
	@ 74,42  GET 	oFone 	 VAR cFone 	  of oDlg
	@ 88,42  GET 	oCelular VAR cCelular of oDlg
	@ 102,42 GET 	oEmail 	 VAR cEmail   of oDlg
	@ 116,42 GET 	oDtNasc	 VAR dDtNasc  READONLY SIZE 50,12 of oDlg
	If nOpCon == 2 .And. HU5->U5_STATUS	 == "N"
		@ 142,01 BUTTON oBtnExcluir CAPTION STR0016 ACTION ExcContato(cCodCli,cLojaCli,@cCodCon, @lAt) SIZE 50,12 of oDlg	 //"Excluir"
	Endif
	@ 142,55 BUTTON oBtnGravar CAPTION STR0017 ACTION GrvContato(nOpCon,cCodCli,cLojaCli,@cCodCon, cContat,cCpf,aFuncao,nFuncao,cFone,cCelular,cEmail,dDtNasc,@lAt) SIZE 50,12 of oDlg //"Gravar"
EndIf

ACTIVATE DIALOG oDlg

Return Nil