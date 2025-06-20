#INCLUDE "finr656.ch"
/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR656  � Autor �Bruno Sobieski        � Data � 23.05.08 ���
������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de provisao p/cobrancas duvidosas                 ���
������������������������������������������������������������������������Ĵ��
���Sintaxe e � FINR655(void)                                             ���
������������������������������������������������������������������������Ĵ��
���Parametros�                                                           ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/

Function FINR656()
Local oReport
#IFDEF TOP
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport	:= ReportDef()
	oReport:PrintDialog()
#ELSE
	Aviso(STR0001,STR0002,{STR0003}) //"Nao disponivel"###"Este relatorio so esta disponivle para ambientes com banco de dados relacional"###"Ok"
#ENDIF
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Bruno Sobieski         � Data �23.05.2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport,oSection1,oSection2
Local cReport := "FINR656"
Local cTitulo := OemToAnsi(STR0004)  //"Provisao para cobranca duvidosa"
Local cDescri := OemToAnsi(STR0005) //"Este relatorio imprime e as provisoes para cobranca duvidosas geradas."

Pergunte( "FINR656001" , .F. )
                   
oReport  := TReport():New( cReport, cTitulo, 'FINR656001' , { |oReport| ReportPrint( oReport ) }, cDescri )
oReport:SetLandScape()

//������������������������������������������������������Ŀ
//� Define a 1a. secao do relatorio Valores nas Moedas   �
//��������������������������������������������������������
oSection1 := TRSection():New( oReport,STR0006 , {"FIA","SE1","SA1"},{STR0007,STR0008})  //"Titulos"###"Cliente"###"Emissao Provisao+Cliente"
TRCell():New( oSection1, "FIA_CLIENT" ,"FIA", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "FIA_LOJA" 	,"FIA", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "FIA_PREFIX"	,"FIA", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "FIA_NUM" 		,"FIA", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "FIA_PARCEL"	,"FIA"	, ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "FIA_TIPO" 	,"FIA", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "FIA_MOEDA"	,"FIA", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "FIA_DTPROV" ,"FIA" )
TRCell():New( oSection1, "FIA_VALOR"	,"FIA" )	
TRCell():New( oSection1, "FIA_VLLOC"	,"FIA" )	
TRCell():New( oSection1, "FIA_SEQ"		,"FIA" )	

oSection1:SetHeaderPage(.T.)
 

Return oReport
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ReportPrint Autor � Bruno Sobieski       � Data � 23.05.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do TREPORT                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oReport : Objeto Report                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


Static Function ReportPrint( oReport )
Local oSection1 := oReport:Section(1)
Local nOrder		:= oSection1:GetOrder()
Local cOrder 
Local 	oBreak1 
If nOrder	==	1
	cOrder	:=	"%ORDER BY FIA_CLIENT,FIA_LOJA,FIA_PREFIX,FIA_NUM,FIA_PARCEL,FIA_TIPO,FIA_SEQ%"
	oBreak1 := TRBreak():New( oSection1,oSection1:Cell("FIA_CLIENT"),STR0009 )   //"Total do cliente"
	TRFunction():New(oSection1:Cell("FIA_VLLOC"), , "SUM"  	, oBreak1,STR0010 , , , .F.,.T.  ) //"Total"
Else
	cOrder	:=	"%ORDER BY FIA_DTPROV,FIA_CLIENT,FIA_LOJA,FIA_PREFIX,FIA_NUM,FIA_PARCEL,FIA_TIPO,FIA_SEQ%"
	oBreak1 := TRBreak():New( oSection1,oSection1:Cell(STR0011), "Total do dia" )   //"FIA_DTPROV"
	TRFunction():New(oSection1:Cell("FIA_VLLOC"), , "SUM"  	, oBreak1,STR0012 , , ,.F. , .T.  ) //"Total "
Endif



MaKeSqlExpr("FINR656001")

	oSection1:BeginQuery()

	BeginSql alias "QRYFIA"
		SELECT E1_CLIENTE,E1_LOJA,E1_EMIS1,E1_VENCREA,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO, 
					 FIA_CLIENT,FIA_LOJA,FIA_PREFIX,FIA_NUM,FIA_PARCEL,FIA_TIPO,
					FIA_DTPROV, FIA_VALOR, FIA_SEQ, FIA_VLLOC
  	FROM %table:SA1% SA1,%table:SE1% SE1,%table:FIA% FIA
		WHERE A1_FILIAL = %xfilial:SA1% AND
					E1_FILIAL = %xfilial:SE1% AND
					FIA_FILIAL = %xfilial:FIA% AND
					FIA_DTPROV BETWEEN %exp:Dtos(mv_par04)% AND %exp:Dtos(mv_par05)% AND
					E1_VENCREA BETWEEN %exp:Dtos(mv_par06)% AND %exp:Dtos(mv_par07)% AND
					A1_COD  	= 	FIA_CLIENT AND					
					A1_LOJA 	= 	FIA_LOJA   AND					
  				FIA_CLIENT=		E1_CLIENTE AND 
  				FIA_LOJA	=   E1_LOJA 	 AND 
  				FIA_PREFIX=   E1_PREFIXO AND 
  				FIA_NUM		=   E1_NUM		 AND 
  				FIA_PARCEL=   E1_PARCELA AND 
  				FIA_TIPO	=   E1_TIPO 	 AND 
					SA1.%notDel% AND
			  	SE1.%notDel% AND                                                              
			  	FIA.%notDel%
					%Exp:cOrder%
	EndSql

	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
	oSection1:EndQuery({mv_par01,mv_par02,mv_par03})


	oSection1:Print()

Return