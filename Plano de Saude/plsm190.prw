#INCLUDE "PROTHEUS.CH"

#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02"
#DEFINE G_SOL_INTER "03"
#DEFINE G_REEMBOLSO "04"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"
#DEFINE G_ANEX_QUIM "07"
#DEFINE G_ANEX_RADI "08"
#DEFINE G_ANEX_OPME "09"
#DEFINE G_REC_GLOSA "10"
#DEFINE G_PROR_INTE "11"

Static lPLSHAT		:= GetNewPar("MV_PLSHAT","0") == "1"


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM190  
Status do peg
@author  Totvs
@version P12
@since   22.10.2002
/*/
//-------------------------------------------------------------------------------------
Function PLSM190
LOCAL aSays     := {}
LOCAL aButtons  := {}
LOCAL cPerg     := "PLM190"
LOCAL cCadastro := "Processamento dos Status das PEGS"

// Monta texto para janela de processamento
AADD(aSays,"Processamento dos Status das PEGS")

// Monta botoes para janela de processamento
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aadd(aButtons, { 1,.T.,{|| PLSM190Pro(cPerg) } })

// Mudo o status da PEG
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

// Exibe janela de processamento           
FormBatch( cCadastro, aSays, aButtons,, 160 )           

Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM190Pro  
Processamento do status da PEG
@author  Totvs
@version P12
@since   22.10.2002
/*/
//-------------------------------------------------------------------------------------
Function PLSM190Pro(cPerg,lPerg,cCodOpe,cCodLDPDe,cCodLDPAte,cCodPEGDe,cCodPEGAte,cAnoDe,cMesDe,cAnoAte,cMesAte,lJob,lAuto,nRecCor,lChkBaixa, lStTiss)
LOCAL aArea			:= GetArea()
LOCAL aAreaBCI		:= BCI->( GetArea() )
LOCAL aAreaBD5		:= BD5->( GetArea() )
LOCAL cFase			:= ""
LOCAL cSQL      	:= ""
LOCAL cSQL1			:= ""
LOCAL cSQL2			:= ""
LOCAL nQtdTot 		:= 0
LOCAL cStaTiss      := ""
LOCAL lBaixa        := .F.
LOCAL aFase         := {}

DEFAULT lStTiss		:= getNewPar("MV_STATISS",.F.)
DEFAULT lChkBaixa   := .F.
DEFAULT cPerg      	:= space(6)
DEFAULT lPerg      	:= .T.
DEFAULT cCodOpe    	:= PLSINTPAD()
DEFAULT cCodLDPDe	:= space(4)
DEFAULT cCodLDPAte	:= space(4)
DEFAULT cCodPEGDe	:= space(8)
DEFAULT cCodPEGAte	:= space(8)
DEFAULT cAnoDe     	:= space(4)
DEFAULT cMesDe     	:= space(2)
DEFAULT cAnoAte    	:= space(4)
DEFAULT cMesAte    	:= space(2)
DEFAULT lJob       	:= .F.
DEFAULT lAuto      	:= .F.

If Empty(cCodOpe)
	cCodOpe := PLSINTPAD()
EndIf

If lAuto
   
   //devolve o status do peg
   aFase 	:= PLSMDVFA(nRecCor, lChkBaixa)
   cFase 	:= aFase[1]
   lBaixa	:= aFase[2] //quando a fase ? 4 "Faturada" retorna se todas as guias ja est?o pagas ou nao

   // Verifica qual ser? o status TISS do PEG
  cStaTiss :=  PLRETSTISS(cFase,,nRecCor, lBaixa)
   	 	
   //Atualiza peg...                                                     
    BCI->(recLock("BCI",.f.)) 

        BCI->BCI_FASE := cFase

        If lStTiss
            BCI->BCI_STTISS := IF(cStaTiss < "2", "2", cStaTiss) //Em an?lise
        EndIf
    BCI->(MsUnLock())
	if lPLSHAT .and. !empty(BCI->BCI_LOTGUI) .and. BCI->BCI_FASE > '1'
		PLHATBCI(4,BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG)
	endif

//Processo Normal														
else

	//Busca dados dos parametros...                                       
	if  lPerg
	    Pergunte(cPerg,.F.)
	    cCodOpe    := mv_par01
	    cCodLDPDe  := mv_par02
	    cCodLDPAte := mv_par03
	    cCodPEGDe  := mv_par04
	    cCodPEGAte := mv_par05
	    cAnoDe     := mv_par06
	    cMesDe     := mv_par07
	    cAnoAte    := mv_par08
	    cMesAte    := mv_par09
	endIf    

	//Seleciona todos os grupos empresas parametrizados...                
	cSQL1 := "SELECT R_E_C_N_O_ AS REG FROM " + RetSQLName("BCI") + " WHERE "
	
	cSQL2 := "SELECT COUNT(*) AS REGTOT FROM " + RetSQLName("BCI") + " WHERE "
	
	cSQL := "( BCI_FILIAL = '"+xFilial("BCI")+"' ) AND "
	cSQL += "( BCI_CODOPE = '"+cCodOpe+"' ) AND "
	cSQL += "( BCI_CODLDP >= '"+cCodLDPDe+"' AND BCI_CODLDP <= '"+cCodLDPAte+"' ) AND "
	cSQL += "( BCI_CODPEG >= '"+cCodPEGDe+"' AND BCI_CODPEG <= '"+cCodPEGAte+"' ) AND "
	cSQL += "( BCI_ANO+BCI_MES >= '"+cAnoDe+cMesDe+"' AND BCI_ANO+BCI_MES <= '"+cAnoAte+cMesAte+"' ) AND "
	cSql += "( BCI_TIPGUI IN ('01','02','03','05','06','13') ) AND "
	cSQL += "( D_E_L_E_T_ = '' )"
	
	PLSQuery(cSQL2+cSQL,"Trb")
	
	nQtdTot := Trb->REGTOT
	
	Trb->(DbCloseArea())
	
	PLSQuery(cSQL1+cSQL,"Trb")
	
	While ! Trb->(Eof())
		
		//devolve o status do peg
		aFase := PLSMDVFA(Trb->REG, lChkBaixa)
   		cFase := aFase[1]
   		lBaixa := aFase[2] //quando a fase ? 4 "Faturada" retorna se todas as guias ja est?o pagas ou nao

  		// Verifica qual ser? o status TISS do PEG
  		cStaTiss :=  PLRETSTISS(cFase,,nRecCor, lBaixa)

		// Atualiza peg...
		BCI->(RecLock("BCI",.f.)) 
		
		BCI->BCI_FASE := cFase
		
		If lStTiss
			BCI->BCI_STTISS := cStaTiss
		EndIf
		
		BCI->(MsUnLock())
		
		if lPLSHAT .and. !empty(BCI->BCI_LOTGUI) .and. BCI->BCI_FASE > '1'
			PLHATBCI(4,BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG)
		endif
		
	//Acessa proxima peg a ser analisada...                               
	Trb->(dbSkip())
	EndDo
	
	Trb->(DbCloseArea())
	
	If  lPerg
	    If !lJob
	       MsgInfo("Processamento concluido com sucesso.")
	    EndIf
	Endif
	    
EndIf	

//Restaura area
RestArea(aArea)
BCI->( RestArea(aAreaBCI) )
BD5->( RestArea(aAreaBD5) )

return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMDVFA
Retorna qual a menor fase de uma guia, caso n?o achou nada olhar as bloqueadas. 

@author    Lucas Nonato
@version   V12
@since     21/10/2019
/*/
function PLSMDVFA(nRecno, lChkBaixa)
local cFase 	:= "1"
local cQuery 	as char
local cSituac 	as char
local lBaixa	:= .F.
local cSql 		as char
local cAlias 	as char

default lChkBaixa := .F.

BCI->( dbGoTo(nRecno) )

cAlias := PLSRALCTM(BCI->BCI_TIPGUI)

cSql := " SELECT " + cAlias + "_FASE FASE "
cSql += "   FROM " + RetSqlName(cAlias) + " " + cAlias
cSql += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "    AND " + cAlias + "_CODOPE = '" + BCI->BCI_CODOPE + "' "
cSql += "    AND " + cAlias + "_CODLDP = '" + BCI->BCI_CODLDP + "' "
cSql += "    AND " + cAlias + "_CODPEG = '" + BCI->BCI_CODPEG + "' "
cSql += "    AND D_E_L_E_T_ = ' ' "

cSituac := " AND " + cAlias + "_SITUAC = '1' " 
cOrder 	:= " ORDER BY " + cAlias+"_FASE ASC "

cQuery 	:= cSql + cSituac + cOrder

dbUseArea(.T.,"TOPCONN",tcgenqry(,,cQuery),"TrbFA",.F.,.T.)

if ! TrbFA->(eof())
	cFase := TrbFA->FASE
else

	//Se n?o achou procuro os bloqueados
	dbUseArea(.T.,"TOPCONN",tcgenqry(,,cSql+cOrder),"TrbFA2",.F.,.T.)

	if ! TrbFA2->(eof())
		cFase := TrbFA2->FASE
	endif

	TrbFA2->(dbclosearea())

EndIf

TrbFA->(dbclosearea())

if cFase == "4" .and. lChkBaixa
	lBaixa := PLSTITPEG(nRecno)
endif

return({cFase, lBaixa})


/*/{Protheus.doc} PLSTITPEG   
@param 	  Retorna se a PEG ja est? paga ou liberada para pagamento
@author  Karine Riquena Limp               
@version P12
@return Retorna verdadeiro se a PEG j? foi paga e falso se ela ainda n?o foi paga
@since   13/11/2015
/*/
function PLSTITPEG(nRecno)
local lFound := .T.
local cAlias := ""
local cSql2  := ""

//ja sei que todas as guias est?o faturadas, essa fun??o s? ? chamada nesse caso
//  Posiciona no peg
BCI->(DbGoTo(nRecno))

//  De acordo com o tipo de guia posiciona no cabecalho da guia...
If BCI->BCI_TIPGUI $ "01,02,04,06,10"
	cAlias := "BD5"
ElseIf BCI->BCI_TIPGUI $ "03|05"
	cAlias := "BE4"
Endif

//Agora preciso achar o titulo das guias enquanto todos estiverem com a data de baixa, se houver algum que est? sem essa data, significa que a PEG n?o foi paga ainda
cSql2 += " SELECT E2_BAIXA FROM " + retSqlName(cAlias) + " " + cAlias 
cSql2 += " INNER JOIN " + RetSQLName("SE2") + " SE2 "
cSql2 += "   ON E2_FILIAL = '" + xFilial("SE2") + "' "
cSql2 += "   AND SE2.E2_PLOPELT = " + cAlias + "." + cAlias + "_OPELOT "
cSql2 += "   AND SE2.E2_PLLOTE  = " + cAlias + "." + cAlias + "_NUMLOT " 
cSql2 += "   AND SE2.D_E_L_E_T_ = ' ' "	
cSql2 += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' " 
cSql2 += "   AND " + cAlias + "_CODOPE = '" + BCI->BCI_CODOPE + "'"
cSql2 += "   AND " + cAlias + "_CODLDP = '" + BCI->BCI_CODLDP + "'"
cSql2 += "   AND " + cAlias + "_CODPEG = '" + BCI->BCI_CODPEG + "'"
cSql2 += "   AND " + cAlias + "_OPELOT = '" + PLSINTPAD() + "'"
cSql2 += "   AND " + cAlias + ".D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql2)),"ExistE2",.F.,.T.)

If ! ExistE2->(EoF())
	While ! ExistE2->(EoF()) .AND. lFound
		lFound := !(empTy(ExistE2->E2_BAIXA))
		ExistE2->(DbSkip())
	EndDo
else
	lfound := .F.
EndIf

ExistE2->(DbClosearea())

return lFound


/*/{Protheus.doc} PLRETSTISS   
@param 	  Fase da peg e Situa??o da PEG, Recno da BCI
@author  Karine Riquena Limp               
@version P12
@since   13/11/2015
/*/
function PLRETSTISS(cFase, cSituacao, nRecno, lBaixa)
LOCAL cStaTiss  := "1"
LOCAL cSituac 	:= "1"
local lNLibPag	:= .t.

DEFAULT cFase 	:= "1"
DEFAULT nRecno  := 0

//  Posiciona no peg
If nRecno != 0
	BCI->(DbGoTo(nRecno))
	cSituac  := BCI->BCI_SITUAC
	lNLibPag := empty(BCI->BCI_DTHRLB)
Else
	cSituac := cSituacao
EndIf

//Situa��o cancelada  
If cSituac == "2"
	// Cancelado
	cStaTiss := "9"

//Situa��o glosada 
elseif (nRecno != 0 .and. ! Empty(BCI->BCI_CODGLO)) .or. PLSPEGPAG(nRecno) 
	
	// Encerrado sem pagamento
	cStaTiss := "4"
    
//Em digita??o      		    
elseIf cFase == "1" 
	
	//Recebido
	cStaTiss := "1"

//Em confer?ncia	 	  	
elseIf cFase == "2" 
	
	//Em an?lise
	cStaTiss := "2"

//Pronta e n?o liberada para pagamento
elseIf cFase == "3" .and. lNLibPag	
  	
  	//Em an?lise
	cStaTiss := "2"

//Pronta e liberada para pagamento, deixo como 3, se n?o, o lote de pag. n?o ? gerado.
elseIf cFase == "3" .and. ! lNLibPag	
  	
	//Liberado para pagamento
	cStaTiss := "3"
   		 
elseIf cFase == "4"  //Faturada
	
    //se os titulos das guias da PEG est?o baixados no financeiro
	if lBaixa 
   	
   		//Pagamento Efetuado
   		cStaTiss := "6"
   		
   	//Nao gerou lote de pagamento ainda /*existe nota vinculada*/
    Else
   	
       	//(N?o pode ter gerado o lote de pagamento ainda) necess?ria consulta ao financeiro de acordo com o lote gerado para atender a este status. Somente quando h? nota vinculada 	
   		cStaTiss := "3" //Liberado para pagamento
   		
   	endIf
    	
endIf

return(cStaTiss)



//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSANLSTIG  
@param 	 Retorna o status da guia conforme tabela 45 de Terminologias da TISS
@author  Renan Martins             
@version P12
@since   07/2016
@obs	 Foi criado o campo BEA_STTISS e BE4_STTISS para armazenar este valor
1 - Autorizado / 2 - Em An?lise / 3 - Negado / 4- Aguardando Justificativa t?cnica do Solicitante / 5 - Aguardando documenta??o do prestador
6 - Solicita??o Cancelada / 7 - Autorizado parcialmente
/*/
//-------------------------------------------------------------------------------------
function PLSANLSTIG (cStatus, lAuditoria, lCancelada)

DEFAULT cStatus		:= "0"
DEFAULT lAuditoria 	:= .F.
DEFAULT lCancelada	:= .F.

//----------------------------------------------------------------------
//  Posiciona no peg
//----------------------------------------------------------------------

   If cStatus == "1"  //Autorizado  
   	  cStaTiss := "1"    
   		
   ELSEIF lAuditoria .OR. cStatus == "6" 
   	  cStaTiss := "2"  //Em An?lise

   	ElseIf lCancelada  //Cancelada	  	
   		cStaTiss := "6" 
   		   
   ElseIf cStatus == "2" //Autorizado Parcialmente  
   		cStaTiss := "7"  	
   		
   ElseIf cStatus == "3" //Negado - N?o Autorizado 	  	
   		cStaTiss := "3"    	  
   
    ElseIf cStatus == "5H" //Aguardando documenta??o do prestador  	
   		cStaTiss := "5"    //Aguardando documenta??o do prestador 

    ElseIf cStatus == "5" //Aguardando Liq. Titulo a Receber - Fica como em An?lise 	
   		cStaTiss := "2"    
    ELSE
    	cStaTiss := "2" //Em An?lise 
    ENDIF	

return(cStaTiss)


/*/{Protheus.doc} PLSPEGPAG  
@param 	 Fun??o para verificar se h? valor de pagamento em alguma Guia dentro do PEG
@author  Oscar Zanin        
@version P12
@since   27/01/2017
/*/
Static Function PLSPEGPAG(nRecno)
Local lRet 	    := .T.
Local cChave	:= ""
Local nValPag	:= 0

If nRecno > 0

	If BCI->(Recno()) <> nRecno
		BCI->(DbGoto(nRecno))
	EndIf

	cChave :=  BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)

	If BCI->BCI_TIPGUI == "05"
	
    	BE4->(dbSetOrder(1))
		if (BE4->(MsSeek(xfilial("BE4") + cChave)))
	
    		While( !(BE4->(EoF())) .AND. BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG) == cChave)
	            
                //Se tiver uma em digita??o ou conferencia, j? sai da rotina
    			If BE4->BE4_FASE == "1" .OR. BE4->BE4_FASE == "2"
				
                	lRet := .F.
					Exit
				else

					nValPag += BE4->BE4_VLRPAG
					If nValPag > 0
						lRet := .F.
						Exit
					EndIF
				EndIf

			BE4->(dbSkip())
			EndDo

		else
			lRet := .F.
		endIf

	else

		BD5->(DbSetOrder(1))
		if (BD5->(msSeek(xfilial("BD5") + cChave)))
			
            While( !(BD5->(EoF())) .AND. BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG) == cChave)
			    
                //Se tiver uma em digita??o ou conferencia ja sai
            	If BD5->BD5_FASE == "1" .OR. BD5->BD5_FASE == "2"  
					lRet := .F.
					Exit
				Else
					nValPag += BD5->BD5_VLRPAG
					If nValPag > 0
						lRet := .F.
						Exit
					EndIf
				EndIf

			BD5->(dbSkip())
			EndDo

		Else
			lRet := .F.
		EndIf

	EndIf

Else
	lRet := .F.
EndIf

Return lRet
