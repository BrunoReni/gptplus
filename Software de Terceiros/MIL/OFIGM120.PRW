#INCLUDE "Ofigm120.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIGM120 � Autor �  Renata               � Data � 21/02/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorno garantia manual VW                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIGM120

Local cChave, cCond

Private aCampos := {} , nIndex := 0

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004)   //"Retorno da garanita manual" //"Retorno Fabrica Manual"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

dbSelectArea("VGA")
dbSetOrder(1)             

cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := "VGA_TRANSM=='S' .And. VGA_SITUAC $ '  000104'" 

IndRegua("VGA",cIndex,cChave,,cCond,STR0005)  //"Aguarde, filtrando registros..."

if VG1->VG1_INFNNF == "0"
   PERGUNTE("OGM120")
Endif              

DbSelectArea("VGA")
nIndex := RetIndex("VGA")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

mBrowse( 6, 1,22,75,"VGA",,,,"VGA_TRANSM=='S' .And. VGA_SITUAC $ '  000104'")  

dbSelectArea("VGA")
RetIndex()
DbsetOrder(1)
#IFNDEF TOP
   If File(cIndex+OrdBagExt())
      fErase(cIndex+OrdBagExt())
   Endif
#ENDIF

return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GM120V    � Autor �Renata                 � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualiza dados do arquivo VGA                             ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GM120V(CLIAS,NREG,NOPC)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GM120V(cAlias,nReg,nOpc)
***************************

IF VGA_TRANSM=='S'

   CPOGM120()
   AxVisual(cAlias,nReg,nOpc,aCampos)

else

   help(" ",1,"OFIGM12001")//Garantia nao foi transmitida

endif                                                                 

return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GM120A    � Autor �Renata                 � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os dados do retorno no arquivo VGA                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GM120A(CLIAS,NREG,NOPC)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GM120A(cAlias,nReg,nOpc)
**************************

Private cDescri  := ""
Private nAdicion := 0

if VGA_TRANSM=='S'

   CPOGM120()
   AxAltera(cAlias,nReg,nOpc,aCampos)

   cDescri  := ""
   nAdicion := 0
   
   FG_SEEK("VG5","VI1->VI1_CODMAR+strzero(val(VI1->VI1_NUMOSV),8)",1,.F.)

   do while VG5->(!eof()) .and. strzero(val(VI1->VI1_NUMOSV),8) == VG5->VG5_NUMOSV .AND. VG5->VG5_FILIAL == XFILIAL("VG5")

      nAdicion := nAdicion + VG5->VG5_VALMAT
      VG5->(dbskip())

   enddo

   FS_SITUAC("VGA->VGA_SITUAC")

   RecLock("VGA",.F.)
   VGA->VGA_DESSIT := cDescri
   VGA->VGA_DIFPGT := (VGA->VGA_VALCRE - VGA->VGA_VALDEB) - (VGA->VGA_VALPEC + nAdicion + VGA->VGA_VALTPO)
   MsUnlock()

else

   help(" ",1,"OFIGM12001")//Garantia nao foi transmitida

endif   

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CPOGM120  � Autor �Renata                 � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pega campos do arquivo VGA no SX3                          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � CPOGM120()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CPOGM120()
***************

DbSelectArea("SX3")
DbSetOrder(1)
dbseek("VGA")
aCampos := {}

do While !eof() .and. x3_arquivo == "VGA"

   if X3USO(x3_usado).And.cNivel>=x3_nivel .And. Alltrim(x3_campo) $ ("VGA->VGA_NUMOSV/VGA->VGA_SERNFI/VGA->VGA_NUMNFI/VGA->VGA_CODMAR/VGA->VGA_DATRET/VGA->VGA_SITUAC/VGA->VGA_DATCRE/VGA->VGA_VALCRE/VGA->VGA_LANCRE/VGA->VGA_DATDEB/VGA->VGA_VALDEB/VGA->VGA_LANDEB/VGA->VGA_CODEST")

      aadd(aCampos,x3_campo)

   endif

   dbskip()

Enddo

DbSelectArea("VGA")

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_SITUAC � Autor �Renata                 � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Identifica situacao da ordem se servico na montadora       ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FS_SITUAC()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_SITUAC(Arg1)
*******************
if &ARG1 = "00"
   cDescri := OemtoAnsi(STR0006)  //"Garantia Solicitadas OK"    //"GARANTIA SOLICITADA OK"
elseif &ARG1 = "01"
   cDescri := OemtoAnsi(STR0007)  //"Garantia Solicitadas c/ ERRO"    //"GARANTIA SOLICITADA COM ERRO"
elseif &ARG1 = "02"
   cDescri := OemtoAnsi(STR0008)  //    //"CREDITO GARANTIA SOLICITADA"
elseif &ARG1 = "03"
   cDescri := OemtoAnsi(STR0009)  //    //"DEBITO GARANTIA SOLICITADA"
elseif &ARG1 = "04"
   cDescri := OemtoAnsi(STR0010)  //"Cupom Revisao OK/ERRO"    //"GARANTIA CUPOM REVISAO COM ERRO/OK"
elseif &ARG1 = "05"                                                                               
   cDescri := OemtoAnsi(STR0011)  //"Credito Cupom Revisao"    //"CREDITO GARANTIA CUPOM REVISAO"
elseif &ARG1 = "06"
   cDescri := OemtoAnsi(STR0012)  //"Debito Cupom Revisao"    //"DEBITO GARANTIA CUPOM REVISAO"
endif

return(cDescri)                                                    

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},; //Pesquisar
                     { STR0002 ,"GM120V", 0 , 2},; //Visualizar
                     { STR0003 ,"GM120A", 0 , 4}}  //Alterar
Return aRotina
