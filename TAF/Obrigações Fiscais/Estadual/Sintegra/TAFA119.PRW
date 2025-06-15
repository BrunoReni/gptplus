#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"       
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TAFA119.CH"     

#DEFINE IMP_SPOOL 	2
#Define oArial06	TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo L Zanaga     º Data ³  06/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao do arquivo do Sintegra                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TAFA119()
                                       
Local 	cAliasQ50	:=  GetNextAlias() 	// 50 
Local 	cAliasQ51	:=  GetNextAlias() 	// 51 
Local 	cAliasQ53	:=  GetNextAlias() 	// 53 
Local 	cAliasQ54	:=  GetNextAlias() 	// 54 
Local 	cAliasQ55	:=  GetNextAlias() 	// 55
Local 	cAliasQ56	:=  GetNextAlias() 	// 56
Local 	cAliasQ57	:=  GetNextAlias() 	// 57
Local 	cAliasQ60M	:=  GetNextAlias() 	// 60M
Local 	cAliasQ60A	:=  GetNextAlias() 	// 60A
Local 	cAliasQ60D	:=  GetNextAlias() 	// 60D
Local 	cAliasQ60I	:=  GetNextAlias() 	// 60I
Local 	cAliasQ60R	:=  GetNextAlias() 	// 60R
Local 	cAliasQ61	:=  GetNextAlias() 	// 61
Local 	cAliasQ61R	:=  GetNextAlias() 	// 61R
Local 	cAliasQ70	:=  GetNextAlias() 	// 70
Local 	cAliasQ71	:=  GetNextAlias() 	// 71
Local 	cAliasQ74	:=  GetNextAlias() 	// 74
Local 	cAliasQ75	:=  GetNextAlias() 	// 75
Local 	cAliasQ76	:=  GetNextAlias() 	// 76
Local 	cAliasQ77	:=  GetNextAlias() 	// 77
Local 	cAliasQ85	:=  GetNextAlias() 	// 85
Local 	cAliasQ86	:=  GetNextAlias() 	// 86
Local 	nPrintType 	:= 0
Local 	nLocal     	:= 0
Local 	aDevice    	:= {} 
Local 	oSetup     	:= Nil   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Necessarias quando utilizado o Objeto FwPrintsetup() que define as opcoes³
//³necessarias para a emissao do relatorio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cSession   := GetPrinterSession()
Local cDevice    := GetProfString( cSession, "PRINTTYPE", "SPOOL", .T. )
Local nFlags     := PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEPAPERSIZE+PD_DISABLEPREVIEW 
                                                 	
Local 	aLisFil		:=	{}
    
//Variaveis de processamento                                                    
Local   nX		:= 0
Local   aQueries	:= {} //Array com alias das queries
//Totalizadores             
// 	nReg50,nReg51,nReg53,nReg54,nReg55,nReg56,nReg57,nReg60M,nReg60D,nReg60A,nReg60I,nReg60R,nReg61,nReg61R,
//	nReg70,nReg71,nReg74,nReg75,nReg76,nReg77,nReg85,nReg86
Local	aSeqs		:= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

Local cCGC	:=	SM0->M0_CGC
Local cInsc	:=	ARETDIG(SM0->M0_INSC,.T.,SM0->M0_ESTENT)
Local cFaxAux:=	SM0->M0_FAX
Local nVirgula	:= Rat(",",SM0->M0_ENDENT)
Local nNumero 	:= val(AllTrim(SubStr(SM0->M0_ENDENT,nVirgula+1)))
Local cEnderec	:= PadR(IIf(nNumero!=0,SubStr(SM0->M0_ENDENT,1,nVirgula-1),SM0->M0_ENDENT),34)
Local cTelEAux	:= SM0->M0_TEL
Local cContato	:=	GetMV("MV_RESPFIS")
Local cTel		:=	""
Local cFax		:=	""
Local nY		:=	1  
Local lProcArq	 	:= .T.

Local cFunction := ProcName()
Local nOpc      := 2 //View

Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()

Private nDisco	:=1
Private nRegN0	:=0

Private Nomeprog	:= "TAFA119"                   
Private cPerg		:= "TAFA119" 
Private lCancel		:= .F.                      
Private oProcess	:= NIL
Private	nHandle		:= -1

Private __cTrbName
Private __cDest
Private cFilAtu		:= cFilAnt
Private oPrint	    := FWMSPrinter():New( "Sintegra" , IMP_SPOOL , .F., , .T. ) 

//Função para gravar o uso de rotinas e enviar ao LS (License Server)
Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

//Protect Data / Log de acesso / Central de Obrigacoes
Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

//Seleciona filiais
If MV_PAR17 == 1   
	aLisFil  :=	xFunTelaFil(.T.)
	If Empty(aLisFil)
		lProcArq	:= .F.
	EndIf		
EndIf	   
	
If lProcArq 
	AvlDrv(@nHandle,1,1)
	
	//Registro 10
	
	// Retira caracteres do campo cTeleAux
	For nY:=1 To Len(cTeleAux)
		If IsDigit(Subs(cTeleAux,nY,1))
			cTel	+= Subs(cTeleAux,nY,1)
		Endif
	Next
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando nao ha virgula no endereco procura-se o caracter branco³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( nVirgula == 0 )
		nVirgula 	:= Rat(" ",AllTrim(SM0->M0_ENDENT))
		nNumero		:= Val(AllTrim(SubStr(SM0->M0_ENDENT,nVirgula+1)))
		cEnderec	:= PadR(IIf(nNumero!=0,SubStr(SM0->M0_ENDENT,1,nVirgula-1),SM0->M0_ENDENT),34)
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retira caracteres do campo cFax³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY:=1 To Len(cFaxAux)
		If IsDigit(Subs(cFaxAux,nY,1))
			cFax += Subs(cFaxAux,nY,1)
		Endif
	Next
	If Empty(cCGC)
		cCGC	:=	Replic("0",14)
	Endif
	    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro TIPO 10 Mestre de Estabelecimento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	R119Reg10(cCGC,cInsc, cFax)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro TIPO 11 Complemento do estabelecimento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	R119Reg11(cEnderec,nNumero,cContato,cTEL)   
	           
	//Adiciona queries a executar em um vetor
	aAdd(aQueries,{cAliasQ50,cAliasQ51,cAliasQ53,cAliasQ54,cAliasQ55,cAliasQ56,cAliasQ57,cAliasQ60M,cAliasQ60A,cAliasQ60D,cAliasQ60I,cAliasQ60R,;
	               cAliasQ61,cAliasQ61R,cAliasQ70,cAliasQ71,cAliasQ74,cAliasQ75,cAliasQ76,cAliasQ77,cAliasQ85,cAliasQ86})
	If Len(aLisFil) > 0
	   //50 filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'50','')				
		   	EndIf
	   Next nX
	   //51 IPI filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'51','')				
		   	EndIf
	   Next nX	   
	   //53 ST filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'53','')				
		   	EndIf
	   Next nX	   
	
	   //54 filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'54','')				
		   	EndIf
	   Next nX	   
		          
	   //56 filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'56','')				
		   	EndIf
	   Next nX	   
	
	   //55 filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
		If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'55','')				
		   	EndIf
	   Next nX	   
	
	   //57 filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'57','')				
		   	EndIf
	   Next nX	   
	
	   //60M e demais filhos, filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'60','M')				
		   	EndIf
	   Next nX	   
	
	   //60R e demais filhos, filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'60','R')				
		   	EndIf
	   Next nX	   
	
	   //61 , filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'61','')				
		   	EndIf
	   Next nX	   
	
	   //61R, filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'61','R')				
		   	EndIf
	   Next nX	   
	
       //70, filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'70','')				
		   	EndIf
	   Next nX	   
	
       //71, filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'71','')				
		   	EndIf
	   Next nX	   
	
       //74, filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'74','')				
		   	EndIf
	   Next nX	   
	
       //75, filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'75','')				
		   	EndIf
	   Next nX	   
	
       //76, filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'76','')				
		   	EndIf
	   Next nX	   

       //77, filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'77','')				
		   	EndIf
	   Next nX	   
	
       //85, filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'85','')
			EndIf
	   Next nX	   

       //86, filiais selecionadas
	   For nX := 1 To Len(aLisFil)	   
			If (aLisFil[nX,1]) // Existe e esta marcada
			   	SM0->(MsSeek (cEmpAnt+aLisFil[nX,2], .T.))
				cFilAnt := FWGETCODFILIAL
				R119Proc(aQueries,@aSeqs,'86','')
			EndIf
	   Next nX	   
	   
   	   SM0->(MsSeek (cEmpAnt+cFilAtu, .T.))
	   cFilAnt := FWGETCODFILIAL
	Else
		R119Proc(aQueries,@aSeqs)				
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro TIPO 90 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	R119Reg90(aSeqs)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha Arquivo Aberto Anteriormente                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SaveTxt( nHandle , __cTrbName , __cDest )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra o resumo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define os Tipos de Impressao validos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aDevice,"DISCO") 
	AADD(aDevice,"SPOOL") 
	AADD(aDevice,"EMAIL") 
	AADD(aDevice,"EXCEL") 
	AADD(aDevice,"HTML" ) 
	AADD(aDevice,"PDF"  ) 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza as configuracoes necessarias para a impressao da GNRE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPrintType := aScan(aDevice,{|x| x == cDevice }) 
	nLocal     := If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
		
	oSetup := FWPrintSetup():New(nFlags, "Sintegra")
	
	
	//oSetup:SetUserParms( {|| Pergunte(cPerg, .T.) } ) 
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , 2) 
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {10,10,10,10})
	oSetup:SetPropert(PD_PAPERSIZE   , 2) 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Confirmando a tela de Configuracao eu inicio a Impressao do Relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oSetup:Activate() == PD_OK                		 			
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializacao do objeto grafico  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:lServer := oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER                      
		//Formato da impressao -> Retrato
		oPrint:SetResolution(75)
		oPrint:SetPortrait()       
		oPrint:SetPaperSize(DMPAPER_A4)
		oPrint:SetMargin(60,60,60,60)
			
		//oPrint:SetLandscape()
			
		// ----------------------------------------------
		// Define saida de impressão
		// ----------------------------------------------
		If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
			oPrint:nDevice := IMP_SPOOL
			// ----------------------------------------------
			// Salva impressora selecionada
			// ----------------------------------------------
			WriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)  //fabio
			oPrint:cPrinter := oSetup:aOptions[PD_VALUETYPE]
		ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
			oPrint:nDevice := IMP_PDF
			// ----------------------------------------------
			// Define para salvar o PDF
			// ----------------------------------------------
			oPrint:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
		Endif 
	
		oPrint:StartPage()
		R119ImpRes(aSeqs)
		oPrint:EndPage()			
		oPrint:Preview()
	EndIf
EndIf

oPrint:Deactivate()

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processo geral dos registros                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Proc(aQueries,aSeqs,cReg,cSubReg);				   

//Reguas de processamento                                                    
Local    bPrepR50 	:= 	{ |lEnd| R119AddLin(aQueries[1][1],'50',,@aSeqs,aQueries) }
Local    bPrepR51 	:= 	{ |lEnd| R119AddLin(aQueries[1][2],'51',,@aSeqs,aQueries) }
Local    bPrepR53 	:= 	{ |lEnd| R119AddLin(aQueries[1][3],'53',,@aSeqs,aQueries) }
Local    bPrepR54 	:= 	{ |lEnd| R119AddLin(aQueries[1][4],'54',,@aSeqs,aQueries) }
Local    bPrepR55 	:= 	{ |lEnd| R119AddLin(aQueries[1][5],'55',,@aSeqs,aQueries) }
Local    bPrepR56 	:= 	{ |lEnd| R119AddLin(aQueries[1][6],'56',,@aSeqs,aQueries) }
Local    bPrepR57 	:= 	{ |lEnd| R119AddLin(aQueries[1][7],'57',,@aSeqs,aQueries) }
Local    bPrepR60M 	:= 	{ |lEnd| R119AddLin(aQueries[1][8],'60','M',@aSeqs,aQueries) }
Local    bPrepR60R 	:= 	{ |lEnd| R119AddLin(aQueries[1][12],'60','R',@aSeqs,aQueries) }
Local    bPrepR61 	:= 	{ |lEnd| R119AddLin(aQueries[1][13],'61',,@aSeqs,aQueries) }
Local    bPrepR61R 	:= 	{ |lEnd| R119AddLin(aQueries[1][14],'61','R',@aSeqs,aQueries) }
Local    bPrepR70 	:= 	{ |lEnd| R119AddLin(aQueries[1][15],'70',,@aSeqs,aQueries) }
Local    bPrepR71 	:= 	{ |lEnd| R119AddLin(aQueries[1][16],'71',,@aSeqs,aQueries) }
Local    bPrepR74 	:= 	{ |lEnd| R119AddLin(aQueries[1][17],'74',,@aSeqs,aQueries) }
Local    bPrepR75 	:= 	{ |lEnd| R119AddLin(aQueries[1][18],'75',,@aSeqs,aQueries) }
Local    bPrepR76 	:= 	{ |lEnd| R119AddLin(aQueries[1][19],'76',,@aSeqs,aQueries) }
Local    bPrepR77 	:= 	{ |lEnd| R119AddLin(aQueries[1][20],'77',,@aSeqs,aQueries) }
Local    bPrepR85 	:= 	{ |lEnd| R119AddLin(aQueries[1][21],'85',,@aSeqs,aQueries) }
Local    bPrepR86 	:= 	{ |lEnd| R119AddLin(aQueries[1][22],'86',,@aSeqs,aQueries) }

Default  cReg		:=	""
Default  cSubReg	:=	""

//Reg 50 - Todos
If (cReg == "" .Or. cReg == '50')
	R119Q50(aQueries[1][1],'50') 
	If !(aQueries[1][1])->(Eof())
		Processa( bPrepR50  ,'',STR0010)
	EndIf                     
	(aQueries[1][1])->(DBCLOSEAREA())
EndIf
	
//Reg 51 IPI
If (cReg == "" .Or. cReg == '51')
	R119Q51(aQueries[1][2],'51') 
	If !(aQueries[1][2])->(Eof())
		Processa( bPrepR51  ,'',STR0011)
	EndIf
	(aQueries[1][2])->(DBCLOSEAREA())	
EndIf

//Reg 53 ICMS ST
If (cReg == "" .Or. cReg == '53')
	R119Q53(aQueries[1][3],'53') 
	If !(aQueries[1][3])->(Eof())
		Processa( bPrepR53  ,'',STR0012)
	EndIf
	(aQueries[1][3])->(DBCLOSEAREA())	
EndIf

//Reg 54 Itens  
If (cReg == "" .Or. (cReg == '54' .And. cSubReg == ''))
	R119Q54(aQueries[1][4]) 
	If !(aQueries[1][4])->(Eof())
		Processa( bPrepR54  ,'',STR0013)
	EndIf
	(aQueries[1][4])->(DBCLOSEAREA())	
EndIf

//Reg 56 Veiculos
If (cReg == "" .Or. (cReg == '56' .And. cSubReg == ''))
	R119Q56(aQueries[1][6])   
	If !(aQueries[1][6])->(Eof())
		Processa( bPrepR56  ,'',STR0015)
	EndIf	     
	(aQueries[1][6])->(DBCLOSEAREA())
EndIf

//Reg 55 GNRE
If (cReg == "" .Or. (cReg == '55' .And. cSubReg == ''))
	R119Q55(aQueries[1][5],"('"+cFilAnt+"')")   
	If !(aQueries[1][5])->(Eof())
		Processa( bPrepR55  ,'',STR0014)
	EndIf	     
	(aQueries[1][5])->(DBCLOSEAREA())   
EndIf

//Reg 57 Lote de Medicamentos
If (cReg == "" .Or. (cReg == '57' .And. cSubReg == ''))
	R119Q57(aQueries[1][7])   
	If !(aQueries[1][7])->(Eof())
		Processa( bPrepR57  ,'',STR0016)
	EndIf	     
	(aQueries[1][7])->(DBCLOSEAREA())
EndIf
          
//Reg 60M ECF Mestre
If (MV_PAR07 >= 2)	.And. (MV_PAR10 == 	1)	// Gera somente se for Saidas
	If (cReg == "" .Or. (cReg == '60' .And. cSubReg == 'M')	)
		R119Q60M(aQueries[1][8])   
		If !(aQueries[1][8])->(Eof())                         	
			Processa( bPrepR60M,'',STR0017)
		EndIf	             
		//Fecha query de ECF, as demais sao fechadas no loop principal
		(aQueries[1][8])->(DBCLOSEAREA())
	EndIf    

	If MV_PAR13 == 1			// Gera 60R, sim ou nao		    
	    //Reg 60R Resumo Mensal
		If (cReg == "" .Or. (cReg == '60' .And. cSubReg == 'R'))	
			R119Q60R(aQueries[1][12])   
			If !(aQueries[1][12])->(Eof())
				Processa( bPrepR60R,'',STR0021)
			EndIf	             
			(aQueries[1][12])->(DBCLOSEAREA())
		EndIf	
	EndIf
		
    //Reg 61 ECF sem equip. ECF
	If (cReg == "" .Or. (cReg == '61' .And. cSubReg == '')	)
		R119Q61(aQueries[1][13])   
		If !(aQueries[1][13])->(Eof())
			Processa( bPrepR61,'',STR0022)
		EndIf	             
		(aQueries[1][13])->(DBCLOSEAREA())
	EndIf
	
	If MV_PAR14 == 1			// Gera 61R, sim ou nao		    
	    //Reg 61R, itens ECF sem equip. ECF
		If (cReg == "" .Or. (cReg == '61' .And. cSubReg == 'R')	)
			R119Q61R(aQueries[1][14])   
			If !(aQueries[1][14])->(Eof())
				Processa( bPrepR61R,'',STR0023)
			EndIf	             
			(aQueries[1][14])->(DBCLOSEAREA())
		EndIf	
	EndIf        
EndIf    

//Reg 70 
If (cReg == "" .Or. (cReg == '70' .And. cSubReg == '')	)
	R119Q70(aQueries[1][15])   
	If !(aQueries[1][15])->(Eof())
		Processa( bPrepR70,'',STR0024)
	EndIf	             
	(aQueries[1][15])->(DBCLOSEAREA())
EndIf

//Reg 71 
If (cReg == "" .Or. (cReg == '71' .And. cSubReg == '')	)
	R119Q71(aQueries[1][16])   
	If !(aQueries[1][16])->(Eof())
		Processa( bPrepR71,'',STR0025)
	EndIf	             
	(aQueries[1][16])->(DBCLOSEAREA())
EndIf

//Reg 74 
If MV_PAR08 == 1
	If (cReg == "" .Or. (cReg == '74' .And. cSubReg == '')	)
		R119Q74(aQueries[1][17])   
		If !(aQueries[1][17])->(Eof())
			Processa( bPrepR74,'',STR0026)
		EndIf	             
		(aQueries[1][17])->(DBCLOSEAREA())
	EndIf	
EndIf    

//Reg 75 
If (cReg == "" .Or. (cReg == '75' .And. cSubReg == '')	)
	R119Q75(aQueries[1][18])   
	If !(aQueries[1][18])->(Eof())
		Processa( bPrepR75,'',STR0027)
	EndIf	             
	(aQueries[1][18])->(DBCLOSEAREA())
EndIf

//Reg 76 
If (cReg == "" .Or. (cReg == '76' .And. cSubReg == '')	)
	R119Q76(aQueries[1][19])   
	If !(aQueries[1][19])->(Eof())
		Processa( bPrepR76,'',STR0028)
	EndIf	             
	(aQueries[1][19])->(DBCLOSEAREA())
EndIf

//Reg 77 
If (cReg == "" .Or. (cReg == '77' .And. cSubReg == '')	)
	R119Q77(aQueries[1][20])   
	If !(aQueries[1][20])->(Eof())
		Processa( bPrepR77,'',STR0029)
	EndIf	             
	(aQueries[1][20])->(DBCLOSEAREA())
EndIf

//Reg 85 Exportacaoes - Mestre
If (cReg == "" .Or. (cReg == '85' .And. cSubReg == '')	)
	R119Q85(aQueries[1][21],'85') 
	If !(aQueries[1][21])->(Eof())
		Processa( bPrepR85  ,'',STR0030)
	EndIf
	(aQueries[1][21])->(DBCLOSEAREA())	
EndIf

//Reg 86 Exportacaoes - Detalhe
If (cReg == "" .Or. (cReg == '86' .And. cSubReg == '')	)
	R119Q86(aQueries[1][22],'86') 
	If !(aQueries[1][22])->(Eof())
		Processa( bPrepR86  ,'',STR0031)
	EndIf
	(aQueries[1][22])->(DBCLOSEAREA())	
EndIf
      
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 50                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q50(cAliasQ,cReg) 
Local   cQuery	:=	""  

/*----------------------------------------------------------
Query principal do movimento para gerar o registro C50
----------------------------------------------------------*/ 
cQuery	+=	"SELECT "
cQuery	+=	"R50.C20_FILIAL, "
cQuery	+=	"R50.C20_CHVNF, " 
cQuery	+=	"C1H.C1H_PPES, " 
cQuery	+=	"C1H.C1H_CPF, " 
cQuery	+=	"C1H.C1H_CNPJ, " 
cQuery	+=	"C1H.C1H_IE, "   
cQuery	+=	"R50.C20_DTES, "
cQuery	+=	"C09.C09_UF, "  
cQuery	+=	"C01.C01_CODIGO, "   
cQuery	+=	"R50.C20_SERIE, " 
cQuery	+=	"R50.C20_NUMDOC, " 
cQuery	+=	"R50.C20_INDEMI, "    
cQuery	+=	"R50.C20_INDOPE, "
cQuery	+=	"C2F.C2F_BASE TOTAL, "
cQuery	+=	"C02.C02_CODIGO, "
cQuery	+=	"C3S.C3S_CODIGO, "
cQuery	+=	"C0Y.C0Y_CODIGO, "
cQuery	+=	"C2F.C2F_ALIQ, "      
cQuery	+=	"C2F.C2F_BASE BASE, "
cQuery	+=	"C2F.C2F_VALOR VALOR, "  
cQuery	+=	"(C2F.C2F_VLNT+C2F.C2F_VLISEN)  ISENTA, "
cQuery	+=	"C2F.C2F_VLOUTR OUTRAS "
cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " R50 "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C2F' ) + " C2F ON(C2F.C2F_FILIAL='" + xFilial('C2F') + "' AND C2F.C2F_FILIAL=R50.C20_FILIAL AND C2F.C2F_CHVNF=R50.C20_CHVNF AND C2F.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C3S' ) + " C3S ON(C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND C3S.C3S_ID=C2F.C2F_CODTRI AND C3S.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0Y' ) + " C0Y ON(C0Y.C0Y_FILIAL='" + xFilial('C0Y') + "' AND C0Y.C0Y_ID=C2F.C2F_CFOP   AND C0Y.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0U' ) + " C0U ON(C0U.C0U_FILIAL='" + xFilial('C0U') + "' AND C0U.C0U_ID=R50.C20_TPDOC  AND C0U.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=R50.C20_CODMOD AND C01.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C02' ) + " C02 ON(C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=R50.C20_CODSIT AND C02.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1H' ) + " C1H ON(C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=R50.C20_CODPAR AND C1H.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C09' ) + " C09 ON(C09.C09_FILIAL='" + xFilial('C09') + "' AND C09.C09_ID=C1H.C1H_UF     AND C09.D_E_L_E_T_=' ') "
cQuery	+=	" WHERE "                                                                                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery +=  " R50.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND R50.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cQuery +=  " AND R50.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cQuery +=  " AND C01.C01_CODIGO IN('01','04','06','21','22','55') "
cQuery +=  " AND C0U.C0U_CODIGO IN('00','02') "
cQuery += "  AND C3S.C3S_CODIGO IN('02','03','05', '17') "
cQuery +=  " AND C2F.D_E_L_E_T_=' ' "

//Est. Origem/Destino
If Alltrim(MV_PAR05)<>"" 
	cQuery += " AND C09.C09_UF = '" + MV_PAR05 + "' "
EndIf


If 		MV_PAR07 == 1 //Entrada
	cQuery += " AND R50.C20_INDOPE = '0' "
ElseIf 	MV_PAR07 == 2 //Saida
	cQuery += " AND R50.C20_INDOPE = '1' "
EndIf
cQuery += " AND R50.D_E_L_E_T_ = '' " 

//NATUREZA DAS OPERACOES!
If (MV_PAR15==1)
	If mv_par07 == 1 		//Entrada
		cQuery +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2') AND C3S.C3S_CODIGO = '04' "
	Elseif mv_par07 == 2 	//Saida
		cQuery +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') AND C3S.C3S_CODIGO = '04' "
	Else
		cQuery +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') AND C3S.C3S_CODIGO = '04' "
	Endif
ElseIf (MV_PAR15==2)
	If mv_par07 == 1 		//Entrada
		cQuery +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2') "
	Elseif mv_par07 == 2 	//Saida
		cQuery +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') "
	Else
		cQuery +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') "
	Endif
ElseIf (MV_PAR15==3)
	If mv_par07 == 1 		//Entrada
		cQuery +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='1' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='3') "
	Elseif mv_par07 == 2 	//Saida
		cQuery +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='5' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='7') "
	Endif
EndIf 			                                            

cQuery 	+= " ORDER BY 11,5,9 " //Ordem reg 50 data

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQ)
                               
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 51                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q51(cAliasQ,cReg) 
Local   cQuery	:=	""

/*----------------------------------------------------------
Query principal do movimento para gerar o registro C51
----------------------------------------------------------*/ 
cQuery	+=	"SELECT "
cQuery	+=	"R50.C20_FILIAL, "
cQuery	+=	"R50.C20_CHVNF, " 
cQuery	+=	"C1H.C1H_PPES, " 
cQuery	+=	"C1H.C1H_CPF, " 
cQuery	+=	"C1H.C1H_CNPJ, " 
cQuery	+=	"C1H.C1H_IE, "   
cQuery	+=	"R50.C20_DTES, "
cQuery	+=	"C09.C09_UF, "  
cQuery	+=	"C01.C01_CODIGO, "   
cQuery	+=	"R50.C20_SERIE, " 
cQuery	+=	"R50.C20_NUMDOC, " 
cQuery	+=	"C02.C02_CODIGO, "
cQuery	+=	"C0Y.C0Y_CODIGO CFOP, "
cQuery	+=	"R50.C20_VLDOC C20_VLDOC, " 
cQuery	+=	"SUM(C2F.C2F_VALOR) VLIPI, "  
cQuery	+=	"SUM(C2F.C2F_VLNT+C2F.C2F_VLISEN) ISENTA, "
cQuery	+=	"SUM(C2F.C2F_VLOUTR) OUTRAS "
cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " R50 "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C2F' ) + " C2F ON(C2F.C2F_FILIAL='" + xFilial('C2F') + "' AND C2F.C2F_FILIAL=R50.C20_FILIAL AND C2F.C2F_CHVNF=R50.C20_CHVNF AND C2F.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C3S' ) + " C3S ON(C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND C3S.C3S_ID=C2F.C2F_CODTRI AND C3S.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0Y' ) + " C0Y ON(C0Y.C0Y_FILIAL='" + xFilial('C0Y') + "' AND C0Y.C0Y_ID=C2F.C2F_CFOP   AND C0Y.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0U' ) + " C0U ON(C0U.C0U_FILIAL='" + xFilial('C0U') + "' AND C0U.C0U_ID=R50.C20_TPDOC  AND C0U.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=R50.C20_CODMOD AND C01.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C02' ) + " C02 ON(C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=R50.C20_CODSIT AND C02.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1H' ) + " C1H ON(C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=R50.C20_CODPAR AND C1H.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C09' ) + " C09 ON(C09.C09_FILIAL='" + xFilial('C09') + "' AND C09.C09_ID=C1H.C1H_UF     AND C09.D_E_L_E_T_=' ') "
cQuery	+=	" WHERE "                                                                                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery +=  " R50.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND R50.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cQuery +=  " AND R50.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cQuery +=  " AND C01.C01_CODIGO IN('01','55') "
cQuery +=  " AND C0U.C0U_CODIGO IN('00') "
cQuery +=  " AND C3S.C3S_CODIGO = '05' "

//Est. Origem/Destino
If Alltrim(MV_PAR05)<>""
	cQuery += " AND C09.C09_UF = '" + MV_PAR05 + "' "
EndIf

If 		MV_PAR07 == 1 //Entrada
	cQuery += " AND R50.C20_INDOPE = '0' "
ElseIf 	MV_PAR07 == 2 //Saida
	cQuery += " AND R50.C20_INDOPE = '1' "
EndIf

cQuery += " AND R50.D_E_L_E_T_ = '' " 
cQuery += " GROUP BY "
cQuery += " R50.C20_FILIAL, R50.C20_CHVNF, C1H.C1H_PPES, C1H.C1H_CPF, C1H.C1H_CNPJ, C1H.C1H_IE, R50.C20_DTES, C09.C09_UF,C01.C01_CODIGO,R50.C20_SERIE,R50.C20_NUMDOC,C02.C02_CODIGO,C0Y.C0Y_CODIGO,R50.C20_VLDOC "
cQuery += " ORDER BY 5 " //ordenacao por data

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQ)
                               
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 53                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q53(cAliasQ,cReg) 
Local   cQuery	:=	""

/*----------------------------------------------------------
Query principal do movimento para gerar o registro C53
----------------------------------------------------------*/ 
cQuery	+=	"SELECT * FROM ("
cQuery	+=	"SELECT DISTINCT "
cQuery	+=	"R50.C20_FILIAL, "                                      
cQuery	+=	"R50.C20_CHVNF, "
cQuery	+=	"C1H.C1H_PPES, " 
cQuery	+=	"C1H.C1H_CPF, " 
cQuery	+=	"C1H.C1H_CNPJ, " 
cQuery	+=	"C1H.C1H_IE, "   
cQuery	+=	"R50.C20_DTES, "
cQuery	+=	"C09.C09_UF, "  
cQuery	+=	"C01.C01_CODIGO, "   
cQuery	+=	"R50.C20_SERIE, " 
cQuery	+=	"R50.C20_NUMDOC, " 
cQuery	+=	"R50.C20_INDEMI, " 
cQuery	+=	"C02.C02_CODIGO, "
cQuery	+=	"C0Y.C0Y_CODIGO CFOP, "
cQuery	+=	"(SELECT SUM(TRIB.C2F_BASE) FROM " + RetSqlName( 'C2F' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C2F_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='04' AND TRIB.C2F_FILIAL=R50.C20_FILIAL AND TRIB.C2F_CHVNF=R50.C20_CHVNF AND TRIB.D_E_L_E_T_=' ') BCST, "
cQuery	+=	"(SELECT SUM(TRIB.C2F_VALOR) FROM " + RetSqlName( 'C2F' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C2F_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO='04' AND TRIB.C2F_FILIAL=R50.C20_FILIAL AND TRIB.C2F_CHVNF=R50.C20_CHVNF AND TRIB.D_E_L_E_T_=' ') ICMSRET, "
cQuery	+=	"(R50.C20_VLOUDE+R50.C20_VLRSEG+R50.C20_VLRFRT) VLRDA " 
cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " R50 "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C30' ) + " C30 ON(C30.C30_FILIAL='" + xFilial('C30') + "' AND C30.C30_FILIAL=R50.C20_FILIAL AND C30.C30_CHVNF=R50.C20_CHVNF AND C30.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C35' ) + " C35 ON(C35.C35_FILIAL='" + xFilial('C35') + "' AND C35.C35_FILIAL=C30.C30_FILIAL AND C35.C35_CHVNF=C30.C30_CHVNF AND C35.C35_CODITE=C30.C30_CODITE AND C35.C35_NUMITE=C30.C30_NUMITE AND C35.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0Y' ) + " C0Y ON(C0Y.C0Y_FILIAL='" + xFilial('C0Y') + "' AND C0Y.C0Y_ID=C30.C30_CFOP   AND C0Y.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0U' ) + " C0U ON(C0U.C0U_FILIAL='" + xFilial('C0U') + "' AND C0U.C0U_ID=R50.C20_TPDOC  	AND C0U.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=R50.C20_CODMOD 	AND C01.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C02' ) + " C02 ON(C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=R50.C20_CODSIT 	AND C02.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1H' ) + " C1H ON(C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=R50.C20_CODPAR 	AND C1H.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C09' ) + " C09 ON(C09.C09_FILIAL='" + xFilial('C09') + "' AND C09.C09_ID=C1H.C1H_UF     	AND C09.D_E_L_E_T_=' ') "
cQuery	+=	" WHERE "                                                                                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery +=  " R50.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND R50.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cQuery +=  " AND R50.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cQuery +=  " AND C01.C01_CODIGO IN('01','06','55') "
cQuery +=  " AND C0U.C0U_CODIGO IN('00') "        
cQuery +=  " AND C35.D_E_L_E_T_=' ' "                                            

//Est. Origem/Destino
If Alltrim(MV_PAR05)<>"" 
	cQuery += " AND C09.C09_UF = '" + MV_PAR05 + "' "
EndIf

If 		MV_PAR07 == 1 //Entrada
	cQuery += " AND R50.C20_INDOPE = '0' "
ElseIf 	MV_PAR07 == 2 //Saida
	cQuery += " AND R50.C20_INDOPE = '1' "
EndIf

cQuery += " AND R50.D_E_L_E_T_ = '') TBL" 

//NATUREZA DAS OPERACOES!
If (MV_PAR15==1)
	If mv_par07 == 1 		//Entrada
		cQuery +=	"  WHERE (SUBSTRING(CFOP,1,1)='2') AND ICMSRET>0 "
	Elseif mv_par07 == 2 	//Saida
		cQuery +=	"  WHERE (SUBSTRING(CFOP,1,1)='6') AND ICMSRET>0 "
	Else
		cQuery +=	"  WHERE (SUBSTRING(CFOP,1,1)='2' OR SUBSTRING(CFOP,1,1)='6') AND ICMSRET>0 "
	Endif
ElseIf (MV_PAR15==2)
	If mv_par07 == 1 		//Entrada
		cQuery +=	"  WHERE (SUBSTRING(CFOP,1,1)='2') "
	Elseif mv_par07 == 2 	//Saida
		cQuery +=	"  WHERE (SUBSTRING(CFOP,1,1)='6') "
	Else
		cQuery +=	"  WHERE (SUBSTRING(CFOP,1,1)='2' OR SUBSTRING(CFOP,1,1)='6') "
	Endif
ElseIf (MV_PAR15==3)
	If mv_par07 == 1 		//Entrada
		cQuery +=	"  WHERE (SUBSTRING(CFOP,1,1)='1' OR SUBSTRING(CFOP,1,1)='2' OR SUBSTRING(CFOP,1,1)='3') "
	Elseif mv_par07 == 2 	//Saida
		cQuery +=	"  WHERE (SUBSTRING(CFOP,1,1)='5' OR SUBSTRING(CFOP,1,1)='6' OR SUBSTRING(CFOP,1,1)='7') "
	Endif
EndIf 			
cQuery += " ORDER BY 5 " //Ordenacao por data

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQ)
                               
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 54                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q54(cAliasQ) 
Local cQuery	:=	""

/*----------------------------------------------------------
Query principal do movimento para gerar o registro C54
----------------------------------------------------------*/ 
cQuery	+=	"SELECT * FROM ("
cQuery	+=	"SELECT "
cQuery	+=	"R54.c20_chvnf,  "
cQuery	+=	"C30.c30_numite, "
cQuery	+=	"C1L.c1l_codigo, "
cQuery	+=	"C30.c30_quant,  "
cQuery	+=	"C0B.C0B_CODIGO, "
cQuery	+=	"R54.C20_VLDOC c30_total,  "
cQuery	+=	"C30.C30_TOTAL C30_TOTAL1,  "
cQuery	+=	"C1H.C1H_PPES,   "
cQuery	+=	"C1H.C1H_CPF,   "
cQuery	+=	"C1H.c1h_cnpj,   "
cQuery	+=	"C01.c01_codigo, "
cQuery	+=	"R54.c20_serie,  "
cQuery	+=	"R54.C20_SUBSER, "
cQuery	+=	"R54.c20_numdoc, "
cQuery	+=	"C0Y.c0y_codigo, "
cQuery	+=	"C03.c03_codigo, "
cQuery	+=	"C30.c30_vldesc, "
cQuery	+=	"R54.c20_vlrfrt, "
cQuery	+=	"R54.c20_vlrseg, "
cQuery	+=	"R54.c20_vlrda,  "
cQuery	+=	"C34.C34_CNPJ, "
cQuery	+=	"C34.C34_CHASSI, "
cQuery	+=	"C34.C34_INDVEI, "
cQuery	+=	"C31.C31_LOTE, "
cQuery	+=	"C3S.C3S_CODIGO, "
cQuery	+=	"C35.C35_ALIQ, "
cQuery	+=	"C35.C35_BASE, "
cQuery	+=	"C35.C35_VALOR, "  
cQuery	+=	"(SELECT MAX(C14.C14_CODIGO) FROM " + RetSqlName( 'C14' ) + " C14, " + RetSqlName( 'C35' ) + " C35, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND C14.C14_FILIAL='" + xFilial('C14') + "' AND C35.C35_FILIAL='" + xFilial('C35') + "' AND C14.C14_ID=C35.C35_CST AND C14.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO IN('02','03','17') AND C3S.C3S_ID=C35.C35_CODTRI AND C3S.D_E_L_E_T_=' ' AND C35.C35_FILIAL=C30.C30_FILIAL AND C35.C35_CHVNF=C30.C30_CHVNF AND C35.C35_NUMITE=C30.C30_NUMITE AND C35.D_E_L_E_T_=' ') CSTICM, "   
cQuery	+=	"(SELECT SUM(TRIB.C35_VALOR) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO IN('06','07') AND TRIB.C35_FILIAL=C30.C30_FILIAL AND TRIB.C35_CHVNF=C30.C30_CHVNF AND TRIB.C35_NUMITE=C30.C30_NUMITE AND TRIB.D_E_L_E_T_=' ') PISCOF, "
cQuery	+=	"(SELECT SUM(TRIB.C35_VALOR) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO IN('03') AND TRIB.C35_FILIAL=C30.C30_FILIAL AND TRIB.C35_CHVNF=C30.C30_CHVNF AND TRIB.C35_NUMITE=C30.C30_NUMITE AND TRIB.D_E_L_E_T_=' ') ICMCMP, "
cQuery	+=	"(SELECT SUM(TRIB.C35_VALOR) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO IN('01') AND TRIB.C35_FILIAL=C30.C30_FILIAL AND TRIB.C35_CHVNF=C30.C30_CHVNF AND TRIB.C35_NUMITE=C30.C30_NUMITE AND TRIB.D_E_L_E_T_=' ') VLRISS, "
cQuery	+=	"(SELECT SUM(TRIB.C35_VALOR) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_=' ' AND C3S.C3S_CODIGO IN('05') AND TRIB.C35_FILIAL=C30.C30_FILIAL AND TRIB.C35_CHVNF=C30.C30_CHVNF AND TRIB.C35_NUMITE=C30.C30_NUMITE AND TRIB.D_E_L_E_T_=' ') VLRIPI, "
cQuery	+=  "C30.C30_CODITE "
cQuery	+=	"FROM " + RetSqlName( 'C20' ) + " R54 "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C30' ) + " C30 ON(C30.C30_FILIAL='" + xFilial('C30') + "' AND C30.C30_FILIAL=R54.C20_FILIAL AND C30.C30_CHVNF=R54.C20_CHVNF AND C30.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C35' ) + " C35 ON(C35.C35_FILIAL='" + xFilial('C35') + "' AND C35.C35_FILIAL=C30.C30_FILIAL AND C35.C35_CHVNF=C30.C30_CHVNF AND C35.C35_CODITE=C30.C30_CODITE AND C35.C35_NUMITE=C30.C30_NUMITE AND C30.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C3S' ) + " C3S ON(C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND C3S.C3S_ID=C35.C35_CODTRI AND C3S.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C34' ) + " C34 ON(C34.C34_FILIAL='" + xFilial('C34') + "' AND C34.C34_FILIAL=C30.C30_FILIAL AND C34.C34_CHVNF=C30.C30_CHVNF AND C34.C34_CODITE=C30.C30_CODITE AND C34.C34_NUMITE=C30.C30_NUMITE AND C34.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C31' ) + " C31 ON(C31.C31_FILIAL='" + xFilial('C31') + "' AND C31.C31_FILIAL=C30.C30_FILIAL AND C31.C31_CHVNF=C30.C30_CHVNF AND C31.C31_CODITE=C30.C30_CODITE AND C31.C31_NUMITE=C30.C30_NUMITE AND C31.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C03' ) + " C03 ON(C03.C03_FILIAL='" + xFilial('C03') + "' AND C03.C03_ID=C30.C30_ORIGEM     AND C03.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0B' ) + " C0B ON(C0B.C0B_FILIAL='" + xFilial('C0B') + "' AND C0B.C0B_ID=C30.C30_CODSER     AND C0B.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C0Y' ) + " C0Y ON(C0Y.C0Y_FILIAL='" + xFilial('C0Y') + "' AND C0Y.C0Y_ID=C30.C30_CFOP     AND C0Y.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C01' ) + " C01 ON(C01.C01_FILIAL='" + xFilial('C01') + "' AND C01.C01_ID=R54.C20_CODMOD   AND C01.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C02' ) + " C02 ON(C02.C02_FILIAL='" + xFilial('C02') + "' AND C02.C02_ID=R54.C20_CODSIT   AND C02.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1H' ) + " C1H ON(C1H.C1H_FILIAL='" + xFilial('C1H') + "' AND C1H.C1H_ID=R54.C20_CODPAR   AND C1H.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C09' ) + " C09 ON(C09.C09_FILIAL='" + xFilial('C09') + "' AND C09.C09_ID=C1H.C1H_UF     	AND C09.D_E_L_E_T_=' ') "
cQuery	+=	"LEFT JOIN " + RetSqlName( 'C1L' ) + " C1L ON(C1L.C1L_FILIAL='" + xFilial('C1L') + "' AND C1L.C1L_ID=C30.C30_CODITE   AND C1L.D_E_L_E_T_=' ') "
cQuery	+=	" WHERE "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery	+= " R54.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND R54.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cQuery	+= " AND R54.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cQuery	+= " AND C02.C02_CODIGO = '00' "             
cQuery	+= " AND C35.D_E_L_E_T_=' ' "                                            
cQuery  += " AND C3S.C3S_CODIGO IN('02','03', '17') "

//Est. Origem/Destino
If Alltrim(MV_PAR05)<>"" 
	cQuery += " AND C09.C09_UF = '" + MV_PAR05 + "' "
EndIf

                                                                        		
If 		MV_PAR07 == 1 //Entrada
	cQuery	+= " AND  ( R54.C20_INDOPE = '0' AND C01.C01_CODIGO IN('01','04','06','55') )"
ElseIf 	MV_PAR07 == 2 //Saida
	cQuery	+= " AND ( R54.C20_INDOPE = '1' AND C01.C01_CODIGO IN('01','04','06','55') )"
Else
	cQuery	+= " AND C01.C01_CODIGO IN('01','04','06','55')
EndIf

cQuery += " AND R54.D_E_L_E_T_ = '') TBL" 

//NATUREZA DAS OPERACOES!
If (MV_PAR15==1)
	If mv_par07 == 1 		//Entrada
		cQuery +=	"  WHERE (SUBSTRING(C0Y_CODIGO,1,1)='2') AND C3S_CODIGO = '04' "
	Elseif mv_par07 == 2 	//Saida
		cQuery +=	"  WHERE (SUBSTRING(C0Y_CODIGO,1,1)='6') AND C3S_CODIGO = '04'  "
	Else
		cQuery +=	"  WHERE (SUBSTRING(C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y_CODIGO,1,1)='6') AND C3S_CODIGO = '04' "
	Endif
ElseIf (MV_PAR15==2)
	If mv_par07 == 1 		//Entrada
		cQuery +=	"  WHERE (SUBSTRING(C0Y_CODIGO,1,1)='2') "
	Elseif mv_par07 == 2 	//Saida
		cQuery +=	"  WHERE (SUBSTRING(C0Y_CODIGO,1,1)='6') "
	Else
		cQuery +=	"  WHERE (SUBSTRING(C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y_CODIGO,1,1)='6') "
	Endif
ElseIf (MV_PAR15==3)
	If mv_par07 == 1 		//Entrada
		cQuery +=	"  WHERE (SUBSTRING(C0Y_CODIGO,1,1)='1' OR SUBSTRING(C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y_CODIGO,1,1)='3') "
	Elseif mv_par07 == 2 	//Saida
		cQuery +=	"  WHERE (SUBSTRING(C0Y_CODIGO,1,1)='5' OR SUBSTRING(C0Y_CODIGO,1,1)='6' OR SUBSTRING(C0Y_CODIGO,1,1)='7') "
	Endif
EndIf 			

cQuery += " ORDER BY c1h_cnpj,c20_serie,c20_numdoc,c30_numite " //CNPJ, Serie, Numero, Numero Item

cQuery	:=	ChangeQuery( cQuery )
dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQ)
                                
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo L Zanaga     º Data ³  26/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query do registro 55                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAliasQ	Alias da query								  	  º±±
±±º			 ³ cFilIn	Filiais a selecionar				  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa query do relatorio                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q55(cAliasQ,cFilIn)
Local cWhere 	 := " " 
Local cFrom 	 := " "
Local cMes1		 := SubStr(DToC(MV_PAR01),4,2)
Local cAno1		 := SubStr(DToC(MV_PAR01),7,4)
Local cMes2		 := SubStr(DToC(MV_PAR02),4,2)
Local cAno2		 := SubStr(DToC(MV_PAR02),7,4)
Local nAnoPos	 := Val(cAno1)+1
Local cAnoPos	 := StrZero(nAnoPos,4)
Local nAnoAnt	 := Val(cAno2)-1
Local cAnoAnt	 := StrZero(nAnoAnt,4)
Local cPerSQL	 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MONTAGEM DO PERIODO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAno2 > cAno1
	// Se o ano final e menor que o inicial, deve quebrar o primeiro periodo 
	If cMes1 < '12'
		cPerSQL :=	" AND ((Substring(C0R.C0R_PERIOD,3,4)='" + cAno1 + "' AND Substring(C0R.C0R_PERIOD,1,2)>='" + cMes1 + "'" +; 
    				" AND Substring(C0R.C0R_PERIOD,3,4)='" + cAno1 + "' AND Substring(C0R.C0R_PERIOD,1,2)<='12')"
    	cPerSQL += "  AND (Substring(C0R.C0R_PERIOD,3,4)>='" + cAnoPos + "' AND Substring(C0R.C0R_PERIOD,3,4)<='" + cAnoAnt + "'" +;
    				" AND Substring(C0R.C0R_PERIOD,3,4)='" + cAnoAnt + "' AND Substring(C0R.C0R_PERIOD,1,2)<='12')"
	Else
		cPerSQL :=	"  AND ((Substring(C0R.C0R_PERIOD,3,4)='" + cAno1 + "' AND Substring(C0R.C0R_PERIOD,1,2)>='" + cMes1 + "'" +; 
    				"  AND Substring(C0R.C0R_PERIOD,3,4)='" + cAno1 + "' AND Substring(C0R.C0R_PERIOD,1,2)='12')"
    	cPerSQL += "  AND (Substring(C0R.C0R_PERIOD,3,4)>='" + cAnoPos + "' AND Substring(C0R.C0R_PERIOD,3,4)<='" + cAnoAnt + "'" +;
    				" AND Substring(C0R.C0R_PERIOD,3,4)='" + cAnoAnt + "' AND Substring(C0R.C0R_PERIOD,1,2)<='12')"
	EndIf	
	cPerSQL +=	" OR (Substring(C0R.C0R_PERIOD,3,4)='" + cAno2 + "' AND Substring(C0R.C0R_PERIOD,1,2)>='01'" +; 
				" AND Substring(C0R.C0R_PERIOD,3,4)='" + cAno2  + "' AND Substring(C0R.C0R_PERIOD,1,2)<='" + cMes2 + "'))"		
ElseIf cAno2 == cAno1
	cPerSQL +=	" AND (Substring(C0R.C0R_PERIOD,3,4)='" + cAno1 + "' AND Substring(C0R.C0R_PERIOD,1,2)>='" + cMes1 + "'" +;
				" AND Substring(C0R.C0R_PERIOD,3,4)='" + cAno1 + "' AND Substring(C0R.C0R_PERIOD,1,2)<='"  + cMes2 + "')"		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MONTAGEM DO FROM ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFrom	:= "%" + RetSqlName('C0R') + " C0R"
If FWModeAccess( 'C1V' , 3 ) == 'C'
	cFrom	+= " LEFT JOIN " + RetSqlName('C1V') + " C1V ON ( C1V.C1V_FILIAL = '" + xFilial("C1V") + "' AND C1V.C1V_ID = C0R.C0R_CODBAN AND C1V.D_E_L_E_T_ = '') "
Else
	cFrom	+= " LEFT JOIN " + RetSqlName('C1V') + " C1V ON ( C1V.C1V_FILIAL IN" + cFilIn + " AND C1V.C1V_ID = C0R.C0R_CODBAN AND C1V.D_E_L_E_T_ = '') "
EndIf
If FWModeAccess( 'C1H' , 3 ) == 'C'
	cFrom	+= " LEFT JOIN " + RetSqlName('C1H') + " C1H ON ( C1H.C1H_FILIAL = '" + xFilial("C1H") + "' AND C1H.C1H_ID = C0R.C0R_CDPART AND C1H.D_E_L_E_T_ = '') "
Else
	cFrom	+= " LEFT JOIN " + RetSqlName('C1H') + " C1H ON ( C1H.C1H_FILIAL IN" + cFilIn + " AND C1H.C1H_ID = C0R.C0R_CDPART AND C1H.D_E_L_E_T_ = '') "
EndIf
If FWModeAccess( 'C09' , 3 ) == 'C'
	cFrom	+= " LEFT JOIN " + RetSqlName('C09') + " C09 ON ( C09.C09_FILIAL = '" + xFilial("C09") + "' AND C09.C09_ID = C1H.C1H_UF AND C09.D_E_L_E_T_ = '')%"
Else
	cFrom	+= " LEFT JOIN " + RetSqlName('C09') + " C09 ON ( C09.C09_FILIAL IN" + cFilIn + " AND C09.C09_ID = C1H.C1H_UF AND C09.D_E_L_E_T_ = '')%"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Filial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C0R.C0R_FILIAL IN" + cFilIn

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pelo periodo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere += cPerSQL

cWhere += " AND C0R.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ                
	SELECT 
		C0R.C0R_DTPGT,C0R.C0R_PERIOD,C0R.C0R_CODAUT,C1V.C1V_CODIGO,C0R.C0R_CODAGE,C0R.C0R_DTVCT,C0R.C0R_CONVEN, 
		C0R.C0R_VLRPRC,C0R.C0R_VLDEV,C0R.C0R_VLRES,C0R.C0R_CDPART,C1H.C1H_CNPJ,C1H.C1H_CPF,C1H.C1H_IE,C09.C09_UF
    FROM 
        %Exp:cFrom%                                                                                                      
	WHERE
		%Exp:cWhere%    
	ORDER BY C0R.C0R_DTPGT//1	//Por data
EndSql                                                     

nRet	:=	1
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registro 56                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q56(cAliasQ) 
Local cWhere 	 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C20.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND C20.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C20.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cWhere += " AND C01.C01_CODIGO IN('01','06','21','22','55') "

cWhere += " AND C3S.C3S_CODIGO IN('05') "
If 		MV_PAR07 == 1 //Entrada
	cWhere += " AND C20.C20_INDOPE = '0' "
ElseIf 	MV_PAR07 == 2 //Saida
	cWhere += " AND C20.C20_INDOPE = '1' "
EndIf
//Est. Origem/Destino
If Alltrim(MV_PAR05)<>"" 
	cWhere += " AND C09.C09_UF = '" + MV_PAR05 + "' "
EndIf

cWhere += " AND C20.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ                
    SELECT
		C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_DTES,C1H.C1H_CNPJ,C1H.C1H_CPF,C01.C01_CODIGO,C03.C03_CODIGO,
		C0Y.C0Y_CODIGO,C3S.C3S_CODIGO,C1L.C1L_CODIGO,C30.C30_NUMITE,C15.C15_CODIGO,C35.C35_ALIQ,C34.C34_CNPJ,C34.C34_CHASSI,C34.C34_INDVEI
    FROM %Table:C20% C20                                                                                                      
		JOIN %Table:C30% C30 ON ( C30.C30_FILIAL = %xFilial:C30% AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel% )  
		JOIN %Table:C34% C34 ON ( C34.C34_FILIAL = %xFilial:C34% AND C34.C34_CHVNF = C30.C30_CHVNF  AND C34.C34_NUMITE=C30.C30_NUMITE AND C34.C34_CODITE=C30.C30_CODITE AND C34.%NotDel% )                                                                             		
		JOIN %Table:C35% C35 ON ( C35.C35_FILIAL = %xFilial:C35% AND C35.C35_CHVNF = C30.C30_CHVNF  AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.c35_codite = C30.c30_codite AND C35.%NotDel% )                      
		LEFT JOIN %Table:C15% C15 ON ( C15.C15_FILIAL = %xFilial:C15% AND C15.C15_ID    = C35.C35_CST    	AND C15.%NotDel% )                                                                             		
		LEFT JOIN %Table:C03% C03 ON ( C03.C03_FILIAL = %xFilial:C03% AND C03.C03_ID    = C30.C30_ORIGEM 	AND C03.%NotDel% )                                                                             		
		LEFT JOIN %Table:C01% C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD 	AND C01.%NotDel% )
		LEFT JOIN %Table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID    = C35.C35_CODTRI 	AND C3S.%NotDel% )
		LEFT JOIN %Table:C0Y% C0Y ON ( C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID    = C30.C30_CFOP   	AND C0Y.%NotDel% )
		LEFT JOIN %Table:C1H% C1H ON ( C1H.C1H_FILIAL = %xFilial:C1H% AND C1H.C1H_ID    = C20.C20_CODPAR 	AND C1H.%NotDel% )
		LEFT JOIN %Table:C09% C09 ON ( C09.C09_FILIAL = %xFilial:C09% AND C09.C09_ID	  = C1H.C1H_UF    	AND C09.%NotDel%) 
		LEFT JOIN %Table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID    = C20.C20_CODSIT 	AND C02.%NotDel% )                                                                             		
		LEFT JOIN %Table:C1L% C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C30.C30_CODITE 	AND C1L.%NotDel% )                                                                             		
	WHERE %Exp:cWhere%    
	ORDER BY C1H.C1H_CNPJ,C20.C20_SERIE,C20.C20_NUMDOC,C30.C30_NUMITE //4,2,1,11 //cnpj, serie, numero, item                                            			
EndSql                     
                                
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 57                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q57(cAliasQ) 
Local cWhere 	 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C20.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND C20.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C20.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cWhere += " AND C01.C01_CODIGO IN('01','06','21','22','55') "

//NATUREZA DAS OPERACOES!
If (MV_PAR15==1)
	If mv_par07 == 1 		//Entrada
		cWhere +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2') AND C30.C30_VLRET>0 "
	Elseif mv_par07 == 2 	//Saida
		cWhere +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') AND C30.C30_VLRET>0 "
	Else
		cWhere +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') AND C30.C30_VLRET>0 "
	Endif
ElseIf (MV_PAR15==2)
	If mv_par07 == 1 		//Entrada
		cWhere +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2') "
	Elseif mv_par07 == 2 	//Saida
		cWhere +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') "
	Else
		cWhere +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') "
	Endif
ElseIf (MV_PAR15==3)
	If mv_par07 == 1 		//Entrada
		cWhere +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='1' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='3') "
	Elseif mv_par07 == 2 	//Saida
		cWhere +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='5' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='7') "
	Endif
EndIf 			

If 		MV_PAR07 == 1 //Entrada
	cWhere += " AND C20.C20_INDOPE = '0' "
ElseIf 	MV_PAR07 == 2 //Saida
	cWhere += " AND C20.C20_INDOPE = '1' "
EndIf
cWhere += " AND C20.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ                
    SELECT DISTINCT
		C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_DTES,C1H.C1H_CNPJ,C1H.C1H_IE,C1H.C1H_CPF,C01.C01_CODIGO,C03.C03_CODIGO,
		C0Y.C0Y_CODIGO,C14.C14_CODIGO,C1L.C1L_CODIGO,C30.C30_NUMITE,C31.C31_LOTE
    FROM 
        %Table:C20% C20                                                                                                      
		JOIN %Table:C30% C30 ON ( C30.C30_FILIAL = %xFilial:C30% AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel% )  
		JOIN %Table:C35% C35 ON ( C35.C35_FILIAL = %xFilial:C35% AND C35.C35_CHVNF = C30.C30_CHVNF  AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.c35_codite = C30.c30_codite AND C35.%NotDel% )                      
		JOIN %Table:C31% C31 ON ( C31.C31_FILIAL = %xFilial:C31% AND C31.C31_CHVNF = C20.C20_CHVNF  
										AND C31.C31_CHVNF = C30.C30_CHVNF  AND C31.C31_NUMITE = C30.C30_NUMITE 
										AND C31.C31_CODITE = C30.C30_CODITE AND C31.%NotDel% )                      
		LEFT JOIN %Table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID    = C35.C35_CODTRI AND C3S.%NotDel% )
		LEFT JOIN %Table:C01% C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD AND C01.%NotDel% )
		LEFT JOIN %Table:C03% C03 ON ( C03.C03_FILIAL = %xFilial:C03% AND C03.C03_ID    = C30.C30_ORIGEM AND C03.%NotDel% )                                                                             		
		LEFT JOIN %Table:C1H% C1H ON ( C1H.C1H_FILIAL = %xFilial:C1H% AND C1H.C1H_ID    = C20.C20_CODPAR AND C1H.%NotDel% )
		LEFT JOIN %Table:C09% C09 ON ( C09.C09_FILIAL = %xFilial:C09% AND C09.C09_ID    = C1H.C1H_UF     AND C09.%NotDel% )                                                                             
		LEFT JOIN %Table:C0Y% C0Y ON ( C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID    = C30.C30_CFOP   AND C0Y.%NotDel% )
		LEFT JOIN %Table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID    = C20.C20_CODSIT AND C02.%NotDel% )                                                                             		
		LEFT JOIN %Table:C14% C14 ON ( C14.C14_FILIAL = %xFilial:C14% AND C14.C14_ID    = C35.C35_CST    AND C14.%NotDel% )
		LEFT JOIN %Table:C1L% C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel% )                                                                             		
	WHERE
		%Exp:cWhere%    
	ORDER BY 
		C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_DTES//1,2,3
EndSql                     
                                
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 60M ECF                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q60M(cAliasQ) 
Local cWhere 	 := " " 

cWhere := "%C6G.C6G_DTMOV >= '" + DTOS(MV_PAR01) + "' AND C6G.C6G_DTMOV <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C6F.C6F_FILIAL = '" + xFilial( "C6F" ) + "' "                   
cWhere += " AND C6F.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ  
	//60M
	SELECT DISTINCT C6F.C6F_ID,C6G.C6G_DTMOV,C0W.C0W_ECFFAB,C0W.C0W_ECFCX,C01.C01_CODIGO,
			C6G.C6G_NRCOPI,	C6G.C6G_NRCOPF,C6G.C6G_PCREDZ,C6G.C6G_PCREOP,
			C6G.C6G_VLBRU,C6G_VLGRTF
	FROM  
		%table:C6F% C6F
		JOIN %table:C6G% C6G ON ( C6G.C6G_FILIAL = %xFilial:C6G% AND C6G.C6G_ID = C6F.C6F_ID	AND C6G.%NotDel% )                      
		JOIN %table:C6I% C6I ON ( C6I.C6I_FILIAL = %xFilial:C6I% AND C6I.C6I_ID = C6G.C6G_ID	AND C6I.C6I_DTMOV = C6G.C6G_DTMOV	AND C6I.%NotDel% )                      
		JOIN %table:C0W% C0W ON ( C0W.C0W_FILIAL = %xFilial:C0W% AND C6F.C6F_CODECF = C0W.C0W_ID AND C0W.%NotDel% )  
		JOIN %table:C01% C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID = C6I.C6I_CMOD AND C01.%NotDel% )  
	WHERE
		%Exp:cWhere%    
	ORDER BY 
		C6F.C6F_ID,C6G.C6G_DTMOV//1,2
EndSql                                                     

nRet	:=	1
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 60A ECF                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q60A(cAliasQ,cId) 
Local cWhere1 	 := " " 
Local cWhere2 	 := " " 
Local cWhere3 	 := " " 
Local cWhere4 	 := " " 
Local cWhere5 	 := " " 

cWhere1 := "%C6J.C6J_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6J.C6J_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere1 += " AND C6J.C6J_FILIAL = '" + xFilial( "C6J" ) + "' "                   
cWhere1 += " AND C6J.C6J_ID = '" + cId + "' "                   
cWhere1 += " AND C02.C02_CODIGO = '02' "                   
cWhere1 += " AND C6J.D_E_L_E_T_ = ''%" 

cWhere2 := "%C6J.C6J_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6J.C6J_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere2 += " AND C6J.C6J_FILIAL = '" + xFilial( "C6J" ) + "' "                   
cWhere2 += " AND C6J.C6J_ID = '" + cId + "' "                   
cWhere2 += " AND C02.C02_CODIGO <> '02' "                   
cWhere2 += " AND C6K.C6K_VLRTRB > 0 "                   
cWhere2 += " AND C3S.C3S_CODIGO = '04' "                   
cWhere2 += " AND C6K.D_E_L_E_T_ = ''%" 

cWhere3 := "%C6J.C6J_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6J.C6J_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere3 += " AND C6J.C6J_FILIAL = '" + xFilial( "C6J" ) + "' "                   
cWhere3 += " AND C6J.C6J_ID = '" + cId + "' "                   
cWhere3 += " AND C02.C02_CODIGO <> '02' "                   
cWhere3 += " AND C6K.C6K_VLISEN > 0 "                   
cWhere3 += " AND C6J.D_E_L_E_T_ = ''%" 

cWhere4 := "%C6J.C6J_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6J.C6J_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere4 += " AND C6J.C6J_FILIAL = '" + xFilial( "C6J" ) + "' "                   
cWhere4 += " AND C6J.C6J_ID = '" + cId + "' "                   
cWhere4 += " AND C02.C02_CODIGO <> '02' "                   
cWhere4 += " AND C6K.C6K_VLNTRI > 0 "                   
cWhere4 += " AND C6J.D_E_L_E_T_ = ''%" 

cWhere5 := "%C6J.C6J_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6J.C6J_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere5 += " AND C6J.C6J_FILIAL = '" + xFilial( "C6J" ) + "' "                   
cWhere5 += " AND C6J.C6J_ID = '" + cId + "' "                   
cWhere5 += " AND C02.C02_CODIGO <> '02' "                   
cWhere5 += " AND C6K.C6K_VLRTRB > 0 "                   
cWhere5 += " AND C3S.C3S_CODIGO <> '04' "                   
cWhere5 += " AND C6J.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ  
	SELECT ECF.dtemis,C0W.C0W_ECFFAB serie,ECF.strib,ECF.aliq,ECF.valor
	FROM                
		//60A - Situacao Cancelada
		(SELECT DISTINCT C6j.c6j_dtemis dtemis,C6j.c6j_id id,'CANC' strib,0 as Aliq,Sum(c6j.c6j_vlrite) valor
		FROM  %table:C6j% C6j
			LEFT JOIN %table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID = C6J.C6J_CODSIT   AND C02.%NotDel% )                      
		WHERE %Exp:cWhere1%    
		GROUP BY C6j.c6j_dtemis,C6j.c6j_id//,'CANC',0	
		UNION 
		//60A - Sub. Trib. 
		SELECT DISTINCT C6j.c6j_dtemis dtemis,C6j.c6j_id id,'F' strib,0 as Aliq,Sum(c6j.c6j_vlrite) valor
		FROM  %table:C6j% C6j
			LEFT JOIN %table:C6K% C6K ON ( C6K.C6K_FILIAL = %xFilial:C6K% AND C6K.C6K_ID = C6J.C6J_ID	      AND C6K.%NotDel% )                      
			LEFT JOIN %table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID = C6K.C6K_CODTRI     AND C3S.%NotDel% )                      
			LEFT JOIN %table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID = C6K.C6K_CODSIT   AND C02.%NotDel% )                      
		WHERE %Exp:cWhere2%    
		GROUP BY C6j.c6j_dtemis,C6j.c6j_id//,'F',0	
		UNION
		//60A - Isentas
		SELECT DISTINCT C6j.c6j_dtemis dtemis,C6j.c6j_id id,'I' strib,0 as Aliq,Sum(c6j.c6j_vlrite) valor
		FROM  %table:C6j% C6j
			LEFT JOIN %table:C6K% C6K ON ( C6K.C6K_FILIAL = %xFilial:C6K% AND C6K.C6K_ID = C6J.C6J_ID	      AND C6K.%NotDel% )                      
			LEFT JOIN %table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID = C6K.C6K_CODSIT   AND C02.%NotDel% )                      
		WHERE %Exp:cWhere3%    
		GROUP BY C6j.c6j_dtemis,C6j.c6j_id//,'I',0
		UNION
		//60A - NTrib
		SELECT DISTINCT C6j.c6j_dtemis dtemis,C6j.c6j_id id,'N' strib,0 as Aliq,Sum(c6j.c6j_vlrite) valor
		FROM  %table:C6j% C6j
			LEFT JOIN %table:C6K% C6K ON ( C6K.C6K_FILIAL = %xFilial:C6K% AND C6K.C6K_ID = C6J.C6J_ID	      AND C6K.%NotDel% )                      
			LEFT JOIN %table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID = C6K.C6K_CODSIT   AND C02.%NotDel% )                      
		WHERE %Exp:cWhere4%    
		GROUP BY C6j.c6j_dtemis,C6j.c6j_id//,'N',0			
		UNION                                                 		
		//60A - Aliquota
		SELECT DISTINCT C6j.c6j_dtemis dtemis,C6j.c6j_id id,'A' strib,c6k.c6k_alqprd As Aliq,Sum(c6j.c6j_vlrite) valor
		FROM  
			%table:C6j% C6j
			LEFT JOIN %table:C6K% C6K ON ( C6K.C6K_FILIAL = %xFilial:C6K% AND C6K.C6K_ID = C6J.C6J_ID	      AND C6K.%NotDel% )                      
			LEFT JOIN %table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID = C6K.C6K_CODSIT   AND C02.%NotDel% )                      
			LEFT JOIN %table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID = C6K.C6K_CODTRI     AND C3S.%NotDel% )                      
		WHERE %Exp:cWhere5%    
		GROUP BY C6j.c6j_dtemis,C6j.c6j_id,c6k.c6k_alqprd) ECF			
			LEFT JOIN %table:C6F% C6F ON ( C6F.C6F_FILIAL = %xFilial:C6F% AND C6F.C6F_ID = ECF.ID	      	  AND C6F.%NotDel% )                      
			LEFT JOIN %table:C0W% C0W ON ( C0W.C0W_FILIAL = %xFilial:C0W% AND C6F.C6F_CODECF = C0W.C0W_ID   AND C0W.%NotDel% )  
	ORDER BY  dtemis//1
	EndSql                                                     
nRet	:=	1
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 60D ECF                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q60D(cAliasQ,cId) 
Local cWhere1 	 := " " 
Local cWhere2 	 := " " 
Local cWhere3 	 := " " 
Local cWhere4 	 := " " 
Local cWhere5 	 := " " 

cWhere1 := "%C6K.C6K_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6K.C6K_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere1 += " AND C6K.C6K_FILIAL = '" + xFilial( "C6K" ) + "' "                   
cWhere1 += " AND C6K.C6K_ID = '" + cId + "' "                   
cWhere1 += " AND C3S.C3S_CODIGO = '04' "
cWhere1 += " AND C6K.D_E_L_E_T_ = ''%" 

cWhere2 := "%C6K.C6K_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6K.C6K_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere2 += " AND C6K.C6K_FILIAL = '" + xFilial( "C6K" ) + "' "                   
cWhere2 += " AND C6K.C6K_ID = '" + cId + "' "                   
cWhere2 += " AND C02.C02_CODIGO = '02' "
cWhere2 += " AND C3S.C3S_CODIGO IN('02','03','04','17') "
cWhere2 += " AND C6K.D_E_L_E_T_ = ''%" 

cWhere3 := "%C6K.C6K_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6K.C6K_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere3 += " AND C6K.C6K_FILIAL = '" + xFilial( "C6K" ) + "' "                   
cWhere3 += " AND C6K.C6K_ID = '" + cId + "' "                   
cWhere3 += " AND C02.C02_CODIGO <> '02' "
cWhere3 += " AND C6K.C6K_VLISEN > 0 "
cWhere3 += " AND C6K.D_E_L_E_T_ = ''%" 

cWhere4 := "%C6K.C6K_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6K.C6K_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere4 += " AND C6K.C6K_FILIAL = '" + xFilial( "C6K" ) + "' "                   
cWhere4 += " AND C6K.C6K_ID = '" + cId + "' "                   
cWhere4 += " AND C02.C02_CODIGO <> '02' "
cWhere4 += " AND C6K.C6K_VLNTRI > 0 "
cWhere4 += " AND C6K.D_E_L_E_T_ = ''%" 

cWhere5 := "%C6K.C6K_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6K.C6K_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere5 += " AND C6K.C6K_FILIAL = '" + xFilial( "C6K" ) + "' "                   
cWhere5 += " AND C6K.C6K_ID = '" + cId + "' "                   
cWhere5 += " AND C3S.C3S_CODIGO IN('02','03','17') "
cWhere5 += " AND C6K.C6K_VLRTRB > 0 "
cWhere5 += " AND C6K.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ  
	//60D  F - Subst Trib
	SELECT DIARIO.dtemis, C0W.C0W_ECFFAB serie, C1L.C1L_CODIGO codigo, DIARIO.qtde, DIARIO.strib, DIARIO.aliq, DIARIO.vlrite, DIARIO.vlrbc, DIARIO.vlrtrb
	FROM
		(SELECT DISTINCT C6K.c6K_dtemis dtemis,C6K.c6K_id id,C6J.C6J_IT,'F' as strib,0 as Aliq, 
	                Sum(C6J.c6j_qtde) QTDE, Sum(C6J.c6j_vlrite) VLRITE, Sum(C6K.c6k_vlrbc)  VLRBC, 
	                Sum(0) as VLRTRB 
		FROM  %table:C6K% C6K
			LEFT JOIN %table:C6J% C6J ON ( C6J.C6J_FILIAL = %xFilial:C6J% AND C6J.C6J_ID = C6K.C6K_ID	AND C6J.%NotDel% )                      
			LEFT JOIN %table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID = C6K.C6K_CODSIT   AND C02.%NotDel% )                      
			LEFT JOIN %table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID = C6K.C6K_CODTRI     AND C3S.%NotDel% )                      
		WHERE %Exp:cWhere1%    
		GROUP BY C6K.c6K_dtemis,C6K.c6K_id,C6J.C6J_IT//,0
		UNION                                                            
		//60D - Cancelado
		SELECT DISTINCT C6K.c6K_dtemis dtemis,C6K.c6K_id id,C6J.C6J_IT,'CANC' as strib,Sum(0) as Aliq, 
	                Sum(C6J.c6j_qtde) QTDE, Sum(C6J.c6j_vlrite) VLRITE, Sum(C6K.c6k_vlrbc)  VLRBC, 
	                Sum(C6K.c6k_vlrtrb) as VLRTRB 
			FROM  %table:C6k% C6k
				LEFT JOIN %table:C6J% C6J ON ( C6J.C6J_FILIAL = %xFilial:C6J% AND C6J.C6J_ID = C6K.C6K_ID	AND C6J.%NotDel% )                      
				LEFT JOIN %table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID = C6J.C6J_CODSIT   AND C02.%NotDel% )                      
				LEFT JOIN %table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID = C6K.C6K_CODTRI     AND C3S.%NotDel% )                      
			WHERE %Exp:cWhere2%    
			GROUP BY C6K.c6K_dtemis,C6K.c6K_id,C6J.C6J_IT//,'CANC'
		UNION
		//60D - Isentas
		SELECT DISTINCT C6K.c6K_dtemis dtemis,C6K.c6K_id id,C6J.C6J_IT,'I' as strib,Sum(0) as Aliq, 
	                Sum(C6J.c6j_qtde) QTDE, Sum(C6J.c6j_vlrite) VLRITE, Sum(C6K.c6k_vlrbc)  VLRBC, 
	                Sum(0) as VLRTRB 
			FROM %table:C6k% C6k
				LEFT JOIN %table:C6J% C6J ON ( C6J.C6J_FILIAL = %xFilial:C6J% AND C6J.C6J_ID = C6K.C6K_ID	AND C6J.%NotDel% )                      
				LEFT JOIN %table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID = C6J.C6J_CODSIT   AND C02.%NotDel% )                      
				LEFT JOIN %table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID = C6K.C6K_CODTRI     AND C3S.%NotDel% )                      
			WHERE %Exp:cWhere3%    
			GROUP BY C6K.c6K_dtemis,C6K.c6K_id,C6J.C6J_IT//,'I'
		UNION
		//60D - Nao trib
		SELECT DISTINCT C6K.c6K_dtemis dtemis,C6K.c6K_id id,C6J.C6J_IT,'N' as strib,Sum(0) as Aliq, 
	                Sum(C6J.c6j_qtde) QTDE, Sum(C6J.c6j_vlrite) VLRITE, Sum(C6K.c6k_vlrbc)  VLRBC, 
	                Sum(0) as VLRTRB 
			FROM  %table:C6k% C6k
				LEFT JOIN %table:C6J% C6J ON ( C6J.C6J_FILIAL = %xFilial:C6J% AND C6J.C6J_ID = C6K.C6K_ID	AND C6J.%NotDel% )                      
				LEFT JOIN %table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID = C6J.C6J_CODSIT   AND C02.%NotDel% )                      
				LEFT JOIN %table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID = C6K.C6K_CODTRI     AND C3S.%NotDel% )                      
			WHERE %Exp:cWhere4%    
			GROUP BY C6K.c6K_dtemis,C6K.c6K_id,C6J.C6J_IT//,'N'
		UNION
		//60D - Aliquota, tributados
		SELECT DISTINCT C6K.c6K_dtemis dtemis,C6K.c6K_id id,C6J.C6J_IT,'A' as strib,C6K.c6k_alqprd As Aliq, 
	                Sum(C6J.c6j_qtde) QTDE, Sum(C6J.c6j_vlrite) VLRITE, Sum(C6K.c6k_vlrbc)  VLRBC, 
	                Sum(C6K.c6k_vlrtrb) as VLRTRB 
			FROM  %table:C6k% C6k
				LEFT JOIN %table:C6J% C6J ON ( C6J.C6J_FILIAL = %xFilial:C6J% AND C6J.C6J_ID = C6K.C6K_ID	AND C6J.%NotDel% )                      
				LEFT JOIN %table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID = C6J.C6J_CODSIT   AND C02.%NotDel% )                      
				LEFT JOIN %table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID = C6K.C6K_CODTRI     AND C3S.%NotDel% )                      
			WHERE %Exp:cWhere5%    
			GROUP BY C6K.c6K_dtemis,C6K.c6K_id,C6J.C6J_IT,C6K.c6k_alqprd) DIARIO //-> Dentro do group by --> 'A',
		LEFT JOIN %table:C6F% C6F ON ( C6F.C6F_FILIAL = %xFilial:C6F% AND C6F.C6F_ID = DIARIO.ID	      	AND C6F.%NotDel% )                      
		LEFT JOIN %table:C0W% C0W ON ( C0W.C0W_FILIAL = %xFilial:C0W% AND C6F.C6F_CODECF = C0W.C0W_ID   	AND C0W.%NotDel% )  
		LEFT JOIN %Table:C1L% C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = DIARIO.C6J_IT 	AND C1L.%NotDel% )                                                                             		
	ORDER BY dtemis//1
EndSql                                                     

nRet	:=	1
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 60I ECF                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q60I(cAliasQ,cId) 
Local cWhere 	 := " " 

cWhere := "%C6I.C6I_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6I.C6I_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C6F.C6F_FILIAL = '" + xFilial( "C6F" ) + "' "                   
cWhere += " AND C6F.C6F_ID = '" + cId + "' "                   
cWhere += " AND C3S.C3S_CODIGO IN('02','03','04','17') "
cWhere += " AND C6F.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ  
	//60I
	SELECT C6I.C6I_DTEMIS,C0W.C0W_ECFFAB,C01.C01_CODIGO,C6J.C6J_NUMDOC,C1L.C1L_CODIGO,C6K.C6K_ALQPRD,C3S.C3S_CODIGO,
		SUM(C6J.C6J_QTDE) C6J_QTDE,SUM(C6J.C6J_VLRITE) C6J_VLRITE,SUM(C6K.C6K_VLRBC) C6K_VLRBC,SUM(C6K.C6K_VLRTRB) C6K_VLRTRB,
		SUM(C6K.C6K_VLISEN) C6K_VLISEN, SUM(C6K.C6K_VLNTRI) C6K_VLNTRI
	FROM  
		%table:C6F% C6F
		LEFT JOIN %table:C6G% C6G ON ( C6G.C6G_FILIAL = %xFilial:C6G% AND C6G.C6G_ID = C6F.C6F_ID	AND C6G.%NotDel% )                      
		LEFT JOIN %table:C6H% C6H ON ( C6H.C6H_FILIAL = %xFilial:C6H% AND C6H.C6H_ID = C6G.C6G_ID	AND C6H.C6H_DTMOV = C6G.C6G_DTMOV AND C6H.%NotDel% )                      		
		LEFT JOIN %table:C6I% C6I ON ( C6I.C6I_FILIAL = %xFilial:C6I% AND C6I.C6I_ID = C6G.C6G_ID	AND C6I.C6I_DTMOV = C6G.C6G_DTMOV AND C6I.%NotDel% )                      		
		LEFT JOIN %table:C0W% C0W ON ( C0W.C0W_FILIAL = %xFilial:C0W% AND C6F.C6F_CODECF = C0W.C0W_ID AND C0W.%NotDel% )  
		LEFT JOIN %table:C6J% C6J ON ( C6J.C6J_FILIAL = %xFilial:C6J% AND 
			C6I.C6I_ID = C6J.C6J_ID AND 
			C6I.C6I_DTMOV = C6J.C6J_DTMOV AND 
			C6I.C6I_CMOD = C6J.C6J_CMOD AND
			C6I.C6I_CODSIT = C6J.C6J_CODSIT AND 
			C6I.C6I_NUMDOC = C6J.C6J_NUMDOC AND 
			C6I.C6I_DTEMIS = C6J.C6J_DTEMIS)
		LEFT JOIN %table:C6K% C6K ON ( C6K.C6K_FILIAL = %xFilial:C6K% AND C6K.C6K_ID = C6J.C6J_ID	AND 
		  	C6K.C6K_DTMOV = C6J.C6J_DTMOV AND C6K.C6K_CMOD = C6J.C6J_CMOD AND C6K.C6K_CODSIT = C6J.C6J_CODSIT AND C6K.C6K_NUMDOC=C6J.C6J_NUMDOC AND
		  	C6K.C6K_DTEMIS = C6J.C6J_DTEMIS AND C6K.C6K_IT = C6J.C6J_IT AND C6K.%NotDel% )                      
		LEFT JOIN %Table:C1L% C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C6J.C6J_IT   AND C1L.%NotDel% )                                                                             		
		LEFT JOIN %Table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID    = C6K.C6K_CODTRI AND C3S.%NotDel% )
		LEFT JOIN %Table:C01% C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C6J.C6J_CMOD AND C01.%NotDel% )
	WHERE
		%Exp:cWhere%    
	GROUP BY
		C6I.C6I_DTEMIS,C0W.C0W_ECFFAB,C01.C01_CODIGO,C6J.C6J_NUMDOC,C1L.C1L_CODIGO,C6K.C6K_ALQPRD,C3S.C3S_CODIGO
	ORDER BY 
		C6I_DTEMIS//1
EndSql                                                     

nRet	:=	1
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 60R ECF                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q60R(cAliasQ) 
Local cWhere 	 := " " 

cWhere := "%C6I.C6I_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6I.C6I_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C6F.C6F_FILIAL = '" + xFilial( "C6F" ) + "' "                   
cWhere += " AND C3S.C3S_CODIGO IN('02','03','04','17') "
cWhere += " AND C02.C02_CODIGO <> '02' "
cWhere += " AND C6F.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ  
	//60I
	SELECT DISTINCT 
		SUBSTRING(C6I.C6I_DTEMIS,5,2) MES,SUBSTRING(C6I.C6I_DTEMIS,1,4) ANO, 
		C1L.C1L_CODIGO,C6K.C6K_ALQPRD,C3S.C3S_CODIGO,
		SUM(C6J.C6J_QTDE) C6J_QTDE,SUM(C6J.C6J_VLRITE) C6J_VLRITE,SUM(C6K.C6K_VLRBC) C6K_VLRBC,SUM(C6K.C6K_VLRTRB) C6K_VLRTRB,
		SUM(C6K.C6K_VLISEN) C6K_VLISEN, SUM(C6K.C6K_VLNTRI) C6K_VLNTRI
	FROM  
		%table:C6F% C6F
		LEFT JOIN %table:C6G% C6G ON ( C6G.C6G_FILIAL = %xFilial:C6G% AND C6G.C6G_ID = C6F.C6F_ID	AND C6G.%NotDel% )                      
		LEFT JOIN %table:C6H% C6H ON ( C6H.C6H_FILIAL = %xFilial:C6H% AND C6H.C6H_ID = C6G.C6G_ID	AND C6H.C6H_DTMOV = C6G.C6G_DTMOV AND C6H.%NotDel% )                      		
		LEFT JOIN %table:C6I% C6I ON ( C6I.C6I_FILIAL = %xFilial:C6I% AND C6I.C6I_ID = C6G.C6G_ID	AND C6I.C6I_DTMOV = C6G.C6G_DTMOV AND C6I.%NotDel% )                      		
		LEFT JOIN %table:C0W% C0W ON ( C0W.C0W_FILIAL = %xFilial:C0W% AND C6F.C6F_CODECF = C0W.C0W_ID AND C0W.%NotDel% )  
		LEFT JOIN %table:C6J% C6J ON ( C6J.C6J_FILIAL = %xFilial:C6J% AND 
			C6I.C6I_ID = C6J.C6J_ID AND 
			C6I.C6I_DTMOV = C6J.C6J_DTMOV AND 
			C6I.C6I_CMOD = C6J.C6J_CMOD AND
			C6I.C6I_CODSIT = C6J.C6J_CODSIT AND 
			C6I.C6I_NUMDOC = C6J.C6J_NUMDOC AND 
			C6I.C6I_DTEMIS = C6J.C6J_DTEMIS)
		LEFT JOIN %table:C6K% C6K ON ( C6K.C6K_FILIAL = %xFilial:C6K% AND C6K.C6K_ID = C6J.C6J_ID	AND 
		  	C6K.C6K_DTMOV = C6J.C6J_DTMOV AND C6K.C6K_CMOD = C6J.C6J_CMOD AND C6K.C6K_CODSIT = C6J.C6J_CODSIT AND C6K.C6K_NUMDOC=C6J.C6J_NUMDOC AND
		  	C6K.C6K_DTEMIS = C6J.C6J_DTEMIS AND C6K.C6K_IT = C6J.C6J_IT AND C6K.%NotDel% )                      
		LEFT JOIN %Table:C1L% C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C6J.C6J_IT   	AND C1L.%NotDel% )                                                                             		
		LEFT JOIN %Table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID    = C6K.C6K_CODTRI 	AND C3S.%NotDel% )
		LEFT JOIN %Table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID    = C6K.C6K_CODSIT   AND C1L.%NotDel% )                                                                             		
	WHERE
		%Exp:cWhere%    
	GROUP BY 
		SUBSTRING(C6I.C6I_DTEMIS,5,2),SUBSTRING(C6I.C6I_DTEMIS,1,4),C0W.C0W_ECFFAB,C1L.C1L_CODIGO,C6K.C6K_ALQPRD,C3S.C3S_CODIGO	
	ORDER BY 
		MES//1
EndSql                                                     

nRet	:=	1
Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registro 61					                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q61(cAliasQ) 
Local cWhere 	 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C20.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND C20.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C20.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cWhere += " AND C01.C01_CODIGO IN('13','14','15','16','02','04') "
cWhere += " AND C3S.C3S_CODIGO IN('02','03','17') "
cWhere += " AND C20.C20_INDOPE = '1' "				// Somente Saidas
cWhere += " AND C20.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ                
    SELECT C20_DTES,C01_CODIGO,C20_SERIE,C20_SUBSER,C2F_ALIQ,
		   C20_NUMDOC,C20_NDOCF,C20_VLDOC,C20_VLRDA,C2F_BASE,C2F_VALOR,C2F_VLNT,C2F_VLOUTR
	FROM
	    (SELECT
			C20.C20_DTES,C01.C01_CODIGO,C20.C20_SERIE,C20.C20_SUBSER,C3S.C3S_CODIGO,C2F.C2F_ALIQ,
			MIN(C20.C20_NUMDOC) C20_NUMDOC,MAX(C20.C20_NUMDOC) C20_NDOCF,SUM(C20.C20_VLDOC) C20_VLDOC,
			SUM((C20.C20_VLRDA+C20.C20_VLRSEG+C20.C20_VLRFRT+C20.C20_VLOUDE)) C20_VLRDA,SUM(C2F.C2F_BASE) C2F_BASE,
			SUM(C2F.C2F_VALOR) C2F_VALOR,SUM((C2F.C2F_VLNT+C2F.C2F_VLISEN)) C2F_VLNT,SUM(C2F.C2F_VLOUTR) C2F_VLOUTR
	    FROM 
	        %Table:C20% C20                                                                                                      
			LEFT JOIN %Table:C2F% C2F ON ( C2F.C2F_FILIAL = %xFilial:C2F% AND C2F.C2F_CHVNF = C20.C20_CHVNF  AND C2F.%NotDel% )                                                                             		
			LEFT JOIN %Table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID    = C2F.C2F_CODTRI AND C3S.%NotDel% )
			LEFT JOIN %Table:C01% C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD AND C01.%NotDel% )
		WHERE
			%Exp:cWhere%    
		GROUP BY
			C20.C20_DTES,C01.C01_CODIGO,C20.C20_SERIE,C20.C20_SUBSER,C3S.C3S_CODIGO,C2F.C2F_ALIQ	
		) TBL ORDER BY C20_DTES//1
		
EndSql                     
                                
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registro 61R					                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q61R(cAliasQ) 
Local cWhere 	 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C20.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND C20.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C20.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cWhere += " AND C01.C01_CODIGO IN('13','14','15','16','02','04') "
cWhere += " AND C3S.C3S_CODIGO IN('02','03','17') "
cWhere += " AND C20.C20_INDOPE = '1' "				// Somente Saidas
cWhere += " AND C20.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ                
    SELECT
		SUBSTRING(C20.C20_DTES,5,2) MES,SUBSTRING(C20.C20_DTES,1,4) ANO,C1L.C1L_CODIGO,C35.C35_ALIQ,
		SUM(C30.C30_QUANT) C30_QUANT,SUM(C30.C30_TOTAL) C30_TOTAL,SUM(C35.C35_VALOR) C35_VALOR,SUM(C35.C35_BASE) C35_BASE
    FROM 
        %Table:C20% C20                                                                                                      
		LEFT JOIN %Table:C30% C30 ON ( C30.C30_FILIAL = %xFilial:C30% AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel% )                                                                             		
		LEFT JOIN %Table:C35% C35 
			ON ( C35.C35_FILIAL = %xFilial:C35% AND C35.C35_CHVNF = C30.C30_CHVNF  AND C35.C35_NUMITE = C30.C30_NUMITE 
					AND C35.C35_CODITE = C30.C30_CODITE AND C35.%NotDel% )                      
		LEFT JOIN %Table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID    = C35.C35_CODTRI AND C3S.%NotDel% )
		LEFT JOIN %Table:C01% C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD AND C01.%NotDel% )
		LEFT JOIN %Table:C1L% C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel% )                                                                             		
	WHERE
		%Exp:cWhere%    
	GROUP BY
		SUBSTRING(C20.C20_DTES,5,2),SUBSTRING(C20.C20_DTES,1,4),C1L.C1L_CODIGO,C35.C35_ALIQ
	ORDER BY 
		MES//1
EndSql                     
                                
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registro 70                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q70(cAliasQ) 
Local cWhere 	 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C20.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND C20.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C20.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cWhere += " AND C01.C01_CODIGO IN('07','08','09','10','11','26','27','57') "
cWhere += " AND C3S.C3S_CODIGO IN('02','03','17') "
If 		MV_PAR07 == 1 //Entrada
	cWhere += " AND C20.C20_INDOPE = '0' "
ElseIf 	MV_PAR07 == 2 //Saida
	cWhere += " AND C20.C20_INDOPE = '1' "
EndIf
cWhere += " AND C20.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ                
    SELECT
		C20.C20_DTES,C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_SUBSER,C1H.C1H_CNPJ,C1H.C1H_CPF,C1H.C1H_IE,C09.C09_UF,C01.C01_CODIGO,
		C0Y.C0Y_CODIGO,C02.C02_CODIGO,C3S.C3S_CODIGO,C0X.C0X_CODIGO,
		SUM(C20.C20_VLDOC) C20_VLDOC,SUM(C2F.C2F_BASE) C2F_BASE,
		SUM(C2F.C2F_VALOR) C2F_VALOR,SUM((C2F.C2F_VLNT+C2F.C2F_VLISEN)) C2F_VLNT,SUM(C2F.C2F_VLOUTR) C2F_VLOUTR
    FROM 
        %Table:C20% C20                                                                                                      
		LEFT JOIN %Table:C2F% C2F ON ( C2F.C2F_FILIAL = %xFilial:C2F% AND C2F.C2F_CHVNF = C20.C20_CHVNF  AND C2F.%NotDel% )                                                                             		
		LEFT JOIN %Table:C35% C35 ON ( C35.C35_FILIAL = %xFilial:C35% AND C35.C35_CHVNF = C20.C20_CHVNF  AND C35.C35_CODTRI = C2F.C2F_CODTRI AND C35.%NotDel% )                      
		LEFT JOIN %Table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID    = C35.C35_CODTRI AND C3S.%NotDel% )
		LEFT JOIN %Table:C01% C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD AND C01.%NotDel% )
		LEFT JOIN %Table:C1H% C1H ON ( C1H.C1H_FILIAL = %xFilial:C1H% AND C1H.C1H_ID    = C20.C20_CODPAR AND C1H.%NotDel% )
		LEFT JOIN %Table:C09% C09 ON ( C09.C09_FILIAL = %xFilial:C09% AND C09.C09_ID    = C1H.C1H_UF     AND C09.%NotDel% )                                                                             
		LEFT JOIN %Table:C0Y% C0Y ON ( C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID    = C2F.C2F_CFOP   AND C0Y.%NotDel% )
		LEFT JOIN %Table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID    = C20.C20_CODSIT AND C02.%NotDel% )                                                                             		
		LEFT JOIN %Table:C0X% C0X ON ( C0X.C0X_FILIAL = %xFilial:C0X% AND C0X.C0X_ID    = C20.C20_INDFRT AND C0X.%NotDel% )                                                                             		
	WHERE
		%Exp:cWhere%    
	GROUP BY
		C20.C20_DTES,C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_SUBSER,C1H.C1H_CNPJ,C1H.C1H_CPF,C1H.C1H_IE,C09.C09_UF,C01.C01_CODIGO,
		C0Y.C0Y_CODIGO,C02.C02_CODIGO,C3S.C3S_CODIGO,C0X.C0X_CODIGO
	ORDER BY 
		C20.C20_DTES,C20.C20_NUMDOC//1,2
EndSql                     
nRet	:=	1
Return nRet                                              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registro 71                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q71(cAliasQ) 
Local cWhere 	 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C20.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND C20.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C20.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cWhere += " AND C01.C01_CODIGO IN('08','09','10','11','26','27','57') "
cWhere += " AND C3S.C3S_CODIGO IN('02','03','17') "
If 		MV_PAR07 == 1 //Entrada
	cWhere += " AND C20.C20_INDOPE = '0' "
ElseIf 	MV_PAR07 == 2 //Saida
	cWhere += " AND C20.C20_INDOPE = '1' "
EndIf

cWhere += " AND C20.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ                
    SELECT
    	C20.C20_DTES,C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_SUBSER,C1H.C1H_CNPJ,C1H.C1H_CPF,
    	C1H.C1H_IE,C09.C09_UF,C01.C01_CODIGO,C0Y.C0Y_CODIGO,C1H2.C1H_CNPJ CH2_CNPJ, 
    	C1H2.C1H_CPF CH2_CPF,	C1H2.C1H_IE CH2_IE, C09.C09_UF C092_UF, C3I.C3I_DTDOC, C3I.C3I_SERIE, 
		C3I.C3I_NUMDOC,C3I.C3I_VLDOC, C012.C01_CODIGO C012_CODIGO	
    FROM 
        %Table:C3A% C3A                                                                                                      
		LEFT JOIN %Table:C20% C20  ON ( C20.C20_FILIAL = %xFilial:C20% AND C3A.C3A_CHVNF = C20.C20_CHVNF  AND C20.%NotDel% )                                                                             		
		LEFT JOIN %Table:C2F% C2F  ON ( C2F.C2F_FILIAL = %xFilial:C2F% AND C2F.C2F_CHVNF = C3A.C3A_CHVNF  AND C2F.%NotDel% )                                                                             		
		LEFT JOIN %Table:C35% C35  ON ( C35.C35_FILIAL = %xFilial:C35% AND C35.C35_CHVNF = C3A.C3A_CHVNF  AND C35.C35_CODTRI = C2F.C2F_CODTRI AND C35.%NotDel% )                      
		LEFT JOIN %Table:C3S% C3S  ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID    = C35.C35_CODTRI AND C3S.%NotDel% )
		LEFT JOIN %Table:C01% C01  ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD AND C01.%NotDel% )
		LEFT JOIN %Table:C1H% C1H  ON ( C1H.C1H_FILIAL = %xFilial:C1H% AND C1H.C1H_ID    = C20.C20_CODPAR AND C1H.%NotDel% )
		LEFT JOIN %Table:C09% C09  ON ( C09.C09_FILIAL = %xFilial:C09% AND C09.C09_ID    = C1H.C1H_UF     AND C09.%NotDel% )                                                                             
		LEFT JOIN %Table:C0Y% C0Y  ON ( C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID    = C2F.C2F_CFOP   AND C0Y.%NotDel% )
		LEFT JOIN %Table:C02% C02  ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID    = C20.C20_CODSIT AND C02.%NotDel% )                                                                             		
		LEFT JOIN %Table:C3I% C3I  ON ( C3I.C3I_FILIAL = %xFilial:C3I% AND C3I.C3I_CHVNF = C3A.C3A_CHVNF  AND C3I.%NotDel% )                                                                             		
		LEFT JOIN %Table:C1H% C1H2 ON ( C1H2.C1H_FILIAL = %xFilial:C1H% AND C3A.C3A_CPARRE = C1H2.C1H_ID  AND C1H2.%NotDel% )
		LEFT JOIN %Table:C09% C092 ON ( C092.C09_FILIAL = %xFilial:C09% AND C092.C09_ID    = C1H2.C1H_UF     AND C092.%NotDel% )                                                                             		
		LEFT JOIN %Table:C01% C012 ON ( C012.C01_FILIAL = %xFilial:C01% AND C012.C01_ID = C3I.C3I_CODMOD AND C012.%NotDel% )                                                                             		
	WHERE
		%Exp:cWhere%    
	GROUP BY
		C20.C20_DTES,C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_SUBSER,C1H.C1H_CNPJ,C1H.C1H_CPF,C1H.C1H_IE,C09.C09_UF,C01.C01_CODIGO,
		C0Y.C0Y_CODIGO,C1H2.C1H_CNPJ,C1H2.C1H_CPF,C1H2.C1H_IE, C09.C09_UF,
		C3I.C3I_DTDOC, C3I.C3I_SERIE, C3I.C3I_NUMDOC, C3I_VLDOC, C012.C01_CODIGO 
	ORDER BY 
		C20.C20_DTES//1
EndSql                     
                                
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  08/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registro 74                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q74(cAliasQ) 
Local cWhere:= "" 
Local cFrom	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MONTAGEM DO FROM ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFrom	:= "%" + RetSQLTab('C5A') 
cFrom	+= " JOIN " + RetSqlName('C5B') + " C5B ON ( C5B.C5B_FILIAL = '" + xFilial('C5B') + "' AND C5B.C5B_ID = C5A.C5A_ID AND C5B.D_E_L_E_T_ = '') "
cFrom	+= " LEFT JOIN " + RetSqlName('C1H') + " C1H ON ( C1H.C1H_FILIAL = '" + xFilial('C1H') + "' AND C1H.C1H_ID = C5B.C5B_CODPAR AND C1H.D_E_L_E_T_ = '') "
cFrom	+= " LEFT JOIN " + RetSqlName('C09') + " C09 ON ( C09.C09_FILIAL = '" + xFilial('C09') + "' AND C1H.C1H_UF = C09.C09_ID AND C09.D_E_L_E_T_ = '') "
cFrom	+= " LEFT JOIN " + RetSqlName('C1l') + " C1L ON ( C1L.C1L_FILIAL = '" + xFilial('C1L') + "' AND C1L.C1L_ID = C5B.C5B_CODITE AND C1L.D_E_L_E_T_ = '') %"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Estoque ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C5A.C5A_FILIAL = '" + xFilial('C5A') + "' AND C5B.C5B_FILIAL = '" + xFilial('C5B') + "' "
cWhere += " AND C5A.C5A_DTINV = '" + DTOS(MV_PAR09) + "' "
cWhere += " AND C5A.D_E_L_E_T_ = ''%" 
                                                 
BeginSql Alias cAliasQ               
    SELECT 
		C1l.C1l_CODIGO,C5B.C5B_QTD,C5B.C5B_VITEM,C5B.C5B_INDPRO,C1H.C1H_CNPJ,C1H.C1H_IE,C09.C09_UF,C1H.C1H_CPF,C5A.C5A_DTINV
    FROM 
        %Exp:cFrom%                                                                                                      
	WHERE
		%Exp:cWhere%    
ORDER BY 
	C1l.C1l_CODIGO,C5B.C5B_QTD//1, 2
EndSql                                                     

nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registro 75                                		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q75(cAliasQ) 
Local cWhere1 	 := " " 
Local cWhere2 	 := " " 
Local cWhere3 	 := " " 
Local cWhere4 	 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere1 := "%C20.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND C20.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cWhere1 += " AND C30.C30_FILIAL = '" + xFilial( "C30" ) + "' "                   
//NATUREZA DAS OPERACOES!
If (MV_PAR15==1)
	If mv_par07 == 1 		//Entrada
		cWhere1 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2') AND C30.C30_VLRET>0 "
	Elseif mv_par07 == 2 	//Saida
		cWhere1 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') AND C30.C30_VLRET>0 "
	Else
		cWhere1 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') AND C30.C30_VLRET>0 "
	Endif
ElseIf (MV_PAR15==2)
	If mv_par07 == 1 		//Entrada
		cWhere1 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2') "
	Elseif mv_par07 == 2 	//Saida
		cWhere1 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') "
	Else
		cWhere1 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') "
	Endif
ElseIf (MV_PAR15==3)
	If mv_par07 == 1 		//Entrada
		cWhere1 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='1' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='3') "
	Elseif mv_par07 == 2 	//Saida
		cWhere1 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='5' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='7') "
	Endif
EndIf 			
If 		MV_PAR07 == 1 //Entrada
	cWhere1 += " AND C20.C20_INDOPE = '0' "
ElseIf 	MV_PAR07 == 2 //Saida
	cWhere1 += " AND C20.C20_INDOPE = '1' "
EndIf
cWhere1 += " AND C01.C01_CODIGO IN('01','04','06','55') "
cWhere1 += " AND C0U.C0U_CODIGO IN('00','01','05') "
cWhere1 += " AND C30.D_E_L_E_T_ = ''%" 

cWhere2 := "%C6K.C6K_DTEMIS >= '" + DTOS(MV_PAR01) + "' AND C6K.C6K_DTEMIS <='" + DTOS(MV_PAR02) + "' "
cWhere2 += " AND C6K.C6K_FILIAL = '" + xFilial( "C6K" ) + "' "                   
cWhere2 += " AND C3S.C3S_CODIGO IN('02','03','17','04','05') "
cWhere2 += " AND C6K.D_E_L_E_T_ = ''%" 

cWhere3 := "%C4H.C4H_DTDOC >= '" + DTOS(MV_PAR01) + "' AND C4H.C4H_DTDOC <='" + DTOS(MV_PAR02) + "' "
cWhere3 += " AND C4H.C4H_FILIAL = '" + xFilial( "C4H" ) + "' "                   
cWhere3 += " AND C4F.C4F_NATEXP = '1' " 
cWhere3 += " AND C4H.D_E_L_E_T_ = ''%" 

//Where para NFs Mod 21 e 22
cWhere4 := "%C20.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND C20.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cWhere4 += " AND C30.C30_FILIAL = '" + xFilial( "C30" ) + "' "                   
//NATUREZA DAS OPERACOES!
If (MV_PAR15==1)
	If mv_par07 == 1 		//Entrada
		cWhere4 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2') AND C30.C30_VLRET>0 "
	Elseif mv_par07 == 2 	//Saida
		cWhere4 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') AND C30.C30_VLRET>0 "
	Else
		cWhere4 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') AND C30.C30_VLRET>0 "
	Endif
ElseIf (MV_PAR15==2)
	If mv_par07 == 1 		//Entrada
		cWhere4 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2') "
	Elseif mv_par07 == 2 	//Saida
		cWhere4 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') "
	Else
		cWhere4 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6') "
	Endif
ElseIf (MV_PAR15==3)
	If mv_par07 == 1 		//Entrada
		cWhere4 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='1' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='2' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='3') "
	Elseif mv_par07 == 2 	//Saida
		cWhere4 +=	" AND (SUBSTRING(C0Y.C0Y_CODIGO,1,1)='5' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='6' OR SUBSTRING(C0Y.C0Y_CODIGO,1,1)='7') "
	Endif
EndIf 			
If 		MV_PAR07 == 1 //Entrada
	cWhere4 += " AND C20.C20_INDOPE = '0' "
ElseIf 	MV_PAR07 == 2 //Saida
	cWhere4 += " AND C20.C20_INDOPE = '1' "
EndIf
cWhere4 += " AND C01.C01_CODIGO IN('21','22') "
cWhere4 += " AND C0U.C0U_CODIGO IN('00','01','05') "
cWhere4 += " AND C30.D_E_L_E_T_ = ''%" 

If MV_PAR10 == 1
	BeginSql Alias cAliasQ                
		SELECT C1L_CODIGO,C0A_CODIGO,C1L_DESCRI,C1J_CODIGO,C1L_REDBC,
			MAX(C1L_ALQIPI) AS C1L_ALQIPI,MAX(C1L_ALQICM) AS C1L_ALQICM,SUM(VLRBC) VLRBC
		FROM (
			//Com C30... Notas Fiscais                                                                    
		    SELECT DISTINCT
				C1L.C1L_CODIGO,C0A.C0A_CODIGO,C1L.C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC,
				MAX(C1L.C1L_ALQIPI) AS C1L_ALQIPI,MAX(C1L.C1L_ALQICM) AS C1L_ALQICM,SUM(C30.C30_BCRETQ) VLRBC
		    FROM %Table:C30% C30                                                                                                      
				JOIN		%Table:C20% 	C20 ON ( C20.C20_FILIAL = %xFilial:C20% AND C20.C20_CHVNF = C30.C30_CHVNF  AND C20.%NotDel% )                                                                             		
				JOIN		%Table:C0U% 	C0U ON ( C0U.C0U_FILIAL = %xFilial:C0U% AND C0U.C0U_ID    = C20.C20_TPDOC  AND C0U.%NotDel% )
				LEFT JOIN	%Table:C01% 	C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD AND C01.%NotDel% )
				LEFT JOIN 	%Table:C1L% 	C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel% )                                                                             		
				LEFT JOIN	%Table:C1J% 	C1J ON ( C1J.C1J_FILIAL = %xFilial:C1J% AND C1J.C1J_ID    = C30.C30_UM 	AND C1J.%NotDel% )                                                                             		
				LEFT JOIN	%Table:C0A% 	C0A ON ( C0A.C0A_FILIAL = %xFilial:C0A% AND C0A.C0A_ID    = C1L.C1L_CODNCM AND C0A.%NotDel% )                                                                             		
				LEFT JOIN 	%Table:C0Y% 	C0Y ON ( C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID    = C30.C30_CFOP   AND C0Y.%NotDel% )
			WHERE %Exp:cWhere1%    
			GROUP BY C1L.C1L_CODIGO,C0A.C0A_CODIGO,C1L.C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC
			//Com C30... Notas Fiscais - Com 21/22
	 		UNION
		    SELECT DISTINCT
				C0B.C0B_CODIGO AS C1L_CODIGO,C0A.C0A_CODIGO,C0B.C0B_DESCRI AS C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC,
				MAX(C1L.C1L_ALQIPI) AS C1L_ALQIPI,MAX(C1L.C1L_ALQICM) AS C1L_ALQICM,SUM(C30.C30_BCRETQ) VLRBC
		    FROM %Table:C30% C30                                                                                                      
				JOIN		%Table:C20% 	C20 ON ( C20.C20_FILIAL = %xFilial:C20% AND C20.C20_CHVNF = C30.C30_CHVNF  AND C20.%NotDel% )                                                                             		
				JOIN		%Table:C0U% 	C0U ON ( C0U.C0U_FILIAL = %xFilial:C0U% AND C0U.C0U_ID    = C20.C20_TPDOC  AND C0U.%NotDel% )
				LEFT JOIN	%Table:C0B% 	C0B ON ( C0B.C0B_FILIAL = %xFilial:C0B% AND C0B.C0B_ID    = C30.C30_CODSER AND C0B.%NotDel% )			
				LEFT JOIN	%Table:C01% 	C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD AND C01.%NotDel% )
				LEFT JOIN 	%Table:C1L% 	C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel% )                                                                             		
				LEFT JOIN	%Table:C1J% 	C1J ON ( C1J.C1J_FILIAL = %xFilial:C1J% AND C1J.C1J_ID    = C30.C30_UM 	AND C1J.%NotDel% )                                                                             		
				LEFT JOIN	%Table:C0A% 	C0A ON ( C0A.C0A_FILIAL = %xFilial:C0A% AND C0A.C0A_ID    = C1L.C1L_CODNCM AND C0A.%NotDel% )                                                                             		
				LEFT JOIN 	%Table:C0Y% 	C0Y ON ( C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID    = C30.C30_CFOP   AND C0Y.%NotDel% )
			WHERE %Exp:cWhere4%    
			GROUP BY C0B.C0B_CODIGO,C0A.C0A_CODIGO,C0B.C0B_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC
		//Com C6K... ECF's
			UNION
		    SELECT DISTINCT
				C1L.C1L_CODIGO,C0A.C0A_CODIGO,C1L.C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC,
				MAX(C1L.C1L_ALQIPI) AS C1L_ALQIPI,MAX(C1L.C1L_ALQICM) AS C1L_ALQICM,SUM(C6K.C6K_VLRBC) VLRBC
		    FROM %Table:C6K% C6K                                                                                                      
				JOIN %Table:C6J% C6J ON ( C6K.C6K_FILIAL = %xFilial:C6K% AND C6K.C6K_ID    = C6J.C6J_ID		 	AND C6J.%NotDel% )		
				LEFT JOIN %Table:C0Y% C0Y ON ( C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID    = C6J.C6J_CFOP   AND C0Y.%NotDel% )
				LEFT JOIN %Table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID    = C6K.C6K_CODTRI 	AND C3S.%NotDel% )		
				LEFT JOIN %Table:C1L% C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C6K.C6K_IT 		AND C1L.%NotDel% )                                                                             		
				LEFT JOIN %Table:C1J% C1J ON ( C1J.C1J_FILIAL = %xFilial:C1J% AND C1J.C1J_ID    = C6J.C6J_UNDITE 	AND C1J.%NotDel% )                                                                             		
				LEFT JOIN %Table:C0A% C0A ON ( C0A.C0A_FILIAL = %xFilial:C0A% AND C0A.C0A_ID    = C1L.C1L_CODNCM 	AND C0A.%NotDel% )                                                                             		
			WHERE %Exp:cWhere2%    
			GROUP BY C1L.C1L_CODIGO,C0A.C0A_CODIGO,C1L.C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC
		//Com C4F // Exportacao
			UNION
		    SELECT DISTINCT
				C1L.C1L_CODIGO,C0A.C0A_CODIGO,C1L.C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC,
				MAX(C1L.C1L_ALQIPI) AS C1L_ALQIPI,MAX(C1L.C1L_ALQICM) AS C1L_ALQICM,SUM(C4H.C4H_VLRTOT) VLRBC
		    FROM %Table:C4H% C4H
				LEFT JOIN %Table:C4F% C4F ON ( C4F.C4F_FILIAL = %xFilial:C4F% AND C4F.C4F_ID    = C4H.C4H_ID 	    AND C4F.%NotDel% )                                                                             		
				LEFT JOIN %Table:C1L% C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C4H.C4H_CODITE 	AND C1L.%NotDel% )                                                                             		
				LEFT JOIN %Table:C1J% C1J ON ( C1J.C1J_FILIAL = %xFilial:C1J% AND C1J.C1J_ID    = C4H.C4H_UNID 	AND C1J.%NotDel% )                                                                             		
				LEFT JOIN %Table:C0A% C0A ON ( C0A.C0A_FILIAL = %xFilial:C0A% AND C0A.C0A_ID    = C1L.C1L_CODNCM 	AND C0A.%NotDel% )                                                                             		
			WHERE %Exp:cWhere3%    
			GROUP BY C1L.C1L_CODIGO,C0A.C0A_CODIGO,C1L.C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC
		)
		QRY_ITENS
		Group By C1L_CODIGO,C0A_CODIGO,C1L_DESCRI,C1J_CODIGO,C1L_REDBC
	EndSql                    
Else
	BeginSql Alias cAliasQ                
		SELECT C1L_CODIGO,C0A_CODIGO,C1L_DESCRI,C1J_CODIGO,C1L_REDBC,
			MAX(C1L_ALQIPI) AS C1L_ALQIPI,MAX(C1L_ALQICM) AS C1L_ALQICM,SUM(VLRBC) VLRBC
		FROM (
			//Com C30... Notas Fiscais Sem Mod 21/22
		    SELECT DISTINCT
				C1L.C1L_CODIGO,C0A.C0A_CODIGO,C1L.C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC,
				MAX(C1L.C1L_ALQIPI) AS C1L_ALQIPI,MAX(C1L.C1L_ALQICM) AS C1L_ALQICM,SUM(C30.C30_BCRETQ) VLRBC
		    FROM %Table:C30% C30                                                                                                      
				JOIN		%Table:C20% 	C20 ON ( C20.C20_FILIAL = %xFilial:C20% AND C20.C20_CHVNF = C30.C30_CHVNF  AND C20.%NotDel% )                                                                             		
				JOIN		%Table:C0U% 	C0U ON ( C0U.C0U_FILIAL = %xFilial:C0U% AND C0U.C0U_ID    = C20.C20_TPDOC  AND C0U.%NotDel% )
				LEFT JOIN	%Table:C01% 	C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD AND C01.%NotDel% )
				LEFT JOIN 	%Table:C1L% 	C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel% )                                                                             		
				LEFT JOIN	%Table:C1J% 	C1J ON ( C1J.C1J_FILIAL = %xFilial:C1J% AND C1J.C1J_ID    = C30.C30_UM 	AND C1J.%NotDel% )                                                                             		
				LEFT JOIN	%Table:C0A% 	C0A ON ( C0A.C0A_FILIAL = %xFilial:C0A% AND C0A.C0A_ID    = C1L.C1L_CODNCM AND C0A.%NotDel% )                                                                             		
				LEFT JOIN 	%Table:C0Y% 	C0Y ON ( C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID    = C30.C30_CFOP   AND C0Y.%NotDel% )
			WHERE %Exp:cWhere1%    
			GROUP BY C1L.C1L_CODIGO,C0A.C0A_CODIGO,C1L.C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC
			//Com C30... Notas Fiscais - Com 21/22
	 		UNION
		    SELECT DISTINCT
				C0B.C0B_CODIGO AS C1L_CODIGO,C0A.C0A_CODIGO,C0B.C0B_DESCRI AS C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC,
				MAX(C1L.C1L_ALQIPI) AS C1L_ALQIPI,MAX(C1L.C1L_ALQICM) AS C1L_ALQICM,SUM(C30.C30_BCRETQ) VLRBC
		    FROM %Table:C30% C30                                                                                                      
				JOIN		%Table:C20% 	C20 ON ( C20.C20_FILIAL = %xFilial:C20% AND C20.C20_CHVNF = C30.C30_CHVNF  AND C20.%NotDel% )                                                                             		
				JOIN		%Table:C0U% 	C0U ON ( C0U.C0U_FILIAL = %xFilial:C0U% AND C0U.C0U_ID    = C20.C20_TPDOC  AND C0U.%NotDel% )
				LEFT JOIN	%Table:C0B% 	C0B ON ( C0B.C0B_FILIAL = %xFilial:C0B% AND C0B.C0B_ID    = C30.C30_CODSER AND C0B.%NotDel% )			
				LEFT JOIN	%Table:C01% 	C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD AND C01.%NotDel% )
				LEFT JOIN 	%Table:C1L% 	C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel% )                                                                             		
				LEFT JOIN	%Table:C1J% 	C1J ON ( C1J.C1J_FILIAL = %xFilial:C1J% AND C1J.C1J_ID    = C30.C30_UM 	AND C1J.%NotDel% )                                                                             		
				LEFT JOIN	%Table:C0A% 	C0A ON ( C0A.C0A_FILIAL = %xFilial:C0A% AND C0A.C0A_ID    = C1L.C1L_CODNCM AND C0A.%NotDel% )                                                                             		
				LEFT JOIN 	%Table:C0Y% 	C0Y ON ( C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID    = C30.C30_CFOP   AND C0Y.%NotDel% )
			WHERE %Exp:cWhere4%    
			GROUP BY C0B.C0B_CODIGO,C0A.C0A_CODIGO,C0B.C0B_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC
		//Com C4F // Exportacao
			UNION
		    SELECT DISTINCT
				C1L.C1L_CODIGO,C0A.C0A_CODIGO,C1L.C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC,
				MAX(C1L.C1L_ALQIPI) AS C1L_ALQIPI,MAX(C1L.C1L_ALQICM) AS C1L_ALQICM,SUM(C4H.C4H_VLRTOT) VLRBC
		    FROM %Table:C4H% C4H
				LEFT JOIN %Table:C4F% C4F ON ( C4F.C4F_FILIAL = %xFilial:C4F% AND C4F.C4F_ID    = C4H.C4H_ID 	    AND C4F.%NotDel% )                                                                             		
				LEFT JOIN %Table:C1L% C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C4H.C4H_CODITE 	AND C1L.%NotDel% )                                                                             		
				LEFT JOIN %Table:C1J% C1J ON ( C1J.C1J_FILIAL = %xFilial:C1J% AND C1J.C1J_ID    = C4H.C4H_UNID 	AND C1J.%NotDel% )                                                                             		
				LEFT JOIN %Table:C0A% C0A ON ( C0A.C0A_FILIAL = %xFilial:C0A% AND C0A.C0A_ID    = C1L.C1L_CODNCM 	AND C0A.%NotDel% )                                                                             		
			WHERE %Exp:cWhere3%    
			GROUP BY C1L.C1L_CODIGO,C0A.C0A_CODIGO,C1L.C1L_DESCRI,C1J.C1J_CODIGO,C1L.C1L_REDBC
		)
		QRY_ITENS
		Group By C1L_CODIGO,C0A_CODIGO,C1L_DESCRI,C1J_CODIGO,C1L_REDBC
	EndSql                     
EndIf
	                                
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 76                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q76(cAliasQ) 
Local cWhere 	 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C20.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND C20.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C20.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cWhere += " AND C01.C01_CODIGO IN('21','22') "

//Somente Saida
cWhere += " AND C20.C20_INDOPE = '1' "

cWhere += " AND C3S.C3S_CODIGO IN('02','03','17') "
cWhere += " AND C20.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ                
    SELECT
		C20.C20_CHVNF,C20.C20_DTES,C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_SUBSER,C1H.C1H_CNPJ,C1H.C1H_CPF,C1H.C1H_IE,C09.C09_UF,C01.C01_CODIGO,
		C0Y.C0Y_CODIGO,C10.C10_CODIGO,C02.C02_CODIGO,C3S.C3S_CODIGO,C2F.C2F_ALIQ,
		SUM(C20.C20_VLDOC) C20_VLDOC,SUM((C20.C20_VLRDA+C20.C20_VLRSEG+C20.C20_VLRFRT+C20.C20_VLOUDE)) C20_VLRDA,SUM(C2F.C2F_BASE) C2F_BASE,
		SUM(C2F.C2F_VALOR) C2F_VALOR,SUM((C2F.C2F_VLNT+C2F.C2F_VLISEN)) C2F_VLNT,SUM(C2F.C2F_VLOUTR) C2F_VLOUTR
    FROM 
        %Table:C20% C20                                                                                                      
		LEFT JOIN %Table:C2F% C2F ON ( C2F.C2F_FILIAL = %xFilial:C2F% AND C2F.C2F_CHVNF = C20.C20_CHVNF  AND C2F.%NotDel% )                                                                             		
		LEFT JOIN %Table:C2G% C2G ON ( C2G.C2G_FILIAL = %xFilial:C2G% AND C2G.C2G_CHVNF = C20.C20_CHVNF  AND C2G.%NotDel% )                      
		LEFT JOIN %Table:C35% C35 ON ( C35.C35_FILIAL = %xFilial:C35% AND C35.C35_CHVNF = C20.C20_CHVNF  AND C35.C35_CODTRI = C2F.C2F_CODTRI AND C35.%NotDel% )                      
		LEFT JOIN %Table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID    = C35.C35_CODTRI AND C3S.%NotDel% )
		LEFT JOIN %Table:C01% C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD AND C01.%NotDel% )
		LEFT JOIN %Table:C1H% C1H ON ( C1H.C1H_FILIAL = %xFilial:C1H% AND C1H.C1H_ID    = C20.C20_CODPAR AND C1H.%NotDel% )
		LEFT JOIN %Table:C09% C09 ON ( C09.C09_FILIAL = %xFilial:C09% AND C09.C09_ID    = C1H.C1H_UF     AND C09.%NotDel% )                                                                             
		LEFT JOIN %Table:C0Y% C0Y ON ( C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID    = C2F.C2F_CFOP   AND C0Y.%NotDel% )
		LEFT JOIN %Table:C02% C02 ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID    = C20.C20_CODSIT AND C02.%NotDel% )                                                                             		
		LEFT JOIN %Table:C10% C10 ON ( C01.C01_FILIAL = %xFilial:C10% AND C10.C10_ID    = C2G.C2G_INDREC AND C2G.%NotDel% )
	WHERE
		%Exp:cWhere%    
	GROUP BY
		C20.C20_CHVNF,C20.C20_DTES,C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_SUBSER,C1H.C1H_CNPJ,C1H.C1H_CPF,C1H.C1H_IE,C09.C09_UF,C01.C01_CODIGO,
		C0Y.C0Y_CODIGO,C10.C10_CODIGO,C02.C02_CODIGO,C3S.C3S_CODIGO,C2F.C2F_ALIQ
	ORDER BY C20.C20_NUMDOC//3
EndSql                     
                                
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 77                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q77(cAliasQ) 
Local cWhere 	 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C20.C20_DTES >= '" + DTOS(MV_PAR01) + "' AND C20.C20_DTES <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C20.C20_FILIAL = '" + xFilial( "C20" ) + "' "                   
cWhere += " AND C01.C01_CODIGO IN('21','22') "

//77 Somente saida
cWhere += " AND C20.C20_INDOPE = '1' "

cWhere += " AND C3S.C3S_CODIGO IN('02','03','17') "
cWhere += " AND C20.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ                
    SELECT
		C20.C20_CHVNF,C20.C20_DTES,C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_SUBSER,C1H.C1H_CNPJ,C1H.C1H_CPF,C1H.C1H_IE,C09.C09_UF,C01.C01_CODIGO,
		C0Y.C0Y_CODIGO,C10.C10_CODIGO,C30.C30_NUMITE,C0B.C0B_CODIGO,C02.C02_CODIGO,C3S.C3S_CODIGO,C35.C35_ALIQ,C2G.C2G_TERMIN,C1H2.C1H_CNPJ MF,
		SUM(C30.C30_QUANT) C30_QUANT , SUM(C30.C30_TOTAL) C30_TOTAL,SUM(C35.C35_BASE) C35_BASE,SUM(C2G.C2G_VLSERV) C35_BASE,
		SUM(C35.C35_VALOR) C35_VALOR,SUM(C30.C30_VLDESC) C30_VLDESC,SUM((C35.C35_VLNT+C35.C35_VLISEN)) C35_VLNT,SUM(C35.C35_VLOUTR) C35_VLOUTR
    FROM 
        %Table:C20% C20                                                                                                      
		LEFT JOIN %Table:C30% C30 ON ( C30.C30_FILIAL = %xFilial:C30% AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel% )  
		LEFT JOIN %Table:C38% C38 ON ( C38.C38_FILIAL = %xFilial:C38% AND C38.C38_CHVNF = C30.C30_CHVNF  AND C38.C38_CODITE = C30.C30_CODITE AND C38.C38_NUMITE = C30.C30_NUMITE AND C38.%NotDel% )  
		LEFT JOIN %Table:C2G% C2G ON ( C2G.C2G_FILIAL = %xFilial:C2G% AND C2G.C2G_CHVNF = C20.C20_CHVNF  AND C2G.%NotDel% )                      
		LEFT JOIN %Table:C35% C35 ON ( C35.C35_FILIAL = %xFilial:C35% AND C35.C35_CHVNF = C30.C30_CHVNF  AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.c35_codite = C30.c30_codite AND C35.%NotDel% )                      
		LEFT JOIN %Table:C3S% C3S ON ( C3S.C3S_FILIAL = %xFilial:C3S% AND C3S.C3S_ID    = C35.C35_CODTRI AND C3S.%NotDel% )
		LEFT JOIN %Table:C01% C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C20.C20_CODMOD AND C01.%NotDel% )
		LEFT JOIN %Table:C1H% C1H ON ( C1H.C1H_FILIAL = %xFilial:C1H% AND C1H.C1H_ID    = C20.C20_CODPAR AND C1H.%NotDel% )
		LEFT JOIN %Table:C1H% C1H2 ON ( C1H2.C1H_FILIAL = %xFilial:C1H% AND C1H2.C1H_ID    = C38.C38_CODPAR AND C1H2.%NotDel% )
		LEFT JOIN %Table:C09% C09  ON ( C09.C09_FILIAL = %xFilial:C09% AND C09.C09_ID    = C1H.C1H_UF     AND C09.%NotDel% )                                                                             
		LEFT JOIN %Table:C0Y% C0Y  ON ( C0Y.C0Y_FILIAL = %xFilial:C0Y% AND C0Y.C0Y_ID    = C30.C30_CFOP   AND C0Y.%NotDel% )
		LEFT JOIN %Table:C02% C02  ON ( C02.C02_FILIAL = %xFilial:C02% AND C02.C02_ID    = C20.C20_CODSIT AND C02.%NotDel% )                                                                             		
		LEFT JOIN %Table:C0B% C0B  ON ( C0B.C0B_FILIAL = %xFilial:C0B% AND C0B.C0B_ID    = C30.C30_CODSER AND C0B.%NotDel% )  
		LEFT JOIN %Table:C10% C10  ON ( C01.C01_FILIAL = %xFilial:C10% AND C10.C10_ID    = C2G.C2G_INDREC AND C2G.%NotDel% )
	WHERE
		%Exp:cWhere%    
	GROUP BY
		C20.C20_CHVNF,C20.C20_DTES,C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_SUBSER,C1H.C1H_CNPJ,C1H.C1H_CPF,C1H.C1H_IE,C09.C09_UF,C01.C01_CODIGO,
		C0Y.C0Y_CODIGO,C10.C10_CODIGO,C30.C30_NUMITE,C0B.C0B_CODIGO,C02.C02_CODIGO,C3S.C3S_CODIGO,C35.C35_ALIQ,C2G.C2G_TERMIN, C1H2.C1H_CNPJ
	ORDER BY C20.C20_NUMDOC//3
EndSql                     
                                
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 85                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q85(cAliasQ) 
Local cWhere 	 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data de Entrada/Saida da NF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C4F.C4F_DTDE >= '" + DTOS(MV_PAR01) + "' AND C4F.C4F_DTDE <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C4F.C4F_FILIAL = '" + xFilial( "C4F" ) + "' "                   

cWhere += " AND C4F.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ                
    SELECT DISTINCT
		C4F.C4F_NRODE,C4F.C4F_DTDE,C4F.C4F_NATEXP,C4F.C4F_NRORE,C4F.C4F_CHCEMB,C4F.C4F_DTCHC,C0S.C0S_CODIGO,C08.C08_CODIGO,C4F.C4F_DTRE,
    	C4F.C4F_DTAVB,C4G.C4G_NUMDOC,C4G.C4G_DTDOC,C01.C01_CODIGO,C4G.C4G_SERIE
    FROM 
        %Table:C4F% C4F                                                                                                      
		LEFT JOIN %Table:C4G% C4G ON ( C4G.C4G_FILIAL = %xFilial:C4G% AND C4G.C4G_ID    = C4F.C4F_ID AND C4G.%NotDel% )
		LEFT JOIN %Table:C0S% C0S ON ( C0S.C0S_FILIAL = %xFilial:C0S% AND C0S.C0S_ID    = C4F.C4F_TPCHC AND C0S.%NotDel% )
		LEFT JOIN %Table:C08% C08 ON ( C08.C08_FILIAL = %xFilial:C08% AND C08.C08_ID    = C4F.C4F_PAIS AND C08.%NotDel% )
		LEFT JOIN %Table:C01% C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C4G.C4G_CODMOD AND C01.%NotDel% )
	WHERE
		%Exp:cWhere%    
	ORDER BY 
		C4F.C4F_NRODE,C4F.C4F_DTDE//1,2
EndSql                     
                                
nRet	:=	1
Return nRet                                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Query Registros 86                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Q86(cAliasQ) 
Local cWhere 	 := " " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro pela Data ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere := "%C4F.C4F_DTDE >= '" + DTOS(MV_PAR01) + "' AND C4F.C4F_DTDE <='" + DTOS(MV_PAR02) + "' "
cWhere += " AND C4F.C4F_FILIAL = '" + xFilial( "C4F" ) + "' "                   
cWhere += " AND C4F.C4F_NATEXP = '1' " 

cWhere += " AND C4F.D_E_L_E_T_ = ''%" 

BeginSql Alias cAliasQ                
    SELECT 
		C4F.C4F_NRORE,C4F.C4F_DTRE,C1H.C1H_CNPJ,C1H.C1H_IE,C09.C09_UF,C4G.C4G_NUMDOC,C4G.C4G_DTDOC,C01.C01_CODIGO,C4G.C4G_SERIE,
		C1L.C1L_CODIGO,C4G.C4G_CODREL,C4H.C4H_QTD,C4H.C4H_VLRUNI,C4H.C4H_VLRTOT
    FROM 
        %Table:C4F% C4F                                                                                                      
		LEFT JOIN %Table:C4G% C4G ON ( C4G.C4G_FILIAL = %xFilial:C4G% AND C4G.C4G_ID    = C4F.C4F_ID AND C4G.%NotDel% )
		LEFT JOIN %Table:C4H% C4H ON ( C4H.C4H_FILIAL = %xFilial:C4H% AND C4H.C4H_ID    = C4G.C4G_ID AND C4H.%NotDel% )
		LEFT JOIN %Table:C0S% C0S ON ( C0S.C0S_FILIAL = %xFilial:C0S% AND C0S.C0S_ID    = C4F.C4F_TPCHC AND C0S.%NotDel% )
		LEFT JOIN %Table:C08% C08 ON ( C08.C08_FILIAL = %xFilial:C08% AND C08.C08_ID    = C4F.C4F_PAIS AND C08.%NotDel% )
		LEFT JOIN %Table:C01% C01 ON ( C01.C01_FILIAL = %xFilial:C01% AND C01.C01_ID    = C4G.C4G_CODMOD AND C01.%NotDel% )
		LEFT JOIN %Table:C1H% C1H ON ( C1H.C1H_FILIAL = %xFilial:C1H% AND C1H.C1H_ID    = C4H.C4H_CODPAR AND C1H.%NotDel% )
		LEFT JOIN %Table:C09% C09 ON ( C09.C09_FILIAL = %xFilial:C09% AND C09.C09_ID    = C1H.C1H_UF AND C09.%NotDel% )
		LEFT JOIN %Table:C1L% C1L ON ( C1L.C1L_FILIAL = %xFilial:C1L% AND C1L.C1L_ID    = C4G.C4G_CODITE AND C1L.%NotDel% )
	WHERE
		%Exp:cWhere%    
	ORDER BY 
		C4F.C4F_NRORE,C4F.C4F_DTRE//1,2
EndSql                     
                                
nRet	:=	1
Return nRet                                              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 50                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L50(aNF,cReg,nReg50) 
Local	cLinha 	:= ""  
Local	cCNPJCPF:= Alltrim(aNf[2])
Local	cSit	:= ""
Local	cTpEmi	:=	Iif(aNf[10]=='0','P','T')

cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
If 		aNf[17] == '02'
	cSit	:= "S"
ElseIf	aNf[17] == '00'
	cSit	:= "N"
ElseIf	aNf[17] $ '01/03'
	cSit	:= "E"
EndIf

//Saida e 21/22 nao vai no Reg50
If aNF[19] == '1' .And. aNF[06] $ '21/22'
	cLinha	:=	""
Else
	nReg50++                             
	cLinha	:=	'50'+;
				cCNPJCPF+;
				aNf[3]+;
				aNf[4]+;
				aNf[5]+;               
				aNf[6]+;               
				Padr(Alltrim(aNf[7]),3)+;
				StrZero(Val(Right(Alltrim(aNf[8]),6)),6)+;
				aNf[09]+;
				cTpEmi+;
				StrTran(StrZero(aNf[11],14,2),'.','')+;
				StrTran(StrZero(aNf[12],14,2),'.','')+; 
				StrTran(StrZero(aNf[13],14,2),'.','')+; 
				StrTran(StrZero(aNf[14],14,2),'.','')+; 
				StrTran(StrZero(aNf[15],14,2),'.','')+; 
				StrTran(StrZero(aNf[16],5,2),'.','')+; 
				cSit
EndIf
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 51                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*/
Static Function R119L51(cAliasQ,cReg,nReg51) 
Local cLinha 	:= ""  
Local cCNPJCPF  := Iif(Alltrim((cAliasQ)->c1h_cnpj)<>"",(cAliasQ)->c1h_cnpj,(cAliasQ)->c1h_cpf)
Local cSit		:= ""

cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
If 		(cAliasQ)->C02_CODIGO == '02'
	cSit	:= "X"
ElseIf	(cAliasQ)->C02_CODIGO == '00'
	cSit	:= "N"
ElseIf	(cAliasQ)->C02_CODIGO $ '01/03'
	cSit	:= "E"
EndIf

//So IPI > 0            
nReg51++
cLinha	:=	cReg+;
			cCNPJCPF+;
			Padr(Alltrim((cAliasQ)->C1H_IE),14)+;			
			(cAliasQ)->C20_DTES+;
			(cAliasQ)->C09_UF+; 
			Padr(Alltrim((cAliasQ)->C20_SERIE),3)+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C20_NUMDOC),6)),6)+;
			(cAliasQ)->CFOP+;
			StrTran(StrZero((cAliasQ)->C20_VLDOC,14,2),'.','')+;
			StrTran(StrZero((cAliasQ)->VLIPI,14,2),'.','')+; 
			StrTran(StrZero((cAliasQ)->ISENTA,14,2),'.','')+; 
			StrTran(StrZero((cAliasQ)->OUTRAS,14,2),'.','')+; 
			Space(20)+;
			cSit
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 53                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L53(cAliasQ,cReg,nReg53) 
Local cLinha := ""  
Local cCNPJCPF  := Iif(Alltrim((cAliasQ)->c1h_cnpj)<>"",(cAliasQ)->c1h_cnpj,(cAliasQ)->c1h_cpf)
Local cTpEmi	:=Iif((cAliasQ)->C20_INDEMI=='0','P','T')
Local cSit		:= ""

cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
If 		(cAliasQ)->C02_CODIGO == '02'
	cSit	:= "X"
ElseIf	(cAliasQ)->C02_CODIGO == '00'
	cSit	:= "N"
ElseIf	(cAliasQ)->C02_CODIGO $ '01/03'
	cSit	:= "E"
EndIf

If (cAliasQ)->ICMSRET > 0
	nReg53++
	cLinha	:=	cReg+;
				cCNPJCPF+;
				Padr(Alltrim((cAliasQ)->C1H_IE),14)+;			
				(cAliasQ)->C20_DTES+;
				(cAliasQ)->C09_UF+;
				(cAliasQ)->C01_CODIGO+;
				Padr(Alltrim((cAliasQ)->C20_SERIE),3)+;
				StrZero(Val(Right(Alltrim((cAliasQ)->C20_NUMDOC),6)),6)+;
				(cAliasQ)->CFOP+;
				cTpEmi+;			
				StrTran(StrZero((cAliasQ)->BCST,14,2),'.','')+;
				StrTran(StrZero((cAliasQ)->ICMSRET,14,2),'.','')+; 
				StrTran(StrZero((cAliasQ)->VLRDA,14,2),'.','')+; 
				cSit+;
				' '+; //(cAliasQ)->C35_CODANT
				Space(29)
EndIf
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 54                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L54(aNFIT,nPos,nReg54,aIT900,aIT,nID) 
Local cLinha 	:= ""    
Local cCod		:= ""                                      
Local cNota		:= ""
Local cItem		:= ""    
Local cCst      := ""            

Local cCNPJCPF  := 	""
Local cQuant	:=	""
Local cTotal	:=	""
Local cDesc		:=	""
Local cBCICMS	:=	""
Local cBCST		:=	""
Local cVLIPI	:=	""
Local cAliq		:=	""

Default aIT900	:= {}
Default aIT		:= {}
Default nID		:= 0
Default aNFIT	:= {}
         

If Len(aNFIT) > 0
	cCNPJCPF:= 	Alltrim(aNFIT[02])
	cQuant	:=	StrTran(StrZero(aNFIT[10],12,3),'.','')
	cTotal	:=	StrTran(StrZero(aNFIT[11],13,2),'.','')
	cDesc	:=	StrTran(StrZero(aNFIT[12],13,2),'.','')
	cBCICMS	:=	StrTran(StrZero(aNFIT[13],13,2),'.','')
	cBCST	:=	StrTran(StrZero(aNFIT[14],13,2),'.','')
	cVLIPI	:=	StrTran(StrZero(aNFIT[15],13,2),'.','')
	cAliq	:=	StrTran(StrZero(aNFIT[16],5,2),'.','')
	cCod	:=  PadR(AllTrim(aNFIT[09]),14)
	cNota	:=	Right(Alltrim(aNFIT[05]),6)
EndIf

cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])

If ( Len(aIT900) == 0 ); 
	 .Or.  ( Len(aIT900) == 0 .And. Alltrim(aNFIT[18])<>""); // Veiculos 
	 .Or.  ( Len(aIT900) == 0 .And. Alltrim(aNFIT[19])<>"")  // Medicamentos
	nReg54++                 
	cLinha	:=	'54'+;
				cCNPJCPF+;
				aNFIT[03]+;
				Padr(Alltrim(aNFIT[04]),3)+;
				StrZero(Val(cNota),6)+;
				aNFIT[06]+;
				PADR(AllTrim(aNFIT[07]),3,"0")+;
				aNFIT[08]+;
				cCod+;
				cQuant+;
				cTotal+;
				cDesc+;
				cBCICMS+;
	            cBCST+;
	            cVLIPI+;
				cALIQ
ElseIf (Len(aIT900) > 0)           
	cCNPJCPF	:=	Alltrim(aIT[1][1])	
	cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
	cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
	cItem		:=	IIf(nID==1,"991",IIf(nID==2,"992",IIf(nID==3,"993",IIf(nID==4,"997",IIf(nID==5,"998","999")))))
	cNota		:=	Right(Alltrim(aIT[1][4]),6)    
	If aIT[1][7]=='  '
		aIT[1][7] := '00'
	EndIf
	If (cItem > "990")
	    cCst :=	Space(3)
	Else
   	    cCst :=	aIT[1][6]+aIT[1][7]
    EndIf
	nReg54++                 
	cLinha	:=	'54'+;
				cCNPJCPF+;
				aIT[1][2]+;
				aIT[1][3]+;
				StrZero(Val(cNota),6)+;
				aIT[1][5]+; 
				cCst+;		    
				cItem+;
				Space(14)+;
				'00000000000'+;
				StrTran(StrZero(aIT[1][8],13,2),'.','')+;
				StrTran(StrZero(aIT900[1][nID],13,2),'.','')+;
				'000000000000'+;
	            '000000000000'+;
	            '000000000000'+;
				'0000'
EndIf
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 55                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L55(cAliasQ,nReg55) 
Local cLinha := ""  
Local cCNPJCPF  := Iif(Alltrim((cAliasQ)->c1h_cnpj)<>"",(cAliasQ)->c1h_cnpj,(cAliasQ)->c1h_cpf) 
Local cCGC	:=	SM0->M0_CGC
//Local cInsc	:=	ARETDIG(SM0->M0_INSC,.T.,SM0->M0_ESTENT)
Local cEst	:= 	SM0->M0_ESTENT
Local cAut	:= ""            

cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCGC		:=  PadR(AllTrim(cCGC),TamSx3("C1H_CNPJ")[1])
cCGC		:= 	StrZero(Val(cCGC),TamSx3("C1H_CNPJ")[1])
cAut		:=  Padl(Right(Alltrim((cAliasQ)->c0r_codaut),20),20)
cConv		:= 	PadR(Right(Alltrim((cAliasQ)->c0r_conven),30),30)

nReg55++
cLinha	:=	'55' + ;
			cCGC+;
			Padr(Alltrim((cAliasQ)->C1H_IE),14)+;			
			(cAliasQ)->c0R_dtpgt+;
       		cEst+;
       		(cAliasQ)->c09_uf+; 
       		(cAliasQ)->c1v_codigo+; 
       		(cAliasQ)->c0r_codage+; 
       		cAut+; 
       		StrTran(StrZero((cAliasQ)->c0r_vlrprc,14,2),'.','')+; 
			(cAliasQ)->c0r_dtvct+;
			Substr((cAliasQ)->c0r_period,1,2)+Substr((cAliasQ)->c0r_period,3,4)+;
       		cConv
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 56                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L56(cAliasQ,nReg56) 
Local cLinha := ""  
Local cCNPJCPF  := Iif(Alltrim((cAliasQ)->c1h_cnpj)<>"",(cAliasQ)->c1h_cnpj,(cAliasQ)->c1h_cpf)    
Local cCNPJCon	:= (cAliasQ)->c34_cnpj
Local cCod		:= ""

cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCon	:=  PadR(AllTrim(cCNPJCon),TamSx3("C34_CNPJ")[1])
cCNPJCon	:= 	StrZero(Val(cCNPJCon),TamSx3("C34_CNPJ")[1])
cCod		:=  PadR(Right(AllTrim((cAliasQ)->c1l_codigo),14),14)

If AllTrim(Alltrim((cAliasQ)->c34_chassi))<>""
    nReg56++
	cLinha	:=	'56' + ;
	       		cCNPJCPF+; 
	       		(cAliasQ)->c01_codigo+; 
				Padr(Alltrim((cAliasQ)->C20_SERIE),3)+;
				StrZero(Val(Right(Alltrim((cAliasQ)->C20_NUMDOC),6)),6)+;
	       		(cAliasQ)->c0y_codigo+; 
	       		(cAliasQ)->c03_codigo+(cAliasQ)->c15_codigo+; 
	       		(cAliasQ)->c30_numite+; 
	       		cCod+; 
	       		(cAliasQ)->c34_indvei+;
	       		cCNPJCon+;
	       		StrTran(StrZero((cAliasQ)->c35_aliq,5,2),'.','')+; 
	       		Padl(Alltrim((cAliasQ)->c34_chassi),17)+;
	       		Space(39) 
EndIf
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 57                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L57(cAliasQ,nReg57) 
Local cLinha := ""  
Local cCNPJCPF  := Iif(Alltrim((cAliasQ)->c1h_cnpj)<>"",(cAliasQ)->c1h_cnpj,(cAliasQ)->c1h_cpf)    
Local cCod		:= ""

cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCod		:=  PadR(Right(AllTrim((cAliasQ)->c1l_codigo),14),14)

nReg57++
cLinha	:=	'57' + ;
       		cCNPJCPF+; 
			Padr(Alltrim((cAliasQ)->C1H_IE),14)+;			
       		(cAliasQ)->c01_codigo+; 
			Padr(Alltrim((cAliasQ)->C20_SERIE),3)+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C20_NUMDOC),6)),6)+;
       		(cAliasQ)->c0y_codigo+; 
       		(cAliasQ)->c03_codigo+(cAliasQ)->c14_codigo+; 
       		(cAliasQ)->c30_numite+; 
       		Padr(Alltrim((cAliasQ)->c1l_codigo),14)+; 
       		Padr(Alltrim((cAliasQ)->c31_lote),20)+; 
       		Space(41) 
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 60M                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L60M(cAliasQ,nReg60M) 
Local cLinha	:= ""  
Local cModelo	:= ""

cModelo	:= 	(cAliasQ)->c01_codigo

nReg60M++
cLinha	:=	'60M'+;
			(cAliasQ)->c6g_dtmov+;
			(cAliasQ)->c0w_ecffab+;
       		(cAliasQ)->c0w_ecfcx+;
       		cModelo+; 
       		StrZero(Val(AllTrim((cAliasQ)->c6g_nrcopi)),6)+; 
       		StrZero(Val(AllTrim((cAliasQ)->c6g_nrcopf)),6)+; 
       		StrZero(Val(AllTrim((cAliasQ)->c6g_pcredz)),6)+; 
       		StrZero(Val(AllTrim((cAliasQ)->c6g_pcreop)),3)+; 
       		StrTran(StrZero((cAliasQ)->c6g_vlbru,17,2),'.','')+; 
       		StrTran(StrZero((cAliasQ)->c6g_vlgrtf,17,2),'.','')+; 
			Space(37)
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 60A                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L60A(cAliasQ,nReg60A) 
Local cLinha 	:= ""  
Local sTributo	:= ""

If  AllTrim((cAliasQ)->sTrib) == 'A'
	sTributo := StrTran(StrZero((cAliasQ)->aliq,5,2),'.','')
Else
	sTributo := padr(AllTrim((cAliasQ)->sTrib),4)
EndIf

nReg60A++
cLinha	:= '60A'+;
			(cAliasQ)->dtemis+;
			(cAliasQ)->serie+;
	   		sTributo+;    
	   		StrTran(StrZero((cAliasQ)->valor,13,2),'.','')+; 
			Space(79)
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 60D                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L60D(cAliasQ,nReg60D) 
Local sTributo	:= ""                                  
Local cLinha 	:= ""

If  AllTrim((cAliasQ)->sTrib) == 'A'
	sTributo := StrTran(StrZero((cAliasQ)->aliq,5,2),'.','')
Else
	sTributo := padr(AllTrim((cAliasQ)->sTrib),4)
EndIf

nReg60D++
cLinha	:=	'60D'+;
			(cAliasQ)->dtemis+;	
			(cAliasQ)->serie+;
			padl(Alltrim((cAliasQ)->codigo),14)+;
	   		StrTran(StrZero((cAliasQ)->qtde,14,3),'.','')+; 
	   		StrTran(StrZero((cAliasQ)->vlrite,17,2),'.','')+; 
	   		StrTran(StrZero((cAliasQ)->vlrbc,17,2),'.','')+; 
	   		sTributo+; 
	   		StrTran(StrZero((cAliasQ)->vlrtrb,14,2),'.','')+; 
			Space(19)	
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 60I                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L60I(cAliasQ,nItem,nReg60I) 
Local cLinha 	:= ""     
Local cCod	 	:= ""
Local cModelo	:= ""    

cModelo		:= (cAliasQ)->c01_codigo

cCod :=  Padl(Right(AllTrim((cAliasQ)->c1l_codigo),14),14)
If (cAliasQ)->C3S_CODIGO = '04' // Sub trib
    nReg60I++
	cLinha	:= '60I'+;
				(cAliasQ)->c6i_dtemis+;
				(cAliasQ)->c0w_ecffab+;
		   		cModelo+; 
		   		StrZero(Val(Right(Alltrim((cAliasQ)->C6J_NUMDOC),6)),6)+;
		   		StrZero(nItem,3)+;
		   		cCod+; 	   		
		   		StrTran(StrZero((cAliasQ)->c6j_qtde,14,3),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6j_vlrite,14,2),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6k_vlrbc,13,2),'.','')+; 
		   		'F   '+; 
		   		StrTran(StrZero(0,13,3),'.','')+; 
				Space(16)  
EndIf				
If (cAliasQ)->c6k_vlisen > 0 // Isenta
    nReg60I++
	cLinha	:= '60I'+;
				(cAliasQ)->c6i_dtemis+;
				(cAliasQ)->c0w_ecffab+;
		   		cModelo+; 
		   		StrZero(Val(Right(Alltrim((cAliasQ)->C6J_NUMDOC),6)),6)+;
		   		StrZero(nItem,3)+;
		   		cCod+; 	   		
		   		StrTran(StrZero((cAliasQ)->c6j_qtde,14,3),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6j_vlrite,14,2),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6k_vlrbc,13,2),'.','')+; 
		   		'I   '+; 
		   		StrTran(StrZero(0,13,3),'.','')+; 
				Space(16)
EndIf 
If (cAliasQ)->c6k_vlntri > 0 // Isenta
    nReg60I++
	cLinha	:= '60I'+;
				(cAliasQ)->c6i_dtemis+;
				(cAliasQ)->c0w_ecffab+;
		   		cModelo+; 
		   		StrZero(Val(Right(Alltrim((cAliasQ)->C6J_NUMDOC),6)),6)+;
		   		StrZero(nItem,3)+;
		   		cCod+; 	   		
		   		StrTran(StrZero((cAliasQ)->c6j_qtde,14,3),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6j_vlrite,14,2),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6k_vlrbc,13,2),'.','')+; 
		   		'N   '+; 
		   		StrTran(StrZero(0,13,3),'.','')+; 
				Space(16)
	cPai	:=  '601'+(cAliasQ)->c6i_dtemis+(cAliasQ)->c0w_ecffab
EndIf 
If (cAliasQ)->C3S_CODIGO $ '02/03/17' // ICMS
    nReg60I++
	cLinha	:= '60I'+;
				(cAliasQ)->c6i_dtemis+;
				(cAliasQ)->c0w_ecffab+;
		   		cModelo+; 
		   		StrZero(Val(Right(Alltrim((cAliasQ)->C6J_NUMDOC),6)),6)+;
		   		StrZero(nItem,3)+;
		   		cCod+; 	   		
		   		StrTran(StrZero((cAliasQ)->c6j_qtde,14,3),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6j_vlrite,14,2),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6k_vlrbc,13,2),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6k_alqprd,5,2),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6k_vlrtrb,13,2),'.','')+; 
				Space(16)  
EndIf				
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 60R                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L60R(cAliasQ,nReg60R) 
Local cLinha 	:= ""     
Local cChave	:= ""  
Local cPai		:= ""
Local aLinha	:= {}

If (cAliasQ)->C3S_CODIGO = '04' // Sub trib
    nReg60R++
	cLinha	:= '60R'+;
				(cAliasQ)->mes+(cAliasQ)->Ano+;
		   		Padr(Right(AllTrim((cAliasQ)->c1l_codigo),14),14)+; 	   		
		   		StrTran(StrZero((cAliasQ)->c6j_qtde,14,3),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6j_vlrite,17,2),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6k_vlrbc,17,2),'.','')+; 
		   		'F   '+; 
				Space(54)  
	cChave	:=	'605' + (cAliasQ)->mes+(cAliasQ)->Ano
	aAdd(aLinha,{cLinha,cChave,cPai})
EndIf				
If (cAliasQ)->c6k_vlisen > 0 // Isenta
    nReg60R++
	cLinha	:= '60R'+;
				(cAliasQ)->mes+(cAliasQ)->Ano+;
		   		Padr(Right(AllTrim((cAliasQ)->c1l_codigo),14),14)+; 	   		
		   		StrTran(StrZero((cAliasQ)->c6j_qtde,14,3),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6j_vlrite,17,2),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6k_vlrbc,17,2),'.','')+; 
		   		'I   '+; 
				Space(54)  
	cChave	:=	'605' + (cAliasQ)->mes+(cAliasQ)->Ano
	aAdd(aLinha,{cLinha,cChave,cPai})
EndIf 
If (cAliasQ)->c6k_vlntri > 0 // Isenta
    nReg60R++
	cLinha	:= '60R'+;
				(cAliasQ)->mes+(cAliasQ)->Ano+;
		   		Padr(Right(AllTrim((cAliasQ)->c1l_codigo),14),14)+; 	   		
		   		StrTran(StrZero((cAliasQ)->c6j_qtde,14,3),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6j_vlrite,17,2),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6k_vlrbc,17,2),'.','')+; 
		   		'N   '+; 
				Space(54)  
	cChave	:=	'605' + (cAliasQ)->mes+(cAliasQ)->Ano
	aAdd(aLinha,{cLinha,cChave,cPai})
EndIf 
If (cAliasQ)->C3S_CODIGO $ '02/03/17' // ICMS
    nReg60R++
	cLinha	:= '60R'+;
				(cAliasQ)->mes+(cAliasQ)->Ano+;
		   		Padr(Right(AllTrim((cAliasQ)->c1l_codigo),14),14)+; 	   		
		   		StrTran(StrZero((cAliasQ)->c6j_qtde,14,3),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6j_vlrite,17,2),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6k_vlrbc,17,2),'.','')+; 
		   		StrTran(StrZero((cAliasQ)->c6k_alqprd,5,2),'.','')+; 
				Space(54)  
	cChave	:=	'605' + (cAliasQ)->mes+(cAliasQ)->Ano
	aAdd(aLinha,{cLinha,cChave,cPai})
EndIf				
Return aLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 61                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L61(cAliasQ,nReg61) 
Local cLinha := ""                    

nReg61++
cLinha	:=	'61'+;
			Space(14)+; 
			Space(14)+; 
			(cAliasQ)->c20_dtes+;
       		(cAliasQ)->c01_codigo+; 
       		Padr(Alltrim((cAliasQ)->c20_serie),3)+; 
       		Padr(Alltrim((cAliasQ)->c20_subser),2)+; 
			StrZero(Val(Right(Alltrim((cAliasQ)->C20_NUMDOC),6)),6)+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C20_NDOCF),6)),6)+;
       		StrTran(StrZero((cAliasQ)->c20_vldoc,14,2),'.','')+; 
       		StrTran(StrZero((cAliasQ)->c2f_base,14,2),'.','')+; 
       		StrTran(StrZero((cAliasQ)->c2f_valor,13,2),'.','')+; 
       		StrTran(StrZero((cAliasQ)->c2f_vlnt,14,2),'.','')+; 
       		StrTran(StrZero((cAliasQ)->c2f_vloutr,14,2),'.','')+; 
       		StrTran(StrZero((cAliasQ)->c2f_aliq,5,2),'.','')+; 
       		Space(1)            
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 61R                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L61R(cAliasQ,nReg61R) 
Local cLinha := ""  

nReg61R++
cLinha	:=	'61R'+;
			Mes+;
			Ano+;
			Padr(Alltrim((cAliasQ)->c1l_codigo),14)+;
	   		StrTran(StrZero((cAliasQ)->c30_quant,14,3),'.','')+; 
	   		StrTran(StrZero((cAliasQ)->c30_total,17,2),'.','')+; 
	   		StrTran(StrZero((cAliasQ)->c35_base,17,2),'.','')+; 
       		StrTran(StrZero((cAliasQ)->c35_aliq,5,2),'.','')+; 
       		Space(54)            
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 70                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L70(cAliasQ,nReg70) 
Local cLinha 	:= ""  
Local cCNPJCPF  := Iif(Alltrim((cAliasQ)->c1h_cnpj)<>"",(cAliasQ)->c1h_cnpj,(cAliasQ)->c1h_cpf) 
Local cSit		:= ""
Local cSer		:= ""

cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
If 		(cAliasQ)->C02_CODIGO == '02'
	cSit	:= "X"
ElseIf	(cAliasQ)->C02_CODIGO == '00'
	cSit	:= "N"
ElseIf	(cAliasQ)->C02_CODIGO $ '01/03'
	cSit	:= "E"
EndIf

cSer	:=	Alltrim((cAliasQ)->c20_serie) 

nReg70++
cLinha	:=	'70'+;
			cCNPJCPF+; 
			Padr(Alltrim((cAliasQ)->C1H_IE),14)+;			
			(cAliasQ)->c20_dtes+;
			(cAliasQ)->c09_uf+;
			(cAliasQ)->c01_codigo+; 
			Padr(Alltrim(cSer),1)+;
			Padr(Alltrim((cAliasQ)->c20_subser),2)+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C20_NUMDOC),6)),6)+;
			(cAliasQ)->c0y_codigo+;    			
       		StrTran(StrZero((cAliasQ)->c20_vldoc,14,2),'.','')+;  
       		StrTran(StrZero((cAliasQ)->c2f_base,15,2),'.','')+;  
       		StrTran(StrZero((cAliasQ)->c2f_valor,15,2),'.','')+;  
       		StrTran(StrZero((cAliasQ)->c2f_vlnt,15,2),'.','')+;  
       		StrTran(StrZero((cAliasQ)->c2f_vloutr,15,2),'.','')+;  
			(cAliasQ)->c0x_codigo+;
       		cSit
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 71                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L71(cAliasQ,nReg71) 
Local cLinha := ""  

nReg71++

cLinha	:=	'71'+;
			Iif(Alltrim((cAliasQ)->c1h_cnpj)<>"",(cAliasQ)->c1h_cnpj,StrZero(Val((cAliasQ)->c1h_cpf),14))+; 
			Padr(Alltrim((cAliasQ)->C1H_IE),14)+;			
			(cAliasQ)->c20_dtes+;
			(cAliasQ)->c09_uf+;
			(cAliasQ)->c01_codigo+; 
			Padr(Alltrim((cAliasQ)->c20_serie),1)+; 
			Padr(Alltrim((cAliasQ)->c20_subser),2)+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C20_NUMDOC),6)),6)+; 	
			(cAliasQ)->C092_UF+;
			Iif(Alltrim((cAliasQ)->ch2_cnpj)<>"",(cAliasQ)->ch2_cnpj,StrZero(Val((cAliasQ)->ch2_cpf),14))+; 
			Padr(Alltrim((cAliasQ)->CH2_IE),14)+;				
			(cAliasQ)->C3I_DTDOC+;					       		
			(cAliasQ)->C012_CODIGO+;   			
			Padr((cAliasQ)->C3I_SERIE,3)+; 
			StrZero(Val((cAliasQ)->C3I_NUMDOC),6)+;
			StrTran(StrZero((cAliasQ)->C3I_VLDOC,15,2),'.','')+;
			Padr(' ',12)
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  08/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 74                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L74(cAliasQ,nReg74) 
Local cLinha 	:= ""  
Local cCNPJCPF  :=  Iif(Alltrim((cAliasQ)->C1H_CNPJ)<>"",(cAliasQ)->C1H_CNPJ,(cAliasQ)->C1H_CPF)  
Local cPosse	:= "" // Posse das mercadorias deve ser tratado (1,2,3 no Sintegra, no SPED eh 0,1,2 como eh gravado no banco)
Local cCod		:= ""
Local cIEPosse:= "" // Se cPosse for igual a 1, preencher com brancos; se igual a 2, preencher com a IE da empresa que detém a 
						//posse da mercadoria de propriedade do informante; se igual a 3, preencher com a IE da proprietária da mercadoria em poder do informante."

cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCod		:=  PadR(Right(AllTrim((cAliasQ)->c1l_codigo),14),14)
                   
If		(cAliasQ)->C5B_INDPRO == '0'
		cPosse := '1'
ElseIf 	(cAliasQ)->C5B_INDPRO == '1'
		cPosse := '2'
ElseIf 	(cAliasQ)->C5B_INDPRO == '2'
		cPosse := '3'
EndIf

cIEPosse := IIF(cPosse = '1', Space(14), cIEPosse := Padr(Alltrim((cAliasQ)->C1H_IE),14))

nReg74++           
cLinha	:=	'74'+;
			(cAliasQ)->C5A_DTINV+;
			cCod+;
			StrTran(StrZero((cAliasQ)->C5B_QTD,14,3),'.','')+;  
			StrTran(StrZero((cAliasQ)->C5B_VITEM,14,2),'.','')+;  
			cPosse+;
			cCNPJCPF+;
			cIEPosse+;			
			(cAliasQ)->C09_UF+;
            Space(45)
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  08/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 75                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L75(cAliasQ,nReg75) 
Local cLinha := ""      
Local cDescr := Alltrim((cAliasQ)->C1L_DESCRI)
Local cProd	 := (cAliasQ)->C1L_CODIGO

nReg75++
cLinha	:=	'75'+;
			dtos(mv_par01)+dtos(mv_par02)+;			
			Padr(AllTrim(cProd),14)+;
			Padr(AllTrim((cAliasQ)->C0A_CODIGO),8)+;
			Padr(cDescr,53)+;
			Padr(Alltrim((cAliasQ)->C1J_CODIGO),6)+;
			StrTran(StrZero((cAliasQ)->c1l_alqipi,6,2),'.','')+;  
			StrTran(StrZero((cAliasQ)->c1l_alqicm,5,2),'.','')+;  
			StrTran(StrZero((cAliasQ)->c1l_redbc,6,2),'.','')+;    
			StrTran(StrZero((cAliasQ)->vlrbc,14,2),'.','')    			
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 76                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L76(cAliasQ,nReg76) 
Local cLinha 	:= ""  
Local cCNPJCPF  := Iif(Alltrim((cAliasQ)->c1h_cnpj)<>"",(cAliasQ)->c1h_cnpj,(cAliasQ)->c1h_cpf) 
Local cSit		:= ""
Local cSer		:= ""     
Local cTpRec	:= ""

cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
If 		(cAliasQ)->C02_CODIGO == '02'
	cSit	:= "X"
ElseIf	(cAliasQ)->C02_CODIGO == '00'
	cSit	:= "N"
ElseIf	(cAliasQ)->C02_CODIGO $ '01/03'
	cSit	:= "E"
EndIf

If 		(cAliasQ)->C10_CODIGO $ '0/1/2/3/4/5/6/7/ '
	cTpRec	:= "1"
ElseIf	(cAliasQ)->C10_CODIGO == '8'
	cTpRec	:= "2"
Else
	cTpRec	:= "1"
EndIf	


cSer	:= Alltrim((cAliasQ)->c20_serie)

nReg76++
cLinha	:=	'76'+;
			cCNPJCPF+;
			Padr(Alltrim((cAliasQ)->C1H_IE),14)+;			
			(cAliasQ)->C01_CODIGO+;
			Padr(Alltrim(cSer),2)+;
			Padr(Alltrim((cAliasQ)->c20_subser),2)+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C20_NUMDOC),10)),10)+;
			(cAliasQ)->C0Y_CODIGO+;
			cTpRec+;
			(cAliasQ)->C20_DTES+;
			(cAliasQ)->C09_UF+;
			StrTran(StrZero((cAliasQ)->C20_VLDOC,14,2),'.','')+;
			StrTran(StrZero((cAliasQ)->C2F_BASE,14,2),'.','')+; 
			StrTran(StrZero((cAliasQ)->C2F_VALOR,13,2),'.','')+; 
			StrTran(StrZero((cAliasQ)->C2F_VLNT,13,2),'.','')+; 
			StrTran(StrZero((cAliasQ)->C2F_VLOUTR,13,2),'.','')+; 
			StrTran(StrZero((cAliasQ)->C2F_ALIQ,2,0),'.','')+; 
			cSit
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 77                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L77(cAliasQ,nReg77) 
Local cLinha 	:= ""  
Local cCNPJCPF  := Iif(Alltrim((cAliasQ)->c1h_cnpj)<>"",(cAliasQ)->c1h_cnpj,(cAliasQ)->c1h_cpf) 
Local cMF  		:= Iif(Alltrim((cAliasQ)->mf)<>"",(cAliasQ)->mf,(cAliasQ)->mf) 

Local cSit		:= ""
Local cSer		:= ""     

cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])

cMF	:=	PadR(AllTrim(cMF),TamSx3("C1H_CNPJ")[1])
cMF	:= 	StrZero(Val(cMF),TamSx3("C1H_CNPJ")[1])

If 		(cAliasQ)->C02_CODIGO == '02'
	cSit	:= "X"
ElseIf	(cAliasQ)->C02_CODIGO == '00'
	cSit	:= "N"
ElseIf	(cAliasQ)->C02_CODIGO $ '01/03'
	cSit	:= "E"
EndIf

cSer	:=	Alltrim((cAliasQ)->c20_serie)

If 		(cAliasQ)->C10_CODIGO $ '0/1/2/3/4/5/6/7/ '
	cTpRec	:= "1"
ElseIf	(cAliasQ)->C10_CODIGO == '8'
	cTpRec	:= "2"
Else
	cTpRec	:= "1"
EndIf	


nReg77++
cLinha	:=	'77'+;
			cCNPJCPF+;
			(cAliasQ)->C01_CODIGO+;
			Padr(cSer,2)+;
			Padr(Alltrim((cAliasQ)->c20_subser),2)+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C20_NUMDOC),10)),10)+;
			(cAliasQ)->C0Y_CODIGO+;
			cTpRec+;
			(cAliasQ)->C30_NUMITE+;
			Padr(Alltrim((cAliasQ)->C0B_CODIGO),11)+;
			StrTran(StrZero((cAliasQ)->C30_QUANT,14,2),'.','')+;
			StrTran(StrZero((cAliasQ)->C30_TOTAL,13,2),'.','')+;
			StrTran(StrZero((cAliasQ)->C30_VLDESC,13,2),'.','')+;			
			StrTran(StrZero((cAliasQ)->C35_BASE,13,2),'.','')+; 
			StrTran(StrZero((cAliasQ)->C35_ALIQ,2,0),'.','')+;       
			cMF+;			
			StrZero(Val(Right(Alltrim((cAliasQ)->C2G_TERMIN),10)),10)			
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 85                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L85(cAliasQ,nReg85) 
Local cLinha	:= ""  
Local cNatExp	:= ""   

If 		(cAliasQ)->C4F_NATEXP == '0'
	cNatExp	:=	'1'
ElseIf	(cAliasQ)->C4F_NATEXP == '1'
	cNatExp	:=	'2'
ElseIf	(cAliasQ)->C4F_NATEXP == '2'
	cNatExp	:=	'3'
ElseIf	(cAliasQ)->C4F_NATEXP == '3'
	cNatExp	:=	'4'
EndIf

nReg85++
cLinha	:=	'85'+;
			StrZero(Val((cAliasQ)->C4F_NRODE),11)+;
			(cAliasQ)->C4F_DTDE+;
			cNatExp+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C4F_NRORE),12)),12)+;
			(cAliasQ)->C4F_DTRE+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C4F_CHCEMB),16)),16)+;
			(cAliasQ)->C4F_DTCHC+;
			(cAliasQ)->C0S_CODIGO+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C08_CODIGO),04)),04)+;
            '00000000'+;
			(cAliasQ)->C4F_DTAVB+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C4G_NUMDOC),6)),6)+;
			(cAliasQ)->C4G_DTDOC+;
			(cAliasQ)->C01_CODIGO+;            
			Padr(Alltrim((cAliasQ)->C4G_SERIE),3)+;
			Space(19)
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo Zanaga       º Data ³  28/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Linha do registro 86                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119L86(cAliasQ,nSeq86) 
Local cLinha	:=	""  
Local cCNPJCPF  := Alltrim((cAliasQ)->c1h_cnpj)
Local cSer		:=	""
Local cCod		:=	""            


cSer		:=	Alltrim((cAliasQ)->c4g_serie) 
cCod		:=  PadR(Right(AllTrim((cAliasQ)->c1l_codigo),14),14)
cCNPJCPF	:=	PadR(AllTrim(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
cCNPJCPF	:= 	StrZero(Val(cCNPJCPF),TamSx3("C1H_CNPJ")[1])
nSeq86++
cLinha	:=	'86'+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C4F_NRORE),12)),12)+;
			(cAliasQ)->C4F_DTRE+;
			cCNPJCPF+;
			Padr(Alltrim((cAliasQ)->C1H_IE),14)+;			
			(cAliasQ)->C09_UF+;
			StrZero(Val(Right(Alltrim((cAliasQ)->C4G_NUMDOC),6)),6)+;
			(cAliasQ)->C4G_DTDOC+;
			(cAliasQ)->C01_CODIGO+;
			Padr(Alltrim(cSer),3)+;
			cCod+;
	   		StrTran(StrZero((cAliasQ)->c4h_qtd,12,3),'.','')+; 
	   		StrTran(StrZero((cAliasQ)->c4h_vlruni,13,2),'.','')+; 
	   		StrTran(StrZero((cAliasQ)->c4h_vlrtot,13,2),'.','')+; 
			(cAliasQ)->c4g_codrel+;									
			Space(05)
Return cLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³AvlDrv     ºAutor  ³Danilo L Zanaga     º Data ³  17/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AvlDrv(nHandle,nBytes,nAtual)

Local 	nDisco	:=	0
Local 	cDisco	:= MV_PAR03
Local 	cPath	:=	""
Local 	cFile
Local	nHdlChk	:=	0
Local	cAliasTRBChk	:=	"TAFA119.CHK"
Local  	nOpcA	:=	2
Local	nOpcB	:=	2

Local	cAliasTRBTxt:=	Alltrim(MV_PAR04)

While (nOpcA==2) .And. (nOpcB==2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define disco a ser gravado                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	__cDest := Nil
	If !Empty(cDisco)
		nDisco	:=	Asc(cDisco)-Asc("A")+1
		cPath	:=	AllTrim(cDisco)+"\"
	Else
		cPath:=""
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se drive ‚ avaliavel                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF Subs(cDisco,1,1)$"AB"
		cAliasTRBChk	:=	cPath+cAliasTRBChk
		nHdlChk	:=	MsFCreate(cAliasTRBChk)
		If nHdlChk < 0
			nOpcB	:=	Aviso(STR0003,STR0004,{STR0002,STR0001}) //###"Abandona",###"Continua" //"Drive"###"Drive n„o est  dispon¡vel."
			If nOpcB==2
				Loop
			Else
				lEnd := .T. ; Exit
			Endif
		Else
			FClose(nHdlChk) ; Ferase(cAliasTRBChk)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica espaco no disco                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DiskSpace(nDisco)<nBytes
			cMsg := STR0005 //"N„o h  espa‡o no disco para grava‡„o;"
			cMsg += STR0006 //" Troque disquete para continuar..."
			nHdlChk := -1
			nOpcB:=Aviso("Drive",cMsg,{STR0002,STR0001}) //###"Abandonar",###"Continuar"
			If nOpcB==2
				Loop
			Else
				lEnd := .T. ; Exit
			Endif
		Endif
		cFile	:=cPath+cAliasTRBTxt
	Else
		cFile   :=CriaTrab(,.f.)
		__cTrbName := cFile
		__cDest := cPath+cAliasTRBTxt
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHandle	:=MsFCreate(cFile)
	If nHandle < 0
		nOpcB	:=	Aviso("Drive","Drive n„o est  pronto.",{"Abandona","Continua"})
		If nOpcB==2
			Loop
		Else
			lEnd := .T. ; Exit
		Endif
	EndIf
	Exit
EndDo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³R119Reg10 ºAutor  ³Danilo L Zanaga     º Data ³  05/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava  registro tipo 11 em arquivo texto                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R119Reg10(cCGC,cInsc,cFax)

Local cRegistro	:=	"10"
Local cFinalid 	:=	str(mv_par06,1)
              
cRegistro	+= xFunFill(Num2Chr(Val(SM0->M0_CGC),14,0),14)
cRegistro	+= xFunFill(ARETDIG(SM0->M0_INSC,.T.,SM0->M0_ESTENT),14)
cRegistro	+= xFunFill(SM0->M0_NOMECOM,35)
cRegistro	+= xFunFill(SM0->M0_CIDENT,30)
cRegistro	+= xFunFill(SM0->M0_ESTENT,02)
cRegistro	+= xFunFill(Num2Chr(FisGetTel(SUBS(ALLTRIM(SM0->M0_FAX),1,10))[3],10,0),10)
cRegistro	+= aFISFILL(DTOS(MV_PAR01),08)
cRegistro	+= aFISFILL(DTOS(MV_PAR02),08)
If YEAR(MV_PAR02)<2003
   cRegistro	+=	xFunFill("1",01)          					// Codigo da identificacao do Convenio
Else
   cRegistro	+=	xFunFill("3",01)          					// Codigo da identificacao do Convenio
Endif   
cRegistro	+= xFunFill(Str(MV_PAR15,1),01)
cRegistro	+= xFunFill(cFinalid,01)
R119Grava(cRegistro)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³R119Grava ºAutor  ³Danilo L Zanaga     º Data ³  13/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava Registro no arquivo texto e acrescenta marca de final º±±
±±º          ³de registro                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TAFA119                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Grava(cConteudo)

Private lEnd		:=	.F.

cConteudo += Chr(13)+Chr(10)

If !lEnd
	FWrite(nHandle,cConteudo,Len(cConteudo))
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R119Reg11    ³Autor ³ Andreia dos Santos  ³ Data ³ 05/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava registro tipo 11                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Reg11(cEnderec,nNumero,cContato,cTEL)

Local cRegistro	:=	"11"
Local aArray	:=	{}


If Empty(aArray) .Or. !(ValType(aArray) == "A") .or.(ValType(aArray) == "A" .and. Len(aArray) # 7)
	aArray := { 	cEnderec	,;				//	[1] Endereco
		nNumero		,;				//	[2] Numero
		SM0->M0_COMPENT	,;				//	[3] complemento
		PadR(SM0->M0_BAIRENT,15),;	//	[4] Bairro
		Val(SM0->M0_CEPENT)	 ,;	//	[5] CEP
		cContato				 ,;	//	[6] Contato
		PadR(cTEL,12) }			//	[7] Telefone
Else
	aArray[1]	:=	IIf( !(Valtype(aArray[1])=="C"),cEnderec,aArray[1])
	aArray[2]	:=	IIf( !(Valtype(aArray[2])=="N"),nNumero,aArray[2])
	aArray[3]	:=	IIf( !(Valtype(aArray[3])=="C"),SM0->M0_COMPENT,aArray[3])
	aArray[4]	:=	IIf( !(Valtype(aArray[4])=="C"),PadR(SM0->M0_BAIRENT),aArray[4])
	aArray[5]	:=	IIf( !(Valtype(aArray[5])=="N"),Val(SM0->M0_CEPENT),aArray[5])
	aArray[6]	:=	IIf( !(Valtype(aArray[6])=="C"),cContato,aArray[6])
	aArray[7]	:=	IIf( !(Valtype(aArray[7])=="N"),PadR(cTEL,12),aArray[7])
EndIf

cRegistro	+=	xFunFill(aArray[1],34)						// Logradouro
cRegistro	+=	xFunFill(Num2Chr(aArray[2],5,0),05)	// Numero
cRegistro	+=	xFunFill(IIf(aArray[2]==0,"S/N",aArray[3]),22)						// Complemento
cRegistro	+=	xFunFill(aArray[4],15)						// Bairro
cRegistro	+=	xFunFill(Num2Chr(aArray[5],8,0),08)	// CEP
cRegistro	+=	xFunFill(aArray[6],28)					  	// Contato
cRegistro	+=	xFunFill(Num2Chr(Val(aArray[7]),12,0),12)	// Telefone

R119Grava(cRegistro)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TAFA119   ºAutor  ³Danilo L Zanaga     º Data ³  23/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAliasQ	Alias da query								      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona registros no arquivo                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119AddLin(cAliasQ,cGrupo,cSubGrp,aSeqs,aQueries)
Local nI		:= 0
//Variaveis de Registro
Local cLinha	:= ""
//Sequencia para Reg 60I (Item do ECF que nao possui esse campo na tabela)
Local nSeq60I	:=	0
//Documento do 60I para zerar nSeq60I
Local   cNumDoc	:=	0
//Array da linha que estiver processando
Local	aLinha	:= 	{}               
// Array das NFs para Reg 50
Local 	aNF			:=	{}       
Local	aNFIT		:=	{}
Local	cChaveIT	:=	""
Local   nImp		:=  0 	//Id do imposto
Local	nAliq		:=	0
Local	nIT			:=	0
// Array com os itens a partir do 991 
Local   aIT900	:=	{} 
Local   aIT		:=	{} 

// Chave para tratamento de mudanca de item
Local 	cChave	:=	""
Local 	lIT900	:=	.F.
Local 	cProd	:= ""    
Local   cCPFCNPJ := ""     
Local   nValorSt := 0
Default cSubGrp := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta arquivo temporario  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

DbSelectArea( cAliasQ )
( cAliasQ )->( DbGoTop( ) )
While !(cAliasQ)->(eof())         		

	cLinha	:= ''                               
	aLinha	:= {}
	
	//Somente para 50, tratamento para CFOP e ALIQ
	If 	(cGrupo	== '50')  
    	cChave	:= (cAliasQ)->C20_CHVNF                
     	If (cAliasQ)->C3S_CODIGO $ '02/03/04/17'
			nImp	:=	1  //ICMS          
			nAliq	:= (cAliasQ)->C2F_ALIQ
     	ElseIf (cAliasQ)->C3S_CODIGO $ '05'
			nImp	:= 	2 //IPI
			nAliq	:= 	0
		EndIf				
     	nPos := aScan(aNF,{|x| x[1] == cChave .And. x[9] == (cAliasQ)->C0Y_CODIGO .And. x[16] == nAliq .And. x[18] == nImp})    
     	
     	cCPFCNPJ := ""							
	    If (cAliasQ)->C1H_PPES == '1'
	    	cCPFCNPJ :=	(cAliasQ)->C1H_CPF
	    Else
	    	cCPFCNPJ :=	(cAliasQ)->C1H_CNPJ
	    Endif
	    
		If  nPos == 0
			aAdd(aNF,{(cAliasQ)->C20_CHVNF,;
   						cCPFCNPJ,;
						Padr(Alltrim((cAliasQ)->C1H_IE),14),;			
						(cAliasQ)->C20_DTES,;
						(cAliasQ)->C09_UF,;
						(cAliasQ)->C01_CODIGO,;
						(cAliasQ)->C20_SERIE,;
						(cAliasQ)->C20_NUMDOC,;
						(cAliasQ)->C0Y_CODIGO,;
						(cAliasQ)->C20_INDEMI,;
						(cAliasQ)->TOTAL,;
						IIf(nImp==1,(cAliasQ)->BASE,0),; 
						IIf(nImp==1,(cAliasQ)->VALOR,0),; 
						(cAliasQ)->ISENTA,; 
						(cAliasQ)->OUTRAS,; 
						nAliq,;
						(cAliasQ)->C02_CODIGO,;
						nImp,;
						(cAliasQ)->C20_INDOPE})
        Else
			aNF[nPos][11]	+=	(cAliasQ)->TOTAL
			aNF[nPos][12]	+=	IIf(nImp==1,(cAliasQ)->BASE,0) 
			aNF[nPos][13]	+=	IIf(nImp==1,(cAliasQ)->VALOR,0)
			aNF[nPos][14]	+=	(cAliasQ)->ISENTA			
			aNF[nPos][15]	+=	(cAliasQ)->OUTRAS			
		EndIf
    EndIf

    
	If cGrupo == '54' //Adiciona itens para aglutinar
    	cChaveIT	:= (cAliasQ)->C20_CHVNF 
     	If (cAliasQ)->C3S_CODIGO $ '02/03/17'
			nImp	:=	1  //ICMS          
			nAliq	:= (cAliasQ)->C35_ALIQ
     	ElseIf (cAliasQ)->C3S_CODIGO $ '05'
			nImp	:= 	2 //IPI
			nAliq	:= 	0
		EndIf				
     	If (cAliasQ)->C01_CODIGO $ '21/22'
        	cProd	:= (cAliasQ)->C0B_CODIGO  //Cod Servico
     	Else
        	cProd	:= (cAliasQ)->C1L_CODIGO //Cod Produto
		EndIf
     	nPos := aScan(aNFIT,{|x| x[1] == cChaveIT .And. x[9] == (cAliasQ)->C0Y_CODIGO .And. x[9] == cProd ;
	  								.And. x[16] == nAliq .And. x[17] == nImp})      
	  	
	  	cCPFCNPJ := ""							
	    If (cAliasQ)->C1H_PPES == '1'
	    	cCPFCNPJ :=	(cAliasQ)->C1H_CPF
	    Else
	    	cCPFCNPJ :=	(cAliasQ)->C1H_CNPJ
	    Endif
	    
  		nValorSt := 0
		//Quando o o tributo for ICMS, verifico se o item possui ICMS-ST
  		If (cAliasQ)->C3S_CODIGO == '02'   
    		dbSelectArea("C35")
			dbSetOrder(1)       
   			If (C35-> ( DbSeek ( xFilial("C35") + (cAliasQ)->C20_CHVNF + (cAliasQ)->C30_NUMITE + (cAliasQ)->C30_CODITE + '000004' ))) 
       			nValorSt := C35->C35_BASE    
       		EndIf
		EndIf       
	 	    
		If  nPos == 0  .And. nImp<>2
			nIt	+= 1  
			
			aAdd(aNFIT,{(cAliasQ)->C20_CHVNF,;
 					 cCPFCNPJ,;
					(cAliasQ)->C01_CODIGO,;
					(cAliasQ)->C20_SERIE,;
					(cAliasQ)->C20_NUMDOC,;
					(cAliasQ)->C0Y_CODIGO,;
					(cAliasQ)->C03_CODIGO+IIf((cAliasQ)->CSTICM=="  ","00",(cAliasQ)->CSTICM),;
					StrZero(nIT,3),;
					cProd,;
					(cAliasQ)->C30_QUANT,;
					(cAliasQ)->C30_TOTAL1,;
					(cAliasQ)->C30_VLDESC,;
					IIF((cAliasQ)->C3S_CODIGO $ '02/03/17',(cAliasQ)->C35_BASE,0),;	//ICMS
	            	nValorST,;        //ST
	            	(cAliasQ)->VLRIPI,;		//IPI
					(cAliasQ)->C35_ALIQ,;
					nImp,;
					(cAliasQ)->C34_CHASSI,;
					(cAliasQ)->C31_LOTE,;
					(cAliasQ)->C20_SUBSER})
        ElseIf nImp<>2
			aNFIT[nPos][11]	+=	(cAliasQ)->C30_TOTAL1
			aNFIT[nPos][12]	+=	(cAliasQ)->C30_VLDESC
			aNFIT[nPos][13]	+=	IIF((cAliasQ)->C3S_CODIGO $ '02/03/17',(cAliasQ)->C35_BASE,0)	//ICMS
			aNFIT[nPos][14]	+=	nValorST        //ST
			aNFIT[nPos][15]	+=	(cAliasQ)->VLRIPI		//IPI
		EndIf	
	EndIf
	
	//Somente para 54, tratamento para o item 901 a 999
	If 	(cGrupo	== '54')  .And. (cChave == "")
    	cChave	:= (cAliasQ)->C20_CHVNF
    	aAdd(aIT900,{(cAliasQ)->C20_VLRFRT,(cAliasQ)->C20_VLRSEG,(cAliasQ)->PISCOF,(cAliasQ)->ICMCMP,(cAliasQ)->VLRISS,(cAliasQ)->C20_VLRDA})    	
    	aAdd(aIT,{cCPFCNPJ,(cAliasQ)->C01_CODIGO,Padr(Alltrim((cAliasQ)->C20_SERIE),3),(cAliasQ)->C20_NUMDOC,(cAliasQ)->C0Y_CODIGO,(cAliasQ)->C03_CODIGO,(cAliasQ)->CSTICM,(cAliasQ)->C30_TOTAL})    	
	EndIf    
	
    //Recupera a linha para o TRB 
	If 	cGrupo	== '51' 
		cLinha	:=	R119L51(cAliasQ,'51',@aSeqs[2]) 
    ElseIf 	cGrupo	== '53' 
		cLinha	:=	R119L53(cAliasQ,'53',@aSeqs[3]) 
    ElseIf 	cGrupo	== '56'
		cLinha	:=	R119L56(cAliasQ,@aSeqs[6])  
    ElseIf 	cGrupo	== '55' 
		cLinha	:=	R119L55(cAliasQ,@aSeqs[5]) 
    ElseIf 	cGrupo	== '57'
		cLinha	:=	R119L57(cAliasQ,@aSeqs[7]) 
    ElseIf 	cGrupo	== '60' .And. cSubGrp == 'M' .And. (MV_PAR07 >= 2)	.And. (MV_PAR10 == 	1)
		//Para o 60, deve fazer um loop para A,D,I
		cLinha	:=	R119L60M(cAliasQ,@aSeqs[8]) 
		//Grava 60 - Mestre
		R119Grava(cLinha)		
		//Grava 60 - Analitico por ECF
		R119Q60A(aQueries[1][13],(cAliasQ)->C6F_ID)   
        While !(aQueries[1][13])->(eof())
			cLinha	:=	R119L60A(aQueries[1][13],@aSeqs[9]) 
			R119Grava(cLinha)		                    
			//Grava 60 - Diario por ECF
			If MV_PAR11 == 1			// Gera 60D, sim ou nao
				R119Q60D(aQueries[1][14],(cAliasQ)->C6F_ID)   
        		While !(aQueries[1][14])->(eof())
					cLinha	:=	R119L60D(aQueries[1][14],@aSeqs[10]) 
					R119Grava(cLinha)	
				    //Grava 60 - Item por ECF
					If MV_PAR12 == 1
						R119Q60I(aQueries[1][15],(cAliasQ)->C6F_ID)   
        				cNumDoc := ""
        				While !(aQueries[1][15])->(eof())
							If (cNumDoc <> (aQueries[1][15])->C6J_NUMDOC)
								nSeq60I	:= 0
								cNumDoc	:= (aQueries[1][15])->C6J_NUMDOC
							EndIf	
							nSeq60I++
							cLinha	:=	R119L60I(aQueries[1][15],nSeq60I,@aSeqs[11]) 
							R119Grava(cLinha)		  
							(aQueries[1][15])->(DbSkip())                  
						EndDo	              
						(aQueries[1][15])->(DBCLOSEAREA())
					EndIf	                          						                    
					(aQueries[1][14])->(DbSkip())
            	EndDo
				(aQueries[1][14])->(DBCLOSEAREA())
			EndIf	
			(aQueries[1][13])->(DbSkip()) 	          	
		EndDo             
		(aQueries[1][13])->(DBCLOSEAREA())
    ElseIf 	cGrupo	== '60' .And. cSubGrp == 'R' .And. MV_PAR13 == 1
		aLinha	:=	R119L60R(cAliasQ,@aSeqs[12]) 
    ElseIf 	cGrupo	== '61' .And. cSubGrp == ''
		cLinha	:=	R119L61(cAliasQ,@aSeqs[13]) 
    ElseIf 	cGrupo	== '61' .And. cSubGrp == 'R' .And. MV_PAR14 == 1
		cGrupo	:= '61_1' 							//Este registro deve ir depois do 61, por isso mudou-se o grupo
		cLinha	:=	R119L61R(cAliasQ,@aSeqs[14]) 
    ElseIf 	cGrupo	== '70'
		cLinha	:=	R119L70(cAliasQ,@aSeqs[15]) 
    ElseIf 	cGrupo	== '71'
		cLinha	:=	R119L71(cAliasQ,@aSeqs[16]) 
    ElseIf 	(cGrupo	== '74') 
		cLinha	:=	R119L74(cAliasQ,@aSeqs[17]) 
    ElseIf 	cGrupo	== '75'
		cLinha	:=	R119L75(cAliasQ,@aSeqs[18]) 
    ElseIf 	cGrupo	== '76'
		cLinha	:=	R119L76(cAliasQ,@aSeqs[19]) 
    ElseIf 	cGrupo	== '77'
		cLinha	:=	R119L77(cAliasQ,@aSeqs[20]) 
    ElseIf 	cGrupo	== '85'
		cLinha	:=	R119L85(cAliasQ,@aSeqs[21]) 
    ElseIf 	cGrupo	== '86'
		cLinha	:=	R119L86(cAliasQ,@aSeqs[22]) 
   	EndIf
						
	(cAliasQ)->(DbSkip()) 	  
	
	//Se mudar a nota, grava array de nota no Reg50
	If (cGrupo == '50' .And. cChave <> (cAliasQ)->C20_CHVNF) .Or. ((cAliasQ)->(eof()) .And. cGrupo == '50') 
		For nI := 1 To Len(aNF)
			cLinha	:=	R119L50(aNF[nI],'50',@aSeqs[1]) 
			If Alltrim(cLinha) <> ""
				R119Grava(cLinha)
			EndIf	
		Next NI  	   
		nIT	:=	0
		aNF	:= {}					
	EndIf

	//Se mudar a nota, complementa itens de valores adicionais (901 a 999)
	If (cGrupo == '54' .And. cChave <> (cAliasQ)->C20_CHVNF) .Or. ((cAliasQ)->(eof()) .And. cGrupo == '54') 
		//Primeiro grava os itens
		For nI := 1 To Len(aNFIT)
			cLinha	:=	R119L54(aNFIT[nI],'54',@aSeqs[4]) 
			If Alltrim(cLinha) <> ""
				R119Grava(cLinha)
			EndIf	
		Next NI       
		nIT		:= 0
		aNFIT	:= {} 
		
		//Grava os itens 991 a 999
		cChave := ""
		lIT900 := .T.
		For nI := 1 To Len(aIT900[1])
			If aIT900[1][nI] > 0
				cLinha	:=	R119L54(,'54',@aSeqs[4],aIT900,aIT,nI) 
				If Alltrim(cLinha) <> ""
					R119Grava(cLinha)
				EndIf	
			EndIf		
		Next NI  
		aIT900	:= {}
		aIT		:= {}		
	EndIf
	
	If (Len(aLinha) > 0) .And. cGrupo	== '60' .And. cSubGrp == 'R'
    	For nI := 1 To Len(aLinha)
    		cLinha	:= aLinha[nI][1]
			R119Grava(cLinha)
		Next nI
	ElseIf cLinha <> '' .And. cGrupo <> '60'  .And. cGrupo	<> '54' .And. cGrupo	<> '50'
		R119Grava(cLinha)
	ElseIf 	lIT900	
		lIT900	:= .F.
	EndIf
	
	IncProc()
	
EndDo                       

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³xFunFill     ³Autor ³ Danilo L Zanaga     ³ Data ³ 20/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Encaixa conteudo em espaco especificado                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function xFunFill(cConteudo,nTam)
	
cConteudo	:=	If(cConteudo==NIL,"",cConteudo)
If Len(cConteudo)>nTam
	cRetorno	:=	Substr(cConteudo,1,nTam)
Else
	cRetorno	:=	cConteudo+Space(nTam-Len(cConteudo))
Endif
	
Return (cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³R119Reg90 ºAutor  ³Danilo L Zanaga     º Data ³  06/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119Reg90(aSeqs)

Local 	cRegistro   :=	""
Private lGravou		:=	.F.
Private nReg50	:= 0
Private nReg51	:= 0
Private nReg53	:= 0
Private nReg54	:= 0
Private nReg55	:= 0
Private nReg60	:= 0
Private nReg61	:= 0
Private nReg70	:= 0
Private nReg71	:= 0
Private nReg74	:= 0
Private nReg75 	:= 0
Private nReg85 	:= 0
Private nReg86 	:= 0
Private nReg90	:= 1

nReg50	:=	aSeqs[1]
nReg51	:=	aSeqs[2]
nReg53	:=	aSeqs[3]
nReg54	:=	aSeqs[4]
nReg55	:=	aSeqs[5]
nReg56	:=	aSeqs[6]
nReg57	:=	aSeqs[7]
nReg60	:=	aSeqs[8]+aSeqs[9]+aSeqs[10]+aSeqs[11]+aSeqs[12] // 60M+60A+60D+60I+60R
nReg61	:=	aSeqs[13]+aSeqs[14] //61+61R
nReg70	:=	aSeqs[15]
nReg71	:=	aSeqs[16]
nReg74	:=	aSeqs[17]
nReg75	:=	aSeqs[18]             
nReg76	:= 	aSeqs[19]
nReg77	:=	aSeqs[20]
nReg85 	:=	aSeqs[21]
nReg86 	:=	aSeqs[22]
nReg88	:=  0

nReg90	:=	1            	
cRegistro	:=	"90"												//01.Tipo
cRegistro	+=	xFunFill(Num2Chr(Val(SM0->M0_CGC),14,0),14)   //02.CGC
cRegistro	+=	xFunFill(ARETDIG(SM0->M0_INSC,.t.,SM0->M0_ESTENT),14) //03.Inscr. Estadual

If nReg50>0
	cRegistro	+=	"50"
	cRegistro	+=	xFunFill(StrZero(nReg50,8),8)	// Total de Registros "50"
EndIf

If nReg51>0
	cRegistro	+=	"51"
	cRegistro	+=	xFunFill(StrZero(nReg51,8),8)	// Total de Registros "51"
EndIf

If nReg53>0
	cRegistro	+=	"53"
	cRegistro	+=	xFunFill(StrZero(nReg53,8),8)	// Total de Registros "53"
EndIf

If nReg54>0
	cRegistro	+=	"54"
	cRegistro	+=	xFunFill(StrZero(nReg54,8),8)	// Total de Registros "54"
EndIf

If nReg55>0
	cRegistro	+=	"55"
	cRegistro	+=	xFunFill(StrZero(nReg55,8),8)	// Total de Registros "55"
EndIf

If nReg56>0
	cRegistro	+=	"56"
	cRegistro	+=	xFunFill(StrZero(nReg56,8),8)	// Total de Registros "56"
EndIf                                    

If nReg57>0
	cRegistro	+=	"57"
	cRegistro	+=	xFunFill(StrZero(nReg57,8),8)	// Total de Registros "57"
EndIf                                    

If nReg60>0
	cRegistro	+=	"60"
	cRegistro	+=	xFunFill(StrZero(nReg60,8),8)	// Total de Registros "60"
EndIf

If nReg61>0
	cRegistro	+=	"61"
	cRegistro	+=	xFunFill(StrZero(nReg61,8),8)	// Total de Registros "61"
EndIf

// Imprime Reg. Tipo 90
If Len(cRegistro)>=110 .And.!lGravou
	R119IncReg90(@cRegistro,@nReg90,(nReg70+nReg71+nReg74+nReg75+nReg76+nReg77+nReg85+nReg86+nReg88))
EndIf

If nReg70>0
	cRegistro	+=	"70"
	cRegistro	+=	xFunFill(StrZero(nReg70,8),8)	// Total de Registros "70"
EndIf

// Imprime Reg. Tipo 90
If Len(cRegistro)>=110 .And.!lGravou
	R119IncReg90(@cRegistro,@nReg90,(nReg71+nReg74+nReg75+nReg76+nReg77+nReg85+nReg86+nReg88))
EndIf

If nReg71>0
	cRegistro	+=	"71"
	cRegistro	+=	xFunFill(StrZero(nReg71,8),8)	// Total de Registros "71"
EndIf

// Imprime Reg. Tipo 90
If Len(cRegistro)>=110.And.!lGravou
	R119IncReg90(@cRegistro,@nReg90,(nReg74+nReg75+nReg76+nReg77+nReg85+nReg86+nReg88))
EndIf

If nReg74>0
	cRegistro	+=	"74"
	cRegistro	+=	xFunFill(StrZero(nReg74,8),8)	// Total de Registros "74"
EndIf

// Imprime Reg. Tipo 90
If Len(cRegistro)>=110.And.!lGravou
	R119IncReg90(@cRegistro,@nReg90,(nReg75+nReg76+nReg77+nReg85+nReg86+nReg88))
EndIf

If nReg75>0
	cRegistro	+=	"75"
	cRegistro	+=	xFunFill(StrZero(nReg75,8),8)	// Total de Registros "75"
EndIf

// Imprime Reg. Tipo 90
If Len(cRegistro)>=110.And.!lGravou
	R119IncReg90(@cRegistro,@nReg90,(nReg76+nReg77+nReg85+nReg86+nReg88))
EndIf

If nReg76>0
	cRegistro	+=	"76"
	cRegistro	+=	xFunFill(StrZero(nReg76,8),8)	// Total de Registros "76"
EndIf

// Imprime Reg. Tipo 90
If Len(cRegistro)>=110.And.!lGravou
	R119IncReg90(@cRegistro,@nReg90,(nReg77+nReg85+nReg86+nReg88))
EndIf

If nReg77>0
	cRegistro	+=	"77"
	cRegistro	+=	xFunFill(StrZero(nReg77,8),8)	// Total de Registros "77"
EndIf

// Imprime Reg. Tipo 90
If Len(cRegistro)>=110.And.!lGravou
	R119IncReg90(@cRegistro,@nReg90,nReg85+nReg86+nReg88)
EndIf

If nReg85>0
	cRegistro	+=	"85"
	cRegistro	+=	xFunFill(StrZero(nReg85,8),8)	// Total de Registros "85"
EndIf

// Imprime Reg. Tipo 90
If Len(cRegistro)>=110.And.!lGravou
	R119IncReg90(@cRegistro,@nReg90,nReg86+nReg88)
EndIf

If nReg86>0
	cRegistro	+=	"86"
	cRegistro	+=	xFunFill(StrZero(nReg86,8),8)	// Total de Registros "86"
EndIf

// Imprime Reg. Tipo 90
If Len(cRegistro)>=110.And.!lGravou
	R119IncReg90(@cRegistro,@nReg90,nReg88)
EndIf

If nReg88 > 0
	cRegistro += "88"
	cRegistro	+=	xFunFill(StrZero(nReg88,8),8)	// Total de Registros "88"
EndIf	

// Imprime Reg. Tipo 90
If (Len(cRegistro)>=110.And.!lGravou).Or.!lGravou
	R119IncReg90(@cRegistro,@nReg90,0)
EndIf 	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³R119IncReg90 ºAutor  ³Danilo L Zanaga     º Data ³  06/04/01   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³ Grava registros tipo 90                                       º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³ TAFA119                                                       º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119IncReg90(cRegistro,nReg90,nResto)

If nResto<=0.And.(125-Len(cRegistro))>8
	// Nao possui mais registros a imprimir
	lGravou	:=	.T.
	cRegistro	+=	"99"
    cRegistro	+=	xFunFill(StrZero(2+nReg90+nReg50+nReg51+nReg53+nReg54+nReg55+nReg60+nReg61+nReg70+nReg71+nReg74+nReg75+nReg76+nReg77+nReg85+nReg86+nReg88+nReg56+nReg57,8),8)
	cRegistro	+=	xFunFill(,(125-Len(cRegistro)))	// Brancos ate registro final	
	cRegistro	+=	Alltrim(Str(nReg90)) 				// Nro registro tipo 90	
	R119Grava(cRegistro)
EndIf

If (125-Len(cRegistro))<=16	// VerIfica se imprime mais um registro
	If !lGravou
		nReg90++				// Incrementa reg. tipo 90
		cRegistro	+=	space(125-Len(cRegistro))
		cRegistro	+=	Alltrim(Str(nReg90))				// Nro registro tipo 90
		R119Grava(cRegistro)				
		If nResto<=0.And.(125-Len(cRegistro))<9
			// Nao possui mais registros a imprimir
			lGravou:=.T.
			cRegistro	:=	"90"	// Reinicializa segundo registro 90
			cRegistro	+=	xFunFill(Num2Chr(Val(SM0->M0_CGC),14,0),14)
			cRegistro	+=	xFunFill(ARETDIG(SM0->M0_INSC,.T.,SM0->M0_ESTENT),14)
			cRegistro	+=	"99"
			cRegistro	+=	xFunFill(StrZero(2+nReg90+nReg50+nReg51+nReg53+nReg54+nReg55+nReg60+nReg61+nReg70+nReg71+nReg74+nReg75+nReg76+nReg77+nReg85+nReg86+nReg88+nReg56,8),8)
			cRegistro	+=	xFunFill(,(125-Len(cRegistro)))	// Brancos ate registro final
			cRegistro	+=	Alltrim(Str(nReg90))  				// Nro registro tipo 90   
			R119Grava(cRegistro)
		Else
			cRegistro	:=	"90"	// Reinicializa segundo registro 90
			cRegistro	+=	xFunFill(Num2Chr(Val(SM0->M0_CGC),14,0),14)
			cRegistro	+=	xFunFill(ARETDIG(SM0->M0_INSC,.T.,SM0->M0_ESTENT),14)
		EndIf
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³R119Reg90 ºAutor  ³Danilo L Zanaga     º Data ³  06/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Imprime Resumo do Arquivo                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R119ImpRes(aSeqs)

Local 	cLinha	:=	" "
Local 	cFirma	:=	SM0->M0_NOMECOM
Local 	cInscr	:=	InscrEst()  
Local 	cEnde	:=	SM0->M0_ENDENT
Local 	cCGC	:=	""
Local 	nLin	:=	0	
Local	nColReg	:=	0
Local 	nI		:=	0
Local 	nTotal	:=	0
Local 	n60		:=	0
Local	n61		:=	0
Local	cTotal	:=	Alltrim(Str(1)) 
Local	cLabel	:=	STR0039


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o campo "CGC" nao esta sendo utilizado para armazenar outro tipo de informacao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SM0->M0_TPINSC == 2 .Or. SM0->M0_TPINSC == 0
	cCGC  := Transform( SM0->M0_CGC, "@R 99.999.999/9999-99" )
Else
	cCGC  := ""	
Endif

oPrint:Box( 050,001,050,580,"-2")  

//Assume linha inicial 30, caso queira aumentar a margem do topo, aumentar o valor
nLin	:=	90
nColReg	:=	320

oPrint:Say( nLin,200,STR0032,oArial06 )
oPrint:Say( nLin,275,cCGC,oArial06 )
oPrint:Say( nLin+10,200,STR0033,oArial06 )
oPrint:Say( nLin+10,275,cInscr,oArial06 )
oPrint:Say( nLin+20,200,STR0034,oArial06 )
oPrint:Say( nLin+20,275,cFirma,oArial06 )
oPrint:Say( nLin+30,200,STR0035,oArial06 )
oPrint:Say( nLin+30,275,cEnde,oArial06 )
oPrint:Say( nLin+40,200,STR0036,oArial06 )
oPrint:Say( nLin+40,275,DTOC(MV_PAR01) + STR0037 + DTOC(MV_PAR02),oArial06 )

oPrint:Say( nLin+120,200,STR0038 + '  10',oArial06 )
oPrint:Say( nLin+120,275,cTotal,oArial06 )	
oPrint:Say( nLin+120,nColReg,cLabel,oArial06 )	
oPrint:Say( nLin+130,200,STR0038 + '  11',oArial06 )
oPrint:Say( nLin+130,275,cTotal,oArial06 )	
oPrint:Say( nLin+130,nColReg,cLabel,oArial06 )	
                           
nLin	:=	nLin+130      
cLinha	:=	""
cTotal	:=	""  
cLabel	:=  ""

For nI := 1 To Len(aSeqs)    
	// 	nReg50,nReg51,nReg53,nReg54,nReg55,nReg56,nReg57,nReg60M,nReg60D,nReg60A,nReg60I,nReg60R,nReg61,nReg61R,
	//	nReg70,nReg71,nReg74,nReg75,nReg76,nReg77,nReg85,nReg86

  	If aSeqs[nI] > 0
  		nLin += 10 
		cTotal	:=	Alltrim(Str(aSeqs[nI])) 
		cLabel	:=	STR0040
		Do Case 
  			Case nI == 1
  				cLinha	:=	STR0038 + '  50'
  			Case nI == 2
  				cLinha	:=	STR0038 + '  51'
  			Case nI == 3
  				cLinha	:=	STR0038 + '  53'
  			Case nI == 4
  				cLinha	:=	STR0038 + '  54'
  			Case nI == 5
  				cLinha	:=	STR0038 + '  55'
  			Case nI == 6
  				cLinha	:=	STR0038 + '  56'
  			Case nI == 7
  				cLinha	:=	STR0038 + '  57'
  			Case nI == 8                    
  				n60		:= aSeqs[nI] + aSeqs[nI+1] + aSeqs[nI+2] + aSeqs[nI+3] + aSeqs[nI+4]
  				cLinha	:=	STR0038 + '  60'
  				nI		:= nI + 4
  			Case nI == 13                    
  				n61		:= 	aSeqs[nI] + aSeqs[nI+1] 
  				cLinha	:=	STR0038 + '  61'
				cTotal	:=	Alltrim(Str(n61)) 
  				nI		:= 	nI + 1
  			Case nI == 15
  				cLinha	:=	STR0038 + '  70'
  			Case nI == 16
  				cLinha	:=	STR0038 + '  71'
  			Case nI == 17
  				cLinha	:=	STR0038 + '  74'
  			Case nI == 18
  				cLinha	:=	STR0038 + '  75'
  			Case nI == 19
  				cLinha	:=	STR0038 + '  76'
  			Case nI == 20
  				cLinha	:=	STR0038 + '  77'
  			Case nI == 21
  				cLinha	:=	STR0038 + '  85'
  			Case nI == 21
  				cLinha	:=	STR0038 + '  86'
  		EndCase
  		oPrint:Say( nLin,200,cLinha,oArial06 )  
  		oPrint:Say( nLin,275,cTotal,oArial06 )	
  		oPrint:Say( nLin,nColReg,cLabel,oArial06 )	
  	EndIf	
Next nI	

For nI := 1 To Len(aSeqs)    
	nTotal := nTotal + aSeqs[nI]
Next nI

oPrint:Say( nLin+10,200,STR0038 + '  90',oArial06 )
oPrint:Say( nLin+10,275,Alltrim(Str(1)),oArial06 )	
oPrint:Say( nLin+10,nColReg,STR0039,oArial06 )	

nLin	+=	80
nTotal	+=	3
cTotal	:=	Alltrim(Str(nTotal)) 
cLabel	:=	STR0042
oPrint:Say( nLin,200,STR0041,oArial06 )
oPrint:Say( nLin,275,cTotal,oArial06 )	
oPrint:Say( nLin,nColReg,cLabel,oArial06 )	

oPrint:Box( 640,001,640,580,"-2")  

Return (Nil)



Static Function SaveTxt( nHandle , cTxtSys , cTxtUsu )
Local	cDrive		:=	''
Local	cPath		:=	''
Local	cNewFile	:=	''
Local	cExt		:=	''
Local	lCopied		:=	.F.
Local 	cStartPath 	:= 	GetSrvProfString( "StartPath" , "" )
Local	lRet		:=	.F.

If nHandle >= 0
	FClose( nHandle )
Endif

If File( cTxtUsu )		
	FErase( cTxtUsu )
Endif             

SplitPath( cTxtUsu , @cDrive , @cPath , @cNewFile , @cExt )
cNewFile	:=	cNewFile + cExt                    
	
If Empty( cDrive )  
	lCopied := __CopyFile( cTxtSys , cDrive + cPath + cNewFile ) 
Else                  
	If Substr( cStartPath , Len( AllTrim( cStartPath ) ) , 1 ) <> "\"
		cStartPath := cStartPath + "\"
	EndIf
	lCopied := CpyS2T( cStartPath + cTxtSys , cDrive + cPath , .F. )
EndIf                           
	
If lCopied
	FErase( cTxtSys )
	If File( cDrive + cPath + cTxtSys )
		FRename( cDrive + cPath + cTxtSys , cTxtUsu )
		lRet	:=	.T.
	EndIf
EndIf

Return lRet


Function SintVldPer( nPerg )
Local	lRet	:=	.T.

If nPerg == 4
	If !( lRet := ISALPHA(SUBSTR(MV_PAR04,1,1)) )
		Help( ,,".TAFA11904.",,, 1, 0 )
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

Construção dos painéis para geração do arquivo.

@Return	aRet	-	Parametrização necessária para a rotina xFunWizard

@Author	Danilo L Zanaga
@Since		06/02/2013
@Version	1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()	

Local	cNomWiz	   	:= "SINTEGRA"+FWGETCODFILIAL 
Local 	cNomeAnt 	:= ""	
Local	aTxtApre	:= {}
Local	aPaineis	:= {}
Local	aItens1		:= {}
Local	aItens2		:= {}
Local	cTitObj1	:= ""
Local	cTitObj2	:= ""	
Local	aRet		:= {}
//
aAdd (aTxtApre, "Processando Empresa.")
aAdd (aTxtApre, "")	
aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético SINTEGRA.")
	
//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 0³
//ÀÄÄÄÄÄÄÄÄÙ	
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético SINTEGRA.")
aAdd (aPaineis[nPos], {})

//MV_PAR01														//MV_PAR02
cTitObj1	:=	"Data Inicial:" ;								cTitObj2	:=	"Data Final:" //Data de - Data Ate 
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
aAdd (aPaineis[nPos][3], {2,,,3,,,,});							aAdd (aPaineis[nPos][3], {2,,,3,,,,}) 
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})


//MV_PAR03														//MV_PAR04
cTitObj1	:=	"Diretório do Arquivo Destino" ;				cTitObj2	:=	"Nome do Arquivo Destino"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

cTitObj1	:=	Replicate ("X", 50);							cTitObj2	:=	Replicate ("X", 20)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})


//MV_PAR05														//MV_PAR06
cTitObj1	:=	"UF Origem/Destino" ;							cTitObj2	:=	"Finalidade"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
																aItens2	:=	{}
																aAdd (aItens2, "Normal")
																aAdd (aItens2, "Ret. Total")
																aAdd (aItens2, "Total Rectif") 

cTitObj1	:=	Replicate ("X", 50)							
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
							
//MV_PAR07														//MV_PAR08
cTitObj1	:=	"Notas Fiscais ?";								cTitObj2	:=  "Gera Inventario:" 
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

aItens1	:=	{}; 												aItens2	:=	{}
aAdd (aItens1, "Entrada"); 										aAdd (aItens2, "Sim") 
aAdd (aItens1, "Saida");										aAdd (aItens2, "Não") 
aAdd (aItens1, "Ambas")										

aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});				    aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})


//MV_PAR09													    //MV_PAR10
cTitObj1	:=	"Data de Fechamento";							cTitObj2	:=  "Cupom Fiscal:" 
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

aAdd (aPaineis[nPos][3], {2,,,3,,,,});							aItens2	:=	{}
																aAdd (aItens2, "Sim") 
																aAdd (aItens2, "Não") 
		
															    aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})


//MV_PAR11														//MV_PAR12
cTitObj1	:=	"Gera Registro 60D";							cTitObj2	:=  "Gera Registro 60l:" 
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

aItens1	:=	{}; 												aItens2	:=	{}
aAdd (aItens1, "Sim"); 											aAdd (aItens2, "Sim") 
aAdd (aItens1, "Não");											aAdd (aItens2, "Não") 									

aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});				    aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})

aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})


//MV_PAR13														//MV_PAR14
cTitObj1	:=	"Gera Registro 60R";							cTitObj2	:=  "Gera Registro 61R:" 
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

aItens1	:=	{}; 												aItens2	:=	{}
aAdd (aItens1, "Sim"); 											aAdd (aItens2, "Sim") 
aAdd (aItens1, "Não");											aAdd (aItens2, "Não") 									

aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});				    aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})

aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})


//MV_PAR15														//MV_PAR16
cTitObj1	:=	"Natureza Operações";							cTitObj2	:=  "Destaca PINS/COFINS:" 
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

aItens1	:=	{}; 												aItens2	:=	{}
aAdd (aItens1, "Inter. ST"); 									aAdd (aItens2, "Sim") 
aAdd (aItens1, "Interestadual");								aAdd (aItens2, "Não") 									
aAdd (aItens1, "Totalidade");

aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});				    aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})


//MV_PAR17
cTitObj1	:=	"Consolidação na mesma UF"						
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})					

aItens1	:=	{}										
aAdd (aItens1, "Sim")							
aAdd (aItens1, "Não")															


aAdd (aPaineis[nPos][3], {0,"",,,,,,})
aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
aAdd (aPaineis[nPos][3], {1,"",,,,,,})			
aAdd (aPaineis[nPos][3], {1,"",,,,,,})
aAdd (aPaineis[nPos][3], {1,"",,,,,,})				


aAdd( aRet, aTxtApre )
aAdd( aRet, aPaineis )
aAdd( aRet, cNomWiz )
aAdd( aRet, cNomeAnt )
aAdd( aRet, Nil )
aAdd( aRet, Nil )

//Chamada de rotina de compatibilização da Wizard para SX1 do Sintegra
aAdd( aRet, { || TAFCOAjSX1( aVarPaineis ), TAFA119() } )	//Code Block para o botão "Finalizar" deve executar a rotina responsável pela geração do arquivo

Return( aRet )
