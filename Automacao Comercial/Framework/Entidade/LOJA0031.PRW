#INCLUDE "MSOBJECT.CH"

User Function LOJA0031 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCEntidadeSistemica�Autor  �Vendas Clientes   � Data �  25/02/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe que representa um entidade sistemica, ou seja, uma entidade  ���
���			 �que n�o pode ser encontrada no SX3,SX2, SIX.                        ���
���			 �Herda da classe LJAEntidade a maioria das funcionalidades,          ���
���			 �a principal diferen�a � que aqui � for�ada a instancia de uma       ���
���			 �conex�o DBF.                                                        ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCEntidadeSistemica From LJAEntidade
          
	Method New()
	Method MontCampos()             // Monta os campos do �ndice
	Method Clonar()					// Clone espec�fico da Entidade Sistemica
	Method Conexao()				// Metodo que ira estancia se necessario e retorna a conexao
	Method CarrCampos()				// Metodo que ira carregar a estrutura dos campos da entidade
	Method CarrIndice()				// Metodo que ira carregar a estrutura dos indices da entidade	
EndClass
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em estancia se necessario e retorna a conexao   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto   									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New( cTabela, lCriaEstru ) Class LJCEntidadeSistemica
	_Super:New( cTabela, lCriaEstru )
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Conexao   �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em estancia se necessario e retorna a conexao   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �LJCConexao: Conex�o DBF da entidade                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Conexao() Class LJCEntidadeSistemica
	
	//Estancia o objeto do tipo LJCConexao for�ando como codebase, pois n�o existe em TOP
	If ::oConexao == Nil
		::oConexao := LJCConexao():NewCodeBase(Self)				
	EndIf
	
Return ::oConexao

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �CarrCampos�Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em carregar a estrutura dos campos da entidade  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �		   									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CarrCampos() Class LJCEntidadeSistemica
	Local nCount		:= 1									// Contador tempor�rio
	Local oCamposTmp	:= LJCColecao():New()					// Cole��o tempor�ria com os campos
	Local aFieldNames	:= Array((Self:cTabela)->(FCount()))		// Nomes dos campos
	Local aTypes		:= Array((Self:cTabela)->(FCount()))		// Tipos dos campos
	Local aWidths		:= Array((Self:cTabela)->(FCount()))		// Tamanho dos campos
	Local aDecimals		:= Array((Self:cTabela)->(FCount()))		// Decimais dos campos
	Local nTotCampos	:= Array((Self:cTabela)->(FCount()))		// Total de campos
	
	nTotCampos := (Self:cTabela)->(aFields(aFieldNames, aTypes, aWidths, aDecimals))
	
	For nCount := 1 To nTotCampos
		oDadosCampo := LJCDadosCampo():New()			
	        
		//Atribui as caracteristica do campo
		oDadosCampo:cNome 		:= aFieldNames[nCount]
		oDadosCampo:cTipo 		:= aTypes[nCount]
		oDadosCampo:nTamanho 	:= aWidths[nCount]
		oDadosCampo:nCasasDec 	:= aDecimals[nCount]
		oDadosCampo:cFormato	:= ""
		oDadosCampo:cContexto	:= "R"
		oDadosCampo:cOrdem		:= StrZero(nCount,2)
		oDadosCampo:cTitulo		:= aFieldNames[nCount]
		oDadosCampo:cDescricao	:= aFieldNames[nCount]
	
		oCamposTmp:Add(oDadosCampo:cNome, oDadosCampo)		
	Next
	
	//Carrega os campos da tabela
	Self:oCampos := oCamposTmp
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �CarrIndice�Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em carregar a estrutura dos indices da entidade ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�													 ���
�������������������������������������������������������������������������͹��
���Retorno   �		   									   		 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CarrIndice() Class LJCEntidadeSistemica
	Local nCount 		:= 1		// Contador tempor�rio
	Local cIndexKey	:= ""		// Chave do �ndice
	
	Local oIndicesTmp	:= LJCColecao():New()					// Cole��o tempor�ria com os campos
	
	While !Empty(cIndexKey:=(Self:cTabela)->(IndexKey(nCount)))
		oDadosIndice := LJCDadosIndice():New()
		
		//Atribui os dados do indice
		oDadosIndice:nOrdem 		:= nCount
		oDadosIndice:cChave 		:= cIndexKey
		oDadosIndice:oCampos		:= Self:MontCampos(oDadosIndice:cChave)
		
		//Adiciona os dados do indice na colecao
		
		oIndicesTmp:Add( oDadosIndice:nOrdem, oDadosIndice )
		nCount++
	End
	
	Self:oIndices := oIndicesTmp
	
Return Nil

Method MontCampos( cChave ) Class LJCEntidadeSistemica
	
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
���Metodo    �Clonar    �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em clonar o objeto							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto   									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Clonar() Class LJCEntidadeSistemica

	Local oRetorno := Nil				//Retorno do metodo
	
	//Estancia o objeto LJCColecao (recursividade)
	oRetorno := LJCEntidadeSistemica():New(::cTabela, .F.)
	
	//Atribui ao array do novo objeto um clone do array original
	oRetorno:oCampos	:= ::oCampos:Clonar()
	oRetorno:oIndices	:= ::oIndices:Clonar()

Return oRetorno