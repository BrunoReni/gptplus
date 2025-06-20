#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SisPacItemAlt
    Classe auxiliar que define atributos e m�todos referentes �s informa��es sobre itens alternativos dos pacotes retornados da API REST
        Sistema de Pacotes (SISPAC) da Unimed Brasil de acordo com Protocolo de Transa��es Unimed - PTU Vers�o 1.0 MS.104 Rev.01
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Class SisPacItemAlt
    Data cCdItem          As String             // cd_item        | C�digo do Item                 | N    | 10  | O |
    Data cDsItem          As String             // ds_item        | Descri��o do Item              | ANS+ | 200 | O |
    Data nQtServico       As Numeric            // qt_servico     | Quantidade de Servi�o          | N    | 4,4 | O |
    Data nUnidadeMedida   As Numeric            // unidade_medida | Descri��o da Unidade de Medida | N    | 03  | O | Conforme tabela X2 � Anexo 01
    Data cDsUnidadeMedida As String             // 

    Method New(oItemJson)
    Method toArray()
EndClass

/*/{Protheus.doc} SisPacItemAlt:New()
    Construtor de objetos da Classe auxiliar SisPacItemAlt
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method New(oItemJson) Class SisPacItemAlt
    self:cCdItem          := oItemJson['cd_item']
    self:cDsItem          := oItemJson['ds_item']
    self:nQtServico       := oItemJson['qt_servico']
    self:nUnidadeMedida   := oItemJson['unidade_medida']
    self:cDsUnidadeMedida := oItemJson['ds_unidade_medida']
Return

/*/{Protheus.doc} SisPacItemAlt:toArray()
    Retorna objetos da Classe auxiliar SisPacItemAlt em forma de array
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method toArray() Class SisPacItemAlt
    Local aRet := {}
    aRet := {;
        self:cCdItem          ,;
        self:cDsItem          ,;
        self:nQtServico       ,;
        self:nUnidadeMedida   ,;
        self:cDsUnidadeMedida ;
    }
Return aRet