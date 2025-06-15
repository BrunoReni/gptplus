// ######################################################################################
// Projeto: KPI
// Modulo : Agendador
// Fonte  : kpiImportData.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.12.05 | 1776 Alexandre Silva      
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "kpiImportData.ch"

#define		F_BLOCK 1024
#define		KPI_PATH	01//KPI_PATH
#define		KPI_IMPORT	02//KPI_PATH

//Posicoes do arquivo de importacao
#define 	I_ID		01
#define 	I_ID_CODCLI	02
#define 	I_DATA		03
#define 	I_VALOR		04
#define 	I_META		05
#define 	I_DESCRICAO	06
#define 	I_AGREG		07
#define 	I_PREVIA	08
#define 	I_ANALITICO	09

/*
*Funcao para importacao dos dados do KPI.
*/
function kpiImportData(aParms)
	local cFileDest		:= ""
	local cFileOri		:= ""
	local cPathDest		:= ""
	local cLogName		:=	"log_"
	local cPathFile		:= alltrim(aParms[KPI_PATH]+aParms[KPI_IMPORT])	
	local cIDImporta	:=	aParms[02]
	local aFiles 		:= {}
	local aFilesType	:= {"\*.txt","\*.csv"}
	local nFile			:= 1	
	local nContFile		:= 1	
	local lExisteLog	:= .f.
	local lAbortImport	:= .f.    
	local lRet			:= .t.  
	local cPastaArq		:= ""
	local bError
    
	private oPlanilha
	private oIndicador
	private	oAgendador 
	private oScheduler
	private dCalcDe		:=	date()
	private dCalcAte	:=	date()
	private lEnvMailAdm	:= .f.
	
	public oKPICore, cKPIErrorMsg := ""

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	//Inicializando o KPICORE
	oKPICore := TKPICore():New(aParms[KPI_PATH])
	ErrorBlock( {|oE| kpiImpErro(oE, oKPICore)})

	//Seta o WorkStatus para ser apresentado na barra de ferramentas
	putGlbValue("bKpiImpRun","T")

	// Arquivo de log
	oKPICore:LogInit()
	oKPICore:Log(STR0001, KPI_LOG_SCRFILE) //"Iniciando importação dos indicadores."
	if(oKPICore:nDBOpen() < 0)
		lEnvMailAdm := .t.
		oKPICore:Log(STR0002, KPI_LOG_SCRFILE)  //"Erro na abertura do banco de dados.(kpiImportData)"  
		envLogMail(aParms[KPI_PATH],cLogName,oKPICore)	
		return
	endif
	
	oPlanilha 	:= oKPICore:oGetTable("PLANILHA")
	oIndicador	:= oKPICore:oGetTable("INDICADOR")                
	oAgendador	:= oKPICore:oGetTable("AGENDAMENTO")
	
	oScheduler  := TKPIScheduler():New()
	oKPICore:oOwner(oScheduler)	
	cLogName += alltrim(getJobProfString("INSTANCENAME", "SGI"))+"_"
	cLogName += strtran(dToc(date()),"/","") +"_"
	cLogName += strtran(time(),":","")
	    
	for nContFile := 1 to len(aFilesType)
		aFiles 	:= directory(cPathFile + aFilesType[nContFile])//Lista do arquivos
		nFile 	:= 1

		if(len(aFiles) > 0 .and. ! lExisteLog)
			oScheduler:lSche_CriaLog(aParms[KPI_PATH],cLogName)//Criando o arquivo de log.
			oScheduler:lSche_WriteLog(STR0003) //"Iniciado a importação dos indicadores."
			lExisteLog	:= .t.
		endif
		
		//Verifica se posso iniciar o calculo.
		while(nFile <= len(aFiles))
			if(! isCalcRunning())
				dCalcDe		:=	cTod("01/01/1980")
				dCalcAte	:=	cTod("01/01/1980")

				oScheduler:lSche_WriteLog(STR0004 + aFiles[nFile][1])  //"Importando dados do arquivo: "
				
				//Importa os indicadores deste arquivo.   
				begin sequence
					bError  :=	ErrorBlock({|e| conout("Erro ao importar dados do arquivo" ),lRet:= .F.})
					
					if(aFilesType[nContFile] == "\*.txt")
						lTXTImpInd(cPathFile + "\" + aFiles[nFile][1])
					elseif(aFilesType[nContFile] == "\*.csv")
						lCSVImpInd(cPathFile + "\" + aFiles[nFile][1])
					endif					
				end sequence
				ErrorBlock(bError)
				
				if(lRet)
                	cPastaArq := "\updated\"
				else
					FT_FUse()
					cPastaArq := "\error\"
					oScheduler:lSche_WriteLog(STR0032 + aFiles[nFile][1]) //"Erro ao importar dados do arquivo "
				endif

				//Quando acabar o processamento move o arquivo para a pasta de backup.     
				cFileDest	:= "bkp" + aFiles[nFile][1]
				cFileOri	:= cPathFile + "\" + aFiles[nFile][1]
				cPathDest	:= cPathFile + cPastaArq
				moveFiles(cPathDest,cFileDest,cFileOri)	
			
				//cRequestCalc	:=	"-1|" + dToc(dCalcDe) + "|" + dToc(dCalcAte)
				//startJobCalc(cFileOri,oScheduler,cRequestCalc)
				sleep(900)
				nFile++
			else
				oScheduler:lSche_WriteLog(STR0012 ) //"A importação foi cancelada, porque existe um cálculo em processamento."
				lEnvMailAdm  := .t.
				lAbortImport := .t.
    	   		exit
			endif				
		enddo

		if(lAbortImport)
			exit
		endif
	next nContFile	

	//Seta o WorkStatus para ser apresentado na barra de ferramentas
	putGlbValue("bKpiImpRun","F")
	
	if lExisteLog
		oScheduler:lSche_WriteLog(STR0005)  //"Finalizado a importação dos indicadores."
		oScheduler:lSche_CloseLog() 
	endif			

	oKPICore:Log(STR0006, KPI_LOG_SCRFILE)	 //"Importação dos indicadores finalizada."

	if lEnvMailAdm == .t.
		envLogMail(aParms[KPI_PATH],cLogName,oKPICore)			
	end if
return .t.

/*
*Faz a importacao dos indicadores folhas a partir de um arquivo txt.
*Layout do arquivo
*ID do Indicador;ID do Indicador Cliente;Data;Valor;Meta;Previa
*/
static function lTXTImpInd(cFileName) 
return lTrataArquivo(cFileName)

/*
*Faz a importacao dos indicadores folhas a partir de um arquivo csv.
*Layout do arquivo
*ID do Indicador;ID do Indicador Cliente;Data;Valor;Meta;Previa
*/
static function lCSVImpInd(cFileName) 
return lTrataArquivo(cFileName)

static function lTrataArquivo(cFileName)
	local aValues		:=	{}
	local lValidaLinha	:=	.t.
	local lRet			:=	.t.
	local cMessage		:=	""
	local nItem			:=	0
	local nLinha		:=	0 , nReadArray := 0
	
	FT_FUse(cFileName)
	FT_FGOTOP()
		
	while !FT_FEof()
		nLinha++
		aValues := aBIToken(FT_FReadln(), ";", .f.)
		
		for nReadArray := 1 to len(aValues)
			if(valtype(aValues[nReadArray]) == "C")
				aValues[nReadArray] = strTran(aValues[nReadArray], chr(10), "")
				aValues[nReadArray] = strTran(aValues[nReadArray], chr(160), "")
			endif
		next nReadArray
		
		if!( upper(alltrim( aValues[1])) ==  "ID" )
			//Ajusta para que o ID tenha sempre tamanho 10 caractreres. Complementa com zeros a esquerda
			if len(aValues) > 0 .and. len(alltrim(aValues[1])) < 10 
				aValues[1] := Replicate("0",10-len(alltrim(aValues[1]))) + aValues[1]
			endif

			lValidaLinha := valIndLinha(aValues)
			if(lValidaLinha)   
				saveIndImp(aValues)
			else
				cMessage	:= STR0007 + alltrim(str(nLinha)) +"<br>" //"Erro na validacao da linha: "
				for nItem := 1 to  len(aValues)
					cMessage+= STR0011 + alltrim(str(nItem)) + ": " + alltrim(aValues[nItem]) + "<br>" 
				next nItem
				oScheduler:lSche_WriteLog(cMessage)   
				lEnvMailAdm	:= .t.
			endif
	   	endif
		FT_FSkip()
	enddo

	FT_FUse()
		
return lRet     

/*
*Faz a gravacao do indicador importado.
*/
function saveIndImp(aValues,oLog)
	Local aFields		:= {}	
	Local aDetalhe		:= {}
	Local aDataPesq 	:= {}
	Local nFrequencia   := 0
	Local nOrdem		:= 1
	Local cID			:= ""
	Local dataImp
	Local lValorPrevio	:= .F.
	Local lAgregado		:= .F.  
	Local lAnalitico	:= .F. 
	Local oParametro	:= oKpiCore:oGetTable("PARAMETRO")
	Local oAnalitico	:= oKpiCore:oGetTable("ANALITICO")
	Local nL			:= 0  //Contador de linha.      
	Local nC			:= 0  //Contador de coluna.
	Local nLinha		:= 0  //Linha da tabela invertida.             
	Local cIDPlanilha	:= "" //ID do item da planilha.       
	Local cIndicador	:= "" //Nome do Indicador Importado.           

	Default oLog 		:= oScheduler
	
	//Verifica se será importada a prévia. 	
	If(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lValorPrevio := oParametro:lValue("DADO") .and. len(aValues) >= I_PREVIA
	EndIf 
	
	//Verifica se será realizada a agregação dos valores. 
	If ( len(aValues) >= I_AGREG )
		lAgregado := .T.
	EndIf    
	
	//Verifica se serão importados os dados analíticos. 
	If ( len(aValues) >=  I_ANALITICO )
		lAnalitico := .T.
	EndIf  
   
	//Identifica a ordem a ser utlizada [ID ou Código de Importação.]
	if( ! Empty(aValues[I_ID_CODCLI]))
		cID	:=	aValues[I_ID_CODCLI]
		nOrdem	:=	6
	else
		cID	:=	aValues[I_ID]
		nOrdem	:=	1
	endif

	If( oIndicador:lSeek(nOrdem, {strTran(cID, chr(10), "") } ) )
		cID			:= oIndicador:cValue("ID")
		cIndicador	:= AllTrim( oIndicador:cValue("NOME") )
		nFrequencia := oIndicador:nValue("FREQ")
		dataImp		:= aValues[I_DATA] 
		
		if(valType(dataImp) == "C")
			aDataPesq 	:= oPlanilha:aDateConv(ctod(aValues[I_DATA]), nFrequencia) 
			setDataImport(ctod(aValues[I_DATA]))  			
		elseif(valType(dataImp) == "D")
			aDataPesq 	:= oPlanilha:aDateConv(aValues[I_DATA], nFrequencia)
			setDataImport(aValues[I_DATA])
		endif
		
		aFields	:=	{}
		
		//Grava a data e hora de atualização da linha da planilha de valores. 
		aAdd(aFields, {"LOG", cBIStr( Date() ) + "|" + Time() }) 
		
		if( ! oPlanilha:lSeek(2, {cID,aDataPesq[1],aDataPesq[2],aDataPesq[3]}))		    
		    //Recupera o ID que será utilizado para o item na planilha de valores.
			cIDPlanilha := oPlanilha:cMakeID()
            
			//Monta o array com os valores a serem gravados na planilha de valores. 
			aAdd(aFields, {"PARENTID"	, cID})	
			aAdd(aFields, {"ID"			, cIDPlanilha })
			aAdd(aFields, {"DIA"		, aDataPesq[3]})	
			aAdd(aFields, {"MES"		, aDataPesq[2]})	
			aAdd(aFields, {"ANO"		, aDataPesq[1]})   

			if!(empty(aValues[I_VALOR]) )   
				aAdd(aFields, {"VALOR"	, val(aValues[I_VALOR])})
			endif
			
			if!(empty(aValues[I_META]))
				aAdd(aFields, {"META"	, val(aValues[I_META])})
			endif
			
			if(lValorPrevio .and. ! (empty(aValues[I_PREVIA])))
				aAdd(aFields, {"PREVIA"	, val(aValues[I_PREVIA])})
			endif

			oKPICore:Log( STR0029 + cIndicador , KPI_LOG_SCRFILE)   //"Gravação Planilha de Valores do Indicador: "

			if(! oPlanilha:lAppend(aFields))				
				if(oPlanilha:nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
					oLog:lSche_WriteLog(STR0010 + STR0017 + cID) 
					lEnvMailAdm	:= .t.
				else
					nStatus := KPI_ST_INUSE
					oLog:lSche_WriteLog(STR0010 + STR0017 + cID + STR0008)  //": O registro esta em uso"
					lEnvMailAdm	:= .t.
				endif
			else
				putGlbValue("bKpiIndUpdate","T")		
			endif	
		else    
		    //Recupera o ID do item da planilha de valores. 
			cIDPlanilha := oPlanilha:cValue("ID")
		         
			If lAgregado .And. Alltrim( upper( aValues[I_AGREG] ) ) == "T"
			  	//Agrega os valores para gravação na planilha de valores. 
			  	if!(empty(aValues[I_VALOR]) )   
					aAdd(aFields, {"VALOR"	, val(aValues[I_VALOR]) + oPlanilha:nValue("VALOR")})
				endif
				
				if!(empty(aValues[I_META]))
					aAdd(aFields, {"META"	, val(aValues[I_META]) + oPlanilha:nValue("META")})
				endif
				
				if(lValorPrevio .and. ! (empty(aValues[I_PREVIA])))
					aAdd(aFields, {"PREVIA"	, val(aValues[I_PREVIA]) + oPlanilha:nValue("PREVIA")})
				endif
			else 	  
				//Substitui os valores da planilha de valores. 
				if!(empty(aValues[I_VALOR]) )   
					aAdd(aFields, {"VALOR"	, val(aValues[I_VALOR])})
				endif
				
				if!(empty(aValues[I_META]))
					aAdd(aFields, {"META"	, val(aValues[I_META])})
				endif
				
				if(lValorPrevio .and. ! (empty(aValues[I_PREVIA])))
					aAdd(aFields, {"PREVIA"	, val(aValues[I_PREVIA])})
				endif
			endif
		          
			oKPICore:Log( STR0030 + cIndicador , KPI_LOG_SCRFILE) //"Atualizado Planilha de Valores do Indicador: "
		
			if(! oPlanilha:lUpdate(aFields))
				if(oPlanilha:nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
					oLog:lSche_WriteLog(STR0010 + STR0017 + cID)
					lEnvMailAdm	:= .t.
				else
					nStatus := KPI_ST_INUSE
					oLog:lSche_WriteLog(STR0010 + STR0017 +cID + STR0008)  //": O registro esta em uso"
					lEnvMailAdm	:= .t.
				endif    
			else
				putGlbValue("bKpiIndUpdate","T")		
			endif	
		endif 

		oAnalitico:lRemove( cIDPlanilha )

		If ( lAnalitico ) 		
			oKPICore:Log( STR0031 , KPI_LOG_SCRFILE) //"Gravando Dados Analíticos"

			If ( oAnalitico:lValida( aValues[I_ANALITICO] ) ) 
	   			For nL := 1 To Len( aValues[I_ANALITICO][1] )     				      
	   				nLinha ++
	   				For nC = 1 To Len( aValues[I_ANALITICO][1][nL] )
	   				    aDetalhe := {}
	   				
		   				aAdd( aDetalhe , {"ID"			, oAnalitico:cFastMakeID()} ) 				
		   				aAdd( aDetalhe , {"INDICADOR"	, cID } )
		   				aAdd( aDetalhe , {"PLANILHA"	, cIDPlanilha } )    
		   				aAdd( aDetalhe , {"LINHA"		, nLinha } )
		   				aAdd( aDetalhe , {"CAMPO"		, cBIStr(aValues[I_ANALITICO][1][nL][nC][1]) } )
		   				aAdd( aDetalhe , {"CONTEUDO"	, cBIStr(aValues[I_ANALITICO][1][nL][nC][2]) } )
	
		   				oAnalitico:lAppend( aDetalhe )
					Next nI
	   			Next nI 
			EndIf
   		EndIf			
	Else
		oLog:lSche_WriteLog(STR0009 + cID)//"INDICADOR Nao localizado..."
		lEnvMailAdm	:= .t.
	EndIf
	
return .T.

/*
*Se a data minima e maxima para importacao.
*/
static function setDataImport(dData)

	if(dCalcDe == cTod("01/01/1980")  .and. dCalcAte ==  dCalcDe)
		dCalcDe	:= dData
		dCalcAte:=	dData
	else
		if(dData <= dCalcDe )
			dCalcDe	:= dData
		endif
		
		if(dData >= dCalcAte )
			dCalcAte:=	dData
		endif
	endif


return .t.   


/*
*Move os arquivos que ja foram carregados, para o diretorios de backup.
*/
static function moveFiles(cPathDest,cFileDest,cFileOri)

	//Cria o diretorio de destino do backup
	BIForceDir(cPathDest)
	__CopyFile(cFileOri,cPathDest+cFileDest)
	fErase(cFileOri)
	
return 

/*
*Valida a linha importada do indicador.
*/
static function valIndLinha(aLinha)
	local lValida		:=	.t.
	local lValorPrevio	:= .f.
	local oParametro	:= oKpiCore:oGetTable("PARAMETRO")

	if(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lValorPrevio := oParametro:lValue("DADO")

		if(lValorPrevio .and. len(aLinha) > 7)
			if( ! empty(aLinha[I_PREVIA]))
				lValorPrevio := .t.
			endif
		else
			lValorPrevio := .f.		
		endif					
	endif
	
	if(empty(aLinha[I_ID]) .and. empty(aLinha[I_ID_CODCLI]))
		lValida	:=	.f.
	elseif(empty(aLinha[I_DATA])) 
		lValida	:=	.f.
	elseif(empty(aLinha[I_META]) .and. empty(aLinha[I_VALOR])) 
		if (lValorPrevio .and. empty(aLinha[I_PREVIA]))
			lValida := 	.f.
		endif	
	endif  
	     
	
	if(lValida .and. !empty(aLinha[I_META]))
		lValida := isNumeric(aLinha[I_META])
	endif
	
	if(lValida .and. !empty(aLinha[I_VALOR]))
		lValida := isNumeric(aLinha[I_VALOR])
	endif
	                                         
	if(lValida .and. !empty(aLinha[I_AGREG]))
		lValida := .T.
		//todo SE EH T OU F
	endif
	
	
	if(lValida .and. lValorPrevio .and. !empty(aLinha[I_PREVIA]))
		lValida := isNumeric(aLinha[I_PREVIA])
	endif
    
    if (lValida)
		lValida := isDateValid(aLinha[I_DATA])
	endif
    

	if(lValida)
		//O valor nao pode conter separador de milhares.
		if	( at(",", aLinha[I_VALOR]) != 0  .and. at(".", aLinha[I_VALOR])	!= 0  ) .or.;
			( lValorPrevio .and. at(",", aLinha[I_PREVIA])!= 0  .and. at(".", aLinha[I_PREVIA])	!= 0  ) .or.;
			( at(",", aLinha[I_META])  != 0  .and. at(".", aLinha[I_META]) 	!= 0  )

			 lValida	:=	.f.
		endif
	endif
	
		
	if(lValida)
		aLinha[I_VALOR]	:= strtran(aLinha[I_VALOR],",",".")//Transforma o ponto em virgula na importacao de valores.
		aLinha[I_META]	:= strtran(aLinha[I_META],",",".")//Transforma o ponto em virgula na importacao de valores.

		if(lValorPrevio)
			aLinha[I_PREVIA]:= strtran(aLinha[I_PREVIA],",",".")//Transforma o ponto em virgula na importacao de valores.
		endif			
	endif		
	
return lValida


/*
*Verifica se é uma data valida.
*/
static function isDateValid(cDtStr)  
	local cDat	:= alltrim(cDtStr) 
	local cAux  := ""
	local lRet 	:= .t.
	local i		:= 1 
    
	for i:= 1 to len(cDat)
		cAux := right(left(cDat,i),1)
		if 	(asc(cAux) > 47 .and. asc(cAux) < 58) .or.	cAux == "/" .or. cAux == "." .or. cAux == "-"
			lRet := .t.	
		else                                  
		  	lRet := .f.	  
		  	exit
		endif
	next                                        

    if len(cDat) == 0
    	lRet := .f.	  
    end if
	
	if (lRet)
		cDat := ctod(cDat)
		if len(alltrim(dtoc(cDat))) > 5
			lRet := .t.
		else
			lRet := .f.
		endif    
	endif
return lRet


/*
*Verifica se é um numero válido
*/
static function isNumeric(cStr)
	local cNum	:= alltrim(cStr)
	local cAux  := ""
	local lRet 	:= .t.
	local i		:= 1 

	for i:= 1 to len(cNum)
		cAux := right(left(cNum,i),1)
		if 	(asc(cAux) > 47 .and. asc(cAux) < 58) .or.	cAux == "." .or. cAux == "," .or. cAux == "-"
		  	lRet := .t.	
		else 
		  	lRet := .f.	
		  	exit
		endif
	next
return lRet




static function isCalcRunning()
	local lRet			:=	.t.
	local cJobCalName	:=	alltrim(getJobProfString("INSTANCENAME", "SGI")+"_CalcInd.lck")		

	//Se conseguir abrir o arquivo o job esta liberado
	nHandle	:=	fCreate(cJobCalName,1)

	if(nHandle != -1)
		lRet	:= .f.
		fClose(nHandle) 
	endif
	
return lRet

/*
static function startJobCalc(cFile,oScheduler,cRequest)
	local cJobCalName	:=	alltrim(getJobProfString("INSTANCENAME", "SGI")+"_CalcInd.lck")		
	local aParms		:=	{}

	if( ! isCalcRunning())	
		oScheduler:lSche_WriteLog(	STR0013 + subst(cRequest,4,len(cRequest)) + "<br>"+ ; //"Iniciando o cálculo para o periodo: "
									STR0014+ cFile)	 //" Arquivo: "

		aadd(aParms,cJobCalName)					//Nome do arquivo de job.
		aadd(aParms,oKpicore:cKpiPath())			//Kpi Path.
		aadd(aParms,0)					 			//Usuario Logado. Nao usado
		aadd(aParms,cRequest)						//Requisicao do java.
		aadd(aParms,"")								//Site do KPI. Nao usado
			
		StartJob("KpiCalc_Indicador", GetEnvServer(), .f., aParms)
	else
		oScheduler:lSche_WriteLog(	STR0015 + cFile+; //"O cálculo dos indicadores do arquivo: "
									STR0016 )	 //" não foi executado porque já existia um cálculo em processamento."  
		lEnvMailAdm	:= .t.									
	endif
	
return .t.
*/

/*
*Quando ocorrer erro no processamento envia o arquivo de log para o e-mail dos Admins
*/
static function envLogMail(cEndSite,cArqLog,oKPICore)
	local cTo:="", cAssunto, cCorpo, cAnexos:="", cCopia
	local cServer, cPorta, cConta, cAutUsuario, cAutSenha ,cFrom   
	local oConexao	:= oKPICore:oGetTable("SMTPCONF")
	local oPessoas	:= oKPICore:oGetTable("USUARIO")
	local cCamArq   := ""
	Local cProtocol				:= "0" // Por padrão não é utilizado nenhum protocolo.
	
	oConexao:cSQLFilter("ID = '"+cBIStr(1)+"'") // Filtra o ID 1 onde tem a configuracao SMTP
	oConexao:lFiltered(.t.)
	oConexao:_First()
	if(!oConexao:lEof()) //posiciona cfg. da organização
		cServer		:= alltrim(oConexao:cValue("SERVIDOR"))
		cPorta			:= alltrim(oConexao:cValue("PORTA"))
		cConta			:= alltrim(oConexao:cValue("NOME"))
		cAutUsuario	:= alltrim(oConexao:cValue("USUARIO"))
		cAutSenha		:= alltrim(oConexao:cValue("SENHA"))
		cFrom			:= alltrim(oConexao:cValue("NOME"))
		cProtocol		:= AllTrim(cBIStr(oConexao:nValue("PROTOCOLO")))
	endif
	oConexao:cSQLFilter("") // Retira filtro
	
	oPessoas:cSQLFilter("ADMIN = 'T'") // Filtra os usuários que são Admin
	oPessoas:lFiltered(.t.)
	oPessoas:_First()	 
	while(!oPessoas:lEof()) //cria lista de endereços
    	cTo	+= if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))   
    	oPessoas:_Next()
	enddo               	
	oPessoas:cSQLFilter("") // Retira filtro	
	                                                         	
	if len(alltrim(cArqLog)) > 4 
		cCamArq := cEndSite + "logs\imports\" + cArqLog + ".html"
	endif 
	
	cCopia	:= ""
	cAssunto:= STR0018 //"SGI - Importação de dados"
	cAnexos	:= cCamArq   
	cCorpo  := STR0019 //"Ocorreu um erro na importação de dados, favor verificar o arquivo de log. "
	oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo, cAnexos, cFrom, cCopia, "", cProtocol)			
return   


static function kpiImpErro(oE, oKPICore)
	envLogMail("","",oKPICore)
	__KPIError(oE)   
return

