#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FINA004.CH"            

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINA004  �Autor  � Jair Ribeiro			� Data �13/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grupos de Analistas Financeiros.                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFIN                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador �Data    � BOPS     � Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Jonathan Glz�26/06/15�PCREQ-4256�Se elimina la funcion FIN004Help() la ���
���            �        �          �cual realiza modificacion a SX1 por   ���
���            �        �          �motivo de adecuacion a fuentes a nueva���
���            �        �          �estructura de SX para Version 12.     ���
���Jonathan Glz�09/10/15�PCREQ-4261�Merge v12.1.8                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FINA004()
Local cFilter		:= "FRQ_ITEM = ''"
Local lDefTop		:= .F.
Local cAlias		:= "FRQ"

Private cCadastro := STR0001	//"Grupo de Analistas Financeiros"
Private aRotina   := MenuDef()

dbSelectArea("FRQ")
dbSelectArea("FRO")

#IFDEF TOP
	lDefTop := .T.
#ENDIF

If lDefTop
	cFilter := "FRQ_ITEM = '" + Space(Len(FRQ->FRQ_ITEM)) + "'"
Else
	cFilter := '"FRQ_ITEM = ""'
	bFiltraBrw := { || FilBrowse(cAlias,@aIndexFil,@cFilter)}
	DbSelectArea(cAlias)
	Eval(bFiltraBrw)
Endif

FRQ->(DbSetOrder(1))
mBrowse( 006, 001, 022, 075, "FRQ"	,,,,,,,,,,,,,,Iif(lDefTop, cFilter,Nil) )
FRQ->(DbClearFilter())
FRQ->(DbSetOrder(1))

If !lDefTop
	EndFilBrw( cAlias, aIndexFil )
Endif
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA004GRPAN�Autor  �Alexandre Inacio Lemes � Data �13/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Manutencao do Grupo de Compradores             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FA004GRPAN(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA004                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FA004GRPAN( cAlias, nReg, nOpcX )
Local cSeek    	 	:= ""
Local cWhile   	 	:= ""
Local nSaveSX8 		:= GetSX8Len()
Local nOpcA    	 	:= 0
Local nX        	:= 0
Local aArea			:= FRQ->(GetArea())

Local aNoFields 	:= {"FRQ_GRPANA","FRQ_DESC"}

Local l004Visual	:= .F.
Local l004Inclui	:= .F.
Local l004Deleta	:= .F.
Local l004Altera	:= .F.
Local lGravaOK  	:= .T.
Local oDlg			:= Nil
Local oGetDados		:= Nil
Local bLinhaok		:= {|| FA004LinOK(oGetDados,.T.)}
Local bDelok		:= {|| FA004LinOK(oGetDados,,,.T.)}
Local bTudook		:= {|| FA004TudOK(oGetDados)}
Local lAutomato 	:= isBlind()  

Private aHeader 	:={}
Private aCols   	:={}

//���������������������������������������������������������Ŀ
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//�����������������������������������������������������������
If lAutomato
	if nOpcX == 3
		l004Inclui	:= .T.
	ElseIf nOpcX == 5
		l004Deleta	:= .T.
	EndIf
Else
	If	aRotina[nOpcX][4]  	== 2
		l004Visual := .T.
	ElseIf aRotina[nOpcX][4]== 3
		l004Inclui	:= .T.
	ElseIf aRotina[nOpcX][4] == 4
		l004Altera	:= .T.
	ElseIf aRotina[nOpcX][4] == 5
		l004Deleta	:= .T.
		l004Visual	:= .T.
	EndIf
EndIf


//�������������������������������������������������������Ŀ
//� Montagem do aHeader e aCols                           �
//���������������������������������������������������������
If l004Inclui
	FillGetDados(nOpcX,"FRQ",1,,,,aNoFields,,,,,.T.,,,)
	aCols[1][aScan( aHeader, { |x| Trim(x[2]) == "FRQ_ITEM" } )] := StrZero( 1, Len( FRQ->FRQ_ITEM ) )
Else
	cSeek  := xFilial("FRQ") + FRQ->FRQ_GRPANA
	cWhile := "FRQ->FRQ_FILIAL+FRQ->FRQ_GRPANA"
	FillGetDados(nOpcX,"FRQ",1,cSeek,{|| &cWhile },{|| (!Empty(FRQ_ITEM))},aNoFields,,,,,,,,)
EndIf

DEFINE MSDIALOG oDlg TITLE STR0001 FROM 1,1 TO 500,800 PIXEL OF oMainWnd	//"Grupos de Analistas Financeiros"
	oPanelI := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,30,30,.T.,.T. )
	oPanelI:Align := CONTROL_ALIGN_TOP
	
	RegToMemory("FRQ",l004Inclui)
	oMsGet := Msmget():New("FRQ" ,, nOpcx,,,,{"FRQ_GRPANA","FRQ_DESC"}, {18,2,210,318},Iif(l004Inclui,{"FRQ_GRPANA","FRQ_DESC"},{"FRQ_DESC"}),,,,, oPanelI, .F., .T.,,,, )
	oMsGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPanelJ := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,30,30,.T.,.T. )
	oPanelJ:Align := CONTROL_ALIGN_ALLCLIENT
	
	oGetDados := MsNewGetDados():New(0,0,150,200,IiF((!l004Visual .and. !l004Deleta),GD_INSERT+GD_UPDATE+GD_DELETE,0)	,"AllwaysTrue","AllwaysTrue","+FRQ_ITEM",,,,,,,oPanelJ,aHeader,aCols)
	oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetDados:bLinhaOk	:= bLinhaok
	oGetDados:bDelok	:= bDelok

	If ExistBlock("FA004SCR")
		ExecBlock("FA004SCR",.F.,.F.,{nOpcx,@oDlg})
	EndIf
IF !lAutomato // Tratamiento para scripts automatizados
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, IIf((Eval(bTudook).and. Obrigatorio(oMsGet:aGets,oMsGet:aTela)),(nOpcA := 1,oDlg:End()),nOpcA := 0)},{||oDlg:End()}) CENTERED
Else
      nOpcA  := 1
Endif

If nOpcA == 1
	If l004Inclui .Or. l004Altera .Or. l004Deleta
		lGravaOk := FA004Grava(l004Deleta,oGetDados)
		If lGravaOk
			EvalTrigger()
			If l004Inclui
				While (GetSX8Len()>nSaveSX8)
					ConFirmSX8()
				EndDo
			EndIf
		Else
			Help(" ",1, "F004TDOK")
			While (GetSX8Len()>nSaveSX8)
				RollBackSX8()
			EndDo
		EndIf
	EndIf
Endif
If nOpcA == 0 .And. l004Inclui
	While (GetSX8Len()>nSaveSX8)
		RollBackSX8()
	EndDo
EndIf
RestArea(aArea)
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |FA004LinOk�Autor  �Alexandre Inacio Lemes � Data �13/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA004                                                    ���
��������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������ ����
�����������������������������������������������������������������������������
*/
Static Function FA004LinOk(oGetDados,lVldLin,nLin,lDel)
Local nPosI 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "FRQ_USER"})
Local nPosJ 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "FRQ_ITEM"})
Local aColsX	:= aClone(oGetDaDos:aCols)
Local lRet		:= .T.
Local aArea     := GetArea()
Default	lVldLin	:= .F.
Default nLin	:= oGetDaDos:oBrowse:nAt
Default lDel := .F.


If !lDel .and. !GDDeleted(nLin,aHeader,aColsX).and. (!Empty(aColsX[nLin,nPosJ]).and. Empty(aColsX[nLin,nPosI]))
	Help( "", 1, "F004LINOK" )
	lRet := .F.
EndIf
If GDDeleted(nLin,aHeader,aColsX) .or. lVldLin .and. lRet
	If aScanX(aColsX,{|x,y| x[nPosI] == aColsX[nLin,nPosI] .and. y!= nLin .and. !GDDeleted(y,aHeader,aColsX)})>0
		Help( "", 1, "F004GRAVA" )
		lRet := .F.
	EndIf
EndIf
If Empty(oGetDados:aCols[1,2])
	Help( " ", 1, "F004VldCpo1", , STR0014, 1, 0 )	//"N�o pode incluir um Grupo sem um Analista !"
	lRet := .f.
Endif
RestArea(aArea)
Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA004TudOk�Autor  �Alexandre Inacio Lemes � Data �13/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de avaliacao da getdados ( TudoOk )                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA004                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FA004TudOk(oGetDados)
Local aArea   	:= GetArea()
Local nI      	:= 0
Local nAux 		:= 0
Local lRet		:= .T.
Local aColsX	:= aClone(oGetDados:aCols)

For nI:= 1 To Len(aColsX)
	If !GDDeleted(nI,aHeader,aColsX)
 		If !(oGetDaDos:ChkObrigat(nI))
 	 		lRet:= .F.
 	 		Exit
 	 	ElseIf !(lRet := FA004LinOk(oGetDados,.T.,nI))
 	 		Exit
 		EndIf
	Else
   		nAux ++
	EndIf
Next nI

If nAux == nI
	Help( " ", 1, "F004DELET")
	lRet:= .F.
EndIf

RestArea(aArea)
Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA004Grava�Autor  �Alexandre Inacio Lemes � Data �13/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta ok                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA004                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FA004Grava (l004Deleta,oGetDados)
Local aArea     := GetArea()
Local nPosItem 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "FRQ_ITEM"})
Local nI       	:= 0
Local nJ       	:= 0
Local aDados	:= aClone(oGetDados:aCols)
Local bCampo	:= {|n| FieldName(n)}
Local lContinua := .T.
Local lMT004VLD	:= .F.
Local lAutomato := isBlind()
//�������������������������������������������������������������-Ŀ
//� Pontos de Entrada para validar o aCols.                      �
//������������������������������������������������������������-���
If ( ExistBlock("MT004VLD") )
	lMT004VLD := ExecBlock( "MT004VLD", .F., .F., { aHeader, aCols, l004Deleta, M->FRQ_GRPANA})
	If ValType(lMT004VLD) == "L"
		lContinua := lMT004VLD
	EndIf
EndIf

If lAutomato .And. !l004Deleta
	If FindFunction ("GetParAuto")  // Tratamiento para scripts automatizados
		aRetAuto  	:= GetParAuto("FINA004TESTCASE")
		aDados 		:= aRetAuto[1]
		M->FRQ_DESC	:= aRetAuto[2]
	Endif
Endif

If lContinua
	Begin Transaction
		FRQ->(DbSetOrder(1))
		If FRQ->(DbSeek( xFilial("FRQ")+M->FRQ_GRPANA))
			If l004Deleta
		   		FRQ->(RecLock("FRQ",.F.,.T.))
			Else
				FRQ->(RecLock("FRQ",.F.))
			EndIf
		Else
			FRQ->(RecLock("FRQ",.T.))
		EndIf
			
		If !l004Deleta
			For nI := 1 To FCount()
				If ALLTRIM(EVAL(bCampo,nI)) $ "FRQ_GRPANA|FRQ_DESC"
					FieldPut(nI,M->&(EVAL(bCampo,nI)))
				EndIf
			Next nI
			FRQ->FRQ_FILIAL	:= xFilial("FRQ")
			FRQ->(MsUnLock())
		Else
			FRQ->(DbDelete())
			FRQ->(MsUnLock())
		EndIf
		
		FRQ->(DbSetOrder(1))
		For nI := 1 To Len(aDados)
			If FRQ->(DbSeek( xFilial("FRQ") + M->FRQ_GRPANA+aDados[nI][nPosItem]))
				If l004Deleta
		   			FRQ->(RecLock("FRQ",.F.,.T.))
				Else
					FRQ->(RecLock("FRQ",.F.))
				EndIf
			Else
				FRQ->(RecLock("FRQ",.T.))
			EndIf
		
			If !l004Deleta
				If !GDDeleted(nI,oGetDados:aHeader,oGetDados:aCols)
					//������������������������������������������������Ŀ
					//� Atualiza dados da GetDados                     �
					//��������������������������������������������������
					For nJ:=1 to Len(aHeader)
						If FieldPos(aHeader[nJ,2])> 0
					   		FRQ->(FieldPut( FieldPos( aHeader[nJ,2] ), aDados[nI,nJ] ) )
					 	EndIf
					Next nJ
					//�������������������������������������������������Ŀ
					//� Atualiza os Campos do Cabecalho/Rodape          �
					//���������������������������������������������������
					FRQ->FRQ_FILIAL	:= xFilial("FRQ")
					FRQ->FRQ_GRPANA := M->FRQ_GRPANA
				Else
					FRQ->(DbDelete())
					FRQ->(DbCommit())
				EndIf
			Else
				FRQ->(DbDelete())
				FRQ->(DbCommit())
			EndIf
			FRQ->(MsUnLock())
		Next nI
	End Transaction

	
	//��������������������������������������������������������������Ŀ
	//� Atualiza FRO em caso de exclusao de todos os itens do grupo  �
	//����������������������������������������������������������������
	If !FRQ->(DbSeek( xFilial("FRQ") + M->FRQ_GRPANA ))
		FRO->(DbSetOrder(2))
		While FRO->(DbSeek( xFilial() + M->FRQ_GRPANA ))
			If FRO->(RecLock( "FRO", .F. ))
				FRO->FRO_GRPANA := ""
				FRO->(MsUnLock())
			EndIf
		EndDo
	EndIf
	
	//Atualiza FRO
	If !l004Deleta
		For nI := 1 To Len(aDados)
			FRO->(DbSetOrder(1))
			If aDados[nI,6] == .T. //Excluido
				If FRO->(DbSeek(xFilial('FRO') + aDados[nI,2]))
					FRO->(RecLock('FRO',.F.))
					FRO->FRO_GRPANA := ''
					FRO->(MsUnLock())
				EndIf	
			Else
				If FRO->(DbSeek(xFilial('FRO') + aDados[nI,2]))
					FRO->(RecLock('FRO',.F.))
					FRO->FRO_GRPANA := M->FRQ_GRPANA
					FRO->(MsUnLock())
				EndIf
			EndIf
		End
	EndIf
	//������������������������������������������������������-Ŀ
	//� Pontos de Entrada apos gravacao.                      �
	//�����������������������������������������������������-���
	If (ExistBlock("MT004GRV"))
		ExecBlock("MT004GRV",.F.,.F.,{aHeader,aCols,l004Deleta,M->FRQ_GRPANA})
	EndIf

EndIf
RestArea(aArea)
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � F004VldUsr � Autor � Danilo Dias      � Data � 11/07/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se o campo digitado na MsGetDados j� existe e se o  ���
���          � mesmo foi deletado.                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Geral                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function F004VldCpo( cAlias, cCampo )
                       
Local aArea      := GetArea()
Local lRet       := .T.
Local nI         := 1
Local aCHeader   := aClone(aHeader)
Local aCCols     := aClone(aCols)
Local nLenCols   := Len(aCCols)
Local nLenHeader := Len(aCHeader)
Local nPosHeader := aScan( aCHeader, { |nPos| AllTrim(nPos[2]) == cCampo } )

lRet := ExistChav( cAlias, &( 'M->' + cCampo ), 2 )

If nPosHeader > 0 .And. lRet
	For nI := 1 To ( nLenCols )
		If nI != n	//Se n�o for a linha atual do grid
			If !(aCCols[nI,nLenHeader+1]) .And. AllTrim(aCCols[nI,nPosHeader]) == &( 'M->' + cCampo )
				lRet := .F.
				Help( " ", 1, "F004VldCpo", , STR0013, 1, 0 )	//"Registro j� gravado!"
				Exit	
			EndIf     
		EndIf
	Next nI
EndIf

RestArea(aArea)
       
Return lRet
 
/*
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �03/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function MenuDef()
Private aRotina := { { OemToAnsi(STR0002), "AxPesqui",   0, 1, 0, .F.},; 	//"Pesquisar"
					 { OemToAnsi(STR0003), "FA004GRPAN", 0, 2, 0, nil},; 	//"Visualizar"
					 { OemToAnsi(STR0004), "FA004GRPAN", 0, 3, 0, nil},; 	//"Incluir"
					 { OemToAnsi(STR0005), "FA004GRPAN", 0, 4, 0, nil},;	//"Alterar"
					 { OemToAnsi(STR0006), "FA004GRPAN", 0, 5, 3, nil} } 	//"Excluir"

If ExistBlock ("MTFA004MNU")
	ExecBlock ("MTFA004MNU", .F., .F.)
EndIf
Return (aRotina)  
