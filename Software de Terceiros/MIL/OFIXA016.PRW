// 浜様様様曜様様様様�
// � Versao � 23     �
// 藩様様様擁様様様様�
#include "PROTHEUS.CH"
#include "OFIXA016.CH"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFIXA016 � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Liberacao de Credito do Orcamento de Pecas e Servicos                  咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                               咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIXA016()
Private cCadastro := STR0001 // Libera艫o de Cr�dito
Private cMotivo := "000012"  // Filtro da consulta do motivo
Private aRotina   := MenuDef()
//
FilBrowse('VS1',{},'VS1_STATUS == "3"') 	// Filtra as compras
//
mBrowse( 6, 1,22,75,"VS1")
//
Return
return .t.
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFIXA016 � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Liberacao de Credito do Orcamento de Pecas e Servicos                  咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                               咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OXA016R()

aMotCancel := {}
dbSelectArea("VS0")
dbGotop()
DBSelectArea("VS1")
if !MsgYesNo(STR0006,STR0007)
	return .f.
endif      

// Ponto de entrada chamado apos clicar em Reabrir Or�amento
if ExistBlock("OX016ARE")
   lRetorn := ExecBlock("OX016ARE",.f.,.f.)
   if !lRetorn 
		return .f.
   Endif
Endif

// Pergunta o Motivo de reabertura/negacao do credito. 
if GetNewPar("MV_MIL0012","0") $ "1"
	aMotCancel := OFA210MOT(cMotivo,"4",VS1->VS1_FILIAL,VS1->VS1_NUMORC,.T.)
	If Len(aMotCancel) == 0
		Return(.f.)
	EndIf
	RecLock("VS1",.f.) 
	VS1->VS1_MOTCRD := aMotCancel[1]
	MsUnlock()
Endif
DBClearFilter()
OXI001REVF(VS1->VS1_NUMORC, "0")
FilBrowse('VS1',{},'VS1_STATUS == "3"') 	// Filtra as compras
return .t.

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OXA016V  � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Montagem da Janela de Orcamento de Pecas e Servicos                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                               咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OXA016V(cAlias,nReg,nOpc)
Local lRet := .f.
//
DBSelectArea("VS1")
dbClearFilter()           // CLAUDIA
lRet = OFIXX001(,,,nOpc)
FilBrowse('VS1',{},'VS1_STATUS == "3"') 	// Filtra as compras
//
Return .t.

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OXA016M  � Autor � Manoel                            � Data � 05/08/10 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Mostra Posicao do Cliente e motivo do Pedido de Liberacao              咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                               咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OXA016M()
//

PutMv("MV_CKCLIXX","")
DBSelectArea("VS1")
FG_CKCLINI(VS1->VS1_CLIFAT+VS1->VS1_LOJA,.t.,.t.)

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OXA016V  � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Montagem da Janela de Orcamento de Pecas e Servicos                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                               咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OXA016L(cAlias,nReg,nOpc)
//
if ExistBlock("OXA016LB")
	if !ExecBlock("OXA016LB",.f.,.f.)
		Return(.f.)
	Endif
Endif
DBSelectArea("VS1")
if !MsgYesNo(STR0008,STR0007)
	return .f.
endif
if !MsgYesNo(STR0009,STR0007)
	return .f.
endif
dbClearFilter()           // CLAUDIA

DbSelectArea("VAI")
Dbsetorder(4)
if !DbSeek(xFilial("VAI")+__cUserID)
	MsgStop(STR0021,STR0007)		
	Return(.f.)
Endif

if VAI->(FieldPos("VAI_ALLBCR")) > 0  
	if VAI->VAI_ALLBCR > 0 
		if VAI->VAI_ALLBCR < VS1->VS1_VTOTNF
			MsgStop(STR0020,STR0007)		
			Return(.f.)
		Endif
	Endif
Endif
                              
cMotVSW := space(TamSX3("VSW_MOTIVO")[1])
nOpca := 0

DEFINE MSDIALOG oDlgMot TITLE OemtoAnsi(STR0015) FROM  01,11 TO 08,76 OF oMainWnd

oTPanelLib := TPanel():New(0,0,"",oDlgMot,NIL,.T.,.F.,NIL,NIL,0,08,.T.,.F.)
oTPanelLib:Align := CONTROL_ALIGN_ALLCLIENT

@ 005,003 SAY STR0016 SIZE 170,40  Of oTPanelLib PIXEL 
@ 005,030 MSGET oMotivo VAR cMotVSW PICTURE "@!" SIZE 200,4 OF oTPanelLib PIXEL COLOR CLR_BLUE 

ACTIVATE MSDIALOG oDlgMot ON INIT EnchoiceBar(oDlgMot,{||nOpca := 1,oDlgMot:End()},{||nOpca := 0,oDlgMot:End()}) CENTER

if nOpca == 0
	Return(.f.)
Endif

DBSelectArea("VAI")
DBSetOrder(6)
DBSeek(xFilial("VAI")+VS1->VS1_CODVEN)

cFases := OI001GETFASE(VS1->VS1_NUMORC)
nPos := At("3", cFases)
cProxStat := subs(cFases,nPos+1,1)
DBSelectArea("VS1")
reclock("VS1",.f.)
cVS1StAnt := VS1->VS1_STATUS
VS1->VS1_STATUS := cProxStat
msunlock()
If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
	OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0001 ) // Grava Data/Hora na Mudan�a de Status do Or�amento / Libera艫o de Cr�dito
EndIf
If FindFunction("FM_GerLog")
	//grava log das alteracoes das fases do orcamento
	FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cVS1StAnt)
EndIF
//
aRet012 := OFIXI001(VS1->VS1_NUMORC)
cMsgFase := aRet012[1]
lRollback := aRet012[2]
lRollObrig := aRet012[3]
lAbortProc := aRet012[4]

if cMsgFase != ""
	MsgInfo(cMsgFase,STR0012)
	if VS1->VS1_STATUS == "O" .or. ;
	(VS1->VS1_STATUS == "R" .and. lAbortProc)
		MsgInfo(STR0013,STR0012)
		reclock("VS1",.f.)
		cVS1StAnt := VS1->VS1_STATUS
		VS1->VS1_STATUS := "3"
		msunlock()
		If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
			OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0001 ) // Grava Data/Hora na Mudan�a de Status do Or�amento / Libera艫o de Cr�dito
		EndIf
		If FindFunction("FM_GerLog")
			//grava log das alteracoes das fases do orcamento
			FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cVS1StAnt)
		EndIF
		Return .f.
	endif
endif

DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFIlial("SA1")+VS1->VS1_CLIFAT + VS1->VS1_LOJA)
DBSelectArea("VSW")
RecLock("VSW",.t.)
VSW_FILIAL := xFilial("VSW")
VSW_CODCLI := SA1->A1_COD
VSW_LOJA   := SA1->A1_LOJA
VSW_VALCRE := VS1->VS1_VTOTNF
VSW_ORIGEM := FunName()
VSW_RISANT := SA1->A1_RISCO
VSW_LCANT  := SA1->A1_LC
VSW_VLCANT := SA1->A1_VENCLC
VSW_USUARI := VAI->VAI_NOMUSU 
if VS1->(FieldPos("VS1_DTHRPL")) > 0
	VSW_DATHOR := VS1->VS1_DTHRPL 
Endif	
VSW_USULIB := Subs(cUsuario,7,15)
VSW_DTHLIB := Dtoc(dDataBase)+"-"+Left(Time(),5)
VSW_NUMORC  := VS1->VS1_NUMORC  
if nOpca == 1
	VSW_MOTIVO := cMotVSW
Endif
MsUnlock()

MsgInfo(STR0010,STR0007)

//Ponto de entrada para que o cliente possa alterar informa苺es da VS1. 
if ExistBlock("OX016GLB")
	ExecBlock("OX016GLB",.f.,.f.)
Endif
//
OX001LDOFI(VS1->VS1_NUMORC)
//
FilBrowse('VS1',{},'VS1_STATUS == "3"') 	// Filtra as compras
Return .t.


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OXA016P  � Autor � Thiago						    � Data � 04/09/14 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Posicao do cliente.									                  咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                               咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OXA016P(cAlias,nReg,nOpc)

DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFilial("SA1")+VS1->VS1_CLIFAT + VS1->VS1_LOJA)  
FC010CON() // Tela de Consulta -> Posicao do Cliente

Return .t.

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � MenuDef  � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Menu (AROTINA) - Orcamento de Pecas e Servicos                         咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                               咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef() 
Local aRecebe := {}
Local aRotina := {	{ STR0002, "axPesqui",    0, 1},;    // "Pesquisar"
{ STR0003, "OXA016V"  , 0, 2},;    // "Visualizar"
{ STR0011, "OXA016R"  , 0, 2},;    // "Reabrir"
{ STR0014, "OXA016M"  , 0, 2},;    // "Verificar Motivo"
{ STR0004, "OXA016L"  , 0, 4},;    // Liberar
{ STR0019, "OXA016P"  , 0, 4}}    // Posicao do cliente    

If ExistBlock("OX016ROT")
	aRecebe := ExecBlock("OX016ROT",.f.,.f.,{aRotina} )
	If ( ValType(aRecebe) == "A" )
		aRotina := aClone(aRecebe)
	EndIf
Endif

Return aRotina

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    �OXA16NCRED  | Autor � Thiago              � Data � 05/08/13 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Consulta motivo da reabertura/negacao do credito.		  咳�
臼�          � tempo                                                      咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�Nenhum                                                      咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OXA16NCRED()  
Local cMsg := ""

cQuery := "SELECT VS0.R_E_C_N_O_ RECVS0 "
cQuery += "FROM "
cQuery += RetSqlName( "VS0" ) + " VS0 " 
cQuery += "WHERE " 
cQuery += "VS0.VS0_FILIAL='"+ xFilial("VS0")+ "' AND VS0.VS0_TIPASS = '000012' AND VS0.VS0_CODMOT = '"+VS1->VS1_MOTCRD+"' AND "
cQuery += "VS0.D_E_L_E_T_=' '"                                             

nVS0 := FM_SQL(cQuery)
dbSelectArea("VS0")
Dbgoto(nVS0)
                       
cMsg := VS0->VS0_CODMOT+" - "+VS0->VS0_DESMOT                  

DEFINE MSDIALOG oDlgMot TITLE STR0018 From 20,115 to 40,200 of oMainWnd

@ 002,002 GET oMsg VAR cMsg OF oDlgMot MEMO SIZE 333,120 PIXEL READONLY MEMO FONT (TFont():New('Courier New',0,-11,.T.,.T.))
DEFINE SBUTTON FROM 130,290 TYPE 2 ACTION (nOpca := 0,oDlgMot:End()) ENABLE OF oDlgMot

ACTIVATE MSDIALOG oDlgMot 
           
Return(.t.)
