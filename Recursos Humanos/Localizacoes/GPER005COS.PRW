#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER005COS.CH"
/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPER005COS� Autor � Flor Monroy                � Data � 03/08/11 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Generar un TReport Reporte NO Aplicados                         ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER005COS()                                                    ���
������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
������������������������������������������������������������������������������Ĵ��
���Programador � Data   �  BOPS/FNC �  Motivo da Alteracao                     ���
������������������������������������������������������������������������������Ĵ��
���Christiane V�26/10/11�020276/2011� Tradu��o de ch                           ���
���Christiane V�31/10/11�020276/2011� Altera��o do tratamento das perguntas    ���
���Christiane V�25/11/11�020276/2011� Corre��o da Impress�o do relat�rio       ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Function GPER005COS()

Local oReport
Local aGetArea		:=	GetArea()

Private cPerg		:=	"GPR005COS"
Private cProceso	:=	""	//Parametro de Entrada: Lista de procesos pertenecientes a la empresa de la cual se generar� la declaraci�n	
Private cNomina		:=	""	//Parametro de Entrada: Lista de Tipos de N�mina disponibles, y permitir capturar uno, todos, o solo algunos tipos de n�mina. flistbox
Private cPeriodo	:=	""	//Parametro de Entrada: Rango de Periodos
Private cNumPag		:=	""	//Parametro de Entrada: Rango de N�mero de Pagos
Private cSuc		:=	""	//Parametro de Entrada: Rango de Sucursales
Private cMat		:=	""	//Parametro de Entrada: Rango de Matr�culas
Private cCC			:=	""	//Parametro de Entrada: Rango de Centro de Costos
Private cDepto		:=	""	//Parametro de Entrada: Rango de Departamentos
Private cLoc		:=	""	//Parametro de Entrasda: Rango de Localidades de Pago
Private cConcep		:=	""	//Parametro de Entrada: Rango de Conceptos
Private cAliasTmp	:=	criatrab(nil,.f.)	// Creo mi tabla temporal
Private cNomeProg	:=	"GPER005COS"

Private nTipo		:=	0	//Parametro de Entrada: 1 Sint�tico / 2 Anal�tico

dbSelectArea("SRA")  //Empleados
dbSelectArea("RCH")  //Periodos
dbSelectArea("SRC")  //Movimientos de N�mina 
dbSelectArea("RCJ")  //Procesos
dbSelectArea("SRV")  //Conceptos
DbSetOrder(1)

Pergunte(cPerg,.F.)

OREPORT:=REPORTDEF()
OREPORT:PRINTDIALOG()

RestArea(aGetArea)
Return ( Nil )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef |  Autor� FMonroy               � Data � 03/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �  Definir las celdas del Reporte NO Aplicados               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �  ReportDef()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  GPEMXX1                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ReportDef()

Local aArea      := GetArea() 
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4


Private cTitulo	:=OEMTOANSI(STR0001) //"Reporte NO Aplicados"
//Private aOrder  := {OemToAnsi(STR0002),OemToAnsi(STR0003),OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006)}//"Matricula"+"Nombre"+"Centro de Costos+Matricula"+"Departamento+Matricula"+"Localidad de Pago+Matricula"
Private aOrder  := {OemToAnsi(STR0002),OemToAnsi(STR0003),OemToAnsi(STR0005)}//"Matricula"+"Nombre"+"Departamento+Matricula"

cTitulo := Trim(cTitulo)
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport:=TReport():New(cNomeProg,OemToAnsi(cTitulo), cPerg   ,{|oReport| PrintReport(oReport)})	
oReport:nColSpace	:= 2
oReport:nFontBody	:= 7 	// Define o tamanho da fonte.
oReport:CFONTBODY	:=	"COURIER NEW" 

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//��������������������������������������������������������������������������

//��������������������������������������������������������������������������������������������Ŀ
//� Definici�n de la Primera Secci�n: Analitico por Concepto o Departamento o Localidad de Pago�
//� Encabezado                                                                                 �
//���������������������������������������������������������������������������������������������� 

oSection1:= TRSection():New(oReport,"EncAnalitico",,aOrder ,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
oSection1:SetLineStyle(.T.)		//Pone titulo del campo y aun lado el y valor
oSection1:SetCharSeparator(":") 

TRCell():New(oSection1,"CC",	,STR0007, ,TamSx3("CTT_DESC01")[1] )	//"Centro de Costos"

//��������������������������������������������������������������������������������������������Ŀ
//� Definici�n de la Segunda Secci�n: Analitico por Concepto o Departamento o Localidad de Pago�
//� Detalle                                                                                    �
//���������������������������������������������������������������������������������������������� 

oSection2:= TRSection():New(oReport,"DetalleAnalitico",,aOrder ,/*Campos do SX3*/,/*Campos do SIX*/)
oSection2:SetHeaderSection(.T.)		//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao

TRCell():New(oSection2,"FIL",		,STR0008,PesqPict("SRA","RA_CIC")	,TamSx3("RA_FILIAL")[1]	)	//"Suc"
TRCell():New(oSection2,"MAT",		,STR0009,							,TamSx3("RA_MAT")[1]	)	//"Mat"
TRCell():New(oSection2,"NOME",		,STR0010,							,TamSx3("RA_NOME")[1]	)	//"Nombre"
TRCell():New(oSection2,"PD",		,STR0011,PesqPict("SRC","RC_PD")	,TamSx3("RC_PD")[1]		)	//"Con"
TRCell():New(oSection2,"DESC",		,STR0012,							,TamSx3("RV_DESC")[1]	)	//"Descrpci�n"
TRCell():New(oSection2,"IMP",		,STR0013,PesqPict("SRC","RC_VALOR")	,15						)	//"Importe"


//������������������������������������������������������������������������������������������������������������Ŀ
//� Definici�n de la Tercera Secci�n: Formato Sint�tico por Centro de Costos o Departamento o Localidad de Pago�
//� Detalle                                                                                                    �
//�������������������������������������������������������������������������������������������������������������� 

oSection3:= TRSection():New(oReport,"EncSintetico",,aOrder ,/*Campos do SX3*/,/*Campos do SIX*/)
oSection3:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection3:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao

TRCell():New(oSection3,"PD",		,STR0011,PesqPict("SRC","RC_PD")	,TamSx3("RC_PD")[1]			)	//"Con"
TRCell():New(oSection3,"DESC",		,STR0012,							,TamSx3("RV_DESC")[1]		)	//"Descripci�n"
TRCell():New(oSection3,"IMP",		,STR0013,PesqPict("SRC","RC_VALOR")	,15							)	//"Importe


//��������������������������������������������������������������������������������������������Ŀ
//� Definici�n de la Cuarta Secci�n: Analitico por Matricula o Nombre                          �
//� Detalle                                                                                    �
//���������������������������������������������������������������������������������������������� 

oSection4:= TRSection():New(oReport,"DetalleSintetico",,aOrder,/*Campos do SX3*/,/*Campos do SIX*/)
oSection4:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection4:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao

TRCell():New(oSection4,"FIL",		,STR0008,PesqPict("SRA","RA_CIC")	,TamSx3("RA_FILIAL")[1]		)	//"Suc"
TRCell():New(oSection4,"MAT",		,STR0009,							,TamSx3("RA_MAT")[1]		)	//"Mat"
TRCell():New(oSection4,"NOME",		,STR0010,							,TamSx3("RA_NOME")[1]		)	//"Nombre"
TRCell():New(oSection4,"PD",		,STR0011,PesqPict("SRC","RC_PD")	,TamSx3("RC_PD")[1]			)	//"Con"
TRCell():New(oSection4,"DESC",		,STR0012,							,TamSx3("RV_DESC")[1]		)	//"Descrpci�n"
TRCell():New(oSection4,"IMP",		,STR0013,PesqPict("SRC","RC_VALOR")	,15							)	//"Importe"
TRCell():New(oSection4,"PER",		,STR0014,							,TamSx3("RC_PERIODO")[1]+3	)	//"Periodo"


Return( oReport )                
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � GetRows   � Autor � FMonroy             � Data � 01/08/11 ���                
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Obtener movimientos de N�mina que corresponden a los pro- ��� 
���           � cesos, periodo, pago y tipo de n�mina capturados en los   ��� 
���           � para�metros de entrada.                                   ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � GetRows(nExp) 		                                      ��� 
�������������������������������������������������������������������������Ĵ��
���Parametros � nExp: Orden seleccionado                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso       � GPER005COS                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GetRows(nOrder)   
    
Local aArea		:=	GetArea()
Local cQuery 	:=	""
Local cPeriodsO	:=	"' ',"
Local cPeriodsC	:=	"' ',"
Local cOrder	:=	""

GetPeriods(@cPeriodsO ,@cPeriodsC )//Obtiene Periodos
cPeriodsO := Substr(cPeriodsO,1,Len(cPeriodsO)-1)
cPeriodsC := Substr(cPeriodsC,1,Len(cPeriodsC)-1)

If nTipo ==1 //Analitico
cQuery  := " SELECT *"
	If nOrder == 1
		cOrder := " ORDER BY MAT,PD "
	ElseIf nOrder == 2
		cOrder := " ORDER BY NOME,PD "
	ElseIf nOrder == 3
		cOrder := " ORDER BY CC,MAT,PD "
	ElseIf nOrder == 4
		cOrder := " ORDER BY DEPTO,MAT,PD"
	ElseIf nOrder == 5
		cOrder := " ORDER BY KEYLOC,MAT,PD"
	Endif

Else //Sintetico	
	If nOrder == 1
		cQuery += " SELECT FILIAL,NOME,  MAT, PD, SUM(VNAOAPL) VNAOAPL"
		cOrder := " GROUP BY PD,FILIAL,MAT,NOME "
		cOrder += " ORDER BY FILIAL,PD,MAT "
	ElseIf nOrder == 2
		cQuery += " SELECT FILIAL,NOME,  MAT, PD, SUM(VNAOAPL)VNAOAPL"
		cOrder := " GROUP BY FILIAL,PD,MAT,NOME "
		cOrder += " ORDER BY FILIAL,PD,NOME "
	ElseIf nOrder == 3
		cQuery += " SELECT CC, PD, SUM(VNAOAPL)VNAOAPL"
		cOrder := " GROUP BY CC,PD "
		cOrder += " ORDER BY CC,PD "
	ElseIf nOrder == 4
		cQuery += " SELECT DEPTO, PD, SUM(VNAOAPL)VNAOAPL"
		cOrder := " GROUP BY DEPTO,PD "
		cOrder += " ORDER BY DEPTO,PD"
	ElseIf nOrder == 5
		cQuery += " SELECT KEYLOC, PD, SUM(VNAOAPL)VNAOAPL"
		cOrder := " GROUP BY KEYLOC,PD "
		cOrder += " ORDER BY KEYLOC,PD"
	Endif
	
EndIf


cQuery	+= " FROM ("
cQuery	+= " SELECT SRC.RC_CC CC,	SRC.RC_DEPTO DEPTO,		SRA.RA_KEYLOC KEYLOC,  SRA.RA_NOME NOME,	SRC.RC_FILIAL FILIAL,	SRC.RC_MAT MAT, "
cQuery	+= "   	   SRC.RC_PD PD,    SRC.RC_VNAOAPL VNAOAPL, SRC.RC_PERIODO PERIODO, SRC.RC_SEMANA SEMANA"
cQuery	+= " FROM "+RetSqlName("SRC")+ " SRC"
cQuery	+= " INNER JOIN "+RetSqlName("SRA")+ " SRA ON SRA.RA_FILIAL ='" +XFILIAL( "SRA", SRC->RC_FILIAL)+"' AND SRA.RA_MAT=SRC.RC_MAT"
cQuery	+= " WHERE" 
cQuery	+= " 		    SRC.RC_SEMANA IN( "+ cPeriodsO +" )"
cQuery	+= " 		AND SRC.RC_PERIODO =  '"+ cPeriodo +"' "
cQuery	+= " 		AND SRC.RC_PROCES IN( "+ cProceso +") "

cQuery	+= " 		AND SRC.RC_ROTEIR IN( "+ cNomina +") "

cQuery	+=If (empty(cSuc),    cSuc,    "AND "+ cSuc )
cQuery	+=If (empty(cMat),    cMat,    "AND "+ cMat )
cQuery	+=If (empty(cCC),     cCC,     "AND "+ cCC )
cQuery	+=If (empty(cDepto),  cDepto,  "AND "+cDepto )
cQuery	+=If (empty(cLoc),    cLoc,    "AND "+cLoc )


cQuery	+=If (empty(cConcep),    cConcep,    "AND "+cConcep )

cQuery	+= "        AND SRA.D_E_L_E_T_ <> '*'  "
cQuery	+= "        AND SRC.D_E_L_E_T_ <> '*'  "
cQuery	+= "        AND SRC.RC_VNAOAPL <> 0    "


cQuery	+= " UNION "


cQuery	+= "SELECT SRD.RD_CC CC,	SRD.RD_DEPTO DEPTO,		SRA.RA_KEYLOC KEYLOC, SRA.RA_NOME NOME,	SRD.RD_FILIAL FILIAL,	SRD.RD_MAT MAT, "
cQuery	+= "   	   SRD.RD_PD PD,    SRD.RD_VNAOAPL VNAOAPL, SRD.RD_PERIODO PERIODO, SRD.RD_SEMANA SEMANA"
cQuery	+= "FROM "+RetSqlName("SRD")+ " SRD"
cQuery	+= " INNER JOIN "+RetSqlName("SRA")+ " SRA ON SRA.RA_FILIAL ='" +XFILIAL( "SRA", SRD->RD_FILIAL)+"' AND SRA.RA_MAT=SRD.RD_MAT"
cQuery	+= " WHERE" 
cQuery	+= " 		SRD.RD_SEMANA IN( "+ cPeriodsC +" ) "
cQuery	+= " 		AND SRD.RD_PERIODO =  '"+ cPeriodo +"' "
cQuery	+= " 		AND SRD.RD_PROCES IN( "+ cProceso +") "
cQuery	+= " 		AND SRD.RD_ROTEIR IN( "+ cNomina +") "

cQuery	+=If (empty(cSuc),    cSuc,    "AND "+ cSuc )
cQuery	+=If (empty(cMat),    cMat,    "AND "+ cMat )
cQuery	+=If (empty(cCC),     cCC,     "AND "+ cCC )
cQuery	+=If (empty(cDepto),  cDepto,  "AND "+cDepto )
cQuery	+=If (empty(cLoc),    cLoc,    "AND "+cLoc )

cConcep	:= StrTran(cConcep , "RC_", "RD_")
cQuery	+=If (empty(cConcep),    cConcep,    "AND "+cConcep )

cQuery	+= "        AND SRA.D_E_L_E_T_ <> '*'  "
cQuery	+= "        AND SRD.D_E_L_E_T_ <> '*'  "
cQuery	+= "        AND SRD.RD_VNAOAPL <> 0    "
cQuery	+= "        ) ROWS  "
cQuery	+= CORDER

      
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
RestArea( aArea )

Return ( Nil )


Static Function GetPeriods(cPeriodsO ,cPeriodsC )
//O=Abierto  C= Cerrado
Local cWhereRCH := 	""
Local cAliasRCH :=	CRIATRAB(NIL,.F.)


cWhereRCH:= "% "+IF(Empty(cProceso),cProceso," AND RCH.RCH_PROCES IN ("+ cProceso+")")
cWhereRCH+= " AND RCH.RCH_ROTEIR = " + cNomina + ""
cWhereRCH+= " AND RCH.RCH_NUMPAG = '"+ cNumpag + "'"
cWhereRCH+= " AND RCH.RCH_PER = '"+ cPeriodo+"'"
cWhereRCH+= " AND RCH.RCH_FILIAL ='"+XFILIAL("RCH")+"'"

cWhereRCH+= " %"
BeginSql alias cAliasRCH
	SELECT	 RCH.RCH_PER, RCH.RCH_NUMPAG,RCH.RCH_DTFECH           
	FROM 	%table:RCH% RCH    
	WHERE 	RCH.%notDel% 
	%exp:cWhereRCH%
	
EndSql 
dbSelectArea( cAliasRCH )
(cAliasRCH)->(DbGoTop()) 

If (cAliasRCH)->(!Eof())
	While (cAliasRCH)->(!Eof())
	If EMPTY((cAliasRCH)->RCH_DTFECH)
		cPeriodsO+="'"+(cAliasRCH)->RCH_NUMPAG+"',"
	Else	
		cPeriodsC+="'"+(cAliasRCH)->RCH_NUMPAG+"',"
	EndIf
		(cAliasRCH)->(dbSkip())
	EndDo

EndIf

(cAliasRCH)->(dbCloseArea()) 

Return ( Nil )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PrintReport�Autor � FMonroy               � Data � 03/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir el reporte de acuerdo a su definici�n.            ���  
���          �                                                            ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(oExp1)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  oExp1.-Objeto TReport                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER005COS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function PrintReport(oReport)       

Local nOrder:= oReport:Section(1):GetOrder() 
TodoOk()
getRows(nOrder) 	 
Do Case
	// Formato Anal�tico 
	Case nTipo==1 
		PrintANA1(oReport)   
	 // Formato Sint�tico 
	Case nTipo==2 
		PrintSIN1(oReport)
EndCase

(cAliasTmp)->(dbCloseArea()) 
Return ( Nil )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrintANA1 | Autor � FMonroy               � Data �08/08/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir Formato Anal�tico por Centro de Costos            ���
���Descri��o � o Departamento  o Localidad de Pago  o Nombre o Matricula  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �  PrintANA1(oExp1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  oExp1: Objeto TReport                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  GPER005COS                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function PrintANA1(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2) 
Local oSection3 := oReport:Section(3) 
Local oSection4 := oReport:Section(4) 
Local cCt       := ""
Local cSur      := ""
Local cConcepto := ""
Local cDepart   := ""
Local cKeyLoca  := ""
Local cFilSRV    := xfilial("SRV", SRC->RC_FILIAL)
Local cFilCTT    := xfilial("CTT", SRC->RC_FILIAL)
Local cFilSQB    := xfilial("SQB", SRC->RC_FILIAL)
Local cFilRCG    := xfilial("RCG", SRC->RC_FILIAL)
Local nAcum      := 0
Local nOrder:= oReport:Section(1):GetOrder()
Local nTotal    := 0

dbSelectArea( cAliasTmp )
count to nTotal
oReport:SetMeter(nTotal) 
(cAliasTmp)->(DbGoTop()) 
If (cAliasTmp)->(!Eof())
	//��������������������������������������������������������������������������������������������Ŀ
	//� Imprime Reporte Analitico Ordenado por Matricula o Nombre                                  �
	//���������������������������������������������������������������������������������������������� 
	If nOrder == 1 .Or. nOrder == 2

		While (cAliasTmp)->(!Eof()) 

			cMat:=(cAliasTmp)->MAT //Mismo concepto
			cConcepto:=(cAliasTmp)->PD //Mismo concepto
			oSection4:Init()
			nAcum:=0
			While (cAliasTmp)->(!Eof()) .And.  cMat==(cAliasTmp)->MAT //cConcepto==(cAliasTmp)->PD .And.
				//IMPRIMIR detalle
				
				oSection4:Cell("FIL"):SetValue((cAliasTmp)->FILIAL)
				oSection4:Cell("MAT"):SetValue((cAliasTmp)->MAT)
				oSection4:Cell("NOME"):SetValue((cAliasTmp)->NOME)
				oSection4:Cell("PD"):SetValue((cAliasTmp)->PD)
				oSection4:Cell("DESC"):SetValue(Posicione("SRV",1,CFILSRV+(cAliasTmp)->PD,"RV_DESC"))
				oSection4:Cell("IMP"):SetValue((cAliasTmp)->VNAOAPL)
				oSection4:Cell("PER"):SetValue((cAliasTmp)->PERIODO+Space(1)+(cAliasTmp)->SEMANA)
				
				oSection4:PrintLine()
				nAcum+=(cAliasTmp)->VNAOAPL
				(cAliasTmp)->(dbSkip())
				oReport:IncMeter() 
				
			EndDo
			//Totales
			oReport:SkipLine()
			oSection4:Cell("FIL"):SetValue(space(1))
			oSection4:Cell("MAT"):SetValue(space(1))
			oSection4:Cell("NOME"):SetValue(STR0015+Space(1)+cMat)//"Total Matricula"
			oSection4:Cell("PD"):SetValue(space(5))//(cConcepto)
			oSection4:Cell("DESC"):SetValue(space(1))//(Posicione("SRV",1,CFILSRV+cConcepto,"RV_DESC"))
			oSection4:Cell("IMP"):SetValue(nAcum)
			oSection4:Cell("PER"):SetValue(space(1))
			
			oSEction4:Printline()
			oSection4:Finish()
			
		EndDo
	//��������������������������������������������������������������������������������������������Ŀ
	//� Imprime Reporte Analitico Ordenado por Centro de Costos                                    �
	//���������������������������������������������������������������������������������������������� 
	ElseIf nOrder == 3
		While (cAliasTmp)->(!Eof()) 	
			cCt :=(cAliasTmp)->CC //Centro de Costo
			cSur:=(cAliasTmp)->FILIAL //Cambio de Sucursal
			cConcepto:=(cAliasTmp)->PD //Mismo concepto
			oSection1:Init()
			oSection1:Cell("CC"):SETTITLE(STR0007)//"Centro de Costos"
			oSection1:Cell("CC"):SETVALUE(Posicione("CTT",1,CFILCTT+(cAliasTmp)->CC,"CTT_DESC01"))
			oSection1:PrintLine()
			oSection1:Finish()
			oSection2:Init()
			nAcum:=0
			While (cAliasTmp)->(!Eof()) .And. cCt ==(cAliasTmp)->CC .and. cSur==(cAliasTmp)->FILIAL //.And.  cConcepto==(cAliasTmp)->PD 
				//IMPRIMIR detalle
				oSection2:Cell("FIL"):SetValue((cAliasTmp)->FILIAL)
				oSection2:Cell("MAT"):SetValue((cAliasTmp)->MAT)
				oSection2:Cell("NOME"):SetValue((cAliasTmp)->NOME)
				oSection2:Cell("PD"):SetValue((cAliasTmp)->PD)
				oSection2:Cell("DESC"):SetValue(Posicione("SRV",1,CFILSRV+(cAliasTmp)->PD,"RV_DESC"))
				oSection2:Cell("IMP"):SetValue((cAliasTmp)->VNAOAPL)
				oSection2:PrintLine()
				nAcum+=(cAliasTmp)->VNAOAPL
				(cAliasTmp)->(dbSkip())
				oReport:IncMeter() 
				
			EndDo
			//Totales
			oReport:SkipLine()
			oSection2:Cell("FIL"):SetValue(space(1))
			oSection2:Cell("MAT"):SetValue(space(1))
			oSection2:Cell("NOME"):SetValue(STR0016)//"Total Concepto"
			oSection2:Cell("PD"):SetValue(space(5))//(cConcepto)
			oSection2:Cell("DESC"):SetValue(space(1))//(Posicione("SRV",1,CFILSRV+cConcepto,"RV_DESC"))
			oSection2:Cell("IMP"):SetValue(nAcum)
			
			oSEction2:Printline()
			oSection2:Finish()
		EndDo	
		
	//��������������������������������������������������������������������������������������������Ŀ
	//� Imprime Reporte Analitico Ordenado por Departamento                                        �
	//���������������������������������������������������������������������������������������������� 		
	ElseIf nOrder == 4
		While (cAliasTmp)->(!Eof()) 	
			cDepart :=(cAliasTmp)->DEPTO //Departamento
			cSur:=(cAliasTmp)->FILIAL //Cambio de Sucursal
			cConcepto:=(cAliasTmp)->PD //Mismo concepto
			oSection1:Init()
			oSection1:Cell("CC"):SETTITLE(STR0017)//"Departamento"
			oSection1:Cell("CC"):SETVALUE(Posicione("SQB",1,CFILSQB+(cAliasTmp)->DEPTO,"QB_DESCRIC"))
			oSection1:PrintLine()
			oSection1:Finish()
			oSection2:Init()
			nAcum:=0
			While (cAliasTmp)->(!Eof()) .And. cDepart ==(cAliasTmp)->DEPTO .and. cSur==(cAliasTmp)->FILIAL //.And.  cConcepto==(cAliasTmp)->PD 
				//IMPRIMIR detalle
				oSection2:Cell("FIL"):SetValue((cAliasTmp)->FILIAL)
				oSection2:Cell("MAT"):SetValue((cAliasTmp)->MAT)
				oSection2:Cell("NOME"):SetValue((cAliasTmp)->NOME)
				oSection2:Cell("PD"):SetValue((cAliasTmp)->PD)
				oSection2:Cell("DESC"):SetValue(Posicione("SRV",1,CFILSRV+(cAliasTmp)->PD,"RV_DESC"))
				oSection2:Cell("IMP"):SetValue((cAliasTmp)->VNAOAPL)
				oSection2:PrintLine()
				nAcum+=(cAliasTmp)->VNAOAPL
				(cAliasTmp)->(dbSkip())
				oReport:IncMeter() 
				
			EndDo
			//Totales
			oReport:SkipLine()
			oSection2:Cell("FIL"):SetValue(space(1))
			oSection2:Cell("MAT"):SetValue(space(1))
			oSection2:Cell("NOME"):SetValue(STR0018)//"Total Concepto"
			oSection2:Cell("PD"):SetValue(space(5))//(cConcepto)
			oSection2:Cell("DESC"):SetValue(space(1))//(Posicione("SRV",1,CFILSRV+cConcepto,"RV_DESC"))
			oSection2:Cell("IMP"):SetValue(nAcum)
			
			oSEction2:Printline()
			oSection2:Finish()
		EndDo	
	//��������������������������������������������������������������������������������������������Ŀ
	//� Imprime Reporte Analitico Ordenado por Localidad de Pago                                   �
	//���������������������������������������������������������������������������������������������� 	
	ElseIf nOrder == 5
		While (cAliasTmp)->(!Eof()) 	
			cKeyLoca :=(cAliasTmp)->KEYLOC //Localidad de Pago
			cSur:=(cAliasTmp)->FILIAL //Cambio de Sucursal
			cConcepto:=(cAliasTmp)->PD //Mismo concepto
			oSection1:Init()
			oSection1:Cell("CC"):SETTITLE(STR0019)//"Localidad de Pago"
			oSection1:Cell("CC"):SETVALUE(Posicione("RGC",1,CFILRCG+(cAliasTmp)->KEYLOC,"RGC_DESLOC"))
			oSection1:PrintLine()
			oSection1:Finish()
			oSection2:Init()
			nAcum:=0
			While (cAliasTmp)->(!Eof()) .And. cKeyLoca ==(cAliasTmp)->KEYLOC .and. cSur==(cAliasTmp)->FILIAL //.And.  cConcepto==(cAliasTmp)->PD 
				//IMPRIMIR detalle
				oSection2:Cell("FIL"):SetValue((cAliasTmp)->FILIAL)
				oSection2:Cell("MAT"):SetValue((cAliasTmp)->MAT)
				oSection2:Cell("NOME"):SetValue((cAliasTmp)->NOME)
				oSection2:Cell("PD"):SetValue((cAliasTmp)->PD)
				oSection2:Cell("DESC"):SetValue(Posicione("SRV",1,CFILSRV+(cAliasTmp)->PD,"RV_DESC"))
				oSection2:Cell("IMP"):SetValue((cAliasTmp)->VNAOAPL)
				oSection2:PrintLine()
				nAcum+=(cAliasTmp)->VNAOAPL
				(cAliasTmp)->(dbSkip())
				oReport:IncMeter() 
				
			EndDo
			//Totales
			oReport:SkipLine()
			oSection2:Cell("FIL"):SetValue(space(1))
			oSection2:Cell("MAT"):SetValue(space(1))
			oSection2:Cell("NOME"):SetValue(STR0018)//Total Concepto
			oSection2:Cell("PD"):SetValue(space(5))//(cConcepto)
			oSection2:Cell("DESC"):SetValue(space(1))//(Posicione("SRV",1,CFILSRV+cConcepto,"RV_DESC"))
			oSection2:Cell("IMP"):SetValue(nAcum)
			
			oSEction2:Printline()
			oSection2:Finish()
		EndDo
	Endif

	
	

	
EndIf
Return ( Nil )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrintSIN1 | Autor � FMonroy               � Data �08/08/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir Formato Sint�tico por Centro de Costos            ���
���Descri��o � o Departamento o Localidad de Pago                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �  PrintSIN1(oExp1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  oExp1: Objeto TReport                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  GPER005COS                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function	PrintSIN1(oReport)
Local oSection1 := oReport:Section(1)
Local oSection3 := oReport:Section(3)
Local oSection4 := oReport:Section(4)

Local cCt       := ""
Local cSur      := ""
Local cConcepto := ""
Local cDepart   := ""
Local cKeyLoca  := ""
Local cFilSRV    := xfilial("SRV", SRC->RC_FILIAL)
Local cFilCTT    := xfilial("CTT", SRC->RC_FILIAL)
Local cFilSQB    := xfilial("SQB", SRC->RC_FILIAL)
Local cFilRCG    := xfilial("RCG", SRC->RC_FILIAL)
Local nAcum      := 0
Local nOrder:= oReport:Section(1):GetOrder()
Local nTotal    := 0

dbSelectArea( cAliasTmp )
count to nTotal
oReport:SetMeter(nTotal) 
(cAliasTmp)->(DbGoTop()) 
If (cAliasTmp)->(!Eof())
	//��������������������������������������������������������������������������������������������Ŀ
	//� Imprime Reporte Sintetico Ordenado por Matricula o Nombre                                  �
	//���������������������������������������������������������������������������������������������� 
	If nOrder == 1 .Or. nOrder== 2
		While (cAliasTmp)->(!Eof()) 
		
			cConcepto:=(cAliasTmp)->PD //Mismo concepto
			oSection4:Init()
			nAcum:=0 
			oSection4:Cell("PER"):SETTITLE(Space(1))
			oSection4:Cell("PER"):hide()
			While (cAliasTmp)->(!Eof()) .And. cConcepto==(cAliasTmp)->PD 
				//IMPRIMIR detalle
				oSection4:Cell("FIL"):SetValue((cAliasTmp)->FILIAL)
				oSection4:Cell("MAT"):SetValue((cAliasTmp)->MAT)
				oSection4:Cell("NOME"):SetValue((cAliasTmp)->NOME)
				oSection4:Cell("PD"):SetValue((cAliasTmp)->PD)
				oSection4:Cell("DESC"):SetValue(Posicione("SRV",1,CFILSRV+cConcepto,"RV_DESC"))
				oSection4:Cell("IMP"):SetValue((cAliasTmp)->VNAOAPL)
				
				oSection4:PrintLine()
				nAcum+=(cAliasTmp)->VNAOAPL
				(cAliasTmp)->(dbSkip())
				oReport:IncMeter() 
				
			EndDo
			//Totales
			oReport:SkipLine()
			oSection4:Cell("FIL"):SetValue(space(1))
			oSection4:Cell("MAT"):SetValue(space(1))
			oSection4:Cell("NOME"):SetValue(STR0018)//"Total Concepto"
			oSection4:Cell("PD"):SetValue(cConcepto)
			oSection4:Cell("DESC"):SetValue(Posicione("SRV",1,CFILSRV+cConcepto,"RV_DESC"))
			oSection4:Cell("IMP"):SetValue(nAcum)

			oSEction4:Printline()
			oSection4:Finish()
			
		EndDo
	//��������������������������������������������������������������������������������������������Ŀ
	//� Imprime Reporte Sintetico Ordenado por Centro de Costos + Matricula                        �
	//���������������������������������������������������������������������������������������������� 
	ElseIf nOrder == 3
	
		While (cAliasTmp)->(!Eof()) 
		
			cCt :=(cAliasTmp)->CC //Centro de Costo
			cConcepto:=(cAliasTmp)->PD //Mismo concepto
			oSection1:Init()
			oSection1:Cell("CC"):SETTITLE(STR0007)//"Centro de Costos"
			oSection1:Cell("CC"):SETVALUE(Posicione("CTT",1,CFILCTT+(cAliasTmp)->CC,"CTT_DESC01"))
			oSection1:PrintLine()
			oSection1:Finish()
			
		   oSection3:Init()
			While (cAliasTmp)->(!Eof()) .And.  cCt ==(cAliasTmp)->CC
				
				oSection3:Cell("PD"):SetValue((cAliasTmp)->PD )
				oSection3:Cell("DESC"):SetValue(Posicione("SRV",1,CFILSRV+(cAliasTmp)->PD,"RV_DESC"))
				oSection3:Cell("IMP"):SetValue((cAliasTmp)->VNAOAPL)
				oSection3:PrintLine()
				(cAliasTmp)->(dbSkip())
				oReport:IncMeter() 
				
			EndDo
			oSection3:Finish()
		EndDo
	//��������������������������������������������������������������������������������������������Ŀ
	//� Imprime Reporte Sintetico Ordenado por Deparatamento + Matricula                           �
	//���������������������������������������������������������������������������������������������� 
	ElseIf nOrder == 4
		While (cAliasTmp)->(!Eof()) 
		
			cDepart :=(cAliasTmp)->DEPTO //Departamento
			cConcepto:=(cAliasTmp)->PD //concepto
			oSection1:Init()
			oSection1:Cell("CC"):SETTITLE(STR0017)//"Departamento"
			oSection1:Cell("CC"):SETVALUE(Posicione("SQB",1,CFILSQB+(cAliasTmp)->DEPTO,"QB_DESCRIC"))
			oSection1:PrintLine()
			oSection1:Finish()

			oSection3:Init()
			While (cAliasTmp)->(!Eof()) .And.  cDepart ==(cAliasTmp)->DEPTO 
				
				oSection3:Cell("PD"):SetValue((cAliasTmp)->PD )
				oSection3:Cell("DESC"):SetValue(Posicione("SRV",1,CFILSRV+(cAliasTmp)->PD,"RV_DESC"))
				oSection3:Cell("IMP"):SetValue((cAliasTmp)->VNAOAPL)
				oSection3:PrintLine()
				(cAliasTmp)->(dbSkip())
				oReport:IncMeter() 
				
			EndDo
			oSection3:Finish()
		EndDo
	//��������������������������������������������������������������������������������������������Ŀ
	//� Imprime Reporte Sintetico Ordenado por Localidad de Pago + Matricula                       �
	//���������������������������������������������������������������������������������������������� 
	ElseIf nOrder == 5
		While (cAliasTmp)->(!Eof()) 

			cKeyLoca :=(cAliasTmp)->KEYLOC //Localidad de Pago
			cConcepto:=(cAliasTmp)->PD //Mismo concepto
			oSection1:Init()
			oSection1:Cell("CC"):SETTITLE(STR0019)//"Localidad de Pago"
			oSection1:Cell("CC"):SETVALUE(Posicione("RGC",1,CFILRCG+(cAliasTmp)->KEYLOC,"RGC_DESLOC"))
			oSection1:PrintLine()
			oSection1:Finish()

		   oSection3:Init()
			While (cAliasTmp)->(!Eof()) .And.  cKeyLoca ==(cAliasTmp)->KEYLOC
				
				oSection3:Cell("PD"):SetValue((cAliasTmp)->PD )
				oSection3:Cell("DESC"):SetValue(Posicione("SRV",1,CFILSRV+(cAliasTmp)->PD,"RV_DESC"))
				oSection3:Cell("IMP"):SetValue((cAliasTmp)->VNAOAPL)
				oSection3:PrintLine()
				(cAliasTmp)->(dbSkip())
				oReport:IncMeter() 
				
			EndDo	
			oSection3:Finish()			
		EndDo

	Endif
    
EndIf
Return( Nil )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TodoOK   � Autor � FMonroy               � Data � 03/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validar los par�metros de entrada                          ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TodoOK(cExp1)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1.-Nombre del grupo de preguntas                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER005COS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function TodoOK(cPerg)
Local lRet := .T.             
Pergunte(cPerg,.F.)

MakeSqlExpr("GPR005COS")  
cProceso	:=	ConvQry(MV_PAR01,"RA_PROCES")	//Parametro de Entrada: Lista de procesos pertenecientes a la empresa de la cual se generar� la declaraci�n	
cNomina		:=	ConvQry(MV_PAR02,"RC_ROTEIR")	//Parametro de Entrada: Lista de Tipos de N�mina disponibles, y permitir capturar uno, todos, o solo algunos tipos de n�mina. flistbox

cPeriodo	:=	MV_PAR03	//Parametro de Entrada: Rango de Periodos
cNumPag		:=	MV_PAR04	//Parametro de Entrada: Rango de N�mero de Pagos
cSuc		:=	MV_PAR05	//Parametro de Entrada: Rango de Sucursales
cMat		:=	MV_PAR06	//Parametro de Entrada: Rango de Matr�culas
cCC			:=	MV_PAR07	//Parametro de Entrada: Rango de Centro de Costos
cDepto		:=	MV_PAR08	//Parametro de Entrada: Rango de Departamentos
cLoc		:=	MV_PAR09	//Parametro de Entrasda: Rango de Localidades de Pago
cConcep		:=	MV_PAR10	//Parametro de Entrada: Rango de Conceptos
nTipo		:=	MV_PAR11	//Parametro de Entrada: 1 Sint�tico / 2 Anal�tico
	
Return ( lRet )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ConvQry   �Autor  �Microsiga           � Data �  27/05/11   ���
�������������������������������������������������������������������������͹��
���Descri��o �Convertir a expreci�n sql un campo informado con un listbox ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �   ConvQry(cExp,cExp1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�    cExp: Cadena de caracteres que retorna el litbox        ���
���          �    cExp1: Campo del diccionario de datos                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  GPER005COS                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ConvQry(cLista,cCampo)
Local cTxt:=''
Local nTamReg := TamSX3(cCampo)[1]
Local nCont:=0
/*
//���������������������������������������������������������������Ŀ
//�Genera texto para usar  para usar despues en Query             �
//�����������������������������������������������������������������
*/                 
cLista:=alltrim(cLista)

For nCont := 1 To Len( cLista ) Step nTamReg
    cTxt+="'"+SubStr( cLista , nCont , nTamReg )+"',"
NEXT       
cTxt:=substr(cTxt,1,len(cTxt)-1)                                   
Return ( cTxt )