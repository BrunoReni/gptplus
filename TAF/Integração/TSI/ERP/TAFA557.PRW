#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
Static cUltStmp := iif(lNewCtrl, TsiUltStamp("C1J"),' ')

/*/{Protheus.doc} TSIUM
	(Classe que cont�m preparedstatament do T005 )
    @type Class
	@author Henrique Pereira / Denis Souza
    @author Carlos Eduardo
	@since 10/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/ 

Class TSIUM

    Data TSITQRY     as String ReadOnly
    Data cFinalQuery as String ReadOnly
    Data oStatement  as Object ReadOnly
    Data cFilC1J     as String ReadOnly
    Data oJObjTSI    as Object

    Method New() Constructor 
    Method PrepQuery()
    Method LoadQuery()
    Method JSon()
    Method FilC1J()

    Method GetQry()
    Method GetJsn()

EndClass

/*/{Protheus.doc} New
	(M�todo contrutor da classe TSIUM )
    @author Carlos Eduardo
    Fluxo New:
    1� Monta-se a query com LoadQuery()
    2� Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final j� com os par�metros
	@type Class
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/
 
Method New(cSourceBr) Class TSIUM
    Self:FilC1J(cSourceBr)
    Self:LoadQuery()
    Self:PrepQuery()
    Self:JSon()
Return Nil

/*/{Protheus.doc} PrepQuery
    @author Carlos Eduardo
	(M�todo respons�vel por Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final j� com os par�metros )
    @type Class
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/

Method PrepQuery() Class TSIUM
    self:oStatement := FWPreparedStatement():New()
    self:oStatement:SetQuery(self:TSITQRY)
    If !lNewCtrl .OR. Empty(cUltStmp) 
        self:oStatement:SetIn(1,self:cFilC1J)
    EndIf
    self:cFinalQuery := self:oStatement:GetFixQuery()
Return Nil

 /*/{Protheus.doc} PrepQuery
	(M�todo respons�vel por montar a query para o preparedstatemen, por hora ainda com '?'
    nos par�metros vari�veis
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/

Method LoadQuery() Class TSIUM
    Local cDbType  := Upper(Alltrim(TCGetDB()))
    Local cQuery   := " "
    Local cConvCPO := ""
   
    cQuery += " SELECT "
    cQuery += " SAH.AH_UNIMED UNIMED, " //2 - UNID
    cQuery += " SAH.AH_UMRES UMRES, " //3 - DESCR

    If cDbType $ "ORACLE"
        cConvCPO := "  cast( to_char(SAH.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    Elseif cDbType $ "POSTGRES"
        cConvCPO := "  cast( to_char(SAH.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    Else
        cConvCPO := " convert(varchar(23), SAH.S_T_A_M_P_ , 21 ) "
    Endif

    cQuery += cConvCPO + " STAMP "    

    cQuery += "  FROM " + RetSqlName("SAH") + " SAH "
    
    If !lNewCtrl .OR. Empty(cUltStmp) 
        cQuery += "  LEFT JOIN " + RetSqlName("C1J") + " C1J "
        cQuery += "  ON C1J.C1J_FILIAL IN (?) "
        cQuery += "  AND C1J.C1J_CODIGO = SAH.AH_UNIMED "
        cQuery += "  AND C1J.D_E_L_E_T_ = ' ' "
    EndIf

    cQuery += "  WHERE SAH.AH_FILIAL = '" + xFilial( "SAH" ) + "' "

    If !lNewCtrl .OR. Empty(cUltStmp)
        cQuery += "  AND SAH.S_T_A_M_P_ IS NOT NULL "
        If cDbType $ "ORACLE"
            cQuery += "  AND ( (C1J.C1J_STAMP IS NULL OR Length(trim(C1J.C1J_STAMP)) = 0 OR Length(trim(C1J.C1J_STAMP)) IS NULL ) OR ( Length(trim(C1J.C1J_STAMP)) > 0 AND SAH.S_T_A_M_P_ > TO_TIMESTAMP(C1J.C1J_STAMP,'dd.mm.yyyy hh24:mi:ss.ff') ) ) "
        else
            cQuery += "  AND (  C1J.C1J_STAMP IS NULL OR (" + cConvCPO + " > C1J.C1J_STAMP) ) "
        endif
    Else
        If cDbType $ "ORACLE"
            cQuery += "  AND SAH.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff') "
        else
            cQuery += "  AND " + cConvCPO + " > '" + Alltrim(cUltStmp) + "' "
        endif
    Endif

    cQuery += "  AND SAH.D_E_L_E_T_ = ' ' "

    self:TSITQRY := cQuery

Return

 /*/{Protheus.doc} PrepQuery
	(M�todo respons�vel por retornar a propriedade self:cFinalQuery
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/

Method GetQry() Class TSIUM
return self:cFinalQuery

 /*/{Protheus.doc} JSon
	(M�todo respons�vel montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/

Method JSon() Class TSIUM

    Local cAlias    := getNextAlias( )
    Local nLen      := 0
    Local oJObjRet  := nil

    oJObjRet := JsonObject( ):New( )

    DbSelectArea( "C1J" )
    C1J->( DbSetOrder( 1 ) )
 
    dbUseArea( .T., "TOPCONN", TCGenQry( ,, self:GetQry( ) ), cAlias, .F., .T. )

    TAFConOut("TSILOG00006: Query de busca do cadastro de Unidade de Medida [ In�cio query TSILOG00002 " + TIME() + "  ]" + self:GetQry() + " [ Fim query TSILOG00002 " + TIME() + " ]") 

    oJObjRet['unitOfMeasureCode'] := { }

    While ( cAlias )->( !EOF( ) )

        aAdd( oJObjRet['unitOfMeasureCode'], JsonObject( ):New( ) )
        nLen++
                                                                                                    // Campos da Planilha Layout TAF - T005
        oJObjRet['unitOfMeasureCode'][nLen]["unitOfMeasureCode" ] := alltrim( ( cAlias )->UNIMED )  // 02 UNID
        oJObjRet['unitOfMeasureCode'][nLen]["description"       ] := alltrim( ( cAlias )->UMRES  )  // 03 DESCR
        oJObjRet['unitOfMeasureCode'][nLen]["stamp"             ] := ( cAlias )->STAMP

        ( cAlias )->( DBSKIP( ) )
    EndDo

    ( cAlias )->( DBCloseArea( ) )

    self:oJObjTSI := oJObjRet

Return

 /*/{Protheus.doc} GetJsn
	(M�todo respons�vel retornar a propriedade self:oJObjTSI
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno. 
/*/
Method GetJsn () Class TSIUM

Return self:oJObjTSI

 /*/{Protheus.doc} TSIUM
	(M�todo respons�vel por montar o conte�do da filial da C1H
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, n�o tem retorno.
/*/
Method FilC1J(cSourceBr) Class TSIUM        
     self:cFilC1J := TafTSIFil(cSourceBr, 'C1J')      
Return
