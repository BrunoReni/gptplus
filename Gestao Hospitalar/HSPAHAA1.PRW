#INCLUDE "HSPAHAA1.ch"
#include "protheus.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � HSPAHAA1 � Autor � Cibele             � Data �  02/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO ATO MEDICO                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHAA1() 

Private cCadastro := STR0001 //"Cadastro de Ato M�dico"
Private aRotina :=  {{STR0008   ,"AxPesqui" ,0,1},; //"Pesquisar"
                     {STR0009   ,"AxVisual" ,0,2},; //"Visualizar"
                     {STR0010   ,"HS_AA1"   ,0,3},; //"Incluir"
                     {STR0011   ,"HS_AA1"   ,0,4},; //"Alterar"
                     {STR0012   ,"HS_AA1"   ,0,5}} //"Excluir"
Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cAlias := "GMC"



	
    	aadd(aRotina, {"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GMC',GMC->GMC_CODATO, 1)})", 0 ,})
		aadd(aRotina, {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GMC',GMC->GMC_CODATO, 0)})", 0 ,})                  




DbSelectArea(cAlias)
DbSetOrder(1)
          			
mBrowse(06, 01, 22, 75, cAlias)

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � HS_AA1   � Autor �Antonio Carlos         � Data � 01/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Selecionar Opcao de Inclusao/Alteracao/Exclusao            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_AA1(cAlias,nReg,nOpc)
 Local nOpcA := 0
 Private cDelFunc := "HS_ExcAA1()",cAIH := ""
 If nOpc == 3	
  nOpcA := axInclui(cAlias,, 3,,,,"HS_AIAA1()") 
 ElseIf nOpc == 4
  nOpcA := axAltera(cAlias, nReg, nOpc,,,,,"HS_AIAA1()")
 ElseIf nOpc == 5
  nOpcA := axDeleta(cALIAS, nReg, nOpc)
 EndIf
Return(nOpcA)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � HS_AIAA1 � Autor �Antonio Carlos         � Data � 01/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da Inclusao/Alteracao                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_AIAA1()             
 Local lRet := .T., cAIH := M->GMC_CDAAIH
  If !Empty(cAIH) .AND. GMC->GMC_CDAAIH <> cAIH
  DbSetOrder(3)
  If DbSeek(xFilial("GMC") + cAIH) 
   HS_MsgInf(STR0005+cAIH, STR0003, STR0001)  //"Este atendimento j� foi cadastrado para outro ato m�dico! "//###"Atencao!"###"Cadastro de Ato M�dico"
   lRet := .F.
  EndIf 
  DbSetOrder(1)
 EndIf
Return(lRet) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � HS_ExcAA1� Autor �Cibele Peria           � Data � 02/04/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da Exclusao de uma Funcao                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_ExcAA1()
 Local lRet := .T., cAliasOld := Alias()

 DbSelectArea("GMF")
 DbSetOrder(2)						// GME_FILIAL + GME_CODATO + GME_CODCRM
 If DbSeek(xFilial("GMF") + GMC->GMC_CODATO) 
  HS_MsgInf(STR0002,STR0003,STR0001) //"Ato cadastrado em relacionamento de medicos com equipe. Exclusao nao permitida"###"Atencao!"###"Cadastro de Ato"
  lRet := .F.
 Endif                                                                                                         
 
 If lRet
  DbSelectArea("GD7")
  DbSetOrder(11)	//GD7/11
  If DbSeek(xFilial("GD7") + GMC->GMC_CODATO) 
   HS_MsgInf(STR0006,STR0003,STR0001) //"Ato cadastrado em relacionamento de medicos com atendimentos. Exclusao nao permitida"###"Atencao!"###"Cadastro de Ato"
   lRet := .F.
  Endif                                                                                                         
 EndIf 
 
 If lRet
  DbSelectArea("GAY")
  DbSetOrder(5)	//GAY/5
  If DbSeek(xFilial("GAY") + GMC->GMC_CODATO) 
   HS_MsgInf(STR0007,STR0003,STR0001) //"Ato cadastrado em credenciamento. Exclusao nao permitida"###"Atencao!"###"Cadastro de Ato"
   lRet := .F.
  Endif                                                                                                         
 EndIf 
 
 DbSelectArea(cAliasOld)
Return(lRet)
                                                         
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � HS_VldAA1� Autor �Cibele Peria           � Data � 06/12/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de validacao dos campos                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_VldAA1()
 Local lRet := .T., cAliasOld := Alias()
 
 If ReadVar() == "M->GME_CODCRM"
  If !HS_SeekRet("SRA","ALLTRIM(M->GM6_CODCRM)",11,.f.,"GM6_NOMCRM","RA_NOME",,,.T.) 
   HS_MsgInf(STR0004,STR0003,STR0001) //"CRM do medico invalido"###"Atencao"###"Cadastro de Ato"
   lRet := .F.
  EndIf
     
 ElseIf ReadVar() == "M->GMC_PPTISS" .AND. !EMPTY(M->GMC_PPTISS)
  If !(lRet := HS_SeekRet("G18", "M->GMC_PPTISS", 1, .F., "GMC_DPPTIS", "G18_DESCRI"))
   HS_MsgInf(STR0013, STR0014, STR0015) //"Posi��o Profissional n�o cadastrada."###"Aten��o"###"Valida��o dos Campos"
  EndIf
 EndIf 
     
 DbSelectArea(cAliasOld)
Return(lRet)
                                         
