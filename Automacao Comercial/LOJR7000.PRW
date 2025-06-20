#INCLUDE "LOJR7000.CH"  
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � LOJR7000 � Autor � Vendas Crm            � Data � 01/03/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Motivo de descontos                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LOJR7000                                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function LOJR7000()

Local oReport	

	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                           �
	//����������������������������������������������������������������
	Pergunte("LOJR7000",.T.)
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                         �
	//� Mv_Par01           // Da Produto                             �
	//� Mv_Par02           // Ate o Produto                          �
	//����������������������������������������������������������������
	
	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������
	oReport := LOJR700Def() 
	oReport:SetLandscape()
	oReport:PrintDialog() 

Return



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LOJR700Def   � Autor �Vendas Crm          � Data �01/03/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina que define os itens que serao apresentados no relato-���
���          �rio de caracteristicas dos produtos no release 4.           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LOJR700Def()                                               ���
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
Static Function LOJR700Def()
Local oReport	//Objeto relatorio TReport (Release 4)
Local oSection1 //Objeto secao 1 do relatorio (Lista, campos das tabelas SB1) 
Local cAlias1 := "MDU"

#IFDEF TOP
	cAlias1		:= GetNextAlias()						
#ENDIF	

DEFINE REPORT oReport NAME "LOJR7000" TITLE STR0001 PARAMETER "LOJR7000" ACTION {|oReport| ljr7PrtRpt( oReport, cAlias1 )} DESCRIPTION STR0002
oReport:SetLandscape()


//�����������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal �
//�������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0001 TABLES "MDU"//,"SX5"      // "Caracteristicas dos Produtos"
                                
//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������
DEFINE CELL NAME "MDU_FILIAL"		OF oSection1 ALIAS "MDU"
DEFINE CELL NAME "MDU_CODIGO"		OF oSection1 ALIAS "MDU"
DEFINE CELL NAME "MDU_SERIE"		OF oSection1 ALIAS "MDU"
DEFINE CELL NAME "MDU_DOC"			OF oSection1 ALIAS "MDU"
DEFINE CELL NAME "MDU_TIPO"			OF oSection1 ALIAS "MDU"
DEFINE CELL NAME "MDU_PRODUT"		OF oSection1 ALIAS "MDU"
DEFINE CELL NAME "MDU_DATA"			OF oSection1 ALIAS "MDU"
DEFINE CELL NAME "MDU_OBS"			OF oSection1 ALIAS "MDU"
 
Return(oReport)  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ljr7PrtRpt   � Autor �Vendas crm          � Data �01/03/2010���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ljr7PrtRpt(ExpO1,ExpC2)                                    ���
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
Static Function ljr7PrtRpt(oReport, cAlias1)
Local oSection1 := oReport:Section(1) 		//Objeto secao 1 do relatorio (Lista, campos das tabelas SB1)
Local cFiltro	:= ""   					//String contendo o filtro de busca a ser utilizado com DBF   

#IFDEF TOP 

	MakeSqlExpr("LOJR7000") 

	DbSelectArea("MDU")	
	If (MDU->(FieldPos("MDU_STATUS"))) > 0
		cCampo	:= " MDU_STATUS <> 'O' AND "
	Else
		cCampo	:= " MDU_SERIE <> '' AND "	
	EndIf
		
	cCampo	:= "%" + cCampo + "%"	     
    
	BEGIN REPORT QUERY oSection1
 	BeginSQL alias cAlias1                          	
           SELECT MDU_CODIGO, MDU_SERIE, MDU_DOC, MDU_OBS, MDU_DATA, MDU_FILIAL, MDU_TIPO, MDU_PRODUT
           FROM   %table:MDU% MDU;
           WHERE  	MDU_FILIAL 	BETWEEN %exp:mv_par01% AND %exp:mv_par02% AND
           			MDU_DATA 	BETWEEN %exp:mv_par03% AND %exp:mv_par04% AND
           			MDU_CODIGO 	BETWEEN %exp:mv_par05% AND %exp:mv_par06% AND
           			%Exp:cCampo%           			
           			MDU.%notDel%
     
           ORDER BY MDU_FILIAL, MDU_DOC
     EndSql    
	END REPORT QUERY oSection1      



#ENDIF

//�������������������������������������������Ŀ
//�Quebra a linha, caso existam muitas colunas�
//���������������������������������������������
oSection1:SetLineBreak()

//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()



Return(.T.)