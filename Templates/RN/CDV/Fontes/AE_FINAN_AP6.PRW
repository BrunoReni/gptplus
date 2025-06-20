#INCLUDE "AE_FINAN_AP6.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_FINAN_AP6�Autor  �Willy / Armando     � Data �  09/06/02 ���
�������������������������������������������������������������������������͹��
���Desc.     �Mbrowse da efetiva��o da Solicita��o no Depto de Viagem.    ���
�������������������������������������������������������������������������͹��
���Uso       �AP6                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function AE_FINAN()

Local aOpcAdc		:= {}

Private aCores		:= {}
Private cCadastro	:= ""
Private _cPerg 	:= "FINAN1    "
Private _cFilSOl 	:= ""
Private _aIndexLHP	:= {}
Private bFiltraBrw := {|| Nil}
Private aRotina 	:= MenuDef()

ChkTemplate("CDV")

cCadastro := STR0001 //"Departamento de Viagem"

// M - Marrom    -> Solicita��o Iniciada
// D - Verde     -> Para Aprova��o
// I - Amarela   -> Aguardando Aprovacao
// A - AZUL      -> Solicita��o Aprovada
// P - PRETO     -> Solicita��o Reprovada
// E - Laranja   -> Encaminhado
// B - Branco    -> Presta��o de Contas sem Solicita��o
// C - Vermelho  -> Respectivo acerto concluido
// Z - Cinza     -> Fechamento da Viagem

aCores := {	{ 'LHP_Flag1 = "M"', 'BR_MARROM'  	},;
			{ 'LHP_Flag1 = "D"', 'BR_VERDE'   	},;
			{ 'LHP_Flag1 = "I"', 'BR_AMARELO' 	},;
			{ 'LHP_Flag1 = "A"', 'BR_AZUL'    	},;
			{ 'LHP_Flag1 = "P"', 'BR_PRETO'   	},;
			{ 'LHP_Flag1 = "E"', 'BR_LARANJA' 	},;
			{ 'LHP_Flag1 = "K"', 'BR_PINK'		},;
			{ 'LHP_Flag1 = "B"', 'BR_BRANCO'  	},;
			{ 'LHP_Flag1 = "C"', 'BR_VERMELHO'	},;
			{ 'LHP_Flag1 = "Z"', 'BR_CINZA'   	} }

dbSelectArea("LHP")

If ExistBlock("AE_FNMENU")
	aOpcAdc := ExecBlock("AE_FNMENU",.F.,.F.)
	If ValType(aOpcAdc) == "A"
		If !Empty(aOpcAdc) .AND. Len(aOpcAdc) >= 4
			aAdd(aRotina, aOpcAdc)
		Endif
	Endif
Endif

If Pergunte(_cPerg,.T.)
	dbSelectArea('LHP')
	dbSetOrder(1)
	If Mv_Par01 == 1
		_cFilSOl := 'LHP->LHP_Flag1 == "D".And.'
	ElseIf Mv_Par01 == 2
		_cFilSOl := 'LHP->LHP_Flag1 == "I".And.'
	ElseIf Mv_Par01 == 3
		_cFilSOl := 'LHP->LHP_Flag1 == "A".And.'
	ElseIf Mv_Par01 == 4
		_cFilSOl := 'LHP->LHP_Flag1 == "E".And.'
	Endif
	_cFilSOl += 'dTos(LHP_EMISS)>="'+dTos(Mv_PAR02)+'" .And. dTos(LHP_EMISS)<="'+dTos(Mv_PAR03)+'" .And.'
	_cFilSOl += 'dTos(LHP_SAIDA)>="'+dTos(Mv_PAR04)+'" .And. dTos(LHP_SAIDA)<="'+dTos(Mv_PAR05)+'"'
	
	MsAguarde({ || LHPFilter() }, "Selecionando Viagens ...")
	
	//����������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                              �
	//������������������������������������������������������������
	
	mBrowse(6, 1, 22, 75, "LHP",,,,,, aCores)
	
	//������������������������������������������������������������������������Ŀ
	//� Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       �
	//��������������������������������������������������������������������������
	EndFilBrw("LHP",_aIndexLHP)
	//������������������������������������������������������������������������Ŀ
	//�Restaura a condicao de Entrada                                          �
	//��������������������������������������������������������������������������
EndIf	

Return
*--------------------------------------------------------------------------------------


*--------------------------------------------------------------------------------------
Static Function LHPFilter()
*--------------------------------------------------------------------------------------

bFiltraBrw	:= {|| FilBrowse("LHP",@_aIndexLHP,@_cFilSOl)}
Eval(bFiltraBrw)

Return(.T.)
*--------------------------------------------------------------------------------------

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

aRotina := {{STR0012		,'PesqBrw'				,0, 1},; //"Pesquisa"
			{STR0013		,'T_AE_SV001(0)'		,0, 2},; //"Visualiza"
			{STR0014		,'T_AE_SV003(.F.)'		,0, 2},; //"Imprimir"
			{STR0015		,'T_AE_SV001(4)'		,0, 4},; //"Aprova��o"
			{STR0016		,'T_AE_FV001(_cFilSOl)'	,0, 4},; //"Encaminhar"
			{STR0017		,'T_Cancela("D")'		,0, 4},; //"Cancelar"
			{STR0018		,'T_AE_AprovFin()'     	,0, 4},; //"Parametros"
			{STR0019		,'T_AE_FV002'			,0, 2, ,.F.} } //"Legenda"
			
Return(aRotina)                                                                                                   
