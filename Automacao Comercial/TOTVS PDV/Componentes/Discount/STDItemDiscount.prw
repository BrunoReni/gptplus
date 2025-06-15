#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STDIDTime
Busca configura��o de momento de desconto por usu�rio, se antes ou despois de registrar o item

@param
@author  Varejo
@version P11.8
@since   23/05/2012
@return  cTime 			Retorna configura��o de momento de efetuar desconto no Item via usu�rio
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDIDTime()

Local cTime		:= "A"		// Retorna configura��o de momento de efetuar desconto no Item via usu�rio
Local aDados	:= {"15", space(20)} // Pega Estatus 15 do ECF para saber se permite desconto apos registrar o item
Local aRet		:= {}

/*/
	"A" - 	Antes (Padrao)
	"D" - 	Depois
/*/


/*/
	Se utiliza impressora fiscal, utiliza
	Verifica se o ECF permite desconto apos registrar o item
/*/
If STFUseFiscalPrinter()

	aRet := STFFireEvent( 	ProcName(0)			,; // Nome do processo
								"STPrinterStatus" 	,; // Nome do evento
								@aDados 				)

	// 0-Arredonda 	1-Trunca
	If !Empty(aRet) .AND. aRet[1] == 1
		cTime := "A" //Antes
	Else
		cTime := "D"	//Depois
	EndIf

EndIf

Return cTime




//-------------------------------------------------------------------
/*/{Protheus.doc} STDIDUseDiscountFrom
Efetua Desconto no Item

@param
@author  Varejo
@version P11.8
@since   23/05/2012
@return  cConfig 			Retorna configura��o de desconto no item quanto a aplicar descontos via usu�rio, via regra ou ambos
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDIDUseDiscountFrom()

Local cConfig		:= ""		// Retorna configura��o de desconto no item quanto a aplicar descontos via usu�rio, via regra ou ambos

/*/
	Fazer Facilitador para configura��o se usa desconto via usu�rio, via regra ou ambos
	"U" - Usu�rio
	"R" - Regra de Desconto
	"A" - Ambos
/*/
cConfig := STFGetCfg("cCtrlDesc")

// Tratamento para corrigir informa��o do par�metro caso venha preenchido com ""
// Necess�rio para n�o alterar boletim t�cnico
If Len(cConfig) > 1
	cConfig := SubStr(cConfig,2,1)
EndIf

Return cConfig


//-------------------------------------------------------------------
/*/{Protheus.doc} STDIDReasonDiscount
Busca configura��o se Registra Motivo de Desconto quando uma Regra de Desconto � aplicada

@param
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet 			Retorna configura��o se Registra Motivo quando uma Regra de Desconto � aplicada
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDIDReasonDiscount()

Local lRet		:= .F.		// Retorna configura��o se Registra Motivo quando uma Regra de Desconto � aplicada

lRet := .T.

Return lRet
