#INCLUDE "PCOA210.ch"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA210_1 �Autor  �Paulo Carnelossi    � Data �  11/11/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para inclusao/alteracao de restricao de acesso para  ���
���          �configuracao de cubo(utiliza mesmo controle acesso por      ���
���          �entidade                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA210_1()
Private aRotina := MenuDef()

If SuperGetMV("MV_PCO_AL3",.F.,"2")=="1"  //1-Verifica acesso por entidade
	PcoAcess_CfgCubo()                    // 2-Nao verifica o acesso por entidade
Else
	Aviso(STR0007,STR0018, {"Ok"}) //"Atencao"###"Para ativar a inclusao de acesso por Configuracao de Cubo devera ser ativado o parametro MV_PCO_AL3."
EndIf

Return


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �29/11/06 ���
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
Local aUsRotina := {}
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	    "A210DLG"  , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"A210DLG"  , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"A210DLG"  , 0 , 4},; //"Alterar"
							{ STR0006, 		"A210DLG"  , 0 , 5},; //"Excluir"
							{ STR0008, 		"PCOA210Leg"  , 0 , 2, ,.F.}} //"Legenda"

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//������������������������������������������������������������������������Ŀ
	//� Adiciona botoes do usuario no aRotina                                  �
	//��������������������������������������������������������������������������
	If ExistBlock( "PCOA2101" )
		//P_E������������������������������������������������������������������������Ŀ
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de lan�amentos                                          �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA2101                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E��������������������������������������������������������������������������
		If ValType( aUsRotina := ExecBlock( "PCOA2101", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)