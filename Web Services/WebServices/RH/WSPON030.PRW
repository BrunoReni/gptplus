#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "WSPON030.CH"
/*/
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ��
���Fun��o    � WSPON030 � Autor � Emerson Campos                   � Data � 04/09/12 ���
������������������������������������������������������������������������������������Ĵ��
���Descri��o � Espelho de Ponto                                                      ���
������������������������������������������������������������������������������������Ĵ��
���Uso       � RH/Portais                                                            ���
������������������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                                ���
������������������������������������������������������������������������������������Ĵ��
��� Analista        � Data       � FNC ou REQ     � 	Motivo da Alteracao          ���
������������������������������������������������������������������������������������Ĵ�� 
���Emerson Campos   � 04/09/2012 � Req126-12      � Adaptar o fonte para apresentar o���
���                 �            �                � espelho de ponto para a fase 4.  ���
���                 �            �                �                                  ���
���Allyson M        � 25/07/2014 � TQCPCK         � Ajuste p/ listar os periodos que ���
���                 �            �                � foram fechados. Esse processo e' ���
���                 �            �                � o mesmo do Rh Online.            ���
���Eduardo K        � 08/02/2018 � MPRIMESP-13747 � Ajuste p/ exibir a qtde de demons���
���                 �            �                � trativos de acordo com o param.  ���
���                 �            �                � MV_TCFMARC.    			         ���
�������������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������/*/
Function WSPON030()
Return

WSSTRUCT TAnotationsList
	WSDATA Branch				AS String
	WSDATA Registration			AS String
	WSDATA DateEvent			AS String
	WSDATA DayWeek				AS String
	WSDATA Marks           		AS ARRAY OF TMarksList OPTIONAL
	WSDATA BonusReason			AS String
	WSDATA HoursMarkType		AS String
	WSDATA Observations			AS String
ENDWSSTRUCT

WSSTRUCT TMarksList
	WSDATA MarksItens	 		AS String
ENDWSSTRUCT

WSSTRUCT TPeriodsList
	WSDATA Fielter	 			AS String	
	WSDATA ValueFielter	 		AS String
ENDWSSTRUCT

WSSTRUCT TAnotationsFields 
	WSDATA Name		 			AS String
	WSDATA Department			AS String
	WSDATA CostCenter			AS String
	WSDATA Branch				AS String
	WSDATA Registration			AS String	
ENDWSSTRUCT 

WSSTRUCT TAnotationsBrowse
	WSDATA Itens				AS Array Of TAnotationsList		OPTIONAL
	WSDATA Fields				AS Array Of TAnotationsFields	OPTIONAL
	WSDATA Periods				AS Array Of TPeriodsList		OPTIONAL	
	WSDATA PeriodView			AS String	OPTIONAL
	WSDATA PeriodFielter		AS String
	WSDATA PDFURL				AS String	OPTIONAL
	WSDATA PDFName				AS String	OPTIONAL
ENDWSSTRUCT

WSSERVICE RHAnotations DESCRIPTION STR0001 //"Tabela de Espelho de Ponto"
	WSDATA Branch				AS String
	WSDATA Registration			AS String
	WSDATA CurrentPage			As Integer	OPTIONAL
	WSDATA FilterField  		As String	OPTIONAL
	WSDATA FilterValue			As String	OPTIONAL
	
	WSDATA AnotationsBrowse		As TAnotationsBrowse
	
	WSMETHOD GetAnotations			DESCRIPTION STR0002 //"M�todo de consulta da tabela de espelho de ponto do funcionario."
	WSMETHOD GetAnotationsFields	DESCRIPTION STR0003 //"M�todo de consulta dos dados pessoais do funcion�rio." 
	WSMETHOD GetPeriods             DESCRIPTION STR0004 //"M�todo que capta os per�odos cadastrados no SIGAPON"
ENDWSSERVICE 

WSMETHOD GetAnotations;
WSRECEIVE Branch, Registration, CurrentPage, FilterField, FilterValue;
WSSEND AnotationsBrowse;
WSSERVICE RHAnotations
	Local lRet			:= .T.
	Local lTerminal		:= .T.
	Local lPortal		:= .T.	
	Local lReturn		:= .F. // .T. Retorno Logico Quando Validacao e .F. retorna os periodos
	Local cFilTerminal	:= Self:Branch
	Local cMatTerminal	:= Self:Registration
	Local cPerAponta
	Local aRetPortal	:= {}
	Local nTam, nTam1, nX, nY	  
	Local nAbHora		:= 0	
	Local nNumPerAnt	:= 1	// Numero de Periodos a Serem Listados ou somente a qtde desde admissao	
	Local cOcorr
	Local cAbHora
	Local cPeriodo	                                                    
	Local bCloseFiles	:= {|cFiles| If( Select(cFiles) > 0, (cFiles)->( DbCloseArea()), NIL) }
	Local aFilesOpen 	:={"SP5", "SP8","SPB","RFF","SPC", "RFE"}
	Local cPathWeb 		:= GetPathWeb()
	Local cArqLocal 	:= GetSrvProfString ("STARTPATH", "")
	Local cNameFile		:= ""
	Local lPort671 		:= SuperGetMV("MV_PORT671",, .F.) // Portaria 671
	
	If Self:FilterValue == Nil		
   		aPeriods	:= GetPerAponta( nNumPerAnt , cFilTerminal , cMatTerminal, lReturn) 
   		cPerAponta	:= DtoS(aPeriods[1,1])+DtoS(aPeriods[1,2])
		cPeriodo	:= DtoC(aPeriods[1,1])+' - '+DtoC(aPeriods[1,2])	
    Else
		cPerAponta	:= Self:FilterValue
		cPeriodo	:= DtoC(SToD(Left(Self:FilterValue, 8))) +" - "+ DtoC(SToD(Right(Self:FilterValue, 8)))
    EndIf
	
	Self:AnotationsBrowse:PDFURL := ""
	Self:AnotationsBrowse:PDFName := ""
	
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	If SRA->(dbSeek(cFilTerminal+cMatTerminal))
		If lPort671 
			// Chama o ponr010 para exibir as marca��es na tela
			Ponr010( lTerminal, cFilTerminal, cMatTerminal, cPerAponta, lPortal, @aRetPortal )
			
			cNameFile := STR0005 + cMatTerminal
			
			// Caminho do arquivo na pasta web para possibilitar o download
			Self:AnotationsBrowse:PDFURL := Right(cPathWeb, Len(cPathWeb)-1) + "/" + cNameFile + ".pdf"
			Self:AnotationsBrowse:PDFURL := SubStr(Self:AnotationsBrowse:PDFURL, At("/", Self:AnotationsBrowse:PDFURL))
			Self:AnotationsBrowse:PDFName := cNameFile + ".pdf"
			
			// Chama o ponr010 para gerar o arquivo pdf
			PONR010( lTerminal, cFilTerminal, cMatTerminal, cPerAponta, , {}, .T., cNameFile, {})
			
			// Copia o PDF da system para a pasta web
			__COPYFILE(cArqLocal + cNameFile + ".pdf", cPathWeb + "/" + cNameFile + ".pdf")
			
		Else
			Ponr010( lTerminal, cFilTerminal, cMatTerminal, cPerAponta, lPortal, @aRetPortal )
		EndIf
	EndIf
	
	nTam	:= Len(aRetPortal)
	
	Self:AnotationsBrowse:Itens := {}
	For nX := 1 To nTam
		//-- Trata Abonos e Excecoes
		If ValType(aRetPortal[nX,3]) == "A"
			nAbHora:=  At( ":" , aRetPortal[nX,3,2] )
		Else
			nAbHora:=  At( ":" , aRetPortal[nX,3] )
		EndIf
		cOcorr	:= ""
		cAbHora	:= "" 
		
		If nAbHora > 0 
			cOcorr :=	Capital( If (ValType(aRetPortal[nX,3]) == "A",aRetPortal[nX,3,1],SubStr( aRetPortal[nX,3] , 1 , nAbHora - 3 )) ) 
			cAbHora:= 	Capital( If (ValType(aRetPortal[nX,3]) == "A",aRetPortal[nX,3,2],SubStr( aRetPortal[nX,3] , nAbHora - 2 ) ) ) 
		Else                                                                      
			cOcorr :=	Capital( If (ValType(aRetPortal[nX,3]) == "A",aRetPortal[nX,3,1],AllTrim( aRetPortal[nX,3] ) ))
			cAbHora:= 	'&nbsp;'	
		EndIf 				
		
		AAdd(Self:AnotationsBrowse:Itens, WSClassNew("TAnotationsList"))		
		Self:AnotationsBrowse:Itens[nX]:Branch				:= cFilTerminal
		Self:AnotationsBrowse:Itens[nX]:Registration        := cMatTerminal
		Self:AnotationsBrowse:Itens[nX]:DateEvent			:= DtoC(aRetPortal[nX, 1])
		Self:AnotationsBrowse:Itens[nX]:DayWeek				:= DiaSemana(aRetPortal[nX,1],8)		
		Self:AnotationsBrowse:Itens[nX]:Observations		:= aRetPortal[nX, 2] 
		Self:AnotationsBrowse:Itens[nX]:Marks				:= {}
		Self:AnotationsBrowse:Itens[nX]:BonusReason        := cOcorr
		Self:AnotationsBrowse:Itens[nX]:HoursMarkType      := cAbHora
		
		nTam1	:=  Len(aRetPortal[nX])
		
		//Inseri o total de marcacoes que houver
		For nY := 4 To nTam1			
			AAdd(Self:AnotationsBrowse:Itens[nX]:Marks, WSClassNew("TMarksList"))		
			Self:AnotationsBrowse:Itens[nX]:Marks[nY-3]:MarksItens := aRetPortal[nX, nY]
		Next nY			
	Next nX
	Self:AnotationsBrowse:PeriodView	:= cPeriodo
	Self:AnotationsBrowse:PeriodFielter	:= cPerAponta
	
	Aeval(aFilesOpen, bCloseFiles) 
Return lRet


WSMETHOD GetAnotationsFields;
WSRECEIVE Branch, Registration;
WSSEND AnotationsBrowse;
WSSERVICE RHAnotations	
	Local lRet			:= .T.
	Local cFilTerminal	:= Self:Branch
	Local cMatTerminal	:= Self:Registration
	
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	SRA->(dbSeek(cFilTerminal+cMatTerminal))
	
	//Imprime os dados do Funcionario
	oFields	:= WSClassNew("TAnotationsFields")
	
	oFields:Name				:= SRA->RA_NOME
	oFields:Department			:= SRA->RA_DEPTO +" - "+ fDesc('SQB',SRA->RA_DEPTO,'QB_DESCRIC')
	oFields:CostCenter			:= SRA->RA_CC    +" - "+ fDesc("CTT",SRA->RA_CC,"CTT_DESC01",,SRA->RA_FILIAL)
	oFields:Branch				:= cFilTerminal
	oFields:Registration		:= cMatTerminal
		
    AAdd(Self:AnotationsBrowse:Fields, oFields)
Return lRet

WSMETHOD GetPeriods;
WSRECEIVE Branch, Registration;
WSSEND AnotationsBrowse;
WSSERVICE RHAnotations	
	Local lRet			:= .T.
	Local lReturn		:= .F. // .T. Retorno Logico Quando Validacao e .F. retorna os periodos
	Local nX			:= 0
	Local nI			:= 0
	Local nTam			:= 0        �
	Local nIni			:= 1
	Local nNumPerAnt	:= 12	// Numero de Periodos a Serem Listados ou somente a qtde desde admissao	
	Local cFilTerminal	:= Self:Branch
	Local cMatTerminal	:= Self:Registration
	Local aPeriods		:= {}
	Local bCloseFiles:= {|cFiles| If( Select(cFiles) > 0, (cFiles)->( DbCloseArea() ), NIL) }
	Local aFilesOpen :={"SP5", "SP8","SPB","RFF","SPC", "RFE"}
	
	aPeriods	:= GetPerAponta( GetMv("MV_TCFMARC",,nNumPerAnt) , cFilTerminal , cMatTerminal, lReturn, NIL, NIL, RetPerSPO( cFilTerminal ) )
	nTam		:= Len(aPeriods)
		
	For nI := nTam To nIni Step -1
		nX += 1
		AAdd(Self:AnotationsBrowse:Periods, WSClassNew("TPeriodsList"))		
		Self:AnotationsBrowse:Periods[nX]:Fielter			:= DtoS(aPeriods[nI,1])+DtoS(aPeriods[nI,2])
		Self:AnotationsBrowse:Periods[nX]:ValueFielter		:= DtoC(aPeriods[nI,1])+' - '+DtoC(aPeriods[nI,2])	
	Next nI	
	
	Aeval(aFilesOpen, bCloseFiles) 
Return lRet

/*/{Protheus.doc} GetPathWeb
Retorna o diret�rio do servidor Web do portal para a gera��o dos espelhos de ponto com base nas informa��es do appserver.ini
@type  Static Function
@author C�cero Alves
@since 08/02/2023
@return cPathWeb, Caractere, diret�rio do servidor web 
@example
	GetPathWeb() => "/web/pp/espelhos"
/*/
Static Function GetPathWeb()
	
	Local cPathWeb 		:= ""
	Local aIniSessions 	:= GetIniSessions(GetADV97())
	Local nI			:= 0
	Local nPosJobPP 	:= 0
	
	If (nPosJobPP := aScan(aIniSessions, {|x| Upper(AllTrim(GetPvProfString( x, "SIGAWEB", '', GetADV97()))) == "PP"})) > 0
		
		cNameJob := Upper(AllTrim(aIniSessions[nPosJobPP]))
		
		For nI := 1 To Len(aIniSessions)
			If Upper(AllTrim(GetPvProfString( aIniSessions[nI], "RESPONSEJOB", '', GetADV97()))) == cNameJob
				cPathWeb := GetPvProfString( aIniSessions[nI], "PATH", '', GetADV97())
				EXIT
			EndIf
		Next nI
	EndIf
	
	cPathWeb := StrTran( cPathWeb, AllTrim(GetSrvProfString ("RootPath", "")), "" )
	cPathWeb := StrTran( cPathWeb, "\", "/" )
	
	cPathWeb :=If(Left(cPathWeb, 1) != "/", "/" + cPathWeb, cPathWeb)
	cPathWeb :=If(Right(cPathWeb, 1) != "/", cPathWeb + "/", cPathWeb)
	
	cPathWeb += "espelhos"
	
	MakeDir(cPathWeb) // Garante que o diret�rio existe
	
Return cPathWeb
