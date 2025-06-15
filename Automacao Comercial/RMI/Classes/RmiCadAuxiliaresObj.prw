#INCLUDE "TOTVS.CH"
#INCLUDE "RMICADAUXILIARESOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiCadAuxiliaresObj
Classe respons�vel pela manipula��o dos Cadastros Auxiliares MIH

@type    method
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Class RmiCadAuxiliaresObj

    //Propridades referente a MIH
    Data cTipoCadastro  as Character
    Data cId            as Character
    Data cDescricao     as Character
    Data cAtivo         as Character
    Data jConfig        as Object

    //Layouts de Cadstros Auxiliares MIG
	Data aLayout        as Array

    //Armazena as filiais do cadastro auxiliar 
    Data aFiliais       as Array

    //Propridades referente a classe de relacionamento
    Data oRelaciona     as Object
    Data cFil           as Character
    Data cEntrada       as Character
    
    Data oImpostos      as Object

    Data oMessageError  as Object

    Method New()
    Method Grava()
    Method Limpa()
    Method GetFiliais()

    Method Carga()

    Method Impostos()
    Method ImpPorProd(cProduto)
    Method GeraImp()
    Method GetJson()

    Method Marcas()
    
    Method setDescricao()
    Method getDescricao()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da Classe

@type    method
@return  RmiCadAuxiliaresObj, Retorna o proprio objeto
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method New() Class RmiCadAuxiliaresObj

    self:cTipoCadastro  := ""
    self:cId            := ""
    self:cDescricao     := ""
    self:cAtivo         := "1"
    self:jConfig        := JsonObject():New()

    self:oRelaciona     := RmiRelacionaObj():New()
    self:cFil           := ""
    self:cEntrada       := ""

    Self:aFiliais       := Self:GetFiliais()

    self:oImpostos      := Nil

    self:oMessageError  := LjMessageError():New()

    //Carrega o layout dos cadastros auxiliares MIG
    Self:aLayout        := LjLayAuxCg()

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Efetua a atualiza��o do cadastro auxiliar MIH

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Grava() Class RmiCadAuxiliaresObj

    Local lInclusao := .F.
    Local cTipCad   := PadR(self:cTipoCadastro, TamSx3("MIH_TIPCAD")[1]) 
    Local cDescric  := PadR(self:getDescricao(), TamSx3("MIH_DESC")[1]) 
    Local aArea     := GetArea()
    
    MIH->( DbSetOrder(4) )  //MIH_FILIAL, MIH_TIPCAD, MIH_DESC, R_E_C_N_O_, D_E_L_E_T_
    lInclusao := !MIH->( DbSeek( xFilial("MIH") + cTipCad + cDescric ) )

    Begin Transaction

        If lInclusao
            LjGrvLog( GetClassName(self), "Novo cadastro auxiliar gerado - MIH.", {self:cTipoCadastro, self:getDescricao(), self:jConfig} )        

            RecLock("MIH", .T.)

                MIH->MIH_FILIAL := xFilial("MIH'")
                MIH->MIH_TIPCAD := self:cTipoCadastro
                MIH->MIH_ID     := CriaVar("MIH_ID", .T.)
                MIH->MIH_DESC   := self:getDescricao()
                MIH->MIH_ATIVO  := self:cAtivo
                MIH->MIH_DATINC := CriaVar("MIH_DATINC", .T.)
                MIH->MIH_DATALT := CriaVar("MIH_DATALT", .T.)
                MIH->MIH_CONFIG := self:jConfig:ToJson()

            MIH->( MsUnLock() )

            ConfirmSx8()
        EndIf

        //Inclui o relacionamento MIL
        self:oRelaciona:setTipo(self:cTipoCadastro)
        self:oRelaciona:Inclui(self:cFil, self:cEntrada, MIH->MIH_ID)
        //Limpa o objeto de relacionamento e mensagens de erro        
        Self:Limpa()
    End Transaction

    self:cDescricao := ""
    RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Limpa
Prepara objeto para o proximo processamento.

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Limpa() Class RmiCadAuxiliaresObj

    self:cDescricao := ""

    self:oMessageError:ClearError()
    self:oRelaciona:Limpa()
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Carga
Centraliza as cargas de dados do cadastro auxiliar

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Carga() Class RmiCadAuxiliaresObj

    self:Impostos()
    Self:Marcas()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilial
Retorna as filiais com base no cadastro de lojas

@type    method   
@author  Bruno Almeida
@since   25/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method GetFiliais() Class RmiCadAuxiliaresObj

    Local cTipoCad  := Padr("CADASTRO DE LOJA", TamSx3("MIH_TIPCAD")[1])
    Local aRet      := {} //Guarda as filiais
    Local cCodFil   := ""
    Local aArea     := GetArea()
    //Carrega as filiais
    MIH->( DbSetOrder(1) )  //MIH_FILIAL, MIH_TIPCAD, MIH_ID, R_E_C_N_O_, D_E_L_E_T_
    If MIH->( DbSeek(xFilial("MIH") + cTipoCad) )

        While !MIH->( Eof() ) .And. MIH->MIH_FILIAL == xFilial("MIH") .And. MIH->MIH_TIPCAD == cTipoCad .And. MIH->MIH_ATIVO == "1"

            //Retorna o conte�do da TAG no campo MIH_CONFIG
            cCodFil := LjCAuxRet("IDFilialProtheus")

            If !Empty(cCodFil) .And. aScan( aRet, {|x| x == cCodFil} ) == 0
                Aadd(aRet, cCodFil)
            EndIf

            MIH->( DbSkip() )
        EndDo
    EndIf
    RestArea(aArea)
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Impostos
Centraliza o processamento dos impostos

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Impostos() Class RmiCadAuxiliaresObj

    Local cBkpFilAnt:= cFilAnt
    Local nCont     := 0

    LjGrvLog(GetClassName(self), "Carga de impostos iniciada.")

    If Len(Self:aFiliais) == 0

        self:oMessageError:SetError( GetClassName(self), I18n(STR0001, {"CADASTRO DE LOJA", STR0002}) )   //"Carga de impostos n�o ser� executada. As filiais n�o foram encontradas, verifique o #1 na rotina #2."    //"Cadastros Auxiliares"
    Else

        LjGrvLog(GetClassName(self), "Processando carga de impostos para as filiais:", Self:aFiliais)

        //Processa as filiais
        For nCont:=1 To Len(Self:aFiliais)

            self:cFil   := Self:aFiliais[nCont]
            cFilAnt     := self:cFil
            LjGrvLog(GetClassName(self), "Processando filial:", self:cFil)

            self:oImpostos := RmiImpostosObj():New()

            //Processa todos os produtos
            SB1->( DbSetOrder(1) )  //B1_FILIAL+B1_COD
            If SB1->( DbSeek( xFilial("SB1") ) )
            
                //Calcula os impostos por produto
                While !SB1->( Eof() ) .And. SB1->B1_FILIAL == xFilial("SB1")

                    If self:oImpostos:setProduto(SB1->B1_COD)

                        self:cEntrada := SB1->B1_COD
                                    
                        self:oImpostos:Calcula()

                        //Gera FECP na MIH
                        self:GeraImp("FECP"      , {"IT_CODDECL", "IT_ALIQFECP","LF_MOTICMS","descontaDesoneracaoNf"}) //{"IT_CODDECL", "IT_ALIQFECP", "IT_BASFECP"}

                        //Gera PISCOFINS na MIH
                        self:GeraImp("PIS/COFINS", {"IT_ALIQPIS", "LF_CSTPIS", "IT_ALIQCOF", "LF_CSTCOF"})

                        //Gera ICMS na MIH
                        self:GeraImp("ICMS"      , {"IT_ALIQICM", "IT_PREDIC", "Modalidade", "Simbolo"})
                    EndIf

                    Self:oImpostos:Limpa()
                    Self:Limpa()

                    SB1->( DbSkip() )
                EndDo
            EndIf

            self:oImpostos:Finaliza()

            FwFreeObj(self:oImpostos)
            self:oImpostos := Nil
        Next nCont

    EndIf

    cFilAnt := cBkpFilAnt

    LjGrvLog(GetClassName(self), "Carga de impostos finalizada.")
 
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraImp
Gera o impostos com base no tipo e campos recebidos

@type    method
@param   cTipoCad, Caractere, Tipo do imposto a ser gerado
@oaram   aCampos, Array, Campos da Matxfis que ser�o retornados pelo objeto RmiImpostosObj
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method GeraImp(cTipoCad, aCampos) Class RmiCadAuxiliaresObj

    Local aMatxFis  := aCampos                
    Local jImposto  := self:oImpostos:getImposto(aMatxFis)
    Local nCont     := 0
    Local nPos      := 0
    Local cCampo    := ""

    self:cTipoCadastro  := cTipoCad

    //Carrega o layout com base no cTipoCadastro
    self:jConfig:FromJson( self:GetJson() )

    //Carrega o dados
    For nCont:=1 To Len(aMatxFis)

        cCampo  := aMatxFis[nCont]
        nPos    := aScan( self:jConfig["Components"], {|x| x["IdComponent"] == cCampo} )

        If nPos > 0
            self:jConfig["Components"][nPos]["ComponentContent"] := jImposto[cCampo]

            //Carrega a descri��o\chave MIH_DESC
            self:setDescricao( self:jConfig["Components"][nPos]["ComponentContent"] )
        EndIf

    Next nCont

    //Gera MIH
    self:Grava()

    FwFreeArray(aMatxFis)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetJson
Metodo responsavel por devolver o layout do cadastro acessado

@type    method   
@return  String, Layout com cadastro acessado
@author  Lucas Novais (lnovais@)
@since   18/11/2021
@version 12.1.37
/*/
//-------------------------------------------------------------------
Method GetJson() Class RmiCadAuxiliaresObj
Return Self:aLayout[aScan(Self:aLayout, {|X| x[1] == self:cTipoCadastro})][2]

//-------------------------------------------------------------------
/*/{Protheus.doc} setDescricao
Atualiza propriedade cDescricao utilizada como chave (MIH_DESC)

@type    method
@param   xDescricao, Variavel, Conteudo das TAGs que compoem o campo MIH_CONFIG
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method setDescricao(xDescricao) Class RmiCadAuxiliaresObj
    self:cDescricao += AllTrim( cValToChar(xDescricao) ) + "|"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getDescricao
Retorna a propriedade cDescricao (MIH_DESC)

@type    method
@return  Caractere, Defini��o que salva no campo MIH_DESC
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getDescricao() Class RmiCadAuxiliaresObj

    While SubStr(self:cDescricao, Len(self:cDescricao), 1) == "|" 
        self:cDescricao := SubStr(self:cDescricao, 1, Len(self:cDescricao) - 1)
    Enddo
    
Return self:cDescricao

//-------------------------------------------------------------------
/*/{Protheus.doc} Marcas
Metodo para gera��o e grava��o das marcas com base na tabela SB5

@type    method   
@author  Bruno Almeida
@since   25/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Marcas(cMarca) Class RmiCadAuxiliaresObj

    Local aMarcas   := {} //Recebe as marcas que foram consultadas na tabela SB5 (B5_MARCA)
    Local nI        := 0 //Variavel de loop
    Local nX        := 0 //Variavel de loop

    Default cMarca := ""

    LjGrvLog(GetClassName(Self), "Inicio da gera��o das marcas no cadastro auxiliar")
    Self:cTipoCadastro := "MARCAS"


    If Empty(cMarca)
        For nI := 1 To Len(Self:aFiliais)

            Self:cFil   := Self:aFiliais[nI]
            aMarcas     := GetMarcas(Self:aFiliais[nI])        

            For nX := 1 To Len(aMarcas)

                Self:cEntrada := aMarcas[nX]

                //Json do Cad Auxiliar de Marcas
                Self:jConfig:FromJson( Self:GetJson() )

                //Alimenta o unico campo de Marcas no Json
                Self:jConfig["Components"][1]["ComponentContent"] := aMarcas[nX]

                //Carrega a descri��o\chave MIH_DESC
                Self:setDescricao( self:jConfig["Components"][1]["ComponentContent"] )

                //Grando o cadastro de marcas
                Self:Grava()


            Next nX
        Next nI
    Else
        Self:cFil := cFilAnt
        Self:cEntrada := cMarca
        
        //Json do Cad Auxiliar de Marcas
        Self:jConfig:FromJson( Self:GetJson() )

        //Alimenta o unico campo de Marcas no Json
        Self:jConfig["Components"][1]["ComponentContent"] := cMarca

        //Carrega a descri��o\chave MIH_DESC
        Self:setDescricao( self:jConfig["Components"][1]["ComponentContent"] )

        //Grando o cadastro de marcas
        Self:Grava()
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Impostos
Centraliza o processamento dos impostos de um unico produto

@type    method   
@author  Lucas Novais 
@since   23/05/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method ImpPorProd(cProduto) Class RmiCadAuxiliaresObj

    Local cBkpFilAnt:= cFilAnt
    Local nCont     := 0

    LjGrvLog(GetClassName(self), "Carga de impostos iniciada.")

    If Len(Self:aFiliais) == 0

        self:oMessageError:SetError( GetClassName(self), I18n(STR0001, {"CADASTRO DE LOJA", STR0002}) )   //"Carga de impostos n�o ser� executada. As filiais n�o foram encontradas, verifique o #1 na rotina #2."    //"Cadastros Auxiliares"
    Else

        LjGrvLog(GetClassName(self), "Processando carga de impostos para as filiais:", Self:aFiliais)

        //Processa as filiais
        For nCont:=1 To Len(Self:aFiliais)

            self:cFil   := Self:aFiliais[nCont]
            cFilAnt     := self:cFil
            LjGrvLog(GetClassName(self), "Processando filial:", self:cFil)

            self:oImpostos := RmiImpostosObj():New()


            If self:oImpostos:setProduto(cProduto)

                self:cEntrada := SB1->B1_COD
                            
                self:oImpostos:Calcula()

                //Gera FECP na MIH
                self:GeraImp("FECP"      , {"IT_CODDECL", "IT_ALIQFECP","LF_MOTICMS","descontaDesoneracaoNf"}) //{"IT_CODDECL", "IT_ALIQFECP", "IT_BASFECP"}

                //Gera PISCOFINS na MIH
                self:GeraImp("PIS/COFINS", {"IT_ALIQPIS", "LF_CSTPIS", "IT_ALIQCOF", "LF_CSTCOF"})

                //Gera ICMS na MIH
                self:GeraImp("ICMS"      , {"IT_ALIQICM", "IT_PREDIC", "Modalidade", "Simbolo"})
            EndIf

            Self:oImpostos:Limpa()
            Self:Limpa()

            self:oImpostos:Finaliza()

            FwFreeObj(self:oImpostos)
            self:oImpostos := Nil
        Next nCont

    EndIf

    cFilAnt := cBkpFilAnt

    LjGrvLog(GetClassName(self), "Carga de impostos finalizada.")
 
Return Nil