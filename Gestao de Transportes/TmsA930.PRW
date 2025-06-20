#INCLUDE "TMSA930.ch"
#include 'Protheus.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA930  � Autor � Richard Anderson      � Data �01.07.2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Libera faturamento de AWB�s bloqueadas                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA930                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA930()

Local aCores      := {}
Local cPerg       := 'TMA930'
Private cInd      := ''
Private cCadastro := STR0001 //'Libera faturamento de AWB�s'
Private aRotina   := MenuDef()
							  
Aadd(aCores,{"DTV_STAFIN == '1'","BR_VERDE"		})		//-- Faturamento liberado
Aadd(aCores,{"DTV_STAFIN == '2'","BR_VERMELHO"	})		//-- Faturamento bloqueado

DbSelectArea('DTV')
DbSetOrder(1)
If !TMSA930Fil(cPerg) //Chama os filtros e o pergunte
	Return Nil
EndIf

mBrowse( 6,1,22,75,'DTV',,,,,,aCores)

// Limpar filtros
DTV->(DbClearFilter())

Return NIL

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �TMSA930Fil� Autor � Richard Anderson      � Data � 01/07/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Chama o pergunte e faz o filtro                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA930                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TMSA930Fil(cPerg)

Local cFiltro

If !Empty(cInd)
	// Limpar filtros
	DTV->(DbClearFilter())
EndIf
		
DbSelectArea('DTV')
DbSetOrder(1)
If !Pergunte(cPerg,.T.)
	Return .F.
EndIf

cFiltro := "       DTV_CODCIA >= '" + MV_PAR01 + "'"				
cFiltro += " .And. DTV_LOJCIA >= '" + MV_PAR02 + "'"		
cFiltro += " .And. DTV_CODCIA <= '" + MV_PAR03 + "'"				
cFiltro += " .And. DTV_LOJCIA <= '" + MV_PAR04 + "'"		
cFiltro += " .And. Dtos(DTV_DATEMI) >= '" + Dtos(MV_PAR05) + "'"				
cFiltro += " .And. Dtos(DTV_DATEMI) <= '" + Dtos(MV_PAR06) + "'"		
cFiltro += " .And. DTV_FILORI >= '" + MV_PAR07 + "'"
cFiltro += " .And. DTV_FILORI <= '" + MV_PAR08 + "'"
cFiltro += " .And. DTV_STAFIN == '2'"

MsgRun(STR0005,,{|| DTV->( DbSetFilter( { || &cFiltro },  cFiltro ) ) })  //  //"Aguarde, selecionando registros..."
cInd := 1

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �TMSA930Lib� Autor � Richard Anderson      � Data � 01/07/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Libera faturamento da AWB                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA930                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TMSA930Lib()

If DTV->DTV_STAFIN != '2' //-- Faturamento bloqueado
	MsgAlert(STR0006+DTV->DTV_NUMAWB+STR0007,STR0008) //'Faturamento da AWB '###' n�o est� bloqueado!'###'ATEN��O'
Else	
	If MsgNoYes(STR0009+DTV->DTV_NUMAWB+"?") //'Confirma libera��o da AWB '
		RecLock('DTV',.F.)
		DTV->DTV_STAFIN := '1' //-- Faturamento em aberto
		DTV->DTV_DTLFAT := dDataBase
		DTV->DTV_USLFAT := Substr(cUsuario,7,15)
		MsUnLock()
	EndIf
EndIf	

Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Jose Luiz Pinheiro Jr � Data �27/05/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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

Private aRotina   := { 	{ STR0002 ,"TmsXPesqui", 0, 1,0,.F. },;	 //'Pesquisar'
								{ STR0003 ,'TMSA320Mnt', 0, 2,0,NIL },; //'Visualizar'
								{ STR0004 ,'TMSA930Lib', 0, 4,0,NIL } } //'Liberar'

If ExistBlock("TM930MNU")
	ExecBlock("TM930MNU",.F.,.F.)
EndIf       

Return(aRotina)
