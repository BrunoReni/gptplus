/*/{PROTHEUS.DOC} LOCA019.PRW  
ITUP BUSINESS - TOTVS RENTAL
PONTO DE ENTRADA PARA VALIDACAO DA MEDICAO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

FUNCTION LOCA019()
LOCAL _LRET 	:= .T.
_CTIPOX 		:= PARAMIXB[1]
_COSSAIDA		:= PARAMIXB[2]
_COSENTRA		:= PARAMIXB[3]
_NCONANT		:= PARAMIXB[4]
_NPOSCONT		:= PARAMIXB[5]

IF _CTIPOX == "L"
	IF EMPTY(_COSSAIDA) .OR. EMPTY(_COSENTRA)
		//MSGALERT("FALTA INFORMAR A OS RELACIONADA.","ATEN��O !")
		//_LRET := .F.
	ENDIF
ENDIF

RETURN _LRET

