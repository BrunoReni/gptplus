// 浜様様様曜様様様様�
// � Versao �   3    �
// 藩様様様擁様様様様�
#Include "Protheus.ch"
#Include "VEICR650.CH"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VEICR650 � Autor � Thiago                � Data � 12/06/12 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri�ao � Relatorio de Cruzamento de Metas X Consorcios Vendidos     咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEICR650()

Local cAlias     := "VQA"
Local cDesc3     :=""
Private cDesc1   := STR0001 // Relat�rio de Cruzamento de Metas X Cons�rcios Vendidos 
Private cabec1   := ""
Private cDesc2   := ""
Private cabec2   := ""
Private aReturn  := { "", 1,"", 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cTamanho := "M"           // P/M/G
Private Limite   := 132           // 80/132/220
Private cTitulo  := STR0001 // Relat�rio de Cruzamento de Metas X Cons�rcios Vendidos
Private cNomeRel := "VEICR650"
Private nLastKey := 0
Private nCaracter:= 15
Private cPerg    := "VCR650"
  
set printer to &cNomeRel
set printer on
set device to printer       

ValidPerg()

PERGUNTE(cPerg,.f.)

cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf     
  
SetDefault(aReturn,cAlias)

RptStatus({|lEnd| FS_VCR650(@lEnd,cNomeRel,cAlias)},cTitulo)

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � FS_VCR650 � Autor � Thiago               � Data � 12/06/12 咳�
臼団陳陳陳陳津陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri�ao � Impressao                                                  咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function FS_VCR650(lEnd,wNRel,cAlias)

Local cAliasVQA := "SQLVQA"
Local cQuery    := ""

M_PAG  := 1

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
nLin := cabec(cTitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1

cQuery := "SELECT VQA.VQA_DATINI,VQA.VQA_DATFIN,VQA.VQA_CODVEN,VQA.VQA_REGIAO,VQA.VQA_TIPVEI,VQA.VQA_QTDVEN,VQA.VQA_VLRVEN "
cQuery += "FROM " + RetSqlName( "VQA" ) + " VQA " + "WHERE "
cQuery += "VQA.VQA_FILIAL='"+ xFilial("VQA")+ "' AND "
if !Empty(mv_par01)
	cQuery += "VQA.VQA_CODVEN ='"+ mv_par01+ "' AND "
Endif
if !Empty(mv_par02)
	cQuery += "VQA.VQA_REGIAO ='"+ mv_par02+ "' AND "
Endif
if !Empty(mv_par03)
	cQuery += "VQA.VQA_TIPVEI ='"+ mv_par03+ "' AND "
Endif
cQuery += "VQA.D_E_L_E_T_=' ' ORDER BY VQA.VQA_CODVEN,VQA.VQA_REGIAO,VQA.VQA_TIPVEI "

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVQA, .T., .T. )
                            
cVendedor := "Inicio"   
nAtingido := 0
nQtdMt    := 0
nVlrVen   := 0
nTvend    := 0  
nQtdGMt   := 0
nVlrGVen  := 0
nTGvend   := 0
nInicio   := 0 
Do While !( cAliasVQA )->( Eof() )

	cQuery := "SELECT SUM(VQ7_VLRVEN) "
	cQuery += "FROM " + RetSqlName( "VQ7" ) + " VQ7 " + "WHERE " 
	cQuery += "VQ7.VQ7_FILIAL='"+ xFilial("VQ7")+ "' AND "
	cQuery += "VQ7.VQ7_DATVDA >='"+( cAliasVQA )->VQA_DATINI+ "' AND VQ7.VQ7_DATVDA <='"+( cAliasVQA )->VQA_DATFIN+"' AND "
	cQuery += "VQ7.VQ7_CODVEN = '"+( cAliasVQA )->VQA_CODVEN+"' AND VQ7.VQ7_REGIAO = '"+( cAliasVQA )->VQA_REGIAO+"' AND "
	cQuery += "VQ7.D_E_L_E_T_=' ' "
    nTotVen := FM_SQL(cQuery)
    nQtdVen := 0

	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3")+( cAliasVQA )->VQA_CODVEN) 
	dbSelectArea("VCB")
	dbSetOrder(1)
	dbSeek(xFilial("VCB")+( cAliasVQA )->VQA_REGIAO) 
	dbSelectArea("VV8")
	dbSetOrder(1)
	dbSeek(xFilial("VV8")+( cAliasVQA )->VQA_TIPVEI) 
	if cVendedor <> ( cAliasVQA )->VQA_CODVEN 
	    nLin++        
	    if nInicio <> 0           
			@ nLin++ , 01 pSay space(59)+STR0004+" "+transform(nQtdMt ,"99999")+transform(nVlrVen ,"@E 99,999,999.99")+" "+transform(nTvend ,"@E 999,999,999.99")+"   "+transform(((nTvend/nVlrVen)*100)    ,"@E 9999.99")+"%"
			nQtdMt  := 0
		    nVlrVen := 0
		    nTvend  := 0
		    nLin++                   
		Endif    
		@ nLin++ , 01 pSay STR0003+" "+( cAliasVQA )->VQA_CODVEN+" - "+SA3->A3_NOME // Vendedor:
		nLin++
		@ nLin++ , 05 pSay STR0002 // Regiao                     Tipo Ve�culo         Dt.Inicial    Dt.Final   Qtd.Quotas   Valor Meta    Valor Venda   Atingido
	Endif     
    nAtingido := (nTotVen / ( cAliasVQA )->VQA_VLRVEN)*100
	@ nLin++ , 05 pSay ( cAliasVQA )->VQA_REGIAO+" - "+VCB->VCB_DESREG+" "+VV8->VV8_DESCRI+" "+transform(stod(( cAliasVQA )->VQA_DATINI),"@D")+space(2)+transform(stod(( cAliasVQA )->VQA_DATFIN),"@D")+"        "+transform(( cAliasVQA )->VQA_QTDVEN,"99999")+""+transform(( cAliasVQA )->VQA_VLRVEN,"@E 99,999,999.99")+" "+transform(nTotVen,"@E 999,999,999.99")+"   "+transform(nAtingido,"@E 9999.99")+"%"
	//
    nInicio   := 1
	cVendedor := ( cAliasVQA )->VQA_CODVEN	 
	nQtdMt    += ( cAliasVQA )->VQA_QTDVEN
    nVlrVen   += ( cAliasVQA )->VQA_VLRVEN
    nTvend    += nTotVen
	nQtdGMt   += ( cAliasVQA )->VQA_QTDVEN
    nVlrGVen  += ( cAliasVQA )->VQA_VLRVEN
    nTGvend   += nTotVen
	//
   	dbSelectArea(cAliasVQA)
    ( cAliasVQA )->(dbSkip()) 
Enddo
( cAliasVQA )->( dbCloseArea())
nLin++                   
@ nLin++ , 01 pSay space(59)+STR0004+" "+transform(nQtdMt ,"99999")+transform(nVlrVen ,"@E 99,999,999.99")+" "+transform(nTvend ,"@E 999,999,999.99")+"   "+transform(((nTvend/nVlrVen)*100)    ,"@E 9999.99")+"%"
nLin++                   
@ nLin++ , 00 psay Repl("*",132) 
@ nLin++ , 01 pSay space(59)+STR0005+" "+transform(nQtdGMt,"99999")+transform(nVlrGVen,"@E 99,999,999.99")+" "+transform(nTGvend,"@E 999,999,999.99")+"   "+transform(((nTGvend / nVlrGVen)*100),"@E 9999.99")+"%"
@ nLin++ , 00 psay Repl("*",132) 
DbSelectArea("VQA")
Set Printer to
Set device to Screen
MS_FLUSH()
If aReturn[5] == 1
   OurSpool(cNomeRel)
EndIf   
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Fun��o    �VALIDPERG � Autor � Thiago			 � Data �  12/06/12   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descri��o � Verifica a existencia das perguntas criando-as caso seja   艮�
臼�          � necessario (caso nao existam).                             艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function ValidPerg
Local _sAlias := Alias()
Local aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg, Len(SX1->X1_GRUPO) )
aAdd(aRegs,{cPerg,"01",STR0003,"","","mv_ch1","C", 06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""}) 
aAdd(aRegs,{cPerg,"02",STR0006,"","","mv_ch2","C", 03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","VCB",""}) 
aAdd(aRegs,{cPerg,"03",STR0007,"","","mv_ch3","C", 02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","VV8",""}) 
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