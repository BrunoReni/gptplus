#INCLUDE "PRR030.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PRR030   � Autor � Tatiana L Campos      � Data � 10/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Questionarios                                 ���
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
Function PRR030()

Local oReport
Local aArea := GetArea()

If FindFunction("TRepInUse") .OR. TRepInUse()

	//���������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                          �
	//� Mv_Par01           // De  Questionario                        �
	//� Mv_Par02           // Ate Questionario  					  �
	//�����������������������������������������������������������������
	Pergunte("PRR030",.F.)

	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������
	oReport := PRR030RptDef()
	oReport:PrintDialog()
EndIf

RestArea( aArea )
Return

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �PRR030RptDef �Autor  �Tatiana L Campos    � Data �  10/08/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � PRR030                                                        ���
����������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���          �        �      �                                               ���
���          �        �      �                                               ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function PRR030RptDef()
Local oReport			// Objeto do relatorio
Local oSection1			// Objeto da secao 1
Local oSection2			// Objeto da secao 2

//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirmacao da geracao do relatorio�
//���������������������������������������������������������������������

//"Emissao de Respondentes. "
// "Este programa ira emitir uma relacao de Pesquisadores." 
DEFINE REPORT oReport NAME "PRR030" TITLE STR0001 PARAMETER "PRR030" ACTION {|oReport| PRR030PrtRpt(oReport)} DESCRIPTION STR0002

//���������������������������������������������������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal utlizado eh o SL3 e o complementar o SB1�
//�����������������������������������������������������������������������������������������������������������

DEFINE SECTION oSection1 OF oReport TITLE STR0001 TABLES "SKP"	// "Emissao de Questionarios. "

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������

DEFINE CELL NAME "KP_CODQUE"	OF oSection1 ALIAS "SKP"	//Codigo do questionario
DEFINE CELL NAME "KP_DESC"		OF oSection1 ALIAS "SKP"	//Descricao do questionario

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �PRR030RptDef �Autor  �Tatiana L Campos    � Data �  10/08/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � PRR030                                                        ���
����������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���          �        �      �                                               ���
���          �        �      �                                               ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao2 (que sera filha da secao1)  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection2 OF oSection1 TITLE STR0002 TABLES "SKG"	// "Emissao de Questionarios"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������

DEFINE CELL NAME "KG_CODQST"	OF oSection2 ALIAS "SKG"	//Codigo da questao
DEFINE CELL NAME "KG_DESC"		OF oSection2 ALIAS "SKG"	//Descricao da questao

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �PRR030PrtRpt�Autor  �Tatiana L Campos    � Data �  10/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � PRR030                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function PRR030PrtRpt( oReport )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local cAlias1	:= GetNextAlias()					// Pega o proximo Alias Disponivel
Local cFiltro	:= ""								// Variavel utilizada para o filtro

#IFDEF TOP
	DbSelectArea("SKP")
	DbSetOrder(1)
	//���������������������������������������������������������������������������������Ŀ
	//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
	//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
	//�����������������������������������������������������������������������������������
	MakeSqlExpr("PRR030")

	//��������������������Ŀ
	//�Inicializa a secao 1�
	//����������������������
	BEGIN REPORT QUERY oSection1

	//����������������Ŀ
	//�Query da secao 1�
	//������������������
	BeginSql alias cAlias1
		SELECT	KP_CODQUE,	KP_DESC,	KG_CODQST,	KG_DESC


		FROM %table:SKP% SKP,%table:SKG% SKG,%table:SKR% SKR
		WHERE	KP_FILIAL	=	%xfilial:SKP%	AND
				KG_FILIAL	=	%xfilial:SKG%	AND
				KR_FILIAL	=	%xfilial:SKR%	AND
				KP_CODQUE	>=	%exp:mv_par01%	AND
				KP_CODQUE	<=	%exp:mv_par02%	AND
				KP_CODQUE	=	KR_CODQUE		AND
                KG_CODQST	=	KR_CODQST		AND
				SKP.%notDel%					AND
				SKG.%notDel%					AND   
				SKR.%notDel%
		ORDER BY %Order:SKP%
	EndSql

	END REPORT QUERY oSection1

	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| (cAlias1)->KP_CODQUE == cParam},{|| (cAlias1)->KP_CODQUE})

#ENDIF	
//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()
Return