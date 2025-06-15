#include "protheus.ch"
#include "ctba910.ch"
#include "apwizard.ch"
#INCLUDE 'FWBROWSE.CH'
#Include "FWLIBVERSION.CH"

/*/
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Funcao    � CTBWIZENT  � Autor � Microsiga                  � Data � 23/02/10 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � User Function de mesmo nome criada com  fins de compatibilidade   ���
���          � entre os bin�rios                                                 ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe   � ENTWIZUPD  - Executada a partir da Main Fuction                   ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � ATUALIZACAO SIGACTB                                               ���
��������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                            ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
/*/

User Function CTBWIZENT()
	CtbA910()
Return

/*/
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Funcao    � CTBWIZENT  � Autor � Microsiga                  � Data � 23/02/10 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � User Function de mesmo nome criada com  fins de compatibilidade   ���
���          � entre os bin�rios                                                 ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe   � ENTWIZUPD  - Executada a partir da Main Fuction                   ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � ATUALIZACAO SIGACTB                                               ���
��������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                            ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
/*/

Main Function CTBWIZENT()
	CtbA910()
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENTWIZUPD �Autor  �Microsiga           � Data �  02/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � ENTWIZUPD  - Prepara��o para execu��o do Wizard.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CtbA910() // ENTWIZUPD()

Local nInc      := 0
Local axFil_CT0 := {}
Local cxFilCT0 := Space(12)
Local oProcessCT0
Local oDlg
Local nMiliSegs := 0
Local nCtdTimer := 0
Local oTFont
Local oSay1
Local nPosEmpFil    := 0
Private aSM0		:= {}

Private	cFirstEmp	:= ""
Private	cArqEmp		:= "SigaMat.Emp"
Private	nModulo		:= 34
Private	__cInterNet	:= Nil
Private nQtdEntid 	:= 1
Private nEntidIni 	:= 0
Private oMainWnd
Private cUserName 	:= ""
Private oGetDados

Private lChkRefaz	:= .F.
Private lChkATF		:= .T.
Private lChkCOM		:= .T.
Private lChkCTB		:= .T.
Private lChkEST		:= .T.
Private lChkFAT		:= .T.
Private lChkFIN		:= .T.
Private lChkGCT		:= .T.
Private lChkPCO		:= .T.
Private lChkVGE  	:= .T.
Private lMaxEnt		:= .F.

Private cMens		:=	STR0002 + CRLF +;	// "Esta rotina ira atualizar os dicionarios de dados"
						STR0003 + CRLF +;	// "para a utilizacao de novas entidades."
						STR0004 + CRLF +;	// "E importante realizar um backup completo dos dicionarios e base de dados, "
						STR0005 + CRLF +;	// "antes da execu��o desta rotina."
						STR0006				// "Nao deve existir usuarios utilizando o sistema durante a atualizacao!"

Private cMessage
Private aArqUpd		:= {}
Private aREOPEN		:= {}
Private __lPyme		:= .F.
Private oWizard
Static lEntidad05   := .F. // Manejo de entidad 05
Private lCriouSDF   := .F.
Private cTxtAux     := ""

TCInternal(5,'*OFF') //-- Desliga Refresh no Lock do Top

Set Dele On
//Realiza a abertura do dicionario Exclusivo
OpenSM0Excl()
aSM0 := AdmAbreSM0()

RpcSetType(3)
RpcSetEnv( aSM0[1][1], aSM0[1][2] )

__cUserID := "000000"

lEntidad05	:= (cPaisLoc $ "COL|PER" .And. FWAliasInDic("QL6") .And. FWAliasInDic("QL7"))
//Habilita mensagem
__cInterNet := ""

//���������������������������������������������������Ŀ
//� Verifica quantas entidades j� existem no ambiente �
//�����������������������������������������������������
IF (nEntidIni := GETMAXENT()) == 0 //Valida��o para caso n�o consiga obter acesso a tabela
	Return .F.
ElseIf nEntidIni > 9
	lMaxEnt := .T.
EndIf
//Valida��o da Lib para gerar SDF --> CRIA INDICE - 20230220 - Michel Framework
If __FWLibVersion() < "20230220"
	MsgInfo(STR0087, STR0001)  // "Lib necess�ria para gera��o correta do SDF referente entidades desatualizada. Favor atualizar!" ###, "Atencao !"
	Return .F.
EndIf

dbSelectArea("SXB")
dbSetOrder(1)
If !MsSeek(Padr('CT0SX3', Len(SXB->XB_ALIAS)))
	MsgInfo(STR0065, STR0001)  // "Ambiente do Ativo Fixo desatualizado, executar o U_UPDCTB" ###, "Atencao !"
	Return .F.
EndIf

dbSelectArea("SX3")
dbSetOrder(2)
If !MsSeek("CT0_ENTIDA") .Or. Alltrim(SX3->X3_WHEN)=="!(M->CT0_ID $ '01|02|03|04')"
	MsgInfo(STR0065, STR0001)  // "Ambiente do CTB desatualizado, executar o U_UPDCTB" ###, "Atencao !"
	Return .F.
EndIf

//�����������������������������������������������������Ŀ
//� Painel 1 - Tela inicial do Wizard 		            �
//�������������������������������������������������������
oWizard := APWizard():New(STR0008/*<chTitle>*/,; // "Configura��o de Entidades"
STR0010/*<chMsg>*/, ""/*<cTitle>*/, ; // "Essa ferramenta ir� efetuar a manuten��o nos campos e par�metros para as novas configura��es"
cMens + CRLF + STR0013, ; // "Voc� dever� escolher o n�mero de entidades que ser�o inclu�das e a partir de qual ser� efetuada a inclus�o"
{||.T.} /*<bNext>*/ ,;
{||.T.}/*<bFinish>*/,;
.F./*<.lPanel.>*/, , , /*<.lNoFirst.>*/)
//{||.T.}/*<bNext>*/ ,;

//�����������������������������������������������������Ŀ
//� Painel 2 - Defini��o das Novas Entidades            �
//�������������������������������������������������������
oWizard:NewPanel(STR0008/*<chTitle>*/,; //"Configura��o de Entidades"
STR0014/*<chMsg>*/,; // "Assistente para configura��o de novas entidades no sistema"
{||.T.}/*<bBack>*/,;
{||ENTWZVLP2()} /*<bNext>*/ ,;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/ ,;
{|| EntGetNum()}/*<bExecute>*/) //Montagem da tela

//�����������������������������������������������������Ŀ
//� Painel 3 - Descri��o das Novas Entidades            �
//�������������������������������������������������������
oWizard:NewPanel(STR0008/*<chTitle>*/,; //"Configura��o de Entidades"
STR0014/*<chMsg>*/,; // "Assistente para configura��o de novas entidades no sistema"
{||.T.}/*<bBack>*/,;
{||ENTWZVLP3()} /*<bNext>*/ ,;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/ ,;
{|| EntGetDesc() }/*<bExecute>*/)

//�����������������������������������������������������Ŀ
//� Painel 4 - Acompanhamento do Processo               �
//�������������������������������������������������������
oWizard:NewPanel(STR0015/*<chTitle>*/,;  //"Processamento..."
""/*<chMsg>*/,;
{||.F.} /*<bBack>*/,;
{||.F.}/*<bNext>*/ ,;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/ ,;
{| lEnd| ENTWIZREGU(@lEnd)}/*<bExecute>*/)

oWizard:Activate( .T./*<.lCenter.>*/,;
{||.T.}/*<bValid>*/,;
{||.T.}/*<bInit>*/,;
{||.T.}/*<bWhen>*/)

 //rodar upddistr e criar as entidades na CT0


If lCriouSDF .And. MsgYesNo(STR0088+CRLF+STR0089,STR0001)   //"Ser� necess�rio acesso exclusivo ao sistema." ##"Confirma o processamento de cria��o das Entidades no cadastro e execu��o UPDDISTR ?"##"Aten��o" 
	cTxtAux := ""

	//�����������������������������Ŀ
	//�Inclui entidade na CT0      .�
	//�������������������������������

	RpcClearEnv()
	OpenSm0Excl()
	axFil_CT0 := {}
	//����������������������������������������������Ŀ
	//�Realiza a INCLUSAO NA TABELA CT0              �
	//������������������������������������������������
	For nInc := 1 To Len( aSM0 )

		RpcSetType(3)
		RpcSetEnv( aSM0[nInc][1], aSM0[nInc][2] ,,,,, { "AE1", "CT0", "CV0" })
		cTxtAux += STR0090+aSM0[nInc][1] +aSM0[nInc][2] +CRLF  //"Empresa/Filial: "
		
		__cUserID := "000000"

		DEFINE DIALOG oDlg TITLE "TOTVS" FROM  000, 000  TO 220, 320 PIXEL
			nMiliSegs := 3 // Disparo ser� de 3 milisegs
			nCtdTimer := 0
			// TFont
			oTFont := TFont():New('Courier new',,16,.T.)
			// Usando o m�todo New
			oSay1 := TSay():New(040,030,{||STR0101+CRLF+".............."},oDlg,,oTFont,,,,.T.,,,400,20)  //"Processando "

			oTimer := TTimer():New(nMiliSegs, {|| oSay1:SetText(STR0101+CRLF+STR0090+cEmpAnt+cFilAnt), If(nCtdTimer>1,oDlg:End(),nCtdTimer++) }, oDlg ) //"Processando "
			
			oTimer:Activate()
		
		ACTIVATE DIALOG oDlg CENTERED

		//pesquisa se ja nao processou a xFilial da CT0
		nPosEmpFil := AScan(axFil_CT0,cEmpAnt+xFilial("CT0")) 

		If nPosEmpFil > 0
			cTxtAux += STR0091+aSM0[nInc][1] +aSM0[nInc][2] +CRLF  //"Processado mesmo xFilial() : "
			RpcClearEnv()
			OpenSm0Excl()
			Loop
		EndIf
		
		cxFilCT0 := xFilial("CT0")
		
		//popula CT0 e carrega as variaveis
		oProcessCT0:=	MsNewProcess():New( {|lEnd| ENTAtuCT0(oProcessCT0) } )
		oProcessCT0:Activate()
		
		aAdd(axFil_CT0, cEmpAnt+cxFilCT0)

		cTxtAux += STR0015+cEmpAnt+cxFilCT0+CRLF  //"Processamento..."
 
		RpcClearEnv()
		OpenSm0Excl()
	
	Next

	RpcClearEnv()
	RpcSetEnv(aSM0[1][1],aSM0[1][2],,,,, { "AE1" })

	cTxtAux += STR0092+CRLF   //"Assistente de cria��o de Entidades Finalizado!"
	cTxtAux += STR0093+CRLF   //"Neste momento iremos executar a fun��o UPDDISTR para atualiza��o do dicionario de dados!"+CRLF 
	CONOUTR(cTxtAux)

	If MsgYesNo(STR0088+CRLF+STR0094,STR0001 )  //"Ser� necess�rio acesso exclusivo ao sistema." ##"Confirma executar o UPDDISTR agora?"##"Aten��o"
		RpcClearEnv()
		dbCloseAll()
		UPDDISTR()
	EndIf

EndIf

Return(.F.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENTWIZPROC�Autor  �Microsiga           � Data �  02/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao  de processamento da gravacao dos arquivos          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ENTWizProc(lEnd)
Local cTexto   := ''
Local cFile    := ""
Local cMask    := STR0009 //"Arquivos Texto (*.TXT) |*.txt|"

Local oPanel    := oWizard:oMPanel[oWizard:nPanel]
Local nInc		:= 0


//Abre os arquivos das empresas
//alimenta variavel private aSM0
aSM0		:= AdmAbreSM0()


oProcess:SetRegua1( Len( aSM0 ) )

RpcClearEnv()
OpenSm0Excl()

//����������������������������������������������Ŀ
//�Realiza as altera��es nos dicion�rios de dados�
//������������������������������������������������
For nInc := 1 To Len( aSM0 )
	RpcSetType(3)
	RpcSetEnv( aSM0[nInc][1], aSM0[nInc][2] )

	//Provis�rio - Tratamento para contornar erro na LIB
	__cUserID := "000000"
	
	aArqUpd  := {}

	oProcess:IncRegua1( STR0011 + aSM0[nInc][1] + "/"+ STR0012 + aSM0[nInc][2] )  //"Empresa : "###"Filial : "

	cTexto += Replicate("-",128)+CRLF
	cTexto += STR0011 + aSM0[nInc][1] + "/" + STR0012 + aSM0[nInc][2] + "-" + aSM0[nInc][6] + CRLF //"Empresa : "###" Filial : "

	//�������������������������������Ŀ           //�����������������������������Ŀ
	//�Atualiza o dicionario de dados.�           //�Atualiza o Indice           .�  	//---------cTexto += ENTAtuSIX() agora fica dentro EntWizSX3
	//���������������������������������           //�������������������������������
	cTexto += (ENTWizSX3())

	If lEntidad05 .And. lChkCTB .And. (nEntidIni == 5)
		dbSelecTArea("QL6")
		dbCloseArea()
		dbSelecTArea("QL7")
		dbCloseArea()
	EndIf

	RpcClearEnv()
	OpenSm0Excl()
	Exit  //se passou 1 vez na funcao ENTWizSX3 ja criou o SDF entao nao tem pq continuar no laco

Next

RpcSetEnv(aSM0[1][1],aSM0[1][2],,,,, { "AE1" })

cTexto     := STR0027+CRLF+cTexto	//	"Log da atualizacao "
__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15
@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 280,130 OF oPanel PIXEL
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont
DEFINE SBUTTON FROM 122,250 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oPanel PIXEL //Salva e Apaga //"Salvar Como..."

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENTWizSX3 �Autor  �Microsiga           � Data �  02/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao  de processamento da gravacao do SX3                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ENTWizSX3()

Local aEstrut	:= {}
Local cTexto	:= "Classe necess�ria n�o encontrada. Atualize a vers�o da LIB."
Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0
Local cGrpNum	:= ""
Local cEntidNum	:= ""
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())

Local aTabATF	:= {{lChkATF},;															//Checklist ATF ou Refaz Campos
					{"SN3","SN5","SN6","SN7","SNA","SNC","SNG","SNV","SNX","SNW","SNY","FNE","FNF"},;	//Tabelas
					{"N3" ,"N5" ,"N6" ,"N7" ,"NA" ,"NC" ,"NG" ,"NV" ,"NX" ,"NW" ,"NY" ,"FNE","FNF"}}	//Inicial dos campos
Local aTabCOM	:= {{lChkCOM},;				//Checklist Compras ou Refaz Campos
					{"SC1","SC7","SCY","SD1","SDE","SCH","SCX","DBK","DBL"},;	//Tabelas
					{"C1" ,"C7" ,"CY" ,"D1" ,"DE" ,"CH","CX","DBK","DBL"}}	//Inicial dos campos
Local aTabCTB	:= {{lChkCTB},;													//Checklist Contabilidade ou Refaz Campos
					{"CT2","CT9","CTJ","CTK","CTZ","CV3","CV4","CV9","CVD","CW1","CW2","CW3"},;	//Tabelas
					{"CT2","CT9","CTJ","CTK","CTZ","CV3","CV4","CV9","CVD","CW1","CW2","CW3"}}	//Inicial dos campos
Local aTabEST	:= {{lChkEST},;			//Checklist Estoque ou Refaz Campos
					{"SB1","SCP","SCQ","SD3","SDG","SGS"},;	//Tabelas
					{"B1" ,"CP" ,"CQ" ,"D3" ,"DG" , "GS" }}	//Inicial dos campos
Local aTabFAT	:= {{lChkFAT},;	//Checklist Faturamento ou Refaz Campos
					{"SD2","SC6","AGG","AGH"},;		//Tabelas
					{"D2" ,"C6" ,"AGG","AGH" }}		//Inicial dos campos
Local aTabFIN	:= {{lChkFIN},;													//Checklist Financeiro ou Refaz Campos
					{"SE1","SE2","SE3","SE5","SE7","SEA","SED","SEF","SEH","SET","SEU","SEZ", "F46","FK8","FKK" },;	//Tabelas
					{"E1" ,"E2" ,"E3" ,"E5" ,"E7" ,"EA" ,"ED" ,"EF" ,"EH" ,"ET" ,"EU" ,"EZ" , "F46","FK8","FKK" }}	//Inicial dos campos
Local aTabGCT	:= {{lChkGCT},;	//Checklist Gestao de Contratos ou Refaz Campos
					Iif ( AliasIndic( "CXP" ), {"CNB","CNE","CNZ","CXP"}, {"CNB","CNE","CNZ"} ) ,;				//Tabelas
					Iif ( AliasIndic( "CXP" ), {"CNB","CNE","CNZ","CXP"}, {"CNB","CNE","CNZ"} ) } 				//Inicial dos campos
Local aTabVGE	:= {{lChkVGE},;													//Checklist Viagens ou Refaz Campos
					{"FLE","FLG"},;	//Tabelas
					{"FLE","FLG"}}	//Inicial
Local aTabGeral	:= {{.T.},;					//Geracao Padrao
					{"SA1","SA2","SA6"},;	//Tabelas
					{"A1" ,"A2" ,"A6" }}	//Inicial dos campos
Local aTabALL	:= {aTabATF,aTabCOM,aTabCTB,aTabEST,aTabFAT,aTabFIN,aTabGCT,aTabVGE,aTabGeral}
Local aColsGet	:= ACLONE(oGetDados:aCols)
Local aHeader	:= ACLONE(oGetDados:aHeader)
Local nPosPlano	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CT0_ID"})
Local nPosGrupo	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CT0_GRPSXG"})
Local nPosF3	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CT0_F3ENTI"})
Local nPosAlias	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CT0_ALIAS"})

Local cF3
Local cAliasEnt
Local cFolder 	:= ""
Local cPath	 := "\systemload\"


Local cX3Usado	:= "���������������"
Local cX3Usado2	:= "���������������"
Local cX3NaoUso	:= "���������������"
Local xReserv	:= '��'
Local xReserv1	:= '?�'
Local xReserv2	:= '��'
Local xReserv3	:= '�+'
Local xReserv4	:= '�+'
Local xReserv5	:= '�+'
Local xReserv6	:= '��'
 
//Verifica se o dicion�rio esta no banco
Local lInDB		:= MPDicInDB()

Local ox31
Local ox31Ind
Local aSixInd := {}
Local nInd    := 0

aEstrut := {"X3_ARQUIVO"	,"X3_ORDEM"		,"X3_CAMPO"		,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"	,"X3_TITSPA"	,"X3_TITENG"	,;
			"X3_DESCRIC"	,"X3_DESCSPA"	,"X3_DESCENG"	,"X3_PICTURE"	,"X3_VALID"		,"X3_USADO"		,"X3_RELACAO"	,"X3_F3"		,"X3_NIVEL"		,;
			"X3_RESERV"		,"X3_CHECK"		,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	,;
			"X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"		}

//---------------------------------------------------------------------------------
// Tratamento para converter o X3_USADO/X3_RESERV caso o dicion�rio esteja no banco de dados
//---------------------------------------------------------------------------------
if cPaisLoc == "PER"
	xReserv6	:= '��'
Endif

If FindClass("MPX31Field")
	If lInDB
		cX3Usado	:= FWConvBin(cX3Usado)
		cX3Usado2	:= FWConvBin(cX3Usado2)
		cX3NaoUso	:= FWConvBin(cX3NaoUso)
		
		xReserv		:= FWConvRese(xReserv)
		xReserv1	:= FWConvRese(xReserv1)
		xReserv2	:= FWConvRese(xReserv2)
		xReserv3	:= FWConvRese(xReserv3)
		xReserv4	:= FWConvRese(xReserv4)
		xReserv5	:= FWConvRese(xReserv5)
		xReserv6	:= FWConvRese(xReserv6)
		
	EndIf
	oX31 := MPX31Field():New("Inclus�o de Entidades") 

	For nX := 1 To Len(aColsGet) //La�o - Quantidade de entidades.

		cEntidNum	:= AllTrim(aColsGet[nX][nPosPlano]) //Numero corrente da entidade
		cGrpNum		:= aColsGet[nX][nPosGrupo]
		cF3			:= aColsGet[nX][nPosF3]
		cAliasEnt	:= aColsGet[nX][nPosAlias]

		//------------------------------------------
		// Campos padroes da contabilidade - INICIO
		//------------------------------------------
	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CT1"	,"00"		,"CT1_ACET"+cEntidNum		,"C"			,1				,0				,"Aceita Ent"+cEntidNum		,"Acepta Ent"+cEntidNum		,"Accept Ent"+cEntidNum		,"Aceita entidade "+cEntidNum+"?"		,"Acepta ente "+cEntidNum+"?"		,"Accept Entity "+cEntidNum+"?"		,"@!"			,"Pertence('12')"	,cX3Usado			,"'2'"			,""			,1			,xReserv		,""			,""				,"S"			,"N"			,"A"			,"R"			,""				,""				,"1=Sim;2=Nao","1=Si;2=No","1=Yes;2=No","","","","","3","S"})
		oX31:SetAlias("CT1")
		oX31:SetField("CT1_ACET"+cEntidNum)
		oX31:SetType("C")
		oX31:SetSize(1,0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Aceita Ent"+cEntidNum)
		oX31:SetTitleSpa("Acepta Ent"+cEntidNum	)
		oX31:SetTitleEng("Accept Ent"+cEntidNum	)
		oX31:cDescri    := "Aceita entidade "+cEntidNum+"?"
		oX31:cDescriSpa := "Acepta ente "+cEntidNum+"?"
		oX31:cDescriEng := "Accept Entity "+cEntidNum+"?"
		oX31:SetValid("Pertence('12')")
		oX31:SetIniPad("2")	
		oX31:SetLevel('1')
		oX31:SetBox("1=Sim;2=Nao")
		oX31:SetBoxSpa("1=Si;2=No")
		oX31:SetBoxEng("1=Yes;2=No")
		oX31:cFolder    := "3"
		oX31:cBrowse    := "N"
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv )
		oX31:SetOverWrite(.T.)
		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Aceita entidade "+ cEntidNum}
		aPHelpSpa := {"Informe entidad acept� " + cEntidNum}
		aPHelpEng := {"Report accepted entity " + cEntidNum}
		PutHelp("PCT1_ACET"+cEntidNum, aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CT1"  ,"00"       ,"CT1_"+cEntidNum+"OBRG"	,"C"            ,1              ,0              ,"Obrg.Ent."+cEntidNum+"?"	,"Oblig.Ent."+cEntidNum+"?"	,"Mand.Ent."+cEntidNum+"?"	,"Obrigat�ria entidade "+cEntidNum+"?"	,"Obligat�ria ente "+cEntidNum+"?"	,"Mandatory Entity "+cEntidNum+"?"	,"@!"           ,"Pertence('12')"   ,cX3Usado           ,"'2'"          ,""         ,1          ,xReserv        ,""         ,""             ,"S"            ,"N"            ,"A"            ,"R"            ,""             ,""             ,"1=Sim;2=Nao"  ,"1=Si;2=No"    ,"1=Yes;2=No"   ,""             ,""             ,""             ,""             ,"3"            ,"S"})
		oX31:SetAlias("CT1")
		oX31:SetField("CT1_"+cEntidNum+"OBRG")
		oX31:SetType("C")
		oX31:SetSize(1,0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Obrg.Ent."+cEntidNum+"?")
		oX31:SetTitleSpa("Oblig.Ent."+cEntidNum+"?"	)
		oX31:SetTitleEng("Mand.Ent."+cEntidNum+"?")
		oX31:cDescri    := "Obrigat�ria entidade "+cEntidNum+"?"
		oX31:cDescriSpa := "Obligat�ria ente "+cEntidNum+"?"
		oX31:cDescriEng := "Mandatory Entity "+cEntidNum+"?"	
		oX31:SetValid("Pertence('12')")
		oX31:SetIniPad("2")	
		oX31:SetLevel('1')
		oX31:SetBox("1=Sim;2=Nao")
		oX31:SetBoxSpa("1=Si;2=No")
		oX31:SetBoxEng("1=Yes;2=No")
		oX31:cFolder    := "3"
		oX31:cBrowse    := "N"
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Obrigat�ria entidade " + cEntidNum}
		aPHelpSpa := {"Dile a entidad obligatoria " + cEntidNum}
		aPHelpEng := {"Inform Mandatory entity " + cEntidNum}
		PutHelp("PCT1_"+cEntidNum+"OBRG", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CT5"    ,"00"       ,"CT5_EC"+cEntidNum+"DB"    ,"C"            ,200            ,0              ,"Ent.Deb. "+cEntidNum	    ,"Ent.Deb. "+cEntidNum	    ,"Ent.Deb. "+cEntidNum	    ,"Ent. Cont�bil Debito "+cEntidNum	    ,"Ent. Contable Debito "+cEntidNum	,"Acc. Entity Debit "+cEntidNum	    ,"@!"           ,"Vazio() .Or. Ctb080Form()",cX3Usado       ,""             ,cF3        ,1          ,xReserv,"","","S","","","","","","","","","","","","","2","S"})
		oX31:SetAlias("CT5")
		oX31:SetField("CT5_EC"+cEntidNum+"DB")
		oX31:SetType("C")
		oX31:SetSize(200,0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent.Deb. "+cEntidNum)
		oX31:SetTitleSpa("Ent.Deb. "+cEntidNum	)
		oX31:SetTitleEng("Ent.Deb. "+cEntidNum)	
		oX31:cDescri    := "Ent. Cont�bil Debito "+cEntidNum
		oX31:cDescriSpa := "Ent. Contable Debito "+cEntidNum
		oX31:cDescriEng := "Acc. Entity Debit "+cEntidNum	
		oX31:SetValid("Vazio() .Or. Ctb080Form()")
		oX31:SetF3( cF3 ) 
		oX31:SetLevel('1')
		oX31:cFolder    := "2"
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf	
		aPHelpPor := {"Informe Ent. Cont�bil D�bito " + cEntidNum}
		aPHelpSpa := {"Dile a Ent. Contabilidad de d�bito "	+ cEntidNum}
		aPHelpEng := {"Inform Ent. accounting Debit " + cEntidNum}
		PutHelp("PCT5_EC"+cEntidNum+"DB", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)


	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CT5"    ,"00"       ,"CT5_EC"+cEntidNum+"CR"    ,"C"            ,200            ,0              ,"Ent.Cred. "+cEntidNum	    ,"Ent.Cred. "+cEntidNum	    ,"Cred.Ent. "+cEntidNum	    ,"Ent. Cont�bil Cr�dito "+cEntidNum	    ,"Ent. Contable Credito "+cEntidNum	,"Acc. Entity Credit "+cEntidNum    ,"@!"           ,"Vazio() .Or. Ctb080Form()",cX3Usado       ,""             ,cF3        ,1          ,xReserv,"","","S","","","","","","","","","","","","","2","S"})
		oX31:SetAlias("CT5")
		oX31:SetField("CT5_EC"+cEntidNum+"CR")
		oX31:SetType("C")
		oX31:SetSize(200,0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent.Cred. "+cEntidNum)
		oX31:SetTitleSpa("Ent.Cred. "+cEntidNum	)
		oX31:SetTitleEng("Cred.Ent. "+cEntidNum)
		oX31:cDescri    := "Ent. Cont�bil Cr�dito "+cEntidNum
		oX31:cDescriSpa := "Ent. Contable Credito "+cEntidNum
		oX31:cDescriEng := "Acc. Entity Credit "+cEntidNum
		oX31:SetValid("Vazio() .Or. Ctb080Form()")
		oX31:SetF3( cF3 ) 
		oX31:SetLevel('1')
		oX31:cFolder    := "2"
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf		

		aPHelpPor := {"Informe Ent. Cont�bil Cr�dito " + cEntidNum}
		aPHelpSpa := {"Dile a Ent. Contabilidad de d�bito "	+ cEntidNum}
		aPHelpEng := {"Inform Ent. Credit accounting " + cEntidNum}
		PutHelp("PCT5_EC"+cEntidNum+"CR", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)
        
	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CVX","00","CVX_NIV"+cEntidNum,"C",TamSXG(cGrpNum)[1],0,"N�vel "+cEntidNum,"N�vel "+cEntidNum,"Level "+cEntidNum,"N�vel "+cEntidNum,"N�vel "+cEntidNum,"Level "+cEntidNum,"@!","",cX3Usado,"","",1,xReserv,"","","","","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CVX")
		oX31:SetField("CVX_NIV"+cEntidNum)
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("N�vel "+cEntidNum)
		oX31:SetTitleSpa("N�vel "+cEntidNum)
		oX31:SetTitleEng("Level "+cEntidNum)
		oX31:cDescri    := "N�vel "+cEntidNum
		oX31:cDescriSpa := "N�vel "+cEntidNum
		oX31:cDescriEng := "Level "+cEntidNum
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe N�vel " + cEntidNum}
		aPHelpSpa := {"Dile a nivel " + cEntidNum}
		aPHelpEng := {"Inform Level " + cEntidNum}
		PutHelp("PCVX_NIV"+cEntidNum, aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CVY","00","CVY_NIV"+cEntidNum,"C",TamSXG(cGrpNum)[1],0,"N�vel "+cEntidNum,"N�vel "+cEntidNum,"Level "+cEntidNum,"N�vel "+cEntidNum,"N�vel "+cEntidNum,"Level "+cEntidNum,"@!","",cX3Usado,"","",1,xReserv,"","","","","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CVY")
		oX31:SetField("CVY_NIV"+cEntidNum)
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("N�vel "+cEntidNum)
		oX31:SetTitleSpa("N�vel "+cEntidNum)
		oX31:SetTitleEng("Level "+cEntidNum)	
		oX31:cDescri    := "N�vel "+cEntidNum
		oX31:cDescriSpa := "N�vel "+cEntidNum
		oX31:cDescriEng := "Level "+cEntidNum		
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe N�vel " + cEntidNum}
		aPHelpSpa := {"Dile a nivel " + cEntidNum}
		aPHelpEng := {"Inform Level " + cEntidNum}
		PutHelp("PCVY_NIV"+cEntidNum, aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CVZ","00","CVZ_NIV"+cEntidNum,"C",TamSXG(cGrpNum)[1],0,"N�vel "+cEntidNum,"N�vel "+cEntidNum,"Level "+cEntidNum,"N�vel "+cEntidNum,"N�vel "+cEntidNum,"Level "+cEntidNum,"@!","",cX3Usado,"","",1,xReserv,"","","","","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CVZ")
		oX31:SetField("CVZ_NIV"+cEntidNum)
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("N�vel "+cEntidNum)
		oX31:SetTitleSpa("N�vel "+cEntidNum)
		oX31:SetTitleEng("Level "+cEntidNum)
		oX31:cDescri    := "N�vel "+cEntidNum
		oX31:cDescriSpa := "N�vel "+cEntidNum
		oX31:cDescriEng := "Level "+cEntidNum
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe N�vel " + cEntidNum}
		aPHelpSpa := {"Dile a nivel " + cEntidNum}
		aPHelpEng := {"Inform Level " + cEntidNum}
		PutHelp("PCVZ_NIV"+cEntidNum, aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CTB","00","CTB_E"+cEntidNum+"DES","C",TamSXG(cGrpNum)[1],0,"Ent."+cEntidNum+" Dest.","Ent."+cEntidNum+" Dest."	,"Ent."+cEntidNum+" Dest."	,"Entidade "+cEntidNum+" Destino"		,"Entidad "+cEntidNum+" Destino"		,"Entity "+cEntidNum+" Destiny"			,"@!",""							,cX3NaoUso,"",cF3,1,xReserv1	,"","","","S","","","","","","","","",""											,"",cGrpNum,"","N"})
		oX31:SetAlias("CTB")
		oX31:SetField("CTB_E"+cEntidNum+"DES")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent."+cEntidNum+" Dest.")
		oX31:SetTitleSpa("Ent."+cEntidNum+" Dest.")
		oX31:SetTitleEng("Ent."+cEntidNum+" Dest.")
		oX31:cDescri    := "Entidade "+cEntidNum+" Destino"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Destino"
		oX31:cDescriEng := "Entity "+cEntidNum+" Destiny"
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1') 
		oX31:SetUsed(cX3NaoUso )
		oX31:SetObrigat(xReserv1 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Destino."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Destino."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " Destiny."}
		PutHelp("PCTB_E"+cEntidNum+"DES", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CTB","00","CTB_E"+cEntidNum+"INI","C",TamSXG(cGrpNum)[1],0,"Ent. "+cEntidNum+" Ini"	,"Ent. "+cEntidNum+" Ini"	,"Ent. "+cEntidNum+" Ini"	,"Entid. "+cEntidNum+" Inicial Origem"	,"Entid. "+cEntidNum+" Inicio Origen"	,"Entity "+cEntidNum+" Initial Origin"	,"@!","Vazio() .Or. CtbEntExis()"	,cX3Usado2,"",cF3,1,xReserv2,"","","","S","","","","","","","","",'TrocaF3("'+cAliasEnt+'","'+cEntidNum+'")'	,"",cGrpNum,"","N"})
		oX31:SetAlias("CTB")
		oX31:SetField("CTB_E"+cEntidNum+"INI")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent."+cEntidNum+" Ini")
		oX31:SetTitleSpa("Ent."+cEntidNum+" Ini")
		oX31:SetTitleEng("Ent."+cEntidNum+" Ini")
		oX31:cDescri    := "Entid. "+cEntidNum+" Inicial Origem"
		oX31:cDescriSpa := "Entid. "+cEntidNum+" Inicio Origen"
		oX31:cDescriEng := "Entity "+cEntidNum+" Initial Origin"
		oX31:SetValid("Vazio() .Or. CtbEntExis()")
		oX31:SetWhen('TrocaF3("'+cAliasEnt+'","'+cEntidNum+'")')
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1') 
		oX31:SetUsed(cX3Usado2 )
		oX31:SetObrigat(xReserv2 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf
		
		aPHelpPor := {"Informe Entidade " + cEntidNum + " Inicial Origem."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Inicio Origen."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " initial Source."}
		PutHelp("PCTB_E"+cEntidNum+"INI", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)


	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CTB","00","CTB_E"+cEntidNum+"FIM","C",TamSXG(cGrpNum)[1],0,"Ent. "+cEntidNum+" Fim"	,"Ent. "+cEntidNum+" Fin"	,"Ent. "+cEntidNum+" END"	,"Entidade "+cEntidNum+" Final Origem"	,"Entidad "+cEntidNum+" Final Origen"	,"Entity "+cEntidNum+" Final Origin"	,"@!","Vazio() .Or. CtbEntExis()"	,cX3Usado2,"",cF3,1,xReserv2,"","","","S","","","","","","","","",'TrocaF3("'+cAliasEnt+'", "'+cEntidNum+'")'	,"",cGrpNum,"","N"})
		oX31:SetAlias("CTB")
		oX31:SetField("CTB_E"+cEntidNum+"FIM")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent."+cEntidNum+" Fim")
		oX31:SetTitleSpa("Ent."+cEntidNum+" Fin")
		oX31:SetTitleEng("Ent."+cEntidNum+" END")
		oX31:cDescri    := "Entidade "+cEntidNum+" Final Origem"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Final Origen"
		oX31:cDescriEng := "Entity "+cEntidNum+" Final Origin"
		oX31:SetValid("Vazio() .Or. CtbEntExis()")
		oX31:SetWhen('TrocaF3("'+cAliasEnt+'","'+cEntidNum+'")')
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado2 )
		oX31:SetObrigat(xReserv2 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Final Origem."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " final Origen."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " Origin final."}
		PutHelp("PCTB_E"+cEntidNum+"FIM", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CTQ","00","CTQ_E"+cEntidNum+"ORI"	,"C",TamSXG(cGrpNum)[1],0,"Ent. "+cEntidNum+"Ori"	,"Ent. "+cEntidNum+"Ori"	,"Ent. "+cEntidNum+"Ori"	,"Entidade "+cEntidNum+" Origem"		,"Entidad "+cEntidNum+" Origen"			,"Entity "+cEntidNum+" Origin"		,"@!","CtbEntExis()",cX3Usado,"",cF3,1,xReserv3,"","","","N","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CTQ")
		oX31:SetField("CTQ_E"+cEntidNum+"ORI")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent. "+cEntidNum+"Ori")
		oX31:SetTitleSpa("Ent. "+cEntidNum+"Ori")
		oX31:SetTitleEng("Ent. "+cEntidNum+"Ori")
		oX31:cDescri    := "Entidade "+cEntidNum+" Origem"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Origen"
		oX31:cDescriEng := "Entity "+cEntidNum+" Origin"
		oX31:cBrowse	:= "N"
		oX31:SetValid("CtbEntExis()")
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1') 
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv3 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Origem."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Origen."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " Source."}
		PutHelp("PCTQ_E"+cEntidNum+"ORI", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

		aHelpPor := {"Digite a Entidade " + cEntidNum	,"Origem para obter o valor a"				,"ser rateado."}
		aHelpEsp := {"Digite la Entidad " + cEntidNum	,"origen para obtener el valor"				,"a prorratearse"}
		aHelpEng := {"Enter the source Entity "			,cEntidNum + "to obtain the value to be"	,"prorated."}
		PutHelp("PCCTQ_E"+cEntidNum+"ORI", aHelpPor,aHelpEng,aHelpEsp,.T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CTQ","00","CTQ_E"+cEntidNum+"PAR"	,"C",TamSXG(cGrpNum)[1],0,"Ent. "+cEntidNum+"Part"	,"Ent. "+cEntidNum+"Part"	,"Ent. "+cEntidNum+"Depar"	,"Entidade "+cEntidNum+" Partida"		,"Entidad "+cEntidNum+" Partida"		,"Entity "+cEntidNum+" Departure"	,"@!","CtbEntExis()",cX3Usado,"",cF3,1,xReserv3,"","","","N","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CTQ")
		oX31:SetField("CTQ_E"+cEntidNum+"PAR")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent. "+cEntidNum+"Part")
		oX31:SetTitleSpa("Ent. "+cEntidNum+"Part")
		oX31:SetTitleEng("Ent. "+cEntidNum+"Depar")
		oX31:cDescri    := "Entidade "+cEntidNum+" Partida"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Partida"
		oX31:cDescriEng := "Entity "+cEntidNum+" Departure"
		oX31:cBrowse    := "N"
		oX31:SetValid("CtbEntExis()")
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv3 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf
		aPHelpPor := {"Informe Entidade " + cEntidNum + " Partida."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Partida."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " Departure."}
		PutHelp("PCTQ_E"+cEntidNum+"PAR", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

		aHelpPor := {"Neste campo dever� ser informado"	,"a Entidade " + cEntidNum + " a ser"	,"Debitada/Creditada na gera��o","dos lan�amentos de rateio."		,"Ser� Debitada/Creditada dependendo da"	,"Natureza do saldo resultante."		,"Se o Valor for devedor o Lan�amento"	,"ser� Credor e vice-versa.","Tecla <F3> disponivel para consulta"			,"do Cadastro de Entidade " + cEntidNum + "."}
		aHelpEsp := {"En este campo debera informarse"	,"la Entidad " + cEntidNum + " que se"	,"adeudara/acreditara en la"	,"generacion de los asientos de"	,"prorrateo. Se adeudara/acreditara segun"	,"la modalidad del saldo resultante."	,"Si el valor es deudor el asiento sera","acreedor y vice versa."	,"Pulse (F3) disponible para consultar"			,"el archivo de Entidad " + cEntidNum + "."}
		aHelpEng := {"You must inform in this field the","Entity " + cEntidNum + " to be"		,"debited/credited during the"	,"generaton of proration entries."	,"It will be credited/debited depending"	,"on the resulting balance nature."		,"If the value is in debt, the entries"	,"won�t be and vice versa."	,"<F3> available for the Entity " + cEntidNum	,"file look-up."}
		PutHelp("PCCTQ_E"+cEntidNum+"PAR", aHelpPor,aHelpEng,aHelpEsp,.T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CTQ","00","CTQ_E"+cEntidNum+"CP"	,"C",TamSXG(cGrpNum)[1],0,"Ent. "+cEntidNum+" CPar"	,"Ent. "+cEntidNum+" CPar"	,"Ent. "+cEntidNum+" CPar"	,"Entid. "+cEntidNum+" Contra-Partida"	,"Entid. "+cEntidNum+" Contrapartida"	,"Entity "+cEntidNum+" Counterpart"	,"@!","CtbEntExis()",cX3Usado,"",cF3,1,xReserv4,"","","","N","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CTQ")
		oX31:SetField("CTQ_E"+cEntidNum+"CP")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent. "+cEntidNum+" CPar")
		oX31:SetTitleSpa("Ent. "+cEntidNum+" CPar")
		oX31:SetTitleEng("Ent. "+cEntidNum+" CPar")
		oX31:cDescri    := "Entid. "+cEntidNum+" Contra-Partida"
		oX31:cDescriSpa := "Entid. "+cEntidNum+" Contrapartida"
		oX31:cDescriEng := "Entity "+cEntidNum+" Counterpart"
		oX31:cBrowse    := "N"
		oX31:SetValid("CtbEntExis()")
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv4 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Contra Partida."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Contrapartida."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " Counterpart ."}
		PutHelp("PCTQ_E"+cEntidNum+"CP", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CV9","00","CV9_E"+cEntidNum+"ORI"	,"C",TamSXG(cGrpNum)[1],0,"Ent. "+cEntidNum+"Ori"	,"Ent. "+cEntidNum+"Ori"	,"Ent. "+cEntidNum+"Ori"	,"Entidade "+cEntidNum+" Origem"		,"Entidad "+cEntidNum+" Origen"			,"Entity "+cEntidNum+" Origin"		,"@!","",cX3Usado,"",cF3,1,xReserv4,"","","","S","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CV9")
		oX31:SetField("CV9_E"+cEntidNum+"ORI")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent. "+cEntidNum+"Ori")
		oX31:SetTitleSpa("Ent. "+cEntidNum+"Ori")
		oX31:SetTitleEng("Ent. "+cEntidNum+"Ori")
		oX31:cDescri    := "Entidade "+cEntidNum+" Origem"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Origen"
		oX31:cDescriEng := "Entity "+cEntidNum+" Origin"
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv4 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf
		aPHelpPor := {"Informe Entidade " + cEntidNum + " Origem."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Origen."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " Origin ."}
		PutHelp("PCV9_E"+cEntidNum+"ORI", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)


	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CV9","00","CV9_E"+cEntidNum+"PAR"	,"C",TamSXG(cGrpNum)[1],0,"Ent. "+cEntidNum+"Part"	,"Ent. "+cEntidNum+"Part"	,"Ent. "+cEntidNum+"Depar"	,"Entidade "+cEntidNum+" Partida"		,"Entidad "+cEntidNum+" Partida"		,"Entity "+cEntidNum+" Departure"	,"@!","",cX3Usado,"",cF3,1,xReserv4,"","","","S","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CV9")
		oX31:SetField("CV9_E"+cEntidNum+"PAR")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent. "+cEntidNum+"Part")
		oX31:SetTitleSpa("Ent. "+cEntidNum+"Part")
		oX31:SetTitleEng("Ent. "+cEntidNum+"Depar")
		oX31:cDescri    := "Entidade "+cEntidNum+" Partida"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Partida"
		oX31:cDescriEng := "Entity "+cEntidNum+" Departure"
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv4 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Partida."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Partida."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " Departure ."}
		PutHelp("PCV9_E"+cEntidNum+"PAR", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CV9","00","CV9_E"+cEntidNum+"CP"	,"C",TamSXG(cGrpNum)[1],0,"Ent. "+cEntidNum+" CPar"	,"Ent. "+cEntidNum+" CPar"	,"Ent. "+cEntidNum+" CPar"	,"Entid. "+cEntidNum+" Contra-Partida"	,"Entid. "+cEntidNum+" Contrapartida"	,"Entity "+cEntidNum+" Counterpart"	,"@!","",cX3Usado,"",cF3,1,xReserv4,"","","","S","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CV9")
		oX31:SetField("CV9_E"+cEntidNum+"CP")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent. "+cEntidNum+" CPar")
		oX31:SetTitleSpa("Ent. "+cEntidNum+" CPar")
		oX31:SetTitleEng("Ent. "+cEntidNum+" CPar")
		oX31:cDescri    := "Entid. "+cEntidNum+" Contra-Partida"
		oX31:cDescriSpa := "Entid. "+cEntidNum+" Contrapartida"
		oX31:cDescriEng := "Entity "+cEntidNum+" Counterpart"
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv4 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Contra Partida."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Contrapartida."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " Counterpart."}
		PutHelp("PCV9_E"+cEntidNum+"CP", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CV5","00","CV5_E"+cEntidNum+"ORI","C",TamSXG(cGrpNum)[1],0,"Ent."+cEntidNum+" Orig.","Ent."+cEntidNum+" Orig.","Source Ent"+cEntidNum	,"Entidade "+cEntidNum+" Origem"		,"Entidad "+cEntidNum+" Origen"			,"Source Entity "+cEntidNum			,"@!"	,"CtbEntExis()"	,cX3Usado,"",cF3	,1,xReserv5,"","","","S","A","R","","","","","","",""										,"",cGrpNum	,"","N"})
		oX31:SetAlias("CV5")
		oX31:SetField("CV5_E"+cEntidNum+"ORI")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent. "+cEntidNum+"Orig")
		oX31:SetTitleSpa("Ent. "+cEntidNum+"Orig")
		oX31:SetTitleEng("Source Ent"+cEntidNum)
		oX31:cDescri    := "Entidade "+cEntidNum+" Origem"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Origen"
		oX31:cDescriEng := "Source Entity "+cEntidNum
		oX31:SetValid("CtbEntExis()")
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv5 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Origem."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Origen."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " Origin ."}
		PutHelp("PCV5_E"+cEntidNum+"ORI", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CV5","00","CV5_E"+cEntidNum+"FIM","C",TamSXG(cGrpNum)[1],0,"Entid."+cEntidNum+" Fim","Entid."+cEntidNum+" Fin","Fin. Ent."+cEntidNum	,"Entidade "+cEntidNum+" Orig. Fim"		,"Entidad "+cEntidNum+" Orig. Fin"		,"Final Entity "+cEntidNum+" Source","@!"	,""				,cX3Usado,"",cF3	,1,xReserv5,"","","","S","A","R","","","","","","",""										,"",cGrpNum	,"","N"})
		oX31:SetAlias("CV5")
		oX31:SetField("CV5_E"+cEntidNum+"FIM")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Entid."+cEntidNum+" Fim")
		oX31:SetTitleSpa("Entid."+cEntidNum+" Fin")
		oX31:SetTitleEng("Fin. Ent."+cEntidNum)
		oX31:cDescri    := "Entidade "+cEntidNum+" Orig. Fim"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Orig. Fin"
		oX31:cDescriEng := "Final Entity "+cEntidNum+" Source"
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv5 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Origem Fim."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " final Origen."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " Origin final ."}
		PutHelp("PCV5_E"+cEntidNum+"FIM", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CV5","00","CV5_E"+cEntidNum+"DES","C",TamSXG(cGrpNum)[1],0,"Ent."+cEntidNum+" Dest.","Ent."+cEntidNum+" Dest.","Dest. Ent."+cEntidNum	,"Entidade "+cEntidNum+" Destino"		,"Entidad "+cEntidNum+" Destino"		,"Destination Entity "+cEntidNum	,"@!"	,"CtbEntExis()"	,cX3Usado,"",cF3	,1,xReserv5,"","","","S","A","R","","","","","","","CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)"	,"",cGrpNum	,"","N"})
		oX31:SetAlias("CV5")
		oX31:SetField("CV5_E"+cEntidNum+"DES")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent."+cEntidNum+" Dest.")
		oX31:SetTitleSpa("Ent."+cEntidNum+" Dest.")
		oX31:SetTitleEng("Dest. Ent."+cEntidNum)
		oX31:cDescri    := "Entidade "+cEntidNum+" Destino"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Destino"
		oX31:cDescriEng := "Destination Entity "+cEntidNum
		oX31:SetValid("CtbEntExis()")
		oX31:SetWhen("CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)")
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv5 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf
		aPHelpPor := {"Informe Entidade " + cEntidNum + " Destino."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Destino."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " Destiny ."}
		PutHelp("PCV5_E"+cEntidNum+"DES", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CV5","00","CV5_E"+cEntidNum+"IGU","C",1					,0,"Ent."+cEntidNum+" igual","Ent."+cEntidNum+" igual","Ent."+cEntidNum+" equal","Entidade "+cEntidNum+" igual origem"	,"Entidad "+cEntidNum+" igual origen"	,"Entity "+cEntidNum+" equal origin",""		,""				,cX3Usado,"",""		,1,xReserv5,"","","",""	,""	,""	,"","","","","","",""										,"",""		,"","N"})
		oX31:SetAlias("CV5")
		oX31:SetField("CV5_E"+cEntidNum+"IGU")
		oX31:SetType("C")
		oX31:SetSize(1,0)
		oX31:SetTitle("Ent."+cEntidNum+" igual")
		oX31:SetTitleSpa("Ent."+cEntidNum+" igual")
		oX31:SetTitleEng("Ent."+cEntidNum+" equal")
		oX31:cDescri    := "Entidade "+cEntidNum+" igual origem"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" igual origen"
		oX31:cDescriEng := "Entity "+cEntidNum+" equal origin"
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(xReserv5 )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " igual origem."}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " igual origen."}
		aPHelpEng := {"Inform Entity " + cEntidNum + " equal origin ."}
		PutHelp("PCV5_E"+cEntidNum+"IGU", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CTA","00","CTA_ENTI"+cEntidNum,"C",TamSXG(cGrpNum)[1],0,"Entidade "+cEntidNum,"Entidad "+cEntidNum,"Entity "+cEntidNum,"Entidade "+cEntidNum,"Entidad "+cEntidNum,"Entity "+cEntidNum,"","",cX3Usado,"","",1,"","","","","","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CTA")
		oX31:SetField("CTA_ENTI"+cEntidNum)
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetTitle("Entidade "+cEntidNum)
		oX31:SetTitleSpa("Entidad "+cEntidNum)
		oX31:SetTitleEng("Entity "+cEntidNum)
		oX31:cDescri    := "Entidade "+cEntidNum
		oX31:cDescriSpa := "Entidad "+cEntidNum
		oX31:cDescriEng := "Entity "+cEntidNum
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum}
		aPHelpEng := {"Inform Entity " + cEntidNum}
		PutHelp("PCTA_ENTI"+cEntidNum, aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CTS","00","CTS_E"+cEntidNum+"INI","C",TamSXG(cGrpNum)[1],0,"Entid."+cEntidNum+" Ini","Entid."+cEntidNum+" Ini","Init. Ent."+cEntidNum,"Entidade "+cEntidNum+" Inicial"	,"Entidad "+cEntidNum+" Inicial","Initial Entity "+cEntidNum,"@!","Vazio() .Or. CtbEntExis()",cX3Usado,"",cF3,1,IIf(lInDB,FWConvRese("��"),"��"),"","","","S","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CTS")
		oX31:SetField("CTS_E"+cEntidNum+"INI")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Entid."+cEntidNum+" Ini")
		oX31:SetTitleSpa("Entid."+cEntidNum+" Ini")
		oX31:SetTitleEng("Init. Ent."+cEntidNum)
		oX31:cDescri    := "Entidade "+cEntidNum+" Inicial"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Inicial"
		oX31:cDescriEng := "Initial Entity "+cEntidNum
		oX31:SetValid("Vazio() .Or. CtbEntExis()")
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(FWConvRese("��") )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Inicial "}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Inicial"}
		aPHelpEng := {"Inform Initial Entity  " + cEntidNum}
		PutHelp("PCTS_E"+cEntidNum+"INI", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CTS","00","CTS_E"+cEntidNum+"FIM","C",TamSXG(cGrpNum)[1],0,"Ent."+cEntidNum+" Final","Ent."+cEntidNum+" Final","Final Ent."+cEntidNum,"Entidade "+cEntidNum+" Final"	,"Entidad "+cEntidNum+" Final"	,"Final Entity "+cEntidNum	,"@!","Vazio() .Or. CtbEntExis()",cX3Usado,"",cF3,1,IIf(lInDB,FWConvRese("��"),"��"),"","","","S","","","","","","","","","","",cGrpNum,"","N"})
		oX31:SetAlias("CTS")
		oX31:SetField("CTS_E"+cEntidNum+"FIM")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent."+cEntidNum+" Final")
		oX31:SetTitleSpa("Ent."+cEntidNum+" Final")
		oX31:SetTitleEng("Final Ent."+cEntidNum)
		oX31:cDescri    := "Entidade "+cEntidNum+" Final"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Final"
		oX31:cDescriEng := "Final Entity "+cEntidNum
		oX31:SetValid("Vazio() .Or. CtbEntExis()")
		oX31:SetF3( cF3 ) 
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(FWConvRese("��") )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Final"}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Final"}
		aPHelpEng := {"Inform Final Entity  " + cEntidNum}
		PutHelp("PCTS_E"+cEntidNum+"FIM", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CV1","00","CV1_E"+cEntidNum+"INI","C",TamSXG(cGrpNum)[1],0,"Ent."+cEntidNum+" Ini"	,"Ent."+cEntidNum+" Inic.","Init. Ent."+cEntidNum,"Entidade "+cEntidNum+" Inicial"	,"Entidad "+cEntidNum+" Inicial","Initial Entity "+cEntidNum,"@!","Ctb390Vld()",cX3Usado,"",cF3,1,IIf(lInDB,FWConvRese("��"),"��"),"","","","","","","","","","","","","CtbMovSaldo('CT0',,'"+cEntidNum+"')","",cGrpNum,"","N"})
		oX31:SetAlias("CV1")
		oX31:SetField("CV1_E"+cEntidNum+"INI")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Entid."+cEntidNum+" Ini")
		oX31:SetTitleSpa("Entid."+cEntidNum+" Inic")
		oX31:SetTitleEng("Init. Ent."+cEntidNum)
		oX31:cDescri    := "Entidade "+cEntidNum+" Inicial"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Inicial"
		oX31:cDescriEng := "Initial Entity "+cEntidNum
		oX31:SetValid("Ctb390Vld()")
		oX31:SetF3( cF3 ) 
		oX31:SetWhen("CtbMovSaldo('CT0',,'"+cEntidNum+"')")
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(FWConvRese("��") )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Inicial"}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Inicial"}
		aPHelpEng := {"Inform Initial Entity  " + cEntidNum}
		PutHelp("PCV1_E"+cEntidNum+"INI", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    //"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
		//Aadd(aSX3,{"CV1","00","CV1_E"+cEntidNum+"FIM","C",TamSXG(cGrpNum)[1],0,"Ent."+cEntidNum+" Final","Ent."+cEntidNum+" Final","Final Ent."+cEntidNum,"Entidade "+cEntidNum+" Final"	,"Entidad "+cEntidNum+" Final"	,"Final Entity "+cEntidNum	,"@!","Ctb390Vld()",cX3Usado,"",cF3,1,IIf(lInDB,FWConvRese("��"),"��"),"","","","","","","","","","","","","CtbMovSaldo('CT0',,'"+cEntidNum+"')","",cGrpNum,"","N"})
		oX31:SetAlias("CV1")
		oX31:SetField("CV1_E"+cEntidNum+"FIM")
		oX31:SetType("C")
		oX31:SetSize(TamSXG(cGrpNum)[1],0)
		oX31:SetPicture("@!")
		oX31:SetTitle("Ent."+cEntidNum+" Final")
		oX31:SetTitleSpa("Ent."+cEntidNum+" Final")
		oX31:SetTitleEng("Final Ent."+cEntidNum)
		oX31:cDescri    := "Entidade "+cEntidNum+" Final"
		oX31:cDescriSpa := "Entidad "+cEntidNum+" Final"
		oX31:cDescriEng := "Final Entity "+cEntidNum
		oX31:SetValid("Ctb390Vld()")
		oX31:SetF3( cF3 ) 
		oX31:SetWhen("CtbMovSaldo('CT0',,'"+cEntidNum+"')")
		oX31:SetGroup( cGrpNum ) 
		oX31:SetLevel('1')
		oX31:SetUsed(cX3Usado )
		oX31:SetObrigat(FWConvRese("��") )		
		oX31:SetOverWrite(.T.)

		If oX31:VldData()
			oX31:CommitData()
		EndIf

		aPHelpPor := {"Informe Entidade " + cEntidNum + " Final"}
		aPHelpSpa := {"Dile a la entidad " + cEntidNum + " Final"}
		aPHelpEng := {"Inform Final Entity  " + cEntidNum}
		PutHelp("PCV1_E"+cEntidNum+"FIM", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

		//------------------------------------------
		// Campos padroes da contabilidade - FIM
		//------------------------------------------

		//--------------------------------------------------------------
		// Campos Debito e Credito padroes para os modulos selecionados
		//--------------------------------------------------------------
		For nY := 1 To Len(aTabALL) //La�o - M�dulos selecionaveis
			If aTabALL[nY][1][1] == .T. //Valida��o - M�dulo selecionado
				For nZ := 1 To Len(aTabAll[nY][2]) //La�o - Campos para gera��o
					If AliasInDic(aTabALL[nY][2][nZ])

						cFolder := Iif( aTabALL[nY][2][nZ] == "SED", "5", "" )


	    				//"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
						//Aadd(aSX3,{aTabALL[nY][2][nZ],"00",aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"DB","C",TamSXG(cGrpNum)[1],0,"Ent.Deb. "	+cEntidNum,"Ent.Deb. "	+cEntidNum,"Ent.Deb. "	+cEntidNum,"Ent. Cont�bil Debito "	+cEntidNum,"Ent. Contable Debito "	+cEntidNum,"Acc. Entity Debit "	+cEntidNum,"@!","CTB105EntC(,M->"+aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"DB,,'"+cEntidNum+"')",cX3Usado,"",cF3,1,xReserv6,"","","S","","","","","","","","","","","",cGrpNum,cFolder,"S"})
						
						oX31:SetAlias(aTabALL[nY][2][nZ])
						oX31:SetField(aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"DB")
						oX31:SetType("C")
						oX31:SetSize(TamSXG(cGrpNum)[1],0)
						oX31:SetPicture("@!")
						oX31:SetTitle("Ent.Deb. "	+cEntidNum)
						oX31:SetTitleSpa("Ent.Deb. "	+cEntidNum)
						oX31:SetTitleEng("Ent.Deb. "	+cEntidNum)
						oX31:cDescri    := "Ent. Cont�bil Debito "	+cEntidNum
						oX31:cDescriSpa := "Ent. Contable Debito "	+cEntidNum
						oX31:cDescriEng := "Acc. Entity Debit "	+cEntidNum
						If  	aTabALL[nY][2][nZ] $ 'SC1|SCP|SCX|SGS'
							oX31:SetValid("CTB105EntC(,M->"+aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"DB,,'"+cEntidNum+"')  .And. MTPVLSOLEC() ")
						ElseIf aTabALL[nY][2][nZ] == 'DBK' 
							oX31:SetValid("Vazio() .Or. CTB105EntC(,M->"+aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"DB,,'"+cEntidNum+"') .Or. FwFldGet('DBK_EC"+cEntidNum+"DB')=='*'")
						Else
							oX31:SetValid("CTB105EntC(,M->"+aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"DB,,'"+cEntidNum+"')")
						EndIf
						oX31:SetF3( cF3 )
						oX31:SetGroup( cGrpNum ) 
						oX31:cFolder    := cFolder
						oX31:SetLevel('1') 
						oX31:SetUsed(cX3Usado )
						oX31:SetObrigat(xReserv6 )		
						oX31:SetOverWrite(.T.)

						If oX31:VldData()
							oX31:CommitData()
						EndIf
						aPHelpPor := {"Informe Ent. Cont�bil D�bito "		+ cEntidNum}
						aPHelpSpa := {"Dile a Ent. Contabilidad de d�bito "	+ cEntidNum}
						aPHelpEng := {"Inform Ent. accounting Debit "		+ cEntidNum}
						PutHelp("P"+aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"DB", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

	    				//"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
						//Aadd(aSX3,{aTabALL[nY][2][nZ],"00",aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"CR","C",TamSXG(cGrpNum)[1],0,"Ent.Cred. "+cEntidNum,"Ent.Cred. "	+cEntidNum,"Cred.Ent. "	+cEntidNum,"Ent. Cont�bil Credito "	+cEntidNum,"Ent. Contable Credito "	+cEntidNum,"Acc. Entity Credit "+cEntidNum,"@!","CTB105EntC(,M->"+aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"CR,,'"+cEntidNum+"')",cX3Usado,"",cF3,1,xReserv6,"","","S","","","","","","","","","","","",cGrpNum,cFolder,"S"})
						oX31:SetAlias(aTabALL[nY][2][nZ])
						oX31:SetField(aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"CR")
						oX31:SetType("C")
						oX31:SetSize(TamSXG(cGrpNum)[1],0)
						oX31:SetPicture("@!")
						oX31:SetTitle("Ent.Cred. "	+cEntidNum)
						oX31:SetTitleSpa("Ent.Cred. "	+cEntidNum)
						oX31:SetTitleEng("Cred.Ent. "	+cEntidNum)
						oX31:cDescri    := "Ent. Cont�bil Credito "	+cEntidNum
						oX31:cDescriSpa := "Ent. Contable Credito "	+cEntidNum
						oX31:cDescriEng := "Acc. Entity Credit "+cEntidNum
						If  	aTabALL[nY][2][nZ] $ 'SC1|SCP|SCX|SGS'
							oX31:SetValid("CTB105EntC(,M->"+aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"CR,,'"+cEntidNum+"')  .And. MTPVLSOLEC() ")
						ElseIf aTabALL[nY][2][nZ] == 'DBK' 
							oX31:SetValid("Vazio() .Or. CTB105EntC(,M->"+aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"CR,,'"+cEntidNum+"') .Or. FwFldGet('DBK_EC"+cEntidNum+"CR')=='*'")
						Else
							oX31:SetValid("CTB105EntC(,M->"+aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"CR,,'"+cEntidNum+"')")
						EndIf
						oX31:SetF3( cF3 )
						oX31:SetGroup( cGrpNum ) 
						oX31:cFolder    := cFolder
						oX31:SetLevel('1') 
						oX31:SetUsed(cX3Usado )
						oX31:SetObrigat(xReserv6 )		
						oX31:SetOverWrite(.T.)
						
						If oX31:VldData()
							oX31:CommitData()
						EndIf						
						
						aPHelpPor := {"Informe Ent. Cont�bil Cr�dito "			+ cEntidNum}
						aPHelpSpa := {"Dile a Ent. Contabilidad de cr�dito "	+ cEntidNum}
						aPHelpEng := {"Inform Ent. accounting credit "			+ cEntidNum}
						PutHelp("P"+aTabALL[nY][3][nZ]+"_EC"+cEntidNum+"CR", aPHelpPor, aPHelpEng, aPHelpSpa, .T.)

					EndIf
				Next nZ
			EndIf
		Next nY

		//---------------------------
		// Campos especificos do PCO
		//---------------------------
		If lChkPCO

			//"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
			//Aadd(aSX3,{'AK2','00','AK2_ENT' + cEntidNum,'C',TamSXG(cGrpNum)[1],0,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'@!','Vazio() .Or. CTB105EntC(,M->AK2_ENT'+cEntidNum+',,"'+cEntidNum+'")',cX3Usado,'',cF3,1,IIf(lInDB,FWConvRese(Chr(150) + Chr(192)),Chr(150) + Chr(192)),'','S','S','S','A','R','N','','','','','','','',cGrpNum,'','S'})
			oX31:SetAlias("AK2")
			oX31:SetField("AK2_ENT" + cEntidNum)
			oX31:SetType("C")
			oX31:SetSize(TamSXG(cGrpNum)[1],0)
			oX31:SetPicture("@!")
			oX31:SetTitle("Entidade " + cEntidNum)
			oX31:SetTitleSpa("Ente " + cEntidNum)
			oX31:SetTitleEng("Entity " + cEntidNum)			
			oX31:cDescri    := 'Entidade ' + cEntidNum
			oX31:cDescriSpa := 'Ente ' + cEntidNum
			oX31:cDescriEng := 'Entity ' + cEntidNum
			oX31:SetValid('Vazio() .Or. CTB105EntC(,M->AK2_ENT'+cEntidNum+',,"'+cEntidNum+'")')
			oX31:SetF3( cF3 )
			oX31:SetGroup( cGrpNum ) 
			oX31:SetLevel('1')
			oX31:SetUsed(cX3Usado )
			oX31:SetObrigat(FWConvRese(Chr(150) + Chr(192)) )		
			oX31:SetOverWrite(.T.)

			If oX31:VldData()
				oX31:CommitData()
			EndIf
			
			aPHelpPor := {"Informe Ent. Cont�bil " + cEntidNum}
			aPHelpSpa := {"Dile a Ent. Contabilidad " + cEntidNum}
			aPHelpEng := {"Inform Ent. accounting " + cEntidNum}
			PutHelp("PAK2_ENT"+cEntidNum,aPHelpPor,aPHelpEng,aPHelpSpa,.T.)

			//"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
			//Aadd(aSX3,{'AKC','00','AKC_ENT' + cEntidNum,'C',60,0,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'@!','PcoVldForm()',cX3Usado,'','CT0001',1,IIf(lInDB,FWConvRese(Chr(132) + Chr(128)),Chr(132) + Chr(128)),'','','S','S','A','R','N','','','','','','','','','','S'})
			oX31:SetAlias("AKC")
			oX31:SetField("AKC_ENT" + cEntidNum)
			oX31:SetType("C")
			oX31:SetSize(60,0)
			oX31:SetPicture("@!")
			oX31:SetTitle("Entidade " + cEntidNum)
			oX31:SetTitleSpa("Ente " + cEntidNum)
			oX31:SetTitleEng("Entity " + cEntidNum)
			oX31:cDescri    := 'Entidade ' + cEntidNum
			oX31:cDescriSpa := 'Ente ' + cEntidNum
			oX31:cDescriEng := 'Entity ' + cEntidNum
			oX31:SetValid('PcoVldForm()')
			oX31:SetF3( 'CT0001' )
			oX31:SetGroup( cGrpNum ) 
			oX31:SetLevel('1')
			oX31:SetUsed(cX3Usado )
			oX31:SetObrigat(FWConvRese(Chr(132) + Chr(128)) )		
			oX31:SetOverWrite(.T.)

			If oX31:VldData()
				oX31:CommitData()
			EndIf
			
			aPHelpPor := {"Informe Ent. Cont�bil " + cEntidNum}
			aPHelpSpa := {"Dile a Ent. Contabilidad " + cEntidNum}
			aPHelpEng := {"Inform Ent. accounting " + cEntidNum}
			PutHelp("PAKC_ENT"+cEntidNum,aPHelpPor,aPHelpEng,aPHelpSpa,.T.)

			//"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
			//Aadd(aSX3,{'AKD','00','AKD_ENT' + cEntidNum,'C',TamSXG(cGrpNum)[1],0,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'@!','Vazio() .Or. CTB105EntC(,M->AKD_ENT'+cEntidNum+',,"'+cEntidNum+'")',cX3Usado,'',cF3,1,IIf(lInDB,FWConvRese(Chr(150) + Chr(192)),Chr(150) + Chr(192)),'','','S','S','A','R','N','','','','','','','',cGrpNum,'','S'})
			oX31:SetAlias("AKD")
			oX31:SetField("AKD_ENT" + cEntidNum)
			oX31:SetType("C")
			oX31:SetSize(TamSXG(cGrpNum)[1],0)
			oX31:SetPicture("@!")
			oX31:SetTitle("Entidade " + cEntidNum)
			oX31:SetTitleSpa("Ente " + cEntidNum)
			oX31:SetTitleEng("Entity " + cEntidNum)
			oX31:cDescri    := 'Entidade ' + cEntidNum
			oX31:cDescriSpa := 'Ente ' + cEntidNum
			oX31:cDescriEng := 'Entity ' + cEntidNum
			oX31:SetValid( 'Vazio() .Or. CTB105EntC(,M->AKD_ENT'+cEntidNum+',,"'+cEntidNum+'")' )
			oX31:SetF3( cF3 )
			oX31:SetGroup( cGrpNum ) 
			oX31:SetLevel('1')
			oX31:SetUsed(cX3Usado )
			oX31:SetObrigat( FWConvRese(Chr(150) + Chr(192)) )		
			oX31:SetOverWrite(.T.)

			If oX31:VldData()
				oX31:CommitData()
			EndIf

			aPHelpPor := {"Informe Ent. Cont�bil " + cEntidNum}
			aPHelpSpa := {"Dile a Ent. Contabilidad " + cEntidNum}
			aPHelpEng := {"Inform Ent. accounting " + cEntidNum}
			PutHelp("PAKD_ENT"+cEntidNum,aPHelpPor,aPHelpEng,aPHelpSpa,.T.)

			//"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
			//Aadd(aSX3,{'ALJ','00','ALJ_ENT' + cEntidNum,'C',TamSXG(cGrpNum)[1],0,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'@!','Vazio() .Or. CTB105EntC(,M->ALJ_ENT'+cEntidNum+',,"'+cEntidNum+'")',cX3Usado,'',cF3,1,IIf(lInDB,FWConvRese(Chr(150) + Chr(192)),Chr(150) + Chr(192)),'','','S','S','A','R','N','','','','','','','',cGrpNum,'','S'})

			oX31:SetAlias("ALJ")
			oX31:SetField("ALJ_ENT" + cEntidNum)
			oX31:SetType("C")
			oX31:SetSize(TamSXG(cGrpNum)[1],0)
			oX31:SetPicture("@!")
			oX31:SetTitle("Entidade " + cEntidNum)
			oX31:SetTitleSpa("Ente " + cEntidNum)
			oX31:SetTitleEng("Entity " + cEntidNum)	
			oX31:cDescri    := 'Entidade ' + cEntidNum
			oX31:cDescriSpa := 'Ente ' + cEntidNum
			oX31:cDescriEng := 'Entity ' + cEntidNum		
			oX31:SetValid('Vazio() .Or. CTB105EntC(,M->ALJ_ENT'+cEntidNum+',,"'+cEntidNum+'")')
			oX31:SetF3( cF3 )
			oX31:SetGroup( cGrpNum ) 
			oX31:SetLevel('1')
			oX31:SetUsed(cX3Usado )
			oX31:SetObrigat( FWConvRese(Chr(150) + Chr(192)) )		
			oX31:SetOverWrite(.T.)

			If oX31:VldData()
				oX31:CommitData()
			EndIf
		
			aPHelpPor := {"Informe Ent. Cont�bil " + cEntidNum}
			aPHelpSpa := {"Dile a Ent. Contabilidad " + cEntidNum}
			aPHelpEng := {"Inform Ent. accounting " + cEntidNum}
			PutHelp("PALJ_ENT"+cEntidNum,aPHelpPor,aPHelpEng,aPHelpSpa,.T.)

			//"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
			//Aadd(aSX3,{'AMJ','00','AMJ_ENT' + cEntidNum,'C',TamSXG(cGrpNum)[1],0,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'@!','Vazio() .Or. CTB105EntC(,M->AMJ_ENT'+cEntidNum+',,"'+cEntidNum+'")',cX3Usado,'',cF3,1,IIf(lInDB,FWConvRese(Chr(150) + Chr(192)),Chr(150) + Chr(192)),'','','S','S','A','R','N','','','','','','','',cGrpNum,'','S'})
			oX31:SetAlias("AMJ")
			oX31:SetField("AMJ_ENT" + cEntidNum)
			oX31:SetType("C")
			oX31:SetSize(TamSXG(cGrpNum)[1],0)
			oX31:SetPicture("@!")
			oX31:SetTitle("Entidade " + cEntidNum)
			oX31:SetTitleSpa("Ente " + cEntidNum)
			oX31:SetTitleEng("Entity " + cEntidNum)
			oX31:cDescri    := 'Entidade ' + cEntidNum
			oX31:cDescriSpa := 'Ente ' + cEntidNum
			oX31:cDescriEng := 'Entity ' + cEntidNum
			oX31:SetValid( 'Vazio() .Or. CTB105EntC(,M->AMJ_ENT'+cEntidNum+',,"'+cEntidNum+'")' )
			oX31:SetF3( cF3 )
			oX31:SetGroup( cGrpNum ) 
			oX31:SetLevel('1')
			oX31:SetUsed(cX3Usado )
			oX31:SetObrigat( FWConvRese(Chr(150) + Chr(192)) )		
			oX31:SetOverWrite(.T.)

			If oX31:VldData()
				oX31:CommitData()
			EndIf
			
			aPHelpPor := {"Informe Ent. Cont�bil " + cEntidNum}
			aPHelpSpa := {"Dile a Ent. Contabilidad " + cEntidNum}
			aPHelpEng := {"Inform Ent. accounting " + cEntidNum}
			PutHelp("PAMJ_ENT"+cEntidNum,aPHelpPor,aPHelpEng,aPHelpSpa,.T.)

			//"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
			//Aadd(aSX3,{'AMK','00','AMK_ENT' + cEntidNum,'C',60,0,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'@!','PcoVldForm()',cX3Usado,'','CT0001',1,IIf(lInDB,FWConvRese(Chr(132) + Chr(128)),Chr(132) + Chr(128)),'','','S','S','A','R','N','','','','','','','','','','S'})
			oX31:SetAlias("AMK")
			oX31:SetField("AMK_ENT" + cEntidNum)
			oX31:SetType("C")
			oX31:SetSize(60,0)
			oX31:SetPicture("@!")
			oX31:SetTitle("Entidade " + cEntidNum)
			oX31:SetTitleSpa("Ente " + cEntidNum)
			oX31:SetTitleEng("Entity " + cEntidNum)
			oX31:cDescri    := 'Entidade ' + cEntidNum
			oX31:cDescriSpa := 'Ente ' + cEntidNum
			oX31:cDescriEng := 'Entity ' + cEntidNum
			oX31:SetValid('PcoVldForm()')
			oX31:SetF3('CT0001')
			oX31:SetLevel('1')
			oX31:SetUsed(cX3Usado )
			oX31:SetObrigat( FWConvRese(Chr(132) + Chr(128)) )		
			oX31:SetOverWrite(.T.)

			If oX31:VldData()
				oX31:CommitData()
			EndIf

			aPHelpPor := {"Informe Ent. Cont�bil " + cEntidNum}
			aPHelpSpa := {"Dile a Ent. Contabilidad " + cEntidNum}
			aPHelpEng := {"Inform Ent. accounting " + cEntidNum}
			PutHelp("PAMK_ENT"+cEntidNum,aPHelpPor,aPHelpEng,aPHelpSpa,.T.)

			//"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
			//Aadd(aSX3,{'AKI','00','AKI_ENT' + cEntidNum,'C',60,0,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'@!','PcoVldForm()',cX3Usado,'','CT0001',1,IIf(lInDB,FWConvRese(Chr(134) + Chr(128)),Chr(134) + Chr(128)),'','','S','S','A','R','N','','','','','','','','','','S'})
			oX31:SetAlias("AKI")
			oX31:SetField('AKI_ENT' + cEntidNum)
			oX31:SetType("C")
			oX31:SetSize(60,0)
			oX31:SetPicture("@!")
			oX31:SetTitle("Entidade " + cEntidNum)
			oX31:SetTitleSpa("Ente " + cEntidNum)
			oX31:SetTitleEng("Entity " + cEntidNum)
			oX31:cDescri    := 'Entidade ' + cEntidNum
			oX31:cDescriSpa := 'Ente ' + cEntidNum
			oX31:cDescriEng := 'Entity ' + cEntidNum
			oX31:SetValid('PcoVldForm()')
			oX31:SetF3('CT0001')
			oX31:SetLevel('1') 
			oX31:SetUsed(cX3Usado )
			oX31:SetObrigat( FWConvRese(Chr(134) + Chr(128)) )		
			oX31:SetOverWrite(.T.)

			If oX31:VldData()
				oX31:CommitData()
			EndIf
			
			aPHelpPor := {"Informe Ent. Cont�bil " + cEntidNum}
			aPHelpSpa := {"Dile a Ent. Contabilidad " + cEntidNum}
			aPHelpEng := {"Inform Ent. accounting " + cEntidNum}
			PutHelp("PAKI_ENT"+cEntidNum,aPHelpPor,aPHelpEng,aPHelpSpa,.T.)

			//"X3_ARQUIVO"	,"X3_ORDEM"	,"X3_CAMPO"					,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"				,"X3_TITSPA"				,"X3_TITENG"				, "X3_DESCRIC"							,"X3_DESCSPA"						,"X3_DESCENG"						,"X3_PICTURE"	,"X3_VALID"			,"X3_USADO"			,"X3_RELACAO"	,"X3_F3"	,"X3_NIVEL"	, "X3_RESERV"	,"X3_CHECK"	,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,"X3_CONTEXT"	,"X3_OBRIGAT"	,"X3_VLDUSER"	, "X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,"X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	
			//Aadd(aSX3,{'AMZ','00','AMZ_ENT' + cEntidNum,'C',TamSXG(cGrpNum)[1],0,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'Entidade ' + cEntidNum,'Ente ' + cEntidNum,'Entity ' + cEntidNum,'@!','Vazio() .Or. CTB105EntC(,M->AMZ_ENT'+cEntidNum+',,"'+cEntidNum+'")',cX3Usado,'',cF3,1,IIf(lInDB,FWConvRese(Chr(254) + Chr(192)),Chr(254) + Chr(192)),'','','S','S','A','R','N','','','','','','','',cGrpNum,'','S'})
			oX31:SetAlias("AMZ")
			oX31:SetField('AMZ_ENT' + cEntidNum)
			oX31:SetType("C")
			oX31:SetSize(TamSXG(cGrpNum)[1],0)
			oX31:SetPicture("@!")
			oX31:SetTitle("Entidade " + cEntidNum)
			oX31:SetTitleSpa("Ente " + cEntidNum)
			oX31:SetTitleEng("Entity " + cEntidNum)
			oX31:cDescri    := 'Entidade ' + cEntidNum
			oX31:cDescriSpa := 'Ente ' + cEntidNum
			oX31:cDescriEng := 'Entity ' + cEntidNum
			oX31:SetValid( 'Vazio() .Or. CTB105EntC(,M->AMZ_ENT'+cEntidNum+',,"'+cEntidNum+'")' )
			oX31:SetF3(cF3)
			oX31:SetGroup( cGrpNum ) 
			oX31:SetLevel('1') 
			oX31:SetUsed(cX3Usado )
			oX31:SetObrigat( FWConvRese(Chr(254) + Chr(192)) )		
			oX31:SetOverWrite(.T.)

			If oX31:VldData()
				oX31:CommitData()
			EndIf
			
			aPHelpPor := {"Informe Ent. Cont�bil " + cEntidNum}
			aPHelpSpa := {"Dile a Ent. Contabilidad " + cEntidNum}
			aPHelpEng := {"Inform Ent. accounting " + cEntidNum}
			PutHelp("PAMZ_ENT"+cEntidNum,aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		EndIf

	Next nX

	aSixInd := ENTAtuSIX()

	If Len(aSixInd) > 0
		oX31Ind := oX31:oIndex

		For nInd := 1 TO Len(aSixInd[1])
			/*
			oX31Ind:SetAlias('SA1')
			oX31Ind:SetOrder('F')
			oX31Ind:SetChave('A1_FILIAL+A1_MUN')
			oX31Ind:SetTitle('MUN TESTE')
			oX31Ind:SetTitleEng('MUN TESTE')
			oX31Ind:SetTitleSpa('MUN TESTE')
			oX31Ind:SetPropri("S")
			oX31Ind:SetOverWrite(.T.)
			If oX31Ind:VldData()
				oX31Ind:CommitData()
			EndIf*/
			//aSixInd := {"INDICE","ORDEM","CHAVE","DESCRICAO","DESCSPA","DESCENG","PROPRI","F3","NICKNAME","SHOWPESQ"}
			oX31Ind:SetAlias(aSixInd[1][nInd][1])
			oX31Ind:SetOrder(aSixInd[1][nInd][2])
			oX31Ind:SetChave(aSixInd[1][nInd][3])
			oX31Ind:SetTitle(aSixInd[1][nInd][4])
			oX31Ind:SetTitleSpa(aSixInd[1][nInd][5])
			oX31Ind:SetTitleEng(aSixInd[1][nInd][6])
			oX31Ind:SetPropri("S")   //posicao 7 desnecessario por se tratar produto padrao
			
			
			
			If !Empty(aSixInd[1][nInd][9])
				oX31Ind:SetNickName(aSixInd[1][nInd][9])
			EndIf
			If !Empty(aSixInd[1][nInd][10])
				oX31Ind:SetPesq(aSixInd[1][nInd][10])
			EndIf
			oX31Ind:SetOverWrite(.T.)

			If oX31:VldData()        //quando se esta utilizando oIndex do MPX31Field():New()
				oX31:CommitData()    //utilizar commit do proprio MPX31Field():New()
			EndIf
		Next

	EndIf
	

	cTexto := ""


	cCodPrj:=oX31:oPrjResult:cCodProj
	FWGnFlByTp(cCodPrj,cPath) 

	If File(cPath+"\sdfbra.txt")
		cTexto += STR0095+CRLF  //"Arquivo SDF exportado com sucesso para a pasta systemload."
		cTexto += CRLF
		cTexto += STR0096+CRLF  //"Ao finalizar o Assistente de cria��o de Entidades, os proximo passos:"+CRLF
		cTexto += CRLF
		cTexto += STR0097+CRLF  //"-Criar Entidades no cadastro (CT0)...Este processo pode demorar alguns minutos..."+CRLF 
		cTexto += CRLF
		cTexto += STR0098+CRLF //"-Executar a fun��o UPDDISTR para atualiza��o do dicionario de dados!"+CRLF 
		cTexto += CRLF
		cTexto += STR0099+CRLF //"...Este processo pode demorar - Aguarde ..."+CRLF 
		cTexto += CRLF
		cTexto += CRLF
		cTexto += STR0100+CRLF //"Pressione o bot�o Finalizar para concluir o processamento!"+CRLF 
		lCriouSDF := .T.
	EndIf
EndIf
RestArea(aAreaSX3)
RestArea(aArea)
Return cTexto

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENTAtuSIX �Autor  �Microsiga           � Data �  02/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de processamento da gravacao do SIX                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ENTAtuSIX()
Local cTexto  := ''
Local lSIX    := .F.
Local lNew    := .F.
Local aSIX    := {}
Local aEstrut := {}
Local i       := 0
Local cAlias  := ''
Local aColsGet	:= ACLONE(oGetDados:aCols)
Local aHeader	:= ACLONE(oGetDados:aHeader)
Local nPosPlano	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CT0_ID"})
Local cEntidNum	:= ""
Local nX		:= 0
Local aSixAux   := {}
Local aRetSix   := {}

aEstrut := {"INDICE","ORDEM","CHAVE","DESCRICAO","DESCSPA","DESCENG","PROPRI","F3","NICKNAME","SHOWPESQ"}

// Indice

If FindFunction("CtbSIXCTA") .And. CtbSIXCTA() //Se as existentes j� tem indice, adiciona as demais, sen�o precisa rodar UPD
	For nX := 1 To Len(aColsGet)
		cEntidNum	:= AllTrim(aColsGet[nX][nPosPlano]) //Numero corrente da entidade
		Aadd(aSIX,{"CTA",Soma1(AllTrim(STR(VAL(cEntidNum)))),"CTA_FILIAL+CTA_ENTI"+cEntidNum,"Entidade "+cEntidNum,"Entidad "+cEntidNum,"Entity "+cEntidNum,'S',"","CTA_ENTI"+cEntidNum,'S'})
	Next nX
EndIf

ProcRegua(Len(aSIX))

dbSelectArea("SIX")
dbSetOrder(1)

For i:= 1 To Len(aSIX)
	If !Empty(aSIX[i,1])
		If !dbSeek(aSIX[i,1]+aSIX[i,2])
			lNew:= .T.
		Else
			lNew:= .F.
		EndIf
		cChvIndNick := ""
		If lNew
			aAdd(aSixAux, { lNew, "*"} )
		Else
			If !(UPPER(AllTrim(CHAVE))==UPPER(Alltrim(aSIX[i,3])))
				cChvIndNick += "CHAVE"
			EndIf
			If !(UPPER(AllTrim(CHAVE))==UPPER(Alltrim(aSIX[i,3])))
				cChvIndNick += "NICKNAMe"
			EndIf
			aAdd(aSixAux, { lNew, cChvIndNick } )
		EndIf
		
		IncProc(STR0029) //"Atualizando Indices..."

	EndIf
Next i

If lSIX
	cTexto += STR0049+cAlias+CRLF //"Indices atualizados  : "
EndIf

If Len(aSix) > 0
	aRetSix := {aClone(aSix),aClone(aSixAux)}
EndIf

Return aRetSix //cTexto

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENTAtuCT0 �Autor  �Microsiga           � Data �  02/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao  de processamento da gravacao da Entidade           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ENTAtuCT0(oProcess)
Local aColsGet  := ACLONE(oGetDados:aCols)
Local cTexto 	:= ''
Local aSaveArea := GetArea()
Local nCont	:= 0
Local lEnte05 := if(cPaisLoc == "PER" .AND. nEntidIni == 5,.T.,.F. )  //localizado .T.

dbSelectArea("CV0")
dbSetOrder(1)//CV0_FILIAL+CV0_PLANO+CV0_CODIGO

dbSelectArea("CT0")
dbSetOrder(1)// CT0_FILIAL+CT0_ID

oProcess:SetRegua1( Len( aColsGet ) )

For nCont := 1 To Len(aColsGet)
	If !dbSeek(xFilial("CT0")+aColsGet[nCont][1]) .OR. (lEnte05 .AND. dbSeek(xFilial("CT0")+aColsGet[nCont][1]) ) //lEnte05 => localizado
		dbSelectArea("CV0")
		If !Empty(aColsGet[nCont][11]) .And. !dbSeek(xFilial("CV0")+aColsGet[nCont][11]) .OR. lEnte05
			if lEnte05  //localizado
				if dbSeek(xFilial("CV0")+"01")
					RecLock("CV0", .F.)
						CV0->CV0_PLANO  := aColsGet[nCont][11]
					MsUnlock("CV0")
				Endif
			Else
			RecLock("CV0", .T.)
			CV0->CV0_FILIAL := xFilial("CV0")
			CV0->CV0_PLANO  := aColsGet[nCont][11]
			CV0->CV0_DESC 	:= aColsGet[nCont][12]
			CV0->CV0_DTIBLQ := Ctod("")
			CV0->CV0_DTFBLQ := dDatabase
			CV0->CV0_DTIEXI := Ctod("")
			CV0->CV0_DTFEXI := Ctod("")
			MsUnlock("CV0")
			Endif
		EndIf
		dbSelectArea("CT0")
		if lEnte05  //localizado
			RecLock("CT0", .F.)
				CT0->CT0_ENTIDA := aColsGet[nCont][11]
			MsUnlock("CT0")		
		Else
			RecLock("CT0",.T.)
				CT0->CT0_FILIAL := xFilial("CT0")
				CT0->CT0_ID	:= aColsGet[nCont][1]
				CT0->CT0_DESC   := aColsGet[nCont][2]
				CT0->CT0_DSCRES := aColsGet[nCont][3]
				CT0->CT0_CONTR  := aColsGet[nCont][4]
				CT0->CT0_ALIAS  := aColsGet[nCont][5]
				CT0->CT0_CPOCHV := aColsGet[nCont][6]
				CT0->CT0_CPODSC := aColsGet[nCont][7]
				CT0->CT0_ENTIDA := aColsGet[nCont][11]
				CT0->CT0_OBRIGA := "2"
				CT0->CT0_CPOSUP := aColsGet[nCont][8]
				CT0->CT0_GRPSXG := aColsGet[nCont][9]
				CT0->CT0_F3ENTI := aColsGet[nCont][10]
				MsUnlock("CT0")
		Endif
		dbSelectArea("CT0")
	EndIf
	oProcess:IncRegua1( STR0011 + cEmpAnt + "/"+ STR0012 + cFilAnt + STR0030+": " +aColsGet[nCont][2])  //"Empresa : "###"Filial : "
	Sleep(500)
Next

RestArea(aSaveArea)
Return cTexto

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENTGetNum  �Autor  �Microsiga           � Data �  02/11/10  ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta gets para informa��o do n�mero, entidade inicial e   ���
���          � m�dulos para gera��o.                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EntGetNum()
Local oPanel	:= Nil
Local nMaxEnt	:= GETMAXENT()
Local oSayQtdEnt, oGetQtdEnt, oSayEntIni, oGetEntIni, oCheckRef, oCheckCTB, oCheckATF, oCheckCOM,;
      oCheckEST, oCheckFAT, oCheckFIN, oCheckGCT, oCheckPCO,oCheckVGE

If lMaxEnt
	lChkRefaz := .T.
	nQtdEntid := 0
	nEntidIni := 0
EndIf

If nEntidIni == 5
	lChkRefaz := .F.
EndIf


//------------------------------------------------------------
// Campos para definicao da quantidade de entidades e modulos
//------------------------------------------------------------
oPanel   := oWizard:oMPanel[oWizard:nPanel]

oSayQtdEnt	:= TSay():New(005,008,{||STR0017},oPanel,,,,,,.T.,,,,,,,,,,) //"Total de Entidades a serem criadas:"
oGetQtdEnt	:= TGet():New(015,008,{|u| If(PCount() > 0,nQtdEntid := u,nQtdEntid)},oPanel,015,009,'@e 99',{|| ENTVldNum(nQtdEntid,nMaxEnt) }	,,,,,,.T.,,,{||!lMaxEnt},,,,,.F.,,"nQtdEntid",,,,,,,,,)

oSayEntIni	:= TSay():New(035,008,{||STR0018},oPanel,,,,,,.T.,,,,,,,,,,) //"Numera��o da primeira entidade a ser criada:"
oGetEntIni	:= TGet():New(045,008,{|u| If(PCount() > 0,nEntidIni := u,nEntidIni)},oPanel,015,009,'@ 99',{|| .T. },,,,,,.T.,,,{||.F.},,,,.F.,.F.,,"nEntidIni",,,,,,,,,)
oCheckRef	:= TCheckBox():New(065,008,STR0066,bSETGET(lChkRefaz)	,oPanel,150,009,,,,,,,,.T.,,,{||!lMaxEnt}) //"Cria campo para entidades j� existentes"

oSayRefaz	:= TSay():New(080,009,{||STR0019},oPanel,,,,,,.T.,,,,,,,,,,) //"Definir os m�dulos para cria��o:"
oCheckCTB   := TCheckBox():New(090,008,STR0043,bSETGET(lChkCTB)		,oPanel,050,009,,,,,,,,.T.,,,{|| .F. })	   //"Contabilidade"
oCheckATF	:= TCheckBox():New(100,008,STR0041,bSETGET(lChkATF)		,oPanel,050,009,,,,,,,,.T.,,,) //"Ativo Fixo"
oCheckCOM	:= TCheckBox():New(110,008,STR0042,bSETGET(lChkCOM)		,oPanel,050,009,,,,,,,,.T.,,,) //"Compras"
oCheckEST	:= TCheckBox():New(120,008,STR0044,bSETGET(lChkEST)		,oPanel,050,009,,,,,,,,.T.,,,) //"Estoque"
oCheckFAT	:= TCheckBox():New(130,008,STR0045,bSETGET(lChkFAT)		,oPanel,050,009,,,,,,,,.T.,,,) //"Faturamento"
oCheckFIN	:= TCheckBox():New(090,108,STR0046,bSETGET(lChkFIN)		,oPanel,050,009,,,,,,,,.T.,,,) //"Financeiro"
oCheckGCT	:= TCheckBox():New(100,108,STR0080,bSETGET(lChkGCT)		,oPanel,100,009,,,,,,,,.T.,,,) //"Gest�o de Contratos"
oCheckPCO	:= TCheckBox():New(110,108,STR0081,bSETGET(lChkPCO)		,oPanel,100,009,,,,,,,,.T.,,,) //"Controle Or�ament�rio"
oCheckVGE	:= TCheckBox():New(120,108,STR0084,bSETGET(lChkVGE)		,oPanel,100,009,,,,,,,,.T.,,,) //"Viagens"

If lMaxEnt
	oCheckRef:bWhen  := {|| .F. }
	oGetQtdEnt:bWhen := {|| .F. }
	oGetEntIni:bWhen  := {|| .F. }
EndIf

If nEntidIni == 5
	oCheckRef:bWhen  := {|| .F. }
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENTGetDesc �Autor  �Microsiga          � Data �  02/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Monta grid para informa��o das descri��es das entidades   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EntGetDesc()
Local nContItem := 1
Local oPanel 	:= oWizard:oMPanel[oWizard:nPanel]
Local nEntNew   := nEntidIni
Local cLinOk	:= "CT910LOk()"

//��������������������������������������������������������������Ŀ
//� Monta grid para informativo das descri��es por entidade      �
//����������������������������������������������������������������
Local aHeader 	:= {}
Local aCols 	:= {}

//��������������������������������������������������������������Ŀ
//� Cria aHeader e aCols da GetDados                             �
//����������������������������������������������������������������
//				cTitulo	,cCampo			,cPicture	,nTamanho	,nDecimais	,cValida��o										,cUsado	,cTipo	,cF3		,cCntxt	,cCBox								,cRelacao
Aadd(aHeader,{	STR0030	,"CT0_ID"		,"!!"		,02			,0			,".F."											,"�"	,"C"	," "		,"R"	,""									,""		}) //Item
Aadd(aHeader,{	STR0031	,"CT0_DESC"		,"@!"		,30			,0			,"NaoVazio()"									,"�"	,"C"	," "		,"R"	,""									,""     }) //Descri��o
Aadd(aHeader,{	STR0052	,"CT0_DSCRES"	,"@!"		,10			,0			,"NaoVazio()"									,"�"	,"C"	," "		,"R"	,""									,""     }) //Descricao Resumida
Aadd(aHeader,{	STR0032	,"CT0_CONTR"	,"@!"		,1			,0			,"NaoVazio().And. Pertence('12')"				,"�"	,"C"	," "		,"R"	,""									,""     }) //Controla
Aadd(aHeader,{	STR0053	,"CT0_ALIAS"	,"@!"		,3			,0			,"NaoVazio().And. ValidX2Alias(M->CT0_ALIAS)"	,"�"	,"C"	," "		,"R"	,""									,""     }) //Alias
Aadd(aHeader,{	STR0054	,"CT0_CPOCHV"	,"@!"		,10			,0			,"NaoVazio().And. ValidX3Cpo(M->CT0_CPOCHV)"	,"�"	,"C"	,"CT0SX3"	,"R"	,""									,""     }) //Campo Chave
Aadd(aHeader,{	STR0055	,"CT0_CPODSC"	,"@!"		,10			,0			,"NaoVazio().And. ValidX3Cpo(M->CT0_CPODSC)"	,"�"	,"C"	,"CT0SX3"	,"R"	,""									,""     }) //Desc. Campo
Aadd(aHeader,{	STR0059	,"CT0_CPOSUP"	,"@!"		,10			,0			,"Vazio() .Or. ValidX3Cpo(M->CT0_CPOSUP)"		,"�"	,"C"	,"CT0SX3"	,"R"	,""									,""     }) //Cpo.Ent.Sup.
Aadd(aHeader,{	STR0060	,"CT0_GRPSXG"	,"@!"		,3			,0			,"Vazio() .Or. ValidSXG(M->CT0_GRPSXG)"			,"�"	,"C"	," "		,"R"	,IIF(!lChkRefaz,AdmCBGrupo(),"")	,""     }) //Grp.Campos
Aadd(aHeader,{	STR0061	,"CT0_F3ENTI"	,"@!"		,6			,0			,"Vazio() .Or. ValidSXB(M->CT0_F3ENTI)"			,"�"	,"C"	," "		,"R"	,IIF(!lChkRefaz,AdmCBCPad(),"")		,""     }) //Cons. Padrao
Aadd(aHeader,{	STR0062	,"CT0_ENTIDA"	,"@!"		,2			,0			,".F."											,"�"	,"C"	," "		,"R"	,""									,""     }) //Plano
Aadd(aHeader,{	STR0063	,"CV0_DESC"		,"@!"		,30			,0			,""												,"�"	,"C"	," "		,"R"	,""									,""     }) //Desc. Plano

If lChkRefaz
	aCols := CT910RACol(aHeader)
Else
	For nContItem := 1 to nQtdEntid
		Do Case //obten��o do nro do grupo
			Case nEntNew == 5  //Entidade 05
				cGrpNum := "040"
			Case nEntNew == 6  //Entidade 06
				cGrpNum := "042"
			Case nEntNew == 7  //Entidade 07
				cGrpNum := "043"
			Case nEntNew == 8  //Entidade 08
				cGrpNum := "044"
			Case nEntNew == 9  //Entidade 09
				cGrpNum := "045"
		EndCase
		aAdd(aCols,{StrZero(nEntNew,2,0), Space(TamSx3("CT0_DESC")[1]), Space(10), "1", "CV0", PADR("CV0_CODIGO",TamSx3("CT0_CPOCHV")[1]), PADR("CV0_DESC",TamSx3("CT0_CPODSC")[1]), PADR("CV0_ENTSUP",TamSx3("CT0_CPOSUP")[1]), cGrpNum, "CV0   ", StrZero(nEntNew,2,0), Upper(STR0062)+" "+StrZero(nEntNew,2,0), .F.}) //Plano
		nEntNew ++
	Next nContItem
EndIf

If lChkRefaz
	nOpcX := 0
Else
	nOpcX := GD_UPDATE
EndIf

//           MsNewGetDados():New(nSuperior	,nEsquerda	,nInferior	,nDireita	,nOpc	,cLinOk	,cTudoOk	,cIniCpos	,aAlterGDa					,nFreeze	,nMax	,cFieldOk	,cSuperDel	,cDelOk	,oDLG	,aHeader	,aCols)
oGetDados := MsNewGetDados():New(005		,008		,105		,255		,nOpcX	,cLinOk	,			,			,{"CT0_DESC","CT0_DSCRES"}	,			,5		,			,			,		,oPanel	,aHeader	,aCols)
oGetDados:SetEditLine(.F.)
SX3->(dbCloseArea())

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENTWIZREGU  �Autor  �Microsiga         � Data �  02/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Realiza o controle do obejto process da rotina             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ENTWIZREGU
Private oProcess
// Executa o processamento dos arquivos
dbSelectArea("SX2")
dbCloseArea()
dbSelectArea("SIX")
dbCloseArea()
dbSelectArea("SX3")
dbCloseArea()
oProcess:=	MsNewProcess():New( {|lEnd| ENTWIZPROC(oProcess) } )
oProcess:Activate()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GETMAXENT  �Autor  �Microsiga           � Data �  02/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna a partir de qual Entidade poder� ser realizada a   ���
���          � criacao                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GETMAXENT()
Local nEntidIni := 0
Local nEntidMax := 0
Local aAreaSX2 	:= {}
Local lExistCpo := .T.

aAreaSX2 := SX2->(GetArea())

dbSelectArea("SX2")
dbSetOrder(1)
If !MsSeek("CT0")
	RestArea(aAreaSX2)
	MsgInfo(STR0057+" CT0 "+STR0058,STR0001) //"Tabela"###"n�o encontrada"###"Aten��o"
	Return(nEntidMax)
EndIf

DbSelectArea("CT0")
If !Empty(Select("CT0"))
	lOpen := .T.
EndIf

If !lOpen
	MsgInfo(STR0050,STR0001) //"Nao foi possivel a abertura da tabela de empresas de forma exclusiva!"###"Atencao!"
Else
	DbSelectArea("CT0")
	DbSetOrder(1)
	DbSeek(xFilial()+"01")
	While CT0->(!EOF())
		lExistCpo := .T.
		IF Val(CT0->CT0_ID) > 0

			If cPaisLoc $ "PER|COL" .and. Val(CT0->CT0_ID) >= 5 // Peru e Col�mbia possuem a quinta entidade em base padr�o (N.I.T.)
				lExistCpo := CtbEntIniVar(CT0->CT0_ID)
			EndIf
			nEntidIni := Val(CT0->CT0_ID)
			If nEntidIni > nEntidMax .and. IIF(cPaisLoc $ "PER|COL",lExistCpo, .T.)
				nEntidMax := nEntidIni
			EndIf
		Else
			Exit
		EndIf

		CT0->(DbSkip())
	EndDo

	If nEntidMax == 0
		MsgInfo(STR0036,STR0001) //"Nao foi possivel determinar a quantidade de entidades
	Else                         //parametrizadas no sistema!"###"Atencao!"
		nEntidMax++				 //N�mero da pr�xima entidade
	EndIf

Endif

RestArea(aAreaSX2)
Return nEntidMax
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENTVldNum �Autor  �Microsiga           � Data �  02/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao do numero de entidades a serem geradas ao sele-  ���
���          � cionar outro campo.                                        ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ENTVldNum(nNum, nEntidIni)
Local lRet := .T.
Local nEntidMax := 9 - (nEntidIni - 1)

If nNum > nEntidMax
	lRet := .F.
	MsgInfo(STR0038+AllTrim(Str(nEntidMax,0))+STR0039,STR0001) //'O n�mero m�ximo de entidades adicionais permitidas no momento � de: ' ### ' entidades. Ajuste o n�mero'###'Atencao'
ElseIf !Empty(nNum) .And. lChkRefaz
	lRet := .F.
	MSGINFO(STR0077,STR0021) //"A op��o refaz entidade n�o permite criar novas." ##"CTBWizard - Entidades"
ElseIf Empty(nNum) .And. !lChkRefaz
	lRet := .F.
	MsgInfo(STR0040,STR0001) //"� necess�rio informar pelo menos uma entidade!"###"Atencao"
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENTWZVLP2 �Autor  �Microsiga           � Data �  02/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao dos dados inicias para parametrizacao de Entida- ���
���          � des na mudan�a de tela (next)                              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ENTWZVLP2()

Local aArea := GetArea()
Local lRet	:= .T.
Local nEntidMax := 9 - (nEntidIni - 1)

If lChkRefaz .And. !Empty(nQtdEntid)
	lRet := .F.
	MSGINFO(STR0067,STR0021) // "A op��o refaz entidade n�o permite criar novas."##"CTBWizard - Entidades"
ElseIf nEntidIni > 9 .Or. nQtdEntid > nEntidMax
	lRet := .F.
	MSGINFO(STR0035+AllTrim(Str(9,0))+STR0037,STR0021) //"A parametriza��o excede o limite de 09 entidades
	//configur�veis no sistema!" # "CTBWizard - Entidades"
Else
	If !lChkATF .And. !lChkCOM .And. !lChkCTB .And. !lChkEST .And. !lChkFAT .And. !lChkFIN .And. !lChkGCT .And. !lChkRefaz .And. !lChkPCO .And. !lChkVGE
		lRet := .F.
		MSGINFO(STR0047,STR0001) //"� necess�rio selecionar pelo menos um m�dulo!"###"Aten��o!"
	EndIf
ENDIF

RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENTWZVLP3 �Autor  �Microsiga           � Data �  02/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao do grid de entidades a serem incluidas.          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ENTWIZUPD                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ENTWZVLP3()
Local lRet 		:= .T.
Local aColsGet	:= ACLONE(oGetDados:aCols)
Local nX		:= 0

For nX := 1 to Len(aColsGet)
	lRet := CT910LOk(nX)
	If !lRet
		Exit
	ENdIf
Next nX

IF lRet
	lRet := MSGYESNO(STR0020,STR0021) //Confirma a parametriza��o das novas entidades # CTBWizard - Entidades
ENDIF

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidX3Cpo   �Autor  �Microsiga        � Data �  05/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida a existencia do campo                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ValidX3Cpo(cCpo)
Local lRet      := .F.

If Empty(cCpo)
	lRet := .F.
	Help(" ",1,"NOMECPO")
Else
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek(cCpo)
	If !Found()
		Help(" ",1,"NOMECPO")
		lRet := .F.
	Else
		lRet := .T.
	EndIf
	dbSetOrder(1)
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidX2Alias  �Autor  �Microsiga       � Data �  05/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Valida a existencia do Alias                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ValidX2Alias(cAlias)
Local lRet := .T.

dbSelectArea("SX2")
Set Filter to
dbSeek(cAlias)
if !Found()
	Help(" ",1,"X7_ALIAS")
	lRet := .F.
endif

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidSXG      �Autor  �Marcelo Akama   � Data �  05/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Valida a existencia do grupo de campos                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ValidSXG(cGrupo)
Local lRet := .T.

DbSelectArea( "SXG" )
SXG->( DbSetOrder( 1 ) )
If !SXG->( DbSeek( cGrupo ) )
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidSXB      �Autor  �Marcelo Akama   � Data �  05/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Valida a existencia de consulta padrao                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ValidSXB(cCod)
Local lRet := .T.

DbSelectArea( "SXB" )
SXB->( DbSetOrder( 1 ) )
If !SXB->( DbSeek( cCod ) )
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AdmCBCPad     �Autor  �Marcelo Akama   � Data �  05/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Combo box de consulta padrao                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AdmCBCPad()
Local cCBox := ""
Local aArea := GetArea()

DbSelectArea("SXB")
DbSetOrder(1)
DbGoTop()
cCBox := Space(31)
Do While !Eof()
	If XB_TIPO == "1" .And. XB_ALIAS != "SX5"
		cCBox += ';'+XB_ALIAS+"="+OemToAnsi(Substr(XBDESCRI(),1,25))
	EndIf
	DbSkip()
EndDo
DbSelectArea("SX5")
DbGoTop()
Do While X5_TABELA == "00"
	cCBox += ';'+SubStr(X5_CHAVE,1,3)+"="+Capital(OemToAnsi(Substr(X5DESCRI(),1,25)))
	DbSkip()
EndDo

RestArea(aArea)

Return cCBox

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AdmCBGrupo    �Autor  �Marcelo Akama   � Data �  05/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Combo box de grupo de campos                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AdmCBGrupo()
Local cCBox := ""
Local aArea := GetArea()

DbSelectArea("SXG")
DbSetOrder(1)
DbGoTop()
cCBox := Space(31)
Do While !Eof()
	cCBox += ';'+XG_GRUPO+"="+OemToAnsi(Substr(XGDESCRI(),1,25))
	DbSkip()
EndDo

RestArea(aArea)

Return cCBox

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AdmAbreSM0� Autor � Orizio                � Data � 22/01/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna um array com as informacoes das filias das empresas ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AdmAbreSM0()
Local aArea			:= SM0->( GetArea() )
Local aAux			:= {}
Local aRetSM0		:= {}
Local lFWLoadSM0	:= FindFunction( "FWLoadSM0" )
Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )

If lFWLoadSM0
	aRetSM0	:= FWLoadSM0()
Else
	DbSelectArea( "SM0" )
	SM0->( DbGoTop() )
	While SM0->( !Eof() )
		aAux := { 	SM0->M0_CODIGO,;
		IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
		"",;
		"",;
		"",;
		SM0->M0_NOME,;
		SM0->M0_FILIAL }

		aAdd( aRetSM0, aClone( aAux ) )
		SM0->( DbSkip() )
	End
EndIf

RestArea( aArea )
Return aRetSM0


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CtbA910   �Autor  �Microsiga           � Data �  04/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CT910RACol(aHeader)
Local aCols  := {}
Local nX     := 0
Local aArea  := GetArea()
Local cAlias := ""
Local nCols  := 0
Local aPlano := {}

CT0->(dbSetOrder(1)) //CT0_FILIAL+CT0_ID
CV0->(dbSetOrder(1)) //CV0_FILIAL+CV0_PLANO+CV0_CODIGO

CV0->(dbGoTop())
While CV0->(!Eof())

	If aSCan(aPlano,{|cPlano| Alltrim(cPlano) == CV0->CV0_PLANO }) <= 0
		aAdd(aPlano,CV0->CV0_PLANO)
	Else
		CV0->(dbSkip())
		Loop
	EndIf

	If CT0->(MsSeek( xFilial("CT0") + CV0->CV0_PLANO ))
		aAdd(aCols,Array(Len(aHeader)+1))
		nCols ++
		For nX := 1 To Len(aHeader)

			If "CT0" $ aHeader[nX][02]
				cAlias := "CT0"
			Else
				cAlias := "CV0"
			EndIf

			If ( aHeader[nX][10] != "V")
				aCols[nCols][nX] := (cAlias)->(FieldGet(FieldPos(aHeader[nX][2])))
			ElseIf (aHeader[nX][8] == "M") // Campo Memo
				aCols[nCols][nX] := MSMM((cAlias)->(&(cCPOMemo)), TamSX3(cMemo)[1] )
			Else
				aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
			Endif

		Next nX
		aCols[nCols][Len(aHeader)+1] := .F.
	EndIf
	CV0->(dbSkip())
EndDo

RestArea(aArea)
Return aCols

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CT910LOk   �Autor  �Microsiga           � Data �  04/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida��o LinOk da rotina                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CT910LOk(nLinha)
Local lRet      := .T.
Local aCols     := oGetDados:aCols
Local aHeader   := oGetDados:aHeader
Local nPosAlias := Ascan(aHeader,{|x|Alltrim(x[2]) == "CT0_ALIAS"})
Local aPos		:= {}

Local nY        := 0
Local lEnte05   := .F.   

Default nLinha := oGetDados:nAt

If cPaisLoc $ "COL|PER"
	lEnte05 := (nEntidIni == 5)  //localizado
EndIf

aAdd(aPos,Ascan(aHeader,{|x|Alltrim(x[2]) == "CT0_CPOCHV"}))
aAdd(aPos,Ascan(aHeader,{|x|Alltrim(x[2]) == "CT0_CPODSC"}))
aAdd(aPos,Ascan(aHeader,{|x|Alltrim(x[2]) == "CT0_CPOSUP"}))


If lRet
	For nY := 1 to Len(aHeader)
		IF Empty(aCols[nLinha,nY]) .And. nY<9 .And. nY>12
			MSGINFO(STR0022,STR0021) //Existem campos obrigat�rios n�o preenchidos # CTBWizard - Entidades
			lRet := .F.
			Exit
		ENDIF
	Next nY
EndIf

If lRet
	For nY := 1 to Len(aPos)
		If !Empty(aCols[nLinha][aPos[nY]])
			cPrefix := PrefixoCpo(aCols[nLinha][nPosAlias])
			If !(cPrefix $ aCols[nLinha][aPos[nY]])
				MSGINFO(STR0076,STR0021) //"O campo deve pertencer a tabela da nova entidade" # CTBWizard - Entidades
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nY
EndIf

If lRet .And. lEntidad05 .And. lChkCTB .And. lEnte05   //localizado
	If !FWAliasInDic("QL6") .Or. !FWAliasInDic("QL7")
		MsgInfo(STR0086,STR0021) //"Antes debe crear las tablas de saldos contables de la entidad 05 (QL6 y QL7) a traves del configurador de Protheus."
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CT0F3SX3 �Autor  �Alvaro Camillo Neto � Data �  04/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para filtro de campos do SX3                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CtbA910                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CT0F3SX3()
Local aArea     := GetArea()
Local lRet      := .F.
Local cFiltro   := ""
Local aHeader   := oGetDados:aHeader
Local aCols     := oGetDados:aCols
Local nLinha    := oGetDados:nAt
Local nPosAlias := Ascan(aHeader,{|x|Alltrim(x[2]) == "CT0_ALIAS"})
Local cEntidade := aCols[nLinha][nPosAlias]
Local oDlg
Local oBrowse
Local oMainPanel
Local oPanelBtn
Local oBtnOK
Local oBtnCan
Local oColumn1
Local oColumn2
Local oColumn3

Local cIdiomaAtu  := Upper( Left( cIdioma, 2 ) )

If !Empty(cEntidade)
	cFiltro := " CT0SX3->X3_CONTEXT!='V' .And. CT0SX3->X3_TIPO=='C' .And. CT0SX3->X3_ARQUIVO == '" + Alltrim(cEntidade) + "' "
EndIf

If Select( 'CT0SX3' ) == 0
	OpenSxs(,,,,cEmpAnt,"CT0SX3","SX3",,.F.)
EndIf

Define MsDialog oDlg From 0, 0 To 390, 515 Title STR0070 Pixel Of oMainWnd		//"Consulta Padr�o - Campos do Sistema"

@00, 00 MsPanel oMainPanel Size 250, 80
oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

@00, 00 MsPanel oPanelBtn Size 250, 15
oPanelBtn:Align := CONTROL_ALIGN_BOTTOM

Define FWBrowse oBrowse DATA TABLE ALIAS 'CT0SX3'  NO CONFIG  NO REPORT ;
DOUBLECLICK { || lRet := .T.,  oDlg:End() } Of oMainPanel
ADD COLUMN oColumn1  DATA { || CT0SX3->X3_CAMPO   }  Title STR0071  Size Len( CT0SX3->X3_CAMPO   ) Of oBrowse // "Campo"

ADD COLUMN oColumn2  DATA { || If(cIdiomaAtu=="ES",CT0SX3->X3_TITSPA, If(cIdiomaAtu=="EN",CT0SX3->X3_TITENG, CT0SX3->X3_TITULO)) }  Title STR0072 Size Len( CT0SX3->X3_TITULO ) Of oBrowse			//"Titulo"
ADD COLUMN oColumn3  DATA { || If(cIdiomaAtu=="ES",CT0SX3->X3_DESCSPA, If(cIdiomaAtu=="EN",CT0SX3->X3_DESCENG, CT0SX3->X3_DESCRIC)) }  Title STR0073 Size Len( CT0SX3->X3_DESCRIC ) Of oBrowse		//"Descri��o"

If !Empty( cFiltro )
	oBrowse:SetFilterDefault( cFiltro )
EndIf
oBrowse:Activate()

Define SButton oBtnOK  From 02, 02 Type 1 Enable Of oPanelBtn ONSTOP STR0074 ;				//"Ok <Ctrl-O>"
Action ( lRet := .T., oDlg:End() )

Define SButton oBtnCan From 02, 32 Type 2 Enable Of oPanelBtn ONSTOP STR0075 ;				//"Cancelar <Ctrl-X>"
Action ( lRet := .F., oDlg:End() )

Activate MsDialog oDlg Centered

CT0SX3->( dbClearFilter() )

RestArea( aArea )

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CtbEntIniVar �Autor  �Microsiga        � Data �  08/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Analise da existencia dos campos das novas entidades       ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CtbEntIniVar(cIdEnt)
Local lExist := .F.
cIdEnt := StrZero(Val(cIdEnt),2)
lExist := CTJ->(FieldPos("CTJ_EC"+cIdEnt+"CR")>0 .And. FieldPos("CTJ_EC"+ cIdEnt + "DB")>0)
Return lExist
