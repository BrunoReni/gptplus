#INCLUDE "ESTPgOn03.ch"
#include "protheus.ch"
#include "msgraphi.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ESTPgOn03� Autor � Nereu Humberto Junior � Data � 29/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta array para Painel de Gestao On-line Tipo 2           ���
���          � Quantidade em estoque                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ESTPgOn02()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �{{cCombo1,{cText1, cValor, nColorValor, bClick},{...},},    ���
���          �{cCombo2, {cText2, cValor, nColorValor, bClick},...}}       ���
���          �                                                            ���
���          �cCombo1 = Item da Selecao                                   ���
���          �cText1 = Texto da Coluna                                    ���
���          �cValor = Valor a ser exibido (string) ja com a picture aplic���
���          �nColorValor = Cor do Valor no Formato RGB (Opcional)        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAEST                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function  ESTPgOn03()

Local aRet      := {}
Local cPerg     := ""
Local cAliasSB2 := 'SB2'
Local nQtdAtu   := 0
Local nQtdFecha := 0
Local nQtdMovim := 0
Local lQuery    := .F.


//��ESTPGON03���������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01            // Produto                     (Range)   �
//� mv_par02            // Armazem                     (Range)   �
//� mv_par03            // Tipo                        (Range)   �
//� mv_par04            // Grupo                       (Range)   �
//����������������������������������������������������������������
cPerg := 'ESTPGONL03'

Pergunte(cPerg,.F.)
//������������������������������������������������������������Ŀ
//�Converte os parametros do tipo range, para um range cheio,  �
//�caso o conteudo do parametro esteja vazio                   �
//��������������������������������������������������������������
FullRange(cPerg)

dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SB2")
dbSetOrder(1)

	cAliasSB2 := GetNextAlias()	
	lQuery    := .T.
	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �
	//��������������������������������������������������������������������������
	MakeSqlExpr(cPerg)
	mv_par01 := '%'+mv_par01+'%'
	mv_par02 := '%'+mv_par02+'%'
	mv_par03 := '%'+mv_par03+'%'
	mv_par04 := '%'+mv_par04+'%'
	
	BeginSql Alias cAliasSB2

		SELECT SB2.B2_COD, SB2.B2_LOCAL, SUM(SB2.B2_QATU) QATU, SUM(SB2.B2_QFIM) QFIM

		FROM %table:SB2% SB2
		
		JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1% AND SB1.B1_COD = SB2.B2_COD AND SB1.%NotDel%

		WHERE SB2.B2_FILIAL = %xFilial:SB2%
   		      AND %Exp:mv_par01%
   		      AND %Exp:mv_par02%
   		      AND %Exp:mv_par03%
   		      AND %Exp:mv_par04%   		      
   		      AND SB2.%NotDel%
   		      
   		GROUP BY B2_COD, B2_LOCAL      

	EndSql


While (cAliasSB2)->(!Eof())
	
	If lQuery .Or. ( !lQuery .And. SB1->(MsSeek(xFilial("SB1")+(cAliasSB2)->B2_COD) .And. &mv_par03 .And. &mv_par04) )

		nQtdAtu   += IIF(lQuery,(cAliasSB2)->QATU,(cAliasSB2)->B2_QATU)
        nQtdFecha += IIF(lQuery,(cAliasSB2)->QFIM,(cAliasSB2)->B2_QFIM)
        nQtdMovim += CalcEst((cAliasSB2)->B2_COD, (cAliasSB2)->B2_LOCAL, dDataBase+1)[1]

	Endif	
	(cAliasSB2)->(dbSkip())
EndDo

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao tipo 2 - Padrao 1                    �
//��������������������������������������������������������������������������

Aadd( aRet, { STR0001 , { ; //"Atual"
		   	{ STR0002, AllTrim(Trans(nQtdAtu,PesqPictQt("B2_QATU"))),IIF(nQtdAtu > 0,CLR_BLUE,CLR_RED), /*{ || bClick }*/ } } }  ) //"Saldo Atual"

Aadd( aRet, { STR0003 , { ; //"Fechamento"
		   	{ STR0004, AllTrim(Trans(nQtdFecha,PesqPictQt("B2_QFIM"))),IIF(nQtdFecha > 0,CLR_BLUE,CLR_RED), /*{ || bClick }*/ } } }  ) //"Saldo Fechamento"

Aadd( aRet, { STR0005 , { ; //"Movimento"
		   	{ STR0006, AllTrim(Trans(nQtdMovim,PesqPictQt("B2_QFIM"))),IIF(nQtdMovim > 0,CLR_BLUE,CLR_RED), /*{ || bClick }*/ } } }  )		   			   	 //"Saldo Movimento"

dbSelectArea(cAliasSB2)
dbCloseArea()

dbSelectArea("SB2")
dbSetOrder(1)

Return aRet