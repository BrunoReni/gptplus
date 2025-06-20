#INCLUDE "QIEA100.CH" 
#INCLUDE "PROTHEUS.CH"
#DEFINE  K_F4    VK_F4

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA100  � Autor � Vera Lucia S. Simoes  � Data � 09/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de funcoes da amarracao Produto X Fornecedor e    ���
���          � Cadastro de Fornecedores                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� STR      � Ultimo utilizado -> 0011                                   ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�15/09/00�META  �Implementacao do Plano de Amostragem por  ���
���            �        �      �Ensaios                                   ���
���Paulo Emidio�12/02/01�008009�Retirada da chamada da funcao Qea330aCol()���
���            �        �      �na aA100WhSi(), para que o aCols nao seja ���
���            �        �      �remontado, quando alterada a situacao do  ���
���            �        �      �Fornecedor. 							  ���
���Paulo Emidio�08/05/01�META  �Implementacao do parametro MV_UTSK25, que ���
���            �        �      �indica se o Skip-Lote de 25% sera aplicado���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIEA100


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100VlSi � Autor � Vera Lucia S. Simoes  � Data � 09/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Situacao                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100VlSi()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Cad. Prod X Fornecedor X3_VALID do A5_SITU                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A100VlSi()
Local lRetu      := .t.
Local cVar  	 := &(ReadVar())
Local lVerIQSQua := .F.
Local nMvIQSQua  := GetMv("MV_QIQSQUA")
Local nRecQEG                                                               
Local nMvIQSAss  := GetMv("MV_QIQSASS") //IQS minimo para Situacao Assegurado
Local lSkpLteAss := If(GetMv("MV_QASSIQS")=="S",.T.,.F.) 
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oField := oModel:GetModel("MdFieldSA5")
	oGrid  := oModel:GetModel("MdGridSA5")
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se a Situacao est� cadastrada                       �
//����������������������������������������������������������������
cVar := UPPER(cVar)
If ! ExistCpo("QEG",cVar)
	lRetu := .f.
EndIf

If lRetu

	// Identifica a Categoria da Situacao
	QEG->(dbSetOrder(1))
	QEG->(dbSeek(xFilial("QEG")+cVar))

	// Localiza o Fornecedor
	SA2->(dbSetOrder(1))
	If l060MVC
		SA2->(dbSeek(xFilial("SA2")+oGrid:GetValue("A5_FORNECE")+oGrid:GetValue("A5_LOJA")))
	Else
		SA2->(dbSeek(xFilial("SA2")+M->A5_FORNECE+M->A5_LOJA))
	Endif

	//��������������������������������������������������������������Ŀ
	//� Verifica se a Situacao pode ser Skip-Lote Total              �
	//����������������������������������������������������������������
	If QEG->QEG_CATEG == "1" .And. (SA2->A2_FATAVA == 0 .Or. Empty(SA2->A2_DTAVA))
		If !lSkpLteAss					// "Fornecedor pode ser Skip-Lote Total sem IQS"
			Help(" ",1,"A100ASSIQS")	// "Situacao nao permitida: Fornecedor nao possui IQS"
			lRetu := .f.
		EndIf
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Verifica se a Situacao pode ser Skip-Lote 25%                �
	//����������������������������������������������������������������
	If lRetu
		// Verifica se existe Situacao c/ Categoria "3" - Sem Skip-Lote
		nRecQEG := QEG->(Recno())
		QEG->(dbSetOrder(1))
		QEG->(dbSeek(xFilial("QEG")))
		While QEG->QEG_FILIAL == xFilial("QEG") .And. !QEG->(Eof())
			If QEG->QEG_CATEG == "3"
				lVerIQSQua := .T.
				Exit
			EndIf
			QEG->(dbSkip())
		EndDo
		QEG->(dbGoTo(nRecQEG))

		If QEG->QEG_CATEG == "1" .And. nMvIQSAss > 0	// "IQS minimo p/ Assegurado"
			If (SA2->A2_FATAVA < nMvIQSAss) .And. !lSkpLteAss
				Help(" ",1,"A100IQSASS") // "Nota IQS menor que a minima para esta Situacao"
				lRetu := .f.
			EndIf
		EndIf
		If lVerIQSQua .And. ;
				QEG->QEG_CATEG == "2" .And. nMvIQSQua > 0	// "IQS minimo p/ Qualificado"
			If ( Empty(SA2->A2_FATAVA) .And. Empty(SA2->A2_DTAVA) ) .Or. ;
				( !Empty(SA2->A2_FATAVA) .And. SA2->A2_FATAVA < nMvIQSQua )
				Help(" ",1,"A100IQSQUA")	// "Nota IQS menor que a minima para esta Situacao"
				lRetu := .f.
			EndIf
		EndIf
	EndIf
EndIf

If l060MVC
	oGrid:LoadValue("A5_SITU",cVar)
Else
	M->A5_SITU := cVar
EndIf

Return(lRetu)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100VlSL � Autor � Vera Lucia S. Simoes  � Data � 13/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Skip-Lote                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100VlSL()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Cad. Prod X Fornecedor X3_VALID do A5_SKPLOT               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A100VlSL()
Local lRetu := .t.
Local cVar := &(ReadVar())	// Campo Skip-Lote   
Local cMvUtSk25 := GetMv("MV_QUTSK25")// Define se sera utilizado o Skip-Lote de 25%
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oField := oModel:GetModel("MdFieldSA5")
	oGrid  := oModel:GetModel("MdGridSA5")
Endif
//��������������������������������������������������������������Ŀ
//� Verifica se o Skip-Lote est� cadastrado                      �
//����������������������������������������������������������������
If !Empty(cVar)
	If ! ExistCpo("QEF",cVar)
		lRetu := .f.
	EndIf
EndIf	

If lRetu
	// Identifica a Categoria da Situacao
	QEG->(dbSetOrder(1))
	If l060MVC		
		QEG->(dbSeek(xFilial("QEG")+oGrid:GetValue("A5_SITU")))
	Else	
		QEG->(dbSeek(xFilial("QEG")+M->A5_SITU))
	Endif

	//��������������������������������������������������������������Ŀ
	//� Verifica se a categoria Situacao � Skip-Lote 25%             �
	//����������������������������������������������������������������
	If QEG->QEG_CATEG == "2"
		QEF->(dbSetOrder(1))
		QEF->(dbSeek(xFilial("QEF")+cVar))
		If QEF->QEF_UNSKLT == "E"	// Skip-Lote por Entradas
			If cMvUtSk25 == "S"
			If QEF->QEF_QTDE > 4
				Help(" ",1,"A100SKLINV")	// "Skip-Lote n�o permitido para a Situa��o"
				lRetu := .f.
				EndIf              
			EndIf
		ElseIf QEF->QEF_UNSKLT <> "L"	// Skip-Lote por Documento Entrada
			Help(" ",1,"A100SKLINV")	// "Skip-Lote n�o permitido para a Situa��o"
			lRetu := .f.
		EndIf
	EndIf
EndIf

Return(lRetu)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100VlTL � Autor � Vera Lucia S. Simoes  � Data � 14/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Tempo Limite                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100VlTL()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Cad. Prod X Fornecedor X3_VALID do A5_TEMPLIM              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A100VlTL()
Local lRetu := .t., nPosTL,;
		cVar := &(ReadVar())	// Campo Tempo Limite
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oModel	  := FWModelActive()
	oField 	  := oModel:GetModel("MdFieldSA5")
	oGrid	  := oModel:GetModel("MdGridSA5")
Endif

//�����������������������������������������������������������������Ŀ
//� Verifica o Skip-Lote definido e se o fonte MATA060 est� em MVC  �
//�������������������������������������������������������������������
If l060MVC
	If !Empty(oGrid:GetValue("A5_SKPLOT"))
		QEF->(dbSetOrder(1))
		QEF->(dbSeek(xFilial("QEF")+oGrid:GetValue("A5_SKPLOT")))
		If QEF->QEF_UNSKLT == "D"	// Skip-Lote por Dia
			If oGrid:GetValue("A5_TEMPLIM") <= (QEF->QEF_QTDE / 30)	// Tempo Lim. � em meses e skip-lote em dias
				// Somente avisa
				Help(" ",1,"A100TLMAIO")	// "Tempo limite deveria ser maior que o Skip-Lote"
			EndIf
		EndIf
	Endif

	If Type("aGets")=="A"
		// Atualiza M e aTela pq. o Help exibe na tela o valor anterior
		oGrid:LoadValue("A5_TEMPLIM",cVar)
		nPosTL := Ascan(aGets,{ |x| Subs(x,9,10) == "A5_TEMPLIM" } )
		If nPosTL > 0
			aTela[Val(Subs(aGets[nPosTL],1,2))][Val(Subs(aGets[nPosTL],3,1))*2] := oGrid:GetValue("A5_TEMPLIM")
		EndIf
	EndIf
Else
	If !Empty(M->A5_SKPLOT)
		QEF->(dbSetOrder(1))
		QEF->(dbSeek(xFilial("QEF")+M->A5_SKPLOT))
		If QEF->QEF_UNSKLT == "D"	// Skip-Lote por Dia
			If M->A5_TEMPLIM <= (QEF->QEF_QTDE / 30)	// Tempo Lim. � em meses e skip-lote em dias
				// Somente avisa
				Help(" ",1,"A100TLMAIO")	// "Tempo limite deveria ser maior que o Skip-Lote"
			EndIf
		EndIf
	EndIf

	If Type("aGets")=="A"
		// Atualiza M e aTela pq. o Help exibe na tela o valor anterior
		M->A5_TEMPLIM := cVar
		nPosTL := Ascan(aGets,{ |x| Subs(x,9,10) == "A5_TEMPLIM" } )
		If nPosTL > 0
			aTela[Val(Subs(aGets[nPosTL],1,2))][Val(Subs(aGets[nPosTL],3,1))*2] := M->A5_TEMPLIM
		EndIf
	EndIf
EndIf

Return(lRetu)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100WhSi � Autor � Vera Lucia S. Simoes  � Data � 09/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Def. a clausula WHEN para o campo Situacao                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100WhSi()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Cad. Prod X Fornecedor X3_WHEN do A5_SITU                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A100WhSi()
Local lRetu := .T.
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oModel		  := FWModelActive()
	oField  	  := oModel:GetModel("MdFieldSA5")
	oGrid		  := oModel:GetModel("MdGridSA5")
Endif

If ReadVar() == "M->A5_SITU"
	//��������������������������������������������������������������Ŀ
	//� Verifica se digitou o Produto e o Fornecedor                 �
	//����������������������������������������������������������������
	If l060MVC
		If Empty(oGrid:GetValue("A5_FORNECE")) .Or. Empty(oField:GetValue("A5_PRODUTO")) .Or. Empty(oGrid:GetValue("A5_LOJA"))
			Help(" ",1,"A100VAZPRF")	// "Informe primeiramente o Produto e o Fornecedor"
			lRetu := .F.
		EndIf
	Else
		If Empty(M->A5_FORNECE) .Or. Empty(M->A5_PRODUTO) .Or. Empty(M->A5_LOJA)
			Help(" ",1,"A100VAZPRF")	// "Informe primeiramente o Produto e o Fornecedor"
			lRetu := .F.
		EndIf
	Endif
	If lRetu
		//����������������������������������������������������������Ŀ
		//� Ativa tecla F4 para visualizar o Historico               �
		//������������������������������������������������������������
		SetKey(K_F4, {|a,b,c| A100Choi(a,b,c) } )
	EndIf
EndIf

Return(lRetu)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100WhSL � Autor � Vera Lucia S. Simoes  � Data � 09/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Def. a clausula WHEN para o campo Skip-Lote                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100WhSL()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Cad. Prod X Fornecedor X3_WHEN do A5_SKPLOT                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A100WhSL()
Local lRetu	  := .T. 
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oModel		  := FWModelActive()
	oField  	  := oModel:GetModel("MdFieldSA5")
	oGrid		  := oModel:GetModel("MdGridSA5")
Endif

If ReadVar() == "M->A5_SKPLOT"
	//��������������������������������������������������������������Ŀ
	//� Verifica se digitou a Situacao                               �
	//����������������������������������������������������������������
	If l060MVC
		If Empty(oGrid:GetValue("A5_SITU"))
			Help(" ",1,"A100VAZSIT")	// "Informe primeiramente a Situacao"
			lRetu := .f.
		EndIf
	Else
		If Empty(M->A5_SITU)
			Help(" ",1,"A100VAZSIT")	// "Informe primeiramente a Situacao"
			lRetu := .f.
		EndIf
	Endif	
	If lRetu
		//��������������������������������������������������������������Ŀ
		//� Categoria da Situacao Sem Skip-Lote/Nao Recebe: nao digita   �
		//����������������������������������������������������������������
		// Identifica a Categoria da Situacao
		If l060MVC
			QEG->(dbSetOrder(1))
			QEG->(dbSeek(xFilial("QEG")+oGrid:GetValue("A5_SITU")))
		Else
			QEG->(dbSetOrder(1))
			QEG->(dbSeek(xFilial("QEG")+M->A5_SITU))
		Endif

		If l060MVC
			If QEG->QEG_CATEG $ "3.4"
				oGrid:LoadValue("A5_SKPLOT",Space(TamSx3("A5_SKPLOT")[1]))
				lRetu := .f.
			EndIf
		Else
			If QEG->QEG_CATEG $ "3.4"
				M->A5_SKPLOT:= Space(TamSx3("A5_SKPLOT")[1])
				lRetu := .f.
			EndIf
		Endif
	EndIf
	If lRetu
		//����������������������������������������������������������Ŀ
		//� Ativa tecla F4 para visualizar o Historico               �
		//������������������������������������������������������������
		SetKey(K_F4, {|a,b,c| A100Choi(a,b,c) } )
	EndIf
EndIf
Return(lRetu)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100WhTL � Autor � Vera Lucia S. Simoes  � Data � 02/02/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Def. a clausula WHEN p/ Tempo Limite s/ Entradas           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100WhTL()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Cad. Prod X Fornecedor X3_WHEN do A5_TEMPLIM               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A100WhTL()
Local lRetu := .T.
Return(lRetu)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100Choi � Autor � Vera Lucia S. Simoes  � Data �11/18/1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta opcao para escolha do Historico/Consulta de Ensaios  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEA100 (Utilizado na Amarr. ProdutoXFornecedor)           ���
�������������������������������������������������������������������������Ĵ��
���Str       � Ultimo Utilizado -> 0010                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A100Choi( cAlias, nReg, nOpcX )

A100Hist(cAlias,nReg,nOpcX)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100Hist � Autor � Vera Lucia S. Simoes  � Data � 13/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Mostra o Historico da Situacao do Produto/Fornecedor       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A100Hist()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA100 - Acionada a partir de F4 nos cpos Situacao, Skip- ���
���          �           Lote e Planos de Amostragem                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A100Hist()
Local cChvHis  := ""
Local cVar     := ReadVar()
Local cTit     := ""
Local cEspecie := ""
Local oDlg 
Local oListBox
Local aHist := {}
Local cAnt	:= ""

// Define a Especie e o Titulo do Historico
If cVar == "M->A5_SITU"	// Situacao
	cEspecie := "MATA060T"
	cTit		:= OemToAnsi(STR0002)	// "   Hist�rico Situa��o    	"
ElseIf cVar == "M->A5_SKPLOT"	// Skip-Lote
	cEspecie := "MATA060L"
	cTit		:= OemToAnsi(STR0003)	// "   Hist�rico Skip-Lote   "

EndIf

If !Empty(cEspecie)
	// Obtem chave para o Historico/Justificativa
	cChvHis := SA5->A5_CHAVE

  	//�����������������������������Ŀ
	//� Monta vetor com o Historico �
	//�������������������������������
	dbSelectArea("QA3")
	QA3->(dbSetOrder(1))
	dbSeek(xFilial("QA3")+cEspecie+cChvHis)

	While ( !QA3->(Eof()) .And. xFilial("QA3") == QA3->QA3_FILIAL .And.;
				QA3->QA3_ESPEC == cEspecie .And. ;
				QA3->QA3_CHAVE == cChvHis )

		// Se for Situacao ou Skip-Lote, mostra a descricao
		If cVar == "M->A5_SITU"	// Situacao
			QEG->(dbSetOrder(1))
			QEG->(dbSeek(xFilial("QEG")+Left(QA3->QA3_ANT,TamSX3("QEG_SITU")[1])))
			cAnt := QEG->QEG_NIVEL
		Elseif  cVar == "M->A5_SKPLOT"	// Skip-Lote
			QEF->(dbSetOrder(1))
			QEF->(dbSeek(xFilial("QEF")+Left(QA3->QA3_ANT,TamSX3("QEF_SKPLOT")[1])))
			cAnt := QEF->QEF_DESCRI
		Else
			cAnt := QA3->QA3_ANT
		EndIf

		Aadd(aHist, { cAnt, QA3->QA3_TEXTO, QA3->QA3_DATA })
      QA3->(dbSkip())
	EndDo

	//��������������������������������������������������������������Ŀ
	//� Verifica se h� historico a ser exibido                       �
	//����������������������������������������������������������������
	If Empty(aHist)
		Help(" ",1,"A100NAOHIS")	// "Nao h� Historico registrado"
	Else
		DEFINE MSDIALOG oDlg FROM  18,16 TO 246,561 TITLE cTit PIXEL

		@ 0.3,0.3 LISTBOX oListBox FIELDS HEADER TitSX3("QA3_ANT")[1] ,;
														 TitSX3("QA3_TEXTO")[1],;
														 TitSX3("QA3_DATA")[1];
														 SIZE 240,100 OF oDlg
		oListBox:SetArray( aHist )
		oListBox:bLine := { || {aHist[oListBox:nAT,1],aHist[oListBox:nAT,2],Dtoc(aHist[oListBox:nAT,3])}}

		DEFINE SBUTTON FROM 05, 243 TYPE 1 ENABLE OF oDlg Action (oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED
	Endif
EndIf
Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A100CoEn � Autor � Vera Lucia S. Simoes  � Data �11/18/1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta os ensaios do Produto com seus respectivos Planos ���
���          � de Amostragem.                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEA100 - A100Choi - Acionada pelo F4 nos campos Plano Amo.���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A100CoEn( )
Local oDlg 
local oListBox
Local cRevi
Local aEnsa	:= {}

//���������������������������������Ŀ
//� Identifica a revisao do Produto �
//�����������������������������������
cRevi := QA_UltRevEsp(M->A5_PRODUTO,dDataBase,.T.,,"QIE")

If Empty(cRevi)	// Nao ha revisao disponivel
	Return(NIL)
EndIf

//���������������������������������������Ŀ
//� Monta vetor com os ensaios do Produto �
//�����������������������������������������
QE7->(dbSetOrder(1))
QE7->(dbSeek(xFilial("QE7")+M->A5_PRODUTO+cRevi))
While !QE7->(Eof()) .And. QE7->QE7_FILIAL+QE7->QE7_PRODUT+QE7->QE7_REVI == ;
		xFilial("QE7")+M->A5_PRODUTO+cRevi
	If !Empty(QE7->QE7_PLAMO)
		// Busca a descricao do Ensaio
		QE1->(dbSetOrder(1))
		QE1->(dbSeek(xFilial("QE1")+QE7->QE7_ENSAIO))

		Aadd(aEnsa, { QE7->QE7_LABOR,QE7->QE7_ENSAIO,QE1->QE1_DESCPO,QE7->QE7_PLAMO })
	EndIf
	QE7->(dbSkip())
EndDo

QE8->(dbSetOrder(1))
QE8->(dbSeek(xFilial("QE8")+M->A5_PRODUTO+cRevi))
While !QE8->(Eof()) .And. QE8->QE8_FILIAL+QE8->QE8_PRODUT+QE8->QE8_REVI == ;
		xFilial("QE8")+M->A5_PRODUTO+cRevi
	If !Empty(QE8->QE8_PLAMO)
		// Busca a descricao do Ensaio
		QE1->(dbSetOrder(1))
		QE1->(dbSeek(xFilial("QE1")+QE8->QE8_ENSAIO))

		Aadd(aEnsa, { QE8->QE8_LABOR,QE8->QE8_ENSAIO,QE1->QE1_DESCPO,QE8->QE8_PLAMO })
	EndIf
	QE8->(dbSkip())
EndDo

//����������������������������������������������������Ŀ
//� Ordena ensaios de acordo com o plano de amostragem �
//������������������������������������������������������
aEnsa := aSort( aEnsa,,, {|x,y| x[4]+x[1] < y[4]+y[1] } )

//�������������������������������������Ŀ
//� Verifica se h� ensaios a apresentar �
//���������������������������������������
If Empty(aEnsa)
	MessageDlg(OemToAnsi(STR0011),,1)	// "N�o h� ensaios com Plano de Amostragem associado."
Else
	DEFINE MSDIALOG oDlg FROM  18,16 TO 246,561 TITLE STR0010 PIXEL	// "Consulta Ensaios"

	@ 0.3,0.3 LISTBOX oListBox FIELDS HEADER TitSX3("QE7_LABOR")[1] ,;
													 TitSX3("QE7_ENSAIO")[1],;
													 TitSX3("QE1_DESCPO")[1],;
													 TitSX3("QE7_PLAMO")[1];
													 SIZE 240,100 OF oDlg
	oListBox:SetArray( aEnsa )
	oListBox:bLine := { || {aEnsa[oListBox:nAT,1],aEnsa[oListBox:nAT,2],;
								aEnsa[oListBox:nAT,3],aEnsa[oListBox:nAT,4] }}

	DEFINE SBUTTON FROM 05, 243 TYPE 1 ENABLE OF oDlg Action (oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED
Endif
Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A060F3SL  � Autor � Vera Lucia S. Simoes  � Data �12/08/1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta consulta de Skip-Lote via SXB especifica              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Consulta especifica                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       �QIEA100.PRX                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A060F3SL()
Local lSitQua	:= .F.
Local lRet		:= .T.
Local cMvUtSk25 := GetMv("MV_QUTSK25") //Define se sera utiliza o Skip-Lote de 25%
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oModel		  := FWModelActive()
	oField  	  := oModel:GetModel("MdFieldSA5")
	oGrid		  := oModel:GetModel("MdGridSA5")
Endif
//�������������������������������������Ŀ
//� Identifica a categoria da Situacao  �
//���������������������������������������
QEG->(dbSetOrder(1))
QEG->(dbSeek(xFilial("QEG")+If(l060MVC,oGrid:GetValue("A5_SITU"),M->A5_SITU)))
If QEG->QEG_CATEG == "2"
	lSitQua := .T.
EndIf

//������������������������������������������������������������Ŀ
//� De acordo com os dados encontrados dispara uma consulta F3 �
//��������������������������������������������������������������
If cMvUtSk25 == "S"
	If lSitQua
		lRet := ConPad1(,,,"QS1",,,.F.)	// Consulta dos Skip-Lotes p/ Qualif (25%)
	Else
		lRet := ConPad1(,,,"QEF",,,.F.)	// Consulta de todos os Skip-Lotes
	EndIf
Else
	lRet := ConPad1(,,,"QEF",,,.F.)	// Consulta de todos os Skip-Lotes
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A100WhDA  � Autor � Vera Lucia S. Simoes  � Data �18/08/1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Sugere Data Sistema na Data da Avaliacao do Fornecedor      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATA020.PRX ( Cad. Fornecedores) - SX3(X3_WHEN) A2_DTAVA    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A100WhDA()
If ReadVar() == "M->A2_DTAVA" .And. !Empty(M->A2_FATAVA)
	M->A2_DTAVA := Iif(Empty(M->A2_DTAVA),dDataBase,M->A2_DTAVA)
EndIf
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QE100GaDA � Autor � Vera Lucia S. Simoes  � Data �26/10/1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Sugere Data Validade a partir da Data da Avaliacao          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Gatilho do A2_DTAVA (SX7)                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QE100GaDA()
Local lRet := .F.
If !Empty(M->A2_DTAVA) .And. Empty(M->A2_DTVAL)
	lRet := .T.
EndIf
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIEA100_V  � Autor � Cleber Maldonado     � Data � 25/03/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao utilizada para verificar a ultima versao do fonte   ���
���			 � QIEA100.PRW aplicado no rpo do cliente, assim verificando  ���
���			 � a necessidade de uma atualizacao neste fonte.			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � EST/PCP/FAT/COM	                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QIEA100_V()
Local nRet := 20130327 // 27 de Mar�o de 2013
Return nRet 

/*/{Protheus.doc} QE100DtAva
Gatilho do campo A2_FATAVA para preencher o campo A2_DTAVA
@author carlos capeli
@since 27/06/2018
@version 1.0
@return Date

@type function
/*/
Function QE100DtAva()

Local oModel     := FWModelActive()
Local oField     := Nil
Local l020MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "CUSTOMERVENDOR"
Local dtRet      := cToD("")

If l020MVC
	oField := oModel:GetModel("SA2MASTER")
	If !Empty(oField:GetValue("A2_FATAVA"))
		dtRet := Iif(Empty(oField:GetValue("A2_DTAVA")),dDataBase,oField:GetValue("A2_DTAVA"))
	EndIf
Else
	If !Empty(M->A2_FATAVA)
		dtRet := Iif(Empty(M->A2_DTAVA),dDataBase,M->A2_DTAVA)
	EndIf
EndIf

Return dtRet

/*/{Protheus.doc} QE100DtVal
Gatilho do campo A2_FATAVA para preencher o campo A2_DTVAL
@author carlos capeli
@since 27/06/2018
@version 1.0
@return Date

@type function
/*/
Function QE100DtVal()

Local oModel     := FWModelActive()
Local oField     := Nil
Local l020MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "CUSTOMERVENDOR"
Local dtRet      := cToD("")

If l020MVC
	oField := oModel:GetModel("SA2MASTER")
	If !Empty(oField:GetValue("A2_DTAVA"))
		dtRet := oField:GetValue("A2_DTAVA") + 365
	EndIf
Else
	If !Empty(M->A2_DTAVA)
		dtRet := M->A2_DTAVA + 365
	EndIf
EndIf

Return dtRet
