#include "protheus.ch"
#include "AGRAR630B.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define _BL 25
#Define __NTAM1  10
#Define __NTAM2  10
#Define __NTAM3  20
#Define __NTAM4  25

#DEFINE IMP_SPOOL 2
#define DMPAPER_A4 9

Static __oFnt10C  := TFont():New("Arial",10,10,,.F., , , , .T., .F.)
Static __oFnt10N  := TFont():New("Arial",10,10,,.T., , , , .T., .F.)
Static __oFnt14N  := TFont():New("Arial",12,12,,.T., , , , .T., .F.)


/** {Protheus.doc} AGRAR630B
@param: 	Nil
@author: 	marina.muller
@since: 	10/11/2017
@Uso: 		SIGAAGR - Relatorio de Etiquetas
 */
Function AGRAR630B(aParam)

	Local oReport			:= Nil
	Local cDirPrint			:= GetTempPath() // Dir�torio Tempor�rio
	Local lRet 				:= .T.
	Local lAdjustToLegacy 	:= .F.
    Local oSetup
    Local cPerg 	        := "AGRAR630B"
	Local cSession	        := GetPrinterSession()
	Local cDevice           := fwGetProfString(cSession,"PRINTTYPE","PDF",.T.)
	Local cDestino	        := fwGetProfString(cSession,"DEFAULT","c:\",.T.)
	Local nFlags   	        := PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION
	
	Private _cFileName 		:= "AGRAR630B"
	Private _aRet           := {"",""}
	Private _nLweb   		:= 10

    //recebe o filtro passado pelo browse do AGRA630
    Default aParam			:= {}

	If !DXJ->(ColumnPos('DXJ_CODBAR'))
		MsgNextRel() //-- � necess�rio a atualiza��o do sistema para a expedi��o mais recente
		return()
	EndIf

	aDevice := {}
	AADD(aDevice,"DISCO") 
	AADD(aDevice,"SPOOL") 
	AADD(aDevice,"EMAIL") 
	AADD(aDevice,"EXCEL") 
	AADD(aDevice,"HTML" ) 
	AADD(aDevice,"PDF"  )  

	nPrintType := aScan(aDevice,{|x| x == cDevice }) 
	nLocal     := If( fWGetProfString( cSession, "LOCAL", "SERVER", .T. ) == "SERVER", 1, 2 )                                                                                                                                                                                                                          
	                                                                                                                                                                                                                              
    //Habilita o bot�o par�metros do spool de impress�o
	oSetup := FWPrintSetup():New(nFlags,"")
	oSetup:SetUserParms( {|| Pergunte(cPerg, .T.) } )
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , 2) 
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {10,10,10,10})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)
	oSetup:SetPropert(PD_PREVIEW,.T.)
	
	If cDevice == "PDF"
		oSetup:aOptions[PD_VALUETYPE] := cDestino
	EndIf
    
    oReport := FWMSPrinter():New(_cFileName, IMP_SPOOL, lAdjustToLegacy, cDirPrint, .T., ,oSetup, ,.T.)// Ordem obrig�toria de configura��o do relat�rio

	If !(oSetup:Activate() == PD_OK)
		oReport:Cancel()
    	lRet := .F.
	Else
		lRet := GeraRelat(oReport, aParam)
	EndIf

	oReport:lServer := oSetup:GetProperty( PD_DESTINATION ) == AMB_SERVER                      
	oReport:SetResolution( 75 )
	
	If oSetup:GetProperty( PD_ORIENTATION ) == 2
	   oReport:SetLandscape()
	Else
	   oReport:SetPortrait()
	EndIf
	       
	oReport:SetPaperSize( oSetup:GetProperty( PD_PAPERSIZE ) )
	oReport:SetMargin(oSetup:GetProperty( PD_MARGIN )[1],oSetup:GetProperty( PD_MARGIN )[2],oSetup:GetProperty( PD_MARGIN )[3],oSetup:GetProperty( PD_MARGIN )[4])
	aMargRel := {oSetup:GetProperty( PD_MARGIN )[1],oSetup:GetProperty( PD_MARGIN )[2],oSetup:GetProperty( PD_MARGIN )[3],oSetup:GetProperty( PD_MARGIN )[4]}
	
	fwWriteProfString(cSession,"LOCAL", If(oSetup:GetProperty(PD_DESTINATION)==1,"SERVER","LOCAL"), .T.)
	fwWriteProfString(cSession,"PRINTTYPE", aDevice[oSetup:GetProperty( PD_PRINTTYPE )], .T.)
	
	If oSetup:GetProperty( PD_PRINTTYPE ) == IMP_SPOOL  
		oReport:nDevice := IMP_SPOOL
		fwWriteProfString(cSession,"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
		oReport:cPrinter := oSetup:aOptions[PD_VALUETYPE]
	ElseIf oSetup:GetProperty( PD_PRINTTYPE ) == IMP_PDF
		oReport:nDevice := IMP_PDF
		fwWriteProfString(cSession,"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)	
		oReport:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
	EndIf	

    if lRet
        oReport:EndPage()
        oReport:Print()

    endIf

    FreeObj(oReport)

    MS_FLUSH()

Return _aRet


/*/{Protheus.doc} GeraRelat
//Fun��o respons�vel pela gera��o do relat�rio
@author marina.muller
@since 10/11/2017
@version undefined
@param oReport, object, descricao
@type function
/*/
Static Function GeraRelat(oReport, aParam)
	Local cAliasQry     := GetNextAlias()
	Local lRet     		:= .T.
	Local nLinhaBar		:= 0
	Local nLinPix       := 0
	Local nColBar		:= 0
	Local nI            := 1
	Local nX            := 0
	Local cQry          := ""
	Local cWhere        := ""
	Local lquebra       := .F.
	
	Local cFilialB      := ""
	Local cSafra        := ""
	Local cProdutor     := ""
	Local cLojaPro      := ""
	Local cFazenda      := ""
	
	Private _nColAux    := 0
	Private _nPag  		:= 1
	Private _nLeft      := 40
	Private _nRight     := 1730
	Private _nCol0      := _nLeft
	Private _nTop       := 130
	Private _nTopInt    := _nTop
	Private _nLinOri    := 46
	Private _nTweb    	:= 3
	Private _nLweb    	:= 10

	if oReport:GetOrientation() == 2 //se o usu�rio informou paisagem
	    _nLeft  	:= 40
	    _nRight  := 2390
	    _nCol0   := _nLeft
	    _nTop    := 130
	    _nTopInt := _nTop
	    _nLinOri := 30
	endIf

	//busca F12 para saber se lista ou n�o os fardos 1-Sim  e 2-N�o
    Pergunte("AGRAR630B", .F.)
    
	If Funname() = "AGRA630"
		//Se tiver filtro no browse utilizamos como filtro no relat�rio
		If !Empty(aParam)
			cWhere += "AND "
			For nX := 1 to Len(aParam)
				If !Empty(aParam[nX][3])
				   cWhere += aParam[nX][3] + IIF(nX < Len(aParam)," AND ","")
				Else
				   cWhere += aParam[nX][2] + IIF(nX < Len(aParam)," AND ","")
				EndIf   
			Next nX
		EndIf
	EndIf	

	cQry := " SELECT * "
	cQry += " FROM " +RetSqlName("DXJ")+ " DXJ "
	cQry += " WHERE DXJ.D_E_L_E_T_ =  ' ' "

    //tipo do romaneio visual
    If MV_PAR01 == 1 
       cQry += " AND DXJ_TIPO = '1' "	
    ElseIf MV_PAR01 == 2
    //tipo do romaneio HVI
       cQry += " AND DXJ_TIPO = '2' "		
    Endif

	If !Empty(cWhere) .And. Funname() = "AGRA630"
		cQry += cWhere
	EndIf

	cQry += " ORDER BY DXJ_FILIAL, DXJ.DXJ_SAFRA, DXJ_PRDTOR, DXJ_LJPRO, DXJ_FAZ, DXJ_CODIGO"

	cQry := ChangeQuery(cQry)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQry),cAliasQry,.F.,.T.)

	oReport:StartPage()
	CabPagRet(oReport, cAliasQry)

    // seta valor default primeira vez
	cFilialB  := (cAliasQry)->DXJ_FILIAL
	cSafra    := (cAliasQry)->DXJ_SAFRA
	cProdutor := (cAliasQry)->DXJ_PRDTOR
	cLojaPro  := (cAliasQry)->DXJ_LJPRO
	cFazenda  := (cAliasQry)->DXJ_FAZ

	nLinhaBar 	:= 14
	nLinPix     := 14
	nColBar     := 10

	While (cAliasQry)->( !Eof() )
        //Se filial/safra/produtor/loja/fazenda for diferente come�a outra p�gina
		If (cFilialB != (cAliasQry)->DXJ_FILIAL) .Or. (cSafra != (cAliasQry)->DXJ_SAFRA) .Or.;
		   (cProdutor != (cAliasQry)->DXJ_PRDTOR) .Or. (cLojaPro != (cAliasQry)->DXJ_LJPRO) .Or.;
		   (cFazenda != (cAliasQry)->DXJ_FAZ)

			cFilialB  := (cAliasQry)->DXJ_FILIAL
			cSafra    := (cAliasQry)->DXJ_SAFRA
			cProdutor := (cAliasQry)->DXJ_PRDTOR
			cLojaPro  := (cAliasQry)->DXJ_LJPRO
			cFazenda  := (cAliasQry)->DXJ_FAZ

			oReport:EndPage()
			oReport:StartPage()

			_nTop := 130
			nLinhaBar := 14
			nLinPix   := 14
			nColBar   := 10
			_nColAux  := 0
			nI := 1
			_nPag++

			CabPagRet(oReport,cAliasQry)
		EndIf
		
		lquebra := .F.
		oReport:FWMSBAR( 'CODE128', nLinhaBar, nColBar, Alltrim((cAliasQry)->DXJ_CODBAR), oReport, .F., , .T., 0.025, 1.5, .f., 'Courier New', '', .F. ) // Imprime o c�digo de barras
		nLinPix   += 10
		oReport:Say(nLinPix * nColBar, 120, (cAliasQry)->DXJ_CODBAR, __oFnt10C)
		nLinPix    -= 0.5
		nLinhaBar  += 8
		
		If nI % 6 == 0 // Se houver 6 registros ou multiplos de 5, finaliza a p�gina
			oReport:EndPage()
			oReport:StartPage()

			_nTop     := 130
			nLinhaBar := 14
			nLinPix   := 14
			nColBar   := 10
			_nColAux  := 0
			lquebra   := .T.
			_nPag++
			
		EndIf

		nI++
		(cAliasQry)->( dbSkip() )
		If lquebra
			CabPagRet(oReport,cAliasQry)
		EndIf
	EndDo

	(cAliasQry)->( dbCloseArea() )

Return lRet


/*/{Protheus.doc} CabPagRet
//Fun��o que imprime os dados do relat�rio
@author marina.muller
@since 10/11/2017
@version undefined
@param oReport, object, descricao
@type function
/*/
Static Function CabPagRet(oReport, cAliasQry)
	Local cFileLogo    := ''
	Local cNmEmp
	Local cNmFilial
	Local cMalaIni    := ""
	Local cMalaFim    := ""
    Local aSaveArea   := GetArea()
	Local cAliasDXJ   := GetNextAlias()
	Local nI          := 1

    //Carrega e Imprime Logotipo da Empresa
    fLogoEmp(@cFileLogo)

	if file(cFilelogo)
		_nColAux += 30
		oReport:SayBitmap(_nTop/_nTweb, _nColAux, cFileLogo, (180)/_nTweb, (050)/_nTweb)
		_nColAux := 0
	EndIf

	_nColAux += 30
	oReport:Line(_nTop/_nTweb, _nColAux, (_nTop/_nTweb), (_nRight/_nTweb) - 20)

	_nTop += 45

	_nColAux += 170
	oReport:Say(_nTop/_nTweb, _nColAux, STR0001, __oFnt14N) //#"Romaneio de Amostras para An�lise por Mala"

	_nTop -= 40
	_nColAux += 320
	oReport:Say(((_nTop)/_nTweb)+_nLweb, _nColAux, STR0011 +AllTrim(Str(_nPag)), __oFnt10C) //#"P�gina: "

	_nColAux := 0
	_nTop += 85

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	EndIf

	cNmEmp	 := AllTrim( SM0->M0_NOME )
	cNmFilial:= AllTrim( SM0->M0_FILIAL )

	_nColAux += 30
	oReport:Say(_nTop/_nTweb, _nColAux, "SIGA/" + _cFileName + "/v." + cVersao, __oFnt10N)
	oReport:Say(_nTop/_nTweb, (_nRight/_nTweb) - 105, STR0003 + Dtoc(dDataBase), __oFnt10N) //#"Emiss�o...: "

	_nTop += 28

	oReport:Say(_nTop/_nTweb, _nColAux, STR0002 + cNmEmp + " / " + cNmFilial, __oFnt10N) //#"Empresa...: "
	oReport:Say(_nTop/_nTweb, (_nRight/_nTweb) - 83, RptHora + Time(), __oFnt10N)

	_nTop += 20
	_nColAux := 0

	_nColAux := 30

	oReport:Line(_nTop/_nTweb, _nColAux, (_nTop/_nTweb), (_nRight/_nTweb) - 20)

	_nTop += 90
	_nColAux := 0

	_nColAux += 30 //Safra
	oReport:Say(_nTop/_nTweb, _nColAux, STR0004, __oFnt10N) //#"Safra: "
	_nColAux += 25
	oReport:Say(_nTop/_nTweb, _nColAux, (cAliasQry)->DXJ_SAFRA, __oFnt10C)

	_nTop 	+= 45
	_nColAux := 0

	_nColAux += 30  //Codigo+Loja+Nome
	oReport:Say(_nTop/_nTweb, _nColAux, STR0005, __oFnt10N) //#"Entidade: "
	_nColAux += 40
	oReport:Say(_nTop/_nTweb, _nColAux, (cAliasQry)->DXJ_PRDTOR + "/" + (cAliasQry)->DXJ_LJPRO +;
	" - " + Posicione("NJ0",1,FWxFilial("NJ0")+(cAliasQry)->(DXJ_PRDTOR+DXJ_LJPRO),"NJ0_NOME"), __oFnt10C)

	_nColAux += 205 //Fazenda+Nome
	oReport:Say(_nTop/_nTweb, _nColAux, STR0006, __oFnt10N) //#"Fazenda: "
	_nColAux += 38
	oReport:Say(_nTop/_nTweb, _nColAux, (cAliasQry)->DXJ_FAZ + " - " + Posicione("NN2",2,FWxFilial("NN2")+(cAliasQry)->DXJ_FAZ,"NN2_NOME"), __oFnt10C)

    // atribui valor do mala inicial
    cMalaIni := (cAliasQry)->DXJ_CODIGO

    //busca valor do mala final para mesma filial/safra/produtor/loja/fazenda
	BeginSql Alias cAliasDXJ
	Select DXJ.DXJ_CODIGO
	FROM %Table:DXJ% DXJ
	WHERE DXJ.%NotDel%
	  AND DXJ.DXJ_FILIAL = %exp:(cAliasQry)->DXJ_FILIAL%
	  AND DXJ.DXJ_SAFRA  = %exp:(cAliasQry)->DXJ_SAFRA%
	  AND DXJ.DXJ_PRDTOR = %exp:(cAliasQry)->DXJ_PRDTOR%
	  AND DXJ.DXJ_LJPRO  = %exp:(cAliasQry)->DXJ_LJPRO%
	  AND DXJ.DXJ_FAZ    = %exp:(cAliasQry)->DXJ_FAZ%
	  AND DXJ.DXJ_CODIGO > %exp:(cAliasQry)->DXJ_CODIGO%
	  AND DXJ.DXJ_TIPO   = %exp:MV_PAR01%
	  EndSQL

    (cAliasDXJ)->(dbGoTop())
    If (cAliasDXJ)->( !Eof() )
	    While (cAliasDXJ)->( !Eof() )

	       // atribui valor do mala final
	       cMalaFim := (cAliasDXJ)->DXJ_CODIGO
	       
	       //quando atingir �ltimo registro da sequ�ncia que poder ser impresso naquela p�gina
	       If nI == 5
		      Exit
		   EndIf   
	    	
	    	nI++
	    	(cAliasDXJ)->( dbSkip() )
		EndDo
	EndIf	
    (cAliasDXJ)->( dbCloseArea() )
    RestArea( aSaveArea )
    
    ////se tiver apenas o mala inicial a mala final � igual
    If Empty(cMalaFim)
       cMalaFim := cMalaIni	
    EndIf

	_nTop 	+= 45
	_nColAux := 0

	_nColAux += 30  //Fardo Inicial
	oReport:Say(_nTop/_nTweb, _nColAux, STR0007, __oFnt10N) //#"Mala Inicial: "
	_nColAux +=  54
	oReport:Say(_nTop/_nTweb, _nColAux, cMalaIni, __oFnt10C)

	_nColAux += 100
	oReport:Say(_nTop/_nTweb, _nColAux, STR0008, __oFnt10N) //#"Mala Final: "
	_nColAux +=  48
	oReport:Say(_nTop/_nTweb, _nColAux, cMalaFim, __oFnt10C)

	_nTop += 25
	_nColAux := 0

	_nColAux := 30

	oReport:Line(_nTop/_nTweb, _nColAux, (_nTop/_nTweb), (_nRight/_nTweb) - 20)

Return

