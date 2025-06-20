#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA926.CH'

Static cEFDAviso
Static cVersEnvio	:= ""
Static cVersGPE		:= ""
//Integra��o com o TAF
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static lRfzTpInsc
Static cVerTaf		:= StrTran(StrTran(SuperGetMv("MV_TAFVLES",, "2.4"), "_", "."), "0", "", 1, 2)
/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA926  � Autor � Emerson Campos                    � Data � 05/09/2013 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Sucess�o de V�nculos (RFZ)                  					���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA926()                                                                ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                     ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � Chamado/FNC    �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���Raquel Hager�08/07/2014�TPZTOA	  	   �Inclusao de fonte na versao 12(datat fonte  ���
���            �          �         	   �versao 11 - 01/06/2014)					    ���
���Raquel Hager�05/09/2014�TQLPQN	  	   �Correcao para validacao do grid - fGP926Edit���
���Sidney O.   �19/09/2014�TQOHEZ	  	   �Ajuste na valida��o do CNPJ                 ���
���            �          �                �Ajuste na valida��o fTpAdmVld para receber  ���
���            �          �                �um parametro de tipo de admiss�o            ���
���Christiane V�02/07/2015� TSMUY2         �Adapta��es para vers�o 2.0 do eSocial       ���
���Raquel Hager�24/08/2016�TVTOQD          �Remo��o do uso do par�metro MV_INTTAF para  ���
���            �          �                �release 12.1.7.							       ���
���Marcia Moura�27/04/2017�DRHESOCP-38    �Remo��o do uso do par�metro MV_INTTAF para   ���
���Cecilia C.  �03/11/2017�DRHESOCP-1608  �Inclus�o de fun��o Gp926When().              ���
���Cecilia C.  �14/11/2017�DRHESOCP-1900    �Ajuste para permitir manuten��o da sucess�o���
���            �          �                 �de v�nculo em funcion�rio ainda n�o integra���
���            �          �                 �do com TAF.                                ���
���Cec�lia Carv�08/01/2018�DRHESOCP-2682   �Ajuste para gera��o de contrato intermitente���
���            �          �                � - evento S-2200.                           ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/

Function GPEA926 (xAutoCab,xAutoItens,nOpcAuto)
Local cFiltraRh
Local oBrwSRA
Local xRetFilRh
Local cFil
Local cMat
Local oModelAuto
Local lRet			:= .T.
Private cCpf		:= ""
Private cCateg		:= ""

Private lGp926Auto  :=(xAutoCab<>NIl)
Private aAutoCab	:= {}
Private aAutoItens  := {}
Private lNewVerEsoc := .F.

// RECEBE A VERS�O DO TAF.
cVerTaf:= StrTran(Iif(cVerTaf == "2.4.01", "2.4", cVerTaf), "S.1", "9")
fVersEsoc("S1030", .F.,,, @cVersEnvio, @cVersGPE)
If lIntTaf .And. FindFunction("fVersEsoc") .And. FindFunction("ESocMsgVer")
	If !lMiddleware .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
        //# "Aten��o! # A vers�o do leiaute GPE � XXX e a do TAF � XXXX, sendo assim, est�o divergentes. A rotina ser� encerrada"
		ESocMsgVer(.T.,/*cEvento*/, cVersGPE, cVersEnvio)
		Return ()
	EndIf
EndIf

cEFDAviso	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas

/*
��������������������������������������������������������������Ŀ
� Carregando Filtro de BROWSE                                  �
����������������������������������������������������������������*/
//--Seta e Carrega os Mnemonicos.
SetMnemonicos(NIL,NIL,.T.)
	
If !lGp926Auto
	oBrwSRA := FWmBrowse():New()		
	oBrwSRA:SetAlias( 'SRA' )
	oBrwSRA:SetDescription(STR0001)	//"Cadastro de Sucess�o de V�nculos"
	
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH==' '"	, "GREEN"	, OemToAnsi(STR0002)  )//"Situa��o Normal"  
	oBrwSRA:AddLegend( "SRA->RA_RESCRAI$'30/31'", "PINK"  	, OemToAnsi(STR0003)  )//"Transferido" 
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='D'"	, "RED"		, OemToAnsi(STR0004)  )//"Demitido"
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='A'"	, "YELLOW"  , OemToAnsi(STR0005)  )//"Afastado"
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='F'"	, "BLUE"	, OemToAnsi(STR0006)  )//"F�rias"     
						
	//Inicializa o filtro utilizando a funcao FilBrowse
	xRetFilRh := CHKRH(FunName(),"SRA","1")
	If ValType(xRetFilRh) == "L"
		cFiltraRh := if(xRetFilRh,".T.",".F.")
	Else
		cFiltraRh := xRetFilRh
	EndIf
	//Filtro padrao do Browse conforme tabela SRA (Funcion�rios)
	oBrwSRA:SetFilterDefault(cFiltraRh)
	
	oBrwSRA:DisableDetails()	
	oBrwSRA:Activate()
Else
	dbSelectArea("SRA")
	aAutoCab	:= xAutoCab
	aAutoItens 	:= xAutoItens
	
	If (nT := aScan(aAutoCab,{|x| UPPER(Alltrim(x[1]))=='RA_FILIAL'})) > 0
		cFil := aAutoCab[nT,2]
	Else
		cFil := xFilial("SRA")
	EndIf
	If (nT := aScan(aAutoCab,{|x| UPPER(Alltrim(x[1]))=='RA_MAT'})) > 0
		cMat := aAutoCab[nT,2]
	EndIf
	
	dbSelectArea('SRA')
	dbSetOrder(1)
	If !dbSeek(cFil+cMat)
		AutoGRLog(STR0007+" "+ Alias()+" "+Dtoc(MsDate())+' '+Time() ) // "Tabela "
		AutoGrLog("RA_FILIAL: "+cFil)
		AutoGrLog("RA_MAT: "+cMat)
		AutoGRLog(STR0008) // "Pesquisa n�o encontrada com os dados acima"   
		AutoGRLog(Replicate("-",80))
		lRet := .F.
	EndIf

	If lRet
		aRotina := MenuDef()
		
		//Executa rotina automatica SEM Interface
		lRet := FWMVCRotAuto(ModelDef(),"SRA",nOpcAuto,{{"SRAMASTER",aAutoCab},{"RFZDETAIL",aAutoItens}},.F.,.T.)
	Endif			
Endif

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef    � Autor � Emerson Campos        � Data �05/09/2013���
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

ADD OPTION aRotina Title STR0009  Action 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0010  Action 'VIEWDEF.GPEA926'  OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0011  Action 'VIEWDEF.GPEA926' 	OPERATION 4 ACCESS 0 //"Alterar"
Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Emerson Campos        � Data �05/09/2013���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelo de dados e Regras de Preenchimento para o Cadastro de  ���
���          �Sucess�o de V�nculos do Funcionario (RFZ)                     ���
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
//Define os campos do SRA que ser�o apresentados na tela	
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|RA_ADMISSA|"}
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSRA 		:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRFZ 		:= FWFormStruct(1, 'RFZ', /*bAvalCampo*/,/*lViewUsado*/)
Local oMdlRFZ

// Blocos de codigo do modelo
Local bLinePos		:= {|| fGp926LinOk()}
Local bPosValid		:= {|| fGp926TdOk() }
Local bCommit		:= {|oMdlRFZ| f926Comm(oMdlRFZ)}
 
// Cria o objeto do Modelo de Dados
oMdlRFZ := MPFormModel():New('GPEA926', /*bPreValid*/ , bPosValid, bCommit, /*bCancel*/)

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oMdlRFZ:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oMdlRFZ:AddGrid( 'RFZDETAIL', 'SRAMASTER', oStruRFZ, /*bLinePre*/, bLinePos, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	
// Faz relaciomaneto entre os compomentes do model
oMdlRFZ:SetRelation('RFZDETAIL', {{'RFZ_FILIAL', 'xFilial("RFZ")'}, {'RFZ_MAT', 'RA_MAT'}}, RFZ->(IndexKey(1)))

//Define Chave �nica
oMdlRFZ:GetModel('RFZDETAIL'):SetUniqueLine({'RFZ_MAT', 'RFZ_TPADM'})

//Permite grid sem dados
oMdlRFZ:GetModel('RFZDETAIL'):SetOptional(.T.)

oMdlRFZ:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdlRFZ:GetModel('SRAMASTER'):SetOnlyQuery(.T.)


// Adiciona a descricao do Modelo de Dados
oMdlRFZ:SetDescription(OemToAnsi(STR0001))  // "Cadastro de Sucess�o de V�nculos"

// Adiciona a descricao do Componente do Modelo de Dados
oMdlRFZ:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0013)) // "Funcion�rios"
oMdlRFZ:GetModel('RFZDETAIL'):SetDescription(OemToAnsi(STR0014)) // "Sucess�o de V�nculos"

//N�o permitir serem inseridas linhas na grid.
//oMdlRFZ:GetModel( 'RFZDETAIL' ):SetNoInsertLine( .T. )

Return oMdlRFZ	
	
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Emerson Campos        � Data � 21/06/13 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizador de dados do Cadastro de Sucess�o de V�nculos do ���
���          � Funcionario (RFZ)                                            ���
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
//Define os campos do SRA que ser�o apresentados na tela	
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|RA_ADMISSA"}
//Define os campos do RFZ que n�o ser�o apresentados na tela	
Local bAvalRFZ 	    := Nil
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel        := FWLoadModel('GPEA926')
// Cria a estrutura a ser usada na View
Local oStruSRA      := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRFZ      := Nil

DEFAULT lRfzTpInsc	:= ChkFile("RFZ") .And. RFZ->(ColumnPos('RFZ_TPINSC')) > 0

If ( ExistFunc( 'fVersEsoc' ), fVersEsoc( "S2200", .F.,,,@cVersEnvio, @cVersGPE),)

If Empty(cVersGPE)
	cVersGPE := cVersEnvio
EndIf

If (cVersEnvio <= "2.5")
	bAvalRFZ := {|cCampo| !AllTrim(cCampo)+"|" $ "RFZ_PRCAD|"}
	oStruRFZ := FWFormStruct(2, 'RFZ', bAvalRFZ)
Else
	oStruRFZ := FWFormStruct(2, 'RFZ')
Endif

// Cria o objeto de View
oView := FWFormView():New()
 
// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')

oStruSRA:SetNoFolder()

// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RFZ', oStruRFZ, 'RFZDETAIL')

oStruRFZ:RemoveField("RFZ_MAT")
If lRfzTpInsc
	oStruRFZ:SetProperty("RFZ_TPINSC", MVC_VIEW_ORDEM, "06")
EndIf
 
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 12)
oView:CreateHorizontalBox('INFERIOR', 88)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RFZ', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0013)) // "Funcion�rio"
oView:EnableTitleView('VIEW_RFZ', OemToAnsi(STR0014)) // "Sucess�o de V�nculos"

// Desabilita botao 'Salvar e Criar'
oView:SetCloseOnOk({ || .T. }) 

cCPF	:= cCPF := AllTrim(SRA->RA_CIC) + ";" + AllTrim(SRA->RA_MAT)
cCateg	:= SRA->RA_CATEFD
Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �fGp926LinOk � Autor � Emerson Campos        � Data �05/09/2013���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pos-validacao da linha do Cadastro de Sucess�o de V�nculos   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp926LinOk( )                                      			���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRFZ = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function fGp926LinOk()
Local lRet   	:= .T. 
Local oModel    := FWModelActive()
Local oMdlRFZ 	:= oModel:GetModel( 'RFZDETAIL' )
Local NRFZLines	:= oMdlRFZ:Length()
Local nI         := 0
Local nDttraPOS  := 0

Private	aHeader	:= oMdlRFZ:AHEADER
nDttraPOS := GdFieldPos("RFZ_DTTRA")

If cEFDAviso <> "2"	
	For nI := 1 To nRFZLines	
		oMdlRFZ:GoLine( nI )		
		If !(oMdlRFZ:IsDeleted())
		    lRet := fTpAdmVld(oMdlRFZ:GetValue( 'RFZ_TPADM' )) //"O campo 'Tp.Admiss�o' � de preenchimento obrigat�rio!"
		    
		    If Empty(oMdlRFZ:GetValue( 'RFZ_INDADM' ))
		    	Help( , , 'HELP', , OemToAnsi( STR0030 +" "+ STR0032 +" "+ STR0031 ), 1, 0 )//"O campo 'Indic.Admiss' � de preenchimento obrigat�rio!"
				If cEFDAviso == "1"
					lRet := .F.
				EndIf
		    EndIf
		    
		    If Empty(oMdlRFZ:GetValue( 'RFZ_INDPEM' ))    	
		    	Help( , , 'HELP', , OemToAnsi( STR0030 +" "+ STR0033 +" "+ STR0031 ), 1, 0 )//"O campo 'Ind.Prim.Emp' � de preenchimento obrigat�rio!"
				If cEFDAviso == "1"
					lRet := .F.
				EndIf
		    EndIf 
		    
			If lRet
				IF ( lRet := SM0->( dbSeek( cEmpAnt + SRA->RA_FILIAL ) ) )
					If oMdlRFZ:GetValue( 'RFZ_TPADM' ) $ "2*3*4"
						 
						If SM0->M0_CGC == oMdlRFZ:GetValue( 'RFZ_CNPJAN' )
							Help( , , 'HELP', , OemToAnsi(STR0017), 1, 0 )//"O CNPJ informado deve ser diferente do CNPJ da filial de cadastro do participante."
							//-- Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
							If cEFDAviso == "1"
								lRet	:= .F.
							EndIf
						EndIf
						If lRet .AND. oMdlRFZ:GetValue( 'RFZ_CNPJAN' ) == "00000000000000"
							Help( , , 'HELP', , OemToAnsi(STR0036), 1, 0 )//"O CNPJ informado n�o � v�lido!"//-- Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
							If cEFDAviso == "1"
								lRet	:= .F.
							EndIf
						EndIf		
						If lRet
							//Valida se o CNPJ � v�lido
							lRet	:= CGC( oMdlRFZ:GetValue( 'RFZ_CNPJAN' ) )
							If cEFDAviso == "0" .AND. !lRet
								lRet	:= .T.	
							EndIf
						EndIf
					EndIf  	
				EndIf
			EndIf
		
		
			If oMdlRFZ:GetValue( 'RFZ_TPADM' ) $ "1*2*3*4"
				If oMdlRFZ:GetValue( 'RFZ_TPADM', nI ) <> "1" 			
					If Empty(oMdlRFZ:GetValue( 'RFZ_CNPJAN' )) .OR.;
						Empty(oMdlRFZ:GetValue( 'RFZ_MATANT' )) .OR.;
						Empty(oMdlRFZ:GetValue( 'RFZ_DTADAN' ))
					   	//"Se for selecionado as op��es 2 ou 3 em Tp.Admiss�o, os campos 'CNPJ Empresa', 'Mat. Anterior' e 'Dt.Admiss�o' s�o de preenchimento obrigat�rio!"  	 
						Help( , , 'HELP', , OemToAnsi( STR0041 ), 1, 0 )  
						lRet := .F.
					EndIf
				EndIf
			EndIf

			If lRet .And. RFZ->(ColumnPos("RFZ_PRCAD")) > 0 .And. !Empty(oMdlRFZ:GetValue('RFZ_PRCAD')) .And. oMdlRFZ:GetValue('RFZ_INDADM') <> "3"
				Help(,, 'PRCAD',, + CRLF + OemToAnsi(STR0049) + AllTrim(TITSX3("RFZ_PRCAD")[1]) + OemToAnsi(STR0050) + AllTrim(TITSX3("RFZ_INDADM")[1]) + OemToAnsi(STR0051), 1, 0 ) // "Campo: "##" s� deve ser preenchido quando "##" for igual a 3."
				lRet := .F.
			EndIf

			If nDttraPOS > 0 .And. cVersGPE >= "2.4"
				If oMdlRFZ:GetValue( 'RFZ_TPADM' ) <> "1"
					If Empty(oMdlRFZ:GetValue( 'RFZ_DTTRA' ))
						Help( ' ' , 1 , "HELP" , , OemToAnsi(STR0044) , 1 , 0 )
						lRet:= .F.
					EndIf
				EndIf				
			EndIf
			
		EndIf
	Next nI
EndIf
Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �fGp926TdOk  � Autor � Emerson Campos        � Data �05/09/2013���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pos-validacao do modelo relativo ao Cad Sucess�o de V�nculos ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGp926TdOk( )                             			        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRFZ = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function fGp926TdOk()
Return fGp926LinOk()

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �fTpDepBox() � Autor � Emerson Campos        � Data � 30/07/13 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Tipo de dependente                                            ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �fTpDepBox()		                                            ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Function fTpAdmBox()
Local cTitulo           := OemToAnsi(STR0021) // "Tp.Admiss�o" 
Local MvPar             := &(ReadVar())
Local MvParDef          := "" 
Local MvStrRet          := ""
Local lRet              := .T. 
Local l1Elem            := .F.  
Local nGrupo            := 0
Local aArea             := GetArea()

Private aOcor := {}

VAR_IXB := MvPar

aOcor := {;			
			OemToAnsi(STR0022),;		//"1=Admiss�o;" 
			OemToAnsi(STR0023),;		//"2=Transfer�ncia de empresa do mesmo grupo econ�mico;" 
			OemToAnsi(STR0039),;		//"3=Transfer�ncia da empresa consorciada ou de cons�rcio"
			OemToAnsi(STR0040),;		//"4=Transfer�ncia por motivo de sucess�o, incorpora��o, cis�o ou fus�o"
			OemToAnsi(STR0058) ;		//"7=Transfer�ncia quando a empresa sucedida � considerada inapta por inexist�ncia de fato" 
	          } 

MvParDef := "12347"
	
If f_Opcoes(@MvPar,cTitulo,aOcor,MvParDef,,,l1Elem,1)
      For nGrupo := 1 To Len(MvPar)
            If (SubStr(MvPar, nGrupo, 1) # "*")
                  MvStrRet += SubStr(mvpar, nGrupo, 1)
            Else
                  MvStrRet += Space(1)
            Endif
      Next nGrupo
      VAR_IXB := AllTrim(MvStrRet)
EndIf

RestArea(aArea)
Return(lRet) 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fTpAdmVld()   � Autor � Emerson Campos   � Data �05/09/2013���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de validacao do campo RFZ_TPADM (Tp. Admiss�o       ���
���Descricao � Trabalhador)                                     	      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Geral                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function fTpAdmVld(cTpAdm)
Local lRet 		:= .T. 
Local oModel    := FWModelActive()
Local oMdlRFZ 	:= oModel:GetModel( 'RFZDETAIL' )

Default cTpAdm := M->RFZ_TPADM

If !cTpAdm $ "1*2*3*4*7"
	Help( , , 'HELP', , OemToAnsi(STR0026), 1, 0 )//"Selecione um tipo de admiss�o v�lido!" 
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao   �fGP926CNPJ �Autor  �Emerson Campos      � Data �  05/09/2013 ���
�������������������������������������������������������������������������͹��
���Desc.    � Verifica se o campo CNPJ � um CNPJ v�lido no territ�rio     ���
���         �nacional e dever� ser diferente do CNPJ do cendente, ou seja,���
���         �da filial a qual o funcion�rio est� associado.               ���
�������������������������������������������������������������������������͹��
���Uso      � GPEA926                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fGP926CNPJ()
Local lRet	    := .T.
Local lInsc	    := .F.
Local aArea	 	:= GetArea()
Local aAreaSM0 	:= SM0->( GetArea() )
Local cCNPJ    	:= ""
Local oModel    := FWModelActive()
Local oMdlRFZ 	:= oModel:GetModel( 'RFZDETAIL' )
Local nLine		:= oMdlRFZ:GetLine()

DEFAULT lRfzTpInsc	:= ChkFile("RFZ") .And. RFZ->(ColumnPos('RFZ_TPINSC')) > 0

/*
������������������������������������������������������������Ŀ
�Obtem o CGC da Empresa de Origem							 �
��������������������������������������������������������������*/
IF ( lRet := SM0->( dbSeek( cEmpAnt + SRA->RA_FILIAL ) ) .Or. IsBlind())
	If ReadVar() == "M->RFZ_CNPJAN"	
		cCNPJ := M->RFZ_CNPJAN
		lInsc := .T.
	ElseIf ReadVar() == "M->RFZ_CNPJCE"
		cCNPJ := M->RFZ_CNPJCE
	EndIf
	
	If !Empty(cCNPJ)
		If SM0->M0_CGC == cCNPJ
			Help( , , 'HELP', , OemToAnsi(STR0017), 1, 0 ) //"O n�mero de inscri��o informado deve ser diferente do n�mero de inscri��o da filial de cadastro do participante."
			lRet	:= .F.
		Else
			If cCNPJ == "00000000000000"
				lRet := .F.
			ElseIf !lRfzTpInsc .Or. Empty(oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine )) 
				If Len( Alltrim(cCNPJ) ) <> 11
					lRet := CGC(cCNPJ)
					If !lRet
						Help( , , 'HELP', , OemToAnsi(STR0036), 1, 0 ) //"O n�mero de inscri��o informado n�o � v�lido!"
					EndIf	
				Else
					lRet := ChkCPF(cCNPJ)
				EndIf	
			ElseIf lRfzTpInsc .And. lInsc .and. !Empty(oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine )) .And. oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine ) $ "1/2"
				If oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine ) == "2" .And. (!ChkCPF( cCNPJ ) .Or. Len( Alltrim(cCNPJ) ) != 11)
					lRet := .F.
				ElseIf oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine ) == "1" .And. (!CGC( cCNPJ ) .Or. Len( Alltrim(cCNPJ) ) != 14)
					lRet := .F.
					Help( , , 'HELP', , OemToAnsi(STR0036), 1, 0 ) //"O n�mero de inscri��o informado n�o � v�lido!"
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

/*
������������������������������������������������������������Ŀ
�Restaura os Dados de Entrada								 �
��������������������������������������������������������������*/
RestArea( aAreaSM0 )
RestArea( aArea )

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao   �fGP926Edit �Autor  �Emerson Campos      � Data �  20/08/2013 ���
�������������������������������������������������������������������������͹��
���Desc.    � When dos campos relativo ao eSocial					      ���
�������������������������������������������������������������������������͹��
���Uso      � GPEA926                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fGP926Edit()
Local lRet 		:= .F.
Local oModelGrid	:= FwModelActive()
Local oModel  	:= oModelGrid:GetModel('RFZDETAIL')

If ReadVar() $ "M->RFZ_CATODS" 
	If (oModel:GetValue('RFZ_TPADM') == "4" .AND.  (SRA->RA_CATEFD == '401'))
		lRet := .T.
	EndIf
ElseIf oModel:GetValue('RFZ_TPADM') $ "1*2*3*4"
	lRet 		:= .T.
	If oModel:GetValue('RFZ_TPADM') == "1" .AND. ReadVar() $ "M->RFZ_CNPJAN*M->RFZ_MATANT*M->RFZ_DTADAN*M->RFZ_OBSVAN" 
		lRet := .F.
	ElseIf oModel:GetValue('RFZ_TPADM') $ "1*2*3" .AND. ReadVar() $ "M->RFZ_CNPJCE*M->RFZ_MATCED*M->RFZ_DTADCE*M->RFZ_ONUS" 
		lRet := .F.
	EndIf
EndIf

Return lRet 

/*/{Protheus.doc} fGP926Pict
Fun��o para mudar a picture de campos CPNJ/CPF
@type      	Function
@author   	Allyson Mesashi
@since		23/12/2019
@version	1.0
/*/
Function fGP926Pict()
	Local cPicRJ 	:=  "@R 99.999.999/9999-99"
	Local oModel    := FWModelActive()
	Local oMdlRFZ 	:= oModel:GetModel( 'RFZDETAIL' )
	Local nLine		:= oMdlRFZ:GetLine()

	If oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine ) == "2"//CPF
		cPicRJ := "@R 999.999.999-99"
	ElseIf !Empty(oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine )) .And. oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine ) != "1"//CNPJ
		cPicRJ := "@R 99999999999999"
	Endif

	cPicRJ := cPicRJ + "%C"

Return cPicRJ

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � RFXDATAIVL    � Autor � Emerson Campos   � Data �11/07/2013���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o para valida��o da data inicial da estabilidade      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Geral                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function fDtAdAnVld(nOpc)
Local lRet 		:= .T.
Local oModel 	:= FWModelActive()

If nOpc == 1 
	lRet := ChkValDt(oModel:GetValue( 'RFZDETAIL', 'RFZ_DTADAN'),SRA->RA_ADMISSA,">",STR0027+" "+dtoc(SRA->RA_ADMISSA),.T.)//"A data de �nicio do v�nculo trabalhista deve ser anterior a data de admiss�o do trabalhador. Funcion�rio admitido em:"
EndIf

If nOpc == 2 
	lRet := ChkValDt(oModel:GetValue( 'RFZDETAIL', 'RFZ_DTADCE'),SRA->RA_ADMISSA,">",STR0028+" "+dtoc(SRA->RA_ADMISSA),.T.)//"A data de admiss�o do trabalhador no empregador de origem(cedente) deve ser anterior a data de admiss�o do trabalhador. Funcion�rio admitido em:"
EndIf 
Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � f926Comm      � Autor � Glaucia Messina  � Data �05/07/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o para integracao TAF evento S-2200                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEA926                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function f926Comm(oModel)
Local aArea			:= GetArea()
Local lRet		    := .T.
Local cTipoAdm		:= 0
Local cStatus		:= ""
Local cStat1    	:= "" 
Local cCod			:= ""
Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|309" //Trabalhador com vinculo
Local cTSV			:= "410" // para envio de trabalhadores sem v�nculo somente se a categoria for 410
Local cFilEnv		:= ""
Local aFilInTaf 	:= {}
Local aArrayFil 	:= {}
Local oMdlRFZ		:= oModel:GetModel("RFZDETAIL")
Local aTpAlt	    := {.F., .F., .F., .F.}
Local aErros		:= {}
Local cMsgLog		:= ""
Local nCont			:= 0

Local aInfoC		:= {}
Local cChaveMid		:= ""
Local cNrInsc		:= ""
Local cTpInsc		:= ""
Local lAdmPubl		:= .F.
Local nIndice		:= 0

cCPF 	:= If( Type("cCPF") == "U"	, SRA->RA_CIC 	, cCPF)
cCateg	:= If( Type("cCateg") == "U", SRA->RA_CATEFD , cCateg)


If Type('cVersEnvio') == "U"
	If ( ExistFunc( 'fVersEsoc' ), fVersEsoc( "S2200", .F.,,,@cVersEnvio),cVersEnvio:= "2.2")
Endif 

If (lIntTAF .Or. lMiddleware) .AND. !(EMPTY(cCPF)) .AND. !(EMPTY(cCateg)) .And. FUNNAME() <> "GPEM035"

	IF !EMPTY(oMdlRFZ) .AND. ALLTRIM(oMdlRFZ:GetValue("RFZ_CATEG")) $ cTrabVincu .AND. !EMPTY(oMdlRFZ:GetValue("RFZ_ONUS"))
		Help( , , 'HELP', , OemToAnsi(STR0045), 1, 0 )
		oMdlRFZ:SetValue("RFZ_ONUS","")
	ENDIF

	If !lMiddleware
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
	EndIf
	RegToMemory("SRA")
	
	If cCateg $ cTrabVincu .And. Empty(SRA->RA_CODUNIC)
		MsgAlert(OemToAnsi(STR0042)) //Funcionario sem codigo unico gerado. Acessar o Cad. Funcionario ou Realizar Carga Inicial
		lRet := .F.
	Else	
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf	

		If cCateg <> cTSV 
			cCod 		:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
			nIndice		:= Retorder( "C9V" , "C9V_FILIAL+C9V_CPF+C9V_MATRIC+C9V_ATIVO") 
		Else
			cCod 		:= AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
			nIndice		:= Retorder( "C9V" , "C9V_FILIAL+C9V_CPF+C9V_CATCI+C9V_ATIVO" )
		EndIf

		If !lMiddleware
			cStatus := TAFGetStat( "S-2200", cCod, cEmpAnt, cFilEnv , nIndice)
		Else
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
		cStat1  := TAFGetStat( "S-2300", cCod, cEmpAnt, cFilEnv , nIndice)
	
		//Verifica o status dos registros
	   If( cStatus == "2" .and.  cStat1 <> "2" )
			If !lMiddleware
				oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0043)) //Em transito
			Else
				oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0047)) //"Registro de admiss�o do funcion�rio em tr�nsito ao RET. A altera��o n�o ser� efetivada."
			EndIf
			lRet := .F.
	   Else
		   fStatusTAF(@aTpAlt,cStatus,cStat1, FUNNAME())
	   EndIf	
	
		If lRet .And. ( cCateg $ cTrabVincu .Or.  cCateg == cTSV )
			If aTpAlt[1] .And. cCateg $ cTrabVincu
				lRet:= fIntAdmiss("SRA", Nil, oModel:GetOperation(), "S2200", Nil, Nil, Nil, oModel, Nil, @aErros, cVersEnvio, oMdlRFZ)
			ElseIf aTpAlt[2] .And. cCateg == cTSV
				lRet := fInt2300New("SRA",,,"S2300",,,cVersEnvio,,,,,oMdlRFZ)
			Else
				lRet := .F.
			Endif
		Endif
		If lRet .And. ExistFunc('fEFDMsg')
			fEFDMsg()
		ElseIf Len(aErros) > 0
			For nCont := 1 to Len(aErros)
				If aErros[nCont] == "TPJORN"
					cMsgLog += CRLF + STR0048//"O Tipo de Jornada n�o foi localizado, favor verificar o cadastro do funcion�rio para que o mesmo seja integrado corretamente." 
				Else
					cMsgLog += CRLF + aErros[nCont]
				EndIf
			Next
			oModel:SetErrorMessage("",,oModel:GetId(),"","",cMsgLog)
		EndIf		
	EndIf

	If lRet
		FWFormCommit(oModel)
	EndIf
Else
    FWFormCommit(oModel)	
Endif

RestArea(aArea)
Return lRet

/*/{Protheus.doc} Gp926When
Fun��o respons�vel por valida��o de when do campo RFZ_DTTRA
@type function
@author Cecilia C
@since 03/11/2017
@version 1.0
@return lRet, boolean, Retorno se libera a edi��o do campo
/*/
Function Gp926When()
Local oModelGrid	:= FwModelActive()
Local oModel  	:= oModelGrid:GetModel('RFZDETAIL')
Local lRet		:= .F. 

If (oModel:GetValue('RFZ_TPADM')) <> "1"
	lRet:= .T.
Endif

Return( lRet )
