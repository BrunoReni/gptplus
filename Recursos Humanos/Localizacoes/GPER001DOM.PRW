#INCLUDE "PROTHEUS.CH"  
#INCLUDE "GPER001DOM.CH"

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPER001DOM � Autor �  FMonroy                      � Data � 08/07/11 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Reporte DGT 2                                                       ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER001DOM()                                                        ���
����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                      ���
����������������������������������������������������������������������������������Ĵ��
���Programador � Data   �      FNC     �  Motivo da Alteracao                      ���
����������������������������������������������������������������������������������Ĵ��
���Christiane V�03/02/12�0000016417/2011�Corre��o de error log.                    ���
���Christiane V�07/02/12�0000016417/2011�Corre��o na impress�o das assinaturas.    ���
���            �        �               �                                          ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/

Function GPER001DOM() 
 
    Local cPerg      :="GPR001DOM"   
    Local oReport 
	Local aGetArea   := GetArea()
	
	Private cNomeProg :="GPER001DOM"
	Private cAliasSRD:=criatrab(nil,.f.)
	Private cSucI	:=	""
	Private cSucF	:=	""
	Private cProI	:=	""
	Private cProF	:=	""
	Private cProces  :=	""
	Private cPerI    :=	""
	Private cNumPagI :=	""
	Private cPerF    :=	""
	Private cNumPagF := 	""
	Private cMatI	:=	""
	Private cMatF	:=	""
	Private cObser	:=	""
	Private cMes	    :=	""
	Private cAnio	:=	""
	Private nMax:=32
	Private nLin:=49
	
	
	Private nMesA	:=	0

    Pergunte(cPerg,.F.)
    
	oReport:=ReportDef(cPerg)  
	oReport:PrintDialog() 

	RestArea(aGetArea)	
	
Return ( Nil )   
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef   Autor � FMonroy               � Data �08/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �  Def. Reporte DGT 2.                                       ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �  ReportDef(cExp1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  cExp1.-Nombre de la pregunta                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  GPER861                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ReportDef(cPerg) 
	
Local aArea      := GetArea() 

Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5
Local nIx :=0


Private cTitulo	:=OEMTOANSI(STR0067)//"Reporte DGT 2" 
 
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
oReport:=TReport():New(cNomeProg,OemToAnsi(cTitulo), cPerg  ,{|oReport| PrintReport(oReport)})	
oReport:nColSpace:= 0
oReport:nFontBody:= 4 // Define o tamanho da fonte.
oReport:CFONTBODY:="COURIER NEW"
oReport:Setlandscape(.T.)//Pag Horizontal  
oReport:lHeaderVisible:=.f.
oReport:oPage:nPaperSize:=9 //A4 210X297 mm


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
//� Creaci�n de la Primera Secci�n:  Encabezado                              �
//���������������������������������������������������������������������������� 

oSection1:= TRSection():New(oReport,/*"Enc"*/,,,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection1:SetLeftMargin(1)

TRCell():New(oSection1,"TITLE"   ,, ,,/*Tama�ano de la hoja*/)//"Atenci�n"
//��������������������������������������������������������������������������Ŀ
//� Creaci�n de la Segunda Secci�n:  Encabezado 2                            �
//���������������������������������������������������������������������������� 
oSection2:= TRSection():New(oReport,/*"Enc"*/,,,/*Campos do SX3*/,/*Campos do SIX*/)
oSection2:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection2:SetLeftMargin(1)

TRCell():New(oSection2,"TITLE1"   ,, ,,)
TRCell():New(oSection2,"TITLE2"   ,, ,,)
TRCell():New(oSection2,"TITLE3"   ,, ,,)     

oSection1:nLinesBefore:=0
oSection2:nLinesBefore:=0

//��������������������������������������������������������������������������Ŀ
//� Creaci�n de la Tercera Secci�n:  Encabezado del Detalle 3                �
//���������������������������������������������������������������������������� 
oSection3:= TRSection():New(oReport,/*"Enc"*/,,,/*Campos do SX3*/,/*Campos do SIX*/)
oSection3:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection3:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection3:SetLeftMargin(1)
oSection3:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor


TRCell():New(oSection3,"No",			,  , 		   ,3)	
TRCell():New(oSection3,"Nombre",		,  , 		   ,TamSx3("RA_NOME")[1])
TRCell():New(oSection3,"Cedula",		,  , 		   ,TamSx3("RA_CIC")[1]+3)
TRCell():New(oSection3,"SDSS",	    ,  ,           ,12)
TRCell():New(oSection3,"Valor",	    ,  ,           ,15)   
oSection3:Cell("Cedula"):lAutoSize := .F.
nIx:=1
While nIx < nMax
	TRCell():New(oSection3,alltrim(str(nIx)),	,  ,  ,5)
	nIx++
Enddo
TRCell():New(oSection3,"HorPag1", ,  ,  ,9)
TRCell():New(oSection3,"HorPag2",	,  ,  ,9)
TRCell():New(oSection3,"HorPag3",	,  ,  ,9)
TRCell():New(oSection3,"Horas", , ,  ,11)
TRCell():New(oSection3,"ValPag",, , ,15)	
TRCell():New(oSection3,"Causa",,  , ,12)
					
//��������������������������������������������������������������������������Ŀ
//� Creaci�n de la Cuarta Secci�n: Detalle                                   �
//���������������������������������������������������������������������������� 
oSection4:= TRSection():New(oReport,/*"Enc"*/,,,/*Campos do SX3*/,/*Campos do SIX*/)
oSection4:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection4:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection4:SetLeftMargin(1)
oSection4:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor

TRCell():New(oSection4,"No",, , ,3)	
TRCell():New(oSection4,"Nombre",,,,TamSx3("RA_NOME")[1])
TRCell():New(oSection4,"Cedula",,,,TamSx3("RA_CIC")[1])
TRCell():New(oSection4,"SDSS",,,,12)
TRCell():New(oSection4,"Valor",,,"999,999,999,999.99",15)
nIx:=1
While nIx < nMax
	TRCell():New(oSection4,alltrim(str(nIx)),,,"99.99",5)
	nIx++
Enddo
TRCell():New(oSection4,"HorPag1",, ,PesqPict("SRD","RD_HORAS"),9)
TRCell():New(oSection4,"HorPag2",, ,PesqPict("SRD","RD_HORAS"),9)
TRCell():New(oSection4,"HorPag3",, ,PesqPict("SRD","RD_HORAS"),9)

TRCell():New(oSection4,"Horas",,,"99,999,999.99" ,11)
TRCell():New(oSection4,"ValPag",,,"999,999,999,999.99",15)	
TRCell():New(oSection4,"Causa",,,,12)

//��������������������������������������������������������������������������Ŀ
//� Creaci�n de la Quinta Secci�n:  Firmas                                    �
//���������������������������������������������������������������������������� 
oSection5:= TRSection():New(oReport,/*"Enc"*/,,,/*Campos do SX3*/,/*Campos do SIX*/)
oSection5:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection5:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection5:SetLeftMargin(1)

TRCell():New(oSection5,"FIR1"   ,, ,,45)
TRCell():New(oSection5,"FIR2"   ,, ,,10)
TRCell():New(oSection5,"FIR3"   ,, ,,45)    
TRCell():New(oSection5,"FIR4"   ,, ,,10)    
TRCell():New(oSection5,"FIR5"   ,, ,,45)    
	
oSection1:nLinesBefore:=0
oSection2:nLinesBefore:=0	
oSection3:nLinesBefore:=0	
oSection4:nLinesBefore:=0	
oSection5:nLinesBefore:=0	

			
Return ( oReport )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrintReport Autor � FMonroy               � Data �29/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �   Impresi�n del Informe                                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �   PrintReport(oExp1)                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�   oExp1.-Objeto del reporte                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  GPER861                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function PrintReport(oReport) 

Local oSection4  := oReport:Section(4)

Local cTitle	  := ""     
Local cFilSRA     := xFilial( "SRA", SRD->RD_FILIAL)
Local cFilRCJ     := xFilial( "RCJ", SRD->RD_FILIAL)
Local cFilSRV     := xFilial( "SRV", SRD->RD_FILIAL)
Local cFilPro     := ""
Local cSelect     := ""
Local cMat        := ""
Local cConK       := ""

Local cSucActu    := ""

Local nTotal     :=  0                                 
Local nI:=0
Local nIx:=0
Local nlc:=0
Local Atot:={0,0,0,0} 


TodoOk()
Pergunte(oReport:GetParam(),.F.)   

#IFDEF TOP
			
	cSelect :="%"
	cSelect +=" SRA.RA_FILIAL, SRA.RA_PROCES, SRA.RA_MAT,SRA.RA_NOME,SRA.RA_CIC, "
	cSelect +=" SRA.RA_NSEGURO,SRA.RA_SALARIO,SRA.RA_TNOTRAB,RCJ.RCJ_FACCON, "
	cSelect +=" SRV.RV_HE,SRV.RV_PERC, SRD.RD_TIPO3,SRD.RD_HORAS,SRD.RD_VALOR,SRD.RD_PERIODO,SRD.RD_SEMANA,SRD.RD_ROTEIR,SRD.RD_DATPGT, SRD.RD_DTREF "
	cSelect +="%"
	
	cFilPro :=  "%"    
	CFILPRO += " SRD.RD_FILIAL BETWEEN '"  + cSucI + "' AND '"+ cSucF+"' "
	CFILPRO += " AND SRD.RD_PROCES BETWEEN '"  + cProI + "' AND '"+ cProF+"' "
	CFILPRO += " AND SRD.RD_MAT BETWEEN '"	 + cMatI + "' AND '"+ cMatF+"' "
	CFILPRO += " AND SRD.RD_PERIODO BETWEEN '" + cPerI + "' AND '"+ cPerF+"' "
	CFILPRO += " AND SRD.RD_SEMANA BETWEEN '"	 + cNumPagI + "' AND '"+ cNumPagF+"' "
	CFILPRO += " AND SRV.RV_HE = 'S' "
	cFilPro +=  "%"    
	
	BeginSql alias cAliasSRD
	
		SELECT	%exp:cSelect% 			
		FROM %table:SRD% SRD    
		INNER JOIN  %table:SRA% SRA 
		ON 	    SRA.RA_FILIAL  = SRD.RD_FILIAL AND
				SRA.RA_MAT    = SRD.RD_MAT
						INNER JOIN  %table:RCJ% RCJ 
		ON 	    RCJ.RCJ_FILIAL = %exp:cFilRCJ%	AND
				RCJ.RCJ_CODIGO = SRA.RA_PROCES
						INNER JOIN 	%table:SRV% SRV
		ON		SRV.RV_FILIAL = %exp:cFilSRV%	AND
				SRV.RV_COD    = SRD.RD_PD	   
		WHERE	
				%exp:cFilPro% 
				AND  SRA.%notDel% 
				AND  SRD.%notDel%  	 
				AND  RCJ.%notDel% 
				AND  SRV.%notDel% 
				
	ORDER BY SRA.RA_FILIAL, SRA.RA_PROCES, SRA.RA_MAT,SRD.RD_PERIODO,SRD.RD_SEMANA,SRD.RD_ROTEIR,SRD.RD_DATPGT
	
	
	
		
	EndSql 
    
		
#ELSE

	MSGERROR(STR0001)//"No esta disponible para DBF"
	
#ENDIF	
Begin Sequence  

	 dbSelectArea( cAliasSRD )
	 count to nTotal
	 oReport:SetMeter(nTotal) 
	 (cAliasSRD)->(DbGoTop()) 
	 If (cAliasSRD)->(!Eof())
		oReport:Skipline(2)
		While (cAliasSRD)->(!Eof())
			cSucActu:=(cAliasSRD)->RA_FILIAL
			nI:=0		
			While (cAliasSRD)->(!Eof()) .and. cSucActu==(cAliasSRD)->RA_FILIAL  
		
				//���������������������������������������������������Ŀ
				//� Imprime Encabezado   1                            �
				//����������������������������������������������������� 
				GPER861En(oReport)		
				//���������������������������������������������������Ŀ
				//� Imprime Encabezado   2                            �
				//����������������������������������������������������� 
				GPER861En2(oReport,1,(cAliasSRD)->RA_FILIAL)
				
				oSection4:init() 
				//���������������������������������������������������Ŀ
				//� Imprime Encabezado   3                            �
				//����������������������������������������������������� 
				oReport:Skipline(2)
				GPER861En3(oReport)
				oreport:fatline()		                   
				
				//���������������������������������������������������Ŀ
				//� Imprime Detalle                                   �
				//����������������������������������������������������� 
				nlc:=0
				While (cAliasSRD)->(!Eof()) .and. cSucActu==(cAliasSRD)->RA_FILIAL  .and. nlc<nLin        
					If alltrim(substr((cAliasSRD)->RD_DTREF,5,2))==cMes
						Atot:={0,0,0,00} 
						nI++
						nlc++
						oSection4:cell("No"):SETVALUE(ALLTRIM(STR(nI)))
						oSection4:cell("Nombre"):SETVALUE((cAliasSRD)->RA_NOME)
						oSection4:cell("Cedula"):SETVALUE((cAliasSRD)->RA_CIC)
						oSection4:cell("SDSS"):SETVALUE((cAliasSRD)->RA_NSEGURO)
						oSection4:cell("Valor"):SETVALUE( (((cAliasSRD)->RA_SALARIO/(cAliasSRD)->RCJ_FACCON)*23.83)/ posicione("SR6",1,xFilial( "SR6", SRD->RD_FILIAL)+(cAliasSRD)->RA_TNOTRAB,"R6_HRDIA") )			   
						nIx :=1
						while  nIx < nMax 
							oSection4:cell(alltrim(str(nIx))):SETVALUE(0)
							nIx++
						EndDo
						cMat:=(cAliasSRD)->RA_MAT 
						cConK:=""
						while (cAliasSRD)->(!Eof()) .and. cSucActu==(cAliasSRD)->RA_FILIAL .and. cMat==(cAliasSRD)->RA_MAT  
							
							
							oSection4:cell(alltrim(STR(VAL(SUBSTR((cAliasSRD)->RD_DTREF,7,2))))):SETVALUE((cAliasSRD)->RD_HORAS)
							Do Case
								case (cAliasSRD)->RV_PERC==135 
									aTot[1]:=aTot[1]+(cAliasSRD)->RD_HORAS	
									aTot[4]:=aTot[4]+(cAliasSRD)->RD_VALOR
								case (cAliasSRD)->RV_PERC==200
									aTot[2]:=aTot[2]+(cAliasSRD)->RD_HORAS	
									aTot[4]:=aTot[4]+(cAliasSRD)->RD_VALOR
								case (cAliasSRD)->RV_PERC!=135 .And. (cAliasSRD)->RV_PERC!=200
									aTot[3]:=aTot[3]+(cAliasSRD)->RD_HORAS	
									aTot[4]:=aTot[4]+(cAliasSRD)->RD_VALOR
							EndCase
							IF (AT(ALLTRIM((cAliasSRD)->RD_TIPO3),cConK) >0,,cConK:=cConK+ALLTRIM((cAliasSRD)->RD_TIPO3)+",")
							
						
							(cAliasSRD)->(dbSkip())
							oReport:IncMeter() 
						EndDo

						
						oSection4:cell("HorPag1"):SETVALUE(aTot[1])
						oSection4:cell("HorPag2"):SETVALUE(aTot[2])
						oSection4:cell("Horpag3"):SETVALUE(aTot[3])
						oSection4:cell("Horas"):SETVALUE(aTot[1]+aTot[2]+aTot[3])
						oSection4:cell("ValPag"):SETVALUE(aTot[4])
						
						oSection4:cell("Causa"):SETVALUE(substr(cConK,1,len(cConk)-1))
						
						oSection4:PrintLine() 
					Else	
						(cAliasSRD)->(dbSkip())
						oReport:IncMeter()
					EndIf
				EndDo //Fin  de archivo
				iif((cAliasSRD)->(Eof()) .or. cSucActu!=(cAliasSRD)->RA_FILIAL ,"",oReport:EndPage())
			EndDo
				oReport:Skipline(1)
				//���������������������������������������������������Ŀ
				//� Imprime P�e de P�gina (Firmas)                    �
				//����������������������������������������������������� 
				GPER861En2(oReport,2,cSucActu)
				oSection4:Finish() 
				//���������������������������������������������������Ŀ
				//� Imprime Observaciones                             �
				//����������������������������������������������������� 
				GPER861Ob(OREPORT)
				oReport:EndPage()

		enddo
	 EndIf //If fin de archivo 
End Sequence
(cAliasSRD)->(dbCloseArea()) 
Return (Nil)  
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPER861En � Autor � FMonroy               � Data �05/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Encabezado                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GPER861En(oExp1)    			     					      ���
���          �                      		     					      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oExp1: Objeto Treport   		     	                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER861                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GPER861En(oReport)

Local oSection1:=oReport:Section(1)
oSection1:Init()	
oReport:Skipline()
oReport:Skipline()
oSection1:cell("TITLE"):SetSize(oReport:GetWidth(),.t.)
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0003)*12))/2)/12)+STR0003+SPACE(((oReport:GetWidth()-(LEN(STR0003)*12))/2)/12))//Republica Dominicana
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0004)*12))/2)/12)+STR0004+SPACE(((oReport:GetWidth()-(LEN(STR0004)*12))/2)/12))//"SECRETARIA DE ESTADO DE TRABAJO"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0005)*12))/2)/12)+STR0005+SPACE(((oReport:GetWidth()-(LEN(STR0005)*12))/2)/12))//"DIRECCION GENERAL DE TRABAJO"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0006)*12))/2)/12)+STR0006+SPACE(((oReport:GetWidth()-(LEN(STR0006)*12))/2)/12))//"Av. Jim�nez Moya, Centro de los H�roes, Santo Domingo, Rep�blica Dominicana"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0007)*12))/2)/12)+STR0007+SPACE(((oReport:GetWidth()-(LEN(STR0007)*12))/2)/12))//"Tel�fono: (809)535-4404 � Fax (809) 535-4590. Correo Electr�nico : secret.trabajo@codetel.net.do - www.set.gov.do"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0008)*12))/2)/12)+STR0008+SPACE(((oReport:GetWidth()-(LEN(STR0008)*12))/2)/12))//"CAMBIOS EN LA PLANILLA DE PERSONAL FIJO"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0009)*12))/2)/12)+STR0009+SPACE(((oReport:GetWidth()-(LEN(STR0009)*12))/2)/12))//"(De conformidad con los Art.  17 del Reglamento No. 258-93 DEL C�digo del Trabajo)"
oSection1:Printline()
oSection1:Finish()

Return ( Nil )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPER861En2� Autor � FMonroy               � Data �05/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Encabezado                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GPER861En2(oExp1,nExp2)    	     					      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oExp1: Objeto Treport   		     					      ���
���          �nExp2: Bandera(1 Imprime Encabezado 2 Imprime Pie de Pag.)  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER861                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GPER861En2(oReport,nT,cFilialRa)

Local oSection2:=oReport:Section(2)
Local oSection1:=oReport:Section(1)
Local oSection5:=oReport:Section(5)

Local nPosS012:=0
Local nPosS112:=0
Local nPosS001:=0

Local cFilOri	:= SM0->M0_CODFIL

dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilialRa,.T.))

nPOSS001:=FPOSTAB("S001",VAL(ALLTRIM(SM0->M0_CEPENT)),"=",4)
	
nPosS012:=FPOSTAB("S012",CFILIALRA,"=",1)
If nPosS012 == 0
	nPosS012 := FPOSTAB("S012",Space(Len(xfilial("RCB"))),"=",1)
Endif

nPosS112:=FPOSTAB("S112",CFILIALRA,"=",1)
If nPosS112 == 0
	nPosS112:=FPOSTAB("S112",Space(Len(xfilial("RCB"))),"=",1)
Endif


IF nt==1
	oSection2:Init()	
	oSection1:Init()
	oSection2:cell("TITLE1"):SetSize((oReport:GetWidth()/3)/14)
	oSection2:cell("TITLE2"):SetSize((oReport:GetWidth()/2)/14)
	oSection2:cell("TITLE3"):SetSize((oReport:GetWidth()/3)/14)
	
	oSection2:cell("TITLE1"):SETVALUE(STR0010 + " : " + IIf(!nPosS012 == 0 , AllTrim(STR(FTABELA("S012",NPOSS012,5))), " " ) )//"R.N.C. No." FTABELA("S012",NPOSTAB,5)
	oSection2:cell("TITLE2"):SETVALUE(space(((oReport:GetWidth()/3)/14)))
	oSection2:cell("TITLE3"):SETVALUE(STR0011)//"Registro Nacional Laboral RNL"
	oSection2:Printline()
	oSection2:cell("TITLE1"):SETVALUE(STR0012 + " : " + IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,7), " " ))//"No.de Seguridad Social"FTABELA("S012",NPOSTAB,7)
	oSection2:cell("TITLE2"):SETVALUE(space(((oReport:GetWidth()/3)/14)))
	oSection2:cell("TITLE3"):SETVALUE(SPACE(((oReport:GetWidth()/3-LEN(STR0013)*12)/2)/12)+STR0013+SPACE(((oReport:GetWidth()/3-LEN(STR0013)*12)/2)/12))//"SOLO PARA USO DE LA SET"
	oSection2:Printline()
		
	oSection2:cell("TITLE1"):SETVALUE(STR0014+" : "+cMes+SPACE(5)+STR0015+" : "+cAnio )//"Mes Reportado"##"A�o"
	oSection2:cell("TITLE2"):SETVALUE(space((oReport:GetWidth()/3)/14))
	oSection2:cell("TITLE3"):SETVALUE(STR0016+" : ")//"Registro de Planilla No."
	oSection2:Printline()

	//Raz�n Social de la empresa: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	Nombre del empleador: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX		C�dula: XXXXXXXXXX			Rama de Actividad No.:	
		
	oSection2:cell("TITLE1"):SETVALUE(STR0017+" : " + SM0->M0_NOMECOM)//"Raz�n Social de la empresa"
	oSection2:cell("TITLE2"):SETVALUE(STR0018+" : " + IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,9), " ") +SPACE(5)+STR0019+" : " + IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,10), " " ))//"Nombre del empleador"##"C�dula"
	oSection2:cell("TITLE3"):SETVALUE(STR0020+" : ")//"Rama de Actividad No."
	oSection2:Printline()

	//Nombre del establecimiento: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	Nombre del representante: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX		C�dula: XXXXXXXXXX			Sucursal: S o N			

	oSection2:cell("TITLE1"):SETVALUE(STR0021+" : " + IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,9), " " ) )//"Nombre del establecimiento"
	oSection2:cell("TITLE2"):SETVALUE(STR0022+" : " + IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,11), " " )+SPACE(5)+STR0023+" : " + IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,12), " " ) )//"Nombre del representante" ##"C�dula"
	oSection2:cell("TITLE3"):SETVALUE(STR0024+" : " + IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,14), " " ))//"Sucursal"
	oSection2:Printline()
	//Direcci�n (Ave./C y #):  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	Sector: XXXXXXXXXXXXXXXXXXXXXXXXX		Municipio: XXXXXXXXXXXXXXXXXXXXXXXXXXX	Secci�n: XXXXXXXXXXXXXXXXXXXXXXXXXXXXX	Provincia: XXXXXXXXXXXXXXXXXXXXXX	
	oSection1:cell("TITLE"):SetSize(oReport:GetWidth())
		
	oSection1:cell("TITLE"):SetValue(STR0025+":"+space(1)+SM0->M0_ENDCOB+space(1)+STR0026+":"+space(1)+ IIf(!nPosS012 == 0, FTABELA("S012",nPosS012,13), " " )+space(5)+STR0027+":"+ space(1)+IIf(!nPosS001 == 0, FTABELA("S001",NPOSS001,6), " " ) + space(1)+STR0028+":"+ IIf(!nPosS112 == 0, FTABELA("S112",NPOSS112,12), " ")+space(1)+STR0029+":"+space(1)+IIf(!nPosS001 == 0, FTABELA("S001",NPOSS001,5), " " )	)//"Direcci�n (Ave./C y #)"##"Sector"##"Municipio"##"Secci�n"##"Provincia"
	oSection1:Printline()
	//Tel�fono: 99999999999	Fax: 99999999999999	Correo electr�nico: 	www.XXXXXXXXXXXXXXXXXX    Zona Franca: S o N		Parque: XXXXXXXXXXXXXXXXXXXXXXX	
	oSection1:cell("TITLE"):SetValue(STR0030+":"+space(2) + SM0->M0_TEL+space(2)+STR0031+":"+space(1)+ SM0->M0_FAX+space(5)+STR0032+":"+ space(1)+ IIf(!nPosS112 == 0, FTABELA("S112",NPOSS112,5), " ")+SPACE(2)+ IIf(!nPosS112 == 0, FTABELA("S112",NPOSS112,4) , " ")+ space(5)+STR0033+" : "+ IIf(!nPosS112 == 0, FTABELA("S012",NPOSS012,6), " ")+space(5)+STR0034+":"+space(1)+ IIf(!nPosS012 == 0, FTABELA("S112",NPOSS112,6), " "))//"Tel�fono"##"Fax"##"Correo electr�nico"##"WWW "##"Zona Franca"##"Parque"
	oSection1:Printline()

	//A que se dedica la empresa	S112?Ocupacion substring(RCC_CONTEU,178,60)	
	oSection1:cell("TITLE"):SetValue(STR0035+" : "+ IIf(!nPosS112 == 0, FTABELA("S112",NPOSS112,13), " ")+SPACE(40)+STR0036+" : "+ IIf(!nPosS112 == 0, transform(FTABELA("S112",NPOSS112,7),"999,999,999,999.99" ), " "))//"A que se dedica la empresa"
	oSection1:Printline()
	oSection1:Finish()
	oSection2:Finish()
ELSE
	oSection5:init()
	oSection5:cell("FIR1"):SetValue(space(7)+ IIf(!nPosS112 == 0, FTABELA("S112",NPOSS112,8), " "))
	oSection5:cell("FIR2"):SetValue(SPACE(1))
	oSection5:cell("FIR3"):SetValue(SPACE(1))
	oSection5:cell("FIR4"):SetValue(SPACE(1))
	oSection5:cell("FIR5"):SetValue(SPACE(1))
	oSection5:Printline()
	oSection5:cell("FIR1"):SetValue(REPLICATE('_',45))
	oSection5:cell("FIR2"):SetValue(SPACE(1))
	oSection5:cell("FIR3"):SetValue(REPLICATE('_',45))
	oSection5:cell("FIR4"):SetValue(SPACE(1))
	oSection5:cell("FIR5"):SetValue(REPLICATE('_',45))
	oSection5:Printline()
	oSection5:cell("FIR1"):SetValue(space(5)+STR0039)//"Firma del Empleador o Representante"
	oSection5:cell("FIR2"):SetValue(SPACE(1))
	oSection5:cell("FIR3"):SetValue(space(11)+STR0037)//"Nombre del Inspector"
	oSection5:cell("FIR4"):SetValue(SPACE(1))
	oSection5:cell("FIR5"):SetValue(space(13)+STR0038)//"Firma del Inspector"
	oSection5:Printline()
	oSection5:Finish()
ENDIF
//������������������������������������������Ŀ
//�Volta a empresa anteriormente selecionada.�
//��������������������������������������������
dbSelectArea("SM0")

SM0->(dbSeek(cEmpAnt+cFilOri,.T.))

cFilAnt := SM0->M0_CODFIL
Return ( Nil )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPER861En3� Autor � FMonroy               � Data �05/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Encabezado                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GPER861En3(oExp1)    			     					      ���
���          �                      		     					      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oExp1: Objeto Treport   		     	                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER861                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function GPER861En3(oReport)

Local oSection3:=oReport:Section(3)
Local oSection1:=oReport:Section(1)
Local nI:=0

oSection3:Init()	
oSection1:Init()	
oSection1:cell("TITLE"):SetValue(space(106)+STR0040)//"Detalle de D�as y Horas Laboradas durante el mes"
oSection1:Printline()
oSection3:cell("No"):SETVALUE(STR0041)//No.	
oSection3:cell("Nombre"):SETVALUE(STR0042)//Nombre y Apellido 
oSection3:cell("Cedula"):SETVALUE(STR0043)//"Cedula de "	
oSection3:cell("SDSS"):SETVALUE(STR0044)//No. Sistema
oSection3:cell("Valor"):SETVALUE(STR0045)//Valor de la Hora normal en (RD$)
nI:=1
While nI<nMax
	oSection3:cell(alltrim(str(nI))):SETVALUE(alltrim(str(nI)))
	nI++
EndDo
oSection3:cell("HorPag1" ):SETVALUE(STR0046)//Horas 
oSection3:cell("HorPag2" ):SETVALUE(STR0046)//Horas
oSection3:cell("HorPag3"):SETVALUE(STR0046)//Horas 
oSection3:cell("Horas"):SETVALUE(STR0047)//Total 
oSection3:cell("ValPag"):SETVALUE(STR0048)//Valor 
oSection3:cell("Causa"):SETVALUE(STR0049)//Causa de la 
oSection3:Printline()

oSection3:cell("No"):SETVALUE(space(1))
oSection3:cell("Nombre"):SETVALUE(STR0050)//del Trabajador
oSection3:cell("Cedula"):SETVALUE(STR0051)//"identidad y"
oSection3:cell("SDSS"):SETVALUE(STR0052)//"Dominicano"
oSection3:cell("Valor"):SETVALUE(STR0053)//normal en (RD$)
nI:=1
While  nI<nMax
	oSection3:cell(alltrim(str(nI))):SETVALUE(space(1))
	nI++
EndDo
oSection3:cell("HorPag1" ):SETVALUE(STR0054)//Pagadas
oSection3:cell("HorPag2" ):SETVALUE(STR0054)//Pagadas
oSection3:cell("HorPag3"):SETVALUE(STR0054)//Pagadas
oSection3:cell("Horas"):SETVALUE(STR0054)//Pagadas
oSection3:cell("ValPag"):SETVALUE(STR0055)//"Pagado"
oSection3:cell("Causa"):SETVALUE(STR0056)//Prolongaci�n
oSection3:Printline()

oSection3:cell("No"):SETVALUE(space(1))
oSection3:cell("Nombre"):SETVALUE(space(1))
oSection3:cell("Cedula"):SETVALUE(STR0057)//"Electoral"
oSection3:cell("SDSS"):SETVALUE(STR0058)//"de Seguridad"
oSection3:cell("Valor"):SETVALUE(space(1))
nI:=1
While  nI<nMax
	oSection3:cell(alltrim(str(nI))):SETVALUE(space(1))
	nI++
EndDo
oSection3:cell("HorPag1" ):SETVALUE(STR0059)//"a un 35%"
oSection3:cell("HorPag2" ):SETVALUE(STR0060)//"a un 100%"
oSection3:cell("HorPag3"):SETVALUE(STR0061)//a Otro
oSection3:cell("Horas"):SETVALUE(space(1))
oSection3:cell("ValPag"):SETVALUE(space(1))
oSection3:cell("Causa"):SETVALUE(space(1))
oSection3:Printline()

oSection3:cell("No"):SETVALUE(space(1))
oSection3:cell("Nombre"):SETVALUE(space(1))
oSection3:cell("Cedula"):SETVALUE(space(1))
oSection3:cell("SDSS"):SETVALUE(STR0062)//"Social SDSS"
oSection3:cell("Valor"):SETVALUE(space(1))
nI:=1
While  nI<nMax
	oSection3:cell(alltrim(str(nI))):SETVALUE(space(1))
	nI++
EndDo
oSection3:cell("HorPag1" ):SETVALUE(space(1))
oSection3:cell("HorPag2" ):SETVALUE(space(1))
oSection3:cell("HorPag3"):SETVALUE(space(1))
oSection3:cell("Horas"):SETVALUE(space(1))
oSection3:cell("ValPag"):SETVALUE(space(1))
oSection3:cell("Causa"):SETVALUE(space(1))
oSection3:Printline()

oSection3:Finish()

Return ( Nil )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPER861Ob � Autor � FMonroy               � Data �05/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Observaciones                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GPER861Ob(oExp1)    			     					      ���
���          �                      		     					      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oExp1: Objeto Treport   		     	                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPER861                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GPER861Ob(oReport)

Local oSection1:=oReport:Section(1)
oSection1:Init()	
oReport:Skipline(1)
oSection1:cell("TITLE"):SetSize(oReport:GetWidth(),.t.)
oSection1:cell("TITLE"):SETVALUE(STR0063+" : "+cObser)//"Observaciones"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(len(STR0063)+3)+replicate("_",len(cObser)) )
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(STR0064)
oSection1:Printline()
oSection1:Finish()

Return (Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPR01DOM01� Autor � FMonroy               � Data �05/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacion de las preguntas                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER86101()											      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Ninguno						                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X1_VALID - GPER861 En X1_ORDEM = 7                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function GPR01DOM01() 
                                   
Local	cMes:=SUBSTR(strZERO(MV_PAR12,6),1,2)
Local   dFechI:= Posicione("RCH",RETORDEM("RCH","RCH_FILIAL+RCH_PER+RCH_NUMPAG+RCH_PROCES+RCH_ROTEIR"),XFILIAL("RCH")+MV_PAR06+MV_PAR07+MV_PAR03+MV_PAR05,"RCH_DTINI")
Local   dFechF:= Posicione("RCH",RETORDEM("RCH","RCH_FILIAL+RCH_PER+RCH_NUMPAG+RCH_PROCES+RCH_ROTEIR"),XFILIAL("RCH")+MV_PAR08+MV_PAR09+MV_PAR03+MV_PAR05,"RCH_DTINI")
Local   dFech:= ctod(""+SUBSTR(DTOS(dFechI),7,2) +"/"+cMes+"/"+SUBSTR(strZERO(MV_PAR12,6),3,4)+"")
	
IF val(cMes)<1 .or.val(cMes)>12
	msginfo(STR0065)//"El mes debe ser de 1 a 12!"
	Return .F.
ENDIF   
If   dFech< dFechI .OR.   dFech> dFechF       
	msginfo(STR0066)//El mes y a�o debe ser correspondiente al Periodo"
	Return .F.
EndIf


Return (.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �TodoOK    �Autor  �Microsiga           � Data �  08/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacion de los datos antes de Ejecutar el proceso        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TodoOK(cPerg)

	Pergunte(cPerg,.F.)

	cSucI	:=	MV_PAR01
	cSucF	:=	MV_PAR02
	cProI	:=	MV_PAR03
	cProF	:=	MV_PAR04
	cProces  :=	MV_PAR05
	cPerI    :=	MV_PAR06
	cNumPagI :=	MV_PAR07
	cPerF    :=	MV_PAR08
	cNumPagF := MV_PAR09
	cMatI	:=	MV_PAR10
	cMatF	:=	MV_PAR11
	cObser	:=	MV_PAR13
	cMes	:=	SUBSTR(strZERO(MV_PAR12,6),1,2)
	cAnio	:=	SUBSTR(strZERO(MV_PAR12,6),3,4)
	nMesA	:=	MV_PAR12

Return (.T.)

