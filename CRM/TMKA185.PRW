#Include "PROTHEUS.CH"
#Include "AP5MAIL.CH"
#Include "TMKA185.CH"



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKA185   �Autor  �Aldo Barbosa dos Santos    �  04/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de geracao automatica de titulos                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � P10                                                        ���
�������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������ĺ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMKA185(aParam)
// aParam[1] = Empresa
// aParam[2] = Filial Execucao
// aParam[3] = Filial De
// aParam[4] = Filial Ate
// aParam[5] = Gera Log (1 ou 2)

Local nCntFor

//��������������������������������������������������������������Ŀ
//� Definicao de variaveis para rotina automatica por schedule   �
//����������������������������������������������������������������
Private lTk180Auto := .T.

// Executa apenas se for chamado pelo Schedule
// a variavel abaixo e util para debug da rotina via execucao normal
Private lExecJob  := .F.
Private aMsgSch   := {}
Private cCadastro := STR0001 // "Geracao Automatica de titulos via Schedule"

ConOut("*** "+STR0003+" INICIO >> "+cCadastro+" "+Dtoc(Date())+" "+Time()) // "TMKA185" #

if Valtype(aParam) <> "A" 
	ConOut("*** "+STR0003+" "+STR0002) // "TMKA185" #"Processo pode ser executado apenas via Schedule"
	Return Nil
Endif

// ao passar parametros considera que foi chamado pelo schedule
lExecJob := .T.

// manter posicionado pois o FINA200 vai utilizar estas informacoes
if Valtype(aParam) == "A" 
	if Len(aParam) < 5 // erro nos parametros - processo interrompido
		ConOut("*** "+STR0003+" "+STR0004) // "TMKA185" #"Um ou mais parametros nao foram passados. Todos os parametros deste processo sao obritagorios"
		Return Nil
	Endif
	RpcSetEnv( aParam[1], aParam[2] )
Endif

BatchProcess(cCadastro, cCadastro , "TK185JOB" , { || Tk185Job(aParam[3],aParam[4],aParam[5]) } , { || .F. } )

// se o parametro nao esta definido, envia as mensagens para o console
If Empty(GetMv("MV_TMKMAIL",, "")) .and. Len(aMsgSch) > 0
	For nCntFor := 1 to Len(aMsgSch)
		ConOut(STR0003+" - "+aMsgSch[nCntFor])
	Next
EndIf

ConOut("*** "+STR0003+" FIM   >> "+cCadastro+Dtoc(Date())+" "+Time()) // "TMKA185" #

Return Nil


/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TK185JOB � Autor � Aldo Barbosa dos Santos� Data � 05/07/11 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Processo automatico de geracao de titulos							���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � TK185JOB()                                                  ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS                                          ���
��������������������������������������������������������������������������Ĵ��
���           	�  /  /  �      �                                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function TK185JOB(cFilDe, cFilAte, cGeraLog)

Private cArqLog := "" 			// controle do anexo (arquivo de Log)  

// controle de mensagens de erro
aMsgSch := {}

//ProcLogAtu("INICIO",STR0003+" "+STR0001) // "TMKA185" # "Geracao Automatica de titulos via Schedule"
      
// executa a consistencia antes de executar o recebimento
Tk180atu(.F.,@cArqLog,cFilDe,cFilAte,cGeraLog)
   
FA185MAIL(STR0001,aMsgSch,cArqLog) // "Geracao Automatica de titulos via Schedule"

//ProcLogAtu("FIM",STR0003+" "+STR0001) // "TMKA185" # "Geracao Automatica de titulos via Schedule"

Return Nil



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA185Mail � Autor � Aldo Barbosa dos Santos        �05/07/11���
�������������������������������������������������������������������������Ĵ��
���Descricao �Prepara os dados para envio de email 							  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function FA185MAIL(cTitulo, aMsgSch, cAttach)
Local aArea			:= GetArea()
Local lSendMail	:= .F.
Local nAux			:= 0
Local cSubject		:= ""
Local cBody			:= ""
Local	cMsgErr     := ""
Local aDestE		:= {}
Local cDestE      := GetMv("MV_TMKMAIL",, "") // destinatarios do email de geracao de titulos automatico via schedule
Local lFA185MAIL  := ExistBlock('TK185MAIL')  // ponto de entrada que permite ajustar envio de email
Local aFA185MAIL  := {}

Default cAttach   := "TMKSK1INCON.LOG"
Default cTitulo   := STR0001 // "Geracao Automatica de titulos via Schedule"

// se o parametro de destinatarios de envio de email estiver vazio ignora o envio
If ValType(cDestE) <> "C" .or. Empty(cDestE)
	Return Nil
EndIf

aDestE := StrTokArr(cDestE,";")
If Len(aDestE) == 0
	Return Nil
EndIf

cSubject	:= cTitulo + '  Processamento: ' +Dtoc(dDataBase) + ' - ' + Time()

// corpo principal do email com o resumo do emvio
cBody	:= '<HTML>'
cBody	+= ' <HEAD>'
cBody	+= '  <TITLE>'+cTitulo+'</TITLE>'
cBody	+= ' </HEAD>'
cBody	+= ' <BODY>'
cBody	+= '  <H1>'
cBody	+= '   <FONT SIZE="4" COLOR="#000099">'
cBody	+= '    <B>'+cTitulo+'</B>'
cBody	+= '   </FONT>'
cBody	+= '  </H1>'
cBody += '  <BR>
cBody	+= '  <H1><HR></H1>'

// adiciona as mensagens contidas no vetor
If Len(aMsgSch) >= 0
	cBody	+= '  <H1>'
	cBody	+= '   <FONT SIZE="3" COLOR="#000000">'
	cBody	+= '    Mensagens do Processamento : '
	cBody	+= '   </FONT>'
	cBody	+= '  </H1>'

	//������������������Ŀ
	//�MONTAGEM DO E-MAIL�
	//��������������������
	if Len(aMsgSch) == 0
		cBody += '<BR>&nbsp;&nbsp;-&nbsp;Processamento sem inconsistencias'
	Else
		For nAux := 1 To Len(aMsgSch)
			cBody += '<BR>&nbsp;&nbsp;-&nbsp;' + aMsgSch[nAux]
		Next
	Endif	
	cBody	+= '  <H1><HR></H1>'
EndIf

cBody	+= '  <H1>'
cBody	+= '   <FONT SIZE="2" COLOR="#FF0000">'
cBody	+= '    '+cSubject
cBody	+= '   </FONT>'
cBody	+= '  </H1>'
cBody	+= ' </BODY>'
cBody	+= '</HTML>'

//���������������������������������������������������Ŀ
//�PONTO DE ENTRADA PARA MANIPULAR A MENSAGEM         �
//�����������������������������������������������������
if lFA185MAIL
	aFA185MAIL := ExecBlock('FA185MAIL',.F.,.F.,{cSubject,cBody,aDestE,aMsgSch})
	If ValType(aFA185MAIL ) == 'A'
		If ValType(aFA185MAIL[1]) == 'C'
			cSubject := aFA185MAIL[1]  			// assunto
		EndIf
		If ValType(aFA185MAIL[2]) == 'C'
			cBody  	:= aFA185MAIL[2]  			// corpo do email
		EndIf
		If ValType(aFA185MAIL[3]) == 'A'
			aDestE	:= aClone(aFA185MAIL[3])  // destinatarios
		EndIf
		If ValType(aFA185MAIL[4]) == 'A'
			aMsgSch := aClone(aFA185MAIL[4])		// mensagens de erro
		EndIf
	EndIf
Endif

// se nao tem assunto, ou corpo, ou destinatario - nao envia email para nao dar erro
If ! Empty(cSubject) .and. !Empty(cBody) .and. !Empty(aDestE)
	if ! File(cAttach)
		cAttach := ""
	Endif
		
	lSendMail 	:= FA185SENDMAIL( aDestE, cSubject, cBody, cAttach )

  	If !lSendMail .And. !Empty(cMsgErr)
  		ConOut(STR0003+" - "+cMsgErr)  //-- TMKA185 # Ocorreu um problema no envio do e-mail:
  	EndIf
EndIf

RestArea(aArea)

Return Nil



/*�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Programa  �FA185SENDMAIL �Autor  � Aldo Barbosa dos Santos  � Data � 05/07/2011  ���
�����������������������������������������������������������������������������������͹��
���Desc.     �Rotina de envio de e-mail                                             ���
���          �                                                                      ���
�����������������������������������������������������������������������������������͹��
���Uso       � TMKA185                                                              ���
�����������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
Static Function FA185SendMail( aDest, cAssunto, cMensagem, cAttach )

Local aArea     := GetArea()
Local cEmailTo  := ""								// E-mail de destino
Local cEmailBcc := ""								// E-mail de copia
Local lResult   := .F.								// Se a conexao com o SMPT esta ok
Local cError    := ""								// String de erro
Local lRelauth  := SuperGetMv("MV_RELAUTH",, .F.)	// Parametro que indica se existe autenticacao no e-mail
Local lRet	    := .F.								// Se tem autorizacao para o envio de e-mail
Local cCtaAut   := Trim(GetMV('MV_RELAUSR')) 		// usuario para Autenticacao Ex.: fuladetal
Local cConta    := Trim(GetMV('MV_RELACNT')) 		// Conta Autenticacao Ex.: fuladetal@fulano.com.br
Local cPsw      := Trim(GetMV('MV_RELAPSW')) 		// Senha de acesso Ex.: 123abc
Local cServer   := Trim(GetMV('MV_RELSERV')) 		// Ex.: smtp.ig.com.br ou 200.181.100.51
Local cFrom	    := Trim(GetMV('MV_RELFROM')) 		// e-mail utilizado no campo From'MV_RELACNT' ou 'MV_RELFROM' e 'MV_RELPSW'
Local nCntFor

Default cAttach := ""  

// remonta os destinatarios utilizando o vetor
cEmail := ""
For nCntFor := 1 To Len(aDest)
	If !Empty(cEmail)
		cEmail += ';'
	EndIf
	cEmail += aDest[nCntFor]
Next

//�����������������������������������������������������������������������������Ŀ
//�Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense�
//�que somente ela recebeu aquele email, tornando o email mais personalizado.   �
//�������������������������������������������������������������������������������
cEmailTo := cEmail

CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cPsw RESULT lResult

// Se a conexao com o SMPT esta ok
If lResult
	
	// Se existe autenticacao para envio valida pela funcao MAILAUTH
	If lRelauth
		lRet := Mailauth( cCtaAut, cPsw )
	Else
		lRet := .T.
	Endif
	
	If lRet
		SEND MAIL; 
		FROM 		cFrom;
		TO      	cEmailTo;
		BCC     	cEmailBcc;
		SUBJECT 	cAssunto;
		BODY    	cMensagem;
		ATTACHMENT  cAttach  ;
		RESULT 		lResult
		
		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			If !IsBlind()
				Help( " ", 1, STR0003+" - 01 " + STR0008, , cError + " " + cEmailTo, 4, 5 )  // "Atencao"
			Else
				ApMsgInfo( STR0003+" - 01 " + STR0008 + " " + cError + " " + cEmailTo )  // "Atencao"
			EndIf
		Endif
		
	Else
		GET MAIL ERROR cError
		If !IsBlind()
			Help( " ", 1, STR0003+" - 02 " + STR0005, , cError, 4, 5 ) // "Autenticacao"
		Else
			ApMsgStop( STR0003+" - 02 " + STR0006, STR0007 ) // "Erro de Autenticacao" # "Verifique a conta e a senha para envio."
		EndIf
	Endif
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	If !IsBlind()
		Help( " ", 1, STR0003+" - 03 " + STR0008, , cError, 4, 5 )  // "Atencao"
	Else
		ApMsgInfo( STR0003+" - 03 " + STR0008 + " " + cError )  // "Atencao"
	EndIf
Endif
 
RestArea( aArea )

Return( lResult )
