#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA853.CH"
#DEFINE CRLF CHR(13)+CHR(10)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA853   �Autor  �Microsiga           � Data �  07/26/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela para selecao de itens das sugestoes de lista para      ���
���          �a tela de criacao de lista de eventos                       ���
�������������������������������������������������������������������������͹��
���Sintaxe   �LOJA853(Exp01)                                              ���
�������������������������������������������������������������������������͹��
���Retorno   �aResult[A] : Array com os itens selecionados na tela        ���
�������������������������������������������������������������������������͹��
���Parametro �Exp01[C] : Codigo do tipo do evento                         ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA843.PRW                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function LOJA853(cCodEve)

Local nB        := 0												// Variavel utilizada como contador em loop utilizando For
Local nC        := 0												// Variavel utilizada como contador em loop utilizando For
Local oDlgSel														// Objeto da caixa de dialogo (tela)
Local oLbxSel														// Objeto do grid com as informacoes sobre as sugestoes de listas
Local oTit1															// Objeto para o texto facilitadores na tela
Local oListBx1														// Objeto do grid com as informacoes sobre os itens da sugestao selecionada
Local oCheck    := LoadBitMap(GetResources(),"LBOK"			)		// Objeto com a imagem de quando o item da lista foi selecionado
Local oNoCheck  := LoadBitMap(GetResources(),"LBNO"			)		// Objeto com a imagem de quando o item da lista foi desmarcado
Local oCan	  := LoadBitMap(GetResources(),"BR_VERDE"		)		// Objeto com a imagem de quando o item da lista esta OK - produto desbloquado
Local oNoCan	  := LoadBitMap(GetResources(),"BR_VERMELHO"	)	// Objeto com a imagem de quando o item da lista esta OK - produto bloquado
Local nOpcx     := 0												// Variavel para controle da opcao escolhida ao sair da tela - botao OK = 1
Local nValLista := 0												// Contem o somatorio do valor de todos os itens uma determinada lista
Local aSugest   := {}                        						// Lista com os dados necessarios para popular o grid das sugestoes
Local aResult   := {}												// Array com os itens selecionados e que e retornado para a funcao chamadora
Local aButton   := {}												// Array com os botoes da enchoice bar que podem ser acrescentados
Local aEstrut   := {}												// Recebe o retorno da funcao LJ853STRU com os dados das sugestoes do tipo de lista selecionado
Local lClick    := .F.												// Variavel utilizada para controle da selecao dos itens nos grids da tela
Local cTit1     := STR0001 //"Facilitadores"							// Texto a ser apresentado na tela
Local nX		:= 0
Local nY		:= 0
Default cCodEve   := ""

Aadd(aButton,{"RELATORIO",{||LJ853Print(@aSugest)},STR0002,STR0002})       //"Imprimir" # "Imprimir"

DbSelectArea("ME7")
ME7->(DbSetOrder(2))
If Empty(cCodEve)
	ME7->(DbGoTop())
Else
	//��������������������������������������������������������������������������������Ŀ
	//�Verificar se existe sugest�o de lista para o tipo de evento passado no parametro�
	//����������������������������������������������������������������������������������
	If !ME7->(DbSeek(xFilial("ME7")+cCodEve))
		Alert(STR0019)   //// "N�o existem Sugest�es para este tipo de Evento!"
		Return(aResult)
	Endif
Endif



//��������������������������������������������������������������������������������������������������Ŀ
//�Varrer a tabela ME7 em busca de todas as sugestoes de lista do tipo de evento enviado no parametro�
//����������������������������������������������������������������������������������������������������
While ME7->(!Eof())
	
	If !Empty(cCodEve) .AND. ME7->(ME7_FILIAL+ME7_TIPLIS) <> xFilial("ME7")+cCodEve
		Exit
	Endif
    
    If ME7->ME7_STATUS == "1"
		aEstrut := LJ853STRU(ME7->ME7_CODIGO)
		If LEN(aEstrut) > 0
			aAdd(aSugest,aEstrut)
			aEstrut := {}
		Endif
	Endif
		
	ME7->(DbSkip())
End                                       			

//�������������������������������������������������������������������������������������Ŀ
//�Caso nao tenha encontrado nenhuma sugestao o array e preenchido com valores default .�
//���������������������������������������������������������������������������������������
If Len(aSugest) == 0
	aAdd(aEstrut,{"","","","","",STR0015,{},.F.,0})
	aAdd(aEstrut[1,7],{.F.,.F.,"","","","","","",0,0}) 
	aAdd(aSugest,aEstrut)

ElseIf Len(aSugest) > 0 //Caso n�o haja nenhum produto na ME8, insere valores default
	For nX:= 1 to Len(aSugest)
		If Len(aSugest[nX]) > 0
			For nY := 1 to Len(aSugest[nX])
				If Len(aSugest[nX][nY][7]) == 0
					Aadd(aSugest[nX][nY][7] , {.F.,.F.,"","","","","","",0,0} )
				EndIf
			Next nY
		EndIf
	Next nX
Endif

//�������������������������������Ŀ
//�Criar a caixa de dialogo (tela)�
//���������������������������������
oDlgSel := TDialog():New(001,001,480,1000,OemToAnsi(STR0003),,,,,,,,oMainWnd,.T.) //"Sugestao de Lista"

//�������������������������Ŀ
//�Monta 2o listbox na tela �
//���������������������������
oLBxSel := TwBrowse():New(015,005,490,58,,{"",STR0004,STR0005,STR0006,STR0007,STR0013,STR0008},,oDlgSel,,,,,,,,,,,,.T.,,.T.,,.F.,,,) //Sugestao#Descricao#Tipo Evento#Evento#Status

oLBxSel:SetArray(aSugest)

oLBxSel:bLine:={||{Iif(	aSugest[oLBxSel:nAt,1,8],oCheck,oNoCheck)	,;
						aSugest[oLBxSel:nAt,1,2]					,;
						aSugest[oLBxSel:nAt,1,3]					,;
						aSugest[oLBxSel:nAt,1,4]					,;
						aSugest[oLBxSel:nAt,1,5]					,;
						Transform(aSugest[oLBxSel:nAt,1,9],"@E 999,999,999.99"),;
						aSugest[oLBxSel:nAt,1,6]					}}

oLBxSel:bChange:={||	oListBx1:SetArray(aSugest[oLBxSel:nAt,1,7])                                           					,;
						oListBx1:bLine := {||{	Iif(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,1],oCheck,oNoCheck)  					,;
												Iif(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,2],oCan  ,oNoCan  )  					,;
													aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,7]					   				,;
													aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,8]									,;
													aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,10]									,;
													Transform(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,9],"@E 999,999,999.99")}}	,;
						oListBx1:Refresh()													   			  						}						

oLBxSel:BlDblClick := {||	lClick:=!aSugest[oLBxSel:nAt,1,8] 		,;
							aSugest[oLBxSel:nAt,1,8]:=lClick   		,;
							nValLista := 0					   		,;
							aEval(aSugest[oLBxSel:nAt,1,7],{|xMark| Iif(xMark[2],(xMark[1]:=lClick, nValLista += Iif(lClick,xMark[9],0)),xMark[1]:=.F.)}),;
							aSugest[oLBxSel:nAt,1,9] := nValLista	,;
							oListBx1:Refresh()}

//�������������������������Ŀ
//�Monta 2o listbox na tela �
//���������������������������
@ 075, 005 Say oTit1 Var cTit1 Size 140, 010 Pixel Of oDlgSel // Font oFntVlr
oListBx1 := TwBrowse():New(085,005,490,150,,{"","",STR0011,STR0012,STR0020,STR0013},,oDlgSel,,,,,,,,,,,,.T.,,.T.,,.F.,,,) //Produto#Descricao Produto#Quantidade#Preco

oListBx1:SetArray(aSugest[oLBxSel:nAt,1,7])

oListBx1:bLine := {|| {	Iif(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,1],oCheck,oNoCheck)  				,;
						Iif(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,2],oCan  ,oNoCan  )  				,;
							aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,7]				   				,;
							aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,8]								,;
							aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,10]								,;							
							Transform(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,9],"@E 999,999,999.99")	}}	

oListBx1:BlDblClick := {||	lClick:=!aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,1]	 							,;
							Iif	(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,2]		 							,;
								(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,1]:= lClick	   						,;
							Iif	(lClick,aSugest[oLBxSel:nAt,1,9]+=aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,9]	,;
								aSugest[oLBxSel:nAt,1,9]-=aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,9])),.T.)	,;
							oLBxSel:Refresh()}

//�������������������������Ŀ
//�Ativar a caixa de dialogo�
//���������������������������
Activate MsDialog oDlgSel Center On Init EnchoiceBar(oDlgSel, {||(oDlgSel:End(),nOpcx:=1)}, {|| (oDlgSel:End(),nOpca := 0)},,aButton)

//������������������������������������������������������������Ŀ
//�Se for clicado no botao ok da enchoicebar e houver registros�
//�selecionados nos grids de produtos estes serao carregado no �
//�array aSugest que e o retorno da funcao.                    �
//��������������������������������������������������������������
If nOpcx == 1
	For nB := 1 To LEN(aSugest)
		If aSugest[nB,1,8]
			For nC := 1 To LEN(aSugest[nB,1,7])
				If aSugest[nB,1,7,nC,1]
					aAdd(aResult,{	aSugest[nB,1,7,nC,3],;  // [01] Facilitador
									aSugest[nB,1,7,nC,4],;  // [02] Descricao do facilitador
									aSugest[nB,1,7,nC,5],;  // [03] Grupo da lista
									aSugest[nB,1,7,nC,6],;  // [04] Descricao do grupo da lista
									aSugest[nB,1,7,nC,7],;  // [05] Codigo do produto
									aSugest[nB,1,7,nC,8],;  // [06] Descricao do produto
									aSugest[nB,1,7,nC,9],;  // [07] Preco
									aSugest[nB,1,7,nC,10]}) // [08] Quantidade
				Endif			
			Next nC			
		Endif
	Next nB	
Endif

Return(aResult)

/*���������������������������������������������������������������������������
���Programa  �LJ853STRU �Autor  �Microsiga           � Data �  07/27/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta o array com a sugestao do codigo passao no paramentro ���
�������������������������������������������������������������������������͹��
���Sintaxe   �LJ853STRU(Exp01)                                           ���
�������������������������������������������������������������������������͹��
���Retorno   �aRetorno[A] : Array com as sugestoes e seus respectivo pro- ���
���          �dutos                                                       ���
�������������������������������������������������������������������������͹��
���Parametro �Exp01[C] : codigo da tabela de sugestao                     ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA853.PRW                                                 ���
���������������������������������������������������������������������������*/
Function LJ853STRU(cCodTab)

//������������������Ŀ
//�Declara variaveis �
//��������������������
Local aArea    := ME7->(GetArea())		// Guardar a area antes de manipula-la para depois restaura-lo ao estado original
Local aRetorno := {}					// Array de retorno da funcao com os dados da sugestao e seus itens consultados
Local nPosTab  := 0						// Variavel utilizada para identificao do numero da linha no array aRetorno para
										// inclusao dos itens da sugestao na linha correta
Local nPrcLis  := 0						// Valor do item
Default cCodTab  := ""					

//�����������������������������������������������������Ŀ
//�Caso nao seja informada a tabela na variavel cCodTab �
//�o componente retornara todas as sugestoes existentes �
//�������������������������������������������������������
DbSelectArea("ME7")
ME7->(DbSetOrder(1))
If Empty(cCodTab)
	ME7->(DbGoTop())
Else
	ME7->(DbSeek(xFilial("ME7")+cCodTab))
Endif

While ME7->(!Eof())
	
	If !Empty(cCodTab) .AND. ME7->(ME7_FILIAL+ME7_CODIGO) <> xFilial("ME7")+cCodTab
		Exit
	Endif
	
	//������������������������������������������Ŀ
	//�Monta a estrutura de arvore das sugestoes �
	//��������������������������������������������
	DbSelectArea("ME8")
	ME8->(DbSetOrder(1))
	ME8->(DbSeek(xfilial("ME8")+ME7->ME7_CODIGO))
	While ME8->(!Eof()) .AND. ME8->(ME8_FILIAL+ME8_CODIGO) == xFilial("ME8")+ME7->ME7_CODIGO
		
		//������������������Ŀ
		//�Agrupa por tabela �
		//��������������������
		nPosTab := aScan(aRetorno,{|x| x[1]+x[2] == ME7->ME7_FILIAL+ME7->ME7_CODIGO})
		If nPosTab == 0
			aAdd(aRetorno,{	ME7->ME7_FILIAL								,; //01
							ME7->ME7_CODIGO								,; //02
							ME7->ME7_DESCRI								,; //03
							ME7->ME7_TIPLIS								,; //04
							ME7->ME7_DESCTP								,; //05
							Iif(ME7->ME7_STATUS=="1",STR0014,STR0015)	,; //06
							{}											,; //07
							.F.											,; //08
							0											}) //09
			nPosTab := LEN(aRetorno)
		Endif
		
		//����������������������������������������������Ŀ
		//�Cria lista dos produtos da sugestao em questao�
		//������������������������������������������������
		If SB1->(DbSeek(xFilial("SB1")+ME8->ME8_CODPRO))

			nPrcLis := Lj843PrcV(ME8->ME8_CODPRO)
			
			//Quando alterar este retorno, alterar a vari�vel aSugest da fun��o Loja853							
			aAdd(aRetorno[nPosTab,7],{	.F.                     	   	,; //01
										SB1->B1_MSBLQL<>"1" 			,; //02
										ME8->ME8_FACIL				   	,; //03
										ME8->ME8_DESFAC				   	,; //04
		   								ME8->ME8_GRPLIS					,; //05
		   								ME8->ME8_DESGRP					,; //06
										SB1->B1_COD						,; //07
										SB1->B1_DESC					,; //08
										nPrcLis							,; //09
										ME8->ME8_QTDADE                 }) //10
		EndIf
		
		ME8->(DbSkip())
	End
	
	ME7->(DbSkip())
End

//���������������������������Ŀ
//�Fim da estrutura de arvore �
//�����������������������������
RestArea(aArea)	
Return aRetorno
                      
/*���������������������������������������������������������������������������
���Programa  �LJ853Print�Autor  �Microsiga           � Data �  07/26/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama o relatorio de sugestao de lista                      ���
�������������������������������������������������������������������������͹��
���Sintaxe   �LJ853Print(Exp01)                                           ���
�������������������������������������������������������������������������͹��
���Retorno   �Nao tem                                                     ���
�������������������������������������������������������������������������͹��
���Parametro �Exp01[A] : Array com os itens as sugestoes para o relatorio ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA853.PRW                                                 ���
���������������������������������������������������������������������������*/
Static Function LJ853Print(aSugest)

Local cRelSug := GetMv("MV_RELSUG",,"LJ853HLP")	// Rotina para execucao do relatorio de sugestao

ExecBlock(cRelSug,.F.,.F.,aSugest)

Return

/*���������������������������������������������������������������������������
���Programa  �LJ853HLP  �Autor  �Microsiga           � Data �  07/26/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao chamada quando o parametro MV_RELSUG nao esta preen- ���
���          �chido                                                       ���
�������������������������������������������������������������������������͹��
���Sintaxe   �LJ853HLP()		                                          ���
�������������������������������������������������������������������������͹��
���Retorno   �Nao tem                                                     ���
�������������������������������������������������������������������������͹��
���Parametro �Nao tem                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA853.PRW                                                 ���
���������������������������������������������������������������������������*/
User Function LJ853HLP()

Aviso("LOJA853",STR0016,{STR0017},1,STR0018)

Return()