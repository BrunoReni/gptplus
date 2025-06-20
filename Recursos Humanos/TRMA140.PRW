#include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#include "TRMA140.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    � TRMA140  � Autor � Cristina Ogura             � Data � 12.11.98 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro dos Instrutores dos Cursos                             ���
������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                          ���
������������������������������������������������������������������������������Ĵ��
���Data      � Programador   � FNC  �Manutencao Efetuada                       ���
������������������������������������������������������������������������������Ĵ��
���21.07.2014�Cecilia Carv.  �TPZSOX�Incluido o fonte da 11 para a 12 e efetua-���
���          �               �      �da a limpeza.                             ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Function TRMA140()
	Local cFiltraRh			//Variavel para filtro
	Local oMBrowse

	oMBrowse := FWmBrowse():New()
	oMBrowse:SetAlias( 'RA7' )
	oMBrowse:SetDescription( OemtoAnsi(STR0008) )	//"Cadastro de Instrutores dos Cursos"

	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh := CHKRH(FunName(),"RA7","1")

	//Filtro padrao do Browse conforme tabela RA7 (Cadastro de Instrutores dos Cursos)
	oMBrowse:SetFilterDefault(cFiltraRh)
	oMBrowse:Activate()

Return(Nil)

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �26/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA140                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0003  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0              	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TRMA140" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TRMA140" 		OPERATION 3 ACCESS 0				//'Incluir'
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TRMA140" 		OPERATION 4 ACCESS 0				//'Alterar'
	ADD OPTION aRotina TITLE STR0007  ACTION "VIEWDEF.TRMA140" 		OPERATION 5 ACCESS 0				//'Excluir'

Return aRotina

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � ModelDef 		�Autor�  Mauricio Takakura� Data �14/06/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Modelagem da gravacao.                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA140                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ModelDef()

	Local oModel
	Local oStructRA7

	// Criacao do Objeto de Modelagem de dados da tabela SRJ //
	oModel     := MPFormModel():New("TRMA140" )
	oModel:SetDescription( OemToAnsi(STR0008) ) //"Cadastro de Instrutores dos Cursos"

	// Estrutura de campos do Model //
	oStructRA7 := FWFormStruct(1, "RA7")
	oStructRA7:RemoveField("RA7_FILIAL")

	oModel:AddFields("TRMA140_RA7", NIL, oStructRA7)

	oModel:GetModel( "TRMA140_RA7" ):SetDescription( OemToAnsi(STR0008) ) //"Cadastro de Instrutores dos Cursos"

Return( oModel )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � ViewDef  		�Autor�  Mauricio Takakura� Data �14/06/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Interface com o Usuario                           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA140                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ViewDef()
	Local oView
	Local oModel
	Local oStructRA7

	// Criacao da Interface //
	oView := FWFormView():New()

	// Vincular o View ao Model //
	oModel := FWLoadModel("TRMA140")
	oStructRA7 := FWFormStruct(2, "RA7")

	oStructRA7:RemoveField("RA7_FILIAL")

	oView:SetModel(oModel)
	oView:AddField("TRMA140_RA7", oStructRA7)

	oView:CreateHorizontalBox("FIELDS", 100)

	oView:SetOwnerView("TRMA140_RA7", "FIELDS")

Return oView
