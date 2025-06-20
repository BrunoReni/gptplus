//Revis�o - transcri��o para 8.11 - Alcir Alves - 14-03-05 
#INCLUDE "ECOMC150.CH"
//Alcir Alves - Revis�o 27-10-05 - inclus�o dos eventos 999(estorno)
//Autor.....: Alessandro Alves Ferreira
//Programa..: ECOMC150.PRW
//Data......: 11/11/04
//Descricao.: Relat�rio de Movimenta��o Contabil.

#INCLUDE "TOPCONN.CH"
#INCLUDE "AVERAGE.CH"

/*
Funcao      : EICTR330
Objetivos   : Ajustar o relat�rio para a vers�o 811 - Release 4
Autor       : Juliano Paulino Alves - JPA
Data 	    : 14/08/2006
Obs         :
*/
******************
Function ECOMC150
******************
lRet := ECOMC150R3(.T.)
RETURN lRet

/*
Fun��o..: ECOMC150R3
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Relat�rio de Movimenta��o Contabil.
*/
*******************
Function ECOMC150R3(p_R4)
*******************
Local i //Alcir Alves - 28-06-05
Private cFilAtu:=""
Private cFilStr //Alcir Alves - 28-06-05
Private cFilECA:= xFilial("ECA")
Private cFilECF:= xFilial("ECF")
Private cFilEC6:= xFilial("EC6")
Private cFilSX5:= xFilial("SX5")
Private cNomArq:= "",aFilSel:={} //Alcir Alves - 28-06-05
Private nTot   := 0
Private aRel   := {}
Private lCancel:= .F.
Private cFilter
Private lExistECI:=.F.  //Alcir Alves - 18-04-05 - flag de verifica��o da tabela ECI

//JPA - 14/08/2006 - Relat�rio Personalizavel - Release 4
Private oReport
Private lR4   := If(p_R4 == NIL,.F.,.T.) .AND. FindFunction("TRepInUse") .And. TRepInUse()

#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF
//Alcir Alves - 18-04-05 - flag de verifica��o da tabela ECI
SX2->(DbSetOrder(1))
IF SX2->(DbSeek("ECI"))
   lExistECI:=.T.   
ENDIF
//

//MC150AcDic()//Verifica e Acerta Dicion�rio

aFilSel:=AvgSelectFil(.T.,"ECF") //Alcir Alves - 27/06/05 - conceito multifilial
//aadd(aFilSel,"02")
if aFilSel[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - valida��o do retorno da fun��o de sele��o de multifilial
   cFilStr:=""
   for i:=1 to len(aFilSel)
     cFilStr+=iif(!empty(cFilStr),",","")+IIF(!Empty(aFilSel[i]),"'"+aFilSel[i]+"'","") // PLB 13/04/06
   next
   Do While .T.
      
   IF ! Pergunte("MC150",.T.)
      Exit
   Endif

   cParEvento:= mv_par01
   cParContra:= mv_par02
   dParIni   := mv_par03
   dParFinal := mv_par04
   nTipImp   := mv_par05
   
   If !E_Periodo_Ok(dParIni,dParFinal) //Ambos est�o preenchidos
      Loop
   Endif
   
   If lTop
      Processa({|| MC150Query("ECA") ,MC150Dados()},STR0001)//"Pesquisando Dados da Pr�via..."
      Processa({|| MC150Query("ECF") ,MC150Dados()},STR0002)//"Pesquisando Dados da Efetiva��o..."
      TRB->( dbCloseArea() )
   Else
      Processa({|| MC150Filter("ECA",.T.),iIF(nTot > 0,MC150Dados("ECA"),.F.)},STR0001)//"Pesquisando Dados da Pr�via..."
      dbSelectArea("ECA")
      SET FILTER TO
      Processa({|| MC150Filter("ECF"),iIF(nTot > 0,MC150Dados("ECF"),.F.)},STR0002)//"Pesquisando Dados da Efetiva��o..."
      dbSelectArea("ECF")
      SET FILTER TO
   Endif

   If Len(aRel) > 0
      //Ordena o Relat�rio por Data de Contabiliza��o+Evento+Embarque
      MsAguarde({|| aRel := aSort( aRel,,,{|x,y| x[11]+DtoS(x[1]) + x[2] + x[4] < y[11]+DtoS(y[1]) + y[2] + y[4]} ) },STR0003)//"Ordenando Relat�rio..."
      
      If nTipImp == 1
         //Impress�o
         MC150Print()
      ElseIf nTipImp == 2
         //Em Arquivo
         RptStatus({|lCancel| MC150DbfImp(.F.)})
      Else
         //Excel
         RptStatus({|lCancel| MC150DbfImp(.T.)})
      Endif
   Else
      Help(" ",1,"AVG0005112")//"N�o h� Dados para Impress�o!"
   Endif
   aRel := {}

   EndDo
ENDIF

Return .T.

/*
Fun��o..: MC150Val
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Valida��es no Pergunte do Relat�rio
*/
*************************
Function MC150Val(cField)
*************************
lRet := .F.

If cField == "EC6_ID_CAM"
   if mv_par01=="999"
   lRet := .t.   
   else
   EC6->( dbSetOrder(1) )
   
   //Pesquisa o Evento em Todos os Modulos
   SX5->( DbSetOrder(1) )//X5_FILIAL+X5_TABELA+X5_CHAVE
   SX5->( DbSeek(cFilSX5+"CJ") )
   Do While !SX5->( EoF() ) .AND. SX5->X5_FILIAL == cFilSX5 .AND. SX5->X5_TABELA == "CJ" .AND. !lRet
      lRet:= EC6->( dbSeek(cFilEC6+SX5->X5_CHAVE+mv_par01) )
      SX5->( DbSkip() )
   EndDo

   If !lRet
      MsgStop(STR0004)//"Evento n�o Cadastrado."
   Endif
   endif
Endif

Return lRet

/*
Fun��o..: MC150Filter
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Filtra a tabela para os dados do relat�rio
*/
*************************
Function MC150Filter(cAlias,lECADT)
*************************
Local nCont    := 0
Default cAlias := "TRB"
Default lECADT := .F.
cFil    := xFilial(cAlias)

cFilter:= cAlias+"_FILIAL $ '"+cFilStr+"' "

If !Empty(cParEvento)
   cFilter+= ".AND. "+cAlias+"_ID_CAM == '"+cParEvento+"' "
Endif
If !Empty(cParContra)
   cFilter+= ".AND. "+cAlias+"_CONTRA == '"+cParContra+"' "
Endif
If !Empty(dParIni)
   If lECADT
      cFilter+= ".AND. "+cAlias+"_DT_CON >= CtoD('"+DtoC(dParIni)+"') "
   Else
      cFilter+= ".AND. "+cAlias+"_DTCONT >= CtoD('"+DtoC(dParIni)+"') "
   Endif
Endif
If !Empty(dParFinal)
   If lECADT
      cFilter+= ".AND. "+cAlias+"_DT_CON <= CtoD('"+DtoC(dParFinal)+"') "
   Else
      cFilter+= ".AND. "+cAlias+"_DTCONT <= CtoD('"+DtoC(dParFinal)+"') "
   Endif
Endif

cFilter := cAlias+"->( "+cFilter+" )"
(cAlias)->( dbSetFilter( {|| &cFilter},cFilter) )

(cAlias)->( dbSetOrder(1) )
(cAlias)->( dbSeek(cFil)  )
nCont:=0

//Conta Registros
(cAlias)->( dbEval( {|| nCont++ },,{|| !(cAlias)->( EoF() )},,,.T.) )

nToT := nCont

(cAlias)->( dbSetOrder(1) )
(cAlias)->( dbSeek(cFil)  )

Return .T.

/*
Fun��o..: MC150Query
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Executa Query para retorno dos dados de impress�o
*/
***************************
Function MC150Query(cAlias)
***************************
Local cDel := iIF( TcSrvType() <> "AS/400", "D_E_L_E_T_ <> '*' ", "@DELETED@ <> '*' " )
Local cQuery
Local cTab := cAlias+"."+cAlias
Local cDtCont := iIF(cAlias == "ECA","ECA.ECA_DT_CON","ECF.ECF_DTCONT")

//            Evento                          Descri��o do Evento     Embarque
//cCampos  :=   cTab+"_ID_CAM AS ECF_ID_CAM, "+" EC6.EC6_DESC,EC6.EC6_TPMODU AS EC6_TPMODU ,"+cTab+"_PREEMB AS ECF_PREEMB, "+cTab+"_HAWB AS ECF_HAWB, "
cCampos  :=   cTab+"_ID_CAM AS ECF_ID_CAM, "+cTab+"_PREEMB AS ECF_PREEMB, "+cTab+"_HAWB AS ECF_HAWB, "
//            Nota Fiscal                Contrato de Financiamento      Conta D�bito                   Contra Cr�dito
cCampos  +=   cTab+"_NRNF AS ECF_NRNF, "+cTab+"_CONTRA AS ECF_CONTRA, "+cTab+"_CTA_DB AS ECF_CTA_DB, "+cTab+"_CTA_CR AS ECF_CTA_CR, "+cTab+"_BANCO AS ECF_BANCO,"
//            Valor R$                     Modulo                        Data
cCampos  +=   cTab+"_VALOR AS ECF_VALOR, "+cTab+"_TPMODU AS ECF_TPMODU, "+cDtCont+" AS ECF_DTCONT,"+cTab+"_LINK AS ECF_LINK" 
//
If cAlias == "ECF"
// Nro. Contabiliza��o
   cCampos += ", "+cTab+"_NR_CON AS ECF_NR_CON,"+cTab+"_TP_EVE AS ECF_TP_EVE "
ELSE
   cCampos += ", "+cTab+"_ID_CAM AS ECF_TP_EVE "
Endif
//              Filial
//cCampos += ", "+cTab+"_FILIAL AS "+cAlias+"_FILIAL "
cCampos += ", "+cTab+"_FILIAL AS ECF_FILIAL "  // PLB 18/05/06

//cFrom    := RetSqlName(cAlias)+" "+cAlias+", "+RetSqlName("EC6")+" EC6 "
cFrom    := RetSqlName(cAlias)+" "+cAlias+" " 
//
cWhere   := cAlias+"."+cDel+" AND "+cTab+"_FILIAL IN ("+IIF(Empty(cFilStr),"'  '",cFilStr)+")"  // PLB 14/04/06

cWhere += " AND "+cTab+"_CONTAB = '1' "
//cWhere   += " AND EC6.EC6_ID_CAM = "+cTab+"_ID_CAM AND EC6.EC6_TPMODU = "+cTab+"_TPMODU and  EC6.EC6_IDENTC = "+cTab+"_IDENTC "
//cWhere   += " "

//Filtro por Evento
If !Empty(cParEvento)
   cWhere += " AND "+cTab+"_ID_CAM = '"+cParEvento+"'"
Endif
//Filtro por Contrato
If !Empty(cParContra)
   cWhere += " AND "+cTab+"_CONTRA = '"+cParContra+"'"
Endif
//Filtro Por periodo
If !Empty(dParIni)
   cWhere += " AND "+cDtCont+" >= '"+DtoS(dParIni)  +"'"
Endif
If !Empty(dParFinal)
   cWhere += " AND "+cDtCont+" <= '"+DtoS(dParFinal)  +"'"
Endif

cOrder := cTab+"_FILIAL,"+cDtCont+", "+cTab+"_ID_CAM ,"+cTab+"_PREEMB, "+cTab+"_HAWB "

cQuery := " SELECT "+cCampos+" FROM "+cFrom+" WHERE "+cWhere+" ORDER BY "+cOrder

cQuery := ChangeQuery( cQuery )

If Select("TRB") > 0
   TRB->( dbCloseArea() )
Endif

TcQuery cQuery ALIAS "TRB" NEW
TcSetField("TRB","ECF_DTCONT","D")

nToT   := MC150TotReg( cQuery )

Return .T.

/*
Fun��o..: MC150TotReg
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Retornar o Numero de Registros retornados em uma Query
*/
Function MC150TotReg(cQuery)
Local nTotalReg

If Select("TOTALREG") > 0
   TOTALREG->( dbCloseArea() )
Endif

cQuery := SubStr(cQuery,1,RAt("ORDER BY",cQuery) - 1)

//Total de Registros
cQuery = ChangeQuery("SELECT COUNT(*) AS TOTAL FROM ("+cQuery+") TEMP")
TcQuery cQuery ALIAS "TOTALREG" NEW

nTotalReg:= TOTALREG->TOTAL

TOTALREG->( dbCloseArea() )

Return nTotalReg

/*
Fun��o..: MC150Dados
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Gera Array com dados de Impress�o
*/
Function MC150Dados(cTab)
Local MCTA_DEB:=MCTA_CRE:=""
Local PTipoFin
Local cNrCon := "PREVIA"
LOCAL cFilSA6:=XFILIAL("SA6")
lOCAL cFilECI:=XFILIAL("ECI")
Default cTab := "TRB"

dbSelectArea(cTab) 
ProcRegua( nToT )
(cTab)->( dbGoTop() )

If cTab == "TRB"
   If TRB->( FieldPos("ECF_NR_CON") > 0 )
      TRB->(DBSELECTAREA("TRB"))
      Do While ! TRB->( EoF() )
         If ECF_TPMODU=="IMPORT"
            cProc := ECF_HAWB
         Else
            cProc := ECF_PREEMB
         Endif
         EC6->(DBSEEK(cFilEC6+TRB->ECF_TPMODU+TRB->ECF_ID_CAM))
         //Alcir Alves - 07-04-05 - adapta��o  do ajuste dos n�meros da conta
         MCTA_DEB := AllTrim(ECF_CTA_DB)
         MCTA_CRE := AllTrim(ECF_CTA_CR)
         PTipoFin:=ECF_TP_EVE
         PEvento:=ECF_ID_CAM
         // Verifica se os tipos de contas s�o de Banco
         If SUBSTR(MCTA_DEB,1,Len(ECF_CTA_DB)-1) = Replicate("7",Len(ECF_CTA_DB)-1)
            DO CASE
               CASE RIGHT(MCTA_DEB,1) = '0' 
                    If (SA6->(DbSeek(cFilSA6+TRB->ECF_BANCO))) //(SA6->(DbSeek(cFilSA6+EEQ->EEQ_BANC)) .AND. !Empty(AllTrim(EEQ->EEQ_BANC))) .Or. (SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI)) .AND. !Empty(AllTrim(EF1->EF1_BAN_FI)))
                       MCTA_DEB = AllTrim(SA6->A6_CONTABI)
                    ENDIF
               OTHERWISE
                    IF lExistECI //Alcir Alves - 18-04-05 - verifica se a tabela ECI existe
                       If ECI->(DbSeek(cFilECI+TRB->ECF_BANCO+'FIEX'+PTipoFin+RIGHT(MCTA_DEB,1)))
                          MCTA_DEB = AllTrim(ECI->ECI_CONTAB)
                       ENDIF         
                       IF PEvento $ '600/650'
                          ECI->(DbSeek(cFilECI+TRB->ECF_BANCO+'FIEX01'+'1'))
                          MCTA_DEB = ECI->ECI_CONTAB
                          ECI->(DbSeek(cFilECI+TRB->ECF_BANCO+'FIEX02'+'1'))
                          MCTA_CRE = ECI->ECI_CONTAB
                       ENDIF  
                    ENDIF
            ENDCASE   
         ENDIF

         If SUBSTR(MCTA_CRE,1,Len(MCTA_CRE)-1) = Replicate("7",Len(MCTA_CRE)-1) .AND. PEvento # '600' .AND. PEvento # '650'
            DO CASE
               CASE RIGHT(MCTA_CRE,1) = '0'
                    If (SA6->(DbSeek(cFilSA6+TRB->ECF_BANCO))) // .AND. !Empty(AllTrim(EEQ->EEQ_BANC))) .Or. (SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI)) .AND. !Empty(AllTrim(EF1->EF1_BAN_FI)))
                       MCTA_CRE = AllTrim(SA6->A6_CONTABI)
                    ENDIF                
               OTHERWISE
                    IF lExistECI //Alcir Alves - 18-04-05 - verifica se a tabela ECI existe
                       If ECI->(DbSeek(cFilECI+TRB->ECF_BANCO+EC6->EC6_TPMODU+RIGHT(MCTA_CRE,1)))
                           MCTA_CRE = AllTrim(ECI->ECI_CONTAB)
                       ENDIF
                    Endif   
            ENDCASE   
         ENDIF 
         //
         aAdd( aRel,{ ECF_DTCONT, ECF_ID_CAM,iif(ECF_ID_CAM<>"999",EC6->EC6_DESC, "Est."+alltrim(Posicione("EC6",1,cFilEC6+ECF_TPMODU+ECF_LINK,"EC6_DESC"))), cProc, ECF_NRNF, ECF_CONTRA, MCTA_DEB,MCTA_CRE, ECF_VALOR, ECF_NR_CON , ECF_FILIAL })
         TRB->( dbSkip() )           
      EndDo
   Else
      Do While ! TRB->( EoF() )
         If ECF_TPMODU=="IMPORT"
            cProc := ECF_HAWB
         Else
            cProc := ECF_PREEMB
         Endif
         
         EC6->(DBSEEK(cFilEC6+TRB->ECF_TPMODU+TRB->ECF_ID_CAM))
         //Alcir Alves - 07-04-05 - adapta��o  do ajuste dos n�meros da conta
         MCTA_DEB := AllTrim(ECF_CTA_DB)
         MCTA_CRE := AllTrim(ECF_CTA_CR)
         PTipoFin:=ECF_TP_EVE
         PEvento:=ECF_ID_CAM
         // Verifica se os tipos de contas s�o de Banco
         If SUBSTR(MCTA_DEB,1,Len(ECF_CTA_DB)-1) = Replicate("7",Len(ECF_CTA_DB)-1)
            DO CASE
               CASE RIGHT(MCTA_DEB,1) = '0'
                    If (SA6->(DbSeek(cFilSA6+TRB->ECF_BANCO))) //(SA6->(DbSeek(cFilSA6+EEQ->EEQ_BANC)) .AND. !Empty(AllTrim(EEQ->EEQ_BANC))) .Or. (SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI)) .AND. !Empty(AllTrim(EF1->EF1_BAN_FI)))
                       MCTA_DEB = AllTrim(SA6->A6_CONTABI)
                    ENDIF
               OTHERWISE
                    IF lExistECI //Alcir Alves - 18-04-05 - verifica se a tabela ECI existe
                       If ECI->(DbSeek(cFilECI+TRB->ECF_BANCO+'FIEX'+PTipoFin+RIGHT(MCTA_DEB,1)))
                          MCTA_DEB = AllTrim(ECI->ECI_CONTAB)
                       ENDIF         
                       IF PEvento $ '600/650'
                          ECI->(DbSeek(cFilECI+TRB->ECF_BANCO+'FIEX01'+'1'))
                          MCTA_DEB = ECI->ECI_CONTAB
                          ECI->(DbSeek(cFilECI+TRB->ECF_BANCO+'FIEX02'+'1'))
                          MCTA_CRE = ECI->ECI_CONTAB
                       ENDIF 
                    Endif
            ENDCASE   
         ENDIF
         If SUBSTR(MCTA_CRE,1,Len(MCTA_CRE)-1) = Replicate("7",Len(MCTA_CRE)-1) .AND. PEvento # '600' .AND. PEvento # '650'
            DO CASE
               CASE RIGHT(MCTA_CRE,1) = '0'
                    If (SA6->(DbSeek(cFilSA6+TRB->ECF_BANCO))) // .AND. !Empty(AllTrim(EEQ->EEQ_BANC))) .Or. (SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI)) .AND. !Empty(AllTrim(EF1->EF1_BAN_FI)))
                       MCTA_CRE = AllTrim(SA6->A6_CONTABI)
                    ENDIF                
               OTHERWISE
                    IF lExistECI //Alcir Alves - 18-04-05 - verifica se a tabela ECI existe
                       If ECI->(DbSeek(cFilECI+TRB->ECF_BANCO+EC6->EC6_TPMODU+RIGHT(MCTA_CRE,1)))
                          MCTA_CRE = AllTrim(ECI->ECI_CONTAB)
                       ENDIF
                    Endif
            ENDCASE   
         ENDIF 
         //
         aAdd( aRel,{ ECF_DTCONT, ECF_ID_CAM,iif(ECF_ID_CAM<>"999",EC6->EC6_DESC, "Est."+alltrim(Posicione("EC6",1,cFilEC6+ECF_TPMODU+ECF_LINK,"EC6_DESC"))), cProc, ECF_NRNF, ECF_CONTRA, MCTA_DEB, MCTA_CRE , ECF_VALOR, cNrCon , ECF_FILIAL })
         TRB->( dbSkip() )
      EndDo   
   Endif
Elseif cTab == "ECA"
   Do While ! ECA->( EoF() )
      If ECA_TPMODU=="IMPORT"
         cProc := ECA_HAWB
      Else
         cProc := ECA_PREEMB
      Endif
      EC6->(DBSEEK(cFilEC6+TRB->ECF_TPMODU+TRB->ECF_ID_CAM))

       //Alcir Alves - 07-04-05 - adapta��o  do ajuste dos n�meros da conta
         MCTA_DEB := AllTrim(ECA_CTA_DB)
         MCTA_CRE := AllTrim(ECA_CTA_CR)
         PTipoFin:=ECA_TP_EVE
         PEvento:=ECA_ID_CAM
         // Verifica se os tipos de contas s�o de Banco
  
         If SUBSTR(MCTA_DEB,1,Len(ECF_CTA_DB)-1) = Replicate("7",Len(ECF_CTA_DB)-1)
            DO CASE
               CASE RIGHT(MCTA_DEB,1) = '0'
                    If (SA6->(DbSeek(cFilSA6+ECF_BANCO))) //(SA6->(DbSeek(cFilSA6+EEQ->EEQ_BANC)) .AND. !Empty(AllTrim(EEQ->EEQ_BANC))) .Or. (SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI)) .AND. !Empty(AllTrim(EF1->EF1_BAN_FI)))
                       MCTA_DEB = AllTrim(SA6->A6_CONTABI)
                    ENDIF
               OTHERWISE
                    IF lExistECI //Alcir Alves - 18-04-05 - verifica se a tabela ECI existe
                       If ECI->(DbSeek(cFilECI+ECF_BANCO+'FIEX'+PTipoFin+RIGHT(MCTA_DEB,1)))
                          MCTA_DEB = AllTrim(ECI->ECI_CONTAB)
                       ENDIF         
                       IF PEvento $ '600/650'
                          ECI->(DbSeek(cFilECI+ECF_BANCO+'FIEX01'+'1'))
                          MCTA_DEB = ECI->ECI_CONTAB
                          ECI->(DbSeek(cFilECI+ECF_BANCO+'FIEX02'+'1'))
                          MCTA_CRE = ECI->ECI_CONTAB
                       ENDIF
                    Endif
            ENDCASE   
         ENDIF
         If SUBSTR(MCTA_CRE,1,Len(MCTA_CRE)-1) = Replicate("7",Len(MCTA_CRE)-1) .AND. PEvento # '600' .AND. PEvento # '650'
            DO CASE
               CASE RIGHT(MCTA_CRE,1) = '0'
                    If (SA6->(DbSeek(cFilSA6+ECF_BANCO))) // .AND. !Empty(AllTrim(EEQ->EEQ_BANC))) .Or. (SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI)) .AND. !Empty(AllTrim(EF1->EF1_BAN_FI)))
                       MCTA_CRE = AllTrim(SA6->A6_CONTABI)
                    ENDIF                
               OTHERWISE
                    IF lExistECI //Alcir Alves - 18-04-05 - verifica se a tabela ECI existe               
                       If ECI->(DbSeek(cFilECI+ECF_BANCO+EC6->EC6_TPMODU+RIGHT(MCTA_CRE,1)))
                          MCTA_CRE = AllTrim(ECI->ECI_CONTAB)
                       ENDIF
                    Endif   
            ENDCASE   
         ENDIF 
         //


      aAdd( aRel,{ ECA_DT_CON, ECA_ID_CAM, Posicione("EC6",1,cFilEC6+ECA_TPMODU+iif(ECF_ID_CAM<>"999",ECA_ID_CAM, ECA_LINK),"EC6_DESC"), cProc, ECA_NRNF, ECA_CONTRA, ECA_CTA_DB, ECA_CTA_CR, ECA_VALOR, cNrCon , ECA_FILIAL })
      ECA->( dbSkip() )
   EndDo
Elseif cTab == "ECF"
   Do While ! ECF->( EoF() )
      If ECF_TPMODU == "IMPORT"
         cProc := ECF_HAWB
      Else
         cProc := ECF_PREEMB
      Endif

      EC6->(DBSEEK(cFilEC6+TRB->ECF_TPMODU+TRB->ECF_ID_CAM))
         //Alcir Alves - 07-04-05 - adapta��o  do ajuste dos n�meros da conta
         MCTA_DEB := AllTrim(ECF_CTA_DB)
         MCTA_CRE := AllTrim(ECF_CTA_CR)
         PTipoFin:=ECF_TPMODU    
         PTipoFin:=ECF_TP_EVE
         // Verifica se os tipos de contas s�o de Banco
         If SUBSTR(MCTA_DEB,1,Len(ECF_CTA_DB)-1) = Replicate("7",Len(ECF_CTA_DB)-1)
            DO CASE
               CASE RIGHT(MCTA_DEB,1) = '0'
                    If (SA6->(DbSeek(cFilSA6+ECF_BANCO))) //(SA6->(DbSeek(cFilSA6+EEQ->EEQ_BANC)) .AND. !Empty(AllTrim(EEQ->EEQ_BANC))) .Or. (SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI)) .AND. !Empty(AllTrim(EF1->EF1_BAN_FI)))
                       MCTA_DEB = AllTrim(SA6->A6_CONTABI)
                    ENDIF
               OTHERWISE
                    IF lExistECI //Alcir Alves - 18-04-05 - verifica se a tabela ECI existe
                       If ECI->(DbSeek(cFilECI+ECF_BANCO+'FIEX'+PTipoFin+RIGHT(MCTA_DEB,1)))
                          MCTA_DEB = AllTrim(ECI->ECI_CONTAB)
                       ENDIF         
                       IF PEvento $ '600/650'
                          ECI->(DbSeek(cFilECI+ECF_BANCO+'FIEX01'+'1'))
                          MCTA_DEB = ECI->ECI_CONTAB
                          ECI->(DbSeek(cFilECI+ECF_BANCO+'FIEX02'+'1'))
                          MCTA_CRE = ECI->ECI_CONTAB
                       ENDIF
                    Endif
            ENDCASE   
         ENDIF
         If SUBSTR(MCTA_CRE,1,Len(MCTA_CRE)-1) = Replicate("7",Len(MCTA_CRE)-1) .AND. PEvento # '600' .AND. PEvento # '650'
            DO CASE
               CASE RIGHT(MCTA_CRE,1) = '0'
                    If (SA6->(DbSeek(cFilSA6+ECF_BANCO))) // .AND. !Empty(AllTrim(EEQ->EEQ_BANC))) .Or. (SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI)) .AND. !Empty(AllTrim(EF1->EF1_BAN_FI)))
                       MCTA_CRE = AllTrim(SA6->A6_CONTABI)
                    ENDIF                
               OTHERWISE
                    IF lExistECI //Alcir Alves - 18-04-05 - verifica se a tabela ECI existe
                       If ECI->(DbSeek(cFilECI+ECF_BANCO+EC6->EC6_TPMODU+RIGHT(MCTA_CRE,1)))
                          MCTA_CRE = AllTrim(ECI->ECI_CONTAB)
                       ENDIF
                    endif   
            ENDCASE   
         ENDIF 
         //

      aAdd( aRel,{ ECF_DTCONT, ECF_ID_CAM, Posicione("EC6",1,cFilEC6+ECF_TPMODU+iif(ECF_ID_CAM<>"999",ECF_ID_CAM, ECF_LINK),"EC6_DESC"), cProc, ECF_NRNF, ECF_CONTRA, MCTA_DEB, MCTA_CRE, ECF_VALOR, ECF_NR_CON , ECF_FILIAL })
      ECF->( dbSkip() )
   EndDo   
Endif

Return .T.

/*
Fun��o..: MC150Print
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Prepara Impress�o SetPrint
*/
*********************
Function MC150Print()
*********************
Local cDesc1         := STR0005//"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0006//"de Movimenta��o Contabil "
Local cDesc3         := "", cPict := "", imprime := .T.
Private titulo       := STR0007//"Movimenta��o Contabil"
Private nPagina      := 0
Private nLin         := 99
Private cString      := "ECF"
Private lAbortPrint  := .F., limite := 220, tamanho := "G"
Private nomeprog     := "ECOMC150"
Private aReturn      := {STR0008, 1,STR0009, 1, 1, 1, "", 1}//"Zebrado"###"Administracao"
Private nLastKey     := 0
Private wnrel        := "ECOMC150"

wnrel := If (lR4,(ReportWork(),oReport := ReportDef()),SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho))  //JPA - 14/08/2006

If nLastKey == 27
   Return
Endif

If !lR4
   SetDefault(aReturn,cString)
EndIf

RptStatus({|lCancel| MC150Impr()})

Return .T.

/*
Fun��o..: MC150Impr
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Imprimir o Relat�rio de ACC/ACE
*/
********************
Function MC150Impr()
********************
Local i
Private cPictVl := AVSX3("ECF_VL_MOE",6)
Private nTamPic := Len(Transform( 1, cPictVl))
Private aColuna := {}

//cPictProc := AVSX3("ECF_PREEMB",6)
//cPictAgen := AVSX3("EEB_CODAGE",6)
//cPictMoe  := AVSX3("ECF_MOEDA" ,6)

SetRegua(Len(aRel))

Private nColIni  := 000 //Coluna Inicial
Private nEspaco  := 002 //Espa�o entre os campos
Private nRemPict := 002 //Quantos caracteres a remover da Picture
   
cPictVl := "@E "+SubStr(cPictVl,4+nRemPict)//@E 999,999,999.99
nTamPic:= Len(Transform( 1, cPictVl))

//             Cabe�alho         Texto              Picture               Tamanho
aColuna := { { STR0010 ,{|x| aRel[x][ 1] }, AVSX3("ECF_DTCONT",6) , AVSX3("ECF_DTCONT",3)},;//"Data"
             { STR0011 ,{|x| aRel[x][ 2] }, AVSX3("ECF_ID_CAM",6) , AVSX3("ECF_ID_CAM",3)},;//"Evento"
             { STR0012 ,{|x| aRel[x][ 3] }, AVSX3("EC6_DESC"  ,6) , AVSX3("EC6_DESC"  ,3)},;//"Descri��o"
             { STR0013 ,{|x| aRel[x][ 4] }, ""                    , Max(AVSX3("ECF_PREEMB",3),AVSX3("ECF_HAWB",3))},;//"Embarque/Cliente/Forn."
             { STR0014 ,{|x| aRel[x][ 5] }, AVSX3("ECF_NRNF"  ,6) , AVSX3("ECF_NRNF"  ,3)},;//"Nota Fiscal"
             { STR0015 ,{|x| aRel[x][ 6] }, AVSX3("ECF_CONTRA",6) , AVSX3("ECF_CONTRA",3)},;//"Contrato"
             { STR0016 ,{|x| aRel[x][ 7] }, AVSX3("ECF_CTA_DB",6) , AVSX3("ECF_CTA_DB",3)},;//"Conta D�bito"
             { STR0017 ,{|x| aRel[x][ 8] }, AVSX3("ECF_CTA_CR",6) , AVSX3("ECF_CTA_CR",3)},;//"Conta Cr�dito"
             { STR0018 ,{|x| aRel[x][ 9] }, AVSX3("ECF_VALOR" ,6) , AVSX3("ECF_VALOR" ,3)},;//"Valor em Reais"
             { STR0019 ,{|x| aRel[x][10] }, AVSX3("ECF_NR_CON",6) , AVSX3("ECF_NR_CON",3)} }//"Nro. Contabil."

If lR4
   oReport:PrintDialog()
   Return
EndIf      

Begin Sequence

   For i:= 1 To Len(aRel)

      If lCancel
         BREAK
      Endif

      If nLin > 56
         //Imprime cabe�alho
         MC150RlCab()
         nLin := 7
      Endif

      if cFilAtu<>aRel[i][11]
          nLin++
          @nLin,0 PSAY replicate("*",220)
          nLin++
          cFilAtu:=aRel[i][11]
          @ nLin,02 PSAY "Filial"+" "+cFilAtu+" - "+AvgFilName({cFilAtu})[1]
          nLin++
          @nLin,0 PSAY replicate("*",220)
          nLin++  
       endif
      //Imprime Linha
      MC150ImpLin(i)
      nLin++

      IncRegua()
   Next
   
   Set Printer To
   OurSpool(wnrel)

End Sequence

MS_FLUSH()

Return .T.       

/*
Fun��o..: MC150ImpLin
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Imprimir uma Linha no Relat�rio de acordo com o aColuna
*/
Function MC150ImpLin(nLinha)
Local i:=0
nColuna := nColIni
For i:= 1 To Len(aColuna)
   If aColuna[i][1] <> NIL
      cSay:= ""

      //Imprimi o Texto -Texto                       Picture
      cSay := Transform( Eval(aColuna[i][2],nLinha), aColuna[i][3] )
      
      If Len(cSay) > 0
         @ nLin,nColuna PSay Left(cSay,MC150TamCol(i,"Cabe�alho"))
      Endif

      //Soma o Espaco Impresso nessa coluna
      nColuna += MC150TamCol(i) + nEspaco
   Endif
Next

Return .T.

/*
Fun��o..: MC150RlCab
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Imprimir o Cabe�alho do Relat�rio
*/
***************************
Function MC150RlCab()
***************************
Local i:=0
nPagina ++
cTitPag := STR0020 + StrZero(nPagina,4,0)//"Pagina "
@ 00, 00 PSay __PrtFatline()
@ 01, 00 PSay STR0021+DtoC(Date())+" - "+Time()//"Emiss�o: " Data e Hora
@ 01, ( 220 / 2 ) - ( Len(titulo) / 2 ) PSay titulo
@ 01, 220 - Len(cTitPag) PSay cTitPag
@ 02, 00 PSay __PrtFatline()

@ 03, 00 PSay STR0022+DtoC(dParIni)+STR0023+DtoC(dParFinal)//"Periodo de "###" at� "

//Cabe�alho
//Primeira Linha
//-----------------------------------------------------------------------------------
nColuna := nColIni
For i:= 1 to Len(aColuna)
   If aColuna[i][1] <> NIL
      nTamCol := MC150TamCol(i,"Cabe�alho")

      nColFim := nColuna+nTamCol
      If i < Len(aColuna) .AND. aColuna[i+1][1] == NIL
         //Pega o Tamanho da Proxima Coluna caso ela n�o tenha Titulo de cabe�alho
         nColFim += nEspaco+CO150TamCol(i+1)
      Endif

      MC150ImpCen(05,nColuna,nColFim,aColuna[i][1])
      nColuna := nColFim+nEspaco
   Endif
Next
//-----------------------------------------------------------------------------------
@ 06, 00 PSay __PrtThinLine()

Return .T.

/*
Fun��o..: MC150TamCol
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Retornar o Tamanho da Coluna
*/
**************************
Function MC150TamCol(nCol)
**************************
RETURN Max(Len(Transform(1,aColuna[nCol][3])),Max( aColuna[nCol][4], Len(aColuna[nCol][1]) ) )

/*
Fun��o..: MC150ImpCen
Autor...: Alessandro Alves Ferreira - AAF
Data....: 11/11/04
Objetivo: Imprimir texto centralizado entre duas colunas
*/
Function MC150ImpCen(nLinha,nColIni,nColFim,cTexto)
Local nCol

If ValType(cTexto) <> "C"
   cTexto := ""
Endif

If Len(cTexto) >= nColFim - nColIni
   nCol := nColIni
Else
   nCol := Round( ( nColIni + nColFim) / 2 ,0) - Round( Len(cTexto) / 2 ,0 ) //Posic�o Para Imprimir no Centro entre as duas colunas
Endif

cSay := Replicate(" ", nCol - nColIni)
If Len(cSay) > 0
   @ nLinha, nColIni PSay cSay          //Imprimi tra�os antes do Texto
Endif

@ nLinha, nCol PSay cTexto  //Imprimi o Texto

If Len(cSay) > 0
   cSay := Replicate(" ", nColFim - (nCol+Len(cTexto)))
   @ nLinha, nCol+Len(cTexto) PSay cSay //Imprimi tra�os depois do Texto
Endif

Return .T.

/*
Fun��o..: MC150DBFImp
Autor...: Alessandro Alves Ferreira - AAF
Data....: 12/11/04
Objetivo: Gera work com o relat�rio para exportar ao Excel
          ou salvar arquivo DBF/TXT
*/
****************************
Function MC150DbfImp(lExcel)
****************************
Local i:=0
Local i2:=0
Local cArquivo := CriaTrab(,.F.)
Local oExcelApp
cDirDocs := MsDocPath()
cPath	:= AllTrim(GetTempPath())

aColuna := { { "DATA_EVENT",AVSX3("ECF_DTCONT", 02), AVSX3("ECF_DTCONT", 03), AVSX3("ECF_DTCONT", 04),{|x| aRel[x][ 1] } },;
             { "EVENTO"    ,AVSX3("ECF_ID_CAM", 02), AVSX3("ECF_ID_CAM", 03), AVSX3("ECF_ID_CAM", 04),{|x| aRel[x][ 2] } },;
             { "DESCRICAO" ,AVSX3("EC6_DESC"  , 02), AVSX3("EC6_DESC"  , 03), AVSX3("EC6_DESC"  , 04),{|x| aRel[x][ 3] } },;
             { "EMBARQUE"  ,AVSX3("ECF_PREEMB", 02), AVSX3("ECF_PREEMB", 03), AVSX3("ECF_PREEMB", 04),{|x| aRel[x][ 4] } },;
             { "NOTA_FISC" ,AVSX3("ECF_NRNF"  , 02), AVSX3("ECF_NRNF"  , 03), AVSX3("ECF_NRNF"  , 04),{|x| aRel[x][ 5] } },;
             { "CONTRATO"  ,AVSX3("ECF_CONTRA", 02), AVSX3("ECF_CONTRA", 03), AVSX3("ECF_CONTRA", 04),{|x| aRel[x][ 6] } },;
             { "CTA_DEBITO",AVSX3("ECF_CTA_DB", 02), AVSX3("ECF_CTA_DB", 03), AVSX3("ECF_CTA_DB", 04),{|x| aRel[x][ 7] } },;
             { "CTA_CREDIT",AVSX3("ECF_CTA_CR", 02), AVSX3("ECF_CTA_CR", 03), AVSX3("ECF_CTA_CR", 04),{|x| aRel[x][ 8] } },;
             { "VALOR_RS"  ,AVSX3("ECF_VALOR" , 02), AVSX3("ECF_VALOR" , 03), AVSX3("ECF_VALOR" , 04),{|x| aRel[x][ 9] } },;
             { "NRO_CONTAB",AVSX3("ECF_NR_CON", 02), AVSX3("ECF_NR_CON", 03), AVSX3("ECF_NR_CON", 04),{|x| aRel[x][10] } },;
             { "FILIAL",AVSX3("ECF_FILIAL", 02)    , AVSX3("ECF_FILIAL", 03), AVSX3("ECF_FILIAL", 04),{|x| aRel[x][11] } } }

//Monta Estrutura
aEstru:= {}
For i:= 1 To Len(aColuna)
   aAdd(aEstru,{ aColuna[i][1], aColuna[i][2], aColuna[i][3], aColuna[i][4] } )
Next

cDirDocs := E_CriaTrab(, aEstru, cArquivo)

SetRegua(Len(aRel))

Begin Sequence

   For i := 1 To Len(aRel)
   
      If lCancel
        (cArquivo)->( dbCloseArea() )
         E_EraseArq(cArquivo)
         BREAK
      Endif
   
      (cArquivo)->( dbAppend() )
      For i2:= 1 To Len(aColuna)
         (cArquivo)->( FieldPut(i2, Eval(aColuna[i2][5],i) ) )
      Next
      IncRegua()

   Next

   if lExcel
      (cArquivo)->( dbCloseArea() )
      CpyS2T( cDirDocs+"\"+cArquivo+".DBF" , cPath, .T. )

      //Envia ao Excel
      If ! ApOleClient( 'MsExcel' )
         MsgStop(STR0024) //"MsExcel n�o instalado."
         RETURN .F.
      Else
         //Abre Dbf no Excel
         oExcelApp:= MsExcel():New()
         oExcelApp:WorkBooks:Open( cPath+cArquivo+".dbf" )
         oExcelApp:SetVisible(.T.)
      EndIf
   Else
      //Abre para criacao do arquivo TXT/DBF
      TR350ARQUIVO(cArquivo)
      (cArquivo)->( dbCloseArea() )
   EndIf

End Sequence

Return .T.

/*
Fun��o..: MC150AcDic
Autor...: Alessandro Alves Ferreira - AAF
Data....: 04/11/04
Objetivo: Acertar o Dicion�rio SX1 caso n�o exista o Pergunte
*/
/*
*************************
Function MC150AcDic()
*************************
LOCAL cSX1CMP  // LCS.06/05/2009.14:44
cSX1CMP := PADR("MC150",LEN(SX1->X1_GRUPO)," ")
///If !SX1->( dbSeek("MC150 "+"01") )
If !SX1->( dbSeek(cSX1CMP+"01") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "MC150 "
   SX1->X1_ORDEM   := "01"
   SX1->X1_VARIAVL := "mv_ch1"
   SX1->X1_VAR01   := "mv_par01"
   SX1->X1_PERGUNT := "Evento ?"
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO := AVSX3("ECF_ID_CAM",3)
   SX1->X1_GSC     := "G"
   SX1->X1_F3      := "E24"
   SX1->X1_VALID   := "Vazio() .OR. MC150Val('EC6_ID_CAM')"
   SX1->( MsUnLock() )
EndIf

///If !SX1->( dbSeek("MC150 "+"02") )
If !SX1->( dbSeek(cSX1CMP+"02") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "MC150 "
   SX1->X1_ORDEM   := "02"
   SX1->X1_VARIAVL := "mv_ch2"
   SX1->X1_VAR01   := "mv_par02"
   SX1->X1_PERGUNT := "Contrato ?"
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO := AVSX3("ECF_CONTRA",3)
   SX1->X1_GSC     := "G"
   SX1->X1_F3      := "EF1"
   SX1->X1_VALID   := "Vazio() .OR. ExistCpo('EF1',mv_par02)"
   SX1->( MsUnLock() )
EndIf

///If !SX1->( dbSeek("MC150 "+"03") )
If !SX1->( dbSeek(cSX1CMP+"03") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "MC150 "
   SX1->X1_ORDEM   := "03"
   SX1->X1_VARIAVL := "mv_ch3"
   SX1->X1_VAR01   := "mv_par03"
   SX1->X1_PERGUNT := "Data Inicial ?"
   SX1->X1_TIPO    := "D"
   SX1->X1_TAMANHO :=  8
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := "Vazio() .OR. E_Periodo_Ok(mv_par03,mv_par04)"
   SX1->( MsUnLock() )
EndIf

///If !SX1->( dbSeek("MC150 "+"04") )
If !SX1->( dbSeek(cSX1CMP+"04") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "MC150 "
   SX1->X1_ORDEM   := "04"
   SX1->X1_VARIAVL := "mv_ch4"
   SX1->X1_VAR01   := "mv_par04"
   SX1->X1_PERGUNT := "Data Final ?"
   SX1->X1_TIPO    := "D"
   SX1->X1_TAMANHO :=  8
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := "Vazio() .OR. E_Periodo_Ok(mv_par03,mv_par04)"
   SX1->( MsUnLock() )
EndIf

///If !SX1->( dbSeek("MC150 "+"05") )
If !SX1->( dbSeek(cSX1CMP+"05") )
   RecLock("SX1",.T.)
   SX1->X1_GRUPO   := "MC150 "
   SX1->X1_ORDEM   := "05"
   SX1->X1_VARIAVL := "mv_ch5"
   SX1->X1_VAR01   := "mv_par05"
   SX1->X1_PERGUNT := "Tipo de relat�rio ?"
   SX1->X1_TIPO    := "N"
   SX1->X1_TAMANHO := 1
   SX1->X1_GSC     := "C"
   SX1->X1_DEF01   := "Impress�o"
   SX1->X1_DEF02   := "em Arquivo"
   SX1->X1_DEF03   := "no MsExcel"
   SX1->(msUnlock() )
Endif

Return .T.
*/
//JPA - 14/08/2006 - Defini��es do relat�rio personaliz�vel
****************************
Static Function ReportDef()
****************************                     
//Alias que podem ser utilizadas para adicionar campos personalizados no relat�rio
aTabelas := {}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usu�rio
aOrdem   := {}

//Par�metros:            Relat�rio , Titulo ,  Pergunte , C�digo de Bloco do Bot�o OK da tela de impress�o.
oReport := TReport():New("ECOMC150", STR0007, "MC150"  , {|oReport| ReportPrint(oReport)}, STR0005+" "+STR0006)

// Define o relatorio como Landscape Nick 20/10/06
oReport:opage:llandscape := .T.
oReport:opage:lportrait := .F.

//Define os objetos com as se��es do relat�rio
oSecao1 := TRSection():New(oReport,"Eventos Cont�beis",aTabelas,aOrdem)
oSecao2 := TRSection():New(oReport,"Filial",{"Work"},{})

//Defini��o das colunas de impress�o da se��o 1
TRCell():New(oSecao1, "WDATA"     , "Work", STR0010   , AVSX3("ECF_DTCONT",6) , AVSX3("ECF_DTCONT",3)                         , /*lPixel*/, /*{||  }*/)
TRCell():New(oSecao1, "EVENTO"    , "Work", STR0011   , AVSX3("ECF_ID_CAM",6) , AVSX3("ECF_ID_CAM",3)                         , /*lPixel*/, /*{||  }*/)
TRCell():New(oSecao1, "DESCR"     , "Work", STR0012   , AVSX3("EC6_DESC"  ,6) , AVSX3("EC6_DESC"  ,3)                         , /*lPixel*/, /*{||  }*/)
TRCell():New(oSecao1, "EMB_CLI_FO", "Work", STR0013   , /*Picture*/           , Max(AVSX3("ECF_PREEMB",3),AVSX3("ECF_HAWB",3)), /*lPixel*/, /*{||  }*/)
TRCell():New(oSecao1, "NOTA_FIS"  , "Work", STR0014   , AVSX3("ECF_NRNF"  ,6) , AVSX3("ECF_NRNF"  ,3)                         , /*lPixel*/, /*{||  }*/)
TRCell():New(oSecao1, "CONTRATO"  , "Work", STR0015   , AVSX3("ECF_CONTRA",6) , AVSX3("ECF_CONTRA",3)                         , /*lPixel*/, /*{||  }*/)
TRCell():New(oSecao1, "CON_DEB"   , "Work", STR0016   , AVSX3("ECF_CTA_DB",6) , AVSX3("ECF_CTA_DB",3)                         , /*lPixel*/, /*{||  }*/)
TRCell():New(oSecao1, "CON_CRE"   , "Work", STR0017   , AVSX3("ECF_CTA_CR",6) , AVSX3("ECF_CTA_CR",3)                         , /*lPixel*/, /*{||  }*/)
TRCell():New(oSecao1, "VALOR"     , "Work", STR0018   , AVSX3("ECF_VALOR" ,6) , AVSX3("ECF_VALOR" ,3)                         , /*lPixel*/, /*{||  }*/)
TRCell():New(oSecao1, "NCONTABIL" , "Work", STR0019   , AVSX3("ECF_NR_CON",6) , AVSX3("ECF_NR_CON",3)                         , /*lPixel*/, /*{||  }*/)
                                                    
//Defini��o das colunas de impress�o da se��o 2 
TRCell():New(oSecao2,"FILIAL"   , "Work", "Filial", /*Picture*/, 22 , /*lPixel*/, /*{|| code-block de impressao }*/)
//oReport:Section("Se��o 2"):Cell("FILIAL"):SetCellBreak()
                                 
oReport:bOnPageBreak :={||oReport:Section("Filial"):PrintLine()} 

//Necess�rio para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Private oSection := oReport:Section("Eventos Cont�beis")
oReport:SetMeter(Len(aRel))

oReport:Section("Filial"):Init()
//Inicio da impress�o da se��o 1. Sempre que se inicia a impress�o de uma se��o � impresso automaticamente
//o cabe�alho dela.
oReport:Section("Eventos Cont�beis"):Init()

//La�o principal
Work->(DbGoTop())
Do While !Work->(EOF())
   oReport:Section("Eventos Cont�beis"):PrintLine() //Impress�o da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->(dbSkip())
EndDo

//Fim da impress�o da se��o 1
oReport:Section("Eventos Cont�beis"):Finish()
//Fim da impress�o da se��o 2
oReport:Section("Filial"):Finish()                                
Work->(DbCloseArea())
return .T.
          
//JPA - 14/08/2006 - Cria work a ser utilizada pelo relat�rio personaliz�vel
****************************
Static Function ReportWork
****************************
Local i:=0
Private cArquivo := CriaTrab(,.F.)
Private aHeader:={},aCampos := {}
PRIVATE aSemSX3 := {}, cNomArq := ""

If Select("Work") > 0
   Work->( DBCloseArea() )       
EndIf              
DBSelectArea("ECF")

aSemSX3 := { { "WDATA"    , AVSX3("ECF_DTCONT", 02), AVSX3("ECF_DTCONT", 03), AVSX3("ECF_DTCONT", 04)},;
            { "EVENTO"    , AVSX3("ECF_ID_CAM", 02), AVSX3("ECF_ID_CAM", 03), AVSX3("ECF_ID_CAM", 04)},;
            { "DESCR"     , AVSX3("EC6_DESC"  , 02), AVSX3("EC6_DESC"  , 03), AVSX3("EC6_DESC"  , 04)},;
            { "EMB_CLI_FO", AVSX3("ECF_PREEMB", 02), AVSX3("ECF_PREEMB", 03), AVSX3("ECF_PREEMB", 04)},;
            { "NOTA_FIS"  , AVSX3("ECF_NRNF"  , 02), AVSX3("ECF_NRNF"  , 03), AVSX3("ECF_NRNF"  , 04)},;
            { "CONTRATO"  , AVSX3("ECF_CONTRA", 02), AVSX3("ECF_CONTRA", 03), AVSX3("ECF_CONTRA", 04)},;
            { "CON_DEB"   , AVSX3("ECF_CTA_DB", 02), AVSX3("ECF_CTA_DB", 03), AVSX3("ECF_CTA_DB", 04)},;
            { "CON_CRE"   , AVSX3("ECF_CTA_CR", 02), AVSX3("ECF_CTA_CR", 03), AVSX3("ECF_CTA_CR", 04)},;
            { "VALOR"     , AVSX3("ECF_VALOR" , 02), AVSX3("ECF_VALOR" , 03), AVSX3("ECF_VALOR" , 04)},;
            { "NCONTABIL" , AVSX3("ECF_NR_CON", 02), AVSX3("ECF_NR_CON", 03), AVSX3("ECF_NR_CON", 04)},;
            { "FILIAL"    , AVSX3("ECF_FILIAL", 02), AVSX3("ECF_FILIAL", 03), AVSX3("ECF_FILIAL", 04)} }

cNomArq:=E_CriaTrab(,aSemSX3,"Work",,.F.)
IndRegua("Work",cNomArq+TEOrdBagExt(),"FILIAL")

Work->(DbGoTop())
For i := 1 to Len(aRel)
   Work->(DbAppend())
   
   Work->WDATA      := aRel[i][1]
   Work->EVENTO     := aRel[i][2]
   Work->DESCR      := aRel[i][3]
   Work->EMB_CLI_FO := aRel[i][4]
   Work->NOTA_FIS   := aRel[i][5]
   Work->CONTRATO   := aRel[i][6]
   Work->CON_DEB    := aRel[i][7]
   Work->CON_CRE    := aRel[i][8]
   Work->VALOR      := aRel[i][9]
   Work->NCONTABIL  := aRel[i][10]
   Work->FILIAL     := aRel[i][11]
Next

Return
