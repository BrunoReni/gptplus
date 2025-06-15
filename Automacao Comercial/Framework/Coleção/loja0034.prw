#INCLUDE "MSOBJECT.CH"

User Function LOJA0034 ; Return  // "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCHashTable     �Autor  �Vendas Clientes     � Data �  11/02/09   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em guardar uma colecao de objetos.         	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCHashTable From LJACollection
	
	Method New()                        		//Metodo construtor
	Method Add(oKey, oObject)  	        		//Metodo que ira adicionar um objeto na Colecao
	Method Contains(oKey)						//Metodo que ira verificar se existe um determinado elemento na Colecao
	Method Remove(oKey)	    					//Metodo para remover um objeto da Colecao
	Method ElementKey(oKey)						//Metodo que ira retornar um elemento da Colecao
	Method Elements(nIndice)					//Metodo que ira retornar um elemento de um determinado indice
	Method ElementPar(nIndice)					
 	Method ToArray()							//Metodo que retorna os elementos da colecao em um array
	Method Clonar()								//Metodo que ira fazer um clone do objeto LJCHashTable usando recursividade
				
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  11/02/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCHashTable                           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											   				  ���
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCHashTable

    _Super:New()

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Add       �Autor  �Vendas Clientes     � Data �  11/02/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Adiciona um elemento a colecao.                             ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpV1 (1 - oKey)    - Chave da colecao.					  ���
���			 �ExpO1 (2 - oObject) - Elemento da colecao.				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Add(oKey, oObject) Class LJCHashTable

    //Verifica se o elemento ja existe na colecao, se sim, remove
    If ::Contains(oKey)
    	::Remove(oKey)
    EndIf
    
    //Adiciona um elemento na colecao
    AADD(::aColecao, {oKey, oObject})

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Contains  �Autor  �Vendas Clientes     � Data �  11/02/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se existe um determinado elemento na colecao.      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpV1 (1 - oKey)    - Chave da colecao.					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Contains(oKey) Class LJCHashTable
	
	Local lRetorno 	:= .F.				//Variavel de retorno do metodo
	Local nPosicao 	:= 0				//Posicao do array
		
	//Verifica se possui algum elemento na colecao
	If ::Count() > 0
		Begin Sequence
			//Procura o elemento na colecao
			nPosicao := Ascan(::aColecao, {|x| x[1] == oKey})
			
			//Verifica se encontrou o elemento
			If nPosicao > 0 
				lRetorno := .T.	
			EndIf
		Recover
			lRetorno := .F.			
		End Sequence
	EndIf
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Remove    �Autor  �Vendas Clientes     � Data �  11/02/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Remove um elemento da colecao.                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpV1 (1 - oKey) - Chave da colecao.					      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Remove(oKey) Class LJCHashTable
	
	Local nPosicao 	:= 0				//Posicao do produto no array
	
	//Procura o elemento na colecao
	nPosicao := Ascan(::aColecao, {|x| x[1] == oKey})
	//Apaga o elemento da colecao
	ADel(::aColecao, nPosicao)
	//Redimensiona a colecao		
	ASize(::aColecao, ::Count() - 1)
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ElementKey�Autor  �Vendas Clientes     � Data �  11/02/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna um elemento da colecao atraves da chave.            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpV1 (1 - oKey) - Chave da colecao.					      ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ElementKey(oKey) Class LJCHashTable

	Local oElement  := Nil				//Objeto que sera retornado na funcao
	Local nPosicao 	:= 0				//Posicao do elemento no array

	//Procura o elemento na colecao
	nPosicao := Ascan(::aColecao, {|x| x[1] == oKey})

	//Pega o elemento
	oElement := ::Elements(nPosicao)
		
Return oElement

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Elements  �Autor  �Vendas Clientes     � Data �  11/02/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna um elemento da colecao atraves de um indice.        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nIndice) - Posicao do array.				      ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Elements(nIndice) Class LJCHashTable

	Local oElement := Nil				//Objeto que sera retornado na funcao
	
	oElement := ::aColecao[nIndice, 2]
	
Return oElement

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Elements  �Autor  �Vendas Clientes     � Data �  11/02/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna um elemento da colecao atraves de um indice.        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nIndice) - Posicao do array.				      ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ElementPar(nIndice) Class LJCHashTable

	Local oPar := Nil				//Objeto que sera retornado na funcao
	
	oPar := LJCKeyValuePar():New(::aColecao[nIndice, 1], ::aColecao[nIndice, 2])

Return oPar

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Clonar    �Autor  �Vendas Clientes     � Data �  11/02/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em clonar o objeto LJCHashTable                 ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Clonar() Class LJCHashTable

	Local oRetorno := Nil				//Retorno do metodo
	Local nCount   := 0
	
	//Estancia o objeto LJCColecao (recursividade)
	oRetorno := LJCHashTable():New()
	
	//Atribui ao array do novo objeto um clone do array original
	For nCount := 1 To ::Count()
		If Valtype(::Elements(nCount)) == "O"
			oRetorno:ADD(::aColecao[nCount, 1], ::Elements(nCount):Clonar())
		Else
			oRetorno:ADD(::aColecao[nCount, 1], ::Elements(nCount))
		EndIf
	Next
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ToArray   �Autor  �Vendas Clientes     � Data �  11/02/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar o conteudo da colecao em um array   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Array                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ToArray() Class LJCHashTable

	Local aRetorno := {}				//Retorno do metodo
	Local nCount   := 0
	
	//Atribui ao array o conteudo do objeto
	For nCount := 1 To ::Count()
		AADD(aRetorno, ::aColecao[nCount, 2])
	Next
	
Return aRetorno