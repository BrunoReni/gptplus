#Include 'Protheus.ch'
#Include 'PLSRDIP.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"


#Define _LF Chr(13)+Chr(10) // Quebra de linha.
#Define _BL 25
#Define __NTAM1  10
#Define __NTAM2  10
#Define __NTAM3  20
#Define __NTAM4  25
#Define __NTAM5  38
#Define __NTAM6  15
#Define __NTAM7  5
#Define __NTAM8  9
#Define __NTAM9  7
#Define __NTAM10 30
#Define __NTAM11 8
#Define Moeda "@E 999,999,999.99"

STATIC oFnt10C 		:= TFont():New("Arial",10,10,,.f., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt11N 		:= TFont():New("Arial",11,11,,.T., , , , .t., .f.)
STATIC oFnt12N 		:= TFont():New("Arial",14,14,,.T., , , , .t., .f.)
STATIC oFnt09C 		:= TFont():New("Arial",9,9,,.f., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",18,18,,.t., , , , .t., .f.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSRDIP� Autor �Roberto Arruda       	� Data �02/02/2017���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera��o de arquivo PDF. DIOPS - Distribui��o Saldos Pagar  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS			                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PLSRDIP(lWeb,aParWeb,cDirPath,cBenefLog)

Local aResult := {}

DEFAULT lWeb			:= .f.
DEFAULT aParWeb		:= {}
DEFAULT cDirPath		:= lower(getMV("MV_RELT"))
DEFAULT cBenefLog	  	:= ""

PRIVATE cTitulo 		:= "Idade de Saldos - Pagar"
PRIVATE oReport     	:= nil
PRIVATE cFileName		:= "idade_saldos_pagar"+CriaTrab(NIL,.F.)

//aResult := PLSRDIQRP() //Executa Query e retorna array com resultado.


Private cPerg		:= "PLSRDIPR"

If  Pergunte("PLSRDIPR",.T.)//nOpca == 1
	If Empty(MV_PAR01)
		MsgInfo(STR0002,STR0001) //"Par�metro n�o informado, por favor informar."#"DIOPS - Distribui��o dos Saldos de Contas a Pagar"
	else
		Processa( {|| aResult := PLSRDIQRP(LastDay(MV_PAR01),.T.)}, STR0001) //
		
		oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,nil,.f.,.f.,.t.)
		
		oReport:lInJob  	:= lWeb
		oReport:lServer 	:= lWeb
		oReport:cPathPDF	:= cDirPath
		
		oReport:setDevice(IMP_PDF)
		oReport:setResolution(72)
		oReport:SetLandscape()
		oReport:SetPaperSize(9)
		oReport:setMargin(10,10,10,10)
		
		IF !lWeb
			oReport:Setup()  //Tela de configura��es
		ENDIF
		
		lRet := PLSDIPRL(aResult) //Recebe Resultado da Query e Monta Relat�rio 
		
		//lRet := PLSDIDIDA(oReport,lWeb,aParWeb,cBenefLog)
		
		if lRet
			aRet := {cFileName+".pdf",""}
		else
			aRet := {"",""}
		endif
		
		IF (lRet)
			oReport:EndPage()
			oReport:Print()
		ENDIF	
		
		
		//��������������������������������������������������������������
		//�Checa se o arquivo PDF esta ponto para visualizacao na web 
		//���������������������������������������������������������������
		if lWeb
			PLSCHKRP(cDirPath, cFileName+".pdf")
		endIf
	endif
endif

return 

Function PLSDIPRL(aValores)

LOCAL lRet			:= .T.
Local nI			:= 0
Local nSom			:= 0
Local nLinha		:= 0
Local cValor 		:= ""
Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro

Local aTotais       := {0,0,0,0,0,0,0,0,0,0,0,0}
//Local aTotais       := {1,2,3,4,5,6,7,8,9,10,11,12}
Local nValor 		:= 0

oReport:StartPage()

//Logotipo ANS
cBMP	:= "lgdiopsidr.bmp"

If File("lgdiopsidr" + FWGrpCompany() + FWCodFil() + ".bmp")
	cBMP :=  "lgdiopsidr" + FWGrpCompany() + FWCodFil() + ".bmp" 
ElseIf File("lgdiopsidr" + FWGrpCompany() + ".bmp")
	cBMP :=  "lgdiopsidr" + FWGrpCompany() + ".bmp" 
EndIf

oReport:SayBitmap(40, 25, cBMP, , 50,150)

oReport:box(30, 20, 375, 805 )  //Box principal
oReport:box(30, 20, 100, 805)	//Box Titulo
oReport:Say(75, 300, STR0001, oFnt14N)  //"DISTRIBUI��O DOS SALDOS DE CONTAS A PAGAR"

oReport:SayBitmap(40, 25, cBMP, , 50,150)

oReport:box(100, 20, 200, 135) //Box Vencimento Financeiro
oReport:Say(160, 60, STR0042, oFnt11N)  //"Vencimento"
oReport:Say(175, 60, STR0043, oFnt11N)	 //"Financeiro"

oReport:box(100, 135, 175 , 580)   //580 Largura
oReport:Say(120, 250, STR0044, oFnt12N) //"D�bitos de Opera��es com Planos de Sa�de"

oReport:box(100, 580, 175 , 805)   
oReport:Say(112, 590, STR0045, oFnt12N) //"Outros D�bitos N�o Relacionados com"
oReport:Say(125, 650, STR0046, oFnt12N) //"Planos de Sa�de"


oReport:box(130, 135, 200, 190) 
oReport:Say(155, 138, STR0003, oFnt10c)  //"Eventos/"
oReport:Say(165, 138, STR0004, oFnt10c)  //"Sinistros a"
oReport:Say(175, 138, STR0005, oFnt10c)  //"Liquidar"
oReport:Say(185, 138, STR0006, oFnt10c)  //"(SUS)"	


oReport:box(130, 190, 200, 245)
oReport:Say(155, 193, STR0003, oFnt10c)	//"Eventos/"
oReport:Say(165, 193, STR0004, oFnt10c)	//"Sinistros a"  
oReport:Say(175, 193, STR0005, oFnt10c)	//"Liquidar"


oReport:box(130, 245, 200, 300) 
oReport:Say(155, 248, STR0007, oFnt10c)  //"Comercializ"
oReport:Say(165, 248, STR0008, oFnt10c)  //"a��o sobre"
oReport:Say(175, 248, STR0009, oFnt10c)  //"opera��es"	


oReport:box(130, 300, 200, 355) 
oReport:Say(155, 303, STR0010, oFnt10c)  //"D�bitos"
oReport:Say(165, 303, STR0011, oFnt10c)  //"com"
oReport:Say(175, 303, STR0012, oFnt10c)  //"operadoras"

oReport:box(130, 355, 200, 410) 
oReport:Say(155, 358, STR0013, oFnt10c)  //"Outros"
oReport:Say(165, 358, STR0014, oFnt10c)  //"D�bitos de"
oReport:Say(175, 358, STR0015, oFnt10c)  //"Opera��es"
oReport:Say(185, 358, STR0016, oFnt10c)  //"com Planos"


oReport:box(130, 410, 200, 465) 
oReport:Say(155, 413, STR0017, oFnt10c)  //"Tributos e"
oReport:Say(165, 413, STR0018, oFnt10c)  //"Encargos a"
oReport:Say(175, 413, STR0019, oFnt10c)  //"Recolher"


oReport:box(130, 465, 200, 520) 
oReport:Say(155, 468, STR0020, oFnt10c)  //"Dep�sitos de"
oReport:Say(165, 468, STR0021, oFnt10c)  //"Benefici�rios -"
oReport:Say(175, 468, STR0022, oFnt10c)  //"Contraprest/"
oReport:Say(185, 468, STR0023, oFnt10c)  //"Seguros"
oReport:Say(195, 468, STR0024, oFnt10c)  //"Recebidos"

oReport:box(130, 520, 200, 580) 
oReport:Say(170, 540, STR0025, oFnt10c)  //"Total"


//Outros d�bitps n�o relacionados com Plano de Sa�de

oReport:box(130, 580, 200, 635) 
oReport:Say(155, 583, STR0026, oFnt10c)  //"Prestadores"
oReport:Say(165, 583, STR0027, oFnt10c)  //"de Serv. de"
oReport:Say(175, 583, STR0028, oFnt10c)  //"Assist�ncia"
oReport:Say(185, 583, STR0029, oFnt10c)  //"a Sa�de"

oReport:box(130, 635, 200, 690) 
oReport:Say(155, 638, STR0030, oFnt10c)  //"D�bitos com"
oReport:Say(165, 638, STR0031, oFnt10c)  //"Aquisi��o de"
oReport:Say(175, 638, STR0032, oFnt10c)  //"Carteira"

oReport:box(130, 690, 200, 745) 
oReport:Say(155, 693, STR0013, oFnt10c)  //"Outros"
oReport:Say(165, 693, STR0033, oFnt10c)  //"D�bitos a"
oReport:Say(175, 693, STR0034, oFnt10c)  //"Pagar"

oReport:box(130, 745, 200, 805) 
oReport:Say(170, 765, STR0025, oFnt10c)  //"Total"

//Box Linha dos vencimentos
oReport:box(200, 20, 215, 805)
oReport:Fillrect( {201, 21, 216, 804 }, oBrush1)		
	
oReport:box(215, 20, 240, 805)
oReport:Say(228, 23, STR0035, oFnt10N) //"A vencer"


oReport:box(240, 20, 265, 805)
oReport:Say(253, 23, STR0036, oFnt10N) //"Vencidos de 1 a 30 dias"


oReport:box(265, 20, 290, 805)
oReport:Say(278, 23, STR0037, oFnt10N) //"Vencidos de 31 a 60 dias"

	
oReport:box(290, 20, 315, 805)
oReport:Say(303, 23, STR0038, oFnt10N)  //"Vencidos de 61 a 90 dias"

		
oReport:box(315, 20, 340, 805)
oReport:Say(328, 23, STR0039, oFnt10N)	 //"Vencidos de 91 a 120 dias"

oReport:box(340, 20, 365, 805)
oReport:Say(353, 23, STR0040, oFnt10N)	 //"Vencidos a mais de 120 dias"
	
			
oReport:box(365, 20, 390, 805)
oReport:Say(378, 90, STR0041, oFnt10N)  //Saldos


//Line das colunas
nSom := 0
For nI := 1 to 13
	oReport:Line(200, 135 + nSom, 390, 135 + nSom)
	
	if nI <> 8 .and. nI <> 12
		nSom += 55
	else
		nSom += 60
	endif
Next

//****************************
//Impress�o dos Valores
//****************************
//**** Linha dos "A VENCER" ******
nSom := 0
For nI := 2 to 8
	cValor := aValores[1][nI]
	oReport:Say(228, 136 + nSom, cValtoChar(cValor)/*"1234567890123"*/, oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI -1] := aTotais[nI - 1] + cValor
Next

oReport:Say(228, 136  + nSom, cValToChar(nValor), oFnt11N)  //"Total"
nSom += 65
aTotais[nI-1] := aTotais[nI-1] + nValor

nLinha := (136 + nSom - 5) //Diferen�a de 70 para 65
nSom := 0
nValor := 0

For nI := 9 To 11
	cValor := aValores[1][nI]
	oReport:Say(228, nLinha + nSom, cValtoChar(cValor)/*"1234567890123"*/, oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI] := aTotais[nI] + cValor
Next

oReport:Say(228, nLinha  + nSom + 1, cValToChar(nValor), oFnt11N)  //"Total"
aTotais[nI] := aTotais[nI] + nValor

//**************** Linha dos "VENCIDOS de 1 a 30 dias" ********************
nSom := 0
nValor:= 0
For nI := 2 to 8
	cValor := aValores[2][nI]
	oReport:Say(253, 136 + nSom, cValtoChar(cValor), oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI -1] := aTotais[nI - 1] + cValor
Next

oReport:Say(253, 136  + nSom, cValToChar(nValor), oFnt11N)  //"Total"
nSom += 65
aTotais[nI-1] := aTotais[nI-1] + nValor

nLinha := (136 + nSom - 5) //Diferen�a de 70 para 65
nSom := 0
nValor := 0


For nI := 9 To 11
	cValor := aValores[2][nI]
	oReport:Say(253, nLinha + nSom, cValtoChar(cValor), oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI] := aTotais[nI] + cValor
Next

oReport:Say(253, nLinha  + nSom + 1, cValToChar(nValor), oFnt11N)  //"Total"
aTotais[nI] := aTotais[nI] + nValor

//************************** Linha dos "VENCIDOS de 31 a 60 dias" ********************
nSom := 0
nValor:= 0
For nI := 2 to 8
	cValor := aValores[3][nI]
	oReport:Say(278, 136 + nSom, cValtoChar(cValor), oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI -1] := aTotais[nI - 1] + cValor
Next

oReport:Say(278, 136  + nSom, cValToChar(nValor), oFnt11N)  //"Total"
nSom += 65
aTotais[nI-1] := aTotais[nI-1] + nValor

nLinha := (136 + nSom - 5) //Diferen�a de 70 para 65
nSom := 0
nValor := 0

For nI := 9 To 11
	cValor := aValores[3][nI]
	oReport:Say(278, nLinha + nSom, cValtoChar(cValor), oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI] := aTotais[nI] + cValor	
	
Next

oReport:Say(278, nLinha  + nSom + 1, cValToChar(nValor), oFnt11N)  //"Total"
aTotais[nI] := aTotais[nI] + nValor

//************************** Linha dos "VENCIDOS de 61 a 90 dias" **************************
nSom := 0
nValor:= 0
For nI := 2 to 8
	cValor := aValores[4][nI]
	oReport:Say(303, 136 + nSom, cValtoChar(cValor)/*"1234567890123"*/, oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI -1] := aTotais[nI - 1] + cValor	
Next

oReport:Say(303, 136  + nSom, cValToChar(nValor), oFnt11N)  //"Total"
nSom += 65
aTotais[nI-1] := aTotais[nI-1] + nValor

nLinha := (136 + nSom - 5) //Diferen�a de 70 para 65
nSom := 0
nValor := 0

For nI := 9 To 11
	cValor := aValores[4][nI]
	oReport:Say(303, nLinha + nSom, cValtoChar(cValor)/*"1234567890123"*/, oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI] := aTotais[nI] + cValor	
Next

oReport:Say(303, nLinha  + nSom + 1, cValToChar(nValor), oFnt11N)  //"Total"
aTotais[nI] := aTotais[nI] + nValor

//************************** Linha dos "VENCIDOS a MAIS de 90 dias" *********************
nSom := 0
nValor:= 0
For nI := 2 to 8
	cValor := aValores[5][nI]
	oReport:Say(328, 136 + nSom, cValtoChar(cValor)/*"1234567890123"*/, oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI -1] := aTotais[nI - 1] + cValor
Next

oReport:Say(328, 136  + nSom, cValToChar(nValor), oFnt11N)  //"Total"
nSom += 65
aTotais[nI-1] := aTotais[nI-1] + nValor

nLinha := (136 + nSom - 5) //Diferen�a de 70 para 65
nSom := 0
nValor := 0

For nI := 9 To 11
	cValor := aValores[5][nI]
	oReport:Say(328, nLinha + nSom, cValtoChar(cValor)/*"1234567890123"*/, oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI] := aTotais[nI] + cValor	
Next

oReport:Say(328, nLinha  + nSom + 1, cValToChar(nValor), oFnt11N)  //"Total"
aTotais[nI] := aTotais[nI] + nValor

//********************** Linha dos "VENCIDOS a MAIS de 90 dias" ***********************
nSom := 0
nValor:= 0
For nI := 2 to 8
	cValor := aValores[6][nI]
	oReport:Say(353, 136 + nSom, cValtoChar(cValor)/*"1234567890123"*/, oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI -1] := aTotais[nI - 1] + cValor				
Next

oReport:Say(353, 136  + nSom, cValToChar(nValor), oFnt11N)  //"Total"
nSom += 65
aTotais[nI-1] := aTotais[nI-1] + nValor

nLinha := (136 + nSom - 5) //Diferen�a de 70 para 65
nSom := 0
nValor := 0

For nI := 9 To 11
	cValor := aValores[6][nI]
	oReport:Say(353, nLinha + nSom, cValtoChar(cValor)/*"1234567890123"*/, oFnt11N)  //"SALDO"
	nSom += 55
	nValor := nValor + cValor
	aTotais[nI] := aTotais[nI] + cValor
Next

oReport:Say(353, nLinha  + nSom + 1, cValToChar(nValor), oFnt11N)  //"Total"
aTotais[nI] := aTotais[nI] + nValor

//****************** Linha do SALDO ***********************
nSom := 0
For nI := 1 to 7
	oReport:Say(378, 136 +  nSom, cValToChar(aTotais[nI]) /*"1234567890123"*/, oFnt11N)  //"SALDO"
	nSom += 55
Next

oReport:Say(378, 136  + nSom, cValToChar(aTotais[8]), oFnt11N)  //"Total"
nSom += 65

nLinha := (136 + nSom - 5) //Diferen�a de 70 para 65
nSom := 0

For nI := 9 To 12
	oReport:Say(378, nLinha + nSom, cValToChar(aTotais[nI]), oFnt11N)  //"SALDO"
	nSom += 55
Next

return lRet



Function PLSRDIQRP(dDtVcto,lMsg)

Local nCount := 0
Local aRetSalPag	:= {;
{  0,0,0,0,0,0,0,0,0,0,0 },;
{ 30,0,0,0,0,0,0,0,0,0,0},;
{ 60,0,0,0,0,0,0,0,0,0,0},;
{ 90,0,0,0,0,0,0,0,0,0,0},;
{120,0,0,0,0,0,0,0,0,0,0},;
{121,0,0,0,0,0,0,0,0,0,0},;
{999,0,0,0,0,0,0,0,0,0,0} }

Local nPosCta	:= 0
Local nDiavcto	:= 0
Local dataate	:= ""

Default dDtVcto	:= LastDay(dDataBase)
Default lMsg	:= .T.

dataate := DtoS(dDtVcto)

cSql := ""
cSql += " Select * From ("
cSql += " Select CONTA, VENCTO, SUM(VALOR) SALDO From ("
cSql += " Select CT2_DATA, CONTA, VALOR, RECCT2, FK2_DATa, FK2_DTDISP, COALESCE(SE2.E2_VENCTO ,  SE2K.E2_VENCTO, SE2L.E2_VENCTO, CT2_DATA) VENCTO, COALESCE(SE2.R_E_C_N_O_ ,SE2K.R_E_C_N_O_, SE2L.R_E_C_N_O_, 0) RECSE2  from ("
cSql += " Select DISTINCT "
cSql += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_CREDIT CONTA, CT2_VALOR VALOR, CT2.R_E_C_N_O_ RECCT2 "
cSql += " , COALESCE(CV3_TABORI, '   ') TABORI, COALESCE(CV3_RECORI, 0) RECORI "    //", FK2_IDDOC, FK7_CHAVE "
cSql += " from " + retSqlName("CT2") + " CT2 "
cSql += " LEFT Join " + retSqlName("CV3") + " CV3 "
cSql += " On "
cSql += " CV3_FILIAL = '" + xFilial("CV3") + "' AND "
cSql += " CV3_RECDES = CT2.R_E_C_N_O_ AND "
cSql += " CV3.D_E_L_E_T_ = ' ' "
csql += " Where "
Csql += " CT2_FILIAL = '" + xfilial("CT2") + "' AND "
cSql += " CT2_DATA <= '" + dataate + "' AND "
cSql += " ( "
cSql += " CT2_CREDIT Like '21111102%' OR "
cSql += " CT2_CREDIT Like '21111202%' OR "
cSql += " CT2_CREDIT Like '21112102%' OR "
cSql += " CT2_CREDIT Like '21112202%' OR "
cSql += " CT2_CREDIT Like '21111103%' OR "
cSql += " CT2_CREDIT Like '21111203%' OR "
cSql += " CT2_CREDIT Like '21112103%' OR "
cSql += " CT2_CREDIT Like '21112203%' OR "
cSql += " CT2_CREDIT Like '2134%' OR "
cSql += " CT2_CREDIT Like '2135%' OR "
cSql += " CT2_CREDIT Like '2131%' OR "
cSql += " CT2_CREDIT Like '2138%' OR "
cSql += " CT2_CREDIT Like '216%'  OR "
cSql += " CT2_CREDIT Like '2132%' OR "
cSql += " CT2_CREDIT Like '2185%' OR "
cSql += " CT2_CREDIT Like '214%'  OR "
cSql += " CT2_CREDIT Like '2186%' OR "
cSql += " CT2_CREDIT Like '2188%'"
cSql += " ) AND "
cSql += " CT2.D_E_L_E_T_ = ' ' "
cSql += " Union "
cSql += " Select DISTINCT "
cSql += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO CONTA, CT2_VALOR * -1 VALOR, CT2.R_E_C_N_O_ RECCT2 "
cSql += " , COALESCE(CV3_TABORI, '   ') TABORI, COALESCE(CV3_RECORI, 0) RECORI "    //", FK2_IDDOC, FK7_CHAVE "
cSql += " from " + retSqlName("CT2") + " CT2 "
cSql += " LEFT Join " + retSqlName("CV3") + " CV3 "
cSql += " On "
cSql += " CV3_FILIAL = '" + xFilial("CV3") + "' AND "
cSql += " CV3_RECDES = CT2.R_E_C_N_O_ AND "
cSql += " CV3.D_E_L_E_T_ = ' ' "
csql += " Where "
Csql += " CT2_FILIAL = '" + xfilial("CT2") + "' AND "
cSql += " CT2_DATA <= '" + dataate + "' AND "
cSql += " ( "
cSql += " CT2_DEBITO Like '21111102%' OR "
cSql += " CT2_DEBITO Like '21111202%' OR "
cSql += " CT2_DEBITO Like '21112102%' OR "
cSql += " CT2_DEBITO Like '21112202%' OR "
cSql += " CT2_DEBITO Like '21111103%' OR "
cSql += " CT2_DEBITO Like '21111203%' OR "
cSql += " CT2_DEBITO Like '21112103%' OR "
cSql += " CT2_DEBITO Like '21112203%' OR "
cSql += " CT2_DEBITO Like '2134%' OR "
cSql += " CT2_DEBITO Like '2135%' OR "
cSql += " CT2_DEBITO Like '2131%' OR "
cSql += " CT2_DEBITO Like '2138%' OR "
cSql += " CT2_DEBITO Like '216%'  OR "
cSql += " CT2_DEBITO Like '2132%' OR "
cSql += " CT2_DEBITO Like '2185%' OR "
cSql += " CT2_DEBITO Like '214%'  OR "
cSql += " CT2_DEBITO Like '2186%' OR "
cSql += " CT2_DEBITO Like '2188%'"
cSql += " ) AND "
cSql += " CT2.D_E_L_E_T_ = ' ' "
cSql += " ) Z"
cSql += " LEFT join " + RetSqlName("FK2") + " FK2"
cSql += " On"
cSql += " Z.TABORI = 'FK2' AND"
cSql += " FK2.R_E_C_N_O_ = Z.RECORI AND"
cSql += " FK2.D_E_L_E_T_ = ' '"
cSql += " Left Join  " + RetSqlName("FK7") + "  FK7"
cSql += " On"
cSql += " FK7_FILIAL = '" + xFilial("FK7") + "' AND "
cSql += " FK7_IDDOC = FK2.FK2_IDDOC AND"
cSql += " FK7.D_E_L_E_T_ =  ' '"
cSql += " Left Join  " + RetSqlName("SE2") + "  SE2K"
cSql += " On"
cSql += " FK7_CHAVE = SE2K.E2_FILIAL || '|' || SE2K.E2_PREFIXO || '|' || SE2K.E2_NUM || '|' || SE2K.E2_PARCELA || '|' || SE2K.E2_TIPO || '|' || SE2K.E2_FORNECE || '|' || SE2K.E2_LOJA AND"
cSql += " SE2K.D_E_L_E_T_ = ' '"
cSql += " Left Join  " + RetSqlName("FI8") + "  FI8"
cSql += " On"
cSql += " FK7_CHAVE = FI8.FI8_FILDES || '|' || FI8.FI8_PRFDES || '|' || FI8.FI8_NUMDES || '|' || FI8.FI8_PARDES || '|' || FI8.FI8_TIPDES || '|' || FI8.FI8_FORDES || '|' || FI8.FI8_LOJDES AND"
cSql += " FI8.D_E_L_E_T_ = ' '"
cSql += " left Join  " + RetSqlName("SE2") + "  SE2L"
cSql += " On"
cSql += " FI8.FI8_PRFORI = SE2L.E2_PREFIXO "
cSql += "  AND FI8.FI8_NUMORI = SE2L.E2_NUM "
cSql += "  AND FI8.FI8_PARORI = SE2L.E2_PARCELA "
cSql += "  AND FI8.FI8_TIPORI = SE2L.E2_TIPO "
cSql += "  AND FI8.FI8_FORORI = SE2L.E2_FORNECE"
cSql += "  AND FI8.FI8_LOJORI = SE2L.E2_LOJA"
cSql += " AND SE2L.D_E_L_E_T_ = ' '"
cSql += " Left join  " + RetSqlName("BD7") + "  BD7"
cSql += " On"
cSql += " Z.TABORI = 'BD7' AND"
cSql += " BD7.R_E_C_N_O_ = Z.RECORI AND"
cSql += " BD7.D_E_L_E_T_ = ' '"
cSql += " Left Join  " + RetSqlName("SE2") + "  SE2"
cSql += " On"
cSql += " BD7_CHKSE2 = SE2.E2_FILIAL || '|' || SE2.E2_PREFIXO || '|' || SE2.E2_NUM || '|' || SE2.E2_PARCELA || '|' || SE2.E2_TIPO || '|' || SE2.E2_FORNECE || '|' || SE2.E2_LOJA AND"
cSql += " SE2.D_E_L_E_T_ = ' '"
cSql += " ) X " //O X marca o local. Nunca se esque�a disso, vai ser importante.
cSql += " Group By CONTA, VENCTO "
cSql += " ) J "
cSql += " Where J.SALDO > 0 "
cSql += " Order By CONTA "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,changequery(csql)),"IDDIOP",.f.,.t.)

While !(IDDIOP->(EoF()))
	
	nPosCta := PosConta(Alltrim(IDDIOP->(CONTA)))
	If nPosCta == 0
		IDDIOP->(dbskip())
		Loop
	endIf

	nDiavcto := StoD(dataate) - StoD(IDDIOP->(VENCTO))

	nCount ++

	If nDiavcto <= 0
		aRetSalPag[1][nPosCta] += IDDIOP->(SALDO)
	elseIf nDiavcto <= 30
		aRetSalPag[2][nPosCta] += IDDIOP->(SALDO)
	elseIf nDiavcto <= 60
		aRetSalPag[3][nPosCta] += IDDIOP->(SALDO)
	elseIf nDiavcto <= 90
		aRetSalPag[4][nPosCta] += IDDIOP->(SALDO)
	elseIf nDiavcto <= 120
		aRetSalPag[5][nPosCta] += IDDIOP->(SALDO)
	else
		aRetSalPag[6][nPosCta] += IDDIOP->(SALDO)
	endIf

	aRetSalPag[7][nPosCta] += IDDIOP->(SALDO) //Esse parece que � o total. s� mantendo por compatibilidade

	IDDIOP->(dbskip())
EndDo
IDDIOP->(dbclosearea())

Return( { /*(nCount>0)*/ .T., aRetSalPag } )


function PLSRMNT(cContaDebito, cContaCredito, aRetSalPag, dDtReferencia, nTipTit /*0-Sem Titulo; 1 - Pai; 2 - Filho*/, cPrefixo, cNum, cParcela,; 
				 cTipo, cNatureza, cFornecedor, cLoja, nValorBD7, nValorPai, dDtVcto, cCodRda)
	
	Local nValorTot := 0
    Local aAux   := {}
    Local lReembolso:= .F.
    Local lJob :=.T.
    Local lRPC	:= .T.
    Local lHelp := .F.
    Local cCodInt := PLSINTPAD()
    Local cCodPad := Subs(AllTrim(GetMv("MV_PLSCDCO")),1,2)
    Local cCodPro := Subs(AllTrim(GetMv("MV_PLSCDCO")),3,16)
    Local nVenc
    Local nData := 0
    Local nCateg	:= 0
    Local aPrestDat := {}
    Local aSaldo    := {}
    Local cSaldoPesq := ""
    Local cDatAux := ""

    // 1 - Eventos/ Sinistros a Liquidar SUS
    If Subs(cContaCredito,1,8) $ '21111902/21112902'
    	nCateg	:= 2
    elseIf Subs( cContaCredito ,1,8) $ '21111903/21112903' // 2- Eventos/ Sinistros a Liquidar - Contas 21111903/21112903
		nCateg	:= 3 
	ElseIf Subs(cContaCredito,1,4) $ '2134' // 3 - Comercializa��o sobre Opera��es - Conta 2134
		nCateg	:= 4 
	ElseIf Subs(cContaCredito,1,4) $ '2135' 	// 4- D�bitos com Operadoras - Conta 2135
		nCateg	:= 5 
	ElseIf Subs(cContaCredito,1,4) $ '2131/2138' // 5- Outros D�bitos de Opera��es com Planos - Contas 2131 /2138
		nCateg	:= 6 
	ElseIf Subs(cContaCredito,1,3) $ '216'   // 6 - Tributos e encargos
		nCateg	:= 7 
	ElseIf Subs(cContaCredito,1,4) $ '2185' // 7 - Dep�sitos de Benefici�rios - Contraprest/ Seguros Recebidos - Conta 2185
		nCateg	:= 8 
	ElseIf Subs(cContaCredito,1,3) $ '214' // 8 - Prestadores de Serv. de Assist�ncia a S�ude - Subgrupo 214
		nCateg	:= 9 
	ElseIf Subs(cContaCredito,1,4) $ '2186' // 9- D�bitos com Aquisi��o de Carteira - Conta 2186
		nCateg	:= 10		 				
	ElseIf Subs(cContaCredito,1,4) $ '2188' // 10 - Outros D�bitos a Pagar - Conta 2188
		nCateg	:= 11		 
	EndIf

	if nCateg <> 0
			
		if nTipTit > 0 //Se achou t�tulo 
			//msgalert("Antes procura Saldo","Verificacao")
			cSaldoPesq := fVerDtPre(cPrefixo + cNum + cParcela + cTipo + cNatureza + cFornecedor + cLoja, aSaldo)
			//msgalert("Ap�s procura saldo","Verificacao")
			if cSaldoPesq = ""
			//msgalert("Antes saldotit","Verificacao")
				nSaldoTit	:= SaldoTit(cPrefixo, cNum, cParcela, cTipo, cNatureza, 'P', cFornecedor, 1, ,;
			   	  					    dDtReferencia,cLoja,,Nil,1) //Localizando saldo do t�tulo na data de refer�ncia.
			   	  					    
			    aadd(aSaldo, {cPrefixo + cNum + cParcela + cTipo + cNatureza + cFornecedor + cLoja, alltrim(str(nSaldoTit))})
			    
			  //  msgalert("pos saldotit","Verificacao")
			else
				nSaldoTit	:= val(cSaldoPesq)
			endif
			
			if nSaldoTit > 0 //Se na data de refer�ncia existir Saldo, significa que existe valor a ser pago.
				
				if nTipTit = 2 //Se for t�tulo filho, faz a conta proporcional
				 	if nValorBD7 > 0
				 		nValorTot := (nValorBD7/nValorPai)*nSaldoTit
				 	else
				 		nValorTot := nSaldoTit
				 	endif
				else 
					if nValorBD7 > 0
						nValorTot := nValorBD7
					else
						nValorTot := nSaldoTit
					endif
				endif
				
				nData := dDtReferencia - stod(dDtVcto)				
				
				if Valtype(nData) = "U"
					nData := 0 
				endif
			endif
		else //Caso n�o exista t�tulo, recupera como data de vencimento a data de pagamento do calendario.
			nValorTot := nValorBD7
			
			cDatAux := fVerDtPre(cCodRda, aPrestDat)
			 
			if cDatAux = ""
				//msgalert("pre calendario","Verificacao")
				aAux := PLSXVLDCAL(dDtReferencia/*Date()*/,cCodInt,lHelp,cCodPad,cCodPro,lRPC,cCodRda,lReembolso,lJob)			
				aadd(aPrestDat, {alltrim(cCodRda), alltrim(aAux[3])})
				
				if len(aAux) > 3 .and. alltrim(aAux[3]) <> ""
					cDatAux := aAux[3]
				endif
				//msgalert("pos calendario","Verificacao")
			endif
			
			
			if /*len(aAux) > 3 .and. alltrim(aAux[3]) <> ""*/ cDatAux <> ""
				nData := dDtReferencia - ctod(cDatAux) /*TRBSE2->E2_VENCREA */
				
				if Valtype(nData) = "U" .or. nData < 0
					nData := 0 
				endif
			else
				nData := 0 //Se n�o conseguir a data do calend�rio, joga como "A vencer". 
			endif
			
		Endif			
		
		If nData <= 0
			nVenc	:= 1		// Se ainda n�o venceu
		ElseIf nData <= 30 .and. nData >= 1
			nVenc	:= 2		// Vencidos de 1 a 30 dias
		ElseIf nData <= 60 .and. nData >= 31
			nVenc	:= 3		// Vencidos de 31 a 60 dias
		ElseIf nData <= 90 .and. nData >= 61
			nVenc	:= 4		// Vencidos de 61 a 90 dias
		ElseIf nData <= 120 .and. nData >= 91
			nVenc	:= 5		// Vencidos de 91 a 120 dias
		ElseIf nData >= 121
			nVenc 	:= 6		// Vencidos a mais de 120 dias
		EndIf				
				
		If Valtype(nValorTot) <> "U" .and. nValorTot > 0 .and. nVenc > 0
			aRetSalPag[nVenc,nCateg] += nValorTot
			aRetSalPag[nVenc,nCateg] := val(TransForm(aRetSalPag[nVenc,nCateg],"@U 999,999,999.99" ) )
		EndIf
							
	endif
					
return aRetSalPag


function fVerDtPre(cChave, aArray)

	Local nI := 1
	Local cData := ""
	
	For nI := 1 To Len(aArray)
		if alltrim(cChave) = alltrim(aArray[nI][1])
			cData :=  aArray[nI][2]
		endif
	Next
	
return cData

//Z-0
Static function PosConta(cConta)

Local nRet := 0

If Substr(cConta,1,8) $ '21111102/21111202/21112102/21112202'
	nRet := 1
elseIf Substr(cConta,1,8) $ '21111103/21111203/21112103/21112203'
	nRet := 2
elseIf Substr(cConta,1,4) == '2134'
	nRet := 3
elseIf Substr(cConta,1,4) == '2135'
	nRet := 4
elseIf Substr(cConta,1,4) $ '2131/2138'
	nRet := 5
elseIf Substr(cConta,1,3) == '216'
	nRet := 6
elseIf Substr(cConta,1,8) $ '2132/2185'
	nRet := 7
elseIf Substr(cConta,1,3) == '214'
	nRet := 8
elseIf Substr(cConta,1,4) == '2186'
	nRet := 9
elseIf Substr(cConta,1,4) == '2188'
	nRet := 10
endIf

If nRet > 0
	nRet++ //compensar que alimenta da segunda posi��o pra frente
endIf

return nRet
