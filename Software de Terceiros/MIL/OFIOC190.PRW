// 浜様様様曜様様様様�
// � Versao � 06     �
// 藩様様様擁様様様様�
#Include "OFIOC190.ch"
#Include "protheus.ch"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OFIOC190  �Autor  �Fabio               � Data �  02/01/05   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Consulta pedido de pecLas                                    艮�
臼�          �                                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � AP5                                                        艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOC190(cGruIni,cCodIni,cGruFin,cCodFin,cPedIni,cPedFin,dDatIni,dDatFin)

Local lAutomatico
Private cQrySB1 := "SQLSB1" 
Private cQrySC7 := "SQLSC7" 
Private cPerg := "OC190"+space(15)
                 
lAutomatico := ( cGruIni#NIL .Or. cCodIni#NIL .Or. cGruFin#NIL .Or. cCodFin#NIL .Or. cPedIni#NIL .Or. cPedFin#NIL .Or. dDatIni#NIL .Or. dDatFin#NIL )
                        
DbSelectArea("SX1")
cPerg := left(cPerg,len(X1_GRUPO))

// Aadd(aRegistros,{cPerg,"01","Grupo Inicial      ?","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","", If(ValType(cGruIni)=="U",Space(04),cGruIni)                ,"","","","","","","","","","","","","","","","","","","","","",""})
// Aadd(aRegistros,{cPerg,"02","Codigo Inicial     ?","","","mv_ch2","C",27,0,0,"G","","mv_par02","","","", If(ValType(cCodIni)=="U",Space(27),cCodIni)                ,"","","","","","","","","","","","","","","","","","","","","",""})
// Aadd(aRegistros,{cPerg,"03","Grupo Final        ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","", If(ValType(cGruFin)=="U",Space(04),cGruFin)                ,"","","","","","","","","","","","","","","","","","","","","",""})
// Aadd(aRegistros,{cPerg,"04","Codigo Final       ?","","","mv_ch4","C",27,0,0,"G","","mv_par04","","","", If(ValType(cCodFin)=="U",Space(27),cCodFin)                ,"","","","","","","","","","","","","","","","","","","","","",""})
// Aadd(aRegistros,{cPerg,"05","Pedido Inicial     ?","","","mv_ch5","C",13,0,0,"G","","mv_par05","","","", If(ValType(cPedIni)=="U",Space(13),cPedIni)                ,"","","","","","","","","","","","","","","","","","","","","",""})
// Aadd(aRegistros,{cPerg,"06","Pedido Final       ?","","","mv_ch6","C",13,0,0,"G","","mv_par06","","","", If(ValType(cPedFin)=="U",Space(13),cPedFin)                ,"","","","","","","","","","","","","","","","","","","","","",""})
// Aadd(aRegistros,{cPerg,"07","Dt Inicial         ?","","","mv_ch7","D",08,0,0,"G","","mv_par07","","","", If(ValType(dDatIni)=="U",'  /  /  ',"'"+Dtoc(dDatIni)+"'") ,"","","","","","","","","","","","","","","","","","","","","",""})
// Aadd(aRegistros,{cPerg,"08","Dt Final           ?","","","mv_ch8","D",08,0,0,"G","","mv_par08","","","", If(ValType(dDatFin)=="U",'  /  /  ',"'"+Dtoc(dDatFin)+"'") ,"","","","","","","","","","","","","","","","","","","","","",""})


If !Pergunte(cPerg, !lAutomatico )
	If !lAutomatico
		Return( .T. )	
	EndIf
EndIf

Processa({|| OC190IMP()})

Return .T.

/*/
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � R120IMP  � Autor � Cristina M. Ogura     � Data � 10.11.95 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Chamada do Relatorio                                       咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � MATR120                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
/*/
Static Function OC190IMP()

Private aItemPed := {}

ProcRegua( SB1->(RecCount()) ) 

cQuery := "SELECT SB1.B1_GRUPO,SB1.B1_COD,SB1.B1_CODITE,SB1.B1_DESC,SC7.C7_NUM,SC7.C7_EMISSAO,SC7.C7_QUANT,SC7.C7_QUJE,SC7.C7_RESIDUO,SC7.C7_NUM "
cQuery += "FROM "+RetSQLName("SB1")+" SB1 "
cQuery += "INNER JOIN "+RetSQLName("SBM")+" SBM ON ( SBM.BM_FILIAL='"+xFilial("SBM")+"' AND SBM.BM_GRUPO=SB1.B1_GRUPO AND SBM.D_E_L_E_T_=' ' ) "
cQuery += "INNER JOIN "+RetSQLName("SC7")+" SC7 ON ( SC7.C7_FILIAL='"+xFilial("SC7")+"' AND SC7.C7_PRODUTO=SB1.B1_COD AND SC7.D_E_L_E_T_=' ' ) "
cQuery += "LEFT JOIN "+RetSQLName("VEI")+" VEI ON ( VEI.VEI_FILIAL='"+xFilial("VEI")+"' AND VEI.VEI_CODMAR=SBM.BM_CODMAR AND VEI.VEI_NUM=SC7.C7_NUM AND VEI.D_E_L_E_T_=' ' ) "
cQuery += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "      
if !Empty(mv_par01) .or. !Empty(mv_par02) .or. !Empty(mv_par03) .or. !Empty(mv_par04) 
	cQuery += " SB1.B1_GRUPO >= '"+mv_par01+"' AND SB1.B1_CODITE >= '"+mv_par02+"' AND SB1.B1_GRUPO <= '"+mv_par03+"' AND SB1.B1_CODITE <= '"+mv_par04+"' AND "
Endif
if !Empty(mv_par07) 
	cQuery += "SC7.C7_EMISSAO >= '"+dtos(mv_par07)+"' AND "
Endif
if !Empty(mv_par08) 
    cQuery += "SC7.C7_EMISSAO <= '"+dtos(mv_par08)+"' AND "
Endif 
cQuery += "( SC7.C7_QUANT-SC7.C7_QUJE > 0 ) AND SC7.C7_RESIDUO=' ' AND "
cQuery += "SB1.D_E_L_E_T_=' '"                                             
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQrySB1, .F., .T. ) 
//
while !(cQrySB1)->(eof())

   IncProc(OemtoAnsi(STR0011))   
	
	//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
	//� Consiste este item. POR PEDIDO                               �
	//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
	If ( (!Empty(mv_par05).And.(cQrySB1)->C7_NUM < mv_par05 ) .Or. (!Empty(mv_par06).And.(cQrySB1)->C7_NUM > mv_par06) )
		DbSelectArea(cQrySB1)
		(cQrySB1)->(dbSkip())
		Loop
	Endif

	//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
	//� Consiste este item. POR EMISSAO                              �
	//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
	If ( Len(aItemPed) == 0 .Or. Ascan(aItemPed,{ |x| x[1]+x[2] == (cQrySB1)->B1_GRUPO+(cQrySB1)->B1_CODITE }) == 0 )
		Aadd(aItemPed, { (cQrySB1)->B1_GRUPO,(cQrySB1)->B1_CODITE,(cQrySB1)->B1_DESC, 0 , {} } )
	EndIf
	        
	Aadd(aItemPed[Len(aItemPed),5], { (cQrySB1)->C7_NUM , stod((cQrySB1)->C7_EMISSAO) , (cQrySB1)->C7_QUANT , (cQrySB1)->C7_QUJE , ((cQrySB1)->C7_QUANT-(cQrySB1)->C7_QUJE) } )
		
	aItemPed[Len(aItemPed),4] += ((cQrySB1)->C7_QUANT-(cQrySB1)->C7_QUJE)		
	
	DbSelectArea(cQrySB1)
	(cQrySB1)->(DbSkip())
EndDo
( cQrySB1 )->( DbCloseArea() )

If Len(aItemPed) # 0

	DEFINE MSDIALOG oDlgPedido FROM 001,000 TO 023,060 TITLE STR0001 OF oMainWnd
	
	@ 001,003 LISTBOX oListPeca FIELDS HEADER OemToAnsi(STR0002),;
	                                          OemToAnsi(STR0003),;
	                                          OemToAnsi(STR0004),;
	                                          OemToAnsi(STR0005);
	    COLSIZES 30,70,70,50;
	    SIZE 232,072 OF oDlgPedido PIXEL ON CHANGE FS_MUDA190()
	
	    oListPeca:SetArray(aItemPed)
	    oListPeca:bLine := { || {  aItemPed[oListPeca:nAt,1] ,;
		                             aItemPed[oListPeca:nAt,2] ,;
		                             aItemPed[oListPeca:nAt,3] ,;
		                             Transform(aItemPed[oListPeca:nAt,4],"99999999999") }}
	
	@ 075,003 LISTBOX oListPedido FIELDS HEADER OemToAnsi(STR0006),;
		                                         OemToAnsi(STR0007),;
		                                         OemToAnsi(STR0008),;
		                                         OemToAnsi(STR0009),;
		                                         OemToAnsi(STR0010);
	    COLSIZES 30,30,50,50,50;
	    SIZE 232,072 OF oDlgPedido PIXEL
	
	    oListPedido:SetArray(aItemPed[oListPeca:nAt,5])
	    oListPedido:bLine := { || {  aItemPed[oListPeca:nAt,5,oListPedido:nAt,1] ,;
			                             Transform(aItemPed[oListPeca:nAt,5,oListPedido:nAt,2],"@D") ,;
			                             Transform(aItemPed[oListPeca:nAt,5,oListPedido:nAt,3],"99999999999") ,;
			                             Transform(aItemPed[oListPeca:nAt,5,oListPedido:nAt,4],"99999999999") ,;
			                             Transform(aItemPed[oListPeca:nAt,5,oListPedido:nAt,5],"99999999999") }}
	
	DEFINE SBUTTON FROM 150,200 TYPE 2 ACTION oDlgPedido:End() ENABLE OF oDlgPedido
	
	ACTIVATE MSDIALOG oDlgPedido CENTER
Else

	MsgInfo("Nao existe pedido pendente para o item consultado!","Atencao")      

EndIf

Return


Function FS_MUDA190()
      
oListPedido:SetArray(aItemPed[oListPeca:nAt,5])
oListPedido:bLine := { || {  aItemPed[oListPeca:nAt,5,oListPedido:nAt,1] ,;
                             Transform(aItemPed[oListPeca:nAt,5,oListPedido:nAt,2],"@D") ,;
                             Transform(aItemPed[oListPeca:nAt,5,oListPedido:nAt,3],"99999999999") ,;
                             Transform(aItemPed[oListPeca:nAt,5,oListPedido:nAt,4],"99999999999") ,;
                             Transform(aItemPed[oListPeca:nAt,5,oListPedido:nAt,5],"99999999999") }}

oListPedido:SetFocus()
oListPeca:SetFocus()

Return
