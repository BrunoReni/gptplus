#INCLUDE "MSOBJECT.CH"

Function LOJA2131 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJAAdapXMLRec     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata responsavel em manter os dados comuns dos adapters  ���
���			 �de recebimento, nao pode ser instanciada.						 	  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJAAdapXMLRec

	Data cXml											//XML a ser processado
	Data cError											//Mensagem de erro no processamento
	Data cWarning										//Mensagem de aviso do processamento
	Data oEstruXml										//Estrutura do XML recebido    
	Data oXml											//Objeto do tipo LJCXml    
	Data cOperacao										//Operacao (3-inclusao ; 4-alteracao ; 5-exclusao)	
	
	Method New()		                   				//Metodo construtor
	Method Processar(cXml)								//Processa o XML recebido, metodo abstrato
	Method ConverCamp(cCampo, cValor, oCampo)			//Converte campo
	Method ErroRotAut()									//Retorna o erro da rotina automatica
	Method LerXml(cDelimit)								//Le a estrutura do XML recebido
	Method Destrutor()									//Limpa os objetos que foram criados
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJAAdapXMLRec.		                  ���
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
Method New() Class LJAAdapXMLRec

	Self:cXml 		:= ""
	Self:cError		:= ""
	Self:cWarning	:= ""
	Self:oEstruXml	:= NIL
	Self:oXml		:= NIL
    Self:cOperacao	:= ""
    
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Processar �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel processar o XML recebido.                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cXml) - XML recebido.	    				  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Processar(cXml) Class LJAAdapXMLRec
	
	Local lRetorno := .T.				//Retorno do metodo

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ConverCamp�Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel converter os campos.							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cCampo) - Campo a ser formatado.			  	  ���
���			 �ExpC2 (2 - cValor) - Valor a ser formatado.			  	  ���
���			 �ExpC3 (3 - cCampo) - Objeto do tipo LJCCAMPOS.		  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConverCamp(cCampo, cValor, oCampo) Class LJAAdapXMLRec

	Local cTipo := ""						//Tipo do campo no dicionario
	
	cTipo := oCampo:ElementKey(cCampo):cTipo
	
	Do Case
        //Data
		Case cTipo == "D"
		
			cValor := STOD(cValor)
		
		//Numerico
		Case cTipo == "N"
			
			cValor := Val(cValor)
			
		//Caracter
		Case cTipo == "C"
			
			cValor := cValor
			
	End Case	
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ErroRotAut�Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar o erro da rotina automatica.		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Caracter									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ErroRotAut() Class LJAAdapXMLRec
    
	Local cRetorno	:= ""					//Retorno do metodo
	Local aErro		:= {}					//Erro retornado da rotina automatica
	Local nCount	:= 0					//Variavel do tipo contador    
	
	//Busca o erro da rotina automatica
	aErro := GetAutoGRLog()
		
	For nCount := 1 To Len(aErro)
		cRetorno += aErro[nCount]
		
		If nCount != Len(aErro)
			cRetorno += " | "			
		EndIf
	Next
	
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �LerXml    �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel ler a estrutura do XML recebido.		  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cDelimit) - Delimitador.					  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LerXml(cDelimit) Class LJAAdapXMLRec
	
	Local lRetorno 	:= .T.					//Retorno do metodo
	Local oRetorno	:= Nil					//Retorno do metodo Criar			
	
    //Instancia o Objeto LJCXml
    Self:oXml := LJCXml():New()
	        
    //Cria a estrutura do XML recebido
    //oRetorno := Self:oXml:Criar(NIL, "_", "XML\produto.xml") <> NIL
    oRetorno := Self:oXml:Criar(Self:cXml, cDelimit, NIL)

    If oRetorno <> Nil
       //Guarda a estrutura lida
       Self:oEstruXml := Self:oXml:oXml 
    Else
    	Self:cError 	:= Self:oXml:cError
    	Self:cWarning 	:= Self:oXml:cWarning
    	lRetorno 	:= .F.
    EndIf
	
Return lRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Destrutor �Autor  �Vendas Clientes     � Data �  26/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Limpa os objetos que foram criados	         			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Destrutor() Class LJAAdapXMLRec
	
	Self:oXml:Destrutor()	
		
	If Self:oEstruXml <> NIL
		FreeObj(Self:oEstruXml)
		Self:oEstruXml	:= NIL
	EndIF
	
	If Self:oXml <> NIL
		FreeObj(Self:oXml)	
		Self:oXml := NIL
	EndIf

Return Nil
