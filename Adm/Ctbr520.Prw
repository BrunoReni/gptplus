#INCLUDE "CTBR520.CH"
#INCLUDE "PROTHEUS.Ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Ctbr520	� Autor � Wagner Mobile Costa	� Data � 15.10.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Demonstracao das origens e aplicacoes de recursos	  	  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CtbR520()
Private nomeprog	:= "CTBR520"
 
CTBR520R4()

//Limpa os arquivos tempor�rios 
CTBGerClean()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR266R4 � Autor� Daniel Sakavicius		� Data � 05/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Demonstracao das origens e aplicacoes de recursos - R4     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR266R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR520R4() 
Local cPerg	   		:= "CTR520"           
Private cPictVal 		:= PesqPict("CT2","CT2_VALOR")

Pergunte(cPerg,.T.)

oReport := ReportDef()      

If valType( oReport ) == 'O'

	If ! Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	

	oReport :PrintDialog()      
Endif

oReport := nil

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Daniel Sakavicius		� Data � 05/09/06 ���
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
Local cREPORT		:= "CTBR520"
Local cSayItem		:= CtbSayApro("CTD")
Local cTITULO		:= Capital(STR0001)  // "DEMONSTRACAO DAS ORIGENS E APLICACOES DE RECURSOS"
Local cDESC			:= STR0007 + STR0008 // "Este programa ira imprimir a Demonstracao das Origens e Aplicacoes "
                                         // "de Recursos, de acordo com os parametros informados pelo usuario. "
Local cPerg	   		:= "CTR520"           
Local aTamDesc		:= TAMSX3("CTS_DESCCG")  
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nDecimais

Local aSetOfBook	:= CTBSetOf(mv_par02)

cTitulo := If(! Empty(aSetOfBook[10]), aSetOfBook[10], cTitulo )		// Titulo definido SetOfBook  
If Valtype(mv_par11)=="N" .And. (mv_par11 == 1)
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
oReport	:= TReport():New( cReport,cTITULO,cPERG, { |oReport| ReportPrint( oReport ) }, cDESC ) 
oReport:SetLandScape(.T.)
oReport:ParamReadOnly()

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
oSection1  := TRSection():New( oReport, Capital(STR0003), {"cArqTmp"},, .F., .F. )        
TRCell():New( oSection1, "DESCCTA"  , ,/*Titulo*/,/*Picture*/,aTamDesc[1] /*Tamanho*/,/*lPixel*/,/*{ || (cArqTmp->DESCCTA) }*//*CodeBlock*/)
TRCell():New( oSection1, "SALDOATU" , ,/*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "SALDOANT" , ,/*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")

oSection1:SetTotalInLine(.F.)          

Return(oReport)     
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Daniel Sakavicius	� Data � 02/09/06 ���
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

Local aCtbMoeda		:= {}
Local cSeparador	:= ""
Local cPicture
Local cDescMoeda            
Local cTipoAnt      := ""      
Local dFinal		:= CTOD("  /  /  ")
Local aSetOfBook	:= CTBSetOf(mv_par02)
Local cArqTmp
Local cTpValor		:= GetMV("MV_TPVALOR")
Local lImpTrmAux	:= Iif(mv_par08 == 1,.T.,.F.)
Local cArqTrm		:= ""
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local bCondVal

oReport:SetPageNumber( mv_par07 )

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)				  �
//����������������������������������������������������������������
// faz a valida��o do livro
if ! VdSetOfBook( mv_par02 , .T. )
   return .F.
endif

dbSelectArea("CTG")
dbSetOrder(1)
If MsSeek(xFilial()+mv_par01,.F.)
	While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
		dFinal    	:= CTG->CTG_DTFIM
		CTG->(DbSkip())
	EndDo
EndIf
	
dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
mv_par01    := dFinal

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return 
Endif

cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)

cPicture 	:= aSetOfBook[4]
If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif                            

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,oReport:Title(),,,,,oReport) } )

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao					     �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
			dFinalA+1,dFinal,"","", "",Repl("Z", Len(CT1->CT1_CONTA)),;
			"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
			"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
			MV_PAR10,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30),,,,,;
			mv_par04 = 1, mv_par05)},STR0004, STR0003) //"Criando Arquivo Temporario...", "Origens e Aplicacoes de recursos"

bCondVal := { || (cArqTmp->IDENTIFI < "5") .And. (cArqTmp->DESCCTA <> "-") }

oSection1:Cell("DESCCTA"):SetTitle(STR0006+cDescMoeda+")")
oSection1:Cell("DESCCTA"):SetBlock( {|| If(cArqTmp->DESCCTA <> "-", cArqTmp->DESCCTA, oReport:ThinLine()) } )

oSection1:Cell("SALDOATU"):SetTitle(Dtoc(dFinal))
oSection1:Cell("SALDOATU"):SetBlock( { || If( Eval(bCondVal),ValorCTB(cArqTmp->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture,;
					                               	                  cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.),"" ) } )
If mv_par06 == 1	//	Demostra Per�odo Anterior
	oSection1:Cell("SALDOANT"):SetTitle(Dtoc(dFinalA))
	oSection1:Cell("SALDOANT"):SetBlock( { || If( Eval(bCondVal),ValorCTB(cArqTmp->SALDOANT,,,aTamVal[1],nDecimais,.T.,cPicture,;
     					                                                  cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.),"" ) } )
Else
	oSection1:Cell("SALDOANT"):Disable()
Endif

//oSection1:OnPrintLine( {|| If( cArqTmp->DESCCTA <> "-", .T.,.F. ) } )

oSection1:Print()

If lImpTrmAux
	cArqTRM 	:= mv_par09
    aVariaveis  := {}
	
    // Buscando os par�metros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->( dbSeek( padr( "CTR520" , Len( SX1->X1_GRUPO ) , ' ' ) + "01" ) )

	While SX1->X1_GRUPO == padr( "CTR520" , Len( SX1->X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->( dbSkip() )
	End

	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024(cArqTRM,STR0005) // "Respons�veis..."
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