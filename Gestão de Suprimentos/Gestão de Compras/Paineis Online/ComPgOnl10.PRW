#INCLUDE "Protheus.ch"
#INCLUDE "ComPgOnl10.ch"
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ComPgOnl10� Autor �Alexandre Inacio Lemes � Data � 13/03/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 3:                     ���
���          �Indice de Eficiencia do Processo de Compras                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {{cText1,cValor,nColorValor,bClick},...}             ���
���          � cTexto1     = Texto da Coluna                       		    ���
���          � cValor      = Valor a ser exibido (string)          		    ���
���          � nColorValor = Cor do valor no formato RGB (opcional)         ���
���          � bClick      = Funcao executada no click do valor (opcional)  ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGACOM                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/        
Function ComPgOnl10()

Local aPanel    := {}

Local cAliasSD1 := "SD1"
Local cIndSD1   := ""
Local cHelp     := ""

Local nPrazoBase:= 0
Local nPrecoBase:= 0
Local nIndiceA  := 0
Local nIndiceB  := 0
Local nIndiceC  := 0
Local nDescIndA := 0
Local nDescIndB := 0
Local nDescIndC := 0
Local nPesoA    := 0
Local nPesoB    := 0
Local nPesoC    := 0
Local nSemPrazo := 0
Local nTotEfcz  := 0
Local nEficaz   := 0

Local lPreco    := .T.
Local lPrazo    := .T.
Local lNeces    := .T.       
Local lQuery    := .F.

dbSelectArea("SC7")  
dbSetOrder(14)

dbSelectArea("SC8")  
dbSetOrder(3)

dbSelectArea("SD1") 
dbSetOrder(1)

lQuery    := .T.
cAliasSD1 := GetNextAlias()	

BeginSql Alias cAliasSD1

SELECT SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_EMISSAO,SD1.D1_DTDIGIT,SD1.D1_FORNECE,SD1.D1_LOJA,
       SD1.D1_PEDIDO,SD1.D1_ITEMPC,SD1.D1_ITEM,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_VUNIT,SD1.D1_TOTAL,SD1.R_E_C_N_O_ SD1RecNo 

FROM %table:SD1% SD1

WHERE SD1.D1_FILIAL = %xFilial:SD1%  
    AND SD1.D1_DTDIGIT >= %Exp:DtoS(dDataBase - 90)% 
    AND SD1.D1_DTDIGIT <= %Exp:DtoS(dDataBase)%
    AND SD1.D1_PEDIDO <> ' '
AND SD1.%NotDel% 
		  
ORDER BY %Order:SD1% 
		
EndSql 

nTotEfcz  := 0
nDescIndA := 0
nDescIndB := 0
nDescIndC := 0

//������������������������������������������������������������������������������Ŀ
//� Serao avaliados apenas os itens entregue que tenham passado pelo processo    �
//� completo de Compras composto por  SC - Cotacao - Pedido de Compras - NFE.    �
//��������������������������������������������������������������������������������
dbSelectArea(cAliasSD1)
While ( !(cAliasSD1)->(Eof()) .And. (cAliasSD1)->D1_FILIAL == xFilial("SD1") )
	
	SC7->(dbSetOrder(14))
	SC7->(MsSeek(xFilEnt(xFilial("SC7"))+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC))
	
	//���������������������������������������������������������������������������Ŀ
	//� A data de Emissao do PC e a dataBase usada na Analise da Cotacao para     �
	//� compor a data de entrega do PC atraves da soma do C8_PRAZO.               �
	//�����������������������������������������������������������������������������
	nPrazoBase := SC7->C7_DATPRF - SC7->C7_EMISSAO
	nPrecoBase := SC7->C7_PRECO
	
	If !Empty(SC7->C7_NUMCOT)
		
		SC8->(dbSetOrder(3))
		SC8->(MsSeek(xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO))
		
		lPreco := .T.
		lPrazo := .T.
		lNeces := .T.
		
		//�����������������������������������������������������������������������Ŀ
		//� Avalia toda a cotacao do produto entregue para verificar se o preco   �
		//� e prazo escolhido foi o melhor da cotacao do produto, se nao for,sera �
		//� descontado o Indice A para Precos e B para Prazos para a composicao   �
		//� da eficiencia total do processo de compras.                           �
		//�������������������������������������������������������������������������
		While ( !SC8->(Eof()) .And. SC8->C8_FILIAL == xFilial("SC8") .And. ;
			SC8->C8_NUM == SC7->C7_NUMCOT .And. SC8->C8_PRODUTO == SC7->C7_PRODUTO )
			
			If SC8->C8_FORNECE+SC8->C8_LOJA+SC8->C8_NUMPED+SC8->C8_ITEMPED <> SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM+SC7->C7_ITEM
				
				//���������������������������������������������������������������Ŀ
				//� Regra para descontar o Indice A - Menor Preco, Se encontrar   �
				//� um outro Fornecedor com o preco menor na cotacao passa apenas �
				//� uma vez para alimentar a variavel nDescIndA.                  �
				//�����������������������������������������������������������������
				If lPreco .And. SC8->C8_PRECO > 0 .And. SC8->C8_PRECO < nPrecoBase
					
					nDescIndA++
					
					lPreco := .F.
					
				EndIf
				
				//���������������������������������������������������������������Ŀ
				//� Regra para descontar o Indice B - Menor Prazo, Se encontrar   �
				//� um outro Fornecedor com o prazo menor na cotacao passa apenas �
				//� uma vez para alimentar a variavel nDescIndB.                  �
				//� Avalia somente os Fornecedores que informaram precos na Cot.  �
				//�����������������������������������������������������������������
				If lPrazo .And. SC8->C8_PRAZO > 0 .And. ( ( SC7->C7_EMISSAO + SC8->C8_PRAZO ) - SC7->C7_EMISSAO ) < nPrazoBase
					
					nDescIndB++
					
					lPrazo := .F.
					
				EndIf
				
			EndIf
			
			//�������������������������������������������������������������������Ŀ
			//� Se for encontrado precos e prazos menores interrompe o While pois �
			//� nao sera necessario rodar a cotacao inteira.                      �
			//���������������������������������������������������������������������
			If !lPreco .And. !lPrazo
				Exit
			EndIf
			
			//�������������������������������������������������������������������Ŀ
			//� Avalia se todos os itens deste produto na cotacao nao foram infor �
			//� mados o prazo de entrega pelo fornecedor, caso isso ocorra a varia�
			//� vel lNeces sera .T. indicando que essa entrega foi gerada pela da �
			//� ta da necessidade e dever ser deduzido o peso do IndiceB desta    �
			//� entrega acrescentando a diferenca desconta para o IndiceC.        �
			//���������������������������������������������������������������������
			If SC8->C8_PRAZO > 0
				lNeces := .F.
			EndIf
			
			SC8->(dbSkip())
			
		EndDo
		
		//�����������������������������������������������������������������������Ŀ
		//� Alimenta as entregas que foram geradas por data de necessidade para   �
		//� deduzir o peso do Indice B.                                           �
		//�������������������������������������������������������������������������
		If lNeces
			nSemPrazo++
		EndIf
		
		//�����������������������������������������������������������������������Ŀ
		//� Regra para descontar o Indice C - Cumprimento do Prazo de Entrega.    �
		//� Avalia se o prazo de Entrega da NFE foi maior do que o definido no PC �
		//� se for deduzira o percentual do Indice C.                             �
		//�������������������������������������������������������������������������
		If StoD((cAliasSD1)->D1_DTDIGIT) > SC7->C7_DATPRF
			nDescIndC++
		EndIf
		
		//�����������������������������������������������������������������������Ŀ
		//� A variavel nTotEfcz acumula o total das entregas avaliadas para compor�
		//� os 100%.                                                              �
		//�������������������������������������������������������������������������
		nTotEfcz++
		
	EndIf
	
	(cAliasSD1)->(dbSkip())
	
EndDo

//������������������������������������������������������������������������������Ŀ
//� Calcula o percentual de cada Indice em relacao ao total de Entregas.         �
//��������������������������������������������������������������������������������
nIndiceA  := ( ( ( nTotEfcz - nDescIndA ) / nTotEfcz ) * 100 )
nIndiceB  := ( ( ( nTotEfcz - nDescIndB ) / nTotEfcz ) * 100 )
nIndiceC  := ( ( ( nTotEfcz - nDescIndC ) / nTotEfcz ) * 100 )

//������������������������������������������������������������������������������Ŀ
//� Definicao padrao dos pesos matematicos de cada Indice conforme a Importancia.�
//��������������������������������������������������������������������������������
nPesoA    := 5
nPesoB    := 3
nPesoC    := 2

//������������������������������������������������������������������������������Ŀ
//� Deduz percentualmente do Indice B as entregas que foram geradas pela data da �
//� necessidade na cotacao e acrescenta essa diferenca ao peso do Indice C.      �
//��������������������������������������������������������������������������������
If nSemPrazo > 0
	nPesoB := nPesoB * ( ( nTotEfcz - nSemPrazo ) / nTotEfcz )
	nPesoC := nPesoC + ( 3 - nPesoB )
EndIf

//������������������������������������������������������������������������������Ŀ
//� Calcula o Percentual de Eficiencia do Processo completo de compra do item    �
//� conforme os Indices e pesos Calculados.                                      �
//��������������������������������������������������������������������������������
nEficaz   := ( ( nIndiceA * nPesoA ) + ( nIndiceB * nPesoB ) + ( nIndiceC * nPesoC ) ) / 10

cHelp := "'"+STR0005 + "'+chr(13)+chr(10)+" //"Para chegar ao Indice Total de Efici�ncia o sistema pesquisa os �ltimos  "
cHelp += "'"+STR0006 + "'+chr(13)+chr(10)+" //"90 dias somente das entregas que foram originadas do processo de cota��o."
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0007 + "'+chr(13)+chr(10)+" //"Formula do Indice Efici�ncia =((Indice A * Peso A) + (Indice B * Peso B) + (Indice C * Peso C)) / 10 "
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0008 + "'+chr(13)+chr(10)+" //"Indice A = % de vezes que o Vencedor escolhido da cota��o � o que tem o melhor pre�o"
cHelp += "'"+STR0009 + "'+chr(13)+chr(10)+"	//"Indice B = % de vezes que o Vencedor escolhido da cota��o � o que tem o menor prazo de entrega"
cHelp += "'"+STR0010 + "'+chr(13)+chr(10)+"	//"Indice C = % de vezes em que a entrega do material (Documento de Entrada) ocorre dentro da data Prevista no Pedido de Compras."
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0011 + "'+chr(13)+chr(10)+" //"Defini��o dos Pesos Utilizados na Formula : "
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0012 + "'+chr(13)+chr(10)+"	//"Peso A = 5  Peso B = 3  Peso C = 2"
cHelp += "'"+STR0013 + "'+chr(13)+chr(10)+"	//"O Peso B sofre um desconto percentual em rela��o ao total de entregas "
cHelp += "'"+STR0014 + "'+chr(13)+chr(10)+"	//"analisadas toda vez que na cota��o do material analisado a data de "
cHelp += "'"+STR0015 + "'+chr(13)+chr(10)+"	//"entrega n�o foi informada ou o pedido foi gerado a partir da data da "
cHelp += "'"+STR0016 + "'+chr(13)+chr(10)+"	//"necessidade do material. Quando esse desconto � realizado o mesmo � adicionado ao Peso C."
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0017 + "'+chr(13)+chr(10)+"	//"Exemplo :"
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0018 + "'+chr(13)+chr(10)+"	//"Em 90 dias foram analisadas 1000 Entregas onde 250 foram originadas de "
cHelp += "'"+STR0019 + "'+chr(13)+chr(10)+"	//"cota��es por data de necessidade ou sem data de entrega informada. Os Pesos "
cHelp += "'"+STR0020 + "'+chr(13)+chr(10)+"	//"B e C seriam :"
cHelp += "'"+STR0021 + "'+chr(13)+chr(10)+"	//"PesoB = ( ( 1000 - 250 ) / 1000 ) * 3 que resulta em 2.25 "
cHelp += "'"+STR0022 + "'+chr(13)+chr(10)"	//"PesoC = a Diferenca de 3 - 2.25 = 0.75  somada ao Indice C 2 que Resulta em 2.75"

//������������������������������������������������������������������������������Ŀ
//� O Aadd contem informacoes de todos os Indicadores para Painel do Tipo 1      �
//� Alterado para Painel Tipo 3 - Aguardando definicoes do Projeto.              �
//��������������������������������������������������������������������������������
Aadd( aPanel, { STR0001,Transform(nIndiceA,"@R 999.99")+" %",Iif(nIndiceA > 50,CLR_HBLUE,CLR_HRED),}) //"Melhores Pre�os " //"Melhores Pre�os "
Aadd( aPanel, { STR0002,Transform(nIndiceB,"@R 999.99")+" %",Iif(nIndiceB > 50,CLR_HBLUE,CLR_HRED),}) //"Melhores Prazos " //"Melhores Prazos "
Aadd( aPanel, { STR0003,Transform(nIndiceC,"@R 999.99")+" %",Iif(nIndiceC > 50,CLR_HBLUE,CLR_HRED),}) //"Prazos Cumpridos" //"Prazos Cumpridos"
Aadd( aPanel, { STR0004,Transform(nEficaz ,"@R 999.99")+" %",Iif(nEficaz  > 50,CLR_HBLUE,CLR_HRED),}) //"Indice de Efici�ncia" //"Indice de Efici�ncia"

aPanel:= {STR0023,Transform(nEficaz,"@R 999.99")+"%",/* "% M�s" */,Iif(nEficaz > 60,CLR_HBLUE,CLR_HRED),"{ || MsgInfo("+cHelp+") }",0,100,nEficaz }	 //"Efici�ncia do Processo de Compras em 90 Dias."

//������������������������������������������������������������������������������Ŀ
//� Apaga arquivos de trabalho,cancela filtros e restabelece as ordens originais.|
//��������������������������������������������������������������������������������
If lQuery
	dbSelectArea(cAliasSD1)
	dbCloseArea()
Else
	dbSelectArea("SD1")
	RetIndex("SD1")
	dbClearFilter()
	Ferase(cIndSD1+OrdBagExt())
EndIf

Return aPanel 
