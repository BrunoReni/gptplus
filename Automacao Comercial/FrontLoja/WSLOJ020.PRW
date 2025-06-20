#INCLUDE "WSLOJ020.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"     
#DEFINE _FORMATEF				 "CC;CD" //Formas de pagamento que utilizam opera��o TEF para valida��o

Function WSLOJ020
Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LjFinaCB  �Autor  �Vendas Clientes     � Data �  12/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Webservices de inclusao e exclusa� de titulo na retaguarda ���
���          � para correspondnte bancario.                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSSERVICE LjFinaCB DESCRIPTION STR0001 	     	// "Servi�o de inclusao e exclus�o de titulo para correspondente bancario (<b>Automa��o Comercial</b>)"

	WSMETHOD IncluiTit   DESCRIPTION STR0002 		// "Inclui os valores da transa��o de correspondente bancario em dinheiro ou cheque"
	WSMETHOD EstornaTit  DESCRIPTION STR0003        // "Estorna os valores da transa��o de correspondente bancario"
   	WSMETHOD Conecta  	 DESCRIPTION STR0004		// "Verifica se o WebService de correspondente bancario esta conectado"

	WSDATA cPref 		As String 
	WSDATA cNumTit		As String 
	WSDATA cParcela		As String 
	WSDATA cTipo		As String 
	WSDATA cNatureza	As String
	WSDATA cCliente		As String 
	WSDATA cLoja		As String 
	WSDATA dEmiss		As Date
	WSDATA dVencto		As Date
	WSDATA cHist		As String
	WSDATA nMoeda		As Float
	WSDATA cRotina		As String
	WSDATA nValtit		As Float
	WSDATA cPortado		As String
	WSDATA lRet 		As Boolean
	WSDATA cBanco		As String
	WSDATA cAgencia		As String
	WSDATA cConta		As String
	WSDATA cNumChq		As String
	WSDATA cCompensa	As String
	WSDATA cRg			As String
	WSDATA cTel			As String
	WSDATA lTerceiro	As Boolean  
	WSDATA cNsuSiTef	As String 
	WSDATA cValor		As String
	WSDATA lDirecao		As Boolean OPTIONAL  	    
	WSDATA cNsuCart  	As String OPTIONAL  
	WSDATA cCodAdm		As String OPTIONAL  
	WSDATA cNumMov		As String OPTIONAL

	
ENDWSSERVICE

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IncluiTit �Autor  �Microsiga           � Data �  12/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que inclui um titulo baixado e gera moviemnto       ���
���          � bancario                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD IncluiTit WSRECEIVE 	cPref		, cNumTit	, cParcela	, cTipo		, ;
								cNatureza	, cCliente	, cLoja		, dEmiss	, ;
								dVencto		, cHist		, nMoeda	, cRotina	, ;
								nValtit 	, cPortado	, cBanco	, cAgencia	, ;
								cConta		, cNumChq	, cCompensa , cRg 		, ;
								cTel		, lTerceiro , cNsuSiTef , cNsuCart  , ;
								cCodAdm		, lDirecao  , cNumMov 	WSSEND lRet WSSERVICE LjFinaCB
	
	Local aDados	:= {}			//Campos do SE1 que necessitam ser enviados
	Local aArea	    := GetArea()    //WorkArea Ativa
	Local cDescAdm  := ""           //Nome da Adminstradora 
	Local aRetTp	:= {}           //Dados da Adminisradora
	Local nDias		:= 0            //Dias
	Local nTaxa		:= 0            //Taxa da Adm do Cartao
	Local lRet      := .T.

	Private lMsErroAuto := .F. 
	
	DEFAULT lDirecao := .F. //GP Dire��o
	DEFAULT cNsuCart := ""
	DEFAULT cNumMov  := ""
    
    If lDirecao .AND. cTipo $ "CC;CD" .AND. !Empty(cCodAdm)
        SAE->(DbSetOrder(1))//AE_FILIAL+AE_COD                                                                                                                                                
        SAE->(DbSeek(xFilial("SAE")+cCodAdm))
 
 		aRetTp := LjGrvTpFin( SAE->AE_FINPRO, If( SAE->(FieldPos("AE_AGLPARC")) > 0, SAE->AE_AGLPARC, 2 ) )
		lAdmProp	:= aRetTp[2] 
		
		If !lAdmProp

            If SAE->( ColumnPos("AE_LOJCLI") ) > 0 .And. !Empty(SAE->AE_CODCLI) .And. !Empty(SAE->AE_LOJCLI)

                cCliente := SAE->AE_CODCLI
                cLoja	 := SAE->AE_LOJCLI
            Else

    			cCliente :=  SAE->AE_COD
	    		cLoja 	 :=  "01"
            EndIf

			cDescAdm :=  SAE->AE_DESC
		Else

			nDias := SAE->AE_DIAS
		EndIf 
		
		nTaxa := SAE->AE_TAXA
    EndIf

    If lDirecao .AND. Empty(cNatureza)
    	cNatureza := SuperGetMv("MV_NATCB")
    EndIf

   	aDados  := {   	{ "E1_PREFIXO"	,cPref					  				,Nil} ,;
					{ "E1_NUM"	  	,cNumTit 				   				,Nil} ,;
					{ "E1_PARCELA" 	,cParcela				 				,Nil} ,;
					{ "E1_TIPO"	 	,cTipo					 				,Nil} ,;
					{ "E1_NATUREZ" 	,cNatureza				 				,Nil} ,;
		          	{ "E1_CLIENTE" 	,cCliente				 				,Nil} ,;
	             	{ "E1_LOJA"	  	,cLoja				  					,Nil} ,;
		          	{ "E1_EMISSAO" 	,dEmiss 								,Nil} ,;
			       	{ "E1_VENCTO"  	,dVencto+nDias			  				,Nil} ,;
			       	{ "E1_VENCREA" 	,DataValida(dVencto+nDias)	  			,Nil} ,;
			       	{ "E1_HIST" 	,cHist					  				,Nil} ,;
			       	{ "E1_MOEDA" 	,nMoeda									,Nil} ,;
					{ "E1_ORIGEM"	,cRotina								,Nil} ,;
					{ "E1_FLUXO"	,"S"						 			,Nil} ,;
				   	{ "E1_VALOR"	,(nValTit - ((nValTit * nTaxa)/100)	)	,Nil} ,;
				   	{ "E1_PORTADO"	,cPortado				  				,Nil} ,;
				   	{ "E1_BCOCHQ"	,cBanco					 				,Nil} ,;
				   	{ "E1_AGECHQ" 	,cAgencia				  				,Nil} ,;
				   	{ "E1_CTACHQ"	,cConta					   				,Nil} ,;
				   	{ "E1_DOCTEF"	,cNsuSiTef                  			,Nil} }
	
	If RTrim(cTipo) $ "CC;CD" .AND. SE1->(FieldPos("E1_NSUTEF")) > 0  
		aAdd(aDados, {"E1_NSUTEF"   , cNsuCart	, Nil})
		aAdd(aDados, {"E1_VLRREAL"  , nValTit   , Nil})
	EndIf

	If SE1->(FieldPos("E1_NUMMOV")) > 0
		aAdd(aDados, {"E1_NUMMOV", cNumMov	, Nil})	
	EndIf

	MSExecAuto( { |x,y| Fina040( x, y ) }, aDados, 3 ) //Inclusao 
	
	If lMsErroAuto
		ConOut(STR0005 + 'Fina040' + STR0006 + 'IncluiTit' + STR0007) //#STR0005->"Erro ao executar a rotina automatica " ##STR0006->" no metodo " ###STR0007->" do fonte 'WSLOJ020.PRW':"
		ConOut( MostraErro() )
		lRet := .F.
	EndIf

	If lDirecao .AND. RTrim(cTipo) $ "CC;CD" 
   		
   		If !Empty(cDescAdm) 
   			RecLock("SE1", .F.)
   			Replace SE1->E1_NOMCLI With cDescAdm
   			SE1->(MsUnLock())
   		EndIf
   		
   		If AliasInDic("MEP") 
	   		RecLock("MEP", .T.)
	   		REPLACE MEP->MEP_FILIAL WITH xFilial("MEP")
	   		REPLACE MEP->MEP_PREFIX WITH SE1->E1_PREFIXO
	   		REPLACE MEP->MEP_NUM 	WITH SE1->E1_NUM
	   		REPLACE MEP->MEP_PARCEL WITH SE1->E1_PARCELA
	   		REPLACE MEP->MEP_TIPO   WITH SE1->E1_TIPO
	   		REPLACE MEP->MEP_PARTEF WITH StrZero(1, TAMSX3("MEP_PARTEF")[1])
	   		MEP->(MsUnLock())  
   		EndIf

	EndIf
	If cTipo == "CH"
		LJRecGrvCH( cBanco  , cAgencia , cConta   , cNumChq	,;
 					nValTit , dEmiss   , cCompensa, cRg    	,;
	                cTel    , lTerceiro, cPref	  , cNumTit	,;
	    			cParcela, cTipo  )
	 	RecLock("SEF", .F.)
	 	REPLACE SEF->EF_CLIENTE WITH cCliente
	 	REPLACE SEF->EF_LOJACLI WITH SA1->A1_LOJA
	 	REPLACE SEF->EF_EMITENT	WITH SA1->A1_NOME
	 	REPLACE SEF->EF_NUMNOTA	WITH cNumTit
	 	REPLACE SEF->EF_SERIE	WITH cPref
	 	MSUnlock()
	EndIf
		
	If cTipo == SuperGetMV( "MV_SIMB1" )
		aDados	:= {	{ "E1_PREFIXO" 	,E1_PREFIXO			, Nil},	;// 01
						{ "E1_NUM"     	,E1_NUM				, Nil},	;// 02
						{ "E1_PARCELA" 	,E1_PARCELA			, Nil},	;// 03
						{ "E1_TIPO"    	,E1_TIPO			, Nil},	;// 04
						{ "E1_MOEDA"    ,E1_MOEDA			, Nil},	;// 05
						{ "E1_TXMOEDA"	,E1_TXMOEDA			, Nil},	;// 06
						{ "E1_ORIGEM"	,E1_ORIGEM			, Nil},	;// 07
						{ "AUTVALREC"	,E1_VALOR  			, Nil},	;// 06
						{ "AUTMOTBX"  	,"NOR"				, Nil},	;// 07
						{ "AUTDTBAIXA"	,dDataBase			, Nil},	;// 08
						{ "AUTDTCREDITO",dDataBase			, Nil},	;// 09
						{ "AUTHIST"   	,cHist				, Nil}  }// 13
	    
		// Verifica se deu algum erro no MSExecAuto anterior
		If !lMsErroAuto
			
			MSExecAuto( { |x,y| FINA070( x, y ) }, aDados, 3 )
		
			If lMsErroAuto
				ConOut(STR0005 + 'FINA070' + STR0006 + 'IncluiTit' + STR0007) //#STR0005->"Erro ao executar a rotina automatica " ##STR0006->" no metodo " ###STR0007->" do fonte 'WSLOJ020.PRW':"
				ConOut( MostraErro() )
				lRet := .F.
			Else
				If SE5->(FieldPos("E5_NUMMOV")) > 0 .And. SE5->(Reclock("SE5",.F.))
					Replace SE5->E5_NUMMOV	WITH cNumMov
					SE5->(MSUNLOCK())
				EndIf
			EndIf
		EndIf
	Endif
		
	If lMsErroAuto
		DisarmTransaction()
		lRet := .F.
	EndIf

	RestArea( aArea )
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EstornaTit�Autor  �Microsiga           � Data �  12/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que exclui o titulo de correspondente bancario      ���
���          � SE1 e inclui registro de estorno no SE5                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD EstornaTit WSRECEIVE cNsuSiTef, lDirecao WSSEND lRet WSSERVICE LjFinaCB   
								
	Local aDados	:= {}			// Campos do SE1 que necessitam ser enviados
	Local aArea	    := GetArea()
	Local aAreaSE5  := SE5->(GetArea())
	Local aVet070   := {} 
	Local cSimb1    := SuperGetMV( "MV_SIMB1" )

	Private lMsErroAuto := .F.
	Private cPaisLoc    := "BRA"
	
	DEFAULT lDirecao    := .F.

	//Pega Numero do Titulo Registro do SE1
    DBSelectArea("SE1")
    SE1->(DBOrderNickName("idxFINA01"))		   // E1_FILIAL + E1_DOCTEF     
	If DbSeek(xFilial("SE1")+ cNsuSiTef)       // Busca exata   
		aDados  := {{"E1_PREFIXO"	, SE1->E1_PREFIXO   ,	Nil},;
   				   	{"E1_NUM"		, SE1->E1_NUM	    , 	Nil},;
					{"E1_PARCELA"	, SE1->E1_PARCELA	,	Nil},;
					{"E1_TIPO"		, SE1->E1_TIPO	    , 	Nil},;
					{"E1_NATUREZ"	, SE1->E1_NATUREZ   ,	Nil},;
					{"E1_CLIENTE"	, SE1->E1_CLIENTE   ,   Nil},;
					{"E1_LOJA"		, SE1->E1_LOJA      ,	Nil},;
					{"E1_MOEDA"		, SE1->E1_MOEDA	    ,	NIL}}

		SE5->(DbSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
		If SE5->(DbSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA ))
			aVet070 := {{"E1_PREFIXO"	, SE5->E5_PREFIXO 		,Nil},;
				{"E1_NUM"		, SE5->E5_NUMERO       	,Nil},;
				{"E1_PARCELA"	, SE5->E5_PARCELA  		,Nil},;
				{"E1_TIPO"	    , SE5->E5_TIPO     		,Nil},;
				{"AUTMOTBX"	    , SE5->E5_MOTBX      	,Nil},;
				{"AUTDTBAIXA"	, SE5->E5_DATA			,Nil},;
				{"AUTDTCREDITO" , SE5->E5_DTDISPO		,Nil},;
				{"AUTHIST"	    , STR0003+": "+Alltrim(SE5->E5_PREFIXO)+Alltrim(SE5->E5_NUMERO)+Alltrim(SE5->E5_PARCELA)+Alltrim(SE5->E5_TIPO) ,Nil},; //"Estorna os valores da transa��o de correspondente bancario"
				{"AUTVALREC"	, SE5->E5_VALOR		    ,Nil}}
		EndIf 
		
		If lDirecao .AND. RTrim(SE1->E1_TIPO) $ "CC/CD" .AND. AliasInDic("MEP") 
				   
		   MEP->(DbSetOrder(1)) //MEP_FILIAL+MEP_PREFIX+MEP_NUM+MEP_PARCEL+MEP_TIPO 
		   If MEP->(DbSeek(xFilial("MEP") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO) ))   
	   			RecLock("MEP", .F.)
	   			MEP->(DbDelete())
		   EndIf
				
		EndIf 
						
	EndIf   

	If AllTrim(SE1->E1_TIPO) == AllTrim(cSimb1)
		//Executa o Cancelamento da Baixa do Titulo
		MSExecAuto({|x,y| Fina070(x,y)},aVet070,5)  
	EndIf
	 
	If lMsErroAuto  
		ConOut( MostraErro() )
		DisarmTransaction() 
		lRet := .F.
	Else

		MSExecAuto( { |x,y| Fina040( x, y ) }, aDados, 5 ) //Exclus�o      
		
		If lMsErroAuto  
			ConOut( MostraErro() )
			DisarmTransaction() 
			lRet := .F.
		Else
			lRet := .T.
		EndIf 
	EndIf 	
	

	RestArea(aAreaSE5)
	RestArea( aArea )
 
Return( lRet )								

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Conecta   �Autor  �Microsiga           � Data �  16/01/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se o WS esta conectado					          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD Conecta WSRECEIVE cValor WSSEND lRet WSSERVICE LjFinaCB

  	lRet := .T.

Return lRet
