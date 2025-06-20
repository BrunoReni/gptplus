#INCLUDE "OMSA215.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE OMSA21501 "OMSA21501"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � OMSA215  � Rev.  � Henry Fila            � Data � 19.07.2001���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Geracao de carga                                ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void OMSA215(void)                                          ���
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
Function OMSA215()
//������������������������������������������������������������������������Ŀ
//� Inicializa vari�veis utilizadas na cria��o de Arquivos de Trabalho     �
//��������������������������������������������������������������������������
Local aArea     := GetArea()
Local aCores    := {}
Local aIndDAK   := {}
Local cCondicao := ""

Private bFiltraBrw := {|| Nil}
Private cCadastro  := OemtoAnsi(STR0001) //"Montagem de carga para terceiros"

Private aRotina := MenuDef()

If (AMIIn(5,39)) // SigaFat - SigaOms
	Aadd(aCores,{"DAK_FEZNF == '2' .And. DAK_ACECAR == '2'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","ENABLE"})		//Totalmente em aberto
	Aadd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '2'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","BR_LARANJA"})	//Somente faturada e nao acertada
	Aadd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '1'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","DISABLE"})		//Faturada e acertada
	Aadd(aCores,{"                                              DAK_BLQCAR == '1'                         .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","BR_PRETO"})	//Bloqueada

	//������������������������������������������������������������������������Ŀ
	//�Inclui Filial de / ate nos parametros OM341B                            �
	//��������������������������������������������������������������������������

	//-- mv_par01 - Carga de ?
	//-- mv_par02 - Carga ate ?
	//-- mv_par03 - Data geracao de ?
	//-- mv_par04 - Data geracao ate ?
	//-- mv_par05 - Filtra por ? Em aberto / Faturadas / Encerradas / Todas
	If Pergunte("OMS20A",.T.)

		cCondicao += "DAK_COD >= '"+mv_par01+"' .And. DAK_COD <= '"+mv_par02+"' .And. "
		cCondicao += "Dtos(DAK_DATA) >= '"+Dtos(mv_par03)+"' .And. Dtos(DAK_DATA) <= '"+Dtos(mv_par04)+"' "
		If mv_par05 == 1
			cCondicao += " .And. DAK_FEZNF=='2' .And. DAK_ACECAR == '2'"
		ElseIf mv_par05 == 2
			cCondicao += " .And. DAK_FEZNF =='1' .And. DAK_ACECAR == '2'"
		ElseIf mv_par05 == 3
			cCondicao += " .And. DAK_FEZNF =='1' .And. DAK_ACECAR == '1' "
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
���Fun��o    �Os215Load � Rev.  � Henry Fila            � Data � 19.07.2001���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Geracao de carga                                ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void Os215Load(void)                                        ���
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
Function Os215Load()
Local aSays    := {}
Local aButtons := {}
Local nOpca    := 0
Local oProcess

	Aadd(aSays,OemToAnsi( STR0004 ) ) //"Esta rotina ira gerar as cargas para terceiros dos pedidos que utilizam transportadora"		 
	Aadd(aSays,OemToAnsi( STR0005 ) ) //"e enderecamentos informados."

	Aadd(aButtons, { 5,.T.,{|o| Pergunte("OMS215",.T.) } } )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	Aadd(aButtons, { 1,.T.,{|o| nOpca := 1,o:oWnd:End() } } )
	FormBatch( cCadastro, aSays, aButtons )

	If nOpca == 1
		oProcess := MsNewProcess():New({|lEnd| Oms215Proc(oProcess)},"","",.F.)
		oProcess:Activate()
	Endif

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Os215Proc � Rev.  � Henry Fila            � Data � 19.07.2001���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Geracao de carga                                ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void Os215Proc(void)                                        ���
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
Function Oms215Proc(oProcess)
Local aGera      := {}
Local cQuery     := ""
Local cCondicao  := ""
Local cAliasSC9  := "SC9"
Local cTransp    := ""
Local cEstFis    := ""
Local cLocal     := ""
Local cEndPad    := ""
Local cRetPE     := ""
Local nTipoOper  := OsVlEntCom()
Local nSequencia := 0
Local lGeraCar   := .T. 
Local lOM215PCA  := ExistBlock("OM215PCA")

	//-- mv_par01 - Pedido de  ?
	//-- mv_par02 - Pedido ate ?
	//-- mv_par03 - Cliente de  ?
	//-- mv_par04 - Cliente ate ?
	//-- mv_par05 - Considera Restricao ? sim/nao
	//-- mv_par06 - Aglutina por ? pedido/itens
	//-- mv_par07 - End. Destino de ?
	//-- mv_par08 - End. Destino ate ?
	//-- mv_par09 - Filial de ?
	//-- mv_par10 - Filial ate ?
	//-- mv_par11 - Data Liberacao de ?
	//-- mv_par12 - Data Liberacao ate ?
	//-- mv_par13 - Loja de ?
	//-- mv_par14 - Loja ate ?
	//-- mv_par15 - Data Entrega de ?
	//-- mv_par16 - Data Entrega ate ?
	//-- mv_par17 - Transportadora de ?
	//-- mv_par18 - Transportadora ate ?
	Pergunte("OMS215",.F.)

	cAliasSC9 := "TRBSC9"

	cQuery := "SELECT A4_COD,A4_ENDPAD,A4_ESTFIS,A4_LOCAL,C9_CLIENTE,C9_FILIAL,C9_LOJA,C9_PEDIDO,C9_ITEM,SC9.R_E_C_N_O_ RECSC9 FROM "
	cQuery += RetSqlName("SC9")+" SC9, "
	cQuery += RetSqlName("SC5")+" SC5, "
	cQuery += RetSqlName('SC6')+" SC6, "
	cQuery += RetSqlName("SA4")+" SA4 "
	cQuery += " WHERE SC9.D_E_L_E_T_ = ' '"
	cQuery += " AND C9_BLCRED  ='"+Space(Len(SC9->C9_BLCRED))+"' "
	cQuery += " AND C9_BLEST   ='"+Space(Len(SC9->C9_BLEST)) +"' "
	cQuery += " AND C9_CARGA   ='"+Space(Len(SC9->C9_CARGA)) +"' "
	cQuery += " AND C9_SEQCAR  ='"+Space(Len(SC9->C9_SEQCAR))+"' "
	cQuery += " AND (C9_TPCARGA='1' OR C9_TPCARGA='3')"
	cQuery += " AND C9_PEDIDO  >= '"+mv_par01+"' AND C9_PEDIDO  <='"+mv_par02+"' "
	cQuery += " AND C9_CLIENTE >= '"+mv_par03+"' AND C9_CLIENTE <='"+mv_par04+"' "
	cQuery += " AND C9_LOJA    >= '"+mv_par13+"' AND C9_LOJA    <='"+mv_par14+"' "
	cQuery += " AND C9_ENDPAD  >= '"+mv_par07+"' AND C9_ENDPAD  <='"+mv_par08+"' "
	cQuery += " AND C9_DATALIB >= '"+Dtos(mv_par11)+"'"
	cQuery += " AND C9_DATALIB <= '"+Dtos(mv_par12)+"'"

	If nTipoOper == 1
		cQuery += "AND C9_FILIAL ='"+xFilial("SC9")+"' "
	Else
		cQuery += "AND C9_FILIAL >= '"+mv_par09+"' "
		cQuery += "AND C9_FILIAL <= '"+mv_par10+"' "
	EndIf

	cQuery += " AND SC5.C5_FILIAL = SC9.C9_FILIAL "
	cQuery += " AND SC5.C5_NUM    = SC9.C9_PEDIDO "
	cQuery += " AND SC5.C5_TRANSP <> '"+Space(Len(SC5->C5_TRANSP))+"' "
	cQuery += " AND SC5.C5_TRANSP >= '" + mv_par17 + "' "
	cQuery += " AND SC5.C5_TRANSP <= '" + mv_par18 + "' "
	cQuery += " AND SC5.D_E_L_E_T_ = ' ' "

	cQuery += " AND SC6.C6_FILIAL = SC9.C9_FILIAL "
	cQuery += " AND SC6.C6_NUM    = SC9.C9_PEDIDO "
	cQuery += " AND SC6.C6_ITEM   = SC9.C9_ITEM "
	cQuery += " AND SC6.C6_PRODUTO = SC9.C9_PRODUTO "
	cQuery += " AND SC6.C6_ENTREG>='"+Dtos(mv_par15)+"'"
	cQuery += " AND SC6.C6_ENTREG<='"+Dtos(mv_par16)+"'"
	cQuery += " AND SC6.D_E_L_E_T_ = ' ' "

	cQuery += " AND SA4.A4_FILIAL = '"+xFilial("SA4")+"' "
	cQuery += " AND SA4.A4_COD    = SC5.C5_TRANSP "
	cQuery += " AND SA4.A4_ENDPAD <> '"+Space(Len(SA4->A4_ENDPAD))+"' "
	cQuery += " AND SA4.A4_ESTFIS <> '"+Space(Len(SA4->A4_ESTFIS))+"' "
	cQuery += " AND SA4.A4_LOCAL  <> '"+Space(Len(SA4->A4_LOCAL)) +"' "
	cQuery += " AND SA4.D_E_L_E_T_ = ' ' "

	If ExistBlock("OM215QRY")
		cRetPE := ExecBlock("OM215QRY",.F.,.F.,{ cQuery , 1 })
		cQuery   := If(ValType(cRetPE)=="C", cRetPE, cQuery)
	EndIf

	cQuery += " ORDER BY C5_TRANSP,A4_ESTFIS,A4_ENDPAD,A4_LOCAL,C9_CLIENTE,C9_LOJA,C9_PEDIDO,C9_ITEM"

	cQuery := ChangeQuery(cQuery)
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSC9",.F.,.T.)

	If !(cAliasSC9)->(Eof())
		While !(cAliasSC9)->(Eof())

			cTransp := (cAliasSC9)->A4_COD
			cEstFis := (cAliasSC9)->A4_ESTFIS
			cLocal  := (cAliasSC9)->A4_LOCAL
			cEndPad := (cAliasSC9)->A4_ENDPAD

			nSequencia := 0

			While (cAliasSC9)->(!Eof()) .And. cTransp ==  (cAliasSC9)->A4_COD .And.;
												cEstFis == (cAliasSC9)->A4_ESTFIS .And.;
												cLocal  == (cAliasSC9)->A4_LOCAL .And. ;
												cEndPad == (cAliasSC9)->A4_ENDPAD
				nSequencia++

				Aadd(aGera, {StrZero(nSequencia,6),;
							"",;
							"",;
							"",;
							(cAliasSC9)->C9_PEDIDO,;
							(cAliasSC9)->C9_ITEM,;
							(cAliasSC9)->C9_CLIENTE,;
							(cAliasSC9)->C9_LOJA,;
							(cAliasSC9)->RECSC9,;
							(cAliasSC9)->A4_ENDPAD,;
							(cAliasSC9)->C9_FILIAL,;
							OsFilial("SA1",(cAliasSC9)->C9_FILIAL),;
							"",;
							"",;
							dDataBase,;
							dDataBase,Nil,Nil} )

				(cAliasSC9)->(dbSkip())

			EndDo

			If lOM215PCA
				lGeraCar := ExecBlock("OM215PCA",.F.,.F.,{aGera})
			EndIf

			If lGeraCar
				Processa({ || Oms200Carga(@aGera,,, "",,,,,,,,,,,,,cTransp,,,,,,.T.) })
				ConfirmSX8()
			EndIf 
			aGera:= {}
		EndDo
	Else
		WmsHelp(STR0007,STR0008,OMSA21501) // "N�o foi poss�vel encontrar pedidos para a montagem da carga." // "Verifique os par�metros configurados e se foi informada uma transportadora (com as caracter�sticas necess�rias) para os pedidos que utilizam carga."
	EndIf

	(cAliasSC9)->(dbCloseArea())

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
Private aRotina := {	{ OemtoAnsi(STR0002) ,'PesqBrw'   , 0, 1 ,0,.F.},;	//"Pesquisar"
						{ OemtoAnsi(STR0006) ,'OmsVisCg'  , 0, 2 ,0,NIL},;	//"Gerar"
						{ OemtoAnsi(STR0003) ,'Os215Load' , 0, 3 ,0,NIL} }	//"Gerar"

If ExistBlock("OM215MNU")
	ExecBlock("OM215MNU",.F.,.F.)
EndIf

Return(aRotina)
