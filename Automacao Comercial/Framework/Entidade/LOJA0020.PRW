#INCLUDE "MSOBJECT.CH"

User Function LOJA0020 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCCampos			�Autor  �Vendas Clientes     � Data �  25/02/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em guardar uma colecao de LJCDadosCampo.	 	  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCCampos From LJCColecao
	
	Method New(cTabela)								//Metodo construtor
	Method Clone()		 							//Metodo construtor para o clone
    Method Clonar()									//Metodo que ira clonar o objeto LJCCampos por recursividade
	
	//Metodos internos
	Method CarregaCam(cTabela)						//Carrega os campos da tabela
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCCampos.			                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Tabela onde estao os campos.          ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cTabela) Class LJCCampos
	
	//Executa o metodo construtor da classe pai
	::Colecao()
	
    //Carrega os campos da tabela
    ::CarregaCam(cTabela)
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Clone     �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCCampos para o clone.                ���
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
Method Clone() Class LJCCampos
	
	//Executa o metodo construtor da classe pai
	::Colecao()
	
Return Self


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �CarregaCam�Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em carregar os campos da tabela.                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Tabela onde estao os campos.          ���															  
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CarregaCam(cTabela)	Class LJCCampos
	
	Local oDadosCampo 	:= Nil						//Objeto do tipo LJCDadosCampo
	Local cCampo		:= ""						//Nome do campo
	
	//Seleciona a tabela
	DbSelectArea("SX3")
	//Seta o indice
	DbSetOrder(1)
	//Posiciona no registro
	DbSeek(cTabela)
	
	//Carrega os campos da tabela
	While !EOF() .And. X3_ARQUIVO == cTabela
		
		cCampo := AllTrim(Upper(X3_CAMPO))
		
		//Verifica se o campo que esta no SX3 pode ser utilizado		
		If (cTabela)->(FieldPos(cCampo)) > 0
			
			//Estancia o objeto LJCDadosCampo
			oDadosCampo := LJCDadosCampo():New()			
	        
	        //Atribui as caracteristica do campo
			oDadosCampo:cNome 		:= cCampo
			oDadosCampo:cTipo 		:= X3_TIPO
			oDadosCampo:nTamanho 	:= X3_TAMANHO
			oDadosCampo:nCasasDec 	:= X3_DECIMAL
			oDadosCampo:cFormato	:= X3_PICTURE
			oDadosCampo:cContexto	:= X3_CONTEXT
			oDadosCampo:cOrdem		:= X3_ORDEM
			oDadosCampo:cTitulo		:= AllTrim(X3Titulo())
			oDadosCampo:cDescricao	:= AllTrim(X3DescriC())
					
			//Adiciona o objeto na colecao
			::ADD(oDadosCampo:cNome, oDadosCampo)
		
		EndIf
		
		//Vai para o proximo registro
		DbSkip()
	End
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Clonar    �Autor  �Vendas Clientes     � Data �  28/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em clonar o objeto LJCCampos.			          ���
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
Method Clonar() Class LJCCampos

	Local oRetorno := Nil				//Retorno do metodo
	Local nCount   := 0					//Variavel de controle contador
	
	//Estancia o objeto LJCCampos (recursividade)
	oRetorno := LJCCampos():Clone()
	
	//Atribui ao array do novo objeto um clone do array original
	For nCount := 1 To ::Count()
		If Valtype(::Elements(nCount)) == "O"
			oRetorno:ADD(::aColecao[nCount, 1], ::Elements(nCount):Clonar())
		Else
			oRetorno:ADD(::aColecao[nCount, 1], ::Elements(nCount))
		EndIf		
	Next
	
Return oRetorno