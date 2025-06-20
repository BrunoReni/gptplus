#include "Cdar030.ch"
#include "protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CdaR030  � Autor � Elizabeth A. Eguni    � Data � 21/10/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emissao do contrato de direitos autorais (Royalty).        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CdaR030(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico - controle de Royalty (direito autoral)         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/

Function Cdar030()

SetPrvt("WNREL,NLASTKEY,LI,M_PAG,TAMANHO,TITULO")
SetPrvt("CDESC1,CDESC2,CDESC3,CSTRING,ARETURN,CPERG")
SetPrvt("NOMEPROG,CBTXT,LIMITE,CBCONT,CCONDFILTR,CARQCONTR")
SetPrvt("AALIASCON,CPRODUTO,AVARIAVEIS,NARQ,CALIAS,I")
SetPrvt("ADRIVER,CDRIVER,")

nLastKey   := 0
li         := 80
m_pag      := 1
tamanho    := "P"
titulo     := STR0001 //"Contrato de Direito Autoral (D.A.)"
cDesc1     := STR0002 //"Emissao do Contrato de Direito Autoral.                    "
cDesc2     := STR0003 //"Sera solicitado os parametros necessarios para a emissao do"
cDesc3     := STR0004 //"relatorio. "

cString    := "AH1"
aReturn    := { STR0005, 1,STR0006, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
cPerg      := "CDR030"
nomeprog   := "CDAR030"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("CDR030",.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01    // Produto inicial                               �
//� mv_par02    // Produto final                                 �
//� mv_par03    // Fornecedor inicial                            �
//� mv_par04    // Fornecedor final                              �
//� mv_par05    // Contrato de                                   �
//� mv_par06    // Sequencia                                     �
//� mv_par07    // Contrato ate                                  �
//� mv_par08    // Sequencia                                     �
//� mv_par09    // Arquivo de contrato                           �
//����������������������������������������������������������������

dbSelectArea("AH2")
dbSetOrder(1)      // AH2_FILIAL + AH2_PRODUT + AH2_FORNEC + AH2_LOJAFO + AH2_ITEM

dbSelectArea("AH1")
dbSetOrder(1)      // AH1_FILIAL + AH1_PRODUT + AH1_FORNEC + AH1_LOJAFO

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel := "CDAR030"
SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

If nLastKey == 27
	Return (.T.)
Endif

CbTxt       := SPACE(10)
limite      := 80
cbCont      := 0
li          := 80

SetDefault(aReturn,cString)

If nLastKey == 27
	Return (.T.)
Endif

RptStatus({|| Cr030Imp()})

Return (.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Cr030Imp � Autor � Elizabeth A. Eguni    � Data � 21/10/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CdaR030	  		                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Cr030Imp()

SetRegua(RecCount())

dbSelectArea("AH1")
Set Filter to

Cr030Contr()
	
//����������������������������������������������������������Ŀ
//� Retorna a situacao original.                             �
//������������������������������������������������������������
Set Device to Screen

If aReturn[5] == 1
  	Set Printer TO 
  	dbCommitall()
  	ourspool(wnrel)
Endif

dbSelectArea("AH1")
Set Filter To
dbSetOrder(1)

MS_FLUSH()

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cr030Contr� Autor � Elizabeth A. Eguni    � Data � 21/10/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do Contrato de Direito Autoral                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CdaR030	  		                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Cr030Contr()
Local i := 0
Local nArq := 0
cArqContr := AllTrim(mv_par09) + ".TRM"
aAliasCon := { "SA2", "SB1", "AH1", "AH2" }      // alias do contrato

dbSelectArea("AH1")

SetRegua( RecCount() )

dbSelectArea("AH1")
MsSeek( xFilial("AH1") + mv_par01, .T. )
While 	AH1_FILIAL = xFilial("AH1") 	.And.;
		AH1_PRODUT <= mv_par02 			.And. !Eof()
	DbSelectArea("AH1")

	If ! Empty(aReturn[7]) .And. ! AH1->(&(aReturn[7]))		// Filtro de usuario
		DbSkip()
		Loop
	Endif

	If 	AH1_CONTRA + AH1_SEQCON < mv_par05 + mv_par06 .Or.;
		AH1_CONTRA + AH1_SEQCON > mv_par07 + mv_par08
		DbSkip()
		Loop
	Endif

	//��������������������������������������������������������������Ŀ
	//� Verifica se o produto est� dentro do intervalo.              �
	//����������������������������������������������������������������
	If AH1->AH1_FORNEC < mv_par03 .Or. AH1->AH1_FORNEC > mv_par04
		dbSelectArea("AH1")
		dbSkip()
		Loop
	Endif

	//��������������������������������������������������������������Ŀ
	//� Verifica se o usuario cancelou o relatorio.                  �
	//����������������������������������������������������������������
	If lAbortPrint
		@Prow()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
		Exit  
	Endif

	cProduto := AH1->AH1_PRODUT

	IncRegua()

	dbSelectArea("SA2")
	MsSeek( xFilial("SA2") + AH1->AH1_FORNEC + AH1->AH1_LOJAFO )
	dbSelectArea("SB1")
	MsSeek( xFilial("SB1") + AH1->AH1_PRODUT )
	dbSelectArea("AH2")
	MsSeek( xFilial("AH2") + AH1->AH1_PRODUT + AH1->AH1_FORNEC + AH1->AH1_LOJAFO)
	dbSelectArea("AH1")
		
	If File(cArqContr)
	
		aVariaveis:={}
		For nArq := 1 To Len(aAliasCon)
			cAlias := aAliasCon[nArq]
			dbSelectArea(cAlias)
			For i:=1 to FCount()	
				AADD(aVariaveis,{ ( cAlias + "->" +FieldName(i)),FieldGet(i) } )
			Next
		Next
		
		aDriver:=ReadDriver()
		cDriver:=aDriver[4] // [132E]
		If File(cArqContr)
			Cr030ImpCt(cArqContr,aVariaveis,&cDriver,aAliasCon)
		Endif
	Endif

	dbSelectArea("AH1")
	dbSkip()
End

@ PROW()+1,00 PSAY " "

Return (.T.)