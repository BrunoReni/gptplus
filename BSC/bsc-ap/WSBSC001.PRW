#Include "APWEBSRV.CH"
#include "WSBSC001.CH"

WSService SigaBSC description STR0001 //NAMESPACE "http://webservices.microsiga.com.br/wsclient_sigaBSC.apw"
//"Ferramenta para administra��o e uso de <i>BSC</i>. Permitindo acessar percentual concluido das tarefas e indicadores do BSC por usuario."
  WSData SESSIONID 		as String
  WSData USUARIO   		as String
  WSData SENHA    		as String
  WSData USERLOGIN		as String
  WSData DATEFROM  		as Date
  WSData DATEUNTIL		as Date
  WSData UserTaksPosicion As UserTaksPosicion
  WSData UserIndicatorPosicion As UserIndicatorPosicion

  WSMETHOD GetTaskGrades description STR0003 //"M�todo de listagem do percentual atingido nas tarefas por usuario/pessoa"
  WSMETHOD GetIndGrades	 description STR0004 //"M�todo de listagem do percentual atingido nos indicadores por usuario/pessoa"

EndWSService

//������������������������������������������������������������������������Ŀ
//�Estrutura de Perncentual Atingo em tarefas e indicadores por usuario    �
//��������������������������������������������������������������������������
WSSTRUCT UserTaksPosicion
	WSDATA UserID					AS String           //ID da Pessoa/usuario
	WSDATA UserName					AS String OPTIONAL  //Nome da pessoa/usuario
	WSDATA DateFrom					AS Date   OPTIONAL  //Data inicial
	WSDATA DateTo					AS Date   OPTIONAL  //Data Final
	WSDATA Grade					As Float  OPTIONAL  //Percentual atingido das tarefas
	//WSDATA ListOfTasks				AS Array Of Tasks OPTIONAL //Tarefas do usuario/pessoa
ENDWSSTRUCT

WSSTRUCT Tasks
	WSDATA TaskID	      			As String               //Codigo Questao
	WSDATA TaskDescription			As String OPTIONAL      //Enunciado da Questao
	WSDATA Grade     				As Float  OPTIONAL      //Pontos da questao
ENDWSSTRUCT

WSSTRUCT UserIndicatorPosicion
	WSDATA UserID					AS String           //ID da Pessoa/usuario
	WSDATA UserName					AS String OPTIONAL  //Nome da pessoa/usuario
	WSDATA DateFrom					AS Date   OPTIONAL  //Data inicial
	WSDATA DateTo					AS Date   OPTIONAL  //Data Final
	WSDATA Grade					As Float  OPTIONAL  //Percentual atingido das tarefas
	//WSDATA ListOfTasks				AS Array Of Tasks OPTIONAL //Tarefas do usuario/pessoa
ENDWSSTRUCT

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �GetTaskGrades �Autor �Aline Correa do Vale� Data �01.08.2006 ���
��������������������������������������������������������������������������Ĵ��
���          �Metodo de recuperacao dos percentuais atingidos nas tarefas  ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo do usuario                                     ���
���          �ExpC2: Codigo do Pessoa no BSC                               ���
���          �ExpD3: Data de Inicio                                        ���
���          �ExpD4: Data Final                                            ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica que o metodo foi avaliado com sucesso          ���
��������������������������������������������������������������������������Ĵ��
���Uso       �BSC/RH/Portais                                               ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
//WSMETHOD GetTasksGrades WSRECEIVE HOST,UserLogin,USERPASSWORD,DateFrom, DATEUNTIL, QueryAddWhere,PageLen, PageLoad WSSEND UserTaksPosicion WSSERVICE SigaBsc
WSMETHOD GetTaskGrades WSRECEIVE UserLogin,DateFrom, DATEUNTIL WSSEND UserTaksPosicion WSSERVICE SigaBsc

local cSession := ""
Local lRetorno	:= .T.

//If PrtChkUser(::UserCode,"SigaBsc","GetTasksGrades")
if(!empty(UserLogin))
	//Abrir conexao com o BSC
	//Localizar em Usuarios se o � o Usuario Protheus e identificar a quais pessoas esta associado aos usuarios
	//Localizar tarefas que contenha as pessoas em Pessoas em Cobranca
	
	::SessionID := cBIMakeKey("SIGABSC")
	oBSCCore := TBSCCore():New()
	//oBSCCore:fcBscPath := "\"
	cSession := BSCXMLSession()
	BscWebStart()
	oTarefas := oBscCore:oGetTable("TAREFA")
	aGrades := oTarefas:aCompletado(USERLOGIN, DATEFROM, DATEUNTIL)
	
	UserTaksPosicion:UserID :=	UserLogin //ID da Pessoa/usuario
	UserTaksPosicion:UserName := ""
	UserTaksPosicion:DateFrom := dateFrom
	UserTaksPosicion:DateTo := DATEUNTIL
	UserTaksPosicion:Grade := aGrades[1]

/*	::UserTasks := {}
	aadd(::UserTasks,WsClassNew('Tasks'))

	for ni:=1 to len(aGrades)
		aadd(::UserTasks,WsClassNew('Tasks'))
		::UserTasks:TaskID := aGrades[ni][1] //TaskID
		::UserTasks:TaskDescription := aGrades[ni][2] //TaskDescription
		::UserTasks:Grade := aGrades[ni][3] //Grade
	next*/
Else
	lRetorno := .F.
	SetSoapFault("GETTASKSGRADE",STR0005) //"Usuario invalido"
EndIf

Return(lRetorno)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �GetTaskGrades �Autor �Aline Correa do Vale� Data �04.09.2006 ���
��������������������������������������������������������������������������Ĵ��
���          �Metodo de retorno dos percentuais atingidos dos indicadores  ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo do usuario                                     ���
���          �ExpC2: Codigo do Pessoa no BSC                               ���
���          �ExpD3: Data de Inicio                                        ���
���          �ExpD4: Data Final                                            ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica que o metodo foi avaliado com sucesso          ���
��������������������������������������������������������������������������Ĵ��
���Uso       �BSC/RH/Portais                                               ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
WSMETHOD GetIndGrades WSRECEIVE UserLogin, Senha, DateFrom, DATEUNTIL WSSEND UserIndicatorPosicion WSSERVICE SigaBsc

local cSession := ""
Local lRetorno	:= .T.

if(!empty(UserLogin))
	//::SessionID := cBIMakeKey("SIGABSC")
	oBSCCore := TBSCCore():New()
	cSession := BSCXMLSession()
	BscWebStart()
	cSession := oBSCCore:nLogin(USERLOGIN, SENHA, cSession)
	oBSCCore:nLogin(USERLOGIN, SENHA, cSession )
	oIndicador := oBscCore:oGetTable("INDICADOR")
	aGrades := oIndicador:aCompletado(USERLOGIN, DATEFROM, DATEUNTIL)
	
	UserIndicatorPosicion:UserID :=	UserLogin //ID da Pessoa/usuario
	UserIndicatorPosicion:UserName := ""
	UserIndicatorPosicion:DateFrom := dateFrom
	UserIndicatorPosicion:DateTo := DATEUNTIL
	UserIndicatorPosicion:Grade := aGrades[1]

Else
	lRetorno := .F.
	SetSoapFault("GETINDICATORGRADE", STR0005) //"Usuario invalido"
EndIf

Return(lRetorno)
