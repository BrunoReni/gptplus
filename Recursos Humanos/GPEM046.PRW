#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM046.CH"
#INCLUDE "SCOPECNT.CH"

#DEFINE TAMIMP 120

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Funcao    	� GPEM046    � Autor � Claudinei Soares         	  � Data �16/10/2015���
���������������������������������������������������������������������������������������Ĵ��
���Descricao 	� Qualificacao Cadastral												���
���             � Rotina utilizada para importar o arquivo de retorno da Qualificacao.  ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   	� GPEM046()                                                    		    ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      	� Generico (DOS e Windows)                                   			���
���������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.               			���
���������������������������������������������������������������������������������������Ĵ��
���Programador  � Data     � FNC			�  Motivo da Alteracao                      ���
���������������������������������������������������������������������������������������Ĵ��
���Claudinei S. �16/10/2015� TTNOIN         � Criacao do novo fonte.                    ���
���Claudinei S. �23/06/2016� TVMB97         � Tratamento em GPM46Proce() para linhas em ���
���				�          �                � branco no novo leiaute.                   ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Function GPEM046()

Local cArquivo
Local nOpca := 0

Local aSays:={ }, aButtons:= { } //<== arrays locais de preferencia

Local aRegs	   		:= {}
Local aHelpPor		:= {}

Private cPerg		:= "GPEM046"
Private lAbortPrint := .F.
Private cArqDados 	:= ""
cCadastro := OemToAnsi(STR0001) //"Leitura do Arquivo de Retorno - Qualifica��o Cadastral"

Pergunte(cPerg,.F.)

AADD(aSays,OemToAnsi(STR0002) )	//Esta rotina faz a leitura do arquivo de retorno da Qualifica��o Cadastral


AADD(aButtons, { 5,.T.,{|| Pergunte("GPEM046",.T. ) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(),FechaBatch(),nOpcA:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

IF nOpcA == 1
	Processa({|lEnd| GPM46Proce(),STR0001})  //"Leitura do Arquivo de Retorno - Qualifica��o Cadastral"
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPM46Proce� Autor � Claudinei Soares    � Data � 16/10/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Leitura Arquivo de Retorno da Qualificacao Cadastral.      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function GPM46Proce()

Local cItem		:= " - "
Local cMsgErro   	:= ""
Local cLogGera	:= ""
Local cBuffer		:= ""
Local cCPF			:= ""	//Numero do CPF
Local cPIS			:= ""	//Numero do PIS
Local cPosNom		:= "" 	//Posicao do nome no arquivo
Local cNome		:= "" 	//Nome
Local cPosNascto	:= ""	//Posicao da data de nascimento
Local cNascto		:= ""	//Data de nascimento
Local cNISInv		:= ""	//NIS Invalido
Local cCPFInv		:= ""	//CPF Invalido
Local cNomeInv	:= ""	//Nome Invalido
Local cDtNasInv	:= ""	//Data Nascto Invalida
Local cNisIncon	:= ""	//NIS Inconsistente
Local cDtNasDCN	:= ""	//Data Nascto Diverge CNIS
Local cNISObto	:= ""	//NIS com Obito
Local cCPFdDCN	:= ""	//CPF diverge CNIS
Local cCPFnpDCN	:= ""	//CPF nao preenchido CNIS
Local cCPFncDCN	:= ""	//CPF nao cadastrado CNIS
Local cCPFNulo	:= ""	//CPF Nulo
Local cCPFcancel	:= ""	//CPF Cancelado
Local cCPFsuspen	:= ""	//CPF Suspenso
Local cCPFdtNasc	:= ""	//CPF Data Nascto divergente CPF
Local cCPFNome	:= ""	//CPF Nome diverge do informado no CPF
Local cCPFOrient	:= ""	//CPF Orientacao
Local cCNISOrien	:= ""	//CNIS Orientacao
Local nCount		:= 0
Local nTam			:= 0
Local nGera		:= 0
Local lPrimeira	:= .T.
Local aLogGera	:= {}
Local aLogProc	:= {}
Local nLin			:= 0

Private aTitle	:= {}
Private aLog		:= {}

//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
cArquivo	:=	AllTrim(mv_par01)		//-- Nome do Aquivo Texto

If !File(cArquivo)
	Help(" ",1,"A210NOPEN")
	Return
Endif

//������������������������������Ŀ
//� Abre arquivo texto informado �
//��������������������������������
FT_FUSE(cArquivo)

nCount := FT_FLastRec()

//��������������������������������������������������������������Ŀ
//� Carrega Regua Processamento	                                 �
//����������������������������������������������������������������
ProcRegua(nCount)

FT_FGOTOP()

Aadd(aTitle, OemToAnsi(STR0026)) //"Log de ocorr�ncias da leitura do arquivo de retorno - Qualifica��o Cadastral"
Aadd( aLogProc,{})

//��������������������������������������������������������������Ŀ
//� Inicia a leitura das linhas do arquivo de retorno            �
//����������������������������������������������������������������
While !FT_FEOF()
	cBuffer := FT_FREADLN()
	nLin++
	If Empty(cBuffer)
		FT_FSKIP()
		nLin++
		cBuffer := FT_FREADLN()
	EndIf

	cMsgErro := "" //Limpa variavel que armazena erros

	//��������������������������������������������������������������Ŀ
	//� Move Regua Processamento	                                 �
	//����������������������������������������������������������������
	IncProc(STR0001) //"Leitura do arquivo de Retorno - Qualifica��o Cadastral"

   //So grava a partir da segunda linha do arquivo, pois a primeira e so um cabecalho.
	If !(lPrimeira .OR. (nLin == nCount))

		//�����������������������������������������Ŀ
	    //� Faz a leitura dos campos no arquivo e a �
	    //� atribuicao nas variaveis para gravacao. �
	    //�������������������������������������������
		cCPF		:= Alltrim(SubStr( cBuffer,1,11))  					//Numero do CPF
		cPIS		:= Alltrim(SubStr( cBuffer,13,11))						//Numero do PIS
		cPosNom	:= AT(";",AllTrim(SubSTR(cBuffer,25,50))) 			//Posicao do nome no arquivo
		cNome		:= Alltrim(SubStr( cBuffer,25,cPosNom-1)) 			//Nome
		cPosNascto	:= AT(";",Alltrim(Substr(cBuffer,25,cPosNom)))+25	//Posicao da data de nascimento
		cNascto	:= Alltrim(SubStr( cBuffer,cPosNascto,8))				//Data de nascimento
		cNISInv	:= Alltrim(SubStr( cBuffer,cPosNascto+9,1))			//NIS Invalido
		cCPFInv	:= Alltrim(SubStr( cBuffer,cPosNascto+11,1))			//CPF Invalido
		cNomeInv	:= Alltrim(SubStr( cBuffer,cPosNascto+13,1))			//Nome Invalido
		cDtNasInv	:= Alltrim(SubStr( cBuffer,cPosNascto+15,1))			//Data Nascto Invalida
		cNisIncon	:= Alltrim(SubStr( cBuffer,cPosNascto+17,1))			//NIS Inconsistente
		cDtNasDCN	:= Alltrim(SubStr( cBuffer,cPosNascto+19,1))			//Data Nascto Diverge CNIS
		cNISObto	:= Alltrim(SubStr( cBuffer,cPosNascto+21,1))			//NIS com Obito
		cCPFdDCN	:= Alltrim(SubStr( cBuffer,cPosNascto+23,1))			//CPF diverge CNIS
		cCPFnpDCN	:= Alltrim(SubStr( cBuffer,cPosNascto+25,1))			//CPF nao preenchido CNIS
		cCPFncDCN	:= Alltrim(SubStr( cBuffer,cPosNascto+27,1))			//CPF nao cadastrado CNIS
		cCPFNulo	:= Alltrim(SubStr( cBuffer,cPosNascto+29,1))			//CPF Nulo
		cCPFcancel	:= Alltrim(SubStr( cBuffer,cPosNascto+31,1))			//CPF Cancelado
		cCPFsuspen	:= Alltrim(SubStr( cBuffer,cPosNascto+33,1))			//CPF Suspenso
		cCPFdtNasc	:= Alltrim(SubStr( cBuffer,cPosNascto+35,1))			//CPF Data Nascto divergente CPF
		cCPFNome	:= Alltrim(SubStr( cBuffer,cPosNascto+37,1))			//CPF Nome diverge do informado no CPF
		cCPFOrient	:= Alltrim(SubStr( cBuffer,cPosNascto+39,1))			//CPF Orientacao
		cCNISOrien	:= Alltrim(SubStr( cBuffer,cPosNascto+41,1))			//CNIS Orientacao

		//Se possuir algum registro com erro, grava a mensagem no log
		If (AT("1",AllTrim(SubSTR(cBuffer,cPosNascto+9,33))) > 0) .Or. (AT("2",AllTrim(SubSTR(cBuffer,cPosNascto+9,33))) > 0) .Or.;
			(AT("3",AllTrim(SubSTR(cBuffer,cPosNascto+9,33))) > 0)

			If cNISInv == "1"
				cMsgErro += cItem + OemToAnsi(STR0007)//"N�mero do PIS/NIS Inv�lido"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0007)) - Len(cItem))
			Endif

			If cCPFInv == "1"
				cMsgErro += cItem + OemToAnsi(STR0008)//"N�mero do CPF Inv�lido"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0008)) - Len(cItem))
			Endif

			If cNomeInv == "1"
				cMsgErro += cItem + OemToAnsi(STR0009)//"Nome Inv�lido"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0009)) - Len(cItem))
			Endif

			If cDtNasInv == "1"
				cMsgErro += cItem + OemToAnsi(STR0010)//"Data de Nascimento Inv�lida"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0010)) - Len(cItem))
			Endif

			If cNisIncon == "1"
				cMsgErro += cItem + OemToAnsi(STR0011)//"N�mero do PIS/NIS Inconsistente"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0011)) - Len(cItem))
			Endif

			If cDtNasDCN == "1"
				cMsgErro += cItem + OemToAnsi(STR0012)//"Data de nascimento informada diverge da existente no CNIS"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0012)) - Len(cItem))
			Endif

			If cNISObto == "1"
				cMsgErro += cItem + OemToAnsi(STR0013)//"N�mero do PIS/NIS com �bito no CNIS"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0013)) - Len(cItem))
			Endif

			If cCPFdDCN == "1"
				cMsgErro += cItem + OemToAnsi(STR0014)//"N�mero do CPF informado diverge do existente no CNIS"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0014)) - Len(cItem))
			Endif

			If cCPFnpDCN == "1"
				cMsgErro += cItem + OemToAnsi(STR0015)//"N�mero do CPF n�o preenchido no CNIS"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0015)) - Len(cItem))
			Endif

			If cCPFncDCN == "1"
				cMsgErro += cItem + OemToAnsi(STR0016)//"N�mero do CPF informado n�o consta no Cadastro CPF"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0016)) - Len(cItem))
			Endif

			If cCPFNulo == "1"
				cMsgErro += cItem + OemToAnsi(STR0017)//"N�mero do CPF informado est� NULO no Cadastro CPF"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0017)) - Len(cItem))
			Endif

			If cCPFcancel == "1"
				cMsgErro += cItem + OemToAnsi(STR0018)//"N�mero do CPF informado est� CANCELADO no Cadastro CPF"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0018)) - Len(cItem))
			Endif

			If cCPFsuspen == "1"
				cMsgErro += cItem + OemToAnsi(STR0019)//"N�mero do CPF informado est� SUSPENSO no Cadastro CPF"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0019)) - Len(cItem))
			Endif

			If cCPFdtNasc == "1"
				cMsgErro += cItem + OemToAnsi(STR0020)//"Data de nascimento informada diverge da existente no Cadastro CPF"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0020)) - Len(cItem))
			Endif

			If cCPFNome == "1"
				cMsgErro += cItem + OemToAnsi(STR0021)//"Nome informado diverge do existente no Cadastro CPF"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0021)) - Len(cItem))
			Endif

			If cCPFOrient == "1"
				cMsgErro += cItem + OemToAnsi(STR0022)//"Procurar conveniadas da RFB."
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0022)) - Len(cItem))
			Endif

			If cCNISOrien == "1"
				cMsgErro += cItem + OemToAnsi(STR0023)//"Atualizar PIS/NIS no INSS"
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0023)) - Len(cItem))
			ElseIf cCNISOrien == "2"
				cMsgErro += cItem + OemToAnsi(STR0024)//"Atualizar o Cadastro NIS em uma ag�ncia da CAIXA."
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0024)) - Len(cItem))
			ElseIf cCNISOrien == "3"
				cMsgErro += cItem + OemToAnsi(STR0025)//"Atualizar o Cadastro NIS em uma ag�ncia do Banco do Brasil."
				cMsgErro += space(TAMIMP - Len(OemToAnsi(STR0025)) - Len(cItem))
			Endif

			If !Empty(cMsgErro)

				cMsgAux := DToC(dDataBase) + " - " + cNome
				cMsgAux += space(TAMIMP - Len(cMsgAux))
		       cMsgAux += cMsgErro
				cMsgErro := cMsgAux

				//Tratamento para tamanho do Log
				If Len(cMsgErro) <= TAMIMP
					aAdd(aLogProc, cMsgErro)
				Else
					aAdd(aLogProc, Subs(cMsgErro, 1, TAMIMP))
					For nTam:= 1 to Int(Len(cMsgErro)/TAMIMP)
						aAdd(aLogProc, Subs(cMsgErro, TAMIMP * nTam + 1, TAMIMP))
					Next nTam
				EndIf
			EndIf
		Else
			 //Tratamento para funcionarios gerados no arquivo - LOG
 			cLogGera	:= 	DToC(dDataBase) + " - " + cNome

			//Tratamento para tamanho do Log de funcionarios gerados no arquivo.
 			If Len(cLogGera) <= TAMIMP
 				aAdd(aLogGera, cLogGera)
 			Else
 				aAdd(aLogGera, Subs(cLogGera, 1, TAMIMP))
 				aAdd(aLogGera, Subs(cLogGera, TAMIMP + 1, Len(cLogGera) - TAMIMP))
 			EndIf
		Endif
	Else
		lPrimeira := .F.
	Endif

	FT_FSKIP()

EndDo

//Se algum funcionario foi gerado no arquivo adiciona no log.
If Len(aLogGera) > 0
	Aadd( aLogProc,{})
	Aadd( aLogProc, OemToAnsi(STR0006))
	Aadd( aLogProc,{})
	For nGera = 1 to Len(aLogGera)
		aAdd(aLogProc,aLogGera[nGera])
	Next nGera
Endif

If Len(aLogProc) > 0 //Imprime Log
	fMakeLog({aLogProc}, aTitle, Nil, Nil, cPerg, OemToAnsi(STR0003), "M", "P",, .F.) //"Log de Ocorrencias do arquivo de retorno - Qualifica��o Cadastral"
Endif

FT_FUSE()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDirQual�Autor  � Claudinei Soares   � Data � 16/03/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � Usado no Pergunte para indicar o diretorio a ser gerado o  ���
���          � arquivo texto.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � GPEM046                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GetDirQual()

Local mvRet:=Alltrim(ReadVar())
Local cFile

oWnd   := GetWndDefault()
cFile 		:= cGetFile(OemToAnsi(STR0004),OemToAnsi(STR0005), ,,.T.,GETF_LOCALHARD + GETF_LOCALFLOPPY)  // "Arquivo Texto" "Selecione o arquivo "

If Empty(cFile)
	Return(.F.)
Endif

cDrive := Alltrim(Upper(cFile))

&mvRet := cFile

If oWnd != Nil
	GetdRefresh()
EndIf

Return( .T. )