#INCLUDE "TMSR330.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR330  � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Posicao de Veiculos                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR330()

Local oReport
Local aArea := GetArea()

//-- Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR330                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local aOrdem     := {}
Local cAliasQry  := GetNextAlias()

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:= TReport():New("TMSR330",STR0016,"TMR330", {|oReport| ReportPrint(oReport,cAliasQry)},STR0017) // "Relacao da Posicao de Veiculo" ### "Emite Relacao da Posicao de Veiculo conforme os parametros informados"
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)
Pergunte(oReport:uParam,.F.)
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
Aadd( aOrdem, STR0018 ) // "Veiculos"

oTipVei := TRSection():New(oReport,STR0019,{"DA3","DUT"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Tipo de Ve�culos"
oTipVei:SetTotalInLine(.F.)
oTipVei:SetTotalText(STR0035) // "Total Tipo de Ve�culos"
TRCell():New(oTipVei,"DA3_TIPVEI","DA3",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTipVei,"DUT_DESCRI","DUT",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oFroVei := TRSection():New(oTipVei,STR0020,{"DA3"},/*Array com as Ordens*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Tipo de Frota"
oFroVei:SetTotalInLine(.F.)
TRCell():New(oFroVei,"DA3_FROVEI","DA3",/*cTitle*/,/*Picture*/,10,/*lPixel*/,/*{|| code-block de impressao }*/)

oVeiculo := TRSection():New(oFroVei,STR0018,{"DA3","DTQ"},/*Array com as Ordens*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Ve�culos"
oVeiculo:SetTotalInLine(.F.)
oVeiculo:SetTotalText(STR0034) //"Total Frota"
TRCell():New(oVeiculo,"DA3_COD"   ,"DA3",STR0021,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // "Veiculo"   
TRCell():New(oVeiculo,"DA3_PLACA" ,"DA3",STR0022,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DA3_DESC"  ,"DA3",STR0023,/*Picture*/,25         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DA3_CAPACM","DA3",STR0024,/*Picture*/,10         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DTQ_FILORI","DTQ",STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DTQ_VIAGEM","DTQ",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DA3_STATUS","DA3",STR0027,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DA3_FILATU","DA3",STR0028,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TMR330Prv((cAliasQry)->DA3_FILVGA,(cAliasQry)->DA3_NUMVGA, (cAliasQry)->DA3_FILATU,(cAliasQry)->DA3_STATUS)[1] })
TRCell():New(oVeiculo,"DTQ_DATFEC","DTQ",STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DTQ_HORFEC","DTQ",STR0030,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DTW_DATPRE","DTW",STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TMR330Prv((cAliasQry)->DA3_FILVGA,(cAliasQry)->DA3_NUMVGA, (cAliasQry)->DA3_FILATU,(cAliasQry)->DA3_STATUS)[2] })
TRCell():New(oVeiculo,"DTW_HORPRE","DTW",STR0032,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TMR330Prv((cAliasQry)->DA3_FILVGA,(cAliasQry)->DA3_NUMVGA, (cAliasQry)->DA3_FILATU,(cAliasQry)->DA3_STATUS)[3] })
TRCell():New(oVeiculo,"DA4_NOME"  ,"DA4",STR0033,/*Picture*/,35         ,/*lPixel*/,/*{|| code-block de impressao }*/)

oTotaliz:=TRFunction():New(oVeiculo:Cell("DA3_COD"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || TMR330Sum((cAliasQry)->DA3_COD+'1') })

oTotaliz:=TRFunction():New(oVeiculo:Cell("DA3_COD"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/,oTipVei)
oTotaliz:SetCondition({ || TMR330Sum((cAliasQry)->DA3_COD+'2') })

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR330                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry,cAliasQry2)

Local cTipVei := ''
Local cFroVei := ''
Local cCodVei := ''
Local cQuery  := ''

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

cQuery :="%"
If mv_par03 <> 4
	cQuery += " AND DA3_FROVEI = '"  + StrZero(mv_par03,Len(DA3->DA3_FROVEI))+ "' "
EndIf
// Verifica se filtra pelo Status do Veiculo
If mv_par06 == 3
	cQuery += " AND (DA3_STATUS = '2' OR DA3_STATUS = '3') "
ElseIf  mv_par06 == 1
	cQuery += " AND DA3_STATUS = '2'  "
ElseIf  mv_par06 == 2
	cQuery += " AND DA3_STATUS = '3'  "
EndIf
cQuery +="%"

BeginSql Alias cAliasQry
	SELECT DA3_FILVGA, DA3_NUMVGA, DA3_TIPVEI, DA3_FROVEI, DA3_COD, DA3_PLACA,
	        DA3_DESC, DA3_CAPACM, DA3_STATUS, DA3_FILATU, DA4_NOME, DA3_FILIAL
		FROM %table:DA3% DA3
	   LEFT JOIN %table:DUP% DUP
	      ON DUP_FILIAL = %xFilial:DUP%
	      AND DUP_FILORI = DA3_FILVGA
	      AND DUP_VIAGEM = DA3_NUMVGA
	      AND DUP_CODVEI = DA3_COD
			AND DUP.%NotDel%	
		LEFT JOIN %table:DA4% DA4
	      ON DA4_FILIAL = %xFilial:DA4%
	      AND DA4_COD = DUP_CODMOT
			AND DA4.%NotDel%	
		WHERE DA3_FILIAL = %xFilial:DA3%
	  	  AND DA3_COD >= %Exp:mv_par01%
		  AND DA3_COD <= %Exp:mv_par02%
		  AND DA3_TIPVEI >= %Exp:mv_par04%
		  AND DA3_TIPVEI <= %Exp:mv_par05%
		  AND DA3.%NotDel%	
		  %Exp:cQuery%
		ORDER BY DA3_FILIAL, DA3_TIPVEI, DA3_FROVEI
EndSql 

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DA3->(LastRec()))

TRPosition():New(oReport:Section(1),"DUT",1,{|| xFilial("DUT")+(cAliasQry)->DA3_TIPVEI })
TRPosition():New(oReport:Section(1):Section(1):Section(1),"DTQ",2,{|| xFilial("DTQ")+(cAliasQry)->DA3_FILVGA+(cAliasQry)->DA3_NUMVGA })

//-- Utiliza a query do Pai
oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):Section(1):SetParentQuery()

DbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
		cTipVei := (cAliasQry)->DA3_TIPVEI
		oReport:Section(1):Init()
		oReport:Section(1):PrintLine()
		While !(cAliasQry)->(Eof()) .And. (cAliasQry)->DA3_TIPVEI == cTipVei
			cFroVei := (cAliasQry)->DA3_FROVEI
			cCodVei := ''
			oReport:Section(1):Section(1):Init()
			oReport:Section(1):Section(1):PrintLine()
			While !(cAliasQry)->(Eof()) .And. (cAliasQry)->DA3_TIPVEI == cTipVei .And. (cAliasQry)->DA3_FROVEI == cFroVei
				If cCodVei == (cAliasQry)->DA3_COD
					oReport:Section(1):Section(1):Section(1):Cell("DA3_COD"   ):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DA3_PLACA" ):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DA3_DESC"  ):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DA3_CAPACM"):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DTQ_FILORI"):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DTQ_VIAGEM"):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DA3_STATUS"):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DA3_FILATU"):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DTQ_DATFEC"):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DTQ_HORFEC"):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DTW_DATPRE"):Hide()
					oReport:Section(1):Section(1):Section(1):Cell("DTW_HORPRE"):Hide()
				Else
					oReport:Section(1):Section(1):Section(1):Cell("DA3_COD"   ):Show()
					oReport:Section(1):Section(1):Section(1):Cell("DA3_PLACA" ):Show()
					oReport:Section(1):Section(1):Section(1):Cell("DA3_DESC"  ):Show()
					oReport:Section(1):Section(1):Section(1):Cell("DA3_CAPACM"):Show()
					oReport:Section(1):Section(1):Section(1):Cell("DTQ_FILORI"):Show()
					oReport:Section(1):Section(1):Section(1):Cell("DTQ_VIAGEM"):Show()
					oReport:Section(1):Section(1):Section(1):Cell("DA3_STATUS"):Show()
					oReport:Section(1):Section(1):Section(1):Cell("DA3_FILATU"):Show()
					oReport:Section(1):Section(1):Section(1):Cell("DTQ_DATFEC"):Show()
					oReport:Section(1):Section(1):Section(1):Cell("DTQ_HORFEC"):Show()
					oReport:Section(1):Section(1):Section(1):Cell("DTW_DATPRE"):Show()
					oReport:Section(1):Section(1):Section(1):Cell("DTW_HORPRE"):Show()
				EndIf
				cCodVei := (cAliasQry)->DA3_COD
				oReport:Section(1):Section(1):Section(1):Init()
				oReport:Section(1):Section(1):Section(1):PrintLine()
				dbSelectArea(cAliasQry)
				dbSkip()
			EndDo
			oReport:Section(1):Section(1):Finish()
			oReport:Section(1):Section(1):Section(1):Finish()
		EndDo
		oReport:IncMeter()
		oReport:Section(1):Finish()
	EndDo
EndIf

//-- Zera a variavel
TMR330Sum(,.T.)

oReport:Section(1):SetPageBreak(.T.) 

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR330Vge � Autor �Eduardo de Souza       � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna dados da previsao de chegada                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Filial Viagem                                        ���
���          �ExpC2: Viagem                                               ���
���          �ExpC3: Filial Atual Veiculo                                 ���
���          �ExpC4: Status Veiculo                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR330                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR330Prv(cFilOri,cViagem,cFilAtu,cStatus)

Static cVge      := ''
Static aDados    := {}
Local cAtivChg   := SuperGetMV("MV_ATIVCHG")
Local cAliasQry2 := ''

//-- Qdo mudar a viagem devera zerar as variaveis
If cVge <> cFilOri+cViagem
	cVge   := cFilOri+cViagem
	aDados := {}
EndIf

If Empty(aDados)
	If cStatus == StrZero(2,Len(DA3->DA3_STATUS))
		Aadd( aDados, cFilAtu )
		Aadd( aDados, STOD('') )
		Aadd( aDados, '' )
	ElseIf cStatus == StrZero(3,Len(DA3->DA3_STATUS))
		cAliasQry2 := GetNextAlias()
		BeginSql Alias cAliasQry2
			SELECT DTW_FILATI, DTW_STATUS, DTW_DATPRE, DTW_HORPRE, DTW_FILIAL
			  FROM %table:DTW%
			  WHERE DTW_FILIAL = %xFilial:DTW%
			    AND DTW_FILORI = %Exp:cFilOri%
			    AND DTW_VIAGEM = %Exp:cViagem%
			    AND DTW_ATIVID = %Exp:cAtivChg%
			    AND %NotDel%
			ORDER BY DTW_FILIAL, DTW_SEQUEN DESC
		EndSql
		If (cAliasQry2)->(!Eof())
			Aadd( aDados, (cAliasQry2)->DTW_FILATI )
			Aadd( aDados, STOD((cAliasQry2)->DTW_DATPRE))
			Aadd( aDados, (cAliasQry2)->DTW_HORPRE )
			(cAliasQry2)->(DbSkip())
			While (cAliasQry2)->(!Eof())
				If (cAliasQry2)->DTW_STATUS == StrZero(1,Len(DTW_STATUS)) //-- Em Aberto
					aDados[1] := (cAliasQry2)->DTW_FILATI
					aDados[2] := (cAliasQry2)->DTW_DATPRE
					aDados[3] := (cAliasQry2)->DTW_HORPRE
				EndIf
				(cAliasQry2)->(DbSkip())
			EndDo
		Else
			Aadd( aDados, '' )
			Aadd( aDados, STOD('') )
			Aadd( aDados, '' )
		EndIf
		(cAliasQry2)->(DbCloseArea())
	EndIf
EndIf

Return aDados

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR330Sum � Autor �Eduardo de Souza       � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se devera ser somado a linha em questao            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Cod. Veiculo                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR330                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR330Sum(cCodVei,lZeraVar)
Static aCodVei := {}

Local lRet := .F.
Default lZeraVar := .F.

If lZeraVar
	aCodVei := {}
ElseIf Ascan( aCodVei, { |x| x == cCodVei } ) == 0
	Aadd( aCodVei, cCodVei )
	lRet := .T.
Endif

Return lRet