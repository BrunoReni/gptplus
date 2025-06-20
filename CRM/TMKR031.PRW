#INCLUDE "TMKR031.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR031  � Autor � Armando M. Tessaroli  � Data � 14/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Produtos por Grupo                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Call Center                                                ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Conrado Q.�15/08/06� 8.11 � Bops. 99201 Conversao para relatorio perso-���
���          �        �      � nalizado (Release 4)                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR031()

Local oReport				// Objeto utilizado para a criacao do relatorio

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� Mv_Par01           // Do Grupo                               �
//� Mv_Par02           // Ate o Grupo                            �
//� Mv_Par03           // Do Produto                             �
//� Mv_Par04           // Ate o Produto                          �
//����������������������������������������������������������������
Pergunte("TMK031",.F.)

//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport := ReportDef() 
oReport:PrintDialog()
                 
Return .T.

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  �Conrado Q. Gomes    � Data �  15/08/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � TMKR031 R4                                                    ���
����������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���Tatiana C.�109139  � 811  � Tratamento de produtos sem grupo.             ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport						// Objeto do relatorio
Local oSection1					// Objeto da secao 1
Local oSection2					// Objeto da secao 2
Local cSB1 			:= "SB1"	// Alias da consulta Embedded SQL
Local cDesc			:= ""		// Descricao do grupo de produtos
Local cGrupo			:= ""		// Quebra por grupo de produtos     
Local nTam 			:= GetSX3Cache("BM_GRUPO","X3_TAMANHO") + 5

cSB1	:= GetNextAlias()

//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirma��o da geracao do relatorio�
//���������������������������������������������������������������������
DEFINE REPORT oReport NAME "TMKR031" TITLE STR0010 PARAMETER "TMK031" ACTION {|oReport| Tkr031PrtRpt(oReport, cSB1)} DESCRIPTION STR0001 + CRLF + STR0002		//"Produtos por Grupo"##"Este programa ir� emitir uma rela��o dos produtos por grupo"##"A emiss�o ocorrer� baseada nos parametros do relat�rio"

//����������������������������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal utlizado eh o SBM�
//������������������������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0013 TABLES "SBM"	// "Grupo de Produtos"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������         
DEFINE CELL NAME "BM_GRUPO"		OF oSection1 ALIAS "SBM" SIZE nTam  
DEFINE CELL NAME "BM_DESC"		OF oSection1 ALIAS "SBM"

//���������������������������������Ŀ
//�N�o quebra a p�gina a cada se��o.�
//�����������������������������������
oSection1:SetPageBreak(.F.) 

//�������������������������������������Ŀ
//�Exibi��o em modo vertical da colunas.�
//���������������������������������������
oSection1:SetLineStyle()

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao2 (que sera filha da secao1)  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection2 OF oSection1 TITLE STR0014 TABLES "SB1"	//	"Produtos"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������            
DEFINE CELL NAME "B1_COD" 		OF oSection2 ALIAS "SB1" 
DEFINE CELL NAME "B1_DESC"		OF oSection2 ALIAS "SB1"
DEFINE CELL NAME "B1_TIPO"		OF oSection2 ALIAS "SB1"
DEFINE CELL NAME "B1_UM"			OF oSection2 ALIAS "SB1"
DEFINE CELL NAME "B1_LOCPAD"	OF oSection2 ALIAS "SB1" 
DEFINE CELL NAME "B1_CUSTD"		OF oSection2 ALIAS "SB1" 
DEFINE CELL NAME "B1_PRV1"		OF oSection2 ALIAS "SB1"
DEFINE CELL NAME ""				OF oSection2 TITLE STR0011 BLOCK {|| PadL(Transform(Posicione("SB2", 1, xFilial("SB2") + (cSB1)->B1_COD + (cSB1)->B1_LOCPAD, "SaldoSB2()"),"@ER 99,999,999,999.99"), 17)} SIZE 17 ALIGN RIGHT // STR0011 = "Saldo"  Calcula o saldo do produto
               
//����������������������������������������������������������
//�Quebra a linha se o cabe�alho/conte�do atingir a largura�
//�m�xima.                                                 �
//����������������������������������������������������������
oSection2:SetLineBreak()

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TKR031PrtRpt�Autor  �Conrado Q. Gomes    � Data �  15/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � TMKR031 R4                                                   ���
���������������������������������������������������������������������������͹��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������͹��
���Parametros� oReport: Objeto TReport do relatorio                         ���
���          � cAlias1: Alias criado para a utilizacao com o relatorio      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/              
Static Function TKR031PrtRpt( oReport, cAlias1 )
Local oSection1	:= oReport:Section(1)		// Define a secao 1 do relatorio
Local oSection2	:= oSection1:Section(1)		// Define que a secao 2 serah filha da secao 1
Local cFilSB1		:= ""
Local cFilSB2		:= ""
Local aAreaSB1	:= SB1->(GetArea())

DbSelectArea("SBM")
DbSetOrder(1)

//������������������������������������������������������������
//�Transforma parametros do tipo Range em expressao SQL      �
//�para ser utilizada na query  Exemplo Word, nao intervalos �
//�pre definidos (mais utilizado pelo RH - Ferias)           �
//������������������������������������������������������������
MakeSqlExpr("TMK031")

//��������������������Ŀ
//�Inicializa a se��o 1�
//����������������������
BEGIN REPORT QUERY oSection1
	//����������������Ŀ
	//�Query da se��o 1�
	//������������������
	BeginSql alias cAlias1
		SELECT	BM_GRUPO, 	BM_DESC, 	B1_GRUPO,	B1_COD,
				B1_DESC, 	B1_TIPO, 	B1_UM,		B1_LOCPAD,
				B1_CUSTD,	B1_PRV1
		FROM	%table:SBM% SBM,%table:SB1% SB1
		WHERE	BM_FILIAL	=	%xfilial:SBM%	AND
				B1_FILIAL	=	%xfilial:SB1%	AND
				BM_GRUPO	=	B1_GRUPO		AND
				BM_GRUPO	>=	%exp:mv_par01%	AND
				BM_GRUPO	<=	%exp:mv_par02%	AND
				B1_COD		>=	%exp:mv_par03%	AND
				B1_COD		<=	%exp:mv_par04%	AND
				SBM.%notDel%					AND
				SB1.%notDel%
		ORDER BY %Order:SBM%
	EndSql
	//�������������������Ŀ
	//�Finaliza a se��o 1.�
	//���������������������
END REPORT QUERY oSection1

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->B1_GRUPO == cParam},{|| (cAlias1)->BM_GRUPO})
	
//��������������������������������������������Ŀ
//�Quebra a linha, caso existam muitas colunas.�
//����������������������������������������������
oSection1:SetLineBreak()

//���������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou �
//�query.                                                   �
//�����������������������������������������������������������
oSection1:Print()         

//��������������������������Ŀ
//�TRATA PRODUTOS SEM GRUPO. �
//����������������������������
If Empty( MV_PAR01 )
	cFilSB1	:= xFilial("SB1")
	cFilSB2	:= xFilial("SB2")
	aAreaSB1	:= SB1->(GetArea())
	DbSelectArea("SB1")
	DbSetOrder(4)
	If DbSeek( cFilSB1 + "" )
		oSection1:Cell("BM_DESC"):SetValue(STR0021)			//"Sem grupo de produtos informado no cadastro"
		oSection1:Init()
		oSection1:PrintLine()
		oSection2:Init()
		While SB1->(! Eof()) .AND. SB1->B1_FILIAL == cFilSB1 .AND. Empty(SB1->B1_GRUPO) .AND. SB1->B1_COD >= MV_PAR03 .AND. SB1->B1_COD <= MV_PAR04 
			//��������������������������������������������Ŀ
			//�Imprime PRODUTOS SEM GRUPO.                 �
			//����������������������������������������������
			oSection2:Cell("B1_COD"):SetValue(SB1->B1_COD)
			oSection2:Cell("B1_DESC"):SetValue(SB1->B1_DESC)
			oSection2:Cell("B1_TIPO"):SetValue(SB1->B1_TIPO)
			oSection2:Cell("B1_UM"):SetValue(SB1->B1_UM)
			oSection2:Cell("B1_LOCPAD"):SetValue(SB1->B1_LOCPAD)
			oSection2:Cell("B1_CUSTD"):SetValue(SB1->B1_CUSTD)
			oSection2:Cell("B1_PRV1"):SetValue(SB1->B1_PRV1)
			oSection2:Cell(""):SetValue(PadL(Transform(Posicione("SB2", 1, cFilSB2 + SB1->B1_COD + SB1->B1_LOCPAD, "SaldoSB2()"), "@ER 99,999,999,999.99"), 17))	// STR0011 = "Saldo"  Calcula o saldo do produto
			oSection2:PrintLine()	
			SB1->(DbSkip())
		End
		oSection2:Finish()
		oSection1:Finish()
	EndIf
	RestArea(aAreaSB1)
EndIf			
Return