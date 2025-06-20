#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//---------------------------------------------------------------------------------------------------
/*{Protheus.doc} GFEC012
An�lise de Despesa de Transporte por Per�odos
Generico

@sample
GFEC012()

@author Felipe M. / Alan Victor Lamb
@since 26/07/12
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------  
Function GFEC012()      
	Local aStruct := {}, nCont 
	Private oBrowse, cAlias, aCampos
	
	
	//Array principal com os campos.. *fazer manuten��o aqui*
	aCampos := {{""               ,"M0_OK"     ,"C",01            ,0,""  },;
					{"C�digo Filial"  ,"M0_CODFIL" ,"C",FWSizeFilial(),0,""  },;
					{"Nome Filial"    ,"M0_FILIAL" ,"C",25            ,0,"@!"},;
					{"Nome Comercial" ,"M0_NOMECOM","C",25            ,0,""  },;
					{"Cid. de Entrega","M0_CIDENT" ,"C",15            ,0,""  },;
					{"UF de Entrega"  ,"M0_ESTENT" ,"C",2             ,0,""  }}

	For nCont := 2 to Len(aCampos)
		aADD(aStruct,{ aCampos[nCont][1],;
					   aCampos[nCont][2],;
					   aCampos[nCont][3],;
					   aCampos[nCont][4],;
					   aCampos[nCont][5],;
					   aCampos[nCont][6]} )
	Next nCont            
	
	cAlias := GFEC011TAB() // Cria a tabela
	GFEC011FIL(cAlias) // Carrega as filiais
				
	oBrowse := FWMarkBrowse():New()
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias(cAlias)						    // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC012")				        // Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription("Consulta de Frete por Per�odo")	// Descri��o do browse   
	oBrowse:SetFieldMark("M0_OK")
	oBrowse:SetFields(aStruct)
	
	oBrowse:Activate()
	GFEDelTab(cAlias)
Return Nil 

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Previsto"  ACTION "GFEC012OPC(1)" OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Realizado" ACTION "GFEC012OPC(2)" OPERATION 4 ACCESS 0
Return aRotina

Function GFEC012OPC(nOpcao)
	Local aParam := {}, aFiliais := {}
	
	dbSelectArea(cAlias)
	dbGotop()
	While (cAlias)->(!Eof())
		If !Empty((cAlias)->M0_OK) 
	    	aADD( aFiliais, (cAlias)->M0_CODFIL )
		EndIf
		
		(cAlias)->(dbSkip())
	EndDo
	
	//Valida��o
	If Len(aFiliais) == 0
		Alert("� necessario escolher pelo menos uma filial")
		Return
	EndIf
	
	If !Pergunte("GFEC012")
		Return
	EndIf
	
	If Vazio(MV_PAR02)
		Help( ,, 'HELP',, "Data final n�o informada.", 1, 0,)
		Return Nil
	EndIf
	
	If !(MV_PAR03 > 0)
		Help( ,, 'HELP',, "Quantidade de per�odos deve ser maior que 0.", 1, 0,)
		Return Nil
	EndIf
	
	aADD( aParam, aFiliais )
	aADD( aParam, MV_PAR01 ) //Tipo de Periodo
	aADD( aParam, MV_PAR02 ) //Data Final
	aADD( aParam, MV_PAR03 ) //Qtd de periodos
	aADD( aParam, MV_PAR06 ) //Grupo de Transp 
	aADD( aParam, MV_PAR04 ) //Transp de
	aADD( aParam, MV_PAR05 ) //Transp at�
	
	If nOpcao == 1 // Previsto
		GFEC012A(aParam)
	ElseIf nOpcao == 2 // Realizado
		GFEC012B(aParam)
	EndIf
Return Nil