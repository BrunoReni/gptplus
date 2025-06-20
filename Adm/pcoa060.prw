#INCLUDE "pcoa060.ch"
#Define BMP_ON  "LBOK"
#Define BMP_OFF "LBNO"
/*
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOA060  � AUTOR � Edson Maricate        � DATA � 24.01.2004 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa para configuracao dos pontos de bloqueio            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOA060                                                      潮�
北砡DESCRI_  � Programa para configuracao dos pontos de bloqueio            潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplo: PCOA060(2) - Executa a chamada da funcao de visua-  潮�
北�          �                        zacao da rotina.                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function PCOA060(nCallOpcx)
Local lRet 	:= .T.

SaveInter()

Private cCadastro	:= STR0001 //"Configura玢o de Bloqueios Ativos"
Private aRotina := MenuDef()

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )

	If nCallOpcx <> Nil
		lRet := A060DLG("AKA",AKA->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AKA")
	EndIf

EndIf

RestInter()

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨060DLG   篈utor  矱dson Maricate      � Data � 24-01-2004  罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- 罕�
北�          � zacao                                                      罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � MP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function A060DLG(cAlias,nRecnoAKA,nOpcx)
Local oDlg
Local lCancel  := .F.
Local aButtons
Local aUsButtons := {}
Local oEnchAKA

Local oGdAKH
Local aHeadAKH
Local aColsAKH
Local nLenAKH   := 0 // Numero de campos em uso no AKH
Local nLinAKH   := 0 // Linha atual do acols
Local aRecAKH   := {} // Recnos dos registros
Local nGetD
Local nPosAtivo
Local l060Inclui := .F.
Local l060Altera := .F.
Local l060Exclui := .F.

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Adiciona botoes do usuario na EnchoiceBar                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock( "PCOA0602" )
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
	//P_E� na tela de configuracao dos lancamentos                                �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�  Ex. :  User Function PCOA0602                                         �
	//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

	If ValType( aUsButtons := ExecBlock( "PCOA0602", .F., .F. ) ) == "A"
		aButtons := {}
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If			aRotina[nOpcx][4] == 2
				l060Inclui := .F.
				l060Altera := .F.
				l060Exclui := .F.
ElseIf 	aRotina[nOpcx][4] == 4
				l060Inclui := .F.
				l060Altera := .T.
				l060Exclui := .F.
				nOpcx := 4
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 480,640 PIXEL
oDlg:lMaximized := .T.

// Carrega dados do AKA para memoria
RegToMemory("AKA",.F.)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Enchoice com os dados dos Lancamentos                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oEnchAKA := MSMGet():New('AKA',,2,,,,,{0,0,(oDlg:nClientHeight/6)-12,(oDlg:nClientWidth/2)},,,,,,oDlg,,,,,,.T.,,,)
oEnchAKA:oBox:Align := CONTROL_ALIGN_TOP

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Montagem do aHeader do AKH                                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
aHeadAKH := GetaHeader("AKH")
nLenAKH  := Len(aHeadAKH) + 1
nPosAtivo:= AScan(aHeadAKH,{|x| Upper(AllTrim(x[2])) == "AKH_ATIVO" })

If nPosAtivo = 0
	MsgInfo(STR0005) //"A utilizacao do campo AKH_ATIVO e obrigatoria. O Campo 'AKH_ATIVO' n鉶 est� dispon韛el, contate o Suporte Microsiga para ativ�-lo."
	Return .F.
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Montagem do aCols do AKH                                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
aColsAKH := {}
DbSelectArea("AKH")
DbSetOrder(1)
DbSeek(xFilial()+AKA->AKA_PROCES+AKA_ITEM)

While !l060Inclui .And. !Eof() .And. AKH->AKH_FILIAL + AKH->AKH_PROCES + AKH->AKH_ITEM == xFilial() + AKA->AKA_PROCES + AKA->AKA_ITEM
	AAdd(aColsAKH,Array( nLenAKH ))
	nLinAKH++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAKH, {|x,y| aColsAKH[nLinAKH][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

	// Deleted
	aColsAKH[nLinAKH][nLenAKH] := .F.
	
	// Adiciona o Recno no aRec
	AAdd( aRecAKH, AKH->( Recno() ) )
	
	AKH->(DbSkip())
EndDo

// Verifica se n鉶 foi criada nenhuma linha para o aCols
If Len(aColsAKH) = 0
	AAdd(aColsAKH,Array( nLenAKH ))
	nLinAKH++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAKH, {|x,y| aColsAKH[nLinAKH][y] := IIf(Upper(AllTrim(x[2])) == "AKH_SEQ", StrZero(1,Len(AKH->AKH_SEQ)),CriaVar(AllTrim(x[2])) ) })
	
	// Deleted
	aColsAKH[nLinAKH][nLenAKH] := .F.
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� GetDados com os Pontos de Lancamento          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If nOpcx = 3 .Or. nOpcx = 4
	nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nGetD := 0
EndIf
oGdAKH:= MsNewGetDados():New(0,0,100,100,nGetd,,,"+AKH_SEQ",,,9999,,,,oDlg,aHeadAKH,aColsAKH)
oGdAKH:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdAKH:CARGO := AClone(aRecAKH)
oGdAKH:oBrowse:blDblClick:={|| If( (nOpcx == 3 .Or. nOpcx == 4) .And. oGdAKH:oBrowse:nColPos == nPosAtivo , A060BMP(@oGdAKH,nPosAtivo), oGdAKH:EditCell() ) }

// Quando nao for MDI chama centralizada.
If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(A060Ok(nOpcx,oEnchAKA,oGdAKH),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons)
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(A060Ok(nOpcx,oEnchAKA,oGdAKH),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons)
EndIf

If lCancel
	RollBackSX8()
EndIf


Return !lCancel

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � A060Ok   篈utor  矴uilherme C. Leal   � Data �  11/26/04   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcao do botao OK da enchoice bar, valida e faz o         罕�
北�          � tratamento adequado das informacoes.                       罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A060Ok(nOpcx,oEnchAKA,oGdAKH)
Local nI
If nOpcx != 4 // Sempre sera alteracao, qq coisa diferente retorna .T.
	Return .T.
EndIf

If !A060Vld(nOpcx,oEnchAKA,oGdAKH)
	Return .F.
EndIf

If nOpcx = 4 // Alteracao

	// Grava as configuracoes dos Lancamento
	For nI := 1 To Len(oGdAKH:aCols)
		If nI <= Len(oGdAKH:Cargo) .And. oGdAKH:Cargo[nI] > 0
			AKH->(DbGoto(oGdAKH:Cargo[nI]))
			Reclock("AKH",.F.)
		Else
			If oGdAKH:aCols[nI][Len(oGdAKH:aCols[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AKH",.T.)
			EndIf
		EndIf
	
		If oGdAKH:aCols[nI][Len(oGdAKH:aCols[nI])] // Verifica se a linha esta deletada
			AKH->(DbDelete())
		Else
			// Varre o aHeader e grava com base no acols
			AEval(oGdAKH:aHeader,{|x,y| FieldPut( FieldPos(x[2]) , oGdAKH:aCols[nI][y] ) })
			Replace AKH_FILIAL With xFilial()
			Replace AKH_PROCES With AKA->AKA_PROCESS
			Replace AKH_ITEM   With AKA->AKA_ITEM

		EndIf

		MsUnlock()
	Next nI
EndIf

If __lSX8
	ConfirmSX8()
EndIf

Return .T.

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � A060Vld  篈utor  矴uilherme C. Leal   � Data �  11/26/04   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcao de validacao dos campos.                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A060Vld(nOpcx,oEnchAKA,oGdAKH)
Local nI
Local nPosField
If nOpcx != 4
	Return .T.
EndIf

For nI := 1 To Len(oGdAKH:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGdAKH:aHeader,{|x,y| x[17] .And. Empty(oGdAKH:aCols[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AKD"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0006 + AllTrim(oGdAKH:aHeader[nPosField][1]) + STR0007+Str(nI,3,0),3,1) //"Campo: "###"Linha: " //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨060BMP   篈utor  矴uilherme C. Leal   � Data �  22/12/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矨ltera bitmap de uso do lancamento.                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A060BMP(oGdAKH,nPosAtivo)
If !oGdAKH:aCols[oGdAKH:nAt][Len(oGdAKH:aHeader)+1]
	If oGdAKH:aCols[oGdAKH:nAt][nPosAtivo] == BMP_ON
		oGdAKH:aCols[oGdAKH:nAt][nPosAtivo]:= BMP_OFF
	Else
		oGdAKH:aCols[oGdAKH:nAt][nPosAtivo]:= BMP_ON
	EndIf
EndIf
   

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Ana Paula N. Silva     � Data �17/11/06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados     潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {	{ STR0002,		"AxPesqui", 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	"A060DLG" , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"A060DLG" , 0 , 4}} //"Alterar"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no aRotina                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

	If ExistBlock( "PCOA0601" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de Configuracao dos Lancamentos                         �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA0601                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOA0601", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)
