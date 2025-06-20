#INCLUDE "PROTHEUS.CH"     
#INCLUDE "GPER810.CH"
#INCLUDE "REPORT.CH"     
                                     
/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � GPER810  � Autor � Alceu Pereira             � Data � 25.08.08 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Exercico de Cargos Superiores                       ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER810()                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                       ���
�����������������������������������������������������������������������������Ĵ��
���                     ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.     ���
�����������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                       ���
�����������������������������������������������������������������������������Ĵ��
���            �          �      �											  ���
������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Programador  � Data     � FNC            �  Motivo da Alteracao                      ���
���������������������������������������������������������������������������������������ĳ��
���Rogerio R.   �29/07/2009�00000018278/2009�Compatibilizacao dos fontes para aumento do���
���             �          �                �campo filial e gest�o corporativa.         ���
���Luis Enr�quez�26/01/2017�SERINN001-848   �-Se realiza merge contra 12.1.15 para hacer���
���             �          �                � cambio en creaci�n de tabla temporal se   ���
���             �          �                � utiliza clase FWTemporary CTRE.           ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Function GPER810()  

	Local	oReport   
	Local	aArea 	:= GetArea()
	Private	cString	:= "SRA"				// alias do arquivo principal (Base)
	Private cPosit	:= "SRJ"
	Private cPerg	:= "GPR810"
	Private aOrd	:= {OemToAnsi(STR0007),OemToAnsi(STR0001)} //Filial + Matricula ####  //Filial + Nome
	Private cTitulo	:= OemToAnsi(STR0002)	//"RELA��O DE EXERCICIO DE FUNCAO SUPERIOR"
	Private oTmpTable := Nil
	Private aOrdem := {}

	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                           �
	//����������������������������������������������������������������
	pergunte(cPerg,.F.) 

	oReport := ReportDef()
	oReport:PrintDialog()

	RestArea( aArea )

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Alceu Pereira         � Data � 25/08/08 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Exercicio de Funcao Superior                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �ReportDef()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � GPER810 - Generico 											���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ReportDef()   
	Local oReport 
	Local oSection 
	Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0002) 
	//������������������������������������������������������������������������Ŀ
	//�Criacao dos componentes de impressao                                    �
	//��������������������������������������������������������������������������
	DEFINE REPORT oReport NAME "GPER810" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| Imp810R(oReport)} DESCRIPTION OemtoAnsi(STR0004) TOTAL IN COLUMN	 
	//"Este programa emite Rela��o de Exerc�cio de Fun��o Superior."
	DEFINE SECTION oSection OF oReport TITLE OemToAnsi(STR0005)TABLES "SRA", "RGL","SRJ", "TRA" TOTAL IN COLUMN ORDERS aOrd	

	DEFINE CELL NAME "RA_FILIAL" 	OF oSection ALIAS cString BLOCK {||TRA->FILIAL}
	DEFINE CELL NAME "RA_MAT" 	 	OF oSection ALIAS cString BLOCK {||TRA->MAT}
	DEFINE CELL NAME "RA_NOME" 	 	OF oSection ALIAS cString BLOCK {||TRA->NOME}           
	DEFINE CELL NAME "RGL_CODFUN"	OF oSection ALIAS cString BLOCK {||TRA->CODFUNC}
	DEFINE CELL NAME "RJ_DESC"		OF oSection ALIAS cString BLOCK {||TRA->DESCFUNC}
	DEFINE CELL NAME "RGL_SALARI"	OF oSection ALIAS cString BLOCK {||TRA->SALARIO}
	DEFINE CELL NAME "RGL_DTINI"	OF oSection ALIAS cString BLOCK {||TRA->INIFUNCAO}
	DEFINE CELL NAME "RGL_DTFIM"	OF oSection ALIAS cString BLOCK {||TRA->FIMFUNCAO}
	DEFINE CELL NAME "RGL_DIAS"		OF oSection ALIAS cString BLOCK {||TRA->DIAS} 

	DEFINE BREAK oBreakFil OF oSection WHEN oSection:Cell("RA_FILIAL") TITLE OemToAnsi(STR0006) // "Total de Registros "	
	oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0006)+x})   

	DEFINE FUNCTION FROM oSection:Cell("RA_MAT") FUNCTION COUNT NO END SECTION   

	oSection:SetAutoSize()
	                                                                                              
Return(oReport)      


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � Imp810R    � Autor � Alceu Pereira         � Data � 25/08/08 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Exercicio de Funcao Superior                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Imp810R(oReport)                                             ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ReportDef - Generico 										���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function Imp810R(oReport)

	Local oSection	:= oReport:Section(1)
	Local cFiltro 	:= "" 
	Local cAliasQry	:= ""
	Local cAcessaSRA:= &("{ || " + ChkRH("GPER810","SRA","2") + "}")
	Local cArqNtx   := cIndCond := ""  
	Local cTrbRGL   := ""
	Local cFilialDe	:= ""
	Local cCCustoDe	:= ""
	Local cMatDe	:= ""
	Local dDataDe   := CTOD("01/01/1900")
	Local dDataAte	:= CTOD("01/01/1900")
	Local cFuncDe 	:= ""
	Local cNomDe	:= ""

	Private nOrdem	:= oSection:GetOrder()

	//��������������������������������������������������������������Ŀ
	//� Carregando variaveis mv_par para Variaveis do Sistema.	     �
	//����������������������������������������������������������������
	cFilialDe		:= mv_par01  //Filial
	CCCustoDe		:= mv_par02  //C. Custo
	cMatDe			:= mv_par03  //Matricula
	dDataDe			:= mv_par04  //Data Inicial
	dDataAte		:= mv_par05  //Data Final
	cFuncDe 		:= mv_par06  //Funcao
	cNomDe			:= mv_par07  //Nome
	     
	If Empty(dDataDe)   
		dDataDe := CTOD("01/01/1900")
	Endif 

	If Empty(dDataAte)
		dDataAte := CTOD("01/01/1900")
	Endif	

	DbSelectarea("SRJ")

	#IFDEF TOP
		cAliasQry := "SRA"
	
		//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
		MakeSqlExpr(cPerg)
	
		BEGIN REPORT QUERY oSection                 
	
			If nOrdem == 1
				cOrdem := "%SRA.RA_FILIAL, SRA.RA_MAT%" 
			ElseIf nOrdem == 2  
				cOrdem := "%SRA.RA_FILIAL, SRA.RA_NOME%"           
			Endif
	
			BeginSql alias cAliasQry   
			SELECT 
			SRA.RA_FILIAL,
			SRA.RA_MAT,
			SRA.RA_NOME,
			RGL.RGL_CODFUN,
			RJ.RJ_DESC,
			RGL.RGL_SALARI,
			RGL.RGL_DTINI,        
			RGL.RGL_DTFIM,
			RGL.RGL_DIAS
			FROM %table:RGL% RGL 
			INNER JOIN %table:SRA% SRA
			ON	SRA.RA_FILIAL = RGL.RGL_FILIAL AND SRA.RA_MAT = RGL.RGL_MAT
			INNER JOIN %table:SRJ% RJ
			ON RJ.RJ_FUNCAO  = RGL.RGL_CODFUN 	
			WHERE                                              
			RGL.%notDel%  
			AND
			SRA.%notDel%   
			ORDER BY %exp:cOrdem%							
			EndSql
	
		END REPORT QUERY oSection PARAM mv_par01, mv_par02, mv_par03, mv_par06, mv_par07
		cPosit	:= cAliasQry                                                            

	#ELSE             

		cAliasQry := "SRA"
	
		//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
		MakeAdvplExpr(cPerg)
		dbSelectArea(cAliasQry)
	
		//��������������������������������������������������������������������������Ŀ
		//� Verifica a ordem selecionada                                             �
		//����������������������������������������������������������������������������
		If nOrdem == 1
			cIndCond := "SRA.RA_FILIAL + SRA.RA_MAT"    
			dbSetOrder(1)
		ElseIf nOrdem == 2
			cIndCond := "SRA.RA_FILIAL + SRA.RA_NOME"    
			dbSetOrder(3)	  
		Endif
	
		If !Empty(mv_par01)
			cFiltro += mv_par01 
		EndIf
	
		If !Empty(mv_par02)
			cFiltro += Iif(!Empty(cFiltro)," .AND. ","")
			cFiltro += mv_par02 
		EndIf
	
		If !Empty(mv_par03)
			cFiltro += Iif(!Empty(cFiltro)," .AND. ","")
			cFiltro += mv_par03
		EndIf
	
		If !Empty(mv_par07)
			cFiltro += Iif(!Empty(cFiltro)," .AND. ","")
			cFiltro += mv_par07     
		EndIf                                             
	
		oSection:SetFilter(cFiltro) 
		(cAliasQry)->( DbGoTop() )

	#ENDIF	
	
	If nOrdem == 1
		cTitulo += CHR(13) + OemToAnsi(STR0008)		//"(Filial + Matricula)"
	ElseIf nOrdem == 2  
		cTitulo +=	CHR(13) + OemToAnsi(STR0003)		//"(Filial + Nome)"		
	Endif			
											
	oReport:SetTitle(cTitulo)  
	
	aCampos := {}
	AADD(aCampos,{"FILIAL"   	,"C",TamSX3("RA_FILIAL")[1],0}) //02
	AADD(aCampos,{"MAT"      	,"C",06,0})
	AADD(aCampos,{"NOME"     	,"C",30,0})
	AADD(aCampos,{"CODFUNC"  	,"C",05,0})
	AADD(aCampos,{"DESCFUNC" 	,"C",TamSX3("RJ_DESC")[1],0}) //05
	AADD(aCampos,{"SALARIO"     ,"N",TamSX3("RGL_SALARI")[1],2})    
	AADD(aCampos,{"INIFUNCAO"  	,"D",08,0})   
	AADD(aCampos,{"FIMFUNCAO"  	,"D",08,0})   
	AADD(aCampos,{"DIAS"      	,"N",03,0})   

	oTmpTable := FWTemporaryTable():New("TRA")
	oTmpTable:SetFields( aCampos )
	
	If nOrdem == 1
		aOrdem	:=	{"FILIAL","MAT"} 
	ElseIf nOrdem == 2
		aOrdem	:=	{"FILIAL","NOME"}  
	EndIf

	oTmpTable:AddIndex("IN1", aOrdem)

	oTmpTable:Create()
	dbSelectArea( cAliasQry )

	//-- Define o total da regua da tela de processamento do relatorio
	oReport:SetMeter( 100 )

	//-- Incializa impressao   
	oSection:Init()                              

	If !(cAliasQry)->( EOF() ) 
		DbSelectArea("RGL")				
		cTrbRGL := CriaTrab(,.F.)
		IndRegua("RGL",cTrbRGL,"RGL_FILIAL+RGL_MAT+DTOS(RGL_DTINI)+DTOS(RGL_DTFIM)",,DBFilter())
		#IFNDEF TOP
			dbSetIndex(cTrbRGL+OrdBagExt())
		#ENDIF
		("RGL")->( dbSetOrder( 1 ) )
		DbSelectArea("SRJ")         
		("SRJ")->( DbGoTop() )		
		("SRJ")->( dbSetOrder( 1 ) )
	Endif	

	While !(cAliasQry)->( EOF() ) 
	
		//��������������������������������������������������������������Ŀ
		//� Movimenta Regua de Processamento                             �
		//����������������������������������������������������������������
		oReport:IncMeter( 1 )   

		//-- Verifica se o usu�rio cancelou a impress�o do relatorio
		If oReport:Cancel()
			Exit
		EndIf               
		
		dbSelectArea( cAliasQry )

		RGL->(dbSeek( xFilial(cAliasQry) + (cAliasQry)->RA_MAT))  

		While !RGL-> ( EOF() ) .AND. ( RGL->RGL_FILIAL + RGL->RGL_MAT = xFilial(cAliasQry)+(cAliasQry)->RA_MAT ) .AND. RGL->RGL_DTINI >= dDataDe .AND. RGL->RGL_DTFIM <= dDataAte  
			SRJ->(dbSeek( xFilial("SRJ") + RGL->RGL_CODFUN)) 
			RecLock("TRA",.T.)
			Replace FILIAL    With (cAliasQry)->RA_FILIAL
			Replace MAT       With (cAliasQry)->RA_MAT
			Replace NOME      With (cAliasQry)->RA_NOME
			Replace CODFUNC   With RGL->RGL_CODFUN
			Replace DESCFUNC  With SRJ->RJ_DESC
			Replace SALARIO   With RGL->RGL_SALARI
			Replace INIFUNCAO With RGL->RGL_DTINI        
			Replace FIMFUNCAO With RGL->RGL_DTFIM
			Replace DIAS      With RGL->RGL_DIAS
			MsUnLock()   
			dbSelectArea("RGL") 	
			RGL->(dbSkip())    

		EndDo  

		dbSelectArea( cAliasQry )
		dbSkip()
	EndDo

	#IFDEF TOP
		dbSelectArea(cString)
		dbCloseArea()
	#Endif	

	oSection:CloseQuery()

	//������������������������������������������������������Ŀ
	//� EMISSAO DO RELATORIO   								 �
	//��������������������������������������������������������
	dbSelectArea("TRA")  
	dbGotop()

		
	While !Eof()
                            
		//��������������������������������������������������������������Ŀ
		//� Imprime a linha                                    	 	     �
		//����������������������������������������������������������������
		oSection:PrintLine()

		dbSelectArea( "TRA" )
		dbSkip() 
	EndDo

	//��������������������������������������������������������������Ŀ
	//� Termino do relatorio									     �
	//����������������������������������������������������������������
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter To

	dbSelectArea("TRA")
	dbCloseArea()


	If File(cTrbRGL+OrdBagExt())
		Ferase(cTrbRGL+OrdBagExt())
	EndIf

//��������������������������������������������������������������Ŀ
//� Finaliza impressao inicializada pelo metodo Init             �
//����������������������������������������������������������������
oSection:Finish()  

	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil 
	EndIf
Return Nil
