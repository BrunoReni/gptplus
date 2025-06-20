#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"

Function LOJA2107 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJAGeraXML        �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata responsavel em os dados comuns para geracao do XML  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJAGeraXML
	
	Data cXml											//XML gerado
		
	Method New()					                   	//Metodo construtor
	Method Gerar()										//Gera Xml
	Method Gerar1Ent()									//Gera Xml para uma entidade
	Method Gerar2Ent()									//Gera Xml para duas entidades
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJAGeraXML.			                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJAGeraXML
	
	::cXml := ""    
		
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gerar     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gerar o XML. Metodo abstrato, tem que ser    ���
���			 �subscrito pelas classes filhos.	          	  			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oDadoInt) - Dado da integracao.                  ���
���			 �ExpO2 (2 - oCampos) - Lista de campos.                   	  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Gerar(oDadoInt, oCampos) Class LJAGeraXML

	Local lRetorno 	:= .T.					//Retorno do metodo
    
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gerar1Ent �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gerar o XML para uma entidade				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oDadoInt) - Dado da integracao.                  ���
���			 �ExpC1 (2 - cDescricao) - Descricao da tag principal do XML  ���
���			 �ExpC2 (3 - cKey) - Campo chave da entidade.		          ���
���			 �ExpO2 (4 - oCampos) - Lista de campos.                   	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Gerar1Ent(oDadoInt, cDescricao, aFields, oCampos) Class LJAGeraXML

	Local lRetorno 			:= .T.								//Retorno do metodo
    Local oModel   			:= Nil                         		//Objeto do tipo MPFormModel
    Local aArea				:= {}                             	//Guarda a area corrente
    Local oStruct			:= Nil                            	//Objeto do tipo FWFormStruct
    Local nCount			:= 0								//Variavel auxiliar contador
        
    Default cDescricao 		:= ""
    Default aFields			:= {}
	Default oCampos			:= Nil
		
	Conout('LOJA2107 - INICIO (' + Time() + ') : Gerando XML entidade ' + oDadoInt:cTabela + '...')
	
	aArea := GetArea()
	
	//Seleciona a tabela 
	DbSelectArea(oDadoInt:cTabela)
	//Ordena a tabela
	DbSetOrder(Val(oDadoInt:cIndice))
	//Posiciona no registro
	DbSeek(oDadoInt:cChave)
    
    //Cria o objeto FWFormModelStruct
    oStruct := FWFormStruct(1, oDadoInt:cTabela)
           
    /*
    If oStruct:Empty()
    	oStruct := FWGetStructTable( oDadoInt:cTabela )
    EndIf    
    */
    
	/* Utilizando classe que agrupa o SB1 e o SBM
    If oDadoInt:cTabela == "SB1"
    	oStructSBM := FWFormStruct( 1, "SBM" )
    EndIf*/
            
    //Verifica se existe campos adicionais
	If oCampos <> Nil
		For nCount := 1 To oCampos:Count()
			//Adiciona os campos
			oStruct:AddField(oCampos:Elements(nCount):cTitulo	, oCampos:Elements(nCount):cDescricao	, ;
			                 oCampos:Elements(nCount):cNome		, oCampos:Elements(nCount):cTipo 		, ;
			                 oCampos:Elements(nCount):nTamanho	, oCampos:Elements(nCount):nCasasDec	, ;
			                 NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL)
		Next
	EndIf

	//Chama o objeto do framework para gerar o xml
	oModel:= MPFormModel():New('FormModel_' + cDescricao,/*Pre-Validacao*/, {|| FWFormCanDel(oModel)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	
	// Tempor�rio at� pegar o Struct do SM0 automaticamente
	If oDadoInt:cTabela == "SM0"
		oStruct:AddTable("SM0",{"M0_CODIGO","M0_CODFIL"},"Empresas e filiais")
		oStruct:AddIndex(1,"01","M0_CODIGO+M0_CODFIL","Empresa+Filial", "" , "" , .T. )
		oStruct:AddIndex(2,"02","M0_NOME+M0_FILIAL","Nome Empresa+Nome Filial", "" , "" , .T. )
	EndIf
	
	oModel:AddFields("FormModel_" + oDadoInt:cTabela, Nil , oStruct,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)	
	
	/* Utilizando classe que agrupa o SB1 e o SBM
	If oDadoInt:cTabela == "SB1"
		oModel:AddGrid( "FormModel_SBM" , "FormModel_" + oDadoInt:cTabela , oStructSBM )
		oModel:GetModel( "FormModel_SBM" ):SetDescription( "Teste" )
		oModel:SetRelation( "FormModel_SBM" ,{{"BM_GRUPO","B1_GRUPO"}},"BM_FILIAL+BM_GRUPO")
	EndIf*/

    //Verifica a necessidade de enviar Primary key
    If Len(aFields) > 0
    	oModel:SetPrimaryKey( aFields )
    EndIf

	// Tempor�rio at� pegar o Model do SM0 automaticamente
    If oDadoInt:cTabela == "SM0"
    	oModel:GetModel( "FormModel_" + oDadoInt:cTabela ):SetDescription( "FormModel_" + oDadoInt:cTabela )
    	oModel:SetDescription( "FormModel_" + cDescricao )    	
	EndIf
                                       
	oModel:Activate()
	
	//Recupera o xml gerado
	Self:cXml := oModel:GetXMLDATA(Nil, Val(oDadoInt:cTipo))

	oModel:Deactivate()

	RestArea(aArea)

	Conout('LOJA2107 - FIM (' + Time() + ') : Gerando XML entidade ' + oDadoInt:cTabela + '...')    

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gerar2Ent �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gerar o XML para duas entidades			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oDadoInt) - Dado da integracao.                  ���
���			 �ExpC1 (2 - cDescricao) - Descricao da tag principal do XML  ���
���			 �ExpC2 (3 - cKey) - Campo chave da entidade.		          ���
���			 �ExpO2 (4 - oCampos) - Lista de campos.                   	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Gerar2Ent(oDadoInt, cDescricao, cKey, oCampos) Class LJAGeraXML

	Local lRetorno 			:= .T.								//Retorno do metodo
    Local oModel   			:= Nil                         		//Objeto do tipo MPFormModel
    Local aArea				:= {}                             	//Guarda a area corrente
    Local oStruct			:= Nil                            	//Objeto do tipo FWFormStruct
    Local nCount			:= 0								//Variavel auxiliar contador
        
    Default cDescricao 		:= ""
    Default cKey			:= ""
	Default oCampos			:= Nil
		
	Conout('LOJA2107 - INICIO (' + Time() + ') : Gerando XML entidade ' + oDadoInt:cTabela + '...')
	
	aArea := GetArea()
	
	//Seleciona a tabela 
	DbSelectArea(oDadoInt:cTabela)
	//Ordena a tabela
	DbSetOrder(Val(oDadoInt:cIndice))
	//Posiciona no registro
	DbSeek(oDadoInt:cChave)
    
    //Cria o objeto FWFormModelStruct
    oStruct := FWFormStruct(1, oDadoInt:cTabela)
    
    //Verifica se existe campos adicionais
	If oCampos <> Nil
		For nCount := 1 To oCampos:Count()
			//Adiciona os campos
			oStruct:AddField(oCampos:Elements(nCount):cTitulo	, oCampos:Elements(nCount):cDescricao	, ;
			                 oCampos:Elements(nCount):cNome		, oCampos:Elements(nCount):cTipo 		, ;
			                 oCampos:Elements(nCount):nTamanho	, oCampos:Elements(nCount):nCasasDec	, ;
			                 NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL)
		Next
	EndIf
                      	
	//Chama o objeto do framework para gerar o xml
	oModel:= MPFormModel():New('FormModel_'+ oDadoInt:cTabela,/*Pre-Validacao*/, {|| FWFormCanDel(oModel)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields(cDescricao + '_' + oDadoInt:cTabela, Nil , oStruct,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)

    //Verifica a necessidade de enviar Primary key
    If cKey <> ""
    	oModel:SetPrimaryKey({cKey})
    EndIf
    
	oModel:Activate()
	
	//Recupera o xml gerado
	::cXml := oModel:GetXMLDATA(Nil, Val(oDadoInt:cTipo))
	
	oModel:Deactivate()

	RestArea(aArea)

	Conout('LOJA2107 - FIM (' + Time() + ') : Gerando XML entidade ' + oDadoInt:cTabela + '...')    

Return lRetorno