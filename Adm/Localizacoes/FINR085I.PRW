#INCLUDE "protheus.ch"  
#INCLUDE "FINR085I.ch"  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINR85I  �Autor  � ROBERTO R.MEZZALIRA � Data �  30/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Relatorio de comprovante reten��o de IGV                   ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FINR085I(cCert,cSerie,lDireto)
Local cPerg := "FIN85I"
Default lDireto := .F.

If !lDireto                                                                  

	If !Pergunte(cPerg,.T.)
		Return nil
	EndIf
	
EndIF

Print85I(cCert,cSerie,lDireto)

return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  �PRINT85I  �Autor  �ROBERTO ROGERIO MEZZALIRA� Data �  11/30/09   ���
������������������������������������������������������������������������������͹��
���Desc.     �                                                                 ���
���          �                                                                 ���
������������������������������������������������������������������������������͹��
���Uso       � AP                                                              ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function Print85I(cCert,cSerie,lDireto)

Local aNfs	:= {}
Local cChave
Local cTitulo	:= STR0002 //"COMPROVANTE DE RETENCAO"
Local oPrint 
oPrint	:= TMSPrinter():New( cTitulo )
//oPrint:SetPortrait() //Retrato
oPrint:SetLandscape() //Paisagem

If !lDireto   
	cCert  := MV_PAR01
	cSerie := MV_PAR02 
EndIf	

DbSelectArea("SFE")
DbSetOrder(9)      
dbgotop()
cSerie := PadR(cSerie,TamSX3("FE_SERIEC")[1])
cCert  := PadR(cCert,TamSX3("FE_NROCERT")[1])

DbSeek(xFilial("SFE")+cCert+"I")
cForn     :=SFE->FE_FORNECE
cLoja     :=SFE->FE_LOJA
dEmisCert :=SFE->FE_EMISSAO 

DbSelectArea("SA2")
DbSetOrder(1)
DbSeek(xFilial("SA2") + SFE->FE_FORNECE + SFE->FE_LOJA)  
cNome:=SA2->A2_NREDUZ
cRUCCli:=SA2->A2_CGC // Numero do RUC do fornecedor
cChave:=xFilial("SFE")+cCert+cSerie+cForn+cLoja+"I" 

DbSelectArea("SFE")
Do While cChave==SFE->FE_FILIAL+SFE->FE_NROCERT+SFE->FE_SERIEC+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_TIPO .And. !SFE->(Eof())
	
	dbSelectArea("SE2")
	dbSetOrder(6) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO  
	If dbSeek(xFilial("SE2")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_SERIE+SFE->FE_NFISCAL+SFE->FE_PARCELA)
		dEmissao:=SE2->E2_EMISSAO
	Else
		dEmissao:=SFE->FE_EMISSAO	
	EndIf	

	dbSelectArea("CCM")
	dbSetOrder(1)
	dbSeek(xFilial("CCM")+SFE->FE_ESPECIE)
	
	dbSelectArea("CCL")
	dbSetOrder(1)
	dbSeek(xFilial("CCL")+CCM->CCM_CODGOV)	
	cEspecie:= CCL->CCL_CODGOV
			
	DbSelectArea("SFE")
	aAdd( aNfs , {SFE->FE_SERIE,SFE->FE_NFISCAL,SFE->FE_VALBASE,SFE->FE_VALIMP,SFE->FE_ALIQ,SFE->FE_SERIEC,dEmissao,cEspecie})

	SFE->(DbSkip())

EndDo

PrintPag( oPrint , aNfs ,cCert,cSerie )
oPrint:Preview()


Return

Static Function PrintPag( oPrint , aNfs ,cCert,cSerie )

Local cStartPath:= GetSrvProfString("StartPath","")
Local cBmp 		:= cStartPath + "lgrl.bmp" //Logo do municipio de Zarate
Local oFont1	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)// Fonte o Titulo Negrito
Local oFont2	:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)// Fonte do Sub-Titulo
Local oFont3	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont4	:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
Local nI,nX  
Local nTotPer:= 0

For nX:=1 to 3
	nTotPer:=0
	oPrint:StartPage()
	oPrint:Box(0200,0100,1850,2600)  // Margem principal
	oPrint:Box(0250,1550,0710,2500)  // Retangulo do RUC
	oPrint:Say(0280,1600,Alltrim(STR0001) + "   " + SM0->M0_CGC,oFont1) //"R.U.C. nO:"
	oPrint:Say(0380,1600,STR0002,oFont1) //"COMPROVANTE DE RETENCAO" 
	oPrint:Say(0590,1800,cSerie+" - "+cCert,oFont1) 	   //" - "
	
	oPrint:Box(0250,0300,0710,1000)  // Logo	
	oPrint:SayBitmap(0280, 0310,cBmp, 350, 350) //Logo
	oPrint:Say( 0800,0200,STR0003,oFont2) // "Fornecedor:"
	oPrint:Say( 0800,0500,cNome,oFont2) // FORNECEDOR
	oPrint:Say( 0855,0200,STR0004,oFont2) // "RUC:"
	oPrint:Say( 0855,0500,cRUCCli,oFont2) // Ruc Do cliente
	oPrint:Say( 0910,0200,STR0005,oFont2) // Emiss�o //"Emiss�o:"
	oPrint:Say( 0910,0500,Dtoc(dEmisCert),oFont2) // Emiss�o do comprovante
	
	
	oPrint:box(0985,0200,1085,1170) 							
	oPrint:Say(0989,0285,STR0006,oFont3)  //"Comprovante de Pagamento de retencao"
	
	oPrint:box(1085,0200,1160,0350) // Caixa Tipo Doc	 
	oPrint:Say(1105,0205,AllTrim(STR0008),oFont3) // Tipo
	
	oPrint:box(1085,0350,1160,0800) // Caixa numero e serie  
  	oPrint:Say(1105,0495,STR0009,oFont3) //"Serie NF"
	
	oPrint:box(1085,0800,1160,1170)  // Caixa emissao
	oPrint:Say(1105,0865,STR0010,oFont3) // emissao		
	
	oPrint:box(0985,1170,1160,1502)      //Caixa base
 	oPrint:Say(1030,1225,STR0013,oFont3) // base //
 	oPrint:Say(1090,1245,STR0019,oFont3) // base //
 	
	oPrint:box(0985,1502,1160,1802)            //Caixa aliquota  
 	oPrint:Say(1030,1520,STR0013,oFont3) //Preco
 	oPrint:Say(1090,1520,STR0012,oFont3) // aliquota
	
	oPrint:box(0985,1802,1160,2102)    //Caixa retencao
 	oPrint:Say(1030,1845,STR0013,oFont3) // Valor
 	oPrint:Say(1090,1830,STR0014,oFont3) // retencao
	
	oPrint:box(0985,2102,1160,2498)    // Caixa Valor total cobrado
 	oPrint:Say(1030,2165,STR0013,oFont3) // Valor total cobrado
 	oPrint:Say(1090,2180,STR0015,oFont3) // Valor total cobrado
	 		
	If nX==1
		oPrint:Say( 1750,2300,STR0003,oFont4) 	 //"CLIENTE"
	Elseif nX==2
		oPrint:Say( 1750,2300,STR0016,oFont4)  //"EMISSOR"
	Else
		oPrint:Say( 1750,2300,STR0017,oFont4) //"SUNAT"
	EndIf		
		
	nLin:=1160
	For nI:= 1 To Len(aNFs)
	
		oPrint:box(nLin-2,200,nLin+69,350) // Tipo Doc						
	 	oPrint:box(nLin-2,350,nLin+69,800) // numero e serie
	 	oPrint:box(nLin-2,800,nLin+69,1170)  // emissao
	 	oPrint:box(nLin-2,1170,nLin+69,1502)  //base
	 	oPrint:box(nLin-2,1502,nLin+69,1802) //aliq
	 	oPrint:box(nLin-2,1802,nLin+69,2102)  //percepcao
	 	oPrint:box(nLin-2,2102,nLin+69,2498)   // valor pago
	 		

		oPrint:Say( nLin+10,210,aNFs[nI,8],oFont3) // Tipo Doc
		oPrint:Say( nLin+10,400,aNFs[nI,1],oFont3) // Serie
		oPrint:Say( nLin+10,460,aNFs[nI,2],oFont3) // Numero da nota fiscal 
		oPrint:Say( nLin+10,900,Dtoc(aNFs[nI,7]),oFont3) // Data emiss�o NF
		oPrint:Say( nLin+10,1200,Transform(aNFs[nI,3], "@E 999,999,999.99"),oFont3) // valor base
		oPrint:Say( nLin+10,1610,Transform(aNFs[nI,5], "@E 999")+"%",oFont3)	// aliquota
		oPrint:Say( nLin+10,1760,Transform(aNFs[nI,4], "@E 999,999,999.99"),oFont3) // valor da percep��o
		oPrint:Say( nLin+10,2145,Transform((aNFs[nI,3]-aNFs[nI,4]), "@E 999,999,999.99"),oFont3)   // Total recebido
	
	    nLin+=70
		nTotPer+= aNFs[nI,4]
		
	Next
		
		oPrint:box(nLin-2,1170,nLin+80,1802)
	 	oPrint:Say(nLin+15,1185,STR0018,oFont2) //"Total da retencao"
		oPrint:box(nLin-2,1802,nLin+80,2102)
		oPrint:Say( nLin+15,1760,Transform(nTotPer, "@E 999,999,999.99"),oFont2)	//"Valor Total de Percep��o"
	
		oPrint:EndPage()
Next
Return
