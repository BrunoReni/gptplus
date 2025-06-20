#include "cdaa020.ch"
#include "protheus.ch"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CDAA020  � Autor � Cristiano G. Cunha    � Data � 04/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de movimentos - Royalty            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACDA - Controle de Direitos Autorais                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CDAA020

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
PRIVATE aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := STR0005 //"Atual. de Movimentacao"

//���������������������������������������������������������Ŀ
//� Salva a Interface                                       �
//�����������������������������������������������������������
SaveInter()

If AMIIn(45)
	mBrowse(6,1,22,75,"AH3")
EndIf

//���������������������������������������������������������Ŀ
//� Restaura a Interface                                    �
//�����������������������������������������������������������
RestInter()

Return (.T.)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CD020Delet� Autor � Cristiano G. Cunha    � Data � 04/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que deleta as movimentacoes                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CD020Delet(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CDAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CD020Deleta(cAlias,nReg,nOpc)

Local bCampo
Local nOpcA
Local cCod
Local oDlg 
Local aSize := MSADVSIZE()
Local aObjects := {}      
Local aInfo
Local aPosObj
Local lRetorno := .T.

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTela[0][0]
PRIVATE aGets[0]
bCampo := {|nCPO| Field(nCPO)}         

AAdd( aObjects, { 100, 100, .t., .t. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA := 0

DEFINE MSDIALOG oDlg TITLE cCadastro  From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

nOpcA := EnChoice(cAlias,nReg,nOpc,,"AC",STR0006,,aPosObj[1]) //"Quanto � exclus�o?"
nOpca := 1

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})   


dbSelectArea(cAlias)

IF nOpcA == 2

	dbSelectArea("SE2")
	dbSetOrder(1)
	dbSeek(xFilial("SE2")+AH3->AH3_PREFIX+AH3->AH3_NOTITU+AH3->AH3_FORNEC+AH3->AH3_LOJAFO)
	
	//�����������������������������������������������������������������������������Ŀ
	//� Verifica se titulo ja foi baixado total ou parcialmente                     �
	//�������������������������������������������������������������������������������
	If AllTrim(SE2->E2_ORIGEM) == "CDAA020" .And. !Empty(SE2->E2_BAIXA) .And. lRetorno 
		Help(" ",1,"FA050BAIXA")
		lRetorno := .F.
	EndIf          
	
	If SE2->E2_VALOR <> SE2->E2_SALDO .And. lRetorno
		Help(" ",1,"BAIXAPARC")
		lRetorno := .F.
	EndIf

	IF lRetorno 

		BEGIN TRANSACTION
		
		//��������������������������������������������������������������Ŀ
		//� Acumula em adiantamento, se este for debito e valor.         �
		//����������������������������������������������������������������
		If AH3->AH3_TIPOMO == "1"
			dbSelectArea("AH1")
			dbSeek(xFilial("AH1")+AH3->AH3_PRODUT+AH3->AH3_FORNEC+AH3->AH3_LOJAFO)
			If AH1->(!Eof())
				RecLock("AH1",.F.)
				AH1_VALADI := AH1_VALADI - AH3->AH3_VALOR
				AH1_SALDOA := AH1_SALDOA - AH3->AH3_VALOR
				If AH3->AH3_TIPOPA == "1"
					AH1_SALDQT := AH1_SALDQT - AH3->AH3_EXEMPL
				Endif
				MsUnLock()
			Endif
		Endif
		
		//��������������������������������������������������������������Ŀ
		//� Apos passar por todas as verificacoes , deleta o registro    �
		//����������������������������������������������������������������
		dbSelectArea( cAlias )
		RecLock(cAlias,.F.,.t.)
		dbDelete()
		
		dbSelectArea("SE2")
		dbSetOrder(1)
		dbSeek(xFilial("SE2")+AH3->AH3_PREFIX+AH3->AH3_NOTITU)
		nRegDelet := 0
		While SE2->E2_PREFIXO+SE2->E2_NUM == AH3->AH3_PREFIX+AH3->AH3_NOTITU .And. SE2->(!Eof())
			If SE2->E2_FORNECE+SE2->E2_LOJA == AH3->AH3_FORNEC+AH3->AH3_LOJAFO .And. AllTrim(SE2->E2_ORIGEM) == "CDAA020"
				CD020DelE2()
			Endif
			dbSkip()
		End
		
		END TRANSACTION
	EndIf		
EndIf

dbSelectArea( cAlias )

Return nOpca

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CD020IniLj� Autor � Cristiano G. Cunha    � Data � 04/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa o numero da loja                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CDAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CD020IniLj()

Local nX
Local nEndereco := 0
Local cLojaFor  := ""
Local cCampo    := &(ReadVar())
Local lRet      := .T.
Local aArea     := GetArea()

If Empty(cCampo)
	cLojaFor := "  "
Else
	dbSelectarea("SA2")
	dbSetOrder(1)
	If dbSeek(xFilial("SA2")+cCampo)	
		cLojaFor := SA2->A2_LOJA
	Else	
		Help( " ",1,"REGNOIS")
		lRet := .F.	
	Endif	
Endif
M->AH3_LOJAFO := cLojaFor

nEndereco := aScan(aGets,{|x| Subs(x,9,10) == "AH3_LOJAFO"})
If nEndereco > 0
	aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := cLojaFor
EndIf

lRefresh := .T. 
RestArea(aArea)

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CD020ChkLj� Autor � Cristiano G. Cunha    � Data � 04/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Checa se a loja esta' cadastrada para o fornecedor digitado���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CDAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CD020ChkLj()

Local cFornece := M->AH3_FORNEC
Local cLojaFor := &(ReadVar())
Local lRet     := .T.

lRet := ExistCpo("SA2",cFornece+cLojaFor)

Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CD020Inclu� Autor � Cristiano G. Cunha    � Data � 04/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que inclui as movimentacoes                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CD020Inclu(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CDAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CD020Inclu(cAlias,nReg,nOpc)

Local nOpcA := 0
Local aAcho := {}

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE cTipoTit
PRIVATE cNaturez
PRIVATE aTela[0][0]
PRIVATE aGets[0]
Private cNumero

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA := 0

aAcho := {"AH3_PRODUT","AH3_FORNEC","AH3_LOJAFO","AH3_DATA","AH3_VALOR",;
"AH3_EXEMPL","AH3_TIPOMO","AH3_HISTOR","AH3_TIPOPA","AH3_GERATI","AH3_MDATIT"}

nOpcA := AxInclui(cAlias,nReg,nOpc,aAcho,,,"CD020ChkTit()")

//��������������������������������������������������������������Ŀ
//� Debito de adiantamento, acumula nos valores de adiantamento. �
//����������������������������������������������������������������
If AH3->AH3_TIPOMO == "1" .And. nOpcA == 1
	dbSelectArea("AH1")
	dbSeek( xFilial("AH1")+AH3->AH3_PRODUT+AH3->AH3_FORNEC+AH3->AH3_LOJAFO )
	If AH1->(!Eof())
		RecLock("AH1",.F.)
		AH1_VALADI := AH1_VALADI + AH3->AH3_VALOR
		If AH3->AH3_TIPOPA != "1"    // Valor
			AH1_SALDOA := AH1_SALDOA + AH3->AH3_VALOR
		ElseIf AH3->AH3_TIPOPA == "1"
			AH1_SALDQT := AH1_SALDQT + AH3->AH3_EXEMPL
			AH1_ADTOIN := AH1_ADTOIN + AH3->AH3_EXEMPL
		Endif
		MsUnLock()
	Endif

	If ExistBlock("CD020ADI")
		ExecBlock("CD020ADI",.F.,.F.)
	EndIf
EndIf

If AH3->AH3_GERATI == "1" .And. nOpcA == 1 .And. AH3->AH3_TIPOMO == "1"
	
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                         �
	//� mv_par01 // tipo do titulo                                   �
	//� mv_par02 // natureza do titulo                               �
	//� mv_par03 // prazo de pagamento do titulo                     �
	//����������������������������������������������������������������
	cTipoTit := mv_par01
	cNaturez := mv_par02
	
	//��������������������������������������������������������������Ŀ
	//� Funcao que retorna o nro. do titulo a ser gerado, esta       �
	//� funcao esta definida no programa CDAA040.PRX                 �
	//����������������������������������������������������������������
	//PRIVATE cNumero
	//	cNumero := CD040NoDoc()
	
	//	cNumero := Iif(ValType(cNumero) == "L","000000",cNumero)
	
	//��������������������������������������������������������������Ŀ
	//� Retorna numero do titulo (royalty) p/ o arq. de Tabelas      �
	//����������������������������������������������������������������
	dbSelectArea("SX5")
	dbSeek(xFilial("SX5") + GetMv("MV_CDANUME") )
	RecLock("SX5",.F.)
	X5_DESCRI := StrZero(Val(cNumero)+1,TamSX3("F2_DOC")[1])
	MsUnLock()
	
	//��������������������������������������������������������������Ŀ
	//� Grava o numero do titulo a pagar.                            �
	//����������������������������������������������������������������
	SA2->(dbSeek(xFilial("SA2")+AH3->AH3_FORNEC+AH3->AH3_LOJAFO))
	
	//��������������������������������������������������������������Ŀ
	//� Geracao de titulo no contas a pagar.                         �
	//����������������������������������������������������������������
	nValor := xMoeda(AH3->AH3_VALOR,AH1->AH1_MOEDRO,AH3->AH3_MDATIT,AH3->AH3_DATA)
	
	nValIRRF := 0
	If SA2->A2_TIPO == "F"    // Pessoa Fisica
		aTabela  := CD040AbrIR()
		nValIRRF := CD040CalIR(nValor,aTabela,AH3->AH3_DATA)
		cMdaRoy  := AllTrim(Str(AH3->AH3_MDATIT,2))
		cMdaOri  := AllTrim(Str(AH1->AH1_MOEDRO,2))
		nValIRRF := xMoeda(nValIRRF,Val(cMdaOri),Val(cMdaRoy),AH3->AH3_DATA)
	Else
		nValIRRF := 0
	Endif
	If SA2->A2_TXTRIBU > 0
		nValIRRF := nValIRRF + Round(nValor * SA2->A2_TXTRIBU / 100,2)
	Endif
	
	cNoTitulo := CD040CtPag(nValor,nValIRRF,AH3->AH3_FORNEC,AH3->AH3_LOJAFO,AH3->AH3_MDATIT,mv_par03,"CDAA020",AH3->AH3_DATA)
	
	
	dbSelectArea("AH3")
	RecLock("AH3",.F.)
	AH3_PREFIX := Substr(cNoTitulo,1,TamSX3("E2_PREFIXO")[1])
	AH3_NOTITU := Substr(cNoTitulo,(TamSX3("E2_PREFIXO")[1])+1,TamSX3("E2_NUM")[1]) 	
	MsUnLock()
	
Endif

dbSelectArea(cAlias)

Return (.T.)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CD020Altera� Autor � Cristiano G. Cunha   � Data � 04/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que altera as movimentacoes                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CD020Altera(ExpC1,ExpN1,ExpN2)                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CDAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CD020Alter(cAlias,nReg,nOpc)

Local nOpcA  := 0
Local nValor := 0
Local nQtde  := 0

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTela[0][0]
PRIVATE aGets[0]

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA := 0

nValor := AH3->AH3_VALOR
nQtde  := AH3->AH3_EXEMPL

nOpcA := AxAltera(cAlias,nReg,nOpc)

//��������������������������������������������������������������Ŀ
//� Debito de adiantamento, acumula nos valores de adiantamento. �
//����������������������������������������������������������������
If AH3->AH3_TIPOMO == "1" .And. nOpcA == 1
	dbSelectArea("AH1")
	dbSeek(xFilial("AH1")+AH3->AH3_PRODUT+AH3->AH3_FORNEC+AH3->AH3_LOJAFO)
	If AH1->(!Eof())
		RecLock("AH1",.F.)
		AH1_VALADI := AH1_VALADI + AH3->AH3_VALOR - nValor
		AH1_SALDOA := AH1_SALDOA + AH3->AH3_VALOR - nValor
		If AH3->AH3_TIPOPA == "1"
			AH1_SALDQT := AH1_SALDQT + AH3->AH3_EXEMPL - nQtde
		Endif
		MsUnLock()
	Endif
EndIf
dbSelectArea(cAlias)

Return (.T.)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CD020ValTp� Autor � Cristiano G. Cunha    � Data � 04/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que valida o tipo do titulo a pagar a ser gerado    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CD020ValTp()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CDAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CD020ValTp

cTipo := &(ReadVar())

Return ExistCpo("SX5","05"+cTipo)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CD020Natur� Autor � Cristiano G. Cunha    � Data � 04/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que valida a natureza do titulo a ser gerado        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CD020Natur()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CDAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CD020Natur

cNatureza := &(ReadVar())

Return ExistCpo("SED")


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CD020Prazo� Autor � Cristiano G. Cunha    � Data � 04/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que valida o prazo do titulo a pagar a ser gerado   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CD020Prazo()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CDAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CD020Prazo

cPrzPagto := &(ReadVar())

Return ExistCpo("SE4",cPrzPagto)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CD020DelE2� Autor � Cristiano G. Cunha    � Data � 04/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que deleta os dados do titulo a pagar               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CD020Prazo()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CDAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

FUNCTION CD020DelE2

Local nTotal    :=0
Local nHdlPrv   :=0
Local cAlias    := Alias()
Local cNatureza := SE2->E2_NATUREZ
Local cPadrao
Local cArquivo
Local lDigita
Local lPadrao

//��������������������������������������������������������������Ŀ
//� Verifica o numero do Lote                                    �
//����������������������������������������������������������������
PRIVATE cLote
LoteCont( "FIN" )

cPrefixo  := E2_PREFIXO
cNum      := E2_NUM
cParcela  := E2_PARCELA
cNatureza := E2_NATUREZ
cFornece  := E2_FORNECE
cTipo     := E2_TIPO
cParcIr   := Iif( Empty( E2_PARCIR ), cParcela, SE2->E2_PARCIR )
nIss      := SE2->E2_ISS
nMoeda    := Int(Val(GetMv("MV_MCUSTO")))

PRIVATE aHeader := {}

//�����������������������������������������������������Ŀ
//� Verifica se o titulo PA pode ser baixado            �
//�������������������������������������������������������
If Substr(SE2->E2_TIPO,1,2) == "PA"
	dbSelectArea("SE5")
	dbSetOrder(4)
	If dbSeek(xFilial("SE5")+SE2->E2_NATUREZ+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO)
		dbSelectArea( "SA6" )
		dbSeek(xFilial("SA6")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA)
		dbSelectArea("SEF")
		dbSetOrder(2)
		If (dbSeek(xFilial("SEF")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+DTOS(SE2->E2_EMISSAO)))
			While !Eof() .and. EF_FILIAL==cFilial .and. ;
				EF_BANCO+EF_AGENCIA+EF_CONTA+DtoS(EF_DATA) == ;
				SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+DTOS(SE5->E5_DATA)
				If EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO == SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
					If SEF->EF_IMPRESS == "S"
						HELP(" ",1,"FA050DELPA")
						Return Nil
					Endif
				Endif
				dbSkip()
			Enddo
			dbSelectArea("SEF")
			dbSkip()
		Endif
	Endif
Endif

//�����������������������������������������������������Ŀ
//� Inicio do bloco protegido via TTS                   �
//�������������������������������������������������������
BEGIN TRANSACTION

dbSelectArea("SE2")
If SubStr(E2_TIPO,1,2) != "PR"
	//�����������������������������������������������������Ŀ
	//� Posiciona no registro referente ao Fornecedor       �
	//�������������������������������������������������������
	dbSelectArea("SA2")
	dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
	dbSelectArea("SE2")
	cPadrao := GetMv("MV_CDAEXCL")
	lPadrao := VerPadrao(cPadrao)
	IF lPadrao .and. SubStr(SE2->E2_LA,1,1) == "S"
		nHdlPrv := HeadProva(cLote,"CDAA020",cUserName,@cArquivo)
		nTotal  += DetProva(nHdlPrv,cPadrao,"CDAA020",cLote)
		RodaProva(nHdlPrv,nTotal)
		//�����������������������������������������������������Ŀ
		//� Envia para Lan�amento Cont�bil                      �
		//�������������������������������������������������������
		lDigita := IIF(mv_par01 == 1,.T.,.F.)
		cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.)
	Endif
	If !cNatureza$GetMv("MV_IRF")
		RecLock("SA2")
		If Substr(SE2->E2_TIPO,1,2) != "PA" .and. SubStr(SE2->E2_TIPO,3,1) != "-" .and. SE2->E2_TIPO != "NDF"
			SA2->A2_SALDUP  -= xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,SE2->E2_EMISSAO)
			SA2->A2_SALDUPM -= xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,nMoeda,SE2->E2_EMISSAO)
		Else
			SA2->A2_SALDUP  += xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,SE2->E2_EMISSAO)
			SA2->A2_SALDUPM += xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,nMoeda,SE2->E2_EMISSAO)
		Endif
	Endif
Endif

//�����������������������������������������������������Ŀ
//� Faz tratamento do titulos de Recebimento antecipado �
//�������������������������������������������������������
If Substr(SE2->E2_TIPO,1,2) == "PA"
	dbSelectArea("SE5")
	dbSetOrder(4)
	If dbSeek(xFilial("SE5")+SE2->E2_NATUREZ+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO)
		AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"+")
		
		//�����������������������������������������������������Ŀ
		//� Excluir registro do cheque gerado.                  �
		//�������������������������������������������������������
		dbSelectArea("SEF")
		dbSetOrder(2)
		If (dbSeek(xFilial("SEF")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+DtoS(SE2->E2_EMISSAO)))
			While !Eof() .and. EF_FILIAL == xFilial("SEF") .And. ;
				EF_BANCO+EF_AGENCIA+EF_CONTA+DtoS(EF_DATA) == ;
				SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+DTOS(SE5->E5_DATA)
				If EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO == SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
					RecLock("SEF",.F.,.T.)
					dbDelete( )
					Exit
				EndIf
				dbSelectArea("SEF")
				dbSkip()
			End
		EndIf
		dbSetOrder( 1 )
		RecLock("SE5",.F.,.T.)
		dbDelete( )
		dbSetOrder( 1 )
	EndIf
EndIf

//��������������������������������������������Ŀ
//� Apaga o registro                           �
//����������������������������������������������
dbSelectArea(cAlias)
RecLock(cAlias ,.F.,.T.)
dbDelete()

//Apaga tambem os registros agregados-SE2
nCntDele := 0
dbSelectArea("SE2")
dbSeek(xFilial("SE2")+cPrefixo+cNum+cParcela)
While !EOF() .And. E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA == ;
	xFilial("SE2")+cPrefixo+cNum+cParcela
	If SubStr(E2_TIPO,3,1) = "-" .And. E2_FORNECE == cFornece
		RecLock("SE2",.F.,.T.)
		dbDelete()
		nCntDele++
		dbSelectArea("SA2")
		Reclock("SA2")
		SA2->A2_SALDUP  += xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,SE2->E2_EMISSAO)
		SA2->A2_SALDUPM += xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,nMoeda,SE2->E2_EMISSAO)
		dbSelectArea("SE2")
	EndIf
	dbSkip()
Enddo

If !cNatureza $ GetMv("MV_IRF")
	//��������������������������������������������Ŀ
	//� Apaga tambem os registros de impostos      �
	//����������������������������������������������
	nCntDele := 0
	dbSelectArea("SE2")
	dbSeek(xFilial("SE2")+cPrefixo+cNum+cParcIr+"TX ")
	While !EOF() .And. E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO== ;
		xFilial("SE2")+cPrefixo+cNum+cParcIr+"TX "
		IF E2_NATUREZ = GetMv("MV_IRF")
			RecLock("SE2",.F.,.T.)
			dbDelete()
			nCntDele++
		EndIF
		dbSkip()
	EndDo
Endif

//����������������������������������������������������Ŀ
//� Final do bloco protegido via TTS                   �
//������������������������������������������������������
END TRANSACTION

dbSelectArea(cAlias)

Return (.T.)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CA020VldPrd�Autor  � Adriano Ueda         � Data � 12/08/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que corrige o erro na funcao PMSAtuSX3()            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CA020VldPrd()                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CDAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CA020VldPrd()
Return IIf(Empty(M->AH3_FORNEC) .Or. Empty(M->AH3_LOJAFO),.T.,ExistCpo("AH1",M->AH3_PRODUT+M->AH3_FORNEC+M->AH3_LOJAFO)).And.ExistCpo('SB1')


Function CD020ChkTit()
Local lRet := .T., xRet := ""

If M->AH3_DATA <= GetMv("MV_CDAFECH")
	HELP(" ",1,"CD030DTINV")
	lRet := .F.
EndIf

If lRet 
	If M->AH3_GERATI == "1" .And. M->AH3_TIPOMO == "1"
		xRet := CD040NoDoc()
		If ValType(xRet) == "L"
			lRet := !xRet
		Else
			lRet := .T.
		EndIf
		If lRet
			//��������������������������������������������������������������Ŀ
			//� Carrega as perguntas selecionadas                            �
			//����������������������������������������������������������������
			If !CA020Perg()
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf


Return lRet

Function CA020Perg()
Local lRet	:= .T.
Local lOk	:= .F.

While !lOk 
	If !Pergunte("CDA020",.T.)
		lRet := .F.
		Exit		
	EndIf
	lOk := ExistCpo("SX5","05"+mv_par01)
    If lOk
		lOk := ExistCpo("SED",mv_par02)
	EndIf
	If lOk
		lOk := ExistCpo("SE4",mv_par03)
	EndIf
End

Return lRet

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
               
Private aRotina := {	{ STR0001,"AxPesqui"   ,0,1,0,.F.},; // "Pesquisar"
							{ STR0002,"AxVisual"   ,0,2,0,NIL},; // "Visualizar"
							{ STR0003,"CD020Inclui",0,3,0,NIL},; // "Incluir"
							{ STR0004,"CD020Deleta",0,5,0,NIL} } // "Excluir"
     
If ExistBlock("CD020MNU")
	ExecBlock("CD020MNU",.F.,.F.)
EndIf

Return(aRotina)