/*
���������������������������������������������������������������������������������������� 
������������������������������� < INDICE DAS FUNCOES  > ������������������������������� 
���������������������������������������������������������������������������������������� 
��
�� @1.  InitPV -> Modulo principal do Pedido
�� @2.  PVItePed -> Modulo de Item do Pedido
�� @3.  Acoes dos Botoes 
�� @3A. PVQTde -> Chamada do Keyboard para o Campo Qtde.
�� @3B. PVPrc -> Chamada do Keyboard para o Campo Preco.
�� @6A. PVDtEntr -> Data de Entrega ( BUTTON ENTREGA )
�� @6B. PVProduto -> Carrega o Modulo de Produtos( BUTTON PRODUTO )
�� @6C. PVObs -> Carrega o Memo de Observacao ( BUTTON OBS )
�� @6D. PVFecha -> Fecha o Modulo de Pedidos ( BUTTON CANCELAR )
������������������������������������������������������������������������������������ 

   
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � Pedidos de Venda    �Autor - Paulo Lima   � Data �27/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Modulo de Pedidos        					 			  ���
���			 � InitPedido -> Inicia o Mod. de Pedidos		 			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SFA CRM 6.0                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�NOperacao 1- Inclusao /2 - Alteracao / 3 - Ult.Pedido(Cons.)���
���			 �4 - Ult.Pedido (Gerar Novo Pedido)   	     		 		  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#include "eADVPL.ch"

//Aqui jaz a tela antiga do pedido que foi retirada por econimia de espaco (tamando do prc)
//Function InitPV(aCabPed,aItePed,aCond,aTab,aColIte)
//
