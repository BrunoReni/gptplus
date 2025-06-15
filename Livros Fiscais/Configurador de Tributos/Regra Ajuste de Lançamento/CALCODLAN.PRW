#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} RetCodAp

Cria um JSON com todos os códigos de lançamentos cadastrados na tabela CJA filtrado por periodo mais filial.

@author Adilson Roberto
@since 04/02/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function RetCodAp(dData, lBdjaSon, oJCodRef, __aPrepared,aNfItem,aNfCab)

Local aInsert      := {}
Local aRegCal      := {}
Local aTribgen     := {}
Local cAliascJA    := GetNextAlias()
Local cFrom        := ""
Local cMD5         := ""
local cOrderby     := ""
Local cQuery       := ""
Local cRegCal      := ""
Local cSelect      := ""
Local cWhere       := ""
Local nLen         := 0
Local nPosPrepared := 0
Local nX           := 0
Local nII          := 0
Local nIF          := Len(aNfItem)

If lBdjaSon

    For nII := 1 to nIF        
        For nX := 1 to Len(aNfItem[nII][IT_TRIBGEN])
            Aadd(aTribgen,aNfItem[nII][IT_TRIBGEN][nX][1])
        Next
    Next
    cSelect := "SELECT CJA.CJA_FILIAL, CJA.CJA_ID, CJA.CJA_CODREG, CJA.CJA_REGCAL, CJA.CJA_CODLAN, CJA.CJA_NFBASE, CJA.CJA_NFALIQ, CJA.CJA_VALOR, CJA.CJA_VLOUTR, "
    cSelect += "CJA.CJA_CODTAB, CJA.CJA_CODCPL, CJA.CJA_CODMSG, CJA.CJA_TXTDSC, CJA.CJA_GERMSG, CDY.CDY_DESCR, CJA.CJA_CNTRL, CJA.CJA_OPER "

    cFrom   := "FROM " + RetSqlName("CJ9") + " CJ9 "
    cFrom   += "INNER JOIN " + RetSqlName("CJA") + " CJA ON(CJA.CJA_FILIAL = ? AND CJA.CJA_ID_CAB = CJ9.CJ9_ID AND CJA.CJA_VIGINI <= ? AND (CJA.CJA_VIGFIM >= ? OR CJA.CJA_VIGFIM = '' ) AND CJA.D_E_L_E_T_ = ' ' ) "
            aadd(aInsert, {'C',xFilial("CJA")})
            aadd(aInsert, {'D',dData})
            aadd(aInsert, {'D',dData})
    cFrom   += "LEFT JOIN " + RetSqlName("CDY") + " CDY ON(CDY.CDY_FILIAL = ? AND CDY.CDY_CODAJU = CJA.CJA_CODLAN AND CDY.D_E_L_E_T_ = ' ' ) "
            aadd(aInsert, {'C',xFilial("CDY")})
    cWhere  := "WHERE CJ9.CJ9_FILIAL= ? AND "
            aadd(aInsert, {'C',xFilial("CJ9")})
    cWhere  += "CJ9.CJ9_VIGINI <= ? AND "
            aadd(aInsert, {'D',dData})
    cWhere  += "(CJ9.CJ9_VIGFIM >= ? OR CJ9.CJ9_VIGFIM = ' ' ) AND "
            aadd(aInsert, {'D',dData})
    cWhere  += "CJA.CJA_REGCAL IN (?) AND "
            aadd(aInsert, {'A',aTribgen})
    cWhere  += "CJ9.D_E_L_E_T_ = ' ' "

    cOrderby   := "ORDER BY CJA.CJA_REGCAL"

    cQuery := cSelect +  cFrom +  cWhere + cOrderby

    nLen := Len(aInsert)
    cMD5 := MD5(cQuery)
    If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
        Aadd(__aPrepared,{FWPreparedStatement():New(),cMD5})
        nPosPrepared := Len(__aPrepared)
        __aPrepared[nPosPrepared][1]:SetQuery(ChangeQuery(cQuery))
    EndIf 

 	For nX := 1 to nLen
		IF aInsert[nX][1] =='C'
			__aPrepared[nPosPrepared][1]:SetString(nX,aInsert[nX][2])
		Elseif aInsert[nX][1] =='A'
			__aPrepared[nPosPrepared][1]:setIn(nX,aInsert[nX][2])
        Elseif aInsert[nX][1] =='D'
			__aPrepared[nPosPrepared][1]:setDate(nX,aInsert[nX][2])  
		Endif
	Next 

    cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliascJA)
  
    oJCodRef := JsonObject():New()
    

    (cAliascJA)->(DBGoTop())
    Do While (cAliascJA)->(!EOF())
        If !cRegCal == (cAliascJA)->CJA_REGCAL
            aRegCal := {}
            cRegCal := (cAliascJA)->CJA_REGCAL
            
            Aadd(aRegCal,{cRegCal,;     //1
            (cAliascJA)->CJA_CODLAN,;   //2
            (cAliascJA)->CJA_NFBASE,;   //3
            (cAliascJA)->CJA_NFALIQ,;   //4
            (cAliascJA)->CJA_VALOR, ;   //5
            (cAliascJA)->CJA_VLOUTR,;   //6
            (cAliascJA)->CJA_CODTAB,;   //7
            (cAliascJA)->CJA_CODMSG,;   //8
            (cAliascJA)->CJA_CODCPL,;   //9
            (cAliascJA)->CJA_TXTDSC,;   //10
            (cAliascJA)->CJA_GERMSG,;   //11
            (cAliascJA)->CDY_DESCR, ;   //12
            (cAliascJA)->CJA_CNTRL, ;   //13
            (cAliascJA)->CJA_OPER})     //14

            oJCodRef[cRegCal] := aRegCal
                 
        Else
            Aadd(aRegCal,{cRegCal,;    //1   
            (cAliascJA)->CJA_CODLAN,;  //2
            (cAliascJA)->CJA_NFBASE,;  //3
            (cAliascJA)->CJA_NFALIQ,;  //4 
            (cAliascJA)->CJA_VALOR,;   //5 
            (cAliascJA)->CJA_VLOUTR,;  //6 
            (cAliascJA)->CJA_CODTAB,;  //7                
            (cAliascJA)->CJA_CODMSG,;  //8 
            (cAliascJA)->CJA_CODCPL,;  //9 
            (cAliascJA)->CJA_TXTDSC,;  //10 
            (cAliascJA)->CJA_GERMSG,;  //11
            (cAliascJA)->CDY_DESCR, ;  //12
            (cAliascJA)->CJA_CNTRL, ;  //13
            (cAliascJA)->CJA_OPER})    //14

            oJCodRef[cRegCal] := aRegCal     
        Endif    
        (cAliascJA)->(DbSkip())
    Enddo

    dbSelectArea(cAliascJA)
    (cAliascJA)->(dbCloseArea())
    //FwFreeArray(aRegCal)
    //FwFreeArray(aInsert)
    asize(aInsert,0)
Endif



Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} BusCodLan

Atualiza array aGrava com todos os lançamentos calculados pelo configurador

@author Adilson Roberto
@since 04/02/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Function BusCodLan(aGrava,nZ,aNfItem,aNfCab, lBdjaSon, oJCodRef)

Local aCodLan   := {}
Local nBasCal   := 0
Local nAlqCal   := 0
Local nValor    := 0
Local nValOut   := 0 
Local nI		:= 0
Local nX        := 0
Local nB        := 0
Local cItem     := aNfItem[nZ,IT_ITEM]
Local aTribgen	:= aNfItem[nZ][IT_TRIBGEN]
Local cTpLanc   := ""
Local cSeq      := "001"
Local cCodRefl  := ""
Local cCodLan   := ""
Local cGeraGNRE := ""
Local cCmp0460  := ""
Local cCMPOrig  := ""
Local cCodDes   := ""
Local cIFCOMP   := ""
Local cLivro    := ""
Local cCFOP     := ""
Local cDescod   := ""
Local cCodObs   := ""
Local cCodOLan  := ""
Local cGeracum  := ""
Local cRegCalc  := ""
Local cCodVal   := ""
Local cCodValOu := ""
Local cOpBase   := ""
Local cOpAliq   := ""
local cEstOri   := aNfCab[NF_UFORIGEM]
Local cEstDest  := aNfCab[NF_UFDEST]
Local cTipoMov  := aNfCab[NF_OPERNF]
Local cDevol    := aNFCab[NF_TIPONF]  
Local lCTOper   := .F.
Local lCtUF     := .F.

//aCodLan[nI][14] =  CJA_OPER  '01=Entrada;02=Saída;03=Devolução;'
//aCodLan[nI][13] =  CJA_CNTRL '01=UF Origem;02=UF Destino;'

IF lBdjaSon .and. Valtype(oJCodRef) =='J'
    If Len(aTribgen) > 0
        For nX := 1 To Len(aTribgen)
            cChave := aTribgen[nX][1]
            aCodLan :=	oJCodRef[cChave]
            If Valtype(aCodLan) =='A' .And. Len(aCodLan) > 0
                For nI := 1 To Len(aCodLan)  
                    cCodLan     := Alltrim(aCodLan[nI][2])   //CJA_CODLAN

                    // Controle da Operação
                    If !Empty(aCodLan[nI][14])
                        If (aCodLan[nI][14] == "01" .And. cTipoMov == "E" .And. cDevol <> "D") .Or.;
                        (aCodLan[nI][14] == "02" .And. cTipoMov == "S" .And. cDevol <> "D" ) .Or.;
                            aCodLan[nI][14] == "03" .And. cDevol == "D"
                            lCTOper := .T.
                        Else
                            lCTOper := .F.            
                        Endif      
                    Else
                        lCTOper := .T.
                    EndIf    

                    //Controle de UF
                    If !Alltrim(aCodLan[nI][7]) == "04" 
                        If !Empty(aCodLan[nI][13])
                            If aCodLan[nI][13] == "01" .And. cEstOri == Left(cCodLan,2)
                                lCtUF := .T.
                            ElseIf aCodLan[nI][13] == "02" .And. cEstDest == Left(cCodLan,2)
                                lCtUF := .T.
                            Else
                                lCtUF := .F.    
                            EndIf
                        Else
                            lCtUF := .T.
                        Endif 
                    Else
                        lCtUF := .T.
                    Endif
                    
                    //Geração dos dados para o aGrava, este array irá alimentar as tabelas CDA e CDV 
                    If lCTOper .And. lCtUF
                        nBasCal     := aTribgen[nX][TG_IT_BASE]        //CJA_NFBASE  
                        nAlqCal     := aTribgen[nX][TG_IT_ALIQUOTA]    //CJA_NFALIQ 
                        cTpLanc     := Iif(Alltrim(aCodLan[nI][7]) == "03","2","1") 
                        cRegCalc    := aCodLan[nI][1]   //cRegCal
                        //cGeraGNRE   := aCodLan[nI][7]   //CJA_GRGUIA 
                        cCodVal     := Left(aCodLan[nI][5],3)   //CJA_VALOR
                        cCodValOu   := Left(aCodLan[nI][6],3)   //CJA_VLOUTR
                        nValor      := 0
                        nValOut     := 0
                        cOpBase     := aCodLan[nI][3]
                        cOpAliq     := aCodLan[nI][4]
                        //vALOR
                        If cCodVal == "BAS"
                            nValor := aTribgen[nX][TG_IT_BASE]
                        ElseIf cCodVal == "ALQ"
                            nValor := aTribgen[nX][TG_IT_ALIQUOTA]
                        ElseIf cCodVal == "VAL"
                            nValor := aTribgen[nX][TG_IT_VALOR]
                        ElseIf cCodVal == "ISE"
                            nValor := aTribgen[nX][TG_IT_LF][TG_LF_ISENTO]
                        ElseIf cCodVal == "OUT"
                            nValor := aTribgen[nX][TG_IT_LF][TG_LF_OUTROS]
                        ElseIf cCodVal == "DIF"
                            nValor := aTribgen[nX][TG_IT_LF][TG_LF_DIFERIDO]
                        Endif
                        //vALOR OUTROS
                        If cCodValOu == "BAS"
                            nValOut := aTribgen[nX][TG_IT_BASE]
                        ElseIf cCodValOu == "ALQ"
                            nValOut := aTribgen[nX][TG_IT_ALIQUOTA]
                        ElseIf cCodValOu == "VAL"
                            nValOut := aTribgen[nX][TG_IT_VALOR]
                        ElseIf cCodValOu == "ISE"
                            nValOut := aTribgen[nX][TG_IT_LF][TG_LF_ISENTO]
                        ElseIf cCodValOu == "OUT"
                            nValOut := aTribgen[nX][TG_IT_LF][TG_LF_OUTROS]
                        ElseIf cCodValOu == "DIF"
                            nValOut := aTribgen[nX][TG_IT_LF][TG_LF_DIFERIDO]
                        Endif

                        cCFOP       := aNfItem[nZ][IT_CF] 
                        cDescod     := aCodLan[nI][12]
                        cLivro      := aNFItem[nZ][IT_TS][TS_NRLIVRO]
                        cCodDes     := aCodLan[nI][10]   //CJA_TXTDSC               
                        cCodObs     := aCodLan[nI][09]   //CJA_CODCPL
                        cCodOLan    := aCodLan[nI][08]   //CJA_CODMSG
                        cGeracum    := aCodLan[nI][11]   //CJA_GERMSG
                        cIFCOMP     := "CONFIG"
                        
                        If Alltrim(aCodLan[nI][7]) == "01"
                            cCMPOrig    := "2"
                        ElseIf Alltrim(aCodLan[nI][7]) == "02"
                            cCMPOrig    := "4"
                        ElseIf Alltrim(aCodLan[nI][7]) == "04"
                            cCMPOrig    := "3"
                        Else 
                            cCMPOrig    := "1"
                        EndIf
                                                
                            aAdd(aGrava, {;
                            cItem,;     //1 - Item
                            cCodLan,;   //2 - Codigo de Lancamento
                            "1",;       //3 - Sistema
                            nBasCal,;   //4 - Base de Calculo
                            nAlqCal,;   //5 - Aliquota
                            nValor,;    //6 - Valor Calculado
                            cSeq,;      //7 - Sequencia
                            cIFCOMP,;   //8 - Informacoes Complementares
                            cTpLanc,;   //9 - Tipo de Utilidade do Lancamento
                            "",;        //10- Gravação do valor em ICMS ou OUTROS
                            cCmp0460,;  //11-Complemento para Registro 0460
                            cCodRefl,;  //12-Codigo Reflexo
                            cGeraGNRE,; //13 - Gera GNRE
                            cCMPOrig,;  //14 - Campo origem CC7
                            cCFOP,;     //15 - CFOP
                            cLivro,;    //16 - lIVRO
                            cDescod,;   //17 - Descrição DO CÓDIGO
                            cCodDes,;   //18 - Descrição Mensagem bloco 0460
                            cCodObs,;   //19 - Descrição Mensagem Bloco X195
                            cCodOLan,;  //20 - Descrição Mensagem Bloco X197
                            nValOut,;   //21
                            cRegCalc,;  //22
                            cOpBase,;   //23
                            cOpAliq,;   //24
                            cGerAcum }) //25 

                            cSeq := Soma1(cSeq)
                        Endif    
                Next nI                   
            Endif            
        Next nX    
    Endif        
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecCja

Função responsável por validar campos das tabelas CJA, CJ9 e novos campos das tabelas CDA e CDV, para serem utilizados nas novas funções
da regra de lançamento do configurador

@author Adilson Roberto.
@since 22/02/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function ExecCja(aPos)
Local lExec := .F.

Default aPos := {}

If  aPos[FP_CDA_REGCAL] .And.;
    aPos[FP_CDA_VLOUTR] .And.;
    aPos[FP_CDA_CODMSG] .And.;
    aPos[FP_CDA_CODCPL] .And.;
    aPos[FP_CDA_TXTDSC] .And.;
    aPos[FP_CDA_OPBASE] .And.;
    aPos[FP_CDA_OPALIQ] .And.;
    aPos[FP_CDV_REGCAL] .And.;
    aPos[FP_CDV_VLOUTR] .And.;
    aPos[FP_CDV_CODMSG] .And.;
    aPos[FP_CDV_CODCPL] .And.;
    aPos[FP_CDV_TXTDSC] .And.;
    aPos[FP_CDV_OPBASE] .And.;
    aPos[FP_CDV_OPALIQ] .And.;
    aPos[FP_CJA_FILIAL] .And.;
    aPos[FP_CJA_ID] .And.;
    aPos[FP_CJA_CODREG] .And.;
    aPos[FP_CJA_ID_CAB] .And.;
    aPos[FP_CJA_REGCAL] .And.;
    aPos[FP_CJA_CODTAB] .And.;
    aPos[FP_CJA_CODTAB] .And.;
    aPos[FP_CJA_CODLAN] .And.;
    aPos[FP_CJA_VIGINI] .And.;
    aPos[FP_CJA_VIGFIM] .And.;
    aPos[FP_CJA_NFBASE] .And.;
    aPos[FP_CJA_NFALIQ] .And.;
    aPos[FP_CJA_VALOR] .And.;
    aPos[FP_CJA_VLOUTR] .And.;
    aPos[FP_CJA_CODCPL] .And.;
    aPos[FP_CJA_CODMSG] .And.;
    aPos[FP_CJA_TXTDSC] .And.;
    aPos[FP_CJA_GERMSG] .And.;
    aPos[FP_CJ9_FILIAL] .And.;
    aPos[FP_CJ9_ID] .And.;
    aPos[FP_CJ9_CODREG] .And.;
    aPos[FP_CJ9_DESCR ] .And.;
    aPos[FP_CJ9_VIGINI] .And.;
    aPos[FP_CJ9_VIGFIM] .And.;
    aPos[FP_CJA_GUIA]  .And.;
    aPos[FP_CJA_TITULO] .And.;
    aPos[FP_CJA_TITGUI] .And.;
    aPos[FP_CDA_AGRLAN] .And.;
    aPos[FP_CDV_AGRLAN]

    lExec := .T.
Endif

Return lExec
