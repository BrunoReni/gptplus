#Include "QIEC020.CH"
#include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEC020  � Autor � Marcelo Pimentel      � Data � 06/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consultas - Entradas em Skip-Lote                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEC020                                                    ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Vera        �19/04/99�------� Inclusao da Loja do Fornecedor           ���
���Vera        �18/02/00�------� Filtra Entradas pelo campo QEK_VERIFI = 2���
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
				 {OemToAnsi(STR0002),"a020IMP"	,	0 , 1}}	  //"Imprimir"

Return aRotina

Function QIEC020
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local cFiltro := ""                      

Private Inclui	:=.T.

//��������������������������������������������������������������Ŀ
//� Recupera o desenho padrao de atualizacoes                    �
//����������������������������������������������������������������
cCadastro := OemToAnsi(STR0003) //"Entradas em Skip-Lote"

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

Pergunte("QEC020",.F.)       
If !(Pergunte("QEC020",.T.))
	Return
EndIf

//��������������������������������������������������������������Ŀ
//� Realiza  o filtro das Entradas em Skip-Lote					 �
//����������������������������������������������������������������
cFiltro += 'QEK_FILIAL == "'+xFilial("QEK")+'"'+'.And.'
If mv_par03 == 1
	cFiltro += '(QEK_TIPONF == " " .Or. QEK_TIPONF == "N")' 
ElseIf mv_par03 == 2
	cFiltro += 'QEK_TIPONF == "B"' 
ElseIf mv_par03 == 3
	cFiltro += 'QEK_TIPONF == "D"' 
EndIf
cFiltro += '.And. Dtos(QEK_DTENTR) >= "'+Dtos(mv_par01)+'"'
cFiltro += '.And. Dtos(QEK_DTENTR) <= "'+Dtos(mv_par02)+'"' 

cFiltro += '.And. QEK_PRODUT >= "'+mv_par04+'"'                         
cFiltro += '.And. QEK_PRODUT <= "'+mv_par05+'"'                         

cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR >= "'+mv_par06+mv_par07+'"'                         
cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR <= "'+mv_par08+mv_par09+'"'                         

cFiltro += '.And. QEK_VERIFI == 2'      

If ExistBlock("QEC20FIL") 
	cFiltro := ExecBlock("QEC20FIL",.F.,.F.,{cFiltro}) 
EndIF

//����������������������������������������������������������Ŀ
//� Fecha o Arq. QEK p/ criar o QEK com Arq. de Trabalho     �
//������������������������������������������������������������
dbSelectArea("QEK")
dbSetOrder(1)                              
MsgRun(STR0014,STR0015,{||dbSetFilter({||&cFiltro},cFiltro)}) //"Selecionando as Entradas..."###"Aguarde..."

dbGoTop()
If Eof()
	Help(" ",1,"RECNO")   
Else
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"QEK" )
EndIf

dbSelectArea("QEK")
Set Filter To

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � a020IMP  � Autor � Marcelo Pimentel      � Data � 06/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a impressao da consulta obtida                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEC020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function a020IMP()
LOCAL cTitulo  :=OemToAnsi(STR0005)		//"ENTRADAS EM SKIP-LOTE"
LOCAL cDesc1   :=OemToAnsi(STR0006)		//"Este programa ira imprimir a Consulta de Entradas em"
LOCAL cDesc2   :=OemToAnsi(STR0007)		//"Skip-Lote."
LOCAL cDesc3   :=""
LOCAL wnrel    :="QIEC020"
LOCAL cString  :="QEL"

PRIVATE cPerg   :="      "
PRIVATE aReturn := {OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
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

RptStatus({|lEnd| C020Imp(@lEnd,ctitulo,wnRel)},ctitulo)
Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C020Imp  � Autor � Marcelo Pimentel      � Data � 06/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que faz a impressao da consulta.         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEC020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C020Imp(lEnd,ctitulo,wnRel)
Local aArea			:= GetArea()
Local aAreas        := {QE6->(GetArea()), QEK->(GetArea()), QEL->(GetArea()), SA2->(GetArea())}
Local CbCont		:= 0
Local cbTxt			:= SPACE(10)
Local cSeek    		:= ""
Private cCabec1		:= ''		//"Fornecedor           Produto                               Dt Entr.   Lote            Doc.Entrada     I/C Pedido     Tam.Lote Laudo"
Private cCabec2		:= ""
Private	cNomeprog	:= "QIEC020"
Private cTamanho	:= "M"
Private nTipo       := 15


cCabec1 := PADR(FwX3Titulo("QEK_FORNEC"),TAMSX3('A2_NREDUZ')[1]) + Space(1)   //Fornecedor
cCabec1 += PADR(FwX3Titulo("QEK_PRODUT"),TAMSX3('QE6_DESCPO')[1] - 9)         //Produto
cCabec1 += PADR(FwX3Titulo("QEK_DTENTR"),TAMSX3('QEK_DTENTR')[1]) + Space(4)  //Dt Entr.
cCabec1 += PADR(AllTrim(FwX3Titulo("QEK_LOTE"))+'/'+AllTrim(FwX3Titulo("QEK_DOCENT")),  TAMSX3('D1_LOTEFOR')[1]) + Space(2)  //Lote-Lote Fornec.
cCabec1 += FwX3Titulo("QEK_VERIFI")  + Space(4)                               // I/C
cCabec1 += PADR(FwX3Titulo("QEK_PEDIDO"),TAMSX3('QEK_PEDIDO')[1]) + Space(08) //No. Pedido
cCabec1 += FwX3Titulo("QEK_TAMLOT")                                           //Tam. Lote 


//�������������������������������������������������������������������Ŀ
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//���������������������������������������������������������������������

Li     := 80
m_pag  := 1
dbSelectArea("QEK")
QEK->(dbGoTop())
SetRegua(QEK->(RecCount())) //Total de Elementos da Regua


While !QEK->(Eof())
	IncRegua()
	If Li > 58 
		Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.)
	EndIf
	@Li,000 PSAY QEK->QEK_FORNEC + " - " + QEK->QEK_LOJFOR
	@Li,021 PSAY QEK->QEK_PRODUT	
	@Li,052 PSAY QEK->QEK_DTENTR	
	@Li,064 PSAY QEK->QEK_LOTE
	@Li,084 PSAY IIF(QEK_VERIFI == 1,STR0011,STR0012)		//"Ins"###"Cer"
	@Li,100 PSAY QEK->QEK_PEDIDO
	@Li,118 PSAY QEK->QEK_TAMLOT PICTURE PesqPict("QEK","QEK_TAMLOT")
	

	QEL->(DbSetOrder(3))
	cSeek := QEK->(QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF+QEK->QEK_TIPONF+DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE)+;
	Space(TamSX3("QEL_LABOR")[1])

	If	QEL->(dbSeek(xFilial("QEL")+cSeek))
		@Li,129 PSAY QEL->QEL_LAUDO
	Endif	
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
aEval(aAreas, {|x| RestArea(x)})
RestArea(aArea)
Return .T.
