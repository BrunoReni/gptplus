#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

static cCharacter	:= "_:," //Caracteres especiais permitidos

Function FisExecNPI(cFormula)

Local nResultado	:= 0
Local nCont			:= 0
Local nContPilha	:= 0
Local aFormula		:= {}
Local aPilha		:= {}

//Converte em array a f�rmula
aFormula	:= StrTokArr(alltrim(cFormula)," ")

//-------------------------------------------------
//La�o para percorrer todos os elementos da  f�rmula
//-------------------------------------------------
For nCont := 1 to len( aFormula )	
	
	//--------------------------
	//Verifica se � um operador
	//--------------------------
	If aFormula[nCont] $ "+-*/"
		
		//-----------------------------------------------------------------------------------
		//Se for operador ent�o far� o c�lculo com os dois �ltimos operandos do topo da pilha
		//Pega o tamanho da pilha		
		//Prote��o caso a pilha n�o tenha elementos suficiente para executar e n�o ocasionar error log
		//------------------------------------------------------------------------------------
		IF (nContPilha	:= Len( aPilha )) > 1
		
			//----------------------------------------------------------------
			//Realiza o c�lculo considerndo os dois operandos do topo da pilha
			//----------------------------------------------------------------
			Do Case
				Case aFormula[nCont] == '/'
					nResultado	:= 	aPilha[nContPilha-1] / aPilha[nContPilha]
					
				Case aFormula[nCont] == '*'
					nResultado	:= 	aPilha[nContPilha-1] * aPilha[nContPilha]
					
				Case aFormula[nCont] == '+'
					nResultado	:= 	aPilha[nContPilha-1] + aPilha[nContPilha]
					
				Case aFormula[nCont] == '-'
					nResultado	:= 	aPilha[nContPilha-1] - aPilha[nContPilha]			
			EndCase
			
			//------------------------------------------------
			//Remove do Array os dois �ltimos operandos (POP)
			//------------------------------------------------
			ASize( aPilha, nContPilha - 2 ) 			
			
			//---------------------------------------------
			//Adiciona o resultado no topo da pilha (PUSH)
			//---------------------------------------------
			aadd( aPilha, nResultado )		
		Else
			//Se caiu aqui � porq existe algum erro na f�rmula, o processamento dever� ser abortado.
			//TODO tratamento de erro

		EndiF
		
	Else		
	
		//-----------------------------------------------------------------------------------
		//Se n�o � um operador ent�o � um operando, ser� adicionado no topo da pilha (PUSH)		
		//-----------------------------------------------------------------------------------
		nResultado	:= Val(StrTran(aFormula[nCont],",","."))
		aadd(aPilha, nResultado )
					
	EndIF
	
Next nCont

Return nResultado


 //-------------------------------------------------------------------
/*/{Protheus.doc} xFisSYard

Fun��o que executa o algor�tumo Shunting-Yar.
Recebe uma express�o aritim�tica e converte para uma express�o
no formato NPI - Nota��o Polonesa Invertida.

@param  cExpr	 	- Express�o aritim�tica convencional
@return cOutPut 	- Espress�o convertida em NPI

@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Function xFisSYard(cExpr, cFormula)

Local cOutPut 		:= ""
Local cTokenProx 	:= ""
Local aPilha 		:= {}
Local nX 			:= 0
Local cForTmp		:= ""

Default cFormula := ""

//Percorre a express�o caracter por caracter para fazer can�lise
For nX := 1 to Len(cExpr)		
	
	//Pega caracter
	cToken := SubStr(cExpr, nX, 1)
	

	//Pega pr�ximo caracter
	cTokenProx := SubStr(cExpr, nX + 1, 1)
	
	// Se for caracter permitido, ou seja, se for um algarismo, ou se for letra, , virgula ou underscore ent�o ser� permitido.
	If IsDigit(cToken) .Or. IsAlpha(cToken) .Or. cToken $ cCharacter 
		
		//Faco uma validacao do proximo token p/ ver se o numero tem mais de um digito
		//A verifica��o � a mesma feita anteriormente para saber se � um caracter v�lido
		//Se for um caracter v�lido � porq trata-se do mesmo operando, e por isso n�o ser� adiconado espa�o.
		//Se n�o for um caracter/algarismo v�lido, ent�o ser� adicionado espa�o para separar
		cOutPut += cToken 

		cForTmp += cToken 
		If IsDigit(cTokenProx) .Or. IsAlpha(cTokenProx) .Or. cTokenProx $ cCharacter
			cOutPut	+= ""
		Else
			cOutPut	+= space(1)
			cFormula += " " + cForTmp
			cForTmp	:= ""
		EndIF

		
			
	// Se for operador vai para a pilha
	ElseIf isOperator(cToken)
				
		// Enquanto houver um operador no topo da pilha, verificar se o operador
		// da expressao tem precedencia MENOR do que o da pilha, ou seja, deve ser
		// resolvido AP�S ele. Se positivo, o operador da pilha (MAIOR precedencia)
		// vai para o output, e o operador da expressao vai para a pilha.
		While isOperator(ViewTop(aPilha)) .And. PesoOperador(ViewTop(aPilha))  >= PesoOperador(cToken) 
			cOutPut += xPop(aPilha) + " "
		EndDo	
	
		//Adiciona o operador na pilha
		xPush(aPilha, cToken)
		cFormula += " " + cToken
	
	// Se for abertura de parenteses vai para a pilha	
	ElseIf cToken == "("
	
		//Adiciona o parenteses na pilha
		xPush(aPilha, cToken)
		cFormula += " " + cToken
	
	// Se for fechamento de parenteses, retira da pilha e manda para a saida todos os operadores ateh
	// encontrar a abertura do parenteses. Quando encontrar a abertura soh retira da pilha e joga fora.
	ElseIf cToken == ")"
	
		cFormula += " " + cToken
		//Percorre a pilha para buscar todos operandos e operadores que est�o dentro do parenstese que acabou de ser fechado
		While Len(aPilha) > 0
			
			//Verifica elemento do topo da pilha
			cTopo := ViewTop(aPilha)
			
			//Se for diferente de parenteses entao adiciona na string
			If cTopo <> "("
				//Adiciona operador/operando na string e retira do topo da pilha
				cOutPut += xPop(aPilha) + " "				
			Else
				//retira o parenteses da pilha e sai do la�o
				xPop(aPilha)
				Exit
			EndIf
		EndDo
	
	EndIf

Next nX

// Fim de express�o: movo todos os operadores restantes da pilha p/ a saida
//Aqui restam os operadores que ser�o executados por �ltimo
While Len(aPilha) > 0
	cOutPut += xPop(aPilha) + space(1)
EndDo

// Retira espa�os da expressao "Final"
cOutPut := AllTrim(cOutPut)

Return cOutPut

//-------------------------------------------------------------------
/*/{Protheus.doc} xPush

Adiciona elemento no final da pilha

@param array - aPilha - Pilha que dever� ser analisada
@param - xVal - Elemento a ser adicionado na pilha

@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function xPush(aPilha, xVal)

aAdd(aPilha, xVal)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} xPop

Fun��o que retira o elemento do topo da pilha

@param array - aPilha - Pilha que dever� ser analisada

@Return xRet-  Valor retirado do topo da pilha

@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function xPop(aPilha)

Local xRet := ""

If Len(aPilha) > 0
	xRet := aPilha[Len(aPilha)]
	aDel(aPilha,Len(aPilha))
	aSize(aPilha,Len(aPilha) - 1)
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewTop

Fun��o que retorna elemento do topo da pilha

@param array - aPilha - Pilha que dever� ser analisada

@Return  Valor do elemento do topo da pilha

@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function ViewTop(aPilha)
Local xRet := ""

If Len(aPilha) > 0
	xRet := aPilha[Len(aPilha)]
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} isOperator

Fun��o que verifica se caracter � um operador v�lido
@param cChar - Caractere
@Return bool - Verdadeiro se for um operador v�lido
@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function isOperator(cChar)
Return cChar $ "+-/*"

//-------------------------------------------------------------------
/*/{Protheus.doc} PesoOperador

Fun��o que retorna o peso/prioridade do operador.
O operador * tem prioridade maior que o operador + por exemplo

@param cOperador - Operador a ser analisado
@Return nRet - Peso do operador
@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function PesoOperador(cOperador)
Local nPeso := 0

If cOperador $ "*/"
	nPeso := 2
ElseIf cOperador $ "+-"
	nPeso := 1
EndIf

Return nPeso

//-------------------------------------------------------------------
/*/{Protheus.doc} FisChkForm

Fun��o que faz valida��o de sintaxe da formula aritim�tica, antes
que seja converitda em NPI.
@param cExpr - Express�o aritim�tica a ser valida
@Return cRet - Mensagem de erro caso tenha alguma inconsist�ncia
@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Function FisChkForm(cExpr)

Local cRet 			:= ""
Local cToken 		:= ""
Local nX 			:= 0
Local nOperadores 	:= 0
Local nAbreParen 	:= 0
Local nFechaParen 	:= 0
Local nInvalid 		:= 0
Local cInvalid		:= ""
Local lErro			:= .F.

// Tratar a expressao.
// Por exemplo, retirar todos os espa�os em branco, contar os parenteses, operadores e etc.
cExpr := StrTran(cExpr, " ", "")

//Passa por todos os caracteres para validar.
For nX := 1 to Len(cExpr)

	//Pega o caracter da string
	cToken := SubStr(cExpr, nX, 1)	
	
	//Abaixo os contadores
	Do Case	
		Case cToken == "("
			nAbreParen++			
		Case cToken == ")"
			nFechaParen++
			if nFechaParen > nAbreParen
				//Aqui fechou parenteses sem ter aberto antes....erro e abortar
				cRet	:= "Express�o cont�m fechamento de parenteses indevido..."
				lErro	:= .T.
				exit
			EndIF
		Case isOperator(cToken)
			nOperadores++
		Case !(IsDigit(cToken) .Or. IsAlpha(cToken) .Or. cToken $ cCharacter)
			nInvalid++			
			cInvalid += "'" + cToken + "' "
	EndCase

Next nX

// Carateres invalidos na expressao
If !lErro .AND. nInvalid > 0
	cRet	+= "Caracteres inv�lidos, por favor verifique: " + CRLF + CRLF + cInvalid + CRLF + CRLF
EndIf

// Numero de aberturas de parenteses deve ser igual o de fechamentos.
If !lErro .AND.  nAbreParen <> nFechaParen
	cRet	+= "Numero de aberturas de parenteses deve ser igual o de fechamentos."	+ CRLF + CRLF 
EndIf

Return cRet