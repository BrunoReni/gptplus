#INCLUDE "PROTHEUS.CH"
#INCLUDE "PFSLOAD.CH"

Static __aSituac   := {} // Array com as Situa��es da pr�-fatura

//-------------------------------------------------------------------
/*/{Protheus.doc} PFSLOAD()
Rotina para carregar as situa��es no menu de pr�-fatura 

@Return		nil

@author Luciano Pereira dos Santos
@since 07/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PFSLOADEXEC()

	MsgRun(STR0001, ,{|| JurSitLoad()} ) // "Carregando situa��es..."
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}  JurSitLoad()
Rotina para carregar o array de situa��es de pr�-fatura 

@Return	 nil

@author Luciano Pereira dos Santos
@since 07/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSitLoad()
Local aSX5 := {}
Local nI   := 0
Local nSX5 := 0

If Empty(__aSituac)

	aSX5 := FWGetSX5( "JS" )
	nSX5 := Len(aSX5)

	If nSX5 > 0
		For nI := 1 To nSX5 
			aAdd(__aSituac, {Alltrim(aSX5[nI][3]), Capital(Alltrim(aSX5[nI][4]))} )
		Next nI
	Else
		aAdd(__aSituac, {"",""} )
	EndIf

EndIf

Return (__aSituac)

//-------------------------------------------------------------------
/*/{Protheus.doc}  JurSitGet()
Rotina para recuperar a descri��o de uma situa��o contida no array de 
situa��es de pr�-fatura. 

@param     cCodSit  - C�digo da chave da tabela de situa��o de pr�-fatura. 

@Return    cRet     - Descri��o da Situa��o

@author Luciano Pereira dos Santos
@since 07/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSitGet(cCodSit)
Local nPos := 0
Local cRet := ""

Default cCodSit := ''

If !Empty(cCodSit)
	If (nPos := aScan( __aSituac, {|x| x[1] == cCodSit} ) ) > 0

		cRet := __aSituac[nPos][2]

	EndIf
EndIf

Return cRet
