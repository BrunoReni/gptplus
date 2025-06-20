#INCLUDE "REPORT.CH" 
#INCLUDE "TMKR508.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR508  � Autor � Vendas CRM            � Data � 30/08/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atendimentos por analista e equipe                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMKR501(void)                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR508()

Local oReport	//Objeto relatorio TReport (Release 4)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TMKR508",.F.)

//�����������������������������������������Ŀ
//� Variaveis utilizadas para parametros	�
//� Mv_PAR01	// De						�
//� Mv_PAR02	// Ate						�
//� Mv_PAR03	// Da Equipe				�
//� Mv_PAR04	// At� a Equipe				�
//� Mv_PAR05	// Do analista				�
//� Mv_PAR06	// At� o analista			�
//� Mv_PAR07	// Indicador        		�				
//� Mv_PAR08	// Tipo de Relatorio		�  
//� MV_PAR09	// Exibe sub-equipes ?   	|		
//�������������������������������������������

//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport := ReportDef()
oReport:PrintDialog() 

Return(.T.)
                     
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef �    Autor �Vendas CRM          � Data �30/08/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina que define os itens que serao apresentados no relato-���
���          �rio.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/              
Static Function ReportDef()
Local oReport 				// Objeto relatorio TReport (Release 4)
Local oSection1             // Objeto secao 1 do relatorio (Cabecalho, campos das tabelas SU2 e SB1)
Local oSection2             // Objeto secao 2 do relatorio (Itens, campos da tabela SU2)
Local oSection4             // Objeto secao 4 do relatorio 
Local cAlias := "ADE"		// Alias da consulta Embedded SQL
Local oBreak				// Break para a se��o 3

cAlias	:= GetNextAlias()						// Pega o proximo Alias Disponivel

DEFINE REPORT oReport NAME "TMKR508" TITLE STR0001 PARAMETER "TMKR508" ACTION {|oReport| Tkr508PrtRpt( oReport, cAlias )} DESCRIPTION STR0002 // "Atendimentos por analista e equipe" "Possibilitar a consulta e extra��o de relat�rio de produtividade analista/equipe por per�odo"

//�����������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal �
//�������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0003 TABLES "ADE"		// "Chamados da �rea"
DEFINE SECTION oSection2 OF oSection1 TITLE STR0004 TABLES "ADE"	// "Chamados do analista"
DEFINE SECTION oSection3 OF oSection2 TITLE STR0005 TABLES "ADE"	// "Chamados por tipo de comunica��o"
DEFINE SECTION oSection4 OF oSection2 TITLE STR0005 TABLES "ADE"	// "Atendimentos avulsos"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������   
DEFINE CELL NAME "ADE_GRUPO"	OF oSection1 ALIAS "ADE" BLOCK {||TRIM((cAlias)->ADE_GRUPO + " - " + POSICIONE('SU0',1,xFilial('SU0')+(cAlias)->ADE_GRUPO,'U0_NOME'))} SIZE 40

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������   
DEFINE CELL NAME "ADE_OPERAD"		OF oSection2 ALIAS "ADE"	TITLE STR0006	BLOCK {||TRIM((cAlias)->ADE_OPERAD + " - " + FATPDObfuscate(POSICIONE('SU7',1,XFILIAL('SU7') + (cAlias)->ADE_OPERAD, 'U7_NOME'),"U7_NOME",,.T.))} SIZE 30	// "Analista"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao3�
//�����������������������������������������������   
DEFINE CELL NAME "TIPO"				OF oSection3 ALIAS ""		TITLE STR0007	SIZE 40		// "Tipo de comunica��o"
DEFINE CELL NAME "ABERTO_PENDENTE"	OF oSection3 ALIAS "" 		TITLE STR0008	ALIGN RIGHT	// "Aberto/Pendente"
DEFINE CELL NAME "APRELATIVO"		OF oSection3 ALIAS "" 		TITLE STR0021	ALIGN RIGHT	// "Aberto/Pendente relativo ao total"
DEFINE CELL NAME "ENCERRADO"		OF oSection3 ALIAS ""		TITLE STR0009	ALIGN RIGHT	// "Encerrado"
DEFINE CELL NAME "ERELATIVO"		OF oSection3 ALIAS ""		TITLE STR0022	ALIGN RIGHT	// "Encerrado relativo ao total"
DEFINE CELL NAME "SUB_TOTAL"		OF oSection3 ALIAS ""		TITLE STR0010	ALIGN RIGHT	// "Sub-Total"
DEFINE CELL NAME "STRELATIVO"		OF oSection3 ALIAS ""		TITLE STR0020	ALIGN RIGHT	// "Relativo ao total"

DEFINE BREAK oBreak OF oSection3 WHEN oSection2:Cell("ADE_OPERAD")

//������������������Ŀ
//�Sub totalizadores.�
//��������������������
DEFINE FUNCTION FROM oSection3:Cell("ABERTO_PENDENTE") FUNCTION SUM BREAK oBreak NO END REPORT NO END SECTION
DEFINE FUNCTION FROM oSection3:Cell("ENCERRADO") FUNCTION SUM BREAK oBreak NO END REPORT NO END SECTION
DEFINE FUNCTION FROM oSection3:Cell("SUB_TOTAL") FUNCTION SUM BREAK oBreak NO END REPORT NO END SECTION

Return(oReport)  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tkr508PrtRpt � Autor �Vendas CRM          � Data �30/08/2008���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tkr508PrtRept(ExpO1,ExpC2)                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = objeto relatorio                                   ���
���          � ExpC1 = alias da query atual                               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tkr508PrtRpt(oReport, cAlias)
Local oSection1 	:= oReport:Section(1)				// Objeto secao 1 do relatorio
Local oSection2 	:= oSection1:Section(1)				// Objeto secao 2 do relatorio
Local oSection3 	:= oSection2:Section(1)				// Objeto secao 2 do relatorio
Local oSection4 	:= oSection1:Section(1)				// Objeto secao 4 do relatorio
Local cAliasAux1	:= GetNextAlias()					// Alias auxiliar para a contagem de dias �teis
Local cAliasAux2	:= GetNextAlias()					// Alias auxiliar para a contagem de feedbacks
Local cAliasAux3	:= GetNextAlias()					// Alias auxiliar para a contagem de feedbacks
Local cAliasAux4	:= GetNextAlias()					// Alias auxiliar para a contagem de feedbacks
Local lSintetico	:= IF(MV_PAR08 == 1, .T. , .F.)	// Se o relat�rio � anal�tico ou sint�tico
Local cSelect		:= ""                              	// Campos que ser�o selecionados por padr�o
Local cGroupBy		:= ""								// Agrupamento dos campos
Local cWhereADE		:= ""								// Condi��es da tabela ADE
Local cWhereADF 	:= ""								// Condi��es da tabela ADF
Local cWhereP		:= ""								// Condi��es da tabela principal		
Local cWhereI1		:= ""								// Where para pegar os dados do indicador 1
Local aDiasUteis	:= {}								// Array com os dias �teis trabalhados por operador sendo, [n,1] = C�digo do operador e [n,2] = Dias trabalhados
Local aFeedbacks	:= {}								// Quantidade de atendimentos realizados por operador sendo, [n,1] = C�digo do operador e [n,2] = Quantidade de atendimentos
Local aChamComI		:= {}								// Chamados com o indicador selecionado
Local aChamados		:= {}								// Buffer de chamados para pegar o totalizador e imprimir
Local cGrupo		:= ""								// Grupo de an�lise
Local cOperador 	:= ""                               // Operador em an�lise
Local cTipoComu		:= ""								// Tipo de comunica��o em an�lise
Local nNaoEncerrado	:= 0								// Quantidade de chamados em aberto/encerrado do operador
Local nEncerrado	:= 0								// Quantidade de chamados encerrados do operador
Local nFeedbacks	:= 0								// Quantidade de feedback do operador
Local nDiasUteis	:= 0								// Quantidade de dias �teis do operador
Local nTotAP		:= 0								// Total de chamados em aberto/encerrado do grupo
Local nTotE			:= 0								// Total de chamados encerrados do grupo
Local nTotAPGeral	:= 0								// Total de chamados em aberto/encerrado no total
Local nTotEGeral	:= 0								// Total de chamados encerrados no total
Local nPos			:= 0								// Vari�vel tempor�ria
Local nChamComI		:= 0								// Vari�vel tempor�ria com a quantidade de chamados com o indicador selecionado
Local nConta		:= 0								// Vari�vel tempor�ria
Local cListSU0  := FormatIn( Tkr501SelGp(Mv_Par03, Mv_Par04), ",")
Local cListSU0E := ""
Local Ix        := 0

MakeSqlExpr("TMKR508")	

If lSintetico
	cSelect		:= "% ADE_GRUPO, ADE_TIPO, ADE_STATUS %"
	cGroupBy	:= "% ADE_GRUPO, ADE_TIPO, ADE_STATUS %"
Else
	cSelect		:= "% ADE_GRUPO, ADE_OPERAD, ADE_TIPO, ADE_STATUS %"
	cGroupBy	:= "% ADE_GRUPO, ADE_OPERAD, ADE_TIPO, ADE_STATUS %"
EndIf
																			
cWhereADE += " ADE_FILIAL ='" + xFilial("ADE") + "' AND "
cWhereADE += " ADE_DATA >= '" + DToS(MV_PAR01) + "' AND ADE_DATA <= '" + DToS(MV_PAR02) + "' AND "

If Type("Mv_Par09") == "N" .AND. Mv_Par09 == 1
	cWhereADE += "ADE_GRUPO	IN " + cListSU0 + " AND "
Else
	cWhereADE += "ADE_GRUPO	BETWEEN '" + Mv_Par03 + "' AND '" + Mv_Par04 + "' AND								"
EndIf	
	
cWhereADE += " ADE_OPERAD >= '" + MV_PAR05 + "' AND ADE_OPERAD <= '" + MV_PAR06 + "' AND "
cWhereADE += " ADE.D_E_L_E_T_ = ' ' "

cWhereADF += " ADF_FILIAL ='" + xFilial("ADF") + "' AND "	
cWhereADF += " ADF_DATA >= '" + DToS(MV_PAR01) + "' AND ADF_DATA <= '" + DToS(MV_PAR02) + "' AND "

If Type("Mv_Par09") == "N" .AND. Mv_Par09 == 1
	cWhereADF += "ADF_CODSU0	IN " + cListSU0 + " AND "
Else
	cWhereADF += "ADF_CODSU0	BETWEEN '" + Mv_Par03 + "' AND '" + Mv_Par04 + "' AND								"
EndIf		

cWhereADF += " ADF_CODSU7 >= '" + MV_PAR05 + "' AND ADF_CODSU7 <= '" + MV_PAR06 + "' AND "
cWhereADF += " ADF.D_E_L_E_T_=' ' "	
				
//����������������Ŀ
//�Query principal.�
//������������������
cWhereP := "% " + cWhereADE + " %"
BEGIN REPORT QUERY oSection1 
	BeginSQL alias cAlias
			SELECT	%exp:cSelect%, 
					COUNT(*) as NCOUNT        	           			      			
			FROM     %table:ADE% ADE
			WHERE  	%exp:cWhereP% AND
					ADE.%notDel% 	           							 			           
			GROUP BY %exp:cGroupBy%				
	EndSql    
END REPORT QUERY oSection1	

//��������������������������������Ŀ
//�Query da contagem de dias �teis.�
//����������������������������������
cQuery := "SELECT ADF_DATA,ADF_CODSU7 FROM " + RetSqlName("ADF") + " ADF WHERE " + cWhereADF + " GROUP BY ADF_DATA, ADF_CODSU7 ORDER BY ADF_CODSU7"	

cQuery := ChangeQuery(cQuery)    	
//MemoWrite("TMKR508.SQL", cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasAux1, .F., .T.)		
aDiasUteis := {}
While (cAliasAux1)->(!EOF())
	cOperador := (cAliasAux1)->ADF_CODSU7
	aAdd( aDiasUteis, { (cAliasAux1)->ADF_CODSU7, 0 } )		
	Do While (cAliasAux1)->(!EOF()) .AND. (cAliasAux1)->ADF_CODSU7 == cOperador
		aDiasUteis[Len(aDiasUteis),2]++
		(cAliasAux1)->(DbSkip())
	End 				
End
(cAliasAux1)->(DbCloseArea())  

//�������������������������������Ŀ
//�Query da contagem de feedbacks.�
//���������������������������������
cQuery := "SELECT ADF_CODSU7, COUNT(*) AS FEEDBACKS FROM " + RetSqlName("ADF") + " ADF WHERE " + cWhereADF + " GROUP BY ADF_CODSU7"	

cQuery := ChangeQuery(cQuery)    	
//MemoWrite("TMKR508.SQL", cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasAux2, .F., .T.)		
aFeedbacks := {}
While (cAliasAux2)->(!EOF())
	aAdd( aFeedbacks, { (cAliasAux2)->ADF_CODSU7, (cAliasAux2)->FEEDBACKS, "N" } )		
	(cAliasAux2)->(DbSkip())
End
(cAliasAux2)->(DbCloseArea())	

If lSintetico
	
	//�������������������������������������������������������������Ŀ
	//�Monta a lista de Ocorr�ncias x Acoes listadas no indicador 1	�
	//���������������������������������������������������������������	
	cQuery := ""
	cQuery := "SELECT 	UU_CODSU9,	UU_CODSUQ,	UU_CODSUT,	UU_FILIAL		" 
	cQuery += "FROM "+RetSqlName("SUU")+" SUU  WHERE "
	cQuery += "SUU.UU_FILIAL = '" + xFilial("SUU") + "' AND "
	cQuery += "SUU.UU_CODSUT = '" + MV_PAR07 + "' AND "
	cQuery += "SUU.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY SUU.UU_CODSUT "	    
	
	cQuery	:= ChangeQuery(cQuery)
	// MemoWrite("TMKR001.SQL", cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasAux3, .F., .T.)	
	
	While	(cAliasAux3)->(!EOF()) .AND.;     
			(cAliasAux3)->UU_FILIAL == xFilial("SUU") .AND.;
			(cAliasAux3)->UU_CODSUT	== MV_PAR07
		
		If !Empty(cWhereI1)
			cWhereI1 += " OR ("		
		Else	                       
			cWhereI1 += " ("
		EndIf        
																
		If !Empty((cAliasAux3)->UU_CODSU9)
			cWhereI1 += " ADF.ADF_CODSU9 = '" + (cAliasAux3)->UU_CODSU9 + "' "
		EndIf
		If !Empty((cAliasAux3)->UU_CODSU9) .AND. !Empty((cAliasAux3)->UU_CODSUQ)
			cWhereI1 += " AND ADF.ADF_CODSUQ = '" + (cAliasAux3)->UU_CODSUQ + "') "
		ElseIf !Empty((cAliasAux3)->UU_CODSUQ)
			cWhereI1 += " ADF.ADF_CODSUQ = '" + (cAliasAux3)->UU_CODSUQ + "') "
		Else          
			cWhereI1 += ")"	   	
		EndIf	   		   	
		(cAliasAux3)->(DbSkip())
	End         	                                       
	(cAliasAux3)->(DbCloseArea())
	
	If !Empty(cWhereI1)
		cWhereI1 := "(" + cWhereI1 + ")"	
	Else
		cWhereI1 := "(1=1)"	
	EndIf     	
	
	//����������������������������������������������Ŀ
	//�Query da contagem de chamados com o indicador �
	//������������������������������������������������
	cQuery := "" 	                        
	cQuery += "SELECT	ADE_CODIGO, ADF_CODSU0 "
	cQuery += "FROM 	" + RetSqlName("ADE") + " ADE, " + RetSQLName("ADF") + " ADF "		
	cQuery += "WHERE 	ADE_FILIAL	=	'" + xFilial("ADE") + "'	AND "
	cQuery += "			ADF_FILIAL	=	'" + xFilial("ADF") + "'	AND				"
	cQuery += "			ADE_CODIGO	=	ADF_CODIGO		AND "
	cQuery += "			ADE_DATA	BETWEEN '" + DtoS(Mv_Par01) + "' AND '" + DtoS(Mv_Par02) + "' AND "
	
	If Type("Mv_Par09") == "N" .AND. Mv_Par09 == 1
		cQuery += "ADF_CODSU0	IN " + cListSU0 + " AND "
	Else
		cQuery += "ADF_CODSU0	BETWEEN '" + Mv_Par03 + "' AND '" + Mv_Par04 + "' AND								"
	EndIf	
	
	cQuery += "			ADF_CODSU7	BETWEEN '" + Mv_Par05 + "' AND '" + Mv_Par06 + "' AND								"
	cQuery += "			ADE.D_E_L_E_T_ = ' '   					AND "
	cQuery += "			ADF.D_E_L_E_T_ = ' '					AND "
	cQuery += cWhereI1                                
	cQuery += " GROUP BY ADF_CODSU0, ADE.ADE_CODIGO "       
	//cQuery := "SELECT COUNT(*) COUNT FROM (" + cQuery + ") AUX "
	
	cQuery	:= ChangeQuery(cQuery)    	
	// MemoWrite("TMKR001.SQL", cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasAux4, .F., .T.)		
	aChamComI := {}
	While (cAliasAux4)->(!EOF())
		If (nPos:=aScan(aChamComI, { |aChamado| aChamado[1] == (cAliasAux4)->ADF_CODSU0 })) == 0
			aAdd( aChamComI, { (cAliasAux4)->ADF_CODSU0, 1 } )
		Else
			aChamComI[nPos,2]++
		EndIf
		(cAliasAux4)->(DbSkip())
	End	
	(cAliasAux4)->(DbCloseArea())

EndIf

oSection2:SetParentQuery()	
oSection2:SetParentFilter({|cParam| (cAlias)->ADE_GRUPO == cParam},{|| (cAlias)->ADE_GRUPO })		
oSection3:SetParentQuery()	
oSection3:SetParentFilter({|cParam| (cAlias)->ADE_GRUPO + (cAlias)->ADE_OPERAD == cParam},{|| (cAlias)->ADE_GRUPO + (cAlias)->ADE_OPERAD })			

If lSintetico
	oSection2:Hide()
EndIf

//�����������Ŀ
//�Loop geral.�
//�������������
While (cAlias)->(!EOF())  
	
	If oReport:Cancel()
		Exit
	EndIf	
	
	//���������������������������Ŀ
	//�Imprime cabe�alho do grupo.�
	//�����������������������������
	oSection1:Init()
	oSection1:PrintLine()
	oSection1:Finish()
	
	//�������������������Ŀ
	//�Zero os contadores.�
	//���������������������
	cGrupo		:= (cAlias)->ADE_GRUPO
	nTotAP		:= 0
	nTotE		:= 0		
	nChamComI	:= 0
	
	//�������������������������������������Ŀ
	//�Se for sint�tico j� inicia a se��o 3.�
	//���������������������������������������
	If lSintetico
		oSection3:init()
	End
	
	//���������������������������������Ŀ
	//�Loop por grupo e herda condi��es.�
	//�����������������������������������
	While	(cAlias)->(ADE_GRUPO) == cGrupo .And.;
			(cAlias)->(!EOF()) 
			
		//�������������������������������������������������������������������������Ŀ
		//�Se for sint�tico n�o faz o loop por analista, vai direto por comunica��o.�
		//���������������������������������������������������������������������������
		If lSintetico		
			//�������������������������������������������
			//�Inicia as vari�veis que contam de status.�
			//�������������������������������������������
			nNaoEncerrado	:= 0
			nEncerrado		:= 0
			cTipoComu		:= (cAlias)->ADE_TIPO
					
			//���������������������������������������Ŀ
			//�Loop por comunica��o e herda condi��es.�
			//�����������������������������������������
			While	(cAlias)->(ADE_TIPO) == cTipoComu 		.And.;					
					(cAlias)->(ADE_GRUPO) == cGrupo		.And.;
					(cAlias)->(!EOF())
				//�����������������������Ŀ
				//�Faz contagem de status.�
				//�������������������������
				If (cAlias)->ADE_STATUS == "1" .Or. (cAlias)->ADE_STATUS == "2"
					nNaoEncerrado+=(cAlias)->NCOUNT
				ElseIf (cAlias)->ADE_STATUS == "3"
					nEncerrado+=(cAlias)->NCOUNT
				EndIf
				(cAlias)->(DbSkip())
			End 
			
			//�����������������������������������Ŀ
			//�Imprime comunca��o e totalizadores.�
			//�������������������������������������				
			aAdd( aChamados, {	IF(AllTrim(cTipoComu) == "", STR0011, AllTrim(cTipoComu + " - " + POSICIONE('SUL',1,XFILIAL('SUL') + cTipoComu, 'UL_DESC'))),; // "Sem comunica��o"
								nNaoEncerrado,;
								nEncerrado } )									     
			
			//������������������������������Ŀ
			//�Incrementa contadores de �rea.�
			//��������������������������������
			nTotAP	+= nNaoEncerrado
			nTotE	+= nEncerrado				

		Else 
			//������������������������������Ŀ
			//�Imprime cabe�alho do operador.�
			//��������������������������������
			oSection2:Init()
			oSection2:PrintLine()
			oSection2:Finish()
			oSection3:Init()
			
			//�����������������������������Ŀ
			//�Zera contadores por operador.�
			//�������������������������������
			cOperador	:= (cAlias)->ADE_OPERAD
			nFeedbacks	:= 0
		
			//������������������������������������Ŀ
			//�Loop por operador e herda condi��es.�
			//��������������������������������������
			While	(cAlias)->(ADE_OPERAD) == cOperador	.And.;
					(cAlias)->(ADE_GRUPO) == cGrupo		.And.;
					(cAlias)->(!EOF()) 
					
				//�������������������������������������������
				//�Inicia as vari�veis que contam de status.�
				//�������������������������������������������
				nNaoEncerrado	:= 0
				nEncerrado		:= 0
				cTipoComu		:= (cAlias)->ADE_TIPO
				
				//���������������������������������������Ŀ
				//�Loop por comunica��o e herda condi��es.�
				//�����������������������������������������
				While	(cAlias)->(ADE_TIPO) == cTipoComu 		.And.;
						(cAlias)->(ADE_OPERAD) == cOperador	.And.;
						(cAlias)->(ADE_GRUPO) == cGrupo		.And.;
						(cAlias)->(!EOF())
					//�����������������������Ŀ
					//�Faz contagem de status.�
					//�������������������������
					If (cAlias)->ADE_STATUS == "1" .Or. (cAlias)->ADE_STATUS == "2"
						nNaoEncerrado+=(cAlias)->NCOUNT
					ElseIf (cAlias)->ADE_STATUS == "3"
						nEncerrado+=(cAlias)->NCOUNT
					EndIf
					(cAlias)->(DbSkip())
				End      
						
				//�����������������������������������Ŀ
				//�Imprime comunca��o e totalizadores.�
				//�������������������������������������
				aAdd( aChamados, {	IF(AllTrim(cTipoComu) == "", STR0011, AllTrim(cTipoComu + " - " + POSICIONE('SUL',1,XFILIAL('SUL') + cTipoComu, 'UL_DESC'))),; // "Sem comunica��o"
									nNaoEncerrado,;
									nEncerrado } )
				
				//������������������������������Ŀ
				//�Incrementa contadores de �rea.�
				//��������������������������������
				nTotAP	+= nNaoEncerrado
				nTotE	+= nEncerrado
	
			End
			
			//���������������������������������������������������Ŀ
			//�Faz a totaliza��o de todos os tipos de comunica��o.�
			//�����������������������������������������������������
			nTotOAP := 0
			nTotOE	:= 0				
			For nConta := 1 To Len(aChamados)
				nTotOAP += aChamados[nConta, 2]
				nTotOE	+= aChamados[nConta, 3]
			Next
			
			//����������������������
			//�Imprime comunica��o.�
			//����������������������
			For nConta := 1 To Len(aChamados)
				oSection3:Cell("TIPO"):SetValue(aChamados[nConta][1])
				oSection3:Cell("ABERTO_PENDENTE"):SetValue(Alltrim(Str(aChamados[nConta][2])))
				oSection3:Cell("APRELATIVO"):SetValue(Transform( (100 * aChamados[nConta][2]) / nTotOAP  , "@E 999.99%" ) )
				oSection3:Cell("ENCERRADO"):SetValue(Alltrim(Str(aChamados[nConta][3])))
				oSection3:Cell("ERELATIVO"):SetValue(Transform( (100 * aChamados[nConta][3]) / nTotOE , "@E 999.99%" ) )
				oSection3:Cell("SUB_TOTAL"):SetValue(Alltrim(Str(aChamados[nConta][2]+aChamados[nConta][3])))
				oSection3:Cell("STRELATIVO"):SetValue(Transform( (100* (aChamados[nConta][2] + aChamados[nConta][3]) ) / (nTotOAP+nTOtOE) , "@E 999.99%" ) )					
				oSection3:PrintLine()					
			Next				
			aChamados := {}				

			//��������������������������������������Ŀ
			//�Pega o total de feedbacks do operador.�
			//����������������������������������������
			If (nPos := aScan( aFeedbacks, { |aOperador| aOperador[1] == cOperador })) > 0
				nFeedbacks := aFeedbacks[nPos,2]
				aFeedbacks[nPos,3] := "S"
			End
			
			//��������������������������������������Ŀ
			//�Pega o total de feedbacks do operador.�
			//����������������������������������������
			If (nPos := aScan( aDiasUteis, { |aOperador| aOperador[1] == cOperador })) > 0
				nDiasUteis := aDiasUteis[nPos,2]
			End			

			oSection3:Finish()								
	
			//���������������������������������Ŀ
			//�Imprime totalizador por operador.�
			//�����������������������������������
			oReport:PrintText(" ")
			oReport:PrintText(STR0012 + Alltrim(Str(nDiasUteis)))	// "Total de dias �teis do analista: "
			oReport:PrintText(STR0013 + Alltrim(Str(nFeedbacks)) ) // "Total de atendimentos do analista: "
			oReport:PrintText(STR0014 + Alltrim(Str(Round((nFeedbacks)/nDiasUteis,2))))	// "M�dia de atendimentos do analista: "
			oReport:PrintText(STR0023 + TK510TAME(	Nil, 		Mv_Par01, 			Mv_Par02, 	cGrupo,; 
																			cGrupo, 	cOperador, 			cOperador) ) //"Tempo total de atendimento:      "

			oReport:PrintText(STR0024 + TK510TMA(	Nil, 		Mv_Par01, 			Mv_Par02, 	cGrupo,; 
																				cGrupo, 	cOperador, 			cOperador) ) //"Tempo M�dio de Atendimento(TMA): "

		EndIf  
	End  
	
	//��������������������������Ŀ
	//�Soma no totalizador geral.�
	//����������������������������
	nTotAPGeral += nTotAP
	nTotEGeral	+= nTotE		

	//��������������������������������������������������������������Ŀ
	//�Se for sint�tico termina a se��o 3, se n�o imprime o total.   �
	//�Faz essa valida��o porque o total que � exibido quando n�o �  �
	//�sint�tico, j� � exibido naturalmente quando � sint�tico, ent�o�
	//�n�o h� a necessidade de imprimir os totais.                   �
	//����������������������������������������������������������������
	If lSintetico
		//���������������������������������������������������Ŀ
		//�Faz a totaliza��o de todos os tipos de comunica��o.�
		//�����������������������������������������������������
		nTotOAP := 0
		nTotOE	:= 0				
		For nConta := 1 To Len(aChamados)
			nTotOAP += aChamados[nConta, 2]
			nTotOE	+= aChamados[nConta, 3]
		Next
		
		//����������������������
		//�Imprime comunica��o.�
		//����������������������
			For nConta := 1 To Len(aChamados)
			oSection3:Cell("TIPO"):SetValue(aChamados[nConta][1])
			oSection3:Cell("ABERTO_PENDENTE"):SetValue(Alltrim(Str(aChamados[nConta][2])))
			oSection3:Cell("APRELATIVO"):SetValue(Transform( (100 * aChamados[nConta][2]) / nTotOAP  , "@E 999.99%" ) )
			oSection3:Cell("ENCERRADO"):SetValue(Alltrim(Str(aChamados[nConta][3])))
			oSection3:Cell("ERELATIVO"):SetValue(Transform( (100 * aChamados[nConta][3]) / nTotOE , "@E 999.99%" ) )
			oSection3:Cell("SUB_TOTAL"):SetValue(Alltrim(Str(aChamados[nConta][2]+aChamados[nConta][3])))
			oSection3:Cell("STRELATIVO"):SetValue(Transform( (100* (aChamados[nConta][2] + aChamados[nConta][3]) ) / (nTotOAP+nTOtOE) , "@E 999.99%" ) )					
			oSection3:PrintLine()					
		Next				
		aChamados := {}				
	
		//��������������������������������������Ŀ
		//�Pega o total de feedbacks do operador.�
		//����������������������������������������
		If (nPos := aScan( aChamComI, { |aGrupo| aGrupo[1] == cGrupo })) > 0
			nChamComI := aChamComI[nPos,2]
		End			
	
		oSection3:Finish()			
		oReport:PrintText(" ")
		oReport:PrintText(STR0019 + " '" + Alltrim(Posicione("SUT", 1, xFilial("SUT") + MV_PAR07, "UT_NOME")) + "': "+ Transform( (100 * nChamComI) / (nTotAP+nTotE), "@E 999.99%" )  )
	Else
		oReport:PrintText(" ")
		oReport:PrintText(STR0015 + Alltrim(Str(nTotAP)))	// "Total de chamados da �rea em aberto/pendente: "
		oReport:PrintText(STR0016 + Alltrim(Str(nTotE)))	// "Total de chamados da �rea encerrados: "
	EndIf 
	
	oReport:IncMeter()
	
	oReport:PrintText(" ")
	oReport:PrintText(STR0017 + Alltrim(Str(nTotAPGeral)))	// "Total de chamados em aberto/pendente: "
	oReport:PrintText(STR0018 + Alltrim(Str(nTotEGeral)))	// "Total de chamados encerrados: "		
	
End                   
//
//�������������������������������������������������������Ŀ
//�Verifica se h� Atendimento Avulsos a serem impressos  �
//���������������������������������������������������������  		  	
For Ix:=1 to len(aFeedbacks)
	
	IF aFeedbacks[Ix,3] == "N"
	
			If oReport:Cancel()
			Exit
			EndIf	          		
	
			//�������������������Ŀ
			//�Zero os contadores.�
			//���������������������
			nTotAP		:= 0
			nTotE		:= 0				
		
			If lSintetico
			oSection4:init()
			End

			aChamados := {}				

			//��������������������������������������Ŀ
			//�Pega o total de feedbacks do operador.�
			//����������������������������������������
			If (nPos := aScan( aFeedbacks, { |aOperador| aOperador[1] == aFeedbacks[Ix,1] })) > 0 .and. aFeedbacks[Ix,3] == "N"
				nFeedbacks := aFeedbacks[nPos,2]
			End				
			
			If (nPos := aScan( aDiasUteis, { |aOperador| aOperador[1] == aFeedbacks[Ix,1] })) > 0 .and. aFeedbacks[Ix,3] == "N"
			nDiasUteis := aDiasUteis[nPos,2]
			End			

			oSection4:Finish()								
	
			//���������������������������������Ŀ
			//�Imprime totalizador por operador.�
			//�����������������������������������
			if !lSintetico
			oReport:PrintText(" ")                      
			oReport:PrintText("ATENDIMENTOS AVULSOS ")     
			oReport:PrintText(" ")     
			oReport:PrintText("ANALISTA  : "+aFeedbacks[Ix,1] + " - " + FATPDObfuscate(POSICIONE('SU7',1,XFILIAL('SU7') + aFeedbacks[Ix,1], 'U7_NOME'),"U7_NOME",,.T.))     	           
			oSection4:PrintLine()
			oReport:PrintText(" ")   
			oReport:PrintText(STR0012 + Alltrim(Str(nDiasUteis)))   	// "Total de dias �teis do analista: "
			oReport:PrintText(STR0013 + Alltrim(Str(nFeedbacks)) )    // "Total de atendimentos do analista: "
			oReport:PrintText(STR0014 + Alltrim(Str(Round((nFeedbacks)/nDiasUteis,2))))	// "M�dia de atendimentos do analista: "
			oReport:PrintText(STR0023 + TK510TAME(	Nil, 		Mv_Par01, 			Mv_Par02, 	cGrupo,; 
																			cGrupo, 	cOperador, 			cOperador) ) //"Tempo total de atendimento:      "
			oReport:PrintText(STR0024 + TK510TMA(	Nil, 		Mv_Par01, 			Mv_Par02, 	cGrupo,; 
																				cGrupo, 	cOperador, 			cOperador) ) //"Tempo M�dio de Atendimento(TMA): "		
			Endif																		
			//��������������������������Ŀ
			//�Soma no totalizador geral.�
			//����������������������������
			nTotAPGeral += nTotAP
			nTotEGeral	+= nTotE		
			
			//���������������������������������������������������Ŀ
			//�Faz a totaliza��o de todos os tipos de comunica��o.�
			//�����������������������������������������������������
			nTotOAP := 0
			nTotOE	:= 0				
			For nConta := 1 To Len(aChamados)
			nTotOAP += aChamados[nConta, 2]
			nTotOE	+= aChamados[nConta, 3]
			Next					
			//��������������������������������������Ŀ
			//�Pega o total de feedbacks do operador.�
			//����������������������������������������
			If (nPos := aScan( aChamComI, { |aGrupo| aGrupo[1] == cGrupo })) > 0
			nChamComI := aChamComI[nPos,2]
			End			
	
			oSection3:Finish()			
			oReport:PrintText(" ")
			oReport:IncMeter()
	Endif

Next		

Return(.T.)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive
