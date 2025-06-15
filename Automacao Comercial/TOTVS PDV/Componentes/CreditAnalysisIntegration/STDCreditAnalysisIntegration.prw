//-------------------------------------------------------------------
/*/{Protheus.doc} STDFindCart()
Pesquisa o n�mero do cart�o do cliente

@param
@author  Varejo
@version P12
@since   17/03/17
@return  aRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDFindCart()

Local aRet 		:= {}
Local cCart		:= ""
Local aCart		:= {}

If ExistFunc("STBGetCrdIdent")
	aCart := STBGetCrdIdent()		//Busco o n�mero do cart�o
EndIf
If Len(aCart) > 0 .AND. !Empty(aCart[1])
	aAdd(aRet, aCart[1])
EndIf 

Return aRet
