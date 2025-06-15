#INCLUDE "PROTHEUS.CH"    
#INCLUDE "LOJA0044.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA0044() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCDownloaderConsoleUI            � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe que exibe informa��es da baixa do arquivo pelo console.         ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCDownloaderConsoleUI
	Method New()
	Method Update()
	Method FormatSize()
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
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New() Class LJCDownloaderConsoleUI
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Update                            � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Recebe a notifica��o de atualiza��o do progresso da baixa do arquivo.  ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oDownloadProgress: Objeto LJCFileDownloaderDownloadProgress.           ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Update( oDownloadProgress ) Class LJCDownloaderConsoleUI
	If oDownloadProgress:nStatus == 1
		ConOut( STR0001 ) // "Iniciado"
	ElseIf oDownloadProgress:nStatus == 2
		ConOut( STR0002 + " " + Self:FormatSize(oDownloadProgress:nDownloadedBytes) + "/" + Self:FormatSize(oDownloadProgress:nTotalBytes) + " (" + ALlTrim(Str(Round((oDownloadProgress:nDownloadedBytes*100)/oDownloadProgress:nTotalBytes,2))) + "%) - " + STR0003 + " " + Self:FormatSize(oDownloadProgress:nBytesPerSecond) + " - " + STR0004 + " " + AllTrim(Str(Int(oDownloadProgress:nSecondsLeft))) + " - " + STR0005 + " " + Self:FormatSize(oDownloadProgress:nBufferSize) ) // "Progresso:" "Velocidade:" "Tempo Restante:" "Buffer size:"
	ElseIf oDownloadProgress:nStatus == 3
		ConOut( STR0006 ) // "Finalizado"
	ElseIf oDownloadProgress:nStatus == -1
		ConOut( STR0007 ) // "Erro"
	EndIf
Return
	
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � FormatSize                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Formata um valor em bytes em um texto para ser exibida amigavelmente.  ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � nSize: Tamanho em bytes.                                               ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cRet: Texto amig�vel.                                                  ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method FormatSize( nSize ) Class LJCDownloaderConsoleUI
	Local cRet	:= ""

	Do Case
		Case nSize < 1024			
			cRet := Transform(Int(nSize),"9999") + "B"
		Case nSize >= 1024 .And. nSize < 1024*1024
			cRet := Transform(Round(nSize/1024,2),"9999.99") + "KB"
		Case nSize >= 1024*1024 .And. nSize < 1024*1024*1024
			cRet := Transform(Round(nSize/(1024*1024),2),"9999.99") + "MB"			
		Case nSize >= 1024*1024*1024 .And. nSize < 1024*1024*1024*1024
			cRet := Transform(Round(nSize/(1024*1024*1024),2),"9999.99") + "GB"
	EndCase
Return AlLTrim(cRet)

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � LJFileServer                      � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Servidor de arquivos do loja                                           ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � uRet: Dado solicitado.                                                 ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/	
Web Function LJFileServer()
	Local cAction						:= HTTPGet->Action
	Local cFileName						:= UnEscape(HTTPGet->FileName)
	Local nTotalBytes					:= 0
	Local nBufferSize					:= 0
	Local nStartByte					:= 0
	Local cBuffer						:= ""
	Local nHandle						:= -1
	Local oLJFileServerConfiguration	:= LJCFileServerConfiguration():New()
	Local cPath							:= oLJFileServerConfiguration:GetPath()
	Local lHasMD5File					:= FindFunction("MD5FILE")
	Local cMD5File						:= "MD5FILE"
	Local lError							:= .F.
	        
	If Lower(cAction) == "connecttest"
		HTTPSend("1111")
	ElseIf Lower(cAction) == "fileexist"
		If File( cPath + cFileName )
			HTTPSend("1111")
		Else
			lError := .T.
		EndIf
	ElseIf Lower(cAction) == "gettotalbytes"
		nHandle := FOpen( cPath + cFileName )
		If nHandle >= 0		
			Conout("Abertura com sucesso do arquivo: " +  cPath + cFileName )
			nTotalBytes := FSeek( nHandle, 0, 2 )
			Conout("Tamanho: " + cValToChar(nTotalBytes)) 
			FClose(nHandle)
			HTTPSend( AllTrim(Str(nTotalBytes)) )
		Else
		Conout("Falha ao abrir o arquivo: " +  cPath + cFileName )
			lError := .T.
		EndIf
	ElseIf Lower(cAction) == "getpart"
		nBufferSize := Val(HTTPGet->Size)
		nStartByte	:= Val(HTTPGet->StartByte)
		
		nHandle := FOpen( cPath + cFileName )
		If nHandle >= 0
			FSeek( nHandle, nStartByte, 0 )
			
			cBuffer := Space( nBufferSize )
			
			If FRead( nHandle, @cBuffer, nBufferSize ) == nBufferSize		
				HttpSetPart( .T. )
				HttpCTType( "binary/octet-stream" )
				HttpCTDisp( 'attachment; filename="' + Escape(cFileName) + '"' )
				HttpCTLen( nBufferSize )
				HTTPSend( cBuffer )
			EndIf		
			
			FClose( nHandle )
		Else
			lError := .T.
		EndIf
	ElseIf Lower(cAction) == "getmd5"
		If lHasMD5File
			If File(cPath + cFileName)
				cBuffer := &cMD5File.(cPath + cFileName, 2) // Prote��o para impedir erro "invalid funcition type"
				HTTPSend("1" + cBuffer)
			Else
				lError := .T.
			EndIf
		Else
			HTTPSend("0")
		EndIf
	EndIf
	
	If lError
		HTTPSend("ERROR")
	EndIf
Return ""

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCFileDownloader                 � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe que baixa o arquivo do servidor de arquivos do loja.            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCFileDownloader
	Data oComunication
	Data cTempPath
	Data cTargetPath
	Data aoObservers
	Data oDownloadProgress
	
	Method New()	
	Method Download()
	Method AddObserver()
	Method Notify()
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
��� Parametros: � oComunication: Inst�ncia concreta da classe abstrata                   ���
���             � LJAFileDownloaderComunicator                                           ���
���             � cTempPath: Caminho tempor�rio da baixa do arquivo.                     ���
���             � cTargePath: Caminho de destino do download.                            ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New( oComunication, cTempPath, cTargetPath) Class LJCFileDownloader
	Self:oComunication		:= oComunication
	Self:cTempPath			:= cTempPath
	Self:cTargetPath		:= cTargetPath
	Self:aoObservers			:= {}
	Self:oDownloadProgress	:= LJCFileDownloaderDownloadProgress():New("",0,0,0,0,0,0)
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Download                          � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Baixa o arquivo solicitado.                                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cFileName: Nome do arquivo a ser baixado.                              ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Download( cFileName ) Class LJCFileDownloader
	Local nTotalBytes			:= 0				// Tamanho total do arquivo a ser baixado
	Local nDownloadedBytes		:= 0				// Quantidade de bytes j� baixado
	Local cTempPathFileName		:= ""				// Path do arquivo tempor�rio
	Local nHandle				:= 0				// Handler do arquivo tempor�rio
	Local cBuffer				:= ""				// Buffer da parte do arquivo baixado
	Local nMaxBufferSize		:= 1024 * 1023		// Buffer m�ximo poss�vel no Protheus (Quase 1M)
	Local nBufferSize			:= 1024 * 1023		// Buffer inicial a ser utilizado	
	Local nNextBufferSize		:= 0				// Buffer din�mico baseado na capacidade da conex�o
	Local nSecond1				:= 0				// Temporizador 1
	Local nSecond2				:= 0				// Temporizador 2
	Local nStartByte			:= 0				// Bytes j� baixados do temporizador 1
	Local nEndByte				:= 0				// Bytes j� baixados do temporizador 2
	Local lRenewTimer			:= .T.				// Controle do temporizador
	Local nBytesPerSecond		:= 0				// Velocidade alcan�ada (Bytes/Segundo)
	Local nSecondsLeft			:= 0				// Tempo restante para baixar o arquivo
	Local nAverageBS			:= 0				// Velocidade m�dia da baixa (Bytes/Segundo)
	Local nGets					:= 0				// Quantidade de gets dados no servidor dentro do temporizador
	Local cLocalMD5				:= ""
	Local cRemoteMD5			:= ""
	Local cOriginalDownloadMD5	:= ""
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local lHandleOpenned		:= .F.
	Local lDownloadError		:= .F.
	Local lContinueDownload		:= .T.
	Local lAlreadyDownloaded	:= .F.
	Local lHasMD5File			:= FindFunction("MD5FILE")
	Local cMD5File				:= "MD5FILE"
	
	If oComunication == Nil
		oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCFileDownloaderComunicationNil", 1, STR0008) ) // "N�o h� inst�ncia da comunica��o iniciada."
		Return
	EndIf
	
	// Se conecta no servidor de arquivos		
	If Self:oComunication:Connect()		
	    // Muda estado como conectado e avisa os interessados
		Self:oDownloadProgress:nStatus		:= 1
		Self:oDownloadProgress:cFileName	:= cFileName
		Self:Notify()
		
		// Configura o path do arquivo tempor�rio a ser baixado
		Self:cTempPath:=If(Len(Self:cTempPath) > 0,If(Left(Self:cTempPath,1) != If( IsSrvUnix(), "/", "\" ), Self:cTempPath + If( IsSrvUnix(), "/", "\" ),Self:cTempPath),If( IsSrvUnix(), "/", "\" ))
		Self:cTargetPath:=If(Len(Self:cTargetPath) > 0,If(Left(Self:cTargetPath,1) != If( IsSrvUnix(), "/", "\" ), Self:cTargetPath + If( IsSrvUnix(), "/", "\" ),Self:cTargetPath),If( IsSrvUnix(), "/", "\" ))
		cTempPathFileName := Self:cTempPath + cFileName + ".part"
             
		If Self:oComunication:FileExist( cFileName )
			// Pega o MD5 do arquivo de origem
			cRemoteMD5 := Self:oComunication:GetMD5( cFileName )		

			// Verifica se o arquivo j� foi baixado
			If File( Self:cTempPath + cFileName )
				// Verifica se o arquivo baixado � id�ntico ao arquivo a ser baixado			
				If lHasMD5File .And. AllTrim( &cMD5File.( Self:cTempPath + cFileName, 2 ) ) == AllTrim( cRemoteMD5 )
					lAlreadyDownloaded := .T.
				Else
					FErase( Self:cTempPath + cFileName )
				EndIf
			
			EndIf
			
			If !lAlreadyDownloaded			
				// Se for um resumo
				If File( cTempPathFileName )
					// Verifica se arquivo que j� foi parcialmente baixado tem o mesmo MD5 do servidor, se tiver continua, se n�o tiver, apaga e inicia um novo download					
					If lHasMD5File
						If File( cTempPathFileName + ".info" )
							nHandle := FOpen( cTempPathFileName + ".info" )
							If nHandle > 0
								cBuffer := Space(32)
								If FRead( nHandle, @cBuffer, 32 ) == 32
									cOriginalDownloadMD5 := cBuffer
									
									// A parte j� baixada faz parte do mesmo download que ser� continuado
									If AllTrim( cOriginalDownloadMD5 ) != AllTrim( cRemoteMD5 )
										lContinueDownload := .F.
									EndIf
								EndIf
								FClose( nHandle )
							EndIf								
						EndIf
					EndIf
				Else
					lContinueDownload := .F.	
				EndIf
				
				// Verifica se � poss�vel abrir a parte j� baixada, se sim, continua da onde parou, se n�o, reinicia o download do arquivo.
				If File( cTempPathFileName ) .And. lContinueDownload						
					// Pega a posi��o inicial de download
					nHandle := FOpen( cTempPathFileName, 2 )
					If nHandle >= 0
						nDownloadedBytes := FSeek( nHandle, 0, 2 )
						lHandleOpenned := .T.
					EndIf
				EndIf
				
				// Se for um download novo
				If !lContinueDownload
					nHandle := FCreate( cTempPathFileName + ".info" )
					If nHandle > 0
						FWrite( nHandle, cRemoteMD5 )
						FClose( nHandle )
						
						nHandle := FCreate( cTempPathFileName )
						If nHandle > 0
							lHandleOpenned := .T.
						EndIf
					EndIf
				EndIf
				
				If lHandleOpenned
					// Pega o tamanho total do arquivo
					nTotalBytes := Self:oComunication:GetTotalBytes( cFileName )						
					If !oLJCMessageManager:HasError() .And. nDownloadedBytes != nTotalBytes
						If nTotalBytes > 0								
							// Baixa o arquivo em pacotes
							While (nDownloadedBytes < nTotalBytes)					
								// Calcula o tamanho do pr�ximo pacote
								nNextBufferSize := Min( nBufferSize, nTotalBytes-nDownloadedBytes )
								
								// Se � para reinicar o temporizador
								If (lRenewTimer)
									nStartByte	:= nDownloadedBytes
									nSecond1	:= Seconds()
									nGets := 0						
									lRenewTimer	:= .F.
								EndIf
													
								cBuffer := Self:oComunication:GetPart( cFileName, nDownloadedBytes, nNextBufferSize )
								nSecond2:=Seconds()
								If !oLJCMessageManager:HasError() .And. Len(cBuffer) == nNextBufferSize
									FWrite( nHandle, cBuffer )
									nDownloadedBytes += nNextBufferSize
									nGets++
															
									If nSecond2-nSecond1 >= 1                                                            
										nEndByte		:= nDownloadedBytes
										nBytesPerSecond := (nEndByte-nStartByte)/(nSecond2-nSecond1)
										nSecondsLeft	:= (nTotalBytes-nDownloadedBytes)/nBytesPerSecond
										nAverageBS		:= (nBytesPerSecond+nAverageBS)/2
										nBufferSize		:= Min( Int(nBytesPerSecond/nGets)*2, nMaxBufferSize )
										lRenewTimer		:= .T.
										
										// Configura o progresso atual, e avisa os interessados
										Self:oDownloadProgress:nTotalBytes		:= nTotalBytes
										Self:oDownloadProgress:nDownloadedBytes	:= nDownloadedBytes
										Self:oDownloadProgress:nBytesPerSecond	:= nBytesPerSecond
										Self:oDownloadProgress:nSecondsLeft		:= nSecondsLeft
										Self:oDownloadProgress:nBufferSize		:= nNextBufferSize
										Self:oDownloadProgress:nStatus			:= 2
										Self:Notify()										
									EndIf
								ElseIf !oLJCMessageManager:HasError() .And. Len(cBuffer) != nNextBufferSize 
									lDownloadError := .T.
									oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCFileDownloaderDownloadError", 1, STR0013) ) // "Parte baixada n�o confere com parte solicitada."
									FClose( nHandle )
									Return
								EndIf
							End
							
							FClose( nHandle )
							
							nEndByte		:= nDownloadedBytes
							nBytesPerSecond := (nEndByte-nStartByte)/(nSecond2-nSecond1)
							nSecondsLeft	:= (nTotalBytes-nDownloadedBytes)/nBytesPerSecond
							nAverageBS		:= (nBytesPerSecond+nAverageBS)/2
							nBufferSize		:= Min( Int(nBytesPerSecond/nGets)*2, nMaxBufferSize )
							lRenewTimer		:= .T.
							
							// Configura o progresso atual, e avisa os interessados
							Self:oDownloadProgress:nTotalBytes		:= nTotalBytes
							Self:oDownloadProgress:nDownloadedBytes	:= nDownloadedBytes
							Self:oDownloadProgress:nBytesPerSecond	:= nBytesPerSecond
							Self:oDownloadProgress:nSecondsLeft		:= nSecondsLeft
							Self:oDownloadProgress:nBufferSize		:= nNextBufferSize
							Self:oDownloadProgress:nStatus			:= 2
							Self:Notify()		
																		
							// Renomeia e move o arquivo para o destino solicitado
							If !lDownloadError							
								If File( Self:cTargetPath + cFileName )
									If FErase( Self:cTargetPath + cFileName ) < 0
										lDownloadError := .T.
										oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCFileDownloaderDownloadError", 1, STR0014 + " '" + Self:cTargetPath + cFileName + "'.") ) // "N�o foi possivel apagar"
									EndIf
								EndIf
								
								If !lDownloadError									
									If FRename( cTempPathFileName, Self:cTargetPath + cFileName  ) < 0
										lDownloadError := .T.				
										oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCFileDownloaderDownloadError", 1, STR0015 + " '" + cTempPathFileName + "' " + STR0016 + " '" + Self:cTargetPath + cFileName + "'.") ) // "N�o foi possivel renomear e mover de" "para"
									EndIf
								EndIf
								
								If !lDownloadError								
									If File( cTempPathFileName + ".info" )
										FErase( cTempPathFileName + ".info" )
									EndIf								
											
									cLocalMD5 := 	&cMD5File.( Self:cTargetPath + cFileName, 2 )
									//Se conseguir receber o MD5 dos dois lados, verifica se o arquivo baixado tem o mesmo MD5 do arquivo no servidor, se n�o tiver
									If !Empty(cRemoteMD5) .AND. !Empty(cLocalMD5) .AND. lHasMD5File .And. AllTrim( cLocalMD5 ) != AllTrim( cRemoteMD5 )
										lDownloadError := .T.
										oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCFileDownloaderDownloadError", 1, STR0009 + " '" + Self:cTargetPath + cFileName + "' " + STR0010) ) // "O arquivo" "est� corrompido."
									EndIf									
								EndIf
							EndIf
						Else
							lDownloadError := .T.				
							oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCFileDownloaderDownloadError", 1, STR0017 + " '" + cFileName + "'.") ) // "N�o foi possivel obter o tamanho total do arquivo"
						EndIf
					Else
						lDownloadError := .T.
					EndIf
				Else
					lDownloadError := .T.
					oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCFileDownloaderIOMessage", 1, STR0011 + " '" + cTempPathFileName + "' " + STR0012) ) // "N�o foi poss�vel cria ou abrir o arquivo" "tempor�rio para download."					
				EndIf
			EndIf
		Else
			lDownloadError := .T.		
			oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCFileDownloaderFileNotExist", 1, STR0018 + " '" + cFileName + "' " + STR0019) ) // "Arquivo" "n�o existe no servidor."
		EndIf
		Self:oComunication:Disconnect()
	Else
		lDownloadError := .T.
		oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCFileDownloaderCanNotConnect", 1, STR0020) ) // "N�o foi poss�vel se conectar no servidor."
	EndIf
	
	If lDownloadError
		If nHandle > 0
			FClose( nHandle )
		EndIf
		
		If File( cTempPathFileName )
			FErase( cTempPathFileName )
		EndIf
		
		If File( cTempPathFileName + ".info" )
			FErase( cTempPathFileName + ".info" )
		EndIf
		// Configura como erro no download
		Self:oDownloadProgress:nStatus := -1
	Else
		// Configura como download encerrado
		Self:oDownloadProgress:nStatus := 3	
	EndIf					
	// Avisa interessados
	Self:Notify()												
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � AddObserver                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Adiciona um observador ao objeto.                                      ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oObserver: Observador                                                  ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method AddObserver( oObserver ) Class LJCFileDownloader
	aAdd( Self:aoObservers, oObserver )
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Notify                            � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Notifica as classes que observam essa.                                 ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Notify() Class LJCFileDownloader
	Local nCount := 0
	
	For nCount := 1 To Len( Self:aoObservers )
		Self:aoObservers[nCount]:Update( Self:oDownloadProgress )
	Next
Return
