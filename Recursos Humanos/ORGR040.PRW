#INCLUDE "orgr040.ch"
#INCLUDE "protheus.ch"      
#INCLUDE "report.ch"
      
/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa     � ORGR040  � Autor � Tania Bronzeri        � Data �01/12/2006���
����������������������������������������������������������������������������Ĵ��
���Descri��o    � Relatorio de Departamentos                                 ���
����������������������������������������������������������������������������Ĵ��
���Uso          � SigaOrg - Arquitetura Organizacional                       ���
����������������������������������������������������������������������������Ĵ��
���Programador  � Data   � BOPS �  Motivo da Alteracao                       ���  
����������������������������������������������������������������������������Ĵ�� 
���Cecilia Carv.�07/08/14�TQEQKP�Incluido o fonte da 11 para a 12 e efetuada ���
���             �        �      �a limpeza.                                  ���
���Isabel N.    �16/06/17�DRHPONTP-1089�Ajuste p/exibir filial e t�tulos das ���
���             �        �             �outras colunas corretamente.         ���
�����������������������������������������������������������������������������ٱ� 
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function ORGR040()
Local oReport   
Local aArea 	:= GetArea()

Private cAliasQry	:= ""
Private lAchou		:= .T.

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("ORG40R",.F.) 
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Tania Bronzeri        � Data �01/12/2006���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Cadastro de Departamentos                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ORGR040                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAORG 	 	 	 	 	 	                                ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0002)	
	//"Cadastro de Departamentos" ### "Ser� impresso de acordo com os parametros solicitados pelo usu�rio."
Private aOrd    := {OemToAnsi(STR0003), OemToAnsi(STR0004), OemToAnsi(STR0005)}	
	//"Departamento" ### "Centro de Custo" ### "Regiao"
Private cTitulo	:= OemToAnsi(STR0001)	//"Cadastro de Departamentos"

//������������������������������������������������������������������������Ŀ
//�Criacao dos componentes de impressao                                    �
//��������������������������������������������������������������������������
DEFINE REPORT oReport NAME "ORGR040" TITLE cTitulo PARAMETER "ORG40R" ACTION {|oReport| ORG040Imp(oReport)} DESCRIPTION OemtoAnsi(STR0006)	//"Emite relacao dos Departamentos cadastrados.

	DEFINE SECTION oSection1 OF oReport TITLE OemToAnsi(STR0003) TABLES "SQB", "CTT", "RBS" ORDERS aOrd	//Departamento

		DEFINE CELL NAME "QB_FILIAL"	OF oSection1 SIZE (GetSx3Cache("QB_FILIAL", "X3_TAMANHO") + 2) ALIAS "SQB"
		DEFINE CELL NAME "QB_DEPTO" 	OF oSection1 SIZE (GetSx3Cache("QB_DEPTO", "X3_TAMANHO") + 7) ALIAS "SQB"
		DEFINE CELL NAME "QB_DESCRIC" 	OF oSection1 SIZE (GetSx3Cache("QB_DESCRIC", "X3_TAMANHO") + 5)	ALIAS "SQB"
		DEFINE CELL NAME "QB_CC"	 	OF oSection1 SIZE (GetSx3Cache("QB_CC", "X3_TAMANHO") + 7) ALIAS "SQB"
		DEFINE CELL NAME "CTT_DESC01"  	OF oSection1 ALIAS "CTT"
		DEFINE CELL NAME "QB_REGIAO"	OF oSection1 TITLE OemToAnsi(STR0007) SIZE (GetSx3Cache("QB_REGIAO", "X3_TAMANHO") + 4) ALIAS "SQB"
		DEFINE CELL NAME "RBS_DESCRI"	OF oSection1 ALIAS "RBS"

		TRPosition():New(oSection1, "CTT", 1, {|| RhFilial("CTT", (cAliasQry)->QB_FILIAL) + (cAliasQry)->QB_CC})
		TRPosition():New(oSection1, "RBS", 1, {|| RhFilial("RBS", (cAliasQry)->QB_FILIAL) + (cAliasQry)->QB_REGIAO})
	              
		oReport:SetColSpace(4)
	
		//oReport: Section("Se��o 1"): Cell("NOMECEL"): SetColSpace(6)
Return(oReport)


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ORG40Imp   � Autor � Tania Bronzeri        � Data �01/12/2006���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Cadastro de Departamentos                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ORG040Imp(oReport)
Local oSection1 := oReport:Section(1)
Local cFiltro 	:= "" 
Local cOrdem	:= ""
Local nOrdem	:= oSection1:GetOrder()

cAliasQry := GetNextAlias()

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr("ORG40R")
	
BEGIN REPORT QUERY oSection1

If nOrdem == 1
	cOrdem  := "%SQB.QB_FILIAL,SQB.QB_DEPTO%"
ElseIf nOrdem == 2                            
	cOrdem	:= "%SQB.QB_FILIAL,SQB.QB_CC,SQB.QB_DEPTO%"
Else                                                   
	cOrdem	:= "%SQB.QB_FILIAL,SQB.QB_REGIAO,SQB.QB_DEPTO%"
EndIf
	
BeginSql alias cAliasQry
	SELECT 	SQB.QB_FILIAL, SQB.QB_DEPTO, SQB.QB_CC, SQB.QB_REGIAO, SQB.QB_DESCRIC
	FROM %table:SQB% SQB 
	WHERE	SQB.%notDel%
	ORDER BY %exp:cOrdem%
EndSql

/*
Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
pela funcao MakeSqlExpr para serem adicionados a query
*/
END REPORT QUERY oSection1 PARAM mv_par01, mv_par02, mv_par03

//�������������������������������������������Ŀ
//� Inicio da impressao do fluxo do relat�rio �
//���������������������������������������������
oReport:SetMeter( (cAliasQry)->(LastRec()) )  

oSection1:Print()	 //Imprimir

Return                     
