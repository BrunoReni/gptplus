/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIIA130 � Autor � Emilton               � Data � 12/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exportacao dos dados da Venda de Cartao de Veiculos        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Integracao                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#include "protheus.ch"
#INCLUDE "Ofiia130.ch"
Function OFIIA130

Private aCampos := {}
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0001)  // "Venda de Veiculos no Varejo"
Private cIndex, cChave, cCond , nIndex := 0

FS_MENUIA130()

if len(aRotina) == 0
   Return
Endif

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

dbSelectArea("VV0")
cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := 'VV0_SITNFI=="1".and.!empty(VV0_NUMNFI)'
IndRegua("VV0",cIndex,cChave,,cCond,STR0002) //"Aguarde, filtrando registros..."
   
DbSelectArea("VV0")
nIndex := RetIndex("VV0")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)
  
cDelFunc := ".T."

lInverte := .F.

Markbrow("VV0","VV0_EXPVEI",,,,"0")

//mBrowse( 6, 1,22,75,"VV0")

dbSelectArea("VV0")
RetIndex()
DbsetOrder(1)
#IFNDEF TOP
   If File(cIndex+OrdBagExt())
      fErase(cIndex+OrdBagExt())
   Endif
#ENDIF

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_MENUIA130Autor �Emilton                � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta as opcoes do menu do programa                         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FS-MENUIA130(calias,nreg,nopc)                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � integracao                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_MENUIA130(cAlias, nReg, nOpc)

if !Pergunte("OFIMAR",.t.) 
   return
endif

cCodMar := MV_PAR01

return()

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �IA130V    � Autor �Emilton                � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � visualiza os dados dos arquivos                            ���
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
Function IA130V(cAlias,nReg,nOpc)

CPOIA130()
AxVisual(cAlias,nReg,nOpc,aCampos)

return
  
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �IA130E    � Autor �Emilton                � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que chama FS_EXPVV0, dessa forma devido ao termometro��
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � IA130E(cAlias,nReg,nOpc)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � INTEGRACAO                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function IA130E(cAlias,nReg,nOpc)
               
Begin Transaction

   Processa( {|| FS_EXP130VV0() } )

End Transaction

RETURN                

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_EXP130VV0 � Autor �Emilton                � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que grava os dados do VV0 no VI7                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FS_EXPVV0()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � INTEGRACAO                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_EXP130VV0()
Local cDn  
Local cNOMCLI , cENDCLI , cCIDCLI , cESTCLI
Local cChassi , lRet := .t.
Private lMsHelpAuto := .t.

dbselectArea("VV0")
dbgotop()
                    
ProcRegua( reccount() ) 
        
Begin Transaction

   While !eof() .And. VV0->VV0_FILIAL == xFilial("VV0")

      If !IsMark("VV0_EXPVEI",ThisMark(),ThisInv())
         IncProc(OemtoAnsi(STR0007))    //"Gravando arquivos de integracao!!"
         dbskip()
         loop
      endif

      dbselectarea("VVA")
      dbsetorder(1)
      dbseek(xFilial("VVA")+VV0->VV0_NUMTRA)
      
      cChassi := VVA->VVA_CHASSI
      
      dbselectArea("VE4")                     //FABRICANTE
      dbgotop()
      dbsetorder(1)
      dbseek(xFilial("VE4")+VV1->VV1_CODMAR)
      FG_SEEK("SA1","VV0->VV0_CODCLI+VV0->VV0_LOJA",1,.F.)
      FG_SEEK("VV1","VVA->VVA_CHASSI",2,.F.)  
      FG_SEEK("SA3","VV0->VV0_CODVEN",1,.F.)  
      
      cDn     := VE4->VE4_CODCON
      cNomCli := left(SA1->A1_NOME,28)
      cEndCli := left(SA1->A1_END,28)
      cNumCli := space(04)
      cCidCli := Left(SA1->A1_MUN,20)
      cEstCli := SA1->A1_EST
      cCepCli := SA1->A1_CEP
      cDDDCli := SA1->A1_DDD
      cFonCli := Left(SA1->A1_TEL,8)
      cDatNas := strzero(day(SA1->A1_DTNASC),2)+strzero(month(SA1->A1_DTNASC),2)+Right(strzero(year(SA1->A1_DTNASC),4),2)
      cEstCiv := space(01)  // pela f�brica os poss�veis s�o S/C/D/O
      cForAca := space(02)  // pela f�brica os poss�veis s�o NA/1C/1I/2C/2I/3C/3I
      cSexCli := space(01) 
      cTipVen := space(02)
      cVeiRec := space(02)
      cAtiCli := space(02)
      cCriVen := space(02)
      cTipMer := space(02)
      cTMAVei := Left(VV1->VV1_SEGMOD,4)
      cDatVen := strzero(day(VV0->VV0_DATMOV),2)+strzero(month(VV0->VV0_DATMOV),2)+substr(strzero(year(VV0->VV0_DATMOV)),3,2)
      cFisJur := If(len(SA1->A1_CGC) > 14,"2","1")
      cCGCCli := SA1->A1_CGC
      cNomVen := Left(SA3->A3_NOME,30)
      cCICVen := SA3->A3_CGC
      cResFro := space(28)
      cMeiVen := space(02)
      cIntern := space(50)

      dbselectArea("VIJ")
      dbgotop()
      dbsetorder(1)
      dbseek(xFilial("VIJ")+VV1->VV1_CODMAR+DTOS(VV0->VV0_DATMOV)+cChassi)

      If !RecLock("VIJ", !Found() )
         Help("  ",1,"REGNLOCK")
         lRet := .f.
         DisarmTransaction()
         Break               
      EndIf
   
      VIJ->VIJ_FILIAL := xFilial("VIJ")
      VIJ->VIJ_CHASSI := VVA->VVA_CHASSI
      VIJ->VIJ_COMPRA := left(SA1->A1_NOME,28)
      VIJ->VIJ_ENDECO := left(SA1->A1_END,28)
      VIJ->VIJ_CIDADE := left(SA1->A1_MUN,20)
      VIJ->VIJ_ESTADO := SA1->A1_EST
      VIJ->VIJ_CEP    := SA1->A1_CEP
      VIJ->VIJ_DDD    := SA1->A1_DDD
      VIJ->VIJ_FONE   := Left(SA1->A1_TEL,8)
      VIJ->VIJ_DTNASC := strzero(day(SA1->A1_DTNASC),2)+strzero(month(SA1->A1_DTNASC),2)+substr(strzero(year(SA1->A1_DTNASC)),3,2)
      VIJ->VIJ_ESTCIV := space(01)  // pela f�brica os poss�veis s�o S/C/D/O
      VIJ->VIJ_FORMAC := space(02)  // pela f�brica os poss�veis s�o NA/1C/1I/2C/2I/3C/3I
      VIJ->VIJ_SEXO   := space(01) 
      VIJ->VIJ_TIPVEN := space(02)
      VIJ->VIJ_VEIREC := space(02)
      VIJ->VIJ_ATICLI := space(02)
      VIJ->VIJ_CRIVEN := space(02)
      VIJ->VIJ_TIPMER := space(02)
      VIJ->VIJ_TMAVEI := Left(VV1->VV1_SEGMOD,4)
      VIJ->VIJ_DATVEN := strzero(day(VV0->VV0_DATMOV),2)+strzero(month(VV0->VV0_DATMOV),2)+substr(strzero(year(VV0->VV0_DATMOV)),3,2)
      VIJ->VIJ_FISJUR := If(len(SA1->A1_CGC) > 14,"2","1")
      VIJ->VIJ_CGCCLI := SA1->A1_CGC
      VIJ->VIJ_NOMVEN := Left(SA3->A3_NOME,30)
      VIJ->VIJ_CICVEN := SA3->A3_CGC
      VIJ->VIJ_RESFRO := space(28)
      VIJ->VIJ_MEIVEN := space(02)
      VIJ->VIJ_INTERN := space(50)
      MsUnlock()

      IncProc(OemtoAnsi(STR0007))   //Gravando arquivos de integracao!!
      dbskip()

   EndDo

End Transaction

If !lRet 
   MostraErro()
EndIf

return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CPOIA130  � Autor �Emilton                � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Pega os campos no SX3 para serem mostrados na visualizacao  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � CPOIA130()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � integracao                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CPOIA130()

DbSelectArea("SX3")
dbSetOrder(1)
dbseek("VV0")
aCampos := {}

do While !eof() .and. x3_arquivo == "VV0"

   if X3USO(x3_usado) .And. cNivel>=x3_nivel  //.And. x3_campo $ []
      aadd(aCampos,x3_campo)
   endif

   dbskip()

Enddo

DbSelectArea("VV0")

Return

Static Function MenuDef()
Local aRotina := { { STR0003 ,"axPesqui",0, 1},; // Pesquisar
      		       { STR0004 ,"IA130V", 0 , 2},; // Visualizar
		           { STR0006 ,"IA130E", 0 , 3}}  // Exportar
Return aRotina
