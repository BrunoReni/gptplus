#Include "PROTHEUS.CH"
#Include "RPTDEF.CH"
#Include "TBICONN.CH"
#Include "GPER991.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n   � GPER991 � Autor � Cristian Franco       � Data �  24/02/20 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir Aviso de Vacaciones                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GPER991()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function GPER991()

	Local oPrinter		:= Nil
	Local cQuery 		:= ""
	Local cSuc   		:= ""   
	Local cMat   		:= ""
	Local cCet   		:= ""
	Local dDate			:= CTOD("  /  /  ") 
	Local dAdate		:= CTOD("  /  /  ") 
	Local cArea			:= ""
	Local nTipRel		:= 0
	Local nResImpr		:= 0 // resultado de impresi�n
	Local lEnvOK 		:= .F.
	Local nI			:= 0
	Local cEmailCli		:= ""
	Local cFileGen		:= STR0038 +  "_" + STR0039 + "_" + STR0040 //"aviso" - "de" - "vacaciones"

	Private dFechaIn 	:= CTOD("  /  /  ")
	Private dFechaFin 	:= CTOD("  /  /  ")
	Private cTitulo		:= "" 
	Private nAux01		:= ""
	Private cNome		:= ""
	Private nDuracao 	:= 0
	Private nDur		:= 0
	Private aInfSRA		:= {}
	Private aInfSR8		:= {}
	Private cAliasBus	:= GetNextAlias()
	Private cAliasTmp	:= GetNextAlias()
	Private dDataAnt	:= CTOD("  /  /  ")
	Private dDataFin	:= CTOD("  /  /  ")
	Private aDataAlt	:= ""
	Private cMesDia		:= ""
	Private cNumID		:= ""
	Private cAnioIni	:= "" 
	Private cMesIni		:= ""  	
	Private cDiaIni		:= "" 
	Private cAnioFim	:= "" 
	Private cMesFim		:= ""  	
	Private cDiaFim		:= "" 
	Private aEmail 		:= {}
	Private li			:= _PROW()
	Private lPDFEmail	:= .T.
	Private aItens 		:= {}
	Private cPath		:= GetSrvProfString('RootPath','\')
	Private cPathEmail	:= GetSrvProfString('StartPath','\')
	
	If Pergunte("GPER991", .T.)
	
		//convierte parametros tipo Range a expresion sql
		//si esta separa por "-" agrega un BETWEEN,  si esta separado por ";" agrega un IN
		MakeSqlExpr("GPER991")
		
		dDate	:= (MV_PAR01) //De Fecha
		dAdate	:= (MV_PAR02) //A fecha 
		nTipRel	:= (MV_PAR03) // Impresso / eMail
		cSuc	:= Trim(MV_PAR04) //�Sucursal ?
		cCet	:= Trim(MV_PAR05) //�Centro de Trabajo ?
		cArea	:= Trim(MV_PAR06) //Area
		cMat	:= Trim(MV_PAR07) //�Matricula ?

		If nTipRel == 1 //Si seleciona opci�n 1 - Imprimir
			
			//���������������������������������������������Ŀ
			//� se inicializa el objeto FWMSPrinter       �
			//� solo si hay registros para procesar		  �
			//�����������������������������������������������
			oPrinter := FWMSPrinter():New(cFileGen,6,.F.,GetClientDir(),.T.,,,,,.F.) //inicializa el objeto
			oPrinter:setDevice( IMP_PDF ) //selecciona el medio de impresi�n
			oPrinter:SetMargin(40,10,40,10) //margenes del documento
			oPrinter:SetPortrait() //orientaci�n de p�gina modo retrato =  Horizontal
			oPrinter:Setup() //Muestra el objeto con la configuraciones previas.

			nResImpr	:= oPrinter:nModalResult //Obtiene nModalResult = 1 confirmada --- nModalResult = 2 cancelada
			
			If nResImpr == 2 //Si no se precede con la impresi�n del informe
				oPrinter:Cancel()
				FreeObj(oPrinter)
				oPrinter := Nil
				Return Nil
			EndIf

		Else
			
			//Valida correcta configuraci�n de par�metros para el env�o de correos
			If !FVldInfEnv()
				Return Nil
			EndIf

		EndIf
							    
		//���������������������������������������������Ŀ
		//� Selecciona los datos de la tabla SR8 Y RCM  �
		////�����������������������������������������������		
 		cQuery  += "SELECT RA_MAT, RA_SEXO, RA_ESTCIVI, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RA_TPCIC, RA_CIC, R8_MAT, R8_DURACAO, R8_DATAINI, R8_DATAFIM"
		cQuery  += " FROM " + RetSqlName( "SR8" ) + " SR8," + RetSqlName("RCM") + " RCM, " + RetSqlName("SRA") + " SRA "
		cQuery  += " WHERE R8_TIPOAFA = RCM.RCM_TIPO "
		cQuery  +=	"AND SRA.D_E_L_E_T_=' ' "
		cQuery  +=	"AND SR8.D_E_L_E_T_=' ' "
		cQuery  +=	"AND RCM.D_E_L_E_T_=' ' "
		cQuery  += " AND R8_FILIAL='"+XFILIAL("SR8")+" ' "
		cQuery  += " AND RCM_FILIAL='"+XFILIAL("RCM")+" ' "
		cQuery  += " AND RA_FILIAL='"+XFILIAL("SRA")+" ' "
		cQuery  += " AND R8_MAT = RA_MAT"
		cQuery  += " AND R8_DATAINI BETWEEN '"+DTOS(dDate)+ "' AND '"+DTOS(dAdate)+"'"
		cQuery  += " AND RCM_TPIMSS='3'"
		If	!Empty( cSuc )
			cQuery  += " AND "+cSuc+""
		EndIf
		If	!Empty( cCet )	
			cQuery  += " AND "+cCet+""
		EndIf
		If	!Empty( cArea )
		cQuery  += " AND "+cArea+""
		EndIf
		If	!Empty( cMat )
			cQuery  += " AND "+cMat+""
		EndIf
		cQuery  := StrTran( cQuery, ";", "" )  	
		
		cQuery := ChangeQuery(cQuery)
    	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasBus, .T., .F. )		
    	
    	TcSetField(cAliasBus, "R8_DATAINI", "D")
    	TcSetField(cAliasBus, "R8_DATAFIM", "D")

		While (cAliasBus)->(!EOF())
		 	
			aInfSRA := {(cAliasBus)->RA_SEXO,(cAliasBus)->RA_ESTCIVI,(cAliasBus)->RA_PRINOME,(cAliasBus)->RA_SECNOME,(cAliasBus)->RA_PRISOBR,(cAliasBus)->RA_SECSOBR,(cAliasBus)->RA_TPCIC,(cAliasBus)->RA_CIC}
			aInfSR8 := {(cAliasBus)->R8_DURACAO,(cAliasBus)->R8_DATAINI,(cAliasBus)->R8_DATAFIM}
				
			cAnioIni	:= YEAR (aInfSR8[2])
			cMesIni		:= MESEXTENSO(MONTH(aInfSR8[2]))
			cDiaIni		:= DAY (aInfSR8[2])
			cAnioFim	:= YEAR (aInfSR8[3])
			cMesFim		:= MESEXTENSO(MONTH(aInfSR8[3]))
			cDiaFim		:= DAY(aInfSR8[3])
			dDataFin	:= aInfSR8[3] + 1		
			dDataAnt	:= aInfSR8[2]-1
			
			If DOW(dDataFin) == 7
				dDataFin 	:= dDataFin+2
			ElseIf	DOW(dDataFin) == 1
				dDataFin 	:= dDataFin+1
			EndIf

			If DOW(dDataAnt) == 1
				dDataAnt	:= dDataAnt-2
			EndIf

			cMesDia := StrZero(MONTH(dDataFin),2) + StrZero(DAY(dDataFin),2)	
			
			If aInfSRA[1] == "F" .and. aInfSRA[2] == "S"
				cTitulo := STR0041 //"Se�orita"
			EndIf
			If aInfSRA[1] == "F" .and. aInfSRA[2] <> "S"
				cTitulo := STR0042 //"Se�ora"
			EndIf
			If aInfSRA[1] == "M"
				cTitulo := STR0043 //"Se�or"
			EndIf
			
			cNome := ALLTRIM(aInfSRA[3])+" "+ALLTRIM(aInfSRA[4])+" "+ALLTRIM(aInfSRA[5]) + " " +ALLTRIM(aInfSRA[6])			
			
			//���������������������������������������������Ŀ
			//� Selecciona los datos de la tabla SRF		  �
			////�����������������������������������������������	
			cQuery	:= ""
			cQuery  += " SELECT RF_DATABAS, RF_DATAFIM, RF_DFERVAT, RF_DFERAAT, RF_DFERANT"
			cQuery  += " FROM " + RetSqlName( "SRF" ) + " SRF"
			cQuery  += " WHERE RF_MAT='"  +(cAliasBus)->R8_MAT+"'"
			cQuery  += " AND RF_STATUS='1' " 
			cQuery  += " AND SRF.D_E_L_E_T_=' ' "
			cQuery  += " AND RF_FILIAL='"+XFILIAL("SRF")+" ' "
			cQuery  += " ORDER BY RF_DATABAS " 	
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .F. ) 
			
			TcSetField(cAliasTmp,"RF_DATABAS"  ,"D")
			TcSetField(cAliasTmp,"RF_DATAFIM"  ,"D")
			
			dFechaIn	:= (cAliasTmp)->RF_DATABAS
			dFechaFin	:= (cAliasTmp)->RF_DATAFIM
			nDuracao	:= (cAliasBus)->R8_DURACAO
			
			While (cAliasTmp)->(!EOF())
				nSaldo		:= (cAliasTmp)->RF_DFERVAT + (cAliasTmp)->RF_DFERAAT - (cAliasTmp)->RF_DFERANT			
					If nDuracao		<= nSaldo
						dFechaFin	:= (cAliasTmp)->RF_DATAFIM
						Exit 
					Else
						nDuracao	:= nDuracao - nSaldo
					EndIf
				
		    	(cAliasTmp)->(dbSkip())
			EndDo
			(cAliasTmp)->(dbCloseArea())

			If nTipRel == 1 //Si selecciona opci�n 1 - Impresi�n
				
				//Realiza impresi�n del aviso por empleado
				ImpPagVac(oPrinter)

			Else //Si selecciona la opci�n 2 - Email

				//���������������������������������������������Ŀ
				//� Se inicializa el objeto FWMSPrinter       �
				//� solo si hay registros para procesar		  �
				//�����������������������������������������������
				oPrinter := FWMSPrinter():New(cFileGen,6,.F.,,.T.,,,,,.F.) //Inicializa el objeto de impresi�n
				oPrinter:setDevice(6) //Setea el medio de impresi�n
				oPrinter:SetMargin(40,10,40,10) //Setea margenes del documento
				oPrinter:SetPortrait() //Setea orientaci�n de p�gina modo retrato =  Horizontal
				oPrinter:SetViewPDF(.F.) //Setea visualizaci�n del PDF
				oPrinter:cPathPDF := GetClientDir() //Setea path de la generaci�n del archivo PDF

				//Realiza impresi�n del aviso por empleado
				ImpPagVac(oPrinter)

				oPrinter:Print() //Imprime informe (genera .rel y .pdf)
				
				//Copia archivo del directorio local al servidor (system)
				CpyT2S(GetClientDir() + cFileGen + ".pdf", cPathEmail)
				FErase(GetClientDir() + cFileGen + ".pdf")
				
				aFileAux := {}
				aItens := {}
				
				//Agrega el archivo que ser� enviado por correo
				aAdd(aItens, cPathEmail + cFileGen + ".pdf")
				
				//Agrega archivos para su borrado al finalizar el proceso
				aAdd(aFileAux, cPathEmail + cFileGen + ".zip") //Archivo ZIP
				
				cFile := cPathEmail + cFileGen + ".zip"
				&('FZip(cFile, aItens, cPathEmail)')
				
				//Obtiene el correo para el env�o del email
				cEmailCli := AllTrim(ObtEmail((cAliasBus)->RA_MAT))

				//Realiza env�o de correo electronico
				lEnvOK := EnvioMail(cEmailCli, aFileAux, (cAliasBus)->RA_MAT)

				aAdd(aFileAux, cPathEmail + cFileGen + ".pdf") //Archivo PDF
				
				//Borra archivos creados
				For nI := 1 To Len(aFileAux)
					FErase(aFileAux[nI])
				Next nI

				FreeObj(oPrinter)
				oPrinter := Nil

			EndIf

    		(cAliasBus)->(dbSkip())
		EndDo

		(cAliasBus)->(dbCloseArea())
		
		If nTipRel == 1 //Si selecciona opci�n 1 - Impresi�n
			oPrinter:Preview()
		EndIf

	EndIf
		
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ImpPagVac � Autor � Cristian Franco      � Data � 24/02/2019���
�������������������������������������������������������������������������Ĵ��
���Descri��o � �Imprime Aviso de Vacaciones             				  ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpPagVac()                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ImpPagVac(oPrinter)
			
	Local oFontT		:= Nil			
	Local oFontP		:= Nil
	Local aLinea		:= {} 
	Local nSalto  		:= 0	
	Local nEsp  		:= 0	
	Local nX  			:= 0 
	Local cValInL		:= ""
	Local cStartPath	:= GetSrvProfString("Startpath","")

	Default oPrinter	:= Nil

	cValInL		:= space(90)
	cLineas		:= space(50)							 
	oFontT 		:= TFont():New('Arial',,-15,.T.,.T.)//Fuente del Titulo
	oFontP 		:= TFont():New('Arial',,-14,.T.)     //Fuente del P�rrafo
	oPrinter:StartPage() 
	nEsp		:= 90 			
	oPrinter:SayBitmap(030,060,cStartPath+"lgrl"+FwCodEmp("SM0")+".bmp",80,40)
	oPrinter:Say(nEsp,200,STR0018,oFontT) //"COMUNICACI�N DE VACACIONES"
	
	//Llena array que contendr� la posici�n vertical de las l�neas del formato de impresi�n
	For nX:=1 to 18 step 1
		nSalto := 20				
		If nX==1   
			nSalto := 80
		EndIf
		If  nX==8 .Or. nX ==9 
			nSalto := 30
		EndIf
		If nX==4 .Or. nX ==13
			nSalto := 60
		EndIf
		If nX==11  .Or. nX==14
			nSalto := 70
		EndIf
		nEsp = nEsp + nSalto
		AADD(aLinea, nEsp)
	Next	
	
	oPrinter:Say(aLinea[1],  70, cTitulo , oFontP)			
	oPrinter:Say(aLinea[2],  70, cNome, oFontP)
	oPrinter:Say(aLinea[3],  70, STR0001 , oFontP) //"Presente"
	
	If ExistBlock("GPE991")  // Punto de entrada para Actualizar fecha de regreso
		dDataFin:= ExecBlock("GPE991",.F.,.F.,{dDataFin})
	EndIf
	
	If VerifDia(cMesDia,dDataFin)
		dDataFin := dDataFin+1
	EndIf

	oPrinter:Say(aLinea[4],  130, STR0002, oFontP) //"Por la presente y en cumplimiento del Art. 222 del C�digo del trabajo, ponemos a "
	oPrinter:Say(aLinea[5],   70, STR0003 + STR0004, oFontP) //"su conocimiento que las vacaciones que le corresponden de acuerdo a su antig�edad, " - "es de"
	oPrinter:Say(aLinea[6],   70, ALLTRIM(STR(nDuracao)) + STR0005 + DIASEMANA(aInfSR8[2]) + ; //" d�as, deber� usufructuar, desde el "
				Alltrim(STR(cDiaIni)) + STR0007 + cMesIni + STR0007 + Alltrim(STR(cAnioIni)) + ; //" de " - " de "
				STR0034 + DIASEMANA(aInfSR8[3]) + " " + Alltrim(STR(cDiaFim)) + STR0007, oFontP, 200) //" hasta el d�a " - " de "
	oPrinter:Say(aLinea[7],   70, cMesFim + STR0007 + Alltrim(STR(cAnioFim)) + STR0008 + STR0009 + ; //" de " - ", " - "correspondiente al per�odo "
				DTOC(dFechaIn) + STR0010 + DTOC(dFechaFin) + STR0012, oFontP) //"-" - "."
	oPrinter:Say(aLinea[8],   70, STR0011 + DIASEMANA(dDataFin) + " " + Alltrim(STR(DAY(dDataFin))) + ; //"Debiendo reintegrarse a su puesto de trabajo el d�a "
				STR0007 + MESEXTENSO(MONTH(dDataFin)) + STR0007 + Alltrim(STR(YEAR(dDataFin))) + STR0012, oFontP) //" de " - " de " - "."
	oPrinter:Say(aLinea[9],   70, STR0019, oFontP) //"El importe de salario por el concepto de vacaciones estar� a su disposici�n en la oficina de"
	oPrinter:Say(aLinea[10],  70, STR0036, oFontP) //"Recursos Humanos, el �ltimo d�a de trabajo antes del inicio de estas."
	oPrinter:Say(aLinea[11],  200, STR0016, oFontP) //"__________________________________"
	oPrinter:Say(aLinea[12],  235, STR0037, oFontP)	//"RECURSOS HUMANOS"
	oPrinter:Say(aLinea[13],  250, STR0017, oFontP) //"RECIB� CONFORME"
	oPrinter:Say(aLinea[14],  200, STR0016, oFontP) //"__________________________________"
	oPrinter:Say(aLinea[15],  200, cNome, oFontP)
	oPrinter:Say(aLinea[16],  250, ALLTRIM(aInfSRA[7]) + "  "+ ALLTRIM(aInfSRA[8]), oFontP)
	
	oPrinter:EndPage() // Finaliza la p�gina
							
Return 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � EnvioMail  � Autor � Cristian Franco       � Data � 24.02.20 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � EnvioMail(cEmailC, aAnexo)                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cEmailC .- Email del empleado para envio de archivo  PDF.    ���
���          � aAnexo .- Arreglo con archivos adjuntos.                     ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lResult .- Valor l�gico .T. envio exitoso, .F. error de envio���
���������������������������������������������������������������������������Ĵ��
��� Uso      � GPER991                                                		���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function EnvioMail(cEmailC, aAnexo, cMatricula)
	Local lResult 		:= .F.
	Local cServer		:= SuperGetMV("MV_RELSERV", .F., "") //Nombre de servidor de envio de E-mail utilizado en los informes.
	Local cEmail		:= SuperGetMV("MV_RELACNT", .F., "") //Cuenta a ser utilizada en el envio de E-Mail para los informes
	Local cPassword		:= SuperGetMV("MV_RELPSW", .F., "") //Contrasena de cta. de E-mail para enviar informes
	Local lAuth			:= SuperGetMV("MV_RELAUTH", .F., .F.) //Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao;
	Local lUseSSL		:= SuperGetMV("MV_RELSSL", .F., .F.) //Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL);
	Local lTls			:= SuperGetMV("MV_RELTLS", .F., .F.) //Informe si el servidor de SMTP tiene conexion del tipo segura ( SSL/TLS ).    
	Local nPort			:= SuperGetMv("MV_SRVPORT", .F., 0)	//Puerto de conexion con el servidor de correo
	Local nErr			:= 0
	Local ctrErr		:= ""
	Local oMailServer	:= Nil
	Local cAttach		:= ""
	Local nI			:= 0
	Local nX			:= 0
	
	Default cEmailC		:= ""
	Default aAnexo		:= {}
	Default cMatricula	:= ""

	If Empty(cEmailC)
		Help("", 1, "HELP", , STR0044 + cMatricula, 1, 0) //"Informe un correo electr�nico en el campo RA_EMAIL para el empleado con matr�cula: "
		Return .F.
	EndIf
	
	If !Empty(cEmailC)
		For nI:= 1 to Len(aAnexo)
			cAttach += aAnexo[nI] + "; "
		Next nI	

		If !lAuth .And. !lUseSSL .And.!lTls
			CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPassword RESULT lResult
			
			If lResult 
				SEND MAIL FROM cEmail ;
				TO      	cEmailC;
				BCC     	"";
				SUBJECT 	STR0032;
				BODY    	STR0033;
				ATTACHMENT  cAttach  ;
				RESULT lResult

				If !lResult
					//Erro no envio do email
					GET MAIL ERROR cError
					Help(" ",1,STR0026,,cError,4,5)
				EndIf

			Else
				//Erro na conexao com o SMTP Server
    			GET MAIL ERROR cError                                       
    			Help(" ",1,STR0026,,cError,4,5) //--- Aviso    

			EndIf

			DISCONNECT SMTP SERVER
		Else
			//Instancia o objeto do MailServer
			oMailServer:= TMailManager():New()
			oMailServer:SetUseSSL(lUseSSL)    //Obs: Apenas se servidor de e-mail utiliza autenticacao SSL para envio
			oMailServer:SetUseTLS(lTls)       //Obs: Apenas se servidor de e-mail utiliza autenticacao TLS para recebimento

			If Empty(nPort)
				oMailServer:Init("",cServer,cEmail,cPassword,0)
			Else
				oMailServer:Init("",cServer,cEmail,cPassword,0,nPort)
			EndIf
		                               
		    //Defini��o do timeout do servidor
			If oMailServer:SetSmtpTimeOut(120) != 0
		   		Help(" ",1,STR0029,,OemToAnsi(STR0030) ,4,5) //"Aviso" ## "Tiempo de Servidor"
		   		Return .F.
		   	EndIf
		
		   	//Conex�o com servidor
		   	nErr := oMailServer:smtpConnect()
		   	If nErr <> 0
		   		cTrErr:= oMailServer:getErrorString(nErr)
		    	oMailServer:smtpDisconnect()
		    	
		    	// Intenta (varias veces) el env�o a trav�s de otra clase de conexi�n
		    	lResult := EnvioMail2(cServer, cEmail, cPassword, lAuth, cEmailC, aAnexo, @cTrErr)
		    	
		    	If !lResult
			   		Help(" ",1,STR0026,,ctrErr,4,5) 
				EndIf

				Return lResult
		   	EndIf

		   	//Autentica��o com servidor smtp
		   	nErr := oMailServer:smtpAuth(cEmail, cPassword)
		   	If nErr <> 0
		    	cTrErr := OemToAnsi(STR0031) + CRLF + oMailServer:getErrorString(nErr)
		     	oMailServer:smtpDisconnect()

		    	// Intenta (varias veces) el env�o a trav�s de otra clase de conexi�n
		    	lResult := EnvioMail2(cServer, cEmail, cPassword, lAuth, cEmailC, aAnexo, @cTrErr)
		    	
		    	If !lResult
			     	Help(" ",1,STR0029,,cTrErr ,4,5)//"Aviso" ## "Autenticaci�n con servidor smtp"
				EndIf

				Return lResult
		   	EndIf
		                               
		   	//Cria objeto da mensagem+
		   	oMessage := tMailMessage():new()
		   	oMessage:clear()
		   	oMessage:cFrom 	:= cEmail 
		   	oMessage:cTo 	:= cEmailC 
		   	oMessage:cSubject :=  STR0032
		   	oMessage:cBody := STR0033

		   	For nX := 1 to Len(aAnexo)
		   		oMessage:AddAttHTag("Content-ID: <" + aAnexo[nX] + ">") //Essa tag, � a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
		     	oMessage:AttachFile(aAnexo[nX])                       //Adiciona um anexo, nesse caso a imagem esta no root
		   	Next nX
		                               
			//Dispara o email          
			nErr := oMessage:send(oMailServer)
			If nErr <> 0
		   		cTrErr := oMailServer:getErrorString(nErr)
		     	Help(" ",1,STR0029,,OemToAnsi(STR0026) + CRLF + cTrErr ,4,5)//"Aviso" ## "Error en el Envio del Email"
		     	oMailServer:smtpDisconnect()
		     	Return .F.
			Else
		   		lResult := .T.
		   	EndIf
		
		  	//Desconecta do servidor
		   	oMailServer:smtpDisconnect()
		EndIf
	EndIf
Return lResult	

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ObtEmail   � Autor � Cristian Franco       � Data � 24.02.20 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtEmail(cMat)                                    			���
���������������������������������������������������������������������������Ĵ��
���Parametros� cMat .- Matr�cula de Empleado.                               ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � cEmailCli .- Email configurado para empleado (RA_EMAIL).     ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � GPERP991                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ObtEmail(cMat)
	Local cEmailCli := ""
	Local aArea 	:= getArea()
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1)) //RA_FILIAL+RA_MAT                                                                                                                                                 
	If SRA->(dbSeek(xFilial("SRA") + cMat ))
		cEmailCli := SRA->RA_EMAIL
	EndIf
	RestArea(aArea)	
Return cEmailCli

/*/{Protheus.doc} EnvioMail2
//TODO Descri��o auto-gerada.
@author arodriguez
@since 10/01/2020
@version 1.0
@return l�gico, env�o correcto?
@param cMailServer, characters, direcci�n de servidor de correo
@param cMailConta, characters, usuario de conexi�n / cuenta de correo remitente
@param cMailSenha, characters, contrase�a del usuario
@param lAutentica, logical, requiere autenticaci�n?
@param cEmail, characters, correo destinatario (cliente)
@param cEMailAst, characters, asunto
@param cMensGral, characters, contenido
@param aAnexo, array, array de anexos
@param cErr, characters, (@referencia) variable para mensaje de error
@type function
/*/
Static Function EnvioMail2(cMailServer, cMailConta, cMailSenha, lAutentica, cEmail, cEMailAst, cMensGral, aAnexo, cErr)
	Local cAcAut	:= GetMV("MV_RELAUSR",,"" )		//Usuario para autenticacion en el servidor de email
	Local cPwAut 	:= GetMV("MV_RELAPSW",,""  )	//Contrase�a para autenticacion en servidor de email
	Local lResult	:= .F.
	Local nIntentos	:= 0

	If lAutentica .And. Empty(cAcAut+cPwAut)
		Return lResult
	EndIf

	Do While !lResult .And. nIntentos < 11
		nIntentos++
		lResult := MailSmtpOn(cMailServer,cMailConta,cMailSenha)

		// Verifica se o E-mail necessita de Autenticacao
		If lResult .And. lAutentica
			lResult := MailAuth(cAcAut,cPwAut)
		Endif

		If lResult
			lResult := MailSend(cMailConta, {cEmail}, {" "}, {" "}, cEMailAst, cMensGral, aAnexo)
		EndIf

		If !lResult
			cErr := MailGetErr()
		EndIf

		MailSmtpOff()
	EndDo

Return lResult

/*/{Protheus.doc} VerifDia
	Verifica si existen d�as feriados.
	
	@type  Static Function
	@author Cristian Franco
	@since 07/10/2022
	@version 1.0
	@param cMesDia, Caracter, Mes y d�a del registro a buscar en SP3.
	@param dDataFin, Fecha, Fecha final del d�a feriado.
	@return lRet, return_type, return_description
	@example
	VerifDia(cMesDia,dDataFin)
/*/
Static Function VerifDia(cMesDia,dDataFin)
Local cQuery	:= ""
Local cTmpDia	:= GetNextAlias()
Local lRet		:= .F.
Local cDataFin	:= ""
	
	cDataFin:= DTOS(dDataFin)
	cQuery 	:= 	"SELECT "
	cQuery	+=	"P3_FILIAL,P3_DATA,  "
	cQuery	+=	"P3_FIXO,P3_MESDIA "
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName("SP3")+ " SP3 "
	cQuery	+=	"WHERE "
	cQuery	+=	"(P3_MESDIA='"+cMesDia+"' "
	cQuery  +=  "OR P3_DATA= '"+cDataFin+"') AND P3_FILIAL='"+XFILIAL("SP3")+" ' "
	cQuery	+=  "AND SP3.D_E_L_E_T_= ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpDia,.T.,.T.)

	If (cTmpDia)-> (!Eof()) 
		While (cTmpDia)-> (!Eof()) 
			If !Empty((cTmpDia)->P3_MESDIA) .OR. !Empty((cTmpDia)->P3_DATA)
				lRet := .T.
			EndIf
			(cTmpDia)->(dbSkip())
		Enddo
	Else
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} FVldInfEnv
	Funci�n utilizada para validar la correcta configuraci�n de los par�metros
	involucrados en el env�o de correos elctr�nicos.

	@type  Static Function
	@author marco.rivera
	@since 12/10/2022
	@version 1.0
	@return lRet, L�gico, .T. si est�n configurados los par�metros / .F. Si no est�n configurados los par�metros.
	@example
	FVldInfEnv()
/*/
Static Function FVldInfEnv()

	Local lRet		:= .T.
	Local cSaltoLin	:= CHR(13) + CHR(10)
	Local cServer	:= SuperGetMV("MV_RELSERV", .F., "") //Nombre de servidor de envio de E-mail utilizado en los informes.
	Local cEmail	:= SuperGetMV("MV_RELACNT", .F., "") //Cuenta a ser utilizada en el envio de E-Mail para los informes
	Local cPassword	:= SuperGetMV("MV_RELPSW", .F., "") //Contrasena de cta. de E-mail para enviar informes
	Local nPort		:= SuperGetMv("MV_SRVPORT", .F., 0)	//Puerto de conexion con el servidor de correo
	Local cMsg		:= ""

	If Empty(cServer)
		cMsg += STR0021 + STR0022 + cSaltoLin //"Configure par�metro " - "MV_RELSERV" 
	EndIf
	
	If Empty(cEmail)
		cMsg += STR0021 + STR0023 + cSaltoLin //"Configure par�metro " - "MV_RELACNT"
	EndIf
	
	If Empty(cPassword)
		cMsg += STR0021 + STR0024 + cSaltoLin // "Configure par�metro " - "MV_RELPSW"
	EndIf

	If nPort == 0
		cMsg += STR0021 + STR0045 + cSaltoLin // "Configure par�metro " - "MV_SRVPORT"
	EndIf
	
	If !Empty(cMsg)
		lRet := .F.
		Help("", 1, "HELP", , STR0046 + cSaltoLin + cMsg, 1, 0) //"Se encontraron los siguientes errores:"
	EndIf
	
Return lRet
