#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "WSFRTVP.CH"
 
User Function _PYPTXRK ; Return  // "dummy" function - Internal Use 

WSSTRUCT WSValePre
	WSDATA Codigo		AS String
	WSDATA Valor		AS Float
	WSDATA Produto   	AS String
	WSDATA Operacao     AS Float
ENDWSSTRUCT

WSSTRUCT WSVPreEst
	WSDATA cCodigo		AS String
	WSDATA cOperacao    AS String
ENDWSSTRUCT

WSSTRUCT WSValeArray
	WSDATA VerArray AS ARRAY OF WSVPreEst
ENDWSSTRUCT


WSSERVICE FRTValePre DESCRIPTION STR0001	//"Servi�o de vales presentes"
	WSDATA ValePre		AS WSValePre
	WSDATA cCodigo		AS String
	WSDATA cDoc 		AS String
	WSDATA cVend 		AS String
	WSDATA cCaixa 		AS String
	WSDATA cOper 		AS String
	WSDATA dData		AS Date
	WSDATA cHora		AS String
	WSDATA cCliente		AS String         
	WSDATA cLoja		AS String
	WSDATA cEstacao		AS String
	WSDATA cPDV			AS String
	WSDATA cSerie		AS String
	WSDATA nValor		AS Float
	WSDATA cMessage		AS String
	WSDATA aVPreEst		AS WSValeArray
	WSDATA cEmpPdv   	  AS String     OPTIONAL
	WSDATA cFilPdv   	  AS String     OPTIONAL
	

	WSMETHOD VldVale	DESCRIPTION STR0002	//"Valida o vale presente solicitado"
	WSMETHOD UpdVenda	DESCRIPTION STR0003	//"Atualiza a situa��o dos vales presentes vendidos"
	WSMETHOD UpdRecebto	DESCRIPTION STR0004	//"Atualiza a situa��o dos vales presentes recebidos"
	WSMETHOD ValorVale	DESCRIPTION STR0005 //"Retorna o valor de face do vale presente"
	WSMETHOD VPEstorna 	DESCRIPTION STR0006 //"Estorna o Status do VP"
ENDWSSERVICE
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo	 �VldVale   � Autor � Venda Clientes        � Data �23/04/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o codigo do vale informado                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 - Objeto vale presente                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � ExpC1 - Mensagem de erro (ou branco quando OK)             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FrontLoja												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD VldVale WSRECEIVE ValePre,cEmpPdv,cFilPdv WSSEND cMessage WSSERVICE FRTValePre

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(cEmpPdv,cFilPdv) 

::cMessage := LjVldVP( ::ValePre:Produto, ::ValePre:Codigo, ::ValePre:Valor, ::ValePre:Operacao )
	
Return (.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo	 �UpdVenda  � Autor � Venda Clientes        � Data �18/04/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza os vales presentes vendidos            			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - Array com os codigos dos vales vendidos            ���
���          � ExpC1 - Numero do cupom fiscal da venda                    ���
���          � ExpC2 - Codigo do PDV                                      ���
���          � ExpC3 - Codigo do vendedor                                 ���
���          � ExpD1 - Data da venda                                      ���
���          � ExpC4 - Hora da venda                                      ���
���          � ExpC5 - Cliente da venda     							  ���
���          � ExpC6 - Loja da venda        							  ���
���          � ExpC7 - Estacao da venda                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � .T.                   						              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FrontLoja												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD UpdVenda WSRECEIVE cCodigo		, cVend		, cDoc		, cEstacao	,;
							cPDV	 	, dData		, cHora		, cCliente	,;
							cLoja 		, cSerie		,cEmpPdv		,cFilPdv WSSEND cMessage WSSERVICE FRTValePre

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(cEmpPdv,cFilPdv) 

LjGrVVP( ::cCodigo	, ::cVend, ::cDoc , ::cEstacao,;
		 ::cPDV		, ::dData, ::cHora, ::cCliente,;
		 ::cLoja 	, ::cSerie, ::cEmpPdv, ::cFilPdv)

::cMessage := ""

Return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo	 �UpdRecebto� Autor � Venda Clientes        � Data �18/04/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza os vales presentes vendidos            			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - Array com os codigos dos vales vendidos            ���
���          � ExpC1 - Caixa que recebeu o cupom                          ���
���          � ExpC2 - Numero do cupom fiscal da venda                    ���
���          � ExpC3 - Estacao da venda                                   ���
���          � ExpC4 - Codigo do PDV                                      ���
���          � ExpD1 - Data da venda                                      ���
���          � ExpC5 - Hora da venda                                      ���
���          � ExpC6 - Cliente da venda     							  ���
���          � ExpC7 - Loja da venda        							  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � .T.                   						              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FrontLoja												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD UpdRecebto WSRECEIVE 	cCodigo		, cCaixa	, cDoc		, cEstacao	,;
								cPDV		, dData		, cHora		, cCliente	,;
								cLoja		, cSerie ,cEmpPdv		,cFilPdv	WSSEND cMessage WSSERVICE FRTValePre

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(cEmpPdv,cFilPdv) 

LjGrRVlPre(	::cCodigo	, ::cCaixa, ::cDoc , ::cEstacao,;
			::cPDV		, ::dData , ::cHora, ::cCliente,;
			::cLoja 	, ::cSerie)

::cMessage := ""

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo	 �VldVale   � Autor � Venda Clientes        � Data �23/04/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o codigo do vale informado                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 - Objeto vale presente                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � ExpC1 - Mensagem de erro (ou branco quando OK)             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FrontLoja												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD ValorVale WSRECEIVE ValePre,cEmpPdv		,cFilPdv WSSEND nValor WSSERVICE FRTValePre

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(cEmpPdv,cFilPdv) 

::nValor := LjVPValor( ::ValePre:Codigo )
	
Return (.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo	 �VPEstorna � Autor � Venda Clientes        � Data �10/05/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Recebe o Array e chama a funcao para o estorno do VP.      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - Array contendo o Codigo e o tipo de oper a executar���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FrontLoja												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD VPEstorna WSRECEIVE  aVPreEst,cEmpPdv ,cFilPdv WSSEND cMessage WSSERVICE FRTValePre

Local lRet		:= .T.
Local aVerOk    := {}
Local nX 		:= 0

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(cEmpPdv,cFilPdv) 

//�������������������������������������������������������
//�Recebe o aVpEst que contem os VPs a serem estornados �
//�������������������������������������������������������
For nX := 1 to Len( ::aVPreEst:VerArray )
	AAdd( aVerOk, Array(2))
	aVerOk[nX][1] := ::aVPreEst:VerArray[nX]:cCodigo
	aVerOk[nX][2] := ::aVPreEst:VerArray[nX]:cOperacao
Next nX	

lRet	:= LjVpAtiva(aVerOk)

If !lRet
	SetSoapFault("Erro LjVpAtiva", "Erro LjVpAtiva")	
EndIf

::cMessage := ""
	
Return (lRet)
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LjVpAtiva � Autor � Vendas Clientes       � Data � 22/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina para voltar o status do Vale Presente                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �WSFRTVP                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LjVpAtiva( aVPreEst )

Local lRet			:= .F.	// Retorno Logico
Local nX 			:= 0	// Variavel de contador
Local nTamCod  		:= 0	// Tamanho do campo L1_SERIE
Local nValorVP		:= 0	// Valor do Vale Presente

LjGrvLog( , "LjVpAtiva | Rotina para voltar o status do Vale Presente  -> Inicio " , )

If AliasIndic("MDD") .AND. Len(aVPreEst) > 0

	nTamCod  	:= TamSX3("MDD_CODIGO")[1] 
	DbSelectArea("MDD")
	DbSetOrder(1)
	//���������������������������������������������������������������Ŀ
	//� Altera o Status do Vale Presente , Caso aVPreEst[nX][2] == 1  �
	//� Vale foi vendido , caso 2 ele foi usado como forma de pgto    �
	//�����������������������������������������������������������������
	For nX := 1 to Len(aVPreEst)
		
		LjGrvLog( , "LjVpAtiva | Busca na MDD -> " + xFilial("MDD") + PadR(aVPreEst[nX][1],nTamCod) , )

		If DbSeek( xFilial("MDD")+ PadR(aVPreEst[nX][1],nTamCod) ) 
			LjGrvLog( , "LjVpAtiva | Vale presente encontrado: " + xFilial("MDD")+ PadR(aVPreEst[nX][1],nTamCod) , )

			RecLock( "MDD", .F. )
			REPLACE MDD->MDD_CAIXA	WITH ""
			REPLACE MDD->MDD_LOJAR	WITH ""
			REPLACE MDD->MDD_DOCR	WITH ""
			REPLACE MDD->MDD_SERIR	WITH ""
			REPLACE MDD->MDD_ESTR	WITH ""
			REPLACE MDD->MDD_PDVR	WITH ""
			REPLACE MDD->MDD_DATAR	WITH CTOD("  /  /  ")
			REPLACE MDD->MDD_HORAR	WITH ""
			REPLACE MDD->MDD_CLIR	WITH ""
			REPLACE MDD->MDD_LJCLIR	WITH ""
			REPLACE MDD->MDD_STATUS	WITH aVPreEst[nX][2]    
			//������������������������������������������������������������������Ŀ
			//� Caso seja VP status "1" (vendido) zera tambem os campos da venda �
			//��������������������������������������������������������������������
			If aVPreEst[nX][2] == "1"
				REPLACE MDD->MDD_DOCV	WITH ""
				REPLACE MDD->MDD_PDVV	WITH ""
				REPLACE MDD->MDD_SERIV	WITH ""
				REPLACE MDD->MDD_ESTV	WITH ""
				REPLACE MDD->MDD_DATAV	WITH CTOD("  /  /  ")
				REPLACE MDD->MDD_HORAV	WITH ""				
				REPLACE MDD->MDD_CLIV	WITH ""
				REPLACE MDD->MDD_LJCLIV	WITH ""	  
				REPLACE MDD->MDD_VEND	WITH ""
				REPLACE MDD->MDD_SALDO	WITH 0
			EndIf
			MDD->( MsUnlock() )
			lRet := .T.
		Else
			LjGrvLog( , "LjVpAtiva | Vale presente n�o encontrado: " + xFilial("MDD")+ PadR(aVPreEst[nX][1],nTamCod) , )
		EndIf
	Next nX	
Endif

LjGrvLog( , "LjVpAtiva | Rotina para voltar o status do Vale Presente  -> Fim | lRet: " + cValToChar( lRet ), )

Return(lRet)
