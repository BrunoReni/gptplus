#Include 'Protheus.ch'
#Include "Average.ch"
#Include "TOPCONN.CH"

/*
Funcao      : EasyUpd12
Objetivos   : Validação para Update para 12
Autor       : Lucas Raminelli - LRS
Data/Hora   : 03/03/2015
*/
Function EasyUpd12(cRelease,cModulo)
   //Local cVersao := "P" + Alltrim(SubSTR(cRelease,1,2))
   //Local cLastRe := SubSTR(cRelease,Rat(".",cRelease)+1)
   //Local aRelease :={"033","2210", "2310"}

   //If aScan(aRelease,cLastRe) > 0 //####NOPADO - 26/05/2023 - Não precisa verificar o release no array para execução. Sempre que sai um novo release para a exeução até atualizarmos o fonte, isso evitará essa parada na execução.
      //&('RUP_'+cModulo+'("'+cVersao+'","0","'+cValToChar(aRelease[1])+'","'+cLastRe+'","BRA")')
      &('UPD_'+cModulo+'("' + cRelease + '")')
   //EndIF

   /*  THTS - 11/07/2017 - TE-5662 / MTRADE-1083 / WCC-524454 -  Implementar as funções TOTVS para alteração dos dicionários no Banco de Dados
    Alterada a forma de execucao das funcoes RUP de todos os modulos para que sejam executados os Releases ativos no mesmo objeto, desta
    forma, dentro das funcoes RUP teremos um unico oUpd := AVUpdate01():New() e um unico oUpd:Init(,.T.). Esta alteracao foi necessaria
    para as chamadas das novas funcoes de dicionarios no banco de dados.
   */

Return

//-------------------------------------------------------------------
/*{Protheus.doc} RUP_[XXX]
Função de compatibilização do release incremental.
Serão chamadas todas as funções compiladas referentes aos módulos cadastrados do Protheus
Será sempre considerado prefixo "RUP_" acrescido do nome padrão do módulo sem o prefixo SIGA.
Ex: para o módulo SIGAEIC criar a função RUP_EIC

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa) - 0=Chamada do AvGeral, para correções de manutenção
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA

@Author Framework
@since 28/01/2015
@version P12

Revisão:
1. removidas as chamadas de funções que não existem no programa
2. condicionada a atualização de dicionário para quando o cmode for igual a 1 (chamada via upddistr) ou 0 (chamado via avgeral) e atualização de carga de dados quando for 2 (chamada por filial)

/* Módulo SIGAEIC */
Function RUP_EIC(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
   Local cRelLoop
   Local nRelease:= 0
   Local lSimula:= .F.
   Local lBlind:= .T.

   #IFDEF TOP

      If FindFunction("AVUpdate01")

         oUpd := AVUpdate01():New()
         oUpd:lSimula:= lSimula

         If (cMode == "0" .Or. cMode == "1" )  .And. cRelFinish < "023" //atualização de dicionário, chamado do avgeral (ajustes de manutenção) ou do RUP
            /* Execução para os releases de partida ao de chegada, inclusive */
            For nRelease := Val( cRelStart ) to Val( cRelFinish )
               cRelLoop := StrZero( nRelease, 3 )
               If cRelLoop == "003"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EIC,{|o|UPDEIC003(o)}} }//MMM=(EIC,EEC,EDC,EFF,ECO)/M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC003(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "004"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC004(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC004(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "005"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC005(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC005(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "006"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC006(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC006(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "007"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC007(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "014"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC014(o)}} }
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC014(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "016"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC016(o)}} }
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC016(o)}} )
                  aAdd(oUpd:aChamados, {EIC,{|o|UTTESWHG(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "017"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC017(o)}} }
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC017(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               EndIF
            Next nRelease
         EndIf

         If cRelFinish <= "2210" //Chamada via Upddistr
            //Efetuada verificacao do relacionamento no SX9 para os campos de Codigo e Loja da tabela SWB. Caso ja exista o relacionamento correto com codigo e loja, deve ser removido o antigo sem a loja
            aAdd(oUpd:aChamados, {EIC,{|o| AjusSX9SW6(o)}})
            aAdd(oUpd:aChamados, {EIC,{|o| AjusSX9Moe(o)}})
         EndIf

         If cMode == '1' .And. cRelFinish >= "023" .And. EKB->(fieldPos("EKB_PAIS")) # 0 //Chamada via Upddistr
            aAdd(oUpd:aChamados, {EIC,{|o| UPDEIC033(o) },.F.})
         EndIf

         If cMode == '1' .And. cRelFinish >= "027" //Chamada via Upddistr
            aAdd(oUpd:aChamados, {EIC,{|o| UPDEIC033V(o)},.F.}) // Ajuste de registros existentes na SX5 (tabela Y3)
            If SW6->(FieldPos("W6_TIPOREG")) > 0
               aAdd(oUpd:aChamados, {EIC,{|o| UPDEIC033W(o)},.F.}) // Ajustes pontuais para DUIMP
            EndIf
         EndIf

         If cMode == '2' /* trocar o zero pelo '2' */ .And. cRelFinish >= "023"
            aAdd(oUpd:aChamados, {EIC,{|o| UPDEIC033Fil(o)},.F.})
         EndIf

         oUpd:Init(,lBlind)


      EndIf

   #ENDIF

Return

/* Módulo SIGAEEC */
Function RUP_EEC( cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

   Local lSimula:= .F.
   Local lBlind:= .T.

   #IFDEF TOP 

      If FindFunction("AVUpdate01")

         oUpd := AVUpdate01():New()
         oUpd:lSimula:= lSimula

         If cMode == "1" .And. cRelFinish >= "033"
            aAdd(oUpd:aChamados,{EEC,{|o|UPDEEC033(o)},.F.} )
         EndIf

         oUpd:Init(,lBlind) //não rodar o init depois do AtuDoc, se não a carga de dados vai matar as alteraçõs do AtduDoc

      EndIf
   #ENDIF

Return

/* Módulo SIGAEFF */
Function RUP_EFF( cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
   Local cRelLoop
   Local nRelease:= 0
   Local lSimula:= .F.
   Local lBlind:= .T.

   #IFDEF TOP

      If FindFunction("AVUpdate01")

         oUpd := AVUpdate01():New()
         oUpd:lSimula:= lSimula

         If (cMode == "0" .Or. cMode == "1")  .And. cRelFinish < "023" //atualização de dicionário, chamado do avgeral (ajustes de manutenção) ou do RUP
            /* Execução para os releases de partida ao de chegada, inclusive */
            For nRelease := Val( cRelStart ) to Val( cRelFinish )
               cRelLoop := StrZero( nRelease, 3 )
               If cRelLoop == "005"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EFF,{|o|UPDEFF005(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EFF,{|o|UPDEFF005(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "006"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EFF,{|o|UPDEFF006(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EFF,{|o|UPDEFF006(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "007"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EFF,{|o|UPDEFF007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EFF,{|o|UPDEFF007(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "014"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EFF,{|o|UPDEFF014(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EFF,{|o|UPDEFF014(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "016"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EEC,{|o|UPDEFF016(o)}} }
                  aAdd(oUpd:aChamados, {EEC,{|o|UPDEFF016(o)}} )
                  aAdd(oUpd:aChamados, {EIC,{|o|UTTESWHG(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "017"
                  aAdd(oUpd:aChamados, {EFF,{|o|UPDEFF017(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
               EndIf
            Next nRelease
         EndIf

         oUpd:Init(,lBlind)

      EndIf

   #ENDIF

Return

/* Módulo SIGAEDC */
Function RUP_EDC( cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
   Local cRelLoop
   Local nRelease:= 0
   Local lSimula:= .F.
   Local lBlind:= .T.

   #IFDEF TOP

      If FindFunction("AVUpdate01")

         oUpd := AVUpdate01():New()
         oUpd:lSimula:= lSimula

         If (cMode == "0" .Or. cMode == "1") .And. cRelFinish < "023" //atualização de dicionário, chamado do avgeral (ajustes de manutenção) ou do RUP
            /* Execução para os releases de partida ao de chegada, inclusive */
            For nRelease := Val( cRelStart ) to Val( cRelFinish )
               cRelLoop := StrZero( nRelease, 3 )
               If cRelLoop == "003"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC003(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  //aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC003(o)}} )
                  //oUpd:cTitulo := "Update para o modulo sIGAEDC, Release " + cRelLoop + "."
                  //oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "004"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC004(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  //aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC004(o)}} )
                  //oUpd:cTitulo := "Update para o modulo sIGAEDC, Release " + cRelLoop + "."
                  //oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "005"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC005(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  //aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC005(o)}} )
                  //oUpd:cTitulo := "Titulo do boletim técnico do Update".
                  //oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "007"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC007(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEDC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "016"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC016(o)}} )
                  aAdd(oUpd:aChamados, {EIC,{|o|UTTESWHG(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEDC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "017"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC017(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEDC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               EndIf
            Next nRelease
         EndIf

         oUpd:Init(,lBlind)

      EndIf

   #ENDIF

Return

/* Módulo SIGAESS */
Function RUP_ESS( cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
   Local cRelLoop
   Local nRelease:= 0
   Local lSimula:= .F.
   Local lBlind:= .T.

   #IFDEF TOP

      If FindFunction("AVUpdate01")

         oUpd := AVUpdate01():New()
         oUpd:lSimula:= lSimula

         If (cMode == "0" .Or. cMode == "1") .And. cRelFinish < "023" //atualização de dicionário, chamado do avgeral (ajustes de manutenção) ou do RUP
            /* Execução para os releases de partida ao de chegada, inclusive */
            For nRelease := Val( cRelStart ) to Val( cRelFinish )
               cRelLoop := StrZero( nRelease, 3 )
               If cRelLoop == "003"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {ESS,{|o|UPDESS003(o)}} } //MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS003(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "006"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {ESS,{|o|UPDESS006(o)}} } //MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS006(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "007"  // GFP - 19/10/2015
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {ESS,{|o|UPDESS007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS007(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "014"  // LRS- 26/10/2016
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {ESS,{|o|UPDESS014(o)}} }
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS014(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "016"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {ESS,{|o|UPDESS016(o)}} }
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS016(o)}} )
                  aAdd(oUpd:aChamados, {EIC,{|o|UTTESWHG(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
               ElseIf cRelLoop == "017"
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS017(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
               EndIf
            Next nRelease
         EndIf

         oUpd:Init(,lBlind)

      EndIf

   #ENDIF

Return

/*
Funcao                     : AjustaEYYSXB
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização da consulta padrão EYY
Autor       			      : wfs
Data/Hora   			      :
Revisao                    :
Obs.                       : Migrado do UPDEEC, para possibilitar a excução intependente do release, até que o pacote
                             oficial com a melhoria seja publicado
*/
Static Function AjustaEYYSXB(o)
   //MCF - Correção para versão 12.1.14 - Deletando digitação nota fiscal de remessa - Projeto Durli
   If !NFRemNewStruct() //NCF - 17/03/2017 - Deve verificar se a utilização da nova rotina está ativada antes de atualizar a consulta(solução temporária até a homologação da nova consulta)
      //Limpa nova consulta
      o:TableStruct("SXB" ,{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"           ,"XB_DESCSPA"          ,"XB_DESCENG"          ,"XB_CONTEM"                 })
      o:DelTableData("SXB",{"EYY"     ,"1"      ,"01"    ,"DB"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"1"      ,"01"    ,"RE"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"2"      ,"01"    ,"01"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"01"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"02"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"03"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"04"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"5"      ,"01"    ,""         ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"5"      ,"02"    ,""         ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"5"      ,"03"    ,""         ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"5"      ,"04"    ,""         ,""                    ,""                    ,""                    ,""                          })
      //Restaura a antiga consulta
      o:TableStruct("SXB" ,{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"              ,"XB_DESCSPA"            ,"XB_DESCENG"            ,"XB_CONTEM"                })
      o:TableData("SXB"   ,{"EYY"     ,"1"      ,"01"    ,"DB"       ,"N.F.s de Entrada"       ,"Fact. de Entrada"      ,"Receipt Invoices"      ,"SF1"                      })
      o:TableData("SXB"   ,{"EYY"     ,"2"      ,"01"    ,"01"       ,"Numero + Serie + For"   ,"Numero + Serie + Pro"  ,"Number+Series+Sup."    ,""                         })
      o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"01"       ,"Número"                 ,"Numero"                ,"Number"                ,"F1_DOC"                   })
      o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"02"       ,"Serie"                  ,"Serie"                 ,"Series"                ,"F1_SERIE"                 })
      o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"03"       ,"Fornecedor"             ,"Proveedor"             ,"Supplier"              ,"F1_FORNECE"               })
      o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"04"       ,"Loja"                   ,"Tienda"                ,"Unit"                  ,"F1_LOJA"                  })
      o:TableData("SXB"   ,{"EYY"     ,"5"      ,"01"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_DOC"              })
      o:TableData("SXB"   ,{"EYY"     ,"5"      ,"02"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_SERIE"            })
      o:TableData("SXB"   ,{"EYY"     ,"5"      ,"03"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_FORNECE"          })
      o:TableData("SXB"   ,{"EYY"     ,"5"      ,"04"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_LOJA"             })

   Else
      //Limpa a antiga consulta
      o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA"}, 1)
      o:DelTableData("SXB" ,{"EYY"     ,"1"      ,"01"    ,"DB"       })
      o:DelTableData("SXB" ,{"EYY"     ,"2"      ,"01"    ,"01"       })
      o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"01"       })
      o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"02"       })
      o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"03"       })
      o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"04"       })
      o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"01"    ,""         })
      o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"02"    ,""         })
      o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"03"    ,""         })
      o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"04"    ,""         })
      //Implementa a nova consulta
      o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"    ,"XB_DESCSPA"    ,"XB_DESCENG" ,"XB_CONTEM"              ,"XB_WCONTEM"})
      o:TableData(  "SXB",{"EYY"     ,"1"      ,"01"    ,"RE"       ,"N.F.s de Entrada","Fact de entrada" ,"Inbound Invoices","SD1"            ,            })
      o:TableData(  "SXB",{"EYY"     ,"2"      ,"01"    ,"01"       ,""                ,""                ,""                ,"AE110SD1F3()"   ,            })
      o:TableData(  "SXB",{"EYY"     ,"5"      ,"01"    ,""         ,""                ,""                ,""                ,"SD1->D1_DOC"    ,            })
      o:TableData(  "SXB",{"EYY"     ,"5"      ,"02"    ,""         ,""                ,""                ,""                ,"SD1->D1_SERIE"  ,            })
      o:TableData(  "SXB",{"EYY"     ,"5"      ,"03"    ,""         ,""                ,""                ,""                ,"SD1->D1_FORNECE",            })
      o:TableData(  "SXB",{"EYY"     ,"5"      ,"04"    ,""         ,""                ,""                ,""                ,"SD1->D1_LOJA"   ,            })

      o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_USADO"    },2)
      o:TableData  ("SX3",{"EYY_SEQEMB" ,TODOS_MODULOS })
      o:TableData  ("SX3",{"EYY_D1ITEM" ,TODOS_MODULOS })
      o:TableData  ("SX3",{"EYY_D1PROD" ,TODOS_MODULOS })
      o:TableData  ("SX3",{"EYY_QUANT"  ,TODOS_MODULOS })
   EndIf

Return

Function ELinkDados(o)

   Local aTabelas := {"EYA","EYB","EYC","EYD","EYE"}

   Local nInc, nInc2, nInc3, i // GFP - 24/08/2012
   Local lParcTit := EYC->(FieldPos("EYC_CONDIC")) > 0 .And. EYE->(FieldPos("EYE_FUNCT")) > 0 //FSM - 27/08/2012

   Private aIndEYA := {"EYA_FILIAL", "EYA_CODINT", "EYA_NOMINT", "EYA_COND"}
   Private aIndEYB := {"EYB_FILIAL", "EYB_CODAC", "EYB_DESAC"}
   Private aIndEYC := {"EYC_FILIAL", "EYC_CODEVE", "EYC_CODINT", "EYC_CODAC", "EYC_CODSRV"} //,"EYC_CONDIC"} - FSM - 27/08/2012
   Private aIndEYD := {"EYD_FILIAL", "EYD_NAME", "EYD_TYPE", "EYD_SIZE", "EYD_DECIM", "EYD_PICT", "EYD_AS"}
   Private aIndEYE := {"EYE_FILIAL", "EYE_CODINT", "EYE_CODSRV", "EYE_DESSRV", "EYE_ARQXML", "EYE_FUNCT"}
   Private aRecEYA := {}, aRecEYB := {}, aRecEYC := {}, aRecEYD := {}, aRecEYE := {}, aDelEYC := {}, aDelEYCEAI := {}

   If EYC->(FieldPos("EYC_CONDIC")) > 0  //FSM - 27/08/2012
      aAdd(aIndEYC,"EYC_CONDIC")
   EndIf

   Begin Sequence
      //FSM - 28/08/2012  - RRC - 08/02/2013 - Inclusão das integrações "003", "004" e "100"
      aAdd(aRecEYA, {EYA->(xFilial("EYA")), "001", "SIGAEEC X SIGAFIN e SIGACTB", "EasyGParam('MV_AVG0131',,.F.)"   })
      aAdd(aRecEYA, {EYA->(xFilial("EYA")), "002", "Integração Inttra"                 , "EECFlags('INTTRA')"  })
      //aAdd(aRecEYA, {EYA->(xFilial("EYA")), "003", "Estufagem de mercadorias","EECFLAGS('ESTUFAGEM')"})
      aAdd(aRecEYA, {EYA->(xFilial("EYA")), "004", "Integração SIGAESS x SIGAFIN", "Int101GetCond()"})
      aAdd(aRecEYA, {EYA->(xFilial("EYA")), "010", "Integração SIGAEEC/SIGAEFF x LOGIX", "AVFLAGS('EEC_LOGIX')"})
      aAdd(aRecEYA, {EYA->(xFilial("EYA")), "100", "SigaEEC x NovoEx", "EECFLAGS('NOVOEX')"})
      //aAdd(aRecEYA, {EYA->(xFilial("EYA")), "200", "Importacao por conta e Ordem", "EasyGParam('MV_EIC_PCO',,.F.)"})

      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "001", "Inclusao de adiantamento                 "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "002", "Exclusao de adiantamento                 "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "003", "Alteracao de adiantamento                "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "004", "Baixa de Titulo                          "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "005", "Inclusao de parcela de cambio a receber  "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "006", "Alteracao de parcela de cambio a receber "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "007", "Exclusao de parcela de cambio a receber  "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "008", "Baixa de Titulo a receber                "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "009", "Estorno de baixa de titulo a receber     "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "010", "Inclusao de parcela de cambio a pagar    "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "011", "Alteracao de parcela de cambio a pagar   "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "012", "Exclusao de parcela de cambio a pagar    "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "013", "Baixa de titulo a pagar                  "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "014", "Estorno de baixa de titulo a pagar       "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "015", "Inclusao de desp. nacional               "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "016", "Estorno de desp. nacional                "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "017", "Inclusao de cambio de desp. internacional"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "018", "Estorno de cambio de desp. internacional "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "019", "Alteracao de desp. nacional              "})  // GFP - 13/03/2012
      //aAdd(aRecEYB, {EYB->(xFilial("EYB")), "022", "Inclusão de container e estufagem" }) //RRC - 08/02/2013 - Foi descontinuado o uso do EasyLink para estufagem
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "020", "Inclusao de titulo a receber de serviço" })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "021", "Alteracao de titulo a receber de serviço"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "022", "Exclusao de titulo a receber de serviço" })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "023", "Baixa de titulo a receber de serviço"    })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "024", "Estorno de titulo a receber de serviço"  })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "025", "Inclusao de titulo a pagar de serviço"   })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "026", "Alteracao de titulo a pagar de serviço"  })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "027", "Exclusao de titulo a pagar de serviço"   })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "028", "Baixa de titulo a pagar de serviço"      })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "029", "Estorno de titulo a pagar de serviço"    })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '050', 'Inclusão de Contrato de Financiamento    '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '051', 'Inclusão de Encargo em Contrato de Financiamento   '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '052', 'Inclusão de Invoice em Financiamento               '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '053', 'Inclusão de Liquidação de Invoice em Financiamento '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '054', 'Inclusão de Parcela do Principal em Financiamento  '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '055', 'Inclusão de Parcela de Juros em Financiamento      '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '056', 'Alteração de Contrato de Financiamento'})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '057', 'Alteração de Encargo em Contrato de Financiamento  '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '058', 'Alteração de Invoice em Financiamento              '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '059', 'Alteração de Liquidação de Invoice em Financiamento'})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '060', 'Alteração de Parcela do Principal em Financiamento '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '061', 'Alteração de Parcela de Juros em Financiamento     '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '062', 'Estorno de Contrato de Financiamento               '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '063', 'Estorno de Encargo em Contrato de Financiamento    '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '064', 'Estorno de Invoice em Financiamento                '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '065', 'Estorno de Liquidação de Invoice em Financiamento  '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '066', 'Estorno de Parcela do Principal em Financiamento   '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '067', 'Estorno de Parcela de Juros em Financiamento       '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '068', 'Liquidação de Parcela do Principal em Financiamento'})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '069', 'Liquidação de Parcela de Juros em Financiamento    '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '070', 'Estorno de Liquidação de Parcela de Principal      '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '071', 'Estorno de Liquidação de Parcela de Juros          '})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "072", "Data de Embarque p/ Exportação                     "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "073", "Alteração da Data de Embarque p/ Exportação        "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "074", "Cancelamento da Data de Embarque                   "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "075", "Contabilização dos Contratos de Financiamento Ativos"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "076", "Liquidação de Encargo em Contrato de Financiamento  "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "077", "Estorno da Liquidacao dos Contratos de Financiamento"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "078", "Compensação do Adiantamento                         "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "079", "Estorno da Compensação do Adiantamento              "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "080", "Contabilização dos Contratos de Financiamento Excluidos"}) // GFP - 26/01/2012
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "090", "Estorno da Contabilização dos Contratos de Financiamento"})

      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "082", "Alteração/Aprov. de Proforma do Pedido de Exportação"})    // NCF - 02/08/2013
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "083", "Alteração/Cancelamento do Pedido de Exportação"})          // NCF - 02/08/2013

      //AAF - 10/10/2013 - Tratamento de baixa de comissão em título a receber
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "085", "Baixa de Comissão em Título a Receber"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "086", "Estorno de Baixa de Comissão em Título a Receber"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "087", "Inclusao Título receber para Comissão"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "088", "Estorno de Título a receber para Comissão"})

      //THTS - 21/03/2017 - Tratamento para inclusao e exclusao de adiantamento a fornecedores com integracao Logix
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "091", "Inclusão de Adiantamento a Fornecedor"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "092", "Exclusão de Adiantamento a Fornecedor"})
      //THTS - 18/04/2017 - Tratamento para compensacao e estorno de adiantamento a fonrnecedor com integracao Logix
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "093", "Compensação de Adiantamento a Fornecedor"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "094", "Estorno Compensação de Adiantamento a Fornecedor"})

      //THTS - 04/05/2023 - User Story 751033: DTRADE-9015 - Aglutinar despesas nacionais para geração do pedido de compras
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "095", "Inclusao de desp. nacional agrupada"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "096", "Alteração de desp. nacional agrupada"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "097", "Estorno de desp. nacional agrupada"})

      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "100", "Envio RE NovoEx"})

      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "300" ,"Geracao de Solicitacao de Booking"     })                         //NCF - 21/06/2012 - Integ. INTTRA
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "301" ,"Recebimento de Informacoes de Booking" })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "302" ,"Envio de Informacoes de SI"            })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "303" ,"Recebimento de Informacoes de SI"      })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "304" ,"Recebimento de Track and Trace"        })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "305" ,"Recebimento de BL"                     })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "306" ,"Atualizacao de arquivos Inttra"        })
      //                                      EVENT  INTEG  ACAO   SERV
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "001", "001", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "002", "002", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "003", "002", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "001", "003", "001", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "004", "005", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "005", "003", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "006", "004", "!EECFLAGS('ALT_EASYLINK')"}) //FSM - 01/08/2012
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "001", "006", "003", "!EECFLAGS('ALT_EASYLINK')"}) //FSM - 01/08/2012

      If lParcTit //FSM - 27/08/2012
         aAdd(aRecEYC, {EYC->(xFilial("EYC")), "003", "001", "006", "016", "EECFLAGS('ALT_EASYLINK')" }) //FSM - 01/08/2012
      EndIf

      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "007", "004", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "008", "006", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "009", "007", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "010", "008", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "011", "009", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "001", "011", "008", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "012", "009", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "013", "010", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "014", "011", ""})

      //RMD - 14/01/15 - Inclusão de condição para execução do evento de criação de título para despesa nacional
      //aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "015", "012", ""})
      //aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "016", "013", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "015", "012", "!EasyGParam('MV_EEC0043',,.F.)"})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "016", "013", "!EasyGParam('MV_EEC0043',,.F.)"})

      //RMD - 14/01/15 - Inclusão de evento para inclusão de pedido de compras para despesa nacional
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "001", "015", "017", "EasyGParam('MV_EEC0043',,.F.)"})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "001", "016", "018", "EasyGParam('MV_EEC0043',,.F.)"})

      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "017", "014", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "018", "015", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "001", "001", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "002", "002", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "003", "002", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "010", "003", "001", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "004", "005", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "005", "003", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "006", "003", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "007", "004", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "008", "006", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "009", "007", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "010", "008", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "011", "008", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "012", "009", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "013", "010", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "014", "011", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "015", "012", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "016", "013", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "019", "012", ""})  // GFP - 13/03/2012
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'050' , '050', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'051' , '051', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'052' , '052', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'053' , '053', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'054' , '054', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'055' , '055', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), '001','010' ,'056' , '050', ""})

      If AVFLAGS('EEC_LOGIX')

         //EXCLUSAO
         aAdd(aDelEYCEAI, {EYC->(xFilial('EYC')), '001','010' ,'057' , '051', ""}) //NCF - 30/01/2019 - (EFF) Alt.Encargo com Exclui/Inclui
         aAdd(aDelEYCEAI, {EYC->(xFilial('EYC')), '001','010' ,'060' , '054', ""}) //NCF - 30/01/2019 - (EFF) Alt.Prc.Princ com Exclui/Inclui
         aAdd(aDelEYCEAI, {EYC->(xFilial('EYC')), '001','010' ,'061' , '055', ""}) //NCF - 30/01/2019 - (EFF) Alt.Prc.Juros com Exclui/Inclui

         //INCLUSAO
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'057' , '063', ""})  //NCF - 30/01/2019 - (EFF) Alt.Encargo com Exclui/Inclui
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'057' , '051', ""})
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'060' , '066', ""})  //NCF - 30/01/2019 - (EFF) Alt.Prc.Princ com Exclui/Inclui
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'060' , '054', ""})
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'061' , '067', ""})  //NCF - 30/01/2019 - (EFF) Alt.Prc.Juros com Exclui/Inclui
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'061' , '055', ""})
      Else
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'057' , '051', ""})
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'060' , '054', ""})
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'061' , '055', ""})
      EndIf

      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'058' , '052', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'059' , '053', ""})

      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'062' , '062', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'063' , '063', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'064' , '064', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'065' , '065', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'066' , '066', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'067' , '067', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'068' , '068', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'069' , '069', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'070' , '070', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'071' , '071', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'072' , '072', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'072' , '073', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'073' , '074', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'073' , '075', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '003','010' ,'073' , '072', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '004','010' ,'073' , '073', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'074' , '074', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'074' , '075', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'075' , '076', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'076' , '077', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'077' , '078', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'078' , '079', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'079' , '080', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'080' , '081', ""}) // GFP - 26/01/2012
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'090' , '090', ""})

      //THTS - 21/03/2017 - Tratamento para inclusao e exclusao de adiantamento a fornecedor com integracao Logix
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'091' , '091', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'092' , '092', ""})
      //THTS - 18/04/2017 - Tratamento para compensacao e estorno de adiantamento a fonrnecedor com integracao Logix
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'093' , '093', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'094' , '094', ""})

      //aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "015", "012"})

      aAdd(aRecEYC, {EYC->(xFilial("EYC")), '001','010' ,'082' , '082', ""}) //// NCF - 02/08/2013 - Pedido de Exportação - Aprov. Proforma
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), '001','010' ,'083' , '083', ""}) //// NCF - 02/08/2013 - Pedido de Exportação - Cancelamento

      //AAF - 10/10/2013 - Tratamento de baixa de comissão em título a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001','010' ,'085' , '085', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001','010' ,'086' , '086', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001','010' ,'087' , '087', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001','010' ,'088' , '088', ""})


      //THTS - 19/12/2017 - Esta carga dos eventos do siscoserv estava sendo feita para o codigo 001 referente a integracao do eec. Foi alterada para exlcuir da carga 001 mantendo somente na carga 004
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "020"      , "003"        , ""}) //Inclusao de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "021"      , "004"        , ""}) //Exclusao de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "002"       , "001"       , "021"      , "003"        , ""}) //Inclusao de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "022"      , "004"        , ""}) //Exclusao de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "023"      , "005"        , ""}) //Baixa de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "024"      , "007"        , ""}) //Estorno de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "025"      , "008"        , ""}) //Inclusao de titulo a pagar
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "026"      , "009"        , ""}) //Exclusao de titulo a pagar
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "002"       , "001"       , "026"      , "008"        , ""}) //Inclusao de titulo a pagar
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "027"      , "009"        , ""}) //Exclusao de titulo a pagar
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "028"      , "010"        , ""}) //Baixa de titulo a pagar
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "029"      , "011"        , ""}) //Estorno de titulo a pagar

      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,"300"       , '001', ""}) //NCF - 21/06/2012 - Integ. INTTRA
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,"301"       , '002', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,'302'       , '003', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,'303'       , '004', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,'304'       , '006', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,'305'       , '005', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,'306'       , '008', ""})
      //RRC - 13/02/2013 - Foi descontinuada a integração EasyLink da estufagem
      //aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "003"       , "022"      , "001"        , ""}) //Inclusão de container e estufagem
      //aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002"       , "003"       , "022"      , "002"        , ""}) //Inclusão de container e estufagem

      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "020"      , "003"        , ""}) //Inclusao de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "021"      , "004"        , ""}) //Exclusao de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002"       , "004"       , "021"      , "003"        , ""}) //Inclusao de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "022"      , "004"        , ""}) //Exclusao de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "023"      , "005"        , ""}) //Baixa de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "024"      , "007"        , ""}) //Estorno de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "025"      , "008"        , ""}) //Inclusao de titulo a pagar
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "026"      , "009"        , ""}) //Exclusao de titulo a pagar
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002"       , "004"       , "026"      , "008"        , ""}) //Inclusao de titulo a pagar
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "027"      , "009"        , ""}) //Exclusao de titulo a pagar
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "028"      , "010"        , ""}) //Baixa de titulo a pagar
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "029"      , "011"        , ""}) //Estorno de titulo a pagar

      //THTS - 04/05/2023 - User Story 751033: DTRADE-9015 - Aglutinar despesas nacionais para geração do pedido de compras
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "095"      , "019"        , ""}) //Inclusao desp. nacional agrupada
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "096"      , "020"        , ""}) //Alteracao desp. nacional agrupada
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "097"      , "021"        , ""}) //Exclusao desp. nacional agrupada

      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "100"       , "100"      , "100"        , ""}) //Envio RE NovoEx

      If !(EYC->(FieldPos("EYC_CONDIC")) > 0)  //NCF - 24/08/2012
         For i := 1 to Len(aRecEYC)
            aDel( aRecEYC[i],Len(aRecEYC[i]) )
            aSize( aRecEYC[i],Len(aRecEYC[i])-1 )
         Next i
      EndIf

      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "TESTE               ", "A",          1,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "DATA_SEND           ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "DATA_SELECTION      ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "DATA_RECEIVE        ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "DATA                ", "D",          8,          0, "@D"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "HORA                ", "C",          8,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "USER                ", "C",         60,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "USUARIO             ", "C",         60,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_SEND            ", "A",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_IT              ", "A",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_ELE1            ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_ELE2            ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_ELE3            ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "SEND_FIN            ", "C",       5000,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ERROR_FIN           ", "C",        500,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "SERVICE_STATUS      ", "L",          3,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "SRV_STATUS          ", "L",          3,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "SRV_MSG             ", "C",        500,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "CMD                 ", "C",          3,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_NUM             ", "C",          3,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "BAIXA_TITULO        ", "L",          1,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_SEQ             ", "N",         15,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "AUTMOTBX            ", "C",          3,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "AUTDTBAIXA          ", "D",          8,          0, "@D"                   , ""})
	  aAdd(aRecEYD, {EYD->(xFilial("EYD")), "AUTDTDEB            ", "D",          8,          0, "@D"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "AUTHIST             ", "C",         60,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "SEND                ", "C",        500,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "AUTVALREC           ", "N",         17,          2, "@E 999,999,999,999.99", ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "AUTTXMOEDA          ", "N",         11,          4, "@E 999999.9999    ", ""})

      //aAdd(aRecEYD, {EYD->(xFilial("EYD")), "XML               ", "X",        100,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"PEDIDOS"              , "A",         20,          0, "@!"                   , ""}) //NCF - 21/06/2012 - Integ. INTTRA
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"EQUIPMENT"            , "A",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"PACKAGES"             , "A",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TOT_EQUIP"            , "N",         20,          5, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TOT_PACKAGE"          , "N",         20,          5, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TOT_VOLUME"           , "N",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"LINE"                 , "N",         20,          5, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"LINENUMBER"           , "N",         20,          5, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"REF_NUM"              , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"XML"                  , "X",        500,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"PESOBR"               , "N",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TIPO_LOC"             , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TIPO_COD_LOC"         , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"COD_LOC"              , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TIPO_DATA_LOC"        , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"DATA_LOC"             , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"REF_TIPO"             , "A",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"NAVIO"                , "A",        100,          0, "@!"                   , ""})

      //RMD - 16/01/15 - Tags utilizadas na integração de pedido de compra para despesas nacionais.
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"ACAB"                , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"ADET"                , "A",        100,          0, "@!"                   , ""})

      //RRC - 13/02/2013 - Foi descontinuada a integração EasyLink da estufagem
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ESTUF_SEL           ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ESTUF_IT            ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ESTUF_CPO           ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ESTUF_ID            ", "C",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "CONTNR_SEL          ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "CONTNR_IT           ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "CONTNR_CPO          ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "CONTNR_ID           ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ESTUF_ID            ", "C",         20,          0, ""                     , ""})

      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "001", "Inclusao de titulo de adiantamento       "                  , "AVLINK001.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "002", "Exclusao de titulo de adiantamento       "                  , "AVLINK002.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "003", "Inclusao de titulo de receita            "                  , "AVLINK003.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "004", "Exclusao de titulo de receita            "                  , "AVLINK004.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "005", "Baixa de titulo a receber                "                  , "AVLINK005.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "006", "Baixa de titulo a receber e adiantamento "                  , "AVLINK006.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "007", "Estorno de baixa de titulo a receber     "                  , "AVLINK007.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "008", "Inclusao de titulo a pagar               "                  , "AVLINK008.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "009", "Exclusao de titulo a pagar               "                  , "AVLINK009.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "010", "Baixa de titulo a pagar                  "                  , "AVLINK010.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "011", "Estorno de baixa de titulo a pagar       "                  , "AVLINK011.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "012", "Inclusão de titulo de desp. nacional     "                  , "AVLINK012.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "013", "Exclusão de titulo de desp. nacional     "                  , "AVLINK013.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "014", "Inclusão de titulo de desp. internacional"                  , "AVLINK014.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "015", "Exclusão de titulo de desp. internacional"                  , "AVLINK015.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "016", "Alteracao de titulo de receita           "                  ,""              , 'AF200SE1Integ(4)'        }) //FSM - 01/08/2012

      //RMD - 14/01/15 - Criação de pedido de compras para despesas nacionais
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "017", "Inclusão de Pedido de desp. nacional     "                  ,"ELINK001.APH"  , ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "018", "Exclusão de Pedido de desp. nacional     "                  ,"ELINK002.APH"  , ""                        })

      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "001", "Inclusao de titulo de adiantamento       "                  ,""              , 'EECAF212(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "002", "Exclusao de titulo de adiantamento       "                  ,""              , 'EECAF212(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "003", "Inclusao de titulo de receita            "                  ,""              , 'EECAF210(3)'             }) // "EasyEnvEAI('EECAF210',3)"})
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "004", "Exclusao de titulo de receita            "                  ,""              , 'EECAF210(5)'             }) // "EasyEnvEAI('EECAF210',5)"})
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "005", "Baixa de titulo a receber                "                  ,""              , 'EECAF213(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "007", "Estorno de baixa de titulo a receber     "                  ,""              , 'EECAF221(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "008", "Inclusao de titulo a pagar               "                  ,""              , 'EECAF214(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "009", "Exclusao de titulo a pagar               "                  ,""              , 'EECAF214(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "010", "Baixa de titulo a pagar                  "                  ,""              , 'EECAF215(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "011", "Estorno de baixa de titulo a pagar       "                  ,""              , 'EECAF222(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "012", "Inclusão de titulo de desp. nacional     "                  ,""              , 'EECAF216(3)'             }) // GFP - 08/03/2012 - EasyEnvEAI('EECAF216',3)
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "013", "Exclusão de titulo de desp. nacional     "                  ,""              , 'EECAF216(5)'             }) // GFP - 08/03/2012 - EasyEnvEAI('EECAF216',5)
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '050','Inclusão de Contrato de Financiamento                       ',''              , 'EECAF217(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '051','Inclusão de Encargo em Contrato de Financiamento            ',''              , 'EECAF218(3)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '054','Inclusão de Parcela do Principal em Financiamento           ',''              , 'EECAF218(3)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '055','Inclusão de Parcela de Juros em Financiamento               ',''              , 'EECAF218(3)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '062','Estorno de Contrato de Financiamento                        ',''              , 'EECAF217(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '063','Estorno de Encargo em Contrato de Financiamento             ',''              , 'EECAF218(5)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '066','Estorno de Parcela do Principal em Financiamento            ',''              , 'EECAF218(5)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '067','Estorno de Parcela de Juros em Financiamento                ',''              , 'EECAF218(5)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '068','Liquidação de Parcela do Principal em Financiamento         ',''              , 'EECAF226(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '069','Liquidação de Parcela de Juros em Financiamento             ',''              , 'EECAF226(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '070','Estorno de Liquidação de Parcela de Principal               ',''              , 'EECAF229(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '071','Estorno de Liquidação de Parcela de Juros                   ',''              , 'EECAF229(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '072','Baixa do CPV                                                ',''              , 'EECAF223(3)'             }) // FSM - 16/01/2012 - EasyEnvEAI("EECAF223",3)
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '073','Lançamento de variação cambial de NF                        ',''              , 'EECAF224(3)'             }) // GFP - 18/01/2012 - EasyEnvEAI("EECAF224",3)
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '074','Estorno da Baixa do CPV                                     ',''              , 'EECAF223(5)'             }) // FSM - 16/01/2012 - EasyEnvEAI("EECAF223",5)
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '075','Estorno do lançamento de variação cambial de NF             ',''              , 'EECAF224(5)'             }) // GFP - 18/01/2012 - EasyEnvEAI("EECAF224",5)
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '076','Contabilização dos contratos de Financiamento Ativos        ',''              , 'EECAF225(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '077','Liquidação de Encargo em Contrato de Financiamento          ',''              , 'EECAF226(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '078','Estorno da Liquidacao dos Contratos de Financiamento        ',''              , 'EECAF229(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '079','Compensação do Adiantamento                                 ',''              , 'EECAF227(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '080','Estorno da Compensação do Adiantamento                      ',''              , 'EECAF230(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '081','Contabilização dos contratos de Financiamento Excluidos     ',''              , 'EasyEnvEAI("EECAF228",3)'}) // GFP - 26/01/2012
      //NCF - 09/04/2014 - Tratamento de integração com fluxo alternativo de geração do Pedido
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '082','Alteração/Aprov. de Proforma do Pedido de Exportação        ',''              , 'EasyEnvEAI("EECAP100",3)'})//NCF - 02/09/2013
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '083','Alteração/Cancelamento do Pedido de Exportação              ',''              , 'EasyEnvEAI("EECAP100",5)'})//NCF - 02/09/2013
      //AAF - 10/10/2013 - Tratamento de baixa de comissão em título a receber
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '085','Baixa de Comissão em Título a Receber                       ',''              , 'EECAF231(3)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '086','Estorno de Baixa de Comissão em Título a Receber            ',''              , 'EECAF232(5)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '087','Inclusao Título a Receber referente a Comissão              ',''              , 'EECAF210(3)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '088','Estorno de Título a Receber referente a Comissão            ',''              , 'EECAF210(5)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '090','Estorno da Contabilização dos contratos de Financiamento    ',''              , 'EECAF225(5)'             })

      //THTS - 21/03/2017 - Tratamento para inclusao e exclusao de adiantamento a fornecedor com integracao Logix
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '091','Inclusão de adiantamento a fornecedor						   ',''              , 'EECAF520(3)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '092','Exclusão de adiantamento a fornecedor						   ',''              , 'EECAF520(5)'             })
      //THTS - 18/04/2017 - Tratamento para compensacao e estorno de adiantamento a fonrnecedor com integracao Logix
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '093','Compensação de adiantamento a fornecedor						   ',''              , 'EECAF521(3)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '094','Estorno Compensação de adiantamento a fornecedor				   ',''              , 'EECAF522(5)'             })

      //aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '052','Inclusão de Invoice em Financiamento                        ','', 'EasyEnvEAI("ADAPTER",3)'})
      //aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '053','Inclusão de Liquidação de Invoice em Financiamento          ','', 'EasyEnvEAI("ADAPTER",3)'})
      //aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '064','Estorno de Invoice em Financiamento                         ','', 'EasyEnvEAI("ADAPTER",5)'})
      //aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '065','Estorno de Liquidação de Invoice em Financiamento           ','', 'EasyEnvEAI("ADAPTER",5)'})
      //aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "006", "Baixa de titulo a receber e adiantamento                   ","", "EasyEnvEAI('EECAF213',5)"})
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"001" ,"Solicitacao de Booking"                                      , "int_bk_request.xml"  ,""    }) //NCF - 21/06/2012 - Integ. INTTRA
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"002" ,"Recebimento de informacaoes de booking"                      , "int_bk_confirm.xml"  ,""    })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"003" ,"Envio de Shipping Instructions"                              , "int_si_send.xml"     ,""    })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"004" ,"Inttra Boundary Manager"                                     , "int_si_acknowled.xml",""    })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"005" ,"Recebimento de BL"                                           , "int_bl_receive.xml"  ,""    })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"006" ,"Recebimento de Track and Trace"                              , "int_tt_rec.xml"      ,""    })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"008" ,"Inttra Boundary Manager"                                     , "int_bd_man.xml"      ,""    })

      //RRC - 13/02/2013 - Foi descontinuada a integração EasyLink da estufagem
      //aAdd(aRecEYE, {EYE->(xFilial("EYE")), "003", "001", "Inclusão de registros de container       "                  , "CONTAINER_INC.XML", ""                    })
      //aAdd(aRecEYE, {EYE->(xFilial("EYE")), "003", "002", "Inclusão de registros de estufagem       "                  , "ESTUFAGEM_INC.XML", ""                    })

      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "003", "Inclusao de titulo de receita            "                  , "AVLINK003.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "004", "Exclusao de titulo de receita            "                  , "AVLINK004.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "005", "Baixa de titulo a receber                "                  , "AVLINK005.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "007", "Estorno de baixa de titulo a receber     "                  , "AVLINK007.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "008", "Inclusao de titulo a pagar               "                  , "AVLINK008.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "009", "Exclusao de titulo a pagar               "                  , "AVLINK009.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "010", "Baixa de titulo a pagar                  "                  , "AVLINK010.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "011", "Estorno de baixa de titulo a pagar       "                  , "AVLINK011.XML", ""                        })

      //THTS - 04/05/2023 - User Story 751033: DTRADE-9015 - Aglutinar despesas nacionais para geração do pedido de compras
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "019", "Inclusão de desp. nacional agrupada      "                  , "", "DN400GRDES(3)"                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "020", "Alteração de desp. nacional agrupada     "                  , "", "DN400GRDES(4)"                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "021", "Estorno de desp. nacional agrupada       "                  , "", "DN400GRDES(5)"                        })

      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "100", "100", "Geração de novo RE - NovoEX              "                  , "novoex_novo_re.xml", ""                   })
      If !(EYE->(FieldPos("EYE_FUNCT")) > 0)  //NCF - 24/08/2012
         For i := 1 to Len(aRecEYE)
            aDel( aRecEYE[i],Len(aRecEYE[i]) )
            aSize( aRecEYE[i],Len(aRecEYE[i])-1 )
         Next i
      EndIf

      If ValType(o) == "U"
         For nInc := 1 To Len(aTabelas)
            /////////////////////////////////////////////////////
            //Verifica se a tabela existe e se possui registros//
            /////////////////////////////////////////////////////
            If (ChkFile(aTabelas[nInc]) .and. Select(aTabelas[nInc]) > 0) .and. !(aTabelas[nInc])->(DbSeek(xFilial()))//(aTabelas[nInc])->(RecCount()) > 0
               //////////////////////////////
               //Não é necessário atualizar//
               //////////////////////////////
               Loop
            Else
               /////////////////////
               //Atualiza a tabela//
               /////////////////////
               DbSelectArea(aTabelas[nInc])
               For nInc2 := 1 To Len(&("aRec"+aTabelas[nInc]))
                  If RecLock(aTabelas[nInc],.T.)
                     For nInc3:=1 To Len(&("aInd"+aTabelas[nInc]))
                        If FieldPos(&("aInd"+aTabelas[nInc])[nInc3])>0
                           FieldPut(FieldPos(&("aInd"+aTabelas[nInc])[nInc3]),&("aRec"+aTabelas[nInc])[nInc2][nInc3])
                        EndIf
                     Next
                  EndIf
               Next
            EndIf
         Next
      Else

         //FDR - 27/07/11
         o:TableStruct("EYA",aIndEYA,1)
         o:TableStruct("EYB",aIndEYB,1)
         o:TableStruct("EYC",aIndEYC,1)
         o:TableStruct("EYD",aIndEYD,1)
         o:TableStruct("EYE",aIndEYE,1)

         If AVFLAGS('EEC_LOGIX')                  //NCF - 18/02/2019 - Verifica flag para implementar ação/serviço de alteração no modo exclui/inclui para os eventos principal,juros e encargos EFF.
            o:DelTableData("EYC",aDelEYCEAI,,.F.)
         EndIf

         o:TableData("EYA",aRecEYA,,.F.)//RMD - 22/12/14 - Incluído parâmetro para que não altere os registros já existenstes.
         o:TableData("EYB",aRecEYB,,.F.)//RMD - 22/12/14 - Incluído parâmetro para que não altere os registros já existenstes.
         o:TableData("EYC",aRecEYC,,.F.)//RMD - 22/12/14 - Incluído parâmetro para que não altere os registros já existenstes.
         o:TableData("EYD",aRecEYD,,.F.)//RMD - 22/12/14 - Incluído parâmetro para que não altere os registros já existenstes.
         o:TableData("EYE",aRecEYE,,.F.)//RMD - 22/12/14 - Incluído parâmetro para que não altere os registros já existenstes.
         o:DelTableData("EYC",aDelEYC,,.F.)//THTS - 19/12/2017 - Exclui a carga dos eventos do siscoserv da integracao 001 (SIGAEEC X SIGAFIN e SIGACTB)

      EndIf

   End Sequence

Return Nil

Static Function UTTESWHG (o)

   o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RESERV" },2)
   o:TableData("SX3"  ,{'E11_DESRED' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED1_PRCUNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED1_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED8_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED8_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED8_QTDNCM' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED8_SALISE' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED9_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED9_QT_AC' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED9_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDA_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDA_QTDEST' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDC_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDC_QTDEST' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDC_QTDPRO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDD_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDD_QTD_EX' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDD_QTD_OR' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDE_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDG_PRCUNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDG_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE5_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE7_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE7_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRCFIX' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRCUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECO2' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECO3' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECO4' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECO5' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECOI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRENEG' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PSBRUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PSLQTO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PSLQUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_QTDFIX' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_QTDLOT' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_SLDATU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_VLPAG ', TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRCUN ', TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECO2' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECO3' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECO4' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECO5' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECOI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PSBRTO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PSBRUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PSLQTO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PSLQUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_QT_AC ', TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_SALISE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_VLPAG' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEB_TXCOMI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEC_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEC_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEC_VALCOM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEK_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEM_OUTROM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEM_VLFREM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEM_VLMERM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEM_VLNFM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEM_VLSEGM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEO_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLFREM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLMERC' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLMERM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLNF' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLNFM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLOUTM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLSEGM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEX_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEX_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEY_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEY_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEY_PRCUNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEY_PREMI1' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEY_PREMI2' , TAM+DEC     })
   o:TableData("SX3"  ,{'EF8_VL_PCT' , TAM+DEC     })
   o:TableData("SX3"  ,{'EG0_CARGO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EG0_PARC_C' , TAM+DEC     })
   o:TableData("SX3"  ,{'EG1_QTDMT' , TAM+DEC     })
   o:TableData("SX3"  ,{'EG1_QTDUC' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI1_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_DESCON' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_INLAND' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_OUT_DE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_PACKIN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_PRUNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_QUANT' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI3_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI4_ENCARG' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI4_FOB_GE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI4_FOB_TO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI4_PESO_B' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI4_VAL_CO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI5_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI5_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI5_SALDO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI9_VALOR2' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI9_VALOR3' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI9_VALOR4' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI9_VALOR5' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI9_VALOR6' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIA_VALOR' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIB_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EID_DESP' , TAM+DEC     })
   o:TableData("SX3"  ,{'EID_VLCORR' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_QT_EST' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_QTDCER' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_QTUCOF' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_QTUIPI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_QTUPIS' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIS_PESO ', TAM+DEC     })
   o:TableData("SX3"  ,{'EIS_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIS_QT_AC' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIS_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIW_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW0_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW1_LIQMER' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW1_MER_US' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW1_VLRUNR' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_VLLIQ ', TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_VLMER' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_VLMOED' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_VLRUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW5_PESOB' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW5_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW5_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW5_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX5_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX6_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH01' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH02' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH03' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH04' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH05' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH06' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH07' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH08' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH09' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH10' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL01' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL02' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL03' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL04' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL05' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL06' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL07' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL08' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL09' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL10' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS01' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS02' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS03' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS04' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS05' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS06' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS07' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS08' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS09' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS10' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_VLMAX' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_VLMIN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXP_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXP_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PRCINC' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PRCTOT' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PRECO ', TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PSBRTO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PSBRUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PSLQTO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PSLQUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_QE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_SALDO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXS_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXS_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXS_QTDEMB' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXS_QTDVNC' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXT_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXU_PESOBR' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXU_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXV_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXZ_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY2_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY5_SLDATU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY5_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY6_SLDATU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY6_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY7_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY8_SLDATU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY8_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY9_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'W1_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W1_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W1_QTSEGUM' , TAM+DEC     })
   o:TableData("SX3"  ,{'W1_SALDO_Q' , TAM+DEC     })
   o:TableData("SX3"  ,{'W2_ENCARGO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W2_FOB_TOT' , TAM+DEC     })
   o:TableData("SX3"  ,{'W2_PARID_U' , TAM+DEC     })
   o:TableData("SX3"  ,{'W2_PESO_B ', TAM+DEC     })
   o:TableData("SX3"  ,{'W2_VAL_COM' , TAM+DEC     })
   o:TableData("SX3"  ,{'W3_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W3_PRECOVE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W3_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W3_SALDO_Q' , TAM+DEC     })
   o:TableData("SX3"  ,{'W4_FOB_TOT' , TAM+DEC     })
   o:TableData("SX3"  ,{'W4_OUT_DES' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_QT_AC' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_QT_AC2' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_SALDO_Q' , TAM+DEC     })
   o:TableData("SX3"  ,{'W6_PESO_BR' , TAM+DEC     })
   o:TableData("SX3"  ,{'W6_PESO_TO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W6_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'W7_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W7_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W7_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W7_SALDO_Q' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_PRECO_F' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_QT_AC' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_QT_AC2' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_QTDE_UM' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_SALISEN' , TAM+DEC     })
   o:TableData("SX3"  ,{'WA_PGTANT' , TAM+DEC     })
   o:TableData("SX3"  ,{'WA_SLDANT' , TAM+DEC     })
   o:TableData("SX3"  ,{'WD_VAL_PRE' , TAM+DEC     })
   o:TableData("SX3"  ,{'WE_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'WE_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'WE_SALDO_Q' , TAM+DEC     })
   o:TableData("SX3"  ,{'WH_VALOR_R' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO1' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO2' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO3' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO4' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO5' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO6' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR1' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR2' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR3' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR4' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR5' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR6' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_01' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_02' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_03' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_04' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_05' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_06' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_07' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_08' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_09' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_10' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_11' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_12' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO01' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO02' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO03' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO04' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO05' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO06' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO07' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO08' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO09' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO10' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO11' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO12' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_DESCONT' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_INLAND ', TAM+DEC     })
   o:TableData("SX3"  ,{'WN_OUT_DES' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_PACKING' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_PRUNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_QTSEGUM' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_QTUCOF' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_QTUIPI' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_QTUPIS' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_QUANT ', TAM+DEC     })
   o:TableData("SX3"  ,{'WP_QT_EST' , TAM+DEC     })
   o:TableData("SX3"  ,{'WS_PESO ', TAM+DEC     })
   o:TableData("SX3"  ,{'WS_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'WT_FOB_TOT' , TAM+DEC     })
   o:TableData("SX3"  ,{'WT_FOB_UNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'WT_VL_UNIT' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO1' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO2' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO3' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO4' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO5' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO6' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR1' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR2' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR3' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR4' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR5' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR6' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO1' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO2' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO3' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO4' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO5' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO6' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR_K' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR1' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR2' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR3' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR4' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR5' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR6' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VL_MIN' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_MAXIMO' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_MINIMO' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_VLR_02' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_VLR_03' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_VLR_04' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_VLR_05' , TAM+DEC     })


Return Nil

/*
Funcao            : AjustaEYYSXB
Parametros        : Objeto de update PAI
Objetivos         : Excluir relacionamento SX9 errado da SW6 que não contem a loja na chave
Revisao           : -
Autor             : Tiago Henrique Tudisco dos Santos - THTS
Obs.              : O relacionamento correto com o campo Loja foi digitado para a versão 12.1.31 em Janeiro/2021
*/
Static Function AjusSX9SW6(o)
   Local aOrdSX9   := SaveOrd("SX9")
   Local aDadosSX9 := {}
   Local lTemLoja  := .F.
   Local nI := 0

   SX9->(dbSetOrder(2))//X9_CDOM + X9_DOM

   If SX9->(dbSeek("SW6" + "SA2"))
      While SX9->(!Eof()) .And. SX9->X9_DOM == "SA2" .And. SX9->X9_CDOM == "SW6"
         If "A2_LOJA" $ SX9->X9_EXPDOM
            lTemLoja := .T.
         Else
            If SX9->X9_ENABLE == "S"
               aAdd(aDadosSX9,{SX9->X9_DOM, SX9->X9_IDENT,SX9->X9_CDOM,SX9->X9_EXPDOM,SX9->X9_EXPCDOM})
            EndIf
         EndIf
         SX9->(dbSkip())
      End

      If lTemLoja .And. Len(aDadosSX9) > 0
         o:TableStruct( "SX9",{"X9_DOM","X9_IDENT" ,"X9_CDOM"  ,"X9_EXPDOM","X9_EXPCDOM","X9_ENABLE"},2)
         For nI := 1 To Len(aDadosSX9)
            o:TableData("SX9",{aDadosSX9[nI][1],aDadosSX9[nI][2],aDadosSX9[nI][3],aDadosSX9[nI][4],aDadosSX9[nI][5],"N"})
         Next
      EndIf
   EndIf

   RestOrd(aOrdSX9)

Return

Static Function AjusSX9Moe(o)
   Local aOrdSX9   := SaveOrd("SX9")
   Local aDadosSX9 := {}
   Local nI := 0

   SX9->(dbSetOrder(2))//X9_CDOM + X9_DOM
   //Tratamento para excluir relacionamento que contem a funcao dToS, pois da erro. Ja corrigida no AtuSX
   If SX9->(dbSeek("SWB" + "SYE"))
      While SX9->(!Eof()) .And. SX9->X9_DOM == "SYE" .And. SX9->X9_CDOM == "SWB"
         If "DTOS" $ SX9->X9_EXPDOM .And. SX9->X9_ENABLE == "S"
            aAdd(aDadosSX9,{SX9->X9_DOM, SX9->X9_IDENT,SX9->X9_CDOM,SX9->X9_EXPDOM,SX9->X9_EXPCDOM})
         EndIf
         SX9->(dbSkip())
      End
   EndIf
   //Tratamento para excluir relacionamendo da moeda pela tabela de taxas de conversao (SYE). Foram criados os corretos pela tabela de Moeda (SYF)
   If SX9->(dbSeek("SW6" + "SYE"))
      While SX9->(!Eof()) .And. SX9->X9_DOM == "SYE" .And. SX9->X9_CDOM == "SW6"
         If ("W6_FREMOED" $ SX9->X9_EXPCDOM .Or. "W6_SEGMOED" $ SX9->X9_EXPCDOM) .And. SX9->X9_ENABLE == "S"
            aAdd(aDadosSX9,{SX9->X9_DOM, SX9->X9_IDENT,SX9->X9_CDOM,SX9->X9_EXPDOM,SX9->X9_EXPCDOM})
         EndIf
         SX9->(dbSkip())
      End
   EndIf

   If Len(aDadosSX9) > 0
      o:TableStruct( "SX9",{"X9_DOM","X9_IDENT" ,"X9_CDOM"  ,"X9_EXPDOM","X9_EXPCDOM","X9_ENABLE"},2)
      For nI := 1 To Len(aDadosSX9)
         o:TableData("SX9",{aDadosSX9[nI][1],aDadosSX9[nI][2],aDadosSX9[nI][3],aDadosSX9[nI][4],aDadosSX9[nI][5],"N"}) //Desabilita Relacionamento
      Next
   EndIf

   RestOrd(aOrdSX9)
Return
