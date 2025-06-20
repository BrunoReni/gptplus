#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TMSA146.CH" 

/*/{Protheus.doc} T146AltVei()
Fun��o para Alterar o veiculo da Programa��o
@author  	Katia
@version 	12.1.35
@since 		17/11/2021
@return 	
---*/
Function T146AltVei()
Local oDlg
Local nOpca  := 0
Local lRet   := .T.
Local aArea  := GetArea()
Local cMotorista := Criavar("DA4_COD",.F.) 
Local cNomeMot   := Criavar("DA4_NOME",.F.) 
Local cCodVei    := Criavar("DA3_COD",.F.)  
Local cDescVei   := Criavar("DA3_DESC",.F.)
Local cPlaca     := Criavar("DA3_PLACA",.F.)
Local cCodRbq1   := Criavar("DA3_COD",.F.)  
Local cDescRb1   := Criavar("DA3_DESC",.F.)  
Local cPlaca1    := Criavar("DA3_PLACA",.F.)  
Local cCodRbq2   := Criavar("DA3_COD",.F.)  
Local cDescRb2   := Criavar("DA3_DESC",.F.)  
Local cPlaca2    := Criavar("DA3_PLACA",.F.)  
Local cCodRbq3   := Criavar("DA3_COD",.F.)  
Local cDescRb3   := Criavar("DA3_DESC",.F.)
Local cPlaca3    := Criavar("DA3_PLACA",.F.)

lRet:= T146VldAlt( @cMotorista, @cCodVei, @cDescVei, @cPlaca, @cCodRbq1, @cDescRb1, @cPlaca1, @cCodRbq2, @cDescRb2, @cPlaca2, @cCodRbq3, @cDescRb3, @cPlaca3, @cNomeMot )

If lRet
    cNrProg   := DF8->DF8_NUMPRG
    cSeqProg  := DF8->DF8_SEQPRG  
    
	DEFINE MSDIALOG oDlg Title STR0253 From 180,001 to 620,720 Pixel //Altera��o do Ve�culo

    @ 037,010 TO 70,350 OF oDlg PIXEL LABEL STR0001  //Programa��o de Carregamento
	@ 050,015 Say  RetTitle('DF8_NUMPRG') Size 50,7 OF oDlg   Pixel //"Nro Prg::"
	@ 048,055 MsGet cNrProg Picture "@!" When .F. Size 25,10 OF oDlg   Pixel
    @ 050,120 Say RetTitle('DF8_SEQPRG')  Size 30,7 OF oDlg   Pixel //"Seq Prg::"
	@ 048,150 MsGet cSeqProg Picture "@!" When .F. Size 25,10 of oDlg   Pixel

    //---  Veiculo
    @ 080,010 TO 198,350 OF oDlg PIXEL LABEL STR0027 //Ve�culos
	@ 098,015 Say RetTitle('DA3_COD')  Size 30,10 OF oDlg  Pixel //"Veiculo"
	@ 096,060 MSGet cCodVei Valid T146VldVei( cCodVei, .F., , @cDescVei, @cPlaca ) Picture "@!" F3 "DA3" Size 30,10 OF oDlg  Pixel
    @ 096,105 MSGet cDescVei When .F. Size 148,10 OF oDlg  Pixel
    @ 098,270 Say RetTitle('DA3_PLACA')  Size 30,10 OF oDlg  Pixel //"Placa"
	@ 096,295 MSGet cPlaca When .F. Size 35,10 OF oDlg  Pixel

    //--- Reboques
	@ 115,015 Say RetTitle('DTR_CODRB1')  Size 40,10 OF oDlg  Pixel //"Reboque 1"
	@ 112,060 MSGet cCodRbq1 Valid T146VldVei( cCodRbq1, .T., '1', @cDescRb1, @cPlaca1 ) Picture "@!" F3 "DA3" Size 30,10  OF oDlg  Pixel
	@ 112,105 MSGet cDescRb1 When .F. Size 148,10 OF oDlg  Pixel
	@ 115,270 Say RetTitle('DA3_PLACA') Size 30,10 OF oDlg  Pixel //"Placa 1"
	@ 112,295 MSGet cPlaca1 When .F. Size 35,10 OF oDlg  Pixel

	@ 132,015 Say RetTitle('DTR_CODRB2')  Size 40,10 OF oDlg  Pixel //"Reboque 2"
	@ 130,060 MSGet cCodRbq2 Valid T146VldVei( cCodRbq2, .T., '2', @cDescRb2, @cPlaca2 ) Picture "@!" F3 "DA3" Size 30,10  OF oDlg  Pixel
	@ 130,105 MSGet cDescRb2 When .F. Size 148,10 OF oDlg  Pixel
	@ 132,270 Say RetTitle('DA3_PLACA')Size 30,10 OF oDlg  Pixel //"Placa 2"
	@ 130,295 MSGet cPlaca2 When .F. Size 35,10 OF oDlg  Pixel

	@ 149,015 Say RetTitle('DTR_CODRB3')  Size 40,10 OF oDlg  Pixel //"Reboque 3"
	@ 147,060 MSGet cCodRbq3 Valid T146VldVei( cCodRbq3, .T., '3', @cDescRb3, @cPlaca3 ) Picture "@!" F3 "DA3" Size 30,10 OF oDlg  Pixel
	@ 147,105 MSGet cDescRb3 When .F. Size 148,10 OF oDlg  Pixel

	@ 149,270 Say RetTitle('DA3_PLACA') Size 30,10 OF oDlg  Pixel //"Placa 3"
	@ 147,295 MSGet cPlaca3 When .F. Size 35,10 OF oDlg  Pixel

	@ 175,015 Say RetTitle('DUP_CODMOT')   Size 40,10 OF oDlg  Pixel //"Motorista"
	@ 173,060 MSGet cMotorista Picture "@!" Valid ( T146VldMot(cMotorista,@cNomeMot) ) F3 "DA4" Size 30,10 OF oDlg  Pixel
	@ 173,105 MsGet cNomeMot When .F. Size 148,10 OF oDlg  Pixel

    ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||Iif( T146Valid( cCodVei, cMotorista, cCodRbq1, cCodRbq2, cCodRbq3 ) , (nOpca := 1,oDlg:End()), nOpca :=0 )},{||nOpca:=0,oDlg:End()})

	If nOpca == 1
        If MsgYesNo( STR0255 ) //-- Confirma a altera��o dos dados do Veiculo/Motorista? // Sim   // N�o
            T146GrvVei( cCodVei, cCodRbq1, cCodRbq2, cCodRbq3, cMotorista )
        EndIf
    EndIf

EndIf	

LimpaVar( @cMotorista, @cNomeMot, @cCodVei, @cDescVei, @cPlaca, @cCodRbq1, @cDescRb1, @cPlaca1, @cCodRbq2, @cDescRb2, @cPlaca2, @cCodRbq3, @cDescRb3, @cPlaca3 )
RestArea(aArea)
FwFreeArray(aArea)
Return lRet

/*/{Protheus.doc} T146VldAlt()
Valida a altera��o dos dados do Veiculo e Motorista
da Programa��o de Carregamento
@author  	Katia
@version 	12.1.35
@since 		18/11/2021
@return 	
---*/
Static Function T146VldAlt( cMoto, cCVei, cDescVei, cPlaca, cCodRbq1, cDescRb1, cPlaca1, cCodRbq2, cDescRb2, cPlaca2, cCodRbq3, cDescRb3, cPlaca3, cNomeMot )
Local lRet  := .T.
Local cIdRot:= ""

If DF8->DF8_STATUS <>  StrZero(1,Len(DF8->DF8_STATUS))  //Em Aberto
    Help('',1,'TMSA14627') // "Manuten��es permitidas apenas para programa��o com status - Em aberto"
	lRet:= .F.
EndIf	

If lRet
	//--- Verifica se existem Doctos da Programa��o pendente para Roteiriza��o
	cIdRot:= T146VldTPR('DF8',DF8->DF8_FILORI,DF8->DF8_NUMPRG,DF8->DF8_SEQPRG,"1")  //1-Pendente,2-Rejeitado,3-Processado
	If !Empty(cIdRot)
		Help('',1,'TMSA14651',, STR0248 + ' ' + cIdRot,5,11) //N�o � permitido a altera��o da Programa��o de Carregamento com Roteiriza��o (TPR) pendente.
		lRet:= .F.
	EndIf
EndIf

If lRet
    //--- Carrega Dados do Veiculo
    T146PosDDZ( @cCVei, @cDescVei, @cPlaca, @cCodRbq1, @cDescRb1, @cPlaca1, @cCodRbq2, @cDescRb2, @cPlaca2, @cCodRbq3, @cDescRb3, @cPlaca3 )
    //--- Carrega Dados do Motorista
    T146PosDLS( @cMoto, @cNomeMot )
    If Empty(cMoto) .Or. Empty(cCVei)
        Help('',1,'TMSA14656')  //Programa��o de Carregamento sem os dados do Ve�culo e Motorista.
        lRet:= .F.
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} T146VldMot()
Valida Motorista da Programa��o
@author  	Katia
@version 	12.1.35
@since 		17/11/2021
@return 	
---*/
Static Function T146VldMot(cMotorista,cNomeMot)
Local lRet:= .T.

If !Empty(cMotorista)
	DA4->(DbSetOrder(1)) //DA4_FILIAL+DA4_COD						 								
	If DA4->(DbSeek(xFilial("DA4") + cMotorista)) 
    	If DA4->DA4_BLQMOT == StrZero(1,Len(DA4->DA4_BLQMOT))
            Help('',1,'TMSA14657') //"O Motorista esta bloqueado"				
            lRet:= .F.
		Else
            cNomeMot:= DA4->DA4_NOME
        EndIf
    Else
        Help('',1,'REGNOIS')
    EndIf
Else
    cNomeMot:= Criavar("DA4_NOME",.F.) 
EndIf

Return lRet

/*/{Protheus.doc} T146VldVei()
Valida Veiculo da Programa��o
@author  	Katia
@version 	12.1.35
@since 		17/11/2021
@return 	
---*/
Static Function T146VldVei(cVeiculo, lReboque, cReboque, cDescRb, cPlaca )
Local lRet    := .T.
Local cCatVei := ""

Default lReboque:= .F.
Default cReboque:= ""
Default cVeiculo:= ""
Default cDescRb := ""
Default cPlaca  := ""

cDescRb:= Criavar("DA3_DESC",.F.)
cPlaca  := Criavar("DA3_PLACA",.F.)

If !Empty(cVeiculo)
    lRet:= T146PosDA3(cVeiculo)
    If lRet
        cCatVei:= T146PosDUT(DA3->DA3_TIPVEI)
        lRet:= !Empty(cCatVei)
        If lRet
            If !lReboque
                If cCatVei == "3"
                    Help('',1,'TMSA14658')  //-- Nao poderao ser Informados Veiculos com categoria igual a "3" (Carreta)
                    lRet:= .F.
                EndIf
            Else
                If cCatVei == StrZero(1, Len(DUT->DUT_CATVEI)) .Or. cCatVei == StrZero(5, Len(DUT->DUT_CATVEI))
                    Help('',1,'TMSA14659')  //-- N�o � permitida a escolha de um Semi Reboque, quando o Cod.Ve�culo n�o for Cavalo Mec�nico.
                    lRet := .F.
                EndIf	
            EndIf		

            If lRet		
                If DA3->DA3_ATIVO != "1"
                    Help('',1,'TMSA14660')  //-- Este veiculo nao esta ativo (DA3)	
                    lRet := .F.
                EndIf
                    
                If lRet .And. !Empty(DA3->DA3_CODFOR+DA3->DA3_LOJFOR)
                    SA2->(DbSetOrder(1))								
                    If SA2->(MsSeek(xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR))
                        If SA2->A2_MSBLQL == "1"
                            Help('',1,'TMSA14661')  //Propriet�rio do ve�culo esta bloqueado, Verificar o campo Bloqueado no Cadastro de Fornecedor
                            lRet := .F.
                        EndIf	
                    EndIf				
                EndIf			
            EndIf
        EndIf
    EndIf

    If lRet
        cDescRb:= DA3->DA3_DESC
        cPlaca  := DA3->DA3_PLACA
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} T146Valid()
Valida dados digitados
@author  	Katia
@version 	12.1.35
@since 		17/11/2021
@return 
---*/
Static Function T146Valid( cCodVei, cMotorista, cCodRbq1, cCodRbq2, cCodRbq3 )
Local lRet:= .T.
Local cTipVei:= ""
Local cCatVei:= ""

If Empty(cCodVei) .Or. Empty(cMotorista)
    Help('',1,'TMSA14662')   //Informe o Veiculo e Motorista
    lRet:= .F.
Else
    cTipVei:= Posicione("DA3",1,xFilial("DA3")+cCodVei,"DA3_TIPVEI")
    
    cCatVei:= T146PosDUT(cTipVei)
    If cCatVei == "2" .And. Empty(cCodRbq1) .And. Empty(cCodRbq2) .And. Empty(cCodRbq3)
        Help('',1,'TMSA14663')   //Informe o Reboque
        lRet:= .F.
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} T146PosDDZ()
Retorna dados do Veiculo da Programa��o
@author  	Katia
@version 	12.1.35
@since 		17/11/2021
@return 	
---*/
Static Function T146PosDDZ( cCodVei, cDescVei, cPlaca, cCodRbq1, cDescRb1, cPlaca1, cCodRbq2, cDescRb2, cPlaca2, cCodRbq3, cDescRb3, cPlaca3 )
Local lRet     := .F.
Local cQuery   := ""
Local cAliasQry:= GetNextAlias()

cQuery := " SELECT DDZ_CODVEI, DA3.DA3_DESC, DA3.DA3_PLACA, "
cQuery += " DDZ_CODRB1, DA31.DA3_DESC DA31_DESC, DA31.DA3_PLACA DA31_PLACA, "
cQuery += " DDZ_CODRB2, DA32.DA3_DESC DA32_DESC, DA32.DA3_PLACA DA32_PLACA, "
cQuery += " DDZ_CODRB3, DA33.DA3_DESC DA33_DESC, DA33.DA3_PLACA DA33_PLACA FROM "
cQuery +=  RetSqlName("DDZ") + " DDZ "

cQuery += " INNER JOIN " + RetSqlName("DA3") + " DA3 "
cQuery += " ON DA3.DA3_FILIAL = '" + xFilial("DA3") + "' "
cQuery += " AND DA3.DA3_COD = DDZ_CODVEI "
cQuery += " AND DA3.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN " + RetSqlName("DA3") + " DA31 "
cQuery += " ON DA31.DA3_FILIAL = '" + xFilial("DA3") + "' "
cQuery += " AND DA31.DA3_COD = DDZ_CODRB1 "
cQuery += " AND DA31.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN " + RetSqlName("DA3") + " DA32 "
cQuery += " ON DA32.DA3_FILIAL = '" + xFilial("DA3") + "' "
cQuery += " AND DA32.DA3_COD = DDZ_CODRB2 "
cQuery += " AND DA32.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN " + RetSqlName("DA3") + " DA33 "
cQuery += " ON DA33.DA3_FILIAL = '" + xFilial("DA3") + "' "
cQuery += " AND DA33.DA3_COD = DDZ_CODRB3 "
cQuery += " AND DA33.D_E_L_E_T_ = ' '"

cQuery += " WHERE DDZ.DDZ_FILIAL = '" + xFilial("DDZ") + "' "
cQuery += " AND DDZ.DDZ_FILORI = '" + DF8->DF8_FILORI + "' "
cQuery += " AND DDZ.DDZ_NUMPRG = '" + DF8->DF8_NUMPRG + "' "
cQuery += " AND DDZ.DDZ_SEQPRG = '" + DF8->DF8_SEQPRG + "' "
cQuery += " AND DDZ.D_E_L_E_T_ = ' '"
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
If (cAliasQry)->(!Eof())
	cCodVei   := (cAliasQry)->DDZ_CODVEI 
    cDescVei  := (cAliasQry)->DA3_DESC
    cPlaca    := (cAliasQry)->DA3_PLACA
    
    cCodRbq1  := (cAliasQry)->DDZ_CODRB1 
    cDescRb1  := (cAliasQry)->DA31_DESC
    cPlaca1   := (cAliasQry)->DA31_PLACA

    cCodRbq2  := (cAliasQry)->DDZ_CODRB2 
    cDescRb2  := (cAliasQry)->DA32_DESC
    cPlaca2   := (cAliasQry)->DA32_PLACA

    cCodRbq3  := (cAliasQry)->DDZ_CODRB3 
    cDescRb3  := (cAliasQry)->DA33_DESC
    cPlaca3   := (cAliasQry)->DA33_PLACA
EndIf

(cAliasQry)->(dbCloseArea())
Return lRet    


/*/{Protheus.doc} T146PosDLS()
Retorna dados do Motorista da Programa��o
@author  	Katia
@version 	12.1.35
@since 		17/11/2021
@return 	
---*/
Static Function T146PosDLS( cMotorista, cNomeMot )
Local cQuery   := ""
Local cAliasQry:= GetNextAlias()

cQuery := " SELECT DLS_CODMOT, DA4_NOME FROM "
cQuery +=  RetSqlName("DLS") + " DLS "

cQuery += " INNER JOIN " + RetSqlName("DA4") + " DA4 "
cQuery += " ON DA4.DA4_FILIAL = '" + xFilial("DA4") + "' "
cQuery += " AND DA4.DA4_COD = DLS_CODMOT "
cQuery += " AND DA4.D_E_L_E_T_ = ' '"

cQuery += " WHERE DLS.DLS_FILIAL = '" + xFilial("DLS") + "' "
cQuery += " AND DLS.DLS_FILORI = '" + DF8->DF8_FILORI + "' "
cQuery += " AND DLS.DLS_NUMPRG = '" + DF8->DF8_NUMPRG + "' "
cQuery += " AND DLS.DLS_ITEDF8 = '" + DF8->DF8_SEQPRG + "' "
cQuery += " AND DLS.D_E_L_E_T_ = ' '"
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
If (cAliasQry)->(!Eof())
	cMotorista  := (cAliasQry)->DLS_CODMOT
    cNomeMot    := (cAliasQry)->DA4_NOME
EndIf

(cAliasQry)->(dbCloseArea())
Return Nil

/*/{Protheus.doc} T146PosDA3()
Posiciona registro DA3
@author  	Katia
@version 	12.1.35
@since 		17/11/2021
@return 	
---*/
Static Function T146PosDA3(cVeiculo)
Local lRet:= .F.
	DA3->(DbSetOrder(1))
	If DA3->(MsSeek(xFilial('DA3')+ cVeiculo ))
        lRet:= .T.
    Else
        Help('',1,'REGNOIS')
        Criavar("DA3_DESC",.F.)
        Criavar("DA3_PLACA",.F.)
    EndIf
Return lRet    

/*/{Protheus.doc} T146PosDUT()
Posiciona Dados do Tipo de Veiculo
@author  	Katia
@version 	12.1.35
@since 		17/11/2021
@return 	
---*/
Static Function T146PosDUT(cTipVei)
Local cRet:= ""
    DUT->(dbSetOrder(1))
    If DUT->(MsSeek(xFilial("DUT") + cTipVei) )
       	cRet:=  DUT->DUT_CATVEI
    EndIf   

    If Empty(cRet)
        Help('',1,'TMSA14664') //-- Nao foi encontrado Categoria de Veiculo para este Tipo de Veiculo
    EndIf   
Return cRet    

/*/{Protheus.doc} T146GrvVei()
Fun��o para gravar dados do Veiculo e
Motorista da Programa��o 
@author  	Katia
@version 	12.1.35
@since 		17/11/2021
@return 	
---*/
Static Function T146GrvVei( cCodVei, cCodRbq1, cCodRbq2, cCodRbq3, cMotorista )

DbSelectArea("DDZ")
DDZ->(dbSetOrder(1)) 
If DDZ->(dbSeek(xFilial("DDZ")+DF8->DF8_FILORI+DF8->DF8_NUMPRG+DF8->DF8_SEQPRG)) 
	RecLock("DDZ",.F.)
	DDZ->DDZ_CODVEI:= cCodVei
	DDZ->DDZ_CODRB1:= cCodRbq1 
	DDZ->DDZ_CODRB2:= cCodRbq2
	DDZ->DDZ_CODRB3:= cCodRbq3
	DDZ->(MsUnLock())
EndIf

DbSelectArea("DLS")
DLS->(DbSetorder(1)) 
If DLS->(MsSeek(xFilial("DLS") + DF8->DF8_FILORI+DF8->DF8_NUMPRG+DF8->DF8_SEQPRG))											
	RecLock("DLS",.F.)	
    DLS->DLS_CODVEI:= cCodVei
    DLS->DLS_CODMOT:= cMotorista
    DLS->DLS_TIPMOT:= Posicione("DA4",1,xFilial("DA4")+DLS->DLS_CODMOT,"DA4_TIPMOT")
    DLS->(MsUnLock())	
EndIf

Return .T.

/*/{Protheus.doc} LimpaVar()
Limpa variaveis
@author  	Katia
@version 	12.1.35
@since 		17/11/2021
@return 	
---*/
Static Function LimpaVar( cMotorista, cNomeMot, cCodVei, cDescVei, cPlaca, cCodRbq1, cDescRb1, cPlaca1, cCodRbq2, cDescRb2, cPlaca2, cCodRbq3, cDescRb3, cPlaca3 )
    cMotorista := Criavar("DA4_COD",.F.) 
    cNomeMot   := Criavar("DA4_NOME",.F.) 
    cCodVei    := Criavar("DA3_COD",.F.)  
    cDescVei   := Criavar("DA3_DESC",.F.)
    cPlaca     := Criavar("DA3_PLACA",.F.)
    cCodRbq1   := Criavar("DA3_COD",.F.)  
    cDescRb1   := Criavar("DA3_DESC",.F.)  
    cPlaca1    := Criavar("DA3_PLACA",.F.)  
    cCodRbq2   := Criavar("DA3_COD",.F.)  
    cDescRb2   := Criavar("DA3_DESC",.F.)  
    cPlaca2    := Criavar("DA3_PLACA",.F.)  
    cCodRbq3   := Criavar("DA3_COD",.F.)  
    cDescRb3   := Criavar("DA3_DESC",.F.)  
    cPlaca3    := Criavar("DA3_PLACA",.F.)  
Return
