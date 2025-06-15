//----------------------------------------------------------
/*/{Protheus.doc} CRMDEF()
 
Fonte que reuni todos os Defines do modulo CRM
Criado para evitar repeti���es de define, impor um padr�o para o desenvolvimento

@param	   nehnum
       
@return   verdadeiro/falso

@author   Victor Bitencourt
@since    26/02/2014
@version  12.0
/*/
//----------------------------------------------------------

// Array de informa��es do usuario do exchange
#DEFINE _PREFIXO    2
#DEFINE _LCRMUSR    3
#DEFINE _Usuario    1
#DEFINE _SenhaUser  2 
#DEFINE _Agenda     3
#DEFINE _DtAgeIni   4
#DEFINE _DtAgeFim   5
#DEFINE _Tarefa     6
#DEFINE _DtTarIni   7
#DEFINE _DtTarFim   8
#DEFINE _EndEmail   9
#DEFINE _Contato    10
#DEFINE _Habilita   11
#DEFINE _TipoPerAge 12
#DEFINE _TipoPerTar 13
#DEFINE _TimeMin    14
#DEFINE _BiAgenda   15
#DEFINE _BiTarefa   16
#DEFINE _BiContato  17	

//Status existentes para Atividades
#DEFINE STNAOINICIADO  "1" 
#DEFINE STEMANDAMENTO  "2"
#DEFINE STCONCLUIDO    "3"
#DEFINE STAGUADOUTROS  "4"
#DEFINE STADIADA       "5"
#DEFINE STPENDENTE     "6"
#DEFINE STENVIADO      "7"
#DEFINE STLIDO         "8"

//Tipos de Atividades
#DEFINE TPTAREFA       "1"
#DEFINE TPCOMPROMISSO  "2"
#DEFINE TPEMAIL        "3"

//Rotinas 
#DEFINE RESPECIFICACAO   1
#DEFINE RATIVIDADE       2
#DEFINE RCONEXAO         3
#DEFINE RANOTACOES       4
#DEFINE REMAIL           5
#DEFINE RCEMAIL          6

// Par�metros dos Filtros 
#DEFINE ADDFIL_TITULO		1	// T�tulo que ser� exibido no filtro.
#DEFINE ADDFIL_EXPR			2	// Express�o do filtro em AdvPL ou SQL ANSI.
#DEFINE ADDFIL_NOCHECK		3	// Indica que o filtro n�o poder� ser marcado/desmarcado.
#DEFINE ADDFIL_SELECTED		4	// Indica que o filtro dever� ser apresentado como marcado/desmarcado. 
#DEFINE ADDFIL_ALIAS			5	// Indica que o filtro � de relacionamento entre as tabelas.
#DEFINE ADDFIL_FILASK		6	// Indica se o filtro pergunta as informa��es na execu��o.
#DEFINE ADDFIL_FILPARSER		7	// Array contendo informa��es parseadas do filtro. 
#DEFINE ADDFIL_ID				8	// Nome do identificador do filtro.

