#INCLUDE "CTBR076.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "REPORT.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR076  � Autor � Danilo Dias             � Data � 14/12/10 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Impress�o da tabela de hist�ricos de altera��es	���
���          � das entidades cont�beis (CW8).                             	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctbr076() 		                                            ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���L
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function CTBR076()   
Local oReport
Private cAlias := ""
Private cPerg  := "CTR076"						// Nome do grupo de perguntas

//Captura a �rea de acordo com a conex�o
cAlias := GetNextAlias()	//Para TopConnection

If TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	MsgAlert( OemToAnsi(STR0028) )//"Relatorio dispon�vel apenas em TReport."
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ReportDef  Autor � Danilo Dias           � Data � 14/12/10 ���
�������������������������������������������������������������������������͹��
���Descricao � Defini��o do objeto do relat�rio personaliz�vel e das      ���
���          � se��es que ser�o utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()

Local oReport
Local oSecaoCW8
Local cReport		:= "CTBR076"					// Nome do Relatorio
Local cTitulo		:= STR0004 						// "Hist�rico de Altera��es"
Local cDesc			:= STR0001 + " " +;				// "Este programa ir� imprimir o Cadastro CW8-Hist�rico de Altera��es."
					   STR0002 + " " + ;		    // "Ser� impresso de acordo com os par�metros solicitados pelo"
					   STR0003						// "usu�rio."                                                                  

//�������������������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         						�
//� mv_par01		// Data Inicial.                             						�
//� mv_par02		// Data Final.                               						�
//� mv_par03		// Entidade Contabil ( Conta, C. Custo, Cl. Valor ou It. Contabil )	�
//� mv_par04		// Considera Bloqueios ( Sim ou N�o ).      	 					� 
//� mv_par05		// Considera Opera��es ( Altera��o, Inclus�o, Exclus�o ou Todas ).  �
//���������������������������������������������������������������������������������������

Pergunte( cPerg, .F. )

DEFINE REPORT oReport NAME cReport TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport( oReport )}  DESCRIPTION cDesc

	DEFINE SECTION oSecaoCW8 OF oReport TITLE cTitulo TABLE "CW8"

		DEFINE CELL NAME "CW8_TABELA" OF oSecaoCW8 ALIAS cAlias TITLE STR0007 	SIZE 16 LINE BREAK BLOCK({||TabDesc( (cAlias)->CW8_TABELA )})	//Title: "Entidade"
		DEFINE CELL NAME "CW8_CODIGO" OF oSecaoCW8 ALIAS cAlias TITLE STR0018	SIZE 14				//Title: "C�d. Entidade"
		DEFINE CELL NAME "CW8_CAMPO"  OF oSecaoCW8 ALIAS cAlias TITLE STR0019 	SIZE 14				//Title: "Campo Alterado"
		DEFINE CELL NAME "CW8_SEQ"    OF oSecaoCW8 ALIAS cAlias TITLE STR0020	SIZE 9				//Title: "Seq. Alt." 
		DEFINE CELL NAME "CW8_TIPCPO" OF oSecaoCW8 ALIAS cAlias TITLE STR0021 	SIZE 4				//Title: "Tipo"
		DEFINE CELL NAME "CW8_TITULO" OF oSecaoCW8 ALIAS cAlias TITLE STR0022	SIZE 14				//Title: "Tit. do Campo"
		DEFINE CELL NAME "CW8_VALANT" OF oSecaoCW8 ALIAS cAlias TITLE STR0023 	SIZE 25 LINE BREAK	//Title: "Conte�do Ant." 
		DEFINE CELL NAME "CW8_VALNOV" OF oSecaoCW8 ALIAS cAlias TITLE STR0024 	SIZE 25 LINE BREAK	//Title: "Conte�do Atual"
		DEFINE CELL NAME "CW8_DATA"   OF oSecaoCW8 ALIAS cAlias TITLE STR0025	SIZE 10 			//Title: "Dt. Alt."
		DEFINE CELL NAME "CW8_HORA"   OF oSecaoCW8 ALIAS cAlias TITLE STR0026	SIZE 5				//Title: "Hora"
		DEFINE CELL NAME "CW8_OPC"    OF oSecaoCW8 ALIAS cAlias TITLE STR0027	SIZE 9				//Title: "Op��o"
				
	oReport:SetLandscape()		//Configura impress�o do relat�rio como Paisagem por padr�o
			
Return oReport      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CTBR076Top  Autor � Danilo Dias        � Data � 10/12/2010 ���
�������������������������������������������������������������������������͹��
���Descricao � Impress�o do relat�rio de acordo com o tipo de BD          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR076                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrintReport( oReport, oSecaoCW8 )

Local bCondicao := {|| (((cAlias)->CW8_DATA >= mv_par01) .And. ((cAlias)->CW8_DATA <= mv_Par02)) .And. AllTrim((cAlias)->CW8_FILIAL) == AllTrim(XFILIAL('CW8')) .And. (cAlias)->CW8_TABELA == cEntidade }
Local cCondicao :=    "(((cAlias)->CW8_DATA >= mv_par01) .And. ((cAlias)->CW8_DATA <= mv_Par02)) .And. AllTrim((cAlias)->CW8_FILIAL) == AllTrim(XFILIAL('CW8')) .And. (cAlias)->CW8_TABELA == cEntidade"
Local cPart     := ""
Local cEntidade := ""
Local cOperacao := ""
Local cTabela   := ""		//Tabela que sofreu altera��o para capturar a descri��o

//Filtra a tabela
If ( mv_par03 == 1 )
	cEntidade := "CT1"		//Plano de Contas
ElseIf ( mv_par03 == 2 )
	cEntidade := "CTT"		//Centro de Custos
ElseIf ( mv_par03 == 3 )
	cEntidade := "CTD"		//Item Cont�bil
ElseIf ( mv_par03 == 4 )
	cEntidade := "CTH"		//Classe de Valor
EndIf

cTabela := TabDesc( cEntidade )
    
//Considera Bloqueios?
If ( mv_par04 == 2 )
	cPart := "%'CT1_BLOQ','CTT_BLOQ','CTD_BLOQ','CTH_BLOQ'%"		//Sim
Else
	cPart := "%''%"													//N�o
EndIf
	
//Considera as opera��es
If ( mv_par05 == 1 )
	cOperacao := "%'3'%"				//Inclus�o
ElseIf ( mv_par05 == 2 )
	cOPeracao := "%'4'%"				//Altera��o
ElseIf ( mv_par05 == 3 )
	cOPeracao := "%'5'%"				//Exclus�o
Else
	cOPeracao := "%'3', '4', '5'%"		//Todas
End If
	
MakeSqlExp( oReport:uParam )
oReport:Section(1):BeginQuery()
	
BeginSql Alias cAlias
		
	Column CW8_DATA As Date
	
	SELECT CW8_DATA,
		   CW8_HORA,
		   CW8_TABELA,
		   CW8_CODIGO,
		   CW8_CAMPO,
		   CW8_SEQ,
		   CW8_TIPCPO,
		   CW8_TITULO,
		   CW8_OPC,
		   CW8_VALANT,
		   CW8_VALNOV
	  FROM %Table:CW8% CW8
	 WHERE CW8_FILIAL = %xFilial:CW8%
	   AND CW8_TABELA = %exp:cEntidade%
	   AND CW8_DATA BETWEEN %exp:mv_par01% AND %exp:mv_par02%
	   AND CW8_OPC IN ( %exp:cOperacao% )
	   AND CW8_CAMPO NOT IN ( %exp:cpart% )
	   AND CW8.%notdel%
			
EndSql
	
oReport:Section(1):EndQuery()
oReport:Section(1):Print()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � TabDesc     Autor � Danilo Dias        � Data � 14/12/2010 ���
�������������������������������������������������������������������������͹��
���Descricao � Captura a descri��o da tabela de acordo com o idioma       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� cTabela: Nome da tabela para capturar a descri��o          ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR076                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TabDesc( cTabela )
           
Local cTabDesc := ""
Local aArea    := GetArea()		//Guarda �rea atual

dbSelectArea("SX2")				//Seleciona dicion�rio SX2 (Tabelas)
dbSetOrder(1)              

If dbSeek( cTabela )           	//Procura Tabela no dicion�rio
	cTabDesc := X2Nome()		//Se encontrar, pega a descri��o
EndIf

RestArea(aArea)					//Restaura �rea
         
Return cTabDesc
