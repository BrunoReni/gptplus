#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiXmlSefaz
Classe para manitulação do XML da Sefaz
    
/*/
//-------------------------------------------------------------------
Class RmiXmlSefaz

    Method New(nTipo, cXml) //Metodo construtor da Classe

    Method getStatus()      //Metodo que retorna se houve erro
    Method getErro()        //Metodo que retorna a mensagem de erro

    Method get(cCaminho, aTags, xValRet, nItem, lText)  //Retorna informações do XML com base nos parametros passados 
    Method getDet(aTags, nItem,xValRet, lText)         //Retorna informações do nó de itens do xml (<det>)
    Method getTotal(aTags, xValRet)                     //Retorna informações do nó de totais do xml (<total>)
    Method getDetIcms(cTag, nItem, xValRet)             //Retornar informações do nó de impostos do itens do xml (<det><imposto><ICMS>)
    Method getDetPIS(cTag, nItem, xValRet)             	//Retornar informações do nó de impostos do itens do xml (<det><imposto><PIS>)
    Method getDetCOF(cTag, nItem, xValRet)             	//Retornar informações do nó de impostos do itens do xml (<det><imposto><COFINS>)

    Data cTipo          as Caractere
    Data cXml           as Caractere
    Data oXml           as Object

    Data oMessageError  as Object

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@type    method
@return  RmiXmlSefaz, O proprio objeto da classe

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method New(nTipo, cXml) Class RmiXmlSefaz

    Local cError    := ""
    Local cWarning  := ""
    Local oXmlAux   := Nil

    self:cTipo          := IIF(nTipo == 1, "SAT", "NFCE")
    self:cXml           := cXml
    self:oMessageError  := LjMessageError():New()

    If !Empty(self:cXml)
        oXmlAux := XmlParser( self:cXml, "_", @cError, @cWarning )

        If Empty(cError) .And. Empty(cWarning)

            If XmlChildEx(oXmlAux, "_PROCINUTNFE") <> Nil
                self:oXml := Nil // quando for inutilização nao existe xml com conteudo valido.   
            Else
                If self:cTipo == "SAT"
                    self:oXml := oXmlAux:_CFE:_INFCFE
                Else
                     If XmlChildEx( oXmlAux, "_NFEPROC" ) <> Nil
						self:oXml := oXmlAux:_NFEPROC:_NFE:_INFNFE
					Else
						self:oXml := oXmlAux:_ENVINFE:_NFE:_INFNFE    
					EndIf
                EndIf
            EndIf    
        Else

             self:oMessageError:SetError( GetClassName(self), "Erro ao efetuar o parse do XML: " + cError + "|" + cWarning )
        EndIf
    EndIf

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
Método que retorna se houve erro

@type    method
@return  Lógico, Define se houve algum erro. (Erro = .F.)

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getStatus() Class RmiXmlSefaz
Return self:oMessageError:GetStatus()

//-------------------------------------------------------------------
/*/{Protheus.doc} getErro
Método que retorna a mensagem de erro

@type    method
@return  Caractere, Descrição do erro dependendo do tipo informado

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getErro() Class RmiXmlSefaz
Return self:oMessageError:GetMessage("E")

//-------------------------------------------------------------------
/*/{Protheus.doc} get
Retorna informações do XML com base nos parametros passados 

@type    Method
@param   cCaminho, Caractere, Caminho para acesso a tag
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag
@param   nItem, Numerico, Numero do item para localizar no xml
@param   lText, Lógico, Define se ira retorna a propriedade TEXT do XML
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method get(cCaminho, aTags, xValRet, nItem, lText) Class RmiXmlSefaz

    Local nTag      := 0
    Local cTag      := ""
    Local lContinua := .T.
    Local xValor    := ""

    Default cCaminho := "SELF:OXML"
    Default nItem    := 0
    Default lText    := .T.

    If Valtype(SELF:OXML) == "U"
        Return xValRet // caso o conteudo do xml for NIL retorna o que foi definido no layout com Default.
    EndIf    

    For nTag:=1 To Len(aTags)

        cTag := "_" + Upper( aTags[nTag] )

        If XmlChildEx( &(cCaminho), cTag) <> Nil
            cCaminho  := cCaminho + ":" + cTag
        Else
            lContinua := .F.
            Exit
        EndIf
    Next nTag

    Do Case
        //Executada tag
        Case lContinua
            If lText
                cCaminho := cCaminho + ":TEXT"
            EndIf

            xValor   := &(cCaminho)

            If Upper( SubStr(cTag, 2, 1) ) $ "Q|V|P" .And. ValType(xValor) == "C"
                xValor := Val(xValor)
            EndIf

        //Retorna valor default, caso não exista
        Case !lContinua .And. xValRet <> Nil
            xValor := xValRet

        OTherWise
            self:oMessageError:SetError( GetClassName(self), I18n("Tag #1 não encontrada no XML da SEFAZ, verifique!", {cCaminho + ":" + cTag}) )
    End Case

Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} getDet
Retornar informações do nó de itens do xml (<det>)

@type    Method
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   nItem, Numerico, Numero do item para localizar no xml
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag
@param   lText, Lógico, Define se ira retorna a propriedade TEXT do XML
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getDet(aTags, nItem, xValRet, lText) Class RmiXmlSefaz

    Local cCaminho := ""

    If ValType(self:oXml) != "U"
        If ValType(self:oXml:_DET) == "O"
            cCaminho := "SELF:OXML:_DET"
        Else
            cCaminho := "SELF:OXML:_DET[NITEM]"
        EndIf
    EndIf
Return self:get(cCaminho, aTags, xValRet, nItem, lText)

//-------------------------------------------------------------------
/*/{Protheus.doc} getTotal
Retornar informações do nó de totais do xml (<total>)

@type    Method
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getTotal(aTags, xValRet) Class RmiXmlSefaz
Return self:get("SELF:OXML:_TOTAL", aTags, xValRet, /*nItem*/, /*lText*/)

//-------------------------------------------------------------------
/*/{Protheus.doc} getDetIcms
Retornar informações do nó de impostos do itens do xml (<det><imposto><ICMS>)

@type    Method
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   nItem, Numerico, Numero do item para localizar no xml
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag (default)
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getDetIcms(cTag, nItem, xValRet) Class RmiXmlSefaz

    Local xValor    := ""
    Local aIcms     := {"ICMS00"    , "ICMS10"   , "ICMS20", "ICMS30", "ICMS40"    ,;
                        "ICMS51"    , "ICMS60"   , "ICMS70", "ICMS90", "ICMSSN102" ,;
                        "ICMSSN500" , "ICMSSN900"}
    Local nIcms     := 0
    Local aAux      := {"imposto", "ICMS", ""}
    Local nPosAuxImp:= 3

    //Procura o ICMS do item
    If ValType(self:oXml) != "U"
        For nIcms:=1 To Len(aIcms)

            aAux[nPosAuxImp] := aIcms[nIcms]

            xValor := self:getDet(aAux, nItem, "", .F.)

            If !Empty(xValor)
                Exit
            EndIf
        Next nIcms

        //Não encontrou nenhum ICMS no item
        If Empty(xValor)  

            self:oMessageError:SetError( GetClassName(self), "ICMS não reconhecido, verifique o nó de impostos do item no XML da SEFAZ!")
            LjGrvLog( GetClassName(self), "ICMS no item do XML da SEFAZ, não implementado: {TAG, ICMS IMPLEMENTADOS, ICMS DO XML SEFAZ}", { cTag, aIcms, self:getDet({"imposto", "ICMS"}, nItem, /*xValRet*/, .F.) } )       
        Else

            //SAT não tem tag de base
            If self:cTipo == "SAT" .And. cTag == "vBC" 
                xValor := self:getDet({"prod", "vProd"}, nItem, /*xValRet*/) - self:getDet({"prod", "vDesc"}, nItem, 0)

            //Retorno o conteudo da tag do ICMS
            Else
                Aadd(aAux, cTag)
                xValor := self:getDet(aAux, nItem, xValRet)
            EndIf
        EndIf
    Else
        xValor := xValRet // Se nao existir o objeto retorna o Default xValRet
    EndIf
    FwFreeArray(aAux)
    FwFreeArray(aIcms)

Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} getDetPIS
Retornar informações do nó de impostos do itens do xml (<det><imposto><PIS>)

@type    Method
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   nItem, Numerico, Numero do item para localizar no xml
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag (default)
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getDetPIS(cTag, nItem, xValRet) Class RmiXmlSefaz

    Local xValor:= ""
    Local aList := {"PISAliq","PISOutr","PISQtde", "PISNT","PISSN"}
    Local aAux  := {"imposto", "PIS",""}
    Local nX    := 0
    
   //Procura o PIS do item
    For nX:=1 To Len(aList)

        aAux[3] := aList[nX]

        xValor := self:getDet(aAux, nItem, "", .F.)

        If !Empty(xValor)
            Exit
        EndIf
    Next nX
    
    If Empty(xValor)
        xValor := xValRet
        LjGrvLog( GetClassName(self), "PIS com retorno default (#1) para TAG (#2), porque não foi encontrada TAGs de PIS no XML da SEFAZ.", {cValToChar(xValRet), cTag} )
    Else
        
        Aadd(aAux, cTag)
        xValor := self:getDet(aAux, nItem, xValRet)   

        If self:cTipo == "SAT" .And. cTag == "pPIS" 
            xValor := xValor * 100 //"Ajuste para quando é SAT" o valor é <pPIS>0.0165</pPIS> e quando é NFC-e <pPIS>1.65</pPIS> 
        EndIf

    EndIf
  
    FwFreeArray(aAux)
    FwFreeArray(aList)
    
Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} getDetCOF
Retornar informações do nó de impostos do itens do xml (<det><imposto><COFINS>)

@type    Method
@param   aTags, Array, Com nomes das tags para acessar a informação
@param   nItem, Numerico, Numero do item para localizar no xml
@param   xValRet, Indefinido, Valor que sera retornado caso não encontre a tag (default)
@return  Indefinido, Conteudo da tag

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getDetCOF(cTag, nItem, xValRet) Class RmiXmlSefaz

    Local xValor:= ""
    Local aList := {"COFINSAliq","COFINSQtde","COFINSNT", "COFINSSN","COFINSOutr"}
    Local aAux  := {"imposto", "COFINS",""}
    Local nX    := 0
    
   //Procura o COFINS do item
    For nX:=1 To Len(aList)

        aAux[3] := aList[nX]

        xValor := self:getDet(aAux, nItem, "", .F.)

        If !Empty(xValor)
            Exit
        EndIf
    Next nX
    
    If Empty(xValor)
        xValor := xValRet
        LjGrvLog( GetClassName(self), "COFINS com retorno default (#1) para TAG (#2), porque não foi encontrada TAGs de COFINS no XML da SEFAZ.", {cValToChar(xValRet), cTag} )
    Else
        Aadd(aAux, cTag)
        xValor := self:getDet(aAux, nItem, xValRet)

        If self:cTipo == "SAT" .And. cTag == "pCOFINS" 
            xValor := xValor * 100 //"Ajuste para quando é SAT" o valor é <pCOFINS>0.0165</pCOFINS> e quando é NFC-e <pCOFINS>1.65</pCOFINS> 
        EndIf  

    EndIf
  
    FwFreeArray(aAux)
    FwFreeArray(aList)
    
Return xValor
