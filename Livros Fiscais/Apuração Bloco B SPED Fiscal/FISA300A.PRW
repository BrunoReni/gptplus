#Include "FISA300A.CH"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA300A()

Esta rotina tem objetivo de exibir as informa��es da apura��o de ISS
por munic�pio e tamb�m por c�digo de servi�o.

@author Erick G. Dias
@since 12/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FISA300A(cModo)

Private cModApur := cModo

FWExecView(STR0001 + FWGETCODFILIAL + ' - ' +SM0->M0_FILIAL,'FISA300A', MODEL_OPERATION_VIEW) //'Filial: '

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 11/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA300A" ) 

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Cria��o do modelo, para exibir cabe�alho com informa��e da apura��o, grid com os totais por
c�digo ed munic�pio, e outro grid com as informa��es totalizadas por c�digo de servi�o.

@author Erick G Dias
@since 12/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil
Local lSaveApur := isincallstack("SAVEAPUR")
Local lNoDel    := !lSaveApur
Local lNoAdd    := !lSaveApur
Local lNoUpd    := !lSaveApur
Local bPreValid := { |oModelGrid, nLine, cAction, cField| FSA300APRE(oModelGrid, nLine, cAction, cField) }	

//Estrutura Pai com as informa��es de cabe�alho da apura��o
Local oCabApur := FWFormStruct(1, "F1P")

//Estrutura Filho com as informa��es agrupadas por c�digo munic�pio 
Local oMunicipio := FWFormStruct(1, "F1N")

//Estrutura Filho com as informa��es agrupadas por c�digo de servi�o do munic�pio selecionado
Local oServico := FWFormStruct(1, "F1O")

//Estrutura Filho com as informa��es dos t�tulos gerados pela apura��o por munic�pio
Local oTitulo := FWFormStruct(1, "F1R")

//Estrutura Filho com as informa��es das dedu��es de ISS
Local oDeducao := FWFormStruct(1, "F1Q")

//Instanciando o modelo
oModel := MPFormModel():New('FISA300A')

//Atribuindo estruturas para o modelo, cabe�alho da apura��o
oModel:AddFields("FISA300A",, oCabApur)

//Adiciona o Grid ao modelo, correspondente ao munic�pio
oModel:AddGrid('FISA300AMUNICIPIO', 'FISA300A', oMunicipio)
//Somente permite adicionar e excluir linha quando modelo � processado por meio da classe de apura��o
oModel:GetModel('FISA300AMUNICIPIO'):SetNoInsertLine(lNoAdd)
oModel:GetModel('FISA300AMUNICIPIO'):SetNoDeleteLine(lNoDel)
oModel:GetModel( 'FISA300AMUNICIPIO' ):SetNoUpdateLine(lNoUpd)

//Adiciona o grid com informa��es do servi�o prestado
oModel:AddGrid('FISA300ASERVICO', 'FISA300AMUNICIPIO', oServico)
//Somente permite adicionar e excluir linha quando modelo � processado por meio da classe de apura��o
oModel:GetModel('FISA300ASERVICO'):SetNoInsertLine(lNoAdd)
oModel:GetModel('FISA300ASERVICO'):SetNoDeleteLine(lNoDel)

//Adiciona o grid com informa��es do t�tulo
oModel:AddGrid('FISA300ATITULO', 'FISA300AMUNICIPIO', oTitulo, bPreValid)
//Somente permite adicionar e excluir linha quando modelo � processado por meio da classe de apura��o
oModel:GetModel('FISA300ATITULO'):SetNoInsertLine(lNoAdd)

//N�o permite altera��o do tipo de apura��o e o valor
oTitulo:SetProperty('F1R_TPIMP' , MODEL_FIELD_WHEN, {|| .F. })
oTitulo:SetProperty('F1R_VALOR' , MODEL_FIELD_WHEN, {|| .F. })

//Torna obrigat�rio o preenchimento dos campos abaixo para gera��o dos t�tulos
oTitulo:SetProperty( 'F1R_FORN'   , MODEL_FIELD_OBRIGAT, lNoAdd )
oTitulo:SetProperty( 'F1R_LOJA'   , MODEL_FIELD_OBRIGAT, lNoAdd )
oTitulo:SetProperty( 'F1R_VENCTO' , MODEL_FIELD_OBRIGAT, lNoAdd )
oTitulo:SetProperty( 'F1R_NATURE' , MODEL_FIELD_OBRIGAT, lNoAdd )
oTitulo:SetProperty( 'F1R_VALOR'  , MODEL_FIELD_OBRIGAT, lNoAdd )

//Regra de valida��o do vencimento
oTitulo:SetProperty( 'F1R_VENCTO'  , MODEL_FIELD_VALID, {|| oModel:GetValue ('FISA300ATITULO',"F1R_VENCTO") >= dDataBase } )

//Adiciona o grid com as dedu��ees
oModel:AddGrid('FISA300ADEDUCOES', 'FISA300AMUNICIPIO', oDeducao)

//As informa��es de detalhamento por servi�o � opicional, na hip�tese de n�o existir nenhuma movimenta��o no per�odo
oModel:GetModel( 'FISA300ASERVICO' ):SetOptional( .T. )

//As informa��es do t�tulo � opicional, pois nem sempre haver� t�tulo gerado
oModel:GetModel( 'FISA300ATITULO' ):SetOptional( .T. )

//Dedu��es � opicional, nem sempre ter� dedu��es
oModel:GetModel( 'FISA300ADEDUCOES' ):SetOptional( .T. )

//Relacionamento entre as tabelas F1P cabe�alho da apura��o com a tabela F1N totais por munic�pio
oModel:SetRelation('FISA300AMUNICIPIO', {{'F1N_FILIAL', 'xFilial("F1N")'}, {'F1N_IDAPUR', 'F1P_ID'}}, F1N->(IndexKey(2)))

//Relacionamento entre as tabelas F1N apura��o por munic�pio com a tbaela F1N apura��o por munic�pio
oModel:SetRelation( 'FISA300ASERVICO', {{'F1O_FILIAL', 'xFilial("F1O")'}, {'F1O_IDAPUR', 'F1N_ID'}}, F1O->( IndexKey(2))) 

//Relacionamento entre as tabelas F1N apura��o por munic�pio com a tbaela F1R informa��es dos t�tulos
oModel:SetRelation( 'FISA300ATITULO', {{'F1R_FILIAL', 'xFilial("F1R")'}, {'F1R_IDAPUR', 'F1N_ID'}}, F1R->( IndexKey(1)))

//Relacionamento entre as tabelas F1N apura��o por munic�pio com a tbaela F1Q dedu��es de ISS
oModel:SetRelation( 'FISA300ADEDUCOES', {{'F1Q_FILIAL', 'xFilial("F1Q")'}, {'F1Q_IDAPUR', 'F1N_ID'}}, F1Q->( IndexKey(1)))

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0002) //"Totais da Apura��o de ISS"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias
@since 12/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados
Local oModel := FWLoadModel("FISA300A")

//Cria��o da estrutura de dados utilizada na interface
Local oMunicipio    := FWFormStruct(2, "F1N")
Local oServico      := FWFormStruct(2, "F1O")
Local oView         := Nil

oView := FWFormView():New()
oView:SetModel(oModel)

//Atribuindo formul�rios para interface
oView:AddGrid('VIEW_MUNICIPIO', oMunicipio  , 'FISA300AMUNICIPIO' )
oView:AddGrid('VIEW_SERVICO'  , oServico    , 'FISA300ASERVICO'   )

//Retira da view os campos de ID
oMunicipio:RemoveField('F1N_ID')
oMunicipio:RemoveField('F1N_IDAPUR')
oMunicipio:RemoveField('F1N_DEDPRP')
oMunicipio:RemoveField('F1N_DEDSUB')
oMunicipio:RemoveField('F1N_DEDUNI')
oMunicipio:RemoveField('F1N_RECUNI')
oMunicipio:RemoveField('F1N_QTDUNI')
oMunicipio:RemoveField('F1N_VLFUNI')
oMunicipio:RemoveField('F1N_STATUS')
oServico:RemoveField( 'F1O_ID')
oServico:RemoveField( 'F1O_IDAPUR')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox('SUPERIOR', 50)
oView:CreateHorizontalBox('INFERIOR', 50)

//O formul�rio da interface ser� colocado dentro do container
oView:SetOwnerView('VIEW_MUNICIPIO', 'SUPERIOR'   )
oView:SetOwnerView('VIEW_SERVICO'  , 'INFERIOR')

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_MUNICIPIO'  , STR0003) //"Totais por Munic�pio"
oView:EnableTitleView('VIEW_SERVICO' , STR0004) //"Totais por Servi�o"

//Desabilita op��o de ordena��o do Grid
oView:SetViewProperty( "*", "GRIDNOORDER")

//Duplo clique no muniuc�pio ter� a��o de abrir tela com detalhamento da apura��o
oView:SetViewProperty("VIEW_MUNICIPIO", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel, cField| FSA300AGDC(oFormulario,cFieldName,nLineGrid,nLineModel,cField)}}) 

//Adiciona o bot�o de FSA300DLEG
oView:AddUserButton( STR0005, 'CLIPS', {|oView| FSA300DLEG()} ) //'Legenda'

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300AGDC

Fun��o que faz o tratamento do duplo click no munic�pio
para abrir a tela com resumo da apura��o do munic�pio em quest�o

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300AGDC(oFormulario,cFieldName,nLineGrid,nLineModel,cField)

Local oMunicipio 	:= oFormulario:GetModel("FISA300AMUNICIPIO") //Obtenho o modelo da F1N
Local cIdF1N	    := oMunicipio:GetValue("F1N_ID") //Obtenho o ID que foi clicado
Local cIdF1P	    := oMunicipio:GetValue("F1N_IDAPUR") //Obtenho o ID que foi clicado
Local cUf	        := oMunicipio:GetValue("F1N_UF") //Obtenho o Estado
Local cCodMun	    := oMunicipio:GetValue("F1N_CODMUN") //Obtenho o ID que foi clicado
Local cStatus       := oMunicipio:GetValue("F1N_STATUS")
Local oModel        := FWModelActive()
Local oView 		:= FWViewActive()
Local oApurISS		:= Nil
Local aApurMun  	:= {}
Local oTotServ      := {}

//Verifico primeiro se o ID n�o est� vazio
If !Empty(cIdF1N) .AND. CC2->(MsSeek(xFilial("CC2") + cUf + cCodMun ))        
    
    //Cria��o do objeto da apura��o
    oApurISS := APURISS():New()
    
    //Faz carga dos valores da apura��o
    oApurISS:LoadApur(cIdF1P)
    
    //Faz carga dos valores por c�digo de servi�o
    aApurMun := oApurISS:getApurMun(RetUfIBGE(cUf)+cCodMun)

    IF Len(aApurMun) > 0

        //Totalizar os valores da lista de servi�os
        oTotServ := FSA300SMOV(aApurMun)
        
        //Chamo tela de resumo da apura��o do munic�pio selecionado
        FISA300B(cModApur, cIdF1P, cIdF1N, Alltrim(CC2->CC2_MUN), oApurISS, aApurMun[1], oTotServ, RetUfIBGE(cUf)+cCodMun, cStatus)

        //Destroi objeto
        FreeObj(oTotServ)
	    oTotServ:= NIL

    EndIf
    
    oApurISS:Clear()

    //Destroi objeto
    FreeObj(oApurISS)   
    oApurISS := Nil     

    //Faz atualiza��o dos valores na tela
    oModel:DeActivate() 
    oModel:Activate()           
    oview:Refresh( 'FISA300AMUNICIPIO' )

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300SMOV

Fun��o que far� a totaliza��o dos valores da lsita de servi�os
para exibir na tela de resumo da apura��o do munic�pio selecionado

@author Erick G. Dias
@since 17/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300SMOV(aApurMun)

Local nX     := 0
Local nY     := 0
Local aServicos := {}
Local oTotServ := APURISSMOV():New()

//Preenche o array com zeros
aFill(aServicos, 0, ,10)

//La�o nos munic�pios
For nX:= 1 to Len(aApurMun)
    
    //Obte a lista de servi�os do munic�pio corrente no la�o
    aServicos:= aApurMun[nX]:getServicos()    

    //La�o na lista dos servi�os
    For nY:= 1 to Len(aServicos)        

        //Realiza a soma dos valores e deixa encapsulado no objeto
        oTotServ:somarMov(aServicos[nY])
    Next nY

Next nX

Return oTotServ

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300APRE

Fun��o que far� a valida��o para n�o permitir alterar todos os campos
do grid dos t�tulos.

@author Erick G. Dias
@since 01/07/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function FSA300APRE(oModelGrid, nLine, cAction, cField)

Local cCampoAlt     := "F1R_PREFIX/F1R_FORN/F1R_LOJA/F1R_VENCTO/F1R_NATURE"
Local lRet          := .F.
Local oModel        :=	FWModelActive()
Local oMunicipio	:= oModel:GetModel('FISA300AMUNICIPIO')
Local cStatus   	:= oMunicipio:GetValue("F1N_STATUS")

//Verifica��o para permitir edi��o dos campos.
If isInCallStack("FSA300FATU") .OR. isInCallStack("SAVEAPUR")
    //Para estes processos permitir� editar informa��o
    lRet    := .T.    
ElseIf cCampoAlt $ cCampoAlt .AND. cStatus == "1"
    //Para estes campos se for edi��o manual tamb�m permitir�, por�m somente para apura��es que ainda n�o geraram t�tulo e/ou contabiliza��o.
    lRet    := .T.    
EndIF

Return lRet
 