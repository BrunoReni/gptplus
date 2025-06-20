#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SisPacPacote
    Classe auxiliar que define atributos e m�todos referentes �s informa��es sobre pacotes retornados da API REST
        Sistema de Pacotes (SISPAC) da Unimed Brasil de acordo com Protocolo de Transa��es Unimed - PTU Vers�o 1.0 MS.104 Rev.01
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Class SisPacPacote 
    Data cCdUniOri        As String             // cd_uni_ori              | C�digo da Unimed      |  N  | 04   | M | C�d. da Unimed Origem do Pacote.
    Data cNmUniOri        As String             // nm_uni_ori              | Nome da Unimed        |  N  | 04   | M | Nome da Unimed Origem do Pacote.
    Data aPrestadores     As Array              // Dados dos Prestadores   |                       |     |      |   |
    Data cCdItem          As String             // cd_item                 | C�digo do Item        |  N  | 10   | M | Item principal do pacote
    Data cDsItem          As String             // ds_item                 | Descri��o do Item     | ANS+| 200  | M |
    Data nQtServico       As Numeric            // qt_servico              | Quantidade de Servi�o |  N  | 4,4  | M |
    Data nVlServico       As Numeric            // vl_servico              | Valor do Servi�o      |  N  | 12,2 | O | Obs: separador das casas decimais deve ser �.� (ponto)
    Data nVlTotal         As Numeric            // vl_total                | Valor total do item   |  N  | 12,2 | O | Campo VL_SERVICO multiplicado pelo campo QT_SERVI�O
                                                //                         | principal             |     |      |   | Obs: separador das casas decimais deve ser �.� (ponto)
    Data cCdPacote        As String             // cd_pacote               | C�digo do Pacote      |  N  | 10   | M | Para o PTU A1200 no formato TXT dever� ser informado 8 d�gitos. Para o PTU A1200 no
                                                //                                                       |      |   | formatao XML dever� ser informado 10 d�gitos
    Data cStPacote        As String             // st_pacote               | Status do Pacote      |  N  | 02   | O | 1 - Em constru��o
                                                //                         |                       |     |      |   | 2 - Em an�lise Administrativo
                                                //                         |                       |     |      |   | 3 - Em an�lise M�dico
                                                //                         |                       |     |      |   | 4 - Em an�lise Enfermeiro
                                                //                         |                       |     |      |   | 5 - Em an�lise Supervisor
                                                //                         |                       |     |      |   | 6 � Exig�ncia
                                                //                         |                       |     |      |   | 7 � Aprovado
                                                //                         |                       |     |      |   | 8 - Aprovado com ressalva
                                                //                         |                       |     |      |   | 9 - Publicado sem Aprova��o
                                                //                         |                       |     |      |   | 10 � Reprovado
                                                //                         |                       |     |      |   | 11 - Reprovado Vigente
                                                //                         |                       |     |      |   | 12 � Cancelado
                                                //                         |                       |     |      |   | 13 � Inv�lido
                                                //                         |                       |     |      |   | 14 � Suspenso
                                                //                         |                       |     |      |   | 15 � Bloqueado
                                                //                         |                       |     |      |   | 16 � Duplicado
                                                //                         |                       |     |      |   | 17 - Reajuste em An�lise
                                                //                         |                       |     |      |   | 18 - Expirado
    Data cTpAcomodacao    As String             // tp_acomoda��o           | Tipo de Acomodac.     | NA  | 02   | O | A=Coletiva; B=Individual; C=N�o se aplica
    Data cTpPacote                              // tp_pacote               | Tipo do Pacote        |  N  | 02   | O | 3 = SADT
                                                //                         |                       |     |      |   | 4 = Hospitalar
                                                //                         |                       |     |      |   | 5 = Consulta
                                                //                         |                       |     |      |   | 6 = Atendimento Domiciliar
                                                //                         |                       |     |      |   | 7 = Sa�de Ocupacional
    Data cCdEspecialidade                       // cd_espec                | C�digo da             |  N  | 02   | O | Nota: Conforme Tabela �A� � Anexo 01
    Data cTpInternacao    As String             // tp_internacao           | Tipo de Interna��o    |  N  | 01   | O | 1- Interna��o Cl�nica
                                                //                         |                       |     |      |   | 2- Interna��o Cir�rgica
                                                //                         |                       |     |      |   | 3- Interna��o Obst�trica
                                                //                         |                       |     |      |   | 4- Interna��o Pedi�trica
                                                //                         |                       |     |      |   | 5- Interna��o Psiqui�trica
    Data cDtNegocPacote   As String             // dt_negoc_pacote         | Data da Negocia��o do | Dt3 | 10   | M |
                                                //                         | Pacote                |     |      |   |
    Data cIndHm           As String             // ind_hm                  | Indicador se o honor. | A   | 01   | M | S � Sim N - N�o
                                                //                         | est� incluso          |     |      |   |
    Data cIndAnestesia    As String             // ind_anestesista         | Inclui Anestesista    | A   | 01   | M | S � Sim N � N�o
    Data cIndAuxiliar     As String             // ind_auxiliar            | Inclui Auxiliar       | A   | 01   | M | S � Sim N � N�o
    Data cTpRede          As String             // tp_rede                 | Tipo de Rede          | N   | 01   | O | 1 � B�sica 2 � Especial (Tabela Pr�pria) 3 � Master (Alto Custo)
    Data cIndOpme         As String             // ind_opme                | Inclui OPME           | A   | 01   | M | S � Sim N � N�o
    Data cDtInicioVig     As String             // dt_inicio_vigencia      | Data In�cio de Vig�n. | Dt3 | 10   | M |
    Data cDtFimVig        As String             // dt_fim_vigencia         | Data Fim de Vig�ncia  | Dt3 | 10   | O |
    Data cDtPublicacao    As String             // dt_publicacao           | Data da Publica��o    | Dt3 | 10   | O |
    Data cDtAprovRepro    As String             // dt_aprovacao_reprovacao | Data de aprova��o ou  |     |      |   |
                                                //                         | reprova��o do pacote  | Dt3 | 10   | O |
    Data nVlPacote        As Numeric            // vl_pacote               | Valor do Pacote       | N   | 12,2 | M | Obs: separador das casas decimais deve ser �.� (ponto)
    Data nVrPacote        As Numeric            // vr_pacote               | Vers�o do Pacote      | N   | 03   | M |
    Data nVlrMat          As Numeric
    Data nVlrMed          As Numeric 
    Data nVlrOpme         As Numeric
    Data nVlrDiarias      As Numeric
    Data nVlrTaxGas       As Numeric
    Data nVlrProc         As Numeric
    
    Data aOutrosProced    As Array              // Lista de Itens Alternativos
    Data aDetalhes        As Array              // Lista de Composi��o do Pacote
    //Data cNmPacote        As String           // Campo eliminado na vers�o mais nova da documenta��o do Sistema de Pacotes

    Method New(oPacJson)
    Method toArray()
EndClass

/*/{Protheus.doc} SisPacPacote:New()
    Construtor de objetos da Classe auxiliar SisPacPacote
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method New(oPacJson) Class SisPacPacote
    Local nI
    self:aPrestadores     := {}
    self:aDetalhes        := {}
    self:aOutrosProced    := {}
    self:cCdUniOri        := oPacJson['cd_uni_ori']
    self:cNmUniOri        := oPacJson['nm_uni_ori']
    For nI := 1 To Len(oPacJson['prestadores'])
        oPrestador := SisPacPrestador():New(oPacJson['prestadores'][nI])
        aAdd(self:aPrestadores, oPrestador:toArray())
    Next
    self:cCdItem          := oPacJson['cd_item']
    self:cDsItem          := oPacJson['ds_item']
    self:nQtServico       := oPacJson['qt_servico']
    self:nVlServico       := oPacJson['vl_servico']
    self:nVlTotal         := oPacJson['vl_total']
    self:cCdPacote        := Alltrim(oPacJson['cd_pacote'])
    self:cStPacote        := oPacJson['st_pacote']
    self:cTpAcomodacao    := oPacJson['tp_acomodacao']
    self:cTpPacote        := oPacJson['tp_pacote']
    self:cCdEspecialidade := oPacJson['cd_especialidade']
    self:cTpInternacao    := oPacJson['tp_internacao']
    self:cDtNegocPacote   := oPacJson['dt_negoc_pacote']
    self:cIndHm           := oPacJson['ind_hm']
    self:cIndAnestesia    := oPacJson['ind_anestesia']
    self:cIndAuxiliar     := oPacJson['ind_auxiliar']
    self:cTpRede          := oPacJson['tp_rede']
    self:cIndOpme         := oPacJson['ind_opme']
    self:cDtInicioVig     := oPacJson['dt_inicio_vigencia']
    self:cDtFimVig        := oPacJson['dt_fim_vigencia']
    self:cDtPublicacao    := oPacJson['dt_publicacao']
    self:cDtPublicacao    := oPacJson['dt_publicacao']
    self:cDtAprovRepro    := oPacJson['dt_aprovacao_reprovacao']
    self:nVlPacote        := oPacJson['vl_pacote']
    self:nVrPacote        := oPacJson['vr_pacote']
    self:nVlrMat          := oPacJson['vl_mat']
    self:nVlrMed          := oPacJson['vl_med']
    self:nVlrOpme         := oPacJson['vl_opme']   
    self:nVlrTaxGas       := oPacJson['vl_tax_gas']
    self:nVlrProc         := oPacJson['vl_proc']
    self:nVlrDiarias      := oPacJson['vl_diarias']

    If ValType(oPacJson['detalhes']) <> "U"
        For nI := 1 To Len(oPacJson['detalhes'])
            oDetalhes := SisPacDetalhe():New(oPacJson['detalhes'][nI])
            aAdd(self:aDetalhes, oDetalhes:toArray())
        Next
    EndIf

    If ValType(oPacJson['outros_procedimentos']) <> "U"
        For nI := 1 To Len(oPacJson['outros_procedimentos'])
            oItemAlter := SisPacItemAlt():New(oPacJson['outros_procedimentos'][nI])
            aAdd(self:aOutrosProced, oItemAlter:toArray())
        Next
    EndIf
Return

/*/{Protheus.doc} SisPacPacote:New()
    Retorna objetos da Classe auxiliar SisPacPacote em forma de array
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method toArray() Class SisPacPacote
    Local aRet := {}
    aRet := {;
        self:cCdUniOri        ,;
        self:cNmUniOri        ,;
        self:aPrestadores     ,;
        self:cCdItem          ,;
        self:cDsItem          ,;
        self:nQtServico       ,;
        self:nVlServico       ,;
        self:nVlTotal         ,;
        self:cCdPacote        ,;
        self:cStPacote        ,;
        self:cTpAcomodacao    ,;
        self:cTpPacote        ,;
        self:cCdEspecialidade ,;
        self:cTpInternacao    ,;
        self:cDtNegocPacote   ,;
        self:cIndHm           ,;
        self:cIndAnestesia    ,;
        self:cIndAuxiliar     ,;
        self:cTpRede          ,;
        self:cIndOpme         ,;
        self:cDtInicioVig     ,;
        self:cDtFimVig        ,;
        self:cDtPublicacao    ,;
        self:cDtAprovRepro    ,;
        self:nVlPacote        ,;
        self:nVrPacote        ,;
        self:aOutrosProced    ,;
        self:aDetalhes        ,;
        self:nVlrMat          ,;
        self:nVlrMed          ,;
        self:nVlrOpme         ,;
        self:nVlrTaxGas       ,;
        self:nVlrProc         ,;
        self:nVlrDiarias      ;
    }
Return aRet