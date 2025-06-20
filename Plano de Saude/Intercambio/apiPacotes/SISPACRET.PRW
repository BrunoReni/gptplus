#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SisPacRet
    Classe auxiliar que define atributos e m�todos referentes ao retorno da API REST
        Sistema de Pacotes (SISPAC) da Unimed Brasil de acordo com Protocolo de Transa��es Unimed - PTU Vers�o 1.0 MS.104 Rev.01
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Class SisPacRet
    Data nTotal            As Numeric           // total              | Total de Registros Encontrados   | N    | 04  | O | Controle de Pagina��o.
    Data aPacotes          As Array             // rows               | Dados dos Pacotes
    Data nIdStatusExecucao As Numeric           // id_status_execucao | ID do Status da Execu��o         | N    | 02  | M |
    Data cDsStatusExecucao As String            // ds_status_execucao | Descri��o do Status da Execu��o  | A    | 100 | M | Conforme Tabela Status de Execu��o
    Data nLimit            As Numeric           // limit              | Quantidade de registros por p�g. | N    | 03  | O |
    Data nOffset           As Numeric           // offset             | Deslocamento/p�gina retornada    | N    | 02  | O |

    Method New(oResponse)
EndClass

/*/{Protheus.doc} SisPacRet:New()
    Construtor de objetos da Classe auxiliar SisPacRet
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method New(oResponse) Class SisPacRet
    Local nI
    self:aPacotes := {}
    self:nTotal   := oResponse['total']
    For nI := 1 To Len(oResponse['rows'])
        oPacote := SisPacPacote():New(oResponse['rows'][nI])
        aAdd(self:aPacotes, oPacote:toArray())
    Next
    self:nIdStatusExecucao := oResponse['status']['id_status_execucao']
    self:cDsStatusExecucao := oResponse['status']['ds_status_execucao']
    self:nLimit := oResponse['limit']
    self:nOffset := oResponse['offset']
Return