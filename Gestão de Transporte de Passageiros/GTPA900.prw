#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA900.CH"

/*/{Protheus.doc} GTPA900()
(long_description)
@type  Function
@author Lucivan Severo Correia
@since 25/06/2020
@version 1
@param 
@return 
@example
(examples)
@see (links_or_references)
/*/
Function GTPA900()
Local oBrowse
Local cMsgErro	:= ''

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
		
	If ValidaDic(@cMsgErro)

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("GY0")
		oBrowse:SetDescription(STR0007) //"Orçamento de Contrato"
			
		oBrowse:AddLegend('GY0_STATUS == "1"',"YELLOW",STR0041, 'GY0_STATUS')//"Em orçamento"
		oBrowse:AddLegend('GY0_STATUS == "2"',"GREEN" ,STR0042, 'GY0_STATUS')//"Contrato vigente"
		oBrowse:AddLegend('GY0_STATUS == "3"',"RED"	  ,STR0043, 'GY0_STATUS')//"Cancelado"
		oBrowse:AddLegend('GY0_STATUS == "4"',"BLACK" ,STR0072, 'GY0_STATUS')//"Finalizado"
		oBrowse:AddLegend('GY0_STATUS == "5"',"ORANGE",STR0081, 'GY0_STATUS')//"Em Revisão"
		oBrowse:AddLegend('GY0_STATUS == "6"',"BLUE"  ,STR0082, 'GY0_STATUS')//"Revisão vigente"
		oBrowse:AddLegend('GY0_STATUS == "7"',"WHITE" ,STR0083, 'GY0_STATUS')//"Obsoleto"

		oBrowse:ACTIVATE()
	Else
		FwAlertHelp(cMsgErro, STR0017)	// "Banco de dados desatualizado, não é possível iniciar a rotina"
	EndIf

EndIf

Return()

/*/{Protheus.doc} MenuDef
(long_description)
@type  Static Function
@author Lucivan Severo Correia
@since 25/06/2020
@version 1
@param 
@return aRotina, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina 	:= {}
Local aRevisa	:= {}

	ADD OPTION aRevisa TITLE STR0094 ACTION "G900IniRev(1)"	OPERATION 2 ACCESS 0 // "Aberta"
	ADD OPTION aRevisa TITLE STR0095 ACTION "G900IniRev(2)"	OPERATION 2 ACCESS 0 // "Reajuste"

	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.GTPA900" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GTPA900" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0003 ACTION "UpdDelCtr(4)"    OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0004 ACTION "UpdDelCtr(5)"    OPERATION 5 ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE STR0024 ACTION "GTPA900CTR()"    OPERATION 2 ACCESS 0 // Gerar contrato 
	ADD OPTION aRotina TITLE STR0025 ACTION "GTPA900CAN()"    OPERATION 2 ACCESS 0 // Cancelar contrato 
	ADD OPTION aRotina TITLE STR0073 ACTION "GTPA900ENC()"    OPERATION 2 ACCESS 0 // Finalizar contrato 
	ADD OPTION aRotina TITLE STR0046 ACTION "G900GerVia(1)"   OPERATION 2 ACCESS 0 // Gerar Viagens
	ADD OPTION aRotina TITLE STR0047 ACTION "G900GerVia(2)"   OPERATION 2 ACCESS 0 // Consultar Viagens
	ADD OPTION aRotina TITLE STR0049 ACTION "G900GerVia(3)"   OPERATION 2 ACCESS 0 // Viagens Extras
	ADD OPTION aRotina TITLE STR0058 ACTION "G900Ctr()"       OPERATION 2 ACCESS 0 // Visualizar contrato
	ADD OPTION aRotina TITLE STR0084 ACTION aRevisa	   		  OPERATION 2 ACCESS 0 // SubMenu - Revisões
	ADD OPTION aRotina TITLE STR0085 ACTION 'G900GerRev()'    OPERATION 2 ACCESS 0 // "Efetivar Revisão"
	ADD OPTION aRotina TITLE STR0104 ACTION 'GTPX900R()'	  OPERATION 8 ACCESS 0 // Impressão do Contrato
	ADD OPTION aRotina TITLE STR0107 ACTION 'G900VESLin()'    OPERATION 3 ACCESS 0 // Viagens Extra Sem Linha
	ADD OPTION aRotina TITLE STR0109 ACTION 'GTPA900B()'	  OPERATION 8 ACCESS 0 // Documentos Operacionais
	ADD OPTION aRotina TITLE STR0110 ACTION 'GTPA900C()'	  OPERATION 8 ACCESS 0 // Checklist Documentos Operacionais


Return aRotina

/*/{Protheus.doc} ModelDef
	(long_description)
	@type  Function
	@author Lucivan Severo Correia
	@since 25/06/2020
	@version 1
	@param param_name, param_type, param_descr
	@return oModel, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function ModelDef()
	Local oModel
	Local oStruGY0      := FWFormStruct(1,"GY0")//cabeçalho cadastral
	Local oStruGYD      := FWFormStruct(1,"GYD")//dados da linha
	Local oStruGQJ      := FWFormStruct(1,"GQJ")//Custos adicionais Cadastral
	Local oStruGYX      := FWFormStruct(1,"GYX")//custos adicionais linha
	Local oStruGQZ      := FWFormStruct(1,"GQZ")//custos operacionais
	Local oStruGQI      := FWFormStruct(1,"GQI")//itinerarios
	Local oStruGQ8      := FWFormStruct(1,"GQ8")//Lista de Passageiros - Header
	Local oStruGQB      := FWFormStruct(1,"GQB")//Lista de Passageiros - Detail
	Local oStruGYY      := FWFormStruct(1,"GYY")//Reajuste de Contrato
	Local bPreGYD       := { |oModel, nLine, cOperation, cField, uValue| GYDLnPre(oModel, nLine, cOperation, cField, uValue)}
	Local bPreGQI       := { |oModel, nLine, cOperation, cField, uValue| GQILnPre(oModel, nLine, cOperation, cField, uValue)}
	Local bPosValid     := { |oModel|PosValid(oModel)}	
	Local oStrTot       := FWFormModelStruct():New()
	Local cMsgErro		:= ''
	Local lHasNewTables := ChkFile('GY0') .AND. ChkFile('GYD') .AND. ChkFile('GQI');
						   .AND. ChkFile('GQZ') .AND. ChkFile('GYX') .AND. ChkFile('GQJ');
						   .AND. ChkFile('GYY')
	Local bCommit		:= {|oModel| G900Commit(oModel)}
	
	If lHasNewTables .And. ValidaDic(@cMsgErro)

		SetModelStruct(oStruGY0,oStruGYD,oStruGQJ,oStruGYX,oStruGQZ,oStruGQI,oStruGYY,oStrTot)

		oModel := MPFormModel():New("GTPA900", /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )
		oModel:setDescription(STR0007) //"Orçamento de Contrato"

		oModel:addFields("GY0MASTER",,oStruGY0)
		oModel:AddFields("GYYFIELDS","GY0MASTER", oStruGYY,/*bPre*/,/*bPos*/)

		oModel:AddGrid("GQJDETAIL" , "GY0MASTER"  , oStruGQJ)
		oModel:AddGrid("GYDDETAIL" , "GY0MASTER"  , oStruGYD, bPreGYD)
		oModel:AddGrid("GQIDETAIL" , "GYDDETAIL"  , oStruGQI, bPreGQI)
		oModel:AddGrid("GYXDETAIL" , "GYDDETAIL"  , oStruGYX)
		oModel:AddGrid("GQZDETAIL" , "GYDDETAIL"  , oStruGQZ)

		oModel:AddGrid("GQ8DETAIL" , "GYDDETAIL"  , oStruGQ8)
		oModel:AddGrid("GQBDETAIL" , "GQ8DETAIL"  , oStruGQB)
		
		oModel:getModel("GY0MASTER"):SetDescription(STR0008) //"Dados do Orçamento de Contrato"
		oModel:getModel('GQJDETAIL'):SetDescription(STR0010) //"Custos"		
		oModel:getModel("GYDDETAIL"):SetDescription(STR0009) //"Itinerários"
		oModel:getModel("GQIDETAIL"):SetDescription(STR0011) //"Percurso"
		oModel:getModel('GYXDETAIL'):SetDescription(STR0010) //"Custos"
		oModel:getModel('GQZDETAIL'):SetDescription(STR0010) //"Custos"

		If GY0->(FieldPos("GY0_FILIAL")) > 0 .AND. GY0->(FieldPos("GY0_NUMERO")) > 0
			oModel:SetPrimaryKey({"GY0_FILIAL","GY0_NUMERO","GY0_REVISA"})
		EndIf

		If GQJ->(FieldPos("GQJ_FILIAL")) > 0 .AND. GQJ->(FieldPos("GQJ_CODIGO")) > 0 
		oModel:SetRelation("GQJDETAIL", ;
			{{"GQJ_FILIAL",'xFilial("GQJ")'},;
			 {"GQJ_CODIGO","GY0_NUMERO"},;
			 {"GQJ_REVISA","GY0_REVISA"}})
		EndIf

		If GYD->(FieldPos("GYD_FILIAL")) > 0 .AND. GYD->(FieldPos("GYD_NUMERO")) > 0
		oModel:SetRelation("GYDDETAIL", ;
			{{"GYD_FILIAL",'xFilial("GYD")'},;
			 {"GYD_NUMERO","GY0_NUMERO"  },;
			 {"GYD_REVISA","GY0_REVISA" }},GYD->(IndexKey(1)))
		EndIf

		If GQI->(FieldPos("GQI_FILIAL")) > 0 .AND. GQI->(FieldPos("GQI_CODIGO")) > 0
		oModel:SetRelation("GQIDETAIL", ;
			{{"GQI_FILIAL",'xFilial("GQI")'},;
			{"GQI_CODIGO","GY0_NUMERO"},;
			{"GQI_REVISA","GY0_REVISA"},;
			{"GQI_ITEM  ","GYD_CODGYD"}})
		EndIf

		If GYX->(FieldPos("GYX_FILIAL")) > 0 .AND. GYX->(FieldPos("GYX_CODIGO")) > 0 
		oModel:SetRelation("GYXDETAIL", ;
			{{"GYX_FILIAL",'xFilial("GYX")'},;
			{"GYX_CODIGO","GY0_NUMERO"},;
			{"GYX_REVISA","GY0_REVISA" },;
			{"GYX_ITEM  ","GYD_CODGYD"}})
		EndIf

		If GQZ->(FieldPos("GQZ_FILIAL")) > 0 .AND. GQZ->(FieldPos("GQZ_CODIGO")) > 0
		oModel:SetRelation("GQZDETAIL", ;
			{{"GQZ_FILIAL",'xFilial("GQZ")'},;
			{"GQZ_CODIGO","GY0_NUMERO"},;
			{"GQZ_REVISA","GY0_REVISA" },;
			{"GQZ_ITEM  ","GYD_CODGYD"}})
		EndIf

		If GQ8->(FieldPos("GQ8_FILIAL")) > 0 .AND. GQ8->(FieldPos("GQ8_CODGY0")) > 0 .AND. GQ8->(FieldPos("GQ8_CODGYD")) > 0
		oModel:SetRelation("GQ8DETAIL", ;
			{{"GQ8_FILIAL",'xFilial("GQ8")'},;
			{"GQ8_CODGY0","GYD_NUMERO"}, ;
			{"GQ8_CODGYD","GYD_CODGYD"}})
		EndIf

		If GQB->(FieldPos("GQB_FILIAL")) > 0 .AND. GQB->(FieldPos("GQB_CODIGO")) > 0
		oModel:SetRelation("GQBDETAIL", ;
			{{"GQB_FILIAL",'xFilial("GQB")'},;
			{"GQB_CODIGO","GQ8_CODIGO"}})
		EndIf

		If GQB->(FieldPos("GQB_FILIAL")) > 0 .AND. GQB->(FieldPos("GQB_CODIGO")) > 0
		oModel:SetRelation("GQBDETAIL", ;
			{{"GQB_FILIAL",'xFilial("GQB")'},;
			{"GQB_CODIGO","GQ8_CODIGO"}})
		EndIf

		oModel:SetRelation("GYYFIELDS",;
			{{"GYY_FILIAL",'xFilial("GY0")'},;
			{"GYY_NUMERO","GY0_NUMERO"},;
			{"GYY_REVISA","GY0_REVISA"}},GYY->(IndexKey(1)))

		oModel:GetModel('GQBDETAIL'):SetDelAllLine(.T.)

		oModel:SetOptional("GYDDETAIL", .T. )
		oModel:SetOptional("GQIDETAIL", .T. )
		oModel:SetOptional("GQJDETAIL", .T. )
		oModel:SetOptional("GYXDETAIL", .T. )
		oModel:SetOptional("GQZDETAIL", .T. )
		oModel:SetOptional("GQ8DETAIL", .T. )
		oModel:SetOptional("GQBDETAIL", .T. )
		oModel:SetOptional("GYYFIELDS", .T. )
		
	Else
		FwAlertHelp(cMsgErro, STR0017) // "Banco de dados desatualizado, não é possível iniciar a rotina"
	EndIf

	oModel:SetCommit(bCommit)

Return oModel

/*/{Protheus.doc} PosValid
(long_description)
@type  Static Function
@author Teixeira
@since 20/08/2020
@version 1.0
@param oModel, objeto, param_descr
@return lRet, Lógico, Lógico
@example
(examples)
@see (links_or_references)
/*/
Static Function PosValid(oModel)

Local oMdlGY0	:= oModel:GetModel('GY0MASTER')
Local oMdlGYD	:= oModel:GetModel('GYDDETAIL')
Local oMdlGQI	:= oModel:GetModel('GQIDETAIL')
Local lRet	    := .T.
Local nGqi      := 0
Local nGyd      := 0

Local cMsgErro	:= ""
Local cMsgSoluc	:= ""
Local cField	:= ""

Local aRIdaVlta	:={}

If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	
	For nGyd := 1 To oMdlGYD:Length()
		
		If !oMdlGYD:IsDeleted(nGyd)
			oMdlGYD:GoLine(nGyd)

			nGqi:= oMdlGQI:Length()
			While nGqi > 1
				If !oMdlGQI:IsDeleted(nGqi)
					oMdlGQI:GoLine(nGqi)
					lRet := (oMdlGQI:GetValue("GQI_CODDES",nGqi) == oMdlGYD:GetValue("GYD_LOCFIM",nGyd)) .OR.(oMdlGYD:GetValue("GYD_SENTID",nGyd) == '3' )
					EXIT
				EndIf
				nGqi--
			End

			If !lRet 
				Help(,,"PosValid",, STR0026, 1,0)//"Necessário que a ultima linha do itnerario finalize com a localidade final da linha"
			Else
				
				If GYD->(FieldPos('GYD_PLCONV')) > 0 .And. ( oMdlGYD:GetValue("GYD_PLCONV",nGYD) != "1"; 
					.And. Empty(oMdlGYD:GetValue("GYD_VLRTOT",nGYD)) )

					lRet := .F.	

					cMsgErro  := STR0116 //"Foi optado por não utilizar a planilha de custos para a composição do valor convecionado. Entretanto, esse valor está zerado."
					cMsgSoluc := STR0117
					
					cField := "GYD_VLRTOT"

				ElseIf GYD->(FieldPos('GYD_PLCONV')) > 0 .And. ( oMdlGYD:GetValue("GYD_PLCONV",nGYD) == "1"; 
					.And. Empty(oMdlGYD:GetValue("GYD_IDPLCO",nGYD)) )

					cMsgErro := STR0118 //"Foi optado por utilizar a planilha de custos para a composição do valor convecionado.Entretanto, nenhuma planilha foi escolhida."
					
					cMsgSoluc := STR0119 //"Preencha o campo [Id.Pl.Conven] com o identificar de alguma planilha de custos."
					
					cField := "GYD_IDPLCO"

					lRet := .F.

				EndIf
				
				If ( lRet .And. !Empty(oMdlGYD:GetValue("GYD_PREEXT",nGYD));
					.And. GYD->(FieldPos('GYD_PLEXTR')) > 0 .And. oMdlGYD:GetValue("GYD_PLEXTR",nGYD) != "1"; 
					.And. Empty(oMdlGYD:GetValue("GYD_VLREXT",nGYD)) )

					lRet := .F.	

					cMsgErro := STR0120 //"Foi optado por não utilizar a planilha de custos para a composição do valor extra. Entretanto, esse valor está zerado."
					
					cMsgSoluc := STR0121 //"Preencha o campo [Valor Extra] com um valor maior que 0,00"
					
					cField := "GYD_VLREXT"
				
					// Exit
				ElseIf GYD->(FieldPos('GYD_PLEXTR')) > 0 .And. ( oMdlGYD:GetValue("GYD_PLEXTR",nGYD) == "1"; 
					.And. Empty(oMdlGYD:GetValue("GYD_IDPLEX",nGYD)) )
					
					lRet := .F.	

					cMsgErro := STR0122 //"Foi optado por utilizar a planilha de custos para a composição do valor extra. Entretanto, nenhuma planilha foi escolhida."
					
					cMsgSoluc := STR0023 //"Preencha o campo [Id.Pl.Extra] com o identificar de alguma planilha de custos."
					
					cField := "GYD_IDPLEX"
				
				EndIf
				
				If lRet .And. oMdlGYD:GetValue("GYD_SENTID",nGYD) == '3'
					aRIdaVlta:=(G900ValIdaVolta(oMdlGQI))
					If !(aRIdaVlta[1])
						cMsgErro := aRIdaVlta[2]
						cMsgSoluc:= aRIdaVlta[3]
						lRet:= .F.
					EndIf
				EndIf

				If lRet .AND. GY0->(FieldPos('GY0_DTINIC'))
					If oMdlGYD:GetValue("GYD_INIVIG",nGYD) < oMdlGY0:GetValue('GY0_DTINIC')
						cMsgErro := STR0124 //'A Data do Inicio da Vigência da Linha não pode ser menor que a data de Inicio do Contrato.'
						cMsgSoluc:= STR0125 + DToC(oMdlGY0:GetValue('GY0_DTINIC')) + STR0126 + DToC(oMdlGY0:GetValue('GY0_DTVIGE'))//'Defina um ínicio de Vigência de Linha entre o Inicio do Contrato: ' // ' e a Vigência do Contrato: '
						lRet:= .F.
					EndIf
				EndIf

				If lRet .AND. GY0->(FieldPos('GY0_DTVIGE'))
					If oMdlGYD:GetValue("GYD_INIVIG",nGYD) > oMdlGY0:GetValue('GY0_DTVIGE')
						cMsgErro := STR0127 //'A Data do Fim da Vigência da Linha não pode ser maior que a data de Vigência do Contrato.'
						cMsgSoluc:= STR0128 + DToC(oMdlGY0:GetValue('GY0_DTINIC')) + STR0126 + DToC(oMdlGY0:GetValue('GY0_DTVIGE'))//'Defina um fim de Vigência de Linha entre o Inicio do Contrato: '
						lRet:= .F.
					EndIf
				EndIf
				If lRet .AND. oMdlGY0:HasField('GY0_DTVORC')
					If !(oMdlGY0:GetValue('GY0_DTVORC') >= dDataBase)
						cMsgErro := STR0141 //'Verifique a data de validade do Orçamento do contrato'
						cMsgSoluc:= STR0142 //'A data deve ser maior ou igual a Data do Sistema'
						lRet := .F.
					EndIf
				EndIf
				
				If ( lRet )
					
					For nGQI := 1 to oMdlGQI:Length()
						
						If ( !(oMdlGQI:IsDeleted()) )

							lRet := WrongWay(oModel,oMdlGQI:GetValue("GQI_SENTID",nGQI),@cMsgErro,nGQI,nGYD)
							
							If (!lRet)
								cMsgSoluc := "Para Linhas de único sentido, os trechos devem possuir o mesmo sentido."
								Exit
							EndIf

						EndIf

					Next nGQI

				EndIf

				If (!lRet)
					oModel:SetErrorMessage(oMdlGYD:GetId(),cField,oMdlGYD:GetId(),cField,"PosValid",cMsgErro,cMsgSoluc)//,cNewValue,cOldValue)
					Exit
				EndIf
			EndIf
		EndIf	

	Next nGyd

EndIf

Return lRet

/*/{Protheus.doc} GYDLnPre
(long_description)
@type  Static Function
@author Teixeira
@since 01/10/2019
@version version
@param oModelGYD, param_type, param_descr
@param nLine, param_type, param_descr
@param cOperation, param_type, param_descr
@param cField, param_type, param_descr
@param uValue, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GYDLnPre(oModel, nLine, cOperation, cField, uValue)
Local lRet      := .T.
Local nCnt      := 0
Local cMsgTitu  := ""
Local cMsgErro  := ""
Local oMdl      := FwModelActive()
Local oModelGYD := oMdl:GetModel("GYDDETAIL")
Local oModelGQI := oMdl:GetModel("GQIDETAIL")
Local oModelGYX := oMdl:GetModel("GYXDETAIL")
Local oModelGQZ := oMdl:GetModel("GQZDETAIL")

IF (cOperation == "DELETE") 
    
    If oModelGQI:Length() > 0
        nCnt:= oModelGQI:Length()
		While nCnt > 0
			If !oModelGQI:IsDeleted(nCnt)
				oModelGQI:Goline(nCnt)
				oModelGQI:DeleteLine(.T.)
			EndIf
			nCnt--
		End
	EndIf
	
	If oModelGYX:Length() > 0
        For nCnt := 1 To oModelGYX:Length()
            If !oModelGYX:IsDeleted(nCnt)
                oModelGYX:Goline(nCnt)
                oModelGYX:DeleteLine(.T.)
            EndIf
        Next nCnt
	EndIf
	If oModelGQZ:Length() > 0
        For nCnt := 1 To oModelGQZ:Length()
            If !oModelGQZ:IsDeleted(nCnt)
                oModelGQZ:Goline(nCnt)
                oModelGQZ:DeleteLine(.T.)
            EndIf
        Next nCnt
	EndIf
ELSEIF (cOperation == "UNDELETE")
    
    If oModelGQI:Length() > 0
        For nCnt := 1 To oModelGQI:Length()
            If oModelGQI:IsDeleted(nCnt)
                oModelGQI:Goline(nCnt)
                oModelGQI:UnDeleteLine(.T.)
            EndIf
        Next nCnt
	EndIf
	If oModelGYX:Length() > 0
        For nCnt := 1 To oModelGYX:Length()
            If oModelGYX:IsDeleted(nCnt)
                oModelGYX:Goline(nCnt)
                oModelGYX:UnDeleteLine(.T.)
            EndIf
        Next nCnt
	EndIf
	If oModelGQZ:Length() > 0
        For nCnt := 1 To oModelGQZ:Length()
            If oModelGQZ:IsDeleted(nCnt)
                oModelGQZ:Goline(nCnt)
                oModelGQZ:UnDeleteLine(.T.)
            EndIf
        Next nCnt
	EndIf
ELSEIF (cOperation == "SETVALUE" .AND. cField == "GYD_LOCFIM")
    lRet := !(oModelGYD:SeekLine({{'GYD_LOCINI',oModelGYD:GetValue("GYD_LOCINI")},{'GYD_LOCFIM',uValue}}))
	If !lRet .AND. oModelGYD:GetLine() != nLine
		cMsgTitu := STR0027//"Linha duplicada"
		cMsgErro := STR0028//"Sequência já utilizada"
		Help(,,cMsgTitu,, cMsgErro, 1,0)
	EndIf

ENDIF

Return lRet

/*/{Protheus.doc} GQILnPre
(long_description)
@type  Static Function
@author Teixeira
@since 01/10/2019
@version version
@param oModelGYD, param_type, param_descr
@param nLine, param_type, param_descr
@param cOperation, param_type, param_descr
@param cField, param_type, param_descr
@param uValue, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GQILnPre(oModel, nLine, cOperation, cField, uValue)
Local lRet      := .T.
Local nCnt      := 0
Local nTamGrid  := 0
Local nLinhaAtu := 0
Local cMsgTitu  := ""
Local cMsgErro  := ""
Local oMdl      := FwModelActive()
Local oMdlGQI   := oMdl:GetModel("GQIDETAIL")

IF (cOperation == "DELETE") 
    
	nCnt:= oMdlGQI:Length()
	While nCnt > 1
		If !oMdlGQI:IsDeleted(nCnt)
			nTamGrid := nCnt
			EXIT
		EndIf
		nCnt--
	End
	If nLine != nTamGrid .AND. nTamGrid > 0
		lRet:= .F.
		cMsgTitu := STR0029//"Alteração indevida"
		cMsgErro := STR0030//"Não pode alterar, por não ser ultima linha."
		Help(,,cMsgTitu,, cMsgErro, 1,0)
	EndIf
ELSEIF (cOperation == "UNDELETE")
    
    nCnt:= oMdlGQI:Length()
	While nCnt > 1
		If !oMdlGQI:IsDeleted(nCnt)
			nTamGrid := nCnt
			EXIT
		EndIf
		nCnt--
	End
	If nLine != nTamGrid .AND. nTamGrid > 0 .AND. nLinhaAtu > 0
		lRet:= .F.
		cMsgTitu := STR0029//"Alteração indevida"
		cMsgErro := STR0030//"Não pode alterar, por não ser ultima linha."
		Help(,,cMsgTitu,, cMsgErro, 1,0)
	EndIf
ELSEIF (cOperation == "SETVALUE" .AND. cField == "GQI_CODDES")
    nCnt:= oMdlGQI:Length()
	While nCnt > 1
		If !oMdlGQI:IsDeleted(nCnt)
			nTamGrid := nCnt
			EXIT
		EndIf
		nCnt--
	End
	If nLine != nTamGrid .AND. nTamGrid > 0 .AND. nLinhaAtu > 0
		lRet:= .F.
		cMsgTitu := STR0029//"Alteração indevida"
		cMsgErro := STR0030//"Não pode alterar, por não ser ultima linha."
		Help(,,cMsgTitu,, cMsgErro, 1,0)
	EndIf

ENDIF

Return lRet

/*/{Protheus.doc} SetModelStruct
	(long_description)
	@type  Static Function
	@author Teixeira
	@since 18/08/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function SetModelStruct(oStruGY0,oStruGYD,oStruGQJ,oStruGYX,oStruGQZ,oStruGQI,oStruGYY,oStrTot)

	Local aArea     := GetArea()
	Local aTrigAux  := {}
	Local bInit	    := {|oMdl,cField,uVal| FieldInit(oMdl,cField,uVal)}
	Local bTrig     := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
	Local bFldWhen	:= {|oMdl,cField,uVal| FieldWhen(oMdl,cField,uVal) } 
	Local bFldVld	:= {|oMdl,cField,uVal,nLine,uOldValue| FieldValid(oMdl,cField,uVal,nLine,uOldValue)}
	
	Local lHasFields:= .F.

	If GQZ->(FieldPos("GQZ_CODCLI")) > 0
		oStruGQZ:RemoveField("GQZ_CODCLI")
	EndIf
	If GQZ->(FieldPos("GQZ_CODLOJ")) > 0
		oStruGQZ:RemoveField("GQZ_CODLOJ")
	EndIf
	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek( "GQZ_NOMCLI"))
		oStruGQZ:RemoveField("GQZ_NOMCLI")
	EndIf

	If GY0->(FieldPos("GY0_CODVD")) > 0
		oStruGY0:AddTrigger("GY0_CODVD","GY0_CODVD",{||.T.},bTrig)	
	EndIf
	
	If GY0->(FieldPos("GY0_DTINIC")) > 0
		oStruGY0:AddTrigger("GY0_DTINIC","GY0_DTINIC",{||.T.},bTrig)	
	EndIf

	If GY0->(FieldPos("GY0_VIGE")) > 0
		oStruGY0:AddTrigger("GY0_VIGE","GY0_VIGE",{||.T.},bTrig)
	EndIf
	
	If GY0->(FieldPos("GY0_UNVIGE")) > 0
		oStruGY0:AddTrigger("GY0_UNVIGE","GY0_UNVIGE",{||.T.},bTrig)	
	EndIf

	If GY0->(FieldPos("GY0_UNORCV")) > 0
		oStruGY0:AddTrigger("GY0_UNORCV","GY0_UNORCV",{||.T.},bTrig)	
	EndIf

	If GY0->(FieldPos("GY0_VALORC")) > 0
		oStruGY0:AddTrigger("GY0_VALORC","GY0_VALORC",{||.T.},bTrig)	
	EndIf

	If GY0->(FieldPos("GY0_DTVIGE")) > 0
		oStruGY0:AddTrigger("GY0_DTVIGE","GY0_DTVIGE",{||.T.},bTrig)
	EndIf

	If GY0->(FieldPos("GY0_DTVORC")) > 0
		oStruGY0:AddTrigger("GY0_DTVORC","GY0_DTVORC",{||.T.},bTrig)
	EndIf

	If GY0->(FieldPos("GY0_ALTLOG")) > 0
		oStruGY0:SetProperty("GY0_ALTLOG", MODEL_FIELD_WHEN, bFldWhen)	
	EndIf

	If GQZ->(FieldPos("GQZ_INIVIG")) > 0
		oStruGQZ:RemoveField("GQZ_INIVIG")
	EndIf
	If GQZ->(FieldPos("GQZ_FIMVIG")) > 0
		oStruGQZ:RemoveField("GQZ_FIMVIG")
	EndIf
	If GQZ->(FieldPos("GQZ_TPDESC"))  > 0
		oStruGQZ:RemoveField("GQZ_TPDESC")
	EndIf
	If GQZ->(FieldPos("GQZ_VALOR")) > 0
		oStruGQZ:RemoveField("GQZ_VALOR")
	EndIf
	If GQZ->(FieldPos("GQZ_TIPCUS")) > 0
		oStruGQZ:RemoveField("GQZ_TIPCUS")
	EndIf

	If GY0->(FieldPos("GY0_DTINIC")) > 0
		oStruGY0:SetProperty('GY0_DTINIC',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_UNVIGE")) > 0
		oStruGY0:SetProperty('GY0_UNVIGE',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_MOEDA")) > 0
		oStruGY0:SetProperty('GY0_MOEDA' ,MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_CONDPG")) > 0
		oStruGY0:SetProperty('GY0_CONDPG',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_TPCTO")) > 0
		oStruGY0:SetProperty('GY0_TPCTO' ,MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_FLGREJ")) > 0
		oStruGY0:SetProperty('GY0_FLGREJ',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_FLGCAU")) > 0
		oStruGY0:SetProperty('GY0_FLGCAU',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_CLIENT")) > 0
		oStruGY0:SetProperty('GY0_CLIENT',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_LOJACL")) > 0
		oStruGY0:SetProperty('GY0_LOJACL',MODEL_FIELD_OBRIGAT, .T. )
		oStruGY0:SetProperty('GY0_LOJACL', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_CODVD")) > 0
		oStruGY0:SetProperty('GY0_CODVD',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_TABPRC")) > 0
		oStruGY0:SetProperty('GY0_TABPRC',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_TIPPLA")) > 0
		oStruGY0:SetProperty('GY0_TIPPLA',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	If GY0->(FieldPos("GY0_PRODUT")) > 0
		oStruGY0:SetProperty('GY0_PRODUT',MODEL_FIELD_OBRIGAT, .T. )
	EndIf
	
	If GY0->(FieldPos("GY0_CODCN9")) > 0
		oStruGY0:SetProperty('GY0_CODCN9',MODEL_FIELD_OBRIGAT, .F. )
	EndIf

	oStruGQJ:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruGYX:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruGQZ:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)

	If GYD->(FieldPos("GYD_PRECON")) > 0	
		oStruGYD:SetProperty('GYD_PRECON', MODEL_FIELD_OBRIGAT, .T.)
	EndIf
	If GYD->(FieldPos("GYD_NUMCAR")) > 0
	 	oStruGYD:SetProperty('GYD_NUMCAR', MODEL_FIELD_OBRIGAT, .T.)
	EndIf

	If GY0->(FieldPos("GY0_PRODUT")) > 0
		oStruGY0:AddTrigger("GY0_PRODUT","GY0_PRODUT",{||.T.},bTrig)	
	EndIf
	
	If GY0->(FieldPos("GY0_CODVD")) > 0
		oStruGY0:AddTrigger("GY0_CODVD","GY0_CODVD",{||.T.},bTrig)	
	EndIf

	If oStruGY0:HasField("GY0_LOJACL") 
		oStruGY0:AddTrigger("GY0_LOJACL","GY0_LOJACL",{||.T.},bTrig)	
	EndIf

	If oStruGYD:HasField("GYD_LOJACL") 
		oStruGYD:AddTrigger("GYD_LOJACL","GYD_LOJACL",{||.T.},bTrig)	
	EndIf


	If GYD->(FieldPos("GYD_ORGAO")) > 0
		oStruGYD:AddTrigger("GYD_ORGAO","GYD_ORGAO",{||.T.},bTrig)	
	EndIf
	If GYD->(FieldPos("GYD_LOCINI")) > 0 .AND. SX3->(dbSeek( "GYD_DLOCIN"))
		aTrigAux := FwStruTrigger("GYD_LOCINI", "GYD_DLOCIN", "Posicione('GI1',1,xFilial('GI1') + FwFldGet('GYD_LOCINI'), 'GI1_DESCRI')")
		oStruGYD:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
	EndIf
	If GYD->(FieldPos("GYD_LOCFIM")) > 0 .AND. SX3->(dbSeek( "GYD_DLOCFI"))
		aTrigAux := FwStruTrigger("GYD_LOCFIM", "GYD_DLOCFI", "Posicione('GI1',1,xFilial('GI1') + FwFldGet('GYD_LOCFIM'), 'GI1_DESCRI')")
		oStruGYD:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
	EndIf

	If GYD->(FieldPos("GYD_LOCFIM")) > 0
		oStruGYD:AddTrigger("GYD_LOCFIM","GYD_LOCFIM",{||.T.},bTrig)	
	EndIf
	
	If oStruGYD:HasField("GYD_TPCARR") 
		oStruGYD:AddTrigger("GYD_TPCARR","GYD_TPCARR",{||.T.},bTrig)	
	EndIf

	If GYD->(FieldPos("GYD_PRODUT")) > 0
		oStruGYD:AddTrigger("GYD_PRODUT","GYD_PRODUT",{||.T.},bTrig)	
	EndIf
	If GYD->(FieldPos("GYD_PRONOT")) > 0
		oStruGYD:AddTrigger("GYD_PRONOT","GYD_PRONOT",{||.T.},bTrig)	
	EndIf
	If GYD->(FieldPos("GYD_PRECON")) > 0
		oStruGYD:AddTrigger("GYD_PRECON","GYD_PRECON",{||.T.},bTrig)	
	EndIf

	lHasFields := GYD->(FieldPos("GYD_PLCONV")) > 0; 
		.And. GYD->(FieldPos("GYD_PRECON")) > 0;
		.And. GYD->(FieldPos("GYD_PREEXT")) > 0;
		.And. GYD->(FieldPos("GYD_IDPLCO")) > 0; 
		.And. GYD->(FieldPos("GYD_PLEXTR")) > 0;
		.And. GYD->(FieldPos("GYD_IDPLEX")) > 0
		
	If ( lHasFields )
		oStruGYD:AddTrigger("GYD_PLCONV","GYD_PLCONV",{||.T.},bTrig)	
		oStruGYD:AddTrigger("GYD_PLEXTR","GYD_PLEXTR",{||.T.},bTrig)
		//Ajuste do When dos campos
		oStruGYD:SetProperty("GYD_VLRTOT", MODEL_FIELD_WHEN, bFldWhen)
		oStruGYD:SetProperty("GYD_VLREXT", MODEL_FIELD_WHEN, bFldWhen)
		oStruGYD:SetProperty("GYD_IDPLCO", MODEL_FIELD_WHEN, bFldWhen)
		oStruGYD:SetProperty("GYD_IDPLEX", MODEL_FIELD_WHEN, bFldWhen)
	EndIf

	lHasFields := GY0->(FieldPos("GY0_PLCONV")) > 0; 
					.And. GY0->(FieldPos("GY0_PREEXT")) > 0;
					.And. GY0->(FieldPos("GY0_IDPLCO")) > 0; 
					.And. GY0->(FieldPos("GY0_PRDEXT")) > 0; 
					.And. GY0->(FieldPos("GY0_PRONOT")) > 0;
					.And. GY0->(FieldPos("GY0_PLCONV")) > 0;

	If ( lHasFields )
		oStruGY0:AddTrigger("GY0_PLCONV","GY0_PLCONV",{||.T.},bTrig)
		oStruGY0:AddTrigger("GY0_PRDEXT","GY0_PRDEXT",{||.T.},bTrig)
		oStruGY0:AddTrigger("GY0_PRONOT","GY0_PRONOT",{||.T.},bTrig)
		oStruGY0:AddTrigger("GY0_PREEXT","GY0_PREEXT",{||.T.},bTrig)

		//Ajuste do When dos campos
		oStruGY0:SetProperty("GY0_IDPLCO", MODEL_FIELD_WHEN, bFldWhen)
		oStruGY0:SetProperty("GY0_VLRACO", MODEL_FIELD_WHEN, bFldWhen)
		oStruGY0:SetProperty("GY0_PREEXT", MODEL_FIELD_WHEN, bFldWhen)
		oStruGY0:SetProperty("GY0_PLCONV", MODEL_FIELD_WHEN, bFldWhen)	
	EndIf

	If GQJ->(FieldPos("GQJ_CUSUNI")) > 0
		oStruGQJ:AddTrigger("GQJ_CUSUNI","GQJ_CUSUNI",{||.T.},bTrig)	
	EndIf
	If GQJ->(FieldPos("GQJ_QUANT")) > 0
		oStruGQJ:AddTrigger("GQJ_QUANT","GQJ_QUANT",{||.T.},bTrig)	
	EndIf
	If GQJ->(FieldPos("GQJ_UN")) > 0
		oStruGQJ:AddTrigger("GQJ_UN","GQJ_UN",{||.T.},bTrig)	
	EndIf
	If GYX->(FieldPos("GYX_CUSUNI")) > 0
		oStruGYX:AddTrigger("GYX_CUSUNI","GYX_CUSUNI",{||.T.},bTrig)	
	EndIf
	If GYX->(FieldPos("GYX_QUANT")) > 0
		oStruGYX:AddTrigger("GYX_QUANT","GYX_QUANT",{||.T.},bTrig)	
	EndIf
	If GYX->(FieldPos("GYX_UM")) > 0
		oStruGYX:AddTrigger("GYX_UM","GYX_UM",{||.T.},bTrig)	
	EndIf
	If GQZ->(FieldPos("GQZ_CUSUNI")) > 0
		oStruGQZ:AddTrigger("GQZ_CUSUNI","GQZ_CUSUNI",{||.T.},bTrig)	
	EndIf
	If GQZ->(FieldPos("GQZ_QUANT")) > 0
		oStruGQZ:AddTrigger("GQZ_QUANT","GQZ_QUANT",{||.T.},bTrig)	
	EndIf
	If GQZ->(FieldPos("GQZ_UM")) > 0
		oStruGQZ:AddTrigger("GQZ_UM","GQZ_UM",{||.T.},bTrig)	
	EndIf
	If GQJ->(FieldPos("GQJ_CODGIM")) > 0
		oStruGQJ:AddTrigger("GQJ_CODGIM", "GQJ_CODGIM", {||.T.},bTrig)
	EndIf
	If GYX->(FieldPos("GYX_CODGIM")) > 0
		oStruGYX:AddTrigger("GYX_CODGIM", "GYX_CODGIM", {||.T.},bTrig)
	EndIf

	If GY0->(FieldPos("GY0_VLRACO")) > 0
		oStruGY0:AddTrigger("GY0_VLRACO" , "GY0_VLRACO", {||.T.},bTrig)
	EndIf

	oStruGYD:AddTrigger("GYD_VLRTOT", "GYD_VLRTOT", {||.T.},bTrig)
	oStruGYD:AddTrigger("GYD_VLREXT", "GYD_VLREXT", {||.T.},bTrig)
	oStruGYX:AddTrigger("GYX_VALTOT", "GYX_VALTOT", {||.T.},bTrig)
	oStruGQZ:AddTrigger("GQZ_VALTOT", "GQZ_VALTOT", {||.T.},bTrig)
	oStruGQJ:AddTrigger("GQJ_VALTOT", "GQJ_VALTOT", {||.T.},bTrig)
		
	If GYD->(FieldPos("GYD_PRODUT")) > 0
		oStruGYD:SetProperty('GYD_PRODUT', MODEL_FIELD_VALID, bFldVld)
	EndIf
	If GYD->(FieldPos("GYD_PRONOT")) > 0
		oStruGYD:SetProperty('GYD_PRONOT', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GYD->(FieldPos("GYD_LOCINI")) > 0
		oStruGYD:SetProperty('GYD_LOCINI', MODEL_FIELD_VALID, bFldVld)
	EndIf


	If GYD->(FieldPos("GYD_LOCFIM")) > 0
		oStruGYD:SetProperty('GYD_LOCFIM', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GYD->(FieldPos("GYD_NUMCAR")) > 0
		oStruGYD:SetProperty('GYD_NUMCAR', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GQI->(FieldPos("GQI_CODORI")) > 0
		oStruGQI:AddTrigger("GQI_CODORI","GQI_CODORI",{||.T.},bTrig)	
	EndIf

	If GQI->(FieldPos("GQI_CODDES")) > 0
		oStruGQI:AddTrigger("GQI_CODDES","GQI_CODDES",{||.T.},bTrig)	
	EndIf

	If GQI->(FieldPos("GQI_CODDES")) > 0
		oStruGQI:SetProperty('GQI_CODDES', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GQJ->(FieldPos("GQJ_CODGIM")) > 0
		oStruGQJ:SetProperty('GQJ_CODGIM', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GYX->(FieldPos("GYX_CODGIM")) > 0
		oStruGYX:SetProperty('GYX_CODGIM', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_PRODUT")) > 0
		oStruGY0:SetProperty('GY0_PRODUT', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_VLRACO")) > 0
		oStruGY0:SetProperty('GY0_VLRACO', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_TPCTO")) > 0
		oStruGY0:SetProperty('GY0_TPCTO', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_TIPPLA")) > 0
		oStruGY0:SetProperty('GY0_TIPPLA', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_TIPREV")) > 0
		oStruGY0:SetProperty('GY0_TIPREV', MODEL_FIELD_VALID, bFldVld)
	EndIf

	If GY0->(FieldPos("GY0_REVISA")) > 0
		oStruGY0:SetProperty("GY0_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf

	If oStruGY0:HasField("GY0_NOMCLI") 
		oStruGY0:SetProperty("GY0_NOMCLI" , MODEL_FIELD_INIT, bInit)
	EndIf

	If oStruGYD:HasField("GYD_NOMCLI") 
		oStruGYD:SetProperty("GYD_NOMCLI"	, MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'IIF(INCLUI, "",POSICIONE("SA1",1,XFILIAL("SA1") + GYD->GYD_CLIENT + GYD->GYD_LOJACL , "A1_NOME"))'))
	EndIf

	If oStruGY0:HasField("GY0_NOMVD") 
		oStruGY0:SetProperty("GY0_NOMVD" , MODEL_FIELD_INIT, bInit)
	EndIf

	If GY0->(FieldPos("GY0_ATIVO")) > 0
		oStruGY0:SetProperty("GY0_ATIVO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYD->(FieldPos("GYD_NUMERO")) > 0
		oStruGYD:SetProperty("GYD_NUMERO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYD->(FieldPos("GYD_REVISA")) > 0
		oStruGYD:SetProperty("GYD_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf

	If GYD->(FieldPos("GYD_NUMCAR")) > 0
		oStruGYD:SetProperty("GYD_NUMCAR" , MODEL_FIELD_INIT, bInit)
	EndIf
	
	If oStruGYD:HasField("GYD_DTIPLI") 
		oStruGYD:SetProperty("GYD_DTIPLI"	, MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'IIF(INCLUI, "",POSICIONE("GQC",1,XFILIAL("GQC") + GYD->GYD_TIPLIN , "GQC_DESCRI"))'))

	EndIf

	If oStruGYD:HasField("GYD_TIPLIN") 
		oStruGYD:AddTrigger("GYD_TIPLIN","GYD_TIPLIN",{||.T.},bTrig)	
	EndIf

	If oStruGYD:HasField("GYD_DESCAT") 
		oStruGYD:SetProperty("GYD_DESCAT"	, MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'IIF(INCLUI, "", POSICIONE("GYR", 1, XFILIAL("GYR") + GYD->GYD_TPCARR, "GYR_DESCRI"))'))
	EndIf

	If GQZ->(FieldPos("GQZ_CODIGO")) > 0
		oStruGQZ:SetProperty("GQZ_CODIGO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_NUMERO")) > 0
		oStruGYY:SetProperty("GYY_NUMERO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_PERGYD")) > 0
		oStruGYY:SetProperty("GYY_PERGYD" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_PERGQJ")) > 0
		oStruGYY:SetProperty("GYY_PERGQJ" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_PERGYX")) > 0
		oStruGYY:SetProperty("GYY_PERGYX" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_PERGQZ")) > 0
		oStruGYY:SetProperty("GYY_PERGQZ" , MODEL_FIELD_INIT, bInit)
	EndIf

	If GQZ->(FieldPos("GQZ_REVISA")) > 0
		oStruGQZ:SetProperty("GQZ_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQI->(FieldPos("GQI_CODIGO")) > 0
		oStruGQI:SetProperty("GQI_CODIGO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQI->(FieldPos("GQI_REVISA")) > 0
		oStruGQI:SetProperty("GQI_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYY->(FieldPos("GYY_REVISA")) > 0
		oStruGYY:SetProperty("GYY_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf

	If GYX->(FieldPos("GYX_CODIGO")) > 0
		oStruGYX:SetProperty("GYX_CODIGO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYX->(FieldPos("GYX_REVISA")) > 0
		oStruGYX:SetProperty("GYX_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQI->(FieldPos("GQI_ITEM")) > 0
		oStruGQI:SetProperty("GQI_ITEM" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GYX->(FieldPos("GYX_ITEM")) > 0
		oStruGYX:SetProperty("GYX_ITEM" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQZ->(FieldPos("GQZ_ITEM")) > 0
		oStruGQZ:SetProperty("GQZ_ITEM" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GY0->(FieldPos("GY0_MOEDA")) > 0
		oStruGY0:SetProperty("GY0_MOEDA" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQJ->(FieldPos("GQJ_CODIGO")) > 0
		oStruGQJ:SetProperty("GQJ_CODIGO" , MODEL_FIELD_INIT, bInit)
	EndIf
	If GQJ->(FieldPos("GQJ_REVISA")) > 0
		oStruGQJ:SetProperty("GQJ_REVISA" , MODEL_FIELD_INIT, bInit)
	EndIf

	If GY0->(FieldPos("GY0_TIPREV")) > 0
		oStruGY0:SetProperty("GY0_TIPREV", MODEL_FIELD_WHEN, bFldWhen)
	EndIf

	If GYD->(FieldPos("GYD_VLRACO")) > 0
		oStruGYD:SetProperty("GYD_VLRACO", MODEL_FIELD_WHEN, bFldWhen)
	EndIf

	If ValType(oStrTot) == "O"
		oStrTot:AddField(STR0051   ,STR0051 ,"TOTADIC"	,"N",09,2,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)//"Adicional" 
   	 	oStrTot:AddField(STR0052   ,STR0052 ,"TOTOPE"	,"N",09,2,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.) //"Operacional" 
		oStrTot:AddField(STR0053   ,STR0053 ,"TOTLINHA"	,"N",09,2,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.) //"Total"
		oStrTot:AddField(STR0054   ,STR0054 ,"VLRITEM"	,"N",09,2,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.) //"Vlr. Item"
		oStrTot:AddField(STR0055   ,STR0055 ,"VLREXTRA"	,"N",09,2,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.) //"Extra"
	Endif   
	
	If GQI->(FieldPos("GQI_SENTID")) > 0
		oStruGQI:SetProperty("GQI_SENTID", MODEL_FIELD_WHEN, bFldWhen)	
		oStruGQI:SetProperty("GQI_SENTID", MODEL_FIELD_INIT, bInit)	
		oStruGQI:SetProperty("GQI_SENTID" , MODEL_FIELD_VALID, bFldVld)

	EndIf
	
	If GYD->(FieldPos("GYD_LOTACA")) > 0
		oStruGYD:SetProperty("GYD_LOTACA",MODEL_FIELD_OBRIGAT,.T.)
	EndIF

RestArea(aArea)	
Return 

/*/{Protheus.doc} FieldInit
(long_description)
@type  Static Function
@author Teixeira
@since 24/07/2020
@version 1
@param oMdl, object, modelo
@param cField, caracter, campo
@return uRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldInit(oMdl,cField,uVal)

	Local uRet      := nil
	Local oModel	:= oMdl:GetModel()
	Local oModelGY0 := oModel:GetModel('GY0MASTER')
	Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT
	Local lRevisa	:= oModel:GetOperation() == 4
	Local aArea     := GetArea()
	Local oModelGYD := oModel:GetModel("GYDDETAIL")
	Local nLineGYD  := oModelGYD:GetLine()

	Do Case
	Case cField == "GY0_NUMERO"
		If lInsert
			uRet := GETSXENUM("GY0","GY0_NUMERO")
		ElseIf lRevisa
			uRet := GY0->GY0_NUMERO
		Endif
	Case cField == "GY0_REVISA" 
		If lRevisa
			uRet := SetRevisao(oModel)
		Else
			uRet := ''
		Endif
	Case cField == "GY0_NOMCLI"
			uRet := oModelGY0:GetValue("GY0_CLIENT") + oModelGY0:GetValue("GY0_LOJACL") 
			uRet := IIF(INCLUI, "", POSICIONE("SA1", 1, XFILIAL("SA1") + uRet , "A1_NOME") )
	Case cField == "GY0_NOMVD"
			uRet := oModelGY0:GetValue("GY0_CODVD")
			uRet := IIF(INCLUI, "", POSICIONE("SA3",1,XFILIAL("SA3") + uRet, "A3_NOME") )
	Case cField $ "GYD_REVISA|GQI_REVISA|GYX_REVISA|GQZ_REVISA|GQJ_REVISA|GYY_REVISA"
		uRet := oModelGY0:GetValue('GY0_REVISA') 
		If cField == 'GYY_REVISA' .And. lRevisa
			oModel:LoadValue('GYYFIELDS','GYY_PERGYD', 0)
			oModel:LoadValue('GYYFIELDS','GYY_PERGQJ', 0)
			oModel:LoadValue('GYYFIELDS','GYY_PERGYX', 0)
			oModel:LoadValue('GYYFIELDS','GYY_PERGQZ', 0)
		Endif
	Case cField $ "GYD_NUMERO|GQZ_CODIGO|GQI_CODIGO|GQJ_CODIGO|GYX_CODIGO|GYY_NUMERO"
		uRet := If(lInsert,FwFldGet("GY0_NUMERO"),GY0->GY0_NUMERO)
	Case cField == 'GY0_ATIVO' .And. lInsert	
		uRet := '1'
	Case cField == "GQI_ITEM"
		uRet := oModelGYD:GetValue("GYD_CODGYD",nLineGYD)
	Case cField == "GYX_ITEM"
		uRet := oModelGYD:GetValue("GYD_CODGYD",nLineGYD)
	Case cField == "GQZ_ITEM"
		uRet := oModelGYD:GetValue("GYD_CODGYD",nLineGYD)
	Case cField == "GY0_MOEDA"
		uRet := "1"
	Case cField $ "GYY_PERGYD|GYY_PERGQJ|GYY_PERGYX|GYY_PERGQZ"
		uRet := 0
	Case cField == 'GYD_NUMCAR'
		uRet := 1
	Case cField == 'GQI_SENTID'		
		uRet := ''
	EndCase

	RestArea(aArea)

Return uRet

/*/{Protheus.doc} FieldTrigger
//TODO Descrição auto-gerada.
@author Teixeira
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param uVal, undefined, descricao
@type function
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
Local uRet     := ""
Local n1       := 0
Local oModel   := FwModelActive()
Local oMdlGY0  := oModel:GetModel('GY0MASTER')
Local oMdlGYD  := oModel:GetModel('GYDDETAIL')
Local oMdlGQJ  := oModel:GetModel('GQJDETAIL')
Local oMdlGYX  := oModel:GetModel('GYXDETAIL')
Local oMdlGQI  := oModel:GetModel("GQIDETAIL")
Local oMdlGQZ  := oModel:GetModel("GQZDETAIL")
Local nLineGYD := oMdlGYD:GetLine()
Local nLineGQI := oMdlGQI:GetLine()
Local nLineGQJ := oMdlGQJ:GetLine()
Local nLineGYX := oMdlGYX:GetLine()
Local nLineGQZ := oMdlGQZ:GetLine()

Private cG900AltLog := ''

DbSelectArea("SX3")
SX3->(dbSetOrder(2))
	
Do Case
	Case cField == "GY0_PRODUT"
		If SX3->(dbSeek( "GY0_DSCPRD"))
			oMdlGY0:SetValue("GY0_DSCPRD", POSICIONE("SB1",1,XFILIAL("SB1") + uVal,"B1_DESC"))
		EndIf
	Case cField == 'GYD_LOCFIM'
		uRet := oMdlGYD:GetValue("GYD_LOCINI")
		oMdlGYD:GoLine(nLineGYD)
		If nLineGQI > 1
			For n1	:= 1 to oMdlGQI:Length()
				If !oMdlGQI:IsDeleted(n1)
					oMdlGQI:GoLine(n1)
					oMdlGQI:Deleteline()
				Endif
			Next
		EndIf
		If nLineGQI != 1
			oMdlGQI:AddLine()
		EndIf
        oMdlGQI:SetValue('GQI_CODORI',uRet)
		oMdlGQI:SetValue('GQI_CODDES',uVal)

	Case cField == "GY0_LOJACL"
			uRet := POSICIONE("SA1", 1, XFILIAL("SA1") + oMdlGY0:GetValue('GY0_CLIENT') + uVal, "A1_NOME")
			If oMdlGY0:HasField("GY0_NOMCLI") 
				oMdlGY0:SetValue('GY0_NOMCLI',uRet)
			EndIf

	Case cField == "GYD_LOJACL"
			uRet := POSICIONE("SA1", 1, XFILIAL("SA1") + oMdlGYD:GetValue('GYD_CLIENT') + uVal, "A1_NOME")
			If oMdlGYD:HasField("GYD_NOMCLI") 
				oMdlGYD:SetValue('GYD_NOMCLI',uRet)
			EndIf			
	Case cField == 'GQJ_CODGIM'
		TrigGIMPrd(oMdlGQJ, oMdlGY0:GetValue('GY0_PRODUT'), uVal)
	Case cField == 'GYX_CODGIM'
		TrigGIMPrd(oMdlGYX, oMdlGYD:GetValue('GYD_PRODUT'), uVal)
	Case cField = "GQJ_CUSUNI"
		uRet := oMdlGQJ:GetValue('GQJ_CUSUNI',nLineGQJ) * oMdlGQJ:GetValue('GQJ_QUANT',nLineGQJ)
		oMdlGQJ:SetValue('GQJ_VALTOT',uRet)
	Case cField = "GQJ_QUANT"
		uRet := oMdlGQJ:GetValue('GQJ_CUSUNI',nLineGQJ) * oMdlGQJ:GetValue('GQJ_QUANT',nLineGQJ)
		oMdlGQJ:SetValue('GQJ_VALTOT',uRet)
	Case cField = "GYX_CUSUNI"
		uRet := oMdlGYX:GetValue('GYX_CUSUNI',nLineGYX) * oMdlGYX:GetValue('GYX_QUANT',nLineGYX)
		oMdlGYX:SetValue('GYX_VALTOT',uRet)
	Case cField = "GYX_QUANT"
		uRet := oMdlGYX:GetValue('GYX_CUSUNI',nLineGYX) * oMdlGYX:GetValue('GYX_QUANT',nLineGYX)
		oMdlGYX:SetValue('GYX_VALTOT',uRet)
	Case cField = "GQZ_CUSUNI"
		uRet := oMdlGQZ:GetValue('GQZ_CUSUNI',nLineGQZ) * oMdlGQZ:GetValue('GQZ_QUANT',nLineGQZ)
		oMdlGQZ:SetValue('GQZ_VALTOT',uRet)
	Case cField = "GQZ_QUANT"
		uRet := oMdlGQZ:GetValue('GQZ_CUSUNI',nLineGQZ) * oMdlGQZ:GetValue('GQZ_QUANT',nLineGQZ)
		oMdlGQZ:SetValue('GQZ_VALTOT',uRet)
	Case cField == "GQJ_UN"
		oMdlGQJ:SetValue('GQJ_DESCUN',POSICIONE("SAH",1,XFILIAL("SAH")+uVal,"AH_UMRES"))
	Case cField == "GYX_UM"
		oMdlGYX:SetValue('GYX_DESUM',POSICIONE("SAH",1,XFILIAL("SAH")+uVal,"AH_UMRES"))
	Case cField == "GQZ_UM"
		oMdlGQZ:SetValue('GQZ_DESUM',POSICIONE("SAH",1,XFILIAL("SAH")+uVal,"AH_UMRES"))
	Case cField == "GYD_PRODUT"
		If GYD->(FieldPos("GYD_PRONOT")) > 0
			oMdlGYD:SetValue("GYD_PRONOT", uVal)
		EndIf
		If SX3->(dbSeek( "GYD_DSCPRD"))
			oMdlGYD:SetValue("GYD_DSCPRD", POSICIONE("SB1",1,XFILIAL("SB1") + uVal,"B1_DESC"))
		EndIf
	Case cField == "GYD_PRONOT"
		If SX3->(dbSeek( "GYD_DPRDNF"))
			oMdlGYD:SetValue("GYD_DPRDNF", POSICIONE("SB1",1,XFILIAL("SB1") + uVal,"B1_DESC"))
		EndIf
	Case cField == "GYD_ORGAO"
		If SX3->(dbSeek( "GYD_DORGAO"))
			oMdlGYD:SetValue("GYD_DORGAO", POSICIONE("GI0", 1, XFILIAL("GI0") + uVal, "GI0_DESCRI"))
		EndIf
	Case cField == "GYD_PRECON" 
		If GYD->(FieldPos('GYD_VLRACO')) > 0 .And. oMdlGYD:GetValue("GYD_PRECON") == '1'
			oMdlGYD:LoadValue("GYD_VLRACO", 0)
		Endif
	Case cField == 'GYD_TPCARR'
		If oMdlGYD:HasField("GYD_DESCAT") 
			oMdlGYD:SetValue("GYD_DESCAT", POSICIONE("GYR", 1, XFILIAL("GYK") + uVal, "GYR_DESCRI"))
		EndIf
	Case ( cField == "GYD_PLCONV" )
		
		If ( uVal == "1" )
			oMdlGYD:LoadValue("GYD_VLRTOT", 0)	
		Else
			oMdlGYD:LoadValue("GYD_IDPLCO", "")	
		EndIf

	Case ( cField == "GYD_PLEXTR" )

		If ( uVal == "1" )
			oMdlGYD:LoadValue("GYD_VLREXT", 0)				
		Else
			oMdlGYD:LoadValue("GYD_IDPLEX", "")	
		EndIf
	Case ( cField == "GY0_PLCONV" )
		
		If ( uVal == "1" )
			oMdlGY0:LoadValue("GY0_VLRACO", 0)	
		Else
			oMdlGY0:LoadValue("GY0_IDPLCO", "")	
			oMdlGY0:LoadValue("GY0_PREEXT", "")	
		EndIf
	Case ( cField == "GY0_VLRACO" )
		If ( uVal > 0 )
			oMdlGY0:LoadValue("GY0_PLCONV", '')	
			oMdlGY0:LoadValue("GY0_IDPLCO", '')	
		EndIf
	Case cField == "GY0_PRDEXT"
		If GY0->(FieldPos("GY0_PRONOT")) > 0
			oMdlGY0:SetValue("GY0_PRONOT", uVal)
		EndIf
		oMdlGY0:SetValue("GY0_PRDDSC", POSICIONE("SB1",1,XFILIAL("SB1") + uVal,"B1_DESC"))
	Case cField == "GY0_PRONOT"
		If GY0->(FieldPos("GY0_PRONOT")) > 0
			oMdlGY0:SetValue("GY0_DPRDNF", POSICIONE("SB1",1,XFILIAL("SB1") + uVal,"B1_DESC"))
		EndIf		
	Case cField == "GY0_CODVD"
		If oMdlGY0:HasField("GY0_NOMVD")  
			oMdlGY0:SetValue("GY0_NOMVD", POSICIONE("SA3",1,XFILIAL("SA3") + uVal,"A3_NOME"))
		EndIf	
	Case cField $ "GY0_DTINIC|GY0_UNVIGE|GY0_VIGE"
		If cField == 'GY0_UNVIGE' .And. uVal == '4'
			oMdlGY0:LoadValue("GY0_VIGE",0)
		EndIf
		If GY0->(FieldPos("GY0_DTVIGE")) > 0 .AND. !(Empty(oMdlGY0:GetValue("GY0_DTINIC")) .AND. Empty(oMdlGY0:GetValue("GY0_UNVIGE")))
			oMdlGY0:LoadValue("GY0_DTVIGE",G900DtFim(oMdlGY0:GetValue("GY0_UNVIGE"),oMdlGY0:GetValue("GY0_DTINIC"),oMdlGY0:GetValue("GY0_VIGE")))
		EndIf	
	Case cField $ "GY0_VALORC|GY0_UNORCV"
		If cField == 'GY0_UNORCV' .And. uVal == '4'
			oMdlGY0:LoadValue("GY0_VALORC",0)
			oMdlGY0:LoadValue("GY0_DTVORC",G900DtFim(oMdlGY0:GetValue("GY0_UNORCV"),dDataBase,0))
		Else
			If GY0->(FieldPos("GY0_DTVORC")) > 0 .AND. (!(Empty(oMdlGY0:GetValue("GY0_VALORC")) .AND. Empty(oMdlGY0:GetValue("GY0_UNORCV")).OR. oMdlGY0:GetValue("GY0_UNORCV")  == '4'))
				oMdlGY0:LoadValue("GY0_DTVORC",G900DtFim(oMdlGY0:GetValue("GY0_UNORCV"),dDataBase,oMdlGY0:GetValue("GY0_VALORC")))
			EndIf
		EndIf
		If !Empty(GY0->GY0_DTVORC)
			If oMdlGY0:GetOperation() == 4 
				cG900AltLog := GY0->GY0_ALTLOG
				oMdlGY0:LoadValue("GY0_ALTLOG", "Usuario da Alteração:" + cUserName + ";Data_Orçamento_Anterior:" + DtoC(GY0->GY0_DTVORC) + ";Alterado:" + FwTimeStamp(2) + CRLF + cG900AltLog)
			EndIf
		Else
			oMdlGY0:LoadValue("GY0_ALTLOG", "Usuario da Alteração:" + cUserName + ";Data_Orçamento_Anterior:" + DtoC(GY0->GY0_DTVORC) + ";Alterado:" + FwTimeStamp(2) + CRLF + cG900AltLog)
		EndIf
	Case cField == "GY0_DTVIGE"	
			oMdlGY0:LoadValue("GY0_VIGE",0)
			oMdlGY0:LoadValue("GY0_UNVIGE",'')
	Case cField == "GY0_DTVORC"	
		If !Empty(GY0->GY0_DTVORC)
			If oMdlGY0:GetOperation() == 4 
				cG900AltLog := GY0->GY0_ALTLOG
				oMdlGY0:LoadValue("GY0_ALTLOG", "Usuario:" + cUserName + ";Data_Orçamento_Anterior:" + DtoC(GY0->GY0_DTVORC) + ";Alterado:" + FwTimeStamp(2) + CRLF + cG900AltLog)
				oMdlGY0:LoadValue("GY0_VALORC",0)
				oMdlGY0:LoadValue("GY0_UNORCV",'')
			EndIf
		Else
			oMdlGY0:LoadValue("GY0_ALTLOG", cG900AltLog + CRLF + "Usuario:" + cUserName + ";Data_Orçamento_Anterior:" + DtoC(GY0->GY0_DTVORC) + ";Alterado:" + FwTimeStamp(2) )
			oMdlGY0:LoadValue("GY0_VALORC",0)
			oMdlGY0:LoadValue("GY0_UNORCV",'')
		EndIf
	Case cField == "GQI_CODORI"
		oMdlGQI:SetValue("GQI_DESORI",POSICIONE("GI1",1,XFILIAL("GI1") + uVal,"GI1_DESCRI"))
	Case cField == "GQI_CODDES"
		oMdlGQI:SetValue("GQI_DESDES",POSICIONE("GI1",1,XFILIAL("GI1") + uVal,"GI1_DESCRI"))
	Case cField == "GYD_TIPLIN"
		oMdlGYD:SetValue("GYD_DTIPLI",POSICIONE("GQC",1,XFILIAL("GQC") + uVal,"GQC_DESCRI"))
	
	EndCase

Return uVal

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author Teixeira
@since 25/09/2019
@version 1.0
@param oMdl, objeto, Modelo 
@param cField, caracter, Campo
@param uVal, undefined, Modelo
@param nLine, numerico, Modelo
@param uOldValue, undefined, Modelo
@return uRet, undefined, Valor de retorno
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldValid(oMdl,cField,uVal,nLine,uOldValue)

Local lRet      := .T.
Local cMsgErro  := ""
Local cMsgTitu  := ""
Local oModel    := FwModelActive()
Local oMdlGY0   := oModel:GetModel("GY0MASTER")
Local oMdlGYD   := oModel:GetModel("GYDDETAIL")
Local oMdlGQI   := oModel:GetModel("GQIDETAIL")
Local nCnt      := 0
Local nTamGrid  := 0
Local nLinhaAtu := 0
Local aAreaAux  := {}

Do Case 
	Case cField $ 'GYD_PRODUT|GYD_PRONOT|GY0_PRODUT|GY0_PRONOT|GY0_PRDEXT'
		aAreaAux := SB1->(GetArea())
		SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD
		If !SB1->(DbSeek(xFilial('SB1')+uVal))
			lRet	:= .F.
			cMsgTitu:= STR0033//"Produto não encontrado"
			cMsgErro:= STR0034//"Selecione algum produto que exista"
			
		ElseIf !RegistroOk("SB1")
			lRet	:= .F.
			cMsgTitu:= STR0035//"Produto informado se encontra bloqueado" 
			cMsgErro:= STR0036//"Informe um produto valido"
			
		ElseIf SB1->B1_TIPO <> "SV"
			lRet	:= .F.
			cMsgTitu:= STR0037//"Tipo de Produto inválido."
			cMsgErro:= STR0038//"O tipo do produto de ser do tipo serviço 'SV'"

		ElseIf EMPTY(SB1->B1_TS)
			lRet := .F.
			cMsgTitu:= STR0079 //'Produto sem TES'
			cMsgErro:= STR0080 //'O campo TES do produto não foipreenchido.'
		Endif 

		RestArea(aAreaAux)
	
	Case cField == 'GYD_NUMCAR'
		If uVal < 1
			cMsgTitu := STR0113 //'Quantidade Minima de Onibus por Viagem'
			cMsgErro := STR0114 //'Não é possível ter menos que um ônibus por viagem.'
			lRet := .F.
		EndIf

	Case cField $ 'GYD_LOCFIM|GYD_LOCINI'
		If nLine > 0
			If oMdlGYD:GetValue('GYD_LOCFIM',nLine) == oMdlGYD:GetValue('GYD_LOCINI',nLine) 
				cMsgTitu := STR0153 //'Localização Inicial / Localização Final'
				cMsgErro := STR0154 //'A Localização Inicial não pode ser Igual a Localização Final '
				lRet := .F.
			EndIf
	
		EndIf
		
	Case cField == 'GQI_CODDES'
		nLinhaAtu:= oMdlGQI:GetLine()
		nCnt:= oMdlGQI:Length()
		While nCnt > 1
			If !oMdlGQI:IsDeleted(nCnt)
				nTamGrid := nCnt
				EXIT
			EndIf
			nCnt--
		End
		If nLinhaAtu != nTamGrid .AND. nTamGrid > 0 .AND. nLinhaAtu > 0
			lRet:= .F.
			cMsgTitu := STR0029//"Alteração indevida"
			cMsgErro := STR0030//"Não pode alterar, por não ser ultima linha."
		EndIf

	Case cField $ 'GQJ_CODGIM|GYX_CODGIM'
		GIM->(DbSetOrder(1))
		If !GIM->(DbSeek(xFilial('GIM')+uVal))
			lRet:= .F.
			cMsgTitu := STR0044 //"Código não encontrado"
			cMsgErro := STR0045 //"Utilize um código válido"
		Endif

	Case cField == 'GY0_TPCTO'
		cMsgErro := VldCn1(uVal)
		
		If !(Empty(cMsgErro))
			lRet := .F.
		//	oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,,cMsgErro,)
		Endif

	Case cField == 'GY0_TIPPLA'
		cMsgErro := VldCnl(uVal)
		
		If !(Empty(cMsgErro))
			lRet := .F.
		Endif

	Case cField == 'GY0_TIPREV'
		CN0->(dbSetOrder(1))
		If CN0->(dbSeek(xFilial('CN0')+uVal))
			If CN0->CN0_TIPO != 'G'
				cMsgErro := STR0129 //"Apenas revisões do tipo Aberta 'G' são permitidas"
				lRet := .F.
			Endif
		Else
			cMsgErro := STR0130 //"Código de tipo de revisão não encontrado."
			lRet := .F.
		Endif
	Case cField == 'GY0_VLRACO'
		If uVal < 0
			cMsgErro := STR0131 //"O valor Acordado não pode ser negativo."
			lRet := .F.
		Endif
	Case cField == 'GY0_LOJACL'
		If (Empty(AllTrim(POSICIONE("SA1", 1, XFILIAL("SA1") + oMdlGY0:GetValue('GY0_CLIENT') + RTRIM(uVal) , "A1_NOME"))))
			cMsgErro := STR0132 // "Cliente Não Existe."
			lRet := .F.
		EndIf
	Case ( cField == "GQI_SENTID" )		
		lRet := WrongWay(oModel,uVal,@cMsgErro)		
EndCase

If !lRet
	oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,,cMsgErro,)
EndIF

Return lRet

/*/{Protheus.doc} WrongWay
Função que avalia se o itinerário possui o mesmo sentido que a linha
(gtrid dados da linha)
@type  Static Function
@author Teixeira
@since 25/05/2023
@version 1.0
@param 
	oModel, objeto, instância do modelo de dados 
	cSentido, caracter, sentido do trecho (ida ou volta)
	cMsgErro, caractere, parâmetro passado por referência para 
	ser atualizado com mensagem de erro, caso haja.
	nLnGQI, numerico, linha do submodelo GQIDETAIL
	nLnGYD, numerico, linha do submodelo GYDDETAIL
	
@return LRet, lógico, .t. sentido está correto; .f. não está correto
@example
(examples)
@see (links_or_references)
/*/
Static Function WrongWay(oModel,cSentido,cMsgErro,nLnGQI,nLnGYD)
		
	Local oMdlGQI := oModel:GetModel("GQIDETAIL")
	Local oMdlGYD := oModel:GetModel("GYDDETAIL")

	Local lRet := .t.
	
	Default nLnGQI	:= oMdlGQI:GetLine()
	Default nLnGYD	:= oMdlGYD:GetLine()

	If ( (!oMdlGYD:IsDeleted(nLnGYD) .And. !oMdlGQI:IsDeleted(nLnGQI)) .And.; 
		(oMdlGYD:GetValue("GYD_SENTID",nLnGYD) != "3" .And. cSentido != oMdlGYD:GetValue("GYD_SENTID",nLnGYD)) .Or.;
		Empty(cSentido))
		
		lRet := .F.

		cMsgErro := STR0155	//"O sentido da linha (Grade Dados da Linha) que foi definido ("
		cMsgErro += X3Combo("GYD_SENTID",oMdlGYD:GetValue("GYD_SENTID",nLnGYD))  
		cMsgErro += STR0156	//"), não é o mesmo sentido do trecho do itinerário, do item " 
		cMsgErro += cValToChar(nLnGQI) 
		cMsgErro += STR0157	//" que foi selecionado na Grade Itinerários."
	
	EndIf

Return(lRet)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Function
@author Lucivan Severo Correia
@since 25/06/2020
@version 1
@param param_name, param_type, param_descr
@return oView, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
	Local oModel        := ModelDef()
	Local oView
	Local oStruGY0      := FWFormStruct(2,"GY0", {|cCpo| !(AllTrim(cCpo)) $ "GY0_REVISA|GY0_DATREV|GY0_MOTREV|GY0_TIPREV|GY0_JUSREV|"})//cadastral	
	Local oStruRev	    := FWFormStruct(2,"GY0", {|cCpo| (AllTrim(cCpo)) $ "GY0_REVISA|GY0_DATREV|GY0_MOTREV|GY0_TIPREV|GY0_JUSREV|"})//dados da revisão	
	Local oStruGYD      := FWFormStruct(2,"GYD")//dados da linha
	Local oStruGQJ      := FWFormStruct(2,"GQJ")//Custos adicionais Cadastral
	Local oStruGYX      := FWFormStruct(2,"GYX")//custos adicionais linha
	Local oStruGQZ      := FWFormStruct(2,"GQZ")//custos operacionais
	Local oStruGQI      := FWFormStruct(2,"GQI")//itinerarios
	Local oStrTot 	    := FWFormViewStruct():New()
	Local cMsgErro 		:= ''
	Local nI			:= 0
	Local nX			:= 0
	Local cOrcContrato	:= '|GY0_NUMERO|GY0_CLIENT|GY0_LOJACL|GY0_NOMCLI|GY0_CODVD|GY0_NOMVD'
	Local aOrcContrato	:= {}
	Local cViagExtraSLin:= 'GY0_PLCONV|GY0_IDPLCO|GY0_PREEXT|GY0_PRDEXT|GY0_PRDDSC|GY0_PRONOT|GY0_DPRDNF|GY0_VLRACO'
	Local aViagExtraSLin:= {}
	Local cVigencias 	:= 'GY0_ASSINA|GY0_UNORCV|GY0_VALORC|GY0_DTVORC|GY0_UNVIGE|GY0_VIGE|GY0_DTVIGE|GY0_DTINIC'
	Local aVigencias	:= {}
	Local cGerLog		:= 'GY0_ALTLOG'
	Local aGerLog		:= {}
	
	aOrcContrato	:= STRTOKARR( cOrcContrato, '|' )
	aViagExtraSLin 	:= STRTOKARR( cViagExtraSLin, '|' )
	aVigencias 		:= STRTOKARR( cVigencias, '|' )
	aGerLog 		:= STRTOKARR( cGerLog, '|' )

	If ValidaDic(@cMsgErro)

		SetViewStruct(oStruGY0,oStruGYD,oStruGQJ,oStruGYX,oStruGQZ,oStruGQI,oStrTot)
		
		oStruGY0:AddGroup('ORÇAMENTO_CONTRATO'	, STR0133	, '', 2 )//Orçamento de Contrato
		oStruGY0:AddGroup('VIGENCIAS'			, STR0134	, '', 2 )//Vigencias
		oStruGY0:AddGroup('GERAIS'				, STR0135	, '', 2 )//Dados Gerais
		oStruGY0:AddGroup('EXTRAORDINARIA'		, STR0136	, '', 2 )//Viagens Extra sem Linha
		oStruGY0:AddGroup('GERLOG'				, STR0137	, '', 2 )//Log de Alteração Orçamento
		
		
		For nI:= 1 To Len(oStruGY0:aFields)
			If (oStruGY0:aFields[nI][1] $ cOrcContrato)
				oStruGY0:SetProperty(oStruGY0:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "ORÇAMENTO_CONTRATO" )
				For nX:= 1 To Len(aOrcContrato)
					If aOrcContrato[nX] == Alltrim(Upper(oStruGY0:aFields[nI][1]))
						Exit
					EndIf
				Next
			ElseIf (oStruGY0:aFields[nI][1] $ cVigencias)
				oStruGY0:SetProperty(oStruGY0:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "VIGENCIAS" )
				For nX:= 1 To Len(aVigencias)
					If aVigencias[nX] == Alltrim(Upper(oStruGY0:aFields[nI][1]))
						Exit
					EndIf
				Next
			ElseIf (oStruGY0:aFields[nI][1] $ cViagExtraSLin)
				oStruGY0:SetProperty(oStruGY0:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "EXTRAORDINARIA" )
				For nX:= 1 To Len(aViagExtraSLin)
					If aViagExtraSLin[nX] == Alltrim(Upper(oStruGY0:aFields[nI][1]))
						Exit
					EndIf
				Next
			ElseIf (oStruGY0:aFields[nI][1] $ cGerLog)
				oStruGY0:SetProperty(oStruGY0:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "GERLOG" )
				For nX:= 1 To Len(aGerLog)
					If aGerLog[nX] == Alltrim(Upper(oStruGY0:aFields[nI][1]))
						Exit
					EndIf
				Next
			Else
				oStruGY0:SetProperty(oStruGY0:aFields[nI][1], MVC_VIEW_GROUP_NUMBER, "GERAIS" )
			EndIf
			oStruGY0:SetProperty(oStruGY0:aFields[nI][1],MVC_VIEW_ORDEM,g900GetOrder(oStruGY0:aFields[nI][1]))
		Next

		For nI:= 1 To Len(oStruGYD:aFields)
			oStruGYD:SetProperty(oStruGYD:aFields[nI][1],MVC_VIEW_ORDEM,g900GetOrder(oStruGYD:aFields[nI][1]))
		Next

		// Cria o objeto de View
		oView := FWFormView():New()
		oView:SetContinuousForm(.T.)
		// Define qual o Modelo de dados será utilizado
		oView:SetModel(oModel)

		oView:AddField("VIEW_GY0", oStruGY0 ,"GY0MASTER" )
		oView:AddField("VIEW_REV", oStruRev ,"GY0MASTER" )
		oView:AddGrid("VIEW_GYD" , oStruGYD ,"GYDDETAIL" )
		oView:AddGrid('VIEW_GQJ' , oStruGQJ ,"GQJDETAIL" )
		oView:AddGrid('VIEW_GYX' , oStruGYX ,"GYXDETAIL" )
		oView:AddGrid('VIEW_GQZ' , oStruGQZ ,"GQZDETAIL" )
		oView:AddGrid("VIEW_GQI" , oStruGQI ,"GQIDETAIL" )
		//oView:AddField('VW_TOTDETAIL' 	, oStrTot	,"TOTDETAIL")

		oView:CreateFolder("FOLDER")
		// Divisão Horizontal
		oView:AddSheet( "FOLDER", "ABA01", STR0012) //"Cadastral"
		oView:CreateHorizontalBox( "SUPERIOR", 60,,,"FOLDER", "ABA01")
		oView:CreateHorizontalBox( "INFERIOR", 40,,,"FOLDER", "ABA01")
		
		oView:EnableTitleView("VIEW_GQJ" , STR0013) //"Custos adicionais/Cortesia"

		oView:AddSheet( "FOLDER", "ABA02", STR0014) //"Precificação/Itinerário"
		oView:CreateHorizontalBox( "BOX_SUPERIOR", 25,,,"FOLDER", "ABA02")

		oView:CreateHorizontalBox( "BOX_ITINERARIO", 25, , , "FOLDER", "ABA02")
		oView:CreateHorizontalBox( "BOX_CUSTOS", 20, , , "FOLDER", "ABA02")
		oView:CreateHorizontalBox( "BOX_CUSTOS_OPERACIONAIS" , 20, /*owner*/,/*lUsePixel*/, "FOLDER", "ABA02" )
		oView:CreateHorizontalBox("TOTAL", 10 , , , "FOLDER", "ABA02") 

		oView:AddSheet("FOLDER", "ABA03", 'Dados da Revisão')
		oView:CreateHorizontalBox("REVISA", 100,,,"FOLDER", "ABA03")

		oView:EnableTitleView("VIEW_GYD"  , STR0015) //"Dados da Linha"
		oView:EnableTitleView("VIEW_GQI"  , STR0009) //"Itinerário"
		oView:EnableTitleView("VIEW_GYX" , STR0013) //"Custos adicionais/Cortesia"
		oView:EnableTitleView("VIEW_GQZ" , STR0016) //"Custos operacionais"
		//oView:EnableTitleView('VW_TOTDETAIL' ,STR0057) //"Totalizadores"

		oView:SetOwnerView("VIEW_GY0" , "SUPERIOR")
		oView:SetOwnerView("VIEW_REV" , "REVISA")
		oView:SetOwnerView("VIEW_GYD" , "BOX_SUPERIOR")
		oView:SetOwnerView("VIEW_GQJ" , "INFERIOR")
		oView:SetOwnerView("VIEW_GYX" , "BOX_CUSTOS")
		oView:SetOwnerView("VIEW_GQZ" , "BOX_CUSTOS_OPERACIONAIS")
		oView:SetOwnerView("VIEW_GQI" , "BOX_ITINERARIO")
		//oView:SetOwnerView('VW_TOTDETAIL'   ,'TOTAL')
		
		
		oView:AddIncrementField( 'VIEW_GYD', 'GYD_SEQ' )
		oView:AddIncrementField( 'VIEW_GQJ', 'GQJ_SEQ' )
		oView:AddIncrementField( 'VIEW_GYX', 'GYX_SEQ' )
		oView:AddIncrementField( 'VIEW_GQI', 'GQI_SEQ' )
		oView:AddIncrementField( 'VIEW_GQZ', 'GQZ_SEQ' )
		
		

		oView:AddUserButton( STR0039, "", {|| GA900Calc(oView)},,VK_F5 )//"Cálculo Custo"
		oView:AddUserButton( STR0040, "", {|| GA900Inc(oView)},,VK_F7, {MODEL_OPERATION_INSERT})//"Listagem passageiros"
		oView:AddUserButton( STR0138, "", {|oView| GTPA900A(oView)},, ) //"Reajuste"
		oView:AddUserButton( STR0139, "", {|| GTPA901A()},, ,) //"Importar Lista de Passageiros"
		
		oView:SetAfterViewActivate( { || AfterActiv(oView)})

		oStruGY0:RemoveField('GY0_PCOMVD')
		oStruGQI:RemoveField("GQI_TIPLOC")
	
		oStruGYD:RemoveField('GYD_CUSMOT')
		oStruGYD:RemoveField('GYD_ANOCAR')
		oStruGYD:RemoveField('GYD_ATENDI')
		oStruGY0:RemoveField('GY0_KMFRAN')

		If INCLUI
			If GY0->(FieldPos("GY0_OBSCAN")) > 0
				oStruGY0:RemoveField("GY0_OBSCAN")
			EndIf

			If GY0->(FieldPos("GY0_DTCANC")) > 0
				oStruGY0:RemoveField("GY0_DTCANC")
			End

			If GY0->(FieldPos("GY0_USUCAN")) > 0
				oStruGY0:RemoveField("GY0_USUCAN")
			End
		EndIf
				
	Else
	    FwAlertHelp(cMsgErro, STR0017)	// "Banco de dados desatualizado, não é possível iniciar a rotina"
	EndIf

Return oView

/*/{Protheus.doc} SetViewStruct
(long_description)
@type  Static Function
@author Teixeira
@since 18/08/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStruGY0,oStruGYD,oStruGQJ,oStruGYX,oStruGQZ,oStruGQI,oStrTot)

	Local aArea := GetArea()

	If GQZ->(FieldPos("GQZ_CODCLI")) > 0
		oStruGQZ:RemoveField("GQZ_CODCLI")
	EndIf
	If GQZ->(FieldPos("GQZ_CODLOJ")) > 0
		oStruGQZ:RemoveField("GQZ_CODLOJ")
	EndIf
	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek( "GQZ_NOMCLI"))
		oStruGQZ:RemoveField("GQZ_NOMCLI")
	EndIf
	If GQZ->(FieldPos("GQZ_INIVIG")) > 0
		oStruGQZ:RemoveField("GQZ_INIVIG")
	EndIf
	If GQZ->(FieldPos("GQZ_FIMVIG")) > 0
		oStruGQZ:RemoveField("GQZ_FIMVIG")
	EndIf
	If GQZ->(FieldPos("GQZ_TPDESC"))  > 0
		oStruGQZ:RemoveField("GQZ_TPDESC")
	EndIf
	If GQZ->(FieldPos("GQZ_VALOR")) > 0
		oStruGQZ:RemoveField("GQZ_VALOR")
	EndIf
	If GQZ->(FieldPos("GQZ_TIPCUS")) > 0
		oStruGQZ:RemoveField("GQZ_TIPCUS")
	EndIf

	If GY0->(FieldPos("GY0_STATUS")) > 0
		oStruGY0:RemoveField("GY0_STATUS")
	EndIf

	If GYD->(FieldPos("GYD_CODCNA")) > 0
		oStruGYD:RemoveField("GYD_CODCNA")
	EndIf

	If GYD->(FieldPos("GYD_TPOPER")) > 0
		oStruGYD:RemoveField("GYD_TPOPER")
	EndIf
	
	If GQJ->(FieldPos("GQJ_PLAN")) > 0
		oStruGQJ:RemoveField("GQJ_PLAN")
	EndIf

	If GYX->(FieldPos("GYX_PLAN")) > 0
		oStruGYX:RemoveField("GYX_PLAN")
	EndIf

	If GY0->(FieldPos("GY0_CODCN9")) > 0
		oStruGY0:SetProperty('GY0_CODCN9', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	
	If GYD->(FieldPos("GYD_NUMERO")) > 0
		oStruGYD:SetProperty('GYD_NUMERO', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GYD->(FieldPos("GYD_CODGYD")) > 0
		oStruGYD:SetProperty('GYD_CODGYD', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GYD->(FieldPos("GYD_CODGI2")) > 0
		oStruGYD:SetProperty('GYD_CODGI2', MVC_VIEW_CANCHANGE , .F. )
	EndIf

	If GQJ->(FieldPos("GQJ_VALTOT")) > 0
		oStruGQJ:SetProperty('GQJ_VALTOT', MVC_VIEW_CANCHANGE , .F. )
	EndIf

	If GQI->(FieldPos("GQI_DESORI")) > 0
		oStruGQI:SetProperty('GQI_DESORI', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GQI->(FieldPos("GQI_DESDES")) > 0
		oStruGQI:SetProperty('GQI_DESDES', MVC_VIEW_CANCHANGE , .F. )
	EndIf

	If GYX->(FieldPos("GYX_CODIGO")) > 0
		oStruGYX:SetProperty('GYX_CODIGO', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GYX->(FieldPos("GYX_SEQ")) > 0
		oStruGYX:SetProperty('GYX_SEQ'   , MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GYX->(FieldPos("GYX_ITEM")) > 0
		oStruGYX:SetProperty('GYX_ITEM'  , MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GYX->(FieldPos("GYX_VALTOT")) > 0
		oStruGYX:SetProperty('GYX_VALTOT' , MVC_VIEW_CANCHANGE , .F. )
	EndIf

	If GQZ->(FieldPos("GQZ_VALTOT")) > 0
		oStruGQZ:SetProperty('GQZ_VALTOT', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GQZ->(FieldPos("GQZ_CODIGO")) > 0
		oStruGQZ:SetProperty('GQZ_CODIGO', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GQZ->(FieldPos("GQZ_SEQ")) > 0
		oStruGQZ:SetProperty('GQZ_SEQ'   , MVC_VIEW_CANCHANGE , .F. )
	EndIf
	If GQZ->(FieldPos("GQZ_ITEM")) > 0
		oStruGQZ:SetProperty('GQZ_ITEM'  , MVC_VIEW_CANCHANGE , .F. )
	EndIf

	If GY0->(FieldPos("GY0_TPCTO")) > 0
		oStruGY0:SetProperty('GY0_TPCTO' , MVC_VIEW_LOOKUP, "CN1")
	EndIf

	If GYD->(FieldPos("GYD_TIPLIN")) > 0
		oStruGYD:SetProperty('GYD_TIPLIN' , MVC_VIEW_LOOKUP, "GQC")
	EndIf

	If GYD->(FieldPos("GYD_LOCINI")) > 0
		oStruGYD:SetProperty('GYD_LOCINI', MVC_VIEW_LOOKUP, "GI1")
	EndIf
	If GYD->(FieldPos("GYD_LOCFIM")) > 0
		oStruGYD:SetProperty('GYD_LOCFIM', MVC_VIEW_LOOKUP, "GI1")
	EndIf
	If GYD->(FieldPos("GYD_ORGAO")) > 0
		oStruGYD:SetProperty('GYD_ORGAO' , MVC_VIEW_LOOKUP, "GI0")
	EndIf

	If GQI->(FieldPos("GQI_CODORI")) > 0
		oStruGQI:SetProperty('GQI_CODORI', MVC_VIEW_LOOKUP, "GI1")
	EndIf
	If GQI->(FieldPos("GQI_CODDES")) > 0
		oStruGQI:SetProperty('GQI_CODDES', MVC_VIEW_LOOKUP, "GI1")
	EndIf
	//Cabeçalho
	If SX3->(dbSeek( "GY0_DSCPRD"))
		oStruGY0:SetProperty('GY0_DSCPRD', MVC_VIEW_CANCHANGE , .F. )
	EndIf
	//custos adicionais cabeçalho
	If GQJ->(FieldPos("GQJ_SEQ")) > 0
		oStruGQJ:SetProperty("GQJ_SEQ"    , MVC_VIEW_ORDEM, '01')
	EndIf
	If GQJ->(FieldPos("GQJ_CODGIM")) > 0
		oStruGQJ:SetProperty("GQJ_CODGIM" , MVC_VIEW_ORDEM, '02')
	EndIf
	If GQJ->(FieldPos("GQJ_DCUSTO")) > 0
		oStruGQJ:SetProperty("GQJ_DCUSTO" , MVC_VIEW_ORDEM, '03')
	EndIf
	If GQJ->(FieldPos("GQJ_FORMUL")) > 0
		oStruGQJ:SetProperty("GQJ_FORMUL" , MVC_VIEW_ORDEM, '04')
	EndIf
	If GQJ->(FieldPos("GQJ_TIPO")) > 0
		oStruGQJ:SetProperty("GQJ_TIPO"   , MVC_VIEW_ORDEM, '05')
	EndIf
	If GQJ->(FieldPos("GQJ_UN")) > 0
		oStruGQJ:SetProperty("GQJ_UN"     , MVC_VIEW_ORDEM, '06')
	EndIf
	If GQJ->(FieldPos("GQJ_DESCUN")) > 0
		oStruGQJ:SetProperty("GQJ_DESCUN"     , MVC_VIEW_ORDEM, '07')
	EndIf
	
	If GQJ->(FieldPos("GQJ_QUANT")) > 0
		oStruGQJ:SetProperty("GQJ_QUANT"  , MVC_VIEW_ORDEM, '08')
	EndIf
	If GQJ->(FieldPos("GQJ_CUSUNI")) > 0
		oStruGQJ:SetProperty("GQJ_CUSUNI" , MVC_VIEW_ORDEM, '09')
	EndIf
	If GQJ->(FieldPos("GQJ_VALTOT")) > 0
		oStruGQJ:SetProperty("GQJ_VALTOT" , MVC_VIEW_ORDEM, '10')
	EndIf
	//Dados da linha
	If GYD->(FieldPos("GYD_CODGYD")) > 0
		oStruGYD:SetProperty("GYD_CODGYD" , MVC_VIEW_TITULO , 'Seq.Lin')
	EndIf
	If SX3->(dbSeek( "GYD_DORGAO"))
		oStruGYD:SetProperty("GYD_DORGAO"  , MVC_VIEW_CANCHANGE, .F.) 
	EndIf
	If SX3->(dbSeek( "GYD_DSCPRD"))
		oStruGYD:SetProperty("GYD_DSCPRD"  , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If SX3->(dbSeek( "GYD_DLOCFI"))
		oStruGYD:SetProperty("GYD_DLOCFI"  , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If GYD->(FieldPos("GYD_PRECON")) > 0
		oStruGYD:SetProperty("GYD_PRECON" , MVC_VIEW_TITULO , 'Precif. Conven.')
	EndIf
	If GYD->(FieldPos("GYD_VLRTOT")) > 0
		oStruGYD:SetProperty("GYD_VLRTOT" , MVC_VIEW_TITULO , 'Valor Conven.')
	EndIf
	If oStruGYD:HasField("GYD_DPRDNF") 
		oStruGYD:SetProperty("GYD_DPRDNF"  , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If GYD->(FieldPos("GYD_CODGI2")) > 0
		oStruGYD:SetProperty("GYD_CODGI2"  , MVC_VIEW_CANCHANGE, .F.)
		oStruGYD:SetProperty("GYD_CODGI2" , MVC_VIEW_TITULO , 'Linha Gerada')
	EndIf

	//Itinerario
	If GQI->(FieldPos("GQI_CODIGO")) > 0
		oStruGQI:SetProperty("GQI_CODIGO", MVC_VIEW_ORDEM, '01')
		oStruGQI:SetProperty("GQI_CODIGO"   , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If GQI->(FieldPos("GQI_SEQ")) > 0
		oStruGQI:SetProperty("GQI_SEQ"   , MVC_VIEW_ORDEM, '02')
		oStruGQI:SetProperty("GQI_SEQ"   , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If GQI->(FieldPos("GQI_ITEM")) > 0
		oStruGQI:SetProperty("GQI_ITEM"  , MVC_VIEW_ORDEM, '03')
		oStruGQI:SetProperty("GQI_ITEM"   , MVC_VIEW_CANCHANGE, .F.)
	EndIf
	If GQI->(FieldPos("GQI_CODORI")) > 0
		oStruGQI:SetProperty("GQI_CODORI", MVC_VIEW_ORDEM, '04')
	EndIf
	If GQI->(FieldPos("GQI_DESORI")) > 0
		oStruGQI:SetProperty("GQI_DESORI", MVC_VIEW_ORDEM, '05')
	EndIf
	If GQI->(FieldPos("GQI_CODDES")) > 0
		oStruGQI:SetProperty("GQI_CODDES", MVC_VIEW_ORDEM, '06')
	EndIf
	If GQI->(FieldPos("GQI_DESDES")) > 0
		oStruGQI:SetProperty("GQI_DESDES", MVC_VIEW_ORDEM, '07')
	EndIf
	If GQI->(FieldPos("GQI_DTORIG")) > 0
		oStruGQI:SetProperty("GQI_DTORIG", MVC_VIEW_ORDEM, '08')
	EndIf
	If GQI->(FieldPos("GQI_HRORIG")) > 0
		oStruGQI:SetProperty("GQI_HRORIG", MVC_VIEW_ORDEM, '09')
	EndIf
	If GQI->(FieldPos("GQI_DTDEST")) > 0
		oStruGQI:SetProperty("GQI_DTDEST", MVC_VIEW_ORDEM, '10')
	EndIf
	If GQI->(FieldPos("GQI_HRDEST")) > 0
		oStruGQI:SetProperty("GQI_HRDEST", MVC_VIEW_ORDEM, '11')
	EndIf
		
	If GQI->(FieldPos("GQI_SENTID")) > 0
		oStruGQI:SetProperty("GQI_SENTID" , MVC_VIEW_ORDEM, '16')
	EndIf
	
	//adicionais
	If GYX->(FieldPos("GYX_CODIGO")) > 0
		oStruGYX:SetProperty("GYX_CODIGO" , MVC_VIEW_ORDEM, '01')
	EndIf
	If GYX->(FieldPos("GYX_SEQ")) > 0
		oStruGYX:SetProperty("GYX_SEQ", MVC_VIEW_ORDEM, '02')
	EndIf
	If GYX->(FieldPos("GYX_ITEM")) > 0
		oStruGYX:SetProperty("GYX_ITEM", MVC_VIEW_ORDEM, '03')
	EndIf
	If GYX->(FieldPos("GYX_CODGIM")) > 0
		oStruGYX:SetProperty("GYX_CODGIM", MVC_VIEW_ORDEM, '04')
	EndIf
	If GYX->(FieldPos("GYX_DCUSTO")) > 0
		oStruGYX:SetProperty("GYX_DCUSTO", MVC_VIEW_ORDEM, '05')
	EndIf
	If GYX->(FieldPos("GYX_FORMUL")) > 0
		oStruGYX:SetProperty("GYX_FORMUL", MVC_VIEW_ORDEM, '06')
	EndIf
	If GYX->(FieldPos("GYX_TIPO")) > 0
		oStruGYX:SetProperty("GYX_TIPO", MVC_VIEW_ORDEM, '07')
	EndIf
	If GYX->(FieldPos("GYX_UM")) > 0
		oStruGYX:SetProperty("GYX_UM", MVC_VIEW_ORDEM, '08')
	EndIf
	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek( "GYX_DESUM"))
		oStruGYX:SetProperty("GYX_DESUM", MVC_VIEW_ORDEM, '09')
	EndIf
	If GYX->(FieldPos("GYX_QUANT")) > 0
		oStruGYX:SetProperty("GYX_QUANT"  , MVC_VIEW_ORDEM, '10')
	EndIf
	If GYX->(FieldPos("GYX_CUSUNI")) > 0
		oStruGYX:SetProperty("GYX_CUSUNI" , MVC_VIEW_ORDEM, '11')
	EndIf
	If GYX->(FieldPos("GYX_VALTOT")) > 0
		oStruGYX:SetProperty("GYX_VALTOT" , MVC_VIEW_ORDEM, '12')
	EndIf
	//operacionais
	If GQZ->(FieldPos("GQZ_CODIGO")) > 0
		oStruGQZ:SetProperty("GQZ_CODIGO", MVC_VIEW_ORDEM, '01')
	EndIf
	If GQZ->(FieldPos("GQZ_SEQ")) > 0
		oStruGQZ:SetProperty("GQZ_SEQ"   , MVC_VIEW_ORDEM, '02')
	EndIf
	If GQZ->(FieldPos("GQZ_ITEM")) > 0
		oStruGQZ:SetProperty("GQZ_ITEM"  , MVC_VIEW_ORDEM, '03')
	EndIf

	If ValType(oStrTot) == "O"
		oStrTot:AddField("VLRITEM"	,'01',STR0054 ,STR0054 ,{STR0054 },"N",'@E 9,999,999,999,999.99' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
		oStrTot:AddField("VLREXTRA"	,'02',STR0055 ,STR0055 ,{STR0055 },"N",'@E 9,999,999,999,999.99' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
		oStrTot:AddField("TOTADIC"	,'03',STR0051 ,STR0051 ,{STR0051 },"N",'@E 9,999,999,999,999.99' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
		oStrTot:AddField("TOTOPE"	,'04',STR0052 ,STR0052 ,{STR0052 },"N",'@E 9,999,999,999,999.99' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
		oStrTot:AddField("TOTLINHA"	,'05',STR0053 ,STR0053 ,{STR0053 },"N",'@E 9,999,999,999,999.99' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )	
	EndIf

	If GY0->(FieldPos('GY0_DTCANC')) > 0
		oStruGY0:SetProperty("GY0_DTCANC", MVC_VIEW_CANCHANGE, .F.)
	Endif

	If GY0->(FieldPos('GY0_USUCAN')) > 0
		oStruGY0:SetProperty("GY0_USUCAN", MVC_VIEW_CANCHANGE, .F.)
	Endif

	If GY0->(FieldPos('GY0_OBSCAN')) > 0
		oStruGY0:SetProperty("GY0_OBSCAN", MVC_VIEW_CANCHANGE, .F.)
	Endif

RestArea(aArea)
Return 

/*/{Protheus.doc} GA900Inc
(long_description)
@type  Static Function
@author Teixeira
@since 12/08/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA900Inc(oView)
Local oModel	:= oView:GetModel()
Local n1        := 0
Local n2        := 0
Local aFldsGQ8  := oModel:GetModel('GQ8DETAIL'):GetStruct():GetFields()
Local aFldsGQB  := oModel:GetModel('GQBDETAIL'):GetStruct():GetFields()

Private oMdl901

GTPA901ORC(oModel)

If oMdl901:IsActive()

	For n1 := 1 To Len(aFldsGQ8)
		oModel:GetModel('GQ8DETAIL'):LoadValue(aFldsGQ8[n1][3], oMdl901:GetModel('GQ8MASTER'):GetValue(aFldsGQ8[n1][3]))
	Next

	oModel:GetModel('GQBDETAIL'):DelAllLine()

	For n2 := 1 To oMdl901:GetModel('GQBDETAIL'):Length()

		If !Empty(oModel:GetModel('GQBDETAIL'):GetValue('GQB_ITEM')) 
			oModel:GetModel('GQBDETAIL'):AddLine()
		Endif

		For n1 := 1 To Len(aFldsGQB)
			oModel:GetModel('GQBDETAIL'):LoadValue(aFldsGQB[n1][3], oMdl901:GetModel('GQBDETAIL'):GetValue(aFldsGQB[n1][3], n2))
		Next

	Next

	oModel:GetModel('GQ8DETAIL'):LoadValue('GQ8_CODGY0', oModel:GetModel('GYDDETAIL'):GetValue('GYD_NUMERO'))
	oModel:GetModel('GQ8DETAIL'):LoadValue('GQ8_CODGYD', oModel:GetModel('GYDDETAIL'):GetValue('GYD_CODGYD'))

	oMdl901:DeActivate()
	oMdl901:Destroy()

Endif

Return nil

/*/{Protheus.doc} TrigGIMPrd
Preenche grid da GIM com as tabelas de custos conforme o produto informado
@type function
@author jacomo.fernandes
@since 19/07/2018
@version 1.0
@param oMdlG6S, objeto, (Descrição do parâmetro)
@param cProduto, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function TrigGIMPrd(oMdl, cProduto, cCodigo)
Local cAliasTmp	:= GetNextAlias()
Local cWhere	:= ""
Local lTrgGQJ	:= .F. //Se vier pelo gatilho do campo GQJ_CODGIM, não permitir que inclua linha.
Local cTable	:= oMdl:GetStruct():GetTable()[1]
Default cCodigo	:= ""

If GIM->(FieldPos('GIM_UTILIZ')) > 0
	cWhere := " AND GIM.GIM_UTILIZ = '2' "
Endif

If !Empty(cCodigo)
	cWhere	:= " AND GIM.GIM_COD = '"+cCodigo+"' "
	lTrgGQJ := .T.
Endif

cWhere := "%"+cWhere+"%"

BeginSql Alias cAliasTmp
	SELECT 
		GIM.GIM_COD AS CODGIM,  
		GIM.GIM_DESCRI AS DCUSTO, 
		GIM.GIM_UM AS UN, 
		SAH.AH_UMRES AS DESCUN,
		(CASE 
			WHEN GIM.GIM_TPCUST = '1' 
				THEN '2'
			ELSE '1' 
		END) AS FORMUL, 
		GIM.GIM_CBASE AS CUSUNI,
		(CASE 
			WHEN GIM.GIM_TPCUST = '1' 
				THEN GIM.GIM_CBASE 
			ELSE 0 
		END) AS VALTOT
	FROM %Table:GIM% GIM
		INNER JOIN %Table:SAH% SAH ON
			SAH.AH_FILIAL = %xFilial:SAH%
			AND SAH.AH_UNIMED = GIM.GIM_UM
			AND SAH.%NotDel%
		
	WHERE 
		GIM_FILIAL = %xFilial:GIM%
		AND GIM.%NotDel%
		
		%Exp: cWhere %
		
	Order By GIM.GIM_FILIAL, GIM.GIM_COD
EndSql

If (cAliasTmp)->(!EoF())
	While (cAliasTmp)->(!EoF())
		
		If !lTrgGQJ .and. (!oMdl:IsEmpty() .or. !Empty(oMdl:GetValue('GQJ_CODGIM')))
			oMdl:AddLine()
		Endif
		
		oMdl:LoadValue(cTable+'_CODGIM'	,(cAliasTmp)->CODGIM	)
		oMdl:LoadValue(cTable+'_DCUSTO'	,(cAliasTmp)->DCUSTO	)
		oMdl:LoadValue(cTable+'_FORMUL'	,(cAliasTmp)->FORMUL	)
		oMdl:LoadValue(If (cTable == 'GQJ','GQJ_UN','GYX_UM'), 	  (cAliasTmp)->UN	)
		oMdl:LoadValue(If (cTable == 'GQJ','GQJ_UN','GYX_DESUM'), (cAliasTmp)->UN	)
		oMdl:LoadValue(cTable+'_QUANT'	, 1						)
		oMdl:LoadValue(cTable+'_CUSUNI'	,(cAliasTmp)->CUSUNI	)
		oMdl:LoadValue(cTable+'_VALTOT'	,(cAliasTmp)->VALTOT	)
		oMdl:LoadValue(cTable+'_PLAN'	,Posicione('GIM',1,xFilial('GIM')+(cAliasTmp)->CODGIM,'GIM_PLAN') )

		(cAliasTmp)->(DbSkip())
	End 
Endif

(cAliasTmp)->(DbCloseArea())

Return

/*/{Protheus.doc} GA900Calc
(long_description)
@type function
@author jacomo.fernandes
@since 20/07/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA900Calc(oView)
Local oModel			:= oView:GetModel()
Local oMdlGY0			:= oModel:GetModel('GY0MASTER')
Local oMdlGQI			:= oModel:GetModel('GQIDETAIL')
Local oMdlGQJ			:= oModel:GetModel('GQJDETAIL')
Local oMdlGYX			:= oModel:GetModel('GYXDETAIL')
Local oMdlGQZ			:= oModel:GetModel('GQZDETAIL')
Local oWorkSheet		:= FWUIWorkSheet():New(/*oWinPlanilha*/,.F. , /*WS_ROWS*/, /*WS_COLS*/)
Local nCell				:= 0
Local n1				:= 0
Local nValue			:= 0

oWorkSheet:lShow := .F.

For n1 := 1 to oMdlGQJ:Length()
	If !oMdlGQJ:IsDeleted(n1) .and. oMdlGQJ:GetValue('GQJ_FORMUL',n1) == '1'
		oMdlGQJ:GoLine(n1)
		oWorkSheet:LoadXmlModel(oMdlGQJ:GetValue('GQJ_PLAN'))
		
		For nCell := 2 To oWorkSheet:NTOTALLINES			
			If oWorkSheet:CellExists("A"+ cValTochar(nCell))
				
				cCellValue	:= oWorkSheet:GetCellValue("A"+ cValTochar(nCell))
				cCellValue	:= AllTrim(cCellValue) 
				
				Do Case
					Case oMdlGY0:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGY0:GetValue(cCellValue))
					Case oMdlGQI:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQI:GetValue(cCellValue))
					Case oMdlGQJ:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQJ:GetValue(cCellValue))
					Case oMdlGYX:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGYX:GetValue(cCellValue))
					Case oMdlGQZ:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQZ:GetValue(cCellValue))
				EndCase

			EndIf
		Next
		
		If oWorkSheet:CellExists("D2") 	
			nValue := oWorkSheet:GetCellValue("D2")
		EndIf
				
		oMdlGQJ:SetValue('GQJ_CUSUNI',nValue)
		
		oWorkSheet:Close()
		
	Endif
Next

For n1 := 1 to oMdlGYX:Length()
	If !oMdlGYX:IsDeleted(n1) .and. oMdlGYX:GetValue('GYX_FORMUL',n1) == '1'
		oMdlGYX:GoLine(n1)
		oWorkSheet:LoadXmlModel(oMdlGYX:GetValue('GYX_PLAN'))
		
		For nCell := 2 To oWorkSheet:NTOTALLINES			
			If oWorkSheet:CellExists("A"+ cValTochar(nCell))
				
				cCellValue	:= oWorkSheet:GetCellValue("A"+ cValTochar(nCell))
				cCellValue	:= AllTrim(cCellValue) 
				
				Do Case
					Case oMdlGY0:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGY0:GetValue(cCellValue))
					Case oMdlGQI:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQI:GetValue(cCellValue))
					Case oMdlGQJ:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQJ:GetValue(cCellValue))
					Case oMdlGYX:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGYX:GetValue(cCellValue))
					Case oMdlGQZ:GetStruct():HasField(cCellValue)
						oWorkSheet:SetCellValue("C" + cValToChar(nCell), oMdlGQZ:GetValue(cCellValue))
				EndCase

			EndIf
		Next
		
		If oWorkSheet:CellExists("D2") 	
			nValue := oWorkSheet:GetCellValue("D2")
		EndIf
				
		oMdlGYX:SetValue('GYX_CUSUNI',nValue)
		
		oWorkSheet:Close()
		
	Endif
Next

GTPDestroy(oWorkSheet)

Return

/*/{Protheus.doc} GTPA900CTR
(long_description)
@type  Function
@author Osmar Cioni
@since 19/08/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA900CTR()
Local lRet	:= .T.

If GY0->(FieldPos("GY0_STATUS")) > 0 .And. GY0->GY0_STATUS != '1' 
	lRet := .F.
	FwAlertWarning(STR0023, STR0020) //"Criação de contrato permitido apenas para registros com o status 'Em Aberto'", "Atenção"
Endif 

If lRet
	lRet := ValidDocs()
Endif

If lRet
	FwMsgRun( ,{|| lRet := G900GerCtr()},, STR0022 ) //"Gerando Contrato...." 	
Endif

Return

/*/{Protheus.doc} G900GerCtr
(long_description)
@type  Static Function
@author Osmar Cioni
@since 19/08/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900GerCtr()
Local lRet      := .T.
Local oModel    := Nil
Local cContrat  := CN300Num()
Local nX 		:= Nil
Local nTotCadast:= 0
Local cMsgErro  := ""
Local oModelOrc	:= FwLoadModel("GTPA900")
Local lValOrc   := .T. // Valida Data Orçamento

oModelOrc:SetOperation(MODEL_OPERATION_UPDATE) 
oModelOrc:Activate()

If oModelOrc:GetModel("GY0MASTER"):HasField('GY0_DTVORC')
	lValOrc := oModelOrc:GetModel("GY0MASTER"):GetValue('GY0_DTVORC') >= dDataBase
EndIf

If  lValOrc

	oModel := FWLoadModel('CNTA301')
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	//Cabeçalho do Contrato  - //GY0MASTER
	oModel:SetValue('CN9MASTER','CN9_NUMERO', cContrat)
	oModel:SetValue('CN9MASTER','CN9_DTINIC', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_DTINIC'))
	oModel:SetValue('CN9MASTER','CN9_UNVIGE', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_UNVIGE'))
	oModel:SetValue('CN9MASTER','CN9_VIGE',   oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_VIGE'))
	oModel:SetValue('CN9MASTER','CN9_MOEDA',  oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_MOEDA')) 
	oModel:SetValue('CN9MASTER','CN9_TPCTO',  oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_TPCTO'))
	oModel:SetValue('CN9MASTER','CN9_CONDPG', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CONDPG'))
	If GY0->(FieldPos("GY0_NATURE")) > 0
		oModel:SetValue('CN9MASTER','CN9_NATURE', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_NATURE'))
	EndIf
	oModel:SetValue('CN9MASTER','CN9_AUTO',  '1')    
	//Vendedor do Contrato
	oModel:LoadValue('CNUDETAIL','CNU_CODVD'   , oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CODVD'))
	oModel:LoadValue('CNUDETAIL','CNU_PERCCM'  , oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_PCOMVD'))

	//Planilhas do Contrato
	oModel:SetValue('CNADETAIL','CNA_NUMERO', StrZero(1, Len(CNA->CNA_NUMERO)))
	oModel:SetValue('CNADETAIL','CNA_CLIENT', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CLIENT'))
	oModel:SetValue('CNADETAIL','CNA_LOJACL', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_LOJACL'))		

	For nX := 1 to oModelOrc:GetModel('GYDDETAIL'):Length() //DADOS DA LINHA
		oModelOrc:GetModel('GYDDETAIL'):goline(nX)
	
		If  Empty(oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CLIENT')) .AND. Empty(oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOJACL'))
			oModelOrc:LoadValue('GYDDETAIL','GYD_CLIENT',oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CLIENT'))
			oModelOrc:LoadValue('GYDDETAIL','GYD_LOJACL',oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_LOJACL'))
		EndIf

		If !Empty(oModelOrc:GetValue('GYDDETAIL','GYD_CLIENT')) .AND. !Empty(oModelOrc:GetValue('GYDDETAIL','GYD_LOJACL'))
				//Cliente/Fornecedor do Contrato
				oModel:GetModel('CNCDETAIL'):AddLine()
				oModel:SetValue('CNCDETAIL','CNC_CLIENT', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CLIENT'))
				oModel:SetValue('CNCDETAIL','CNC_LOJACL', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOJACL'))
				//Planilhas do Contrato
				oModel:GetModel('CNADETAIL'):AddLine()
				oModel:SetValue('CNADETAIL','CNA_NUMERO', StrZero(nX, Len(CNA->CNA_NUMERO)))
				oModel:SetValue('CNADETAIL','CNA_CLIENT', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CLIENT'))
				oModel:SetValue('CNADETAIL','CNA_LOJACL', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOJACL'))
		EndIf

		oModel:SetValue('CNADETAIL','CNA_TIPPLA', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_TIPPLA'))
		
		If GYD->(FieldPos("GYD_CODCNA")) > 0
			oModelOrc:SetValue('GYDDETAIL','GYD_CODCNA', oModel:GetModel('CNADETAIL'):GetValue('CNA_NUMERO', oModel:GetModel('CNADETAIL'):Length()))
		Endif	
	Next nX
	//GQZ-CUSTOS ADICIONAIS/CORTESIA
	//GQJ-Custo Cadastral
	//GYX-Custo Linha
	For nX := 1 to oModelOrc:GetModel('GQJDETAIL'):Length() //Custo Cadastral
		oModelOrc:GetModel('GQJDETAIL'):goline(nX)
		nTotCadast += oModelOrc:GetModel('GQJDETAIL'):GetValue('GQJ_VALTOT')
	Next nX 

	Begin Transaction

	If (oModel:VldData()) /*Valida o modelo como um todo*/
		oModel:CommitData()//--Grava Contrato

		If G900GerLin(oModelOrc)
			oModelOrc:SetValue('GY0MASTER','GY0_CODCN9', cContrat)	
			oModelOrc:SetValue('GY0MASTER','GY0_STATUS', '2')
			If (oModelOrc:VldData())
				oModelOrc:CommitData()
				FwAlertSuccess(STR0021) //"Contrato gerado com sucesso","'Ok'
			EndIf
		Else
			lRet := .F.
			DisarmTransaction()
			Break	
		EndIf
	Else
		cMsgErro := Alltrim(oModel:GetErrorMessage()[6]) + ". " + Alltrim(oModel:GetErrorMessage()[7])
		Help(,,"G900GerCtr",, cMsgErro, 1,0)
	EndIf

	End Transaction

	If lRet
		DbSelectArea("CN9")
		CN9->(dbSetOrder(1))

		If CN9->(dbSeek(xFilial('CN9')+cContrat)) 
			RecLock("CN9", .F.)
				CN9->CN9_SITUAC := '05'
			MsUnLock()
			lRet:= .T.
		EndIf
		IF !IsBlind() .AND. lRet
			If MsgYesNo(STR0048, STR0020) //"Deseja gerar as viagens agora?","Atenção"
				lRet := G900GerVia(1)
			Endif
		EndIf
	Endif
Else
	lRet:= .F.
	FwAlertWarning(STR0143,STR0020)
EndIf

Return lRet

/*/{Protheus.doc} G900GerLin
(long_description)
@type  Static Function
@author Osmar Cioni
@since 19/08/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900GerLin(oModelOrc)
Local lRet 		:= .T.
Local oModel 	:= FwLoadModel("GTPA002")
Local oMdlGI2	:= Nil
Local oMdlG5I	:= Nil
Local nX		:= Nil
Local nY		:= Nil
Local cMsgErro  := ""
Local aLoc		:= {}
Local nSeq		:= 2
Local cCodOri	:= ''
Local cLocIni	:= ''
Local dDtIniGQI 
Local cHrIniGQI := ''
Local dDtFimGQI 
Local cHrFimGQI := ''

	For nX := 1 to oModelOrc:GetModel('GYDDETAIL'):Length() //DADOS DA LINHA
		
		oModelOrc:GetModel('GYDDETAIL'):goline(nX)
		If EMPTY(oModelOrc:GetModel('GYDDETAIL'):GetValue("GYD_LOCINI")) .AND. EMPTY(oModelOrc:GetModel('GYDDETAIL'):GetValue("GYD_LOCFIM"))
			Help(,,"G900GerLin",, STR0086, 1,0) // "Não foi cadastrado linha para esse orçamento"
			lRet := .F.
			EXIT
		EndIf
		If lRet
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			
			If oModel:Activate()
				oMdlGI2 := oModel:GetModel('FIELDGI2')
				oMdlG5I := oModel:GetModel('GRIDG5I')

				
				oMdlGI2:SetValue('GI2_ORGAO',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_ORGAO')) 
				oMdlGI2:SetValue('GI2_CATEG',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_TPCARR')) 
				oMdlGI2:SetValue('GI2_PREFIX','CONTRATO')
				oMdlGI2:LoadValue('GI2_TIPLIN',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_TIPLIN'))
				oMdlGI2:LoadValue('GI2_LOCINI',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCINI'))
				oMdlGI2:LoadValue('GI2_LOCFIM',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCFIM'))
				oMdlGI2:SetValue('GI2_KMIDA',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_KMIDA'))
				oMdlGI2:SetValue('GI2_KMVOLT',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_KMVOLT'))
				oMdlGI2:SetValue('GI2_KMTOTA',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_KMIDA')+oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_KMVOLT'))

				
				oMdlGI2:LoadValue('GI2_LOCINI',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCINI'))
				oMdlGI2:LoadValue('GI2_LOCFIM',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCFIM'))

				oModel:GetModel('GRIDG5I'):AddLine()
				cLocIni:= oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCINI')
				oMdlG5I:SetValue('G5I_SEQ','001')
				oMdlG5I:SetValue('G5I_LOCALI',cLocIni)
				oMdlG5I:SetValue('G5I_VENDA','1')
				
				//KM INICIAL 
				For nY := 1 to oModelOrc:GetModel('GQIDETAIL'):Length()
					oModelOrc:GetModel('GQIDETAIL'):goline(nY)
					cCodOri:= oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_CODORI')
					cCodDes:= oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_CODDES')
						If cCodOri == cLocIni .OR. cCodDes == cLocIni
							dDtIniGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTORIG')
							cHrIniGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG'),'99:99')
							dDtFimGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTDEST')
							cHrFimGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRDEST'),'99:99')
							oMdlG5I:SetValue('G5I_KM',oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_KM'))
							oMdlG5I:SetValue('G5I_TEMPO',StrTran(GTDeltaTime(dDtIniGQI,cHrIniGQI,dDtFimGQI,cHrFimGQI),':',''))
							Exit
						EndIf
				Next

				oModel:GetModel('GRIDG5I'):AddLine()
				oMdlG5I:SetValue('G5I_SEQ','999')
				oMdlG5I:SetValue('G5I_LOCALI',oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCFIM'))
				oMdlG5I:SetValue('G5I_VENDA','1')

				aAdd(aLoc,oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCINI'))
				aAdd(aLoc,oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOCFIM'))
				dDtIniGQI := Nil
				cHrIniGQI := ''
				dDtFimGQI := Nil
				cHrFimGQI := ''
				For nY := 1 to oModelOrc:GetModel('GQIDETAIL'):Length()
					oModelOrc:GetModel('GQIDETAIL'):goline(nY)
					
					cCodOri:= oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_CODORI')

					If aScan(aLoc,cCodOri) == 0 
						dDtIniGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTORIG')
						cHrIniGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG'),'99:99')
						dDtFimGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTDEST')
						cHrFimGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRDEST'),'99:99')
						oModel:GetModel('GRIDG5I'):AddLine()
						oMdlG5I:SetValue('G5I_SEQ',StrZero(nSeq,TamSx3('G5I_SEQ')[1]))
						oMdlG5I:SetValue('G5I_LOCALI',cCodOri)
						oMdlG5I:SetValue('G5I_KM',oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_KM'))
						oMdlG5I:SetValue('G5I_TEMPO',StrTran(GTDeltaTime(dDtIniGQI,cHrIniGQI,dDtFimGQI,cHrFimGQI),':',''))
						oMdlG5I:SetValue('G5I_VENDA','1') 
						aAdd(aLoc,cCodOri)
						nSeq++
					EndIf

				Next nY

				If (oModel:VldData())
					oModel:CommitData()
					oModelOrc:GetModel('GYDDETAIL'):SetValue('GYD_CODGI2', oMdlGI2:GetValue('GI2_COD') )
					lRet := G900GerSer(oModelOrc)					
				Else
					cMsgErro := Alltrim(oModel:GetErrorMessage()[6]) + ". " + Alltrim(oModel:GetErrorMessage()[7])
					Help(,,"G900GerLin",, cMsgErro, 1,0)
					lRet := .F.
				EndIf

				oModel:DeActivate()

			Endif
		EndIf
	Next nX

Return lRet

/*/{Protheus.doc} GTPA900CAN
(long_description)
@type  Static Function
@author Osmar Cioni
@since 19/08/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA900CAN()

If GY0->GY0_STATUS != '2' .Or. GY0->GY0_ATIVO == '2'
	FwAlertWarning(STR0078, STR0075) // "Status do orçamento de contrato não permite o seu cancelamento", "Opção válida apenas para contratos com status 'Contrato gerado'"
	Return
Else
	GTPA900D()
Endif

Return

/*/{Protheus.doc} GTPA900ENC
(long_description)
@type  Static Function
@author flavio.martins
@since 26/04/2021
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA900ENC()
Local lRet := .T.

If GY0->GY0_STATUS != '2' 
	FwAlertWarning(STR0074, STR0075) // "Status do orçamento de contrato não permite o seu encerramento", "Opção válida apenas para contratos com status 'Contrato gerado'"
	Return
Else
	CN9->(dbSetOrder(1))
	If CN9->(dbSeek(xFilial("CN9") + GY0->GY0_CODCN9))
		FwMsgRun( ,{|| lRet := CN100SitCh(CN9->CN9_NUMERO,CN9->CN9_REVISA,"08",,.F.)},, STR0077) // "Finalizando contrato..." 	

		If lRet
			RecLock("GY0",.F.)
			GY0->GY0_STATUS := '4'
			GY0->(MsUnlock())
		Else
			FwAlertHelp(STR0076) // "Erro ao finalizar o contrato"
		Endif
	Endif

Endif

Return


/*/{Protheus.doc} G900GerSer
(long_description)
@type  Static Function
@author Osmar Cioni
@since 28/09/2020
@version 1.0
@param oView, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900GerSer(oModelOrc)

	Local oModel	  	:= Nil
	Local oMdlGID	  	:= Nil
	Local oMdlGIE     	:= Nil
	
	Local cMsgErro    	:= ''
	Local cHrIniGQI		:= ''
	Local cHrFimGQI		:= ''
	Local cSentido		:= ''
	
	Local nY		  	:= 0
	Local nLength		:= 0
	Local nSeq			:= 0

	Local dDtIniGQI		:= StoD("") 
	Local dDtFimGQI		:= StoD("") 
	
	Local lRet := .T.
	Local lExecSer	  := GYD->(FieldPos("GYD_LOTACA")) > 0 .AND. GYD->(FieldPos("GYD_SENTID")) > 0 .AND. GYD->(FieldPos("GYD_INIVIG")) > 0 .AND. GYD->(FieldPos("GYD_FINVIG")) > 0
	Local lHeaderWriter	:= .T.

	If lExecSer
		
		oModel	:= FwLoadModel("GTPA004")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		
		oMdlGID := oModel:GetModel('GIDMASTER')
		oMdlGIE := oModel:GetModel('GIEDETAIL')
		
		nLength	:= oModelOrc:GetModel('GQIDETAIL'):Length()
		
		For nY := 1 to nLength	// For nIdaVolta := 1 To 2	
			
			cSentido := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_SENTID',nY)
			
			If ( lHeaderWriter )
				nSeq := 0
				oModel:Activate()
			
				lRet := oMdlGID:SetValue ('GID_LINHA',	oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CODGI2'))	.And.;
					oMdlGID:LoadValue('GID_INIVIG',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_INIVIG'))	.And.;
					oMdlGID:LoadValue('GID_FINVIG',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_FINVIG'))	.And.;
					oMdlGID:LoadValue('GID_LOTACA',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_LOTACA'))	.And.;
					oMdlGID:LoadValue('GID_SEG',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_SEG'))	.And.;
					oMdlGID:LoadValue('GID_TER',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_TER'))	.And.;
					oMdlGID:LoadValue('GID_QUA',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_QUA'))	.And.;
					oMdlGID:LoadValue('GID_QUI',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_QUI'))	.And.;
					oMdlGID:LoadValue('GID_SEX',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_SEX'))	.And.;
					oMdlGID:LoadValue('GID_SAB',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_SAB'))	.And.;
					oMdlGID:LoadValue('GID_DOM',		oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_DOM'))	.And.;	
					oMdlGID:LoadValue('GID_SENTID',		cSentido)	.And.; 
					oMdlGID:LoadValue('GID_HORCAB',		oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG',nY))
				
				lHeaderWriter := .f.

			EndIf

			If ( lRet )

				dDtIniGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTORIG',nY)
				cHrIniGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG',nY),'99:99')
				
				dDtFimGQI := oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_DTDEST',nY)
				cHrFimGQI := GTFormatHour(oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRDEST',nY),'99:99')
				
				If ( nY > 1 )
					oModel:GetModel('GIEDETAIL'):SetNoInsertLine(.F.)                                
					oModel:GetModel('GIEDETAIL'):AddLine()
				EndIf
				nSeq++
				oMdlGIE:LoadValue('GIE_SEQ', StrZero(nSeq,TamSx3("GIE_SEQ")[1])	)//oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_SEQ',nY)
				oMdlGIE:LoadValue('GIE_SENTID',	cSentido)
				oMdlGIE:LoadValue('GIE_HORCAB',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG',nY))
				oMdlGIE:LoadValue('GIE_HORLOC',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRORIG',nY))	
				oMdlGIE:LoadValue('GIE_IDLOCP',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_CODORI',nY)) 
				oMdlGIE:LoadValue('GIE_HORDES',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRDEST',nY))
				oMdlGIE:LoadValue('GIE_IDLOCD',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_CODDES',nY))
				oMdlGIE:LoadValue('GIE_TEMPO',	StrTran(GTDeltaTime(dDtIniGQI,cHrIniGQI,dDtFimGQI,cHrFimGQI),':',''))
				
				If ( (nY == nLength) .Or.;
					(nY < nLength .and. cSentido <> oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_SENTID',(nY+1))))
				
					oMdlGID:LoadValue('GID_HORFIM',	oModelOrc:GetModel('GQIDETAIL'):GetValue('GQI_HRDEST',nY))
				
					If (oModel:VldData())
						oModel:CommitData()									
					Else
						cMsgErro := Alltrim(oModel:GetErrorMessage()[6]) + ". " + Alltrim(oModel:GetErrorMessage()[7])
						Help(,,"G900GerSer",, cMsgErro, 1,0)								
						lRet := .F.
					EndIf

					oModel:DeActivate()		

					lHeaderWriter := .T.

				EndIf

			EndIf

		Next nY //antes, era next nIdaVolta

	EndIf

Return lRet

/*/{Protheus.doc} G900GerVia
(long_description)
@type  Static Function
@author flavio.martins
@since 01/10/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/'
Function G900GerVia(nOpc)
Local lRet 		:= .T.
Local oMdl300B	
Local oMdl300C
Local oModelOrc 



If MSGYESNO( STR0149,STR0150 ) //'Deseja Gerar viagens do Contrato posicionado?', 'Gerar Viagens'
	oModelOrc := FwLoadModel('GTPA900')
	oModelOrc:SetOperation(MODEL_OPERATION_VIEW)
	oModelOrc:Activate()
EndIf
If !(GY0->GY0_STATUS $ '2|6') .And. nOpc != 2
	FwAlertWarning(STR0115) // "Status do contrato não permite a geração de viagens")
	Return .F.
Endif

If nOpc == 1

	oMdl300B := FwLoadModel("GTPA300B")
	oMdl300B:SetOperation(MODEL_OPERATION_UPDATE)

	If oModelOrc <> Nil
		oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('*', MODEL_FIELD_WHEN, {||.F.})
	Else
		oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('TPVIAGEM'	, MODEL_FIELD_WHEN, {||.F.})
		oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('EXTRA'		, MODEL_FIELD_WHEN, {||.F.})
	Endif

	oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('DATAINI', MODEL_FIELD_WHEN,  {||.T.})
	oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('DATAFIM', MODEL_FIELD_WHEN,  {||.T.})
	oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('LINHAINI', MODEL_FIELD_WHEN, {||.T.})
	oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('LINHAFIM', MODEL_FIELD_WHEN, {||.T.})

	oMdl300B:Activate()

	oMdl300B:GetModel('HEADER'):LoadValue('OPCAO', 1)
	oMdl300B:GetModel('HEADER'):LoadValue('TPVIAGEM', '3')
	oMdl300B:GetModel('HEADER'):LoadValue('EXTRA', '2')

	If oModelOrc <> Nil 

		oMdl300B:GetModel('HEADER'):LoadValue('DATAINI', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_INIVIG'))
		oMdl300B:GetModel('HEADER'):LoadValue('DATAFIM', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_FINVIG'))
		oMdl300B:GetModel('HEADER'):LoadValue('CLIEINI', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CLIENT'))
		oMdl300B:GetModel('HEADER'):LoadValue('LOJAINI', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_LOJACL'))
		oMdl300B:GetModel('HEADER'):LoadValue('CLIEFIM', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_CLIENT'))
		oMdl300B:GetModel('HEADER'):LoadValue('LOJAFIM', oModelOrc:GetModel('GY0MASTER'):GetValue('GY0_LOJACL'))
		oMdl300B:GetModel('HEADER'):LoadValue('CONTRINI', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_NUMERO'))
		oMdl300B:GetModel('HEADER'):LoadValue('CONTRFIM', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_NUMERO'))
		oMdl300B:GetModel('HEADER'):LoadValue('LINHAINI', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CODGI2', 1))
		oMdl300B:GetModel('HEADER'):LoadValue('LINHAFIM', oModelOrc:GetModel('GYDDETAIL'):GetValue('GYD_CODGI2', oModelOrc:GetModel('GYDDETAIL'):GetLine()))

	Endif

	GTPA300B(oMdl300B)
	
	oMdl300B:DeActivate()
	oMdl300B:Destroy()	

ElseIf nOpc == 2

	oMdl300B := FwLoadModel("GTPA300B")
	oMdl300B:SetOperation(MODEL_OPERATION_UPDATE)

	oMdl300B:GetModel('HEADER'):GetStruct():SetProperty('TPVIAGEM', MODEL_FIELD_WHEN, {||.F.})

	oMdl300B:Activate()

	oMdl300B:GetModel('HEADER'):LoadValue('OPCAO', 2)
	oMdl300B:GetModel('HEADER'):LoadValue('TPVIAGEM', '3')

	GTPA300B(oMdl300B)
	
	oMdl300B:DeActivate()
	oMdl300B:Destroy()	

ElseIf nOpc == 3

	oMdl300C := FwLoadModel("GTPA300C")
	oMdl300C:SetOperation(MODEL_OPERATION_UPDATE)

	oMdl300C:Activate()

	oMdl300C:GetModel('HEADER'):GetStruct():SetProperty('TPVIAGEM', MODEL_FIELD_WHEN, {||.F.})
	oMdl300C:GetModel('HEADER'):LoadValue('TPVIAGEM', '3')

	GTPA300C(oMdl300C)

	oMdl300C:DeActivate()
	oMdl300C:Destroy()	

Endif

Return lRet

/*/{Protheus.doc} AfterActiv
//TODO Descrição auto-gerada.
@author GTP
@since 16/11/2020
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/
Static Function AfterActiv(oView)
Local oModel := oView:GetModel()

If Empty(oModel:GetModel('GY0MASTER'):GetValue('GY0_REVISA'))
	oView:HideFolder('FOLDER',3, 2)
	oView:SelectFolder("FOLDER",1,2)
Endif

oView:Refresh()

If oModel:GetModel('GY0MASTER'):GetValue('GY0_MOTREV') == '2' .And.;
	oModel:GetOperation() == MODEL_OPERATION_INSERT
	GTPA900A(oView)
Endif

Return

/*/
{Protheus.doc} G900Ctr()"
(long_description)
@type  Function
@author Eduardo Ferreira
@since 19/03/2021
@version 12.1.30
@param 
@return 
/*/
Function G900Ctr()
Local cCodigo := ''
Local cStatus := ''

If GY0->(FieldPos("GY0_CODCN9")) > 0
	cCodigo := GY0->GY0_CODCN9
EndIf

If GY0->(FieldPos("GY0_STATUS")) > 0
	cStatus := GY0->GY0_STATUS
EndIf

IF cStatus != '1'
	DbSelectArea("CN9")
	CN9->(dbSetOrder(1))

	If CN9->(dbSeek(xFilial('CN9')+cCodigo)) 
		FWMsgRun(, {||FWExecView(STR0059,"CNTA301",MODEL_OPERATION_VIEW,,{|| .T.})},"", STR0060) //Contrato //Buscando Contrato		
	EndIf
Else
	MsgAlert(STR0061, STR0062) //Não foi gerado contrato //Atenção
EndIf

Return 

/*/{Protheus.doc} VldCn1()
(long_description)
@type  Static Function
@author Eduardo Ferreira
@since 23/03/2021
@version 12.1.30
@param cod
@return lRet
/*/
Static Function VldCn1(cod)
Local cAliasCn1 := GetNextAlias()
Local cMsgVld	:= ''

BeginSql Alias cAliasCn1
	SELECT 
		CN1.CN1_ESPCTR,
		CN1.CN1_CTRFIX,
		CN1.CN1_VLRPRV,
		CN1.CN1_MEDEVE
		
	FROM 
		%Table:CN1% CN1
	WHERE 
		CN1.CN1_FILIAL = %xFilial:CN1% AND
		CN1.CN1_CODIGO = %Exp:cod% AND
		CN1.%NotDel% 
EndSql

If (cAliasCn1)->CN1_ESPCTR <> '2'
	cMsgVld := STR0065 // "Espécie do tipo de contrato diferente de Venda"
	Return cMsgVld
Endif

If (cAliasCn1)->CN1_CTRFIX <> '2'
	cMsgVld := STR0066 // "Contrato selecionado não pode ser do tipo fixo"
	Return cMsgVld
Endif

If (cAliasCn1)->CN1_VLRPRV <> '2'
	cMsgVld := STR0067 // "Contrato selecionado deve estar configurado com Previsão Financeira igual a 'Não'"
	Return cMsgVld
Endif

If (cAliasCn1)->CN1_MEDEVE <> '1'
	cMsgVld := STR0068 // "Contrato selecionado deve estar configurado com Medição Eventual igual a 'Sim'"
	Return cMsgVld
Endif

(cAliasCn1)->(dbCloseArea())

Return cMsgVld

/*/{Protheus.doc} VldCnl()
(long_description)
@type  Static Function
@author Eduardo Ferreira
@since 23/03/2021
@version 12.1.30
@param cod
@return lRet
/*/
Static Function VldCnl(cod)
Local cAliasCnl := GetNextAlias()
Local cMsgVld	:= ''

BeginSql Alias cAliasCnl
	SELECT 
		CNL.CNL_CTRFIX,
		CNL.CNL_VLRPRV,
		CNL.CNL_MEDEVE
	FROM 
		%Table:CNL% CNL
	WHERE 
		CNL.CNL_FILIAL = %xFilial:CNL% AND
		CNL.CNL_CODIGO = %Exp:cod% AND
		CNL.%NotDel% 
EndSql

If !((cAliasCnl)->CNL_MEDEVE $ '0|1')
	cMsgVld :=  STR0069 // "Medição eventual do tipo de planilha não pode estar configurada como 'Não'"
	Return cMsgVld
Endif

If !((cAliasCnl)->CNL_CTRFIX $ '0|2')
	cMsgVld :=  STR0070 // "Tipo de planilha deve estar configurada como 'Fixo' ou 'Conforme Contrato'"
	Return cMsgVld
Endif

If !((cAliasCnl)->CNL_VLRPRV $ '0|2')
	cMsgVld :=  STR0071 // "Previsão financeira do tipo de planilha deve estar configurada como 'Não' ou 'Conforme Contrato'"
	Return cMsgVld
Endif

(cAliasCnl)->(dbCloseArea())

Return cMsgVld

/*/{Protheus.doc} UpdDelCtr()
(long_description)
@type  Function
@author Eduardo Ferreira
@since 24/03/2021
@version version
@param  nOper
@return lRet
/*/
Function UpdDelCtr(nOper)
Local cStatus 	:= ''
Local lRet    	:= .T.	
Local cMsgErro	:= ''
Local oModel	:= FwLoadModel('GTPA900')

If ValidaDic(@cMsgErro)

	oModel:SetOperation(nOper)

	If GY0->GY0_MOTREV == '2'
		ConfigModel(oModel, 2)
	Endif

	oModel:Activate()

	If GY0->(FieldPos("GY0_STATUS")) > 0
		cStatus := GY0->GY0_STATUS
	EndIf

	If (nOper = 4 .Or. nOper = 5) .And. cStatus $ '2|3|6|7'
		MsgAlert(STR0063, STR0064) //'Este registro não pode ser alterado ou excluído.' // Contrato gerado
		lRet := .F.
	Else
		if nOper = 4
			FwExecView(STR0003,"VIEWDEF.GTPA900",MODEL_OPERATION_UPDATE,,,,/*5*/,/*aEnableButtons*/,,,,oModel) // 'Alterar'
		else
			FwExecView(STR0004,"VIEWDEF.GTPA900",MODEL_OPERATION_DELETE,,,,/*5*/,/*aEnableButtons*/,,,,oModel) // 'Excluir'
		endif
	EndIf	

Else
    FwAlertHelp(cMsgErro, STR0017)	// "Banco de dados desatualizado, não é possível iniciar a rotina"
Endif

oModel:Deactivate()
oModel:Destroy()

Return lRet

/*/{Protheus.doc} G900IniRev()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function G900IniRev(nOpc)
Local lRet 		:= .T.
Local cMsgErro	:= ''
Local oMdlRev	:= FwLoadModel('GTPA900')
Local cNumero   := GY0->GY0_NUMERO

If ValidaDic(@cMsgErro)

	If GY0->GY0_STATUS != '2' .And. GY0->GY0_STATUS != '6'
		FwAlertHelp(STR0087) //'Status atual do orçamento não permite revisão
		Return
	Endif

	If ExistRevisa()
		FwAlertHelp(STR0096) //'Contrato já possui uma revisão em andamento'
		Return
	Endif

	If nOpc == 2 .And. GY0->GY0_FLGREJ == '2'
		FwAlertHelp(STR0105) //"Configuração do contrato não permite reajustes"
		Return
	Endif

	oMdlRev:SetOperation(MODEL_OPERATION_INSERT)

	ConfigModel(oMdlRev, nOpc)

	oMdlRev:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_NUMERO' , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD , '' ) )
	oMdlRev:Activate(.T.)

	oMdlRev:SetValue('GY0MASTER', 'GY0_NUMERO', cNumero)
	oMdlRev:LoadValue('GY0MASTER', 'GY0_STATUS', '5')

	Do Case
		Case nOpc = 1
			oMdlRev:GetModel('GY0MASTER'):LoadValue('GY0_MOTREV', '1')
		Case nOpc = 2
			oMdlRev:LoadValue('GY0MASTER', 'GY0_MOTREV', '2')
			oMdlRev:LoadValue('GYYFIELDS', 'GYY_NUMERO', oMdlRev:GetValue('GY0MASTER','GY0_NUMERO'))
	EndCase

	FwExecView(STR0099,"VIEWDEF.GTPA900",MODEL_OPERATION_INSERT,,,,/*5*/,/*aEnableButtons*/,,,,oMdlRev) //"Revisão"
Else
    FwAlertHelp(cMsgErro, STR0017)	// "Banco de dados desatualizado, não é possível iniciar a rotina"
Endif

Return lRet

/*/{Protheus.doc} ConfigModel(oModel, nOpc)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 19/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ConfigModel(oModel, nOpc)
Local aNCopyGY0	:= {'GY0_ATIVO','GY0_TIPREV','GY0_MOTREV','GY0_JUSREV','GY0_DATREV'}
Local aNCopyGYY	:= {'GYY_PERGYD','GYY_PERGQZ','GYY_PERGYX','GYY_PERGQJ'}

oModel:GetModel("GYYFIELDS"):SetFldNoCopy(aNCopyGYY)
oModel:GetModel("GY0MASTER"):SetFldNoCopy(aNCopyGY0)
oModel:GetModel("GYDDETAIL"):SetFldNoCopy({'GYD_REVISA'})
oModel:GetModel("GQIDETAIL"):SetFldNoCopy({'GQI_REVISA'})
oModel:GetModel("GYXDETAIL"):SetFldNoCopy({'GYX_REVISA'})
oModel:GetModel("GQZDETAIL"):SetFldNoCopy({'GQZ_REVISA'})
oModel:GetModel("GQJDETAIL"):SetFldNoCopy({'GQJ_REVISA'})
oModel:GetModel("GYYFIELDS"):SetFldNoCopy({'GYY_REVISA'})

If nOpc == 1
	oModel:GetModel('GYYFIELDS'):SetOnlyQuery(.T.)
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_CLIENT' , MODEL_FIELD_WHEN, {||.F.})
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_LOJACL' , MODEL_FIELD_WHEN, {||.F.})
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_CODVD'  , MODEL_FIELD_WHEN, {||.F.})
ElseIf nOpc == 2
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('*' , MODEL_FIELD_WHEN, {||.F.})
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_TIPREV' , MODEL_FIELD_WHEN, {||.T.})
	oModel:GetModel('GY0MASTER'):GetStruct():SetProperty('GY0_JUSREV' , MODEL_FIELD_WHEN, {||.T.})

	oModel:GetModel('GYDDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GYDDETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel('GYDDETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('GQJDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GQJDETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel('GQJDETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('GYXDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GYXDETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel('GYXDETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('GQZDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GQZDETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel('GQZDETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('GQIDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GQIDETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel('GQIDETAIL'):SetNoDeleteLine(.T.)
Endif

Return

/*/{Protheus.doc} ExistRevisa()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 19/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ExistRevisa()
Local lRet 		:= .F.
Local cAliasGY0	:= GetNextAlias()

BeginSql Alias cAliasGY0
	SELECT GY0_NUMERO FROM %Table:GY0%
	WHERE
	GY0_NUMERO = %Exp:GY0->GY0_NUMERO%
	AND GY0_STATUS = '5'
	AND %NotDel%
EndSql

lRet :=  !Empty((cAliasGY0)->GY0_NUMERO)

(cAliasGY0)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} SetRevisao()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function SetRevisao(oModel)
Local cAliasGY0		:= GetNextAlias()
Local cRevisao		:= 0
Local cNumero		:= Alltrim(oModel:GetModel('GY0MASTER'):GetValue('GY0_NUMERO'))

If Empty(cNumero)
	cNumero := GY0->GY0_NUMERO
EndIf
	
BeginSql Alias cAliasGY0

	SELECT MAX(GY0_REVISA) NUMREV
	FROM %Table:GY0%
	WHERE GY0_FILIAL = %xFilial:GY0%
	  AND GY0_NUMERO = %Exp:cNumero%
	  AND %NotDel%

EndSql
If Empty((cAliasGY0)->NUMREV )
	cRevisao:= 0
Else
	cRevisao:= Val((cAliasGY0)->NUMREV)
EndIf

cRevisao := StrZero((cRevisao+1),TamSx3('GY0_REVISA')[1])

(cAliasGY0)->(dbCloseArea())

Return cRevisao

/*/{Protheus.doc} G900GerRev()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function G900GerRev()
Local lRet		:= .T.
Local oModel	:= FwLoadModel('GTPA900')
Local nPercReaj := 0
Local cTipoRev 	:= ''
Local cJustRev	:= ''
Local cMsgErro	:= ''

If ValidaDic(@cMsgErro)

	If GY0->GY0_STATUS != '5' 
		FwAlertHelp(STR0102) // "Opção válida apenas para contratos em revisão"
		Return
	Endif

	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	cTipoRev := oModel:GetModel('GY0MASTER'):GetValue('GY0_TIPREV')
	cJustRev := oModel:GetModel('GY0MASTER'):GetValue('GY0_JUSREV')

	If Empty(cTipoRev)
		FwAlertHelp(STR0088, STR0089) //'Tipo de revisão não informado', 'Tipo de revisão obrigatório'
		Return .F.
	Endif

	If Empty(cJustRev)
		FwAlertHelp(STR0090, STR0091) //'Justificativa da revisão não informado', 'Justificativa da revisão obrigatória'
		Return .F.
	Endif

	If oModel:GetModel('GY0MASTER'):GetValue('GY0_MOTREV') == '2'
		nPercReaj := oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGYD') +;
					oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGQJ') +;
					oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGYX') +;
					oModel:GetModel('GYYFIELDS'):GetValue('GYY_PERGQZ')

		If nPercReaj == 0
			FwAlertHelp(STR0100, STR0101) //'Nenhum percentual de reajuste foi informado', 'Informe os percentuais antes de efetivar a revisão'
			Return
		Endif

	Endif

	FwMsgRun( ,{|| lRet := GrvRevisa(oModel)},, STR0097) //"Gerando Revisão...." 
Else
    FwAlertHelp(cMsgErro, STR0017)	// "Banco de dados desatualizado, não é possível iniciar a rotina"
Endif

oModel:DeActivate()
oModel:Destroy()

Return lRet

/*/{Protheus.doc} GrvRevisa()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function GrvRevisa(oModel)
Local lRet 		:= .T.
Local oMdlCntr	:= Nil
Local nX		:= 0
Local cContrato	:= oModel:GetValue('GY0MASTER', 'GY0_CODCN9')
Local cRevAtu	:= oModel:GetValue('GY0MASTER', 'GY0_REVISA')
Local cRevVig	:= GetRevVig(oModel:GetValue('GY0MASTER', 'GY0_NUMERO'))
Local aProdLin  := {}

CN9->(dbSetOrder(1))
If CN9->(dbSeek(xFilial("CN9")+GY0->GY0_CODCN9+cRevVig))
 	
	Begin Transaction

 	A300STpRev("G")									
 	
 	oMdlCntr := FwLoadModel("CNTA300")			
	oMdlCntr:SetOperation(MODEL_OPERATION_INSERT)		
	 
	oMdlCntr:Activate(.T.) 

	If !(oMdlCntr:IsActive())
		If !(IsBlind())
			lRet := .F.
			DisarmTransaction()
	        JurShowErro(oMdlCntr:GetErrormessage())	
		Endif
	Else
		oMdlCntr:SetValue('CN9MASTER','CN9_TIPREV'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_TIPREV'))
		oMdlCntr:SetValue('CN9MASTER','CN9_JUSTIF'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_JUSREV'))

		oMdlCntr:SetValue('CN9MASTER','CN9_NUMERO'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_CODCN9'))
		oMdlCntr:SetValue('CN9MASTER','CN9_DTINIC'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_DTINIC'))
		oMdlCntr:SetValue('CN9MASTER','CN9_UNVIGE'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_UNVIGE'))
		oMdlCntr:SetValue('CN9MASTER','CN9_VIGE'  	, oModel:GetModel('GY0MASTER'):GetValue('GY0_VIGE'))
		oMdlCntr:SetValue('CN9MASTER','CN9_MOEDA'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_MOEDA')) 
		oMdlCntr:SetValue('CN9MASTER','CN9_TPCTO'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_TPCTO'))
		oMdlCntr:SetValue('CN9MASTER','CN9_CONDPG'	, oModel:GetModel('GY0MASTER'):GetValue('GY0_CONDPG'))
		If GY0->(FieldPos("GY0_NATURE")) > 0
			oMdlCntr:SetValue('CN9MASTER','CN9_NATURE', oModel:GetModel('GY0MASTER'):GetValue('GY0_NATURE'))
		EndIf
		oMdlCntr:SetValue('CN9MASTER','CN9_AUTO'	, '1')    
			
		//Cliente/Fornecedor do Contrato
		oMdlCntr:LoadValue('CNCDETAIL','CNC_CLIENT'  , oModel:GetModel('GY0MASTER'):GetValue('GY0_CLIENT'))
		oMdlCntr:LoadValue('CNCDETAIL','CNC_LOJACL'  , oModel:GetModel('GY0MASTER'):GetValue('GY0_LOJACL'))
	


		//Vendedor do Contrato
		oMdlCntr:LoadValue('CNUDETAIL','CNU_CODVD'   , oModel:GetModel('GY0MASTER'):GetValue('GY0_CODVD'))
		oMdlCntr:LoadValue('CNUDETAIL','CNU_PERCCM'  , oModel:GetModel('GY0MASTER'):GetValue('GY0_PCOMVD'))

		For nX := 1 To oMdlCntr:GetModel('CNADETAIL'):Length()
			oMdlCntr:GetModel('CNADETAIL'):GoLine(nX)
			oMdlCntr:GetModel('CNADETAIL'):DeleteLine()
		Next

		For nX := 1 to oModel:GetModel('GYDDETAIL'):Length() 
			oModel:GetModel('GYDDETAIL'):GoLine(nX)

			If aScan(aProdLin,{|x| x == AllTrim(oModel:GetModel('GYDDETAIL'):GetValue('GYD_PRODUT'))}) == 0

				Aadd(aProdLin, AllTrim(oModel:GetModel('GYDDETAIL'):GetValue('GYD_PRODUT')))

				If !Empty(oMdlCntr:GetModel('CNADETAIL'):GetValue('CNA_NUMERO'))
					oMdlCntr:GetModel('CNADETAIL'):AddLine()
				EndIf

				//Planilhas do Contrato
				oMdlCntr:LoadValue('CNADETAIL','CNA_NUMERO', StrZero(nX, Len(CNA->CNA_NUMERO)))
				oMdlCntr:SetValue('CNADETAIL','CNA_CLIENT', oModel:GetModel('GY0MASTER'):GetValue('GY0_CLIENT'))
				oMdlCntr:SetValue('CNADETAIL','CNA_LOJACL', oModel:GetModel('GY0MASTER'):GetValue('GY0_LOJACL'))
				oMdlCntr:SetValue('CNADETAIL','CNA_TIPPLA', oModel:GetModel('GY0MASTER'):GetValue('GY0_TIPPLA'))
			EndIf
		Next
	
		If oMdlCntr:VldData() 
			oMdlCntr:CommitData()
		Else
			lRet := .F.
			DisarmTransaction()
			JurShowErro(oMdlCntr:GetErrormessage())	
		Endif

		If lRet

			oMdlCntr:Deactivate()

			FwMsgRun( ,{|| lRet :=  AprovaRev(cContrato, cRevAtu)},, STR0106) //"Aprovando Revisão..."

			lRet := InativGY0()

			If lRet
				RecLock('GY0', .F.)
					GY0->GY0_ATIVO  := '1'
					GY0->GY0_STATUS := '6'
					GY0->GY0_DATREV := dDataBase
				GY0->(MsUnLock())

				FwAlertSuccess(STR0093) //'Revisão gerada com sucesso'
			Endif
		Endif
	
	Endif

	End Transaction

Else
	lRet := .F.
	FwAlertHelp(STR0092) //'Contrato não encontrado'
Endif

Return lRet

/*/{Protheus.doc} InativGY0
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function InativGY0()
Local lRet 		:= .T.
Local cAliasGY0	:= GetNextAlias()
Local aAreaGY0  := GY0->(GetArea()) 

BeginSql Alias cAliasGY0

	SELECT R_E_C_N_O_ AS Recno 
	FROM %Table:GY0%
	WHERE
	GY0_FILIAL = %xFilial:GY0%
	AND GY0_NUMERO = %Exp:GY0->GY0_NUMERO%
	AND GY0_ATIVO = '1'
	AND %NotDel%

EndSql

GY0->(dbGoto((cAliasGY0)->Recno))

RecLock('GY0', .F.)
	GY0->GY0_ATIVO  := '2'
	GY0->GY0_STATUS := '7'
GY0->(MsUnLock())

(cAliasGY0)->(dbCloseArea())

RestArea(aAreaGY0)

Return lRet

/*/{Protheus.doc} ValidaDic
//TODO Descrição auto-gerada.
@author flavio.martins
@since 11/05/2021
@version 1.0
@return ${return}, ${return_description}
@param
@type function
/*/
Static Function ValidaDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'GY0','GYD','GQI','GQZ','GYX','GQJ','GYY'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'GY0_REVISA','GY0_DATREV','GY0_JUSREV',;
            'GY0_TIPREV','GY0_ATIVO','GYD_REVISA',;
			'GQI_REVISA','GQZ_REVISA','GYX_REVISA',;
			'GQJ_REVISA','GYY_NUMERO','GYY_REVISA',;
			'GY0_MOTREV','GYY_PERGYD','GYY_PERGYX',;
			'GYY_PERGQJ','GYY_PERGQZ','GYD_VLRACO'}
			

For nX := 1 To Len(aTables)
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

if Empty(cMsgErro)
	For nX := 1 To Len(aFields)
	    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
	        lRet := .F.
	        cMsgErro := I18n("Campo #1 não se encontra no dicionário",{aFields[nX]})
	        Exit
	    Endif
	Next
EndIf

Return lRet

/*/{Protheus.doc} FieldWhen(oMdl, cField, uVal)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 12/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function FieldWhen(oMdl, cField, uVal)
Local lRet     := .T.
Local oModel   := oMdl:GetModel()
Local oMdlGY0  := oModel:GetModel('GY0MASTER')
Local oMdlGYD  := oModel:GetModel('GYDDETAIL')

Local nLineGYD := oMdlGYD:GetLine()

Do Case
	Case cField == "GY0_TIPREV"
        lRet := !Empty(oMdl:GetValue('GY0_REVISA'))
	Case cField == "GYD_VLRACO"  .AND. GYD->(FieldPos("GYD_VLRACO")) > 0
        lRet := oMdlGYD:GetValue('GYD_PRECON',nLineGYD) $ '2|3|4'
	Case cField == "GYD_VLRTOT"  .AND. GYD->(FieldPos("GYD_VLRTOT")) > 0
        lRet := oMdlGYD:GetValue('GYD_PLCONV',nLineGYD) != '1'
	Case cField == "GYD_VLREXT"  .AND. GYD->(FieldPos("GYD_VLREXT")) > 0
        lRet := oMdlGYD:GetValue('GYD_PLEXTR',nLineGYD) != '1'
	Case cField == "GYD_IDPLCO"  .AND. GYD->(FieldPos("GYD_IDPLCO")) > 0
        lRet := oMdlGYD:GetValue('GYD_PLCONV',nLineGYD) == '1'
	Case cField == "GYD_IDPLEX"  .AND. GYD->(FieldPos("GYD_IDPLEX")) > 0
        lRet := oMdlGYD:GetValue('GYD_PLEXTR',nLineGYD) == '1'
	Case cField == "GY0_VLRACO"  .AND. GY0->(FieldPos("GY0_VLRACO")) > 0
        lRet := oMdlGY0:GetValue('GY0_PLCONV') <> '1'	
	Case cField == "GY0_IDPLCO"  .AND. GY0->(FieldPos("GY0_IDPLCO")) > 0
        lRet := oMdlGY0:GetValue('GY0_PLCONV') == '1'
	Case cField == "GY0_PREEXT"  .AND. GY0->(FieldPos("GY0_PREEXT")) > 0
        lRet := oMdlGY0:GetValue('GY0_PLCONV') <> '1'
	Case cField == "GY0_PLCONV"  .AND. GY0->(FieldPos("GY0_PLCONV")) > 0
        lRet := oMdlGY0:GetValue('GY0_VLRACO') == 0
	Case cField == "GY0_ALTLOG"  .AND. GY0->(FieldPos("GY0_ALTLOG")) > 0
        lRet := .F.
	Case cField == "GQI_SENTID"  .AND. GQI->(FieldPos("GQI_SENTID")) > 0
        lRet := oMdlGYD:GetValue('GYD_SENTID',nLineGYD) == '3'
EndCase

Return lRet

/*/{Protheus.doc} GetRevVig(cNumero)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 11/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function GetRevVig(cNumero)
Local cAliasGY0	:= GetNextAlias()
Local cCodRev	:= ''

BeginSql Alias cAliasGY0 

	SELECT GY0_REVISA
		FROM %Table:GY0%
	WHERE	
	GY0_FILIAL = %xFilial:GY0%
	AND GY0_NUMERO = %Exp:cNumero%
	AND GY0_ATIVO = '1'
	AND %NotDel%

EndSql

If !Empty((cAliasGY0)->GY0_REVISA)
	cCodRev := (cAliasGY0)->GY0_REVISA
Endif

(cAliasGY0)->(dbCloseArea())

Return cCodRev

/*/{Protheus.doc} AprovaRev(cNumero, cRevisa)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 11/05/2021
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function AprovaRev(cNumero, cRevisa)
Local lRet 		:= .T.
Local cMsgErro	:= ''
Local nRet		:= 0

CN9->(dbSetOrder(1))
If CN9->(dbSeek(xFilial('CN9')+cNumero+cRevisa))
	
	nRet := CN300Aprov(.T.,,@cMsgErro) //- Função retorna 0 em caso de falha e 1 em caso de sucesso, também retorna a mensagem de erro por referência através do parâmetro cMsgErro.
	If nRet == 1
		lRet := .T.
	Else
		FwAlertHelp(STR0103+cNumero+ " "+cMsgErro) // "Erro na aprovação do contrato "
	EndIf

EndIf	

Return lRet

/*/{Protheus.doc} G900Commit(oModel)	
Commit do modelo
@author flavio.martins
@since 15/08/2021
@version 1.0
@return lógico
@type function
/*/
Static Function G900Commit(oModel)	
Local lRet		:= .T.
Local nOpc		:= oModel:GetOperation()
Local oMdl900B	:= Nil

lRet := FwFormCommit(oModel)

If (nOpc ==  3 .Or. nOpc == 4) 

	If AliasInDic('H69') .And. FindFunction('GTPA900B')

		oMdl900B := FwLoadModel('GTPA900B')
		oMdl900B:SetOperation(MODEL_OPERATION_UPDATE)
		oMdl900B:Activate()

		If oMdl900B:IsActive()
			G900BCopy(oMdl900B)

			If oMdl900B:VldData()
				oMdl900B:CommitData()
			Endif
		Endif

	Endif
	

Endif 

Return lRet

/*/{Protheus.doc} ValidDocs()	
Valida pendência de checklist dos documentos operacionais do contrato
@author flavio.martins
@since 22/08/2022
@version 1.0
@return lógico
@type function
/*/
Static Function ValidDocs()
Local lRet 	:= .T.

If ExistDocs()

	If !(IsBlind() )
		If FwAlertYesNo(STR0111, STR0020) //"Encontrado documentos obrigatórios para o contrato. Deseja realizar o checklist agora ? ", "Atenção"
			GTPA900C()
		EndIf
	Endif

	If ExistDocs()
		lRet := .F.
		FwAlertWarning(STR0112,STR0020) //"Preencha o campo data de Validade do Orçamento", "Atenção"
	Endif

Endif

Return lRet

/*/{Protheus.doc} ExistDocs()	
Verifica se existem documentos pendentes de checklist
@author flavio.martins
@since 22/08/2022
@version 1.0
@return lógico
@type function
/*/
Static Function ExistDocs()
Local lRet 		:= .T.
Local cAliasTmp	:= GetNextAlias()
If AliasInDic("H69")
	BeginSql Alias cAliasTmp 

		SELECT COALESCE(COUNT(H69_NUMERO), 0) AS TOTREG
		FROM %Table:H69%
		WHERE H69_FILIAL = %xFilial:H69%
		AND H69_NUMERO = %Exp:GY0->GY0_NUMERO%
		AND H69_REVISA = %Exp:GY0->GY0_REVISA%
		AND H69_EXIGEN IN ('1','3')
		AND H69_CHKLST = 'F'
		AND %NotDel%

	EndSql

	lRet := (cAliasTmp)->TOTREG > 0

	(cAliasTmp)->(dbCloseArea())
EndIf
Return lRet

/*/{Protheus.doc} G900VESLin
	(Valida se campos relacionados a cobrança de viagens extras sem linha estão preenchidos)
	@type  Function
	@author marcelo.adente
	@since 10/08/2022
	@version 1.0
	/*/
Function G900VESLin()
Local aArea := GetArea()

If !(GY0->GY0_STATUS $ '2|6')
	FwAlertWarning(STR0115) // "Status do contrato não permite a geração de viagens")
	Return .F.
Endif

DbSelectArea('GYN')

If GYN->(FieldPos("GYN_EXTCMP")) > 0
	If 	  GY0->(FieldPos("GY0_PREEXT")) > 0 ;
	.AND. GY0->(FieldPos("GY0_PRDEXT")) > 0 ;
	.AND. GY0->(FieldPos("GY0_PRONOT")) > 0 ;
	.AND. GY0->(FieldPos("GY0_VLRACO")) > 0 ;
	.AND. GY0->(FieldPos("GY0_PLCONV")) > 0 ;
	.AND. GY0->(FieldPos("GY0_IDPLCO")) > 0

		If (!Empty(GY0->GY0_PREEXT) .AND.;
			!Empty(GY0->GY0_PRDEXT) .AND.;
			!Empty(GY0->GY0_PRONOT) .AND.;
			!Empty(GY0->GY0_VLRACO)); 
			.OR.;
		(!Empty(GY0->GY0_PLCONV) .AND.;
			!Empty(GY0->GY0_IDPLCO))
			// Chama Rotina de criação de viagens  sem linha
			GTPA300(GY0->GY0_NUMERO,GY0->GY0_STATUS)
		Else
			MsgAlert(STR0108, STR0020)// 'Preencha os dados de Viagens Extra Sem Linha no Orçamento de Contrato', Atenção!
		EndIf
	EndIf
else
	MsgAlert(STR0144)
	RestArea(aArea)
EndIf

Return

/*/{Protheus.doc} g900GetOrder
	( Retorna Ordem dos Campos mencionados )
	@type  Static Function
	@author marcelo.adente
	@since 30/01/2023
	@version 1.0
	@param cCampo, String, Campo 
	@return cRet, String, Ordem associada
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function g900GetOrder(cCampo)
Local aCampo 	:= {}
Local cRet		:= ''

//Orçamento do Contrato
aAdd(aCampo,{'GY0_NUMERO','01'})
aAdd(aCampo,{'GY0_CLIENT','02'})
aAdd(aCampo,{'GY0_LOJACL','03'})
aAdd(aCampo,{'GY0_NOMCLI','04'})
aAdd(aCampo,{'GY0_CODVD','05'})
aAdd(aCampo,{'GY0_NOMVD','06'})

//VIGENCIAS
aAdd(aCampo,{'GY0_DTINIC','01'})
aAdd(aCampo,{'GY0_UNVIGE','02'})
aAdd(aCampo,{'GY0_VIGE'	 ,'03'})
aAdd(aCampo,{'GY0_DTVIGE','04'})
aAdd(aCampo,{'GY0_UNORCV','05'})
aAdd(aCampo,{'GY0_VALORC','06'})
aAdd(aCampo,{'GY0_DTVORC','07'})
aAdd(aCampo,{'GY0_ALTLOG','08'})
aAdd(aCampo,{'GY0_ASSINA','09'})

//GERAIS
aAdd(aCampo,{'GY0_FILIAL','01'})
aAdd(aCampo,{'GY0_MOEDA','02'})
aAdd(aCampo,{'GY0_CONDPG','03'})
aAdd(aCampo,{'GY0_TPCTO','04'})
aAdd(aCampo,{'GY0_FLGREJ','05'})
aAdd(aCampo,{'GY0_FLGCAU','06'})
aAdd(aCampo,{'GY0_PCOMVD','07'})
aAdd(aCampo,{'GY0_KMFRAN','08'})
aAdd(aCampo,{'GY0_PRODUT','09'})
aAdd(aCampo,{'GY0_DSCPRD','10'})
aAdd(aCampo,{'GY0_TIPPLA','11'})
aAdd(aCampo,{'GY0_TABPRC','12'})
aAdd(aCampo,{'GY0_STATUS','13'})
aAdd(aCampo,{'GY0_CODCN9','14'})
aAdd(aCampo,{'GY0_REVISA','15'})
aAdd(aCampo,{'GY0_MOTREV','16'})
aAdd(aCampo,{'GY0_DATREV','17'})
aAdd(aCampo,{'GY0_TIPREV','18'})
aAdd(aCampo,{'GY0_JUSREV','19'})
aAdd(aCampo,{'GY0_ATIVO','20'})
aAdd(aCampo,{'GY0_NATURE','21'})
aAdd(aCampo,{'GY0_DTCANC','22'})
aAdd(aCampo,{'GY0_USUCAN','23'})
aAdd(aCampo,{'GY0_OBSCAN','24'})

//EXTRAORDINARIA
aAdd(aCampo,{'GY0_PRDEXT','01'})
aAdd(aCampo,{'GY0_PRDDSC','02'})
aAdd(aCampo,{'GY0_PRONOT','03'})
aAdd(aCampo,{'GY0_DPRDNF','04'})
aAdd(aCampo,{'GY0_VLRACO','05'})
aAdd(aCampo,{'GY0_PLCONV','06'})
aAdd(aCampo,{'GY0_IDPLCO','07'})
aAdd(aCampo,{'GY0_PREEXT','08'})

//GERLOG
aAdd(aCampo,{'GY0_ALTLOG','01'})

//Dados da Linha
aAdd(aCampo,{'GYD_NUMERO','01'})
aAdd(aCampo,{'GYD_SEQ','02'})
aAdd(aCampo,{'GYD_CODGI2','03'})
aAdd(aCampo,{'GYD_SENTID','04'})
aAdd(aCampo,{'GYD_NUMCAR','04'})
aAdd(aCampo,{'GYD_ORGAO','05'})
aAdd(aCampo,{'GYD_DORGAO','06'})
aAdd(aCampo,{'GYD_PRODUT','07'})
aAdd(aCampo,{'GYD_DSCPRD','08'})
aAdd(aCampo,{'GYD_PRONOT','09'})
aAdd(aCampo,{'GYD_DPRDNF','10'})
aAdd(aCampo,{'GYD_LOCINI','11'})
aAdd(aCampo,{'GYD_DLOCIN','12'})
aAdd(aCampo,{'GYD_KMIDA','13'})
aAdd(aCampo,{'GYD_LOCFIM','14'})
aAdd(aCampo,{'GYD_DLOCFI','15'})
aAdd(aCampo,{'GYD_KMVOLT','16'})
aAdd(aCampo,{'GYD_TIPLIN','17'})
aAdd(aCampo,{'GYD_DTIPLI','18'})
aAdd(aCampo,{'GYD_KMGRRD','19'})
aAdd(aCampo,{'GYD_KMRDGR','20'})
aAdd(aCampo,{'GYD_SEG','21'})
aAdd(aCampo,{'GYD_TER','22'})
aAdd(aCampo,{'GYD_QUA','23'})
aAdd(aCampo,{'GYD_QUI','24'})
aAdd(aCampo,{'GYD_SEX','25'})
aAdd(aCampo,{'GYD_SAB','26'})
aAdd(aCampo,{'GYD_DOM','27'})
aAdd(aCampo,{'GYD_INIVIG','28'})
aAdd(aCampo,{'GYD_FINVIG','29'})
aAdd(aCampo,{'GYD_LOTACA','30'})
aAdd(aCampo,{'GYD_TPCARR','31'})
aAdd(aCampo,{'GYD_DESCAT','32'})
aAdd(aCampo,{'GYD_VIGCAR','33'})
aAdd(aCampo,{'GYD_ANOCAR','34'})
aAdd(aCampo,{'GYD_ATENDI','35'})
aAdd(aCampo,{'GYD_NRMOTO','36'})
aAdd(aCampo,{'GYD_CUSMOT','37'})
aAdd(aCampo,{'GYD_TPMAXC','38'})
aAdd(aCampo,{'GYD_PRECON','39'})
aAdd(aCampo,{'GYD_VLRACO','40'})
aAdd(aCampo,{'GYD_PLCONV','41'})
aAdd(aCampo,{'GYD_IDPLCO','42'})
aAdd(aCampo,{'GYD_VLRTOT','43'})
aAdd(aCampo,{'GYD_PREEXT','44'})
aAdd(aCampo,{'GYD_VLREXT','45'})
aAdd(aCampo,{'GYD_PLEXTR','46'})
aAdd(aCampo,{'GYD_IDPLEX','47'})
aAdd(aCampo,{'GYD_CLIENT','48'})
aAdd(aCampo,{'GYD_LOJACL','49'})
aAdd(aCampo,{'GYD_NOMCLI','50'})

nPosCmp := aScan( aCampo , { |x| x[1] == cCampo})

If nPosCmp == 0
	cRet:='99'
Else
	cRet:=aCampo[nPosCmp][2]
EndIf

Asize(aCampo,0)

Return cRet

/*/{Protheus.doc} g900DtFim
	( Retorna data Final do Contrato ou Orçamento )
	@type  Static Function
	@author marcelo.adente
	@since 30/01/2023
	@version 1.0
	@param cCampo, String, Campo 
	@return cRet, String, Ordem associada
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function G900DtFim(cTipV,dDtIni,nVig)
Local nX := 0
Local dDtFim
Local nDiaIni

If (!Empty(nVig) .Or. cTipV == "4") .And. !Empty(dDtIni)
	Do Case
		Case cTipV == "1"  //Dia
			dDtFim:= dDtIni + nVig
		Case cTipV == "2"  //Mes
			nDiaIni := Day(dDtIni) //Dia do início do contrato.
			dDtFim  := dDtIni
			For nX := 1 to nVig
				dDtFim += CalcAvanco(dDtFim,.F.,.F.,nDiaIni)
			Next
		Case cTipV == "3"  //Ano
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida ano bissexto                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Day(dDtIni) == 29 .And. Month(dDtIni) == 2 .And. ((Year(dDtIni)+nVig) % 4 != 0)
				dDtFim := cTod("28/02/"+str(Year(dDtIni)+nVig))
			Else
				dDtFim := cTod(str(Day(dDtIni))+"/"+str(Month(dDtIni))+"/"+str(Year(dDtIni)+nVig))
			EndIf
			//segundo a legislação de contrato o primeiro dia não conta na vigencia sendo assim o dia de inicio é o mesmo dia do fim no mes final
		Case cTipV == "4"  //Indeterminada
			dDtFim := CTOD("31/12/49")//Retorna data limite do sistema
	EndCase
EndIf

Return dDtFim

/*/{Protheus.doc} G900ValIdaVolta
(Valida se Cadastro de Orçamento do Tipo 3-Ida e Volta esta de acordo com as regras)
@type  Function
@author marcelo.adente
@since 14/02/2023
@version 1.0
@param oModelOrc, object, Modelo do Orçamento
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900ValIdaVolta(oMdlGQI)
Local nGQI 			:= 0 
Local aValid 		:= GridToArray(oMdlGQI,{"GQI_SEQ","GQI_CODDES","GQI_CODORI","GQI_SENTID"},.T.)
Local lRet 			:= .T.
Local nPosGQIa		:= 0
Local nPosGQIb		:= 0
Local nVolta 		:= 0
Local nIda			:= 0
Local aRet			:= {}
Local cMsgErro		:= ''
Local cMsgSolu		:= ''
// Verifica se existem registros sem o sentido preenchido
For nGQI := 1 To Len(aValid)
	If Empty(aValid[nGQI][4])
		lRet:= .F.
		cMsgErro:= STR0145 //'Sentido não preenchido'
		cMsgSolu:= STR0146 //'O Tipo de Sentido da Linha é Ida e Volta, preencha o sentido do trecho'
		Exit
	EndIF
Next
// Verifica se existem as mesma quantidade de trechos de ida e Volta
If lRet
	For nGQI := 1 To Len(aValid)
		If (aValid[nGQI][4]) == '1'
			nIda++
		ElseIf (aValid[nGQI][4]) == '2'
			nVolta++
		EndIF
	Next
	If nVolta <> nIda
		lRet:=.F.
		cMsgErro:= STR0147 //'A ida e a volta deve passar pelo mesmo roteiro.'
		cMsgSolu:= STR0148 // 'Utilize ida e volta em Linhas diferentes'
	EndIf
EndIf

If lRet
	For nGQI := 1 To Len(aValid)
	
		nPosGQIa := aScan( aValid , { |x| x[2] == aValid[nGQI][2] .And. x[3] == aValid[nGQI][3]})
		nPosGQIb := aScan( aValid , { |x| x[3] == aValid[nGQI][2] .And. x[2] == aValid[nGQI][3]})
		If nPosGQIa == 0 .OR. nPosGQIb == 0
			lRet:=.F.
			cMsgErro:= STR0151 //'Não existe o mesmo roteiro de trechos para ida e volta'
			cMsgSolu:= STR0152 //'Valide os Itens de Ida e Volta ou utilize linhas distintas para os roteiros'
			Exit
		EndIf
	Next
EndIf

aRet:={lRet,cMsgErro,cMsgSolu}

Return aRet
