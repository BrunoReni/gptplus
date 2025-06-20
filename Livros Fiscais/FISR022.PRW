#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISR022.CH"
#INCLUDE "REPORT.CH"
/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � FISR022  � Autor � Graziele Paro         � Data � 22/03/2013 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO �Demonstrativo das Aquisi��es Interestaduais realizadas no     ��� 
���			 |per�odo com Antecipa��o Tribut�ria do ICMS                    ��� 
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFIS 		                                                ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Function Fisr022()
Local oReport
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.) 
    
If lVerpesssen .And. TRepInUse()		//	verifica se relatorios personalizaveis esta disponivel	
        //������������������������������������������������������������������������Ŀ
		//�Interface de impressao                                                  �
		//��������������������������������������������������������������������������
		oReport	:= ReportDef()
		oReport:PrintDialog()
Endif  

Return    
/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    �ReportDef � Autor � Graziele Paro         � Data � 22/03/2013 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Definicao do componente                                      ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/                

Static Function ReportDef()
Local oReport
Local oRelat
Local oNomes 
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("FISR022",STR0001,"FISR022", {|oReport| ReportPrint(oReport)},STR0001)
oReport:oPage:nPaperSize:= 9
oReport:SetTotalInLine(.F.)
oReport:SetLandscape() 
Pergunte("FISR022",.F.) 
aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}
Aadd(aHelpPor,"Informar se a gera��o do relat�rio")
Aadd(aHelpPor,"dever� ser pela data de emiss�o com 'Sim' ")
Aadd(aHelpPor,"ou pela data de entrada com 'N�o'. ")

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
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//��������������������������������������������������������������������������  
   
//Secao Relatorio                 
oRelat:=TRSection():New(oReport,STR0001,{"REL"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)    //M�todo construtor da classe TRSection
oRelat:SetPageBreak(.T.)  //Define se salta a p�gina na quebra de se��o         
oRelat:SetTotalInLine(.F.)  

TRCell():New(oRelat,"DENTRADA"	,"REL",STR0004,/*cPicture*/,25,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data Entrada"
TRCell():New(oRelat,"DEMISSAO" ,"REL",STR0005,/*cPicture*/,25,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data Emissao"
TRCell():New(oRelat,"NFISCAL"  ,"REL",STR0006,/*cPicture*/,25,/*lPixel*/,/*{|| code-block de impressao }*/) //"Nota Fiscal"
TRCell():New(oRelat,"ESTADO"   ,"REL",STR0007,/*cPicture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/) //"Estado"
TRCell():New(oRelat,"CODFOR"	,"REL",STR0008,/*cPicture*/,25,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oRelat,"RAZAOFOR"	,"REL",STR0009,/*cPicture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Razao Social"
TRCell():New(oRelat,"CNPJ" 	    ,"REL",STR0010,"@R 99.999.999/9999-99",35,/*lPixel*/,/*{|| code-block de impressao }*/) //"CNPJ"  
TRCell():New(oRelat,"INSCRICAO"	,"REL",STR0011,"@!",35,/*lPixel*/,/*{|| code-block de impressao }*/) //"Inscricao Estadual"   
TRCell():New(oRelat,"CFOP" 	    ,"REL",STR0012,/*cPicture*/,08,/*lPixel*/,/*{|| code-block de impressao }*/) //"CFOP"       
TRCell():New(oRelat,"VCONTABIL","REL",STR0013,"@E 99,999,999,999.99",23,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Contabil"      
TRCell():New(oRelat,"VICMSANT" 	,"REL",STR0014,"@E 99,999,999,999.99",23,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor ICMS antecipado"  

Return(oReport)     
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Graziele Paro          � Data �22/03/2013���
��������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os  ���
���          �relatorios que poderao ser agendados pelo usuario.           ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                            ���
��������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                          ���
��������������������������������������������������������������������������Ĵ��
���          �               �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ReportPrint(oReport)
Local oRelat	:= oReport:Section(1) 
Local oBreakEs   := ""

SelRel()
REL->(dbSetOrder(2))                     
oReport:SkipLine(10) 

//Totalizadores
If mv_par03 == 1 // define se deve ou nao ser agrupado por fornecedor
	oBreakEs  := TRBreak():New(oRelat,oRelat:Cell("ESTADO"),STR0015,.F.) // "Total Estado "      
	TRFunction():New(oRelat:Cell("VICMSANT"),Nil,"SUM",oBreakEs,"","@E 999,999,999.99",/*uFormula*/,.F.,.T.,.F.)
Else
	oBreakFil := TRBreak():New(oRelat,oRelat:Cell("CODFOR"),STR0016,.F.) // "Total Fornecedor   
	oBreakEs  := TRBreak():New(oRelat,oRelat:Cell("ESTADO"),STR0015,.F.) // "Total Estado "      
	TRFunction():New(oRelat:Cell("VICMSANT"),Nil,"SUM",oBreakEs,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.,.F.)       
	TRFunction():New(oRelat:Cell("VICMSANT"),Nil,"SUM",oBreakFil,"","@E 999,999,999.99",/*uFormula*/,.F.,.T.,.F.)      
EndIf 
 
oRelat:Print()    
REL->(DbCloseArea())
FErase(cArqRel+GetDBExtension())
FErase(cArqRel+IndexExt())

Return         

/*
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � SelRel	    �Autor � Graziele Paro        �Data�22/03/2013���
�������������������������������������������������������������������������Ĵ��
���Descricao � Seleciona dados para emissao do relatorio 		          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������
*/ 
Static Function SelRel()    
Local aCampos 	:= {}                    
Local lTop	 	:= .F.   
Local cAliasSF3	:= "SF3"     
Local cAliasSA2 := "SA2"    
Local cArqInd	:= ""
Local nMes 		:=mv_par01   
Local nAno 		:=mv_par02
Local dInicial	:= LastDay(CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nAno,4,0)),1)
Local dFinal 	:= LastDay(CTOD("01/"+StrZero(nMes,2,0)+"/"+StrZero(nAno,4,0)),2)

//Criando tabela temporaria
aCampos:={{"DENTRADA"     ,"D",08,0},;
{"DEMISSAO"    	,"D",08,0},;
{"NFISCAL"      ,"C",09,0},; 
{"SERIE"        ,"C",03,0},;
{"LOJA"         ,"C",02,0},; 
{"FILIAL"       ,"C",02,0},; 
{"ESTADO"     	,"C",02,0},;
{"CODFOR"      	,"C",06,0},;
{"RAZAOFOR"     ,"C",30,2},;
{"CNPJ"         ,"C",14,0},;
{"INSCRICAO"    ,"C",18,0},;
{"CFOP"      	,"C",05,0},;
{"VCONTABIL"    ,"N",14,2},;
{"VICMSANT"     ,"N",14,2}} 

//Indices
If Select("REL")>0
	dbSelectArea("REL")
	REL->(DbCloseArea())
EndIf

cArqTemp := CriaTrab(aCampos)
dbUseArea(.T.,,cArqTemp,"REL",.T.,.F.)
cArqInd  := CriaTrab(NIL,.F.)
IndRegua("REL",cArqInd,"CODFOR+LOJA+NFISCAL+SERIE+CFOP")
cArqInd2  := CriaTrab(NIL,.F.)
IndRegua("REL",cArqInd2,"ESTADO")    
dbClearIndex()
dbSelectArea("REL")
dbSetIndex(cArqInd+OrdBagExt())
dbSetIndex(cArqInd2+OrdBagExt())
dbSetOrder(2)
aAdd(aCampos,{cArqTemp,"REL"})

dbSelectArea("SF3")
SF3->(dbSetOrder(4))   
dbSelectArea("SA2")
SA2->(dbSetOrder(1))   

#IFDEF TOP
    If (TcSrvType ()<>"AS/400")	  
     lTop	:= .T.
     cAliasSF3		:=	GetNextAlias()
    if mv_par04 == 1
    	BeginSql Alias cAliasSF3    
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_EMISSAO AS DATE    
			
			SELECT SA2.A2_COD,
					SA2.A2_LOJA,
					SA2.A2_NOME,
					SA2.A2_NREDUZ,
					SA2.A2_EST,
					SA2.A2_CGC,
					SA2.A2_INSCR,
					SF3.F3_ENTRADA,
					SF3.F3_NFISCAL,
					SF3.F3_SERIE,
					SF3.F3_CLIEFOR,
					SF3.F3_LOJA,
					SF3.F3_CFO,
					SF3.F3_ESTADO,
					SF3.F3_EMISSAO,
					SF3.F3_FILIAL,
					SF3.F3_VALANTI,
					SF3.F3_VALCONT				
      	    FROM 
					%TABLE:SF3% SF3
					INNER JOIN %TABLE:SA2% SA2 ON(SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND SA2.%NOTDEL%)
			WHERE 
					SF3.F3_FILIAL=%XFILIAL:SF3% 
					AND SA2.A2_FILIAL=%XFILIAL:SA2%  
				   	AND SF3.F3_VALANTI >0
				   	AND SF3.%NOTDEL%
					AND SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))%
					AND SF3.F3_ENTRADA >= %EXP:DTOS(dInicial)% 
					AND SF3.F3_ENTRADA <= %EXP:DTOS(dFinal)% 
			ORDER BY SA2.A2_EST,SA2.A2_COD
     EndSql 
	 DbSelectArea (cAliasSF3)
     (cAliasSF3)->(DbGoTop())
   elseif mv_par04 == 2
   		BeginSql Alias cAliasSF3    
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_EMISSAO AS DATE    
			
			SELECT SA2.A2_COD,
					SA2.A2_LOJA,
					SA2.A2_NOME,
					SA2.A2_NREDUZ,
					SA2.A2_EST,
					SA2.A2_CGC,
					SA2.A2_INSCR,
					SF3.F3_ENTRADA,
					SF3.F3_NFISCAL,
					SF3.F3_SERIE,
					SF3.F3_CLIEFOR,
					SF3.F3_LOJA,
					SF3.F3_CFO,
					SF3.F3_ESTADO,
					SF3.F3_EMISSAO,
					SF3.F3_FILIAL,
					SF3.F3_VALANTI,
					SF3.F3_VALCONT				
      	    FROM 
					%TABLE:SF3% SF3
					INNER JOIN %TABLE:SA2% SA2 ON(SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND SA2.%NOTDEL%)
			WHERE 
					SF3.F3_FILIAL=%XFILIAL:SF3% 
					AND SA2.A2_FILIAL=%XFILIAL:SA2%  
				   	AND SF3.F3_VALANTI >0
				   	AND SF3.%NOTDEL%
					AND SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))%
					AND SF3.F3_EMISSAO >= %EXP:DTOS(dInicial)% 
					AND SF3.F3_EMISSAO <= %EXP:DTOS(dFinal)% 
			ORDER BY SA2.A2_EST,SA2.A2_COD
     EndSql 
	 DbSelectArea (cAliasSF3)
     (cAliasSF3)->(DbGoTop())
   
   Endif
Else
#ENDIF       
         cIndex	:= CriaTrab(NIL,.F.)
         cFiltro	:= 'F3_FILIAL=="'+xFilial ("SF3")+'".And.' 
         cFiltro += 'F3_VALANTI >0 .And. '   
         cFiltro += 'DTOS (F3_DTCANC)>="'+DTOS(dInicial)+'" .And. '
         cFiltro += 'DTOS (F3_ENTRADA)>="'+DTOS(dInicial)+'" .And. ' 
         cFiltro += 'DTOS (F3_ENTRADA)<="'+DTOS(dFinal)+'"'                        
         
	    IndRegua (cAliasSF3, cIndex, SF3->(IndexKey ()),, cFiltro)
	    nIndex := RetIndex(cAliasSF3)

		#IFNDEF TOP
			DbSetIndex (cIndex+OrdBagExt ())
		#ENDIF
		DbSelectArea (cAliasSF3)
	    DbSetOrder (nIndex+1)        
#IFDEF TOP
	Endif
#ENDIF         

If lTop
	cAliasSA2	:= cAliasSF3				 				 
EndIf
 
DbSelectArea (cAliasSF3)
(cAliasSF3)->(DbGoTop())
	While (cAliasSF3)->(!EOF())
		IF !lTop  
		   (cAliasSF2)->(MsSeek(xFilial("SF2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))   
		ENDIF 
		DbSelectArea ("REL")
		REL->(dbSetOrder(1))
		IF !REL->(MsSeek((cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CFO)) //passar a sf3
			    Reclock("REL",.T.)                  
				REL->DENTRADA		:= (cAliasSF3)->F3_ENTRADA
				REL->DEMISSAO		:= (cAliasSF3)->F3_EMISSAO
				REL->NFISCAL		:= (cAliasSF3)->F3_NFISCAL 
				REL->SERIE			:= (cAliasSF3)->F3_SERIE
				REL->LOJA			:= (cAliasSF3)->F3_LOJA
				REL->ESTADO			:= (cAliasSA2)->A2_EST
				REL->CODFOR	   		:= (cAliasSA2)->A2_COD
				REL->RAZAOFOR		:= (cAliasSA2)->A2_NOME
				REL->CNPJ			:= (cAliasSA2)->A2_CGC
				REL->INSCRICAO		:= (cAliasSA2)->A2_INSCR 
				REL->CFOP			:= (cAliasSF3)->F3_CFO
				REL->VCONTABIL		:= (cAliasSF3)->F3_VALCONT
				REL->VICMSANT		:= (cAliasSF3)->F3_VALANTI   
				MsUnLock()	
		Else
			    Reclock("REL",.F.)
				REL->VCONTABIL		+= (cAliasSF3)->F3_VALCONT
				REL->VICMSANT		+= (cAliasSF3)->F3_VALANTI   		
				MsUnLock()
		EndIf		
		(cAliasSF3)->(dbSkip()) 
 	EndDo
 	(cAliasSF3)->(DbCloseArea())
return 
