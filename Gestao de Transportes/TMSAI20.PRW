#include "PROTHEUS.ch"
#include "TMSAI20.ch"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSAI20   � Autor � Richard Anderson   � Data � 22/11/06 ���
��������������������������������������������������������������������������͹��
���             	Cadastro de Descri��o do Frete por Pais     		         ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSAI20()                                                ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			         ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SIGATMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario �                                                           ���
���            �                                                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function TMSAI20()

Private aMemos    := {}
Private cCadastro	:= STR0001 //-- "Descri��o de Frete por Pais"
Private aRotina	:= {{ STR0002  , "AxPesqui"  , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMAI20Mnt" , 0, 2 },; //"Visualizar"
 				          { STR0004  , "TMAI20Mnt" , 0, 3 },; //"Incluir"  
 				          { STR0005  , "TMAI20Mnt" , 0, 4 },; //"Alterar"  
				          { STR0006  , "TMAI20Mnt" , 0, 5 } } //"Excluir

dbSelectArea("DI3")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DI3")

Return Nil

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI20Mnt � Autor � Richard Anderson     � Data �19.03.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Interface da Rotina de geracao de CRT                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Alias da tabela                                      ���
���          � ExpN2: Numero do Registro                                   ���
���          � ExpN3: Opcao do aRotina                                     ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI20Mnt(cAlias, nReg, nOpcx)

Local nI       := 0
Local aAreaAtu := GetArea()
Local nTLinhas := 0

//-- EnchoiceBar
Local aTmsVisual	:= {}
Local aTmsAltera	:= {}
Local nOpcA			:= 0
Local nOpcB       := aRotina[nOpcx,4]
Local oTmsEnch

//-- Dialog
Local oTmsDlgEsp
Local aNoFields	:= {}
Local aYesFields	:= {}
Local oFont       := TFont():New( "Courier New", 6, 15 )

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, INCLUI )

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

	//-- Monta a enchoice.
	oTmsEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,, aTmsPosObj[1],, 3,,,,,,.T. )
	
	//-- Muda o fonte dos gets de campo Memo
	For nI := 1 To Len(oTmsEnch:aEntryCtrls)
		If oTmsEnch:aEntryCtrls[nI]:ClassName() == "TMULTIGET"
			oTmsEnch:aEntryCtrls[nI]:oFont := oFont
		EndIf
	Next nI					
	
ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar( oTmsDlgEsp,{|| nOpcA := 1, oTmsDlgEsp:End() },{|| nOpcA := 0, oTmsDlgEsp:End() }) 

If nOpcx != 2 .And. nOpcA == 1
	TMAI20Grv(nOpcx)
EndIf

RestArea(aAreaATU)

Return nOpcA

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI20Vld� Autor � Richard Anderson      � Data �22/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida antes de editar o campo.                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMAI20Vld(cCampo) 

Local   lRet	:= .T.
Default cCampo := ReadVar()

If "DI3_PAIS" $ cCampo
	lRet := ExistCpo("SYA",M->DI3_PAIS,1) .And. ExistChav("DI3",M->DI3_PAIS)
	If lRet
		M->DI3_DEPAIS := E_Field("DI3_PAIS","YA_DESCR")
	EndIf
EndIf			

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI20Grv� Autor � Richard Anderson      � Data �12/11/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava��o dos dados                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAI20                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMAI20Grv(nOpcx)

Local nI := 0

If nOpcx == 3 .Or. nOpcx == 4
	RecLock("DI3",(nOpcx == 3))
	For nI := 1 To FCount()
		If "FILIAL" $ Field(nI)
			FieldPut(nI,xFilial("DI3"))
		Else
			If Type("M->"+FieldName(nI)) <> "U"
				FieldPut(nI,M->&(FieldName(nI)))
			EndIf
		EndIf
	Next nI
	MsUnLock()
	//��������������������������������������������������������������Ŀ
	//� Grava o campo MEMO                                           �
	//����������������������������������������������������������������
	MSMM(DI3->DI3_CODDCA,,,M->DI3_DOCANE,1,,,"DI3","DI3_CODDCA")
Else
	RecLock("DI3",.F.)
	dbDelete()
	MsUnLock()
EndIf

Return NIL
