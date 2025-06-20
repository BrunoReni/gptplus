#INCLUDE "LOJA854.ch"
#INCLUDE 'PROTHEUS.CH'

Static bFiltraSC6										 //Variavel usada para montar/manter o filtro
/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Loja854	 � Autor � Vendas Cliente       � Data � 04/02/11 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Rotina de Encerramento do Pedido de Venda da Lista de 	  ���
���			 � presentes												  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � Automacao Comercial										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA854()

Local cQuery	:= ""								//Variavel para filtrar na utilizacao de TOP
Local cFilMarkb := ""								//Variavel para filtrar na utilizacao de DBF
Local cPerg		:= "LJA854"                         //nome do pergunte
Local aIndexSC6	:= {}								//array com os indices da tabela SC6

//Variavel que determina se esta atina a Lista de Presentes
Local lUsaLstPre:= SuperGetMV("MV_LJLSPRE",,.F.) .And. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)

Private cCadastro := OemToAnsi(STR0001)					 //"Encerramento de Pedido de Venda de Lista de Presentes"
Private aRotina := {{ STR0002 	,"Lj854Pesq", 0 , 0},;	 //"Pesquisa"
					{ STR0003	,"Lj854Enc"	, 0 , 0}}	 //"Encerra PV"

If lUsaLstPre
	//����������������������������������������������������������Ŀ
	//� Define parametros abertos                                �
	//�                                                          �
	//�MV_PAR01: Pedido de  ?                                    �
	//�MV_PAR02: Pedido Ate ?                                    �	
	//�MV_PAR03: Lista de   ?                                    �
	//�MV_PAR04: Lista Ate  ?                                    �		
	//�MV_PAR05: Produto de ?                                    �
	//�MV_PAR06: Produto Ate?                                    �		
	//�MV_PAR07: Dt Entrega de ?                                 �
	//�MV_PAR08: Dt Entrega Ate?                                 �		
	//�MV_PAR09: Dt Emissao de ?                                 �
	//�MV_PAR10: Dt Emissao Ate?                                 �			
	//������������������������������������������������������������
	
	If ( Pergunte(cPerg,.T.) )
		//������������������������������������������������������������������������Ŀ
		//�Realiza a Filtragem                                                     �
		//��������������������������������������������������������������������������
		cQuery	:= "C6_FILIAL = '" + xFilial("SC6") + "' AND "
		cQuery	+= "C6_NUM >= '" + MV_PAR01 + "' AND "
		cQuery	+= "C6_NUM <= '" + MV_PAR02 + "' AND "
		cQuery 	+= "C6_CODLPRE <> '" + Space(Len(SC6->C6_CODLPRE)) + "' AND "
		cQuery	+= "C6_CODLPRE >= '" + MV_PAR03 + "' AND "
		cQuery	+= "C6_CODLPRE <= '" + MV_PAR04 + "' AND "	
		cQuery	+= "C6_PRODUTO >= '" + MV_PAR05 + "' AND "
		cQuery	+= "C6_PRODUTO <= '" + MV_PAR06 + "' AND "
		cQuery	+= "C6_ENTREG BETWEEN '" + Dtos(MV_PAR07) + "' AND '" + Dtos(MV_PAR08) + "' AND "
		cQuery	+= "C6_BLQ <> 'R ' AND C6_BLQ <> 'S ' AND "
		cQuery	+= "(C6_QTDVEN - C6_QTDENT) > 0 AND "
		cQuery 	+= "C6_RESERVA = '" + Space( TamSX3("C6_RESERVA")[1] ) + "'"

		cFilMarkb	:= "C6_FILIAL = '" + xFilial("SC6") + "' .AND. "
		cFilMarkb	+= "C6_NUM >= '" + MV_PAR01 + "' .AND. "
		cFilMarkb	+= "C6_NUM <= '" + MV_PAR02 + "' .AND. "
		cFilMarkb 	+= "C6_CODLPRE <> '" + Space(Len(SC6->C6_CODLPRE)) + "' .AND. "
		cFilMarkb	+= "C6_CODLPRE >= '" + MV_PAR03 + "' .AND. "
		cFilMarkb	+= "C6_CODLPRE <= '" + MV_PAR04 + "' .AND. "
		cFilMarkb	+= "C6_PRODUTO >= '" + MV_PAR05 + "' .AND. "
		cFilMarkb	+= "C6_PRODUTO <= '" + MV_PAR06 + "' .AND. "
		cFilMarkb	+= "Dtos(C6_ENTREG)  >= '"+Dtos(MV_PAR07)+"' .AND. "
		cFilMarkb	+= "Dtos(C6_ENTREG)  <= '"+Dtos(MV_PAR08)+"' .AND. "
		cFilMarkb	+= "C6_BLQ <> 'R ' .AND. C6_BLQ <> 'S ' .AND. "
		cFilMarkb	+= "(C6_QTDVEN - C6_QTDENT) > 0 .AND. "
		cFilMarkb 	+= "C6_RESERVA = '" + Space( TamSX3("C6_RESERVA")[1] ) + "'"
	
		bFiltraSC6 := {|x| If(x == Nil,FilBrowse("SC6",@aIndexSC6,@cFilMarkb),IIF( x == 1,cFilMarkb,cQuery) ) }
		Eval(bFiltraSC6)
		
		//����������������������������������������������������������Ŀ
		//� Endereca a funcao de BROWSE                              �
		//������������������������������������������������������������
		MarkBrow("SC6","C6_OK",,,,GetMark())
		
		//��������������������������������������������������������������Ŀ
		//� Retorna indices do SC6                                       �
		//����������������������������������������������������������������
		DbSelectArea("SC6")
		RetIndex("SC6")
		DbClearFilter()
		aEval(aIndexSC6,{|x| Ferase(x[1]+OrdBagExt())})
	EndIf
Else
	MsgInfo(STR0004) //"Processo da Lista de Presentes nao aplicada/ativa"
EndIf

Return




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj854Enc  �Autor  �Vendas Cliente      � Data �  02/17/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa os itens selecionados para elimininacao do residuo ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA846													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Lj854Enc()

Local nOpcA 	:= 0						//Variavel para tratamento da opcao selecionada pelo usuario para confirmar o encerramento

FormBatch(OemToAnsi(STR0005),; //"Encerramento do Pedido de Venda da Lista de Presentes"
	{OemToAnsi(STR0006),; //"  Este programa  tem  como  objetivo  encerrar os pedidos de venda vinculados"
	 OemToAnsi(STR0007)},; //"  a uma lista de presentes, baseado nos parametros previamente preenchidos   "
	{	{5,.F.,{|o| o:oWnd:End()}       },;
	{1,.T.,{|o| nOpcA:=1,o:oWnd:End()}  },;
	{2,.T.,{|o| o:oWnd:End() }}         })

If nOpcA == 1 
	Processa({|| Lj854Proc() },STR0008) //"Encerramento do Pedido de Vneda da Lista de Presentes"
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj854Proc �Autor  �Vendas Cliente      � Data �  02/17/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa os itens selecionados para elimininacao do residuo ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA846													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Lj854Proc()

Local cQuery	:= ""						//Variavel para montagem da Query
Local cAlias	:= GetNextAlias()			//Busca o proximo alias
Local aArea		:= GetArea()				//Guarda a area atual
Local aAreaME4	:= ME4->( GetArea()	)		//Guarda a area da tabela ME4
Local cWhere	:= Eval(bFiltraSC6,2)		//validacoes da clausula Where
Local aRecno	:= {}						//Array contendo Recno de todos os registros da tabela de conta corrente
Local nSeqRec	:= 0						//variavel de contagem
Local nPosRec	:= 0						//Posicao no array aRecno

cQuery := "SELECT SC6.R_E_C_N_O_ REGSC6,SC5.R_E_C_N_O_ REGSC5 "	 
cQuery += "  FROM " + RetSqlName("SC6")+" SC6 "
cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND SC5.C5_NUM = SC6.C6_NUM AND SC5.D_E_L_E_T_=' '"
cQuery += " WHERE " + cWhere + " AND "

If ( ThisInv() )
	cQuery += "SC6.C6_OK <> '" + ThisMark() + "' AND "
Else
	cQuery += "SC6.C6_OK = '" + ThisMark() + "' AND "
EndIf

cQuery += "SC6.D_E_L_E_T_ = ' ' AND "
cQuery += "SC5.C5_EMISSAO >= '" + DTOS(MV_PAR09) + "' AND "
cQuery += "SC5.C5_EMISSAO <= '" + DTOS(MV_PAR10) + "'"
cQuery += "ORDER BY C6_FILIAL,C6_NUM,C6_ITEM"	 

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

ProcRegua( SC6->( LastRec() ) )

DbSelectArea("ME4")
DbSetOrder(4)	//ME4_FILIAL+ME4_CODIGO+ME4_PEDIDO+ME4_ITPED+ME4_ITLST	 

DbSelectArea("SC6")

Begin Transaction 
	While !(cAlias)->( Eof() )
		SC6->( DbGoTo( (cAlias)->REGSC6 ) )
		
		IncProc(OemToAnsi(STR0009) + ": " + SC6->C6_NUM + "/" + SC6->C6_ITEM) //"Encerrando Pedido/Item"
		
		If ME4->( DbSeek( xFilial("ME4") + SC6->C6_CODLPRE + SC6->C6_NUM + SC6->C6_ITEM + SC6->C6_ITLPRE) )		
			If (nPosRec := aScan(aRecno,{|x| Alltrim(x[1]) == SC6->C6_CODLPRE })) == 0
				aAdd(aRecno,{	SC6->C6_CODLPRE,;			//Codigo da Lista de Presentes
								SC6->C6_VALOR,;				//Valor total do Credito a ser gerado 
								{{.T.,ME4->( Recno() )}},;	//Recno da tabela de Conta Corrente
							})
			Else
				//Soma o valor do item para gerar o Credito
				aRecno[nPosRec][2]	+= SC6->C6_VALOR
				
				//Adiciona o Recno do registro para atualiza-lo
				aAdd(aRecno[nPosRec][3], { {.T. , ME4->( Recno() ) } } )
			EndIf
			
			 If !MaResDoFat((cAlias)->REGSC6,.T.,.T.,0)
			 	DisarmTransaction()
			 	Break
			 EndIf
		EndIf
		
		(cAlias)->( DbSkip() )
	End
	
	//Executar a rotina abaixo para criar a NCC e vincular os registros do ME4
	For nSeqRec := 1 to Len(aRecno)
		If !Lj8GerCred(aRecno[nSeqRec][3],aRecno[nSeqRec][2],aRecno[nSeqRec][1],.T.)
		 	DisarmTransaction()
		 	Break
		EndIf
	Next nSeqRec
End Transaction 

(cAlias)->( DbCloseArea() )

RestArea(aArea)
RestArea(aAreaME4)

Eval(bFiltraSC6)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj854Pesq �Autor  �Vendas Cliente      � Data �  02/17/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua as pesquisas e mantem o filtro inicial				  ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA854													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Lj854Pesq()

AxPesqui()

Eval(bFiltraSC6)

Return(.T.)