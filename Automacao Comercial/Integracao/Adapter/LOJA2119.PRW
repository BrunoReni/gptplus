#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"

Function LOJA2119 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCGeraXMLSC5     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em gerar o XML PEDIDO						      ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCGeraXMLSC5 From LJAGeraXML
		
	Method New()					                   	//Metodo construtor
	Method Gerar(oDadoInt, oCampos)						//Gera Xml
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCGeraXMLSC5		                  ���
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
Method New() Class LJCGeraXMLSC5

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
Method Gerar(oDadoInt, oCampos) Class LJCGeraXMLSC5

	Local lRetorno 		:= .T.					//Retorno do metodo
	Local lRet			:= .F.					//Retorno de consulta
	Local oModel   		:=  Nil
	Local cEntidade		:= oDadoInt:cTabela
	Local cChave 		:= oDadoInt:cChave
	Local nIndice 		:= oDadoInt:cIndice
    Local cDescricao 	:= 'N_PEDIDO'
    Local aArea 		:= {}
    Local cTipo			:= oDadoInt:cTipo
    Local nTipo			:= 3
	
	DEFAULT oCampos		:= NIL
	
	// carrega tipo de opera��o
	/*Do Case
			
		Case cTipo 	= _INCLUSAO			
				nTipo := 3   		
		Case cTipo = _ALTERACAO							
				nTipo := 4				
		Case cTipo = _EXCLUSAO							
				nTipo := 5							
	End Case*/
	
	nTipo := Val(cTipo)

	//Getarea
	aArea := GetArea()
	
	DbSelectArea(cEntidade)
	DbSetOrder(1)
	lRet := DbSeek(cChave)
	oStructDA0 := FWFormStruct(1,"SC5")
	oStructDA1 := FWFormStruct(1,"SC6",Nil ,.F.)
	oModel:= MpFormModel():New("FormModel_PEDIDO", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields(      "CAB_PEDIDO", /*cOwner*/, oStructDA0 , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:AddGrid ("ITEM_PEDIDO", "CAB_PEDIDO"/*cOwner*/, oStructDA1 , /*bLinePre*/,{|x|Oms010Lok()}/*bLinePost*/,/*bPre*/,{|x|Oms010Tok()}/*bPost*/,/*bLoad*/)
	oModel:GetModel("ITEM_PEDIDO"):SetUseOldGrid()
	oModel:GetModel("ITEM_PEDIDO"):SetUniqueLine({"C6_ITEM"})
	oModel:SetRelation("ITEM_PEDIDO",{{"C6_FILIAL",'xFilial("C6")'},{"C6_NUM","C5_NUM"}},SC6->(IndexKey()))   

	//Alimenta ::cXml com os dado reetornado do objeto
	oModel:Activate()
	::cXml := oModel:GetXMLDATA()
	oModel:Deactivate()
	
	RestArea(aArea)

Return lRetorno