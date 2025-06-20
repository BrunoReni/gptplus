#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1022 ; Return  // "dummy" function - Internal Use

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCTelaComplementar�Autor  �Vendas Clientes     � Data �  04/09/07   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em guardar os dados da tela complementar.	 	   ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/
Class LJCTelaComplementar
	
	Data cTipoCampo                           	//Tipo do campo (N-NUMERICO , A-ALFANUMERICO, F-FLAG(S/N))
	Data nMinimo								//Tamanho minimo do campo (de 1 a 50)
	Data nMaximo								//Tamanho maximo do campo (de 1 a 50)
	Data cCampo									//Descricao do campo
	Data oValor                                 //Valor do campo
		
	Method TelaCompl()                       	//Metodo construtor

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TelaCompl �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCTelaComplementar.                   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TelaCompl() Class LJCTelaComplementar

	::cTipoCampo := ""
	::nMinimo := 0
	::nMaximo := 0
	::cCampo := ""
	::oValor := Nil

Return Self