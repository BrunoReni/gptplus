#INCLUDE "TOTVS.CH"
#INCLUDE "RMIIMPOSTOSOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiImpostosObj
Classe respons�vel pelo calculo de impostos

@type    class
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Class RmiImpostosObj

    Data nItem          as Numeric

    Data cCodCliente    as Character
    Data cLojCliente    as Character
    Data cProduto       as Character   
    Data cTes           as Character
    Data nValorUnit     as Numeric
    
    Data jImposto       as Object
    Data cSitTrib       as Character

    Data oMessageError  as Object

    Method New(cCodCli, cLojaCli, cProduto)
    Method Finaliza()
    Method Limpa()

    Method setProduto(cProduto)
    Method setTes(cTes)
    Method getImposto(aCampos)

    Method Calcula()

    Method Exception()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da Classe

@type    method
@param   cCodCli, Caractere, C�digo do cliente
@param   cLojaCli, Caractere, Loja do cliente
@return  RmiImpostosObj, Retorna o proprio objeto
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method New(cCodCli, cLojaCli) Class RmiImpostosObj

    Default cCodCli  := SuperGetMv("MV_CLIPAD" , , "")
    Default cLojaCli := SuperGetMv("MV_LOJAPAD", , "")

    self:nItem          := 1   
    self:cCodCliente    := PadR(cCodCli , TamSx3("A1_COD")[1] )
    self:cLojCliente    := PadR(cLojaCli, TamSx3("A1_LOJA")[1])
    self:cProduto       := ""
    self:cTes           := ""
    self:nValorUnit     := 100

    self:jImposto       := Nil
    self:cSitTrib       := ""

    self:oMessageError  := LjMessageError():New()
    
    MaFisIni(self:cCodCliente   , self:cLojCliente	, "C"           , "S"	        , "F"               ,;
             /*aRelImp*/        , /*cTpComp*/       , .F.           , "SB1"         , "LOJA701"         ,;
             "01"	            , /*cEspecie*/      , /*cCodProsp*/ , /*cGrpCliFor*/, /*cRecolheISS*/   ,;
             /*cCliEnt*/        , /*cLojEnt*/       , /*aTransp*/   , .F.           , .T.               ) 

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setProduto
Atualiza a propridade cProduto.

@type    method
@param   cProduto, Caractere, C�digo do produto
@return  L�gico, Define se foi poss�vel efetuar a atualiza��o
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method setProduto(cProduto) Class RmiImpostosObj

    Default cProduto := ""

    SB1->( DbSetOrder(1) )  //B1_FILIAL+B1_COD
    If Empty(cProduto) .Or. !SB1->( DbSeek(xFilial("SB1") + cProduto) )

        self:oMessageError:SetError( GetClassName(self), I18n(STR0001, {STR0002, cProduto}) )       //"#2 n�o localizado(a) (#2), verifique!"   //"Produto"
    Else
   
        self:cProduto := cProduto

        self:setTes()
    EndIf

Return self:oMessageError:GetStatus()

//-------------------------------------------------------------------
/*/{Protheus.doc} setTes
Atualiza a propridade cTes.

@type    method
@param   cTes, Caractere, C�digo da tes
@return  L�gico, Define se foi poss�vel efetuar a atualiza��o
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method setTes() Class RmiImpostosObj

    Local cTes := ""

    cTes := RmiTesProd(self:cProduto,self:cCodCliente,self:cLojCliente)

    SF4->( DbSetOrder(1) )  //F4_FILIAL+F4_CODIGO
    If Empty(cTes) .Or. !SF4->( DbSeek(xFilial("SF4") + cTes) )

        self:oMessageError:SetError( GetClassName(self), I18n(STR0001, {"TES", cTes}) )     //"#2 n�o localizado(a) (#2), verifique!"
    Else

        self:cTes := cTes
    EndIf
    LjGrvLog( GetClassName(self), "TES indicada para o produto (Retorno da MaTesInt)", {self:cTes,self:cProduto} )  
Return self:oMessageError:GetStatus()

//-------------------------------------------------------------------
/*/{Protheus.doc} Calcula
Efetua os calculos dos impostos utilizando a MATXFIS.

@type    method
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Calcula() Class RmiImpostosObj

    If MaFisFound("IT", self:nItem)
        //Limpa os itens da NF e zera as variaveis do cabecalho.
        MaFisClear()
    EndIf

    SB1->( DbSetOrder(1) )  //B1_FILIAL+B1_COD
    SB1->( DbSeek(xFilial("SB1") + self:cProduto) )

    SF4->( DbSetOrder(1) )  //F4_FILIAL+F4_CODIGO
    SF4->( DbSeek(xFilial("SF4") + self:cTes) )

    MaFisAdd(   self:cProduto   ,;  // 1 -Codigo do Produto ( Obrigatorio )
                self:cTes       ,;  // 2 -Codigo do TES ( Opcional ) 
                1               ,;  // 3 -Quantidade ( Obrigatorio )
                self:nValorUnit ,;  // 4 -Preco Unitario ( Obrigatorio )
                0               ,;  // 5 -Valor do Desconto ( Opcional )
                ""	 		    ,;  // 6 -Numero da NF Original ( Devolucao/Benef )
                ""    		    ,;  // 7 -Serie da NF Original ( Devolucao/Benef )
                0               ,;  // 8 -RecNo da NF Original no arq SD1/SD2
                0               ,;  // 9 -Valor do Frete do Item ( Opcional )
                0               ,;  // 10-Valor da Despesa do item ( Opcional )
                0           	,;  // 11-Valor do Seguro do item ( Opcional )
                0               ,;  // 12-Valor do Frete Autonomo ( Opcional )
                self:nValorUnit ,;  // 13-Valor da Mercadoria ( Obrigatorio )
                0	 	        ,;  // 14-Valor da Embalagem ( Opiconal )
                SB1->( Recno() ),;  // 15-RecNo do SB1
                SF4->( Recno() ) )  // 16-RecNo do SF4

    MaFisRecal("", self:nItem)

    //Verifica a situacao tributaria do item - LOJA701D
    self:cSitTrib := Lj7Strib(Nil, Nil, Nil, Nil, self:nItem)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getImposto


@type    method
@param   aCampos, Array, Campos que deseja o retorno da MATXFIS, utilizando o MATXDEF.ch como refer�ncia.
@return  JsonObject, Com os campos do par�metro aCampos e seus conteudos retornados pela MATXFIS.
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getImposto(aCampos) Class RmiImpostosObj

    Local nCont := 1
    Local aException := {}

    If MaFisFound("IT", self:nItem)

        FwFreeObj(self:jImposto) 
        self:jImposto := Nil
        self:jImposto := JsonObject():New()

        For nCont:=1 To Len(aCampos)
            If (aException := Self:Exception(aCampos[nCont]))[1]
                self:jImposto[ aCampos[nCont] ] := aException[2]
            Else    
                self:jImposto[ aCampos[nCont] ] := MaFisRet( self:nItem, aCampos[nCont] )
            EndIf
        Next nCont
    EndIf

Return self:jImposto

//-------------------------------------------------------------------
/*/{Protheus.doc} Finaliza
Encerra o calculo de impostos

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Finaliza() Class RmiImpostosObj
    MaFisEnd()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Limpa
Prepara propriedade para o proximo processamento

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Limpa() Class RmiImpostosObj
    self:oMessageError:ClearError()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Exception
Metodo responsavel por tratar exce��es no get de valores de impostos 

@type    method   
@param  String, Campo a sertratado
@return  Array, {.F.,""} -- Indica se tem exce��o e se tiver envia o dado
@author  Lucas Novais (lnovias@)
@since   18/11/2021
@version 12.1.37
/*/
//-------------------------------------------------------------------
Method Exception(cCampo) Class RmiImpostosObj

    Local aRet := {.F., ""}		//Indica se tem tratamento de exce��o no campo.
    Local aAux := {}
    Local nAux := 0
    
    Do Case
    
        Case cCampo == "IT_CODDECL"
        
            aRet := {.T.,""}
            
            //F3K_CODAJU - Codigo do Valor Declaratorio - Mesmo retorno do LOJNFCE fun��o LjCodBenef
            aAux :=  MaFisRet( self:nItem, cCampo )
            
            If Len(aAux) > 0 .AND. Len(aAux[1]) > 0
                aRet :=  {.T.,aAux[1][1]}
            EndIf

		Case cCampo == "Modalidade"
		
			aRet[1] := .T.
			aRet[2] := self:cSitTrib

		Case cCampo == "Simbolo"
		
			aRet[1] := .T.
			aRet[2] := self:cSitTrib

            Do Case
                Case SubStr(self:cSitTrib, 1, 1) == "F"
                    aRet[2] := "FF"
                Case SubStr(self:cSitTrib, 1, 1) == "N"
                    aRet[2] := "NN"
                Case SubStr(self:cSitTrib, 1, 1) == "I"
                    aRet[2] := "II"
            End Case     
        Case cCampo == "descontaDesoneracaoNf"
            aRet[1] := .T.
			aRet[2] := IIf(MaFisRet( 1,"IT_ICMDESONE" ) > 0,.F.,.T.)
        Case cCampo == "IT_ALIQICM"    //Al�quota de ICMS - Verifica se tem majora��o de FECP
            
            If (nAux := MaFisRet( self:nItem, "IT_ALIQFECP" )) > 0 
                aRet[1] := .T.            
                If (aRet[2] := MaFisRet( self:nItem, "IT_ALIQICM" ) - nAux ) < 0 
                    aRet[2] := 0     
                EndIf
            EndIf
    EndCase

Return aRet
