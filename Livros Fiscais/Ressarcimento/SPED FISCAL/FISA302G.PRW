#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA302G

Gera��o de Arquivo para Solicita��o de Abatimento, Creditamento / Ressarcimento de ST - MG

@return	Nil

@author Jose Ricardo Bernardo
@since 04/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISA302G()
Local cAnoMes   := ''       // Per�odo de Apura��o
Local cCodEnq   := ''       // Codigo de Enquadramento
Local cTipGer   := ''       // Tipo de Gera��o
Local cDiretorio:= ''       // Diretorio de grava��o do arquivo
Local cArquivo  := ''       // Arquivo Gerado
Local cTitulo   := 'Apura��o Ressarcimento SPED'
Local nCodFin   := 0        // Codigo da Finalidade

Local lOk		:= .F.
Local lCancel	:= .F.

Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Local aWizard   := {}
Local cNomWiz	:=	"FISA302G"

Private lAutomato := Iif(IsBlind(),.T.,.F.)       

If !lVerpesssen .Or. !(F302GWiz(cNomWiz))
	Return
EndIf

If !xMagLeWiz(cNomWiz,@aWizard,.T.)
	Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
EndIf

cAnoMes     := aWizard[1][1]
nCodFin     := left(aWizard[1][2],1)
cCodEnq     := aWizard[1][3]
cTipGer     := left(aWizard[1][4],1)

cDiretorio  := Alltrim( aWizard[1][5] )
cArquivo    := Alltrim( aWizard[1][6] )

If  Empty( cCodEnq )
    Alert( "Codigo de Enquadramento obrigat�rio!")
    Return
Endif

If  !ExistDir( cDiretorio )
    Alert( "Diret�rio para grava��o do arquivo inexistente!")
    Return
Endif

If  Empty( cArquivo )
    Alert( "Arquivo para grava��o n�o informado!")
    Return 
Else
    cArquivo := cDiretorio + iif( substr(cDiretorio,len(cDiretorio),1) <> '\','\','') + iif( lower(right(cArquivo,4)) $ '.txt|.csv',cArquivo, cArquivo + '.txt')
Endif

oProcess:= FISProgress():New({||Arquivos_MG(oProcess,cAnoMes, nCodFin, cCodEnq, cTipGer, cArquivo, cTitulo, @lOk, @lCancel)},"Gera��o de Arquivo ",.T.)
oProcess:Activate()

If  lCancel
    Alert("Opera��o Cancelada pelo usu�rio", cTitulo)
EndIf

Return    


//-------------------------------------------------------------------
/*/{Protheus.doc} Arquivos_MG

Gera��o de Arquivo para Apura��o de estoque, restitui��es e complementa��es 
exigidos pela Secretaria de Estado da Fazenda de Minas Gerais

@return Nil

@author Jose Ricardo Bernardo
@since 05/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Arquivos_MG(oProcess,cAnoMes,nCodFin,cCodEnq,cTipGer,cArquivo,cTitulo, lOk, lCancel)

Local cQuery    := GetNextAlias()

Local cSelect	:= ""
Local cFrom     := ""
Local cWhere    := ""
Local cGroupBy  := ""
Local cOrder    := ""

Local cCabec    := ''
Local cLinha    := ''

Local cCodSped  := ''
Local cCodNCM   := ''
Local cCodEAN13 := ''
Local cDescProd := ''
Local cUnMed    := ''
Local cQtdPrdFGP:= ''

Local cVlrIcmOpc:= ''
Local cVlrIcmStr:= ''
Local cVlrFemRst:= ''

Local cQtdStRest:= '' //Finalidade 5
Local cQtdStCmpl:= '' //Finalidade 5
Local cVlrStRest:= '' //Finalidade 5
Local cVlrStCmpl:= '' //Finalidade 5
Local cVlrFemCmp:= '' //Finalidade 5

Local nRegistros:= 0
Local oArquivo

If nCodFin == "4"

    cCabec  :=  "CD_SPED|CD_NCM|CD_EAN13|DS_PRODMERC|TP_UNIDADE|QT_PROD_FGP|VR_ICMS_FGP_OPC|VR_ICMS_FGP_STR|VR_FEM_FGP_REST"

    cSelect :=  " CII.CII_FILIAL, CII.CII_PERIOD, CII.CII_IDAPUR, CII.CII_PRODUT, SB1.B1_POSIPI, SB1.B1_CODBAR, SB1.B1_DESC, CII.CII_UNID, "
                
    If  cTipGer == "1"   // Consolidado
        cSelect  += " SUM(CII.CII_QTDMOV) AS CII_QTDMOV, SUM(CII.CII_VCREDI) AS CII_VCREDI, SUM(CII.CII_VRESSA) AS CII_VRESSA, SUM(CII_VREFCP) AS CII_VREFCP "
        cGroupBy := " GROUP BY CII.CII_FILIAL, CII.CII_PERIOD, CII.CII_IDAPUR, CII.CII_PRODUT, SB1.B1_POSIPI, SB1.B1_CODBAR, SB1.B1_DESC, CII.CII_UNID "
    Else                // Analitico
        cSelect  += "CII.CII_QTDMOV, CII_VCREDI, CII_VRESSA, CII_VREFCP"
    Endif

    cFrom   :=  RetSqlName("CII") + " CII INNER JOIN " + RetSqlName("SB1") + " SB1  ON B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD    = CII.CII_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
    
    cWhere  :=  " CII.CII_FILIAL = '" + xFilial("CII") + "' AND " +;
                " CII.CII_PERIOD = '" + cAnoMes + "' AND " +;
                " CII.CII_ENQLEG = '" + cCodEnq + "' AND " +;
                " CII.D_E_L_E_T_ = ' ' "

    cOrder  :=  " CII.CII_FILIAL, CII.CII_PERIOD, SB1.B1_POSIPI, CII.CII_PRODUT "

    cSelect := "%" + cSelect  + "%"
    cFrom   := "%" + cFrom    + "%"
    cWhere  := "%" + cWhere + cGroupBy + "%"
    cOrder	:= '%' + cOrder   + '%'
    
    BeginSql Alias cQuery
            
        SELECT %Exp:cSelect%
        FROM   %Exp:cFrom% 
        WHERE  %Exp:cWhere%
        ORDER BY %Exp:cOrder%

    EndSQL

    COUNT TO nRegistros    
    (cQuery)->(dbGoTop())

    If !(cQuery)->(Eof())

        oArquivo:= FWFILEWRITER():New(cArquivo)
        If  oArquivo:Exists()
            oArquivo:Erase()
        Endif

        If  oArquivo:Create()

            GrvLinha(oArquivo, cCabec)

            oProcess:Set1Progress(1)
            oProcess:Inc1Progress("Obtendo informa��es")

            oProcess:Set2Progress(nRegistros)            
            
            While !(cQuery)->(Eof())

                oProcess:Inc2Progress("Gerando arquivo")

                cCodSped    := (cQuery)->CII_PRODUT
                cCodNCM     := (cQuery)->B1_POSIPI
                cCodEAN13   := (cQuery)->B1_CODBAR
                cDescProd   := (cQuery)->B1_DESC
                cUnMed      := (cQuery)->CII_UNID
                cQtdPrdFGP  := Transform( (cQuery)->CII_QTDMOV, "@E 999999999.9999" )

                cVlrIcmOpc  := Transform( (cQuery)->CII_VCREDI, "@E 999999999.99" )
                cVlrIcmStr  := Transform( (cQuery)->CII_VRESSA, "@E 999999999.99" )
                cVlrFemRst  := Transform( (cQuery)->CII_VREFCP, "@E 999999999.99" )

                cLinha :=  Alltrim(cCodSped) + "|" + Alltrim(cCodNCM) + "|" + Alltrim(cCodEAN13) + "|" + Alltrim(cDescProd) + "|" + cUnMed + "|" + Alltrim( cQtdPrdFGP ) + "|" + Alltrim(cVlrIcmOpc) + "|" + Alltrim(cVlrIcmStr) + "|" + alltrim(cVlrFemRst) + "|"        
            
                GrvLinha(oArquivo, cLinha)	

                (cQuery)->(dbSkip())

            Enddo
        
            oArquivo:Close()

            If oArquivo:Exists()
                lOk := .T.
                oProcess:Inc2Progress("Arquivo gerado com sucesso! Clique em Finalizar.")
            Endif

        Else
            MsgInfo(oArquivo:Error():Message)
        Endif

        FreeObj( oArquivo )

    Endif

    (cQuery)->(dbCloseArea())
Else

     cCabec  :=  "CD_SPED|CD_NCM|CD_EAN13|DS_PRODMERC|TP_UNIDADE|QT_PROD_ST_COMP|VR_ICMS_ST_COMP|VR_FEM_ST_COMP|QT_PROD_ST_REST|VR_ICMS_ST_REST|VR_FEM_ST_REST"

     cSelect :=  " CII.CII_FILIAL, CII.CII_PERIOD, CII.CII_IDAPUR, CII.CII_PRODUT, SB1.B1_POSIPI, SB1.B1_CODBAR, SB1.B1_DESC, CII.CII_UNID, "
                
    If  cTipGer == "1"   // Consolidado
        cSelect  += " SUM(CII.CII_QTDMOV) AS CII_QTDMOV, SUM(CII.CII_VRESSA) AS CII_VRESSA, SUM(CII_VREFCP) AS CII_VREFCP, SUM(CII_VCMPL) AS CII_VCMPL, SUM(CII_VCMFCP) AS CII_VCMFCP "
        cGroupBy := " GROUP BY CII.CII_FILIAL, CII.CII_PERIOD, CII.CII_IDAPUR, CII.CII_PRODUT, SB1.B1_POSIPI, SB1.B1_CODBAR, SB1.B1_DESC, CII.CII_UNID "
    Else                // Analitico
        cSelect  += "CII.CII_QTDMOV, CII_VRESSA, CII_VREFCP , CII_VCMPL , CII_VCMFCP"
    Endif

    cFrom   :=  RetSqlName("CII") + " CII INNER JOIN " + RetSqlName("SB1") + " SB1  ON B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD    = CII.CII_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
    
    cWhere  :=  " CII.CII_FILIAL = '" + xFilial("CII") + "' AND " +;
                " CII.CII_PERIOD = '" + cAnoMes + "' AND " +;
                " CII.CII_ENQLEG = '" + cCodEnq + "' AND " +;
                " CII.D_E_L_E_T_ = ' ' "

    cOrder  :=  " CII.CII_FILIAL, CII.CII_PERIOD, SB1.B1_POSIPI, CII.CII_PRODUT "

    cSelect := "%" + cSelect  + "%"
    cFrom   := "%" + cFrom    + "%"
    cWhere  := "%" + cWhere + cGroupBy + "%"
    cOrder	:= '%' + cOrder   + '%'

    BeginSql Alias cQuery
            
        SELECT %Exp:cSelect%
        FROM   %Exp:cFrom% 
        WHERE  %Exp:cWhere%
        ORDER BY %Exp:cOrder%

    EndSQL

    COUNT TO nRegistros
    (cQuery)->(dbGoTop())

    If !(cQuery)->(Eof())

        oArquivo:= FWFILEWRITER():New(cArquivo)
        If  oArquivo:Exists()
            oArquivo:Erase()
        Endif

        If  oArquivo:Create()

            GrvLinha(oArquivo, cCabec)

            //oProcess:Set1Progress(1)
            //oProcess:Inc1Progress("Obtendo informa��es")

            //oProcess:Set2Progress(nRegistros)
            
            While !(cQuery)->(Eof())

                oProcess:Inc1Progress("Gerando arquivo")

                cCodSped    := (cQuery)->CII_PRODUT
                cCodNCM     := (cQuery)->B1_POSIPI
                cCodEAN13   := (cQuery)->B1_CODBAR
                cDescProd   := (cQuery)->B1_DESC
                cUnMed      := (cQuery)->CII_UNID
                cQtdStCmpl  := Iif( (cQuery)->CII_VCMPL  > 0 , Transform( (cQuery)->CII_QTDMOV, "@E 999999999.9999" ), "0,0000")
                cVlrStCmpl  := Transform( (cQuery)->CII_VCMPL,  "@E 999999999.99" )
                cVlrFemCmp  := Transform( (cQuery)->CII_VCMFCP, "@E 999999999.99" )
                cQtdStRest  := Iif( (cQuery)->CII_VRESSA > 0 , Transform( (cQuery)->CII_QTDMOV, "@E 999999999.9999" ), "0,0000")                
                cVlrStRest  := Transform( (cQuery)->CII_VRESSA, "@E 999999999.99" )
                cVlrFemRst  := Transform( (cQuery)->CII_VREFCP, "@E 999999999.99" )
                
                cLinha :=  Alltrim(cCodSped) + "|" + Alltrim(cCodNCM) + "|" + Alltrim(cCodEAN13) + "|" + Alltrim(cDescProd) + "|" + cUnMed + "|" + Alltrim(cQtdStCmpl) + "|" + Alltrim(cVlrStCmpl) + "|" + Alltrim(cVlrFemCmp) + "|" + Alltrim(cQtdStRest) + "|" + Alltrim(cVlrStRest) + "|" + Alltrim(cVlrFemRst) + "|"  
            
                GrvLinha(oArquivo, cLinha)	

                (cQuery)->(dbSkip())

            Enddo
        
            oArquivo:Close()

            If oArquivo:Exists()
                lOk := .T.
            Endif

        Else
            MsgInfo(oArquivo:Error():Message)
        Endif

        FreeObj( oArquivo )

    Endif

    (cQuery)->(dbCloseArea())


Endif

If  lOk
	MsgInfo( "Arquivo " + cArquivo + " gerado com Sucesso", cTitulo)
Else
  	MsgInfo( "Arquivo " + cArquivo + " n�o foi gerado. Verifique par�metros!", cTitulo)
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvLinha

Grava��o de Linha

@return Nil

@author Jose Ricardo Bernardo
@since 05/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GrvLinha(oArquivo, cLinha)	
Local cConteudo := Alltrim( cLinha) + Chr(13)+Chr(10)

oArquivo:Write( cConteudo )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} F302GWiz

Montagem do Wizard de parametros para gera��o do arquivo

@return .T. se finalizado com sucesso ou .F. se cancelado

@author Jose Ricardo Bernardo
@since 09/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F302GWiz(cNomWiz)
Local aTxtApre := {}
Local aPaineis := {}
Local aItens1  := {}
Local cTitObj1 := ""
Local cTitObj2 := ""
Local lRet     := .T.

/* Painel de apresenta��o   */
aAdd (aTxtApre, "Restitui��o ST MG")
aAdd (aTxtApre, "")
aAdd (aTxtApre, "Preencha corretamente as informa��es solicitadas.")
aAdd (aTxtApre, "Informa��es necess�rias para a gera��o do meio-magn�tico correspondente a Apura��o de Estoque, restitui��es e complementa��es, exigidos pela Secretaria de Estado da Fazenda de Minas Gerais")

/* Painel de parametros     */
aAdd (aPaineis, {})
nPos := Len (aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informa��es solicitadas.")
aAdd (aPaineis[nPos], "Par�metros para Gera��o")
aAdd (aPaineis[nPos], {})

// Linha correspondente ao per�odo de apura��o do ressarcimento
cTitObj1 := "Ano/M�s de Apura��o (AAAA/MM)"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

cTitObj1 := Replicate ("X", 6)
aAdd (aPaineis[nPos][3], {2,,"@R 9999/99",1,,,,6})

aAdd (aPaineis[nPos][3], {0,"",,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})

// Linha correspondente a Finalidade do Arquivo
cTitObj1 := "C�digo da Finalidade do Arquivo"					
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

aItens1 := {}
//OBS.: As op��es que seriam adicionadas a aItens (abaixo) foram comentadas pois se trata de implementa��o futura.
//aAdd (aItens1, "1-Pagamento - Estoque ST")                // "Finalidade 1 - Pagamento - Estoque ST"
//aAdd (aItens1, "2-Restitui��o - Estoque ST")              // "Finalidade 2 - Restitui��o - Estoque ST"
//aAdd (aItens1, "3-Cr�dito Presumido - Estorno")           // "Finalidade 3 - Cr�dito Presumido - Estorno"
aAdd (aItens1, "4-Restitui��o ST")                          // "Finalidade 4 - Restitui��o ST"
aAdd (aItens1, "5-Complementa��o e/ou Restitui��o ST")      // "Finalidade 5 - Complementa��o e/ou Restitui��o ST"    
aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})

aAdd (aPaineis[nPos][3], {0,"",,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})

// Linha correspondente ao Codigo de Enquadramento selecionado com F3
cTitObj1 := "Codigo de enquadramento"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

cTitObj1 := Replicate ("X", 5)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,5,,,"CIF"})

aAdd (aPaineis[nPos][3], {0,"",,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})


// Forma de gera��o do arquivo
cTitObj1 := "Gerar Arquivo "
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})

aItens2 := {}
aAdd (aItens2, "1 - Consolidado")
aAdd (aItens2, "2 - Analitico"  )
aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})

aAdd (aPaineis[nPos][3], {0,"",,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})


// Linha correspondente ao Diretorio e Arquivo de Destino
cTitObj1 := "Diret�rio do Arquivo Destino";						cTitObj2 := "Nome do Arquivo Destino"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

cTitObj1 := Replicate ("X", 50);								cTitObj2 := Replicate ("X", 50)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50,,,,})

aAdd (aPaineis[nPos][3], {0,"",,,,,,});						    aAdd (aPaineis[nPos][3], {0,"",,,,,,})

lRet := xMagWizard (aTxtApre, aPaineis, cNomWiz)

Return (lRet)
