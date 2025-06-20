#Include "Ctbc400.ch"
#Include "PROTHEUS.Ch"
#Include "TcBrowse.Ch"
#INCLUDE "DBINFO.CH"


// 17/08/2009 -- Filial com mais de 2 caracteres

//-------------------------------------------------------------------
/*{Protheus.doc} CTBC480
Consulta de Item Contabil ( raz�o )  

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CTBC480
Local lGetFil := .F.
// ��������������������������������������Ŀ
// � Par�metros para tela de atualiza��es �
// ����������������������������������������
Private cCadastro  	:= STR0001 + " - " + CtbSayAPro("CTD")  //"Consulta � Raz�o Anal�tico"
Private aRotina := MenuDef()
Private aSelFil	 := {} // Sera alimentada pela AdmGetFil

If !Pergunte( "CTC480" , .T.)
	Return
EndIf	

// Seleciona filiais
If mv_par14 == 1
	aSelFil := AdmGetFil()
	If Empty(aSelFil)
		Return
	EndIf
End	

SetKey(VK_F12, { || If(Pergunte( "CTC480" , .T. ), If( mv_par14 == 1, aSelFil := AdmGetFil(),aSelFil := {} ),NIL) })
mBrowse(06, 01, 22, 75, "CTD")

SetKey(VK_F12, Nil)

dbSelectarea("CTD")
dbSetOrder(1)
dbSelectarea("CT1")
dbSetOrder(1)
dbSelectarea("CT2")
dbSetOrder(1)

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} CT480Con
Envia para funcao que monta o arquivo de trabalho com as  movimentacoes e mostra-o na tela 

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CT480Con()

LOCAL nAlias
Local oDlg,oBrw,oCOl,aBrowse:={},ni, aCpos, nCpo
Local nDecimais := CTbMoeda(mv_par03)[5]
Local aSize		:= MsAdvSize(,.F.,430)
Local aSizeAut 	:= MsAdvSize(), cArqTmp
Local aEntCtb	:= {	{ "", "", nil, .T. },;	// Conta	
					 	{ "", "", nil, .T. },;	// Contra Partida
						{ "", "", nil, .T. },;	// Centro de Custo
						{ "", "", nil, .F. },;	// Item Contabil
						{ "", "", nil, .T. } }	// Classe de Valor
Local aObjects	:= {	{ 375,  70, .T., .T. },;
						{ 100, 750, .T., .T., .T. },;
						{ 100, 100, .T., .T. },;
						{ 100, 200, .T., .T. } }
Local aInfo 			:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
Local aPosObj 		:= MsObjSize( aInfo, aObjects, .T. ) , nSaldoAnterior := 0
Local nTotalDebito 	:= nTotalCredito := nTotalSaldo := 0
Local nSALDOSCR  		:= nLANCDEB := nLANCCRD := 0.00
Local aSetOfBook 		:= CTBSetOf(mv_par05)
Local cMascara1
Local cMascara2
Local cMascara3
Local cMascara4
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local lCusto			:= Iif(mv_par08 == 1,.T.,.F.)
Local lCLVL			:= Iif(mv_par11 == 1,.T.,.F.)
Local aArea 			:= GetArea()               
Local cPictVal  		:= PesqPict("CT2","CT2_VALOR")
Local nX
Local cFilOld 		:= cFilAnt
Local cArq

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros ( CTC480 )              �
//� mv_par01            // da data                               �
//� mv_par02            // Ate a data                            �
//� mv_par03            // Moeda			                     �   
//� mv_par04            // Saldos		                         �   
//� mv_par05            // Set Of Books                          �
//� mv_par06            // Do Conta Contabil                     �
//� mv_par07            // At� a Conta Contabil                  �
//� mv_par08            // Imprime C.Custo?                      �
//� mv_par09            // Do Centro de Custo                    �
//� mv_par10            // At� o Centro de Custo                 �
//� mv_par11            // Imprime Classe de Valor?              �	
//� mv_par12            // Da Classe de Valor                    �
//� mv_par13            // Ate a Classe de Valor                 �
//� mv_par14            // Seleciona filiais ?                   �
//����������������������������������������������������������������

If ( CTD->CTD_CLASSE == "1" )
   Help ( " ", 1, "CC010SINTE" )
   Return ( .F. )
End

//Validar se Moeda Existe ou esta em branco
dbSelectArea("CTO")
dbSetOrder(1)
If Empty(mv_par03) .or. !dbSeek(xFilial("CTO")+mv_par03,.F.) 
    Help(" ",1,"NOMOEDA")
	Return(.F.)
EndIf

nSaldoAnterior := SaldTotCT4(CTD->CTD_ITEM,CTD->CTD_ITEM,mv_par09,mv_par10,mv_par06,mv_par07,mv_par01,mv_par03,mv_par04,aSelFil)[6]

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf               

// Mascara do Item Contabil
If Empty(aSetOfBook[7])
	cMascara3 := ""
Else
	cMascara3 := RetMasCtb(aSetOfBook[7],@cSepara3)
EndIf
	
If lCusto .Or. lCLVL
	// Mascara do Centro de Custo
	If Empty(aSetOfBook[6])
		cMascara2 := GetMv("MV_MASCCUS")
	Else
		cMascara2	:= RetMasCtb(aSetOfBook[6],@cSepara2)
	EndIf                                                

	// Mascara da Classe de Valor
	If Empty(aSetOfBook[8])
		cMascara4 := ""
	Else
		cMascara4 := RetMasCtb(aSetOfBook[8],@cSepara4)
	EndIf
EndIf	

// Gera arquivo temporario de trabalho processando os lancamentos de todas as filiais

MsgMeter({|	oMeter, oText, oDlg, lEnd | CTBGerRaz( oMeter,oText,oDlg,lEnd,@cArqTmp,mv_par06,mv_par07,;
												 					 mv_par09,mv_par10,CTD->CTD_ITEM,CTD->CTD_ITEM,;
																	 mv_par12,mv_par13,mv_par03,mv_par01,mv_par02,;
																	 aSetOfBook,.F.,mv_par04,.F.,"3",.T.,,,,,aSelFil) },;
																	 STR0006,;		// "Criando Arquivo Tempor�rio..."
																	 STR0005)		// "Emissao do Razao"


RestArea(aArea)

aCpos := (cArqTmp->(DbStruct()))
If (cArqTmp->(Eof()))
   Help(" ", 1, "CC010SEMMO")
   //Nao colocar return falso pois ap�s esse help inibe a tela mesmo vazia mas exibindo saldo das entidades, deve abrir a tela mesmo 
   //sem movimentos no periodo ou com saldo 0.
End

CTGerCplHis(@nSaldoAnterior, @nTotalSaldo, @nTotalDebito, @nTotalCredito)
nAlias 	:= Select("cArqTmp")
aBrowse := {	{STR0009,"DATAL"},;
				{STR0010,	{ || cArqTmp->LOTE + cArqTmp->SUBLOTE + cArqTmp->DOC +;
							'/' + cArqTmp->LINHA } },;
				{StrTran(STR0021, "-", ""),{ || MascaraCTB(cArqTmp->CONTA,cMascara1,,cSepara1) } },;
				{STR0012,{ || MascaraCTB(cArqTmp->XPARTIDA,cMascara1,,cSepara1) } },;
				{STR0011,"HISTORICO"},;
				{STR0013,"LANCDEB"},;
				{STR0014,"LANCCRD"},;
    			{STR0015,"SALDOSCR"},;
   				{STR0029,"TPSLDATU"},;
   				{"Filial","FILORI"}}

If lCusto
	Aadd(aBrowse, {CtbSayAPro("CTT"),{ || MascaraCTB(cArqTmp->CCUSTO,cMascara2,,cSepara2) } })
Endif
If lCLVL
	Aadd(aBrowse, {CtbSayAPro("CTH"),{ || MascaraCTB(cArqTmp->CLVL,cMascara4,,cSepara4) } })
Endif

DEFINE 	MSDIALOG oDlg TITLE cCadastro;
		From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
cCondA := Iif(nSaldoAnterior<0,"D","C")
@ 18, 04  SAY CtbSayApro("CTD") + " " + MascaraCTB(CTD->CTD_ITEM,cMascara3,,cSepara3) + " - " +;
AllTrim(Substr(&("CTD->CTD_DESC" + mv_par03),1,45)) PIXEL
@ 18,aPosObj[1][4] - 80 Say STR0026 +;
Transform(Abs(nSaldoAnterior),cPictVal) + " " + cCondA PIXEL //"Saldo Anterior "
@ 30,4 COLUMN BROWSE oBrw SIZE 	aPosObj[2][3],aPosObj[2][4] PIXEL OF oDlg
oBrw:lColDrag := .T.  // Permite a mudanca das ordens das colunas
oBrw:lMChange := .T.  // Permitir o ajuste do tamanho dos campos
oBrw:bChange := { || C400ChgBrw( mv_par03, @aEntCtb ) }

For ni := 1 to Len(aBrowse)
	uCpo := aBrowse[ni][2]
	If ValType(uCpo) <> "B"
		nCpo := Ascan(aCpos, { |x| x[1] = aBrowse[ni][2]})
	Else
		nCpo := 0
	Endif
	If nCpo = 0
		DEFINE COLUMN oCol DATA { || "" };
		HEADER aBrowse[ni][1];
		SIZE CalcFieldSize("C",	Len(Eval(uCpo)), 0,"",aBrowse[ni][1])
		oCol:bData := uCpo
	ElseIf ValType(&(aBrowse[ni][2])) != "N"
		If aBrowse[ni][2] == "HISTORICO"
			aCpos[nCpo][3] := TamSX3("CT2_HIST")[1]
		EndIf
		DEFINE COLUMN oCol DATA FieldWBlock(aBrowse[ni][2], nAlias);
		HEADER aBrowse[ni][1];
		SIZE CalcFieldSize(aCpos[nCpo][2],aCpos[nCpo][3],aCpos[nCpo][4],"",aBrowse[ni][1]) -; 
		If(ValType(&(aBrowse[ni][2])) = "D", 7, 0)
	Else
		uCpo := aBrowse[ni][2]
		DEFINE COLUMN oCol DATA FieldWBlock(aBrowse[ni][2], nAlias);
		PICTURE cPictVal;
		HEADER aBrowse[ni][1] SIZE CalcFieldSize(aCpos[nCpo][2],aCpos[nCpo][3],aCpos[nCpo][4],cPictVal,aBrowse[ni][1]) RIGHT
	Endif
	oBrw:ADDCOLUMN(oCol)
Next ni
DEFINE COLUMN oCol DATA { || Space(10) } HEADER " " SIZE 10 RIGHT
oBrw:ADDCOLUMN(oCol)

@aPosObj[3][1],002 TO aPosObj[3][3], aPosObj[3][4] LABEL STR0027 + CtbSayAPro("CTD") PIXEL
@aPosObj[3][1] + 8,005  Say STR0013 + Trans(nTotalDebito,tm(nTotalDebito,17,nDecimais)) PIXEL		//"D�bito "
@aPosObj[3][1] + 8,170  Say STR0014 + Trans(nTotalCredito,tm(nTotalCredito,17,nDecimais)) PIXEL  	//"Cr�dito "
cCondF := Iif(nTotalSaldo<0,"D","C")			
@ aPosObj[3][1] + 8,aPosObj[1][4] - 60 Say STR0020+ Transform(ABS(nTotalSaldo),cPictVal) + " " + cCondF Pixel //"Saldo "

@ aPosObj[4][1], 002 TO aPosObj[4][3], aPosObj[4][4] LABEL STR0030 PIXEL	// "Descri��es"

@ aPosObj[4][1]+8,005 SAY StrTran(STR0021, "-", "") PIXEL	// Conta
@ aPosObj[4][1]+8,040 MSGET aEntCtb[1,3] VAR aEntCtb[1,2] WHEN .F. SIZE 150,08 PIXEL

@ aPosObj[4][1]+8,aPosObj[4][4] -190 SAY STR0012 PIXEL	// "Contra Partida"
@ aPosObj[4][1]+8,aPosObj[4][4] -152 MSGET aEntCtb[2,3] VAR aEntCtb[2,2] WHEN .F. SIZE 150,08 PIXEL

@ aPosObj[4][1]+19,005 SAY CtbSayAPro("CTT") PIXEL	// Centro de Custo
@ aPosObj[4][1]+19,040 MSGET aEntCtb[3,3] VAR aEntCtb[3,2] WHEN .F. SIZE 150,08 PIXEL
                     
@ aPosObj[4][1]+19,aPosObj[4][4] -190 SAY CtbSayAPro("CTH") PIXEL	// Classe de Valor
@ aPosObj[4][1]+19,aPosObj[4][4] -152 MSGET aEntCtb[5,3] VAR aEntCtb[5,2] WHEN .F. SIZE 150,08 PIXEL

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

cFilAnt := cFilOld
// Elimina arquivo de Trabalho
dbSelectArea("cArqTmp")
cArq := DbInfo(DBI_FULLPATH)
cArq := AllTrim(SubStr(cArq,Rat("\",cArq)+1))
DbCloseArea()
FErase(cArq)

//Limpa os arquivos tempor�rios 
CtbRazClean()

dbSelectArea("CTD")

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CT480Imp � Autor � Wagner Mobile Costa   � Data � 28/01/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prepara a chamada para o relatorio CTBR480                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBC480                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CT480Imp()

Local aAreaCtd := CTD->(GetArea())
Local aSelImp	:= {}

If ! Pergunte("CTC480", .T.)
	Return .F.
Endif

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros ( CTC480 )              �
//� mv_par01            // da data                               �
//� mv_par02            // Ate a data                            �
//� mv_par03            // Moeda			                     �   
//� mv_par04            // Saldos		                         �   
//� mv_par05            // Set Of Books                          �
//� mv_par06            // Do Conta Contabil                     �
//� mv_par07            // At� a Conta Contabil                  �
//� mv_par08            // Imprime C.Custo?                      �
//� mv_par09            // Do Centro de Custo                    �
//� mv_par10            // At� o Centro de Custo                 �
//� mv_par11            // Imprime Classe de Valor?              �	
//� mv_par12            // Da Classe de Valor                    �
//� mv_par13            // Ate a Classe de Valor                 �
//� mv_par14            // Seleciona filiais ?                   �
//����������������������������������������������������������������
If mv_par14 == 1
	aSelImp := aClone(aSelFil)
EndIf  

CTBR480(CTD->CTD_ITEM, CTD->CTD_ITEM, mv_par01, mv_par02, mv_par03, mv_par04,;
			mv_par05, mv_par06, mv_par07, mv_par08=1, mv_par09, mv_par10, mv_par11=1,;
			mv_par12, mv_par13,,aSelImp) 
	
If ! Pergunte("CTC480", .F.)
	Return .F.
Endif


CTD->(RestArea(aAreaCtd))
Return .T.

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �06/12/06 ���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
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
Local aRotina   	:= {	{STR0002,"AxPesqui",0,1},;  	//"Pesquisar"
                           	{STR0003,"CT480Con",0,2},;   	//"Visualizar"
                           	{STR0004,"CT480Imp",0,3}}    	//"Impressao"
Return(aRotina)
