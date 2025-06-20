#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CSAA010.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSAA010  � Autor � Cristina Ogura        � Data � 13.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro das Empresas Participantes                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSAA010                                                    ���
�������������������������������������������������������������������������Ĵ��
���     DATA � Programador  �BOPS   �Manutencao Efetuada                  ���
�������������������������������������������������������������������������Ĵ��
���07/07/2014� Cecilia Car. �TPZVTW �Incluido o fonte da 11 para a 12 e   ���
���          �              �       �efetuada a limpeza.                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CSAA010()
	Local oBrwRB0
	Local cFiltraRh

   	oBrwRB0:= FwmBrowse():New()
	oBrwRB0:SetAlias( 'RB0' )
	oBrwRB0:SetDescription( STR0008 ) 		//"Cadastro de Participantes da Pesquisa Salarial"
	
	cFiltraRh	:= CHKRH(FunName(),"RB0","1")
	oBrwRB0:SetFilterDefault(cFiltraRh)
	
	oBrwRB0:Activate() 

Return NIL

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MenuDef     � Autor � Glaucia C. Messina    � Data � 18/03/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Menu Funcional                                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Static Function MenuDef()
                                                                               	
	Local aRotina := {}  

	ADD OPTION aRotina TITLE STR0003	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0 	//"Pesquisar"
	ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.CSAA010'	OPERATION 2 ACCESS 0	//"Visualizar"
	ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.CSAA010'	OPERATION 3 ACCESS 0	//"Incluir"
	ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.CSAA010'	OPERATION 4 ACCESS 0	//"Alterar"
	ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.CSAA010'	OPERATION 5 ACCESS 0	//"Excluir"
	ADD OPTION aRotina TITLE STR0012	ACTION 'VIEWDEF.CSAA010'	OPERATION 9 ACCESS 0	//"Copiar"
	ADD OPTION aRotina TITLE STR0011	ACTION 'VIEWDEF.CSAA010'	OPERATION 8 ACCESS 0	//"Imprimir"

Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Glaucia C.Messina     � Data � 18/03/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelo de dados e Regras de Preenchimento para o Cadastro de  ���
���          �Empresas Participantes					                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Static Function ModelDef()

	Local oModel
	Local oStruRB0 	:= FWFormStruct( 1, 'RB0') 
    Local bPosValid	:= { |oModel| CS010PosVal( oModel ) } 

	oModel := MPFormModel():New('CSAA010', ,bPosValid) 
	oModel:AddFields( 'RB0MASTER',, oStruRB0)
	oModel:SetDescription( STR0008 )   							//"Cadastro de Participantes da Pesquisa Salarial"
	oModel:GetModel( 'RB0MASTER' ):SetDescription( STR0008 )	//"Cadastro de Participantes da Pesquisa Salarial"

	FWMemoVirtual(oStruRB0, {{'RB0_OBSERV','RB0_MEMO1'}})      
   	oModel:SetPrimaryKey( { 'RB0_EMPRES' } )   
   	 	
Return oModel

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Glaucia C. Messina    � Data � 18/03/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Visualizador de dados do Cadastro de Empresas Participantes   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'CSAA010' )
	Local oStruRB0 	:= FWFormStruct( 2, 'RB0' )
	Local oView   

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_RB0', oStruRB0, 'RB0MASTER' )  
	
Return oView    

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs150PosVal � Autor � Glaucia C. Messina    � Data � 18/03/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pos validacao do Formul�rio de Dados Empresas Participantes  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � CS010PosVal( oModel )                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oModel = objeto do modelo 									���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ModelDef()                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Static Function CS010PosVal( oModel )
	Local aArea			:= GetArea()
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T. 
	Local cEmpresa		:= Nil

	RestArea( aArea )   

Return (lRet)          