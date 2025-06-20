#include "FISA801.ch"
#include "protheus.ch"
#include "rwmake.ch"
#include "shell.ch"
#include "xmlxfun.ch"
#include "fileio.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � FISA801  � Autor � Laura Medina         � Data � 21/09/15 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Funcion para cancelar la factura electronica (CFDi) desde ���
���           � las opciones borrar/anular en los procesos de facturacion ���
���           � y notas de cr�dito.                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � FISA801()                                                 ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �        � LOCXPE27 y LOCXPE29                    ���
���Alf Medrano �28/04/17�MMI-4684�En func FISA801 si el llamado a la Func ���
���            �        �        �proviene de la Rutina Mata101N se cancela���
���            �        �        �la acci�n Replica MMI-4678              ���
���            �        �        �Merge Main vs 12.1.14                   ���
���ARodriguez  �18/07/14�TQCKCT�-Correcci�n al actualizar de SF1          ���
���            �        �      �-Par�metro de tipo de log                 ���
���            �31/07/14�      �-No bloquear/desbloquear SF1 al actualizar���
���M.Camargo   �08/11/18�DMINA-�Se habilita uso del par�metro MV_CFDICAN  ���
���            �        �4651  �para forzar la anulaci�n de documentos    ���
���            �        �MEX   �solamente por rutina fisa817.             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Function FISA801( cAliasSF )
Local aArea     := GetArea()
Local cNameCFDI := ""     
//Datos de la factura a cancelar
Local cLoja     := "" // SF2->F2_LOJA
Local cCliente  := "" // SF2->F2_CLIENTE
Local cSerie    := "" // SF2->F2_SERIE
Local cNumero   := "" // SF2->F2_DOC
Local cEspecie  := "" // SF2->F2_ESPECIE
Local cTimbre   := "" // SF2->F2_TIMBRE
Local cUUID     := ""
Local cRFCEmisor:= ""
Local cFeCanTF    := ""
Local lRet      := .F. 
Private cRUTASRV := &(SuperGetmv( "MV_CFDDOCS" , .F. , "\cfd\facturas\" ))	// Ruta donde se encuentran las facturas.xml (servidor)
Private cRUTASMR := &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))	// Ruta A donde se copiaran los archivos que vienen del servidor . . .  + "\TimbradoATEB\bin\Debug\"
Private cCfdUser := SuperGetmv( "MV_CFDI_US" , .F. , "0000000001" )			// Usuario del servicio web
Private cCfdPass := SuperGetmv( "MV_CFDI_CO" , .F. , "pwd" )				// Password del servicio web
Private cCFDiPAC := SuperGetmv( "MV_CFDI_PA" , .F. , "ATEB" )				// Rutina a ejecutar (PAC)
Private cCFDiAmb := SuperGetmv( "MV_CFDI_AM" , .F. , "T" )					// Ambiente (Teste o Produccion)
Private cCFDiCer := SuperGetmv( "MV_CFDI_CE" , .F. , "." )					// Archivo de certificado (.cer)
Private cCFDiKey := SuperGetmv( "MV_CFDI_PR" , .F. , "." )					// Archivo de clave (.key)
Private cCFDiCve := SuperGetmv( "MV_CFDI_CL" , .F. , "." )					// Clave de certificado para autenticar WS
Private cCFDiSF1 := SuperGetmv( "MV_CFDNAF1" , .F. , "" )					// Nombre para archivo xml de SF1
Private cCFDiSF2 := SuperGetmv( "MV_CFDNAF2" , .F. , "" )					// Nombre para archivo xml de SF2
Private nCFDiCmd := SuperGetmv( "MV_CFDICMD" , .F. , 0 )					// Mostrar ventana de comando del Shell: 0=no, 1=si
Private lProxySr := SuperGetmv( "MV_PROXYSR" , .F. , .F. )					// Emplear Proxy Server?
Private cProxyIP := SuperGetmv( "MV_PROXYIP" , .F. , "" )					// IP del Proxy Server
Private nProxyPt := SuperGetmv( "MV_PROXYPT" , .F. , 0 )					// Puerto del Proxy Server
Private lProxyAW := SuperGetmv( "MV_PROXYAW" , .F. , .F. )					// Autenticaci�n en Proxy Server con credenciales de Windows?
Private cProxyUr := SuperGetmv( "MV_PROXYUR" , .F. , "" )					// Usuario para autenticar Proxy Server
Private cProxyPw := SuperGetmv( "MV_PROXYPW" , .F. , "" )					// Clave para autenticar Proxy Server
Private cProxyDm := SuperGetmv( "MV_PROXYDM" , .F. , "" )					// Dominio para autenticar Proxy Server
Private cLogWS   := SuperGetmv( "MV_CFDILOG" , .F. , "LOG" )				// Tipo de log en consumo del servicio web: LOG (default), LOGDET (detallado), NOLOG (ninguno)
Private lDeMenu  := ( Alltrim(FunName()) $ "MATA467N/MATA465N" )

Private lAddenda := .F.
Private cError   := ""  //Contiene el numero de error
Private cDetalle := ""  //Contiene el detalle del error, cuando el timbre no es generado

Default cAliasSF := IIf(Alltrim(FunName()) $ "MATA467N" , "SF2" , IIf(Alltrim(FunName()) $ "MATA465N" .AND. nNFTipo==2, "SF2" , "SF1" ))	// Tabla de encabezado NF/NDC => SF2, NCC => SF1
If SuperGetmv( "MV_CFDICAN" , .F. , .F. )
	// Est� habilitado el Nuevo Esquema de Cancelaci�n de CFDI
	// La anulaci�n de documentos timbrados se hace desde la rutina FISA817 (Cancelaci�n de CFDI)
	Return .T.
EndIf

If cAliasSF == "SF2"
	cLoja     := SF2->F2_LOJA
	cCliente  := SF2->F2_CLIENTE
	cSerie    := SF2->F2_SERIE
	cNumero   := SF2->F2_DOC
	cEspecie  := SF2->F2_ESPECIE
	cTimbre   := SF2->F2_TIMBRE
	cNameCFDI := &(cCFDiSF2)
ElseIf cAliasSF == "SF1"
	cLoja     := SF1->F1_LOJA
	cCliente  := SF1->F1_FORNECE
	cSerie    := SF1->F1_SERIE
	cNumero   := SF1->F1_DOC
	cEspecie  := SF1->F1_ESPECIE  
	cTimbre   := SF1->F1_TIMBRE
	cNameCFDI := &(cCFDiSF1)
Endif

If Empty(cTimbre) .or. funname() == "MATA101N"
	// Documento sin TFD... no requiere consumo de servicio web para cancelar
	Return .T.
Endif

If !( cAliasSF $ "SF2/SF1" ) .Or. Empty(cEspecie + cSerie + cNumero)
	If lDeMenu
		Aviso( STR0004 , STR0017 , {STR0002} )  //Atencion##Tabla de encabezado/Documento no v�lidos.##Ok
	Else
		Conout( STR0016 + STR0017 )
	Endif
	Return lRet
Endif

If  Empty(cRUTASRV) .Or. Empty(cRUTASMR) .Or. Empty(cCfdUser) .Or. Empty(cCfdPass) .Or. Empty(cCFDiPAC) .Or. ;
	Empty(cCFDiCer) .Or. Empty(cCFDiKey) .Or. Empty(cCFDiCve)
	If lDeMenu
		Aviso( STR0004 , STR0005, {STR0003} )  //Atencion##Faltan par�metros por definir para este proceso##Ok
	Else
		Conout( STR0016 + STR0005 )
	Endif
	Return lRet
Endif

If !File( cRUTASRV + cNameCFDI )
	If lDeMenu
		Aviso( STR0004 , STR0010 + cNameCFDI , {STR0002} )  //Atencion##No se encontro la factura##Ok
	Else
		Conout( STR0016 + STR0010 + cNameCFDI )
	Endif
	Return lRet
Endif

If GetRemoteType() == 5 //Tratamiento para timbrado en WEB
	COPY FILE (cRUTASRV+cNameCFDI) TO (cRUTASMR+cNameCFDI)
Else
	//Copiar la factura.xml del servidor a la ruta de trabajo (ROOTPATH...\CFD\FACTURAS\NF_UNI_000020.XML a x:\totvs\protheusroot\bin\smartclient)
	CpyS2T(cRUTASRV + cNameCFDI, cRUTASMR)
Endif

// Quitar provisionalmente la Addenda
lAddenda := AddendaCFDi(cRUTASMR, cNameCFDI, "1")

If .F. // Upper( cCFDiPAC ) $ "DAYSOFT,FORMASDIGITALES,TIMBREFISCAL"
	//Obtener el Identificador unico del certificado
	lRet := ObtUidXML(cNameCFDI, @cUUID, @cRFCEmisor, @cFeCanTF)
	If !lRet
		If lDeMenu
			Aviso( STR0004 , STR0015 + cNameCFDI , {STR0002} )  //Atencion##No se encontro la factura##Ok
		Else
			Conout( STR0016 + STR0015 + cNameCFDI )
		Endif
	Endif
Else
	cUUID := "."
Endif

If !Empty(cUUID)
	//WS del PAC para realizar la cancelacion del TFD
	lRet := CanTimCFDi(cNameCFDI, cUUID, cRFCEmisor, cFeCanTF, cAliasSF, cNumero, cSerie, cCliente, cLoja )
Endif

RestArea(aArea) 
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ObtUidXML� Autor � Laura Medina          � Data � 11/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funci�n para leer el archivo XML que se genero al momento  ���
���          � del timbrado, con la finalidad de obtener el identificador ���
���          � �nico del certificado, RFC emisor y fecha.                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtUidXML()                                                ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ�� 
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ObtUidXML(cNameCFDI, cFeCanTF, cError, cDetalle)
Local oXML
Local cArchiOUT:= Substr(cRUTASRV,2) + cNameCFDI + ".canc" //Archivo recibido del servicio web
Local cXML     := ""
Local lRet     := .F.

oXml := XmlParserFile(cArchiOUT, "", @cError, @cDetalle )

If valType(oXml) == "O"				//Es un objeto
	SAVE oXml XMLSTRING cXML
	
	If At("ERROR" , Upper(cXML) ) > 0
		If AT( "CFDI:ERROR" , Upper(cXML) ) > 0
			If 	ValType(oXml:_CFDI_ERROR) == "O"
				cError := oXml:_CFDI_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_CFDI_ERROR:_CFDI_DESCRIPCIONERROR:TEXT
			Endif
		ElseIf AT( "<ERROR" , Upper(cXML) ) > 0
			If 	ValType(oXml:_ERROR) == "O"
				cError := oXml:_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_ERROR:_DESCRIPCIONERROR:TEXT
			Endif
	    Endif
		If Empty(cError)
			cError := cXML
		Endif
	Else 
		If At( "NS2:CANCELACFDRESPONSE " , Upper(cXml) ) > 0 //Respuesta FormasDigitales
			If At( "NS2:CANCELACFDRESULT " , Upper(cXml) ) > 0
				cFeCanTF := Strtran(Substr(oXml:_NS2_CANCELACFDRESPONSE:_NS2_CANCELACFDRESULT:_FECHA:TEXT,1,10), "-")
				lRet := .T.
			EndIf
		ElseIf At ("ResponseCancelaCFDiType " , Upper(cXml) ) > 0 //Respuesta TimbreFiscal (Diverza)
				cFeCanTF := Strtran(Substr(oXml:_ResponseCancelaCFDiType:_FECHA:TEXT,1,10), "-")
				lRet := .T.
		ElseIf At ("NS1:CANCELACFDRESPONSE" , Upper(cXml) ) > 0 //Respuesta Tralix
			If At( "NS1:CANCELACFDRESULT " , Upper(cXml) ) > 0
				cFeCanTF := Strtran(Substr(oXml:_NS1_CANCELACFDRESPONSE:_NS1_CANCELACFDRESULT:_FECHA:TEXT,1,10), "-")
				lRet := .T.
			EndIf
		Else
			cFeCanTF := Dtos(Date())
		Endif
	EndIf
Else								// Regresar contenido del archivo como texto del error (sefactura no regresa formato xml)
	cError := MemoRead( cRUTASMR + cNameCFDI + ".canc")
Endif

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CanTimCFDi� Autor � Laura Medina          � Data � 11/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funci�n ejecutar el proceso de cancelacion de la factura   ���
���          � electronica (ejecuci�n del exe).                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CanTimCFDi()                                               ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���ARodriguez  �07/06/12�v2.03 �-No codificar certificado ni llave privada���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CanTimCFDi(cNameCFDI, cUUID, cRFCEmisor, cFeCanTF, cAliasSF, cNumero, cSerie, cCliente, cLoja)
Local nOpc       := 0
Local cRutina    := "TimbradoCFDi.exe "
Local cParametros:= cCFDiPAC + " "
Local aArea      := GetArea()
Local aAreaSF2   := SF2->(GetArea())
Local aAreaSF1   := SF1->(GetArea())
Local cCancelac  := "C"
Local archivoCer := ""
Local archivoKey := ""
Local cResultado := ""
Local cMensaje   := ""
Local cXMLSign   := ""
Local cBatch     := "Timbrado.bat"
Local nHandle    := 0
Local lRet       := .T.
Local cProxy     := "[PROXY]"

Default cUUID := "."
Default cRFCEmisor := "."
Default cFeCanTF := "."

// Verifica la existencia del EXE de WS para timbrado
If !File( cRUTASMR + cRutina )
	// Compatibilidad con versiones aut�nomas
	cRutina := "Timbrado" + Trim(cCFDiPAC) + ".exe "
	cParametros := ""

	// Validar si el ejecutable existe
	If !File( cRUTASMR + cRutina )
		If lDeMenu
			Aviso( STR0004 , STR0006 + cRUTASMR + cRutina + STR0007, {STR0003} )  //No existe el cliente de servicio web: ...exe, no es posible continuar con el timbrado.
		Else
			Conout( STR0016 + STR0006 + cRUTASMR + cRutina )
		Endif
		lRet := .F.
	Endif
Endif

If lRet
	//Convertir el archivo de certificado y clave a base64
	/********** Codificar en los proyectos de VB .NET de los clientes de WS que lo requieran, tambi�n la clave de llave privada
	If  !ConvBase64(cCFDiCer,@archivoCer)
		Aviso( STR0004 , STR0011  , {STR0003} )    //"Ocurri� un error al intentar convertir el archivo .cer a base64..."
	Elseif !ConvBase64(cCFDiKey,@archivoKey)
		Aviso( STR0004 , STR0012  , {STR0003} )    //"Ocurri� un error al intentar convertir el archivo .key a base64..."
	Endif
	**********/

	// Par�metros para el Proxy Server
	cProxy += "[" + If( lProxySr , "1" , "0" ) + "]"
	cProxy += "[" + cProxyIP + "]"
	cProxy += "[" + lTrim( Str( nProxyPt ) ) + "]"
	cProxy += "[" + If( lProxyAW , "1" , "0" ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyUr ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyPw ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyDm ) + "]"

	//Parametros: PAC, Usuario, Password, Factura.xml, Ambiente,
	cParametros += cCfdUser + " " + cCfdPass + " " + cNameCFDI + " " + cCFDiAmb + " "
	//			  Archivo.cer, Archivo.key, ClaveAutenticacion, UUID, Timbrar/Cancelar
	cParametros += cCFDiCer + " " + cCFDiKey + " " + cCFDiCve + " " + cUUID + " " + cCancelac + " "
	//			  Proxy, log
	cParametros += cProxy + " " + cLogWS

	If nCFDiCmd < 0 .Or. nCFDiCmd > 10
		nCFDiCmd := 0
	Endif

	If nCFDiCmd == 3 .Or. nCFDiCmd == 10
		nHandle	:= FCreate( cRUTASMR + cBatch )
		If nHandle == -1
			If lDeMenu
				Aviso( STR0004 , STR0018 + cRUTASMR, {STR0003} )  //"No es posible crear un archivo temporal en la ruta " + cRUTASMR
				nRet := 11
			Else
				Conout( STR0016 + STR0018 + cRUTASMR + cRutina )
				nRet := 10
			Endif
		Else
			FWrite( nHandle, cRUTASMR + cRutina + Trim(cParametros) + CRLF )
			FWrite( nHandle, "Pause" + CRLF )
			fClose( nHandle )
			nOpc := WAITRUN( cRUTASMR + cBatch, nCFDiCmd )
		Endif
	Else
		//Ejecuta cliente de servicio web
		nOpc := WAITRUN(cRUTASMR + cRutina + Trim(cParametros), nCFDiCmd) // SW_HIDE
	Endif

	If nOpc == 0 .And. File( cRUTASMR + cNameCFDI + ".out" )   //creo correctamente el archivo
		If ObtResult(cRUTASMR + cNameCFDI + ".out", @cResultado)
			//Aviso( STR0004 , cResultado , {STR0003} )   //Cancelacion correcta
			cMensaje := cResultado
			
			//Copiar respuesta del WS al servidor
			Frename( cRUTASMR + cNameCFDI + ".out" , cRUTASMR + cNameCFDI + ".canc" )
			
			If GetRemoteType() == 5 //Tratamiento para timbrado en WEB
				COPY FILE (cRUTASMR+cNameCFDI+".canc") TO (cRUTASRV+cNameCFDI+".canc")
			Else
				CpyT2S(cRUTASMR + cNameCFDI + ".canc" , cRUTASRV)
			Endif

			//Obtiene fecha del XML.out
			IF ObtUidXML(cNameCFDI, @cFeCanTF, @cError, @cDetalle)
				If cAliasSF == "SF2"
					SF2->(dbSetOrder(1))
					If SF2->(dbSeek( xFilial( "SF2" )+cNumero+cSerie+cCliente+cLoja ))
						If SF2->(RecLock( "SF2" , .F.))
							SF2->F2_FECANTF := STOD(cFeCanTF)
							SF2->(msUnlock())
						Endif
					Endif
					SF2->(RestArea(aAreaSF2))
				ElseIf cAliasSF == "SF1"
					If SF1->( F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA ) == xFilial( "SF1" )+cNumero+cSerie+cCliente+cLoja .And. IsLocked( "SF1" , SF1->( Recno() ) )
						// LOCXNF: Cursor ya posicionado; no debe bloquear/desbloquear registro
						SF1->F1_FECANTF := STOD(cFeCanTF)
					Else
						SF1->(dbSetOrder(1))
						If SF1->(dbSeek( xFilial( "SF1" )+cNumero+cSerie+cCliente+cLoja ))
							If SF1->(RecLock( "SF1" , .F.))
								SF1->F1_FECANTF := STOD(cFeCanTF)
								SF1->(msUnlock())
							Endif
						Endif
						SF1->(RestArea(aAreaSF1))
					Endif
				Endif
			EndIf

			If lAddenda
				// Restaurar Addenda en el xml ya timbrado
				AddendaCFDi(cRUTASMR, cNameCFDI, "2")
			Endif
			
			// Verificar si se cre� archivo XML-Signature, copiarlo al servidor
			cXMLSign := Strtran( Lower(cNameCFDI) , ".xml" , "_firma.xml" )
			If File( cRUTASMR + cXMLSign )
				If GetRemoteType() == 5 //Tratamiento para timbrado en WEB
					COPY FILE (cRUTASMR+cXMLSign) TO (cRUTASRV+cXMLSign)
				Else
					CpyT2S(cRUTASMR + cXMLSign , cRUTASRV)				
				Endif
			Endif
		Else
			//Aviso( STR0004 , STR0013 + cResultado , {STR0003} )   //"Ocurri� un error al ejecutar la cancelaci�n: " + mensaje del ws
			cMensaje := STR0013 + cResultado
			lRet := .F.
		Endif
	Else
		//Aviso( STR0004 , STR0008 , {STR0003} )    //"Ocurri� un error al ejecutar la cancelaci�n..."
		cMensaje := STR0008
		lRet := .F.
	Endif

	If lDeMenu
		Aviso( STR0004 , cMensaje , {STR0003} )  //Atencion## **mensaje** ##Ok
	Else
		Conout( STR0016 + cMensaje )
	Endif
Endif

RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � ObtResult� Autor � Laura Medina         � Data � 16/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Funci�n para leer del archivo .out el error por el cual   ���
���           � no se realizo la cancelaci�n.                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � ObtResult  				                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ObtResult(cFile,cResultado)
Local nHandle 	:= 0
Local aInfoFile	:= {}
Local nSize		:= 0
Local nRegs		:= 0
Local nFor		:= 0
Local cBuffer	:= ""
Local cLine		:= ""
Local cString	:= ""
Local lRet      := .F.

Begin Sequence
   	nHandle := fOpen(cFile)

	If  nHandle <= 0
		cResultado := STR0014  //"No fue posible abrir el archivo .out"
		Break
	EndIf

	aInfoFile := Directory(cFile)
	nSize := aInfoFile[ 1 , 2 ]
	nRegs := Int(nSize/2048)

	For nFor := 1 to nRegs
		fRead( nHandle , @cBuffer , 2048 )
		cLine += cBuffer
	Next

	If nSize > nRegs * 2048
		fRead( nHandle , @cBuffer , (nSize - nRegs * 2048) )
		cLine += cBuffer
	Endif

	fClose(nHandle)
End Sequence

If Substr(cLine,1,1) == "("
	cLine := Substr(cLine,2)
	cLine := Strtran( cLine , ")" , " " , 1 , 1 )
EndIF

cBuffer := Upper(cLine)

If ( "UUID CANCELADO" $ cBuffer ) .Or. ( "STATUSUUID>201" $ cBuffer ) .Or. ( "SE REPORTARA" $ cBuffer .And. "CANCELADO" $ cBuffer) .Or. ;
	( "PREVIAMENTE" $ cBuffer .And. "CANCELADO" $ cBuffer)
	lRet := .T.
Else
	cString	:= Substr( cLine , 1 , 4 )
	If Empty(cLine) .Or. ( "ERROR" $ cBuffer ) .Or. ( "FAILED" $ cBuffer ) .Or. ( "FAIL " $ cBuffer ) .Or. ( "EXCEPTION" $ cBuffer ) .Or. ; 
	( "EXCEPCION" $ cBuffer ) .Or. ( "EXCEPCI�N" $ cBuffer ) .Or. ( "EXCEPCI�N" $ cBuffer )  .Or. ( Val(cString) > 0 ) .Or. ;
	( "CANCELED" $ cBuffer .And. "FALSE" $ cBuffer )
		// Error 
	Else
		lRet := .T.
	Endif
Endif

cResultado := Alltrim(cLine)

Return 	lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �AddendaCFDi�Autor � Alberto Rodriguez     � Data � 09/12/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manejo de Addenda para timbrar xml			              ���
���          � Las funciones de tratamiento de xml alteran el formato!!!  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AddendaCFDi( cRutaSmartclient, cArchivoXML, cOpcion )      ���
���          � cOpcion 1-Elimina, 2-Restaura                              ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function AddendaCFDi(cRutaXML, cArchivo, cOpcion)
Local aXML	:= {}
Local cEtiq1:= "<cfdi:Addenda"
Local cEtiq2:= "</cfdi:Addenda>"
Local cFin	:= "</cfdi:Comprobante>"
Local nIni	:= 0
Local nFin	:= 0
Local nLoop	:= 0
Local lRet	:= .F.

Static aAddenda := {}

// Leer xml recibido como string
aXML := File2Array( cRutaXML + cArchivo )

If Len(aXML) > 0
	If cOpcion == "1"
		// Extrae la Addenda y la elimina del xml
		aSize( aAddenda , 0 )
		nIni := aScan( aXML , {|x| cEtiq1 $ x } )

		If nIni > 0
			// Hace copia de la Addenda
			For nLoop := nIni To Len(aXML)
				aAdd( aAddenda , aXML[nLoop] )
				If cEtiq2 $ aXML[nLoop]
					nFin := nLoop
					Exit
				Endif
			Next

			If nFin == 0
				// Indica que el elemento Addenda termina en la misma l�nea del xml: "... />" puede haber espacios los caracteres
				nFin := nIni
			Endif
			
			// Elimina la Addenda
			For nLoop := nFin To nIni Step -1
				aDel( aXML , nLoop )
				aSize( aXML , Len(aXML)-1 )
			Next

			// Codificacion UTF-8
			If Substr(aXML[1], 1, 1) == "<"
				aXML[1] := EncodeUTF8( aXML[1] )
			Endif

			// Graba el xml actualizado
			lRet := Array2File( cRutaXML + cArchivo , aXML )
		Endif

	ElseIf Len(aAddenda) > 0
		// Restaura la Addenda en el xml timbrado
		For nLoop := Len(aXML) To 1 Step -1
			If cFin $ aXML[nLoop]
				nIni := nLoop
				Exit
			Endif
		Next

		// Como viene el xml? formateado o todo seguido
		If !( cFin == Alltrim( aXML[nIni] ) )
			// La l�nea donde se encuentra la etiqueta de cierre de documento contiene m�s definiciones ==> partirla
			aSize( aXML , Len(aXML) + 1 )
			nFin := At( cFin , aXML[nIni] )
			aXML[nIni + 1] := Substr( aXML[nIni] , nFin )
			aXML[nIni] := Substr( aXML[nIni] , 1 , nFin - 1 )
			++nIni
		Endif

		// Reinserta la Addenda
		For nLoop := 1 To Len(aAddenda)
			aSize( aXML , Len(aXML)+1 )
			aIns( aXML , nIni + nLoop - 1 )
			aXML[nIni + nLoop - 1] := aAddenda[nLoop]
		Next

		// Graba el xml final
		lRet := Array2File( cRutaXML + cArchivo , aXML )

	Endif
Endif

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �File2Array�Autor  � Alberto Rodriguez     � Data � 12/12/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Lee un archivo de texto y deja el contenido en un arreglo  ���
���          � Sin CR + LF                                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � File2Array( cArchivo, aDatos )                             ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function File2Array( cFile )
Local nHandle		:= 0
Local aInfoFile		:= {}
Local nSize			:= 0
Local nTamChr		:= 0
Local nPosFimLinha	:= 0
Local aFile 		:= {}
Local cLine			:= ""
Local cImpLine		:= ""
Local cAuxLine		:= ""

Begin Sequence
   
	IF !( File( cFile ) )
		Break
	EndIF

	nHandle 	:= fOpen( cFile )
	If nHandle <= 0
		Break
	EndIf
	aInfoFile	:= Directory( cFile )
	nSize		:= aInfoFile[ 1 , 2 ]

	/*/
	��������������������������������������������������������������Ŀ
	� Extrai uma linha "FISICA" de texto (pode conter varias linhas�
	� logicas)											           �
	����������������������������������������������������������������/*/
	cLine	:= fReadStr( nHandle , nSize )

	/*/
	��������������������������������������������������������������Ŀ
	� Gerar o Array para a GetDados       						   �
	� Verifica a Existencia de CHR(13)+CHR(10) //Carriage Return e �
	� Line Feed na linha extraida do texto Se ambos existirem, esta�
	� mos trabalhando em ambiente Windows. Caso contrario, estamos �
	� em ambiente Linux e somente teremos o CHR(10) para indicar o �
	� final da linha 											   �
	����������������������������������������������������������������/*/
	If (nPosFimLinha	:=	At( CRLF , cLine ) ) == 0
		nPosFimLinha	:=	At( Chr(10) , cLine )
		nTamChr := 1
	Else
		nTamChr := 2
	EndIf

	cImpLine := Substr( cLine, 1, nPosFimLinha - 1 )
	cAuxLine := Substr( cLine, nPosFimLinha+nTamChr, nSize )

	If Len( cImpLine ) > 0
		aAdd( aFile, cImpLine )
	Else
		aAdd( aFile, cLine )
	EndIf

	While nPosFimLinha <> 0
		If nTamChr == 1
			nPosFimLinha	:=	At( Chr(10) , cAuxLine )
		Else
			nPosFimLinha	:=	At( CRLF , cAuxLine )
		EndIf

		If nPosFimLinha <> 0
			cImpLine := Substr( cAuxLine, 1, nPosFimLinha - 1 )
			cAuxLine := Substr( cAuxLine, nPosFimLinha+nTamChr, nSize )
			aAdd( aFile, cImpLine )			
		ElseIf Len( cAuxLine ) > 0
			aAdd( aFile, cAuxLine )			
		EndIf
	EndDo
	
	fClose( nHandle )

End Sequence

Return( aFile )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Array2File�Autor  � Alberto Rodriguez     � Data � 12/12/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Graba un arreglo en un archivo de texto agregando CR + LF  ���
���          � al final de cada l�nea                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Array2File( cArchivo, aDatos )                             ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Array2File(cArchivo, aDatos)
Local nHandle	:= FCreate(cArchivo)
Local nLoop		:= 0
Local lRet		:= .F.

If !(nHandle == -1)
	For nLoop := 1 to Len(aDatos)
		FWrite(nHandle, aDatos[nLoop] + CRLF)
	Next
   FClose(nHandle)
   lRet := .T.
EndIf

Return lRet

/*
