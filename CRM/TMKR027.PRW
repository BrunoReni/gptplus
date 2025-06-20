#INCLUDE "TMKR027.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR027  � Autor � Rafael M. Quadrotti   � Data � 30/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Campanhas - Gerencia de Campanhas             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Call Center - Relatorios 			                      ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Michel W. �21/08/06�99197 �Atualizacao relatorios release 4.           ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 

Function TMKR027()

Local oReport	//Objeto relatorio TReport (Release 4)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TMK027",.F.)
//�������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                 			  �
//� mv_par01            // Da Campanha                                �
//� mv_par02            // Ate a Campanha                             �
//� mv_par03            // Do Script                                  �
//� mv_par04            // Ate o Script                               �
//� mv_par05            // Tipo de Atendimento                        �
//� mv_par06            // Publico Alvo                               �
//� mv_par07            // Atendimento                                �
//���������������������������������������������������������������������
		
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
���Fun��o    �TK027VALSC   �Autor�Rafael M. Quadrotti   � Data � 30/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao dos parametros de SCRIPTS                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Call Center - Gerencia de Campanhas                        ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function TK027VALSC(cCodCamp)
Local lRet  := .T.
Local cAlias:= Alias()

DbSelectArea("SUW")
DbSetOrder(1)
IF MsSeek(xFilial("SUW") + cCodCamp)
	While 	(!Eof()) 							.And.; 
			(xFilial("SUZ") == SUZ->UZ_FILIAL) .And.;
			(SUW->UW_CODCAMP = cCodCamp) 
		       
		If (SUW->UW_CODSCRI < Mv_Par03) .And. (SUW->UW_CODSCRI > Mv_Par04)
			lRet:= .F.
			Exit
		EndIf
		
		DbSkip()
	End
Endif
DbSelectArea(cAlias)

Return(lRet)     


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef    � Autor �Michel W. Mosca     � Data �28/08/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina que define os itens que serao apresentados no relato-���
���          �rio de Emissao de Campanhas no release 4.                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CALL CENTER                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/              
Static Function ReportDef()
Local oReport 				//Objeto relatorio TReport (Release 4)
Local oSection3             //Lista de Campanhas que participam da meta
Local oSection4             //Lista de Scripts que participam da meta
Local oSection5             //Lista de Scripts que participam da meta
Local oSection6             //Lista de Produtos que participam da meta
Local oSection7             //Lista de Produtos que participam da meta
Local oSection8				//Lista de eventos que participam da meta
Local oSection9				//Lista de grades do evento que participam da meta
Local cAC6 := "AC6"     	//Alias da consulta Embedded SQL
Local cAC7 := "AC7"     	//Alias da consulta Embedded SQL
Local cSUO := "SUO"      	//Alias da consulta Embedded SQL
Local cSUZ := "SUZ"     	//Alias da consulta Embedded SQL
Local cACD := "ACD"     	//Alias da consulta Embedded SQL
Local cSB1 := "SB1"     	//Alias da consulta Embedded SQL
Local cSUH := "SUH"     	//Alias da consulta Embedded SQL
Local cSUW := "SUW"     	//Alias da consulta Embedded SQL
Local cACE := "ACE"     	//Alias da consulta Embedded SQL
                                                                    
cAC6	:= GetNextAlias()						// Pega o proximo Alias Disponivel	
cSUO	:= cAC6	
cAC7	:= cAC6
cSUW	:= GetNextAlias()						// Pega o proximo Alias Disponivel		 
cSUZ	:= GetNextAlias()						// Pega o proximo Alias Disponivel		 
cSUH	:= GetNextAlias()						// Pega o proximo Alias Disponivel		 
cSB1	:= GetNextAlias()						// Pega o proximo Alias Disponivel		 
cACD	:= GetNextAlias()						// Pega o proximo Alias Disponivel		 
cACE	:= GetNextAlias()						// Pega o proximo Alias Disponivel		 		               

// "Emiss�o de Campanhas. " # // "Este programa ira emitir uma relacao das Campanhas " # // "de Marketing."
DEFINE REPORT oReport NAME "TMKR027" TITLE STR0001 PARAMETER "TMK027" ACTION {|oReport| Tkr027PrtRpt( oReport, cAC6, cSUO, cAC7, cSUZ, cACD, cSB1, cSUH, cSUW, cACE )} DESCRIPTION STR0002 + 	STR0003

//�����������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal �
//�������������������������������������������������������������������
DEFINE SECTION oSection3 OF oReport TITLE STR0095 TABLES "SUO"   		//"Campanhas"
DEFINE SECTION oSection4 OF oSection3 TITLE STR0096 TABLES "SUW"   		//"Script Dinamico x Campanha"
DEFINE SECTION oSection5 OF oSection4 TITLE STR0097 TABLES "SUZ"   		//"Script Dinamico"
DEFINE SECTION oSection6 OF oSection4 TITLE STR0098 TABLES "SUZ"   		//"Midia relacionada aos itens da campanha"
DEFINE SECTION oSection7 OF oSection4 TITLE STR0099 TABLES "SB1"   		//"Produtos"
DEFINE SECTION oSection8 OF oSection4 TITLE STR0100 TABLES "ACD"   		//"Eventos"
DEFINE SECTION oSection9 OF oSection8 TITLE STR0101 TABLES "ACE"       	//"Grade de Eventos"

DEFINE CELL NAME "UO_CODCAMP" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_DESC" 		OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_OBJETIV" 	OF oSection3 Alias "SUO" 												
DEFINE CELL NAME "UO_DTINI" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_DTFIM" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "" 			OF oSection3 Alias "SUO" BLOCK{||(cSUO)->UO_TIPO + " - " + Iif((cSUO)->UO_TIPO == "2",STR0085,STR0086)} TITLE STR0012  //"Tipo              : "###"Ativo"###"Receptivo"										
DEFINE CELL NAME "" 			OF oSection3 Alias "SUO" BLOCK{||IF((cSUO)->UO_ATENDIM == "1",(cSUO)->UO_ATENDIM  + " - " + STR0031,IF((cSUO)->UO_ATENDIM == "2",(cSUO)->UO_ATENDIM  + " - " + STR0032,IF((cSUO)->UO_ATENDIM == "3",(cSUO)->UO_ATENDIM  + " - " + STR0033,IF((cSUO)->UO_ATENDIM == "4",(cSUO)->UO_ATENDIM  + " - " + STR0034,""))))} TITLE STR0013										
DEFINE CELL NAME "UO_PUBALVO" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "" 			OF oSection3 Alias "SUO" BLOCK{||Posicione("SX5",1,xFilial("SX5") + "T6" + (cSUO)->UO_PUBALVO,"X5DESCRI()")} TITLE STR0015	//"Descri��o         : "									
DEFINE CELL NAME "UO_RESP" 		OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_COORDEN" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_DEPTO" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_META" 		OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_METAOP" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_CUSTO" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_PREVEND" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_RETORNO" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_PRELEAD" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_TOTSUC" 	OF oSection3 Alias "SUO"										
DEFINE CELL NAME "UO_TOTFRA" 	OF oSection3 Alias "SUO"										

//�����������������Ŀ
//�Se existir Script�
//�������������������
DEFINE CELL NAME "UW_CODSCRI" 	OF oSection4 Alias "SUW" 									
										
DEFINE CELL NAME "UZ_CODSCRI" 	OF oSection5 Alias "SUZ"										
DEFINE CELL NAME "UZ_DESC" 		OF oSection5 Alias "SUZ"	//"T�tulo            : "											
DEFINE CELL NAME "UZ_TEMPO" 	OF oSection5 Alias "SUZ"											
DEFINE CELL NAME "" 			OF oSection5 Alias "SUZ" BLOCK{||IF((cSUZ)->UZ_TIPO == "1",STR0031,IF((cSUZ)->UZ_TIPO == "2",STR0032,IF((cSUZ)->UZ_TIPO == "3",STR0033,IF((cSUZ)->UZ_TIPO == "4",STR0034,""))))} TITLE STR0030 SIZE 10											
DEFINE CELL NAME "" 			OF oSection5 Alias "SUZ" BLOCK{||IF((cSUZ)->UZ_TIPO == "1",STR0036,STR0037)} TITLE STR0035 SIZE 10											
DEFINE CELL NAME "" 			OF oSection5 Alias "SUZ" BLOCK{||IF((cSUZ)->UZ_ARMRESP == "1",STR0039,STR0040)} TITLE STR0038 SIZE 10											
DEFINE CELL NAME "UZ_SCORMIN" 	OF oSection5 Alias "SUZ"											
DEFINE CELL NAME "" 			OF oSection5 Alias "SUZ" BLOCK{||(cSUZ)->UZ_PROCMIN + " - " + SubStr(Posicione("SX5",1,xFilial("SX5") + "E3" + (cSUZ)->UZ_PROCMIN,"X5DESCRI()"),1,40)} TITLE STR0042 SIZE 40											
DEFINE CELL NAME "" 			OF oSection5 Alias "SUZ" BLOCK{||Transform( (cSUZ)->UZ_SCORMAX  ,PesqPict("SUZ","UZ_SCORMAX"))} TITLE STR0051	 SIZE 10										
DEFINE CELL NAME "" 			OF oSection5 Alias "SUZ" BLOCK{||(cSUZ)->UZ_PROCMAX + " - " + SubStr(Posicione("SX5",1,xFilial("SX5") + "E3" + (cSUZ)->UZ_PROCMAX,"X5DESCRI()"),1,40)} TITLE STR0044 SIZE 40											

//�������������������������������������������������������
//�Impressao da Midia relacionada aos itens da campanha.�
//�������������������������������������������������������
DEFINE CELL NAME "UH_MIDIA"		OF oSection6 Alias "SUH"
DEFINE CELL NAME "UH_DESC" 		OF oSection6 Alias "SUH"
DEFINE CELL NAME ""				OF oSection6 Alias "SUH" BLOCK{||Posicione("SX5",1,xFilial("SX5")+"T4"+(cSUH)->UH_TIPO ,"X5_DESCRI")} TITLE STR0012 SIZE 40  //"Tipo              : "										
DEFINE CELL NAME ""				OF oSection6 Alias "SUH" BLOCK{||IF((cSUH)->UH_BOUND == "1",STR0047,IF((cSUH)->UH_BOUND == "2",STR0048,STR0049))} TITLE STR0046 SIZE 20 //"Liga��o           :										

DEFINE CELL NAME "B1_COD" 		OF oSection7 Alias "SB1"										
DEFINE CELL NAME "B1_DESC" 		OF oSection7 Alias "SB1"										
DEFINE CELL NAME "" 			OF oSection7 Alias "SB1" BLOCK{||Posicione("SX5",1,xFilial("SX5")+"02"+(cSB1)->B1_TIPO ,"X5_DESCRI")} TITLE STR0012 SIZE 20		//"Tipo              : "								
DEFINE CELL NAME "B1_UM" 		OF oSection7 Alias "SB1"										

DEFINE CELL NAME "ACD_CODIGO" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_DESC" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_TEMA" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "" 			OF oSection8 Alias "ACD" BLOCK{||IF((cACD)->ACD_TIPEXP == "1",STR0056,IF((cACD)->ACD_TIPEXP == "2",STR0057,IF((cACD)->ACD_TIPEXP == "3",STR0058,IF((cACD)->ACD_TIPEXP == "4",STR0059,IF((cACD)->ACD_TIPEXP == "5",STR0060,IF((cACD)->ACD_TIPEXP == "6",STR0061,""))))))} TITLE STR0055 SIZE 50	//"Exposi��o         :				
DEFINE CELL NAME "" 			OF oSection8 Alias "ACD" BLOCK{||If((cACD)->ACD_GRATUI = "1",STR0039,STR0040)} TITLE STR0062 SIZE 5  //"Gratuito 					
DEFINE CELL NAME "ACD_PRECO" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_LOCAL" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_END" 		OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_MUN" 		OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_EST" 		OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_PAIS" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_TEL" 		OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_HPAGE" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_EMAIL" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_DTINI" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_DTFIM" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_HRINI" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "ACD_HRFIM" 	OF oSection8 Alias "ACD"					
DEFINE CELL NAME "" 			OF oSection8 Alias "ACD" BLOCK{||IF((cACD)->ACD_ESTAC == "1",STR0077,IF((cACD)->ACD_TIPEXP == "2",STR0078,IF((cACD)->ACD_TIPEXP == "3",STR0079,IF((cACD)->ACD_TIPEXP == "4",STR0080,IF((cACD)->ACD_TIPEXP == "5",STR0081,IF((cACD)->ACD_TIPEXP == "6",STR0082,""))))))} TITLE STR0076 SIZE 30	//"Estacionamento    :					
DEFINE CELL NAME "ACD_ENDEST" 	OF oSection8 Alias "ACD"					
											
DEFINE CELL NAME "ACE_GRADE" 	OF oSection9 Alias "ACE"		
DEFINE CELL NAME "ACE_TEMA" 	OF oSection9 Alias "ACE"		
DEFINE CELL NAME "ACE_HRINI" 	OF oSection9 Alias "ACE"		
DEFINE CELL NAME "ACE_HRFIM" 	OF oSection9 Alias "ACE"		
DEFINE CELL NAME "ACE_DATA" 	OF oSection9 Alias "ACE"		
DEFINE CELL NAME "ACE_SALA" 	OF oSection9 Alias "ACE"		
DEFINE CELL NAME "ACE_PALEST" 	OF oSection9 Alias "ACE"		
DEFINE CELL NAME "ACE_EMP" 		OF oSection9 Alias "ACE"		
		

Return(oReport)
                  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tkr027PrtRpt � Autor �Michel W. Mosca     � Data �28/08/2006���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio de Emissao de���
���          �campanhas no release 4. 			                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tkr027PrtRept(ExpO1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7    ���
���          �               ,ExpC8,ExpC9,ExpC10)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = objeto relatorio                                   ���
���          � ExpC2 = alias da query atual                               ���
���          � ExpC3 = alias da query atual                               ���
���          � ExpC4 = alias da query atual                               ���
���          � ExpC5 = alias da query atual                               ���
���          � ExpC6 = alias da query atual                               ���
���          � ExpC7 = alias da query atual                               ���
���          � ExpC8 = alias da query atual                               ���
���          � ExpC9 = alias da query atual                               ���
���          � ExpC10 = alias da query atual                              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tkr027PrtRpt(	oReport, 	cAC6, 		cSUO, 		cAC7,; 
								cSUZ, 		cACD, 		cSB1, 		cSUH,; 
								cSUW, 		cACE)
																
Local oSection3 := oReport:Section(1)  		//Lista de Campanhas que participam da meta
Local oSection4 := oSection3:Section(1) 	//Lista de Scripts que participam da meta
Local oSection5 := oSection4:Section(1) 	//Lista de Scripts que participam da meta
Local oSection6 := oSection4:Section(2) 	//Lista de Produtos que participam da meta
Local oSection7 := oSection4:Section(3) 	//Lista de Produtos que participam da meta
Local oSection8 := oSection4:Section(4)		//Lista de eventos que participam da meta
Local oSection9 := oSection8:Section(1)		//Lista de grades do evento que participam da meta
Local cFiltro	:= ""      					//String contendo o filtro de busca a ser utilizado com DBF
Local cWhere	:= ""						//String contendo condicoes da clausula Where para pesquisa em TOP   
    
	//���������������������������������������������������������������������������������Ŀ
	//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
	//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
	//�����������������������������������������������������������������������������������
	MakeSqlExpr("TMK027")      


	//���������������������������������������������������������Ŀ
	//�Caso nao sejam definidas as campanhas a data passa a ser �
	//�a regra de validacao.                                    �
	//�����������������������������������������������������������
	cWhere := "% "
	If !Empty(mv_par05)			
		cWhere +=	" '"+ STR(MV_PAR05,1) + "' IN('3',SUO.UO_TIPO) AND " 
	EndIf
	If !Empty(mv_par06)			
		cWhere +=	" SUO.UO_PUBALVO = '"+ (Mv_Par06) + "' AND " 
	EndIf				
	cWhere +=	" '"+ STR(MV_PAR07,1) + "' IN('4',SUO.UO_ATENDIM) AND "
	cWhere += " %"

	BEGIN REPORT QUERY oSection3 
	 	BeginSQL alias cSUO
	           SELECT 	UO_CODCAMP, UO_DESC, 	UO_OBJETIV, 	UO_DTINI, 
						UO_DTFIM, 	UO_TIPO, 	UO_ATENDIM, 	UO_PUBALVO, 	
						UO_RESP, 	UO_COORDEN, UO_DEPTO, 		UO_META,  
						UO_METAOP, 	UO_CUSTO, 	UO_PREVEND, 	UO_RETORNO, 
						UO_PRELEAD, UO_TOTSUC, 	UO_TOTFRA,		UO_FILIAL	           			         			
	           FROM     %table:SUO% SUO 
	           WHERE  	UO_FILIAL 	= %xfilial:SUO% 						AND
						UO_CODCAMP BETWEEN %exp:mv_par01% AND %exp:mv_par02% AND
						%exp:cWhere%
						SUO.%notDel% 										 			           
	           ORDER BY %order:SUO%
	    EndSql    
	END REPORT QUERY oSection3
	                               
	oSection3:SetParentQuery() 
	
	BEGIN REPORT QUERY oSection4
		BeginSQL alias cSUW 
			SELECT UW_CODSCRI,	UW_MIDIA,	UW_PRODUTO,		UW_CODEVE 
			FROM %table:SUW% SUW
			WHERE	UW_FILIAL	=	%xFilial:SUW%	AND
					UW_CODCAMP	= %exp:(cSUO)->UO_CODCAMP%	AND 
					UW_CODSCRI	BETWEEN %exp:mv_par03% AND %exp:mv_par04% AND 
					SUW.%notDel%
			ORDER BY %order:SUW%
		EndSql	
	END REPORT QUERY oSection4

	BEGIN REPORT QUERY oSection5
		BeginSQL alias cSUZ 
			SELECT SUZ.* 
			FROM %table:SUZ% SUZ
			WHERE	UZ_FILIAL	=	%xFilial:SUZ%	AND
					UZ_CODSCRI	= 	%exp:(cSUW)->UW_CODSCRI%	AND
					SUZ.%notDel%
			ORDER BY %order:SUZ%
		EndSql	
	END REPORT QUERY oSection5	
	oSection5:SetLineCondition({||!Empty((cSUW)->UW_CODSCRI)})

	BEGIN REPORT QUERY oSection6
		BeginSQL alias cSUH 
			SELECT SUH.* 
			FROM %table:SUH% SUH
			WHERE	UH_FILIAL	=	%xFilial:SUH%	AND
					UH_MIDIA	=	%exp:(cSUW)->UW_MIDIA% 	AND
					SUH.%notDel%
			ORDER BY %order:SUH%
		EndSql	
	END REPORT QUERY oSection6	
		
	oSection6:SetLineCondition({||!Empty((cSUW)->UW_MIDIA)})

	BEGIN REPORT QUERY oSection7
		BeginSQL alias cSB1
			SELECT SB1.* 
			FROM %table:SB1% SB1
			WHERE	B1_FILIAL	=	%xFilial:SB1%	AND
					B1_COD	=		%exp:(cSUW)->UW_PRODUTO%	AND
					SB1.%notDel%
			ORDER BY %order:SB1%
		EndSql	
	END REPORT QUERY oSection7	
	oSection7:SetLineCondition({||!Empty((cSUW)->UW_PRODUTO)})	
    
	BEGIN REPORT QUERY oSection8
		BeginSQL alias cACD
			SELECT ACD.* 
			FROM %table:ACD% ACD
			WHERE	ACD_FILIAL	=	%xFilial:ACD%	AND
					ACD_CODIGO	=	%exp:(cSUW)->UW_CODEVE% 	AND
					ACD.%notDel%
			ORDER BY %order:ACD%
		EndSql	
	END REPORT QUERY oSection8
	oSection8:SetLineCondition({||!Empty((cSUW)->UW_CODEVE)})	

	BEGIN REPORT QUERY oSection9
		BeginSQL alias cACE
			SELECT ACE.* 
			FROM %table:ACE% ACE
			WHERE	ACE_FILIAL	=	%xFilial:ACE%	AND
					ACE_CODIGO	=	%exp:(cACD)->ACD_CODIGO%	AND
					ACE.%notDel%
			ORDER BY %order:ACE%
		EndSql	
	END REPORT QUERY oSection9
	oSection9:SetLineCondition({||ACE->ACE_CODIGO == ACD->ACD_CODIGO})		

//�������������������������������������������Ŀ
//�Quebra a linha, caso existam muitas colunas�
//���������������������������������������������


oSection3:SetLineStyle()
oSection5:SetLineStyle()
oSection6:SetLineStyle()
oSection7:SetLineStyle()
oSection8:SetLineStyle()
oSection9:SetLineBreak()

oSection4:Cell("UW_CODSCRI"):Disable()

oSection4:SetLeftMargin(5)
oSection5:SetLeftMargin(5)    
oSection6:SetLeftMargin(5)
oSection7:SetLeftMargin(5)
oSection8:SetLeftMargin(5)
oSection9:SetLeftMargin(5)

oSection3:SetPageBreak()

//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection3:Print()

Return(.T.)