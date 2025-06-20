#INCLUDE "AE_DV004_AP6.ch"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_DV004_AP6�Autor  �Armando / Willy   � Data �  09/06/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Legenda                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
// V - Verde     -> Colaborador Viajando
// D - Amarela   -> Iniciado Processo de Acerto
// L - Laranja   -> Encaminhado e Aguardando Confirmacao
// C - Vermelho  -> Autorizado e Concluido
// M - Marrom    -> Iniciado a Presta��o de Contas sem Solicita��o
// B - Branco    -> Presta��o de Contas sem Solicita��o
// P - Preto     -> Processo de acerto em atraso
// Z - Cinza     -> Fechamento da Viagem          
// K - Pink		 -> Solicita��o cancelada

//user Function AE_DV004()
Template Function AE_DV004()

Local cCadastro := STR0001 //"Presta��o de Contas"

Local aCores2 := {	{ 'BR_VERDE',	STR0002 },; //"Colaborador Viajando"
					{ 'BR_AMARELO',	STR0003 },; //"Iniciado Processo de Acerto"
					{ 'BR_LARANJA', STR0004 },; //"Encaminhado e Aguardando Confirma��o "
					{ 'BR_VERMELHO',STR0005 },; //"Autorizado e Liberado"
					{ 'BR_PINK', 	STR0006 },; //"Solicita��o Cancelada"
					{ 'BR_CINZA',  	STR0007 },; //"Fechamento da Viagem"
					{ 'BR_MARROM',  STR0008 },; //"Iniciado Prest.Contas sem Solicita��o "
					{ 'BR_BRANCO' , STR0009 },; //"Presta��o de Contas sem Solicita��o "
					{ 'BR_PRETO',   STR0010 },;//"Acerto da Despesa em Atraso"
					{ 'BR_AZUL',  STR0012 }} 

ChkTemplate("CDV")

BrwLegenda(cCadastro,STR0011,aCores2) //"Legenda"

Return
