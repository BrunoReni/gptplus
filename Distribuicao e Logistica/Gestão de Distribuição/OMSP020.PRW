#INCLUDE "PROTHEUS.CH"
#INCLUDE "OMSP020.CH

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �OMSP020   � Autor � Marco Bianchi         � Data � 15/01/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 1: Faturamento por     ���
���          �Rota.                                                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �OMSP020()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {{cText1,cValor,nColorValor,bClick},...}             ���
���          � cTexto1     = Texto da Coluna                       		    ���
���          � cValor      = Valor a ser exibido (string)          		    ���
���          � nColorValor = Cor do valor no formato RGB (opcional)         ���
���          � bClick      = Funcao executada no click do valor (opcional)  ���
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


Function OMSP020()

Local aArea       := GetArea()
Local aAreaDAI    := DAI->(GetArea())
Local aAreaDA8    := DA8->(GetArea())
Local aAreaSF2    := SF2->(GetArea())
Local aRet        := {} 
Local aFatRota    := {} 
Local cAliasDAI   := "DAI"
Local cAliasDA8   := "DA8"
Local cAliasSF2   := "SF2"
Local cMes        := StrZero(Month(dDataBase),2)
Local cAno        := Substr(DTOC(dDataBase),7,2)
Local dPerIni     := CTOD("01/"+cMes+"/"+cAno)
Local dPerFim     := CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Local bWhile 
Local nPos        := 0
Local cMensagem  := "'"+STR0001 + DTOC(dPerIni)  + STR0002 + DTOC(dPerFim)	+ "'" // "Faturamento do periodo de "###" a "###"."

#IFDEF TOP

	//������������������������������������������������������������������������Ŀ
	//�Query para Filtrar as rotas que possuem faturamento dentro do mes       �
	//�corrente.                                                               �
	//��������������������������������������������������������������������������
	cAliasDAI := cAliasDA8 := cAliasSF2 := GetNextAlias()
	BeginSql Alias cAliasDAI
	SELECT DAI_ROTEIR,DAI_NFISCA,DAI_SERIE,DAI_DATA,DA8_DESC,F2_VALBRUT
		FROM %Table:DAI% DAI
		LEFT JOIN %Table:DA8% DA8 ON DA8_FILIAL = %xFilial:DA8% AND DAI_ROTEIR = DA8_COD AND DA8.%NotDel% 
		LEFT JOIN %Table:SF2% SF2 ON F2_FILIAL = %xFilial:SF2% AND DAI_NFISCA = F2_DOC AND DAI_SERIE = F2_SERIE AND SF2.%NotDel% 
		WHERE DAI_FILIAL = %xFilial:DAI% 
			AND DAI_DATA >= %Exp:Dtos(dPerIni)% AND DAI_DATA <= %Exp:Dtos(dPerFim)% 
			AND DAI_NFISCA <> ' ' AND DAI.%NotDel% 
	EndSql
	bWhile := {|| !Eof() }

#ELSE 

	dbSelectArea("DAI")		// Itens da Carga
	dbSetOrder(2)			// Data
	MsSeek(xFilial("DAI")+DTOS(dPerIni),.T.)
	bWhile := {|| !Eof() .And. DAI_DATA >= dPerIni .And. DAI_DATA <= dPerFim }
	
#ENDIF
              

//������������������������������������������������������������������������Ŀ
//�Calcula o valor faturado por Rota                                       �
//��������������������������������������������������������������������������
While Eval(bWhile)

	#IFNDEF TOP
		dbSelectArea(cAliasDA8)
		dbSetOrder(1)
		dbSeek(xFilial("DA8")+(cAliasDAI)->DAI_ROTEIR)

		dbSelectArea(cAliasSF2)
		dbSetOrder(1)
		dbSeek(xFilial("SF2")+(cAliasDAI)->DAI_NFISCA+(cAliasDAI)->DAI_SERIE)
 	#ENDIF
	                                 	
	nPos := aScan(aFatRota,{|x| x[1] == (cAliasDAI)->DAI_ROTEIR+"-"+(cAliasDA8)->DA8_DESC })
	If nPos == 0
		AADD(aFatRota,{(cAliasDAI)->DAI_ROTEIR+"-"+(cAliasDA8)->DA8_DESC,((cAliasSF2)->F2_VALBRUT)})
	Else
		aFatRota[nPos,2] += ((cAliasSF2)->F2_VALBRUT)
	EndIf
	
	dbSelectArea(cAliasDAI)
	dbSkip()
EndDo

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
For nPos := 1 to Len(aFatRota)
	Aadd( aRet, { aFatRota[nPos,1], Transform(aFatRota[nPos,2],"@E 999,999,999.99"),CLR_BLUE, "{ || MsgInfo("+cMensagem+") }" } )
Next

//������������������������������������������������������������������������Ŀ
//�Restaura areas                                                          �
//��������������������������������������������������������������������������
#IFDEF TOP
	(cAliasDAI)->(DbCloseArea())
#ENDIF

RestArea(aAreaDAI)
RestArea(aAreaDA8)
RestArea(aAreaSF2)
RestArea(aArea)

Return aRet
