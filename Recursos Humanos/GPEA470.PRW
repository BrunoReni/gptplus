#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA470.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"

/*/
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA470  � Autor � Valdeci Lira                    � Data � 05/10/07 ���
�����������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro dos Criterios de acumulacao                                 ���
�����������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                             ���
�����������������������������������������������������������������������������������Ĵ��
���              ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
�����������������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS/FNC       �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������������Ĵ��
���Natie       �10/06/08�                �Inclusao de validacao RCH_QTDSEQ          ���
���Silvia Tag. �03/10/08�155370          �Ajuste para utilizacao na rotina na Argen-���
���            �        �                �tina modelo 1                             ���
���Kelly       �24/11/08�00000005530/2008�Ajuste para utilizacao em Venezuela e     ���
���            �        �                �Colombia.                                 ���
���Rogerio R.  �05/05/09�00000008714/2009�Correcao no erro na validacao ao excluir  ���
���Ademar Jr.  �23/01209�00000029430/2009�Tratamento pra localizacao do Peru.       ���
���Christiane V�25/10/11�00000026587/2011�Valida��o da tabela RCH na exclus�o.      ���
���Aldo Marini �24/04/12�P12-REQ199      �Recriacao de Acumuladores                 ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������/*/
Function GPEA470()
	Local bValidAlt := {|| f470VldAlt() }
	Private cCadastro := OemToAnsi(STR0001)	
	
   	If (MV_MODFOL == "2") .Or. cPaisLoc $ "ARG/VEN/COL/PER"		
		AxCadastro("RG9", cCadastro, "f470VldDel()", "f470VldAlt()", NIL, bValidAlt )
	Else
		Help("",1,"NAO_DISPONIVEL" )
	EndIf
Return


/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �f470VldDel    �Autor  �Valdeci Lira        � Data �  18/10/07   ���
�����������������������������������������������������������������������������͹��
���Desc.     � Realiza os relacionamentos antes de deletar o RG9_CODCRI       ���
���          �                                                                ���
�����������������������������������������������������������������������������͹��
���Uso       � AP                                                             ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Function f470VldDel()    
	Local lDelReg
	Local aAreas := {}
    Local nAreas
 
	//RG7 - Cadastro de acumuladores
	aAdd(aAreas, Array(4))
	nAreas := Len(aAreas)
	aAreas[nAreas, 1] := RG7->(GetArea())
	aAreas[nAreas, 2] := {"RG7_FILIAL", "RG7_CODCRI"}
	aAreas[nAreas, 3] := RetOrdem("RG7", "RG7_FILIAL+RG7_CODCRI", .T.)
	
	//RG6 - Padrao de periodos
	aAdd(aAreas, Array(4))
	nAreas := Len( aAreas )
	aAreas[nAreas, 1] := RG6->( GetArea() )
	aAreas[nAreas, 2] := {"RG6_FILIAL", "RG6_CRITER"}
	aAreas[nAreas, 3] := RetOrdem("RG6", "RG6_FILIAL+RG6_CRITER", .T.)
	aAreas[nAreas, 4] := {"='@'" ," LIKE '%@%'"}
	
	//SRM - Roteiro de Calculo 
	If cPaisLoc $ "MEX|DOM|COS"
		aAdd(aAreas, Array(4))
		nAreas := Len(aAreas)
		aAreas[nAreas, 1] := SRM->(GetArea())
		aAreas[nAreas, 2] := {"RM_FILIAL", "RM_CODCRI"}
		aAreas[nAreas, 3] := RetOrdem("SRM", "RM_FILIAL+RM_CODCRI", .T.)
		
		aAdd(aAreas, Array(4))
		nAreas := Len(aAreas)
		aAreas[nAreas, 1] := RCH->(GetArea())
		aAreas[nAreas, 2] := {"RCH_FILIAL", "RCH_CRITER"}
		aAreas[nAreas, 3] := RetOrdem("RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR", .T.)		
	EndIf
	
	// verificar se a tabela nao possui registros relacionados //
	lDelReg := ChkDelRegs(	"RG9"				,;	// 1-Alias do Arquivo Principal
							RG9->( Recno() )	,;	// 2-Registro do Arquivo Principal
							5					,;	// 3-Opcao para a AxDeleta
							xFilial("RG9")		,;	// 4-Filial do Arquivo principal para Delecao
							RG9->RG9_CODCRI 	,;	// 5-Chave do Arquivo Principal para Delecao
							aAreas 				,;	// 6-Array contendo informacoes dos arquivos a serem pesquisados
							NIL					,;	// 7-Mensagem para MsgYesNo
							NIL					,;	// 8-Titulo do Log de Delecao
							NIL					,;	// 9-Mensagem para o corpo do Log
							.F.				 	,;	// 10-Se executa AxDeleta
							.T.     			,;	// 11-Se deve Mostrar o Log
							NIL					,;	// 12-Array com o Log de Exclusao
							NIL				 	,;	// 13-Array com o Titulo do Log
							NIL					,;	// 14-Bloco para Posicionamento no Arquivo
							NIL					,;	// 15-Bloco para a Condicao While
							NIL					,;	// 16-Bloco para Skip/Loop no While
							.T.					,;	// 17-Verifica os Relacionamentos no SX9
							NIL					,;	// 18-Alias que nao deverao ser Verificados no SX9
							NIL				 	 ;	// 19-Se faz uma checagem soft
					     )	
Return lDelReg        

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �f470VldQtdSeq �Autor  �Natie               � Data �  05/06/08   ���
�����������������������������������������������������������������������������͹��
���Desc.     �Permite a inclusao de no maximo 13 sequencias de acumulacao     ���
���          �                                                                ���
�����������������������������������������������������������������������������͹��
���Uso       � AP                                                             ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Function  f470VldQtdSeq()
	Local lRetOk	:= .T. 
	Local nConteudo := &(ReadVar())
	
	If nConteudo > 13 
		MsgAlert( OemToAnsi(STR0003) , OemToAnsi( STR0002 ) ) // ""Sao permitidas no maximo 13 sequencias."#"Aviso "
		lRetOk := .F.
	Endif 
Return(lRetOk) 

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �f470VldAlt    �Autor  �IP Rh Inovacao      � Data �  23/04/12   ���
�����������������������������������������������������������������������������͹��
���Desc.     �Valida a opcao de "Alterar" para nao permitir quando houver um  ���
���          �criterio utilizado em meses ja fechados                         ���
�����������������������������������������������������������������������������͹��
���Uso       � GPEA470                                                        ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Function f470VldAlt()

Local aArea		:= GetArea()
Local cWhere	:= ""
Local cAliasQry	:= GetNextAlias()	
Local lRetOk 	:= .T.

If ALTERA

	cWhere := "% RCH.RCH_DTFECH <> '" + Space(8) + "' AND RCH.RCH_CRITER LIKE '%" + RG9->RG9_CODCRI + "%' %"
	BeginSql alias cAliasQry
	   	SELECT R_E_C_N_O_
		FROM %table:RCH% RCH
		WHERE %exp:cWhere% and RCH.%notDel%
	EndSql
	
	If (cAliasQry)->(!Eof())
		MsgAlert( OemToAnsi(STR0004) , OemToAnsi( STR0002 ) ) // "Crit�rio de acumula��o foi utilizado em per�odos j� fechados, n�o sendo poss�vel sua altera��o. Por favor, selecione outro crit�rio ou inclua um novo." ### "Aviso "
		lRetOk := .F.
	Endif
	(cAliasQry)->(dbCloseArea())

Endif

RestArea(aArea)

Return lRetOK