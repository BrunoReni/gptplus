#include "PLSMGER.CH"
#include "PLSA032.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSA032 � Autor � Tulio Cesar          � Data � 01.07.2004 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Co-Participacao por subcontrato x horario      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA032(xAutoCab,xAutoItens,xOpcAuto,nReg)
LOCAL aAliasItem	:= {{"BNZ","Horarios X Co-Participacao","PlsVldBNZ()",}}  
LOCAL aKeyItem 		:= {"BNX->BNX_SUBCON+BNX->BNX_SEQUEN"}
LOCAL aCondItem 	:= {"BNZ->BNZ_SUBCON+BNZ->BNZ_SEQUEN"}
LOCAL aChavCab 		:= {{{"BNZ_SUBCON","M->BNX_SUBCON"},{"BNZ_SEQUEN","M->BNX_SEQUEN"}}}

PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE n       := 1

PlsCabItem("BNX",Fundesc(),aAliasItem,{1},aKeyItem,aCondItem,aChavCab,nil,nil,xAutoCab,;
           xAutoItens,xOpcAuto,nReg)                                                                                       
           
Return                  


Function PLSA032Cd(cSubCon)
LOCAL nRet    := 0
LOCAL nOrdBNX := BNX->(IndexOrd())

BNX->(DbSetOrder(1))

BNX->(DbSeek(xFilial("BNX")+cSubCon+Replicate("9",Len(BNX->BNX_SEQUEN)),.T.))
BNX->(DbSkip(-1))
                                                           
If BNX->(BNX_FILIAL+BNX_SUBCON) <> xFilial("BNX")+cSubCon
   nRet := StrZero(1,3)
Else
   nRet := StrZero(Val(BNX->BNX_SEQUEN)+1,3)
Endif

BNX->(DbSetOrder(nOrdBNX))

Return(nRet)

/*
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PlsVldBNZ �Autor  �Microsiga           � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funca de validacao das datas de vigencia, chamada no       ���
���          � botao de OK da Rotina Cobertura / Co-Participacao.         ���
���          � Tabela - BNZ - Subcont x Co-Part x Hor(Item. 			  ���
�������������������������������������������������������������������������͹��
���Uso       � PLS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function PlsVldBNZ()
Local lRet     := .T.
Local aArea	   := GetArea()                                          
Local cDatDe   := 'BNZ_VIGINI'
Local cDatAte  := 'BNZ_VIGFIN' 

If BNZ->( FieldPos('BNZ_VIGINI') ) > 0 .And. BNZ->( FieldPos('BNZ_VIGFIN') ) > 0	

	If BNZ->( FieldPos("BNZ_FINATE") ) > 0 
		aChave := {'01',M->BNZ_TIPO+M->BNZ_FINATE,'BNZ_TIPO+BNZ_FINATE'}
	Else
		aChave := {'01',M->BNZ_TIPO,'BNZ_TIPO'}
	Endif

	lRet := PLSVLDVIG("BNZ",0,oGetDados,cDatDe,cDatAte,aChave)   
EndIf
	
RestArea(aArea)

Return(lRet)                                                                        

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 08/04/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := PLSMnDefY(, "BNX", , )

Return(aRotina)