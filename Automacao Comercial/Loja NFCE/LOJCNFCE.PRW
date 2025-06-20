#INCLUDE "TOTVS.CH"

Function LOJCNFCE()
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} LOJCNFCE
Classe responsavel pela comunica��o do Protheus com a Classe de comunica��o com TSS LOJXNFCE

@author  Lucas Novais (lnovais)
@since   12/03/2019
@version P12
/*/
//----------------------------------------------------------------------

Class LOJCNFCE

Data aResultTSS             //Array {Logico,Metodo executado,Mensagem de retorno,Codigo de Erro(Caso exista),Descri��o do Erro}
Data aResultMetodo          //Array {Logico,Descri��o}
Data aResultCancelamento    //Array {Logico,Codigo de retorno,Descri��o do retorno}

Method New()                                CONSTRUCTOR //Metodo Construtor
Method LjCancOnline(cId)                                //Metodo responsavel pelo cancelamento Online
Method LjCancOffLine(cSerie,cDoc,cModelo)               //Metodo responsavel pelo cancelamento OffLine TBC-GO -> Acrescentado devido NF-e Totvs PDV cModelo
Method LjAtualizaL1Situa(cId,cRecnoL1)                  //Monitora e atualiza SITUA da SL1
Method LjMensagem(cMetodo,aMensagem)                    //Metodo responsavel por Administrar as mensagens da Classe
Method LjCancSbst(cId, cKeyNFce, cNfceRef)              //Metodo respons�vel por gerar o XML para o Cancelamento por Substitui��o da NFC-e
Method LjCancInut(cId,cModelo)                          //Metodo responsavel por realizar cancelamento / inutiliza��o Assincrona //-- TBC-GO Acrescimo da serie para inutilizar a numeracao correta

EndClass

//----------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe LOJCNFCE

@author  Lucas Novais (lnovais)
@since   12/03/2019
@version P12

/*/
//----------------------------------------------------------------------

Method New() Class LOJCNFCE

Self:aResultTSS             := {.F.,"","","",""}     //Array {Logico,Metodo executado,Mensagem de retorno,Codigo de Erro(Caso exista),Descri��o do Erro}
Self:aResultMetodo          := {.F.,""}              //Array {Logico,Descri��o}
Self:aResultCancelamento    := {.F.,"",""}           //Array {Logico,Codigo de retorno,Descri��o do retorno}

Return Self

//----------------------------------------------------------------------
/*/{Protheus.doc} LjCancOnline
Metodo responsavel pelo cancelamento Online

@param   cId	    Numero do Id da nota no TSS (Serie + Documento)
@author  Lucas Novais (lnovais)
@since   12/03/2019
@version P12

/*/
//----------------------------------------------------------------------

Method LjCancOnline(cId) Class LOJCNFCE

Local cError					:= ""                       //Variavel utilizada para retorno da fun��o XmlParser
Local cWarning 					:= ""                       //Variavel utilizada para retorno da fun��o XmlParser
Local oXmCancelaEventoResult	:= Nil                      //Armazena o retorno do metodo LjCancelaEvento(cCancelaEventoResult) e transforma em objeto
Local cStat                     := ""                       //Codigo do retorno da SEFAZ
Local cMotivo                   := ""                       //Descri��o do retorno da SEFAZ
Local oNfce						:= LOJXNFCE():New()			//Constroi o objeto LOJXNFCE

If oNFCe:LojXNfceStart()
	If oNFCe:LjCancelaEvento(cID)
		if !Empty(oNFCe:oWSNFESBRA:cCancelaEventoResult)
			
            oXmCancelaEventoResult := XmlParser( oNFCe:owsnfesbra:cCancelaEventoResult, "_", @cError, @cWarning )
			 
            If !Empty(oXmCancelaEventoResult)
               
   				if XmlChildEx(oXmCancelaEventoResult:_RETENVEVENTO,"_RETEVENTO") == NIL
					cStat   := 	oXmCancelaEventoResult:_RETENVEVENTO:_CSTAT:Text
					cMotivo :=	oXmCancelaEventoResult:_RETENVEVENTO:_XMOTIVO:Text
				else	
					cStat   := 	oXmCancelaEventoResult:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT
					cMotivo :=	oXmCancelaEventoResult:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT
				endif
                
                If cStat <> "135"

                    Self:LjMensagem("aResultTSS",oNfce:aMensagem)
                    Self:LjMensagem("aResultMetodo",      {.T.,"Processos internos executado com sucesso"})
                    Self:LjMensagem("aResultCancelamento",{.F.,cStat,cMotivo})

				Else

                    Self:LjMensagem("aResultTSS",oNfce:aMensagem)
                    Self:LjMensagem("aResultMetodo",      {.T.,"Processos internos executado com sucesso"})
                    Self:LjMensagem("aResultCancelamento",{.T.,cStat,cMotivo})

				EndIf 

			Else
                Self:LjMensagem("aResultTSS",oNfce:aMensagem)
                Self:LjMensagem("aResultMetodo",{.F.,"Falha ao gerar Objeto XML : " + cError + " / " + cWarning})
			EndIf
		Else    
            Self:LjMensagem("aResultTSS",oNfce:aMensagem)        
            Self:LjMensagem("aResultMetodo",{.F.,"cCancelaEventoResult N�o retornado"})
        EndIf
	Else
        Self:LjMensagem("aResultTSS",oNfce:aMensagem)
        Self:LjMensagem("aResultMetodo",{.T.,"Metodo n�o conseguiu se comunicar com TSS ou Time-out consultar propriedade aResultTSS."})
	Endif
Else 
    Self:LjMensagem("aResultTSS",oNfce:aMensagem)
    Self:LjMensagem("aResultMetodo",{.T.,"Metodo n�o conseguiu se comunicar com TSS ou Time-out consultar propriedade aResultTSS."})
EndIf 

Return 

//----------------------------------------------------------------------
/*/{Protheus.doc} LjCancOnline
Metodo responsavel pelo cancelamento OffLine

@param   cSerie	    Numero da Serie da nota
@param   cDoc	    Numero do Documento da nota
@author  Lucas Novais (lnovais)
@since   12/03/2019
@version P12

/*/
//----------------------------------------------------------------------
Method LjCancOffLine(cSerie,cDoc,cModelo) Class LOJCNFCE
Local lRet      := .F.                      //Variavel de retorno do metodo
Local oNfce     := LOJXNFCE():New()			//Constroi o objeto LOJXNFCE

DEFAULT cModelo := "65"

//To Do, Iniciamente chamando fun��o do lojnfce, em uma segunda fase trazer a fun��o para o LOJXNFCE e LOJCNFCE
lRet := LjNFCeCanc( cSerie,cDoc,,cModelo)

//Monitoro a nota para que seja criado a TSSTR1 (Contorno provisorio para o problema de cancelamento Online do TSS sem comunica��o com a SEFAZ)
If lRet .AND. oNFCe:LojXNfceStart()
    oNFCe:LjMonitorFaixa(cSerie + cDoc)
EndIf 

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LjCancOnline
Metodo responsavel por monitorar e atualiza SITUA da SL1

@param   cId	        Numero do Id da nota no TSS (Serie + Documento)
@param   nRecnoL1	    REcno da venda na tabela SL1
@author  Lucas Novais (lnovais)
@since   12/03/2019
@version P12

/*/
//----------------------------------------------------------------------

Method LjAtualizaL1Situa(cId,nRecnoL1) Class LOJCNFCE

Local oNfce         := LOJXNFCE():New()     //Constroi o objeto LOJXNFCE
Local aAreaAtu      := GetArea()            //Guarda Area atual
Local aAreaSL1      := SL1->(GetArea())     //Guarda area da tabela SL1
Local lRet          := .F.                  //Variavel de retorno do metodo
Local lEncontrou    := .F.                  //Variavel que indica se encontrou a nota no TSS
Local aResultNF     := {}                   //Variavel armazena o resultado do metodo LjGetDadosNfeId
Local nI            := 0                    //Variavel para FOR
Local nPosModDoc	:= 0	                //posicao do campo MODELO no vetor retornado pelo TSS
Local nPosStatus	:= 0	                //posicao do campo STATUS no vetor retornado pelo TSS
Local nPosStCanc	:= 0	                //posicao do campo STATUSCANC no vetor retornado pelo TSS
Local oLOJGNFCE     := Nil                  //Instancia Classe LOJGNFCE 
Local lInteract		:= Iif(ExistFunc("LOJGNFCE"),GetApoInfo("LOJGNFCE.PRW")[4] >= CtoD("31/07/2019"),.F.)	//Valida se o controle de intera��es esta disponivel.
Local lLxIteracao   := SLX->(ColumnPos("LX_ITERACA") ) > 0 .And. SLX->(ColumnPos("LX_DULTPRC") ) > 0 .And. SLX->(ColumnPos("LX_HULTPRC") ) > 0  //indica se os campos est�o presentes 

DbSelectArea("SL1")
SL1->( DbGoTo(nRecnoL1))

If !SL1->(EOF())
    If !(SL1->L1_SITUA  $ "X2|X3")
        lRet := .T.
    Else
        Self:LjMensagem("aResultTSS",oNfce:aMensagem)
        Self:LjMensagem("aResultMetodo",{.F.,"Or�amento Ja esta cancelado ou esta com rejei��o.(L1_SITUA = 'X2|X3')"}) 
    Endif
Else
    Self:LjMensagem("aResultTSS",oNfce:aMensagem)
    Self:LjMensagem("aResultMetodo",{.F.,"N�o foi possivel posicionar no RECNO da tabeal SL1: " + AllTrim(STR(nRecnoL1))})
EndIf

If lRet .AND. oNFCe:LojXNfceStart()

    If oNfce:LjMonitorFaixa(cId) //Monitora as nota na Sefaz (TO DO, Controle de vezes que a nota foi consultara para evitar consulmo indevido.)

        If oNFCe:LjGetDadosNfeId(cId+";") //Busco os dados da Nota no TSS

            aResultNF :=  aClone(oNFCe:oWSNFESBRA:OWSGETDADOSNFEIDRESULT:OWSNFEIDSAI)

            If Len(aResultNF) > 0
                
                nPosModDoc 	:= Ascan( aResultNF[1]:OWSCMPSTRUCT:OWSCAMPO, {|x| x:CCMPNAME == "MODELO"} )
                nPosStatus 	:= Ascan( aResultNF[1]:OWSCMPSTRUCT:OWSCAMPO, {|x| x:CCMPNAME == "STATUS"} )
                nPosStCanc 	:= Ascan( aResultNF[1]:OWSCMPSTRUCT:OWSCAMPO, {|x| x:CCMPNAME == "STATUSCANC"} )
                
                For nI := 1 to Len( aResultNF )

                    If aResultNF[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosModDoc]:CCMPVALUE == "65" //NFCE
                        lEncontrou := .T.
                        Do Case

                            Case aResultNF[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosStatus]:CCMPVALUE == "6" .AND. aResultNF[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosStCanc]:CCMPVALUE == "0"
                                //CANCELAMENTO N�O REALIZADO NO PDV
                                Self:LjMensagem("aResultTSS",oNfce:aMensagem)
                                Self:LjMensagem("aResultMetodo",      {.T.,"Cancelamento n�o realizado no PDV, Cancelamento dever� ser realizado pelo Job LjCancNFCE"})

                            Case aResultNF[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosStatus]:CCMPVALUE == "7" .AND. aResultNF[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosStCanc]:CCMPVALUE == "1"
                                //CANCELAMENTO N�O PROCESSADO
                                Self:LjMensagem("aResultTSS",oNfce:aMensagem)
                                Self:LjMensagem("aResultMetodo",      {.T.,"Cancelamento n�o processado"})
                                
                            Case aResultNF[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosStatus]:CCMPVALUE == "7" .AND. aResultNF[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosStCanc]:CCMPVALUE == "2"
                                //CANCELAMENTO PROCESSADO - atualizamos o valor do L1_SITUA
                                
                                RecLock( "SL1", .F. )
                                Replace SL1->L1_SITUA with "X2"
                                SL1->( MsUnlock() )

                                If lInteract .And. lLxIteracao
                                    oLOJGNFCE := LOJGNFCE():New()
                                    /* Limpa intera��es na tabela SLX */
                                    oLOJGNFCE:LjClearInteractSLX(SL1->L1_PDV,SL1->L1_DOC,SL1->L1_SERIE)
                                EndIf 

                                Self:LjMensagem("aResultTSS",oNfce:aMensagem)
                                Self:LjMensagem("aResultMetodo",      {.T.,"Or�amento:" + SL1->L1_NUM + " ja esta cancelado no TSS, STATUS = 7 STATUSCANC = 2"})
                                Self:LjMensagem("aResultMetodo",      {.T.,"Or�amento:" + SL1->L1_NUM + " Alterado, L1_SITUA alterado para X2, Cancelamento ja realizado no PDV"})
                    
                            Case aResultNF[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosStatus]:CCMPVALUE == "7" .AND. aResultNF[nI]:OWSCMPSTRUCT:OWSCAMPO[nPosStCanc]:CCMPVALUE == "3"
                                //CANCELAMENTO COM FALHA - atualizamos o valor do L1_SITUA
                                
                                RecLock( "SL1", .F. )
                                Replace SL1->L1_SITUA with "X3"
                                SL1->( MsUnlock() )

                                Self:LjMensagem("aResultTSS",oNfce:aMensagem)
                                Self:LjMensagem("aResultMetodo",      {.T.,"Or�amento:" + SL1->L1_NUM + " Com rejei��o no TSS, STATUS = 7 STATUSCANC = 2"})
                                Self:LjMensagem("aResultMetodo",      {.T.,"Or�amento:" + SL1->L1_NUM + " Alterado, L1_SITUA alterado para X3, Cancelamento Rejeitado"})

                            Otherwise
                                //Retornou STATUS e/ou STATUSCANC invalidos para cancelamento
                                Self:LjMensagem("aResultTSS",oNfce:aMensagem)
                                Self:LjMensagem("aResultMetodo",      {.T.,"RETORNO DO TSS N�O MAPEADO"})
                        End Case
                    EndIf
                Next
                //Indica que n�o encontrou a nota no TSS
                If !lEncontrou
                    Self:LjMensagem("aResultTSS",oNfce:aMensagem)
                    Self:LjMensagem("aResultMetodo", {.T.,"NFC-e: " + cId + " N�o encontrada."})
                EndIf
            Else 
                Self:LjMensagem("aResultTSS",oNfce:aMensagem)
                Self:LjMensagem("aResultMetodo", {.T.,"NFC-e: " + cId + " N�o encontrada."})
            EndIf 
        Else
            Self:LjMensagem("aResultTSS",oNfce:aMensagem)
            Self:LjMensagem("aResultMetodo",{.T.,"Metodo n�o conseguiu se comunicar com TSS. consultar propriedade aResultTSS."})
        EndIf
    Else
         Self:LjMensagem("aResultTSS",oNfce:aMensagem)
        Self:LjMensagem("aResultMetodo",{.T.,"Metodo n�o conseguiu se comunicar com TSS. consultar propriedade aResultTSS."})
    EndIf
Else 
    Self:LjMensagem("aResultTSS",oNfce:aMensagem)
    Self:LjMensagem("aResultMetodo",{.T.,"Metodo n�o conseguiu se comunicar com TSS. consultar propriedade aResultTSS."})
EndIf
   
RestArea(aAreaSL1)
RestArea(aAreaAtu)

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} LjMensagem
Metodo responsavel informar ao ERP sobre erro na comunica��o/ execu��o do WebService atravez das propriedades aResultTSS, aResultMetodo e aResultCancelamento

@param   cResult	    Indica em qual propriedade o metodo precisa ser gravado
@param   aMensagem	    Mensagem de erro ou log
@author  Lucas Novais (lnovais)
@since   12/03/2019
@version P12
/*/
//----------------------------------------------------------------------

Method LjMensagem(cResult,aMensagem) Class LOJCNFCE

Do Case
    Case cResult == "aResultTSS"
        Self:aResultTSS             := aMensagem
        LjGrvLog(cResult + " -> " + ProcName(1),Self:aResultTSS[3],Self:aResultTSS)

    Case cResult == "aResultMetodo"
        Self:aResultMetodo          := {aMensagem[1],aMensagem[2]}
        LjGrvLog(cResult + " -> " + ProcName(1),Self:aResultMetodo[2],Self:aResultMetodo)
        
    Case cResult == "aResultCancelamento"
        Self:aResultCancelamento    := {aMensagem[1],aMensagem[2],aMensagem[3]}	
        LjGrvLog(cResult + " -> " + ProcName(1),Self:aResultCancelamento[2],Self:aResultCancelamento)
End Case

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCancSbst
Metodo responsavel por gerar o XML do Cancelamento por Substitui��o para enviar ao TSS.

@type    Method
@param   cKeyNfce   Chave da NFC-e a ser cancelada
@param   nProt      Numero do protocolo da NFC-e a ser cancelada
@param   cNfceRef   Chave da NFC-e substituta para a cancelada
@author  eduardo.sales
@since   15/05/2019
@version P12
/*/
//-------------------------------------------------------------------
Method LjCancSbst(cKeyNfce, nProt, cNfceRef) Class LOJCNFCE

Local lRet          := .F.                      //Variavel de retorno do metodo
Local oNfce         := LOJXNFCE():New()			//Constroi o objeto LOJXNFCE
Local cXML          := ""                       //Arquivo XML
Local oXmlResult    := Nil                      //Objeto utilizado para capturar dados da nfce
Local cError        := ""                       //Variavel utilizada para retorno da fun��o XmlParser
Local cWarning      := ""                       //Variavel utilizada para retorno da fun��o XmlParser
Local cStat         := ""                       //Codigo do retorno da SEFAZ
Local cMotivo       := ""                       //Descri��o do retorno da SEFAZ

cXML  := "<envEvento>"
cXML  += "  <eventos>"
cXML  += "      <detEvento>"
cXML  += "          <tpEvento>110112</tpEvento>"
cXML  += "          <chNFe>" + cKeyNfce + "</chNFe>"
cXML  += "          <xCorrecao>Cancelamento por substituicao de NFC-e</xCorrecao>"
cXML  += "          <tpAutor>1</tpAutor>"
cXML  += "          <nProt>" + nProt + "</nProt>"
cXML  += "          <xJust>Evento de cancelamento por substituicao da NFC-e</xJust>"
cXML  += "          <chNFeRef>" + cNfceRef + "</chNFeRef>"
cXML  += "      </detEvento>"
cXML  += "  </eventos>"
cXML  += "</envEvento>"

If oNFCe:LojXNfceStart()
    If oNFCe:LjCancelaEvento(Nil, "Cancelamento por Substitui��o", cXML)
        If !Empty(oNFCe:oWSNFESBRA:cCancelaEventoResult)
            
            oXmlResult := XmlParser(oNFCe:oWSNFESBRA:cCancelaEventoResult, "_", @cError, @cWarning )
            
            If !Empty(oXmlResult)
                cStat   := oXmlResult:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT
                cMotivo := oXmlResult:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT
                
                If cStat == "135"
                    lRet := .T.
                Else
                    Self:LjMensagem("aResultCancelamento",{.F., cStat , "Rejei��o: " + cMotivo })
                EndIf
            Else
                Self:LjMensagem("aResultMetodo",{.F., "Falha ao gerar Objeto XML : " + cError + " / " + cWarning })
            EndIf
        EndIf
    Else
        Self:LjMensagem("aResultMetodo",{.F.,"Metodo n�o conseguiu se comunicar com TSS ou Time-out, consultar propriedade aResultTSS."})
    EndIf
Else
    Self:LjMensagem("aResultMetodo",{.F.,"Metodo n�o conseguiu se comunicar com TSS ou Time-out, consultar propriedade aResultTSS."})
EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LjCancInut
Metodo responsavel por realizar o cancelamento / Inutiliza��o assincrono 

@param   cId - Id composto por Serie (At� 3 posi��es ) + Doc (At� 9 posi��es)	    
@author  Lucas Novais (lnovais)
@since   02/07/2019
@version P12
@return  Consultar as propriedades aResultTSS e aResultMetodo
/*/
//----------------------------------------------------------------------
Method LjCancInut(cId,cModelo) Class LOJCNFCE
Local oLOJXNFCE     := LOJXNFCE():New()                                 // -- Controi objeto LOJXNFCE
Local oLOJGNFCE     := LOJGNFCE():New()                                 // -- Controi objeto LOJGNFCE
Local aMVMODNFCE    := oLOJGNFCE:LjGetMVTSS("MV_MODNFCE",,,,"1")        // -- Retorna o parametro MV_MODNFCE no TSS Array: {{Entidade,Conteudo},{Entidade,Conteudo},{Entidade,Conteudo},....}
Local cMVMODNFCE    := aMVMODNFCE[1][2]                                 // -- Pega o conteudo do parametro MV_MODNFCE no TSS 
Local cXML      	:= ""

DEFAULT cModelo := "65"

// Tratamento para caso a cModelo vier como string vazia
If Empty(cModelo)
    cModelo := "65"
EndIf

If ValType(aMVMODNFCE[1]) <> "U" //Entidade Nil indica que n�o tem comunica��o com TSS, desta forma retornar� o Default
    If oLOJXNFCE:LojXNfceStart()
        
        If AllTrim(cMVMODNFCE) == "2"
            cMvModNFCe := "9"
        EndIf 

        cXML := oLOJGNFCE:LjGetCodIBGE(oLOJXNFCE:oWSSPEDADM:cUF)    + ; // -- Codigo IBGE
                SUBSTR(AnoMes(dDatabase),3,4)                       + ; // -- Ano (AA) + Mes (MM)
                oLOJXNFCE:oWSSPEDADM:cCNPJ                          + ; // -- CNPJ
                cModelo 		                                    + ; // -- Modelo "65" - TBC-GO Troca por variavel para Inutilizar o modelo correto
                AllTrim(StrZero(Val(SubStr(cId,0,3)),3))            + ; // -- Serie
                AllTrim(StrZero(Val(SubStr(cId,4,10)),9))           + ; // -- Doc
                cMVMODNFCE                                          + ; // -- Modalidade 
                Alltrim(Str(Randomize( 10000000, 99999999 )))           // -- Id (C�digo num�rico que comp�e a Chave de Acesso. N�mero aleat�rio gerado pelo emitente para cada NF-e para evitar acessos indevidos da NF-e.)
        cXML := 'Id="' + cXML + Modulo11(cXML) + '"'                    // -- Compoe chave e cria digito verificador.

        If oLOJXNFCE:LjCancelaNotas(cId,cXML)
            Self:LjMensagem("aResultMetodo",{.T.,"Cancelamento executado com sucesso!"})
            Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)
        Else
            Self:LjMensagem("aResultMetodo",{.F.,"Falha ao executar o Metodo LjCancelaNotas, Consultar pripriedade aResultTSS"})    
            Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)
        EndIf
    Else
        Self:LjMensagem("aResultMetodo",{.F.,"Falha ao executar o Metodo LojXNfceStart, Consultar pripriedade aResultTSS"})   
        Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)
    EndIf 
Else
    // -- Indica que esta sem comunica��o com o TSS, o Default do parametro n�o atende a condi��o, preciso do valor real do parametro
    Self:LjMensagem("aResultMetodo",{.F.,"Falha ao executar o Metodo LjGetMVTSS, Consultar pripriedade aResultTSS"})   
    Self:LjMensagem("aResultTSS",oLOJGNFCE:aResultTSS)
EndIf

Return
