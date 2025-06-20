#INCLUDE "CRDR040.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDR040   � Autor � Marcos Roberto Andrade� Data � 07.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Listagem de Vale-Compras.                                   ���
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
Function CRDR040()
Local oReport				// Objeto para geracao do relatorio
Local aArea := GetArea()	// Salva a area

If FindFunction("TRepInUse") .OR. TRepInUse()

	Pergunte("CRD040",.F.)
	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������
	oReport := CRD040RptDef()
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
���Programa  �CRD040RptDeF�Autor  �Marcos R. Andrade   � Data �  14/07/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela  ���
���          �latorio                                                       ���
���������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CRD040RptDef()
Local oReport											// Objeto do relatorio
Local oSection1											// Objeto da secao 1	
Local cAlias1	:= "MAV"								// Pega o proximo Alias Disponivel

#IFDEF TOP
	cAlias1		:= GetNextAlias()						// Pega o proximo Alias Disponivel
#ENDIF	

DEFINE REPORT oReport 	NAME "CRDR040"		; 
						TITLE STR0001		;			//### Relatorio de Vale-Compras		
	 					PARAMETER "CRD040"	;			//Arquivo de parametros			 
	 					ACTION {|oReport| CRD040PrtRpt(oReport, cAlias1)} DESCRIPTION STR0002 //##"Este programa ir� emitir uma listagem dos Vale-Compras cadastrados"                                                                                                                                                                                                                                                                                                                                                                                                                                                
	//������������������������������������������Ŀ
	//�Definido a sessao PAI                     �
	//��������������������������������������������
	DEFINE SECTION oSection1 OF oReport TITLE STR0003 TABLES "MAV"    // "Cadastro de Vale-Compra"
		
		DEFINE CELL NAME "MAV_CODIGO" 	OF oSection1 ALIAS "MAV"
		DEFINE CELL NAME "MAV_LOJA" 	OF oSection1 ALIAS "MAV"
		DEFINE CELL NAME "MAV_VALOR"	OF oSection1 ALIAS "MAV" 
		DEFINE CELL NAME "MAV_STATUS" 	OF oSection1 ALIAS "MAV"

Return oReport 


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �CRD040PrtRpt�Autor  �Marcos R. Andrade   � Data �  14/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio                            ���
���������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CRD040PrtRpt(oReport, cAlias1)
Local oSection1 := oReport:Section(1)					//Define a secao 1 do relatorio
Local cWhere1		:= "%%" 							//Expressao 1 
Local cFiltro		:= "" 								//Filtro DBF

#IFDEF TOP
	//����������������Ŀ
	//�Query da secao 1�
	//������������������
	DbSelectArea("MAV")
	DbSetOrder(1)
	
	MakeSqlExpr("CRD040")
         
	If Empty(MV_PAR01) 
	    cWhere1	:= "%MAV_CODIGO >='01' "
	Else
	    cWhere1	:= "%MAV_CODIGO >='" + AllTrim(MV_PAR01) +"' "
	Endif
	
	If !Empty(MV_PAR02)
		cWhere1	+= " AND MAV_CODIGO <='" + AllTrim(MV_PAR02) +"' "
	Endif 
	
	If !Empty(MV_PAR03)
		cWhere1	+= " AND MAV_STATUS ='" + AllTrim(STR(MV_PAR03)) +"' "
	Endif  
	cWhere1	+= "%"

	BEGIN REPORT QUERY oSection1
	
		BeginSql alias cAlias1
			SELECT	 MAV_FILIAL,	MAV_CODIGO,		MAV_LOJA,	MAV_VALOR ,		
					 MAV_STATUS
			FROM %table:MAV% MAV
			WHERE	MAV_FILIAL = %xfilial:MAV%	AND
					%exp:cWhere1% 			    AND				
					MAV.%notDel%
				 	                                
			ORDER BY %ORDER:MAV%
		EndSql
	END REPORT QUERY oSection1     
	
	oSection1:SetHeaderSection(.T.)		//Define que o header vai ser apresentado

#ELSE
	//���������������������������������������������������������������������������������Ŀ
	//�Utilizar a funcao MakeAdvlExpr, somente quando for utilizar o range de parametros�
	//�����������������������������������������������������������������������������������
	MakeAdvplExpr("CRDR040")
	
	DbSelectArea("MAV")
	DbSetOrder(1)

	cFiltro	:= "MAV_FILIAL ='"+xFilial("MAV")+"'"
	    
	If !Empty(MV_PAR01) 
		cFiltro	+= " .AND. MAV_CODIGO >='" + AllTrim(MV_PAR01) +"'"
	Endif
	
	If !Empty(MV_PAR02)
		cFiltro	+= " .AND. MAV_CODIGO <='" + AllTrim(MV_PAR02) +"'"
	Endif 
	
	If !Empty(MV_PAR03)
		cFiltro	+= " .AND. MAV_STATUS =='" + AllTrim(STR(MV_PAR03)) +"'"
	Endif

	oSection1:SetFilter( cFiltro )	

	oSection1:SetHeaderSection(.T.)		
	
#ENDIF	
oSection1:SetLineBreak()
oSection1:Print()

Return