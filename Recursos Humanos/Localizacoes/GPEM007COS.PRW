#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "GPEM007COS.CH"

/*                                                                         
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEM007COS� Autor � Laura Medina Prado       � Data � 29/07/2011 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Generacion de Archivos SICERE.                                  ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM007COS()                                                    ���
������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
������������������������������������������������������������������������������Ĵ��
���Programador � Data   �    FNC    �  Motivo da Alteracao                     ���
������������������������������������������������������������������������������Ĵ��
���Laura Medina�13/09/11�           � Adecuaci�n para marcar como enviado al   ���
���            �        �           � IMSS y validar al obtener la informacion.���
���Christiane V�13/01/12�024244/2011� Corre��es na gera��o do arquivo SICERE   ���
���Mauricio T. �12/05/12�012124/2012� Correcao do tratamento de mes e ano ante-���
���            �        �     TEZEJW� rior. Para mes 01 devera ser 12 e o ano  ���
���            �        �           � devera ser um a menos do selecionado.    ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Function GPEM007COS()

Local aSays	      := { }
Local aButtons    := { }
Local aGetArea	  := GetArea()
Local cPerg       := "GPM007COS"                    
Local nOpca     

Private cCadastro := OemtoAnsi(STR0001)//"Archivo SICERE"                                            
//Variables de entrada (par�metros) 
Private cRegSIC   := ""   //Registro patronal
Private cAnoSIC   := ""   //A�o de Planilla
Private cMesSIC   := ""   //Mes de Planilla
Private cMarSIC   := ""   //Marcar como enviado
Private cArchivo  := ""   //Ruta y nombre del archivo
Private cCtoSIC   := ""   //Concepto Base CCSS   
Private cEOL      := CHR(13)+CHR(10)
Private cAnoAnt   := ""   //A�o anterior acumulado
Private cMesAnt   := ""   //Mes anterior acumulado 

Private lExisArc  := .F.
Private lError    := .f.

Private nTotRegSIC:= 0 //Total de registros a procesar   

Private dDAUX_01  := ""
Private dDAUX_02  := ""

dbSelectArea("SRA")  //Empleados
dbSelectArea("SRB")  //Dependientes
dbSelectArea("RCJ")  //Procesos
DbSetOrder(1)


AADD(aSays,OemToAnsi(STR0002) ) //"Esta rutina genera el Archivo SICERE"	

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(cPerg),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons )

If  nOpca == 1 //Ejecuta el proceso
	Processa({|| GPM700GERA() },OemToAnsi(STR0003))  //"Procesando..."
	If  lError
	    Msgalert(STR0004) //"Hubo problemas durante el proceso, y el archivo generado puede tener inconsistencias!!"
    Else	                      
		If  nTotRegSIC==0             
			If  !lExisArc 
		   		msgInfo(STR0005)//"Proceso Fianlizado! No encontro registros..."
		 	Endif
		Else
		   msgInfo(STR0006+cEOL+cArchivo)   //"Proceso Finalizado, Genero los archivos: "
		Endif
	ENDIF	
Endif              	

RestArea(aGetArea)
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � GPM700GERA� Autor � Laura Medina        � Data � 29/07/11 ���                
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Generacion del archivo SICERE.                            ��� 
���           �                                                           ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � GPM700GERA()			                                  ��� 
�������������������������������������������������������������������������Ĵ��  
���Parametros � Ninguno                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso       � GPEM007COS                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function GPM700GERA
Local aAcumula := {}

Private aTrayecto := {} 
Private aTraBajas := {} 
Private aTraAltas := {} 
Private aIncapaci := {}
Private aRegPatro := {}   
Private aTraModSl := {}  
Private aEnviados := {}


//Obtener los registros con los cuales se va a generar el archivo SICERE
aAcumula := ObtEmpleado()

If  !Empty(aTrayecto) .Or. !Empty(aTraBajas) .Or. !Empty(aTraAltas) .Or. !Empty(aTraModSl) .Or. !Empty(aIncapaci)  //Encontro registros para procesar
	GenArch()  //Rutina que genera el archivo SICERE
Endif

Return     
             
                       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    �ObtEmpleado� Autor � Laura Medina        � Data � 26/07/11 ���                
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Obtenci�n de la informaci�n de los Empleados para generar ��� 
���           � el archivo SICERE                                         ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � ObtEmpleado()  		                                      ��� 
�������������������������������������������������������������������������Ĵ��
���Parametros � Ninguno                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso       � GPM700GERA                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ObtEmpleado()       
Local cAliasTmp := CriaTrab(Nil,.F.)	   
Local cAliasRCO := CriaTrab(Nil,.F.)
Local cSRAName  := InitSqlName("SRA")    
Local cRCOName  := InitSqlName("RCO")
Local cRCPName  := InitSqlName("RCP") 
Local cSR8Name  := InitSqlName("SR8")
Local cRCMName  := InitSqlName("RCM")     
Local cSRJName  := InitSqlName("SRJ") 
Local cRG7Name  := InitSqlName("RG7") 
Local cQuery    := ""                  
Local cFechEnv  := dtos(ctod("//"))                                 
Local cEmpleado := Space(TAMSX3("RA_FILIAL")[1]+TAMSX3("RA_MAT")[1])
Local nReg 		:= 0  
Local cSalAct   := 0 //Salario actual
Local cSalAnt   := 0 //Salario anterior   
Local cTpPens	:= Space(3)

//OBTENER:DATOS DEL PATRONO
cQuery := " SELECT RCO_FILIAL, RCO_NREPAT, RCO_SUCCSS, RCO_STATUS " 
cQuery += " From "+cRCOName+" RCO "
cQuery += " WHERE "
cQuery += "	RCO_CODIGO ='" + cRegSIC+ "'  "       
cQuery += " AND RCO_FILIAL = '" +xFilial("RCO")+"' " 
cQuery += " AND RCO.D_E_L_E_T_=' '"   
cQuery := ChangeQuery(cQuery)      

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)  
Count to nReg     
	
	(cAliasTmp)->(dbgotop())
	ProcRegua(nReg)   
	While  (cAliasTmp)->(!EOF())
		IncProc()          
	    
		aAdd(aRegPatro,{(cAliasTmp)->RCO_FILIAL,;
			(cAliasTmp)->RCO_NREPAT,;
			(cAliasTmp)->RCO_SUCCSS,;   
			(cAliasTmp)->RCO_STATUS,; 
			})  
			 	      
	 	(cAliasTmp)->(dbSkip())
	Enddo
	(cAliasTmp)->( dbCloseArea()) 	                 

	
//OBTENER:DATOS DE LOS EMPLEADOS - TRAYECTORIA (Activos/Bajas/Cambios en el periodo informado)			
cQuery := " SELECT RA_FILIAL, RA_MAT, RCP_CIC, RA_PRINOME, RA_SECNOME, RCP_TPCIC, RA_RG,  " 
cQuery += " RA_PRISOBR,RA_SECSOBR, RA_TJRNDA, RA_CODFUNC, RJ_CODCCSS,  "
cQuery += " RCP_DTMOV, RCP_TPMOV, RCP_SALMES, RA_TPCCSS, RCP_TJRNDA, RA_TPPENS, RA_CIC, RA_TPCIC, RCP.R_E_C_N_O_ RCP_RECNO "
cQuery += " From "+cSRAName+" SRA, "+cRCPName+" RCP, "+cSRJName+" SRJ  "
cQuery += " WHERE "              
cQuery += " RCP_FILIAL = '" +xFilial( "RCP", SRA->RA_FILIAL)+"' " 
cQuery += " AND RA_MAT = RCP_MAT "    
cQuery += " AND RCP_CODRPA = '" + cRegSIC+ "' "
cQuery += "	AND RCP_DTMOV BETWEEN '" + DTOS(dDAUX_01)+ "' AND '"+ DTOS(dDAUX_02)+ "' "     
cQuery += "	AND RCP_TPMOV IN ('01','02','04','11','21','22','23')" 
cQuery += " AND RCP_DTIMSS = ' ' "  
cQuery += " AND RA_CODFUNC = RJ_FUNCAO " 
cQuery += " AND RJ_FILIAL = '" +xFilial( "SRJ")+ "' "  // 
cQuery += " AND RCP.D_E_L_E_T_=' '" 
cQuery += " AND SRA.D_E_L_E_T_=' '"   
cQuery += " AND SRJ.D_E_L_E_T_=' '"
cQuery += " ORDER BY RA_FILIAL, RA_MAT, RCP_TPMOV "    
cQuery := ChangeQuery(cQuery)      
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)  
Count to nReg     
	
	(cAliasTmp)->(dbgotop())
	ProcRegua(nReg)   
	While  (cAliasTmp)->(!EOF())
		IncProc() 
		
		If (cAliasTmp)->RA_TPPENS == "1"
			cTpPens := "INV"
		ElseIf (cAliasTmp)->RA_TPPENS == "2"
			cTpPens := "VEJ"
		ElseIf (cAliasTmp)->RA_TPPENS == "3"
			cTpPens := "EXT"
		Endif         
	    
		aAdd(Iif((cAliasTmp)->RCP_TPMOV=='02',aTraBajas,Iif((cAliasTmp)->RCP_TPMOV =='01',aTraAltas,aTrayecto)),{(cAliasTmp)->RA_FILIAL,;
			(cAliasTmp)->RA_MAT,; 
			(cAliasTmp)->RCP_CIC,;        
			(cAliasTmp)->RCP_TPCIC,;
			(cAliasTmp)->RA_RG,;   
			(cAliasTmp)->RA_PRINOME,; 
			(cAliasTmp)->RA_SECNOME,; 
			(cAliasTmp)->RA_PRISOBR,; 
			(cAliasTmp)->RA_SECSOBR,;  
			(cAliasTmp)->RA_TJRNDA,;
			(cAliasTmp)->RA_CODFUNC,;  
			(cAliasTmp)->RCP_DTMOV,; 
			(cAliasTmp)->RCP_TPMOV,; 
			(cAliasTmp)->RCP_SALMES,;
			(cAliasTmp)->RJ_CODCCSS,; 
			(cAliasTmp)->RA_TPCCSS,;		
			(cAliasTmp)->RCP_TJRNDA,;
			cTpPens,;   
			(cAliasTmp)->RA_CIC,;        
			(cAliasTmp)->RA_TPCIC,;
			})     
		IF  cMarSIC==1
			aadd(aEnviados,(cAliasTmp)->RCP_RECNO)
		Endif   
	 	(cAliasTmp)->(dbSkip())
	Enddo
	(cAliasTmp)->( dbCloseArea()) 	
    
    //Ordenar por CIC y Fecha de movimiento
	If  !Empty(aTraAltas)  //"01"
		aTraAltas := aSort(aTraAltas,,,{|x,y| x[3]+x[12] <= y[3]+y[12] }) // RFC + Fecha del movimiento
	Endif
	If  !Empty(aTrayecto)  //"04,11,21,22,23"
		aTrayecto := aSort(aTrayecto,,,{|x,y| x[3]+x[12] <= y[3]+y[12] }) // RFC + Fecha del movimiento
	Endif 
	If  !Empty(aTraBajas)  //"02"                                                                        
		aTraBajas := aSort(aTraBajas,,,{|x,y| x[3]+x[12] <= y[3]+y[12] }) // RFC + Fecha del movimiento
	Endif


//OBTENER:DATOS DE LOS EMPLEADOS - MODIFICACION DE SALARIOS (Acumulados)			
cQuery := " SELECT RA_CIC, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, 0 RG7_ACUM02, " 
cQuery += " SUM(RG7_ACUM" +cMesSIC+") RG7_ACUM01 " 
cQuery += " From "+cSRAName+" SRA, "+cRG7Name+" RG7 "
cQuery += " WHERE "              
cQuery += " RG7_FILIAL = '" +xFilial( "RG7", SRA->RA_FILIAL)+"' " 
cQuery += " AND RA_MAT = RG7_MAT "  
cQuery += " AND RA_CODRPAT = '" + cRegSIC+ "' "  
cQuery += " AND RG7_PD = '" + cCtoSIC+ "' "   
cQuery += " AND RG7_ANOINI  = '" + cAnoSIC+ "' " 
cQuery += " AND RG7.D_E_L_E_T_=' '" 
cQuery += " AND SRA.D_E_L_E_T_=' '"    
cQuery += " GROUP BY RA_CIC, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RG7_ACUM02, RG7_ACUM01 "
cQuery += " UNION"  
cQuery += " SELECT RA_CIC, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, SUM(RG7_ACUM" +cMesAnt+") RG7_ACUM02, "
cQuery += " SUM(0) RG7_ACUM01" 
cQuery += " From "+cSRAName+" SRA, "+cRG7Name+" RG7 "
cQuery += " WHERE "              
cQuery += " RG7_FILIAL = '" +xFilial( "RG7", SRA->RA_FILIAL)+"' " 
cQuery += " AND RA_MAT = RG7_MAT "
cQuery += " AND RA_CODRPAT = '" + cRegSIC+ "' "    
cQuery += " AND RG7_PD = '" + cCtoSIC+ "' "   
cQuery += " AND RG7_ANOINI  = '" + cAnoAnt+ "' " 
cQuery += " AND RG7.D_E_L_E_T_=' '" 
cQuery += " AND SRA.D_E_L_E_T_=' '"     
cQuery += " GROUP BY RA_CIC, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RG7_ACUM02, RG7_ACUM01 "
cQuery += " ORDER BY RA_CIC "    
cQuery := ChangeQuery(cQuery)      
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)  
Count to nReg     
	
	(cAliasTmp)->(dbgotop())
	ProcRegua(nReg)   
	While  (cAliasTmp)->(!EOF())
		IncProc()          
       
 		//Obtener salario (Anterior/Actual)
 		If  (cAliasTmp)->RG7_ACUM01 != 0    //Almacenar salario actual
			cSalAct := (cAliasTmp)->RG7_ACUM01  
		Elseif  (cAliasTmp)->RG7_ACUM02 != 0  //Almacenar salario mes-anterior
			cSalAnt := (cAliasTmp)->RG7_ACUM02
		Endif
 
 		If  cEmpleado != (cAliasTmp)->RA_CIC //RA_FILIAL+RA_MAT	
			aAdd(aTraModSl,{(cAliasTmp)->RA_CIC,;          
				(cAliasTmp)->RA_PRINOME,; 
				(cAliasTmp)->RA_SECNOME,; 
				(cAliasTmp)->RA_PRISOBR,; 
				(cAliasTmp)->RA_SECSOBR,;   
				(cAliasTmp)->RG7_ACUM01,; 
				(cAliasTmp)->RG7_ACUM02,; 	
				.T.,;      
				})     	
		Else 
		    //Validar si los salario son diferentes, entonces ser�a modificacion de salario
		 	If  cSalAct != cSalAnt   
			 	aTraModSl[LEN(aTraModSl),6]:= cSalAct
			 	aTraModSl[LEN(aTraModSl),7]:= cSalAnt    
		 	Else
		 		aTraModSl[LEN(aTraModSl),8]:= .F. //Generar modificaci�n de salarios
		 	Endif
		 	cSalAct := 0
		 	cSalAnt := 0
		Endif	 
		 cEmpleado := (cAliasTmp)->RA_CIC	 	      
	 	(cAliasTmp)->(dbSkip())
	Enddo
	(cAliasTmp)->( dbCloseArea()) 	

                                                                


//OBTENER:DATOS DE LOS EMPLEADOS - INCAPACIDADES/AUSENTISMOS (IA/IG/IM/F/V/N)			
cQuery := " SELECT RA_FILIAL, RA_MAT, RA_CIC, RA_PRINOME, RA_SECNOME, RA_TPCIC, RA_RG,  " 
cQuery += " RA_PRISOBR, RA_SECSOBR, RA_TJRNDA, RA_CODFUNC, RJ_CODCCSS, R8_TIPOAFA, "
cQuery += " R8_DATAINI, R8_DATAFIM,RCM_TPIMSS, RCM_TIPOAF "
cQuery += " From "+cSRAName+" SRA, "+cSR8Name+" SR8, "+cRCMName+" RCM, "+cSRJName+" SRJ  "
cQuery += " WHERE "              
cQuery += " R8_FILIAL = '" +xFilial( "SR8", SRA->RA_FILIAL)+"' " 
cQuery += " AND RA_MAT = R8_MAT "    
cQuery += " AND R8_CODRPAT = '" + cRegSIC+ "' "                 
cQuery += "	AND ( (R8_DATAINI <= '" + DTOS(dDAUX_01)+ "' AND R8_DATAFIM >=  '"+ DTOS(dDAUX_02)+ "' ) OR "  
cQuery += "		(R8_DATAINI BETWEEN '" + DTOS(dDAUX_01)+ "' AND '"+ DTOS(dDAUX_02)+ "' ) OR "   
cQuery += "		(R8_DATAFIM BETWEEN '" + DTOS(dDAUX_01)+ "' AND '"+ DTOS(dDAUX_02)+ "' ) OR " 
cQuery += "		(R8_DATAINI <= '" + DTOS(dDAUX_01)+ "' AND R8_ENVSUA='2' )  )" 
cQuery += "	AND RCM_TIPO = R8_TIPOAFA "   
cQuery += "	AND RCM_TPIMSS IN ('A','G','M','F')" 
cQuery += " AND RA_CODFUNC = RJ_FUNCAO "                    
cQuery += " AND RJ_FILIAL = '" +xFilial( "SRJ")+ "' "  // 
cQuery += " AND RCM_FILIAL = '" +xFilial( "RCM")+ "' "  //  
cQuery += " AND SRA.D_E_L_E_T_=' '"   
cQuery += " AND RCM.D_E_L_E_T_=' '"    
cQuery += " AND SRJ.D_E_L_E_T_=' '"
cQuery += " ORDER BY RA_FILIAL, RA_MAT "    
cQuery := ChangeQuery(cQuery)      
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)  
Count to nReg     
	
	(cAliasTmp)->(dbgotop())
	ProcRegua(nReg)   
	While  (cAliasTmp)->(!EOF())                                               
		IncProc()          
	    
		aAdd(aIncapaci,{(cAliasTmp)->RA_FILIAL,;
			(cAliasTmp)->RA_MAT,; 
			(cAliasTmp)->RA_CIC,;        
			(cAliasTmp)->RA_TPCIC,;
			(cAliasTmp)->RA_RG,;   
			(cAliasTmp)->RA_PRINOME,; 
			(cAliasTmp)->RA_SECNOME,; 
			(cAliasTmp)->RA_PRISOBR,; 
			(cAliasTmp)->RA_SECSOBR,;  
			(cAliasTmp)->RA_TJRNDA,;
			(cAliasTmp)->RA_CODFUNC,; 
			(cAliasTmp)->R8_DATAINI,;
			(cAliasTmp)->R8_DATAFIM,;  
			(cAliasTmp)->RCM_TPIMSS,; 
			(cAliasTmp)->RJ_CODCCSS,; 
           	(cAliasTmp)->RCM_TIPOAF,;
			})  
			 	      
	 	(cAliasTmp)->(dbSkip())
	Enddo
	(cAliasTmp)->( dbCloseArea()) 	
	
	 //Ordenar por CIC y Fecha de movimiento
	If  !Empty(aIncapaci)  
		aIncapaci := aSort(aIncapaci,,,{|x,y| x[3]+x[12] <= y[3]+y[12] }) // RFC + Fecha inicio de la incapacidad
	Endif
	
Return 



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GenArch  � Autor � Laura Medina          � Data � 20/07/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que va a generar los registros para el archivo TXT ���  
���          � dependiendo de los par�etros selecccionados.               ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GenArch(aExp1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  aExp1.-Registros que se colocaran en el archivo de salida ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM700GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function GenArch()       
Local lRet      := .T.
Local nloop   	:= 0     
Local nArchivo  := 0 
Local nIndRCO   := Retordem("RCO","RCO_FILIAL+RCO_CODIGO+RCO_NREPAT")
Local nJornada  := 0 
Local cRegPat   := POSICIONE("RCO",nIndRCO,xFilial("RCO")+cRegSIC,"RCO_NREPAT")
Local aEmpleado := {}

cArchivo  := Alltrim(cArchivo)+"pla_"+cAnoSIC+cMesSIC+"_"+Substr(cRegPat,2,14)+".txt" 
lExisArc  := .F.

If  File(cArchivo)  //Si el archivo ya existe
	If  MsgYesNo(oemtoansi(STR0008+Alltrim(cArchivo)+STR0009))   //"El archivo "+XXX+" ya existe, �Desea eliminarlo?"
		FErase(cArchivo) 		
	Else 
		lRet     := .F.   
		lExisArc := .T.  
		fClose(nArchivo) 
	EndIf 
Endif     

If  lRet  
	//Creacion de archivo
	nArchivo  := MSfCreate(cArchivo,0)
	
	If  !Empty(aRegPatro) 
		//Imprime: Registro 1 ***********************************************************************************
		FWrite(nArchivo,"25"+PADR(aRegPatro[1,2],18)+PADR(aRegPatro[1,3],4)+cAnoSIC+cMesSIC+Iif(aRegPatro[1,4]=='1','N','S')+cEOL)
		
		nTotRegSIC := Len(aTrayecto)+Len(aTraBajas)+Len(aTraAltas)+Len(aIncapaci)+Len(aTraModSl)
		ProcRegua(nTotRegSIC)
		
		//Imprime: Registro 2  **********************************************************************************

		//Trayectoria Laboral (Ingresos)
		For nloop:=1 to len(aTraAltas) 
			IncProc(STR0014)   //"Procesando Ingresos"
			nJornada := ObtJornada(aTraAltas[nloop,10]) //strzero(POSICIONE("SR6",nIndSR6,XFILIAL("SR6")+aTraAltas[nloop,10],"R6_HRDIA"),5)
			FWrite(nArchivo,"35"+PADR(aTraAltas[nloop,4],1)+PADR(aTraAltas[nloop,3],25)+PADR(aTraAltas[nloop,8],20)+PADR(aTraAltas[nloop,9],20)+PADR(Alltrim(aTraAltas[nloop,6])+ " " + Alltrim(aTraAltas[nloop,7]),60)+;
					PADR(aTraAltas[nloop,15],4)+SPACE(15)+PADR(aTraAltas[nloop,16],1)+"IC"+StrZero(nJornada,2)+ObtDesJor(aTraAltas[nloop,10])+PADR(aTraAltas[nloop,17],2)+"GEN"+aTraAltas[nloop,12]+Space(8)+cEOL)           		
			/*					RA_TPCIC					RA_CIC                       RA_PRISOBR					RA_SECSOBR                RA_PRINOME+RA_SECNOME
								RJ_CODCCSS  SALARIO         RA_TPCCSS                    R6_HRDIA		RCP_TJRNDA  */
    	Next nloop 
        
        //Trayectoria Laboral (Modif. Salario)
    	For nloop:=1 to len(aTraModSl) 
			IncProc(STR0015)   //"Procesando Modif. Salario"      
			aEmpleado :=ObtDatos(aTraModSl[nloop,1])   
			If !Empty(aEmpleado)
				FWrite(nArchivo,"35"+PADR(aEmpleado[1,9],1)+PADR(aTraModSl[nloop,1],25)+PADR(aTraModSl[nloop,4],20)+PADR(aTraModSl[nloop,5],20)+PADR(Alltrim(aTraModSl[nloop,2])+ " " + Alltrim(aTraModSl[nloop,3]),60)+;
				   		PADR(aEmpleado[1,4],4)+Transform(aTraModSl[nloop,6],"999999999999.99")+SPACE(1)+"SA"+SPACE(5)+SPACE(3)+SPACE(3)+dtos(dDAUX_02)+Space(8)+cEOL)           			
				If  aTraModSl[nloop,8] //Generar modificaci�n de salarios
					InsModSal(aTraModSl[nloop],aEmpleado[1])
				Endif
			Endif	
    	Next nloop 
        
        //Trayectoria Laboral (Cambios)
    	For nloop:=1 to len(aTrayecto) 
			IncProc(STR0016)   //"Procesando Modif. Jornada/N�mero Patronal/..."  
			nJornada := ObtJornada(aTrayecto[nloop,17]) 
			FWrite(nArchivo,"35"+Iif(aTrayecto[nloop,13]=='21',PADR(aTrayecto[nloop,20],1)+PADR(aTrayecto[nloop,19],25),PADR(aTrayecto[nloop,4],1)+PADR(aTrayecto[nloop,3],25))+PADR(aTrayecto[nloop,8],20)+PADR(aTrayecto[nloop,9],20)+PADR(Alltrim(aTrayecto[nloop,6])+ " " + Alltrim(aTrayecto[nloop,7]),60)+;
			   		PADR(aTrayecto[nloop,15],4)+Space(15)+Space(1)+;  
			   		Iif(aTrayecto[nloop,13]=='11',"OC",Iif(aTrayecto[nloop,13]=='23',"JO",Iif(aTrayecto[nloop,13]=='21' .And. aTrayecto[nloop,16] <> 'C',"PN",Iif(aTrayecto[nloop,13]=='21',"CS",Space(2)) )))+;
			   		Iif(aTrayecto[nloop,13]=='23',STRZERO(nJornada,2)+ObtDesJor(aTrayecto[nloop,17])+PADR(aTrayecto[nloop,17],2),Space(2)+Space(3)+Space(2))+;
			   		Iif(aTrayecto[nloop,13]=='21' .And. aTrayecto[nloop,16] <> 'C',PADR(aTrayecto[nloop,18],3), Space(3))+;
			   		aTrayecto[nloop,12]+Space(8)+cEOL)           			
    	Next nloop 	 
    	
    	//Ausentismos (Incapacidades/Permisos)
    	For nloop:=1 to len(aIncapaci) 
			IncProc(STR0017)   //"Procesando Incapacidades/Permisos" 
			If  aIncapaci[nloop,14]=='F' //Permisos
				FWrite(nArchivo,"35"+PADR(aIncapaci[nloop,4],1)+PADR(aIncapaci[nloop,3],25)+PADR(aIncapaci[nloop,8],20)+PADR(aIncapaci[nloop,9],20)+PADR(Alltrim(aIncapaci[nloop,6])+ " " + Alltrim(aIncapaci[nloop,7]),60)+;
				   		PADR(aIncapaci[nloop,15],4)+SPACE(15)+SPACE(1)+"PE"+SPACE(5)+SPACE(3)+;
				   		Iif(aIncapaci[nloop,16]=='2',PADR('C',3),PADR('S',3))+aIncapaci[nloop,12]+aIncapaci[nloop,13]+cEOL)           			
			Else   //Incapacidades
				FWrite(nArchivo,"35"+PADR(aIncapaci[nloop,4],1)+PADR(aIncapaci[nloop,3],25)+PADR(aIncapaci[nloop,8],20)+PADR(aIncapaci[nloop,9],20)+PADR(Alltrim(aIncapaci[nloop,6])+Alltrim(aIncapaci[nloop,7]),60)+;
				   		PADR(aIncapaci[nloop,15],4)+SPACE(15)+SPACE(1)+"IN"+SPACE(5)+SPACE(3)+;
				   		Iif(aIncapaci[nloop,14]=='A','INS',Iif(aIncapaci[nloop,14]=='I','SEM','MAT'))+aIncapaci[nloop,12]+aIncapaci[nloop,13]+cEOL)           			
			Endif         		
    	Next nloop 	
    	
    	//Trayectoria Laboral (Bajas)  
    	For nloop:=1 to len(aTraBajas) 
			IncProc(STR0018)   //"Procesando Bajas"    
			FWrite(nArchivo,"35"+PADR(aTraBajas[nloop,4],1)+PADR(aTraBajas[nloop,3],25)+PADR(aTraBajas[nloop,8],20)+PADR(aTraBajas[nloop,9],20)+PADR(Alltrim(aTraBajas[nloop,6])+Alltrim(aTraBajas[nloop,7]),60)+;
			   		PADR(aTraBajas[nloop,15],4)+SPACE(15)+SPACE(1)+"EX"+SPACE(5)+SPACE(2)+SPACE(3)+aTraBajas[nloop,12]+Space(8)+cEOL)           			
              		
    	Next nloop      
    Endif
       
    
   	//Para cerrar el archivo creado
	If  nTotRegSIC>0  
		//Registro sumario
		FWrite(nArchivo,"15"+"PAT"+DTOS(DDATABASE)+PADR("1",10)+STRZERO(nTotRegSIC,10)+cEOL)
		fClose(nArchivo)   
	Endif        
	
 	
	//Actualiza RCP si la opcion es Marcar como enviado (1 = Si)
	ProcRegua(LEN(aEnviados)) // N�mero de registros a procesar

	For nloop:=1 to len(aEnviados)
	    Incproc(STR0013)//"Actualizando Trayectoria Laboral"
	    RCP->(dbgoto(aEnviados[nloop]))
	    If !RCP->(EOF())
	        Reclock("RCP",.F.)
	        RCP->RCP_DTIMSS:=DDATABASE
	        RCP->RCP_HRIMSS:=TIME()
	        RCP->(MSUNLOCK())
	    ENDIF
	Next
	 
Endif            

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TodoOK   � Autor � Laura Medina          � Data � 25/07/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que valida los par�metros de entrada para la obten-���  
���          � ci�n de la informacion.                                    ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TodoOK(cExp1)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  cExp1.-Nombre de grupo de pregunta                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM700GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function TodoOK(cPerg)
Local lRet := .T.             
Pergunte(cPerg,.F.)

cRegSIC   := MV_PAR01	//Registro patronal
cAnoSIC   := strzero(MV_PAR02,4)   //A�o de Planilla
cMesSIC   := strzero(MV_PAR03,2)   //Mes de Planilla
cMarSIC   := MV_PAR04   //Marcar como enviado
cCtoSIC   := MV_PAR05   //Concepto Base CCSS 
cArchivo  := MV_PAR06   //Ruta y nombre del archivo

If  Empty(cArchivo)
	msginfo(STR0007)//"Debe proporcionar la ruta!"
	lRet := .F.  
Endif	  

If  lRet
	dDAUX_01 := CTOD("01/"+cMesSIC+"/"+cAnoSIC)
	dDAUX_02 := Iif(cMesSIC=='12',CTOD("31/"+cMesSIC+"/"+cAnoSIC),CTOD("01/"+strzero(val(cMesSIC)+1,2)+"/"+cAnoSIC)-1) 
	
	cAnoAnt  := Strzero(Iif(MV_PAR03==01,MV_PAR02-1,MV_PAR02),4)
	cMesAnt  := Strzero(Iif(MV_PAR03==01,12,MV_PAR03-1),2)
Endif       

Return lRet
              

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �InsModSal � Autor � Laura Medina          � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descripci� Funcion para insertar la modificaci�n de salario, si se    ��� 
���          � encuentra en acumulados (RG7) una diferencia de salario    ��� 
���          � del mes del proceso vs un mes anterior.                    ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � InsModSal(cExp1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  cExp1.- Arreglo de trayectori para el empleado en proceso ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM700GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function InsModSal(aRegSal,aRegEmp)	   
Local nIndSR6   := Retordem("SR6","R6_FILIAL+RA_TURNO")

DbSelectArea("RCP")
RCP->(dbSetOrder(RETORDEM("RCP","RCP_FILIAL+RCP_MAT+DTOS(RCP_DTMOV)+RCP_TPMOV"))) 

If  RCP->(!DBSEEK(aRegSal[1]+aRegSal[2]+dtos(dDAUX_02)+'05'))
	RCP->(RECLOCK("RCP",.T.))
Else
	RCP->(RECLOCK("RCP",.F.))  
Endif
	
	RCP->RCP_FILIAL  := aRegEmp[1]
	RCP->RCP_MAT     := aRegEmp[2]
	RCP->RCP_DTMOV   := dDAUX_02
	RCP->RCP_TPMOV   := '05'
	RCP->RCP_SALMES  := aRegSal[6]  
	RCP->RCP_CODRPA  := cRegSIC   
	RCP->RCP_TJRNDA  := aRegEmp[8]  	
	RCP->RCP_CIC     := aRegSal[1]
	RCP->RCP_TPCIC   := aRegEmp[9]
	RCP->RCP_HRSDIA  := POSICIONE("SR6",nIndSR6,XFILIAL("SR6")+aRegEmp[8],"R6_HRDIA")
	RCP->RCP_PERMOV  := RcPeriodoInit()
	RCP->RCP_NPGMOV  := RcNumPgInit()
	RCP->RCP_DTIMSS  := DDATABASE
	RCP->RCP_HRIMSS  := TIME()	                  
	RCP->RCP_CARGO   := aRegEmp[7]
	RCP->RCP_CC      := aRegEmp[5]
	RCP->RCP_DEPTO   := aRegEmp[6]
	RCP->RCP_CODFUN  := aRegEmp[3]       
	IF  cMarSIC==1
		RCP->RCP_DTIMSS:= DDATABASE
	    RCP->RCP_HRIMSS:= TIME()
	Endif   
	RCP->(MsUnlock()) 
	                          
Return                              


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GPM07COS01� Autor � Laura Medina          � Data � 24/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion que valida el mes del periodo de los parametros de ���  
���          � entrada.                                                   ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GPM07COS01()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPM07COS01                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Function GPM07COS01()   
                                   
Local  cMes:= MV_PAR03
                
IF  cMes<1 .or. cMes>13
	msginfo(STR0011) //"Debe proporcionar un mes valido"
    Return .F.
ENDIF                  

Return (.T.)
                 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ObtJornada� Autor � Laura Medina          � Data � 25/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para obtener la jornada.                           ���  
���          �                                                            ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtJornada(cExp1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1.- Campo RA_TJRNDA                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM700GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function ObtJornada(cCodJorn)
Local  nAUX01   := 0
Local  nJornada := 0 

cCodJorn += Space(4 - Len(cCodJorn))

nAUX01   := FPOSTAB("S021",cCodJorn,"=",4)
nJornada := IF(nAUX01>0, FTABELA("S021",NAUX01,10), 0)
    
Return nJornada      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ObtDesJor � Autor � Laura Medina          � Data � 26/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para obtener la clave de la jornada.               ���  
���          �                                                            ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtDesJor(cExp1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  cExp1.- Campo RA_TJRNDA                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM700GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function ObtDesJor(cCodJorn)
Local  nAUX01  := 0
Local  cDescJor:= SPACE(3)  

cCodJorn += Space(4 - Len(cCodJorn))

nAUX01   := FPOSTAB("S021",cCodJorn,"=",4)
cDescJor := IF(nAUX01>0, FTABELA("S021",NAUX01,8),SPACE(3) )
    
Return cDescJor
                  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ObtDatos � Autor � Laura Medina          � Data � 29/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para obtener los datos del empleado para grabar en ���  
���          � trayectoria.                                               ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtDatos(cExp1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  cExp1.- RFC del empleado en proceso                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPM700GERA                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function ObtDatos(cRFC)
Local cAliasTmp := CriaTrab(Nil,.F.)	   
Local cSRAName  := InitSqlName("SRA")    
Local cSRJName  := InitSqlName("SRJ")
Local cQuery    := ""    
local aEmpleado := {}              


//OBTENER:DATOS DEL PATRONO
cQuery := " SELECT RA_FILIAL, RA_MAT, RA_CODFUNC, RJ_CODCCSS, RA_CC, RA_DEPTO, RA_CARGO, RA_TJRNDA " 
cQuery += " From "+cSRAName+" SRA, "+cSRJName+" SRJ 
cQuery += " WHERE "
cQuery += "	RA_CIC ='" + cRFC+ "'  "    
cQuery += "	AND RA_SITFOLH <> 'D'  "         
cQuery += " AND RA_CODFUNC = RJ_FUNCAO " 
cQuery += " AND RJ_FILIAL = '" +xFilial( "SRJ", SRA->RA_FILIAL)+"' " 
cQuery += " AND SRA.D_E_L_E_T_=' '"   
cQuery += " AND SRJ.D_E_L_E_T_=' '"   
cQuery := ChangeQuery(cQuery)      

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)  
Count to nReg     
	
	(cAliasTmp)->(dbgotop())
	ProcRegua(nReg)   
	While  (cAliasTmp)->(!EOF())
		IncProc()          
	    
		aAdd(aEmpleado,{(cAliasTmp)->RA_FILIAL,;
			(cAliasTmp)->RA_MAT,;
			(cAliasTmp)->RA_CODFUNC,;   
			(cAliasTmp)->RJ_CODCCSS,; 
			(cAliasTmp)->RA_CC,;
			(cAliasTmp)->RA_DEPTO,;
			(cAliasTmp)->RA_CARGO,; 
			(cAliasTmp)->RA_TJRNDA,;
			})  
			 	      
	 	(cAliasTmp)->(dbSkip())
	Enddo
	(cAliasTmp)->( dbCloseArea()) 	                 
   
Return aEmpleado

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Gpm007Dir  �Autor  �Christiane Vieira  � Data �  09/01/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para selecionar destino da gera��o do arquivo.      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Gpm007Dir()

Local _mvRet  := Alltrim(ReadVar())
Local _cPath  := mv_par06

_cPath:=cGetFile( STR0001 ,STR0019 ,0,_cPath,.F.,GETF_RETDIRECTORY+GETF_LOCALFLOPPY+GETF_LOCALHARD) 

&_mvRet := _cPath

Return