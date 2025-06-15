#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
Static cUltStmp := iif(lNewCtrl, TsiUltStamp("C1L"),' ')

static nTmFTPrd := GetSx3Cache( 'FT_PRODUTO' , 'X3_TAMANHO' )
static nTmB1Prd := GetSx3Cache( 'B1_COD'     , 'X3_TAMANHO' )

/*/{Protheus.doc} TSIITEM
	(Classe que contém preparedstatament do T005 )
    @type Class
	@author Henrique Pereira 
    @author Carlos Eduardo
	@since 10/06/2020
	@return Nil, nulo, não tem retorno.
/*/ 
 
Class TSIITEM

    Data TSITQRY     as String ReadOnly
    Data cFinalQuery as String ReadOnly 
    Data oStatement  as Object ReadOnly
    Data aFilC1L     as Array  ReadOnly
    Data oJObjTSI    as Object
    Data cAlias      as String 
    Data nTotReg     as numeric
    Data nSizeMax    as numeric
    Data nReg        as numeric 

    Method New() Constructor
    Method PrepQuery()
    Method LoadQuery()
    Method JSon()
    Method TempTable()
    Method FilC1L()

    Method GetQry()
    Method GetJsn()
    Method CommitRegs()

EndClass

/*/{Protheus.doc} New
	(Método contrutor da classe TSIITEM )
    Fluxo New:
    1º Monta-se a query com LoadQuery()
    2º Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros
	@type Class
	@author Henrique Pereira 
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
 
Method New(cSourceBr) Class TSIITEM
    Self:FilC1L(cSourceBr)
    self:nSizeMax := 1000       //Seta limite máximo de execução para ser chamado no TAFA565
    Self:LoadQuery()
    Self:PrepQuery()
    Self:TempTable()  
Return Nil

/*/{Protheus.doc} PrepQuery
	(Método responsável por Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros )
    @type Class
	@author Henrique Pereira
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno. 
/*/

Method PrepQuery() Class TSIITEM

    self:oStatement := FWPreparedStatement():New()
    self:oStatement:SetQuery(self:TSITQRY)
    self:cFinalQuery := self:oStatement:GetFixQuery()

Return Nil

 /*/{Protheus.doc} LoadQuery
	(Método responsável por montar a query para o preparedstatemen, por hora ainda com '?'
    nos parâmetros variáveis
	@author Henrique Pereira 
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method LoadQuery() Class TSIITEM

Local cQuery    := ''
Local aBlocok   := {}
Local cB1Sped   := GetNewPar('MV_DTINCB1','')
Local nIcmPad   := GetNewPar('MV_ICMPAD','')
Local cDbType   := Upper(Alltrim(TCGetDB()))
Local cConvB1   := ''
Local cConvB5   := ''
Local cConvF2Q  := ''
Local cConvPROD := ''
Local cConvISS  := ''
Local nX        := 1
Local cMensagem := ''

//Guardo todos os parametros referente ao bloco K no array.
aadd(aBlocok,{GetNewPar('MV_BLKTP00',''),'MV_BLKTP00'}) // Mercadoria para revenda
aadd(aBlocok,{GetNewPar('MV_BLKTP01',''),'MV_BLKTP01'}) // Materia Prima
aadd(aBlocok,{GetNewPar('MV_BLKTP02',''),'MV_BLKTP02'}) // Embalagem
aadd(aBlocok,{GetNewPar('MV_BLKTP03',''),'MV_BLKTP03'}) // Produto em processo
aadd(aBlocok,{GetNewPar('MV_BLKTP04',''),'MV_BLKTP04'}) // Produto acabado
aadd(aBlocok,{GetNewPar('MV_BLKTP06',''),'MV_BLKTP06'}) // Produto Intermediario
aadd(aBlocok,{GetNewPar('MV_BLKTP10',''),'MV_BLKTP10'}) // OUtros Insumos

// Criado for para tratar os casos em que o valor informado nos parâmetros MV_BLKTPXX não começam ou não
// terminam com aspas simples, evitando quebra na query.

cMensagem += "TSILOG000022: Conteudo dos parametros do bloco K ->> MV_BLKTPXX:" +chr(10)

For nX := 1 to len(aBlocok)
    If !Empty(aBlocok[nX,1])
        If  SubStr(Alltrim(aBlocok[nX,1]), 1, 1 ) != "'" .OR. SubStr(Alltrim(aBlocok[nX,1]), len(AllTrim(aBlocok[nX,1])),1) != "'"
            aBlocok[nX,1] := AllTrim(StrTran( aBlocok[nX,1], '"', '' ))
            aBlocok[nX,1] := "'" + AllTrim(StrTran( aBlocok[nX,1], "'", '' )) + "'" 
        Endif

        cMensagem += aBlocok[nX,2] + " : " + aBlocok[nX,1]+chr(10)
      
    Else
        cMensagem += "Parametro: "+ aBlocok[nX,2] + " Vazio "
    Endif

Next nX

TAFConOut(cMensagem) 

if !empty(cB1Sped) 
	cB1Sped := StrTran(cB1Sped, '"','')
	cB1Sped := StrTran(cB1Sped, "'",'')
    cB1Sped := 'B1.'+alltrim(cB1Sped)
else
    cB1Sped := dtos(dDataBase)
endif

//Gerando registro T007

cQuery := " SELECT "  

If cDbType $ "MSSQL/MSSQL7"
    cConvB1     := " convert(varchar(23), B1.S_T_A_M_P_ , 21 ) "
    cConvB5     := " convert(varchar(23), B5.S_T_A_M_P_ , 21 ) "
    cConvF2Q    := " convert(varchar(23), F2Q.S_T_A_M_P_ , 21 ) "   
    cConvPROD   := " convert(varchar(23), CDNPROD.S_T_A_M_P_ , 21 ) "
    cConvISS    := " convert(varchar(23), CDNISS.S_T_A_M_P_  , 21 ) "
Elseif cDbType $ "ORACLE"
    cConvB1     := " cast( to_char(B1.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    cConvB5     := " cast( to_char(B5.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    cConvF2Q    := " cast( to_char(F2Q.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    cConvPROD   := " cast( to_char(CDNPROD.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
    cConvISS    := " cast( to_char(CDNISS.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
Elseif cDbType $ "POSTGRES"
    cConvB1     := " cast( to_char(B1.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    cConvB5     := " cast( to_char(B5.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    cConvF2Q    := " cast( to_char(F2Q.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    cConvPROD   := " cast( to_char(CDNPROD.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
    cConvISS    := " cast( to_char(CDNISS.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
Endif

cQuery += cConvB1 + " B1_STAMP, "
cQuery += cConvB5 + " B5_STAMP, "
cQuery += cConvF2Q + " F2Q_STAMP, "   
cQuery += cConvPROD + " CDNPROD_STAMP, "
cQuery += cConvISS + " CDNISS_STAMP, "
cQuery += "B1.B1_COD COD_ITEM, " // 02 - COD_ITEM
cQuery += "B1.B1_DESC  DESCR_ITEM, " // 03 - DESCR_ITEM
cQuery += "B1.B1_UM UNID_INV, " // 05 - UNID_INV
cQuery += "case " 
cQuery += "   when B1.B1_CODISS != '' then '09' "
cQuery += "   when B1.B1_TIPO = 'AI' then '08' "
//Coloco IFF para veriifcar se a posição do array é branco. Caso seja, não há motivos para ter operador OR, pois iria
//criar um IN com o valor BRANCO.
IIF (!Empty(aBlocok[03,01]) , cQuery += "   when B1.B1_TIPO = 'EM' OR B1.B1_TIPO IN ("+aBlocok[03,01]+") then '02' " , cQuery += " when B1.B1_TIPO = 'EM' then '02' ")
cQuery += "   when B1.B1_TIPO = 'MC' then '07' "
IIF (!Empty(aBlocok[01,01]) , cQuery += "   when B1.B1_TIPO = 'ME' OR B1.B1_TIPO IN ("+aBlocok[01,01]+") then '00' " , cQuery += " when B1.B1_TIPO = 'ME' then '00' ")
IIF (!Empty(aBlocok[02,01]) , cQuery += "   when B1.B1_TIPO = 'MP' OR B1.B1_TIPO IN ("+aBlocok[02,01]+") then '01' " , cQuery += " when B1_TIPO = 'MP' then '01' ")
IIF (!Empty(aBlocok[07,01]) , cQuery += "   when B1.B1_TIPO = 'OI' OR B1.B1_TIPO IN ("+aBlocok[07,01]+") then '10' " , cQuery += " when B1_TIPO = 'OI' then '10' ")
IIF (!Empty(aBlocok[05,01]) , cQuery += "   when B1.B1_TIPO = 'PA' OR B1.B1_TIPO IN ("+aBlocok[05,01]+") then '04' " , cQuery += " when B1_TIPO = 'PA' then '04' ")
IIF (!Empty(aBlocok[06,01]) , cQuery += "   when B1.B1_TIPO = 'PI' OR B1.B1_TIPO IN ("+aBlocok[06,01]+") then '06' " , cQuery += " when B1_TIPO = 'PI' then '06' ")
IIF (!Empty(aBlocok[04,01]) , cQuery += "   when B1.B1_TIPO = 'PP' OR B1.B1_TIPO IN ("+aBlocok[04,01]+") then '03' " , cQuery += " when B1_TIPO = 'PP' then '03' ")
IIF (!Empty(aBlocok[05,01]) , cQuery += "   when B1.B1_TIPO = 'SP' OR B1.B1_TIPO IN ("+aBlocok[05,01]+") then '05' " , cQuery += " when B1_TIPO = 'SP' then '05' ")
cQuery += "else '99' end TIPO_ITEM, " //Verificar se o conteúdo deverá vir do sped // 06 - TIPO_ITEM
cQuery += "B1.B1_POSIPI COD_NCM, " // 07 - COD_NCM
cQuery += "B1.B1_EX_NCM EX_IPI, " // 08 - EX_IPI
cQuery += "case "
cQuery += "   when CDNPROD.CDN_CODLST IS NOT NULL then CDNPROD.CDN_CODLST "
cQuery += "   when CDNISS.CDN_CODLST IS NOT NULL then CDNISS.CDN_CODLST "
cQuery += "else '' end COD_LST, "														//-- 10 - COD_LST -> Na posição 10 vai o código de serviço federal.
cQuery += "B1.B1_ORIGEM ORIGEM, "																//-- 14 - ORIGEM
cQuery += "case when B1.B1_PICM > 0 then B1.B1_PICM else " + str(nIcmPad,5,2) + " end ALIQ_ICMS,  " //-- 16 - ALIQ_ICMS
cQuery += "B1.B1_IPI ALIQ_IPI, "                                                               //-- 18 - ALIQ_IPI -- Val2Str((cAliasQry)->B1_IPI,5,2))
cQuery += "case "
// Caso existe a tabela e o campo, priorizo o tipo de serviço da reinf que esta no cadastro do produto.
if TAFAlsInDic('F2Q') .and. TafColumnPos('F2Q_TPSERV')
    cQuery += "when F2Q.F2Q_TPSERV IS NOT NULL AND F2Q.F2Q_TPSERV != '' then F2Q.F2Q_TPSERV " 
endif
cQuery += "   when CDNPROD.CDN_CODLST IS NOT NULL then CDNPROD.CDN_TPSERV "
cQuery += "   when CDNISS.CDN_CODLST IS NOT NULL then CDNISS.CDN_TPSERV "
cQuery += "else '' end TIP_SERV, " //29 - TIP_SERV	 
cQuery += "B1.B1_CODISS, B1.B1_PICM " //-- Campos auxiliares
cQuery += "FROM " + RetSqlName('SB1') + " B1 "

cQuery += "LEFT JOIN " + RetSqlName('SB5') + " B5 ON B5.B5_FILIAL = '" + xFilial( "SB5" ) + "' AND B5.B5_COD = B1.B1_COD AND B5.D_E_L_E_T_ = ' ' " // Left Join com SB5 porque serão incluídos campos para registros REINF
If cDbType $ "ORACLE"
    cQuery += "AND B5.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff') "
else
    cQuery += " AND " +  cConvB5   + " > '" + AllTrim(cUltStmp) + "' "
endif

cQuery += "FULL OUTER JOIN " + RetSqlName('CDN') + " CDNPROD ON CDNPROD.CDN_FILIAL = '" + xFilial( "CDN" ) + "' AND CDNPROD.CDN_CODISS = B1.B1_CODISS AND CDNPROD.CDN_PROD = B1.B1_COD AND CDNPROD.D_E_L_E_T_ = ' ' "
If cDbType $ "ORACLE"
    cQuery += " AND CDNPROD.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff') "
else
    cQuery += " AND " +  cConvPROD + " > '" + AllTrim(cUltStmp) + "' "
endif

cQuery += "FULL OUTER JOIN " + RetSqlName('CDN') + " CDNISS ON CDNISS.CDN_FILIAL = '" + xFilial( "CDN" ) + "' AND CDNISS.CDN_CODISS = B1.B1_CODISS AND CDNISS.CDN_PROD = '' AND CDNISS.D_E_L_E_T_ = ' ' "
If cDbType $ "ORACLE"
    cQuery += " AND CDNISS.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff') "
else
    cQuery += " AND " + cConvISS  + " > '" + AllTrim(cUltStmp) + "' "
endif

if TAFAlsInDic('F2Q') .and. TafColumnPos('F2Q_TPSERV')
    cQuery += "LEFT JOIN " + RetSqlName('F2Q') + " F2Q ON F2Q.F2Q_FILIAL = '" + xFilial( "F2Q" ) + "' AND F2Q.F2Q_PRODUT = B1.B1_COD AND F2Q.D_E_L_E_T_ = ' ' "
    If cDbType $ "ORACLE"
        cQuery += " AND F2Q.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff') "
    else
        cQuery += " AND " +  cConvF2Q  + " > '" + AllTrim(cUltStmp) + "' "
    endif
endif
cQuery += "WHERE B1.D_E_L_E_T_ = ' ' "
cQuery += "AND B1.B1_FILIAL = '" + xFilial('SB1') + "' "
If cDbType $ "ORACLE"
    cQuery += " AND B1.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff')  "
Else
    cQuery += " AND " +  cConvB1   + " > '" + AllTrim(cUltStmp) + "'  "
Endif
cQuery += " AND EXISTS ( SELECT "
if "MSSQL" $ cDbType
    cQuery += " TOP 1 "
endif
cQuery += " FT_PRODUTO FROM " + RetSqlName("SFT") + " SFT WHERE "
cQuery += " SFT.FT_FILIAL = '" + xFilial( "SFT" ) + "' "

if nTmFTPrd == nTmB1Prd
    cQuery += " AND SFT.FT_PRODUTO = B1.B1_COD "
else
    cQuery += " AND RTRIM( SFT.FT_PRODUTO ) = RTRIM( B1.B1_COD ) "
endif

cQuery += " AND SFT.D_E_L_E_T_ = ' ' "

//Nao utilizar esse filtro, mesmo na 1° execução, pois o ultstamp vira com conteudo (ver tratamento para C1H|C1L
//no TsiUltStamp do TSIXFUN), se manter esse filtro na query havera perda de performance na JadLog.
//cQuery += " AND SFT.S_T_A_M_P_ IS NOT NULL "

If cDbType $ "ORACLE"
    cQuery += " AND ROWNUM <= 1 " //ganho de performance com top no exists jadlog
ElseIf cDbType $ "POSTGRES"
    cQuery += " LIMIT 1 "
Endif

cQuery += " ) "

self:TSITQRY := cQuery

Return

/*/{Protheus.doc} PrepQuery
	(Método responsável por retornar a propriedade self:cFinalQuery
	@author Henrique Pereira
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method GetQry() Class TSIITEM
return self:cFinalQuery

/*/{Protheus.doc} TempTable(
	(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method TempTable() Class TSIITEM

    Self:cAlias    := getNextAlias( )
    TAFConOut("TSILOG00009: Query de busca dos Produtos [ Início query TSILOG00009 " + TIME() + " ] " + self:GetQry(), 1, .F., "TSI" ) 
    dbUseArea( .T., "TOPCONN", TCGenQry( ,, self:GetQry( ) ), Self:cAlias, .F., .T. )
    Count to self:nTotReg
    (Self:cAlias)->(dbGoTOp())

    TAFConOut("TSILOG00009: Query de busca dos Produtos [ Fim query TSILOG00009 " + TIME() + " ] ", 1, .F., "TSI" )

Return

/*/{Protheus.doc} GetJsn
	(Método responsável retornar a propriedade self:oJObjTSI
	@author Henrique Pereira
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.  
/*/

Method GetJsn() Class TSIITEM

    Local cCodNcm   := ""
    Local cTpServ   := ""
    Local nTamDesc  := TAMSX3("C1L_DESCRI")[1]

    Local oJObjRet  := JsonObject( ):New( )
   
    //Gravo o maior stamp entro todos que compoe o registro
    cStamp := aSort( {(self:cAlias)->B1_STAMP, (self:cAlias)->B5_STAMP,(self:cAlias)->F2Q_STAMP, (self:cAlias)->CDNPROD_STAMP, (self:cAlias)->CDNISS_STAMP } ,,, { |x, y| x > y } )[1] 
    
    cCodNcm := alltrim( ( self:cAlias )->COD_NCM ) + alltrim(iif( !empty( ( self:cAlias )->EX_IPI ), ( self:cAlias )->EX_IPI, '' ))
    cTpServ := iif( !empty( ( self:cAlias )->TIP_SERV ), '1' + StrZero( Val( ( self:cAlias )->TIP_SERV ), 08 ), ''  )
    
    // Campos da Planilha Layout TAF - T007
    oJObjRet["itemId"       ] := rtrim( ( self:cAlias )->COD_ITEM )	    // 02 COD_ITEM 
    oJObjRet["description"  ] := Alltrim( SUBSTR( ( self:cAlias )-> DESCR_ITEM,1,nTamDesc) )   // 03 DESCR_ITEM
    oJObjRet["unit"         ] := ( self:cAlias )->UNID_INV              // 05 UNID_INV
    oJObjRet["itemType"     ] := alltrim( ( self:cAlias )->TIPO_ITEM )  // 06 TIPO_ITEM
    oJObjRet["idNcm"        ] := cCodNcm                                // 07 COD_NCM
    oJObjRet["serviceId"    ] := alltrim( ( self:cAlias )->COD_LST )    // 10 COD_LST
    oJObjRet["originId"     ] := ( self:cAlias )->ORIGEM                // 14 ORIGEM
    oJObjRet["icmsRate"     ] := ( self:cAlias )->ALIQ_ICMS             // 16 ALIQ_ICMS
    oJObjRet["ipiRate"      ] := ( self:cAlias )->ALIQ_IPI              // 18 ALIQ_IPI
    oJObjRet["serviceTypeId"] := cTpServ                                // 29 TIP_SERV
    oJObjRet["stamp"        ] := cStamp

Return oJObjRet

/*/{Protheus.doc} FilC1L
	(Método responsável por montar o conteúdo da filial da C1H
	@author Henrique Pereira
    @author Carlos Eduardo
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method FilC1L(cSourceBr) Class TSIITEM        
    self:aFilC1L := TafTSIFil(cSourceBr, 'C1L')      
Return

Method CommitRegs(oHash, cUltStmp) Class TSIITEM  
    
    Local nGetNames := 0
    Local oBjJson   := 0

    Default cUltStmp := ''

    self:nReg := 0

    oJObjRet := JsonObject( ):New( )
    oJObjRet['item'] := { }
    
    (Self:cAlias)->(dbGoTop())
    while (Self:cAlias)->(!EOF())
        self:nReg ++
        
        oBjJson := Self:GetJsn()
        aadd(oJObjRet['item'],oBjJson)
        
        //Verifico se atingiu o limite de registros por array ou se o registro processado é igual ao ultimo da temp table
        IF self:nReg == self:nSizeMax .or. (Self:cAlias)->(RECNO()) == Self:nTotReg

            TAFConOut("TSILOG000025 Item (Cadastro de Produtos) " + cValtoChar((Self:cAlias)->(RECNO())) + " de " + cValToChar(Self:nTotReg),1,.F.,"TSI")
            
            for nGetNames := 1 to len( oJObjRet:GetNames() )
                TAFConOut("TSILOG00004 GetNames ok: " + cvaltochar(len( oJObjRet:GetNames() )))
                aObjJson := oJObjRet:GetJsonObject( oJObjRet:GetNames()[nGetNames] )

                //Utilizara novo motor pai e filho TAFA585, ex: processo referenciado e suspensao
                TAFA565( oHash, aObjJson, , , , @cUltStmp )
            next nGetNames
            
            ASIZE(aObjJson,0)
            aObjJson := {}

            FreeObj(oBjJson)
            oBjJson := NIL
            self:nReg := 0
        Endif

        (Self:cAlias)->(dbSkip())

    enddo

Return
