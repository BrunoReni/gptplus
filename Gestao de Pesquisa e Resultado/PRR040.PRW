#INCLUDE "PRR040.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PRR040   � Autor � Tatiana L Campos      � Data � 03/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Respondentes                                  ���
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
Function PRR040()

Local oReport
Local aArea := GetArea()

If FindFunction("TRepInUse") .OR. TRepInUse()

	//���������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                          �
	//� Mv_Par01           // De Questao	                          �
	//� Mv_Par02           // Ate Questao	                          �
	//�����������������������������������������������������������������
	Pergunte("PRR040",.F.)

	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������
	oReport := PRR040RptDef()
	oReport:PrintDialog()
EndIf

RestArea( aArea )
Return

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �PRR040RptDef �Autor  �Tatiana L Campos    � Data �  04/08/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � PRR040                                                        ���
����������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���          �        �      �                                               ���
���          �        �      �                                               ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function PRR040RptDef()
Local oReport			// Objeto do relatorio
Local oSection1			// Objeto da secao 1
Local oSection2			// Objeto da secao 2

//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirmacao da geracao do relatorio�
//���������������������������������������������������������������������

//"Emissao de Respondentes. "
// "Este programa ira emitir uma relacao de Respondentes." 
DEFINE REPORT oReport NAME "PRR040" TITLE STR0001 PARAMETER "PRR040" ACTION {|oReport| PRR040PrtRpt(oReport)} DESCRIPTION STR0002

//���������������������������������������������������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal utlizado eh o SL3 e o complementar o SB1�
//�����������������������������������������������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0001 TABLES "SKG"		// "Emissao de Respondentes e questoes. "

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������
DEFINE CELL NAME "KG_CODQST"	OF oSection1 ALIAS "SKG"	//Codigo da questao
DEFINE CELL NAME "KG_DESC"		OF oSection1 ALIAS "SKG"	//Descricao da questao

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao2 (que sera filha da secao1)  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection2 OF oSection1 TITLE STR0002 TABLES "SKT"	// "Emiss�o de Respondentes e questoes. "

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������
DEFINE CELL NAME "KT_CODPESQ"	OF oSection2 ALIAS "SKT"	//Codigo da pesquisa
DEFINE CELL NAME "KT_CODRESP"	OF oSection2 ALIAS "SKT"	//Codigo do respondente

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �PRR040PrtRpt�Autor  �Tatiana L Campos    � Data �  04/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � PRR040                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function PRR040PrtRpt( oReport )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local cAlias1	:= GetNextAlias()					// Pega o proximo Alias Disponivel
Local cFiltro	:= ""								// Variavel utilizada para o filtro

#IFDEF TOP
	DbSelectArea("SKG")
	DbSetOrder(1)
	//���������������������������������������������������������������������������������Ŀ
	//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
	//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
	//�����������������������������������������������������������������������������������
	MakeSqlExpr("PRR040")

	//��������������������Ŀ
	//�Inicializa a secao 1�
	//����������������������
	BEGIN REPORT QUERY oSection1

	//����������������Ŀ
	//�Query da secao 1�
	//������������������
	BeginSql alias cAlias1
		SELECT	KG_CODQST,	KG_DESC,	KT_CODPESQ,	KT_CODRESP	


		FROM %table:SKG% SKG,%table:SKT% SKT
		WHERE	KG_FILIAL	=	%xfilial:SKG%	AND
				KT_FILIAL	=	%xfilial:SKT%	AND
				KG_CODQST	>=	%exp:mv_par01%	AND
				KG_CODQST	<=	%exp:mv_par02%	AND
				KG_CODQST	=	KT_CODQST		AND
				SKG.%notDel%					AND
				SKT.%notDel%					   
		ORDER BY %Order:SKG%
	EndSql
	END REPORT QUERY oSection1

	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| (cAlias1)->KT_CODQST == cParam},{|| (cAlias1)->KG_CODQST})
#ENDIF	

//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()
Return
