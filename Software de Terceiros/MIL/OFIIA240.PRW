#Include "OfiIA240.ch"      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIIA240 � Autor �  Fabio                � Data � 08/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao dos dados do retorno do pedido   VW               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Integracao montadora x concessionaria                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIIA240

Local cChave, cCond
Private aCampos := {}
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0001)   //"Importacao do retorno do pedido  
Private cIndex, nIndex

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

If !Pergunte("OFIMAR",.t.) 
   Return
EndIf              

DbSelectArea("VIE")
DbSetOrder(1)

cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := 'VIE->VIE_CODMAR==MV_PAR01'

IndRegua("VIE",cIndex,cChave,,cCond,STR0006)
     
DbSelectArea("VIE")
nIndVIE := RetIndex("VIE")+1
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndVIE)

mBrowse( 6, 1,22,75,"VIE")

DbSelectArea("VIE")
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
���Fun��o    �IA240V    � Autor �Fabio                  � Data � 08/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � visualiza os dados dos arquivos                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � AxVisual(cAlias,nReg,nOpc,aCampos)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function IA240V(cAlias,nReg,nOpc)

CPOIA240()
AxVisual(cAlias,nReg,nOpc,aCampos)

return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �IA240I    � Autor �Fabio                  � Data � 08/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � chama a funcao FS_IA240GRAVA, feito dessa forma por causa  ���
���          � termometro                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � IA240I(cAlias,nReg,nOpc)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � INTEGRACAO                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function IA240I(cAlias,nReg,nOpc)

Processa({|| FS_IA240GRAVA()}) 
               
return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_IA240GR� Autor �Fabio                  � Data � 08/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama funcoes de gravacoes do VIE (Pedido   ) no  arquivos ���
���          � VEO                                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FS_IA240GRAVA()                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � integracao                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                  
Function FS_IA240GRAVA()

Local lDeleReg := .f.

lDeleReg := MsgYesNo(OemToAnsi(STR0007),OemToAnsi(STR0008))

DbSelectArea("VIE")
dbSetOrder(nIndVIE)

DbGoTop()

ProcRegua( RecCount() )   

Begin Transaction 

   Do While !Eof() .And. VIE->VIE_FILIAL == xFilial("VIE")

      DbSelectArea("VEO")
      DbSetOrder(2)
      DbSeek( xFilial("VEO") + VIE->VIE_NPEDFB + VIE->VIE_GRUITE + VIE->VIE_CODITE )
		                                                   
		RecLock("VEO",!Found())		      
                 
		VEO->VEO_FILIAL := xFilial("VEO")                 
		VEO->VEO_CODMAR := VIE->VIE_CODMAR
		VEO->VEO_GRUITE := VIE->VIE_GRUITE
		VEO->VEO_CODITE := VIE->VIE_CODITE
		VEO->VEO_NPEDDN := VIE->VIE_NPEDDN
		VEO->VEO_NPEDFB := VIE->VIE_NPEDFB
		VEO->VEO_QTDSUG := VIE->VIE_QTDSUG
		VEO->VEO_QTDINF := VIE->VIE_QTDINF
		VEO->VEO_QTDAPR := VIE->VIE_QTDAPR
		VEO->VEO_QTDBKO := VIE->VIE_QTDBKO
		VEO->VEO_QTDFAT := VIE->VIE_QTDFAT
		VEO->VEO_VALTOT := VIE->VIE_VALTOT
		VEO->VEO_VALBKO := VIE->VIE_VALBKO
		VEO->VEO_DATPRO := VIE->VIE_DATPRO
		VEO->VEO_DATALO := VIE->VIE_DATALO
		VEO->VEO_DATFAT := VIE->VIE_DATFAT
		VEO->VEO_DATVEN := VIE->VIE_DATVEN
		VEO->VEO_SERNFI := VIE->VIE_SERNFI
		VEO->VEO_NUMNFI := VIE->VIE_NUMNFI
		VEO->VEO_TIPPED := VIE->VIE_TIPPED
		VEO->VEO_STAERR := VIE->VIE_STAERR
		VEO->VEO_VIATRA := VIE->VIE_VIATRA
		VEO->VEO_NUMOSV := VIE->VIE_NUMOSV
		VEO->VEO_CHASSI := VIE->VIE_CHASSI
		VEO->VEO_PGT48H := VIE->VIE_PGT48H
		VEO->VEO_OBSPED := VIE->VIE_OBSPED

		MsUnLock()

		If lDeleReg
		
	      RecLock("VIE",.F.,.T.)
	      dbdelete()
	      MsUnlock()
	      WriteSx2("VIE")

      EndIf

      IncProc(OemtoAnsi(STR0005))   
   
      DbSelectArea("VIE")
      DbSkip()

   EndDo

End Transaction
        
return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CPOIA240  � Autor �Fabio                  � Data � 08/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Pega os campos no SX3 para serem mostrados na visualizacao  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � CPOIA240()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � integracao                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CPOIA240()

DbSelectArea("SX3")
DbSetOrder(1)
dbseek("VIE")
aCampos := {}

do While !eof() .and. x3_arquivo == "VIE"

   if X3USO(x3_usado) .And. cNivel>=x3_nivel 
      aadd(aCampos,x3_campo)
   endif           
   
   dbskip()
   
Enddo

DbSelectArea("VIE")

Return

Static Function MenuDef()
Local aRotina := { { STR0002 ,"axPesqui", 0 , 1},;
                      { STR0003 ,"IA240V"  , 0 , 2},;    //Vizualizar
                      { STR0004 ,"IA240I"  , 0 , 3}}     //Importa
Return aRotina
