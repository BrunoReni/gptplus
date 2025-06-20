#include "protheus.ch"
#INCLUDE "AE_Despv_Ap6.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_DESPV  �Autor  �Armando / Willy     � Data �  09/06/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � MBrowse das Despesas com Viagem.                           ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function AE_DespV()

Local aOpcAdc		:= {}

Private aCores		:= {}
Private cCadastro	:= ""
Private aRotina 	:= MenuDef()

ChkTemplate("CDV")

cCadastro  := STR0001 //"Presta��o de Contas"

// V - Verde     -> Colaborador Viajando
// D - Amarela   -> Iniciado Processo de Acerto
// L - Laranja   -> Encaminhado e Aguardando Confirmacao
// C - Vermelho  -> Autorizado e Liberado
// Z - Cinza     -> Fechamento da Viagem
// M - Marrom    -> Iniciado a Presta��o de Contas sem Solicita��o
// B - Branco    -> Presta��o de Contas sem Solicita��o
// P - Preto     -> Processo de acerto em atraso
// K - Pink		 -> Solicitacoes canceladas

aCores := {	{ 'LHQ_Flag = "V" ', 'BR_VERDE'    	},;
			{ 'LHQ_Flag = "D" ', 'BR_AMARELO'  	},;
			{ 'LHQ_Flag = "L" ', 'BR_LARANJA'  	},;
			{ 'LHQ_Flag = "C" ', 'BR_VERMELHO' 	},;
			{ 'LHQ_Flag = "Z" ', 'BR_CINZA'    	},;
			{ 'LHQ_Flag = "M" ', 'BR_MARROM'   	},;
			{ 'LHQ_Flag = "B" ', 'BR_BRANCO'   	},;
			{ 'LHQ_Flag = "K" ', 'BR_PINK'   	},;
			{ 'LHQ_Flag = "P" ', 'BR_PRETO'    	},;
			{ 'LHQ_Flag = "E" ', 'BR_AZUL'    	}}

If ExistBlock("AE_DVMENU")
	aOpcAdc := ExecBlock("AE_DVMENU",.F.,.F.)
	If ValType(aOpcAdc) == "A"
		If !Empty(aOpcAdc) .AND. Len(aOpcAdc) >= 4
			aAdd(aRotina, aOpcAdc)
		Endif
	Endif
Endif

dbSelectArea('LHQ')   
mBrowse(6, 1, 22, 75,"LHQ",,,,,, aCores)	
LHQ->(dbClearFilter())

Return Nil


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �08/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}   

aAdd(aRotina, {STR0002	,'AxPesqui'		,0	,1}) //"Pesquisa"
aAdd(aRotina, {STR0003	,'T_AE_SV001(0)',0	,2}) //"Visualiza"
aAdd(aRotina, {STR0004	,'T_AE_DV001(1)',0	,3}) //"Despesas"
aAdd(aRotina, {STR0005	,'T_AE_DV001(2)',0	,3}) //"Avulso"
aAdd(aRotina, {STR0006	,'T_AE_DV003'	,0	,4}) //"Liberar"
aAdd(aRotina, {STR0007	,'T_AE_DV006'	,0	,4}) //"Fechamento"
aAdd(aRotina, {STR0008	,'T_LibAtraso'	,0	,4}) //"Lib.Atraso"
aAdd(aRotina, {STR0009	,'T_VerAtraso'	,0	,4}) //"Manuten��o"
aAdd(aRotina, {STR0010	,'T_AE_DV002'	,0	,2}) //"Imprime"
aAdd(aRotina, {STR0012	,'T_AE_DVCANC()',0	,5,,}) //"Cancelamento"
aAdd(aRotina, {STR0015	,'T_AE_DVEXC()'	,0	,5,,}) //"Excluir"
aAdd(aRotina, {STR0011	,'T_AE_DV004'	,0	,2,,.F.}) //"Legenda"



Return(aRotina)                           



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_DESPV  �Autor  �Leandro Sousa       � Data �  22/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cancelamento de despesas avulsas.                           ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function AE_DVCANC()

Local aArea			:= GetArea()
Local lRet			:= .F. 
Local cPrefReem		:= GetMV("MV_PREREEM")
Local cParcReem		:= GetMV("MV_PARREEM")
Local cTipoReem		:= GetMV("MV_TIPREEM")
Local cPrefAdia		:= GetMV("MV_PREADIA")
Local cParcAdia		:= GetMV("MV_PARADIA")
Local cTipoAdia		:= GetMV("MV_TIPADIA")
Local cPrefixo		:= ""
Local cTipo			:= ""
Local cParcela		:= ""
Local cNumReem		:= ""
Local cForReem		:= ""
Local cLojReem		:= ""

If Empty(cPrefReem)
	cPrefReem := Space(TamSX3("E2_PREFIXO")[1])
Else
	cPrefReem := PadR(cPrefReem,TamSX3("E2_PREFIXO")[1])	
EndIf

If Empty(cPrefAdia)
	cPrefAdia := Space(TamSX3("E2_PREFIXO")[1])
Else
	cPrefAdia := PadR(cPrefAdia,TamSX3("E2_PREFIXO")[1])	
EndIf

If Empty(cParcReem)
	cParcReem := Space(TamSX3("E2_PARCELA")[1])
Else
	cParcReem := PadR(cParcReem,TamSX3("E2_PARCELA")[1])
EndIf

If Empty(cParcAdia)
	cParcAdia := Space(TamSX3("E2_PARCELA")[1])
Else
	cParcAdia := PadR(cParcAdia,TamSX3("E2_PARCELA")[1])
EndIf

If Empty(cTipoReem)
	cTipoReem := Space(TamSX3("E2_TIPO")[1])     
Else
	cTipoReem := PadR(cTipoReem,TamSX3("E2_TIPO")[1])
EndIf

If Empty(cTipoAdia)
	cTipoAdia := Space(TamSX3("E2_TIPO")[1])     
Else
	cTipoAdia := PadR(cTipoAdia,TamSX3("E2_TIPO")[1])
EndIf

dbSelectArea("LHQ")

If LHQ->LHQ_Flag = "K"
	Alert(STR0021) //Despesa j� cancelada.
ElseIf lRet := MsgYesNo(STR0013)

	DbSelectArea("LHP")
	LHP->(DbSetOrder(1))
	LHP->(DbSeek(xFilial("LHP")+LHQ->LHQ_CODIGO))
	cNumReem := PadR(LHP->LHP_CODIGO,TamSX3("E2_NUM")[1])
	
	DbSelectArea("SA2")
	SA2->(DbOrderNickName("SA2CDV6"))
	SA2->(DbSeek(xFilial("SA2")+LHP->LHP_FUNC))
	cForReem := SA2->A2_COD
	cLojReem := SA2->A2_LOJA

	//Verifica se tem o t�tulo de reembolso
	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))
	If SE2->(DbSeek(xFilial("SE2")+cPrefReem+cNumReem+cParcReem+cTipoReem+cForReem+cLojReem))

		If SE2->E2_SALDO == SE2->E2_VALOR .And. Empty(SE2->E2_BAIXA) .And. Empty(SE2->E2_NUMBOR)
			
			T_AE_EXCSE2( .F. , SE2->(RECNO()) )
			
		Else
			If !Empty(SE2->E2_NUMBOR)
		   	    Alert(STR0022+SE2->E2_NUMBOR)
		   	Else
				Alert(STR0018 + CRLF + STR0019)
			Endif		
		EndIf
	EndIf

	//Verifica se tem o t�tulo de adiantamento
	If SE2->(DbSeek(xFilial("SE2")+cPrefAdia+cNumReem+cParcAdia+cTipoAdia+cForReem+cLojReem))

		If SE2->E2_SALDO == SE2->E2_VALOR .And. Empty(SE2->E2_BAIXA) .And. Empty(SE2->E2_NUMBOR)
			
			T_AE_EXCSE2( .F. , SE2->(RECNO()) )
			
			RecLock("LHQ",.F.)
			Replace LHQ->LHQ_FLAG With "K"
			MsUnLock()
		Else
			If !Empty(SE2->E2_NUMBOR)
		   	    Alert(STR0022+SE2->E2_NUMBOR)
		   	Else
				Alert(STR0018 + CRLF + STR0019)
			Endif		
		EndIf
	Else	
		RecLock("LHQ",.F.)
		Replace LHQ->LHQ_FLAG With "K"
		MsUnLock()
	EndIf


EndIf

RestArea(aArea)

Return lRet   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_DESPV  �Autor  �Leandro Sousa       � Data �  22/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exclusao de despesas avulsas.                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function AE_DVEXC()
Local aArea			:= GetArea()
Local lRet			:= .F.
Local cPrefReem		:= GetMV("MV_PREREEM")
Local cParcReem		:= GetMV("MV_PARREEM")
Local cTipoReem		:= GetMV("MV_TIPREEM")
Local cCodigo		:= ""
Local cNumReem		:= ""
Local cForReem		:= ""
Local cLojReem		:= ""
Local cChvSE2		:= ""
Local nTamChv		:= 0
Local lExc			:= .F.

nTamChv := TamSX3("E2_FILIAL")[1] + TamSX3("E2_PREFIXO")[1] + TamSX3("E2_NUM")[1] + TamSX3("E2_PARCELA")[1] + TamSX3("E2_TIPO")[1] + TamSX3("E2_FORNECE")[1] + TamSX3("E2_LOJA")[1]

If Empty(cPrefReem)
	cPrefReem := Space(TamSX3("E2_PREFIXO")[1])
Else
	cPrefReem := PadR(cPrefReem,TamSX3("E2_PREFIXO")[1])	
EndIf

If Empty(cParcReem)
	cParcReem := Space(TamSX3("E2_PARCELA")[1])
Else
	cParcReem := PadR(cParcReem,TamSX3("E2_PARCELA")[1])
EndIf

If Empty(cTipoReem)
	cTipoReem := Space(TamSX3("E2_TIPO")[1])     
Else
	cTipoReem := PadR(cTipoReem,TamSX3("E2_TIPO")[1])
EndIf

dbSelectArea("LHQ")

DbSelectArea("LHP")
LHP->(DbSetOrder(1))

If LHQ->LHQ_TPDES == "A" .And. LHQ->LHQ_Flag == "K"
	lRet := MsgYesNo(STR0017)
ElseIf LHQ->LHQ_TPDES == "A"
	lRet := MsgYesNo(STR0016)
Else
	// Na primeira chamada da fun��o AE_EXCSE2 a fun��o verificar se houve baixas.
	// Guardo o conteudo do Campo LHQ_CODIGO para ter controle do que foi excluido ou n�o.
	LHP->( DbSeek( xFilial("LHP") + LHQ->LHQ_CODIGO ) )
	cCodigo := LHQ->LHQ_CODIGO
	cChvSE2 := PadR( LHP->LHP_DOCUME, nTamChv )
	lRet 	:= T_AE_EXCSE2( .T. )
	lExc	:= .T.
EndIf

If lRet .And. lExc
	
	If LHP->( DbSeek( xFilial("LHP") + cCodigo ) )
	
		cNumReem := PadR( LHP->LHP_CODIGO, TamSX3("E2_NUM")[1] )
			
		DbSelectArea("SA2")
		SA2->(DbOrderNickName("SA2CDV6"))
		If SA2->( DbSeek(xFilial("SA2") + LHP->LHP_FUNC ) )
			cForReem := SA2->A2_COD
			cLojReem := SA2->A2_LOJA
		EndIf
		
		cChvSE2 := xFilial("SE2") + cPrefReem + cNumReem + cParcReem + cTipoReem + cForReem + cLojReem
		
		// Se o titulo for encontrado na SE2 mesmo ap�s j� ter executado a chamada da fun��o T_AE_EXCSE2( .T. )
		// significa que o titulo n�o possuia baixas, desta forma posiciono do titulo e fa�o a exclus�o
		DbSelectArea("SE2")
		SE2->(DbSetOrder(1))
		If SE2->( DbSeek( cChvSE2 ) )
		
			If SE2->E2_SALDO == SE2->E2_VALOR .And. Empty(SE2->E2_BAIXA) // Se o Titulo possui o E2_Saldo igual ao E2_Valor e o campo data de Baixa estiver vazio o titulo n�o possui baixas 
				
				T_AE_EXCSE2( .F., SE2->(RECNO()) )// T_AE_EXCSE2( lTemBaixa, nRecno )
				
			Else
				Alert( STR0018 + CRLF + STR0020 )
				lRet := .F.	
			EndIf
		Else
			DVAVExc()
		EndIf
	EndIF
EndIf

RestArea(aArea)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_DESPV  �Autor  �Flavio Vilarim      � Data �  23/10/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exclusao dos registros da despesas avulsas. LHQ, LHP e LHR  ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                         
Static Function DVAVExc()  

RecLock("LHQ",.F.)
DbDelete()
MsUnLock()	

RecLock("LHP",.F.)
DbDelete()
MsUnLock()

DbSelectArea("LHR")
LHR->(DbSetOrder(1))
If (DbSeek(xFilial("LHQ")+LHQ->LHQ_CODIGO)) 
	While !Eof() .And. xFilial("LHR")+LHR->LHR_CODIGO  ==  xFilial("LHQ")+LHQ->LHQ_CODIGO 
		RecLock("LHR",.F.)
		DbDelete()
		MsUnLock()
		dbSkip()
	EndDo 
EndIf	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_DESPV  �Autor  �Rodrigo Oliveira    � Data �  04/12/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exclusao de despesas no Financeiro.                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function AE_EXCSE2( lTemBaixa, nRecSe2 )

Local aArea		:= GetArea()
Local lRet		:= .F.
Local cQuery	:= "" 
Local lFunname	:= FunName() $ "FINA050|FINA750"
Local cTit		:= ""
Local aDados	:= {}
Local cTmp		:= ""

//-- Vari�veis utilizadas para o controle de erro da rotina autom�tica
Private lMsErroAuto		:= .F.

Default lTemBaixa	:= .T.
Default nRecSe2		:= 0

If lTemBaixa // Verifico se tem baixa para o titulo
	If lFunname
		cTit := SE2->E2_NUM
	Else
		Posicione("LHP",1,xFilial("LHQ") + LHQ->LHQ_CODIGO,"LHP_DOCUME") 
		cTit := LHP->LHP_DOCUME
	EndIf
	
	cQuery := "SELECT SE2.E2_NUM TIT, SE2.E2_SALDO SLD, SE2.E2_VALOR VALOR, SE2.E2_BAIXA DTBX, SE2.E2_NUMBOR NUMB, SE2.R_E_C_N_O_ Rec, SE5.R_E_C_N_O_ RECSE5 "
	cQuery += " FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += " INNER JOIN " + RetSqlName("SE5") + " SE5 "
	cQuery += 		" ON E5_FILIAL = E2_FILIAL "
	cQuery += 		" AND E5_PREFIXO = E2_PREFIXO "
	cQuery += 		" AND E5_NUMERO = E2_NUM "
	cQuery += 		" AND E5_PARCELA = E2_PARCELA "
	cQuery += 		" AND E5_TIPO = E2_TIPO "
	cQuery += 		" AND E5_CLIFOR = E2_FORNECE "
	cQuery += 		" AND E5_LOJA = E2_LOJA "
	cQuery += " WHERE"
	cQuery += " SE2.E2_FILIAL || SE2.E2_PREFIXO || SE2.E2_NUM || SE2.E2_PARCELA || SE2.E2_TIPO || SE2.E2_FORNECE || SE2.E2_LOJA = '" + cTit + "'"
	cQuery += " AND SE2.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	cTmp   := GetNextAlias() 
	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cTmp, .F., .T. )
	 
	If !Empty( (cTmp)->TIT )
		If !lFunname
			If (cTmp)->( SLD != VALOR .AND. DTBX != '' )
				Alert( STR0018 + chr(10) + chr(13) + If( LHQ->LHQ_FLAG == "K", STR0020, STR0019 ) )
			ElseIf !Empty( (cTmp)->NUMB )
				Alert(STR0022 + (cTmp)->NUMB)
			Else
				SE2->(DbGoTo( (cTmp)->Rec))
				
				//-- Monta Array para ExecAuto do Titulo Retentor
		 		aEval( SE2->(DbStruct()), {|x| AAdd( aDados, { x[1], SE2->&(x[1]), NIL } ) } )
		 		aAreaTMP :=(cTmp)->( GetArea() )	
				MSExecAuto( { |x, y, z| FINA050( x, y, z ) }, aClone( aDados ), 5, 5 )
				
				If lMsErroAuto
					MostraErro()
				Else				
					lRet := .T.
				EndIf
				RestArea( aAreaTMP )
			EndIf
		EndIf
	Else
		lRet := .T.
	EndIf
	
	If Select( (cTmp) ) > 0
		(cTmp)->(DbCloseArea())
	EndIf
	
Else // Se n�o tem baixa fa�o a exclus�o do titulo
	If !lFunName
		SE2->( DbGoTo( nRecSe2 ) )
		
		//-- Monta Array para ExecAuto do Titulo Retentor
		aEval( SE2->(DbStruct()), {|x| AAdd( aDados, { x[1], SE2->&(x[1]), NIL } ) } )
			
		MSExecAuto( { |x, y, z| FINA050( x, y, z ) }, aClone( aDados ), 5, 5 )
		
		If lMsErroAuto
			MostraErro()
		Else
			If !FwIsInCallStack("T_AE_DVCANC")
				DVAVExc()
			EndIf
			lRet := .T.
		EndIf
	Else
		cQuery	:= " SELECT R_E_C_N_O_ RECNO "
		cQuery	+= " FROM " + RetSqlName("LHP")
		cQuery	+= " WHERE LHP_FILIAL = '"+xFilial("LHP")+"' "
		cQuery 	+= " AND LHP_DOCUME = '"+ xFilial("LHP")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+"' "
		cQuery 	+= " AND D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)
		cTmp   := GetNextAlias() 
		DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cTmp, .F., .T. )
		
		If (cTmp)->RECNO > 0 
			lRet	:= .F.
		Else
			lRet	:= .T.
		EndIf
		
		If Select( (cTmp)  ) > 0
			(cTmp)->(DbCloseArea())
		EndIf
	
	EndIf	
EndIf

RestArea(aArea)

Return lRet