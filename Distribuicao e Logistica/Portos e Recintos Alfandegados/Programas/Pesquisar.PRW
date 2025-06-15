//--------------------------------- 
/*/{Protheus.doc}
Tela de Pesquisa pertencente ao requisito 29 do Projeto de Virtualização. 
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 08/02/2013
@return nil
@obs: 
@sample
/*/
//---------------------------------



//---------------------------------
/*/{Protheus.doc}
Função Pesquisar apresenta o oBrowse para apresentar as grids com os retistros do estoque
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 08/02/2013
@return nil
/*/
//---------------------------------
function Pesquisar(cParent,cCodSistema)

	Local   aCoors  := FWGetDialogSize(oMainWnd)
	Local   oDlg    := nil
	Local   cFileTab
	Local   aCampos := {}
	Private   cAlias := SGetNAlias()
	Private   oBrowse := nil
	Private   oColumn := nil
	Private   aDados  := {}
	 
	
	//////criar tabela temporaria vazia	para aliar com o oBrowse//////////////
	Aadd(aCampos, {'ID', 'C', 10, 0})
	SCriaTbTmp({aCampos, {'ID'}}, cAlias)
	/////////////fim cricao da tabela temporaria vazia///////////////////////
	

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]
	
	oBrowse := FWMarkBrowse():new(oDlg)
	oBrowse:SetAlias(cAlias)
	oBrowse:SetDescription('Pesquisa de Estoque')
	oBrowse:AddButton('Pesquisar',{||A866PESQ('313','0')},,1,2)
	oBrowse:AddButton('Pesquisar em Nivel',{||A866PNVL('313','0'),},,1,2,)
	oBrowse:AddButton('Voltar',{||voltar()},,1,2)
	oBrowse:AddButton('Exp. Imagem',{||exportarImagem()},,1,2)
	oBrowse:DisableSeek()
	
	oBrowse:Activate()
	
Return



//---------------------------------
/*/{Protheus.doc}
Função A866PESQ faz a pesquisa geral do estoque
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 08/02/2013
@return nil
/*/
//---------------------------------
Function A866PESQ(cCodSistema,cParent)

	aDados := wmsc867(cCodSistema,'')
	
	if len(aDados) != 0 
		A866FNVL(cParent)
		
		if adados != nil  .and. len(aDados) > 0  
			A866DCG(aDados)
			oBrowse:Activate()
		endif
	endif
return 


//---------------------------------
/*/{Protheus.doc}
Função A866PNVL faz a pesquisa no estoque tendo como consulta o cParent
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 08/02/2013
@return nil
/*/
//---------------------------------
Function A866PNVL(cCodSistema,cParent)

	aDados := wmsc867(cCodSistema,'0')
	
	if len(aDados) != 0  
		A866DCG(aDados)
		oBrowse:Activate()
	endif
return 



//---------------------------------
/*/{Protheus.doc}
Função A866FNVL filtra os registros da grid (funcao auxiliar para a A866PESQ)
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 08/02/2013
@return nil
/*/
//---------------------------------
function A866FNVL(cParent)

	Local 	 filtro  := "" 

	filtro := "PARENT " + SUPERGETMV("MV_SARACSV",.T., "=") + " '" + cParent + " '"
	DBSelectArea(aDados[1])
	(aDados[1])->(DbSetFilter({||&filtro},filtro))
	
return


//---------------------------------
/*/{Protheus.doc}
A Função A866DCG define as colunas e seus respctivos valores da grid
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 08/02/2013
@return nil
/*/
//---------------------------------

Function A866DCG(aDados)
	
	Local   i
	Local   aDesc := {}
	Local   cCampo := ''
	Local   aStruct := {}
	
	if aDados != nil
		aDesc := aDados[2]
		aStruct := (aDados[1])->(dbStruct())
	endif
	
	if aDados == nil
		oColumn := FWBrwColumn():New()
		oColumn:SetTitle( '' )
		oColumn:SetSize(20)
		oBrowse:SetColumns({oColumn})
	else
		for i := 2 to len(aStruct)			
			if ((lower(STrim(aStruct[i][1])) != 'parent') .AND. (lower(STrim(aStruct[i][1])) != 'imagem')) 
				oColumn := FWBrwColumn():New()
				cCampo := "{|| "+STrim(aStruct[i][1])+"}"
				oColumn:SetData( &(cCampo) )
				oColumn:SetTitle( aDesc[i] )
				oColumn:SetSize(20)
				oBrowse:SetColumns({oColumn})
			endif
		next
	endif
	
return



