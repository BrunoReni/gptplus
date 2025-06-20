#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATA630.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �FATA630     � Autor �Eduardo Gomes Junior   � Data � 29/06/08 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de componentes - Integracao com WORD.				���	
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                      	���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum					 									���
���������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         	���
���������������������������������������������������������������������������Ĵ��
���          �               �                                            	���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
FUNCTION FATA630()
Local oMBrowse
	
DEFINE FWMBROWSE oMBrowse ALIAS "AG3" DESCRIPTION STR0001 //"Cadastro de Componentes"
ACTIVATE FWMBROWSE oMBrowse

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �MenuDef     � Autor �Eduardo Gomes Junior   � Data � 29/06/08 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do aRotina (Menu funcional)                      	���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina                                                     	���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
���������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         	���
���������������������������������������������������������������������������Ĵ��
���          �               �                                            	���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()

Private aRotina := {}	//Array para opcoes
				
ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.FATA630' OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.FATA630' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.FATA630' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.FATA630' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.FATA630' OPERATION 5 ACCESS 0	 //"Exclui"
								
Return(aRotina)


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �ViewDef     � Autor �Vendas & CRM           � Data � 16/01/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao da View                                          	���
���������������������������������������������������������������������������Ĵ��
���Retorno   � oView                                                       	���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()
Local oModel 	 := FWLoadModel( 'FATA630' )	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruAG3 := FWFormStruct( 2, 'AG3' )	// Cria as estruturas a serem usadas na View
Local oStruAG4 := FWFormStruct( 2, 'AG4' , { |cCampo| (Trim(cCampo) <> "AG4_CODIGO") } ) // Retira o Campo AG4_CODIGO do Grid.
Local oView									// Interface de visualiza��o constru�da

oView := FWFormView():New()								// Cria o objeto de View
oView:SetModel( oModel )									// Define qual Modelo de dados ser� utilizado				
oView:AddField( 'VIEW_AG3', oStruAG3, 'AG3MASTER' )	// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
oView:AddGrid( 'VIEW_AG4' , oStruAG4, 'AG4DETAIL' )	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddIncrementField( 'VIEW_AG4', 'AG4_ITEM' )		// Item Incremental do Grid

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 20 )			
oView:CreateHorizontalBox( 'INFERIOR', 80 )

// Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView( 'VIEW_AG3', 'SUPERIOR' )			
oView:SetOwnerView( 'VIEW_AG4', 'INFERIOR' )

Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �ModelDef    � Autor �Vendas & CRM           � Data � 16/01/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do Model                                         	���
���������������������������������������������������������������������������Ĵ��
���Retorno   � oModel                                                      	���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruAG3 := FWFormStruct( 1, 'AG3' )
Local oStruAG4 := FWFormStruct( 1, 'AG4' )
Local oModel // Modelo de dados constru�do

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'FATA630')
oModel:SetVldActivate( { |oModel| A630PRE( oModel ) } )

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'AG3MASTER', /*cOwner*/, oStruAG3 )
// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'AG4DETAIL', 'AG3MASTER', oStruAG4 )
oModel:GetModel( 'AG4DETAIL'):SetOptional( .T. )
// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'AG4DETAIL', { { 'AG4_FILIAL', 'xFilial( "AG4" )' }, { 'AG4_CODIGO', 'AG3_CODIGO' } }, AG4->( IndexKey( 1 ) ) )
// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( STR0001 ) //"Cadastro de Componentes"

// Retorna o Modelo de dados

Return oModel

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �A630Pre     � Autor �Vendas & CRM           � Data � 16/01/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pr�-Valida��o do Model                                     	���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                      	���
���������������������������������������������������������������������������Ĵ��
���Parametros� oModel 														���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function A630Pre(oModel) 
Local lRet := .T.

//Valida�ao Exclus�o.
If oModel:getOperation() == MODEL_OPERATION_DELETE .AND. !Ft630Exclui()
	lRet := .F.
EndIf

Return lRet
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �A630Aheader � Autor �Eduardo Gomes Junior   � Data � 29/06/08 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Monta aHeader e aCols.									 	���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                      	���
���������������������������������������������������������������������������Ĵ��
���Parametros� cAlias	- Alias usado para criar o aHeader/aCols			���
���			 � cCampo	- Campo para ser usado na pesquisa					���
���������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         	���
���������������������������������������������������������������������������Ĵ��
���          �               �                                            	���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function A630Aheader(cAlias, cCampo)

Local aArea    		:= GetArea()										//Guarda area atual
Local nX       		:= 1												//Usando no For/Next
Local nCOLSCntfor	:= 1												//Usando no For/Next

Private cChave		:= "" 												//Campo chave de pesquisa

Default cCAMPO     	:= IIF( VALTYPE(cCAMPO) != "U" , cCAMPO , "" )		//Campo a ser pesquisado

//��������������������Ŀ
//�Montagem do aHeader �
//����������������������
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek( cALIAS )

While ( !EOF() .And. (SX3->X3_ARQUIVO == cALIAS ) )

	If 	X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .AND. !(ALLTRIM(SX3->X3_CAMPO)$ cCAMPO )

		AADD(aHeader,{ TRIM(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT,;
						SX3->X3_INIBRW } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()

EndDo

//�������������������������������������Ŀ
//�Montagem do aCols baseado no aHeader �
//���������������������������������������
cChave		:= xFILIAL("AG3") +AG3->AG3_CODIGO
cCompara	:= "AG4->(AG4_FILIAL+AG4_CODIGO) == cChave"

//����������������������Ŀ
//�Inclui elemento vazio �
//������������������������
IF 	INCLUI 
	AADD( aCOLS, ARRAY(LEN(aHEADER)+1) )
	For nCOLSCntFor := 1 To Len(aHeader)
		cCOLSCampo := Alltrim(aHeader[nCOLSCntFor,2])          
		aCols[Len(aCols)][nCOLSCntFor] := CriaVar(cCOLSCampo)
	NEXT nCOLSCntfor
	aCols[Len(aCols)][ Len(aHeader)+1 ] 		:= .F.
EndIf

//�����������������������������������Ŀ
//�Preenche acols com conteudo gravado�
//�������������������������������������
IF 	ALTERA .OR. EXCLUI .OR. VISUAL
	dbSelectArea( "AG4" )
	dbSetOrder( 1 )
	MsSeek( cChave )
	
	While &(cCOMPARA) .AND. !EOF() 
		
		AADD(aCols,Array(Len(aHeader)+1))
		
		For nX := 1 to Len(aHeader)
			If 	( aHeader[nX][10] <> "V" )
				aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
			Else
				aCols[Len(aCols)][nX] := IIF(!EMPTY(aHeader[nX][11]),&(aHeader[nX][11]),Criavar(aHeader[nX][2],.T.))
			EndIf
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
		Next nX
		
		dbSelectArea( cAlias )
		dbSkip()
		
	EndDo
	
EndIf
	
RestArea(aArea)

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �A630GravaMod� Autor �Eduardo Gomes Junior   � Data � 29/06/08 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao do modelo 											���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                      	���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum					 									���
���������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         	���
���������������������������������������������������������������������������Ĵ��
���          �               �                                            	���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function A630GravaMod()

Local nX 	//Usado no FOR/NEXT
Local ny 	//Usado no FOR/NEXT

IF 	INCLUI

	dbSelectArea("AG3")
	dbSetOrder(1)	
	If (nX := Ascan(aCposAG3,"AG3_FILIAL")) == 0 	
		Aadd(aCposAG3,"AG3_FILIAL")
		M->AG3_FILIAL := XFilial("AG3")		
	EndIf
	RecLock("AG3",.T.)
	AEval(aCposAG3,{|x|&("AG3->"+x):=&("M->"+x)})
	MsUnlock()
	
EndIf 

IF 	ALTERA

	dbSelectArea("AG3")
	dbSetOrder(1)
	msSeek( xFILIAL("AG3") + M->AG3_CODIGO )

	RecLock("AG3",.F.)
	AEval(aCposAG3,{|x|&("AG3->"+x):=&("M->"+x)})
	MsUnlock()

EndIf 

//������������������������������������Ŀ
//�Remove itens existentes no cabecalho�
//��������������������������������������
If 	EXCLUI 

	dbSelectArea("AG3")
	dbSetOrder( 1 ) 
	msSeek( xFilial("AG3") + M->AG3_CODIGO ) 

	RecLock("AG3")
	dbDelete()
	msUnlock()
	 
EndIf 

//������������������������������������Ŀ
//�Remove itens existentes nos itens   |
//��������������������������������������
If 	EXCLUI .OR. ALTERA

	dbSelectArea("AG4")
	dbSetOrder( 1 ) 
	msSeek( xFilial("AG4") + M->AG3_CODIGO ) 
	WHILE AG4->(AG4_FILIAL+AG4_CODIGO) == xFILIAL("AG4")+ M->AG3_CODIGO .AND. !EOF()
		RecLock("AG4")
		dbDelete()
		msUnlock()
		dbSkip()
	ENDdo
	
EndIf 

//���������������������������������Ŀ
//�Inclui itens disponiveis no Acols�
//�����������������������������������
If	INCLUI .OR. ALTERA            

	FOR nX := 1 TO LEN( aCOLS ) 
	
		IF 	( aCols[nx][Len(aHeader)+1] ) 
			Loop
		ENDif
		
		dbSelectArea('AG4')
		RecLock('AG4',.T.)
		AG4->AG4_FILIAL		:= xFILIAL("AG4") 
		AG4->AG4_CODIGO		:= M->AG3_CODIGO
	
		//����������������������������������������������������������Ŀ
		//� Atualiza os dados contidos na GetDados                   �
		//������������������������������������������������������������
		For ny := 1 to Len(aHeader)
			If 	aHeader[ny][10] # "V"
				AG4->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
			Endif
		Next
		msUnlock()
		
	NEXT nX

EndIf

Return		

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �A600ValDOT  � Autor �Eduardo Gomes Junior   � Data � 29/06/08 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o arquivo DOT informado pelo usuario					���
���			 � Observacao: funcao acionada atraves da validacao do campo 	���
���			 � (X3_VALID) AG3_DOCWOR e AG4_DOCWOR.							���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRet - Verdadeiro / Falso                           			���
���������������������������������������������������������������������������Ĵ��
���Parametros� cNomeDot - Nome do DOT informado								���
���������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         	���
���������������������������������������������������������������������������Ĵ��
���          �               �                                            	���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function A630ValDOT(cNomeDot)

Local lRet 			:= .T.														//Retorno (.T./.F.)
Local cPathServer	:= Alltrim(SuperGetMv("MV_DOCAR")) 								//Caminho que fica os DOTS (exemplo: \system\word\)

If	!File(Alltrim(cPathServer)+alltrim(cNomeDot)+".DOT")
	MsgAlert(STR0007+Alltrim(cPathServer),STR0008) //"DOT informado n�o encontrado na pasta:"###"Aten��o"
	lRet := .F.
Endif

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft630Exclui�Autor  � Vendas Clientes    � Data �  09/01/12  ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se o componente n�o est� sendo utilizado por	  ���
��� 	     � nenhum modelo.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � FATA630                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft630Exclui()

Local cQuery  := ""
Local lDeleta := .T.

BeginSQL Alias "TRBAG2"
	SELECT COUNT(*) MODELO FROM  %Table:AG2%  AG2
	WHERE AG2.%NotDel%  
	  And AG2.AG2_FILIAL  = %xFilial:AG2%
	  And ( AG2.AG2_COMPPR = %Exp:AG3->AG3_CODIGO%
	   OR   AG2.AG2_COMPAS = %Exp:AG3->AG3_CODIGO%)  
EndSql


If TRBAG2->MODELO > 0
	Help(" ",1,"NODELETA")
	lDeleta := .F.
Endif

dbSelectArea("TRBAG2")
TRBAG2->(dbCloseArea())
dbSelectArea("AG3")

Return (lDeleta)
