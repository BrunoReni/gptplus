#INCLUDE "FINA415.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FINA415   � Autor � Sergio S. Fuzinaka    � Data � 10.05.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Eliminacao de Residuos dos Saldos a Receber e a Pagar,      ���
���          �atraves de Baixas por Dacao.                                ���                    
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Fina415()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SIGAFIN                                                     ���
�������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������Ĵ��
���PROGRAMADOR� DATA   �Issue        �  MOTIVO DA ALTERACAO               ���
�������������������������������������������������������������������������Ĵ��
���Jose Glez  �28/09/17�TSSERMI01-156�Ajusta el montaje del di�logo       ���
���           �        �             �utilizando FwDefSize ()             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fina415()

//��������������������������������������������������������������Ŀ
//�                    P A R A M E T R O S                       �
//�--------------------------------------------------------------�
//�                     Perguntas  FIN415                        �
//�                                                              �
//�MV_PAR01: Tipo do Titulo ( Receber ou Pagar )                 �
//�MV_PAR02: Tipo da baixa  (Ver sigaadv.mot   )                 �
//�MV_PAR03: Historico para o lancamento da baixa                �
//�--------------------------------------------------------------�
//�              Perguntas  FI415A e FI415B                      �
//�                                                              �
//�MV_PAR01: De Codigo  ( Cliente ou Fornecedor )                �
//�MV_PAR02: Ate Codigo ( Cliente ou Fornecedor )                �
//�MV_PAR03: De Loja                                             �
//�MV_PAR04: Ate Loja                                            �
//�MV_PAR05: De Prefixo                                          �
//�MV_PAR06: Ate Prefixo                                         �
//�MV_PAR07: De Titulo                                           �
//�MV_PAR08: Ate Titulo                                          �
//�MV_PAR09: De Tipo                                             �
//�MV_PAR10: Ate Tipo                                            �
//�MV_PAR11: De Natureza                                         �
//�MV_PAR12: Ate Natureza                                        �
//�MV_PAR13: De Emissao                                          �
//�MV_PAR14: Ate Emissao                                         �
//�MV_PAR15: De Vencimento                                       �
//�MV_PAR16: Ate Vencimento                                      �
//�MV_PAR17: Valor Maximo                                        �
//�MV_PAR18: Qual Moeda                                          �
//�MV_PAR19: Selecionar Titulo ( Sim ou Nao )                    �
//�--------------------------------------------------------------�
//�                     Perguntas  FI415C                        �
//�                                                              �
//�MV_PAR01: Mostrar lancamentos contabeis.                      �
//�MV_PAR02: Aglomerar lancamentos                               �
//�MV_PAR03: Contabilizar on-Line                                �
//����������������������������������������������������������������

Local lProc    := .F.
Local nOp      := 0
Local aSays    := {}
Local aButtons := {}
Local lPergunte := .F.
Local lPanelFin := IsPanelFin()

Private nTipoTit    , ;		// Tipo do Titulo ( Receber / Pagar )
		cCodDe      , ;		// De Codigo ( Cliente / Fornecedor )
		cCodFim		, ;		// Ate Codigo ( Cliente / Fornecedor )
		cLojaDe     , ;		// De Loja
		cLojaAte    , ;		// Ate Loja
		cPrefixoDe  , ;		// De Prefixo
		cPrefixoAte , ;		// Ate Prefixo
		cTituloDe   , ;		// De Titulo
		cTituloAte  , ;		// Ate Titulo
		cTipoDe		, ;		// De Tipo
		cTipoAte	, ;		// Ate Tipo
		cNatDe      , ;		// De Natureza
		cNatAte     , ;		// Ate Natureza
		dEmisDe     , ;		// De Emissao
		dEmisAte    , ;		// Ate Emissao
		dVencDe     , ;		// De Vencimento
		dVencAte    , ;		// Ate Vencimento
		nValor      , ;		// Valor Limite para Baixa
		nMoeda      , ;		// Moeda do Valor
		nSelTit     , ;   	// Seleciona Titulo ( Sim / Nao )
		cMotBaixa   ,;      //Motivo da Baixa
		cHistorico          //Historico padrao

Private aMotBx   	:= ReadMotBx()
Private lF415Auto := .T.
Private cCadastro := OemToAnsi(STR0001)  //"Eliminacao de Residuos"

AADD (aSays, OemToAnsi(STR0002))  //"Este programa tem o objetivo de eliminar os residuos dos saldos a Receber e Pagar,"
AADD (aSays, OemToAnsi(STR0003))  //"atraves de baixas por Dacao"

//��������������������������������������������������������������Ŀ
//� Inicializa o log de processamento                            �
//����������������������������������������������������������������
ProcLogIni( aButtons )

If lPanelFin  //Chamado pelo Painel Financeiro			
	aButtonTxt := {}			
	If Len(aButtons) > 0
		AADD(aButtonTxt,{STR0025,STR0025,aButtons[1][3]}) // Visualizar			
	Endif	
	FaMyFormBatch(aSays,aButtonTxt,{||nOp:=1},{||nOp:=0})	
Else                  			
	AADD(aButtons, { 1,.T.,{|o| nOp:=1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	FormBatch( cCadastro, aSays, aButtons )
Endif	

If nOp == 1
	If lPanelFin
		lPergunte := PergInPanel("FIN415",.T.)
	Else
	   lPergunte := pergunte("FIN415",.T.)
	Endif		
	
	If lPergunte
		nTipoTit 	:= Mv_Par01
		cMotBaixa   := Mv_Par02
		cHistorico	:= Mv_Par03
		If Empty(cMotBaixa)
			cMotBaixa := "DAC"
		EndIf
		If Empty(cHistorico)
			cHistorico	:= OemToAnsi(STR0005)
		EndIf
		If aScan(aMotBx,cMotBaixa) == 0
			MsgAlert(STR0009)
			Return .T.
		EndIf			
		If nTipoTit == 1	// Contas a Receber
			If lPanelFin
				lPergunte := PergInPanel("FI415A",.T.)
			Else
			   lPergunte := pergunte("FI415A",.T.)
			Endif
			If lPergunte
				lProc := .T.
			Endif
		Else         		// Contas a Pagar
			If lPanelFin
				lPergunte := PergInPanel("FI415B",.T.)
			Else
			   lPergunte := pergunte("FI415B",.T.)
			Endif
			If lPergunte
				lProc := .T.
			Endif
		Endif
		If lProc
			//�����������������������������������Ŀ
			//� Atualiza o log de processamento   �
			//�������������������������������������
			ProcLogAtu("INICIO")
				
			cCodDe      := Mv_Par01
			cCodAte     := Mv_Par02
			cLojaDe		:= Mv_Par03
			cLojaAte	:= Mv_Par04
			cPrefixoDe	:= Mv_Par05
			cPrefixoAte	:= Mv_Par06
			cTitDe		:= Mv_Par07
			cTitAte		:= Mv_Par08
			cTipoDe		:= Mv_Par09
			cTipoAte	:= Mv_Par10
			cNatDe		:= Mv_Par11
			cNatAte		:= Mv_Par12
			dEmisDe		:= Mv_Par13
			dEmisAte	:= Mv_Par14
			dVencDe		:= Mv_Par15
			dVencAte	:= Mv_Par16
			nValor		:= Mv_Par17
			nMoeda		:= Mv_Par18
			nSelTit		:= Mv_Par19

			Processa( {|| F415Proc()} )
			//�����������������������������������Ŀ
			//� Atualiza o log de processamento   �
			//�������������������������������������
			ProcLogAtu("FIM")
					
		Endif
	Endif
Endif

If lPanelFin  //Chamado pelo Painel Financeiro			
	dbSelectArea(FinWindow:cAliasFile)			
	ReCreateBrow(FinWindow:cAliasFile,FinWindow)      	
	
Endif
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �F415Proc  � Autor � Sergio S. Fuzinaka    � Data � 13.05.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Tratamento dos Titulos a Receber / Pagar                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �FINA415                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F415Proc()

Local cAlias   := IIf(nTipoTit == 1, "SE1", "SE2")
Local aGrid    := {}
Local aFields  := {}
Local lBaixou  := .F.
Local aArea    := {}
Local nI       := 0
Local cQuery   := ""
Local bWhile   := {|| !Eof()}
Local aCampos  := {}
Local nTotAbat := 0
Local lBaixa            
Local lBxRec	:= ExistBlock("F415BxRec")
Local lBxPag	:= ExistBlock("F415BxPag")    
Local nMulta := 0 								//Valor da Multa
Local cMVJurTipo := SuperGetMV("MV_JURTIPO",,"") //Tipo de Calculo dos Juros
Local lLojxRMul     := .T.  //Valor que calcula os juros e multas do SigaLoja 
Local lMvLjIntFs	:= SuperGetMv("MV_LJINTFS", , .F.) //Habilita integra��o com o Financial Services?   

Private aHead   := {}
Private aCols   := {}
Private aCpos   := {}
Private cMotivo := ""
Private dBaixa  := IIf(nTipoTit == 1, CriaVar("E1_BAIXA"), CriaVar("E2_BAIXA"))

For nI := 1 To Len(aMotBx)
	If Substr(aMotBx[nI],1,03) == cMotBaixa
		cMotivo := Substr(aMotBx[nI],07,10)
	Endif
Next

//����������������������������������������������������������������Ŀ
//� Tratamento das variaveis para serem utilizadas na Baixa Manual �
//������������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias,.F.)
While !Eof() .And. X3_ARQUIVO == Alltrim(cAlias)
	If X3Uso(X3_USADO) .And. cNivel >= X3_NIVEL .And. AScan(aCpos,Alltrim(X3_CAMPO)) == 0
		AADD(aCpos  , X3_CAMPO)
		AADD(aCampos, {X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL})		
	Endif
	dbSkip()
Enddo

If nTipoTit == 1	// Receber
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SE1")
	cQuery += " WHERE E1_FILIAL='"+xFilial("SE1")+"'"
	cQuery += " AND E1_CLIENTE BETWEEN '"+cCodDe+"' AND '"+cCodAte+"'" 
	cQuery += " AND E1_LOJA BETWEEN '"+cLojaDe+"' AND '"+cLojaAte+"'" 
	cQuery += " AND E1_PREFIXO BETWEEN '"+cPrefixoDe+"' AND '"+cPrefixoAte+"'"
	cQuery += " AND E1_NUM BETWEEN '"+cTitDe+"' AND '"+cTitAte+"'"
	cQuery += " AND E1_TIPO BETWEEN '"+cTipoDe+"' AND '"+cTipoAte+"'"
	cQuery += " AND E1_NATUREZ BETWEEN '"+cNatDe+"' AND '"+cNatAte+"'"	    
	cQuery += " AND E1_EMISSAO BETWEEN '"+Dtos(dEmisDe)+"' AND '"+Dtos(dEmisAte)+"'"	    
	cQuery += " AND E1_VENCREA BETWEEN '"+Dtos(dVencDe)+"' AND '"+Dtos(dVencAte)+"'"	    
	cQuery += " AND E1_SALDO <= "+Str(nValor,TamSX3("E1_SALDO")[1],TamSX3("E1_SALDO")[2])+""
	cQuery += " AND E1_SALDO > 0 "
	cQuery += " AND E1_MOEDA =" + STR(MV_PAR18) 
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY E1_CLIENTE, E1_LOJA"
Else	// Pagar
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL='"+xFilial("SE2")+"'"
	cQuery += " AND E2_FORNECE BETWEEN '"+cCodDe+"' AND '"+cCodAte+"'" 
	cQuery += " AND E2_LOJA BETWEEN '"+cLojaDe+"' AND '"+cLojaAte+"'" 
	cQuery += " AND E2_PREFIXO BETWEEN '"+cPrefixoDe+"' AND '"+cPrefixoAte+"'"
	cQuery += " AND E2_NUM BETWEEN '"+cTitDe+"' AND '"+cTitAte+"'"
	cQuery += " AND E2_TIPO BETWEEN '"+cTipoDe+"' AND '"+cTipoAte+"'"
	cQuery += " AND E2_NATUREZ BETWEEN '"+cNatDe+"' AND '"+cNatAte+"'"	    
	cQuery += " AND E2_EMISSAO BETWEEN '"+Dtos(dEmisDe)+"' AND '"+Dtos(dEmisAte)+"'"	    
	cQuery += " AND E2_VENCREA BETWEEN '"+Dtos(dVencDe)+"' AND '"+Dtos(dVencAte)+"'"	    
	cQuery += " AND E2_SALDO <= "+Str(nValor,TamSX3("E2_SALDO")[1],TamSX3("E2_SALDO")[2])+""
	cQuery += " AND E2_SALDO > 0 "
	cQuery += " AND E2_MOEDA =" + STR(MV_PAR18)
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY E2_FORNECE, E2_LOJA"
Endif

cAlias := "TRB"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
aEval(aCampos, {|e| If(e[2]!= "C", TCSetField(cAlias, e[1],e[2],e[3],e[4]),Nil)})

aGrid := FA087aHead(cAlias,aCpos,.T.)	// Monta Grid 
aCpos := aClone(aGrid[2])				// Campos
aHead := aClone(aGrid[3])  				// Cabecalho

//������������������Ŀ
//� Contas a Receber �
//��������������������
If nTipoTit == 1
	
	dbSelectArea(cAlias)

	While Eval(bWhile)
		
		lBaixa := .T.
		
		//�������������������������������������Ŀ
		//� Verifica se e um registro Principal �
		//���������������������������������������
		If lBaixa .And. E1_TIPO $ MVABATIM+"/"+MVIRABT+"/"+MVINABT
			lBaixa := .F.
		Endif
	
		//������������������������������������Ŀ
		//� Verifica se e um titulo provisorio �
		//��������������������������������������
		IF lBaixa .And. E1_TIPO $ MVPROVIS
			lBaixa := .F.		
		EndIF

		//������������������������������������������������������������Ŀ
		//� Consiste o motivo de baixa em relacao a situacao do titulo �
		//��������������������������������������������������������������
		If lBaixa .And. E1_SITUACA != "0" .And. !MovBcoBx(cMotivo, .T.)
			lBaixa := .F.				
		Endif		

		//����������������������������������������Ŀ
		//� Soma abatimentos relacionado ao titulo �
		//������������������������������������������
		If lBaixa 
			nTotAbat := SumAbatRec(E1_PREFIXO, E1_NUM, E1_PARCELA, E1_MOEDA, "S", dBaixa)
		Endif

		//��������������������������������������������������������������Ŀ
		//� Verifica se e a mesma moeda, caso contrario converte o valor �
		//����������������������������������������������������������������
		If lBaixa .And. E1_MOEDA == nMoeda
			If (E1_SALDO - nTotAbat) > nValor
				lBaixa := .F.
			Endif
		Else
			If  lBaixa .And. ;
				Round((xMoeda(E1_SALDO,E1_MOEDA,nMoeda,E1_EMISSAO) - nTotAbat), MsDecimais(nMoeda)) > nValor
				lBaixa := .F.			
			Endif
		Endif

		//����������������������������������������������������������������������Ŀ
		//� Verifica se o t�tulo tem juros ou taxas de permanencia sob o residuo �
		//������������������������������������������������������������������������		
	    //Calculo de Juros e Multas: SIGALOJA x SIGAFIN
	    //Inclu�do o valor da multa, caso esteja habilidado o c�lculo de juros e multas do controle de Lojas
		nMulta := 0
		//������������������������������������������������������--------��������������Ŀ
		//�Verifica se o tipo de calculo de juros � igual (L)loja, calcula a multa      � 
		//�������������������������������������������������--------���������������������
		If (cMvJurTipo == "L" .OR. lMvLjIntFs) .and. lLojxRMul
	
			//��������������������������������������������������������������������Ŀ
			//� Calcula o valor da Multa  :funcao LojxRMul :fonte Lojxrec          �
			//����������������������������������������������������������������������
			  nMulta := LojxRMul( , , ,(cAlias)->E1_SALDO, (cAlias)->E1_ACRESC, (cAlias)->E1_VENCREA, dDataBase, , (cAlias)->E1_MULTA, ,;
			  					 (cAlias)->E1_PREFIXO, (cAlias)->E1_NUM, (cAlias)->E1_PARCELA, (cAlias)->E1_TIPO, (cAlias)->E1_CLIENTE, (cAlias)->E1_LOJA, cAlias )   	
		Endif
			
		//Calculo de Juros e Multas: SIGALOJA x SIGAFIN
		If lBaixa .And. E1_SALDO + faJuros((cAlias)->E1_VALOR,(cAlias)->E1_SALDO,(cAlias)->E1_VENCTO,(cAlias)->E1_VALJUR,(cAlias)->E1_PORCJUR,(cAlias)->E1_MOEDA,(cAlias)->E1_EMISSAO,dDataBase,If(cPaisLoc=="BRA",(cAlias)->E1_TXMOEDA,0),iif( ValType((cAlias)->E1_BAIXA)=='D', (cAlias)->E1_BAIXA, Stod((cAlias)->E1_BAIXA)),(cAlias)->E1_VENCREA, cAlias) + nMulta > nValor
			lBaixa := .F.
		Endif		
		//�����������������������������������������������Ŀ
		//� Ponto de Entrada para filtragem dos titulos	  �
		//�������������������������������������������������
		If lBaixa .And. lBxRec
			lBaixa := ExecBlock("F415BxRec",.F.,.F.)
		EndIf
		
		If lBaixa
			If nSelTit == 2		// Baixa Automatica
				lBaixou := .T.
				aArea   := GetArea()
				F415BaixA("1", cAlias)
				RestArea(aArea)
			Else
				aFields		:= AClone(aCpos)
				aFields[1]	:= .F.
				For nI:=2 To Len(aCpos)
				    aFields[nI] := &(aCpos[nI])
				Next
				AADD(aCols, aFields)	
			Endif
		Endif

		dbSelectArea(cAlias)
		dbSkip()
    Enddo

//����������������Ŀ
//� Contas a Pagar �
//������������������
Else
		
	dbSelectArea(cAlias)

	While Eval(bWhile)

		lBaixa := .T.
		
		//�������������������������������������Ŀ
		//� Verifica se e um registro Principal	�
		//���������������������������������������
		If lBaixa .And. E2_TIPO $ MVABATIM
			lBaixa := .F.
		Endif
	
		//�����������������������������������Ŀ
		//�Verifica se e um titulo provisorio �
		//�������������������������������������
		If lBaixa .And. E2_TIPO $ MVPROVIS
			lBaixa := .F.
		Endif
	                                      
		//����������������������������������������Ŀ
		//� Soma abatimentos relacionado ao titulo �
		//������������������������������������������
		If lBaixa
			nTotAbat := SumAbatPag(E2_PREFIXO, E2_NUM, E2_PARCELA, E2_FORNECE, E2_MOEDA, "S", dBaixa, E2_LOJA)
		Endif

		//��������������������������������������������������������������Ŀ
		//� Verifica se e a mesma moeda, caso contrario converte o valor �
		//����������������������������������������������������������������
		If lBaixa .And. E2_MOEDA == nMoeda
			If (E2_SALDO - nTotAbat) > nValor
				lBaixa := .F.
			Endif
		Else        
			If lBaixa .And. ;
				Round((xMoeda(E2_SALDO,E2_MOEDA,nMoeda,E2_EMISSAO) - nTotAbat), MsDecimais(nMoeda)) > nValor
				lBaixa := .F.			
			Endif
		Endif

		//�����������������������������������������������Ŀ
		//� Ponto de Entrada para filtragem dos titulos	  �
		//�������������������������������������������������
		If lBaixa .And. lBxPag
			lBaixa := ExecBlock("F415BxPag",.F.,.F.)
		EndIf

		If lBaixa
			If nSelTit == 2		// Baixa Automatica
				lBaixou := .T.
				aArea   := GetArea()		
				F415BaixA("2")
				RestArea(aArea)
			Else
				aFields    	:= AClone(aCpos)
				aFields[1]	:= .F.
				For nI:=2 To Len(aCpos)
				    aFields[nI] := &(aCpos[nI])
				Next
				AADD(aCols, aFields)	
			Endif
		Endif

        dbSelectArea(cAlias)
		dbSkip()
    Enddo

Endif

If nSelTit == 1		// Baixa Manual
	If !Empty(aCols)
		F415BaixM()	
	Else
		Help(" ",1,"RECNO")
		//���������������������������������������������Ŀ
		//� Atualiza o log de processamento com o erro  �
		//�����������������������������������������������
		ProcLogAtu("ERRO","RECNO",Ap5GetHelp("RECNO"))
	Endif
Else				// Baixa Automatica
	If !lBaixou	
		Help(" ",1,"RECNO")
		//���������������������������������������������Ŀ
		//� Atualiza o log de processamento com o erro  �
		//�����������������������������������������������
		ProcLogAtu("ERRO","RECNO",Ap5GetHelp("RECNO"))
	Else
		MsgAlert(STR0010)//"Eliminacao de residuos completa."	
	Endif	
Endif

dbSelectArea(cAlias)
dbCloseArea()

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �F415BaixM � Autor � Sergio S. Fuzinaka    � Data � 16.05.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Baixa Manual dos Titulos a Receber / Pagar                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �FINA415                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F415BaixM()

Local nOp		:= 0
Local nPos		:= 0
Local cLine		:= "{IIf(aCols[oListBox:nAt,1],oOk,oNo)"
Local oOk		:= LoadBitMap(GetResources(), "LBOK")
Local oNo		:= LoadBitMap(GetResources(), "LBNO")
Local cPrefixo	:= ""
Local cNum		:= ""
Local cParcela	:= ""
Local cTipo		:= ""
Local cCodigo	:= ""
Local cLoja		:= ""
Local oDlg, oListBox, bLine
Local nI		:= 0
Local aBut415	:= {{"PESQUISA",{||Fa415Pesq(oListBox,aCols)},STR0016,STR0017}} //"Pesquisar..(CTRL-P)"###"Pesquisar"
Local bKeyF5	:= SetKey( VK_F5 )
Local oSize
Local a1stRow	:=  {}

Private nValor	:= 0
Private nQtdTit	:= 0     
Private cTexto	:= Space(30)                           

SetKey (VK_F12,{|a,b| AcessaPerg("FI415C",.T.)})
SetKey (VK_F5,{||Fa415Pesq(oListBox,aCols,.T.)}) 

For nI:=2 To Len(aHead)
	cLine += ",aCols[oListBox:nAt][" + AllTrim(Str(nI)) + "]"
Next
cLine += "}"
bLine := &( "{|| " + cLine + "}" )                                                                             

Aadd( aBut415, {"CHECKED" ,{ || AEval(aCols,{|x,y| aCols[y][1]:=.T.,FA415Disp(oListBox,aCols)})	},STR0018, "Marcar"} ) //"Marcar todos"
Aadd( aBut415, {"UNCHECKED" ,{ || AEval(aCols,{|x,y| aCols[y][1]:=.F.,FA415Disp(oListBox,aCols)}) },STR0019, "Desmarcar"} ) //"Desmarcar todos"

DEFINE MSDIALOG oDlg FROM 00,00 To 600,1200 TITLE OemToAnsi(STR0006)+" - "+IIf(nTipoTit==1,OemToAnsi(STR0007),OemToAnsi(STR0008)) Of oMainWnd PIXEL // Baixa Manual por Dacao

	//Defino o tamanho dos componentes atrav�s do m�todo FwDefSize(), amarrando ao objeto oDlg
	oSize := FwDefSize():New(.T.,,,oDlg)
	
	oSize:lLateral := .F.
	oSize:lProp := .T.
	
	oSize:AddObject("MASTER",100,100,.T.,.T.)

	oSize:Process()
	
	a1stRow := {oSize:GetDimension("MASTER","LININI"),;
				oSize:GetDimension("MASTER","COLINI"),;
				oSize:GetDimension("MASTER","LINEND"),;
				oSize:GetDimension("MASTER","COLEND")}

	//Panel
	oPanel := TPanel():New(a1stRow[1],a1stRow[2],'',oDlg,, .T., .T.,, ,a1stRow[4],a1stRow[3],.T.,.T. )
	//oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI
		
	@0.5,1 Say STR0020 Of oPanel // "Valor Total:"
	@0.5,7 Say oValor VAR nValor Picture "@E 999,999,999,999.99" SIZE 50,8 Of oPanel
		
	@0.5,20 Say STR0021 Of oPanel //"Quantidade:"
	@0.5,28 Say oQtda VAR nQtdTit Picture "@E 99999" SIZE 50,8 Of oPanel    

	oListBox := TWBrowse():New(a1stRow[1],a1stRow[2],a1stRow[4]-07,a1stRow[3]-70,,aHead,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox:SetArray(aCols)
	oListBox:bLDblClick := {|| aCols[oListBox:nAt,1] := !aCols[oListBox:nAt,1],FA415Disp(oListBox,aCols)}
	oListBox:bLine      := bLine

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||(nOp := 1,oDlg:End())},{||(nOp := 0,oDlg:End())},,aBut415) CENTERED

If nOp == 1		// Efetua Baixa
	For nI:=1 To Len(aCols)
		If aCols[nI,1]	// Registro Marcado
			nPos     := Ascan(aCpos, IIf(nTipoTit==1,"E1","E2")+"_PREFIXO")
			cPrefixo := aCols[nI,nPos]
			nPos     := Ascan(aCpos, IIf(nTipoTit==1,"E1","E2")+"_NUM")
			cNum     := aCols[nI,nPos]
			nPos     := Ascan(aCpos, IIf(nTipoTit==1,"E1","E2")+"_PARCELA")
			cParcela := aCols[nI,nPos]
			nPos     := Ascan(aCpos, IIf(nTipoTit==1,"E1","E2")+"_TIPO")
			cTipo    := aCols[nI,nPos]
			nPos     := Ascan(aCpos, IIf(nTipoTit==1,"E1_CLIENTE","E2_FORNECE"))
			cCodigo  := aCols[nI,nPos]
			nPos     := Ascan(aCpos, IIf(nTipoTit==1,"E1","E2")+"_LOJA")
			cLoja    := aCols[nI,nPos]                          

			If nTipoTit == 1	// Receber
				dbSelectArea("SE1")
				dbSetOrder(2)
				dbSeek(xFilial("SE1")+cCodigo+cLoja+cPrefixo+cNum+cParcela+cTipo)
				F415BaixA("1", "SE1")
			Else				// Pagar
				dbSelectArea("SE2")
				dbSetOrder(1)
				dbSeek(xFilial("SE2")+cPrefixo+cNum+cParcela+cTipo+cCodigo+cLoja)
				F415BaixA("2")
			Endif
		Endif
	Next 
	MsgAlert(STR0010)//"Eliminacao de residuos completa."
Endif

SetKey (VK_F5,bKeyF5) 

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �F415BaixA � Autor � Sergio S. Fuzinaka    � Data � 13.05.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Baixa Automatica a Receber / Pagar                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cPar   : '1' - Receber / '2' - Pagar                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �FINA415                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F415BaixA(cPar, cAlias)

Local aBaixa 		:= {}
Local lRet	 		:= .T.  
Local nMulta		:= 0        	//Valor da Multa
Local cMVJurTipo 	:= SuperGetMV("MV_JURTIPO",,"") //Tipo de Calculo dos Juros
Local lLojxRMul  	:= .T.     //Funcao que calcula os Juros do Loja 
Local lMvLjIntFS 	:= SuperGetMV("MV_LJINTFS", , .F.) //Habilita integracao com o financial services?
Local aPerg			:= {}

	  
If cPar == "1"	// Contas a Receber

	AADD( aBaixa, { "E1_PREFIXO" 	, E1_PREFIXO			, Nil } )	// 01
	AADD( aBaixa, { "E1_NUM"     	, E1_NUM				, Nil } )	// 02
	AADD( aBaixa, { "E1_PARCELA" 	, E1_PARCELA			, Nil } )	// 03
	AADD( aBaixa, { "E1_TIPO"    	, E1_TIPO				, Nil } )	// 04
	AADD( aBaixa, { "AUTMOTBX"  	, cMotivo				, Nil } )	// 05
	AADD( aBaixa, { "AUTDTBAIXA"	, dDataBase				, Nil } )	// 06
	AADD( aBaixa, { "AUTDTCREDITO"	, dDataBase				, Nil } )	// 07
	AADD( aBaixa, { "AUTHIST"   	, cHistorico			, Nil } )	// 08
	
	//Calculo de Juros e Multas: SIGALOJA x SIGAFIN - Inicio
	nMulta := 0
	If (cMvJurTipo == "L" .OR. lMvLjIntFs) .and. lLojxRMul 

		//��������������������������������������������������������������������Ŀ
		//� Calcula o valor da Multa  :funcao LojxRMul :fonte Lojxrec          �
		//����������������������������������������������������������������������

		  nMulta := LojxRMul( , , ,(cAlias)->E1_SALDO, (cAlias)->E1_ACRESC, (cAlias)->E1_VENCREA, dDataBase, , SE1->E1_MULTA, ,;
		  					 (cAlias)->E1_PREFIXO, (cAlias)->E1_NUM, (cAlias)->E1_PARCELA, (cAlias)->E1_TIPO, (cAlias)->E1_CLIENTE, (cAlias)->E1_LOJA, cAlias )   	

	
		AADD( aBaixa, { "AUTMULTA"  	, nMulta						, Nil } )	// 09
	Endif
    //Calculo de Juros e Multas: SIGALOJA x SIGAFIN - Fim
	Pergunte("FIN070",.F.)
	Pergunte("FI415C",.F.)
	mv_par04 := mv_par03 //Compatibilizacao com os parametros da Fina070.
		
	lRet := MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)
	
Else	// Contas a Pagar

	AADD( aBaixa, { "E2_PREFIXO" 	, E2_PREFIXO			, Nil } )	// 01
	AADD( aBaixa, { "E2_NUM"     	, E2_NUM		 		, Nil } )	// 02
	AADD( aBaixa, { "E2_PARCELA" 	, E2_PARCELA			, Nil } )	// 03
	AADD( aBaixa, { "E2_TIPO"    	, E2_TIPO				, Nil } )	// 04
	AADD( aBaixa, { "E2_FORNECE"	, E2_FORNECE			, Nil } )	// 05
	AADD( aBaixa, { "E2_LOJA"    	, E2_LOJA				, Nil } )	// 06
	AADD( aBaixa, { "AUTMOTBX"  	, cMotivo				, Nil } )	// 07
	AADD( aBaixa, { "AUTBANCO"  	, ""					, Nil } )	// 08
	AADD( aBaixa, { "AUTAGENCIA"  	, ""					, Nil } )	// 09
	AADD( aBaixa, { "AUTCONTA"  	, ""					, Nil } )	// 10
	AADD( aBaixa, { "AUTDTBAIXA"	, dDataBase				, Nil } )	// 11
	AADD( aBaixa, { "AUTHIST"   	, cHistorico			, Nil } )	// 12
	AADD( aBaixa, { "AUTDESCONT" 	, 0						, Nil } )	// 13
	AADD( aBaixa, { "AUTMULTA"	 	, 0						, Nil } )	// 14
	AADD( aBaixa, { "AUTJUROS" 		, 0						, Nil } )	// 15
	AADD( aBaixa, { "AUTOUTGAS" 	, 0						, Nil } )	// 16
	AADD( aBaixa, { "AUTVLRPG"  	, 0        				, Nil } )	// 17
	AADD( aBaixa, { "AUTVLRME"  	, 0						, Nil } )	// 18
	AADD( aBaixa, { "AUTCHEQUE"  	, ""					, Nil } )	// 19
	Pergunte("FIN080",.F.)
	Pergunte("FI415C",.F.)

	aPerg := {}
	AADD(aPerg , mv_par01)
	AADD(aPerg , mv_par02)
	AADD(aPerg , mv_par03)


	lRet :=	MSExecAuto({|a,b,c,d,e,f,g,h,i,j,k,l| Fina080(a,b,c,d,e,f,g,h,i,j,k,l) } ,aBaixa,3,,,,,,,,,,aPerg)
	
Endif

If !lRet 
	MsgAlert(STR0011+chr(13)+chr(10)+STR0012+aBaixa[1][2]+chr(13)+chr(10)+;
	         STR0013+aBaixa[2][2]+chr(13)+chr(10)+STR0014+aBaixa[3][2]+chr(13)+chr(10)+;
            STR0015+aBaixa[4][2])//"Ocorreu um erro na rotina de eliminacao de residuos."###"Prefixo"###"Numero"###"Parcela"###"Tipo"
EndIf

Set Key VK_F12 to

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Fa415Pesq � Autor � Ricardo A. Canteras   � Data �20.01.06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela de pesquisa - WINDOWS 										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 																  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Fa415Pesq(oListBox,aCols,lF5)
Local nAscan := 0
Local oDlg
Local nOpca := 0  
Local nA			:= 0
Local nB			:= 0
Local lFind := .F.
Local bKeyF5	:=  SetKey( VK_F5 )

SetKey(VK_F5,Nil)

Default lF5 := .F.    

If !lF5 .Or. Empty(cTexto)   
	DEFINE MSDIALOG oDlg TITLE STR0023 From 9,2 To 20,70 OF oMainWnd  //"Pesquisa de Titulo"
		@  39, 5  Say STR0024   OF oDlg PIXEL SIZE 50,9  
		@  39, 55 MSGET cTexto  OF oDlg PIXEL PICTURE "@!" 
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca := 0,oDlg:End()}) CENTER
Endif

If nOpca == 1 .Or. lF5 

	If !lF5
		oListBox:nAt := 1
	Else
		oListBox:nAt++ 	           
	EndIf
 	
	For nA:=oListBox:nAt To Len(aCols) // Elemento por Elemendo do aCols
 		For nB:=1 To Len(aCols[nA]) // Cpo por Cpo da linha atual nA do aCols
			If ValType( aCols[nA,nB] ) == 'C'
				lFind  := UPPER(ALLTRIM(cTexto)) $ UPPER(ALLTRIM(aCols[nA,nB]))
 	 			If lFind
 					nAscan := nA 
					Exit
 				EndIf
   			Endif
     	Next nB               
		If lFind
			Exit
		EndIf
   Next nA
   
   // Se encontrou, atualiza a linha do objeto
	If nAscan > 0
		oListBox:nAt := nAscan
		oListBox:Refresh(.T.)
	Else       
		oListBox:nAt--
		Alert(STR0022) 	
	Endif	  

Endif 

SetKey(VK_F5,bKeyF5)

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FA415Disp � Autor � Ricardo A. Canteras   � Data � 20/01/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe Valores na tela        									 	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA415																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fa415Disp(oListBox,aCols)

Local nPos := 0                         
Local nI                                

nValor  := 0    // valor total dos titulos,mostrado no cabe�alho do browse
nQtdTit := 0    // quantidade de titulos,mostrado no cabe�alho do browse

For nI:=1 To Len(aCols)
	If aCols[nI,1]	// Registro Marcado
		nPos     := Ascan(aCpos, IIf(nTipoTit==1,"E1","E2")+"_VALOR")
		nValor 	+= aCols[nI,nPos]			      
		nQtdTit++
	EndIf
Next
	
oValor:Refresh()
oQtda:Refresh()
oListBox:Refresh(.t.)             

Return
