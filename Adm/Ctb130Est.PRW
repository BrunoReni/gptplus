#INCLUDE "CTBA130.CH"
#INCLUDE "PROTHEUS.CH"
// 17/08/2009 -- Filial com mais de 2 caracteres
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctb130Est  � Autor � Pilar S Albaladejo   � Data � 17/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro Estrutura da Conta                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctb130Est()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA130                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CTB130Est(nAutoOper, aCabAuto, aDetAuto)

If ValType(nAutoOper) = "N" .and. nAutoOper >= 3 .and. nAutoOper <= 5 .and. ValType(aCabAuto) = "A" .and. ValType(aDetAuto) = "A"
	CTB130Auto(nAutoOper, aCabAuto, aDetAuto)
Else
	Private aRotina   := MenuDef()
	Private cCadastro := STR0013  // "Cadastro Mascara Entidade Contabil"
	
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"CTM")
Endif

Return


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �01/12/06 ���
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
*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0006,"AxPesqui", 0 , 1, ,.F.},;	 //"Pesquisar"
							{ STR0007,"Ct130Cap", 0 , 2},;  //"Visualizar"
							{ STR0008,"Ct130Cap", 0 , 3},;  //"Incluir"
							{ STR0009,"Ct130Cap", 0 , 4},;  //"Alterar"
							{ STR0010,"Ct130Cap", 0 , 5} }  //"Excluir"
Return(aRotina)


/*/{Protheus.doc} CTB130Auto
Fun��o auxiliar para grava��o de m�scara via msExecAuto.

@author  Felipe Raposo
@version
@since   11/04/2018
/*/
Static Function CTB130Auto(nAutoOper, aCabAuto, aDetAuto)

Local cCodMasc   := aCabAuto[1]
Local cDescMasc  := aCabAuto[2]
Local nTamSeg    := TamSX3("CTM_SEGMEN")[1]
Local aLinha     := {}
Local nLin

Private aHeader[0], aCols[0], n := 0, nUsado := 0
Private nPosDig     := 0
Private nPosDesc    := 0
Private nPosSep     := 0
Private nMascEnt    := aCabAuto[3]

// Monta o aHeader.
c130aHead()

// Monta uma linha em branco de aCols.
c130aCols(3, cCodMasc)  // aCols de inclus�o.
aLinha := aClone(aCols[1])

// Se for altera��o ou exclus�o de m�scara, monta a aCols a ser gravada.
If nAutoOper <> 3
	// Carrega todas as linhas na aCols...
	c130aCols(nAutoOper, cCodMasc)
	aEval(aCols, {|x, nLin| aTail(aCols[nLin]) := .T.})  // ... e marca todas as linhas como apagadas.
Endif

// Monta aCols com os dados passados por par�metro.
// Se for exclus�o, n�o precisa montar.
If nAutoOper = 3 .or. nAutoOper = 4
	For nLin := 1 to len(aDetAuto)
		// Adiciona linha na aCols.
		If nLin > len(aCols)
			aAdd(aCols, aClone(aLinha))
		Endif
		aTail(aCols[nLin]) := .F.  // Marca a linha como n�o apagada.

		// Atualiza dados da linha.
		aCols[nLin, 1]        := StrZero(nLin, nTamSeg)
		aCols[nLin, nPosDig]  := aDetAuto[nLin, 1]
		aCols[nLin, nPosDesc] := aDetAuto[nLin, 2]
		aCols[nLin, nPosSep]  := aDetAuto[nLin, 3]
	Next nLin
Endif

// Valida e grava.
If Ct130Tudok()
	c130Grava(cCodMasc, nAutoOper, cDescMasc)
Else
	Help(,, 'HELP',, "Erro na grava��o da m�scada", 1, 0)
Endif

Return


/*/{Protheus.doc} IntegDef
Fun��o para integra��o via Mensagem �nica Totvs.

@author  Felipe Raposo
@version P12
@since   11/04/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return CTBI130A(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
