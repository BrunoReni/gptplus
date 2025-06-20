#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"


Function LOJA1967 ; Return  // "dummy" function - Internal Use

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCTransDiscado  �Autor�VENDAS CRM     � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar as informacoes comuns das          ��� 
���          �transacoes de tef.                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCTransDirecao From LJCTransDiscado				
	
	Method New()
	Method TransCartao(oDadosTran, oTrans)
	Method TransCheque(oDadosTran, oTrans)	
    Method TotTrnsPend() //total de Transacoes Pendentes   
    Method Prefixo001(oDadosTran) //Retorna o prefixo 001

EndClass         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCTransClisitef.               ���
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
Method New(oDiscado) Class LJCTransDirecao

	_Super:New(oDiscado)

Return Self



                                                   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |TransCartao  �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza qualquer transacao de cartao              		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto com dados da transacao                               ���
���          �EXPC2                                                       ���
���          �Transacao corrente                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TransCartao(oDadosTran, oTrans) Class LJCTransDirecao 
	//���������������Ŀ
	//�Manda transacao�
	//�����������������
	Self:oDiscado:SetTrans(oDadosTran) 	
	
	
	Self:oDiscado:CriarCRT(Self:Prefixo001(oDadosTran))

	//��������������������������������Ŀ
	//�Carrega os retorno do Gerenciador�
	//����������������������������������
	oDadosTran := Self:TratarRet(oDadosTran)
	oTrans:Add(oDadosTran:oRetorno:cNsu ,oDadosTran)

   	
Return oDadosTran   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |TransCheque  �Autor  �Vendas CRM       � Data �  22/01/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza qualquer transacao de cartao              		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto com dados da transacao                               ���
���          �EXPC2                                                       ���
���          �Transacao corrente                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TransCheque(oDadosTran, oTrans) Class LJCTransDirecao 
	
	//���������������Ŀ
	//�Manda transacao�
	//�����������������
	Self:oDiscado:SetTrans(oDadosTran)  
		
	Self:oDiscado:CriarCHQ(Self:Prefixo001(oDadosTran))

	//��������������������������������Ŀ
	//�Carrega os retorno do Gerenciado�
	//����������������������������������
	oDadosTran := Self:TratarRet(oDadosTran)
	oTrans:Add(oDadosTran:oRetorno:cNsu ,oDadosTran)   
	
Return oDadosTran 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |TotTrnsPend  �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o total de Transacoes Pendentes            		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto com dados da transacao                               ���
���          �EXPC2                                                       ���
���          �Transacao corrente                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TotTrnsPend() Class LJCTransDirecao 
	Local nRet := 0 
	Local aTransac	:= Self:oDiscado:LerArqPend(_DISCADO_PENDENTE) 
	
	nRet := Len(aTransac)
   	
Return nRet 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |TotTrnsPend  �Autor  �Vendas CRM       � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o total de Transacoes Pendentes            		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1                                                       ���
���          �Objeto com dados da transacao                               ���
���          �EXPC2                                                       ���
���          �Transacao corrente                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Prefixo001(oDadosTran) Class LJCTransDirecao 
	Local cRet := ""    
	
	If !oDadosTran:lUltimaTrn  //N�o � ultima transacao - Prefixo001
		cRet := "002"
	Else
		If Self:TotTrnsPend() > 0 
			cRet := "999"
		EndIf
	EndIf
	
Return cRet

  		