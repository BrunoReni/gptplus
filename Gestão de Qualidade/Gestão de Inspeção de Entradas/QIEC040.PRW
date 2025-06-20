#Include "QIEC040.CH"
#Include "PROTHEUS.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Qiec040  � Autor � Marcelo Pimentel      � Data � 06/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consultas - Entradas por Documento de Entrada              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qiec040                                                    ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Vera        �19/04/99�------� Inclusao da Loja do Fornecedor           ���
���Vera        �18/02/00�------� Filtra Entradas pela Filial tambem       ���
���Paulo Emidio�24/01/01�------� Correcao na abertura dos indices tempora ���
���			   �	    �	   � rio atraves da funcao IndRegua.		  ���
���Paulo Emidio�11/06/01�META  � Incluida a opcao par selecionar o tipo de���
���       	   �		�	   � Entrada a ser considera,se a mesma sera: ���
���       	   �		�	   � 1)Normal 2)Beneficiamento 3)Devolucao 	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()

Local aRotina := {{OemToAnsi(STR0001),"AxPesqui"	,0,1},;	//"Pesquisar"
					 {OemToAnsi(STR0002),"a040IMP"	,0,1}}		//"Imprimir"

Return aRotina

Function qiec040
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local cFiltro := ""

Private Inclui	:=.T.

//��������������������������������������������������������������Ŀ
//� Recupera o desenho padrao de atualizacoes                    �
//����������������������������������������������������������������
cCadastro := OemToAnsi(STR0003)		//"Docum. Entrada"

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
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        // Do Docum. Entrada                         �
//� mv_par02        // At� Docum. Entrada                        �
//� mv_par03        // Data inicial                              �
//� mv_par04        // Data final                                �
//� mv_par05        // Considera Nota Fiscal 1)Normal			 �
//�											 2)Beneficiamento    �
//� 										 3)Devolucao         �
//����������������������������������������������������������������
Pergunte("QEC040",.F.)
If !(Pergunte("QEC040",.T.))
	Return
EndIf

//��������������������������������������������������������������Ŀ
//� Realiza o filtro por documento de Entrada   				 �
//����������������������������������������������������������������
cFiltro += 'QEK_FILIAL == "'+xFilial("QEK")+'"'+'.And.'
If mv_par05 == 1
	cFiltro += '(QEK_TIPONF == " " .Or. QEK_TIPONF == "N")'
ElseIf mv_par05 == 2                                 
	cFiltro += 'QEK_TIPONF == "B"'
ElseIf mv_par05 == 3           
	cFiltro += 'QEk_TIPONF == "D"'
EndIf
cFiltro += '.And. QEK_DOCENT >= "'+mv_par01+'"'
cFiltro += '.And.QEK_DOCENT <= "'+mv_par02+'"'
cFiltro += '.And.Dtos(QEK_DTENTR) >= "'+Dtos(mv_par03)+'"'
cFiltro += '.And.Dtos(QEK_DTENTR) <= "'+Dtos(mv_par04)+'"'  

If ExistBlock("QEC40FIL") 
	cFiltro := ExecBlock("QEC40FIL",.F.,.F.,{cFiltro}) 
EndIF

dbSelectArea("QEK")
dbSetOrder(4)              
MsgRun(STR0015,STR0016,{||dbSetFilter({||&cFiltro},cFiltro)}) //"Selecionando as Entradas..."###"Aguarde..."

dbGoTop()
If Eof()
	Help(" ",1,"RECNO")    
Else
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"QEK")
EndIf	

dbSelectArea("QEK") 
Set Filter To                          

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a040IMP  � Autor � Marcelo Pimentel      � Data � 06/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a impressao da consulta obtida                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � qiec040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function a040IMP()
LOCAL cTitulo :=OemToAnsi(STR0005)		//"Documento de Entrada"
LOCAL cDesc1  := ""
LOCAL cDesc2  :=""
LOCAL cDesc3  :=""
LOCAL wnrel   :="QIEC040"
LOCAL cString :="QEL"

PRIVATE cPerg   :="      "
PRIVATE aReturn := { OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey:=0
PRIVATE cTamanho:= "M"

wnrel:= SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| c040Imp(@lEnd,ctitulo,wnRel)},ctitulo)
Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � c040Imp  � Autor � Marcelo Pimentel      � Data � 06/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que faz a impressao da consulta.         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � qiec040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function c040Imp(lEnd,ctitulo,wnRel)
Local aAreas    :={QE6->(GetArea()), QEK->(GetArea()), QEL->(GetArea()), SA2->(GetArea())}
Local cbcont    := 0
Local cbTxt     := SPACE(10)
Local cCabec1   := ""
Local cNomeProg := "QIEC040"
Local nTipo     := 15

cCabec1 := PADR(FwX3Titulo("QEK_FORNEC"),TAMSX3('A2_NREDUZ')[1]) + Space(1)   //Fornecedor
cCabec1 += PADR(FwX3Titulo("QEK_PRODUT"),TAMSX3('QE6_DESCPO')[1] - 9)         //Produto
cCabec1 += PADR(FwX3Titulo("QEK_DTENTR"),TAMSX3('QEK_DTENTR')[1]) + Space(4)  //Dt Entr.
cCabec1 += PADR(AllTrim(FwX3Titulo("QEK_LOTE"))+'/'+AllTrim(FwX3Titulo("QEK_DOCENT")),  TAMSX3('D1_LOTEFOR')[1]) + Space(2)  //Lote-Lote Fornec.
cCabec1 += FwX3Titulo("QEK_VERIFI")  + Space(3)                               // I/C
cCabec1 += PADR(FwX3Titulo("QEK_PEDIDO"),TAMSX3('QEK_PEDIDO')[1]) + Space(5) //No. Pedido
cCabec1 += FwX3Titulo("QEK_TAMLOT") + Space(1)
cCabec1 += FwX3Titulo("QEL_LAUDO") + Space(4)

Li    := 80
m_pag := 1

DbSelectArea("QEK")
QEK->(dbGoTop())
SetRegua(RecCount()) //Total de Elementos da Regua

While QEK->(!Eof())
	IncRegua()
	If Li > 58 
		Cabec(cTitulo,cCabec1,"",cNomeProg,cTamanho,nTipo,,.F.)
	EndIf

	@Li,000 PSAY QEK->(QEK_FORNEC + " - " + QEK->QEK_LOJFOR)
	@Li,021 PSAY QEK->QEK_PRODUT	
	@Li,052 PSAY QEK->QEK_DTENTR	
	@Li,064 PSAY QEK->QEK_LOTE
	@Li,086 PSAY IIF(QEK->QEK_VERIFI == 1,STR0011,STR0012)		//"Ins"###"Cer"
	@Li,099 PSAY QEK->QEK_PEDIDO
	@Li,116 PSAY QEK->QEK_TAMLOT

	QEL->(dbSetOrder(3))
	If	QEL->(dbSeek(xFilial("QEL")+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+Dtos(QEK_DTENTR)+QEK_LOTE)+Space(TamSx3("QEL_LABOR")[1])))
		@Li,129 PSAY QEL->QEL_LAUDO
	Endif	        

	Li++
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+QEK->(QEK_FORNEC+QEK_LOJFOR)))
		@Li,000 PSAY SA2->A2_NREDUZ
	EndIf	
	QE6->(dbSetOrder(1))
	If QE6->(dbSeek(xFilial("QE6")+QEK->QEK_PRODUT))
		@Li,021 PSAY QE6->QE6_DESCPO
	EndIf

	@Li,064 PSAY QEK->QEK_DOCENT
	Li+=2
	QEK->(dbSkip())

EndDo

If Li != 80 
	Roda(cbcont,cbtxt)
EndIf

Set Device To Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	ourSpool(wnrel)
EndIf

MS_FLUSH()

QEK->(dbGoTop())
aEval(aAreas, {|x| RestArea(x)})
Return .T.
