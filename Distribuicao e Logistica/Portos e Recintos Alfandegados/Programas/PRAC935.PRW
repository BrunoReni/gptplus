#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC935.CH"

/*/{Protheus.doc} PRAC935 
Metodo construtor da classe
@author   Marcio Franklin Carvalho de Noronha
@version  P12
@since    24/07/2012
@obs      Documentação do sistema
/*/

Function PRAC935()
	Local oDlg          := nil                       //Janela
	Local oLayer        := nil                       //Layout
	Local aCoors        := FWGetDialogSize(oMainWnd) //Coordenada da janela
	Local oPanelFiltro
	Local oPanelBottom
	Local oList
	Local oTButtonSair
	local nX            := 0
	Local cQuery        := "select dbo_desc, dbo_local from " + RETSQLNAME("DBO") + " WHERE DBO_FILIAL='"+xFilial("DBO")+"' AND D_E_L_E_T_ <> '*' ORDER BY DBO_ORD"

	Private cAlias      := SGetNAlias()
	Private aItems      := {}
	Private aFiles      := {}
	private aDirNome    := {}
	private aDirPath    := {}
	private cDescr      := nil
	private cLocal      := nil
	private nCont       := 0
	private cPath       := ""
	private oListArq
	private nList       := 1
	private nListFiles  := 1


	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]
       cDescr := nil
	   	cLocal := nil
	   	nCont  := 0

		oLayer := FWLayer():new() //Cria uma camada na janela
		oLayer:init(oDlg,.F.)
		oLayer:addColumn('Col01',100,.F.) //Adiciona uma coluna na camada
        oLayer:addWindow('Col01','C1_Win01',STR0002,38 /*tamanho em %*/,.T.,.F.,,,)
		oLayer:addWindow('Col01','C1_Win02',STR0003,48 /*tamanho em %*/,.T.,.T.,,,)
		oLayer:addWindow('Col01','C1_Win03','',14 /*tamanho em %*/,.T.,.T.,,,)

        oPanelFiltro    := oLayer:getWinPanel('Col01','C1_Win01')
	 	oPanelResultado := oLayer:getWinPanel('Col01','C1_Win02')
		oPanelBottom    := oLayer:getWinPanel('Col01','C1_Win03')

		RETSQLNAME("SD2")

	   	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAlias,.T.,.F.)
	   	while ((cAlias)->(!EOF()))
	   	    nCont  := nCont + 1
	   		cDescr := ((cAlias)->DBO_DESC)
	   		cLocal := ((cAlias)->DBO_LOCAL)

	   		cDescr := STrim(cDescr) + ' - ' + STrim(cLocal)

	   		Aadd(aDirNome,cDescr)
	   		Aadd(aDirPath,cLocal)
	   		DBSkip()
	   	enddo

		oList:= tListBox():New(10,10,{|u|if(Pcount()>0,nList:=u,nList)} ,aDirNome,100,100,{||R935CHANGE(nList,.T.)},oPanelFiltro,,,,.T.,,)
		oList:Align := 5 //CONTROL_ALIGN_ALLCLIENT

		oListArq:= tListBox():New(10,10,{|u|if(Pcount()>0,nListFiles:=u,nListFiles)} ,aFiles,100,100,,oPanelResultado,,,,.T.,,{||R935OPEN(nListFiles)})
		oListArq:Align := 5 //CONTROL_ALIGN_ALLCLIENT

		oTButtonAbrir := TButton():Create( oPanelBottom,01,01,STR0006,{||R935OPEN(nListFiles)} ,40,10,,,,.T.,,,,,,)
		oTButtonSair  := TButton():Create( oPanelBottom,01,42,STR0004,{||oDlg:end()}      ,40,10,,,,.T.,,,,,,)

       if (oList:Len()) > 0
          R935CHANGE(1,.F.)
       endif

	   ACTIVATE MSDIALOG oDlg CENTERED

	   oList := nil
	   oListArq := nil
	   aItems := nil
return

//-------------------------------------------------------------------
/*/{Protheus.doc} R935CHANGE
Carrega diretórios do 'DBO - Cadastro de Localização de Documentos do Sistema SARA'

@param nList Variavel que contem o numero do documento selecionado.
@param nShowErro

@author  Marcio Franklin Carvalho de Noronha
@since   24/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function R935CHANGE(nList, nShowErro)
   Local cDiretorio  := ""
	Local cDirOpen    := ""
   Local nX
	Local cArquivo := STrim(cDirOpen)
	Local nLinhas

	oListArq:Reset()

	aItems := {}

	if IsSrvUnix()
		if right(STrim(cDirOpen),1) != "/"
			cDirOpen += "/"
		endif
	else
		if right(STrim(cDirOpen),1) != "\"
			cDirOpen += "\"
		endif
	endif

	cArquivo += (Strim(aDirPath[nList]))

	if IsSrvUnix()
	   if right(STrim(cArquivo),1) != "/"
			cArquivo += "/"
		endif
	else
		if right(STrim(cArquivo),1) != "\"
			cArquivo += "\"
		endif
	endif      

	cPath := cArquivo

	cArquivo += "*.*"

	aFiles     := Directory(cArquivo,,nil,.F.)
	nCount     := Len( aFiles )

	if nCount == 0
	  if nShowErro == .T.
         Alert(STR0005)
      endif
      return .F.
    endif

	if nCount > 0
		For nX := 1 to nCount
			Aadd(aItems,aFiles[nX,1])
		Next

		oListArq:SetItems(aItems)
	endif

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} R935OPEN
Carrega arquivos do diretório selecionado pelo usuario.

@param nListFiles Variavel que contem o numero do documento selecionado.

@author  Marcio Franklin Carvalho de Noronha
@since   24/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Static Function R935OPEN(nListFiles)
	Local cDir
	Local cDirTemp
	Local cArq := ''

	if Len(aItems) == 0
	   return .F.
	endif

	if nListFiles == 0
	   nListFiles := 1
	endif

	cDir     := cPath+aItems[nListFiles]
	cDirTemp := GetTempPath()+aItems[nListFiles]

	if GetRemoteType() == 5 //Verifica se é WEB ou Desktop
		CpyS2TW(cDir , .T.) //WEB
    	//CPYS2TW(cDir , .T.) //WEB
    else
    	CpyS2T(cDir, GetTempPath(), .F. ) //Desktop
    	shellExecute( "Open", cDirTemp, "", GetTempPath(),1)
    endif

return .T.
