#INCLUDE "orgr010.ch"
#INCLUDE "protheus.ch"      
#INCLUDE "report.ch"

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa     � ORGR010  � Autor � Tania Bronzeri        � Data �21/11/2006���
����������������������������������������������������������������������������Ĵ��
���Descri��o    � Relacao de Regioes                                         ���
����������������������������������������������������������������������������Ĵ��
���Uso          � SigaOrg - Arquitetura Organizacional                       ���
����������������������������������������������������������������������������Ĵ��
���Programador  � Data   � BOPS �  Motivo da Alteracao                       ���  
����������������������������������������������������������������������������Ĵ�� 
���Cecilia Carv.�07/08/14�TQEQKP�Incluido o fonte da 11 para a 12 e efetuada ���
���             �        �      �a limpeza.                                  ���
�����������������������������������������������������������������������������ٱ� 
��������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function ORGR010()

Local oReport   
Local aArea 	:= GetArea()

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("ORG10R",.F.) 

oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Tania Bronzeri        � Data �22/11/2006���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Cadastro de Regioes                             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ORGR010                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ORGR010 - Generico                                           ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0002) + OemToAnsi(STR0003)	
	//"Cadastro de Regioes" ### "Ser� impresso de acordo com os parametros solicitados pelo"  ### "usu�rio."
Private aOrd    := {OemToAnsi(STR0004),OemToAnsi(STR0007)}	//"Codigo da Regiao" ### "Descricao da Regiao"
Private cTitulo	:= OemToAnsi(STR0001)	//"Cadastro de Regioes"

//������������������������������������������������������������������������Ŀ
//�Criacao dos componentes de impressao                                      �
//��������������������������������������������������������������������������
DEFINE REPORT oReport NAME "ORGR010" TITLE cTitulo PARAMETER "ORG10R" ACTION {|oReport| ORG10Imp(oReport)} DESCRIPTION OemtoAnsi(STR0005)	//"Este relatorio emite relacao das Regioes cadastradas."

	DEFINE SECTION oSection1 OF oReport TITLE OemToAnsi(STR0006) TABLES "RBS" ORDERS aOrd	//"Regioes"

		DEFINE CELL NAME "RBS_CODIGO" OF oSection1 ALIAS "RBS"
		DEFINE CELL NAME "RBS_DESCRI" OF oSection1 ALIAS "RBS"
	oReport:SetColSpace(4)
	
Return(oReport)


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ORG10Imp   � Autor � Tania Bronzeri        � Data �22/11/2006���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Cadastro de Regioes                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ORG10Imp(oReport)

Local oSection1 := oReport:Section(1)
Local cFiltro 	:= "" 
Local cAliasQry	:= ""

Private cOrdem	:= ""
Private nOrdem	:= oSection1:GetOrder()

cAliasQry := GetNextAlias()

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr("ORG10R")
	
BEGIN REPORT QUERY oSection1

If nOrdem == 1
	cOrdem  := "%RBS.RBS_FILIAL,RBS.RBS_CODIGO%"
Else
	cOrdem  := "%RBS.RBS_FILIAL,RBS.RBS_DESCRI%"
EndIf
	
BeginSql alias cAliasQry
	SELECT 	RBS.RBS_FILIAL, RBS.RBS_CODIGO, RBS.RBS_DESCRI
	FROM %table:RBS% RBS 
	WHERE RBS.%notDel%  
	ORDER BY %exp:cOrdem%
EndSql

/*
Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
pela funcao MakeSqlExpr para serem adicionados a query
*/
END REPORT QUERY oSection1 PARAM mv_par01, mv_par02

//�������������������������������������������Ŀ
//� Inicio da impressao do fluxo do relat�rio �
//���������������������������������������������
oReport:SetMeter( (cAliasQry)->(LastRec()) )  

oSection1:Print()	 //Imprimir

Return