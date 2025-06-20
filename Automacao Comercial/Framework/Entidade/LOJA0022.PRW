#INCLUDE "MSOBJECT.CH"

User Function LOJA0022 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCIndices	    �Autor  �Vendas Clientes     � Data �  25/02/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em guardar os indices da tabela.           	  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCIndices From LJCColecao
			
	Method New(cTabela)		 							//Metodo construtor
	Method Clone()										//Metodo construtor para o clone
	
	//Metodos internos
	Method CarregaInd(cTabela)							//Metodo que ira carrega os indices da tabela
	Method MontCampos(cChave)                           //Metodo que ira carrega os campos do indice
    Method Clonar()										//Metodo que ira clonar o objeto LJCIndices por recursividade
    	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCIndices.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Tabela onde estao os indices.         ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cTabela) Class LJCIndices
	
	//Executa o metodo construtor da classe pai
	::Colecao()
	
    //Carrega os indices da tabela
    ::CarregaInd(cTabela)
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Clone     �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCIndices para clonar.                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�													          ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Clone() Class LJCIndices
	
	//Executa o metodo construtor da classe pai
	::Colecao()
		
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �CarregaInd�Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em carregar os indices da tabela.               ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela. 					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CarregaInd(cTabela) Class LJCIndices
	
	Local oDadosIndi := Nil					//Objeto do tipo LJCDadosIndice
	
	//Seleciona a tabela
	DbSelectArea("SIX")
	//Seta o indice
	DbSetOrder(1)
	//Posiciona no registro
	DbSeek(cTabela)
	
	//Carrega os dados do indice
	While !EOF() .And. INDICE == cTabela
		
		//Estancia o objeto LJCDadosIndice
		oDadosIndi := LJCDadosIndice():New()			
        
        //Atribui os dados do indice
		oDadosIndi:nOrdem 		:= Val(ORDEM)
		oDadosIndi:cChave 		:= CHAVE
		oDadosIndi:oCampos		:= ::MontCampos(oDadosIndi:cChave)
		
		//Adiciona os dados do indice na colecao
		::ADD(oDadosIndi:nOrdem, oDadosIndi)
		
		//Vai para o proximo registro
		DbSkip()
	End
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �MontCampos�Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em carregar os campos do indice.                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cChave) - Chave do indice. 					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MontCampos(cChave) Class LJCIndices
	
	Local oGlobal 		:= Nil					//Objeto do tipo LJCGlobal
	Local nCount		:= 0                   	//Variavel de controle contador
	Local oCamposInd	:= Nil                 	//Objeto LJCColecao para guardar os campos do indice
	Local oCampos		:= Nil					//Colecao com campos retornados da funcao Split
	Local cCampo		:= ""					//Nome do campo
			
	//Estancia o objeto LJCColecao
	oCamposInd := LJCColecao():Colecao()
	
	//Estancia o objeto LJCGlobal
	oGlobal := LJCGlobal():Global()
	
	//Quebra os campos da chave do indice e retorna em uma colecao
	oCampos := oGlobal:Funcoes():Split(cChave, "+") 
	
	//Adicina na colecao cada campo do indice
	For nCount := 1 To oCampos:Count()	
		cCampo := AllTrim(Upper(oCampos:Elements(nCount)))
		
		If "DTOS" $ cCampo
			cCampo := Substr(cCampo, At("(", cCampo) + 1, Len(cCampo) - At("(", cCampo) - 1)
		EndIf
		
		oCamposInd:ADD(cCampo, cCampo)
	Next
	
Return oCamposInd

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Clonar    �Autor  �Vendas Clientes     � Data �  28/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em clonar o objeto LJCIndices.		          ���
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
Method Clonar() Class LJCIndices

	Local oRetorno := Nil				//Retorno do metodo
	Local nCount   := 0					//Variavel de controle contador
	
	//Estancia o objeto LJCCampos (recursividade)
	oRetorno := LJCIndices():Clone()
	
	//Atribui ao array do novo objeto um clone do array original
	For nCount := 1 To ::Count()
		If Valtype(::Elements(nCount)) == "O"
			oRetorno:ADD(::aColecao[nCount, 1], ::Elements(nCount):Clonar())
		Else
			oRetorno:ADD(::aColecao[nCount, 1], ::Elements(nCount))
		EndIf		
	Next
	
Return oRetorno