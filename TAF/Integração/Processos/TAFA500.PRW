#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMILEDEF.CH" 
#INCLUDE "TAFA500.CH"      
#INCLUDE "TOPCONN.CH"   
#INCLUDE "FILEIO.CH"

STATIC aLayout :=	{ "TAFA050", "TAFA029", "TAFA079", "TAFA180", "TAFA051",;    
					  "TAFA053", "TAFA077", "TAFA060", "TAFA061", "TAFA065",;
					  "TAFA071", "TAFA076", "TAFA083", "TAFA087", "TAFA026",;
					  "TAFA031", "TAFA052", "TAFA055",;
					  "TAFA056", "TAFA059", "TAFA072", "TAFA073", "TAFA092",;
					  "TAFA098", "TAFA187", "TAFA070", "TAFA057",;
					  "TAFA058", "TAFA027", "TAFA188", "TAFA068", "TAFA069",;
					  "TAFA084", "TAFA091", "TAFA074", "TAFA078", "TAFA089",;
					  "TAFA097", "TAFA063", "TAFA064", "TAFA075", "TAFA081",;
					  "TAFA085", "TAFA093", "TAFA094", "TAFA095", "TAFA067",;
					  "TAFA088", "TAFA096", "TAFA082", "TAFA086", "TAFA109",;
					  "TAFA062", "TAFA066", "TAFA307", "TAFA200", "TAFA201",;
					  "TAFA202", "TAFA203", "TAFA204", "TAFA205", "TAFA206",;
					  "TAFA207", "TAFA208",;
					  "TAFA372", "TAFA371", "TAFA331", "TAFA311", "TAFA361",; //ECF
					  "TAFA330", "TAFA322", "TAFA319", "TAFA321", "TAFA323",; //ECF
					  "TAFA324", "TAFA325", "TAFA332", "TAFA334", "TAFA335",; //ECF
					  "TAFA336", "TAFA337", "TAFA338", "TAFA339", "TAFA340",; //ECF
					  "TAFA329", "TAFA341", "TAFA342", "TAFA343", "TAFA350",; //ECF
					  "TAFA344", "TAFA345", "TAFA346", "TAFA349", "TAFA351",; //ECF
					  "TAFA352", "TAFA353", "TAFA354", "TAFA355", "TAFA373",; //ECF
					  "TAFA356", "TAFA357", "TAFA358", "TAFA359", "TAFA360",; //ECF
					  "TAFA367" }  //ECF 

//------------------------------------------------------------------------- 
/*/{Protheus.doc}  TAFA500 

Rotina para processamento de importacao de arquivos TXT baseados em
layout pre configurado

@Param   
aParam - [1] = Empresa, [2] = Filial quando a chamada da funcao for via Schedule, [3] =  Nome do arquivo a ser gerado

@return lOk - Flag de sucesso de processamento, .T. = Sucesso, .F. = Falha

@author Rodrigo Aguilar
@since 12/09/2012
@version P11   
      
/*/                                                         
//------------------------------------------------------------------------
/*
Function TAFA500( aParam )

	Local oDlg 	  := Nil 
    Local oFolder := Nil 
	Local aCoors  := FWGetDialogSize( oMainWnd )
    Local aFolder := {}


	Define MsDialog oDlg From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel Title 'TESTE' 
		
	TButton():New(50,50, "botao 1",oDlg, {||retetete()}, 30, 12,,, .F., .T., .F.,, .F.,,, .F. )
	
	 Activate MsDialog oDlg Centered On Init Enchoicebar (oDlg,{||.T.,oDlg:End()},{||.T.,oDlg:End()},,,,,.F.,.F.,.F.,.T.,.F.,'PROFILE')

Return Nil

Function  retetete

	lOCAL CVAL := ""


	CVAL :=	cGetFile("Arquivo xml|*.xml", OemToAnsi( "Procurar" ), 0,"C:\", .F.,nOR(GETF_LOCALHARD, GETF_MULTISELECT), .T.,.T. ) 


return CVAL 
*/

Function TAFA500( aParam, cFilOri ) 

	Local cNomWiz		:= "A500"
	Local cDirRead		:= ""
	Local cMVDImpTAF	:= AllTrim( GetNewPar( "MV_DIMPTAF", "" ) )
	Local cOwner		:= ""
	Local cFilTran		:= ""
	Local cFilsproc		:= ""
	Local nTipImport	:= 0
	Local aWizard		:= {}
	Local aArq			:= {}
	Local aFilArqInt	:= {}
	Local aFilInt		:= {}
	Local lOk			:= .T.
	Local lJob			:= Iif( IsBlind(), .T., .F. )
	Local lMlToST2		:= .T.
	Local lProcess		:= .F.
	Local lMsgPlural	:= .F.
	Local cDrive		:= ""
	Local cPath			:= ""
	Local aPaths		:= {}
	Local cNewFile		:= ""
	Local cExt			:= ""
	Local cBkpFilAnt	:= ""
	Local cBkpEmpLog	:= ""
	Local nFil			:= 0
	Local cTicketXML	:= ""
	Local cDirImp	    := ""
	Local cBarra        := ""
	Local lSrvLinux		:= IsSrvUnix()
	Local nX 			:= 0
	Local nStart   		:= Seconds()
	Local nStartFl 		:= 0
	Local aMultiFiles	:= {}
	Private _lIniMt 	:= .F.
	Private _lNoCloseTH	:= .T.

	Default aParam		:= {}
	Default cFilOri    	:= ""

	TAFConOut( "Inicio Importa��o TAFA500 " ) 


	If Empty( cMVDImpTAF ) .and. lJob
		TAFConOut( STR0013 ) //"Para processar via Job, deve-se informar o diret�rio de leitura dos arquivos de importa��o no par�metro MV_DIMPTAF."
	EndIf

	//Se n�o for Job, monta o aWizard
	If ( lJob .and. !Empty( cMVDImpTAF ) ) .or. A500Wizard( cNomWiz )

		cBarra := IIF(lSrvLinux,"/","\")

		//Se n�o for Job, confirmo o processamento com o usu�rio
		If lJob .or. ApMsgYesNo( "Confirma o processamento dos arquivos?" ) //"Confirma o processamento do Layout TAF ?"

			//Se n�o for Job, carrego as informa��es da Wizard
			If lJob .or. xFunLoadProf( cNomWiz, @aWizard )

				cTime := DToS( Date() ) + "-" + Time()

				If !lJob
					nTipImport := Val( SubStr( aWizard[1,2], 1, 1 ) )
					lMlToST2 := Iif( nTipImport > 1, .T., .F. )

					If nTipImport == 1
						MsgInfo( STR0038 + " MILE obsoleto para o processamento."  ) //"Modo de Integra��o"
					EndIf
				Else
					nTipImport := MV_PAR01
					
					lMlToST2 := Iif( nTipImport > 1, .T., .F. )
					TAFConOut( STR0038 + Iif( MV_PAR01 == 1, "MILE", Iif( MV_PAR01 == 2, "Layout Totvs", "e-Social" ) ) ) //"Modo de Integra��o"

				EndIf

				//Tratamento para Linux onde a barra � invertida
				If GetRemoteType() == 2 //REMOTE_LINUX
					If ( SubStr( cMVDImpTAF, Len( cMVDImpTAF ), 1 ) <> "/" )
						cMVDImpTAF += "/"
					EndIf
				Else
					If ( SubStr( cMVDImpTAF, Len( cMVDImpTAF ), 1 ) <> "\" )
						cMVDImpTAF += "\"
					EndIf
				EndIf
				
				//Caso seja Job, busco o caminho de leitura do par�metro,
				//caso contr�rio, informa��o vem da Wizard
				If lJob
					//Leitura do caminho de onde ser�o lidos os arquivos de importa��o
					cDirRead := cMVDImpTAF

					If nTipImport == 3
						aArq := Directory( cDirRead + "*.xml" )
					Else
						If Len( aParam ) == 3
							aArq := Directory( cDirRead + aParam[3] )
						Else
							aArq := Directory( cDirRead + "*.TXT" )
						EndIf
					EndIf
						If !Empty (cFilOri )
						cFiltran := cFilOri
						EndIf
				Else

					cDirRead := aWizard[1,1]
					cOwner   := aWizard[1,3]				
					cFiltran := aWizard[1,4]
					
					//Para rotina visual o caminho informado na wizard j� � o
					//pr�prio arquivo a ser importado
					If GetRemoteType() <> REMOTE_HTML
						aAdd( aArq, { cDirRead } )
					EndIf 

				EndIf

				aPaths := {}
				lSuccess := .F. 
				cMsgErr := "" 

				If GetRemoteType() == REMOTE_HTML

					aMultiFiles := StrTokArr( cDirRead, "|")
					If Len(aMultiFiles) > 0

						For nX := 1 To Len(aMultiFiles)

							cDirRead := AllTrim(aMultiFiles[nX])

							//Quando h� multi sele��o de arquivos o drive s� � informado no primeiro arquivo
							//por conta de estar dentro de um la�o na segunda passagem a vari�vel cDrive sempre 
							//estar� preenchida, com isso posso adicionar o drive para os demais arquivos
							//mantendo a compatibilidade da fun��o SplitPath. O trecho abaixo � um c�digo defensivo.
							If !Empty(cDrive)
								cDirRead := cDrive + StrTran(cDirRead," ","")
							ElseIf nX > 1
								//Quando a sele��o � feita no servidor a partir da segunda op��o � retornado a 
								//palavra "servidor" na primeira posi��o do caminho do arquivo, quando isso acontece 
								//o arquivo n�o � encontrado. O trecho abaixo � um c�digo defensivo.
								If Substr(cDirRead,1,At("\",cDirRead)-1) == "servidor"
									cDirRead := Substr(cDirRead,At("\",cDirRead)+1)
								Else
									cDirRead := StrTran(cDirRead," ","")
								EndIf 
							EndIf 

							If File( cDirRead )
							
								SplitPath(	cDirRead,;	//cArquivo
											@cDrive,;	//cDrive
											@cPath,;	//cDiretorio
											@cNewFile,;	//cNome
											@cExt )		//cExtensao

								cDirTemp := cBarra + "tempTaf"

								// for�o a copia dos arquivos para a pasta destino.
								cDirImp := cDirTemp
								MakeDir(cDirImp)
								cDirImp := cDirImp + cBarra + cNewFile + cExt

								If !File( cDirImp )
									__CopyFile(cDirRead,cDirImp)
									//Se o arquivo esta no servidor excluo o mesmo do diretorio original pq foi realizado a transferencia
									//para o diret�rio tempor�rio (cDirTemp) criado para execucoes no webapp		
									If Empty(cDrive)
										If FErase( cDirRead ) < 0
											TafConOut("Falha para apagar o arquivo integrado. C�digo do erro: " + AllTrim( Str( FError() ) ) )
										EndIf
									EndIf 
								Endif

								//Para rotina visual o caminho informado na wizard j� � o
								//pr�prio arquivo a ser importado
								aAdd( aArq, { cDirImp } )

							EndIf 
						Next nX
					EndIf 

					If Len(aArq) == 0
						MsgAlert("Arquivo n�o encontrado!")
						Return
					EndIf 
				EndIf

				If lMlToST2 .And. Empty(cMsgErr)
					If !lJob
						If nTipImport == 2

							If GetRemoteType() == REMOTE_HTML
								cDirRead := cDirTemp
							EndIf 
							
							cBkpFilAnt 	:= cFilAnt
							cBkpEmpLog	:= FWCodEmp()

							FWMsgRun( , { || lProcess := FMileToST2( cDirRead, aArq, lJob, @aFilInt, @aFilArqInt, cBkpEmpLog, cBkpFilAnt ) },, STR0036 ) //"Executando Importa��o dos arquivos..."

							If lProcess
								If GetRemoteType() <> REMOTE_HTML
									if len(aFilArqInt) > 1
										lMsgPlural := .T.
									endif
									
									if	lOk .And. Len(aFilArqInt) > 0

										cFilsproc := StrTran(ArrTokStr(aFilArqInt),'|', ' -  ')
										
									endif

									nTamFilArq := len( aFilArqInt )

									for nFil := 1 to nTamFilArq
										TAFConOut("------------->Filial:" + aFilArqInt[nFil] )
										nStartFl := Seconds()

										if lOk
											If nFil == nTamFilArq
												_lNoCloseTH := .F.
											Endif

											cFilAnt := aFilArqInt[nFil]

											TAFAInteg( {}, 2,, @lOk,,,'1' )
										endif
										TAFConOut( "#Duracao Execucao filial: " + aFilArqInt[nFil] + " #Tempo: " + cValTochar( Seconds() - nStartFl ) )
									next nFil
									TAFConOut( "#Duracao Operacao: " + cValTochar( Seconds() - nStart ) )

									if 	!empty(cBkpFilAnt) .And. (cBkpFilAnt <> cFilAnt)
										cFilAnt := cBkpFilAnt
									endif
								Else
									TAFAInteg( {}, 2,, @lOk )
								EndIf
							Else
								lOk := .F.
							EndIf
						ElseIf nTipImport == 3
							If GetRemoteType() == REMOTE_HTML
								cDirRead := cDirImp
								cDrive   := ""
								cPath    := ""
								cNewFile := ""
								cExt     := ""
							EndIf

							SplitPath(	cDirRead,;	//cArquivo
										@cDrive,;	//cDrive
										@cPath,;	//cDiretorio
										@cNewFile,;	//cNome
										@cExt )		//cExtensao

							TAFAInteg( {}, 6, cDrive + cPath, @lOk,,, "3",, cOwner, cFiltran,@cTicketXML )
							Iif( lOk, TAFAInteg( {}, 2,, @lOk,,, "3",,,,cTicketXML ), .F. )
							
						EndIf

						If lOk .and. Aviso( "Valida��o de dados", "Desejar realizar o processo de valida��o ?", { "Sim", "N�o" }, 2 ) == 1
							TAFAInteg( {}, 3,/*3*/,/*4*/,/*5*/,/*6*/,/*7*/,/*8*/,/*9*/,/*10*/,cTicketXML, aFilArqInt )
						EndIf

						If FindFunction("ProtData")
							If ProtData(.F.)
								If lOk .and. Aviso( "Monitor de Integra��o", "Integra��o finalizada, deseja visualizar o Monitor de Integra��o ?", { "Sim", "N�o" }, 2 ) == 1
									TAFTicket( .T. )
								EndIf
							Else	
								MsgAlert(STR0069, STR0068)
							EndIf
						Else
							If lOk .and. Aviso( "Monitor de Integra��o", "Integra��o finalizada, deseja visualizar o Monitor de Integra��o ?", { "Sim", "N�o" }, 2 ) == 1
								TAFTicket( .T. )
							EndIf
						EndIf

					Else
						If nTipImport == 3
							TAFConOut( "Executando Integra��o TAFA500 via Schedule" ) 
							//Incluido tratamento para quando executado via Schedule.
							
							cDirRead := cMVDImpTAF
							cDrive   := ""
							cPath    := ""
							cNewFile := ""
							cExt     := ""

							SplitPath(	cDirRead,;	//cArquivo
										@cDrive,;	//cDrive
										@cPath,;	//cDiretorio
										@cNewFile,;	//cNome
										@cExt )		//cExtensao

							TAFAInteg( {}, 6, cDrive + cPath, @lOk,,, "3",, cOwner, cFiltran,@cTicketXML,,,,lJob )
							Iif( lOk, TAFDinamicJOB(2, FWGrpCompany()), .F. )

							If lOk
								TAFConOut( "Integrado arquivo com sucesso !" )
							EndIf
						ElseIf nTipImport == 2
							FMileToST2( cDirRead, aArq, lJob, aParam )
						EndIf
					EndIf
				ElseIf !Empty(cMsgErr)
					ApMsgStop(cMsgErr)
				EndIf

				cTime += CRLF + DToS( Date() ) + "-" + Time()
				TAFConOut( cTime )
			Else
				ApMsgStop( STR0009 ) //"Problema encontrado ao carregar o Profile! Tente novamente!"
			EndIf
		Else
			MsgInfo( STR0010 ) //"Processamento cancelado." 
		EndIf
	EndIf
	Asize(aWizard,0)
	aWizard := nil
	Asize(aPaths,0)
	aPaths := nil
	Asize(aMultiFiles,0)
	aMultiFiles := nil


Return( lOk )

//-------------------------------------------------------------------     
/*/{Protheus.doc} A500Wizard   

Funcao responsavel pela montagem do Wizard da rotina

@param 
cNomWiz - Nome do Wizard utilizado no processamento dos layouts

@return 
lRet - Flag de sucesso de processamento, .T. = Wizard concluido com sucesso, .F. = Assistente cancelado

@author Rodrigo Aguilar
@since 12/09/2012
@version P11  
   
/*/
//------------------------------------------------------------------- 
Static Function A500Wizard ( cNomWiz ) 
                              
	Local	cTitObj1		:=	""
	Local	aTxtApre		:=	{}
	Local	aPaineis		:=	{}
	Local  aItens			:= {}
	Local	lRet			:=	.T.

	aAdd ( aTxtApre , STR0001 ) //"Rotina de Importa��o do Layout TAF - Totvs Automa��o Fiscal"
	aAdd ( aTxtApre , "" )	
	aAdd ( aTxtApre , STR0002 ) //"Preencha corretamente as informa��es solicitadas."
	aAdd ( aTxtApre , STR0003 ) //"Informa��es necess�rias para a importa��o do arquivo texto."

	//����������������Ŀ
	//�Montando Wizard �
	//������������������	
	aAdd ( aPaineis , {} )
	nPos	:=	Len ( aPaineis )
	aAdd ( aPaineis[nPos] , STR0004 ) //"Preencha corretamente as informa��es solicitadas."
	aAdd ( aPaineis[nPos] , STR0005 ) //"Par�metros da importa��o"
	aAdd ( aPaineis[nPos] , {} )
	
	aAdd (aPaineis[nPos][3], {0,,,,,,,});							aAdd (aPaineis[nPos][3], {0,,,,,,,})
	aAdd (aPaineis[nPos][3], {0,,,,,,,}); 							aAdd (aPaineis[nPos][3], {0,,,,,,,})

	cTitObj1	:=	STR0026 //"Selecione o Arquivo para importa��o:"				
	aItens := {"2-Importa TXT - Layout TOTVS","3-Importa XML - Layout eSocial"}

	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,});		aAdd (aPaineis[nPos][3], {2,,,1,,,,,,.T.}) 
	aAdd (aPaineis[nPos][3], {0,,,,,,,});				aAdd (aPaineis[nPos][3], {0,,,,,,,})
	aAdd (aPaineis[nPos][3], {1,STR0029,,,,,,});		aAdd( aPaineis[nPos][3], {3,,,,,aItens,,,,,,,{"xFunVldWiz","TAFA500-DIR"}} )  //"M�todo de Importa��o ?"
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});				aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {1,STR0062,,,,,,});		aAdd (aPaineis[nPos][3], {2,,,1,,,,50});  //"ERP Propriet�rio"

	aAdd (aPaineis[nPos][3], {0,,,,,,,});							aAdd (aPaineis[nPos][3], {0,,,,,,,})
	aAdd (aPaineis[nPos][3], {1,STR0063,,,,,,});		aAdd (aPaineis[nPos][3], {2,,,1,,,,50})  //"Filial Origem da Transferencia"

	aAdd (aPaineis[nPos][3], {0,,,,,,,});							aAdd (aPaineis[nPos][3], {0,,,,,,,})
	aAdd (aPaineis[nPos][3], {1,"NOVO! Importa��o Multi-Filiais",,,,,,});		aAdd (aPaineis[nPos][3], {7,"Documenta��o",,,,,,,,,,,,,,,'ShellExecute("open","http://tdn.totvs.com/x/J9ruDQ","","",1)'})

	lRet	:=	XFUNWizard ( aTxtApre , aPaineis , cNomWiz )

Return ( lRet )

//----------------------------------------------------------------------
/*/{Protheus.doc} FMileToST2
Envia as informa��es do arquivo texto para a tabela TAFST2

@author Evandro dos Santos Oliveira
@since 21/04/2015
@version 1.0	

@param cDirRead	- Path do Arquivo
@param aArq 	  	- Array com nome dos arquivos
@param lJob 	  	- Verifica se � Job

@return Nil
/*/
//------------------------------------------------------------------------
Static Function FMileToST2(cDirRead,aArq,lJob,aFilInt, aFilArqInt, cBkpEmpLog, cBkpFilAnt)

	Local cArqTxt			:= ""
	Local cBuffer			:= ""
	Local cEmpTaf			:= ""
	Local aLinha			:= {}
	Local cChannel			:= ""
	Local cMsg				:= ""
	Local aTopInfo			:= {}
	Local aTabConf 			:= {}
	Local nHdlTaf			:= 0 
	Local aErros			:= {}
	Local lConn				:= .F.
	Local cQuebra			:= ""
	Local cChanT999			:= ""
	Local nX				:= 0
	Local nSeqChv			:= 0
	Local aRotinas			:= {} 
	Local aPath				:= {}
	Local cST2TAB			:= "TAFST2"
	Local cTCBuild  		:= "TCGetBuild" 	// Nome da funcao para verificao da Build 
	Local cBarra			:= ""
	Local cKey				:= "" 
	Local cDirProc			:= ""
	Local cDirFinz			:= ""
	Local cArqFinz			:= ""
	Local cAuxExt			:= ""
	Local cAuxFile			:= ""	
	Local cTicket			:=	TAFGTicket()
	Local dDtTicket			:=	Date()
	Local cHrTicket			:=	Time()
	Local lProcess			:=	.F.
	Local nCopyFile			:=	0
	Local nSmartSO      	:= 0
	Local nTAFSEQ       	:= 1
	Local nQtdChild   		:= 0
	Local cTickAnt			:= ""
	Local cKeyAnt			:= ""
	Local cUserInt			:= AllTrim(FWSFUser( __cUserId, "DATAUSER", "USR_CODIGO" )) //usu?rio que integrou

	Default lJob 			:= .F.
	Default aFilArqInt		:= {}
	Default	cBkpEmpLog		:= ""
	Default cBkpFilAnt		:= ""
         
	If FindFunction(cTCBuild)
		cTopBuild := &cTCBuild.()
	EndIf
	cBancoDB := Upper(AllTrim(TcGetDB()))	
	cST2Alias	:= GetNextAlias()          

	aAdd(aRotinas,TAFRtFis())
	aAdd(aRotinas,TAFRtECF())
	aTabConf 		:= xTAFGetStru("TAFST2")
	aTopInfo		:= FWGetTopInfo()

	For nX := 1 To Len(aArq)
		
		TAFConOut("Importando ... " +  AllTrim(Str(nX)))
		
		nSmartSO := GetRemoteType()
		If nSmartSO == 2 	//LINUX
			aPath		:= TafStr2Arr(aArq[ nX, 1 ],"/")
			cBarra 	:= "/"
		
		ElseIf nSmartSO == -1 //JOB
			If IsSrvUnix()
				aPath		:= TafStr2Arr(aArq[ nX, 1 ],"/")
				cBarra 	:= "/"
			Else
				aPath	 	:= TafStr2Arr(aArq[ nX, 1 ],"\")
				cBarra  	:= "\"
			EndIf
		
		Else			//WINDOWS
			aPath	 	:= TafStr2Arr(aArq[ nX, 1 ],"\")
			cBarra  	:= "\"
		EndIf
		
		//conforme orienta��o do frame n�o � preciso tratar as barras. Quando tratadas, ocorre erro no FwMakeDir
		cDirProc	:= "\out\inproc"
		cDirFinz	:= "\out\imported"
		
		If !lJob
			cArqTxt := aArq[ nX, 1 ]
		ELse
			cArqTxt := cDirRead + aArq[ nX, 1 ]
		EndIf

		If File(cArqTxt)
			/*+-----------------------------------------------------+
			  | Copia o arquivo para pasta de processamento, antes  |
			  | verifico se o arquivo n�o est� em uso.		    	|
			  +-----------------------------------------------------+*/ 
			If FVerExcl(cArqTxt)
				If FwMakeDir(cDirProc)
				
					//"Rotina de Importa��o do Layout TAF - Totvs Automa��o Fiscal"
					//"Para evitar duplicidade de importa��es, o arquivo " + cArqTxt
					//" est� sendo enviado para um diret�rio interno do sistema."
					//"Para mais informa��es sobre a rotina manual de importa��o acesse: http://tdn.totvs.com/display/TAF/03.+Processamento+manual"
					
					If !lJob
						nCopyFile := Aviso( STR0001 , STR0059 + cArqTxt + STR0060 + CRLF + CRLF + STR0061 , {"Continua","Cancela"} , , CRLF + CRLF + STR0057 + aTail( aPath ) )
					Else
						nCopyFile := 1
					EndIf
					
					If nCopyFile == 1 .And. (__CopyFile( cArqTxt , cDirProc +"\" + aTail(aPath))) 
						
						If FERASE(cArqTxt) <> -1

							FT_FUSE(cDirProc + "\" + aTail(aPath))
							FT_FGOTOP()

								//Abre a Tabela TAFST2
								If !lConn
									lConn := xTAFCriaTB(,aTopInfo,cST2TAB,cST2Alias,__CRDD,aTabConf[1],aTabConf[2],cTopBuild,cBancoDB,.F.,lJob,@aErros, @nHdlTaf)        
							 	EndIf
								
							 	If lConn
							 	
							 		If FVldFil(@aFilArqInt, cBkpEmpLog, cBkpFilAnt)

										cTickAnt := cKeyAnt := ""
										
										/* 
											A variavel nSeqChv � iniciado com zero e foi incrementada nesse ponto, porque o TAFA500 pode ser utilizado como Schedule.
											E como schedule, a integra��o � feita considerando os arquivos contidos no diret�rio informado no parametro MV_DIMPTAF.
											Quando tem mais de um arquivo .txt, o TAFKEY ( que � composto pela vari�vel nSeqChv ) do pr�ximo arquivo e do pr�ximo registro T001 ( For nX := 1 To Len(aArq) ) 
											estava sendo utilizado o mesmo TAFKEY do �ltimo registro do arquivo anterior, 
											causando erro de estrutura ao passar pela fun��o TAFVerEstru ( TAFAINTEG.prw ).
											Ent�o, ao trocar de arquivo � necess�rio incrementar a vari�vel nesse ponto para evitar o erro mencionado acima.
										*/
										nSeqChv++

								 		Begin Transaction 
										
										//
										//O trecho dentro do la�o funciona da seguinte forma:
										//  - Armazena e concatena o conte�do que deve ser gravado em uma �nica linha da TAFST2
										//
										//  - Quando o la�o chega em um registro de quebra, ou seja, um registro "pai" do Layout que deve ser
										//  gravado em outra linha da TAFST2, fa�o o RecLock e gravo o conte�do que est� em mem�ria na vari�vel cMsg
										//
										//  - Inicio novamente o processo de concaten��o do conte�do at� a pr�xima linha "pai"
										//
										While ! FT_FEOF()
											
											//Armazeno o conte�do da linha que est� sendo lida do TXT
											cBuffer := FT_FREADLN()
											IF(Len(cBuffer) >= 1023)
												FT_FSKIP()
												cBuffer += FT_FREADLN()
											EndIf

											//Fa�o parser do conte�do da linha em um array
											aLinha := TafStr2Arr(cBuffer,"|")
											
											//Trecho comentado, para que n�o afete a grava��o da linha
											//cChannel := aLinha[2]
											
											//Identifico o registo de quebra, ou seja, pai na hierarquia
											cQuebra := FRetCanal(cBuffer, @cChanT999)
											
											//Inserido o cKey no Topo para tratamento da multi-filiais											
											cKey := DToS( dDataBase )+ StrTran(Time(), ":", "" ) +  StrTran( XFUNCh2ID( cEmpTaf , "C1E", 7 ) , " ", "" ) + "_" + StrZero(nSeqChv,10) //C1ET107	C1E_FILIAL, C1E_CODFIL, C1E_ATIVO

											If Len( aLinha ) > 1  // Preven��o de erro de linha vazia
												If AllTrim(aLinha[2])  == "T001"
													If !Empty(AllTrim(cMsg))
														if empty(cTickAnt)
															cTickAnt := cTicket
														endif
														if empty(cKeyAnt)
															cKeyAnt := cKey
														endif
														If RecLock(cST2Alias,.T.)
															(cST2Alias)->TAFFIL	 	:= cEmpTaf  
															(cST2Alias)->TAFCODMSG 	:= "1"
															(cST2Alias)->TAFSEQ 	:= STRZERO(nTAFSEQ,3)
															(cST2Alias)->TAFTPREG 	:= cChannel
															(cST2Alias)->TAFKEY 	:= cKeyAnt
															(cST2Alias)->TAFMSG 	:= cMsg
															(cST2Alias)->TAFSTATUS 	:= "1"
															(cST2Alias)->TAFTICKET	:= cTickAnt
															(cST2Alias)->TAFDATA	:= dDtTicket
															(cST2Alias)->TAFHORA	:= cHrTicket

															If (cST2Alias)->( FieldPos( 'TAFUSER') ) > 0
																(cST2Alias)->TAFUSER := cUserInt
															EndIf

															(cST2Alias)->(dbCommit(),MsUnLock())
														EndIf
														nQtdChild := 0
														nTAFSEQ := 1
														cTickAnt := cKeyAnt := cMsg := ""
													EndIf
													cTicket := TAFGTicket()
													cEmpTaf := aLinha[3]
													aadd(aFilInt,cEmpTaf)											
													cKey := DToS( dDataBase )+ StrTran(Time(), ":", "" ) +  StrTran( XFUNCh2ID( cEmpTaf , "C1E", 7 ) , " ", "" ) + "_" + StrZero(nSeqChv,10)
													cKeyAnt := cKey										
												ElseIf Empty(cEmpTaf)
													If !lJob		 	
														ApMsgStop(STR0045) //"N�o encontrado layout T001 no inicio do arquivo"
													EndIf
													Exit
												EndIF	

												//Procurando Registro Pai
												If (aScan(aRotinas[1], {|x| AllTrim(x[5]) == cQuebra } ) > 0) .Or. (aScan(aRotinas[2], {|x| AllTrim(x[5]) == cQuebra } ) > 0)
													If (!Empty(AllTrim(cMsg)))
														//Gravo Informa��es do registro Anterior
														If RecLock(cST2Alias,.T.)														
															(cST2Alias)->TAFFIL 	:= cEmpTaf
															(cST2Alias)->TAFCODMSG 	:= "1"
															(cST2Alias)->TAFSEQ 	:= STRZERO( nTAFSEQ , 3)
															(cST2Alias)->TAFTPREG 	:= cChannel
															(cST2Alias)->TAFKEY 	:= iif( empty(cKeyAnt), cKey, cKeyAnt )
															(cST2Alias)->TAFMSG 	:= cMsg
															(cST2Alias)->TAFSTATUS 	:= "1"
															(cST2Alias)->TAFTICKET	:= iif( empty(cTickAnt), cTicket, cTickAnt )
															(cST2Alias)->TAFDATA	:= dDtTicket
															(cST2Alias)->TAFHORA	:= cHrTicket

															If (cST2Alias)->( FieldPos( 'TAFUSER') ) > 0
																(cST2Alias)->TAFUSER := cUserInt
															EndIf

															(cST2Alias)->(dbCommit(),MsUnLock())
														EndIf
														nSeqChv++
														nQtdChild := 0
														nTAFSEQ := 1
														cTickAnt := cKeyAnt := ""
													EndIf
													cMsg     := cBuffer
													cChannel := if(Empty(cChanT999),cQuebra,cChanT999)
													cKey 	 := DToS( dDataBase )+ StrTran(Time(), ":", "") + StrTran( XFUNCh2ID( cEmpTaf , "C1E", 7 ) , " ", "" ) + "_" + StrZero(nSeqChv,10)
												Else //Controle dos filhos dentro do pai, ou da proxima sequencia com mesmo TafTicket e TafKey do Pai
													nQtdChild++
													If (nQtdChild) > 2500													
														If !Empty(AllTrim(cMsg))
															if empty(cTickAnt)
																cTickAnt := cTicket
															endif
															if empty(cKeyAnt)
																cKeyAnt := cKey
															endif
															If RecLock(cST2Alias,.T.)
																(cST2Alias)->TAFFIL 	:= cEmpTaf
																(cST2Alias)->TAFCODMSG 	:= "1"
																(cST2Alias)->TAFSEQ 	:= STRZERO( nTAFSEQ,3)
																(cST2Alias)->TAFTPREG 	:= cChannel
																(cST2Alias)->TAFKEY 	:= cKeyAnt
																(cST2Alias)->TAFMSG 	:= cMsg
																(cST2Alias)->TAFSTATUS 	:= "1"
																(cST2Alias)->TAFTICKET	:= cTickAnt
																(cST2Alias)->TAFDATA	:= dDtTicket
																(cST2Alias)->TAFHORA	:= cHrTicket

																If (cST2Alias)->( FieldPos( 'TAFUSER') ) > 0
																	(cST2Alias)->TAFUSER := cUserInt
																EndIf

																(cST2Alias)->(dbCommit(),MsUnLock())
															EndIf
															nTAFSEQ++
															cMsg := cBuffer
															nQtdChild := 0
														endif
													else //Acumula os filhos com o Pai
														cMsg += CRLF + cBuffer
													endif
												EndIf
											EndIf	
											FT_FSKIP()
										EndDo
										
										If !Empty(cEmpTaf)
											//Verifica se ficou alguma coisa na vari�vel cMsg
											If !Empty(AllTrim(cMsg))
												If RecLock(cST2Alias,.T.)
													(cST2Alias)->TAFFIL	 	:= cEmpTaf
													(cST2Alias)->TAFCODMSG 	:= "1"
													(cST2Alias)->TAFSEQ 	:= STRZERO( nTAFSEQ ,3)
													(cST2Alias)->TAFTPREG 	:= cChannel
													(cST2Alias)->TAFKEY 	:= iif( empty(cKeyAnt) , cKey 	 , cKeyAnt )
													(cST2Alias)->TAFMSG 	:= cMsg
													(cST2Alias)->TAFSTATUS 	:= "1"
													(cST2Alias)->TAFTICKET	:= iif( empty(cTickAnt) , cTicket , cTickAnt )
													(cST2Alias)->TAFDATA	:= dDtTicket
													(cST2Alias)->TAFHORA	:= cHrTicket

													If (cST2Alias)->( FieldPos( 'TAFUSER') ) > 0
														(cST2Alias)->TAFUSER := cUserInt
													EndIf
													
													(cST2Alias)->(dbCommit(),MsUnLock())
												EndIf
											EndIf

											FT_FUse()
											cMsg := ""
											/*+-----------------------------------------------------+
											| Copia o arquivo para pasta de arquivos processados, |
											| se acontecer erro na c�pia volto a transa��o	    	|
											+-----------------------------------------------------+*/ 
											If FwMakeDir(cDirFinz)
												cAuxFile	:= Substr(aTail(aPath),1,AT(".",aTail(aPath))-1)
												cAuxExt	:= Substr(aTail(aPath),Len(cAuxFile)+2,Len(cAuxFile)+5)		
													
												cArqFinz := cDirFinz + "\" +  cAuxFile + "_" + DToS( dDataBase )+ StrTran(Time(), ":", "" ) + "." +cAuxExt											 
												If ( __CopyFile( cDirProc + "\" + aTail(aPath) , cArqFinz )) 
													lErase := FERASE( cDirProc + "\" + cAuxFile + "." + cAuxExt)   == -1

                                                    If !lJob
                                                        Iif( lErase, MsgInfo(STR0039 + cValToChar( FError() )), MsgInfo(STR0041) )
                                                        If lErase                                                       
                                                            DisarmTransaction()                                                 
                                                        EndIf
                                                    Else
                                                        Iif( lErase, TAFConOut(STR0039 +" " +cValToChar( FError())) , TAFConOut(STR0041 +" " +cValToChar( FError())) )
                                                    EndIf
												Else
													TAFConOut(STR0042 +" " +cValToChar( FError()))
													TAFConOut(STR0042 + cDirProc + cBarra + STR0043 + cDirFinz + cBarra + "'") //"Erro ao Copiar arquivo do diretorio '"#"' para o diretorio '"
													DisarmTransaction()
												EndIf
											EndIf
											
												lProcess	:=	.T.
										Else		
											lProcess	:=	.F.										
										EndIf
										End Transaction 
									Else
										//"O arquivo importado possui filiais n�o compat�veis com o Complemento de Empresa da filial logada."
										//"Necess�rio revisar os registros T001 do arquivo e/ou o Cadastro de Complemento de Empresa."
										//"Arquivo: " + cArqTxt
										//"O arquivo foi enviado ao diret�rio out\inproc do servidor."
										If !lJob
											ApMsgStop( STR0055 + CRLF + CRLF + STR0056 + CRLF + CRLF + STR0057 + cArqTxt + CRLF + STR0058 )
										EndIf
									Endif
								Else
									If !lJob
										ApMsgStop(STR0044) //"Erro ao se conectar a tabela TAFST2"
									EndIf
								EndIf
							Else		
/*								If lJob		 	
									TAFConOut(STR0045) //"N�o encontrado layout T001 no inicio do arquivo"	
								Else
									ApMsgStop(STR0045) //"N�o encontrado layout T001 no inicio do arquivo"
								EndIf
							EndIf
						Else*/
							If !lJob
								ApMsgStop(STR0046 + cArqTxt + STR0047 + cValToChar( FError() )) //"Erro ao apagar arquivo '"# "Erro. 
							EndIf	
						EndIf
					Else
						If !lJob
							TAFConOut(STR0048+" "+cValToChar( FError()))
							//ApMsgStop(STR0048 + cArqTxt + STR0049+ cDirProc + "'") //"Erro ao Copiar arquivo '"# "' para pasta de processamento '"							
							MsgInfo("Opera��o cancelada pelo usu�rio.")
						EndIf
					EndIf		
				Else 
					If !lJob
						TAFConOut(STR0050 + " " +cValToChar( FError()))
						ApMsgStop(STR0050+ cDirProc) //"Erro na cria��o do diret�rio: "						 
					EndIf
				EndIf
			Else
				If !lJob
					TAFConOut(STR0051 + " " +cValToChar( FError()))
					ApMsgStop(STR0051 + cArqTxt + STR0052) //" n�o pode ser aberto em modo exclusivo"					 
				EndIf		
			EndIf		
		Else
			If !lJob
				TAFConOut(STR0053+ " " + cValToChar( FError()))
				ApMsgStop(STR0053) //"Arquivo Inexistente"
			EndIf	
		EndIf
	Next nX

	IIf (Len(aArq) == 0,STR0053 + cDirRead,.F.) //"Nenhum Arquivo encontrado em : " 
	
Return (lProcess)

//----------------------------------------------------------------------
/*/{Protheus.doc} FRetCanal
Retorna nome do Canal de acordo com a linha passada

@author Evandro dos Santos Oliveira
@since 21/04/2015
@version 1.0	

@param cLinha - Linha em processo

@return Nil
/*/
//------------------------------------------------------------------------
Static Function FRetCanal(cLinha, cChanT999)

	Local cCanal 		:= ""
	Local nPipe  		:= 0
	Local nI	 		:= 0
	Default	cChanT999	:= ''
	
	For nI := 1 To Len(cLinha) 
		If Substr(cLinha,nI,1) == "|"
			nPipe++
			if cCanal == 'T999' .and. nPipe == 2
				cChanT999	:= cCanal
				cCanal	:= ''
				nPipe	:= 1
			endif
			If nPipe == 2
				Exit 
			EndIf
		Else
			cCanal += 	Substr(cLinha,nI,1)
		EndIf
	Next nI	
	
Return cCanal

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Evandro dos Santos Oliveira
@since  22/04/2015
@version 1.0

/*///----------------------------------------------------------------
Static Function SchedDef()

	Local aParam  := {}


	aParam := { "P";				//Tipo R para relatorio P para processo
	           	,"TAFMST2";		//Pergunte do relatorio, caso nao use passar ParamDef
	            ,;				//Alias
	            ,;				//Array de ordens
	            ,STR0037 } 		//Rotina para processamento de importacao de arquivos TXT


Return ( aParam )


//-------------------------------------------------------------------
/*/{Protheus.doc} FVerExcl
Verifica se o Arquivo n�o est� em Uso

@author Evandro dos Santos Oliveira
@since  22/04/2015
@version 1.0

@param cArq   - Caminho do arquivo a ser verificado
@Return  lRet - Indica se o Arquivo est� em uso

/*///----------------------------------------------------------------
Static Function FVerExcl(cArq)

	Local nHandle := 1
	Local lRet 	:= .F.

	// Devido as exigencias do Sonarqube removemos o par�mentro FO_EXCLUSIVE, n�o h� problema neste caso, pois colocamos um tratamento no uso da pr�pria CopyFile() 
	nHandle := FOPEN(cArq)
	lRet	 := IIf(nHandle < 0,.F.,.T.)
	FCLOSE(nHandle)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FArrT500
Retorna o Array com os Layouts 

@author Evandro dos Santos Oliveira
@since  16/06/2015
@version 1.0

@Return  aLayout - Array com Layouts

/*///----------------------------------------------------------------
Function FArrT500()
Return(aLayout)

//-------------------------------------------------------------------
/*/{Protheus.doc} FVldFil
Fun��o respons�vel por validar se todas as filiais do arquivo que est� sendo importado
s�o v�lidas, conforme de/para no Complemento de Empresa. 

@author Luccas Curcio
@since  07/06/2016
@version 1.0

@Return  lRet	-> Arquivo v�lido .T. / Arquivo inv�lido .F.

/*///----------------------------------------------------------------
static function FVldFil(aFilArqInt, cBkpEmpLog, cBkpFilAnt)

	local	lRet	:=	.T.
	local	cLinha	:=	''
	local	cFilTAF	:=	''
	local	aLinha	:=	{}

	Default	aFilArqInt	:= {}
	Default	cBkpEmpLog	:= ""
	Default	cBkpFilAnt	:= ""

	while !( ft_fEof() )
			
		If "|T001|" $ FT_FREADLN()   
			//Armazeno o conte�do da linha que est� sendo lida do TXT
			cLinha := FT_FREADLN()	
			//Fa�o parser do conte�do da linha em um array
			aLinha := TafStr2Arr( cLinha , "|" )
			if aLinha[ 2 ]  == "T001"
			
				//caso n�o seja encontrada filial correspondente no Complemento de Empresa, aborta o processo			
				cFilTAF	:=	fTAFGetFil( aLinha[ 3 ] )			
				
				if empty( cFilTAF ) //.or. cFilTAF <> cFilAnt 
					lRet	:=	.F.
					exit
				endif
				if lRet
					aadd(aFilArqInt,cFilTAF)
				else
					aFilArqInt	:= {}
				endif
				
			endif
		EndIf
		
		ft_fSkip()
	enddo

	ft_fGoTop()

	if !Taf500Emp(cBkpEmpLog, cBkpFilAnt, aFilArqInt) 
		lRet := .F.
		ApMsgStop("Existem filiais n�o pertinentes a empresa: " + cBkpEmpLog + ". A importa��o ser� abortada!" )
	endIf
aSize(aLinha,0)
aLinha := Nil

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FVldFil
Fun��o respons�vel por validar se todas as filiais do arquivo que est� sendo importado
s�o v�lidas, conforme de/para no Complemento de Empresa. 

@author Luccas Curcio
@since  07/06/2016
@version 1.0

@Return  lRet	-> Arquivo v�lido .T. / Arquivo inv�lido .F.

/*///----------------------------------------------------------------
Static Function getFileArray(cText)

	Local aFiles := {}

	If (AT(" | " , cText) != 0)
		aFiles := StrTokArr2(cText, " | ")
	Else
		aFiles := {cText}
	Endif

Return aFiles

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF500EMP
Fun��o respons�vel por validar se todas as filiais do arquivo pertencem a mesma empresa
@author Henrique Pereira
@since  28/05/2018
@version 1.0

@Return  lRet	-> Arquivo v�lido .T. / Arquivo inv�lido .F.

/*///----------------------------------------------------------------
Static Function Taf500Emp(cBkpEmpLog, cBkpFilAnt, aFilArqInt)
	Local lRet	:=	.T.
	Local nX	:=	0

	if !empty(cBkpFilAnt + cBkpFilAnt)
		For nX := 1 to Len(aFilArqInt)		
			cFilAnt := aFilArqInt[nX]		
			if	!cBkpEmpLog == FWCodEmp()			
				lRet := .F.
			endif
		Next
		cFilAnt := cBkpFilAnt
	endif

Return lRet
