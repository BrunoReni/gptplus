#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog
Classe para exibição de um painel com filtros selecionados
Generico

@author siegklenes.beulke
@since 12/03/15
@version 1.0
/*///------------------------------------------------------------------------------------------------
CLASS PRAPnlFiltr
	DATA oOwner //tÍTULO
	DATA aList
	DATA aListSay
	DATA nNumList
	DATA lHasUpdate
	DATA oDefSize
	DATA oSayTitulo
	DATA cTituloFiltro
	DATA nAjustLin // Percentual de ajuste da linha
	DATA nAjustCol // Percentual de definição do espaçamento entre os objetos
	//DATA nAjustHorz // Ajuste do espaçamento horizontal dos objetos
	DATA lPrepared
	// Declaração dos Métodos da Classe
	METHOD New(oOwner, aList,cTituloFiltro) CONSTRUCTOR
	METHOD AddItem(cStr,nPos)
	METHOD SetList(aList)
	METHOD Build()
	METHOD Destroy()
	METHOD Prepare()
ENDCLASS


/*/{Protheus.doc} New
(long_description)
@author siegklenes.beulke
@since 12/03/2015
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
METHOD New(oOwner, aList,cTituloFiltro) Class PRAPnlFiltr 
	::aListSay := {}
	::nNumList := 0
	::cTituloFiltro := cTituloFiltro
	::nAjustLin := 50
	::nAjustCol := 25
	//::nAjustHorz:= 20
	::aList := aList
	::lPrepared := .F.
	::oOwner := TGroup():New(0,0,0,0,::cTituloFiltro,oOwner,,,.T.)
	::oOwner:Align := CONTROL_ALIGN_ALLCLIENT
	
	//	oGroup1:= TGroup():New(5,02,30,50,'Filtros',oDlg,,,.T.)
Return Self

METHOD SetList(aList) Class PRAPnlFiltr
	Local nX
	For nX := 1 to Len(::aListSay)
		If !Empty(::aListSay[nX][3])
			::aListSay[nX][2]:= ""
			::aListSay[nX][3]:SetText("")
		EndIf
	Next nX
	If ValType(aList) == "A"
		For nX := 1 To Len(aList)
			::AddItem(aList[nX],nX)
		Next nX
	EndIf
Return


METHOD AddItem(cStr,nPos) Class PRAPnlFiltr
	Default nPos := 0
	
	If nPos == 0 .Or. nPos > ::nNumList
		::nNumList++
		If nPos == 0
			aAdd(::aListSay,{cValToChar(Len(::aListSay)+1),cStr,})
		Else
			aAdd(::aListSay,{cValToChar(nPos),cStr,})
		EndIf
	Else
		::aListSay[nPos][2] := cStr
		If !Empty(::aListSay[nPos][3])
			::aListSay[nPos][3]:SetText(cStr)
		EndIf
	EndIf
Return

METHOD Build() Class PRAPnlFiltr
	Local nX
	Local aSz
	Local nAjust := (::oOwner:nClientHeight/3.5) * (::nAjustLin/100) // ALTERAR A DIVISÃO DO NCLIENT
	Local nAjustHorz := 2
	If !::Prepare()
//		MsgInfo("Class PRAPnlFiltr : Método prepare() não executado com sucesso")
//		Return
	EndIf
	
	::oOwner:FreeChildren()
	::oOwner:Refresh()
	
	::oDefSize:Process()
		
	aSz := {	::oDefSize:GetDimension("Titulo","COLINI"),;
				::oDefSize:GetDimension("Titulo","COLEND"),;
				::oDefSize:GetDimension("Titulo","LININI"),;
				::oDefSize:GetDimension("Titulo","LINEND"),;
				::oDefSize:GetDimension("Titulo","XSIZE"),;
				::oDefSize:GetDimension("Titulo","YSIZE");
				}
//	If Empty(::oSayTitulo)
		::oOwner:cCaption := ::cTituloFiltro
		//TSay():New(aSz[1],aSz[3],&('{||"' + ::cTituloFiltro + '"}'),::oOwner,,,,,,.T.,,,,)
		//::oSayTitulo := TSay():New(aSz[1],aSz[3],&('{||"' + ::cTituloFiltro + '"}'),oGroup,,,,,,.T.,,,,)
//	Else
//		::oSayTitulo:SetText(::cTituloFiltro)
//	EndIf
	
	If ::nNumList > 0
						
		For nX := 1 To ::nNumList
			
			aSz := {::oDefSize:GetDimension(::aListSay[nX][1],"COLINI"),;
						::oDefSize:GetDimension(::aListSay[nX][1],"COLEND"),;
						::oDefSize:GetDimension(::aListSay[nX][1],"LININI"),;
						::oDefSize:GetDimension(::aListSay[nX][1],"LINEND"),;
						::oDefSize:GetDimension(::aListSay[nX][1],"XSIZE"),;
						::oDefSize:GetDimension(::aListSay[nX][1],"YSIZE");
						}
			If Empty(::aListSay[nX][3])
				::aListSay[nX][3] := TSay():New(aSz[1]+nAjust,aSz[3]+nAjustHorz,&('{||"' + ::aListSay[nX][2] + '"}'),::oOwner,,,,,,.T.,,,,)
			Else
				::aListSay[nX][3]:nLeft := aSz[3]+nAjustHorz 
				::aListSay[nX][3]:nTop := aSz[1]+nAjust
			EndIf
		Next
	EndIf
Return

METHOD Destroy() Class PRAPnlFiltr
	aSize(::aListSay,0)
	aSize(::aList,0)
Return

METHOD Prepare() Class PRAPnlFiltr
	Local nTam1 
	Local nTam2 
	Local nX
	
	If Empty(::aList) .And. Empty(::aListSay)
		::lPrepared := .F.
	ElseIf !Empty(::aList) .And. Empty(::aListSay)		
		::SetList(::aList)
		::lPrepared := .T.
	Else
		::lPrepared := .T.
	EndIf
	
	If !Empty(::oDefSize)
		FreeObj(::oDefSize)
		::oDefSize := Nil
	EndIf
	nTam1 := Len(::cTituloFiltro)
	nTam2 := nTam1*3
	::oDefSize := FwDefSize():New( .F., , , , .T. )
//	::oDefSize:AddObject("Titulo", nTam1, nTam2, .F., .F.)
	
	If ::lPrepared
		For nX := 1 To Len(::aListSay)
			nTam1 := Len(::aListSay[nX][2])
			nTam2 := nTam1*(3+(::nAjustCol/100))
			::oDefSize:AddObject(::aListSay[nX][1], nTam1, nTam2, .F., .F.)
		Next nX
		
	EndIf
	
	
Return ::lPrepared