#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STDISSL1Get
Busca o Orcamento pelo numero e retorna o cabeçalho num array
@param   cNumOrc				Numero do Orcamento
@param	 lSL1Locked				Retorna .T. se a SL1 estiver com lock
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSL1					Retorna cabeçalho do orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISSL1Get( cNumOrc, lSL1Locked )

Local aArea 			:= GetArea()		// Armazena alias corrente
Local cOptionsTemp 		:= GetNextAlias()	// Armazena Proximo alias disponível
Local aSL1				:= {}				// Retorno da função
Local nI				:= 0				// Contador
Local cNumExp			:= ""				// Expressao L1_NUM
Local cQryFields 		:= ""
Local aFieldsImp 		:= {}
Local axTesSql 			:= {}
Local caxTesSql			:= ""

Default cNumOrc			:= ""
Default lSL1Locked		:= .F. 

ParamType 0 Var 	cNumOrc 			As Character	Default ""	

If FindFunction("STBImpGFld")
	aFieldsImp	:= STBImpGFld("SL1") //Retorna os campos que serao utilizados na query para importacao do orcamento
Else
	aFieldsImp	:= SL1->(dbStruct()) //Todos os campos
EndIf

For nI := 1 To Len( aFieldsImp )
	cQryFields += aFieldsImp[nI][1]+","
Next nI
//Retira a Ultima Virgula
cQryFields := Left(cQryFields,Len(cQryFields)-1)
cQryFields := "%"+cQryFields+"%"

If !Empty(cNumOrc)
	If Len(Alltrim(cNumOrc)) == TamSX3("L1_NUM")[1]
		cNumExp := "%'" + cNumOrc + "'%"
	Else
		cNumExp := "%'" + StrZero(Val(cNumOrc),TamSX3("L1_NUM")[1]) + "'%"
	EndIf
Else
	cNumExp := "%''%"
EndIf

BeginSql ALIAS cOptionsTemp  
						
				SELECT %Exp:cQryFields%					
				FROM %table:SL1% SL1						
				WHERE	
						L1_FILIAL		=	%xfilial:SL1%				AND	
					  	L1_NUM			=	%exp:cNumExp%				AND        
						L1_PEDRES		=  " "							AND
						SL1.%NotDel%
EndSql

axTesSql :=   GetLastQuery()

caxTesSql := axTesSql[2]

LjGrvLog( " 03 Importação do PDV Orcamento " + cNumOrc, "SQL", Nil )
LjGrvLog( " 04 A sql = " + 	caxTesSql + "Fim", "SQL", Nil )

//Ajuste no tipo de dado retornado da query (Numerico, Data, Lógico)
For nI := 1 To Len(aFieldsImp)
	If aFieldsImp[nI,2]<>"C" .And. aFieldsImp[nI,2]<>"M" //M=Memo Real
		TcSetField(cOptionsTemp,aFieldsImp[nI,1],aFieldsImp[nI,2],aFieldsImp[nI,3],aFieldsImp[nI,4])
	EndIf
Next nI

DbSelectArea(cOptionsTemp)

While !(cOptionsTemp)->(EOF()) 
	    
	For nI := 1 To FCount()
		AADD( aSL1 , {FieldName(nI) , FieldGet(nI)} )
		
	Next nI
	
	lSL1Locked := STDValLock ((cOptionsTemp)->L1_NUM)

	(cOptionsTemp)->(DbSkip())
	
EndDo

(cOptionsTemp)->( DbCloseArea() )

DbSelectArea( "SL1" ) // Seleção de tabela (preventiva)

RestArea(aArea)

Return aSL1


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISPafSL1Get
Busca o Orcamento pela numeração de DAV/PRE e retorna o cabeçalho
@param   cNumOrc				Numero do Orcamento(L1_NUMORC)
@param   cTypeNumber			Tipo de Numeração. "D" -> DAV , "P" -> PREVENDA
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSL1					Retorna cabeçalho do orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISPafSL1Get( cNumOrc , cTypeNumber )

Local aArea 			:= GetArea()		// Armazena alias corrente
Local cOptionsTemp 		:= GetNextAlias()		// Armazena Proximo alias disponível
Local aSL1				:= {}				// Retorno da função
Local nI				:= 0				// Contador
Local cNumExp			:= ""				// Expressao L1_NUM
Local cTpOrc			:= ""				// Expressao L1_TPORC
Local cQryFields 		:= ""
Local aFieldsImp 		:= {} 

Default cNumOrc		:= ""
Default cTpOrc		:= ""

ParamType 0 Var 	cNumOrc 			As Character	Default ""	

If FindFunction("STBImpGFld")
	aFieldsImp	:= STBImpGFld("SL1") //Retorna os campos que serao utilizados na query para importacao do orcamento
Else
	aFieldsImp	:= SL1->(dbStruct()) //Todos os campos
EndIf

For nI := 1 To Len( aFieldsImp )
	cQryFields += aFieldsImp[nI][1]+","
Next nI
//Retira a Ultima Virgula
cQryFields := Left(cQryFields,Len(cQryFields)-1)
cQryFields := "%"+cQryFields+"%"


If !Empty(cNumOrc)
	cNumExp	:= "%'" + StrZero(Val(cNumOrc),TamSX3("L1_NUMORC")[1]) + "'%"
Else
	cNumExp := "%''%"
Endif
cTpOrc 	:= "%'" + cTypeNumber + "'%"

BeginSql ALIAS cOptionsTemp  
						
				SELECT %Exp:cQryFields%
				FROM %table:SL1% SL1						
				WHERE	
						L1_FILIAL		=	%xfilial:SL1%				AND	
					  	L1_NUMORC		=	%exp:cNumExp%				AND
					  	L1_TPORC		=	%exp:cTpOrc%				AND      
						SL1.%NotDel%
EndSql

//Ajuste no tipo de dado retornado da query (Numerico, Data, Lógico)
For nI := 1 To Len(aFieldsImp)
	If aFieldsImp[nI,2]<>"C" .And. aFieldsImp[nI,2]<>"M" //M=Memo Real
		TcSetField(cOptionsTemp,aFieldsImp[nI,1],aFieldsImp[nI,2],aFieldsImp[nI,3],aFieldsImp[nI,4])
	EndIf
Next nI

DbSelectArea(cOptionsTemp)

While !(cOptionsTemp)->(EOF()) 
		    
	For nI := 1 To FCount()
	
		AADD( aSL1 , {FieldName(nI) , FieldGet(nI)} )
		
	Next nI
	
	(cOptionsTemp)->(DbSkip())
	
	
EndDo

(cOptionsTemp)->( DbCloseArea() )

DbSelectArea( "SL1" ) // Seleção de tabela (preventiva)

RestArea(aArea)

Return aSL1


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISSL2Get
Busca os itens do Orcamento pelo numero e retorna num array bidimensional

@param   cNumOrc				Numero do Orcamento
@param   lPafEcf				Indica se usa PafEcf
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSL2					Retorna Itens do orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISSL2Get( cNumOrc , lPafEcf )

Local aArea				:= GetArea()	// armazena alias corrente
Local aSL2				:= {}			// Retorno da funcao      
Local cOptionsTemp 		:= GetNextAlias()		// Armazena Proximo alias disponível
Local aItens			:= {}			// Armazena os itens(auxiliar do SL2)
Local nI				:= 0			// Contador
Local cNumExp			:= ""				// Expressao L1_NUM
Local cDeleted			:= ""			// Status de deleção
Local cL1_Vendid      	:= PadR('N', TamSx3("L2_VENDIDO")[1])		// Tamanho do L2_VENDIDO
Local cQryFields 		:= ""
Local aFieldsImp 		:= {} 

Default cNumOrc			:= ""
Default lPafEcf			:= .F.

ParamType 0 Var 	cNumOrc 			As Character	Default ""	

If FindFunction("STBImpGFld")
	aFieldsImp	:= STBImpGFld("SL2") //Retorna os campos que serao utilizados na query para importacao do orcamento
Else
	aFieldsImp	:= SL2->(dbStruct()) //Todos os campos
EndIf

For nI := 1 To Len( aFieldsImp )
	cQryFields += aFieldsImp[nI][1]+","
Next nI
//Retira a Ultima Virgula
cQryFields := Left(cQryFields,Len(cQryFields)-1)
cQryFields := "%"+cQryFields+"%"


If !Empty(cNumOrc)

	If Len(Alltrim(cNumOrc)) == TamSX3("L2_NUM")[1]
		cNumExp := "%'" + cNumOrc + "'%" 
	Else
		cNumExp := "%'" + StrZero(Val(cNumOrc),TamSX3("L2_NUM")[1]) + "'%"
	EndIf
Else
	cNumExp := "%''%"
EndIf
cDeleted := "%'*'%"
cL1_Vendid := "%'" + cL1_Vendid + "'%"

If  lPafEcf
	
	//No PAFECF nao usar 	%NotDel% pois os itens serao
	//impressos e cancelados de acordo com campo L2_VENDIDO	
	BeginSql ALIAS cOptionsTemp  
					
					SELECT %Exp:cQryFields%  				
					FROM %table:SL2% SL2						
					WHERE	
							L2_FILIAL		=	%xfilial:SL2%				AND	
						  	L2_NUM			=	%exp:cNumExp%             AND
						  	( 	SL2.%NotDel%                               OR
						  	   		( 	SL2.D_E_L_E_T_ = %exp:cDeleted%  AND
						  	     		SL2.L2_VENDIDO = %exp:cL1_Vendid% 
						  	    	)
						  	 )
	
	EndSql
	
Else

	BeginSql ALIAS cOptionsTemp  
					
					SELECT %Exp:cQryFields% 				
					FROM %table:SL2% SL2						
					WHERE	
							L2_FILIAL		=	%xfilial:SL2%				AND	
						  	L2_NUM			=	%exp:cNumExp%				AND
							SL2.%NotDel% 
	
	EndSql

EndIf	

//Ajuste no tipo de dado retornado da query (Numerico, Data, Lógico)
For nI := 1 To Len(aFieldsImp)
	If aFieldsImp[nI,2]<>"C" .And. aFieldsImp[nI,2]<>"M" //M=Memo Real
		TcSetField(cOptionsTemp,aFieldsImp[nI,1],aFieldsImp[nI,2],aFieldsImp[nI,3],aFieldsImp[nI,4])
	EndIf
Next nI

DbSelectArea(cOptionsTemp)

While !(cOptionsTemp)->(EOF()) 
		    
	For nI := 1 To FCount()
	
		AADD( aItens , {FieldName(nI) , FieldGet(nI)} )
		
	Next nI
	
	AADD( aSL2 , aItens )
	
	aItens := {}	
	
	(cOptionsTemp)->(DbSkip())
	
EndDo

(cOptionsTemp)->( DbCloseArea() )

RestArea(aArea)

Return aSL2


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISSL4Get
Busca as formas de pagamento do Orcamento pelo numero e retorna num array bidimensional

@param   cNumOrc				Numero do Orcamento
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSL4					Retorna formas de pagamento do orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISSL4Get( cNumOrc )

Local aArea			:= GetArea()		// Armazena alçiasl corrente
Local aSL4			:= {}				// Retorno da funcao
Local cOptionsTemp 	:= GetNextAlias()	// Armazena Proximo alias disponível
Local aPay			:= {}				// Armazena formas de pagamento(auxilial aSL4)
Local nI				:= 0				// Contador

Default cNumOrc			:= ""

ParamType 0 Var 	cNumOrc 			As Character	Default ""	

If !Empty(cNumOrc)
	If Len(Alltrim(cNumOrc)) == TamSX3("L4_NUM")[1]
		cNumExp := "%'" + cNumOrc + "'%"
	Else
		cNumExp := "%'" + StrZero(Val(cNumOrc),TamSX3("L4_NUM")[1]) + "'%"
	EndIf
Else
	cNumExp := "%''%"
EndIf
 
BeginSql ALIAS cOptionsTemp  
						
				SELECT	 *					
				FROM %table:SL4% SL4						
				WHERE	
						L4_FILIAL		=	%xfilial:SL4%				AND	
					  	L4_NUM			=	%exp:cNumExp%				AND        
						SL4.%NotDel%
EndSql

DbSelectArea(cOptionsTemp)

While !(cOptionsTemp)->(EOF()) 
		    
	For nI := 1 To FCount()
	
		AADD( aPay , {FieldName(nI) , FieldGet(nI)} )
		
	Next nI
	
	AADD( aSL4 , aPay )
	
	aPay := {}	
	
	(cOptionsTemp)->(DbSkip())
	
EndDo

(cOptionsTemp)->( DbCloseArea() )  

RestArea(aArea)

Return aSL4


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISGetFieldOptions
Busca de opções de orcamento em outro ambiente
@param   cField				Campo utilizado para busca
@param   cFieldAssigned		Conteúdo do campo para busca
@param   aFieldsAdd			Campos adicionais a serem buscados
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aOptions				Opções de orcamentos encontrados, contendo n orcamentos. Retorna os campos
@return  aOptions[1]			Numero do Orcamento	-> L1_NUM
@return  aOptions[2]			Numero da DAV/PRE		-> L1_NUMORC
@return  aOptions[3]			Nome do CLiente		-> A1_NOME				
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISGetFieldOptions( cField , cFieldAssigned , aFieldsAdd )

Local aOptions	   		:= {}					// Retorno funcao
Local aAux					:= {}					// Armazena aOptions temporario
Local cOptionsTemp 		:= GetNextAlias()		// Armazena Proximo alias disponível
Local cFieldExp			:= ""					// Expressao do campo preenchido
Local cAddSELECT			:= ""					// Expressao com campos adicionais a buscar
Local nI					:= 0					// Contador

Default cField				:= ""
Default cFieldAssigned		:= ""
Default aFieldsAdd			:= {}

ParamType 0 Var 	cField 			As Character	Default ""	
ParamType 1 Var  	cFieldAssigned	As Character	Default ""
ParamType 2 Var  	aFieldsAdd			As Array		Default {}

cFieldAssigned := AllTrim(cFieldAssigned)

/*/
	Monta expressão dos campos adicionais
/*/
cAddSELECT := "%"
For nI := 1 To Len(aFieldsAdd)
	If 	SL1->(ColumnPos(aFieldsAdd[nI])) > 0
		cAddSELECT := cAddSELECT + " , " + aFieldsAdd[nI]
	Else
		aDel(aFieldsAdd, nI)
		aSize(aFieldsAdd, nI-1)
	EndIf
Next nI
cAddSELECT := cAddSELECT + "%"

If cField = "L1_NUM" .AND. !Empty(cFieldAssigned) .AND. At("*",cFieldAssigned) == 0
	If Len(Alltrim(cFieldAssigned)) <> TamSX3("L1_NUM")[1] 			
		cFieldAssigned := StrZero(Val(cFieldAssigned),TamSX3("L1_NUM")[1])
	EndIf
EndIf 

/*/
	Monta Expressão do campo de pesquisa
/*/
If SuperGetMv("MV_LJORPAR",,.F.) // "Procura de orçamento por parte do conteudo de busca?" Utiliza LIKE
	
	cFieldAssigned := StrTran(cFieldAssigned,"*","%")	

	If (cField == "A1_NOME" .OR. cField == "A1_NREDUZ")
		cFieldExp := 	"%(A1_NOME LIKE '" + cFieldAssigned + "' OR " + ;
						"A1_NREDUZ LIKE '" + cFieldAssigned + "') AND%"
	Else
		cFieldExp := "%" + cField + " LIKE '" + cFieldAssigned + "' AND%"
	EndIf
	
Else  
	cFieldExp := "%" + cField + " = '" + cFieldAssigned + "' AND%"
EndIf

BeginSql ALIAS cOptionsTemp  

						%NoParser%
						
						SELECT	 L1_NUM , A1_NOME , L1_NUMORC %exp:cAddSELECT%  
					
						FROM %table:SL1% SL1
						INNER JOIN %table:SA1% SA1 ON 	A1_COD 	= 	L1_CLIENTE		AND
															A1_LOJA	=	L1_LOJA
						WHERE	
								L1_FILIAL		=	%xfilial:SL1%				AND	
								A1_FILIAL		=	%xfilial:SA1%				AND	
								L1_DTLIM 		>= 	%exp:DTOS(dDataBase)%		AND
								L1_DOC      	=   " "							AND
								L1_DOCPED		=	" "							AND
								%exp:cFieldExp%
								SL1.%notDel%									AND
								SA1.%notDel%									AND
								(
								 	(
								 		L1_SERIE    =	" "				AND	
								 		L1_PDV		=	" "				AND
										L1_STORC	<>	"C"
									) OR
									(
										L1_RESERVA	<>	" " 			AND
										L1_STATUS	<>	"D"				
									)
								)
EndSql

LjGrvLog( "STDISGetFi",  "SQL:  " + GetLastQuery()[2] )

				
While !(cOptionsTemp)->(EOF()) 
	
	// Verifica se existe arquivo informando que o orcamento ja foi importado
	// So add se o arquivo nao existir
	If !FR271HArq ( {{ (cOptionsTemp)->L1_NUM , "" }} , .T., Nil , .T. )[1]
		  
		AADD( aAux , (cOptionsTemp)->L1_NUM 		)		
		AADD( aAux , (cOptionsTemp)->L1_NUMORC 	)
		AADD( aAux , AllTrim((cOptionsTemp)->A1_NOME) 		)
					    
		For nI := 1 To Len(aFieldsAdd)
		
	   		AADD( aAux , (cOptionsTemp)->&(aFieldsAdd[nI])	)
			
		Next nI
		
		AADD( aOptions , aAux )
		
		aAux := {}
	
	EndIf
	
	(cOptionsTemp)->(DbSkip())
	
EndDo

(cOptionsTemp)->( DbCloseArea() )

DbSelectArea( "SL1" ) // Seleção de tabela (preventiva)

Return aOptions


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISGetOptions
Busca das opções de orçamento
@param   nOption				Opção de pesquisa. 2 -> Todos 3 -> Data
@param   lIsPafPdv			Conteúdo do campo para busca
@param   lSearchAll			Busca Todas as vendas PAFECF
@param   aFieldsAdd			Campos adicionais a serem buscados
@param   dDataMov				Data do movimento a realizar a Busca PAFECF 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aOptions				Opções de orcamentos encontrados, contendo n orcamentos. Retorna os campos
@return  aOptions[1]			Numero do Orcamento	-> L1_NUM
@return  aOptions[2]			Numero da DAV/PRE		-> L1_NUMORC
@return  aOptions[3]			Nome do CLiente		-> A1_NOME				
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISGetOptions( 	nOption , lIsPafPdv , lSearchAll , aFieldsAdd 	,;
							  	dDataMov												)

Local aOptions			:= {}					// Retorno da funcao
Local cDateExp			:= "%%"					// Armazena Expressão de data de emissao
Local cOrderBy			:= "%%"					// Expressao ordenação
Local cAddSELECT		:= ""					// Expressao com campos adicionais a buscar
Local cOptionsTemp		:= GetNextAlias()		// Pega o proximo Alias Disponivel
Local nI				:= 0					// Contador
Local aAux				:= {}					// Auxiliar	

Default nOption				:= 0
Default lIsPafPdv			:= .F.
Default lSearchAll			:= .F.
Default aFieldsAdd			:= {}
Default dDataMov				:= dDataBase

ParamType 0 Var 		nOption 			As Numeric		Default 0
ParamType 1 Var  	lSearchAll			As Logical		Default .F.
ParamType 2 Var  	aFieldsAdd			As Array		Default {}

/*/
	Monta expressão dos campos adicionais
/*/    
If Len(aFieldsAdd) > 0
	cAddSELECT := "%"
	For nI := 1 To Len(aFieldsAdd)
		If SL1->(ColumnPos(aFieldsAdd[nI])) > 0 
			cAddSELECT := cAddSELECT + " , " + aFieldsAdd[nI]
		Else
			aDel(aFieldsAdd, nI)
			aSize(aFieldsAdd, nI-1)
		EndIf
	Next nI
	cAddSELECT := cAddSELECT + "%" 
EndIf	

If nOption == 3 // DATA  
	cDateExp := "%L1_EMISSAO	= '"+ DTOS(dDataBase)+"'	 AND%"
EndIf

cOrderBy := "%L1_NUM , A1_NOME, L1_NUMORC%"

Do Case

	Case lIsPafPdv .AND. lSearchAll // PAF - Redução Z 
		
		// TODO: Verificar se tem que tirar a DateExp da query quando for LOJA160
		BeginSql alias cOptionsTemp
				
				%NoParser%
				
				SELECT	 L1_NUM , A1_NOME, L1_NUMORC %exp:cAddSELECT%
				
				FROM %table:SL1% SL1 ,%table:SA1% SA1
				
				WHERE	L1_FILIAL		=	%xfilial:SL1%					AND	
						A1_FILIAL		=	%xfilial:SA1%					AND	
						L1_DTLIM 		< 	%exp:DTOS(dDataMov)%  			AND
						L1_SERIE		=  " "								AND
						L1_DOC			=  " "   	                		AND
						L1_PDV			=  " "       	           			AND
						L1_STORC		<> "C"								AND
						L1_ORCRES		=  " "								AND
						L1_CLIENTE		=  A1_COD							AND
						L1_LOJA	   		=  A1_LOJA                			AND
						L1_SITUA		=  " "								AND	
						L1_TPORC		=  "P"							    AND					
						SL1.%notDel%										AND
						SA1.%notDel% 
						                           
				ORDER BY %exp:cOrderBy%
		EndSql	  

	Case lIsPafPdv // PAF
		BeginSql alias cOptionsTemp
				
				%NoParser%
				
				SELECT	 L1_NUM ,A1_NOME, L1_NUMORC %exp:cAddSELECT%
				
				FROM %table:SL1% SL1 ,%table:SA1% SA1 
				
				WHERE	L1_FILIAL		=	%xfilial:SL1%				AND	
						A1_FILIAL		=	%xfilial:SA1%				AND	
						L1_DTLIM 		>= 	%exp:DTOS(dDataBase)%		AND
						L1_CLIENTE  	=  A1_COD						AND
						L1_LOJA  		=  A1_LOJA            			AND
						L1_PEDRES		=  " "							AND
						L1_DOCPED		=  " "							AND
						L1_DOC      	=  " "							AND
						((L1_SERIE  	=  " "							AND
						L1_PDV      	=  " "       	        		AND
						L1_STORC 		<> "C"							AND
						%exp:cDateExp%
						SL1.%notDel%									AND
						SA1.%notDel%)            						OR	 
				    	(L1_RESERVA		<> " "							AND
						 L1_STATUS 		<> "D"							))
									
				ORDER BY %exp:cOrderBy%
				
		EndSql    
	
	Otherwise // Normal

		BeginSql alias cOptionsTemp

				%NoParser%
				
				SELECT L1_NUM , A1_NOME , L1_NUMORC %exp:cAddSELECT%
			
				FROM %table:SL1% SL1 ,%table:SA1% SA1
				 
				WHERE	L1_FILIAL		=	%xfilial:SL1%				AND	
						A1_FILIAL		=	%xfilial:SA1%				AND	
						L1_DTLIM 		>= 	%exp:DTOS(dDataBase)%  		AND
						L1_DOC      	=  	" "   	            		AND
						L1_DOCPED		=	" "							AND
						L1_CLIENTE 		=  	A1_COD					   	AND
						L1_LOJA  		=  	A1_LOJA              		AND
						L1_PEDRES     	=  	" "		  				    AND
						%exp:cDateExp%
						SL1.%notDel%									AND
						SA1.%notDel%									AND
						(
						 	(
						 		L1_SERIE    =	" "				AND	
						 		L1_PDV		=	" "				AND
								L1_STORC	<>	"C"
							) OR
							(
								L1_RESERVA	<>	" " 			AND
								L1_STATUS	<>	"D"				
							)
						)
					
				ORDER BY %exp:cOrderBy%
				
		EndSql        
			
EndCase
           
LjGrvLog( "STDISGetOp",  "SQL:  " + GetLastQuery()[2] )

While !(cOptionsTemp)->(EOF()) 
	
	// Verifica se existe arquivo informando que o orcamento ja foi importado
	// So add se o arquivo nao existir
	If !FR271HArq ( {{ (cOptionsTemp)->L1_NUM , "" }} , .T., Nil , .T. )[1]
			  
		AADD( aAux , (cOptionsTemp)->L1_NUM 		)		
		AADD( aAux , (cOptionsTemp)->L1_NUMORC 	)
		AADD( aAux , AllTrim((cOptionsTemp)->A1_NOME )	)
		
	
		For nI := 1 To Len(aFieldsAdd)
			AADD( aAux , (cOptionsTemp)->&(aFieldsAdd[nI])	)
		Next nI

		AADD( aOptions , aAux )
		
	EndIf	
	
	aAux := {}
	
	(cOptionsTemp)->(DbSkip())
	
EndDo

(cOptionsTemp)->( DbCloseArea() )

DbSelectArea( "SL1" ) // Seleção de tabela (preventiva)

Return aOptions


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISSearchField
Retorna a estrutura do campo de pesquisa para Interface

@param   cField		Nome do Campo   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aField -> Retorna a estrutura do campo de pesquisa para a interface
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISSearchField(cField)

Local aField		:= {}				// Estrutura do campo de pesquisa para interface
Local cLabelScreen	:= ""				// Label da interface
Local bValid		:= {|| .T.}			// ValiCAIXAPOSdação do campo

Default cField		:= ""

ParamType 0 Var cField As Character	Default ""

If !Empty(cField)

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(cField))
		
		Do Case 
		
			Case cField == "A1_CGC"
		
				cLabelScreen := AllTrim( X3Titulo()  )
		
			Case cField == "L1_NUMORC"
			
				If SuperGetMv("MV_LJPRVEN",,.T.) 	// Utiliza Pre-Venda:
					cLabelScreen := "Pre-Venda"
				Else
					cLabelScreen := "DAV"			// Utiliza DAV
				EndIf
				
			OtherWise
			
				cLabelScreen := AllTrim( X3Titulo()  )
				
		EndCase
		  			
		AAdd( aField		, 	cLabelScreen			        		  		) 	// [01] Titulo do campo
		AAdd( aField		,	AllTrim( X3Descric() )         				)	// [02] ToolTip do campo
		AAdd( aField		,	AllTrim( SX3->X3_CAMPO )         	  		)	// [03] Id do Field
		AAdd( aField		,	SX3->X3_TIPO                  		  		)	// [04] Tipo do campo
		AAdd( aField		,	SX3->X3_TAMANHO               		  		)	// [05] Tamanho do campo
		AAdd( aField		,	SX3->X3_DECIMAL                				)	// [06] Decimal do campo
		AAdd( aField		,	bValid                         				)	// [07] Code-block de validacaoo do campo
		AAdd( aField		,	Nil                          				)	// [08] Code-block de validacaoo When do campo
		AAdd( aField		,	StrTokArr( AllTrim( X3CBox() ),';')  		)	// [09] Lista de valores permitido do campo
		AAdd( aField		,	Nil 											)	// [10] Indica se o campo tem preenchimento obrigatorio
		AAdd( aField		,	Nil                         				)	// [11] Code-block de inicializacao do campo
		AAdd( aField		,	Nil                            				)	// [12] Indica se trata-se de um campo chave
		AAdd( aField		,	Nil                            				)	// [13] Indica se o campo pode receber valor em uma operacao de update.
		AAdd( aField		,	.F.							     				)  	// [14] Indica se o campo e virtual
		
	EndIf
	
EndIf

Return(aField)

//-------------------------------------------------------------------
/*/{Protheus.doc} STDIMPPROD
Importa as informacoes do produto da retaguarda, para posteriormente cadastra-lo na base local

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDIMPPROD( cProdCode, aFieldsProd )
Local aArea   := GetArea()
Local aCampos := {}							// Array de campos
Local aRet    := {}							// Parâmetro de retorno
Local nX      := 0							// Contador

DEFAULT cProdCode := ""

LjGrvLog("Importa_Orcamento:STDImpProd","Comunicação OK")

DbSelectArea("SB1")
DbSetOrder(1)//B1_FILIAL+B1_COD
If 	DbSeek( xFilial("SB1")+cProdCode )
	For nX := 1 to Len(aFieldsProd)
		AAdd(aRet,{aFieldsProd[nX],&("SB1->"+aFieldsProd[nX]),Nil})
	Next nX
EndIf

RestArea(aArea)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDValLock
Valida se o orçamento está com lock, ou seja, se está sendo alterado por outro usuário
@param   sNumOrc  Número do Orçamento L1_NUM
@author  Varejo
@version P12
@since   29/01/2021
@return  lRet  Se o orçamento estiver sendo utilizado retorno .T. 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STDValLock(sNumOrc)
Local lRet  := .F. 

DbSelectArea("SL1")
DbSetOrder(1)

If SL1->(DbSeek(xfilial("SL1") + sNumOrc))
	If SL1->(SimpleLock()) //tenta dar lock no registro, se retornar .F. significa que está com lock
		SL1->(MsUnLock())
	Else
		lRet :=.T. 
	Endif 	
Endif 

Return  lRet


