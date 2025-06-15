#INCLUDE "PROTHEUS.CH"  
#INCLUDE "LOJA0042.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA0042() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCFileDownloaderComunicationHTTP � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Implementa��o do baixador de arquivos por HTTP.                        ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCFileDownloaderComunicationHTTP From LJAFileDownloaderComunication
	Data cReceiverFunction
	Data cLoadCode
	Data nExtFile
	
	Method New()
	Method Connect()
	Method Disconnect()
	Method FileExist()	
	Method GetTotalBytes()
	Method GetPart()
	Method GetMD5()
EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor                                                             ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cReceiverFunction: Endere�o da web function que serve o arquivo.       ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New( cReceiverFunction , cLoadCode) Class LJCFileDownloaderComunicationHTTP
	Self:cReceiverFunction 	:= cReceiverFunction
	Self:cLoadCode 			:= cLoadCode
	Self:nExtFile			:= SuperGetMV("MV_LJTFILE",.F.,0)
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Connect                           � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Testa a conex�o com a web function que serve o arquivo.                ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lConnect: .T. sucesso, .F. falha.                                      ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Connect() Class LJCFileDownloaderComunicationHTTP
	Local lConnect			:= .F.
	Local uData				:= Nil
	Local cHeadRet			:= ""
	Local oLJCMessageManager := GetLJCMessageManager()	
	
	uData := HTTPPost( Self:cReceiverFunction, "action=connecttest",,,, @cHeadRet)
	
	If HTTPGetStatus() != 200 
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "HTTPPostError", 1, cHeadRet ) )	
	ElseIf uData == Nil .Or. !IsDigit( uData )
		oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCFileDownloaderComunicationHTTPWrongResponse", 1, STR0001 + " " + cValToChar(uData) ) ) // "Resposta n�o esperada do servidor:"
	Else
		If Val( uData ) == 1111
			lConnect := .T.
		EndIf
	EndIf
Return lConnect

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Disconnect                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Como comunica��o via web function n�o necessita de desconex�o, esse    ���
���             � m�todo n�o possui funcionalidade.                                      ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Disconnect() Class LJCFileDownloaderComunicationHTTP
Return Nil 

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � FileExist                         � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Verifica se o arquivo passado por par�metro est� dispon�vel para ser   ���
���             � baixado.                                                               ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cFileName: Nome do arquivo.                                            ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lFileExist: Se o arquivo existe ou n�o.                                ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method FileExist( cFileName ) Class LJCFileDownloaderComunicationHTTP
	Local lFileExist		:= .F.
	Local uData				:= Nil
	Local oLJCMessageManager := GetLJCMessageManager()
	Local cHeadRet			:= ""
	                                                            
	uData := HTTPPost( Self:cReceiverFunction, "action=fileexist&filename=" + Escape(Self:cLoadCode + "\" + cFileName),,,,@cHeadRet )
	
	If HTTPGetStatus() != 200
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "HTTPPostError", 1, cHeadRet ) )	
	ElseIf ValType(uData) == "C" .And. IsDigit( uData )
		If Val(uData) == 1111
			lFileExist := .T.
		EndIf
	Else  
		If Self:nExtFile <> 1
			oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCFileDownloaderComunicationHTTPWrongResponse", 1, STR0001 + " " + cValToChar(uData) ) ) // "Resposta n�o esperada do servidor:"
		EndIf
	EndIf	
Return lFileExist

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetTotalBytes                     � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o tamanho total do arquivo.                                       ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cFileName: Nome do arquivo.                                            ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � nTotalSize: Tamanho do arquivo em bytes.                               ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetTotalBytes( cFileName ) Class LJCFileDownloaderComunicationHTTP
	Local nTotalSize		:= 0
	Local uData				:= Nil	
	Local cHeadRet			:= ""
	Local cErro				:= ""
	Local nStatusHttp			:= 0
	Local oLJCMessageManager := GetLJCMessageManager()
	
	uData := HTTPPost( Self:cReceiverFunction, "action=gettotalbytes&filename=" + Escape(Self:cLoadCode + "\" + cFileName),,,,@cHeadRet )
	
	nStatusHttp := HTTPGetStatus(@cErro) 
	If nStatusHttp != 200
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "HTTPPostError", 1, cValtoChar(nStatusHttp) + " - " + cErro ) )	
	ElseIf !(ValType(uData) == "C" .And. IsDigit( uData )) 
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCFileDownloaderComunicationHTTPWrongResponse", 1, STR0001 + " " + cValToChar(uData) ) ) // "Resposta n�o esperada do servidor:"
	Else
		nTotalSize := Val(uData)
	EndIf
Return nTotalSize

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetPart                           � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Baixa uma por��o do arquivo.                                           ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cFileName: Nome do arquivo.                                            ���
���             � nStartByte: Parte inicial.                                             ���
���             � nSize: Tamanho a ser baixado.                                          ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � uData: Dados baixados de tamanho passado por par�metro.                ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetPart( cFileName, nStartByte, nSize ) Class LJCFileDownloaderComunicationHTTP
	Local uData				:= Nil
	Local cHeadRet			:= ""
	Local oLJCMessageManager := GetLJCMessageManager()	
	
	uData := HTTPPost( Self:cReceiverFunction, "action=getpart&startbyte=" + AllTrim(Str(nStartByte)) + "&size=" + AllTrim(Str(nSize)) + "&filename=" + Escape(Self:cLoadCode + "\" + cFileName),,,,@cHeadRet )

	If HTTPGetStatus() != 200 
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "HTTPPostError", 1, cHeadRet ) )
	ElseIf uData == Nil		
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCFileDownloaderComunicationHTTPCanNotGetPart", 1, STR0002 + " " + cFileName + ".", LJCMessage():New( "HTTPPostError", 1, cHeadRet ) ) ) // "N�o foi possivel baixar parte do arquivo"
	EndIf	
Return uData

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetMD5                            � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o valor de verifica��o do arquivo a ser baixado.                  ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cFileName: Nome do arquivo.                                            ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cMD5: Valor de verifica��o.                                            ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetMD5( cFileName ) Class LJCFileDownloaderComunicationHTTP
	Local cMD5	:= ""
	Local uData	:= Nil
	
	uData := HTTPPost( Self:cReceiverFunction, "action=getmd5&filename=" + Escape(Self:cLoadCode + "\" + cFileName) )

	If HTTPGetStatus() != 200 .Or. !ValType(uData) == "C"
		cMD5 := ""
	Else
		If Left( uData, 1 ) == "1"
			cMD5 := SubStr( uData, 2 )
		Else
			cMD5 := ""
		EndIf
	EndIf	
Return cMD5
