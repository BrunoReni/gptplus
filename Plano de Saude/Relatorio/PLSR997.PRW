#INCLUDE "PLSR997.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Report.ch"
#INCLUDE "FWPrintSetup.ch"
Static objCENFUNLGP := CENFUNLGP():New() 
Static lautoSt := .F.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
����������������������������������c���������������������������������������ͻ��
���Programa  � PLSR997  � Autor � 				     � Data �  09/01/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Emite relatorio de Demonstrativo de IR.                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

function PLSR997(cmv_par01, cmv_par02, cmv_par03, cmv_par04, cmv_par05, cmv_par06,;
 cmv_par07, cmv_par08, cmv_par09, cmv_par10, cmv_par11,lWeb	,cPathRelW, cmv_par12, lAutoma)

//���������������������������������������������������������������������Ŀ
//� Inicializa variaveis.                                               �
//�����������������������������������������������������������������������
Local cDesc1         := OemToAnsi(STR0001) //"Este programa tem como objetivo listar o relatorio"
Local cDesc2         := OemToAnsi(STR0002) //"de Demonstrativo de IR referente aos  12 meses,"
Local cDesc3         := OemToAnsi(STR0003) //"a partir do Ano de referencia informado."
Local cPict          := ""
Local imprime        := .T.
Local aOrd           := {}
Local nMes
Local nPos1			 := 0
Local nPos2			 := 0
LOCAL cFileName		:= "IR"+CriaTrab(NIL,.F.)
Local aRet			:=	{}
Local 	cMvTitDeIR 	:= AllTrim(GetNewPar("MV_PLSTDIR","")) //Substitui o t�tulo do relat�rio de demonstrativo de IR do PLS.
Local cPict   := "@E 99,999,999.99"

Private cMvPLSMDIR 	:= AllTrim(GetNewPar("MV_PLSMDIR","")) //Apresenta mensagem no final do relat�rio de demonstrativo de IR do PLS.
Private cTitulo      := FunDesc() //"Demonstrativo de Imposto de Renda"
Private aCabec1      := {}                    "
Private cCabec2      := "                    "
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private cTamanho     := "G"
Private cNomeprog    := "PLSR997" // Coloque aqui o nome do programa para impressao no cabecalho
Private nCaracter    := 18
Private aReturn      := { OemToAnsi(STR0004), 1, OemToAnsi(STR0005), 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag		 := 01
Private wnrel		 := "PLSR997" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nLimite		 := 220
Private cPerg        := "PLR997R"
Private cAlias       := "BM1"
Private cSintetico   := ""
Private nLi          := 0
Private nLinPag      := 58
Private cOper			:=	""
Private cEmpDe			:= 	""
Private cEmpAte			:= 	""
Private cConDe			:= 	""
Private cConAte			:= 	""
Private cSubDe			:= 	""
Private cSubAte			:= 	""
Private cMatDe			:= 	""
Private cMatAte			:= 	""
Private nListar			:=	0
Private nTipo			:=	0
Private aDesMes			:=  {}
Private lReembolso		:=	.T.
Private cRelName:= "PLSR997" + "" + DtoS(Date()) + "" + StrTran(Time(),":")

Default lWeb := .F.
Default cmv_par12 := 1 // Reembolso Sim(mv_par12==1)
Default lAutoma	:= .F.
Default cPathRelW := GETMV("MV_RELT")

	lautoSt := lAutoma

	//-- LGPD ---------- N�O FOI EFETUADO A LGPD DENTRO DO PORTAL.
	// if !objCENFUNLGP:getPermPessoais() 
	// 	objCENFUNLGP:msgNoPermissions()
	// 	Return
	// Endif
	//------------------

	// PE para Informes customizados, nestes casos n�o segue o restante da fun��o
	If ExistBlock("PLR997IR")
		aParPoe := {cmv_par01, cmv_par02, cmv_par03, cmv_par04, cmv_par05, cmv_par06,;
					cmv_par07, cmv_par08, cmv_par09, cmv_par10, cmv_par11,lWeb	,cPathRelW, cmv_par12}
		xRetPoe := ExecBlock("PLR997IR",.f.,.f., aParPoe )
		Return(xRetPoe)
	EndIf

	//��������������������������������������������������������������������������Ŀ
	//� Testa ambiente do relatorio somente top...                               �
	//����������������������������������������������������������������������������
	If !PLSRelTop()
		Return .F.
	Endif


	//��������������������������������������������������������������������������Ŀ
	//� Ajusta perguntas                                                         �
	//����������������������������������������������������������������������������
	//Verifica se o grupo de perguntas foi criado (U_UPDPLS70) junto com o patch desta FNC

	If !lWeb .AND. !lautoSt
		If !(SX1->(dbSeek(cPerg)))
			MsgInfo(STR0006) //"Para a execu��o desta rotina � necess�rio a execu��o do compatibilizador U_UPDPLS70."
			return(nil)
		Endif
	Endif

	If lWeb
		cNomeProg:=cFileName
	Endif

	If !lautoSt .AND. lWeb .and. cmv_par01 # Nil
		cPerg := ""
		mv_par01 := cmv_par01
		mv_par02 := cmv_par02
		mv_par03 := cmv_par03
		mv_par04 := cmv_par04
		mv_par05 := cmv_par05
		mv_par06 := cmv_par06
		mv_par07 := cmv_par07
		mv_par08 := cmv_par08
		mv_par09 := cmv_par09
		mv_par10 := cmv_par10
		mv_par11 := cmv_par11
		mv_par12 := cmv_par12
	Else
		Pergunte(cPerg,.T.)
	Endif

	cOper  		:= mv_par01
	cEmpDe		:= mv_par02
	cEmpAte		:= mv_par03
	cConDe		:= mv_par04
	cConAte		:= mv_par05
	cSubDe		:= mv_par06
	cSubAte		:= mv_par07
	cMatDe		:= mv_par08
	cMatAte		:= mv_par09
	nAno    	:= mv_par10
	nListar		:= mv_par11
	lReembolso	:= mv_par12 == 1 // Reembolso Sim(mv_par12==1)

	nMes    := 1

	If  nMes <= 0
		nAno -= 1
		If  nMes == 0
			nMes := 1
		Else
			nMes += 12
		Endif
	Endif

	nMesIni := 01
	nMesFim := 12
	cMesIni := '01'
	cMesFim := '12'
	cAnoIni := cvaltochar(nAno)
	cAnoFim := cvaltochar(nAno)

	If Empty(cMvTitDeIR)
		cTitulo:=	STR0007+"- "+cAnoIni //"          INFORME DE PAGAMENTOS  "###" - "
	Else
		cTitulo:=	cMvTitDeIR+"-"+cAnoIni // Titulo conforme parametro
	EndIf

	//���������������������������������������������������������������������Ŀ
	//� Monta descricao do cabecalho                                        �
	//�����������������������������������������������������������������������
	nPos1 := nMesIni
	cAno  := cAnoIni
	
	For nPos2 := 1 to 12
		AAdd(aCabec1, MesExtenso(nPos2) + "/" + cAno)
		nPos1 += 1
		If  nPos1 > 12
			nPos1 := 1
			cAno  := cAnoFim
		Endif
	Next
		
	AAdd(aCabec1, STR0008  + "/" + cAno) //"         Total"

	if !lWeb .AND. !lAutoSt .AND. !lAutoma
		RptStatus({|aRet| RunReport(aCabec1,cCabec2,cTitulo,lweb,cPathRelW, cOper) },cTitulo)
	else
		aRet := RunReport( aCabec1,cCabec2,cTitulo,lWeb,cPathRelW,cOper)
	endif
	
Return aRet

// /*/
// �����������������������������������������������������������������������������
// �����������������������������������������������������������������������������
// �������������������������������������������������������������������������ͻ��
// ���Fun��o    RunReport � Autor � Guilherme Carreiro � Data �  11/02/2022 ���
// �������������������������������������������������������������������������͹��
// ���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
// ���          � monta a janela com a regua de processamento.               ���
// �������������������������������������������������������������������������͹��
// ���Uso       � Programa principal                                         ���
// �������������������������������������������������������������������������ͼ��
// �����������������������������������������������������������������������������
// �����������������������������������������������������������������������������
// /*/
Static Function RunReport(aCabec1,cCabec2,cTitulo,lWeb,cPathRelW,cOper)
	//��������������������������������������������������������������������������Ŀ
	//� Inicializa variaveis                                                     �
	//����������������������������������������������������������������������������
	Local aRecDes := {}
	Local aMes    := array(12)
	Local nPos
	Local nPos1
	Local nPos2
	Local nMes
	Local cLinha
	Local cCPF		:=""
	Local cNome		:=""
	Local aRecTotDes:={}
	Local aRecDetal	:={}
	Local aRecReemb	:={}
	Local cObs		:=""
	Local nLinObs	:=0
	Local aObs		:={}
	Local nObs		:=0
	Local nTotRec
	Local nTotDes
	Local cPict   := "@E 99,999,999.99"
	Local cAntes  := ""
	Local cDepois := ""
	local lImp	:=.T.
	Local nPos1i	:= 0
	Local nPos2i	:= 0
	Local nPos1E	:= 0
	Local nPos2E	:= 0
	Local nFor		:= 0
	Local nItRem	:= 0
	Local cLinha2	:= ""
	local nLinRef		:= 0
	Local aRecComp := {}
	Local cCompetencia := ""
	Local nPosComp := 0
	Local nPosComp2 := 0
	Local nMesCompetencia := 0
	Local cAnoCompetencia := ""
	Local cSinalComp := ""
	Local dDataEmissao := "Data de Emiss�o: " + DTOC(dDataBase) + " " + TIME()
	Local nTotPag := 0
	Local nValPag := 0
	Local nTop	:= 35
	Local nLeft	:= 25
	Local nTamanho := 40
	Local aBMP	:= {"lgesqrl.bmp"}
	Local cLogo := "lgesqrl"
	Local nColMaxAux := 220
	Local nLinIniAux := 005
	Local nColIniAux := 005
	Local nVlrGrl := 0
	Local aVlrRefGrl := {0,0,0,0,0,0,0,0,0,0,0,0}
		
	private nLinMax		:= 0
	private nColMax		:= 0
	private nLinIni		:= 0
	private nColIni		:= 0
	private oFontDef1  	:= TFont():New("Arial", 8,  8, , .F., , , , .T., .F.) // Padrao
	private oFontDef2	:= TFont():New("Arial", 10, 10, , .F., , , , .T., .F.) // Padrao reduzida
	private oFontDef3  	:= TFont():New("Arial", 12, 12, , .F., , , , .T., .F.) // Padrao
	private oFontBld1	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	private oFontBld2	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	private oFontBld3	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito	
	private nColRef := 35
	DEFAULT cOper := plsintpad()

	objCENFUNLGP:setAlias("BA0")

	BA0->(dbSetOrder(1)) 
	BA0->(MsSeek(xFilial("BA0") + cOper))
	
	oPrint := FWMSPrinter():New(cRelName,,.F.,cPathRelW,.T.,,,,,.F.)

	// Definindo as propriedades
	if lWeb
		oPrint:lServer := lWeb		// Indica se e oriundo do Portal do Beneficiario
		oPrint:setDevice(IMP_PDF)	// For�a a impressao em PDF caso for portal
	else
		oPrint:Setup()				// Inicializa o SETUP

		If oPrint:nModalResult == 2 //Verifica se foi Cancelada a Impress�o
			Return ({.F.,"",""})
		EndIf
	endif
	oPrint:SetLandscape()			// Seta o relatorio para o modo paisagem
	
	// Forca tamanho A4
	oPrint:setPaperSize(9)
	
	// Inicializa as variaveis de posicionamento
	nLinIni := 030
	nLinMax	:= 570
	nColIni := 005
	nColMax	:= 820
	nLinRef := 070
	
	// Inicia a primeira pagina
	oPrint:StartPage()
	
	// Cria o box principal
	oPrint:Box(nLinIni, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )

	//Insere Logo
	If FindFunction("PlLogoImp")
		PlLogoImp(oPrint, nTop, nLeft, aBMP, cLogo, nTamanho, nLinIniAux,nColIniAux, nColMaxAux, cTitulo, oFontDef1, objCENFUNLGP)
	Endif

	// Carrega cabe�alho Inicial
	oPrint:Say(	nLinIni + 0030, nColIni + (nColMax * 0.35), cTitulo, oFontBld1,,,,2)

	nColMax	:= 800

	// Carrega o N�mero da P�gina
	oPrint:Say(	nLinIni + 0025, nColIni + (nColMax * 0.80), "P�gina: " + cValToChar(oPrint:nPageCount), oFontBld1,,,,2)

	// Carrega Data de Emiss�o
	oPrint:Say(	nLinIni + 0035, nColIni + (nColMax * 0.80), dDataEmissao, oFontBld1,,,,2)

	nColMax	:= 820

	// Carrega linha p�s cabe�alho
	oPrint:Line( 80, nColIni + 10, 80, nColIni + nColMax)

	// Marca a referencia da proxima linha apos o cabecalho
	nLinRef += 15

	//���������������������������������������������������������������������Ŀ
	//� Busca as Informa��es para a Impressao do relatorio                  �
	//�����������������������������������������������������������������������
	aRecTotDes:=PLR997Fil(cOper,cEmpDe,cEmpAte,cConDe,cConAte,cSubDe,cSubAte,cMatDe,cMatAte,nAno,nTipo,nListar,lWeb,lReembolso)
	aRecDes		:= aRecTotDes[1]
	aRecDetal	:= aRecTotDes[2]
	aRecReemb	:= IIf ( Len(aRecTotDes)>=3,aRecTotDes[3],{})
	aRecComp	:= IIf ( Len(aRecTotDes)>=4,aRecTotDes[4],{})

	IF len(aRecDes)==0
		Return({.F.,STR0012,""})
	Endif

//���������������������������������������������������������������������Ŀ
//� Impressao do relatorio                                              �
//�����������������������������������������������������������������������

	For nPos1 := 1 to len(aRecDes)
		//���������������������������������������������������������������������Ŀ
		//� Imprime cabecalho                                                   �
		//�����������������������������������������������������������������������
		cLinha := aRecDes[nPos1,1] + IIF(lweb,"",space(01)) + ;
		aRecDes[nPos1,2] + IIF(lweb,"",space(01)) + ;
		aRecDes[nPos1,3] + IIF(lweb,"",space(01)) + ;
		aRecDes[nPos1,4] + IIF(lweb,"",space(01)) + ;
		aRecDes[nPos1,5] + IIF(lweb,"",space(01))
		Do Case
			Case ! empty(aRecDes[nPos1,4]) .and. Empty(aRecDes[nPos1,5])
				If  lImp == .T.
					nLi     := 58
				Endif
				
				if(nPos1 != 1)
					oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

					nLinRef := 85
				EndIf
				

				cLinha2:=""
				BA1->(DbSetOrder(1))
				BA1->(MsSeek(xFilial("BA1")+cOper+aRecDes[nPos1,1]+aRecDes[nPos1,4]+"T"))
				
				BA0->(DbSetOrder(1))
				BA0->(MsSeek(xFilial("BA0")+cOper))
				cLinha2  := ""
				cLinha2  := "Operadora: " + AllTrim(BA0->BA0_NOMINT) + Space(10) + "CNPJ: " + Transform(AllTrim(BA0->BA0_CGC), "@R 99.999.999/9999-99" )
				
				IiF((nLinIni + nLinRef) > (nLinMax - 0010), oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao), NIL)
				
				oPrint:Say(	nLinIni + nLinRef, nColIni + 025, cLinha2, oFontBld1,,,,2)
				nLinRef += 10
				
				cLinha2:=""
				
				cObs := FS_OBSORC(cPathRelW,Lweb)
				nLinObs	:= MLCOUNT(cObs, , , )
				
				aObs	:= {}
				cObs:=R97EXMMO(@cObs)
				
				For nObs := 1 To nLinObs
					aADD(aObs,{MEMOLINE(cObs, , nObs, )})
				Next nObs
				
				For nObs := 1 To Len(aObs)
					cLinha2	:= allTrim(aObs[nObs,1]) //+CHR(13) + CHR(10)
					
					IiF((nLinIni + nLinRef) > (nLinMax - 0010), oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao), NIL)
					
					oPrint:Say(	nLinIni + nLinRef, nColIni + 0025, cLinha2, oFontBld1,,,,2)
					nLinRef += 10
				Next nObs
				
				cLinha  :=""
				cLinha  := STR0009 + cLinha + aRecDes[nPos1,1]+"."+aRecDes[nPos1,4]/*+" "+ Posicione("BA1",1,xFilial("BA1")+cOper+aRecDes[nPos1,1]+aRecDes[nPos1,4]+"T","BA1_NOMUSR")*/ + space(01) //".... Familia:    "
				cAntes  := iif(lweb," ", "     ")
				cDepois := iif(lweb,""," ")
				
			Case ! empty(aRecDes[nPos1,5])
				If aRecDes[nPos1,5]="00"
					lImp := .T.
				Endif
				cCPF    := Posicione("BA1",2,xFilial("BA1")+cOper+aRecDes[nPos1,1]+aRecDes[nPos1,4]+aRecDes[nPos1,5],"BA1_CPFUSR")
				cNome   := Posicione("BA1",2,xFilial("BA1")+cOper+aRecDes[nPos1,1]+aRecDes[nPos1,4]+aRecDes[nPos1,5],"BA1_NOMSOC") // Caso tenha, apresenta o Nome Social
				
				If Empty(cNome)
					cNome   := Posicione("BA1",2,xFilial("BA1")+cOper+aRecDes[nPos1,1]+aRecDes[nPos1,4]+aRecDes[nPos1,5],"BA1_NOMUSR")
				EndIf
				
				cLinha  :=""
				cLinha  := STR0010 + cLinha +aRecDes[nPos1,4]+"."+aRecDes[nPos1,5]+" "+ Alltrim(cNome) + Space(05) + "CPF: " + Transform(cCPF,"@R 999.999.999-99") + space(01) //"..... Usuario:   "
				cAntes  := iif(lweb," ", "     ")
				cDepois := ""
		EndCase
		
		if((nLinIni + nLinRef) > (nLinMax - 145))
				oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

				nLinRef := 110
		EndIf
			
		oPrint:Say(	nLinIni + nLinRef, nColIni + 70, cLinha, oFontBld1,,,,2)	//Fam�lia - Benefici�rio
		nLinRef += 10
		aTemMes := {0,0,0,0,0,0,0,0,0,0,0,0}
		//���������������������������������������������������������������������Ŀ
		//� Imprime receitas                                                    �
		//�����������������������������������������������������������������������
		cLinha  :=""
		cLinha  := cAntes + STR0011+" " + cDepois //"Total Pago     "
		nTotRec := 0
		For nPos2 := 9 to 20

			cCompetencia := ""

			cLinha  := aCabec1[nPos2-8]
			
			oPrint:Say(	nLinIni + nLinRef, nColIni + 170, cLinha, oFontDef2,,,,2) //Refer�ncias

			cLinha := transform(aRecDes[nPos1,nPos2],cPict)

			oPrint:Say(	nLinIni + nLinRef, nColIni + 280, cLinha, oFontDef2,,,,2) //Valores

			If Len(aRecComp[nPos2-8]) > 0 .And. Val(cLinha) <> 0 //Verifica se o m�s possui Compet�ncia

				For nPosComp := 1 to Len(aRecComp[nPos2-8]) // For para cada compet�ncia do m�s

					If(aRecComp[nPos2-8][nPosComp][3] == aRecDes[nPos1][1] + aRecDes[nPos1][2] + aRecDes[nPos1][3] + aRecDes[nPos1][4])

						nMesCompetencia := Val(aRecComp[nPos2-8][nPosComp][1])
						cAnoCompetencia := aRecComp[nPos2-8][nPosComp][2]

						cSinalComp := IIF(nPosComp < Len(aRecComp[nPos2-8])-1, ", ", " e ")
						cSinalComp := IIF(nPosComp == Len(aRecComp[nPos2-8]), "", cSinalComp)

						cCompetencia += MesExtenso(nMesCompetencia) + "/" + cAnoCompetencia + cSinalComp

					EndIf
				Next

				If !Empty(cCompetencia)

					IIF(cSinalComp == ", " .Or. cSinalComp == " e ", cCompetencia := SUBSTRING(cCompetencia, 1, Len(cCompetencia)-Len(cSinalComp)), cCompetencia := cCompetencia)

					cCompetencia := "Compet�ncia(s) " + cCompetencia

					oPrint:Say(	nLinIni + nLinRef, nColIni + 330, cCompetencia, oFontDef2,,,,2) //Compet�ncias

				EndIf
			EndIf
					
			nTotRec += aRecDes[nPos1,nPos2]
			
			nLinRef += 10

			If !empty(aRecDes[nPos1,4]) .and. Empty(aRecDes[nPos1,5]) // Realiza a soma dos totais por refer�ncia, buscando direto do
				aVlrRefGrl[nPos2-8] += aRecDes[nPos1,nPos2]			  // total das Fam�lias para adicionar no totalizador ( �ltima P�gina)
			EndIf
		Next

		If !empty(aRecDes[nPos1,4]) .and. Empty(aRecDes[nPos1,5]) // Realiza a soma dos totais pagos por fam�lia para adicionar no totalizador ( �ltima P�gina)
			nVlrGrl += nTotRec
		EndIf

		oPrint:Say(	nLinIni + nLinRef, nColIni + 90, aCabec1[13], oFontBld3,,,,2) //Total Pago

		oPrint:Say(	nLinIni + nLinRef, nColIni + 270, transform(nTotRec, cPict), oFontBld3,,,,2) //Valor Total

		nLinRef += 20
		
		if(len(aRecDes)>nPos1)
			if((nLinIni + nLinRef) > (nLinMax - 0010)) .and. (!empty(aRecDes[nPos1+1,4]) .and. !Empty(aRecDes[nPos1+1,5]))
				oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

				nLinRef := 110
			EndIf
		EndIf
		
		//���������������������������������������������������������������������Ŀ
		//� Imprime despesas                                                    �
		//�����������������������������������������������������������������������
		cLinha  :="" //cAntes + "Iten  " + cDepois
		nTotDes := 0
		If nListar	== 2
			For nPos1i := 1 to len(aRecDetal)
				If nPos1i> len (aRecDetal)
					nPos1i:=20
					loop
				Endif
				iF aRecDetal[nPos1i,1] ==aRecDes[nPos1,1] .and. aRecDetal[nPos1i,2] ==aRecDes[nPos1,2] .and.;
					aRecDetal[nPos1i,3] ==aRecDes[nPos1,3].and. aRecDetal[nPos1i,4] ==aRecDes[nPos1,4].and. aRecDetal[nPos1i,5] ==aRecDes[nPos1,5]
					
					if((nLinIni + nLinRef) > (nLinMax - 140))
						oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

						nLinRef := 110
					EndIf

					For nPos2i := 7 to 20//len(aRecDetal)
						If nPos2i==8
							loop
						endif
						If nPos2i>=9
							nTotDes := aRecDetal[nPos1i,nPos2i]
							
							cLinha := transform(nTotDes   ,cPict) + IIF(lweb,"",space(01))
			
							oPrint:Say(	nLinIni + nLinRef, nColIni + 260, aCabec1[nPos2i-8], oFontDef2,,,,2) //Refer�ncias

							oPrint:Say(	nLinIni + nLinRef, nColIni + 370, cLinha, oFontDef2,,,,2) //Valores

							nLinRef += 10

						Else
							cLinha := (aRecDetal[nPos1i,nPos2i]) + IIF(lweb,"",space(01))

							oPrint:Say(	nLinIni + nLinRef, nColIni + 200, cLinha, oFontBld1,,,,2)

							nLinRef += 10
						Endif
						
					Next
					
					IiF((nLinIni + nLinRef) > (nLinMax - 0010), oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao), NIL)
					
					nLinRef += 10
					cLinha:=""
				Endif
			Next
		Endif
		//�����������������������������������������������������������������������������Ŀ
		//� Imprime Reembolso do usu�rio atual (aRecDes) quando existir em aRecReemb	�
		//� aRecDes[nPos1,1] == CODEMP													�
		//� aRecDes[nPos1,2] == CONEMP													�
		//� aRecDes[nPos1,3] == SUBCON													�
		//� aRecDes[nPos1,4] == MATRIC													�
		//� aRecDes[nPos1,5] == TIPREG													�
		//�������������������������������������5������������������������������������������
		If lReembolso
			nPos1E := aScan(aRecReemb,{|x| ( ;
				x[1] == aRecDes[nPos1,1] .and. ;
				x[2] == aRecDes[nPos1,2] .and. ;
				x[3] == aRecDes[nPos1,3] .and. ;
				x[4] == aRecDes[nPos1,4] .and. ;
				x[5] == aRecDes[nPos1,5])})
				
			If nPos1E > 0 .AND. !aRecReemb[nPos1E][8] // Se existe o mesmo usuario atual em reembolso e n�o foi impresso... imprime
				
				cLinha := ""
				
				nTotPag := 0

				For nPos2E := 9 to 20

					nValPag := 0

					cLinha := Chr(13) + Chr(10) + Chr(13) + Chr(10)

					If nPos2E == 9
						cLinha := ("Reembolso" + space(40) + "Valor" + IIF(lweb,"",space(01)))

						oPrint:Say(	nLinIni + nLinRef, nColIni + 200, cLinha, oFontBld1,,,,2)

						nLinRef += 10
					Endif
					
					For nItRem := 1 To Len(aRecReemb[nPos1E,nPos2E])

						nValPag += aRecReemb[nPos1E,nPos2E,nItRem,04]
							
						cLinha := transform(nValPag   ,cPict) + IIF(lweb,"",space(01))

						if nItRem == Len(aRecReemb[nPos1E,nPos2E])

							IiF((nLinIni + nLinRef) > (nLinMax - 0010), oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao), NIL)

							oPrint:Say(	nLinIni + nLinRef, nColIni + 240, aCabec1[nPos2E-8], oFontDef2,,,,2) //Refer�ncias

							oPrint:Say(	nLinIni + nLinRef, nColIni + 370, cLinha, oFontDef2,,,,2) //Valores

							nLinRef += 10

						EndIf

						nTotPag += aRecReemb[nPos1E,nPos2E,nItRem,04]

					Next nItRem
											
				Next nPos2E
				aRecReemb[nPos1E][8] := .T. //Impresso

				oPrint:Say(	nLinIni + nLinRef, nColIni + 200, "Total", oFontBld3,,,,2) //Total Pago

				oPrint:Say(	nLinIni + nLinRef, nColIni + 340, transform(nTotPag, cPict), oFontBld3,,,,2) //Valor Total

				nLinRef += 20
			
			EndIf

		EndIf
		If !EMPTY(cMvPLSMDIR)
			cLinha  := cMvPLSMDIR

			If((nLinIni + nLinRef) > (nLinMax - 0010))
				oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

				nLinRef := 110
			EndIf
				
			oPrint:Say(	nLinIni + nLinRef, nColIni + 0025, cLinha, oFontBld1,,,,2)
			nLinRef += 10
		EndIf

		//Se tiver gerado todas as p�ginas, gera a �ltima com o totalizador de todos os valores apresentados.

		If nPos1 == len(aRecDes)

			oPrint = PlsBoxTot(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao, aVlrRefGrl, nVlrGrl, aCabec1, aRecDes[nPos1,4])

		ElseIf !empty(aRecDes[nPos1+1,4]) .And. Empty(aRecDes[nPos1+1,5]) .And. aRecDes[nPos1,1] <> aRecDes[nPos1+1,1]

			oPrint = PlsBoxTot(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao, aVlrRefGrl, nVlrGrl, aCabec1, aRecDes[nPos1,1])

			aVlrRefGrl := {0,0,0,0,0,0,0,0,0,0,0,0}
			nVlrGrl := 0

		EndIf
 
	Next

	//Imprime
	oPrint:Print()
	
return ({.T.,'',cRelName + ".PDF"})

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FS_OBSORC    � Autor �                  � Data 28/09/2011  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o para a Exibi��o da Observa��o no Relatorio          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function FS_OBSORC(cPathRelW,Lweb)

Local cEnvServ := GetEnvServer()
Local cDirRaiz 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97())) 
//Local cdirweb	:= getWebDir() + getSkinPls() + "\relatorios\"
Local cNomArq	:= ""
Local cTxtOrc := ""
//Local cNomArq2	:=""

If SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
	cNomArq := cDirRaiz + "obsimprenda.txt"
Else
	cNomArq := cDirRaiz + "\obsimprenda.txt"
EndIf

/*If !EMPTY(cNomArq) .AND. Lweb
If SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
	cNomArq := cPathRelW + "obsimprenda.txt"
Else
	cNomArq := cPathRelW + "\obsimprenda.txt"
EndIf
Endif*/ 


If !EMPTY(cNomArq) .AND. Lweb
	cNomArq :=cPathRelW+ "obsimprenda.txt"
Endif 

cTxtOrc := MemoRead(cNomArq)

Return (cTxtOrc)

function PLSR997stA(lvalor)
lautoSt := lvalor
return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSR997Box    � Autor �                  � Data 11/02/2022 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o para criar o box das p�ginas				          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

	Local nTop	:= 35
	Local nLeft	:= 25
	Local nTamanho := 40
	Local aBMP	:= {"lgesqrl.bmp"}
	Local cLogo := "lgesqrl"
	Local oFontDef1 := TFont():New("Arial", 8,  8, , .F., , , , .T., .F.) 

	oPrint:EndPage()//Finaliza a p�gina
	oPrint:StartPage()// Inicia a p�gina

	// Cria o box da P�gina
	oPrint:Box(nLinIni, nColIni + 0010, nLinIni + (nLinMax - 0010), nColIni + nColMax )

	nLinIni := 005
	nColMax := 220

	//Insere Logo
	If FindFunction("PlLogoImp")
		PlLogoImp(oPrint, nTop, nLeft, aBMP, cLogo, nTamanho, nLinIni, nColIni, nColMax, cTitulo, oFontDef1, objCENFUNLGP)
	Endif

	nLinIni := 030
	nColMax := 820

	// Carrega cabe�alho Inicial
	oPrint:Say(	nLinIni + 0030, nColIni + (nColMax * 0.30), cTitulo, oFontBld1,,,,2)

	// Carrega o N�mero da P�gina
	oPrint:Say(	nLinIni + 0025, nColIni + (nColMax * 0.75), "P�gina: " + cValToChar(oPrint:nPageCount), oFontBld1,,,,2)

	// Carrega Data de Emiss�o
	oPrint:Say(	nLinIni + 0035, nColIni + (nColMax * 0.75), dDataEmissao, oFontBld1,,,,2)

	// Carrega linha p�s cabe�alho
	oPrint:Line( 80, nColIni + 10, 80, nColIni + nColMax)

return oPrint

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PlsBoxTot    � Autor �                  � Data 23/02/2023  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o para criar o box com o valor total		          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PlsBoxTot(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao, aVlrRefGrl, nVlrGrl, aCabec1, cEmpresa)

	Local nLinRef := 0
	Local nPos := 0
	Local cPict   := "@E 99,999,999.99"
	private oFontBld2	:= TFont():New("Arial", 15, 15, , .T., , , , .T., .F.) // Negrito
	Default cEmpresa := ""

	oPrint = PLSR997Box(oPrint, nLinIni, nLinMax, nColIni, nColMax, cTitulo, oFontBld1, nColRef, dDataEmissao)

	nLinRef := 75
	
	oPrint:Say(	nLinIni + nLinRef, nColIni + 283, STR0013 + cEmpresa, oFontBld2,,,,2)

	nLinRef := 105

	oPrint:Say(	nLinIni + nLinRef, nColIni + 70, STR0014, oFontBld1,,,,2)
	
	nLinRef += 10

	For nPos := 1 to 12
		cLinha := Replace(aCabec1[nPos], SUBSTR(aCabec1[nPos], AT("/",aCabec1[nPos]), Len(aCabec1[nPos])), "")
		
		oPrint:Say(	nLinIni + nLinRef, nColIni + 170, cLinha, oFontDef2,,,,2) //Refer�ncias

		cLinha := transform(aVlrRefGrl[nPos],cPict)

		oPrint:Say(	nLinIni + nLinRef, nColIni + 280, cLinha, oFontDef2,,,,2) //Valores

		nLinRef += 10
	Next

	oPrint:Say(	nLinIni + nLinRef, nColIni + 90, STR0015, oFontBld3,,,,2) //Total Pago

	oPrint:Say(	nLinIni + nLinRef, nColIni + 270, transform(nVlrGrl, cPict), oFontBld3,,,,2) //Valor Total

return oPrint