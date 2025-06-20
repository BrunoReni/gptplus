#INCLUDE "OMSA220.ch"
#INCLUDE "PROTHEUS.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � OMSA220  � Rev.  � Henry Fila            � Data � 19.07.2001���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Simulacao de visualizacao de entrega            ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void OMSA220(void)                                          ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
���              �        �      �                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function OMSA220()
//������������������������������������������������������������������������Ŀ
//� Inicializa vari�veis utilizadas na cria��o de Arquivos de Trabalho     �
//��������������������������������������������������������������������������
Local aArea     := GetArea()
Local aCores    := {}
Local aIndDAK   := {}
Local cCondicao := ""

Private bFiltraBrw  := {|| Nil}
Private cCadastro   := OemtoAnsi(STR0001) //"Simulacao de agenda de entrega"
Private aRotina     := MenuDef()

If (AMIIn(5,39)) // SigaFat - SigaOms
	Aadd(aCores,{"DAK_FEZNF == '2' .And. DAK_ACECAR == '2'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","ENABLE"})		//Totalmente em aberto
	Aadd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '2'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","BR_LARANJA"})	//Somente faturada e nao acertada
	Aadd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '1'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","DISABLE"})		//Faturada e acertada
	Aadd(aCores,{"                                              DAK_BLQCAR == '1'                         .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","BR_PRETO"})	//Bloqueada
	//������������������������������������������������������������������������Ŀ
	//�Inclui Filial de / ate nos parametros OM341B                            �
	//��������������������������������������������������������������������������
	If	Pergunte("OMS20A",.T.)
		cCondicao += "DAK_COD >= '"+mv_par01+"' .And. DAK_COD <= '"+mv_par02+"' .And. "
		cCondicao += "Dtos(DAK_DATA) >= '"+Dtos(mv_par03)+"' .And. Dtos(DAK_DATA) <= '"+Dtos(mv_par04)+"' "
		If	mv_par05 == 1
			cCondicao += " .And. DAK_FEZNF == '2' .And. DAK_ACECAR == '2' "
		ElseIf	mv_par05 == 2
			cCondicao += " .And. DAK_FEZNF == '1' .And. DAK_ACECAR == '2' "
		ElseIf	mv_par05 == 3
			cCondicao += " .And. DAK_FEZNF == '1' .And. DAK_ACECAR == '1' "
		EndIf
		//������������������������������������������������������������������������Ŀ
		//�Realiza a Filtragem                                                     �
		//��������������������������������������������������������������������������
		bFiltraBrw := {|| FilBrowse("DAK",@aIndDAK,@cCondicao) }
		Eval(bFiltraBrw)
		Mbrowse(6,1,22,75,"DAK",,,,,,aCores)
	EndIf
	//����������������������������������������������������������������Ŀ
	//�Restaura a integridade da rotina                                �
	//������������������������������������������������������������������
	dbSelectArea("DAK")
	RetIndex("DAK")
	dbClearFilter()
	aEval(aIndDAK,{|x| Ferase(x[1]+OrdBagExt())})
	RestArea(aArea)
EndIf
Return(.T.)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � OMS220Sim� Rev.  � Henry Fila            � Data � 19.07.2001���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Simulacao de visualizacao de entrega            ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void OMSA220(void)                                          ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
���              �        �      �                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Oms220Sim(cAlias,nReg,nOpc)
Local nOpca    := 0
Local cHrStart := DAK->DAK_HRSTART
Local dDataIni := DAK->DAK_DATA
Local cBitmap  := "PROJETOAP"

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0004) From 0,0 To 120,280 OF oMainWnd PIXEL //"Dados para a simulacao"
	@   0,  0 BITMAP oBmp RESNAME cBitMap oF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL
	@ 005,055 Say OemtoAnsi(STR0005) Of oDlg PIXEL SIZE 45,10 //"Hora" 
	@ 005,088 MSGET cHrStart Of oDlg Valid OmsVldHr(cHrStart) PIXEL SIZE 34,10 Picture "99:99"
	@ 020,055 Say OemtoAnsi(STR0006) Of oDlg PIXEL SIZE 45,10 //"Data" 
	@ 020,088 MSGET dDataIni  Of oDlg PIXEL SIZE 41,10 
	DEFINE SBUTTON FROM 045, 067 TYPE 1 ENABLE OF oDlg ACTION( nOpcA := 1,oDlg:End())
	DEFINE SBUTTON FROM 045, 097 TYPE 2 ENABLE OF oDlg ACTION( oDlg:End())
ACTIVATE DIALOG oDlg Centered

If nOpca == 1
	OmsVisCg(cAlias,nReg,nOpc,dDataIni,cHrStart)
EndIf
Return
/*/
���������������������������������������������������������������������������
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
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
Private aRotina := {	{ OemtoAnsi(STR0002) ,'PesqBrw'	,0,1,0,.F.},; //"Pesquisar"
						{ OemtoAnsi(STR0003) ,'Oms220Sim',0,2,0,NIL}} //"Simulacao"
If ExistBlock("OM220MNU")
	ExecBlock("OM220MNU",.F.,.F.)
EndIf
Return(aRotina)