#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"

Function LOJA2117 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCGeraXMLSA3     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em gerar o XML SF2							      ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCGeraXMLSF2 From LJAGeraXML
		
	Method New()					                   	//Metodo construtor
	Method Gerar(oDadoInt, oCampos)						//Gera Xml
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCGeraXMLSF2.		                  ���
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
Method New() Class LJCGeraXMLSF2

	//Executa o metodo construtor da classe pai
	_Super:New()
		
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
���Parametros�ExpO1 (1 - oDadoInt) - Dado da integracao.				  ���
���			 �ExpO2 (2 - oCampos) - Campos do XML.				  		  ���											                
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Gerar(oDadoInt, oCampos) Class LJCGeraXMLSF2

	Local lRetorno 		:= .T.					//Retorno do metodo
	Local oModel   		:=  Nil
    Local aArea 		:= {}
    Local nTipo			:= 3
	
	DEFAULT oCampos		:= NIL
	
	//Tipo de operacao
	/*Do Case
			
		Case oDadoInt:cTipo	= _INCLUSAO			
				nTipo := 3   		
		Case oDadoInt:cTipo = _ALTERACAO							
				nTipo := 4				
		Case oDadoInt:cTipo = _EXCLUSAO							
				nTipo := 5							
	End Case*/
	
	nTipo := Val(oDadoInt:cTipo)
	
	//Getarea
	aArea := GetArea()
	
	DbSelectArea(oDadoInt:cTabela)
	
	//Posicionar no registro 
	DbSetOrder(Val(oDadoInt:cIndice))
	
	DbSeek(oDadoInt:cChave)
	
	oStructDA0 := FWFormStruct(1,"SF2")
	oStructDA1 := FWFormStruct(1,"SD2")
	
	aArea := GetArea()
	SX3->( dbsetorder(2) )
	If SX3->( dbseek("F2_CGCCLI") )
		
		//Adiciona o campo na estrutura para que seja enviado o CPF / CNPJ do cliente da venda
		oStructDA0:AddField(	AllTrim( X3Titulo()  )        				, ;		// [01] Titulo do campo
								AllTrim( X3Descric() )         				, ;		// [02] ToolTip do campo
								AllTrim( SX3->X3_CAMPO )       				, ;		// [03] Id do Field
								SX3->X3_TIPO                   				, ;		// [04] Tipo do campo
								SX3->X3_TAMANHO                				, ;		// [05] Tamanho do campo
								SX3->X3_DECIMAL                				, ;		// [06] Decimal do campo
								FwBuildFeature(1, AllTrim(SX3->X3_VALID) )	, ;		// [07] Code-block de valida��o do campo
								FwBuildFeature(2, AllTrim(SX3->X3_WHEN) )	, ;		// [08] Code-block de valida��o When do campo
								StrTokArr( AllTrim( X3CBox() ),';') 		, ;		// [09] Lista de valores permitido do campo
								X3Obrigat( SX3->X3_CAMPO )     				, ;		// [10] Indica se o campo tem preenchimento obrigat�rio
								FwBuildFeature(3, AllTrim(SX3->X3_RELACAO))	, ;		// [11] Code-block de inicializacao do campo
								NIL                            				, ;		// [12] Indica se trata-se de um campo chave
								NIL                            				, ;		// [13] Indica se o campo pode receber valor em uma opera��o de update.
								( SX3->X3_CONTEXT == 'V' )     )					// [14] Indica se o campo � virtual
		
		
		//Adiciona o campo na estrutura para que seja enviado o Nome do cliente da venda
		SX3->( dbseek("A1_NOME") )
		oStructDA0:AddField(	AllTrim( X3Titulo()  )        				, ;		// [01] Titulo do campo
								AllTrim( X3Descric() )         				, ;		// [02] ToolTip do campo
								"NOMECLIENTE"		   			    		, ;		// [03] Id do Field
								SX3->X3_TIPO                   				, ;		// [04] Tipo do campo
								SX3->X3_TAMANHO                				, ;		// [05] Tamanho do campo
								SX3->X3_DECIMAL                				, ;		// [06] Decimal do campo
								FwBuildFeature(1, AllTrim(SX3->X3_VALID) )	, ;		// [07] Code-block de valida��o do campo
								FwBuildFeature(2, AllTrim(SX3->X3_WHEN) )	, ;		// [08] Code-block de valida��o When do campo
								StrTokArr( AllTrim( X3CBox() ),';') 		, ;		// [09] Lista de valores permitido do campo
								X3Obrigat( SX3->X3_CAMPO )     				, ;		// [10] Indica se o campo tem preenchimento obrigat�rio
								FwBuildFeature(3, AllTrim(SX3->X3_RELACAO))	, ;		// [11] Code-block de inicializacao do campo
								NIL                            				, ;		// [12] Indica se trata-se de um campo chave
								NIL                            				, ;		// [13] Indica se o campo pode receber valor em uma opera��o de update.
								( SX3->X3_CONTEXT == 'V' )     )					// [14] Indica se o campo � virtual
	EndIf
	RestArea( aArea )
	
	oModel:= MpFormModel():New("FormModel_CUPOM", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields("CAB_NOTA", /*cOwner*/, oStructDA0 , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:AddGrid("ITEM_NOTA", "CAB_NOTA"/*cOwner*/, oStructDA1 , /*bLinePre*/,{|x|Oms010Lok()}/*bLinePost*/,/*bPre*/,{|x|Oms010Tok()}/*bPost*/,/*bLoad*/)
	oModel:GetModel("ITEM_NOTA"):SetUseOldGrid()
	oModel:GetModel("ITEM_NOTA"):SetUniqueLine({"D2_ITEM"})
	oModel:SetRelation("ITEM_NOTA",{{"D2_FILIAL",'xFilial("SD2")'},{"D2_DOC","F2_DOC"},{"D2_SERIE","F2_SERIE"}}, "D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM") //SD2->(IndexKey()))

	
	oModel:Activate()
	
	oModel:LoadValue( "CAB_NOTA" , "NOMECLIENTE", SA1->A1_NOME ) //Carrega o valor do campo "NOME_CLIENTE" que foi adicionado na estrutura
	
	::cXml := oModel:GetXMLDATA(Nil, nTipo)
	
	oModel:Deactivate()
	
	RestArea(aArea)

Return lRetorno
