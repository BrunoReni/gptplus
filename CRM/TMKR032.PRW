#INCLUDE "TMKR032.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR032  � Autor � Armando M. Tessaroli  � Data � 14/03/003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rel�cao dos vendedores                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMKR032(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
���ANALISTA  � DATA   � BOPS �MOTIVO DA ALTERACAO                         ���
�������������������������������������������������������������������������Ĵ��
���Michel W. �13/07/06�99202 �Atualizacao release 4.                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR032()

Local oReport //Objeto relatorio TReport (Release 4)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TMK032",.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� Mv_Par01           // Do Vendedor                            �
//� Mv_Par02           // Ate o Vendedor                         �
//����������������������������������������������������������������

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
���Fun��o    �ReportDef � Autor �Michel W. Mosca     � Data �13/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina que define os itens que serao apresentados no relato-���
���          �rio de Listagem de vendedores no release 4.           	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �    ReportDef()                                             ���
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
Local oReport             	//Objeto relatorio TReport (Release 4)
Local oSection1  			//Objeto secao 1 do relatorio (Dados, campos das tabelas SA3)
Local cAlias1 := "SA3" 		//Alias da consulta Embedded SQL

#IFDEF TOP
	cAlias1		:= GetNextAlias()						// Pega o proximo Alias Disponivel
#ENDIF	

// "Listagem de vendedores" # // "Este Programa ira emitir uma listagem dos vendedores"
// "conforme os parametros informados"
DEFINE REPORT oReport NAME "TMKR032" TITLE STR0001 PARAMETER "TMK032" ACTION {|oReport| Tkr032PrtRpt( oReport, cAlias1 )} DESCRIPTION STR0002 + STR0003

//�����������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal �
//�������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0009 TABLES "SA3"			//Vendedores

	
DEFINE CELL NAME "A3_COD"		OF oSection1 ALIAS "SA3"
DEFINE CELL NAME "A3_NOME"		OF oSection1 ALIAS "SA3"	
DEFINE CELL NAME "A3_END"		OF oSection1 ALIAS "SA3"	
DEFINE CELL NAME "A3_BAIRRO"	OF oSection1 ALIAS "SA3"
DEFINE CELL NAME "A3_MUN"		OF oSection1 ALIAS "SA3"	
DEFINE CELL NAME "A3_EST"		OF oSection1 ALIAS "SA3"	

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tkr032PrtRpt � Autor �Michel W. Mosca     � Data �13/07/2006���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio de           ���
���          �Listagem de vendedores no release 4.                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tkr032PrtRept(ExpO1,ExpC2)                                 ���
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
Static Function Tkr032PrtRpt(oReport, cAlias1)
Local oSection1 := oReport:Section(1) 		//Objeto secao 1 do relatorio (Dados, campos das tabelas SA3)
Local cFiltro	:= ""                      	//String contendo o filtro de busca a ser utilizado com DBF

#IFDEF TOP 


	//���������������������������������������������������������������������������������Ŀ
	//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
	//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
	//�����������������������������������������������������������������������������������
	MakeSqlExpr("TMKR032")      
	
    

	BEGIN REPORT QUERY oSection1
 	BeginSQL alias cAlias1
		SELECT	A3_COD,		A3_NOME,	A3_END,		A3_BAIRRO,
				A3_MUN,		A3_EST 
		FROM 	%table:SA3% SA3
		WHERE	A3_FILIAL 	=	%xFilial:SA3%	AND
				A3_COD	BETWEEN	%exp:mv_par01% 	AND %exp:mv_par02% AND
				SA3.%notDel%
		ORDER BY %order:SA3%
    EndSql    
	END REPORT QUERY oSection1 
                              

#ELSE 

	//���������������������������������������������������������������������������������Ŀ
	//�Utilizar a funcao MakeAdvlExpr, somente quando for utilizar o range de parametros�
	//�����������������������������������������������������������������������������������
	MakeAdvplExpr("TMK032")       

	DbSelectArea ("SA3")
	DbSetOrder(1)
	
	cFiltro := 	"A3_FILIAL 	== 	'"+ xFilial("SA3") +"'	.AND. "	
	cFiltro +=	"A3_COD 	>= 	'" + MV_PAR01 + "' 		.AND. "
	cFiltro +=	"A3_COD 	<= 	'" + MV_PAR02 + "'"
	
	oSection1:SetFilter( cFiltro ) 

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