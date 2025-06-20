#INCLUDE "CRDR020.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDR020   � Autor � Marcos Roberto Andrade� Data � 14.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio de Questionario.                                  ���
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
Function CRDR020()
Local oReport				// Objeto para geracao do relatorio
Local aArea := GetArea()	// Salva a area

If FindFunction("TRepInUse") .OR. TRepInUse()

	Pergunte("CRD020",.F.)
	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������
	oReport := CRD020RptDef()
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
���Programa  �CRD020RptDeF�Autor  �Marcos R. Andrade   � Data �  16/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela  ���
���          �latorio                                                       ���
���������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CRD020RptDef()
Local oReport											// Objeto do relatorio
Local oSection1											// Objeto da secao 1	 
Local oSection2											// Objeto da secao 2	
Local oSection3											// Objeto da secao 3	
Local oSection4											// Objeto da secao 4	
//Local oSection5											// Objeto da secao 5
Local cAlias1	:= "SA1"								// Pega o proximo Alias Disponivel

#IFDEF TOP
	cAlias1		:= GetNextAlias()						// Pega o proximo Alias Disponivel
#ENDIF	

DEFINE REPORT oReport 	NAME "CRDR020"		; 
						TITLE STR0001		;			//### "Relacao de Questionarios" 
	 					PARAMETER "CRD020"	;			//Arquivo de parametros			 
	 					ACTION {|oReport| CRD020PrtRpt(oReport, cAlias1)} DESCRIPTION STR0002 //##"Este programa ir� emitir a ficha cadastral do cliente."
	//������������������������������������������Ŀ
	//�Definido a sessao PAI                     �
	//��������������������������������������������
	DEFINE SECTION oSection1 OF oReport TITLE STR0007 TABLES "SA1" 	// Cadastro de Cliente
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
  	DEFINE SECTION oSection2 OF oSection1 TITLE STR0003 TABLES "MA7" // "Complemento da ficha"
		DEFINE CELL NAME "MA7_PAI"		OF oSection2 ALIAS "MA7"		 
		DEFINE CELL NAME "MA7_MAE"		OF oSection2 ALIAS "MA7"		
		DEFINE CELL NAME "MA7_BLOQUE"	OF oSection2 ALIAS "MA7"	

	//�����������������������������Ŀ
	//�Define a secao3 do relatorio �                           
	//�������������������������������                           
	DEFINE SECTION oSection3 OF oSection2 TITLE STR0004 TABLES "MA8" // "Referencia de trabalho"
		DEFINE CELL NAME "MA8_TIPO" 	OF oSection3 ALIAS "MA8"
		DEFINE CELL NAME "MA8_EMPRES" 	OF oSection3 ALIAS "MA8"  
		DEFINE CELL NAME "MA8_DTADM" 	OF oSection3 ALIAS "MA8" 
		DEFINE CELL NAME "MA8_DTDES" 	OF oSection3 ALIAS "MA8" 
		DEFINE CELL NAME "MA8_RENDA" 	OF oSection3 ALIAS "MA8"  
	//�����������������������������Ŀ
	//�Define a secao4 do relatorio �                           
	//�������������������������������                           
	DEFINE SECTION oSection4 OF oSection3 TITLE STR0005 TABLES "MAB" // "Referencia pessoal"
		DEFINE CELL NAME "MAB_NOME" 	OF oSection4 ALIAS "MAB"
		DEFINE CELL NAME "MAB_DDD" 		OF oSection4 ALIAS "MAB"
		DEFINE CELL NAME "MAB_TEL" 		OF oSection4 ALIAS "MAB" 
		DEFINE CELL NAME "MAB_RAMAL" 	OF oSection4 ALIAS "MAB"
		DEFINE CELL NAME "MAB_OBS" 		OF oSection4 ALIAS "MAB" 
	//�����������������������������Ŀ
	//�Define a secao5 do relatorio �                           
	//�������������������������������                           	
	DEFINE SECTION oSection5 OF oSection4 TITLE STR0006 TABLES "MAA", "MAN" // "Referencia bancaria"
		DEFINE CELL NAME "MAA_BANCO" 	OF oSection5 ALIAS "MAA"
	   	DEFINE CELL NAME "MAN_DESC" 	OF oSection5 ALIAS "MAN"
		DEFINE CELL NAME "MAA_DTABER" 	OF oSection5 ALIAS "MAA" 
		DEFINE CELL NAME "MAA_TPCHEQ" 	OF oSection5 ALIAS "MAA"       


Return oReport 

                       
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �CRD020PrtRpt�Autor  �Marcos R. Andrade   � Data �  14/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio                            ���
���������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CRD020PrtRpt(oReport, cAlias1)
Local oSection1 := oReport:Section(1)				   								//Define a secao 1 do relatorio        
Local oSection2 := oReport:Section(1):Section(1)	   								//Define que a secao 2 sera filha da secao 1 
Local oSection3 := oReport:Section(1):Section(1):Section(1)						//Define que a secao 3 sera filha da secao 1
Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)			//Define que a secao 4 sera filha da secao 1
Local oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)	//Define que a secao 5 sera filha da secao 1
Local cQuery	:= "%%" 								//Query 1 
Local cFiltro	:= "" 									//Filtro DBF

DbSelectArea("SA1")
DbSetOrder(1)
    
MakeSqlExpr("CRD020")

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
	
	cQuery	+= "%"

	BEGIN REPORT QUERY oSection1
	
		BeginSql alias cAlias1
		
			SELECT	A1_LOJA,	A1_COD,	A1_NOME,	A1_END,	A1_MUN,
					A1_EST	,	A1_CEP,		A1_CGC,		A1_DDD,
					A1_TEL	,	A1_CEP,		A1_LC,		A1_VENCLC,
					MA7_PAI	,	MA7_MAE,	MA7_BLOQUE,	MA7_CODCLI,
					MA7_LOJA,	MA8_EMPRES,	MA8_DTADM,	MA8_DTDES,	
					MA8_RENDA,  MA8_LOJA,	MA8_CODCLI,	MAB_NOME,	MAB_DDD,	MAB_TEL,
					MAB_RAMAL,	MAB_OBS,    MAB_CODCLI, MAB_LOJA,	
					MAA_BANCO,	MAA_DTABER,	MAA_TPCHEQ, MAA_CODCLI, MAA_LOJA

			FROM %table:SA1% SA1 LEFT JOIN %table:MA7% MA7 ON	MA7_CODCLI = A1_COD	AND	
																MA7_LOJA   = A1_LOJA	
								LEFT JOIN %table:MA8% MA8 ON	MA8_CODCLI = A1_COD	AND	
																MA8_LOJA   = A1_LOJA	
								LEFT JOIN %table:MAB% MAB ON	MAB_CODCLI = A1_COD	AND	
																MAB_LOJA   = A1_LOJA	
								LEFT JOIN %table:MAA% MAA ON 	MAA_CODCLI = A1_COD	AND	
																MAA_LOJA   = A1_LOJA						
			WHERE 	A1_FILIAL	= %xfilial:SA1%		AND
					%exp:cQuery% 			    	AND
					SA1.%notDel%					AND
					MA7_FILIAL  = %xfilial:MA7%	    AND
					MA7.%notDel%					AND	
					MA8_FILIAL  = %xfilial:MA8%	    AND	
					MA8.%notDel%					AND
					MAB_FILIAL  = %xfilial:MAB%	    AND
					MAB.%notDel%					AND   
					MAA_FILIAL  = %xfilial:MAA%	    AND
					MAA.%notDel%				
					
			ORDER BY %ORDER:SA1%
		EndSql
	END REPORT QUERY oSection1   
	
	//����������������������������������������������������Ŀ
	//� Posiciona nas tabelas secundarias usadas na secao5 �
	//������������������������������������������������������
	TRPosition():New(oSection5,"MAN",1,{|| xFilial("MAN")+(cAlias1)->MAA_BANCO })    
	                                                     		
	//�������������������������������������������������������������������������������������������Ŀ
	//�Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao�
	//���������������������������������������������������������������������������������������������
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( { | cParam |	(cAlias1)->MA7_CODCLI+(cAlias1)->MA7_LOJA == cParam},;
											{|| (cAlias1)->A1_COD+(cAlias1)->A1_LOJA } )

	//�������������������������������������������������������������������������������������������Ŀ
	//�Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao�
	//���������������������������������������������������������������������������������������������
	oSection3:SetParentQuery()
	oSection3:SetParentFilter( { | cParam |	(cAlias1)->MA8_CODCLI+(cAlias1)->MA8_LOJA == cParam},;
											{|| (cAlias1)->A1_COD+(cAlias1)->A1_LOJA } )

	//�������������������������������������������������������������������������������������������Ŀ
	//�Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao�
	//���������������������������������������������������������������������������������������������
	oSection4:SetParentQuery()
	oSection4:SetParentFilter( { | cParam |	(cAlias1)->MAB_CODCLI+(cAlias1)->MAB_LOJA == cParam},;
											{|| (cAlias1)->A1_COD+(cAlias1)->A1_LOJA } )	   
											
	//�������������������������������������������������������������������������������������������Ŀ
	//�Baseada na query da secao1, utiliza filtro para saber quando deve sair do laco de impressao�
	//���������������������������������������������������������������������������������������������
	oSection5:SetParentQuery()
	oSection5:SetParentFilter( { | cParam |	(cAlias1)->MAA_CODCLI+(cAlias1)->MAA_LOJA == cParam},;
											{|| (cAlias1)->A1_COD+(cAlias1)->A1_LOJA } )											
									
	oSection1:SetHeaderSection(.T.)		//Define que o header vai ser apresentado


#ELSE
	                  
	cFiltro	:= "A1_FILIAL ='"+xFilial("SA1")+"'"

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

	oSection1:SetFilter( cFiltro )	        
	                                                                                     
	
	//����������������������������������������������������Ŀ
	//� Posiciona nas tabelas secundarias usadas na secao5 �
	//������������������������������������������������������
	TRPosition():New(oSection5,"MAN",1,{|| xFilial("MAN")+MAA->MAA_BANCO })    
											
	//����������������������������������������������������������������������������������Ŀ
	//� Executa a secao2, com o mesmo filtro da secao1.                                  �
	//������������������������������������������������������������������������������������
	oSection2:SetRelation({|| xFilial("MA7")+SA1->A1_COD+SA1->A1_LOJA },"MA7",1,.T.)
	oSection2:SetParentFilter(	{|cParam| MA7_CODCLI+MA7_LOJA == cParam}, {||SA1->A1_COD+SA1->A1_LOJA })
		
																   
	//�������������������������������������������������������������������������������������������Ŀ
	//�Executa a secao3, com o mesmo filtro da secao1. �
	//���������������������������������������������������������������������������������������������
	oSection3:SetRelation({|| xFilial("MA8")+SA1->A1_COD+SA1->A1_LOJA },"MA8",3,.T.)
	oSection3:SetParentFilter( { | cParam |	MA8_CODCLI+MA8_LOJA == cParam}, {|| SA1->A1_COD+SA1->A1_LOJA } )

	//�������������������������������������������������������������������������������������������Ŀ
	//�Executa a secao4, com o mesmo filtro da secao1. �
	//���������������������������������������������������������������������������������������������
	oSection4:SetRelation({|| xFilial("MAB")+SA1->A1_COD+SA1->A1_LOJA },"MAB",2,.T.)
	oSection4:SetParentFilter( { | cParam |	MAB_CODCLI+MAB_LOJA == cParam},{|| SA1->A1_COD+SA1->A1_LOJA } )	   
											
	//�������������������������������������������������������������������������������������������Ŀ
	//�Executa a secao5, com o mesmo filtro da secao1. �
	//���������������������������������������������������������������������������������������������
	oSection5:SetRelation({|| xFilial("MAA")+SA1->A1_COD+SA1->A1_LOJA },"MAA",2,.T.)
	oSection5:SetParentFilter( { | cParam |	MAA_CODCLI+MAA_LOJA == cParam},	{|| SA1->A1_COD+SA1->A1_LOJA } )				
	
	oSection1:SetHeaderSection(.T.)		
	
#ENDIF	                                                                                                                
oSection1:SetLineBreak()
oSection1:Print()

Return