#INCLUDE "PROTHEUS.CH"
#INCLUDE "SCOPECNT.CH"
#INCLUDE "GPEXFUNPAR.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |GPEXFUNPARºAutor  ³Laura Medina        º Data ³ 15/01/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Contiene funciones auxiliares en la localización de GPE     º±±
±±º          ³para PARAGUAY.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³Merge                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DiasFerParºAutor  ³Laura Medina        º Data ³ 15/01/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Función para obtener los días derecho para Paraguay.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ DiasFerPar(cFilSRA,cMat,cPdSRF,dDateIni                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cFilSRA     = Filial del empleado                          º±±
±±º          ³ cMat        = Matrícula                         	  	    º±±
±±º          ³ cPdSrf      = Concepto de días Derecho                     º±±
±±º          ³ dDateIni    = Fecha de Admisión del empleado               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gpea010Grv()                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DiasFerPar(cProces, dFcRecon, dAdmissa, cGpoVac)  
Local aArea	    := GetArea()
Local cCalend   := ""
Local nDiasVac  := 0
Local nAntigTot := ""
Local nAux01    := 0
Default cProces := ""
Default dFcRecon:= CTOD("//")
Default dAdmissa:= CTOD("//")
Default cGpoVac := ""

DbSelectArea( "RCJ" )
DbSetOrder( RetOrdem( "RCJ", "RCJ_FILIAL+RC_CODIGO" ) )
If  MsSeek( xFilial("RCJ") + cProces, .F. )
	If !Eof()
		cCalend := RCJ->RCJ_CALEND 
	EndIf
Endif

If  !Empty(dFcRecon) 
	dAntig := dFcRecon
Else 
	dAntig := dAdmissa                             
EndIf

If  cCalend == "1"
	nDiasAntig := Dias360(dAntig, dDatabase)
	nAntigTot  := nDiasAntig / 360 
Else
	nDiasAntig := dDatabase - dAntig + 1 
	nAntigTot  := nDiasAntig / 365
Endif  

nAux01 := FPOSTAB("S013", cGpoVac, "=", 4, nAntigTot, "<=",7)
If  nAux01 > 0 
	nDiasVac := FTABELA("S013",nAux01,8)
Endif


RestArea( aArea )

Return nDiasVac 


/*/{Protheus.doc} Dias360
Devuelve el salario y actualiza los campos necesarios. 
@author Laura Medina
@since 10/01/2020
@version 12.1.25  	
@return 	nSalario	Numerico	Salario (RA_SALARIO).  
/*/
Function fSal_PAR()
Local aArea		:= GetArea()
Local dAntig    := CTOD("//")
Local nFacCon   := 0 
Local cCalend   := ""
Local nAntigTot := 0
Local cCodFunc  := "" 
Local cCatFunc  := ""
Local cProces   := ""
Local nSalario  := 0
Local cPer      := ""
Local cNumPag   := ""
Local nAux01    := 0
Local nSalMes   := 0
Local nSalDia   := 0
Local lPer      := .T.
Local dFcRecon  := CTOD("//")
Local dFcAdmis  := CTOD("//")
Local nPorcen   := 0
Local dFcTemRCH := CTOD("//")
Local dFcIniRCH := CTOD("//")
Local dFcAniver := CTOD("//") 
Local dFcNasc   := CTOD("//")
Local nSalTemp  := 0

nSalario  := If( IsMemVar( "RA_SALARIO" ), GetMemVar( "RA_SALARIO" ) , SRA->RA_SALARIO)
cCodFunc  := If( IsMemVar( "RA_CODFUNC" ), GetMemVar( "RA_CODFUNC" ), SRA->RA_CODFUNC)
cCatFunc  := If( IsMemVar( "RA_CATFUNC" ), GetMemVar( "RA_CATFUNC" ), SRA->RA_CATFUNC)
cProces   := If( IsMemVar( "RA_PROCES" ),  GetMemVar( "RA_PROCES" ), SRA->RA_PROCES )
dFcRecon  := If( IsMemVar( "RA_DTREC" ),   GetMemVar( "RA_DTREC" ), SRA->RA_DTREC)
dFcAdmis  := If( IsMemVar( "RA_ADMISSA" ), GetMemVar( "RA_ADMISSA" ), SRA->RA_ADMISSA )
dFcNasc   := If( IsMemVar( "RA_NASC" ) ,   GetMemVar( "RA_NASC" ), SRA->RA_NASC ) 

If  Empty(dFcRecon)
	dAntig  := dFcAdmis
Else
	dAntig  := dFcRecon
Endif 

DbSelectArea( "RCJ" )
DbSetOrder( RetOrdem( "RCJ", "RCJ_FILIAL+RC_CODIGO" ) )
If  MsSeek( xFilial("RCJ") + cProces, .F. )
	If !Eof()
		cCalend := RCJ->RCJ_CALEND 
	EndIf
Endif

If  cCalend == "1"
	nDiasAntig := Dias360(dAntig, dDatabase)
	nAntigTot  := nDiasAntig / 360 
Else
	nDiasAntig := dDatabase - dAntig + 1 
	nAntigTot  := nDiasAntig / 365
Endif  

//Obtener Periodo y Numero de Pago 
cRetPer := Gp010RetCont("RCH_PER", NIL, cProces, @lPer )
If lPer
	cPer  := cRetPer
EndIf
cRetPer := Gp010RetCont("RCH_NUMPAG", NIL, cProces, @lPer )
If lPer
	cNumPag  := cRetPer
Endif
dFcTemRCH := Gp010RetCont("RCH_DTFIM", NIL, cProces, @lPer )
If lPer
	dFcIniRCH:= dFcTemRCH
Endif


//Determinar el % del salario mínimo con el que se compara

//1) Si Ley del primer empleo, Jornalero, Mensualista >= 100%
IF cCatFunc $ "1|D|M" 
   nPorcen  := 1
ENDIF

//2) Si Ley Empleo Juvenil (menor de edad, aprendiz)– Práctica Laboral >= 60%
dFcAniver :=  CTOD(STRZERO(DAY(dFcNasc),2) +"/" + STRZERO(MONTH(dFcNasc),2)+ "/" + ALLTRIM(STR(YEAR(dFcNasc)+18))) 
If  dFcIniRCH < dFcAniver .OR. cCatFunc $ "E|3"   //Menor de edad o E=Aprendiz o 3=Ley Empleo Juvenil – Práctica Laboral
	nPorcen := 0.60
Endif

//3) Si Ley de Empleo Juvenil – Capacitación Laboral y  Si Ley de Empleo Juvenil – Aprendizaje >= 70%
If  cCatFunc $ "2|5"
	nPorcen := 0.70
Endif

//4) Si Ley de Empleo Juvenil – Beca de Trabajo >= 25%
If  cCatFunc == "4" 
	nPorcen := 0.25
Endif

//5) Si Ley Empleo Juvenil - Primer Empleo Juvenil >= 65%
If  cCatFunc == "6" 
	nPorcen := 0.65
Endif

//6) Si Honorarios o Destajista >=0 %
If  cCatFunc $ "A|T"
	nPorcen := 0.00
Endif

DbSelectArea( "SRJ" )
DbSetOrder( RetOrdem( "SRJ", "SRJ_FILIAL+SRJ_FUNCAO" ) )
If  MsSeek( xFilial("SRJ") + cCodFunc )

	//Tomar de la tabla de Categorías (SRJ)
	If  SRJ->RJ_SALANT == "2" .AND. SRJ->RJ_SALTAR == "2" 
		nSalTemp := (SRJ->RJ_SALARIO * nPorcen)
		If  nSalario < 	nSalTemp				
			M->RA_SALARIO := nSalTemp
		Endif
		
    //Tomar de la tabla de Salario x Antiguedad (S003) 
    ElseIf  SRJ->RJ_SALANT == "1"   
    	nAux01 := FPOSTAB("S003", cCodFunc, "=", 4, nAntigTot, "<=",7)
    	If nAux01 > 0 
    		nSalTemp := FTABELA("S003",nAux01,8) * nPorcen
    		If  nSalario < nSalTemp	
    			M->RA_SALARIO := nSalTemp
    		Endif
    	Else
    		M->RA_SALARIO := 0
    	Endif
	      
    //Tomar de la tabla de Salario x Tareas (S070)
    ElseIf  SRJ->RJ_SALTAR == "1"    
    	IF  nSalario <> 0
		       M->RA_SALARIO := 0
		Endif
		M->RA_CATFUNC := "T"
	Endif 	
	M->RA_SALMES  := M->RA_SALARIO
	M->RA_SALDIA  := Iif(M->RA_SALARIO>0,Iif(SRJ->RJ_FACCON>0,M->RA_SALARIO / SRJ->RJ_FACCON,0) ,0)				
Endif

If !Inclui 
    M->RA_FECAUM  := CTOD("//")
    M->RA_TIPOALT := "004"
    M->RA_PERAUM  := cPer
    M->RA_PAGAUM  := cNumPag
    M->RA_DATAALT := Ddatabase 
Endif

nSalario := M->RA_SALARIO 

RestArea( aArea )
Return( nSalario )


/*/{Protheus.doc} Dias360
Devuelve la cantidad de días entre dos fechas basándose en un año de 360 días (12 meses de 30 días)
@author Laura Medina
@since 13/01/2020
@version 12.1.25
@param 		dFchIni		Date		Fecha de Antiguedad (inicial).
@param 		dFchFin		Date		Fecha actual (final).   	
@return 	nDias360	Numerico	Numero de días entre las 2 fechas, en un año de 360 días.  
/*/
Function Dias360(dFchIni, dFchFin)  //01/10/2007, 13/01/2020 
Local nDias360  := 0
Local nAnoFcIni := 0
Local nAnoFcFin := 0 
Local nAnoTotal := 0
Local nMesFcIni := 0
Local nMesFcFin := 0
Local nMesTotal := 0
Local nDayFcIni := 0 
Local nDayFcFin := 0 
Local nDayTotal := 0


Default dFchIni := CTOD("//")  
Default dFchFin := CTOD("//")   


//Año 
nAnoFcIni := YEAR(dFchIni)
nAnoFcFin := YEAR(dFchFin)

//Mes
nMesFcIni := MONTH(dFchIni)
nMesFcFin := MONTH(dFchFin)

//Día 
nDayFcIni := DAY(dFchIni)
nDayFcFin := DAY(dFchFin)

nDayFcIni := If(nDayFcIni>30, 30, Iif(nMesFcIni == 2 .And. (nDayFcIni == 28 .OR. nDayFcIni == 29), 30, nDayFcIni))
nDayFcFin := If(nDayFcFin>30, 30, Iif(nMesFcFin == 2 .And. (nDayFcFin == 28 .OR. nDayFcFin == 29), 30, nDayFcFin))

nDayTotal := nDayFcFin - nDayFcIni  //13 - 01 = 12

If  nDayTotal < 0  //Días en negativo 
	nDayFcFin += 30
	nDayTotal := nDayFcFin - nDayFcIni 
	nMesFcFin -= 1 
Endif

nMesTotal := nMesFcFin - nMesFcIni  //01 - 10 = -09

If  nMesTotal < 0  //Días en negativo 
	nMesFcFin += 12
	nMesTotal := nMesFcFin - nMesFcIni 
	nAnoFcFin -= 1 
Endif

nAnoTotal := nAnoFcFin - nAnoFcIni  //2020 - 2007 = 13

nDias360 := nDayTotal + ( nMesTotal * 30) + (nAnoTotal * 360) 


Return nDias360

/*/{Protheus.doc} GpexAusent
Genera archivo PRX para la tabla RCM a partir de a rutina de Conceptos
Genera el archivo GPRCMPAR a partir de la  Tabla de Tipos de Ausentimos (RCM).

La funcionalidad se movió al fuente GPEXFUMI

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@param cPath, caracter, directorio donde se generara el archivo
@param aListaArch, arreglo, lista de archivos que se han generado
@example
GpexAusent(cPath, aListaArch)
/*/
Function GpexAusent(cPath, aListaArch)

	Local cFuncion		:= "GPEXGERRCM"
	
	Default cPath		:= ""
	Default aListaArch	:= {}

	IIf(FindFunction(cFuncion), GpexGerRCM(cPath, aListaArch), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return(NIL)

/*/{Protheus.doc} fCargRCM
Carga los Registros de la Tabla de Tipos de Ausentimos RCM a partir de conceptos

La funcionalidad se movió al fuente GPEXFUMI

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@example
fCargRCM()
/*/
Function fCargRCM()

	Local cFuncion	:= "GPEXCRGRCM"

	IIf(FindFunction(cFuncion), GpexCrgRCM(), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return(NIL)

/*/{Protheus.doc} GerGpexRGX

Genera archivo PRX para la tabla RG5, RG6 y RG9 a partir de a rutina de Conceptos por proceso.
Genera el archivo GPRGX + cPaisLoc y GPRG9 + cPaisLoc a partir de la  Tabla de estandar de 
periodos y Criterios de Acumulación (RG5,RG6 y RG9).

Se mueve funcionalidad a GPEXFUMI debido que aplica para todo MI.

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@archivo utilizado	RCM
/*/
Function GerGpexRGX(cPath, aListaArch)

	Local cFuncion	:= "GPEXRGXMI"

	IIf(FindFunction(cFuncion), GpexRGXMI(cPath, aListaArch), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return (Nil)

/*/{Protheus.doc} fCargRGX
Carga los Registros de las Tablas de Estandar de Periodos RG5 y RG6 a partir de conceptos por procesos

Se mueve funcionalidad a GPEXFUMI debido que aplica para todo MI.

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@archivo utilizado	GPRGX + cPaisLoc + .PRX 
/*/
Function fCargRGX()

	Local cFuncion	:= "GPEXCRGRGX"

	IIf(FindFunction(cFuncion), GpexCrgRGX(), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return (Nil)

/*/{Protheus.doc} Carga RG9
Carga los Registros de la Tabla de Criterios de Acumulación RG9 a partir de conceptos por procesos.

Se mueve funcionalidad a GPEXFUMI debido que aplica para todo MI.

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@archivo utilizado  GPRG9 + cPaisLoc + .PRX  
/*/
Function fCargRG9()

	Local cFuncion	:= "GPEXCRGRG9"

	IIf(FindFunction(cFuncion), GpexCrgRG9(), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return (Nil)

/*/{Protheus.doc} Inicializa estandar SRG
Inicializador estandar del campo RG_DFERVENT
@author Erika Espinosa
@since 10/03/2020
@version 12.1.25
@archivo utilizado 
/*/
Function fDferven()

Local aAreaSRF	:= SRF->(GetArea()) 
Local nAniosant := 0

DbSelectArea("SRF")
DbSetOrder(1)

If SRF->(MsSeek(xFilial("SRG") +  M->RG_MAT))

	While !SRF->(Eof()) .and. xFilial("SRG") +  M->RG_MAT == SRF->RF_FILIAL + SRF->RF_MAT

		If (RF_STATUS == "1")
			nAniosant := nAniosant + (RF_DFERVAT-RF_DFERANT)
		EndIf
	SRF->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSRF)
Return(nAniosant)

/*/{Protheus.doc} Inicializa estandar SRG
Inicializador estandar del campo RG_DFERPRO
@author Erika Espinosa
@since 10/03/2020
@version 12.1.25
@archivo utilizado 
/*/
Function fDferpro()

Local aAreaSRF	:= SRF->(GetArea()) 
Local nAniospro := 0

DbSelectArea("SRF")
DbSetOrder(1)

If SRF->(MsSeek(xFilial("SRG") +  M->RG_MAT))

	While !SRF->(Eof()) .and. xFilial("SRG") +  M->RG_MAT == SRF->RF_FILIAL + SRF->RF_MAT

		If (RF_STATUS == "1")
			nAniospro := nAniospro + RF_DFERAAT
		EndIf
	SRF->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSRF)
Return(nAniospro)


/*/{Protheus.doc} Inicializa estandar SRG
Inicializador estandar del campo RG_salmes
@author Erika Espinosa
@since 10/03/2020
@version 12.1.25
@archivo utilizado 
/*/
Function fSalmespar()

Local aAreaSRA	:= SRA->(GetArea()) 
Local nSalmes := 0

DbSelectArea("SRA")
DbSetOrder(1)

If SRA->(MsSeek(xFilial("SRG") +  M->RG_MAT))

	If (SRA->RA_CATFUNC $ "A|C|E|I|M|P")
		nSalmes := SRA->RA_SALARIO
	EndIf
	If (SRA->RA_CATFUNC $ "D|S")
		nSalmes := (SRA->RA_SALARIO * SRA->RA_HRSDIA) / SRA->RA_HRSMES
	EndIf
	If (SRA->RA_CATFUNC $ "G|H")
		nSalmes := SRA->RA_SALARIO * SRA->RA_HRSDIA
	EndIf
		
EndIf

RestArea(aAreaSRA)
Return(nSalmes)
		
		