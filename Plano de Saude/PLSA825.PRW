#include "PLSA825.CH"
#include "PROTHEUS.CH"

#DEFINE BASEINSSPF	1
#DEFINE INSSPF		2
#DEFINE BASEINSSPJ	3
#DEFINE INSSPJ		4
#DEFINE VLRFATURA	5
#DEFINE SALCONTRIB	6
#DEFINE PROLAB   	7
#DEFINE INSSPROLAB 	8

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA825
Gera dados referentes aos pagamentos efetuados aos RDA's nos seguintes arquivos:                                 
SRA - Funcionarios                                      
SI3 - Centro de Custos                                  
SRC - Lancamentos Mensais                               
Objetivo: Integracao com GPE - Gerar arquivo SEFIP.RE aproveitando a rotina GPEM610   
                           
@author	Lucas Nonato
@since	27/10/2017
	
@obs	Modifica��es V11 para V12:
@obs	Tabela SR5 migrada para RCB
@obs	Tabela SRX migrada para RCC
@obs	Tipo 15 migrado para Tabela S035 do cadastro de Manuten��o de Tabelas.
@obs	Grava��o na SRC deve ser apenas para gera��o da SEFIP, caso contrario utilizar tabela RGB que ap�s o calculo da folha grava a tabela SRC
@obs	N�o gravamos mais na SRCX e sim direto na SRC pois n�o se pode mais criar alias em tempo de execu��o.
/*/
//------------------------------------------------------------------------------------------
Function PLSA825
Local aSays     := {}
Local aButtons  := {}
Local cCadastro := ""
Local nOpca     := 0
Local cPerg     := "PLA825"
Local aIdCalc   := { "350", ;  	//Base INSS Autonomo PF e JF
					 "351", ;  	//INSS Autonomo PF
					 "353", ;  	//Base INSS Autonomo PJ
					 "354", ;  	//INSS Autonomo PJ
					 "314", ;  	//Valor de Fatura Prestacao de Servicos
					 "288", ;  	//Salario de Contribuicao Inss Outras Empresas
					 "221",;   	//Sal.Contr.Aut./Pro-Lab. 15%
					 "064"}    	//desconto de INSS

Local aCodPD    := { "", "", "", "", "", "", "", "" }
Local nI		   := 0
Local nCodFoL	:= tamSX3( "RV_CODFOL" )[ 1 ]

Private cSI3

//������������������������������������������������������������������������������Ŀ
//� Funcao cadastrada na tabela SRJ que sera utilizada para gerar dados na SEFIP �
//��������������������������������������������������������������������������������
If Empty(GetNewPar("MV_PLSFNSF",""))
	MsgStop(STR0012) // "Antes de prosseguir, favor cadastrar o parametro MV_PLSFNSF informando o codigo da funcao utilizada para gerar a SEFIP"
	Return
EndIf

For nI := 1 To Len(aCodPD)
	aCodPD[nI] := Posicione("SRV", 2, xFilial("SRV")+StrZero(Val(aIdCalc[nI]),nCodFoL), "RV_COD")
	If Empty(aCodPD[nI])
		Aviso(STR0005, STR0006 + aIdCalc[nI] + " - " + AllTrim(Tabela("35", aIdCalc[nI])),{"Ok"} ) // Verba nao Cadastrada
		Return
	EndIf
Next nI

Pergunte(cPerg, .F.)

cCadastro := FunDesc() // "Gera Base SEFIP PLS"

aAdd(aSays, OemToAnsi(STR0002) ) // "Este programa gera os arquivos que servirao de base ..."
aAdd(aSays, OemToAnsi(STR0003) )

aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpca := 1,If(PLA825OK(), FechaBatch(), nOpca := 0) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca <> 1
	Return
EndIf

MsAguarde({|| PLSA825DEL() }, "Analisando dados da competencia", "", .T.) 

If GetNewPar("MV_SI3PLS","SI3X")=='SI3X'
	cSI3 := "SI3"
Else
	cSI3 := "CTT"
Endif

//��������������������������������������������������������������������������Ŀ
//� Processa B15                                                             �
//����������������������������������������������������������������������������
MsAguarde({|| A825Gera(aCodPD) }, STR0007, "", .T.) // "Gerando base para SEFIP"

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A825Gera   � Autor � Sandro Hoffman Lopes  � Data � 08/12/05���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa "B15" para gravar "SRAX", "SRCX" e "SI3X"         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A825Gera(aCodPD)		
Local cSQL 		:= ""
Local cChaveSA1 := ""
Local cCodOpe 	:= ""
Local cCodRDA 	:= ""
Local cMatFun 	:= ""
Local cProcesso := "00003" // Contribuinte individual mensal
Local dData 	:= ""
Local cSemana   := ""
Local cRoteiro  := "AUT"
Local cPeriodo  := ""
Local cFilFun	:= ""
Local aDadosBAU := {} 
Local aDadosSA1 := {} 
Local aCodFun 	:= {} 
Local aPerAtual := {}

Local nI 		:= 0

Local lPLSA825CC:= ExistBlock("PLSA825CC")

Private cCodOpeDe, cCodOpeAte, cAnoPag, cMesPag, cRDAPad, cCopCre, cCopCrePar

cCodOpeDe  := mv_par01
cCodOpeAte := mv_par02
cAnoPag    := mv_par03
cMesPag    := mv_par04
cRDAPad    := mv_par05
cCopCrePar := mv_par06

// Encontra o periodo e verifica se esta ativo
If fGetPerAtual(@aPerAtual, xFilial( "RCH" ), cProcesso, cRoteiro) .And. aPerAtual[1][1] >= (cAnoPag+cMesPag)
	cPeriodo	:= aPerAtual[1][1]
	cSemana		:= aPerAtual[1][2]
	dData 		:= aPerAtual[1][7]
	
	// Verifica se o per�odo n�o se encontra bloqueado
	If !fVldAccess(xFilial("SRC"), dData, cSemana,.F., cRoteiro, "3", "V") 	
		MsgAlert("Per�odo se encontra bloqueado")
		Return .F.
	Endif
	
Else
	MsgAlert("Per�odo informado n�o esta cadastrado ou j� foi fechado")
	Return .F.
EndIf

cCopCre    := "("
For nI := 1 To Len(mv_par06)
	If ! SubStr(mv_par06, nI, 1) $ " *"
		cCopCre += IIf(Len(cCopCre) > 1, ",", "") + "'" + SubStr(mv_par06, nI, 1) + "'"
	EndIf
Next nI
cCopCre    += ")"

//������������������������������������������������������������������������������Ŀ
//� Funcao cadastrada na tabela SRJ que sera utilizada para gerar dados na SEFIP �
//��������������������������������������������������������������������������������
aAdd(aCodFun, GetMV("MV_PLSFNSF"))

IF SRJ->(FieldPos("RJ_CODCBO")) > 0
	aAdd(aCodFun, Posicione("SRJ", 1, xFilial("SRJ")+aCodFun[1], "RJ_CODCBO"))
Else
	aAdd(aCodFun, Posicione("SRJ", 1, xFilial("SRJ")+aCodFun[1], "RJ_CBO"))
Endif


cSQL := " SELECT B15_OPERDA, B15_CODRDA, B15_CLIENT, B15_LOJA, B15_BASEPF, B15_BASEPJ, B15_BASEJF, B15_INSSPF, B15_INSSPJ, "
cSQL += " BAU_NOME, BAU_INSS, BAU_END, BAU_BAIRRO, BAU_MUN, BAU_EST, BAU_CEP, BAU_COPCRE, BAU_CBO, BAU_FILFUN, BAU_MATFUN "
cSql += " FROM " + RetSqlName("B15") + " B15 "

cSQL += " INNER JOIN " + RetSQLName("BAU") + " BAU "
cSQL += " ON  BAU_FILIAL = '" + xFilial("BAU") + "' "
cSQL += " AND BAU_CODIGO = B15_CODRDA "
cSQL += " AND BAU.D_E_L_E_T_ <> '*' "

cSQL += " WHERE B15_FILIAL = '" + xFilial("B15") + "' "
cSQL += " AND (B15_OPERDA >= '" + cCodOpeDe + "' "
cSQL += " AND B15_OPERDA <= '" + cCodOpeAte + "') "
cSQL += " AND B15_ANOLOT = '" + cAnoPag + "' "
cSQL += " AND B15_MESLOT = '" + cMesPag + "' "
cSQL += " AND B15.D_E_L_E_T_ <> '*'"

//��������������������������������������������������������������������������Ŀ
//� Exibe mensagem...                                                        �
//����������������������������������������������������������������������������
MsProcTxt(STR0004) // "Buscando dados no servidor..."

cSql := ChangeQuery(cSql)
If GetNewPar("MV_PSFPLOG",.F.)
	PlsPtuLog("-----------------------------------------------", "Sefip.log")
	PlsPtuLog(cSql, "Sefip.log")
	PlsPtuLog("-----------------------------------------------", "Sefip.log")
EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"Trb825",.F.,.T.)

While ! Trb825->(Eof())
	
	MsProcTxt(STR0008 + Trb825->B15_CODRDA + "... ") // "Processando RDA "
	ProcessMessages()
	If  ! Trb825->BAU_COPCRE $ cCopCrePar
		Trb825->(dbSkip())
		Loop
	Endif
	
	If cCodOpe <> Trb825->B15_OPERDA
		cCodOpe := Trb825->B15_OPERDA
		// Indice 1 - BA0_FILIAL+BA0_CODIDE+BA0_CODINT
		BA0->(dbSetOrder(1))
		BA0->(MsSeek(xFilial("BA0")+cCodOpe, .F.))
	EndIf
	
	// Somente gera SI3 e SRA se houver algum valor a gravar no SRC, pois se gravar SI3 e SRA e nao gravar
	// SRC, caso haja valor de fatura para o Tomador de Servico (CLIENTE), nao ira gravar o SRC com R$ 0.01
	// na rotina "fGr_RCC". Isso fazia com que o GPEM610 gravasse um registro TIPO 20 sem o TIPO 30 no arquivo
	// da SEFIP e gerava um erro na validacao da SEFIP
	// BOPS: 94817
	If Trb825->B15_BASEPF > 0 .Or. Trb825->B15_BASEPJ > 0 .Or. Trb825->B15_BASEJF > 0
		cMatFun   := Trb825->BAU_MATFUN
		cFilFun	  := Trb825->BAU_FILFUN
		cCodRDA   := Trb825->B15_CODRDA
		cChaveSA1 := Trb825->(B15_CLIENT+B15_LOJA)
		aDadosSA1 := GetAdvFVal("SA1", { "A1_NOME", "A1_END", "A1_BAIRRO", "A1_CEP", "A1_MUN", "A1_EST", "A1_CGC", "A1_CEINSS", "A1_PESSOA" }, xFilial("SA1")+cChaveSA1, 1, { "", "", "", "", "", "", "", "", "" })
		aDadosBAU := { Trb825->BAU_NOME, Trb825->BAU_INSS, Trb825->BAU_END, Trb825->BAU_BAIRRO, Trb825->BAU_MUN, Trb825->BAU_EST, Trb825->BAU_CEP, Trb825->BAU_CBO, Trb825->BAU_MATFUN}
		fGr_SI3(@cChaveSA1, aDadosSA1)		
		
		//����������������������������������������������������������������������������������������Ŀ
		//� Ponto de Entrada - Para alterar a Chave qdo for federa��o e for pago para o mesmo CGC  �
		//������������������������������������������������������������������������������������������		
		If lPLSA825CC
			cChaveSA1:= ExecBlock("PLSA825CC",.F.,.F.,{Trb825->B15_CLIENT,Trb825->B15_LOJA})
		EndIf
		//Gera a base Unica Pessoa F�sica + Jur�dica
		If GetNewPar("MV_PLCATEG","") == "13" .And. ALLTRIM(Trb825->BAU_COPCRE) $ GetNewPar("MV_PLTIPRE","1,2,3")//Contribuinte individual - Trabalhador aut�nomo ou a este equiparado
			fGr_SRC(aCodPD[PROLAB], cChaveSA1, cMatFun, Trb825->(B15_BASEPF+B15_BASEPJ+B15_BASEJF), cCodRDA, cFilFun)
			fGr_SRC(aCodPD[INSSPROLAB], cChaveSA1, cMatFun, Trb825->(B15_INSSPF+B15_INSSPJ), cCodRDA, cFilFun)
		Else
			If Trb825->B15_BASEPF <> 0 // Base INSS Pessoa Fisica
				fGr_SRC(aCodPD[BASEINSSPF], cChaveSA1, cMatFun, Trb825->B15_BASEPF, cCodRDA, cFilFun)
			EndIf
			If Trb825->B15_BASEPJ <> 0 // Base INSS Pessoa Juridica
				fGr_SRC(aCodPD[BASEINSSPJ], cChaveSA1, cMatFun, Trb825->B15_BASEPJ, cCodRDA, cFilFun)
			EndIf
			If Trb825->B15_BASEJF <> 0 // Base INSS Juridica Filantropica
				fGr_SRC(aCodPD[BASEINSSPF], cChaveSA1, cMatFun, Trb825->B15_BASEJF, cCodRDA, cFilFun)
			EndIf
			If Trb825->B15_INSSPF > 0 // INSS Pessoa Fisica
				fGr_SRC(aCodPD[INSSPF], cChaveSA1, cMatFun, Trb825->B15_INSSPF, cCodRDA, cFilFun)
			EndIf
			If Trb825->B15_INSSPJ > 0 // INSS Pessoa Juridica
				fGr_SRC(aCodPD[INSSPJ], cChaveSA1, cMatFun, Trb825->B15_INSSPJ, cCodRDA, cFilFun)
			EndIf
		Endif
		// Grava um centavo para o ID Calc 288 (INSS Outras Empresas) para que a SEFIP seja gerada com
		// ocorrencia "05", onde sera possivel informar o valor de INSS retido para cada RDA
		fGr_SRC(aCodPD[SALCONTRIB], cChaveSA1, cMatFun, 0.01, cCodRDA, cFilFun)
	EndIf
	
	Trb825->(dbSkip())
	
EndDo

Trb825->(DbCloseArea())

fProcBBT(aCodPD)
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fGr_SI3    � Autor � Sandro Hoffman Lopes  � Data � 08/12/05���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava o arquivo "SI3X"                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGr_SI3(cChaveSA1, aDadosSA1)
/*	
���������������������������������������������������������������Ŀ
� aDadosSA1[8] - Numero do CEI                                  �
� aDadosSA1[9] - Tipo Pessoa: F-Fisica / J-Juridica             �
�                                                               �
�1) Se cliente eh Pessoa Fisica e NAO POSSUI CEI, deve constar  �
�   como TOMADOR DE SERVICOS a propria OPERADORA.               �
�                                                               �
�2) Se cliente eh Pessoa Fisica e POSSUI CEI, deve constar como �
�   TOMADOR DE SERVICOS o proprio cliente. Ex.: Escritorios de  �
�   Contabilidade onde o contador se cadastra no INSS (CEI) pa- �
�   ra ter empregados e paga os impostos devidos.               �
�                                                               �
�3) Se CGC do Cliente eh o mesmo da OPERADORA, deve constar como�
�   OPERADORA para evitar duplicidade de registros na geracao   �
�   do SRC.                                                     �
�                                                               �
�4) Se o cliente eh uma operadora (atendimentos de intercambio) �
�   deve constar como TOMADOR DE SERVICOS a propria OPERADORA.  �
�����������������������������������������������������������������*/
Local lOper := .F.
If  (aDadosSA1[9] == "F" .or. Empty(aDadosSA1[9])) .and. Empty(aDadosSA1[8])
	lOper := .T.
Endif
If  aDadosSA1[7] == BA0->BA0_CGC
	lOper := .T.
Endif
If  fInterc(aDadosSA1[7])
	lOper := .T.
Endif
If lOper
	aDadosSA1[1] := BA0->BA0_NOMINT
	aDadosSA1[2] := BA0->BA0_END
	aDadosSA1[3] := BA0->BA0_BAIRRO
	aDadosSA1[4] := BA0->BA0_CEP
	aDadosSA1[5] := BA0->BA0_CIDADE
	aDadosSA1[6] := BA0->BA0_EST
	aDadosSA1[7] := BA0->BA0_CGC
	aDadosSA1[8] := ""
	cChaveSA1    := "OPERADORA"
EndIf

// Indice 1: I3_FILIAL+I3_CUSTO+I3_CONTA+I3_MOEDA
If Alltrim(cSI3) =="SI3"
	SI3->(dbSetOrder(1))
	If ! SI3->(MsSeek(xFilial("SI3")+PadR(cChaveSA1, 9)))
		SI3->(RecLock("SI3", .T.))
		SI3->I3_FILIAL  := xFilial("SI3")
		SI3->I3_CUSTO   := cChaveSA1
		SI3->I3_DESC    := "CC PLS"
		SI3->I3_NOME    := aDadosSA1[1]
		SI3->I3_ENDEREC := aDadosSA1[2]
		SI3->I3_BAIRRO  := aDadosSA1[3]
		SI3->I3_CEP     := aDadosSA1[4]
		SI3->I3_MUNICIP := aDadosSA1[5]
		SI3->I3_ESTADO  := aDadosSA1[6]
		SI3->I3_TIPO    := IIf(Empty(aDadosSA1[8]), "1", "2") // 1-CNPJ , 2-CEI
		SI3->I3_CEI     := IIf(Empty(aDadosSA1[8]), aDadosSA1[7], PadL(AllTrim(aDadosSA1[8]), 14, "0"))
		SI3->(MsUnlock())
	EndIf
Else
	CTT->(dbSetOrder(1))
	If ! CTT->(MsSeek(xFilial("CTT")+PadR(cChaveSA1, 9), .F.))
		CTT->(RecLock("CTT", .T.))
		CTT->CTT_FILIAL  := xFilial("SI3")
		CTT->CTT_CUSTO   := cChaveSA1
		CTT->CTT_DESC01  := "CC PLS"
		CTT->CTT_NOME    := aDadosSA1[1]
		CTT->CTT_ENDER   := aDadosSA1[2]
		CTT->CTT_BAIRRO  := aDadosSA1[3]
		CTT->CTT_CEP     := aDadosSA1[4]
		CTT->CTT_MUNIC   := aDadosSA1[5]
		CTT->CTT_ESTADO  := aDadosSA1[6]
		CTT->CTT_TIPO    := IIf(Empty(aDadosSA1[8]), "1", "2") // 1-CNPJ , 2-CEI
		CTT->CTT_CEI     := IIf(Empty(aDadosSA1[8]), aDadosSA1[7], PadL(AllTrim(aDadosSA1[8]), 14, "0"))
		CTT->(MsUnlock())
	EndIf
	
Endif
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fGr_SRC    � Autor � Sandro Hoffman Lopes  � Data � 08/12/05���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava o arquivo "SRCX"                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGr_SRC(cCodPD, cChaveSA1, cMatFun, nVlrPag, cCodRDA, cFilFun)
	
Local cProcesso := '00003' // Contribuinte individual mensal
Local dData 	:= ''
Local cSemana   := ''
Local cRoteiro  := 'AUT'
Local aPerAtual := {}
Local cPeriodo  := ''
DEFAULT cCodRDA := ""
DEFAULT cFilFun := xFilial("SRC")

SRC->(dbSetOrder(15)) //RC_FILIAL, RC_PROCES, RC_MAT, RC_PERIODO, RC_SEMANA, RC_ROTEIR, RC_PD, RC_CC, RC_ITEM, RC_CLVL, RC_SEQ, RC_DTREF, R_E_C_D_E_L_                                                                                                                                              
//If ! SRC->(MsSeek(xFilial("SRC")+PadR(cChaveSA1, 9)+cMatFun+cCodPD))
If ! SRC->(MsSeek(cFilFun+cProcesso+cMatFun+cAnoPag+cMesPag+'01'+cRoteiro+cCodPD+cChaveSA1))
	SRC->(RecLock("SRC", .T.))
	SRC->RC_FILIAL := cFilFun
	SRC->RC_MAT    := cMatFun
	SRC->RC_PD     := cCodPD
	SRC->RC_TIPO1  := "V"
	SRC->RC_CC     := cChaveSA1
	SRC->RC_TIPO2  := "G"
	SRC->RC_PERIODO:= cAnoPag+cMesPag
	SRC->RC_ROTEIR := cRoteiro
	SRC->RC_PROCES := cProcesso
	SRC->RC_SEMANA := '01'
	SRC->RC_LOTPLS := 'PLSA825'
	SRC->RC_CODRDA := cCodRDA
Else
	SRC->(RecLock("SRC", .F.))
EndIf
SRC->RC_VALOR  += nVlrPag
SRC->(MsUnlock())
	
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLA825Ok  � Autor � Sandro Hoffman Lopes  � Data � 08/12/05���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Confirma parametros antes de continuar processamento       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PLA825Ok()
Return (MsgYesNo(OemToAnsi(STR0009),OemToAnsi(STR0010))) // "Confirma configura��o dos par�metros?" ## "Atencao"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fProcBBT   � Autor � Sandro Hoffman Lopes  � Data � 04/01/06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Le tabela BBT (Titulo Gerados pelo PLS) e grava tabela     ���
���Descri��o � "RCC" com o Valor das Faturas por Tomador                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fProcBBT(aCodPD)
	
Local cSQL, aDadosSA1, cChaveSA1, aCC
Local cBBTName := RetSQLName("BBT") // Titulos Gerados pelo PLS

cSQL     := " SELECT BBT_CLIFOR, BBT_LOJA, BBT_BASINS "
cSQL     += " FROM " + cBBTName
cSQL     += " WHERE "
cSql     += "        BBT_FILIAL = '" + xFilial("BBT") + "' AND "
cSql     += "        BBT_CODOPE >= '" + cCodOpeDe  + "' AND "
cSQL     += "        BBT_CODOPE <= '" + cCodOpeAte + "' AND "
cSQL     += "        BBT_MESTIT = '" + cMesPag + "' AND "
cSQL     += "        BBT_ANOTIT = '" + cAnoPag + "' AND "
cSQL     += "        BBT_INTERC = '0' AND "
cSQL     += "        BBT_RECPAG = '0' AND "
cSQL     += "        " + cBBTName + ".D_E_L_E_T_ <> '*' "

//��������������������������������������������������������������������������Ŀ
//� Exibe mensagem...                                                        �
//����������������������������������������������������������������������������
MsProcTxt(STR0004) // "Buscando dados no servidor..."
ProcessMessages()

PLSQuery(cSQL, "Trb825") // Igual ao TCQuery

Trb825->(DbGotop())
aCC := {}

Do While ! Trb825->(Eof())
	
	MsProcTxt(STR0011 + Trb825->(BBT_CLIFOR+BBT_LOJA) + "... ") // "Processando Cliente "
	ProcessMessages()
	
	aDadosSA1 := GetAdvFVal("SA1", { "A1_CEINSS", "A1_PESSOA", "A1_CGC" }, xFilial("SA1")+Trb825->(BBT_CLIFOR+BBT_LOJA), 1, { "", "" })
	If (aDadosSA1[2] == "F" .Or. Empty(aDadosSA1[2])) .And. Empty(aDadosSA1[1]) .Or. ; // Cliente pagador eh Pessoa Fisica e nao possui CEI
		(fInterc(aDadosSA1[3]))
		cChaveSA1 := "OPERADORA"
		// Nao deve gerar o valor da Fatura qdo o Tomador for a propria OPERADORA
		Trb825->(dbSkip())
		Loop
	Else
		cChaveSA1 := Trb825->(BBT_CLIFOR+BBT_LOJA)
	EndIf
	
	nInd := aScan(aCC, {|x| x[1] == cChaveSA1})
	If nInd == 0
		aAdd(aCC, { cChaveSA1, 0 })
		nInd := Len(aCC)
	EndIf
	aCC[nInd, 2] += Trb825->BBT_BASINS
	
	Trb825->(dbSkip())
	
EndDo

Trb825->(DbCloseArea())

fGr_RCC(aCC, cAnoPag, cMesPag, aCodPD)
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fGr_RCC    � Autor � Sandro Hoffman Lopes  � Data � 04/01/06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava o arquivo "RCC" com o Valor das Faturas por Tomador  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGr_RCC(aCC, cAnoPag, cMesPag, aCodPD)
	
Local   nL		   := 0
Local   nX		   := 1
Local   nI 		   := 1
Local   nRecVal	   := 0
Local   nRegistros
Local   nCnt
Local   nItens
Local   cTip       := "S035"
Local   cCodPD     := aCodPD[VLRFATURA]
Local   cChaveSA1  := ""
Local   cMatFun    := ""
Local   aDadosSA1  := {}
Local   aDadosBAU  := {}
Local   aCodFun    := {}
Private nUsado     := 0
Private aHeader    := {}
Private aCols      := {}
Private nOpcx      := 4	
Private lAdmin  	:= FWIsAdmin( __cUserID )	
Private aInfoUser	:= {}	
Private aEmp		:= {}	

//��������������������������������������������������������������Ŀ
//� Se usuario nao for administrador, busca os acessos do usuario�
//� Se ele possui acesso a todas as filiais, sera administrador. �
//����������������������������������������������������������������
If !lAdmin
	//Ordem pelo ID do usu�rio/grupo
	PswOrder( 1 )
	//Pesquisa por usuario - Obtem as informcoes de usu�rio.
	PswSeek( __cUserID, .T. )
	aInfoUser := PswRet( 2 )
	//Procura o Grupo por Codigo
	aRet := AllGroups(.F.)
	//Obtem os Grupos no qual o usu�rio participa e carrega sua posicao
	aGrupoAc := UsrRetGrp()
	//-- Verifica se prioriza o grupo de acessos
	lPrioriza:= aInfoUser[1][11]
	//--Obtem informa��es de grupo do usuario
	aEmpresas(@aEmp)
	
	For nX:= 1 To Len(aGrupoAc)
		If lPrioriza
			For nI := 1 to Len(aRet)
				nPos	 := Ascan(aRet, {|X| Alltrim(aRet[nI, 1, 1]) == aGrupoAc[nX]})
				If (nPos > 0)
					nRecVal  := nPos
				EndIf
			Next nI
			//Verifica quais Empresa e Filiais
			If nRecVal > 0
				aRetPrio := FWGrpEmp(aGrupoAc[nRecVal])
			Endif
			//clona os acessos de Empresas e Filiais do grupo
			aInfoUser[1][6]:= aClone(aRetPrio)
		EndIf
	Next
	
	//-- Se prioriza grupo, verifica se algum grupo eh de administrador
	IF lPrioriza
		lAdmin :=  fAccess(aEmp,'@@@@')
	Endif
	
	IF !lAdmin
		IF Len(aInfoUser[1][6]) > 0
			lAdmin    := If( aInfoUser[1][6][1] == "@@@@", .T., .F. )
		Endif
	Endif
EndIf
//������������������������������������������������������������������������������Ŀ
//� Funcao cadastrada na tabela SRJ que sera utilizada para gerar dados na SEFIP �
//��������������������������������������������������������������������������������
aAdd(aCodFun, GetMV("MV_PLSFNSF"))
IF SRJ->(FieldPos("RJ_CODCBO")) > 0
	aAdd(aCodFun, Posicione("SRJ", 1, xFilial("SRJ")+aCodFun[1], "RJ_CODCBO"))
Else
	aAdd(aCodFun, Posicione("SRJ", 1, xFilial("SRJ")+aCodFun[1], "RJ_CBO"))
Endif

//��������������������������������������������������������������Ŀ
//� Monta o cabecalho                                            �
//����������������������������������������������������������������
RCB->(dbSetOrder(1))
RCB->(MsSeek(FWxFilial("RCB")+cTip))

nRegistros := IIf(RCB->RCB_TAMAN <= 0, 1, RCB->RCB_TAMAN)
Do While ! RCB->(Eof()) .And. RCB->RCB_CODIGO == cTip
	nUsado++
	aAdd(aHeader,{ Trim(RCB->RCB_DESC),RCB->RCB_CAMPOS,RCB->RCB_PICTUR,RCB->RCB_TAMAN,RCB->RCB_DECIMA,RCB->RCB_VALID,RCB->RCB_TIPO,Val(RCB->RCB_ORDEM) } )
	RCB->(dbSkip())
EndDo

If Len(aHeader) == 0
	Help('',1,'A150SRCB',,'Registro S035 n�o encontrado, verifique a rotina de Manuten��o de Tabelas no SIGAGPE!',1,0)
	Return
EndIf

nCnt := 0
RCC->(dbSetOrder(1))
RCC->(MsSeek(FWxFilial("RCB")+cTip))
Do While ! RCC->(Eof()) .And. RCC->RCC_CODIGO == cTip
	nCnt ++
	RCC->(dbSkip())
EndDo

nCnt   := Int(nCnt/nRegistros)
nCnt   := IIf(nOpcx == 3, 1, nCnt)
aCols  := Array(nCnt, nUsado+IIf(nOpcx=2 .Or. nOpcx=6, 0, 1))
nItens := 0
nCnt   := 0

//��������������������������������������������������������������Ŀ
//� Monta o aCols com os dados gravados no RCC - Cod S035        �
//����������������������������������������������������������������
CarS035(nRegistros, @nItens, nOpcx)

//���������������������������������������������������������������Ŀ
//� Zera valores no array aCols pois, se nao houver mais fatura   �
//� para um determinado TOMADOR, geraria com o valor ja gravado.  �
//�����������������������������������������������������������������
For nL := 1 To Len(aCols)
	aCols[nL, fPosCpo("Base")] := "0.00"
Next nL

//��������������������������������������������������������������Ŀ
//� Inclui/Altera todos os CC's do array aCC no array aCols      �
//����������������������������������������������������������������
For nL := 1 To Len(aCC)
	// Pesquisa se ja existe dados para o CC (TOMADOR) em questao, caso nao exista, grava SI3, SRA e SRC para
	// que o prog9rama gere o TIPO 20/30 referente a este CC (TOMADOR) com o valor das faturas emitidas
	// Neste caso o SRC e gravado com R$ 0,01 de base de INSS apenas para gerar o arquivo da SEFIP
	cChaveSA1 := aCC[nL, 1]
	//DbSelectArea(cSI3)
	//dbSetOrder(1)
	If ! MsSeek(xFilial(cSI3)+PadR(cChaveSA1, 9), .F.) .And. aCC[nL, 2] > 0
		cMatFun   := cRDAPad
		aDadosSA1 := GetAdvFVal("SA1", { "A1_NOME", "A1_END", "A1_BAIRRO", "A1_CEP", "A1_MUN", "A1_EST", "A1_CGC", "A1_CEINSS", "A1_PESSOA" }, xFilial("SA1")+cChaveSA1, 1, { "", "", "", "", "", "", "", "", "" })
		aDadosBAU := GetAdvFVal("BAU", { "BAU_NOME", "BAU_INSS", "BAU_END", "BAU_BAIRRO", "BAU_MUN", "BAU_EST", "BAU_CEP","BAU_CBO","BAU_MATFUN","BAU_FILFUN" }, xFilial("BAU")+cMatFun, 1, { "", "", "", "", "", "", "", "" })
		cMatFun   := aDadosBAU[9]
		cFilFun   := aDadosBAU[10]
		fGr_SI3(@cChaveSA1, aDadosSA1)
		//fGr_SRA(cChaveSA1, aDadosSA1, cMatFun, aDadosBAU, aCodFun)
		fGr_SRC(aCodPD[BASEINSSPJ], cChaveSA1, cMatFun, 0.01, cFilFun) // Base INSS Pessoa Juridica
		// Grava um centavo para o ID Calc 288 (INSS Outras Empresas) para que a SEFIP seja gerada com
		// ocorrencia "05", onde sera possivel informar o valor de INSS retido para cada RDA
		fGr_SRC(aCodPD[SALCONTRIB], cChaveSA1, cMatFun, 0.01, cFilFun) // Inss Outras Empresas
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Pesquisa se ja existe a chave no RCC - S035               �
	//����������������������������������������������������������������
	nInd := aScan(aCols, {|x| AllTrim(x[fPosCpo("Observacao")]) == FWCodFil() .And. ; // X15_EMPRE1 = Observacao
	AllTrim(x[fPosCpo("CdeCusto")])		== aCC[nL, 1]   	.And. ;
		AllTrim(x[fPosCpo("CmpIniMM")]) == cMesPag 			.And. ;
		AllTrim(x[fPosCpo("CmpAnoIn")]) == cAnoPag        	.And. ;
		AllTrim(x[fPosCpo("Verba    ")]) == cCodPD         	.And. ;
		AllTrim(x[fPosCpo("TpContr")]) == "1" })
	If nInd == 0
		aAdd(aCols, Array(nUsado + 1))
		nInd := Len(aCols)
		aEval(aHeader, { |x| aCols[nInd, fPosCpo(x[2])] := IIf(x[7] == "N", 0, Space(x[4])) })
		aCols[nInd, fPosCpo("Observacao")] := FWCodFil() // X15_EMPRE1 = Observacao
		aCols[nInd, fPosCpo("CdeCusto")] := PadR(aCC[nL, 1], aHeader[fPosCpo("CdeCusto"), 4])
		aCols[nInd, fPosCpo("CmpIniMM")] := cMesPag
		aCols[nInd, fPosCpo("CmpAnoIn")] := cAnoPag
		aCols[nInd, fPosCpo("CmpFimMM")] := cMesPag
		aCols[nInd, fPosCpo("CmpFimAn")] := cAnoPag
		aCols[nInd, fPosCpo("Verba")] 	 := cCodPD
		aCols[nInd, fPosCpo("TpContr")]  := "1"
		aCols[nInd, nUsado + 1]          := .F.
		
	EndIf
	aCols[nInd, fPosCpo("Base")] := aCC[nL, 2]
Next nL

//��������������������������������������������������������������Ŀ
//� Grava o array aCols no RCC - S035                         		�
//����������������������������������������������������������������
RCC->(dbSetOrder(1))
//--Alteracao
If nOpcx = 4
	RCC->(MsSeek(FwxFilial()+ cTip))
	Do While ! RCC->(Eof()) .And. RCC->RCC_CODIGO == cTip
		RecLock("RCC", .F., .T.)
		nCnt ++
		DbDelete()
		MsUnlock()
		RCC->(dbSkip())
	Enddo
EndIf
//--Gravacao na Inclusao e Alteracao
If nOpcx == 3 .Or. nOpcx == 4
	PL825GRV()
EndIf
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fPosCpo   � Autor � Sandro Hoffman Lopes  � Data � 04/01/06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna posicao de determinado campo dentro de aHeader     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fPosCpo(cCampo)
Return aScan(aHeader, {|x| AllTrim(x[2]) == AllTrim(cCampo) })



/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Funcao    � fTpPrest  � Autor � Sandro Hoffman Lopes � Data � 20.06.06 ���
��������������������������������������������������������������������������Ĵ��
��� Descricao � Selecionar os Tipos de Prestador que serao gerados.        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function fTpPrest(l1Elem,lTipoRet)
	
Local cTitulo  := ""
Local MvPar
Local MvParDef := ""
Local aCBOX    := {}
Local aTpPrest := {}
Local cAlias

DEFAULT lTipoRet := .T.

l1Elem := If (l1Elem = Nil , .F. , .T.)

cAlias := Alias()

If lTipoRet
	MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	MvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
EndIf

aCBOX := RetSx3Box(X3CBox(Posicione('SX3', 2, "BAU_COPCRE", 'X3_CBOX')),,,1)
aEval(aCBOX, {|x| IIf(!Empty(x[1]), aAdd(aTpPrest, x[1]),) })
MvParDef := "1234"
cTitulo  := "Tipo de Prestador"
If lTipoRet
	If f_Opcoes(@MvPar, cTitulo, aTpPrest, MvParDef, 12, 49, l1Elem)  // Chama funcao f_Opcoes
		&MvRet := MvPar // Devolve Resultado
	EndIf
EndIf

DbSelectArea(cAlias) // Retorna Alias
	
Return(If(lTipoRet, .T., MvParDef))
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fInterc   � Autor � Angelo Sperandio      � Data � 26/12/06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se o cliente eh uma operadora                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fInterc(cCGC)
	
Local lRet    := .F.
Local nPosBA0 := BA0->(Recno())

SIX->(dbSetOrder(1))
BA0->(dbSetOrder(4))
If  BA0->(msSeek(xFilial("BA0")+cCGC))
	lRet := .T.
Endif
BA0->(dbSetOrder(1))
BA0->(dbGoTo(nPosBA0))
	
Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �aEmpresas �Autor  �Equipe RH           � Data �  21/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para obter grupos do usuario. 						  ���
�������������������������������������������������������������������������͹��
���Uso       � GPEA150                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function aEmpresas(aEmp)
	
//Pesquisa por usuario
PswSeek( __cUserID, .T. )
//--Obtem os grupos do usuario
aEmp := PswRet( 1 )[1][10]
	
Return(aEmp)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fAccess   �Autor  �Equipe RH           � Data �  21/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verificar se possui acesso a Filial Cadastrada.			  ���
�������������������������������������������������������������������������͹��
���Uso       � GPEA150                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fAccess(aEmp,cMyFil)
Local lRet := .F.
Local nI

For nI:=1 to len(aEmp)
	If (lRet:= (cMyFil $ aEmp[nI]))
		Exit
	Endif
Next nI
	
Return (lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL825GRV
Fun��o para substituir a gp150Grava() do GPEA150

@author	Lucas Nonato
@since	27/10/2017
/*/
//------------------------------------------------------------------------------------------
Static Function PL825GRV()
Local cChave 		:= ""
Local cInclFilial 	:= FWxFilial("RCB")
Local cTxt			:= ""		
Local cTip			:= "S035"
Local nCnt			:= 0	
Local nCol			:= 0	
Local nReg 			:= 1	

For nCnt =1 TO Len(aCols)
	If substr(aHeader[1,2],1,3) == "S035"
		If aCols[nCnt,3]==0 .and. aCols[nCnt,4]==0 .and. aCols[nCnt,5]==0
			loop
		EndIf
	Endif	

	nCol := 1
	nReg := 1
	
	RCB->(dbSetOrder(1))
	If RCB->(MsSeek(xFilial("RCB") +  cTip )) 
		While !RCB->(EOF()) .And. ( RCB->RCB_CODIGO =  cTip ) .And. VAL(RCB->RCB_ORDEM) = nReg
			cCampo := ""				
			If RCB->RCB_TIPO = "C" .Or. aCols[nCnt, Len(aCols[nCnt])]
				If ValType(aCols[nCnt,nReg]) <> 'C'
					aCols[nCnt,nReg] := cValToChar(aCols[nCnt,nReg])
				EndIf
				cCampo := SubStr(aCols[nCnt,nReg] + Space(RCB->RCB_TAMAN),1,RCB->RCB_TAMAN)
			ElseIf RCB->RCB_TIPO = "N"
				cCampo := SubStr(Str(aCols[nCnt,nReg],RCB->RCB_TAMAN,RCB->RCB_DECIMA),1,RCB->RCB_TAMAN)
			ElseIf RCB->RCB_TIPO = "D"
				cCampo := If( Empty(aCols[nCnt,nReg]) , DTOC(aCols[nCnt,nReg]), DTOS(aCols[nCnt,nReg]) )
			Endif
			
			cTxt += cCampo
			
			If AllTrim(RCB->RCB_CAMPOS) $ 'CmpIniMM;CmpAnoIn'
				cChave += cCampo
			EndIf
			RCB->(dbSkip())
			nReg ++
		Enddo
		If Len(AllTrim(cTxt+cTip+cChave)) = 0
			Exit
		Endif
		If RCC->(MsSeek(FwxFilial('RCC') + 'S035' + Space(tamSX3( "RCC_FIL" )[ 1 ]) + cChave))
			RCC->(RecLock("RCC",.F.))
		Else
			RCC->(RecLock("RCC",.T.))
		EndIf				
		RCC->RCC_FILIAL :=  cInclFilial
		RCC->RCC_CODIGO :=  cTip
		RCC->RCC_CHAVE  :=  cChave
		RCC->RCC_CONTEU :=  cTxt
		RCC->(MsUnlock())				
		cTxt := ""
		cChave := ""
		
	EndIf
	
Next
	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarS035
Fun��o para substituir a Carrega15() do GPEA150

@author	Lucas Nonato
@since	27/10/2017
/*/
//------------------------------------------------------------------------------------------
Static Function CarS035(nRegistros,nItens,nOpcx)
	
Local aRCC     := {}	
Local nReg     := 0
Local nCnt     := 0
Local nPosRCB  := 1

RCC->(dbSetOrder(1))
RCB->(dbSetOrder(1))

If !RCC->( MsSeek(xFilial('RCC') + "S035"))
	Return
EndIf	
	
While !RCC->( Eof()) .and. RCC->RCC_CODIGO ==  "S035"		
	If RCB->( MsSeek( xFilial("RCB")+ "S035") )
		While !RCB->(Eof()) .and. (RCB->RCB_FILIAL + RCB->RCB_CODIGO ==  FWxFilial("RCB") + "S035")
			aAdd(aRCC, SubStr(RCC->RCC_CONTEU,nPosRCB,RCB->RCB_TAMAN))
			nPosRCB += RCB->RCB_TAMAN
			RCB->( dbSkip() )
		EndDo		
	EndIf
	If Len(aRCC) > 0
		aAdd(aRCC, .T.)
		aAdd(aCols, aRCC)
		aRCC := {}		
		nItens++
	EndIf
	RCC->( dbSkip() )
	
EndDo	

Return
 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA825DEL
Exclusao dos lotes da competencia

@author    Lucas Nonato
@version   12.1.17
@since     14/11/2017
/*/
//------------------------------------------------------------------------------------------
Function PLSA825DEL()

TCSQLEXEC("DELETE FROM " + RetSqlName("SRC") + " WHERE RC_FILIAL = '" + xfilial("SRC") +"'" + "AND RC_LOTPLS = 'PLSA825' ")

Return .T.
