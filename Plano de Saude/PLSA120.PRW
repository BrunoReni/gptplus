#INCLUDE "plsa120.ch"
#include "PLSMGER.CH" 

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA120 � Autor � Tulio Cesar          � Data � 03.04.2000 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cadastro de Localidades                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus 5.07                                     潮�
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
Function PLSA120

Local aAliasItem
Local aKeyItem
Local aCondItem
Local aChavCab

Private aCols   := {}
Private aHeader := {}  

If ! PLSALIASEX("BSY")
   aAliasItem := {{"BSC",STR0001,,} }  //"Ambulatorios"
   aKeyItem := {"BD1->(BD1_CODINT+BD1_CODLOC)" }
   aCondItem := {"BSC->(BSC_CODINT+BSC_CODLOC)" }
   aChavCab := {{{"BSC_CODINT","M->BD1_CODINT"},{"BSC_CODLOC","M->BD1_CODLOC"}}}

   PlsCabItem("BD1",STR0001,aAliasItem,{1,1},aKeyItem,aCondItem,aChavCab,nil,nil,nil,nil,nil,nil,{|| M->BD1_NSALAS := PLSA120Atu() })
Else
   aAliasItem := {{"BSC",STR0001,,},{"BSY",STR0002,,}  }  //"Ambulatorios"###"Co-Participacao"
   aKeyItem := {"BD1->(BD1_CODINT+BD1_CODLOC)","BD1->(BD1_CODINT+BD1_CODLOC)" }
   aCondItem := {"BSC->(BSC_CODINT+BSC_CODLOC)" , "BSY->(BSY_CODINT+BSY_CODLOC)" }
   aChavCab := {{{"BSC_CODINT","M->BD1_CODINT"},{"BSC_CODLOC","M->BD1_CODLOC"}},{{"BSY_CODINT","M->BD1_CODINT"},{"BSY_CODLOC","M->BD1_CODLOC"}}}

   PlsCabItem("BD1",STR0001,aAliasItem,{1,1},aKeyItem,aCondItem,aChavCab,nil,nil,nil,nil,nil,nil)
Endif   

Return


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PLSA120Atu() � Autor � Totvs             � Data � 		  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � 		                               					      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function PLSA120Atu()

Local nCont            
Local nPos := oGetDados:PLRETPOS("BSC_NSALAS")
Local nTot := 0

If nPos > 0
   For nCont := 1 To Len(oGetDados:aCols)
       nTot  += oGetDados:aCols[nCont,nPos]
   Next        
Endif   

Return(nTot)
                   

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PLSA120Cd() � Autor � Totvs              � Data � 		  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � 	  					                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA120Cd(cCodInt) 

Local nRet    := 0
Local nOrdBD1 := BD1->(IndexOrd())

BD1->(DbSetOrder(1))

BD1->(DbSeek(xFilial("BD1")+cCodInt+Replicate("9",Len(BD1->BD1_CODLOC)),.T.))
BD1->(DbSkip(-1))
                                                           
If BD1->(BD1_FILIAL+BD1_CODINT) <> xFilial("BD1")+cCodInt
   nRet := StrZero(1,3)
Else
   nRet := StrZero(Val(BD1->BD1_CODLOC)+1,3)
Endif

BD1->(DbSetOrder(nOrdBD1))

Return(nRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 08/04/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := PLSMnDefY(, "BD1", , )

Return(aRotina)