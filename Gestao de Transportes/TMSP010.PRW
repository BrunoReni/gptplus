#DEFINE QTDCTRC 	2
#DEFINE PESO 		3
#DEFINE VALFAT 		4
#DEFINE VALMER 		5

#include "protheus.ch"
#include "tmsp010.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSP010  � Autor � Rodolfo K. Rosseto    � Data �11.01.07  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - Analise de Clientes                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGATMS                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSP010()

Local aInfo     := {}
Local aInfAux   := {}
Local nCnt      := 0
Local cMsg      := ""

aInfAux := TMSGerQry() //--Funcao para alimentar o array

cMsg := "'"+STR0005+"'+chr(13)+chr(10)+" //"Este calculo e basedo na somatoria de Peso, Valor de Mercadoria, Quantidade"
cMsg += "'"+STR0006+"'+chr(13)+chr(10)+" //"de CTRC e Valor Faturado dos documentos de acordo com o cliente e periodo"
cMsg += "'"+STR0007+"'" //"escolhido."

/*
����������������������������������������������������������Ŀ
� Estrutura do Array aInfAux :                             �
� aInfAux[1] - Nome do Cliente                             �
� aInfAux[2] - Quantidade de CTRC                          �
� aInfAux[3] - Peso da Mercadoria                          �
� aInfAux[4] - Valor Faturado                              �
� aInfAux[5] - Valor da Mercadoria                         �
������������������������������������������������������������
����������������������������������������������������������Ŀ
� Este Array contem as somatorias vindas da query para     �
� exibir no Painel                                         �
������������������������������������������������������������
*/
//-- Tratamento para tabela de Documentos de Transporte (DT6) sem dados.
If Len(aInfAux) == 0
	Aadd(aInfAux ,{STR0008,,,,}) //'N�o h� dados para exibir'
EndIf

aSort(aInfAux,,,{|x,y| x[PESO] > y[PESO] }) //--Ordena pelo peso - aInfAux[3]
Aadd(aInfo, { STR0001 } ) //--Peso
Aadd(aInfo[Len(aInfo)] , {} )
For nCnt := 1 To Len(aInfAux)
	Aadd(aInfo[Len(aInfo)][2] , { aInfAux[nCnt,1] , Transform(aInfAux[nCnt,PESO],"@E 999,999,999.9999") , CLR_BLUE, "{ || MsgInfo("+cMsg+") }" } )
Next nCnt

aSort(aInfAux,,,{|x,y| x[QTDCTRC] > y[QTDCTRC] }) //--Ordena pela Qtd. de CTRC - aInfAux[2]
Aadd(aInfo, { STR0002 } ) //--"Qtd.CTRC"
Aadd(aInfo[Len(aInfo)] , {} )
For nCnt := 1 To Len(aInfAux)
	Aadd(aInfo[Len(aInfo)][2] , { aInfAux[nCnt,1] , Transform(aInfAux[nCnt,QTDCTRC],"99999") , CLR_BLUE, "{ || MsgInfo("+cMsg+") }" } )
Next nCnt

aSort(aInfAux,,,{|x,y| x[VALFAT] > y[VALFAT] }) //--Ordena pelo Valor Faturado - aInfAux[4]
Aadd(aInfo, { STR0003 } ) //--"Val.Fat."
Aadd(aInfo[Len(aInfo)] , {} )
For nCnt := 1 To Len(aInfAux)
	Aadd(aInfo[Len(aInfo)][2] , { aInfAux[nCnt,1] , Transform(aInfAux[nCnt,VALFAT],"@E 99,999,999,999.99") , CLR_BLUE, "{ || MsgInfo("+cMsg+") }" } )
Next nCnt

aSort(aInfAux,,,{|x,y| x[VALMER] > y[VALMER] }) //--Ordena pelo Valor da Mercadoria - aInfAux[5]
Aadd(aInfo, { STR0004 } ) //--"Val.Merc."
Aadd(aInfo[Len(aInfo)] , {} )
For nCnt := 1 To Len(aInfAux)
	Aadd(aInfo[Len(aInfo)][2] , { aInfAux[nCnt,1] , Transform(aInfAux[nCnt,VALMER],"@E 99,999,999,999.99") , CLR_BLUE, "{ || MsgInfo("+cMsg+") }" } )
Next nCnt

Return aInfo

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSGerQry � Autor � Rodolfo K. Rosseto    � Data �11.01.07  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera a Query que sera exibida pelo Painel de Gestao        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGATMS                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function TMSGerQry()

Local cAliasQry := GetNextAlias()
Local aInfAux   := {}
Local cWhere    := ""
Local cPerg     := "TMSP010"

Pergunte(cPerg,.F.)

//Tratamento na primeira chamada do Painel, caso o pergunte esteja vazio
//carregamos a data atual do sistema para evitar um periodo muito grande na query
If Empty(mv_par05)
	mv_par05 := Dtoc(dDataBase) + '-' + Dtoc(dDataBase)
EndIf

MakeSqlExpr(cPerg)

cWhere := '%' +mv_par05+ '%'

BeginSql Alias cAliasQry

	SELECT MAX(A1_NOME) A1_NOME, COUNT(DT6_FILDOC) CTRC, SUM(DT6_PESO) DT6_PESO,
	SUM(DT6_VALFAT) DT6_VALFAT, SUM(DT6_VALMER) DT6_VALMER

	FROM %table:DT6% DT6

	JOIN %table:SA1% SA1 ON
		A1_FILIAL = %xFilial:SA1%
		AND A1_COD = DT6_CLIDEV
		AND A1_LOJA = DT6_LOJDEV
		AND SA1.%NotDel%

	WHERE DT6_FILIAL = %xFilial:DT6%
		AND DT6_CLIDEV BETWEEN %Exp:mv_par01% AND %Exp:mv_par03%
		AND DT6_LOJDEV BETWEEN %Exp:mv_par02% AND %Exp:mv_par04%
		AND DT6_DOCTMS NOT IN (%Exp:StrZero(1,Len(DT6->DT6_DOCTMS))%,%Exp:StrZero(4,Len(DT6->DT6_DOCTMS))%)
		AND %Exp:cWhere%
		AND DT6.%NotDel%

	GROUP BY DT6_CLIDEV,DT6_LOJDEV

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aInfAux ,{ (cAliasQry)->A1_NOME,(cAliasQry)->CTRC,(cAliasQry)->DT6_PESO,(cAliasQry)->DT6_VALFAT,(cAliasQry)->DT6_VALMER } )
		(cAliasQry)->(DbSkip())
	EndDo
EndIf
(cAliasQry)->(DbCloseArea())

Return aInfAux