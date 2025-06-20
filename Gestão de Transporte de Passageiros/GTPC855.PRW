#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "SPEDNFE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "BRWCTEOS.CH"

/*/{Protheus.doc} G001CCe   
    Carta de corre��o de CTEOS
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 02/10/2017
    @version version
   
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPC855EXP()

Local aAreaGZH := GZH->(GetArea())
local cPath := ""
local lPos     := iif(!IsBlind(),FwAlertYesNo("Deseja exportar apenas o registro posicionado?","Aten��o!!"), .F.)
Local cAliasTmp	:= ''
Local cFiltro	:= ''
Local cMsgRet	:= ''

if !IsBlind()
	cPath := cGetFile( "*.xml", "Arquivo XML", 1, "", .F., nOr(GETF_LOCALHARD,GETF_RETDIRECTORY), .F. , .T. )
EndIf

If lPos

	If( GZH->GZH_STATUS $ '3-5' .and. !empty(GZH->GZH_XMLCTE) )
		GZHExport_(cPath,lPos,@cMsgRet)
	Else
		FwAlertHelp("CCE","Apenas CTEOS Autorizado podem ser Exportados.") 
	Endif

Else
	If PERGUNTE('GTPT001',.T.)

		If !Empty(MV_PAR01) .OR. !Empty(MV_PAR03)
			cFiltro += "AND GZH.GZH_CLIENT BETWEEN '"+MV_PAR01+"' AND '" + MV_PAR03 + "' "
		EndIf

		If !Empty(MV_PAR02) .OR. !Empty(MV_PAR04)
			cFiltro += "AND GZH.GZH_LOJA BETWEEN '"+MV_PAR02+"' AND '" + MV_PAR04 + "' "
		EndIf

		If !Empty(MV_PAR05) .OR. !Empty(MV_PAR06)
			cFiltro += "AND GZH.GZH_SERIE BETWEEN '"+MV_PAR05+"' AND '" + MV_PAR06 + "' "
		EndIf

		If !Empty(MV_PAR07) .OR. !Empty(MV_PAR08)
			cFiltro += "AND GZH.GZH_NOTA BETWEEN '"+MV_PAR07+"' AND '" + MV_PAR08 + "' "
		EndIf	

		cFiltro:="%"+cFiltro+"%"

		cAliasTmp	:= GetNextAlias()

		BeginSql Alias cAliasTmp
			SELECT 
				R_E_C_N_O_ RECNO
			FROM 
				%Table:GZH% GZH
			WHERE 
				GZH.%notdel%
				AND GZH.GZH_FILIAL = %xfilial:GZH%
				AND GZH.GZH_STATUS IN ('3','5','B')
				AND GZH.GZH_XMLCTE <> ' '
				%exp:cFiltro%
				ORDER BY GZH.GZH_CLIENT,GZH.GZH_LOJA,GZH.GZH_SERIE,GZH.GZH_NOTA,GZH.GZH_DSAIDA
		EndSql

		While !(cAliasTmp)->(EOF())
			
			GZH->(DbGoTo((cAliasTmp)->RECNO))
			
			GZHExport_(cPath,lPos,@cMsgRet)
			
			(cAliasTmp)->(DbSkip())
		EndDo
		(cAliasTmp)->(DBCloseArea())

		If !EMPTY(Alltrim(cMsgRet))
			Aviso("CTeOS - "+"Exporta��o de CTeOS", cMsgRet, {'OK'}, 3)  //"Exporta��o de CTeOS"
		else
			FwAlertSuccess('Exporta��o concluida.',"Aten��o")   //
		EndIf

	EndIf

EndIf

RestArea(aAreaGZH)

Return()

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GZHExporta
Exporta��o do Xml de distribui��o do CTeOS

@param nil

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
function GZHExport_(cPath,lPos,cMsgRet, lAut)
    
    local cFile := ""
    local cXml  := ""
    local nHdl
    local lSave    := .T.
    local cRetorno := ""
    
    Default lAut := .F.

	cFile := GZH->GZH_CLIENT  + "-" + alltrim(GZH->GZH_LOJA) + "-" + alltrim(GZH->GZH_SERIE) + "-" + GZH->GZH_NOTA + ".xml"

    cXml := alltrim(GZH->GZH_XMLCTE)

    nHdl := fCreate(AllTrim(cPath + cFile))

     If lAut
        cXml := 'Automa��o'
    EndIf

    If(!empty(cPath))

        If(nHdl < 0)
            lSave := .F.
            cRetorno := "Falha ao Criar arquivo: " + CRLF + cPath + cFile + CRLF                //"Falha ao Criar arquivo: "
        ElseIf(empty(cXml))
            lSave := .F.
            cRetorno := "Xml Inv�lido para Distribui��o:" + CRLF + cXml + CRLF  //"Xml Inv�lido para Distribui��o:"
        Else
            If( !fwrite(nHdl, cXml) )
                cRetorno := "Erro de grava��o: " + CRLF + str(FError()) + CRLF  //"Erro de grava��o: "
            Else
                IF lPos            
                    cRetorno := "Arquivo Salvo com sucesso!"       // "Arquivo Salvo com sucesso!"
                EndIf
                fClose(nHdl)
            EndIf

        EndIf
        
        If lPos
            Aviso(STR0009, cRetorno, {STR0004}, 3)        //"CTeOS - Exporta��o de CTeOS"
        Else
            cMsgRet += cRetorno
        EndIF    
    EndIf
Return
