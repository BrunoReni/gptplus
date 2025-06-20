#INCLUDE "AE_FV002_AP6.ch"
#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_FV002  �Autor  �Willy             � Data �  27/02/03     ���
�������������������������������������������������������������������������͹��
���Desc.     �  Legenda                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function AE_FV002()

Local cCadastro := STR0001, aCores3 //"Departamento de Viagem"

chktemplate("CDV")

aCores3 := {	{ 'BR_MARROM'  	, STR0002 },; //"Solicita��o Iniciada					"
				{ 'BR_VERDE'   	, STR0003 },; //"Para Aprova��o              		   	"
				{ 'BR_AMARELO' 	, STR0004 },; //"Aguardando Aprovacao Workflow		"
				{ 'BR_AZUL'    	, STR0005 },; //"Solicita��o Aprovada        	       	"
				{ 'BR_PRETO'   	, STR0006 },; //"Solicita��o Reprovada       		   	"
				{ 'BR_LARANJA' 	, STR0007 },; //"Encaminhado Ag�ncia Viagem/Financeiro"
				{ 'BR_PINK'		, STR0008 },; //"Solicita��o Cancelada				"
				{ 'BR_BRANCO'  	, STR0009 },; //"Presta��o de Contas sem Solicita��o 	"
				{ 'BR_VERMELHO'	, STR0010 },; //"Respectivo Acerto Concluido 		   	"
				{ 'BR_CINZA'   	, STR0011 } } //"Fechamento da Viagem 			   		"

BrwLegenda(cCadastro,STR0012,aCores3) //"Legenda Depto de Viagem"

Return