#Include "Average.ch"
#Include "EICRMAPA.ch"

/*
Programa   : EICRMAPA
Objetivo   : Relat�rio - Mapa de Importa��o
Autor      : Saimon Vinicius Gava 
Data/Hora  : 18/11/2009 17:25:07
*/ 

/* 
Funcao     : EICRMAPA() 
Parametros : Nenhum 
Retorno    : 
Objetivos  : Chamada do Menu para a Cria��o do Relat�rio Mapa de Importa��o
Autor      : Saimon Vinicius Gava 
Data/Hora  : 18/11/2009 17:25:07
*/
*-----------------------------*                              
Function EICRMAPA()
*-----------------------------*
Local oReport

#IFDEF TOP
	If FindFunction("TRepInUse") .And. TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	Else
		Aviso(STR0009,STR0002,{STR0003}) //"Nao disponivel"###"Esta funcionalidade so esta disponivel para os relatorios personalizaveis"###"Fechar"
	Endif
#ELSE
	Aviso(STR0009,STR0004,{STR0003}) //"Nao disponivel"###"Esta funcionalidade so esta disponivel para uso com bancos de dados relacionais"###"Fechar"
#ENDIF

Return .F.

Static Function ReportDef()
Local oReport  
Local oSection1, oSection2, oBreak1
Local cAliasQry1 := GetNextAlias()
Local nTamanho:=AvSx3("W3_COD_I",3)
oReport := TReport():New("EICRMAPA",STR0001,"EICRMAPA",;  //"Relacao de faturas"
{|oReport| ReportPrint(oReport,cAliasQry1)},STR0006) //"Este programa ira emitir a Relacao das faturas a pagar, e o detalhe dos titulos que compoem cada fatura. "

oReport:SetPortrait(.T.)

Pergunte(oReport:uParam,.T.)

//MFR 22/12/2020 OSSME-5462          //Mapa de importa��o
oSection1 := TRSection():New(oReport,STR0001,{"SW2","SW3","SW4","SW5","SW6","SW7","SW8","SW9","SWN","SF1","SWP"}, )  

TRCell():New(oSection1,"W2_PO_NUM" ,"SW2",STR0010,,AvSx3("W2_PO_NUM",AV_TAMANHO),.T.,{|| (cAliasQry1)->W2_PO_NUM})
TRCell():New(oSection1,"W2_MOEDA"  ,"SW2",STR0011,,AvSx3("W2_MOEDA",AV_TAMANHO),.F.,{|| (cAliasQry1)->W2_MOEDA})
TRCell():New(oSection1,"W3_COD_I"  ,"SW3",,,AvSx3("W3_COD_I",AV_TAMANHO),.F.,{|| (cAliasQry1)->W3_COD_I})
//TRCell():New(oSection1,"B1_DESC"   ,"SB1",,,15,.F.,{|| (cAliasQry1)->B1_DESC})
TRCell():New(oSection1,"W3_QTDE"   ,"SE2",STR0012,,,.F.,{|| (cAliasQry1)->W3_QTDE})
TRCell():New(oSection1,"WP_REGIST" ,"SWP",,,Len(Transform(Space(AvSx3("WP_REGIST",AV_TAMANHO)),AvSx3("WP_REGIST",AV_PICTURE))),.F.,{|| (cAliasQry1)->WP_REGIST})
TRCell():New(oSection1,"W6_HAWB"   ,"SW6",STR0013,,,.F.,{|| (cAliasQry1)->W6_HAWB})
TRCell():New(oSection1,"W6_VIA_TRA","SW6",STR0014,,AvSx3("W6_VIA_TRA",AV_TAMANHO),.F.,{|| (cAliasQry1)->W6_VIA_TRA})
TRCell():New(oSection1,"W6_ORIGEM" ,"SW6",STR0015,,AvSx3("W6_ORIGEM",AV_TAMANHO),.F.,{|| (cAliasQry1)->W6_ORIGEM})                          
TRCell():New(oSection1,"W6_DEST"   ,"SW6",STR0016,,,.F.,{|| (cAliasQry1)->W6_DEST})
TRCell():New(oSection1,"W6_DT_EMB" ,"SW6",STR0017,,14,.F.,{|| (cAliasQry1)->W6_DT_EMB})  // GFP - 29/03/2012 - Ajuste no tamanho de datas
TRCell():New(oSection1,"W6_DTREG_D","SW6",STR0018 ,,14,.F.,{|| (cAliasQry1)->W6_DTREG_D})  // GFP - 29/03/2012 - Ajuste no tamanho de data
TRCell():New(oSection1,"W6_DI_NUM" ,"SW6",STR0019	,,Len(Transform(Space(AvSx3("W6_DI_NUM",AV_TAMANHO)),AvSx3("W6_DI_NUM",AV_PICTURE))),.F.,{|| (cAliasQry1)->W6_DI_NUM})
TRCell():New(oSection1,"W8_INVOICE","SW8",STR0020,,,.F.,{|| (cAliasQry1)->W8_INVOICE})
TRCell():New(oSection1,"WN_DOC"    ,"SWN",STR0021	,,AvSx3("WN_DOC",AV_TAMANHO)+AvSx3("WN_SERIE",AV_TAMANHO)+1,.F.,{|| (cAliasQry1)->WN_DOC+"-"+Transform((cAliasQry1)->WN_SERIE,AvSx3("WN_SERIE",AV_PICTURE))})
TRCell():New(oSection1,"F1_EMISSAO","SF1",STR0022,,,.F.,{|| (cAliasQry1)->F1_EMISSAO})
TRCell():New(oSection1,"WN_QUANT"  ,"SWN",,,,.F.,{|| (cAliasQry1)->WN_QUANT})

oSection1:SetTotalInLine(.T.)

Return oReport                                         


/* 
Funcao     : ReportPrint() 
Parametros : Nenhum 
Retorno    : 
Objetivos  : 
Autor      : Saimon Vinicius Gava 
Data/Hora  : 18/11/2009 17:25:07
*/
Static Function ReportPrint(oReport,cAliasQry1)
local oSX1      := FWSX1Util():New()
local aPergunte := {}
local lNewPerg  := .F.
local nPerg     := 2

Private oSection1 := oReport:Section(1)
Private oSection2 := oReport:Section(2)
Private cParam:=""
Private lParam:=.F. //LGS-23/05/2014
Private cBreak := "" //LRS

//Tabelas relacionadas {"SW2","SW3","SW4","SW5","SW6","SW7","SW8","SW9","SWN","SF1","SWP"}
TRPosition():New(oReport:Section(1),"SW2",1,{|| xFilial("SW2")+(cAliasQry1)->W2_PO_NUM})
TRPosition():New(oReport:Section(1),"SW3",1,{|| xFilial("SW3")+(cAliasQry1)->W2_PO_NUM+(cAliasQry1)->W3_CC+(cAliasQry1)->W3_SI_NUM+(cAliasQry1)->W3_COD_I+Str((cAliasQry1)->W3_REG,AVSX3("W3_REG",3))+Str((cAliasQry1)->W3_SEQ,AVSX3("W3_SEQ",3))})
TRPosition():New(oReport:Section(1),"SW4",1,{|| xFilial("SW4")+(cAliasQry1)->W3_PGI_NUM})
TRPosition():New(oReport:Section(1),"SW5",1,{|| xFilial("SW5")+(cAliasQry1)->W3_PGI_NUM+(cAliasQry1)->W3_CC+(cAliasQry1)->W3_SI_NUM+(cAliasQry1)->W3_COD_I})
TRPosition():New(oReport:Section(1),"SW6",1,{|| xFilial("SW6")+(cAliasQry1)->W6_HAWB})
TRPosition():New(oReport:Section(1),"SW7",1,{|| xFilial("SW7")+(cAliasQry1)->W6_HAWB+(cAliasQry1)->W3_PGI_NUM+(cAliasQry1)->W3_CC+(cAliasQry1)->W3_SI_NUM+(cAliasQry1)->W3_COD_I})
TRPosition():New(oReport:Section(1),"SW8",1,{|| xFilial("SW8")+(cAliasQry1)->W6_HAWB+(cAliasQry1)->W8_INVOICE+(cAliasQry1)->W2_FORN+(cAliasQry1)->W2_FORLOJ})
TRPosition():New(oReport:Section(1),"SW9",1,{|| xFilial("SW9")+(cAliasQry1)->W8_INVOICE+(cAliasQry1)->W2_FORN+(cAliasQry1)->W2_FORLOJ+(cAliasQry1)->W6_HAWB})
TRPosition():New(oReport:Section(1),"SWN",1,{|| xFilial("SWN")+(cAliasQry1)->WN_DOC+(cAliasQry1)->WN_SERIE+(cAliasQry1)->WN_TEC+(cAliasQry1)->WN_EX_NCM+(cAliasQry1)->WN_EX_NBM})
TRPosition():New(oReport:Section(1),"SF1",1,{|| xFilial("SF1")+(cAliasQry1)->WN_DOC+(cAliasQry1)->WN_SERIE+(cAliasQry1)->WN_FORNECE+(cAliasQry1)->WN_LOJA+(cAliasQry1)->F1_TIPO})
TRPosition():New(oReport:Section(1),"SWP",1,{|| xFilial("SWP")+(cAliasQry1)->W3_PGI_NUM})

oSX1:AddGroup("EICRMAPA")
oSX1:SearchGroup()
aPergunte := oSX1:GetGroup("EICRMAPA")
if len(aPergunte) > 0 .and. len(aPergunte[2]) > 7 .and. ("LOJA" $ alltrim(upper(aPergunte[2][3]["CX1_PERGUNT"])) .or. "TIENDA" $ alltrim(upper(aPergunte[2][3]["CX1_PERGUNT"])) .or. "STORE" $ alltrim(upper(aPergunte[2][3]["CX1_PERGUNT"])))
   lNewPerg := .T.
   nPerg += 1
endif

If !Empty(MV_PAR01)
   cParam += If(!Empty(cParam)," AND ","")+" SW2.W2_IMPORT = '"+mv_par01+"'"
EndIf
If !Empty(MV_PAR02)
   cParam += If(!Empty(cParam)," AND ","")+" SW2.W2_FORN = '"+mv_par02 + "'"
EndIf
if lNewPerg .and. !Empty(MV_PAR03)
   cParam += If(!Empty(cParam)," AND ","")+" SW2.W2_FORLOJ = '" + MV_PAR03 +"'"
endif
nPerg += 1
If !Empty(&("MV_PAR" + StrZero(nPerg,2)))
   cParam += If(!Empty(cParam)," AND ","")+" SW2.W2_MOEDA = '"+&("MV_PAR" + StrZero(nPerg,2))+"'"
EndIf
nPerg += 1
If !Empty(&("MV_PAR" + StrZero(nPerg,2)))
   cParam += If(!Empty(cParam)," AND ","")+" SW2.W2_PO_NUM ='"+&("MV_PAR" + StrZero(nPerg,2))+"'"
EndIf
nPerg += 1
If !Empty(&("MV_PAR" + StrZero(nPerg,2)))
   cParam += If(!Empty(cParam)," AND ","")+" SW3.W3_COD_I = '"+&("MV_PAR" + StrZero(nPerg,2))+"'" 
EndIf
nPerg += 1
If !Empty(&("MV_PAR" + StrZero(nPerg,2)))
   cParam += If(!Empty(cParam)," AND ","")+" SW2.W2_PO_DT >= '"+dToS(&("MV_PAR" + StrZero(nPerg,2)))+"'"
EndIf
nPerg += 1
If !Empty(&("MV_PAR" + StrZero(nPerg,2)))
   cParam += If(!Empty(cParam)," AND ","")+" SW2.W2_PO_DT <= '"+DToS(&("MV_PAR" + StrZero(nPerg,2)))+"'"
EndIf

If !Empty(cParam)
   cParam := "%WHERE" + cParam //+ " ORDER BY SW2.W2_IMPORT%"
EndIf

If(EasyEntryPoint("EICRMAPA"),ExecBlock("EICRMAPA",.F.,.F.,"PE_SUMARIZA"),)  //LGS-03/12/2013 - P.E. PARA SUMARIZAR RELATORIO.

//LGS-23/05/2014
If !lParam
   cParam += if ( empty(cParam), "%", "" ) + " ORDER BY SW2.W2_IMPORT, SW2.W2_FORN, SW2.W2_FORLOJ, SW3.W3_PO_NUM%"
EndIf

oSection1:BeginQuery()

	BeginSql Alias cAliasQry1
	   SELECT SW2.W2_PO_NUM,SW2.W2_FORN,SW2.W2_FORLOJ,SW2.W2_MOEDA,SW3.W3_COD_I,SW3.W3_PO_NUM,SW3.W3_QTDE,SW3.W3_SALDO_Q,SW2.W2_IMPORT, SW3.W3_CC, SW3.W3_SI_NUM, SW3.W3_REG, SW3.W3_SEQ, SW3.W3_PGI_NUM,//SB1.B1_DESC,
              SW5.W5_AC,SW8.W8_HAWB,SW8.W8_INVOICE,SW6.W6_HAWB,SW6.W6_VIA_TRA,SW6.W6_ORIGEM,SW6.W6_DEST,SW6.W6_DT_EMB,SW6.W6_DI_NUM,
              SW6.W6_DTREG_D,SWN.WN_DOC, SWN.WN_SERIE, SWN.WN_QUANT, SWN.WN_PRUNI ,SWN.WN_PRODUTO, SWN.WN_TEC, SWN.WN_EX_NCM, SWN.WN_EX_NBM, SWN.WN_FORNECE, SWN.WN_LOJA, SF1.F1_EMISSAO, SF1.F1_TIPO, SWP.WP_REGIST
       FROM 
             %table:SW2% SW2 INNER JOIN %table:SW3% SW3 ON SW3.W3_PO_NUM = SW2.W2_PO_NUM 
             AND SW3.%NotDel% AND SW2.%NotDel% AND SW3.W3_SEQ <> 0 AND SW2.W2_FILIAL = %xFilial:SW2%
             AND SW3.W3_FILIAL = %xFilial:SW3%
             LEFT OUTER JOIN %table:SB1% SB1 ON SW3.W3_COD_I  = SB1.B1_COD AND SB1.B1_FILIAL = %xFilial:SB1% AND SB1.%NotDel%  
             LEFT OUTER JOIN %table:SW5% SW5 ON SW5.W5_PO_NUM = SW3.W3_PO_NUM AND SW5.W5_COD_I = SW3.W3_COD_I AND SW5.W5_SEQ = 0 
             AND SW5.W5_PGI_NUM = SW3.W3_PGI_NUM AND SW5.W5_POSICAO = SW3.W3_POSICAO 
             AND SW5.%NotDel% AND SW5.W5_FILIAL = %xFilial:SW5%
             LEFT OUTER JOIN %table:SWP% SWP ON SWP.WP_PGI_NUM = SW5.W5_PGI_NUM AND SWP.%NotDel%
             LEFT OUTER JOIN %table:SW8% SW8 on SW8.W8_COD_I  = SW3.W3_COD_I AND SW8.W8_POSICAO = SW3.W3_POSICAO
             AND SW8.W8_PO_NUM = SW3.W3_PO_NUM AND SW8.W8_FORN = SW2.W2_FORN AND SW8.W8_FORLOJ = SW2.W2_FORLOJ  AND  SW8.%NotDel% AND SW8.W8_FILIAL = %xFilial:SW8% AND SW8.W8_PGI_NUM=SW3.W3_PGI_NUM
             LEFT OUTER JOIN %table:SW6% SW6 On SW6.W6_HAWB   = SW8.W8_HAWB AND SW6.%NotDel% AND SW6.W6_FILIAL = %xFilial:SW6%
             LEFT OUTER JOIN %table:SWN% SWN ON SWN.WN_HAWB   = SW8.W8_HAWB  AND SWN.WN_PO_EIC = SW3.W3_PO_NUM 
             AND SWN.WN_PRODUTO = SW3.W3_COD_I AND SWN.WN_HAWB = SW8.W8_HAWB AND SWN.WN_INVOICE = SW8.W8_INVOICE 
             AND SWN.WN_FORNECE = SW2.W2_FORN AND SWN.WN_LOJA = SW2.W2_FORLOJ  AND SWN.WN_TIPO_NF IN ('1','3','5') AND SWN.%NotDel% AND SWN.WN_FILIAL = %xFilial:SWN%
             AND SWN.WN_ITEM = SW8.W8_POSICAO AND SWN.WN_PGI_NUM = SW8.W8_PGI_NUM
             LEFT OUTER JOIN %table:SF1% SF1 ON SF1.F1_DOC= SWN.WN_DOC AND SF1.F1_SERIE  = SWN.WN_SERIE 
             AND SF1.F1_HAWB = SWN.WN_HAWB AND SF1.F1_FORNECE = SWN.WN_FORNECE AND SF1.F1_LOJA = SWN.WN_LOJA 
             AND SF1.%NotDel% 
             AND SF1.F1_FILIAL = %xFilial:SF1%
             %Exp:cParam%
            

	EndSql
	
oSection1:EndQuery() 

(cAliasQry1)->(dbGoTop())

oBreak1   := TRBreak():New( oSection1, {|| (cAliasQry1)->(W2_IMPORT + W2_FORN + W2_FORLOJ)},,.F.) // "Importador"  

WHILE (cAliasQry1)->(!EOF())
oSection1:Init()
oReport:IncMeter((cAliasQry1)->(LastRec())) 

		IF (cAliasQry1)->(W2_IMPORT + W2_FORN + W2_FORLOJ) <> cBreak
			cBreak:= (cAliasQry1)->(W2_IMPORT + W2_FORN + W2_FORLOJ)
			oReport:SkipLine(1)
			oReport:PrintText(STR0005 + alltrim((cAliasQry1)->(W2_IMPORT)) + STR0007 + STR0008 + alltrim((cAliasQry1)->W2_FORN) + " " + STR0024 + ": " + alltrim((cAliasQry1)->W2_FORLOJ))
         oReport:SetMeter((cAliasQry1)->(LastRec()))
		EndIF 
		
oSection1:PRINTLINE()		
(cAliasQry1)->(DBSKIP())	
ENDDO

/*
oBreak1   := TRBreak():New( oSection1, {|| (cAliasQry1)->(W2_IMPORT + W2_FORN)},,.F.) // "Importador"
oBreak1:bOnBreak:={||oReport:SkipLine(2),oReport:PrintText(if((cAliasQry1)->(!EOF()),STR0005+(cAliasQry1)->(W2_IMPORT)+STR0007 + STR0008 +(cAliasQry1)->(W2_FORN),""),,)}
oReport:SetMeter((cAliasQry1)->(LastRec()))

WHILE (cAliasQry1)->(!EOF())
	oSection1:Init()
    oReport:IncMeter((cAliasQry1)->(LastRec()))
	oSection1:PRINTLINE() 
    (cAliasQry1)->(DBSKIP())	
ENDDO
*/
oSection1:Finish()
Return
