#INCLUDE "UBAC050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TopConn.ch"

/*/{Protheus.doc} UBAC050
//Programa de Consulta de Contaminantes Lan�ados
@author jeferson.chaves
@since 04/04/2017
@version undefined

@type function
/*/
Function UBAC050()
	
	Private _aCoors  	:= FWGetDialogSize( oMainWnd )
	Private _oCbxEntida
	Private _aEntidade 	:= {AGRSX2NOME("DXL"),AGRSX2NOME("DXI"),AGRSX2NOME("DXJ"), AGRSX2NOME("DXD")}
	Private _cEntidade 	:= AGRSX2NOME("DXL")
	Private _cWhereEnt  := ""	
	Private _cTitulo    := ""
	Private _aSeek 		:= {}
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(_aCoors)
	oSize:aMargins := {3,3,3,3}
	oSize:lProp    := .T.
	oSize:Process()
	Define MsDialog oDlg Title STR0002  From _aCoors[1]/2, _aCoors[2]/2 To _aCoors[3]/2, _aCoors[4]/2 Pixel //STR0002 - Parametro
	
	@04, 02 Say STR0003      Size 53, 07 														  Of oDlg Pixel //STR0003 - Entidade
	@13, 02 MSCOMBOBOX _oCbxEntida VAR _cEntidade ITEMS _aEntidade  SIZE 90,13						  Of oDlg Pixel
	//botao
	@13, 97 BUTTON STR0004   SIZE 43, 13  ACTION UBAC050LST()									  Of oDlg Pixel //STR0004 - Pesquisar 
	Activate MsDialog oDlg Center	
	
Return ()

/*/{Protheus.doc} UBAC050LST
//Fun��o para carregar a listagem dos contaminantes
@author jeferson.chaves
@since 04/04/2017
@version undefined

@type function
/*/
Function UBAC050LST()
	Local aColumns  := {}
		
	If .Not. TableInDic('N76')
		MsgNextRel() //-- � necess�rio a atualiza��o do sistema para a expedi��o mais recente
		Return()
	Endif	
	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||NPX_CODTA})
	aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("NPX_CODTA")))
	aColumns[Len(aColumns)]:SetSize(TamSx3("NPX_CODTA")[1])
	aColumns[Len(aColumns)]:SetDecimal(TamSx3("NPX_CODTA")[2])
	aColumns[Len(aColumns)]:SetPicture(PesqPict("NPX", "NPX_CODTA"))
	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||Posicione("N76",1,FWxFilial("N76")+NPX_CODTA,"N76_NMCON")})
	aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("N76_NMCON")))
	aColumns[Len(aColumns)]:SetSize(TamSx3("N76_NMCON")[1])
	aColumns[Len(aColumns)]:SetDecimal(TamSx3("N76_NMCON")[2])
	aColumns[Len(aColumns)]:SetPicture(PesqPict("N76", "N76_NMCON"))
	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||UBAC050RES()})
	aColumns[Len(aColumns)]:SetTitle(STR0006) //STR0006 - Resultado
	aColumns[Len(aColumns)]:SetPicture({||U050RESPIC()})
	aColumns[Len(aColumns)]:SetAlign("RIGHT")
	
	if !IsIncallStack("ResultCont") 
		
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData({||NPX_CODSAF})
		aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("NPX_CODSAF")))
		aColumns[Len(aColumns)]:SetSize(TamSx3("NPX_CODSAF")[1])
		aColumns[Len(aColumns)]:SetDecimal(TamSx3("NPX_CODSAF")[2])
		aColumns[Len(aColumns)]:SetPicture(PesqPict("NPX", "NPX_CODSAF"))
		
		_cTitulo     :=  alltrim(_aEntidade[_oCbxEntida:nAt]) 
	else	
		_cTitulo     :=  alltrim(_aEntidade[_oCbxEntida:nAt]) + ": " + _cTitulo
	endif
		
	Do Case
		Case _oCbxEntida:nAt = 1 //DXL - Fard�o
			_cEntidade 	:= "DXL"
			
			if !IsIncallStack("ResultCont")
		
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||NPX_CODPRO})
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("NPX_CODPRO")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("NPX_CODPRO")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("NPX_CODPRO")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("NPX", "NPX_CODPRO"))
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||Posicione('SB1',1,fwxFilial('SB1')+NPX_CODPRO,"B1_DESC")}) //Descri��o Produto
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("B1_DESC")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("B1_DESC")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("B1_DESC")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("SB1", "B1_DESC"))				
								
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||NPX_FARDAO}) //Fard�o
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXL_CODIGO")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXL_CODIGO")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXL_CODIGO")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXL", "DXL_CODIGO"))				
								
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||NPX_PRDTOR}) //Produtor
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXL_PRDTOR")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXL_PRDTOR")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXL_PRDTOR")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXL", "DXL_PRDTOR"))				
								
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||Posicione('NJ0',1,fwxFilial('NJ0')+NPX_PRDTOR+NPX_LJPRO,'NJ0_NOME')}) //Entidade NOME
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("NJ0_NOME")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("NJ0_NOME")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("NJ0_NOME")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("NJ0", "NJ0_NOME"))		
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||NPX_LJPRO}) //Loja
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXL_LJPRO")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXL_LJPRO")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXL_LJPRO")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXL", "DXL_LJPRO"))		
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||NPX_FAZ}) //Fazenda
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXL_FAZ")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXL_FAZ")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXL_FAZ")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXL", "DXL_FAZ"))	
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||Posicione("DXL",1,fwxFilial('DXL')+NPX_FARDAO+NPX_CODSAF+NPX_PRDTOR+NPX_LJPRO+NPX_FAZ, "DXL_CODUNB")}) //Unidade de Benef.
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXL_CODUNB")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXL_CODUNB")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXL_CODUNB")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXL", "DXL_CODUNB"))
			endif
			
		Case _oCbxEntida:nAt = 2 //DXI - Fardinho
			_cEntidade 	:= "DXI"
			
			if !IsIncallStack("ResultCont") 
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||NPX_ETIQ}) //Etiqueta
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXI_ETIQ")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXI_ETIQ")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXI_ETIQ")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXI", "DXI_ETIQ"))
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||NPX_FARDO}) 
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXI_CODIGO")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXI_CODIGO")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXI_CODIGO")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXI", "DXI_CODIGO"))
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||Posicione('DXI',1,fwxFilial('DXI')+NPX_CODSAF+NPX_ETIQ,'DXI_CODCNJ' )}) //Conjunto
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXI_CODCNJ")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXI_CODCNJ")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXI_CODCNJ")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXI", "DXI_CODCNJ"))
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||Posicione("DXI",1,fwxFilial('DXI')+NPX_CODSAF+NPX_ETIQ,"DXI_CODUNB")}) //Unidade de Benef.
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXI_CODUNB")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXI_CODUNB")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXI_CODUNB")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXI", "DXI_CODUNB"))
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||Posicione('DXI',1,fwxFilial('DXI')+NPX_CODSAF+NPX_ETIQ,'DXI_CLACOM' )}) //Classifica��o Comercial
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXI_CLACOM")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXI_CLACOM")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXI_CLACOM")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXI", "DXI_CLACOM"))
			endIF
			
		Case _oCbxEntida:nAt = 3 //DXJ - Mala
			_cEntidade 	:= "DXJ"
			
			if !IsIncallStack("ResultCont") 
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||NPX_ROMCLA}) //Cod Mala
				aColumns[Len(aColumns)]:SetTitle(STR0007) //Rom.Clas
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXJ_CODIGO")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXJ_CODIGO")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXJ", "DXJ_CODIGO"))
								
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||NPX_CDUMAL}) //CODBAR
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXJ_CODBAR")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXJ_CODBAR")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXJ_CODBAR")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXJ", "DXJ_CODBAR"))
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||Posicione("DXJ",1,fwxFilial('DXJ')+NPX_ROMCLAS+"1","DXJ_CODUNB")}) //Unidade de Benef.
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXJ_CODUNB")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXJ_CODUNB")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXJ_CODUNB")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXJ", "DXJ_CODUNB"))
			endIf
			
		Case _oCbxEntida:nAt = 4 //DXD - Bloco
			_cEntidade 	:= "DXD"
			
			if !IsIncallStack("ResultCont") 
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||NPX_BLOCO}) //Cod Bloco
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXD_CODIGO")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXD_CODIGO")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXD_CODIGO")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXD", "DXD_CODIGO"))
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||Posicione("DXD",1,fwxFilial('DXD')+NPX_CODSAF+NPX_BLOCO, "DXD_CODUNB")}) //Unidade de Benef.
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXD_CODUNB")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXD_CODUNB")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXD_CODUNB")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXD", "DXD_CODUNB"))
				
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData({||Posicione("DXD",1,fwxFilial('DXD')+NPX_CODSAF+NPX_BLOCO, "DXD_CLACOM")}) //Unidade de Benef.
				aColumns[Len(aColumns)]:SetTitle(AllTrim(FWX3Titulo("DXD_CLACOM")))
				aColumns[Len(aColumns)]:SetSize(TamSx3("DXD_CLACOM")[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSx3("DXD_CLACOM")[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DXD", "DXD_CLACOM"))
			endIf
	EndCase
	
	DEFINE MSDIALOG oDlgX FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] Title STR0001 OF oMainWnd PIXEL //STR0001 - Consulta de lan�amento de contaminante 
	DEFINE FWFormBrowse oBrowse DATA TABLE ALIAS "NPX" DESCRIPTION _cTitulo  OF oDlgX
	oBrowse:SetColumns(aColumns)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias("NPX")
	oBrowse:DisableDetails()
	
	If _oCbxEntida:nAt = 1 //Fard�o
		if _cWhereEnt != nil 
			oBrowse:SetFilterDefault(_cWhereEnt)
		else
			oBrowse:SetFilterDefault("NPX->NPX_FARDAO <> ''" )
		endif
	ElseIf _oCbxEntida:nAt = 2 //Fardinho
		if _cWhereEnt != nil 
			oBrowse:SetFilterDefault(_cWhereEnt)
		else
			oBrowse:SetFilterDefault("NPX->NPX_ETIQ <> ''" )
		endif
	
	ElseIf _oCbxEntida:nAt = 3 //Mala
		if _cWhereEnt != nil 
			oBrowse:SetFilterDefault(_cWhereEnt)
		else
			oBrowse:SetFilterDefault("NPX->NPX_ROMCLA <> ''" )
		endif
	
	Else //Bloco
		if _cWhereEnt != nil 
			oBrowse:SetFilterDefault(_cWhereEnt)
		else
			oBrowse:SetFilterDefault("NPX->NPX_BLOCO <> ''" )
		endif
	Endif
		
	oBrowse:SetdbFFilter(.T.)
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetSeek(,_aSeek)
	ACTIVATE FWFormBrowse oBrowse
	ACTIVATE MSDIALOG oDlgX CENTER
	
	
Return ()

/*/{Protheus.doc} UBAC050RES
//Fun��o para trazer o tipo de resultado
@author jeferson.chaves
@since 04/04/2017
@version undefined

@type function
/*/
Static Function UBAC050RES()
	Local xValor 		
	
	If .Not. NPX_TIPOVA = Nil
		Do Case
			Case NPX_TIPOVA = "1" //Numerico
				xValor := NPX_RESNUM
			Case NPX_TIPOVA = "2" //Texto
				xValor := NPX_RESTXT
			Case NPX_TIPOVA = "3" //Data
				xValor := NPX_RESDTA
			Case NPX_TIPOVA = "4" //Lista
				xValor := NPX_RESTXT
			Case NPX_TIPOVA = "5" //Faixa
				xValor := cValToChar(NPX_RESNUM) + " - " + NPX_RESTXT  
		EndCase
	EndIf
	
Return xValor

/*/{Protheus.doc} U050RESPIC
//Fun��o para trazer a picture do resultado
@author silvana.torres
@since 19/04/2017
@version undefined

@type function
/*/
Static Function U050RESPIC()
	Local xValor
	Local aValor := {}
	Local aNumerico := {} 		
	
	If .Not. NPX_TIPOVA = Nil
		Do Case
			Case NPX_TIPOVA = "1" //Numerico
			
				aNumerico := StrTokArr(CValToChar(NPX_RESNUM), ".")
				
				if len(aNumerico) > 1
				
					aValor := AGRGerPic(len(CVALTOCHAR(NPX_RESNUM))-1, len(CVALTOCHAR(aNumerico[2])))
					
					if aValor[1] == .T.
						xValor := aValor[2]
					endIf					
			    else
			    	aValor := AGRGerPic(len(CVALTOCHAR(aNumerico[1])), 0)
			    	
			    	if aValor[1] == .T.
						xValor := aValor[2]
					endIf
				endIf				 
			Case NPX_TIPOVA = "2" //Texto
				xValor 	:= "@!"   
			OTHERWISE
				xValor := ""
		EndCase
	EndIf
	
Return xValor
