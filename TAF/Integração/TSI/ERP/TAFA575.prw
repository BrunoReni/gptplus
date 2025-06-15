#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
Static cUltStmp := iif(lNewCtrl, TsiUltStamp("C3Q"),' ')

/*/{Protheus.doc} TSIADDINFO
Classe que cont�m preparedstatament do T001AK - Informa��es Complementares

@type Class
@author Wesley Pinheiro
@since 04/11/2020
@return Nil, nulo, n�o tem retorno.
/*/ 

Class TSIADDINFO

    Data TSITQRY     as String ReadOnly
    Data cFinalQuery as String ReadOnly
    Data oStatement  as Object ReadOnly
    Data aFilCCE     as Array ReadOnly
    Data oJObjTSI    as Object

    Method New( ) Constructor 
    Method PrepQuery( )
    Method LoadQuery( )
    Method JSon( )
    Method FilCCE( )

    Method GetQry( )
    Method GetJsn( )

EndClass

/*/{Protheus.doc} New
M�todo contrutor da classe TSIADDINFO

Fluxo New:
1� Monta-se a query com LoadQuery()
2� Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
cFinalQuery com a query final j� com os par�metros

@type Class
@author Wesley Pinheiro
@since 04/11/2020
@return Nil, nulo, n�o tem retorno
/*/
 
Method New( cSourceBr ) Class TSIADDINFO
    Self:FilCCE( cSourceBr )
    Self:LoadQuery( )
    Self:PrepQuery( )
    Self:JSon( )
Return

/*/{Protheus.doc} PrepQuery   
M�todo respons�vel por Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
cFinalQuery com a query final j� com os par�metros

@type Class
@author Wesley Pinheiro
@since 04/11/2020
@return Nil, nulo, n�o tem retorno.
/*/

Method PrepQuery( ) Class TSIADDINFO

    self:oStatement := FWPreparedStatement( ):New( )
    self:oStatement:SetQuery( self:TSITQRY )
    
    If !lNewCtrl .OR. Empty(cUltStmp)
        self:oStatement:SetIn( 1, self:aFilCCE )           // par01
        self:oStatement:SetString( 2, xFilial( "V5R" ) )   // par02
        self:oStatement:SetString( 3, cFilAnt )            // par03
        self:oStatement:SetString( 4, "C3Q" )              // par04
        self:oStatement:SetString( 5, xFilial( "CCE" ) )   // par05
    Else
        self:oStatement:SetString( 1, xFilial( "CCE" ) )   // par05
    EndIf

    self:cFinalQuery := self:oStatement:GetFixQuery( )

Return

 /*/{Protheus.doc} PrepQuery
M�todo respons�vel por montar a query para o preparedstatemen

@author Wesley Pinheiro
@since 04/11/2020
@return Nil, nulo, n�o tem retorno.
/*/

Method LoadQuery( ) Class TSIADDINFO

    Local cDbType  := Upper( Alltrim( TCGetDB( ) ) )
    Local cQuery   := ""
    Local cConvCPO := ""
    
    cQuery := " SELECT  "  

    cQuery += " CCE.CCE_COD, "
    cQuery += " CCE.CCE_DESCR, "

    If cDbType $ "ORACLE"
        cConvCPO := "  cast( to_char(CCE.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    Elseif cDbType $ "POSTGRES"
        cConvCPO := "  cast( to_char(CCE.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    Else
        cConvCPO := " convert(varchar(23), CCE.S_T_A_M_P_ , 21 ) "
    Endif

    cQuery += cConvCPO + " STAMP "
    cQuery += "  FROM " + RetSqlName( "CCE" ) + " CCE "
    
    If !lNewCtrl .OR. Empty(cUltStmp)
        cQuery += "  LEFT JOIN " + RetSqlName( "C3Q" ) + " C3Q "
        cQuery += "  ON C3Q.C3Q_FILIAL IN (?)" // par01
        cQuery += "  AND CCE.CCE_COD = C3Q.C3Q_CODINF "
        cQuery += "  AND CCE.D_E_L_E_T_ = C3Q.D_E_L_E_T_ "

        cQuery += "  LEFT JOIN " + RetSqlName( "V5R" ) + " V5R "
        cQuery += "  ON V5R.V5R_FILIAL = ? "   // par02
        cQuery += "  AND V5R.V5R_CODFIL = ? "  // par03
        cQuery += "  AND V5R.V5R_ALIAS = ? "   // par04
        cQuery += "  AND V5R.V5R_REGKEY = CCE.CCE_COD "
        cQuery += "  AND V5R.D_E_L_E_T_ = ' ' "  
    EndIf

    cQuery += "  WHERE CCE.CCE_FILIAL = ? " // par05
    cQuery += "  AND CCE.D_E_L_E_T_ = ' ' "

    If !lNewCtrl .OR. Empty(cUltStmp)
        cQuery += "  AND CCE.S_T_A_M_P_ IS NOT NULL "
        If cDbType $ "ORACLE"
            cQuery += " AND ( "
            cQuery += "         ( V5R.V5R_STAMP IS NOT NULL AND Length(trim(V5R.V5R_STAMP)) > 0 AND (CCE.S_T_A_M_P_ > TO_TIMESTAMP(V5R.V5R_STAMP, 'dd.mm.yyyy hh24:mi:ss.ff'))) "
            cQuery += "     OR "
            cQuery += "     ( 
            cQuery += "         ( C3Q.C3Q_STAMP IS NULL OR Length(trim(C3Q.C3Q_STAMP)) = 0 OR Length(trim(C3Q.C3Q_STAMP)) IS NULL ) OR (Length(trim(C3Q.C3Q_STAMP)) > 0 AND (CCE.S_T_A_M_P_ > TO_TIMESTAMP(C3Q.C3Q_STAMP, 'dd.mm.yyyy hh24:mi:ss.ff')))) "
            cQuery += " ) "
        else
            cQuery += "  AND ( (" + cConvCPO + "> C3Q.C3Q_STAMP ) OR C3Q.C3Q_STAMP IS NULL ) "
            cQuery += "  AND ( (" + cConvCPO + "> V5R.V5R_STAMP ) OR V5R.V5R_STAMP IS NULL ) "
        endif
    Else
        If cDbType $ "ORACLE"
            cQuery += "  AND CCE.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff')  "
        else
            cQuery += "  AND " + cConvCPO + " > '" + Alltrim(cUltStmp) + "' "
        endif
    Endif

    self:TSITQRY := cQuery

Return

 /*/{Protheus.doc} PrepQuery
M�todo respons�vel por retornar a propriedade self:cFinalQuery

@author Wesley Pinheiro
@since 04/11/2020
@return cFinalQuery  - String com a query j� montada e pronta para ser executada
/*/

Method GetQry( ) Class TSIADDINFO
return self:cFinalQuery

 /*/{Protheus.doc} JSon
M�todo respons�vel montar o objeto Json e alimenta a propriedade self:oJObjTSI

@author Wesley Pinheiro
@since 04/11/2020
@return Nil, nulo, n�o tem retorno.
/*/

Method JSon( ) Class TSIADDINFO

    Local cAlias    := getNextAlias( )
    Local nLen      := 0
    Local oJObjRet  := nil

    oJObjRet := JsonObject( ):New( )
 
    dbUseArea( .T., "TOPCONN", TCGenQry( ,, self:GetQry( ) ), cAlias, .F., .T. )
    
    TAFConOut( "TSILOG000011: Query de busca do cadastro de Informa��es Adicionais NF [ " + self:GetQry() + " ]")

    oJObjRet['addInformation'] := { }

    While ( cAlias )->( !EOF( ) )

        aAdd( oJObjRet['addInformation'],JsonObject( ):New( ) )
        nLen := Len( oJObjRet['addInformation'] )
        oJObjRet['addInformation'][nLen]["addInformationId" ] := alltrim( ( cAlias )->CCE_COD )
        oJObjRet['addInformation'][nLen]["description"]       := alltrim( ( cAlias )->CCE_DESCR )
        oJObjRet['addInformation'][nLen]["stamp"]             := ( cAlias )->STAMP

        ( cAlias )->( DBSKIP( ) )

    EndDo

    self:oJObjTSI := oJObjRet

    ( cAlias )->( DbCloseArea( ) )

Return

 /*/{Protheus.doc} GetJsn
M�todo respons�vel retornar a propriedade self:oJObjTSI

@author Wesley Pinheiro
@since 04/11/2020
@return oJObjTSI - Objeto TSIADDINFO com o Json gerado com as informa��es complementares - antigo T001AK
/*/
Method GetJsn ( ) Class TSIADDINFO
Return self:oJObjTSI

 /*/{Protheus.doc} TSIADDINFO
M�todo respons�vel por montar o conte�do da filial da CCE

@author Wesley Pinheiro
@since 04/11/2020
@return Nil, nulo, n�o tem retorno.
/*/
Method FilCCE( cSourceBr ) Class TSIADDINFO        
     self:aFilCCE := TafTSIFil( cSourceBr, "CCE" )      
Return
