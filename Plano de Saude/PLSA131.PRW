
#INCLUDE "plsa131.ch"
#include "PLSMGER.CH"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA131 � Autor � Tulio Cesar          � Data � 03.06.2003 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Local de Atendimento X Procedimento X Medico               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA131
                                                                
Local aAliasItem := {{"BDJ",Fundesc(),,} } 

Local aKeyItem := {"BDI->(BDI_CODINT+BDI_CODLOC)" }

Local aCondItem := {"BDJ->(BDJ_CODINT+BDJ_CODLOC)" }

Local aChavCab := {{ {"BDJ_CODINT","M->BDI_CODINT"},{"BDJ_CODLOC","M->BDI_CODLOC"},;
                     {"BDJ_CODPRO","M->BDI_CODPRO"},{"BDJ_CODPAD","M->BDI_CODPAD"},;
                     {"BDJ_CDNV01","M->BDI_CDNV01"},{"BDJ_CDNV02","M->BDI_CDNV02"},;
                     {"BDJ_CDNV03","M->BDI_CDNV03"},{"BDJ_CDNV04","M->BDI_CDNV04"},;
                     {"BDJ_NIVEL","M->BDI_NIVEL"}}}

PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE n       := 1

PlsCabItem("BDI",Fundesc(),aAliasItem,{1,1},aKeyItem,aCondItem,aChavCab,nil,nil,nil,nil,nil,nil,nil)


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 08/04/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := PLSMnDefY(, "BDI", , )

Return(aRotina)