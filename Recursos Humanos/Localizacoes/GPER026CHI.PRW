#Include "PROTHEUS.CH"
#Include "RPTDEF.CH"
#Include "TBICONN.CH"
#Include "GPER026CHI.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n   �GPER026CHI� Autor � alfredo.medrano     � Data � 09/09/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Reporte de Vacaciones (Chile)                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER026CHI()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generar el informe de Vacaciones                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador   � Data   � BOPS/FNC  �  Motivo da Alteracao              ���
�������������������������������������������������������������������������Ĵ��
���M.Camargo     �09/06/15�TSMFU7     �Se agregan columnas Dias Prop,esta-���
���              �09/06/15�TSMFU7     �tus y sandos pendientes.           ���
���Jonathan Glez �24/11/15�PCREQ-7944 �Localizacion CHI v12, modificacion ���
���              �        �           �en funcion ReportPrint, se agrega  ���
���              �        �           �SetMeter para definir de manera co-���
���              �        �           �rrecta la regla de avance          ���
���M.Camargo     �15/04/16�TUZJKU     �Se coloca picture campos numericos ���
���              �        �           �con 2 decimales                    ���
���M.Camargo     �15/04/16�TVCL20     �Se coloca picture campos numericos ���
���              �        �           �con 2 decimales.                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GPER026CHI()
Local		oReport   
Local		aArea 		:= GetArea()
Private 	cTitulo		:= OemToAnsi(STR0001)
Private 	aOrdem    	:= {}
Private 	cPerg   	:= "GPER026CHI"

If FindFunction("TRepInUse") .And. TRepInUse()
	//����������������������������������������Ŀ
	//� Verifica las perguntas selecionadas    �
	//������������������������������������������
	pergunte(cPerg,.F.) 
	
   	oReport := ReportDef()
   	oReport:PrintDialog()
EndIF    

RestArea( aArea )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GPER0025DH� Autor � Alfredo Medrano       � Data �09/09/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Reporte de Vacaciones                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER0025DH()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPER0025CN                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport 
Local oSection 

///������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
	oReport:= TReport():New("GPER026CHI",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},"") 
	oReport:SetLandscape() 		
	oReport:SetTotalInLine(.F.) //True = imprime totalizadores 
	oReport:nFontBody	:= 9 	//Tama�o fuente del documento
	oReport:nLineHeight	:= 38 	//Altura de linea 
	oReport:nColSpace	:= 1 	//Espacio entre las columnas de informaci�n
	oReport:ShowHeader()		//imprimir el encabezado del informe (por default)
	oReport:cFontBody	:= "COURIER NEW" // tipo de letra
	
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//� Sessao 1  (oSection)                                          			 �
//��������������������������������������������������������������������������
	oSection :=TRSection():New(oReport,OemToAnsi(STR0015),"SRF") //Filial
	oSection :SetHeaderBreak(.F.) //Muestra el encabezado de la secci�n
	oSection :SetHeaderSection(.F.) 
	oSection:SetLineBreak(.F.) //.T. imprime una o mas lineas - .F.= no imprime linea  
	
//������������������������������������������������������������������������Ŀ
//�Cria��o da celulas da se��o do relat�rio									 �
//� 																				 �
//� TRCell():New 																	 �	
//� ExpO1 : Objeto TSection que a secao pertence                     		 �
//� ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado     		 �
//� ExpC3 : Nome da tabela de referencia da celula              			 �
//� ExpC4 : Titulo da celula                                     			 � 
//� Default : X3Titulo() 														 �
//� ExpC5 : Picture 																 �
//� Default : X3_PICTURE															 �
//� ExpC6 : Tamanho																 �
//� Default : X3_TAMANHO															 �
//� ExpL7 : Informe se o tamanho esta em pixel								 �
//� Default : False																 �		
//� ExpB8 : Bloco de c�digo para impressao.									 �
//� Default : ExpC2																 �
//��������������������������������������������������������������������������

	TRCell():New(oSection,'RF_FILIAL',			'SRF',	'',/*Picture*/,50,		/*lPixel*/,/*{|| code-block de impressao }*/) //fILIAL

//������������������������������������������������������������������������Ŀ
//� Sessao 1  (oSection)                                          			 �
//��������������������������������������������������������������������������
	oSection1 :=TRSection():New(oReport,OemToAnsi(STR0016),{"SRF","SRA"}) //"Filia - Matricula y Nombre"
	oSection1 :SetHeaderBreak(.F.) //Muestra el encabezado de la secci�n
	oSection1 :SetHeaderSection(.F.) 
	oSection1:SetLineBreak(.F.) //.T. imprime una o mas lineas - .F.= no imprime linea 
	TRCell():New(oSection1,'RF_FILIAL'	,''		,''						,/*Picture*/,TamSx3("RF_MAT")[1]	, /*lPixel*/,/*{|| code-block de impressao }*/) //FILIAL 
	TRCell():New(oSection1,'SRTEMPL'	,''		,OemToAnsi(STR0013)	,/*Picture*/,10     					, /*lPixel*/,/*{|| code-block de impressao }*/) //MATRICULA
	TRCell():New(oSection1,'RF_MAT'		,'SRF'	,OemToAnsi(STR0013)	,/*Picture*/,TamSx3("RF_MAT")[1]	, /*lPixel*/,/*{|| code-block de impressao }*/) //MATRICULA
	TRCell():New(oSection1,'RA_NOME'	,'SRA'	,OemToAnsi(STR0011)	,/*Picture*/,TamSx3("RA_NOME")[1]	, /*lPixel*/,/*{|| code-block de impressao }*/) //NOMBRE
	

//������������������������������������������������������������������������Ŀ
//� Sessao 2  (oSection)                               	                   �
//��������������������������������������������������������������������������
	oSection2 := TRSection():New(oReport,OemToAnsi(STR0017),{"SRF","SRV"})//"Detalle de Vacaciones"
	oSection2:SetHeaderPage()
	oSection2:SetLineBreak(.F.) //.T. imprime una o mas lineas - .F.= no imprime linea   
	oSection2:SetLineBreak(.F.) //.T. imprime una o mas lineas - .F.= no imprime linea  
	TRCell():New(oSection2,'RF_FILIAL'	,''		,  	OemToAnsi(STR0015),/*Picturae*/	,TamSx3("RF_FILIAL")[1]+10	,	/*lPixel*/,/*{|| code-block de impressao }*/) //Filial
	TRCell():New(oSection2,'RF_PD'		,'SRF'	,	OemToAnsi(STR0002),/*Picture*/	,TamSx3("RF_PD")[1]	+13		,	/*lPixel*/,/*{|| code-block de impressao }*/) //Concepto
	TRCell():New(oSection2,'RV_DESC'	,'SRV'	,	OemToAnsi(STR0003),/*Picture*/	,TamSx3("RV_DESC")[1]+5		,	/*lPixel*/,/*{|| code-block de impressao }*/) //Descripci�n
	TRCell():New(oSection2,'RF_DATABAS'	,'SRF'	,	OemToAnsi(STR0004),/*Picture*/	,TamSx3("RF_DATABAS")[1]+10 ,	/*lPixel*/,/*{|| code-block de impressao }*/) //"Fecha Inicio"
	TRCell():New(oSection2,'RF_DATAFIM'	,'SRF'	,	OemToAnsi(STR0005),/*Picture*/	,TamSx3("RF_DATAFIM")[1]+10 ,	/*lPixel*/,/*{|| code-block de impressao }*/) //"Fecha Fin"
	TRCell():New(oSection2,'RF_DIASDIR'	,'SRF'	,	OemToAnsi(STR0006),  "@E 9999.99"  	,TamSx3("RF_DIASDIR")[1],	/*lPixel*/,/*{|| code-block de impressao }*/) //"D�as Vacaciones"
	TRCell():New(oSection2,'RF_DFERVAT'	,'SRF'	,	OemToAnsi(STR0007),  "@E 9999.99"  	,TamSx3("RF_DFERVAT")[1] +10,	/*lPixel*/,/*{|| code-block de impressao }*/) //"D�as Derecho"
	TRCell():New(oSection2,'RF_DFERAAT'	,'SRF'	,	OemToAnsi(STR0018),  "@E 9999.99"  	,TamSx3("RF_DFERAAT")[1] +10,	/*lPixel*/,/*{|| code-block de impressao }*/) //"D�as Proporcionales"		
	TRCell():New(oSection2,'RF_DIASANT'	,'SRF'	,	OemToAnsi(STR0008),  "@E 9999.99"  	,TamSx3("RF_DIASANT")[1] +13,	/*lPixel*/,/*{|| code-block de impressao }*/) //"D�as Anticipados"
	TRCell():New(oSection2,'RF_DFERANT'	,'SRF'	,	OemToAnsi(STR0009),  "@E 9999.99"  	,TamSx3("RF_DFERANT")[1] +13,	/*lPixel*/,/*{|| code-block de impressao }*/) //"D�as Reducidos"
	TRCell():New(oSection2,'RFTOT'			,''		,	OemToAnsi(STR0010),  "@E 9999.99"  	,TamSx3("RF_DFERANT")[1] +13,	/*lPixel*/,/*{|| code-block de impressao }*/) //"Pendientes"
	TRCell():New(oSection2,'ESTDESC'  		,''		,	OemToAnsi(STR0019),/*Picture*/	,25						,	/*lPixel*/,/*{|| code-block de impressao }*/) //Descripci�n
			
  	oSection3 := TRSection():New(oSection2,'',{"SRF"}) 
	oSection3 :SetHeaderPage()
	oSection3 :SetTotalInLine(.F.)         
	TRCell():New(oSection3,'SALTOT'	,''		,  	'',	,100		,	/*lPixel*/,/*{|| code-block de impressao }*/) //FilialADM
		                                                                                  
Return(oReport)



/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint � Autor �Alfredo Medrano      � Data �10/09/2014  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportPrint devera ser criada para todos    ���
���          �os relatorios que poderao ser agendados pelo usuario.         ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ReportDef                                                    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)
	Local	aArea 	:= getArea() 
	Local oSection	:= oReport:Section(1)
	Local oSection1	:= oReport:Section(2)
	Local oSection2	:= oReport:Section(3)
	Local oSection3	:= oReport:Section(3):Section(1)
	Local cAliasBus	:= criatrab( nil, .f. )
	Local cQuery 	:= ""
	Local cSuc   	:= ""   
	Local cPro   	:= "" 
	Local cEmp   	:= "" 
	Local cMaT		:= ""
	Local cFil 		:= ""
	Local cEmpresa	:= ""
	Local cCiudad 	:= ""
	Local cFilEmp	:= ""
	Local cStatus	:= ""
	Local nSalPen	:= 0
	Local nData		:= 0
	Local NSit		
	Local cSith		:= ""
	
	//convierte parametros tipo Range a expresion sql
	//si esta separa por "-" agrega un BETWEEN,  si esta separado por ";" agrega un IN
			
	MakeSqlExpr("GPER026CHI")
	
	cSuc := trim(MV_PAR01) //Sucursal 
	cPro := trim(MV_PAR02) //Proceso                 
	cEmp := trim(MV_PAR03) //Empleados           
	nSit := MV_PAR04
	 
	//Se filtran los datos de las tablas SRF, SRV(Conceptos), SRA (Empleados)
	cQuery := " SELECT  RF_FILIAL,RF_MAT,RF_PD,RF_DATABAS, RF_DATAFIM,RF_DIASDIR,"
	cQuery += " RF_DFERVAT,RF_DIASANT,RF_DFERANT,RF_STATUS,RF_DFERAAT, RV_DESC,RA_NOME"
	cQuery += " FROM " + RetSqlName("SRF") + " SRF, "
	cQuery += 	  RetSqlName("SRV") + " SRV, "
	cQuery += 	  RetSqlName("SRA") + " SRA, "
	cQuery += " WHERE RV_COD = RF_PD AND RF_MAT = RA_MAT "
	If	!Empty( cSuc )	
		cQuery += " AND " + cSuc 
	EndIf
	If	!Empty( cPro )
		cQuery += " AND " + cPro 
	EndIf
	If	!Empty( cEmp )
		cQuery += " AND " + cEmp 
	EndIf
	cQuery += " AND RF_FILIAL 	= '" + XFILIAL('SRF') + "' "
	cQuery += " AND RV_FILIAL 	= '" + XFILIAL('SRV') + "' "
	cQuery += " AND RA_FILIAL	= '" + XFILIAL('SRA') + "' "     

	If nSit == 1
		cQuery += " AND RA_SITFOLH <> 'D' " 
	ElseIf nSit == 2
		cQuery += " AND RA_SITFOLH = 'D' " 
	EndIF 	
	                                 
	cQuery += " AND SRF.D_E_L_E_T_ 	= ' ' "
	cQuery += " AND SRV.D_E_L_E_T_ 	= ' ' "
	cQuery += " AND SRA.D_E_L_E_T_ 	= ' ' "
	cQuery += " ORDER BY RF_FILIAL, RF_MAT, RF_DATABAS"

	cQuery := ChangeQuery(cQuery)   	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBus,.T.,.T.)
	TCSetField(cAliasBus,"RF_DATABAS","D",8,0) // Formato de fecha 
	TCSetField(cAliasBus,"RF_DATAFIM","D",8,0) // Formato de fecha 
	Count to nTotalR
	oReport:SetMeter(nTotalR)
	(cAliasBus)->(dbgotop())//primer registro de tabla
	
//������������������������������������������������Ŀ
//� Se genera la consulta y se recorren   		  �
//� los datos del array obtenidos en ( cAliasBus ) �
//��������������������������������������������������

	WHILE ( cAliasBus )->(!eof())
		oReport:IncMeter()
		If oReport:Cancel() //termina proceso si se cancela el reporte
			Exit
		EndIf
		
			cFilEmp  := POSICIONE( "SM0", 1,SM0->M0_CODIGO + ( cAliasBus )->RF_FILIAL, "M0_FILIAL" ) //obtiene la filial 
			cEmpresa := POSICIONE( "SM0", 1,SM0->M0_CODIGO + ( cAliasBus )->RF_FILIAL, "M0_NOMECOM" )//obtiene Empresa
			cCiudad  := POSICIONE( "SM0", 1,SM0->M0_CODIGO + ( cAliasBus )->RF_FILIAL, "M0_CIDCOB" ) //obtiene la ciudad
			
			Do case
				Case ( cAliasBus )->RF_STATUS $ "1"
					cStatus := STR0020
					nSalPen+= ( cAliasBus )->RF_DFERVAT + ( cAliasBus )->RF_DIASANT  - ( cAliasBus )->RF_DFERANT
					nData := ( cAliasBus )->RF_DFERVAT + ( cAliasBus )->RF_DIASANT  - ( cAliasBus )->RF_DFERANT
				Case ( cAliasBus )->RF_STATUS $ "2"
					cStatus := STR0021
					nData := 0
				Case ( cAliasBus )->RF_STATUS $ "3"
					cStatus := STR0022
					nData := 0
			End Case
			
			If cFil == ( cAliasBus )->RF_FILIAL
				If cMat != ( cAliasBus )->RF_MAT 
					oReport:SkipLine() 
					oSection1:Init()
					oSection1:cell("SRTEMPL"):SetValue(OemToAnsi(STR0011)) //Empleado
					oSection1:cell("RF_MAT"):SetValue(( cAliasBus )->RF_MAT)
					oSection1:cell("RA_NOME"):SetValue(( cAliasBus )->RA_NOME)
					oSection1:PrintLine()
				
				End If
					
				oSection2:cell("RF_PD"):SetValue(( cAliasBus )->RF_PD)
				oSection2:cell("RV_DESC"):SetValue(( cAliasBus )->RV_DESC)
				oSection2:cell("RF_DATABAS"):SetValue(( cAliasBus )->RF_DATABAS)
				oSection2:cell("RF_DATAFIM"):SetValue(( cAliasBus )->RF_DATAFIM)
				oSection2:cell("RF_DIASDIR"):SetValue(( cAliasBus )->RF_DIASDIR)
				oSection2:cell("RF_DFERAAT"):SetValue(( cAliasBus )->RF_DFERAAT)
				oSection2:cell("RF_DFERVAT"):SetValue(( cAliasBus )->RF_DFERVAT)
				oSection2:cell("RF_DIASANT"):SetValue(( cAliasBus )->RF_DIASANT)
				oSection2:cell("RF_DFERANT"):SetValue(( cAliasBus )->RF_DFERANT)
				oSection2:cell("RFTOT"):SetValue(nData)
				oSection2:cell("ESTDESC"):SetValue(cStatus)				
				oSection3:cell("SALTOT"):SetValue(STR0023 + Transform(nSalPen,"@E 999.99"))	
			Else
				oSection:Init()
				oSection:cell("RF_FILIAL"):SetValue(Alltrim(( cAliasBus )->RF_FILIAL) + " - " + Alltrim(cFilEmp))
				oSection:PrintLine()
				oSection1:Init()
				oSection1:cell("SRTEMPL"):SetValue(OemToAnsi(STR0011)) //Empleado
				oSection1:cell("RF_MAT"):SetValue(( cAliasBus )->RF_MAT)
				oSection1:cell("RA_NOME"):SetValue(( cAliasBus )->RA_NOME)
				oSection1:PrintLine()
	
				oSection2:cell("RF_PD"):SetValue(( cAliasBus )->RF_PD)
				oSection2:cell("RV_DESC"):SetValue(( cAliasBus )->RV_DESC)
				oSection2:cell("RF_DATABAS"):SetValue(( cAliasBus )->RF_DATABAS)
				oSection2:cell("RF_DATAFIM"):SetValue(( cAliasBus )->RF_DATAFIM)
				oSection2:cell("RF_DIASDIR"):SetValue(( cAliasBus )->RF_DIASDIR)
				oSection2:cell("RF_DFERAAT"):SetValue(( cAliasBus )->RF_DFERAAT)
				oSection2:cell("RF_DFERVAT"):SetValue(( cAliasBus )->RF_DFERVAT)
				oSection2:cell("RF_DIASANT"):SetValue(( cAliasBus )->RF_DIASANT)
				oSection2:cell("RF_DFERANT"):SetValue(( cAliasBus )->RF_DFERANT)
				oSection2:cell("RFTOT"):SetValue(nData)
				oSection2:cell("ESTDESC"):SetValue(cStatus)	
				oSection3:cell("SALTOT"):SetValue(STR0023 + STR(nSalPen))	
			End If
			
			cFil := ( cAliasBus )->RF_FILIAL
			cMat := ( cAliasBus )->RF_MAT 
			
			oSection2:Init()
			oSection2:PrintLine()
			oSection:Finish()
			oSection2:Finish()
			oSection1:Finish()
		
		cMat :=  ( cAliasBus )->RF_MAT 			
		( cAliasBus )->(dbSkip())
		If cMat <> ( cAliasBus )->RF_MAT 
			oSection3:Init()
			oSection3:PrintLine()
			oSection3:Finish()
			nSalPen := 0
		EndIf
	ENDDO
	
	( cAliasBus )->(dbCloseArea())
	restArea(aArea)
	
Return