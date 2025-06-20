#Include "QIEC030.CH"
#include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Qiec030  � Autor � Marcelo Pimentel      � Data � 06/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consultas - Entradas Inspecionadas                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qiec030                                                    ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Vera        �19/04/99�------� Inclusao da Loja do Fornecedor           ���
���Vera        �18/02/00�------� Filtra Entradas pelo campo QEK_VERIFI = 1���
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

Local aRotina := {{OemToAnsi(STR0001),"AxPesqui"	,	0 , 1},; //"Pesquisar"
					 {OemToAnsi(STR0002),"a030IMP"	,	0 , 1}}	  //"Imprimir"

Return aRotina

Function qiec030
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Private cFiltro := " "             			
Private Inclui  := .T.

//��������������������������������������������������������������Ŀ
//� Recupera o desenho padrao de atualizacoes                    �
//����������������������������������������������������������������
cCadastro := OemToAnsi(STR0003)		//"Entradas inspecionadas"

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
//� mv_par01        // Data inicial                              �
//� mv_par02        // Data final                                �
//� mv_par03        // Considera Nota Fiscal 1) Normal			 �
//� 										 2) Beneficiamento   �
//� 										 3) Devolucao        �
//� mv_par04        // Considera Lotes a Vencer					 �
//� mv_par05        // Dias p/ os lotes a Vencer				 �
//� mv_par06        // Produto De  		                 		 �
//� mv_par07        // Produto Ate				                 �
//� mv_par08        // Fornecedor De                   			 �
//� mv_par09        // Loja De                         			 �
//� mv_par10        // Fornecedor Ate                  			 �
//� mv_par11        // Loja Ate                        			 �
//����������������������������������������������������������������

Pergunte("QEC030",.F.)
If !(Pergunte("QEC030",.T.))
	Return
EndIf

//��������������������������������������������������������������Ŀ
//� Realiza o filtro das Entradas Inspecionadas 				 �
//����������������������������������������������������������������
cFiltro := 'QEK_FILIAL == "'+xFilial("QEK")+'"'+'.And.'
If mv_par03 == 1
	cFiltro += '(QEK_TIPONF == " " .Or. QEK_TIPONF == "N")'
ElseIf mv_par03 == 2                                   
	cFiltro += 'QEK_TIPONF == "B"'
ElseIf mv_par03 == 3
	cFiltro += 'QEK_TIPONF == "D"'
EndIf

cFiltro += '.And. Dtos(QEK_DTENTR) >= "'+Dtos(mv_par01)+'"'
cFiltro += '.And.Dtos(QEK_DTENTR) <= "'+Dtos(mv_par02)+'"'                         

cFiltro += '.And. QEK_PRODUT >= "'+mv_par06+'"'                         
cFiltro += '.And. QEK_PRODUT <= "'+mv_par07+'"'                         

cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR >= "'+mv_par08+mv_par09+'"'                         
cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR <= "'+mv_par10+mv_par11+'"'                         

cFiltro += '.And. QEK_VERIFI == 1 .And. QEK_SITENT # "1" .And. QEK_SITENT # "4" .And. QEK_SITENT # "7" .And. QEK_SITENT # "8"'
cFiltro += '.And. C030PosLau()'
If mv_par04 == 1
	cFiltro += '.And. Dtos(QEL->QEL_DTVAL) <= "'+Dtos(dDataBase+mv_par05)+'"'
EndIf

If ExistBlock("QEC30FIL") 
	cFiltro := ExecBlock("QEC30FIL",.F.,.F.,{cFiltro}) 
EndIF

dbSelectArea("QEK")
dbSetOrder(2)                                                    

dbGoTop()
If Eof()
	Help(" ",1,"RECNO")   
Else
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse(6,1,22,75,"QEK",,,,,,,,,,,,,,,,,,cFiltro)                                     
EndIf	        


dbSelectArea("QEK") 
Set Filter To

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a030IMP  � Autor � Marcelo Pimentel      � Data � 06/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a impressao da consulta obtida                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � qiec030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function a030IMP()
LOCAL cTitulo := OemToAnsi(STR0005)		//"ENTRADAS INSPECIONADAS"
LOCAL cDesc1  := OemToAnsi(STR0006)		//"Este programa ira imprimir a Consulta das Entradas"
LOCAL cDesc2  := OemToAnsi(STR0007)		//"Inspecionadas."
LOCAL cDesc3  := ""
LOCAL wnrel   := "QIEC030"
LOCAL cString := "QEK"

PRIVATE cPerg   := " "
PRIVATE aReturn := { OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey:= 0
PRIVATE cTamanho:= "M"

wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,.F.) 

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| c030Imp(@lEnd,ctitulo,wnRel)},ctitulo)
Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � c030Imp  � Autor � Marcelo Pimentel      � Data � 06/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que faz a impressao da consulta.         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � qiec030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function c030Imp(lEnd,ctitulo,wnRel)
Local aAreas   := {QE6->(GetArea()), QEK->(GetArea()), QEL->(GetArea()), SA2->(GetArea())}

Local cCabec1  := ""
Local cNomeProg:= "QIEC030"
Local cbTxt    := SPACE(10)
Local cbcont   := 0
Local nTipo    := 15


cCabec1 := PADR(FwX3Titulo("QEK_FORNEC"),TAMSX3('A2_NREDUZ')[1]) + Space(1)   //Fornecedor
cCabec1 += PADR(FwX3Titulo("QEK_PRODUT"),TAMSX3('QE6_DESCPO')[1] - 9)         //Produto
cCabec1 += PADR(FwX3Titulo("QEK_DTENTR"),TAMSX3('QEK_DTENTR')[1]) + Space(4)  //Dt Entr.
cCabec1 += PADR(AllTrim(FwX3Titulo("QEK_LOTE"))+'/'+AllTrim(FwX3Titulo("QEK_DOCENT")),  TAMSX3('D1_LOTEFOR')[1]) + Space(2)  //Lote-Lote Fornec.
cCabec1 += FwX3Titulo("QEK_VERIFI")  + Space(4)                               // I/C
cCabec1 += PADR(FwX3Titulo("QEK_PEDIDO"),TAMSX3('QEK_PEDIDO')[1]) + Space(08) //No. Pedido
cCabec1 += FwX3Titulo("QEK_TAMLOT") + Space(4)

  

Li    := 80
m_pag := 1

dbSelectArea("QEK")
dbGoTop()
SetRegua(RecCount()) //Total de Elementos da Regua

While !Eof()
				
	IncRegua()
	If Li > 58 
		Cabec(cTitulo,cCabec1,"",cNomeProg,cTamanho,nTipo,,.F.)
	EndIf
	@Li,000 PSAY QEK->QEK_FORNEC	+ " - " + QEK_LOJFOR
	@Li,021 PSAY QEK->QEK_PRODUT	
	@Li,052 PSAY QEK->QEK_DTENTR
	@Li,064 PSAY QEK->QEK_LOTE
	@Li,086 PSAY IIF(QEK->QEK_VERIFI == 1,STR0011,STR0012)		//"Ins"###"Cer"
	@Li,103 PSAY QEK->QEK_PEDIDO
	@Li,120 PSAY QEK->QEK_TAMLOT
	@Li,129 PSAY QEL->QEL_LAUDO

	Li++
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR))
		@Li,000 PSAY SA2->A2_NREDUZ
	EndIf	
	QE6->(dbSetOrder(1))
	If QE6->(dbSeek(xFilial("QE6")+QEK->QEK_PRODUT))
		@Li,021 PSAY QE6->QE6_DESCPO
	EndIf
	@Li,064 PSAY QEK->QEK_DOCENT
	Li+=2
	dbSkip()
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

dbSelectArea("QEK")
dbGoTop() 
MS_FLUSH()             
aEval(aAreas, {|x| RestArea(x)})

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C030Laudo� Autor � Marcelo Pimentel      � Data � 06.05.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Apresenta o Laudo do QEL.                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Function C030Laudo()
Local cRet	 :=""
Local cSeek  := ""

QEL->(DbSetOrder(3))
cSeek := QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF+QEK->QEK_TIPONF+DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE+;
Space(TamSX3("QEL_LABOR")[1])

QEL->(dbSetOrder(1))
If	QEL->(dbSeek(xFilial("QEL")+cSeek))
	cRet := QEL->QEL_LAUDO
EndIf

Return cRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C030PosLau� Autor � Paulo Emidio de Barros� Data �28/11/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Posiciona No Laudo Final da Entrada Inspecionada           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Function C030PosLau() 

QEL->(dbSetOrder(3))
QEL->(MsSeek(xFilial("QEL")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF+QEK->QEK_TIPONF+Dtos(QEK->QEK_DTENTR)+QEK->QEK_LOTE+Space(TamSx3("QEL_LABOR")[1])))

Return(.T.)
