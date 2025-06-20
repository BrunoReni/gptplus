/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIIA120 � Autor � Emilton               � Data � 12/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Importacao da Tabela de Defeitos para Garantia             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Integracao montadora                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#include "ofiia120.ch"
#include "Protheus.ch"
Function OFIIA120

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004)   //Importacao da Tabela de Defeitos
Private cCodMar  && Variavel criada para nao ter conflito com a segunda pergunte
Private lMsErroAuto := .f.

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

If !Pergunte("OFIMAR",.t.)
   Return
EndIf

cCodMar := MV_PAR01
                          
DbSelectArea("VII")
DbSetOrder( 1 )
cIndVII := CriaTrab(Nil, .F.)
IndRegua("VII",cIndVII,IndexKey(),,"VII_CODMAR == cCodMar",OemToAnsi(STR0004) )
                    
mBrowse( 6, 1,22,75,"VII")

DbSelectArea("VII")
RetIndex()

#IFNDEF TOP
   If File(cIndVII+OrdBagExt())
      fErase(cIndVII+OrdBagExt())
   Endif
#ENDIF

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �IA120I    � Autor � Emilton               � Data � 20/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama a funcao de gravacao de integracao de pedido da mon  ���
���          � tadora                                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �IA120I(CLIAS,NREG,NOPC)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PECAS                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function IA120I(cAlias,nReg,nOpc)

If xFilial("VII") != VII->VII_FILIAL .or. (VII->(EOF()) .and. VII->(BOF()))
   Help(" ",1,"ARQVAZIO")
   Return .f.
Endif                        

// Help(" ",1,"VFIMPMOD")

dbSelectArea("VII")
dbSeek( xFilial("VII") + cCodMar )

dbSelectArea("VE4")
dbSetOrder(1)
dbSeek( xFilial("VE4") + cCodMar )

Processa( {|| FS_INTVII()} )

return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_INTVII � Autor � Emilton               � Data � 20/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao dos dados do arquivo Fornecedores p/Garantia      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Integracao montadora                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_INTVII()

Local ixi    := 0
Local _CDERR := Space(03)
Local _MENSA := Space(30)

Local nRegTrans := 0

DbSelectArea("VII")                                                                           
dbSeek( xFilial("VII"))

Begin Transaction

   While xFilial("VII") == VII->VII_FILIAL .and. VII->VII_CODMAR == cCodMar .and. !Eof()

      For ixi := 1 to 3

         _CDERR := "VII->VII_CDERR"+Str(ixi,1)
         _MENSA := "VII->VII_MENSA"+Str(ixi,1)

         If Empty(&_CDERR)
            Loop
         EndIf

         dbSelectArea("VGD")
         dbSetOrder(1)
         dbSeek( xFilial("VGD")+cCodMar+&_CDERR)

         RecLock("VGD", !Found() )
         VGD_FILIAL := xFilial("VGD")
         VGD_CODMAR := cCodMar
         VGD_CODERR := &_CDERR
         VGD_DESERR := &_MENSA

      Next

      DbSelectArea("VII")
      DbSkip()

   EndDo

End Transaction

FS_DELIA120()

If lMsErroAuto
   MostraErro()
EndIf   

return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �IA120V    � Autor � Emilton               � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualiza os dados dos arquivos VID                        ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � AxVisual(cAlias,nReg,nOpc,aCampos)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function IA120V(cAlias,nReg,nOpc)

Private aCampos := {}

CPOIA120()
AxVisual(cAlias,nReg,nOpc,aCampos)

return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CPOIA120  � Autor � Emilton               � Data � 01/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Pega os campos no SX3 para serem mostrados na visualizacao  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � CPOIA120()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � integracao                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CPOIA120()

DbSelectArea("SX3")
dbgotop()
dbseek("VII")
aCampos := {}

While !eof() .and. x3_arquivo == "VII"

   If X3USO(x3_usado) .And. cNivel>=x3_nivel
      aadd(aCampos,x3_campo)
   EndIf
   
   dbSkip()
   
EndDo

DbSelectArea("VII")

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_DELIA120 Autor � Emilton               � Data � 01/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Apaga os dados do arquivo VID                              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FS_DELIA120()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � integracao                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_DELIA120()

dbselectarea("VII")
dbgotop()
IF Ma280Flock("VII")
   DbClearInd()
   OpenIndx("VII",.F.)
   delete all for VII->VII_CODMAR == cCodMar
   pack
//   reindex
   DbCloseArea()
Endif

ChkFile("VII",.F.)

return

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;//Pesquisar
                     { STR0002 ,"IA120V", 0 , 2},;//Visualizar
                     { STR0003 ,"IA120I", 0 , 3}} //Importar
Return aRotina
