#INCLUDE "TMKR037.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR037  � Autor � Armando M. Tessaroli  � Data � 16/07/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Situacao dos titulos por cliente.                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico TeleCobranca (ACF)                                ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR037()

Local oReport
Local aArea := GetArea()

//���������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                          �
//� Mv_Par01           // Do Cliente                              �
//� Mv_Par02           // Da Loja                                 �
//� Mv_Par03           // Ate o Cliente                           �
//� Mv_Par04           // Ate a Loja                              �
//� Mv_Par05           // Status do Titulo                        �
//� Mv_Par06           // Tipo da Ligacao                         �
//� Mv_Par07           // Ocorrencia                              �
//�����������������������������������������������������������������
Pergunte("TMK037",.F.)

//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  �Hanna               � Data �  27/06/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � TMKR037                                                       ���
����������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���Hanna C   �26/07/06�R4    � Inclusao SetLineStyle para impressao estilo   ���
���          �        �      � Enchoice                                      ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport				// Objeto do relatorio
Local oSection1				// Objeto da secao 1
Local oSection2				// Objeto da secao 2
Local cAlias1	:= "ACG"	// Pega o proximo Alias Disponivel

cAlias1		:= GetNextAlias()						// Pega o proximo Alias Disponivel

//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirma��o da geracao do relatorio�
//���������������������������������������������������������������������

//"Situa��o dos T�tulos em Cobran�a"
// "Este programa ir� emitir a rela��o dos t�tulos com cobran�a efetuada pelo atendimento de Telecobran�a."
// "Apenas os T�tulos a receber que foram pelo atendimento de Telecobran�a ser�o considerados."
DEFINE REPORT oReport NAME "TMKR037" TITLE STR0001 PARAMETER "TMK037" ACTION {|oReport| Tkr037PrtRpt( oReport, cAlias1 )} DESCRIPTION STR0002 + STR0003

//���������������������������������������������������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal utlizado eh o SL3 e o complementar o SB1�
//�����������������������������������������������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0017 TABLES "ACF","SU5","SA1"		// "Dados Cliente"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������
DEFINE CELL NAME "ACF_CLIENT"	OF oSection1 ALIAS "ACF"
DEFINE CELL NAME "ACF_LOJA"		OF oSection1 ALIAS "ACF"
DEFINE CELL NAME "A1_NOME"		OF oSection1 ALIAS "SA1"
DEFINE CELL NAME "ACF_CODCON"	OF oSection1 ALIAS "ACF"
DEFINE CELL NAME "U5_CONTAT"	OF oSection1 ALIAS "SU5"

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao2 (que sera filha da secao1)  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection2 OF oSection1 TITLE STR0018 TABLES "ACF","ACG"	// "Itens dos Titulos em Cobranca"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������
DEFINE CELL NAME "ACG_CODIGO"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACF_DATA"		OF oSection2 ALIAS "ACF"
DEFINE CELL NAME "ACF_PENDEN"	OF oSection2 ALIAS "ACF"
DEFINE CELL NAME "ACF_HRPEND"	OF oSection2 ALIAS "ACF"
DEFINE CELL NAME "ACG_PREFIX"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_TITULO"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_PARCEL"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_TIPO"		OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_NATURE"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_DTVENC"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_DTREAL"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_VALOR"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_ACRESC"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_DECRES"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_NUMBCO"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_VALJUR"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_PORJUR"	OF oSection2 ALIAS "ACG"
DEFINE CELL NAME "ACG_STATUS"	OF oSection2 ALIAS "ACG"

DEFINE FUNCTION FROM oSection2:Cell("ACG_VALOR") FUNCTION SUM TITLE STR0012 FORMULA {|| TKR037RetVal( cAlias1, "1" ) }
DEFINE FUNCTION FROM oSection2:Cell("ACG_VALOR") FUNCTION SUM TITLE STR0013 FORMULA {|| TKR037RetVal( cAlias1, "2" ) }
DEFINE FUNCTION FROM oSection2:Cell("ACG_VALOR") FUNCTION SUM TITLE STR0014 FORMULA {|| TKR037RetVal( cAlias1, "3" ) }

//�������������������������������������������Ŀ
//�Define a secao3 (que sera filha da secao2) �
//���������������������������������������������
oSection1:SetLineStyle()
oSection2:SetTotalText("")
Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TKR037PrtRpt�Autor  �Hanna               � Data �  17/05/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � TMKR037                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function TKR037PrtRpt( oReport, cAlias1 )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local cQuery	:= "%%"								// Variavel da cQuery
Local cQuery1	:= "%%"								// Variavel da cQuery
Local cQuery2	:= "%%"								// Variavel da cQuery

//�����������������������������������������������������Ŀ
//�Abre o arquivo de telecobranca pelo indice do cliente�
//�������������������������������������������������������
DbSelectArea("ACF")
DbSetOrder(2)

//���������������������������������������������������������������������������������Ŀ
//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
//�����������������������������������������������������������������������������������
MakeSqlExpr("TMK037")

//������������������������������������������������Ŀ
//�Se nao for AMBOS, pego apenas ATIVO ou RECEPTIVO�
//��������������������������������������������������
If MV_PAR06 <> 3
	cQuery := "%ACF_OPERA = '" + STR( MV_PAR06,1 ) + "' AND %"
EndIf

//���������������������������������������������������Ŀ
//�Se escolheu uma ocorrencia, somente ela eh filtrada�
//�����������������������������������������������������
If !Empty(MV_PAR07)
	cQuery1 := "%ACF_MOTIVO = '" + MV_PAR07 + "' AND %"
Endif

//���������������������������������������������������Ŀ
//�Se nao for TODOS os status, pego apenas o escolhido�
//�����������������������������������������������������
If MV_PAR05 <> 4
	cQuery2	:= "%ACG_STATUS = '" + STR( MV_PAR05,1 ) + "' AND %"
Endif

//��������������������Ŀ
//�Inicializa a secao 1�
//����������������������
BEGIN REPORT QUERY oSection1

//��������������������������������������������������������Ŀ
//�Query utilizada para filtrar todos os dados necessarios �
//����������������������������������������������������������
BeginSql alias cAlias1
	SELECT	ACF_CLIENT,	ACF_LOJA,	A1_NOME,	ACF_CODCON,	U5_CONTAT,	ACG_CODIGO,
			ACF_DATA,	ACF_PENDEN,	ACF_HRPEND,	ACG_PREFIX,	ACG_TITULO,	ACG_PARCEL,
			ACG_TIPO,	ACG_NATURE,	ACG_DTVENC,	ACG_DTREAL,	ACG_VALOR,	ACG_ACRESC,
			ACG_DECRES,	ACG_NUMBCO,	ACG_VALJUR,	ACG_PORJUR,	ACG_STATUS,	ACG_VALOR,	ACF_CODIGO

	FROM %table:ACF% ACF, %table:ACG% ACG, %table:SA1% SA1, %table:SU5% SU5
	WHERE	ACF_FILIAL	=	%xfilial:ACF%			AND
			ACG_FILIAL	=	%xfilial:ACG%			AND
			A1_FILIAL	=	%xfilial:SA1%			AND
			U5_FILIAL	=	%xfilial:SU5%			AND
			ACF_CLIENT	>=	%exp:mv_par01%			AND
			ACF_CLIENT	<=	%exp:mv_par03%			AND
			ACF_LOJA	>=	%exp:mv_par02%			AND
			ACF_LOJA	<=	%exp:mv_par04%			AND
			%exp:cQuery%
			ACF_CLIENT	=	A1_COD					AND
			ACF_LOJA	=	A1_LOJA					AND
			ACF_CODCON	=	U5_CODCONT				AND
			ACF_CODIGO	=	ACG_CODIGO				AND
			%exp:cQuery1%
			ACF.%notDel%							AND
			%exp:cQuery2%
			ACG.%notDel%							AND
			SA1.%notDel%							AND
			SU5.%notDel%
	ORDER BY %Order:ACF%
EndSql

//���������������������������������������������������������������������������Ŀ
//�Indica o fim da query, caso utilize range, deve-se informar como parametro �
//�{MV_?,MV_?} para que seja incluido no select automaticamente               �
//�����������������������������������������������������������������������������
END REPORT QUERY oSection1 //PARAM mv_par01,mv_par02

//�������������������������������������������������������������������������������������������Ŀ
//�Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao�
//���������������������������������������������������������������������������������������������
oSection2:SetParentQuery()
oSection2:SetParentFilter( { | cParam | (cAlias1)->ACF_CLIENT == cParam},{|| (cAlias1)->ACF_CLIENT } )
	
//�������������������������������������������Ŀ
//�Quebra a linha, caso existam muitas colunas�
//���������������������������������������������
oSection2:SetLineBreak()

//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TKR037RetVal�Autor  �Hanna             � Data �  27/06/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o valor para a celula de acordo com o status        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TMKR037                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static function TKR037RetVal( cAlias1, cStatus )
Local nRet	:= 0			// Retorno numerico da funcao

If (cAlias1)->ACG_STATUS == cStatus
	nRet	:= (cAlias1)->ACG_VALOR
Endif

Return nRet