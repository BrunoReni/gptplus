#include "Ofipa990.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIPA990 � Autor �  Renata               � Data � 01/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Grupos de Desconto das pecas                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Pecas                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIPA990
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0001) //Grupos de Desconto de Itens
Private cGruFor   := "04"
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
axCadastro("VE5", cCadastro,"OFIPA990EX()")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OFIPA990EX� Autor � Valdir F. SIlva       � Data � 17/10/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se pode ser feito a exclusao                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIPA990EX()
Local aArquivos:={}

aadd(aArquivos,{"VE4","VE4_PREFAB+VE4_GRUDES" ,VE5->VE5_CODMAR+VE5->VE5_GRUDST,})
aadd(aArquivos,{"SB1","B1_GRUPO+B1_GRUDES" ,VE5->VE5_CODMAR+VE5->VE5_GRUDST,})
Return(FG_DELETA(aArquivos))
                                  
Function FS_VALFORVDA()
Local OFP8600016 := ExistFunc("OFP8600016_VerificacaoFormula")
If Vazio()
   Return .t.
Else
   FG_STRZERO("M->VE5_FORVDA",6)
   If OFP8600016 .And. !OFP8600016_VerificacaoFormula(M->VE5_FORVDA)
      Return .f. // A mensagem j� � exibida dentro da fun��o
   EndIf
   If !FG_Seek("VEG","M->VE5_FORVDA",1,.f.,"VE5_DESVDA","VEG_DESCRI")
      Return .f.
   EndIf
   If VEG->VEG_GRUFOR != "04"     
      Return .f.
   EndIf
EndIf     
return .t.
                                  
Function FS_VALFORGAR()
Local OFP8600016 := ExistFunc("OFP8600016_VerificacaoFormula")
If Vazio()
   Return .t.
Else
   FG_STRZERO("M->VE5_FORGAR",6)
   If OFP8600016 .And. !OFP8600016_VerificacaoFormula(M->VE5_FORGAR)
      Return .f. // A mensagem j� � exibida dentro da fun��o
   EndIf
   If !FG_Seek("VEG","M->VE5_FORGAR",1,.f.,"VE5_DESGAR","VEG_DESCRI")
      Return .f.
   EndIf
   If Type("cGruFor") != "U"
   	If VEG->VEG_GRUFOR != cGruFor
      	Return .f.
   	EndIf
   EndIf
EndIf     
return .t.

                                  
Function FS_VALFORPRP()
Local OFP8600016 := ExistFunc("OFP8600016_VerificacaoFormula")
If Vazio()
   Return .t.
Else
   FG_STRZERO("M->VE5_FORPRP",6)
   If OFP8600016 .And. !OFP8600016_VerificacaoFormula(M->VE5_FORPRP)
      Return .f. // A mensagem j� � exibida dentro da fun��o
   EndIf
   If !FG_Seek("VEG","M->VE5_FORPRP",1,.f.,"VE5_DESPRP","VEG_DESCRI")
      Return .f.
   EndIf
   If Type("cGruFor") != "U" 
   	If VEG->VEG_GRUFOR != cGruFor
     		Return .f.
   	EndIf
   EndIf
EndIf     
return .t.

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)