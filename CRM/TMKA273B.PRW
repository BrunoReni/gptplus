#INCLUDE "TMKA273B.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TMKDEF.CH"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �TkStatus   � Autor �Vendas Clientes    	 � Data �21/07/00  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Busca o status do pedido selecionado                         ���
��������������������������������������������������������������������������Ĵ��
���Uso       � TeleVendas - SX3                                            ���
��������������������������������������������������������������������������Ĵ��
���          �        �      �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/   
Function Tk273Status(cCampo)

Local cDesc := " "			//Retorno do status

Do case
	case AllTrim(cCampo) == "NF." .AND. AllTrim(SUA->UA_OPER) == "1"
  		 cDesc := STR0003 //"NF.Emitida" 
  		 
	case AllTrim(cCampo) == "RM." .AND. AllTrim(SUA->UA_OPER) == "1"
  		 cDesc := STR0002 //"Merc.Enviada" 

	case AllTrim(cCampo) == "SUP" .AND. AllTrim(SUA->UA_OPER) == "1"
  		 cDesc := STR0004 //"Ped. Bloq." 

	case AllTrim(cCampo) == "SUP" .AND. AllTrim(SUA->UA_OPER) == "3"  // Atendimento
  		 cDesc := STR0001 //"Atendimento"

	case AllTrim(cCampo) == "CAN"
  		 cDesc := STR0005 //"Cancelado " 

	case AllTrim(SUA->UA_STATUS) == "LIB"
  		 cDesc := STR0006 //"Liberado  " 

	other
		 cDesc := STR0007 //"Or�amento" 
Endcase

Return(cDesc)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Tk271NumTlv � Autor �Vendas Clientes      � Data � 03/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Carrega as informacoes do numero do atendimento digitado    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TeleVendas - SX3                                           ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Tk273NumTlv(	nOpc		,cNumTlv		,lHabilita		,oFolderTlv,;
						oEnchTlv	,cCodPagto		,cDescPagto		,cCodTransp,;
						cTransp		,cCob			,cEnt			,cCidadeC,;
						cCepC		,cUfC			,cBairroE		,cBairroC,;
						cCidadeE	,cCepE			,cUfE			,nLiquido,;
						nTxJuros	,nTxDescon		,nVlJur			,aParcelas,;
						nEntrada	,nFinanciado	,nNumParcelas	,nValorCC,;
						aColsTlv	,cCodAnt		,cCliAnt		,cLock)

Local aArea   	:= GetArea()						// Salva a area atual
Local aSaSUA   	:= {}                        	// Salvar a area para posterior restauracao
Local cTmkaLoj	:= SuperGetMv("MV_TMKALOJ")  	// Parametro que altera os ORCAMENTOS NO SIGALOJA gerados pelo Televendas
Local cAltPed 	:= SuperGetMV("MV_ALTPED")   	// Parametro que permite a edi��o de pedido j� faturado
Local cFilSUA 	:= xFilial("SUA")
Local cFilSC6		:= ""
Local cFilSC9		:= ""
Local cNumAux 	:= ""								// Armazena o UA_NUM quando nao encontra no SUA
Local cTipo   	:= ""								// Armazena o Tipo do Contato (US_TIPO)
Local cAliasEnt	:= ""
Local cNaturez	:= ""
Local lTLVENT 	:= ExistBlock("TLVENT") 		// P.E. executado no fim da funcao
Local lRet		:= .F.								// Retorno da funcao
Local aPDFields := {"U7_NOME","A1_NOME","U5_CONTAT"}
Local lCliEntreg:= SUA->(ColumnPos("UA_CLIENT")) > 0 .And. SUA->(ColumnPos("UA_LOJAENT")) > 0

Default cLock := ""

CursorWait()

//�����������������������������������������������������Ŀ
//�Se encontrar o atendimento informado carrega na tela �
//�������������������������������������������������������
DbSelectArea("SUA")
DbSetOrder(1)
If DbSeek( cFilSUA + cNumTlv)

	//������������������Ŀ
	//�Limpa o aParcelas.�
	//��������������������
	aParcelas:={}

	//����������������������������������������������������������������������������Ŀ
	//�Se a rotina estava incluindo e agora passou a ser uma alteracao solta o SXE �
	//�Atualiza o status dos semaforos para evitar o empilhamento do ultimo folder �
	//������������������������������������������������������������������������������
	If nOpc == 3
		//���������������������������������������������������Ŀ
		//�Se foi usado o SX8 e nao foi feita nenhuma inclusao�
		//�����������������������������������������������������
		If TkGetTipoAte() == "4"// todos os atendimentos
			DbSelectArea("ACF")
			RollBackSX8() // rollback do ultimo folder

			DbSelectArea("SUA")
			RollBackSX8() // rollback do primeiro folder.

			DbSelectArea("SUC")
			RollBackSX8() // rollback do penultimo folder
		ElseIf TkGetTipoAte() == "2"  //TLV
			DbSelectArea("SUA")
			RollBackSX8()
		Endif

		nOpc		:= 4   // Alteracao
		INCLUI		:= .F.
		ALTERA 		:= .T.

	Endif

	//��������������������������������������������������������������������Ŀ
	//�Se a opcao gravada foi FATURAMENTO o usuario nao pode mudar a opcao �	
	//����������������������������������������������������������������������
	If SUA->UA_OPER == "1"
		lAltTpOper := .F.
	Else
		lAltTpOper := .T.
	Endif

	lProspect := SUA->UA_PROSPEC

	If lProspect
		cTipo := Posicione("SUS",1,xFilial("SUS") + SUA->UA_CLIENTE + SUA->UA_LOJA,"US_TIPO")
		cAliasEnt	:= 'SUS'
	Else
		cTipo := Posicione("SA1",1,xFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA,"A1_TIPO")
		cAliasEnt	:= 'SA1'
	Endif

	//���������������������������������������������������
	//�Habilita os dados para depois validar o status   �
	//���������������������������������������������������
	If nOpc == 2 .And. Empty(cLock) .And. !lHabilita
		Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
	Else
		Tk271HabObj(.T.,@lHabilita,@oEnchTlv)
	EndIf

	//���������������������������������������������������
	//�Inicializa os dados do cliente na FUNCAO FISCAL  �
	//���������������������������������������������������
	If ( nOpc <> 2 )
		MaFisIni(IIF(lCliEntreg .And. !lProspect,SUA->UA_CLIENT,SUA->UA_CLIENTE),;	// 1-Codigo Cliente/Fornecedor
				 IIF(lCliEntreg .And. !lProspect,SUA->UA_LOJAENT,SUA->UA_LOJA),;	// 2-Loja do Cliente/Fornecedor
		         "C",;				// 3-C:Cliente , F:Fornecedor
		         "N",;				// 4-Tipo da NF
		         cTipo,;				// 5-Tipo do Cliente/Fornecedor
		         Nil,;				// 6-Relacao de Impostos que suportados no arquivo
		         Nil,;				// 7-Tipo de complemento
		         Nil,;				// 8-Permite Incluir Impostos no Rodape .T./.F.
		         Nil,;				// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		         Nil,;				// 10-Nome da rotina que esta utilizando a funcao
		         Nil,;				// 11-Tipo de documento
		         Nil,;				// 12-Especie do documento
		         IIF(lProspect,SUA->UA_CLIENTE+SUA->UA_LOJA,""))// 13- Codigo e Loja do Prospect

		cNaturez := Tk273DpNat(SUA->UA_CLIENTE, SUA->UA_LOJA)
		If !Empty(cNaturez)
			MaFisAlt("NF_NATUREZA",cNaturez)
		EndIf
	EndIf

	//���������������������������������������������������������������������������������������Ŀ
	//�Se for um PROSPECT atualiza o estado de DESTINO e valida o campo de inscricao estadual �
	//�����������������������������������������������������������������������������������������
	If ( lProspect .AND. ( nOpc <> 2 ) )
		DbSelectArea("SUS")
		DbSetOrder(1)
		If DbSeek(xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA)
			MaFisAlt("NF_UFDEST",SUS->US_EST)
		Endif
	Endif

	Do Case
		Case SUA->UA_STATUS == "NF."           // MV_OPFAT = "S"
			If  ! Empty(SUA->UA_NUMSC5)
				//���������������������������������������������������������������������������������\�
				//�Verifica se o pedido j� foi faturado, se o parametro MV_ALTPED estiver como "N",�
				//�o pedido n�o podera ser alterado, caso contrario o sistema verificara cada item.�
				//���������������������������������������������������������������������������������\�
				DbSelectArea("SC5")
				DbSetOrder(1)
				If DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
					If !Empty(SC5->C5_NOTA)					// Verifica se o pedido foi faturado totalmente
						Aviso(STR0008,STR0012,{STR0009})	// "Aten��o!" "A Nota fiscal referente a este pedido j� foi emitida!" "Continuar"
						If cAltPed == "N"					// Se o par�meto MV_ALTPED == "N", o pedido n�o pode ser alterado
							Help(" ",1,"A410PEDFAT")
							Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
						EndIf
					EndIf
				EndIf
			Else
				//Empty(SUA->UA_NUMSC5) - identifica gera��o de venda pelo Venda Direta
				DbSelectArea("SF2")
				DbSetOrder(1)
				If DbSeek(xFilial("SC5")+SUA->UA_DOC+SUA->UA_SERIE+SUA->UA_CLIENTE+SUA->UA_LOJA)
					Help(" ",1,"VENDA_LOJA")      //Aviso(STR0008,"A Nota fiscal referente a este pedido j� foi emitida atraves da Venda Direta!",{STR0009})	// "Aten��o!" "A Nota fiscal referente a este pedido j� foi emitida!" "Continuar"
					Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
				EndIf
			EndIf

		Case SUA->UA_STATUS == "RM."
			Help(" ",1,"RM.ENVIADA")
			Tk271HabObj(.F.,@lHabilita,@oEnchTlv)

		Case SUA->UA_STATUS == "CAN"           // Nao habilita nada
			Help(" ",1,"PED.CAN")
			Tk271HabObj(.F.,@lHabilita,@oEnchTlv)

		Case SUA->UA_STATUS == "SUP" .Or. SUA->UA_STATUS == "LIB"
			//����������������������������������������������������������Ŀ
			//�Verifica se o Operador tem acesso (Senhas) para alterar o �
			//�pedido.                                                   �
			//������������������������������������������������������������
			If (VAL(SUA->UA_OPER) == FATURAMENTO) .AND. !Empty(SUA->UA_NUMSC5)
				If !ChkPsw(20)
					Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
				Endif
			Endif

			//�����������������������������������������������������Ŀ
			//�Verifico se esse pedido foi liberado pelo SIGAFAT    �
			//�sao verificados os campos C6_QTDEMP + C6_QTDENT > 0  �
			//�nao altera mais o atendimento                        �
			//�������������������������������������������������������
			If !Empty(SUA->UA_NUMSC5)
				DbSelectArea("SC5")
				DbSetOrder(1)
				If DbSeek(xFilial("SC5")+SUA->UA_NUMSC5)
					//�������������������������������������������������������Ŀ
					//�Antes de alterar o pedido verifico se nao foi liberado �
					//���������������������������������������������������������
					If Empty(SC5->C5_NOTA)
						//�������������������������������������������������������Ŀ
						//�Verifica se teve algum item com NF emitida parcial     �
						//���������������������������������������������������������
						cFilSC6	:= xFilial("SC6")
						cFilSC9	:= xFilial("SC9")
						DbSelectArea("SC6")
						DbSetOrder(1)
						If SC6->(DbSeek(cFilSC6+SUA->UA_NUMSC5))
							While SC6->(! Eof()) .AND. SC6->C6_FILIAL == cFilSC6 .AND. SC6->C6_NUM == SUA->UA_NUMSC5

								//�����������������������������������������������������������������������Ŀ
								//�Impede a alteracao de Pedido com Servico de WMS jah executado 		  �
								//�������������������������������������������������������������������������								
								If	IntDL(SC6->C6_PRODUTO)
									SC9->(dbSetOrder(2)) //-- C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
									If	SC9->(DbSeek(cFilSC9+SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC5->C5_NUM+SC6->C6_ITEM, .F.))
										If	Empty(SC9->C9_NFISCAL) .And. SC9->C9_BLWMS == '05' .And. !(SC6->C6_QTDLIB==SC9->C9_QTDLIB) //-- Liberado para WMS (Servico jah executado)
											Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
											Aviso('SigaWMS',STR0015+AllTrim(SC6->C6_ITEM)+STR0016+" ( "+AllTrim(Transform(SC9->C9_QTDLIB, PesqPict('SC9', 'C9_QTDLIB')))+" "+STR0017, {'Ok'}) //'O Item '###" nao pode ser alterado porque possui servicos de WMS pendentes. Estorne estes servicos para proceder com a alteracao."###"na 1a UM ) nao pode ser alterada."
											Exit
										EndIf
									EndIf
								EndIf

								//����������������������������������������������������
								//�Visualiza o atendimento mas, nao pode alterar nada�
								//����������������������������������������������������
								If !Empty(SC6->C6_NOTA)
									Aviso(STR0008,STR0013,{STR0009}) // "Aten��o!" "A Nota fiscal referente a este pedido j� foi emitida parcialmente!" "Continuar"
									Exit
								Elseif (SC6->C6_QTDEMP + SC6->C6_QTDENT) > 0
									Aviso(STR0008,STR0014,{STR0009}) // "Aten��o!" "Este pedido j� foi liberado!" "Continuar"
									Exit
								Endif
								SC6->(DbSkip())
							EndDo
						Endif
					Endif
				Else
					//��������������������������������������������������������������������������������������������Ŀ
					//�O pedido foi apagado pelo SIGAFAT - na base da 609 - Na 710 quem apaga o pedido e o SIGATMK �
					//����������������������������������������������������������������������������������������������
					Help(" ",1,"PED.CAN")
					Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
				Endif
			Endif

			//�����������������������������������������������������Ŀ
			//�Verifico se existe integracao com o SIGALOJA         �
			//�������������������������������������������������������
			If (cTmkaLoj == "S") .AND. (Val(SUA->UA_OPER) == ORCAMENTO)

				//����������������������������������������������������������������������Ŀ
				//�Se encontrou o orcamento e ele ja foi recebido sera emitido um HELP e �
				//�impede a alteracao desse atendimento porque ele ja foi fechado no LOJA� 
				//������������������������������������������������������������������������
				DbSelectArea("SL1")
				DbSetOrder(1)
				If DbSeek(xFilial("SL1") + SUA->UA_NUMSL1)
					If!Empty(SL1->L1_DOC)
						Help(" ",1,"VENDA_LOJA")
						Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
					Else
						//���������������������������������������������Ŀ
						//�Tranca o or�amento para edi��o pelo SIGALOJA.�
						//�����������������������������������������������
						If nOpc <> 2
							If !TkLibLoja("C")
								Tk271HabObj(.F.,@lHabilita,@oEnchTlv)
							EndIf
						EndIf
					Endif
				EndIf
			Endif

	EndCase

	//�������������������������������������Ŀ
	//�Atualiza a enchoice de Telemarketing.�
	//���������������������������������������
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SUA")
	While (!SX3->( Eof()) .AND. SX3->X3_ARQUIVO == "SUA")
		If X3USO(SX3->X3_USADO)
			cCampo := ALLTRIM(SX3->X3_CAMPO)
			If (X3_CONTEXT # "V")
				M->&(cCampo) := SUA->&(cCampo)
			ElseIf (X3_CONTEXT == "V")
				M->&(cCampo) :=  CriaVar(cCampo)
			EndIf
		EndIf
		DbSkip()
	EndDo
	If Empty(M->UA_TIPOCLI)
		M->UA_TIPOCLI := cTipo
	EndIf

	If nOpc == 4
		If (SUA->(FieldPos("UA_TIPOCLI")) > 0)
			Tk273RodImposto("NF_TPCLIFOR",SUA->UA_TIPOCLI)
		EndIf
		If lCliEntreg
			MaFisAlt("NF_CODCLIFOR",IIf(!lProspect,M->UA_CLIENT,M->UA_CLIENTE))
			MaFisAlt("NF_LOJA",IIf(!lProspect,M->UA_LOJAENT, M->UA_LOJA))
		EndIf
	EndIf

	//������������������������������������������������������������Ŀ
	//�Grava a condi��o de pagamento atual para que se for alterada�
	//�aconte�a a montagem das parcelas novamente.                 �
	//��������������������������������������������������������������
	cCodAnt := SUA->UA_CONDPG

	//��������������������������������������������������������������Ŀ
	//� Configura�ao da GetDados - Folder 01  *** Televendas 		 �
	//����������������������������������������������������������������
	TK271Config("SUB","UB_NUM",nOpc,NIL,cNumTlv,NIL,)
	oGetTlv:oBrowse:Refresh(.T.)

	//�������������������������������������������������������������Ŀ
	//�Armazena o ACOLS anterior para recaculo posterior do ESTOQUE �
	//���������������������������������������������������������������
	aColsTlv := aClone(aCols)

	//��������������������������������������������������������������Ŀ
	//�Refresh no RODAPE	  										 �
	//����������������������������������������������������������������
	aValores[MERCADORIA]	:= SUA->UA_VALMERC
	aValores[ACRESCIMO]		:= SUA->UA_ACRESCI

	aValores[DESCONTO]		:= SUA->UA_DESCONT
	Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])

	aValores[DESPESA]	 	:= SUA->UA_DESPESA
	Tk273RodImposto("NF_DESPESA",aValores[DESPESA])

	aValores[FRETE]			:= SUA->UA_FRETE
	Tk273RodImposto("NF_FRETE",aValores[FRETE])

	aValores[MERCADORIA]	:= SUA->UA_VALBRUT

	//��������������������������������������������������������������Ŀ
	//�Se existir BONUS deleta o item para indicar que e um BONUS    �
	//����������������������������������������������������������������
	Tk273Bonus(2)

	nEntrada 	:= SUA->UA_ENTRADA
	nFinanciado := SUA->UA_FINANC
	nTxJuros	:= SUA->UA_JUROS
	nTxDescon	:= SUA->UA_TXDESC

	nNumParcelas:= SUA->UA_PARCELA
	cCodPagto	:= SUA->UA_CONDPG
	cCodTransp	:= SUA->UA_TRANSP

	//���������������������������������Ŀ
	//�Posiciona a Condicao de Pagamento�
	//�����������������������������������
	If !Empty(cCodPagto)
		DbSelectArea("SE4")
		DbSetOrder(1)
		DbSeek(xFilial("SE4")+cCodPagto)
	EndIf

	//�������������������������������Ŀ
	//�Atualiza nome da transportadora�
	//���������������������������������
	If !Empty(cCodTransp)
		cTransp		:= Posicione("SA4",1,xFilial("SA4")+M->UA_TRANSP,"A4_NOME")
	EndIf

	//���������������������������������������������������������������Ŀ
	//�Atualizo o Endre�o de entrega e de cobran�a                    �
	//�����������������������������������������������������������������
	cCob    	:=SUA->UA_ENDCOB
	cEnt    	:=SUA->UA_ENDENT
	cCidadeC	:=SUA->UA_MUNC
	cCepC   	:=SUA->UA_CEPC
	cUfC    	:=SUA->UA_ESTC
	cBairroC	:=SUA->UA_BAIRROC
	cCidadeE	:=SUA->UA_MUNE
	cCepE   	:=SUA->UA_CEPE
	cUfE    	:=SUA->UA_ESTE
	cBairroE	:=SUA->UA_BAIRROE
	cCliAnt		:=SUA->UA_CLIENTE + SUA->UA_LOJA

	//�������������������������������������������������������������������������������������������������Ŀ
	//�Caso o operador mude de or�amento p/ faturamento obrigo ele a indicar a forma de pagto escolhida �
	//���������������������������������������������������������������������������������������������������
	DbSelectArea("SUA")

    //Salva a area anterior para evitar o desposicionamento no SUA.
	aSaSUA:= GetArea()

	DbSetOrder(7)   //Data da ultima liga�ao
	If DbSeek(cFilSUA + M->UA_CLIENTE + M->UA_LOJA)
		FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)
		While !EOF() .And. cFilSUA ==  SUA->UA_FILIAL .And. M->UA_CLIENTE == SUA->UA_CLIENTE .And. M->UA_LOJA == SUA->UA_LOJA
			If lProspect == SUA->UA_PROSPEC
				cLigacao	:= DTOC(CTOD("01/01/45")-UA_DIASDAT)+" - "+Substr(SUA->UA_INICIO,1,5)
				cOperador   := FATPDObfuscate( Posicione("SU7",1,xFilial("SU7") + SUA->UA_OPERADO,"U7_NOME"),"U7_NOME")
				If !Empty(SUA->UA_PROXLIG)
					cProximo:= DTOC(SUA->UA_PROXLIG) + " - " + SUA->UA_HRPEND + " - " + cOperador
				Endif
			
				cOperacao := Tk273Status(SUA->UA_STATUS)
				cNomeHist := FATPDObfuscate(TkEntidade(cAliasEnt,SUA->UA_CLIENTE+M->UA_LOJA,1),"A1_NOME")
				cContHist:=  FATPDObfuscate(TkDadosContato(M->UA_CODCONT,0),"U5_CONTAT")

				oLigacao :Refresh()
				oOperador:Refresh()
				oOperacao:Refresh()
				oProximo :Refresh()
				oNomeHist:Refresh()
				oContHist:Refresh()
				Exit
			EndIf
			SUA->(DbSkip())
		EndDo
		FATPDUnload()
	Endif

	RestArea(aSaSUA)

	//������������������Ŀ
	//�Reposiciona o SUA �
	//��������������������
	RestArea(aArea)

	lRet := .T.
Else
	cNumAux   := GetSxeNum("SUA","UA_NUM")
	M->UA_NUM := cNumAux
	RollBackSxe()

	If cNumTlv > cNumAux
		Help( " ",1,"FORA_SEQ")
	EndIf

	lRet := .T.
Endif

If lTLVENT
	U_TLVENT(M->UA_NUM,@lHabilita,@oGetTlv,@oEnchTlv)
Endif

oFolderTlv:Refresh()
oGetTlv:oBrowse:Refresh()
Eval(bRefresh)
CursorArrow()
Return(lRet)

//--------------------------------------- Funcoes nao chamadas no sistema------------------------------------------------------

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK273Track  �Autor  �Vendas Clientes   � Data �  07/31/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Executa a funcao de Tracker para rastrear o atendimento no  ���
���          �SIGAFAT                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �Somente Televendas                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

Function TK273Track()

Local aEnt     := {}
Local cNumTlv  := M->UA_NUM
Local nPosItem := GDFieldPos( "UB_ITEM" )
Local nLoop    := 0

//���������������������������������������������Ŀ
//�Inicializa a funcao fiscal                   �
//�����������������������������������������������
For nLoop := 1 To Len( aCols )
	AAdd( aEnt, { "SUB", cNumTlv + aCols[ nLoop, nPosItem ] } )
Next nLoop

MaTrkShow( aEnt )

Return(.T.)
*/

/*
��������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Tk271TabValid� Autor � Vendas Clientes      � Data � 10.05.01 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Seleciona a primeira tabela valida para o produto            ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tk271TabValid(ExpC1) 										���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Produto	                            			    ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � TMKA271													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function Tk273TabValid(cProduto)
Local aSaveArea := GetArea()
Local cCodTab   := ""

If !Empty(cProduto)
	DbSelectArea("DA1")
	DbSetOrder(2)
	If DbSeek (xFilial("DA1") + cProduto)
		While (!EOF()) .AND. (xFilial("DA1") == DA1->DA1_FILIAL) .AND. (DA1->DA1_CODPRO == cProduto)
			If MaVldTabPrc(DA1->DA1_CODTAB,"","")
				cCodTab := DA1->DA1_CODTAB
				Exit
			Endif
			DbSkip()
		End
	Endif
	
Endif

RestArea(aSaveArea)

Return(cCodTab)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �TK271LOTCTL �Autor  �Vendas Clientes      � Data �23.03.00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o Lote de Controle digitado pelo usuario             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Logico                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TK273LotCTL()

Local aArea		:= GetArea()
Local aAreaF4	:= SF4->(GetArea())
Local nPProduto := Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_PRODUTO"})
Local nPLocal	:= Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_LOCAL"})
Local nPLoteCtl := Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_LOTE"})
Local nPNumLote := Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_SUBLOTE"})
Local nPDtValid := Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_DTVALID"})
Local nPTes		:= Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_TES"})
Local nPQuant	:= Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_QUANT"})
Local cProduto	:= aCols[n][nPProduto]
Local cLocal	:= aCols[n][nPLocal]
Local cNumLote	:= aCols[n][nPNumLote]
Local cLoteCtl  := aCols[n][nPLoteCtl]
Local nQuant    := aCols[n][nPQuant]
Local lRetorna  := .T.
Local nSaldo	:= 0
Local lGrade 	:= SuperGetMv("MV_GRADE")

If Empty(cLoteCtl) .AND. Empty(cNumLote)
	Return .T.
Endif

//������������������������������������������������������������������������Ŀ
//�Verifica se Movimenta Estoque                                           �
//��������������������������������������������������������������������������
DbSelectArea("SF4")
DbSetOrder(1)
If ( DbSeek(xFilial("SF4")+aCols[n][nPTes]) .AND. SF4->F4_ESTOQUE=="N" )
	Help(" ",1,"A410TEEST")
	lRetorna := .F.
Endif
//������������������������������������������������������������������������Ŀ
//�Verifica se o Produto eh uma referencia                                 �
//��������������������������������������������������������������������������
If  ( lRetorna .AND. lGrade )
	If ( MatGrdPrrf(cProduto) )
		Help(" ",1,"A410NGRADE")
		lRetorna := .F.
	Endif
Endif
//������������������������������������������������������������������������Ŀ
//�Verifica se o Produto possui rastreabilidade                            �
//��������������������������������������������������������������������������
If ( lRetorna .AND. !Rastro(cProduto) )
	Help( " ", 1, "NAORASTRO" )
	aCols[n,nPNumLote]  := CriaVar( "UB_SUBLOTE" )
	aCols[n,nPLoteCtl]	:= CriaVar( "UB_LOTE" )
	aCols[n,nPDtValid]	:= CriaVar( "UB_DTVALID" )
	aCols[n,nPQuant]	:= CriaVar( "UB_QUANT" )
	lRetorna := .F.
Else
	If ( lRetorna )
		nSaldo := SldAtuEst(cProduto,cLocal,nQuant,cLoteCtl)
		If ( nQuant > nSaldo )
			Help(" ",1,"A440ACILOT")
			lRetorna  := .F.
		Else
			If !Empty(cLoteCtl)
				aCols[n,nPDtValid]	:= SB8->B8_DTVALID
			Endif
		Endif
	Endif
Endif

//������������������������������������������������������������������������Ŀ
//�Restaura a Entrada da Rotina                                            �
//��������������������������������������������������������������������������
RestArea(aAreaF4)
RestArea(aArea)
Return(lRetorna)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TK271Lote � Autor � Vendas Clientes      � Data � 23.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a Quantidade digitada no Lote.                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMK010                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TK273Lote()

Local cLote 
Local cProduto
Local cLocal
Local nSaldo
Local cAlias 	:= Alias()
Local cTes
Local nPosProd 	:= 0
Local lGrade   	:= SuperGetMv("MV_GRADE")
Local cLoteCtl
Local nX		:= 0 			// Contador

nPosProd := Ascan(aHeader,{ |x| ALLTRIM(x[2])=="UB_PRODUTO"})
If !Rastro(aCols[n,nPosProd])
	Help(" ",1,"A440NAORAS")
	For nX = 1 to Len(aHeader)
		If Trim(aHeader[nX][2]) == "UB_SUBLOTE"
			aCols[n][nX] 	:=CriaVar("UB_SUBLOTE")
			M->UB_SUBLOTE	:=CriaVar("UB_SUBLOTE")
		ElseIf Trim(aHeader[nX][2]) == "UB_LOTE"
			aCols[n][nX]	:=CriaVar("UB_LOTE")
			M->UB_LOTE		:=CriaVar("UB_LOTE")
		ElseIf Trim(aHeader[nX][2]) == "UB_DTVALID"
			aCols[n][nX]	:=CriaVar("UB_DTVALID")
			M->UB_DTVALID	:=CriaVar("UB_DTVALID")
		Endif
	Next nX
	Return .T.
Endif

cLote := &(ReadVar())

If Empty(cLote)
	Return .T.
Endif

For nX=1 to Len(aHeader)
	If Trim(aHeader[nX][2]) == "UB_PRODUTO"
		cProduto := aCols[n][nX]
		//��������������������������������������������������������������Ŀ
		//� Verifica se a grade esta ativa, e se o produto digitado e'   �
		//� uma referencia                                               �
		//����������������������������������������������������������������
		If lGrade
			lRet := MatGrdPrrf(@cProduto)
			If lRet
				cProduto := ALLTRIM(cProduto)
			Endif
		Endif
	Elseif Trim(aHeader[nX][2]) == "UB_LOCAL"
		cLocal := aCols[n][nX]
	Elseif Trim(aHeader[nX][2]) == "UB_QUANT"
		nQuant := aCols[n][nX]
	Elseif Trim(aHeader[nX][2]) == "UB_TES"
		cTes := aCols[n][nX]
	Elseif Trim(aHeader[nX][2]) == "UB_LOTE"
		cLoteCtl := aCols[n][nX]
	End
Next nX

DbSelectArea("SF4")
DbSeek(xFilial("SF4")+cTes)
//��������������������������������������������������������������Ŀ
//� Verifica o arquivo a ser pesquisado                          �
//����������������������������������������������������������������
DbSelectArea("SB8")
DbSetOrder(1)
DbSeek(xFilial("SB8")+cProduto+cLocal)
If !Found()
	Help(" ",1,"A440NAOLOT")
	For nX = 1 to Len(aHeader)
		If Trim(aHeader[nX][2]) == "UB_SUBLOTE"
			aCols[n][nX] :=CriaVar("UB_SUBLOTE")
			M->UB_SUBLOTE:=CriaVar("UB_SUBLOTE")
		ElseIf Trim(aHeader[nX][2]) == "UB_LOTE"
			aCols[n][nX] :=CriaVar("UB_LOTE")
			M->UB_LOTE   :=CriaVar("UB_LOTE")
		ElseIf Trim(aHeader[nX][2]) == "UB_DTVALID"
			aCols[n][nX] :=CriaVar("UB_DTVALID")
			M->UB_DTVALID:=CriaVar("UB_DTVALID")
		Endif
	Next nX
	DbSelectArea(cAlias)
	Return .T.
Else
	If SF4->F4_ESTOQUE == "S"
		DbSelectArea("SB8")
		
		If Rastro( cProduto, "S" )
			DbSetOrder( 2 )
			DbSeek(xFilial("SB8")+cLote+If(!Empty(cLoteCtl),cLoteCtl,""))
		Else
			DbSetOrder( 3 )
			cChave := xFilial( "SB8" ) + cProduto + cLocal + cLoteCtl
			DbSeek( cChave, .f. )
		Endif
		
		If Found()
			
			If Rastro( cProduto, "S" )
				nSaldo := B8_SALDO - ( B8_EMPENHO + QtdLote(SB8->B8_PRODUTO,SB8->B8_LOCAL,SB8->B8_NUMLOTE) )
			Else
				
				nSaldo := SaldoLote( cProduto, cLocal, cLoteCtl )
				nSaldo -= QtdLote(SB8->B8_PRODUTO,SB8->B8_LOCAL,,,SB8->B8_LOTECTL)
				
			Endif
			
			If nSaldo > 0
				For nX := 1 To Len(aHeader)
					If nSaldo < nQuant
						If Trim(aHeader[nX][2]) == "UB_QUANT"
							aCols[n][nX] := nSaldo
						ElseIf Trim(aHeader[nX][2]) == "UB_SUBLOTE"
							aCols[n][nX] := cLote
							M->UB_SUBLOTE := cLote
						ElseIf Trim(aHeader[nx][2]) == "UB_LOTE"
							aCols[n][nx] :=SB8->B8_LOTECTL
							M->UB_LOTE   :=SB8->B8_LOTECTL
						ElseIf Trim(aHeader[nx][2]) == "UB_DTVALID"
							aCols[n][nx] :=SB8->B8_DTVALID
							M->UB_DTVALID:=SB8->B8_DTVALID
						Endif
					Endif
				Next nX
			Else
				Help(" ",1,"A440LOTVAZ")
				DbSelectArea(cAlias)
				Return .F.
			Endif
		Else
			Help(" ",1,"A440NAOLOT")
			For nx = 1 to Len(aHeader)
				If Trim(aHeader[nx][2]) == "UB_SUBLOTE"
					aCols[n][nx] :=CriaVar("UB_SUBLOTE")
					M->UB_SUBLOTE:=CriaVar("UB_SUBLOTE")
				ElseIf Trim(aHeader[nx][2]) == "UB_LOTE"
					aCols[n][nx] :=CriaVar("UB_LOTE")
					M->UB_LOTE   :=CriaVar("UB_LOTE")
				ElseIf Trim(aHeader[nx][2]) == "UB_DTVALID"
					aCols[n][nx] :=CriaVar("UB_DTVALID")
					M->UB_DTVALID:=CriaVar("UB_DTVALID")
				Endif
			Next nx
			DbSelectArea(cAlias)
			Return .F.
		Endif
	Endif
Endif
Return .T.   




//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usu�rio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que ser�o verificados.
    @param aFields, Array, Array com todos os Campos que ser�o verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com prote��o de dados.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
