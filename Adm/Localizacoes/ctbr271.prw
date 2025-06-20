#Include "PROTHEUS.Ch"
#Include "CTBR271.Ch"

#DEFINE 	COL_SEPARA1			1
#DEFINE 	COL_CONTA 			2
#DEFINE 	COL_SEPARA2			3
#DEFINE 	COL_DESCRICAO		4
#DEFINE 	COL_SEPARA3			5
#DEFINE 	COL_COLUNA1       	6
#DEFINE 	COL_SEPARA4			7
#DEFINE 	COL_COLUNA2       	8
#DEFINE 	COL_SEPARA5			9
#DEFINE 	COL_COLUNA3       	10
#DEFINE 	COL_SEPARA6			11
#DEFINE 	COL_COLUNA4   		12
#DEFINE 	COL_SEPARA7			13
#DEFINE 	COL_COLUNA5   		14
#DEFINE 	COL_SEPARA8			15
#DEFINE 	COL_COLUNA6   		16
#DEFINE 	COL_SEPARA9			17
#DEFINE 	COL_COLUNA7			18
#DEFINE 	COL_SEPARA10		19
#DEFINE 	COL_COLUNA8			20
#DEFINE 	COL_SEPARA11		21
#DEFINE 	COL_COLUNA9			22
#DEFINE 	COL_SEPARA12		23
#DEFINE 	COL_COLUNA10		24
#DEFINE 	COL_SEPARA13		25
#DEFINE 	COL_COLUNA11		26
#DEFINE 	COL_SEPARA14		27
#DEFINE 	COL_COLUNA12		28
#DEFINE 	COL_SEPARA15		29


//Tradu��o PTG 20080721

// 17/08/2009 -- Filial com mais de 2 caracteres


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Ctbr271	� Autor � Paulo Augusto       	� Data � 23.01.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Comparativo de Movim. de Contas x 12 Colunas	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctbr271()                               			 		  ���
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
Function Ctbr271()

Private Titulo		:= ""
Private NomeProg	:= "CTBR271"
Private nTaxaCor:=0 
Private nTaxaAtu:=0
Private nTaxaAnt:=0
Private aSelFil := {}       

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()      
If !Empty( oReport:uParam )
	Pergunte( oReport:uParam, .F. )
EndIf	
oReport :PrintDialog()      
Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Paulo AUgusto     	� Data � 23/12/07 ���
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
Local cREPORT		:= "CTBR271"
Local cTITULO		:= Capital(STR0021)				  //"Este programa ira imprimir o Comparativo de Contas Contabeis."
Local cDESC			:= OemToAnsi(STR0021)+OemtoAnsi(STR0002) //"Este programa ira imprimir o Comparativo de Contas Contabeis."###"Os valores sao ref. a movimentacao do periodo solicitado. "
Local cPerg	   		:= "CTR271"
Local aTamConta		:= {20}	//	TAMSX3("CT1_CONTA")
Local aTamDesc		:= {20}
Local aTamVal		:= {12}
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
oReport	:= TReport():New( cReport,cTITULO,cPERG, { |oReport| ReportPrint( oReport ) }, cDESC )
oReport:SetLandScape(.T.)

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
oSection1  := TRSection():New( oReport, STR0003, {"cArqTmp","CT1"},, .F., .F. )         //"Conta ContaAbil"
TRCell():New( oSection1, "CONTA"   , ,STR0004/*Titulo*/,/*Picture*/,aTamConta[1] + 2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)  //"CONCEITO"
TRCell():New( oSection1, "DESCCTA" , ,STR0005/*Titulo*/,/*Picture*/,aTamDesc[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/) //"Descricao"
TRCell():New( oSection1, "COLUNA1" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA2" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA3" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA4" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA5" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA6" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA7" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA8" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA9" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA10", ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA11", ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA12", ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "TOTAL"	, ,STR0028/*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT") //"TOTAL"
TRCell():New( oSection1, "MEDIA"  	, ,STR0027	        ,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")

oSection1:SetTotalInLine(.F.)          

Return(oReport)     

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Paulo Augusto        � Data � 23/01/07 ���
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

Local oTotCol1, oTotCol2, oTotCol3, oTotCol4 , oTotCol5 , oTotCol6 ,;
      oTotCol7, oTotCol8, oTotCol9, oTotCol10, oTotCol11, oTotCol12
      
Local oTotGrp1,	oTotGrp2, oTotGrp3, oTotGrp4 , oTotGrp5 , oTotGrp6 ,;
      oTotGrp7,	oTotGrp8, oTotGrp9, oTotGrp10, oTotGrp11, oTotGrp12,;
      oTotGrpTot, oBreakGrp

Local aCtbMoeda		:= {}
Local cSeparador	:= ""
Local cPicture
Local cDescMoeda
Local nDivide		:= 1
Local cString		:= "CT1"

Local cCodMasc		:= ""
Local cGrupo		:= ""
Local cArqTmp
Local dDataFim 		:= dDatabase
Local lFirstPage	:= .T.
Local lJaPulou		:= .F.
Local lPrintZero	:= .T.
Local lPula			:= .T.
Local nDecimais
Local cSegFim		:= "zzzzzzzzzzzzzzz"
Local cSegAte   	:= "zzzzzzzzzzzzzzzzzzzzz"
Local nDigitAte		:= 0
Local aMeses		:= {}          
Local aPeriodos
Local nMeses		:= 1
Local nCont			:= 0
Local nDigitos		:= 0
Local nVezes		:= 0
Local nPos			:= 0 
Local cHeader 		:= ""
Local lAtSlBase		:= Iif(GETMV("MV_ATUSAL")== "S",.T.,.F.)
Local cFilter		:= ""
Local cTipoAnt		:= ""
Local aTamVal		:= {12}
Local cFilUser		:= ""
Local cDifZero		:= ""
Local cEspaco
Local bCond
Local nMes:=1
Local nValorMedio:= 0

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

//��������������������������������������������������������������Ŀ
//� Mostra tela de aviso - processar exclusivo					 �
//����������������������������������������������������������������
cMensagem := STR0006 +chr(13)    //"Caso nao atualize os saldos  basicos  na"
cMensagem += STR0007 +chr(13) //"digitacao dos lancamentos (MV_ATUSAL='N'),"
cMensagem +=  STR0008+chr(13)   //"rodar a rotina de atualizacao de saldos "
cMensagem += STR0009+chr(13)   //"para todos os periodos solicitados nesse "
cMensagem += STR0010+chr(13)  	  //"relatorio."

IF !lAtSlBase
	IF !MsgYesNo(cMensagem,STR0011)  //" ATENCAO "
		Return
	Endif
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)			 �
//����������������������������������������������������������������
If !ct040Valid(mv_par04)
	Return
Else
   aSetOfBook := CTBSetOf(mv_par04)
Endif

aCtbMoeda  	:= CtbMoeda(mv_par05,nDivide)
If Empty(aCtbMoeda[1])                       
   Help(" ",1,"NOMOEDA")
   Return
Endif

cDescMoeda 	:= Alltrim(aCtbMoeda[2])

If !Empty(aCtbMoeda[6])
	cDescMoeda += STR0012 + aCtbMoeda[6] //" EM "
EndIf	

nDecimais := DecimalCTB(aSetOfBook,mv_par05)
cPicture  := AllTrim( Right(AllTrim(aSetOfBook[4]),16) )

dbSelectArea("CTG")
dbSetOrder(1)
CTG->(DbSeek(xFilial() + mv_par01))
dIni:=CTG->CTG_DTINI
While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
	dDataFim	:= CTG->CTG_DTFIM
	CTG->(DbSkip())
EndDo


aPeriodos := ctbPeriodos(mv_par05, dIni, dDataFim, .T., .F.)
lPrim:=.T.
nMes:=1
For nCont := 1 to len(aPeriodos)       
	//Se a Data do periodo eh maior ou igual a data inicial solicitada no relatorio.
	If lPrim
		nMes:=Month(aPeriodos[nCont][1])
		cDescMes:=MesExtenso(nMes)
		lPrim:=.F.
	Else 
		nMes:=nMes+1
        If nMes> 12
        	nMes:=1
        EndIf
        cDescMes:=MesExtenso(nMes)	
	EndIf
	
	If aPeriodos[nCont][1] >= dIni .And. aPeriodos[nCont][2] <= dDataFim 
		If nMeses <= 12
			AADD(aMeses,{StrZero(nMeses,2),aPeriodos[nCont][1],aPeriodos[nCont][2],cDescMes})	
			nMeses += 1           					
		EndIf
	EndIf
Next                                                                   

If nMeses == 1
	cMensagem := STR0013 //"Por favor, verifique se o calend.contabil e a amarracao moeda/calendario "
	cMensagem += STR0014 //"foram cadastrados corretamente..."
	MsgAlert(cMensagem)
	Return
EndIf                                                      

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
	cCodMasc := ""
Else
	cCodmasc	:= aSetOfBook[2]
	cMascara 	:= RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf     

If !Empty(cSegAte)                
    nDigitAte	:= CtbRelDig(cSegAte,cMascara) 	
EndIf


//��������������������������������������������������������������Ŀ
//� Carrega titulo do relatorio: Analitico / Sintetico			  �
//����������������������������������������������������������������
Titulo:=STR0015 //"COMPARATIVO DE "


Titulo += 	DTOC(dIni) +STR0016 + Dtoc(aMeses[Len(aMeses)][3]) + ;  //" ATE "
				STR0012 + cDescMoeda  //" EM "

CTR271V(.F.)
oReport:SetCustomText( {||CTBR271CAB(dDataFim,oReport) } )

DbSelectArea("CT1")
cFilUser := oSection1:GetAdvplExp("CT1")

If Empty(cFilUser)
	cFilUser := ".T."
EndIf


//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao							  �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerComp(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				dIni,dDataFim,"CT7","",mv_par02,mv_par03,,,,,,,mv_par05,;
				mv_par06,aSetOfBook,"","",cSegFim,"",;
				.F.,.F.,2,cHeader,.F.,,nDivide,"F",.F.,,.T.,aMeses,.T.,,,.T.,cString,cFilUser)},;
				STR0022, STR0018) //"Criando Arquivo Tempor�rio..."###"Comparativo de Contas Contabeis"

oReport:NoUserFilter()

If Select("cArqTmp") == 0
	Return
EndIf			        

oSection1:OnPrintLine( {|| ( IIf( lPula .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOCONTA == "1" .And. cTipoAnt == "2")), oReport:SkipLine(),NIL),;
								 cTipoAnt := cArqTmp->TIPOCONTA;
							)  })       

cDifZero := " (cArqTmp->COLUNA1  <> 0 .OR. cArqTmp->COLUNA2  <> 0 .OR. cArqTmp->COLUNA3  <> 0 .OR. "
cDifZero += "  cArqTmp->COLUNA4  <> 0 .OR. cArqTmp->COLUNA5  <> 0 .OR. cArqTmp->COLUNA6  <> 0 .OR. "
cDifZero += "  cArqTmp->COLUNA7  <> 0 .OR. cArqTmp->COLUNA8  <> 0 .OR. cArqTmp->COLUNA9  <> 0 .OR. "
cDifZero += "  cArqTmp->COLUNA10 <> 0 .OR. cArqTmp->COLUNA11 <> 0 .OR. cArqTmp->COLUNA12 <> 0)"
						           
oSection1:SetFilter( cFilter )                                                

For nMes:= 1 to Len(aMeses)     
	cColVal := "COLUNA"+Alltrim(Str(nMes))
	cDtCab := Strzero(Day(aMeses[nMes][2]),2)+"/"+Strzero(Month(aMeses[nMes][2]),2)+ " - "
	cDtCab += Strzero(Day(aMeses[nMes][3]),2)+"/"+Strzero(Month(aMeses[nMes][3]),2)	

	oSection1:Cell(cColVal):SetTitle(aMeses[nMes][4])	
Next
lFirst:=.T.
nMes:=1
For nCont:= Len(aMeses)+1 to 12
	If lFirst
		nMes:=month(aMeses[Len(aMeses)][2])+1
		lFirst:=.F.
	Else
		If nMes>12
			nMes:=1
		Else
			nMes:=nMes+1
		EndIf	
		
	EndIf
	
	cColVal := "COLUNA"+Alltrim(Str(nCont))
	oSection1:Cell(cColVal):SetTitle(MesExtenso(nMes))
Next       
                                  
	oSection1:Cell("CONTA"  ):SetBlock( {|| IF( cArqTmp->TIPOCONTA == "2" ,	cEspaco:=SPACE(02),	cEspaco:="" ),	/*Fazer um recuo nas contas anal�ticas em rela��o � sint�tica*/;
   		                                    cEspaco + EntidadeCTB(cArqTmp->CONTA,0,0,70,.F.,cMascara,cSeparador,,,,,.F. ) } )	//Conta Sint�tica


oSection1:Cell("DESCCTA"):SetBlock( {|| cArqTmp->DESCCTA })

oSection1:Cell("COLUNA1"):SetBlock ( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA1 ,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("COLUNA2"):SetBlock ( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA2 ,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("COLUNA3"):SetBlock ( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA3 ,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("COLUNA4"):SetBlock ( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA4 ,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("COLUNA5"):SetBlock ( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA5 ,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("COLUNA6"):SetBlock ( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA6 ,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("COLUNA7"):SetBlock ( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA7 ,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("COLUNA8"):SetBlock ( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA8 ,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("COLUNA9"):SetBlock ( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA9 ,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("COLUNA10"):SetBlock( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA10,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("COLUNA11"):SetBlock( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA11,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("COLUNA12"):SetBlock( { ||Iif(!(cArqTmp->IDENTIFI $ "356"), ValorCTB(cArqTmp->COLUNA12,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("TOTAL"):SetBlock( { || Iif(!(cArqTmp->IDENTIFI $ "356"),ValorCTB((cArqTmp->COLUNA1+cArqTmp->COLUNA2+cArqTmp->COLUNA3+cArqTmp->COLUNA4+cArqTmp->COLUNA5+cArqTmp->COLUNA6+cArqTmp->COLUNA7+cArqTmp->COLUNA8+;
cArqTmp->COLUNA9+cArqTmp->COLUNA10+cArqTmp->COLUNA11+cArqTmp->COLUNA12),,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )
oSection1:Cell("MEDIA"):SetBlock( { || Iif(!(cArqTmp->IDENTIFI $ "356"),ValorCTB((cArqTmp->COLUNA1+cArqTmp->COLUNA2+cArqTmp->COLUNA3+cArqTmp->COLUNA4+cArqTmp->COLUNA5+cArqTmp->COLUNA6+cArqTmp->COLUNA7+cArqTmp->COLUNA8+;
cArqTmp->COLUNA9+cArqTmp->COLUNA10+cArqTmp->COLUNA11+cArqTmp->COLUNA12)/12,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),"") } )

           
oSection1:Print()

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return
              

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    ��CtCGCCabTR� Autor � PAULO AUGUSTO        � Data � 23/01/07 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Monta Cabecalho do relatorio                                ���
��������������������������������������������������������������������������Ĵ��
��� Sintaxe   �CtCGCCabTR(Titulo,oReport)                                  ���
��������������������������������������������������������������������������Ĵ��
��� Retorno   � Nenhum                                                     ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros �Arg1  = dATA                              				   ���
���           �Arg2 = Objeto do oReport                   				   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CTBR271CAB(dDataFim,oReport)
Local aCabec:={}    
Local cTexto1
Local cTexto2
Local cTexto3
Local cChar	:= chr(160)  // caracter dummy para alinhamento do cabe�alho



cTexto1:=STR0023 + Alltrim(Str(year(dDataFim)))   //"  AJUSTE ANUAL DE INFLACAO  "
ctexto2:="   I.N.P.C DIC " + Alltrim(Str(year(dDataFim)  ))+" "+Alltrim(Transf(nTaxaAtu,PesqPict("SIE","IE_INDICE")))+  "." //"   I.N.P.C DIC "###" FATOR DE JUSTE "
ctexto3:="   I.N.P.C DIC " + Alltrim(Str(year(dDataFim)-1))+  " " +Alltrim(Transf(nTaxaAnt,PesqPict("SIE","IE_INDICE"))) +  "." 

aCabec:= {	"__LOGOEMP__",;
         "  SIGA /" + NomeProg + "/v." + cVersao + "   " + "       " + cChar ,;
         RptHora + " " + time() + "     " + RptEmiss + " " + Dtoc(dDataBase),;
          cChar + "       " + AllTrim(SM0->M0_NOMECOM) + "       " + cChar + RptFolha+ TRANSFORM(oReport:Page(),'999999'),;
         cChar + "       " + cTexto1 + "       " + cChar,; 
		 cChar + "       " + cTexto2 + "       " + cChar,;             //"EXERCICIO "  
         cChar + "       " + cTexto3 + "       " + cChar,;             //"EXERCICIO "   }
         cChar + "       " + STR0025+" "+ Alltrim(Str(year(dDataFim)))+" "+ Alltrim(Transf(MV_PAR07,"@E 99999.9999"))  + "       " + cChar ,;
 		STR0026} //".          S A L D O S   M E D I O S       ."

Return aCabec

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTR518V      �Autor �  Paulo Augusto       �Data� 22/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao da pergunta 06 ref. a taxa do periodo contabil ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CTR271V(laltera)
Local cMesAtu:= ""
Local cAnoAtu:= ""
Local cMesIn:= ""
Local cAnoIn:= ""
Local aArea:=Getarea() 
Local dDataFim:=dDataBase 
Default lAltera:=.T.

dbSelectArea("CTG")
dbSetOrder(1)
CTG->(DbSeek(xFilial() + mv_par01))
dIni:=CTG->CTG_DTINI
While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
	dDataFim	:= CTG->CTG_DTFIM
	CTG->(DbSkip())
EndDo
If Month(dIni) ==1               
	cMesIn:= StrZero(12,2,0)
	cAnoIn:= Str(Year(dIni)-1,4,0) 
Else
	cMesIn:= StrZero(Month(dIni)-1,2,0)
	cAnoIn:= Str(Year(dIni),4,0) 
EndIf	
cMesAtu:= StrZero(Month(dDataFim),2,0) 
cAnoAtu:= Str(Year(dDataFim),4,0) 

DbSelectArea("SIE")   

If DbSeek( xFilial("SIE")+cAnoAtu +cMesAtu) 
	nTaxaAtu:=SIE->IE_INDICE
EndIf
If DbSeek( xFilial("SIE")+cAnoIn +cMesIn)
	nTaxaAnt:=SIE->IE_INDICE
EndIf   
If lAltera
	nTaxaCor:= Round((nTaxaAtu /  nTaxaAnt) - 1,TamSx3("IE_INDICE")[2])
	MV_PAR07:=nTaxaCor
EndIf
      
RestArea(aArea)  
