#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FRTA050.CH"

#define _PICTURE 13

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un嘺o	 � Frta050  � Autor � Edney Soares de Souza � Data � 26/09/00 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri嘺o � Efetua Sangria/Entrada de Troco no Front Loja			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � Fron Loja			   								  	  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�  Analista  � Data	� BOPS �  Motivo da Alteracao 					  潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矰anilo Calil�27/03/07�105168砈ubstituidas as funcoes:                  潮�
北�            �        |      � - VerifCaixa por LjxDVerCx				  潮�
北矯onrado Q.  �05/04/07�122711矨lterada a utiliza玢o da chamada          潮�
北�            �        �      砈ubStr(cUsuario,7,15) por cUserName       潮�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function Frta050(nCheck)
Local oDlgSangr, oCheck, oBtnAct, oBtnEnd, oGroup1, oGroup2, oGroup3
Local oCodOrigem, oCodDestin
Local oMoeda
Local cCodOrigem := xNumCaixa()
Local cCodDestin := Space(Len(cCodOrigem))
Local cMoedaCorr := GetMv("MV_MOEDA1")
Local cCampo     := ""
Local oDinheir, oCheques, oCartao, oVlrDebi, oFinanc, oConveni, oVales, oOutros
Local nDinheir  := 0
Local nCheques  := 0
Local nCartao   := 0
Local nVlrDebi  := 0
Local nFinanc   := 0
Local nConveni  := 0
Local nVales    := 0
Local nOutros   := 0        
Local nAltura   := 0
Local nAltura2  := 0
Local nX
Local nPosCampo := 0
Local aRet      := {} // Retorno do Ponto de Entrada
Local aMoedas   := {}
Local aSimbs    := {}
Local lRet      := .F.
Local cCaixaSup := Space(15)

Private nMoedaCorr := 1   // Moeda Corrente

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica Permissao "Sangria/Entrada de Troco" - #5 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If !LjProfile(5, @cCaixaSup)
    //"Usuario sem permissao para realizar Sangria / Entrada de Troco. Atencao" 				
	MsgStop(STR0022 + AllTrim(cUserName) + STR0023, STR0024)
	Return(NIL)
EndIf

If cPaisLoc != "BRA"
   nAltura   := 40
   nAltura2  := 15   
   SM2->(DbSetOrder(1))
   SM2->(DbSeek(dDatabase))
   For nX := 1 To MoedFin()             
      If !Empty(&("MV_MOEDA"+LTrim(Str(nX))))                          
         cCampo  := "M2_MOEDA"+Str(nX,1)
         nPosCampo := SM2->(FieldPos(cCampo))
         If IIf(nX > 1,SM2->(Found()) .And. SM2->(FieldGet(nPosCampo)) > 0,.T.)
	        AAdd(aMoedas,GetMv("MV_MOEDA"+LTrim(Str(nX))))			   
	        AAdd(aSimbs,GetMv("MV_SIMB"+LTrim(Str(nX))))			   	     	     
	     Else
	        MsgAlert(STR0025,STR0024) //"Por favor, preencher as cotacoes do dia de todas as moedas que estao sendo usadas no sistema!"###"Atencao"
	        Return(Nil)
	     EndIf   
	  EndIf   
   Next nX   
EndIf

nCheck := if(nCheck ==NIl,0,nCheck)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Se Troco o caixa destino sempre eh o operador atual�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If nCheck = 2
	cCodDestin := xNumCaixa()
	cCodOrigem := Substr(GetMv("MV_CXLOJA"),1,3)
Else
	cCodDestin := Substr(GetMv("MV_CXLOJA"),1,3)
	cCodOrigem := xNumCaixa()
EndIf

If lGaveta
	If (!Empty(LJGetStation("PORTGAV"))) .And. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
		GavetaAci(nHdlGaveta, LJGetStation("PORTGAV"))
	Else
		IFGaveta(nHdlECF)
	EndIf
EndIf

If ExistBlock("FRT050SA")
	aRet := ExecBlock("FRT050SA",.F.,.F.,{nCheck,cCodOrigem,cCodDestin})
	nCheck		:= aRet[1]
	cCodOrigem	:= aRet[2]
	cCodDestin	:= aRet[3]
	nDinheir	:= aRet[4]
	nCheques	:= aRet[5]
	nCartao		:= aRet[6]
	nVlrDebi	:= aRet[7]
	nFinanc		:= aRet[8]
	nConveni	:= aRet[9]
	nVales		:= aRet[10]
	nOutros		:= aRet[11]
EndIf

SX5->(dbSetOrder(1)) // Primeiro indice para validacao do caixa digitado
SA6->(dbSetOrder(1)) // Primeiro indice para obtencao da Agencia/Conta para geracao do SE5

DEFINE MSDIALOG ODlgSangr FROM 1,1 TO 388+nAltura,330 TITLE STR0001 PIXEL OF GetWndDefault()

@ 005,004 GROUP oGroup1 TO 043,057 LABEL STR0002 COLOR CLR_HBLUE OF oDlgSangr PIXEL

@ 013,007 RADIO oCheck VAR nCheck 3D SIZE 47,10 PROMPT STR0003,STR0004 ON CHANGE Frt050Enab(nCheck,@cCodOrigem,@cCodDestin,oCodOrigem,oCodDestin) OF ODlgSangr PIXEL

If ! nCheck == 0
	oCheck:Disable()
Else
	nCheck := 1
EndIf

@ 005,061 GROUP oGroup2 TO 043,162 LABEL STR0005 COLOR CLR_HBLUE OF oDlgSangr PIXEL

@ 012,065 SAY STR0006 SIZE 50,10 OF ODlgSangr PIXEL
@ 012,120 MSGET oCodOrigem VAR cCodOrigem F3 "23" WHEN nCheck == 2 SIZE 30,10 OF ODlgSangr PIXEL ;
VALID SX5->(dbSeek(xFilial("SX5")+"23"+cCodOrigem)) .and. SA6->(dbSeek(xFilial("SA6")+cCodOrigem) .And. cCodOrigem <> xNumCaixa())
oCodOrigem:cSx1Hlp:=""

@ 027,065 SAY STR0007 SIZE 50,10 OF ODlgSangr PIXEL
@ 027,120 MSGET oCodDestin VAR cCodDestin F3 "23" WHEN nCheck == 1 SIZE 30,10 OF ODlgSangr PIXEL ;
VALID SX5->(dbSeek(xFilial("SX5")+"23"+cCodDestin)) .and. SA6->(dbSeek(xFilial("SA6")+cCodDestin) .And. cCodDestin <> xNumCaixa())
oCodDestin:cSx1Hlp:=""

@ 046,004 GROUP oGroup3 TO 176+nAltura2,162 LABEL STR0008 COLOR CLR_HBLUE OF oDlgSangr PIXEL

@ 055,014 SAY STR0009 SIZE 60,10 OF ODlgSangr PIXEL
@ 055,074 MSGET oDinheir VAR nDinheir Picture PesqPict("SL1","L1_DINHEIR",_PICTURE,nMoedaCorr) SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oDinheir:cSx1Hlp:="L1_DINHEIR"

@ 070,014 SAY STR0010 SIZE 60,10 OF ODlgSangr PIXEL
@ 070,074 MSGET oCheques VAR nCheques Picture PesqPict("SL1","L1_CHEQUES",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oCheques:cSx1Hlp:="L1_CHEQUES"

@ 085,014 SAY STR0011 SIZE 60,10 OF ODlgSangr PIXEL
@ 085,074 MSGET oCartao VAR nCartao Picture PesqPict("SL1","L1_CARTAO",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oCartao:cSx1Hlp:="L1_CARTAO"

@ 100,014 SAY STR0012 SIZE 60,10 OF ODlgSangr PIXEL
@ 100,074 MSGET oVlrDebi VAR nVlrDebi Picture PesqPict("SL1","L1_VLRDEBI",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oVlrDebi:cSx1Hlp:="L1_VLRDEBI"

@ 115,014 SAY STR0013 SIZE 60,10 OF ODlgSangr PIXEL
@ 115,074 MSGET oFinanc VAR nFinanc Picture PesqPict("SL1","L1_FINANC",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oFinanc:cSx1Hlp:="L1_FINANC"

@ 130,014 SAY STR0014 SIZE 60,10 OF ODlgSangr PIXEL
@ 130,074 MSGET oConveni VAR nConveni Picture PesqPict("SL1","L1_CONVENI",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oConveni:cSx1Hlp:="L1_CONVENI"


@ 145,014 SAY STR0015 SIZE 60,10 OF ODlgSangr PIXEL
@ 145,074 MSGET oVales VAR nVales Picture PesqPict("SL1","L1_VALES",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oVales:cSx1Hlp:="L1_VALES"

@ 160,014 SAY STR0016 SIZE 60,10 OF ODlgSangr PIXEL
@ 160,074 MSGET oOutros VAR nOutros Picture PesqPict("SL1","L1_OUTROS",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oOutros:cSx1Hlp:="L1_OUTROS"

If cPaisLoc != "BRA"
   @ 175,014 SAY STR0026 SIZE 60,10 OF ODlgSangr PIXEL  //"Moeda: " 		
   @ 175,074 MSCOMBOBOX oMoeda VAR cMoedaCorr ITEMS aMoedas ON CHANGE (nMoedaCorr:=oMoeda:nAt);
             SIZE 70,10 OF ODlgSangr PIXEL 
EndIf   

DEFINE SBUTTON oBtnAct FROM 180+nAltura2,105 TYPE 1 ENABLE ACTION ;
					Frt050Conf(	nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
								nDinheir	,nCheques	,nCartao	,nVlrDebi,;
								nFinanc		,nConveni	,nVales		,nOutros,;
								aSimbs		,ODlgSangr) OF ODlgSangr

DEFINE SBUTTON oBtnEnd FROM 180+nAltura2,135 TYPE 2 ENABLE ACTION ODlgSangr:End() OF ODlgSangr

ACTIVATE MSDIALOG ODlgSangr CENTER

RETURN NIL
             
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un嘺o	 矲rt050Conf� Autor � Cleber Martinez       � Data � 06/10/05 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri嘺o � Confirma a gravacao dos valores informados (Botao OK)   	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � ExpL1 := Frt050Conf(ExpN1, ExpC2, ExpC3, ExpC4,            潮�
北�			 � 					  ExpN5, ExpN6, ExpN7, ExpN8,             潮�
北�			 � 					  ExpN9, ExpN10, ExpN11, ExpN12,          潮�
北�  		 � 					  ExpA13, ExpO14)			              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpN1 - Indica se eh Troco ou Sangria                      潮�
北�          � ExpC2 - Codigo do Caixa logado                             潮�
北�          � ExpC3 - Codigo do caixa (De)                               潮�
北�          � ExpC4 - Codigo do caixa (Ate)                              潮�
北�          � ExpN5 - Valor em dinheiro                                  潮�
北�          � ExpN6 - Valor em cheques                                   潮�
北�          � ExpN7 - Valor em cartao                                    潮�
北�          � ExpN8 - Valor em debitos 	                              潮�
北�          � ExpN9 - Valor financiado                                   潮�
北�          � ExpN10 - Valor em Convenios                                潮�
北�          � ExpN11 - Valor em Vales                                    潮�
北�          � ExpN12 - Outros valores                                    潮�
北�          � ExpA13 - array de Simbolos de Moeda                        潮�
北�          � ExpO14 - Objeto dialog                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � Front Loja			   								  	  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function Frt050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
					nDinheir	,nCheques	,nCartao	,nVlrDebi,;
					nFinanc		,nConveni	,nVales		,nOutros,;
					aSimbs		,ODlgSangr)

Local lFrt050SB := ExistBlock("FRT050SB") //indica se existe o PE
Local lVldPE	:= .T.	//retorno da validacao executada no PE
Local lRet		:= .F.	//retorno da funcao

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Ponto de Entrada (antes da gravacao do SE5) �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If lFrt050SB
	lVldPE := ExecBlock("FRT050SB",.F.,.F.,{nCheck,cCaixaSup,nDinheir,nCheques,nCartao,nVlrDebi,nFinanc,nConveni,nVales,nOutros,cCodOrigem,cCodDestin})
	If Valtype(lVldPE) != "L"
		lVldPE := .T.
	Endif	
Endif	

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Se o PE retornar .T., continua a gravacao �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If lVldPE                                                 
	LjMsgRun(STR0017,,{|| lRet := Frt050SE5(nCheck,cCodOrigem,cCodDestin,nDinheir,nCheques,nCartao,nVlrDebi,nFinanc,nConveni,nVales,nOutros,aSimbs)})
	
	If (lRet .And. LJProfile(3) .And. ExistBlock("Frt050ST"))
		ExecBlock("Frt050ST",.F.,.F.,{nCheck,cCaixaSup,nDinheir,nCheques,nCartao,nVlrDebi,nFinanc,nConveni,nVales,nOutros})
	Endif
	
	ODlgSangr:End()	
Endif
                    
Return (lRet)

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un嘺o	 矲rt050Enab� Autor � Edney Soares de Souza � Data � 26/09/00 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Ativa/Desativa os campos conforme a escolha do Radio Btn	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � Frta050				   								  	  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function Frt050Enab(nCheck,cCodOrigem,cCodDestin,oCodOrigem,oCodDestin)
If nCheck == 1
	cCodOrigem := xNumCaixa()
	oCodOrigem:Refresh()
	oCodDestin:SetFocus()
Else
	cCodDestin := xNumCaixa()
	oCodDestin:Refresh()
	oCodOrigem:SetFocus()
EndIf
Return NIL

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un嘺o	 矲rt050SE5 � Autor � Edney Soares de Souza � Data � 26/09/00 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Gera o SE5 Conforme os campos digitados na tela			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � Frta050				   								  	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpN1 - (1 - nCheck)Indica se e troco ou sangria.          潮�
北�          � ExpC1 - (2 - cCodOrigem) Codigo do caixa origem.           潮�
北�          � ExpC2 - (3 - cCodDestin) Codigo do caixa destino.          潮�
北�          � ExpN1 - (4 - nDinheir) Valor em dinheiro.                  潮�
北�          � ExpN2 - (5 - cCheques) Valor em cheques.                   潮�
北�          � ExpN3 - (6 - nCartao) Valor em cartao.                     潮�
北�          � ExpN4 - (7 - nVlrDeb) Valor em debitos.                    潮�
北�          � ExpN5 - (8 - nFinanc) Valor financiado.                    潮�
北�          � ExpN6 - (9 - nConveni) Valor em convenios.                 潮�
北�          � ExpN7 - (10 - nVales) Valor em vales.                      潮�
北�          � ExpN8 - (11 - nOutros) Outros valores.                     潮�
北�          � ExpA1 - (12 - aSimbs) Array de simbolos de moeda.          潮�
北�          � ExpL1 - (13 - lMensa) Se ira exibir mensagem.              潮�
北�          � ExpL2 - (14 - lSigaLoja) Indica se a funcao esta sendo     潮�
北�          �							chamada do siga loja.             潮�
北媚哪哪哪哪呐哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矰ata      | Analista | Bops  | Descricao                               |北
北媚哪哪哪哪呐哪哪哪哪哪拍哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�18/11/2005| Marcos R.|088079 | Detalhamento da Sangria no CUPOM        |北 
北�02/10/2007| Nunzio   |132489 | Criacao do parametro lSigaLoja          |北  
北滥哪哪哪哪牧哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function Frt050SE5(nCheck	, cCodOrigem, cCodDestin, nDinheir	, ;
                   nCheques	,nCartao	,nVlrDebi	,nFinanc	, ;
                   nConveni	,nVales		,nOutros	,aSimbs		, ;
                   lMensa	,lSigaLoja	,nVlrPagDig, nVlrPagPix )
                   
Local aNumerarios   := {}																	//Array com os valores
Local nX			:= 0																	//Variavel de controle contador
Local nTotal 		:= nDinheir+nCheques+nCartao+nVlrDebi+nFinanc+nConveni+nVales+nOutros 	//Valor total 
Local cSimb 		:= SuperGetMV("MV_SIMB"+LTrim(Str(nMoedaCorr)))                        //Simbolo da moeda
Local nRet			:= 0                                                                   	//Variavel de retorno da impressao do comprovante
Local lSup      	:= SuperGetMV("MV_FORMSUP", ,.F.)                                      //Indica se ira exibir formulario
Local cFormSup		:= '' 																	// Contem a descricao das formas de Suprimentos que saira no cupom
Local cCupom		:= ""																	//Numero do cupom
Local lSE5ToFKs		:= ExistFunc("LjSE5ToFKs")

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//矱staremos utilizando esta fun玢o de outros programas             �
//硃ortanto em determinadas ocasi鮡s n鉶 deverei exibir mensagens   �
//硃arando o processo. Atualmente teremos no fonte LOJA340 e LOJA350�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Default lMensa 		:= .T.
Default lSigaLoja 	:= .F.
Default nVlrPagDig	:= 0
Default nVlrPagPix	:= 0

nTotal := nDinheir+nCheques+nCartao+nVlrDebi+nFinanc+nConveni+nVales+nOutros+nVlrPagDig+nVlrPagPix	//Valor total

If nTotal == 0 .And. lMensa
	MsgStop(STR0018,STR0024)  //"Nenhum valor foi informado, nenhuma movimenta玢o ser� gerada." ### "Aten玢o"
	Return (.F.)
EndIf

If lMensa
	//"Confirma grava玢o da(s) movimenta玢o(鮡s) referente(s) a quantia de: "
	If !MsgYesNo(STR0019+cSimb+" "+Transform(nTotal,PesqPict("SL1","L1_DINHEIR",_PICTURE,nMoedaCorr)) )
		Return (.F.)
	EndIf
EndIf

aNumerarios := {{cSimb,nDinheir}	,;
				{"CH",nCheques}		,;
				{"CC",nCartao}		,;
				{"CD",nVlrDebi}		,;
				{"FI",nFinanc}		,;
				{"CO",nConveni}		,;
				{"VA",nVales}		,;
				{"OU",nOutros}		,;
				{"PD",nVlrPagDig}	,;
				{"PX",nVlrPagPix}	}

If lSup 
	If nDinheir > 0
		cFormSup	:= STR0029 + "|" + STRZERO(nDinheir, 10,2)+"|" //DINHEIRO
	EndIf
	If nCheques > 0			     
		cFormSup = cFormSup + STR0030 + "|" + STRZERO(nCheques, 10,2)+"|" //CHEQUE
	EndIf	
	If nCartao > 0			     
		cFormSup = cFormSup + STR0031 + "|" + STRZERO(nCartao, 10,2)+"|" //CARTAO CREDITO
	EndIf	
	If nVlrDebi > 0			     
		cFormSup = cFormSup + STR0032 + "|" + STRZERO(nVlrDebi, 10,2)+"|" //CARTAO DEBITO
 	EndIf	
	If nFinanc > 0			     
		cFormSup = cFormSup + STR0033 + "|" + STRZERO(nFinanc, 10,2)+"|" //FINANCIADO
	EndIf	
	If nConveni > 0			     
		cFormSup = cFormSup + STR0034 + "|" + STRZERO(nConveni, 10,2)+"|" //CONVENIO
	EndIf
	If nVales > 0			     
		cFormSup = cFormSup + STR0035 + "|" + STRZERO(nVales, 10,2)+"|" //VALES
	EndIf

	If nVlrPagDig > 0			     
		cFormSup = cFormSup + "PAGTO DIGITAL" + "|" + STRZERO(nVlrPagDig, 10,2)+"|" //PAGTO DIGITAL
	EndIf
	If nVlrPagPix > 0
		cFormSup = cFormSup + "PAGTO PIX" + "|" + STRZERO(nVlrPagPix, 10,2)+"|" //PAGTO PIX
	EndIf

	If nOutros > 0			     
		cFormSup = cFormSup + STR0036 + "|" + STRZERO(nOutros, 10,2)+"|" //OUTROS
	EndIf
	
EndIf
                              
If lFiscal .And. nTotal > 0 .And. !ExistBlock("Frt050ST")
	nRet := IFSupr( nHdlECF, If(nCheck=1,3,nCheck), StrZero(nTotal,14,2), "","",, cFormSup )
	If nRet != 0
		// "N鉶 foi poss韛el registrar " ### "Sangria","Troco" ### " no ECF. Opera玢o n鉶 efetuada." ### "Aten玢o"
		MsgStop(STR0027 + If(nCheck==1,STR0003,STR0004) + STR0028, STR0024)
		Return(.F.)
	Else
	   nRet := IfPegCupom( nHdlECF, @cCupom)
	   
	   If nRet != 0
			// "N鉶 foi poss韛el registrar " ### "Sangria","Troco" ### " no ECF. Opera玢o n鉶 efetuada." ### "Aten玢o"
			MsgStop(STR0027 + If(nCheck==1,STR0003,STR0004) + STR0028, STR0024)
			Return(.F.)
		EndIf
		//--------------------------------------------------------
	EndIf
EndIf

For nX := 1 to If(nCheck==1,Len(aNumerarios),1)
	If !aNumerarios[nX][2] == 0
		FRT050GRV(cCodOrigem, nCheck, "P", aNumerarios[nX], ;
				  aSimbs	, lSigaLoja, cCupom)
		//Gera FKs com base na SE5 gerada
		If lSE5ToFKs
			LjSE5ToFKs()
		EndIf	

		FRT050GRv(cCodDestin, nCheck, "R", aNumerarios[nX], ;
			      aSimbs, lSigaLoja, cCupom)
		//Gera FKs com base na SE5 gerada
		If lSE5ToFKs
			LjSE5ToFKs()
		EndIf
	EndIf
Next nX

Return(.T.)

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un嘺o	 矲rt050GRV � Autor � Edney Soares de Souza � Data � 26/09/00 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Grava o Registro no SE5 conforme os parametros recebidos	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � Frta050				 								  	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 - (1 - cCodigo) Codigo do caixa.                     潮�
北�          � ExpN1 - (2 - nCheck) Indica se e troco ou sangria.         潮�
北�          � ExpC2 - (3 - nRecPag) Indica se e pagto ou recebimento.    潮�
北�          � ExpN2 - (4 - aNum) Valor a ser gravado.                    潮�
北�          � ExpA1 - (5 - aSimbs) Array de simbolos de moeda.           潮�
北�          � ExpL1 - (6 - lSigaLoja) Indica se a funcao esta sendo      潮�
北�          �							chamada do siga loja.             潮�
北媚哪哪哪哪呐哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矰ata      | Analista | Bops  | Descricao                               |北
北媚哪哪哪哪呐哪哪哪哪哪拍哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�02/10/2007| Nunzio   |132489 | Criacao do parametro lSigaLoja          |北  
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function FRT050Grv (cCodigo	, nCheck, cRecPag, aNum, ;
					aSimbs	, lSigaLoja, cCupom, dDataMovto)

Local cCaixa 		:= xNumCaixa()										//Numero do caixa
Local cNatureza 	:= If(nCheck == 1,Upper(STR0003),Upper(STR0004))  	//"Sangria","Troco"
Local cHistor   	:= If(nCheck == 1,STR0020,STR0021)+cCaixa  		//"SANGRIA DO CAIXA ","TROCO PARA O CAIXA "
Local cAgencia  	:= ""                                       		//Numero da agencia
Local cConta    	:= ""                                       		//Numero da conta
Local nDecs1    	:= MsDecimais(1)                            		//Numero de casas decimais
Local cPrefixo      := LjGetStation("LG_SERIE")							//Numero de serie do PDV
Local nSequencia	:= 0												//Proxima sequecia a ser gravada
Local oInt			:= Nil                                              //Objeto da integracao
Local lGerInte		:= SuperGetMV("MV_LJGRINT",.F. ,.F.) 					//Verifica se a integracao esta habilitada
Local lMovBco       := .T.
Local lLj7050Grv	:= ExistBlock("LJ7050GRV")                          //Verifica se existe o ponto de entrada LJ7050GRV
Local nRecnoSE5     := 0                                                //Recno da tabela SE5
Local cNumMov		:= AllTrim(LjNumMov())								//Retorno o numero do movimento atual
Local nTamCod   	:= TamSX3("A6_COD")[1]								//Tamanho do campo A6_COD
Local nTamAg   		:= TamSX3("A6_AGENCIA")[1]							//Tamanho do campo A6_AGENCIA
Local nTamConta		:= TamSX3("A6_NUMCON")[1]							//Tamanho do campo A6_NUMCON
Local cCodBanco   	:= ""												//Codigo do banco		
Local cCodAgen   	:= ""												//Codigo do agencia
Local cNumCon       := "" 												//Numero do conta	
Local cSeek			:= ""												// Variavel para controle do SA6	
Local aCxLoja		:= Separa(SuperGetMV("MV_CXLOJA",.F.,""),"/")

DEFAULT lSigaLoja 	:= .F.
DEFAULT dDataMovto	:= dDataBase

If Len(aCxLoja) >= 3
	cCodBanco   	:= PADR(aCxLoja[1],nTamCod) //Codigo do banco		
	cCodAgen   		:= PADR(aCxLoja[2],nTamAg) //Codigo do agencia
	cNumCon       	:= PADR(aCxLoja[3],nTamConta) //Numero do conta	
EndIf		

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Efetua apenas 1 lancamento pois somente baterah o  �
//� Resumo de Caixa qdo os dados subirem p/ o servidor.�
//� Sangria de Cx para Cx jah possui 2 registros,      �
//� um R e um P.                                       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

If cCodigo == cCaixa .Or. cCodigo == Substr(GetMv("MV_CXLOJA"),1,3) .OR. lSigaLoja

	DbSelectArea("SE5")

    DbSetOrder(2)

    If DbSeek(xFilial("SE5") + "TR" + PadR(cPrefixo, TamSX3("E5_PREFIXO")[1]) + PadR(cCupom, TamSX3("E5_NUMERO")[1]) + space(TamSX3("E5_PARCELA")[1]) + space(TamSX3("E5_TIPO")[1]) + DTOS(dDatabase))
       While !Eof() .AND. xFilial("SE5") + "TR" + PadR(cPrefixo, TamSX3("E5_PREFIXO")[1]) + PadR(cCupom, TamSX3("E5_NUMERO")[1]) + space(TamSX3("E5_PARCELA")[1]) + space(TamSX3("E5_TIPO")[1]) + DTOS(dDatabase) == SE5->E5_FILIAL + SE5->E5_TIPODOC + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + DTOS(SE5->E5_DATA)
           nSequencia  := Val(SE5->E5_SEQ)
           DbSkip()
       End 
    EndIf

	// Para caixa de destino (cCodDestin) trata Caixa/Ag阯cia/Conta que define o Caixa Geral no SIGALOJA.
	If cRecPag = "R" .and. AllTrim(cCodigo)== AllTrim(cCodBanco)
		cSeek := cCodBanco+cCodAgen+cNumCon
	Else
		cSeek := cCodigo
	EndIf
	
	// Posiciona no registro correto do SA6
	SA6->(dbSeek(xFilial("SA6")+cSeek))	

	//Busca o Caixa da moeda correspondente a sangria                          
	If cPaisLoc != "BRA" .And. nMoedaCorr > 1                      
       cConta	 := SA6->A6_NUMCON	      //Conta do Caixa na moeda 1                            
	   cAgencia  := aSimbs[nMoedaCorr]	  //Agencia do Caixa na moeda da sangria/troco     
	   LjxDVerCx(nMoedaCorr,cCodigo,cAgencia,cConta)   //Verifica se existe o Caixa na moeda da sangria/troco. Se nao existir,cria.           
	   SA6->(dbSeek(xFilial("SA6")+cCodigo+cAgencia))  //Posiciona no Caixa da moeda da sangria/troco                          
	EndIf	
	Reclock("SE5",.T.)
	SE5->E5_FILIAL	:= xFilial("SE5")              
	SE5->E5_DATA	:= dDataMovto
	SE5->E5_BANCO	:= SA6->A6_COD
	SE5->E5_AGENCIA	:= SA6->A6_AGENCIA
	SE5->E5_CONTA	:= SA6->A6_NUMCON
	SE5->E5_RECPAG	:= cRecPag
	SE5->E5_HISTOR	:= cHistor
	SE5->E5_TIPODOC	:= "TR"
	SE5->E5_MOEDA	:= If(nCheck=1, aNum[1], "TC")
	SE5->E5_VALOR	:= aNum[2]
	SE5->E5_DTDIGIT	:= dDataBase
	SE5->E5_BENEF	:= Space(15)
	SE5->E5_DTDISPO	:= SE5->E5_DATA
	SE5->E5_NATUREZ	:= cNatureza
	SE5->E5_PREFIXO := cPrefixo
	SE5->E5_NUMERO  := cCupom
	SE5->E5_SEQ     := strzero(nSequencia + 1, 2)
	SE5->E5_SITUA	:= "00" // Criar esse campo para instalacao do Front Loja
	If cPaisLoc != "BRA"  //Para compatibilizar com o Resumo de Caixa
	   SE5->E5_VLMOED2	:= Round(xMoeda(SE5->E5_VALOR,nMoedaCorr,1,dDataMovto,nDecs1+1),nDecs1)
	   SE5->E5_TIPO     := aNum[1]	   
	EndIf   
	If SE5->(FieldPos("E5_NUMMOV")) > 0
		SE5->E5_NUMMOV := cNumMov
	EndIf
	SE5->E5_FILORIG := cFilAnt
	SE5->(dbCommit())
	SE5->(MsUnLock())
	nRecnoSE5 := SE5->(Recno())
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砅onto de entrada que permite realizar alteracoes no movimento gerado na tabela SE5 � 
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If lLj7050Grv
		ExecBlock("LJ7050GRV",.F.,.F.,{nRecnoSE5})
	EndIf	
      
    If lSigaLoja
	   	If SE5->E5_MOEDA$"C1/C2/C3/C4/C5/CH".AND.;
			( (Empty(SE5->E5_NUMCHEQ) .OR. Substr(SE5->E5_NUMCHEQ,1,1)=="*") .AND. SE5->E5_NATUREZ <> Upper(STR0003) )			
			lMovbco := .F.
		Endif
	   	If SE5->E5_VENCTO <= SE5->E5_DATA .AND. lMovBco
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Atualiza Saldo Bancario		              				     �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,If(Upper(AllTrim(cRecPag)) == "P","-","+"))
		EndIf	                                  
	EndIf	
	If lGerInte .AND. nModulo == 12 .AND. (Alltrim(Upper(FunName())) $ "LOJA340|LOJA350")
		
		If AllTrim(Upper(cNatureza)) == "TROCO"
			
			oInt := LJCAdapXMLEnvSuprimento():New()
		
		ElseIf AllTrim(Upper(cNatureza)) == Upper(STR0003)
			
			oInt := LJCAdapXMLEnvSangria():New()	
		
		EndIf
		
		If oInt != Nil
			oInt:Inserir("SE5", xFilial("SE5") +  SE5->E5_TIPODOC + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + DTOS(SE5->E5_DATA) + SE5->E5_CLIFOR + SE5->E5_LOJA + SE5->E5_SEQ, "2", "3")
			oInt:Gerar() 
			oInt:Finalizar() 
		EndIf
	EndIf	
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矱sta gera玢o deve ser efetuada somente qdo chamada do Front Loja             �
	//硃ois a tabela SLI tem como 鷑ica fun玢o subir os movimentos para a retaguarda|
	//�                                                                             �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If Alltrim(Upper(FunName())) $ "FRTA010|FRTA271"
		FRTGeraSLI("    ", "050", Str(SE5->(Recno()),17,0), "NOVO")
	EndIf
			
EndIf

Return NIL
