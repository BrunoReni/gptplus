#INCLUDE "MSOBJECT.CH"

Function LOJA1113 ; Return  // "dummy" function - Internal Use 

/* 
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCRplIntegracao  �Autor  �Vendas Clientes     � Data �  04/03/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em integrar o processo via integracao, esta   	  ���
���		     �classe tem que implementar a interface LJIIntegracao.     	      ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCRplIntegracao
		
	Data cTransacao								//Numero da transacao
	
	Method New()	                        	//Metodo construtor
	Method Integrar(oDadosProc)					//Metodo que ira integrar o processo
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  04/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCRplIntegracao.                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCRplIntegracao

	::cTransacao := Nil

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Inserir   �Autor  �Vendas Clientes     � Data �  22/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em armazenar os dados do processo.              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oDadosProc) - Dados do processo.				  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Integrar(oDadosProc) Class LJCRplIntegracao

	Local lRetorno 	:= .T.				//Retorno do metodo
	Local nCount	:= 0				//Variavel de controle contador
	Local oDadosExp	:= Nil				//Objeto do tipo LJCDadosExportacao
	Local oDadoProc	:= Nil				//Objeto do tipo LJCDadoProcesso
	Local oExporta	:= NIl				//Objeto do tipo LJCExporta
	
	//Estancia o objeto LJCDadosExportacao
	oDadosExp := LJCDadosExportacao():New()
		
	For nCount := 1 To oDadosProc:Count()
		//Pega o dado do processo
		oDadoProc := oDadosProc:Elements(nCount)
		
		//Insere o dado do processo na exportacao, se estiver marcado para integrar
		If oDadoProc:lIntegra 		
			oDadosExp:Incluir(oDadoProc:cTabela, oDadoProc:cChave, oDadoProc:nIndice, oDadoProc:cTipo)
		EndIf
	Next
	
	//Estancia o objeto LJCExporta e exporta os dados
	oExporta := LJCExporta():new(oDadosExp, oDadosProc:cProcesso)
	
	//Pega o numero da transacao
	::cTransacao := oExporta:cTransacao
	
Return lRetorno