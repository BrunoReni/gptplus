#INCLUDE "MSOBJECT.CH" 

User Function LOJA0008 ; Return  // "dummy" function - Internal Use

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿟ipo de operacoes para calculo�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
#DEFINE ADICAO 		1
#DEFINE SUBTRACAO 	2
#DEFINE MULTIPLICA 	3
#DEFINE DIVISAO		4
	
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튏lasse    쿗JCFuncoes       튍utor  쿣endas Clientes     � Data �  22/10/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿎lasse com as funcoes comuns.										 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Class LJCFuncoes
			
	Method Funcoes()											//Metodo construtor
	Method Split(cDados, cDelimit)								//Metodo que ira receber uma string com delimitadores e retornar uma colecao
    Method Join(oDados, cDelimit)								//Metodo que ira receber uma colecao e retornar uma string separada por um delimitador
	Method CalcValor(nValor1, nValor2, nOperacao, nCasasDec) 	//Metodo que ira retornar um valor calculado
	Method DecToHex(nDec)										//Metodo que ira converter um valor decimal para hexadecimal
	Method HexToDec(cHex)										//Metodo que ira converter um valor hexadecimal para decimal
	Method Rat(cDados, cDelimit)								//Metodo que ira retornar a posicao que o delimitador esta na string da esquerda para direita.
	Method IsNumeric(cValor)									//Metodo que ira verificar se a string passada eh numerica
		
EndClass

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿑uncoes   튍utor  쿣endas Clientes     � Data �  22/10/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎onstrutor da classe LJCFuncoes.         		              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�															  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method Funcoes() Class LJCFuncoes
Return Self

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿞plit     튍utor  쿣endas Clientes     � Data �  22/10/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo Responsavel em receber uma string com delimitadores  볍�
굇�			 쿮 retornar uma uma colecao. 								  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpC1 (1 - cDados) 	- Dados com delimitadores. 			  볍�
굇�			 쿐xpC2 (2 - cDelimit) 	- Delimitador utilizado para quebrar  볍�			
굇�			 �						  a string e retornar a colecao.      볍�			
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bject												      볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method Split(cDados, cDelimit) Class LJCFuncoes
	
	Local oDados 	:= {}						//Variavel de retorno do metodo
	Local nCount	:= 1						//Contador utilizado na chave da colecao
	Local cAux		:= ""						//Variavel auxiliar
	Local lLoop		:= .T.						//Variavel de controle do While
	
	//Estancia o objeto colecao
	oDados := LJCColecao():Colecao()
	
	//Retira o delimitador do inicio da string
	If Substr(cDados, 1, 1) == cDelimit
		cDados := Substr(cDados, 2)
	EndIf

	//Retira o delimitador do fim da string
	If Substr(cDados, Len(cDados), 1) == cDelimit
		cDados := Substr(cDados, 1, Len(cDados) - 1)
	EndIf
	
	While lLoop
	    //Procura o delimitador na string
		nPos := At(cDelimit, cDados)
	    
	    //Verifica se encontrou o delimitador
		If nPos > 0 
			cAux := Substr(cDados, 1, nPos-1)
			cDados := Substr(cDados, nPos + 1)
			oDados:Add("P" + AllTrim(Str(nCount)), cAux)						
		Else
			oDados:Add("P" + AllTrim(Str(nCount)), cDados)
			lLoop := .F.
		EndIf
		
		nCount ++
	End
		
Return oDados

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿕oin      튍utor  쿣endas Clientes     � Data �  22/10/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo Responsavel em receber uma colecao de string e       볍�
굇�			 퀁etornar uma string separada por delimitadores.			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpC1 (1 - oDados) 	- Colecao.			  	 			  볍�
굇�			 쿐xpC2 (2 - cDelimit) 	- Delimitador utilizado para retornar 볍�			
굇�			 �						  a string.						      볍�			
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿞tring												      볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method Join(oDados, cDelimit) Class LJCFuncoes
	
	Local cRetorno 	:= ""						//Variavel de retorno do metodo
	Local nCount	:= 0						//Contador utilizado para varrer a colecao
	Local nDados	:= oDados:Count()
		
	//Cria a string de retorno
	For nCount := 1 To nDados
		cRetorno += oDados:Elements(nCount) + cDelimit
	End
	
	//Retira o delimitador do fim da string
	If Substr(cRetorno, Len(cRetorno), 1) == cDelimit
		cRetorno := Substr(cRetorno, 1, Len(cRetorno) - 1)
	EndIf
		
Return cRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿎alcValor 튍utor  쿣endas Clientes     � Data �  19/11/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo Responsavel em receber dois valor e retornar o       볍�
굇�			 쿬alculo(divisao, subtracao, adicao ou multiplicacao) entre  볍�
굇�			 쿮les.														  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - nValor1) 			- Valor 1.	  	 			  볍�
굇�			 쿐XPN2 (2 - nValor2) 			- Valor 2.					  볍�			
굇�			 쿐XPN3 (3 - nOperacao)			- Tipo operacao.			  볍�
굇�			 �									1 - Adicao.				  볍�							
굇�			 �									2 - Subtracao.			  볍�							
굇�			 �									3 - Multiplicacao.		  볍�							
굇�			 �									4 - Divisao.			  볍�							
굇�			 쿐XPN4 (4 - nCasasDecimais) 	- Numero de casas decimais.	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿙umerico												      볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method CalcValor(nValor1, nValor2, nOperacao, nCasasDec) Class LJCFuncoes
	
	Local lTrunca 	:= .T.							//Se o valor trunca ou arredonda
	Local nRetorno 	:= 0							//Retorno do metodo
	
	DEFAULT nOperacao := ADICAO    
	DEFAULT nCasasDec := 2
	
	//Verifica qual operacao vai ser executada
	Do Case
		Case nOperacao == ADICAO
			nRetorno := nValor1 + nValor2
					
		Case nOperacao == SUBTRACAO
			nRetorno := nValor1 - nValor2
		
		Case nOperacao == MULTIPLICA
			nRetorno := nValor1 * nValor2
		
		Case nOperacao == DIVISAO
			nRetorno := nValor1 / nValor2
	EndCase
	
	//Trunca ou arredonda o valor
	If lTrunca
		nRetorno := NoRound(nRetorno, nCasasDec)
	Else
		nRetorno := Round(nRetorno, nCasasDec)
	EndIf
	
Return nRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿏ecToHex  튍utor  쿣endas Clientes     � Data �  03/12/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em converter um decimal para hexadecimal 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - nDec)	- Valor decimal.    	  	 			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿎aracter												      볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method DecToHex(nDec) Class LJCFuncoes
	
	Local aNibbles 	:= {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'} 	//Array com os valores em hexadecimal
    Local cHex     	:= ''																				 	//Retorno do m�todo	
    Local nRes     	:= nDec																					//Valor em decimal
    Local nDiv		:= 0                                                                                   	//Variavel auxiliar

    While nRes > 0
	    If nRes >= 16
	        nDiv := int( nRes / 16 )
			nRes := nRes - ( nDiv * 16 )
        Else
            nDiv := 0
        EndIf
		
		cHex := aNibbles[nRes + 1] + cHex
        nRes := nDiv
    End
	
Return cHex

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿓exToDec  튍utor  쿣endas Clientes     � Data �  03/12/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em converter um hexadecimal para decimal 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cHex)	- Valor hexadecimal.    	  	 		  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿙umerico												      볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method HexToDec(cHex) Class LJCFuncoes
	
	Local aNibbles 	:= { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' } 	//Array com os valores em hexadecimal
    Local nDec 		:= 0																						//Retorno do metodo			
    Local nCount	:= 0																						//Variavel contador	
    Local nPosicao	:= 0																						//Posicao do array
    Local nAux		:= 0																						//Variavel auxiliar

    For nCount := Len(cHex) - 1 to 0 step -1
	    nPosicao := Ascan( aNibbles, Substr(Upper(cHex), nCount + 1, 1 ) ) - 1
        nAux := len( cHex ) - nCount - 1
        nDec += nPosicao * (16 ** nAux)
    Next
	
Return nDec

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿝at       튍utor  쿣endas Clientes     � Data �  13/12/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em retornar a posicao que o delimitador  볍�
굇�			 쿮sta na string da esquerda para direita. 					  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cDados)   - String com os dados.  	 			  볍�
굇�			 쿐XPC2 (2 - cDelimit) - Delimitador a ser procurado.		  볍�			
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿙umerico												      볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method Rat(cDados, cDelimit) Class LJCFuncoes

	Local nRetorno 		:= 0							//Retorno do metodo   
	Local nTamDados 	:= 0							//Tamanho da string cDados
	Local nCount		:= 0							//Variavel de controle contador
		
	//Tamanho da string
	nTamDados := Len(cDados)

	//Procura o caracter na string
	For nCount := nTamDados To 1 Step -1
		If SubStr(cDados, nCount, 1) == cDelimit 
			nRetorno := nCount
			Exit
		EndIf
	Next

Return nRetorno  

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿔sNumeric 튍utor  쿣endas Clientes     � Data �  13/12/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em verificar se a string passada eh 	  볍�
굇�			 쿻umerica.								 					  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cValor)   - Valor a ser verificado. 			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico												      볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method IsNumeric(cValor) Class LJCFuncoes
	
	local nCount 	:= 1							//Variavel auxiliar contador
	local cChar		:= ""							//Variavel para guardar caracter a caracter do valor passado
	local lRetorno	:= .T.							//Retorno do metodo
	
	//Tira os espacos da string
	cValor := AllTrim(cValor)
    
 	//Procura se algum caracter da string nao eh numerico
	While nCount <= Len(cValor) .AND. lRetorno
	   //Pega caracter a caracter
	   cChar := SubStr(cValor, nCount++, 1)
	   //Verifica se o caracter eh numerico
	   lRetorno := IsDigit(cChar) .OR. (cChar $ ".,")
	   
	   If !lRetorno
	   		Exit
	   EndIf
	End
  
Return lRetorno
