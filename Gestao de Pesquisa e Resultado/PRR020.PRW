#INCLUDE "PRR020.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PRR020   � Autor � Tatiana L Campos      � Data � 08/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Pesquisadores                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gestao de pesquisa e resultado - GPR                       ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PRR020()

Local oReport
Local aArea := GetArea()

If FindFunction("TRepInUse") .OR. TRepInUse()

	//���������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                          �
	//� Mv_Par01           // De  Pesquisador                         �
	//� Mv_Par02           // Ate Pesquisador   					  �
	//� Mv_Par03		   // De  Pesquisa 							  �
	//� Mv_Par04           // Ate Pesquisa               			  �
	//�����������������������������������������������������������������
	Pergunte("PRR020",.F.)

	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������             
	
	oReport := PRR020RptDef()
	oReport:PrintDialog()
EndIf

RestArea( aArea )
Return

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �PRR020RptDef �Autor  �Tatiana L Campos    � Data �  08/08/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � PRR020                                                        ���
����������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���          �        �      �                                               ���
���          �        �      �                                               ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function PRR020RptDef()
Local oReport			// Objeto do relatorio
Local oSection1			// Objeto da secao 1
Local oSection2			// Objeto da secao 2

//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirmacao da geracao do relatorio�
//���������������������������������������������������������������������

//"Emissao de Pesquisadores. "
// "Este programa ira emitir uma relacao de Pesquisadores." 
DEFINE REPORT oReport NAME "PRR020" TITLE STR0001 PARAMETER "PRR020" ACTION {|oReport| PRR020PrtRpt(oReport)} DESCRIPTION STR0002

//���������������������������������������������������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal utlizado eh o SL3 e o complementar o SB1�
//�����������������������������������������������������������������������������������������������������������

DEFINE SECTION oSection1 OF oReport TITLE STR0001 TABLES "SKN"		// "Emissao de Pesquisadores. "

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������

DEFINE CELL NAME "KN_CODPES"	OF oSection1 ALIAS "SKN"	//Codigo do pesquisador
DEFINE CELL NAME "KN_NOMPES"	OF oSection1 ALIAS "SKN"	//Nome do pesquisador 

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao2 (que sera filha da secao1)  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection2 OF oSection1 TITLE STR0002 TABLES "SKC"	// "Emissao de Pesquisadores "

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������

DEFINE CELL NAME "KC_CODPQ"		OF oSection2 ALIAS "SKC"	//Codigo da pesquisa
DEFINE CELL NAME "KC_DESC"		OF oSection2 ALIAS "SKC"    //Descricao da pesquisa

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �PRR020PrtRpt�Autor  �Tatiana L Campos    � Data �  04/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � PRR020                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function PRR020PrtRpt( oReport )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local cAlias1	:= GetNextAlias()					// Pega o proximo Alias Disponivel
Local cFiltro	:= ""								// Variavel utilizada para o filtro

#IFDEF TOP
	DbSelectArea("SKN")
	DbSetOrder(1)
	//���������������������������������������������������������������������������������Ŀ
	//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
	//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
	//�����������������������������������������������������������������������������������
	MakeSqlExpr("PRR020")

	//��������������������Ŀ
	//�Inicializa a secao 1�
	//����������������������
	BEGIN REPORT QUERY oSection1

	//����������������Ŀ
	//�Query da secao 1�
	//������������������
	BeginSql alias cAlias1
		SELECT	KN_CODPES,	KN_NOMPES,	KC_CODPQ,	KC_DESC


		FROM %table:SKN% SKN,%table:SKC% SKC,%table:SKO% SKO
		WHERE	KN_FILIAL	=	%xfilial:SKN%	AND
				KC_FILIAL	=	%xfilial:SKC%	AND
				KO_FILIAL	=	%xfilial:SKO%	AND
				KN_CODPES	>=	%exp:mv_par01%	AND
				KN_CODPES	<=	%exp:mv_par02%	AND
				KC_CODPQ	>=	%exp:mv_par03%	AND
				KC_CODPQ	<=	%exp:mv_par04%	AND
                KN_CODPES	=	KO_CODPQ		AND
                KC_CODPQ	=	KO_CODPSQ		AND
				SKN.%notDel%					AND
				SKC.%notDel%					AND   
				SKO.%notDel%
		ORDER BY %Order:SKN%
	EndSql

	END REPORT QUERY oSection1

	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| (cAlias1)->KN_CODPES == cParam},{|| (cAlias1)->KN_CODPES})

#ENDIF	
//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()
Return