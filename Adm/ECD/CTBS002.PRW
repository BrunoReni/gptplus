#INCLUDE "CTBS002.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "ECD.CH"

//Compatibiliza��o de fontes 30/05/2018

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  �WizarValid 	 �Autor  �Elton C. Santana	  � Data �  25/02/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Efetua o controle de pagina ao voltar, apo�s ser efetuado a 	   ���
���          �Pr� Valida��o                                               	   ���
������������������������������������������������������������������������������͹��
���Uso       �  		                                                       ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Function CTBS002(cEmp, cFil)
Local 	cEmpVld		:= cEmp
Local 	aPerg		:= ParamPerguntas()[1]
Local 	aResp		:= ParamPerguntas()[2]

Private oWzrdValid	:= Nil 
Private aHeaderErr	:= {}
Private aErrEcd 	:= {{STR0014}}
Private oErr		:= Nil

Default cEmp		:= ""
Default cFil		:= ""

//������������������������Ŀ
//�Monta o aheader de Erro �
//��������������������������
aHeaderErr 				:= Array(NUM_COL_ERR)
aHeaderErr[ERRO_DESC]	:= STR0014

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

//������������������������������������������������������������������������Ŀ
//� Montagem da Interface                                                  �
//��������������������������������������������������������������������������
// P1
DEFINE WIZARD oWzrdValid;
	TITLE STR0001 + cEmp; //"Assistente de Importa��o de Dados de Escritura��o Cont�bil - Empresa: "
	HEADER STR0002;		 //"Aten��o"
	MESSAGE STR0003 ; //"Pr�-valida��o dos principais cadastros"
	TEXT STR0004 ; //"Essa rotina tem como objetivo efetuar a Pr�-valida��o dos principais cadastros das filiais desta empresa"
	NEXT {|| .T.} ;
	FINISH {||.T.}

// P2       
CREATE PANEL oWzrdValid  ;
	HEADER STR0005+CRLF+STR0006; //"Informe neste passo, a data inicial e final da escritura��o."###"Clique em avan�ar para iniciar a pr�-valida��o"
	MESSAGE ""	;
	BACK {|| .T.} ;
	Next {|| PreValidacao(cEmpVld,aPerg,aResp,cFil)};
	PANEL                                                                                           

	ParamBox(aPerg,"", @aResp,,,,,,oWzrdValid:GetPanel(2)) 

// P3
CREATE PANEL oWzrdValid  ;
	HEADER "";
	MESSAGE STR0007; //"Resultado da pr�-valida��o"
	BACK {|| .T.} ;
	NEXT {|| PreValidNext(,.T.)} ;
	PANEL
	
	@ 030,010 SAY STR0008 SIZE 270,020 PIXEL OF oWzrdValid:GetPanel(3) //"Nenhum erro encontrato..."

// P4
CREATE PANEL oWzrdValid  ;
	HEADER "";
	MESSAGE STR0007; //"Resultado da pr�-valida��o"
	BACK {|| PreValidBack()} ;
	NEXT {|| .T. } ;
	PANEL
	
	oErr := TWBrowse():New( 0.5, 0.5 , 280, 100,Nil,aHeaderErr, Nil, oWzrdValid:GetPanel(4), Nil, Nil, Nil,Nil )      
	oErr:SetArray( aErrEcd ) 
    oErr:bLine := {||{aErrEcd[oErr:nAt,ERRO_DESC]}}
	
	@ 110,005 BUTTON STR0009 SIZE 070,010 ACTION {|| Processa({||ImpErroECD(aErrEcd)})} PIXEL OF oWzrdValid:GetPanel(4) WHEN .T. //"Imprim. Erro"
	
// P5
CREATE PANEL oWzrdValid  ;
	HEADER "";
	MESSAGE STR0010; //"Finaliza��o"
	BACK {|| PreValidBack()} ;
	FINISH {|| .T.} ;
	PANEL
	
	@ 030,010 SAY STR0011 SIZE 270,020 PIXEL OF oWzrdValid:GetPanel(5) //"Processo de pr�-valida��o efetuado com sucesso..."
	
ACTIVATE WIZARD oWzrdValid CENTERED 

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PreValidacao �Autor  �Elton da C. Santana � Data �28/01/10  ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua a pr�valida��o da escritura��o, dos principais campos���
���          �                        									  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PreValidacao(cEmp,aPerg,aResp,cFil)

Local aEmp	:= GetEmpEcd( cEmp )
Local lRet		:= .F.
Local oProcess	:= Nil //indicador de processamento. 

Default aPerg	:= {}
Default aResp	:= {}
Default cFil	:= "" 

//��������������������������������������������������������Ŀ
//�Efetua a valida��o da data inicial e final, .T. OU .F.  �
//����������������������������������������������������������
If ValidaParam(aPerg,aResp)
 
	lRet := .T.

	aErrEcd := RetPreValid(oProcess, aResp[1], aResp[2], aResp[3], aResp[4], aResp[5])
	IF Len( aErrEcd ) <= 0
		aErrEcd:= {{STR0014}}
	Endif

	If oErr <> Nil
		oErr:SetArray( aErrEcd )
		oErr:bLine := {||{aErrEcd[oErr:nAt][ERRO_DESC]}}
	Endif

	//����������������������������������������������������������Ŀ
	//�Fun��o utilizada para apresentar o painel correto,		 �
	//�de acordo com o resultado da valida��o da base de dados 	 �
	//������������������������������������������������������������
	PreValidNext()
EndIf


Return lRet 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetPreValid �Autor  �Elton da C. Santana � Data �10/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Preenche o array com as mensagens de Erro e Advertencia	  ���
���          �                        									  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RetPreValid(oProcess,dDataIni,dDataFim,cCalend,cContaIni,cContaFim)

Local aPreVld := {}
Local aResVld := {}
Local nX	  := 0
Local nY	  := 0

DEFAULT dDataIni 	:= cTod(" / / ")
DEFAULT dDataFim 	:= cTod(" / / ")
DEFAULT cContaIni 	:= Space(20)
DEFAULT cContaFim 	:= Replicate( "Z" , 20 )                       

oProcess:= MsNewProcess():New( {|| aPreVld := PreValdEcd(oProcess,dDataIni,dDataFim,cCalend,cContaIni,cContaFim)} )
oProcess:Activate()

If !Empty(aPreVld)
	For nX := 1 To Len(aPreVld) 
		Aadd(aResVld ,Array(ERRO_DESC) )
		aResVld[Len(aResVld)][ERRO_DESC] := aPreVld[nX]
	Next
EndIf  

Return aResVld  

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  �ImpErroECD     �Autor  �Elton C. Santana	  � Data �  03/02/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Efetua o controle de pagina ao voltar, apo�s ser efetuado a 	   ���
���          �Pr� Valida��o                                               	   ���
������������������������������������������������������������������������������͹��
���Uso       �  		                                                       ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ImpErroECD(aErrEcd)

Local aConoutr	:= {}
Local nX		:= 0
If Len(aErrEcd)>= 1.And. aErrEcd[1][1]!= STR0014
	For nX := 1 To Len(aErrEcd)
	    aAdd(aConoutr,aErrEcd[nX][1])
	Next 
	CtRConOut(aConoutr)
EndIf

Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  �PreValidBack 	 �Autor  �Elton C. Santana	  � Data �  03/02/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Efetua o controle de pagina ao voltar, apo�s ser efetuado a 	   ���
���          �Pr� Valida��o                                               	   ���
������������������������������������������������������������������������������͹��
���Uso       �  		                                                       ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function PreValidBack(nPos)

Local lRet	:= .T.
Default nPos := oWzrdValid:nPanel
//oErr:Refresh()
nPos++

If Len(aErrEcd)>= 1.And. aErrEcd[1][1]!= STR0014
	nPos := 2
Else
	nPos := 3
EndIf

oWzrdValid:nPanel := nPos + 1

Return lRet

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �PreValidNext 	 �Autor  �Elton C. Santana	  � Data �03/02/10   ���
����������������������������������������������������������������������������͹��
���Desc.     �Efetua o controle de pagina ao avan�ar, apo�s ser efetuado a   ���
���          �Pr� Valida��o                                                  ���
����������������������������������������������������������������������������͹��
���Uso       �  		                                                     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function PreValidNext(nPos,lFim)

Local lRet	:= .T.
Default nPos := oWzrdValid:nPanel
Default lFim    := .F.

nPos++

If lFim
	nPos := 5
ElseIf Len(aErrEcd)>= 1 .And. aErrEcd[1][1]!= STR0014
	nPos := 4
Else
	nPos := 3
EndIf

oWzrdValid:nPanel := nPos - 1

Return lRet


Static Function ParamPerguntas()
	
Local aPerguntas := {}
Local aRespostas := {}
Local aRet		 := {}

aAdd(aPerguntas,{1,STR0012		,CTOD(""),"","","",,50,.T.}) //"Periodo Inicial da Escritura��o: "
aAdd(aPerguntas,{1,STR0013		,CTOD(""),"","","",,50,.T.}) //"Periodo Final da Escritura��o: "
aAdd(aPerguntas,{1,"Calendario"	,Space(CTG->(TamSx3("CTG_CALEND")[1])),"@!","CTG->( vazio() .or. ExistCpo('CTG') )","CTG",,03,.F.}) 
aAdd(aPerguntas,{1,"Conta De"	,Space(CT1->(TamSx3("CT1_CONTA")[1])),"@!","","CT1",,60,.F.})
aAdd(aPerguntas,{1,"Conta Ate"  ,Space(CT1->(TamSx3("CT1_CONTA")[1])),"@!","","CT1",,60,.F.})

aRespostas := {CTOD(""),CTOD(""),Space(CTG->(TamSx3("CTG_CALEND")[1])),Space(CT1->(TamSx3("CT1_CONTA")[1])),Space(CT1->(TamSx3("CT1_CONTA")[1]))}

AaDD(aRet,aPerguntas)
AaDD(aRet,aRespostas)
	
Return aRet
