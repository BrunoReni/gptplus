#include "PROTHEUS.CH"  
#include "QIPA060.CH"   


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA060  � Autor � Cleber Souza          � Data � 27/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Equipes de Follow-up            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �  									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                                                          
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001) ,"AxPesqui" , 0 , 1,,.F.},;  //"Pesquisa"    
                    {OemToAnsi(STR0002) ,"QP060FOL" , 0 , 2},;  //"Visualiza"   
                    {OemToAnsi(STR0003) ,"QP060FOL" , 0 , 3},;  //Incluir"   
                    {OemToAnsi(STR0004) ,"QP060FOL" , 0 , 4},;  //"Alterar"    
                    {OemToAnsi(STR0005) ,"QP060FOL" , 0 , 5 , 3 }}  //"Excluir"

Return aRotina

Function QIPA060 

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006)   //"Equipes de Follow-up"  

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
PRIVATE aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QP4")

Return .T. 

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QP060FOL � Autor � Cleber Souza          � Data � 27/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Equipes de Follow-up            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QP060FOL(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QP060FOL(cAlias,nReg,nOpc)

Local oDlg   
Local oEquipe  
Local oGroup
Local oFont
Local nOpcA 
Local cCod
Local lInclui    := IIF(nOpc == 3, .T., .F.)
Local cMontAcols := IIF(lInclui,"","{|| QP060LOAD(nOpc)}")
Local oSize

Private aHeader    := {}
Private aCols      := {} 
Private oGet     
Private nPosRes  := 0
Private nPosDRe  := 0
Private nPosAli  := 0
Private nPosRec  := 0 
Private aGets    := {}
Private aTela    := {}

RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)

  FillGetDados(nOpc,"QP5" ,1     ,      ,             ,         ,         ,          ,        ,      ,&cMontAcols,lInclui ,          ,        ,          ,           ,            ,)
//FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols  ,lEmpty  ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry

//����������������������������������������������������������������������Ŀ
//� Verifica a posicao dos campos no aHeader p/ posterior consistencia   �
//������������������������������������������������������������������������
nPosRes  := Ascan(aHeader,{|x| x[2] = "QP5_RESPON"})
nPosDRe  := Ascan(aHeader,{|x| x[2] = "QP5_NOMUSU"})

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"	,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS"	,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE cCadastro FROM ;
					oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL 	 //"Grupos de Produtos"
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

oEquipe := MsMGet():New(cAlias,nReg,nOpc,,,,,{;
									oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI"),;
						 			oSize:GetDimension("ENCHOICE","LINEND"),oSize:GetDimension("ENCHOICE","COLEND")},,,,,,oDlg,,.T.,,,,,,,.T.) 

@ 53,003 GROUP oGroup TO 150,314 LABEL STR0007 OF oDlg PIXEL //"Respons�veis"  
oGroup:oFont:= oFont

oGet := MsNewGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
						 				oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND"),;
						 				Iif(nOpc==3 .Or. nOpc==4, GD_INSERT+GD_DELETE+GD_UPDATE, 0),"QP060LOk","QP060TOk","",,,,,,,oDlg,aHeader,aCols)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(Obrigatorio(aGets,aTela),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{|| nOpca := 0,oDlg:End()}) CENTERED

If nOpcA==1 .and. nOpc<>2
	QP060GrvAll(nOpc)
EndIf

Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QP060LOAD �Autor  �Cleber Souza        � Data �  25/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina que carrega o aHeader e aCols da GetDados.          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � QIPA060                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP060LOAD(nOpc)

Local nIteCol := 0

nPosAli  := Ascan(aHeader,{|x| x[2] = "QP5_ALI_WT"})
nPosRec  := Ascan(aHeader,{|x| x[2] = "QP5_REC_WT"})   

dbSelectArea("QP5")
If dbSeek( xFilial("QP5")+QP4->QP4_EQUIPE ) .and. nOpc<>3
	While !EOF() .And. QP5_FILIAL+QP5_EQUIPE == xFilial("QP5")+QP4->QP4_EQUIPE
	    Aadd(aCols,Array(Len(aHeader)+1))
		For nIteCol:=1 to Len(aHeader)
			If aHeader[nIteCol,10] # "V"
				aCols[Len(aCols),nIteCol] := &("QP5->"+aHeader[nIteCol,2])
			Else
				If !(aHeader[nIteCol,2] $ "QP5_ALI_WT | QP5_REC_WT")
					If aHeader[nIteCol,2] == "QP5_NOMUSU"
						aCols[Len(aCols),nIteCol] := QA_NUSR(,QP5->QP5_RESPON,.T.,"N")
					Else
						aCols[Len(aCols),nIteCol] := CriaVar(AllTrim(aHeader[nIteCol,2]))
					EndIf
				EndIf
			Endif
		Next nIteCol
		If nPosAli > 0 .and. nPosRec > 0
			aCols[Len(aCols),nPosAli] := Alias()
			If IsHeadRec(aHeader[nPosRec,2])
				aCols[Len(aCols),nPosRec] := QP5->(RecNo())
			EndIf
		Endif
		aCols[Len(aCols),Len(aHeader)+1] := .F. 
		dbSelectArea("QP5")
		dbSkip()
	Enddo
EndIf

Return 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QP060LOk � Autor � Cleber Souza           � Data � 27/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QP060LOk(o)
Local lRet	:= .T.
Local nAchou	:= 0
Local aCols     := oGet:aCols
Local n         := oGet:nAT
Local cProcura	:= aCols[n,nPosRes]
Local nDel      := Len(oGet:aHeader)+1

If !(aCols[n,Len(aCols[n])])
	//�������������������������������������������������������������Ŀ
	//� Verifica se campo Responsavel esta' preenchido              �
	//���������������������������������������������������������������
	If !aCols[n,nDel] 
		If Empty(aCols[n,nPosRes])
			Help(" ",1,"QA_CPOOBR")
			lRet:=.F.	
		EndIf
	EndIf
	If lRet
		//�������������������������������������������������Ŀ
		//� Verifica se o Responsavel ja' existe            �
		//���������������������������������������������������
		nAchou := Ascan(aCols,{|x| x[nPosRes] == cProcura .And. !(x[Len(aCols[n])])})
		If nAchou > 0 .And. nAchou # n
			Help(" ",1,"A070EXIREE")
			lRet:=.F.
		EndIf
	EndIf

	//�������������������������������������������������Ŀ
	//� Verifica se o Responsavel esta' cadastrado      �
	//� e nao � demitido.                               �	
	//���������������������������������������������������
	If lRet
		If ! Empty(aCols[n,nPosRes])
			lRet := QA_CHKMAT(xFilial("QAA"),aCols[n,nPosRes])
		EndIf	
	EndIf
EndIf				
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QP060GrvAll� Autor � Cleber Souza         � Data � 27/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava a amarracao Responsavel X Equipe                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QP060GrvAll(nOpc)
Local nX 
Local nY 
Local nDel := Len(oGet:aHeader)+1  
Local cVar 
Local cCod 
Local aStruAlias := FWFormStruct(3, "QP4")[3]

//��������������������������������������������������������������Ŀ
//� Atualiza os dados referentes a Equipe                        �
//����������������������������������������������������������������
dbSelectArea("QP4")
RecLock("QP4",If(nOpc==3,.T.,.F.))
If (nOpc == 3 .Or. nOpc == 4) //Inclusao ou Alteracao
	For nX := 1 To Len(aStruAlias)
		If GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") <> "V"
			FieldPut(FieldPos(AllTrim(aStruAlias[nX,1])),&("M->"+aStruAlias[nX,1]))
		EndIf
	Next nX
	If FieldPos("QP4_FILIAL") > 0
		FieldPut(FieldPos("QP4_FILIAL"),xFilial("QP4"))
	EndIf
EndIf
MsUnlock()

dbSelectArea("QP5")
//����������������������������Ŀ
//� Grava o arquivo QP5        �
//������������������������������
For nX := 1 to Len(oGet:aCols)
	If ! Empty(oGet:aCols[nX,nPosRes]) // Cod. Responsavel nao vazio
		If !oGet:aCols[nX,nDel] .and. (nOpc==3 .or. nOpc==4)	// Nao esta deletado
			If dbSeek(xFilial("QP5") + QP4->QP4_EQUIPE + oGet:aCols[nX,nPosRes])
				RecLock("QP5",.F.)	// Lock
			Else
				RecLock("QP5",.T.)	// Append
			Endif
			For nY := 1 to Len(oGet:aHeader)
				If oGet:aHeader[nY,10] # "V"
					cVar := Trim(oGet:aHeader[nY,2])
					Replace &cVar. With oGet:aCols[nX,nY]
				Endif
			Next ny
			QP5->QP5_EQUIPE := QP4->QP4_EQUIPE
			QP5->QP5_FILIAL := xFilial("QP5")
			QP5->QP5_FILMAT := cFilAnt
			MsUnLock()
		Else
		 	//���������������������������������������Ŀ
			//� Cancela o Responsavel no QP5          �
			//�����������������������������������������
			If dbSeek(xFilial("QP5") + QP4->QP4_EQUIPE + oGet:aCols[nX,nPosRes])			
				RecLock("QP5",.F.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	EndIf
Next nX  

//�������������������������������������������������������������Ŀ
//� Na Rotina de exlus�o, Equipe tem de ser excluido por ultimo �
//���������������������������������������������������������������
If (nOpc == 5)	
	
	cCod := QP4->QP4_EQUIPE
	
	dbSelectArea("QP4")
	RecLock("QP4",.F.)
	dbDelete()
	MsUnlock() 
	
	//���������������������������������������������������������������Ŀ
	//� Apaga tambem do QP3 -> Grupos de Produtos                     �
	//�����������������������������������������������������������������
	dbSelectArea('QP3')
	dbSetOrder(2)
	If dbSeek( xFilial("QP3")+cCod )
		While !EOF()
			RecLock("QP3",.F.,.t.)
			QP3->QP3_EQUIPE := space(TamSX3("QP3_EQUIPE")[1])
			dbSeek( xFilial("QP3")+cCod )
		EndDo
	EndIf	
	dbSetOrder(1)

	//���������������������������������������������������������������Ŀ
	//� Apaga tambem do QQ5 -> Linhas de Produtos                     �
	//�����������������������������������������������������������������
	dbSelectArea('QQ5')
	dbSetOrder(2)
	If dbSeek( xFilial("QQ5")+cCod )
		While !EOF()
			RecLock("QQ5",.F.,.t.)
			QQ5->QQ5_EQUIPE := space(TamSX3("QQ5_EQUIPE")[1])
			dbSeek( xFilial("QQ5")+cCod )
		EndDo
	EndIf	
	dbSetOrder(1)
	
EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A060VlRe � Autor � Cleber Souza          � Data � 27/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Responsavel                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA060 - E' chamada no X3_VALID do cpo. QP5_RESPON - SX3  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A060VlRe()
Local lRetu    := .t.
Local nI       := 0 
Local cVar     := &(readvar()) // Conteudo da variavel do campo Responsavel
Local n        := oGet:nAT

//����������������������������������������������������������������������Ŀ
//� Verifica se mudou o Responsavel (Alterou o campo ja' digitado)       �
//������������������������������������������������������������������������
If !Empty(oGet:aCols[n,nPosRes]) .and. !Empty(cVar) .and. oGet:aCols[n,nPosRes] <> cVar
	Help(" ",1,"A010ALTCHA")	// Campo nao pode ser alterado	
	lRetu := .f.
EndIf

//�������������������������������������������������Ŀ
//� Verifica se o Responsavel esta' cadastrado      �
//���������������������������������������������������
If lRetu
	oGet:aCols[n,nPosRes] := M->QP5_RESPON
	If ! QA_CHKMAT(cFilAnt,oGet:aCols[n,nPosRes],.T.)
		lRetu := .f.
	EndIf
EndIf

//���������������������������������������������������������Ŀ
//� Verifica se o Responsavel ja' existe p/ esta Equipe     �
//�����������������������������������������������������������
If lRetu
	For nI := 1 to len(oGet:aCols)
		If cVar == oGet:aCols[nI,nPosRes] .and. nI <> n // Se ja' existir este cod. NC
			Help(" ",1,"A060EXIRES")
			lRetu := .f.
		EndIf
	Next nI
EndIf

//�������������������������������������������������Ŀ
//� Preenche o nome do Responsavel                  �
//���������������������������������������������������
If lRetu
	oGet:aCols[n,nPosDRe] := QA_NUSR(,cVar,.T.,"N")
EndIf

Return(lRetu)

