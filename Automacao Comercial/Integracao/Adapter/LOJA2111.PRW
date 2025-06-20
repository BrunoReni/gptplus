#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"

Function LOJA2111 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCGeraXMLAC8     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em gerar o XML AC8							      ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCGeraXMLAC8 From LJAGeraXML
		
	Method New()					                   	//Metodo construtor
	Method Gerar(oDadoInt, oCampos)						//Gera Xml
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCGeraXMLAC8.		                  ���
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
Method New() Class LJCGeraXMLAC8

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
Method Gerar(oDadoInt, oCampos) Class LJCGeraXMLAC8

	Local lRetorno 		:= .T.					//Retorno do metodo
	Local lRet			:= .F.					//Retorno de consulta
	Local oModel   		:=  Nil
	Local oStructA		:=  Nil
	Local oStructB		:=  Nil	
	Local cEntidade		:= oDadoInt:cTabela
	Local cChave 		:= oDadoInt:cChave
	Local cTipo			:= oDadoInt:cTipo
    Local nTipo			:= 0
	Local aArea			:= {}
	
	DEFAULT oCampos		:= Nil
	
	//Carrega tipo de operacao
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
	//Posicionar no registro 
	DbSetOrder(1)
	lRet := DbSeek(cChave)
	
	//Chama o objeto do framework para gerar o xml
	oStructA := FWFormStruct(1,"AC8")
	oStructB := FWFormStruct(1,"SU5")
	
	//-----------------------------------------
	//Monta o modelo do formul�rio
	//-----------------------------------------
	oModel:= MpFormModel():New("RELACIONAMENTOCLIENTES", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields("RELCLIENTE" , /*cOwner*/  , oStructA , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:AddFields("CONTATOS"   ,"RELCLIENTE" /*cOwner*/, oStructB , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)

	//Alimenta ::cXml com os dado reetornado do objeto
	oModel:Activate()
	
	::cXml := oModel:GetXMLDATA(Nil, nTipo)

	oModel:Deactivate()
    
    //Restarea
	RestArea(aArea)
   	    
Return lRetorno