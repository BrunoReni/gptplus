#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICOE400.CH"
#INCLUDE "AVERAGE.CH"

#define ALIAS_TEMP          1
#define ARQ_TAB             2
#define INDEX1              3
#define INDEX2              4

static _aTabsTmp  := {}
static OE400_F3 := "OE400_F3"

/*
Programa   : EICOE400
Objetivo   : Criar o cadastro de operadaor estrangeiro 
Autor      : Maurício Frison 
Data/Hora  : 29/05/2020 11:28:07 
*/ 
Function EICOE400(aCapAuto,nOpcAuto)
Local oBrowse
Local aCores 	:= {}
Local nX		:= 1
local lAtualTIN  := .F.

Private INCLUI     := .F. //Variável INCLUI utilizada no dicionário de dados da EKJ para nao permitir alteração de alguns campos  
Private lOE400Auto := ValType(aCapAuto) <> "U" .And. ValType(nOpcAuto) <> "U"

aCores :={{"EKJ_STATUS == '1' "	,"ENABLE"      ,STR0027 },;  //"Registrado"
         { "EKJ_STATUS == '2' .OR. EMPTY(EKJ_STATUS) "	,"BR_AMARELO"  ,STR0028 },; //"Pendente Registro"
         { "EKJ_STATUS == '3' "	,"BR_VERMELHO" ,STR0029 },; //"Pendente Retificação"
         { "EKJ_STATUS == '4' "	,"BR_PRETO"    ,STR0030 }}	 //"Falha de Integração"

   if  !lOE400Auto

      lAtualTIN  := avFlags("CATALOGO_PRODUTO")
      if lAtualTIN
         loadAgeEmi()
      endif

      oBrowse := FWMBrowse():New() //Instanciando a Classe
      For nX := 1 To Len( aCores )                                 //Adiciona a legenda 	    
			oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
		Next nX
      oBrowse:SetAlias("EKJ") //Informando o Alias
      oBrowse:SetMenuDef("EICOE400") //Nome do fonte do MenuDef
      oBrowse:SetDescription(STR0006)//Operador Estrangeiro
      oBrowse:Activate()

      eraseTmp()

   Else
      FWMVCRotAuto(ModelDef(), "EKJ", nOpcAuto,{{"EICOE400_EKJ",aCapAuto}})
   EndIf

Return 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Maurício Frison 
Data/Hora  : 29/05/2020 11:28:07 
*/ 
Static Function MenuDef()
Local aRotina := {}

   aAdd( aRotina, { STR0001	, "AxPesqui"			, 0, 1, 0, NIL } )	//'Pesquisar'
   aAdd( aRotina, { STR0002	, 'VIEWDEF.EICOE400'	, 0, 2, 0, NIL } )	//'Visualizar'
   aAdd( aRotina, { STR0003   , 'VIEWDEF.EICOE400'	, 0, 3, 0, NIL } )	//'Incluir'
   aAdd( aRotina, { STR0004   , 'VIEWDEF.EICOE400'	, 0, 4, 0, NIL } )	//'Alterar'
   aAdd( aRotina, { STR0005   , 'VIEWDEF.EICOE400'	, 0, 5, 0, NIL } )	//'Excluir'
   aAdd( aRotina, { STR0026   , 'OE400Integrar()'  , 0, 6, 0, NIL } )	//'Integrar'
   aAdd( aRotina, { STR0038   , 'OE400RecVers()'   , 0, 7, 0, NIL } )	//'Recuperar Versão'
   aAdd( aRotina, { STR0031   , 'COE400Legen'		, 0, 1, 0, NIL } )	//'Legenda'

Return aRotina

/*
Programa   : modelef()
Objetivo   : model da rotina de cadastro de operador estrangeiro
Retorno    : objeto model
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
Static Function ModelDef()
Local oStruEKJ       := FWFormStruct( 1, "EKJ") //Monta a estrutura da tabela EKJ
Local bPosValidacao  := {|oModel| OE400POSVL(oModel)}
Local oModel
local lAtualTIN  := avFlags("CATALOGO_PRODUTO")
local oStruEKT   := nil

   /*Criação do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
   módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
   oModel := MPFormModel():New( 'EICOE400', /*bPreValidacao*/, bPosValidacao, /*bCommit*/, /*bCancel*/ )

   //Modelo para criação da antiga Enchoice com a estrutura da tabela SJO
   oModel:AddFields( 'EICOE400_EKJ',/*nOwner*/,oStruEKJ, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

   //Adiciona a descrição do Modelo de Dados
   oModel:SetDescription(STR0006)//Operador Estrangeiro

   //Utiliza a chave primaria
   oModel:SetPrimaryKey( { "EKJ_FILIAL","EKJ_CNPJ_R", "EKJ_FORN", "EKJ_FOLOJA"} )  

   if lAtualTIN
      oStruEKT := FWFormStruct( 1, "EKT")
      oModel:AddGrid("EICOE400_EKT","EICOE400_EKJ", oStruEKT, /*bPreValidacao*/ , /*bPosValidacao*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
      oModel:SetRelation('EICOE400_EKT', {{ 'EKT_FILIAL' , 'xFilial("EKT")' },;
                                          { 'EKT_CNPJ_R' , 'EKJ_CNPJ_R'     },;
                                          { 'EKT_FORN'   , 'EKJ_FORN'       },;
                                          { 'EKT_FOLOJA' , 'EKJ_FOLOJA'     }},;
                                           EKT->(IndexKey(1)) )
      oModel:GetModel("EICOE400_EKT"):SetDescription(STR0051) // "Identificações Adicionais"
      oModel:GetModel("EICOE400_EKT"):SetOptional(.T.)
   endif

Return oModel

/*
Programa   : Viewdef()
Objetivo   : View da rotina de cadastro de operador estrangeiro
Retorno    : objeto view
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
Static Function ViewDef()
Local oModel   := FWLoadModel("EICOE400")
Local oStruEKJ := FWFormStruct(2,"EKJ")
Local oView
local lAtualTIN  := avFlags("CATALOGO_PRODUTO")
local oStruEKT   := nil

   // Cria o objeto de View
   oView := FWFormView():New()
                                                                        
   // Define qual o Modelo de dados a ser utilizado
   oView:SetModel( oModel ) 

   oStruEKJ:SetProperty('EKJ_VERSAO' , MVC_VIEW_ORDEM ,'16')
   oStruEKJ:SetProperty('EKJ_VERMAN' , MVC_VIEW_ORDEM ,'17')
   oStruEKJ:SetProperty('EKJ_DATA' , MVC_VIEW_ORDEM ,'18')
   oStruEKJ:SetProperty('EKJ_HORA' , MVC_VIEW_ORDEM ,'19')
   oStruEKJ:SetProperty('EKJ_USER' , MVC_VIEW_ORDEM ,'20')

   //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
   oView:AddField('VIEW_EKJ', oStruEKJ, 'EICOE400_EKJ')

   //Relaciona a quebra com os objetos
   if lAtualTIN
      oStruEKT := FWFormStruct(2,"EKT")
      if( oStruEKT:HasField("EKT_CNPJ_R"), oStruEKT:RemoveField("EKT_CNPJ_R"), nil )
      if( oStruEKT:HasField("EKT_FORN"), oStruEKT:RemoveField("EKT_FORN"), nil )
      if( oStruEKT:HasField("EKT_FOLOJA"), oStruEKT:RemoveField("EKT_FOLOJA"), nil )
      oView:AddGrid("VIEW_EKT",oStruEKT , "EICOE400_EKT")
      oView:CreateHorizontalBox( 'SUPERIOR' , 60 )
      oView:CreateHorizontalBox( 'INFERIOR' , 40 )
      oView:SetOwnerView( 'VIEW_EKJ' , 'SUPERIOR' )
      oView:SetOwnerView( 'VIEW_EKT' , 'INFERIOR' )
      oView:EnableTitleView("EICOE400_EKT",STR0051) // "Identificações Adicionais"
   endif

   //Habilita ButtonsBar
   oView:EnableControlBar(.T.)

Return oView 

/*
Programa   : OE400Val(cCampo)
Objetivo   : Funcao de validação dos campos
Retorno    : Lógico
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
FUNCTION OE400Val(cCampo)
Local lRet := .T.
Local oModel      := FWModelActive()
Local oModelEKJ   := oModel:GetModel("EICOE400_EKJ")

   Do Case 
      Case cCampo == "EKJ_IMPORT"
         If Empty(Posicione("SYT",1,xFilial("SYT")+oModelEKJ:GetValue("EKJ_IMPORT"),"YT_COD_IMP"))
            lRet := .F.
            easyHelp(STR0008) //Código do importador não encontrado
         ElseIf SYT->YT_IMP_CON <> "1"
            lRet := .F.
            easyHelp(STR0009) //"Código informado não é de importador"
         EndIf
      Case cCampo == "EKJ_TIN"
         If !Empty(Posicione("EKJ",2,xFilial("EKJ")+oModelEKJ:GetValue("EKJ_TIN"),"EKJ_TIN"))
            lRet := .F.
           // easyHelp(STRTRAN(STR0007,####,":"+M->EKJ_TIN)) // Campo TIN:#### já existente
           easyHelp(STR0007) // Campo TIN já existente
         EndIf
      Case (cCampo == "EKJ_FORN" .OR. cCampo == "EKJ_FOLOJA") .And. !empty(oModelEKJ:GetValue("EKJ_FORN")) .And. !empty(oModelEKJ:GetValue("EKJ_FOLOJA"))
         If empty(Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_COD"))
            lRet := .F.
            easyHelp(STR0010) //Fornecedor e Loja não encontrados
         EndIf
         If !empty(Posicione("EKJ",1,xFilial("EKJ") + oModelEKJ:GetValue("EKJ_CNPJ_R") + oModelEKJ:GetValue("EKJ_FORN") + oModelEKJ:GetValue("EKJ_FOLOJA"),"EKJ_CNPJ_R"))
            lRet := .F.
            easyHelp(STR0035) //Importador, Fornecedor e Loja já existentes
         EndIf
      Case cCampo == "EKJ_VERMAN"
         If !Empty(oModelEKJ:GetValue("EKJ_VERMAN")) .and. !Empty(oModelEKJ:GetValue("EKJ_VERSAO"))
            lRet := (oModelEKJ:GetValue("EKJ_VERMAN") == oModelEKJ:GetValue("EKJ_VERSAO")) .Or. MsgYesNo(STR0043) // Deseja substituir a versão atual pela informação digitada?
            If !lRet
               easyHelp(STR0042) // Limpe o campo para prosseguir.
            EndIf
         EndIf

   EndCase

Return lRet

/*
Programa   : OE400Gatil(cCampo)
Objetivo   : Funcao de gatilho dos campos
Retorno    : cReturn
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
FUNCTION OE400Gatil(cCampo)
Local cReturn := ''
Local oModel      := FWModelActive()
Local oModelEKJ   := oModel:GetModel("EICOE400_EKJ")
Local cTin :=''

   Do Case
      Case cCampo=="EKJ_IMPORT" 
           cReturn := Posicione("SYT",1,xFilial("SYT")+oModelEKJ:GetValue("EKJ_IMPORT"),"YT_NOME_RE")
      Case cCampo=="EKJ_CNPJ_R"
           cReturn := Posicione("SYT",1,xFilial("SYT")+oModelEKJ:GetValue("EKJ_IMPORT"),"YT_CGC")
           cReturn := Substr(cReturn,1,8)
      Case cCampo=="EKJ_NOME" 
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_NOME")
      Case (cCampo=="EKJ_TIN")
            Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_MUN")
            cTin := Posicione("EKJ",2,xFilial("EKJ") + SA2->A2_FILIAL + SA2->A2_COD + SA2->A2_LOJA,"EKJ_TIN")
            cReturn :=  if(Empty(cTin),RTRIM(SA2->A2_FILIAL) + RTRIM(SA2->A2_COD) + RTRIM(SA2->A2_LOJA),cTin) 
      Case (cCampo=="EKJ_CIDA")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_MUN")
           cReturn := SubStr(cReturn,1,35)
      Case (cCampo=="EKJ_LOGR")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_END")
      Case (cCampo=="EKJ_POSTAL")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_POSEX")
           cReturn := SubStr(cReturn,1,9)
      Case (cCampo=="EKJ_PAIS")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_PAISSUB")
           cReturn := Substr(cReturn,1,2)
      Case (cCampo=="EKJ_SUBP")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_PAISSUB")
      Case (cCampo=="EKJ_VERSAO")
           cReturn := oModelEKJ:GetValue("EKJ_VERSAO")
           If !Empty(oModelEKJ:GetValue("EKJ_VERMAN"))
               cReturn := oModelEKJ:GetValue("EKJ_VERMAN")
           EndIf
   EndCase

return cReturn

/*
Programa   : OE400POSVL
Objetivo   : Funcao de Pos Validacao
Retorno    : Logico
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
Static Function OE400POSVL(oMdl)
Local oModel      := FWModelActive()
Local oModelEKJ   := oModel:GetModel("EICOE400_EKJ")
Local lRet        := .T.
local lAtualTIN   := avFlags("CATALOGO_PRODUTO")
local oModelEKT   := nil
local nAgencia    := 0
local nTotaAgen   := 0

   //Inclusão
   If oMdl:GetOperation() == 3
      If EKJ->( dbsetorder(1),dbseek(xFilial("EKJ")+oModelEKJ:GetValue("EKJ_CNPJ_R")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA")))
         lRet := .F.
         easyHelp(STR0012) // Inclusão não permitida, chave do registro duplicada
      EndIf
   EndIf

   //Alteração
   If oMdl:GetOperation() == 4
      If oModelEKJ:getvalue("EKJ_STATUS") == "1" .and. VerifAlt(oModelEKJ, oMdl)
         oModelEKJ:setvalue("EKJ_STATUS", "3")
      EndIf
   EndIf

   if lAtualTIN .and. (oMdl:GetOperation() == 3 .or. oMdl:GetOperation() == 4)
      oModelEKT := oModel:GetModel("EICOE400_EKT")
      nTotaAgen := oModelEKT:length(.T.) 
      for nAgencia := 1 to nTotaAgen
         oModelEKT:goLine(nAgencia)
         if !oModelEKT:IsDeleted(nAgencia) .and. ( (empty(oModelEKT:getValue("EKT_AGEEMI")) .and. !empty(oModelEKT:getValue("EKT_NUMIDE"))) .or. (!empty(oModelEKT:getValue("EKT_AGEEMI")) .and. empty(oModelEKT:getValue("EKT_NUMIDE"))) )
            lRet := .F.
            EasyHelp(STR0052, STR0017, STR0053) // "Existe número de identificação do operador estrangeiro sem agência emissora informada ou agência emissora sem número de identificação." ### "Atenção" ### "Revise as informações das Identificações Adicionais antes de prosseguir."
            exit
         endif
      next
   endif

   //Exclusão
   If oMdl:GetOperation() == 5
      IF !Empty(oModelEKJ:GetValue("EKJ_DATA")) 
         lRet := .F.
         easyHelp(STR0011) // Registro com data de integração não pode ser excluído
      EndIf
   EndIf

Return lRet

/*
Programa   : VerifAlt
Objetivo   : Função para verificar se houve alteração nos campos e consequentemente alterar o status de retificação
Retorno    : Logico (.T. caso houve alteração e caso contrário, .F.)
Autor      : Nícolas Castellani Brisque
Data/Hora  : Ago/2022
Obs.       :
*/
Static Function VerifAlt(oModelEKJ, oMdl)
   Local lRet    := .F.
   Local aCampos := {"EKJ_TIN", "EKJ_NOME", "EKJ_LOGR", "EKJ_CIDA", "EKJ_SUBP", "EKJ_PAIS", "EKJ_POSTAL"}
   Local i
   local lAtualTIN   := avFlags("CATALOGO_PRODUTO")
   local oModelEKT   := nil

   Begin Sequence
      For i := 1 to Len(aCampos)
         If oModelEKJ:getvalue(aCampos[i]) != EKJ->&(aCampos[i])
            lRet := .T.
            Break
         EndIf
      Next

      if lAtualTIN
         oModelEKT := oMdl:GetModel("EICOE400_EKT")
         lRet := oModelEKT:isModified()
      endif

   End Sequence

Return lRet

/*
Programa   : OE400RecVers
Objetivo   : Função para recuperar a versão do Operador Estrangeiro diretamente do Portal Único
Parâmetros : lIntegOp - Quando .T. Indica que já integrou o operador estrangeiro, então muda alguns constroles internos
                        Quando .F. Indica que não passou pela rotina de intgrar o operador estrangeiro
Retorno    : 
Autor      : Nícolas Castellani Brisque
Data/Hora  : Ago/2022
Obs.       :
*/
Function OE400RecVers(cUrlInteg, lIntegOp) 
   Local cURLAuth
   Local cUrlGetVers
   Local oEasyJS     := nil
   Local cAuth       := "/portal/api/autenticar"
   Local cErros      := ''
   Local cRet        := ""
   Local aRet        := {.T.,.T.} //[1] erro de conexão, [2] erro da camada de negócio  
   Local aResult     := {}
   Local lRet        := .T.
   Local lIntegrou   := .T.
   Default cUrlInteg := AVgetUrl()
   Default lIntegOp := .F.

   If !AvFlags("DUIMP_12.1.2310-22.4")
      If !lIntegOp
         EasyHelp(STR0045, STR0033, STR0046) // Esta ação está indisponível para o release atual. / "A ação estará disponível a partir do release 12.1.2310. / Aviso
      EndIf
   Else
      cURLAuth    := cUrlInteg + cAuth
      cUrlGetVers := cUrlInteg + '/catp/api/ext/operador-estrangeiro?cpfCnpjRaiz=' + EKJ->EKJ_CNPJ_R + '&codigo=' + rtrim(EKJ->EKJ_TIN)

      oEasyJS := EasyJS():New()
      oEasyJS:cUrl := cUrlAuth
      oEasyJS:setTimeOut(30)

      Begin Sequence   
         lRet := oEasyJS:Activate(.T.) //Ativa a tela que solicita o certificado
         If lRet
            cRet := execEndPoint(oEasyJs, cUrlAuth, cUrlGetVers, '', 'GET', @aRet,,, .F., @cErros)
            If Empty(cRet)
               cErros := If(lIntegOp,STR0047,STR0044) //"O registro do operador estrangeiro no portal único ocorreu com sucesso, mas houve falha na recuperação da versão","Houve uma falha na recuperação da versão do operador estrangeiro do Portal Único."               
            Else
               aResult := getRetorno(cRet)
            EndIf
         EndIf
      End Sequence

      If !Empty(cErros)
            lIntegrou := .F.
            EECView(STR0039 + cErros + CRLF + STR0040, STR0033) // Ocorreu o seguinte problema: / Solução: Conferir sua conexão de internet ou verificar os parâmetros MV_EIC0073 e MV_EIC0072. / Aviso
      Else
         recLock("EKJ",.F.)
         EKJ->EKJ_VERSAO := aResult[1]
         EKJ->(msUnlock())
         If !lIntegOp
            MsgInfo(STR0041, STR0033) // "Recuperado a versão com sucesso!" / "Aviso"
         EndIf
      EndIf
   EndIf

Return lIntegrou

Static Function execEndPoint(oEasyJS, cUrlAuth, cUrlExec, cDados, cMetodo, aRet, oLogView, cAtuReg, lBody, cErros)
   Local cRet    := ''
   Local cScript := AVAuth(cUrlAuth, cUrlExec, cDados, cMetodo, lBody)
   Default lBody := .T.

   oEasyJS:runJSSync(cScript, {|x| cRet := x }, {|x| cErros := x })
   If !Empty(cErros)
      aRet[1] := .F.
      Break
   EndIf

Return cRet
/*
Função:    getRetorno
Objetivo:  tratar o json retornado pelo portal e obter o código do Operador Estrangeiro e a Versão
Retorno:   aResult contendo o código do Operador Estrangeiro na primeira posição e a versão na segunda posição
Autor:     Maurício Frison
Data:      Maio/2022
*/
Static Function getRetorno(cMsg)
   Local cRet
   Local oJson
   Local aJson   := {}
   Local aResult := {}

   If !empty(cMsg)
      cRet     := '{"items":['+cMsg+']}'
      oJson    := JsonObject():New()
      cRetJson := oJson:FromJson(cRet)
      If valtype(cRetJson) == "U" .And. valType(oJson:GetJsonObject("items")) == "A"
         aJson := oJson:GetJsonObject("items")
         If len(aJson) > 0 .And. len(aJson[1]) > 0
            cTin    := aJson[1][1]:GetJsonText("codigo")
            cVersao := aJson[1][1]:GetJsonText("versao")
            aadd(aResult,cTin)
            aadd(aResult,cVersao) 
         EndIf
      EndIf
   EndIf
   FreeObj(oJson)
Return aResult

/*/{Protheus.doc} OE400Integrar
   Função para realizar a integração do operador estrangeiro com o siscomex
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   @param aOperadores - array com o recno do operador a ser integrado, se vazio registra o posicionado no browse
   @return Nil
   /*/
Function OE400Integrar(aOperadores,lIntegAuto)
Local cURLTest    := EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br") // Teste integrador localhost:3001 - val.portalunico.siscomex.gov.br
Local cURLProd    := EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br") // Produção - portalunico.siscomex.gov.br 
Local lIntgProd   := EasyGParam("MV_EIC0074",.F.,"1") == "1"
Local cErros      := ""
Local cPathInt    := ""
Local lRet        := .T.
Local oProcess
Local cLib

Private cURLIAOE    := "/catp/api/ext/operador-estrangeiro"
Private cURLCOE     := "/catp/api/ext/operador-estrangeiro/exportar/" // + {cpfCnpjRaiz}/{exibirDesativados}
Private cURLAuth    := "/portal/api/autenticar"
Private cPathAuth   := ""
Private cPathIAOE   := ""

Default aOperadores  := {}
Default lIntegAuto   := .F.
GetRemoteType(@cLib)
If 'HTML' $ cLib 
   If ! lOE400Auto
      easyhelp(STR0036,STR0033,STR0037) //"Integração com Portal Único não disponível no smartclientHtml","AVISO","Utilizar o smartclient aplicativo"
   Endif 
ElseIf !lIntegAuto .And. EKJ->EKJ_STATUS == "1"
   easyhelp(STR0049,STR0033,STR0050) //"Integração não realizada, operador estrangeiro já estava integrado","AVISO","Posicione em um operador estrangeiro com o status diferente de integrado pra executar a integração"
Else
   begin sequence

         if ! lIntgProd 
            // se não for execauto exibe a pergunta se não segue como sim
            if ! lOE400Auto .and. ;
               ! lIntegAuto .and. ;
               ! msgnoyes( STR0013 + ENTER ; // "O sistema está configurado para integração com a Base de Testes do Portal Único."
                         + STR0014 + ENTER ; // "Qualquer integração para a Base de Testes não terá qualquer efeito legal e não deve ser utilizada em um ambiente de produção."
                         + STR0015 + ENTER ; //"Para integrar com a Base Oficial (Produção) do Portal Único, altere o parâmetro 'MV_EEC0054' para 1."
                         + STR0016 , STR0017 ) // "Deseja Prosseguir?" // "Atenção"
               break
            else
               cPathInt := cURLTest
            endif
         else
            cPathInt := cURLProd
         endif
         cPathAuth := cPathInt+cURLAuth
         cPathIAOE := cPathInt+cURLIAOE
         // Caso não receba parâmetro faz a inclusão do registro posicionado 
         if len(aOperadores) == 0
            aadd(aOperadores, EKJ->(recno()) )
         endif

      if ! lOE400Auto
         oProcess := MsNewProcess():New({|lEnd| lRet := OE400Sicomex(aOperadores,cPathAuth,cPathIAOE,oProcess,lEnd,@cErros) },;
                    STR0024 , STR0025 ,.T.) // "Integrar Operado Estrangeiro" , "Processando integração"
         oProcess:Activate()
      else
         lRet := OE400Sicomex(aOperadores,cPathAuth,cPathIAOE,oProcess,.F.,@cErros)
      endif

      if ! empty(cErros) .and. ! lRet
         EECView(cErros,STR0017) //ATENÇÃO
      Else
         lIntVrs := OE400RecVers(cPathInt, .T.) // Adquire a versão do Operador Estrangeiro após integrar e não mostra mensagem
         MsgInfo(if(lIntVrs,STR0048,STR0032),STR0033) //Registrado e versão atualizada com sucesso//"Registrado com sucesso" //"Aviso" "
      endif

   end sequence
EndIf
Return lRet

/*/{Protheus.doc} OE400Sicomex
   Função que realiza a integração com o siscomex para cada item do array aOperadores
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
Function OE400Sicomex(aOperadores,cPathAuth,cPathIAOE,oProcess,lEnd,cErros)
Local nQtdInt     := len(aOperadores)
Local cRet        := ""
Local cAux        := ""
Local cSucesso    := ""
Local cCodigo     := ""
Local ctxtJson    := ""
Local aJson       := {}
Local aJsonErros  := {}
Local lRet        := .T.
Local oEasyJS
Local oJson
Local cRetJson
Local nO
Local nj
local lAtualTIN   := avFlags("CATALOGO_PRODUTO")
local cIdenAdic   := ""
local aAreaEKT    := {}

   if lAtualTIN
      aAreaEKT := EKT->(getArea())
      EKT->(dbSetOrder(1))
   endif

   if ! lOE400Auto
      oProcess:SetRegua1(nQtdInt)
   endif
   for nO := 1 to nQtdInt
      If lEnd	//houve cancelamento do processo
         lRet := .F.
         Exit
      EndIf
      EKJ->(dbgoto(aOperadores[nO]))
      If EKJ->EKJ_STATUS <> "1" // se for diferente de registrado
         if ! lOE400Auto
            oProcess:IncRegua1( STR0023 + EKJ->EKJ_FORN + "/" + EKJ->EKJ_FOLOJA ) // "Integrando:"
            oProcess:SetRegua2(1)
         endif

         cIdenAdic := ""
         if lAtualTIN
            cIdenAdic := getIdenAdc(EKJ->(recno()))
         endif

         // Monta o texto do json para a integração
         ctxtJson := '[{' + ;
                        ' "seq": '                    + "1" + ' ,' + ;
                        ' "cpfCnpjRaiz": "'           + alltrim(EKJ->EKJ_CNPJ_R)   + '",' + ;
                        ' "codigo": "'                + alltrim(EKJ->EKJ_TIN)      + '",' + ;
                        ' "nome": "'                  + alltrim(EKJ->EKJ_NOME)     + '",' + ;
                        ' "logradouro": "'            + alltrim(EKJ->EKJ_LOGR)     + '",' + ;
                        ' "nomeCidade": "'            + alltrim(EKJ->EKJ_CIDA)     + '",' + ;
                        ' "codigoSubdivisaoPais": "'  + alltrim(EKJ->EKJ_SUBP)     + '",' + ;
                        ' "codigoPais": "'            + alltrim(EKJ->EKJ_PAIS)     + '",' + ;
                        ' "cep": "'                   + alltrim(EKJ->EKJ_POSTAL)   + '"' + ;
                        if( lAtualTIN .and. !empty(cIdenAdic), ', "identificacoesAdicionais": ' + cIdenAdic , '' ) + ;
                        '}]'

         // consome o serviço através do easyjs
         oEasyJS  := EasyJS():New()
         oEasyJS:cUrl := cPathAuth
         oEasyJS:setTimeOut(30)
         oEasyJS:Activate(.T.)
         oEasyJS:runJSSync( OE400Auth( cPathAuth , cPathIAOE , ctxtJson ) ,{|x| cRet := x } , {|x| cErros := x } )

         // Pega o retorno e converte para json para extrair as informações
         if ! empty(cRet)
            cRet     := '{"items":'+cRet+'}'
            oJson    := JsonObject():New()
            cRetJson := oJson:FromJson(cRet)
            if valtype(cRetJson) == "U" 
               if valtype(oJson:GetJsonObject("items")) == "A"
                  aJson    := oJson:GetJsonObject("items")
                  if len(aJson) > 0
                     cSucesso := aJson[1]:GetJsonText("sucesso")
                     cCodigo  := aJson[1]:GetJsonText("codigo")
                     if valtype(aJson[1]:GetJsonObject("erros")) == "A"
                        aJsonErros := aJson[1]:GetJsonObject("erros")
                        for nj := 1 to len(aJsonErros)
                           cErros += aJsonErros[nj] + ENTER
                        next
                        if empty(cErros)
                           cErros += STR0019 
                        endif
                     endif
                  endif
               else
                  cErros += STR0018 + ENTER // "Arquivo de retorno sem itens!"
               endif
               FreeObj(oJson)
            else
               cErros += STR0019 + ENTER // "Arquivo de retorno inválido!"
            endif
         elseif empty(cErros)
            cErros += STR0020 + ENTER // "Integração sem nenhum retorno!"
         endif

         // caso dê tudo certo grava as informações e finaliza o registro
         if ! empty(cRet) .and. ! empty(cSucesso) .and. upper(cSucesso) == "TRUE"
            reclock("EKJ",.F.)
               EKJ->EKJ_STATUS:= "1"
               EKJ->EKJ_TIN   := cCodigo
               EKJ->EKJ_DATA  := dDatabase
               EKJ->EKJ_HORA  := strtran(time(),":","")
               EKJ->EKJ_USER  := __cUserID
               EKJ->EKJ_LOG   := ""
            EKJ->(msunlock())
            if ! lOE400Auto
               oProcess:IncRegua2( STR0021 ) // "Integrado!"
            endif
         else // caso não grava o log, se não tiver ret tem algum erro.
            lRet := .F.
            cAux += "Fabricante: " + EKJ->EKJ_FORN + "/" + EKJ->EKJ_FOLOJA + ENTER + cErros
            reclock("EKJ",.F.)
               EKJ->EKJ_STATUS:= "4"
               EKJ->EKJ_DATA  := dDatabase
               EKJ->EKJ_HORA  := strtran(time(),":","")
               EKJ->EKJ_USER  := __cUserID
               EKJ->EKJ_LOG   := cErros
            EKJ->(msunlock())
            if ! lOE400Auto
               oProcess:IncRegua2( STR0022 ) // "Falha!"
            endif
         endif
      endif

      cErros   := ""
      cRet     := ""
      cCodigo  := ""
      cSucesso := ""
   next

   if len(aAreaEKT) > 0
      restArea(aAreaEKT)
   endif

   if ! empty(cAux)
      cErros := cAux
   endif

Return lRet

/*/{Protheus.doc} OE400Auth
   Gera o script para autenticar e consumir o serviço do portaul unico através do easyjs 
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
Static Function OE400Auth(cUrl,cURLIAOE,cOperador)
Local cVar

   begincontent var cVar
      fetch( '%Exp:cUrl%', {
         method: 'POST',
         mode: 'cors',
         headers: { 
            'Content-Type': 'application/json',
            'Role-Type': 'IMPEXP',
         },
      })
      .then( response => {
         if (!(response.ok)) {
            throw new Error( response.statusText );
         }
         var XCSRFToken = response.headers.get('X-CSRF-Token');
         var SetToken = response.headers.get('Set-Token');
         return fetch( '%Exp:cURLIAOE%', {
            method: 'POST',
            mode: 'cors',
            headers: { 
               'Content-Type': 'application/json',
               "Authorization": SetToken,
               "X-CSRF-Token":  XCSRFToken,
            },
            body: '%Exp:cOperador%'
         })
      })
      .then( (res) => res.text() )
      .then( (res) => { retAdvpl(res) } )
      .catch((e) => { retAdvplError(e) });
   endcontent

Return cVar

/*
Programa   : COE400Legen
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       :
*/
Function COE400Legen()
Local aCores := {}

   aCores := { {"ENABLE"       ,STR0027   },;   //"Registrado"
               {"BR_AMARELO"   ,STR0028   },;   //"Pendente Registro"
               {"BR_VERMELHO"  ,STR0029	},;   //"Pendente de Retificação
               {"BR_PRETO"     ,STR0030   }}    //"Falha de Integração"

   BrwLegenda(STR0006,STR0031,aCores)

Return .T.

/*
Programa   : COE400AgEm
Objetivo   : Utilizado na consulta padrão da Agencia Emissora do número da identificação (EKT_AGEEMI)
             https://service.unece.org/trade/untdid/d20b/tred/tred3055.htm
Retorno    : .T.
Autor      : Bruno Kubagawa
Data/Hora  : 20/03/2023
Obs.       :
*/
function COE400AgEm()
   local lRet       := .F.
   local cAliasTmp  := OE400_F3
   local aBckRot    := {}
   local aBckCampo  := {}
   local cAliasSel  := alias()
   local oDlgAgen   := nil
   local oBrAgen    := nil
   local aStruct    := {}
   local nCpo       := 0
   local aColumns   := {}
   local nOpc       := 0
 
   aBckRot := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
   aRotina := {}
   aBckCampo := if( isMemVar( "aCampos" ), aClone( aCampos ), {})
   aCampos := {}

   aStruct := (cAliasTmp)->(dbStruct())
   for nCpo := 1 To Len(aStruct)
      if !(aStruct[nCpo][1] $ "RECNO||SEQUENCIA")
         aAdd(aColumns,FWBrwColumn():New())
         aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nCpo][1]+"}") )
         if aStruct[nCpo][1] == "CODIGO"
            aColumns[Len(aColumns)]:SetTitle( STR0055 ) // "Código"
         elseif aStruct[nCpo][1] == "DESCRICAO"
            aColumns[Len(aColumns)]:SetTitle( STR0056 ) // "Descrição"
         endif
         aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
         aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
         aColumns[Len(aColumns)]:SetPicture( "" )
      endif	
   next nCpo 

   oDlgAgen := FWDialogModal():New()
   oDlgAgen:setEscClose(.F.)
   oDlgAgen:setTitle( OemTOAnsi( STR0054 )) // "Agências Emissoras" 
   oDlgAgen:setSize(250, 340)
   oDlgAgen:enableFormBar(.F.)
   oDlgAgen:createDialog()

   oBrAgen := FWMBrowse():New()
   oBrAgen:SetOwner( oDlgAgen:getPanelMain() )
   oBrAgen:SetAlias( cAliasTmp )
   oBrAgen:AddButton( OemTOAnsi(STR0057) , { || nOpc := 1 , oDlgAgen:DeActivate() },, 2 ) // "Confirmar"
   oBrAgen:AddButton( OemTOAnsi(STR0058)  , { || oDlgAgen:DeActivate() },, 2 ) // "Cancelar"
   oBrAgen:SetColumns( aColumns )
   oBrAgen:SetMenuDef("")
   oBrAgen:SetTemporary(.T.)
   oBrAgen:DisableDetails()
   oBrAgen:DisableFilter()
   oBrAgen:DisableConfig()
   oBrAgen:DisableReport()
   oBrAgen:SetDoubleClick({ || nOpc := 1 , oDlgAgen:DeActivate() })
   oBrAgen:Activate()

   oDlgAgen:Activate()

   if nOpc == 1 .and. (cAliasTmp)->(!eof()) .and. (cAliasTmp)->(!bof())
      lRet := .T.
   endif

   fwFreeObj(oDlgAgen)

   if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)
   if( len(aBckCampo) > 0, aCampos := aClone(aBckCampo), nil)
   if(!empty(cAliasSel),dbSelectArea(cAliasSel),nil)

return lRet

/*
Função     : COE400RAgEm
Objetivo   : Função de retorno
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
function COE400RAgEm()
   local cAgencia   := ""
   local cAliasTmp  := OE400_F3

   if (cAliasTmp)->(!eof())
      cAgencia := (cAliasTmp)->CODIGO
   endif

return cAgencia

/*
Função     : loadAgeEmi
Objetivo   : Função para carregar as agencias identificadoras na tabela temporaria
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function loadAgeEmi()
   local cAliasTmp  := ""
   local aListAgenc := {}
   local nAgencia   := 0
   local nTam       := 0

   cAliasTmp := OE400_F3
   clearTmp(cAliasTmp)

   nTam := len((cAliasTmp)->SEQUENCIA)
   aListAgenc := getAgeEmis()
   for nAgencia := 1 to len( aListAgenc )
      reclock(cAliasTmp, .T.)
      (cAliasTmp)->SEQUENCIA := strZero( nAgencia, nTam)
      (cAliasTmp)->CODIGO := aListAgenc[nAgencia][1]
      (cAliasTmp)->DESCRICAO := aListAgenc[nAgencia][2]
      (cAliasTmp)->(msUnLock())
   next nAgencia

return

/*
Função     : createTmp
Objetivo   : Função para criação do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function createTmp()
   local aBckCampo  := if( isMemVar( "aCampos" ), aClone( aCampos ), {})
   local cAliasTmp  := ""
   local aSemSX3    := {}
   local cArqTab    := ""
   local cIndExt    := ""
   local cIndex1    := ""
   local cIndex2    := ""

   // ---- Criação da tabela temporaria para a consulta padrão das agencias emissoras da identificação
   cAliasTmp := OE400_F3
   if Select(cAliasTmp) == 0
 
      aCampos := {}
      aSemSX3 := {}
      aAdd(aSemSX3, {"SEQUENCIA" , "C" , 003 , 0 })
      aAdd(aSemSX3, {"CODIGO"    , "C" , 003 , 0 })
      aAdd(aSemSX3, {"DESCRICAO" , "C" , 150 , 0 })
      aAdd(aSemSX3, {"RECNO"     , "N" , 010 , 0 })
  
      cArqTab := e_criatrab(, aSemSX3, cAliasTmp )

      cIndExt := TEOrdBagExt()
      E_IndRegua( cAliasTmp , cArqTab+cIndExt, "SEQUENCIA")

      cIndex1 := e_create()
      E_IndRegua( cAliasTmp , cIndex1+cIndExt, "CODIGO")

      SET INDEX TO (cArqTab+cIndExt),(cIndex1+cIndExt)

      aAdd( _aTabsTmp, {cAliasTmp, cArqTab, cIndex1, cIndex2 })

   endif
   // ------------------------------------------------------------------------

   if( len(aBckCampo) > 0, aCampos := aClone(aBckCampo), nil)

return

/*
Função     : eraseTmp
Objetivo   : Função para exclusão do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function eraseTmp()
   local nTab       := 0
   local cAliasTmp  := ""
   local cTabArq    := ""
   local cIndex1    := ""
   local cIndex2    := ""

   for nTab := 1 to len(_aTabsTmp)
      cAliasTmp := _aTabsTmp[nTab][ALIAS_TEMP]
      cTabArq := _aTabsTmp[nTab][ARQ_TAB]
      cIndex1 := if(empty(_aTabsTmp[nTab][INDEX1]),nil,_aTabsTmp[nTab][INDEX1])
      cIndex2 := if(empty(_aTabsTmp[nTab][INDEX2]),nil,_aTabsTmp[nTab][INDEX2])
      if select(cAliasTmp) > 0
         (cAliasTmp)->(E_EraseArq(cTabArq,cIndex1,cIndex2))
      endif
   next

   aSize(_aTabsTmp, 0)
   _aTabsTmp := {}

return

/*
Função     : clearTmp
Objetivo   : Função limpeza do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function clearTmp(cAliasTmp)
   default cAliasTmp := ""

   if( !empty(cAliasTmp), if( select(cAliasTmp)  > 0, AvZap(cAliasTmp), createTmp()), nil)

return

/*
Função     : getAgeEmis
Objetivo   : Função retorna as agencias emissoras de identificação
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function getAgeEmis()
   local aAgencias := {}

   aAdd( aAgencias , { "1"   , "CCC (Customs Co-operation Council)" } )
   aAdd( aAgencias , { "2"   , "CEC (Commission of the European Communities)" } )
   aAdd( aAgencias , { "3"   , "IATA (International Air Transport Association)" } )
   aAdd( aAgencias , { "4"   , "ICC (International Chamber of Commerce)" } )
   aAdd( aAgencias , { "5"   , "ISO (International Organization for Standardization)" } )
   aAdd( aAgencias , { "6"   , "UN/ECE (United Nations - Economic Commission for Europe)" } )
   aAdd( aAgencias , { "7"   , "CEFIC (Conseil Europeen des Federations de l'Industrie Chimique)" } )
   aAdd( aAgencias , { "8"   , "EDIFICE" } )
   aAdd( aAgencias , { "9"   , "GS1" } )
   aAdd( aAgencias , { "10"  , "ODETTE" } )
   aAdd( aAgencias , { "11"  , "Lloyd's register of shipping" } )
   aAdd( aAgencias , { "12"  , "UIC (International union of railways)" } )
   aAdd( aAgencias , { "13"  , "ICAO (International Civil Aviation Organization)" } )
   aAdd( aAgencias , { "14"  , "ICS (International Chamber of Shipping)" } )
   aAdd( aAgencias , { "15"  , "RINET (Reinsurance and Insurance Network)" } )
   aAdd( aAgencias , { "16"  , "US, D&B (Dun & Bradstreet Corporation)" } )
   aAdd( aAgencias , { "17"  , "S.W.I.F.T." } )
   aAdd( aAgencias , { "18"  , "Conventions on SAD and transit (EC and EFTA)" } )
   aAdd( aAgencias , { "19"  , "FRRC (Federal Reserve Routing Code)" } )
   aAdd( aAgencias , { "20"  , "BIC (Bureau International des Containeurs)" } )
   aAdd( aAgencias , { "21"  , "Assigned by transport company" } )
   aAdd( aAgencias , { "22"  , "US, ISA (Information Systems Agreement)" } )
   aAdd( aAgencias , { "23"  , "FR, EDITRANSPORT" } )
   aAdd( aAgencias , { "24"  , "AU, ROA (Railways of Australia)" } )
   aAdd( aAgencias , { "25"  , "EDITEX (Europe)" } )
   aAdd( aAgencias , { "26"  , "NL, Foundation Uniform Transport Code" } )
   aAdd( aAgencias , { "27"  , "US, FDA (Food and Drug Administration)" } )
   aAdd( aAgencias , { "28"  , "EDITEUR (European book sector electronic data interchange group)" } )
   aAdd( aAgencias , { "29"  , "GB, FLEETNET" } )
   aAdd( aAgencias , { "30"  , "GB, ABTA (Association of British Travel Agencies)" } )
   aAdd( aAgencias , { "31"  , "FI, Finish State Railway" } )
   aAdd( aAgencias , { "32"  , "PL, Polish State Railway" } )
   aAdd( aAgencias , { "33"  , "BG, Bulgaria State Railway" } )
   aAdd( aAgencias , { "34"  , "RO, Rumanian State Railway" } )
   aAdd( aAgencias , { "35"  , "CZ, Tchechian State Railway" } )
   aAdd( aAgencias , { "36"  , "HU, Hungarian State Railway" } )
   aAdd( aAgencias , { "37"  , "GB, British Railways" } )
   aAdd( aAgencias , { "38"  , "ES, Spanish National Railway" } )
   aAdd( aAgencias , { "39"  , "SE, Swedish State Railway" } )
   aAdd( aAgencias , { "40"  , "NO, Norwegian State Railway" } )
   aAdd( aAgencias , { "41"  , "DE, German Railway" } )
   aAdd( aAgencias , { "42"  , "AT, Austrian Federal Railways" } )
   aAdd( aAgencias , { "43"  , "LU, Luxembourg National Railway Company" } )
   aAdd( aAgencias , { "44"  , "IT, Italian State Railways" } )
   aAdd( aAgencias , { "45"  , "NL, Netherlands Railways" } )
   aAdd( aAgencias , { "46"  , "CH, Swiss Federal Railways" } )
   aAdd( aAgencias , { "47"  , "DK, Danish State Railways" } )
   aAdd( aAgencias , { "48"  , "FR, French National Railway Company" } )
   aAdd( aAgencias , { "49"  , "BE, Belgian National Railway Company" } )
   aAdd( aAgencias , { "50"  , "PT, Portuguese Railways" } )
   aAdd( aAgencias , { "51"  , "SK, Slovakian State Railways" } )
   aAdd( aAgencias , { "52"  , "IE, Irish Transport Company" } )
   aAdd( aAgencias , { "53"  , "FIATA (International Federation of Freight Forwarders Associations)" } )
   aAdd( aAgencias , { "54"  , "IMO (International Maritime Organisation)" } )
   aAdd( aAgencias , { "55"  , "US, DOT (United States Department of Transportation)" } )
   aAdd( aAgencias , { "56"  , "TW, Trade-van" } )
   aAdd( aAgencias , { "57"  , "TW, Chinese Taipei Customs" } )
   aAdd( aAgencias , { "58"  , "EUROFER" } )
   aAdd( aAgencias , { "59"  , "DE, EDIBAU" } )
   aAdd( aAgencias , { "60"  , "Assigned by national trade agency" } )
   aAdd( aAgencias , { "61"  , "Association Europeenne des Constructeurs de Materiel Aerospatial (AECMA)" } )
   aAdd( aAgencias , { "62"  , "US, DIstilled Spirits Council of the United States (DISCUS)" } )
   aAdd( aAgencias , { "63"  , "North Atlantic Treaty Organization (NATO)" } )
   aAdd( aAgencias , { "64"  , "FR, CLEEP" } )
   aAdd( aAgencias , { "65"  , "GS1 France" } )
   aAdd( aAgencias , { "66"  , "MY, Malaysian Customs and Excise" } )
   aAdd( aAgencias , { "67"  , "MY, Malaysia Central Bank" } )
   aAdd( aAgencias , { "68"  , "GS1 Italy" } )
   aAdd( aAgencias , { "69"  , "US, National Alcohol Beverage Control Association (NABCA)" } )
   aAdd( aAgencias , { "70"  , "MY, Dagang.Net" } )
   aAdd( aAgencias , { "71"  , "US, FCC (Federal Communications Commission)" } )
   aAdd( aAgencias , { "72"  , "US, MARAD (Maritime Administration)" } )
   aAdd( aAgencias , { "73"  , "US, DSAA (Defense Security Assistance Agency)" } )
   aAdd( aAgencias , { "74"  , "US, NRC (Nuclear Regulatory Commission)" } )
   aAdd( aAgencias , { "75"  , "US, ODTC (Office of Defense Trade Controls)" } )
   aAdd( aAgencias , { "76"  , "US, ATF (Bureau of Alcohol, Tobacco and Firearms)" } )
   aAdd( aAgencias , { "77"  , "US, BXA (Bureau of Export Administration)" } )
   aAdd( aAgencias , { "78"  , "US, FWS (Fish and Wildlife Service)" } )
   aAdd( aAgencias , { "79"  , "US, OFAC (Office of Foreign Assets Control)" } )
   aAdd( aAgencias , { "80"  , "BRMA/RAA - LIMNET - RINET Joint Venture" } )
   aAdd( aAgencias , { "81"  , "RU, (SFT) Society for Financial Telecommunications" } )
   aAdd( aAgencias , { "82"  , "NO, Enhetsregisteret ved Bronnoysundregisterne" } )
   aAdd( aAgencias , { "83"  , "US, National Retail Federation" } )
   aAdd( aAgencias , { "84"  , "DE, BRD (Gesetzgeber der Bundesrepublik Deutschland)" } )
   aAdd( aAgencias , { "85"  , "North America, Telecommunications Industry Forum" } )
   aAdd( aAgencias , { "86"  , "Assigned by party originating the message" } )
   aAdd( aAgencias , { "87"  , "Assigned by carrier" } )
   aAdd( aAgencias , { "88"  , "Assigned by owner of operation" } )
   aAdd( aAgencias , { "89"  , "Assigned by distributor" } )
   aAdd( aAgencias , { "90"  , "Assigned by manufacturer" } )
   aAdd( aAgencias , { "91"  , "Assigned by seller or seller's agent" } )
   aAdd( aAgencias , { "92"  , "Assigned by buyer or buyer's agent" } )
   aAdd( aAgencias , { "93"  , "AT, Austrian Customs" } )
   aAdd( aAgencias , { "94"  , "AT, Austrian PTT" } )
   aAdd( aAgencias , { "95"  , "AU, Australian Customs Service" } )
   aAdd( aAgencias , { "96"  , "CA, Revenue Canada, Customs and Excise" } )
   aAdd( aAgencias , { "97"  , "CH, Administration federale des contributions" } )
   aAdd( aAgencias , { "98"  , "CH, Direction generale des douanes" } )
   aAdd( aAgencias , { "99"  , "CH, Division des importations et exportations, OFAEE" } )
   aAdd( aAgencias , { "100" , "CH, Entreprise des PTT" } )
   aAdd( aAgencias , { "101" , "CH, Carbura" } )
   aAdd( aAgencias , { "102" , "CH, Centrale suisse pour l'importation du charbon" } )
   aAdd( aAgencias , { "103" , "CH, Office fiduciaire des importateurs de denrees alimentaires" } )
   aAdd( aAgencias , { "104" , "CH, Association suisse code des articles" } )
   aAdd( aAgencias , { "105" , "DK, Ministry of taxation, Central Customs and Tax Administration" } )
   aAdd( aAgencias , { "106" , "FR, Direction generale des douanes et droits indirects" } )
   aAdd( aAgencias , { "107" , "FR, INSEE" } )
   aAdd( aAgencias , { "108" , "FR, Banque de France" } )
   aAdd( aAgencias , { "109" , "GB, H.M. Customs & Excise" } )
   aAdd( aAgencias , { "110" , "IE, Revenue Commissioners, Customs AEP project" } )
   aAdd( aAgencias , { "111" , "US, U.S. Customs Service" } )
   aAdd( aAgencias , { "112" , "US, U.S. Census Bureau" } )
   aAdd( aAgencias , { "113" , "GS1 US" } )
   aAdd( aAgencias , { "114" , "US, ABA (American Bankers Association)" } )
   aAdd( aAgencias , { "116" , "US, ANSI ASC X12" } )
   aAdd( aAgencias , { "117" , "AT, Geldausgabeautomaten-Service Gesellschaft m.b.H." } )
   aAdd( aAgencias , { "118" , "SE, Svenska Bankfoereningen" } )
   aAdd( aAgencias , { "119" , "IT, Associazione Bancaria Italiana" } )
   aAdd( aAgencias , { "120" , "IT, Socieata' Interbancaria per l'Automazione" } )
   aAdd( aAgencias , { "121" , "CH, Telekurs AG" } )
   aAdd( aAgencias , { "122" , "CH, Swiss Securities Clearing Corporation" } )
   aAdd( aAgencias , { "123" , "NO, Norwegian Interbank Research Organization" } )
   aAdd( aAgencias , { "124" , "NO, Norwegian Bankers' Association" } )
   aAdd( aAgencias , { "125" , "FI, The Finnish Bankers' Association" } )
   aAdd( aAgencias , { "126" , "US, NCCMA (Account Analysis Codes)" } )
   aAdd( aAgencias , { "127" , "DE, ARE (AbRechnungs Einheit)" } )
   aAdd( aAgencias , { "128" , "BE, Belgian Bankers' Association" } )
   aAdd( aAgencias , { "129" , "BE, Belgian Ministry of Finance" } )
   aAdd( aAgencias , { "130" , "DK, Danish Bankers Association" } )
   aAdd( aAgencias , { "131" , "DE, German Bankers Association" } )
   aAdd( aAgencias , { "132" , "GB, BACS Limited" } )
   aAdd( aAgencias , { "133" , "GB, Association for Payment Clearing Services" } )
   aAdd( aAgencias , { "134" , "GB, APACS (Association of payment clearing services)" } )
   aAdd( aAgencias , { "135" , "GB, The Clearing House" } )
   aAdd( aAgencias , { "136" , "GS1 UK" } )
   aAdd( aAgencias , { "137" , "AT, Verband oesterreichischer Banken und Bankiers" } )
   aAdd( aAgencias , { "138" , "FR, CFONB (Comite francais d'organ. et de normalisation bancaires)" } )
   aAdd( aAgencias , { "139" , "Universal Postal Union (UPU)" } )
   aAdd( aAgencias , { "140" , "CEC (Commission of the European Communities), DG/XXI-01" } )
   aAdd( aAgencias , { "141" , "CEC (Commission of the European Communities), DG/XXI-B-1" } )
   aAdd( aAgencias , { "142" , "CEC (Commission of the European Communities), DG/XXXIV" } )
   aAdd( aAgencias , { "143" , "NZ, New Zealand Customs" } )
   aAdd( aAgencias , { "144" , "NL, Netherlands Customs" } )
   aAdd( aAgencias , { "145" , "SE, Swedish Customs" } )
   aAdd( aAgencias , { "146" , "DE, German Customs" } )
   aAdd( aAgencias , { "147" , "BE, Belgian Customs" } )
   aAdd( aAgencias , { "148" , "ES, Spanish Customs" } )
   aAdd( aAgencias , { "149" , "IL, Israel Customs" } )
   aAdd( aAgencias , { "150" , "HK, Hong Kong Customs" } )
   aAdd( aAgencias , { "151" , "JP, Japan Customs" } )
   aAdd( aAgencias , { "152" , "SA, Saudi Arabia Customs" } )
   aAdd( aAgencias , { "153" , "IT, Italian Customs" } )
   aAdd( aAgencias , { "154" , "GR, Greek Customs" } )
   aAdd( aAgencias , { "155" , "PT, Portuguese Customs" } )
   aAdd( aAgencias , { "156" , "LU, Luxembourg Customs" } )
   aAdd( aAgencias , { "157" , "NO, Norwegian Customs" } )
   aAdd( aAgencias , { "158" , "FI, Finnish Customs" } )
   aAdd( aAgencias , { "159" , "IS, Iceland Customs" } )
   aAdd( aAgencias , { "160" , "LI, Liechtenstein authority" } )
   aAdd( aAgencias , { "161" , "UNCTAD (United Nations - Conference on Trade And Development)" } )
   aAdd( aAgencias , { "162" , "CEC (Commission of the European Communities), DG/XIII-D-5" } )
   aAdd( aAgencias , { "163" , "US, FMC (Federal Maritime Commission)" } )
   aAdd( aAgencias , { "164" , "US, DEA (Drug Enforcement Agency)" } )
   aAdd( aAgencias , { "165" , "US, DCI (Distribution Codes, INC.)" } )
   aAdd( aAgencias , { "166" , "US, National Motor Freight Classification Association" } )
   aAdd( aAgencias , { "167" , "US, AIAG (Automotive Industry Action Group)" } )
   aAdd( aAgencias , { "168" , "US, FIPS (Federal Information Publishing Standard)" } )
   aAdd( aAgencias , { "169" , "CA, SCC (Standards Council of Canada)" } )
   aAdd( aAgencias , { "170" , "CA, CPA (Canadian Payment Association)" } )
   aAdd( aAgencias , { "171" , "NL, Interpay Girale Services" } )
   aAdd( aAgencias , { "172" , "NL, Interpay Debit Card Services" } )
   aAdd( aAgencias , { "173" , "NO, NORPRO" } )
   aAdd( aAgencias , { "174" , "DE, DIN (Deutsches Institut fuer Normung)" } )
   aAdd( aAgencias , { "175" , "FCI (Factors Chain International)" } )
   aAdd( aAgencias , { "176" , "BR, Banco Central do Brazil" } )
   aAdd( aAgencias , { "177" , "AU, LIFA (Life Insurance Federation of Australia)" } )
   aAdd( aAgencias , { "178" , "AU, SAA (Standards Association of Australia)" } )
   aAdd( aAgencias , { "179" , "US, Air transport association of America" } )
   aAdd( aAgencias , { "180" , "DE, BIA (Berufsgenossenschaftliches Institut fuer Arbeitssicherheit)" } )
   aAdd( aAgencias , { "181" , "Edibuild" } )
   aAdd( aAgencias , { "182" , "US, Standard Carrier Alpha Code (Motor)" } )
   aAdd( aAgencias , { "183" , "US, American Petroleum Institute" } )
   aAdd( aAgencias , { "184" , "AU, ACOS (Australian Chamber of Shipping)" } )
   aAdd( aAgencias , { "185" , "DE, BDI (Bundesverband der Deutschen Industrie e.V.)" } )
   aAdd( aAgencias , { "186" , "US, GSA (General Services Administration)" } )
   aAdd( aAgencias , { "187" , "US, DLMSO (Defense Logistics Management Standards Office)" } )
   aAdd( aAgencias , { "188" , "US, NIST (National Institute of Standards and Technology)" } )
   aAdd( aAgencias , { "189" , "US, DoD (Department of Defense)" } )
   aAdd( aAgencias , { "190" , "US, VA (Department of Veterans Affairs)" } )
   aAdd( aAgencias , { "191" , "IAPSO (United Nations Inter-Agency Procurement Services Office)" } )
   aAdd( aAgencias , { "192" , "Shipper's association" } )
   aAdd( aAgencias , { "193" , "EU, European Telecommunications Informatics Services (ETIS)" } )
   aAdd( aAgencias , { "194" , "AU, AQIS (Australian Quarantine and Inspection Service)" } )
   aAdd( aAgencias , { "195" , "CO, DIAN (Direccion de Impuestos y Aduanas Nacionales)" } )
   aAdd( aAgencias , { "196" , "US, COPAS (Council of Petroleum Accounting Society)" } )
   aAdd( aAgencias , { "197" , "US, DISA (Data Interchange Standards Association)" } )
   aAdd( aAgencias , { "198" , "CO, Superintendencia Bancaria De Colombia" } )
   aAdd( aAgencias , { "199" , "FR, Direction de la Comptabilite Publique" } )
   aAdd( aAgencias , { "200" , "GS1 Netherlands" } )
   aAdd( aAgencias , { "201" , "US, WSSA(Wine and Spirits Shippers Association)" } )
   aAdd( aAgencias , { "202" , "PT, Banco de Portugal" } )
   aAdd( aAgencias , { "203" , "FR, GALIA (Groupement pour l'Amelioration des Liaisons dans l'Industrie Automobile)" } )
   aAdd( aAgencias , { "204" , "DE, VDA (Verband der Automobilindustrie E.V.)" } )
   aAdd( aAgencias , { "205" , "IT, ODETTE Italy" } )
   aAdd( aAgencias , { "206" , "NL, ODETTE Netherlands" } )
   aAdd( aAgencias , { "207" , "ES, ODETTE Spain" } )
   aAdd( aAgencias , { "208" , "SE, ODETTE Sweden" } )
   aAdd( aAgencias , { "209" , "GB, ODETTE United Kingdom" } )
   aAdd( aAgencias , { "210" , "EU, EDI for financial, informational, cost, accounting, auditing and social areas (EDIFICAS) - Europe" } )
   aAdd( aAgencias , { "211" , "FR, EDI for financial, informational, cost, accounting, auditing and social areas (EDIFICAS) - France" } )
   aAdd( aAgencias , { "212" , "DE, Deutsch Telekom AG" } )
   aAdd( aAgencias , { "213" , "JP, NACCS Center (Nippon Automated Cargo Clearance System Operations Organization)" } )
   aAdd( aAgencias , { "214" , "US, AISI (American Iron and Steel Institute)" } )
   aAdd( aAgencias , { "215" , "AU, APCA (Australian Payments Clearing Association)" } )
   aAdd( aAgencias , { "216" , "US, Department of Labor" } )
   aAdd( aAgencias , { "217" , "US, N.A.I.C. (National Association of Insurance Commissioners)" } )
   aAdd( aAgencias , { "218" , "GB, The Association of British Insurers" } )
   aAdd( aAgencias , { "219" , "FR, d'ArvA" } )
   aAdd( aAgencias , { "220" , "FI, Finnish tax board" } )
   aAdd( aAgencias , { "221" , "FR, CNAMTS (Caisse Nationale de l'Assurance Maladie des Travailleurs Salaries)" } )
   aAdd( aAgencias , { "222" , "DK, Danish National Board of Health" } )
   aAdd( aAgencias , { "223" , "DK, Danish Ministry of Home Affairs" } )
   aAdd( aAgencias , { "224" , "US, Aluminum Association" } )
   aAdd( aAgencias , { "225" , "US, CIDX (Chemical Industry Data Exchange)" } )
   aAdd( aAgencias , { "226" , "US, Carbide Manufacturers" } )
   aAdd( aAgencias , { "227" , "US, NWDA (National Wholesale Druggist Association)" } )
   aAdd( aAgencias , { "228" , "US, EIA (Electronic Industry Association)" } )
   aAdd( aAgencias , { "229" , "US, American Paper Institute" } )
   aAdd( aAgencias , { "230" , "US, VICS (Voluntary Inter-Industry Commerce Standards)" } )
   aAdd( aAgencias , { "231" , "Copper and Brass Fabricators Council" } )
   aAdd( aAgencias , { "232" , "GB, Inland Revenue" } )
   aAdd( aAgencias , { "233" , "US, OMB (Office of Management and Budget)" } )
   aAdd( aAgencias , { "234" , "DE, Siemens AG" } )
   aAdd( aAgencias , { "235" , "AU, Tradegate (Electronic Commerce Australia)" } )
   aAdd( aAgencias , { "236" , "US, United States Postal Service (USPS)" } )
   aAdd( aAgencias , { "237" , "US, United States health industry" } )
   aAdd( aAgencias , { "238" , "US, TDCC (Transportation Data Coordinating Committee)" } )
   aAdd( aAgencias , { "239" , "US, HL7 (Health Level 7)" } )
   aAdd( aAgencias , { "240" , "US, CHIPS (Clearing House Interbank Payment Systems)" } )
   aAdd( aAgencias , { "241" , "PT, SIBS (Sociedade Interbancaria de Servicos)" } )
   aAdd( aAgencias , { "244" , "US, Department of Health and Human Services" } )
   aAdd( aAgencias , { "245" , "GS1 Denmark" } )
   aAdd( aAgencias , { "246" , "GS1 Germany" } )
   aAdd( aAgencias , { "247" , "US, HBICC (Health Industry Business Communication Council)" } )
   aAdd( aAgencias , { "248" , "US, ASTM (American Society of Testing and Materials)" } )
   aAdd( aAgencias , { "249" , "IP (Institute of Petroleum)" } )
   aAdd( aAgencias , { "250" , "US, UOP (Universal Oil Products)" } )
   aAdd( aAgencias , { "251" , "AU, HIC (Health Insurance Commission)" } )
   aAdd( aAgencias , { "252" , "AU, AIHW (Australian Institute of Health and Welfare)" } )
   aAdd( aAgencias , { "253" , "AU, NCCH (National Centre for Classification in Health)" } )
   aAdd( aAgencias , { "254" , "AU, DOH (Australian Department of Health)" } )
   aAdd( aAgencias , { "255" , "AU, ADA (Australian Dental Association)" } )
   aAdd( aAgencias , { "256" , "US, AAR (Association of American Railroads)" } )
   aAdd( aAgencias , { "257" , "ECCMA (Electronic Commerce Code Management Association)" } )
   aAdd( aAgencias , { "258" , "JP, Japanese Ministry of Transport" } )
   aAdd( aAgencias , { "259" , "JP, Japanese Maritime Safety Agency" } )
   aAdd( aAgencias , { "260" , "ebIX (European forum for energy Business Information eXchange)" } )
   aAdd( aAgencias , { "261" , "EEG7, European Expert Group 7 (Insurance)" } )
   aAdd( aAgencias , { "262" , "DE, GDV (Gesamtverband der Deutschen Versicherungswirtschaft e.V.)" } )
   aAdd( aAgencias , { "263" , "CA, CSIO (Centre for Study of Insurance Operations)" } )
   aAdd( aAgencias , { "264" , "FR, AGF (Assurances Generales de France)" } )
   aAdd( aAgencias , { "265" , "SE, Central bank" } )
   aAdd( aAgencias , { "266" , "US, DoA (Department of Agriculture)" } )
   aAdd( aAgencias , { "267" , "RU, Central Bank of Russia" } )
   aAdd( aAgencias , { "268" , "FR, DGI (Direction Generale des Impots)" } )
   aAdd( aAgencias , { "269" , "GRE (Reference Group of Experts)" } )
   aAdd( aAgencias , { "270" , "Concord EDI group" } )
   aAdd( aAgencias , { "271" , "InterContainer InterFrigo" } )
   aAdd( aAgencias , { "272" , "Joint Automotive Industry agency" } )
   aAdd( aAgencias , { "273" , "CH, SCC (Swiss Chambers of Commerce)" } )
   aAdd( aAgencias , { "274" , "ITIGG (International Transport Implementation Guidelines Group)" } )
   aAdd( aAgencias , { "275" , "ES, Banco de Espana" } )
   aAdd( aAgencias , { "276" , "Assigned by Port Community" } )
   aAdd( aAgencias , { "277" , "BIGNet (Business Information Group Network)" } )
   aAdd( aAgencias , { "278" , "Eurogate" } )
   aAdd( aAgencias , { "279" , "NL, Graydon" } )
   aAdd( aAgencias , { "280" , "FR, Euler" } )
   aAdd( aAgencias , { "281" , "GS1 Belgium and Luxembourg" } )
   aAdd( aAgencias , { "282" , "DE, Creditreform International e.V." } )
   aAdd( aAgencias , { "283" , "DE, Hermes Kreditversicherungs AG" } )
   aAdd( aAgencias , { "284" , "TW, Taiwanese Bankers' Association" } )
   aAdd( aAgencias , { "285" , "ES, Asociacion Espanola de Banca" } )
   aAdd( aAgencias , { "286" , "SE, TCO (Tjanstemannes Central Organisation)" } )
   aAdd( aAgencias , { "287" , "DE, FORTRAS (Forschungs- und Entwicklungsgesellschaft fur Transportwesen GMBH)" } )
   aAdd( aAgencias , { "288" , "OSJD (Organizacija Sotrudnichestva Zeleznih Dorog)" } )
   aAdd( aAgencias , { "289" , "JP.JIPDEC" } )
   aAdd( aAgencias , { "290" , "JP, JAMA" } )
   aAdd( aAgencias , { "291" , "JP, JAPIA" } )
   aAdd( aAgencias , { "292" , "FI, TIEKE The Information Technology Development Centre of Finland" } )
   aAdd( aAgencias , { "293" , "DE, BDEW (Bundesverband der Energie- und Wasserwirtschaft e.V.)" } )
   aAdd( aAgencias , { "294" , "GS1 Austria" } )
   aAdd( aAgencias , { "295" , "AU, Australian Therapeutic Goods Administration" } )
   aAdd( aAgencias , { "296" , "ITU (International Telecommunication Union)" } )
   aAdd( aAgencias , { "297" , "IT, Ufficio IVA" } )
   aAdd( aAgencias , { "298" , "GS1 Spain" } )
   aAdd( aAgencias , { "299" , "BE, Seagha" } )
   aAdd( aAgencias , { "300" , "SE, Swedish International Freight Association" } )
   aAdd( aAgencias , { "301" , "DE, BauDatenbank GmbH" } )
   aAdd( aAgencias , { "302" , "DE, Bundesverband des Deutschen Textileinzelhandels e.V." } )
   aAdd( aAgencias , { "303" , "GB, Trade Service Information Ltd (TSI)" } )
   aAdd( aAgencias , { "304" , "DE, Bundesverband Deutscher Heimwerker-, Bau- und Gartenfachmaerkte e.V." } )
   aAdd( aAgencias , { "305" , "ETSO (European Transmission System Operator)" } )
   aAdd( aAgencias , { "306" , "SMDG (Ship-planning Message Design Group)" } )
   aAdd( aAgencias , { "307" , "JP, Ministry of Justice" } )
   aAdd( aAgencias , { "309" , "JP, JASTPRO (Japan Association for Simplification of International Trade Procedures)" } )
   aAdd( aAgencias , { "310" , "DE, SAP AG (Systeme, Anwendungen und Produkte)" } )
   aAdd( aAgencias , { "311" , "JP, TDB (Teikoku Databank, Ltd.)" } )
   aAdd( aAgencias , { "312" , "FR, AGRO EDI EUROPE" } )
   aAdd( aAgencias , { "313" , "FR, Groupement National Interprofessionnel des Semences et Plants" } )
   aAdd( aAgencias , { "314" , "OAGi (Open Applications Group, Incorporated)" } )
   aAdd( aAgencias , { "315" , "US, STAR (Standards for Technology in Automotive Retail)" } )
   aAdd( aAgencias , { "316" , "GS1 Finland" } )
   aAdd( aAgencias , { "317" , "GS1 Brazil" } )
   aAdd( aAgencias , { "318" , "IETF (Internet Engineering Task Force)" } )
   aAdd( aAgencias , { "319" , "FR, GTF" } )
   aAdd( aAgencias , { "320" , "DK, Danish National IT and Telcom Agency (ITA)" } )
   aAdd( aAgencias , { "321" , "EASEE-Gas (European Association for the Streamlining of Energy Exchange for gas)" } )
   aAdd( aAgencias , { "322" , "IS, ICEPRO" } )
   aAdd( aAgencias , { "323" , "PROTECT" } )
   aAdd( aAgencias , { "324" , "GS1 Ireland" } )
   aAdd( aAgencias , { "325" , "GS1 Russia" } )
   aAdd( aAgencias , { "326" , "GS1 Poland" } )
   aAdd( aAgencias , { "327" , "GS1 Estonia" } )
   aAdd( aAgencias , { "328" , "Assigned by ultimate recipient of the message" } )
   aAdd( aAgencias , { "329" , "Assigned by loading dock operator" } )
   aAdd( aAgencias , { "330" , "Nordic Ediel Group" } )
   aAdd( aAgencias , { "331" , "US, Agricultural Marketing Service (AMS)" } )
   aAdd( aAgencias , { "332" , "DE, DVGW Service & Consult GmbH" } )
   aAdd( aAgencias , { "333" , "US, Animal and Plant Health Inspection Service (APHIS)" } )
   aAdd( aAgencias , { "334" , "US, Bureau of Labor Statistics (BLS)" } )
   aAdd( aAgencias , { "335" , "US, Bureau of Transportation Statistics (BTS)" } )
   aAdd( aAgencias , { "336" , "US, Customs and Border Protection (CBP)" } )
   aAdd( aAgencias , { "337" , "US, Center for Disease Control (CDC)" } )
   aAdd( aAgencias , { "338" , "US, Consumer Product Safety Commission (CPSC)" } )
   aAdd( aAgencias , { "339" , "US, Directorate of Defense Trade Controls (DDTC)" } )
   aAdd( aAgencias , { "340" , "US, Environmental Protection Agency (EPA)" } )
   aAdd( aAgencias , { "341" , "US, Federal Aviation Administration (FAA)" } )
   aAdd( aAgencias , { "342" , "US, Foreign Agriculture Service (FAS)" } )
   aAdd( aAgencias , { "343" , "US, Federal Motor Carrier Safety Administration (FMCSA)" } )
   aAdd( aAgencias , { "344" , "US, Food Safety Inspection Service (FSIS)" } )
   aAdd( aAgencias , { "345" , "US, Foreign Trade Zones Board (FTZB)" } )
   aAdd( aAgencias , { "346" , "US, The Grain Inspection, Packers and Stockyards Administration (GIPSA)" } )
   aAdd( aAgencias , { "347" , "US, Import Administration (IA)" } )
   aAdd( aAgencias , { "348" , "US, Internal Revenue Service (IRS)" } )
   aAdd( aAgencias , { "349" , "US, International Trade Commission (ITC)" } )
   aAdd( aAgencias , { "350" , "US, National Highway Traffic Safety Administration (NHTSA)" } )
   aAdd( aAgencias , { "351" , "US, National Marine Fisheries Service (NMFS)" } )
   aAdd( aAgencias , { "352" , "US, Office of Fossil Energy (OFE)" } )
   aAdd( aAgencias , { "353" , "US, Office of Foreign Missions (OFM)" } )
   aAdd( aAgencias , { "354" , "US, Bureau of Oceans and International Environmental and Scientific Affairs (OES)" } )
   aAdd( aAgencias , { "355" , "US, Office of Naval Intelligence (ONI)" } )
   aAdd( aAgencias , { "356" , "US, Pipeline and Hazardous Materials Safety Administration (PHMSA)" } )
   aAdd( aAgencias , { "357" , "US, Alcohol and Tobacco Tax and Trade Bureau (TTB)" } )
   aAdd( aAgencias , { "358" , "US, Army Corp of Engineers (USACE)" } )
   aAdd( aAgencias , { "359" , "US, Agency for International Development (USAID)" } )
   aAdd( aAgencias , { "360" , "US, Coast Guard (USCG)" } )
   aAdd( aAgencias , { "361" , "US, Office of the United States Trade Representative (USTR)" } )
   aAdd( aAgencias , { "362" , "International Commission for the Conservation of Atlantic Tunas (ICCAT)" } )
   aAdd( aAgencias , { "363" , "Inter-American Tropical Tuna Commission (IATTC)" } )
   aAdd( aAgencias , { "364" , "Commission for the Conservation of Southern Bluefin Tuna (CCSBT)" } )
   aAdd( aAgencias , { "365" , "Indian Ocean Tuna Commission (IOTC)" } )
   aAdd( aAgencias , { "366" , "International Botanical Congress" } )
   aAdd( aAgencias , { "367" , "International Commission on Zoological Nomenclature" } )
   aAdd( aAgencias , { "368" , "International Society for Horticulture Science" } )
   aAdd( aAgencias , { "369" , "Chemical Abstract Service (CAS)" } )
   aAdd( aAgencias , { "370" , "Social Security Administration (SSA)" } )
   aAdd( aAgencias , { "371" , "INMARSAT" } )
   aAdd( aAgencias , { "372" , "Agent of ship at the intended port of arrival" } )
   aAdd( aAgencias , { "373" , "US Air Force" } )
   aAdd( aAgencias , { "374" , "US, Bureau of Explosives" } )
   aAdd( aAgencias , { "375" , "Basel Convention Secretariat" } )
   aAdd( aAgencias , { "376" , "PANTONE" } )
   aAdd( aAgencias , { "377" , "IS, National Registry of Iceland" } )
   aAdd( aAgencias , { "378" , "IS, Internal Revenue Directorate of Iceland" } )
   aAdd( aAgencias , { "379" , "IANA (Internet Assigned Numbers Authority)" } )
   aAdd( aAgencias , { "380" , "Korea Customs Service" } )
   aAdd( aAgencias , { "381" , "Israel Tax Authority" } )
   aAdd( aAgencias , { "382" , "Israeli Ministry of Interior" } )
   aAdd( aAgencias , { "383" , "FR, LUMD (Logistique Urbaine Mutualisee Durable)" } )
   aAdd( aAgencias , { "384" , "DE, BiPRO (Brancheninitiative Prozessoptimierung)" } )
   aAdd( aAgencias , { "385" , "JO, Jordan Ministry of Agriculture" } )
   aAdd( aAgencias , { "386" , "JO, Jordan Customs" } )
   aAdd( aAgencias , { "387" , "JO, Jordan Food & Drug Administration" } )
   aAdd( aAgencias , { "388" , "JO, Jordan Institution for Standards and Metrology" } )
   aAdd( aAgencias , { "389" , "JO, Jordan Telecommunication Regulatory Commission" } )
   aAdd( aAgencias , { "390" , "JO, Jordan Nuclear Regulatory Commission" } )
   aAdd( aAgencias , { "391" , "JO, Jordan Ministry of Environment" } )
   aAdd( aAgencias , { "392" , "Hazardous waste collector" } )
   aAdd( aAgencias , { "393" , "Hazardous waste generator" } )
   aAdd( aAgencias , { "394" , "Marketing agent" } )
   aAdd( aAgencias , { "395" , "BE, TELEBIB Centre" } )
   aAdd( aAgencias , { "396" , "BE, BNB" } )
   aAdd( aAgencias , { "397" , "BE, FSMA" } )
   aAdd( aAgencias , { "398" , "FR, PHAST" } )
   aAdd( aAgencias , { "399" , "EXIS (Exis Technologies Ltd.)" } )
   aAdd( aAgencias , { "400" , "FAO (Food and Agriculture Organisation)" } )
   aAdd( aAgencias , { "401" , "CH, Spedlogswiss" } )
   aAdd( aAgencias , { "402" , "JP, National Tax Agency" } )
   aAdd( aAgencias , { "403" , "Comite Europeen de Normalisation" } )
   aAdd( aAgencias , { "404" , "Assigned by logistics service provider" } )
   aAdd( aAgencias , { "405" , "Assigned by transport ministry" } )
   aAdd( aAgencias , { "406" , "AR, Customs Administration of Argentina" } )
   aAdd( aAgencias , { "407" , "BO, Customs Administration of Bolivia" } )
   aAdd( aAgencias , { "408" , "BR, Customs Administration of Brazil" } )
   aAdd( aAgencias , { "409" , "PY, Customs Administration of Paraguay" } )
   aAdd( aAgencias , { "410" , "UY, Customs Administration of Uruguay" } )
   aAdd( aAgencias , { "411" , "VE, Customs Administration of Venezuela" } )
   aAdd( aAgencias , { "412" , "IN, Customs Administration of India" } )
   aAdd( aAgencias , { "413" , "JP, JEC (UN/CEFACT Japan Committee)" } )
   aAdd( aAgencias , { "ZZZ" , "Mutually defined" } )

return aAgencias

/*
Função     : getIdenAdc
Objetivo   : Função retorna as identificações adicionais para integração do operador estrangeiro
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function getIdenAdc(nRecEKJ)
   local cRet       := ""
   local cIdenAdic  := ""
   local cFilEKT    := xFilial("EKT")

   default nRecEKJ := EKJ->(recno())

   // EKT_FILIAL+EKT_CNPJ_R+EKT_FORN+EKT_FOLOJA+EKT_AGEEMI+EKT_NUMIDE
   if EKT->(dbSeek(cFilEKT + EKJ->EKJ_CNPJ_R + EKJ->EKJ_FORN + EKJ->EKJ_FOLOJA))
      cRet := '['
      while EKT->(!eof()) .and. ;
         EKT->EKT_FILIAL == cFilEKT .and. EKT->EKT_CNPJ_R == EKJ->EKJ_CNPJ_R .and. EKT->EKT_FORN == EKJ->EKJ_FORN .and. EKT->EKT_FOLOJA == EKJ->EKJ_FOLOJA

         cIdenAdic := '{ "codigo": "' + alltrim(EKT->EKT_AGEEMI) + '", '
         cIdenAdic += '"numero": "' + alltrim(EKT->EKT_NUMIDE) + '" }'
         cRet += cIdenAdic + ', '

         EKT->(dbSkip())
      end
      cRet := substr( cRet, 1 , len(cRet)-2)
      cRet += ']'
   endif
 
return cRet
