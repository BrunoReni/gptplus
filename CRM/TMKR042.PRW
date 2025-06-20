#INCLUDE "TMKR042.CH"
#INCLUDE "REPORT.CH"
Static aOcorTot := {}			// Total de ocorrencias
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR042  � Autor � Marcos Daniel         � Data � 29/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ocorrencias de cobrancas                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Televendas                                                 ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Hanna C   �21/07/06�099212� Conversao para relatorio personalizavel    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR042()
Local oReport
Local aArea := GetArea()

//���������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                          �
//� Mv_Par01           // Do Operador                             �
//� Mv_Par02           // Ate o Operador                          �
//� Mv_Par03           // A Partir de                             �
//� Mv_Par04           // Ate o dia                               �
//� Mv_Par05           // Tipo            - Ativo ou Receptivo    �
//� Mv_Par06           // Codigo da ocorrencia                    �
//� Mv_Par07           // Relatorio       - Analitico ou Sintetico�
//�����������������������������������������������������������������
Pergunte("TMK042",.F.)

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
���Programa  �ReportDef �Autor  �Hanna               � Data �  30/06/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � TMKR042                                                       ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport				// Objeto do relatorio
Local oSection1				// Objeto da secao 1
Local oSection2				// Objeto da secao 2
Local oSection3				// Objeto da secao 2
Local cAlias1	:= "ACF"	// Pega o proximo Alias Disponivel


cAlias1		:= GetNextAlias()						// Pega o proximo Alias Disponivel

//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirma��o da geracao do relatorio�
//���������������������������������������������������������������������
// "Ocorr�ncias de cobran�a"
// "Este programa ira emitir uma relacao dos" # "atendimentos de cobranca separados por" # "ocorrencias."
DEFINE REPORT oReport NAME "TMKR042" TITLE STR0001 PARAMETER "TMK042" ACTION {|oReport| Tkr042PrtRpt( oReport, cAlias1 )} DESCRIPTION STR0002 + STR0003 + STR0004

//�����������������������������Ŀ
//�Define a secao1 do relatorio �
//�������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0022 TABLES "ACF","SU7" // "Operador"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������
DEFINE CELL NAME "ACF_OPERAD"	OF oSection1 ALIAS "ACF" SIZE TamSX3("ACF_OPERAD")[1]
DEFINE CELL NAME "U7_NOME"		OF oSection1 ALIAS "SU7" SIZE TamSX3("U7_NOME")[1]

//�����������������������������Ŀ
//�Define a secao2 do relatorio �
//�������������������������������
DEFINE SECTION oSection2 OF oSection1 TITLE STR0023 TABLES "ACF","SU9","SA1" // "Ocorr�ncias Registradas"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������
DEFINE CELL NAME "ACF_DATA"		OF oSection2 ALIAS "ACF" SIZE TamSX3("ACF_DATA")[1]
DEFINE CELL NAME "ACF_INICIO"	OF oSection2 ALIAS "ACF" SIZE TamSX3("ACF_INICIO")[1]
DEFINE CELL NAME "ACF_MOTIVO"	OF oSection2 ALIAS "ACF" SIZE TamSX3("ACF_MOTIVO")[1]
DEFINE CELL NAME "U9_DESC" 		OF oSection2 ALIAS "SU9" BLOCK {|| TKR042RetDes( cAlias1 ) } SIZE TamSX3("U9_DESC")[1]
DEFINE CELL NAME "A1_CGC" 		OF oSection2 ALIAS "SA1" SIZE TamSX3("A1_CGC")[1]
DEFINE CELL NAME "A1_TEL" 		OF oSection2 ALIAS "SA1" SIZE TamSX3("A1_TEL")[1]
DEFINE CELL NAME "A1_NOME" 		OF oSection2 ALIAS "SA1" SIZE TamSX3("A1_NOME")[1]
DEFINE CELL NAME "VALOR" 		OF oSection2 SIZE 10 PICTURE "@E 9,999,999.99" TITLE STR0020

//�����������������������������Ŀ
//�Define a secao3 do relatorio �
//�������������������������������
DEFINE SECTION oSection3 OF oSection1 TITLE STR0024 TABLES "ACF" // "Descri��o das ocorr�ncias"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������
DEFINE CELL NAME "DESCR"	OF oSection3 PICTURE "@!"			TITLE STR0021
DEFINE CELL NAME "QTD"		OF oSection3 PICTURE "999,999"		TITLE STR0018
DEFINE CELL NAME "NQTD"		OF oSection3 SIZE 30 PICTURE "@!"	TITLE STR0019

oSection2:SetTotalText(STR0012)
oSection2:SetTotalInLine(.F.)		// Imprime total em linha ou coluna (default .T. - linha )
DEFINE FUNCTION FROM oSection2:Cell("VALOR")	FUNCTION SUM TITLE STR0020
Return oReport
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TKR042PrtRpt�Autor  �Hanna               � Data �  21/07/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � TMKR042                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function TKR042PrtRpt( oReport, cAlias1 )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local oSection3 := oSection1:Section(2)				// Define que a secao 3 serah filha da secao 1
Local cQuery	:= "%"								// Variavel da cQuery
Local cArqTrb	:= ""								// Arquivo de trabalho
Local cAliasTrb	:= ""								// Tabela filtrada
Local cIndex 	:= ""								// Indice
Local nAuxFor	:= 0								// Variavel auxiliar do For... Next
Local cDbMs		:= ""								//Nome do BD              
Local cSelect	:= ""								//Campos a adicionar na query

DbSelectArea("ACF")
DbSetOrder(1)


MakeSqlExpr("TMK042")

//������������������������������
//�Valida o tipo de atendimento�
//������������������������������
If MV_PAR05 <> 3
	cQuery	+= "ACF_OPERA = '"	+ Alltrim(Str(Mv_Par05)) + "' AND "
Endif

If !Empty( MV_PAR06 )
	cQuery += " ACF_MOTIVO = '" + MV_PAR06 + "' AND "
Endif

cQuery += "%"


cDbMs	:= UPPER(TcGetDb())  //define o tipo de banco para diferenciar o operador de soma

If cDbMs $ "MSSQL"
	cSelect := "%	ACF_FILIAL	+	ACF_OPERAD	+	ACF_DATA	%"
Else
	cSelect := "%	ACF_FILIAL	||	ACF_OPERAD	||	ACF_DATA	%"
EndIf		  


//��������������������Ŀ
//�Inicializa a secao 1�
//����������������������
BEGIN REPORT QUERY oSection1

//��������������������������������������������������������Ŀ
//�Query utilizada para filtrar todos os dados necessarios �
//����������������������������������������������������������
BeginSql alias cAlias1
	SELECT	ACF_DATA,	ACF_INICIO,	ACF_MOTIVO,	ACF_OPERAD,	ACF_CLIENT,
			ACF_LOJA,	ACF_CODIGO,	A1_CGC,		A1_TEL,		A1_NOME
	FROM %table:ACF% ACF, %table:SA1% SA1, %table:SU7% SU7
	WHERE	ACF_FILIAL	=	%xfilial:ACF%			AND
			A1_FILIAL	=	%xfilial:SA1%			AND
			%exp:cQuery%
			ACF_OPERAD	>=	%exp:mv_par01%			AND
			ACF_OPERAD	<=	%exp:mv_par02%			AND
			ACF_DATA	>=	%exp:DTOS(mv_par03)%	AND
			ACF_DATA	<=	%exp:DTOS(mv_par04)%	AND
			ACF_OPERAD	=	U7_COD					AND
			ACF_CLIENT	=	A1_COD					AND
			ACF_LOJA	=	A1_LOJA
	ORDER BY  %exp:cSelect%
EndSql

END REPORT QUERY oSection1

//�������������������������������������������������������������������������������������������Ŀ
//�Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao�
//���������������������������������������������������������������������������������������������
oSection2:SetParentQuery()
oSection2:SetParentFilter( { | cParam | (cAlias1)->ACF_OPERAD == cParam},{|| (cAlias1)->ACF_OPERAD } )

//���������������������������������������Ŀ
//�Chama funcao para impressao - PrintLine�
//�����������������������������������������
TKR042Impres( oReport, cAlias1 )

//�����������������������������������������������������������������������������������Ŀ
//�Ordena e varre o array com o total das ocorrencias e imprime no final do relatorio �
//�������������������������������������������������������������������������������������
aSort( aOcorTot,,,{|x,y| x[1] < y[1] } )					// Crescente
If Len( aOcorTot ) > 0
	oSection3:Init()
	oSection3:Cell("DESCR"):Enable()						// habilita a celula para ser apresentada
	For nAuxFor := 1 to Len( aOcorTot )
		If nAuxFor == 1
			oSection3:Cell("DESCR"):SetValue( STR0021 )		// "Quantidade Total"
		Else
			oSection3:Cell("DESCR"):Hide()
		Endif
		oSection3:Cell("QTD"):SetValue( aOcorTot[nAuxFor][3] )
		oSection3:Cell("NQTD"):SetValue( aOcorTot[nAuxFor][2] )
		oSection3:PrintLine()
	Next nAuxFor
	oSection3:Finish()
Endif
aOcorTot := {}

Return
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TKR042RetDes�Autor  �Hanna               � Data �  24/07/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para retorno da descricao do SU9 se existir            ���
���������������������������������������������������������������������������͹��
���Uso       � TMKR042                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function TKR042RetDes( cAlias1 )
Local cRet	:= ""			// Retorno da funcao
Local aArea := GetArea()	// Grava a area utilizada para restaurar

DbSelectArea( "SU9" )
DbSetOrder(2)
If MsSeek( xFilial( "SU9" ) + (cAlias1)->ACF_MOTIVO )
	cRet	:= SU9->U9_DESC
Endif

//�������������������������������������������������������������Ŀ
//�Se nao existir ocorrencia, imprime "Ocorr�ncia n�o informada"�
//���������������������������������������������������������������
If Empty( cRet )
	cRet := STR0016			// "Ocorr�ncia n�o informada"
Endif

RestArea( aArea )
Return cRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TKR042Impres�Autor  �Hanna               � Data �  24/07/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio                            ���
���������������������������������������������������������������������������͹��
���Uso       � TMKR042                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function TKR042Impres( oReport, cAliasX )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local oSection3 := oSection1:Section(2)				// Define que a secao 3 serah filha da secao 1
Local aArea := GetArea()							// Grava a area utilizada para restaurar
Local cOperador	:= ""								// Variavel com o Operador utilizado para comparacao
Local nValACG	:= 0								// Variavel que calcula o valor do ACG
Local nPosOco	:= 0								// Posicao da ocorrencia no array
Local nAuxFor	:= 0								// Variavel auxiliar do For... Next
Local aOcorren	:= {}								// Array com as ocorrencias encontradas

//������������������������������������Ŀ
//�Deixa todos os arquivos posicionados�
//��������������������������������������
SU9->( DbSetOrder(2) )
SU9->( MsSeek( xFilial( "SU9" ) + (cAliasX)->ACF_MOTIVO ) )
	
SA1->( DbSetOrder(1) )
SA1->( MsSeek( xFilial( "SA1" ) + (cAliasX)->ACF_CLIENT + (cAliasX)->ACF_LOJA ) )
	
(cAliasX)->( DbGotop() )
While (cAliasX)->( !Eof() )
	
	//�������������������������������
	//�Imprime a secao 1 - Operador �
	//�������������������������������
	SU7->( DbSetOrder(1) )
	SU7->( MsSeek( xFilial( "SU7" ) + (cAliasX)->ACF_OPERAD ) )

	oSection1:Init()
	oSection1:PrintLine()
	cOperador:= (cAliasX)->ACF_OPERAD
	oSection2:Init()

	//��������������������������������������������Ŀ
	//�Enquanto for o mesmo operador mantem a secao�
	//����������������������������������������������
	While (cAliasX)->( !Eof() ) .AND. (cAliasX)->ACF_OPERAD == cOperador
		ACG->( DbSetOrder( 1 ) )
		ACG->( MsSeek( xFilial( "ACG" ) + (cAliasX)->ACF_CODIGO ) )

		//��������������������Ŀ
		//�Soma os itens do ACG�
		//����������������������
		While ACG->( !Eof() ) .AND. (cAliasX)->ACF_CODIGO == ACG->ACG_CODIGO
			nValACG	:= nValACG + ACG->ACG_VALOR
			ACG->( DbSkip() )
		End

		//������������������������������������������������Ŀ
		//�Verifica se encontra a ocorrencia no array.     �
		//�Para somar por ocorrencia no final de cada se��o�
		//��������������������������������������������������
		nPosOco := Ascan(aOcorren, {|x| x[1] == (cAliasX)->ACF_MOTIVO })

		If nPosOco == 0
			Aadd( aOcorren,{ (cAliasX)->ACF_MOTIVO, TKR042RetDes( cAliasX ), 1 } )
		Else
			aOcorren[nPosOco][3]	:= aOcorren[nPosOco][3] + 1
		Endif
		
		//��������������������������������������������Ŀ
		//�O valor total do ACG de cada item eh somado �
		//����������������������������������������������
		oSection2:Cell("VALOR"):SetValue( nValACG )
		nValACG	:= 0
		oReport:IncMeter()

		//�������������������������������������������������������������Ŀ
		//�Se for sintetico, esconde as celulas, senao imprime a secao 2�
		//���������������������������������������������������������������
		If MV_PAR07 == 1
			oSection2:Cell("ACF_DATA"):Disable()
			oSection2:Cell("ACF_INICIO"):Disable()
			oSection2:Cell("ACF_MOTIVO"):Disable()
			oSection2:Cell("U9_DESC"):Disable()
			oSection2:Cell("A1_CGC"):Disable()
			oSection2:Cell("A1_TEL"):Disable()
			oSection2:Cell("A1_NOME"):Disable()
			oSection2:Cell("VALOR"):Disable()
			oSection2:PrintLine()
		Else
			oSection2:PrintLine()
		Endif
		(cAliasX)->( DbSkip() )
	End
	oSection2:Finish()
		
	//���������������������������������������������������Ŀ
	//�Varre o array das ocorrencias e imprime na secao 3 �
	//�����������������������������������������������������
	aSort( aOcorren,,,{|x,y| x[1] < y[1] } )		// Crescente
	If Len( aOcorren ) > 0
		oSection3:Init()
		For nAuxFor := 1 to Len( aOcorren )
			oSection3:Cell("DESCR"):Disable()
			oSection3:Cell("QTD"):SetValue( aOcorren[nAuxFor][3] )
			oSection3:Cell("NQTD"):SetValue( aOcorren[nAuxFor][2] )
			oSection3:PrintLine()

			//�����������������������������������������������������������������������Ŀ
			//�Totaliza todas as ocorrencias, para ser impressa no final do relatorio �
			//�������������������������������������������������������������������������
			nPosOco := Ascan(aOcorTot, {|x| x[1] == aOcorren[nAuxFor][1] } )
			If nPosOco == 0
				Aadd( aOcorTot,{ aOcorren[nAuxFor][1], aOcorren[nAuxFor][2], aOcorren[nAuxFor][3] } )
			Else
				aOcorTot[nPosOco][3]	:= aOcorTot[nPosOco][3] + aOcorren[nAuxFor][3]
			Endif
		Next nAuxFor
		oSection3:Finish()
	Endif

	aOcorren := {}
	oSection1:Finish()
End
RestArea( aArea )
Return