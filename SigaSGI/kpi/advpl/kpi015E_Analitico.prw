// ######################################################################################
// Projeto: KPI
// Fonte  : KPI015E_Detalhe.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 21.09.10 | 3174 Valdiney V GOMES
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI015E_ANALITICO.ch"

#define TAG_ENTITY 		"ANALITICO"
#define TAG_GROUP  		"ANALITICOS"
#define TEXT_ENTITY 	STR0001 	//"Analítico"  
#define TEXT_GROUP  	STR0002 	//"Analíticos"  
               
#define MAX_LINHA		250     	//Número máximo de linhas por página.     
#define PAG_SINTESE		"sintese"   //Identifica a página de síntase do relatório simples.         

#define _CONTEUDO   	1          	//Identifica o conteúdo no array de relação. 
#define _PLANILHA      2  			//Identifica a planilha no array de relação.
#define _OCORRENCIA    2           //Identifica a ocorrência o no array de relação.                          
#define _VALOR		    3			//Identifica o valor no array de relação.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TKPI015E
Definição da classe KPI015E_ANALITICO 

@author    3174 - Valdiney V GOMES
@version   P10
@since     04/01/2010
/*/
//------------------------------------------------------------------------------------- 
class TKPI015E from TBITable                                                 
	//Construção. 
	Method New() constructor
	Method NewKPI015E()

	//Funcionalidade. 
	Method lValida(aValores)     
	Method lRemove(cIDPlanilha)
	Method lAnalitico(cIDIndicador, dDataAlvo) 
	Method nPaginas(cIDPlanilha) 
	Method aColuna(xIDPlanilha )	
	Method aOcorrencia(xIDPlanilha)	
	Method aRelacao(xIDPlanilha, cMestre, cDetalhe)
endclass
	  
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} KPI015E_ANALITICO
Construtor.   

@author    3174 - Valdiney V GOMES
@version   P10
@since     04/01/2010
/*/
//------------------------------------------------------------------------------------- 	
method New() class TKPI015E
	::NewKPI015E()
return   

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewKPI015E
Construtor.   

@author    3174 - Valdiney V GOMES
@version   P10
@since     04/01/2010
/*/
//------------------------------------------------------------------------------------- 
method NewKPI015E() class TKPI015E
	::NewTable("SGI015E")
	::cEntity(TAG_ENTITY)

	::addField(TBIField():New("ID"			,"C"	,010)) 		//Chave Primária. 
	::addField(TBIField():New("INDICADOR"	,"C"	,010)) 		//ID do indicador.   
	::addField(TBIField():New("PLANILHA"	,"C"	,015)) 		//ID do item da planilha de valores
	::addField(TBIField():New("LINHA"		,"N"		)) 		//Linha da tabela invertida. 	
	::addField(TBIField():New("CAMPO" 		,"C"	,254)) 		//Nome do campo dinâmico.   
	::addField(TBIField():New("CONTEUDO"	,"C"	,254)) 		//Conteúdo do campo dinâmico.    

	::addIndex(TBIIndex():New("SGI015EI01",	{"ID"}						,.T.))  
	::addIndex(TBIIndex():New("SGI015EI02",	{"PLANILHA", "LINHA"}		,.F.)) 
	::addIndex(TBIIndex():New("SGI015EI03",	{"PLANILHA"}				,.F.))
	::addIndex(TBIIndex():New("SGI015EI04",	{"PLANILHA", "ID", "LINHA"}	,.F.))    
return
  
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} lValida
Valida o formato da estrutura de dados a ser importada.   

@param aValores Array contendo os dados a serem importados. 

@author    3174 - Valdiney V GOMES
@version   P10
@since     04/01/2010
/*/
//------------------------------------------------------------------------------------- 
Method lValida(aValores)  class TKPI015E
    Local lValido	:= .T.   //Identifica se o modelo de dados do relatório anaçítico é válido.
    Local nLinhas	:= 0     //Quantidade de linhas do relatório analítico.
    Local nColunas	:= 0     //Quantidade de colunas do relatório analítico. 
    	 	             
   	If ( ValType( aValores ) == "A" )  
   	 	   	
   	   	If ( ! Len(aValores) == 0 )	    
	
	    	If ( ValType( aValores[1] ) == "A" )    		
	    		  
	    		If ( ! Len(aValores[1]) == 0 )
	    		   	   	
		    		nLinhas := Len( aValores[1] )
		    		
		    		If ( ValType( aValores[1][1] ) == "A" )
		    			nColunas := Len( aValores[1][1] )
		    	  	Else           
		         		lValido		:= .F. 
		    	    EndIf   
			    Else           
		     		lValido		:= .F. 
		    	EndIf
	    	Else
	         	lValido		:= .F.  
	    	EndIf 
		Else
	     	lValido		:= .F.  
    	EndIf    	
    Else 
        lValido		:= .F.                  
	EndIf   
	
	If (lValido) 
	    oKPICore:Log("  " + cBIStr( nLinhas ) + STR0008 + " X " +  cBIStr( nColunas ) + STR0009, KPI_LOG_SCR)  //Linhas X Colunas
	Else
		oKPICore:Log(STR0004, KPI_LOG_SCRFILE)//"A Estrutura de Dados Analíticos é Inválida."
	EndIf   
return lValido

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} lRemove
Remove os dados analíticos gravados para um item da planilha de valores.   

@param cIDPlanilha ID do item da planilha. 
@author    3174 - Valdiney V GOMES
@version   P10
@since     04/01/2010
/*/
//------------------------------------------------------------------------------------- 
Method lRemove(cIDPlanilha) class TKPI015E
   	Local lReturn	:= .F.   	//Indica se a exclusão dos dados foi realizada com sucesso. 
   	Local cQuery	:= ""     	//Instrução para remoção de dados desatualizados.
	
	cQuery += " DELETE FROM SGI015E WHERE PLANILHA = '" + cIDPlanilha + "'"
		
	If ( TCSQLExec( cQuery ) < 0 )
		lReturn :=  .F.
	EndIf
	
	TCRefresh("SGI015E") 
Return lReturn
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} KPI015E_ANALITICO
Identifica se existem dados analíticos para determinado indicador na data informada. 

@author    3174 - Valdiney V GOMES
@version   P10
@since     04/01/2010
/*/
//------------------------------------------------------------------------------------- 
Method lAnalitico(cIDIndicador, dDataAlvo) class TKPI015E
  	Local lReturn 		:= .T.           	//Indica se existe relatório analítico associada a um indicador ou a um filho do indicador.
Return lReturn   
    
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nPaginas
Calcula a quantidade de páginas do relatório.

@author    3174 - Valdiney V GOMES
@version   P10
@since     04/01/2010
/*/
//------------------------------------------------------------------------------------- 
Method nPaginas(cIDPlanilha) class TKPI015E
	Local cAlias 		:= GetNextAlias()  	//Alias para montagem da workarea temporária.  
	Local cQuery		:= ""              	//Query para recuperar dados para workarea temporária. 
	Local nPaginas 		:= 0               	//Quantidade de páginas do relatório.
		
	cQuery += " SELECT MAX(LINHA) TOTAL " 
	cQuery += " FROM "
	cQuery += " SGI015E ANALITICO" 
	cQuery += " WHERE "
	cQuery += " ANALITICO.PLANILHA = '" +  cIDPlanilha + "'"       
	cQuery += " AND "    
	cQuery += " D_E_L_E_T_ = '' "   

	DBUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)  
	
	If ( ! (cAlias)->( EOF() ) )
    	nPaginas := ( (cAlias)->(TOTAL) / MAX_LINHA ) 
    	
    	If ( Mod( nPaginas, MAX_LINHA ) > 0 )
    		nPaginas += 1
    	EndIf 
	EndIf   
	 
	 (cAlias)->( dbCloseArea() )  
Return Iif( Int( nPaginas ) == 0, 1, Int( nPaginas ) ) 
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} aColuna
Retorna todos os campos de um relatório.

@author    3174 - Valdiney V GOMES 
@version   P10
@since     06/04/2011
/*/
//------------------------------------------------------------------------------------- 
Method aColuna( xIDPlanilha ) class TKPI015E
	Local cAlias 		:= GetNextAlias()  	//Alias para montagem da workarea temporária.  
	Local cQuery		:= ""              	//Query para recuperar dados para workarea temporária. 
	Local aCampos		:= {}              	//Array contendo os valores e o número de ocorrência de cada valor. 
	
	cQuery := " SELECT DISTINCT CAMPO "
	cQuery += " FROM "
	cQuery += " SGI015E "
	cQuery += " WHERE " 
	cQuery += " PLANILHA IN ( '" +  cBIStr( cBIConcatWSep("','", xIDPlanilha )  ) + "')"  
	cQuery += " ORDER BY CAMPO "
  
	DBUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)  

	While ( ! (cAlias)->( EOF() ) ) 
	    aAdd ( aCampos, { AllTrim( (cAlias)->(CAMPO) ) } )
		(cAlias)->(DBSkip())
	End      
   
	(cAlias)->( dbCloseArea() ) 
Return aCampos  
 
  
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} aOcorrencia
Calcula a quantidade de ocorrência de cada valor de cada coluna em um relatório.

@author    3174 - Valdiney V GOMES   (Colaboração de Marcia Junko)
@version   P10
@since     06/04/2011
/*/
//------------------------------------------------------------------------------------- 
Method aOcorrencia(xIDPlanilha, cColuna) class TKPI015E
	Local cAlias 		:= GetNextAlias()  	//Alias para montagem da workarea temporária.  
	Local cQuery		:= ""              	//Query para recuperar dados para workarea temporária. 
	Local aValores		:= {}              	//Array contendo os valores e o número de ocorrência de cada valor. 
	Local nI			:= 0                //Contador. 
	         
	Default cColuna 	:= ""
	
	cQuery := " SELECT DISTINCT CONTEUDO "
	cQuery += " FROM "
	cQuery += " SGI015E "
	cQuery += " WHERE " 
	cQuery += " PLANILHA IN ( '" 	+  cBIStr( cBIConcatWSep("','", xIDPlanilha )  ) + "')"  
	cQuery += " AND "
	cQuery += " CAMPO = '" 			+  cColuna 		+ "'"  
  
	DBUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)  

	While ( ! (cAlias)->( EOF() ) )   
	    aAdd ( aValores, { AllTrim( (cAlias)->(CONTEUDO) ), 0 } )
		(cAlias)->(DBSkip())
	End      
   
	(cAlias)->( dbCloseArea() ) 

    For nI := 1 To Len( aValores )    
  		cAlias 		:= GetNextAlias()	       
  
		cQuery := " SELECT COUNT(*) TOTAL"
		cQuery += " FROM "
		cQuery += " SGI015E "
		cQuery += " WHERE "
		cQuery += " PLANILHA IN ( '" 			+  cBIStr( cBIConcatWSep("','", xIDPlanilha )  ) + "')"  
		cQuery += " AND "
		cQuery += " CAMPO = '"	  				+  cColuna 			+ "'"   
		cQuery += " AND "
		cQuery += " RTRIM(LTRIM(CONTEUDO)) = '" +  AllTrim( aValores[nI][1] ) 	+ "'" 
        
        DBUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)  

		If ( ! (cAlias)->( EOF() ) )           
			aValores[nI][_OCORRENCIA] := (cAlias)->(TOTAL)
		EndIf   

 		(cAlias)->( dbCloseArea() ) 
    Next nI    
    
    aSort( aValores, , , {|x,y|x[_OCORRENCIA] > y[_OCORRENCIA]}) 
    
Return aValores 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} aRelacao
Traça a relação dos dados de uma coluna com os dados de uma segunda coluna. 

@author    3174 - Valdiney V GOMES   (Colaboração de Marcia Junko)
@version   P10
@since     08/04/2011
/*/
//------------------------------------------------------------------------------------- 
Method aRelacao(xIDPlanilha, cMestre, cDetalhe) class TKPI015E
	Local cAlias 		:= GetNextAlias()  						//Alias para montagem da workarea temporária.  
	Local cQuery		:= ""              						//Query para recuperar dados para workarea temporária. 
	Local aValores		:= {}              						//Array contendo os valores e o número de ocorrência de cada valor. 
	Local nI			:= 0                					//Contador. 
    Local nValor		:= 0  
       
	Default cMestre	:= ""
	Default cDetalhe:= ""
            
    
	//Recupera todas os conteúdos distintos da coluna mestre em cada planilha. 
	cQuery := " SELECT DISTINCT CONTEUDO, PLANILHA "
	cQuery += " FROM "
	cQuery += " SGI015E "
	cQuery += " WHERE "  	
	cQuery += " PLANILHA IN ( '" 	+  cBIStr( cBIConcatWSep("','", xIDPlanilha )  ) + "')"  
	cQuery += " AND "
	cQuery += " CAMPO = '" 			+  cMestre 	+ "'"  

	DBUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)  

	While ( ! (cAlias)->( EOF() ) )    
		nValor := aScan( aValores, {|x| AllTrim( x[_CONTEUDO] ) == AllTrim( (cAlias)->(CONTEUDO) )  })     
	      
	   	If ( nValor > 0 )
   			aValores[nValor][_PLANILHA] := aValores[nValor][_PLANILHA] + "|" + AllTrim( (cAlias)->(PLANILHA) )
	   	Else
	   		aAdd ( aValores, { AllTrim( (cAlias)->(CONTEUDO) ), AllTrim( (cAlias)->(PLANILHA) ), {/*Contador*/} } )
	   	EndIf          
	    
		(cAlias)->(DBSkip())
	End      

	(cAlias)->( dbCloseArea() ) 
      

    //Recupera todos os conteúdos que se relacionam com o conteúdo da coluna mestre. 
    For nI := 1 To Len( aValores )    
  		cAlias 		:= GetNextAlias()	       

	  	cQuery := " SELECT CONTEUDO "   
	  	cQuery += " FROM "  
	  	cQuery += " SGI015E PAI "
	  	cQuery += " WHERE "  
		cQuery += " PLANILHA IN ( '" 	+  cBIStr( cBIConcatWSep("','", aBIToken( aValores[nI][_PLANILHA], "|",.F.) )  ) + "')"  
		cQuery += " AND "
		cQuery += " CAMPO = '" 			+  cDetalhe	+ "'"
		cQuery += " AND "	
		cQuery += " EXISTS "  
		cQuery += " ( "	
		cQuery += " 	SELECT DISTINCT LINHA "
		cQuery += " 	FROM "
		cQuery += " 	SGI015E FILHO "
		cQuery += " 	WHERE "      
		cQuery += " 	PAI.LINHA = FILHO.LINHA " 
		cQuery += " 	AND "   
		cQuery += " 	PAI.PLANILHA = FILHO.PLANILHA " 	
		cQuery += " 	AND "   
		cQuery += " 	PLANILHA IN ( '" 				+  cBIStr( cBIConcatWSep("','", aBIToken( aValores[nI][_PLANILHA], "|",.F.) )  ) + "')"   
		cQuery += " 	AND "
		cQuery += " 	CAMPO = '" 						+  cMestre 	+ "'"  
		cQuery += " 	AND "
		cQuery += " 	RTRIM(LTRIM(CONTEUDO)) = '" 	+  AllTrim( aValores[nI][_CONTEUDO] ) 	+ "'" 
	  	cQuery += " ) "	

        DBUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)  
           
		While ( ! (cAlias)->( EOF() ) )   
		   	aAdd ( aValores[ni][3], { AllTrim( (cAlias)->(CONTEUDO) ) } )
			(cAlias)->(DBSkip())
		End 

 		(cAlias)->( dbCloseArea() ) 
    Next nI    
    
    aSort( aValores, , , {|x,y| Len(x[_VALOR]) > Len(y[_VALOR]) }) 
    
Return aValores 
  
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nRelatorio
Monta o relatório analítico para cada indicador. 

@author    3174 - Valdiney V GOMES
@version   P10
@since     04/01/2010
/*/
//------------------------------------------------------------------------------------- 
Function nRelatorio() 
    Local oAnalitico 		:= oKPICore:oGetTable("ANALITICO") //Instãncia do relatório analítico.              
    Local oPlanilha			:= oKPICore:oGetTable("PLANILHA")  //Instãncia da planilha de valores. 
    Local oIndicador		:= oKPICore:oGetTable("INDICADOR") //Instaância do Indicador.  
 	Local lContinua			:= .T.  							//Indica se está tudo ok na geração do relatório.
    Local lLink				:= .F.                 				//Indica se deve ser criado link para um item da tabela.
    Local lLinhas  			:= .F. 							   //Identifica se o relatório tem alguma linha a ser exibida. 
    Local lSimples			:= .F.								//Identifica se o relatório é simples ou múltiplo.  
	Local cIDPlanilha		:= ""                   			//ID do item da planilha de valores.    
    Local cIDIndicador		:= HTTPGet->Indicador   			//ID do indicador para o qual será gerado o relatório. 
    Local cDataAlvo			:= HTTPGet->Alvo        			//Data alvo para geração do relatório.    
    Local cPagina			:= HTTPGet->Pagina      			//Página na qual o relatório estará posicionado.  
	Local cIndicador		:= ""                   			//Nome do Indicador.
    Local cRelatorio		:= ""                  				//Conteúdo HTML do relatório. 
    Local cDescricao		:= ""                   			//Descrição do indicador. 
	Local cURL				:= KPIFixPath(cBIGetWebHost())     //URL do site do SGI.         
	Local nLinha 			:= 1                  				//Linha da tabela invertida a ser impressa.
 	Local nFilho			:= 0                               //Contador.   
   	Local nTotalLinhas		:= 0                               //Quantidade de linhas de dados no relatório. 
   	Local nPaginas			:= 1                   			   //Número de páginas do relatório.     
    Local nPaginaAtual      := 1                               //Pagina em exibição no relatório simples.  
   	Local aFilhos			:= {}                              //Todos os filhos de um indicador. 
	Local aPlanilha			:= {}								//Todos os IDs das planilha de um relatório múltiplo.
    Local aPosicao			:= {}                              //Posicao da tabela. 

   
    //Verifica se o indicador existe e recupera seu nome e descrição para montar o cabeçalho. 
 	If ( oIndicador:lSeek( 1, { cIDIndicador } ) )       
      	cIndicador	:= oIndicador:cValue("NOME")
      	cDescricao	:= oIndicador:cValue("DESCRICAO")
    Else 
      	lContinua 	:= .F.
    EndIf  
                
     
    //Monta o cabeçalho do relatório analítico. Importa todo o CSS e JS necessário.  
	cRelatorio := '<html>'
	cRelatorio +=' <head>'
	cRelatorio +=' <title>' + cIndicador + '</title>'
	cRelatorio +=' <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">' 
	cRelatorio +=' <meta http-equiv="Pragma" content="no-cache">'
	cRelatorio +=' <meta http-equiv="expires" content="0">'
	cRelatorio +=' <link href="' + cURL + 'imagens/report_estilo2.css" rel="stylesheet" type="text/css">'    
	cRelatorio +=' <link href="' + cURL + 'imagens/style.css" rel="stylesheet" type="text/css">'  
	cRelatorio +='	<script type="text/javascript" src="' + cURL + 'jquery.js"></script>'   
	cRelatorio +='	<script type="text/javascript" src="' + cURL + 'jquery.tablesorter.js"></script>' 
	cRelatorio +='	<script type="text/javascript" src="' + cURL + 'sgilib.js"></script>'    
	cRelatorio +=' </head>'
	cRelatorio +='	<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">' 
	cRelatorio +='		<table width="100%" border="0" cellpadding="0" cellspacing="0">'
	cRelatorio +='			<tr>'
	cRelatorio +='				<td>'      
	cRelatorio +='					<table width="100%" class="tabela">'
	cRelatorio +='						<tr>'
	cRelatorio +='							<td width="150" class="tdlogo"><center><img class="imglogo" src="' + cURL + 'imagens/art_logo_clie.sgi"></center></td>'
	cRelatorio +='							<td class="titulo" align="center">' + cIndicador + '<br>'
	cRelatorio +='							<strong><span class="texto">' + cDescricao + '</span></strong></td>'
	cRelatorio +='							<td width="150" align="center" valign="center" class="texto">' + dToC( Date() ) + '</td>'
	cRelatorio +='						</tr>'
	cRelatorio +='					</table>'
	cRelatorio +='				</td>'
	cRelatorio +='			</tr>'   
	cRelatorio +='		<tr>'
	cRelatorio +='		<td>&nbsp;</td>'
	cRelatorio +='		</table>' 
                   
    
	If ( ! cPagina == PAG_SINTESE  )

	    //Monta os filtros do relatório analalítico. Todos os filhos podem se tornar filtros. 
	    If ( oIndicador:lSeek(4, { cIDIndicador } ) )  
			cRelatorio += '	<table width="80%" align="center" border="0" cellpadding="0" cellspacing="0" >'             

			cRelatorio += '<tr align="center" height="15">' 				
			cRelatorio += '		<td class="texto1">     
			cRelatorio += ' 		<strong>'
			cRelatorio += 				STR0006 //"Indicadores Filhos"  
			cRelatorio += ' 		</strong>'
			cRelatorio += '		</td>' 
			cRelatorio += '</tr>' 

	
			While ( ! oIndicador:lEof() .And. oIndicador:cValue("ID_INDICA") == cIDIndicador )                       
			  	aPosicao 	:= oIndicador:SavePos()
			  	lLink 		:= .F.		  	         
				aFilhos 	:= oIndicador:aFilhos( oIndicador:cValue("ID") )
	                        
	            aAdd( aFilhos, oIndicador:cValue("ID") )
	            		
	           	For nFilho := 1 To Len ( aFilhos ) 				
					If ( oIndicador:lSeek(1, { aFilhos[nFilho] } ) )				   
						If ( oPlanilha:lDateSeek( oIndicador:cValue("ID") , SToD( cDataAlvo ), oIndicador:nValue("FREQ") ) ) 
							cIDPlanilha := oPlanilha:cValue("ID")  
						 	If( oAnalitico:lSoftSeek( 4, { cIDPlanilha } ) )  			 	
				    			lLink := .T.     
				    			Exit
				            EndIf 
						EndIf
					EndIf 
			  	Next nFilho  
			  	
			  	oIndicador:RestPos(aPosicao)
	                 
				If ( lLink ) 
					cRelatorio += '<tr align="center" height="15">' 				
					cRelatorio += '		<td class="texto1">
					cRelatorio += '			<a href="' 
					cRelatorio += 				"analitico.apw?indicador=" + oIndicador:cValue("ID") + "&alvo=" + cDataAlvo + "&pagina=1" + '">' 
					cRelatorio += 				AllTrim( cBIStr( oIndicador:cValue("NOME") ) ) 
					cRelatorio += '			</a>'
					cRelatorio += '		</td>' 
					cRelatorio += '</tr>' 
				Else
					cRelatorio += '<tr align="center" height="15">' 				
					cRelatorio += '		<td class="texto1">
					cRelatorio += 			AllTrim( cBIStr( oIndicador:cValue("NOME") ) ) 
					cRelatorio += '		</td>' 
					cRelatorio += '</tr>'  
				EndIf	   
	
				oIndicador:_Next()			
			EndDo   
			
			cRelatorio += '</table>'
			cRelatorio += '<br>'		  	
		EndIf  
	EndIf
	    

 	//Recupera a lista de todos os indicadores filhos e filhos dos filhos de um indicador. 
    aPosicao 	:= oIndicador:SavePos()
	aFilhos 	:= oIndicador:aFilhos( cIDIndicador ) 
 	aAdd( aFilhos, cIDIndicador )
     
    
    //Identifica se está sendo gerado um relatório simples ou múltiplo. 
   	lSimples := ( Len( aFilhos ) == 1 )
                                           

    //Monta o conteúdo do relatório com divisão de conteúdo por indicador.        			
  	For nFilho := 1 To Len ( aFilhos ) 
		If ( oIndicador:lSeek(1, { aFilhos[nFilho] } ) )	
			If ( lContinua ) .And. ( oPlanilha:lDateSeek( oIndicador:cValue( "ID" ) , SToD( cDataAlvo ) , oIndicador:nValue("FREQ") ) ) 
		 		cIDPlanilha := oPlanilha:cValue("ID")
                   
				If ( ! cPagina == PAG_SINTESE  ) 

					If( oAnalitico:lSoftSeek( 4, { cIDPlanilha } ) )  			 	
			                     
						cRelatorio += '	<table width="95%" align="center" border="0" cellpadding="0" cellspacing="0" >' 	
						cRelatorio += '		<td class="texto2"> 
						cRelatorio +='			<strong>'  
						cRelatorio += '				<a href="' 
						cRelatorio += 					"analitico.apw?indicador=" + oIndicador:cValue("ID") + "&alvo=" + cDataAlvo + "&pagina=1" + '">' 
						cRelatorio += 					oIndicador:cValue("NOME") + "  [" + oPlanilha:cValue("VALOR") + "]"
						cRelatorio += '				</a>'
						cRelatorio +='			</strong>'
						cRelatorio += '	   	</td>'
					 	cRelatorio += ' </table>'
						cRelatorio += '<br>'
						cRelatorio +=' <table align="center" border="1" cellpadding="0" cellspacing="0"  class="tablesorter">' 
				 		cRelatorio += '		<thead>'
				 		cRelatorio += '			<tr align="center" height="15">'
		
				    	While ( ! oAnalitico:lEof() .And. oAnalitico:cValue("PLANILHA") == cIDPlanilha .And. oAnalitico:nValue("LINHA") == 1) 	    	
			   	       		cRelatorio +='<th class="cabecalho_2">'
			   	       		cRelatorio +='		<strong>' 
							cRelatorio += 		AllTrim( cBIStr( oAnalitico:cValue("CAMPO") ) ) 
							cRelatorio +='		</strong>'
							cRelatorio +='</th>'
	
				   			oAnalitico:_Next() 
				   	    EndDo   
				   	     
				   	    cRelatorio += '			</tr>' 
				   	    cRelatorio += '		</thead>'
	                   	cRelatorio += '		<tbody>'                       
				   		cRelatorio += '			<tr height="20" class="texto1">'       
	
	                    
	                    //Identifica se será aplicada paginação. Apenas relatório simples é paginado. 
	                	If ( lSimples )
	                		nPrimeiraLinha := ( ( nBIVal( cPagina ) - 1 ) * MAX_LINHA ) + 1 
	                		lLinhas := oAnalitico:lSeek( 2, { cIDPlanilha, nPrimeiraLinha } )
	                	Else 
	                		nPrimeiraLinha := 1
	                		lLinhas := oAnalitico:lSoftSeek( 4, { cIDPlanilha } )
	                	EndIf
	
				   		
				   		If( lLinhas )
					   		nLinha := oAnalitico:nValue("LINHA") 
					  		nTotalLinhas++       
					  	
					    	While ( ! oAnalitico:lEof() .And. oAnalitico:cValue("PLANILHA") == cIDPlanilha  .And. oAnalitico:nValue("LINHA") < ( nPrimeiraLinha + MAX_LINHA ))  	    	
				   		    	If ( ! nLinha == oAnalitico:nValue("LINHA") )    
					   		    	cRelatorio += '</tr>'  
		                                  
		                                   
		                            //Limite o tamanho do relatório múltiplo ao número máximo de linhas por página. . 
									If ( ! lSimples )
						   		    	If ( nTotalLinhas >= MAX_LINHA )
						   		    		Exit
						   		    	EndIf                     
					   		    	EndIf
			
					   		    	cRelatorio += '<tr height="20" class="texto1">'  
					   		       	nLinha := oAnalitico:nValue("LINHA") 
					   		       	
					   		       	nTotalLinhas++  
						        EndIf  
						        
						        cRelatorio += '<td>' 
								cRelatorio += 		AllTrim( cBIStr( oAnalitico:cValue("CONTEUDO") ) ) 
								cRelatorio += '</td>'  
								
					   			oAnalitico:_Next() 
							EndDo  
						EndIf
						
						cRelatorio += '			</tr>' 
						cRelatorio += '		</tbody>'
				   	    cRelatorio += '</table>' 
						cRelatorio += '<br>' 
			   	    Else
				   		If ( AllTrim( cIDIndicador ) == oIndicador:cValue( "ID" ) .And. ( nTotalLinhas == 0 ) )			
							cRelatorio += '	<table width="95%" align="center" border="0" cellpadding="0" cellspacing="0" >' 
							cRelatorio += '		<tr align="center">'  
							cRelatorio += '			<td class="cabecalho_amarelo">'
							cRelatorio += '				<strong>' 
							cRelatorio += 					STR0005 //"Não há relatório analítico associodo a este indicador no período informado." 
							cRelatorio += '	   			</strong>'
							cRelatorio += '			</td>'
							cRelatorio += '		</tr>' 
							cRelatorio += '	</table>'    
						EndIf   
			   	    EndIf 
			   EndIf		   	    
			Else   
			    If ( AllTrim( cIDIndicador ) == oIndicador:cValue( "ID" ) )			
					cRelatorio += '	<table width="95%" align="center" border="0" cellpadding="0" cellspacing="0" >' 
					cRelatorio += '		<tr align="center">'  
					cRelatorio += '			<td class="cabecalho_amarelo">'
					cRelatorio += '				<strong>' 
					cRelatorio += 					STR0005 //"Não há relatório analítico associodo a este indicador no período informado." 
					cRelatorio += '	   			</strong>'
					cRelatorio += '			</td>'
					cRelatorio += '		</tr>' 
					cRelatorio += '	</table>'    
				EndIf
			EndIf      
 		EndIf  
 		   
 
  		//Limita o tamanho do relatório múltiplo ao número máximo de linhas por página. . 
		If ( ! lSimples )
   		   	If ( nTotalLinhas >= MAX_LINHA )
   		   		Exit
   		   	EndIf                     
  		EndIf
  		 				
  	Next nFilho  

  	oIndicador:RestPos(aPosicao)
 

   	//Monta os links de paginação do relatório simples ou limita o relatório múltiplo.
    If ( lSimples )   
        
 		//Monta a página de síntese. 
    	If ( cPagina == PAG_SINTESE )        
   			cRelatorio += cSintese( cIDPlanilha )	            
        EndIf     
        
         
     	//Exibe a quantidade de páginas do relatório e a página atual. 
	    nPaginas := oAnalitico:nPaginas( cIDPlanilha ) 

	    cRelatorio += '	<table width="80%" align="center" border="0" cellpadding="0" cellspacing="0" >' 	
		cRelatorio += '	<br>'     
		cRelatorio += '		<center><strong><span class="texto">'  
		
		If ( cPagina == PAG_SINTESE ) 
			cRelatorio += 			STR0015 // "Síntese"
		Else
			cRelatorio += 			STR0016 + cPagina + STR0017 + cBIStr( nPaginas ) //"Página X de Y"
		EndIf                            
		
		cRelatorio += '		</span></strong></center>'
	 	cRelatorio += '	</table>'     
                  
        
        //Monta o link de paginação do relatório simples. 
		cRelatorio += '	<table align="center" border="0" cellpadding="0" cellspacing="0" >' 
		cRelatorio += '	<tr align="center" height="15" class="texto1">' 

		For nPaginaAtual := 1 To nPaginas 				
			cRelatorio += '<td class="texto1">'
			cRelatorio += '		<a href="analitico.apw?indicador=' + cIDIndicador + '&alvo=' + cDataAlvo + '&pagina=' + cBIStr( nPaginaAtual ) +'">'
			cRelatorio += 			cBIStr( nPaginaAtual )
			cRelatorio += '		</a>'
			cRelatorio += '</td>'		  	
	    Next nPaginaAtual   
	         
	     //Monta o link da sintese do relaório simples.           
	    cRelatorio += '<td class="texto1">'
		cRelatorio += '		<a href="analitico.apw?indicador=' + cIDIndicador + '&alvo=' + cDataAlvo + '&pagina=' + PAG_SINTESE +'">'
		cRelatorio += 		'['
		cRelatorio +=			STR0015 // "Síntese"
		cRelatorio += 		']'
		cRelatorio += '		</a>'
		cRelatorio += '</td>'

	    cRelatorio += '	</tr>'
	 	cRelatorio += '	</table>' 
    Else        
		
		//Monta a página de síntese. 
		If ( cPagina == PAG_SINTESE )  
		      
 			//Recupera todos os IDs das planilhas que compõem um relatório múltiplo. 
 			aPosicao 	:= oIndicador:SavePos()
           	For nFilho := 1 To Len ( aFilhos ) 				
				If ( oIndicador:lSeek(1, { aFilhos[nFilho] } ) )				   
					If ( oPlanilha:lDateSeek( oIndicador:cValue("ID") , SToD( cDataAlvo ), oIndicador:nValue("FREQ") ) ) 
						aAdd( aPlanilha, oPlanilha:cValue("ID") )
					EndIf
				EndIf 
		  	Next nFilho  
		  	oIndicador:RestPos(aPosicao) 
 	
 	   		cRelatorio += cSintese( aPlanilha )	         
        Else        
			If ( nTotalLinhas >= MAX_LINHA ) 
				cRelatorio += '	<table width="95%" align="center" border="0" cellpadding="0" cellspacing="0" >' 
				cRelatorio += '		<tr align="center">'  	
				cRelatorio += '			<td class="cabecalho_verm"> 
				cRelatorio += '				<strong>' 
				cRelatorio += 			 		STR0007 //"Apenas 250 itens podem ser exibidos por página. Por favor aplique um filtro." 
				cRelatorio += '				</strong>'
				cRelatorio += '	   		</td>'   
				cRelatorio += '		</tr>' 
			 	cRelatorio += ' </table>' 
			 	cRelatorio += ' <br>'
			EndIf 
		EndIf     
		             
		
		//Exibe o link de paginação. 
		cRelatorio += '	<table align="center" border="0" cellpadding="0" cellspacing="0" >' 
		cRelatorio += '	<tr align="center" height="15" class="texto1">' 

		cRelatorio += '<td class="texto1">'
		cRelatorio += '		<a href="analitico.apw?indicador=' + cIDIndicador + '&alvo=' + cDataAlvo + '&pagina=' + cBIStr( nPaginaAtual ) +'">'
		cRelatorio += 			STR0018 //"Relatório Múltiplo"
		cRelatorio += '		</a>'
		cRelatorio += '</td>'		  	
 
	    cRelatorio += '<td class="texto1">'
		cRelatorio += '		<a href="analitico.apw?indicador=' + cIDIndicador + '&alvo=' + cDataAlvo + '&pagina=' + PAG_SINTESE +'">'
		cRelatorio += 		'['
		cRelatorio +=			STR0015 // "Síntese"
		cRelatorio += 		']'
		cRelatorio += '		</a>'
		cRelatorio += '</td>'

	    cRelatorio += '	</tr>'
	 	cRelatorio += '	</table>'
	EndIf

    cRelatorio += '<br>' 
	cRelatorio += '</table>' 
 	cRelatorio += '<br>'  
	cRelatorio += '</body>'
	cRelatorio += '</html>'	  
return cRelatorio

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cSintese
Monta a síntese para um relatório analítico. 

@author    3174 - Valdiney V GOMES
@version   P10
@since     11/04/2010
/*/
//------------------------------------------------------------------------------------- 
Static Function cSintese( xPlanilha )    
    Local oAnalitico 	:= oKPICore:oGetTable("ANALITICO") //Instãncia do relatório analítico. 
	Local cMestre		:= HTTPGet->Mestre        			//Mestre.
    Local cDetalhe		:= HTTPGet->Detalhe       			//Detalhe. 
    Local cIDIndicador	:= HTTPGet->Indicador   			//ID do indicador para o qual será gerado o relatório. 
    Local cDataAlvo		:= HTTPGet->Alvo        			//Data alvo para geração do relatório.    
    Local cPagina		:= HTTPGet->Pagina      			//Página na qual o relatório estará posicionado.  
	Local aOcorrencias 	:= {}                     			//Matriz contendo a coluna mestre e a quantidade de ocorrências relacionadas.
    Local aColunas		:= {}								//Colunas do relatório. 
	Local cUnicos		:= ""                     			//Todos os registros que aparecem uma única vez concatenados com ','.
    Local cRelatorio	:= ""								//Conteúdo HTML da síntese do relatório analítico. 
	Local nUnicos		:= 0                  				//Quantidade de valores com uma única ocorrência no relatório.
	Local nI			:= 0                       			//Contador. 

	  	
    cRelatorio := '	<table width="95%" align="center" border="0" cellpadding="0" cellspacing="0" >' 	
	cRelatorio += '		<td class="texto2"> 
	cRelatorio +='			<strong>' 
	cRelatorio += 			 	STR0010 //"Quantidade de Ocorrências: "
	cRelatorio +='			</strong>'
	cRelatorio += '	   	</td>'  
	            
	        
	//Recupera todas as colunas distintas de um relatório.
	aColunas := oAnalitico:aColuna( xPlanilha )
	
	For nI := 1 To Len( aColunas ) 
		cRelatorio +='<td class="texto2">' 
		cRelatorio +='<input type="checkbox" '
	    cRelatorio +=' name="' + cBIStr(aColunas[nI]) + '"'        
	    cRelatorio +=' value="'+ cBIStr(aColunas[nI]) + '"'  
	    cRelatorio +=' onclick ="sgiSelecaoSintese(this); "'
		cRelatorio +='>' + AllTrim( cBIStr( aColunas[nI] ) )
		cRelatorio +='</td>'					
	Next nI  

	     
 	//Monta a URL do relatório sint[etico.
 	cURLBase := "'" + "analitico.apw?indicador=" + cIDIndicador + "&alvo=" + cDataAlvo + "&pagina=" + cPagina + "'"           

 	cRelatorio +='<td class="texto2">' 
   	cRelatorio += '		<a href="javascript:sgiRequisicaoSintese(' + cURLBase + ')">'
	cRelatorio += 			STR0019 //"Sintetizar"
	cRelatorio += '		</a>'  
	cRelatorio +='</td>'
	
 	cRelatorio += ' </table>'
	cRelatorio += '<br>'	  	
	  	

	If ( ValType( cMestre ) == "C" )     
	
		If ( ValType( cDetalhe ) == "C" )  
		  
			//Monta a relação de ocorrência entre a coluna mestre e a coluna de detalhe. 
		 	aOcorrencias := oAnalitico:aRelacao( xPlanilha, cMestre, cDetalhe )
		  				
		 	cRelatorio += '	<table width="95%" align="center" border="1" cellpadding="0" cellspacing="0"  class="tablesorter">' 
		 	cRelatorio += '	<thead>'	
			cRelatorio += ' <tr class="texto1" style="text-align:justify">'                     
			cRelatorio += '		<th width="25%" class="cabecalho_2">'   
			cRelatorio += '			<strong>'  
			cRelatorio += 				cMestre
			cRelatorio += '			<strong>' 	
			cRelatorio += '		</th>'					
		 	cRelatorio += '		<th width="15%" class="cabecalho_2"> ' 
		 	cRelatorio += '			<strong>'   	
			cRelatorio += 				STR0012 //"Ocorrências"
			cRelatorio += '			</strong>' 
			cRelatorio += '		</th>'    
			cRelatorio += '		<th class="cabecalho_2">' 
		 	cRelatorio += '			<strong>'   	
			cRelatorio += 				cDetalhe
			cRelatorio += '			</strong>' 
			cRelatorio += '		</th>' 
			cRelatorio += '	</tr>'    
			cRelatorio += '	</thead>'  
			
			cRelatorio += '	<tbody>'		 
		 	For nI := 1 to Len ( aOcorrencias )	   
				cRelatorio += ' <tr class="texto1" style="text-align:justify">'                      
		   	   	cRelatorio += '		<td width="25%">'
				cRelatorio += 			AllTrim( aOcorrencias[nI][_CONTEUDO] ) 
				cRelatorio += '		</td>' 
				cRelatorio += '		<td width="15%">' 
		   		cRelatorio += '			<strong>'   	
				cRelatorio += 				cBIStr( Len( aOcorrencias[nI][_VALOR] ) ) 
				cRelatorio += '			</strong>' 
				cRelatorio += '		</td>' 
		   	   	cRelatorio += '		<td>' 
				cRelatorio += 			cBIStr( cAgrupa( aOcorrencias[nI][_VALOR] ) ) 
				cRelatorio += '		</td>'   
		 		cRelatorio += '	</tr>'     
		   	Next nI  
			cRelatorio += '	</tbody>'
		 	cRelatorio += '	</table>'     
		 	cRelatorio += ' <br> '	  				
		Else             
		
		  	//Monta a análise sintética de ocorrência de dados em uma coluna. 
		 	aOcorrencias := oAnalitico:aOcorrencia( xPlanilha, cMestre )  
		 		
		 	cRelatorio += '	<table id="dd" width="95%" align="center" border="1" cellpadding="0" cellspacing="0"  class="tablesorter">' 	
		 	cRelatorio += '	<thead>'	
			cRelatorio += ' <tr>'                     
			cRelatorio += '		<th width="25%" class="cabecalho_2">'   
			cRelatorio += '			<strong>'  
			cRelatorio += 				cMestre 
			cRelatorio += '			<strong>' 	
			cRelatorio += '		</th>'					
		 	cRelatorio += '		<th width="75%" class="cabecalho_2">' 
		  	cRelatorio += '			<strong>'   	
			cRelatorio += 				STR0012 //"Ocorrências"
			cRelatorio += '			</strong>' 
			cRelatorio += '		</th>'   
			cRelatorio += '	</tr>' 
			cRelatorio += '	</thead>'  
		    
		 	cRelatorio += '	<tbody>'	
			For nI := 1 to Len ( aOcorrencias )	  
			 	If ( ! aOcorrencias[nI][_OCORRENCIA] == 1 )     
					cRelatorio += ' <tr class="texto1" style="text-align:justify">'                      
			  		cRelatorio += '		<td width="30%">'
					cRelatorio += 			AllTrim( aOcorrencias[nI][_CONTEUDO] ) 
					cRelatorio += '		</td>'
			   	    cRelatorio += '		<td>' 
			   		cRelatorio += '			<strong>'   	
					cRelatorio += 				cBIStr( aOcorrencias[nI][_OCORRENCIA] ) 
					cRelatorio += '			</strong>' 
					cRelatorio += '		</td>'   
			 		cRelatorio += '	</tr>'     
			 	 Else  
			 	 	If ( Len( cUnicos ) > 0 )
			 	 		cUnicos := cUnicos + ", " + AllTrim( aOcorrencias[nI][_CONTEUDO] ) 
			 	 	Else
			 	 		cUnicos := cUnicos + AllTrim( aOcorrencias[nI][_CONTEUDO] ) 
			 	 	EndIf
			 			 
			 	 	nUnicos ++
			 	 EndIf
			Next nI  
			cRelatorio += '	</tbody>'
		 	cRelatorio += '	</table>'   
		 	cRelatorio += ' <br> '
		                
			If ( nUnicos > 0 ) 
			 	cRelatorio += '	<table width="95%" align="center" border="0" cellpadding="0" cellspacing="0" border="1" >'   
			 	cRelatorio += ' 	<tr class="texto1" style="text-align:justify">'     
				cRelatorio += '			<td width="100%">'
				cRelatorio += '			<strong>'  
				cRelatorio += 				STR0013 //Valores com única ocorrência	
				cRelatorio += '			</strong>' 
				cRelatorio +=			"[" + cBIStr( nUnicos ) + STR0014 + cMestre + "]" 
				cRelatorio += '			</td>'
				cRelatorio += '		</tr>' 	 
			 	cRelatorio += ' 	<tr class="texto1" style="text-align:justify">'     
				cRelatorio += '			<td width="100%">' 
				cRelatorio += 				cUnicos 
				cRelatorio += '			</td>'
				cRelatorio += '		</tr>' 
			 	cRelatorio += '	</table>' 
			 	cRelatorio += ' <br> '
			EndIf 
		EndIf
	EndIf    
Return cRelatorio
                    
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cAgrupa
Agrupa e totaliza valores iguais.  

@author    3174 - Valdiney V GOMES
@version   P10
@since     11/04/2010
/*/
//------------------------------------------------------------------------------------- 
Static Function cAgrupa( aValores )
   	Local aAgrupado := {}
	Local cAgrupado := ""
	Local nI		:= 0
   	Local nValor  	:= 0

	//Agrupa e conta todas as ocorrências.
	For nI := 1 To Len ( aValores )
		 nValor := aScan( aAgrupado, {|x| alltrim( x[_CONTEUDO] ) == AllTrim( aValores[nI][_CONTEUDO] ) })     
	      
	   	If ( nValor > 0 )
   			aAgrupado[nValor][_OCORRENCIA] ++
	   	Else
	   		aAdd ( aAgrupado, { AllTrim( aValores[nI][_CONTEUDO] ), 1 } ) 
	   	EndIf 
	Next nI    

    //Ordena os valores agrupados de acordo com a relevência.          
    aSort(aAgrupado, , , {|x,y| x[_OCORRENCIA] > y[_OCORRENCIA]} )    
    
    //Monta a exibição dos valores.                     
	For nI := 1 To Len ( aAgrupado )
	  	If ( ! Empty( cAgrupado ) )
         	cAgrupado += ", "
	  	EndIf 
	  	
	  	//Não exibe o totalizador quando a ocorrência for única. 
	  	If ( aAgrupado[nI][_OCORRENCIA] > 1 )
		  	cAgrupado += "<strong> [" 
		  	cAgrupado += cBIStr( aAgrupado[nI][_OCORRENCIA] ) 
			cAgrupado += "] </strong>  " 
		EndIf
		
		cAgrupado += aAgrupado[nI][_CONTEUDO]  
	Next nI      
Return cAgrupado

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} KPI015E_ANALITICO
Torna a classe visível no inspetor de objetos.  

@author    3174 - Valdiney V GOMES
@version   P10
@since     04/01/2010
/*/
//------------------------------------------------------------------------------------- 
Function _KPI015E_ANALITICO()
return nil