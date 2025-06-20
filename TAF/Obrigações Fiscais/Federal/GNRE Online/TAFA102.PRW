#INCLUDE "TAFA102.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA102
Geracao da Guia Nacional de Recolhimento (GNRE)

@author Rodrigo Aguilar
@since 17/09/2012
@version 1.0
/*/  
//-------------------------------------------------------------------
Function TAFA102()

Local cXml       := ""  
Local cDir		 := ""
Local cFile	   	 := ""
Local cFileDes   := ""    
Local cAliasQry  := ""
Local cNomWiz    := "A501"
Local aWizard    := {} 
Local aParam     := Array(6)
Local cFunction  := ProcName()
Local nOpc       := 2 //View

//Protect Data / Log de acesso / Central de Obrigacoes
Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

If A102Wizard( cNomWiz )
	If XFUNLoadProf( cNomWiz , @aWizard )		
		
		If !Empty( Alltrim( aWizard[1][7] ) + Alltrim( aWizard[1][8] ) )	
		
			cDir	:= Alltrim(aWizard[1][7])  
			cFile 	:= Alltrim(aWizard[1][8])
			
			NorDir(@cDir)
			
			If NorFile(@cFile) 
		
				cFileDes := cDir + cFile  		
										
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//쿛ar�metros para emissao do arquivo magnetico�
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				aParam[1] := aWizard[1][1]
				aParam[2] := Posicione("C09",3,xFilial("C09")+aWizard[1][5],"C09_UF")
				aParam[3] := aWizard[1][3]
				aParam[4] := aWizard[1][4]
				aParam[5] := Left( aWizard[1][2], 1 )
		
				//Novo item de pesquisa por s�rie de documento			
				aParam[6] := aWizard[1][9]
			
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//쿐xecuta a Query para emissao das GNRE(s)�
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸				
				If A102QryPrin( @cAliasQry, aParam )							   						
				    MsgRun( STR0001, "", {|| CursorWait(), cXML := A102GeraXML( cAliasQry ) ,CursorArrow() } )  //"Gerando Arquivo Magn�tico, Aguarde..."       
					MemoWrite( cFileDes, cXml )     
					MsgInfo( STR0002 ) //"Arquivo Magn�tico Gerado com Sucesso!"
				Else
					MsgAlert( STR0003 ) //"N�o foram encontrados registros com os par�metros informados!"
				EndIf												
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//쿑echas o Alias utilizado na emissao das GNRE(s)�
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				(cAliasQry)->(DbCloseArea())
			Else
				MsgAlert(STR0018)
			EndIf				
		Else
			MsgAlert( STR0004 ) //"Arquivo N�o Gerado, informe o driver de destino!"
		EndIf
	EndIf    
EndIf
     	 			   				
Return ( Nil ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} A102GeraXML
Geracao do Arquivo .XML

@Param  cAliasQry - Query Principal para emissao do Aquivo
@return cXML      - String com XML Montado                                                                                        

@author Rodrigo Aguilar
@since 17/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A102GeraXML( cAliasQry )

Local cRetXML    := ""
Local cCmpData   := ""
Local cTpPessoa  := ""
Local lInicioXml := .T. 
Local lPeriodo	 := .F. 
Local lParcela	 := .F.
Local lPartDest	 := .F. 
Local cInsc		 := ""
Local cCodReceita	 := ""

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿘onta Cabecalho do Arquivo XML      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
cRetXML := A102Cabec( @cRetXML, lInicioXml )

DbSelectArea(cAliasQry)                                               
(cAliasQry)->(DbGoTop())                                              
Do While (cAliasQry)->(!Eof())
					   
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿏efino as variaveis logicas para a construcao dos leiautes.�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	lPeriodo	 	:= .F. 
	lParcela	 	:= .F.	
	lPartDest	 	:= .F.		
	cCodReceita 	:= AllTrim((cAliasQry)->C6R_CODIGO)

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿏efino se a Parcela sera preenchida�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	/*If (cAliasQry)->C09_UF	$ "AM/DF/RS/SC"				
		Do Case		
			Case (cAliasQry)->C09_UF == "AM" .And. cCodReceita $ "100072"
				lParcela := .T.				
			Case (cAliasQry)->C09_UF == "DF" .And. cCodReceita $ "100013/100021/100030/100048/100056/100099/500011/600016"
				lParcela := .T.				
			Case (cAliasQry)->C09_UF == "RS" .And. cCodReceita $ "100072/150010"
				lParcela := .T.				
			Case (cAliasQry)->C09_UF == "SC" .And. cCodReceita $ "100072"
				lParcela := .T.	
		EndCase	
	EndIf	*/
	If !((cAliasQry)->C09_UF $ "BA/GO") .And.  cCodReceita $ "100048/100099" //N�o ter inscri豫o no estado de destino. No protheus tem um par�metro
		lParcela := .T.
	EndIf
	
	If (cAliasQry)->C09_UF == "DF" .And. !(cCodReceita $ "100048/100099") .And.  cCodReceita $ ("100013/100021/100030/100056")
		lParcela := .T.
	EndIf
	
			
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿏efino se o Periodo sera somente "MES + ANO", ou "PERIODO + MES + ANO"�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	 If (cAliasQry)->C09_UF	$ "AC/AM/AP/BA/CE/DF/MA/MS/PE/PR/RO/RR/RS/SE"		
		 Do Case 
		 	Case (cAliasQry)->C09_UF == "AC" .And. cCodReceita $ "100021/100048" 
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "AM" .And. cCodReceita $ "100013/100021/100048/100056/100064/100072/100080/100099/150010/500011"
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "AP" .And. cCodReceita $ "100048"
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "BA" .And. cCodReceita $ "100013/100021/100030/100048/100099"
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "CE" .And. cCodReceita $ "100048"
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "DF" .And. cCodReceita $ "100013/100030/100048/500011/600016"
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "MA" .And. cCodReceita $ "100013/100021/100030/100048"
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "MS" .And. cCodReceita $ "100048"
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "PE" .And. cCodReceita $ "100013/100048"     
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "PR" .And. cCodReceita $ "100013/100021/100030/100048"
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "RO" .And. cCodReceita $ "100048"
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "RR" .And. cCodReceita $ "100013/100048"
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "RS" .And. cCodReceita $ "100013/100021/100048"
				lPeriodo := .T.				
			Case (cAliasQry)->C09_UF == "SE" .And. cCodReceita $ "100048/100056/100099"
				lPeriodo := .T.											
		EndCase		
	EndIf			

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿏efino se o Participante sera preenchido�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If (cAliasQry)->C09_UF	$ "AC/AL/AM/AP/CE/GO/MA/MG/MS/MT/PA/PB/PE/PI/RN/RS/SE/TO"				
		Do Case	
			Case (cAliasQry)->C09_UF == "AC" .And. cCodReceita $ "100099/100102/100110"
				lPartDest := .T.
			Case (cAliasQry)->C09_UF == "AL" .And. cCodReceita $ "100056/100099/100102/100129"
				lPartDest := .T.				
			Case (cAliasQry)->C09_UF == "AM" .And. cCodReceita $ "100021/100030/100099"
				lPartDest := .T.				
			Case (cAliasQry)->C09_UF == "AP" .And. cCodReceita $ "100099/100102"
				lPartDest := .T.				
			Case (cAliasQry)->C09_UF == "CE" .And. cCodReceita $ "100099/100102/100129"
				lPartDest := .T.				
			Case (cAliasQry)->C09_UF == "GO" .And. cCodReceita $ "100056/100099/100102"
				lPartDest := .T.				
			Case (cAliasQry)->C09_UF == "MA" .And. cCodReceita $ "100013/100021/100056/100099/100102/100129"
				lPartDest := .T.				
			Case (cAliasQry)->C09_UF == "MG" .And. cCodReceita $ "100099"
				lPartDest := .T.				
			Case (cAliasQry)->C09_UF == "MS" .And. cCodReceita $ "100056/100099/100102/100129"
				lPartDest := .T.						
			Case (cAliasQry)->C09_UF == "MT" .And. cCodReceita $ "100030/100056/100080/100099"
				lPartDest := .T.	
			Case (cAliasQry)->C09_UF == "PA" .And. cCodReceita $ "100102/100110"
				lPartDest := .T.					
			Case (cAliasQry)->C09_UF == "PB" .And. cCodReceita $ "100013"
				lPartDest := .T.						
			Case (cAliasQry)->C09_UF == "PE" .And. cCodReceita $ "100099/100102/100129"
				lPartDest := .T.						
			Case (cAliasQry)->C09_UF == "PI" .And. cCodReceita $ "100099/100102/100129"
				lPartDest := .T.						
			Case (cAliasQry)->C09_UF == "RN" .And. cCodReceita $ "100013/100021/100056/100099/100102/100129"
				lPartDest := .T.		
			Case (cAliasQry)->C09_UF == "RS" .And. cCodReceita $ "100099/100102/100129"
				lPartDest := .T.					
			Case (cAliasQry)->C09_UF == "SE" .And. cCodReceita $ "100056/100099/100102"
				lPartDest := .T.						
			Case (cAliasQry)->C09_UF == "TO" .And. cCodReceita $ "100030/100056/100102/100110/100129/100137/100099"
				lPartDest := .T.						
		EndCase	                                		
	EndIf

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿔nscricao Estadual do Emitente     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�				
	dbSelectArea("C1E")
	C1E->(DbSetOrder(3))
	MsSeek(xFilial("C1E")+(cAliasQry)->C0R_FILIAL)
	
	dbSelectArea("C1F")
	C1F->(DbSetOrder(1))  
	If MsSeek(xFilial("C1F")+C1E->C1E_ID+(cAliasQry)->C0R_UF + "1")							
		cInsc := C1F->C1F_IEST
	ElseiF !Empty( SM0->M0_INSC ) .And. SM0->M0_ESTCOB == (cAliasQry)->C09_UF		
		cInsc := SM0->M0_INSC
	EndIf   
                                                     
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿔nicializa Impressao da GNRE   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	cRetXML += MontaXML( "TDadosGNRE",,,,,,6,.T.,.F.,.T. )						
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿢F Favorecida (Obrigatorio) �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cRetXML += MontaXML( "c01_UfFavorecida", (cAliasQry)->C09_UF, , , , , 9, .T., .T., .T. )
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿎odigo da Receita (Obrigatorio) �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸		
	cRetXML += MontaXML( "c02_receita", cCodReceita, , , , ,9, .T., .T., .T. )	
			
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿎odigo do Detalhamento da Receita�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If !Empty( (cAliasQry)->C6S_CODIGO )
		cRetXML += MontaXML( "c25_detalhamentoReceita", (cAliasQry)->C6S_CODIGO, , , , ,9, .T., .T., .T.)
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴�
	//쿎odigo do Produto  �
	//읕컴컴컴컴컴컴컴컴컴�		
	If !Empty( (cAliasQry)->C6U_CODIGO )
		cRetXML += geraProduto(cCodReceita,(cAliasQry)->C09_UF,(cAliasQry)->C6U_CODIGO)
	EndIf
			
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿟ipo de Identificacao do Emitente, de acordo com o Layout quando informada        �
	//쿪 IE do Emitente este campo deve ser emitido, caso contrario eh exibido "1" (CNPJ)�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If Empty( cInsc )		
		cRetXML += MontaXML( "c27_tipoIdentificacaoEmitente", "1", , , , ,9, .T., .T., .T.)
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴�
	//쿎NPJ do Emitente   �
	//읕컴컴컴컴컴컴컴컴컴�				
	If !Empty( SM0->M0_CGC ) .And. Empty( cInsc )  
		cRetXML += MontaXML( "c03_idContribuinteEmitente", , , , , ,9, .T., .F., .T. )  
					
		cRetXML += MontaXML( "CNPJ", SM0->M0_CGC, , , , ,12, .T., .T., .T. )					
			
		cRetXML += MontaXML( "c03_idContribuinteEmitente", , , , , ,9, .F., .T., .T. )  								
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿟ipo do Documento de Origem  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴�			
	If !Empty( (cAliasQry)->C6T_CODIGO )
		cRetXML += MontaXML( "c28_tipoDocOrigem", (cAliasQry)->C6T_CODIGO , , , , ,9, .T., .T., .T. )
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿙umero do Documento de Origem|
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴�			
	If !Empty( (cAliasQry)->C0R_DOCORI )
		cRetXML += MontaXML( "c04_docOrigem", (cAliasQry)->C0R_DOCORI, , , , ,9, .T., .T., .T. )	
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿣alor Original da Guia (Sem Impostos)  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�	
	If !Empty( (cAliasQry)->C0R_VLRPRC )		
		cRetXML += MontaXML( "c06_valorPrincipal", (cAliasQry)->C0R_VLRPRC, "N",6, 2, "@R 9999999999999999999.99", 12, .T., .T., .T. )
	EndIf

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿣alor Original da Guia (Com Impostos)  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�			
	If !Empty( (cAliasQry)->C0R_VLDA )
		cRetXML += MontaXML( "c10_valorTotal", (cAliasQry)->C0R_VLDA, "N",6, 2, "@R 9999999999999999999.99", 12, .T., .T., .T. )
	EndIf
					
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿏ata de Vencimento da Guia (Obrigatorio) �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	cCmpData := Left( (cAliasQry)->C0R_DTVCT, 4) + "-" + Substr( (cAliasQry)->C0R_DTVCT, 5, 2 ) + "-" + Right( (cAliasQry)->C0R_DTVCT, 2 )
	cRetXML  += MontaXML( "c14_dataVencimento", cCmpData, , , , ,9, .T., .T., .T. )
	
	//旼컴컴컴컴컴컴컴컴컴컴컴�
	//쿎odigo do Convenio     �
	//읕컴컴컴컴컴컴컴컴컴컴컴�		
	If !Empty( (cAliasQry)->C0R_CONVEN )
		cRetXML += MontaXML( "c15_convenio", (cAliasQry)->C0R_CONVEN, , , , ,9, .T., .T., .T. )	
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿝azao Social, de acordo com o Layout quando informada    �
	//쿪 IE do Emitente este campo deve ser emitido             �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If Empty( cInsc )  
		If !Empty( SM0->M0_NOMECOM )
			cRetXML += MontaXML( "c16_razaoSocialEmitente", SM0->M0_NOMECOM, , , , ,9, .T., .T., .T. )
		EndIf
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿔nscricao Estadual do Emitente     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�				
	If !Empty( cInsc )

		cRetXML += MontaXML( "c17_inscricaoEstadualEmitente", cInsc, , , , ,9, .T., .T., .T. )			

	Else

    	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿐ndereco do Emitente, de acordo com o Layout quando informada    �
		//쿪 IE do Emitente este campo deve ser emitido                     �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

		If !Empty( SM0->M0_ENDCOB )
			cRetXML += MontaXML( "c18_enderecoEmitente" , SM0->M0_ENDCOB, , , , ,9, .T., .T., .T. )
		EndIf
       
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿘unicipio do Emitente, de acordo com o Layout quando informada     �
		//쿪 IE do Emitente este campo deve ser emitido                       �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

		If !Empty( SM0->M0_CODMUN )		
			cRetXML += MontaXML( "c19_municipioEmitente", Right( Alltrim( SM0->M0_CODMUN ), 5 ), , , , ,9, .T., .T., .T. )
		EndIf
        
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿢F do Emitente, de acordo com o Layout quando informada            �
		//쿪 IE do Emitente este campo deve ser emitido                       �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

		If !Empty( SM0->M0_ESTCOB )
			cRetXML += MontaXML( "c20_ufEnderecoEmitente" , SM0->M0_ESTCOB, , , , ,9, .T., .T., .T. )
		EndIf
	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿎EP do emitente, de acordo com o Layout quando informada           �
		//쿪 IE do Emitente este campo deve ser emitido                       �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�		

		If !Empty(SM0->M0_CEPCOB )
			cRetXML += MontaXML( "c21_cepEmitente",SM0->M0_CEPENT, , , , ,9, .T., .T., .T. )
		EndIf
	
	    //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿟elefone do emitente, de acordo com o Layout quando informada      �
		//쿪 IE do Emitente este campo deve ser emitido                       �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�				

		If !Empty( SM0->M0_TEL )
			cRetXML += MontaXML( "c22_telefoneEmitente", SM0->M0_TEL, , , , ,9, .T., .T., .T. )
		EndIf

	EndIf
			
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿎aso seja informado o Participante no cadastro de Guias, deve-se gerar �
	//쿪s informacoes de destinatario (Substituicao Tributaria)               �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If !Empty( (cAliasQry)->C0R_CDPART ) .And. lPartDest
		                                                         			
		//旼컴컴컴컴컴컴컴컴컴�
		//�1 = Pessoa Juridica�
		//�2 = Pessoa Fisica  �
		//읕컴컴컴컴컴컴컴컴컴�
		cTpPessoa := Iif( (cAliasQry)->C1H_PPES == "1" , "2", "1" )
					 		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿟ipo de Identificacao do Destinatario�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		cRetXML += MontaXML( "c34_tipoIdentificacaoDestinatario", cTpPessoa , , , , ,9, .T., .T., .T. )				  

   		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿔nscricao Estadual do Destinatario�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸       	    
		If !Empty((cAliasQry)->C1H_IE)					
			cRetXML += MontaXML( "c36_inscricaoEstadualDestinatario", AllTrim((cAliasQry)->C1H_IE), , , , ,9, .T., .T., .T. )				
        Else
			//旼컴컴컴컴컴컴컴컴컴컴컴커
			//쿎PF/CNPJ do Destinatario�
			//읕컴컴컴컴컴컴컴컴컴컴컴켸
			If cTpPessoa == "1" 
				If !Empty( (cAliasQry)->C1H_CNPJ ) 
					cRetXML += MontaXML( "c35_idContribuinteDestinatario", , , , , ,9, .T., .F., .T. )  			
					
						cRetXML += MontaXML( "CNPJ", (cAliasQry)->C1H_CNPJ, , , , ,12, .T., .T., .T. )             
						
					cRetXML += MontaXML( "c35_idContribuinteDestinatario", , , , , ,9, .F., .T., .T. )  				
				EndIf
			Else 
				If !Empty( (cAliasQry)->C1H_CPF )                       
					cRetXML += MontaXML( "c35_idContribuinteDestinatario", , , , , ,9, .T., .F., .T. )
					  			
						cRetXML += MontaXML( "CPF", (cAliasQry)->C1H_CPF, , , , ,12, .T., .T., .T. )               
						
					cRetXML += MontaXML( "c35_idContribuinteDestinatario", , , , , ,9, .F., .T., .T. )  			
				EndIf
			EndIf						
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿝azao Social do Destinatario      �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸			
			If !Empty( (cAliasQry)->C1H_NOME )
				cRetXML += MontaXML( "c37_razaoSocialDestinatario", (cAliasQry)->C1H_NOME, , , , ,9, .T., .T., .T. )
			EndIf		
		EndIf

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿎odigo do Municipio do Destinatario �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸						
		If !Empty( (cAliasQry)->C1H_CODMUN )   				
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿎aso encontre o ID na tabela de cadastro de Municipios (C07) realizo a impressao�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If A102PosID( "C07", 3, (cAliasQry)->C1H_CODMUN )
				cRetXML += MontaXML( "c38_municipioDestinatario", C07->C07_CODIGO, , , , ,9, .T., .T., .T. )
			EndIf
		EndIf
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿏ata de Pagamento da Guia (Obrigatorio)  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If (!Empty(AllTrim((cAliasQry)->C0R_DTPGT)))
		cCmpData := Left( (cAliasQry)->C0R_DTPGT, 4) + "-" + Substr( (cAliasQry)->C0R_DTPGT, 5, 2 ) + "-" + Right( (cAliasQry)->C0R_DTPGT, 2 )	
	Else
		cCmpData := "0000-00-00"
	EndIf			
	cRetXML += MontaXML( "c33_dataPagamento", cCmpData, , , , ,9, .T., .T., .T. )			
			
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿛eriodo, Mes, Ano e Parcela a qual se refere a Guia �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If !Empty( (cAliasQry)->C0R_PERIOD )
		cRetXML += MontaXML( "c05_referencia", , , , , ,9, .T., .F., .T. )  							
			
			If lPeriodo 
				If !Empty(AllTrim((cAliasQry)->C0R_REFERE))
					cRetXML += MontaXML( "periodo", (cAliasQry)->C0R_REFERE, , , , ,12, .T., .T., .T. )
				EndIf
			EndIf
			
			cRetXML += MontaXML( "mes", Left( (cAliasQry)->C0R_PERIOD, 2 ), , , , ,12, .T., .T., .T. )
			cRetXML += MontaXML( "ano", Right( (cAliasQry)->C0R_PERIOD, 4) , , , , ,12, .T. , .T., .T. ) 
			  
			If lParcela			
				If !Empty( (cAliasQry)->C0R_NUMPAR ) 
					cRetXML += MontaXML( "Parcela", (cAliasQry)->C0R_NUMPAR, , , , ,12, .T., .T., .T. )
				Else
					cRetXML += MontaXML("parcela","1","N",,,,12,.T.,.T.,.T.)
				EndIf
			EndIf
			
		cRetXML += MontaXML( "c05_referencia" , , , , , ,9, .F. , .T. , .T. )  								
	EndIf 
			                                                            				
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿣erifico atrtaves do ID se existem informacoes de campos extras para o documento, caso exista�
	//퀁ealizo a impressao de todos de acordo com o Layout da GNRE Online                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If A102PosID( "C6Q", 1, (cAliasQry)->C0R_ID )
		cRetXML += MontaXML( "c39_camposExtras", , , , , ,9, .T., .F., .T. )
		While C6Q->( !Eof() ) .And. C6Q->C6Q_ID == (cAliasQry)->C0R_ID										
			cRetXML += MontaXML( "campoExtra", , , , , ,12, .T., .F., .T. ) 
			cRetXML += MontaXML( "codigo"    , C6Q->C6Q_CODIGO, , , , ,15, .T., .T., .T. )
			cRetXML += MontaXML( "tipo"      , C6Q->C6Q_TIPO, , , , ,15, .T., .T., .T. )
			cRetXML += MontaXML( "valor"     , C6Q->C6Q_VLRCMP,,,,,15,.T.,.T.,.T.) 										
			cRetXML += MontaXML( "campoExtra", , , , , ,13, .F., .T., .T., .T. )     				
			C6Q->( DbSkip( ) )
		EndDo
		cRetXML += MontaXML( "c39_camposExtras", , , , , ,9, .F., .T., .T., .T. )     
	EndIf	                                                    
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿑inaliza Impressao da GNRE  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸		
	
	cRetXML += MontaXML( "TDadosGNRE", , , , , ,6, .F., .T., .T. ) 	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿙o momento da gera豫o da guia o sistema altera o conte�do�
	//쿭o campo C0R_PROCES para que na pr�xima gera豫o o sistema�
	//쿻�o trava guias j� geradas.                              �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	dbSelectArea("C0R")
	DbSetOrder(6)
	if TAFColumnPos("C0R_PROCES")
		IF C0R->( DbSeek(xFilial("C0R") + (cAliasQry)->C0R_ID,.T. )) 
			If ( Empty(C0R->C0R_PROCES) .Or. C0R->C0R_PROCES=="2" )
				RecLock("C0R",.F.)
				C0R->C0R_PROCES := "1"
				C0R->(MsUnlock())
			Endif									
			C0R->( DbSkip( ) )
		Endif
	Endif

	(cAliasQry)->( DbSkip( ) )

EndDo

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿑inaliza Cabecalho do Arquivo XML   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
cRetXML := A102Cabec( @cRetXML, !lInicioXml )	

Return ( cRetXML )      

//-------------------------------------------------------------------
/*/{Protheus.doc} A102Cabec
Geracao do Cabecalho do Arquivo XML

@Param  cRetXML    - String com Cabecalho XML
@Param  lInicioXML - Define se esta Iniciando ou Finalizando o Arquivo XML

@return cRetXML - String com Cabecalho XML

@author Rodrigo Aguilar
@since 17/09/2012
@version 1.0
/*/
//------------------------------------------------------------------- 	
Static Function A102Cabec( cRetXML, lInicioXML )

If lInicioXML
	cRetXML += MontaXML( "?xml",,,,,,,.T.,.F.,.T.,"version="+'"1.0"'+" encoding="+'"UTF-8" standalone="yes"'+" ?" )
	cRetXML += MontaXML( "TLote_GNRE",,,,,,,.T.,.F.,.T.,' xmlns="http://www.gnre.pe.gov.br"' )
	cRetXML += MontaXML( "guias",,,,,,3,.T.,.F.,.T. )  
Else
	cRetXML += MontaXML( "guias",,,,,,3,.F.,.T.,.T.,.T. )     
	cRetXML += MontaXML( "TLote_GNRE",,,,,,,.F.,.T.,.T.,' xmlns="http://www.gnre.pe.gov.br"' )	
EndIf

Return ( cRetXML ) 

//-------------------------------------------------------------------     
/*/{Protheus.doc} A102Wizard   

Funcao responsavel pela montagem do Wizard da rotina

@param cNomWiz - Nome do Wizard utilizado no processamento dos layouts

@return lRet - Flag de sucesso de processamento, .T. = Wizard concluido com sucesso, .F. = Assistente cancelado

@author Rodrigo Aguilar
@since 17/09/2012
@version 1.0  
   
/*/
//------------------------------------------------------------------- 
Static Function A102Wizard ( cNomWiz ) 
                              
Local	cTitObj1		:=	""       
Local   cTitObj2        :=  ""
Local	aTxtApre		:=	{}
Local	aPaineis		:=	{}
Local	lRet			:=	.T.

aAdd ( aTxtApre , STR0005 ) //"Guia Naciona de Recolhimento (GNRE)"
aAdd ( aTxtApre , "" )	
aAdd ( aTxtApre , STR0006 ) //"Emiss�o da Guia Nacional de Recolhimento (GNRE)"
aAdd ( aTxtApre , STR0007 ) //"Esta rotina tem como objetivo realizar a emiss�o da Guia Nacional de Recolhimento (GNRE)  "

//旼컴컴컴컴컴컴컴커
//쿘ontando Wizard �
//읕컴컴컴컴컴컴컴켸	
aAdd ( aPaineis , {} )
nPos	:=	Len ( aPaineis )
aAdd ( aPaineis[nPos] , "" ) 
aAdd ( aPaineis[nPos] , STR0008 ) //"Defini豫o dos Par�metros para Gera豫o"
aAdd ( aPaineis[nPos] , {} )

//旼컴컴컴컴컴컴컴컴컴컴커                                	//旼컴컴컴컴컴컴컴컴컴커																	
//쿏efinicao do Periodo  �										//쿏efine Modelo DA ?  �
//읕컴컴컴컴컴컴컴컴컴컴켸										//읕컴컴컴컴컴컴컴컴컴켸
cTitObj1	:=	STR0009;											cTitObj2	:=	STR0013    //"Per�odo (MMAAAA) # Modelo DA ? "
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

aItens1	:=	{}	
aAdd (aItens1, STR0014) 			//"0-DA Estadual"
aAdd (aItens1, STR0015)			//"1-GNRE"	

cTitObj1	:=	Replicate ("X", 6)								
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,6});				aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})			
			
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴�									//旼컴컴컴컴컴컴컴컴컴컴컴컴컴�  
//쿏efinicao do Num.Docto De  �									//쿏efinicao do Num.Docto Ate �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴�									//읕컴컴컴컴컴컴컴컴컴컴컴컴컴�
cTitObj1	:=	STR0011;		 									cTitObj2	:=	STR0012    				//"Num.Docto De ? "#"Num.Docto Ate ? "
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

cTitObj1	:=	Replicate ("X", 60);								cTitObj2	:=	Replicate ("X", 60)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,60});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,60})

aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})

//旼컴컴컴컴컴컴컴컴�
//쿏efinicao da UF  �
//읕컴컴컴컴컴컴컴컴�
cTitObj1 := "Id da UF (Deixar em branco para todas)" ; 									cTitObj2 := "Descri豫o da UF" //"UF # Descri豫o da UF"
aAdd (aPaineis[nPos][3],{1,cTitObj1,,,,,,});												aAdd (aPaineis[nPos][3],{1,cTitObj2,,,,,,})
																								cTitObj2	:=	Replicate ("X", 30)	
aAdd( aPaineis[nPos][3],{2,,"",1,,,,6,,,"C09",,{ "xFunVldWiz", "UF-GNRE" } });   	aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 30, { .T., "" } } )	
						
aAdd (aPaineis[nPos][3], {0,"",,,,,,});													aAdd (aPaineis[nPos][3], {0,"",,,,,,})

//旼컴컴컴컴컴컴컴컴컴�             						   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿙ome do Arquivo    �			   							   //쿏iretorio para gravacao do arquivo .XML gerado�
//읕컴컴컴컴컴컴컴컴컴� 						            -   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cTitObj1	:=	STR0017;				 						cTitObj2	:=	STR0016					//"Diret�rio do Arquivo Destino"#"Nome do Arquivo Destino"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,}); 				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

cTitObj1	:=	Replicate ("X", 20); 					   		cTitObj2	:=	Replicate ("X", 50)							
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,20});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50})

aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//旼컴컴컴컴컴컴컴컴컴�
//쿌crescentar Serie  �
//읕컴컴컴컴컴컴컴컴컴�
cTitObj1	:=	"Para gerar a guia filtrada por s�rie de NF, ";	cTitObj2	:=	""	
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1,"",,,,,,})
cTitObj1	:=	"informe as s�ries separadas por (;) Ex: 01;02;";cTitObj2	:=	""
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1,"",,,,,,})
//
cTitObj1	:=	Replicate ("X", 20);									cTitObj2	:=	""
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,20});					aAdd (aPaineis[nPos][3], {1,"",,,,,,})	
 			
aAdd (aPaineis[nPos][3], {0,"",,,,,,})

lRet	:=	XFUNWizard ( aTxtApre , aPaineis , cNomWiz )

Return ( lRet )

//-------------------------------------------------------------------     
/*/{Protheus.doc} A102PosID   

Realiza o posicionamento na tabela de acordo com o ID informado, 
permitindo assim a utilizacao das informacoes do cadastro.

Ex: 
Tenho no campo C0R_UF o ID 000001, assim utilizando esta funcao
temos como retorno o posicionamento na tabela para que possamos
exibir a informacao SP

@Param cAlias   - Alias da tabela de Busca
@Param nIndice  - Indice de busca na tabela
@Param cChave  -  Chave de busca

@Return lRet - Informa se encontrou o registro na tabela

@author Rodrigo Aguilar
@since 25/10/2012
@version 1.0  
   
/*/
//------------------------------------------------------------------- 
Static Function A102PosID( cAlias, nIndice, cChave )

Local lRet := .F. 

(cAlias)->( DbSetOrder ( nIndice ) )
If (cAlias)->( DbSeek ( xFilial( cAlias ) + cChave ) )
	lRet := .T.
EndIf

Return ( lRet )

//-------------------------------------------------------------------     
/*/{Protheus.doc} A102QryPrin   

Realizada a execucao da Query Principal para emissao da GNRE / Geracao do Arquivo Magnetico

@Param cAliasQry - Alias para geracao da Query
@Param aParm     - Parametros definidos pelo usuario    

@Return lRet - Verifica se foram encontrados registros na Query

@author Rodrigo Aguilar
@since 17/09/2012
@version 1.0  
   
/*/
//------------------------------------------------------------------- 
Function A102QryPrin( cAliasQry, aParam )          

Local lRet      := .T.      
Local cWhere    := "%"
Local cUFEmp	:= GetNewPar("MV_TAFUF","")
Local cSerieFil := ""
Local nPosIni   := 0
Local nPosFim   := 0
Local aRetQry   := {}

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿏efinindo os filtros que serao realizados na query�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cWhere  +=	"C0R.C0R_FILIAL = '"+ xFilial("C0R") + "' AND " 
cWhere	 +=	"C0R.C0R_PERIOD = '"+ aParam[1] + "' AND "
cWhere  +=	"C0R.C0R_NUMDA >= '" + Alltrim(aParam[3]) + "' AND C0R.C0R_NUMDA <= '" + Alltrim(aParam[4]) + "' AND "
cWhere  +=	"C0R.C0R_CODDA = '"+ aParam[5] + "' AND " 
cWhere  +=	"C09.C09_UF <> '" + cUFEmp + "' AND "

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿟ratamento para filtrar somente guias ainda n�o geradas     �  
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

if TAFColumnPos("C0R_PROCES")
	cWhere  +=	"(C0R.C0R_PROCES = '' OR C0R.C0R_PROCES = '2') AND "
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿟ratamento para filtrar as s�ries esoclhidas para o filtro  �  
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cSerieFil	:= aParam[6]
If Len(Alltrim(cSerieFil)) > 0
	If Substr(cSerieFil,Len(Alltrim(cSerieFil)), Len(Alltrim(cSerieFil))) <> ';'
		cSerieFil += ';'
	EndIf
				
	cWhere  +=	" C20_SERIE IN ("
	nPosIni	:= 1
	nPosFim	:= AT(';',cSerieFil)
	While	nPosIni < Len(Alltrim(cSerieFil))
		cWhere	+=	"'" + Substr(Alltrim(cSerieFil),nPosIni,nPosFim - 1) + "'"
		nPosIni := nPosIni + nPosFim
		nPosFim   := AT(';',Substr(Alltrim(cSerieFil),nPosIni,Len(Alltrim(cSerieFil))))
					
		If 	nPosIni < Len(Alltrim(cSerieFil))
			cWhere	+=	","
		EndIf
	EndDo
	cWhere	+=	") AND "
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿟ratamento para se buscar apenas a UF definida no parametro�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty( aParam[2] ) .And. Alltrim( Upper( aParam[2] ) ) <> "ZZ"         
  	cWhere  +=  "C09.C09_UF='"+ aParam[2]+ "' AND "
EndIf	                                         
cWhere += "%"         

cAliasQry := GetNextAlias()

BeginSql Alias cAliasQry
	SELECT			    	 
		C0R.C0R_PERIOD, C0R.C0R_VLRPRC, C0R.C0R_ATUMON, C0R.C0R_JUROS , C0R.C0R_MULTA  , 
		C0R.C0R_VLDA  , C0R.C0R_DTVCT , C0R.C0R_DTPGT , C0R.C0R_DOCORI, C0R.C0R_CONVEN , 
		C0R.C0R_NUMPAR, C0R.C0R_REFERE, C0R.C0R_CDPART, C0R.C0R_ID    , C0R.C0R_DESDOC ,
		C1H.C1H_PPES  , C1H.C1H_CPF   , C1H.C1H_CNPJ  , C1H.C1H_IE    , C1H.C1H_NOME   , 
		C1H.C1H_CODMUN, C09.C09_CODUF , C09.C09_DESCRI, C09.C09_UF    , C6R.C6R_CODIGO , 
		C6S.C6S_CODIGO, C6U.C6U_CODIGO, C6T.C6T_CODIGO, C0R.C0R_FILIAL, C0R.C0R_UF		,
		C1H.C1H_UF    , C0R.C0R_CODDA , C20.C20_CHVNF ,  C20.C20_SERIE, C0R.C0R_ID
	FROM 
		%Table:C0R% C0R  		
		LEFT JOIN %Table:C1H% C1H ON ( C1H.C1H_FILIAL = %xFilial:C1H% AND C0R.C0R_CDPART = C1H.C1H_ID AND C1H.%NotDel% )  
		LEFT JOIN %Table:C09% C09 ON ( C09.C09_FILIAL = %xFilial:C09% AND C0R.C0R_UF     = C09.C09_ID AND C09.%NotDel% )
		LEFT JOIN %Table:C6R% C6R ON ( C6R.C6R_FILIAL = %xFilial:C6R% AND C0R.C0R_CODREC = C6R.C6R_ID AND C6R.%NotDel% )
		LEFT JOIN %Table:C6S% C6S ON ( C6S.C6S_FILIAL = %xFilial:C6S% AND C0R.C0R_DETREC = C6S.C6S_ID AND C6S.%NotDel% )
		LEFT JOIN %Table:C6T% C6T ON ( C6T.C6T_FILIAL = %xFilial:C6T% AND C0R.C0R_TIPDOC = C6T.C6T_ID AND C6T.%NotDel% )
		LEFT JOIN %Table:C6U% C6U ON ( C6U.C6U_FILIAL = %xFilial:C6U% AND C0R.C0R_CODPRD = C6U.C6U_ID AND C6U.%NotDel% )
	  	//ACRESCENTADO PARA FILTRO DE SERIE DE NF - CONFORME CHAMADO TUTICM - 13/03/2017 
		LEFT JOIN %Table:C25% C25 ON ( C25.C25_FILIAL = %xFilial:C0R% AND C0R.C0R_ID     = C25.C25_IDENTI AND C25.%NotDel% )
		LEFT JOIN %Table:C20% C20 ON ( C20.C20_FILIAL = %xFilial:C25% AND C20.C20_CHVNF  = C25.C25_CHVNF  AND C20.%NotDel% )  	

	WHERE              
		%Exp:cWhere%		
		C0R.%NotDel% 
EndSql	 

aRetQry := GetLastQuery(2)

DbSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )  			
If ( cAliasQry )->( Eof() )
	lRet := .F.
EndIf

Return ( lRet )

//-------------------------------------------------------------------     
/*/{Protheus.doc} NorDir   

Normaliza o diretorio para a gera豫o da gnre, acrescentando uma "barra"
no final caso a mesma n�o tenha sido informada.

@Param NorDir - Diretorio informado na Wizard

@Return Nil

@author Evandro dos Santos O. Teixeira
@since 16/11/2016
@version 1.0  
   
/*/
//------------------------------------------------------------------- 
Static Function NorDir(cDir)

	Local nVersaoRemote := GetRemoteType() 
	Local cBarra := "\"

	If (nVersaoRemote == 2)
		cBarra := "/"
	EndIf
	
	If SubStr(cDir,Len(cDir)) != cBarra
		cDir += cBarra
	EndIf

Return Nil 

//-------------------------------------------------------------------     
/*/{Protheus.doc} NorFile   

Normaliza nome e extens�o do arquivo da Gnre garantindo a extens�o xml.

@Param cFile - Nome do arquivo informado na Wizard

@Return boolean - Returna True para se a extens�o n�o existir ou for
igual a .xml

@author Evandro dos Santos O. Teixeira
@since 16/11/2016
@version 1.0  
   
/*/
//------------------------------------------------------------------- 
Static Function NorFile(cFile)

	Local nPosPonto := 0
	
	nPosPonto := RAT(".",cFile)

	If nPosPonto > 0
		If Lower(Substr(cFile,nPosPonto)) != ".xml"
			Return(.F.)
		EndIf
	Else
		cFile += ".xml"
	EndIf

Return(.T.)

//-------------------------------------------------------------------     
/*/{Protheus.doc} geraProduto   

Cria a tag produto de acordo com a regra do estado

@Param cCodRec  - Codigo da Receita
@Param cUFDest  - UF do Destinat�rio
@Param cCodProd - Codigo do produto de acordo com a tabela disponibilizada
no site da genre.pe  

@Return Tag do produto

@author Evandro dos Santos O. Teixeira
@since 16/11/2016
@version 1.0  
   
/*/
//------------------------------------------------------------------- 
Static Function geraProduto(cCodRec,cUFDest,cCodProd)

	If cCodRec == "100048"
		If cUFDest  $ "AL|GO|MA|MG|PI|RN|RO|SE|TO|CE|MS|RR|DF"
			Return MontaXML("c26_produto",cCodProd,"N",9,2,,9,.T.,.T.,.T.)
		EndIf
	ElseIf cCodRec == "100099"
		If cUFDest $ "AC|AL|AM|BA|CE|DF|GO|MA|MS|PE|PI|RN|RO|RR|SC|SE|TO"
			Return MontaXML("c26_produto",cCodProd,"N",9,2,,9,.T.,.T.,.T.)
		EndIf
	Else
		Return MontaXML("c26_produto",cCodProd,"N",9,2,,12,.T.,.T.,.T.)
	EndIf
		
Return "" 

