#include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "CSAA110.CH"

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Program   � CSAA110  � Autor � Emerson Grassi Rocha              � Data � 13/08/2003 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento de Classe Salariais                                        ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSAA110()                                                                ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                           ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���Cecilia Car.�07/07/2014�TPZVTW          �Incluido o fonte da 11 para a 12 e          ���
���            �          �                �efetuada a limpeza.                         ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������/*/
Function CSAA110()

	Local cFiltraRh			//Variavel para filtro
	Local oMBrowse

	oMBrowse := FWmBrowse():New()		
	oMBrowse:SetAlias( 'RBF' )
	oMBrowse:SetDescription( OemToAnsi(STR0001) )	//"Classes Salariais"
	
	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh := CHKRH(FunName(),"RBF","1")
	
	//Filtro padrao do Browse conforme tabela TMA (Cadastro de Agentes de Risco)
	oMBrowse:SetFilterDefault(cFiltraRh)
	oMBrowse:Activate()

Return(Nil)

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �28/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �CSAA100                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar' 
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.CSAA110" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.CSAA110" 		OPERATION 3 ACCESS 0				//'Incluir'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.CSAA110" 		OPERATION 4 ACCESS 0				//'Alterar'
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.CSAA110" 		OPERATION 5 ACCESS 0				//'Excluir'

Return aRotina 

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � ModelDef 		�Autor�  Mauricio Takakura� Data �14/06/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Modelagem da gravacao.                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �CSAA110                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ModelDef()

	Local oModel
	Local oStructRBF

	// Criacao do Objeto de Modelagem de dados da tabela SRJ //	
	oModel     := MPFormModel():New("CSAA110", NIL, { |oModel| Csaa110PosVal(oModel) } )
	oModel:SetDescription( OemToAnsi(STR0001) ) //
	
	// Estrutura de campos do Model //
	oStructRBF := FWFormStruct(1, "RBF")
	oStructRBF:RemoveField("RBF_FILIAL")

	oModel:AddFields("CSAA110_RBF", NIL, oStructRBF)
	
	oModel:GetModel( "CSAA110_RBF" ):SetDescription( OemToAnsi(STR0001) ) //"Classes Salariais"

Return( oModel )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � ViewDef  		�Autor�  Mauricio Takakura� Data �14/06/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Interface com o Usuario                           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �CSAA110                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ViewDef()
	Local oView 
	Local oModel
	Local oStructRBF
	                           
	// Criacao da Interface //
	oView := FWFormView():New()
	
	// Vincular o View ao Model //
	oModel := FWLoadModel("CSAA110")	
	oStructRBF := FWFormStruct(2, "RBF")

	oStructRBF:RemoveField("RBF_FILIAL")
	
	oView:SetModel(oModel)
	oView:AddField("CSAA110_RBF", oStructRBF)
	
	oView:CreateHorizontalBox("FIELDS", 100)
	
	oView:SetOwnerView("CSAA110_RBF", "FIELDS")
	
Return oView

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    � CSAA110PosVal� Autor �Mauricio Takakura   � Data �14/06/2011�
������������������������������������������������������������������������Ĵ
�Descri��o �Validacao para exclusao - Integridade Referencial DBF 		 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �                                                             �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide parametros formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �oView                                                 	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
�Uso       �Generico		                                             �
��������������������������������������������������������������������������/*/
Static Function Csaa110PosVal( oModel )
	Local lRetorno := .T.

Return( .T. )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �Cs110Class� Autor � Emerson Grassi Rocha  � Data � 28/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Busca Descricao da Classe Salarial.		                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cRet - Campo de Retorno da Descricao da Classe.             ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Cs110Class(cRet)
	Local aSaveArea	:= GetArea() 
	Local lRet		:= .T.
	Local cClasse	:= &(ReadVar())
	Local nPosDesc	:= GdFieldPos(cRet) 
	                   
	// Enchoice
	If Type("M->"+cRet) == "C"
		&("M->"+cRet) := FDesc("RBF",cClasse,"RBF->RBF_DESC")
	EndIf       

	// GetDados
	If nPosDesc > 0
		aCols[n][nPosDesc] := FDesc("RBF",cClasse,"RBF->RBF_DESC")
	EndIf

	RestArea(aSaveArea)
Return .T.