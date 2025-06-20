#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA118
EFD Contribui��es - Descontinuada em Dez/2021
/*/
//-------------------------------------------------------------------
Function TAFA118()
	MsgInfo("Prezado cliente, esta rotina foi descontinuada. O EFD Contribui��es deve ser entregue atrav�s do m�dulo Fiscal de seu ERP principal.")
Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

Constru��o dos pain�is para gera��o do arquivo.

@Return	aRet	-	Parametriza��o necess�ria para a rotina xFunWizard

@Author	Fabio V. Santana
@Since		22/02/2013
@Version	1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()	

Local	aTxtApre	:= {}
Local	aRet		:= {}

aAdd (aTxtApre, "EFD Contribui��es")
aAdd (aTxtApre, "")	
aAdd (aTxtApre, "Aten��o! Rotina descontinuada.")
aAdd (aTxtApre, "Rotina Obsoleta - O EFD Contribui��es deve ser entregue atrav�s do m�dulo Fiscal de seu ERP principal.")

aAdd( aRet, aTxtApre )
aAdd( aRet, {} )
aAdd( aRet, "SPDPISCOF"+FWGETCODFILIAL)
aAdd( aRet, "" )
aAdd( aRet, Nil )
aAdd( aRet, Nil )
aAdd( aRet, { || TAFA118() } )	//Code Block para o bot�o "Finalizar" deve executar a rotina respons�vel pela gera��o do arquivo

Return( aRet )
