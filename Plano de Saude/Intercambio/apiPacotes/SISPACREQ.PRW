#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SisPacReq
    Classe auxiliar que define atributos e m�todos referentes �s requisi��es do client da API REST
        Sistema de Pacotes (SISPAC) da Unimed Brasil de acordo com Protocolo de Transa��es Unimed - PTU Vers�o 1.0 MS.104 Rev.01
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Class SisPacReq
    Data cCdUniOri      As String               // cd_uni_ori    | C�digo Unimed      |  N  | 04 | M | Codifica��o: C�digo do Sistema + Cooperativa
                                                //               |                    |     |    |   | de 0001 � 0600 = Singulares
                                                //               |                    |     |    |   | de 0601 � 0650 = Seccionais
                                                //               |                    |     |    |   | de 0651 � 0850 = Entidades Internacionais
                                                //               |                    |     |    |   | de 0851 � 0949 = Intrafederativas
                                                //               |                    |     |    |   | de 0950 � 0990 = Interfederativas/Federa��o
                                                //               |                    |     |    |   | de 0991 � 0998 = Empresas do Complexo (Seguradora,UAS,etc.)
                                                //               |                    |     |    |   | 0999 = Confedera��o Nacional
                                                //               |                    |     |    |   | de 1001 � 1600 = Singulares Unicred
                                                //               |                    |     |    |   | de 1950 � 1990 = Centrais Unicred
                                                //               |                    |     |    |   | 1999 = Confedera��o Unicred
                                                //               |                    |     |    |   | de 2001 � 2999 = Usimeds
    Data cCdPacote      As String               // cd_pacote     | C�digo do Pacote   |  N  | 10 | O | Nota: Para o PTU A1200 no formato TXT dever� ser informado 8 d�gitos. Para o
                                                //               |                    |     |    |   | PTU A1200 no formatao XML dever� ser informado 10 d�gitos
    Data cCdItem        As String               // cd_item       | C�digo de Servi�o  |  N  | 10 | O | Nota: Item principal somente poder� ser Honor�rio M�dico
                                                //               | do Item Principal  |     |    |   | ou SADT (Rol de Procedimentos Unimed)
    Data cTpAcomodacao  As String               // tp_acomoda��o | Tipo de Acomodac.  | NA  | 02 | O | A=Coletiva; B=Individual; C=N�o se aplica
    Data cStPacote      As String               // st_pacote     | Status do Pacote   |  N  | 02 | O | 1 - Em constru��o
                                                //               |                    |     |    |   | 2 - Em an�lise Administrativo
                                                //               |                    |     |    |   | 3 - Em an�lise M�dico
                                                //               |                    |     |    |   | 4 - Em an�lise Enfermeiro
                                                //               |                    |     |    |   | 5 - Em an�lise Supervisor
                                                //               |                    |     |    |   | 6 � Exig�ncia
                                                //               |                    |     |    |   | 7 � Aprovado
                                                //               |                    |     |    |   | 8 - Aprovado com ressalva
                                                //               |                    |     |    |   | 9 - Publicado sem Aprova��o
                                                //               |                    |     |    |   | 10 � Reprovado
                                                //               |                    |     |    |   | 11 - Reprovado Vigente
                                                //               |                    |     |    |   | 12 � Cancelado
                                                //               |                    |     |    |   | 13 � Inv�lido
                                                //               |                    |     |    |   | 14 � Suspenso
                                                //               |                    |     |    |   | 15 � Bloqueado
                                                //               |                    |     |    |   | 16 � Duplicado
                                                //               |                    |     |    |   | 17 - Reajuste em An�lise
                                                //               |                    |     |    |   | 18 - Expirado
    Data cCdEspec       As String               // cd_espec      | C�digo da          |  N  | 02 | O | Nota: Conforme Tabela �A� � Anexo 01
                                                //               | Especialidade      |     |    |   |
    Data cTpPacote      As String               // tp_pacote     | Tipo do Pacote     |  N  | 02 | O | 3 = SADT
                                                //               |                    |     |    |   | 4 = Hospitalar
                                                //               |                    |     |    |   | 5 = Consulta
                                                //               |                    |     |    |   | 6 = Atendimento Domiciliar
                                                //               |                    |     |    |   | 7 = Sa�de Ocupacional
    Data cDtReferencia  As String               // dt_referencia | Data da refer�ncia | Dt3 | 10 | O | Nota:
                                                //               |                    |     |    |   | Para autoriza��o: Dever� ser informado a data do pedido da autoriza��o.
                                                //               |                    |     |    |   | Para cobran�a: Dever� ser informado a data do atendimento.
                                                //               |                    |     |    |   | O Servi�o ir� retornar o pacote vigente na data informada. A data de
                                                //               |                    |     |    |   | refer�ncia poder� ser igual ou maior que a data inicio de vig�ncia do pacote
                                                //               |                    |     |    |   | OU igual ou menor que a data fim de vig�ncia.
    Data cCdPrest       As String               // cd_prest      | C�d. do Prestador  |  N  | 08 | O | Nota: Campo utilizado para autoriza��o.
    Data cCdCPFCNPJ     As String               // cd_cpf_cnpj   | CNPJ ou CPF Prest. |  N  | 14 | O | Nota: Campo utilizado para cobran�a.
    Data nOffset        As Numeric              // offset        | Deslocamento/p�g.  |  N  | 02 | O | Quando n�o informado, ser� retornado a partir do primeiro pacote (offset = 0)
                                                //               | para pesquisa      |     |    |   |
    Data nLimit         As Numeric              // limit         | Qtd. de registros  |  N  | 03 | O | Quando n�o informado, ser� limitado a 10 pacotes. 
                                                //               | a serem retornados |     |    |   |

    Method New(cCodOpe)
    Method setCodOpe(cCodOpe)
    Method setCodPac(cCodPac)
    Method setCdItem(cCdItem)
    Method setTpAcom(cTpAcom)
    Method setStPaco(cStPaco)
    Method setCdEspe(cCdEspe)
    Method setTpPaco(cTpPaco)
    Method setDtRefe(cDtRefe)
    Method setCdPres(cCdPres)
    Method setCpfCnp(cCpfCnp)
    Method setOffset(nOffset)
    Method setLimite(nLimite)
EndClass

/*/{Protheus.doc} SisPacReq:New()
    Construtor de objetos da Classe auxiliar SisPacReq
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method New(cCodOpe) Class SisPacReq
    self:cCdUniOri     := cCodOpe
    self:cCdPacote     := ""
    self:cCdItem       := ""
    self:cTpAcomodacao := ""
    self:cStPacote     := ""
    self:cCdEspec      := ""
    self:cTpPacote     := ""
    self:cDtReferencia := ""
    self:cCdPrest      := ""
    self:cCdCPFCNPJ    := ""
    self:nOffset       := ""
    self:nLimit        := ""
Return

Method setCodOpe(cCodOpe) Class SisPacReq
    self:cCdUniOri     := cCodOpe
Return

Method setCodPac(cCodPac) Class SisPacReq
    self:cCdPacote     := cCodPac
Return

Method setCdItem(cCdItem) Class SisPacReq
    self:cCdItem     := cCdItem
Return

Method setTpAcom(cTpAcom) Class SisPacReq
    self:cTpAcomodacao     := cTpAcom
Return

Method setStPaco(cStPaco) Class SisPacReq
    self:cStPacote     := cStPaco
Return

Method setCdEspe(cCdEspe) Class SisPacReq
    self:cCdEspec     := cCdEspe
Return

Method setTpPaco(cTpPaco) Class SisPacReq
    self:cTpPacote     := cTpPaco
Return

Method setDtRefe(cDtRefe) Class SisPacReq
    self:cDtReferencia     := cDtRefe
Return

Method setCdPres(cCdPres) Class SisPacReq
    self:cCdPrest     := cCdPres
Return

Method setCpfCnp(cCpfCnp) Class SisPacReq
    self:cCdCPFCNPJ     := cCpfCnp
Return

Method setOffset(nOffset) Class SisPacReq
    self:nOffset     := nOffset
Return

Method setLimite(nLimite) Class SisPacReq
    self:nLimit     := nLimite
Return