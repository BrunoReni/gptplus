#Include "QIEM010.CH"
#Include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QIEM010	� Autor � Marcelo Pimentel      � data � 19/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Duplica Especifica�oes       			  	              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAQIE													  ���
�������������������������������������������������������������������������Ĵ��
��� STR		 � Ultimo utilizado: 032                                      ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�20/04/01�META  �Gravacao do B1_TIPOCQ quando o produto for���
���            �        �      �cadastrado no SB1.						  ���
���			   �        �      �Implementacao do parametro MV_QRASTRO     ���
���Robson Ramir�14/05/01�META  �Remodelamento da Tela da Duplicacao de Pro���
���            �        �      �dutos.									  ���
���Robson Ramir�15/05/01�008439�Implementacao opcao para selecionar a ori-���
���			   �		�	   �gem da Descricao, se a mesma sera informa-���
���			   �        �      �da, ou originada do Cadastro de produtos  ���
���			   �        �      �ou Especificacao. 						  ���
���Cleber Souza�14/05/03�064155�Sugere numero da proxima revisao automati-��� 
���			   �        �      �camente na digitacao do produto.          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QIEM010()
Local oDlg
Local oCampo
Local nOpc     := 0
Local dVigRev  := dDataBase
Local bOk 	   := {||If(A010ExProd("O", .T.) .And. A010ExProd("D", .T.),((dVigRev := A010CkProd(),.T.), nOpc := 1, oDlg:End()), .F.)}
Local bCancel  := {||nOpc := 0, oDlg:End()}
Local lQEM10F3 := ExistBlock("QEM10F3")
Local lConfDup := .T.
Local oSize

//���������������������������������������������������������������������������Ŀ
//� Edicao de Dados															  �
//�����������������������������������������������������������������������������
Private aItem    := {STR0001,STR0013,STR0014,STR0003} //"Informado" ### "Produto Origem " ### "Produto Destino" ### "Especificacoes"
Private cProdOri := Space(TamSX3("B1_COD")[1])
Private cRevOri  := Space(02)
Private cProdDes := Space(TamSX3("B1_COD")[1])
Private cRevDes  := Space(02)
Private cDesPro  := Space(TamSX3("B1_DESC")[1])
Private oDesPro
Private cOriDes  := aItem[1]

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New()

oSize:AddObject( "TELA"    ,  100, 20, .T., .F. ) // Nao dimensiona Y

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0004) ; //PARAMETROS
								FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

@ oSize:GetDimension("TELA","LININI"),010 	SAY OemToAnsi(STR0005) PIXEL //"Produto Origem ?"
@ oSize:GetDimension("TELA","LININI")+15,010 	SAY OemToAnsi(STR0006) PIXEL //"Revisao Origem ?"
@ oSize:GetDimension("TELA","LININI")+30,010 	SAY OemToAnsi(STR0007) PIXEL //"Produto Destino ?"
@ oSize:GetDimension("TELA","LININI")+45,010 	SAY OemToAnsi(STR0008) PIXEL //"Revisao Destino ?"
@ oSize:GetDimension("TELA","LININI")+60,010 	SAY OemToAnsi(STR0009) PIXEL //"Descricao do Produto Destino ?"
@ oSize:GetDimension("TELA","LININI")+75,010	SAY OemToAnsi(STR0010) PIXEL //"Quanto a Descricao ?"


@ oSize:GetDimension("TELA","LININI")		,110 MSGET cProdOri Picture "@!" F3 "QE7"													SIZE 105,11 Valid QIE010UpIn()    OF oDlg PIXEL
@ oSize:GetDimension("TELA","LININI")+15	,110 MSGET cRevOri  Picture "@!"															SIZE 020,11 Valid A010ExProd("O") OF oDlg PIXEL
@ oSize:GetDimension("TELA","LININI")+30	,110 MSGET cProdDes Picture "@!" F3 If(lQEM10F3,ExecBlock("QEM10F3",.F.,.F.),"QE6")	SIZE 105,11                       OF oDlg PIXEL
@ oSize:GetDimension("TELA","LININI")+45	,110 MSGET cRevDes  Picture "@!"															SIZE 020,11 Valid A010ExProd("D") OF oDlg PIXEL

@ oSize:GetDimension("TELA","LININI")+60,110 COMBOBOX oCampo VAR cOriDes ITEMS aItem 												SIZE 150,11 OF oDlg PIXEL
oCampo:bChange :={||cDesPro:=QIE010VERIF(aItem,cOriDes),oDesPro:Refresh()}

@ oSize:GetDimension("TELA","LININI")+75,110 MSGET oDesPro VAR cDesPro Picture "@!" 												SIZE 150,11 OF oDlg PIXEL  Valid !Empty(cDesPro)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,) CENTER

// Ponto de Entrada para validar ou nao a Duplicado da Especificacao do Produto
If Existblock("QIEVALDUP")
	lConfDup := Execblock("QIEVALDUP", .F. , .F. , {cProdOri,cRevOri,cProdDes,cRevDes} )
Endif

//���������������������������������������������������������������������������Ŀ
//� Confirma a duplicacao do Produto										  �
//�����������������������������������������������������������������������������
If (nOpc == 1) .And. lConfDup 
	QIEDupEsp(cProdOri,cRevOri,cProdDes,cRevDes,cDesPro,dVigRev)
EndIf

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEDupEsp   � Autor � Paulo Emidio de Barros�Data�14/04/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Duplica a Especificacao de Produtos						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIEDupEsp(EXPC1,EXPC2,EXPC3,EXPC4,EXPC5,EXPD1)		  	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �	EXPC1 = Produto Origem									  ���
���		  	 �	EXPC2 =	Revisao Origem									  ���
���			 �	EXPC3 =	Produto Destino									  ���
���			 �	EXPC4 =	Revisao Destino									  ���
���			 �	EXPC5 =	Descricao Destino								  ���
���			 �	EXPD1 =	Vigencia da Especificacao						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIE													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QIEDupEsp(cProdOri,cRevOri,cProdDes,cRevDes,cDesPro,dVigRev)
//���������������������������������������������������������������������������Ŀ
//�  Definicao das variaveis padroes										  �
//�����������������������������������������������������������������������������
Local aArea     := {}
Local aAreaQE6  := {}
Local aArq      := {}
Local aEnsaios  := {}
Local bCConQA2H := Nil
Local bCConQE6  := Nil
Local bCConQE7  := Nil
Local bCConQE8  := Nil
Local bCConQE9  := Nil
Local bCRepQA2H := Nil
Local bCRepQE6  := Nil
Local bCRepQE7  := Nil
Local bCRepQE8  := Nil
Local bCRepQE9  := Nil
Local cEspecH   := ""
Local cKeyNewH  := ""
Local cRastro   := ""
Local cLocPad	:= ""
Local cTipoCQ   := ""
Local lAtuSB1   := .T.
Local lRetSB1   := .F.
Local lVolta    := .T.
Local nI        := 0
Local nRec      := 0

//����������������������������������������������������������������������Ŀ
//� Ponto de Entrada utilizado para verificar se atualiza o arquivo SB1. �
//������������������������������������������������������������������������
Local lQEPM10B1:= ExistBlock("QEPM10B1")                        
Local lAltProd := If(GetMv("MV_QALTPRO",.F.,"1") == "1",.T.,.F.)//Indica se o produto destino tera o camp Tipo C.Q. alterado pra Q na duplicacao

//Caso a data da vigencia nao seja informada, a mesma sera gerada.
If dVigRev == NIL
	dVigRev := A010CkProd()
EndIf

QE6->(dbSetOrder(1))
If QE6->(dbSeek(xFilial("QE6")+cProdOri+Inverte(cRevOri)))
	nRec := Recno()
	
	//���������������������������������������������������������������������������Ŀ
	//� Atualiza o SB1(Cadastro de Produtos) se o mesmo nao existir				  �
	//�����������������������������������������������������������������������������
	cRastro := "N"
	cLocPad := "01"
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cProdOri))
		If Rastro(cProdOri)
			cRastro := If(GetMv("MV_RASTRO")=="S",GetMv("MV_QRASTRO"),"")
		Else
			cRastro := "N"
		EndIf
		cTipoCQ := SB1->B1_TIPOCQ
		cLocPad := SB1->B1_LOCPAD
	EndIf
	

	lAtuSB1 := If(lQEPM10B1, ExecBlock("QEPM10B1",.F.,.F.), lAtuSB1)	
	If lAtuSB1
		lRetSB1 := QIEAtuSB1(.T.,cProdDes,cRevDes,cDesPro,cRastro,cLocPad)
		If lAltProd
			If RetArqProd(cProdDes)
				If AllTrim(SB1->B1_COD) <> "Q"
					RecLock("SB1",.F.)
						If lAltProd
							SB1->B1_TIPOCQ := "Q"
						Else
							SB1->B1_TIPOCQ:= cTipoCQ
						Endif
					MsUnLock()
				EndIf
			ElseIf AllTrim(RetFldProd(SB1->B1_COD,"B1_TIPOCQ")) <> "Q"
				aArea := GetArea()
				RecLock("SBZ",.F.)
					If lAltProd
						SBZ->BZ_TIPOCQ := "Q"
					Else
						SBZ->BZ_TIPOCQ:= "M"
					Endif
				MsUnLock()
				RestArea(aArea)
			EndIf
		EndIf
			//���������������������������������������������������������������������������Ŀ
			//� Verifica se o Produto ja esta cadastrado								  �
			//�����������������������������������������������������������������������������
			If QE6->(dbSeek(xFilial("QE6")+cProdDes+Inverte(cRevDes)))
				Help(" ",1,"M010EXIREV")	// "Produto/Revisao ja' cadastrados."
				Return(Nil)
			EndIf
			DbGoTo(nRec)

			//��������������������������������������������������������������Ŀ
			//� Inicializa Array 										     �
			//����������������������������������������������������������������
			aArq := {}
				
			//��������������������������������������������������������������Ŀ
			//� Chave de ligacao do QE6										 �
			//����������������������������������������������������������������
			cEspecH	 := "QIEA010 "
			aAreaQE6 := QE6->(GetArea())
			cKeyNewH := QA_NewChave("QE6",2)
			RestArea(aAreaQE6)   

			bCrepQE6 := {||QE6->QE6_PRODUT := cProdDes	   	    ,;
							QE6->QE6_REVI   := cRevDes	  	    ,;
							QE6->QE6_DESCPO := cDesPro	        ,;
							QE6->QE6_REVINV := Inverte(cRevDes),;
							QE6->QE6_CHAVE  := cKeyNewH        ,;
							QE6->QE6_DTCAD  := dDataBase}
								
			bCconQE6 := {||!Eof() .and. xFilial("QE6") == QE6_FILIAL .and.;
							QE6_PRODUT == cProdOri .and. QE6_REVI == cRevOri}
				
			Aadd(aArq,{"QE6",cProdOri+Inverte(cRevOri),bCRepQE6,bCConQE6,1})
				
			//��������������������������������������������������������������Ŀ
			//� Condicoes para QA2 - Historico								 �
			//����������������������������������������������������������������
			QE6->(dbSeek(xFilial("QE6")+cProdOri+Inverte(cRevOri)))
				
			cKeyH 	:= QE6->QE6_CHAVE
			cEspecH	:= "QIEA010 "

			bCRepQA2H := {||QA2->QA2_CHAVE := cKeyNewH}
			bCConQA2H := {||!QA2->(eof()) .and. xFilial("QA2") == QA2_FILIAL .and.;
							QA2_CHAVE == cKeyh .and. QA2_ESPEC == cEspecH}
														
			Aadd(aArq,{"QA2",cEspecH+cKeyH,bCRepQA2H,bCConQA2H,1})
				
			//��������������������������������������������������������������Ŀ
			//� Condicoes para QE7											 �
			//����������������������������������������������������������������
			QE7->(dbSetOrder(1))
			QE7->(dbSeek(xFilial("QE7")+cProdOri+cRevOri))
				
			bCrepQE7 := {||QE7->QE7_PRODUT := cProdDes,QE7->QE7_REVI := cRevDes}
				
			bCconQE7 := {||QE7->(!Eof()) .and. xFilial("QE7") == QE7->QE7_FILIAL .and.;
							QE7->QE7_PRODUT == cProdOri .and. QE7->QE7_REVI	 == cRevOri}
												
			Aadd(aArq,{"QE7",cProdOri+cRevOri,bCRepQE7,bCConQE7,1})
				
			//��������������������������������������������������������������Ŀ
			//� Condicoes para QE8											 �
			//����������������������������������������������������������������
			bCrepQE8 := {||QE8->QE8_PRODUT := cProdDes,QE8->QE8_REVI := cRevDes}
					
			bCconQE8 := {||!QE8->(Eof()) .and. xFilial("QE8") == QE8->QE8_FILIAL .and.;
							QE8->QE8_PRODUT == cProdOri .and. QE8->QE8_REVI == cRevOri}
					
			Aadd(aArq,{"QE8",cProdOri+cRevOri,bCRepQE8,bCConQE8,1})
					
			//��������������������������������������������������������������Ŀ
			//� Condicoes para QE9										     �
			//����������������������������������������������������������������
			bCrepQE9 := {||QE9->QE9_PRODUT := cProdDes,;
							QE9->QE9_REVI   := cRevDes}
									
			bCconQE9 := {||!QE9->(eof()) .and. xFilial("QE9") == QE9->QE9_FILIAL .and.;
							QE9->QE9_PRODUT == cProdOri .and. QE9->QE9_REVI == cRevOri}

			Aadd(aArq,{"QE9",cProdOri+cRevOri,bCRepQE9,bCConQE9,1})

			//���������������������������������������������������������������������������Ŀ
			//� Executa a duplicacao dos produtos						 				  �
			//�����������������������������������������������������������������������������
			For nI := 1 to Len(aArq)
				dbSelectArea(aArq[nI,1])
				dbSetOrder(aArq[nI,5])
				dbSeek(xFilial()+aArq[nI,2])

				While Eval(aArq[nI,4])
					lVolta := .t.
					If QA_Dupl(lVolta, aArq[nI,3], aArq[nI,1])
						dbSkip()
					Else
						Exit
					Endif
				EndDo
			Next
				
			//���������������������������������������������������������������������������Ŀ
			//� Grava a data de vigencia da nova revisao da especificacao				  �
			//�����������������������������������������������������������������������������
			QE6->(dbSetOrder(1))
			If QE6->(dbSeek(xFilial("QE6")+cProdDes+Inverte(cRevDes)))
				RecLock("QE6",.F.)
				QE6->QE6_DTINI := dVigRev
				If Alltrim(Str(Ascan(aItem,cOriDes))) $ ("1,3")
					If Upper(__Language) == "PORTUGUESE" 
						QE6->QE6_DESCIN := ""
						QE6->QE6_DESCES := ""
					Endif 
				EndIF  
				
				//Verifica se o produto destino existe no SB1 para atualiza��o de algumas infos do SB1
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1")+cProdDes))
					QE6->QE6_UNMED1  := SB1->B1_UM 
					QE6->QE6_TIPO    := SB1->B1_TIPO
				EndIf     

				If lRetSB1 // Caso o produto j� estiver cadastrado na SB1, atualiza Unidade de Medida conforme cadastro do produto
					QE6->QE6_UNMED1  := SB1->B1_UM
					QE6->QE6_UNAMO1  := QE6->QE6_UNMED1
					QE6->QE6_TIPO    := SB1->B1_TIPO
				EndIf
				
				MsUnLock()
			EndIf

			//���������������������������������������������������������������������������Ŀ
			//� Atualiza o Plano de Amostragens por Ensaios de acordo com a revisao ante- �
			//� rior da Especificacao do Produto.										  �
			//�����������������������������������������������������������������������������
			aEnsaios := {}
				
			//Armazena os ensaios mensuraveis no vetor aEnsaios
			QE7->(dbSetorder(1))
			QE7->(dbSeek(xFilial("QE7")+cProdDes+cRevDes))
			While QE7->(!Eof()) .And. QE7->QE7_FILIAL == xFilial("QE7") .And.;
				QE7->(QE7_PRODUT+QE7_REVI) == (cProdDes+cRevDes)
				Aadd(aEnsaios,{QE7->QE7_ENSAIO,.F.})			
				QE7->(dbSkip())	
			EndDo	

			//Armazena os ensaios textos no vetor aEnsaios		
			QE8->(dbSetorder(1))
			QE8->(dbSeek(xFilial("QE8")+cProdDes+cRevDes))
			While QE8->(!Eof()) .And. QE8->QE8_FILIAL == xFilial("QE8") .And.;
				QE8->(QE8_PRODUT+QE8_REVI) == (cProdDes+cRevDes)
				Aadd(aEnsaios,{QE8->QE8_ENSAIO,.F.})			
				QE8->(dbSkip())	
			EndDo	
									
			If (cProdOri == cProdDes) 
				MsgRun(STR0011,STR0012,{||QComMovPAE(cProdDes,cRevDes,aEnsaios,,1)}) //"Atualizando o Plano de Amostragem por Ensaios..." ### "Aguarde"
			EndIf
		EndIf
	EndIf                                       

	If ExistBlock("QEM010R")
		ExecBlock("QEM010R",.f.,.f.)
	Endif


		

Return(Nil)
    
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � A010ExProd � Autor � Marcelo Pimentel      � Data � 19/05/98 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verif. se Prod. est� cadastrado ou se j� existe	            ���
���������������������������������������������������������������������������Ĵ��
��� Sintaxe  � A010ExProd(ExpC1)                             				���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: "O" se for Produto Origem              				���
���          � ExpC1: "D" se for Produto Destino             				���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � X1_VALID (QEM010)                            				���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A010ExProd(cPerg, lTudoOk)
Local cChave          
Local lRet  := .F.

DEFAULT lTudoOk := .F.

If cPerg == "O"  
	//���������������������������������������������������������������������������Ŀ
	//� Produto Origem					 												  �
	//�����������������������������������������������������������������������������
	
	
	cChave := cProdOri + Inverte(cRevOri)

	//���������������������������������������������������������������������������Ŀ
	//� Verifica se existe o Produto+Revisao									  �
	//�����������������������������������������������������������������������������
	QE6->(dbSetOrder(1))
	If QE6->(DbSeek(xFilial('QE6') + cChave ))
	
		//���������������������������������������������������������������������������Ŀ
		//� Sugere a descricao do Produto (Especificacao do Produto)				  �
		//�����������������������������������������������������������������������������
		If ! lTudoOk
			cDesPro := QE6->QE6_DESCPO
		Endif

		//���������������������������������������������������������������������������Ŀ
		//� Sugere a Proxima Revisao no campo de Destino                              �
		//�����������������������������������������������������������������������������  
		If Empty(cProdDes) .And. Empty(cRevDes)
			cRevDes  := QA_UltRevEsp(cProdOri,dDataBase,.F.,.T.,"QIE")
			cProdDes := cProdOri
			If empty(cRevDes)
			   cRevDes := "00"
			Else 
			   cRevDes := Soma1(cRevDes)
			   While .t.
	               If !FreeForUse("QE6",xFilial("QE6")+cProdOri+cRevDes)
	    	          cRevDes := Soma1(cRevDes)    
	               Else
	                  Exit
	               EndIf
	           EndDo
			EndIf
  		EndIf
		lRet    := .T.  
	Else
		Help(" ",1,"Q_010PRNAO")	// "Produto/Revisao nao cadastrados."

	EndIf
Else
	//���������������������������������������������������������������������������Ŀ
	//� Produto Destino															  �
	//�����������������������������������������������������������������������������
	If Empty(cProdDes)
		MsgAlert(STR0017, STR0018)	// "Produto destino nao informado !" #  "Aten��o"
		Return(.F.)
	EndIf
	
	
	cChave := (cProdDes + Inverte(cRevDes))

	//���������������������������������������������������������������������������Ŀ
	//� Verifica se existe o Produto+Revisao									  �
	//�����������������������������������������������������������������������������
	QE6->(dbSetOrder(1))
	If !QE6->(DbSeek(xFilial('QE6') + cChave ))
		lRet := .T.
	Else
		Help(" ",1,"Q_010PRJAC")	// "Produto/Revisao j� cadastrados."
	EndIf

EndIf

Return(lRet)


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � A010CkProd � Autor � Marcelo Pimentel      � Data � 19/05/98 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se produto est� cadastrado                          ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � X1_VALID                            							���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A010CkProd()
Local nRec      := 0
Local dVigencia := dDataBase

cProdDes := Upper(cProdDes)

nRec := QE6->(Recno())
	
QE6->(dbSetOrder(1))
If QE6->(DbSeek(xFilial('QE6') + cProdDes))
	
	While !QE6->(Eof()) .And. cProdDes == QE6->QE6_PRODUT
		If cRevDes < QE6->QE6_REVI
			cRevDes := Soma1(QE6->QE6_REVI)
		EndIf	
		If dVigencia <= QE6->QE6_DTINI
			dVigencia := (QE6->QE6_DTINI+1)
		EndIf
		QE6->(DbSkip()) 
	EndDo

EndIf
QE6->(DbGoTo(nRec))
              
Return(dVigencia)


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � Qie010UpIn � Autor � Wanderley Gon�alves	  � Data � 29/01/98 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se Campo Produto nao esta vazio e converte para     ���
���			 � maiusculo.										            ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � X1_VALID                               					    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Qie010UpIn()
Local lret := .f.
If naovazio()
	cProdOri := Upper(cProdOri)
	lRet := .T.
EndIf
Return(lRet)


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao	 � Qie010Verif� Autor � Robson R. A. Oliveira � Data � 14/05/01 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica de onde vira a descricao do produto                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros� EXPA1 = Array contendo as opcoes do ComboBox					���
���          � EXPC1 = Descricao da posicao atual na ComboBox				���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEM010                                 					    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Qie010Verif(aItem,cOriDes)  
Local cDes   := Space(TamSX3("B1_DESC")[1])
Local nAscan := Ascan(aItem,cOriDes)

If (nAscan == 2)
	SB1->(dbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+cProdOri))
		cDes := SB1->B1_DESC
	EndIf
	
ElseIf (nAscan == 3)
	SB1->(dbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+cProdDes))
		cDes := SB1->B1_DESC
	EndIf

ElseIf (nAscan == 4)
	QE6->(dbSetorder(1))
	If QE6->(DbSeek(xFilial("QE6")+cProdOri+Inverte(cRevOri)))
		cDes := QE6->QE6_DESCPO
	EndIf	
	
EndIf

Return(cDes)




