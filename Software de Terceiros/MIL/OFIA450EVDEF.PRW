#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA450.CH"

CLASS OFIA450EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD VldActivate()

ENDCLASS


METHOD New() CLASS OFIA450EVDEF
RETURN .T.


// Valida��o antes da Abertura da Tela //
METHOD VldActivate(oModel, cModelId) CLASS OFIA450EVDEF

	Local lRet := .T.
	
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		If OA4500011_ServicoUsado(VPX->VPX_SERINT)
			Help("",1,"DELETE_VPX",,STR0015,1,0) // Servi�o Especializado j� utilizado. Imposs�vel excluir.
			lRet := .f.
		EndIf
	EndIf

RETURN lRet