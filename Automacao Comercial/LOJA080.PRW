#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'LOJA080.CH'
#INCLUDE 'FWMVCDEF.CH'    
#INCLUDE "FWMBROWSE.CH"

/*���������������������������������������������������������������������������
���Programa  �LOJA080   �Autor  �Andre Alves Veiga   � Data �  28/05/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Identificacao de loja. Utilizado para configurar���
���          �as lojas para a consulta de estoque.                        ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
���������������������������������������������������������������������������*/
Function LOJA080

Local oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SLJ')
oBrowse:SetDescription(STR0001) // Identificacao de Lojas
oBrowse:Activate()

Return

/*���������������������������������������������������������������������������
���Fun��o    |MenuDef   � Autor �Vendas CRM             � Data �26/01/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � LOJA080                                                    ���
���������������������������������������������������������������������������*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003	ACTION "PesqBrw" 		 OPERATION 1 ACCESS 0 //"Pesquis	ar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.LOJA080" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005   	ACTION "VIEWDEF.LOJA080" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.LOJA080" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0007    ACTION "VIEWDEF.LOJA080" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina


/*���������������������������������������������������������������������������
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados (MVC)                              ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA080                                                     ���
���������������������������������������������������������������������������*/
Static Function ModelDef()

Local oStruSLJ := FWFormStruct( 1, 'SLJ')
Local bCommit  := { |oModel| Lj080Cmt( oModel ) } // Grava os dados e faz chamada para loja off line -> Lj080AltOk
Local oModel   := Nil

oModel := MPFormModel():New('LOJA080M',,, bCommit,)
oModel:AddFields( 'SLJMASTER',, oStruSLJ,,,)
oModel:GetModel( 'SLJMASTER' ):SetDescription( STR0001 )// Identificacao de Lojas

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de concorrentes em MVC.    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA080                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef() 

Local oModel   := FWLoadModel( 'LOJA080' )
Local oStruSLJ := FWFormStruct( 2, 'SLJ',)
Local oView    := Nil

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_SLJ', oStruSLJ, 'SLJMASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_SLJ', 'TELA' )

Return oView
                         
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Lj080Cmt  �Autor  �Vendas CRM          � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario.		  ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA080                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Lj080Cmt(oModel)
Local aArea		:= GetArea()
Local nOperation	:= oModel:GetOperation()
Local cCodigo	 	:= oModel:GetValue( 'SLJMASTER', 'LJ_CODIGO' ) 
Local lRet			:= .T.
local aLocais		:= {} //Locais de Estoque
Local nC			:= 0 //Vari�vel contadora
Local aNNRArea		:= {} //WorkArea de Armazens
Local cFilCad		:= oModel:GetValue( 'SLJMASTER', 'LJ_RPCFIL' ) 
Local lECCia 		:= !Empty(oModel:GetValue( 'SLJMASTER', 'LJ_ECFLAG' )) //Tratamento Integracao e-commerce CiaShop
Local cLocaisEC 	:= SuperGetMv("MV_LJECOMG", ,"")
Local cLocal		:= oModel:GetValue( 'SLJMASTER', 'LJ_LOCAL' ) 
Local cEmpCad		:= oModel:GetValue( 'SLJMASTER', 'LJ_RPCEMP' )
     
     
//Verifica se existe a empresa/Filial cadastrado
If (lECCia .OR. !Empty(oModel:GetValue( 'SLJMASTER', 'LJ_TOKEN' ))) .AND.  !(lRet := FWFilExist( cEmpCad, cFilCad))
	MsgAlert(STR0015  + cEmpCad + "/"+cFilCad + STR0016) //"Empresa/Filial ["##+"] n�o cadastrado"
EndIf
     
If lRet .and. lECCia 

	If cEmpCad <> cEmpAnt
		MsgAlert(STR0010) //"Para lojas e-commerce, a empresa deve ser igual � empresa de cadastro"
		 lRet := .F.
	EndIf
	If lRet .AND.  Empty(cLocal)
		If !Empty(cLocaisEC)
			If !MsgYesNo(STR0011)//"Deseja incluir como local de estoque os armaz�ns configurados no e-commerce?"
				 lRet := .F.
			Else
				oModel:GetModel('SLJMASTER'):SetValue("LJ_LOCAL",cLocaisEC)
			EndIf
		Else
			MsgAlert(STR0012)//"Incluir locais de estoque para loja e-commerce"
			 lRet := .F.
		EndIf
	EndIf
	
	If lRet
		//Verifica se os armaz�ns est�o cadastrados para a filial informada
		
		aLocais		:= StrTokArr ( StrTran(oModel:GetValue( 'SLJMASTER', 'LJ_LOCAL' ) , " ", ""), ",") //Locais de Estoque
		
		aNNRArea := NNR->(GetArea())
		NNR->(DbSetOrder(1)) //NNR_FILIAL + NNR_CODIGO
	
		For nC := 1 to Len(aLocais)
			lRet := NNR->(DbSeek(xFilial("NNR", cFilCad) + aLocais[nC]))
			If !lRet
				MsgAlert(STR0013 + aLocais[nC] + STR0014)//"N�o existe local de estoque ["##"] cadastrado para a filial"
				Exit
			EndIf
		Next
		
		If nOperation == MODEL_OPERATION_UPDATE 
			oModel:GetModel('SLJMASTER'):SetValue("LJ_ECDTEX"," ")
		EndIf
	
	EndIf
	
EndIf

//Grava os dados
If lRet
	lRet := FWFormCommit(oModel) 
EndIf

If lRet
	//Chamada processo loja off line
	Lj080AltOk("021","SLJ",cCodigo,1)
EndIf

RestArea( aArea )

Return lRet   


/*���������������������������������������������������������������������������
���Programa  �Lj080Local�Autor  �Andre Alves Veiga   � Data �  29/05/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Faz a validacao do campo de Local (almoxarifado)            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Sintaxe   �Lj080Local( cLocal[, nOperacao] )                           ���
�������������������������������������������������������������������������͹��
���          �[1] - String contendo os locais (almoxarifados) no formato: ���
���          �      01,02,03 --> Aqui foram escolhidos os almox. 01, 02   ���
���          �                   e 03                                     ���
���          �      01-03,05 --> Aqui foram escolhidos os almox. 01, 02,  ���
���          �                   03 e 05                                  ���
���          �[2] - nOperacao (1)-Valida o campo | Retorno .T. ou .F.     ���
���          �                (2)-Retorna um array com os estoques        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
���������������������������������������������������������������������������*/
Function Lj080Local( cLocal, nOperacao )
Local xRetorno
Local i, nX 
Local cLocalDe := ""
Local cLocalAte := ""
Local lRet := .T. 

Default nOperacao := 1

//�����������������������������������������������������������
//�Faz a validacao do campo                                 �
//�����������������������������������������������������������
cLocal := Alltrim(cLocal)
If nOperacao == 1
	xRetorno := lRet
Else
	//�����������������������������������������������������������Ŀ
	//�Retorna a array com os locais escolhidos                   �
	//�������������������������������������������������������������
	xRetorno := {}
	For i:=1 to Len(cLocal)
		If Subst(cLocal,i,1) == '-'
			cLocalAte := Subst(cLocal,i+1,2)
			For nX := Val(cLocalDe) to Val(cLocalAte)
				aAdd(xRetorno,StrZero(nX,2,0))
			Next nX
			cLocalDe := ""
			cLocalAte := ""
			i := i+3
		ElseIf Subst(cLocal,i,1) == ','
			aAdd(xRetorno,cLocalDe)
			cLocalDe := ""
		Else
			cLocalDe += Subst(cLocal,i,1)
		Endif
	Next i
	If !Empty(cLocalDe)
		aAdd(xRetorno,cLocalDe)
	Endif
	
Endif

Return xRetorno

/*���������������������������������������������������������������������������
���Funcao    �Lj080AltOk� Autor � IP-Vendas 			� Data � 12/04/10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Define a operacao que sera realizada na tabela de 	      ���
���			 � integracao de acordo com o processo de replicacao executado���
�������������������������������������������������������������������������Ĵ��
���Uso       � Registros utilizados na integracao Off-line                ���
���������������������������������������������������������������������������*/
Function Lj080AltOk( cProcess, cTabela, cChave, nOrdem, cTipo)
		
Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
Local lAmbOffLn		:= .F.	        
		
lAmbOffLn	 		:= SuperGetMv("MV_LJOFFLN", Nil, .F.)	//Identifica se o ambiente esta operando em offline		

//Verifica se o ambiente esta em off-line
If lAmbOffLn
	//Instancia o objeto LJCProcessoOffLine
	oProcessOff := LJCProcessoOffLine():New(cProcess)
	
	//Determina o tipo de operacao 
	If Empty(cTipo)
		If INCLUI
			cTipo := "INSERT"
		ElseIf ALTERA
			cTipo := "UPDATE"
		Else
			cTipo := "DELETE"				
		EndIf
	Endif    
	
	If cTipo = "DELETE"				
		//Considera os registros deletados
		SET DELETED OFF
	EndIf
		    
	If !Empty(cTipo)
		//Insere os dados do processo (registro da tabela)
		oProcessOff:Inserir(cTabela, xFilial(cTabela) + cChave, nOrdem, cTipo)	
			
		//Processa os dados 
		oProcessOff:Processar()	
	EndIf
	
	//Desconsidera os registros deletados
	SET DELETED ON
EndIf
	
Return Nil
/*                         
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Lj080EcLoc � Autor � IP-Vendas 			� Data � 07/12/16 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Condi��o de Atualiza��o do Gatilho do Local de Estoque   ���
���			 �  														  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Loja080													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj080EcLoc()
Local lRet

lRet := !Empty(M->LJ_ECFLAG) .And. Empty(M->LJ_LOCAL)

Return lRet
