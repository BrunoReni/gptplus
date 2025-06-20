#INCLUDE "CRDR030.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "PROTHEUS.CH"
/*/                                                                        
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDR030   � Autor � Marcos Roberto Andrade� Data � 22.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio Cliente X Cartoes                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
���ANALISTA  � DATA   � BOPS �MOTIVO DA ALTERACAO                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDR030()
Local oReport				// Objeto para geracao do relatorio
Local aArea := GetArea()	// Salva a area

If FindFunction("TRepInUse") .OR. TRepInUse()

	Pergunte("CRD030",.F.)
	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������
	oReport := CRD030RptDef()
	oReport:PrintDialog()
EndIf

//���������������Ŀ
//�Restaura a area�
//�����������������
RestArea( aArea )
Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �CRD030RptDeF�Autor  �Marcos R. Andrade   � Data �  22/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela  ���
���          �latorio                                                       ���
���������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CRD030RptDef()
Local oReport											// Objeto do relatorio
Local oSection1											// Objeto da secao 1	 
Local oSection2											// Objeto da secao 2	
Local oSection3											// Objeto da secao 3	
Local cAlias1	:= "SA1"								// Pega o proximo Alias Disponivel

#IFDEF TOP
	cAlias1		:= GetNextAlias()						// Pega o proximo Alias Disponivel
#ENDIF	

DEFINE REPORT oReport 	NAME "CRDR030"		; 
						TITLE STR0001		;			//### "Relatorio de Clientes X Cartoes" 
	 					PARAMETER "CRD030"	;			//Arquivo de parametros			 
	 					ACTION {|oReport| CRD030PrtRpt(oReport, cAlias1)} DESCRIPTION STR0002 //##"Este programa ir� emitir o relat�rio de clientes x cart�es private label."
	//������������������������������������������Ŀ
	//�Definido a sessao PAI                     �
	//��������������������������������������������
	DEFINE SECTION oSection1 OF oReport TITLE STR0005 TABLES "SA1" // Cadastro de Clientes
		DEFINE CELL NAME "A1_COD" 		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "A1_NOME" 		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "A1_END"		OF oSection1 ALIAS "SA1" 
		DEFINE CELL NAME "A1_MUN"		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "A1_EST"		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "A1_CEP"		OF oSection1 ALIAS "SA1" 
		DEFINE CELL NAME "A1_CGC"		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "A1_DDD"		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "A1_TEL"		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "A1_CEP"		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "A1_LC"		OF oSection1 ALIAS "SA1"
		DEFINE CELL NAME "A1_VENCLC"	OF oSection1 ALIAS "SA1"
	//�����������������������������Ŀ
	//�Define a secao2 do relatorio �                           
	//�������������������������������                           
  	DEFINE SECTION oSection2 OF oSection1 TITLE STR0003 TABLES "MA6" // "Cart�es Private Label"
		DEFINE CELL NAME "MA6_NUM"		OF oSection2 ALIAS "MA6"		 
		DEFINE CELL NAME "MA6_DTEVE"	OF oSection2 ALIAS "MA6"		
		DEFINE CELL NAME "MA6_SITUA"	OF oSection2 ALIAS "MA6"	 
		DEFINE CELL NAME "MA6_MOTIVO"	OF oSection2 ALIAS "MA6"	
		DEFINE CELL NAME "MA6_DTREC"	OF oSection2 ALIAS "MA6"	
		DEFINE CELL NAME "MA6_DTENV"	OF oSection2 ALIAS "MA6"	
		DEFINE CELL NAME "MA6_CODDEP"	OF oSection2 ALIAS "MA6"	

	//�����������������������������Ŀ
	//�Define a secao3 do relatorio �                           
	//�������������������������������                           
	DEFINE SECTION oSection3 OF oSection2 TITLE STR0004 TABLES "MAC", "MA0" // "Dependentes"
		DEFINE CELL NAME "MAC_DEPNOM" 	OF oSection3 ALIAS "MAC"
		DEFINE CELL NAME "MAC_DEPDTN" 	OF oSection3 ALIAS "MAC"  
		DEFINE CELL NAME "MAC_DEPGRA" 	OF oSection3 ALIAS "MAC" 
		DEFINE CELL NAME "MAO_DESC" 	OF oSection3 ALIAS "MAO" 

Return oReport 

                       
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �CRD030PrtRpt�Autor  �Marcos R. Andrade   � Data �  22/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio                            ���
���������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CRD030PrtRpt(oReport, cAlias1)
Local oSection1 := oReport:Section(1)				   								//Define a secao 1 do relatorio        
Local oSection2 := oReport:Section(1):Section(1)	   								//Define que a secao 2 sera filha da secao 1 
Local oSection3 := oReport:Section(1):Section(1):Section(1)						//Define que a secao 3 sera filha da secao 1
Local cQuery	:= "%%" 								//Query 1 
Local cFiltro	:= "" 									//Filtro DBF

DbSelectArea("SA1")
DbSetOrder(1)
    
MakeSqlExpr("CRD030")

#IFDEF TOP
	//����������������Ŀ
	//�Query da secao 1�
	//������������������         
	If Empty(MV_PAR01) 
	    cQuery	:= "% A1_COD >='' "
	Else
	    cQuery	:= "% A1_COD >='" + AllTrim(MV_PAR01) +"' "
	Endif
	
	If Empty(MV_PAR02)               
		cQuery	+= " AND A1_LOJA >='' "
	Else
		cQuery	+= " AND A1_LOJA >='" + AllTrim(MV_PAR02) +"' "
	Endif 
	
	If !Empty(MV_PAR03)
		cQuery	+= " AND A1_COD <='" + AllTrim(MV_PAR03) +"' "
	Endif

	If !Empty(MV_PAR04)
		cQuery	+= " AND A1_LOJA <='" + AllTrim(MV_PAR04) +"' "
	Endif 	
            
	If !Empty(MV_PAR05)
		cQuery	+= " AND MA6_NUM >='" + AllTrim(MV_PAR05) +"' "
	Endif 	
	
	If !Empty(MV_PAR06)
		cQuery	+= " AND MA6_NUM <='" + AllTrim(MV_PAR06) +"' "
	Endif 	

	
	cQuery	+= "%"

	BEGIN REPORT QUERY oSection1
	
		BeginSql alias cAlias1
		
			SELECT	A1_LOJA,	A1_COD,		A1_NOME,	A1_END,	A1_MUN,
					A1_EST,		A1_CEP,		A1_CGC,		A1_DDD,
					A1_TEL,		A1_CEP,		A1_LC,		A1_VENCLC,
					MA6_NUM,	MA6_DTEVE,	MA6_SITUA,	MA6_MOTIVO,
					MA6_DTREC,	MA6_DTENV,	MA6_CODDEP, MA6_CODCLI,
					MA6_LOJA,	MAC_DEPNOM, MAC_DEPDTN,	MAC_DEPGRA, 
					MAC_CODDEP, MAC_CODCLI,	MAC_LOJA	

			FROM %table:SA1% sA1 INNER JOIN %table:MA6% MA6 ON	MA6_CODCLI = A1_COD		AND	
																MA6_LOJA   = A1_LOJA	
								LEFT JOIN %table:MAC% MAC ON	MAC_CODDEP = MA6_CODDEP	AND	
																MAC_CODCLI = MA6_CODCLI AND
																MAC_LOJA   = MA6_LOJA													
			WHERE 	A1_FILIAL	= %xfilial:SA1%		AND
					%exp:cQuery% 			    	AND
					SA1.%notDel%					AND
					MA6_FILIAL  = %xfilial:MA6%	    AND
					MA6.%notDel%					
					
			ORDER BY %ORDER:SA1%
		EndSql
	END REPORT QUERY oSection1   
	
	//����������������������������������������������������Ŀ
	//� Posiciona nas tabelas secundarias usadas na secao5 �
	//������������������������������������������������������
	TRPosition():New(oSection3,"MAO",1,{|| xFilial("MAO")+(cAlias1)->MAC_DEPGRA })    
	                                                     		
	//�������������������������������������������������������������������������������������������Ŀ
	//�Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao�
	//���������������������������������������������������������������������������������������������
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( { | cParam |	(cAlias1)->MA6_CODCLI+(cAlias1)->MA6_LOJA == cParam},;
											{|| (cAlias1)->A1_COD+(cAlias1)->A1_LOJA } )

	//�������������������������������������������������������������������������������������������Ŀ
	//�Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao�
	//���������������������������������������������������������������������������������������������
	oSection3:SetParentQuery()
	oSection3:SetParentFilter( { | cParam |	(cAlias1)->MAC_CODDEP+(cAlias1)->MAC_CODCLI+(cAlias1)->MAC_LOJA == cParam},;
											{|| (cAlias1)->MA6_CODDEP+(cAlias1)->MA6_CODCLI+(cAlias1)->MA6_LOJA } )
									
	oSection1:SetHeaderSection(.T.)		//Define que o header vai ser apresentado

 #ELSE
	                  
	cFiltro	:= "A1_FILIAL ='"+xFilial("SA1")+"'"

	//����������������Ŀ
	//�Query da secao 1�
	//������������������         
	If !Empty(MV_PAR01) 
	    cFiltro	+= " .AND. A1_COD >='" + AllTrim(MV_PAR01) +"' "
	Endif
	
	If !Empty(MV_PAR02)               
		cFiltro	+= " .AND. A1_LOJA >='" + AllTrim(MV_PAR02) +"' "
	Endif 
	
	If !Empty(MV_PAR03)
		cFiltro	+= " .AND. A1_COD <='" + AllTrim(MV_PAR03) +"' "
	Endif

	If !Empty(MV_PAR04)
		cFiltro	+= " .AND. A1_LOJA <='" + AllTrim(MV_PAR04) +"' "
	Endif 	
	             
 	//��������������������������������������������������������������������������������������������������������
	//�Efetua o filtro de acordo com a expressao                                                             �
	//��������������������������������������������������������������������������������������������������������
	oSection1:SetFilter( cFiltro )    
	
	//�����������������������������������������������������������������������������������������������������Ŀ
	//�Efetua a condicao do codeblock dentro do filtro jah efetuado, efetua o filtro do MA6_NUM do pergunte �
	//�������������������������������������������������������������������������������������������������������
	oSection1:SetLineCondition({|| ChkMA6_NUM()})
	 	                                                     		

	//����������������������������������������������������Ŀ
	//� Posiciona nas tabelas secundarias usadas na secao3 �
	//������������������������������������������������������
	TRPosition():New(oSection3,"MAO",1,{|| xFilial("MAO")+MAC->MAC_DEPGRA })    
	
	//�������������������������������������������������������������������������������������������Ŀ
	//�Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao�
	//���������������������������������������������������������������������������������������������
	oSection2:SetRelation({|| xFilial("MA6")+SA1->A1_COD+SA1->A1_LOJA },"MA6",2,.T.)
	oSection2:SetParentFilter( { | cParam |	MA6->MA6_CODCLI+MA6->MA6_LOJA == cParam},;
											{|| SA1->A1_COD+SA1->A1_LOJA } )

	//�������������������������������������������������������������������������������������������Ŀ
	//�Baseada na query da secao2, utiliza filtro para saber quando deve sair do laco de impressao�
	//���������������������������������������������������������������������������������������������

	oSection3:SetRelation({|| xFilial("MAC")+MA6->MA6_CODDEP+MA6->MA6_CODCLI+MA6->MA6_LOJA },"MAC",1,.T.)
	oSection3:SetParentFilter( { | cParam |	MAC->MAC_CODDEP+MAC->MAC_CODCLI+MAC->MAC_LOJA == cParam},;
											{|| MA6->MA6_CODDEP+MA6->MA6_CODCLI+MA6->MA6_LOJA } )										


	oSection1:SetHeaderSection(.T.)		                                                                                                
	
	
#ENDIF	                                                                                                                
oSection1:SetLineBreak()
oSection1:Print()

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ChkMA6_NUM �Autor  �Marcos Andrade      � Data �  23/05/06   ���
��������������������������������������������������������������������������͹��
���Desc.     �Funcao para considerar os cartoes, informado no parametro    ���
���          �no filtro em Codebase                                        ���
��������������������������������������������������������������������������͹��
���Uso       � CRDR030                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function ChkMA6_NUM()

DbSelectArea( "MA6" )                                                       
DbSetOrder( 2 )
	
Return MsSeek( xFilial( "MA6" )+SA1->A1_COD+SA1->A1_LOJA ) .AND. MA6->MA6_NUM >= MV_PAR05 .AND. MA6->MA6_NUM <=MV_PAR06

