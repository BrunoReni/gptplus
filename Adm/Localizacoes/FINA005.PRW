#INCLUDE "FINA005.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINA005  � Rev.  �Fernando Radu Muscalu  � Data �16.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de manutencao do cadastro de grupos de gestores   ���
���          �financeiros.												  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINA005()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FINA005()
Local cFilter := "FRR_ITEM = '01'"
Private cCadastro := STR0001	//"Grupo de Gestores Financeiros"
Private aRotina   := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("FRR")
dbSetOrder(1)

mBrowse( 006, 001, 022, 075, "FRR",,,,,,,,,,,,,,cFilter)

Return




/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �08/11/2006���
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
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Private aRotina	:=     {{OemToAnsi(STR0002),"AxPesqui",0,1,0,.F.},;	//"Pesquisar"
 						{OemToAnsi(STR0003),"FA005MAN",0,2,0,nil},;	//"Visualizar"
						{OemToAnsi(STR0004),"FA005MAN",0,3,0,nil},; //"Incluir"
						{OemToAnsi(STR0005),"FA005MAN",0,4,0,nil},; //"Alterar"
						{OemToAnsi(STR0006),"FA005MAN",0,5,0,nil} } //"Excluir"
//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("FA005MNU")
	ExecBlock("FA005MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA005MAN  � Rev.  �Fernando Radu Muscalu  � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao executada pelo aRotina, opcoes Visualizar, Incluir,  ���
���			 �Alterar e Excluir.  										  ���
���			 �Responsavel pela manutencao de cadastro, atraves da montagem���
���			 �da tela, das chamadas as funcoes de validacoes dos dados    ���
���			 �e da chamada da funcao que grava, altera e exclui registros ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FA005MAN(cAlias,nReg,nOpc)								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cAlias	- String: Alias da Tabela corrente ("FRR")		  ���
���			 �nReg		- Numeric: Nro do registro posicionado.			  ���
���			 �nOpc		- Numeric: Opcao de manipulacao de dados 		  ���
���			 �			2 - Visualizar 		  							  ���
���			 �			3 - Incluir 		  							  ���
���			 �			4 - Alterar 		  							  ���
���			 �			5 - Excluir 		  							  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nil									    				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAFIN													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FA005MAN(cAlias,nReg,nOpc,lAutomato)

Local nOpcA		:= 0

Local oDlg
Local oEnch
Local oMsNewGD

Local aFields	:= {"FRR_COD","FRR_DESC","FRR_MOEDA"}
Local aEditFld	:= {}
Local aPosEnch	:= {}
Local aObjects	:= {}
Local aPosObj	:= {}
Local aInfo		:= {}
Local aSizeAut	:= MsAdvSize()
Local aHeader	:= FA005HeadFRR()
Local aCols		:= FA005CargaGD(aHeader,nOpc)
Local aAlter	:= {}
Local aButtons	:= {}
Local aUsButtons:= {}

Local lInsert	:= (nOpc == 3 .or. nOpc == 4)
Local lUpdate	:= (nOpc == 3 .or. nOpc == 4)
Local lDelete	:= (nOpc == 3 .or. nOpc == 4)
Local lPreVld	:= .t.

Local bLinhaOk	:= {|lRet| 	lRet := FA005LINOK(oMsNewGd), lRet }
Local bTudoOk	:= {|lRet|	lRet := Obrigatorio(oEnch:aGets,oEnch:aTela), Iif(lRet,lRet := FA005ALLOK(oMsNewGd,nOpc),nil), lRet }
Local bDelOk	:= {|lRet|	lRet := FA005DELOK(oMsNewGd), lRet	}
Local bCancel	:= {||oDlg:End(),nOpcA := 0}
Local bUpdate	:= {|| Iif(Eval(bTudoOk),nOpcA := 1,nOpcA := 0),Iif(nOpcA == 1,oDlg:End(),nil)}

Default lAutomato	:=  .F. //Se inicializa en .T. cuando viene por automatizaci�n, en todos los dem�s casos es .F.

If ExistBlock("FA005PVD")
	lPreVld := ExecBlock("FA005PVD",.f.,.f.,{nOpc})
Endif

If !lPreVld
	Return()
Endif

If ExistBlock("FA005BTN")
	If ValType( aUsButtons := ExecBlock( "FA005BTN", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
Endif

If nOpc == 3 .or. nOpc == 4
	If nOpc == 3
		aEditFld	:= aClone(aFields)
	Endif
	aEval( aHeader, {|x| Iif(ALLTRIM(x[2]) <> "FRR_ITEM",aAdd(aAlter,x[2]),nil) } )
Endif

AAdd( aObjects, { 000, 025, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })

aInfo  		:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj		:= MsObjSize( aInfo, aObjects )
aPosEnch	:= {aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]}

RegToMemory(cAlias,(nOpc == 3),.T.,.T.)
If !lAutomato
DEFINE MSDIALOG oDlg TITLE STR0001 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] PIXEL OF oMainWnd //"Cadastro de Grupo de Gestores"

oEnch := MsMGet():New(cAlias,nReg,nOpc,,,STR0001,aFields,aPosEnch,aEditFld,,,,,oDlg,,,.F.) //"Cadastro de Grupo de Gestores"
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oMsNewGD := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],GD_INSERT+GD_UPDATE+GD_DELETE,"AllwaysTrue","AllwaysTrue","+FRR_ITEM",aAlter,,999,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeader,aCols)


oMsNewGD:bLinhaOk	:= bLinhaOk  
oMsNewGD:bDelOk		:= bDelOk

oMsNewGD:lInsert 	:= lInsert
oMsNewGD:lUpdate 	:= lUpdate
oMsNewGD:lDelete 	:= lDelete
Endif



IF !lAutomato
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bUpdate,bCancel,,aButtons) CENTERED
Else
	oMsNewGD	:= R_MSRoboGetDados():New(@aHeader,@aCols)
	aHeader 	:= oMsNewGD:aHeader
	aCols 		:= oMsNewGD:aCols
	nOpcA := 1
Endif
If nOpcA == 1
	Begin Transaction
		FA005GRV(nOpc,oMsNewGD,lAutomato)
		ConfirmSx8()
	End Transaction
Else
	RollbackSX8()
Endif

Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FA005HeadFRR� Rev.  �Fernando Radu Muscalu  � Data �16.03.2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Campos para composicao do objeto MsNewGetDados.			   	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �FA005HeadFRR()                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�nenhum			                                            ���
���������������������������������������������������������������������������Ĵ��
���Retorno	 �aRetHead	- Array: Campos do Header da MsNewGetDados        	���
���          �	aRetHead[n,01]- Char: Titulo do Campo			        	���
���          �	aRetHead[n,02]- Char: Nome do Campo	(Ex: FRR_CODGES)       	���
���          �	aRetHead[n,03]- Char: Mascara do Campo				       	���
���          �	aRetHead[n,04]- Char: Tamanho do Campo 				       	���
���          �	aRetHead[n,05]- Char: Decimal do Campo				       	���
���          �	aRetHead[n,06]- Char: Validacao de sistema do campo       	���
���          �	aRetHead[n,07]- Char: Campo Usado					       	���
���          �	aRetHead[n,08]- Char: Tipo de campo					       	���
���          �	aRetHead[n,09]- Char: Consulta padrao				       	���
���          �	aRetHead[n,10]- Char: Contexto do campo				       	���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    	���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FA005HeadFRR()

Local aRetHead	:= {}
Local aAreaSX3	:= SX3->(GetArea())

Local cNoFields	:= "FRR_FILIAL|FRR_COD|FRR_DESC|FRR_MOEDA"

SX3->(dbSetOrder(1))

SX3->(DBSeek("FRR"))

While SX3->(!EOF()) .And. (SX3->X3_ARQUIVO == "FRR")

	IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !(alltrim(SX3->X3_CAMPO) $ cNoFields)
		AADD(aRetHead,{ TRIM(x3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_F3,;
						SX3->X3_CONTEXT } )
	EndIf

	SX3->(dbSkip())
EndDo

RestArea(aAreaSX3)

Return(aRetHead)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FA005CargaGD� Rev.  �Fernando Radu Muscalu  � Data �16.03.2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Carga dos dados para o aCols do objeto MsNewGetDados.		   	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �FA005CargaGD(aHeadGD,nOpc)                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�aHeadGd	- Array: aHeader do objeto MsNewGetDados            ���
���          �nOpc		- Numeric: opcao da manipulacao de dados            ���
���          �			2 - Visualizacao						            ���
���          �			3 - Inclusao							            ���
���          �			4 - Alteracao							            ���
���          �			5 - Exclusao							            ���
���������������������������������������������������������������������������Ĵ��
���Retorno	 �aRetCols	- Array: aCols preenchida da MsNewGetDados        	���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    	���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FA005CargaGD( aHeadGD, nOpc )

Local cChave	:= ""

Local nI		:= 0

Local aRetCols	:= {}
Local aAux		:= {}
Local aAreaFRR	:= {}

If nOpc == 3
	aAdd( aRetCols, array( len(aHeadGD) + 1 ) )

	For nI  := 1 to len(aHeadGD)
		If Alltrim(aHeadGD[nI,2]) == "FRR_ITEM"
			aRetCols[len(aRetCols),nI] := strzero(1,TAMSX3("FRR_ITEM")[1])
		Else
			aRetCols[len(aRetCols),nI] := CriaVar(aHeadGD[nI,2])
		Endif
	Next nI

	aRetCols[len(aRetCols),len(aHeadGD) + 1] := .f.
Else

   	aAreaFRR := FRR->(GetArea())
   	cChave := xFilial("FRR") + Padr(FRR->FRR_COD,TamSX3("FRR_COD")[1])

	FRR->(DbSetOrder(1))

	If FRR->(DbSeek(cChave))

		While FRR->(!Eof()) .AND. cChave == FRR->FRR_FILIAL + Padr(FRR->FRR_COD,TamSX3("FRR_COD")[1])

			For nI := 1 to len(aHeadGD)
				If aHeadGD[nI,10] != "V"
					aAdd(aAux,FRR->&(aHeadGD[nI,2]))
				Else
					If AllTrim(aHeadGD[nI,2]) == "FRR_NOME"
				   		aAdd( aAux, UsrFullName( FRR->FRR_USER ) )
				 	EndIf
				EndIf
			Next nI

			aAdd(aAux,.f.)
			aAdd(aRetCols,aAux)
			aAux := {}
			FRR->(dbSkip())
		EndDo

	Endif

	RestArea(aAreaFRR)
Endif

Return(aRetCols)


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FA005LINOK  � Rev.  �Fernando Radu Muscalu  � Data �16.03.2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da linha do objeto MsNewGetDados.				   	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �FA005LINOK(oGetDados,nLin)                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�oGetDados	- objeto: instancia de MsNewGetDados            	���
���          �nLin		- Numeric: Nro da Linha do array aCols do objeto    ���
���������������������������������������������������������������������������Ĵ��
���Retorno	 �lRet	- Boolean: Se a linha foi validada			         	���
���       	 �		.t. - linha validada									���
���       	 �		.f. - linha invalidada									���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    	���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function FA005LINOK(oGetDados,nLin)

Local lRet		:= .t.

Local nI		:= 0
Local nX		:= 0
Default nLin	:= oGetDados:nAt

If !oGetDados:aCols[nLin,len(oGetDados:aHeader)+1]
	For nI := 1 to Len(oGetDados:aCols[nLin])-1

		If Alltrim(oGetDados:aHeader[nI,2]) == "FRR_CODGES"
			For nX := 1 to len(oGetDados:aCols)
				If !oGetDados:aCols[nX,len(oGetDados:aHeader)+1]
					If nX <> nLin
						If oGetDados:aCols[nX,nI] == oGetDados:aCols[nLin,nI]
							Help(" ",1,"FA005LINOK",,STR0007 + alltrim(oGetDados:aCols[nLin,nI]) + STR0008 + strzero(nI,3),1,0) //"O Gestor selecionado, "#", � o mesmo que da linha "
							lRet := .f.
							Exit
						Endif
					Endif
				Endif
			Next nX
		Endif

	Next nI
Endif

If lRet
	If ExistBlock("FA005LOK")
		lRet := ExecBlock("FA005LOK",.f.,.f.,{nLin,oGetDados})
	Endif
Endif
Return(lRet)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FA005ALLOK  � Rev.  �Fernando Radu Muscalu  � Data �16.03.2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao do formulario de cadastro de grupo de gestores.   	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �FA005ALLOK(oGetDados,nOpcao)                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros�oGetDados	- objeto: instancia de MsNewGetDados            	���
���			 �nOpcao	- Numeric: Opcao de manipulacao de dados 		    ���
���			 �				2 - Visualizar 		  							���
���			 �				3 - Incluir 		  							���
���			 �				4 - Alterar 		  							���
���			 �				5 - Excluir 		  							���
���������������������������������������������������������������������������Ĵ��
���Retorno	 �lRet	- Boolean: Se o formulario foi validado			        ���
���       	 �		.t. - formulario validado								���
���       	 �		.f. - formulario invalidado								���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    	���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FA005ALLOK( oGetDados, nOpcao )

Local lRet		:= .T.
Local nI		:= 0
Local nX		:= 0
Local nDel		:= 0
Local aAreaFRR	:= FRR->(GetArea())
Local nPos      := aScan( oGetDados:aHeader, { |x| Alltrim(x[2]) $ "FRR_CODGES" } )

For nI := 1 to len(oGetDados:aCols)

	If nOpcao == 3 .or. nOpcao == 4

		If !oGetDados:aCols[nI,len(oGetDados:aHeader)+1]

			For nX := 1 to len(oGetDados:aHeader)
				If oGetDados:aHeader[nX,17] .Or. nX == nPos
					If Empty(oGetDados:aCols[nI,nX])
						Help( oGetDados:aHeader[nX,2], 1, "OBRIGAT" )
						lRet := .f.
						Exit
					Endif
				Endif
			Next nX

			If lRet
				lRet := FA005LINOK(oGetDados,nI)
			Endif

			If !lRet
				Exit
			Endif

		Else
			nDel++
		Endif

		If lRet
			If nDel == len(oGetDados:aCols)
				lRet := .f.
				Help( " ", 1, "FA005ALLOK", , STR0009, 1, 0 )	//"Todos os itens foram exclu�dos."
			Endif
		Endif

	Elseif nOpcao == 5

		lRet := FA005DELOK(oGetDados,nI)

		If !lRet
			Exit
		Endif
	Endif
Next nI

If lRet
	If ExistBlock("FA005VOK")
		lRet := ExecBlock("FA005VOK",.f.,.f.,{nOpcao,oGetDados})
	Endif
Endif

RestArea(aAreaFRR)
Return(lRet)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FA005DELOK  � Rev.  �Fernando Radu Muscalu  � Data �16.03.2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da exclusao da linha do objeto MsNewGetDados.   	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �FA005DELOK(oGetDados,nLin)                             	    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�oGetDados	- objeto: instancia de MsNewGetDados            	���
���          �nLin		- Numeric: Nro da Linha do array aCols do objeto    ���
���������������������������������������������������������������������������Ĵ��
���Retorno	 �lRet	- Boolean: Se exclusao da linha foi validada			���
���       	 �		.t. - exclusao da linha validada						���
���       	 �		.f. - exclusao da linha invalidada						���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    	���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FA005DELOK(oGetDados,nLin)

Local lRet		:= .t.

Local nPGes		:= aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == "FRR_CODGES" })
Local nPNome	:= aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == "FRR_NOME" })
Local aSaldo	:= {}

Default nLin	:= oGetDados:nAt

//Para se retornar as movimentacoes de todo o periodo ate a data atua, nao deve informar a data no parametro 2 da funcao abaixo.
//Como ha uma necessidade de checar se ha movimentacoes para este aprovador, diferente de saldo inicial, omiti o parametro data.
aSaldo := fXAlcSld(FRR->FRR_MOEDA,,oGetDados:aCols[nLin,nPGes])

If FXALCCHKTP(aSaldo,"2|3|4|5")//CHECA SE EXISTE MOVIMENTACAO PARA OS TIPOS DE SALDO PARAMETRIZADOS
	lRet := .f.
	Help(" ",1,"FA005DELOK",,STR0010 + Alltrim(oGetDados:aCols[nLin,nPNome]) + STR0011,1,0) //"O Aprovador "#" possui movimenta��es al�m do SALDO INICIAL."
Endif

If lRet
	If ExistBlock("FA005DLN")
		lRet := ExecBlock("FA005DLN",.f.,.f.,{nLin,oGetDados})
	Endif
Endif

Return(lRet)

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �FA005VLDNV	� Rev.  �Fernando Radu Muscalu  � Data �24.03.2011���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Validacoes para o nivel do gestor do grupo.					  ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �FA005VLDNV()												      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�nenhum													   	  ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �lRet	- Boolean: Retorna a validacao do Nivel.				  ���
���			 �					moeda.										  ���
���			 �					.t. - Nivel validado					      ���
���			 �					.f. - Nivel invalidado		    			  ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      �Tabela FRR, validacoes de campos (X3_VALID)		              ���
���			 �	- FRR_NIVEL													  ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Function FA005VLDNV()

Local lRet	:= .t.

If Substr(ReadVar(),4) == "FRR_NIVEL"

	If !(IsDigit(M->FRR_NIVEL)) .OR. Empty(M->FRR_NIVEL)
		M->FRR_NIVEL := "00"
	Endif

	If Val(M->FRR_NIVEL) < 0 .or. Val(M->FRR_NIVEL) > 99
		lRet := .f.
	Endif
Endif

If lRet
	If len(alltrim(M->FRR_NIVEL)) == 1
		M->FRR_NIVEL := "0"+alltrim(M->FRR_NIVEL)
	Endif
Endif

Return(lRet)


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �FA005TRIGG	� Rev.  �Fernando Radu Muscalu  � Data �24.03.2011���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para retorna conteudo do contra-dominio de acordo com	  ���
���          �parametro														  ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �FA005TRIGG(cCampo)										      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�cCampo	-String: Campo contra-dominio do gatilho			  ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �xRetTrigger	- Any: Retorna conteudo do campo de contra-dominio���
�����������������������������������������������������������������������������Ĵ��
��� Uso      �Gatilhos para o arquivo FRR, Regras do gatilho (X7_REGRA)		  ���
���			 �	- FRR_CODGES Sequencia 001									  ���
���			 �	- FRR_CODGES Sequencia 002									  ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Function FA005TRIGG(cCampo)

Local cChave1 := xFilial("FRP") + PadR(M->FRR_CODGES,TamSX3("FRP_COD")[1]) + PadR(M->FRR_MOEDA,TAMSX3("FRP_MOEDA")[1])
Local xRetTrigger := FRP->(GetAdvFVal("FRP",cCampo,cChave1,1,""))

Return(xRetTrigger)


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �FA005GRV		� Rev.  �Fernando Radu Muscalu  � Data �24.03.2011���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de atualizacao do arquivo FRR.						      ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �FA005GRV(nOpcao,oGetDados)								      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�nOpcao	- Numeric: Opcao de manipulacao de dados de aRotina   ���
���          �				3 - Inclusao    								  ���
���          �				4 - Alteracao    								  ���
���          �				5 - Exclusao    								  ���
���          �oGetDados	- Objeto: Instancia de MsNewGetDados				  ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �Nil.														      ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAFIN										                  ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Function FA005GRV(nOpcao,oGetDados,lAutomato)

Local nI	:= 0
Local nX	:= 0

Local cChave1	:= ""

Local lInsert	:= .f.
Local lExcPE	:= .t.
Default lAutomato	:= .F. //Se inicializa en .T. cuando viene por automatizaci�n, en todos los dem�s casos es .F.

   If lAutomato  .and. (nOpcao == 3 .OR. nOpcao == 4)
      If FindFunction ("GetParAuto")  // Tratamiento para scripts automatizados
         aRetAuto  := GetParAuto("FINA005TESTCASE")
         M->FRR_DESC 	:= aRetAuto[1]
         M->FRR_MOEDA 	:= aRetAuto[2]  
         oGetDados:aCols:= aRetAuto[3] 
         
         	
     Endif
   Endif

For nI := 1 to  len(oGetDados:aCols)

	cChave1 := xFilial("FRR") +;
				PadR(M->FRR_COD,TamSx3("FRR_COD")[1]) +;
				PadR(M->FRR_MOEDA,TamSx3("FRR_MOEDA")[1]) +;
				PadR(oGetDados:aCols[nI,1],TamSx3("FRR_ITEM")[1])

	FRR->(DbSetOrder(1))

	lSeek := FRR->(DbSeek(cChave1))

	Do Case
		Case nOpcao == 3 .OR. nOpcao == 4

			If nOpcao == 3 .Or. !lSeek
				lInsert := .t.
			Else
				lInsert := .f.
			Endif

			If !oGetDados:aCols[nI,len(oGetDados:aHeader)+1]

				RecLock("FRR",lInsert)

				If lInsert
					FRR->FRR_FILIAL	:= xFilial("FRR")
					FRR->FRR_COD	:= M->FRR_COD
					FRR->FRR_DESC	:= M->FRR_DESC
					FRR->FRR_MOEDA	:= M->FRR_MOEDA
                Endif

				For nX := 1 to len(oGetDados:aHeader)
					FRR->&(oGetDados:aHeader[nX,2]) := oGetDados:aCols[nI,nX]
				Next nX

				FRR->(MSUnlock())

			Else
				If lSeek
					RecLock("FRR",.F.)
						FRR->(DbDelete())
					FRR->(MsUnlock())
				Endif
			Endif

		Case nOpcao == 5
			If lSeek

				If ExistBlock("FA005DEL")
					lExcPE := ExecBlock("FA005DEL",.f.,.f.)
				Endif

				If lExcPE
					RecLock("FRR",.F.)
						FRR->(DbDelete())
					FRR->(MsUnlock())
				Endif

			Endif
	End Case
Next nI

If nOpcao == 3 .or. nOpcao == 4
	If ExistBlock("FA5GRAVA")
		ExecBlock("FA5GRAVA",.f.,.f.,{nOpcao})
	Endif
Endif

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � F005VldCpo � Autor � Danilo Dias      � Data � 11/07/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se o campo digitado na MsGetDados j� existe e se o  ���
���          � mesmo foi deletado.                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Geral                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function F005VldCpo( cAlias, cCampo )

Local aArea      := GetArea()
Local lRet       := .T.
Local nI         := 1
Local aCHeader   := aClone(aHeader)
Local aCCols     := aClone(aCols)
Local nLenCols   := Len(aCCols)
Local nLenHeader := Len(aCHeader)
Local nPosHeader := aScan( aCHeader, { |nPos| AllTrim(nPos[2]) == cCampo } )

For nI := 1 To ( nLenCols - 1 )
	If !(aCCols[nI,nLenHeader+1]) .And. AllTrim(aCCols[nI,nPosHeader]) == &( 'M->' + cCampo )
		lRet := .F.
		Help( " ", 1, "F005VldCpo", , STR0013, 1, 0 )	//"Registro j� gravado!"
		Exit
	EndIf
Next nI

RestArea(aArea)

Return lRet
