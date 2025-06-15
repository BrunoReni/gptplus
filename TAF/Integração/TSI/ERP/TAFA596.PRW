#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
Static cUltStmp := iif(lNewCtrl, TsiUltStamp("T9C"),' ')

static cTsiLayout := "WorkNationalFile"
Static nTamDescr  :=  GetSx3Cache("T9C_DSCOBR","X3_TAMANHO")

/*/{Protheus.doc} TSICNO
	(Classe que contém preparedstatament do CNO )
    @type Class
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, não tem retorno.
/*/ 
Class TSICNO

    Data TSITQRY     //as String ReadOnly
    Data cFinalQuery //as String ReadOnly
    Data oStatement  //as Object ReadOnly
    Data cFilT9C     //as String ReadOnly
    Data oJObjTSI    //as Object

    Method New() Constructor
    Method PrepQuery()
    Method LoadQuery()
    Method JSon()
    Method FilT9C()

    Method GetQry()
    Method GetJsn()

EndClass


/*/{Protheus.doc} New
	(Método construtor da classe TSICNO )
    Fluxo New:
    1º Monta-se a query com LoadQuery()
    2º Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros
	@type Class
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, não tem retorno.
/*/
Method New(cSourceBr) Class TSICNO

    Self:FilT9C(cSourceBr)
    Self:LoadQuery()
    Self:PrepQuery()
    Self:JSon()
    
Return Nil

/*/{Protheus.doc} PrepQuery
    @author Ricardo Lovrenovic
	(Método responsável por Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parametros )
    @type Class
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, nao tem retorno.
/*/
Method PrepQuery() Class TSICNO

    self:oStatement := FWPreparedStatement():New()
    self:oStatement:SetQuery(self:TSITQRY)

    If !lNewCtrl .OR. Empty(cUltStmp)
        self:oStatement:SetIn(1,self:cFilT9C)
    EndIf
          
    self:cFinalQuery := self:oStatement:GetFixQuery()

Return Nil


 /*/{Protheus.doc} LoadQuery
	(Método responsável por montar a query para o preparedstatement, por hora ainda com '?'
    nos parâmetros variáveis
    
    SON_TPINSCR  -- > T9C_TPINSC
    SON_CNO      -- > T9C_NRINSC
    SON_DESC     -- > T9C_DSCOBR
    SON_IDOBRA   -- > T9C_INDOBR
    SON_INDCPRB  -- > T9C_CPRB

	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, não tem retorno.
/*/
Method LoadQuery() Class TSICNO

    Local cDbType   := Upper(Alltrim(TCGetDB()))
    Local cQuery    := " "
    Local cConvCpo  := " "

    cQuery += " SELECT "
    cQuery += " SON.ON_TPINSCR "   // Tipo de Inscrição ( CNPJ ou CNO )
    cQuery += " ,SON.ON_CNO "      // Numero do Registro ( CNPJ ou CNO )
    cQuery += " ,SON.ON_DESC "     // Descrição da Obra 
    cQuery += " ,SON.ON_IDOBRA "   // Indicativo de Prestação de Serviço
    cQuery += " ,SON.ON_INDCPRB "  // Contribuição Previdenciaria 
    cQuery += " ,SON.ON_TPOBRA "   // Tipo de Obra

    If cDbType $ "MSSQL/MSSQL7" //STAMP
        cConvCpo := " convert(varchar(23), SON.S_T_A_M_P_ , 21 ) "
    Elseif cDbType $ "ORACLE"
        cConvCpo += " cast( to_char(SON.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    Elseif cDbType $ "POSTGRES"
        cConvCpo += " cast( to_char(SON.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    Endif
    
    cQuery += "," + cConvCpo + " STAMP "
    
    cQuery += " FROM " + RetSqlName("SON") + " SON " //ERP

    If !lNewCtrl .OR. Empty(cUltStmp)
        cQuery += " LEFT JOIN " + RetSqlName("T9C") + " T9C " //TAF
        cQuery += " ON T9C.T9C_FILIAL IN (?) "
        cQuery += " AND T9C_TPINSC = SON.ON_TPINSCR "
        cQuery += " AND T9C_NRINSC = SON.ON_CNO "
        cQuery += " AND T9C.D_E_L_E_T_ = ' ' "
    EndIf

    cQuery += " WHERE SON.ON_FILIAL = '" + xFilial( "SON" ) + "' "
    cQuery += " AND SON.D_E_L_E_T_ = ' ' "

    If !lNewCtrl .OR. Empty(cUltStmp)
        cQuery += " AND SON.S_T_A_M_P_  IS NOT NULL "
        If cDbType $ "ORACLE"
            cQuery += " AND ((T9C.T9C_STAMP IS NULL OR Length(trim(T9C.T9C_STAMP)) = 0 OR Length(trim(T9C.T9C_STAMP)) IS NULL) OR ( Length(trim(T9C.T9C_STAMP)) > 0 AND SON.S_T_A_M_P_ > TO_TIMESTAMP(T9C.T9C_STAMP,'dd.mm.yyyy hh24:mi:ss.ff') ) ) "
        else
            cQuery += " AND (( " + cConvCpo + " > T9C.T9C_STAMP) OR T9C.T9C_STAMP IS NULL ) "
        endif
    Else
        If cDbType $ "ORACLE"
            cQuery += " AND SON.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff') "
        else
            cQuery += " AND " + cConvCpo + "> '" + Alltrim(cUltStmp) + "' "
        endif
    Endif

    self:TSITQRY := cQuery

Return


 /*/{Protheus.doc} GetQry
	(Método responsável por retornar a propriedade self:cFinalQuery
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, não tem retorno.
/*/
Method GetQry() Class TSICNO
return self:cFinalQuery


 /*/{Protheus.doc} JSon
	(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, não tem retorno.
/*/
Method JSon() Class TSICNO

    Local cAlias    := getNextAlias()
    Local nLen      := 0
    Local oJObjRet  := nil

    oJObjRet := JsonObject():New()

    DbSelectArea('T9C')
    T9C->(DbSetOrder(1)) //C0A_FILIAL, C0A_CODIGO, C0A_EXNCM, C0A_VALIDA, R_E_C_N_O_, D_E_L_E_T_ //Ricardo alterar índice
 
    oJObjRet[cTsiLayout] := {}
    
    If ExistStamp(,,"SON")
    
        dbUseArea(.T., "TOPCONN", TCGenQry(, , self:GetQry()), cAlias, .F., .T.)
        (cAlias)->(DbGoTop())

        TAFConOut("TSILOG000020: Query de busca do cadastro de CNO - Obras [ Início query TSILOG000020 " + TIME() + " ]"  + self:GetQry() + "[ Fim query TSILOG000020 " + TIME() + "  ] ")  

        While (cAlias)->(!EOF())

            aAdd( oJObjRet[cTsiLayout],JsonObject():New())
            nLen++

            oJObjRet[cTsiLayout][nLen]["registrationType"]      := Alltrim((cAlias)->ON_TPINSCR)  
            oJObjRet[cTsiLayout][nLen]["cnoNumber"]             := Alltrim((cAlias)->ON_CNO)      
            oJObjRet[cTsiLayout][nLen]["description"]           := Substr(Alltrim((cAlias)->ON_DESC), 1, nTamDescr)
            oJObjRet[cTsiLayout][nLen]["workIdentification"]    := Alltrim((cAlias)->ON_IDOBRA)   
            oJObjRet[cTsiLayout][nLen]["cprbPayer"]             := Alltrim((cAlias)->ON_INDCPRB)
            oJObjRet[cTsiLayout][nLen]["thirdPartyCallsign"]    := IIf(Alltrim((cAlias)->ON_TPOBRA)=='2','1','2')
            oJObjRet[cTsiLayout][nLen]["stamp"]                 := (cAlias)->STAMP
        
        (cAlias)->(DBSKIP())

        EndDo

        ( cAlias )->( DbCloseArea( ) )

    Endif

    self:oJObjTSI := oJObjRet

Return

 /*/{Protheus.doc} GetJsn
	(Método responsável retornar a propriedade self:oJObjTSI
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, não tem retorno. 
/*/
Method GetJsn () Class TSICNO

Return self:oJObjTSI


 /*/{Protheus.doc} TSICNO
	(Método responsável por montar o conteúdo da filial da T9C
	@author Ricardo Lovrenovic
	@since 21/09/2021
	@return Nil, nulo, não tem retorno.
/*/
Method FilT9C(cSourceBr) Class TSICNO        
     self:cFilT9C := TafTSIFil(cSourceBr, 'T9C')      
Return
