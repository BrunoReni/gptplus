#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM005COS.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEM005COS� Autor � Flor Monroy                � Data � 01/08/11 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Generar un TReport D152 Declaraci�n Anual                       ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM005COS()                                                    ���
������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
������������������������������������������������������������������������������Ĵ��
���Programador � Data   �    FNC    �  Motivo da Alteracao                     ���
������������������������������������������������������������������������������Ĵ��
���Christiane V�23/11/11�024242/2011� Corre��o do Error Log ao acessar a rotina���
���Christiane V�30/11/11�024242/2011� Corre��o da Gera��o do Arquivo           ���
���Christiane V�06/12/11�024242/2011� Corre��o da Formata��o dos Valores       ���  
���Christiane V�11/01/12�000634/2012� Corre��o quando existe reingresso        ���
���GSantacruz V�30/10/12�TGA284		� Cambio de nombre de los titulos en Reg 1 ���
���            �        �           � Cambio de anchos de campo en Reg 2       ���
���            �        �           � Se agrego Log de errores y las etiquetas ���
���            �        �           � de Nomina a Procedimiento                ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/

Function GPEM005COS()
Local oReport
Local aGetArea		:=	GetArea()                           

Private aError		:= {} //Contiene los errores para el LOG
Private cPerg		:=	"GPM005COS"
Private cCond		:= 	"1" 
Private cRot		:= 	""

Private cProceso	:=	""	//Parametro de Entrada: Proceso
Private cPeriodo	:=	""	//Parametro de Entrada: Periodo
Private cNumPag		:=	""	//Parametro de Entrada: Numero de Pago
Private cNomina		:=	""	//Parametro de Entrada: Nomina
Private cTipoSep	:=	""	//Parametro de Entrada: Nomina
Private cAnio		:=	""	//Parametro de Entrada: Anio
Private cAliasTmp	:=	criatrab(nil,.f.)	// Creo mi tabla temporal
Private cNomeProg	:=	"GPEM005COS"  


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
���Fun��o    �ReportDef |  Autor� FMonroy               � Data �26/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �  Definir las celdas del Reporte D152  Declaraci�n Anual    ���
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


Private cTitulo	:=OEMTOANSI(STR0001) //"D152 Declaraci�n Anual"

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
oReport:nFontBody	:= 6 	// Define o tamanho da fonte.
oReport:CFONTBODY	:=	"COURIER NEW"   
oReport:CREPORT		:=	"D152" //+cAnio   
oReport:nDevice		:=	4
oReport:nEnvironment	:= 	2   

oReport:lParamPage:=.f. //Evita que se imprima la hoja de parametros
oReport:lHeaderVisible	:= .f. //no imprime el encabezado

                                            

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

//��������������������������������������������������������������������������Ŀ
//� Definici�n de la Primera Secci�n: Encabezado                             �
//���������������������������������������������������������������������������� 

oSection1:= TRSection():New(oReport,"",,/*aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
//oSection1:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao
oSection1:lHeaderPage:=	.f. //	Imprime cabe�alho da se��o no topo da p�gina


TRCell():New(oSection1,"RA_CIC",      ,STR0002, PesqPict("SRA","RA_CIC"),12)	//"CEDULA"
TRCell():New(oSection1,"RA_NOMECMP",  ,STR0003,                        ,80	)	//"NOMBRE"
TRCell():New(oSection1,"SRC_VALOR",   ,STR0004,,13)	//"BASE RETENCION"
TRCell():New(oSection1,"IRC_VALOR",   ,STR0005,	,13)	//"IMPUESTO RETENIDO"
TRCell():New(oSection1,"PRC_VALOR",   ,STR0006,	,13)	//"DEDUCCION PENSION COMPLEMENTARIA"
TRCell():New(oSection1,"CRC_VALOR",   ,STR0007, ,13)	//"CREDITOS FISCALES"
TRCell():New(oSection1,"CRV_DECLANU", ,STR0008,			        ,3	)	//"CODIGO"

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
���Sintaxe    � GetRows()   		                                      ��� 
�������������������������������������������������������������������������Ĵ��
���Parametros �                                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso       � GPEM005COS                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GetRows()   
    
Local aArea		:= GetArea()
Local cQuery 	:= ""

cQuery := " SELECT SRC.RC_FILIAL,SRA.RA_CIC,SRA.RA_PRISOBR,SRA.RA_SECSOBR,SRA.RA_PRINOME,SRA.RA_SECNOME,SRA.RA_NASC,SRV.RV_DECLANU, SUM(SRC.RC_VALOR) RC_VALOR"
cQuery += " FROM " + RetSqlName("SRC") + " SRC "
cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV "
cQuery += " ON SRC.RC_PD = SRV.RV_COD AND SRV.RV_FILIAL = '"+XFILIAL("SRV",SRC->RC_FILIAL)+"' "
cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA "
cQuery += " ON SRA.RA_MAT = SRC.RC_MAT AND SRA.RA_FILIAL = '"+XFILIAL("SRA",SRC->RC_FILIAL)+"' "
cQuery += " WHERE"
cQuery += " 		    SRC.RC_PROCES IN ("+  cProceso +") "
cQuery += " 		AND SRC.RC_PERIODO = '"+ cPeriodo +"' "
cQuery += " 		AND SRC.RC_SEMANA = '"+ cNumPag +"' "
cQuery += " 		AND SRC.RC_ROTEIR = '"+ cNomina +"' "
//cQuery += " 		AND ( SUBSTRING(SRV.RV_DECLANU,1,1) IN ('I','P','C') OR SRV.RV_DECLANU ='SL')"
cQuery += " 		AND SRV.RV_DECLANU<>'' "
cQuery += " AND SRC.D_E_L_E_T_ <> '*' AND SRV.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY SRC.RC_FILIAL,SRA.RA_CIC,SRA.RA_PRISOBR,SRA.RA_SECSOBR,SRA.RA_PRINOME,SRA.RA_SECNOME,SRA.RA_NASC,SRV.RV_DECLANU"
cQuery += " ORDER BY SRC.RC_FILIAL,SRA.RA_CIC,SRA.RA_PRISOBR,SRA.RA_SECSOBR,SRA.RA_PRINOME,SRA.RA_SECNOME,SRA.RA_NASC,substring(SRV.RV_DECLANU,2,3)"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
TCSetField(cAliasTmp,"RA_NASC","D")  
RestArea( aArea )
Return ( Nil )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PrintReport�Autor � FMonroy               � Data � 13/07/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir el reporte de acuerdo a su definici�n.            ���  
���          �                                                            ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(oExp1)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  oExp1.-Objeto TReport                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM005COS                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function PrintReport(oReport)       

Local oSection1  := oReport:Section(1)
Local cMat
Local cDeclaNu
Local nImp
Local nPen
Local nCre
Local nLin	:=	1
Local nValor:=	0    
Local lRet:= .t.
Local aRegProc:={}

Pergunte(oReport:GetParam(),.F.)   
if !TodoOk()
	oReport:Cancel():= .T.
    return  
endif    
getRows()

Begin Sequence 
	dbSelectArea( cAliasTmp )
	count to nTotal
	oReport:SetMeter(nTotal) 
	(cAliasTmp)->(DbGoTop()) 
	If (cAliasTmp)->(!Eof())
	    oSection1:Init()
	    
		While (cAliasTmp)->(!Eof())
		    aRegProc:={} 
			cDeclaNu:=SUBSTR((cAliasTmp)->RV_DECLANU,2,3)
			cMat:=(cAliasTmp)->RA_CIC
			
			//Hace un filtro de registros validos
			lRet:=.t. 
		    IF YEAR(DDATABASE)- YEAR((cAliasTmp)->RA_NASC)<21 .OR. !VldReg((cAliasTmp)->RA_CIC,1,nlin); //MENORES DE 21 A�OS NO GENERA  O NO TIENE CEDULA
			    .or. !VldReg( SUBSTR(ALLTRIM((cAliasTmp)->RA_PRISOBR)+" "+ALLTRIM((cAliasTmp)->RA_SECSOBR)+" "+ALLTRIM((cAliasTmp)->RA_PRINOME)+" "+ALLTRIM((cAliasTmp)->RA_SECNOME),1,80),2,nlin);
			    .or.  !VldReg(cDeclaNu,7,nlin)
				lRet:=.f.   
		    	While (cAliasTmp)->(!Eof()) .And. cMat==(cAliasTmp)->RA_CIC
					 oReport:IncMeter()  
			    	(cAliasTmp)->(dbSkip())
		    	ENDDO                                             
		    ELSE                  
		        aadd(aRegProc,{(cAliasTmp)->RA_CIC,;
		        				SUBSTR(ALLTRIM((cAliasTmp)->RA_PRISOBR)+" "+ALLTRIM((cAliasTmp)->RA_SECSOBR)+" "+ALLTRIM((cAliasTmp)->RA_PRINOME)+" "+ALLTRIM((cAliasTmp)->RA_SECNOME),1,80),;
		        				0,;
		        				0,;
		        				0,;
		        				0,;
		        				cDeclaNu})
		        				
		    	While (cAliasTmp)->(!Eof()) .And. cMat==(cAliasTmp)->RA_CIC
			    	nValor:=round((cAliasTmp)->RC_VALOR,0)                            
      				Do Case          
						Case substr(alltrim((cAliasTmp)->RV_DECLANU),1,1)=='B'//llTrim((cAliasTmp)->RV_DECLANU) == 'SL' // Base
							lRet:= VldReg(nValor,3,nlin,cDeclaNu)
	  						aRegProc[1,3]:=nValor
						Case substr(alltrim((cAliasTmp)->RV_DECLANU),1,1)=='I' //Impuestos
							lRet:=VldReg(nValor,4,nlin)
							aRegProc[1,4]:=nValor
						Case substr(alltrim((cAliasTmp)->RV_DECLANU),1,1)=='P' //Pensiones
							lRet:=VldReg(nValor,5,nlin,cDeclaNu)
							aRegProc[1,5]:=nValor
						Case substr(alltrim((cAliasTmp)->RV_DECLANU),1,1)=='C' // Cr�dito
							lRet:=VldReg(nValor,6,nlin,cDeclaNu)
							aRegProc[1,6]:=nValor
					EndCase                                                                
					oReport:IncMeter()  
			    	(cAliasTmp)->(dbSkip())                                               
		    	ENDDO 
	    		
		    ENDIF	                                              
		    if !lRet
		        loop                             
			else
				nlin++      		        
		    endif    
		    
			//Genera a excel el registro valido	    
			if nlin==2
				oSection1:Cell("RA_CIC"):SetValue(STR0002)
				oSection1:Cell("RA_NOMECMP"):SetValue( STR0003) 
				oSection1:Cell("SRC_VALOR"):SetValue(STR0004)				
				oSection1:Cell("IRC_VALOR"):SetValue(STR0005)
				oSection1:Cell("PRC_VALOR"):SetValue(STR0006)
				oSection1:Cell("CRC_VALOR"):SetValue(STR0007)
				oSection1:Cell("CRV_DECLANU"):SetValue(STR0008)
				oSection1:PrintLine()
			endif
		    
		    
			oSection1:Cell("RA_CIC"):SetValue(aRegProc[1,1])
			oSection1:Cell("RA_NOMECMP"):SetValue( aRegProc[1,2]) 
			oSection1:Cell("SRC_VALOR"):SetValue(TRANSFORM(aRegProc[1,3],"9999999999999"))				
			oSection1:Cell("IRC_VALOR"):SetValue(TRANSFORM(aRegProc[1,4],"9999999999999"))
			nImp:=aRegProc[1,4]
			oSection1:Cell("PRC_VALOR"):SetValue(TRANSFORM(aRegProc[1,5],"9999999999999"))
			nPen:=aRegProc[1,5]
			oSection1:Cell("CRC_VALOR"):SetValue(TRANSFORM(aRegProc[1,6],"9999999999999"))
			nCre:=aRegProc[1,6]
			oSection1:Cell("CRV_DECLANU"):SetValue(aRegProc[1,7])
			oSection1:PrintLine()

			
			
		EndDo //Fin  de archivo
	EndIf //If fin de archivo 
End Sequence
(cAliasTmp)->(dbCloseArea()) 
if len(aerror)>0  
   if msgyesno("Archivo generado con errores. Verificalos?")
		ImprimeLog()                                            
	endif
endif
Return ( Nil )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TodoOK   � Autor � FMonroy               � Data � 08/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validar los par�metros de entrada                          ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TodoOK(cExp1)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1.-Nombre del grupo de preguntas                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM005COS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function TodoOK(cPerg)
Local lRet := .T.             
Pergunte(cPerg,.F.)

cProceso	:=	ConvQry(MV_PAR01,"RA_PROCES")	//Parametro de Entrada: Proceso
cNomina		:=	MV_PAR02	//Parametro de Entrada: Nomina
cPeriodo	:=	MV_PAR03	//Parametro de Entrada: Periodo
cNumPag		:=	MV_PAR04	//Parametro de Entrada: Numero de Pago
cAnio		:=	transform(MV_PAR05,"9999")	//Parametro de Entrada: Nomina
if empty(cproceso) .or. empty(cnomina) .or. empty(cPeriodo) .or. empty(cNumPag) .or. empty(cAnio)
   lRet:= .f.
   msginfo("Verifique los parametros, todos son requeridos")
endif   
	
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
��� Uso      �  GPEM005COS                                                ���
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
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VldReg   � Autor � GSantacruz            � Data � 30/10/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validar lso datos que van al archivo                       ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � VldReg(uExp1,nExp1,nExp2)                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� uExp1.-Valor a validar                                     ���
���          � nExp1.-Tipo de valor                                       ���
���          � nExp2.-Numero de linea                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM005COS                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 


Static Function VldReg(uValor,nTipo,nlin,cDec)
      
Local cLin:=alltrim(str(nlin))              
Local lRet:=.t.
Default cDec:=''
Do Case
	Case nTipo==1
			if empty(uValor)
			 	aadd(aError,(cAliasTmp)->RA_CIC+", CEDULA sin valor")
			   	lRet:=.f.
		    endif
			if alltrim(uValor)=='0'
			 	aadd(aError,(cAliasTmp)->RA_CIC+", CEDULA igual a cero")
		 		lRet:=.f.
			 endif		                        
			if !Numero(uValor)
			 	aadd(aError,(cAliasTmp)->RA_CIC+", CEDULA con caracteres diferentes de numeros")
		 		lRet:=.f.
			 endif		                        
			if ChkCarEsp(uValor)    
			 	aadd(aError,(cAliasTmp)->RA_CIC+", CEDULA con caracteres especiales")
		 		lRet:=.f.
			 endif		                        
			                        
			 if len(alltrim(uValor))<10 .or. len(alltrim(uValor))>12
	 		 	aadd(aError,(cAliasTmp)->RA_CIC+", CEDULA con longitud menor a diez o mayor a doce caracteres")
 		 		lRet:=.f.
			 endif		 	
	Case nTipo==2        
		    if empty(uValor)
			 	aadd(aError,(cAliasTmp)->RA_CIC+", NOMBRE sin valor")
		 		lRet:=.f.
		    endif
			if alltrim(uValor)=='0'
			 	aadd(aError,(cAliasTmp)->RA_CIC+", NOMBRE igual a cero")
		 		lRet:=.f.
			 endif		                        
			 if len(alltrim(uValor))>80 
	 		 	aadd(aError,"Renglon:"+clin+", NOMBRE con longitud  mayor a 80 caracteres")
			 endif		 	
	Case nTipo==3 
		 	if empty(uValor)
			 	aadd(aError,"Renglon:"+clin+", BASE RETENCION sin valor")
		    endif
			if uValor==0
			 	aadd(aError,"Renglon:"+clin+", BASE RETENCION igual a cero")
			 endif
	Case nTipo==4      
			If empty(uValor)
			 	aadd(aError,"Renglon:"+clin+", IMPUESTO RETENIDO sin valor")
		    endif
			if uValor==0
			 	aadd(aError,"Renglon:"+clin+", IMPUESTO RETENIDO igual a cero")
			 endif
	Case nTipo==5  
			If empty(uValor)
			 	aadd(aError,"Renglon:"+clin+", PENSION COMPLEMENTARIA sin valor")
		    endif
			 if !empty(uValor) .AND. alltrim(cDec)<>"SL"
			 	aadd(aError,(cAliasTmp)->RA_CIC+", PENSION COMPLEMENTARIA si tiene valor y el c�digo es diferente a SL")
			 	lRet:= .f.
			 endif	
	Case nTipo==6	 
			If empty(uValor)
			 	aadd(aError,"Renglon:"+clin+", CREDITOS FISCALES sin valor")
		    endif
			 
			 if !empty(uValor) .AND.  alltrim(cDec)<>"SL"
			 	aadd(aError,(cAliasTmp)->RA_CIC+", CREDITOS FISCALES si tiene valor y el c�digo es diferente a SL")
		 		lRet:= .f.
			 endif					
	Case nTipo==7  
			If empty(uValor)
			 	aadd(aError,"Renglon:"+clin+", CODIGO sin valor")
		    endif
			 if alltrim(uValor)=='0'
			 	aadd(aError,"Renglon:"+clin+", CODIGO igual cero")
			 endif                              
			 if len(alltrim(uValor))>3
				 aadd(aError,"Renglon:"+clin+", CODIGO con longitud mayor a 3 caracteres")
			 endif
			 if !substr(alltrim(uValor),2,3) $ "SL |SLV|IN |RO |DP |RE |OR "
				 aadd(aError,(cAliasTmp)->RA_CIC+", CODIGO c�digo es diferente a SL, SLV, IN, RO, DP, RE, OR")
			 	 lRet:= .f.
			 endif
EndCase


Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ChkCarEsp� Autor � gSantacruz            � Data � 30/10/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida si hay caracteres especiales                        ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ChkCarEsp(cExp1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1.-Valor a validar                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM005COS                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function ChkCarEsp(cValor)
Local lRet	:= .f.       
Local nx	:=	0 
Local cChrValido:='ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz"

cValor:=alltrim(cValor)

for nx:=1 to len(cValor)
    if !substr(cValor,nx,1) $ cChrValido
       lRet:= .t.
       exit
    endif
next

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Numero 	  Autor � gSantacruz            � Data � 30/10/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida si solo son Numeros                                 ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Numero(cExp1)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1.-Valor a validar                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM005COS                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 

Static Function Numero(cValor)
Local lRet	:= .t.       
Local nx	:=	0 
Local cChrValido:='1234567890"

cValor:=alltrim(cValor)

for nx:=1 to len(cValor)
    if !substr(cValor,nx,1) $ cChrValido
       lRet:= .f.
       exit
    endif
next

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImprimeLog  � Autor �GSANTACRUZ          � Data � 30/10/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ejecuta rutina para Visualizar/Imprimir log del proceso.   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �      													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function ImprimeLog()

Local aReturn		:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra��o"
Local aTitLog		:= {}  
Local cTamanho		:= "M"
Local cTitulo		:= "D152 Declaraci�n Anual" 
Local cDet			:= ""
Local nX			:= 0.00

Local aNewLog		:= {}
Local nTamLog		:= 0


aNewLog		:= aClone(aError)
nTamLog		:= Len( aError)

aLog := {}

If !Empty( aNewLog )
	aAdd( aTitLog , "E")
	aAdd( aLog , aClone( aNewLog ) )
Endif

/*
1 -	aLogFile 	//Array que contem os Detalhes de Ocorrencia de Log
2 -	aLogTitle	//Array que contem os Titulos de Acordo com as Ocorrencias
3 -	cPerg		//Pergunte a Ser Listado
4 -	lShowLog	//Se Havera "Display" de Tela
5 -	cLogName	//Nome Alternativo do Log
6 -	cTitulo		//Titulo Alternativo do Log
7 -	cTamanho	//Tamanho Vertical do Relatorio de Log ("P","M","G")
8 -	cLandPort	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
9 -	aRet		//Array com a Mesma Estrutura do aReturn
10-	lAddOldLog	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
*/

MsAguarde( { ||fMakeLog( aLog , , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},"Generando LOG...")

Return 

