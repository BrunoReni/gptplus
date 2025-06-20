
#INCLUDE "PCOA030.ch"
#INCLUDE "PROTHEUS.CH"
/*
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOA030  � AUTOR � Guilherme C. Leal     � DATA � 26.11.2003 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa para cadastro de processos                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOA030                                                      潮�
北砡DESCRI_  � Programa para cadastro de processos, pontos de lancamentos   潮�
北砡DESCRI_  � e pontos de bloqueio.                                        潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplo: PCOA030(2) - Executa a chamada da funcao de visua-  潮�
北�          �                        zacao da rotina.                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOA030(nCallOpcx)
Private cCadastro	:= STR0001 //"Cadastro de Processos de Sistema"
Private aRotina := MenuDef()    

If ExistBlock("PCOA030VAR")
	ExecBlock("PCOA030VAR",.F.,.F.)
EndIf

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil
		A030DLG("AK8",AK8->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AK8")
	EndIf
EndIf
Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨030DLG   篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- 罕�
北�          � zacao                                                      罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function A030DLG(cAlias,nRecnoAK8,nCallOpcx)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {{"NCO",{|| A030PropLc(@cCposCfg) },STR0015,STR0016}}//"Configura玢o dos Campos"###"Campos"
Local aUsButtons := {}
Local oEnchAK8
Local oFolder

Local oGdAKB
Local aHeadAKB
Local aColsAKB
Local nLenAKB   := 0 // Numero de campos em uso no AKB
Local nLinAKB   := 0 // Linha atual do acols
Local aRecAKB   := {} // Recnos dos registros
Local nGetD
Local oSize
Local nLinIni := 0 
Local nColIni := 0 
Local nLinEnd := 0 
Local nColEnd := 0 

Local oBarAKB
Local oBtnAKB

Private INCLUI  := (nCallOpcx = 3)
Private cCposCfg := If(Inclui,"",AK8->AK8_PROPLC)

If !AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	Return .F.
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoAK8) == "N" .And. nRecnoAK8 > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoAK8)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAK8)))
		Return .F.
	EndIf
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Adiciona botoes do usuario na EnchoiceBar                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock( "PCOA0302" )
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
	//P_E� na tela de processos                                                   �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�  Ex. :  User Function PCOA0302                                         �
	//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

	If ValType( aUsButtons := ExecBlock( "PCOA0302", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

oSize := FwDefSize():New(.T.,,,)
oSize:AddObject( "CABECALHO",  100, 20, .T., .T. ) 
oSize:AddObject( "GETDADOS" ,  100, 80, .T., .T. ) 
oSize:lProp 	:= .T. 
oSize:Process() 

DEFINE MSDIALOG oDlg TITLE STR0007 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4]  PIXEL //"Cadastro de Processos"

// Carrega dados do AK8 para memoria
RegToMemory("AK8",INCLUI)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Enchoice com os dados do Processo                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
nLinIni :=   oSize:GetDimension("CABECALHO","LININI") 
nColIni :=  oSize:GetDimension("CABECALHO","COLINI") 
nLinEnd := oSize:GetDimension("CABECALHO","LINEND")
nColEnd := oSize:GetDimension("CABECALHO","COLEND") 

oEnchAK8 := MSMGet():New('AK8',,nCallOpcx,,,,,{nLinIni,nColIni,nLinEnd,nColEnd},,,,,,oDlg,,,,,,.T.,,,)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Folder com os Pontos de Lancamento                                     �
//� Pontos de Bloqueio foi desativada pois tera tela especifica            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
nLinIni :=   oSize:GetDimension("GETDADOS","LININI") 
nColIni :=  oSize:GetDimension("GETDADOS","COLINI") 
nLinEnd := oSize:GetDimension("GETDADOS","LINEND")
nColEnd := oSize:GetDimension("GETDADOS","COLEND") 

oFolder  := TFolder():New(nLinIni,nColIni,{STR0008/*,STR0009*/},{''},oDlg,1,,,.T.,,nColEnd,nLinEnd-80,) //"Pontos de Lan鏰mento"###"Pontos de Bloqueio"

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Montagem do aHeader do AKB                                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
aHeadAKB := GetaHeader("AKB")
nLenAKB  := Len(aHeadAKB) + 1

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Panel para colocar botoes no folder de Pontos de Lancamento            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

AADD(aButtons, {"NOTE"		, {|| A030Lancto(oGdAKB) }, STR0017 } )	//"Configura玢o dos Lan鏰mentos"


//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Montagem do aCols do AKB                                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
aColsAKB := {}
DbSelectArea("AKB")
DbSetOrder(1)
DbSeek(xFilial()+AK8->AK8_CODIGO)

While nCallOpcx != 3 .And. !Eof() .And. AKB->AKB_FILIAL + AKB->AKB_PROCES == xFilial() + AK8->AK8_CODIGO
	AAdd(aColsAKB,Array( nLenAKB ))
	nLinAKB++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAKB, {|x,y| aColsAKB[nLinAKB][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

	// Deleted
	aColsAKB[nLinAKB][nLenAKB] := .F.
	
	// Adiciona o Recno no aRec
	AAdd( aRecAKB, AKB->( Recno() ) )
	
	AKB->(DbSkip())
EndDo

// Verifica se n鉶 foi criada nenhuma linha para o aCols
If Len(aColsAKB) = 0
	AAdd(aColsAKB,Array( nLenAKB ))
	nLinAKB++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAKB, {|x,y| aColsAKB[nLinAKB][y] := IIf(Upper(AllTrim(x[2])) == "AKB_ITEM", StrZero(1,Len(AKB->AKB_ITEM)),CriaVar(AllTrim(x[2])) ) })

	// Deleted
	aColsAKB[nLinAKB][nLenAKB] := .F.
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� GetDados com os Pontos de Lancamento          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If nCallOpcx = 3 .Or. nCallOpcx = 4
	nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nGetD := 0
EndIf
oGdAKB:= MsNewGetDados():New(0,0,100,100,nGetd,,,"+AKB_ITEM",,,9999,,,,oFolder:aDialogs[1],aHeadAKB,aColsAKB)
oGdAKB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdAKB:CARGO := AClone(aRecAKB)

// Quando nao for MDI chama centralizada. 

If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(A030Ok(nCallOpcx,oEnchAK8,oGdAKB),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons,,,,, .F. )
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(A030Ok(nCallOpcx,oEnchAK8,oGdAKB),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons,,,,, .F. )
EndIf


If lCancel
	RollBackSX8()
EndIf


Return !lCancel

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � A030Ok   篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcao do botao OK da enchoice bar, valida e faz o         罕�
北�          � tratamento adequado das informacoes.                       罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A030Ok(nCallOpcx,oEnchAK8,oGdAKB)
Local nI
Local cCampo
If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If !A030Vld(nCallOpcx,oEnchAK8,oGdAKB)
	Return .F.
EndIf

If nCallOpcx = 3 // Inclusao

	// Grava Processo
	Reclock("AK8",.T.)
	For nI := 1 To FCount()
		cCampo := Upper(AllTrim(FieldName(nI)))
		If cCampo == "AK8_FILIAL"
			FieldPut(nI,xFilial())
		Else
			FieldPut(nI, &("M->" + cCampo))
		EndIf
	Next nI
	AK8->AK8_PROPLC	:= cCposCfg
	MsUnlock()
	
	// Grava Pontos de Lancamento
	For nI := 1 To Len(oGdAKB:aCols)
		If oGdAKB:aCols[nI][Len(oGdAKB:aCols[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AKB",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		AEval(oGdAKB:aHeader,{|x,y| FieldPut(FieldPos(x[2]), oGdAKB:aCols[nI][y] ) })

		Replace AKB_FILIAL With xFilial()
		Replace AKB_PROCES With AK8->AK8_CODIGO

		MsUnlock()

	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao

	// Grava Processo
	Reclock("AK8",.F.)
	For nI := 1 To FCount()
		cCampo := Upper(AllTrim(FieldName(nI)))
		If cCampo == "AK8_FILIAL"
			FieldPut(nI,xFilial())
		Else
			FieldPut(nI, &("M->" + cCampo))
		EndIf
	Next nI
	AK8->AK8_PROPLC	:= cCposCfg	
	MsUnlock()

	// Grava Pontos de Lancamento
	For nI := 1 To Len(oGdAKB:aCols)
		If nI <= Len(oGdAKB:Cargo) .And. oGdAKB:Cargo[nI] > 0
			AKB->(DbGoto(oGdAKB:Cargo[nI]))
			Reclock("AKB",.F.)
		Else
			If oGdAKB:aCols[nI][Len(oGdAKB:aCols[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AKB",.T.)
			EndIf
		EndIf
	
		If oGdAKB:aCols[nI][Len(oGdAKB:aCols[nI])] // Verifica se a linha esta deletada
            // Se houver alguma configuracao de lancamento, apaga.
			If AKC->(DbSeek(xFilial()+AKB->AKB_PROCES+AKB->AKB_ITEM))
				While AKC->(!Eof()) .And. AKC->AKC_FILIAL + AKC->AKC_PROCES + AKC->AKC_ITEM == xFilial("AKC") + AKB->AKB_PROCES + AKB->AKB_ITEM
					Reclock("AKC",.F.)
					AKC->(DbDelete())
					MsUnLock()
					AKC->(DbSkip())
				EndDo
			EndIf
			AKB->(DbDelete())
		Else
			// Varre o aHeader e grava com base no acols
			AEval(oGdAKB:aHeader,{|x,y| FieldPut( FieldPos(x[2]) , oGdAKB:aCols[nI][y] ) })
			Replace AKB_FILIAL With xFilial()
			Replace AKB_PROCES With AK8->AK8_CODIGO

		EndIf

		MsUnlock()
	Next nI

ElseIf nCallOpcx = 5 // Exclusao

	AKC->(DbSetOrder(1))
	// Exclui Pontos de Lancamento
	For nI := 1 To Len(oGdAKB:aCols)
		If nI <= Len(oGdAKB:Cargo) .And. oGdAKB:Cargo[nI] > 0
			AKB->(DbGoto(oGdAKB:Cargo[nI]))

            // Se houver alguma configuracao de lancamento, apaga.
			If AKC->(DbSeek(xFilial()+AKB->AKB_PROCES+AKB->AKB_ITEM))
				While AKC->(!Eof()) .And. AKC->AKC_FILIAL + AKC->AKC_PROCES + AKC->AKC_ITEM == xFilial("AKC") + AKB->AKB_PROCES + AKB->AKB_ITEM
					Reclock("AKC",.F.)
					AKC->(DbDelete())
					MsUnLock()
					
					AKC->(DbSkip())
				EndDo
			EndIf

			Reclock("AKB",.F.)
			AKB->(DbDelete())
			MsUnLock()
		EndIf		
	Next nI

	// Exclui Processo
	Reclock("AK8",.F.)
	AK8->(DbDelete())
	MsUnLock()

EndIf

If __lSX8
	ConfirmSX8()
EndIf

Return .T.

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � A030Vld  篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcao de validacao dos campos.                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A030Vld(nCallOpcx,oEnchAK8,oGdAKB)
Local nI
If (nCallOpcx = 3 .Or. nCallOpcx = 4) .And. !Obrigatorio(oEnchAK8:aGets,oEnchAK8:aTela)
	Return .F.
EndIf


If nCallOpcx = 5   //exclusao

	AKA->(dbSetOrder(1))
	If AKA->(DbSeek(xFilial()+M->AK8_CODIGO))
	   Aviso(STR0018, STR0019, {"Ok"})//"Atencao"###"Nao pode ser excluido, pois existem pontos de Bloqueio."
		Return .F.
	EndIf

EndIf		  
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Codigos de 0 a 4999 sao reservados para lancamentos internos,     �
//� os demais podem ser usados em customizacoes                       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

If Val(M->AK8_CODIGO) < 900000
	If nCallOpcx = 3
		MsgInfo(STR0011) //"O c骴igo utilizado deve ser maior que 900000."
		Return .F.
	ElseIf nCallOpcx = 4 .Or. nCallOpcx = 5
		If !(MsgYesNo(STR0012 +CRLF+ STR0026)) //"O processo atual � padr鉶, voc� tem certeza que deseja salvar as altera珲es? Obs: O processo padr鉶 ser� restaurado ao reiniciar o sistema, desfazendo as altera珲es realizadas."
			Return .F.
		EndIf
	EndIf
EndIf

For nI := 1 To Len(oGdAKB:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGdAKB:aHeader,{|x,y| x[17] .And. Empty(oGdAKB:aCols[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AKD"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+ STR0020 + AllTrim(oGdAKB:aHeader[nPosField][1]) + STR0021 +Str(nI,3,0),3,1) //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨030Lancto篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Faz a chamada da A040Dlg para edicao dos lancammentos      罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A030Lancto(oGdAKB)
Local nPosDesc := AScan(oGdAKB:aHeader,{|x| Upper(AllTrim(x[2])) == "AKB_DESCRI" })
Local lRet     := .F.
Local nLin     := oGdAKB:oBrowse:nAt

If Empty(nLin)
	Return .F.
EndIf

If nLin > Len(oGdAKB:CARGO)
	MsgInfo(STR0013) //"O Registro atual ainda n鉶 foi salvo. Salve-o antes de editar seus lan鏰mentos."
	Return .F.
EndIf
If nPosDesc <= 0
	MsgInfo(STR0014) //"O campo 'AKB_DESCRI' n鉶 est� habilitado, favor contactar o suporte Microsiga para que o campo seja habilitado."
	Return .F.
EndIf

AKB->(DbGoto(oGdAKB:CARGO[nLin]))
If AKB->(EOF()) .OR. AKB->(BOF())
	Return .F.
EndIf

lRet := A040DLG("AKB",AKB->(Recno()),4)

Return lRet



Function A030PropLc(cPropri)

Local aArea	:= GetArea()
Local aSX3	:= {}
Local aParamBox	:= {}
Local aRet		:= {}      
Local nx

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AKD")
While !Eof() .and. SX3->X3_ARQUIVO == "AKD"
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel
		aAdd(aSX3,SX3->X3_CAMPO)
		nPos := AT(Alltrim(SX3->X3_CAMPO)+";",cPropri)
		If nPos > 0
			If Substr(cPropri,Len(Alltrim(SX3->X3_CAMPO))+nPos+1,1) == "1"
				lCheck := .T.
			Else
				lCheck := .F.
			EndIf
		Else
			lCheck := .F.
		EndIf
		If Empty(aParamBox)
			aAdd(aParamBox,{ 4 ,STR0022,lCheck,Alltrim(X3DESCRIC()),80 ,""    ,.F.  })//"Campos Visuais ?"
		Else
			aAdd(aParamBox,{ 4 ,"",lCheck,Alltrim(X3DESCRIC()),75 ,""    ,.F.  })
		EndIf
	EndIf
	dbSkip()
End

If ParamBox(aParamBox,STR0023,@aRet)//"Configura玢o da Tela de Lancamentos"
	cPropri := ""
	For nx := 1 to Len(aRet)
		cPropri += AllTrim(aSX3[nx])+";"+If(aRet[nx],"1","2")+CHR(13)+CHR(10)
	Next
EndIf

RestArea(aArea)
Return cPropri
                



/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Ana Paula N. Silva    � Data �17/11/06  潮�
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
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados         潮�
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
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	"A030DLG" , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"A030DLG" , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"A030DLG" , 0 , 4},; //"Alterar"
							{ STR0006, 		"A030DLG" , 0 , 5}} //"Excluir"

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no aRotina                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOA0301" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de processos                                            �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA0301                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOA0301", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf

Return(aRotina)
