#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
Static cUltStmp := iif(lNewCtrl, TsiUltStamp("C1H"),' ')
Static nIndCP   := 0

Static lCompSA1 := iif(Upper(AllTrim(FWModeAccess("SA1",1)+FWModeAccess("SA1",2)+FWModeAccess("SA1",3))) == 'CCC',.T.,.F.)
Static lCompSA2 := iif(Upper(AllTrim(FWModeAccess("SA2",1)+FWModeAccess("SA2",2)+FWModeAccess("SA2",3))) == 'CCC',.T.,.F.)
Static lCompC1H := iif(Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3))) == 'CCC',.T.,.F.)
Static lAliErp  := iif(lNewCtrl,V80->(FieldPos("V80_ALIERP") ) > 0,.F.)
//Tratamento para filtrar e atualizar o V80_COMPAR = 1 (Sim), caso cliente utilize base totalmente compartilhada para os participantes (SA1\SA2 e C1H).
Static lCompar  := iif(lNewCtrl, (V80->(FieldPos("V80_COMPAR") ) > 0 .And. lCompSA1  .And. lCompSA2  .And. lCompC1H) ,.F.)
Static cStmpSA1 := iif(lAliErp,TsiUltStamp("C1H",/*2*/,'SA1',lAliErp,lCompar),cUltStmp)
Static cStmpSA2 := iif(lAliErp,TsiUltStamp("C1H",/*2*/,'SA2',lAliErp,lCompar),cUltStmp)

/*/{Protheus.doc} TSIPARTIC
	(Classe que para consula e retorno da mensagem Json )
    @type Class
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Class TSIPARTIC
Data cQRY        as String
Data cFinalQuery as String
Data aFilC1H     as String
Data oStatement  as Object
Data cAlias      as String
Data nTotReg     as numeric
Data nSizeMax    as numeric

Method New() Constructor
Method PrepQuery()
Method LoadQuery() 
Method JSon()
Method TempTable()
Method FilC1H() 

Method GetQry()
Method GetJsn()
Method CommitRegs()

EndClass

/*/{Protheus.doc} New
	(Método contrutor da classe TSIPARTIC )
    Fluxo New:
    1º Monta-se a query com LoadQuery()
    2º Instaciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros
	@type Class
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method New(cSourceBr) Class TSIPARTIC 
    self:FilC1H(cSourceBr)
    self:nSizeMax := 1000       //Seta limite máximo de execução para ser chamado no TAFA565
    Self:LoadQuery()  
    Self:PrepQuery()   
    Self:TempTable()  
Return Nil

/*/{Protheus.doc} PrepQuery
	(Método responsável por Instaciar o preparedStatement com PrepQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros )
    @type Class
	@author Henrique Pereira    
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/ 

Method PrepQuery() Class TSIPARTIC

    self:oStatement := FWPreparedStatement():New()
    self:oStatement:SetQuery(self:cQRY)


    self:cFinalQuery := self:oStatement:GetFixQuery()

Return Nil

 /*/{Protheus.doc} PrepQuery
	(Método responsável por montar a query para o preparedstatemen, por hora ainda com '?'
    nos parâmetros variáveis
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method LoadQuery() Class TSIPARTIC

Local cDbType   := Upper(Alltrim(TCGetDB()))
Local cConcat   := " "
Local cQuery    := " "
Local cConvSA1  := " "
Local cConvSA2  := " "
Local lTemDKE   := .F. 
Local nTmStmp   := 0

// VerIfica o tipo de concatenação para o banco
If "MSSQL" $ cDbType
	cConcat := "+"
Else
	cConcat := "||"
EndIf

lTemDKE := TableInDic("DKE")

cQuery += " SELECT "   
cQuery += " SA1.A1_COD CODIGO, "
cQuery += " SA1.A1_LOJA LOJA, "
cQuery += " ( 'C' " + cConcat + " SA1.A1_COD " + cConcat + " RTRIM(SA1.A1_LOJA) ) COD_PART, "
cQuery += " SA1.A1_NOME NOME, " 
cQuery += " SA1.A1_CODPAIS COD_PAIS, "

DbSelectArea("SA2")
nIndCP := SA2->(FieldPos("A2_INDCP"))
if nIndCP > 0
    cQuery += "	' ' INDCP, "
endif
SA2->(DbCloseArea())

cQuery += "	' ' INDRUR, "
cQuery += "	' ' CPFRUR, "
cQuery += " SA1.A1_CGC CGC, "
cQuery += " SA1.A1_INSCR IE, "
cQuery += " CASE WHEN SA1.A1_EST='EX' THEN '99999' ELSE SA1.A1_COD_MUN END COD_MUN, "
cQuery += " SA1.A1_SUFRAMA SUFRAMA, "
cQuery += " SA1.A1_END ENDERECO, "
cQuery += " SA1.A1_COMPLEM COMPL, "
cQuery += " SA1.A1_BAIRRO BAIRRO, "
cQuery += " SA1.A1_EST UF, "
cQuery += " SA1.A1_CEP CEP, "
cQuery += " SA1.A1_DDD DDD, "
cQuery += " SA1.A1_TEL FONE, "		
cQuery += " SA1.A1_EMAIL EMAIL, "
cQuery += " CASE WHEN SA1.A1_TIPO <> 'X' AND SA1.A1_PESSOA = 'F' THEN '1' WHEN SA1.A1_TIPO <> 'X' AND SA1.A1_PESSOA = 'J' THEN '2' WHEN SA1.A1_TIPO = 'X' THEN '3' ELSE '' END TP_PESSOA, "
cQuery += " '' RAMO_ATV, "
cQuery += " '0' INDCPRB, "
cQuery += " AI0.AI0_INDPAA EXECPAA, "
cQuery += " '' IND_ASSOC_DESPORT, "
cQuery += " SA1.A1_CONTRIB CONTRIBUINTE, "
cQuery += " '' ISENCAO_IMUNIDADE, "
cQuery += " '' ESTADO_EXT, "
cQuery += " '' TELEFONE_EXT, "
cQuery += " '' NIF," 
cQuery += " '' FORMA_TRIBUTACAO,"

cQuery += " '' COD_PAIS_EXT, "
cQuery += " '' LOGRAD_EXT, "
cQuery += " '' NR_LOGRAD_EXT, "
cQuery += " '' COMPLEM_EXT, "
cQuery += " '' BAIRRO_EXT, "
cQuery += " '' NOME_CIDADE_EXT, "
cQuery += " '' COD_POSTAL_EXT, "
cQuery += " '' REL_FONTE_PAG_RESID_EXTERIOR, "
cQuery += " '' INDICATIVO_NIF_EXT, "
cQuery += "	'' TIPO_PESSOA_EXTERIOR, "

If cDbType $ "MSSQL/MSSQL7"
    cConvSA1 := " convert(varchar(23), SA1.S_T_A_M_P_ , 21 ) "
Elseif cDbType $ "ORACLE"
    cConvSA1 := " cast( to_char(SA1.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
Elseif cDbType $ "POSTGRES"
    cConvSA1 := " cast( to_char(SA1.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
Endif

cQuery += cConvSA1 + " STAMP, "
cQuery += " 'SA1' TABELA,"
cQuery += "  SA1.R_E_C_N_O_ RECNO "
cQuery += "  FROM " + RetSqlName("SA1") + " SA1 "


cQuery += "  LEFT JOIN "+RetSqlName("AI0")+ " AI0 ON 
cQuery += "  AI0.AI0_FILIAL = SA1.A1_FILIAL AND "
cQuery += "  AI0.AI0_CODCLI = SA1.A1_COD AND "
cQuery += "  AI0.AI0_LOJA = SA1.A1_LOJA  AND "
cQuery += "  AI0.D_E_L_E_T_ = ' ' "
cQuery += "  WHERE SA1.A1_FILIAL = '" + xFilial( "SA1" ) + "' "

	cQuery += " AND SA1.S_T_A_M_P_ IS NOT NULL "
     if cDbType $ "ORACLE"
        nTmStmp := Len( Alltrim( cStmpSA1 ) )
       if nTmStmp >= 22 //posui centesimos
            cStmpSA1 := SubString( Alltrim( cStmpSA1 ) , 1 , (nTmStmp-4) )
            cStmpSA1 += ".999"
        endif
        cQuery += " AND SA1.S_T_A_M_P_ > to_timestamp('" + cStmpSA1 + "','dd.mm.yyyy hh24:mi:ss.ff') "
    else
        cQuery += " AND " + cConvSA1 + "> '" + Alltrim(cStmpSA1) + "' "
    endif
cQuery += "  AND SA1.D_E_L_E_T_ = ' ' "

//Tratamento abaixo, para ignorar clientes que nao constam na SFT ("sem nota"). Atualmente o cliente Sequoia possui um processo de integracao com muitos clientes que nao
//sao necessarios para a geracao da gia. A cada 15 minutos entravam mais de 2.000 registros que nao sao necessarios e demorava mais de 30 minutos para processa-los, depois processava
//o lote de 500 notas, depois tornava a colocar participantes desnecessarios. Fazendo que a gravaçao de nota ficasse bem lenta por causa dessa volumetria desnecessaria, estavam sendo
//processados apenas 1.000 notas a cada 1 hora, so que a volumetria do cliente eh 10x maior por hora.
cQuery += " AND SA1.A1_ULTCOM <> ' ' "

cQuery += " UNION ALL "

cQuery += " SELECT " 

cQuery += " SA2.A2_COD CODIGO, "
cQuery += " SA2.A2_LOJA LOJA, "
cQuery += " ( 'F' " + cConcat + " SA2.A2_COD " + cConcat + " SA2.A2_LOJA ) COD_PART, "
cQuery += " SA2.A2_NOME NOME, "
cQuery += " SA2.A2_CODPAIS COD_PAIS, "
if nIndCP > 0
    cQuery += "	SA2.A2_INDCP INDCP, "
endif
cQuery += "	SA2.A2_INDRUR INDRUR, "
cQuery += " CASE WHEN SA2.A2_TIPO = 'F' AND SA2.A2_INDRUR <> ' ' AND SA2.A2_INDRUR <> '0' AND SA2.A2_EST IN ('SP','MG') THEN SA2.A2_CPFRUR ELSE ' ' END CPFRUR, "
cQuery += " SA2.A2_CGC CGC, "
cQuery += " SA2.A2_INSCR IE, " 
cQuery += " CASE WHEN SA2.A2_EST='EX' THEN '99999' ELSE SA2.A2_COD_MUN END COD_MUN, "
cQuery += " '' SUFRAMA, "
cQuery += " SA2.A2_END " + cConcat + " SA2.A2_EST ENDERECO, " 
cQuery += " SA2.A2_COMPLEM COMPL, "
cQuery += " SA2.A2_BAIRRO BAIRRO, "
cQuery += " SA2.A2_EST UF, "
cQuery += " SA2.A2_CEP CEP, "
cQuery += " SA2.A2_DDD DDD, "
cQuery += " SA2.A2_TEL FONE,	"
cQuery += " SA2.A2_EMAIL EMAIL, "
cQuery += " CASE WHEN SA2.A2_TIPO <> 'X' AND SA2.A2_TIPO = 'F' THEN '1' WHEN SA2.A2_TIPO <> 'X' AND SA2.A2_TIPO = 'J' THEN '2' WHEN SA2.A2_TIPO = 'X' THEN '3' ELSE '' END TP_PESSOA, "
cQuery += " CASE WHEN SA2.A2_TIPORUR <> ' ' THEN '4' ELSE '' END RAMO_ATV, "
cQuery += " CASE WHEN SA2.A2_CPRB = '2' THEN '0' ELSE SA2.A2_CPRB END INDCPRB, "
cQuery += " '' EXECPAA, "
cQuery += " SA2.A2_DESPORT IND_ASSOC_DESPORT, "
cQuery += " SA2.A2_CONTRIB CONTRIBUINTE, "
cQuery += IIF(lTemDKE," DKE.DKE_ISEIMU ISENCAO_IMUNIDADE, ", " '' ISENCAO_IMUNIDADE, ")
cQuery += " SA2.A2_ESTEX ESTADO_EXT, "
cQuery += " SA2.A2_TELRE TELEFONE_EXT, "
cQuery += " SA2.A2_NIFEX NIF, "
cQuery += " SA2.A2_TRBEX FORMA_TRIBUTACAO, "

cQuery += " SA2.A2_PAISEX COD_PAIS_EXT, "
cQuery += "	SA2.A2_LOGEX LOGRAD_EXT, "
cQuery += "	SA2.A2_NUMEX NR_LOGRAD_EXT, "
cQuery += "	SA2.A2_COMPLR COMPLEM_EXT, "
cQuery += "	SA2.A2_BAIEX BAIRRO_EXT, "
cQuery += "	SA2.A2_CIDEX NOME_CIDADE_EXT, "
cQuery += "	SA2.A2_POSEX COD_POSTAL_EXT, "
cQuery += "	SA2.A2_BREEX REL_FONTE_PAG_RESID_EXTERIOR, "
cQuery += "	CASE WHEN SA2.A2_MOTNIF = '1' AND SA2.A2_NIFEX = ' ' THEN '2' WHEN SA2.A2_MOTNIF = '2' AND SA2.A2_NIFEX = ' ' THEN '3' WHEN SA2.A2_NIFEX <> ' ' THEN '1' ELSE ' ' END INDICATIVO_NIF_EXT, "
cQuery += IIF(lTemDKE," DKE.DKE_PEEXTE TIPO_PESSOA_EXTERIOR, ", " '' TIPO_PESSOA_EXTERIOR, ")

If cDbType $ "MSSQL/MSSQL7"
    cConvSA2 := " convert(varchar(23), SA2.S_T_A_M_P_ , 21 ) "
Elseif cDbType $ "ORACLE"
    cConvSA2 := " cast( to_char(SA2.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
Elseif cDbType $ "POSTGRES"
    cConvSA2 := " cast( to_char(SA2.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
Endif

cQuery += cConvSA2 + " STAMP, "
cQuery += " 'SA2' TABELA, "
cQuery += " SA2.R_E_C_N_O_ RECNO " 
cQuery += " FROM " +RetSqlName("SA2") + " SA2 "
If lTemDKE
    cQuery += " LEFT JOIN "+RetSqlName("DKE")+ " DKE "
    cQuery += " ON  SA2.A2_FILIAL = DKE.DKE_FILIAL "
    cQuery += " AND SA2.A2_COD = DKE.DKE_COD "
    cQuery += " AND SA2.A2_LOJA = DKE.DKE_LOJA "
    cQuery += " AND DKE.D_E_L_E_T_ = ' ' "
Endif

cQuery += " WHERE SA2.A2_FILIAL = '" + xFilial( "SA2" ) + "' "

	cQuery += " AND SA2.S_T_A_M_P_ IS NOT NULL "
    if cDbType $ "ORACLE"
        nTmStmp := Len( Alltrim( cStmpSA2 ) )
       if nTmStmp >= 22 //posui centesimos
            cStmpSA2 := SubString( Alltrim( cStmpSA2 ) , 1 , (nTmStmp-4) )
            cStmpSA2 += ".999"
        endif
        cQuery += " AND SA2.S_T_A_M_P_ > to_timestamp('" + cStmpSA2 + "','dd.mm.yyyy hh24:mi:ss.ff') "
    else
        cQuery += " AND " + cConvSA2 + "> '" + Alltrim(cStmpSA2) + "' "
    endif

cQuery += " AND SA2.D_E_L_E_T_ = ' ' "

//Tratamento abaixo, para ignorar fornecedores que nao constam na SFT ("sem nota"). Atualmente o cliente Sequoia possui um processo de integracao com muitos fornecedores que nao 
//sao necessarios para a geracao da gia. A cada 15 minutos entravam mais de 2.000 registros que nao sao necessarios e demorava mais de 30 minutos para processa-los, depois processava 
//o lote de 500 notas, depois tornava a colocar participantes desnecessarios. Fazendo que a gravaçao de nota ficasse bem lenta por causa dessa volumetria desnecessaria, estavam sendo 
//processados apenas 1.000 notas a cada 1 hora, so que a volumetria do cliente eh 10x maior por hora.
cQuery += " AND SA2.A2_ULTCOM <> ' ' "

self:cQRY := cQuery

Return

 /*/{Protheus.doc} PrepQuery
	(Método responsável por retornar a propriedade self:cFinalQuery
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method GetQry() Class TSIPARTIC 
return self:cFinalQuery

 /*/{Protheus.doc} TempTable(
	(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method TempTable() Class TSIPARTIC

    Self:cAlias    := getNextAlias( )
	TAFConOut("TSILOG00005: Query de busca do cadastro participantes (Cliente / Fornecedor) [ Início query TSILOG00005 " + TIME() + " ]" + self:GetQry(), 1, .F., "TSI" ) 
    dbUseArea( .T., "TOPCONN", TCGenQry( ,, self:GetQry( ) ), Self:cAlias, .F., .T. )
	TAFConOut("TSILOG00005: Query de busca do cadastro participantes (Cliente / Fornecedor) [ Fim query TSILOG00005 " + TIME(), 1, .F., "TSI" )
	Count to self:nTotReg
    (Self:cAlias)->(dbGoTOp())

Return

 /*/{Protheus.doc} GetJsn 
	(Método responsável retornar a propriedade self:oJObjTSI
	@author Henrique Pereira      
	@since 08/06/2020 
	@return Nil, nulo, não tem retorno.     
/*/
Method GetJsn() Class TSIPARTIC     
    Local oJObjRet  :=  JsonObject( ):New( )
	Local nTAMfone  :=  TAMSX3("C1H_FONE")[1]
    Local nTAMEmail :=  TAMSX3("C1H_EMAIL")[1]
    Local nTAMCompl :=  TAMSX3("C1H_COMPL")[1]
    Local nPos      := 0

    aFisGetEnd := FisGetEnd( ( self:cAlias )->ENDERECO )
    // Campos da Planilha Layout TAF - T003
    oJObjRet["participantId"]        := alltrim( ( self:cAlias )->COD_PART )                               // 02 COD_PART
    oJObjRet["name"]                 := alltrim( ( self:cAlias )->NOME     )                               // 03 NOME
    oJObjRet["countryCode"]          := if(Empty(alltrim( ( self:cAlias )->COD_PAIS )),"01058", alltrim( ( self:cAlias )->COD_PAIS )) // 04 COD_PAIS
    
    if alltrim( ( self:cAlias )->TP_PESSOA ) == '1'
        oJObjRet["registrationCPF"]  := alltrim( ( self:cAlias )->CGC )                                    // 06 CPF
        if alltrim( ( self:cAlias )->TABELA ) = 'SA2' .and. alltrim( ( self:cAlias )->INDRUR ) != '' .and. alltrim( ( self:cAlias )->INDRUR ) != '0' .and. Alltrim(( self:cAlias )->UF) $ "SP|MG"
            oJObjRet["registrationCNPJ"] := alltrim( ( self:cAlias )->CGC )                                // 05 CNPJ
            oJObjRet["registrationCPF"]  := alltrim( ( self:cAlias )->CPFRUR )                             // 06 CPFRUR
        endif
    elseif alltrim( ( self:cAlias )->TP_PESSOA ) == '2'
        oJObjRet["registrationCNPJ"] := alltrim( ( self:cAlias )->CGC )                                    // 05 CNPJ
    else
        if len(alltrim((self:cAlias)->CGC))>11
            oJObjRet["registrationCNPJ"] := alltrim( ( self:cAlias )->CGC )                                // 05 CNPJ
        else
            oJObjRet["registrationCPF"]  := alltrim( ( self:cAlias )->CGC )                                // 06 CPF
        endif
    endif

    oJObjRet["stateRegistration"]    := StrTran( alltrim( ( self:cAlias )->IE ), '.', '' )                 // 07 IE
    oJObjRet["codeCity"]             := alltrim( ( self:cAlias )->COD_MUN )                                // 08 COD_MUN
    oJObjRet["suframa"]              := StrTran( alltrim( ( self:cAlias )->SUFRAMA ), '.', '' )            // 09 SUFRAMA
    oJObjRet["adress"]               := alltrim( aFisGetEnd[1] )                                           // 11 END
    oJObjRet["numberAdress"]         := alltrim( IIf( !Empty( aFisGetEnd[2]), aFisGetEnd[3], "SN" ) )      // 12 NUM
    oJObjRet["complement" ]          := alltrim( SubStr( ( self:cAlias )->COMPL,1,nTAMCompl) )             // 13 COMPL
    oJObjRet["neighborhood"]         := alltrim( ( self:cAlias )->BAIRRO )                                 // 15 BAIRRO
    oJObjRet["unitFederative"]       := alltrim( ( self:cAlias )->UF     )                                 // 16 UF
    oJObjRet["cep"]                  := alltrim( ( self:cAlias )->CEP    )                                 // 17 CEP
    oJObjRet["ddd"]                  := alltrim( ( self:cAlias )->DDD    )                                 // 18 DDD FONE
    // O tratamento abaixo foi feito devido o tamanho do campo Fone não terem o mesmo tamanho na tabela SA1 e C1H.
    oJObjRet["phoneNumber"]          := alltrim( substr( ( self:cAlias )->FONE, 1,nTAMfone ) )             // 19 FONE
    oJObjRet["email"]                := alltrim( substr( ( self:cAlias )->EMAIL,1,nTAMEmail) )             // 22 EMAIL
    oJObjRet["kindOfPerson"]         := alltrim( ( self:cAlias )->TP_PESSOA )                              // 24 TP_PESSOA
    oJObjRet["activity"]             := alltrim( ( self:cAlias )->RAMO_ATV )                               // 25 RAMO_ATV
    oJObjRet["cprb"]                 := alltrim( ( self:cAlias )->INDCPRB )                                // 41 INDCPRB
    oJObjRet["paa"]                  := alltrim( ( self:cAlias )->EXECPAA )                                // 43 EXECPAA
    oJObjRet["sportsAssociationIndicator"] := alltrim( IIF( ( self:cAlias )->IND_ASSOC_DESPORT =="1","1","2" ) ) // 44 IND_ASSOC_DESPORT
    oJObjRet["ctissCode"]            := alltrim( ( self:cAlias )->CONTRIBUINTE )                           // 45 CONTRIBUINTE
    if nIndCP > 0
        oJObjRet["indcp"]            := alltrim( ( self:cAlias )->INDCP)                                   // 46 INDCP
    endif
    oJObjRet["codCountryExt"]        := alltrim( ( self:cAlias )->COD_PAIS_EXT )                           // 28 COD_PAIS_EXT
    oJObjRet["addressExt"]           := alltrim( ( self:cAlias )->LOGRAD_EXT )                             // 29 LOGRAD_EXT
    oJObjRet["numberExt"]            := alltrim( ( self:cAlias )->NR_LOGRAD_EXT )                          // 30 NR_LOGRAD_EXT
    oJObjRet["complementExt"]        := alltrim( ( self:cAlias )->COMPLEM_EXT )                            // 31 COMPLEM_EXT
    oJObjRet["district"]             := alltrim( ( self:cAlias )->BAIRRO_EXT )                             // 32 BAIRRO_EXT
    oJObjRet["city"]                 := alltrim( ( self:cAlias )->NOME_CIDADE_EXT )                        // 33 NOME_CIDADE_EXT
    oJObjRet["postalCode"]           := alltrim( ( self:cAlias )->COD_POSTAL_EXT )                         // 34 COD_POSTAL_EXT
    oJObjRet["payingSourceReport"]   := alltrim( ( self:cAlias )->REL_FONTE_PAG_RESID_EXTERIOR )           // 36 REL_FONTE_PAG_RESID_EXTERIOR
    oJObjRet["exemptimmune"]         := alltrim( ( self:cAlias )->ISENCAO_IMUNIDADE)                       // 46 ISENTO_IMUNE
    oJObjRet["state"]                := alltrim( ( self:cAlias )->ESTADO_EXT )                             // 48 ESTADO_EXT
    oJObjRet["foneExt"]              := alltrim( ( self:cAlias )->TELEFONE_EXT )                           // 49 TELEFONE_EXT
    oJObjRet["indicativeNif"]        := alltrim( ( self:cAlias )->INDICATIVO_NIF_EXT )                     // 50 INDICATIVO_NIF_EXT
    oJObjRet["nif"]                  := alltrim( ( self:cAlias )->NIF )                                    // 51 NIF
    oJObjRet["formOftaxation"]       := alltrim( ( self:cAlias )->FORMA_TRIBUTACAO )                       // 52 FORMA_TRIBUTACAO
    oJObjRet["kindOfPersonExt"]      := alltrim( ( self:cAlias )->TIPO_PESSOA_EXTERIOR)               // 53 TIPO_PESSOA_EXTERIOR

    oJObjRet["code"]                 :=( self:cAlias )->CODIGO                                          // 54 CODIGO DO FOR/CLI
    oJObjRet["store"]                :=( self:cAlias )->LOJA                                            // 55 LOJA DO FOR/CLI
    
    oJObjRet["stamp"]                := ( self:cAlias )->STAMP

    //Grava layout T003AB - Dependentes
    if (self:cAlias)->TABELA == 'SA2'
        if TcCanOpen(RetSqlName('DHT'))
            DHT->(DbSetOrder(1)) //DHT_FILIAL+DHT_FORN+DHT_LOJA+DHT_COD
            if DHT->(DbSeek(xFilial('DHT')+(self:cAlias)->(CODIGO+LOJA)) )
                oJObjRet['dependent'] := {}
                while DHT->(!eof()) .and. xFilial('DHT')+DHT->(DHT_FORN+DHT_LOJA) == xFilial('SA2')+(self:cAlias)->(CODIGO+LOJA)
                    aadd( oJObjRet['dependent'], JsonObject():New() )
                    nPos := len( oJObjRet['dependent'] )
                                                            
                    oJObjRet['dependent'][nPos]['dependentCode']           := DHT->DHT_COD
                    oJObjRet['dependent'][nPos]['document']                := DHT->DHT_CPF
                    oJObjRet['dependent'][nPos]['name']                    := alltrim(DHT->DHT_NOME)
                    oJObjRet['dependent'][nPos]['dependencyRelationship']  := DHT->DHT_RELACA
                    oJObjRet['dependent'][nPos]['descriptionDependency']   := ''
                    DHT->(DbSkip())
                enddo
            endif
        endif
    endif    

Return oJObjRet
    
 /*/{Protheus.doc} FilC1H
	(Método responsável por montar o conteúdo da filial da C1H
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method FilC1H(cSourceBr) Class TSIPARTIC        
    self:aFilC1H := TafTSIFil(cSourceBr, 'C1H')       
Return


/*/{Protheus.doc} CommitRegs
    (Método responsável por realizar a gravação dos dados)
    @author user
    @since 26/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method CommitRegs(oHash, cUStamp, aREGxV80 ) Class TSIPARTIC  
    Local nReg      := 0
    Local oJObjRet  := Nil

    Default cUStamp  := ''
    Default aREGxV80 := {}

    oJObjRet := JsonObject( ):New( )
    oJObjRet['participants'] := { }
    
    (Self:cAlias)->(dbGoTop())
    while (Self:cAlias)->(!EOF())
        nReg ++
        
        aadd(oJObjRet['participants'], Self:GetJsn())
        
        //Verifico se atingiu o limite de registros por array ou se o registro processado é igual ao ultimo da temp table
        if nReg == self:nSizeMax .or. (Self:cAlias)->(RECNO()) == Self:nTotReg

            TAFConOut("TSILOG00024 Participantes (Cliente / Fornecedor) "+cValtoChar((Self:cAlias)->(RECNO()))+" de "+cValToChar(Self:nTotReg))

            WsTSIProc( oJObjRet, .T., HashPARTIC(), @cUStamp, aREGxV80 )

            ASIZE(oJObjRet['participants'],0)

            nReg := 0
        endif

        (Self:cAlias)->(dbSkip())
    enddo

    FreeObj(oJObjRet)

Return
