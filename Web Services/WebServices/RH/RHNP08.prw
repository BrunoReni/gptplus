#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP08.CH"

#DEFINE  PAGE_LENGTH 10

#DEFINE OPERATION_INSERT  1
#DEFINE OPERATION_UPDATE  2
#DEFINE OPERATION_APPROVE 3
#DEFINE OPERATION_REPROVE 4
#DEFINE OPERATION_DELETE  5

Function RHNP08()
Return .T.

Private cMRrhKeyTree := ""


WSRESTFUL Vacation DESCRIPTION STR0001 //"Servi�os de Vacation"
WSDATA type         As String Optional
WSDATA page         As String Optional
WSDATA pageSize     As String Optional
WSDATA employeeId   As String Optional
WSDATA vacationId   As String Optional
WSDATA WsNull       As String Optional

//****************************** GETs ***********************************
WSMETHOD GET getInfoVacation ;
 DESCRIPTION STR0002 ; //"Servi�o GET que retorna os dados das solicita��es de f�rias."
 WSSYNTAX "/vacation/info/{employeeId}" ;
 PATH "/info/{employeeId}" ;
 PRODUCES 'application/json;charset=utf-8';
 TTALK "v2";

WSMETHOD GET getHistoryVacation ;
 DESCRIPTION STR0003 ; //"Servi�o GET que retorna o hist�rico de movimenta��es de f�rias."
 WSSYNTAX "/vacation/history/{employeeId}" ;
 PATH "/history/{employeeId}" ;
 PRODUCES 'application/json;charset=utf-8';
 TTALK "v2";

WSMETHOD GET NextDaysVacation ;
 DESCRIPTION STR0029; //Servi�o GET que retorna dados de f�rias programadas do funcion�rio ;
 WSSYNTAX "/vacation/myVacation/{employeeId}" ;
 PATH "/myVacation/{employeeId}" ;
 PRODUCES 'application/json;charset=utf-8'

WSMETHOD GET NoticeVacation ;
  DESCRIPTION STR0045 ; //"Retorna arquivo PDF do aviso de f�rias"
  WSSYNTAX "/vacation/notice/report/{employeeId}/{vacationId}" ;
  PATH "/notice/report/{employeeId}/{vacationId}" ;
  PRODUCES 'application/json;charset=utf-8';
  TTALK "v2";

WSMETHOD GET ReportVacation ;
  DESCRIPTION STR0046 ; //"Retorna arquivo PDF do recibo de f�rias"
  WSSYNTAX "/vacation/detail/report/{employeeId}/{vacationId}" ;
  PATH "/detail/report/{employeeId}/{vacationId}" ;
  PRODUCES 'application/json;charset=utf-8';
  TTALK "v2";

WSMETHOD GET getDetailVacation ;
  DESCRIPTION STR0038 ; //Retorna o detalhe do recibo de f�rias
  WSSYNTAX "/vacation/detail/{employeeId}/{vacationId}" ;
  PATH "/detail/{employeeId}/{vacationId}" ;
  PRODUCES 'application/json;charset=utf-8'

WSMETHOD GET vacationProcess ;
  DESCRIPTION STR0065 ; //Retorna o cabe�alho do recibo das f�rias em andamento
  WSSYNTAX "/vacation/process/{employeeId}" ;
  PATH "/process/{employeeId}" ;
  PRODUCES 'application/json;charset=utf-8';
  TTALK "v2";

WSMETHOD GET balanceAux ;
  DESCRIPTION STR0067 ; //Retorna a quantidade de dias de f�rias que o funcion�rio ter� conforme a data de in�cio das f�rias.
  WSSYNTAX "/vacation/balanceAux/{employeeId}/{initVacation}/{initPeriod}" ;
  PATH "/balanceAux/{employeeId}/{initVacation}/{initPeriod}" ;
  PRODUCES 'application/json;charset=utf-8';
  TTALK "v2";

//****************************** POSTs ***********************************
WSMETHOD POST postRequestVacation ;
  DESCRIPTION STR0010 ; //"Servi�o POST respons�vel pela inclus�o da solicita��o de f�rias."
  WSSYNTAX "/vacation/request/{employeeId}" ;
  PATH "/vacation/request/{employeeId}" ;
  PRODUCES 'application/json;charset=utf-8';
  TTALK "v2";

//****************************** PUTs ***********************************
WSMETHOD PUT putRequestVacation ;
  DESCRIPTION STR0011 ; //"Servi�o PUT respons�vel pela edi��o da solicita��o de f�rias."
  WSSYNTAX "/vacation/request/{employeeId}" ;
  PATH "/request/{employeeId}" ;
  PRODUCES 'application/json;charset=utf-8';
  TTALK "v2";

//****************************** DELETEs ***********************************
WSMETHOD DELETE delRequestVacation ;
  DESCRIPTION STR0012 ; //"Servi�o DEL respons�vel pela exclus�o da solicita��o de f�rias."
  WSSYNTAX "/vacation/request/{employeedId}/{vacationId}" ;
  PATH "/request/{employeedId}/{vacationId}" ;
  PRODUCES 'application/json;charset=utf-8'

END WSRESTFUL


// -------------------------------------------------------------------
// GET - Retorna os dados de f�rias do per�odo aquisitivo aberto
// SRF (F�rias confirmadas do per�odo em aberto)
// RH3 (Solicita��o de F�rias apenas em processo de aprova��o)
//
// retorna estrutura "vacationInfoResponse"
// -- hasNext
// -- Array of vacationInfo
// -------------------------------------------------------------------
WSMETHOD GET getInfoVacation WSREST Vacation

Local nDiaSolFer     := SuperGetMv("MV_DSOLFER",,30)
Local cDia2501     := ""
Local oItem        := JsonObject():New()
Local oVac         := JsonObject():New()
Local cQuery       := GetNextAlias()
Local aData        := {}
Local aPeriod      := {}
Local aDadosSRH    := {}
Local dDataIniPer  := cToD(" / / ")
Local dDataFimPer  := cToD(" / / ")
Local dDtProg      := cToD(" / / ")
Local dRFDataFim   := cToD(" / / ")
Local dDate        := dDataBase
Local aDataLogin   := {}
Local lProgFer     := .F.
Local lExistSRH    := .F.
Local lDemit       := .F.
Local lHabil       := .T.
Local lProjSRF     := .F.
Local lMrhFerp     := .T.
Local lReq13o      := .F.
Local lDiasProj    := .F.
Local nDiasSRH     := 0
Local nDMes12      := 0
Local nDMes01      := 0
Local nAboSRH      := 0
Local nDiasSolic   := 0
Local nAboProg     := 0
Local nQtdRFxRH    := 0
Local nReqs        := 0
Local nI           := 0
Local nX           := 0
Local nFer         := 0
Local nTotalFal    := 0
Local nDescFal     := 0
Local nDiasDir	    := 0
Local nDFerias     := 0
Local nDiasFer     := 0
Local nDiasAbo     := 0
Local nDiasSub     := 0
Local nPerc13      := 0
Local nFaltas      := 0
Local nDFerProp    := 0
Local nDFerVenc    := 0
Local nCount       := 0
Local cIdFer       := ""
Local cJson        := ""
Local cToken       := ""
Local cKeyId       := ""
Local cMatSRA      := ""
Local cBranchVld   := ""
Local cLogin       := ""
Local cRD0Cod      := ""
Local cDtaProg     := ""
Local cStatusFer   := ""
Local cStatusLab   := ""
Local cDtFimFer    := ""
Local cDtIniFer    := ""
Local cSRFtab      := ""
Local cSRAtab      := ""
Local cEmpSRA      := cEmpAnt
Local nLenParms    := Len(::aURLParms)
Local aQryParam    := Self:aQueryString
Local aOcurances   := {}
Local aOcurAux     := {}
Local aDateGMT     := {}
Local cDtConv      := ""
Local cRoutine     := "W_PWSA100A.APW" //F�rias.

::SetHeader('Access-Control-Allow-Credentials' , "true")
cToken     := Self:GetHeader('Authorization')
cKeyId  	  := Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len(aDataLogin) > 0
   cMatSRA    := aDataLogin[1]
   cLogin     := aDataLogin[2]
   cRD0Cod    := aDataLogin[3]
   cBranchVld := aDataLogin[5]
   lDemit     := aDataLogin[6]
EndIf

lMrhFerp := SuperGetMv("MV_MRHFERP",,.T., cBranchVld) // Par�metro para verificar se ser� permitido solicitar f�rias proporcionais.

/* Cria��o do par�metro espec�fico para o cliente Uniforte.
   Esse par�metro n�o ser� documentado e n�o dever� ser compartilhado com outros clientes.
   No cen�rio da Uniforte eles n�o utilizam a solicita��o de f�rias, mas somente a programa��o manualmente via SRF.
   Caso o par�metro esteja com .T., o MeuRH verificar� o conteudo do par�metro MV_DIA2501
   Caso o MV_DIA2501 esteja ativado, ir� projetar a data fim das f�rias no card de f�rias programadas.
   Ex:
   Inic�o F�rias = 21/12/2020
   Dias de F�rias = 10 dias.
   MV_DIA2501 = 24/12, 25/12, 31/12, 01/01.
   Fim F�rias = 03/01/2021.
*/
lProjSRF  := SuperGetMv("MV_PROJSRF",,.F.,cBranchVld) // Busca o conte�do do par�metro conforme a filial do funcion�rio.
If lProjSRF
   cDia2501  := SuperGetMv("MV_DIA2501",,"N",cBranchVld) // Busca o conte�do do par�metro conforme a filial do funcion�rio.
EndIf

//Obtem a data do queryparam que existe apenas na automa��o de testes
For nX := 1 To Len( aQryParam )
   If UPPER(aQryParam[nX,1]) == "DDATEROBOT"
      dDate := sToD( aQryParam[nX,2] )
   EndIf
Next

//avalia solicitante e destino da requisi��o 
If nLenParms > 0 .And. !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2])
   aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
   If Len(aIdFunc) > 1
      If cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2]
         //Valida Permissionamento
         fPermission(cBranchVld, cLogin, cRD0Cod, "vacation", @lHabil)
         If !lHabil .Or. lDemit
            SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
            Return (.F.)  
         EndIf
      Else
         //Valida Permissionamento
         fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementVacation", @lHabil)
         If !lHabil .Or. lDemit
            SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
            Return (.F.)
         //valida se o solicitante da requisi��o pode ter acesso as informa��es
         ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
            cBranchVld	:= aIdFunc[1]
            cMatSRA		:= aIdFunc[2]
            cEmpSRA     := aIdFunc[3]
         Else
            SetRestFault(400, EncodeUTF8( STR0064 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
            Return (.F.)
         EndIf	
      EndIf
   EndIf
Else
   //Valida Permissionamento
   fPermission(cBranchVld, cLogin, cRD0Cod, "vacation", @lHabil)
   If !lHabil .Or. lDemit
      SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
      Return (.F.)  
   EndIf
EndIF


If !Empty(cBranchVld) .And. !Empty(cMatSRA)

   cSRFtab := "%" + RetFullName("SRF", cEmpSRA) + "%"
   cSRAtab := "%" + RetFullName("SRA", cEmpSRA) + "%"

	//Busca f�rias programadas e confirmadas
	//Status do Periodo de Ferias (1=Ativo / 2=Prescrito / 3-Pago)
	BEGINSQL ALIAS cQuery
        COLUMN RF_DATABAS AS DATE
        COLUMN RF_DATAINI AS DATE
        COLUMN RF_DATINI2 AS DATE
        COLUMN RF_DATINI3 AS DATE
        COLUMN RF_DATAFIM AS DATE
        COLUMN RA_ADMISSA AS DATE
        	      
		SELECT 
			SRA.RA_ADMISSA,
			SRF.RF_FILIAL,
			SRF.RF_MAT,
			SRF.RF_DATABAS,
			SRF.RF_DATAFIM,
			SRF.RF_DATAINI,
			SRF.RF_DATINI2,
			SRF.RF_DATINI3,
			SRF.RF_DFEPRO1,
			SRF.RF_DFEPRO2,
			SRF.RF_DFEPRO3,
			SRF.RF_DABPRO1,
			SRF.RF_DABPRO2,
			SRF.RF_DABPRO3,
			SRF.RF_PERC13S, 
			SRF.RF_DFERVAT, 
			SRF.RF_DFERAAT,
			SRF.RF_DFERANT, 
			SRF.RF_DVENPEN,
			SRF.RF_DFALAAT,
			SRF.RF_DFALVAT,
			SRF.R_E_C_N_O_
		FROM 
			%exp:cSRFtab% SRF
		INNER JOIN 
			%exp:cSRAtab% SRA
		ON 
			SRF.RF_FILIAL = SRA.RA_FILIAL AND
			SRF.RF_MAT    = SRA.RA_MAT 
		WHERE 
			SRF.RF_FILIAL = %Exp:cBranchVld% AND 
			SRF.RF_MAT    = %Exp:cMatSRA%    AND
			SRF.RF_STATUS = '1'              AND
			SRF.%NotDel%
        ORDER BY SRF.RF_DATABAS 			
	ENDSQL
   SetMnemonicos( xFilial("RCA",cBranchVld) , Nil , .T.)
   fMRhTabFer(cBranchVld, cMatSRA, @nDiasDir, , cEmpSRA)
	
   While (cQuery)->(!Eof())

      aPeriod := PeriodConcessive( dtos((cQuery)->RF_DATABAS) , dtos((cQuery)->RF_DATAFIM) )
      //varinfo("aPeriod: ",aPeriod)

      dDataIniPer := aPeriod[1]
      dDataFimPer := aPeriod[2] - nDiaSolFer
      
      //============================================= 
      //Busca solicita��es f�rias em andamento na RH3 do usu�rio recebido diretamente na rota da url	
      //1=Em processo de aprova��o;2=Atendida;3=Reprovada;4=Aguardando Efetiva��o do RH;5=Aguardando Aprova��o do RH
      aOcurAux   := {}
      aOcurances := {}
      GetVacationWKF(@aOcurances, cMatSRA, cBranchVld, cMatSRA, cBranchVld, cEmpSRA, "'1','4'") 

      nDiasSolic := 0
      nAboProg   := 0
      nQtdRFxRH  := 0      
      lDiasProj  := .F.

      If Len(aOcurances) > 0 
         //inclui registro no array principal
         For nI := 1  To Len(aOcurances)
            If STOD(aOcurances[nI,21]) == (cQuery)->RF_DATABAS
               oVac                    := JsonObject():New() 
               oVac["days"]            := aOcurances[nI][12]                           //Dias de f�rias
               oVac["status"]          := "approving"                                  //"approved" "approving" "reject" "empty" "closed"

               oVac["initVacation"]    := Substr(aOcurances[nI][5],7,4) + "-" + ;
                                          Substr(aOcurances[nI][5],4,2) + "-" + ;
                                          Substr(aOcurances[nI][5],1,2)                //Data de in�cio das f�rias
               oVac["endVacation"]     := Substr(aOcurances[nI][6],7,4) + "-" + ;
                                          Substr(aOcurances[nI][6],4,2) + "-" + ;
                                          Substr(aOcurances[nI][6],1,2)                //Data final das f�rias

               If !empty(aOcurances[nI][21]) .and. !empty(aOcurances[nI][22])
                  oVac["initPeriod"]   := Substr(aOcurances[nI][21],1,4) + "-" + ;
                                          Substr(aOcurances[nI][21],5,2) + "-" + ;
                                          Substr(aOcurances[nI][21],7,2)               //Data de in�cio das f�rias
                  oVac["endPeriod"]    := Substr(aOcurances[nI][22],1,4) + "-" + ;
                                          Substr(aOcurances[nI][22],5,2) + "-" + ;
                                          Substr(aOcurances[nI][22],7,2)               //Data final das f�rias
               EndIf

               If alltrim(aOcurances[nI][17]) == "4"
                  oVac["statusLabel"]  := EncodeUTF8(STR0005)                           //"Aguardando aprova��o do RH"
               Else
                  oVac["statusLabel"]  := EncodeUTF8(STR0004)                           //"Em processo de aprova��o"
               EndIf
               oVac["id"]              := "RH3"              +"|" +;
                                          cBranchVld         +"|" +;
                                          cMatSRA            +"|" +;              
                                          aOcurances[nI][15] +"|" +;              
                                          alltrim( str(aOcurances[nI][16]) )            //Identificador de solicita��es
               oVac["vacationBonus"]   := aOcurances[nI][7]                             //Dias de abono 
               oVac["advance"]         := 0                                             //Adiantamento do 13
               oVac["hasAdvance"]      := aOcurances[nI][14]                            //Se foi solicitado Adiantamento do 13

               //Avalia possibilidade de altera��o ou exclus�o das solicita��es
               oVac["canAlter"]        := .F.
               oVac["limitDate"]       := ""                                            //Data limite para solicita��o de f�rias
               oVac["balance"]         := 0
               
               // Se for a filial+matricula logada for a mesma filial+matricula que iniciou a solicita��o de f�rias
               // E possuir somente 2 hist�ricos, ou seja, nenhuma aprova��o, ent�o permite alterar..
               If aDataLogin[5] == aOcurances[nI][23] .And. aDataLogin[1] == aOcurances[nI][24] .And. Val( GetRGKSeq( aOcurances[nI][15] , .T.) ) == 2

                  nReqs ++                                     //Numero de solicitacoes que podem ser alteradas
                  oVac["canAlter"]     := .T.
                  oVac["isUpdated"]    := .F.
                  oVac["balance"]      := aOcurances[nI][12] + aOcurances[nI][7]  //Dias de f�rias + Abono da solicita��o original

                  aDateGMT             := {}
                  aDateGMT             := LocalToUTC( dtos(dDataFimPer), "12:00:00"  )
                  cDtConv              := DTOS( dDataFimPer - nDiasDir + 1)
                  oVac["limitDate"]    := Substr(cDtConv,1,4) + "-" + ;
                                          Substr(cDtConv,5,2) + "-" + ;
                                          Substr(cDtConv,7,2)  //Data limite para solicita��o de f�rias
               EndIf
               nDiasSolic += ( aOcurances[nI,12] + aOcurances[nI,7] )
               Aadd(aData,oVac)
            EndIf
         Next nI
      EndIf

      //Se tiver ferias calculadas obtem os dados do cabecalho de Ferias.
      //Caso n�o tenha um ano de admiss�o, n�o envia data fim na busca do cabecalho
      dRFDataFim := If(Date() - (cQuery)->RA_ADMISSA > 365, (cQuery)->RF_DATAFIM, Nil)
      aDadosSRH  := fGetSRH( cBranchVld, cMatSRA, (cQuery)->RF_DATABAS, dRFDataFim,,, cEmpSRA )
      lExistSRH  := Len(aDadosSRH) > 0
      
      //Status padrao das programacoes � aprovado. Altera para calculado (calculated) somente quando existe calculo
      cStatusFer := "approved"
      cStatusLab := EncodeUTF8(STR0009) //"Confirmada"

      //============================================= 
      //********************* Avalia programa��es SRF
      lReq13o  := .F.
      lProgFer := .F.
      nDMes12  := 0
      nDMes01  := 0

      //reinicia vari�veis.
      dDtProg   := cToD(" / / ")
      cDtIniFer := ""
      cDtFimFer := ""
      nDiasFer  := 0
      nDiasAbo  := 0
      nPerc13   := 0

        //Carrega o primeiro per�odo de f�rias confirmados
      If !Empty((cQuery)->RF_DATAINI)

         cIdFer := "SRF" +"|"+ cBranchVld +"|"+ cMatSRA +"|"+ dtos((cQuery)->RF_DATABAS) +"|"+ dtos((cQuery)->RF_DATAINI) +"|"+ Alltrim(str((cQuery)->R_E_C_N_O_))
         If lProjSRF
            fChkLicRem( (cQuery)->RF_DATAINI, (cQuery)->RF_DATAINI + (cQuery)->RF_DFEPRO1 - 1 , @nDMes12, @nDMes01, cDia2501)
         EndIf

         If lExistSRH
            If ( nFer := Ascan( aDadosSRH, {|x| ( x[1] == DTOS((cQuery)->RF_DATAINI) ) } ) ) > 0 
               cStatusFer  := "calculated"
               cStatusLab  := EncodeUTF8(STR0027)    //"Em processo de c�lculo"
               cDtIniFer   := aDadosSRH[nFer][1]
               nDiasFer    := aDadosSRH[nFer][2]
               cDtFimFer   := aDadosSRH[nFer][3]  
               nDiasAbo    := aDadosSRH[nFer][6]
               nPerc13     := aDadosSRH[nFer][7]
               nQtdRFxRH   += nDiasFer + nDiasAbo              
               cIdFer      := "SRH" +"|"+ cBranchVld +"|"+ cMatSRA +"|"+ aDadosSRH[nFer,4] +"|"+ aDadosSRH[nFer,1] +"|"+ aDadosSRH[nFer,8]
            EndIf
         EndIf

         //Quando existe 13o e mais de uma programacao verifica se teve origem em alguma requisicao
         If (cQuery)->RF_PERC13S > 0 .And. ( !Empty((cQuery)->RF_DATINI2) .Or. !Empty((cQuery)->RF_DATINI3) )
            GetVacationWKF(@aOcurAux, cMatSRA, cBranchVld, cMatSRA, cBranchVld, cEmpSRA, "'2'")

            If Len(aOcurAux) > 0               
               ASORT( aOcurAux,,, { |x,y| x[5] > y[5] } )

               For nX := 1 to Len( aOcurAux )
                  dDtAux := CTOD(aOcurAux[nX,5])
                  If aOcurAux[nX,14] .And. (dDtAux == (cQuery)->RF_DATAINI .Or. dDtAux == (cQuery)->RF_DATINI2 .Or. dDtAux == (cQuery)->RF_DATINI3)
                     lReq13o := .T.
                     dDtProg := dDtAux
                     Exit
                  EndIf
               Next nX

            EndIf
         EndIf

         If (cQuery)->RF_DATAINI > dDate		

            oVac                    := JsonObject():New()
            oVac["balance"]         := 0
            oVac["days"]            := If( nDiasFer > 0, nDiasFer, (cQuery)->RF_DFEPRO1 )  //Dias de f�rias
            oVac["status"]          := cStatusFer                                         //"approved" "approving" "reject" "empty" "closed"

            cDtConv                 := If( !Empty(cDtIniFer), cDtIniFer, dTos( (cQuery)->RF_DATAINI ) ) 
            oVac["initVacation"]    := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                                //Data de in�cio das f�rias

            cDtConv                 := If( !Empty(cDtFimFer), cDtFimFer, dTos( (cQuery)->RF_DATAINI + nDMes12 + nDMes01 + ((cQuery)->RF_DFEPRO1 - 1) ) ) 
            oVac["endVacation"]     := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                                //Data final das f�rias

            cDtConv                 := dTos( (cQuery)->RF_DATABAS ) 
            oVac["initPeriod"]      := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                               //Inicio do per�odo aquisitivo  "2018-02-01T00:00:00Z"

            cDtConv                 := dTos( (cQuery)->RF_DATAFIM ) 
            oVac["endPeriod"]       := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                               //Final do per�odo aquisitivo   "2019-01-31T00:00:00Z"

            oVac["statusLabel"]     := cStatusLab		                                   //"Confirmada" "Calculada"
            oVac["id"]              := cIdFer                                             //Identificador de f�rias

            oVac["vacationBonus"]   := If (nDiasAbo > 0 , nDiasAbo, (cQuery)->RF_DABPRO1 ) //Dias de abono

            If lReq13o
               If dDtProg == (cQuery)->RF_DATAINI
                  oVac["advance"]      := If (nPerc13 > 0, nPerc13, (cQuery)->RF_PERC13S )  //optional - Adiantamento do 13
                  oVac["hasAdvance"]   := .T.                                               //Se foi solicitado Adiantamento do 13
               Else
                  oVac["advance"]      := 0
                  oVac["hasAdvance"]   := .F.
               EndIf
            Else
               oVac["advance"]         := If (nPerc13 > 0, nPerc13, (cQuery)->RF_PERC13S )    //optional - Adiantamento do 13
               oVac["hasAdvance"]      := If ( oVac["advance"] > 0, .T., .F. )               //Se foi solicitado Adiantamento do 13
            EndIf

            oVac["limitDate"]       := ""                                                 //Data limite para solicita��o de f�rias
            oVac["canAlter"]        := .F.                                                //Verifica se a solicita��o de f�rias pode ser editada e exclu�da de acordo com o status
            Aadd(aData,oVac)

            lProgFer := .T.
         EndIf
		EndIf
      If ( nDiasFer + nDiasAbo ) > 0
         nDiasSolic += nDiasFer + nDiasAbo
         nAboProg   := nDiasAbo
      Else
         nDiasSolic += (cQuery)->RF_DFEPRO1 + (cQuery)->RF_DABPRO1
         nAboProg   := (cQuery)->RF_DABPRO1
      EndIf

      //Reinicia vari�veis.
      cDtIniFer := ""
      cDtFimFer := ""
      nDiasFer  := 0
      nDiasFer  := 0
      nDiasAbo  := 0
      nPerc13   := 0
      cStatusFer := "approved"
      cStatusLab := EncodeUTF8(STR0009) //"Confirmada"
		
      //Carrega o segundo per�odo de f�rias confirmado
      If !Empty((cQuery)->RF_DATINI2)

         cIdFer := "SRF" +"|"+ cBranchVld +"|"+ cMatSRA +"|"+ dtos((cQuery)->RF_DATABAS) +"|"+ dtos((cQuery)->RF_DATINI2) +"|"+ Alltrim(str((cQuery)->R_E_C_N_O_))
         If lProjSRF
            fChkLicRem( (cQuery)->RF_DATINI2, (cQuery)->RF_DATINI2 + (cQuery)->RF_DFEPRO2 - 1 , @nDMes12, @nDMes01, cDia2501)
         EndIf

         If lExistSRH
            If ( nFer := Ascan( aDadosSRH, {|x| ( x[1] == DTOS((cQuery)->RF_DATINI2) ) } ) ) > 0 
               cStatusFer   := "calculated"
               cStatusLab   := EncodeUTF8(STR0027)    //"Em processo de c�lculo"
               cDtIniFer    := aDadosSRH[nFer][1]
               nDiasFer     := aDadosSRH[nFer][2]
               cDtFimFer    := aDadosSRH[nFer][3]
               nDiasAbo     := aDadosSRH[nFer][6]
               nPerc13      := aDadosSRH[nFer][7]
               nQtdRFxRH    += nDiasFer + nDiasAbo   
               cIdFer       := "SRH" +"|"+ cBranchVld +"|"+ cMatSRA +"|"+ aDadosSRH[nFer,4] +"|"+ aDadosSRH[nFer,1] +"|"+ aDadosSRH[nFer,8]
            EndIf
         EndIf

         If (cQuery)->RF_DATINI2 > dDate

            oVac                    := JsonObject():New()
            oVac["balance"]         := 0
            oVac["days"]            := If( nDiasFer > 0, nDiasFer, (cQuery)->RF_DFEPRO2 )                               //Dias de f�rias
            oVac["status"]          := cStatusFer                                         //"approved" "approving" "reject" "empty" "closed"

            cDtConv                 := If( !Empty(cDtIniFer), cDtIniFer, dTos( (cQuery)->RF_DATINI2 ) )
            oVac["initVacation"]    := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                                //Data de in�cio das f�rias

            cDtConv                 := If( !Empty(cDtFimFer), cDtFimFer , dTos( (cQuery)->RF_DATINI2 + nDMes12 + nDMes01 + ((cQuery)->RF_DFEPRO2 - 1) ) )
            oVac["endVacation"]     := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                                //Data final das f�rias

            cDtConv                 := dTos( (cQuery)->RF_DATABAS ) 
            oVac["initPeriod"]      := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                                //Inicio do per�odo aquisitivo  "2018-02-01T00:00:00Z"

            cDtConv                 := dTos( (cQuery)->RF_DATAFIM ) 
            oVac["endPeriod"]       := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                                //Final do per�odo aquisitivo   "2019-01-31T00:00:00Z"

            oVac["statusLabel"]     := cStatusLab		                                   //"Confirmada" "Calculada"
            oVac["id"]              := cIdFer                                             //Identificador de f�rias

            oVac["vacationBonus"]   := If (nDiasAbo > 0 , nDiasAbo, (cQuery)->RF_DABPRO2 )    //Dias de abono

            If lReq13o
               If dDtProg == (cQuery)->RF_DATINI2
                  oVac["advance"]      := If (nPerc13 > 0, nPerc13, (cQuery)->RF_PERC13S )    //optional - Adiantamento do 13
                  oVac["hasAdvance"]   := .T.                                                //Se foi solicitado Adiantamento do 13
               Else
                  oVac["advance"]      := 0
                  oVac["hasAdvance"]   := .F.
               EndIf
            Else
               oVac["advance"]         := If (nPerc13 > 0, nPerc13, (cQuery)->RF_PERC13S )    //optional - Adiantamento do 13
               oVac["hasAdvance"]      := If ( oVac["advance"] > 0, .T., .F. )               //Se foi solicitado Adiantamento do 13
            EndIf

            oVac["limitDate"]       := ""                                                 //Data limite para solicita��o de f�rias
            oVac["canAlter"]        := .F.                                                //Verifica se a solicita��o de f�rias pode ser editada e exclu�da de acordo com o status
            Aadd(aData,oVac)

            lProgFer := .T.
         EndIf
      EndIf
      If ( nDiasFer + nDiasAbo ) > 0
         nDiasSolic += nDiasFer + nDiasAbo
         nAboProg   := nDiasAbo
      Else
         nDiasSolic += (cQuery)->RF_DFEPRO2 + (cQuery)->RF_DABPRO2
         nAboProg   := (cQuery)->RF_DABPRO2
      EndIf

      //Reinicia vari�veis.
      cDtIniFer := ""
      cDtFimFer := ""
      nDiasFer  := 0
      nDiasAbo  := 0
      nPerc13   := 0
      cStatusFer := "approved"
      cStatusLab := EncodeUTF8(STR0009) //"Confirmada"

      //Carrega o terceiro per�odo de f�rias confirmado
      If !Empty((cQuery)->RF_DATINI3)

         cIdFer := "SRF" +"|"+ cBranchVld +"|"+ cMatSRA +"|"+ dtos((cQuery)->RF_DATABAS) +"|"+ dtos((cQuery)->RF_DATINI3) +"|"+ Alltrim(str((cQuery)->R_E_C_N_O_))
         If lProjSRF
            fChkLicRem( (cQuery)->RF_DATINI3, (cQuery)->RF_DATINI3 + (cQuery)->RF_DFEPRO3 - 1 , @nDMes12, @nDMes01, cDia2501)
         EndIf
        
         If lExistSRH
            If ( nFer := Ascan( aDadosSRH, {|x| ( x[1] == DTOS((cQuery)->RF_DATINI3) ) } ) ) > 0 
               cStatusFer 	:= "calculated"
               cStatusLab	:= EncodeUTF8(STR0027)    //"Em processo de c�lculo"
               cDtIniFer   := aDadosSRH[nFer][1] // Data inicio das f�rias
               nDiasFer    := aDadosSRH[nFer][2] // Quantidade de dias de f�rias.
               cDtFimFer   := aDadosSRH[nFer][3] // Data fim das f�rias.
               nDiasAbo    := aDadosSRH[nFer][6] // Quantidade de abono.
               nPerc13     := aDadosSRH[nFer][7] // Percentual 13.
               nQtdRFxRH	+= nDiasFer + nDiasAbo
               cIdFer      := "SRH" +"|"+ cBranchVld +"|"+ cMatSRA +"|"+ aDadosSRH[nFer,4] +"|"+ aDadosSRH[nFer,1] +"|"+ aDadosSRH[nFer,8]
            EndIf
         EndIf

         If (cQuery)->RF_DATINI3 > dDate

            oVac                    := JsonObject():New()
            oVac["balance"]         := 0
            oVac["days"]            := If( nDiasFer > 0 , nDiasFer, (cQuery)->RF_DFEPRO3 )                               //Dias de f�rias
            oVac["status"]          := cStatusFer                                         //"approved" "approving" "reject" "empty" "closed"

            cDtConv                 := If( !Empty(cDtIniFer), cDtIniFer, dTos( (cQuery)->RF_DATINI3 ) )
            oVac["initVacation"]    := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                                //Data de in�cio das f�rias

            cDtConv                 := If( !Empty(cDtFimFer), cDtFimFer, dTos( (cQuery)->RF_DATINI3 + nDMes12 + nDMes01 + ( (cQuery)->RF_DFEPRO3 - 1) ) ) 
            oVac["endVacation"]     := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                               //Data final das f�rias

            cDtConv                 := dTos( (cQuery)->RF_DATABAS ) 
            oVac["initPeriod"]      := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                               //Inicio do per�odo aquisitivo  "2018-02-01T00:00:00Z"

            cDtConv                 := dTos( (cQuery)->RF_DATAFIM ) 
            oVac["endPeriod"]       := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                               //Final do per�odo aquisitivo   "2019-01-31T00:00:00Z"

            oVac["statusLabel"]     := cStatusLab		                                   //"Confirmada" "Calculada"
            oVac["id"]              := cIdFer                                             //Identificador de f�rias

            oVac["vacationBonus"]   := If( nDiasAbo > 0, nDiasAbo, (cQuery)->RF_DABPRO3 )  //Dias de abono

            If lReq13o
               If dDtProg == (cQuery)->RF_DATINI3
                  oVac["advance"]      := If (nPerc13 > 0, nPerc13, (cQuery)->RF_PERC13S )    //optional - Adiantamento do 13
                  oVac["hasAdvance"]   := .T.                                               //Se foi solicitado Adiantamento do 13
               Else
                  oVac["advance"]      := 0
                  oVac["hasAdvance"]   := .F.
               EndIf
            Else
               oVac["advance"]         := If (nPerc13 > 0, nPerc13, (cQuery)->RF_PERC13S )    //optional - Adiantamento do 13
               oVac["hasAdvance"]      := If ( oVac["advance"] > 0, .T., .F. )               //Se foi solicitado Adiantamento do 13
            EndIf

            oVac["limitDate"]       := ""                                                 //Data limite para solicita��o de f�rias
            oVac["canAlter"]        := .F.                                                //Verifica se a solicita��o de f�rias pode ser editada e exclu�da de acordo com o status
            Aadd(aData,oVac)

            lProgFer := .T.
         EndIf
      EndIf
      If ( nDiasFer + nDiasAbo ) > 0
         nDiasSolic += nDiasFer + nDiasAbo
         nAboProg   := nDiasAbo
      Else
         nDiasSolic += (cQuery)->RF_DFEPRO3 + (cQuery)->RF_DABPRO3
         nAboProg   := (cQuery)->RF_DABPRO3
      EndIf


      /*  avaliar registros na SRH calculados com data de inicio posterior a data do sistema, 
         para que possa ser criado um card, caso n�o existam programa��es na SRF...
         al�m disso ser utilizado para abater do saldo dispon�vel de f�rias, prevendo que
         o fechamento ainda possa n�o ter sido realizado, atualizando os saldos na SRF  */
      nDiasSRH := 0
      nAboSRH  := 0
      cDtaProg := If( Empty((cQuery)->RF_DATAINI), "", dtos((cQuery)->RF_DATAINI) ) + "|" 
      cDtaProg += If( Empty((cQuery)->RF_DATINI2), "", dtos((cQuery)->RF_DATINI2) ) + "|"
      cDtaProg += If( Empty((cQuery)->RF_DATINI3), "", dtos((cQuery)->RF_DATINI3) ) + "|"
      
      For nX := 1 To Len( aDadosSRH )

         //Considera as Ferias se nao houver programacao, ou se houver ferias mas com data de inicio diferente da programacao 
         If ( STOD(aDadosSRH[nX,1]) >= dDate .And. (!lProgFer .Or. !aDadosSRH[nX,1] $ cDtaProg ) ) 
            oVac                    := JsonObject():New() 
            oVac["balance"]         := 0                      //Saldo dispon�vel
            oVac["days"]            := aDadosSRH[nX,2]        //Dias de f�rias
            oVac["status"]          := "calculated"           //"approved" "approving" "reject" "empty" "closed" "calculated"
            
            oVac["initVacation"]    := Substr(aDadosSRH[nX,1],1,4) + "-" + ;
                                       Substr(aDadosSRH[nX,1],5,2) + "-" + ;
                                       Substr(aDadosSRH[nX,1],7,2)         //Data de in�cio das f�rias
            cDtConv                 := aDadosSRH[nX,3]
            oVac["endVacation"]     := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                //Data final das f�rias

            oVac["initPeriod"]      := Substr(aDadosSRH[nX,4],1,4) + "-" + ;
                                       Substr(aDadosSRH[nX,4],5,2) + "-" + ;
                                       Substr(aDadosSRH[nX,4],7,2)        //Inicio do per�odo aquisitivo  "2018-02-01T00:00:00Z"
            cDtConv                 := aDadosSRH[nX,5] 
            oVac["endPeriod"]       := Substr(cDtConv,1,4) + "-" + ;
                                       Substr(cDtConv,5,2) + "-" + ;
                                       Substr(cDtConv,7,2)                //Final do per�odo aquisitivo   "2019-01-31T00:00:00Z"
            
            oVac["statusLabel"]     := EncodeUTF8(STR0027)    //"Em processo de c�lculo"
            oVac["id"]              := "SRH"              +"|" +;
                                       cBranchVld         +"|" +;
                                       cMatSRA            +"|" +;              
                                       aDadosSRH[nX,4]    +"|" +;              
                                       aDadosSRH[nX,1]    +"|" +;              
                                       aDadosSRH[nX,8]        //Identificador de f�rias
            oVac["vacationBonus"]   := aDadosSRH[nX,6]        //Dias de abono
            oVac["advance"]         := aDadosSRH[nX,7]        //optional - Adiantamento do 13
            If aDadosSRH[nX,7]  > 0           
               oVac["hasAdvance"]  := .T.                    //Se foi solicitado Adiantamento do 13
            Else
               oVac["hasAdvance"]  := .F.                    //Se foi solicitado Adiantamento do 13
            EndIf    
            oVac["limitDate"]       := ""                    //Data limite para solicita��o de f�rias
            oVac["canAlter"]        := .F.                   //Verifica se a solicita��o de f�rias pode ser editada e exclu�da de acordo com o status
            Aadd(aData,oVac)
         EndIf

         nDiasSRH := nDiasSRH + aDadosSRH[nX,2] //Dias de ferias 
         nAboSRH  := nAboSRH  + aDadosSRH[nX,6] //Dias de abono pecuniario

      Next nX
      
      /* Carrega o card para "solicitar f�rias" em virtude de saldo pendente
         apenas para o primeiro per�odo aquisitivo em aberto, para que as 
         solicita��es dos saldos sejam feitos na sequencia
         
         exemplo:
         DATABAS   DATAFIM   DIASDIR(dias vencidos)  DFERVAT(dias vencidos)  DFERAAT(dias proporcionais)
         20180210  20190209     30                     30                       0
         20190210  20200209     30                     0                       10
      */
      //Considera o abono do calculo somente quando ele nao consta na programacao de ferias
      If nAboProg == 0 .And. nAboSRH > 0
         nDiasSRH += nAboSRH
      EndIf

      nDFerVenc := (cQuery)->RF_DFERVAT - (nDiasSolic + nDiasSRH - nQtdRFxRH)
      nDFerProp := (cQuery)->RF_DFERAAT - (nDiasSolic + nDiasSRH - nQtdRFxRH)
      If ( nDFerVenc > 0 .or. (lMrhFerp .And. nDiasDir > (nDiasSolic + nDiasSRH - nQtdRFxRH)) )
         
         nCount ++
         oVac := JsonObject():New()
         If cPaisLoc $ ("BRA")
            // F�rias Vencidas Ou F�rias a Vencer
            nDFerias := If ( (cQuery)->RF_DFERVAT <= 0, (cQuery)->RF_DFERAAT, (cQuery)->RF_DFERVAT )
            If cPaisLoc = "BRA"
               nDFerias := If (nDFerias>nDiasDir,nDiasDir,nDFerias)
            EndIf

            //Zera as faltas para carregar a cada per�odo
            nFaltas := 0
            If (cQuery)->RF_DFERVAT < nDiasDir // Dias F.Venc. < Dias de Direito
               If (cQuery)->RF_DFERVAT > 0
                  nFaltas  := (cQuery)->RF_DFALVAT // D.Falt.Venc.
               Else
                  nFaltas  := (cQuery)->RF_DFALAAT
               EndIf
            Else
               nFaltas  := (cQuery)->RF_DFALVAT // D.Falt.Venc.
            EndIf
            // Carrega Faltas da SRC em caso de f�rias proporcionais.
            If (cQuery)->RF_DFERAAT > 0
               nFaltas += fMRhGetFal(cBranchVld, cMatSRA, cEmpSRA)
            EndIf
            nTotalFal := nFaltas
            TabFaltas(@nTotalFal)

            nDescFal := If( nDFerias < nDiasDir, ((nTotalFal / 30) * nDFerias), nTotalFal )
         EndIf

         //Avalia se as ferias calculadas ja constavam na programacao (nQtdRFxRH). 
         //Neste caso, nao podemos considerar os dois valores senao os dias de ferias pendentes ficarao incorretos.           
         If (cQuery)->RF_DFERVAT > 0
            oVac["balance"]      := (cQuery)->RF_DFERVAT - (nDiasSolic + nDiasSRH - nQtdRFxRH) - nDescFal
            oVac["vacationProportional"] := .F.
         Else
            //Se nao tiver dias proporcionais mas o saldo do per�odo aquisitivo ainda tiver saldo
            //Apresenta o card com dias zerados para que seja poss�vel solicitar os dias restantes
            If lMrhFerp .And. nDFerProp <= 0 
               lDiasProj := (nDiasDir - (nDiasSolic + nDiasSRH - nQtdRFxRH) - nDescFal) > 0
            EndIf
            oVac["balance"]      := Max( ((cQuery)->RF_DFERAAT - (nDiasSolic + nDiasSRH - nQtdRFxRH) - nDescFal), 0 )
            oVac["vacationProportional"] := .T.
         EndIf
         
         oVac["status"]          := "empty"                                            //"approved" "approving" "reject" "empty" "closed"
         oVac["initVacation"]    := ""
         oVac["endVacation"]     := ""

         cDtConv                 := dTos( (cQuery)->RF_DATABAS ) 
         oVac["initPeriod"]      := Substr(cDtConv,1,4) + "-" + ;
                                    Substr(cDtConv,5,2) + "-" + ;
                                    Substr(cDtConv,7,2)                               //Inicio do per�odo aquisitivo  "2018-02-01T00:00:00Z"

         cDtConv                 := dTos( (cQuery)->RF_DATAFIM ) 
         oVac["endPeriod"]       := Substr(cDtConv,1,4) + "-" + ;
                                    Substr(cDtConv,5,2) + "-" + ;
                                    Substr(cDtConv,7,2)                               //Final do per�odo aquisitivo   "2019-01-31T00:00:00Z"

         oVac["id"]              := "SRF"                         +"|" +;
                                    cBranchVld                    +"|" +;
                                    cMatSRA                       +"|" +;              
                                    dtos((cQuery)->RF_DATABAS)    +"|" +;              
                                    dtos((cQuery)->RF_DATAFIM)    +"|" +;              
                                    alltrim(str((cQuery)->R_E_C_N_O_))                 //Identificador de f�rias
         oVac["hasAdvance"]      := .F.                                                //Se foi solicitado Adiantamento do 13

         //Na definicao da data limite considera os dias de direito com a deducao de faltas e dias j� pagos ou programados
         If (nDiasSolic + nDiasSRH) > 0 .Or. nQtdRFxRH > 0 .Or. nTotalFal > 0
            nDiasSub := nDiasDir - (nDiasSolic + nDiasSRH - nQtdRFxRH) - nTotalFal
         Else
            nDiasSub := nDiasDir
         EndIf
         
         dDataFimPer             := dDataFimPer - nDiasSub + 1
         cDtConv                 := DTOS( dDataFimPer )
         oVac["limitDate"]       := Substr(cDtConv,1,4) + "-" + ;
                                    Substr(cDtConv,5,2) + "-" + ;
                                    Substr(cDtConv,7,2)                                //Data limite para solicita��o de f�rias

         oVac["canAlter"]        := .F.                                               //Verifica se a solicita��o de f�rias pode ser editada e exclu�da de acordo com o status
         oVac["canRequest"]      := ( nCount == 1 ) 

         If oVac["balance"] > 0 .Or. lDiasProj 
            If nReqs > 0 .And. oVac["balance"] > 0
               fSetBalanceDays( @aData, oVac["balance"], oVac["initPeriod"] )
            EndIf
            Aadd(aData,oVac)
         EndIf
      EndIf 
      (cQuery)->( DbSkip() )
   EndDo
	
	(cQuery)->(DBCloseArea())		

ENDIF

oItem["hasNext"] := .F.
oItem["items"]   := aData

cJson := oItem:ToJson()
::SetResponse(cJson)

Return(.T.)


// ---------------------------------------------------------
// GET - Retorna o hist�rico de solicita��es de f�rias 
// SRH (F�rias processadas)
// RH3 (Solicita��es de F�rias reprovadas)
//
// retorna estrutura "vacationInfoResponse"
// -- hasNext
// -- Array of vacationInfo
// ---------------------------------------------------------
WSMETHOD GET getHistoryVacation WSREST Vacation

Local oItem         := JsonObject():New()
Local oVac          := JsonObject():New()
Local aData         := {}
Local aDataResult   := {}
Local aDataLogin    := {}
Local cQuery        := GetNextAlias()
Local cJson         := ""
Local cToken        := ""
Local cKeyId        := ""
Local cMatSRA       := ""
Local cBranchVld    := ""
Local cLogin        := ""
Local cRD0Cod       := ""
Local cSRHtab       := ""
Local cEmpSRA       := cEmpAnt
Local aOcurances    := {}
Local lMaisPaginas  := .F.
Local lHabil        := .T.
Local lDemit        := .F.
Local nI            := 0
Local nRegCount     := 0
Local nRegCountIni  := 0 
Local nRegCountFim  := 0
Local nLenParms     := Len(::aURLParms)
Local cRoutine     := "W_PWSA100A.APW" //F�rias.

DEFAULT Self:page     := "1"
DEFAULT Self:pageSize := "10"

Self:SetHeader('Access-Control-Allow-Credentials' , "true")
cToken     := Self:GetHeader('Authorization')
cKeyId  	  := Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len(aDataLogin) > 0
   cMatSRA    := aDataLogin[1]
   cLogin     := aDataLogin[2]
   cRD0Cod    := aDataLogin[3]
   cBranchVld := aDataLogin[5]
	lDemit     := aDataLogin[6]
EndIf

//Prepara o controle de paginacao
If Self:page == "1" .Or. Self:page == ""
  nRegCountIni := 1 
  nRegCountFim := val(Self:pageSize)
Else
  nRegCountIni := ( val(Self:pageSize) * (val(Self:Page) - 1)  ) + 1
  nRegCountFim := ( nRegCountIni + val(Self:pageSize) ) - 1
EndIf   

//avalia solicitante e destino da requisi��o 
If nLenParms > 0 .And. !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2])
   aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
   If Len(aIdFunc) > 1
      If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
         //Valida Permissionamento
         fPermission(cBranchVld, cLogin, cRD0Cod, "vacation", @lHabil)
         If !lHabil .Or. lDemit
            SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
            Return (.F.)  
         EndIf
      Else
         //Valida Permissionamento
         fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementVacation", @lHabil)
         If !lHabil .Or. lDemit
            SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
            Return (.F.)    
         //valida se o solicitante da requisi��o pode ter acesso as informa��es
         ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
            cBranchVld	:= aIdFunc[1]
            cMatSRA		:= aIdFunc[2]
            cEmpSRA     := aIdFunc[3]
         Else
            SetRestFault(400, EncodeUTF8( STR0064 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
            Return (.F.) 
         EndIf	
      EndIf
   EndIf
Else
   //Valida Permissionamento
   fPermission(cBranchVld, cLogin, cRD0Cod, "vacation", @lHabil)
   If !lHabil .Or. lDemit
      SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
      Return (.F.)  
   EndIf
EndIF


If !Empty(cBranchVld) .And. !Empty(cMatSRA)

   cSRHtab := "%" + RetFullName("SRH", cEmpSRA) + "%"

   //================================== 
   //Avalia as f�rias calculadas na SRH
	BEGINSQL ALIAS cQuery
        COLUMN RH_DATABAS AS DATE
        COLUMN RH_DBASEAT AS DATE
        COLUMN RH_DATAINI AS DATE
        COLUMN RH_DATAFIM AS DATE
	
		SELECT 
			SRH.RH_DATABAS,
			SRH.RH_DBASEAT,
			SRH.RH_DATAINI,
			SRH.RH_DATAFIM,
			SRH.RH_DABONPE,
			SRH.RH_ACEITE,
			SRH.RH_DFERIAS,
			SRH.RH_DFERVEN,
			SRH.RH_PERC13S,
			SRH.R_E_C_N_O_,
			SRH.RH_FILIAL,
			SRH.RH_MAT
		FROM 
         %exp:cSRHtab% SRH
		WHERE 
			SRH.RH_FILIAL   = %Exp:cBranchVld% AND 
			SRH.RH_MAT      = %Exp:cMatSRA %   AND
			SRH.%NotDel%
		ORDER BY
			SRH.RH_DATABAS DESC		 
	ENDSQL

	While (cQuery)->(!Eof())
	
          //F�rias calculadas mais que a data de inicio ainda n�o ocorreu, ser�o 
          //disponibilizadas no card do servi�o "/vacation/info" como confirmadas 
          If (cQuery)->RH_DATAINI <= dDataBase           
	
             oVac                    := JsonObject():New() 
             oVac["balance"]         := (cQuery)->RH_DFERVEN                          //Saldo dispon�vel
             oVac["days"]            := (cQuery)->RH_DFERIAS                          //Dias de f�rias
             oVac["status"]          := "closed"                                      //"approved" "approving" "reject" "empty" "closed"
             oVac["initVacation"]    := formatGMT( DTOC( (cQuery)->RH_DATAINI) )      //Data inicial das f�rias
             oVac["endVacation"]     := formatGMT( DTOC( (cQuery)->RH_DATAFIM) )      //Data final das f�rias
             oVac["initPeriod"]      := formatGMT( DTOC( (cQuery)->RH_DATABAS) )      //Inicio do per�odo aquisitivo  "2018-02-01T00:00:00Z"
             oVac["endPeriod"]       := formatGMT( DTOC( (cQuery)->RH_DBASEAT) )      //Final do per�odo aquisitivo   "2019-01-31T00:00:00Z"

             If (cQuery)->RH_DATAFIM < dDataBase           
                oVac["statusLabel"]  := EncodeUTF8(STR0006)                           //"Finalizadas"
             Else  
                oVac["statusLabel"]  := EncodeUTF8(STR0007)                           //"Em Andamento"
             EndIf

             oVac["id"]              := "SRH"                         +"|" +;
                                        (cQuery)->RH_FILIAL           +"|" +;
                                        (cQuery)->RH_MAT              +"|" +;              
                                        dtos((cQuery)->RH_DATABAS)    +"|" +;              
                                        dtos((cQuery)->RH_DATAINI)    +"|" +;              
                                        alltrim(str((cQuery)->R_E_C_N_O_))            //Identificador de f�rias

             oVac["vacationBonus"]   := (cQuery)->RH_DABONPE                          //Dias de abono
             oVac["advance"]         := (cQuery)->RH_PERC13S                          //optional - Adiantamento do 13
             If (cQuery)->RH_PERC13S > 0           
                 oVac["hasAdvance"]  := .T.                                           //Se foi solicitado Adiantamento do 13
             Else
                 oVac["hasAdvance"]  := .F.                                           //Se foi solicitado Adiantamento do 13
             EndIf    
             oVac["limitDate"]       := ""                                            //Data limite para solicita��o de f�rias
             oVac["canAlter"]        := .F.                                           //Verifica se a solicita��o de f�rias pode ser editada e exclu�da de acordo com o status
             Aadd(aData,oVac)

          EndIf
          
         (cQuery)->(DBSkip())
	EndDo
	(cQuery)->(DBCloseArea())


    //==================================== 
    //Busca solicita��es rejeitadas na RH3 do usu�rio recebido diretamente na rota da url
    //1=Em processo de aprova��o;2=Atendida;3=Reprovada;4=Aguardando Efetiva��o do RH;5=Aguardando Aprova��o do RH
    aOcurances := {}
    GetVacationWKF(@aOcurances, cMatSRA, cBranchVld, cMatSRA, cBranchVld, cEmpSRA, "'3'")
    //varinfo("getHistory aOcurances: ",aOcurances)

    If Len(aOcurances) > 0 
        //inclui registro no array principal
        For nI := 1  To Len(aOcurances)
            oVac                    := JsonObject():New() 
            oVac["balance"]         := 0
            oVac["days"]            := aOcurances[nI][12]                           //Dias de f�rias
            oVac["status"]          := "rejected"                                     //"approved" "approving" "rejected" "empty" "closed"
            oVac["rejectionReason"] := AllTrim(getRGKJustify(cBranchVld, aOcurances[nI][15], , .T.))

            oVac["initVacation"]    := formatGMT( aOcurances[nI][5] )               //Data de in�cio das f�rias
            oVac["endVacation"]     := formatGMT( aOcurances[nI][6] )               //Data final das f�rias
            If !empty(aOcurances[nI][21]) .and. !empty(aOcurances[nI][22])
               oVac["initPeriod"]   := formatGMT( aOcurances[nI][21], .T. )
               oVac["endPeriod"]    := formatGMT( aOcurances[nI][22], .T. )
            EndIf

            oVac["statusLabel"]     := EncodeUTF8(STR0008)                          //"Rejeitada"
            oVac["id"]              := "RH3"              +"|" +;
                                       cBranchVld         +"|" +;
                                       cMatSRA            +"|" +;              
                                       aOcurances[nI][15] +"|" +;              
                                       alltrim( str(aOcurances[nI][16]) )           //Identificador de solicita��es
            oVac["vacationBonus"]   := aOcurances[nI][7]                            //Dias de abono 
            oVac["advance"]         := 0                                            //Adiantamento do 13
            oVac["hasAdvance"]      := aOcurances[nI][14]                           //Se foi solicitado Adiantamento do 13
            oVac["limitDate"]       := ""                                           //Data limite para solicita��o de f�rias
            oVac["canAlter"]        := .F.
            Aadd(aData,oVac)
        Next nI
    EndIf


    //Ordenando resultado pela data de inicio das f�ras
    ASORT(aData, , , { | x,y | x["initVacation"] > y["initVacation"] } )

    //Avalia a pagina��o ap�s a ordena��o
    For nI := 1 To Len(aData)

		nRegCount ++
		If ( nRegCount >= nRegCountIni .And. nRegCount <= nRegCountFim )
            Aadd(aDataResult , aData[nI])
		Else
			If nRegCount > nRegCountFim
				lMaisPaginas := .T.
			EndIf   
		EndIf   

    Next nI

ENDIF

    oItem["hasNext"]  := lMaisPaginas
    oItem["items"]    := aDataResult
    oItem["length"]   := Len(aData)

    cJson := oItem:ToJson()
    Self:SetResponse(cJson)

Return(.T.)

WSMETHOD GET NextDaysVacation WSREST Vacation

Local oVac          := JsonObject():New()
Local cQuery        := GetNextAlias()
Local aPeriod       := {}
Local aIDFunc       := {}
Local aDataLogin    := {}
Local cRestFault    := ""
Local cJson         := ""
Local cToken        := ""
Local cKeyId        := ""
Local cMatSRA       := ""
Local cID           := ""
Local cBranchVld    := ""
Local cLogin        := ""
Local cRD0Cod       := ""
Local cStatus       := ""
Local cDtConv       := ""
local cDtBsIni      := ""
Local cDtBsFim      := ""
Local cDtFerIni     := ""
Local cSRFtab       := ""
Local dDataIniPer   := cTod("")
Local dDataFimPer   := cTod("")
Local nDiaSolFer    := SuperGetMv("MV_DSOLFER",,30)
Local nDiasFer      := 0
Local lRet          := .T.
Local lTem13        := .F.
Local lDemit        := .F.
Local lHabil        := .T.
Local cRoutine     := "W_PWSA100A.APW" //F�rias.

::SetHeader('Access-Control-Allow-Credentials' , "true")
cToken     := Self:GetHeader('Authorization')
cKeyId  	  := Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len(aDataLogin) > 0
   cMatSRA    := aDataLogin[1]
   cLogin     := aDataLogin[2]
   cRD0Cod    := aDataLogin[3]
   cBranchVld := aDataLogin[5]
   lDemit     := aDataLogin[6]
EndIf

//Valida Permissionamento
fPermission(cBranchVld, cLogin, cRD0Cod, "dashboardVacationCountdown", @lHabil)
If !lHabil .Or. lDemit
   SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
   Return (.F.)  
EndIf

//avalia solicitante e destino da requisi��o 
If len(::aUrlParms) > 0 .And. !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2])
   aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
   If Len(aIdFunc) > 1 
   
      //valida se o solicitante da requisi��o pode ter acesso as informa��es
      If getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
         cBranchVld	:= aIdFunc[1]
         cMatSRA		:= aIdFunc[2]
         cEmpSRA		:= aIdFunc[3]
      Else
         cRestFault := EncodeUTF8(STR0043) +cBranchVld +"/" +cMatSRA //"usu�rio sem permiss�o para execu��o da requisi��o: "
         cBranchVld	:= ""
         cMatSRA		:= ""
      EndIf	
   EndIf
EndIF

If !Empty(cBranchVld) .And. !Empty(cMatSRA)

   cSRFtab  := "%" + RetFullName("SRF", cEmpSRA) + "%"

   BEGINSQL ALIAS cQuery
      COLUMN RF_DATABAS AS DATE
      COLUMN RF_DATAINI AS DATE
      COLUMN RF_DATINI2 AS DATE
      COLUMN RF_DATINI3 AS DATE
      COLUMN RF_DATAFIM AS DATE
            
   SELECT 
      SRF.RF_DATABAS,
      SRF.RF_DATAFIM,
      SRF.RF_DATAINI,
      SRF.RF_DATINI2,
      SRF.RF_DATINI3,
      SRF.RF_DFEPRO1,
      SRF.RF_DFEPRO2,
      SRF.RF_DFEPRO3,
      SRF.RF_DABPRO1,
      SRF.RF_DABPRO2,
      SRF.RF_DABPRO3,
      SRF.RF_PERC13S, 
      SRF.RF_DFERVAT, 
      SRF.RF_DFERAAT,
      SRF.RF_DFERANT, 
      SRF.R_E_C_N_O_
   FROM 
      %exp:cSRFtab% SRF
   WHERE 
      SRF.RF_FILIAL = %Exp:cBranchVld% AND 
      SRF.RF_MAT    = %Exp:cMatSRA%    AND
      SRF.RF_STATUS = '1'              AND
      SRF.%NotDel%
      ORDER BY SRF.RF_DATABAS		
   ENDSQL

  While (cQuery)->(!Eof())


   //Busca informa��es do per�odo concessivo para saber a data limite de cada per�odo.
   //Somente busca se existir programa��o
   If !Empty((cQuery)->RF_DATAINI) .Or. !Empty((cQuery)->RF_DATINI2) .Or. !Empty((cQuery)->RF_DATINI3)
      aPeriod     := PeriodConcessive( dtos((cQuery)->RF_DATABAS) , dtos((cQuery)->RF_DATAFIM) )
      dDataIniPer := aPeriod[1]
      dDataFimPer := aPeriod[2] - nDiaSolFer
   EndIf

   lTem13 := .F.
   //Verifica se existe programa��o e a data de inicio � menor que a database
   If !Empty((cQuery)->RF_DATAINI) .And. (cQuery)->RF_DATAINI > dDataBase
      nDiasFer  := (cQuery)->RF_DFEPRO1               // Qtde dias de f�rias
      cStatus   := "approved"                         // Status

      cDtFerIni := dToS((cQuery)->RF_DATAINI)         // Data in�cio f�rias.
      cDtFerIni := Substr(cDtFerIni,1,4) + "-" + ;
                   SubStr(cDtFerIni,5,2) + "-" + ;
                   SubStr(cDtFerIni,7,2) + "-" + ;
                   "T00:00:00Z"

      cDtBsIni  := dToS((cQuery)->RF_DATABAS)         // Database in�cio
      cDtBsIni  := Substr(cDtBsIni,1,4) + "-" + ;
                   SubStr(cDtBsIni,5,2) + "-" + ;
                   SubStr(cDtBsIni,7,2) + "-" + ;
                   "T00:00:00Z"

      cDtBsFim  := dToS((cQuery)->RF_DATAFIM)         // Database fim
      cDtBsFim  := Substr(cDtBsFim,1,4) + "-" + ;
                   SubStr(cDtBsFim,5,2) + "-" + ;
                   SubStr(cDtBsFim,7,2) + "-" + ;
                   "T00:00:00Z"                 

      cID       := cBranchVld + "|" + cMatSRA + "|" + dToS((cQuery)->RF_DATABAS) + "|" + dToS((cQuery)->RF_DATAINI)                   
      lTem13    := (cQuery)->RF_PERC13S > 0

      cDtConv   := dToS(dDataFimPer)                  //Data limite para gozo
      cDtConv   := Substr(cDtConv,1,4) + "-" + ;
                   SubStr(cDtConv,5,2) + "-" + ;
                   SubStr(cDtConv,7,2) 
      
      //Se encontrar, sai do loop
      Exit

   ElseIf !Empty((cQuery)->RF_DATINI2) .And. (cQuery)->RF_DATINI2 > dDataBase
      nDiasFer  := (cQuery)->RF_DFEPRO2               // Qtde dias de f�rias
      cStatus   := "approved"                         // Status

      cDtFerIni := dToS((cQuery)->RF_DATINI2)         // Data in�cio f�rias.   
      cDtFerIni := Substr(cDtFerIni,1,4) + "-" + ;
                   SubStr(cDtFerIni,5,2) + "-" + ;
                   SubStr(cDtFerIni,7,2) + "-" + ;
                   "T00:00:00Z"
 

      cDtBsIni  := dToS((cQuery)->RF_DATABAS)          // Database in�cio
      cDtBsIni  := Substr(cDtBsIni,1,4) + "-" + ;
                   SubStr(cDtBsIni,5,2) + "-" + ;
                   SubStr(cDtBsIni,7,2) + "-" + ;
                   "T00:00:00Z"

      cDtBsFim  := dToS((cQuery)->RF_DATAFIM)           // Database fim
      cDtBsFim  := Substr(cDtBsFim,1,4) + "-" + ;
                   SubStr(cDtBsFim,5,2) + "-" + ;
                   SubStr(cDtBsFim,7,2) + "-" + ;
                   "T00:00:00Z" 
                   
      cID       := cBranchVld + "|" + cMatSRA + "|" + dToS((cQuery)->RF_DATABAS) + "|" + dToS((cQuery)->RF_DATINI2)
      lTem13    := (cQuery)->RF_PERC13S > 0

      cDtConv   := dToS(dDataFimPer)                    //Data limite para gozo
      cDtConv   := Substr(cDtConv,1,4) + "-" + ;
                   SubStr(cDtConv,5,2) + "-" + ;
                   SubStr(cDtConv,7,2) 
      //Se encontrar, sai do loop
      Exit
      
   ElseIf !Empty((cQuery)->RF_DATINI3) .And. (cQuery)->RF_DATINI3 > dDataBase
      nDiasFer  := (cQuery)->RF_DFEPRO3                  // Qtde dias de f�rias
      cStatus   := "approved"                            // Status

      cDtFerIni := dToS((cQuery)->RF_DATINI3)            // Data in�cio f�rias. 
      cDtFerIni := Substr(cDtFerIni,1,4) + "-" + ;
                   SubStr(cDtFerIni,5,2) + "-" + ;
                   SubStr(cDtFerIni,7,2) + "-" + ;
                   "T00:00:00Z"

      cDtBsIni  := dToS((cQuery)->RF_DATABAS)             // Database in�cio
      cDtBsIni  := Substr(cDtBsIni,1,4) + "-" + ;
                   SubStr(cDtBsIni,5,2) + "-" + ;
                   SubStr(cDtBsIni,7,2) + "-" + ;
                   "T00:00:00Z"

      cDtBsFim  := dToS((cQuery)->RF_DATAFIM)            // Database fim
      cDtBsFim  := Substr(cDtBsFim,1,4) + "-" + ;
                   SubStr(cDtBsFim,5,2) + "-" + ;
                   SubStr(cDtBsFim,7,2) + "-" + ;
                   "T00:00:00Z" 

      cID       := cBranchVld + "|" + cMatSRA + "|" + dToS((cQuery)->RF_DATABAS) + "|" + dToS((cQuery)->RF_DATINI3)
      lTem13    := (cQuery)->RF_PERC13S > 0

      cDtConv   := dToS(dDataFimPer)                     //Data limite para gozo
      cDtConv   := Substr(cDtConv,1,4) + "-" + ;   
                   SubStr(cDtConv,5,2) + "-" + ;
                   SubStr(cDtConv,7,2) 
      
      //Se encontrar, sai do loop
      Exit

   Else
      //Se n�o existir programa��o, verifica se h� f�rias calculada para o per�odo aquisitivo em quest�o.
      SRH->(dbSetOrder(1))
      If SRH->(dbSeek(cBranchVld + cMatSRA + dToS((cQuery)->RF_DATABAS))) 

         //Busca o per�odo concessivo de acordo com os dados da SRH.
         aPeriod     := PeriodConcessive( dtos(SRH->RH_DATABAS) , dtos(SRH->RH_DBASEAT) )
         dDataIniPer := aPeriod[1]
         dDataFimPer := aPeriod[2] - nDiaSolFer

         nDiasFer    := SRH->RH_DFERIAS                  //quantidade de dias de f�rias
         cStatus     := "approved"                       //status

         cDtFerIni := dToS(SRH->RH_DATAINI)              //Data in�cio das f�rias.
         cDtFerIni := Substr(cDtFerIni,1,4) + "-" + ;
                      SubStr(cDtFerIni,5,2) + "-" + ;
                      SubStr(cDtFerIni,7,2) + "-" + ;
                      "T00:00:00Z"

         cDtBsIni    := dToS(SRH->RH_DATABAS)            
         cDtBsIni    := Substr(cDtBsIni,1,4) + "-" + ;   //database in�cio
                        SubStr(cDtBsIni,5,2) + "-" + ;
                        SubStr(cDtBsIni,7,2) + "-" + ;
                        "T00:00:00Z"

         cDtBsFim    := dToS(SRH->RH_DBASEAT)  
         cDtBsFim    := Substr(cDtBsFim,1,4) + "-" + ;   //database fim
                        SubStr(cDtBsFim,5,2) + "-" + ;
                        SubStr(cDtBsFim,7,2) + "-" + ;
                        "T00:00:00Z" 

         cID         := cBranchVld + "|" + cMatSRA + "|" + dToS(SRH->RH_DATABAS) + "|" + dToS(SRH->RH_DATAINI)
         lTem13      := SRH->RH_PERC13S > 0              //solicitado 13?

         cDtConv     := dToS(dDataFimPer)
         cDtConv     := Substr(cDtConv,1,4) + "-" + ;    //data limite para gozo das f�rias;
                        SubStr(cDtConv,5,2) + "-" + ;
                        SubStr(cDtConv,7,2) 
         
         //Se encontrar, sai do loop
         Exit
      EndIf
   EndIf

   (cQuery)->(dbSkip())
  EndDo

  (cQuery)->(dbCloseArea())
ENDIF

If empty(cRestFault) .And. lRet
   oVac                    := JsonObject():New()
   oVac["days"]            := nDiasFer
   oVac["status"]          := cStatus
   oVac["initVacation"]    := cDtFerIni
   oVac["initPeriod"]      := cDtBsIni
   oVac["endPeriod"]       := cDtBsFim
   oVac["id"]              := cID
   oVac["hasAdvance"]      := lTem13
   oVac["limitDate"]       := cDtConv
   
   lRet := .T.
   cJson := oVac:ToJson()
   Self:SetResponse(cJson)  
Else
   lRet := .F.
   SetRestFault(400, EncodeUTF8(cRestFault), .T.)
EndIf

Return (lRet)


// -------------------------------------------------------------------
// - Atualiza��o da inclus�o de solicita��o de f�rias.
// -------------------------------------------------------------------
WSMETHOD POST postRequestVacation WSREST Vacation

Local oItemDetail       := NIL
Local oItemData         := NIL
Local oItem             := NIL
Local oMsgReturn        := NIL
Local oRequest          := NIL 
Local oVacationRequest  := NIL

Local cToken	 	      := ""
Local cKeyId	 	      := ""
Local cRestFault        := ""
Local cMsgReturn        := ""
Local cRoutine          := "W_PWSA100A.APW"
Local cApprover         := ""
Local cDeptoApr         := ""
Local cEmpApr           := ""
Local cFilApr           := ""
Local cVision           := ""
Local cIniVac           := ""
Local cEndVac           := ""
Local cIniPer           := ""
Local cEndPer           := ""
Local cMatSRA           := ""
Local cLogin            := ""
Local cRD0Cod           := ""
Local cBranchSolic      := ""
Local cMatSolic         := ""
Local cBody             := ::GetContent()
Local cAliasRH4         := GetNextAlias()
Local cBranchVld        := FwCodFil()
Local cEmpSolic         := cEmpAnt

Local aVision           := {}
Local aGetStruct        := {}
Local aEmployee         := {}
Local aMessages         := {}
Local aDataLogin        := {}

Local nSupLevel         := 99
Local nDias             := 0
Local nDiasAbn          := 0

Local lSolic13          := .F.
Local lDemit            := .F.
Local lHabil            := .T.
Local lRet              := .T.
Local lGestor           := .F.
Local lSUPAprove        := .F.

::SetHeader('Access-Control-Allow-Credentials' , "true")
cToken     := Self:GetHeader('Authorization')
cKeyId  	  := Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len(aDataLogin) > 0
   cMatSRA    := aDataLogin[1]
   cLogin     := aDataLogin[2]
   cRD0Cod    := aDataLogin[3]
   cBranchVld := aDataLogin[5]
   lDemit     := aDataLogin[6]
EndIf

//avalia solicitante e destino da requisi��o 
If len(::aUrlParms) > 0
   If !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2] )
   
      aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
      If Len(aIdFunc) > 1
         If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
            //Valida Permissionamento
            fPermission(cBranchVld, cLogin, cRD0Cod, "vacationRegister", @lHabil)
            If !lHabil .Or. lDemit
               SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
               Return (.F.)  
            EndIf
         Else
            //Valida Permissionamento
            fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementVacation", @lHabil)
            If !lHabil .Or. lDemit
               SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
               Return (.F.)  
            EndIf
            //valida se o solicitante da requisi��o pode ter acesso as informa��es
            If getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
               cMatSolic    := cMatSRA
               cBranchSolic := cBranchVld

               cBranchVld	:= aIdFunc[1]
               cMatSRA		:= aIdFunc[2]
               cEmpSolic	:= aIdFunc[3]
            Else
               cRestFault   := EncodeUTF8(STR0043) +cBranchVld +"/" +cMatSRA //"usu�rio sem permiss�o para execu��o da requisi��o: "
               cBranchVld	:= ""
               cMatSRA		:= ""
            EndIf	
            lGestor     := .T.
            lSUPAprove	:= SuperGetMv("MV_SUPTORH", NIL, .F.)
         EndIf
      EndIf
   Else
      //Valida Permissionamento
      fPermission(cBranchVld, cLogin, cRD0Cod, "vacationRegister", @lHabil)
      If !lHabil .Or. lDemit
         SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
         Return (.F.)  
      EndIf
   EndIf
Else
   cRestFault := EncodeUTF8(STR0044) //"erro na requisi��o do servi�o de f�rias"
EndIF

If Empty(cRestFault) .And. !Empty(cBody)
   oItemDetail := JsonObject():New()
   oItemDetail:FromJson(cBody)
   nDias    := Iif(oItemDetail:hasProperty("days"),oItemDetail["days"], 0)
   nDiasAbn := Iif(oItemDetail:hasProperty("vacationBonus"),oItemDetail["vacationBonus"], 0)
   cIniVac  := Iif(oItemDetail:hasProperty("initVacation"), Format8601(.T.,oItemDetail["initVacation"]), "")
   cEndVac  := Iif(oItemDetail:hasProperty("endVacation"), Format8601(.T.,oItemDetail["endVacation"]), "")
   lSolic13 := Iif(oItemDetail:hasProperty("hasAdvance"),oItemDetail["hasAdvance"], .F.)       
   cIniPer  := Iif(oItemDetail:hasProperty("initPeriod"), Format8601(.T.,oItemDetail["initPeriod"]), "")
   cEndPer  := Iif(oItemDetail:hasProperty("endPeriod"), Format8601(.T.,oItemDetail["endPeriod"]), "")

   If cPaisLoc $ "BRA|CHI|PAR|URU"
      //valida��es diversas para f�rias
      cRestFault := fVldSolicFer(cBranchVld,cMatSRA,cIniVac,cEndVac,nDias,nDiasAbn,lSolic13,cIniPer,cEndPer,,cEmpSolic)
   ENDIF

   If empty(cRestFault)
      //busca dados do solicitante
      aEmployee := getSummary( cMatSRA, cBranchVld, cEmpSolic)

      //busca vis�o para a solicita��o de f�rias
      aVision := GetVisionAI8(cRoutine, cBranchVld, cEmpSolic)
      cVision := aVision[1][1]

      //busca estrutura organizacional do workflow
      cMRrhKeyTree := fMHRKeyTree(If( !Empty(cBranchSolic), cBranchSolic, cBranchVld) , If(!Empty(cMatSolic), cMatSolic, cMatSRA))
      aGetStruct   := APIGetStructure( cRD0Cod,                                                 ;
                                       SUPERGETMV("MV_ORGCFG"),                                 ;
                                       cVision,                                                 ;
                                       cBranchVld,                                              ;
                                       cMatSRA,                                                 ;
                                       NIL,                                                     ;
                                       NIL,                                                     ;
                                       NIL,                                                     ;
                                       "B",                                                     ;
                                       If( !Empty(cBranchSolic), cBranchSolic, cBranchVld )  ,  ;
                                       If( !Empty(cMatSolic)   , cMatSolic   , cMatSRA    ),    ;
                                       NIL,                                                     ;
                                       NIL,                                                     ;
                                       NIL,                                                     ;
                                       NIL,                                                     ;
                                       .T.,                                                     ;
                                       {cEmpAnt},                                               ;
                                       NIL,                                                     ;
                                       NIL,                                                     ;
                                       .T. )
      //varinfo("aGetStruct: ",aGetStruct)

      If valtype(aGetStruct[1]) == "L" .and. !aGetStruct[1] 
         cRestFault := alltrim( EncodeUTF8(aGetStruct[2]) +" - " +EncodeUTF8(aGetStruct[3]) ) 
      Else
         If Len(aGetStruct) >= 1 .And. !(Len(aGetStruct) == 3 .And. !aGetStruct[1]) .And. (!lGestor .Or. (lGestor .And. !lSUPAprove))
            cEmpApr   := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa
            cFilApr   := aGetStruct[1]:ListOfEmployee[1]:SupFilial
            nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
            cApprover := aGetStruct[1]:ListOfEmployee[1]:SupRegistration
            cDeptoApr := aGetStruct[1]:ListOfEmployee[1]:DepartAprovador
         EndIf
      EndIf   
   EndIf

   If empty(cRestFault)
      //Prepara objeto RH3 Request
      oRequest := WSClassNew("TRequest")
      oRequest:Origem                             := EncodeUTF8(STR0013) //MEURH
      oRequest:Branch				                 := cBranchVld
      oRequest:Registration		                 := cMatSRA
      oRequest:StarterBranch		                 := If( !Empty(cBranchSolic), cBranchSolic, cBranchVld )  
      oRequest:StarterRegistration	              := If( !Empty(cMatSolic)   , cMatSolic   , cMatSRA    )           
      oRequest:Vision				                 := cVision
      oRequest:Observation                        := Alltrim(STR0014 +" - " +aEmployee[2] +" - " +dToC(date()) +Space(1) +Time())
      oRequest:EmpresaAPR                         := cEmpApr
      oRequest:ApproverBranch                     := cFilApr
      oRequest:ApproverRegistration               := cApprover
      oRequest:ApproverLevel                      := nSupLevel
      oRequest:DepartAPR                          := cDeptoApr
      oRequest:Empresa                            := cEmpSolic

      //Prepara objeto RH4 Vacation
      oVacationRequest := WSClassNew("TVacation")
      oVacationRequest:Branch                     := cBranchVld
      oVacationRequest:Registration               := cMatSRA
      oVacationRequest:Name                       := aEmployee[2]
      oVacationRequest:InitialDate                := cIniVac
      oVacationRequest:FinalDate                  := cEndVac
      oVacationRequest:Days                       := nDias
      oVacationRequest:PecuniaryDays              := nDiasAbn
      oVacationRequest:PecuniaryAllowance         := Iif( nDiasAbn>0, ".T.", ".F.") 
      oVacationRequest:ThirteenthSalary1stInstall := Iif( lSolic13  , ".T.", ".F.")  

      If AddVacationRequest(oRequest, oVacationRequest, "MEURH", .T., @cMsgReturn)
         //complementa RH4 com os dados do per�odo aquisito relacionado 
         BeginSQL ALIAS cAliasRH4
            SELECT COUNT(*) QTD  FROM %table:RH4% RH4
               WHERE RH4.RH4_CODIGO = %exp:oRequest:Code%
                     AND RH4.RH4_FILIAL = %exp:oVacationRequest:Branch%
                     AND RH4.%NotDel%
         EndSQL

         If (cAliasRH4)->(!Eof()) .and. (cAliasRH4)->QTD > 0   
            DBSelectArea("RH4")

            Reclock("RH4", .T.)
            RH4->RH4_FILIAL	:= oVacationRequest:Branch 
            RH4->RH4_CODIGO	:= oRequest:Code
            RH4->RH4_ITEM	:= (cAliasRH4)->QTD + 1
            RH4->RH4_CAMPO	:= "RF_DATABAS"
            RH4->RH4_VALNOV	:= cIniPer
            RH4->(MsUnlock())

            Reclock("RH4", .T.)
            RH4->RH4_FILIAL	:= oVacationRequest:Branch 
            RH4->RH4_CODIGO	:= oRequest:Code
            RH4->RH4_ITEM	:= (cAliasRH4)->QTD + 2
            RH4->RH4_CAMPO	:= "RF_DATAFIM"
            RH4->RH4_VALNOV	:= cEndPer
            RH4->(MsUnlock())
         EndIf
         (cAliasRH4)->( dbCloseArea() )
      Else
         cRestFault := cMsgReturn       
      EndIf
   EndIf
EndIf   

If empty(cRestFault) .And. lRet
   oMsgReturn := JsonObject():New()
   oMsgReturn["type"]         := "success"
   oMsgReturn["code"]         := "200"
   oMsgReturn["detail"]       := EncodeUTF8(STR0015) //"Atualiza��o realizada com sucesso"
   Aadd(aMessages, oMsgReturn)

   //atualiza dados para o retorno
   oItemData := JsonObject():New()
   oItemData["days"]          := nDias
   oItemData["vacationBonus"] := nDiasAbn
   oItemData["initVacation"]  := cIniVac
   oItemData["endVacation"]   := cEndVac
   oItemData["hasAdvance"]    := Iif(lSolic13, "true", "false")
   oItemData["initPeriod"]    := cIniPer
   oItemData["endPeriod"]     := cEndPer

   oItem := JsonObject():New()
   oItem["data"]              := oItemData
   oItem["messages"]          := aMessages
   oItem["length"]            := 1

   cJson := oItem:ToJson()
   Self:SetResponse(cJson)
Else
   lRet := .F.
   SetRestFault(400, EncodeUTF8(cRestFault), .T.)
EndIf

Return(lRet)


// -------------------------------------------------------------------
// - Atualiza��o da edi��o dos itens da solicita��o de f�rias.
// -------------------------------------------------------------------
WSMETHOD PUT putRequestVacation WSREST Vacation
Local oItem          := JsonObject():New()
Local oItemData      := JsonObject():New()
Local oItemDetail    := JsonObject():New()
Local oMsgReturn     := JsonObject():New()
Local cBody          := ::GetContent()
Local lRet           := .T.
Local aMessages      := {}
Local aParam         := {}
Local aDataLogin     := {}

Local cRestFault     := ""
Local cBranchVld     := ""
Local cMatSRA        := ""
Local cLogin         := ""
Local cRD0Cod        := ""
Local cToken         := ""
Local cJson          := ""
Local cKey           := ""
Local cEmpSRA        := cEmpAnt
Local cRoutine       := "W_PWSA100A.APW" 

Local nDias          := 0
Local nDiasAbn       := 0
Local lSolic13       := .F.
Local lDemit			:= .F.
Local lHabil			:= .T.
Local cIniVac        := ""
Local cEndVac        := ""
Local cIniPer        := ""
Local cEndPer        := ""
Local cID            := ""

::SetHeader('Access-Control-Allow-Credentials' , "true")
cToken     := Self:GetHeader('Authorization')
cKeyId  	  := Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len(aDataLogin) > 0
   cMatSRA    := aDataLogin[1]
   cLogin     := aDataLogin[2]
   cRD0Cod    := aDataLogin[3]
   cBranchVld := aDataLogin[5]
   lDemit     := aDataLogin[6]
EndIf

//avalia solicitante e destino da requisi��o 
If len(::aUrlParms) > 0
   //varinfo("::aUrlParms -> ",::aUrlParms) 
   If !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2])
      aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
      If Len(aIdFunc) > 1
         If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
            fPermission(cBranchVld, cLogin, cRD0Cod, "vacation", @lHabil)
            If !lHabil .Or. lDemit
               SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
               Return (.F.)  
            EndIf
         Else
            //Valida Permissionamento
            fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementVacation", @lHabil)
            If !lHabil .Or. lDemit
               SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
               Return (.F.)  
            //valida se o solicitante da requisi��o pode ter acesso as informa��es
            ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
               cBranchVld	:= aIdFunc[1]
               cMatSRA		:= aIdFunc[2]
               cEmpSRA		:= aIdFunc[3]               
            Else
               cRestFault   := EncodeUTF8(STR0043) +cBranchVld +"/" +cMatSRA //"usu�rio sem permiss�o para execu��o da requisi��o: "
               cBranchVld	:= ""
               cMatSRA		:= ""
            EndIf	
         EndIf
      EndIf
   Else
      //Valida Permissionamento
      fPermission(cBranchVld, cLogin, cRD0Cod, "vacation", @lHabil)
      If !lHabil .Or. lDemit
         SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
         Return (.F.)  
      EndIf
   EndIf
ELSE
   cRestFault := EncodeUTF8(STR0044) //"erro na requisi��o do servi�o de f�rias"
EndIF

If Empty(cRestFault) .And. !Empty(cBody)
   oItemDetail:FromJson(cBody)
   cID     := Iif(oItemDetail:hasProperty("id"),oItemDetail["id"], "")

   nDias   := Iif(oItemDetail:hasProperty("days"),oItemDetail["days"], 0)
   nDiasAbn:= Iif(oItemDetail:hasProperty("vacationBonus"),oItemDetail["vacationBonus"], 0)
   cIniVac := Iif(oItemDetail:hasProperty("initVacation"), Format8601(.T.,oItemDetail["initVacation"]), "")
   cEndVac := Iif(oItemDetail:hasProperty("endVacation"), Format8601(.T.,oItemDetail["endVacation"]), "")
   cIniPer := Iif(oItemDetail:hasProperty("initPeriod"), Format8601(.T.,oItemDetail["initPeriod"]), "")
   cEndPer := Iif(oItemDetail:hasProperty("endPeriod"), Format8601(.T.,oItemDetail["endPeriod"]), "")

   If oItemDetail:hasProperty("hasAdvance") 
      //chegando com tipo caracter no PUT
      If (Valtype(oItemDetail["hasAdvance"]) == "L" .And. oItemDetail["hasAdvance"]) .Or. ;
         (Valtype(oItemDetail["hasAdvance"]) == "C" .And. oItemDetail["hasAdvance"] == ".T.")
         lSolic13 := .T.
      Else  
         lSolic13 := .F.
      EndIf       
   Else
      lSolic13 := .F.
   EndIf
   
   If empty(cRestFault)
      aParam := StrTokArr(cID , "|")
      cKey   := aParam[2] + aParam[4]

      //Valida movimenta��o do workflow
      cRestFault := fVldWkf(cKey, aParam[4], "U")
   ENDIF

   If empty(cRestFault) .and. (cPaisLoc $ "BRA|CHI|PAR|URU")
      //valida��es diversas para f�rias
      cRestFault := fVldSolicFer(cBranchVld,cMatSRA,cIniVac,cEndVac,nDias,nDiasAbn,lSolic13,cIniPer,cEndPer,aParam[2] + aParam[3] + aParam[4], cEmpSRA)
   EndIf
Else
   cRestFault := STR0026 //"Informa��es da requisi��o n�o recebida"
EndIf

If empty(cRestFault)
   //atualiza RH4
   Begin Transaction
   DBSelectArea("RH4")
   DBSetOrder(1)
   RH4->(DbSeek(RH3->(RH3_FILIAL + RH3_CODIGO)))

   While RH4->(RH4_FILIAL + RH4_CODIGO) == RH3->(RH3_FILIAL + RH3_CODIGO) .And. !RH4->(Eof())

      RecLock("RH4", .F.)
         If AllTrim(RH4->RH4_CAMPO) == "R8_DATAINI"
            RH4->RH4_VALANT := RH4->RH4_VALNOV
            RH4->RH4_VALNOV := cIniVac
         ElseIf AllTrim(RH4->RH4_CAMPO) == "R8_DATAFIM"
            RH4->RH4_VALANT := RH4->RH4_VALNOV
            RH4->RH4_VALNOV := cEndVac
         ElseIf AllTrim(RH4->RH4_CAMPO) == "R8_DURACAO"
            RH4->RH4_VALANT := RH4->RH4_VALNOV
            RH4->RH4_VALNOV := AllTrim(Str(nDias))   
         ElseIf AllTrim(RH4->RH4_CAMPO) == "TMP_ABONO"
            RH4->RH4_VALANT := RH4->RH4_VALNOV
            If nDiasAbn > 0  
               RH4->RH4_VALNOV := ".T."
            Else
               RH4->RH4_VALNOV := ".F."
            EndIf
         ElseIf AllTrim(RH4->RH4_CAMPO) == "TMP_DABONO"
            RH4->RH4_VALANT := RH4->RH4_VALNOV
            RH4->RH4_VALNOV := AllTrim(Str(nDiasAbn))       
         ElseIf AllTrim(RH4->RH4_CAMPO) == "TMP_1P13SL"
            RH4->RH4_VALANT := RH4->RH4_VALNOV
            If lSolic13  
               RH4->RH4_VALNOV := ".T."
            Else
               RH4->RH4_VALNOV := ".F."
            EndIf
         EndIf
      MsUnLock()

      RH4->(DbSkip())
   EndDo
   End Transaction
EndIf

If empty(cRestFault)
   oMsgReturn["type"]      := "success"
   oMsgReturn["code"]      := "200"
   oMsgReturn["detail"]    := EncodeUTF8(STR0022) //"Altera��o realizada com sucesso"

   Aadd(aMessages, oMsgReturn)

   If !Empty(cBody)
      //atualiza dados para o retorno
      oItemData["days"]          := nDias
      oItemData["vacationBonus"] := nDiasAbn
      oItemData["initVacation"]  := cIniVac
      oItemData["endVacation"]   := cEndVac
      oItemData["hasAdvance"]    := Iif(lSolic13, .T. , .F. )
      oItemData["initPeriod"]    := cIniPer
      oItemData["endPeriod"]     := cEndPer
   EndIf

   oItem["data"]                 := oItemData
   oItem["messages"]             := aMessages
   oItem["length"]               := 1

   cJson := oItem:ToJson()
   ::SetResponse(cJson)
Else
   lRet := .F.
   SetRestFault(400, EncodeUTF8(cRestFault), .T.)
EndIf

Return(lRet)


// -------------------------------------------------------------------
// - Atualiza��o da dele��o de solicita��o de f�rias.
// -------------------------------------------------------------------
WSMETHOD DELETE delRequestVacation WSREST Vacation
Local lRet           := .T.
Local lDemit         := .F.
Local lHabil         := .T.
Local aUrlParam      := ::aUrlParms
Local oItem          := JsonObject():New()
Local oItemData      := JsonObject():New()
Local oMsgReturn     := JsonObject():New()
Local aMessages      := {}
Local aParam         := {}
Local aIDFunc        := {}
Local aDataLogin     := {}

Local cRestFault     := ""
Local cBranchVld     := ""
Local cMatSRA        := ""
Local cToken         := ""
Local cLogin         := ""
Local cRD0Cod        := ""
Local cJson          := ""
Local cKey           := ""
Local cKeyRGK        := ""
Local cRoutine       := "W_PWSA100A.APW" 

::SetHeader('Access-Control-Allow-Credentials' , "true")
cToken     := Self:GetHeader('Authorization')
cKeyId  	  := Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len(aDataLogin) > 0
   cMatSRA     := aDataLogin[1]
   cLogin      := aDataLogin[2]
   cRD0Cod     := aDataLogin[3]
   cBranchVld  := aDataLogin[5]
   lDemit      := aDataLogin[6]
EndIf

//avalia solicitante e destino da requisi��o 
If Len(aUrlParam) > 0 .And. !Empty(aUrlParam[2]) .And. !("current" $ aUrlParam[2])
   aIdFunc := STRTOKARR( aUrlParam[2], "|" )
   If Len(aIdFunc) > 1
      If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
         //Valida Permissionamento
         fPermission(cBranchVld, cLogin, cRD0Cod, "vacation", @lHabil)
         If !lHabil .Or. lDemit
            SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
            Return (.F.)  
         EndIf
      Else 
         //Valida Permissionamento
         fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementVacation", @lHabil)
         If !lHabil .Or. lDemit
            SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
            Return (.F.)  
         //valida se o solicitante da requisi��o pode ter acesso as informa��es
         ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
            cBranchVld	:= aIdFunc[1]
            cMatSRA		:= aIdFunc[2]
         Else
            cRestFault   := EncodeUTF8(STR0043) +cBranchVld +"/" +cMatSRA //"usu�rio sem permiss�o para execu��o da requisi��o: "
            cBranchVld	:= ""
            cMatSRA		:= ""
         EndIf	
      EndIf
   EndIf
Else
   //Valida Permissionamento
   fPermission(cBranchVld, cLogin, cRD0Cod, "vacation", @lHabil)
   If !lHabil .Or. lDemit
      SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
      Return (.F.)  
   EndIf
EndIf

If Empty(cRestFault)
   If len(aUrlParam) > 0 .And. !Empty(aUrlParam[1]) .And. aUrlParam[1] == "request"

      //origem requisi��o DELETE
      If Len(aUrlParam) == 3 .And. aUrlParam[3] != "undefined"
         aParam := StrTokArr(aUrlParam[3], "|")
      EndIf

      //"RH3" , Filial , Matricula , RH3_CODIGO , R_E_C_N_O_
      If len(aParam) != 5
         cRestFault := STR0023 //"Erro na requisi��o, par�metros invalidos"
      EndIf
   EndIF
EndIf

If empty(cRestFault)
   cKey    := aParam[2] + aParam[4]
   cKeyRGK := aParam[2] + aParam[3] + aParam[4] //Filial + Matricula + C�digo

   //Valida movimenta��o do workflow
   cRestFault := fVldWkf(cKey, aParam[4], "D")
ENDIF

If empty(cRestFault)

   Begin Transaction
   RecLock("RH3",.F.)
   RH3->(dbDelete())
   RH3->(MsUnlock())

   DbSelectArea("RH4")
   RH4->( dbSetOrder(1) )
   RH4->( dbSeek(cKey) )
   While !Eof() .And. RH4->(RH4_FILIAL+RH4_CODIGO) == cKey;

      RecLock("RH4",.F.)
      RH4->(dbDelete())
      RH4->(MsUnlock())
      RH4->(dBSkip())

   EndDo

   DbSelectArea("RGK")
   RGK->( dbSetOrder(1) )
   RGK->( dbSeek(cKeyRGK) )
   While !Eof() .And. RGK->(RGK_FILIAL+RGK_MAT+RGK_CODIGO) == cKeyRGK;

      RecLock("RGK",.F.)
      RGK->(dbDelete())
      RGK->(MsUnlock())
      RGK->(dBSkip())

   EndDo
   End Transaction

EndIf

If empty(cRestFault)
   HttpSetStatus(204)

   oMsgReturn["type"]      := "success"
   oMsgReturn["code"]      := "204"
   oMsgReturn["detail"]    := EncodeUTF8(STR0022) //"Exclus�o realizada com sucesso"
   Aadd(aMessages, oMsgReturn)

   oItem["data"]           := oItemData
   oItem["messages"]       := aMessages
   oItem["length"]         := 1

   cJson :=  oItem:ToJson()
   ::SetResponse(cJson)
Else
   lRet := .F.
   SetRestFault(400, EncodeUTF8(cRestFault), .T.)
EndIf

Return(lRet)

// -------------------------------------------------------------------
// Retorna o arquivo PDF do AVISO de f�rias
// -------------------------------------------------------------------
WSMETHOD GET NoticeVacation WSREST Vacation
   Local aLog        := {}
   Local aIdFunc     := {}
   Local aDados      := {}
   Local aInfo       := {}
   Local aDataLogin  := {}
   Local aQryParam   := Self:aQueryString
   Local cToken      := ""
   Local cMatSRA     := ""
   Local cBranchVld  := ""
   Local cLogin      := ""
   Local cRD0Cod     := ""
   Local cExtFile    := ""
   Local cDescDepto  := ""
   Local cDia2501    := ""
   Local cNome       := ""
   Local cSavFil     := cFilAnt
   Local cSavEmp     := cEmpAnt
   Local cEmpSRA     := cEmpAnt
   Local cRoutine    := "W_PWSA100A.APW" 
   Local nX          := 0
   Local nCont       := 0
   Local nDMes12     := 0
   Local nDMes01     := 0
   Local lContinua   := .T.
   Local lRet        := .T.
   Local lDemit      := .F.
   Local lHabil      := .T.
   Local lProjSRF    := .F.
   Local lRobot      := .F.
   Local lSucess     := .F.
   Local lChangeEmp  := .F.
   Local lNomeSoc    := SuperGetMv("MV_NOMESOC", NIL, .F.)
   Local lImpESP     := ExistBlock("NOTICEVACATIONREPORT")
   Local dPgDataBas  := CtoD('//')
   Local dPgDataIni  := CtoD('//')

   Local oFile       := Nil
   Local cArqLocal   := ""
   Local cFileName   := ""
   Local cFile       := ""
   Local cPDF        := ".PDF"

   ::SetContentType("application/json")
   ::SetHeader('Access-Control-Allow-Credentials' , "true")

   cToken     := Self:GetHeader('Authorization')
   cKeyId  	  := Self:GetHeader('keyId')
   aDataLogin := GetDataLogin(cToken, .T., cKeyId)
   If Len(aDataLogin) > 0
      cMatSRA    := aDataLogin[1]
      cLogin     := aDataLogin[2]
      cRD0Cod    := aDataLogin[3]
      cBranchVld := aDataLogin[5]
      lDemit     := aDataLogin[6]
   EndIf

   /* Cria��o do par�metro espec�fico para o cliente Uniforte.
      Esse par�metro n�o ser� documentado e n�o dever� ser compartilhado com outros clientes.
      No cen�rio da Uniforte eles n�o utilizam a solicita��o de f�rias, mas somente a programa��o manualmente via SRF.
      Caso o par�metro esteja com .T., o MeuRH verificar� o conteudo do par�metro MV_DIA2501
      Caso o MV_DIA2501 esteja ativado, ir� projetar a data fim das f�rias no card de f�rias programadas.
      Ex:
      Inic�o F�rias = 21/12/2020
      Dias de F�rias = 10 dias.
      MV_DIA2501 = 24/12, 25/12, 31/12, 01/01.
      Fim F�rias = 03/01/2021.
   */
   lProjSRF := SuperGetMv("MV_PROJSRF",,.F.,cBranchVld) // Busca o conte�do do par�metro conforme a filial do funcion�rio.
   If lProjSRF
      cDia2501 := SuperGetMv("MV_DIA2501",,"N",cBranchVld) // Busca o conte�do do par�metro conforme a filial do funcion�rio.
   EndIf

   If Len(::aUrlParms) == 4

      If !Empty(::aUrlParms[3]) .And. !( "current" $ ::aUrlParms[3] )
         aIdFunc := STRTOKARR( ::aUrlParms[3], "|" )
         If Len(aIdFunc) > 1
            If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
               //Valida Permissionamento
               fPermission(cBranchVld, cLogin, cRD0Cod, "vacationNotice", @lHabil)
               If !lHabil .Or. lDemit
                  SetRestFault(400, EncodeUTF8( STR0056 )) //"Permiss�o negada aos servi�os para aviso de f�rias!"
                  Return (.F.)  
               EndIf
            Else 
               //Valida Permissionamento
               fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementVacation", @lHabil)
               If !lHabil .Or. lDemit
                  SetRestFault(400, EncodeUTF8( STR0056 )) //"Permiss�o negada aos servi�os para aviso de f�rias!"
                  Return (.F.)			
               //valida se o solicitante da requisi��o pode ter acesso as informa��es
               ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
                  cBranchVld	:= aIdFunc[1]
                  cMatSRA		:= aIdFunc[2]
                  cEmpSRA		:= aIdFunc[3]
                  lChangeEmp  := !(cEmpSRA == cEmpAnt)
               Else
                  SetRestFault(400, EncodeUTF8( STR0064 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
                  Return (.F.)
               EndIf	
            EndIf
         EndIf
      Else
         //Valida Permissionamento
         fPermission(cBranchVld, cLogin, cRD0Cod, "vacationNotice", @lHabil)
         If !lHabil .Or. lDemit
            SetRestFault(400, EncodeUTF8( STR0056 )) //"Permiss�o negada aos servi�os para aviso de f�rias!"
            Return (.F.)  
         EndIf
      EndIf

      If !Empty(::aUrlParms[4]) 
         aIdVac := STRTOKARR( ::aUrlParms[4], "|" )

         //aIdVac[1] - tipo do registro de f�rias SRF ou SRH
         //aIdVac[2] - Filial
         //aIdVac[3] - Matr�cula
         //aIdVac[4] - Data Base
         //aIdVac[5] - Data Inicial
         //aIdVac[6] - RECNO

         If !len(aIdVac) > 0 .or. (aIdVac[1] != "SRF" .and. aIdVac[1] != "SRH")
            lContinua := .F.
         Else
            //Busca dados da empresa/filial (RHLIBFIL)
            lContinua := fInfo(@aInfo, cBranchVld, cEmpSRA)
         EndIf
      EndIf
   Else
      lContinua := .F.
   EndIF

   If !Empty(cBranchVld) .And. !Empty(cMatSRA) .And. lContinua

      If lChangeEmp
         fNewEmpFiles(cEmpSRA, cBranchVld, {"SRA","SRJ","SRH","SRF"})
      EndIf
      
      //Posiciona a tabela SRA na matricula que esta sendo impressa
      dbSelectArea("SRA")
      dbSetOrder(1)
      If dbSeek( cBranchVld + cMatSRA )

         cExtFile    := DTOS( DATE() ) + SubStr( TIME(), 1, 2) //Ano + Mes + Dia + Hora
         cFileName   := Alltrim(cBranchVld) + "_" + Alltrim(cMatSRA) + "_notice_"
         cArqLocal   := GetSrvProfString ("STARTPATH","")
         cDescDepto  := AllTrim(EncodeUTF8(fDesc('SQB', SRA->RA_DEPTO,'SQB->QB_DESCRIC', , xFilial("SQB", SRA->RA_FILIAL))))
         cNome       := If(lNomeSoc .And. !Empty(SRA->RA_NSOCIAL), SRA->RA_NSOCIAL, SRA->RA_NOMECMP)
         cNome       := Alltrim(EncodeUTF8(If(Empty(cNome), SRA->RA_NOME, cNome)))

         //Obtem o periodo da queryparam que veio na requisicao
         For nX := 1 To Len( aQryParam )
            If UPPER(aQryParam[nX,1]) == "EXECROBO"
               lRobot := .T.
            EndIf
         Next
         
         aDados := {}
         aAdd( aDados, ""                          ) //  1) inicializa tipo do aviso
         aAdd( aDados, AllTrim(aInfo[5])           ) //  2) inicializa estado da empresa
         aAdd( aDados, cToD(" / / ")               ) //  3) inicializa data do aviso
         aAdd( aDados, cNome                       ) //4) inicializa nome do funcion�rio
         aAdd( aDados, SRA->RA_NUMCP               ) //  5) inicializa carteira de trabalho
         aAdd( aDados, SRA->RA_SERCP               ) //  6) inicializa s�rie da carteira de trabalho
         aAdd( aDados, cDescDepto                  ) //  7) inicializa descri��o do departamento
         aAdd( aDados, 0                           ) //  8) inicializa dias de licen�a remunerada m�s seguinte
         aAdd( aDados, 0                           ) //  9) inicializa dias de licen�a remunerada
         aAdd( aDados, cToD(" / / ")               ) // 10) inicializa inicio do per�odo aquisitivo
         aAdd( aDados, cToD(" / / ")               ) // 11) inicializa t�rmino do per�odo aquisitivo
         aAdd( aDados, cToD(" / / ")               ) // 12) inicializa inicio do gozo de f�rias
         aAdd( aDados, cToD(" / / ")               ) // 13) inicializa t�rmino do gozo de f�rias
         aAdd( aDados, AllTrim(aInfo[3])           ) // 14) inicializa nome da empresa
         aAdd( aDados, aInfo[8]                    ) // 15) inicializa CNPJ da empresa
         aAdd( aDados, 0                           ) // 16) inicializa dias de abono pecuni�rio
         aAdd( aDados, ""                          ) // 17) inicializa informa��es do aceite
         aAdd( aDados, SRA->RA_FILIAL              ) // 18) inicializa filial do funcion�rio
         aAdd( aDados, SRA->RA_MAT                 ) // 19) inicializa matr�cula do funcion�rio
         aAdd( aDados, SRA->RA_ADMISSA             ) // 20) inicializa admiss�o do funcion�rio
         aAdd( aDados, cToD(" / / ")               ) // 21) inicializa data do recibo
         
         If aIdVac[1] == "SRH" //F�rias Calculadas

            dbSelectArea("SRH")
            dbSetOrder(1) //Filial + Mat + DataBas + DataIni
            If SRH->(DBSeek(SRA->RA_FILIAL + SRA->RA_MAT + aIdVac[4] + aIdVac[5] ))
               aDados[1]  := "F"
               aDados[3]  := SRH->RH_DTAVISO
               aDados[8]  := SRH->RH_DIALRE1
               aDados[9]  := SRH->RH_DIALREM
               aDados[10] := SRH->RH_DATABAS
               aDados[11] := SRH->RH_DBASEAT 
               aDados[12] := SRH->RH_DATAINI
               aDados[13] := SRH->RH_DATAFIM
               aDados[16] := SRH->RH_DABONPE
               aDados[21] := SRH->RH_DTRECIB
            EndIf

         ElseIf aIdVac[1] == "SRF" //F�rias Programadas

            dPgDataBas := Ctod(Substr(aIdVac[4],7,2) + "/" + Substr(aIdVac[4],5,2) + "/" + Substr(aIdVac[4],1,4))
            dPgDataIni := Ctod(Substr(aIdVac[5],7,2) + "/" + Substr(aIdVac[5],5,2) + "/" + Substr(aIdVac[5],1,4))
            
            dbSelectArea("SRF")
            SRF->(dbSetOrder(1))  //Filial + Mat + DataBas + PD
         
            If SRF->(DbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
         
               While SRF->(!EoF()) .and. SRA->RA_FILIAL+SRA->RA_MAT == SRF->RF_FILIAL+SRF->RF_MAT
               
                  nDMes12  := 0
                  nDMes01  := 0

                  If SRF->RF_DATABAS == dPgDataBas
                     aDados[1]  := "P"
                     aDados[10] := SRF->RF_DATABAS
                     aDados[11] := SRF->RF_DATAFIM
                  
                     If SRF->RF_DATAINI == dPgDataIni
                        If lProjSRF
                           fChkLicRem( SRF->RF_DATAINI, SRF->RF_DATAINI + SRF->RF_DFEPRO1 - 1 , @nDMes12, @nDMes01, cDia2501)
                        EndIf
                        aDados[3]  := SRF->RF_DATAINI - 30
                        aDados[21] := DataValida(DataValida(SRF->RF_DATAINI-1,.F.)-1,.F.)
                        aDados[12] := SRF->RF_DATAINI
                        aDados[13] := SRF->RF_DATAINI + nDMes12 + nDMes01 + (SRF->RF_DFEPRO1 - 1) 
                        aDados[16] := SRF->RF_DABPRO1
                     ElseIf SRF->RF_DATINI2 == dPgDataIni
                        If lProjSRF
                           fChkLicRem( SRF->RF_DATINI2, SRF->RF_DATINI2 + SRF->RF_DFEPRO2 - 1 , @nDMes12, @nDMes01, cDia2501)
                        EndIf
                        aDados[3]  := SRF->RF_DATINI2 - 30
                        aDados[21] := DataValida(DataValida(SRF->RF_DATINI2-1,.F.)-1,.F.)
                        aDados[12] := SRF->RF_DATINI2
                        aDados[13] := SRF->RF_DATINI2 + nDMes12 + nDMes01 + (SRF->RF_DFEPRO2 - 1) 
                        aDados[16] := SRF->RF_DABPRO2
                     ElseIf SRF->RF_DATINI3 == dPgDataIni
                        If lProjSRF
                           fChkLicRem( SRF->RF_DATINI3, SRF->RF_DATINI3 + SRF->RF_DFEPRO3 - 1 , @nDMes12, @nDMes01, cDia2501)
                        EndIf
                        aDados[3]  := SRF->RF_DATINI3 - 30
                        aDados[21] := DataValida(DataValida(SRF->RF_DATINI3-1,.F.)-1,.F.)
                        aDados[12] := SRF->RF_DATINI3
                        aDados[13] := SRF->RF_DATINI3 + nDMes12 + nDMes01 + (SRF->RF_DFEPRO3 - 1) 
                        aDados[16] := SRF->RF_DABPRO3
                     EndIf

                     Exit
                  EndIf

                  SRF->(DbSkip())
               EndDo
         
            EndIf 
         EndIf
         
         If aDados[1] != ""
            
            //------------------------------------------------------------------------------
            //Existe um problema ainda nao solucionado que o APP envia mais de uma requisicao via mobile
            //Quando isso ocorre o sistema nao gera o arquivo e envia uma resposta sem conteudo. 
            //Solucao paliativa:
            //Caso alguma requisicao falhe tentaremos gerar o arquivo novamente por 3 vezes no maximo
            //Cada nova requisicao ira gerar o arquivo com um nome diferente (Filial + Matricula + nX) 
            //------------------------------------------------------------------------------
            For nX := 1 To 3

               //Se existir o arquivo REL/PDF nao executamos a geracao porque indica uma requisicao em andamento
               If !File( cArqLocal + cFileName + cExtFile + '*' )
                  //Faz a geracao do arquivo PDF do aviso de f�rias
                  If lImpESP
                     U_NOTICEVACATIONREPORT(aDados, cArqLocal, cFileName + cExtFile + cValToChar(nX))
                  Else
                     ImpNotVacation(aDados, cArqLocal, cFileName + cExtFile + cValToChar(nX))
                  EndIf
               EndIf
            
               //Avalia o arquivo gerado no servidor
               While lContinua
                  
                  If File( cArqLocal + cFileName + cExtFile + cValToChar(nX) + cPDF )
                     oFile := FwFileReader():New( cArqLocal + cFileName + cExtFile + cValToChar(nX) + cPDF )
                     
                     If (oFile:Open())
                        cFile := oFile:FullRead()
                        oFile:Close()
                        lSucess := .T.
                     EndIf
                  EndIf
         
                  //Em determinados ambientes pode ocorrer demora na geracao do arquivo, entao tentar localizar por 5 segundos no maximo.
                  If ( lContinua := Empty(cFile) .And. nCont <= 4 )
                     nCont++
                     Sleep(1000)
                  EndIf
               End
            
               If !Empty(cFile)
                  Exit
               Else
                  lContinua := .T.
                  Conout( EncodeUTF8(">>>"+ STR0030 +"("+ cValToChar(nX) +")") ) //"Aguardando a geracao do recibo de f�rias..."
               EndIf

            Next nX
         EndIf    

      EndIf

      //Se algum erro impediu a geracao do arquivo, faz a geracao de um arquivo PDF com a mensagem do erro.
      If Empty( cFile )
         aAdd( aLog, STR0031 ) //"Durante o processamento ocorreram erros que impediram a grava��o dos dados. Contate o administrador do sistema."
         aAdd( aLog, "" )
         aAdd( aLog, STR0032 ) //"Poss�veis causas do problema:"
         aAdd( aLog, "- " + STR0033 ) //"Erro na gera��o do arquivo pdf no servidor."
         aAdd( aLog, "- " + STR0034 ) //"Erro na consulta do registro de programa��o de f�rias."
         aAdd( aLog, "- " + STR0036 ) //"Funcionalidade RDMAKE RHNPMEURH n�o compilada no RPO."

         fPDFMakeFileMessage( aLog, cFileName, @cFile ) 
      Else 
         //Atualiza informa��o de download do recibo de f�rias calculadas
         If aDados[1] == "SRH"
            Begin Transaction
               SRH->( Reclock("SRH",.F.) )
               RH_ACEITE := "MeuRH Download" +"|" +DtoS(Date()) +"|" +Time() +"|" +SRA->RA_CIC +"|" +SRA->RA_NOME 
               SRH->( MsUnlock() )
               SRH->( FkCommit() )
            End Transaction
         EndIf
      EndIf  

      //Exclui os arquivos temporarios gerados durante o processamento (REL/PDF/PD_)
      fExcFileMRH( cArqLocal + cFileName + '*' )

      If lRobot
         cFile := If( lSucess, "ARQUIVO_GERADO", "")
      EndIf

      If lChangeEmp
         fNewEmpFiles(cSavEmp, cSavFil, {"SRA","SRJ","SRH","SRF"})
      EndIf

      ::SetHeader("Content-Disposition", "attachment; filename=" + cFileName + cPDF)
      ::SetResponse(cFile)
      
   EndIf

Return( lRet )

// -------------------------------------------------------------------
// Retorna o arquivo PDF do recibo de f�rias
// -------------------------------------------------------------------
WSMETHOD GET ReportVacation WSREST Vacation

Local cToken      := ""
Local cKeyId      := ""
Local cMatSRA     := ""
Local cBranchVld  := ""
Local cLogin      := ""
Local cRD0Cod     := ""
Local cExtFile    := ""
Local cFile       := ""
Local cFileName   := ""
Local cArqLocal   := ""
Local cSavFil     := cFilAnt
Local cSavEmp     := cEmpAnt
Local cEmpSRA     := cEmpAnt
Local cRoutine    := "W_PWSA100A.APW" 
Local cPDF        := ".PDF"
Local nX          := 0
Local nCont       := 0
Local aVerbas     := {}
Local aCabec      := {}
Local aInfo       := {}
Local aLog        := {}
Local aIdFunc     := {}
Local aDataLogin  := {}
Local aQryParam 	:= Self:aQueryString
Local lDemit		:= .F.
Local lHabil		:= .T.
Local lRobot      := .F.
Local lSucess     := .F.
Local lChangeEmp  := .F.
Local lImpESP     := ExistBlock("VACATIONREPORT")

Self:SetContentType("application/json")
Self:SetHeader('Access-Control-Allow-Credentials' , "true")

cToken	  := Self:GetHeader('Authorization')
cKeyId  	  := Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len(aDataLogin) > 0
   cMatSRA    := aDataLogin[1]
   cLogin     := aDataLogin[2]
   cRD0Cod    := aDataLogin[3]
   cBranchVld := aDataLogin[5]
   lDemit     := aDataLogin[6]
EndIf

If Len(::aUrlParms) == 4

	If !Empty(::aUrlParms[2]) .And. !( "current" $ ::aUrlParms[3] )
      aIdFunc := STRTOKARR( ::aUrlParms[3], "|" )
      If Len(aIdFunc) > 1
         If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
            //Valida Permissionamento
            fPermission(cBranchVld, cLogin, cRD0Cod, "vacationReceipt", @lHabil)
            If !lHabil .Or. lDemit
               SetRestFault(400, EncodeUTF8( STR0057 )) //"Permiss�o negada aos servi�os para recibo de f�rias!"
               Return (.F.)  
            EndIf
         Else 
            //Valida Permissionamento
            fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementVacation", @lHabil)
            If !lHabil .Or. lDemit
               SetRestFault(400, EncodeUTF8( STR0057 )) //"Permiss�o negada aos servi�os para recibo de f�rias!"
               Return (.F.)  
            //valida se o solicitante da requisi��o pode ter acesso as informa��es
            ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
               cBranchVld	:= aIdFunc[1]
               cMatSRA		:= aIdFunc[2]
               cEmpSRA		:= aIdFunc[3]
               lChangeEmp  := !(cEmpSRA == cEmpAnt)              
            Else
               SetRestFault(400, EncodeUTF8( STR0064 )) //Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time.
               Return (.F.) 
            EndIf
         EndIf	
      EndIf
   Else
      //Valida Permissionamento
      fPermission(cBranchVld, cLogin, cRD0Cod, "vacationReceipt", @lHabil)
      If !lHabil .Or. lDemit
         SetRestFault(400, EncodeUTF8( STR0057 )) //"Permiss�o negada aos servi�os para recibo de f�rias!"
         Return (.F.)  
      EndIf
	EndIf

	If lChangeEmp
		fNewEmpFiles(cEmpSRA, cBranchVld, {"SRA","SRJ","SRH","SRF","CTT",'SQB'})
	EndIf

	//Posiciona no funcionario que esta sendo impresso
   DbSelectArea("SRA")
   SRA->( dbSetOrder(1) )
   lContinua := SRA->( dbSeek( cBranchVld + cMatSRA ) )	

   If lContinua .And. !Empty(::aUrlParms[3])
      
      aIdVac := STRTOKARR( ::aUrlParms[4], "|" )
      cRecno := If( Len(aIdVac) > 5, aIdVac[6], "" )

      //Obtem o periodo da queryparam que veio na requisicao
      For nX := 1 To Len( aQryParam )
         If UPPER(aQryParam[nX,1]) == "EXECROBO"
            lRobot := .T.
         EndIf
      Next

      If !Empty(cRecno)
      
         //Busca os dados das ferias
         fVacationDetail( cBranchVld, cMatSRA, cRecno, @aCabec, @aVerbas, cEmpSRA )

         If !Empty(aCabec) .And. !Empty(aVerbas)

            fInfo(@aInfo, cBranchVld, cEmpSRA)
         
            cExtFile	 := DTOS( DATE() ) + SubStr( TIME(), 1, 2) //Ano + Mes + Dia + Hora
            cFileName := Alltrim(cBranchVld) + "_" + Alltrim(cMatSRA) + "_vacation_"
            cArqLocal := GetSrvProfString ("STARTPATH","")
         
            For nX := 1 To 3

               //Se existir o arquivo REL/PDF nao executamos a geracao porque indica uma requisicao em andamento
               If !File( cArqLocal + cFileName + cExtFile + '*' )
                  //Faz a geracao do arquivo PDF do recibo de f�rias
                  If lImpESP
                     U_VACATIONREPORT( aCabec, aVerbas, aInfo, cArqLocal, cFileName + cExtFile + cValToChar(nX) )
                  Else
                     ImpRecVacation( aCabec, aVerbas, aInfo, cArqLocal, cFileName + cExtFile + cValToChar(nX) )                     
                  EndIf
               EndIf
            
               //Avalia o arquivo gerado no servidor
               While lContinua
                     
                  If File( cArqLocal + cFileName + cExtFile + cValToChar(nX) + cPDF )
                     oFile := FwFileReader():New( cArqLocal + cFileName + cExtFile + cValToChar(nX) + cPDF )
                  
                     If (oFile:Open())
                        cFile := oFile:FullRead()
                        oFile:Close()
                        lSucess := .T.
                     EndIf
                  EndIf
            
                  //Em determinados ambientes pode ocorrer demora na geracao do arquivo, entao tentar localizar por 5 segundos no maximo.
                  If ( lContinua := Empty(cFile) .And. nCont <= 4 )
                     nCont++
                     Sleep(1000)
                  EndIf
               End
               
               If !Empty(cFile)
                  Exit
               Else
                  lContinua := .T.
                  Conout( EncodeUTF8(">>>"+ STR0030 +"("+ cValToChar(nX) +")") ) //"Aguardando a geracao do recibo de f�rias..."
               EndIf
            Next nX
         EndIf
      EndIf
	EndIf
EndIf

If Empty( cFile )
	aAdd( aLog, STR0031 ) //"Durante o processamento ocorreram erros que impediram a grava��o dos dados. Contate o administrador do sistema."
	aAdd( aLog, "" )
	aAdd( aLog, STR0032 ) //"Poss�veis causas do problema:"
	aAdd( aLog, "- " + STR0033 ) //"Erro na gera��o do arquivo pdf no servidor."
	aAdd( aLog, "- " + STR0034 ) //"Erro na consulta do registro de programa��o de f�rias."
	aAdd( aLog, "- " + STR0036 ) //"Funcionalidade RDMAKE RHNPMEURH n�o compilada no RPO."

	fPDFMakeFileMessage( aLog, cFileName, @cFile ) 
EndIf  

//Exclui os arquivos temporarios gerados durante o processamento (REL/PDF/PD_)
fExcFileMRH( cArqLocal + cFileName + '*' )

If lRobot
   cFile := If( lSucess, "ARQUIVO_GERADO", "")
EndIf

If lChangeEmp
   fNewEmpFiles(cSavEmp, cSavFil, {"SRA","SRJ","SRH","SRF","CTT",'SQB'})
EndIf

Self:SetHeader("Content-Disposition", "attachment; filename=" + cFileName + cPDF)
Self:SetResponse(cFile)

Return( .T. )

// -------------------------------------------------------------------
// Retorna o detalhe do recibo de f�rias
// -------------------------------------------------------------------
WSMETHOD GET getDetailVacation WSREST Vacation

Local oItem       := JsonObject():New()
Local oItemDetail := JsonObject():New()
Local oEvents     := JsonObject():New() 
Local oSubtot     := JsonObject():New()
Local nX          := 0
Local cMsg        := ""
Local cToken      := ""
Local cKeyId      := ""
Local cMatSRA     := ""
Local cBranchVld  := ""
Local cLogin      := ""
Local cRD0Cod     := ""
Local cDtAviso    := "" 
Local cDtRecibo   := ""
Local cSRHtab     := ""
Local cSRRtab     := ""
Local cSRVtab     := ""
Local cJoinFil    := ""
Local cEmpSRA     := cEmpAnt
Local lRet        := .T.
Local lDemit      := .F.
Local lHabil      := .T.
Local aIdFunc     := {}
Local aTmpEvent   := {}
Local aEvents     := {}
Local aSubtot     := {}
Local aTmpSub     := {0,0,0}
Local aDataLogin  := {}
Local cPDLiq      := fGetCodFol("0102")
Local cQrySRH     := ""
Local cQrySRR     := ""
Local cRoutine    := "W_PWSA100A.APW" 

::SetContentType("application/json")
::SetHeader('Access-Control-Allow-Credentials' , "true")

cToken  	  := Self:GetHeader('Authorization')
cKeyId  	  := Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len(aDataLogin) > 0
   cMatSRA    := aDataLogin[1]
   cLogin     := aDataLogin[2]
   cRD0Cod    := aDataLogin[3]
   cBranchVld := aDataLogin[5]
   lDemit     := aDataLogin[6]
EndIf

If Len(::aUrlParms) == 3

	If !Empty(::aUrlParms[2]) .And. !( "current" $ ::aUrlParms[2] )
      aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
      If Len(aIdFunc) > 1 
         If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
            //Valida Permissionamento
            fPermission(cBranchVld, cLogin, cRD0Cod, "vacationReceipt", @lHabil)
            If !lHabil .Or. lDemit
               SetRestFault(400, EncodeUTF8( STR0057 )) //"Permiss�o negada aos servi�os para recibo de f�rias!"
               Return (.F.)  
            EndIf
         Else
            //Valida Permissionamento
            fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementVacation", @lHabil)
            If !lHabil .Or. lDemit
               SetRestFault(400, EncodeUTF8( STR0057 )) //"Permiss�o negada aos servi�os para recibo de f�rias!"
               Return (.F.)  
            //valida se o solicitante da requisi��o pode ter acesso as informa��es
            ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
               cBranchVld	:= aIdFunc[1]
               cMatSRA		:= aIdFunc[2]
               cEmpSRA		:= aIdFunc[3]
            Else
               SetRestFault(400, EncodeUTF8( STR0064 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
               Return (.F.)  
            EndIf
         EndIf	
      EndIf
   Else
      //Valida Permissionamento
      fPermission(cBranchVld, cLogin, cRD0Cod, "vacationReceipt", @lHabil)
      If !lHabil .Or. lDemit
         SetRestFault(400, EncodeUTF8( STR0057 )) //"Permiss�o negada aos servi�os para recibo de f�rias!"
         Return (.F.)  
      EndIf
	EndIf

	If !Empty(::aUrlParms[3]) 
		aIdVac := STRTOKARR( ::aUrlParms[3], "|" )
		cRecno := aIdVac[6]
		
		If "SRF" $ aIdVac[1]
			dbSelectArea("SRH")
			If SRH->( dbSeek( cBranchVld + cMatSRA + aIdVac[4] + aIdVac[5]) )
				cRecno := Recno()
			EndIf
		EndIf

		cQrySRH  := GetNextAlias()
		cQrySRR  := GetNextAlias()		
		cSRHtab  := "%" + RetFullName("SRH", cEmpSRA) + "%"
		cSRRtab  := "%" + RetFullName("SRR", cEmpSRA) + "%"
		cSRVtab  := "%" + RetFullName("SRV", cEmpSRA) + "%"
		cJoinFil := "%" + FWJoinFilial("SRR", "SRV")  + "%"

        //aIdVac[1] - Tipo do registro de f�rias SRF ou SRH
        //aIdVac[2] - Filial
        //aIdVac[3] - Matr�cula
        //aIdVac[4] - Data Base
        //aIdVac[5] - Data Inicial
        //aIdVac[6] - RECNO

		//Executa a query para obter dados do cabecalho das ferias
		BEGINSQL ALIAS cQrySRH
		    COLUMN RH_DATAINI AS DATE
		    COLUMN RH_DTAVISO AS DATE
		    COLUMN RH_DTRECIB AS DATE
		
			SELECT 
				SRH.RH_FILIAL,
				SRH.RH_MAT,
				SRH.RH_DATAINI,
				SRH.RH_DTAVISO,
				SRH.RH_DTRECIB,
				SRH.R_E_C_N_O_
			FROM 
				%exp:cSRHtab% SRH
			WHERE 
				SRH.RH_FILIAL   = %Exp:cBranchVld% AND 
				SRH.RH_MAT      = %Exp:cMatSRA %   AND
				SRH.R_E_C_N_O_  = %Exp:cRecno % AND
				SRH.%NotDel%
		ENDSQL    
		
		While (cQrySRH)->(!Eof())    

			cDtAviso  := (cQrySRH)->RH_DTAVISO 
			cDtRecibo := (cQrySRH)->RH_DTRECIB

			//Executa a query para obter dados dos itens das ferias
			BEGINSQL ALIAS cQrySRR
				SELECT 
					SRR.RR_PD, SRR.RR_HORAS, SRR.RR_VALOR,
					SRV.RV_TIPOCOD, SRV.RV_DESC
				FROM 
					%exp:cSRRtab% SRR
				INNER JOIN %exp:cSRVtab% SRV
					ON %exp:cJoinFil% AND SRV.%NotDel% AND SRR.RR_PD = SRV.RV_COD
				WHERE 
					SRR.RR_FILIAL = %Exp:(cQrySRH)->RH_FILIAL%  AND
					SRR.RR_MAT    = %Exp:(cQrySRH)->RH_MAT%     AND
					SRR.RR_TIPO3  = %Exp:'F'%                   AND
					SRR.RR_DATA   = %Exp:(cQrySRH)->RH_DATAINI% AND					
					SRR.%NotDel%
			ENDSQL
			
			While (cQrySRR)->( !Eof() )
				
				//A verba Liquido de Ferias so pode ser demonstrada no subtotal
				If (cQrySRR)->RR_PD == cPDLiq 
					aTmpSub[3] += (cQrySRR)->RR_VALOR
				Else
					//As demais verbas de provento e desconto serao somadas para compor o subtotal 
					//e serao adicionadas no array aTmpEvent para compor os eventos das ferias
					DO CASE
						CASE (cQrySRR)->RV_TIPOCOD == "1" //Proventos
							aTmpSub[1] += (cQrySRR)->RR_VALOR
							cType := "proceeds"
							
						CASE (cQrySRR)->RV_TIPOCOD == "2" //Descontos
							aTmpSub[2] += (cQrySRR)->RR_VALOR
							cType := "deductions"
							
						OTHERWISE
							//Bases
							cType := "tax-base"
					END CASE
	
					aAdd( aTmpEvent, { ;
									cType,; 
									(cQrySRR)->RR_PD,;
									(cQrySRR)->RR_VALOR,; 
									(cQrySRR)->RR_HORAS,;
									AllTrim( (cQrySRR)->RV_DESC ) } )
				EndIf
				
				(cQrySRR)->(DbSkip())
			Enddo

			(cQrySRH)->(DbSkip())
        Enddo
        
		//Gera os dados das verbas
		For nX := 1 To Len(aTmpEvent) 
			oEvents 				:= JsonObject():New() 
			oEvents["type"]			:= aTmpEvent[nX,1]
			oEvents["id"]			:= aTmpEvent[nX,2]
			oEvents["value"]		:= aTmpEvent[nX,3]
			oEvents["quantity"]		:= aTmpEvent[nX,4] 
			oEvents["description"]	:= aTmpEvent[nX,5]
			aAdd( aEvents, oEvents )
		Next nX        

		//Gera os dados dos subtotais
		For nX := 1 To 3 
			oSubtot 				:= JsonObject():New() 
			oSubtot["type"]			:= If( nX == 1, "proceeds", If( nX == 2, "deductions", "net-value"))
			oSubtot["value"]		:= aTmpSub[nX]
			oSubtot["description"]	:= If( nX == 1, EncodeUTF8(STR0039), If( nX == 2, EncodeUTF8(STR0040), EncodeUTF8(STR0041) ) ) //"Proventos"#"Descontos"#"L�quido"
			aAdd( aSubtot, oSubtot )
		Next nX

		//Gera os elementos do JSON
		oItemDetail["id"]         := ::aUrlParms[3]
		oItemDetail["payDate"]    := FwTimeStamp(6, cDtRecibo, "12:00:00" ) 
		oItemDetail["noticeDate"] := FwTimeStamp(6, cDtAviso,  "12:00:00" )
		oItemDetail["subtotals"]  := aSubtot        
		oItemDetail["events"]     := aEvents

		oItem["data"]		:= oItemDetail
		oItem["length"]		:= 1
		oItem["messages"]	:= {}
	Else
		cMsg := EncodeUTF8( STR0042 ) //"N�o foi poss�vel consultar os dados do recibo. Tente novamente e se o problema persistir contate o administrador do sistema"
		lRet := .F.
	EndIf

    (cQrySRH)->( DBCloseArea() )
    (cQrySRR)->( DBCloseArea() )

EndIf

If lRet
	cJson := oItem:ToJson()
	::SetResponse(cjson)
Else
	SetRestFault(400, cMsg)
EndIf

Return( lRet )


/*/{Protheus.doc} fVldSolicFer
   Valida��es genericas relacionadas as f�rias  
/*/
Function fVldSolicFer(cFil, cMat, cDataIni, cDataFim, nFerDuracao, nDiasVendidos, lSolic13, cIniPer, cFimPer, cKey, cEmpSRA)
Local lRefTrab   := FindFunction("fRefTrab") .And. fRefTrab("F")
Local cMsgValid  := ""
Local cSavFil    := cFil
Local cSavEmp    := cEmpAnt
Local aDadosSRH  := {}
Local aOcurances := {}
Local aPerFerias := {}
Local lChangeEmp := !(cEmpSRA == cEmpAnt)

DEFAULT cIniPer  := ""
DEFAULT cKey     := ""
DEFAULT cEmpSRA  := cEmpAnt

// Valida idade.
cMsgValid := fVldIdade(cFil, cMat, nFerDuracao, lRefTrab, cEmpSRA)

//Valida Feriado.
If Empty(cMsgValid)
   cMsgValid := fVldFeriado(cFil, cMat, cDataIni, lRefTrab )
EndIf

//Valida dia da semana
If Empty(cMsgValid)
   cMsgValid := fVldDSemana(cFil, cMat, cDataIni)
EndIf

//Valida f�rias iniciadas em Jan ou Dez
If Empty(cMsgValid) .And. lSolic13
   cMsgValid := VldDtFer13( cTod(cDataIni) )
EndIf

//Valida solicita��o de f�rias com anteced�ncia.
If Empty(cMsgValid)
   cMsgValid := fVldDtSol(cDataIni)
EndIf

//Ferias que foram solicitadas pelo Portal GCH n�o possuem os dados do per�odo aquisitivo.
GetDtBasFer(cFil, cMat, @aPerFerias, cEmpSRA, cIniPer)
If Empty(cIniPer) .Or. Empty(cFimPer)
   If Len(aPerFerias) > 0
      cIniPer := DTOC(aPerFerias[1,1])
      cFimPer := DTOC(aPerFerias[1,2])
   EndIf
EndIf

aDadosSRH := fGetSRH( cFil, cMat, CTOD(cIniPer), CTOD(cFimPer), , , cEmpSRA )
If Empty(cMsgValid)
   cMsgValid := fVldSRF(cFil, cMat, cDataIni, nFerDuracao, nDiasVendidos, lSolic13, cIniPer, cEmpSRA)
EndIf

//Valida programa��es conforme a nova reforma trabalhista.
//Verifica se tem alguma solicita��o ainda n�o aprovada.
GetVacationWKF(@aOcurances, cMat, cFil, cMat, cFil, cEmpSRA, "'1','4'")
If Empty(cMsgValid)
   If lChangeEmp
      fNewEmpFiles(cEmpSRA, cFil, {"RCA","SRA","SRF","RCC","RCH"})
   EndIf

   cMsgValid := fVldRefTrab(cFil, cMat, nFerDuracao, nDiasVendidos, lRefTrab, aDadosSRH, cKey, aOcurances, aPerFerias, cEmpSRA)

   If lChangeEmp
      fNewEmpFiles(cSavEmp, cSavFil, {"RCA","SRA","SRF","RCC","RCH"})
   EndIf
EndIf

//Valida f�rias em conflito na SRH.
If Empty(cMsgValid)
   cMsgValid := fVldSRH(cFil, cMat, cDataIni, cDataFim, nFerDuracao, nDiasVendidos, aDadosSRH, cIniPer, cFimPer)
EndIf

//Valida f�rias j� solicitadas e que est�o em aberto.
If Empty(cMsgValid)
   cMsgValid := fVldFerWfl(cFil, cMat, cDataIni, cDataFim, cKey, aOcurances)
EndIf

//Valida se existe mais de um adiantamento de d�cimo terceiro.
If Empty(cMsgValid) .And. lSolic13
   cMsgValid := fVld13Wkfl(aOcurances, cKey, cDataIni)
EndIf

Return( cMsgValid )

// -------------------------------------------------------------------
// GET - Retorna dados das f�rias calculadas por�m ainda n�o inciadas
//       Pois ser�o apresentadas no cabe�alho do recibo de f�rias do servi�o vacationInfo.
// SRH - (F�rias calculadas)
//
// retorna estrutura "vacationInfoResponse"
// -- hasNext
// -- Array of vacationInfo
// -------------------------------------------------------------------
WSMETHOD GET vacationProcess WSREST Vacation
Local oVac           := JsonObject():New()
Local oItem          := JsonObject():New()
Local cQuery         := GetNextAlias()
Local cToken         := ""
Local cKeyId         := ""
Local cMatSRA        := ""
Local cLogin         := ""
Local cRD0Cod        := ""
Local cBranchVld     := ""
Local cDtFer         := ""
Local cSRHtab        := ""
Local cEmpSRA        := cEmpAnt
Local cStatusFer     := "calculated"
Local cRoutine       := "W_PWSA100A.APW" 
Local lDemit         := .F.
Local lHabil         := .T.
Local aDataLogin     := {}
Local aIdFunc        := {}
Local aVac           := {}
Local nLenParms      := Len(::aURLParms)

::SetHeader('Access-Control-Allow-Credentials' , "true")
cToken     := Self:GetHeader('Authorization')
cKeyId  	  := Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len(aDataLogin) > 0
   cMatSRA    := aDataLogin[1]
   cLogin     := aDataLogin[2]
   cRD0Cod    := aDataLogin[3]
   cBranchVld := aDataLogin[5]
	lDemit     := aDataLogin[6]
EndIf

//avalia solicitante e destino da requisi��o 
If nLenParms > 0 .And. !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2])
   aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
   If Len(aIdFunc) > 1
      If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
         //Valida Permissionamento do recibo de f�rias.
         fPermission(cBranchVld, cLogin, cRD0Cod, "vacationReceipt", @lHabil)
         If !lHabil .Or. lDemit
            SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
            Return (.F.)  
         EndIf
      Else
         //Valida Permissionamento do recibo de f�rias.
         fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementVacation", @lHabil)
         If !lHabil .Or. lDemit
            SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
            Return (.F.)  
         //valida se o solicitante da requisi��o pode ter acesso as informa��es
         ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
            cBranchVld	:= aIdFunc[1]
            cMatSRA		:= aIdFunc[2]
            cEmpSRA		:= aIdFunc[3]
         Else
            SetRestFault(400, EncodeUTF8( STR0064 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
            Return (.F.)  
         EndIf
      EndIf	
   EndIf
Else
   //Valida Permissionamento do recibo de f�rias.
   fPermission(cBranchVld, cLogin, cRD0Cod, "vacationReceipt", @lHabil)
   If !lHabil .Or. lDemit
      SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
      Return (.F.)  
   EndIf
EndIF

If !Empty(cBranchVld) .And. !Empty(cMatSRA)

   cSRHtab := "%" + RetFullName("SRH", cEmpSRA) + "%"

   //================================== 
   //Avalia as f�rias calculadas na SRH
	BEGINSQL ALIAS cQuery
         COLUMN RH_DATABAS AS DATE
         COLUMN RH_DBASEAT AS DATE
         COLUMN RH_DATAINI AS DATE
         COLUMN RH_DATAFIM AS DATE
		SELECT 
			SRH.RH_DATABAS,
			SRH.RH_DBASEAT,
			SRH.RH_DATAINI,
			SRH.RH_DATAFIM,
			SRH.RH_DABONPE,
			SRH.RH_DFERIAS,
			SRH.RH_DFERVEN,
			SRH.RH_PERC13S,
			SRH.R_E_C_N_O_,
			SRH.RH_FILIAL,
			SRH.RH_MAT
		FROM 
			%exp:cSRHtab% SRH
		WHERE 
			SRH.RH_FILIAL   = %Exp:cBranchVld% AND 
			SRH.RH_MAT      = %Exp:cMatSRA %   AND
         SRH.RH_DATAINI  > %Exp:dDataBase%  AND
			SRH.%NotDel%
		   ORDER BY
			1,3 DESC		 
	ENDSQL

	While (cQuery)->(!Eof())
	
      oVac            := JsonObject():New() 
      oVac["balance"] := (cQuery)->RH_DFERVEN             //Saldo dispon�vel
      oVac["days"]    := (cQuery)->RH_DFERIAS             //Dias de f�rias
      oVac["status"]  := cStatusFer                       //"approved" "approving" "reject" "empty" "closed"

      cDtFer := dToS((cQuery)->RH_DATAINI)
      cDtFer := SubStr( cDtFer, 1, 4 ) + "-" + ;
                SubStr( cDtFer, 5, 2 ) + "-" + ;
                SubStr( cDtFer, 7, 2 )                    //Data de in�cio das f�rias
      oVac["initVacation"] := cDtFer                      //Data inicial das f�rias
     
      cDtFer := dToS((cQuery)->RH_DATAFIM)
      cDtFer := SubStr( cDtFer, 1, 4 ) + "-" + ;
                SubStr( cDtFer, 5, 2 ) + "-" + ;
                SubStr( cDtFer, 7, 2 )                    //Data final das f�rias
      oVac["endVacation"]  := cDtFer                      //Data final das f�rias

      cDtFer := DtoS((cQuery)->RH_DATABAS)
      cDtFer := SubStr( cDtFer, 1, 4 ) + "-" + ;
                SubStr( cDtFer, 5, 2 ) + "-" + ;
                SubStr( cDtFer, 7, 2 )                    //Inicio do per�odo aquisitivo
      oVac["initPeriod"] := cDtFer                        //Inicio do per�odo aquisitivo  "2018-02-01T00:00:00Z"

      cDtFer := DtoS((cQuery)->RH_DBASEAT)
      cDtFer := SubStr( cDtFer, 1, 4 ) + "-" + ;
                SubStr( cDtFer, 5, 2 ) + "-" + ;
                SubStr( cDtFer, 7, 2 )                    //Final do per�odo aquisitivo
      oVac["endPeriod"] := cDtFer                         //Final do per�odo aquisitivo   "2019-01-31T00:00:00Z"
      oVac["statusLabel"]  := EncodeUTF8(STR0066)         //"N�o iniciada"
      oVac["id"]              := "SRH"                         +"|" +;
                                 (cQuery)->RH_FILIAL           +"|" +;
                                 (cQuery)->RH_MAT              +"|" +;              
                                 DtoS( (cQuery)->RH_DATABAS )  +"|" +;              
                                 DtoS( (cQuery)->RH_DATAINI )  +"|" +;              
                                 alltrim(str( (cQuery)->R_E_C_N_O_) )            //Identificador de f�rias

      oVac["vacationBonus"]   := (cQuery)->RH_DABONPE                          //Dias de abono
      oVac["advance"]         := (cQuery)->RH_PERC13S                          //optional - Adiantamento do 13
      If (cQuery)->RH_PERC13S > 0           
         oVac["hasAdvance"]  := .T.                                           //Se foi solicitado Adiantamento do 13
      Else
         oVac["hasAdvance"]  := .F.                                           //Se foi solicitado Adiantamento do 13
      EndIf    
      oVac["limitDate"]       := ""                                            //Data limite para solicita��o de f�rias
      oVac["canAlter"]        := .F.                                           //Verifica se a solicita��o de f�rias pode ser editada e exclu�da de acordo com o status
      Aadd(aVac,oVac)

          
      (cQuery)->(DBSkip())
	EndDo
	(cQuery)->(DBCloseArea())
EndIf

oItem["hasNext"] := .F.
oItem["items"]   := aVac

cJson := oItem:ToJson()
::SetResponse(cJson)

Return .T.

// -------------------------------------------------------------------
// GET - Retorna a quantidade de dias de f�rias que o funcion�rio ter� direito de acordo com a data de in�cio das f�rias.
//
// retorna estrutura "vacationBalanceAux"
// -- balanceAux
// -------------------------------------------------------------------
WSMETHOD GET balanceAux WSREST Vacation
Local oVac           := JsonObject():New()
Local cToken         := ""
Local cKeyId         := ""
Local cMatSRA        := ""
Local cLogin         := ""
Local cRD0Cod        := ""
Local cBranchVld     := ""
Local cEmpSRA        := cEmpAnt
Local lDemit         := .F.
Local lHabil         := .T.
Local aDataLogin     := {}
Local aIdFunc        := {}
Local nLenParms      := Len(::aURLParms)
Local dDtIniPer		:= If( nLenParms > 0, CtoD( Format8601(.T.,::aURLParms[4]) ), CTOD("//") )
Local dDtIniFer      := If( nLenParms > 0, CtoD( Format8601(.T.,::aURLParms[3]) ), CTOD("//") )
Local nDiasDir       := 0
Local lNotExist      := Type("P_REFMED") == "U"
Local cRoutine       := "W_PWSA100A.APW" 

::SetHeader('Access-Control-Allow-Credentials' , "true")
cToken     := Self:GetHeader('Authorization')
cKeyId  	  := Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len(aDataLogin) > 0
   cMatSRA    := aDataLogin[1]
   cLogin     := aDataLogin[2]
   cRD0Cod    := aDataLogin[3]
   cBranchVld := aDataLogin[5]
	lDemit     := aDataLogin[6]
EndIf

//avalia solicitante e destino da requisi��o 
If nLenParms > 0 .And. !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2])
   aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
   If Len(aIdFunc) > 1
      If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
         //Valida permissionamento da solicita��o de f�rias.
         fPermission(cBranchVld, cLogin, cRD0Cod, "vacationRegister", @lHabil)
         If !lHabil .Or. lDemit
            SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
            Return (.F.)  
         EndIf
      Else
         //Valida Permissionamento do recibo de f�rias.
         fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementVacation", @lHabil)
         If !lHabil .Or. lDemit
            SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
            Return (.F.)  
         //valida se o solicitante da requisi��o pode ter acesso as informa��es
         ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
            cBranchVld	:= aIdFunc[1]
            cMatSRA		:= aIdFunc[2]
            cEmpSRA		:= aIdFunc[3]
         Else
            SetRestFault(400, EncodeUTF8( STR0064 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
            Return (.F.)  
         EndIf	
      EndIf
   EndIf
Else
   //Valida permissionamento da solicita��o de f�rias.
   fPermission(cBranchVld, cLogin, cRD0Cod, "vacationRegister", @lHabil)
   If !lHabil .Or. lDemit
      SetRestFault(400, EncodeUTF8( STR0055 )) //"Permiss�o negada aos servi�os de f�rias!"
      Return (.F.)  
   EndIf
EndIF

If nLenParms > 0 .And. !Empty(cBranchVld) .And. !Empty(cMatSRA)
   If lNotExist
      SetMnemonicos( xFilial("RCA",cBranchVld) , Nil , .T.)
   EndIf   
   fProjDias(cBranchVld, cMatSRA, dDtIniFer, dDtIniPer, @nDiasDir, cEmpSRA)
   oVac["balanceAux"] := nDiasDir
   cJson := oVac:ToJson()
   Self:SetResponse(cJson)
EndIf

Return .T.

/*/{Protheus.doc} fVldWkf
   Valida��es para movimenta��o do workflow  
/*/
Function fVldWkf(cKey, cReq, cOper)
local cMsgFault := ""

default cKey  := ""
default cReq  := ""
default cOper := ""

    If cOper == "U" .or. cOper == "D"
    
       DBSelectArea("RH3")
       DBSetOrder(1)	//RH3_FILIAL+RH3_CODIGO
       If RH3->( dbSeek(cKey) )
          If RH3_NVLAPR != RH3_NVLINI   

             If Val( GetRGKSeq( cReq , .T.) ) == 2
                cMsgFault := ""
             Else
                cMsgFault := STR0024 //"N�o ser� poss�vel executar a requisi��o, pois o workflow foi movimentado"    
             EndIf
          EndIf
       Else   
          cMsgFault := STR0025 //"Identificador da solicita��o n�o localizado"
       EndIf

    ElseIf cOper == "I"
       
        If Val( GetRGKSeq( cReq , .T.) ) == 2
           cMsgFault := ""
        Else
           cMsgFault := STR0024 //"N�o ser� poss�vel executar a requisi��o, pois o workflow foi movimentado"    
        EndIf
    EndIf

Return( cMsgFault )


/*/{Protheus.doc} fGetVacationDetail
Efetua a inclusao ou a alteracao de uma solicitacao de atestado medico
@author:	Marcelo Silveira
@since:		27/05/2019
@param:		lNewReg - Indica se e inclusao (.T.) ou alteracao (.F.)
			cBranchVld - Filial;
			cMatSRA - Matr�cula;
			cBody - Json com o corpo da requisicao;
			oItemDetail - Objeto Json com o corpo da requisicao;
			cError - Erros durante a criacao do arquivo (referencia)
@return:	lRet - Verdadeiro se o registro foi incluido ou alterado com sucesso			
/*/
Function fVacationDetail(cBranchVld, cMatSRA, cRecno, aCabec, aVerbas, cEmpSRA )

Local cQrySRH     := GetNextAlias()
Local cSRHtab     := ""
Local cSRRtab     := ""
Local cSRVtab     := ""
Local cJoinFil    := ""
Local cQrySRR     := ""
Local lContinua   := .F.

DEFAULT cBranchVld   := ""
DEFAULT cMatSRA      := ""
DEFAULT cRecno       := ""
DEFAULT aCabec       := {}
DEFAULT aVerbas      := {}

If !Empty(cBranchVld) .And. !Empty(cMatSRA) .And. !Empty(cRecno)
	dbSelectArea( "SRA" )	
	SRR->(dbSetOrder(1))
	lContinua := dbSeek( cBranchVld + cMatSRA )	
EndIf

If lContinua

   cSRHtab  := "%" + RetFullName("SRH", cEmpSRA) + "%"
   cSRRtab  := "%" + RetFullName("SRR", cEmpSRA) + "%"
   cSRVtab  := "%" + RetFullName("SRV", cEmpSRA) + "%"
   cJoinFil := "%" + FWJoinFilial("SRR", "SRV")  + "%"

	//Executa a query para obter dados do cabecalho das ferias
	BEGINSQL ALIAS cQrySRH
      COLUMN RH_DATAINI AS DATE
      COLUMN RH_DATAFIM AS DATE
      COLUMN RH_DTAVISO AS DATE
      COLUMN RH_DTRECIB AS DATE
      COLUMN RH_DATABAS AS DATE
      COLUMN RH_DBASEAT AS DATE
	
		SELECT 
			SRH.RH_FILIAL,
			SRH.RH_MAT,
			SRH.RH_DFERIAS,
			SRH.RH_DATAINI,
			SRH.RH_DATAFIM,
			SRH.RH_DTAVISO,
			SRH.RH_DTRECIB,
			SRH.RH_DATABAS,
			SRH.RH_DBASEAT,
			SRH.RH_DIALREM,
			SRH.RH_DIALRE1,
			SRH.RH_DABONPE,
			SRH.RH_ABOPEC,
			SRH.RH_SALMES, 
			SRH.RH_SALHRS,
			SRH.RH_SALDIA,
			SRH.RH_SALDIA1,
			SRH.R_E_C_N_O_
		FROM 
			%exp:cSRHtab% SRH
		WHERE 
			SRH.RH_FILIAL   = %Exp:cBranchVld% AND 
			SRH.RH_MAT      = %Exp:cMatSRA %   AND
			SRH.R_E_C_N_O_  = %Exp:cRecno %    AND
			SRH.%NotDel%
	ENDSQL    
	
	If (cQrySRH)->(!Eof())
	
		cQrySRR := GetNextAlias()
	
		While (cQrySRH)->(!Eof())
		
			//Gera dados do cabecalho
			aAdd( aCabec, { ;
                        (cQrySRH)->RH_FILIAL,;
                        (cQrySRH)->RH_MAT,; 
                        (cQrySRH)->RH_DFERIAS,;
                        (cQrySRH)->RH_DATAINI,; 
                        (cQrySRH)->RH_DATAFIM,; 
                        (cQrySRH)->RH_DTAVISO,; 
                        (cQrySRH)->RH_DTRECIB,; 
                        (cQrySRH)->RH_DATABAS,; 
                        (cQrySRH)->RH_DBASEAT,; 
                        (cQrySRH)->RH_DIALREM,; 
                        (cQrySRH)->RH_DIALRE1,;
                        (cQrySRH)->RH_DABONPE,;
                        (cQrySRH)->RH_ABOPEC,;
                        (cQrySRH)->RH_SALMES,;
                        (cQrySRH)->RH_SALHRS,;
                        (cQrySRH)->RH_SALDIA,;
                        (cQrySRH)->RH_SALDIA1 } )
	
			//Executa a query para obter dados dos itens das ferias
			BEGINSQL ALIAS cQrySRR
				SELECT 
					SRR.RR_PD, SRR.RR_HORAS, SRR.RR_VALOR,
               SRV.RV_TIPOCOD, SRV.RV_CODFOL, SRV.RV_DESC
				FROM 
               %exp:cSRRtab% SRR
				INNER JOIN %exp:cSRVtab% SRV
					ON %exp:cJoinFil% AND SRV.%NotDel% AND SRR.RR_PD = SRV.RV_COD
				WHERE 
					SRR.RR_FILIAL = %Exp:(cQrySRH)->RH_FILIAL%  AND
					SRR.RR_MAT    = %Exp:(cQrySRH)->RH_MAT%     AND
					SRR.RR_TIPO3  = %Exp:'F'%                   AND
					SRR.RR_DATA   = %Exp:(cQrySRH)->RH_DATAINI% AND					
					SRR.%NotDel%
			ENDSQL
			
			While (cQrySRR)->( !Eof() )
				
				aAdd( aVerbas, { (cQrySRR)->RV_TIPOCOD, (cQrySRR)->RV_CODFOL, (cQrySRR)->RR_PD, (cQrySRR)->RR_VALOR, (cQrySRR)->RR_HORAS, AllTrim( (cQrySRR)->RV_DESC ) } )
				
				(cQrySRR)->(DbSkip())
			Enddo
	
			(cQrySRH)->(DbSkip())
	    Enddo
	    
	    (cQrySRR)->( DBCloseArea() )
	    
    EndIf

    (cQrySRH)->( DBCloseArea() )

EndIf

Return()

/*/{Protheus.doc} fGetSRH
Obtem os dados do cabe�alho de f�rias conforme os dados solicitados.
@author:	Marcelo Silveira
@since:		10/02/2020
@param:		cBranchVld - Filial;
			cMatSRA - Matr�cula;
			dDataBas - Data inicio periodo aquisitivo das ferias;
			dDataFim - Data fim periodo aquisitivo das ferias;
			dIniFer - Data inicio das ferias;
			dFimFer - Data fim das ferias;         
@return:	aDados - Array com o cabecalho das ferias			
/*/
Function fGetSRH(cBranchVld, cMatSRA, dDataBas, dDataFim, dIniFer, dFimFer, cEmpFun )

Local cQuerySRH      := ""
Local cWhereSRH      := ""
Local cTabSRH        := ""
Local cDelete        := "% SRH.D_E_L_E_T_ = ' ' %"
Local aDados         := {}

DEFAULT cBranchVld   := ""
DEFAULT cMatSRA      := ""
DEFAULT dDataBas     := ""
DEFAULT dDataFim     := ""
DEFAULT dIniFer      := ""
DEFAULT dFimFer      := ""
DEFAULT cEmpFun      := cEmpAnt

If !Empty(cBranchVld) .And. !Empty(cMatSRA)

   If !Empty(dDataBas)
      cWhereSRH += " SRH.RH_DATABAS = '" + dToS(dDataBas) + "'"
   EndIf

   If !Empty(dDataFim)
      cWhereSRH += If( Empty(cWhereSRH), "", " AND "  )
      cWhereSRH += " SRH.RH_DBASEAT = '" + dToS(dDataFim) + "' "
   EndIf

   If !Empty(dIniFer) .And. !Empty(dFimFer)
      cWhereSRH += If( Empty(cWhereSRH), "", " AND "  )
      cWhereSRH += " SRH.RH_DATAINI = '" + dIniFer + "' AND "
      cWhereSRH += " SRH.RH_DATAFIM = '" + dFimFer + "' "
   EndIf

   If !Empty(cWhereSRH)

      cTabSRH     := "%" + RetFullName("SRH", cEmpFun) + "%"
      cWhereSRH   := "% " + cWhereSRH + " %"
      cQuerySRH   := GetNextAlias()

      BEGINSQL ALIAS cQuerySRH
         COLUMN RH_DATABAS AS DATE
         COLUMN RH_DBASEAT AS DATE
         COLUMN RH_DATAINI AS DATE
         COLUMN RH_DATAFIM AS DATE

         SELECT 
            SRH.RH_DATABAS,
            SRH.RH_DBASEAT,
            SRH.RH_DATAINI,
            SRH.RH_DATAFIM,
            SRH.RH_DABONPE,
            SRH.RH_ACEITE,
            SRH.RH_DFERIAS,
            SRH.RH_DFERVEN,
            SRH.RH_PERC13S,
            SRH.R_E_C_N_O_,
            SRH.RH_FILIAL,
            SRH.RH_MAT
         FROM 
            %exp:cTabSRH% SRH
         WHERE 
            SRH.RH_FILIAL = %Exp:cBranchVld% AND 
            SRH.RH_MAT = %Exp:cMatSRA % AND
		      %Exp:cWhereSRH% AND
		      %exp:cDelete%            
      ENDSQL
      
      While (cQuerySRH)->(!Eof())
         
         aAdd( aDados, { ;
                        DTOS( (cQuerySRH)->RH_DATAINI ), ;
                        (cQuerySRH)->RH_DFERIAS, ;
                        DTOS( (cQuerySRH)->RH_DATAFIM ), ;
                        DTOS( (cQuerySRH)->RH_DATABAS ), ;
                        DTOS( (cQuerySRH)->RH_DBASEAT ), ;
                        (cQuerySRH)->RH_DABONPE, ;
                        (cQuerySRH)->RH_PERC13S, ;
                        Alltrim( STR((cQuerySRH)->R_E_C_N_O_) );
                     } )

         (cQuerySRH)->(DBSkip())
      EndDo 
      
      (cQuerySRH)->(DBCloseArea())

   EndIf
        
EndIf        
        
Return( aDados )

/*/{Protheus.doc} fMRhGetFal
Obtem as Faltas do funcion�rio 
@author: raquel.andrade
@since:	01/12/2020
@param:	cBranchVld  - Filial;
         cMatSRA     - Matr�cula;
         cEmpSRA     - Empresa do funcionario;
@return: nRet		
/*/
Function fMRhGetFal(cBranchVld,cMatSRA,cEmpSRA)
Local cAliasSRA   := ""
Local cAliasSRC   := ""
Local cPd054      := ""
Local cPd055      := ""
Local cPd203      := ""
Local cPd242      := ""
Local cPd243      := ""
Local cPd244      := ""
Local cPd245      := ""
Local cPdSoma     := ""
Local cPdSub      := ""
Local cVerbaPesq  := ""
Local cWhere      := ""
Local cJoinSRV    := ""
Local cTabSRA     := ""
Local cTabSRC     := ""
Local cTabSRV     := ""
Local cDelSRC     := "% SRC.D_E_L_E_T_ = ' ' %"
Local cDelSRA     := "% SRA.D_E_L_E_T_ = ' ' %"
Local nRet        := 0

Private aCodFol
Fp_CodFol(@aCodFol,cBranchVld,,.F.)

If !Empty(cBranchVld) .And. !Empty(cMatSRA)

   cAliasSRA   := GetNextAlias()
   cTabSRA     := "%" + RetFullName("SRA", cEmpSRA) + "%"

   BEGINSQL ALIAS cAliasSRA
      SELECT 
         SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_HRSMES
      FROM 
         %exp:cTabSRA% SRA
      WHERE 
         SRA.RA_FILIAL = %Exp:cBranchVld% AND 
         SRA.RA_MAT = %Exp:cMatSRA% AND
         %exp:cDelSRA%
   ENDSQL

   If (cAliasSRA)->(!Eof())

      cPd054 := aCodFol[54,1]
      cPd055 := aCodFol[55,1]
      cPd203 := aCodFol[203,1]
      cPd242 := aCodFol[242,1]
      cPd243 := aCodFol[243,1]
      cPd244 := aCodFol[244,1]
      cPd245 := aCodFol[245,1]

      cWhere := "%"
      cWhere += "SRC.RC_PD IN ('"+cPd054+"'"
      cWhere += ",'" + cPd055 +"'"
      cWhere += ",'" + cPd203 +"'"
      cWhere += ",'" + cPd242 +"'"
      cWhere += ",'" + cPd243 +"'"
      cWhere += ",'" + cPd244 +"'"
      cWhere += ",'" + cPd245 +"'"
      cWhere += ")"
      cWhere += "%"

      cAliasSRC   := GetNextAlias()
      cTabSRC     := "%" + RetFullName("SRC", cEmpSRA) + "%"
      cTabSRV     := "%" + RetFullName("SRV", cEmpSRA) + "%"
      cJoinSRV    := "%" + FWJoinFilial("SRC", "SRV")  + " AND SRC.RC_PD=SRV.RV_COD AND SRV.D_E_L_E_T_=' ' %"      

      cPdSoma     := cPd054 +"/"+ cPd055 +"/"+ cPd203 +"/"+ cPd242 +"/"+ cPd243
      cPdSub      := cPd244 +"/"+ cPd245

      BEGINSQL ALIAS cAliasSRC
         SELECT 
            SRC.RC_HORAS,
            SRC.RC_TIPO1,
            SRC.RC_PD,
            SRV.RV_MEDFER
         FROM 
            %exp:cTabSRC% SRC
         INNER JOIN %exp:cTabSRV% SRV
            ON %exp:cJoinSRV%
         WHERE
            SRC.RC_FILIAL = %exp:cBranchVld% AND
            SRC.RC_MAT = %Exp:cMatSRA%       AND
            %Exp:cWhere%                     AND
            %exp:cDelSRC%
      ENDSQL

      //Pesquisa no Acumulado
      While (cAliasSRC)->(!Eof())
         cVerbaPesq := (cAliasSRC)->RC_PD

         //�����������������������������������������������������������������Ŀ
         //� Faltas/Atrasos/Faltas Mes Ant/Falta 1/2 Per/ Atras. Abonado     �
         //�������������������������������������������������������������������         
         If cVerbaPesq $ cPdSoma
            If (cAliasSRC)->RV_MEDFER $ "S *SP"
               nRet += If((cAliasSRC)->RC_TIPO1 == "D", (cAliasSRC)->RC_HORAS, Int((cAliasSRC)->RC_HORAS/Round((cAliasSRA)->RA_HRSMES/30,2)) )
            EndIf
         EndIf

         //�����������������������������������������������������������������Ŀ
         //� Reembolso Faltas / Atrasos                                      �
         //�������������������������������������������������������������������            
         If cVerbaPesq $ cPdSub
            If (cAliasSRC)->RV_MEDFER $ "S *SP"
               nRet -= If((cAliasSRC)->RC_TIPO1 == "D", (cAliasSRC)->RC_HORAS, Int((cAliasSRC)->RC_HORAS/Round((cAliasSRA)->RA_HRSMES/30,2)) )
            EndIf
         EndIf

         (cAliasSRC)->(DbSkip())
      EndDo
      (cAliasSRC)->(DbCloseArea())
   EndIf
   
   (cAliasSRA)->(DbCloseArea())
EndIF

Return nRet

/*/{Protheus.doc} fVldIdade
Valida Idade para solicitar f�rias. 
@author: Henrique Ferreira
@since:	08/01/2021
@param:	cCodFil     - Filial;
         cCodMat     - Matr�cula;
		   nFerDuracao - Dura��o F�rias.;  
@return: String		
/*/
Static Function fVldIdade( cCodFil, cCodMat, nFerDuracao, lRefTrab, cEmpSRA )

Local nIdade      := 0
Local cSRAtab     := ""
Local cMsgValid   := ""
Local cSitFol     := "D','T"
Local cQuery      := GetNextAlias()

Default cEmpSRA   := cEmpAnt

cSRAtab := "%" + RetFullName("SRA", cEmpSRA) + "%"

BEGINSQL ALIAS cQuery

   COLUMN RA_NASC AS DATE

   SELECT 
      SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NASC
   FROM 
      %exp:cSRAtab% SRA
   WHERE 
      SRA.RA_FILIAL = %Exp:cCodFil% AND 
      SRA.RA_MAT = %Exp:cCodMat% AND 
      SRA.RA_SITFOLH NOT IN (%Exp:cSitFol%) AND
      SRA.%NotDel%
ENDSQL

If (cQuery)->(!Eof())
   If !lRefTrab
      nIdade := Int((dDataBase - (cQuery)->RA_NASC) / 365)

      If nFerDuracao < 30 .AND. (nIdade < 18 .Or. nIdade > 50)
         If nIdade < 18 .AND. nFerDuracao < 30
            Return cMsgValid := OemToAnsi(STR0051) //"Menor de 18 anos, deve tirar f�rias em per�odo �nico!"
         ElseIf nIdade > 50 .AND. nFerDuracao < 30
            Return cMsgValid := OemToAnsi(STR0052) //"Maior de 50 anos, deve tirar f�rias em per�odo �nico!"
         EndIf
      EndIf   
   EndIf
Else
   Return cMsgValid := OemToAnsi(STR0048) //"Cadastro do funcionario da solicitacao nao localizado!"
EndIf

(cQuery)->(DBCloseArea())

Return cMsgValid


/*/{Protheus.doc} fVldFeriado
Valida se a data de inicio das f�rias n�o come�a em feriado. 
@author: Henrique Ferreira
@since:	08/01/2021
@param:	cCodFil  - Filial;
         cCodMat  - Matr�cula;
		   dDataIni - Data inicio;  
@return: String		
/*/
Static Function fVldFeriado(cFilFun, cMatFun, cDataIni, lRefTrab)

Local dDataIni  := CTOD(cDataIni)
Local dFeriado  := CTOD("//")
Local dDSR      := CTOD("//")
Local cMsgValid := ""

If lRefTrab
   // Verifica feriados no intervalo de at� 2 dias da data de inicio das f�rias.
   // Mesma tratativa do GPEM030 - Function m030VldCalc
   If !Empty( dFeriado := fVldDSR(cFilFun, cMatFun, dDataIni, 2, "F", .T.)  )
      Return cMsgValid := OemToAnsi(STR0018) + " (" + cValToChar(Day(dDataIni))+"/"+ cValToChar(Month(dDataIni)) + "/" + cValToChar(Year(dDataIni)) + ")"  + OemToAnsi(STR0019) + "(" + cValToChar(Day(dFeriado))+"/"+ cValToChar(Month(dFeriado)) + "/" + cValToChar(Year(dFeriado)) +  ")" + "."
   Else 
      //verifica DSR
      If !Empty( dDSR := fVldDSR(cFilFun, cMatFun, dDataIni, 2, "D", .T.) ) //data do DSR
         Return cMsgValid := OemToAnsi(STR0018) + " (" + cValToChar(Day(dDataIni))+"/"+ cValToChar(Month(dDataIni)) + "/" + cValToChar(Year(dDataIni)) + ")"  + OemToAnsi(STR0020) + "(" + cValToChar(Day(dDSR))+"/"+ cValToChar(Month(dDSR)) + "/" + cValToChar(Year(dDSR)) +  ")" + "."
      EndIf
   EndIf
EndIf

Return cMsgValid

/*/{Protheus.doc} fVldDSemana
Valida se a data de inicio das f�rias � s�bado ou domingo. 
@author: Henrique Ferreira
@since:	08/01/2021
@param:	cFil  - Filial do funcionario para pesquisa no calendario; 
         cMat  - Matricula do funcionario para pesquisa no calendario; 
         cDataIni  - Data de in�cio das f�rias.; 
@return: String		
/*/
Static Function fVldDSemana(cFil, cMat, cDataIni)
Local dDataIni  := CTOD(cDataIni)
Local nDOW      := 0
Local dTrab     := ""
Local cMsgValid := ""

//valida finais de semana
nDOW := DOW(dDataIni)

If nDow == 7 .Or. nDow == 1
   //A data de inicio das ferias pode ser num final de semana desde que seja dia trabalhado
   dTrab := fVldDSR(cFil, cMat, dDataIni, , "S", .T.) //Retorna valor caso seja dia trabalhado
   
   If Empty(dTrab)
      dTrab := fVldDSR(cFil, cMat, dDataIni, , "N", .T.) //Retorna valor caso seja dia n�o trabalhado
      If !Empty(dTrab)
         //"O in�cio das f�rias n�o poder� ocorrer em um dia previsto para n�o ser trabalhado"
         cMsgValid := OemToAnsi(STR0072)
      Else
         //"O in�cio das f�rias n�o poder� ocorrer em um s�bado"#"O in�cio das f�rias n�o poder� ocorrer em um domingo"
         cMsgValid := If( nDow == 7, OemToAnsi(STR0016), OemToAnsi(STR0017) )
      EndIf
   EndIf
EndIf

Return cMsgValid


/*/{Protheus.doc} fVldDtSol
Valida data de anteced�ncia para solicitar f�rias.
@author: Henrique Ferreira
@since:	08/01/2021
@param:	cDataIni  - Data de in�cio das f�rias;
@return: String		
/*/
Static Function fVldDtSol(cDataIni)
Local nPorDFer  := Val( SuperGetMv("MV_PORDFER",,30) )
Local dHj30     := Date() + nPorDFer
Local cMsgValid := ""
Local dDataIni  := CTOD(cDataIni)

If dDataIni < dHj30
   Return cMsgValid := OemToAnsi(STR0021) + cValToChar(nPorDFer) + OemToAnsi(STR0037) //"As f�rias devem ser solicitadas com pelo menos XX dias de anteced�ncia."
EndIf

Return cMsgValid

/*/{Protheus.doc} fVldSRF
Valida f�rias conforme valores j� programados na SRF.
@author: Henrique Ferreira
@since:	08/01/2021
@param:	cFil - Filial;
         cMat - Matr�cula;
         cDataIni - Data Inicial das F�rias;
         nFerDuracao - Dura��o das f�rias
         nDiasVendidos - Dias de Abono
         lSolic13 - Se pediu 13.
         cDtBsIni - Database in�cio das f�rias
         cEmpFun - Empresa do funcionario
@return: String		
/*/
Function fVldSRF(cFil, cMat, cDataIni, nFerDuracao, nDiasVendidos, lSolic13, cDtBsIni, cEmpFun)
Local cQuery     := GetNextAlias()
Local dDataIni   := CTOD(cDataIni)
Local dDataFim   := dDataIni + nFerDuracao - 1
Local cSRFtab    := ""
Local cMsgValid  := ""
Local cDelete    := "% SRF.D_E_L_E_T_ = ' ' %"
Local cDtBas     := DtoS(cToD(cDtBsIni)) //Database

DEFAULT cEmpFun  := cEmpAnt

cSRFtab := "%" + RetFullName("SRF", cEmpFun) + "%"

BeginSql ALIAS cQuery

   COLUMN RF_DATABAS AS DATE
   COLUMN RF_DATAINI AS DATE
   COLUMN RF_DATINI2 AS DATE
   COLUMN RF_DATINI3 AS DATE
   COLUMN RF_DATAFIM AS DATE

   SELECT 	
      RF_FILIAL, RF_MAT, RF_DATABAS, RF_DATAFIM, RF_DATAINI, RF_DFEPRO1, RF_DABPRO1, 
      RF_DATINI2, RF_DFEPRO2, RF_DABPRO2, RF_DATINI3, RF_DFEPRO3, RF_DABPRO3, RF_PERC13S
   FROM 
      %exp:cSRFtab% SRF
   WHERE 	
      SRF.RF_FILIAL = %Exp:cFil% AND
      SRF.RF_MAT = %Exp:cMat% AND
      SRF.RF_DATABAS = %Exp:cDtBas% AND
      SRF.RF_STATUS = '1'	AND
      %exp:cDelete%

EndSql

If (cQuery)->(Eof())
   Return cMsgValid := OemToAnsi(STR0049) //"Nao existe periodo de ferias no cadastro de Programacao de Ferias!"
Else
   While (cQuery)->(!Eof())

      If ( !Empty( (cQuery)->RF_DATAINI ) .and. !Empty( (cQuery)->RF_DATINI2 ) .and. !Empty( (cQuery)->RF_DATINI3) )
         Return cMsgValid := OemToAnsi(STR0050) //"Todas as programacoes disponiveis ja estao ocupadas, verifique!"
      EndIf 

      //Valida se j� foi solicitado adiantamento do d�cimo terceiro para o mesmo ano.
      If (cQuery)->RF_PERC13S > 0 .And. lSolic13
         If !Empty((cQuery)->RF_DATAINI) .Or. !Empty((cQuery)->RF_DATINI2)
            If (Year((cQuery)->RF_DATAINI) == Year(dDataIni)) .Or. (Year((cQuery)->RF_DATINI2) == Year(dDataIni))
               Return cMsgValid := OemToAnsi(STR0058) //"Adiantamento de 13 Salario j� requisitado anteriormente!"
            EndIf
         EndIf
      EndIf

      If nDiasVendidos > 0
         If ( (cQuery)->RF_DABPRO1 + (cQuery)->RF_DABPRO2 + nDiasVendidos ) > 10
            Return cMsgValid := OemToAnsi(STR0060) //"O total de abono n�o pode superar superar 10 dias no per�odo aquisitivo!"
         EndIf
      EndIf

      If !Empty( (cQuery)->RF_DATAINI )
         If ( dDataIni >= (cQuery)->RF_DATAINI .And. dDataIni <= DaySum( (cQuery)->RF_DATAINI, (cQuery)->RF_DFEPRO1 - 1 ) ) .Or. ;
            ( dDataIni <= (cQuery)->RF_DATAINI .And. dDataFim >= (cQuery)->RF_DATAINI )
               Return cMsgValid := OemToAnsi(STR0061) //"Periodo de f�rias em conflito com a primeira programa��o de f�rias!"
         EndIf
      EndIf

      If !Empty( (cQuery)->RF_DATINI2)
         If ( dDataIni >= (cQuery)->RF_DATINI2 .And. dDataIni <= DaySum( (cQuery)->RF_DATINI2, (cQuery)->RF_DFEPRO2 - 1 ) ) .Or. ;
            ( dDataIni <= (cQuery)->RF_DATINI2 .And. dDataFim >= (cQuery)->RF_DATINI2 )                                                                                               
               Return cMsgValid := OemToAnsi(STR0062) //"Periodo de f�rias em conflito com a segunda programa��o de f�rias!"
         EndIf
      EndIf      

      (cQuery)->( DbSkip() )
   EndDo
EndIf

(cQuery)->( DBCloseArea() )

Return cMsgValid

/*/{Protheus.doc} fVldSRH
Valida f�rias conforme programados na SRH
@author: Henrique Ferreira
@since:	08/01/2021
@param:	cFil - Filial;
         cMat - Matr�cula;
         cDataIni - Data Inicial das F�rias;
         nFerDuracao - Dura��o das f�rias
         nDiasVendidos - Dias de Abono
         aDadosSRH - Array os as informa��es da SRH.
@return: String		
/*/
Function fVldSRH(cFil, cMat, cDataIni, cDataFim, nFerDuracao, nDiasVendidos, aDadosSRH, cIniPer, cFimPer)
Local cMsgValid  := ""
Local dDataIni   := CTOD(cDataIni)
Local dDataFim   := CTOD(cDataFim)
Local dIniPer    := DTOS(CTOD(cIniPer))
Local dFimPer    := DTOS(CTOD(cFimPer))
Local nLenSRH    := Len(aDadosSRH)
Local nI         := 0
//RH_DATAINI = aDadosSRH: [1][1]  		
//RH_DFERIAS = aDadosSRH: [1][2]
//RH_DATAFIM = aDadosSRH: [1][3]   		
//RH_DATABAS = aDadosSRH: [1][4]   		
//RH_DBASEAT = aDadosSRH: [1][5]   		

If nLenSRH > 0
   For nI := 1 To nLenSRH
      If ( dIniPer == aDadosSRH[nI][4] ) .And. ( dFimPer == aDadosSRH[nI][5] )

         // Checa se as f�rias solicitadas n�o est� em conflito com f�rias j� calculadas, por�m sem solicita��o.
         // Se encontrar, sai do for.
         If ( dDataIni >= STOD(aDadosSRH[nI][1]) .and. dDataIni <= STOD(aDadosSRH[nI][3] ) ) .Or. ;
            ( dDataIni <= STOD(aDadosSRH[nI][1]) .And. dDataFim >= STOD(aDadosSRH[nI][1] ) )
               Return cMsgValid := OemToAnsi(STR0063) // J� existem f�rias calculadas para essa data!
         EndIf
      EndIf
   Next nI
EndIf

Return cMsgValid


/*/{Protheus.doc} fVldRefTrab
Valida programa��es de f�rias conforme a reforma trabalhista
@author: Henrique Ferreira
@since:	08/01/2021
@param:	cFil        - Filial
         cMat        - Matr�cula
         nFerDuracao - Quantidade de dias de f�rias solicitados.
         nDiasVendidos - Quantidade de dias de abono.
         lRefTrab - Var�avel de controle para saber se a reforma trabalhista est� ou n�o vigente.
         aDadosSRH - Array com os dados da tabela SRH.
@return: String		
/*/
Static Function fVldRefTrab(cFil, cMat, nFerDuracao, nDiasVendidos, lRefTrab, aDadosSRH, cKey, aOcurances, aPerFerias, cEmpSRA)
Local cMsgValid  := ""
Local cKeyRH3    := ""
Local lMaior14   := .F.
Local nFaltas    := 0
Local nI         := 0
Local nDiasSolic := 0
Local nAcumSRH   := 0
Local nDFeVenc   := 0
Local nDFeProp   := 0
Local nDFalVen   := 0
Local nDFalPro   := 0
Local nDFePro1   := 0
Local nDFePro2   := 0
Local nDFePro3   := 0
Local nDAbon1    := 0
Local nDAbon2    := 0
Local nDAbon3    := 0
Local nDAbonSol  := 0
Local nDAbonSRH  := 0
Local nTotAbon   := 0
Local nDiasSobra := 0
Local dDtBsFer   := cTod("//")
Local dDtIni1    := cTod("//")
Local dDtIni2    := cTod("//")
Local dDtIni3    := cTod("//")
Local nLenSRH    := Len(aDadosSRH)
Local nLenOcur   := Len(aOcurances)
Local nDiasDir   := 0
Local nCntSolic  := 0
Local nDiasValid := 0
Local aParam     := {}
Local aCpyOcurr  := {}

DEFAULT cEmpSRA  := cEmpAnt

If Len(aPerFerias) > 0
   nDFeVenc := aPerFerias[1,3]
   nDFeProp := aPerFerias[1,4]
   nDAbon1  := aPerFerias[1,11]
   nDAbon2  := aPerFerias[1,12]
   nDAbon3  := aPerFerias[1,13]
   nDFePro1 := aPerFerias[1,8] + nDAbon1 //Ferias + Abono prog. 1
   nDFePro2 := aPerFerias[1,9] + nDAbon2 //Ferias + Abono prog. 2
   nDFePro3 := aPerFerias[1,10] + nDAbon3 //Ferias + Abono prog. 3
   nDFalVen := aPerFerias[1,14]
   nDFalPro := aPerFerias[1,15]
   dDtBsFer := aPerFerias[1,1]
   dDtIni1  := aPerFerias[1,5]
   dDtIni2  := aPerFerias[1,6]
   dDtIni3  := aPerFerias[1,7]
EndIf

If lRefTrab
   //Valida��es referentes � reforma trabalhista.
   //Valida dias solicitados menor que 5.
   If ( nFerDuracao > 0 .And. nFerDuracao < 5 )
      Return cMsgValid := OemToAnsi(STR0069) // A quantidade solicitada de f�rias n�o pode ser inferior a 5 dias corridos
   EndIf

   //Valida se algum dos per�odos n�o possui pelo menos 14 dias de f�rias.
   If ( nDFePro1 > 0 .And. nDFePro1 < 14 ) .And. ; // Primeira programa��o com menos de 14 dias.
      ( nDFePro2 > 0 .And. nDFePro2 < 14 ) .And. ; // Segunda programa��o com menos de 14 dias.
      ( nFerDuracao > 0 .And. nFerDuracao < 14)                  // Quantidade solicitada com menos de 14 dias.
      Return cMsgValid := OemToAnsi(STR0068) // Deve existir ao menos um per�odo com 14 ou mais dias de f�rias.
   EndIf
   
   If nLenOcur > 0
      For nI := 1 To nLenOcur
         aParam  := StrTokArr(aOcurances[nI,2], "|")
         cKeyRH3 := aParam[1] + aParam[2] + aParam[4] //Filial + Matricula + Cod. Requisicao
         If STOD(aOcurances[nI,21]) == dDtBsFer
            If !(cKey == cKeyRH3) // Em casos de altera��o, n�o adiciona os dias da solicita��o, mas considera a vari�vel nFerDura��o e nDiasVendidos.
               nDiasSolic += aOcurances[nI,12] + aOcurances[nI,7]
               nDAbonSol += aOcurances[nI,7] // somente os dias de abono.
               aAdd(aCpyOcurr, aOcurances[nI])
            EndIf
         EndIf
      Next nI      
      nCntSolic := Len(aCpyOcurr)
   EndIf

   //Busca f�rias da SRH que n�o tem rela��o com a SRF.
   If nLenSRH > 0
      For nI := 1 to nLenSRH
         //verifica se existe a programa��o para o c�lculo realizado
         If ( STOD(aDadosSRH[nI][1]) != dDtIni1 .And. ;
            STOD(aDadosSRH[nI][1]) != dDtIni2 .And. ;
            STOD(aDadosSRH[nI][1]) != dDtIni3 )
            nAcumSRH += (aDadosSRH[nI][2] + aDadosSRH[nI,6]) //Acumula dias de f�rias + Abono calculados
            nDAbonSRH +=  aDadosSRH[nI,6]
            lMaior14 := If(lMaior14, lMaior14, aDadosSRH[nI][2] >= 14)
         EndIf
      Next nI
   EndIf

   nDiasValid := nFerDuracao + nDFePro1 + nDFePro2 + nDiasVendidos + nAcumSRH + nDiasSolic
   nTotAbon   := nDAbon1 + nDAbon2 + nDAbon3 + nDAbonSol + nDAbonSRH + nDiasVendidos // Total dos dias de abono, contando Programa��o, Solicita��o e F�rias

   //Vencidas.
   If nDFeVenc > 0
      nFaltas := nDFalVen
      TabFaltas(@nFaltas)
      //Valida se o saldo final das f�rias n�o � menor que 5 dias.
      If (nDFeVenc - nFaltas - nDiasValid) < 5 .and. (nDFeVenc - nFaltas - nDiasValid) > 0
         Return cMsgValid := OemToAnsi(STR0053) //O saldo final dos dias de f�rias n�o poder� ser menor que 5 dias!
      EndIf

      //Se for a terceira solicita��o, obriga a solicitar os dias restantes.
      If nCntSolic == 2 .And. (nDFeVenc - nFaltas - nDiasValid) > 0
         Return cMsgValid := OemToAnsi(STR0071) //Esta � a terceira solicita��o de um mesmo per�odo de f�rias. Por favor, utilize todo o saldo dispon�vel.
      EndIf

      If nDiasValid > (nDFeVenc - nFaltas)
         Return cMsgValid := OemToAnsi(STR0059) //A quantidade de dias de f�rias mais os dias de abono (venda das f�rias) ultrapassam o saldo dispon�vel.
      EndIf

      If ( nTotAbon > ( ( nDFeVenc - nFaltas ) / 3 ) )
         Return cMsgValid := OemToAnsi(STR0075) //Os dias de abono n�o podem ultrapassar 1/3 das f�rias.
      EndIF

      //Valida se pelo menos um dos per�odos tem 14 dias de f�rias solicitadas, de acordo com cada per�odo aquisitivo.
      If nFerDuracao < 14 .And. !lMaior14
         For nI := 1 To nCntSolic
            If aCpyOcurr[nI,12] >= 14
               lMaior14 := .T.
            EndIf
         Next nI
         If !lMaior14
            nDiasSobra := (nDFeVenc - nFaltas) - (nDiasSolic + nDiasVendidos + nFerDuracao + nAcumSRH)
            //Verifica se sobraram menos que 14 dias
            If nDiasSobra >= 0 .And. nDiasSobra < 14
               Return cMsgValid := OemToAnsi(STR0068) // Deve existir ao menos um per�odo com 14 ou mais dias de f�rias.
            EndIf
         EndIf
      EndIf

   //Proporcionais.
   ElseIF nDFeProp > 0
      //Apura as faltas proporcionais
      fMRhTabFer(cFil,cMat,@nDiasDir,,cEmpSRA)
      nFaltas := nDFalPro // D.Falt.Prop. (SRD)
      nFaltas += fMRhGetFal(cFil, cMat, cEmpSRA) // SRC
      TabFaltas(@nFaltas)
      nDiasDir := nDiasDir - nFaltas
      If (nDiasDir - nDiasValid) > 0 .and. (nDiasDir - nDiasValid) < 5
         Return cMsgValid := OemToAnsi(STR0053) //O saldo final dos dias de f�rias n�o poder� ser menor que 5 dias!
      EndIf 

      //Se for a terceira solicita��o, obriga a solicitar os dias restantes.
      If nCntSolic == 2 .And. (nDiasDir - nDiasValid) > 0
         Return cMsgValid := OemToAnsi(STR0071) //Esta � a terceira solicita��o de um mesmo per�odo de f�rias. Por favor, utilize todo o saldo dispon�vel.
      EndIf

      If nDiasValid > nDiasDir
         Return cMsgValid := OemToAnsi(STR0059) //A quantidade de dias de f�rias mais os dias de abono (venda das f�rias) ultrapassam o saldo dispon�vel.
      EndIf

      If ( nTotAbon > ( nDiasDir / 3 ) )
         Return cMsgValid := OemToAnsi(STR0075) //Os dias de abono n�o podem ultrapassar 1/3 das f�rias.
      EndIF

      //Valida se pelo menos um dos per�odos tem 14 dias de f�rias solicitadas, de acordo com cada per�odo aquisitivo.
      If nFerDuracao < 14 .And. !lMaior14 
         For nI := 1 To nCntSolic
            If aCpyOcurr[nI,12] >= 14
               lMaior14 := .T.
            EndIf
         Next nI
         If !lMaior14
            nDiasSobra := nDiasDir - (nDiasSolic + nDiasVendidos + nFerDuracao + nAcumSRH)
            //Verifica se sobraram menos que 14 dias
            If nDiasSobra >= 0 .And. nDiasSobra < 14
               Return cMsgValid := OemToAnsi(STR0068) // Deve existir ao menos um per�odo com 14 ou mais dias de f�rias.
            EndIf
         EndIf
      EndIf

   EndIf
Else
   Conout("<<<< Reforma trabalhista desabilitada, verifique o parametro MV_REFTRAB >>>>>")
EndIf

Return cMsgValid

/*/{Protheus.doc} fProjDias
Projeta dias de f�rias solicitadas conforme dias de direito.
@author: Henrique Ferreira
@since:	08/01/2021
@param:	cFil - Filial;
         cMat - Matr�cula;
         cDataIni - Data Inicial das F�rias;
@return: Integer		
/*/
Function fProjDias(cFil, cMat, dDtIniFer, dDtIniPer, nDFerias, cEmpSRA)
Local nDiasDir  := 0
Local nFaltas   := 0
Local nMeses    := 0
Local nFator    := 0
Local nDiasSolic := 0
Local nDiasSRH   := 0
Local nX         := 0
Local nDescFal   := 0
Local cSRFtab    := ""
Local cDtBasFer  := ""
Local cDelete    := "% SRF.D_E_L_E_T_ = ' ' %"
Local cQuery     := GetNextAlias()
Local aOcurances := {}
Local aDadosSRH  := {}
Local cCodFer   := fGetCodFol("0072",,cFil)
Local aArea     := GetArea()

DEFAULT cEmpSRA := cEmpAnt

fMRhTabFer(cFil, cMat, @nDiasDir, @nFator, cEmpSRA)

GetVacationWKF(@aOcurances, cMat, cFil, cMat, cFil, cEmpSRA, "'1','4'")

If Len( aOcurances ) > 0
   aEval(aOcurances, { |x| If(CTOD(x[21]) == dDtIniPer, nDiasSolic += ( x[12] + x[7] ), 0 ) } )
EndIf

If !Empty(dDtIniPer)
   cDtBasFer := "% SRF.RF_DATABAS = '" + DtoS(dDtIniPer) + "' AND %"
EndIf

cSRFtab := "%" + RetFullName("SRF", cEmpSRA) + "%"

BeginSql ALIAS cQuery

   COLUMN RF_DATABAS AS DATE
   COLUMN RF_DATAFIM AS DATE
   COLUMN RF_DATAINI AS DATE
   COLUMN RF_DATINI2 AS DATE
   COLUMN RF_DATINI3 AS DATE

   SELECT 	
      RF_FILIAL, RF_MAT, RF_DATABAS, RF_DATAFIM, RF_DFERVAT, RF_DFERAAT, RF_DATAINI, RF_DATINI2, RF_DATINI3,
		RF_DFEPRO1, RF_DFEPRO2, RF_DFEPRO3, RF_DABPRO1, RF_DABPRO2, RF_DABPRO3, RF_DFALVAT, RF_DFALAAT
   FROM 
      %exp:cSRFtab% SRF
   WHERE 	
      SRF.RF_FILIAL = %Exp:cFil% AND
      SRF.RF_MAT = %Exp:cMat% AND
      %exp:cDtBasFer%
      (SRF.RF_STATUS = '1' OR SRF.RF_STATUS = ' ') AND
      SRF.RF_PD = %Exp:cCodFer% AND 
      %exp:cDelete%
   ORDER BY RF_DATABAS ASC

EndSql

If (cQuery)->(!Eof())

   aDadosSRH := fGetSRH(cFil, cMat, (cQuery)->RF_DATABAS, (cQuery)->RF_DATAFIM)
   If Len(aDadosSRH) > 0
      //Somente adiciona f�rias na SRH que n�o tem a ver com a program��o da SRF.
      For nX := 1 to Len(aDadosSRH)
         If ( aDadosSRH[nX,1] != DTOS((cQuery)->RF_DATAINI) ) .And.;
            ( aDadosSRH[nX,1] != DTOS((cQuery)->RF_DATINI2) ) .And.;
            ( aDadosSRH[nX,1] != DTOS((cQuery)->RF_DATINI3) )
            nDiasSRH += ( aDadosSRH[nX][2] + aDadosSRH[nX][6] )
         EndIf
      Next nX
   EndIf

   nDiasSolic += ( (cQuery)->RF_DFEPRO1 + (cQuery)->RF_DFEPRO2 + (cQuery)->RF_DFEPRO3 + (cQuery)->RF_DABPRO1 + (cQuery)->RF_DABPRO2 + (cQuery)->RF_DABPRO3 + nDiasSRH )

   //Apura os dias de direito conforme nova data das f�rias.
   //Envia o Inicio das F�rias menos 1 dia para considerar os dias trabalhados daquele m�s.
   //Exemplo. Inicio F�rias - 15/06/2021. Apura-se os dias trabalhados do dia 01/06 at� o dia 14/06. 
   nMeses := fMesesTrab(dDtIniPer, dDtIniFer - 1)
   nMeses := Min(12,nMeses)

   nDFerias := nMeses * nFator

   nFaltas := (cQuery)->RF_DFALAAT // D.Falt.Prop. (SRD)
   nFaltas += fMRhGetFal(cFil, cMat, cEmpSRA) // SRC

   nDescFal := nFaltas
   TabFaltas(@nDescFal)

   If nDFerias < nDiasDir
      nDescFal := ((nDescFal / nDiasDir) * nDFerias)
   EndIf
   //Abate as faltas e os dias j� solicitados dos dias de direito.
   nDFerias := nDFerias - nDescFal - nDiasSolic
EndIf

RestArea(aArea)

Return .T.

/*/{Protheus.doc} fMRhTabFer
Retorna a quantidade de dias de direito do funcion�rio, conforme tabela 
@author: Henrique Ferreira
@since:	08/01/2021
@param:	cFil - Filial;
         cMat - Matr�cula;
         cDataIni - Data Inicial das F�rias;
@return: Integer		
/*/
Function fMRhTabFer(cBranchVld, cMatSRA, nDiasDir, nFator, cEmpSRA)

Local aTabFer    := {}
Local aTabFer2   := {}
Local nTempoParc := 0
Local nPosTbFer  := 0
Local cQuery     := ""
Local cSRAtab    := ""
Local cSitFol    := "D','T"
Local cDelSRA    := "% SRA.D_E_L_E_T_ = ' ' %"

Default nFator   := 2.5
Default nDiasDir := 30
Default cEmpSRA  := cEmpAnt

// Carrega Tabela de Faltas
fTab_Fer(@aTabFer,,@aTabFer2)

//Se as horas semanais forem inferiores a 26, e o Mnemonico P_REGPARCI estiver ativo,
//utiliza os dias de ferias da tabela S065 - Tabela de ferias tempo parcial (Artigo 130A da CLT)
If cPaisLoc $ ("BRA*")

   cQuery  := GetNextAlias()
   cSRAtab := "%" + RetFullName("SRA", cEmpSRA) + "%"

   BEGINSQL ALIAS cQuery
      SELECT 
         SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_HRSEMAN, SRA.RA_HOPARC
      FROM 
         %exp:cSRAtab% SRA
      WHERE 
         SRA.RA_FILIAL = %Exp:cBranchVld% AND 
         SRA.RA_MAT = %Exp:cMatSRA% AND 
         SRA.RA_SITFOLH NOT IN (%Exp:cSitFol%) AND         
         %exp:cDelSRA%
   ENDSQL

   If (cQuery)->(!Eof())

      nTempoParc := (cQuery)->RA_HRSEMAN
      If ( ( (cQuery)->RA_HOPARC == "1" .And. nTempoParc <= 25 ) .And. nTempoParc  > 0 .And. Len(aTabFer2) > 0	.And. P_REGPARCI )
         nPosTbFer := Ascan(aTabFer2, { |X|  nTempoParc <= X[6] .And. nTempoParc > X[5] })
         If nPosTbFer > 0
            aTabFer := aClone(aTabFer2[nPosTbFer])
         EndIf
      EndIf
      If Len(aTabFer) > 0
         nDiasDir := aTabFer[3] // Dias de Direito de acordo com Tabela de F�rias
         nFator   := aTabFer[4] // Fator
      EndIf

   EndIf

   (cQuery)->(DBCloseArea())

EndIf

Return .T.

/*/{Protheus.doc} fVldFerWfl
Verifica se existe alguma solicita��o de f�rias ainda n�o aprovada em conflito.
@author: Henrique Ferreira
@since:	28/01/2021
@param:	cFil - Filial;
         cMat - Matr�cula;
         cDataIni - Data Inicial das F�rias;
         cDataFim - Data final das f�rias.
         cKey - Chave da RH3 para n�o validar a propria solicita��o em casos de PUT.
@return: Integer		
/*/
Function fVldFerWfl(cFil, cMat, cDataIni, cDataFim, cKey, aOcurances)
Local dDataIni   := CTOD(cDataIni)
Local dDataFim   := CTOD(cDataFim)
Local nLenOcur   := Len(aOcurances)
Local aParam     := {}
Local nI         := 0
Local cMsgFault  := ""
Local cKeyRH3    := ""

If nLenOcur > 0
   For nI := 1 To nLenOcur

      aParam  := StrTokArr(aOcurances[nI,2], "|")
      cKeyRH3 := aParam[1] + aParam[2] + aParam[4] //Filial + Matricula + Cod. Requisicao

      If cKey == cKeyRH3
         Loop
      Else
         // Checa se as f�rias solicitadas n�o est�o em conflito com outras f�rias j� solicitadas.
         If ( ( dDataIni >= CTOD(aOcurances[nI][5]) .and. dDataIni <= CTOD(aOcurances[nI][6]) ) .Or. ;
            ( dDataIni <= CTOD(aOcurances[nI][5]) .And. dDataFim >= CTOD(aOcurances[nI][5]) ) )
               Return cMsgFault := OemToAnsi(STR0070) // J� existe f�rias solicitadas para esta data.
         EndIf
      EndIf
   Next nI
EndIf

Return cMsgFault


/*/{Protheus.doc} fVld13Wkfl
Verifica se existe alguma solicita��o de f�rias ainda n�o aprovada em conflito.
@author: Alberto Ortiz
@since:	04/05/2022
@param:	aCurances - Array de ocorre;
         cKey - Chave da RH3 para n�o validar a propria solicita��o em casos de PUT.
@return: String		
/*/
Function fVld13Wkfl(aOcurances, cKey, cDataIni)
Local nLenOcur   := Len(aOcurances)
Local nI         := 0
Local cMsgFault  := ""
Local cKeyRH3    := ""
Local dDataIni   := ctod(cDataIni)

DEFAULT aCorances := {}
DEFAULT cKey      := ""

If nLenOcur > 0
   For nI := 1 To nLenOcur
      aParam  := StrTokArr(aOcurances[nI,2], "|")
      cKeyRH3 := aParam[1] + aParam[2] + aParam[4] //Filial + Matricula + Cod. Requisicao

      If cKey == cKeyRH3
         Loop
      EndIf

      If aOcurances[nI][14] .And. Year(dDataIni) == Year(cTod(aOcurances[nI][5]))
         cMsgFault := OemToAnsi(STR0073) // J� existe uma solicita��o de f�rias com adiantamento de d�cimo terceiro solicitada para este per�odo.
         Exit
      EndIf
   Next nI
EndIf

Return cMsgFault

/*/{Protheus.doc} GetDtBasFer
Retorna da database de ferias do periodo ativo mais antigo
@author: Marcelo Silveira
@since:	06/08/2021
@param:	cFil - Filial;
         cMat - Matr�cula;
         aDtBasFer - Array de referencia para retorno
         cEmpFun - Empresa do funcionario
         cDtBas - Data base do periodo aquisitivo
@return: Nil
/*/
Function GetDtBasFer(cFil, cMat, aDtBasFer, cEmpFun, cDtBas)
Local cQuery     := GetNextAlias()
Local cSRFtab    := ""
Local cDtBasFer  := "%%"
Local cDelete    := "% SRF.D_E_L_E_T_ = ' ' %"

DEFAULT aDtBasFer:= {}
DEFAULT cEmpFun  := cEmpAnt
DEFAULT cDtBas   := ""

cSRFtab := "%" + RetFullName("SRF", cEmpFun) + "%"

//Quando nao possui database espec�fica considera o per�odo aquisitivo mais antigo que est� ativo
If !Empty(cDtBas)
   cDtBasFer := "% SRF.RF_DATABAS = '" + DtoS(cToD(cDtBas)) + "' AND %"
EndIf

BeginSql ALIAS cQuery

   COLUMN RF_DATABAS AS DATE
   COLUMN RF_DATAFIM AS DATE
   COLUMN RF_DATAINI AS DATE
   COLUMN RF_DATINI2 AS DATE
   COLUMN RF_DATINI3 AS DATE

   SELECT 	
      RF_FILIAL, RF_MAT, RF_DATABAS, RF_DATAFIM, RF_DFERVAT, RF_DFERAAT, RF_DATAINI, RF_DATINI2, RF_DATINI3,
		RF_DFEPRO1, RF_DFEPRO2, RF_DFEPRO3, RF_DABPRO1, RF_DABPRO2, RF_DABPRO3, RF_DFALVAT, RF_DFALAAT
   FROM 
      %exp:cSRFtab% SRF
   WHERE 	
      SRF.RF_FILIAL = %Exp:cFil% AND
      SRF.RF_MAT = %Exp:cMat% AND
      %exp:cDtBasFer%
      (SRF.RF_STATUS = '1' OR SRF.RF_STATUS = ' ') AND
      %exp:cDelete%
   ORDER BY RF_DATABAS ASC

EndSql

If (cQuery)->(!Eof())
   aAdd( aDtBasFer, { ;
                        (cQuery)->RF_DATABAS, ;
                        (cQuery)->RF_DATAFIM, ;
                        (cQuery)->RF_DFERVAT, ;
                        (cQuery)->RF_DFERAAT, ;
                        (cQuery)->RF_DATAINI, ;
                        (cQuery)->RF_DATINI2, ;
                        (cQuery)->RF_DATINI3, ;
                        (cQuery)->RF_DFEPRO1, ;
                        (cQuery)->RF_DFEPRO2, ;
                        (cQuery)->RF_DFEPRO3, ;
                        (cQuery)->RF_DABPRO1, ;
                        (cQuery)->RF_DABPRO2, ;
                        (cQuery)->RF_DABPRO3, ;
                        (cQuery)->RF_DFALVAT, ;
                        (cQuery)->RF_DFALAAT  ;
                     } )
Else
   aAdd( aDtBasFer, { ;
                        cTod("//"), ;
                        cTod("//"), ;
                        0, ;
                        0, ;
                        cTod("//"), ;
                        cTod("//"), ;
                        cTod("//"), ;
                        0, ;
                        0, ;
                        0, ;
                        0, ;
                        0, ;
                        0, ;
                        0, ;
                        0  ;
                     } )
EndIf

(cQuery)->( DBCloseArea() )

Return

/*/{Protheus.doc} fSetBalanceDays
Atualiza a quantidade de dias dispon�veis em uma solicita��o que f�rias que ainda pode ser alterada
@author: Marcelo Silveira
@since:	19/05/2022
@param:	aData - Array com os objetos json das requisi��es;
         nDaysAdd - Dias que deverao ser somados ao atributo balance;
         cIniPer - Inicio do periodo aquisitivo para validar se ser� somado na solicita��o
@return: Nil
/*/
Static Function fSetBalanceDays( aData, nDaysAdd, cIniPer )

   Local nX := 0

   //O atributo 'isUpdated' n�o existe em contrato. Ele foi adicionado apenas para controlar se os 
   //dias de direito do funcionario de uma determinada requisicao j� foi atualizado. 
   For nX := 1 To Len(aData)
      If aData[nX]:hasProperty("id") .And. "RH3" $ aData[nX]["id"]
         If aData[nX]["canAlter"] .And. aData[nX]["initPeriod"] == cIniPer .And. (aData[nX]:hasProperty("isUpdated") .And. !aData[nX]["isUpdated"]) 
            aData[nX]["balance"] := aData[nX]["balance"] + nDaysAdd
            aData[nX]["isUpdated"] := .T.
         EndIf
      EndIf
   Next nX

Return()
