#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//Static cCaminhoA808	:= "C:\warroom\Ambiente\web" // Caminho do protheus data
Static	cBarA806B		:=  IF (IsSrvUnix(),"/","\")
Static cRootA806B		:= GetSrvProfString( "RootPath" , "" )

/*/{Protheus.doc} PRAA806B

Responsável pelo upload de arquivos para processamento
Se usar o smartclient html configurar o caminho da instalação do protheus_data e instalar o smartclienthtml nesta pasta
@author siegklenes.beulke
@since 03/03/2015
@version 1.0
@example
PRAA806B()
/*/
Function PRAA806B()
Local cRet
Private cAliasZZ2 := GetNextAlias()
Private cAliasZZ3 := GetNextAlias()
Private cRetFile := ""
MontaStru()

cRet := GetSParam("DIRETORIO_INTEGRACAO_DOCUMENTOS_UPLOAD",'','',.T.)
If Empty(cRet)
	Return
EndIf

FwExecView("Upload de documentos","PRAA806B",MODEL_OPERATION_UPDATE,,{||.T.}) 

delTabTmp(cAliasZZ2)
delTabTmp(cAliasZZ3)


Return

Static Function ModelDef()
	Local oModel  	 := Nil
	Local oStructZZ2 := FWFormModelStruct():New()
	Local oStructZZ3 := FWFormModelStruct():New()
	Local bCommit    := {|oModel|A806BBCOMMIT(oModel)}
	Local bCancel    := {|oModel|A806BBCANCEL(oModel)}
	
	oStructZZ2:AddTable(cAliasZZ2, {'ZZ2_RESERV'},"Registro de documentos")
	oStructZZ2:AddIndex(1,'01','ZZ2_RESERV','Indice 1','','',.T.)
	
	oStructZZ2:AddField("Reserva"		, "Código da reserva", "ZZ2_RESERV", "C",  30, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ2:AddField("Tipo"			, "Tipo da reserva"	, "ZZ2_DSRESR", "C",  20, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ2:AddField("Beneficiário"	, "Nome beneficiário", "ZZ2_DSBENE", "C",  67, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ2:AddField("Arquivo"		, "Selecione o arquivo", "ZZ2_ARQ", "C",  2000, 0, {||ADDARQUIVO()/*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ2:AddField("Tipo Documento","Tipo Documento"	 , "ZZ2_TPDOC", "C",  10 ,0  ,{||.T.},{||.F.},Nil,.T.,/**/,.F.,.F.,.F.)
	
	oStructZZ3:AddTable(cAliasZZ3, {'CVALTOCHAR(ZZ3_DUID)'},"Documentos")
	oStructZZ3:AddIndex(1,'01','CVALTOCHAR(ZZ3_DUID)','Indice 1','','',.T.)
	
	oStructZZ3:AddField("Reserva"			, "Código da reserva", "ZZ3_RESERV", "C",  30, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ3:AddField("Tipo Documento","Tipo Documento"		, "ZZ3_TPDOC", "C",  10 ,0  ,{||.T.},{||.T.},Nil,.T.,/**/,.F.,.F.,.F.)
	oStructZZ3:AddField("Seq"				, "Seq do doc"		, "ZZ3_DUID"	, "N",  10, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ3:AddField("Arquivo"			, "Nome do Arquivo"	, "ZZ3_ARQ"	, "C",  100, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ3:AddField("ArquivoOri"		, "ArquivoOri"	   , "ZZ3_ARQORI"	, "C",  100, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ3:AddField("Data upload"		, "Data do upload"	, "ZZ3_DTUP"	, "C",  16, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ3:AddField("Processado"		, "Processado"		, "ZZ3_PROCES", "L",  01, 0, {||.T./*bValid*/},{||.T./*bWhen*/},{.T.,.F.}  ,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ3:AddField("Ocorrência"		, "Ocorrência"		, "ZZ3_DSMSG"	, "C",  255, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ3:AddField("ArqTemp"			, "ArqTemp"			, "ZZ3_TMPARQ", "C",  2000, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oModel := MPFormModel():New('PRAA806B', /*bPre*/, /*bPost*/, bCommit, bCancel)
	oModel:SetDescription("Registro de documentos")
	
	oModel:AddFields('PRAA806B_ZZ2', Nil, oStructZZ2,,,)
	oModel:GetModel('PRAA806B_ZZ2'):SetDescription("Registro de documentos")
	
	oModel:AddGrid('PRAA806B_ZZ3', 'PRAA806B_ZZ2', oStructZZ3,,,,,{|oModel|A806BDOC(oModel)})
	oModel:GetModel('PRAA806B_ZZ3'):SetDescription("Documentos")
	oModel:GetModel('PRAA806B_ZZ3'):SetOptional(.T.)
	
	oModel:SetPrimaryKey({'ZZ2_RESERV'})
   
	oModel:SetVldActivate({|oModel| A806BACTIVE(oModel)})
Return oModel

Function A806BACTIVE()
	If Empty((cAliasZZ2)->ZZ2_RESID)
		Help(,,'HELP',,'Obrigatório informar uma reserva válida',1,0)
		Return .F.
	EndIf
	
Return .T.

Static Function ViewDef()

	Local oModel := FWLoadModel('PRAA806B')
	Local oStructZZ2	:= FWFormViewStruct():New()
	Local oStructZZ3	:= FWFormViewStruct():New()
	Local oView := Nil
	
	oStructZZ2:AddFolder('01','Geral')
	
	oStructZZ2:AddGroup("Reserva", "Reserva", '01', 2)
	oStructZZ2:AddGroup("Arq", "Selecione o arquivo", '01', 2)
	
	oStructZZ2:AddField("ZZ2_RESERV","01","Reserva"		,"Código da reserva"		,/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ2:AddField("ZZ2_DSRESR","02","Tipo"			,"Tipo da reserva"		,/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ2:AddField("ZZ2_DSBENE","03","Beneficiário"	,"Nome beneficiário"		,/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	oStructZZ2:AddField("ZZ2_ARQ","05","Arquivo"			,"Selecione o arquivo"	,/*aHelp*/,"C",/*PIC*/,/*BPIC*/,'SZOFIL'/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/,"Arq"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ2:AddField("ZZ2_TPDOC","04","Tipo de documento","Tipo de documento"	,/*aHelp*/,"C",/*PIC*/,/*BPIC*/,'SARATD'/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/,"Arq"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	oStructZZ3:AddField("ZZ3_TPDOC","01","Tipo de documento","Tipo de documento"	,/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ3:AddField("ZZ3_ARQ"	,"02","Arquivo"		,"Nome do Arquivo",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ3:AddField("ZZ3_DTUP"	,"03","Data upload"	,"Data do upload"	,/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ3:AddField("ZZ3_PROCES","04","Processado"	,"Processado"		,/*aHelp*/,"L",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ3:AddField("ZZ3_DSMSG","05","Ocorrência"	,"Ocorrência"		,/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "PRAA806B_ZZ2" , oStructZZ2, /*cLinkID*/ )
	oView:AddGrid ( "PRAA806B_ZZ3" , oStructZZ3, /*cLinkID*/ )
	
	oView:CreateHorizontalBox( "MASTER" , 60,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( "DETAIL" , 40,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:SetOwnerView("PRAA806B_ZZ2","MASTER")
	oView:SetOwnerView("PRAA806B_ZZ3","DETAIL")
	oView:SetNoInsertLine("PRAA806B_ZZ3")
Return oView


Static Function MontaStru()
	Static aCamposZZ2 :={{"ZZ2_RESID", "N",  10, 0},;
						{"ZZ2_RESERV", "C",  30,0},;
						{"ZZ2_DSRESR", "C",  50, 0},;
						{"ZZ2_DSBENE", "C",  67, 0},;
						{"ZZ2_TPDOC" , "C",  10, 0},;
						{"ZZ2_DCTPES", "C",  01 ,0},;
						{"ZZ2_DENTID", "C",  30, 0},;
						{"ZZ2_ARQ", "C",  2000 ,0 }}
						
	Static aCamposZZ3 :={{"ZZ3_RESERV"	,"C",30,00},;
							{"ZZ3_DUID"	,"N",10,00},;
							{"ZZ3_ARQ"		,"C",100,00},;
							{"ZZ3_ARQORI"	,"C",100,00},;
							{"ZZ3_DTUP"	,"C",16,00},;
							{"ZZ3_PROCES"	,"L",01,00},;
							{"ZZ3_TPDOC" , "C",10, 0},;
							{"ZZ3_DSMSG"	,"C",255,00}}
	

	cAliasZZ2 := CriaTabTmp(aCamposZZ2,{'ZZ2_RESERV'},cAliasZZ2)
	cAliasZZ3 := CriaTabTmp(aCamposZZ3,{'cValToChar(ZZ3_DUID)','ZZ3_RESERV+CVALTOCHAR(ZZ3_DUID)'},cAliasZZ3)
	
//	MockUp()
	Carregar()
	
Return

Static Function Carregar()
	Local cQuery
	Local cAlTpDoc
	Local cFiltro
	
	RecLock(cAliasZZ2,.T.)
	If Empty(MV_PAR01) .And. !Empty((cAliasZZ4)->ZZ4_RESID)
		cFiltro := " res_id = " + cValTochar((cAliasZZ4)->ZZ4_RESID)
	ElseIf !Empty(MV_PAR01)
		cFiltro := " res_numero = '" + MV_PAR01 + "'"
	Else
		(cAliasZZ2)->ZZ2_RESID := 0
		(cAliasZZ2)->(MsUnLock())
		Return
	EndIf
	
	(cAliasZZ2)->ZZ2_DCTPES := 'E'
//	(cAliasZZ2)->ZZ2_DENTID := (cAliasZZ4)->ZZ4_DENTID 
	
	cQuery := " SELECT a.res_id, a.res_numero, b.cli_cgc, b.cli_nome, c.res_tipo_descricao tpdescr  "
	cQuery += " FROM tab_reserva a"
	cQuery += " left join tab_clientes b"
	cQuery += " on b.cli_id = a.cli_id " 
	cQuery += " LEFT JOIN tab_reserva_tipo c "
	cQuery += "  ON c.res_tipo = a.res_tipo "
	cQuery += "  where" + cFiltro
	
	cAlTpDoc := GetNextAlias()
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlTpDoc, .F., .T.)
	
	(cAliasZZ2)->ZZ2_RESID  := (cAlTpDoc)->res_id
	(cAliasZZ2)->ZZ2_RESERV := (cAlTpDoc)->res_numero
	(cAliasZZ2)->ZZ2_DSRESR := (cAlTpDoc)->tpdescr
	(cAliasZZ2)->ZZ2_DSBENE := AllTrim((cAlTpDoc)->cli_cgc+' - '+(cAlTpDoc)->cli_nome)
	(cAlTpDoc)->(dbCloseArea())
	(cAliasZZ2)->ZZ2_TPDOC  := "NF"
	
	(cAliasZZ2)->(MsUnlock())
	
Return

Function A806BDOC(oModel)
Local cQuery
Local cAlTpDoc := GetNextAlias()
Local aRet := {}
Local nRec := 1
Local aStruc := oModel:GetStruct()//Struct da tabela
cQuery := "select CONVERT(VARCHAR, du_dt_registro , 103) + ' - ' + CONVERT(VARCHAR, du_dt_registro , 108) ZZ3_DTUP, " +;
				" du_id ZZ3_DUID, doc_id ZZ3_TPDOC, du_nome_arquivo ZZ3_ARQ, null as ZZ3_ARQORI, du_status ZZ3_PROCES, du_status_ocorrencia ZZ3_DSMSG "+;
	 			"from tab_documentos_upload where res_id = " + cValTochar((cAliasZZ2)->ZZ2_RESID) 
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlTpDoc, .F., .T.)
	While !(cAlTpDoc)->(Eof())
		AAdd(aRet,{nRec, {(cAliasZZ2)->ZZ2_RESERV,(cAlTpDoc)->ZZ3_TPDOC,(cAlTpDoc)->ZZ3_DUID, (cAlTpDoc)->ZZ3_ARQ,(cAlTpDoc)->ZZ3_ARQORI,(cAlTpDoc)->ZZ3_DTUP,If ((cAlTpDoc)->ZZ3_PROCES == 'S',.T.,.F.),(cAlTpDoc)->ZZ3_DSMSG,''}})
		RecLock(cAliasZZ3,.T.)
		(cAliasZZ3)->ZZ3_DUID := (cAlTpDoc)->ZZ3_DUID
		(cAlTpDoc)->(MsUnLock())
		nRec++
		(cAlTpDoc)->(dbSkip())
	EndDo
	
	(cAlTpDoc)->(dbclosearea())
	If Empty(aRet)
		aRet := {{0,&("{" + Replicate(",", Len(aStruc:AFIELDS)-1) + "}")}}
	EndIf
Return aRet

Static Function MockUp()
	RecLock(cAliasZZ2,.T.)
	(cAliasZZ2)->ZZ2_RESERV := "ABCD123456"
	(cAliasZZ2)->ZZ2_DSRESR := "Usuário"
	(cAliasZZ2)->ZZ2_DSBENE := "Joãozinho da silva"
	(cAliasZZ2)->(MsUnlock())
	
	RecLock(cAliasZZ3,.T.)
	(cAliasZZ3)->ZZ3_RESERV := "ABCD123456"
	(cAliasZZ3)->ZZ3_SEQARQ := "001"
	(cAliasZZ3)->ZZ3_ARQ    := "Arquivo1.xml"
	(cAliasZZ3)->ZZ3_ARQORI := "Arquivo1.xml"
	(cAliasZZ3)->ZZ3_DTUP   := "10/03/2015 11:12"
	(cAliasZZ3)->ZZ3_PROCES := .T.
	(cAliasZZ3)->ZZ3_DSMSG  := "Ok"
	(cAliasZZ3)->(MsUnlock())
	
	RecLock(cAliasZZ3,.T.)
	(cAliasZZ3)->ZZ3_RESERV := "ABCD123456"
	(cAliasZZ3)->ZZ3_SEQARQ := "002"
	(cAliasZZ3)->ZZ3_ARQ    := "Arquivo2.xml"
	(cAliasZZ3)->ZZ3_ARQORI := "Arquivo2.xml"
	(cAliasZZ3)->ZZ3_DTUP   := "09/03/2015 11:12"
	(cAliasZZ3)->ZZ3_PROCES := .F.
	(cAliasZZ3)->ZZ3_DSMSG  := "aguardando processamento"
	(cAliasZZ3)->(MsUnlock())
Return

Function sZoomFile()
	Local lRet := .F.
	cRetFile := cGetFile( '*.*' ,'', 1,'' , .F., nOR(GETF_MULTISELECT, GETF_LOCALHARD, GETF_LOCALFLOPPY ),.F., .T. )
	If !Empty(cRetFile)
		lRet := .T.
	EndIf
Return lRet


/*/{Protheus.doc} ADDARQUIVO
	Efetua o upload do arquivo do remote para o servidor em um caminho determinado
@author siegklenes.beulke
@since 03/03/2015
@version 1.0
@example
ADDARQUIVO()
/*/
Static Function ADDARQUIVO()
	Local lRet := .T.
	Local nStatus
	Local oModel := FWModelActive()
	Local cArquivo := AllTrim(oModel:GetValue('PRAA806B_ZZ2','ZZ2_ARQ'))
	Local nBar 
	Local cDestino		
	
	If !Empty(cArquivo)
		nBar := Rat(cBarA806B,cArquivo)
		cDestino := SubStr(cArquivo,nBar)
		InsereArq(cdestino,cArquivo)
		oModel:LoadValue('PRAA806B_ZZ2','ZZ2_ARQ', '')
        
        If ExistTemplate("PRAARQUIVO")
            oModel = ExecTemplate("PRAARQUIVO",.F.,.F.,{oModel,cArquivo})
        Endif
	EndIf
	
Return lRet

/*/{Protheus.doc} InsereArq
	Insere o registro do arquivo no model
@author siegklenes.beulke
@since 03/03/2015
@version 1.0
@param cArq, character, Nome do arquivo
@param cArqTemp, character, Arquivo temporário, removido no cancelamento ou movido na confirmação
@example
InsereArq('cArq.txt')
/*/
Static Function InsereArq(cArq,cArqTemp)
	Local oModel := FWModelActive()
	Local oView := FWViewActive()
	Local oModelZZ3 := oModel:GetModel('PRAA806B_ZZ3')
	Local oModelZZ2 := oModel:GetModel('PRAA806B_ZZ2')
	Local nX
	Local cSeq := "001"
	cArq := StrTran(cArq,cBarA806B,"")
	
//	For nX := 1 To oModelZZ3:Length()
//		cSeq := oModelZZ3:GetValue('ZZ3_SEQARQ',nX)
//	Next nX
	If !Empty(oModelZZ3:GetValue('ZZ3_ARQ'))
		oModelZZ3:AddLine(.T.)
	EndIf

//	oModelZZ3:LoadValue('ZZ3_SEQARQ',StrZero(Val(cSeq)+1,3))
	oModelZZ3:LoadValue('ZZ3_ARQ',DTOS(DATE()) + SUBSTR(Time(), 1, 2) + SUBSTR(Time(), 4, 2) +; 
	                              SUBSTR(Time(), 7, 2)+cArq)
	oModelZZ3:LoadValue('ZZ3_ARQORI',cArq)
	oModelZZ3:LoadValue('ZZ3_DTUP', DTOC(DATE()) + " " + SubStr(Time(),1,5))  
	oModelZZ3:LoadValue('ZZ3_PROCES',.F.)
	oModelZZ3:LoadValue('ZZ3_DSMSG', "Confirmação pendente") 
	oModelZZ3:LoadValue('ZZ3_TMPARQ',cArqTemp)
	oModelZZ3:LoadValue('ZZ3_TPDOC', oModelZZ2:GetValue('ZZ2_TPDOC'))

    If ExistTemplate("PRAARQ")
        oModelZZ3 = ExecTemplate("PRAARQ",.F.,.F.,{oModelZZ3,cArq})
    Endif
Return

		
Static Function A806BBCOMMIT(oModel)
	Local oModelZZ3 := oModel:GetModel('PRAA806B_ZZ3')
	Local oModelZZ2 := oModel:GetModel('PRAA806B_ZZ2')
	Local nX
	Local nY
	Local cArquivo
	Local cArqDest
	Local nStatus
	Local nRegOp := 0
	Local aResult
	Local cPasta
	Local cPastaT
	Local aPasta
	Local cPastaSrv := GetSParam("DIRETORIO_INTEGRACAO_DOCUMENTOS_UPLOAD",'\system\upload','\system\upload',.T.)
	Local nLine
	
	cPastaSrv := StrTran(cPastaSrv,"\",cBarA806B)
	cPastaSrv := StrTran(cPastaSrv,"/",cBarA806B)
	For nX := 1 To oModelZZ3:Length()
		nRegOp := 0
		cArquivo := alltrim(oModelZZ3:GetValue('ZZ3_TMPARQ',nX))           
		cArqDest := UPPER(alltrim(oModelZZ3:GetValue('ZZ3_ARQ',nX))              )
		cArqOri  := UPPER(alltrim(oModelZZ3:GetValue('ZZ3_ARQORI',nX))              )
		cArquivo := UPPER(StrTran(cArquivo,cRootA806B,"")                        )
		cPasta   := UPPER(cBarA806B + alltrim(oModelZZ3:GetValue('ZZ3_TPDOC',nX)))
		If !ExistDir( cPastaSrv + cPasta)
			aPasta := StrtoKarr(cPastaSrv + cPasta,cBarA806B)
			cPastaT := ""
			For nY := 1 To Len(aPasta)
				If !Empty(aPasta[nY])
					cPastaT += cBarA806B + aPasta[nY]
					If !ExistDir( cPastaT)
						MakeDir(cPastaT)
					EndIF
				EndIf
			Next nY
		EndIf
		
		If !Empty(cArquivo) .And. !oModelZZ3:IsDeleted(nX) //Está adicionando e confirmando
			nStatus := FOpen ( cPastaSrv + cPasta + cBarA806B + cArqOri )

			If nStatus!= -1//Elimina se já existe no destino
				fClose(nStatus)
				fErase(cPastaSrv + cPasta  + cBarA806B + cArqOri )
			EndIf
			
     		If !CpyT2S( cArquivo, cPastaSrv + cPasta  + cBarA806B , .F. )
				oModel:SetErrorMessage('PRAA806B',,,,,'Erro fatal ao copiar o arquivo ' + CRLF + AllTrim(cArquivo) + CRLF + ' para a pasta de processamento ' + Alltrim(cPastaSrv + cPasta ) + cBarA806B )
				Return .F.
			EndIf
          nStatus := frenameEX(cPastaSrv + cPasta  + cBarA806B + AllTrim(cArqOri),cPastaSrv + cPasta  + cBarA806B + AllTrim(cArqDest))				
		   If nStatus == -1
		     oModel:SetErrorMessage('PRAA806B',,,,,'Erro fatal ao copiar o arquivo ' + CRLF + AllTrim(cArquivo) + CRLF + ' para a pasta de processamento ' + Alltrim(cPastaSrv + cPasta ) + cBarA806B  )
		     Return .F.
		   EndIf				
				
			nRegOp := 3
		ElseIf Empty(cArquivo) .And. oModelZZ3:IsDeleted(nX)// Está eliminando e confirmando do servidor
			nStatus := FOpen ( cPastaSrv + cPasta  + cBarA806B + cArqDest )
		
			If nStatus!= -1//Elimina se já existe no destino
				fClose(nStatus)
				fErase(cPastaSrv + cPasta  + cBarA806B + cArqDest )
			EndIf
			nRegOp := 5
		ElseIf oModelZZ3:IsDeleted(nX) .And. !Empty(cArquivo) // Está eliminando o pendente de processamento
		
			nStatus := FOpen ( cArquivo )
		
			If nStatus!= -1//Elimina se já existe no destino
				fClose(nStatus)
			//	fErase(cArquivo)
			EndIf
			nRegOp := 0
		EndIf
		If nRegOp != 0
			aResult := TCSPExec("proc_diu_documentos_upload_ag",nRegOp,; // @w_operacao	int
			If (Empty(oModelZZ3:GetValue('ZZ3_DUID',nX)),0,oModelZZ3:GetValue('ZZ3_DUID',nX)),; // @w_du_id	int
			(cAliasZZ2)->ZZ2_RESID,; // @w_res_id	int
			oModelZZ3:GetValue('ZZ3_TPDOC',nX),; // @w_doc_id	varchar	10
			(cAliasZZ2)->ZZ2_DCTPES,; // @w_du_tipo_ES	varchar	1
			oModelZZ3:GetValue('ZZ3_ARQ',nX),; // @w_du_nome_arquivo	varchar	50
			sdbdate(DATE(),TIME()),; // @w_du_dt_registro	varchar	30
			'N',; // @w_du_status	varchar	1
			'',; // @w_du_status_ocorrencia	varchar	255
			''; // @w_du_chave	varchar	30
			)
			IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
				cErro := AllTrim(TCSQLError())
				oModel:SetErrorMessage('PRAA806B',,,,,cErro )
				Return .F.
			elseIF !empty(aResult) .And. AllTrim(aResult[1]) <> ''
				cErro := "Ocorreu um erro no processo da gravação do documento"+Chr(13)+AllTrim(aResult[1])
				oModel:SetErrorMessage('PRAA806B',,,,,cErro )
				Return .F.
			End IF
			
			nLine := oModelZZ3:GetLine()
			oModelZZ3:GoLine(nX)
			oModelZZ3:LoadValue('ZZ3_TMPARQ','')// Limpa para que em um possivel erro não insire novo registro
			oModelZZ3:GoLine(nLine)
		EndIf
	Next nX
	
Return .T.

Function A806BBCANCEL(oModel)
	Local oModelZZ3 := oModel:GetModel('PRAA806B_ZZ3')
	Local nX
	Local cArquivo
	For nX := 1 To oModelZZ3:Length()
		cArquivo := alltrim(oModelZZ3:GetValue('ZZ3_TMPARQ',nX))
		cArquivo := StrTran(cArquivo,cRootA806B,"")
		If !Empty(cArquivo) //Ao cancelar deve apagar os envios temporários.
			nStatus := FOpen ( cArquivo )
		
			If nStatus!= -1//Elimina se já existe no destino
				fClose(nStatus)
				//fErase(cArquivo)
			EndIf
		EndIf
	Next nX
Return .T.
