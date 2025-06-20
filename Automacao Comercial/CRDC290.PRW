#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'CRDC290.CH'

Static oBrowse      // Objeto do Browse

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Crdc290   � Autor � Leandro Nogueira	    � Data � 28/12/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Posicao de cartao fidelidade								  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �ExpL1:=Crdc290()				 							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 		 													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �NIL					   									  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �SIGACRD												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/ 
Function Crdc290 () 
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('MBO')
oBrowse:SetDescription(STR0001) // "Posi��o de cartao Fidelidade"
oBrowse:SetExecuteDef(2)
oBrowse:Activate()
  		
Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �MenuDef	� Autor � Leandro Nogueira	    � Data � 27/12/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �MenuDef - MVC												  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �ExpA1:=MenuDef()				 							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 		 													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpA1 = aRotina											  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �SIGACRD												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/

Static Function MenuDef()
Local aRotina 	:= {}


ADD OPTION aRotina TITLE STR0002	ACTION 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.CRDC290' 	OPERATION 2 ACCESS 0 //"Visualizar" 
ADD OPTION aRotina TITLE STR0004	ACTION 'Cc290Rel()'			OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �ModelDef  � Autor � Leandro Nogueira	    � Data � 28/12/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �MVC - Camada de modelo de dados						 	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �ExpO1:=ModelDef()			 								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 		 													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1 = oModel											  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �SIGACRD												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Static Function ModelDef()  

Local oStruMBO 	:= FWFormStruct( 1, 'MBO')				// Estrutura do Modelo de Dados - Cadastro de cartoes fidelidade
Local oStruMBP 	:= FWFormStruct( 1, 'MBP')				// Estrutura do Modelo de Dados - Saldos dos cartoes fidelidade
Local oStruMBN 	:= FWFormStruct( 1, 'MBN') 				// Estrutura do Modelo de Dados - Movimentos cartao fidelidade  
Local oModel	:= MPFormModel ():New('CRDC290MODEL') 	// Modelo de dados
Local nOperation:= oModel:GetOperation()				
Local oReport	

oModel:SetDescription(STR0005)	//"Modelo de Dados Posi��o de cart�o fidelidade"

//��������������������������������������������������������������
//�Definicoes do FormFields com os dados do cartao selecionado �
//��������������������������������������������������������������
oModel:AddFields( 'MBOMASTER',   , oStruMBO)
oModel:GetModel( 'MBOMASTER' ):SetDescription(STR0006 )	//"Dados do cartao" 

//����������������������������������������������������������Ŀ
//�Definicoes do FormGrid com as RECARGAS de saldo realizadas�
//������������������������������������������������������������
oModel:AddGrid( 'MBPDETAIL', 'MBOMASTER', oStruMBP,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:SetRelation( 'MBPDETAIL', { { 'MBP_FILIAL', 'xFilial( "MBP" )' }, { 'MBP_NUMCAR' , 'MBO_CODBAR'  }} ,MBP->(IndexKey())  )
oModel:GetModel( 'MBPDETAIL' ):SetDescription(STR0007)//"Recargas do cart�o fidelidade"
oModel:GetModel( 'MBPDETAIL' ):SetNoInsertLine()
oModel:GetModel( 'MBPDETAIL' ):SetNoUpdateLine()
oModel:GetModel( 'MBPDETAIL' ):SetNoDeleteLine()

//���������������������������������������������������������������Ŀ
//�Definicoes do grid com as VENDAS pagas com o cartao fidelidade �
//�����������������������������������������������������������������
oModel:AddGrid( 'MBNDETAIL', 'MBOMASTER', oStruMBN)
oModel:SetRelation( 'MBNDETAIL', { { 'MBN_FILIAL', 'xFilial( "MBN" )' }, { 'MBN_NUMCAR' , 'MBO_CODBAR'  },{'MBN_TIPMOT','"2"'} } , MBN->(IndexKey())  )
oModel:GetModel( 'MBNDETAIL' ):SetDescription(STR0008)//"Movimentos do cart�o fidelidade"
oModel:GetModel( 'MBNDETAIL' ):SetNoInsertLine()
oModel:GetModel( 'MBNDETAIL' ):SetNoUpdateLine()
oModel:GetModel( 'MBNDETAIL' ):SetNoDeleteLine()

//�����������������������������������Ŀ
//�Campo Calculado - Total Recarregado�
//�������������������������������������
oModel:AddCalc( 'MBNCALC', 'MBOMASTER', 'MBPDETAIL', 'MBP_VALOR', 'MBP__SUMRECARGA', 'SUM', {|| .T.} )

//����������������������������������Ŀ
//�Campo Calculado - Saldo Dispon�vel�
//������������������������������������
oModel:AddCalc( 'MBNCALC', 'MBOMASTER', 'MBPDETAIL', 'MBP_SALDO', 'MBP__SUMSALDO', 'SUM', {|| .T.} )

//���������������������������������Ŀ
//�Campo Calculado - Total de Vendas�
//�����������������������������������
oModel:AddCalc( 'MBNCALC', 'MBOMASTER', 'MBNDETAIL', 'MBN_VALOR', 'MBN__TOTAL', 'SUM', {|| .T.} )


Return oModel


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �ViewDef   � Autor � Leandro Nogueira	    � Data � 28/12/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �MVC - Camada de visualiza��o de dados					 	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �ExpO1:=ModelDef()			 								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 		 													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1 = oModel											  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �SIGACRD												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oModel   := FWLoadModel( 'CRDC290' )  	// Modelo de Dados baseado no ModelDef do fonte informado
Local oStruMBO := FWFormStruct( 2, 'MBO' )		// Estrutura da View - Cadastro de cartoes fidelidade
Local oStruMBP := FWFormStruct( 2, 'MBP')		// Estrutura da View - Saldos dos cartoes fidelidade
Local oStruMBN := FWFormStruct( 2, 'MBN') 		// Estrutura da View - Movimentos cartao fidelidade  
Local oView    := FWFormView():New()			// Objeto de visualizacao   
Local oCalc									// Objetos de calculo
Local nOperation:= oModel:GetOperation()

oView:SetModel( oModel )                

// Remove campos da estrutura
oStruMBP:RemoveField( 'MBP_NUMCAR' ) 
oStruMBN:RemoveField( 'MBN_NUMCAR' ) 
oStruMBN:RemoveField( 'MBN_ITSALD' ) 
oStruMBN:RemoveField( 'MBN_TIPMOT' ) 

//��������������������������������������������������������������
//�Definicoes do FormFields com os dados do cartao selecionado �
//��������������������������������������������������������������
oView:AddField( 'VIEW_MBO', oStruMBO, 'MBOMASTER' )

//����������������������������������������������������������Ŀ
//�Definicoes do FormGrid com as RECARGAS de saldo realizadas�
//������������������������������������������������������������
oView:AddGrid(  'VIEW_MBP', oStruMBP, 'MBPDETAIL' )


//����������������������������������������������������������Ŀ
//�Definicoes do FormGrid com as VENDAS de saldo realizadas  �
//������������������������������������������������������������
oView:AddGrid(  'VIEW_MBN', oStruMBN, 'MBNDETAIL' )


oCalc := FWCalcStruct( oModel:GetModel( 'MBNCALC') )
oCalc:SetProperty( 'MBP__SUMRECARGA', MVC_VIEW_TITULO,STR0009 ) //"Recarga"
oCalc:SetProperty( 'MBP__SUMSALDO', MVC_VIEW_TITULO,STR0010 )//"Saldo"
oCalc:SetProperty( 'MBN__TOTAL', MVC_VIEW_TITULO,STR0011 )//"Vendas"

oView:AddField( 'VIEW_CALC', oCalc, 'MBNCALC' )


//����������������������
//�Definicoes dos Boxes�
//����������������������
oView:CreateHorizontalBox( 'SUPERIOR' , 20 )
oView:SetOwnerView( 'VIEW_MBO', 'SUPERIOR' )  
oView:EnableTitleView	('VIEW_MBO'	,STR0012) //"Cart�o Fidelidade"

oView:CreateHorizontalBox( 'INFERIOR' , 70 )   

oView:CreateVerticalBox( 'INFERIORDIREITA' , 40 ,'INFERIOR')
oView:SetOwnerView( 'VIEW_MBP', 'INFERIORDIREITA' )  
oView:EnableTitleView('VIEW_MBP' ,STR0013)//"Recargas" 

oView:CreateVerticalBox( 'INFERIORESQUERDA' , 60 ,'INFERIOR')
oView:SetOwnerView( 'VIEW_MBN', 'INFERIORESQUERDA' )  
oView:EnableTitleView('VIEW_MBN'	,STR0014)//"Vendas" 

oView:CreateHorizontalBox( 'RODAPE' , 10 )
oView:SetOwnerView( 'VIEW_CALC', 'RODAPE' )  
oView:EnableTitleView('VIEW_CALC',STR0015)//"Totais" 

Return oView      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Cc290Rel  � Autor � Leandro Nogueira	    � Data � 30/12/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Obtem o codigo doc artao selecionado e executa a impressao  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �ExpO1:=Cc290Rel ()		 								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 		 													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �NIL														  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �SIGACRD												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function Cc290Rel()

Crdr290 (oBrowse:GetColumnData(1))

Return NIL