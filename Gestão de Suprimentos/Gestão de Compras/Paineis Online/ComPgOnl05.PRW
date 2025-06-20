#INCLUDE "Protheus.ch"
#INCLUDE "MSgraphi.ch"
#INCLUDE "ComPgOnl05.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ComPgOnl05�Autor  �Alexandre Inacio Lemes �Data  �06/02/2007���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta array para Painel de Gestao On-line Tipo\Padrao 2.2: ���
���          � Pedidos de Compras em aberto                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ComPgOnl05(nTipo)1 = Pedido Compras  2 = Autorizacao Entrega���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {cTypeGraf,{cTitleG,bClickG,aEixoX,aEixoY},        ���
���          � {cTitleT,bClickT,aTabela}}                                 ���
���          � cTypeGraph = Tipo do grafico                       		  ���
���          � cTitleG    = Titulo do grafico                      		  ���
���          � bClickG    = Bloco de codigo executado no click do grafico ���
���          � aEixoX     = Atributos do eixo X                           ���
���          � aEixoY     = Atributos do eixo Y                           ���
���          � cTitleT    = Titulo da tabela                              ���
���          � bClickT    = Bloco de codigo executado no click da tabela  ���
���          � aTabela    = Array multidimensional contendo os array por  ���
���          � filtro, no formato{"filtro",aCabec,aValores}               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGACOM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ComPgOnl05(oObj,nTipo)

Local aTitle    := {} 
Local aTipoSC7  := {}
Local aQtdSC7   := {}
Local aSC7Open  := {}
Local aSC7Parc  := {}
Local aSC7Bloq  := {}
Local aPanel    := {}
Local aTable    := {}

Local cAliasSC7 := "SC7"
Local cWhere    := ""
Local cCondicao := ""
Local cIndSC7	:= ""
Local cNumSC7   := ""
Local cFilEntr  := ""
Local cPerg     := ""         
Local dEmissao  := dDataBase
Local dEntrega  := dDataBase

Local nOrderSC7 := 0
Local lQuery    := .F.
Local lOpen     := .F.
Local lParcial  := .F.
Local lBloqued  := .F.

DEFAULT nTipo := 1

aTitle := {Iif(nTipo == 1,STR0001,STR0002),STR0003,STR0004,STR0005,STR0006}  //"Pedido"###"Autoriza��o de Entrega"###"Fornecedor"###"Data Emiss�o"###"Data Entrega"###"Filial de Entrega"

If nTipo == 1 
	cPerg := "COMPGONL05" 
else
	cPerg := "COMPGONL06" 
EndIf

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//�                                                              �
//� mv_par01            // Produto                     (Range)   �
//� mv_par02            // Fornecedor                  (Range)   �
//� mv_par03            // Loja                        (Range)   �
//� mv_par04            // Data de Emissao             (Range)   �
//� mv_par05            // Data de Entrega             (Range)   �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)
FullRange(cPerg)

dbSelectArea("SA2")
dbSetOrder(1)

dbSelectArea("SC7")
dbSetOrder(1)

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �	
//��������������������������������������������������������������������������
MakeSqlExpr(cPerg)
mv_par01 := '%'+mv_par01+'%'
mv_par02 := '%'+mv_par02+'%'
mv_par03 := '%'+mv_par03+'%'
mv_par04 := '%'+mv_par04+'%'
mv_par05 := '%'+mv_par05+'%'

    lQuery    := .T.
cAliasSC7 := GetNextAlias()	

cWhere :="%"
cWhere += " (C7_QUANT - C7_QUJE) > 0 AND C7_RESIDUO = ' ' "	
 
    If nTipo == 1
	cWhere += " AND C7_TIPO = 1 "		
    Else
	cWhere += " AND C7_TIPO = 2 "		    
    EndIf 

cWhere +="%"	

BeginSql Alias cAliasSC7

SELECT SC7.* , SC7.R_E_C_N_O_ SC7RecNo 

FROM %table:SC7% SC7

WHERE SC7.C7_FILIAL = %xFilial:SC7%  
AND %Exp:cWhere%
AND SC7.%NotDel% 
AND %Exp:mv_par01%
AND %Exp:mv_par02%
AND %Exp:mv_par03%
AND %Exp:mv_par04%
AND %Exp:mv_par05%
		  
ORDER BY %Order:SC7% 
		
EndSql 
	
dbSelectArea(cAliasSC7)

cNumSC7  := (cAliasSC7)->C7_NUM 
cFilEntr := (cAliasSC7)->C7_FILENT
dEmissao := STOD((cAliasSC7)->C7_EMISSAO)
dEntrega := STOD((cAliasSC7)->C7_DATPRF)

Do While (cAliasSC7)->(!Eof()) .And. (cAliasSC7)->C7_FILIAL = xFilial("SC7")
	
	SA2->(dbSetOrder(1))
	SA2->(dbSeek( xFilial("SA2") + (cAliasSC7)->C7_FORNECE + (cAliasSC7)->C7_LOJA ))
			
	//������������������������������������������������������������������������������������������������������Ŀ
	//�Identifica se o PC esta em aberto, sendo que nao deve existir nenhum item do PC parcialmente atendido �	
	//��������������������������������������������������������������������������������������������������������
	If (cAliasSC7)->C7_QUJE == 0 .And. (cAliasSC7)->C7_CONAPRO <> "B" .And. lParcial == .F.
        lOpen    := .T.	
	EndIf
	//������������������������������������������������������������������������������������������������������Ŀ
	//�Se exitir um item do PC parcialmente atendido ou atendido o PC sera considerado parcialmente atendido �	
	//��������������������������������������������������������������������������������������������������������	
	If (cAliasSC7)->C7_QUJE > 0 .And. (cAliasSC7)->C7_CONAPRO <> "B"
        lOpen    := .F.	
        lParcial := .T.    
    EndIf
	//������������������������������������������������������������������������������������������������������Ŀ
	//�Se o PC estiver Bloqueado independente do atendimento ser� considerado Aguardando liberacao.          �	
	//��������������������������������������������������������������������������������������������������������	    
	If (cAliasSC7)->C7_CONAPRO == "B"
        lBloqued := .T.
	EndIf

	(cAliasSC7)->(dbSkip())

    If (cAliasSC7)->C7_NUM <> cNumSC7 .Or. (cAliasSC7)->(Eof())

	    If lOpen
			Aadd(aSC7Open,{cNumSC7,SA2->A2_NOME,dEmissao,dEntrega,cFilEntr })          
		ElseIf lParcial
	 		Aadd(aSC7Parc,{cNumSC7,SA2->A2_NOME,dEmissao,dEntrega,cFilEntr })          
	    ElseIf lBloqued
			Aadd(aSC7Bloq,{cNumSC7,SA2->A2_NOME,dEmissao,dEntrega,cFilEntr })          
	    EndIf

		//��������������������������������������������������������������������������������������������������Ŀ
		//�Apos a Classificacao do PC alimenta as variaveis para avaliacao do proximo PC a ser classificado. �	
		//����������������������������������������������������������������������������������������������������	    
		cNumSC7  := (cAliasSC7)->C7_NUM 
		cFilEntr := (cAliasSC7)->C7_FILENT
		dEmissao := STOD((cAliasSC7)->C7_EMISSAO)
		dEntrega := STOD((cAliasSC7)->C7_DATPRF)
		
        lOpen    := .F.
        lParcial := .F.
        lBloqued := .F.

    EndIf
     
EndDo

If !Empty(aSC7Open)
	Aadd(aTipoSC7,STR0007)  //"N�o Atendidos"
	Aadd(aTable , {aTipoSC7[Len(aTipoSC7)] , aTitle , aSC7Open})
	Aadd(aQtdSC7,Len(aSC7Open))  
EndIf

If !Empty(aSC7Parc)
	Aadd(aTipoSC7,STR0008)  //"Parcialmente Atendidos"
	Aadd(aTable , {aTipoSC7[Len(aTipoSC7)] , aTitle , aSC7Parc})
	Aadd(aQtdSC7,Len(aSC7Parc))  
EndIf

If !Empty(aSC7Bloq)
	Aadd(aTipoSC7, STR0009)  //"Aguardando Libera��o"
	Aadd(aTable , {aTipoSC7[Len(aTipoSC7)] , aTitle , aSC7Bloq})
	Aadd(aQtdSC7,Len(aSC7Bloq))
EndIf

If Empty(aSC7Open) .And. Empty(aSC7Parc) .And. Empty(aSC7Bloq)
	Aadd(aTipoSC7, STR0014) //"Nao foram encotrados Pedidos de Compras em Aberto"
	Aadd(aTable , {aTipoSC7[Len(aTipoSC7)] , aTitle , {{" "," "," "," "," "}} })
	Aadd(aQtdSC7,1)
EndIf

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aPanel:= {GRP_PIE, { Iif( nTipo == 1 ,STR0010,STR0011) ,/*bClickG*/,aTipoSC7,aQtdSC7}, ;  //"Numero de Pedidos em Aberto"###"Autoriza��es de Entrega em Aberto"
{Iif( nTipo == 1 ,STR0012,STR0013),{ |x| COMPView05( x[1] ) },aTable}} //"Pedidos de Compras"###"Autoriza��es de Entrega"
			
//�������������������������������������������������������������������������������������Ŀ
//� Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
//���������������������������������������������������������������������������������������
If lQuery
	dbSelectArea(cAliasSC7)
	dbCloseArea()
Else
  	dbSelectArea("SC7") 
	RetIndex("SC7") 
	dbClearFilter()
	Ferase(cIndSC7+OrdBagExt())
EndIf

Return aPanel 

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �COMPView05� Autor �Alexandre Inacio Lemes � Data � 06/02/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Consulta os documentos de Pedido de Compras                   ���
���������������������������������������������������������������������������Ĵ��
���Uso       � ComPgOnl05                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function COMPView05(cPedido)

Local aArea := GetArea()

dbSelectArea("SC7")
dbSetOrder(1)
If MsSeek(xFilial("SC7")+Substr(cPedido,1,len(SC7->C7_NUM)))
//	Mata120(NIL,NIL,NIL,2) // Aguardando Depto de tecnologia para definicao das regras para chamadas dos programas. 06/02/2007 
EndIf

RestArea(aArea)

Return
