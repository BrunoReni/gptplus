#INCLUDE "HSPAHABA.ch"
#INCLUDE "protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABA  � Autor � Alessandro Freire  � Data �  27/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de sitios da ANVISA                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHABA()

Private cCadastro := STR0001 //"Cadastro de Sitios - ANVISA"

Private aRotina := MenuDef()

Private cDelFunc := ".T."

dbSelectArea("GEK")
dbSetOrder(1)

dbSelectArea("GEK")
mBrowse( 6,1,22,75,"GEK")

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_ABASITI�Autor  �Alessandro Freire   � Data �  27/04/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de sitios                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_ABASITI(cAlias,nReg,nOpc)

Local aSize
Local aObjects
Local aInfo
Local aPObjs
Local oDlg
Local oEnGEK
Local nI

Local aHGEL          := {}
Local aCGEL          := {}
Local nUGEL          := 0
Local nOpcDlg        := 0

Local nGDOpc         := IIf(nOpc == 3 .or. nOpc == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)

Private aTela        := {}, aGets := {}
Private nGEL_CODIGO  := 0

RegToMemory( "GEK", nOpc == 3 )

// carrega aheder, acols e nUsado da getdados
HS_BDados("GEL", @aHGEL, @aCGEL, @nUGEL, 2,, IIf(nOpc # 3, "'" + M->GEK_CODIGO + "' == GEL->GEL_CODGEK", Nil))

// Posicao de GEL_CODIGO na getdados
nGEL_CODIGO  := aScan(aHGEL, {| x | x[2] == "GEL_CODIGO"})

// Monta o posicionamento da tela
aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T. } )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )


DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel

oEnGEK               := MsMGet():New("GEK", nReg, nOpc,,,,, aPObjs[1],, 2)
oEnGEK:oBox:align    := CONTROL_ALIGN_TOP

oGDGEL               := MsNewGetDados():New(aPObjs[2, 1]+05, ;
                                            aPObjs[2, 2]   , ;
                                            aPObjs[2, 3]+10, ;
                                            aPObjs[2, 4]   , ;
                                            nGdOpc,"HS_ABALOK",,,,, 99999,,,,, aHGEL, aCGEL)
oGDGEL:oBrowse:bdelete:= {|| IIF (nOpc == 3 .OR. nOpc == 4,IIF(FS_DELGEL(nOpc),oGDGEL:DelLine(),.F.),0)} 
oGDGEL:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcDlg := 1, IIf(Obrigatorio(aGets, aTela) .And.       ;
                                                                       IIF(nOpc == 5, FS_ABAEXC(),.T.),oDlg:End(),; 
                                                                       nOpcDlg := 0) },;
	                                                 {|| nOpcDlg := 0, oDlg:End()} )
                                                 
If nOpc < 3 .or. nOpcDlg == 0
	Return(nil)
EndIf

If nOpc == 3 .or. nOpc == 4 // Inclusao ou alteracao
 
 If aRotina[nOpc, 4] == 3 // Inclusao
  M->GEK_CODIGO := HS_VSxeNum("GEK", "M->GEK_CODIGO", 1)
 Endif 

	RecLock("GEK", (nOpc == 3) )
	HS_GRVCPO("GEK")
	GEK->GEK_FILIAL := xFilial("GEK")
	MsUnlock()
	
	dbSelectArea("GEL")
	dbSetOrder(2)
	
	For nI := 1 to Len(oGDGEL:aCols)
	
	 lDeleta := oGDGEL:aCols[nI][Len(oGDGEL:aCols[nI])]
	 lAchou  := dbSeek(xFilial("GEL")+M->GEK_CODIGO+oGDGEL:aCols[nI,nGEL_CODIGO] ) 
	  
	 // grava registro novo ou altera registro
	 If ! lDeleta .And. !EMPTY(oGDGEL:aCols[nI,nGEL_CODIGO])
		 RecLock("GEL", !lAchou)
			HS_GRVCPO("GEL", oGDGEL:aCols, oGDGEL:aHeader, nI)
			GEL->GEL_FILIAL := xFilial("GEL")
			GEL->GEL_CODGEK := GEK->GEK_CODIGO
		 MsUnlock()
		EndIf
				
		// apaga registro
		If lDeleta .and. lAchou
			RecLock("GEL",.F.)
			dbDelete()
			MsUnlock()
		EndIf
		
	Next nI

Else

 // Apaga registros
 dbSelectArea("GEL")
 dbSetOrder(2)
 
 While dbSeek(xFilial("GEL") + GEK->GEK_CODIGO)
 	RecLock("GEL",.F.)
 	dbDelete()
 	MsUnlock()
 Enddo
 
 dbSelectArea("GEK")
 RecLock("GEK",.F.)
 dbDelete()
 MsUnlock()
	
EndIf

dbSelectArea("GEK")

Return(nil)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_ABAEXC �Autor  �MARIO ARIZONO       � Data �  15/12/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao criada para validacao do botao excluir              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ABAEXC()

 Local lRet := .T.
 Local cAliasOld := Alias()

 dbSelectArea("GEH")
 dbSetOrder(3)  
 If dbSeek(xFilial("GEH") + GEK->GEK_CODIGO)   //GEH_FILIAL+GEH_SITPRI
	 HS_MsgInf(STR0007, STR0008, STR0009) //"Item nao pode ser excluido pois encontra-se na notificacao"###"Atencao"####"Valida��o de exclus�o"
	 lRet := .F.
	Endif
	DbSelectArea(cAliasOld)     
	
Return(lRet)  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_DELGEL �Autor  �MARIO ARIZONO       � Data �  15/12/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao criada para validacao da delecao na getdados da     ���
���          � tabela GEL                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_DELGEL(nOpc)

 Local lret    := .T.  
  
 DBSelectArea("GEH")
 DbSetOrder(3)
 If DbSeek(xFilial("GEH")+ M->GEK_CODIGO + oGDGEL:aCols[oGDGEL:nAt,nGEL_CODIGO])
  HS_MsgInf(STR0007, STR0008, STR0009) //"Item nao pode ser excluido pois encontra-se na notificacao"###"Atencao"####"Valida��o de exclus�o"
  lret := .F.
 Endif  
Return(lRet)            

Function HS_ABALOK()
 Local lRet := .T.
 
 lRet := HS_DuplAC(oGDGEL:oBrowse:nAt, oGDGEL:aCols, {nGEL_CODIGO})

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 06/06/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Gera arquivo TXT para exportacao                      �
//�    4 - Recebe arquivo TXT                                    �
//����������������������������������������������������������������
Local aRotina :=	{{STR0002	,"AxPesqui"  ,0,1, 0, nil},; //"Pesquisar"
					 {STR0003	,"HS_ABASITI",0,2, 0, nil},; //"Visualizar"
					 {STR0004   ,"HS_ABASITI",0,3, 0, nil},; //"Incluir"
					 {STR0005   ,"HS_ABASITI",0,4, 0, nil},; //"Alterar"
					 {STR0006   ,"HS_ABASITI",0,5, 0, nil}}  //"Excluir"
Return(aRotina)