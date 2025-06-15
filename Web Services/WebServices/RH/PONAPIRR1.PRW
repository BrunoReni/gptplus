#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PONAPIRR1.CH"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )

Static __oSt1//fDisp()
Static __oSt2//fValNSR()

//---------------------------------------------------------------------
/*/{Protheus.doc} recordClockMarkings
@type			method
@description	Serviço para gravação de marcações originadas do Suricato na tabela RR1
@author			Allyson Mesashi
@since			16/10/2020
/*/
//---------------------------------------------------------------------
WSRESTFUL recordClockMarkings DESCRIPTION STR0001 FORMAT APPLICATION_JSON//"Serviço para gravação de marcações originadas do Suricato na tabela RR1"

WSDATA companyId			AS STRING
WSDATA branchId			    AS STRING
WSDATA items				AS ARRAY

WSMETHOD POST;
	DESCRIPTION STR0002;//"Inclui marcações originadas do Suricato na tabela RR1"
	WSSYNTAX "api/rh/v1/recordClockMarkings";
	PATH "api/rh/v1/recordClockMarkings";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

END WSRESTFUL

/*/{Protheus.doc} POST
@type			method
@description	Método responsável por incluir marcações originadas do Suricato na tabela RR1
@author			Allyson Mesashi
@since			16/10/2020
@version 12.1.27
/*/
WSMETHOD POST WSREST recordClockMarkings 

Local cBody	    	:= self:GetContent()
Local lRet          := .T.
Local oParams   	:= JsonObject():New()
Local oResp     	:= JsonObject():New()

Private bError      := { |e| oError := e, Break(e) }
Private bErrorBlock := ErrorBlock( bError )
Private oError
Private aGrpEmp		:= {}

oParams:FromJSON( cBody )

BEGIN SEQUENCE
	If checkParams(oParams)
        If !AliasInDic("RR1")
            lRet := .F.
            SetRestFault( 400, EncodeUTF8( STR0004 ) )//"A tabela RR1 não existe no dicionário de dados. É necessário a atualização do sistema para utilizar este serviço."
        Else
            If fGrvRR1( oParams, @oResp )
				Self:setHeader("Status", "200")
			Else
				Self:setHeader("Status", "400")
			EndIf
			Self:setResponse( EncodeUTF8(oResp:ToJson()) )
        EndIf
	Else
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( STR0005 ) )//"Parâmetro inválido: verifique se o parâmetro 'items' foi enviado."
	EndIf
RECOVER
	lRet := .F.
	ErrorBlock( bErrorBlock )
	SetRestFault( 500, EncodeUTF8( STR0006 ) + TAB + EncodeUTF8( oError:Description ) ) //"Ocorreu uma falha no retorno da informação: "
END SEQUENCE

Return lRet

/*/{Protheus.doc} checkParams
Validação dos parâmetros recebidos.
@author Allyson Mesashi
@since 16/10/2020
/*/
Static Function checkParams( oParams )

Local lRet	:=	.T.

If Empty( oParams["items"] )
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} function fSetErrorHandler
Função para setar erros tratados
@author  Hugo de Oliveira
@since   07/02/2020
/*/
Static Function fSetErrorHandler( cTitle )

bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
bErrorBlock	:= ErrorBlock( bError )

Return .T.

/*/{Protheus.doc} function fResetErrorHandler
Função para limpar o retorno de erros
@author  Hugo de Oliveira
@since   07/02/2020
/*/
Static Function fResetErrorHandler( cTitle )

bError  	:= { |e| oError := e , Break( e ) }
bErrorBlock := ErrorBlock( bError )

Return .T.

/*/{Protheus.doc} checkParams
Validação dos parâmetros recebidos.
@author Allyson Mesashi
@since 16/10/2020
/*/
Static Function fGrvRR1( oParams, oResp )
Local aMarcs		:= oParams["items"]
Local aRet			:= {}
Local lTudoOk		:= .T.
Local lRR1671		:= .F. 
Local lEnv671		:= .F. 
Local oRet     		:= Nil
Local nCodNSR		:= 0
Local nVersLayou	:= 0
Local nNumMarcac	:= 0
Local nCont			:= 0
Local cCodPIS		:= ""
Local cDatMarcac	:= ""
Local cCodRelExt	:= ""
Local cCodFuncM		:= ""
Local cCodREP		:= ""
Local cCodUniExt	:= ""
Local cCodUsrExt	:= ""
Local cCodCPF		:= ""
Local cInscrEmp		:= ""
Local cCodFuso		:= ""
Local cModo			:= ""
Local cEmpAntBck	:= cEmpAnt
Local aEmp			:= {}


Private	nTamCodRel	:= GetSx3Cache( "RR1_CODREL" , "X3_TAMANHO" )
Private	nTamCodRep	:= GetSx3Cache( "RR1_CODREP" , "X3_TAMANHO" )

dbSelectArea("RR1")

lRR1671 := RR1->(ColumnPos("RR1_CODPIS")) > 0 .And. ;
		   RR1->(ColumnPos("RR1_FUSO"  )) > 0 .And. ;
		   RR1->(ColumnPos("RR1_VRSLAY")) > 0 .And. ;
		   RR1->(ColumnPos("RR1_INSCR" )) > 0

aGrpEmp := fBuscEmps()

For nCont := 1 To Len(aMarcs)
	oRet     	:= JsonObject():New()
	cCodRelExt	:= aMarcs[nCont]["codRelogioExtChave"]
	cCodFuncM	:= aMarcs[nCont]["codFuncMsa"]
	nCodNSR		:= aMarcs[nCont]["codNsr"]
	cCodPIS		:= aMarcs[nCont]["codPisMsa"]
	cDatMarcac	:= aMarcs[nCont]["datMarcacAces"]
	nNumMarcac	:= aMarcs[nCont]["numHorarMarcacAces"]
	cCodREP		:= aMarcs[nCont]["codRep"]
	cCodUniExt	:= aMarcs[nCont]["codUnidExtChave"]
	cCodUsrExt	:= aMarcs[nCont]["codUsuarExtChave"]
	nVersLayou	:= 0

	If aMarcs[nCont]["codFuso"] <> Nil .And. aMarcs[nCont]["codCPF"] <> Nil .And. aMarcs[nCont]["numVersLayout"] <> Nil .And. aMarcs[nCont]["inscrEmp"] <> Nil
		cCodFuso	:= aMarcs[nCont]["codFuso"]
		cCodCPF		:= aMarcs[nCont]["codCPF"]
		cInscrEmp	:= aMarcs[nCont]["inscrEmp"]

		If Empty(aMarcs[nCont]["numVersLayout"])
			nVersLayou := 0
		ElseIf ValType(aMarcs[nCont]["numVersLayout"]) == "C"
			nVersLayou := Val(aMarcs[nCont]["numVersLayout"])
		ElseIf ValType(aMarcs[nCont]["numVersLayout"]) == "N"
			nVersLayou := aMarcs[nCont]["numVersLayout"]
		EndIf

		lEnv671 := .T.
	EndIf

	aEmp := {}
	aEmp := fDefEmp(aGrpEmp,cCodUniExt)

	If (cCodRelExt == Nil .And. cCodREP == Nil) .Or. cCodFuncM == Nil .Or. cCodPIS == Nil .Or. cDatMarcac == Nil .Or.;
		nNumMarcac == Nil .Or. cCodUniExt == Nil .Or. cCodUsrExt == Nil
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		
		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf 
		
		oRet["message"] 			:= STR0033 // "Não foi informado algum dos campos obrigatórios: 'codRelogioExtChave', 'codFuncMsa', 'codPisMsa', 'datMarcacAces', 'numHorarMarcacAces', 'codRep', 'codUnidExtChave' ou 'codUsuarExtChave'."
		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"

		aAdd( aRet, oRet )
		Loop
	ElseIf Empty(aEmp)
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		
		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf 
		
		oRet["message"] 			:= STR0036 // "Empresa não encontrada. Verifique se o campo 'codUnidExtChave' possui uma empresa válida."
		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"

		aAdd( aRet, oRet )
		Loop
	ElseIf ValType( cCodRelExt ) != "C"
		lTudoOk				:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		
		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0014 // "Campo 'codRelogioExtChave' no formato incorreto. Deve ser preenchido como texto."
		aAdd( aRet, oRet )
		Loop
	ElseIf ValType( cCodFuncM ) != "C"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		
		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0015 // "Campo 'codFuncMsa' no formato incorreto. Deve ser preenchido como texto."
		aAdd( aRet, oRet )
		Loop
	ElseIf ValType( nCodNSR ) != "U" .And. ValType( nCodNSR ) != "N"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt

		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0016 // "Campo 'codNsr' no formato incorreto. Deve ser preenchido como numérico."
		aAdd( aRet, oRet )
		Loop
	ElseIf ValType( cCodPIS ) != "C"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt

		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0017 // "Campo 'codPisMsa' no formato incorreto. Deve ser preenchido como texto."
		aAdd( aRet, oRet )
		Loop
	ElseIf ValType( cDatMarcac ) != "C" .Or. ValType( sToD( StrTran( SubStr(cDatMarcac, 1, 10), "-" ) ) ) != "D"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt

		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0018 // "Campo 'datMarcacAces' no formato incorreto. Deve ser preenchido como data."
		aAdd( aRet, oRet )
		Loop
	ElseIf ValType( nNumMarcac ) != "N"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt

		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0019 // "Campo 'numHorarMarcacAces' no formato incorreto. Deve ser preenchido como numérico."
		aAdd( aRet, oRet )
		Loop
	ElseIf ValType( cCodREP ) != "C"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt

		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0020 // "Campo 'codRep' no formato incorreto. Deve ser preenchido como texto."
		aAdd( aRet, oRet )
		Loop
	ElseIf ValType( cCodUniExt ) != "C"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt

		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0021 // "Campo 'codUnidExtChave' no formato incorreto. Deve ser preenchido como texto."
		aAdd( aRet, oRet )
		Loop
	ElseIf ValType( cCodUsrExt ) != "C"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt

		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0022 // "Campo 'codUsuarExtChave' no formato incorreto. Deve ser preenchido como texto."
		aAdd( aRet, oRet )
		Loop
	ElseIf !fValPis(cCodPIS,aEmp)
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt

		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00001"
		oRet["message"] 			:= STR0023 // "PIS em formato inválido ou inexistente no cadastro."
		aAdd( aRet, oRet )
		Loop
	ElseIf !fDisp(cCodREP, cCodRelExt,aEmp)
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		
		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00007"
		oRet["message"] 			:= STR0024 // "Foi enviado marcações de um relógio que não está cadastrado no ERP."
		aAdd( aRet, oRet )
		Loop
	ElseIf nCodNSR == Nil
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00003"
		oRet["message"] 			:= STR0025 // "NSR não foi informado e é obrigatório."
		aAdd( aRet, oRet )
		Loop
	ElseIf !fValNSR(nCodNSR, cCodREP, cCodRelExt,aEmp)
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt

		If lEnv671
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
		EndIf

		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00002"
		oRet["message"] 			:= STR0026 // "NSR duplicado. Número já foi importado na tabela."
		aAdd( aRet, oRet )
		Loop
	ElseIf lEnv671 .And. !Empty(cCodFuso) .And. ValType(cCodFuso) != "C"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		oRet["codFuso"]				:= cCodFuso
		oRet["codCPF"]				:= cCodCPF
		oRet["numVersLayout"]		:= nVersLayou
		oRet["inscrEmp"]			:= cInscrEmp
		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00009"
		oRet["message"] 			:= STR0034 // "Campo 'codFuso' no formato incorreto. Deve ser preenchido como texto."
		aAdd( aRet, oRet )
		Loop	
	ElseIf lEnv671 .And. !Empty(cCodCPF) .And. ValType(cCodCPF) != "C"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		oRet["codFuso"]				:= cCodFuso
		oRet["codCPF"]				:= cCodCPF
		oRet["numVersLayout"]		:= nVersLayou
		oRet["inscrEmp"]			:= cInscrEmp
		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00009"
		oRet["message"] 			:= STR0032 // "Campo 'codCPF' no formato incorreto. Deve ser preenchido como texto."
		aAdd( aRet, oRet )
		Loop
	ElseIf lEnv671 .And. !Empty(cCodCPF) .And. !ChkCPF(cCodCPF)
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		oRet["codFuso"]				:= cCodFuso
		oRet["codCPF"]				:= cCodCPF
		oRet["numVersLayout"]		:= nVersLayou
		oRet["inscrEmp"]			:= cInscrEmp
		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0029 // "CPF inválido."
		aAdd( aRet, oRet )
		Loop
	ElseIf lEnv671 .And. !Empty(nVersLayou) .And. ValType(nVersLayou) != "N"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		oRet["codFuso"]				:= cCodFuso
		oRet["codCPF"]				:= cCodCPF
		oRet["numVersLayout"]		:= nVersLayou
		oRet["inscrEmp"]			:= cInscrEmp
		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0030 // "Campo 'numVersLayout' no formato incorreto. Deve ser preenchido como número."
		aAdd( aRet, oRet )
		Loop
	ElseIf lEnv671 .And. !Empty(cInscrEmp) .And. ValType(cInscrEmp) != "C"
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		oRet["codFuso"]				:= cCodFuso
		oRet["codCPF"]				:= cCodCPF
		oRet["numVersLayout"]		:= nVersLayou
		oRet["inscrEmp"]			:= cInscrEmp
		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0031 // "Campo 'inscrEmp' no formato incorreto. Deve ser preenchido como texto."
		aAdd( aRet, oRet )
		Loop
	ElseIf (lEnv671 .And. Empty(cCodCPF) .And. Empty(cCodPIS)) .Or. (!lEnv671 .And. Empty(cCodPIS))
		lTudoOk						:= .F.
		oRet["codRelogioExtChave"]	:= cCodRelExt
		oRet["codFuncMsa"]			:= cCodFuncM
		oRet["codNsr"]				:= nCodNSR
		oRet["codPisMsa"]			:= cCodPIS
		oRet["datMarcacAces"]		:= cDatMarcac
		oRet["numHorarMarcacAces"]	:= nNumMarcac
		oRet["codRep"]				:= cCodREP
		oRet["codUnidExtChave"]		:= cCodUniExt
		oRet["codUsuarExtChave"]	:= cCodUsrExt
		oRet["codFuso"]				:= cCodFuso
		oRet["codCPF"]				:= cCodCPF
		oRet["numVersLayout"]		:= nVersLayou
		oRet["inscrEmp"]			:= cInscrEmp
		oRet["status"] 				:= 400
		oRet["errorCode"] 			:= "00006"
		oRet["message"] 			:= STR0035 // "O documento do funcionário não foi enviado. O PIS ou o CPF deve ser preenchido."
		aAdd( aRet, oRet )
		Loop
	EndIf
	
	If EmpOpenFile("RR1","RR1",1,.T.,aEmp[1,1],@cModo)
		If RR1->( Reclock("RR1", .T.) )
			RR1->RR1_VALCON		:= fProxVal(aEmp)
			RR1->RR1_CODREL		:= cCodRelExt
			RR1->RR1_CODFUN		:= cCodFuncM
			RR1->RR1_LOGIP		:= "0"
			RR1->RR1_CODNSR		:= nCodNSR
			RR1->RR1_CODPIS		:= cCodPIS
			RR1->RR1_DATMAR		:= sToD( StrTran( SubStr(cDatMarcac, 1, 10), "-" ) )
			RR1->RR1_NUMMAR		:= nNumMarcac
			RR1->RR1_CODREP		:= cCodREP
			RR1->RR1_CODUNI		:= cCodUniExt
			RR1->RR1_CODUSU		:= cCodUsrExt
			
			If lRR1671 .And. lEnv671
				RR1->RR1_FUSO		:= cCodFuso
				RR1->RR1_CODCPF		:= cCodCPF
				RR1->RR1_VRSLAY		:= nVersLayou
				RR1->RR1_INSCR		:= cInscrEmp
			EndIf

			RR1->( MsUnlock() )
			
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt

			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
			EndIf

			oRet["status"] 				:= 200
			oRet["errorCode"] 			:= ""
			oRet["message"] 			:= STR0027 // "Gravação efetuada com sucesso."
			aAdd( aRet, oRet )
		Else
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "99999"
			oRet["message"] 			:= "Erro interno no lock da tabela RR1. Registro não foi gravado"
			aAdd( aRet, oRet )
		EndIf
		EmpOpenFile("RR1","RR1",1,.T.,cEmpAntBck,@cModo)
		Loop
	EndIf
Next nCont

oResp["items"]	:= aRet

Return lTudoOk

/*/{Protheus.doc} fProxVal
Busca o proximo registro sequencial da tabela RR1.
@author Allyson Mesashi
@since 16/10/2020
/*/
Static Function fProxVal(aEmp)
Local cAliasTMP := GetNextAlias()
Local nContador := 0
Local cTabela	:= ""

cTabela := "%" + aEmp[1,3] + "%"

BeginSql alias cAliasTMP
	SELECT 	MAX(RR1_VALCON) AS MAXIMO
	FROM 	%Exp:cTabela%
EndSql

nContador := (cAliasTMP)->(MAXIMO)

(cAliasTMP)->(dbCloseArea())

nContador += 1

Return nContador

/*/{Protheus.doc} fValPis
Efetua busca do PIS na SRA
@author Allyson Mesashi
@since 26/03/2021
@version P12.1.27
/*/
Static Function fValPis(cCodPIS,aEmp)
Local cPisSRA		:= Iif( Left( cCodPIS , 1) == "0", Right(cCodPIS, 11), cCodPIS )
Local lRet			:= .F.
Local cModo			:= ""
Local cEmpAntBck	:= cEmpAnt
Local aArea 		:= GetArea()
Local aAreaSRA 		:= SRA->(GetArea())

Default aEmp 	:= {}

If EmpOpenFile("SRA","SRA",26,.T.,aEmp[1,1],@cModo)
	lRet := SRA->( dbSeek( cPisSRA ) )
EndIf

EmpOpenFile("SRA","SRA",26,.T.,cEmpAntBck,@cModo)
RestArea(aArea)
RestArea(aAreaSRA)

Return lRet

/*/{Protheus.doc} fDisp
Efetua busca do dispositivo
@author Allyson Mesashi
@since 26/03/2021
@version P12.1.27
/*/
Static Function fDisp(cCodREP, cCodRelExt,aEmp)
Local cAliasQRY := GetNextAlias()
Local cCodRel	:= ""
Local cQuery	:= ""
Local lRet		:= .F.

If !Empty(cCodREP)
	cCodRel	:= cCodREP
Else
	cCodRel	:= cCodRelExt
EndIf

If __oSt1 == Nil
	__oSt1 := FWPreparedStatement():New()	 

	cQuery := "SELECT COUNT(*) AS CONT "
	cQuery += "FROM ? "
	cQuery += "WHERE "
	cQuery += "P0_REP = ? AND "
	cQuery += "D_E_L_E_T_= ' '"	
	cQuery := ChangeQuery(cQuery)
	
	__oSt1:SetQuery(cQuery)
EndIf

__oSt1:SetString(1, aEmp[1,2])
__oSt1:SetString(2, cCodRel)
cQuery := __oSt1:getFixQuery()

cQuery := StrTran(cQuery, "'" + aEmp[1,2] + "'",aEmp[1,2])

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQRY)

lRet := (cAliasQRY)->CONT > 0

(cAliasQRY)->( dbCloseArea() )

Return lRet

/*/{Protheus.doc} fValNSR
Efetua validação/busca do NSR
@author Allyson Mesashi
@since 26/03/2021
@version P12.1.27
/*/
Static Function fValNSR(nCodNSR, cCodREP, cCodRelExt,aEmp)
Local cAliasQRY 	:= GetNextAlias()
Local cChaveBus		:= ""
Local cCodRel		:= ""
Local cQuery		:= ""
Local cModo			:= ""
Local lMarc			:= .F.
Local lRep			:= .F.
Local lRet			:= .T.
Local cEmpAntBck	:= cEmpAnt
Local aArea 		:= GetArea()
Local aAreaRR1 		:= RR1->(GetArea())
Local aAreaSP0 		:= SP0->(GetArea())

Default aEmp 	:= {}

If !Empty(cCodREP)
	cCodRel	:= cCodREP
	lRep	:= .T.
Else
	cCodRel	:= cCodRelExt
EndIf

If __oSt2 == Nil
	__oSt2 := FWPreparedStatement():New()	 

	cQuery := "SELECT R_E_C_N_O_ AS RECNO "
	cQuery += "FROM ? "
	cQuery += "WHERE "
	cQuery += "P0_REP = ? AND "
	cQuery += "D_E_L_E_T_= ' '"	
	cQuery := ChangeQuery(cQuery)
	
	__oSt2:SetQuery(cQuery)
EndIf

__oSt2:SetString(1, aEmp[1,2])
__oSt2:SetString(2, cCodRel)

cQuery := __oSt2:getFixQuery()

cQuery := StrTran(cQuery, "'" + aEmp[1,2] + "'",aEmp[1,2])

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQRY)

If (cAliasQRY)->( !EoF() )
	If EmpOpenFile("SP0","SP0",1,.T.,aEmp[1,1],@cModo)
		SP0->( dbGoTo((cAliasQRY)->RECNO) )
		lMarc := SP0->P0_CONTROL == "P"
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

If lRet .And. lMarc
	If EmpOpenFile("RR1","RR1",1,.T.,aEmp[1,1],@cModo)
		If lRep
			RR1->( dbSetOrder(7) )//RR1_CODREP+STR(RR1_CODNSR,9)
			cChaveBus := PadR(cCodREP, nTamCodRep)+Str(nCodNSR, 9)
		Else
			RR1->( dbSetOrder(5) )//RR1_CODREL+STR(RR1_CODNSR,9)
			cChaveBus := PadR(cCodRel, nTamCodRel)+Str(nCodNSR, 9)
		EndIf
		
		If RR1->( dbSeek( cChaveBus ) )
			lRet := .F.
		EndIf
	EndIf
EndIf

cEmpAnt := cEmpAntBck
	
EmpOpenFile("SP0","SP0",1,.T.,cEmpAnt,@cModo)
EmpOpenFile("RR1","RR1",1,.T.,cEmpAnt,@cModo)
RestArea(aArea)
RestArea(aAreaRR1)
RestArea(aAreaSP0)

Return lRet

/*/{Protheus.doc} fBuscEmps
Função para buscar todos os grupos de empresas
@author Marco Nakazawa
@since 25/05/2023
@version P12.1.2210
/*/
Static Function fBuscEmps()
Local aRet			:= {}
Local aSM0			:= {}
Local nI			:= 0
Local cEmpAntBck	:= cEmpAnt
Local cFilAntBck	:= cFilAnt

RPCSetType(3)

aSM0 := FWAllGrpCompany()

For nI := 1 To Len(aSM0)
	RESET ENVIRONMENT
	PREPARE ENVIRONMENT EMPRESA aSM0[nI] FILIAL ""

	RpcSetEnv(aSM0[nI],FWGetCodFilial,,,,,{"SP0","RR1"})
	DBSelectArea("RR1")
	DBSelectArea("SP0")
	
	aAdd(aRet,{aSM0[nI],RetSqlName('SP0'),RetSqlName('RR1')})

	RR1->(DBCloseArea())
	SP0->(DBCloseArea())
Next

// Restauro o ambiente 
RESET ENVIRONMENT
PREPARE ENVIRONMENT EMPRESA cEmpAntBck FILIAL cFilAntBck

Return aRet

/*/{Protheus.doc} fDefEmp
Função para definir qual grupo de empresas deverá ser utilizado para validar e salvar a marcação
@author Marco Nakazawa
@since 25/05/2023
@version P12.1.2210
/*/
Static Function fDefEmp(aGrpEmp,cCodUniExt)
Local nI			:= 0
Local aRet			:= {}

Default	aGrpEmp		:= {}
Default	cCodUniExt	:= ""

If !Empty(cCodUniExt) .And. !Empty(aGrpEmp)
	For nI := 1 To Len(aGrpEmp)
		If aGrpEmp[nI,1] $ SubStr(cCodUniExt,1,Len(aGrpEmp[nI,1]))
			aAdd(aRet,aGrpEmp[nI])
			Exit
		EndIf
	Next
EndIf

Return aRet
