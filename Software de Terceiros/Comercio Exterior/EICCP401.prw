#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EEC.CH"
#include 'EICCP401.CH'
#Include "TOPCONN.CH"

#Define ATT_COMPOSTO       "COMPOSTO"
#Define ATT_LISTA_ESTATICA "LISTA_ESTATICA"
#Define ATT_TEXTO          "TEXTO"
#Define ATT_BOOLEANO       "BOOLEANO"
/*
Programa   : EICCP4010   
Objetivo   : Rotina - Integra��o do Catalogo de Produtos
Retorno    : Nil
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Function EICCP401(aCapaAuto,nOpcAuto)
Local lRet := .T.
Local aArea := GetArea()
Local oBrowse
Local aCores 	:= {}
Local nX		:= 1
Local cModoAcEK9	:= FWModeAccess("EK9",3)
Local cModoAcEKA	:= FWModeAccess("EKA",3)
Local cModoAcEKB	:= FWModeAccess("EKB",3)
Local cModoAcEKD	:= FWModeAccess("EKD",3)
Local cModoAcEKE	:= FWModeAccess("EKE",3)
Local cModoAcEKF	:= FWModeAccess("EKF",3)
Local cModoAcSB1	:= FWModeAccess("SB1",3)
Local cModoAcSA2	:= FWModeAccess("SA2",3)

Private aRotina
Private lCP401Auto := ValType(aCapaAuto) <> "U" .Or. ValType(nOpcAuto) <> "U"
Private lMultiFil
Private lEkbPAis     :=EKB->(FieldPos("EKB_PAIS"))>0
Private lEKFVincFB   :=EKF->(FieldPos("EKF_VINCFB"))>0 

aCores :={{ "EKD_STATUS == '2' "	,"BR_AMARELO"  ,STR0008 },; //"Pendente Registro"
          { "EKD_STATUS == '1' "	,"ENABLE"      ,STR0009 },; //"Registrado"
          { "EKD_STATUS == '5' " ,"BR_AZUL"     ,STR0027 },;  //"Registrado (pendente: fabricante/pa�s)"
          { "EKD_STATUS == '6' " ,"BR_AZUL_CLARO",STR0028},; //Registrado Manualmente
          { "EKD_STATUS == '3' "	,"BR_VERMELHO" ,STR0010 },; //"Obsoleto"
          { "EKD_STATUS == '4' "	,"BR_PRETO"    ,STR0025 }} //"Falha de Integra��o"

lMultiFil      := VerSenha(115) .And. cModoAcEK9 == "C" .And. cModoAcSB1 == "E" .And. cModoAcSA2 == "E"

If !(cModoAcEK9 == cModoAcEKD .And. cModoAcEK9==cModoAcEKA .and. cModoAcEK9 == cModoAcEKE .And. cModoAcEK9==cModoAcEKB .And. cModoAcEK9 == cModoAcEKF)
   EasyHelp(STR0018,STR0014) //"O Modo de compatilhamento est� diferente entre as tabelas. Verifique o modo das tabelas EK9, EKA, EKB,EKD, EKE e EKF "###Aten��o
Else

	If !lCP401Auto
		oBrowse := FWMBrowse():New()                                 //Instanciando a Classe
		oBrowse:SetAlias("EKD")                                      //Informando o Alias 
		oBrowse:SetMenuDef("EICCP401")                               //Nome do fonte do MenuDef
		oBrowse:SetDescription(STR0007)                              //"Integra��o do Catalogo de Produtos" //Descri��o a ser apresentada no Browse   

		For nX := 1 To Len( aCores )                                 //Adiciona a legenda 	    
			oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
		Next nX
		
		oBrowse:SetAttach( .T. )                                     //Habilita a exibi��o de vis�es e gr�ficos
		oBrowse:SetViewsDefault(GetVisions())                        //Configura as vis�es padr�o
		oBrowse:ForceQuitButton()                                    //For�a a exibi��o do bot�o fechar o browse para fechar a tela                                                              
		oBrowse:Activate()                                           //Ativa o Browse 
	Else
		aRotina	:= MenuDef()
		INCLUI := nOpcAuto == INCLUIR                                //Defini��es de WHEN dos campos
		ALTERA := nOpcAuto == ALTERAR
		EXCLUI := nOpcAuto == EXCLUIR
		If ALTERA .Or. EXCLUI
			If aScan(aCapaAuto,{|x| x[1] == "EKD_VERSAO"}) == 0
				EasyHelp(STR0019,STR0014)//"A Opera��o de Exclus�o ou Altera��o deve conter a Vers�o do Cat�logo."####"Aten��o"
				lRet := .F.
			EndIf
		EndIf
		If INCLUI
			If aScan(aCapaAuto,{|x| x[1] == "EKD_VERSAO"}) > 0
				EasyHelp(STR0020,STR0014)//"Na Opera��o de Inclus�o n�o � permitido informar o campo de Vers�o do Cat�logo."###"Aten��o"
				lRet := .F.
			EndIf
		EndIf
		If lRet
			EasyMbAuto(nOpcAuto,aCapaAuto,"EKD",,,ModelDef(),{{"EKDMASTER",aCapaAuto}})
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return Nil

/*
Programa   : Menudef
Objetivo   : Estrutura do MenuDef - Funcionalidades: Pesquisar, Visualizar, Incluir, Alterar e Excluir
Retorno    : aRotina
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001 , "AxPesqui"			, 0, 1, 0, NIL } )	//'Pesquisar'
aAdd( aRotina, { STR0002 , 'VIEWDEF.EICCP401', 0, 2, 0, NIL } )	//'Visualizar'
aAdd( aRotina, { STR0003 , 'VIEWDEF.EICCP401', 0, 3, 0, NIL } )	//'Incluir'
aAdd( aRotina, { STR0026 , 'CP401Canc'	      , 0, 4, 0, NIL } )	//'Tornar Obsoleto'
aAdd( aRotina, { STR0005 , 'VIEWDEF.EICCP401', 0, 5, 0, NIL } )	//'Excluir'
aAdd( aRotina, { STR0006 , 'CP401Legen'		, 0, 1, 0, NIL } )	//'Legenda'

Return aRotina

/*
Programa   : ModelDef
Objetivo   : Cria a estrutura a ser usada no Modelo de Dados - Regra de Negocios
Retorno    : oModel
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function ModelDef()
Local oStruEKD			:= FWFormStruct( 1, "EKD", , /*lViewUsado*/ )
Local oStruEKE 		:= FWFormStruct( 1, "EKE", , /*lViewUsado*/ )
Local oStruEKF			:= FWFormStruct( 1, "EKF", , /*lViewUsado*/ )
Local oStruEKI			:= FWFormStruct( 1, "EKI", , /*lViewUsado*/ )
Local oModel			// Modelo de dados que ser� constru�do	
Local bPosValidacao	:= {|oModel| CP401POSVL(oModel)}
Local bCommit			:= {|oModel| CP401COMMIT(oModel)}
Local oMdlEvent      := CP401EV():New()
// Cria��o do Modelo
oModel := MPFormModel():New( "EICCP401", /*bPreValidacao*/, bPosValidacao, bCommit,  )
oModel:AddFields("EKDMASTER", /*cOwner*/ ,oStruEKD )                                               //Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:SetPrimaryKey( { "EKD_FILIAL", "EKD_COD_I" , "EKD_VERSAO"} )                                //Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0007)                                                                     //"Integra��o do Catalogo de Produtos
oModel:GetModel("EKDMASTER"):SetDescription(STR0007)                                               //Adiciona a descri��o do Componente do Modelo de Dados "Integra��o do Catalogo de Produtos"

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid - Rela��o de Produtos
oModel:AddGrid("EKEDETAIL","EKDMASTER", oStruEKE, /*bLinePre*/ ,/*bLinePos*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
oModel:GetModel("EKEDETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum PRODUTO //MFR 11/02/2022 OSSME-6595
oModel:GetModel("EKEDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("EKEDETAIL"):SetNoInsertLine(.T.)
oStruEKE:RemoveField("EKE_COD_I")
oStruEKE:RemoveField("EKE_VERSAO")

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid - Fabricantes
oModel:AddGrid("EKFDETAIL","EKDMASTER", oStruEKF, /*bLinePre*/ ,/*bLinePos*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
oModel:GetModel("EKFDETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum Fabricante
oModel:GetModel("EKFDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("EKFDETAIL"):SetNoInsertLine(.T.)
oStruEKF:RemoveField("EKF_COD_I")
oStruEKF:RemoveField("EKF_VERSAO")

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid - Atributos
CpoModel( oStruEKI )
oModel:AddGrid("EKIDETAIL","EKDMASTER", oStruEKI, /*bLinePre*/ ,/*bLinePos*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
oModel:GetModel("EKIDETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum Atributo
oModel:GetModel("EKIDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("EKIDETAIL"):SetNoInsertLine(.T.)
oStruEKI:RemoveField("EKI_COD_I")
oStruEKI:RemoveField("EKI_VERSAO")

//Modelo de rela��o entre Capa - Produto Referencia(EK9) e detalhe Rela��o de Produtos(EKA)

oModel:SetRelation('EKEDETAIL', {{ 'EKE_FILIAL'	, 'xFilial("EKE")'  },;
											{ 'EKE_COD_I'	, 'EKD_COD_I' },;
											{ 'EKE_VERSAO' , 'EKD_VERSAO'}}, EKE->(IndexKey(1)) )
							

oModel:SetRelation('EKFDETAIL', {{ 'EKF_FILIAL'	, 'xFilial("EKF")'  },;
											{ 'EKF_COD_I'	, 'EKD_COD_I' },;
											{ 'EKF_VERSAO' , 'EKD_VERSAO'}}, EKF->(IndexKey(1)) )

oModel:SetRelation('EKIDETAIL', {{ 'EKI_FILIAL'	, 'xFilial("EKI")'  },;
											{ 'EKI_COD_I'	, 'EKD_COD_I' },;
											{ 'EKI_VERSAO' , 'EKD_VERSAO'}}, EKI->(IndexKey(1)) )
										
oModel:InstallEvent("CP401EV", , oMdlEvent)

Return oModel

/*
Programa   : ViewDef
Objetivo   : Cria a estrutura Visual - Interface
Retorno    : oView
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function ViewDef()
Local oStruEKD := FWFormStruct( 2, "EKD" )
Local oStruEKE := FWFormStruct( 2, "EKE", , /*lViewUsado*/ )
Local oStruEKF := FWFormStruct( 2, "EKF" )
Local oStruEKI := FWFormStruct( 2, "EKI" )
Local oView
Local oModel   := FWLoadModel( "EICCP401" )
Local cOrdIDPort
//Cria o objeto de View
oView := FWFormView():New()                          // Adiciona no nosso View um controle do tipo formul�rio
oView:SetModel( oModel )                             // Define qual o Modelo de dados ser� utilizado na View
oView:AddField( 'VIEW_EKD', oStruEKD, 'EKDMASTER' )  // (antiga Enchoice)
oView:SetContinuousForm(.T.)
oView:CreateHorizontalBox( 'TELA' , 10 )            // Criar um "box" horizontal para receber algum elemento da view
oView:SetOwnerView( 'VIEW_EKD', 'TELA' )             // Relaciona o identificador (ID) da View com o "box" para exibi��o
oStruEKD:RemoveField("EKD_NALADI")
oStruEKD:RemoveField("EKD_GPCBRK")
oStruEKD:RemoveField("EKD_GPCCOD")
oStruEKD:RemoveField("EKD_UNSPSC")

If EKD->(ColumnPos("EKD_VATUAL")) > 0
   cOrdIDPort := oStruEKD:GetProperty("EKD_IDPORT", MVC_VIEW_ORDEM)
   oStruEKD:SetProperty("EKD_VATUAL", MVC_VIEW_ORDEM, Soma1(cOrdIDPort))
EndIf

//Adiciona no nosso View um controle do tipo FormGrid(antiga getdados)
oView:AddGrid("VIEW_EKE",oStruEKE , "EKEDETAIL")
oStruEKE:RemoveField("EKE_COD_I")
oStruEKE:RemoveField("EKE_VERSAO")
If IsMemVar('lMultiFil') .And. !lMultiFil
	oStruEKE:RemoveField("EKE_FILORI")
EndIf

//Identifica��o do componente
oView:EnableTitleView( "VIEW_EKE", STR0021 ) //"Rela��o de Produtos"
oView:CreateHorizontalBox( 'INFERIOR_EKE'  , 45 )
oView:SetOwnerView( "VIEW_EKE", 'INFERIOR_EKE' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga getdados)
oView:AddGrid("VIEW_EKF",oStruEKF , "EKFDETAIL")
oStruEKF:RemoveField("EKF_COD_I")
oStruEKF:RemoveField("EKF_VERSAO")
If IsMemVar('lMultiFil') .And. !lMultiFil
	oStruEKF:RemoveField("EKF_FILORI")
EndIf

//Identifica��o do componente
oView:EnableTitleView( "VIEW_EKF", STR0022 ) //"Rela��o de Fabricantes"
oView:CreateHorizontalBox( 'INFERIOR_EKF'  , 23 )
oView:SetOwnerView( "VIEW_EKF", 'INFERIOR_EKF' )

//Identifica��o do componente
oView:AddGrid("VIEW_EKI",oStruEKI , "EKIDETAIL")
oView:EnableTitleView( "VIEW_EKI", STR0024 ) //"Rela��o de Atributos"
oView:CreateHorizontalBox( 'INFERIOR_EKI'  , 22 )
oView:SetOwnerView( "VIEW_EKI", 'INFERIOR_EKI' )
oStruEKI:RemoveField("EKI_VERSAO")
oStruEKI:RemoveField("EKI_COD_I")
oStruEKI:RemoveField("EKI_VALOR")

if oStruEKI:HasField("EKI_CONDTE")
   oStruEKI:RemoveField("EKI_CONDTE")
endif

Return oView

/*
Programa   : CP401Canc
Objetivo   : Cancelar um Registro
Retorno    : Logico
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Function CP401Canc(oMdl)
Local lRet := .T. 
Local oModel
Local lExec := .T.

   oModel := FWLoadModel("EICCP401")                                   //Carrega o modelo de dados para altera��o
   oModel:SetOperation(4)
   oModel:Activate()

   If !oModel:GetModel():GetValue("EKDMASTER","EKD_STATUS") $ '1|6'
      EasyHelp(STR0013,STR0014) //"Apenas � poss�vel cancelar registro de integra��o do cat�logo de produto com os status '1-Integrado' e '6-Registrado Manualmente' " #Aten��o
      lRet := .F.
   EndIf

   If lRet .And. !lCP401Auto
      lExec := MsgYesNo(STR0011)                                          //"Confirma o cancelamento do registro desta integra��o de produto do cat�logo ?"
   EndIf

   If lRet .And. lExec
      oModel:GetModel():GetModel("EKDMASTER"):SetValue("EKD_STATUS",'3')  //Alteracao Status do registro
      If oModel:VldData()
         lRet := oModel:CommitData()
      Else
         lRet := .F.
      EndIf
      If !lRet
         EasyHelp(GetErrMessage(oModel),STR0014)
      EndIf
   EndIf

   oModel:Deactivate()
   //Limpa o Objeto pra liberar mem�ria
   FreeObj(oModel)

Return lRet
/*
Programa   : CP401POSVL
Objetivo   : Funcao de Pos Validacao
Retorno    : Logico
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function CP401POSVL(oMdl)
Local lRet := .T.

Do Case 
   Case oMdl:GetOperation() == 5  //Excluir
	   If oMdl:GetModel():GetValue("EKDMASTER","EKD_STATUS") <> "2"
		   EasyHelp(STR0012,STR0014) //"Apenas � poss�vel excluir registro de integra��o do cat�logo de produto com status '2-N�o integrado' " #Aten��o
		   lRet := .F.
	   EndIf
   Case oMdl:GetOperation() == 4  //Cancelar
      If oMdl:GetModel():GetValue("EKDMASTER","EKD_STATUS") == '3' .And. !EKD->EKD_STATUS $ '1|6'
		   EasyHelp(STR0013,STR0014) //"Apenas � poss�vel cancelar registro de integra��o do cat�logo de produto com status '1-Integrado' ou '6-Registrado Manualmente' " #Aten��o
		   lRet := .F.
      EndIf
		
End Case

Return lRet

Static Function CP401COMMIT(oMdl)
Local lRet := .T.
Local cErro:= ""
Local cCatalogo := oMdl:GetModel():GetValue("EKDMASTER","EKD_COD_I")
Begin Transaction
	If oMdl:GetOperation() == 3  //Incluir	
		If TemNaoInteg(cCatalogo) //Posciona EKD
			cErro := DelNaoInteg(cCatalogo,EKD->EKD_VERSAO)
		EndIf
		If Empty(cErro)
			CancelaTudo(cCatalogo)
		EndIf
	ElseIf oMdl:GetOperation() == 4  //Tornar Obsoleto
      EK9->(dbSetOrder(1))
      If EK9->(dbSeek( xFilial("EK9") + cCatalogo ))
         EK9->(RecLock("EK9",.F.))
         EK9->EK9_STATUS := "4" //Bloqueado
         EK9->EK9_VSMANU := " "
         EK9->EK9_VATUAL := " "
         EK9->(MsUnlock())
      EndIf

   EndIf
	If Empty(cErro)
		FWFormCommit(oMdl)
	Else
		DisarmTransaction()
	EndIf
End Transaction

If !Empty(cErro)
	EasyHelp(cErro,STR0014)
	lRet := .F.
EndIf

Return lRet
/*
Programa   : CP401Legen
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       :
*/
Function CP401Legen()
Local aCores := {}

   aCores := { {"BR_AMARELO"   ,STR0008   },;   //"Pendente Registro"
               {"ENABLE"       ,STR0009   },;   //"Registrado"
               {"BR_AZUL"      ,STR0027   },;    //"Registrado (pendente: fabricante/pa�s)"
               {"BR_AZUL_CLARO",STR0028   },; //Registrado Manualmente
               {"BR_VERMELHO"  ,STR0010	},;   //"Obsoleto"
               {"BR_PRETO"     ,STR0025   }}   //"Falha de Integra��o"

   BrwLegenda(STR0007,STR0006,aCores)

Return .T.

/*
Programa   : CP401IniBw
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X3_INIPAD do cadastro do campo.
*/
Function CP401IniBw(cCpo)
Local xRet
Local oModel,oModelEKD

   oModel    := FWModelActive()
   oModelEKD := oModel:GetModel("EKDMASTER")

   Do Case
      Case cCpo == "EKD_VERSAO"
         xret := Replicate(" ",TamSx3("EKD_VERSAO")[1] )
      Case cCpo == "EKD_STATUS"
         xRet := "2"
   End Case
Return xRet

/*
Programa   : CP401Trigg
Objetivo   : Executa os gatilhos dos campos da EKD
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X7_REGRA do gatilho do campo.
*/
Function CP401Trigg(cCpo)
Local xRet  := ""
Local oModel,oModelEKD,oModelEKE,oModelEKF,oModelEKI
Local lPosicEK9      := .F.

   oModel    := FWModelActive()
   oModelEKD := oModel:GetModel("EKDMASTER")
   oModelEKE := oModel:GetModel("EKEDETAIL")
   oModelEKF := oModel:GetModel("EKFDETAIL")
   oModelEKI := oModel:GetModel("EKIDETAIL")

   EK9->(DbSetOrder(1)) //Filial + Cod.Item Cat + Vers�o Atual
   If EK9->(AvSeekLAst( xFilial("EK9") + oModelEKD:GetModel():GetValue("EKDMASTER","EKD_COD_I") )) 
      lPosicEK9 := .T.
   EndIf

   Do Case
      Case cCpo == "EKD_COD_I"
         EKD->(DbSetOrder(1))
         If EKD->(AvSeekLAst( xFilial("EKD") + oModelEKD:GetModel():GetValue("EKDMASTER","EKD_COD_I") ))
            //Se status for nao integrado, deve manter a mesam versao, pois ao salvar a versao nao integrada sera excluida
            If EKD->EKD_STATUS == '2'
               xRet := EKD->EKD_VERSAO
            else
               xRet := SomaIt( EKD->EKD_VERSAO )
            EndIf
         Else
            xRet := StrZero(1,TamSX3("EKD_VERSAO")[1])
         EndIf

         LoadCpoMod( oModelEKD )
         LoadModEKE( oModelEKE )
         LoadModEKF( oModelEKF )
         LoadModEKI( oModelEKI )
   End Case

Return xRet

/*
Programa   : CP401SX7Cd
Objetivo   : Determina se o gatilho de um campo da EKD ser� executado.
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X7_COND do gatilho do campo.
*/
Function CP401SX7Cd(cCpo)
Local lRet
Local oModel,oModelEKD

oModel    := FWModelActive()
oModelEKD := oModel:GetModel("EKDMASTER")
Do Case
   Case cCpo == "EKD_COD_I"
      lRet := !Empty(oModelEKD:GetModel():GetValue("EKDMASTER","EKD_COD_I"))
EndCase

Return lRet

/*
Programa   : CP401Val
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X3_VALID do cadastro do campo.
*/
Function CP401Val(cCpo)
Local lRet := .T.
Local oModel,oModelEKD,cCod_I

oModel    := FWModelActive()
oModelEKD := oModel:GetModel("EKDMASTER")

Do Case
   Case cCpo == "EKD_COD_I"
      cCod_I := oModelEKD:GetModel():GetValue("EKDMASTER","EKD_COD_I")
      lRet := ExistCpo( "EK9", cCod_I , 1 )
		If lRet .And. TemNaoInteg(cCod_I) //Verifica se ja existe registro nao integrado para o codigo informado
			If IsMemVar("lCP401Auto") .And. !lCP401Auto 
				MsgInfo(STR0023,STR0014)//"Foi identificado um registro com o Status 'N�o integrado' para este mesmo c�digo. O registro ser� exclu�do automaticamente ao confirmar a inclus�o deste novo registro."###"Aten��o"
			EndIf
		EndIf
End Case

Return lRet

/*
Fun��o     : GetVisions()
Objetivo   : Retorna as vis�es definidas para o Browse
*/
Static Function GetVisions()
Local oDSView
Local aVisions := {}
Local aColunas := AvGetCpBrw("EKD")
Local aContextos := {"NAO_INTEGRADO", "INTEGRADO", "INTEGRADO_PENDENTE_FABRICANTE_PAIS","REGISTRADO_MANUALMENTE", "CANCELADO", "FALHA_INTEGRACAO"}
Local cFiltro
Local i

      If aScan(aColunas, "EKD_FILIAL") == 0
         aAdd(aColunas, "EKD_FILIAL")
      EndIf

      For i := 1 To Len(aContextos)
         cFiltro := RetFilter(aContextos[i])
         oDSView := FWDSView():New()
         oDSView:SetName(AllTrim(Str(i)) + "-" + RetFilter(aContextos[i], .T.))
         oDSView:SetPublic(.T.)
         oDSView:SetCollumns(aColunas)
         oDSView:SetOrder(1)
         oDSView:AddFilter(AllTrim(Str(i)) + "-" + RetFilter(aContextos[i], .F.), cFiltro)
         oDSView:SetID(AllTrim(Str(i)))
         oDsView:SetLegend(.T.)
         aAdd(aVisions, oDSView)
      Next

Return aVisions

/*
Fun��o     : RetFilter(cTipo)
Objetivo   : Retorna a chave ou nome do filtro da tabela EK9 de acordo com o contexto desejado
Par�metros : cTipo - C�digo do Contexto
             lNome - Indica que deve ser retornado o nome correspondente ao filtro (default .f.)
*/
Static Function RetFilter(cTipo, lNome)
Local cRet		:= ""
Default lNome	:= .F.

      Do Case
         Case cTipo == "NAO_INTEGRADO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '2' "
         Case cTipo == "NAO_INTEGRADO" .And. lNome
            cRet := STR0008 //"Pendente Registro"

         Case cTipo == "INTEGRADO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '1' "
         Case cTipo == "INTEGRADO" .And. lNome
            cRet  := STR0009 //"Registrado"

         Case cTipo == "INTEGRADO_PENDENTE_FABRICANTE_PAIS" .and. !lNome
            cRet := "EKD->EKD_STATUS = '5' "
         Case cTipo == "INTEGRADO_PENDENTE_FABRICANTE_PAIS" .and. lNome
            cRet := STR0027 //"Registrado (pendente: fabricante/pa�s)" 
            
         Case cTipo == "REGISTRADO_MANUALMENTE" .And. !lNome
            cRet := "EKD->EKD_STATUS = '6' "
         Case cTipo == "REGISTRADO_MANUALMENTE" .And. lNome
            cRet := STR0028 //"Registrado Manualmente"

         Case cTipo == "CANCELADO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '3' "
         Case cTipo == "CANCELADO" .And. lNome
            cRet := STR0010 //"Obsoleto"

         Case cTipo == "FALHA_INTEGRACAO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '4' "
         Case cTipo == "FALHA_INTEGRACAO" .And. lNome
            cRet := STR0025 //"Falha de Integra��o"

      EndCase

Return cRet

Static Function LoadCpoMod( oMdl )
Local aArea			:= GetArea()
Local lRet

If ValType(oMdl) == "O" .And. EK9->(!Eof())   
   oMdl:SetValue("EKD_IDPORT",EK9->EK9_IDPORT)   
   oMdl:SetValue("EKD_CNPJ"  ,AvKey(EK9->EK9_CNPJ, "EKD_CNPJ"))
   oMdl:SetValue("EKD_MODALI",EK9->EK9_MODALI)
   oMdl:SetValue("EKD_NCM"   ,EK9->EK9_NCM)
   oMdl:SetValue("EKD_UNIEST",EK9->EK9_UNIEST)
   oMdl:SetValue("EKD_OBSINT",EK9->EK9_OBSINT)
   oMdl:SetValue("EKD_RETINT",EK9->EK9_RETINT)
   If EK9->EK9_STATUS == "5" .And. IsMemVar("lCP401Auto") .And. lCP401Auto  //Registrado Manualmente - Integrado via Cat�logo
      oMdl:SetValue("EKD_STATUS","6")
      If EKD->(ColumnPos("EKD_VATUAL")) > 0
         oMdl:SetValue("EKD_VATUAL",EK9->EK9_VATUAL)
      EndIf
   EndIf
   //oMdl:SetValue("EKD_USERIN",cUserNAme) //Sera gravado o usuario da integra��o
   lRet := .T.
Else
   lRet := .F.
EndIf

RestArea(aArea)
Return lRet

/*
Fun��o     : LoadModEKE(oModel)
Objetivo   : Carregar dados de rela��o de produtos do catalogo
Par�metros : oModel - objeto do grid rela�ao de prod
Retorno    : lRet - Retorno se foram carregados os dados na tela
Autor      : Ramon Prado
Data       : dez/2019
Revis�o    :
*/
Static Function LoadModEKE( oModelEKE )
Local aArea  	:= getArea()
Local nContLn	:= 1
Local lRet 		:= .F.

If Valtype(oModelEKE) == "O" .And. EK9->(!Eof())
	oModelEKE:SetNoDeleteLine(.F.)
	oModelEKE:SetNoInsertLine(.F.)
   If oModelEKE:Length() > 0
      CP400Clear(oModelEKE)
   EndIf
   DbSelectArea("EKA")
   EKA->(DbSetOrder(1)) //EKA_FILIAL+EKA_COD_I+EKA_VERSAO
   If MsSeek(xFilial("EKA")+EK9->EK9_COD_I)
      While EKA->(!EOF()) .And. xFilial("EKA")+EKA->EKA_COD_I == EK9->EK9_FILIAL+EK9->EK9_COD_I
         If nContLn <> 1
           oModelEKE:AddLine()
         EndIf          
         oModelEKE:GoLine(nContLn)
         oModelEKE:SetValue("EKE_FILIAL"	,EKA->EKA_FILIAL)
         oModelEKE:SetValue("EKE_ITEM"		,EKA->EKA_ITEM)
		 	oModelEKE:SetValue("EKE_PRDREF"	,EKA->EKA_PRDREF)
         If lMultiFil 
            oModelEKE:SetValue("EKE_FILORI"	,EKA->EKA_FILORI)
            oModelEKE:SetValue("EKE_DESC_I"	, Posicione("SB1",1,EKA->EKA_FILORI+AvKey(EKA->EKA_PRDREF,"B1_COD"),"B1_DESC"))
         Else
            oModelEKE:SetValue("EKE_DESC_I"	,Posicione("SB1",1,XFILIAL("SB1")+AvKey(EKA->EKA_PRDREF,"B1_COD"),"B1_DESC"))
         EndIf
        
         lRet := .T.         
         nContLn++
         EKA->(DbSkip())
      EndDo   
   EndIf
   oModelEKE:GoLine(1)
Else
   lRet := .F.
Endif
oModelEKE:SetNoDeleteLine(.T.)
oModelEKE:SetNoInsertLine(.T.)
RestArea(aArea)
Return lRet

/*
Fun��o     : LoadModEKF(oModel)
Objetivo   : Carregar dados de rela��o de fabricantes do catalogo
Par�metros : oModel - objeto do grid rela�ao de fabric.
Retorno    : lRet - Retorno se foram carregados os dados na tela
Autor      : Ramon Prado
Data       : dez/2019
Revis�o    :
*/
Static Function LoadModEKF( oModelEKF )
Local aArea  	   := getArea()
Local nContLn	   := 1
Local lRet 		   := .F.
//Local lDeletedFB  := .F. //Retirado as ocorr�ncias da vari�vel lDeletedFB, n�o tem sentido tratar registros deletados
Local lStatInteg  := .F. 
Local QryFb       := ""
Local cCatalogo   := ""
Local cFilEKF     := ""
Local cChaveEKJ   := ""
Local cChaveEKJ2   := ""
Local cChaveSA2   := ""
Local cPais       := ""

If Valtype(oModelEKF) == "O" .And. EK9->(!Eof())
	oModelEKF:SetNoDeleteLine(.F.)
	oModelEKF:SetNoInsertLine(.F.)   
   If oModelEKF:Length() > 0
      CP400Clear(oModelEKF)
   EndIf 

   cCatalogo := EK9->EK9_COD_I  
   DbSelectArea("EKB")
   EKB->(DbSetOrder(1)) //EKB_FILIAL+EKB_COD_I+EKB_CODFAB+EKB_LOJA
   If MsSeek(xFilial("EKB")+cCatalogo)      
      lStatInteg := CP401GetSt(cCatalogo)

      QryFb := " SELECT EKB_CODFAB, EKB_LOJA, D_E_L_E_T_ AS DELETED"  
      If lEkbPAis
         QryFb += ", EKB_PAIS "
      EndIf
      If lMultifil
         QryFb += ", EKB_FILORI "
      EndIf
      
      QryFb += " FROM " + RetSQLName("EKB")
      QryFb += " WHERE EKB_FILIAL = '" + xFilial("EKB") + "' "
      QryFb += "   AND EKB_COD_I  = '" + cCatalogo + "' "
      //N�o tem sentido tratar registros deletados
      //If !lStatInteg   //para casos onde a �ltima vers�o da Integra��o do cat�logo est� com status diferente de "Integrado/Registrado"
         QryFb += "   AND D_E_L_E_T_ = ' ' " 
      //EndIf
      QryFb:= ChangeQuery(QryFb)
      DBUseArea(.T., "TopConn", TCGenQry(,, QryFb), "WkQryFb", .T., .T.)

      WkQryFb->(DBGoTop())
   
      While WkQryFb->(!EOF()) 
         // lDeletedFB := .F.   //Retirado as ocorr�ncias da vari�vel lDeleteFB, n�o tem sentido tratar registros deletados
         If nContLn <> 1
            oModelEKF:AddLine()
         EndIf

         oModelEKF:GoLine(nContLn)            
         oModelEKF:SetValue("EKF_CODFAB",WkQryFb->EKB_CODFAB)
         oModelEKF:SetValue("EKF_LOJA",WkQryFb->EKB_LOJA)
         If lMultiFil 
            oModelEKF:SetValue("EKF_FILORI",WkQryFb->EKB_FILORI)
            cFilEKF := WkQryFb->EKB_FILORI
            oModelEKF:SetValue("EKF_NOME",POSICIONE("SA2",1,WkQryFb->EKB_FILORI+WkQryFb->EKB_CODFAB+WkQryFb->EKB_LOJA,"A2_NOME"))            
         Else
            cFilEKF := xFilial("EKF")
            oModelEKF:SetValue("EKF_NOME",POSICIONE("SA2",1,XFILIAL("SA2")+WkQryFb->EKB_CODFAB+WkQryFb->EKB_LOJA,"A2_NOME"))            
         EndIf 

         If lEkbPais
            oModelEKF:SetValue("EKF_PAIS", WkQryFb->EKB_PAIS)
            oModelEKF:LoadValue("EKF_PAISDS", POSICIONE("SYA",1,xFilial("SYA")+WkQryFb->EKB_PAIS,"YA_DESCR"))
            cPais := WkQryFb->EKB_PAIS
         EndIf   

         If SA2->(dbsetorder(1),msseek(cChaveSA2))
            cChaveEKJ := SA2->A2_FILIAL+EK9->EK9_CNPJ+SA2->A2_COD+SA2->A2_LOJA
            EKJ->(dbsetorder(1))
            If EKJ->(msseek(cChaveEKJ)) .Or. EKJ->(msseek(cChaveEKJ2))
               oModelEKF:LoadValue("EKF_OPERFB", EKJ->EKJ_TIN)
            EndIf
         EndIf   

         /* //Retirado as ocorr�ncias da vari�vel lDeleteFB, n�o tem sentido tratar registros deletados
         If !Empty(WkQryFb->DELETED)
            lDeletedFB := .T.
         EndIf
         */
         
         If lEKFVincFB .And. lStatInteg                                                                                                         //Retirado as ocorr�ncias da vari�vel lDeleteFB, n�o tem sentido tratar registros deletados
            oModelEKF:LoadValue("EKF_VINCFB", CP401Vinc(cFilEKF,cCatalogo, CP401GetVs(cCatalogo), WkQryFb->EKB_CODFAB, WkQryFb->EKB_LOJA,cPais)) //o default � False,lDeletedFB  
         EndIf

         lRet := .T.
         nContLn++
         WkQryFb->(DbSkip())
      EndDo  
      WkQryFb->(dbcloseArea())       
   EndIf
   
   oModelEKF:GoLine(1)
Else
   lRet := .F.
Endif
oModelEKF:SetNoDeleteLine(.T.)
oModelEKF:SetNoInsertLine(.T.)
RestArea(aArea)
Return lRet

/*
Fun��o     : CP401Gatil(cCampo)
Objetivo   : Regras de gatilho para diversos campos
Par�metros : cCampo - campo cujo conteudo deve ser gatilhado
Retorno    : .T.
Autor      : Ramon Prado
Data       : dez/2019
Revis�o    :  
*/
Function CP401Gatil(cCampo)
Local aArea		   := GetArea()
Local oModel	   := FWModelActive()
Local oGridEKF    := oModel:GetModel("EKFDETAIL")
Local cRet        := ""

If cCampo == "EKF_PAISDS"   
   If !Empty(oGridEKF:getvalue("EKF_PAIS",oGridEKF:getline()))
      cRet := POSICIONE("SYA",1,xFilial("SYA")+oGridEKF:getvalue("EKF_PAIS",oGridEKF:getline()),"YA_DESCR")
   EndIf    
EndIf

RestArea(aArea)
Return cRet

/*
Fun��o     : CP401GetSt()
Objetivo   : Retornar o ultimo status da versao do historico de integracao
Par�metros : 
Retorno    : lRet - ultimo status � integrado .T. - .F. para nao integrado
Autor      : Ramon Prado
Data       : Maio/2021
Revis�o    :
*/
Static Function CP401GetSt(cCatalogo)
Local lRet     := .F.
Local aArea := GetArea()


EKD->(DbSetOrder(1))
If EKD->(AvSeekLAst( xFilial("EKD") + cCatalogo ))
   If EKD->EKD_STATUS == '3'
      lRet := .T. //integrado
   EndIf 
EndIf

RestArea(aArea)
Return lRet

/*
Fun��o     : CP401GetVs()
Objetivo   : Retornar a ultima versao do historico de integracao
Par�metros : 
Retorno    : lRet - ultima versao 
Autor      : Ramon Prado
Data       : Maio/2021
Revis�o    :
*/
Static Function CP401GetVs(cCatalogo)
Local cVersao := ""
Local aArea := GetArea()

EKD->(DbSetOrder(1))
If EKD->(AvSeekLAst( xFilial("EKD") + cCatalogo ))
   cVersao := EKD->EKD_VERSAO
EndIf

RestArea(aArea)
Return cVersao


/*
Fun��o     : LoadModEKI(oModel)
Objetivo   : Carregar dados de rela��o de atributos do catalogo
Par�metros : oModel - objeto do grid rela�ao de atributos.
Retorno    : lRet - Retorno se foram carregados os dados na tela
Autor      : Maur�cio Frison
Data       : abr/2020
Revis�o    :
*/
Static Function LoadModEKI( oModelEKI )
Local aArea    := getArea()
Local aAreaEKC := EKC->(getArea())
Local aAreaEKG := EKG->(getArea())
Local nContLn	:= 1
Local lRet     := .F.
Local cNome    := ""
Local cChaveEKG:= ""
local lCondic    := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
local cCodAtrib  := ""
local cCodCondic := ""
local nPosOrdem  := 0
local nOrdem     := 0
local nOrdCond   := 0
local aOrderAtrb := {}
local cOrdem     := ""

   If Valtype(oModelEKI) == "O" .And. EK9->(!Eof())
      oModelEKI:SetNoDeleteLine(.F.)
      oModelEKI:SetNoInsertLine(.F.)
      If oModelEKI:Length() > 0
         CP400Clear(oModelEKI)
      EndIf
      DbSelectArea("EKC")
      EKC->(DbSetOrder(1)) //EKC_FILIAL+EKC_COD_I+EKC_CODATR
      If MsSeek(xFilial("EKC")+EK9->EK9_COD_I)
         While EKC->(!EOF()) .And. xFilial("EKC")+EKC->EKC_COD_I == EK9->EK9_FILIAL+EK9->EK9_COD_I

            if lCondic
               cCodAtrib := EKC->EKC_CODATR
               cCodCondic := EKC->EKC_CONDTE
               if !empty(cCodCondic)
                  nPosOrdem := aScan( aOrderAtrb, { |X| X[1] == cCodCondic .and. empty(X[2]) })
                  if nPosOrdem > 0
                     nOrdem := aOrderAtrb[nPosOrdem][3]
                     nOrdCond := aOrderAtrb[nPosOrdem][4]
                  endif
                  nPosOrdem := aScan( aOrderAtrb, { |X| X[2] == cCodCondic .and. !empty(X[1]) } )
                  if nPosOrdem > 0
                     while nPosOrdem > 0
                        nOrdCond := if( nOrdCond <= aOrderAtrb[nPosOrdem][4], aOrderAtrb[nPosOrdem][4], nOrdCond )
                        nPosOrdem := aScan( aOrderAtrb, { |X| X[2] == cCodCondic .and. !empty(X[1]) }, nPosOrdem+1 )
                     end
                  endif
                  nOrdCond += 1
               else
                  nOrdem += 1
                  if aScan( aOrderAtrb, { |X| X[1] == cCodAtrib }) == 0
                     nOrdCond := 0
                  endif
               endif
               cOrdem := StrZero(nOrdem,3) + "_" + StrZero(nOrdCond,3)
               aAdd( aOrderAtrb , { cCodAtrib, cCodCondic, nOrdem, nOrdCond} )
            endif

            //Se utilizar campos da EKG s� usar ap�s a linha de baixo onde posiciona o registro nesta tabela
            cChaveEKG := xFilial("EKG")+EK9->EK9_NCM+EKC->EKC_CODATR + if( lCondic, EKC->EKC_CONDTE,"")
            EKG->(dbsetorder(1),msseek(cChaveEKG)) // POSICIONE("EKG",1,xFilial("EKC")+EK9->EK9_NCM+EKC->EKC_CODATR,"EKG_NIVIG")
            If nContLn <> 1
            oModelEKI:AddLine()
            EndIf
            cNome := (iif(EKG->EKG_OBRIGA == "1","* ","")) + AllTrim(EKG->EKG_NOME)
            oModelEKI:GoLine(nContLn)
            oModelEKI:SetValue("EKI_CODATR"  ,EKC->EKC_CODATR)
            oModelEKI:SetValue("EKI_STATUS"  ,CP400Status(EKG->EKG_INIVIG,EKG->EKG_FIMVIG))
            oModelEKI:SetValue("EKI_NOME"    , cNome )
            oModelEKI:SetValue("EKI_VALOR"   ,EKC->EKC_VALOR/*CP401Valor(alltrim(EKG->EKG_FORMA),.F.)*/)
            oModelEKI:SetValue("EKI_VLEXIB"  ,CP401Valor(alltrim(EKG->EKG_FORMA),.T.))
            if lCondic
               oModelEKI:SetValue("EKI_CONDTE"  , EKC->EKC_CONDTE)
               if( empty(oModelEKI:GetValue("ATRIB_ORDEM")), oModelEKI:LoadValue("ATRIB_ORDEM", cOrdem ) , )
            endif
            lRet := .T.
            nContLn++
            EKC->(DbSkip())
         EndDo
      EndIf

      if lCondic
         OrdAtrib(oModelEKI)
      endif
      oModelEKI:GoLine(1)
      oModelEKI:SetNoDeleteLine(.T.)
      oModelEKI:SetNoInsertLine(.T.)
   Else
      lRet := .F.
   Endif

   RestArea(aArea)
   RestArea(aAreaEKC)
   RestArea(aAreaEKG)

Return lRet

/*
Fun��o     : CP401Vinc()
Objetivo   : Carregar o valor de acordo com a forma de preenchimento
Par�metros : Cod do Catalogo, FAbri, Loja, Pais do Fabr.
Retorno    : Retorna a string com o status do vinculo
Autor      : Ramon Prado
Data       : Maio/2021
Revis�o    :
*/
Static Function CP401Vinc(cFilEKF,cCatalog,cVersaoEKF,cCodFab,cLojaFab,cPaisFb, lDeletedFB)
Local cVinculo    := ""
Local aArea       := GetArea()

Default lDeletedFB := .F.

If !lDeletedFB //registro n�o est� deletado na EKB - Rela��o de Fabricantes ou Pa�ses de Origem(Cat�logo)
   If !Empty(cVersaoEKF) .and. EKF->(dbsetorder(1),Msseek(cFilEKF+cCatalog+cVersaoEKF+cCodFab+cLojaFab+cPaisFb))
      cVinculo := "3" //sem alteracao   
   Else
      cVinculo := "1" //vincular ao cat�logo   
   EndIf
Else
   If !Empty(cVersaoEKF) .and. EKF->(dbsetorder(1),Msseek(xFilial("EKF")+cCatalog+cVersaoEKF+cCodFab+cLojaFab+cPaisFb))
      If lEKFVincFB .AND. EKF->EKF_VINCFB  $ '5'
         cVinculo := "3" //sem altera��o
      Else
         cVinculo := "2" //desvincular do cat�logo   
      EndIf
   EndIf
EndIf   

RestArea(aArea)
Return cVinculo

/*
Fun��o     : CP401Valor()
Objetivo   : Carregar o valor de acordo com a forma de preenchimento
Par�metros : lTrunca, se true trunca o valor do tipo texo em 100 posi��es
Retorno    : Retorna a stringa com o valor
Autor      : Maur�cio Frison
Data       : abr/2020
Revis�o    :
*/
Function CP401Valor(cForma,lTrunca)
Local cRetorno:=""

DO CASE
   CASE cForma == "LISTA_ESTATICA"
      cRetorno := Substr(getAtrName(EKC->EKC_VALOR, xFilial("EKH") + EK9->EK9_NCM + EKC->EKC_CODATR),1,100)
      //cRetorno := alltrim(EKC->EKC_VALOR) + "-" + POSICIONE("EKH",1,xFilial("EKH")+EK9->EK9_NCM+EKC->EKC_CODATR+EKC->EKC_VALOR,"EKH_DESCRE")
   CASE cForma == "BOOLEANO"
        cRetorno := if(EKC->EKC_VALOR == "", "", if(EKC->EKC_VALOR =="1", "SIM", "NAO"))
   CASE cForma == "TEXTO"
        cRetorno := if(lTrunca,substr(EKC->EKC_VALOR,1,100),EKC->EKC_VALOR)
   otherwise // CASE cForma == "NUMERO_REAL"
        cRetorno := EKC->EKC_VALOR
EndCase
Return cRetorno


Static Function GetErrMessage(oModel)
Local cRet := ""
Local aErro

aErro   := oModel:GetErrorMessage(.T.)
// A estrutura do vetor com erro �:
//  [1] Id do formul�rio de origem
//  [2] Id do campo de origem
//  [3] Id do formul�rio de erro
//  [4] Id do campo de erro
//  [5] Id do erro
//  [6] mensagem do erro
//  [7] mensagem da solu��o
//  [8] Valor atribuido
//  [9] Valor anterior

If !Empty(aErro[4]) .AND. SX3->(dbSetOrder(2),dbSeek(aErro[4]))
   xInfo := if(ValType(aErro[8])=="U",aErro[9],aErro[8])
   cRet += "Erro ao preencher campo '"+PadR(AvSX3(aErro[4],AV_TITULO),Len(SX3->X3_TITULO))+"' com valor "+if(ValType(xInfo)=="C","'","")+AllTrim(AvConvert(ValType(xInfo),"C",,xInfo))+if(ValType(xInfo)=="C","'","")+": "+aErro[6]+" "
Else
   cRet += "Registro Inv�lido ("+AllTrim(aErro[3])+"): "+AllTrim(aErro[6])+IF(Len(aErro[7]) > 2," Solu��o: "+AllTrim(aErro[7]),"")
EndIf

Return cRet

/*
Fun��o     : CP400Clear(oModel)
Objetivo   : Limpar dados do grid desejado
Par�metros : oModel - objeto do grid 
Retorno    : lRet - Retorno se foi feito com sucesso a limpa dos dados
Autor      : Ramon Prado
Data       : Jan/2020
Revis�o    :
*/
Static Function CP400Clear(oModel)
Local aArea   		  := GetArea()
Local lRet	    	  := .F.
Local nI := 0

For nI := 1 To oModel:Length()
   oModel:GoLine( nI )
   If !oModel:IsDeleted()
      oModel:DeleteLine()
   EndIf
Next

oModel:ClearData()

RestArea(aArea)
Return lRet

/*
Programa   : TemNaoInteg
Objetivo   : Verifica se para o codigo informado, existe registro nao integrado
Retorno    : .T. quando encontrar registro nao integrado; .F. n�o encontrar registro nao integrado
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 30/12/2019
*/
Static Function TemNaoInteg(cCod_I)
Local lRet := .F.
Local cQuery:= GetNextAlias()

BeginSQL Alias cQuery
   SELECT R_E_C_N_O_ RECNO 
   FROM %Table:EKD% EKD
      WHERE EKD_FILIAL = %xFilial:EKD%
        AND EKD_COD_I  = %Exp:cCod_I%
        AND EKD_STATUS = '2' 
        AND EKD.%NotDel%
EndSQL

If (cQuery)->(!Eof())
	lRet := .T.
   EKD->(dbGoTo((cQuery)->(RECNO)))
EndIf
(cQuery)->(dbCloseArea())
Return lRet

/*
Programa   : DelNaoInteg
Objetivo   : Delete o registro nao integrado ao incluir um novo registro.
Retorno    : .T. caso a exclus�o tenha sido realizada; .F. caso n�o tenha sido efetivada a exclus�o
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 02/01/2020
*/
Static Function DelNaoInteg(cCod_I,cVersaoEKD)
Local cRet  	:= ""
Local aCapaEKD := {}
Local oErro		:= AvObject():New()
aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")	, Nil})
aAdd(aCapaEKD,{"EKD_COD_I"	, cCod_I				, Nil})
aAdd(aCapaEKD,{"EKD_VERSAO", cVersaoEKD		, Nil})

EasyMVCAuto("EICCP401",5,{{"EKDMASTER", aCapaEKD}},oErro)
If oErro:HasErrors()
	cRet := oErro:GetStrErrors()
EndIf

Return cRet

/*
Programa   : CancelaTudo
Objetivo   : Alterar o status de todos os registros do codigo informado para 3-Cancelado
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 30/12/2019
*/
Static Function CancelaTudo(cCod_I)
Local aAreaEKD := EKD->(getArea())
Local aAreaEK9 := EK9->(getArea())
EKD->(dbSetOrder(1)) //EKD_FILIAL, EKD_COD_I, EKD_VERSAO
If EKD->(dbSeek(xFilial("EKD") + cCod_I))

	While EKD->(!EOF()) .And. EKD->EKD_FILIAL == xFilial("EKD") .And. EKD->EKD_COD_I == cCod_I
		If EKD->EKD_STATUS != '3'
			RecLock("EKD",.F.)
			EKD->EKD_STATUS := '3' //Cancelado
			EKD->(MsUnlock())
		EndIf
		EKD->(dbSkip())
	End

   EK9->(dbSetOrder(1))
   If IsMemVar("lCP401Auto") .And. !lCP401Auto .And. EK9->(dbSeek( xFilial("EK9") + cCod_I )) 
      EK9->(RecLock("EK9",.F.))
      EK9->EK9_STATUS := "3" //Pendente Retifica��o
      EK9->EK9_VSMANU := " "
      EK9->EK9_VATUAL := " "
      EK9->(MsUnlock())
   EndIf

EndIf

RestArea(aAreaEK9)
RestArea(aAreaEKD)
Return

/*
CLASSE PARA CRIA��O DE EVENTOS E VALIDA��ES NOS FORMUL�RIOS
MFR - Maur�cio Frison
 */
Class CP401EV FROM FWModelEvent
     
    Method New()
    Method Activate()

End Class

Method New() Class CP401EV
Return

Method Activate(oModel,lCopy) Class CP401EV
  CP401AtuAtrib(oModel)
Return

Function CP401AtuATrib(oModel)
Local oModelEKI	:= oModel:GetModel("EKIDETAIL")
Local nI
Local nOperation := oModel:GetOperation()
Local aAreaEKG := EKG->(getArea())

If nOperation == 5 //Exclus�o
    oModel:nOperation := 3
EndIf
If oModelEKI:Length() > 0
   EKG->(dbSetORder(1)) //EKG_FILIAL, EKG_NCM, EKG_COD_I, EKG_CONDTE
   oModelEKI:GoLine(1)
   For nI := 1 to oModelEKi:Length()
      oModelEKI:GoLine( nI )
      If EKG->(dbSeek(xFilial("EKG") + EKD->EKD_NCM + oModelEKI:getValue("EKI_CODATR") + If( Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS"), oModelEKI:getValue("EKI_CONDTE"),""))) 
         If Alltrim(EKG->EKG_FORMA) == ATT_LISTA_ESTATICA
            oModelEKI:LoadValue("EKI_VLEXIB",substr(getAtrName(oModelEKI:getValue("EKI_VALOR"), xFilial("EKH") + EKD->EKD_NCM + oModelEKI:getValue("EKI_CODATR")),1,100))
         ElseIf Alltrim(EKG->EKG_FORMA) == ATT_BOOLEANO
            oModelEKI:LoadValue("EKI_VLEXIB",if(oModelEKI:getValue("EKI_VALOR")=="1","SIM",if(oModelEKI:getValue("EKI_VALOR")=="2","NAO","")))
         Else
            oModelEKI:LoadValue("EKI_VLEXIB",substr(oModelEKI:getValue("EKI_VALOR"),1,100))
         EndIf
      Else
         oModelEKI:LoadValue("EKI_VLEXIB",substr(oModelEKI:getValue("EKI_VALOR"),1,100))
      EndIf
   Next
   oModelEKI:GoLine(1)
   RestArea(aAreaEKG)
EndIf
oModel:nOperation := nOperation
return .t.


/*/{Protheus.doc} CpoModel
   inclus�o de campo no modelo 

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param  oStruct, Objeto, Objeto da classe FWFormStruct
   @return 
/*/
static function CpoModel( oStruct )
   if Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
      oStruct:AddField( "Ordem"                        , ; // [01]  C   Titulo do campo
                        "Ordem"                        , ; // [02]  C   ToolTip do campo
                        "ATRIB_ORDEM"                  , ; // [03]  C   identificador (ID) do Field
                        "C"                            , ; // [04]  C   Tipo do campo
                        7                              , ; // [05]  N   Tamanho do campo
                        0                              , ; // [06]  N   Decimal do campo
                        {|| .T. }                      , ; // [07]  B   Code-block de valida��o do campo
                        {|| .F. }                      , ; // [08]  B   Code-block de valida��o When do campo
                        {}                             , ; // [09]  A   Lista de valores permitido do campo
                        .F.                            , ; // [10]  L   Indica se o campo tem preenchimento obrigat�rio
                        nil                            , ; // [11]  B   Code-block de inicializacao do campo
                        .F.                            , ; // [12]  L   Indica se trata de um campo chave
                        .T.                            , ; // [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
                        .T.                            )   // [14]  L   Indica se o campo � virtual
   endif

return

/*/{Protheus.doc} OrdAtrib
   Ordenar os atributos 

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param oModelEKC, objeto, modelo EKI
   @return 
/*/
static function OrdAtrib(oModelEKI)
   local nPosOrdem  := 0
   local oStrGrd    := oModelEKI:getStruct()

   nPosOrdem  := oStrGrd:GetFieldPos("ATRIB_ORDEM")
   if nPosOrdem > 0
      aSort(oModelEKI:aDATAMODEL,,, {|x,y| x[1][1][nPosOrdem] < y[1][1][nPosOrdem] } )
   endif

return 

/*/{Protheus.doc} getAtrName
   Retornar o codigo da lista de atributos com descri��o
   O campo cChave n�o deve conter os valores do dominio, pois estes v�o estar no cValor

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param oModelEKC, objeto, modelo EKI
   @return 
/*/
Static Function getAtrName(cValor, cChave)
Local cRetorno := ""
Local aAreaEKH := EKH->(GetArea())
Local aValores
Local nI

EKH->(dbSetOrder(1))//EKH_FILIAL, EKH_NCM, EKH_COD_I, EKH_CODDOM
aValores := strTokArr( alltrim(cValor), ";" )
For nI := 1 To Len(aValores)
   If EKH->(dbSeek( cChave + aValores[nI]))
      cRetorno += Alltrim(EKH->EKH_CODDOM) + " - " + Alltrim(EKH->EKH_DESCRE) + " ;"
   endif
next 
cRetorno := Substr( cRetorno, 1, Len(cRetorno)-1)
RestArea(aAreaEKH)
   
Return cRetorno