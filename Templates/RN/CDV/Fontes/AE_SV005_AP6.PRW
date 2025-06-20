#INCLUDE "AE_SV005_AP6.ch"
#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_SV005  �Autor  �Armando / Willy     � Data �  09/06/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Legenda                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �Template CDV - Controle de Despesas de Viagens              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function AE_SV005()

Local cCadastro := STR0001 //"Solicita��o de Viagem"

ChkTemplate("CDV")

aCores2 := { 	{ 'BR_VERDE'   	, STR0002 },; //"Montando Solicita��o                  "
				{ 'BR_AMARELO' 	, STR0003 },; //"Aguardando Aprova��o Workflow         "
				{ 'BR_AZUL'    	, STR0004 },; //"Solicita��o Aprovada         		 "
				{ 'BR_PRETO'   	, STR0005 },; //"Solicita��o Reprovada                 "
				{ 'BR_MARROM'  	, STR0006 },; //"Aguardando Libera��o do Depto Viagem  "
				{ 'BR_LARANJA' 	, STR0007 },; //"Liberado para Presta��o de Contas     "
				{ 'BR_BRANCO'  	, STR0008 },; //"Presta��o de Contas sem Solicita��o   "
				{ 'BR_VERMELHO'	, STR0009 },; //"Respectivo Acerto Concluido           "
				{ 'BR_PINK'		, STR0010 },;   //"Solicita��o Cancelada                 "
				{ 'BR_CINZA'   	, STR0011 }} //"Fechamento da Viagem                  "

BrwLegenda(cCadastro,STR0012,aCores2) //"Legenda da Solicita��o"

Return
