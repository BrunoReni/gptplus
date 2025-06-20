#INCLUDE "HSPAHABJ.ch"
#include "protheus.CH"  
#INCLUDE "TopConn.CH"
#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABJ  � Autor � DANIEL PEIXOTO     � Data �  28/06/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Salas de Atendimento                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��  
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function HSPAHABJ(lClinicas)
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Default lClinicas := .F.

Private cCadastro := STR0001 //"Cadastro de Sala de Atendimento"
private  nGncStaReg  := 0
Private  nGNC_CODSAL := 0
Private  nGNC_CODPRO := 0 
Private  nGNC_DESPRO := 0 
Private aRotina := MenuDef()
private  nGO2StaReg  := 0
Private  nGO2_CODREC := 0 
Private  nGO2_DESREC := 0
Private lOnlyCli :=  lClinicas

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "GF3"

If !HS_ExisDic({{"T", "GO2","Bops 148152"}})
 Return(nil)                                               
EndIf

dbSelectArea("GF3")
dbSetOrder(1)
 
dbSelectArea(cString)

mBrowse( 6,1,22,75,cString)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvABJ �Autor  �Paulo C�sar         � Data �  22/11/07   ���
�������������������������������������������������������������������������͹��
���Descri��o �Funcao de Gravacao ou Exclusao dos Dados    															 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Gest�o Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FS_GrvABJ(aHGNC, nUGNC)

 // Grava dados da Enchoice

 If Inclui .Or. Altera 
 	If Inclui .and. !HS_VIABJ()            
   		Return(.F.)
	EndIf	
 	
  RecLock("GF3", Inclui)
   HS_GrvCpo("GF3")
   GF3->GF3_FILIAL := xFilial("GF3")
  MsUnLock()
 
 // Exclui dados da Enchoice
 Else
		
 	DbSelectArea("GF3")
 	DBSetOrder(1)
 	RecLock("GF3", .F., .T.)
 	DbDelete()
 	MsUnlock()
 	WriteSx2("GF3")

 EndIf
 
 Fs_GrvRel("GNC",oGNC, nGNC_CODPRO)
 Fs_GrvRel("GO2",oGO2, nGO2_CODREC)
  
Return(.T.)
  
Static Function Fs_GrvRel(cAliasRel,oGdObj, nPosChv)
 Local aArea  := GetArea()
 Local nI    := 0 
 Local lFound := .F.  
  
 For nI := 1 to Len(oGdObj:aCols)  
  If oGdObj:aCols[nI, 1]  == "BR_VERDE" .and. !(oGdObj:aCols[nI, len(oGdObj:aHeader) + 1])
    Loop
  EndIf 
  DbSelectArea(cAliasRel)
  DBSetOrder(1)
  
  lFound := DbSeek(xFilial(cAliasRel) + M->GF3_CODIGO + oGdObj:aCols[nI, nPosChv])
    
  If Inclui .Or. Altera .And. !(oGdObj:aCols[nI, len(oGdObj:aHeader) + 1]) 
	  RecLock(cAliasRel, !lFound)
	   HS_GrvCpo(cAliasRel, oGdObj:aCols, oGdObj:aHeader, nI)
	   &(cAliasRel+"->"+cAliasRel+"_FILIAL") := xFilial(cAliasRel)
	   &(cAliasRel+"->"+cAliasRel+"_CODSAL") := M->GF3_CODIGO
	    MsUnlock()	
  ElseIf lFound 
	  RecLock(cAliasRel, .F.)
     DbDelete()
    MsUnlock()
   WriteSx2(cAliasRel)            
   EndIf   
                                                               
next nI

 RestArea(aArea)
Return()


/************************************* validacao de inclusao ****************************************************/
/*Function HS_ABJ(cAlias, nReg, nOpc)
 Local nOpcA := 0    
 If nOpc == 3
  nOpcA := axInclui("GF3",, 3,,,, "HS_VIABJ()") 
 ElseIf nOpc == 5 .AND. HS_VEABJ()
  nOpcA := axDeleta("GF3", nReg, nOpc)
 EndIf                            
Return(nOpcA)*/

Function HS_ABJ(cAlias, nReg, nOpc)

	Local nOpA 	  := 0
	Local cCpoEnc := ""
	Local nGDOpc  := IIf( Inclui .Or. Altera, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
	Local nLenGD  := 0
 	Local lRetRec:= .T.

    
	Private aTela := {}, aGets := {}
	Private aHGNC := {}, aCGNC := {}, nUGNC := 0
	Private aHGO2 := {}, aCGO2 := {}, nUGO2 := 0
	
	Private oDlg, oGNC, oGO2, oEnchoi

	RegToMemory("GF3", (nOpc == 3))    

 cCpoEnc := "GNC_CODSAL" //Define os campos que nao deverao ser editados na Getdados

	nLenGD := HS_BDados("GNC", @aHGNC    ,   @aCGNC,    @nUGNC, 1," ", IIf((nOpc == 3), Nil, "'" + M->GF3_CODIGO + "' == GNC->GNC_CODSAL"),.T.,,,,cCpoEnc,.T.)

 nGncStaReg  := aScan(aHGNC, {| aVet | AllTrim(aVet[2]) == "HSP_STAREG"})   
 nGNC_CODSAL := aScan(aHGNC, {| aVet | AllTrim(aVet[2]) == "GNC_CODSAL"})
 nGNC_CODPRO := aScan(aHGNC, {| aVet | AllTrim(aVet[2]) == "GNC_CODPRO"})
 nGNC_DESPRO := aScan(aHGNC, {| aVet | AllTrim(aVet[2]) == "GNC_DESPRO"})

	HS_BDados("GO2", @aHGO2, @aCGO2, @nUGO2, 1,, IIf((nOpc == 3), Nil," GO2->GO2_CODSAL = '"+M->GF3_CODIGO+"'"),.T.,,,,,.T.)

 nGO2StaReg  := aScan(aHGO2, {| aVet | AllTrim(aVet[2]) == "HSP_STAREG"})   
 nGO2_CODREC := aScan(aHGO2, {| aVet | AllTrim(aVet[2]) == "GO2_CODREC"})
 nGO2_DESREC := aScan(aHGO2, {| aVet | AllTrim(aVet[2]) == "GO2_DESREC"})

 aSize 			:= MsAdvSize(.T.)
 aObjects := {}
 
 AAdd( aObjects, { 100, 030, .T., .T. } )
 AAdd( aObjects, { 100, 070, .T., .T. } )
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
  
  oEnchoi := MsMGet():New("GF3",nReg,nOpc, , , , ,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, , , , , ,oDlg)
  oEnchoi :oBox:align:= CONTROL_ALIGN_TOP


  @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel Of oDlg Prompts "Procedimentos","Recursos"
  oFolder:align := CONTROL_ALIGN_ALLCLIENT

  oGNC := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,,,, 99999,,,, oFolder:aDialogs[1], aHGNC, aCGNC)
  oGNC:oBrowse:align      := CONTROL_ALIGN_ALLCLIENT
  oGNC:cFieldOk           := "HS_GDAtrib(oGNC, {{nGncStaReg, 'BR_AMARELO', 'BR_VERDE'}})"
  oGNC:oBrowse:bDelete    := {|| HS_GDAtrib(oGNC, {{nGncStaReg, 'BR_AMARELO', 'BR_VERDE'}}), oGNC:DelLine(),oGNC:oBrowse:Refresh()}                     
  
  oGO2 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,"HS_DuplAC(oGO2:oBrowse:nAt, oGO2:aCols, {nGO2_CODREC},, .T.)",,,,, 99999,,,, oFolder:aDialogs[2], aHGO2, aCGO2)
  oGO2:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
  oGO2:cFieldOk           := "HS_GDAtrib(oGO2, {{nGO2StaReg, 'BR_AMARELO', 'BR_VERDE'}})"
  oGO2:oBrowse:bDelete    := {|| Iif(FS_VLRec(oGO2:oBrowse:nAt),(HS_GDAtrib(oGO2, {{nGO2StaReg, 'BR_AMARELO', 'BR_VERDE'}}), oGO2:DelLine(),oGO2:oBrowse:Refresh()),oGO2:oBrowse:Refresh())}
  oGO2:oBrowse:bDelOk     := {|| Iif(!FS_ValDel(oGO2:oBrowse),(HS_GDAtrib(oGO2, {{nGO2StaReg, 'BR_AMARELO', 'BR_VERDE'}}), oGO2:DelLine(),oGO2:oBrowse:Refresh()),"")}

If lOnlyCli
	oFolder:aDialogs[2]:lActive := .F.
EndIf	

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {	|| nOpA := 1,;
IIF(Obrigatorio(aGets, aTela) .And. oGNC:TudoOk() .And. IIf(!lOnlyCli,oGO2:TudoOk(),.T.), oDlg:End(), nOpA := 0)},;
{|| nOpA := 0, oDlg:End()})
                                                             
If (nOpA == 1) .And. (nOpc <> 2) 

 Begin Transaction
  FS_GrvABJ(aHGNC, nUGNC)
 End Transaction
EndIf

Return(Nil)	

Function HS_GNCAtrib(oGetDados, aPosAtrib)
 Local nPosAtrib := 1, lGDAtrib := .F.
 Local nForAtrib := 0, cCndAt := ""
 
 Private oGDATrib := oGetDados
                          
 For nPosAtrib := 1 To Len(aPosAtrib)
  If Len(aPosAtrib[nPosAtrib]) < 3 .Or. ;
   oGetDados:aCols[oGetDados:nAt, aPosAtrib[nPosAtrib, 1]] == IIf(oGetDados:aCols[oGetDados:nAt, Len(oGetDados:aHeader) + 1], aPosAtrib[nPosAtrib, 2], aPosAtrib[nPosAtrib, 3])
   oGetDados:aCols[oGetDados:nAt, aPosAtrib[nPosAtrib, 1]] := IIf(!oGetDados:aCols[oGetDados:nAt, Len(oGetDados:aHeader) + 1], aPosAtrib[nPosAtrib, 2], aPosAtrib[nPosAtrib, 3])
  EndIf
 Next

 If Type("cCondAtrib") <> "U" .And. !Empty(cCondAtrib)
   
  For nForAtrib := 1 To Len(oGetDados:aCols)
   cCndAt := cCondAtrib
   cCndAt := StrTran(cCndAt, "oGetDados", "oGDATrib")
   cCndAt := StrTran(cCndAt, "__nAtGD", AllTrim(Str(nForAtrib)))
   If oGetDados:nAt <> nForAtrib .And. &(cCndAt)
    For nPosAtrib := 1 To Len(aPosAtrib)
     If oGetDados:aCols[nForAtrib, aPosAtrib[nPosAtrib, 1]] == "BR_VERDE"
      oGetDados:aCols[nForAtrib, aPosAtrib[nPosAtrib, 1]] := "BR_AMARELO"
     EndIf
    Next
   EndIf
  Next
  
 EndIf

Return(.T.)


/*************************************  validacao de inclusao  ****************************************************/
Function HS_VIABJ()
 Local lRet := .T. 

 If DBSeek(xFilial("GF3") + M->GF3_CODIGO)
  HS_MsgInf(STR0007, STR0008, STR0010) //"Codigo ja existente..."###"Atencao"###"Valida��o de Inclus�o"
  lRet := .F.
 EndIf   
 
Return( lRet )  

/*************************************  validacao de exclusao  ****************************************************/
Function HS_VEABJ()
 Local lRet := .T.
 Local cAliasOld:= Alias() 
 
 M->GF3_CODIGO := GF3->GF3_CODIGO
 
 DbSelectArea("GM6")
 DbSetOrder(4)
 If DBSeek( xFilial("GM6") + GF3->GF3_CODIGO )
   HS_MsgInf(STR0009, STR0008, STR0010) //"Este Codigo esta sendo usado pela Disponibilidade Ambulatorial(GM6).Impossivel Exclui-lo!"###"Atencao"###"Valida��o de Exclus�o"
   lRet := .F.
 EndIf
 
 DbSelectArea(cAliasOld)
   
Return( lRet )  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |FS_VLRec  �Autor  �Sueli Santos        � Data �  23/02/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � valida se o dia da semana e o procedimento estao           ���
���          � preenchidos                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_VLRec(nPos)

Local lRet1 := .T.
Default nPos := 0
 
If nPos > 0 .And. nPos<= Len(oGO2:aCols) 
	If Len(oGO2:aCols)>1 
		If FS_VldExcR(oGO2:aCols[nPos, nGO2_CODREC])
			 lRet1 := .F. 
		EndIf
	EndIf
EndIf
 
If !lRet1 
	If Len(oGO2:aCols)>1 
	 	HS_MsgInf(STR0011, STR0008, STR0010) //"Codigo ja existente..."###"Atencao"###"Valida��o de Inclus�o"
	Else
		HS_MsgInf(STR0012, STR0008, STR0010)
	EndIf 	
EndIf

Return(lRet1)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VldExcR� Autor � Sueli Santos       � Data �  28/08/09   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina que Verifica se o Recurso esta em                   ���
���          � uso na Agenda Ambulatorial (GM8)                           ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_VldExcR(cCodRec)

 Local lRetGo3    := .F.
 Local cSqlGo3    := ""
 Local aArea      := GetArea()
 Default cCodRec  := ""
 
  cSqlGo3 := "SELECT GO3.GO3_CODDIS, GO3.GO3_CODSAL, GO3.GO3_CODREC "
  cSqlGo3 += "FROM " + RetSqlName("GO3") + " GO3 "
  cSqlGo3 += "WHERE GO3.D_E_L_E_T_ <> '*' AND GO3.GO3_FILIAL = '" + xFilial("GO3") + "' "
  cSqlGo3 += "AND GO3.GO3_CODSAL = '" + M->GF3_CODIGO + "' "
  cSqlGo3 += "AND GO3.GO3_CODREC = '" + cCodRec + "' "
  cSqlGo3 := ChangeQuery(cSqlGo3)    
   
  TCQuery cSqlGo3 New Alias "TMPGO3"
   
  DbSelectArea("TMPGO3")
  If !Eof()  
    lRetGo3 := .T. 
  EndIf

 DbCloseArea()  
 RestArea(aArea) 
 
Return(lRetGo3)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_ValDel � Autor � Sueli Santos       � Data �  18/09/09   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina verifica se existe algum recurso ativo na sala      ���
���          � se possuir nao e cancelada a exclusao                      ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
 Static Function FS_ValDel ()
 Local nI := 0
 Local nCont  := 0
 Local lRet2 := .T.
 
 For nI := 1 To Len(oGO2:aCols)
 	If oGo2:aCols[nI, Len(oGo2:aCols[nI])]  
 		nCont += 1
 	EndIf	
 Next nI 
 
 If nCont >=  Len(oGO2:aCols)
 	lRet2 := .F.    
 	HS_MsgInf(STR0012, STR0008, STR0010)
 EndIf
 
 Return(lRet2)



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
Local aRotina := {{STR0002, "AxPesqui", 0, 1, 0, nil} ,; //"Pesquisar"
                 {STR0003, "HS_ABJ"  , 0, 2, 0, nil} ,; //"Visualizar"
                 {STR0004, "HS_ABJ"  , 0, 3, 0, nil} ,; //"Incluir"
                 {STR0005, "HS_ABJ"  , 0, 4, 0, nil} ,; //"Alterar"
                 {STR0006, "HS_ABJ"  , 0, 5, 0, nil} } //"Excluir"

Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Rogerio Tabosa        � Data � 16/06/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do cadastro de Salas para Clinicas                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_ABJCLI()
	HSPAHABJ(.T.)	
Return
