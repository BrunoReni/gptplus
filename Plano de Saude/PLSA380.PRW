#INCLUDE "plsa380.ch"
#include "PLSMGER.CH"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA380 � Autor � Eduardo Motta        � Data � 18.05.2001 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cadastro de Questionario                                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪�-哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       �                                                            潮�
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

Function PLSA380(xAutoCab,xAutoItens,xOpcAuto,nReg)
Local bFilBAK := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BAK_CODPER",aHeader)]==cCodPer }
Local bFilBAL := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BAL_CODPER",aHeader)]==cCodPer .and. aCols[nLine,GdFieldPos("BAL_CODRES",aHeader)]==cCodRes }
Local aAliasItem := {{"BAJ",OemtoAnsi(STR0002)	,{|oObj|oObj:Refresh()},{|x|cCodPer := x:FieldGet("BAJ_CODPER") }, /*bFilter */     },; //"Perguntas"
                      {"BAK",OemtoAnsi(STR0003)	,{|oObj|oObj:Refresh()},{|x|cCodRes := x:FieldGet("BAK_CODRES") }, bFilBAK}} //"Respostas"

Local aKeyItem := {"BAM->BAM_PROPRI+BAM->BAM_CODQUE",;
                    "BAM->BAM_PROPRI+BAM->BAM_CODQUE"}

Local aCondItem := {"BAJ->BAJ_PROQUE+BAJ->BAJ_CODQUE",;
                     "BAK->BAK_PROQUE+BAK->BAK_CODQUE"}

Local aChavCab := {   {{"BAJ_PROQUE","M->BAM_PROPRI"},{"BAJ_CODQUE","M->BAM_CODQUE"}},;
                       {{"BAK_PROQUE","M->BAM_PROPRI"},{"BAK_CODQUE","M->BAM_CODQUE"}}}
Private cCodPer := ""
Private cCodRes := "" 

PlsCabItem("BAM",OemtoAnsi(STR0001),aAliasItem,{1,1},aKeyItem,aCondItem,aChavCab,nil,nil,xAutoCab,xAutoItens,xOpcAuto,nReg) //"Cadastro de Questionario"

Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o	 砅lsa380Num矨utor  � Eduardo Motta               � Data � 18.05.01 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矲uncao para geracao de numero sequencial de pergunta              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe	 矴rava(nOpc,nOpca,aObjGD)                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � PLSA350                                                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function Plsa380Num(nCampo)
If Type("aObjGd["+AllTrim(Str(nCampo,3))+"]") == "O"
   Return aObjGd[nCampo]:Linha()+1
Else
   Return 1
EndIf
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o	 砅LSA380AUT矨utor  � Eduardo Motta               � Data � 18.05.01 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矲uncao para rotina automatica                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe	 矴rava(nOpc,nOpca,aObjGD)                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � PLSA350                                                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA380AUT

aCab := {{"BAM_PROPRI","2",nil},;
          {"BAM_CODQUE","0001",nil},;
          {"BAM_DESCRI","DESCRICAO QUEST",nil}}
          
aItens  := {}

aadd(aItens,{ { {"BAJ_PROQUE","2",nil},{"BAJ_CODQUE","0001",nil},{"BAJ_CODPER","0001",nil},{"BAJ_DESCRI","PERG 1",nil} },;
               { {"BAJ_PROQUE","2",nil},{"BAJ_CODQUE","0001",nil},{"BAJ_CODPER","0002",nil},{"BAJ_DESCRI","PERG 2",nil} }})

aadd(aItens,{ { {"BAK_PROQUE","2",nil},{"BAK_CODQUE","0001",nil},{"BAK_CODPER","0001",nil},{"BAK_DESCRI","PERG 1",nil},{"BAK_CODRES","1",nil},{"BAK_PEDCOM","1",nil} },;
               { {"BAK_PROQUE","2",nil},{"BAK_CODQUE","0001",nil},{"BAK_CODPER","0002",nil},{"BAK_DESCRI","PERG 2",nil},{"BAK_CODRES","1",nil},{"BAK_PEDCOM","1",nil} }})
               
aadd(aItens,{ { {"BAL_PROQUE","2",nil},{"BAL_CODQUE","0001",nil},{"BAL_CODPER","0001",nil},{"BAL_CODRES","1",nil},{"BAL_SEQUEN","001",nil},{"BAL_DESCRI","DESCRI 1",nil} },;
               { {"BAL_PROQUE","2",nil},{"BAL_CODQUE","0001",nil},{"BAL_CODPER","0002",nil},{"BAL_CODRES","1",nil},{"BAL_SEQUEN","001",nil},{"BAL_DESCRI","DESCRI 2",nil} }} )
lMsErroAuto := .F.

PLSA380(aCab,aItens,K_Incluir,0)          

If lMsErroAuto
   MostraErro()
Endif   

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

Local aRotina := PLSMnDefY(, "BAM", , )

Return(aRotina)