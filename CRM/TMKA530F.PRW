#INCLUDE "TMKA530F.ch"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SLAResponsible	�Autor: Vendas Clientes     �Data:08/01/08���
�������������������������������������������������������������������������͹��
���Desc.     � Descreve o responsavel pelo SLA							  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class SLAResponsible
Data id						//ID do responsavel
Data codProtheusUser		//Usuario Protheus
Data email					//E-mail do responsavel
Data name					//Nome do responsavel
Data codSuperior			//Cod. do superior
Data oPersist           	//Classe de acesso ao banco de dados

Method new() Constructor
Method load()
Method save()
Method delete()
Method createPersist()
Method openBrowse()
Method showDialog(cAction, nReg, nOpc)
Method free()

EndClass


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �New          �Autor  � Vendas Clientes � Data �  08/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe SLAResponsible	              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class SLAResponsible
Self:id					:= ""
Self:codProtheusUser	:= ""
Self:email				:= ""
Self:name				:= ""
Self:codSuperior		:= ""
Self:oPersist 			:= Self:createPersist()

Return Self


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �load      �Autor  �Vendas Clientes     � Data �  14/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que aciona a operacao de carregar registro de       ���
���          � responsavel                                                ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(id) Class SLAResponsible
Local lRet := .F.			//Variavel de retorno do metodo

Self:id := id
lRet := Self:oPersist:load(Self)
If !lRet 
	Self:id := ""
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �save      �Autor  �Vendas Clientes     � Data �  14/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que aciona a operacao de salvar reg. de responsavel ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method save() Class SLAResponsible
Local lRet := .F.			//Variavel de retorno do metodo

lRet := Self:oPersist:save(Self)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �delete    �Autor  �Vendas Clientes     � Data �  14/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que aciona a operacao de excluir registro de        ���
���          � responsavel                                                ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method delete() Class SLAResponsible
Local lRet := .F.		//Variavel de retorno do metodo

lRet := Self:oPersist:delete(Self)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �createPersist �Autor  �Vendas Clientes � Data �  14/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a classe de acesso ao banco de dados.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method createPersist() Class SLAResponsible
Local obj			//Objeto de retorno da classe de Persistencia

#IFDEF TOP
	obj := SLAResponsibleTop():New()
#ELSE
	obj := SLAResponsibleCodebase():New()
#ENDIF

Return obj


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �openBrowse   �Autor  � Vendas Clientes � Data �  14/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exibe o browse da rotina de cadastro de Responsaveis por    ���
���          �SLA.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method openBrowse() Class SLAResponsible

Private aRotina		:= MenuDef()		//Array com as rotinas do menu funcional
Private cCadastro 	:= STR0007			//Titulo da Dialog //"Responsaveis por SLA"

DbSelectArea("SK8") 
DbSetOrder(1)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSetOrder(1)
DbSeek(xFilial("SK8"))
MBrowse(,,,,"SK8",,,,,,,,,,)

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Funcao   �TK530FOpc    �Autor  � Vendas Clientes � Data �  14/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Abre a tela para configurar responsaveis por SLA conforme   ���
���          �a opcao selecionada.                              		  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TK530FOpc(cAlias, nReg, nOpc) 

If nOpc == 2
	
	oObj:showDialog(STR0001, nReg, nOpc) //"Visualizar"
	
ElseIf nOpc == 3

	oObj:showDialog(STR0002, nReg, nOpc)  //"Incluir"

ElseIf nOpc == 4	 

	oObj:showDialog(STR0003, nReg, nOpc) //"Alterar"

ElseIf nOpc == 5

	If oObj:showDialog(STR0004, nReg, nOpc) //"Excluir"
		If MsgYesNo(STR0005 + AllTrim(oObj:id) + "'?", STR0006) //"Deseja realmente excluir o Responsavel '"###"Aten��o"
			//��������������������������������������������������������������Ŀ
			//� Se existir Contratos de SLA para o respons�vel n�o exclui.   �
			//����������������������������������������������������������������
			If Tk530VerSla(oObj:id)
				oObj:delete()
			Else
				Help(" ",1,"NODELETA",,STR0009,2,0)	//"Este respons�vel esta sendo utilizado pela rotina de Contrato de SLA."
			EndIf
		EndIf
	EndIf	

EndIf

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo    � showDialog � Autor �  Vendas Clientes	� Data � 14/01/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Controla a interface do cadastro de Responsaveis por SLA   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void showDialog(ExpC1,ExpN1,ExpN2)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Acao a executar                                    ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMKA503A                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Method showDialog(cAction, nReg, nOpc) Class SLAResponsible
Local aArea     := GetArea()                            //Guarda a area atual
Local aPosObj   := {}									//Array com posicao dos objetos
Local aObjects  := {}									//Array com as coordenadas da tela
Local aSize     := {}									//Array com as dimensoes retornadas pelo MsAdvSize()
Local aInfo     := {}									//Array de informacoes de tela

Local nOpcA     := 0									//Guarda a opcao selecionada (1=gravar;0=cancelar)
Local nSaveSx8 	:= GetSX8Len()							//Numeracao automatica
Local lContinua := .T.									//Indica se continua a execucao
Local lRet		:= .T.									//Indica o retorno da funcao
Local oDlg												//Objeto Dialog

Private aTELA[0][0]
Private aGETS[0]

DEFAULT INCLUI := .F.

//������������������������������������������������������������������������Ŀ
//�Inicializa as variaveis da Enchoice                                     �
//��������������������������������������������������������������������������
If INCLUI
	RegToMemory("SK8", .T., .F. )
Else
	If SoftLock("SK8") 
		RegToMemory( "SK8", .F., .F. )
		Self:load( M->K8_CODRESP )
	Else
		lContinua	:= .F.
		lRet		:= .F.
	EndIf
EndIf


If lContinua
	//������������������������������������������������������Ŀ
	//� Faz o calculo automatico de dimensoes de objetos     �
	//��������������������������������������������������������
	aSize := MsAdvSize()
	aAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects, .T.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
	
	EnChoice("SK8", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA := 1, If(!Obrigatorio(aGets,aTela), nOpcA := 0, oDlg:End()) },;
													{|| nOpcA := 0, oDlg:End()},,/*aButtons*/)


	If nOpcA == 0
		lRet := .F.	
		While (GetSx8Len() > nSaveSx8)
			RollBackSX8()
		End	
	Else
		//�����������������������������Ŀ
		//� Atualiza os dados do objeto �
		//�������������������������������
		Self:id					:= M->K8_CODRESP
		Self:name				:= M->K8_NOME
		Self:email				:= M->K8_EMAIL
		Self:codProtheusUser	:= M->K8_CODUSU
		Self:codSuperior		:= M->K8_SUPERIO
		//������������������Ŀ
		//� Grava o registro �
		//��������������������
		If nOpc == 3 .OR. nOpc == 4
			Self:save()
			While (GetSx8Len() > nSaveSx8)
				ConfirmSX8()
			End
			EvalTrigger()
		EndIf
	EndIf

EndIf

//������������������������������Ŀ
//� Restaura a entrada da rotina �
//��������������������������������
MsUnLockAll()
FreeUsedCode()
RestArea(aArea)

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �free       	�Autor  �Vendas Clientes � Data �  30/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Libera a mem�ria dos objetos utilizados.    			 	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method free() Class SLAResponsible
TMKFree( Self:oPersist )
Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKA530F � Autor � IP - Vendas Clientes  � Data � 14/01/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Responsaveis por SLA                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MP10                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKA530F()
Static oObj := SLAResponsible():New()		//Objeto da classe SLAResponsible

oObj:openBrowse()
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA530F     �Autor  �Vendas Clientes � Data �  08/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION _TMKA530F()
RETURN NIL


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef	� Autor � Vendas Clientes       � Data �14/01/08  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMKA530F                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 
Local aRotina		//Array de rotinas

aRotina		:= {{ STR0008	,"AxPesqui" 	,0	,1 },; 	// 	"Pesquisar"  //"Pesquisar"
				{ STR0001	,"TK530FOpc" 	,0	,2 },; 	// 	"Visualizar" //"Visualizar"
				{ STR0002	,"TK530FOpc" 	,0	,3 },; 	// 	"Incluir"  //"Incluir"
				{ STR0003	,"TK530FOpc" 	,0	,4 },;	//	"Alterar" //"Alterar"
				{ STR0004  	,"TK530FOpc" 	,0	,5 }} 	// 	"Excluir" //"Excluir"

Return(aRotina)     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk530VerSla�Autor  � Vendas Clientes    � Data �  15/03/13  ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se exitem Contratos de SLA para o Respons�vel.     ���
�������������������������������������������������������������������������͹��
���Uso       � TMKA530F                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tk530VerSla(cCodResp)

Local cQuery := ""
Local cAlias := ""
Local lRet	 := .T.

#IFDEF TOP
	cAlias := GetNextAlias()
	cQuery += " SELECT COUNT(*) TOTAL FROM " + RetSqlName("SK6")
	cQuery += " WHERE "
	cQuery += " K6_FILIAL  = '" + xFilial("SK6") + "' AND "
	cQuery += " K6_CODRESP = '" + cCodResp       + "' AND "
	cQuery += " D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	If (cAlias)->TOTAL > 0
		lRet := .F.
	Endif

	(cAlias)->(dbCloseArea())
#ENDIF

Return lRet