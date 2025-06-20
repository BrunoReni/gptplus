#Include "Ctbr046.Ch"
#Include "PROTHEUS.Ch"

#DEFINE 	COL_SEPARA1			1
#DEFINE 	COL_CONTA 			2
#DEFINE 	COL_SEPARA2			3
#DEFINE 	COL_DESCRICAO		4
#DEFINE 	COL_SEPARA3			5
#DEFINE 	COL_SALDO_ANT    	6
#DEFINE 	COL_SEPARA4			7
#DEFINE 	COL_VLR_DEBITO   	8
#DEFINE 	COL_SEPARA5			9
#DEFINE 	COL_VLR_CREDITO  	10
#DEFINE 	COL_SEPARA6			11
#DEFINE 	COL_MOVIMENTO 		12
#DEFINE 	COL_SEPARA7			13
#DEFINE 	COL_SALDO_ATU 		6
#DEFINE 	COL_SEPARA8			15


// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR046	� Autor � Getulio de A. Oliveira� Data � 04.11.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Analitico Sintetico Modelo IV			 		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR046()                               			 		  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso    	 � Generico     											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR046()
PRIVATE titulo		:= ""
Private nomeprog	:= "CTBR046"
Private aSelFil	:= {}

CTBR046R4()

//Limpa os arquivos tempor�rios 
CTBGerClean()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR046R4 � Autor� Davi					� Data � 03/09/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Analitico Sintetico Modelo IV - R4                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR040R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR046R4()
Local nQuadro

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������

Private aQuadro := { "","","","","","","",""}              

For nQuadro :=1 To Len(aQuadro)
	aQuadro[nQuadro] := Space(Len(CriaVar("CT1_CONTA")))
Next	

CtbCarTxt()

Pergunte("CTR046",.F.)

oReport := ReportDef()

If Valtype( oReport ) == 'O'
	If ! Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	
	
	oReport:PrintDialog()      
Endif
	
oReport := Nil

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Daniel Sakavicius		� Data � 28/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo relatorio.                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
local aArea	   		:= GetArea()   
Local CREPORT		:= "CTBR046"
Local CTITULO		:= STR0004				   			// "Emissao do Relat. Conf. Dig. "
Local CDESC			:= OemToAnsi(STR0001)+OemToAnsi(STR0002)+OemToAnsi(STR0003)			// "Este programa ira imprimir o Relatorio para Conferencia"
Local cPerg	   		:= "CTR046" 
Local CCOLBAR		:= "|"                   
Local aTamConta		:= TAMSX3("CT1_CONTA")    
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aTamDesc		:= {40}  
Local cPictVal 		:= PesqPict("CT2","CT2_VALOR")
Local nDecimais
Local cMascara		:= ""
Local cSeparador	:= ""
Local nTamConta		:= 30
Local nSomaCol		:= 5
Local aSetOfBook
Local nMaskFator 	:= 1 
Local nImpX

//�����������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros								  �
//� mv_par01				// Data Inicial                  	  		  �
//� mv_par02				// Data Final                        		  �
//� mv_par03				// Conta Inicial                         	  �
//� mv_par04				// Conta Final  							  �
//� mv_par05				// Imprime Contas: Sintet/Analit/Ambas   	  �
//� mv_par06				// Set Of Books				    		      �
//� mv_par07				// Saldos Zerados?			     		      �
//� mv_par08				// Moeda?          			     		      �
//� mv_par09				// Pagina Inicial  		     		    	  �
//� mv_par10				// Saldos? Reais / Orcados	/Gerenciais   	  �
//� mv_par11				// Quebra por Grupo Contabil?		    	  �
//� mv_par12				// Filtra Segmento?					    	  �
//� mv_par13				// Conteudo Inicial Segmento?		   		  �
//� mv_par14				// Conteudo Final Segmento?		    		  �
//� mv_par15				// Conteudo Contido em?				    	  �
//� mv_par16				// Salta linha sintetica ?			    	  �
//� mv_par17				// Imprime valor 0.00    ?			    	  �
//� mv_par18				// Imprimir Codigo? Normal / Reduzido  		  �
//� mv_par19				// Divide por ?                   			  �
//� mv_par20				// Imprimir Ate o segmento?			   		  �
//� mv_par21				// Posicao Ant. L/P? Sim / Nao         		  �
//� mv_par22				// Data Lucros/Perdas?                 		  �
//� mv_par23				// Imprime Quadros Cont�beis?				  �		
//� mv_par24				// Rec./Desp. Anterior Zeradas?				  �		
//� mv_par25				// Grupo Receitas/Despesas?      			  �		
//� mv_par26				// Data de Zeramento Receita/Despesas?		  �		
//� mv_par27                // Num.linhas p/ o Balancete Modelo 1		  � 
//� mv_par28				// Descricao na moeda?                        |
//� mv_par29                // Imprimir ? Normal/Cabecalho/Informacoes	  �		
//�������������������������������������������������������������������������

// Efetua a pergunta antes de montar a configura��o do relatorio, afim de poder definir o layout a ser impresso
Pergunte( "CTR046" , .T. )


//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)	    	  �
//����������������������������������������������������������������
If ! CT046Valid( mv_par06 )
	Return .F.
Else
   aSetOfBook := CTBSetOf( mv_par06 )
Endif

If mv_par28 == 1 .And. Len( aSelFil ) <= 0  .And. !IsBlind()
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		Return .F.
	EndIf 
EndIf

cMascara := RetMasCtb( aSetOfBook[2], @cSeparador )

If ! Empty( cMascara )
	nTamConta := aTamConta[1] + ( Len( Alltrim( cMascara ) ) / 2 )
Else
	nTamConta := aTamConta[1]
EndIf

cPicture := aSetOfBook[4]

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������

//"Este programa tem o objetivo de emitir o Cadastro de Itens Classe de Valor "
//"Sera impresso de acordo com os parametros solicitados pelo"
//"usuario"
oReport	:= TReport():New( cReport,Capital(CTITULO),CPERG, { |oReport| Pergunte(cPerg , .F. ), If(! ReportPrint( oReport ), oReport:CancelPrint(), .T. ) }, CDESC ) 
oReport:ParamReadOnly()

IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

// Controle do tamanho da conta, caso a mesma ultrapasse o tamanho definido de 20, muda o relatorio para o modo paisagem
If nTamConta > 30
	oReport:SetLandScape(.T.)
    nSomaCol := 20
Endif     

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
oSection1  := TRSection():New( oReport, STR0005,/*{"cArqTmp",*/{"CT1","NAOUSA"},, .F., .F. ) //"Plano de contas"

TRCell():New( oSection1, "CONTA"	,,STR0006/*Titulo*/	,/*Picture*/, nTamConta	 + 5		/*Tamanho*/, /*lPixel*/, /*CodeBlock*/  )
TRCell():New( oSection1, "DESCCTA"  ,,STR0007/*Titulo*/	,/*Picture*/, aTamDesc[1]+ nSomaCol	/*Tamanho*/, /*lPixel*/, /*CodeBlock*/  )
TRCell():New( oSection1, "SALDO" 	,,STR0008/*Titulo*/	,/*Picture*/, aTamVal[1] + nSomaCol	/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"CENTER"/*"RIGHT"*/)


If mv_par29 == 2
	
	oSection1:SetHeaderSection(.F.)  
	
	oSection1:Cell("CONTA"):Hide()
	oSection1:Cell("DESCCTA"):Hide()
	oSection1:Cell("SALDO"):Hide()
		
	oReport:OnPageBreak( { || oReport:SkipLine(8)}) 
	lImprime := .F.  
	
ElseIf mv_par29 == 3 
	
	oReport:HideHeader() 
	oReport:OnPageBreak( { || oReport:SkipLine(6)})  

EndIf
       
Return( oReport )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Davi					� Data � 03/09/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou   ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport)                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )  

Local oSection1 	:= oReport:Section(1) 
Local lExterno		:= .F.   
Local aSetOfBook
Local dDataFim 		:= mv_par02  
Local dDataIni      := mv_par01
Local lFirstPage	:= .T.
Local lJaPulou		:= .F.
Local lRet			:= .T.
Local lPrintZero	:= (mv_par17==1)
Local lPula			:= (mv_par16==1) 
Local lNormal		:= (mv_par18==1)
Local lVlrZerado	:= (mv_par07==1)
Local lQbGrupo		:= (mv_par11==1) 
Local lQbConta		:= (mv_par11==2)
Local l132			:= .T.
Local nDecimais
Local nDivide		:= 1
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotMov		:= 0
Local nGrpDeb		:= 0
Local nGrpCrd		:= 0                     
Local cSegAte   	:= mv_par20
Local nDigitAte		:= 0
Local lImpAntLP		:= (mv_par21 == 1)
Local dDataLP		:= mv_par22
Local lImpSint		:= Iif(mv_par05=1 .Or. mv_par05 ==3,.T.,.F.)
Local lRecDesp0		:= (mv_par23 == 1)
Local cRecDesp		:= mv_par24
Local dDtZeraRD		:= mv_par25
Local n
Local oMeter
Local oText
Local oDlg
Local oBreak
Local lImpPaisgm	:= .F.	
Local nMaxLin   	:= mv_par26
Local cMoedaDsc		:= mv_par27
Local aCtbMoeda		:= {}
Local aCtbMoedadsc	:= {}
Local CCOLBAR		:= "|"                   
Local cTipoAnt		:= ""
Local cGrupoAnt		:= ""
Local cArqTmp		:= ""
Local Tamanho		:= "M"
Local cSeparador	:= ""
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local oTotDeb		
Local oTotCrd
Local oTotGerDeb		
Local oTotGerCrd
Local cPicture
Local cContaSint
Local cBreak		:= "2"
Local cGrupo		:= ""
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nTotGerMov	:= 0
Local nCont			:= 0
Local cFilUser		:= ""
Local cCtaAn 		:= ""
Local nOrdenPrn 	:= 0
Local cTpSald		:= IIF(Valtype(mv_par10) == "N",cValToChar(mv_par10),mv_par10)

Private nLinReport    := 9


//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)	    	  �
//����������������������������������������������������������������
If ! CT046Valid( mv_par06 )
	Return .F.
Else
   aSetOfBook := CTBSetOf(mv_par06)
Endif

If mv_par19 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par19 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par19 == 4		// Divide por milhao
	nDivide := 1000000
EndIf	     

If lRet
	aCtbMoeda := CtbMoeda( mv_par08 , nDivide )

	If Empty(aCtbMoeda[1])                       
		Help(" ",1,"NOMOEDA")
		lRet := .F.
		Return lRet
	Endif
	
	If Empty(cTpSald)
		Help(" ",1,"NOTpSald")
		lRet := .F.
		Return lRet
	EndIf

    // valida��o da descri��o da moeda
	if lRet .And. ! Empty( mv_par27 ) .and. mv_par27 <> nil
		aCtbMoedadsc := CtbMoeda( mv_par27 , nDivide )

		If Empty( aCtbMoedadsc[1] )                       
    		Help( " " , 1 , "NOMOEDA")
	        lRet := .F.
    	    Return lRet
	    Endif
	Endif
Endif

If lRet
	If (mv_par23 == 1) .and. ( Empty(mv_par24) .or. Empty(mv_par25) )
		cMensagem	:= STR0009	//"Favor preencher os parametros Grupos Receitas/Despesas e "
		cMensagem	+= STR0010	//"Data Sld Ant. Receitas/Desp. "
		MsgAlert(cMensagem,STR0011)	 //"Ignora Sl Ant.Rec/Des"
		lRet    	:= .F.	
	    Return lRet
    EndIf
EndIf

aCtbMoeda  	:= CtbMoeda(mv_par08,nDivide)                

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par08)

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara 	:= RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf
cPicture 		:= aSetOfBook[4]

lPrintZero	:= Iif(mv_par17==1,.T.,.F.)

Titulo :=	OemToAnsi(STR0004)	//"BALANCETE DE VERIFICACAO SINTETICO DE "

Titulo += 	DTOC(mv_par01) + OemToAnsi(STR0012) + Dtoc(mv_par02) + ;
			OemToAnsi(STR0013) + cDescMoeda + CtbTitSaldo(cTpSald)           

oReport:SetPageNumber( mv_par09 )
oReport:SetCustomText( {|| nCtCGCCabT3(dDataFim,titulo,oReport,dDataIni)})

cFilUser := oSection1:GetAdvplExpr("CT1")    
If Empty(cFilUser)
	cFilUser := ".T."
EndIf	

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao			  		     �
//����������������������������������������������������������������

If lExterno  .or. IsBlind()
	CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
				cTpSald,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
				.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
				cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)
Else
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
					mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
					cTpSald,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
					.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
					cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)},;
					OemToAnsi(OemToAnsi(STR0014)),;  //"Criando Arquivo Tempor�rio..."
					OemToAnsi(STR0003))  				//"Balancete Verificacao"
EndIf                                                          
                
nCount := cArqTmp->(RecCount())

oReport:SetMeter(nCont)

lRet := !(nCount == 0 .And. !Empty(aSetOfBook[5]))

If lRet
	                          
	// Verifica Se existe filtragem Ate o Segmento
	If ! Empty( cSegAte )
		nDigitAte := CtbRelDig( cSegAte, cMascara )	
	EndIf	

	cArqTmp->(dbGoTop())

	
	While !cArqTmp->(Eof() .And. !oReport:Cancel())

		If oReport:Cancel()
    		Exit
		EndIf         
		
		If !Empty(cSegAte)
			If Len(Alltrim(cArqTmp->CONTA)) > nDigitAte
				cArqTmp->(DbSkip())
				Loop
			Endif
		Endif
		
		If lNormal
			oSection1:Cell("CONTA"):SetBlock( {|| EntidadeCTB(cArqTmp->CONTA,000,000,030,.F.,cMascara,cSeparador,,,.F.,,.F.) } )
		Else
			oSection1:Cell("CONTA"):SetBlock( {|| cArqTmp->CTARES } )
		EndIf	
	
		oSection1:Cell("DESCCTA"):SetBlock( { || cArqTMp->DESCCTA } )

		oSection1:Cell("SALDO"):SetBlock( { ||  ValorCTB(cArqTmp->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )

		 If cArqTmp->TIPOCONTA == "2"

			If GETNEWPAR("MV_CTASUP","N") == "S"
				nOrdenPrn := cArqTmp->ORDEMPRN
			Else	
				cCtaAn := cArqTmp->CONTA
			EndIf
			
			cArqTmp->(dbskip())
			
			If cArqTmp->TIPOCONTA == "2"
				
				If GETNEWPAR("MV_CTASUP","N") == "S"
					cArqTmp->(dbSetOrder(2))
					cArqTmp->(dbSeek(nOrdenPrn))
				Else
					cArqTmp->(dbSeek(cCtaAn))
				EndIf	
			
			ElseIf  Empty( cArqTmp->TIPOCONTA ).OR. cArqTmp->TIPOCONTA == "1"
			    
				If GETNEWPAR("MV_CTASUP","N") == "S"
					cArqTmp->(dbSetOrder(2))
					cArqTmp->(dbSeek(nOrdenPrn))
				Else
					cArqTmp->(dbSeek(cCtaAn))
				EndIf	
			    
				oSection1:Init()
				oSection1:PrintLine()
				
				If GETNEWPAR("MV_CTASUP","N") == "S"
				    cArqTmp->(dbSetOrder(3))
					cArqTmp->(dbSeek(cArqTmp->SUPERIOR))
				Else
					cArqTmp->(dbSeek(cArqTmp->SUPERIOR))
				EndIf													
				
				If GETNEWPAR("MV_CTASUP","N") == "S"
				    cArqTmp->(dbSetOrder(2))
					cArqTmp->(dbSeek(nOrdenPrn))
				Else
					cArqTmp->(dbSeek(cCtaAn))
				EndIf	
				
				cArqTmp->(dbSkip())
			
		 	EndIf
		 EndIf															
		 
        oSection1:OnPrintLine( {|| 	CTR046OnPrint( lPula, lQbConta, nMaxLin, @cTipoAnt, @nLinReport, @cGrupoAnt ) } )
		 
		oSection1:Init()
		oSection1:PrintLine()
		
		cArqTmp->(dbSkip())
		
	EnDdo	
	oSection1:Finish()

EndIf

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return .T.

  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTR046OnPrint �Autor � Gustavo Henrique � Data � 07/02/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Executa acoes especificadas nos parametros do relatorio,   ���
���          � antes de imprimir cada linha.                              ���
�������������������������������������������������������������������������͹��
���Parametros� EXPL1 - Indicar se deve saltar linha entre conta sintetica ���
���          � EXPL2 - Indicar se deve quebrar pagina por conta           ���
���          � EXPN3 - Informar o total de linhas por pagina do balancete ���
���          � EXPC4 - Guardar o tipo da conta impressa (sint./analitica) ���
���          � EXPN5 - Guardar linha atual do relatorio para validacao    ���
���          �         com o valor do parametro EXPN3.                    ���
�������������������������������������������������������������������������͹��
���Retorno   � EXPL1 - Indicar se deve imprimir a linha (.T.)             ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTR046OnPrint( lPula, lQbConta, nMaxLin, cTipoAnt, nLinReport )
                                                                        
Local lRet := .T.           

// Verifica salto de linha para conta sintetica (mv_par17)
If lPula .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOCONTA == "1" .And. cTipoAnt == "2"))
	oReport:SkipLine()
EndIf	

// Verifica quebra de pagina por conta (mv_par11)
If lQbConta .And. cArqTmp->NIVEL1
	oReport:EndPage()
	nLinReport := 9
	Return
EndIf	

// Verifica numero maximo de linhas por pagina (mv_par28)
If ! Empty(nMaxLin)
	CTR046MaxL(nMaxLin,@nLinReport)
EndIf	

cTipoAnt := cArqTmp->TIPOCONTA

If mv_par05 == 1		// Apenas sinteticas
	lRet := (cArqTmp->TIPOCONTA == "1")
ElseIf mv_par05 == 2	// Apenas analiticas
	lRet := (cArqTmp->TIPOCONTA == "2")
EndIf

Return lRet
     

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CT046Valid� Autor � Pilar S. Albaladejo   � Data � 24.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Perguntas                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CT046Valid(cSetOfBook)                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T./.F.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Config. Relatorio                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CT046Valid(cSetOfBook)

Local aSaveArea:= GetArea()
Local lRet		:= .T.	

If !Empty(cSetOfBook)
	dbSelectArea("CTN")
	dbSetOrder(1)
	If !dbSeek(xfilial()+cSetOfBook)
		aSetOfBook := ("","",0,"","")
		Help(" ",1,"NOSETOF")
		lRet := .F.
	EndIf
EndIf
	
RestArea(aSaveArea)

Return lRet


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  � CTR040MAXL �Autor � Eduardo Nunes Cirqueira � Data �  31/01/07 ���
�����������������������������������������������������������������������������͹��
���Desc.     � Baseado no parametro MV_PAR28 ("Num.linhas p/ o Balancete      ���
���          � Modelo 1"), cujo conteudo esta na variavel "nMaxLin", controla ���
���          � a quebra de pagina no TReport                                  ���
�����������������������������������������������������������������������������͹��
���Uso       � AP                                                             ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function CTR046MaxL(nMaxLin,nLinReport)

nLinReport++

If nLinReport > nMaxLin
	oReport:EndPage()
	nLinReport := 10
EndIf

Return Nil
                                                                          

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � nCtCGCCabTR  � Autor � Fabio Jadao Caires      � Data � 31/01/07���
������������������������������������������������������������������������������͹��
���Desc.     � Chama a funcao padrao CtCGCCabTR reiniciando o contador de      ���
���          � linhas para o controle do relatorio.                            ���
���          �                                                                 ���
������������������������������������������������������������������������������͹��
���Uso       � AP                                                              ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
STATIC FUNCTION nCtCGCCabT3(dDataFim,titulo,oReport,dDataIni)

nLinReport := 10

RETURN CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport,,,,,,,,,,dDataIni)