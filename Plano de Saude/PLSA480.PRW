#include "PROTHEUS.CH"
#include "PLSA480.CH"
#include "PLSMGER.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE "hatActions.ch"

#define K_Proced 6
#define K_SitAdv 7
#define K_CoPart 6
#define K_Copiar 8

STATIC cMenu := 2 //Variavel estatica para controlar o MenuDef e o aRotina.
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA480 � Autor � Tulio Cesar            � Data � 31.05.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Grupo de Cobertura                                         ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA480
PRIVATE aRotina   := {}
PRIVATE cCadastro := Fundesc() //'Grupo de Cobertura'    

cMenu     := 0       
aRotina   := MenuDef()
//��������������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                              �
//����������������������������������������������������������������������������
BG7->(DbSetOrder(1))
BG7->(DbGoTop())

oBrowse := FWMBrowse():New()

oBrowse:SetAlias('BG7')
oBrowse:SetMenuDef('PLSA480')		//Define que este � o Browse que ser� utilizado na chamada da fun��o
oBrowse:setMainProc("PLSA480")
oBrowse:SetDescription(cCadastro)   // Descri��o do Browser
oBrowse:Activate()

//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal                                                  �
//����������������������������������������������������������������������������
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL480MOV � Autor � Tulio Cesar           � Data � 31.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Movimentacao do Grupo de Cobertura                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL480MOV(cAlias,nReg,nOpc)
Local I__f := 0
//��������������������������������������������������������������������������Ŀ
//� Define Variaveis...                                                      �
//����������������������������������������������������������������������������
LOCAL nOpca	   := 0
LOCAL oDlg
LOCAL bOk      := {|| nOpca := 1,If(Obrigatorio(aGets,aTela) .And. PLSA480Del(nOpc),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL aButtons := {}
LOCAL cOldCad  := cCadastro

PRIVATE oEnchoice
PRIVATE aChave   := {}
PRIVATE aGets    := {}
PRIVATE aTela    := {}
PRIVATE nAlt := 015

aSize := MsAdvSize()
//��������������������������������������������������������������������������Ŀ
//� Monta dados...                                                           �
//����������������������������������������������������������������������������
If nOpc == K_Incluir
	Copy "BG7" TO Memory Blank
Else
	Copy "BG7" TO MEMORY
EndIf
//��������������������������������������������������������������������������Ŀ
//� Define Dialogo...                                                        �
//����������������������������������������������������������������������������
If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12
	nAlt := 030
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd Pixel
Else
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
Endif
//��������������������������������������������������������������������������Ŀ
//� Monta Enchoice...                                                        �
//����������������������������������������������������������������������������
	oEnchoice := MSMGET():New(cAlias,nReg,nOpc,,,,,{nAlt,001,196,355},,,,,,oDlg,,,.F.)
//��������������������������������������������������������������������������Ŀ
//� Monta dialogo...                                                         �
//����������������������������������������������������������������������������
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOk,{||oDlg:End()},.F.,aButtons) })
//��������������������������������������������������������������������������Ŀ
//� Rotina de gravacao dos dados...                                          �
//����������������������������������������������������������������������������
If nOpca == K_OK
   //��������������������������������������������������������������������������Ŀ
   //� Gravacao do grupo de cobertura...                                        �
   //����������������������������������������������������������������������������
   BG7->(DbGoTo(nReg))
   PLUPTENC("BG7",nOpc)
   //��������������������������������������������������������������������������Ŀ
   //� No caso de exclusao devo excluir os itens...                             �
   //����������������������������������������������������������������������������
   If nOpc == K_Excluir    
      //��������������������������������������������������������������������������Ŀ
      //� BG8 - Itens procedimentos...                                             �
      //����������������������������������������������������������������������������
      BG8->(DbSetOrder(1))
      While BG8->(MsSeek(xFilial("BG8")+BG7->(BG7_CODINT+BG7_CODGRU)))
            BG8->(RecLock("BG8",.F.))
            BG8->(DbDelete())
            BG8->(MsUnLock())
      Enddo
      //��������������������������������������������������������������������������Ŀ
      //� BHK - Procedimentos X Co-Participacao                                    �
      //����������������������������������������������������������������������������
      BHK->(DbSetOrder(1))
      While BHK->(MsSeek(xFilial("BHK")+BG7->(BG7_CODINT+BG7_CODGRU)))
            BHK->(RecLock("BHK",.F.))
            BHK->(DbDelete())
            BHK->(MsUnLock())
      Enddo                  
   Endif
EndIf        
//��������������������������������������������������������������������������Ŀ
//� Restaura dados...                                                        �
//����������������������������������������������������������������������������
cCadastro := cOldCad
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                         �
//����������������������������������������������������������������������������
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL480COD � Autor � Tulio Cesar           � Data � 31.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta novo codigo...                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL480COD(cCodInt,cAlias,cCampo)
LOCAL nOrdBG7 	:= 0
LOCAL nRecBG7 	:= 0
LOCAL nRet		:= 0
DEFAULT cAlias 	:= "BG7"         
DEFAULT cCampo	:= "BG7_CODGRU"

nOrdBG7 := (cAlias)->( IndexOrd() )
nRecBG7 := (cAlias)->( Recno() )

(cAlias)->( MsSeek( xFilial(cAlias)+cCodInt+"999",.T.) )
(cAlias)->( DbSkip(-1) )

If (cAlias)->&( cAlias+"_FILIAL + " + cAlias+"_CODINT" ) <> xFilial(cAlias)+cCodInt
   nRet := StrZero(1,3)
Else
   nRet := StrZero( Val( (cAlias)->&(cCampo) )+1,3)
Endif

(cAlias)->( DbSetOrder(nOrdBG7) )
(cAlias)->( DbGoTo(nRecBG7) )

Return(nRet)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL480PRO � Autor � Tulio Cesar           � Data � 11.07.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Seleciona procedimentos para um grupo de cobettura         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL480PRO(cAlias,nReg,nOpc)
LOCAL cOldCad := cCadastro
LOCAL aAuxRot := {}
Local i

cMenu := 1
//��������������������������������������������������������������������������Ŀ
//� Define variaveis da rotina...                                            �
//����������������������������������������������������������������������������
PRIVATE aRotina := MenuDef()						                    
//��������������������������������������������������������������������������Ŀ
//� Define fitlro...                                                         �
//����������������������������������������������������������������������������
PRIVATE cFil := "@BG8_FILIAL = '"+xFilial("BG8")+"' AND BG8_CODINT = '"+BG7->BG7_CODINT+"' AND "
        cFil += " BG8_CODGRU = '"+BG7->BG7_CODGRU+"' AND D_E_L_E_T_ = ' '"
//��������������������������������������������������������������������������Ŀ
//� Define titulo...                                                        �
//����������������������������������������������������������������������������

cCadastro   := STR0010+"   "+AllTrim(BG7->(BG7_CODINT+"."+BG7_CODGRU)+" - "+BG7->BG7_DESCRI) //"Procedimentos do Grupo de Cobertura "

//��������������������������������������������������������������������������Ŀ
//� Ponto de entrada para adicionar itens ao arotina...                      �
//����������������������������������������������������������������������������
If ExistBlock("PL480RT2")
	aAuxRot := ExecBlock("PL480RT2",.F.,.F.,)
	If Valtype(aAuxRot) == "A" 
		If Len(aAuxRot) > 0
			For i := 1 To Len(aAuxRot)
				Aadd(aRotina, aAuxRot[i])
			Next
		Endif
	Endif
Endif

//��������������������������������������������������������������������������Ŀ
//� Executa filtro e monta browse...                                        �
//����������������������������������������������������������������������������
BG8->(DbSetOrder(1))   
DbSelectArea("BG8")
SET FILTER TO &cFil
BG8->(MsSeek(xFilial("BG8")))
BG8->(dbSetorder(1))
mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BG8",,,,,,,,,,,.F.)
BG8->(DbClearFilter())
//��������������������������������������������������������������������������Ŀ
//� Restaura dados...                                                       �
//����������������������������������������������������������������������������
cCadastro := cOldCad
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                        �
//����������������������������������������������������������������������������
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL480INC � Autor � Thiago Machado Correa � Data � 01.11.04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Rotina de inclusao                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA480INC(cFil,nOpc)
BG8->(AxInclui("BG8",nil,nil,nil,nil,nil,'P480HATBG8(nOpc)'))
DbSelectArea("BG8")
SET FILTER TO &cFil
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA480ALT
Rotina de alteracao

@author  Renan Sakai
@version P12
@since   30/04/2019
/*/
//------------------------------------------------------------------- 
Function PLSA480ALT(cFil,nOpc)
BG8->(AxAltera("BG8",BG8->(Recno()),K_Alterar,nil,nil,nil,nil,'P480HATBG8(nOpc)'))
DbSelectArea("BG8")
SET FILTER TO &cFil
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} P480HATBG8
Realiza a gravacado dos pedidos do HAT

@author  Renan Sakai
@version P12
@since   30/04/2019
/*/
//------------------------------------------------------------------- 
Function P480HATBG8(nOpc)
Local lRet := .T.
Local aBG8HAT := {}

if GetNewPar("MV_PLSHAT","0") == "1"
	if nOpc == K_Incluir
		PLHATPedPD(nOpc,_coverageGroupLevel_BG8_inc,"BG8",M->(BG8_CODINT+BG8_CODGRU+BG8_CODPAD+BG8_CODPSA+BG8_NIVEL))
	
	elseIf nOpc == K_Alterar
		aadd(aBG8HAT,{"BG8_CODPSA",M->BG8_CODPSA })
		aadd(aBG8HAT,{"BG8_BENUTL",M->BG8_BENUTL })
		aadd(aBG8HAT,{"BG8_AUTORI",M->BG8_AUTORI })
		aadd(aBG8HAT,{"BG8_CARENC",M->BG8_CARENC})
		aadd(aBG8HAT,{"BG8_UNCAR" ,M->BG8_UNCAR })
		aadd(aBG8HAT,{"BG8_NIVEL" ,M->BG8_NIVEL })
		aadd(aBG8HAT,{"BG8_NIVCAR",M->BG8_NIVCAR })
		aadd(aBG8HAT,{"BG8_QTD"   ,M->BG8_QTD })
		aadd(aBG8HAT,{"BG8_UNCA"  ,M->BG8_UNCA })
		aadd(aBG8HAT,{"BG8_PERIOD",M->BG8_PERIOD })
		aadd(aBG8HAT,{"BG8_UNPERI",M->BG8_UNPERI })
		aadd(aBG8HAT,{"BG8_QTDESP",M->BG8_QTDESP })
		aadd(aBG8HAT,{"BG8_SEXO"  ,M->BG8_SEXO })
		aadd(aBG8HAT,{"BG8_QTDMED",M->BG8_QTDMED })
		aadd(aBG8HAT,{"BG8_IDAMIN",M->BG8_IDAMIN })
		aadd(aBG8HAT,{"BG8_QTDPAT",M->BG8_QTDPAT })
		aadd(aBG8HAT,{"BG8_IDAMAX",M->BG8_IDAMAX })
		aadd(aBG8HAT,{"BG8_PTRMED",M->BG8_PTRMED })
		aadd(aBG8HAT,{"BG8_PTRESP",M->BG8_PTRESP })
		aadd(aBG8HAT,{"BG8_PTRPAT",M->BG8_PTRPAT })
		aadd(aBG8HAT,{"BG8_CODPAD",M->BG8_CODPAD })
		aadd(aBG8HAT,{"BG8_CLACAR",M->BG8_CLACAR })

		PLHATPedPD(nOpc,_coverageGroupLevel_BG8_alt,"BG8",M->(BG8_CODINT+BG8_CODGRU+BG8_CODPAD+BG8_CODPSA+BG8_NIVEL),aBG8HAT)
	endIf
endIf

Return lRet
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL480CLO � Autor � Thiago Machado Correa � Data � 01.11.04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Parametros para a clonagem do Grupo de Cobertura.          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL480CLO(cAlias,nReg,nOpc)

Local oDlg
Local nOpca   := 0
Local cCodInt := BG7->BG7_CODINT
Local cCodGru := BG7->BG7_CODGRU
Local cDesGru := BG7->BG7_DESCRI
Local cNewCod := Space(3)
Local cNewDes := Space(40)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()

	@ 20,05 Say STR0014		PIXEL //"Operadora"
	@ 35,05 Say STR0015	PIXEL //"Cod. Grupo"
	@ 50,05 Say STR0016		PIXEL //"Descricao"
	@ 65,05 Say STR0017	PIXEL COLOR CLR_HBLUE //"Cod. Destino"
	@ 80,05 Say STR0018	PIXEL COLOR CLR_HBLUE //"Desc. Destino"
	@ 20,45 MsGet cCodInt Picture X3Picture("BG7_CODINT") When .F. Size 20,08 PIXEL
	@ 35,45 MsGet cCodGru Picture X3Picture("BG7_CODGRU") When .F. Size 25,08 PIXEL
	@ 50,45 MsGet cDesGru Picture X3Picture("BG7_DESCRI") When .F. Size 140,08 PIXEL
	@ 65,45 MsGet cNewCod Picture X3Picture("BG7_CODGRU") Valid VldGru(cCodInt,cNewCod) Size 20,08 PIXEL COLOR CLR_HBLUE
	@ 80,45 MsGet cNewDes Picture X3Picture("BG7_DESCRI") Size 140,08 PIXEL COLOR CLR_HBLUE

ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End(),.T. },{||oDlg:End()},.F.,{})  })

If nOpca == 1    
	If AllTrim(cNewCod) == "" .OR. AllTrim(cNewDes) == ""
		Help("",1,"OBRIGAT")
	else
		ClonaTab(cCodInt,cCodGru,cNewCod,cNewDes)
		BG7->(MsSeek(xFilial("BG7")+cCodInt+cNewCod))
		PL480MOV("BG7",BG7->(Recno()),4)
	Endif
Endif

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � ClonaTab �Autor  �Thiago Machado Correa � Data �  01/11/04   ���
���������������������������������������������������������������������������͹��
���Desc.     � Clona Grupo de Cobertura                                     ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � AP6                                                          ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ClonaTab(cCodInt,cCodGru,cNewCod,cNewDes)

Local aArea 	:= sGetArea()
Local aDaDbG7 	:= {}
Local nColBG7   := Len(BG7->(DbStruct()))
Local aDaDbG8 	:= {}
Local nColBG8   := Len(BG8->(DbStruct()))
Local aDaDbHK 	:= {}
Local nColBHK   := Len(BHK->(DbStruct()))
Local nI		:= 0 
Local nJ		:= 0 	
Local nCont 	:= 0
Local nCont2	:= 0
Local cCodPad   := ""
Local cCodPsa   := ""

sGetArea(aArea,"BG7")
sGetArea(aArea,"BG8")
sGetArea(aArea,"BHK")

DbSelectArea("BG7")
MsSeek(xFilial("BG7")+cCodInt+cCodGru)
While (!Eof()) .AND. (xFilial("BG7")+cCodInt+cCodGru == BG7->(BG7_FILIAL+BG7_CODINT+BG7_CODGRU))
	nCont++
	aadd(aDaDbG7,Array(nColBG7))
	For nI := 1 to nColBG7
		aDaDbG7[nCont,nI] := FieldGet(nI)
	Next
	DbSkip()
End

nCont := 0

nCont  := 0
DbSelectArea("BG8")
MsSeek(xFilial("BG8")+cCodInt+cCodGru)
While (!Eof()) .AND. (xFilial("BG8")+cCodInt+cCodGru == BG8->(BG8_FILIAL+BG8_CODINT+BG8_CODGRU))

	nCont++
	aadd(aDaDbG8,Array(nColBG8))
	For nI := 1 to nColBG8
		aDaDbG8[nCont,nI] := FieldGet(nI)
		If FieldName(nI) == "BG8_CODPSA"
			cCodPsa := aDaDbG8[nCont,nI]
		Endif
		If FieldName(nI) == "BG8_CODPAD"
			cCodPad := aDaDbG8[nCont,nI]
		Endif
	Next
	
		DbSelectArea("BHK")
	MsSeek(xFilial("BHK")+cCodInt+cCodGru+cCodPad+cCodPsa)
	While (!Eof()) .AND. (xFilial("BHK")+cCodInt+cCodGru+cCodPad+cCodPsa == BHK->(BHK_FILIAL+BHK_CODINT+BHK_CODGRU+BHK_CODPAD+BHK_CODPSA))
		nCont2++
		aadd(aDaDbHK,Array(nColBHK))
		For nJ := 1 to nColBHK
			aDaDbHK[nCont2,nJ] := FieldGet(nJ)
		Next
		DbSkip()
	End
		
	DbSelectArea("BG8")
	DbSkip()
End

For nI := 1 to Len(aDaDbG7)
	RecLock("BG7",.T.)
	For nJ := 1 To nColBG7
		FieldPut(nJ,aDaDbG7[nI,nJ])
	Next
	BG7->BG7_CODGRU := cNewCod
	BG7->BG7_DESCRI := cNewDes
	DbUnlock()
Next


For nI := 1 to Len(aDaDbG8)
	RecLock("BG8",.T.)
	For nJ := 1 To nColBG8
		FieldPut(nJ,aDaDbG8[nI,nJ])
	Next
	BG8->BG8_CODGRU := cNewCod
	DbUnlock()
Next 

For nI := 1 to Len(aDaDbHK)
	RecLock("BHK",.T.)
	For nJ := 1 To nColBHK
		FieldPut(nJ,aDaDbHK[nI,nJ])
	Next
	BHK->BHK_CODGRU := cNewCod
	DbUnlock()
Next

sRestArea(aArea)
Return(NIL)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � VldGru   �Autor  �Thiago Machado Correa � Data �  01/11/04   ���
���������������������������������������������������������������������������͹��
���Desc.     � Valida inclusao do novo Grupo de Cobertura        		 	���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function VldGru(cCodInt,cCodGru)
Local lRet := .T.

BG7->(DbSetOrder(1))
If BG7->(MsSeek(xFilial("BG7")+cCodInt+cCodGru))
	MsgStop(STR0019) //"Codigo ja cadastrado!"
 	lRet := .F.
Endif       


Return(lRet)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA480Del � Autor � Helio F R lecchi    � Data � 12.09.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Validacao de delecao do cadastro de Grupo de Cobertura     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA480Del(nOpc)

LOCAL lRet		:= .T.
LOCAL aChaves 	:= {}

If nOpc # K_Excluir
	Return .T.
Endif

aadd(aChaves,{"BRV","BRV_CODGRU",BG7->(BG7_CODGRU)}) //Planos X Grupos de Cobertura
aadd(aChaves,{"BT7","BT7_CODGRU",BG7->(BG7_CODGRU)}) //Grp/Emp X Grupos de Cobertura
aadd(aChaves,{"BG7","BG7_GRUVIN",BG7->(BG7_CODGRU)}) //Grupos de Cobertura X Grupo Principal
aadd(aChaves,{"BFC","BFC_CODGRU",BG7->(BG7_CODGRU)}) //Grupos de Cobertura/Familias
aadd(aChaves,{"BFE","BFE_CODGRU",BG7->(BG7_CODGRU)}) //Grupos de Cobertura/Usuarios

lRet := PLSCHKDEL(aChaves)

Return(lRet) 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL480COP � Autor � Tulio Cesar           � Data � 11.07.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Seleciona co-participacoes p/ um procedimento              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL480COP(cAlias,nReg,nOpc)
LOCAL cOldCad := cCadastro
LOCAL aAuxRot := {}
Local i
//��������������������������������������������������������������������������Ŀ
//� Define variaveis da rotina...                                            �
//����������������������������������������������������������������������������
PRIVATE aRotina   := {}
//��������������������������������������������������������������������������Ŀ
//� Define fitlro...                                                         �
//����������������������������������������������������������������������������
PRIVATE cFil := "@BHK_FILIAL = '"+xFilial("BHK")+"' AND "
        cFil += " BHK_CODINT = '"+BG8->BG8_CODINT+"' AND "
        cFil += " BHK_CODGRU = '"+BG8->BG8_CODGRU+"' AND "
        cFil += " BHK_CODPAD = '"+BG8->BG8_CODPAD+"' AND "
        cFil += " BHK_CODPSA = '"+BG8->BG8_CODPSA+"' AND "
        cFil += " D_E_L_E_T_ = ' '"
//��������������������������������������������������������������������������Ŀ
//� Define titulo...                                                         �
//����������������������������������������������������������������������������
cCadastro   := STR0012+"   "+BG8->(BG8_CODINT+"."+BG8_CODGRU)+; //"Co-Participacao "
               " - "+AllTrim(BG7->BG7_DESCRI)+STR0013+BG8->BG8_CODPAD+"-"+AllTrim(BG8->BG8_CODPSA)+" "+; //"  Procedimento  "
               AllTrim(Posicione("BR8",1,xFilial("BR8")+BG8->(BG8_CODPAD+BG8_CODPSA),"BR8_DESCRI"))

cMenu   := 3
aRotina := MenuDef()

//��������������������������������������������������������������������������Ŀ
//� Ponto de entrada para adicionar itens ao arotina...                      �
//����������������������������������������������������������������������������
If ExistBlock("PL480RT4")
	aAuxRot := ExecBlock("PL480RT4",.F.,.F.,)
	If Valtype(aAuxRot) == "A" 
		If Len(aAuxRot) > 0
			For i := 1 To Len(aAuxRot)
				Aadd(aRotina, aAuxRot[i])
			Next                                                                                         
		Endif
	Endif
Endif
               
//��������������������������������������������������������������������������Ŀ
//� Executa filtro e monta browse...                                        �
//����������������������������������������������������������������������������
BHK->(DbSetOrder(1))   
DbSelectArea("BHK")
SET FILTER TO &cFil
BHK->(MsSeek(xFilial("BHK")))
BHK->(dbSetorder(1))
BHK->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BHK",,,,,,,,,,, .T. ))
BHK->(DbClearFilter())
//��������������������������������������������������������������������������Ŀ
//� Restaura dados...                                                       �
//����������������������������������������������������������������������������
cCadastro := cOldCad
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                        �
//����������������������������������������������������������������������������
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �05/01/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	LOCAL aAuxRot := {}
	LOCAL i

	If cMenu == 0
		Private aRotina := { 	{ STR0001	, 'AxPesqui' , 0 , K_Pesquisar  , 0, .F.},; //'Pesquisar' //"Pesquisar"
		{ STR0002	, 'PL480MOV' , 0 , K_Visualizar , 0, Nil},; //'Visualizar' //"Visualizar"
		{ STR0003	, 'PL480MOV' , 0 , K_Incluir    , 0, Nil},; //'Incluir' //"Incluir"
		{ STR0004	, 'PL480MOV' , 0 , K_Alterar    , 0, Nil},; //'Alterar' //"Alterar"
		{ STR0005	, 'PL480MOV' , 0 , K_Excluir    , 0, Nil},; //'Excluir' //"Excluir"
		{ STR0006	, 'PL480PRO' , 0 , K_Proced     , 0, Nil},; //"Procedimentos"
		{ STR0008 	, 'PL480CLO' , 0 , K_Copiar     , 0, Nil} } //"Clonar"
	Elseif cMenu == 1
		Private	aRotina   := { { STR0001	,"AxPesqui" , 0 , K_Pesquisar  },; //'Pesquisar' //"Pesquisar"
		{ STR0002	,"AxVisual" , 0 , K_Visualizar },; //'Visualizar' //"Visualizar"
		{ STR0003	,"PLSA480INC(cFil,nOpc)" , 0 , K_Incluir    },; //'Incluir' //"Incluir"
		{ STR0004	,"PLSA480ALT(cFil,nOpc)" , 0 , K_Alterar    },; //'Alterar' //"Alterar"
		{ STR0005	,"AxDeleta" , 0 , K_Excluir    },; //'Excluir' //"Excluir"
		{ STR0009	,"PL480COP" , 0 , K_CoPart     }} //"Co-Participacao"  
		aadd(aRotina,{ OemtoAnsi(STR0029)	,'PlVigMenu',0,K_Alterar})		//"Period. Dif. Idade"
	Elseif cMenu == 2
		Private aRotina := { 	{ STR0001	, 'AxPesqui' , 0 , K_Pesquisar  , 0, .F.},; //'Pesquisar' //"Pesquisar"
		{ STR0002	, 'PL480MOV' , 0 , K_Visualizar , 0, Nil},; //'Visualizar' //"Visualizar"
		{ STR0003	, 'PL480MOV' , 0 , K_Incluir    , 0, Nil},; //'Incluir' //"Incluir"
		{ STR0004	, 'PL480MOV' , 0 , K_Alterar    , 0, Nil},; //'Alterar' //"Alterar"
		{ STR0005	, 'PL480MOV' , 0 , K_Excluir    , 0, Nil},; //'Excluir' //"Excluir"
		{ STR0006	, 'PL480PRO' , 0 , K_Proced     , 0, Nil},; //"Procedimentos"
		{ STR0008 	, 'PL480CLO' , 0 , K_Copiar     , 0, Nil},; //"Clonar"
		{ STR0001	,"AxPesqui" , 0 , K_Pesquisar  },; //'Pesquisar' //"Pesquisar"
		{ STR0002	,"AxVisual" , 0 , K_Visualizar },; //'Visualizar' //"Visualizar"
		{ STR0003	,"PLSA480INC(cFil,nOpc)" , 0 , K_Incluir    },; //'Incluir' //"Incluir"
		{ STR0004	,"PLSA480ALT(cFil,nOpc)" , 0 , K_Alterar    },; //'Alterar' //"Alterar"
		{ STR0005	,"AxDeleta" , 0 , K_Excluir    },; //'Excluir' //"Excluir"
		{ STR0009	,"PL480COP" , 0 , K_CoPart     },; //"Co-Participacao" 
        { STR0001	,'AxPesqui' , 0 , K_Pesquisar  },; //'Pesquisar' //"Pesquisar"
        { STR0002	,'AxVisual' , 0 , K_Visualizar },; //'Visualizar' //"Visualizar"
        { STR0003	,'TudoOkBHK', 0 , K_Incluir    },; //'Incluir' //"Incluir"  'AxInclui'
        { STR0004	,'TudoOkBHK' , 0 , K_Alterar    },; //'Alterar' //"Alterar"
        { STR0005	,'AxDeleta' , 0 , K_Excluir    } }  

		aadd(aRotina,{ OemtoAnsi(STR0029)	,'PlVigMenu',0,K_Alterar})		//"Period. Dif. Idade"
	Elseif cMenu == 3
       Private aRotina :=  { { STR0001	,'AxPesqui' , 0 , K_Pesquisar  },; //'Pesquisar' //"Pesquisar"
                        { STR0002	,'AxVisual' , 0 , K_Visualizar },; //'Visualizar' //"Visualizar"
                        { STR0003	,'TudoOkBHK', 0 , K_Incluir    },; //'Incluir' //"Incluir"  'AxInclui'
                        { STR0004	,'TudoOkBHK' , 0 , K_Alterar    },; //'Alterar' //"Alterar"
                        { STR0005	,'AxDeleta' , 0 , K_Excluir    } } //'Excluir' //"Excluir"
    EndIf

	//��������������������������������������������������������������������������Ŀ
	//� Ponto de entrada para adicionar itens ao arotina...                      �
	//����������������������������������������������������������������������������
	If ExistBlock("PL480RT1")
		aAuxRot := ExecBlock("PL480RT1",.F.,.F.,)
		If Valtype(aAuxRot) == "A" 
			If Len(aAuxRot) > 0
				For i := 1 To Len(aAuxRot)
					Aadd(aRotina, aAuxRot[i])
				Next
			Endif
		Endif
	Endif
Return(aRotina)        

/*/{Protheus.doc} PlVigMenu
Menu Period. Dif. Idade
@author Roberto Barbosa
@since 04/2019
/*/
Function PlVigMenu()
	PlVigDifId("BG8","BG8->(BG8_FILIAL+BG8_CODINT+BG8_CODGRU+BG8_CODPAD+BG8_CODPSA+BG8_NIVEL)",BG8->BG8_DIFIDA)
Return
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA010   �Autor  �Microsiga           � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funca de validacao das datas de vigencia, chamada no       ���
���          � botao de OK da Rotina Cobertura / Co-Participacao.         ���
���          � Tabela - BHK - Grupo Cob x Co-participacao. 				  ���
�������������������������������������������������������������������������͹��
���Uso       � PLS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TudoOkBHK(cAlias,nReg,nOpc)
Local nRet  := 0

Private INCLUI := .F.
Private ALTERA := .F.
Private EXCLUI := .F.

If nOpc == K_Incluir
	//INCLUSAO
	INCLUI := .T.
	ALTERA := .F.
	EXCLUI := .F.
	
	nRet   := AxInclui(cAlias,nReg,K_Incluir,,,,"PlsVldBHK(cAlias,nReg,nOpc)")     
ElseIf nOpc == K_Alterar
	//ALTERACAO
	INCLUI := .F.
	ALTERA := .T.
	EXCLUI := .F.
	
	nRet   := AxAltera(cAlias,nReg,K_Alterar,,,,,"PlsVldBHK(cAlias,nReg,nOpc)")  

EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PlsVldBHK �Autor  �Microsiga           � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funca de validacao das datas de vigencia, chamada no       ���
���          � botao de OK da Rotina Cobertura / Co-Participacao.         ���
���          � Tabela - BHK - Grupo Cob x Co-participacao. 				  ���
�������������������������������������������������������������������������͹��
���Uso       � PLS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function PlsVldBHK(cAlias,nReg,nOpc)
Local lRet    := .f.

If BHK->( FieldPos("BHK_VIGINI") ) > 0 .And. BHK->( FieldPos("BHK_VIGFIN") ) > 0
   if ! Empty(M->BHK_VIGFIN) .And. M->BHK_VIGINI > M->BHK_VIGFIN
	MsgAlert("Vig�ncia final menor que a inicial!")
   else
	lRet := .t.
   endif
EndIf

Return(lRet) 
