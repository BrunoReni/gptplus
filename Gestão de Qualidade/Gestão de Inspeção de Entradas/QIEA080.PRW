#include "PROTHEUS.CH" 
#include "QIEA080.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA080  � Autor � Cleber Souza          � Data � 03/06/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao de Informativo sobre Produtos         ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),   "AxPesqui",0,1,,.F.},;  //"Pesquisar"   
	  			 {OemToAnsi(STR0002),   "A080INFO",0,2},;  //"Visualizar"	  
				 {OemToAnsi(STR0003),   "A080INFO",0,3},;  //"Incluir"	  
				 {OemToAnsi(STR0004),   "A080INFO",0,4},;  //"Alterar"  
				 {OemToAnsi(STR0005),   "A080INFO",0,5,3}} //"Excluir"  

Return aRotina

Function QIEA080()                                         
Private cEspecie := 'QIEA080 '	// Deve ter tamanho 8
Private lEdita	 := .T.       
Private aTexto   := {} 

PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Informativo s/ Produtos"  

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
//�    6 - Altera determinados campos sem incluir novos Regs     �
//����������������������������������������������������������������
PRIVATE aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QEB")

Return(NIL)   
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A080Visual� Autor � Vera Lucia S. Simoes  � Data � 21/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa atualizacao Informativo sobre Itens - Visualizacao���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A080Visual(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A080INFO(cAlias,nReg,nOpc)

Local oDlg  
Local oGet
Local nOpcA      := 0
Local lWhn       := IIF(nOpc==2 .or. nOpc==5 ,.F.,.T.) 
Local cVarPrd    := CriaVar("QE6_DESCPO",.F.)
Local cPictPro   := '@!'  
Local nX         := 0 
Local cWhile     := ""
Local cSeek      := ""
Local aNoFields  := {} 
Local aHeaderAux := {}
Local oSize 
Local oSize2
Local oSize3
Local cAcao		:= IIF(nOpc==3, 'INCLUIR',IIF(nOpc==4, 'ALTERAR',IIF(nOpc==2, 'VISUALIZAR',IIF(nOpc==5, 'EXCLUIR',''))))

Private cIE080Prod := CriaVar("QEB_PRODUT")
Private cIE080Desc := CriaVar("QEB_DESCRI")
Private cIE080Data := CriaVar("QEB_DTATU")  
Private nPosTop
Private nPosDTo  
Private aHeader    := {}
Private aCols      := {}
Private nPostxt

          
//����������������������������������������������������������������������Ŀ
//�Monta aHeader da tabela QEC  										 �
//������������������������������������������������������������������������
//QE080Head() 

/* Documenta��o dos parametros do Metodo FillGetDados
FillGetDados  (nOpc,; 			// numero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
               Alias,       	// area a ser utilizada;
               nOrdem,      	// ordem correspondente a chave de �ndice para preencher o  acols;
               cSeek,       	// chave utilizada no posicionamento da �rea para preencher o acols; 
               bSeekWhile,  	// bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While. 
               uSeekFor,    	// pode ser utilizados de duas maneiras:
							 	   1 - bloco-de-codigo, condicao a ser utilizado para executar o Loop no While;
							 	   2 - array bi-dimensional contendo N condicoes, em que o 1 elemento o bloco condicional, o 2 bloco a ser executado se verdadeiro e o 3 e bloco a ser executado se falso:
							 	   Exemplo:
							 	   {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
               aNoFields,   	// array contendo os campos que n�o estar�o no aHeader;
               aYesFields,  	// array contendo somente os campos que estar�o no aHeader;
               lOnlyYes,    	// se verdadeiro, exibe apenas os campos de usu�rio;
               cQuery,      	// query a ser executada para preencher o acols;
               bMontCols,    	// bloco contendo funcao especifica para preencher o aCols; 
               lEmpty,       	// 
               aHeaderAux,   	// 
               aColsAux,     	// 
               bAfterCols,   	// 
               bBeforeCols,  	// 
               bAfterHeader,    // 
               cAliasQry)       // 
*/

cWhile    := Alltrim(RetSIX("QEC","1",.T.,{"QEC_TOPICO"}))
cSeek 	  := RetSIX("QEB","1",.T.)
aNoFields := {"QEC_FILIAL", "QEC_PRODUT","QEC_TXTTOP","QEC_CHAVE" }
bheader:= {|| Aadd(aHeader,{STR0009,"QEC_TXTTOP","@!",50,,,,"M",,,,,,,,,,,,,,,,,,,,,,,,""}) } //"Texto do T�pico"
 
FillGetDados(	nOpc,; 							// numero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
               	"QEC",;       					// area a ser utilizada;
               	1,;      						// nOrdem - ordem correspondente a chave de �ndice para preencher o  acols;
               	Iif((nOpc == 3),"",&cSeek),;  	// chave utilizada no posicionamento da �rea para preencher o acols; 
               	{|| &cWhile},; 					// bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While. 
               	{|| .T.},;  					// uSeekFor
               	aNoFields,;  					// array contendo os campos que n�o estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usu�rio;
                '',;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpc == 3),.T.,.F.),;  	// lEmpty 
               	,; 					// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	bheader,; 								// bAfterHeader
               	'') 							// cAliasQry
               	
//����������������������������������������������������������������������Ŀ
//� Verifica a posicao dos campos no aHeader p/ posterior consistencia   �
//������������������������������������������������������������������������
nPosTop := Ascan(aHeader,{|x| x[2] = "QEC_TOPICO"})
nPosDTo := Ascan(aHeader,{|x| x[2] = "QEC_DESTOP"})

QE080AfCols( aHeader, @aCols )

If nOpc<> 3 
	cIE080Prod := QEB->QEB_PRODUT 
	cIE080Desc := QEB->QEB_DESCRI
	cIE080Data := QEB->QEB_DTATU
	ShowPrd  (cIE080Prod,@cVarPrd)
Else
	cIE080Data := dDataBase
EndIf

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New()

oSize:AddObject( "LINHA1"    ,  100, 10, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "LINHA2"    ,  100, 10, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 80, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 0, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize2 := FwDefSize():New()

oSize2:aWorkArea := oSize:GetNextCallArea( "LINHA1" ) 

oSize2:AddObject( "LABEL"     ,  5, 100	, .T., .T.) // N�o dimensionavel
oSize2:AddObject( "PRODUTO"   ,  10, 100	, .T., .T.) // N�o dimensionavel
oSize2:AddObject( "DESCRICAO" ,  10, 100	, .T., .T.) // N�o dimensionavel
oSize2:AddObject( "VAZIO" 	  ,  75, 100	, .T., .T.) // N�o dimensionavel
  
oSize2:lLateral	:= .T.            //Calculo em Lateral
oSize2:lProp		:= .T.          
oSize2:aMargins	:= { 3, 3, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize2:Process() // Dispara os calculos  

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize3 := FwDefSize():New()

oSize3:aWorkArea := oSize:GetNextCallArea( "LINHA2" ) 

oSize3:AddObject( "LABEL"     		,  5	, 100, .T., .T.) // N�o dimensionavel
oSize3:AddObject( "DESCRITIVO"     ,  25	, 100, .T., .T.) // N�o dimensionavel
oSize3:AddObject( "LABELDATA"		,  4	, 100, .T., .T.) // N�o dimensionavel
oSize3:AddObject( "DATA"				,  6	, 100, .T., .T.) // N�o dimensionavel
oSize3:AddObject( "VAZIO" 	  		,  55	, 100, .T., .T.) // N�o dimensionavel
 
oSize3:lLateral := .T.            //Calculo em Lateral
oSize3:lProp := .T.               // Proporcional             
oSize3:aMargins := { 3, 3, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize3:Process() // Dispara os calculos 

//��������������������������������������������������������������Ŀ
//� Monta Dialog                                                 �
//���������������������������������������������������������������� 

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0006) + ' - '+cAcao  FROM ;
								oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL  //"Informativos/ Produtos" 

@ oSize2:GetDimension("LABEL","LININI")  ,oSize2:GetDimension("LABEL","COLINI")+3  SAY OemToAnsi(STR0007) SIZE 29,7 OF oDlg PIXEL  //"Produto"	 

@ oSize2:GetDimension("PRODUTO","LININI"),oSize2:GetDimension("PRODUTO","COLINI") MSGET cIE080Prod 		  ;
			  PICTURE cPictPro					  ;
			  VALID ExistCpo ("QE6",cIE080Prod)	  ;
			  .AND. ExistChav("QEB",cIE080Prod)   ;
			  .AND. ShowPrd  (cIE080Prod,@cVarPrd);
			  WHEN  lWhn                	  	  ;
			  F3 "QE6" SIZE  61,10 OF oDlg PIXEL 
			  
@ oSize2:GetDimension("DESCRICAO","LININI"),oSize2:GetDimension("DESCRICAO","COLINI") SAY cVarPrd SIZE 200,7 OF oDlg PIXEL     

@ oSize3:GetDimension("LABEL","LININI"),oSize3:GetDimension("LABEL","COLINI")+3 SAY OemToAnsi(STR0010) SIZE 35,7 OF oDlg PIXEL //"Descritivo"	 
@ oSize3:GetDimension("DESCRITIVO","LININI"),oSize3:GetDimension("DESCRITIVO","COLINI") MSGET cIE080Desc ;
			  VALID CheckSX3("QEB_DESCRI") ;
			  WHEN lWhn SIZE 162,10 OF oDlg PIXEL

@ oSize3:GetDimension("LABELDATA","LININI"),oSize3:GetDimension("LABELDATA","COLINI") SAY OemToAnsi(STR0008) SIZE 18,7 OF oDlg PIXEL  //"Data"	 
@ oSize3:GetDimension("DATA","LININI"),oSize3:GetDimension("DATA","COLINI") MSGET cIE080Data					;
			  VALID CheckSX3("C7_CONTATO")	;
			  SIZE  42,10					; 
			  WHEN  lWhn           	  	    ;
			  OF    oDlg PIXEL

dbSelectArea("QEC")
dbSetOrder(1)
dbseek(xFilial("QEC") + cIE080Prod)

oGet := MSGetDados():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
						 oSize:GetDimension("GETDADOS","LINEND")+3,oSize:GetDimension("GETDADOS","COLEND"),;
						 nOpc,"A080LinOk","A080TudoOk",,.T.,,,,,,,,,,,,,oDlg)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,oDlg:End()},{||oDlg:End()}) CENTERED

If nOpcA == 1 .and. nOpc#2
	QIE080Grav(nOpc)
EndIF	

Return(NIL)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �QE080AfCols �Autor  �Cicero Cruz         � Data �  18/01/04   ���
���������������������������������������������������������������������������͹��
���Desc.     � Rotina que carrega os campos Virtuais                        ���
���������������������������������������������������������������������������Ĵ��
���Uso       � QIEA080                                                    ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function QE080AfCols( aHeader, aCols )
Local nLinha := 0
Local nTamLin    := TamSX3("QA2_TEXTO")[1]  
Local aTextos    := {}     

nPosTxt := ASCAN(aHeader,{|x|x[2] = "QEC_TXTTOP"})

For nLinha := 1 to Len(aCols)
	aCols[nLinha,nPosDTo] := Iif(!Empty(aCols[nLinha,nPosTop]),A080DTOP(aCols[nLinha,nPosTop]),"")
	DBSELECTAREA("QEC")
	DBSETORDER(1)
	DBSEEK(XFILIAL("QEC")+ QEB->QEB_PRODUT + aCols[nLinha,nPosTop])
	aCols[nLinha,nPosTxt] := QA_RecTxt(QEC->QEC_CHAVE,cEspecie,00,nTamLin,"QA2",aTextos)
Next

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A080VlTo � Autor � Vera Lucia S. Simoes  � Data � 28/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Topico                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QieA080 - E' chamada no X3_VALID do cpo. QEC_TOPICO - SX3  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A080VlTo()
Local lRetu  := .t.
Local nI
Local cVar   := &(readvar()) 

//����������������������������������������������������������������Ŀ
//� Verifica se mudou o Topico (Alterou o campo ja' digitado)      �
//������������������������������������������������������������������
If !Empty(aCols[n][nPosTop]) .and. !Empty(cVar) .and. aCols[n][nPosTop] <> cVar
	Help(" ",1,"A010ALTCHA")	// Campo nao pode ser alterado
	lRetu := .f.
EndIf

//�������������������������������������������������Ŀ
//� Verifica se o Topico esta' cadastrado           �
//���������������������������������������������������
If lRetu
	aCols[n][nPosTop] := M->QEC_TOPICO
	If ! ExistCpo("SX5",'Q3'+aCols[n][nPosTop])
		lRetu := .f.
	EndIf
EndIf

//�������������������������������������������������Ŀ
//� Verifica se o Topico ja' existe                 �
//���������������������������������������������������
If lRetu
	For nI := 1 to len(aCols)
		If cVar == acols[nI][nPosTop] .and. nI <> n // Se ja' existir este cod. topico
			Help(" ",1,"A080EXITOP")
			lRetu := .f.
		EndIf
	Next nI
EndIf

//�������������������������������������������������Ŀ
//� Preenche a Descricao do Topico                  �
//���������������������������������������������������
If lRetu
	aCols[n][nPosDTo] := A080DTOP(aCols[n][nPosTop])
EndIf

Return(lRetu)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SHOWPRD  � Autor � Alessandro B. Freire  � Data � 16.01.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a descricao do Produto                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function ShowPrd( cIE080Prod, cVarPrd )
Local nB1OldOrd := QE6->(IndexOrd())

QE6->(dbSetOrder(1))
QE6->(dbSeek(xFilial("QE6")+cIE080Prod))
If cVarPrd != NIL
	cVarPrd := QE6->QE6_DESCPO
EndIf
QE6->(dbSetOrder(nB1OldOrd))
Return(.T.)  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A080DTOP � Autor � Vera Lucia S. Simoes  � Data � 05.12.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a descricao do Topico                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A080DTOP(cCodTop)
SX5->(dbSetOrder(1))
SX5->(dbSeek(xFilial("SX5") + 'Q3' + cCodTop))	// Topico posicionado na getdados
Return(X5Descri())

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A080LinOk � Autor � Vera Lucia S. Simoes  � Data � 21/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QieA080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A080LinOk(o)
Local lRet     := .T.
Local nAchou   := 0
Local cProcura := aCols[n][nPosTop]
Local nUsado   := Len(aHeader)

If !(aCols[n,Len(aCols[n])])
	//�������������������������������������������������������������Ŀ
	//� Verifica se campo Topico esta' preenchido                   �
	//���������������������������������������������������������������
	If !aCols[n][nUsado+1] .And. LastKey() != 5 .And. LastKey() != 27 .And. lRet
		If Empty(aCols[n][nPosTop])
			Help(" ",1,"QA_CPOOBR")
			lRet:=.F.
		EndIf
	EndIf
	If lRet
		//�������������������������������������������������Ŀ
		//� Verifica se o Topico ja' existe                 �
		//���������������������������������������������������
		nAchou := Ascan(aCols,{|x| x[nPosTop] == cProcura .And. !(x[Len(aCols[n])])})
		If nAchou > 0 .And. nAchou # n
			Help(" ",1,"A080EXITOI")
			lRet:=.F.
		EndIf
	EndIf

	//�������������������������������������������������Ŀ
	//� Verifica se o Topico esta' cadastrado           �
	//���������������������������������������������������
	If lRet
		If ! Empty(aCols[n][nPosTop])
			If ! ExistCpo("SX5",'Q3'+aCols[n][nPosTop])
				lRet := .f.
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A080TudoOk� Autor � Vera Lucia S. Simoes  � Data � 20/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se toda a getdados esta' Ok                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QieA080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A080TudoOk(o)
Local nI
Local lRet := .t.

For nI := 1 to Len(aCols)
	If ! A080LinOk(o)
		lRet := .f.
		Exit
	EndIf
Next

Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIE080Grav� Autor � Cleber Souza          � Data � 04/06/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava as informacoes dos Informativos                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QieA080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIE080Grav(nOpc)

Local nx        := 0 
Local ny        := 0 
Local nMaxArray := Len(aCols)
Local n080Del   := 0
Local nPosTop   := 0 
Local lOk       := .t.
Local cChave    := ""
Local nUsado    := Len(aHeader) 
Local aTexto    := {}
Local aAreaQEC 

dbSelectArea("QEC")
dbSetOrder(1)

//������������������������������������������������������������Ŀ
//� Verifica qual a posicao do campo Topico no aHeader         �
//��������������������������������������������������������������
nPosTop := ASCAN(aHeader,{|x|x[2] = "QEC_TOPICO"})
nPosTxt := ASCAN(aHeader,{|x|x[2] = "QEC_TXTTOP"})

//����������������������������������������Ŀ
//� Conta no. de Topicos deletados         �
//������������������������������������������
For nx := 1 to nMaxArray
	If aCols[nx][Len(aCols[nx])]	// Deletou
		n080Del++
	EndIf
Next nx

If n080Del >= nMaxArray
	If Inclui
		Help(" ",1,"A080DTOPIN")
	Else
		Help(" ",1,"A080DTOPAL")
	EndIf
	lOk := .f.
Endif

If lOk
	If nOpc # 5
	
		//����������������������������Ŀ
		//� Grava o arquivo QEC        �
		//������������������������������
		For nX := 1 to nMaxArray
			If ! Empty(aCols[nX][nPosTop]) // Cod. Topico nao vazio
				If !Acols[nX][nUsado+1]	// Nao esta deletado
					If dbSeek(xFilial("QEC") + cIE080Prod + aCols[nX][nPosTop])
						RecLock("QEC",.F.)	// Lock
					Else
						dbSelectArea("QEC")
						RecLock("QEC",.T.)	// Append
						QEC->QEC_PRODUT := cIE080Prod
						QEC->QEC_FILIAL := xFilial("QEC")
					Endif
			
					For ny := 1 to Len(aHeader)
						If aHeader[ny][10] # "V" .and. aHeader[ny][2] # "TXTTOP"
							cVar := Trim(aHeader[ny][2])
							Replace &cVar. With aCols[nx][ny]
						Endif
					Next ny

		 			//����������������������������������������������������������Ŀ
		  			//� Grava o codigo do texto do topico                        �
		  			//������������������������������������������������������������
		 			If Empty(QEC->QEC_CHAVE) 
	   					QEC->QEC_CHAVE := QA_NewChave()
	   		        EndIf                    
	   		        MsUnLock()
                    
					//����������������������������������������������������������Ŀ
		  			//� Grava Texto do Topico na tabela QA2                      �
		  			//������������������������������������������������������������
		 		
		 			If !Empty(aCols[nX][nPosTxt]) 
		 		 		aTexto := {}
	  					Aadd(aTexto,{1,aCols[nX][nPosTxt]}) 
			 			QA_GrvTxt(QEC->QEC_CHAVE,cEspecie,1,@aTexto)    			                      	
                    EndIF
                    
       			Else
				 	//���������������������������������������Ŀ
					//� Cancela o Topico no QEC               �
					//�����������������������������������������
					If dbSeek(xFilial("QEC") + cIE080Prod + aCols[nX][nPosTop])
						RecLock("QEC",.F.)
						cChave := QEC->QEC_CHAVE
						dbDelete()
						MsUnLock()
			
					 	//���������������������������������������Ŀ
						//� Cancela o Texto do Topico no QA2      �
						//�����������������������������������������
						IF !Empty(cChave)
							QA_DelTxt(cChave,cEspecie)	// QAXFUN
						EndIF	
					EndIf
				EndIf
			EndIf
		Next nx

		//  Se cancelou todos os Topicos, cancela o Informativo
		If ! QEC->(dbSeek(xFilial("QEC") + cIE080Prod))
			//�������������������������������������Ŀ
			//� Cancela o Informativo no QEB        �
			//���������������������������������������
			dbSelectArea("QEB")
			If dbseek(xFilial("QEB") + cIE080Prod)
				RecLock("QEB",.F.)
				dbDelete()
				MsUnLock()
			EndIf
		Else
			//����������������������������Ŀ
			//� Grava o arquivo QEB        �
			//������������������������������
			dbSelectArea("QEB")
			If dbseek(xFilial("QEB") + cIE080Prod)
				RecLock("QEB",.F.)
			Else
				RecLock("QEB",.t.)
				QEB->QEB_FILIAL := xFilial("QEB")
				QEB->QEB_PRODUT := cIE080Prod
			EndIf
			QEB->QEB_DESCRI := cIE080Desc
			QEB->QEB_DTATU  := cIE080Data	
			MsUnLock()
		EndIf
    Else 
    	For nX := 1 to nMaxArray
   			//���������������������������������������Ŀ
			//� Cancela o Topico no QEC               �
			//�����������������������������������������
			If dbSeek(xFilial("QEC") + cIE080Prod + aCols[nX][nPosTop])
				RecLock("QEC",.F.)
				cChave := QEC->QEC_CHAVE
				dbDelete()
				MsUnLock()
		
			 	//���������������������������������������Ŀ
				//� Cancela o Texto do Topico no QA2      �
				//�����������������������������������������
				IF !Empty(cChave)
					QA_DelTxt(cChave,cEspecie)	
				EndIF	
			EndIf
    	
    	Next nX 
    	
   		//�������������������������������������Ŀ
		//� Cancela o Informativo no QEB        �
		//���������������������������������������
		dbSelectArea("QEB")
		If dbseek(xFilial("QEB") + cIE080Prod)
			RecLock("QEB",.F.)
			dbDelete()
			MsUnLock()
		EndIf

    EndIF

EndIf

Return