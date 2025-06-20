#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1017 ; Return  			// "dummy" function - Internal Use

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadosSitefDireto�Autor  �Vendas Clientes     � Data �  10/09/07   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em armazenar os dados da transacao.               ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/
Class LJCDadosSitefDireto
	
	Data nRetorno							//Ira guardar o codigo de retorno da funcao
	Data nRedeDest							//Codigo da rede de destino (provedor)
	Data nFuncSitef						    //Codigo da funcao sitef
	Data nOffSetCar							//Posicao do inicio do cartao no dados TX
	Data cDadosTx							//Dados da transacao
	Data nTaDadosTx							//Tamanho do dados TX
	Data cDadosRx							//Dados de retorno da Transacao
	Data nTaDadosRx							//Quantidade maxima de dados que podem ser colocados em dados RX
	Data nCodResp							//Codigo de resposta retornado pelo autorizador
	Data nTempEspRx							//Tempo de espera do dados RX
	Data cCupomFisc							//Numero do cupom correspondente a operacao
	Data cDataFisc							//Data fiscal no formato AAAAMMDD
	Data cHorario							//Horario fiscal no formato HHMMSS
	Data cOperador							//Identificacao do operador de caixa
	Data nTpTrans							//Indica se a transacao e apenas de consulta (valor 0) ou se e uma
											//transacao que exige uma confirmacao
	
	Method DadosSitef()						//Metodo construtor

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �DadosSitef�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCDadosSitefDireto.		              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method DadosSitef() Class LJCDadosSitefDireto

	::nRetorno			:= 0
	::nRedeDest 		:= 0
	::nFuncSitef 		:= 0
	::nOffSetCar		:= 0
	::cDadosTx			:= ""
	::nTaDadosTx		:= 0
	::cDadosRx			:= ""
	::nTaDadosRx		:= 0
	::nCodResp			:= 0
	::nTempEspRx		:= 0
	::cCupomFisc		:= ""
	::cDataFisc			:= ""
	::cHorario			:= ""
	::cOperador			:= ""
	::nTpTrans			:= 0
					
Return Self
