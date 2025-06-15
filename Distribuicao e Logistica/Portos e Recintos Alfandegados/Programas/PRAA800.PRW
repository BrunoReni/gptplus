#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#include "praa800.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "PRCONST.CH"

static  aTipoPessoa  := {STR0009,STR0010,STR0011} 
static insert := .F.
static oBrwSD1  := Nil 
static cnt := 0
static v_cMarca := ''
static v_tipo := 0
static cli_id2 := ''
static armadorVelho := ''



/*/{Protheus.doc}
Requisito 02 do Projeto Unificacao de cadastro 
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 25/11/2013
@return nil
@obs: Cadastro de Clientes
@sample
/*/
//---------------------------------



//---------------------------------
/*/{Protheus.doc}
Função PRAA800 apresenta a tabela com o Browse na tela 
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
/*/
//---------------------------------
function PRAA800()
	Local aColsTab := {}
	Local aSeek := {}
	//Private cAliasTab := 'tab_clientes'
	Private cAliasTab := 'tab_clientes'
	static  oBrwTab := nil 
	
	Private cCodEmp := ''
	
	A8001CLI()
		
	A8001TCLI()
			
	// Campos adicionais
	/*
	aColsTab:= {;
    	{'Cód.',       {|| (cAliasTab)->cli_id}  ,'C',"@!",6,6,6,.F.,,,,,,,,1},;
		{STR0001,       {|| (cAliasTab)->cli_nome},'C',"@!",0,25,0,.F.,,,,,,,,1},;
		{STR0003,       {|| (cAliasTab)->cli_fant},'C',"@!",0,15,0,.F.,,,,,,,,1},;
		{STR0004,       {|| (cAliasTab)->tipo_pes_d},'C',"@!",0,0,0,.F.,,,,,,,,1},;
		{STR0005,       {|| (cAliasTab)->cli_cgc} ,'C',"@!",0,0,0,.F.,,,,,,,,1},;
		{STR0006,       {|| (cAliasTab)->cli_cpf} ,'C',"@!",0,0,0,.F.,,,,,,,,1},;		
    	{STR0007,       {|| (cAliasTab)->cli_ie}  ,'C',"@!",0,0,0,.F.,,,,,,,,1},;
    	{STR0008,       {|| (cAliasTab)->armador} ,'C',"@!",0,0,0,.F.,,,,,,,,1},;
    	{'Grupo empresarial', {|| (cAliasTab)->gru_nome} ,'C',"@!",0,0,0,.F.,,,,,,,,1};
	}
	*/
	Aadd(aColsTab,{'Cód.',"cli_id","C" ,0,0,})
	Aadd(aColsTab,{STR0001,"cli_nome","C" ,30,0,})
	Aadd(aColsTab,{STR0003,"cli_fant","C" ,0,0,})
	Aadd(aColsTab,{STR0004,"tipo_pes_d","C" ,5,5,})
	Aadd(aColsTab,{STR0005,"cli_cgc","C" ,14,0,})
	Aadd(aColsTab,{STR0006,"cli_cpf","C" ,11,0,})
	Aadd(aColsTab,{STR0007,"cli_ie","C" ,10,0,})
	Aadd(aColsTab,{STR0008,"armador","C" ,0,0,})
	Aadd(aColsTab,{STR0060,"gru_nome","C" ,0,0,})
	
	
	Aadd(aSeek,{STR0061, {{"","C",6,0,'cli_id',""}}, 1, .T. } )
    Aadd(aSeek,{STR0001 , {{"","C",30,0, 'cli_nome',}} , 2, .T. } )
    Aadd(aSeek,{STR0005 , {{"","C",14,0, 'cli_cgc',}} , 3, .T. } )
    Aadd(aSeek,{STR0006 , {{"","C",11,0, 'cli_cpf',}} , 4, .T. } )
    /*
    Aadd(aSeek,{STR0006 , {{"","C",10,0, 'cli_cpf'}} , 3, .T. } )
    Aadd(aSeek,{'Grupo empresarial' , {{"","C",10,0, 'gru_nome'}} , 4, .T. } )
	*/
	
	//cAliasTab := criaTabTmp(aCamposTab,{'cli_id','cli_cgc','cli_cpf','gru_nome'},'tab_clientes')
	(cAliasTab)->(dbsetorder(1)) 
	  
	oBrwTab := FWMBrowse():New()
	oBrwTab:SetAlias(cAliasTab)
	oBrwTab:SetFields(aColsTab)   
	oBrwTab:SetMenuDef('PRAA800')
	oBrwTab:SetSeek(.T.,aSeek)
	oBrwTab:SetLocate()
	oBrwTab:SetTemporary(.T.)
	oBrwTab:DisableDetails()
	oBrwTab:Activate()
	
	delTabTmp(cAliasTab)

	dbClearAll()
	
Return nil



//---------------------------------
/*/{Protheus.doc}
Função A8001TCLI monta a tabela temporaria  tab_tipo_cliente para apresentar no Markbrowse
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
function A8001TCLI()
	Local cAlias := GetNextAlias()
	Local aArrayTab  := {}
	Local aCamposTab := {}
	
	
	// Movimento do SD1
	cQuery := ' select tcli_id, tcli_descricao as tcli_desc'+;	
			   '    from tab_tipo_cliente '; 
				  
	           
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)

	dbSelectArea(cAlias)
	(cAlias)->( dbGoTop() )
	While !(cAlias)->( Eof() )		
		AAdd(aArrayTab,{			'  ',;
									alltrim(str((cAlias)->tcli_id)),;
									(cAlias)->tcli_desc;
									})
				
		(cAlias)->( dbSkip() )
	Enddo                         
	(cAlias)->( DBCloseArea())
	
	AAdd(aCamposTab,{'DO_MARK'   ,'C',2,0})
	AAdd(aCamposTab,{'tcli_id'   ,'C',6,0})
	AAdd(aCamposTab,{'tcli_desc' ,'C',40,0})
    
    
    // Monta cAlias da tabela   	
   	If Select('tab_tipo_cliente') == 0
		criaTabTmp(aCamposTab,{'tcli_id'},'tab_tipo_cliente')
	Else   
		//------------------------
		// Limpa tabela temporária
		//------------------------
		dbSelectArea('tab_tipo_cliente')
		('tab_tipo_cliente')->( dbSetOrder(1) )
		ZAP
		
	EndIf
	MntCargDad('tab_tipo_cliente',aArrayTab,aCamposTab)	
return .T.


//---------------------------------
/*/{Protheus.doc}
Função A8001CLI monta a table temporaria  tab_clientes que vai ser o modelo para os dados
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
function A8001CLI()
	Local cAlias := GetNextAlias()
	Local aArrayTab  := {}
	Local aCamposTab := {}
	
	// Movimento do SD1
	cQuery := " SELECT a.cli_id, "+;
	           "        a.cli_nome, "+;
	           "        a.cli_nomefan as cli_fant, "+;
	           "        a.cli_cgc, "+;
	           "        a.cli_cpf, "+;
	           "        a.cli_ie, "+;
	           "        c.trans_id, "+;
	           "        c.permisso, "+;
	           "        a.gru_id, "+;
	           "        e.gru_nome, "+;
	           "        b.arma_id as armador,b.arma_nome, "+;
	           "        d.ag_id as agente, "+;	
	          "   case when ((a.cli_cgc <> '' ) or (a.cli_cgc is not null )) and (a.cli_cgc = a.cli_id)      "+; 
			  "				then  'E' 	"+;
			  "			when ((a.cli_cgc <> '' ) or (a.cli_cgc is not null )) and ((a.cli_cpf = '') or (a.cli_cpf is null))  "+; 
			"				then  'J'  "+;
			"			when ((a.cli_cgc <> '' ) or (a.cli_cgc is not null )) and (a.cli_cpf = a.cli_cgc) "+; 
			"				then  'F'  end as tipo_pes, "+;
			 "   case when ((a.cli_cgc <> '' ) or (a.cli_cgc is not null )) and (a.cli_cgc = a.cli_id)	"+;
			  "				then 'Estrangeiro' "+; 
			"			 when ((a.cli_cgc <> '' ) or (a.cli_cgc is not null )) and ((a.cli_cpf = '') or (a.cli_cpf is null)) "+;
			"				then 'Jurídica' "+; 
			"			 when  ((a.cli_cgc <> '' ) or (a.cli_cgc is not null )) and (a.cli_cpf = a.cli_cgc) " +;
			"              then 'Física'  end as tipo_pes_d " +;
	           "   FROM tab_clientes a "+;
	           " left join tab_armador b "+;
	           "     on b.cli_id = a.cli_id "+;
	           " left join tab_transportadora c "+;
	           "     on c.trans_nome = a.cli_nome "+;
	           " left join tab_agente d " +;
	           " 	  on d.cli_id = 	a.cli_id " +;
	           " left join tab_grupos e " +;
	           " 	  on e.gru_id = 	a.gru_id " ;
	           
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)

	dbSelectArea(cAlias)
	(cAlias)->( dbGoTop() )
	While !(cAlias)->( Eof() )		
		AAdd(aArrayTab,{AllTrim( (cAlias)->cli_id),;
									(cAlias)->cli_nome,;
									(cAlias)->cli_fant,;
									(cAlias)->cli_cgc, ;
									(cAlias)->cli_cpf, ;
									(cAlias)->cli_ie, ;
									IIF(alltrim(str((cAlias)->trans_id))='0','',alltrim(str((cAlias)->trans_id))),;
									(cAlias)->permisso,;
									(cAlias)->armador,;
									IIF(alltrim(str((cAlias)->agente)) = '0','',alltrim(str((cAlias)->agente))),;
									(cAlias)->tipo_pes,;
									(cAlias)->tipo_pes_d,;
									(cAlias)->gru_id,;
									(cAlias)->gru_nome,;
									(cAlias)->arma_nome;
									})
				
		(cAlias)->( dbSkip() )
	Enddo                         
	(cAlias)->( DBCloseArea())
	
	AAdd(aCamposTab,{'cli_id'   ,'C',6,0})
	AAdd(aCamposTab,{'cli_nome' ,'C',50,0})
    AAdd(aCamposTab,{'cli_fant' ,'C',30,0})
	AAdd(aCamposTab,{'cli_cgc'  ,'C',14,0})
	AAdd(aCamposTab,{'cli_cpf'  ,'C',11,0})
	AAdd(aCamposTab,{'cli_ie'   ,'C',15,0})
	AAdd(aCamposTab,{'trans_id' ,'C',5,0})
	AAdd(aCamposTab,{'permisso' ,'C',5,0})
	AAdd(aCamposTab,{'armador'  ,'C',4,0})
    AAdd(aCamposTab,{'agente'   ,'C',5,0})
    AAdd(aCamposTab,{'tipo_pes' ,'C',1,0})
    AAdd(aCamposTab,{'tipo_pes_d' ,'C',12,0})
    AAdd(aCamposTab,{'gru_id' ,'C',6,0})
    AAdd(aCamposTab,{'gru_nome' ,'C',30,0})
    AAdd(aCamposTab,{'arma_nome' ,'C',30,0})
    	
    // Monta cAlias da tabela
    
	//cAliasTab := criaTabTmp(aCamposTab,{'cli_id','cli_cgc','cli_cpf','gru_nome'},'tab_clientes')
	cAliasTab := criaTabTmp(aCamposTab,{'cli_id','cli_nome','cli_cgc','cli_cpf'}, 'tab_clientes')
   	cAliasTab := MntCargDad(cAliasTab,aArrayTab, aCamposTab)		

Return .T.



//---------------------------------
/*/{Protheus.doc}
Modeldef
/*/
//---------------------------------
Static function modeldef()
	
	Local oModel
    Local oStructTab  :=  FWFormModelStruct():New()
	Local oStructTab2 := FWFormModelStruct():New()
	
    oModel := MPFormModel():New('PRAA800',,{|oModel| A800VAOK(oModel)})
	
	//Monta a tabela tab_tipo_cliente
	oStructTab2:AddTable('tab_tipo_cliente', {'tcli_id'},'tcli_id')
	oStructTab2:AddIndex(1,'1','tcli_id','tcli_id','','',.T.)	
	oStructTab2:AddField(STR0001              ,STR0001               ,'tcli_id'      		      ,'C',6 ,0,Nil,{||.T.},Nil,.F.,,.T.,.T.,.F.)
	oStructTab2:AddField(STR0022     ,STR0022      ,'tcli_desc'            ,'C',40,0,Nil,{||.T.},Nil,.F.,,.T.,.T.,.F.)
	
	oStructTab:AddTable('tab_clientes', {'cli_id'},'cli_id')
	oStructTab:AddIndex(1,'1','cli_id','cli_id','','',.T.)
	oStructTab:AddField(STR0001       ,STR0001     ,'cli_id'      		  ,'C',6 ,0,Nil,{||.F.},Nil,.F.,,.T.,.T.,.F.)
	oStructTab:AddField(STR0013       ,STR0013     ,'cli_nome'		      ,'C',50  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0014       ,STR0014     ,'cli_fant'			  ,'C',30  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0015       ,STR0015     ,'tipo_pes'		      ,'C',1,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0016       ,STR0016     ,'cli_cpf'				  ,'C',17  ,0,{||A800VALCPF()},{||A800TIPO()},Nil,.F.,,.F.,.F.,.F.)	
	oStructTab:AddField(STR0017       ,STR0017     ,'cli_ie'				  ,'C',15  ,0,Nil,{||A801VIE()},Nil,.F.,,.F.,.F.,.F.)	
	oStructTab:AddField(STR0018       ,STR0018     ,'trans_id'			  ,'C',5  ,0,Nil,{||.F.},Nil,.F.,/*{||A800TRANS()}*/,.F.,.F.,.F.)
	oStructTab:AddField(STR0008       ,STR0008     ,'armador'			      ,'C',4  ,0,Nil,{|| A800VTST() },Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0008       ,STR0008     ,'arma_nome'			  ,'C',20  ,0,Nil,{|| .T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0019       ,STR0019     ,'agente'			      ,'C',5  ,0,Nil,{||.F.},Nil,.F.,/*{||A800AGEN()}*/,.F.,.F.,.F.)
	oStructTab:AddField(STR0020       ,STR0020     ,'permisso'			  ,'C',5   ,0,Nil,{||A800FRONT()},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0005       ,STR0005     ,'cli_cgc'			      ,'C',14  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0021       ,STR0021     ,'teste'			      ,'C',1,0,Nil,{||.T.},Nil,.F.,{||''},.F.,.F.,.F.)
	oStructTab:AddField(STR0022       ,STR0022     ,'tipo_pes_d'      	  ,'C',12 ,0,Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0062		  ,STR0062      ,'gru_id'      	  ,'C',6 ,0,{||VAL_GR_EMP()},{||.T.},nil,.F.,,.F.,.F.,.F.)
	oStructTab:AddField(STR0060       ,STR0060     ,'gru_nome'  ,'C',30 ,0,Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.)	
		
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields('ZA1MASTER',/*cOwner*/, oStructTab)

	oModel:SetDescription(STR0023)
	oModel:SetPrimaryKey({'cli_id'})
	
	oModel:InstallEvent("_A800EVENT",, _A800EVENT():New())
	
	oModel:SetActivate({|oModel|A800ARMA(oModel)})	
	oModel:SetActivate()
	
	
return omodel


static function A800VALCPF()
	Local oModel    := FWModelActive()
	local oView := FWViewActive()
    Local lRet := .T.
	Local nOp    := (oModel:getOperation())
	Local cAlias := GetNextAlias()
	
   if alltrim(oModel:getmodel('ZA1MASTER'):getvalue('tipo_pes')) == 'J'
   	  cQuery := " select cli_id from tab_clientes where cli_cgc = '" + alltrim(omodel:getmodel('ZA1MASTER'):getvalue('cli_cpf')) + "'"
   	  
   	  if nOp = 4
   	     cQuery := " and cli_id <> '" + alltrim(omodel:getmodel('ZA1MASTER'):getvalue('cli_id')) + "'"
   	  endif
   	  
   	  cQuery := ChangeQuery(cQuery)
	  DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	
	  if alltrim((cAlias)->cli_id) <> ''
	  	//oModel:SetErrorMessage('PRAA800','cli_cpf','','','3000','CPF/CNPJ já cadastrado', 'Insira um novo CPF/CNPJ' ,nil,nil)
	  	return .F.
	  else
	  	return .T.
	  endif
   elseif oModel:getmodel('ZA1MASTER'):getvalue('tipo_pes') == 'F' 
      cQuery := " select cli_id from tab_clientes where cli_cpf = '" + alltrim(omodel:getmodel('ZA1MASTER'):getvalue('cli_cpf')) + "'"
   	  cQuery := ChangeQuery(cQuery)
   	  
   	  if nOp = 4
   	     cQuery := " and cli_id <> '" + alltrim(omodel:getmodel('ZA1MASTER'):getvalue('cli_id')) + "'"
   	  endif
   	  
	  DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	
	  if alltrim((cAlias)->cli_id) <> ''
	  	//oModel:SetErrorMessage('PRAA800','cli_cpf',,,'3000','CPF/CNPJ já cadastrado', 'Insira um novo CPF/CNPJ' ,nil,nil)
	  	return .F.
	  else
	  	return .T.
	  endif
   else
   	 return .T.
   endif
   
   
return lRet

//---------------------------------
/*/{Protheus.doc}
Função A801VIE() verifica se habilita o campo IE. Habilita somente se for Pessoa Juridica.   
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
static function A801VIE()
    Local oModel    := FWModelActive()
	local oView := FWViewActive()
    Local lRet := .F.
	Local nOp    := (oModel:getOperation())
	
	if oModel:getmodel('ZA1MASTER'):getvalue('tipo_pes') == 'J'
      lRet := .T.
   elseif (alltrim(omodel:getmodel('ZA1MASTER'):getvalue('tipo_pes')) = '') .and. (nop = 3) 
      lRet := .T.
   else
   	  lRet := .F.
   endif
	 
return lRet

//---------------------------------
/*/{Protheus.doc}
Função A800ARMA inicia a armadorVelho com o valor do armador do modelo   
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
static function A800ARMA(omodel)
    Local lRet := .F.
	Local nOp    := (oModel:getOperation())
	
		
	armadorVelho := alltrim(oModel:getmodel('ZA1MASTER'):getvalue('armador'))
	
	
	    if 	alltrim(oModel:getmodel('ZA1MASTER'):getvalue('tipo_pes')) = 'J'
			oModel:getmodel('ZA1MASTER'):loadvalue('cli_cpf',alltrim(oModel:getmodel('ZA1MASTER'):getvalue('cli_cgc')))
		endif
	
	if nOp = 3
		oModel:getmodel('ZA1MASTER'):loadvalue('tipo_pes','J')
	endif
return .T.


//---------------------------------
/*/{Protheus.doc}
Função A800TIPO apaga o valor do campo cpf se a pessoa for do tipo estrangeiro  
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
static function A800TIPO()
	Local oModel    := FWModelActive()
	local oView := FWViewActive()
	Local lRet := .T.
	
	if  oModel:getmodel('ZA1MASTER'):getvalue('tipo_pes') == 'E'
		oModel:getmodel('ZA1MASTER'):loadvalue('cli_cpf','')
		oModel:getmodel('ZA1MASTER'):loadvalue('cli_ie','')
		oview:refresh()
		return .F.
	elseif  oModel:getmodel('ZA1MASTER'):getvalue('tipo_pes') == 'F'
		oModel:getmodel('ZA1MASTER'):loadvalue('cli_ie','')
		oview:refresh()
		return .T.
	else
		return .T.
	endif
return


//---------------------------------
/*/{Protheus.doc}
Função A800VTST realiza o when para o campo armador. Se na grid o armador estiver marcado,ativar o campo, senao manter desativado
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
function A800VTST()
		Local oModel    := FWModelActive()
		local oView := FWViewActive()
		
		if oBrwSD1 = nil
			if alltrim(oModel:getmodel('ZA1MASTER'):getvalue('armador')) <> ''
				return .T.
			else	
				return .F.
			endif
		else
			if (alltrim((oBrwSD1:Alias())->tcli_desc) = 'ARMADOR') .and. (oBrwSD1:ismark('OK'))
				return .T.
			else
				if alltrim(oModel:getmodel('ZA1MASTER'):getvalue('armador')) <> ''
					return .T.
				else
					if A800VMARK('ARMADOR') = .F.
			    		return .F.
			    	else
			    		return .T.
			    	endif
			    endif	
			endif  
		endif
return


//---------------------------------
/*/{Protheus.doc}
Função A800DESAB faz a habilitação/desabilitação do campo
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------

static function A800DESAB()
	local oView := FWViewActive()
	Local oModel    := FWModelActive()
	Local oStructModel    := oModel:GetModelStruct('ZA1MASTER')
    
   oModel:GetModel('ZA1MASTER'):setvalue('teste','')
   oview:EvalChanges()
   
   if (oBrwSD1 != nil) .and. (alltrim((oBrwSD1:Alias())->tcli_desc) = 'ARMADOR')
        if (alltrim(oModel:getmodel('ZA1MASTER'):getvalue('armador')) <> '') .and. (oBrwSD1:ismark('OK') = .F.) 
        		    		
        		oModel:loadValue('ZA1MASTER', 'armador','')
        		oview:refresh()	
        		oView:GetViewObj('VIEW_ZA1MASTER')[3]:EvalWhen()

        else
        	oView:GetViewObj('VIEW_ZA1MASTER')[3]:EvalWhen()
        endif
   endif
   
return .T.


//---------------------------------
/*/{Protheus.doc}
Função A800FRONT verifica se o cliente é do tipo fronteira. Se sim deverá habilitar o campo, senão não. 
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
/*/
//---------------------------------
static function A800FRONT()
	Local lRet := .T.
	Local cQuery := ''
	Local cAlias := GetNextAlias()
	
	cQuery := " select param_valor from tab_parametro where param_desc = 'FRONTEIRA' "
	           
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	
	if (cAlias)->(param_valor) = '1'
		lRet := .T.
	else
		lRet := .F.
	endif
	
return lRet


//---------------------------------
/*/{Protheus.doc}
Função A800FECH apaga a grid de marcações quando fechar a tela  
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
static function A800FECH(oModel)
	Local cAliasTC := 'tab_tipo_cliente'
	Local cMarca
	Local oview := FWViewActive()   

	 oBrwSD1 := nil 
	 
		(cAliasTC)->( dbGoTop() )
		While !(cAliasTC)->( Eof() )
				(cAliasTC)->DO_MARK := '  '
				(cAliasTC)->(dbSkip())
		EndDo
	
	oview:DeActivate()

return .T.


//----------------------------------------------------------
// ViewDef
//----------------------------------------------------------
Static Function ViewDef()       
	Local oModel := FWLoadModel('PRAA800')  
	Local oStructTab := FWFormViewStruct():New()
	Local oStructTab2 := FWFormViewStruct():New()
	Local oStruTmp := FWFormViewStruct():New()
	Local oView      := FWFormView():New()
		
	oStructTab:AddGroup('GrpInformacoes',STR0044,'',2)
	oStructTab:AddGroup('GrpCodRelCli',STR0045,'',2)
	oStructTab2:AddGroup('GrpTipo',STR0046,'',2)
	oStructTab2:AddGroup('Grpemp',STR0060,'',2)
	
    //Monta Struct SD1
	oStructTab:AddField('cli_id'            ,'01',STR0001          ,STR0001             	,Nil,'GET',"@!",Nil,Nil,.F.,Nil,'GrpInformacoes',Nil,Nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('cli_nome'          ,'02',STR0013          ,STR0013            ,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpInformacoes',Nil,Nil,Nil,.F.,Nil,.F.)	
	oStructTab:AddField('cli_fant'          ,'03',STR0014          ,STR0014            ,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpInformacoes',Nil,Nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('tipo_pes'          ,'04',STR0015          ,STR0015                ,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpInformacoes',{"J=Jurídica","F=Física","E=Estrangeiro"},30,Nil,.F.,Nil,.F.)
	oStructTab:AddField('cli_cpf'           ,'05',STR0016          ,STR0016              ,Nil,'GET',"@R 999.999.99-99",{||A800MAS()},Nil,.T.,Nil,'GrpInformacoes',Nil,17,Nil,.F.,Nil,.F.)	
	oStructTab:AddField('cli_ie'            ,'06',STR0017          ,STR0017    ,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpInformacoes',Nil,Nil,Nil,.F.,Nil,.F.)
	
	
	oStructTab:AddField('trans_id'          ,'07',STR0018          ,STR0018         ,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpCodRelCli',Nil,Nil,nil,.F.,Nil,.F.)
	oStructTab:AddField('armador'           ,'08',STR0008          ,STR0008       		    ,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpCodRelCli',Nil,Nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('agente'            ,'09',STR0019          ,STR0019       		    ,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpCodRelCli',nil,nil,nil,.F.,Nil,.F.)
	oStructTab:AddField('permisso'            ,'10',STR0020        ,STR0020       		    ,Nil,'GET',"@!",Nil,Nil,.T.,Nil,'GrpCodRelCli',nil,nil,Nil,.F.,Nil,.F.)

	
	oStructTab:AddField('gru_id'             ,'12',STR0063      ,STR0063               ,Nil,'GET',"@R 999999",Nil,'SARAEM',.T.,Nil,'Grpemp',nil,nil,Nil,.F.,Nil,.F.)
	oStructTab:AddField('gru_nome'           ,'13',''                 ,''               ,Nil,'GET',"@!",Nil,Nil,.F.,Nil,'Grpemp',nil,nil,nil,.F.,Nil,.F.)
		   	
		   	
   	oView:SetModel(oModel)
   	oView:CreateHorizontalBox( 'MASTER' , 50,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
   	oView:AddField('VIEW_ZA1MASTER', oStructTab,'ZA1MASTER')
                                                                                                 
	
	oView:CreateHorizontalBox( 'DETAIL' , 50,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddOtherObject('VIEW_ZA1DETAIL', {|oPnlSD1| A800MONT(oPnlSD1)})		

	oView:SetOwnerView('VIEW_ZA1MASTER', 'MASTER')       
   	oView:SetOwnerView('VIEW_ZA1DETAIL', 'DETAIL')
	oView:SetUseCursor(.F.)
	
	oView:AddUserButton( STR0057, 'CLIPS', { |oModel| A800CEND(oModel) } ) 		                    	                                        
	 	      		
Return oView


//-----------------------------------
/*{Protheus.doc}
Validacao campo Grupo empresarial

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao campo Grupo empresarial
*/
//-----------------------------------
Static Function VAL_GR_EMP()
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('ZA1MASTER')
	Local lResult := .T.
	Local tTabTrans := GetNextAlias()
	Local oView      := FWFormView():New()

   IF AllTrim(oModelTMP:GetValue('gru_id')) <> ''
      cQuery := " SELECT gru_id, gru_nome from tab_grupos "
      cQuery += " where gru_id = '"+alltrim(oModelTMP:GetValue('gru_id'))+ "'"
      
      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabTrans, .F., .T.)
      IF AllTrim((tTabTrans)->gru_id) <> ''
         oModelTMP:loadvalue('gru_nome',alltrim((tTabTrans)->gru_nome))
         oView:refresh()
      Else
         lResult := .F.
      End IF
      (tTabTrans)->(DbCloseArea())
   ELSE
      oModelTMP:loadvalue('gru_nome','')
      oView:refresh()
   End IF
Return lResult

//---------------------------------
/*/{Protheus.doc}
Função A801ZCITY() realiza um pesquisa os grupos empresariais.
Esta função é cadastrada no protheus e é chamado pelo campo gru_id 
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
function A800GREMP()
   Local aRet := {}
   Local aFields := {}
   Local cSql := ''
   Local lRet := .T.
   Local aRetZoom := {}
   Local oModel    := FWModelActive()
   Local oView    := FWViewActive()
   Local lError := .F.
   Local bError := errorBlock({|e| A800MER( e, @lError ) })
   Local cAliasTab := 'tab_grupos'
   
   
   Aadd(aRet, 1)
   
   	cSql   :=	   ' select                           '
    cSql   +=     '  gru_id,                      '
    cSql   +=     '  gru_nome '
    cSql   +=     ' from                             '
    cSql   +=     '  tab_grupos ';
    

    if (alltrim(oModel:getmodel('ZA1MASTER'):getvalue('gru_id')) != '') 
	   	  cSql   +=     ' where gru_id = ' + alltrim(oModel:getmodel('ZA1MASTER'):getvalue('gru_id'))
    endif
 
 
    //alltrim(str(oview:getmodel('VIEW_ZA1MASTER'):getvalue('cid_id')))

   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY gru_id')
              //aFields, cCampo           ,  cDesc          , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "GRU_ID"         , 'Código'              , "C"  , 6      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "GRU_NOME"       , 'Grupo empresarial' , "C"  , 30      , 0        , ""      , .T.     , .T., .T., 1)

	Aadd(aRet, aFields)
	
	aRet := PRAC938(aRet, '', @lRet)
	
	
	if !SEmpty(aRet)
      cCodEmp := alltrim(aRet[1])
   else
      cCodEmp:= ''
   endif
   
return lRet


//---------------------------------
/*/{Protheus.doc}
Função A800CEND abre a tela de endereços.É a ação do botão Cadastro de endereços.
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
static function A800CEND(omodel)
	Local oModel    := FWModelActive()
	Local cAlias := GetNextAlias()
	local oView := FWViewActive()
	Local cQuery := '' 
	private  cli_id_end := alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id'))
	private  cli_cpf :=alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))
	private  cli_cgc := alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cgc'))
	private  cli_nome := alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_nome'))
	Private cCodCity := ''
	Private cCodUF := ''
	Private SDESCCITY := ''
	
	if alltrim(oModel:getmodel('ZA1MASTER'):getvalue('cli_id')) <> ''
		cQuery := " select cli_id from tab_cli_endereco where cli_id = '" + alltrim(oModel:getmodel('ZA1MASTER'):getvalue('cli_id')) + "'"
		
		cQuery := ChangeQuery(cQuery)
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
		if alltrim((cAlias)->cli_id) <> ''
			FWExecView('Inclusão por FWExecView','PRAA801', 3, , { || lOk := .T., lOk } )
		else
			if MSGYESNO(STR0058)	
				FWExecView('Inclusão por FWExecView','PRAA801', 3, , { || lOk := .T., lOk } )	
			endif
		endif
	else	
		alert(STR0059)		
	endif	
return

//---------------------------------
/*/{Protheus.doc}
Função A800TRANS busca o codigo tranpotador do cliente se ele for transportador
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
static function A800TRANS()
	Local oModel    := FWModelActive()
	Local cAlias := GetNextAlias()
	Local cQuery := '' 
	local cRet := ''  
	
	cQuery := " select trans_id from rel_trans_ben_com where ben_id = '" + oModel:getmodel('ZA1MASTER'):getvalue('cli_id') + "'"
	
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	cRet := (cAlias)->trans_id
	
	if cRet = 0	
		cRet := ''
	else
	    cRet := str(cRet)
	endif
	
return cRet

//---------------------------------
/*/{Protheus.doc}
Função A800AGEN busca o codigo do agente do cliente
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
static function A800AGEN()
	Local cAlias := GetNextAlias()
	Local cQuery := '' 
	local cRet := ''  
	
	cQuery := " select ag_id from tab_agente where cli_id = '" + cli_id2 + "'"
	           
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	cRet := (cAlias)->ag_id
	
	if cRet = 0	
		cRet := ''
	else
		cRet := str(cRet) 
	endif
	
return cRet




//---------------------------------
/*/{Protheus.doc}
Função A800MAS faz a configuração do formato do campo CPF/CNPJ
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
Static Function A800MAS()
   Local Retorno
   Local oModel    := FWModelActive() 
   Local Resultado
    
   if oModel:getmodel('ZA1MASTER'):getvalue('tipo_pes') == 'E'
      Resultado := "@!"
   else   
      Resultado := picpes(oModel:getmodel('ZA1MASTER'):getvalue('tipo_pes'))
   endif       
Return Resultado 


//---------------------------------
/*/{Protheus.doc}
Função A800MONT monta a grid do tipo MarkBrowse
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return 
/*/
//---------------------------------
Static Function A800MONT(oPnl)
	Local aColsSD1    := {}                                
	Local aColsSX3    := {}    	
	Local lMarcar     := .F.
	local cAliasRT :=  SGetNAlias()
	local cAliasTC :=  'tab_tipo_cliente'
	local cQuery := ''
	local oModel := FWModelActive()
	Local nOp    := (oModel:getOperation())
	
	// Campos adicionais
	aColsSD1:= {;
		{ STR0030,{|| ('tab_tipo_cliente')->tcli_desc}    ,'C' ,''          ,1,40          ,0            ,.F.,,,,,,,,1};
		}
       
	oBrwSD1 := FWMarkBrowse():New()
	oBrwSD1:SetAlias('tab_tipo_cliente')
	oBrwSD1:SetOwner(oPnl)
	oBrwSD1:SetFields(aColsSD1)
	oBrwSD1:SetFieldMark('DO_MARK')
	oBrwSD1:SetMark('OK', 'tab_tipo_cliente', 'DO_MARK')
	oBrwSD1:SetAllMark( { || oBrwSD1:AllMark() } )
	oBrwSD1:SetMenuDef('')         
	oBrwSD1:oBrowse:SetFixedBrowse(.T.)   
	oBrwSD1:SetDescription('Tipos de clientes') // Pedidos
	v_cMarca := oBrwSD1:Mark()
	oBrwSD1:SetAfterMark({||A800DESAB()})
	
	if insert = .F.	
		cQuery := "select tcli_id from rel_tipo_cliente where cli_id = '" + alltrim(('tab_clientes')->cli_id) + "'"
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasRT, .F., .T.)
		
		if (nop = 4) .or. (nop = 5) 
			While (cAliasRT)->(!Eof())
				(cAliasTC)->( dbGoTop() )
				While !(cAliasTC)->( Eof() )
					if ((cAliasRT)->tcli_id = val((cAliasTC)->tcli_id))
					    if (cAliasTC)->DO_MARK = '  '
							(cAliasTC)->DO_MARK := 'OK'
						endif
					endif
					(cAliasTC)->( dbSkip() )
				EndDo
		  		(cAliasRT)->(dbSkip())
			EndDo	 
		endif
		
		if nop = 3
				(cAliasTC)->( dbGoTop() )
				While !(cAliasTC)->( Eof() )
					(cAliasTC)->DO_MARK = '  '
					(cAliasTC)->( dbSkip() )
				EndDo
		endif
		
	endif
	
	insert := .F.
	               
	
	oBrwSD1:Activate()
	
Return .T.




//---------------------------------
/*/{Protheus.doc}
Menudef
/*/
static function menuDEF()
	local arotina := {}
	
	add option arotina title STR0031   action 'VIEWDEF.PRAA800' operation 1 access 0
	add option arotina title STR0032   action 'Viewdef.PRAA800' operation 3 access 0
	add option arotina title STR0033  action 'Viewdef.PRAA800' operation 4 access 0
	add option arotina title STR0034  action 'Viewdef.PRAA800' operation 5 access 0
	
return arotina


//---------------------------------
/*/{Protheus.doc}
A função tem A800VAOK() tem como objetivo: 
1) Realizar a verificacao de todas as regras de negocio no momento em que 
o usuário realizar uma operacao(apertar o botao confirma da tela de Cadastro).
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return  Retorna um boolean para dizer se foi bem sucedido a operacao ou nao.
/*/
static function A800VAOK(oModel)
	Local nOp    := (oModel:getOperation()) 
	//Local oModelTab := oModel:GetModel('PRAA800')
	local cAliasArm :=  SGetNAlias()
	Local cCPF := ''
	Local cQuery := ''
	
	
	If nOp == 3 .or. nOp == 4	
	    //verificar se o nome do cliente tem pelo menos 5 caracteres 		
		if len(AllTrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_nome'))) < 5
			oModel:SetErrorMessage('PRAA800','cli_nome','','','3000', STR0035,STR0036,nil,nil)
			return .f.
		endif
		
		//validar se cnpj ou cpf está vazio	
		if (oModel:Getmodel('ZA1MASTER'):Getvalue('tipo_pes') = 'J' ) .or. (oModel:Getmodel('ZA1MASTER'):Getvalue('tipo_pes') = 'F' )
			if (alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf')) = '' )
				oModel:SetErrorMessage('PRAA800','cli_cpf',   ,  , ,STR0037 )
				Return .F.
			endif 
		endif
		
		//verificar validade cnpj
			if oModel:Getmodel('ZA1MASTER'):Getvalue('tipo_pes') = 'J'  
				if CGC(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))) == .F.
					oModel:SetErrorMessage('PRAA800','cli_cpf',   ,  , ,STR0038 )
					Return .F.
				endif
			endif
			
			//verificar validade cpf
			if	oModel:Getmodel('ZA1MASTER'):Getvalue('tipo_pes') = 'F'
				if A800VCPF(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))) == .F.
					oModel:SetErrorMessage('PRAA800','cli_cpf',   ,  , ,STR0038 )
					Return .F.
				endif
			endif
		
		//verificar se tem pelo menos 1 tipo de pessoa
		if A800VMARK('') = .F.
			oModel:SetErrorMessage('PRAA800','',   ,  , ,STR0039 )
			Return .F.
		endif 
				
		//verifica se na grid esta marcado como armado e se codigo do armador
		if (A800VMARK('ARMADOR')) .and. (alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador')) = '')	
			oModel:SetErrorMessage('PRAA800','',   ,  , ,STR0040 )
			Return .F.
		endif
		
		//verifica se o código do armador é maior que 3
		if (A800VMARK('ARMADOR')) .and. len(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador'))) < 4
			oModel:SetErrorMessage('PRAA800','armador','','','3000', STR0041,STR0042,nil,nil)
			Return .F.
		endif
		
		//verifica se já existe já existe um código de armador na tabela
		   if nop = 3
			 if alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador')) != ''
						cQuery := "select cli_id from tab_armador where arma_id = '" + alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador')) + "' and cli_id <> '" + alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')) + "'"
						dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasArm, .F., .T.)
						
						if alltrim((cAliasArm)->cli_id) != ''	
							oModel:SetErrorMessage('PRAA800','armador', ,  , ,STR0043 )
							Return .F.
						endif
					endif
			endif
			
		  if nop = 4
			 if alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador')) != ''
				    if alltrim(armadorVelho) != alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador'))
						cQuery := "select cli_id from tab_armador where arma_id = '" + alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador')) + "' and cli_id <> '" + alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')) + "'"
						dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasArm, .F., .T.)
						
						if alltrim((cAliasArm)->cli_id) != ''	
							oModel:SetErrorMessage('PRAA800','armador', ,  , ,STR0043 )
							Return .F.
						endif
					endif
				endif
			endif
	endif 

Return .T.



//---------------------------------
/*/{Protheus.doc}
Função A800OPE  faz a operacao de insert, update e delete da tab_clientes.
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return Retorna um boolean para dizer se a operacao foi bem concluída ou nao.
/*/
//---------------------------------
Static Function A800OPE(oModel)
	//Local oModelTab := oModel:GetModel('PRAA800')  	
	Local nOp       := oModel:getOperation()
	Local cQuery := ''
	Local aResult := {}
	Local cAliasTC := ''
	Local sql := ''
	Local nRet := 0
	local cAliasAgen := SGetNAlias()
	local cAliasT := SGetNAlias()
	local cAliasT2 := SGetNAlias()
	local cAliasEnd := SGetNAlias()
	local cAliasCli := SGetNAlias()
  	local oView  := FWViewActive()
  	local teste := ''
  	local cgc := ''
  	local cAliasArmador := SGetNAlias()
  	local cCodCli := ''
  	local cpf := ''
	private  cli_id_end := alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id'))
	private  cli_cpf :=alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))
	private  cli_cgc := alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cgc'))
	private  cli_nome := alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_nome'))
	Private cCodCity := ''
	Private cCodUF := ''
	Private SDESCCITY := ''
	
	if (nOp != 3) .and. (nOp != 5)
		oModel:Getmodel('ZA1MASTER'):setvalue('teste', '5')
	endif
										
	If (nOp == 3) .or. (nOP == 4)
			
			/*
			if nop = 3	
				cgc :=  IIF(Sempty(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cgc'))),'',alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')))
			elseif nop = 4 
			    if alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf')) <> ''
					cgc := IIF(Sempty(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cgc'))),alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf')),alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cgc')))
				else
					cgc := IIF(Sempty(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cgc'))),alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')),alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cgc')))
				endif
			endif
		   */
		   /*
			sql := " proc_diu_clientes1_w "
			sql := sql +  IIF(nOp==3,'2','3') + ','
			sql := sql + "'" + IIF(nOp==3,'',alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')))+"',"
			sql := sql + "'" + alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_nome'))+"',"
			sql := sql + "'" + cgc+"',"
			sql := sql + "'" + IIF(Sempty(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))),'',alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf')))+"',"
			sql := sql + "'" + alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_ie')) + "',"
			sql := sql + "'" + alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador'))+"',"
			sql := sql + "'" + alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_fant'))+"',''"
			*/
			
			if len(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))) = 11
				cpf := alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))
			elseif len(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))) = 14
				cgc := alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))
			endif
			
			aResult := TCSPExec("proc_diu_clientes1_w",;
                          IIF(nOp==3,2,3),; //@operacao int
                          alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')),; //@prog_id int = null
                         alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_nome')),;
                         alltrim(cgc),;
                         alltrim(cpf),;
						 IIF(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_ie'))='','',alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_ie'))),;
						 alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador')),;
						 IIF(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_fant'))='','',alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_fant'))),;
						 alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('gru_id'));
						 )
						                          
			//IIF(Sempty(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))),'',alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))),;                          
			
      		if empty(aResult)
         		oModel:SetErrorMessage('PRAA800','cli_cpf',   ,  , ,AllTrim(A800VMSG(TCSQLError())) + IIF(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador')) = '','', STR0047  ) )         			
         		Return .F.
			endif
			
			 
			 
			 /*
			aResult:=  TCSPExec('proc_diu_clientes1_w ',;
			 			 IIF(nOp==3,2,3),;
			 			 IIF(nOp==3,'',alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id'))),;
			 			 alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_nome')),;
			 			 cgc,;
			 			 IIF(Sempty(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))),'',alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_cpf'))),;
			 			 alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_ie')),;
			 			 alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador')),;
			 			 alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_fant')))
			 			
			 	
			 
			 aResult:=  TCSPExec('testeRetorno',1,'')
			 	
			  IF empty(aResult)
         			oModel:SetErrorMessage('WMSA800','trans_cgc',   ,  ,       ,AllTrim(A800VMSG(TCSQLError())) )         			
         			Return .F.
      		  endif
			  */
			  /*	         
			if nOp == 3
					//dbUseArea(.T., 'TOPCONN', TCGenQry(,,"select max(cli_id) from tab_clientes where cli_id not in('999999','999998','999997','999996')"),cAliasCli, .F., .T.)
					//cCodCli := AllTrim((cAliasCli)->(Fieldget(1)))
					//(cAliasCli)->(dbCloseArea())
			else
					cCodCli := AllTrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_id'))
			endif	
			*/
							
			if (nOp == 3)					
				if  alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_cpf')) <> ''
					if length(alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_cpf'))) = 11
						oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes_d', 'Fisica')
						oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes', 'F')
						oModel:Getmodel('ZA1MASTER'):loadvalue('cli_cgc', alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_cpf')))
					elseif length(alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_cpf'))) = 14
						oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes', 'J')
						oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes_d', 'Juridica')
						oModel:Getmodel('ZA1MASTER'):loadvalue('cli_cgc', alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_cpf')))
						oModel:Getmodel('ZA1MASTER'):loadvalue('cli_cpf','')
					endif
				else
					oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes', 'E')
					oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes_d', 'Estrangeiro')
					oModel:Getmodel('ZA1MASTER'):loadvalue('cli_cgc',alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')))					
				endif
			elseif (nOp == 4)
				if  alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_cpf')) <> ''
					if length(alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_cpf'))) = 11
						oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes', 'F')
						oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes_d', 'Fisica')
						oModel:Getmodel('ZA1MASTER'):loadvalue('cli_cgc', alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_cpf')))
					elseif length(alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_cpf'))) = 14
						oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes', 'J')
						oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes_d', 'Juridica')
						oModel:Getmodel('ZA1MASTER'):loadvalue('cli_cgc', alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_cpf')))
						oModel:Getmodel('ZA1MASTER'):loadvalue('cli_cpf','')
					endif
				else
					oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes_d', 'Estrangeiro')
					oModel:Getmodel('ZA1MASTER'):loadvalue('tipo_pes', 'E')
					oModel:Getmodel('ZA1MASTER'):loadvalue('cli_cgc',alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')))					
				endif
			endif
		   
			
			if nop = 3
			    oModel:Getmodel('ZA1MASTER'):loadvalue('cli_id',alltrim(aResult[1]))
				cli_id_end := alltrim(aResult[1])
			else
				cli_id_end := alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id'))
			endif
			
			
		   TcSqlExec('delete from rel_tipo_cliente where cli_id = ' + alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')) )
		  
	        	
		  
		    cAliasTC:='tab_tipo_cliente'
			(cAliasTC)->( dbGoTop() )
			While !(cAliasTC)->( Eof() )
				if (cAliasTC)->DO_MARK = 'OK'
						sql := " insert into rel_tipo_cliente values (" + alltrim((cAliasTC)->tcli_id) + ",'" + alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')) +"')"
						nRet := TcSqlExec(sql)
				endif
				(cAliasTC)->( dbSkip() )
			EndDo 
			
			if(nOp == 3)
		      if MSGYESNO( STR0048, STR0049 )
		      	 FWExecView('Inclusão por FWExecView','PRAA801', 3, , { || lOk := .T., lOk } )
		      endif
		  endif	
		   	
	  
		//se for UPDATE e ele DEIXOU de ser tipo agente, excluir da tab_agente o seu registro
		if (nOp == 4) .and. (alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('agente')) <> '') .and. (A800VMARK('AGENTE') = .F. )
			sql := " delete from tab_agente where ag_id = " +  alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('agente'))
			If ( TcSQLExec(sql) < 0 )
				Help( ,1, 'HELP',, UserException( TCSQLError() ), 1, 0)
			else
				oModel:loadValue('ZA1MASTER', 'agente','')
        		oview:refresh()
			EndIf
		endif
		
		//se for UPDATE e ele DEIXOU de ser tipo ARMADOR, excluir da tab_armador o seu registro
		if (nOp == 4)
			sql := " select arma_nome from tab_armador where cli_id = '" +  alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_id')) +"'" 
		    sql := ChangeQuery(sql)
			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,sql),cAliasArmador,.F.,.T.)
		    dbSelectArea(cAliasArmador)
		    (cAliasArmador)->( dbGoTop() )
			if (A800VMARK('ARMADOR') = .F. ) .and. (alltrim((cAliasArmador)->arma_nome) <> '')
				sql := " delete from tab_armador where cli_id = '" +  alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_id')) + "'"
				If ( TcSQLExec(sql) < 0 )
					Help( ,1, 'HELP',, UserException( TCSQLError() ), 1, 0)
				endif
			endif
		endif
		
			//se for UPDATE e ele DEIXOU de ser um TRANSPORTADOR, chamar a sua proc para deletar o registro
			if (nOp == 4) .and. (alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('trans_id')) <> '') .and. (A800VMARK('TRANSPORTADOR') = .F. )
				sql := " proc_diu_cli_transportadora 1,"
				sql := sql + "'" + alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_id')) + "',"
				sql := sql + alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('trans_id')) + ",''"
				 
				 If ( TcSQLExec(sql) < 0 )
				    Help( ,1, 'HELP',, STR0051, 1, 0)				
				EndIf
				
		   endif
				
				
		 if nRet = 0
		 	sql := "select ag_id from tab_agente where cli_id = '" + alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_id')) + "'"
	     	dbUseArea(.T., 'TOPCONN', TCGenQry(,,sql),cAliasAgen, .F., .T.)
	     endif	
	
		
		dbSelectArea(cAliasAgen)
		(cAliasAgen)->( dbGoTop() )
		 oModel:loadValue('ZA1MASTER', 'agente',IIF(alltrim(str((cAliasAgen)->ag_id)) = '0','',alltrim(str((cAliasAgen)->ag_id))))
         oview:refresh()
		
		if alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('trans_id')) = ''
			sql := " select trans_id from tab_transportadora where trans_nome = '" + alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_nome')) + "'"
		elseif  alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('trans_id')) != ''
			sql := " select trans_id from tab_transportadora where trans_id = " + alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('trans_id'))
		endif
		
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,sql),cAliasT, .F., .T.)
		dbSelectArea(cAliasT)
		(cAliasT)->( dbGoTop() )
		
		sql := " proc_diu_cli_transportadora "
		sql := sql + IIF(alltrim(str((cAliasT)->trans_id)) = '0','2','3') + ","
		sql := sql + "'"+oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')+"',"
		sql := sql + IIF((cAliasT)->trans_id = 0,'null',alltrim(str((cAliasT)->trans_id))) + ","
		sql := sql + IIF(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('permisso')) = '','null',"'"+alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('permisso'))+"'")
		 TcSQLExec(sql)
				 	 
		 
		sql := " select trans_id from tab_transportadora where trans_nome = '" + alltrim(oModel:Getmodel('ZA1MASTER'):getvalue('cli_nome')) + "'"
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,sql),cAliasT2, .F., .T.)
		dbSelectArea(cAliasT2)
		(cAliasT2)->( dbGoTop() )
		oModel:loadValue('ZA1MASTER', 'trans_id',IIF(alltrim(str((cAliasT2)->trans_id)) = '0','',alltrim(str((cAliasT2)->trans_id))))
        oview:refresh()
        
	endif	
			
	If nOp == 5	   
	   if MSGYESNO( STR0052, STR0053 )
	   		
	   		//apagar na tabela de transportadora se ele for do tipo transportadora
	   		if alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('trans_id')) <> ''
		   		sql := " proc_diu_cli_transportadora "
				sql := sql + '1,'
				sql := sql + "'"+oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id')+"',"
				sql := sql + alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('trans_id')) +","
				sql := sql + 'null'
				If ( TcSQLExec(sql) < 0 )
				    Help( ,1, 'HELP',, UserException( STR0054 + TCSQLError() ), 1, 0)
			  	EndIf
			endif
			  
				 	
			//apagar o cliente da tabela de cliente   
				sql := " proc_diu_clientes1_w 1,"
				sql := sql + "'"+alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('cli_id'))+"','','','','',"
				sql := sql + IIF(len(alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador')))==0,"''","'"+alltrim(oModel:Getmodel('ZA1MASTER'):Getvalue('armador'))+"'")
				sql := sql + ",'','',''"
				 
				 If ( TcSQLExec(sql) < 0 )
				 	oModel:SetErrorMessage('PRAA800','cli_id','','','3000', STR0055,STR0056,nil,nil)
				 	return .F.
			  	EndIf
		 else
		 	return .T.
	     endif
	     
	     
	endif
	
Return .T.



//---------------------------------
/*/{Protheus.doc}
Função A800VMARK verifica se o tipo de cliente esta marcado conforme o tipo passado por parametro(descTipo). Se o descTipo for = '' verificara se existe pelo menos 1 cliente marcado no markbrowse.
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return Retorna um boolean para dizer se a operacao foi bem concluída ou nao.
/*/
//---------------------------------			
static function A800VMARK(descTipo)
	Local lRet := .F.
	Local cAliasTC := 'tab_tipo_cliente'
	Local cMarca:=oBrwSD1:Mark()
	Local marcadoVelho := ''
	
	
	marcadoVelho := alltrim((cAliasTC)->tcli_desc) 
	
	(cAliasTC)->( dbGoTop() )
	if descTipo = 'ARMADOR'
	    While !(cAliasTC)->( Eof() )
			if (oBrwSD1:IsMark(cMarca)) .and. (alltrim((cAliasTC)->tcli_desc) ='ARMADOR') 
				 lRet := .T.
			endif
			(cAliasTC)->(dbSkip())
		EndDo
	elseif descTipo = 'AGENTE'
		 While !(cAliasTC)->( Eof() )
			if (oBrwSD1:IsMark(cMarca)) .and. (alltrim((cAliasTC)->tcli_desc) ='AGENTE DE CARGA') 
				 lRet := .T.
			endif
			(cAliasTC)->(dbSkip())
		EndDo
	elseif descTipo = 'TRANSPORTADOR'
		 While !(cAliasTC)->( Eof() )
			if (alltrim((cAliasTC)->tcli_desc) ='TRANSPORTADOR AEREO') .or. (alltrim((cAliasTC)->tcli_desc) ='TRANSPORTADOR FERROVIARIO')  .or. (alltrim((cAliasTC)->tcli_desc) ='TRANSPORTADOR RODOVIARIO')
				if (oBrwSD1:IsMark(cMarca))  
					 lRet := .T.
				endif
			endif
			(cAliasTC)->(dbSkip())
		EndDo
	else	
		While !(cAliasTC)->( Eof() )
			if (oBrwSD1:IsMark(cMarca))
				 lRet := .T. 
			endif
			(cAliasTC)->(dbSkip())
		EndDo
	endif
	
	(cAliasTC)->( dbGoTop() )
				While !(cAliasTC)->( Eof() )
					if (alltrim((cAliasTC)->tcli_desc) = marcadoVelho)
						exit
					else
						(cAliasTC)->(dbSkip())
					endif
					
				EndDo
	
return lRet

//---------------------------------
/*/{Protheus.doc}
Função A800VMSG monta a mensagem retornado pelo banco de dados.
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return Retorna um boolean para dizer se a operacao foi bem concluída ou nao.
/*/
//---------------------------------
Static function A800VMSG(cMsg)
	Local nIni := At('Server]', cMsg)
	Local nFim := At('( From', cMsg)	

return SubStr(cMsg, nIni + 7, (nFim - nIni - 7))


//---------------------------------
/*/{Protheus.doc}
Função A800VCPF realiza a validacao do CPF
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 23/10/2013
@return Retorna um boolean para dizer se a operacao foi bem concluída ou nao.
/*/
//---------------------------------
STATIC FUNCTION A800VCPF(num_cpf)
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


//---------------------------------
/*/{Protheus.doc}
Função A800MER que apresenta em alert os erros lancados pela funcao C867GSTK
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 08/02/2013
@return nil
/*/
//---------------------------------
Function A800MER(e,lError)
	Local cDesc :=  e:Description
	Local nCod := e:Gencode
	
return .T.



