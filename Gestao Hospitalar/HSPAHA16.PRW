#INCLUDE "HSPAHA16.ch"
#include "protheus.CH"
#include "TopConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA16  � Autor � Cibele Peria       � Data �  08/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Tipo de Alta                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ�� 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA16()
 Private cCadastro := STR0001 //"Tipo de Alta"
 Private aRotina   := MenuDef()

 DbSelectArea("GF4")
 mBrowse(06, 01, 22, 75, "GF4")

Return()            	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A16    � Autor � Cibele Peria       � Data �  08/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Procedimento                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_A16(cAlias, nReg, nOpc)
 Local nGDOpc := IIf(aRotina[nOpc, 4] == 3 .or. aRotina[nOpc, 4] == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local nOpcG  := aRotina[nOpc, 4]
 Local nOpcA  := 0 
 Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {} 
                
 Private aTela := {}, aGets := {}
 Private oGF4
 
 RegToMemory("GF4", nOpcG==3)
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 nOpcA := 0 
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
  oGF4 := MsMGet():New("GF4", nReg, nOpc	,,,,, aPObjs[1],, 2)
  oGF4:oBox:Align := CONTROL_ALIGN_ALLCLIENT
  
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela) .And. IIF(nOpcG==5, HS_A16DOK(nOpcG), .T.), oDlg:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()} )

 If nOpcA == 1
  FS_GrvA16(nOpcG)
 Endif

Return()
        
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A16DOK � Autor � Cibele Peria       � Data �  08/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Verifica, no caso de exclusao, se o procedimento pode ser  ���
���          � excluido.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_A16DOK(nOpcG)
 Local cAliasOld := Alias()
 Local lRet      := .T.
 
 /*If (nOpcG <> 5 .or. nOpcG <> 4)      //Exclusao
  Return(lRet)
 Endif */

 DbSelectArea("GCY")
 DbSetOrder(11)
 If DbSeek(xFilial("GCY") + GF4->GF4_TPALTA)
  lRet := .F.
  HS_MsgInf(STR0007, STR0008, STR0009) //"Tipo de alta em uso em atendimento. Exclusao nao permitida!"###"Atencao"####"Valida��o de Exclus�o"
 Endif
 
 DbSelectArea(cAliasOld)
 
Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA16 � Autor � Cibele Peria       � Data �  08/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Atualizacao do cadastro                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvA16(nOpcG)
Local lAchou      := .T.
Local lEspelhar := GetNewPar("MV_INTSAIP",.F.)
local lNovBIY   := .T.
Local aArea := GetArea()

If nOpcG == 2     // Se for uma consulta
	Return(.T.)
Endif

DbselectArea("GF4")
DbsetOrder(1)
lAchou := DbSeek(xFilial("GF4")+M->GF4_TPALTA)
Begin Transaction



//������������������������������������������������������Ŀ
//� Espelhamento GF4 X BIY...                            �
//��������������������������������������������������������
If nOpcG == 3   //Inclusao
	//������������������������������������������������������Ŀ
	//� Verifica se o  Tipo de Alta ja existe Tabela PLS     �
	//��������������������������������������������������������
	
	If lEspelhar
		
		If  ! Empty(M->GF4_TPALTA)
			DbSelectArea("BIY")
			BIY->(DbSetOrder(3))
			lNovBIY := (BIY->(MsSeek(xFilial("BIY")+M->GF4_TPALTA)))
		Endif
	Else
		lNovBIY := .T.
	Endif
	
	//������������������������������������������������������Ŀ
	//� Verifica se deve criar Tipo de Alta no plano de Saude�
	//��������������������������������������������������������
	If  ! LNovBIY
		DbSelectArea("BBL")
		BBL->(DbSetOrder(2))
		If 	BBL->(MsSeek(xFilial("BBL")+"HSPAHA16  "+"GF4"+"BIY"))
			BIY->(RecLock("BIY",(nOpcG == 3)))
			BIY->BIY_FILIAL := xFilial("BIY")
			IF GF4->(FieldPos("GF4_CODINT"))>0 
				BIY->BIY_CODOPE := M->GF4_CODINT
			Endif			
			PlsSinc("HSPAHA16","GF4","BIY")
			BIY->(MsUnLock())
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0012)) //"Arquivo de sincronismo entre BIY x GF4 nao esta integro. Verifique!"
			Endif
		Endif
		
	Endif
	
	RecLock("GF4", (nOpcG == 3))
	HS_GrvCpo("GF4")
	GF4->GF4_FILIAL:=xFilial("GF4")
	GF4->GF4_LOGARQ := HS_LOGARQ()
	MsUnlock()
	
	
ElseIf nOpcG == 4
	If lEspelhar
		DbSelectArea("BIY")
		BIY->(DbSetOrder(3))
		If BIY->(MsSeek(xFilial("BIY")+M->GF4_TPALTA))
			DbSelectArea("BBL")
			BBL->(DbSetOrder(2))
			If BBL->(MsSeek(xFilial("BBL")+"HSPAHA16  "+"GF4"+"BIY"))
				BIY->(RecLock("BIY",.F.))
				BIY->BIY_FILIAL := xFilial("BIY")
							
				IF GF4->(FieldPos("GF4_CODINT"))>0 
					If !Empty(M->GF4_CODINT)
						BIY->BIY_CODOPE := M->GF4_CODINT
					Endif
				Endif			

				PlsSinc("HSPAHA16","GF4","BIY")
				BIY->(MsUnLock())
			Else
				If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi(STR0012)) //"Arquivo de sincronismo entre BIY x GF4 nao esta integro. Verifique!"
				Endif
			Endif
		Endif
	Endif
	
	RecLock("GF4", .F.)
	HS_GrvCpo("GF4")
	GF4->GF4_FILIAL:=xFilial("GF4")
	GF4->GF4_LOGARQ := HS_LOGARQ()
	MsUnlock()
	
ElseIf nOpcG == 5
	
	If HS_VldExc(M->GF4_TPALTA)
		If lEspelhar
			DbSelectArea("BIY")
			BIY->(DbSetOrder(3))
			If BIY->(MsSeek(xFilial("BIY")+M->GF4_TPALTA))
				DbSelectArea("BBL")
				BBL->(DbSetOrder(2))
				If BBL->(MsSeek(xFilial("BBL")+"HSPAHA16  "+"GF4"+"BIY"))
					RecLock("BIY", .F.)
					DbDelete()
					MsUnlock()
				Else
					If GetNewPar("MV_PLSMSGS","1") == "1"
						MsgAlert(OemtoAnsi(STR0012)) //"Arquivo de sincronismo entre BIY x GF4 nao esta integro. Verifique!"
					Endif
				Endif
			Endif
		Endif
		
		
		
		RecLock("GF4", .F., .T.)
		DbDelete()
		MsUnLock()
	EndIf
	
Endif

RestArea(aArea)

End Transaction
Return(.T.)


Function HS_VldA16()
 Local lRet := .T.
 
 If ReadVar() == "M->GF4_TSTISS" .AND. !EMPTY(M->GF4_TSTISS)
  If !(lRet := HS_SeekRet("G16", "M->GF4_TSTISS", 1, .F., "GF4_DTSTIS", "G16_DESCRI"))
   HS_MsgInf(STR0010, STR0008, STR0011) //"Tipo de Saida n�o cadastrada."###"Aten��o"###"Valida��o dos Campos"
  EndIf
ElseIf ReadVar() == "M->GF4_TPASUS" .AND. !EMPTY(M->GF4_TPASUS)
If !(lRet := HS_SeekRet("G19", "M->GF4_TPASUS", 1, .F., "GF4_DTASUS", "G19_DESCRI"))
 		HS_MsgInf(STR0010, STR0008, STR0011) //"Tipo de Saida n�o cadastrada."###"Aten��o"###"Valida��o dos Campos"
  	EndIf
 EndIf

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 11/07/07 ���
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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui", 0, 1, 0, nil},; //"Pesquisar"
                     {OemToAnsi(STR0003), 'HS_A16'  , 0, 2, 0, nil},; //"Visualizar"
                     {OemToAnsi(STR0004), 'HS_A16'  , 0, 3, 0, nil},; //"Incluir"
                     {OemToAnsi(STR0005), 'HS_A16'  , 0, 4, 0, nil},; //"Alterar"
                     {OemToAnsi(STR0006), 'HS_A16'  , 0, 5, 0, nil}}  //"Excluir" 

                       

	
    	aadd(aRotina, {"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GF4',GF4->GF4_TPALTA, 1)})", 0 ,})
		aadd(aRotina, {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GF4',GF4->GF4_TPALTA, 0)})", 0 ,})                  

                  
                     
                     
Return(aRotina)
