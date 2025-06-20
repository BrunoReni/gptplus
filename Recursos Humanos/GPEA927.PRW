#include 'Protheus.ch'
#Include 'fwmvcdef.ch'    
#include 'GPEA927.CH'      

//Integra��o com o TAF
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )  
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static cVerTrab		:= "2.2"
Static cVerGPE		:= ""
Static cVersEnvio	:= ""

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA927  � Autor � Alessandro Santos                 � Data � 15/01/2014 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Informacoes de Funcionarios Temporarios (RBW)         					���   
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA927()                                                                ���
���������������������������������������������������������������������������������������Ĵ�� 
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                     ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���Alessandro S�15/01/2014�00000000823/2014�Inclusao da rotina para atender a Fase 2    ���
���            �          �          TIFBQF�eSocial, Cadastro de Funcionarios Temporario���  
���Alessandro S�24/01/2014�00000000823/2014�Ajuste na validacao dos funcionarios para   ���
���            �          �          TIFBQF�considerar o Vinculo Empregaticio..         ���
���Alessandro S�24/01/2014�00000000823/2014�Ajuste para considerar vinculo empregaticio ���
���            �          �          TIFBQF�306 e removidas validacoes de Fase 2 eSocial���
���Alessandro S�28/01/2014�00000000823/2014�Ajuste para apresentar corretamente a descri���
���            �          �          TIFBQF�cao da rotina.                              ���    
���Gustavo M.  �01/06/2014�			 TPHIYY�Ajuste para uso da tela centralizadora.		���
���Christiane V�02/07/2015�          TSMUY2�Adapta��es para vers�o 2.0 do eSocial       ���
���Mariana M.  �15/09/2015�          TTIWMQ�Ajuste na fun��o ModelDef,onde sistema est� ���
���            �          �                �carregando o modelo incorreto para abertura ���
���            �          �                �da tela. Ajustado para que busque oModel e  ���
���            �          �                �nao oMdlRBW									���
���Raquel Hager�24/08/2016�TVTOQD          �Remo��o do uso do par�metro MV_INTTAF para  ���
���            �          �                �release 12.1.7.							    ���
���MArcia Moura�23/06/2017�DRHESOCP-470    �Inclusao no novo controle de eSocial        ���			    
���Oswaldo L   �23/06/2017�DRHESOCP-439    �Corre��o variaveis n�o declaradas no fonte  ���			    
���Oswaldo L   �04/08/2017�DRHESOCP-755    �Replica ajustes e-social feit apenas na 12  ���
��|Claudinei S.|11/09/2017|    DRHESOCP-729 |Inclu�da chamada para a nova tela da pror- |��
��|            |          |                 |roga��o dos tempor�rios leiaute 2.3.       |��
��|Claudinei S.|14/09/2017|   DRHESOCP-1018 |Consist�ncia do leiaute 2.3 para os func.  |��
��|            |          |                 |tempor�rios.                               |��
��|Marcos Cout.|23/11/2017|   DRHESOCP-2010 |Caso o lIntTaf esteja setado com FALSE(.F.)|��
��|            |          |                 |o sistema n�o dever� verificar a filial de |��
��|            |          |                 |envio ao TAF.                              |��
��|Cec�lia Carv|08/01/2018|DRHESOCP-2682    |Ajuste para gera��o de contrato intermiten-|��
��|            |          |                 |te - evento S-2200.                        |��
��|Cec�lia Carv|15/02/2018|DRHESOCP-2493    |Implementa��o do campo RBW_LOCT para gerar |��
��|            |          |                 |dados na tag <localTrabDom> - eventos      |��
��|            |          |                 |S-2200/2206.                               |��
��|Cec�lia Carv|03/05/2018|DRHESOCP-4497    |Ajuste para permitir efetuar manuten��o com|��
��|            |          |                 |par�mmetro MV_RHTAF desabilitado.          |��
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/

Function GPEA927()

Local oMBrowse
Local cFiltraRh  := ""
Local cTrabVincu := fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|304|306" //Trabalhador com vinculo

If lIntTAF .And. FindFunction("fVersEsoc") .And. FindFunction("ESocMsgVer")
	fVersEsoc("S2200", .F.,,, @cVersEnvio, @cVerGPE)			
	If !lMiddleware .And. cVerGPE <> cVersEnvio .And. (cVerGPE >= "9.0" .Or. cVersEnvio >= "9.0")
		If ESocMsgVer(.F., /*cEvento*/, cVerGPE, cVersEnvio)
			lIntTaf := .F.
		Else
			Return ()
		EndIf
	EndIf
EndIf
    
oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("SRA")
oMBrowse:SetDescription(OemToAnsi(STR0002)) //Tempor�rios

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//�������������������������������������������������������������������������
cFiltraRH	:= ChkRh( "GPEA927" , "SRA" , "1" )
If IsInCallStack("GPEA927")	
	cFiltraRH += If(!Empty(cFiltraRH)," .AND. ", " ")
	cFiltraRh += "RA_TPCONTR == '2'"
	cFiltraRh += " .AND. RA_CATEFD $ '" + cTrabVincu + "'"
	cFiltraRh += " .AND. (Empty(RA_DEMISSA) .OR. DToC(RA_DEMISSA) >= '" + DToC(dDataBase) + "')"		
EndIf

oMBrowse:SetFilterDefault(cFiltraRh)
oMBrowse:SetLocate()
GpLegMVC(@oMBrowse)

oMBrowse:ExecuteFilter(.T.)

oMBrowse:Activate()

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MenuDef     � Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Menu Funcional                                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA927'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA927'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0007)  Action 'VIEWDEF.GPEA927'	OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelo de dados e Regras de Preenchimento para o Cadastro de  ���
���          �Funcionarios Temporarios (RBW)                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Static Function ModelDef()

Local oMdlRBW
Local bAvalCampo	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|"}
Local oStruSRA 	  	:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRBW 	  	:= FWFormStruct(1, 'RBW', /*bAvalCampo*/,/*lViewUsado*/)
Local bPosValid  	:= {|oMdlRBW| Gp927PosVal(oMdlRBW)}
Local bCommit		:= {|oMdlRBW| f927Comm(oMdlRBW)}
oMdlRBW := MPFormModel():New('GPEA927', /*bPreValid */, bPosValid, bCommit, /*bCancel*/)

oMdlRBW:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

oMdlRBW:AddGrid( 'RBWDETAIL', 'SRAMASTER', oStruRBW, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oMdlRBW:SetRelation('RBWDETAIL', {{'RBW_FILIAL', 'xFilial("RBW",SRA->RA_FILIAL)'}, {'RBW_MAT', 'RA_MAT'}}, RBW->(IndexKey(1)))
oMdlRBW:GetModel('RBWDETAIL'):SetUniqueLine({'RBW_FILIAL','RBW_MAT'})
oMdlRBW:GetModel('RBWDETAIL'):SetMaxLine(1)

//Permite grid sem dados
oMdlRBW:GetModel('RBWDETAIL'):SetOptional(.T.)
oMdlRBW:GetModel('RBWDETAIL'):SetNoInsertLine(.T.)
oMdlRBW:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdlRBW:GetModel('SRAMASTER'):SetOnlyQuery(.T.)

// Adiciona a descricao do Modelo de Dados
oMdlRBW:SetDescription(OemToAnsi(STR0013))  //"Cadastro de Funcionarios Temporarios"

// Adiciona a descricao do Componente do Modelo de Dados
oMdlRBW:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0003)) // "Funcion�rios"
oMdlRBW:GetModel('RBWDETAIL'):SetDescription(OemToAnsi(STR0002)) // "Tempor�rios"

oMdlRBW:SetActivate( { |oModel| Gp927Init(oModel,oModel:GetOperation()) } )
oMdlRBW:SetVldActivate( { |oModel| Gp927VlMdl(oModel, oModel:GetOperation(), lIntTAF) } )

Return oMdlRBW

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizador de dados do Cadastro de Funcion�rios Tempor�rios���
���          � (RBW)                                                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Static Function ViewDef()

Local oView
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|"}
Local oModel   := FWLoadModel('GPEA927')
Local oStruSRA := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRBW := FWFormStruct(2, 'RBW')
Local bProrrog := {|| MsAguarde( { || Iif(Gp927VlMdl(oModel, oModel:GetOperation(), @lIntTAF), GPEA927A(4, lIntTAF), "")})}

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')
oStruSRA:SetNoFolder()

oView:AddGrid('VIEW_RBW', oStruRBW, 'RBWDETAIL')

oStruRBW:RemoveField("RBW_MAT")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 16)
oView:CreateHorizontalBox('INFERIOR', 84)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RBW', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0003)) // "Funcion�rio"
oView:EnableTitleView('VIEW_RBW', OemToAnsi(STR0002)) // "Tempor�rios"

oView:SetCloseOnOk({ || .T. })		//Desabilita bot�o "Salvar e Criar Novo"

If ( ExistFunc( 'fVersEsoc' ), fVersEsoc( "S2200", .F.,,,@cVerTrab,@cVerGPE),)

If Empty(cVerGPE)
	cVerGPE := cVerTrab
EndIf

If SR8->( ColumnPos("R8_TPPROC")) > 0 .And. cVerGPE > "2.2"
	oView:addUserButton(OemToAnsi(STR0021),"MAGIC_BMP", bProrrog, OemToAnsi(STR0021),, {/*MODEL_OPERATION_INSERT,*/MODEL_OPERATION_UPDATE} ) //"Prorroga��o Contrato"
Endif

Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Gp927Init  � Autor � Leandro Drumond       � Data � 24/09/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega matricula na grid.                                  s��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gp927Init(oMdl,nOperation)                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T.                                               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Gp927Init(oMdl,nOperation)

Local oGridRBW   := oMdl:GetModel('RBWDETAIL') 

If nOperation == MODEL_OPERATION_UPDATE
	oGridRBW:SetValue("RBW_MAT",SRA->RA_MAT)
EndIf

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Gp927VlMdl  � Autor � Claudinei Soares     � Data � 14/09/17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o do Model                                           ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gp927VlMdl(oMdl,nOperation)                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = lRet                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Gp927VlMdl(oMdl, nOperation, lIntTAF)

	Local lRet			:= .T.
    Local cVerTaf		:= StrTran(StrTran(SuperGetMv("MV_TAFVLES",, "2.4"), "_", "."), "0", "", 1, 2)

	Default nOperation	:= 0
	Default lIntTAF		:= .T.

    // RECEBE A VERS�O DO TAF.
    cVerTaf := StrTran(Iif(cVerTaf == "2.4.01", "2.4", cVerTaf), "S.1", "9")

	If lIntTAF
		If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE
			lRet := If (ExistFunc('fVersEsoc' ), fVersEsoc( "S2200", .F.,,, @cVerTrab, @cVerGPE), .T.)
			If lRet
				lRet := If (ExistFunc('fVersEsoc'), fVersEsoc( "S2100", .F.,,, @cVerTrab, @cVerGPE), lRet)
			Endif
		Endif
		
		If Empty(cVerTrab)
			cVerTrab := "2.2"
		Endif
		
		If Empty(cVerGPE)
			cVerGPE := cVerTrab
		EndIf

	EndIf

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp927PosVal � Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pos-validacao do Cadastro de Funcionarios Temporarios        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gp927PosVal( oMdlRFX )                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRFX = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function Gp927PosVal( oMdl )

Local aArea      := GetArea()
Local oMdl       := FWModelActive()
Local oGridRBW   := oMdl:GetModel('RBWDETAIL') 
Local nOperation := oMdl:GetOperation()
Local lRetorno   := .T.

If !oGridRBW:IsDeleted() .And. cVerTrab < "9.0.00" .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
	If Empty(oMdl:GetValue('RBWDETAIL','RBW_TPCONT'))
    	Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0033) + FWX3Titulo("RBW_TPCONT") + OemToAnsi(STR0034), 2 , 0 , , , , , , { OemToAnsi(STR0035) } ) 
    	lRetorno := .F.
    ElseIf Empty(oMdl:GetValue('RBWDETAIL','RBW_TPINSC'))
        Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0033) + FWX3Titulo("RBW_TPINSC") + OemToAnsi(STR0034), 2 , 0 , , , , , , { OemToAnsi(STR0035) } ) 
        lRetorno := .F.
    ElseIf Empty(oMdl:GetValue('RBWDETAIL','RBW_INSC'))
	    Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0033) + FWX3Titulo("RBW_INSC") + OemToAnsi(STR0034), 2 , 0 , , , , , , { OemToAnsi(STR0035) } )
        lRetorno := .F.
	EndIf
EndIf

RestArea(aArea)

Return lRetorno  
           
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � fGp927When � Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verificacao de When para Cadastro de Funcionarios Temporarios��� 
���          � Campo RBW_MATSUB e RBW_CPFSUB.                               ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp927When()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function fGp927When()

Local aSaveArea:= GetArea()
Local lRetorno := .F.

//Ativa campos se Motivo = 1
If FwFldGet("RBW_MOTIVO") == '1'
	lRetorno := .T.
EndIf 

RestArea(aSaveArea)

Return lRetorno 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � fGp927Valid� Autor � Alessandro Santos     � Data � 15/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes dos campos de Cadastro de Funcionarios Temporarios��� 
���          � Campo RBW_MATSUB e RBW_CPFSUB.                               ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp927Valid()                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function fGp927Valid(cCampo)

Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|309" //Trabalhador com vinculo
Local aSaveArea		:= GetArea()
Local lRetorno		:= .T.
Local cCPFs			:= ""
Local cCPF2 		:= ""
Local cCPF3			:= ""
Local cCPF4			:= ""
Local cCPF5			:= ""
Local cCPF6			:= ""
Local cCPF7 		:= ""
Local cCPF8			:= ""
Local cCPF9			:= ""
Local aCPFs			:= {}
Local cCMP1			:= ""
Local oMdl   		:= FwModelActive()
Local nC			:= 0

oMdl:Activate()

cCPFS 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPFSUB')
cCPF2 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF2')
cCPF3 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF3')
cCPF4 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF4')
cCPF5 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF5')
cCPF6 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF6')
cCPF7 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF7')
cCPF8 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF8')
cCPF9 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_CPF9')

aCPFs := {cCPFS,cCPF2,cCPF3,cCPF4,cCPF5,cCPF6,cCPF7,cCPF8,cCPF9}

cCMP1 := Substr(cCampo,8,1)

If cCMP1 == "S"
	cCMP1 := "1"
Endif

If FwFldGet("RBW_MOTIVO") == "1"   //Validacoes para Motivo == 1	
	//Validacoes do campo RBW_MATSUB 
	If !NaoVazio() .And. cCampo == 'RBW_CPFSUB'  
		lRetorno := .F.
    EndIf			
Else
	If !Empty(FwFldGet(cCampo))
		Help( ,, 'Help',, OemtoAnsi(STR0009), 1, 0 ) //"Campo deve ser vazio para essa motivo"				
		lRetorno := .F.
	EndIf 
EndIf 

If lRetorno
	For nC := 1 To LEN(aCPFs)
		If !Empty(aCPFs[nC]) .And. cCMP1 <> AllTrim(STR(nC)) .And. !Empty(AllTrim(FwFldGet(cCampo)))
			If ( aScan( aCPFs , { |x| x == AllTrim(FwFldGet(cCampo)) } ) <> VAL(cCMP1) )
				lRetorno := .F.
				Help( ,, 'Help',, OemtoAnsi(STR0023), 1, 0 ) //"O CPF do substitu�do n�o pode se repetir."	
			Endif			
		Endif
	Next nC
Endif

RestArea(aSaveArea)

Return lRetorno

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � f927Comm      � Autor � Glaucia Messina  � Data �05/07/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o para integracao TAF evento S-2200                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEA927                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function f927Comm(oModel)
Local lRet	   		:= .T.
Local cStatus  		:= " "
Local cStat1   		:= " "
Local cCPFCun  		:= " "
Local cCPF	   		:= ""
Local cCateg   		:= ""
Local cMsgLog       := ""
Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|309" //Trabalhador com vinculo
Local cFilEnv		:= ""
Local nCont			:= 1
Local aFilInTaf 	:= {}
Local aArrayFil 	:= {}
Local aErros		:= {}

Local aInfoC		:= {}
Local cChaveMid		:= ""
Local cNrInsc		:= ""
Local cTpInsc		:= ""
Local lAdmPubl		:= .F.
Local lEnvia		:= .T.
Local lS2206		:= .T.

cCateg	:= SRA->RA_CATEFD
cCPF    := AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)

If cVerTrab >= "9.0.00" 
	lS2206 	:= .F. 
	If oModel:GetOperation() == 4
		lEnvia	:= fCpoAlt(oModel, SRA->RA_FILIAL + SRA->RA_MAT, @lS2206)
	EndIf
EndIf

If (lIntTAF .Or. lMiddleware) .AND. !(EMPTY(cCPF)) .AND. !(EMPTY(cCateg)) .And. FUNNAME() <> "GPEM035" .And. (cVerTrab < "9.0.00" .Or. (cVerTrab >= "9.0.00" .And. lEnvia))
	If Type('cVerTrab') == "U"
		If ( ExistFunc( 'fVersEsoc' ), fVersEsoc( "S2100", .F.,,,@cVerTrab),cVerTrab:= "2.2")
	Endif 

	If !lMiddleware
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
	EndIf

	RegToMemory("SRA")
	If Empty(SRA->RA_CODUNIC)
		MsgAlert(OemToAnsi(STR0017)) //Funcionario sem codigo unico gerado. Acessar o Cad. Funcionario ou Realizar Carga Inicial
		lRet := .F.
	Else	
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf
		If cCateg $ cTrabVincu 
			cCPFCun		:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
			If !lMiddleware
				cStatus 	:= TAFGetStat( "S-2200", cCPFCun, cEmpAnt, cFilEnv )
				cStat1 		:= TAFGetStat( "S-2100", cCPFCun, cEmpAnt, cFilEnv )
			Else
				cStat1	:= "-1"
				cStatus := "-1"
				fPosFil( cEmpAnt, SRA->RA_FILIAL )
				aInfoC   := fXMLInfos()
				If LEN(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
				cStatus 	:= "-1"			
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatus )
			EndIf
			If cVerTrab < "2.3" .And. cStat1 <> "-1" // O REGISTRO 2100 foi emitido, sendo assim vamos gerar um retificador   
				lRet:= fIntAdmiss("SRA",,,"S2100",,,,oModel,,aErros,cVerTrab)
			Else
				If cStatus  $ " |-1|0|1|3"   //N�o existe no TAF ou existe e ainda n�o foi transmitido
					lRet:= fIntAdmiss("SRA", Nil, oModel:GetOperation(), Nil, Nil, Nil, Nil, oModel, Nil, @aErros, cVerTrab)
				ElseIf cStatus == "4"
					If !lS2206
						lRet := fIntAdmiss("SRA", Nil, oModel:GetOperation(), "S2200", Nil, Nil, Nil, oModel, Nil, @aErros, cVerTrab, )
					Else
   				   		lRet := fInt2206("SRA", , 4,"S2206",,,,,,oModel, cVerTrab) 
					EndIf
				Else //cStatus == "2"
					If !lMiddleware
						oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0018)) //Em transito
					Else
						oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0026)) //"Registro de admiss�o do funcion�rio em tr�nsito ao RET. A altera��o n�o ser� efetivada."
					EndIf
					lRet := .F.
				Endif
			Endif	
		Endif
	Endif	
	
	If lRet .And. FindFunction("fEFDMsg")
		fEFDMsg()
	ElseIf Len(aErros) > 0
	   For nCont:= 1 to len(aErros)
	       If aErros[nCont] == "TPJORN"
	          cMsgLog+= CRLF + STR0025 //"O Tipo de Jornada n�o foi localizado, favor verificar o cadastro do funcion�rio para que o mesmo seja integrado corretamente." 
	       Else
	          cMsgLog+= CRLF + aErros[nCont]
	       EndIf
	   Next 
	EndIf
EndIf

If !Empty(cMsglog)
    oModel:SetErrorMessage("",,oModel:GetId(),"","",cMsgLog)
EndIf
If lRet
	FWFormCommit(oModel)
Endif

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � fGp927Tom� Autor � Claudinei Soares      � Data � 23/08/2017 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se o CPNJ informado no campo RBW_INSCT pertence a Raiz��� 
���          � do CNPJ do Campo RBW_INSC.                                   ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp927Tom()                                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cTpInsc   = Tipo de Inscri��o, campo RBW_TPINSC              ���
���          � cInsc     = N�mero da Inscri��o, campo RBW_INSC              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function fGp927Tom()

Local cTp 		:= ""
Local cIns 	:= ""
Local cTpT		:= ""
Local cInsT	:= ""
Local cCNPJ	:= ""
Local cCNPJT	:= ""
Local lRet 	:= .T.
Local oMdl   	:= FwModelActive()

oMdl:Activate()

cTp 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_TPINSC')
cIns 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_INSC')
cTpT 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_TPINST')
cInsT 	:= oMdl:GetModel('RBWDETAIL'):GetValue('RBW_INSCT')

If cTp == cTpT .And. cTp == "1"
	cCNPJ	:= Left(cIns,8)
	cCNPJT	:= Left(cInsT,8)
	
	If Alltrim(cIns) == Alltrim(cInsT)
		lRet := .F.
		Help( ,, 'Help',, OemtoAnsi(STR0019)+ CRLF + OemtoAnsi(STR0020), 1, 0 ) //"Ao Preencher o campo Insc.Tomador ele deve pertencer a raiz do CNPJ do campo Nr.Inscri��o" // "Caso os CNPJ's sejam iguais n�o � necess�rio preencher o campo Insc. Tomador."
	ElseIf cCNPJ == cCNPJT
		lRet := .T.
	Else
		lRet := .F.
		Help( ,, 'Help',, OemtoAnsi(STR0019)+ CRLF + OemtoAnsi(STR0020), 1, 0 ) //"Ao Preencher o campo Insc.Tomador ele deve pertencer a raiz do CNPJ do campo Nr.Inscri��o" // "Caso os CNPJ's sejam iguais n�o � necess�rio preencher o campo Insc. Tomador."
	Endif
Endif

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � GpeSocWhen � Autor � Claudinei Soares      � Data � 11/09/17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verificacao de When para Cadastro de Funcionarios Temporarios��� 
���          �                                                              ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GpeSocWhen()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function GpeSocWhen()

Local aSaveArea:= GetArea()
Local lRetorno := .T.

RestArea(aSaveArea)

Return lRetorno 


/*/{Protheus.doc} fCpoAlt
Verifica se os campos de envio do evento para a vers�o S-1.0 foram alterados 
@since	28/01/2020
@autor	lidio.oliveira
@version 12
/*/
Static Function fCpoAlt(oModel, cChave, lS2206)

Local oMdlRBW	:= oModel:GetModel("RBWDETAIL")
Local lAlterou  := .F.	
Local aArea		:= GetArea()
Local aAreaRBW	:= RBW->(GetArea())
Local bCond     := {|x|(  RBW->RBW_LOCT <> oMdlRBW:GetValue("RBW_LOCT") )}//Campos que se alterados geram o evento S2206
Local bCondRet	:= {|x|(  RBW->RBW_MOTIVO <> oMdlRBW:GetValue("RBW_MOTIVO") ) .Or.; //Campos que se alterados geram o evento S2200
( RBW->RBW_CPFSUB <> oMdlRBW:GetValue("RBW_CPFSUB") )  .Or.;
( RBW->RBW_JUST <> oMdlRBW:GetValue("RBW_JUST") ) .Or.;
( RBW->RBW_TPINST <> oMdlRBW:GetValue("RBW_TPINST") ) .Or.;
( RBW->RBW_INSCT <> oMdlRBW:GetValue("RBW_INSCT ") ) .Or.;
( RBW->RBW_CPF2 <> oMdlRBW:GetValue("RBW_CPF2") ) .Or.;
( RBW->RBW_CPF3 <> oMdlRBW:GetValue("RBW_CPF3") ) .Or.;
( RBW->RBW_CPF4 <> oMdlRBW:GetValue("RBW_CPF4") ) .Or.;
( RBW->RBW_CPF5 <> oMdlRBW:GetValue("RBW_CPF5") ) .Or.;
( RBW->RBW_CPF6 <> oMdlRBW:GetValue("RBW_CPF6") ) .Or.;
( RBW->RBW_CPF7 <> oMdlRBW:GetValue("RBW_CPF7") ) .Or.;
( RBW->RBW_CPF8 <> oMdlRBW:GetValue("RBW_CPF8") ) .Or.;
( RBW->RBW_CPF9 <> oMdlRBW:GetValue("RBW_CPF9") )}

Default cChave	:= ""
Default lS2206	:= .F.

	If !Empty(cChave )
		dbSelectArea( "RBW" )
		//Pesquisa pelo registro, se n�o encontrou se trata de uma inclus�o
		If dbSeek(cChave ,.T.) 
			//Sempre que o registro estiver deletado haver� integra��o
			If oMdlRBW:IsDeleted()
				lAlterou := .T.
			//Executa o bloco de c�digo com as valida��es de retifica��o
			ElseIf Eval( bCondRet )
				lAlterou	:= .T.
			//Executa o bloco de c�digo com as valida��es das altera��es
			Elseif Eval( bCond )
				lAlterou	:= .T.
				lS2206		:= .T.
			Endif
		Else
			lAlterou := .T.
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaRBW)

Return lAlterou
