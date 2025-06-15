#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAR903.CH"

/*/{Protheus.doc} PRAR903 
Metodo construtor da classe
@author   Felipe Machado de Oliveira
@version  P12
@since    04/07/2012
@obs      Impressão de layout em branco
/*/
Function PRAR903()
	Local oDlg
	Local oPanelBottom
	Local oList
	Local nList         := 1
	Local oTButtonAbrir
	Local oTButtonSair
	local nX            := 0
	Private aItems      := {}
	Private aFiles      := {}
	private cDiretorio  := ""
	private cDirOpen    := ""

	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,500 PIXEL

		cDiretorio := GetMV("MV_WMSDFS")
		cDirOpen   := cDiretorio

		if IsSrvUnix()
			cDiretorio += "/*.*"     /**/
		else
			cDiretorio += "\*.*"		/**/
		endif

		aFiles     := Directory(cDiretorio,,nil,.F.)
		nCount     := Len( aFiles )

		For nX := 1 to nCount
			Aadd(aItems,aFiles[nX,1])
		Next

		oPanelBottom  := TPanel():Create(oDlg,01,01,"",,,,,,10,15)
		oPanelBottom:Align := 4 //CONTROL_ALIGN_BOTTOM

		oPanelAllClient  := TPanel():Create(oDlg,01,102,"",,,,,,100,100)
		oPanelAllClient:Align := 5 //CONTROL_ALIGN_ALLCLIENT

		oList:= tListBox():New(10,10,{|u|if(Pcount()>0,nList:=u,nList)} ,aItems,100,100,,oPanelAllClient,,,,.T.,,{||R903OPEN(nList)})
		oList:Align := 5 //CONTROL_ALIGN_ALLCLIENT

		oTButtonAbrir := TButton():Create( oPanelBottom,01,01,STR0001,{||R903OPEN(nList)} ,40,10,,,,.T.,,,,,,)
		oTButtonSair  := TButton():Create( oPanelBottom,01,42,STR0002,{||oDlg:end()}      ,40,10,,,,.T.,,,,,,)

	ACTIVATE MSDIALOG oDlg CENTERED

	oList := nil
	aItems := nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} R903OPEN
Abre o arquivo selecionado pelo usuario.

@param nList Variavel que contem o numero do documento selecionado.

@author  Felipe Machado de Oliveira
@since   05/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function R903OPEN(nList)
	Local cArquivo := cDirOpen

	if IsSrvUnix()
		if right(cDirOpen,1) != "/"
			cDirOpen += "/"
		endif
	else
		if right(cDirOpen,1) != "\"
			cDirOpen += "\"
		endif
	endif

	if IsSrvUnix()
		cArquivo += "/"
	else
		cArquivo += "\"
	endif

    If(Len(aItems) > 0)
    	cArquivo += aItems[nList]
	EndIf

	if GetRemoteType() == 5 //Verifica se é WEB ou Desktop
		CpyS2TW(cArquivo, .T.) //WEB
    	//CPYS2TW(cArquivo, .T.) //WEB
    else
        If(Len(aItems) > 0)
        	CpyS2T(cDirOpen+aItems[nList], GetTempPath(), .F. ) //Desktop
        	shellExecute( "Open", GetTempPath()+aItems[nList], "", cDirOpen,1)
    	EndIf
    endif

return .T.
