#INCLUDE "CFGX056.CH"

//-- Manuten��o Mashups
Function CFGX056()
Local nPos
Local aContry  := {}
Local cCountry := ""

If cPaisLoc <> "BRA"
	aContry := GetCountryList()
	If (nPos := Ascan( aContry, { |x| x[1] == cPaisLoc } )) > 0
		cCountry := aContry[nPos,2]
	EndIf
	MsgStop( STR0001 + cCountry) // "Op��o indispon�vel para a localiza��o "
	Return
EndIf

Return APCFG10("#SXV")