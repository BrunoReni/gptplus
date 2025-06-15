#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHLIBAPI.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )

/*
{Protheus.doc} fSetInforRJP(nOperacao,)
Biblioteca de funcoes para tratamento de envio de dados de API                    
@author  Wesley Alves Pereira
@since   23/03/2020
@version 12.1.27
*/

Function fSetInforRJP(cTmpFil, cTmpMat, cProces, cChaves, cOperac,  dDtBase, cHoraAt,cUserId)
//cTmpFil - Filial da Entidade
//cTmpMat - Matricula do Funcionario
//cProces - Tabela da Entidade
//cChaves - Chave da Entidade
//cOperac - Tipo da operacao
//dDtBase - Data da operacao
//cHoraAt - Hora da operacao
//cUserId - Usuario da operacao

Local lReto := .F.
Local lAltReg := .F.
Local TamFil := TamSX3( 'RJP_FIL' )[1] - Len(cTmpFil)
Local TamMat := TamSX3( 'RJP_MAT' )[1] - Len(cTmpMat)
Local CIncSemInteg := "I"

cTmpFil := cTmpFil + Space(TamFil)
cTmpMat := cTmpMat + Space(TamMat)  

If ! TcCanOpen(RetSqlName("RJP"))
	Help( " ", 1, OemToAnsi(STR0001),, OemToAnsi(STR0002), 1, 0 )
	Return (lReto)
EndIf

If (cOperac == 'E')
	DBSelectArea("RJP")
	DBSetOrder(1)
	If DBSeek(xFilial("RJP")+cTmpFil+cTmpMat)
		While ! EOF() .AND. RJP->RJP_FILIAL == xFilial("RJP") .AND. RJP->RJP_FIL == cTmpFil .AND. RJP->RJP_MAT == cTmpMat 
			If  ( ( Alltrim(RJP->RJP_TAB) == Alltrim(cProces)) .AND. ( Alltrim(RJP->RJP_KEY) == Alltrim(cChaves) ) .AND. ( RJP->RJP_OPER == 'I') .AND. Empty(RJP->RJP_DTIN))
				If RecLock("RJP",.F.)
					RJP->(DbDelete())

					lReto := .T. 
				
					Return (lReto)

				EndIf
			EndIf
			
			DBSelectArea("RJP")
			DBSkip()
		
		EndDo	
	EndIf	
EndIf

DBSelectArea("RJP")
DBSetOrder(7)
If (RJP->(DBSeek(xFilial("RJP")+cProces+cChaves)))
	While RJP->RJP_FILIAL== xFilial("RJP") .AND. RJP->RJP_TAB == cProces .AND. RJP->RJP_FIL == cTmpFil ;
	.AND. ( RJP->RJP_OPER == cOperac .OR. RJP->RJP_OPER == CIncSemInteg ) .AND. AllTrim(RJP->RJP_KEY) == AllTrim(cChaves)

		If Empty(RJP->RJP_DTIN)	
			If RecLock("RJP",.F.)

				RJP->RJP_DATA   := dDtBase
				RJP->RJP_HORA   := cHoraAt
				RJP->RJP_USER   := cUserId
					
				RJP->(MsUnlock())

				lReto 	:= .T.
				lAltReg	:= .T.
			EndIf
		EndIf
		DBSkip()		
	EndDo
Endif

If !lAltReg .And. RecLock("RJP",.T.)

		RJP->RJP_FILIAL := xFilial("RJP")
		RJP->RJP_FIL    := cTmpFil
		RJP->RJP_MAT    := cTmpMat
		RJP->RJP_TAB    := cProces
		RJP->RJP_KEY    := cChaves
		RJP->RJP_DATA   := dDtBase
		RJP->RJP_HORA   := cHoraAt
		RJP->RJP_OPER   := cOperac
		RJP->RJP_USER   := cUserId
	
		RJP->(MsUnlock())

		lReto := .T.
EndIf

Return (lReto)

/*
{Protheus.doc} fSetDeptoRJP(nOperacao,)
Biblioteca de funcoes para tratamento de envio de dados de API                    
@author  brdwc0032
@since   23/03/2020
@version 12.1.27
*/

Function fSetDeptoRJP(cTmpFil, cProces, cChaves, cOperac,  dDtBase, cHoraAt, cUserId)
//cTmpFil - Filial da Entidade
//cProces - Tabela da Entidade
//cChaves - Chave da Entidade
//cOperac - Tipo da operacao
//dDtBase - Data da operacao
//cHoraAt - Hora da operacao
//cUserId - Usuario da operacao

Local lReto := .F.
Local lAltReg := .F.
Local TamFil := TamSX3( 'RJP_FIL' )[1] - Len(cTmpFil)
Local CIncSemInteg := "I"

cTmpFil := cTmpFil + Space(TamFil) 

If ! TcCanOpen(RetSqlName("RJP"))
	Help( " ", 1, OemToAnsi(STR0001),, OemToAnsi(STR0002), 1, 0 )
	Return (lReto)
EndIf

If (cOperac == 'E')
	DBSelectArea("RJP")
	DBSetOrder(7)
	If DBSeek(xFilial("RJP")+cProces+cChaves)
		While ! EOF() .AND. RJP->RJP_FILIAL == xFilial("RJP") .AND. RJP->RJP_FIL == cTmpFil .AND. RJP->RJP_TAB == cProces .AND. Alltrim(RJP->RJP_KEY) == Alltrim(cChaves) 
			If  ( ( Alltrim(RJP->RJP_TAB) == Alltrim(cProces)) .AND. ( Alltrim(RJP->RJP_KEY) == Alltrim(cChaves) ) .AND. ( RJP->RJP_OPER == 'I') .AND. Empty(RJP->RJP_DTIN))
				If RecLock("RJP",.F.)
					RJP->(DbDelete())

					lReto := .T. 
				
					Return (lReto)

				EndIf
			EndIf
			
			DBSelectArea("RJP")
			DBSkip()
		
		EndDo	
	EndIf	
EndIf

DBSelectArea("RJP")
DBSetOrder(7)
If (RJP->(DBSeek(xFilial("RJP")+cProces+cChaves)))
	While RJP->RJP_FILIAL== xFilial("RJP") .AND. RJP->RJP_TAB == cProces .AND. RJP->RJP_FIL == cTmpFil ;
	.AND. ( RJP->RJP_OPER == cOperac .OR. RJP->RJP_OPER == CIncSemInteg ) .AND. AllTrim(RJP->RJP_KEY) == AllTrim(cChaves)

		If Empty(RJP->RJP_DTIN)	
			If RecLock("RJP",.F.)

				RJP->RJP_DATA   := dDtBase
				RJP->RJP_HORA   := cHoraAt
				RJP->RJP_USER   := cUserId
					
				RJP->(MsUnlock())

				lReto := .T.
				lAltReg	:= .T.
			EndIf
		EndIf
		DBSkip()		
	EndDo
Endif

If !lAltReg .And. RecLock("RJP",.T.)

		RJP->RJP_FILIAL := xFilial("RJP")
		RJP->RJP_FIL    := cTmpFil
		RJP->RJP_MAT    := Space(TamSX3("RJP_MAT")[1])
		RJP->RJP_TAB    := cProces
		RJP->RJP_KEY    := cChaves
		RJP->RJP_DATA   := dDtBase
		RJP->RJP_HORA   := cHoraAt
		RJP->RJP_OPER   := cOperac
		RJP->RJP_USER   := cUserId
	
		RJP->(MsUnlock())

		lReto := .T.
EndIf

Return (lReto)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fFormTel
Recebe o DDD e Telefone e retorna formatado para envio na API
@author  Hugo de Oliveira
@since   18/05/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function fFormTel(cDDD, cTelefone)
    
    DEFAULT cDDD := ""
    DEFAULT cTelefone := ""

    If Len(cTelefone) > 7 .AND. !Empty(cTelefone) // Tamanho Mínimo: 8
        If !Empty(cDDD)
            cTelefone := cDDD + " " + cTelefone
        EndIf

        If Len(cTelefone) == 9 // "975434543" - Sem DDD(Obrigatório)
            cTelefone := "XX " + cTelefone

        ElseIf Len(cTelefone) == 8 // "75434543" - Sem 9 Dígito(Não Obrigatório) e sem DDD(Obrigatório)
            cTelefone := "XX " + cTelefone
        EndIf
    Else
        cTelefone := ""
    EndIf
Return cTelefone

//-------------------------------------------------------------------
/*/{Protheus.doc} function fAtuRJPRet
Atualiza retorno da API na RJP
@author  Marcio Felipe Martins
@since   18/05/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function fAtuRJPRet(nRecno, cRetCode, cRet, cCodSucss)

Local lOk    := .F.
Local cAlias := "RJP"

DEFAULT cCodSucss := "200|201|202|203|204"

DbSelectArea( cAlias )
( cAlias )->( DbGoTop() )

DbGoTo(nRecno)

If !Eof()
    If Reclock( cAlias, .F.)
        ( cAlias )->RJP_DTIN 	:= DATE()
        ( cAlias )->RJP_HORAIN  := TIME()
		
		If cRetCode $ cCodSucss
            ( cAlias )->RJP_RTN := STR0003 // "Registro integrado com sucesso!"
        Else
            ( cAlias )->RJP_RTN := cRetCode + " - " + cRet
        EndIf

        MsUnlock()
        lOk := .T.
    EndIf
EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} function fComprJSn
Compacta os dados do retorno solicitado
@author  Marcio Felipe Martins
@since   22/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function fComprJSn(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := FWJsonSerialize(oObj,.T.,.T.)

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf
	
	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif

Return cComp
