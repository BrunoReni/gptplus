#INCLUDE "FATA210.ch"
#include "Protheus.ch"


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � FATA210  � Autor � Henry Fila            � Data � 03.02.02   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Liberacao de Regras ou Verbas de Vendas                      ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Materiais - OMS/FATURAMENTO                                  ���
���������������������������������������������������������������������������Ĵ��
���                                                                         ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function FATA210()

Local oDlg1 		:= ""                     	// Objeto da janela
Local aIndSC5   	:= {}						// Arquivo e n�mero de �ndice utilizado
Local aArea     	:= GetArea()				// Salva a �rea atual
Local cCondicao 	:= ""						// Condi��o para a filtragem
Local lFT210BRW		:= ExistBlock("FT210BRW")	// Verifica se existe o ponto de entrada lMT410BRW
Local aCores      := {{ "C5_BLQ == '1'",'BR_AZUL'},;	
			              { "C5_BLQ == '2'",'BR_LARANJA'}}
Local aCoresNew := {}
Local lFT210COR  := ExistBlock("FT210COR")

Private cCadastro	:= STR0001			 		// "Liberacao de pedidos bloqueados por Regra ou Verba"
Private aRotina		:= MenuDef()				// Rotinas que podem ser executadas na mBrowser

cCondicao := "Empty(C5_NOTA) .And. (C5_BLQ == '1' .Or. C5_BLQ == '2')"
//������������������������������������������������������������������������Ŀ
//�Realiza a Filtragem                                                     �
//��������������������������������������������������������������������������
bFiltraBrw := {|| FilBrowse("SC5",@aIndSC5,@cCondicao) }
Eval(bFiltraBrw)

//���������������������������������������Ŀ
//�Permite que o usu�rio filtre o browser.�
//�����������������������������������������
If lFT210BRW
	ExecBlock("FT210BRW",.F.,.F.)
EndIf
//��������������������������������������������������������������Ŀ
//� Ponto de Entrada para alterar cores do Browse do Cadastro    �
//����������������������������������������������������������������
If lFT210COR
	aCoresNew := ExecBlock("FT210COR",.F.,.F.,aCores)
	If ValType( aCoresNew ) == "A"
		aCores := aClone(aCoresNew)
	EndIf
Endif

DbSelectArea("SC5")

mBrowse(06,01,22,75,"SC5",,,,,,aCores)

//����������������������������������������������������������������Ŀ
//�Restaura a integridade da rotina                                �
//������������������������������������������������������������������
DbSelectArea("SC5")
RetIndex("SC5")
DbClearFilter()
aEval(aIndSC5,{|x| FErase(x[1]+OrdBagExt())})
RestArea(aArea)

Return Nil


/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft210Legen�Autor  � Henry Fila            � Data �13.09.2000 ���
��������������������������������������������������������������������������Ĵ��
���          �Demonstra a legenda das cores da mbrowse                     ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina monta uma dialog com a descricao das cores da    ���
���          �Mbrowse.                                                     ���
���          �                                                             ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Ft210Legend()
Local aCoresNew := {}
Local aCores    := {{ "BR_AZUL"	   ,  STR0007 },;		//"Pedido Bloqueado por Regra"
							{ "BR_LARANJA"	,  STR0008 } }			//"Pedido bloqueado por Verba"  
//���������������������������������������������������Ŀ
//� Ponto de Entrada para alterar cores da legenda    �
//�����������������������������������������������������
If ExistBlock("FT210LEG")
	aCoresNew := ExecBlock("FT210LEG",.F.,.F.,aCores)
	If ValType( aCoresNew ) == "A"
		aCores := aClone(aCoresNew)
	EndIf
Endif

BrwLegenda(cCadastro,STR0006,aCores) //"Pedidos Bloqueados"
				
Return(.T.)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft210Liber�Autor  � Eduardo Riera         � Data �13.09.2000 ���
��������������������������������������������������������������������������Ĵ��
���          �Libera o pedido de vendas                                    ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina chama a liberacao do pedido de vendas            ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function Ft210Liber()

Local aSays    := {}             
Local aButtons := {}
Local nOpca    := 0
Local oBrw 	   := Nil

If !ctbValiDt( Nil, dDataBase, .T., Nil, Nil, { "FAT002" }, Nil )
	Return Nil
EndIf

AADD(aSays, STR0009 ) //"Esta rotina realizara a liberacao do pedido de vendas, caso tenha"
AADD(aSays, STR0010 ) //"sido bloqueado por regra de negocio ou verba de vendas"

cCadastro := STR0011 //"Liberacao de Regras e Verbas"

AADD(aButtons, { 1,.T.,{|o| nOpca:= 1, o:oWnd:End() } } )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	If ExistBlock("FT210OPC")
		nOpcA := ExecBlock("FT210OPC",.F.,.F.,{nOpcA})
	EndIf
EndIf

If nOpca == 1
	Ft210Proc()
	If FWSizeFilial() <= 2	//Se n�o utiliza Gest�o de Empresas
		oBrw := GetObjBrow()
		oBrw:Goto(oBrw:nAt-1)	//Posiciona na linha anterior para atualizar o browse
	EndIf
Endif

Return 

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft210Liber�Autor  � Eduardo Riera         � Data �13.09.2000 ���
��������������������������������������������������������������������������Ĵ��
���          �Libera o pedido de vendas                                    ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina chama a liberacao do pedido de vendas            ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Static Function Ft210Proc()

Local aArea     := GetArea()
Local aAreaSC6  := SC6->(GetArea())
Local bWhile    := { || .T. }

Local cQuery    := ""
Local cAliasSC6 := "SC6"
Local lQuery    := .T.
Local lLibBlq   := .T.
If AllTrim(SuperGetMv("MV_ESTADO")) == "AL" //Legisla��o somente para alagoas
	lLibBlq := !BlPVLFat(SC5->C5_CLIENTE,SC5->C5_LOJACLI)
EndIf
If lLibBlq
//������������������������������������������������������������������������Ŀ
//�Chama evento de liberacao de regras com o SC5 posicionado               �
//��������������������������������������������������������������������������
	Begin Transaction
		MaAvalSC5("SC5",9)
		If Existblock("FT210LIB")
			ExecBlock("FT210LIB",.f.,.f.)
		EndIf
	End Transaction
EndIf

RestArea(aAreaSC6)
RestArea(aArea)
                                                
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
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
     
Private aRotina 	:= {	{ STR0002,"AxPesqui"   ,0,1,0,.F.	},;	// "Pesquisar" 
		  			 		{ STR0003,"A410Visual" ,0,2,0,NIL	},;	// "Visualizar"
							{ STR0004,"Ft210Liber" ,0,4,0,NIL	},;	// "Liberar"
							{ STR0005,"Ft210Legend",0,2,0,.F.	}}	// "Legenda"
											
Aadd (	aRotina, {STR0012,"BlqRegBrw", 0 , 0 , 0 , .F.})		// "Blq. Regra"				

If ExistBlock("FT210MNU")
	ExecBlock("FT210MNU",.F.,.F.)
EndIf

Return(aRotina)
