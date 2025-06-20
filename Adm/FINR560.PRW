#INCLUDE "Finr560.ch"
#INCLUDE "PROTHEUS.CH"
#Include "Dbstruct.ch"

#DEFINE CRLF Chr(13) + Chr(10)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FINR560	� Autor � Daniel Tadashi Batori � Data � 26.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Movimento do Caixinha                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FINR560(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Sigafin                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FINR560()
Private oReport

oReport:= ReportDef()
oReport:PrintDialog()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ReportDef� Autor � Daniel Batori         � Data � 26.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do layout do Relatorio                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef(void)                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oFilial //Gest�o Corporativa
Local oSecFil //Gest�o Corporativa

Local aDados := Array(10)

oReport := TReport():New("FINR560",STR0004,"FIR560",;
{|oReport| ReportPrint(oReport,aDados)},STR0001+STR0002+STR0003)

pergunte("FIR560",.F.)
//������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                       �
//� mv_par01            // de caixinha                         �
//� mv_par02            // Ate caixinha                        �
//� mv_par03            // De data digitacao                   �
//� mv_par04            // Ate data digitacao                  �
//� mv_par05            // Mostra Movimento                    �
//��������������������������������������������������������������

oReport:SetLandscape(.T.)

oSection := TRSection():New(oReport,STR0011,{"SEU"},) //"Caixinha   "
oSection:SetTotalInLine(.F.)
TRCell():New(oSection,"EU_CAIXA","SEU",STR0011,,28,.F.,)  //"Caixinha   "

If FXMultSld()
	TRCell():New(oSection,"FIJ_SLDANT","FIJ","Saldo Anterior do Caixinha",,68,.F.,)  //definido por SetBlock
EndIf

oSection:SetHeaderSection(.F.)

oSection1 := TRSection():New(oSection,STR0004,{"SEU"},) //"Movimento do Caixinha"
oSection1:SetTotalInLine(.F.)
TRCell():New(oSection1 ,"TIPO"       ,      ,STR0028              , ,28 ,.F. ,{ || aDados[1] })  //"Descricao"
TRCell():New(oSection1 ,"EU_BENEF"   ,"SEU" ,STR0029              , ,   ,.F. ,{ || aDados[2] })  //"Usuario"
TRCell():New(oSection1 ,"EU_NRCOMP"  ,"SEU" ,STR0030              , ,   ,.F. ,{ || aDados[3] })  //"Comprovante"
TRCell():New(oSection1 ,"EU_NUM"     ,"SEU" ,STR0031+CRLF+STR0032 , ,   ,.F. ,{ || aDados[4] })  //"Nro. Interno"###"do Movimento" 
TRCell():New(oSection1 ,"EU_NROADIA" ,"SEU" ,STR0033+CRLF+STR0034 , ,   ,.F. ,{ || aDados[5] })  //"Numero de"###"Adiant."
TRCell():New(oSection1 ,"EU_DTDIGIT" ,"SEU" ,STR0035+CRLF+STR0036 , ,   ,.F. ,{ || aDados[6] })  //"Data de"###"Digitacao"
TRCell():New(oSection1 ,"EU_VALOR"   ,"SEU" ,STR0037              , ,   ,.F. ,{ || aDados[7] })  //"Valor"
TRCell():New(oSection1 ,"EU_SLDADIA" ,"SEU" ,STR0038              , ,   ,.F. ,{ || aDados[8] })  //"Baixado"
oSection1:SetHeaderPage()

//Gest�o Corporativa - In�cio
oFilial := TRSection():New(oReport,"",{"SEI"})
TRCell():New(oFilial,"Filial",,,,TamSx3("EI_FILIAL")[1] + Len(STR0046)) //"Filial : "
oFilial:SetHeaderSection(.F.)

oSecFil := TRSection():New(oReport,"SECFIL",{})
TRCell():New(oSecFil,"CODFIL" ,,STR0041,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)		//"C�digo"
TRCell():New(oSecFil,"EMPRESA",,STR0042,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)		//"Empresa"
TRCell():New(oSecFil,"UNIDNEG",,STR0043,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)		//"Unidade de neg�cio"
TRCell():New(oSecFil,"NOMEFIL",,STR0044,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)		//"Filial"

oReport:SetUseGC(.F.)
//Gest�o Corporativa - Fim

Return oReport

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Daniel Batori          � Data �26/07/2006���
��������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os  ���
���          �relatorios que poderao ser agendados pelo usuario.           ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                            ���
��������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                          ���
��������������������������������������������������������������������������Ĵ��
���          �               �                                             ���
���������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint(oReport,aDados)
Local oSection		:= oReport:Section(1)
Local oSection1	:= oReport:Section(1):Section(1)
Local cFilterUser	:= oReport:Section(1):GetAdvplExp("SEU")
Local cAliasQry1	:= GetNextAlias()
Local cQuery		:= ""
Local cCaixa		:= ""
Local cAdia,lSaldo:= .T.
Local lPrinted		:= .F.
Local titulo		:= STR0004 //"Movimento do Caixinha"
Local oTotValor
Local oBreak2
Local oTotCx
Local cAdto		:= ""
Local lProcAlc		:= SuperGetMV("MV_FINCTAL", .T., "1") == "2"
Local cWhere		:= ""

//Gest�o Corporativa - In�cio
Local aAreaSEU := SEU->(GetArea())
Local aAreaSET := SET->(GetArea())
Local aAreaSM0 := SM0->(GetArea())
Local aAreaORI := GetArea()
Local oFilial		:= oReport:Section(2)
Local aTmpFil	:= {}
Local cTmpSEUFil := ""
Local cRngFilSEU := NIL
Local lGestao   := ( FWSizeFilial() > 2 )
Local lSEUExcl  := Iif( lGestao, FWModeAccess("SEU",1) == "E", FWModeAccess("SEU",3) == "E")
Local cSEUFil  := FWModeAccess("SEU",3)
Local cSEUUN   := FWModeAccess("SEU",2)
Local cSEUEmp  := FWModeAccess("SEU",1)
Local nX 		:= 1
Local nC := 1
Local oSecFil	:= oReport:Section("SECFIL")
Local nRegSM0	:= SM0->(Recno())
Local aSelFil := {}
Local cUNold := ""
Local cEmpOld := ""
Local cFilialAnt := cFilAnt
Local cDtini	:= Dtos(mv_par03)
Local cDtfim	:= Dtos(mv_par04)
Local lPrtFil 	:= .T.
Local lSldAtu	:= .T.
Local nSaldoAtu	:= 0
Local cCaixinha	:= ""
Local cCampos		:= ""
Local aSEUStruct	:= SEU->(DbStruct())
Local nCampo		:= 0

Private lConSur := cPaisLoc $ "ARG|BOL|PAR|URU|CHI" 
//Gest�o Corporativa - Fim
Private nSaldo		:= 0
Private nSldAdia  := 0
Private nSaldoTot	:= 0
Private nSaldoCxa	:= 0
Private cSeqCxa   := ""
Private nSalAbat	 := 0
Private _lSemlibc := .F. //Registro sem Liberacao e Cancelado
//Caso selecione Pend Prest Contas exibe coluna adicional
If MV_PAR05 == 2
	TRCell():New(oSection1 ,"EU_SLDADIA" ,"SEU" , , , ,.F. ,{ || aDados[9] })  //"Saldo Antecipo"
EndIf

//Gest�o Corporativa - In�cio

nRegSM0 := SM0->(Recno())

If (lSEUExcl .and. mv_par06 == 1)
	If !IsBlind()	//controle via job
		aSelFil := FwSelectGC()
	EndIf	
Endif

If Empty(aSelFil)
	aSelFil := {cFilAnt}
Endif

SM0->(DbGoTo(nRegSM0))

If Len(aSelFil) > 1
	cRngFilSEU := GetRngFil( aSelFil, "SEU", .T., @cTmpSEUFil )
	aAdd(aTmpFil, cTmpSEUFil)
	oSection1:SetHeaderSection(.F.)
	aSM0 := FWLoadSM0()
	nTamEmp := Len(FWSM0LayOut(,1))
	nTamUnNeg := Len(FWSM0LayOut(,2))
	cTitulo := oReport:Title()
	oReport:SetTitle(cTitulo + " (" + STR0045 +  ")")	//"Filiais selecionadas para o relatorio"
	nTamTit := Len(oReport:Title())
	oSecFil:Init()
	oSecFil:Cell("CODFIL"):SetBlock({||cFilSel})
	oSecFil:Cell("EMPRESA"):SetBlock({||aSM0[nLinha,SM0_DESCEMP]})
	oSecFil:Cell("UNIDNEG"):SetBlock({||aSM0[nLinha,SM0_DESCUN]})
	oSecFil:Cell("NOMEFIL"):SetBlock({||aSM0[nLinha,SM0_NOMRED]})
	For nX := 1 To Len(aSelFil)
		nLinha := Ascan(aSM0,{|sm0|,sm0[SM0_CODFIL] == aSelFil[nX]})
		If nLinha > 0
			cFilSel := Substr(aSM0[nLinha,SM0_CODFIL],1,nTamEmp)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + 1,nTamUnNeg)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + nTamUnNeg + 1)
			oSecFil:PrintLine()
		Endif
	Next
	oReport:SetTitle(cTitulo)
	oSecFil:Finish()
	oReport:EndPage()
	RestArea(aAreaSM0)
	cFilSEU := " EU_FILIAL "+ cRngFilSEU + " AND "
Else
	cFilSEU := " EU_FILIAL = '"+ xFilial("SEU",aSelFil[1]) + "' AND "
Endif
cFilSEU := "%"+cFilSEU+"%"
oSection1:SetHeaderSection(.T.)


//���������������������������Ŀ
//�MV_PAR05 - Mostra movimento�
//�	1 - Adiantamento          �
//�	2 - Prestacao de contas   �
//�	3 - Gastos                �
//�	4 - Todos                 �
//�EU_TIPO                    �
//� 00=Despesa                �
//� 01=Adiantamento           �
//� 02=Dev.Adiantamento       �
//� 03=Complemento adiantam   �
//� 10=Mov.Banco/Caixinha     �
//� 11=Mov.Caixinha/Banco     �
//�����������������������������

//Incrementa a clausula WHERE de acordo com os parametros
Do Case
	Case MV_PAR05 == 1 //Adiantamento
		cWhere	+= " AND EU_TIPO = '01' "
	Case MV_PAR05 == 2 //Pend. Prestacao de contas
		cWhere	+= " AND EU_TIPO = '00' AND EU_NROADIA != ''"
	Case MV_PAR05 == 3 //Gastos
		cWhere	+= " AND EU_TIPO IN ('00','02') "
EndCase

cWhere	+= If(lProcAlc," AND EU_STATUS <> '01' AND EU_STATUS <> '02' AND EU_STATUS <> '04' ","")
cWhere	:= "%" + cWhere + "%"

cQuery += SqlOrder(SEU->(IndexKey(4)))	//EU_FILIAL + EU_CAIXA + DTOS(EU_DTDIGIT) + EU_NUM
cQuery := "%" + cQuery + "%"


For nCampo := 1 To Len(aSEUStruct)
	If aSEUStruct[nCampo][DBS_TYPE] <> "M"
		cCampos += ", " + aSEUStruct[nCampo][DBS_NAME]
	EndIf
Next nCampo

cCampos := "%" + SubStr(cCampos, 2) + "%"

FwFreeArray(aSEUStruct)

BeginSQL Alias cAliasQry1
	COLUMN EU_DTDIGIT AS DATE
	SELECT %exp:cCampos%
	FROM %table:SEU% SEU
	WHERE %exp:cFilSEU%
	EU_CAIXA BETWEEN %exp:mv_par01% AND %exp:mv_par02% AND
	EU_DTDIGIT BETWEEN %exp:cDtini% AND %exp:cDtfim% AND
	SEU.%NotDel%
	%Exp:cWhere%
	ORDER BY %Exp:cQuery%
EndSQL

oSection:Cell("EU_CAIXA"):SetBlock({|| STR0011 + (cAliasQry1)->EU_CAIXA + " - " + SET->ET_NOME } )

If FXMultSld()
	If MV_PAR05 = 4
		TRCell():New(oSection1,"EU_SLDCXA","FIJ", STR0047 ,,15, .F.,{ || aDados[10] }, "RIGHT",,"RIGHT" ) // Saldo
		oSection:Cell("FIJ_SLDANT"):SetBlock({|| STR0039 + ": " + Transform( getSldAnt( (cAliasQry1)->EU_FILIAL, (cAliasQry1)->EU_CAIXA, MV_PAR03 ), PesqPict("SEU","EU_VALOR",16) ) } ) // "Saldo Anterior do Caixinha"
		oSection1:Cell("EU_SLDCXA"):SetBlock({|| Transform( aDados[10], PesqPict("SEU","EU_VALOR",16) ) } )
	Else
		oSection:Cell("FIJ_SLDANT"):SetBlock({|| STR0039 + ": " + Transform( getSldAnt( (cAliasQry1)->EU_FILIAL, (cAliasQry1)->EU_CAIXA, MV_PAR03 ), PesqPict("SEU","EU_VALOR",16) ) } ) // "Saldo Anterior do Caixinha"
	EndIf
Endif

oBreak1 := TRBreak():New( oSection,{|| (cAliasQry1)->(EU_CAIXA)},"",.F.)
oTotValor := TRFunction():New(oSection1:Cell("EU_VALOR"),/*CNAME*/,"SUM",oBreak1,STR0013,PesqPict("SEU","EU_VALOR",16)/*CPICTURE*/,/*UFORMULA*/,.F.,.F.,.F.,oSection1,{|| Iif(cPaisLoc $ "ARG|COS",!(cAliasQry1)->(EU_TIPO) $ "91|92",.T.) },.T.,/*BCANPRINT*/) //"Saldo dos Movimentos do Caixinha"
TRFunction():New(oSection1:Cell("EU_VALOR"),/*CNAME*/,"ONPRINT",oBreak1,STR0013,PesqPict("SEU","EU_VALOR",16)/*CPICTURE*/,{|| IIF(lConSur,oTotValor:GetValue(),oTotValor:GetValue() + nSldAdia - nSalAbat)},.F.,.F.,.F.,oSection1,/*BCONDITION*/,/*LDISABLE*/,/*BCANPRINT*/) //"Saldo dos Movimentos do Caixinha"
If FXMultSld()
	oBreak2 := TRBreak():New( oSection,{|| (cAliasQry1)->(EU_CAIXA)},"",.F.)
	oBreak2:SetTitle( STR0040 )
	oTotCx := TRFunction():New(oSection1:Cell("EU_VALOR"),/*CNAME*/,"SUM",oBreak2,STR0040,PesqPict("SEU","EU_VALOR",16)/*CPICTURE*/,/*UFORMULA*/,.F.,.F.,.F.,oSection1,/*BCONDITION*/,.T.,/*BCANPRINT*/) //"Saldo dos Movimentos do Caixinha"
	TRFunction():New(oSection1:Cell("EU_VALOR"),/*CNAME*/,"ONPRINT",oBreak2,STR0040,PesqPict("SEU","EU_VALOR",16)/*CPICTURE*/,{|| /*oTotCx:GetValue()*/ nSaldoCxa},.F.,.F.,.F.,oSection1,/*BCONDITION*/,/*LDISABLE*/,/*BCANPRINT*/) //"Saldo dos Movimentos do Caixinha" 
EndIf

(cAliasQry1)->(dbGoTop())

If MV_PAR05 == 3 //Gastos
	oSection1:SetTotalText(STR0014) //"Total Despesas -->"
	oBreak1:SetTitle(STR0014) //"Total Despesas -->"
Else
	oSection1:SetTotalText(STR0013) //"Saldo dos Movimentos do Caixinha->"
	oBreak1:SetTitle(STR0013) //"Saldo dos Movimentos do Caixinha->"
EndIf

If Len(aSelFil) > 1
	aSort(aSelFil)
	cFilAnt := aSelFil[nC]
	cUN  := FWUnitBusiness()
	cEmp := FWCodEmp()
	cUNold := cUN
	cEmpOld := cEmp
EndIf

For nC := 1 To Len(aSelFil) Step 1

	If aSelFil[nC] <> cFilAnt .And. mv_par06 == 1

		If cSEUEmp == "E" .And. cSEUUN == "E" .And. cSEUFil == "C" .And. mv_par06 == 1
			While cUN == cUNold
				nC += 1
				If nC > Len(aSelFil)
					cUN := ""
				Else
					cFilAnt := aSelFil[nC]
					cUN := FWUnitBusiness()
				EndIf
			EndDo

			If nC > Len(aSelFil)
				Loop
			EndIf 
		EndIf

		If cSEUEmp == "E" .And. cSEUUN == "C" .And. cSEUFil == "C" .And. mv_par06 == 1
			While cEmp == cEmpOld
				nC += 1
				If nC > Len(aSelFil)
					cEmp := ""
				Else
					cFilAnt := aSelFil[nC]
					cEmp := FWCodEmp()
				EndIf
			EndDo

			If nC > Len(aSelFil)
				Loop
			EndIf 
		EndIf

		If cSEUEmp == "C" .And. cSEUUN == "C" .And. cSEUFil == "C" .And. mv_par06 == 1
			nC := Len(aSelFil) + 1
			Loop
		EndIf

		cFilAnt := aSelFil[nC]
		cUN  := FWUnitBusiness()
		cEmp := FWCodEmp()
		cUNold := cUN
		cEmpOld := cEmp

		SEU->(dbSeek(xFilial("SEU")))

		If SEU->(EOF())
			Loop
		Else
			lPrtFil := .T.
		EndIf
	EndIf

	aDados[10] 	:= getSldAnt( (cAliasQry1)->EU_FILIAL, (cAliasQry1)->EU_CAIXA, MV_PAR03 )
	cCaixinha	:= (cAliasQry1)->EU_CAIXA
	
	While (cAliasQry1)->(!EOF()) .And. (cAliasQry1)->EU_FILIAL == xFilial("SEU")

		If cCaixinha = (cAliasQry1)->EU_CAIXA
			If lSldAtu
				aDados[10] += nSaldoAtu
				lSldAtu := .F.
			Else
				aDados[10] := nSaldoAtu
			Endif
		Else
			cCaixinha := (cAliasQry1)->EU_CAIXA
			aDados[10] := getSldAnt( (cAliasQry1)->EU_FILIAL, (cAliasQry1)->EU_CAIXA, MV_PAR03 )
		Endif

		//�����������������������������Ŀ
		//� Considera filtro do usuario �
		//�������������������������������
		DbSelectArea(cAliasQry1)		
		If !Empty(cFilterUser).and.!(&cFilterUser)
			(cAliasQry1)->(dbSkip())
			Loop
		Endif

		If cCaixa <> (cAliasQry1)->EU_CAIXA
			cSeqCxa := Fa570SeqAtu( (cAliasQry1)->EU_CAIXA )
		EndIf

	 	If cCaixa <> (cAliasQry1)->EU_CAIXA .And. MV_PAR05 <> 3
			If !lSaldo
				nSaldoTot	+= nSaldo
				nSaldo		:= 0
				lSaldo		:= .T.
				lPrinted	:= .F.
			Endif
			If FXMultSld()
				nSaldoCxa	:= getSldDia((cAliasQry1)->EU_FILIAL /*cFilCx*/, cCaixa/*(cAliasQry1)->EU_CAIXA*/, MV_PAR04 )
			EndIf
		Endif
		//No caso de impressao de adiantamentos em aberto nao imprime os outros movimentos.
		If MV_PAR05 == 1 .And. !(cAliasQry1)->(Empty(EU_NROADIA)) .and. (cAliasQry1)->EU_TIPO <> "02"
			aArea	:=	(cAliasQry1)->(GetArea())
			SEU->(DbSetOrder(3))
			SEU->(DbSeek(xFilial()+(cAliasQry1)->EU_NROADIA))
			If SEU->EU_SLDADIA > 0 .Or. (cAliasQry1)->EU_TIPO == "00"
				RestArea(aArea)
				(cAliasQry1)->(DbSkip())
				Loop
			Endif
			RestArea(aArea)
		Endif

		If !lPrinted
			//Gest�o Corporativa - In�cio
			If lPrtFil
				If mv_par06 == 1
					oReport:SkipLine()
					oFilial:Init()
					oFilial:Cell("Filial"):SetBlock({|| STR0046 + xFilial("SEU")}) //"Filial : "
					oFilial:PrintLine()
					oFilial:Finish()
					oReport:SkipLine()
				EndIf
				lPrtFil := .F.
				nFilCx := cFilAnt
			EndIf
			//Gest�o Corporativa - Fim
			oSection:Init()
			oSection1:Init()
			SET->(DbSetOrder(1))
			SET->(DbSeek(xFilial() + (cAliasQry1)->EU_CAIXA))
			oSection:PrintLine()
			cCaixa := (cAliasQry1)->EU_CAIXA
			lPrinted := .T.
			nSldAdia := 0
		Endif

		lSaldo := .F.
		SEU->(DbSetOrder(1))
		SEU->(DbSeek(xFilial()+ (cAliasQry1)->EU_NUM))

		If (cAliasQry1)->EU_DTDIGIT >= mv_par03 .and. (cAliasQry1)->EU_DTDIGIT <= mv_par04
			If (cAliasQry1)->EU_TIPO <> "02"
				IIf(MV_PAR05 == 2, aDados[9] := SEU->EU_SLDADIA, Nil) //Se for exibir as Pend Prest Contas mostra o saldo pendente
				F560PrintR4(0,Titulo,.T.,cAliasQry1,@aDados)
				If (mv_par05 == 1 .OR. mv_par05 == 4).And. (cAliasQry1)->EU_TIPO $ "01"
					If (cAliasQry1)->(EU_VALOR-EU_SLDADIA) > 0
						aDados[8] := (cAliasQry1)->(EU_VALOR-EU_SLDADIA)  // imprime o valor do adiantamento que j� foi devolvido
					EndIf
					If (cAliasQry1)->EU_VALOR <> (cAliasQry1)->EU_SLDADIA .AND. mv_par05 == 4
						nSldAdia  += (cAliasQry1)->(EU_VALOR-EU_SLDADIA)   // soma o que ja foi devolvido para compor o saldo corretamente
					Endif
				EndIf
				nSaldoAtu := aDados[10] 
				oSection1:PrintLine()
				aFill(aDados, nil)
			Else
			 If MV_PAR05 == 3 //.And. ((cAliasQry1)->EU_TIPO == "00" .OR.  (cAliasQry1)->EU_TIPO == "02")
		 	    F560PrintR4(0,Titulo,.T.,cAliasQry1,@aDados)
		 	 Endif
				aArea:=GetArea()
				SEU->(DbSetOrder(1))
				If (cAliasQry1)->EU_TIPO $ "00|02" //.OR.  (cAliasQry1)->EU_TIPO == "02")//SEU->(DbSeek(xFilial()+ (cAliasQry1)->EU_NROADIA)) .And. SEU->EU_TIPO =="00"
					RestArea(aArea)
					F560PrintR4(0,Titulo,.T.,cAliasQry1,@aDados)
					nSaldoAtu := aDados[10] 
					oSection1:PrintLine()
					aFill(aDados, nil)
				Else
					RestArea(aArea)
				EndIf
			EndIf

			If (mv_par05 == 1 .Or. mv_par05 == 2)  .And. (cAliasQry1)->EU_TIPO $ "01|03"
				If (cAliasQry1)->EU_VALOR <> (cAliasQry1)->EU_SLDADIA
					nSaldoAtu := aDados[10]  
					aFill(aDados, nil)
					aDados[1] := "  " + STR0012 //"Detalhes do Adiantamento"
					nSaldoAtu := aDados[10]  
					oSection1:PrintLine()
					aFill(aDados, nil)
					aArea	:=	GetArea()
					SEU->(DbSetOrder(3))
					cAdia	:=	(cAliasQry1)->EU_NUM 
					SEU->(DbSeek(xFilial()+cAdia))
					cAdto	:= SEU->EU_NROADIA
					While !SEU->(EOF()) .And. xFilial("SEU") == SEU->EU_FILIAL .And. SEU->EU_NROADIA == cAdia
						F560PrintR4(4,Titulo,.F.,"SEU",@aDados)
						nSaldoAtu := aDados[10]  
						oSection1:PrintLine()
						aFill(aDados, nil)
						SEU->(DbSkip())
					Enddo
					RestArea(aArea)
			   	Endif
			Endif

		EndIf

		(cAliasQry1)->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		If cCaixa <> (cAliasQry1)->EU_CAIXA .And. !lSaldo
			nSaldoTot	+= nSaldo - nSalAbat 
			nSaldo		:= 0
			nSalAbat   := 0
			lSaldo		:= .T.
			lPrinted	:= .F.
			If (cAliasQry1)->(EOF()) .Or. (cAliasQry1)->EU_FILIAL != xFilial("SEU")
				If Empty(cCaixa)
					cCaixa := (cAliasQry1)->EU_CAIXA 	
				Endif			
				nSaldoCxa	:= getSldDia( xFilial("SEU",aSelFil[nC]) /*cFilCx*/, cCaixa/*(cAliasQry1)->EU_CAIXA*/, MV_PAR04 )
			EndIf
			If lConSur
				nSaldoCxa := nSaldoAtu
			Endif
			oSection1:Finish()
		Endif
	EndDo

	If !lSaldo
		nSaldoTot	+=	nSaldo
	Endif

	oSection:Finish()
	oSection1:Finish()
Next

cFilAnt := cFilialAnt //Gest�o Corporativa

//Gest�o Corporativa - In�cio

For nX := 1 TO Len(aTmpFil)
	CtbTmpErase(aTmpFil[nX])
Next


RestArea(aAreaSEU)
RestArea(aAreaSET)
RestArea(aAreaORI)
//Gest�o Corporativa - Fim

Return

/*/
 �����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Fun��o    �F560PrintR4� Autor � Bruno Sobieski     � Data �  28/07/06   ���
��������������������������������������������������������������������������͹��
���Descri��o � Imprime um item.                                            ���
��������������������������������������������������������������������������͹��
���Uso       � Programa principal                                          ���
��������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F560PrintR4(nDesp,Titulo,lEst,cAliasQry1,aDados)
Local cTipo 	:= ""
Local nVlRep	:= 0
Local aAreaSEU	:= {}

Do Case
	Case (cAliasQry1)->EU_TIPO == "00"
		cTipo := IIf(Empty((cAliasQry1)->EU_HISTOR),STR0016,(cAliasQry1)->EU_HISTOR) //"Gasto"

	Case (cAliasQry1)->EU_TIPO == "01"
		cTipo := IIf(Empty((cAliasQry1)->EU_HISTOR),STR0017,STR0018+ Substr((cAliasQry1)->EU_HISTOR,1,20)) //"Anticipo"###"Ant. "

	Case (cAliasQry1)->EU_TIPO == "02"
		cTipo := If(lEst,STR0027,STR0019) //"Estorno de Despesa"###"Dev. Anticipo"

	Case (cAliasQry1)->EU_TIPO == "10"
		cTipo := STR0020 //"Reposicion"

	Case (cAliasQry1)->EU_TIPO == "11"
		cTipo := IIf(Empty((cAliasQry1)->EU_HISTOR),STR0021,(cAliasQry1)->EU_HISTOR) //"Transf. por cierre"

	Case (cAliasQry1)->EU_TIPO == "12"
		cTipo := IIf(Empty((cAliasQry1)->EU_HISTOR),STR0022,(cAliasQry1)->EU_HISTOR) //"Dev. por cierre Caja Menor"

	Case (cAliasQry1)->EU_TIPO == "13"
		cTipo := IIf(Empty((cAliasQry1)->EU_HISTOR),STR0023,(cAliasQry1)->EU_HISTOR) //"Repos. Caja Menor"

	Case (cAliasQry1)->EU_TIPO == "90"
		cTipo := STR0024 //"Reposicao cancelada"

	Case (cAliasQry1)->EU_TIPO == "91"
		cTipo := STR0025 //"Aguardando autorizacao para reposicao"

	Case (cAliasQry1)->EU_TIPO == "92"
		cTipo := STR0026 //"Aguardando debito do titulo para reposicao"

	Case (cAliasQry1)->EU_TIPO == "03"
		cTipo := (cAliasQry1)->EU_HISTOR
Endcase
//If nLin > 58 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
//	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
//	nLin := 9
//Endif

aDados[1] := Space(nDesp) + cTipo
//@nLin,000+nDesp	PSAY	cTipo

If (cAliasQry1)->EU_TIPO < "90"
	aDados[2] := (cAliasQry1)->EU_BENEF
	//@nLin,029			PSAY	Substr(EU_BENEF,1,19)
Endif

aDados[3] := (cAliasQry1)->EU_NRCOMP
aDados[4] := (cAliasQry1)->EU_NUM 
aDados[5] := (cAliasQry1)->EU_NROADIA
aDados[6] := (cAliasQry1)->EU_DTDIGIT
/*
@nLin,049			PSAY	EU_NRCOMP 	PICTURE PesqPict("SEU","EU_NRCOMP")
@nLin,062			PSAY	EU_NUM		PICTURE PesqPict("SEU","EU_NUM")
@nLin,076			PSAY	EU_NROADIA	PICTURE PesqPict("SEU","EU_NROADIA")
@nLin,088			PSAY	DTOC(EU_DTDIGIT)
*/
If (cAliasQry1)->EU_TIPO < "90"
	nSigno	:=	IIf(MV_PAR05 == 3 .Or. !((cAliasQry1)->EU_TIPO $ "00|01|03|11|13"),1,-1) 

	If !Empty(EU_NROADIA) .and. MV_PAR05 == 3  .And. EU_TIPO == "02"
		nSigno	:=  -1
	EndIf

	If cSeqCxa == (cAliasQry1)->EU_SEQCXA .And. (cAliasQry1)->EU_TIPO == "10"
		nVlRep := (cAliasQry1)->EU_VALOR * nSigno
		aDados[7]  := nVlRep
		aDados[10] += aDados[7]
		If (nVlRep+SET->ET_SALANT) > SET->ET_VALOR
			nSaldo	  := nvlRep
			nSldAdia  := 0
		Else
	 		nSaldo	  += nvlRep
		EndIf
	Else
		If nDesp == 0
			If MV_PAR05 <> 3	
				aDados[7] := (cAliasQry1)->EU_VALOR *  Iif(SEU->EU_TIPO $ "02" .And. nSigno < 1, 1, nSigno) 
				If SEU->EU_TIPO $ "11" .And. Empty(SEU->EU_NRREND)
					aDados[10] := 0
				ElseIf SEU->EU_TIPO $ "11" .And. !Empty(SEU->EU_NRREND)
					aDados[10] += aDados[7]
				ElseIf lConSur .And. SEU->EU_TIPO $ "00" .And. !Empty(SEU->EU_NROADIA )
					aDados[10] += aDados[7]
                ElseIf SEU->EU_TIPO $ "00|02" .And. !Empty(SEU->EU_NROADIA ) .And. SEU->EU_ENVUMOV <>"2"
                    aDados[10] := aDados[10]
                ElseIf SEU->EU_TIPO $ "02" .And. !Empty(SEU->EU_NROADIA ) .And. SEU->EU_ENVUMOV =="2"
                    aDados[10] += aDados[7]
                Else
					If aDados[10] = Nil
						aDados[10] := 0
						aDados[10] += aDados[7]
					Else
						aDados[10] += aDados[7]
					Endif
				Endif
				If SEU->EU_TIPO $ "02" .and. !Empty(SEU->EU_BAIXA) 
					aAreaSEU := SEU->(GetArea())
					DbSelectArea("SEU")
					SEU->(DbSetOrder(1))
					
					If (DbSeek(xFilial("SEU")+EU_NROADIA)) .And. AllTrim(SEU->EU_TIPO)  == "01"
						aDados[8] := (cAliasQry1)->EU_VALOR  // Contra partida de Estorno de Despesa
					EndIf
					
					RestArea(aAreaSEU)
				Endif
			Else 
				aDados[7]  := (cAliasQry1)->EU_VALOR * nSigno
				aDados[10] += aDados[7]
			EndIf 
		ElseIf  (cAliasQry1)->EU_TIPO == "03" //Devolucao de adiantamento
			aDados[7]  := (cAliasQry1)->EU_VALOR * nSigno
			If aDados[10] = Nil
				aDados[10] := 0
				aDados[10] += aDados[7]
			Else
				aDados[10] += aDados[7]
			Endif
		Else
			If (cAliasQry1)->EU_TIPO == "02" //Devolucao de adiantamento
				aDados[7]	:= (cAliasQry1)->EU_VALOR
				aDados[10]	:= aDados[7]
			Endif
			
			aDados[8] := (cAliasQry1)->EU_VALOR
		Endif
   		
   		If nDesp == 0 .Or. (cAliasQry1)->EU_TIPO $ "02|03"
   			If MV_PAR05 <> 3
   				nSigno := Iif(SEU->EU_TIPO $ "02|03" .And. nSigno < 1, 1, nSigno) //devolu� no caixinha 
   			EndIf 
			
			nSaldo		+=	((cAliasQry1)->EU_VALOR * nSigno)
			
			If Len(Adados) > 8
				If !Empty(Adados[8]) .and. lEst .and. (cAliasQry1)->EU_TIPO $ "02"
					nSldAdia	-=	ADADOS[8]
				Endif	
			Endif		
		Endif
	EndIf
ElseIf (cAliasQry1)->EU_TIPO > "90"
	aDados[7]  := (cAliasQry1)->EU_VALOR
	aDados[10] += aDados[7]
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �getSldAnt � Autor � Totvs              � Data �  13/11/09   ���
�������������������������������������������������������������������������͹��
���Descri��o � Obtem o saldo anterior da caixinha                         ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function getSldAnt( cFil, cCaixa, dData )
Local nRet		:= 0
Local cQry		:= ""
Local aArea	:= GetArea()

#IFDEF TOP

	cQry += "SELECT FIJ_DATA, FIJ_SALDO "
	cQry += "FROM " + RetSqlName( "FIJ" ) + " "
	cQry += "WHERE 	FIJ_DATA < '" + DtoS( dData ) + "' AND "
	cQry += "		FIJ_FILIAL = '" + FwXFilial("FIJ") + "' AND "
	cQry += "		FIJ_CODCX = '" + cCaixa + "' AND "
	cQry += "		D_E_L_E_T_ = ' '"
	cQry += "ORDER BY FIJ_DATA DESC	"
	cQry := ChangeQuery( cQry )

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ), "FIJTMP", .T., .T. )

	If FIJTMP->( !Eof() )
		nRet := FIJTMP->FIJ_SALDO
	EndIf

	FIJTMP->( DbCloseArea() )

#ELSE

	cChave	:= "FIJ_FILIAL+DTOS(FIJ_DATA)+FIJ_CODCX"
	nOrdem 	:= FIJ->(IndexOrd())

	dbSelectArea("FIJ")
	dbSetOrder(1)
	cIndex	:= CriaTrab(nil,.f.)
	dbSelectArea("FIJ")
	IndRegua("FIJ",cIndex,cChave,,Nil,)  //"Selecionando Registros..."
	nIndex	:= RetIndex("FIJ")
	dbSetIndex(cIndex+OrdBagExt())
	dbSetOrder(nIndex+1)
	FIJ->(DbSeek(xFilial("FIJ")))
	While !FIJ->(Eof()) .And. FIJ->FIJ_FILIAL = xFilial("FIJ")
		If Dtos(FIJ->FIJ_DATA) > Dtos(dData) .Or. FIJ->FIJ_CODCX <> cCaixa
			Exit
		ElseIf Dtos(FIJ->FIJ_DATA) < Dtos(dData) .And. FIJ->FIJ_CODCX = cCaixa
			nRet := FIJ->FIJ_SALDO
		Endif
		FIJ->(Dbskip())
	Enddo

	IF cIndex != ""
		FErase (cIndex+OrdBagExt())
	EndIF

	dbSetOrder(nOrdem)
#ENDIF
	RestArea( aArea )
Return nRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �getSldDia � Autor � Totvs              � Data �  13/11/09   ���
�������������������������������������������������������������������������͹��
���Descri��o � Obtem o saldo anterior da caixinha                         ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function getSldDia( cFil, cCaixa, dData )
Local nRet		:= 0
Local cQry		:= ""
Local aArea	:= GetArea()

#IFDEF TOP
	cQry += "SELECT FIJ_DATA, FIJ_SALDO "
	cQry += "FROM " + RetSqlName( "FIJ" ) + " "
	cQry += "WHERE 	FIJ_DATA <= '" + DtoS( dData ) + "' AND "
	cQry += "		FIJ_CODCX = '" + cCaixa + "' AND "
	cQry += "FIJ_FILIAL = '" + FwXFilial("FIJ") + "' AND "
	cQry += "		D_E_L_E_T_ = ' '"
	cQry += "ORDER BY FIJ_DATA DESC	"
	cQry := ChangeQuery( cQry )

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ), "FIJTMP", .T., .T. )

	If FIJTMP->( !Eof() )
		nRet := FIJTMP->FIJ_SALDO
	EndIf

	FIJTMP->( DbCloseArea() )

#ELSE
	cChave	:= "FIJ_FILIAL+DTOS(FIJ_DATA)+FIJ_CODCX"
	nOrdem 	:= FIJ->(IndexOrd())

	dbSelectArea("FIJ")
	dbSetOrder(1)
	cIndex	:= CriaTrab(nil,.f.)
	dbSelectArea("FIJ")
	IndRegua("FIJ",cIndex,cChave,,Nil,)  //"Selecionando Registros..."
	nIndex	:= RetIndex("FIJ")
	dbSetIndex(cIndex+OrdBagExt())
	dbSetOrder(nIndex+1)
	FIJ->(DbSeek(xFilial("FIJ")))
	While !FIJ->(Eof()) .And. FIJ->FIJ_FILIAL = xFilial("FIJ")
		If Dtos(FIJ->FIJ_DATA) > Dtos(dData) .Or. FIJ->FIJ_CODCX <> cCaixa
			Exit
		ElseIf Dtos(FIJ->FIJ_DATA) <= Dtos(dData) .And. FIJ->FIJ_CODCX = cCaixa
			nRet := FIJ->FIJ_SALDO
		Endif
		FIJ->(Dbskip())
	Enddo

	IF cIndex != ""
		FErase (cIndex+OrdBagExt())
	EndIF

	dbSetOrder(nOrdem)
#ENDIF
	RestArea( aArea )
Return nRet
