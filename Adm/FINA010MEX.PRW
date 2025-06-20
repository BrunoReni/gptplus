#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'FINA010.ch'

#DEFINE SOURCEFATHER "FINA010"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010MEX
Cadastro de Natureza localizado para M�XICO.

O fonte cont�m browse, menu, model e view propria, todos herdados do FINA010. 
Qualquer regra que se aplique somente para o M�XICO deve ser definida aqui.

As valida��es e integra��es realizadas ap�s/durante a grava��o est�o definidas nos eventos do modelo, 
na classe FINA010EVMEX.

@type function
 
@author Rodrigo Oliveira
@since 18/05/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Function FINA010MEX()
Local oBrowse As Object
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Define o browse padr�o para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 18/05/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse As Object 
	
	oBrowse := FwLoadBrw(SOURCEFATHER) 

Return oBrowse
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o model padr�o para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 18/05/2017
@version P12.1.17 
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel As Object
Local oEvent As Object
	
	oModel := FWLoadModel(SOURCEFATHER)
	oEvent := FINA010EVMEX():New()
	oModel:InstallEvent("MEXICO",,oEvent)
	
Return oModel
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view padr�o para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 18/05/2017
@version P12.1.17 
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView As Object

	oView := FWLoadView(SOURCEFATHER)

Return oView

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu padr�o para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 18/05/2017
@version P12.1.17 
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	As Array 
Local cStcFunc	As Character

	aRotina  := FWLoadMenuDef(SOURCEFATHER)
	cStcFunc := 'StaticCall(FINA010MEX, F010SldCTb)'
	aAdd(aRotina, { STR0011, cStcFunc, 0, 2  } ) //"Saldos Cont�beis"
	
Return aRotina
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F010SldCtb
Cadastro de Natureza localizado para M�XICO.

Botoes especificos da consulta de naturezas: Saldo da conta contabil relacionada a Natureza

@type function
 
@author Mauricio Pequim Jr
@since 23.11.2009
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function F010SldCtb()

LOCAL oDlg As Object

If !Empty (SED->ED_CONTA)
	
	//Saldo da conta contabil relacionada a Natureza
	//Saldo inicial ( ultimo dia do mes anterior )
	bSldCTBAnt	:= {||SaldoCT7(SED->ED_CONTA,FirstDay(dDatabase)-1,"01")}
	//Saldo atual ( database )
	bSldCTBAtu	:= {||SaldoCT7(SED->ED_CONTA,dDatabase,"01")}
	
	//������������������������������������������������������Ŀ
	//� Retorno SaldoCT7:                                    �
	//� [1] Saldo Atual (com sinal)                          �
	//� [2] Debito na Data                                   �
	//� [3] Credito na Data                                  �
	//� [4] Saldo Atual Devedor                              �
	//� [5] Saldo Atual Credor                               �
	//� [6] Saldo Anterior (com sinal)                       �
	//� [7] Saldo Anterior Devedor                           �
	//� [8] Saldo Anterior Credor                            �
	//��������������������������������������������������������
	
	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario na EnchoiceBar                              �
	//��������������������������������������������������������������������������
	If ExistBlock( "F010BUT" )
		bSldCTBAnt := ExecBlock( "F010BUT", .F., .F.,{1} )
		bSldCTBAtu := ExecBlock( "F010BUT", .F., .F.,{2} )
	EndIf
	
	aSaldosAnt := Eval(bSldCTBAnt)
	aSaldosAtu := Eval(bSldCTBAtu)
		
	cSalAnt :=  ValorCtb(aSaldosAnt[1],0,0,17,2,.T.,,,SED->ED_CONTA,,,,,.T.,.F.)
	cMovPer :=  ValorCtb(aSaldosAtu[1] - aSaldosAnt[1],0,0,17,2,.T.,,,SED->ED_CONTA,,,,,.T.,.F.)
	cSalAtu := 	ValorCtb(aSaldosAtu[1],0,0,17,2,.T.,,,SED->ED_CONTA,,,,,.T.,.F.)
	
	DEFINE MSDIALOG oDlg FROM 00,00 TO 120, 300 TITLE STR0012 PIXEL //"Saldo Cont�bil"
	@	003,003 	Say STR0013  OF oDlg PIXEL //"Saldo Anterior: "
	@	003,095	Say cSalAnt OF oDlg PIXEL
	@	015,003 	Say STR0014  OF oDlg PIXEL //"Movimento no periodo: "
	@	015,095	Say cMovPer OF oDlg PIXEL
	@	029,003 	Say STR0015  OF oDlg PIXEL //"Saldo Atual: "
	@	029,095	Say cSalAtu OF oDlg PIXEL
	
	@	001,001 TO 40,150 OF oDlg PIXEL
	
	DEFINE SBUTTON FROM 045,100	TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
Else

   Help("  ",1,"EMPTYCC",,STR0016,1,1) //"Conta cont�bil n�o preenchida para esta natureza"

Endif

Return nil