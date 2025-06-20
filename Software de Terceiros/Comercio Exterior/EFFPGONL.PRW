#Include "PanelOnLine.ch"
#Include "EFFPGONL.ch"
#INCLUDE "TOPCONN.CH"

// [nType]    : Tipo do Painel de Gest�o OnLine
//              1 - Exibi��o de valores ( 1 dimens�o )
//              2 - Exibi��o de valores ( n dimens�es )
//              3 - Indicador ( 1 Valor )
//              4 - Indicador ( 2 Valores )
//              5 - Browse
// [cProcessa]: Fun��o que executa o processamento. Receber� os    // [nSegundos] : Tempo sugerido para refresh 
//              do painel. Caso seja colocado 0, n�o haver� refresh inicial.
// [aToolBar] : Array contendo as fun��es dispon�veis na barra de ferramentas. Cada posi��o do array ser� 
//              um outro array contendo : {nome do �cone, texto, bloco de a��o a ser executada}
// [nPadr�o]  : Apenas usado para o Tipo 2 de painel, informando qual o tipo de padr�o que ser� mostrado (1,2,3).
// [cID]      : Identificador ( para controle interno ) do Painel. Usar inicialmente n�meros seq�enciais e 
//              nunca dever� repetir o mesmo identificador dentro de uma mesma fun��o XXXPGOnL. 
// NOTIMER    : Desabilita o Timer ( O usu�rio n�o conseguir� definir um timer).

********************************************************************************************************
Function EFFPgOnL(oPGOnLine)
********************************************************************************************************

 Local cTitulo    := ""   ,;
       cDescr     := ""   ,;
       nType      := 0    ,;
       cPergunte  := ""   ,;
       cProcessa  := ""   ,;
       nSegundos  := 0    ,;
       aToolBar   := {}   ,;
       nPadrao    := 0    ,;
       cID        := ""

 Private cMoeDolar := EasyGParam("MV_SIMB2",,"US$")


   //************************************* Painel de Gest�o 01 **************************************//

   cTitulo    := STR0001  //"C�mbio de Exporta��o"
   cDescr     := STR0002  //"Valores do C�mbio de Exporta��o por Per�odo"
   nType      := 2
   cPergunte  := "EECPGOL6"
   cProcessa  := "EECPG06"
   nSegundos  := 0
   aToolBar   := {}
   nPadrao    := 3
   cID        := "01"


   PANELONLINE oPGOnline ADDPANEL      ;
               TITLE       cTitulo      ;
               DESCR       cDescr       ;
               TYPE        nType        ;
               PARAMETERS  cPergunte    ;
               ONLOAD      cProcessa    ;
               REFRESH     nSegundos    ;
               TOOLBAR     aToolBar     ;
               DEFAULT     nPadrao      ;
               NAME        cID

   //************************************* Painel de Gest�o 02 **************************************//

   cTitulo    := STR0003  //"C�mbio de Importa��o"
   cDescr     := STR0004  //"Valores do C�mbio de Importa��o por Per�odo"
   nType      := 2
   cPergunte  := "EICPGOL5"
   cProcessa  := "EICPG05"
   nSegundos  := 0
   aToolBar   := {}
   nPadrao    := 3
   cID        := "02"


   PANELONLINE oPGOnline ADDPANEL      ;
               TITLE       cTitulo      ;
               DESCR       cDescr       ;
               TYPE        nType        ;
               PARAMETERS  cPergunte    ;
               ONLOAD      cProcessa    ;
               REFRESH     nSegundos    ;
               TOOLBAR     aToolBar     ;
               DEFAULT     nPadrao      ;
               NAME        cID

   //************************************* Painel de Gest�o 03 **************************************//

   cTitulo    := STR0005 //"Comparativo de Financiamentos"
   nType      := 2
   cPergunte  := ""
   cProcessa  := "EFFPG01"
   nSegundos  := 900
   aToolBar   := {}
   nPadrao    := 3
   cID        := "03"

   cDescr    := STR0006+cMoeDolar+")"  //"Valores Exportados/Importados x Valores Financiados (em mil " ###

   PANELONLINE oPGOnline  ADDPANEL    ;
               TITLE       cTitulo    ;
               DESCR       cDescr     ;
               TYPE        nType      ;
               PARAMETERS  cPergunte  ;
               ONLOAD      cProcessa  ;
               REFRESH     nSegundos  ;
               TOOLBAR     aToolBar   ;
               DEFAULT     nPadrao    ;
               NAME        cID
               

   //************************************* Painel de Gest�o 04 **************************************//

   cTitulo    := STR0008  //"Contratos de Financiamentos"
   nType      := 2
   cPergunte  := "EFFPGOL2"
   cProcessa  := "EFFPG02"
   nSegundos  := 0
   aToolBar   := {}
   nPadrao    := 2
   cID        := "04"

   cDescr     := STR0009+cMoeDolar+")"  //"Valores dos Contratos de Financiamentos por Tipo (em mil "


   PANELONLINE oPGOnline ADDPANEL      ;
               TITLE       cTitulo      ;
               DESCR       cDescr       ;
               TYPE        nType        ;
               PARAMETERS  cPergunte    ;
               ONLOAD      cProcessa    ;
               REFRESH     nSegundos    ;
               TOOLBAR     aToolBar     ;
               DEFAULT     nPadrao      ;
               NAME        cID

   //************************************* Painel de Gest�o 05 **************************************//

   cTitulo    := STR0010  //"Resumo do Financiamento"
   cDescr     := STR0011  //"Informa��es resumidas sobre os contratos de Financiamento"
   nType      := 1
   cPergunte  := "EFFPGOL3"
   cProcessa  := "EFFPG03"
   nSegundos  := 0
   aToolBar   := {}
   nPadrao    := 0
   cID        := "05"

   PANELONLINE oPGOnline  ADDPANEL      ;
               TITLE       cTitulo      ;
               DESCR       cDescr       ;
               TYPE        nType        ;
               PARAMETERS  cPergunte    ;
               ONLOAD      cProcessa    ;
               REFRESH     nSegundos    ;
               TOOLBAR     aToolBar     ;
               DEFAULT     nPadrao      ;
               NAME        cID

Return