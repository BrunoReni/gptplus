// 浜様様様曜様様様様�
// � Versao � 12     �
// 藩様様様擁様様様様� 
#Include "PROTHEUS.Ch"
#Include "OFIPR160.Ch"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFIPR160 � Autor � Andre Luis Almeida    � Data � 10/08/06 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Relacao das Divergencias do Inventario                     咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIPR160(cVPE)
Default cVPE   := ""
Private cDesc1 := STR0001
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "M"
Private limite := 132 
Private cString:= "VPG"
Private titulo := STR0001
Private cabec1 := ""
Private cabec2 := ""
Private aReturn := {STR0002,1,STR0003,1,2,1,"",1}  
Private nomeprog:= "OFIPR160"
Private aLinha  := { },nLastKey := 0
Private cPerg   := If(Empty(cVPE),"OFP160",nil)
//////////// PERGUNTE - OFP160 ////////////
//  01  Codigo Contagem  MV_PAR01  C  6  //
///////////////////////////////////////////

ValidPerg()

nomeprog := SetPrint(cString,nomeprog,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf     
If Empty(cVPE)
	Pergunte(cPerg,.f.)
Else
	MV_PAR01 := cVPE
	MV_PAR02 := 1
EndIf
SetDefault(aReturn,cString)
RptStatus( { |lEnd| FS_OFIPR160(@lEnd,nomeprog,cString) } , Titulo )
If aReturn[5] == 1
   OurSpool( nomeprog )
EndIf
MS_Flush()
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � FS_OFIPR160 � Autor � Andre Luis Almeida � Data � 10/08/06 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Relacao das Divergencias do Inventario                     咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function FS_OFIPR160()
Local ni := 0
Local nQtd := 0
Local nDig := 0
Local nPIte := 0
Local nPDiv := 0
Local nPCus := 0
Local nNIte := 0
Local nNDiv := 0
Local nNCus := 0
Local cQuery := ""
Local cQAlVPG := "SQLVPG"  // VPG


titulo := STR0001+" ( "+MV_PAR01+" )"
nLin  := 0
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
DbSelectArea("VPE")
DbSetOrder(1)
If DbSeek(xFilial("VPE")+MV_PAR01)
	cabec1 := space(36)+STR0004+" - "+STR0005+Transform(VPE->VPE_DATINI,"@D")+" "+Transform(VPE->VPE_HORINI,"@R 99:99")+" "+STR0008
	If VPE->VPE_FASE == "99"
		cabec1 += " - "+STR0006+Transform(VPE->VPE_DATFIN,"@D")+" "+Transform(VPE->VPE_HORFIN,"@R 99:99")+" "+STR0008
		cabec2 := STR0009
	ElseIf VPE->VPE_FASE == "XX"
		cabec1 += " - "+STR0007+Transform(VPE->VPE_DATFIN,"@D")+" "+Transform(VPE->VPE_HORFIN,"@R 99:99")+" "+STR0008
	EndIf
	nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
	DbSelectArea("VPG")
	cQuery := "SELECT VPG.VPG_QTDEST , VPG.VPG_DIVERG , VPG.VPG_CUSTO , VPG.VPG_GRUITE , VPG.VPG_CODITE , VPG.VPG_ALMOX , VPG.VPG_LOCAC , SB1.B1_DESC "
	cQuery += "  FROM "+RetSqlName("VPG")+" VPG "
	cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO = VPG.VPG_GRUITE AND SB1.B1_CODITE = VPG.VPG_CODITE AND SB1.D_E_L_E_T_=' ' ) "
	cQuery += " WHERE VPG.VPG_FILIAL='"+xFilial("VPG")+"' AND VPG.VPG_CODIGO = '"+MV_PAR01+"' "
	cQuery += "   AND VPG.D_E_L_E_T_=' ' "
	If MV_PAR02 == 1 //Grupo e C�digo
		cQuery += " ORDER BY VPG.VPG_GRUITE , VPG.VPG_CODITE "
	ElseIf MV_PAR02 == 2 //Loca艫o
		cQuery += " ORDER BY VPG.VPG_LOCAC , VPG.VPG_GRUITE , VPG.VPG_CODITE "
	ElseIf MV_PAR02 == 3 //Descri艫o
		cQuery += " ORDER BY SB1.B1_DESC , VPG.VPG_GRUITE , VPG.VPG_CODITE , VPG.VPG_LOCAC"
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVPG, .F., .T. ) 
	While !( cQAlVPG )->( Eof() )
		If nLin >= 60
			nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
		EndIf
		ni++
		nQtd += ( cQAlVPG )->VPG_QTDEST
		nDig += ( cQAlVPG )->VPG_QTDEST+( cQAlVPG )->VPG_DIVERG
		If ( cQAlVPG )->VPG_DIVERG > 0
			nPIte++
			nPDiv += ( cQAlVPG )->VPG_DIVERG
			nPCus += ( cQAlVPG )->VPG_CUSTO
		Else
			nNIte++
			nNDiv += ( cQAlVPG )->VPG_DIVERG
			nNCus += ( cQAlVPG )->VPG_CUSTO
		EndIf
		@nLin++, 00 PSAY strzero(ni,6)+" "+( cQAlVPG )->VPG_GRUITE+" "+( cQAlVPG )->VPG_CODITE+" "+( cQAlVPG )->VPG_ALMOX+" "+( cQAlVPG )->VPG_LOCAC+" "+left(( cQAlVPG )->B1_DESC,20)+Transform(( cQAlVPG )->VPG_QTDEST+( cQAlVPG )->VPG_DIVERG,"@E 99,999,999.99")+Transform(( cQAlVPG )->VPG_QTDEST,"@E 99,999,999.99")+Transform(( cQAlVPG )->VPG_DIVERG,"@E 99,999,999.99")+Transform(( cQAlVPG )->VPG_CUSTO,"@E 9,999,999.9999")
		( cQAlVPG )-> (DbSkip())
	EndDo
	( cQAlVPG )-> (DbCloseArea())
	DbSelectArea("VPG")
	@nLin++, 00 PSAY repl("-",132)
	@nLin++, 00 PSAY space(75)+STR0019
	@nLin++, 00 PSAY left(STR0010+space(30),30)+left("("+Transform(nPIte,"@E 999,999")+" "+STR0013+" )"+space(70),70)+Transform(nPDiv,"@E 99,999,999.99")+"  "+Transform(nPCus,"@E 999,999,999.9999")
	@nLin++, 00 PSAY left(STR0011+space(30),30)+left("("+Transform(nNIte,"@E 999,999")+" "+STR0013+" )"+space(70),70)+Transform(nNDiv,"@E 99,999,999.99")+"  "+Transform(nNCus,"@E 999,999,999.9999")
	@nLin++, 00 PSAY left(STR0012+space(30),30)+left("("+Transform(nPIte+nNIte,"@E 999,999")+" "+STR0013+" )"+space(44),44)+Transform(nDig,"@E 99,999,999.99")+Transform(nQtd,"@E 99,999,999.99")+Transform(nPDiv+ABS(nNDiv),"@E 99,999,999.99")+"  "+Transform(nPCus+nNCus,"@E 999,999,999.9999")
	@nLin++, 00 PSAY repl("-",132)
EndIf
Set Printer to
Set Device  to Screen
Return

/*/
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � ValidPerg� Autor � Rogerio Vaz Melonio� Data �  18/03/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Acompanhamento de Vendas por Recepcioniosta                咳�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
/*/
Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))

// Grupo/Ordem/Pergunta/Pergunta Espanhol/Pergunta Ingles/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/DefSpa1/DefEng1/Cnt01/Var02/Def02/DefSpa2/DefEng2/Cnt02/Var03/Def03/DefSpa3/DefEng3/Cnt03/Var04/Def04/DefSpa4/DefEng4/Cnt04/Var05/Def05/DefSpa5/DefEng5/Cnt05/F3/GRPSX6
aAdd(aRegs,{cPerg,"01",STR0014,"","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","VPE","",""})
aAdd(aRegs,{cPerg,"02",STR0015,"","","mv_ch2","N",1,0,0,"C","","mv_par02",STR0016,STR0016,STR0016,"","",STR0017,STR0017,STR0017,"","",STR0018,STR0018,STR0018,"","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return