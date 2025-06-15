#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
Static cUltStmp := iif(lNewCtrl, TsiUltStamp("C1N"),' ')

/*/{Protheus.doc} TSINATOPE
	( Classe que contém preparedstatament do T009 Natureza(TES) )
    @type Class
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Class TSINATOPE

    Data TSIQRY  as String ReadOnly
    Data cFinalQuery as String ReadOnly
    Data oStatement  as Object ReadOnly
    Data oJObjTSI    as Object
    Data aFilC1N    as Array

    Method New() Constructor
    Method PrepQuery()
    Method LoadQuery()
    Method JSon()
    Method FilC1N()

    Method GetQry()
    Method GetJsn()

EndClass

/*/{Protheus.doc} New
	(Método contrutor da classe TSINATOPE )
    Fluxo New:
    1º Monta-se a query com LoadQuery()
    2º Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros
	@type Class
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method New(cSourceBr) Class TSINATOPE
    Self:FilC1N(cSourceBr)
    Self:LoadQuery()
    Self:PrepQuery()
    Self:JSon()

Return Nil

/*/{Protheus.doc} PrepQuery
	(Método responsável por Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros )
    @type Class
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method PrepQuery() Class TSINATOPE

    self:oStatement := FWPreparedStatement():New()
    self:oStatement:SetQuery(self:TSIQRY)
   
    If !lNewCtrl .OR. Empty(cUltStmp)
	    self:oStatement:SetIn(1,self:aFilC1N)
        self:oStatement:SetString(2,xFilial('SF4'))
    Else
        self:oStatement:SetString(1,xFilial('SF4'))
    EndIf 

    self:cFinalQuery := self:oStatement:GetFixQuery()

Return Nil

 /*/{Protheus.doc} PrepQuery
	(Método responsável por montar a query para o preparedstatemen, por hora ainda com '?'
    nos parâmetros variáveis
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method LoadQuery() Class TSINATOPE

    Local cDbType  := Upper(Alltrim(TCGetDB()))
    Local cQuery   := " "
    Local cVarConv := " "

    If cDbType $ 'MSSQL/MSSQL7' //STAMP
        cVarConv := " convert(varchar(23), SF4.S_T_A_M_P_ , 21 ) "
    Elseif cDbType $ 'ORACLE'
        cVarConv := " cast( to_char(SF4.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    Elseif cDbType $ 'POSTGRES'
        cVarConv := " cast( to_char(SF4.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    Endif

    cQuery += " SELECT DISTINCT "
    cQuery += " SF4.F4_CODIGO CODIGO, "
	cQuery += " SF4.F4_TEXTO DESCR, "
    cQuery += cVarConv + " STAMP "
    cQuery += " FROM " + RetSqlName("SF4") + " SF4 "
    
    If !lNewCtrl .OR. Empty(cUltStmp)
        cQuery += " LEFT JOIN " + RetSqlName("C1N") + " C1N ON "
        cQuery += " C1N.C1N_FILIAL = ? "
        cQuery += " AND C1N.C1N_CODNAT = SF4.F4_CODIGO "
        cQuery += " AND C1N.C1N_DESNAT = SF4.F4_TEXTO "
        cQuery += " AND C1N.D_E_L_E_T_ = ' '  "
    EndIf

    cQuery += " WHERE SF4.F4_FILIAL = ? "
	cQuery += " AND (SF4.F4_MSBLQL = '2' OR SF4.F4_MSBLQL = ' ') "

    If !lNewCtrl .OR. Empty(cUltStmp)
        cQuery += " AND SF4.S_T_A_M_P_ IS NOT NULL "
        If cDbType $ "ORACLE"
	        cQuery += " AND ( (C1N.C1N_STAMP IS NULL OR Length(trim(C1N.C1N_STAMP)) = 0 OR Length(trim(C1N.C1N_STAMP)) IS NULL ) OR (Length(trim(C1N.C1N_STAMP)) > 0 AND SF4.S_T_A_M_P_ > TO_TIMESTAMP(C1N.C1N_STAMP,'dd.mm.yyyy hh24:mi:ss.ff')) ) "
        else
            cQuery += " AND (( " + cVarConv + " > C1N.C1N_STAMP) OR C1N.C1N_STAMP IS NULL ) "
        endif
    Else
        If cDbType $ "ORACLE"
            cQuery += " AND SF4.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff') "
        else
            cQuery += " AND " + cVarConv + "> '" + Alltrim(cUltStmp) + "' "
        Endif
    Endif
    
    cQuery += " AND SF4.D_E_L_E_T_ = ' ' "

    self:TSIQRY := cQuery

Return

 /*/{Protheus.doc} PrepQuery
	(Método responsável por retornar a propriedade self:cFinalQuery
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method GetQry() Class TSINATOPE

return self:cFinalQuery

 /*/{Protheus.doc} JSon
	(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method JSon() Class TSINATOPE

    Local cAlias    := getNextAlias()
    Local nLen      := 0
    Local oJObjRet  := nil

    oJObjRet := JsonObject():New()

    DbSelectArea('C1N')
    C1N->(DbSetOrder(1))
 
    dbUseArea(.T., "TOPCONN", TCGenQry(, , self:GetQry()), cAlias, .F., .T.)
    (cAlias)->(DbGoTop())
    TAFConOut("TSILOG000010: Query de busca do cadastro de Natureza da operação [ Início query TSILOG00006 " + TIME() + " ]"  + self:GetQry() + "[ Fim query TSILOG00005 " + TIME() + "  ] ")  
    oJObjRet['natureOfTheOperation'] := {}  

    While ( cAlias )->( !EOF( ) )

            aAdd( oJObjRet['natureOfTheOperation'], JsonObject( ):New( ) )
            nLen++
                                                                                                              // Campos da Planilha Layout TAF - T009
            oJObjRet['natureOfTheOperation'][nLen]["natureOfTheOperationId"] := alltrim( ( cAlias )->CODIGO ) // 2 - COD_NAT
            oJObjRet['natureOfTheOperation'][nLen]["description"           ] := alltrim( ( cAlias )->DESCR  ) // 3 - DESCR_NAT
            oJObjRet['natureOfTheOperation'][nLen]["stamp"                 ] := ( cAlias )->STAMP             // 9 - STAMP

            ( cAlias )->( DBSKIP( ) )
    EndDo

    ( cAlias )->( DBCloseArea( ) )

    self:oJObjTSI := oJObjRet

Return

 /*/{Protheus.doc} GetJsn
	(Método responsável retornar a propriedade self:oJObjTSI
	@author Henrique Pereira / Jose Felipe
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method GetJsn () Class TSINATOPE

Return self:oJObjTSI
 /*/{Protheus.doc} FilC1N
	(Método responsável por montar o conteúdo da filial da C1H
	@author Henrique Pereira
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method FilC1N(cSourceBr) Class TSINATOPE        
     self:aFilC1N := TafTSIFil(cSourceBr, 'C1N')      
Return
