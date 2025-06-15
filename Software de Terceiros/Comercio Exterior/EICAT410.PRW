#Include "Totvs.Ch"
#Include "EICAT410.Ch"
#Include "Average.CH"

#Define ATT_COMPOSTO "COMPOSTO"
/*
Programa   : EICAT410
Objetivo   : Faz a integração dos atibutos do catalogo de produtos
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Function EICAT410()
Local lRet
Local cMsgRet := ""
Local cUrl
If MsgYesNo(STR0002,STR0001) //"Esta opção ira realizar o download e integração para o sistema do cadastro de atributos do Portal Unico. Deseja prosseguir?"###"Atenção"
	cUrl := AVgetUrl(.T.) 
	If !empty(cUrl)
		lRet := ProcArquiv(@cMsgRet,cUrl)
		If lRet
			MsgInfo(STR0003,STR0001) //"Integração de atributos realizada com sucesso!"###"Atenção"
		Else
			EasyHelp(STR0004+CHR(13)+CHR(10)+cMsgRet,STR0001) //"Falha na integração de atributos."###"Atenção"
		EndIf
	EndIf	
EndIf

Return

/*
Programa   : ProcArquiv
Objetivo   : Faz a integração dos atibutos do catalogo de produtos
Parâmetros : cMsgRet - Mensagem de retorno no caso de ocorrer algum erro
Retorno    : lRet - Se integrado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function ProcArquiv(cMsgRet,cUrl)
Local lRet := .T.
Local aArquivos := {}
Local cDirComex   := "\comex"
Local cCaminho := cDirComex+"\atributos\"

Local oProgress := EasyProgress():New(.F.)
//Verifica estrutura de pastas
lRet := ExisteComex(cDirComex,cCaminho,@cMsgRet)

//JAVASCRIPT - Download, ordenação e quebra do arquivo json
If lRet
    AtuBloqAtt('EKG') //bloqueia todos os registros uma única vez	
	AtuBloqAtt('EKH') //bloqueia todos os registros uma única vez
	LimpaPasta(cCaminho) //aqui
	MsAguarde({|| lRet := TrataArqs(@cMsgRet,cDirComex,cCaminho,cUrl)},STR0005,STR0006) //"Integração de Atributos"###"Aguarde...") //aqui
	If lRet
		aArquivos := getJsonFiles(cDirComex,cCaminho)
		If !Empty(aArquivos)
			oProgress:SetProcess({|| lRet := MontaThread(aArquivos,oProgress,@cMsgRet), STR0007 }) //'Iniciando integração...'
			oProgress:Init()
			LimpaPasta(cCaminho) // aqui 
		Else
			cMsgRet := STR0008 //"Não foi encontrado nenhum arquivo para integração."
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*
Programa   : MontaThread
Objetivo   : Thread Pai, onde será feito o controle das Threads filhas que serão responsáveis pela integração
Parâmetros : aArquivos 	- Array com os arquivos Json que serão integrados
				 oProgress 	- Objeto de barra de progresso
				 cMsgRet		- Mensagem de retorno no caso de ocorrer algum erro
Retorno    : lRet - Se integrado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function MontaThread(aArquivos,oProgress,cMsgRet)
Local nTotThread:= 4 //Foi definida a utilização de 4 Threads
Local nMaxThread //Maximo de arquivos a serem processados por cada Thread
Local nTot
Local nThread
Local aProc
Local nI
Local nTotNcm := 0
Local nCtrJob := 0
Local nRetThread
Local lRet := .T.
Local lRetFilha
Local nThreadFim := 0
Local cError
Local nFilha := 0
Local cNcmIni := ""
Local cAtribIni:= ""
Local cNcmFim := ""
Local cAtribFim := ""

Begin Sequence

nMaxThread := int(Len(aArquivos)/nTotThread)
nTot := 1
nThread := 0
aProc := {}
Do While nTot <= Len(aArquivos)
aAdd(aProc,aArquivos[nTot])
	if nTot == Len(aArquivos) .OR. (nMaxThread == Len(aProc) .And. nThread+1 < nTotThread)
		nThread++
		StartJob("AT410JOBS",GetEnvServer(),.F.,"AT410JOBS"+AllTrim(Str(ThreadId()))+"_"+AllTrim(Str(nThread)),aProc,oProgress,cEmpAnt,cFilAnt,"AT410JOBS"+AllTrim(Str(ThreadId())),nThread)
		aProc := {}
	ENdif
	nTot++
EndDo
//Captura a quantidade total de registros a serem processados
For nI:= 1 To nThread
	nRetThread := 0
	While !killApp()
		lRetFilha := IpcWaitEx("AT410JOBS"+AllTrim(Str(ThreadId()))+"_"+AllTrim(Str(nI)),5000,@nRetThread)
		If lRetFilha
				Exit
		Endif
	End
	If !Empty(nRetThread)
		nTotNcm += nRetThread
	EndIf
Next
oProgress:SetRegua(nTotNcm)
nTot := 0
//Recebe uma reposta a cada registro processado para incrementar o Progress
While !killapp() .And. (nTotNcm != nCtrJob .Or. nTot != Len(aArquivos))
	lRetFilha := IpcWaitEx("AT410JOBS"+AllTrim(Str(ThreadId())),100,@nFilha,@cNcmIni,@cAtribIni,@cNcmFim,@cAtribFim,@cError)
	If lRetFilha
		If Empty(cError)
			If Empty(nFilha)
				nCtrJob++
				oProgress:IncRegua()
			Else
				nTot++
			EndIf
		Else
			cMsgRet := cError
			lRet := .F.
			Break
		EndIf
	EndIf
End

//Recebe uma resposta de fim do processamento das Threads filhas
For nI:= 1 To nThread
	While !killApp()
		lRetFilha := IpcWaitEx("AT410JOBS"+AllTrim(Str(ThreadId()))+"_"+AllTrim(Str(nI)),5000)
		If lRetFilha
			nThreadFim++
			Exit
		Endif
	End
Next

//Grava data e hora de atualização
If lRet
	PutMv("MV_EIC0071", FWTimeStamp(2))
EndIf

End Sequence

Return lRet

/*
Programa   : AT410JOBS
Objetivo   : Threads filhas respinsáveis por processar os arquivos json e gravar no protheus
Parâmetros : cID 			- Código que identifica a Thread em execução
				 aArquivos	- Array que contém os arquivos a serem processados pela Thread
				 oProgress 	- Objeto de barra de progresso
				 cEmp			- Código da empresa para abertura do ambiente
				 cFil			- Código da filial para abertura do ambiente
				 cIdPai		- Código que identifica a Thread Pai
Retorno    : lRet - Se integrado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Function AT410JOBS(cID,aArquivos,oProgress,cEmp,cFil,cIdPai,nFilha)
Local lRet := .T.
Local nI
Local nY
Local oAtributo
Local cNcm
Local aNcmAtrib
Local oNcmDados
Local lInsere
Local aObjJson := Array(Len(aArquivos))
Local xArqJson
Local oJson
Local nTotNCM := 0
Local nK
Local cAtributo
Local cNcmIni
Local cAtribIni
local cFiles := ""
Private lCondTe 
Private EKGFilial
Private EKHFilial

//Tratamento de erro para as Threads filha
SysErrorBlock({|oErr| JobIncRegua(cIDPai,,,,,,oErr:description) })

For nI := 1 To Len(aArquivos)
	cFiles += aArquivos[nI] + " - "
	aObjJson[nI] := EasyMemoRead(aArquivos[nI])
	oJson := JsonObject():New()
	xArqJson := oJson:FromJson(aObjJson[nI])
	If ValType(xArqJson) == "U"
		aObjJson[nI] := oJson:GetJsonObject("listaNcm")
		nTotNCM += Len(aObjJson[nI])
		FreeObj(oJson)
	Else
		UserException(STR0009 + " ("+aArquivos[nI]+"). "+STR0010 + xArqJson) //"Houve uma falha ao ler o arquivo JSON###"Erro: "
	EndIf
Next

if(ExistFunc("FWMonitorMsg"),FWMonitorMsg( "Processando os arquivos: " + substr( alltrim(cFiles), 1, len(alltrim(cFiles)) - 1 ) ) ,nil)

RpcSetType(3)
RpcSetEnv(cEmp,cFil)

//Informa a quantidade de NCM pra Thread pai iniciar o Progress
JobInicio(cID,nTotNCM)

EKG->(dbSetOrder(1))//EKG_FILIAL, EKG_NCM, EKG_COD_I
EKH->(dbSetOrder(1))//EKH_FILIAL, EKH_NCM, EKH_COD_I, EKH_CODDOM
lCondTe := EKG->(FieldPos("EKG_CONDTE")) > 0
EKGFilial := xFilial('EKG')
EKHFilial := xFilial('EKH')

For nK := 1 To Len(aObjJson)
	aJson := aObjJson[nK]
	For nI := 1 To Len(aJson)
        cAtributo:=''
		oAtributo := aJson[nI]
		cNcm := AvKey(StrTran(oAtributo:getJsonText('codigoNcm'),'.',''),"EKG_NCM")
		aNcmAtrib := oAtributo:getJsonObject('listaAtributos')
		IIF(Empty(cNcmIni),cNcmIni := cNcm,)
		nY := 1
		While nY <= Len(aNcmAtrib)
			oNcmDados 	:= aNcmAtrib[nY]
			cAtributo := AvKey(oNcmDados:GetJsonText('codigo'),"EKG_COD_I")
			cAtrPai   := oNcmDados:GetJsonText('atributoPai')
			cAtrPai   := if(cAtrPai=='null','',cAtrPai)
			IIF(Empty(cAtribIni),cAtribIni := cAtributo,)

            lInsere := !EKG->(dbSeek(EKGFilial + cNcm + PADR(cAtributo,AVSX3("EKG_COD_I",AV_TAMANHO)) + iif(lCondTe,PADR(cAtrPai,AVSX3("EKG_CONDTE",AV_TAMANHO)),'')  ))			            
			ny++
            gravaEKG(lInsere,oNcmDados,cNcm,cAtributo,cAtrPai)			
		End
		JobIncRegua(cIdPai) //Informa Thread pai que o registro foi processado
	Next
	JobIncRegua(cIdPai,nFilha,cNcmIni,cAtribIni,cNcm,cAtributo)
	cNcmIni 	:= ""
	cAtribIni:= ""
Next
RpcClearEnv()
JobFim(cID) //Informa Thread pai que o processo foi finalizado

Return lRet

/*
Programa   : gravaEKG
Objetivo   : Gravar a tabela EKG o registro principal e o registro condicionante
Parâmetros : lInsere - .t. insere um registro, .f. altera
			 oNcmDados - objeto com os dados a serem inseridos ou alterados
			 cNcm - ncm a ser inserido			 
			 cAtributo -  indica o atributo principal
             cAtrCondte - indica o atributo condionante
Retorno    : lRet - sempre retorna .t.
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function gravaEKG(lInsere,oNcmDados,cNcm,cAtributo,cAtrCondte)
Local lRet := .T.
Local xOrgao
Local xDominio
Local xObjetivos
Local xComposto
local cMultVal
Local cCodObj 	:= ''
Local cOrgao	:= ''
Local oDominio
Local nObj
Local nOrg
Local nDom
Local nComp
Local cForma
Local lAddComp
Local oAttComp
Local cAtribComp

            xOrgao		:= oNcmDados:getJsonObject('orgaos')
			xDominio	:= oNcmDados:getJsonObject('dominio')
			xObjetivos	:= oNcmDados:getJsonObject('objetivos')
			cMultVal    := if(oNcmDados:getJsonText('multivalorado')=="true", cSim, cNao)

            RecLock('EKG',lInsere)
			
				EKG->EKG_FILIAL := EKGFilial
				EKG->EKG_NCM	:= cNcm
				EKG->EKG_COD_I	:= cAtributo
				if lCondTe
				   EKG->EKG_MULTVA := cMultVal
				EndIf   
				EKG->EKG_NOME	:= GetJsonCpo(oNcmDados,'nomeApresentacao') //DecodeUTF8(oNcmDados:GetJsonText('nomeApresentacao'))
				//Objetivos
				cCodObj := ''
				if xObjetivos != nil
					For nObj := 1 To Len(xObjetivos)
						cCodObj += GetJsonCpo(xObjetivos[nObj],'codigo')//xObjetivos[nObj]:GetJsonText('codigo')
						If nObj < Len(xObjetivos)
							cCodObj += ';'
						EndIf
					Next
				EndIf	
				EKG->EKG_CODOBJ:= cCodObj
				EKG->EKG_ORIENT:= GetJsonCpo(oNcmDados,'orientacaoPreenchimento')//DecodeUTF8(oNcmDados:GetJsonText('orientacaoPreenchimento'))
				cForma := GetJsonCpo(oNcmDados,'formaPreenchimentoAtributo')
				If Empty(cForma)
					cForma := GetJsonCpo(oNcmDados,'formaPreenchimento')//DecodeUTF8(oNcmDados:GetJsonText('formaPreenchimento'))
				EndIf
				EKG->EKG_FORMA	:= cForma
				EKG->EKG_MODALI:= GetModalidade(oNcmDados:GetJsonText('modalidade'))
				EKG->EKG_OBRIGA:= IIF(Lower(oNcmDados:GetJsonText('obrigatorio'))=='true','1','2')
				EKG->EKG_INIVIG:= SToD(StrTran(oNcmDados:GetJsonText('dataInicioVigencia'),'-',''))
				If !Empty(oNcmDados:GetJsonText('dataFimVigencia'))
					EKG->EKG_FIMVIG := SToD(StrTran(oNcmDados:GetJsonText('dataFimVigencia'),'-',''))
				Else
					EKG->EKG_FIMVIG := CToD("  /  /    ")
				EndIf
				//Orgao
				cOrgao := ''
				if xOrgao != nil
					For nOrg := 1 To Len(xOrgao)
						cOrgao += xOrgao[nOrg]
						If nOrg < Len(xOrgao)
							cOrgao += ';'
						EndIf
					Next
				EndIf	
				EKG->EKG_ORGAO := cOrgao
			
				EKG->EKG_TAMAXI := if(oNcmDados:GetJsonText('tamanhoMaximo')=='null',0,Val(oNcmDados:GetJsonText('tamanhoMaximo')))
				EKG->EKG_DECATR := if(oNcmDados:GetJsonText('casasDecimais')=='null',0,Val(oNcmDados:GetJsonText('casasDecimais')))
				EKG->EKG_INFADC := GetJsonCpo(oNcmDados,'informacaoAdicional') //DecodeUTF8(oNcmDados:GetJsonText('informacaoAdicional'))
				EKG->EKG_BRIDAT := GetJsonCpo(oNcmDados,'brid') //DecodeUTF8(oNcmDados:GetJsonText('brid'))
				EKG->EKG_MSBLQL := "2" //Não Bloqueado
				//Dominios
				If ValType(xDominio) != "U"
					For nDom := 1 To Len(xDominio)
						oDominio := xDominio[nDom]						
						cCodDom := PADR(oDominio:GetJsonText('codigo'),AVSX3('EKH_CODDOM',AV_TAMANHO))
						lInsere :=  EKH->(!dbSeek(EKHFilial + EKG->EKG_NCM + EKG->EKG_COD_I + cCodDom))	
						RecLock("EKH",lInsere)
						EKH->EKH_FILIAL := EKHFilial
						EKH->EKH_NCM 	:= EKG->EKG_NCM
						EKH->EKH_COD_I	:= EKG->EKG_COD_I
						EKH->EKH_CODDOM:= cCodDom
						EKH->EKH_DESCRE:= DecodeUTF8(oDominio:GetJsonText('descricao'))
						EKH->EKH_MSBLQL:= "2" //Liberado
						EKH->(MsUnlock())
					Next
				EndIf 
				if !empty(cAtrCondte)
				   EKG->EKG_CONDTE := cAtrCondte 
				   EKG->EKG_CONDIC := oNcmDados:getJsonText('condicao')				   
				EndIf
			EKG->(MsUnlock())

			//TRATAMENTO PARA ATRIBUTOS COMPOSTOS - "formaPreenchimento" : "COMPOSTO"
			If cForma == ATT_COMPOSTO
				xComposto := oNcmDados:getJsonObject('listaSubatributos') //Lista de Sub-Atributos de um Atributo Composto
				if xComposto != nil
					For nComp := 1 To Len(xComposto)
						oAttComp	:= xComposto[nComp]
						cAtribComp	:= AvKey(oAttComp:GetJsonText('codigo'),"EKG_COD_I")

						lAddComp := !EKG->(dbSeek(EKGFilial + cNcm + PADR(cAtribComp,AVSX3("EKG_COD_I",AV_TAMANHO)) + PADR(cAtributo,AVSX3("EKG_CONDTE",AV_TAMANHO))))
						gravaEKG(lAddComp, oAttComp, cNcm, cAtribComp, cAtributo)
					Next
				EndIf
			EndIf

return lRet


/*
Programa   : JobInicio, JobIncRegua e JobFim
Objetivo   : Funções que fazem a comunicação com a Thread Pai
Parâmetros : cID		- Código da Thread
				 nRet 	- Informa a quantidade de NCMs a serem processadas para informar a barra de progresso
				 cError	- Informa erro para a Thread Pai
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function JobInicio(cID,nRet)
While !killapp() .And. !IPCGo(cID,nRet)
    Sleep(100)
End
Return .T.

Static Function JobIncRegua(cID,nFilha,cIniFim,cAtribFim,cNcm,cAtributo,cError)
While !killapp() .And. !IPCGo(cID,nFilha,cIniFim,cAtribFim,cNcm,cAtributo,cError)
    Sleep(100)
End
Return .T.

Static Function JobFim(cID)
While !killapp() .And. !IPCGo(cID)
    Sleep(100)
End
Return .T.


/*
Programa   : GetJsonCpo
Objetivo   : Retornar uma Tag do Json
Parâmetros : oObj		- Objeto Json
				 cTag 	- Tag da informação a ser obtida
Retorno    : cInfo - Informação a ser gravada no campo
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function GetJsonCpo(oObj,cTag)
Local cRet
Local cInfo

cInfo := oObj:GetJsonText(cTag)
If Alltrim(cInfo) == 'null' .Or. Empty(cInfo)
	cRet := " "
Else
	cRet := DecodeUTF8(cInfo)
EndIf
Return cRet

/*
Programa   : getJsonFiles
Objetivo   : Verifica na pasta os arquivos json que serão integrados
Parâmetros : cDirComex 	- Caminho principal no servidor
				 cDir 		- Pasta onde deve conter os arquivos json no servidor
Retorno    : aFiles - Retorna os arquivos json encontrados no caminho especificado
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function getJsonFiles(cDirComex,cDir)
Local i, aDir, aFiles := {}

aDir := Directory(cDir+"/*.json")
For i := 1 To Len(aDir)
	If aDir[i][1] <> "." .AND. aDir[i][1] <> ".."
		If At(".JSON",upper(aDir[i][1])) > 0
			aAdd(aFiles,cDir+aDir[i][1])
		EndIf
	EndIf
Next i

Return aSort(aFiles)

/*
Programa   : UnzipJson
Objetivo   : Desconpacta um arquivo .Zip
Parâmetros : cDirComex 	- Caminho principal no servidor
				 cCaminho	- Pasta onde deve conter os arquivos json no servidor
				 cMsgRet		- retorna uma mensagem caso ocorra falha ao descompactar o arquivo .Zip
Retorno    : lRet - Retorna se descompactou com sucesso ou não
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function UnzipJson(cDirComex,cCaminho,cMsgRet)
Local lRet := .T.
Local nRetZip
Local cArquivo
Local i:=0
Local aArquivos := Directory(cCaminho + '*.zip')
for i:=1 to len(aArquivos)
    cArquivo := cCaminho+aArquivos[i][1]
	nRetZip := FUnZip(cArquivo,cCaminho)
	If nRetZip != 0
		cMsgRet := STR0011 + ' ' + cArquivo //"Falha ao descompactar o arquivo."
		lRet := .F.
		exit
	EndIf
next

Return lRet


/*
Programa   : TrataArqs
Objetivo   : Baixa arquivo pelo javascript e descompacta o retorno pro protheus processar
Parâmetros : cMsgRet		- retorna uma mensagem caso ocorra falha na criação da pasta quando ela não existir
				 cDirComex 	- Caminho principal no servidor
				 cCaminho	- Pasta onde deve conter os arquivos json no servidor
Retorno    : lRet - Retorna se tudo foi efetuado com sucesso
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function TrataArqs(cMsgRet,cDirComex,cCaminho,cUrl)
Local lRet := .T.
MsProcTxt(STR0013) //"Iniciando o download do arquivo de atributos... "
lRet :=  BaixaJson(@cMsgRet,cCaminho,cUrl)
If lRet
	//Extrai os arquivos compactados
	MsProcTxt(STR0014)//"Descompactando arquivos baixados... "
	lRet := UnzipJson(cDirComex,cCaminho,@cMsgRet)
EndIf

Return lRet

/*
Programa   : ExisteComex
Objetivo   : Verifica a estrutuda de pastas necessárias para o correto funcionamento da rotina
Parâmetros : cDirComex 	- Caminho principal no servidor
				 cDir			- Pasta onde deve conter os arquivos json no servidor
				 cMsgRet		- retorna uma mensagem caso ocorra falha na criação da pasta quando ela não existir
Retorno    : lRet - Retorna se a estrutura de pastas esntão corretas
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function ExisteComex(cDirComex,cDir,cMsgRet)
Local lRet := .T.
Begin Sequence
//Verifica se exsite a pasta comex dentro da Protheus_data
If !ExistDir(cDirComex)
	If MakeDir(cDirComex) <> 0
		cMsgRet := STR0015 + cValToChar( FError() ) //"Não foi possível criar os diretórios necessários para a geração do arquivo de integração. Erro: "
		lRet := .F.
		Break
	EndIf
EndIf

If !ExistDir(cDir)
	If MakeDir(cDir) <> 0
		cMsgRet := STR0015 + cValToChar( FError() ) //"Não foi possível criar os diretórios necessários para a geração do arquivo de integração. Erro: "
		lRet := .F.
		Break
	EndIf
EndIf
End Sequence
Return lRet

/*
Programa   : GetModalidade
Objetivo   : Recebe a modalidade enviada pelo Json e retorna o código a ser gravado na tabela
Parâmetros : cModalidade - Nome da Modalidade
Retorno    : cRet - Retorna o código da modalidade (1=Importação; 2=Exportação; 3=Ambos)
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function GetModalidade(cModalidade)
Local cRet
cModalidade := DecodeUTF8(cModalidade)
If Upper(cModalidade) == 'EXPORTAÇÃO'
	cRet := '2'
ElseIf Upper(cModalidade) == 'IMPORTAÇÃO'
	cRet := '1'
Else
	cRet := '3'
EndIf
Return cRet

/*
Programa   : EasyMemoRead
Objetivo   : Faz a leitura do arquivo do disco para a memória
Parâmetros : cFile - Arquivo a ser lido
Retorno    : cText - Retorna o conteúdo do arquivo no formato texto
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function EasyMemoRead(cFile)
Local cText := ""
Local nHdl  := FOpen(cFile,64)
 
If nHDL >= 0
    FRead(nHdl,@cText,1024*8192)
    FClose(nHdl)
EndIf
 
Return cText

/*
Programa   : LimpaPasta
Objetivo   : Exclui todos os arquivos da pasta informada
Parâmetros : cCaminho - Caminho que devem ser excluídos os arquivos
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function LimpaPasta(cCaminho)
AEval(Directory(cCaminho+"\*.*"), { |aFile| FErase(cCaminho+"\"+aFile[1]) })
Return

/*

/*
Programa   : AtuBloqAtt
Objetivo   : Realizar um update bloqueando os registros que não foram processados pelo arquivo
Parâmetros : cTab - Tabela que terá os rgistros bloqueados
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 29/04/2020
Obs.       :
*/
Static Function AtuBloqAtt(cTab)
Local cQuery
cQuery := " UPDATE  " + RetSqlName(cTab) + " "
cQuery += " SET " + cTab+"_MSBLQL = '1' "
cQuery += " WHERE  " + cTab+"_FILIAL = '" + xFilial(cTab) + "' "
cQuery += " AND " + cTab + "_MSBLQL = '2' AND D_E_L_E_T_ = ' ' "

If TcSQLExec(cQuery) < 0
	UserException("TCSQLError() " + TCSQLError())
EndIf

Return

/*
Programa   : BaixaJson
Objetivo   : Efetuar o acesso ao portal unico, baixar o arquivo json, organizar e efetuar a quebra em arquivos menores. Será gerado um .zip destes arquivos para o Protheus Processar.
Parâmetros : -
Retorno    : -
Autor      : AAF - Alessandro Alves Ferreira
Data/Hora  : 04/05/2020
Obs.       :
*/
Static Function BaixaJson(cMsgRet,cCaminho,cUrl)
Local oJS
Local cLib
Local lRet 	      := .T.
Local nRemoteType	:= GetRemoteType( @cLib )
Local cFetch      := iif( nRemoteType <> 1 .and. "HTML" $ cLib , "advplFetch" , "fetch" )
Local cUrlApi := cUrl + '/cadatributos/api'
Local cUrlDwn := cUrlApi + '/atributo-ncm/download/json'
Local cUrlRedirect := cUrlDwn + '?perfil=PUBLICO'

 /* I M P O R T A N T E
Para executar no navegador tem que entrar no domínio https://portalunico.siscomex.gov.br/cadatributos/api e só aí entrar no f12 para executar o javascript
Para verificar se houve redirecionamento no site do portal único, colocar um break point aqui nesta rotina e executar no debug a seguinte chamada
httpget('https://portalunico.siscomex.gov.br/cadatributos/api/atributo-ncm/download/json')
 */   
	oJS := EasyJS():New()
	oJS:cUrl := cUrlApi
	oJS:setTimeOut(30)
	oJS:AddLib(TEGetJSZip())
	lRet := oJS:Activate(.T.)
		
    if lRet
      begincontent var cscript
			function arrayBufferToBase64(buffer) {
				var binary = '';
				var bytes = new Uint8Array(buffer);
				var len = bytes.byteLength;
				for (var i = 0; i < len; i++) {
					binary += String.fromCharCod(bytes[i]);
				}
				return btoa(binary);
			}

	        function dwnzip(a){				  
			   return a.blob();
			};

			function openTxt(zip){
               return Object.values(zip.files)[0].async('string')
			};

			function retornaZip(base64zip){			
			   let nArq = 0	
			   base64zip.forEach((n)=>{
				  nArq++
			      n.then((base64) => {retAdvplChunk(base64)});					
			   })		
			}

			function geraZip(obj){
			return new Promise((accept,reject)=>{
                    let nQtdNcms = 100;
					let nro_arquivos = Math.trunc(obj.listaNcm.length / nQtdNcms) + (obj.listaNcm.length / nQtdNcms == Math.trunc(obj.listaNcm.length / nQtdNcms) ? 0 : 1);
					let partes = Array.from(Array(nro_arquivos).keys());//Math.min(obj.listaNcm.length,100)
					let zip_result
					let zipArray = new Array()

					partes.forEach((n)=>{		
						zip_result = new JSZip();				
						zip_result.file("parte_"+(("00000").substring((n+1).toString().length)+(n+1))+".json",JSON.stringify({ listaNcm : obj.listaNcm.slice(n*nQtdNcms, Math.min((n+1)*nQtdNcms,obj.listaNcm.length)) })); 																	                                  
						zipArray.push( zip_result.generateAsync({type:"base64", compression: "DEFLATE"}))
				})
				accept(zipArray);
			}
			)
			}	


			async function getTxt(text){
				var finalArray=new Array();
					let zipArray=new Array();
					let xArray=new Array();
					let obj = JSON.parse(text) //parse do texto como JSON
					//Ordena a lista de NCM em ordem crescente, cada lista de atributos em ordem crescente
					//e filtra as ncms que nao possuem atributos 


					obj.listaNcm = obj.listaNcm.filter((a)=>{
						a.listaAtributos.forEach((at)=>{                            
{
							at.condicionados.forEach((ac)=>{
                                   if (ac.atributo) {
                                       ac.atributo['atributoPai'] = at['codigo']
									   ac.atributo['condicao'] = ac.condicao
                                       a.listaAtributos.push(ac.atributo)
                                     }
                                  } 
								)							 
							}

							if (at.condicionados) {
								at.condicionados.forEach((acn)=>{
									if (acn.atributo.dominio) {
									    acn.atributo.dominio.sort((a, b) =>{return a.codigo.localeCompare(b.codigo)})                                 
									}
							    } )             
							}

                             if(at.dominio){
								at.dominio.sort((a, b) =>{return a.codigo.localeCompare(b.codigo)})
							 }									 							 							 							 							 							 
						})
						a.listaAtributos.sort((a, b) =>{return a.codigo.localeCompare(b.codigo)});
						
						return a.listaAtributos.length > 0;
					}).sort((a, b)=>{return a.codigoNcm.localeCompare(b.codigoNcm)})										
					zipArray = await geraZip(obj)									
					return zipArray;							
			};

		%Exp:cFetch%('%Exp:cUrlRedirect%').then(
				(a) => {return dwnzip(a)}) //dowload do binário do zip
				.then(
				(blob)=> {return JSZip.loadAsync(blob)}) //interpreta o zip
				.then(                 
				(zip) => {return openTxt(zip)}) //abre o primeiro arquivo como texto
				.then( 
				(text) => { return getTxt(text) })                                    
			    .then((base64zip)=>{retornaZip(base64zip) })
			.catch((e) => { retAdvplError(e) })			
		endcontent			
		oJS:runJSSync(cScript,{|x| gravaAtributos(x,cCaminho) },{|e| lRet := .F.,cMsgRet := STR0016 + e}) //"Falha no download do arquivo no portal único: "
	endif

Return lRet 

/*
Programa   : gravaAtributos
Objetivo   : Pega o array com os vários arquivos zip e grava o arquivo físico
Parâmetros : -cAtributos: contém a string em base64 do arqivo zip
             -cCaminho  : caminho onde será gravado o arquivo
Retorno    : -
Autor      : Maurício Frison
Data/Hora  : 12/12/2022
Obs.       :
*/
Static Function gravaAtributos(cAtributos,cCaminho)
Local nArq
    while FILE(cCaminho + 'atributos'+alltrim(str(nArq:=Random(0,1000000)))+'.zip') ; Enddo 
    h := fcreate(cCaminho + 'atributos'+allTrim(str(nArq))+'.zip')
    fwrite(h,Decode64(cAtributos))
	fclose(h)
return


