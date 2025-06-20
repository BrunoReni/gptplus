#INCLUDE "TMKR041.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TMKR041  � Autor � Marcos Daniel         � Data � 29/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cobrancas pendentes que estao na carteira de cobrancas     ���
���          � de um Operador.                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � AP8                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR041()

Local oReport
Local aArea := GetArea()

//���������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                          �
//� Mv_Par01           // Da Filial                               �
//� Mv_Par02           // Ate a Filial                            �
//� Mv_Par03           // Do Grupo                                �
//� Mv_Par04           // Ate o Grupo                             �
//� Mv_Par05           // Do Operador                             �
//� Mv_Par06           // Ate o Operador                          �
//� Mv_Par07           // Tipo: 1-Interno; 2-Externo; 3-Ambos     �
//�����������������������������������������������������������������
Pergunte("TMK041",.F.)

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
���Programa  ReportDef �Autor  �Hanna               � Data �  30/06/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � TMKR041                                                       ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport				// Objeto do relatorio
Local oSection1				// Objeto da secao 1
Local oSection2				// Objeto da secao 2
Local oSection3				// Objeto da secao 2
Local oSection3x			// Objeto da secao 2.2
Local oBreak				// Objeto da secao 2
Local cAlias1	:= "ACG"	// Pega o proximo Alias Disponivel

cAlias1		:= GetNextAlias()						// Pega o proximo Alias Disponivel
	
//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirma��o da geracao do relatorio�
//���������������������������������������������������������������������

//"Pend�ncias agendadas para o Operador"
// "Este programa ir� emitir uma rela��o das " # "cobran�as pendentes que est�o na carteira " # "de cobran�a de um Operador."
DEFINE REPORT oReport NAME "TMKR041" TITLE STR0001 PARAMETER "TMK041" ACTION {|oReport| Tkr041PrtRpt( oReport, cAlias1 )} DESCRIPTION STR0002 + STR0003 + STR0003

//����������������������������������������������������Ŀ
//�Define a secao1 do relatorio, com quebra por filial �
//������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0022 TABLES "SM0" 	//"Quebra por Filial"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������
DEFINE CELL NAME "M0_CODFIL"	OF oSection1 TITLE STR0019 SIZE 2	BLOCK {|| TKR041RetEmp( cAlias1, "M0_CODFIL" ) }
DEFINE CELL NAME "M0_FILIAL"	OF oSection1 TITLE STR0020 SIZE 15	BLOCK {|| TKR041RetEmp( cAlias1, "M0_FILIAL" ) }

//���������������������������������������������������������������������������������������������������������Ŀ
//�Define a secao2 do relatorio, informando que o arquivo principal utlizado eh o SL3 e o complementar o SB1�
//�����������������������������������������������������������������������������������������������������������
DEFINE SECTION oSection2 OF oSection1 TITLE STR0023 TABLES "SU7" 	//"Operadores"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������
DEFINE CELL NAME "U7_COD"	OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_NOME"	OF oSection2 ALIAS "SU7"

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao2 (que sera filha da secao1)  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection3 OF oSection2 TITLE STR0024 TABLES "ACF","SA1","SU4","SU5","SU6","ACG"		//"Itens x Pendencia"
DEFINE SECTION oSection3x OF oSection3 TITLE STR0024 TABLES "ACF","SA1","SU4","SU5","SU6","ACG"		//"Itens x Pendencia"

DEFINE CELL NAME "A1_COD"		OF oSection3 ALIAS "SA1"
DEFINE CELL NAME "A1_LOJA"		OF oSection3 ALIAS "SA1"
DEFINE CELL NAME "A1_NOME"		OF oSection3 ALIAS "SA1"
DEFINE CELL NAME "A1_CGC"		OF oSection3 ALIAS "SA1" SIZE 20
DEFINE CELL NAME "ACG_VALOR"	OF oSection3 ALIAS "ACG"
DEFINE CELL NAME "U4_DATA"		OF oSection3 ALIAS "SU4"
DEFINE CELL NAME "ACF_PENDEN"	OF oSection3 ALIAS "ACF"
DEFINE CELL NAME "ACF_HRPEND"	OF oSection3 ALIAS "ACF"
DEFINE CELL NAME "U5_CONTAT"	OF oSection3 ALIAS "SU5"
DEFINE CELL NAME "U6_CODLIG"	OF oSection3x ALIAS "SU6"
DEFINE CELL NAME "ACF_DATA"		OF oSection3x ALIAS "ACF"
DEFINE CELL NAME "ACF_OPERA"	OF oSection3x ALIAS "ACF"

oSection3:SetTotalText("")
DEFINE FUNCTION FROM oSection3:Cell("ACG_VALOR") FUNCTION SUM TITLE STR0013 NO END SECTION

DEFINE BREAK oBreak OF oSection1 WHEN oSection3:Cell("ACG_VALOR")
oBreak:SetTotalInLine(.T.)		// Imprime total em linha ou coluna (default .T. - linha )
DEFINE FUNCTION FROM oSection3:Cell("ACG_VALOR") FUNCTION SUM BREAK oBreak NO END SECTION NO END REPORT TITLE STR0018

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TKR041PrtRpt�Autor  �Hanna               � Data �  30/06/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � TMKR041                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function TKR041PrtRpt( oReport, cAlias1 )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local oSection3 := oSection2:Section(1)				// Define que a secao 3 serah filha da secao 2
Local oSection3x := oSection3:Section(1)			// Define que a secao 3x ser� filha da secao 3
Local cFiltro	:= ""								// Variavel utilizada para o filtro
Local cQuery	:= "%%"								// Variavel da cQuery
Local cQuery1	:= "%%"								// Variavel da cQuery1
Local nTotSec3	:= 0								// Total da Secao 3
Local aFilial	:= {}								// Vetor com todas as filiais selecionadas no SX1
Local nPosFil	:= 1								// Posicao da filial no vetor
Local lExclu	:= FWModeAccess("ACF",3) == "E"		// Verifica se eh exclusivo o ACF
Local cAlias2	:= ""								// Quando for Codebase, utiliza arquivo temporario
Local aTam		:= {}								// Estrutura do arquivo temporario
Local nAuxFor	:= 0								// Contador para o For... Next
Local cFilACF	:= ""								// Filial do ACF
Local aCampos	:= {}								// Vetor com os campos do arquivo de trabalho
Local cDbMs		:= ""								//Nome do BD              
Local cSelect	:= ""								//Campos a adicionar na query

//�����������������������������������������������������Ŀ
//�Abre o arquivo de telecobranca pelo indice do cliente�
//�������������������������������������������������������
DbSelectArea("SU7")
DbSetOrder(1)

//����������������������������������������������������Ŀ
//�Valida as filiais de acordo com os parametros do SX1�
//������������������������������������������������������
DbSelectArea("SM0")
DbGotop()
While !Eof()
	If M0_CODIGO <> cEmpAnt .OR. FWGETCODFILIAL < MV_PAR01 .OR. FWGETCODFILIAL > MV_PAR02
		DbSkip()
		Loop
	Endif
	Aadd(aFilial,{M0_CODIGO, FWGETCODFILIAL, M0_FILIAL})
	DbSkip()
End

MakeSqlExpr("TMK041")

//������������������������������
//�Valida o tipo de atendimento�
//������������������������������
If MV_PAR07 <> 3
	cQuery	:= "%U0_TIPOIE		=	'"	+ Alltrim(Str(Mv_Par07)) + "' AND %"
Endif

//�����������������������������������������������������������������������������������������������Ŀ
//�Imprime apenas as pendencias de Cobranca que estao ativas e que sejam originadas por Pendencias�
//�������������������������������������������������������������������������������������������������

cDbMs	:= UPPER(TcGetDb())  //define o tipo de banco para diferenciar o operador de soma

If cDbMs $ "MSSQL"
	cSelect := "%	A1_COD+A1_LOJA	%"
Else
	cSelect := "%	A1_COD||A1_LOJA	%"
EndIf		

cQuery1	:= "% (U4_STATUS = '1' AND U4_TIPO = '2' AND U4_FORMA = '5') %"  	

//��������������������Ŀ
//�Inicializa a secao 1�
//����������������������
BEGIN REPORT QUERY oSection1

//��������������������������������������������������������Ŀ
//�Query utilizada para filtrar todos os dados necessarios �
//����������������������������������������������������������
BeginSql alias cAlias1
	SELECT	A1_FILIAL,	A1_NOME,	A1_CGC,	
			U4_FILIAL,	U4_DATA,	U4_LISTA,
			U5_FILIAL,	U5_CODCONT,	U5_CONTAT,
			U6_FILIAL,	U6_CODENT,	U6_CODLIG, 	
			U7_FILIAL,	U7_POSTO,	U7_COD,		U7_NOME,
			ACG_FILIAL,	ACG_VALOR,
			ACF_FILIAL,	ACF_PENDEN,	ACF_HRPEND,	ACF_DATA,	ACF_OPERA,	ACF_CODIGO

	FROM %table:SU7% SU7, %table:SU0% SU0, %table:SU4% SU4, %table:SU6% SU6, %table:SA1% SA1, %table:ACF% ACF, %table:SU5% SU5, %table:ACG% ACG
	WHERE	U7_FILIAL	=	%xfilial:SU7%			AND
			%exp:cQuery%
			U7_POSTO	=	U0_CODIGO				AND
			%exp:cQuery1%							AND
			U7_COD		=	U4_OPERAD				AND
			U4_LISTA	=	U6_LISTA				AND
			ACF_CODIGO	=	U6_CODLIG				AND
			ACF_CODCON	=	U5_CODCONT				AND
			ACF_CODIGO	=	ACG_CODIGO				AND
			ACF_FILIAL	=	ACG_FILIAL				AND
			U7_POSTO	>=	%exp:mv_par03%			AND
			U7_POSTO	<=	%exp:mv_par04%			AND
			U7_COD		>=	%exp:mv_par05%			AND
			U7_COD		<=	%exp:mv_par06%			AND
			U6_CODENT	=	%exp:cSelect%	        AND
			ACF.%notDel%							AND
			ACG.%notDel%							AND
			SU7.%notDel%							AND
			SU0.%notDel%							AND
			SU4.%notDel%							AND
			SU6.%notDel%							AND
			SU5.%notDel%							AND
			SA1.%notDel%

	ORDER BY ACF_FILIAL, U6_CODLIG
EndSql                     

END REPORT QUERY oSection1

//���������������������������������������������������Ŀ
//�Controla a impressao do arquivo gerado pelo SELECT �
//�����������������������������������������������������
(cAlias1)->( DbGotop() )
While (cAlias1)->( !EOF() )
	//�������������������������������������������������Ŀ
	//�Se nao for compartilhado o ACF, quebra por filial�
	//���������������������������������������������������
	If lExclu .OR. !Empty( (cAlias1)->ACF_FILIAL )
		nPosFil	:= Ascan(aFilial, {|x| x[2] == (cAlias1)->ACF_FILIAL })
		If nPosFil == 0
			(cAlias1)->( DbSkip() )
			Loop
		Else
			DbSelectArea("SM0")
			DbSetOrder(1)
			MsSeek( aFilial[nPosFil][1] + aFilial[nPosFil][2] )
		Endif
	Endif

	If Len( aFilial ) == 0
		Exit
	Endif
	
	//�������������������������������������Ŀ
	//�Inicia e imprime o conteudo da Secao1�
	//���������������������������������������
	oSection1:Init()
	oSection1:PrintLine()

	//������������������������������������������
	//�Varre o ACF enquanto for da mesma filial�
	//������������������������������������������
	While (cAlias1)->( !EOF() ) .AND. ;
		  ( ( aFilial[nPosFil][2] == (cAlias1)->ACF_FILIAL ) .OR. Empty( (cAlias1)->ACF_FILIAL ) )
			  
		cCodLig	:= (cAlias1)->U6_CODLIG

		//���������������������Ŀ
		//�Posiciona nas tabelas�
		//�����������������������
		SU7->( DbSetOrder(1) )
		SU7->( MsSeek( (cAlias1)->U7_FILIAL + (cAlias1)->U7_COD ))

		SU4->( DbSetOrder(5) )
		SU4->( MsSeek( (cAlias1)->U4_FILIAL + (cAlias1)->U4_LISTA ))

		SU5->( DbSetOrder(1) )
		SU5->( MsSeek( (cAlias1)->U5_FILIAL + (cAlias1)->U5_CODCONT ))

		SU6->( DbSetOrder(1) )
		SU6->( MsSeek( (cAlias1)->U6_FILIAL + (cAlias1)->U4_LISTA ))

		SA1->( DbSetOrder(1) )
		SA1->( MsSeek( (cAlias1)->A1_FILIAL + (cAlias1)->U6_CODENT ))

		ACF->( DbSetOrder(1) )
		ACF->( MsSeek( (cAlias1)->ACF_FILIAL + (cAlias1)->ACF_CODIGO ))

		ACG->( DbSetOrder(1) )
		ACG->( MsSeek( (cAlias1)->ACG_FILIAL + (cAlias1)->ACF_CODIGO ))

		//���������������������������������������������������Ŀ
		//�Gera a barra de processamento. Inicia a Secao 2 e 3�
		//�����������������������������������������������������
		oReport:IncMeter()

		oSection2:Init()
		oSection2:PrintLine()
	
		oSection3:Init()

		//���������������������������������������������������������������������Ŀ
		//�Soma os valores do ACG, pois na celula eh somente apresentado o total�
		//�����������������������������������������������������������������������
		While (cAlias1)->( !EOF() ) .AND. cCodLig	== (cAlias1)->U6_CODLIG
				nTotSec3	:= nTotSec3 + (cAlias1)->ACG_VALOR
			(cAlias1)->( DbSkip() )
		End

		oSection3:Cell("A1_CGC"):SetPicture(IIf(RetPessoa(SA1->A1_CGC) == "J","@R 99.999.999/9999-99","@R 999.999.999-99"))

		//������������������������������������������������������������
		//�Coloca o valor total do ACG na celula e finaliza as secoes�
		//������������������������������������������������������������
		oSection3:Cell("ACG_VALOR"):SetValue( nTotSec3 )
		nTotSec3 := 0
		oSection3:PrintLine()

		oSection3x:Init()
		oSection3x:PrintLine()

		oSection3x:Finish()
		oSection3:Finish()
		oSection2:Finish()
	End
	oSection1:Finish()		
End

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TKR041RetEmp�Autor  �Hanna Caroline    � Data �  10/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para retornar a empresa que esta sendo processada    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TMKR041                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TKR041RetEmp( cAlias1, cCampo )
Local cCmpFil	:= ""

DbSelectArea("SM0")
DbSetOrder(1)


cCmpFil	:= (cAlias1)->ACF_FILIAL

If !MsSeek( cEmpAnt + cCmpFil )
	If cCampo == M0_FILIAL .AND. Empty( cCmpFil )
		cCampo := "M0_NOME"
	Endif
Endif

Return &(cCampo)
