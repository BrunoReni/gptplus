#INCLUDE "AE_SViag_AP6.ch"
#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_SVIAG  �Autor  �Armando / Willy     � Data �  09/06/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Mbrowse da Solicita��o de Viagem Nacional e Internacional.���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function AE_SViag()

Local lLHPFIL := ExistBlock("LHPFIL")
Local cFil := "" 
Local aOpcAdc		:= {}

Private aCores,cCadastro

chktemplate("CDV")

// D - Verde     -> Montando Solicitacao
// I - Amarela   -> Encaminhado para Aproca��o via Workflow
// A - AZUL      -> Solicitacao Aprovada
// P - PRETO     -> Solicitacao Reprovada
// M - MARROM    -> Aguardando Depto de Viagens
// E - Laranja   -> Liberado para Presta��o de Contas
// B - BRANCO    -> Presta��o de Contas sem Solicitacao
// C - Vermelho  -> Respectivo acerto Concluido
// Z - Cinza     -> Fechamento da Viagem


aCores := {	{ 'LHP_Flag = "D" ', 'BR_VERDE'   	},;
			{ 'LHP_Flag = "I" ', 'BR_AMARELO' 	},;
			{ 'LHP_Flag = "A" ', 'BR_AZUL'    	},;
			{ 'LHP_Flag = "P" ', 'BR_PRETO'   	},;
			{ 'LHP_Flag = "M" ', 'BR_MARROM'  	},;
			{ 'LHP_Flag = "E" ', 'BR_LARANJA' 	},;
			{ 'LHP_Flag = "B" ', 'BR_BRANCO'  	},;
			{ 'LHP_Flag = "C" ', 'BR_VERMELHO'	},;
			{ 'LHP_Flag = "K" ', 'BR_PINK'	  	},;
			{ 'LHP_Flag = "Z" ', 'BR_CINZA'   	} }

Private aRotina := MenuDef()

cCadastro := STR0001 //"Solicita��o de Viagem"

If ExistBlock("AE_SVMENU")
	aOpcAdc := ExecBlock("AE_SVMENU",.F.,.F.,{aRotina})
	If ValType(aOpcAdc) == "A" .And. Len(aOpcAdc) > 0
		aRotina := aClone(aOpcAdc)
	Endif
Endif

dbSelectArea('LHP')
LHP->(DbSetOrder(2))

If lLHPFIL 
	cFil := Execblock("LHPFIL",.F.,.F.,__cUserID)
	If !Empty(cFil)
		DbSetFilter({||&(cFil)},cFil)
	EndIf	
EndIf

mBrowse(6, 1, 22, 75, "LHP",,,,,, aCores)

If lLHPFIL 
	DBClearFilter()
EndIf

Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �08/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {	{STR0002, 	'AxPesqui',        	0, 1},; //"Pesquisa"
				{STR0003,	'T_AE_SV001(0)',	0, 2},; //"Visualiza"
				{STR0004,  	'T_AE_SV001(1)',    0, 3},; //"Incluir"
				{STR0005,  	'T_AE_SV001(2)', 	0, 4},; //"Alterar"
				{STR0006,  	'T_AE_SV001(3)',   	0, 5},; //"Excluir"
				{STR0007, 	'T_AE_SV003(.T.)', 	0, 6},; //"Imprimir"
				{STR0008,	'T_AE_SV001(4)',    0, 7},; //"Aprova��o"
				{STR0009,   	'T_AE_SV001(5)', 	0, 8},; //"Copiar"
				{STR0010,   	'T_Cancela("S")', 	0, 9},; //"Cancelar"
				{STR0011,  	'T_AE_SV005',      	0, 10, ,.F.}} //"Legenda"

Return(aRotina)