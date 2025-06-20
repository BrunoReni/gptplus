#include  "HSPAHA27.CH"
#include "protheus.CH"
#include "colors.CH"                                                                           

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA27  � Autor � Cibele Ap. L. Peria� Data �  29/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Item de Prescricao Medica                      ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HSPAHA27()
 Local aCores      := {{"GGI->GGI_TPITMP == '1'", "BR_VERDE"  }}
 Local bKeyF12     := SetKey(VK_F12, {|| FS_FilA27("HSPA27", .T.) } )
                        
 Private aRotInclui := {{OemToAnsi(STR0009), 'HS_A27Med("GGC", 0, 3)', 0, 03}, ; //"Medicamento"
                        {OemtoAnsi(STR0010) , "HS_A27Far()"           , 0, 03}, ; //"F�rmaco"
                        {OemtoAnsi(STR0011) , "HS_A27Kit()"           , 0, 03}, ; //"Kit"
                        {OemtoAnsi(STR0012) , "HS_A27Exc()"           , 0, 03}}   //"Exce��o"
                                                                                                   
 Private aRotina   := {{OemToAnsi(STR0001)  , "axPesqui"     , 0, 01}, ; //"Pesquisar"
                        {OemToAnsi(STR0002) , "HS_A27Menu"  , 0, 02}, ; //"Visualizar"
                        {OemToAnsi(STR0003) ,  aRotInclui   , 0, 03}, ; //"Incluir"
                        {OemToAnsi(STR0004) , "HS_A27Menu"  , 0, 04}, ; //"Alterar"
                        {OemToAnsi(STR0013) , "HS_A27Menu"  , 0, 05}, ; //"Excluir"
                        {OemToAnsi(STR0014) , "HS_A27Menu"  , 0, 04}, ; //"Copiar"
                        {OemtoAnsi(STR0015) , "HS_LegA27"   , 0, 02}}  //"Legenda"
                     
 Private cCadastro := OemToAnsi(STR0016) //"Item de Prescri��o M�dica"
 Private cFilA27   := ""
 
 If HS_LocTab("GGI")
  DbSelectArea("GGI")
  DbSetOrder(1)
                   
  If FS_FilA27("HSPA27", .F.)
   mBrowse(06, 01, 22, 75, "GGI",,,,,, aCores,,,,,,,, cFilA27)
  EndIf 

  SetKey(VK_F12, bKeyF12)            
 EndIf 
 
Return(Nil)

/*�������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������Ŀ��
���Fun��o    �HS_A27Menu� Autor � Cibele Peria          � Data �29/09/06���
�����������������������������������������������������������������������Ĵ��
���Descri��o � Rotina principal                                         ���
������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������
�������������������������������������������������������������������������*/
Function HS_A27Menu(cAlias, nRegGGI, nOpc)
 Local aArea := GetArea()
 Local nReg  := 0
 
 If GGI->GGI_TPITMP == "1"    //Medicamento
  DbSelectArea("GGC")
  DbSetOrder(1)
  DbSeek(xFilial("GGC") + GGI->GGI_CDITMP)
  nReg := GGC->(RecNo())
  HS_A27Med("GGC", nReg, nOpc)

 ElseIf GGI->GGI_TPITMP == "2"    //Farmaco
//  HS_A27Far("GG?", nReg, nOpc)

 ElseIf GGI->GGI_TPITMP == "3"    //Kit
//  HS_A27Kit("GG?", nReg, nOpc)

 ElseIf GGI->GGI_TPITMP == "4"    //Excecao
//  HS_A27Exc("GG?", nReg, nOpc)
 Endif              
 
 RestArea(aArea)
Return(Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A27Med � Autor � L.Gustavo Caloi    � Data �  03/10/2006 ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de item de MEDICAMENTO                              ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HS_A27Med(cAlias, nReg, nOpc)
 Local nOpcA   := 0

 Private aTela 		:= {}
 Private aGets      := {}
 Private aHeader    := {}
 Private aCols      := {}
 Private nUsado     := 0
 Private oGGC
 Private lGDVazio   := .F.
 
 Private cG1RTipo   := "1"
 Private cGGACdMedi := ""
 Private cGGBCdMedi := "1"
 
 DbSelectArea("GGC")
                        
 RegToMemory("GGC",(aRotina[nOpc,4] == 3)) //Gera variavies de memoria para o GGC

 If nOpc == 6 // Copiar
  INCLUI := .T.
  M->GGC_CDITMP := CriaVar("GGC_CDITMP")
 EndIf
 
 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0017) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Medicamentos"

 oGGC := MsMGet():New("GGC", nReg, nOpc,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGGC:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 oGGC:AENTRYCTRLS[aScan(oGGC:aGets, {| aVet | "GGC_CDITAP"		$ aVet})]:BGOTFOCUS := {|| cGGACdMedi	:= M->GGC_CDMEDI} 
 oGGC:AENTRYCTRLS[aScan(oGGC:aGets, {| aVet | "GGC_CDITPO"		$ aVet})]:BGOTFOCUS := {|| cGGBCdMedi	:= M->GGC_CDMEDI} 

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. FS_VLDDEL(nOpc, M->GGC_CDITMP), oDlg:End(), nOpcA == 0)}, ;
																																																		 {|| nOpcA := 0, oDlg:End()})
 
 If nOpcA == 1  
  If aRotina[nOpc,4] <> 2
   Begin Transaction
    FS_GrvMed(nOpc)
   End Transaction
  
 		While __lSx8
  		ConfirmSx8()
 	 End
 	EndIf  
		
  If nOpc == 6 // Copiar
   MBrChgLoop(.F.)
  EndIf
 Else
		While __lSx8
  	RollBackSxe()
  EndDo
 EndIf

Return(Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvMed �Autor  �L.Gustavo Caloi     � Data �  11/09/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function FS_GrvMed(nOpc)

 DbSelectArea("GGC")
 
 If aRotina[nOpc,4] == 3 .Or. aRotina[nOpc,4] == 4 //Inclusao ou Alterar
  RecLock("GGI", INCLUI)
   If INCLUI
    GGI->GGI_FILIAL := xFilial("GGI")
    GGI->GGI_CDITMP := M->GGC_CDITMP
    GGI->GGI_TPITMP := "1"
   EndIf 
   HS_GrvCpo("GGI")  
   If HS_EXISDIC({{"C", "GGI_CDMEDI"}})
    GGI->GGI_CDMEDI := M->GGC_CDMEDI
   Endif
   GGI->GGI_APRESE := HS_IniPadR("GGA", 1, M->GGC_CDMEDI + M->GGC_CDITAP,  "GGA_APRESE",, .F.)  
   If HS_EXISDIC({{"C", "GGI_CDITPO"}})
    GGI->GGI_CDITPO := M->GGC_CDITPO    
   Endif
   If HS_EXISDIC({{"C", "GGI_APRESD"}})
    GGI->GGI_APRESD := HS_IniPadR("GGD", 3, GGA->GGA_CDDILU + GGA->GGA_CDITED,  "GGD_APRESE",, .F.) 
   Endif
  MsUnlock()
  
  RecLock("GGC", INCLUI)
   If INCLUI
    GGC->GGC_FILIAL := xFilial("GGC")
   EndIf 
   HS_GrvCpo("GGC") 
  MsUnlock()  
  
 ElseIf aRotina[nOpc,4] == 5 //Exclusao
  RecLock("GGC", .F.)
   DbDelete()
  MsUnlock()
  
  DbSelectArea("GGI")
  RecLock("GGI", .F.)
   DbDelete()
  MsUnlock()
  
 Endif
 
Return()

/*�������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������Ŀ��
���Fun��o    �HS_A27Far � Autor � Cibele Peria          � Data �29/09/06���
�����������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de item de FARMACO                                ���
������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������
�������������������������������������������������������������������������*/
Function HS_A27Far() //cAliasGG?, nReg, nOpc)
 Local aArea := GetArea()
 RestArea(aArea) 
Return()

/*�������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������Ŀ��
���Fun��o    �HS_A27Med � Autor � Cibele Peria          � Data �29/09/06���
�����������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de item de KIT                                    ���
������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������
�������������������������������������������������������������������������*/
Function HS_A27Kit() //cAliasGG?, nReg, nOpc)
 Local aArea := GetArea()
 RestArea(aArea)
Return()

/*�������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������Ŀ��
���Fun��o    �HS_A27Med � Autor � Cibele Peria          � Data �29/09/06���
�����������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de item de Excecao                                ���
������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������
�������������������������������������������������������������������������*/
Function HS_A27Exc(cAliasGGC, nReg, nOpc)
 Local aArea := GetArea()
 RestArea(aArea) 
Return()

/*�������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������Ŀ��
���Fun��o    � FS_FilA27� Autor � Cibele Peria          � Data �29/09/06���
�����������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Filtro da tabela principal (GGI)               ���
������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������
�������������������������������������������������������������������������*/
Static Function FS_FilA27(cPerg, lSetFilter)
 Local lRet        := .F.
 Local oObjMBrw    := GetObjBrow()

 If (lRet := Pergunte(cPerg))

   cFilA27 := "GGI_FILIAL = '" + xFilial("GGI") + "'"
  If MV_PAR01 <> 5 //Todos
   cFilA27 += " AND GGI_TPITMP = '" + Str(MV_PAR01, Len(GGI->GGI_TPITMP)) + "'"
  Endif 
  
  If lSetFilter
   SetMBTopFilter("GGI", cFilA27)
   oObjMBrw:GoTop()
   oObjMBrw:Refresh()
  EndIf
 
 EndIf
 DbSelectArea("GGI")
    
Return(lRet)       

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldA27 �Autor  �Luiz Gustavo Caloi  � Data �  10/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��es dos campos da tabela GGC                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function HS_VldA27()
 Local lRet      := .T.
 Local aAreaOld  := GetArea()  
 Local nNroReg   := 0, nCOnt := 0
 local aTabRel   := {{"GGA", "GGA->GGA", "GGC_CDITAP", STR0018}, {"GGB", "GGB->GGB", "GGC_CDITPO", STR0019}} //"Apresenta��o"###"Posologia"
 
  If ReadVar() == "M->GGC_CDMEDI" //Valida�cao do campo _CDITEM (Item do Medicamento)
   If HS_SeekRet("SB1", "M->GGC_CDMEDI", 1, .F.,"GGC_DSITEM", "B1_DESC",,.F.)
    DbSelectArea("GBI")
    DbSetOrder(1)
    DbSeek(xFilial("GBI") + M->GGC_CDMEDI)
    If GBI->GBI_TIPO <> "1"
     HS_MsgInf(STR0020, STR0007, STR0021) //"O Item selecionado n�o � um Medicamento"###"Aten��o"###"Valida��o do Medicamento"
     lRet := .F.
    EndIf
   Else
    HS_MsgInf(STR0022, STR0007, STR0021) //"O c�digo do Item n�o existe no Cadastro de Produto"###"Aten��o"###"Valida��o do Medicamento"
    lRet := .F.
   EndIf
   
   If lRet
    //Valida se existe relacionamentos GGA e GGB
    For nCont := 1 To Len(aTabRel)
     If (nNroReg := HS_CountTB(aTabRel[nCont, 1],	aTabRel[nCont, 1] + "_CDMEDI = '" + M->GGC_CDMEDI + "' ")) == 0
      HS_MsgInf(STR0023 + aTabRel[nCont, 4] + STR0024 + aTabRel[nCont, 1] + ")", STR0007, STR0021) //"O medicamento n�o possui nenhuma "###" cadastrada("###"Aten��o"###"Valida��o do Medicamento"
      Return(.F.)
     EndIf 
    Next
    //Preenche automatico
    For nCont := 1 To Len(aTabRel)
     DbSelectArea(aTabRel[nCont, 1])
     DbSetOrder(2) //CDMEDI + CDITEM + IDPADR
     If nNroReg > 1
      DbSeek(xFilial(aTabRel[nCont, 1]) + M->GGC_CDMEDI + "1")
     Else
      DbSeek(xFilial(aTabRel[nCont, 1]) + M->GGC_CDMEDI)
     Endif
     &("M->" + aTabRel[nCont, 3]) := &(aTabRel[nCont, 2] + "_CDITEM")
     If aTabRel[nCont, 1] == "GGA"      
      M->GGC_APRESA := HS_IniPadR("GGA", 1, M->GGC_CDMEDI + M->GGC_CDITAP, "GGA_APRESE",, .F.)
      If HS_EXISDIC({{"C", "GGC_APRESD"}})
       M->GGC_APRESD := HS_IniPadR("GGD", 3, GGA->GGA_CDDILU + GGA->GGA_CDITED, "GGD_APRESE",, .F.)
      Endif
     Else                                                                                           
      M->GGC_CDFRQA := HS_IniPadR("GGB", 1, M->GGC_CDMEDI + M->GGC_CDITPO, "GGB_CDFRQA",, .F.)
      M->GGC_DSFRQA := HS_IniPadR("GFZ", 1, M->GGC_CDFRQA, "GFZ_DSFRQA",, .F.)
     EndIf
    Next 
   EndIf   
    
  ElseIf ReadVar() == "M->GGC_CDITAP" //Valida��o do campo item da Apresentacao
   If !(lRet := HS_SeekRet("GGA", "M->GGC_CDMEDI + M->GGC_CDITAP", 1, .F., "GGC_APRESA", "GGA_APRESE",,.F.))
    Hs_MsgInf(STR0025, STR0007, STR0026)  //"O item selecionado, n�o possui relacionamento(GGA) com o medicamento informado"###"Aten��o"###"Valida��o de Apresenta��o"
   Else
    If HS_EXISDIC({{"C", "GGC_APRESD"}})
     HS_SeekRet("GGD", "GGA->GGA_CDDILU + GGA->GGA_CDITED", 3, .F., "GGC_APRESD", "GGD_APRESE",,.F.)
    Endif
    nNroReg := HS_CountTB("GGB",	"GGB_CDMEDI = '" + M->GGC_CDMEDI + "' ") 
    If nNroReg > 0
     If nNroReg == 1
      HS_SeekRet("GGB", "M->GGC_CDMEDI", 1, .F., {"GGC_CDITPO", "GGC_CDFRQA"}, {"GGB_CDITEM", "GGB_CDFRQA"},,.F.)
      HS_SeekRet("GFZ", "M->GGC_CDFRQA", 1, .F., "GGC_DSFRQA", "GFZ_DSFRQA",,.F.)
     Else
      HS_SeekRet("GGB", "M->GGC_CDMEDI + '1'", 2, .F., {"GGC_CDITPO", "GGC_CDFRQA"}, {"GGB_CDITEM", "GGB_CDFRQA"},,.F.)
      HS_SeekRet("GFZ", "M->GGC_CDFRQA", 1, .F., "GGC_DSFRQA", "GFZ_DSFRQA",,.F.)
     Endif
    Endif
   EndIf
   
  ElseIf ReadVar() == "M->GGC_CDITPO" //Valida��o do campo item da posologia
   If !(lRet := HS_SeekRet("GGB", "M->GGC_CDMEDI + M->GGC_CDITPO", 1, .F., "GGC_CDFRQA", "GGB_CDFRQA",,.F.))
    Hs_MsgInf(STR0027, STR0007, STR0028)  //"O item selecionado, n�o possui relacionamento(GGB) com o medicamento informado"###"Aten��o"###"Valida��o de posologia"
   Else
    HS_SeekRet("GFZ", "M->GGC_CDFRQA", 1, .F., "GGC_DSFRQA", "GFZ_DSFRQA",,.F.)
   EndIf

  EndIf
 
 RestArea(aAreaOld) 
Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_LegA27 �Autor  �Daniel Peixoto      � Data �  04/01/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Legenda                                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_LegA27()

  BrwLegenda(cCadastro, STR0015, {{"BR_VERDE"   , STR0009}})  //"Legenda"###"Medicamento"

Return(Nil) 
                 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VLDDEL �Autor  �Mario Arizono       � Data �  30/05/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao delecao dos itens.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_VLDDEL(nOpc, cCdItmp)
 Local lRet := .T.
 
 If nOpc == 5
  If HS_ExisDic({{"T", "GHU"}})  
   If HS_CountTB("GHU", "GHU_CDITMP = '" + cCdItmp + "'") > 0
    HS_MsgInf(STR0030, STR0007, STR0029) //"Registro n�o pode ser excluido, pois, possui relacionamento com a prescri��o padr�o."##"Valida��o Exclus�o"
    lRet := .F.	
   EndIf        
  Endif
  If lRet
   If HS_ExisDic({{"T", "GHX"}})  
    If HS_CountTB("GHX", "GHX_CDITMP = '" + cCdItmp + "'") > 0
     HS_MsgInf(STR0031, STR0007, STR0029) //"Registro n�o pode ser excluido, pois, possui relacionamento com a prescri��o m�dica."##"Valida��o Exclus�o"
     lRet := .F.	
    EndIf        
   Endif
  Endif
 Endif

Return(lRet)
