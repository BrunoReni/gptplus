#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PRAA801.CH"

static  aFuncao := {}
static  cFunDef := ''
static  aTipoDoc  := {'RG','CNH','CTPS','PASSAPORTE','OUTROS'} 
static  oBrwTab := nil

//---------------------------------
/*/{Protheus.doc}PRAA801
A função tem PRAA801() tem como objetivo:
1) Criar o Browser para representar os dados na GRID
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 01/04/2013
@return Retorna um boolean para a validacao
/*/
//---------------------------------
function PRAA801()
	Local aColsTab := {}
	Private  cAliasTab := 'tab_pessoas'

	A801CRTB()

	// Campos adicionais
	aColsTab:= {;
		{STR0014, {|| (cAliasTab)->pes_id}                     ,'C',"@!",0,10,0,.F.,,,,,,,,1},;
		{STR0015, {|| (cAliasTab)->pes_nome}		              ,'C',"@!",0,35,0,.F.,,,,,,,,1},;
		{STR0016, {|| (cAliasTab)->pes_rg} 		              ,'C',"@!",0,30,0,.F.,,,,,,,,1},;
		{STR0017, {|| (cAliasTab)->documento} 		          ,'C',"@!",0,10,0,.F.,,,,,,,,1},;
		{STR0018, {|| (cAliasTab)->pes_org_em}                 ,'C',"@!",0,8,0,.F.,,,,,,,,1},;
		{STR0019, {|| (cAliasTab)->pes_dt_em}                  ,'D',"@!",0,11,0,.F.,,,,,,,,1},;
		{STR0020, {|| (cAliasTab)->pes_cpf}                    ,'C',"@!",0,9,0,.F.,,,,,,,,1},;
		{STR0021, {|| (cAliasTab)->pes_cnh}                    ,'C',"@!",0,7,0,.F.,,,,,,,,1},;
		{STR0022, {|| (cAliasTab)->pes_rg_uf}                  ,'C',"@!",0,8,0,.F.,,,,,,,,1},;
		{STR0023, {|| (cAliasTab)->pes_pais}                   ,'C',"@!",0,8,0,.F.,,,,,,,,1},;
		{STR0024, {|| IIF((cAliasTab)->pes_bloq == .T., 'SIM','NAO')} ,'C',"@!",0,6,0,.F.,,,,,,,,1},;
		{STR0025, {|| (cAliasTab)->pes_dt_bl}                  ,'D',"@!",0,8,0,.F.,,,,,,,,1},;
		{STR0026, {|| (cAliasTab)->pes_motblq}                 ,'C',"@!",0,25,0,.F.,,,,,,,,1};
	}

	(cAliasTab)->(dbsetorder(2))
	oBrwTab := FWMBrowse():New()
	oBrwTab:SetAlias(cAliasTab)
	oBrwTab:SetFields(aColsTab)
	oBrwTab:SetMenuDef('PRAA801')
	oBrwTab:SetProfileID('1')
	oBrwTab:SetDescription(STR0001)
	oBrwTab:DisableDetails()
	oBrwTab:SetUseFilter(.T.)

	oBrwTab:Activate()

	delTabTmp('tab_pessoas')
	dbClearAll()
return nil

/*
{Protheus.doc}
A função tem A801CRTB() tem como objetivo:
1) Criar a tabela que vai alimentar a GRId
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 01/04/2013
@return Retorna um boolean para a validacao
*/
static Function A801CRTB()
	Local cAlias := GetNextAlias()
	Local aArrayTab  := {}
	Local aCamposTab := {}

	cQuery	:=	" select    a.pes_id, "+;
				"			  a.pes_nome, "+;
				"			  a.pes_rg, "+;
				"			  a.pes_rg_uf, "+;
				"			  a.pes_funcao, "+;
				"			  b.ustipo_descricao as func_desc, "+;
				"			  a.pes_bloqueio as pes_bloq, "+;
				"			  convert(VarChar, a.pes_dt_bloqueio, 103) as pes_dt_bl, "+;
				"			  convert(varchar(255),(CONVERT(varbinary(255),a.pes_foto))) as pes_foto, "+;
				"			  a.pes_motivobloq as pes_motblq, "+;
				"			  a.pes_tipo_doc as pes_tip_dc, "+;
				" 			  case when a.pes_tipo_doc = 0 then '' "+;
	            "                when a.pes_tipo_doc = 1 then 'RG'  "+;
	            "                when a.pes_tipo_doc = 2 then 'CNH' "+;
	            "                when a.pes_tipo_doc = 3 then 'CTPS' "+;
	            "                when a.pes_tipo_doc = 4 then 'PASSAPORTE' "+;
	            "                when a.pes_tipo_doc = 5 then 'OUTROS' "+;
	            "                end as documento,	"+;
				"			  a.pes_pais, "+;
				"			  a.pes_cpf, "+;
				"			  a.pes_cnh, "+;
				"			  convert(VarChar, a.pes_dt_cnh, 103) as pes_dt_cnh, "+;
				"			  convert(VarChar,a.pes_dt_emissao, 103) as pes_dt_em, "+;
				"			  a.pes_orgao_emissor as pes_org_em, "+;
				"			  a.pes_contato as pes_contat "+;
				"			from tab_pessoas a "+;
	            "          left join tab_usuario_tipo b "+;
	            "             on a.pes_funcao = b.ustipo_id ";

		cQuery := ChangeQuery(cQuery)
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)

		dbSelectArea(cAlias)
		(cAlias)->( dbGoTop() )
		While !(cAlias)->( Eof() )
				AAdd(aArrayTab,{alltrim(str((cAlias)->pes_id)),(cAlias)->pes_nome,(cAlias)->pes_rg,;
					(cAlias)->pes_rg_uf,(cAlias)->pes_funcao,(cAlias)->func_desc, IIF(STransType((cAlias)->pes_bloq, 'N') == 0, .F., .T.), (cAlias)->pes_dt_bl, (cAlias)->pes_foto,;
					(cAlias)->pes_motblq,(cAlias)->pes_tip_dc,(cAlias)->documento,(cAlias)->pes_pais,;
					(cAlias)->pes_cpf,(cAlias)->pes_cnh, stranstype((cAlias)->pes_dt_cnh,'D'),stranstype((cAlias)->pes_dt_em,'D'),;
					(cAlias)->pes_org_em,(cAlias)->pes_contat})

				(cAlias)->(dbSkip())
		Enddo
		(cAlias)->( DBCloseArea())

		AAdd(aCamposTab,{'pes_id','C',10,0})
		AAdd(aCamposTab,{'pes_nome','C',50,0})
		AAdd(aCamposTab,{'pes_rg','C',15,0})
		AAdd(aCamposTab,{'pes_rg_uf','C',16,0})
		AAdd(aCamposTab,{'pes_funcao','N',10,0})
		AAdd(aCamposTab,{'func_desc','C',50,0})
		AAdd(aCamposTab,{'pes_bloq','L',1,0})
		AAdd(aCamposTab,{'pes_dt_bl','C',50,0})
		AAdd(aCamposTab,{'pes_foto','C',50,0})
		AAdd(aCamposTab,{'pes_motblq','C',30,0})
		AAdd(aCamposTab,{'pes_tip_dc','N',10,0})
		AAdd(aCamposTab,{'documento','C',10,0})
		AAdd(aCamposTab,{'pes_pais','C',30,0})
		AAdd(aCamposTab,{'pes_cpf','C',11,0})
		AAdd(aCamposTab,{'pes_cnh','C',30,0})
		AAdd(aCamposTab,{'pes_dt_cnh','D',10,0})
		AAdd(aCamposTab,{'pes_dt_em','D',10,0})
		AAdd(aCamposTab,{'pes_org_em','C',15,0})
		AAdd(aCamposTab,{'pes_contat','C',255,0})

	    //Monta cAlias da tabela
		cAliasTab := criaTabTmp(aCamposTab,{'pes_id','pes_nome'},'tab_pessoas')
	   	cAliasTab := MntCargDad(cAliasTab,aArrayTab, aCamposTab)

Return .T.

Static function modeldef()
	
	Local oModel 
	Local oStructTab  := FWFormModelStruct():New()
	
    oModel := MPFormModel():New('PRAA801',,{|oModel|A801VAOK(oModel)})

	A801TUSU()

	//Monta Struct SD1
	oStructTab:AddTable('tab_pessoas', {'pes_id'},'pes_id')
	oStructTab:AddIndex(1,'1','pes_id','pes_id','','',.T.)

	//oStructTab:AddTrigger('tab_transportadora','trans_cgc',,{|oModel| PRAA800STA(oModel)})
	oStructTab:AddField(STR0014              ,STR0014              ,'pes_id'      				 ,'C',10  ,0,Nil,{||.T.},Nil,.F.,,.T.,.T.,.F.)
	oStructTab:AddField(STR0015                ,STR0015                ,'pes_nome'					 ,'C',50  ,0,Nil,{||.T.},Nil,.T.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0030    				,STR0030    ,'pes_funcao'				 ,'N',10  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0031        	  	,STR0031              ,'func_desc'				 ,'C',50  ,0,Nil,{||.T.},Nil,.T.,{|| cFunDef},.F.,.F.,.F.)
	oStructTab:AddField(STR0032       				,STR0032      ,'pes_tip_dc'				 ,'N',10  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0033                   ,STR0033,'documento'				 ,'C',10  ,0,Nil,{||.T.},Nil,.T.,{|| 'RG'},.F.,.F.,.F.)
	oStructTab:AddField(STR0034         		    ,STR0034                 ,'pes_rg' 					 ,'C',15  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0018                ,STR0018       ,'pes_org_em'             ,'C',20  ,0,Nil,{||.T.},Nil,.T.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0019                ,STR0019        ,'pes_dt_em'              ,'D',10  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0035        	    ,STR0035               ,'pes_rg_uf'				 ,'C',16  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0023                 ,STR0023                ,'pes_pais'  				 ,'C',30  ,0,Nil,{||.T.},Nil,.T.,{|| 'BRASIL'},.F.,.F.,.F.)
	oStructTab:AddField(STR0020                  ,STR0020                 ,'pes_cpf'                ,'C',11  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0036                  ,STR0042         ,'pes_cnh'                ,'C',30  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0037                  ,STR0037,'pes_dt_cnh'             ,'D',10  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0038              ,STR0038             ,'pes_contato'            ,'C',255 ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0039             ,STR0039            ,'pes_bloq' 				 ,'L',1   ,0,nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)

	oModel:AddFields('PRAA801', Nil, oStructTab,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetDescription(STR0001) //Embarque

	oModel:SetPrimaryKey({'pes_id'})
	
	oModel:InstallEvent("_A801EVENT",, _A801EVENT():New())
	
	oModel:SetActivate()

return omodel

//----------------------------------------------------------
// ViewDef
//----------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel('PRAA801')
	Local oStructTab := FWFormViewStruct():New()
	Local oView      := Nil
	Local aArPais:= {''}
	Local aArUF  := {''}

	oStructTab:AddGroup('GrpDados','Dados','',2)
	oStructTab:AddGroup('GrpBloqueio',STR0002,'',2)

	A801AUF(@aArUF)
	A801APA(@aArPais)

    //Monta Struct SD1
	oStructTab:AddField('pes_id'               ,'01',STR0014,STR0014,Nil,'GET',"@!",Nil,Nil,.F.,Nil,'GrpDados',Nil,Nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('pes_nome'             ,'02',STR0015,STR0015,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpDados',Nil,Nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('func_desc'            ,'03',STR0031,STR0031,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpDados',aFuncao,30,Nil,.F.,Nil,.F.)
	oStructTab:AddField('documento'            ,'04',STR0032,STR0032,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpDados',aTipoDoc,30,Nil,.F.,Nil,.F.)
	oStructTab:AddField('pes_rg'               ,'05',STR0016,STR0016,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpDados',Nil,Nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('pes_org_em'           ,'06',STR0018,STR0018,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpDados',Nil,Nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('pes_dt_em'            ,'07',STR0019,STR0019,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpDados',nil,nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('pes_rg_uf'            ,'08',STR0022,STR0022,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpDados',aArUF,2,Nil,.F.,Nil,.F.)
	oStructTab:AddField('pes_pais'             ,'09',STR0023,STR0023,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpDados',aArPais,30,Nil,.F.,Nil,.F.)
	oStructTab:AddField('pes_cpf'              ,'10',STR0043,STR0043,Nil,'GET',"@R 99.9999.999-99",Nil,Nil,.T.,Nil,'GrpDados',Nil,Nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('pes_cnh'              ,'11',STR0042,STR0042,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpDados',nil,nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('pes_dt_cnh'           ,'12',STR0037,STR0037,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpDados',nil,nil,Nil,.F.,Nil,.T.)
	oStructTab:AddField('pes_contato'          ,'13',STR0038,STR0038,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpDados',Nil,Nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('pes_bloq'             ,'14',STR0039,STR0039,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpBloqueio',Nil,Nil,nil,.F.,Nil,.F.)

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'MASTER' , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddField('PRAA801' , oStructTab)

	// Associa um View a um box
	oView:SetOwnerView('PRAA801', 'MASTER')
   	oView:SetUseCursor(.F.)

Return oView

static function menuDEF()
	local arotina := {}

	add option arotina title STR0003 action 'VIEWDEF.PRAA801' operation 1 access 0
	add option arotina title STR0004   action 'Viewdef.PRAA801' operation 3 access 0
	add option arotina title STR0005   action 'Viewdef.PRAA801' operation 4 access 0
	add option arotina title STR0006   action 'Viewdef.PRAA801' operation 5 access 0
return arotina

/*
{Protheus.doc}
A função tem A801AUF() tem como objetivo:
1) Alimentar o array aArUF com todos os estados, conforme a consulta a tabela tab_estado
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 01/04/2013
@return Retorna um boolean para dizer se a operacao foi bem concluída ou nao.
*/
static Function A801AUF(aArUF)
	local cAliasUF := ''

	cAliasUF := SGetNAlias()
	cQuery := " select uf_id from tab_estado "
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasUF, .F., .T.)

	//Carga Combo Estado
	While (cAliasUF)->(!Eof())
		aAdd( aArUF, (cAliasUF)->(FieldGet(1)))
  		(cAliasUF)->(dbSkip())
	EndDo
Return .T.


/*
{Protheus.doc}
A função tem A801APA() tem como objetivo:
1) Alimentar o array aArPais com todos os paises, conforme a consulta a tabela tab_pais
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 01/04/2013
@return Retorna um boolean para dizer se a operacao foi bem concluída ou nao.
*/
static Function A801APA(aArPais)
   local cAliasP := ''

	cAliasP := SGetNAlias()
	cQuery := " select pais_nome from tab_pais "
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasP, .F., .T.)

    //Carga combo Pais
	While (cAliasP)->(!Eof())
		aAdd( aArPais,alltrim((cAliasP)->(FieldGet(1))))
  		(cAliasP)->(dbSkip())
	EndDo
Return .T.

/*
{Protheus.doc}
A função tem A801TUSU() tem como objetivo:
1) Alimentar o array aFuncao( array global) com todo as funcoes que o usuraio pode ser conforme a tabela tab_usuario_tipo
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 01/04/2013
@return Retorna um boolean para dizer se a operacao foi bem concluída ou nao.
*/
static Function A801TUSU()
	local cAliasF := ''
	cFunDef := ''

	cAliasF := SGetNAlias()
	cQuery := "select ustipo_id, ustipo_descricao, case upper(ustipo_descricao) when 'FUNCIONARIO' THEN 'S' ELSE 'N' end from tab_usuario_tipo"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasF, .F., .T.)

    //Carga combo Pais
	While (cAliasF)->(!Eof())
		aAdd( aFuncao,(cAliasF)->(FieldGet(2)))
		if ((cAliasF)->(FieldGet(3)) == 'S')
			cFunDef := (cAliasF)->(FieldGet(1))
		endif
  		(cAliasF)->(dbSkip())
	EndDo

Return .T.

/*
{Protheus.doc}
A função tem A801OPER() tem como objetivo:
1) Realizar a operacao de insert, update e delete da tabela pessoas.
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 01/04/2013
@return Retorna um boolean para dizer se a operacao foi bem concluída ou nao.
*/
Static Function A801OPER(oModel)
	Local oModelTab := oModel:GetModel('PRAA801')
	Local nOp       := oModel:getOperation()
	Local lError := .F.
	Local i:=1
	Local bError := errorBlock({|e| SMSGERRO( e, @lError ) })
	Local cTipDoc := ''
	Local cTipDocArray := ''
	Local aResult := {}
	Local cQueryConsulta := ''
	Local cAliasConsulta := SGetNAlias()
	Local cFunTipo := ''
	Local cDocum    := ''

	If nOp == 3 .or. nOP == 4

		if (alltrim(oModelTab:GetValue('func_desc')) <> '')
			cQueryConsulta :=	"select ustipo_id from tab_usuario_tipo where ustipo_descricao = '"+alltrim(oModelTab:GetValue('func_desc'))+"'"
			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQueryConsulta),cAliasConsulta,.F.,.T.)
			cFunTipo := alltrim(str((cAliasConsulta)->(fieldget(1))))
			dbclosearea(cAliasConsulta)
		endif

		if (alltrim(oModelTab:GetValue('documento')) != '' )
			i:= 1
			cTipDoc := alltrim(oModelTab:GetValue('documento'))
			cTipDocArray := aTipoDoc[i]
			While (alltrim(cTipDoc) <> alltrim(cTipDocArray))
				i++
				cTipDocArray := aTipoDoc[i]
			EndDo
			cDocum := alltrim(str(i-1))
		endif


		aResult := TCSPExec("proc_diu_pessoas_w",;
			IIF(nOp==3,2,3),;
			IIF(nOp==3,'',alltrim(oModelTab:GetValue('pes_id'))),;
			alltrim(oModelTab:GetValue('pes_nome')),;
			alltrim(oModelTab:GetValue('pes_rg')),;
			alltrim(oModelTab:GetValue('pes_rg_uf')),;
			cFunTipo,;
			IIF(oModelTab:GetValue('pes_bloq'),'1','0'),;
			cDocum,;
			alltrim(oModelTab:GetValue('pes_pais')),;
			alltrim(oModelTab:GetValue('pes_cpf')),;
			alltrim(oModelTab:GetValue('pes_cnh')),;
			IIF(len(alltrim(dtoc(oModelTab:GetValue('pes_dt_em')))) > 4, SDBDField(oModelTab:GetValue('pes_dt_em')), ''),;
			alltrim(oModelTab:GetValue('pes_org_em')),;
			IIF(len(alltrim(dtoc(oModelTab:GetValue('pes_dt_cnh')))) > 4, SDBDField(oModelTab:GetValue('pes_dt_cnh')), ''),;
			alltrim(oModelTab:GetValue('pes_contato')))

      		IF empty(aResult)
         		oModel:SetErrorMessage('PRAA800','trans_cgc',   ,  ,       ,AllTrim(PRAA801VMSG(TCSQLError())) )
         		Return .F.
			endif

			if (nOp == 3)
				oModelTab:setvalue('pes_id', AllTrim(Str(aResult[2])))
			endif
	endif

	If nOp == 5

		//verificar relacionamento na tab_cesv
		cQueryConsulta :=	" select cesv_id from tab_cesv where pes_id = " +alltrim(oModelTab:GetValue('pes_id'))
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQueryConsulta),cAliasConsulta,.F.,.T.)
		if (!SEmpty((cAliasConsulta)->(fieldget(1))))
			dbclosearea(cAliasConsulta)
			oModel:SetErrorMessage('PRAA801',STR0007,,,,STR0007 )
			return .F.
		else
			dbclosearea(cAliasConsulta)
		endif

		aResult := TCSPExec("proc_diu_pessoas_w",;
			1,;
			alltrim(oModelTab:GetValue('pes_id')),;
			' ',;
			' ',;
			' ',;
			'0',;
			' ',;
			'0',;
			' ',;
			' ',;
			' ',;
			' ',;
			' ',;
			' ',;
			' ')

      		IF empty(aResult)
         		oModel:SetErrorMessage('PRAA800','trans_cgc',   ,  ,       ,AllTrim(PRAA801VMSG(TCSQLError())) )
         		Return .F.
			endif
	EndIf

	FwFormCommit(oModel)

Return .T.

/*
{Protheus.doc}
A função tem A801VAOK() tem como objetivo:
1) Realizar a verificacao de todas as regras de negocio no momento em que o usuário realizar uma operacao(apertar o botao confirma da tela de Cadastro).
2) Dentre as validacoes estao : a)Nome do usuario tenha mais que 5 caracteres
								b)Data de validade da habilitação seja obrigatório caso o usuario tenha funcao de MOTORISTA e a data de habilitacao esteja vazio e o valor do parametro seja S
									c)O CPF/CIC esteja Inválido.
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 01/04/2013
@return Retorna um boolean para dizer se foi bem sucedido a operacao ou nao.
*/
static function A801VAOK(oModel)
	Local nOp    := (oModel:getOperation())
	Local oModelTab := oModel:GetModel('PRAA801')
	Local cCPF := ''

	If nOp == 3 .or. nOp == 4
		if len(AllTrim(oModelTab:GetValue('pes_nome'))) < 5
			oModel:SetErrorMessage('PRAA801','pes_nome','','','3000', STR0009,STR0010,nil,nil)
			return .f.
		endif

		cCPF := alltrim(oModelTab:GetValue('pes_cpf'))
		if ((len(AllTrim(oModelTab:GetValue('pes_rg'))) == 0) .AND. (len(cCPF) == 0))
			oModel:SetErrorMessage('PRAA801', '','','','3000',STR0040,STR0041,nil,nil)
			return .f.
		endif

		if ((len(cCPF) > 0) .AND. (A801VCPF(cCPF) == .F.))
			oModel:SetErrorMessage('PRAA801', '','','','3000',STR0013,nil,nil)
			return .f.
		endif

		if (alltrim(oModelTab:GetValue('func_desc')) == "MOTORISTA") .and. (A801VPAR()) .and. ((len(alltrim(dtoc(oModelTab:GetValue('pes_dt_cnh'))))) < 10)
			oModel:SetErrorMessage('PRAA801', '','','','3000',STR0011,STR0012,nil,nil)
			return .f.
		endif
	endif

Return .T.


/*
{Protheus.doc}
A função tem A801VPAR() tem como objetivo:
1) Pegar o valor do parametro DATA_VALIDADE_CNH_OBRIGATORIO.
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 01/04/2013
@return Retorna um boolean para verificar se o valor do parametor eh igual a S(true), senao retorna false.
*/
static Function A801VPAR()
   local cAliasPam := ''

	cAliasPam := SGetNAlias()
	cQuery := "select param_valor from tab_parametro where param_desc = 'DATA_VALIDADE_CNH_OBRIGATORIO'"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasPam, .F., .T.)

    //Carga combo Pais
	if alltrim((cAliasPam)->param_valor) == 'S'
		return .T.
	else
		return .F.
	end

Return .T.

/*
{Protheus.doc}
A função tem A801VCPF() tem como objetivo:
1) Fazer a validacao de um determinado CPF ou cic
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 01/04/2013
@return Retorna um boolean para verificar se cpf/cic eh valido ou nao.
*/
static FUNCTION A801VCPF(num_cpf)
	LOCAL i,ii,soma,controle,digito,num

	IF (Empty(num_cpf)) .OR. (LEN(num_cpf) < 11)
		RETURN(.F.)
	ELSE
		controle= ""
		num= 10

		FOR ii= 1 TO 2
			soma= 0
			FOR i= 1 TO 9
				soma+= (VAL(SUBSTR(num_cpf,i,1))*num)
				num--
			NEXT
			IF ii= 2
				soma+= (2*VAL(controle))
			ENDIF
			digito= soma - (INT(soma/11)*11)
			IF digito= 0 .OR. digito= 1
				controle= controle + "0"
			ELSE
				controle= controle + STR(11-digito,1)
			ENDIF
			num= 11
		NEXT
		IF controle != SUBST(num_cpf,10,2)
			RETURN(.F.)
		ENDIF
	ENDIF
RETURN(.T.)

Static function PRAA801VMSG(cMsg)
	Local nIni := At('Server]', cMsg)
	Local nFim := At('( From', cMsg)

return SubStr(cMsg, nIni + 7, (nFim - nIni - 7))



