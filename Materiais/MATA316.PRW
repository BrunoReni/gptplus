#INCLUDE "MATA316.ch"
#include "PROTHEUS.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA316   �Autor  � Daniel Leme        � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Categorias x Itens de Precifica��o             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA316()
Private cCadastro	:= STR0001 //"Categorias x Itens Precifica��o"
Private aRotina	:= MenuDef()

If AliasInDic("SAW")

	dbSelectArea("ACU")
	dbSetOrder(1)
	dbGoTop()
	
	mBrowse(06,01,22,75,"ACU",,,,,, MA316Legenda("ACU"))
Else
	Alert(STR0008) // "Para utilizar esta rotina � necess�rio a aplica��o do UPDFAT19"
EndIf
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA316Mnt�Autor  � Daniel Leme        � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Manuten��o do Cadastro de Categorias x Itens de            ���
���          � Precifica��o                                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA316Mnt( cAlias, nReg, nOpcx )

Local aAreaAtu := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local nI       := 0
Local oFont    := TFont():New( "Courier New", 6, 15 )
Local nTLinhas := 0

//-- EnchoiceBar
Local aVisual	:= {"ACU_COD","ACU_DESC"}
Local aAltera	:= {}
Local nOpcA			:= 0
Local nOpcB       := aRotina[nOpcx,4]
Local oEnch

//-- Dialog
Local oDlgEsp
Local aNoFields	:= {}
Local aYesFields	:= {}

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}

//-- GetDados
Local nNumLinhas  := 999

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

//-- GetDados
Private oGetD
Private aHeader	 := {}
Private aCols	    := {}
Private aPosObj := {}

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, INCLUI )

//-- Configura variaveis da GetDados
TMSFillGetDados( nOpcB, 'SAW', 1, xFilial( 'SAW' ) + M->ACU_COD   , { || SAW->(AW_FILIAL+AW_CATEGO) },;
																		 { || .T. }, aNoFields,	aYesFields )
nTLinhas := Len(aCols)									
										 
If	Empty(GDFieldGet('AW_ITEM',1))
	GDFieldPut('AW_ITEM',StrZero(1,Len(SAW->AW_ITEM)),1)
EndIf

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

	//-- Monta a enchoice.
	oEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,aVisual, aPosObj[1],aAltera, 3,,,,,,.T. )
	
	//-- Muda o fonte dos gets de campo Memo
	For nI := 1 To Len(oEnch:aEntryCtrls)
		If oEnch:aEntryCtrls[nI]:ClassName() == "TMULTIGET"
			oEnch:aEntryCtrls[nI]:oFont := oFont
		EndIf
	Next nI

	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oGetD := MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], nOpcx,'MATA316LOk()','MATA316TOk()','+AW_ITEM',.T.,nil,nil,nil,nNumLinhas)	

	oGetD:Refresh(.T.)
ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar( oDlgEsp,{|| IIf( Obrigatorio(aGets,aTela) .And. MATA316TOk(nOpcB),(nOpcA := 1, oDlgEsp:End()),'') },{|| nOpcA := 0, oDlgEsp:End() }) 

RestArea(aAreaSM0)

If nOpcB != 2 
	If nOpcA == 1
		MATA316Grv(nOpcB)
		If __lSX8
			ConfirmSX8()
		EndIf
	ElseIf __lSX8
		RollBackSX8()
	EndIf
EndIf

RestArea(aAreaATU)

Return nOpcA

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA316Del�Autor  � Daniel Leme        � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se �  permitida a exclus�o                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA316Del()
Local lRet	:= .T.
Local aArea	:= GetArea()


RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA316Vld�Autor  � Daniel Leme        � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o de Valida��o dos campos do cadastro de Categorias x ���
���          � Itens de Precifica��o                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA316Vld(cCampo) 
Local aArea 	:= GetArea()
Local lRet 		:= .T.

Default cCampo := ReadVar()

RestArea(aArea)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA316Whe�Autor  � Daniel Leme        � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna se � permitida a edi��o de um campo                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA316Whe(cCampo) 
Local   lRet	:= .T.

Default cCampo := ReadVar()

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA316Grv�Autor  � Daniel Leme        � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o de grava��o dos dados                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA316Grv(nOpcx)
Local aAreas	:= {	SAW->(GetArea()),;
							GetArea()}
Local nCntFor	:= 0
Local nCntFo1	:= 0    
Local lRet		:=.T.

Begin Transaction

	SAW->(DbSetOrder(1)) //-- AW_FILIAL+AW_CATEGO+AW_ITEM
	For nCntFor := 1 To Len( aCols )
		If	nOpcx != 5 .And. !GDDeleted( nCntFor ) 
			If SAW->(DbSeek( xFilial('SAW') + M->ACU_COD + GdFieldGet("AW_ITEM",nCntFor) ))
				RecLock('SAW',.F.)
			Else
				RecLock('SAW',.T.)
				SAW->AW_FILIAL := xFilial("SAW")
				SAW->AW_CATEGO := M->ACU_COD
			EndIf				

			//-- Grava Campos da GetDados
			For nCntFo1 := 1 To Len(aHeader)
				If	aHeader[nCntFo1,10] != 'V'
					SAW->(FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1]))
				EndIf
			Next              
			SAW->(MsUnLock())
		Else
			SAW->(DbSetOrder(1)) //-- AW_FILIAL+AW_CATEGO+AW_ITEM
			If SAW->(DbSeek( xFilial('SAW') + M->ACU_COD + GdFieldGet("AW_ITEM",nCntFor) ))
				RecLock('SAW',.F.)
				SAW->(dbDelete())
				SAW->(MsUnLock())
			EndIf
		EndIf
	Next nCntFor
	   
End Transaction

aEval(aAreas,{|x| RestArea(x) })

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA316LOk�Autor  � Daniel Leme        � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o de Valida��o da linha da GetDados                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA316LOk( nOpc )
Local lRet      := .T.        
Local aArea		 := GetArea()
Local aCpoCheck := {"AW_CODPRC"}
Local aCpoNoEmp := {"AW_CODPRC"}  
Local nCtn      := 0      

//-- Analisa se ha itens duplicados na GetDados.
If !GDDeleted(n) 
	lRet := MaCheckCols(aHeader,aCols,n)
	If lRet
		lRet := GDCheckKey(aCpoCheck,4)
	EndIf
EndIf

//-- Analisa se ha itens vazios na GetDados.
If !GDDeleted(n) .And. lRet
	For nCtn := 1 To Len(aCpoNoEmp)
		lRet := !Empty(GdFieldGet(aCpoNoEmp[nCtn],n))
		If !lRet
			Help('',1,'OBRIGAT',,aHeader[GdFieldPos(aCpoNoEmp[nCtn]),1],4,0)
			Exit
		EndIf
	Next 
EndIf

RestArea(aArea)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA316TOk�Autor  � Daniel Leme        � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o de Valida��o geral da tela de cadastro de Categoria ���
���          � x Itens de Precifica��o                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA316TOk( nOpcx )
Local lRet			:= .T.
Local nOld 			:= N
Local nI				:= 0   

If nOpcx <> 2
	For nI := 1 To Len(aCols)
		n := nI
		lRet := MATA316LOk( nOpcx )
		If !lRet
			Exit
		EndIf
	Next
EndIf
N := nOld
                       
Return(lRet)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA316Legenda� Autor � Daniel Leme        � Data � 19.02.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda da mBrowse ou retorna a ���
���          � para o BROWSE                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA316                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MA316Legenda(cAlias, nReg)

Local aLegenda := 	{	{"BR_VERDE", STR0002 },;  //"Categoria sem Precifica��o"
						{"BR_AZUL", STR0003 }} //"Categoria com Precifica��o"
Local uRetorno := .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}                                          
	Aadd(uRetorno, { '!Empty(Posicione("SAW",1,xFilial("SAW")+ACU->ACU_COD,"AW_ITEM"))', aLegenda[2][1] } )
	Aadd(uRetorno, { 'Empty(Posicione("SAW",1,xFilial("SAW")+ACU->ACU_COD,"AW_ITEM"))', aLegenda[1][1] } )
Else
	BrwLegenda(cCadastro, STR0004, aLegenda) //"Legenda"
Endif

Return uRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef  �Autor  � Daniel Leme        � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Menu funcional                                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina	:= {	{ STR0005 , "AxPesqui"  , 0, 1 },;  //"Pesquisar"
							{ STR0006, "MATA316Mnt", 0, 2 },;  //"Visualizar"
							{ STR0007 , "MATA316Mnt", 0, 4 },; //"Cadastrar"
							{ STR0004   , "MA316Legenda", 0 , 5} }  //"Legenda"
     
Return(aRotina)