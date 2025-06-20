#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA005.CH"
#INCLUDE "FILEIO.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA005
Rotina que ir� fazer manuten��o nos c�digos das tabelas CCZ, CG1, CGE e CGG.
@author Erick G. Dias
@since 01/08/2014
@version 11.90

/*/
//-------------------------------------------------------------------
Function FISA005()
Local oBrw		:= FWmBrowse():New()
local cOpcao 	:= ''
Local cDescric	:= ''
Local cVersao	:= GetVersao(.F.)

If Pergunte("ISA005",.T.)
	IF MV_PAR01 == 1
		cOpcao := 'CCZ'
		cDescric:=STR0001//'C�digos da Natureza da Receita'
	ElseIF MV_PAR01 == 2
		cOpcao := 'CG1'
		cDescric:=STR0002//'C�digos da Atividade referente CPRB'			
	ElseIF MV_PAR01 == 3
		cOpcao := 'CGE'
		cDescric:=STR0003//'C�digos de Receitas para Institui��es Financeiras'			
	ElseIF MV_PAR01 == 4		
		cOpcao := 'CGG'
		cDescric:=STR0004//'C�digos de Dedu��es para Institui��es Financeiras'			
	ElseIF MV_PAR01 == 5		
		cOpcao 	:= 'F3G'
		cDescric	:='Receita EFD Contrib a  Recolher'
		oBrw:AddLegend( "F3G_TRIBUT=='1'", "RED", 'PIS') // "Ajuste de Redu��o"
		oBrw:AddLegend( "F3G_TRIBUT=='2'", "GREEN", 'COFINS' ) // "Ajuste de Acr�scimo"	
	EndIF

EndIF
PRIVATE cAlias	:= cOpcao

IF Len(cOpcao) > 0

	oBrw:SetDescription(cDescric)
	oBrw:SetAlias( cAlias)
	oBrw:SetMenuDef( 'FISA005' )	
	oBrw:Activate()  
EndIF
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Erick G. Dias
@since 01/08/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   

Local aRotina	:= {}

	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA005' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA005' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA005' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FISA005' OPERATION 5 ACCESS 0 //'Excluir'
	// Realizado tratamento, pois n�o h� c�digos para importa��o ao utilizar a op��o de Cadastro 5 - Receita EFD Contrib a  Recolher  
	If valtype(MV_PAR01) == 'N' .AND. MV_PAR01  <> 5
		ADD OPTION aRotina TITLE STR0009 ACTION 'A005TXT'	   OPERATION 3 ACCESS 0 // Importar TXT
	endif

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Erick G. Dias
@since 01/08/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruGener
Local oModel
Local aAux := {}

DEFAULT cAlias	:= 'CCZ'

oStruGener 	:= 	FWFormStruct( 1,cAlias)

oModel	:=	MPFormModel():New('FISA005',,{ |oModel| .T. } , { |oModel| VldGrava() } )

oModel:AddFields( 'MODEL_GEN' ,, oStruGener )

//Ir� verificar qual alias est� sendo processado, para n�o permitir campos do X2_UNICO sejam alterados no modo de edi��o
IF cAlias == 'CCZ'
	oStruGener:SetProperty( 'CCZ_FILIAL' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStruGener:SetProperty( 'CCZ_TABELA' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStruGener:SetProperty( 'CCZ_COD' 		, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
	oStruGener:SetProperty( 'CCZ_GRUPO' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStruGener:SetProperty( 'CCZ_DTFIM' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
ElseIF cAlias == 'CG1'
	oStruGener:SetProperty( 'CG1_FILIAL' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStruGener:SetProperty( 'CG1_CODIGO' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
	oStruGener:SetProperty( 'CG1_DTINI' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
	oStruGener:SetProperty( 'CG1_DTFIM' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
ElseiF cAlias == 'CGE'
	oStruGener:SetProperty( 'CGE_COD' 		, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
	oStruGener:SetProperty( 'CGE_DTINI' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
	oStruGener:SetProperty( 'CGE_DTFIN' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
ElseIF cAlias == 'CGG'
	oStruGener:SetProperty( 'CGG_COD' 		, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
	oStruGener:SetProperty( 'CGG_DTINI' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
	oStruGener:SetProperty( 'CGG_DTFIN' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
ElseIF cAlias == 'F3G'
	oStruGener:SetProperty( 'F3G_CST' 		, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
	oStruGener:SetProperty( 'F3G_TRIBUT' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })	
	oStruGener:SetProperty( 'F3G_REGIME' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
	oStruGener:SetProperty( 'F3G_CODCON' 	, MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3) })
EndIF

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 01/08/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local	oModel 		:= 	FWLoadModel( 'FISA005' )
Local	oStruGener 	:= 	Nil
Local	oView 			:= 	FWFormView():New()
Local cDescri			:= 'Visualiza��o'

DEFAULT cAlias := "CCZ"

oView:SetModel( oModel )
oStruGener	:= 	FWFormStruct( 2, cAlias)
oView:AddField( 'VIEW_GEN', oStruGener, 'MODEL_GEN' )

//oView:EnableTitleView( 'VIEW_GEN', cDescri )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VldGrava
Fun��o que ir� fazer valida��o de grava��o das informa��es 

@author Erick G. Dias
@since 01/08/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function VldGrava()

Local	oModel		:=	FWModelActive()
Local	oModelGEN	:=	oModel:GetModel('MODEL_GEN')
Local lExiste		:= .F.
Local lConfliF3G	:= .F.
Local cTabela		:= ''
Local cCod			:= ''
Local cGrupo		:= ''
Local cCST			:= ''
Local cTributo		:= ''
Local cRegime		:= ''
Local cCodCont		:= ''
Local cTNatRec		:= ''
Local cCNatRec		:= ''
Local cDescF3G		:= ''
Local dDtIni		:= CTod("  /  /    ")
Local dDtFin		:= CTod("  /  /    ")
Local nTNatRec		:= 0
Local nCNatRec		:= 0
Local aArea    		:= {}

DEFAULT cAlias 		:= "CCZ"

IF oModel:GetOperation() == MODEL_OPERATION_INSERT

	If cAlias == 'CCZ'
		//'CCZ_FILIAL+CCZ_TABELA+CCZ_COD+CCZ_GRUPO+DTOS(CCZ_DTFIM)'
		cTabela	:= oModelGEN:GetValue('CCZ_TABELA' )
		cCod		:= oModelGEN:GetValue('CCZ_COD' )	
		cGrupo		:= oModelGEN:GetValue('CCZ_GRUPO' )
		dDtFin		:= oModelGEN:GetValue('CCZ_DTFIM' )			
		lExiste 	:=CCZ->(MSSEEK(xFilial('CCZ')+ cTabela+cCod+cGrupo+DTOS(dDtFin)))
		
	ElseIf cAlias == 'CG1'
		//CG1_FILIAL+CG1_CODIGO+DtoS(CG1_DTFIM)
		cCod		:= oModelGEN:GetValue('CG1_CODIGO' )
		dDtFin		:= oModelGEN:GetValue('CG1_DTFIM' )			
		lExiste 	:=CG1->(MSSEEK(xFilial('CG1')+ cCod+DTOS(dDtFin)))
		
	ElseIf cAlias == 'CGE'
		//CGE_FILIAL+CGE_COD+DTOS(CGE_DTINI)+DTOS(CGE_DTFIN)
		cCod		:= oModelGEN:GetValue('CGE_COD' )
		dDtIni		:= oModelGEN:GetValue('CGE_DTINI' )
		dDtFin		:= oModelGEN:GetValue('CGE_DTFIN' )	
		lExiste 	:=CGE->(MSSEEK(xFilial('CGE')+ cCod+DTOS(dDtIni)+DTOS(dDtFin)))
			
	ElseIf cAlias == 'CGG'
		//CGG_FILIAL+CGG_COD+DTOS(CGG_DTINI)+DTOS(CGG_DTFIN)
		cCod		:= oModelGEN:GetValue('CGG_COD' )
		dDtIni		:= oModelGEN:GetValue('CGG_DTINI' )
		dDtFin		:= oModelGEN:GetValue('CGG_DTFIN' )
		lExiste 	:=CGG->(MSSEEK(xFilial('CGG')+ cCod+DTOS(dDtIni)+DTOS(dDtFin)))	
			
	ElseIf cAlias == 'F3G'
		//F3G_FILIAL+F3G_CST+F3G_TRIBUT+F3G_REGIME+F3G_CODCON+F3G_NATREC+F3G_CNATRE
		aArea		:= F3G->(GetArea())
		cCST		:= oModelGEN:GetValue('F3G_CST' )
		cTributo	:= oModelGEN:GetValue('F3G_TRIBUT' )
		cRegime		:= oModelGEN:GetValue('F3G_REGIME' )
		cCodCont	:= oModelGEN:GetValue('F3G_CODCON' )
		cTNatRec	:= oModelGEN:GetValue('F3G_NATREC' )
		cCNatRec	:= oModelGEN:GetValue('F3G_CNATRE' )
				
		nTNatRec	:= TamSx3("F3G_NATREC")[1]
		nCNatRec	:= TamSx3("F3G_CNATRE")[1]
		dbSelectArea("F3G")
		dbSetOrder(1)		
		
		//Verifica se regra j� existe
		lExiste 	:= F3G->(MSSEEK(xFilial('F3G')+cTributo+cRegime + cCST+ cCodCont + PADR(cTNatRec,nTNatRec)+ PADR(cCNatRec,nCNatRec)))			
		
		//Caso a regra ainda n�o exista, precisa verificar se ela n�o entra em conflito com alguma regra j� cadastrada.
		If !lExiste
			If Empty(cTNatRec) .AND. Empty(cCNatRec)
				//Regra gen�rica
				IF !lExiste .AND. F3G->(MSSEEK(xFilial('F3G')+cTributo+cRegime + cCST+ cCodCont))			
					lConfliF3G	:= .T.					
				EndIF			
			Else
				//Regra mais espec�fica
				IF !lExiste .AND. F3G->(MSSEEK(xFilial('F3G')+cTributo+cRegime + cCST+ cCodCont + PADR("",nTNatRec)+ PADR("",nCNatRec)))			
					lConfliF3G	:= .T.					
				EndIF
			EndiF
		EndIF
		RestArea(aArea)
	EndIF

	IF lExiste			
		Help(,,"Help",,STR0010,1,0) //'Estas informa��es j� est�o cadastradas no banco de dados.'	
	
	ElseIF lConfliF3G
		//Alertar usu�rio que existe um regra em conflito, n�o ser� cadastrada, e ser�o exibida qual a regra em quest�o est� em conflito
		cDescF3G	:= 'Regra em conflito com a regra j� cadastrada:' 	    + CHR(13) + CHR(10) + ;
				       'C�dido de receita: ' 			+ F3G->F3G_CODREC 	+ CHR(13) + CHR(10) + ;
		      		   'CST: ' 							+ F3G->F3G_CST 		+ CHR(13) + CHR(10) + ;
		  		       'C�digo da Contribui��o: ' 		+ F3G->F3G_CODCON	+ CHR(13) + CHR(10) + ; 
		      		   'Tabela Natureza Receita:'		+ F3G->F3G_NATREC 	+ CHR(13) + CHR(10) + ;
		       	       'C�digo da Natureza Receita:'	+ F3G->F3G_CNATRE
		
		Help(,,"Help",,cDescF3G,1,0) //'Estas informa��es j� est�o cadastradas no banco de dados.'
		lExiste	:= .T.	
	
	Else
		FWFormCommit(oModel)		
	EndIF
Else
	FWFormCommit(oModel)
EndIF

Return !lExiste

//-------------------------------------------------------------------
/*/{Protheus.doc} A005TXT
Fun��o que pergunta para usu�rio qual a pasta onde os arquivos a serem 
importados est�o. 

@author Erick G. Dias
@since 01/08/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function A005TXT()

Local cDirFiles	:= ""
Local oProcess

DEFAULT cAlias	:= "CCZ"

If DialogFld(@cDirFiles)

	oProcess := FISProgress():New({|lEnd| PrImpSPEDC(cDirFiles,oProcess)},STR0011)//'Realizando Importa��o'
	oProcess:Activate()
	(cAlias)->(DBGOTOP())
	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrImpSPEDC
Fun��o respons�vel pela verifica��o da exist�ncia da pasta e do arquivo, bem como 
percorrer o arquivo e preparar as linhas para grava��o.

@author Erick G. Dias
@since 01/08/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function PrImpSPEDC (cDirFiles,oProcess)

Local aArquivos	:= {}
Local aLinha		:= {}
Local cLinha  	  := ""
Local nContArq	:= 0
Local nHandle  	:= 0
Local nCG1			:= 0
Local cNomeArq	:= ""
lOCAL nInclu�do	:= 0
lOCAL nAlterado	:= 0
Local nProcessado := 0
Local nArqProc	:= 0
Local lCCZSIX		:=  .F.
Local lCancel		:= .F.

DEFAULT cDirFiles	:= ""

dbSelectArea("CG1")
dbSetOrder(1)
dbSelectArea("CCZ")
dbSetOrder(1)
dbSelectArea("SIX")
dbSetOrder(1)
cDirFiles := Alltrim(cDirFiles)

lCCZSIX	:=SIX->(MsSeek("CCZ"+"2")) .and. SIX->(MsSeek("CCZ"+"3"))

Begin Transaction
If ExistDir(cDirFiles) 
	aArquivos := Directory(cDirFiles+"*.txt")

	oProcess:Set1Progress(Len(aArquivos))

	If Len(aArquivos) > 0
		For nContArq:=1 to Len(aArquivos)
							
			If File(cDirFiles+aArquivos[nContArq,1])
				nHandle  	:= FOpen(cDirFiles+aArquivos[nContArq,1])
				cNomeArq	:= aArquivos[nContArq,1]

				oProcess:Inc1Progress(STR0012 +cNomeArq)//'Processando Arquivo : '			
				If oProcess:Cancel()
					lCancel:=.T.
						Exit
				EndIf
				
				lProc	:= .F.
				//Ir� importar somente arquivos com informa��es pertinentes ao alias escolhido
				//pelo usu�rio no in�cio da rotina.
				Do case
					Case MV_PAR01 == 1// 'CCZ'
						IF SUBSTR(Upper(cNomeArq),1,8) == 'TABELA43'
							lProc := .T.
						EndIF
					Case MV_PAR01 == 2// 'CG1'
						IF Upper(cNomeArq) == 'TABELA511.TXT'
							lProc := .T.
						EndIF
					Case MV_PAR01 == 3// 'CGE'
						IF Upper(cNomeArq) $ "TABELA711.TXT" .Or. SUBSTR(Upper(cNomeArq),1,11) == 'TABELA713GR'
							lProc := .T.
						EndIF			
					Case MV_PAR01 == 4 // 'CGG'
						IF UPPER(cNomeArq) $ "TABELA712.TXT" .Or. SUBSTR(Upper(cNomeArq),1,11) == 'TABELA714GR'
							lProc := .T.
						EndIF																					
				EndCase
				
				IF lProc
					nArqProc++
					FSeek(nHandle,0,0)
					
					FT_FUse(cDirFiles+aArquivos[nContArq,1])
					FT_FGotop()
					oProcess:Set2Progress(FT_FLASTREC( )- 1)
					
					//Leitura do arquivo
					While (!FT_FEof())	
			
						aLinha	:= {}
						cLinha  := ""
						cLinha  := Alltrim(FT_FREADLN())
	
						oProcess:Inc2Progress(STR0013 + SubStr(cLinha,1,40) + '..."')//'Processando Linha : "'			
						If oProcess:Cancel()
							lCancel:=.T.
							Exit
						EndIf
						
						If RegToArSC(cLinha,@aLinha)
							nProcessado ++
							If UPPER(cNomeArq) == "TABELA511.TXT" .OR.(lCCZSIX)
								GrvTabSC(aLinha,cNomeArq,@nCG1,@nInclu�do,@nAlterado)
							EndIf
						EndIf                               
						
						FT_FSkip()
					EndDo
					
					FT_FUse()
					FClose(nHandle)
				EndIf
			EndIf
		
		Next nContArq		
		
	EndIf
EndIf

oProcess:Inc1Progress(STR0014)//'Conclu�do'
oProcess:Inc2Progress(STR0014)//'Conclu�do'

oProcess:Set2Progress(1)

/*
"Importa��o Conclu�da"
"Arquivos Processados : "
"Quantidade de C�digos Processados:"
"Quantidade de C�digos Inclu�dos:"
*/

oProcess:SetDetProgress(STR0015,,;
	STR0016,nArqProc ,;
	STR0017,nProcessado ,;
	STR0018,nInclu�do )

If !lCancel	
	MsgInfo(STR0015)//'Importa��o Conclu�da'
Else
	DisarmTransaction()
	Alert(STR0019)//'Opera��o Cancelada'
EndIF

End Transaction

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrImpSPEDC
Fun��o que ir� verificar se informa��o j� est� gravada no banco de dados
e tamb�m definir para qual tabela a informa��o dever� ser gravada.

@author Erick G. Dias
@since 01/08/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static function GrvTabSC(aLinha,cNomeArq,nCG1,nInclu�do,nAlterado)

Local 	dData		:= CToD ("//")
Local 	dDataIni	:= CToD ("//")
Local  cGrupo		:= "  "
Local  cCod		:= ""
Local  cAlqPis		:= ""
Local  cAlqCof		:= ""
Local  cTab		:= ""
Local  cDescr		:= ""
Local  cAlqPsC		:= ""
Local  cAlqCfC		:= ""
DEFAULT cNomeArq	:= ""

//Tabela 5.1.1 para SPED Contribui��es
If Upper(cNomeArq) == "TABELA511.TXT" //CODIGO DA ATIVIDADE CPRB
    
	If len(aLinha[3])>0
		dDataIni:=	stod(Substr(aLinha[3],5,4) + Substr(aLinha[3],3,2)+Substr(aLinha[3],1,2)) 
	EndIF
	
	If len(aLinha[4])>0
		dData:=	stod(Substr(aLinha[4],5,4) + Substr(aLinha[4],3,2)+Substr(aLinha[4],1,2)) 
	EndIF
	
	//Se a data final do c�digo no arquivo texto estiver preenchida, ent�o ter� que excluir as linhas do mesmo c�digo
	//que n�o possuam data final preenchida, e considerar a data final constante no arquivo.
	IF !EmpTy(dData) .AND.  CG1->(dbSeek(xFilial("CG1") + aLinha[1]))
		Do while !CG1->(Eof()) .AND. EmpTy(CG1->CG1_DTFIM) .AND. CG1->CG1_CODIGO == aLinha[1]
			RecLock("CG1")
			CG1->(dbDelete())
			MsUnLock()
			CG1->(dbSkip())
		Enddo
	ElseIf EmpTy(dData) .AND. CG1->(dbSeek(xFilial("CG1") + aLinha[1]))		
		Do while !CG1->(Eof()) .AND. !EmpTy(CG1->CG1_DTFIM) .AND. CG1->CG1_CODIGO == aLinha[1];
		.And. IIf (Len(aLinha) > 5, (CG1->CG1_ALIQ == Val(aLinha[6])), .F.)
			RecLock("CG1")
			CG1->(dbDelete())
			MsUnLock()
			CG1->(dbSkip())
		Enddo
	EndIF

	IF CG1->(dbSeek(xFilial("CG1") + aLinha[1]+ dTos(dData)))
		RecLock("CG1",.F.)
		nAlterado++
		CG1->CG1_DTINI	:= dDataIni
		MsUnLock()	
	Else
		nCG1++
		nInclu�do++
		RecLock("CG1",.T.)
		CG1->CG1_FILIAL	:= xFilial("CG1")
		CG1->CG1_CODIGO	:= aLinha[1]
		CG1->CG1_DESCRI	:= aLinha[2]
		CG1->CG1_ALIQ	:= Iif(Len(aLinha)>5,val(aLinha[6]),0)   
		CG1->CG1_DTINI	:= dDataIni 
		CG1->CG1_DTFIM	:= dData
		MsUnLock()					
	EndIF
		
ElseIf Upper(cNomeArq) == "TABELA439.TXT"

	IF Len(aLinha) >= 09
		CCZ->(DbSetOrder(2))
	
		If len(aLinha[4])>0
			dData:=	stod(Substr(aLinha[4],5,4) + Substr(aLinha[4],3,2)+Substr(aLinha[4],1,2)) 
		EndIF
		
		cGrupo:= "  "
		cCod  := aLinha[1]	
		If len(aLinha[1])>3	
			cGrupo:= StrZero(Val(Substr(aLinha[1],4,3)),2)
			cCod  := Substr(cCod,1,3)	
		EndIF  	
		
		IF !CCZ->(dbSeek(xFilial("CCZ")+dTos(dData)+"439 "+cCod+cGrupo)) //Data+Tabela+Codigo+Grupo
		   CCZ->(DbSetOrder(3))
			If CCZ->(dbSeek(xFilial("CCZ")+"439 "+cCod+cGrupo+str(val(aLinha[8]),8,4)+str(val(aLinha[9]),8,4))) //Tabela+Codigo+Grupo+AlqPIS+ALQCOF    
			
				RecLock("CCZ",.F.)
				nAlterado++
				CCZ->CCZ_DTFIM	:= dData //Atualiza data final
				MsUnLock()		
			Else
				RecLock("CCZ",.T.)
				nInclu�do++
				CCZ->CCZ_FILIAL	:= xFilial("CCZ")
				CCZ->CCZ_TABELA	:= "439"
				CCZ->CCZ_COD	:= cCod
				CCZ->CCZ_DESC	:= aLinha[2]
				CCZ->CCZ_GRUPO	:= cGrupo
				CCZ->CCZ_ALQPIS	:= Val(aLinha[8])
				CCZ->CCZ_ALQCOF	:= Val(aLinha[9])
				CCZ->CCZ_DTFIM	:= dData
				MsUnLock()		
			EndIF
		EndIF 	
	EndIF

ElseIf Upper(cNomeArq) == "TABELA4310.TXT" //AL�QUOTAS DIFERENCIADAS
		IF Len(aLinha) >= 9
			CCZ->(DbSetOrder(2))
		
			If len(aLinha[4])>0
				dData:=	stod(Substr(aLinha[4],5,4) + Substr(aLinha[4],3,2)+Substr(aLinha[4],1,2))
			EndIF
			
			cCod:=aLinha[1]
			
			if cCod $ "150/151/402"
				cCod:=aLinha[1]			
			EndIF
			
			IF !CCZ->(dbSeek(xFilial("CCZ")+dTos(dData)+"4310"+cCod)) //Data+Tabela+Codigo
				CCZ->(DbSetOrder(3))
				If CCZ->(dbSeek(xFilial("CCZ")+"4310"+cCod+cGrupo+str(val(aLinha[8]),8,4)+str(val(aLinha[9]),8,4))) //Tabela+Codigo+Grupo+AlqPIS+ALQCOF
					RecLock("CCZ",.F.)
					nAlterado++
					CCZ->CCZ_DTFIM	:= dData //Atualiza data final
					MsUnLock()
				Else
					RecLock("CCZ",.T.)
					nInclu�do++
					CCZ->CCZ_FILIAL	:= xFilial("CCZ")
					CCZ->CCZ_TABELA	:= "4310"
					CCZ->CCZ_COD	:= cCod
					CCZ->CCZ_DESC	:= aLinha[2]
					CCZ->CCZ_GRUPO	:= cGrupo
					CCZ->CCZ_ALQPIS	:= Val(aLinha[8])
					CCZ->CCZ_ALQCOF	:= Val(aLinha[9])
					CCZ->CCZ_DTFIM	:= dData
					MsUnLock()
				EndIF
			EndIF
		EndIF
		
ElseIf Upper(cNomeArq) == "TABELA4311.TXT" //AL�QUOTAS EM REAIS
	IF Len(aLinha) >= 10
		CCZ->(DbSetOrder(2))
	
		If len(aLinha[4])>0
			dData:=	stod(Substr(aLinha[4],5,4) + Substr(aLinha[4],3,2)+Substr(aLinha[4],1,2)) 
		EndIF
		
		cGrupo:= "  "
		cCod  := aLinha[1]	
		If len(aLinha[1])>3	
			cGrupo:= StrZero(Val(Substr(aLinha[1],4,3)),2)
			cCod  := Substr(cCod,1,3)	
		EndIF  	
		
		IF !CCZ->(dbSeek(xFilial("CCZ")+dTos(dData)+"4311"+cCod+cGrupo)) //Data+Tabela+Codigo+Grupo
			CCZ->(DbSetOrder(3))
			If CCZ->(dbSeek(xFilial("CCZ")+"4311"+cCod+cGrupo+str(val(aLinha[9]),8,4)+str(val(aLinha[10]),8,4))) //Tabela+Codigo+Grupo+AlqPIS+ALQCOF
				RecLock("CCZ",.F.)
				nAlterado++
				CCZ->CCZ_DTFIM	:= dData //Atualiza data final
				MsUnLock()		
			Else
				RecLock("CCZ",.T.)
				nInclu�do++
				CCZ->CCZ_FILIAL	:= xFilial("CCZ")
				CCZ->CCZ_TABELA	:= "4311"
				CCZ->CCZ_COD	:= cCod
				CCZ->CCZ_DESC	:= aLinha[2]
				CCZ->CCZ_GRUPO	:= cGrupo
				CCZ->CCZ_ALQPIS	:= Val(aLinha[9])
				CCZ->CCZ_ALQCOF	:= Val(aLinha[10])
				CCZ->CCZ_DTFIM	:= dData
				MsUnLock()		
			EndIF
		EndIF 	
	EndIF

ElseIf Upper(cNomeArq) == "TABELA4312.TXT"
	CCZ->(DbSetOrder(2))

	If len(aLinha[4])>0
		dData:=	stod(Substr(aLinha[4],5,4) + Substr(aLinha[4],3,2)+Substr(aLinha[4],1,2)) 
	EndIF		

	cCod  := aLinha[1]	
	
	If Len(aLinha) >= 9
		cAlqPis	:=aLinha[8]
		cAlqCOF	:=aLinha[9]
	EndIF
	
	IF !CCZ->(dbSeek(xFilial("CCZ")+dTos(dData)+"4312"+cCod)) //Data+Tabela+Codigo
		CCZ->(DbSetOrder(3))
		If CCZ->(dbSeek(xFilial("CCZ")+"4312"+cCod+cGrupo+str(val(cAlqPis),8,4)+str(val(cAlqCOF),8,4))) //Tabela+Codigo+Grupo+AlqPIS+ALQCOF
			RecLock("CCZ",.F.)
			nAlterado++
			CCZ->CCZ_DTFIM	:= dData //Atualiza data final
			MsUnLock()
		Else
			RecLock("CCZ",.T.)
			nInclu�do++
			CCZ->CCZ_FILIAL	:= xFilial("CCZ")
			CCZ->CCZ_TABELA	:= "4312"
			CCZ->CCZ_COD	:= cCod
			CCZ->CCZ_DESC	:= aLinha[2]
			CCZ->CCZ_GRUPO	:= cGrupo
			CCZ->CCZ_ALQPIS	:= Val(cAlqPIS)
			CCZ->CCZ_ALQCOF	:= Val(cAlqCOF)
			CCZ->CCZ_DTFIM	:= dData
			MsUnLock()
		EndIF
	EndIF
ElseIf Upper(cNomeArq) $ "TABELA4313.TXT/TABELA4314.TXT/TABELA4315.TXT/TABELA4316.TXT"

	CCZ->(DbSetOrder(2))
	cTab	:= SubStr(cNomeArq,7,4)

	If len(aLinha[4])>0
		dData:=	stod(Substr(aLinha[4],5,4) + Substr(aLinha[4],3,2)+Substr(aLinha[4],1,2)) 
	EndIF		

	cCod  := aLinha[1]	
	
	IF !CCZ->(dbSeek(xFilial("CCZ")+dTos(dData)+cTab+cCod)) //Data+Tabela+Codigo
		RecLock("CCZ",.T.)
		nInclu�do++
		CCZ->CCZ_FILIAL	:= xFilial("CCZ")
		CCZ->CCZ_TABELA	:= cTab
		CCZ->CCZ_COD	:= cCod
		CCZ->CCZ_DESC	:= aLinha[2]
		CCZ->CCZ_GRUPO	:= cGrupo
		CCZ->CCZ_ALQPIS	:= 0
		CCZ->CCZ_ALQCOF	:= 0
		CCZ->CCZ_DTFIM	:= dData
		MsUnLock()	
	EndIF
ElseIf Upper(cNomeArq) == "TABELA4317.TXT"

	CCZ->(DbSetOrder(2))
	cTab	:= SubStr(cNomeArq,7,4)

	If len(aLinha[4])>0
		dData:=	stod(Substr(aLinha[4],5,4) + Substr(aLinha[4],3,2)+Substr(aLinha[4],1,2))
	EndIF
	If Len(aLinha) >= 11
		cAlqPis	 :=aLinha[08]
		cAlqPsC :=aLinha[09]
		cAlqCOF	 :=aLinha[10]
		cAlqCFC  :=aLinha[11]
	EndIF
	cCod  := aLinha[1]

	IF !CCZ->(dbSeek(xFilial("CCZ")+dTos(dData)+cTab+cCod)) //Data+Tabela+Codigo
		RecLock("CCZ",.T.)
		nInclu�do++
		CCZ->CCZ_FILIAL	:= xFilial("CCZ")
		CCZ->CCZ_TABELA	:= cTab
		CCZ->CCZ_COD	:= cCod
		CCZ->CCZ_DESC	:= aLinha[2]
		CCZ->CCZ_GRUPO	:= cGrupo
		CCZ->CCZ_ALQPIS	:= Val(cAlqPis)
		If FieldPos("CCZ_ALQPSC") > 0
			CCZ->CCZ_ALQPSC	:= Val(cAlqPsC)
		EndIf
		CCZ->CCZ_ALQCOF	:= Val(cAlqCOF)
		If FieldPos("CCZ_ALQCFC") > 0
			CCZ->CCZ_ALQCFC	:= Val(cAlqCFC)
		EndIf
		CCZ->CCZ_DTFIM	:= dData
		MsUnLock()
	EndIF
ELSEIF Upper(cNomeArq) $ "TABELA711.TXT" .Or. SUBSTR(Upper(cNomeArq),1,11) == 'TABELA713GR'
	cCod	:= PADR(aLinha[1],8)
	cDescr	:= aLinha[2]
	
	If len(aLinha[3])>0
		dDataIni:=	stod(Substr(aLinha[3],5,4) + Substr(aLinha[3],3,2)+Substr(aLinha[3],1,2)) 
	EndIF
	
	If len(aLinha[4])>0
		dData:=	stod(Substr(aLinha[4],5,4) + Substr(aLinha[4],3,2)+Substr(aLinha[4],1,2)) 
	EndIF

	IF !CGE->(dbSeek(xFilial("CGE")+cCod+dTos(dDataIni)+dTos(dData)))
		RecLock("CGE",.T.)
		nInclu�do++
		CGE->CGE_FILIAL		:= xFilial("CGE")
		CGE->CGE_COD			:= cCod		
		CGE->CGE_DESCR		:= cDescr
		CGE->CGE_DTINI		:= dDataIni
		CGE->CGE_DTFIN		:= dData
		MsUnLock()	
	EndIF

ELSEIF Upper(cNomeArq) $ "TABELA712.TXT" .Or. SUBSTR(Upper(cNomeArq),1,11) == 'TABELA714GR'

	cCod	:= PADR(aLinha[1],8)
	cDescr	:= aLinha[2]
	
	If len(aLinha[3])>0
		dDataIni:=	stod(Substr(aLinha[3],5,4) + Substr(aLinha[3],3,2)+Substr(aLinha[3],1,2)) 
	EndIF
	
	If len(aLinha[4])>0
		dData:=	stod(Substr(aLinha[4],5,4) + Substr(aLinha[4],3,2)+Substr(aLinha[4],1,2)) 
	EndIF

	IF !CGG->(dbSeek(xFilial("CGG")+cCod+dTos(dDataIni)+dTos(dData)))
		RecLock("CGG",.T.)
		nInclu�do++
		CGG->CGG_FILIAL		:= xFilial("CGG")
		CGG->CGG_COD			:= cCod		
		CGG->CGG_DESCR		:= cDescr
		CGG->CGG_DTINI		:= dDataIni
		CGG->CGG_DTFIN		:= dData
		MsUnLock()	
	EndIF
Endif		

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegtoArSC
Fun��o que le a linha e coloca em um array de forma pronta para processamento

@author Erick G. Dias
@since 01/08/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function RegtoArSC(cLinha,aLinha)

Local nPos		:= At("|",SubStr(cLinha,1,len(cLinha)))
Local cField	:= ""
Local cVersao	:= ""

If ("vers�o"$cLinha .or. "versao"$cLinha) .And. (nPosIg := AT("=",cLinha)) > 0
	cVersao := PADR(Alltrim(Substr(cLinha,nPosIg+1)),5)
EndIf

IF Empty(cVersao)
	//�����������������������������������������Ŀ
	//�Montando array com os campos do registro �
	//�������������������������������������������
	While nPos > 0
		cField := Substr(cLinha,1,nPos-1)
		AADD(aLinha,StrTran(AllTrim(cField),",","."))
		cLinha := Substr(cLinha,nPos+1,len(cLinha))
		nPos  := At("|",SubStr(cLinha,1,len(cLinha)))
	EndDo
	
	If len(cLinha) > 0
		AADD(aLinha,StrTran(AllTrim(cLinha),",","."))
	EndIF
EndIF
                                                                   
Return (len(aLinha) >= 4)

//-------------------------------------------------------------------
/*/{Protheus.doc} DialogFld
Fun��o que monta tela de pergunta para �su�rio, para selecionar o 
diret�rio onde os arquivos est�o gravados.

@author Erick G. Dias
@since 01/08/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Function DialogFld(cDirFiles)

Local oDlgImp, oBtnArq, oBtnImp, oBtnEsc

DEFINE MSDIALOG oDlgImp TITLE STR0020 FROM 0,0 TO 160,580 PIXEL OF GetWndDefault() //"IMPORTA��O DOS C�DIGOS DA EFD CONTRIBUI��ES"

@ 12,010 SAY STR0021 PIXEL OF oDlgImp //"Esta rotina realiza importa��o de c�digos das tabelas utilizadas na EFD Contribui��es." 
@ 20,010 SAY STR0022  PIXEL OF oDlgImp //"Selecione a pasta onde est�o localizados os arquivos em formato TXT."

@ 42,010 MSGET cDirFiles SIZE 160,10 PICTURE "@!" PIXEL OF oDlgImp
@ 42,170 BUTTON oBtnArq PROMPT STR0023 SIZE 26,11 PIXEL ACTION (cDirFiles := cGetFile(,STR0024,0,"",.T.,GETF_RETDIRECTORY) ) //"Procurar" 

@ 60,010 BUTTON oBtnImp PROMPT "OK" SIZE 35,13 PIXEL ACTION ( IIF(ExistDir(cDirFiles),oDlgImp:End(),Alert(STR0025)) ) //"Selecione um diret�rio valido"
@ 60,050 BUTTON oBtnEsc PROMPT 'Cancelar' SIZE 35,13 PIXEL ACTION ( cDirFiles := "" , oDlgImp:End() ) //"Cancelar"

ACTIVATE DIALOG oDlgImp CENTERED

Return !Empty(cDirFiles)
