#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "LaboratoriosInspecaoDeProcessosAPI.CH"

#DEFINE X5_FILIAL     1
#DEFINE X5_TABELA     2
#DEFINE X5_CHAVE      3
#DEFINE X5_DESCRICAO  4

/*/{Protheus.doc} processinspectionlaboratory
API Laboratório da Inspeção de Processos - Qualidade
@author brunno.costa
@since  06/10/2022
/*/
WSRESTFUL processinspectionlaboratory DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ensaios Calculados Inspeção de Processos"
	DATA Login AS STRING
    WSMETHOD GET list;
    DESCRIPTION STR0001; //"Retorna Lista de Laboratórios"
    	WSSYNTAX "api/qip/v1/list/{Login}" ;
	PATH "/api/qip/v1/list" ;
	TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET list PATHPARAM Login WSSERVICE processinspectionlaboratory
	Local aDados      := {}
	Local aQ2SX5      := {}
	Local nIndSX5     := Nil
	Local nTotal      := 1
	Local oAPIManager := QualityAPIManager():New(, Self,)
	Local oItemAPI    := Nil

	Default Self:Login := ""
	
	If oAPIManager:ValidaPrepareInDoAmbiente()
		oAPIManager:AvaliaPELaboratoriosRelacionadosAoUsuario()
		
		aQ2SX5 := FWGetSX5( "Q2" )
		nTotal := Len(aQ2SX5)

		For nIndSX5 := 1 to nTotal
			If aQ2SX5[nIndSX5][X5_FILIAL] == xFilial("SX5")

				If oAPIManager:lPELaboratoriosRelacionadosAoUsuario
					If !oAPIManager:ChecaLaboratorioValidoParaUsuario(Self:Login, "processinspectionlaboratory/api/qip/v1/list", aQ2SX5[nIndSX5][X5_CHAVE])
						Loop
					EndIf
				EndIf

				oItemAPI                   := JsonObject():New()
				oItemAPI["laboratoryCode"] := aQ2SX5[nIndSX5][X5_CHAVE]
				oItemAPI["laboratory"    ] := Acentuacao(aQ2SX5[nIndSX5][X5_DESCRICAO])
				aAdd(aDados, oItemAPI)
			EndIf
		Next
	EndIf
	oAPIManager:RespondeArray(aDados, .F.)
Return 

/*/{Protheus.doc} Acentuacao
Capitaliza e Acentua Dicionário Padrão
@author brunno.costa
@since  07/10/2022
/*/
Static Function Acentuacao(cTitulo)
	Local cReturn := StrTran(Capital(cTitulo), "Laboratorio", "Laboratório")
	cReturn := StrTran(cReturn, "Fisico", "Físico")
Return cReturn
