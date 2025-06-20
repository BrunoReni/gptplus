#INCLUDE "ctbr502.ch"
#Include "PROTHEUS.Ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ�
���Fun��o	 � CTBR502	� Autor � Wagner Mobile Costa	 � Data � 15.10.01 ��
��������������������������������������������������������������������������Ĵ�
���Descri��o � Demonstracao de Resultados por Natureza (apenas Portugal)   ��
��������������������������������������������������������������������������Ĵ�
���Retorno	 � Nenhum       											   ��
��������������������������������������������������������������������������Ĵ�
���Parametros� Nenhum													   ��
���������������������������������������������������������������������������ٱ
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR502()          

Private dFinalA
Private dFinal
Private nomeprog	:= "CTBR502"    
Private dPeriodo0
Private cRetSX5SL := ""

CTBR502R4()

//Limpa os arquivos tempor�rios 
CTBGerClean()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR502R4 � Autor� Daniel Sakavicius		� Data � 17/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Demostrativo de balancos patrimoniais - R4		          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR115R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR502R4()                           

PRIVATE CPERG	   	:= "CTR510"        

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������            
Pergunte( CPERG, .T. )

// faz a valida��o do livro
if ! VdSetOfBook( mv_par02 , .T. )
   return .F.
endif

oReport := ReportDef()      

If VALTYPE( oReport ) == "O"
	oReport :PrintDialog()      
EndIf

oReport := nil

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Daniel Sakavicius		� Data � 17/08/06 ���
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

Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda	:= {}
Local cDescMoeda 	:= ""
local aArea	   	:= GetArea()   
Local CREPORT		:= "CTBR502"
Local CTITULO		:= OemToAnsi(STR0001)				// DEMONSTRACAO DE RESULTADOS
Local CDESC			:= OemToAnsi(STR0014) + ; 			//"Este programa ir� imprimir a Demonstra��o de Resultados, "
	   					OemToAnsi(STR0015) 				//"de acordo com os par�metros informados pelo usu�rio."
Local aTamDesc		:= TAMSX3("CTS_DESCCG")  
Local aTamVal		:= TAMSX3("CT2_VALOR")
                 
aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
cDescMoeda 	:= AllTrim(aCtbMoeda[3])

If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)		     �
//����������������������������������������������������������������
If !ct040Valid(mv_par02)
	Return
EndIf	
             
lMovPeriodo	:= (mv_par13 == 1)

If mv_par09 == 1												/// SE DEVE CONSIDERAR TODO O CALENDARIO
	CTG->(DbSeek(xFilial() + mv_par01))
	If Empty(mv_par08)
		While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
			dFinal	:= CTG->CTG_DTFIM
			CTG->(DbSkip())
		EndDo
	Else
		dFinal	:= mv_par08
	EndIf
	dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
	If Empty ( dFinalA )
		If MONTH(dFinal) == 2
			If Day(dFinal) > 28 .and. Day(dFinal) == 29
				dFinalA := Ctod(Left( STRTRAN ( Dtoc(dFinal) , "29" , "28" ), 6) + Str(Year(dFinal) - 1, 4))
			EndIf
		EndIf
	EndIf	
	mv_par01    := dFinal
	If lMovPeriodo
		dPeriodo0 	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 2, 4)) + 1
	EndIf
Else															/// SE DEVE CONSIDERAR O PERIODO CONTABIL
	If Empty(mv_par08)
		MsgInfo(STR0008,STR0009)//"� necess�rio informar a data de refer�ncia !"#"Parametro Considera igual a Periodo."
		Return
	Endif
    
	dFinal		:= mv_par08
	dFinalA		:= CTOD("  /  /  ")
	dbSelectArea("CTG")
	dbSetOrder(1)
	MsSeek(xFilial("CTG")+mv_par01,.T.)
	While CTG->CTG_FILIAL == xFilial("CTG") .And. CTG->CTG_CALEND == mv_par01
		If dFinal >= CTG->CTG_DTINI .and. dFinal <= CTG->CTG_DTFIM
			dFinalA		:= CTG->CTG_DTINI	
			If lMovPeriodo
				nMes			:= Month(dFinalA)
				nAno			:= Year(dFinalA)
				dPeriodo0	:= CtoD(	StrZero(Day(dFinalA),2)							+ "/" +;
											StrZero( If(nMes==1,12		,nMes-1	),2 )	+ "/" +;
											StrZero( If(nMes==1,nAno-1,nAno		),4 ) )
				dFinalA		:= dFinalA - 1
			EndIf
			Exit
		Endif
		CTG->(DbSkip())
	EndDo
    
	If Empty(dFinalA)
		MsgInfo(STR0010,STR0011)//"Data fora do calend�rio !"#"Data de refer�ncia."
		Return
	Endif
Endif

CTITULO		:= If(! Empty(aSetOfBook[10]), aSetOfBook[10], CTITULO)		// Titulo definido SetOfBook
If Valtype(mv_par16)=="N" .And. (mv_par16 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf
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
oReport	:= TReport():New( CREPORT,CTITULO,CPERG, { |oReport| ReportPrint( oReport ) }, CDESC ) 
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport) } )                                        
oReport:ParamReadOnly()

oReport:DisableOrientation()

IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

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
oSection1  := TRSection():New( oReport, STR0012, {"cArqTmp"},, .F., .F. )        //"Contas/Saldos"

TRCell():New( oSection1, "ATIVO"	,""	,STR0013+cDescMoeda+")"	/*Titulo*/,/*Picture*/,100	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"LEFT",,"CENTER",,,.T.)	//"(Em "
TRCell():New( oSection1, "NOTAS"	,	,"NOTAS"				/*Titulo*/,/*Picture*/,20  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"LEFT",,"CENTER",,,.F.)
TRCell():New( oSection1, "SALDOATU"	,""	,						/*Titulo*/,/*Picture*/,aTamVal[1]+3	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/, /*"RIGHT"*/,,"CENTER",,,.F.)
TRCell():New( oSection1, "SALDOANT"	,""	,						/*Titulo*/,/*Picture*/,aTamVal[1]+3	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/, /*"RIGHT"*/,,"CENTER",,,.F.)

oSection1:Cell("ATIVO"):lHeaderSize		:= .F.
oSection1:Cell("NOTAS"):lHeaderSize		:= .F.
oSection1:Cell("SALDOATU"):lHeaderSize	:= .F.
oSection1:Cell("SALDOANT"):lHeaderSize	:= .F.

oSection1:SetTotalInLine(.F.) 

If cPaisloc <> 'PTG'
	oSection1:Cell("NOTAS"):Hide()  
Endif    

oReport:SetLineHeight(50)  

oSection1:Cell("ATIVO"):SetBorder("LEFT",,,.F.) 
oSection1:Cell("ATIVO"):SetBorder("TOP",,,.T.) 
oSection1:Cell("ATIVO"):SetBorder("LEFT",,,.T.) 
oSection1:Cell("NOTAS"):SetBorder("LEFT",,,.F.) 
oSection1:Cell("NOTAS"):SetBorder("TOP",,,.T.) 
oSection1:Cell("NOTAS"):SetBorder("LEFT",,,.T.) 
oSection1:Cell("SALDOANT"):SetBorder("LEFT",,,.F.)
oSection1:Cell("SALDOANT"):SetBorder("TOP",,,.T.)
oSection1:Cell("SALDOANT"):SetBorder("LEFT",,,.T.)
oSection1:Cell("SALDOANT"):SetBorder("RIGHT",,,.F.)
oSection1:Cell("SALDOANT"):SetBorder("RIGHT",,,.T.)
oSection1:Cell("SALDOATU"):SetBorder("LEFT",,,.F.)
oSection1:Cell("SALDOATU"):SetBorder("TOP",,,.T.)
oSection1:Cell("SALDOATU"):SetBorder("LEFT",,,.T.)
oSection1:Cell("SALDOATU"):SetBorder("RIGHT",,,.F.)
oSection1:Cell("SALDOATU"):SetBorder("RIGHT",,,.T.)  

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Daniel Sakavicius	� Data � 17/08/06 ���
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
Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda	:= {}
Local lin 			:= 3001
Local cArqTmp
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cPicture
Local cDescMoeda
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local nSaldo
Local nTamLin		:= 2350
Local aPosCol		:= { 1740, 2045 }
Local nPosCol		:= 0
Local lImpTrmAux	:= Iif(mv_par10 == 1,.T.,.F.)
Local cArqTrm		:= ""
Local lVlrZerado	:= Iif(mv_par12==1,.T.,.F.)
Local lMovPeriodo
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local cMoedaDesc	:= iif( empty( mv_par14 ) , mv_par03 , mv_par14 )
Local lPeriodoAnt 	:= (mv_par06 == 1)
Local cSaldos     	:= CT510TRTSL() 

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
cPicture 	:= aSetOfBook[4]

If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif

lMovPeriodo	:= (mv_par13 == 1)

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao					     �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp, dFinalA+1, dFinal;
					  , "", "", "", Repl( "Z", Len( CT1->CT1_CONTA )), ""; 
					  , Repl( "Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM));
					  , "", Repl("Z", Len(CTH->CTH_CLVL)), mv_par03, /*MV_PAR15*/cSaldos, aSetOfBook, Space(2);
					  , Space(20), Repl("Z", 20), Space(30),,,,, mv_par04=1, mv_par05;
					  , ,lVlrZerado,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,lMovPeriodo,,,.T.,MV_PAR17==1)};
			,STR0006, STR0001) //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")           
dbGoTop()

oReport:SetPageNumber(mv_par07) //mv_par07 - Pagina Inicial

oSection1:Cell("SALDOATU" ):SetTitle(Dtoc(dFinal))
If lPeriodoAnt
	oSection1:Cell("SALDOANT" ):SetTitle(Dtoc(dFinalA))
Else
	oSection1:Cell("SALDOANT" ):Disable()
EndIf

oSection1:Cell("ATIVO"):SetBlock( { || Iif(cArqTmp->COLUNA<2,Iif(cArqTmp->TIPOCONTA="2",space(2)+ cArqTmp->DESCCTA,space(2)+cArqTmp->DESCCTA),"") } )		

oSection1:Cell("SALDOATU"):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->(SALDOATU-SALDOANT),cArqTmp->SALDOATU),,,aTamVal[1],nDecimais,.T.,cPicture,;
    	                                                	cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,(cArqTmp->IDENTIFI < "5"),.F. ) } )

If lPeriodoAnt
	oSection1:Cell("SALDOANT" ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->MOVPERANT,cArqTmp->SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture,;
														 cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,(cArqTmp->IDENTIFI < "5"),.F. ) } )
EndIf

oSection1:Init()

While cArqTmp->(!Eof())
	oSection1:PrintLine()
	dbSkip()     
EndDo

oReport:ThinLine()
oSection1:Finish()

If lImpTrmAux 
	oReport:EndPage()
	cArqTRM 	:= mv_par11
    aVariaveis  := {}
	
    // Buscando os par�metros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->( dbSeek("CTR510"+"01") )
	SX1->( dbSeek( padr( "CTR510" , Len( X1_GRUPO ) , ' ' ) + "01" ) )
	While SX1->X1_GRUPO == padr( "CTR510" , Len( SX1->X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->( dbSkip() )
	End

	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024(cArqTRM,STR0007) // "Respons�veis..."
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		ImpTerm2(cArqTRM,aVariaveis,,,,oReport)
	Endif	 

Endif

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � fTrataSlds� Autor �Elton da Cunha Santana       � 13.10.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tratamento do retorno do parametro                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CT510TRTSL                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CT510TRTSL()

Local cRet := ""

If MV_PAR17 == 1
	cRet := MV_PAR18
Else
	cRet := MV_PAR15
EndIf

Return(cRet)
