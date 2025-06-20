#INCLUDE "PROTHEUS.CH"
#include "FATP020.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FATP020   � Autor � Marco Bianchi         � Data � 19/01/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 3: Perda de Faturamento���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �FATP020()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {cText1,cValor,cLegenda,nColorValor,cClick,nPosIni,  ���
���          � nPosFim,nPos}                                                ���
���          � cText1      = Texto da Barra                         		���
���          � cValor      = Valor a ser exibido (string)                   ���
���          � cLegenda    = Nome da Legenda                                ���
���          � nColorValor = Cor do Valor no formato RGB (opcional)         ���
���          � cClick      = Funcao executada no click do valor (opcional)  ���
���          � nPosIni     = Valor Inicial                      		    ���
���          � nPosFim     = Valor Final                                    ���
���          � nPos        = Valor da Barra                                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGAMDI                                                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/


Function FATP020()

Local aArea       := GetArea()
Local aAreaSC6    := SC6->(GetArea())
Local aAreaSC9    := SC9->(GetArea())
Local cAliasSC6   := "SC6"
Local cAliasSC9   := "SC9"
Local cChave      := ""
Local aRet        := {} 
Local cMes        := StrZero(Month(dDataBase),2)
Local cAno		    := cValToChar(Year(dDataBase))
Local dDataIni    := CTOD("01/"+cMes+"/"+cAno)
Local dDataFim    := CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Local cMensagem   := ""
Local nValPed     := 0		// Valor total dos pedidos
Local nValNFat    := 0		// Valor total nao faturado (bloqueio de credito/estoque ou eliminado residuo)
Local nPerc       := 0
Local lSkip 	  := .F.

#IFDEF TOP  

	//������������������������������������������������������������������������Ŀ
	//�Filtra os pedidos de venda com bloqueio de credito, bloqueio de estoque �
	//�e verifica residuos.                                                    �
	//��������������������������������������������������������������������������
	cAliasSC6 := cAliasSC9 := GetNextAlias()
	BeginSql Alias cAliasSC6
	SELECT C6_NUM,C6_ITEM,C6_ENTREG,C6_VALOR,C9_QTDLIB,C6_BLQ,C6_QTDVEN,C6_QTDENT,C9_PEDIDO,C9_ITEM,C9_PRCVEN,C9_BLEST,C9_BLCRED
		FROM %Table:SC6% SC6
		LEFT JOIN %Table:SC9% SC9 ON C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM
		WHERE C6_ENTREG >= %Exp:Dtos(dDataIni)% AND C6_ENTREG <= %Exp:Dtos(dDataFim)% AND SC6.%NotDel% 
	ORDER BY C6_NUM,C6_ITEM
	EndSql
	bWhile := {|| !Eof() }
	
#ELSE 

	dbSelectArea(cAliasSC6)		// Itens dos pedidos de venda
	dbSetOrder(3)				// Data de Entrega,Pedido,Item
	MsSeek(xFilial("SC6")+DTOS(dDataIni),.T.)
	bWhile := {|| !Eof() .And. C6_ENTREG >= dDataIni .And. C6_ENTREG <= dDataFim }
	
#ENDIF


While Eval(bWhile)
	               
	// Total dos pedidos dentro do mes
	nValPed += (C6_VALOR)

	#IFNDEF TOP  
		dbSelectArea("SC9")
		dbSetOrder(1)
		dbSeek(xFilial("SC9")+(cAliasSC6)->C6_NUM+(cAliasSC6)->C6_ITEM)
	#ENDIF

	cChave := (cAliasSC6)->C6_NUM+(cAliasSC6)->C6_ITEM
	lSkip := .T.
	While !Eof() .And. C9_PEDIDO+C9_ITEM == cChave
	
		#IFDEF TOP  
			lSkip := .F.
		#ENDIF	
		
		//������������������������������������������������������������������������Ŀ
		//� Valor total dos pedidos com bloqueio de estoque, bloqueio de credito   �
		//� ou eliminado residuo.                                                  �
		//��������������������������������������������������������������������������
		If C9_BLEST == '10' .And. C9_BLCRED == '10'		// Nota ja emitida
		   	If AllTrim((cAliasSC6)->C6_BLQ) == 'R'	// Verifica se foi eliminado residuo
		   		nValNFat += (((cAliasSC6)->C6_QTDVEN - (cAliasSC6)->C6_QTDENT) * (cAliasSC6)->C6_PRCVEN)
	   		EndIf
		ElseIf (!Empty(C9_BLEST) .And. C9_BLEST <> '10') .Or. (!Empty(C9_BLCRED) .And. C9_BLCRED <> '10')		// Bloqueio de credito ou estoque
			nValNFat += (C9_QTDLIB * C9_PRCVEN)	
		EndIf
		
		dbSelectArea(cAliasSC9)
		dbSkip()
	
	EndDo
	
	If lSkip
		dbSelectArea(cAliasSC6)
		dbSkip()
	EndIf	
	
EndDo

//������������������������������������������������������������������������Ŀ
//�Calcula percentual                                                      �
//��������������������������������������������������������������������������
nPerc  := Round( ((nValNFat* 100) / nValPed),0)

//������������������������������������������������������������������������Ŀ
//�Monta mensagem                                                          �
//��������������������������������������������������������������������������
cMensagem := "'"+STR0001 + "'+chr(13)+chr(10)+"		// "% de Perda de Faturamento"
cMensagem += "'"+"'+chr(13)+chr(10)+"
cMensagem += "'"+STR0002 + "'+chr(13)+chr(10)+"		// "Representa o % do valor nao faturado (pedidos com bloqueios, rejeitados ou "
cMensagem += "'"+STR0003 + "'+chr(13)+chr(10)+"		// "eliminado residuo), em relacao a carteira de pedidos dentro do mes. "
cMensagem += "'"+STR0004 + "'+chr(13)+chr(10)+"		// "Periodo Considerado (Data de Entrega):  Mes corrente. "
cMensagem += "'"+STR0005 +"'+chr(13)+chr(10)+"		// "Resultado %: (Valor nao faturado * 100) / Carteira de Pedidos"
cMensagem += "'"+" " +"'+chr(13)+chr(10)+"
cMensagem += "'"+STR0006 + Transform(nValNFat,"@E 999,999,999.99")+"'+chr(13)+chr(10)+"	// "Valor nao Faturado: "
cMensagem += "'"+STR0007 + Transform(nValPed,"@E 999,999,999.99")+"'"						// "Carteira de Pedidos: "

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aRet := { STR0008,AllTrim(Str(nPerc))+"%",STR0009,CLR_BLUE,"{ || MsgInfo("+cMensagem+") }",0,100,nPerc }		// "Valor Bloqueado,rejeitado e eliminado residuo"###"% Perda"
                 
//������������������������������������������������������������������������Ŀ
//�Restaura areas                                                          �
//��������������������������������������������������������������������������
#IFDEF TOP
	(cAliasSC6)->(DbCloseArea())
#ENDIF

RestArea(aAreaSC6)
RestArea(aAreaSC9)
RestArea(aArea)


Return aRet
                   