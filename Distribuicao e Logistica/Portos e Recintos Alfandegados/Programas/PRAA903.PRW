#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'DBINFO.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc}
Cadastro msg RFB

@author Marcelo Nunes
@version P1217
@Since	09/02/2016
@obs Cadastro msg RFB
/*/
Function PRAA903()
	Local aCols := {}
	Local aFieFilter := {}
	Local oDlg         := nil
	Local aCoors       := FWGetDialogSize(oMainWnd)
	Local aAreaAnt     := GetArea()

	Private oBrowse := nil
 
	Private aCamposAst := {}
	Private cAliasAst  := GetNextAlias()//'Assunto'
	Private aCamposMsg:= {}
	Private cAliasMsg := GetNextAlias()//'Mensagens'
	Private aCamposDes := {}
	Private cAliasDes := GetNextAlias()//'Destinatários'
	Private cUsuario := ""
	Private  a_DEPART := {''}
	Private aStructDesc
	Private aStruct
	private cRetPRA903 := ''
	Private lKill := .F.
  
	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

	cUsuario := A903_USUAR()

	if cUsuario == ""
		MsgStop('Este usuário não está cadastrado no sistema SARA'+Chr(13)+'Entre em contato com o administrador do sistema')
		Return .F.
	EndIF

	   //Cria tabelas temporárias
	A903CRI_TB()

      //Carrega os dados das tebelas temporárias
	A903CAR_TB()

      //Colunas da Grid        TMP_HR_PRE
	Aadd(aCols,{'Código',"AST_ID","C" ,0,0,})
	Aadd(aCols,{'Assunto',"AST_DESC","C" ,150,0,})
	Aadd(aCols,{'Data Cadastro',"AST_DT_REG" ,"D" ,0,0,})
	Aadd(aCols,{'Hora',"AST_HR_REG","C" ,5,0,})
     
    Aadd(aFieFilter,{'AST_ID', 'Código','C', 0, 0})
      
    oBrowse := FWMBrowse():New(oDlg)
    oBrowse:setowner(oDlg)
    oBrowse:SetAlias(cAliasAst)
    oBrowse:SetTemporary(.T.)
    oBrowse:SetMenuDef('PRAA903')
    oBrowse:SetDescription('Registro de Mensagens')
    oBrowse:SetUseFilter(.F.)
    oBrowse:SetFields(aCols)
    
	oBrowse:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED

	delTabTmp(cAliasAst)
	delTabTmp(cAliasMsg)
	delTabTmp(cAliasDes)
	dbClearAll()
	
	RESTAREA(aAreaAnt)
      
Return .T.

/*{Protheus.doc}
@author Marcelo Nunes
@version P12
@Since	10/02/2016
@obs Retorna Usuario SARA
*/
Function A903_USUAR()
	Local tTabUser := GetNextAlias()
   
	Local cCodUsr
	cQuery :=     " SELECT  "
	cQuery +=            " USU_ID "
	cQuery +=       " FROM TAB_USUARIOS "
	cQuery +=      " WHERE USU_ID = 'c"+ StrTran(SCodUsr903(),'ECPF','',1,1) + "'"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),tTabUser,.F.,.T.)

	cCodUsr := AllTrim((tTabUser)->USU_ID)
	(tTabUser)->(DbCloseArea())
Return cCodUsr

/*{Protheus.doc}
@author Marcelo Nunes
@version P12
@Since	10/02/2016
@obs Cria as tabelas temporarias
*/
Function A903CRI_TB()

	Aadd(aCamposAst,{"AST_ID","C",10,0})
	Aadd(aCamposAst,{"AST_DESC","C",150,0})
	Aadd(aCamposAst,{"AST_DT_REG","C",10,0})
	Aadd(aCamposAst,{"AST_HR_REG","C",5,0})
	//cAliasAst := CriaTabTmp(aCamposAst,{'AST_ID','AST_DESC'},cAliasAst) //yuri iuchi teste
	cAliasAst := SCriaTbTmp({aCamposAst,{'AST_ID'}})
	
	Aadd(aCamposMsg,{"AST_ID","C",10,0})
	Aadd(aCamposMsg,{"MSG_ID","C",10,0})
	Aadd(aCamposMsg,{"MSG_USU_ID","C",12,0})
	Aadd(aCamposMsg,{"MSG_DEP_ID","C",3,0})
	Aadd(aCamposMsg,{"MSG_TEXTO","C",4000,0})
	Aadd(aCamposMsg,{"MSG_DT_REG","C",10,0})
	Aadd(aCamposMsg,{"MSG_HR_REG","C",5,0})
	//cAliasMsg := CriaTabTmp(aCamposMsg,{"AST_ID+MSG_ID"},cAliasMsg) //yuri iuchi
	cAliasMsg := SCriaTbTmp({aCamposMsg,{'AST_ID','MSG_ID','MSG_USU_ID','MSG_DEP_ID'}})

	Aadd(aCamposDes,{"AST_ID","C",10,0})
	Aadd(aCamposDes,{"MSG_ID","C",10,0})
	Aadd(aCamposDes,{"DES_ID","C",12,0})
	Aadd(aCamposDes,{"DES_NM","C",30,0})
	//cAliasDes := CriaTabTmp(aCamposDes,{"AST_ID+MSG_ID+DES_ID"},cAliasDes)
	cAliasDes := SCriaTbTmp({aCamposDes,{'AST_ID','MSG_ID','DES_ID'}})
   
Return .T.

/*/{Protheus.doc}
@author Marcelo Nunes
@version P12
@Since	10/02/2016
@obs Monta dados da tabela temporaria
/*/
Static Function A903CAR_TB()
	Local cAliTABAst := GetNextAlias()
	Local aArrTABAst := {}
	Local cAliTABMsg := GetNextAlias()
	Local aArrTABMsg := {}
	Local cAliTABDes := GetNextAlias()
	Local aArrTABDes := {}
	Local aAreaAnt   := GetArea()

    //TABELA PRINCIPAL
	cQuery :=     " Select  "
	cQuery +=            " Cast(REPLICATE('0', 10 - LEN(msg_id)) + RTrim(msg_id) as VarChar(10)) as AST_ID, "
	cQuery +=            " msg_assunto as AST_DESC, "
	cQuery +=            " Convert(VarChar, msg_data_registro, 103) as AST_DT_REG, "
	cQuery +=            " Convert(VarChar, msg_data_registro, 108) as AST_HR_REG "
	cQuery +=       " From Tab_msg_rf"
	cQuery += " order by msg_id "

	cQuery := ChangeQuery(cQuery)

	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliTABAst,.F.,.T.)

	DbSelectArea(cAliTABAst)

	While !(cAliTABAst)->(Eof())
		Aadd(aArrTABAst,{;
			(cAliTABAst)->AST_ID, ;
			(cAliTABAst)->AST_DESC, ;
			(cAliTABAst)->AST_DT_REG, ;
			(cAliTABAst)->AST_HR_REG;
			})
		(cAliTABAst)->(DbSkip())
	EndDo
	(cAliTABAst)->(DbCloseArea())
	cAliasAst := A903CARDAD(cAliasAst,aArrTABAst,aCamposAst)
   
   
	cQuery :=     " Select  "
	cQuery +=            " Cast(REPLICATE('0', 10 - LEN(msg_id)) + RTrim(msg_id) as VarChar(10)) as AST_ID, "
	cQuery +=            " Cast(REPLICATE('0', 10 - LEN(rmsg_id)) + RTrim(rmsg_id) as VarChar(10)) as MSG_ID, "
	cQuery +=            " usu_id as MSG_USU_ID, "
	cQuery +=            " Cast(REPLICATE('0', 3 - LEN(dep_id)) + RTrim(dep_id) as VarChar(3)) as MSG_DEP_ID, "
	cQuery +=            " Cast(rmsg_texto as VarChar(4000)) as MSG_TEXTO, "
	cQuery +=            " Convert(VarChar, rmsg_data, 103) as MSG_DT_REG, "
	cQuery +=            " Convert(VarChar, rmsg_data, 108) as MSG_HR_REG "
	cQuery +=       " From rel_msg_rf"
	cQuery += " order by msg_id, rmsg_id "

	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliTABMsg,.F.,.T.)

	DbSelectArea(cAliTABMsg)
	While !(cAliTABMsg)->(Eof())
		Aadd(aArrTABMsg,{;
			(cAliTABMsg)->AST_ID, ;
			(cAliTABMsg)->MSG_ID, ;
			(cAliTABMsg)->MSG_USU_ID, ;
			(cAliTABMsg)->MSG_DEP_ID, ;
			(cAliTABMsg)->MSG_TEXTO, ;
			(cAliTABMsg)->MSG_DT_REG, ;
			(cAliTABMsg)->MSG_HR_REG;
			})
		(cAliTABMsg)->(DbSkip())
	EndDo
	(cAliTABMsg)->(DbCloseArea())
	cAliasMsg := MntCargDad(cAliasMsg,aArrTABMsg,aCamposMsg)

	cQuery :=     " Select "
	cQuery +=            " Cast(REPLICATE('0', 10 - LEN(msg_id)) + RTrim(msg_id) as VarChar(10)) as AST_ID, "
	cQuery +=            " Cast(REPLICATE('0', 10 - LEN(a.rmsg_id)) + RTrim(a.rmsg_id) as VarChar(10)) as MSG_ID, "
	cQuery +=            " a.usu_id as DES_ID, "
	cQuery +=            " b.usu_nome as DES_NM "
	cQuery +=       " From rel_rfb_msg_usuarios a left join tab_usuarios b on a.usu_id = b.usu_id"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliTABDes,.F.,.T.)

	DbSelectArea(cAliTABDes)
	While !(cAliTABDes)->(Eof())
		Aadd(aArrTABDes,{;
			(cAliTABDes)->AST_ID, ;
			(cAliTABDes)->MSG_ID, ;
			(cAliTABDes)->DES_ID, ;
			(cAliTABDes)->DES_NM})
		(cAliTABDes)->(DbSkip())
	EndDo
	(cAliTABDes)->(DbCloseArea())
	cAliasDes := MntCargDad(cAliasDes,aArrTABDes,aCamposDes)

	aSize(aArrTABAst  ,0)
	aSize(aArrTABMsg  ,0)
	aSize(aArrTABDes  ,0)
	
	RESTAREA(aAreaAnt)
   
Return .T.

/*{Protheus.doc}
@author Marcelo Nunes
@version P12
@Since	10/02/2016
@obs Carga de dados nas tabelas temporarias
*/
static Function A903CARDAD(cAliasTab,arrayDados, arrayCampos)

	Local nCont := 0
	Local nCont1   := 0
	Local aAreaAnt   := GetArea()

	//-------------------------------------------------------------------
	// Limpa tabela temporária
	//-------------------------------------------------------------------
	dbSelectArea(cAliasTab)
	(cAliasTab)->( dbSetOrder(1) )
	EndTran()
	ZAP

	//-------------------------------------------------------------------
	// Carga de dados
	//-------------------------------------------------------------------
	For nCont := 1 To Len(arrayDados)
		RecLock(cAliasTab,.T.)
		For nCont1 := 1 To Len(arrayCampos)
			(cAliasTab)->&(arrayCampo[nCont1,1]) := arrayDados[nCont,nCont1]
		Next
		MsUnLock(cAliasTab)
	Next
	//dbGoTop()
	
	RESTAREA(aAreaAnt)
Return cAliasTab

Function A903FILTER(oBrowse)
	Local i := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	local cFilter := ''
	Local aAreaAnt   := getArea()

	aFilter := oFilter:GetFilter(.T.)
  
	for i := 1 to len(aFilter)
		if i = 1
			cFilter +=  aFilter[i][2]
		else
			cFilter += ' .or. ' + aFilter[i][2]
		endif
	next

	if AllTrim(cFilter) = ""
		(cAliasAst)->(DBClearFilter())
	else
		(cAliasAst)->(DbSetFilter({||&cFilter},cFilter) )
	endif
	oBrowse:refresh()
	
	RESTAREA(aAreaAnt)
	
return .T.

/*{Protheus.doc}
ModelDef MVC
@author Marcelo Nunes
@version P12
@Since	10/02/2016
@obs Contrução do Modelo de Dados
*/
Static Function ModelDef()
	Local oModel  	 := Nil
	Local oStrTABAst := FWFormModelStruct():New()
	Local oStrTABMsg := FWFormModelStruct():New()
	Local oStrTABDes := FWFormModelStruct():New()
	Default cAliasAst := getnextalias()
	Default cAliasMsg := GetNextAlias()
   
	/*****STRUCT*****/
    //TABELA PRINCIPAL
	oStrTABAst:AddTable(cAliasAst, {'AST_ID'},'Assuxnto')
	oStrTABAst:AddIndex(1,'01','AST_ID','Indice 1','','',.T.)
	oStrTABAst:AddField('Código'       ,'Código'       ,'AST_ID'    ,'C',10 ,0,Nil,{||.T.},Nil,.F.,,.T.,.T.,.F.)
	oStrTABAst:AddField('Assunto'      ,'Assunto'      ,'AST_DESC'  ,'C',150,0,Nil,{||.T.},Nil,.T.,,.F.,.F.,.F.)
	
    //Mensagem
	A903_SELDEP()
	oStrTABMsg:AddTable(cAliasMsg, {'AST_ID+MSG_ID'},"Mensagem")
	oStrTABMsg:AddIndex(1,'01',  'AST_ID+MSG_ID','index 1','','',.T.)
	oStrTABMsg:AddField('Código Assunto' ,'Código Assunto' ,'AST_ID'    ,'C',10  ,0,Nil,{||.T.},Nil,.F.,,.T.,.T.,.F.)
	oStrTABMsg:AddField('Código mensagem','Código mensagem','MSG_ID'    ,'C',10  ,0,Nil,{||.T.},Nil,.F.,,.T.,.T.,.F.)
	oStrTABMsg:AddField('Usuário'        ,'Usuário'        ,'MSG_USU_ID','C',12  ,0,Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.)
	oStrTABMsg:AddField('Departamento'   ,'Departamento'   ,'MSG_DEP_ID','C',3   ,0,Nil,{||.T.},a_DEPART,.T.,,.F.,.F.,.F.)
	oStrTABMsg:AddField('Mensagem'       ,'Mensagem'       ,'MSG_TEXTO' ,'M',4000,0,Nil,{||.T.},Nil,.T.,,.F.,.F.,.F.)
	
	oStrTABDes:AddTable(cAliasDes, {'AST_ID+MSG_ID+DES_ID'},"Destinatario")
	oStrTABDes:AddIndex(1,'01',  'AST_ID+MSG_ID+DES_ID','index 1','','',.T.)
	oStrTABDes:AddField('Código Assunto' ,'Código Assunto' ,'AST_ID','C',10 ,0,Nil,{||.T.},Nil,.F.,,.T.,.T.,.F.)
	oStrTABDes:AddField('Código mensagem','Código mensagem','MSG_ID','C',10 ,0,Nil,{||.T.},Nil,.F.,,.T.,.T.,.F.)
	oStrTABDes:AddField('Código Destinatário'   ,'Código Destinatário'   ,'DES_ID','C',12 ,0,{||A903_VDEST()} ,{||.T.},Nil,.F.,,.F.,.T.,.F.)
	oStrTABDes:AddField('Nome'                  ,'Nome'                  ,'DES_NM','C',30 ,0,Nil              ,{||.T.},Nil,.F.,,.F.,.T.,.F.)
	
	/*****MODEL*****/
    oModel := MPFormModel():New('PRAA903')
	oModel:SetDescription('Registro de Mensagens')
    oModel:AddFields('PRAA903', Nil, oStrTABAst,,,)
    
    oModel:AddGrid('PRAA903Msg','PRAA903',oStrTABMsg,,,,,{|oModel|PRAA903LD(oModel, cAliasMsg)})
	oModel:SetRelation('PRAA903Msg',{{'AST_ID', 'AST_ID'}},'AST_ID+MSG_ID')
	oModel:GetModel('PRAA903Msg'):SetDescription("Mensagem")
	oModel:GetModel('PRAA903Msg'):SetOptional(.T.)
      
	oModel:AddGrid('PRAA903Des','PRAA903Msg',oStrTABDes,,,,,{|oModel|PRAA903LD(oModel,cAliasDes)})
	oModel:SetRelation('PRAA903Des',{{'AST_ID', 'AST_ID'},{'MSG_ID','MSG_ID'}}, 'AST_ID+MSG_ID+DES_ID')
	oModel:GetModel('PRAA903Des'):SetDescription("Destinatários")
	oModel:GetModel('PRAA903Des'):SetOptional(.T.)

	oModel:SetPrimaryKey({'AST_ID'})
	
	oModel:InstallEvent("_A903EVENT",, _A903EVENT():New())
	
Return oModel

/*{Protheus.doc}
ViewDef MVC
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Contrução da Interface
*/
Static Function ViewDef()
	Local oModel := FWLoadModel('PRAA903')
	Local oStrTABAst := FWFormViewStruct():New()
	Local oStrTABMsg := FWFormViewStruct():New()
	Local oStrTABDes := FWFormViewStruct():New()
	Local oView      := Nil
   
	/*                  CIDFIELD    ,CORDEM,CTITULO        ,CDESCRIC       ,AHELP,CTYPE,CPICTURE    ,BPICTVAR,CLOOKUP,LCANCHANGE,CFOLDER,CGROUP,ACOMBOVALUES,NMAXLENCOMBO,CINIBROW,LVIRTUAL,CPICTVAR,LINSERTLINE*/
	oStrTABAst:AddField('AST_ID'    ,'01'  ,'Código'       ,'Código'       ,Nil  ,'GET',"@"         ,Nil     ,Nil    ,.F.       ,Nil    ,Nil   ,Nil         ,Nil         ,Nil     ,.F.     ,Nil     ,.F.)
	oStrTABAst:AddField('AST_DESC'  ,'02'  ,'Assunto'      ,'Assunto'      ,Nil  ,'GET',"@"         ,Nil     ,Nil    ,.T.       ,Nil    ,Nil   ,Nil         ,Nil         ,Nil     ,.F.     ,Nil     ,.F.)
         
	/*                  CIDFIELD    ,CORDEM,CTITULO        ,CDESCRIC       ,AHELP,CTYPE,CPICTURE    ,BPICTVAR,CLOOKUP,LCANCHANGE,CFOLDER,CGROUP,ACOMBOVALUES,NMAXLENCOMBO,CINIBROW,LVIRTUAL,CPICTVAR,LINSERTLINE*/
	oStrTABMsg:AddField('MSG_ID'    ,'01'  ,'Sequência'    ,'Sequência'    ,Nil  ,'GET',"@"         ,Nil     ,Nil    ,.F.       ,Nil    ,Nil   ,Nil         ,Nil         ,Nil     ,.F.     ,Nil     ,.F.)
	oStrTABMsg:AddField('MSG_TEXTO' ,'02'  ,'Mensagem'     ,'Mensagem'     ,Nil  ,'GET',"@"         ,Nil     ,Nil    ,.T.       ,Nil    ,Nil   ,Nil         ,Nil         ,Nil     ,.F.     ,Nil     ,.F.)
	oStrTABMsg:AddField('MSG_DEP_ID','03'  ,'Departamento Destinatários' ,'Departamento Destinatários' ,Nil,'GET',Nil ,Nil,Nil,.T.,Nil  ,Nil   ,a_DEPART    ,200         ,Nil     ,.F.     ,Nil     ,.F.)
      
	/*                  CIDFIELD    ,CORDEM,CTITULO        ,CDESCRIC       ,AHELP,CTYPE,CPICTURE    ,BPICTVAR,CLOOKUP,LCANCHANGE,CFOLDER,CGROUP,ACOMBOVALUES,NMAXLENCOMBO,CINIBROW,LVIRTUAL,CPICTVAR,LINSERTLINE*/
	oStrTABDes:AddField('DES_ID'    ,'01'  ,'Código Destinatário','Código Destinatário',Nil  ,'GET',"@"         ,Nil     ,'SARADT'    ,.T.       ,Nil    ,Nil   ,Nil         ,Nil         ,Nil     ,.F.     ,Nil     ,.F.)
	oStrTABDes:AddField('DES_NM'    ,'02'  ,'Nome','Nome',Nil  ,'GET',"@"         ,Nil     ,Nil    ,.F.       ,Nil    ,Nil   ,Nil         ,Nil         ,Nil     ,.F.     ,Nil     ,.F.)

	/*****VIEW*****/
    //CRIAÇÃO
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox('ASSUNTO' , 20,,,,)
	oView:CreateHorizontalBox('MENSAGEM' , 40,,,,)
	oView:CreateHorizontalBox('DESTINATARIO',40,,,,)
    //oView:CreateFolder("FOLDER","INFERIOR")

    //TABELA PRINCIPAL
	oView:AddField('PRAA903' , oStrTABAst)
	oView:SetOwnerView('PRAA903', 'ASSUNTO')
	oView:EnableTitleView( 'PRAA903','Assunto',0 )
  
	oView:AddGrid('PRAA903Msg', oStrTABMsg)
	oView:SetOwnerView('PRAA903Msg','MENSAGEM')
	oView:EnableTitleView( 'PRAA903Msg', "Mensagens", 0)
   
	oView:AddGrid('PRAA903Des', oStrTABDes)
	oView:SetOwnerView('PRAA903Des','DESTINATARIO')
	oView:EnableTitleView( 'PRAA903Des', "Destinatários", 0 )
   
	oView:AddIncrementField( 'PRAA903Msg','MSG_ID')
   
Return oView

static function MenuDef()
	local aRotina := {}

    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.PRAA903' OPERATION 2 ACCESS 0 DISABLE MENU  // 'Visualizar'
    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.PRAA903' OPERATION 3 ACCESS 0 DISABLE MENU  // 'Incluir'
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.PRAA903' OPERATION 4 ACCESS 0 DISABLE MENU   // 'Alterar'
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.PRAA903' OPERATION 5 ACCESS 0 DISABLE MENU   // 'Imprimir'
    ADD OPTION aRotina Title 'Imprimir'   Action 'VIEWDEF.PRAA903' OPERATION 8 ACCESS 0 DISABLE MENU 
    ADD OPTION aRotina Title 'Copiar'     Action 'VIEWDEF.PRAA903' OPERATION 9 ACCESS 0 DISABLE MENU 
   
return aRotina

Static Function A903_SELDEP()
    Local aAreaAnt := GetArea()
	Local tTabDep := GetNextAlias()

	cQuery := " select dep_descricao, Cast(REPLICATE('0', 3 - LEN(dep_id)) + RTrim(dep_id) as VarChar(3)) as dep_id from tab_departamento where dep_id <> 0 "
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabDep, .F., .T.)

	While (tTabDep)->(!Eof())
		aAdd(a_DEPART,CVALTOCHAR((tTabDep)->dep_id)+"="+AllTrim((tTabDep)->dep_descricao))
		(tTabDep)->(dbSkip())
	EndDo
	(tTabDep)->(DbCloseArea())
	
	RESTAREA(aAreaAnt)
Return .T.

//-----------------------------------
/*{Protheus.doc}
@author Marcelo Nunes
@version P12
@Since	04/03/2016
@obs Gravação de dados no banco SARA
*/
//-----------------------------------
static function A903OPE(omodel)
	Local oModelAst := oModel:GetModel('PRAA903')
	Local oModelMsg := oModel:GetModel('PRAA903Msg')
	Local oModelDes := oModel:GetModel('PRAA903Des')
	Local nOp       := oModel:getOperation()
	Local nStatus := 0
	Local nI
	Local nI2
	Local nRegOp
	Local cQryAux
	Local cAliasAux := GetNextAlias()
	Local nMaxMsgId := 0
	Local nMaxRMsgId := 0
	Local aAreaAnt   := GetArea()
    
	IF ((nOp == 3) .or. (nOp == 4)) //.and. retorno == .T. //inclusão //Alteração
			
        //Se for insert, calcula a nova chave primaria
		if nOp == 3
			cQryAux := "select IsNull(max(msg_id),0)+1 as msg_id from tab_msg_rf"
			cQryAux := ChangeQuery(cQryAux)
			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQryAux),cAliasAux,.F.,.T.)
			nMaxMsgId := allTrim(CValToChar((cAliasAux)->msg_id))
			(cAliasAux)->(dbCloseArea())
		    
			oModelAst:setvalue('AST_ID',nMaxMsgId)
		EndIf
		if (nOp == 3) .OR. (nOp == 4)
			nStatus :=  TcSqlExec("exec proc_diu_assunto_msg_rf "+cValToChar(nOp-1)+","+alltrim(oModelAst:GetValue('AST_ID'))+",'"+alltrim(oModelAst:GetValue('AST_DESC'))+"',null")
			IF  nStatus < 0
				cErro := AllTrim(TCSQLError())
				if AllTrim(cErro) <> ''
					oModel:SetErrorMessage('PRAA903',,,,,cErro)
					Return .F.
				EndIf
			EndIf
		EndIf
    //----------------------------------------------------------------------------------------------------------   
	
		For nI := 1 To oModelMsg:Length()
			oModelMsg:GoLine(nI)
					  
			nRegOp := 0 // Sem alteração
			If !oModelMsg:IsDeleted() .And. oModelMsg:IsInserted() // Inserção
				nRegOp := 2
			ElseIf !oModelMsg:IsDeleted() .And. !oModelMsg:IsInserted() .And. oModelMsg:IsUpdated()// Atualização
				nRegOp := 3
			ElseIf oModelMsg:IsDeleted() .And. !oModelMsg:IsInserted() // Exclusão
				nRegOp := 1
			EndIf
			if (alltrim(oModelMsg:GetValue('MSG_DEP_ID')) == '') .And. (alltrim(oModelMsg:GetValue('MSG_TEXTO'))== '')
				nRegOp := 0
			EndIf
	       
	    //Se for insert, calcula a nova chave primaria 
			if nRegOp = 2
				oModelMsg:setvalue('AST_ID',oModelAst:GetValue('AST_ID'))
				cQryAux := "SELECT isnull(MAX(rmsg_id),0) + 1 as rmsg_id FROM rel_msg_rf where msg_id = "+ alltrim(oModelMsg:GetValue('AST_ID'))
				cQryAux := ChangeQuery(cQryAux)
				DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQryAux),cAliasAux,.F.,.T.)
				nMaxRMsgId := allTrim(CValToChar((cAliasAux)->rmsg_id))
				oModelMsg:setvalue('MSG_ID',nMaxRMsgId)
				(cAliasAux)->(dbCloseArea())
			EndIf
	              
			If (nRegOp = 2) .OR. (nRegOp = 3)
				nStatus :=  TcSqlExec("exec proc_diu_msg_rf "+;
					cValToChar(nRegOp)+","+;
					alltrim(oModelMsg:GetValue('MSG_ID'))+","+;
					alltrim(oModelMsg:GetValue('AST_ID'))+","+;
					"'"+cUsuario+"',"+;
					alltrim(oModelMsg:GetValue('MSG_DEP_ID'))+",Null,"+;
					"'"+alltrim(oModelMsg:GetValue('MSG_TEXTO'))+"',"+;
					"null,null,null,''")
                 
				IF  nStatus < 0
					cErro := AllTrim(TCSQLError())
					if AllTrim(cErro) <> ''
						oModel:SetErrorMessage('PRAA903',,,,,cErro)
						Return .F.
					EndIf
				EndIf
			EndIf
			
			if nRegOp = 1
				TcSqlExec("delete from rel_rfb_msg_usuarios where msg_id = "+alltrim(oModelMsg:GetValue('AST_ID')) +;
					" and rmsg_id = "+alltrim(oModelMsg:GetValue('MSG_ID')) )
					
				IF  nStatus < 0
					cErro := AllTrim(TCSQLError())
					if AllTrim(cErro) <> ''
						oModel:SetErrorMessage('PRAA903',,,,,cErro)
						Return .F.
					EndIf
				EndIf
				
				TcSqlExec("delete from rel_msg_rf where msg_id = "+alltrim(oModelMsg:GetValue('AST_ID')) +;
					" and rmsg_id = "+alltrim(oModelMsg:GetValue('MSG_ID')) )
					
				IF  nStatus < 0
					cErro := AllTrim(TCSQLError())
					if AllTrim(cErro) <> ''
						oModel:SetErrorMessage('PRAA903',,,,,cErro)
						Return .F.
					EndIf
				EndIf
			EndIf
			
			For nI2 := 1 To oModelDes:Length()
				oModelDes:GoLine(nI2)
					  
				nRegOp := 0 // Sem alteração
				If !oModelDes:IsDeleted() .And. oModelDes:IsInserted() // Inserção
					nRegOp := 2
				ElseIf oModelDes:IsDeleted() .And. !oModelDes:IsInserted() // Exclusão
					nRegOp := 1
				EndIf
				if alltrim(oModelDes:GetValue('DES_ID')) == ''
					nRegOp := 0
				EndIf
	              
				If (nRegOp = 2)
					oModelDes:setvalue('AST_ID',oModelMsg:GetValue('AST_ID'))
					oModelDes:setvalue('MSG_ID',oModelMsg:GetValue('MSG_ID'))
			   
					nStatus :=  TcSqlExec("exec proc_diu_rel_msg_usuarios "+;
						cValToChar(nRegOp)+","+;
						alltrim(oModelDes:GetValue('MSG_ID'))+","+;
						alltrim(oModelDes:GetValue('AST_ID'))+","+;
						"'"+alltrim(oModelDes:GetValue('DES_ID'))+"'")
                 
					IF  nStatus < 0
						cErro := AllTrim(TCSQLError())
						if AllTrim(cErro) <> ''
							oModel:SetErrorMessage('PRAA903',,,,,cErro)
							Return .F.
						EndIf
					EndIf
				EndIf
				if nRegOp = 1
					TcSqlExec("delete from rel_rfb_msg_usuarios where msg_id = "+alltrim(oModelDes:GetValue('AST_ID')) +;
						" and rmsg_id = "+alltrim(oModelDes:GetValue('MSG_ID'))+;
						" and usu_id = '"+alltrim(oModelDes:GetValue('DES_ID'))+"'" )
					IF  nStatus < 0
						cErro := AllTrim(TCSQLError())
						if AllTrim(cErro) <> ''
							oModel:SetErrorMessage('PRAA903',,,,,cErro)
							Return .F.
						EndIf
					EndIf
				EndIf
			Next nI2
			
		Next nI
		
		
		
	EndIf
	
	if nOp == 5//deleta todas as tabelas
		TcSqlExec("delete from rel_rfb_msg_usuarios where msg_id = "+alltrim(oModelAst:GetValue('AST_ID')) )
		IF  nStatus < 0
			cErro := AllTrim(TCSQLError())
			if AllTrim(cErro) <> ''
				oModel:SetErrorMessage('PRAA903',,,,,cErro)
				Return .F.
			EndIf
		EndIf
	   
		TcSqlExec("delete from rel_msg_rf where msg_id = "+alltrim(oModelAst:GetValue('AST_ID')) )
		IF  nStatus < 0
			cErro := AllTrim(TCSQLError())
			if AllTrim(cErro) <> ''
				oModel:SetErrorMessage('PRAA903',,,,,cErro)
				Return .F.
			EndIf
		EndIf
		TcSqlExec("delete from tab_msg_rf where msg_id = "+alltrim(oModelAst:GetValue('AST_ID')) )
		IF  nStatus < 0
			cErro := AllTrim(TCSQLError())
			if AllTrim(cErro) <> ''
				oModel:SetErrorMessage('PRAA903',,,,,cErro)
				Return .F.
			EndIf
		EndIf
				
	EndIF
	
	A903CAR_TB()
	
	RESTAREA(aAreaAnt)
return .T.

Static Function A903TRDES(cDesId)
	Local cNomeUsu
	Local aAreaAnt := GetArea()
	Local cQuery := "select usu_id, usu_nome from tab_usuarios"+;
		" where usu_id = '" + cDesId+" ' "
	Local cAliasT := GetNextAlias()

	cQuery := ChangeQuery(cQuery)

	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasT,.F.,.T.)
	//(cAliasT)->(dbGoTop())

	If !(cAliasT)->(Eof()) .And. !Empty((cAliasT)->usu_id)
		cNomeUsu := AllTrim((cAliasT)->(usu_nome))
	EndIf
	(cAliasT)->(dbCloseArea())
	
	RESTAREA(aAreaAnt)
Return cNomeUsu

//-----------------------------------
/*{Protheus.doc}
Zoom dos campos

@author Marcelo Nunes
@version P12
@Since	24/02/16
@obs Funcao que monta zoom para os campos (Funcao infomada no dicionario de dados)
*/
//-----------------------------------
Function PRA903ZOOM(nTipoCon)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.
	Local oModel    := FWModelActive()
	Local oModelMSG
	Local aAreaAnt := GetArea()
	
	If ValType(oModel) != "U" .And. oModel:lActivate
		oModelMSG := oModel:GetModel('PRAA903Msg')
	EndIf

	cRetPRA903 := ''
   //Zoom destinatário e-mail
	if nTipoCon == 'DT'
		aZoom := SZoomDT(oModelMSG:GetValue('MSG_DEP_ID'))
	EndIf
   
	if SEmpty(aZoom)
		cRetPRA903 := ''
		return .T.
	else
		aRetZoom := PRAC938(aZoom, '', @lRet)
	endif

	if !SEmpty(aRetZoom)
		cRetPRA903 := STransType(aRetZoom[1],"C")
	else
		cRetPRA903 := ''
	endif
	
	RESTAREA(aAreaAnt)
Return lRet

static Function SZoomDT(Depart)
	Local aRet := {}
	Local aFields := {}
	Local cSql
	Local cFiltro := ''
	IF AllTrim(Depart) <> ''
		cFiltro := " and dep_id = "+Depart
	EndIf

	Aadd(aRet, 1)

	cSql := " SELECT usu_id, usu_nome, usu_email"
	cSql += "   FROM TAB_usuarios "
	cSql += "  WHERE usu_status = 1 " +cFiltro
   
	Aadd(aRet, cSql)
	Aadd(aRet, 'ORDER BY usu_nome')

              //aFields,   cCampo    ,  cDesc              , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "usu_id"    , 'Código do Usúario', "C"  , 12      , 0        , ""      , .T.     , .T., .T., 1)
	SAddPField(@aFields , "usu_nome"  , 'Nome'             , "C"  , 30      , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "usu_email" , 'E-mail'           , "C"  , 100     , 0        , ""      , .T.     , .F.)

	Aadd(aRet, aFields)

return aRet

static function A903_VDEST()
    Local aAreaAnt := GetArea()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelDes := oModel:GetModel('PRAA903Des')
	Local aTabUsu := GetNextAlias()
	
	IF AllTrim(oModelDes:GetValue('DES_ID')) <> ''
		cQuery := " SELECT USU_NOME FROM TAB_USUARIOS WHERE USU_ID = '"+oModelDes:GetValue('DES_ID')+"'"
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),aTabUsu, .F., .T.)
		IF AllTrim((aTabUsu)->USU_NOME) <> ''
			oModelDes:setvalue('DES_NM',(aTabUsu)->USU_NOME)
		Else
			lResult := .F.
		EndIf
		(aTabUsu)->(DbCloseArea())
	ELSE
		oModelDes:setvalue('DES_NM','')
	EndIf
	
	RESTAREA(aAreaAnt)

return lResult

Function SCodUsr903()
    Local aAreaAnt := GetArea()
	Local __SUsrSara := ''
	__SUsrSara := strtokarr(__ccredential,';')[4]
	RESTAREA(aAreaAnt)
Return __SUsrSara

Function PRAA903LD( oObj,cAliasT )
    Local aArea   := GetArea() 
	Local aFields := {}
	Local aRet    := {} 
	Local cFields := 'R_E_C_N_O_ RECNO'
	Local cTmp    := ''
	Local cQuery  := ''
	Local oGrid := oObj
	
	// Pega campos que fazem parte da estrutura do objeto, para otimizar retorno da query
	aFields := oGrid:GetStruct():GetFields()
	aEval( aFields, { |aX| IIf( !aX[MODEL_FIELD_VIRTUAL], cFields += ',' + aX[MODEL_FIELD_IDFIELD],) } )
	
	cTmp   := GetNextAlias() 
	cQuery := ""
	cQuery += "SELECT " + cFields + " FROM " + sGetRealName( cAliasT ) + " TAB"
	cQuery += " WHERE TAB.D_E_L_E_T_=' '"
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. ) 
	
	aRet := FWLoadByAlias( oGrid, cTmp ) 
	
	(cTmp)->( dbCloseArea() ) 
	
	RestArea( aArea ) 
	
Return aRet


