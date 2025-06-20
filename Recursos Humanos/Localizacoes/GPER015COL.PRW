#INCLUDE "PROTHEUS.CH"   
#INCLUDE "report.ch"    
#INCLUDE "GPER015COL.ch" 

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������?
�����������������������������������������������������������������������������Ŀ�?
���Fun��o    �GPER015COL?Autor    �Miguel Angel Rojas G.   ?Data ?14.11.13 ��?
�����������������������������������������������������������������������������Ĵ�?
���Descri��o ?Comparativo por  Empleado - Concepto                           ��?
�����������������������������������������������������������������������������Ĵ�?
���Sintaxe   ?GPER015COL                                                     ��?
�����������������������������������������������������������������������������Ĵ�?
���Parametros?                                                               ��?
�����������������������������������������������������������������������������Ĵ�?
��?Uso      ?COLOMBIA                                                       ��?
�����������������������������������������������������������������������������Ĵ�?
��?        ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                 ��?
�����������������������������������������������������������������������������Ĵ�?
���Programador ?Data   ?BOPS     ? Motivo da Alteracao                     ��?
�����������������������������������������������������������������������������Ĵ�?
���MIGUEL ROJAS?4/01/14?         �Error query distintos periodos            ��?
���Jonathan glz?2/02/16�PCREQ-9393�Localizacion SIGAGPE v12 Colombia.        ��?
��?           ?       ?         �Se elimina la funciona RANGESX1 y se usa  ��?
��?           ?       ?         �la funcion MAKESQLEXPR() para tratar para-��?
��?           ?       ?         �metros tipo rango - funcion PrintReport   ��?
������������������������������������������������������������������������������ٱ?
��������������������������������������������������������������������������������?
��������������������������������������������������������������������������������?
/*/

Function GPER015COL()
 	Local		oReport                             
 	Local		aArea 			:= GetArea()
 	Private 	cString		:= GetNextAlias()				// Alias del Archivo Princial
 	Private 	lCorpManage	:= fIsCorpManage(FWGrpCompany())

 	If lCorpManage
		Private lEmpFil		:= !Empty(FWSM0Layout(cEmpAnt, 1))  
		Private cLayoutGC 	:= FWSM0Layout(cEmpAnt)
		Private nStartEmp	   	:= At("E",cLayoutGC)
		Private nStartUnN	   	:= At("U",cLayoutGC)
		Private nEmpLength   	:= Len(FWSM0Layout(cEmpAnt, 1))
		Private nUnNLength   	:= Len(FWSM0Layout(cEmpAnt, 2))
 	EndIf
 	oReport := ReportDef()
 	oReport:PrintDialog()
 	RestArea( aArea )
Return

/*/
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������Ŀ�?
���Fun��o    �ReportDef ?Autor ?Miguel Angel Rojas   ?Data ? 14.11.13 ��?
�������������������������������������������������������������������������Ĵ�?
���Descri��o ?Definici�n del Reporte                                     ��?
��������������������������������������������������������������������������ٱ?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
/*/
Static Function ReportDef()   
	Local oReport
 	Local oBreakPg                                    
 	Local oSection1
 	Local oSection2
 	Local cTitulo := STR0001
 	Local cPerg   := "GPER015COL"
 	Pergunte( cPerg , .F. )
	
	//Definici�n del Reporte
  	DEFINE REPORT oReport NAME "GPER015COL" TITLE OemToAnsi(cTitulo)  PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION ""
 	oReport:SetLandscape()
	//-- Datos del Empleado
	DEFINE SECTION oSection1 OF oReport TABLES "SRA" TITLE OemToAnsi(cTitulo) TOTAL IN COLUMN
	oSection1 :SetHeaderSection()
	//--- CELL HEADER BORDER
    	    DEFINE CELL NAME "RA_FILIAL"  	OF oSection1 ALIAS "SRA" TITLE oemToAnsi(STR0002)
		 	DEFINE CELL NAME "RA_MAT" 	    OF oSection1 ALIAS "SRA" SIZE 13 TITLE oemToansi(STR0003) 
			DEFINE CELL NAME "RA_NOME" 	    OF oSection1 ALIAS "SRA" TITLE oemToansi(STR0004) 
			DEFINE CELL NAME "RA_RG"			OF oSection1 ALIAS "SRA" TITLE oemToansi(STR0005)
			DEFINE CELL NAME "RA_CC"			OF oSection1 ALIAS  "SRA" SIZE 13 TITLE oemToansi(STR0006)
			DEFINE CELL NAME "RV_COD"		OF oSection1 Alias "SRV" SIZE 12 TITLE oemToAnsi(STR0007)
			DEFINE CELL NAME "RV_DESC"		OF oSection1 Alias "SRV" SIZE 18 TITLE oemToAnsi(STR0008)
			DEFINE CELL NAME "RD_ENTIDAD"	OF oSection1 ALIAS "SRA" TITLE oemToansi(STR0009)  
			
			//-- oSection2 Para encabezado cada que corte el reporte por Matr�cula
			DEFINE SECTION oSection2 		OF oSection1 TABLES " " TITLE " "
		    oSection2 :SetHeaderSection()
			
			//--- CELL HEADER BORDER
			//--- Datos del Empleado SRA  
			DEFINE CELL NAME "RA_FILIAL"  	OF oSection2 ALIAS "SRA" TITLE oemToAnsi(STR0002)
		 	DEFINE CELL NAME "RA_MAT" 	    OF oSection2 ALIAS "SRA" SIZE 13 TITLE oemToansi(STR0003) 
			DEFINE CELL NAME "RA_NOME" 	    OF oSection2 ALIAS "SRA" TITLE oemToansi(STR0004) 
			DEFINE CELL NAME "RA_RG"			OF oSection2 ALIAS "SRA" TITLE oemToansi(STR0005)
			
			//--- Se deshabilitan las celdas para evitar que se dupliquen en oSection1
			oSection1:Cell("RA_FILIAL"):Disable()
	        oSection1:Cell("RA_MAT"):Disable()
	        oSection1:Cell("RA_NOME"):Disable()
	        oSection1:Cell("RA_RG"):Disable()
			oSection1:Cell("RA_FILIAL"):Disable() 
Return oReport   

/*/
������������������������������������������������������������������������������?
������������������������������������������������������������������������������?
���������������������������������������������������������������������������ͻ�?
���Programa  �PrintReport �Autor  �Miguel Angel Rojas  ?Data ? 14/11/13   ��?
���������������������������������������������������������������������������͹�?
������������������������������������������������������������������������������?
������������������������������������������������������������������������������?
/*/
Static Function PrintReport(oReport)     
	//-- Objetos Section para armado de Reporte
  	Local oSection1 := oReport:Section(1) 		// Detalle
  	Local oSection2 := oReport:Section(1):Section(1) 		// Datos del Empleado
	//-- Variables
  	Local oValor1
  	Local oValor2
  	Local oSumVal
  	Local oBreakFil	   
  	Local oBreakEFilLocal
  	Local oTotFunc
  	Local cFiltro    		:= ""
  	Local cSitQuery  		:= ""
  	Local cCatQuery  		:= ""
 	Local cProdPagoQ 		:= ""
  	Local cQrySRA     		:= GetNextAlias()
  	Local cSucursal   	:= ""
  	Local cCentroCosto 	:= ""
  	Local cMatricula    	:= ""
  	Local cNombre    	   	:= ""
  	Local cSituacion   	:= MV_PAR05
  	Local cCategoria 		:= MV_PAR06
  	Local cConceptos  	:= ""
  	Local cProceso			:= MV_PAR08
  	Local cProcedimiento 	:= MV_PAR09
  	Local cPeriodo1 		:= MV_PAR10
  	Local cPago1 	  		:= MV_PAR11
  	Local cPeriodo2 		:= MV_PAR12
  	Local cPago2     		:= MV_PAR13
  	Local cPrefx     		:= "" 
  	Local cAliasAux  		:= ""
  	Local cPrefx2     		:= "" 
  	Local cAliasAux2  	:= ""
  	Local cTitEFil  		:= ""
  	Local cFilalAux 		:= ""
  	Local cStPer1 			:= ""
  	Local cStPer2 			:= ""
	//--- Bandera control de impresi�n si .T. se ejecutar?el reporte.
  	Local bImprimir 		:= .T.      
  	Local nValor1 			:= 0
  	Local nValor2 			:= 0
  	Local nHoras1 			:= 0
  	Local nHoras2 			:= 0
  	Local nDifHor 			:= 0
  	Local nDifVal 			:= 0
  	Local nPorCH  			:= 0
  	Local nPorCV  			:= 0
  	Local cFilImpr 		:= 0
  	Local cCod    			:= ""
  	Local nReg				:= 0
  	Local cFilialSRA 		:= xFilial("SRA")
  	Local cFilialSRV 		:= xFilial("SRV")
	//--- Variables para totalizar por empleado  
  	Local nSumVal1 		:= 0                   
  	Local nSumVal2 		:= 0
  	Local nTotalVal 		:= 0
	//--- Totales Generales  
  	Local nTotalVal1 		:= 0                 
  	Local nTotalVal2 		:= 0
  	Local nTotalGral 		:= 0

//������������������������������������������������������������������������Ŀ
//?Preguntas selecionadas - GPER015COL                                    ?
//��������������������������������������������������������������������������
 	Local cPerg   := "GPER015COL"
 	Pergunte( cPerg , .F. )

//������������������������������������������������������������������������Ŀ
//?Variable utilizadas para parametros                                    ?
//?mv_par01     // �Sucursal?                                             ?
//?mv_par02     // �Centro de Costos?                                     ?
//?mv_par03     // �Matr�cula?                                            ?
//?mv_par04     // �Nombre?                                               ?
//?mv_par05     // �Situaciones?                                          ?
//?mv_par06     // �Categor�as?                                           ?
//?mv_par07     // �Conceptos?                                            ?
//?mv_par08     // �Proceso?                                              ?
//?mv_par09     // �Procedimiento?                                        ?
//?mv_par10     // �Periodo 1?                                            ?
//?mv_par11     // �No. Pago 1?                                           ?
//?mv_par12     // �Periodo 2?                                            ?
//?mv_par13     // �No. Pago 2?                                           ?
//��������������������������������������������������������������������������
	MakeSqlExpr(cPerg)

  	cSucursal   	:= MV_PAR01
  	cCentroCosto 	:= MV_PAR02
  	cMatricula    := MV_PAR03
  	cNombre    	:= MV_PAR04
  	cConceptos  	:= MV_PAR07

	//������������������������������������������������Ŀ
	//?Verifica que los periodos y numeros de pago    ?
	//?sean distintos para hacer la comparaci�n,      ?
	//?si son iguales manda un    Aviso               ?
	//?informando que los periodos son iguales        ?
	//��������������������������������������������������
   	IF  cPeriodo1==cPeriodo2 .AND. cPago1 == cPago2     
    		Aviso( STR0024,STR0025+cPeriodo1+" "+cPago1, {"Ok"} )
     	 	bImprimir := .F.
   	Endif       

	//-- Filtro para Sucursales         
   	If !Empty(cSucursal)
        	cFiltro += " AND SRA."+ substr(cSucursal,2,len(cSucursal)-2)// Filtro Sucursal
   	EndIf

	//-- Filtro para Centro de Costos
   	If !Empty(cCentroCosto)
			cFiltro += " AND SRA."+ substr(cCentroCosto,2,len(cCentroCosto)-2)// Filtro de Centro de Costos
   	EndIf

	//-- Filtro para Matricula
   	If !Empty(cMatricula)
			cFiltro += " AND SRA."+ substr(cMatricula,2,len(cMatricula)-2)// Filtro Matricula
   	EndIf 
 	
	//--- Filtro Nombre 	
   	If !Empty(cNombre)
			cFiltro += " AND SRA."+ substr(cNombre,2,len(cNombre)-2)// Filtro Nombre
   	EndIF

	//-- Filtro para Situaciones
   	For nReg:=1 to Len(cSituacion)
			CSitQuery += "'"+Subs(cSituacion,nReg,1)+"'"
			If ( nReg+1 ) <= Len(cSituacion)
				cSitQuery += "," 
			Endif
   	Next nReg        
	
	//-- Filtro para Categorias	
   	cCategoria = Alltrim(cCategoria)                               
   	For nReg:=1 to Len(cCategoria)
     		cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	   		If ( nReg+1 ) <= Len(cCategoria)
				cCatQuery += "," 
	   		Endif
   	Next nReg

	//--- T�tulo a imprimir en el reporte 	
   	oReport:CTITLE := STR0001+" " +STR0020+cProcedimiento+" "+STR0021+" "+cPeriodo1+" "+cPago1+" "+STR0022+cPeriodo2+" "+cPago2 
	
	//������������������������������������������������Ŀ
	//?Verifica que exista el periodo en RCH y define ?
	//?que tabla se usar?SRC o SRD, en caso de que   ?
	//?no se encuentren datos manda un                ?
	//?Aviso informando que no hay datos a comparar   ?
	//��������������������������������������������������
 
	//--- Si los Periodos son Distintos vefica que el Primer Periodo Exista en la tabla RCH  
   	If bImprimir      
     	Dbselectarea("RCH")                                                 
	 	RCH ->(DBSETORDER(1)) 
	 	RCH ->(	Dbseek(xFilial("RCH")+cProceso+cPeriodo1+cPago1+cProcedimiento)) // Determina si el Periodo 1 esta Abierto o Cerrado
	
	 	IF (EMPTY(RCH->RCH_DTFECH) .AND.(!EOF()))                                 
			cPrefx    	:= "RC"    //  Valor si es periodo1 abierto
			cAliasAux 	:= "SRC"
			cStPer1 	:="A"
	 	ELSE
	    	IF !EOF()
		  		cPrefx    	:= "RD"    //  Valor si es periodo1 cerrado 
		  		cAliasAux 	:= "SRD"
		  		cStPer1 	:="C"
		  		bImprimir 	:= .t.
	    	ELSE
		  		bImprimir := .f.  // Si no encuentra datos en RCH manda un Aviso
		  		Aviso( STR0024,STR0023+cPeriodo1+" "+cPago1, {"Ok"} )
			ENDIF
     	ENDIF
   	ENDIF   ///   Fin de Vericiacion del Periodo 1 en RCH  

	//--- Si el Periodo 1 existe, verifica que el Periodo 2 exista en RCH  
   	IF bImprimir   
    	RCH ->(DBSETORDER(1)) 
	  	RCH ->(	Dbseek(xFilial("RCH")+cProceso+cPeriodo2+cPago2+cProcedimiento)) // Determina si el Periodo 2 esta Abierto o Cerrado
   
     	IF EMPTY(RCH->RCH_DTFECH) .AND.(!EOF())                                
			cPrefx2   	:= "RC"    //  Valor si es periodo2 abierto
			cAliasAux2	:= "SRC"
			cStPer2 	:="A"
 	 	ELSE
			IF !EOF()
		  		cPrefx2   	:= "RD"    //  Valor si es periodo2 cerrado 
		  		cAliasAux2	:= "SRD"
		  		cStPer2 	:= "C"
			ELSE
		  		bImprimir := .f.     // Si no encuentra datos en RCH manda un Aviso
		  		Aviso( STR0024,STR0023+cPeriodo2+" "+cPago2, {"Ok"} )
			ENDIF
	 	ENDIF
   	ENDIF     /// Fin de verificaci�n Periodo 2 en RCH

	//--- Valida que existan datos en los periodos
  	IF bImprimir         
	//--- Arma el Query para el primer periodo
     	cQuery := "SELECT  RV_COD,RV_DESC,RA_FILIAL,RA_MAT,RA_NOME,RA_RG, RA_CC,"+cPreFx+"_ENTIDAD AS ENTIDAD, "+cPreFx+"_HORAS, "+cPreFx+"_VALOR" 
     	cQuery += "	FROM "+ RetSqlName("SRV")+ " SRV, "	+ RetSqlName("SRA") + " SRA "
     	cQuery += "	INNER JOIN " + RetSqlName(cAliasAux) + " "+cAliasAux+" ON "
	 	cQuery += "           "+cAliasAux+"."+cPrefx+"_FILIAL     = SRA.RA_FILIAL       AND "
	 	cQuery += "			  "+cAliasAux+"."+cPrefx+"_MAT        = SRA.RA_MAT         AND " 
	 	cQuery += "	  		  ("+cAliasAux+"."+cPrefx+"_PERIODO    = '"+cPeriodo1+"')  AND " 
	 	cQuery += "	  		  ("+cAliasAux+"."+cPrefx+"_SEMANA    = '"+cPago1+"')  AND "
	 	cQuery += "	   		  "+cAliasAux+"."+cPrefx+"_ROTEIR     = '"+cProcedimiento+"'     AND "
	
		If !Empty(cConceptos)
	   		cCpto := cAliasAux+"."+cPreFx+"_PD"  + substr(cConceptos, 8 , len(cConceptos)-8)// Filtro Conceptos
       		cQuery += cCpto + "  AND"
    	endif 
    
    	cQuery += "	         "+cAliasAux+".D_E_L_E_T_ = ' ' "		 
    	cQuery += "		WHERE SRA.RA_SITFOLH	IN	("+cSitQuery+") 	AND "
    	cQuery += "       SRV.RV_COD ="+cAliasAux+"."+cPrefx+"_PD     AND  "
    	cQuery += "			  SRA.RA_CATFUNC	IN	("+cCatQuery+") 	AND " 
		cQuery += "			  SRA.RA_PROCES      =  '"+cProceso+"' 	AND "
		cQuery +="       SRV.RV_FILIAL = '"+cFilialSRV+"'            AND  "
    	cQuery +="       SRA.RA_FILIAL = '"+cFilialSRA+"'            AND  "
		cQuery += "	 		  SRA.D_E_L_E_T_     = ' '       AND "
		cQuery += "	 		  SRV.D_E_L_E_T_     = ' '      "
    	IF !EMPTY(cFiltro)    // Agrega los filtros al Query
	    		cQuery += cFiltro
		ENDIF
		cQuery 		:= ChangeQuery(cQuery) 
		
		IF Select(cQrySRA) > 0
				(cQrySRA)->( DBCLOSEAREA() )
		ENDIF   
		nReg := 0
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySRA)
		Count to nReg 
	
    	IF nReg == 0     
        		Aviso( STR0024,STR0023+cPeriodo1+" "+cPago1, {"Ok"} )
       			bImprimir := .f.
				//--- Valida si Existen datos en el segundo Periodo     
    	else  
				//--- Armado del Query para el periodo 2  
       			(cQrySRA)->( DBCLOSEAREA() )  
        		cQuery := "SELECT  RV_COD,RV_DESC,RA_FILIAL,RA_MAT,RA_NOME,RA_RG, RA_CC,"+cPreFx2+"_ENTIDAD AS ENTIDAD, "+cPreFx2+"_HORAS, "+cPreFx2+"_VALOR"
        		cQuery += "	FROM "+ RetSqlName("SRV")+ " SRV, "	+ RetSqlName("SRA") + " SRA "
        		cQuery += "	INNER JOIN " + RetSqlName(cAliasAux2) + " "+cAliasAux2+" ON "
	    		cQuery += "           "+cAliasAux2+"."+cPrefx2+"_FILIAL     = SRA.RA_FILIAL       AND " 
	    		cQuery += "			  "+cAliasAux2+"."+cPrefx2+"_MAT        = SRA.RA_MAT         AND " 
	    		cQuery += "	  		  ("+cAliasAux2+"."+cPrefx2+"_PERIODO    = '"+cPeriodo2+"')  AND " 
	    		cQuery += "	  		  ("+cAliasAux2+"."+cPrefx2+"_SEMANA    = '"+cPago2+"')  AND "
	    		cQuery += "	   		  "+cAliasAux2+"."+cPrefx2+"_ROTEIR     = '"+cProcedimiento+"'     AND "
		
	    		If !Empty(cConceptos)
	      			cCpto := cAliasAux2+"."+cPreFx2+"_PD" + substr(cConceptos, 8 , len(cConceptos)-8)// Filtro Conceptos
          			cQuery += cCpto + "  AND"
        		endif 
    	
        		cQuery += "	         "+cAliasAux2+".D_E_L_E_T_ = ' ' "		 
        		cQuery += "		WHERE SRA.RA_SITFOLH	IN	("+cSitQuery+") 	AND "
        		cQuery += "       SRV.RV_COD ="+cAliasAux2+"."+cPrefx2+"_PD     AND  "
        		cQuery += "			  SRA.RA_CATFUNC	IN	("+cCatQuery+") 	AND " 
	    		cQuery += "			  SRA.RA_PROCES      =  '"+cProceso+"' 	AND "
	    		cQuery += "       SRV.RV_FILIAL = '"+cFilialSRV+"'            AND  "
        		cQuery += "       SRA.RA_FILIAL = '"+cFilialSRA+"'            AND  "
	    		cQuery += "	 		  SRA.D_E_L_E_T_     = ' '      AND"
	    		cQuery += "	 		  SRV.D_E_L_E_T_     = ' '      "
        		IF !EMPTY(cFiltro)    // Agrega los filtros al Query
	    			cQuery += cFiltro
	    		ENDIF
        		cQuery 		:= ChangeQuery(cQuery) /// Carga Query
        		IF Select(cQrySRA) > 0
		 			(cQrySRA)->( DBCLOSEAREA() )
	    		ENDIF   
	    		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySRA)
	    		nReg := 0
	    		Count to nReg    
        		If nReg == 0       
          			Aviso( STR0024,STR0023+cPeriodo2+" "+cPago2, {"Ok"} )
        			bImprimir := .f.
      			Else    
					//--- Si existen Datos en ambos periodos cambia el status de bImprimir para que se ejecute el reporte
       				(cQrySRA)->( DBCLOSEAREA() )
         			bImprimir := .t.
         			cQueryB := cQuery     
     			Endif  
    	Endif
  	Endif   /// Fin de validaci�n de datos en los periodos
     
	//--- Arma el Query para el Informe si los dos periodos tienen datos para comparar     
  	If bImprimir
		DEFINE CELL NAME "REFPER1"    	OF oSection1 ALIAS cString TITLE oemToansi(STR0010) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "VALORPER1"  	OF oSection1 ALIAS cString TITLE oemToansi(STR0011) SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "REFPER2"    	OF oSection1 ALIAS cString TITLE oemToansi(STR0012) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "VALORPER2"  	OF oSection1 ALIAS cString TITLE oemToansi(STR0013) SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "DIF_HORAS"  	OF oSection1 ALIAS cString TITLE oemToansi(STR0014) SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "PORC_HORAS" 	OF oSection1 ALIAS cString TITLE oemToansi(STR0015) SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "DIF_VALOR"  	OF oSection1 ALIAS cString TITLE oemToansi(STR0016) SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
		DEFINE CELL NAME "PORC_VALOR" 	OF oSection1 ALIAS cString TITLE oemToansi(STR0017) SIZE 15 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT

		//--- Armado de Query si los datos estan en la misma tabla (SRD ?SRC) dependiendo si los periodos estan abiertos o cerrados   
    	If cStPer1 == cStPer2
        		cQuery := " SELECT  RV_COD,RV_TIPOCOD,RV_DESC,RA_FILIAL,RA_MAT,RA_NOME,RA_RG, RA_CC,"+cPreFx+"_ENTIDAD  AS ENTIDAD "
        		cQuery += ", SUM(CASE WHEN "+cPreFx+"_PERIODO = '"+cPeriodo1+"' AND "+cPreFx+"_SEMANA = '"+cPago1+"' THEN "+cPreFx+"_HORAS ELSE 0 END) AS REFPER1"  //Column 09                        
	    		cQuery += ", SUM(CASE WHEN "+cPreFx+"_PERIODO = '"+cPeriodo1+"' AND "+cPreFx+"_SEMANA = '"+cPago1+"' THEN "+cPreFx+"_VALOR ELSE 0 END) AS REFVAL1 " //Column 10	
	    		cQuery += ", SUM(CASE WHEN "+cPreFx2+"_PERIODO = '"+cPeriodo2+"' AND "+cPreFx2+"_SEMANA = '"+cPago2+"' THEN "+cPreFx2+"_HORAS ELSE 0 END)AS REFPER2 " 	//Column 11
	    		cQuery += ", SUM(CASE WHEN "+cPreFx2+"_PERIODO = '"+cPeriodo2+"' AND "+cPreFx2+"_SEMANA = '"+cPago2+"' THEN "+cPreFx2+"_VALOR ELSE 0 END)AS REFVAL2 "  //Column 12
        		cQuery += "	FROM "+ RetSqlName("SRV")+ " SRV, "	+ RetSqlName("SRA") + " SRA "
	    		cQuery += "	INNER JOIN " + RetSqlName(cAliasAux) + " "+cAliasAux+" ON "
	    		cQuery += "           "+cAliasAux+"."+cPrefx+"_FILIAL     = SRA.RA_FILIAL      AND "
	    		cQuery += "			  "+cAliasAux+"."+cPrefx+"_MAT        = SRA.RA_MAT         AND " 
	    		cQuery += "	  		  ("+cAliasAux+"."+cPrefx+"_PERIODO    = '"+cPeriodo1+"' OR "+cAliasAux+"."+cPrefx2+"_PERIODO    = '"+cPeriodo2+"')     AND " 
	    		cQuery += "	   		  "+cAliasAux+"."+cPrefx+"_ROTEIR     = '"+cProcedimiento+"'              AND "
				//--- Filtro Conceptos	    
	    		cCpto := cAliasAux+"."+cPreFx+"_PD" + substr(cConceptos, 8 , len(cConceptos)-8)
        		If !Empty(cConceptos)
	       			cCpto := cAliasAux2+"."+cPreFx2+"_PD" + substr(cConceptos, 8 , len(cConceptos)-8)
           			cQuery += cCpto + "  AND"
         		endif

         		cQuery += "	   		  "+cAliasAux+".D_E_L_E_T_ = ' ' "
         		cQuery += "		WHERE SRA.RA_SITFOLH	IN	("+cSitQuery+") 	AND "
         		cQuery += "      SRV.RV_COD ="+cAliasAux+"."+cPreFX+"_PD    AND"		      
    	Else
    			//--- Armado de Query si los datos se encuentran en diferentes tablas (SRD y SRC) dependiendo cual periodo esta abierto y cual cerrado
	    		cQuery :=" SELECT RV_COD,RV_TIPOCOD, RV_DESC,RA_FILIAL,RA_MAT,RA_NOME,RA_RG,RA_CC,ENTIDAD,REFPER1,REFVAL1,REFPER2,REFVAL2 "
        		cQuery +="            FROM "+ RetSqlName("SRV")+ " SRV, "	+ RetSqlName("SRA") + " SRA,( "		
        		cQuery +=" SELECT "+cPreFx+"_PD AS CODIGO,"+cPreFx+"_MAT AS MATRICULA,"+cPreFX+"_ENTIDAD AS ENTIDAD,"
        		cQuery +=" SUM("+cPreFx+"_HORAS) AS REFPER1,"
        		cQuery +=" SUM("+cPreFX+"_VALOR) AS REFVAL1,"
        		cQuery +=" SUM("+cPreFX2+"_HORAS) AS REFPER2,"
        		cQuery +=" SUM("+cPreFX2+"_VALOR) AS REFVAL2"
        		cQuery +="  FROM  "+RetSqlName(cAliasAux)+" "+cAliasAux+"   LEFT OUTER JOIN  "+RetSqlName(cAliasAux2)+" "+cAliasAux2
        		cQuery +="  ON   "+cPreFX+"_PD = "+cPreFX2+"_PD"
        		cQuery +="  AND  "+cPreFX+"_MAT = "+cPreFX2+"_MAT"
        		cQuery +="  AND  "+cPreFX2+"_PERIODO = '"+cPeriodo2+"'"
        		cQuery +="  AND  "+cPreFX2+"_SEMANA = '"+cPago2+"'"
        		cQuery +="  AND  "+cPreFX2+"_ROTEIR = '"+cProcedimiento+"'"
        		cQuery +="  AND  "+cPreFX2+"_FILIAL = '"+cFilialSRA+"'"
        		cQuery +="  AND  "+cAliasAux2+".D_E_L_E_T_ = ' ' "
        		cQuery +="  WHERE "+cPreFX+"_PERIODO = '"+cPeriodo1+"'"
        		cQuery +="  AND  "+cPreFX+"_SEMANA = '"+cPago1+"'"
        		cQuery +="  AND  "+cPreFX+"_ROTEIR = '"+cProcedimiento+"'"
        		cQuery +="  AND  "+cPreFX+"_FILIAL = '"+cFilialSRA+"'"
        		cQuery +="  AND  "+cPreFX2+"_VALOR IS NULL"
				//--- Filtro Conceptos	            
        		If !Empty(cConceptos)
	       			cCpto := cAliasAux+"."+cPreFx+"_PD"  + substr(cConceptos, 8 , len(cConceptos)-8)
           			cQuery +=" AND "+ cCpto 
           		Endif

        		cQuery +="  AND  "+cAliasAux+".D_E_L_E_T_ = ' ' "
        		cQuery +=" GROUP BY "+cPreFX+"_PD,"+cPreFX+"_MAT,"+cPreFX+"_ENTIDAD"  
        		cQuery +="  UNION ALL"
        		cQuery +=" SELECT "+cPreFx2+"_PD AS CODIGO,"+cPreFx2+"_MAT AS MATRICULA,"+cPreFX2+"_ENTIDAD AS ENTIDAD,"
        		cQuery +=" SUM("+cPreFx+"_HORAS) AS REFPER1,"
        		cQuery +=" SUM("+cPreFX+"_VALOR) AS REFVAL1,"
        		cQuery +=" SUM("+cPreFX2+"_HORAS) AS REFPER2,"
        		cQuery +=" SUM("+cPreFX2+"_VALOR) AS REFVAL2"
        		cQuery +="  FROM  "+RetSqlName(cAliasAux2)+" "+cAliasAux2+"   LEFT OUTER JOIN  "+RetSqlName(cAliasAux)+" "+cAliasAux
        		cQuery +="  ON   "+cPreFX+"_PD = "+cPreFX2+"_PD"
        		cQuery +="  AND  "+cPreFX+"_MAT = "+cPreFX2+"_MAT"
        		cQuery +="  AND  "+cPreFX+"_PERIODO = '"+cPeriodo1+"'"
        		cQuery +="  AND  "+cPreFX+"_SEMANA = '"+cPago1+"'"
        		cQuery +="  AND  "+cPreFX+"_ROTEIR = '"+cProcedimiento+"'"
        		cQuery +="  AND  "+cPreFX+"_FILIAL = '"+cFilialSRA+"'"
        		cQuery +="  AND  "+cAliasAux+".D_E_L_E_T_ = ' ' "
        		cQuery +="  WHERE "+cPreFX2+"_PERIODO = '"+cPeriodo2+"'"
        		cQuery +="  AND  "+cPreFX2+"_SEMANA = '"+cPago2+"'"
        		cQuery +="  AND  "+cPreFX2+"_ROTEIR = '"+cProcedimiento+"'"
				//--- Filtro Conceptos	            
        		If !Empty(cConceptos)
	       			cCpto := cAliasAux2+"."+cPreFx2+"_PD"  + substr(cConceptos, 8 , len(cConceptos)-8)
           			cQuery += " AND "+cCpto 
        		Endif

        		cQuery +="  AND  "+cPreFX2+"_FILIAL = '"+cFilialSRA+"'"
        		cQuery +="  AND  "+cAliasAux2+".D_E_L_E_T_ = ' '"
        		cQuery +="  GROUP BY "+cPreFX2+"_PD,"+cPreFX2+"_MAT,"+cPreFX2+"_ENTIDAD) cResult"
        		cQuery +="	 WHERE SRA.RA_MAT = MATRICULA   AND  SRV.RV_COD = CODIGO "  
       			cQuery +="  AND  SRA.RA_SITFOLH	IN	("+cSitQuery+") 	AND "
    	Endif  // Fin de comparaci�n si son Diferentes periodos
        cQuery +="       SRV.RV_FILIAL = '"+cFilialSRV+"'            AND  "
        cQuery +="       SRA.RA_FILIAL = '"+cFilialSRA+"'            AND  " 
        cQuery += "			  SRA.RA_CATFUNC	IN	("+cCatQuery+") 	  AND " 
	    cQuery += "			  SRA.RA_PROCES      =  '"+cProceso+"'  AND "
	    cQuery += "	 		  SRA.D_E_L_E_T_     = ' '      AND"
	    cQuery += "	 		  SRV.D_E_L_E_T_     = ' '      "
		//--- Agrega los filtros al Query    
   		If !EMPTY(cFiltro)    
	    		cQuery += cFiltro
		Endif
	 		
		If cStPer1 == cStPer2
	    		cQuery += " GROUP BY RV_COD,RV_TIPOCOD,RV_DESC,RA_FILIAL,RA_MAT,RA_NOME,RA_RG, RA_CC,"+cPreFx+"_ENTIDAD "
		Endif
		cQuery += "  ORDER BY RA_FILIAL,RA_MAT,RV_COD"
    	cQuery := ChangeQuery(cQuery) 	
    	IF Select(cQrySRA) > 0
				(cQrySRA)->( DBCLOSEAREA() )		
    	ENDIF
    	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySRA)
    	nReg := 0
    	Count to nReg
		If lCorpManage  
				//--- Totales por Empleado (Neto)
        		DEFINE BREAK oBreakEFil OF oReport WHEN oSection2:Cell("RA_MAT")
				DEFINE FUNCTION oValor1 FROM oSection1:Cell("VALORPER1")  FUNCTION ONPRINT  OF oSection1 FORMULA {|| nSumVal1 } BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
				DEFINE FUNCTION oValor2 FROM oSection1:Cell("VALORPER2" ) FUNCTION ONPRINT  OF oSection1 FORMULA {|| nSumVal2 } BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
				DEFINE FUNCTION oSumVal FROM oSection1:Cell("DIF_VALOR" ) FUNCTION ONPRINT  OF oSection1 FORMULA {|| ntotalVal } BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
				oBreakEFil:OnBreak({ |x,y| cTitEFil := Space(70) + OemToAnsi(STR0018)})	
	    		oBreakEFil:SetTotalText({ || cTitEFil })
	    		oBreakEFil:SetTotalInLine(.F.)
	    
				//--- Total General
	    		DEFINE BREAK oBreakFil OF oReport WHEN oSection1:Cell("RA_FILIAL")
	    		DEFINE FUNCTION NAME "VALORPER1"  FROM oSection1:Cell("VALORPER1" ) FUNCTION ONPRINT  FORMULA {|| nTotalVal1 }   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
				DEFINE FUNCTION NAME "VALORPER2"  FROM oSection1:Cell("VALORPER2" ) FUNCTION ONPRINT  FORMULA {|| nTotalVal2 }   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
				DEFINE FUNCTION NAME "DIF_VALOR"  FROM oSection1:Cell("DIF_VALOR" ) FUNCTION ONPRINT  FORMULA {|| nTotalGral }   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
				oBreakFil:OnBreak({ |x,y| cTitEFil := OemToAnsi(STR0019)})	
	    		oBreakFil:SetTotalText({ || cTitEFil })
	    		oBreakFil:SetTotalInLine(.F.)
		EndIf
		//--- Obtiene Cantidad de registros a imprimir  y se posiciona en el primer registro del archivo de datos
		oReport:SetMeter(nReg)
   		( cQrySRA )->(DBGOTOP()) 
		//--- Inicializa Variables para control de totales en Cortes
    	nSumaVal1 := 0
    	nSumaVal2 := 0
    	nTotalVal := 0
    	cCod 	   := ""
		//--- Impresi�n del reporte
    	WHILE ( cQrySRA )->(!eof())
       			oReport:IncMeter()                     
				//--- Pasa los datos del Empleado a las variables para imprimir.
       			cFilImpr 	:= ( cQrySRA )->(RA_FILIAL)
       			cCodImpr 	:= ( cQrySRA )->(RV_COD)
       			cDescImp 	:= ( cQrySRA )->(RV_DESC)
       			cMatImpr 	:= ( cQrySRA )->(RA_MAT)
       			cNomImpr 	:= ( cQrySRA )->(RA_NOME)
       			cNITImpr 	:= ( cQrySRA )->(RA_RG)
       			cCCImpr 	:= ( cQrySRA )->(RA_CC)
       			cEntImpr 	:= ( cQrySRA )->(ENTIDAD)
       			nHoras1	:= ( cQrySRA )->(REFPER1)
       			nValor1	:= ( cQrySRA )->(REFVAL1)
       			nHoras2	:= ( cQrySRA )->(REFPER2)
       			nValor2	:= ( cQrySRA )->(REFVAL2)
				//--- Calcula la Diferencia de Horas y Valor del Periodo 2 con el Periodo 1       
       			nDifHor 	:= nHoras2 - nHoras1               
       			nDifVal := nValor2 - nValor1               
				//--- Calculo de % Diferencia en horas y valor
       			If nHoras1 <> 0                 
         			nPorCH 	:= (((nHoras2 / nHoras1)) - 1)*100
       			Else
         			nPorCH := 0
       			Endif
       			If nValor1 <> 0                 
         			nPorCV  := (((nValor2 / nValor1)) - 1)*100
       			Else
         			nPorCV := 0
       			Endif
				//--- Pasamos los valores a Imprimir a las Celdas
       			oSection2:cell("RA_FILIAL"):SetValue(cFilImpr)           
       			oSection2:cell("RA_MAT"):SetValue(cMatImpr)
       			oSection2:cell("RA_NOME"):SetValue(cNomImpr)
       			oSection2:cell("RA_RG"):SetValue(cNITImpr)
       			oSection1:cell("RV_COD"):SetValue(cCodImpr)
       			oSection1:cell("RV_DESC"):SetValue(cDescImp)
       			oSection1:cell("RA_CC"):SetValue(cCCImpr)
       			oSection1:cell("RD_ENTIDAD"):SetValue(cEntImpr)
       			oSection1:cell("DIF_HORAS"):SetValue(nDifHor)
       			oSection1:cell("DIF_VALOR"):SetValue(nDifVal)
       			oSection1:cell("REFPER1"):SetValue(nHoras1)
       			oSection1:cell("REFPER2"):SetValue(nHoras2)
       			oSection1:cell("VALORPER1"):SetValue(nValor1)
       			oSection1:cell("VALORPER2"):SetValue(nValor2)
       			oSection1:cell("PORC_VALOR"):SetValue(nPorCV)
       			oSection1:cell("PORC_HORAS"):SetValue(nPorCH)
				//--- Condiciones para totalizar por Empleado
       			If cCod == (cQrySRA)->(RA_MAT)        
					//--- Si TipoCod = '1' suma el contenido de RD_VALOR al acumulado del empleado       
         			If ( cQrySRA )->(RV_TIPOCOD) =='1'    
          				nSumVal1 := nSumVal1 + nValor1       
          				nSumVal2 := nSumVal2 + nValor2
         			Else
						//--- Si TipoCod = '2' resta el contenido de RD_VALOR al acumulado del empleado         
          				If ( cQrySRA )->(RV_TIPOCOD) =='2'
           					nSumVal1 := nSumVal1 - nValor1      
           					nSumVal2 := nSumVal2 - nValor2
          				Endif                                    
         			Endif 
       			Endif
				//--- Control del Corte por Matr�cula    
       			If cCod <> (cQrySRA)->(RA_MAT)
         			nTotalVal 	:= ( nSumVal2 - nSumVal1)
         			oSection2:Init()
         			oSection2:PrintLine()
         			oSection2:Finish()
         			oSection1:Finish()
         			cCod 		:= (cQrySRA)->(RA_MAT)         			
         			nTotalVal1	:= nTotalVal1 + nSumVal1                 
         			nTotalVal2	:= nTotalVal2 + nSumVal2
         			nTotalGral	:= nTotalGral + nTotalVal
         			nSumVal1	:= nValor1
         			nSumVal2	:= nValor2
       			endif
       			oSection1:Init()
       			oSection1:PrintLine()
      			( cQrySRA )->(dbSkip())
    	ENDDO  
		//--- Finaliza el reporte    
    	oSection1:Finish()                          
		//--- Imprime Totales Generales    
   		nTotalVal 	:= (nSumVal2 - nSumVal1)       
   		nTotalVal1	:= nTotalVal1 + nSumVal1                 
    	nTotalVal2	:= nTotalVal2 + nSumVal2
    	nTotalGral	:= nTotalGral + nTotalVal
  	endif  /// Endif de la validacion de periodos  
Return NIL
