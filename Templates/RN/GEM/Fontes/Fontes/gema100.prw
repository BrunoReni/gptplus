#INCLUDE "gema100.ch"
#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GEMA100   �Autor  �Reynaldo Miyashita  � Data �  04.05.2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tratamento de vencimento dos titulos                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGEM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function GEMA100(cAlias,nReg,nOpc)
Local aArea := GetArea()

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004) //"Renegocia��o de T�tulos"

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//������������������������������������������������������������������������Ŀ
//�Endereca para a funcao MBrowse                                          �
//��������������������������������������������������������������������������
dbSelectArea("LIZ")
LIZ->(dbSetOrder(1)) // LIZ_FILIAL+LIZ_NCONTR+LIZ_REVISA
MsSeek(xFilial("LIZ"))
mBrowse(06,01,22,75,"LIZ")

//������������������������������������������������������������������������Ŀ
//�Restaura a Integridade da Rotina                                        �
//��������������������������������������������������������������������������
dbSelectArea("LIZ")
LIZ->(dbSetOrder(1)) // LIZ_FILIAL+LIZ_NCONTR+LIZ_REVISA
dbClearFilter()

RestArea(aArea)

Return .T.


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA100View� Autor � Reynaldo Miyashita    � Data � 26.07.2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de Visualizar as renegociacoes                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �T_GMA100View()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias do Arquivo                                       ���
���          �ExpN2: Numero do Registro                                     ���
���          �ExpN3: Opcao do aRotina                                       ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMA100View(cAlias,nReg,nOpc)

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	Do Case
		// Vencimento
		Case LIZ->LIZ_TIPREG == "2"
			T_GEMA101(cAlias,nReg,nOpc)
		// Quitacao
		Case LIZ->LIZ_TIPREG == "4"
			T_GEMA102(cAlias,nReg,nOpc)
	EndCase  
	
Return( .T. )


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMViewCont� Autor � Reynaldo Miyashita    � Data � 04.05.2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Visualiza o contrato original                                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �GMViewContr(cContrato, cRevisa)                               ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Numero do contrato                                     ���
���          �ExpC2: Numero da revisao do contrato                          ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMViewContr(cContrato, cRevisa)

Local oDlgR
Local oGetLJA
Local oGetLJB
Local aCampos	:= {}
Local aColsCON 	:= {}
Local aHeadCON  := {}
Local aButtons  := {}
Local aArea     := GetArea()
Local nOpcA     := 0
Local nOpcGD    := 0
Local nX        := 0
Local nUsado    := 0
Local cCpoGrv   := ""

Private aTELA[0][0]
Private aGETS[0]
                   
// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//
// cabecalho do contrato original(historico)
//
dbSelectArea("LJA")
LJA->(dbSetOrder(2)) //LJA_FILIAL+LJA_NCONTR+LJA_REVISA
If LJA->(MsSeek(xFilial("LJA")+cContrato+cRevisa))
	
	aHeadCON := aClone(TableHeader("LJB"))
	nUsado	 := Len(aHeadCON)
	
	//
	// Itens do contrato original(historico)
	//
	dbSelectArea("LJB")
 	LJB->(dbSetOrder(1)) // LJB_FILIAL+LJB_DOC+LJB_SERIE+LJB_REVISA+LJB_CLIENT+LJB_LOJA+LJB_COD+LJB_ITEM
	IF LJB->(MsSeek(xFilial("LJB")+LJA->LJA_DOC+LJA->LJA_SERIE+LJA->LJA_REVISA+LJA->LJA_CLIENT+LJA->LJA_LOJA))
		While LJB->(!eof()) .AND. LJA->LJA_DOC+LJA->LJA_SERIE+LJA->LJA_REVISA+LJA->LJA_CLIENT+LJA->LJA_LOJA == ;
		     LJB->LJB_DOC+LJB->LJB_SERIE+LJB->LJB_REVISA+LJB->LJB_CLIENT+LJB->LJB_LOJA
			AADD(aColsCON,Array(nUsado+1))
			For nX := 1 To Len(aHeadCON)
				cCpoGrv := FieldName(FieldPos(AllTrim(aHeadCON[nX,2])))
				aColsCON[Len(aColsCON),nX] := &cCpoGrv
			Next
			aColsCON[Len(aColsCON),nUsado+1] := .F.
			LJB->(dbSkip())
		Enddo
	Endif
	
	//������������������������������������������������������Ŀ
	//� Faz o calculo automatico de dimensoes de objetos     �
	//��������������������������������������������������������
	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 015, .T., .f. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,;
	                       {{003,033,160,200,240,263}} )
	
	DEFINE MSDIALOG oDlgR TITLE OemToAnsi(STR0014) From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL   //"Visualiza��o do Contrato Original"
	
	dbSelectArea("LJA")
	RegToMemory("LJA",.F.)
	oGetLJA := MsMGet():New("LJA",LJA->(RecNo()),2,,,,,{003,000,125,100},,,,,,oDlgR )
	oGetLJA:oBox:Align := CONTROL_ALIGN_TOP
	
	oGetLJB := MsNewGetDados():New(002,02,097,338,nOpcGD,"AllwaysTrue","AllwaysTrue",,,,9999,,,,oDlgR,aHeadCON,aColsCON)
	oGetLJB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	Aadd(aButtons,{"GROUP"    ,{|| ContrViewSol( M->LJA_NCONTR ,M->LJA_REVISA) } ,STR0015,STR0016}) //"Cadastro de Solidarios"###"Solidarios"
	ACTIVATE MSDIALOG oDlgR ON INIT EnchoiceBar(oDlgR,{|| nOpca:=1,oDlgR:End()},{|| nOpca:= 0,oDlgR:End()},,aButtons)
	
Else
	// nao encontrou o contrato antigo
EndIf

RestArea(aArea)

Return( .T. )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ContrViewS� Autor � Reynaldo Miyashita    � Data � 23.06.2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Visualiza os solidarios do cliente no Historico do contrato.  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �ContrViewS(cContrato, cRevisa)                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Numero do contrato                                     ���
���          �ExpC2: Numero da revisao do contrato                          ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ContrViewSol( cContrato ,cRevisa )

Local oDlgR
Local oGetSol
Local aHeadSOL	  := {}
Local aColsSOL	  := {}
Local nPos_CODSOL := 0
Local nPos_LJSOLI := 0
Local nPos_NOMSOL := 0
Local nCount      := 0
Local nUsado      := 0

Local aArea := GetArea()

	// cabecalho do contrato (historico)
	dbSelectArea("LJA")
	LJA->(dbSetOrder(2)) //LJA_FILIAL+LJA_NCONTR+LJA_REVISA
	If LJA->(dbSeek(xFilial("LJA")+cContrato+cRevisa))
							
		aHeadSOL := aClone(TableHeader("LJF"))
		nUsado   := len(aHeadSOL)
		
		//
		//
		dbSelectArea("LJF")
		LJF->(dbSetOrder(1)) // LJF_FILIAL+LJF_NCONTR+LJF_REVISA
		If LJF->(dbSeek(xFilial("LJF")+cContrato+cRevisa))
			RegToMemory("LJF",.F.)
			While LJF->(!Eof()) .And. xFilial("LJF") == LJF->LJF_FILIAL .And. cContrato == LJF->LJF_NCONTR
				Aadd(aColsSOL,Array(nUsado+1))
				For nCount := 1 To nUsado
					cCpoGrv := FieldName(FieldPos(AllTrim(aHeadSOL[nCount ,2])))
					aColsSOL[Len(aColsSOL),nCount ] := &cCpoGrv
				Next nCount
				aColsSOL[Len(aColsSOL),nUsado+1] := .F.
				LJF->(dbSkip())
			Enddo
		Endif
	
		If Empty(aColsSOL)
			aColsSOL := Array(1,nUsado+1)
			dbSelectArea("SX3")
			SX3->(dbSetOrder(1)) // X3_FILIAL+X3_CAMPO
			SX3->(dbSeek("LJF"))
			nUsado := 0
			
			While !Eof() .And. (SX3->x3_arquivo == "LJF")
			
				If X3USO(SX3->x3_usado) .And. cNivel >= SX3->x3_nivel
					nUsado++
					aColsSOL[1,nUsado] := CriaVar( SX3->X3_Campo)
				EndIf
				SX3->(dbSkip())
			EndDo
			aColsSOL[1,nUsado+1] := .F.
			
		Else
			//
			// preenche o campo LJF_NOMSOL
			//
			nPos_CODSOL := aScan( aHeadSOL ,{|x|Upper(AllTrim(x[2])) == "LJF_CODSOL" } )
			nPos_LJSOLI := aScan( aHeadSOL ,{|x|Upper(AllTrim(x[2])) == "LJF_LJSOLI" } )
			nPos_NOMSOL := aScan( aHeadSOL ,{|x|Upper(AllTrim(x[2])) == "LJF_NOMSOL" } )
	
			If nPos_CODSOL > 0 .AND. nPos_LJSOLI > 0 .AND. nPos_NOMSOL > 0
		  		For nCount := 1 To len(aColsSOL)
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
					If SA1->(dbSeek( xFilial("SA1")+aColsSOL[nCount ,nPos_CODSOL]+aColsSOL[nCount ,nPos_LJSOLI]))
						aColsSOL[nCount ,nPos_NOMSOL] := SA1->A1_NOME
					EndIf
				Next nCount
			EndIf
		EndIf
			
		DEFINE MSDIALOG oDlgR TITLE OemToAnsi(STR0001) FROM 9,0 TO 25,85 //"Cadastro de Solidarios"
				
		oGetSol := MsNewGetDados():New(002,02,097,338 ,0 ,{|| .T. },"AllwaysTrue",,,,9999,,,,oDlgR,aHeadSOL,aColsSOL)
		oGetSol:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		
		ACTIVATE MSDIALOG oDlgR ON INIT EnchoiceBar(oDlgR,{||oDlgR:End()},{||oDlgR:End()})
	Else
		Help(" ",1,"ERRCONTR",,STR0017 + cContrato + STR0018,1) //"O contrato "###" n�o existe."
	EndIf

	RestArea( aArea )

Return( .T. )


Template Function GEMA100LIZLoad( aDefField )
Local nPos     := 0
Local nX       := 0
Local cString  := ""
Local cPode    := ""
Local cObgt    := ""
Local lObrigat := .F.
Local aItens   := {}
Local aCampos  := {}
Local aArea    := GetArea()
			
// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

dbSelectArea("SX3")
SX3->(dbSetOrder(2)) // X3_FILIAL+X3_CAMPO
For nX := 1 To len(aDefField)
	If SX3->(dbSeek(aDefField[nX]))
		If X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
			cPode := X3Reserv(SX3->x3_reserv)
			cObgt := Bin2Str(SX3->x3_Obrigat)
			lObrigat := Iif(Substr(cPode,7,1)=="x" .or. Substr(cObgt,1,1)== "x",.T.,.F.)

			aAdd( aCampos ,{ SX3->X3_CAMPO ,X3Titulo() ,SX3->X3_PICTURE ,SX3->X3_TAMANHO ,SX3->X3_VISUAL ,SX3->X3_F3 ,X3_VALID ,{} ,lObrigat })
			
			If !Empty(SX3->X3_CBOX)
				cString := alltrim(SX3->X3_CBOX)+";"
				aItens := {}
				While len(cString) > 0
					nPos := At( ";",cString)
					aAdd( aItens ,alltrim(SubStr( cString ,1 ,nPos-1)))
					cString := alltrim(SubStr(cString,nPos+1))
				EndDo
				aCampos[len(aCampos)][8]:= aClone( aItens )
			EndIf
		EndIf
	EndIf
Next nX

RestArea( aArea )

Return( aCampos )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GEMLIZVLD � Autor � Reynaldo Miyashita    � Data � 02.12.2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o campo LIZ_NCONTR e carrega as parcelas referentes.   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �GEMLIZVLD(cContrato)                                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Numero do contrato                                     ���
���          �ExpC2: Numero da revisao do contrato                          ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GEMLIZVLD(cContrato ,cTipo)
Local lRetorno := .T.
Local aArea    := GetArea()
Local lNaoAltera := Iif(Type("lNaoAltera")=="U", .T., lNaoAltera)

DEFAULT cContrato := M->LIZ_NCONTR
DEFAULT cTipo     := M->LIZ_TIPREG

dbSelectArea("LIT")
LIT->(dbSetOrder(2)) //LIT_FILIAL+LIT_NCONTR
If (Len(aTitulos)<=1 .OR. cContrato<>LIT->LIT_NCONTR) .AND. LIT->(dbSeek( xFilial("LIT")+cContrato ))
// Len(aTitulos)>1 maneira de saber se � a primeira vez que est� escolhendo um contrato, para recalcular as parcelas
	If T_GMContrStatus(cContrato)
		Do Case
			// Vencimento
			Case cTipo == "2" 	.and. !lNaoAltera
				t_GEMA101PRC(cContrato)
			// Quitacao
			Case cTipo == "4" .and. !lNaoAltera
				t_GEMA102PRC(cContrato)
		EndCase
	Else
		lRetorno := .F.
	EndIf
EndIf

RestArea(aArea)

Return( lRetorno )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �05/12/06 ���
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
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Private aRotina := {{ OemToAnsi(STR0001) ,"AxPesqui"     ,0,1,,.F.},;  //'Pesquisar'
                    { OemToAnsi(STR0002) ,"T_GMA100View" ,0,2},; //"Visualizar"
                    { OemToAnsi(STR0020) ,"T_GEMA102"    ,0,3},;  //"Renegocia��o"
                    { OemToAnsi(STR0021) ,"T_GEMA102"    ,0,5},;  //"EXCLUSAO"
                    { OemToAnsi(STR0019) ,"T_GEMA101"    ,0,3}}  //"Vencimento"
                    
Return(aRotina)
