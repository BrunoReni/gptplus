#include "VDFR010.CH"
#include 'protheus.ch'
#INCLUDE "report.ch"
#INCLUDE "FWMVCDEF.CH"
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Funcao    � VDFR010  � Autor � TOTVS.       � Data � 01/07/2013 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Vitaliciamento de Membros.                           ���
���          � (Executado a partir de acao relacionada do VDFC010                ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                          ���
��������������������������������������������������������������������������������Ĵ��
���              ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               �����������
����������������������������������������������������������������������������������������Ŀ��
���Programador   � Data   � PRJ/REQ-Chamado �  Motivo da Alteracao                       ���
����������������������������������������������������������������������������������������Ĵ��
���Marcos Pereira�20/03/14�xxx. xxxxxxx     �-Ajuste no filtro RA_CATFUNC p/ "0" somente.���
���              �        �REQ. xxxxxx      �     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc���
���              �        �                 �                                            ���
���Joao balbino  �26/11/15�xxx. xxxxxxx     �-Ajuste no filtro RA_SITFOLH p/ buscar func-���
���              �        �que  n�o estiver demitidoxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc���
�����������������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/


//--------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc}  VDFR010
O relat�rio dever� lista a matricula, nome, data de nomea��o, 
data prevista para vitaliciamento (considerando as prorroga��es)
e tempo restante para vitaliciamento.
@author Everson S.P. Junior
@version 11
@since 16/07/2013
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------
Function VDFR010()
Local oReport

Private cPerg    := STR0001  // Informe o nome do grupo de perguntas      //"FR010PEG"

If IsInCallStack("VDFC010")	
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
                                                    
	If ! Pergunte(cPerg, .T.)
		Return
	EndIf    
	
	oReport := ReportDef(/*cPerg*/)
	oReport:PrintDialog()
Else
 MsgAlert(STR0002)//'O acesso ao Relat�rio � permitido atrav�s da rotina de consulta de vitaliciamento'
EndIf
	
Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Everson S P Junior    � Data �16/07/2013���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de vitaliciamento    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ReportDef()
Local oReport
Local cTitulo := STR0003//'Prazos para Vitaliciamento'
Local aOrd    := {STR0006,STR0004,STR0007,STR0005}//'Centro de Custo'//'Departamento'//'Matricula'//'Nome'
Local cPerg   := '' 
Local cString := 'SRA'
Local oSection1 
Local cDesc1	:= STR0008	//"Matricula"

//������������������������������������������������������������������������Ŀ
//�Criacao dos componentes de impressao                                    �
//��������������������������������������������������������������������������
DEFINE REPORT oReport NAME "VDFR010" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| ReportPrint(oReport)} DESCRIPTION STR0009 TOTAL IN COLUMN//'Relat�rio de prazos para vitaliciamento'
	
	DEFINE SECTION oSection1 OF oReport TITLE 'OemToAnsi(STR0021)' TABLES "SRA" TOTAL IN COLUMN ORDERS aOrd
	    DEFINE CELL NAME "RA_MAT" 	 	  OF oSection1 ALIAS cString
		DEFINE CELL NAME "RA_NOME" 	 	  OF oSection1 ALIAS cString
		DEFINE CELL NAME "RA_DTNOMEA"	  OF oSection1 ALIAS cString
	   	DEFINE CELL NAME STR0010  OF oSection1 TITLE STR0011         BLOCK {||aRet[1][1]}//"data_prevista"//'Data Prevista Vit.'
		DEFINE CELL NAME STR0012 OF oSection1 TITLE STR0013 BLOCK {||aRet[1][2]}//"tempo_restante"//'Tempo para Vitaliciamentos'
	    DEFINE CELL NAME "RA_DEPTO"       OF oSection1 ALIAS cString
	    DEFINE CELL NAME "QB_DESCRIC"     OF oSection1 ALIAS cString
	    DEFINE FUNCTION FROM oSection1:Cell("RA_MAT")		FUNCTION COUNT NO END SECTION 
	                                                                                              
Return(oReport)
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    �
���������������������������������������������������������������������������Ĵ��
���Descri�ao �     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                            ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/

Static Function ReportPrint(oReport)

Local cAliQry   := GetNextAlias()
Local cQryTmp   := ''
Local cOrdem    := ''

//Cria��o da oSection para impress�o, conforme c�lulas definidas no RepordDef
Private oSection 	:= oReport:Section(1)    
Private aRet        := {}
Private nOrdem	    := oSection:GetOrder()
//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(cPerg)
//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������
//Associa a query � section que voc� vai imprimir
oSection:BeginQuery()
If nOrdem == 1
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_MAT%"
ElseIf nOrdem == 2
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_MAT%"
ElseIf nOrdem == 3
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_NOME%"
ElseIf nOrdem == 4
	cOrdem := "%SRA.RA_FILIAL,RA_DEPTO,SRA.RA_MAT%"
Endif

BeginSql alias cAliQry    

	SELECT	QB_DESCRIC,RA_MAT,RA_NOME,RA_DTNOMEA,RA_CC,RA_FILIAL,RA_DEPTO
	FROM 	%table:SRA% SRA 
			
			LEFT JOIN %table:SQB% SQB ON
			SQB.%notDel% AND 
			SQB.QB_FILIAL = %exp:FwxFilial('SQB')% AND
			SRA.RA_DEPTO  = SQB.QB_DEPTO
	
	WHERE	SRA.%notDel% AND 
			SRA.RA_FILIAL = %exp:FwxFilial('SRA')% AND
			SRA.RA_CATFUNC = '0' AND	
			SRA.RA_DEFETIV = ' ' AND
			SRA.RA_SITFOLH NOT IN ('D')
           	
	ORDER BY %Exp:cOrdem%
    
EndSql
END REPORT QUERY oSection PARAM mv_par01, mv_par02, mv_par03, mv_par04, mv_par05

oSection:EndQuery()

oSection:SetLineCondition({||aRet:=FDIAS((cAliQry)->RA_MAT),.T.})//Fun��o Inicia o Modelo de dados Para cada RA_MAT.

oReport:SetMeter((cAliQry)->(LastRec()))

oReport:Section(1):Print(.T.,cAliQry)

//oReport:Section(1):Finish()	

//oReport:Section(1):SetPageBreak(.T.) 

Return

//������������������������������������������������������������������������Ŀ
//�oModel: Inica o Modelo para o calculo do tempo e data para              �
//� Viataliciamento                                                        �
//                                                                      �
//��������������������������������������������������������������������������
//Retorna um Array aDatTMP com os valores dos campos calculados
//������������������������������������������������������������������������Ŀ
//�                             �
//��������������������������������������������������������������������������
Static Function FDIAS(MAT)
Local aDatTMP := {}

If !Empty(MAT)
	dbSelectArea( 'SRA' )
	dbSetOrder( 1 ) //
	SRA->( dbSeek( FwxFilial( "SRA" ) + MAT ) ) 
	
	oModel := FWLoadModel( 'VDFC010' ) //Inicia o modelo VDFC010 para Receber o valor dos campos 
	oModel:SetOperation( MODEL_OPERATION_UPDATE )
	oModel:Activate()
	aAdd(aDatTMP,{oModel:GetValue( 'SRAMASTER', 'RA_DATVITA' ),oModel:GetValue('SRAMASTER','RA_TEMVITA' )})
	oModel:DeActivate()
EndIf
	
Return aDatTMP