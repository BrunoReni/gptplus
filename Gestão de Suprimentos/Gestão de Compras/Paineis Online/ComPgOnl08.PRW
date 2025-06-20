#INCLUDE "Protheus.ch"
#INCLUDE "MSgraphi.ch"
#INCLUDE "ComPgOnl08.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ComPgOnl08�Autor  �Alexandre Inacio Lemes �Data  �06/02/2007���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta array para Painel de Gestao On-line Tipo\Padrao 2.2: ���
���          � Cotacoes de Compras em Aberto                              ���
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
Function ComPgOnl08()

Local aTitle    := {STR0001,STR0002} //"Cota��o"###"Data Emissao"
Local aTipoSC8  := {}
Local aQtdSC8   := {}
Local aSC8Open  := {}
Local aSC8Parc  := {}
Local aSC8Bloq  := {}
Local aPanel    := {}
Local aTable    := {}

Local cAliasSC8 := "SC8"
Local cWhere    := ""
Local cCondicao := ""
Local cIndSC8	:= ""
Local cNumSC8   := ""
Local cPerg     := "COMPGONL08"         
Local dEmissao  := dDataBase

Local nOrderSC8 := 0
Local lQuery    := .F.
Local lOpen     := .F.
Local lAnalise  := .F.

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//�                                                              �
//� mv_par01            // Produto                     (Range)   �
//� mv_par02            // Fornecedor                  (Range)   �
//� mv_par03            // Loja                        (Range)   �
//� mv_par04            // Proposta                    (Range)   �
//� mv_par05            // Data de Emissao             (Range)   �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)
FullRange(cPerg)

dbSelectArea("SC8")
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
cAliasSC8 := GetNextAlias()	

cWhere :="%"
cWhere += " C8_NUMPED = ' ' "	
cWhere +="%"	

BeginSql Alias cAliasSC8

SELECT SC8.* , SC8.R_E_C_N_O_ SC8RecNo 

FROM %table:SC8% SC8

WHERE SC8.C8_FILIAL = %xFilial:SC8%  
AND %Exp:cWhere%
AND SC8.%NotDel% 
AND %Exp:mv_par01%
AND %Exp:mv_par02%
AND %Exp:mv_par03%
AND %Exp:mv_par04%
AND %Exp:mv_par05%
		  
ORDER BY %Order:SC8% 
		
EndSql 

dbSelectArea(cAliasSC8)

cNumSC8   := (cAliasSC8)->C8_NUM 
dEmissao  := STOD((cAliasSC8)->C8_EMISSAO)

Do While (cAliasSC8)->(!Eof()) .And. (cAliasSC8)->C8_FILIAL = xFilial("SC8")

	//������������������������������������������������������������������������������������������������������Ŀ
	//�Identifica se a Cotacao esta em aberto, sendo que nao deve existir nenhum item da Cotacao com Preco   �	
	//��������������������������������������������������������������������������������������������������������
	If (cAliasSC8)->C8_PRECO == 0 .And. lAnalise == .F.
        lOpen    := .T.	
	EndIf
	//������������������������������������������������������������������������������������������������������Ŀ
	//�Se exitir um item da Cotacao ja atualizado com preco a cotacao sera considerada em Analise.           �	
	//��������������������������������������������������������������������������������������������������������	
	If (cAliasSC8)->C8_PRECO <> 0
        lOpen    := .F.	
        lAnalise := .T.    
    EndIf

	(cAliasSC8)->(dbSkip())

    If (cAliasSC8)->C8_NUM <> cNumSC8 .Or. (cAliasSC8)->(Eof())

	    If lOpen
			Aadd(aSC8Open,{cNumSC8,dEmissao})          
		ElseIf lAnalise
	 		Aadd(aSC8Parc,{cNumSC8,dEmissao})          
	    EndIf

		//��������������������������������������������������������������������������������������������������Ŀ
		//�Apos a Classificacao do PC alimenta as variaveis para avaliacao do proximo PC a ser classificado. �	
		//����������������������������������������������������������������������������������������������������	    
		cNumSC8   := (cAliasSC8)->C8_NUM 
		dEmissao  := STOD((cAliasSC8)->C8_EMISSAO)
		
        lOpen     := .F.
        lAnalise  := .F.

    EndIf
     
EndDo

If !Empty(aSC8Open)
	Aadd(aTipoSC8,STR0003)     //"Em Aberto"
	Aadd(aTable , {aTipoSC8[Len(aTipoSC8)] , aTitle , aSC8Open})
	Aadd(aQtdSC8,Len(aSC8Open))  
EndIf

If !Empty(aSC8Parc)
	Aadd(aTipoSC8,STR0004)   //"Em Analise"
	Aadd(aTable , {aTipoSC8[Len(aTipoSC8)] , aTitle , aSC8Parc})
	Aadd(aQtdSC8,Len(aSC8Parc))  
EndIf

If Empty(aSC8Open) .And. Empty(aSC8Parc) 
	Aadd(aTipoSC8, STR0007)  //"Nao foram encotradas Cota��es de Compras em Aberto"
	Aadd(aTable , {aTipoSC8[Len(aTipoSC8)] , aTitle , {{" "," "}} })
	Aadd(aQtdSC8,1)
EndIf

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aPanel:= {GRP_PIE, {STR0005,/*bClickG*/,aTipoSC8,aQtdSC8},{STR0006,{ |x| COMPView08( x[1] ) },aTable}} //"Numero de Cota��es em Aberto"###"Cota��es de Compras"
			
//�������������������������������������������������������������������������������������Ŀ
//� Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
//���������������������������������������������������������������������������������������
If lQuery
	dbSelectArea(cAliasSC8)
	dbCloseArea()
Else
  	dbSelectArea("SC8") 
	RetIndex("SC8") 
	dbClearFilter()
	Ferase(cIndSC8+OrdBagExt())
EndIf

Return aPanel 

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �COMPView08� Autor �Alexandre Inacio Lemes � Data � 06/02/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Consulta os documentos de Cotacao de Compras                  ���
���������������������������������������������������������������������������Ĵ��
���Uso       � ComPgOnl07                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function COMPView08(cCotacao)

Local aArea := GetArea()

dbSelectArea("SC8")
dbSetOrder(1)
If MsSeek(xFilial("SC8")+Substr(cCotacao,1,len(SC8->C8_NUM)))
//	Mata160(NIL,2) // Aguardando Depto de tecnologia para definicao das regras para chamadas dos programas. 06/02/2007 
EndIf

RestArea(aArea)

Return
