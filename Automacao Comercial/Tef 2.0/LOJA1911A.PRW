#INCLUDE "PROTHEUS.CH"        

Function LOJA1911A ; Return  // "dummy" function - Internal Use 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCDiscPayGoCCCD�Autor  �VENDAS CRM     � Data �  29/10/09  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Interface para transcao com cartao de credito e cartao de ��� 
���          �debito utilizando CliSitef.                                 ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
//Class LJCDiscDirecaoCCCD From LJACCCD
Class LJCDiscDirecaoCCCD From LJCDiscadoCCCD

	//Data oTransTef			// Transacao Tef
   //	Data oTransDiscado		// Transacao Tef Discado
	
	Method Create(oDiscado) //Constructor 
   /*	Method Credito(oDadosTran)
	Method CreditoPar(oDadosTran)
	Method Debito(oDadosTran)  
	Method DebitoPar(oDadosTran)
	Method DebitoPre(oDadosTran)
	Method Confirmar()
	Method Desfazer()
	Method FuncoesAdm(oDadosTran)   */

EndClass       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto de comunicacao                                       ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Create(oDiscado) Class LJCDiscDirecaoCCCD 
	
	_Super:Create()
	
	//oSuper:New()
   	Self:oTransDiscado 	:= LJCTransDirecao():New(oDiscado)  

Return Self      