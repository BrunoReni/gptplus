#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTABLE.CH"

#DEFINE FIELD 	1
#DEFINE TYPE 	2
#DEFINE LENGHT 	3
#DEFINE DECIMAL 4

Static __aPK

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTable
Respons�vel pela verifica��o da tabela, ou seja, cria quando n�o existir
e caso contr�rio verifica pela sua estrutura

@param cTable, caracter, Nome da tabela no Protheus
@param aField, array, Defini��o dos campos da tabela
@param aIndex, array,Defini��o dos �ndices da tabela

@author  Valdiney V GOMES
@since   14/02/2017
/*/
//-------------------------------------------------------------------
function BIXTable( cTable, aField, aIndex )
	Local oTable	:= nil
	Local aKey		:= {}
	Local nField	:= 0
	Local nIndex	:= 0
	
	Default cTable	:= ""
	Default aField	:= {}
	Default aIndex	:= {}

	oTable	:= TBITable():New( cTable, cTable ) 
	
	//-------------------------------------------------------------------
	// Habilita o log da TBITable. 
	//-------------------------------------------------------------------       
	oTable:bLogger( {|x| BIXSysOut("BIXTABLE", cTable + " " + x )} )

	//-------------------------------------------------------------------
	// Recupera os campos e os �ndices da tabela. 
	//-------------------------------------------------------------------
	If ( Empty( aField ) )
	   	aField := BIXField( cTable ) 
	   	
	   	If ( Empty( aField ) )
	   		BIXSysOut( "BIXTABLE", cTable + STR0001 ) //" estrutura de campos n�o encontrada!" 
 			Return 	   	
	   	EndIf		
	EndIf

	If ( Empty( aIndex ) )
		aIndex := BIXIndex( cTable )
			
		If ( Empty( aIndex ) )
	 		BIXSysOut( "BIXTABLE", cTable + STR0002 ) //" estrutura de �ndices n�o encontrada!"
	 		Return 		
		EndIf
	EndIf
            
	//-------------------------------------------------------------------
	// Monta a estrutura de campos da tabela. 
	//-------------------------------------------------------------------
	For nField := 1 To Len( aField )
 		oTable:addField( TBIField():New( aField[nField][FIELD], aField[nField][TYPE], aField[nField][LENGHT], aField[nField][DECIMAL] ))		
	Next nField    

	//-------------------------------------------------------------------
	// Monta a estrutura de �ndices da tabela. 
	//-------------------------------------------------------------------
	For nIndex := 1 To Len( aIndex )  
		If ( ValType( aIndex[nIndex] ) == "C" ) 
			aKey := aBIToken( aIndex[nIndex], "+", .F. )  
		Else
			aKey := aIndex[nIndex]	
		EndIf 

		oTable:addIndex(TBIIndex():New( cTable + cBIStr( nIndex ), aKey, .F.) )  
	Next nIndex
 
	//-------------------------------------------------------------------
	// Cria/Atualiza a tabela no banco. 
	//-------------------------------------------------------------------	             
	oTable:ChkStruct( .F., .F., .T., .T., .T. )
	
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXField
Recupera os campos de uma tabela da Fluig Smart Data. 

@param cTable, caracter, Nome da tabela. 
@return aField, Campos da tabela no formato { NOME, TIPO, TAMANHO, DECIMAL }

@author  M�rcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Static Function BIXField( cTable )
	Local aField 	:= {}

	Default cTable 	:= ""

	DBSelectArea("SX3")
	SX3->( DBSetOrder( 1 ) )

	//-------------------------------------------------------------------
	// Procura pela tabela no dicion�rio de dados. 
	//------------------------------------------------------------------- 
	If ( SX3->( DBSeek( cTable ) ) )
		While ( ! SX3->( EoF( ) ) .And. SX3->X3_ARQUIVO == cTable )
			//-------------------------------------------------------------------
	   		// Recupera os campos da tabela.  
			//------------------------------------------------------------------- 			
			aAdd( aField, { AllTrim( SX3->X3_CAMPO ), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
			SX3->( DBSkip( ) )
		EndDo 
	EndIf 	
return aField

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXIndex
Recupera os indexes de uma tabela da Fluig Smart Data. 

@param cTable, caracter, Nome da tabela
@return aIndex,	Indexes da tabela. 

@author  M�rcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Static function BIXIndex( cTable )
	Local aIndex 	:= {}

	Default cTable 	:= ""

	DBSelectArea( "SIX" )
	SIX->( DBSetOrder( 1 ) )

	//-------------------------------------------------------------------
	// Procura pela tabela no dicion�rio de dados. 
	//------------------------------------------------------------------- 
	If ( SIX->( DBSeek( cTable ) ) )
		While ( ! SIX->( EoF( ) ) .And. SIX->INDICE == cTable )
			//-------------------------------------------------------------------
	   		// Recupera os indexes da tabela.  
			//------------------------------------------------------------------- 
			aAdd( aIndex, AllTrim(SIX->CHAVE) )
			SIX->( dbSkip( ) )
		EndDo
	EndIf	
return aIndex

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPK
Recupera o campo chave prim�ria.

@param cTable, caracter, Nome da tabela do ERP. 
@param lFunction, l�gico, Define se adiciona fun��es na express�o.
@return cPK, caracter, Retorna a chave �nica cadastrada.

@author  M�rcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
function BIXPK( cTable )
  	Local aField	:= {}
  	Local cPK 		:= ""
  	Local cKey		:= ""
  	Local cAux		:= ""
	Local nTable  	:= 0
	Local nField	:= 0

	Default cTable := ""

  	If ( __aPK == nil )
  		__aPK := {}
  	EndIf 

	//-------------------------------------------------------------------
	// Identifica se a PK da tabela foi processada anteriormente. 
	//------------------------------------------------------------------- 
  	nTable := AScan( __aPK, { | x | x[1] == cTable } )

	If ( Empty( nTable ) )
	  	If ( cTable == "SX5" )
	  		cPK := "X5_FILIAL+X5_CHAVE"
	  	Else
	  	SX2->( DBSetOrder( 1 ) )
	
	    	If ( SX2->( DBSeek( cTable ) ) )
				//-------------------------------------------------------------------
				// Recupera a chave �nica da tabela. 
				//------------------------------------------------------------------- 	    	
	      		cPK := AllTrim( FWX2Unico( cTable )  )

	      		If ( Empty( cPK ) )
	        		SIX->( DBSetOrder( 1 ) )
	        		
	        		If ( SIX->( DBSeek( cTable ) ) )
	        			//-------------------------------------------------------------------
						// Recupera o primeiro �ndice da tabela. 
						//------------------------------------------------------------------- 
	          			cPK := AllTrim( SIX->CHAVE )
	        		EndIf
	      		EndIf

    			//-------------------------------------------------------------------
				// Identifica se a PK cont�m fun��o. 
				//------------------------------------------------------------------- 
        		If ( ! Empty( At( "(", cPK ) ) .And. ! Empty( At( ")", cPK ) ) )
          			cKey	:= ""
          			cAux 	:= ""
          			aField 	:= aBIToken( cPK, "+" )
          			
          			For nField := 1 to len(aField)
            			cAux := aField[nField]
            			
            			//-------------------------------------------------------------------
      					// Remove as fun��es de cada campo da PK. 
						//------------------------------------------------------------------- 
            			If ( ! Empty( At( "(", cAux) ) .And. ! Empty( At( ")", cAux ) ) )
              				cAux := Substr( cAux, At( "(", cAux ) + 1 )

              				If ! Empty( At(",", cAux) )
              					cAux := Substr( cAux, 0, At( ",", cAux ) - 1 )
              				Else
              					cAux := Substr( cAux, 0, At( ")", cAux ) - 1 )
              				EndIf
            			EndIf
          			
            			If ( Empty( cKey ) )
            				cKey += cAux
            			Else
            				cKey += "+" + cAux
            			EndIf
          			Next nField
          			
          			cPK := cKey
        		EndIf
	    	EndIf
	  	EndIf
	  	
	  	//-------------------------------------------------------------------
		// Mant�m a PK em mem�ria. 
		//------------------------------------------------------------------- 	  	
		Aadd(__aPK, { cTable, cPK } )
	Else
		cPK := __aPK[nTable][2]
	EndIF
return cPK


//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSetupTable
Cria��o das entidades da engine na Fluig Smart Data.

@param cTable. 

@author  Andr�ia Lima
@since   31/07/2017
/*/
//-------------------------------------------------------------------
function BIXSetupTable( cTable )
	Local aField := {}
	Local aIndex := {}
	
	Do Case
		Case cTable == 'HJJ' //Dimens�o Per�odo Extra��o

			AADD(aField,{"HJJ_FILIAL", "C", FWSizeFilial(), 00}) //Filial do sistema
			AADD(aField,{"HJJ_EMPRES", "C", 32, 00}) //Empresa
			AADD(aField,{"HJJ_ESTABL", "C", 32, 00}) //Estabelecimento
			AADD(aField,{"HJJ_CDFATO", "C", 03, 00}) //identificador de Tabela
			AADD(aField,{"HJJ_INFPER", "C", 01, 00}) //Informa Per�odo?
			AADD(aField,{"HJJ_TIPPER", "C", 01, 00}) //Tipo de Per�odo
			AADD(aField,{"HJJ_TIPFXA", "C", 01, 00}) //Tipo de faixa do per�odo
			AADD(aField,{"HJJ_PERINI", "C", 08, 00}) //Per�odo Inicial
			AADD(aField,{"HJJ_PERFIN", "C", 08, 00}) //Per�odo Final
			AADD(aField,{"HJJ_LIVRE0", "C", 50, 00}) //Livre 0			
			AADD(aField,{"HJJ_LIVRE1", "C", 50, 00}) //Livre 1
			AADD(aField,{"HJJ_LIVRE2", "C", 50, 00}) //Livre 2			
			AADD(aField,{"HJJ_LIVRE3", "C", 50, 00}) //Livre 3
			AADD(aField,{"HJJ_LIVRE4", "C", 50, 00}) //Livre 4
			AADD(aField,{"HJJ_LIVRE5", "C", 50, 00}) //Livre 5
			AADD(aField,{"HJJ_LIVRE6", "C", 50, 00}) //Livre 6
			AADD(aField,{"HJJ_LIVRE7", "C", 50, 00}) //Livre 7
			AADD(aField,{"HJJ_LIVRE8", "C", 50, 00}) //Livre 8
			AADD(aField,{"HJJ_LIVRE9", "C", 50, 00}) //Livre 9	
			
			AADD(aIndex,{"HJJ_FILIAL", "HJJ_CDFATO", "HJJ_INFPER", "HJJ_TIPPER", "HJJ_TIPFXA", "HJJ_PERINI", "HJJ_PERFIN"}) //Identificad. + Informa + Tipo Periodo + Tipo Faixa + Per. Inicial + Pe  
			AADD(aIndex,{"HJJ_FILIAL", "HJJ_EMPRES", "HJJ_ESTABL", "HJJ_CDFATO"}) //Empresa + Estabelecime + Identificad. 																																
		
		Case cTable == 'HJK' //Dimens�o Par�metro Extra��o
		
			AADD(aField,{"HJK_CPARAM", "C", 10, 00}) //Par�metro-C�digo
			AADD(aField,{"HJK_FILIAL", "C", FWSizeFilial(), 00}) //Filial do sistema
			AADD(aField,{"HJK_CDFATO", "C", 03, 00}) //Identificador de Tabela
			AADD(aField,{"HJK_DPARAM", "C", 50, 00}) //Par�metro-descritivo
			AADD(aField,{"HJK_APARAM", "C", 250, 00}) //Par�metro-Ajuda
			AADD(aField,{"HJK_VPARAM", "C", 250, 00}) //Valor-Par�metro
			AADD(aField,{"HJK_LIVRE0", "C", 50, 00}) //Livre 0
			AADD(aField,{"HJK_LIVRE1", "C", 50, 00}) //Livre 1
			AADD(aField,{"HJK_LIVRE2", "C", 50, 00}) //Livre 2
			AADD(aField,{"HJK_LIVRE3", "C", 50, 00}) //Livre 3
			AADD(aField,{"HJK_LIVRE4", "C", 50, 00}) //Livre 4
			AADD(aField,{"HJK_LIVRE5", "C", 50, 00}) //Livre 5
			AADD(aField,{"HJK_LIVRE6", "C", 50, 00}) //Livre 6
			AADD(aField,{"HJK_LIVRE7", "C", 50, 00}) //Livre 7
			AADD(aField,{"HJK_LIVRE8", "C", 50, 00}) //Livre 8
			AADD(aField,{"HJK_LIVRE9", "C", 50, 00}) //Livre 9																																												
		    
		    AADD(aIndex,{"HJK_FILIAL", "HJK_CPARAM", "HJK_CDFATO", "HJK_DPARAM"}) //Codigo + Identificad. + Descritivo 
		    
		Case cTable == 'HKC' //Dimens�o Moeda Extra��o

			AADD(aField,{"HKC_CDFATO", "C", 03, 00}) //Identificador de tabela
			AADD(aField,{"HKC_CDMOED", "C", 10, 00}) //Moeda Extra��o				
			AADD(aField,{"HKC_FILIAL", "C", FWSizeFilial(), 00}) //Filial do sistema
			AADD(aField,{"HKC_LIVRE0", "C", 50, 00}) //Livre 0
			AADD(aField,{"HKC_LIVRE1", "C", 50, 00}) //Livre 1
			AADD(aField,{"HKC_LIVRE2", "C", 50, 00}) //Livre 2
			AADD(aField,{"HKC_LIVRE3", "C", 50, 00}) //Livre 3
			AADD(aField,{"HKC_LIVRE4", "C", 50, 00}) //Livre 4
			AADD(aField,{"HKC_LIVRE5", "C", 50, 00}) //Livre 5
			AADD(aField,{"HKC_LIVRE6", "C", 50, 00}) //Livre 6
			AADD(aField,{"HKC_LIVRE7", "C", 50, 00}) //Livre 7
			AADD(aField,{"HKC_LIVRE8", "C", 50, 00}) //Livre 8
			AADD(aField,{"HKC_LIVRE9", "C", 50, 00}) //Livre 9		
			
			AADD(aIndex,{"HKC_FILIAL", "HKC_CDFATO", "HKC_CDMOED"}) //Identifciad. + Moeda 																																										
		
		Case cTable == 'HK4' //Dimens�o �reas

			AADD(aField,{"HK4_CDAREA", "C", 03, 00}) //Identificador da �rea
			AADD(aField,{"HK4_FILIAL", "C", FWSizeFilial(), 00}) //Filial do Sistema				
			AADD(aField,{"HK4_DSAREA", "C", 50, 00}) //Nome da �rea
			AADD(aField,{"HK4_LIVRE0", "C", 50, 00}) //Livre 0
			AADD(aField,{"HK4_LIVRE1", "C", 50, 00}) //Livre 1
			AADD(aField,{"HK4_LIVRE2", "C", 50, 00}) //Livre 2
			AADD(aField,{"HK4_LIVRE3", "C", 50, 00}) //Livre 3
			AADD(aField,{"HK4_LIVRE4", "C", 50, 00}) //Livre 4
			AADD(aField,{"HK4_LIVRE5", "C", 50, 00}) //Livre 5
			AADD(aField,{"HK4_LIVRE6", "C", 50, 00}) //Livre 6
			AADD(aField,{"HK4_LIVRE7", "C", 50, 00}) //Livre 7
			AADD(aField,{"HK4_LIVRE8", "C", 50, 00}) //Livre 8
			AADD(aField,{"HK4_LIVRE9", "C", 50, 00}) //Livre 9	
			
			AADD(aIndex,{"HK4_FILIAL", "HK4_CDAREA", "HK4_DSAREA"}) //Identificad. + Nome Area  																																											
		
		Case cTable == 'HK3' //Dimens�o Fatos
		
			AADD(aField,{"HK3_CDFATO", "C", 03, 00}) //Identificador de tabela
			AADD(aField,{"HK3_FILIAL", "C", FWSizeFilial(), 00}) //Filial do Sistema				
			AADD(aField,{"HK3_CDAREA", "C", 03, 00}) //Identificador de �rea
			AADD(aField,{"HK3_DSFATO", "C", 50, 00}) //Nome da tabela			
			AADD(aField,{"HK3_EXTRAI", "C", 01, 00}) //Par�metro Extra��o
			AADD(aField,{"HK3_LIVRE0", "C", 50, 00}) //Livre 0
			AADD(aField,{"HK3_LIVRE1", "C", 50, 00}) //Livre 1
			AADD(aField,{"HK3_LIVRE2", "C", 50, 00}) //Livre 2
			AADD(aField,{"HK3_LIVRE3", "C", 50, 00}) //Livre 3
			AADD(aField,{"HK3_LIVRE4", "C", 50, 00}) //Livre 4
			AADD(aField,{"HK3_LIVRE5", "C", 50, 00}) //Livre 5
			AADD(aField,{"HK3_LIVRE6", "C", 50, 00}) //Livre 6
			AADD(aField,{"HK3_LIVRE7", "C", 50, 00}) //Livre 7
			AADD(aField,{"HK3_LIVRE8", "C", 50, 00}) //Livre 8
			AADD(aField,{"HK3_LIVRE9", "C", 50, 00}) //Livre 9																																												
			
			AADD(aIndex,{"HK3_FILIAL", "HK3_CDFATO", "HK3_CDAREA", "HK3_DSFATO", "HK3_EXTRAI"}) //Identificad. + Identif Area + Nome Tabela + Parametro   
		
		Case cTable == 'HH1' //Configura��o Consolida��o de Moedas
		
			AADD(aField,{"HH1_ISTCIA", "C", 02, 00}) //Inst�ncia
			AADD(aField,{"HH1_LINPRO", "C", 02, 00}) //Linha de Produto
			AADD(aField,{"HH1_GRPEMP", "C", 10, 00}) //Grp Empresa
			AADD(aField,{"HH1_CDUNEG", "C", 10, 00}) //Unidade de neg�cio
			AADD(aField,{"HH1_CDEMPR", "C", 10, 00}) //Empresa
			AADD(aField,{"HH1_FILIAL", "C", FWSizeFilial(), 00}) //Filial
        	AADD(aField,{"HH1_TIPALU", "C", 32, 00}) //Tipo Aluno
			AADD(aField,{"HH1_CODIGO", "C", 10, 00}) //C�digo
			AADD(aField,{"HH1_DESC  ", "C", 60, 00}) //Desc Tp Aluno
			AADD(aField,{"HH1_LIVRE0", "C", 50, 00}) //Livre 0
			AADD(aField,{"HH1_LIVRE1", "C", 50, 00}) //Livre 1
			AADD(aField,{"HH1_LIVRE2", "C", 50, 00}) //Livre 2
			AADD(aField,{"HH1_LIVRE3", "C", 50, 00}) //Livre 3
			AADD(aField,{"HH1_LIVRE4", "C", 50, 00}) //Livre 4
			AADD(aField,{"HH1_LIVRE5", "C", 50, 00}) //Livre 5
			AADD(aField,{"HH1_LIVRE6", "C", 50, 00}) //Livre 6
			AADD(aField,{"HH1_LIVRE7", "C", 50, 00}) //Livre 7
			AADD(aField,{"HH1_LIVRE8", "C", 50, 00}) //Livre 8
			AADD(aField,{"HH1_LIVRE9", "C", 50, 00}) //Livre 9																																												
			AADD(aField,{"HH1_CODERP", "C", 10, 00}) //C�digo da moeda
			AADD(aField,{"HH1_MOEDES", "C", 10, 00}) //Moeda
			AADD(aField,{"HH1_CODCON", "C", 10, 00}) //Novo c�digo 
			
			AADD(aIndex,{"HH1_FILIAL", "HH1_CODERP"}) //Codigo Moeda
		
		Case cTable == 'HQF' //Config. Macreorregiao 
		    
		    AADD(aField,{"HQF_FILIAL", "C", 08, 00}) //Filial      
			AADD(aField,{"HQF_MACREG", "C", 10, 00}) //Sigla       
			AADD(aField,{"HQF_MACDES", "C", 40, 00}) //Macrerregiao
			AADD(aField,{"HQF_PAISES", "C", 254, 00}) //Paises    
			
			AADD(aIndex,{"HQF_FILIAL", "HQF_MACREG"}) //Sigla                                                                   
		 
	Endcase
	
	BIXTable( cTable, aField, aIndex )

return nil
