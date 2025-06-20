#INCLUDE "TMKR506.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR506  � Autor � Vendas CRM            � Data � 20/07/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio Impressao de chamados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMKR506(void)                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR506(cCodChama)
Local oReport	//Objeto relatorio TReport (Release 4)
Local lClose	:= .T.	

Default cCodChama := "" 

	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                           �
	//����������������������������������������������������������������
	If Empty(cCodChama)
		Pergunte("TMKR506",.F.)
	EndIf
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                         �
	//� Mv_Par01           // De                                     �
	//� Mv_Par02           // Ate                                    �
	//� Mv_Par03           // Do Produto    		                 �
	//� Mv_Par04           // At� o Produto                          �
	//� Mv_Par05           // Do Grupo                               �
	//� Mv_Par06           // Ate o Grupo                            �
	//� Mv_Par07           // Do Analista                            �
	//� Mv_Par08           // Ate o Analista                         �
	//� Mv_Par09           // Tipo de Data		                     �
	//� MV_PAR10		   // Do Cliente     						 |
	//� MV_PAR11		   // Da Loja	     						 |
	//� MV_PAR12		   // Ate o Cliente   						 |
	//� MV_PAR13		   // Ate a Loja     						 |
	//� MV_PAR14		   // Status	     						 |
	//� MV_PAR15		   // Do Chamado 	  						 |
	//� MV_PAR16		   // Ate o Chamado	  						 |
	//����������������������������������������������������������������
	
	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������

If !TMKOPERADOR()
	If !IsBlind()
		Help("  ",1,"OPERADOR")   
		lClose	:= .F.
	Endif 
Endif	

If lClose	
	oReport := ReportDef(cCodChama)
	oReport:PrintDialog() 
Endif            

Return(.T.)
                     
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TKR501RptDef � Autor �Vendas CRM          � Data �20/07/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina que define os itens que serao apresentados no relato-���
���          �rio.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tkr501RptDef()                                             ���
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
Static Function ReportDef(cCodChama)
Local oReport 				//Objeto relatorio TReport (Release 4)
Local oSection1             //Objeto secao 1 do relatorio (Cabecalho, campos das tabelas SU2 e SB1)
Local oSection2             //Objeto secao 2 do relatorio (Itens, campos da tabela SU2)
Local oSection3             //Objeto secao 2 do relatorio (Analitico)
Local cAlias1 := "ADE"     //Alias da consulta Embedded SQL
Local oBreak 
Local oObj	   
Local nI 		:= 0  
Local bBlock	:= {||} 
Local cSQLCampos:= ""
    
oObj := TeleServicing():New() 
oObj:load( GetModel() )   

cAlias1	:= "ADE"+GetNextAlias()						// Pega o proximo Alias Disponivel

// "Impress�o de Chamado" # // "Este programa ira emitir uma relacao de chamados" #
DEFINE REPORT oReport NAME "TMKR506" TITLE STR0001 PARAMETER "TMKR506" ACTION {|oReport| Tkr506PrtRpt( oReport, cAlias1, cCodChama, cSQLCampos )} DESCRIPTION STR0002
oReport:SetLandscape()      
If !Empty(cCodChama)
	oReport:SetParam(NIL)
EndIf

//�����������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal �
//�������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport 	TITLE STR0003 	TABLES oObj:tableStructureInfo:master:alias PAGE BREAK COLUMNS 3  // "Cabe�alho"
DEFINE SECTION oSection2 OF oSection1 	TITLE STR0004	TABLES oObj:tableStructureInfo:detail:alias // "Itens"


//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������  
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(oObj:tableStructureInfo:master:alias)
While 	SX3->(!Eof()) 														.AND.;
		SX3->X3_ARQUIVO == oObj:tableStructureInfo:master:alias

		If !( AllTrim(SX3->X3_CAMPO) == "ADE_CODIGO" )
			If SX3->X3_CONTEXT == "R" 
				If Empty(cSQLCampos)
					cSQLCampos += "ADE." + AllTrim(SX3->X3_CAMPO)
				Else
					cSQLCampos += ",ADE." + AllTrim(SX3->X3_CAMPO)
				EndIf
			EndIf
		
			If 	SX3->X3_NIVEL 	<= cNivel	.AND.;
				X3USO(SX3->X3_USADO)
	
				//���������������������������������������������Ŀ
				//�Carrega as informacoes de campos virtuais    �
				//�����������������������������������������������
				bBlock := NIL
				If AllTrim(SX3->X3_CAMPO) == "ADE_NMPROD"
					bBlock := {||POSICIONE('SB1',1,XFILIAL('SB1')+ADE->ADE_CODSB1, 'B1_DESC')}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_DESCAS"
					bBlock := {||POSICIONE('SX5',1,xFilial('SX5')+'T1'+ADE->ADE_ASSUNT,'X5DESCRI()')}			
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_NMTEC"			
					bBlock := {||POSICIONE('AA1',1,XFILIAL('AA1')+ADE->ADE_TECNIC, 'AA1_NOMTEC')}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_NMCONT"			
					bBlock := {||POSICIONE('SU5',1,XFILIAL('SU5')+ ADE-> ADE_CODCONT, 'U5_CONTAT')}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_NMOPER"			
					bBlock := {||POSICIONE('SU7',1,XFILIAL('SU7')+ADE-> ADE_OPERAD, 'U7_NOME')}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_NMMIDI"			
					bBlock := {||POSICIONE('SUH',1,XFILIAL('SUH')+ADE->ADE_MIDIA, 'UH_DESC')}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_NMENT"			
					bBlock := {||POSICIONE('SX2',1,ADE-> ADE_ENTIDAD,'X2NOME()')}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_DESCCH"			
					bBlock := {||TKENTIDADE(ADE->ADE_ENTIDA,ADE->ADE_CHAVE,1)}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_DESCGP"			
					bBlock := {||POSICIONE('SU0',1,xFilial('SU0')+ADE->ADE_GRUPO,'U0_NOME')}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_INCIDE"			
					bBlock := {||MSMM (ADE->ADE_CODINC,TamSx3("ADE_INCIDE")[1])}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_DSCCAM"			
					bBlock := {||POSICIONE('SUO',1,XFILIAL('SUO') + ADE->ADE_CODCAM, 'UO_DESC')}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_NORIGE"			
					bBlock := {||FQNCNTAB('3',ADE->ADE_CODORI)}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_NEFEIT"			
					bBlock := {||FQNCNTAB('2',ADE->ADE_CODEFE)}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_NCATEG"			
					bBlock := {||FQNCNTAB('4',ADE->ADE_CODCAT)}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_NCAUSA"			
					bBlock := {||FQNCNTAB('1',ADE->ADE_CODCAU)}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_NMTIPO"			
					bBlock := {||POSICIONE('SUL',1,XFILIAL('SUL')+ADE->ADE_TIPO, 'UL_DESC')}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_DESREP" 
					bBlock := {||Posicione("SU5",1,xFilial("SU5")+ADE->ADE_CODREP,"U5_CONTAT")}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_DCHREP"
					bBlock := {||TkEntidade(ADE->ADE_ENTREP,ADE->ADE_CHVREP,1)}
				ElseIf AllTrim(SX3->X3_CAMPO) == "ADE_DESENT"
					bBlock := {||POSICIONE('SX2',1,ADE->ADE_ENTREP,'X2NOME()')}
				EndIf		
	
				TRCell():New(	oSection1,;
				 				AllTrim(SX3->X3_CAMPO),; 
				 				"ADE",;
				 				,;
				 				,;
				 				,;
				 				,;
				 				bBlock)			
			EndIf
		EndIf
		SX3->(DbSkip())		
End
      
//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(oObj:tableStructureInfo:detail:alias)
While 	SX3->(!Eof()) 														.AND.;
		SX3->X3_ARQUIVO == oObj:tableStructureInfo:detail:alias 	
		
		If SX3->X3_CONTEXT == "R" 
			If Empty(cSQLCampos)
				cSQLCampos += "ADF." + AllTrim(SX3->X3_CAMPO)
			Else
				cSQLCampos += ",ADF." + AllTrim(SX3->X3_CAMPO)
			EndIf
		EndIf

		If 	SX3->X3_NIVEL 	<= cNivel	.AND.;
			X3USO(SX3->X3_USADO)  
			
			//���������������������������������������������Ŀ
			//�Carrega as informacoes de campos virtuais    �
			//�����������������������������������������������
			bBlock := NIL
			If AllTrim(SX3->X3_CAMPO) == "ADF_NMSU9"
				bBlock := {||POSICIONE('SU9', 2, xFilial('SU9')+(cAlias1)->ADF_CODSU9,'U9_DESC')}
			ElseIf AllTrim(SX3->X3_CAMPO) == "ADF_NMSUQ" 			
				bBlock := {||POSICIONE('SUQ', 1, xFilial('SUQ')+(cAlias1)->ADF_CODSUQ,'UQ_DESC')}
			ElseIf AllTrim(SX3->X3_CAMPO) == "ADF_NMSU7" 			
				bBlock := {||POSICIONE('SU7',1,XFILIAL('SU7') + (cAlias1)->ADF_CODSU7, 'U7_NOME')}
			ElseIf AllTrim(SX3->X3_CAMPO) == "ADF_NMGRUP" 			
				bBlock := {||POSICIONE('SU0',1,XFILIAL('SU0')+(cAlias1)->ADF_CODSU0, 'U0_NOME')}
			ElseIf AllTrim(SX3->X3_CAMPO) == "ADF_OBS" 			
				bBlock := {||MSMM((cAlias1)->ADF_CODOBS,TamSx3("ADF_OBS")[1])}
			EndIf			
                      
			TRCell():New(	oSection2,;
			 				AllTrim(SX3->X3_CAMPO),; 
			 				"ADF",;
			 				,;
			 				,;
			 				,;
			 				,;
			 				bBlock)				 				   

		EndIf
		SX3->(DbSkip())		
End

oSection1:SetLineStyle()
oSection1:PageBreak()

Return(oReport)  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tkr501PrtRpt � Autor �Vendas CRM          � Data �20/07/2008���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tkr501PrtRept(ExpO1,ExpC2)                                 ���
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
Static Function Tkr506PrtRpt(oReport, cAlias1, cCodChama, cSQLCampos)
Local oSection1 := oReport:Section(1)		//Objeto secao 1 do relatorio (Cabecalho, campos das tabelas SU2 e SB1)
Local oSection2 := oSection1:Section(1)	//Objeto secao 2 do relatorio (Itens, campos da tabela SU2)
Local cWhere	:= ""						//Condicoes utilizadas na listagem do indicador
Local cQuery	:= ""

//���������������������������������������������������������������������������������Ŀ
//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
//�����������������������������������������������������������������������������������
BEGIN REPORT QUERY oSection1
MakeSqlExpr("TMKR506")  
If !Empty(cSQLCampos)
	cSQLCampos := "% ," + cSQLCampos + " %"   
Else
	cSQLCampos := "%%"
EndIf         

If Empty(cCodChama)          
	If MV_PAR14 = 1
		cWhere := " ADE_STATUS = '1' AND "		
	ElseIf MV_PAR14 = 2                   
		cWhere := " ADE_STATUS = '2' AND "			
	ElseIf MV_PAR14 = 3                        
		cWhere := " ADE_STATUS = '3' AND "			
	EndIf                                                                   

	If MV_PAR09 == 1
		cWhere += " ADE_DATA " 	
	Else
		cWhere += " ADE_DTEXPI " 	
	EndIf	
	cWhere += " BETWEEN '" + DtoS(Mv_Par01) + "' AND '" + DtoS(Mv_Par02) + "' AND "

	If !Empty(MV_PAR10) .OR. (!Empty(MV_PAR12) .AND. MV_PAR12 <> "ZZZZZZ")
		cWhere += "ADE_CHAVE BETWEEN '" + MV_PAR10+MV_PAR11 + "' AND '" + MV_PAR12+MV_PAR13 + "' AND "
		cWhere += "ADE_ENTIDA 	= 'SA1' AND "                    	     			
	EndIf	                                                
	cWhereSQL := cWhere
	cWhere	:= "%" + cWhere + "%"
		
	BeginSQL alias cAlias1
		SELECT ADE_CODIGO %exp:cSQLCampos%
		FROM %table:ADE% ADE, %table:ADF% ADF
		WHERE ADE.ADE_FILIAL = %xFilial:ADE% AND
			ADF.ADF_FILIAL = %xFilial:ADF% AND
			ADE.%notDel%   					AND
			ADF.%notDel%   					AND
			ADE.ADE_CODIGO = ADF.ADF_CODIGO AND
			%exp:cWhere%
			ADE_CODSB1	BETWEEN %exp:Mv_Par03% AND %exp:Mv_Par04% AND
			ADE_GRUPO	BETWEEN %exp:Mv_Par05% AND %exp:Mv_Par06% AND
			ADE_OPERAD	BETWEEN %exp:Mv_Par07% AND %exp:Mv_Par08% AND
			ADE_CODIGO  BETWEEN %exp:Mv_Par15% AND %exp:Mv_Par16%   
		ORDER BY ADE_CODIGO, ADF_ITEM

	EndSql    		
Else
	BeginSQL alias cAlias1
		SELECT ADE.ADE_CODIGO %exp:cSQLCampos%
		FROM %table:ADE% ADE, %table:ADF% ADF 
		WHERE ADE.ADE_FILIAL = %xFilial:ADE% AND 			
			ADF.ADF_FILIAL = %xFilial:ADF% AND
			ADE.%notDel%   					AND			
			ADF.%notDel%   					AND							
			ADE.ADE_CODIGO = ADF.ADF_CODIGO AND				
			ADE_CODIGO	= %exp:cCodChama% 									
		ORDER BY ADE_CODIGO, ADF_ITEM
	EndSql    	
EndIf         
END REPORT QUERY oSection1 

oSection2:SetParentQuery() 
oSection2:SetParentFilter({|cParam|(cAlias1)->ADE_CODIGO == cParam},{|| (cAlias1)->ADE_CODIGO})

TRPosition():New(oSection1,"ADE",1,{|| xFilial("ADE") + (cAlias1)->ADE_CODIGO } )
TRPosition():New(oSection1,"ADF",1,{|| xFilial("ADF") + (cAlias1)->ADE_CODIGO } )

//�������������������������������������������Ŀ
//�Quebra a linha, caso existam muitas colunas�
//���������������������������������������������
oSection1:SetLineBreak()
oSection2:SetLineBreak()

//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()

Return(.T.)
   	                       
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GetModel     � Autor �Vendas CRM          � Data �20/07/2008���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Seleciona o Modelo de Atendimento do usu�rio                ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GetModel()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetModel()
Local cModelo := ""		//Cod. do modelo de atendimento

//�����������������������������������������������������������������Ŀ
//� Se o USUARIO nao estiver cadastrado em OPERADORES e nao tiver	�
//� um Posto de Venda associado nao entra na rotina					�
//�������������������������������������������������������������������
If !TMKOPERADOR()
	If !IsBlind()
		Help("  ",1,"OPERADOR")   
	Else
		cModelo := SU0->U0_CODSKA	
	EndIf
Else
	//���������������������������������������Ŀ
	//� Pega o modelo no grupo de atendimento �
	//�����������������������������������������
	cModelo := SU0->U0_CODSKA
EndIf
Return cModelo
