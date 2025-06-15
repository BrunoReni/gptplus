#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA0045.CH"
#INCLUDE "AUTODEF.CH" 

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA0045() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCFileServerConfiguration        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe com os dados de configura��o do servidor de arquivos do loja.   ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCFileServerConfiguration From FWSerialize
	
	Data cPath
	Data cFileServerURL
	Data cHTTPPort
	Data cHTTPEnvironment
	Data cFSLocation
	Data lValidate
	Data lValHTTPSession
	Data lValHTTPJobResponse
	Data lValLJFileServerSession
	
	
	Method New()
	Method Initialize()
	
	Method SetUpFileServer()
	Method TestConnection()
	
	//Setters - definem os dados na inicializacao (para garantir que as funcoes que lerao os inis pegarao do ambiente certo)
	Method SetPath()
	Method CreatePath()
	Method SetFileServerURL()
	Method SetHTTPPort()
	Method SetHTTPEnvironment()
	Method SetFSLocation()
	Method SetValidate()	
	Method SetVHTTPSession()
	Method SetVHTTPJobResponse()
	Method SetVLJFileServerSession()
	
	//Getters
	Method GetPath()
	Method GetFileServerURL()
	Method GetHTTPPort()
	Method GetHTTPEnvironment()
	Method GetFSLocation()
	Method Validate()	
	Method ValidHTTPSession()
	Method ValidHTTPJobResponse()
	Method ValidLJFileServerSession()
	
EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor.                                                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New(lInitialize) Class LJCFileServerConfiguration
Default lInitialize := .T.

If lInitialize
	Self:Initialize()
Else
	Self:SetPath()
EndIf

Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Initialize                        � Autor: Vendas CRM � Data: 31/05/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Inicializa os dados buscando configuracoes do ini                      ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Initialize() Class LJCFileServerConfiguration

	Self:SetPath()
	Self:SetFileServerURL()
	Self:SetHTTPPort()
	Self:SetHTTPEnvironment()
	Self:SetFSLocation()
	
	Self:SetVHTTPSession()
	Self:SetVHTTPJobResponse()
	Self:SetVLJFileServerSession()	
	
	Self:SetValidate()	
	
	
Return


/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetFileServerURL                  � Autor: Vendas CRM � Data: 31/05/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Define o endere�o do servidor de arquivo, baseado nas configura��es    ���
���             � HTTP do servidor protheus e configura��es de INI.                      ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetFileServerURL() Class LJCFileServerConfiguration
	Local cTemp				:= ""
	Local lEnable			:= .F.
	Local cPort				:= ""
	Local cIP				:= ""
	Local cURL				:= ""	
	Local oLJCMessageManager := GetLJCMessageManager()

		
	cTemp := GetPvProfString("HTTP","Enable","",GetAdv97())
	
	If cTemp != "1"
	
		//Tratamento para se n�o tiver configura��o de http procurar no grupo "LJFileServer"
		//Isso evita erro em ambientes com balanceamento de carga ativa. onde o usuario devera 
		//preencher com os dados do servidor de cargas
		cTemp := GetPvProfString("LJFileServer","Port","",GetAdv97())
		If IsDigit( cTemp )
			lEnable := .T.
		Else
			oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadConfigurationHTTPNotEnable", 1, STR0001 ) ) // "Servidor HTTP n�o configurado."			
		EndIf
	
	Else
		lEnable := .T.
	EndIf
	
	If !oLJCMessageManager:HasError()
		
		//Caso tenha um parametro de porta especifico para a carga sobreescreve a do HTTP, pois posso usar balance e a porta
		// do HTTP ficar no balance server, ou seja, vai ser diferente no SLAVE a verdadeira porta HTTP
		cTemp := GetPvProfString("LJFileServer","Port","",GetAdv97()) 
		
		If IsDigit( cTemp ) 	
			cPort := cTemp
		Else
			cTemp := GetPvProfString("HTTP","Port","",GetAdv97())

			If IsDigit( cTemp )
				cPort := cTemp
			EndIf	
		EndIf
		
		If Empty(cPort)
			oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadConfigurationHTTPInvalidPort", 1, STR0002 ) ) // "Porta do servidor HTTP n�o configurada."
		EndIf
	
		If !oLJCMessageManager:HasError()
		
			cTemp := GetPvProfString("LJFileServer","Location","",GetAdv97())
		
		
			If Empty(cTemp)
				oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadConfigurationHTTPInvalidLocation", 1, STR0003 ) ) // "IP ou nome da m�quina do servidor HTTP n�o configurado."
			Else
				cIP := cTemp
			EndIf
			
			If !oLJCMessageManager:HasError()
				cURL := "HTTP://" + cIP + If("80" <> cPort, ":" + cPort, "") + "/ljfileserver/" + "w_LJFileServer.apw"
				If GetRemoteType() == REMOTE_LINUX
					cURL := StrTran(cURL,"/", "\")	
				EndIf
			EndIf
		EndIf
	EndIf
	
	Self:cFileServerURL := cURL
	
Return 

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetPath                           � Autor: Vendas CRM � Data: 31/05/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Define o caminho de armazenamento do servidor de arquivos.             ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetPath() Class LJCFileServerConfiguration	
	Self:cPath := GetPvProfString("LJFileServer","Path","\LJFileServer\",GetAdv97())
	Self:CreatePath()
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � CreatePath                           � Autor: Vendas CRM � Data: 31/05/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Se n�o existir, cria o path raiz das cargas             ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method CreatePath() Class LJCFileServerConfiguration	

Local oLJCMessageManager	:= GetLJCMessageManager()	

Self:cPath := If( Right( Self:cPath,1) != If( IsSrvUnix(), "/", "\" ) , Self:cPath += If( IsSrvUnix(), "/", "\" ) , Self:cPath )
If !ExistDir( Self:cPath )
	If MakeDir( Self:cPath ) != 0
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCFileServerConfigurationIOMessage", 1, "N�o foi poss�vel criar o diret�rio '" + Self:cPath + "'.") ) // ATUSX //"N�o foi poss�vel criar o diret�rio"
	EndIf
EndIf		

Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetValidate                       � Autor: Vendas CRM � Data: 31/05/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Define se as configura��es necess�rias para o funcionamento            ���
���             � do servidor de arquivos sao validas.                                   ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetValidate() Class LJCFileServerConfiguration
	Local lValid				:= .T.

	// Valida sess�o HTTP
	lValid := If( !Self:ValidHTTPSession() , .F., lValid )
	
	// Valida sess�o do JOB_RESPONSE
	lValid := If( !Self:ValidHTTPJobResponse() , .F., lValid )
	
	// Valida sess�o do servidor de arquivos		
	lValid := If( !Self:ValidLJFileServerSession() , .F., lValid )	
	
	Self:lValidate := lValid
	
Return 

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetVHTTPSession                   � Autor: Vendas CRM � Data: 31/05/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Define se a configura��o da sess�o HTTP do servidor protheus eh valida.���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetVHTTPSession() Class LJCFileServerConfiguration	
	Self:lValHTTPSession := aScan( GetINISessions(GetAdv97()), {|x| Upper(x) == "HTTP" } ) > 0
Return 


/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetVHTTPJobResponse               � Autor: Vendas CRM � Data: 31/05/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Define se a sess�o JobResponse do servidor HTTP do protheus eh valida. ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetVHTTPJobResponse() Class LJCFileServerConfiguration
	Local cJobName	:= ""
	Local cType		:= ""
	Local lValid	:= .F.	

	If Self:ValidHTTPSession()
		cJobName := GetPvProfString(AllTrim(Self:GetFSLocation()) + ":" + AllTrim(Self:GetHTTPPort()) + "/ljfileserver","RESPONSEJOB","",GetAdv97())
		
		If !Empty( cJobName )
			cType := GetPvProfString("JOB_LJFILESERVER","TYPE","",GetAdv97())
			If !Empty( cType )
				lValid := .T.
			EndIf
		EndIf
	EndIf
	
 	Self:lValHTTPJobResponse := lValid
 	
Return
	
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetVLJFileServerSession           � Autor: Vendas CRM � Data: 31/05/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Define se a sessao do servidor de arquivos do loja eh valida.          ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetVLJFileServerSession() Class LJCFileServerConfiguration
	Self:lValLJFileServerSession := aScan( GetINISessions(GetAdv97()), {|x| Upper(x) == Upper("LJFileServer") } ) > 0
Return 
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetHTTPPort                       � Autor: Vendas CRM � Data: 31/05/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Define a porta do servidor HTTP configurada no protheus.               ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetHTTPPort() Class LJCFileServerConfiguration	
	Self:cHTTPPort := GetPvProfString("HTTP","Port","",GetAdv97())
Return
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetHTTPEnvironment                � Autor: Vendas CRM � Data: 31/05/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Define o ambiente onde o servidor HTTP � executado.                    ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetHTTPEnvironment() Class LJCFileServerConfiguration
	Self:cHTTPEnvironment := GetPvProfString("JOB_LJFILESERVER","Environment","",GetAdv97())
Return
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetUpHTTP                         � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Efetua a configura��o no protheus do servidor HTTP.                    ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � nPort: Porta da configura��o.                                          ���
���             � cEnvironment: Ambiente da configura��o.                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetUpFileServer( cIP, nPort, cEnvironment, cRepository ) Class LJCFileServerConfiguration
	// Configura a sess�o HTTP se ela n�o existir
	WritePProString( "HTTP", "Enable"		, "1"					, GetAdv97() )
	WritePProString( "HTTP", "Port"			, AllTrim(Str(nPort))	, GetAdv97() )	
	WritePProString( "HTTP", "InstanceName"	, "HTTP Instance"		, GetAdv97() )
	
	// Configura o endere�o do servidor de arquivos se ele n�o existir
	WritePProString( AllTrim(cIP) + ":" + AllTrim(Str(nPort)) + "/ljfileserver", "Enable"	   		, "1"							, GetAdv97() )
	WritePProString( AllTrim(cIP) + ":" + AllTrim(Str(nPort)) + "/ljfileserver", "InstanceName"	, "File Server HTTP Instance"	, GetAdv97() )	
	WritePProString( AllTrim(cIP) + ":" + AllTrim(Str(nPort)) + "/ljfileserver", "ResponseJob"		, "JOB_LJFILESERVER"			, GetAdv97() )		                                                     
	
	// Configura o response job do HTTP se ele n�o existir
	WritePProString( "JOB_LJFILESERVER", "Type"			, "WEBEX"			, GetAdv97() )
	WritePProString( "JOB_LJFILESERVER", "Environment"	, cEnvironment		, GetAdv97() )
	WritePProString( "JOB_LJFILESERVER", "InstanceName"	, "File Server Job"	, GetAdv97() )
	WritePProString( "JOB_LJFILESERVER", "OnStart"		, "STARTWEBEX"		, GetAdv97() )			
	WritePProString( "JOB_LJFILESERVER", "OnConnect"	, "CONNECTWEBEX"	, GetAdv97() )						
	WritePProString( "JOB_LJFILESERVER", "OnExit"		, "FINISHWEBEX"		, GetAdv97() )									
	
	// Configura a sess�o do servidor de arquivos do loja
	WritePProString( "LJFileServer", "Location"		, cIP					, GetAdv97() )
	WritePProString( "LJFileServer", "Port"			, AllTrim(Str(nPort))	, GetAdv97() )
	If cRepository != Nil .And. !Empty( cRepository )
		WritePProString( "LJFileServer", "Path"		, cRepository	, GetAdv97() )
	EndIf	
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetFSLocation                     � Autor: Vendas CRM � Data: 31/05/12 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Define o endere�o IP ou nome da m�quina que responder� pelas           ���
���             � solicita��es HTTP para o servidor de arquivos do loja.                 ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetFSLocation() Class LJCFileServerConfiguration	
	Self:cFSLocation := GetPvProfString("LJFileServer","Location","",GetAdv97())
Return




/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetFileServerURL                  � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Retorna o endere�o do servidor de arquivo, baseado nas configura��es   ���
���             � HTTP do servidor protheus e configura��es de INI.                      ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cURL: Endere�o do servidor de arquivos do loja.                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetFileServerURL() Class LJCFileServerConfiguration
Return Self:cFileServerURL

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetPath                           � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Retorna o caminho de armazenamento do servidor de arquivos.            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cRet: Caminho de armazenamento.                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetPath() Class LJCFileServerConfiguration	
Return Self:cPath

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Validade                          � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Efetua a valida��o das configura��es necess�rias para o funcionamento  ���
���             � do servidor de arquivos.                                               ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lValid: .T. se est� configurado corretamente, .F. se n�o.              ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Validate() Class LJCFileServerConfiguration
Return Self:lValidate
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ValidHTTPSession                  � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Valida a configura��o da sess�o HTTP do servidor protheus.             ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lRet: .T. Se a sess�o est� configurada, .F. se n�o.                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ValidHTTPSession() Class LJCFileServerConfiguration	
Return Self:lValHTTPSession

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ValidHTTPJobResponse              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Valida a sess�o JobResponse do servidor HTTP do protheus.              ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lValid: .T. se a sess�o est� configurada, .F. se n�o.                  ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ValidHTTPJobResponse() Class LJCFileServerConfiguration
Return Self:lValHTTPJobResponse

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ValidLJFileServerSession          � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Valida a sess�o do servidor de arquivos do loja.                       ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lRet: .T. se a est� configurado, .F. se n�o.                           ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ValidLJFileServerSession() Class LJCFileServerConfiguration
Return Self:lValLJFileServerSession

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetHTTPPort                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega a porta do servidor HTTP configurada no protheus.                 ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cRet: A porta configurada.                                             ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetHTTPPort() Class LJCFileServerConfiguration	
Return Self:cHTTPPort

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetHTTPEnvironment                � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o ambiente onde o servidor HTTP � executado.                      ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cRet: Nome do ambiente.                                                ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetHTTPEnvironment() Class LJCFileServerConfiguration
Return Self:cHTTPEnvironment

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetFSLocation                     � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Retorna o endere�o IP ou nome da m�quina que responder� pelas          ���
���             � solicita��es HTTP para o servidor de arquivos do loja.                 ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cRet: Endere�o IP ou nome da m�quina.                                  ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetFSLocation() Class LJCFileServerConfiguration	
Return Self:cFSLocation

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � TestConnection                    � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Testa a conex�o com o servidor de arquivos do loja.                    ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lSuccess: .T. se foi poss�vel conectar, .F. se n�o.                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method TestConnection() Class LJCFileServerConfiguration                               
	Local oLJCMessageManager				:= GetLJCMessageManager()
	Local oLJCFileDownloaderComunication	:= LJCFileDownloaderComunicationHTTP():New( Self:GetFileServerURL() )		
	Local lSuccess							:= .T.
	
	oLJCFileDownloaderComunication:Connect()
	
	If oLJCMessageManager:HasError()
		lSuccess := .F.
		oLJCMessageManager:Clear()
	EndIf		
Return lSuccess

