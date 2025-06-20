#Include "Qiea240.ch"
#include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA240  � Autor � Marcelo Pimentel      � Data � 29/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao - Indices do IQF                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIE                                                    ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���Cesar Valadao �18/08/99�PROTHE�Alteracao de Macros                     ���
���Marcelo       �25/04/00�------� Incluido o quinto parametro como 3 no  ���
���Marcelo       �25/04/00�------� array aRotina.                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina := {	{OemToAnsi(STR0005), "AxPesqui"  , 0, 1,,.F.},; //"Pesquisar"
			       	{OemToAnsi(STR0006), "AxVisual"  , 0, 2},; //"Visualizar"
		   		 	{OemToAnsi(STR0007), "Q240AtuInd", 0, 4}}  //"Atualizar"
		   		 
Return aRotina

Function QIEA240
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0001) //"Indices do IQF"

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Private aRotina := MenuDef()

mBrowse(6,1,22,75,"QF1")

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q240AtuInd� Autor � Paulo Emidio de Barros� Data �26/11/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao - Indices do IQF                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA240                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q240AtuInd(cAlias,nReg,nOpc)
Local nOpca   := 0
Local nX      := 0
Local lGravaOk:= .T.
Local nCnt    := 0
Local oDlg
Local oGet
Local oSize

Private aHeader := {}
Private aCols   := {}
Private nUsado  := 0 
Private lCont   := .T.
Private nPosInd
Private nPosDes
Private nPosEsp
Private nPosIng
Private nPosCal
Private nPosFat

dbSelectArea(cAlias)
dbSetOrder(1)

cWhile  := 'QF1->(xFilial())'
cSeek 	:= 'QF1->(xFilial())'

FillGetDados(	4,; 							// numero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
               	'QF1',;       					// area a ser utilizada;
               	1,;      						// nOrdem - ordem correspondente a chave de �ndice para preencher o  acols;
                xFilial("QF1"),;  				// chave utilizada no posicionamento da �rea para preencher o acols; 
               	{|| QF1->QF1_FILIAL },;			// bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While. 
               	{|| .T.},;  					// uSeekFor
               	,;  						 	// aNoFields - array contendo os campos que n�o estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usu�rio;
                ,;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
               	.F.,;  							// lEmpty 
               	,; 								// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	,; 								// bAfterHeader
               	'') 							// cAliasQry*/

//��������������������������������������������������������������Ŀ
//� Guarda as posicoes dos campos p/ posterior consistencia      �
//����������������������������������������������������������������
nPosInd := Ascan(aHeader, { |x| Alltrim(x[2]) == "QF1_INDICE" })
nPosDes := Ascan(aHeader, { |x| Alltrim(x[2]) == "QF1_DESCRI" })
nPosEsp := Ascan(aHeader, { |x| Alltrim(x[2]) == "QF1_DESCES" })
nPosIng := Ascan(aHeader, { |x| Alltrim(x[2]) == "QF1_DESCIN" })
nPosCal := Ascan(aHeader, { |x| Alltrim(x[2]) == "QF1_CALC" })
nPosFat := Ascan(aHeader, { |x| Alltrim(x[2]) == "QF1_FATIQF" })

nUsado := Len(aHeader)

oSize := FwDefSize():New(.T.)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001);	//"Indices do IQF"
									FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������

oSize:AddObject( "GETDADOS",  100, 100, .T., .T. ) // Totalmente dimensionavel
oSize:lProp 	:= .T. // Proporcional
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() 	   // Dispara os calculos   

oGet := MsGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
					   oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND"),;
					   nOpc,"A240LinOk","QIE240TOk","",.T.,,,,,,,,,oDlg)		

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGet:TudoOk(),oDlg:End(),nOpca:=0)},{||oDlg:End()})

If nOpca == 1
	Begin Transaction
		lGravaOk := A240Grv()
		If !lGravaOK
			Help(" ",1,"A010NAOGRV")
		Else
			EvalTrigger()
		EndIf
	End Transaction
EndIf
dbSelectArea(cAlias)

Return(nOpca)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A240Grv   � Autor � Marcelo Pimentel      � Data � 29/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os Indices do IQF                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA240                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A240Grv()
Local nX        := 0 
Local nY 		:= 0 
Local nMaxArray := Len(aCols)

//��������������������������������������������������������������Ŀ
//� Grava os Indices informados									 �
//����������������������������������������������������������������
For nX := 1 to nMaxArray
 	dbSelectArea("QF1")
	dbSetOrder(1)
	If !aCols[nX,nUsado+1]
		If !Empty(aCols[nX,nPosInd]).And.!Empty(aCols[nX,nPosDes]).And.!Empty(aCols[nX,nPosCal])
			If dbSeek(xFilial("QF1")+aCols[nX,nPosInd])
				RecLock("QF1",.F.)   
			Else
				RecLock("QF1",.T.)   
				QF1_FILIAL := xFilial("QF1")
				QF1_INDICE := aCols[nX,nPosInd]
				QF1_DESCRI := aCols[nX,nPosDes]
				QF1_DESCES := aCols[nX,nPosEsp]
				QF1_DESCIN := aCols[nX,nPosIng]
				QF1_CALC   := aCols[nX,nPosCal]
				QF1_FATIQF := aCols[nX,nPosFat]
			Endif
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] <> "V"
					cVar := alltrim(aHeader[ny][2])
					Replace &cVar With aCols[nx][ny]
				Endif
			Next ny
			MsUnLock()
		EndIf	
	Else
		If dbSeek(xFilial("QF1")+aCols[nX,nPosInd])
			RecLock("QF1",.F.,.T.)
			dbDelete()
			MsUnLock()
		EndIf	
	EndIf
Next nx

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A240Obrig� Autor � Marcelo Pimentel      � Data � 28/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o dos campos obrigat�rios                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QieA240                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A240Obrig(cInd)
Local lRet :=.T.

//����������������������������������������������������������������������Ŀ
//�Nao deixar alterar o Campo-INDICE, se o registro existir.Somente pode-�
//�r� ser alterado, se for inclus�o do novo registro.                    �
//������������������������������������������������������������������������
If !Empty(cInd)
	dbSelectArea("QF1")
	dbSetOrder(1)
	If dbSeek(xFilial("QF1")+cInd)
		Help( " ", 1, "JAGRAVADO" )
		lRet:= .F.
	EndIf
	
EndIf
	
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A240LinOk � Autor � Marcelo Pimentel      � Data � 31/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa que faz consistencias apos a digitacao da tela    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA240                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A240LinOk()
Local lRet    := .T.
Local nX      :=0

For nX := 1 To Len(aCols)
	If !aCols[nX,Len(aCols[nX])]	
		If nX # n .And. aCols[n,nPosInd] == aCols[nX,nPosInd]
			Help(" ",1,"JAGRAVADO")
			lRet := .F.
		EndIf	
	Endif
Next nX

//��������������������������������������������������������������Ŀ
//� Verifica se a linha do aCols nao foi preenchida				 �
//����������������������������������������������������������������
If n == Len(aCols) .And. !aCols[n,Len(aCols[n])]
	If Empty(aCols[n,nPosInd]).Or.Empty(aCols[n,nPosDes]).Or.Empty(aCols[n,nPosCal])
		lRet := .F.
	EndIf
Endif
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIE240TOk � Autor � Marcelo Pimentel      � Data � 31/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa que faz consistencias do Indice Informado.        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA240                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QIE240TOk()
Local lRet    := .T.
Local nIndice := 0
Local nX      := 0

For nX := 1 To Len(aCols)
	If !aCols[nX,Len(aCols[nX])]
		nIndice += aCols[nX,nPosFat]
	Else
	  	QE0->(dbSetorder(2))
	  	If QE0->(dbSeek(xFilial("QE0")+aCols[nX,nPosInd]))
			MsgAlert(STR0004) //"O Indice marcado nao podera ser excluido, pois o mesmo esta sendo utilizado para calculo"
			lRet := .F.
			Exit
		EndIf
	EndIf
Next nX

If nIndice # 1
	MsgAlert(OemToAnsi(STR0002),OemToAnsi(STR0003))//"A Soma dos fatores deve ser 1"###"Aten��o"
	lRet := .F.
Endif

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A240Ind   � Autor � Marcelo Pimentel      � Data � 31/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa que faz consistencias do Indice Informado-WHEN    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA240                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A240Ind(nPosic)
Local lRet := .T.

If !Empty(aCols[n,nPosic]) .And. n <= Len(aCols)
	lRet := .F.
EndIf

Return(lRet)