#INCLUDE "CTBA070.CH"
#INCLUDE "PROTHEUS.CH"

// 17/08/2009 -- Filial com mais de 2 caracteres


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBA070  � Autor � Pilar S. Albaladejo   � Data � 05/11/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento de Historicos                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA070()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum.                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA070()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBA070(nPosArotina,lAutomato)

Local aIndexCt8 := {}
Local cFilter   := Nil

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0006)  // "Cadastro Hist�ricos Padr�o"
PRIVATE bFiltraBrw
PRIVATE lCTB070FPE := ExistBlock("CTB070FPE") // Ponto de entrada para manipula��o de filtro

DEFAULT lAutomato   := .F.

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

cFilter   := "CT8_FILIAL = '"+xFilial("CT8")+"'"+" AND CT8_SEQUEN = '000001'"

If lCTB070FPE
	cFilter := ExecBlock("CTB070FPE",.F. ,.F.,{cFilter})
EndIf

If !lAutomato
	mBrowse( 6, 1,22,75,"CT8",,,,,,,,,,,,,,cFilter)
Else
	bBlock := &( "{ |a,b,c,d| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d) }" )
	Eval( bBlock, "CT8", (Alias())->(Recno()),nPosArotina,lAutomato)
EndIF	

DbSetOrder(1)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CTB070MAN � Autor � Pilar S. Albaladejo   � Data � 05/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Acessa tela de cadastro de historico                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTB070MAN(cAlias,nReg,nOpc)                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTB070MAN(cAlias,nReg,nOpc,lAutomato)
           
Local aVetor :={}
Local aButtons	:= {{"POSCLI",;
						{||CT070Enche(nOpc,@aVetor) .And.;
						hGetWizard(OemtoAnsi(STR0007),@aVetor,Iif(nOpc==2,.T.,.F.),37)},;
						STR0007,STR0008}} //"Historico Inteligente" "His.Intelig"
Local bCampo := {|nCPO| Field(nCPO) }
Local bOk    	:= {||nOpca:=1,IIf(Ct070TOK(nOpc,aVetor),oDlg:End(),nOpca := 0),.F.}
Local bCancel	:= {||nOpca:=2,oDlg:End()}
Local cCampo
Local oDlg  
Local nCont 
Local nOpca		:= 0
Local oSize
Local aPos := {}
Local aArea		:= GetArea()

Default lAutomato := .F.

DbClearFil()

Private aTELA[0][0],aGETS[0]

If nOpc == 3
	FOR nCont := 1 TO FCount()
		DbSelectArea("CT8")
		cCampo := EVAL(bCampo,nCont)
		M->&(cCampo) := FieldGet(nCont)
		If ValType(M->&(cCampo)) = "C"
			M->&(cCampo) := SPACE(LEN(M->&(cCampo)))
		ElseIf ValType(M->&(cCampo)) = "N"
			M->&(cCampo) := 0
		ElseIf ValType(M->&(cCampo)) = "D"
			M->&(cCampo) := CtoD("  /  /  ")
		ElseIf ValType(M->&(cCampo)) = "L"
			M->&(cCampo) := .F.
		EndIf
	Next nCont
Else
	FOR nCont := 1 TO FCount()
		M->&(EVAL(bCampo,nCont)) := FieldGet(nCont)
	NEXT 	nCont
EndIF

If !lAutomato

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd    
	
	//��������������������������������������������������������������Ŀ
	//� Calcula dimens�es                                            �
	//����������������������������������������������������������������
	oSize := FwDefSize():New(.T.,,,oDlg)
	oSize:AddObject( "CABECALHO",  100, 100, .T., .T. ) // Totalmente dimensionavel
	
	oSize:lProp 	:= .T. // Proporcional             
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
	
	oSize:Process() 	   // Dispara os calculos   
	
	aPos := { oSize:GetDimension("CABECALHO","LININI"), oSize:GetDimension("CABECALHO","COLINI") ,;
					oSize:GetDimension("CABECALHO","LINEND"), oSize:GetDimension("CABECALHO","COLEND") }
							
	EnChoice(cAlias,nReg,nOpc, /*aCRA*/,/*cLetras*/,/*cTexto*/,/*aAcho*/, aPos)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED
Else
	If FindFunction("GetParAuto")
		aRetAuto	:= GetParAuto("CTBA070TestCase")
		
		If !Empty(aRetAuto)
				If EnchAuto( cAlias, aRetAuto[1], , nOpc)				
					If Len(aRetAuto) > 1
						aVetor := aRetAuto[2][2]
					EndIf 
					nOpca := 1
				EndIf 
		Else
			aVetor := {}
		EndIf												
	EndIf
EndIf

If nOpca == 1
	BEGIN TRANSACTION
		Ct070Grava(nOpc,aVetor)
	END TRANSACTION
EndIf	

RetIndex("CT8")
CTB070Fil()

//Tratado inclusao para nao perder o focu do recno incluido
If nOpc != 3 ; RestArea(aArea) ; EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ct070Grava� Autor � Pilar S. Albaladejo   � Data � 05/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava dados                                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ct070grava()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Numero da opcao selecionada                        ���                                                   ���
���          � ExpA1 = Array com conteudo do historico inteligente        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ct070Grava(nOpc,aVetor)
           
Local aSaveArea 	:= GetArea()
Local nCont
Local nCont1
Local cDescHP		:= ""                                                    

dbSelectArea("CT8")
dbSetOrder(1)

If nOpc  == 5
	dbSelectArea("CT8")
	dbSetOrder(1)
	If dbSeek(xFilial()+m->CT8_HIST)
		While !Eof() .And. xFilial() == CT8->CT8_FILIAL .And. CT8->CT8_HIST == m->CT8_HIST
			RecLock("CT8",.F.,.T.)
			dbDelete()
			dbSkip()
		EndDo	
	EndIf
EndIf

If nOpc == 3                       
	cDescHp := MsHGetText(aVetor)
	If !Empty(aVetor)               
		RecLock("CT8",.T.)
		Replace CT8_FILIAL 	With xFilial()
		Replace CT8_HIST	With m->CT8_HIST
		Replace CT8_SEQUEN	With "000001"
		Replace CT8_IDENT	With "I"
//		Replace CT8_DESC	With "<" + OemToAnsi(STR0007) + ">"
		Replace CT8_DESC With Subs(cDescHp,1,37)
		GrvCT8Usu()
		MsUnlock()
		For nCont := 1 To Len(aVetor)
			RecLock("CT8",.t.)
			Replace CT8_FILIAL	With xFilial()
			Replace CT8_HIST	With m->CT8_HIST
			Replace CT8_SEQUEN	With StrZero(nCont+1,6)
			Replace CT8_IDENT	With "I"
			Replace CT8_DESC	With aVetor[nCont]
			GrvCT8Usu()
			MsUnlock()
		Next nCont
	Else
		RecLock("CT8",.t.)
		Replace CT8_FILIAL	With xFilial()
		Replace CT8_HIST	With m->CT8_HIST
		Replace CT8_SEQUEN	With "000001"
		Replace CT8_DESC	With m->CT8_DESC
		Replace CT8_IDENT	With "C"     
		GrvCT8Usu()
		MsUnlock()
	EndIf
EndIF	

If nOpc == 4                    
	dbSetOrder(1)
	dbSeek(xFilial()+m->CT8_HIST)
	
	If Empty(aVetor) 
		Ct070Enche(4,@aVetor)
	EndIf
	
	nTam := Len(aVetor)
		
	nCont := 1

	While !Eof() .And. CT8->CT8_FILIAL == xFilial() .And. CT8->CT8_HIST == m->CT8_HIST

		If nTam > 0
			If (nCont-1) > nTam			// Foram deletadas linhas do historico
				RecLock("CT8",.F.,.T.)
				dbDelete()            
				MsUnlock()
				nCont++
				dbSkip()
				Loop
			EndIf   
		EndIf	
		RecLock("CT8")
		If nCont == 1
			cDescHp := MsHGetText(aVetor)		
			Replace CT8_SEQUEN	With	"000001"
			If nTam > 0
//				Replace CT8_DESC		With "<" + OemToAnsi(STR0007) + ">"			
				Replace CT8_DESC 		With Subs(cDescHp,1,37)
				Replace CT8_IDENT		With "I"
			Else
				Replace CT8_DESC		With m->CT8_DESC
				Replace CT8_IDENT		With "C"
			EndIf	
		Else
			Replace CT8_SEQUEN	With StrZero(nCont,6)
			Replace CT8_DESC		With aVetor[nCont-1]				
			Replace CT8_IDENT		With "I"
		EndIf
		GrvCT8Usu()
		MSUnlock()
		nCont++
		dbSkip()
	EndDo	

	If nTam > (nCont-2)
		For nCont1 := nCont-1 To nTam
			RecLock("CT8",.t.)
			Replace CT8_FILIAL	With xFilial()
			Replace CT8_HIST		With m->CT8_HIST
			Replace CT8_SEQUEN	With StrZero(nCont1+1,6)
			Replace CT8_IDENT		With "I"
			Replace CT8_DESC		With aVetor[nCont1]
			GrvCT8Usu()
			MsUnlock()
		Next nCont
	EndIf
EndIf	
     
//Tratado inclusao para nao perder o focu do recno incluido
If nOpc != 3 ; RestArea(aSaveArea) ; EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CT070TOK  � Autor � Pilar S. Albaladejo   � Data � 05/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida botao -> tudo OK!                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CT070TOK()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T./.F.                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Numero da opcao selecionada                        ���                                                   ���
���          � ExpA1 = Array com conteudo do historico inteligente        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Ct070TOK(nOpc,aVetor)

Local lRet := .T.

If Empty(aVetor) .And. Empty(m->CT8_DESC)
	Help(" ",1,"CT8HIST")
	lRet := .F.
EndIf	

If Empty(m->CT8_HIST)
	Help(" ",1,"CT8COD")
	lRet := .F.
EndIf	


Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CT070ENCHE� Autor � Pilar S. Albaladejo   � Data � 05/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Enche vetor + campo -> na alteracao e inclusao             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA070()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Numero da opcao selecionada                        ���                                                   ���
���          � ExpA1 = Array com conteudo do historico inteligente        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ct070Enche(nOpc,aVetor)

Local cHist 	:= CT8->CT8_HIST
Local aSaveAREA:= GetArea()

If nOpc == 3
	m->CT8_DESC := "<" + OemToAnsi(STR0007) + ">"
Else
	aVetor := {}
	dbSelectArea("CT8")
	dbSetOrder(1)
	While !Eof() .And. CT8->CT8_FILIAL == xFilial() .And. CT8->CT8_HIST == cHist
		If CT8->CT8_SEQUEN <> "000001"
			Aadd(aVetor,CT8->CT8_DESC)
		EndIf	
		dbSkip()
	EndDo
	If !Empty(aVetor)	
		m->CT8_DESC := "<" + OemToAnsi(STR0007) + ">"
	EndIf
EndIf

lRefresh := .T.

RestArea(aSaveArea)
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTB070Fil� Autor � Wagner Mobile Costa   � Data � 28/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta filtro da rotina de historico inteligente            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTB070Fil()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTB070Fil()

LOCAL	aIndexCT8	:= {}
LOCAL   cFiltraCT8  := ""

cFiltraCT8 := 'CT8_FILIAL=="'+xFilial("CT8")+'"'+'.And.CT8_SEQUEN=="000001"'

If lCTB070FPE
	cFiltraCT8 := ExecBlock("CTB070FPE",.F. ,.F.,{cFiltraCT8})
EndIf

bFiltraBrw := {|| FilBrowse("CT8",@aIndexCT8,cFiltraCT8) }
Eval(bFiltraBrw)

Return aIndexCt8


/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    � GrvCT8Usu � Autor � Eduardo Nunes Cirqueira � Data � 03/03/06 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Grava campos de usuario na tabela CT8                         ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � GrvCT8Usu()                                                   ���
����������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                        ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � Cadastro de Historico                                         ���
����������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                        ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function GrvCT8Usu()
          
Local nCont

// Gravando os campos de Usuario
For nCont := 1 to M->( FCount() )
	// Se nao for um dos campos padrao
	If ! ( M->(Field(nCont)) $ "CT8_FILIAL/CT8_HIST/CT8_SEQUEN/CT8_IDENT/CT8_DESC" )
		CT8->( FieldPut( nCont,M->&(Field(nCont)) ) )
	EndIf
Next

Return .T.

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Paulo Carnelossi      � Data �09/03/07  ���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
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

Local aRotina := { 	{ OemToAnsi(STR0001), "PESQBRW"		, 0 , 1,,.F.},;  //"Pesquisar"
					{ OemToAnsi(STR0002), "CTB070MAN"	, 0 , 2},;  //"Visualizar"
					{ OemToAnsi(STR0003), "CTB070MAN"	, 0 , 3},;  //"Incluir"
					{ OemToAnsi(STR0004), "CTB070MAN"	, 0 , 4},;  //"Alterar"
					{ OemToAnsi(STR0005), "CTB070MAN"	, 0 , 5} }  //"Excluir"

Return(aRotina)
