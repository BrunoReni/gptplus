
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"
#IFDEF TOP
       #include "TOPCONN.CH"
#ENDIF       
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA168 � Autor � Paulo Carnelossi		� Data � 06.06.2003 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cadastro de Comissoao X Produto...                         潮�
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
Function PLSA168()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Declaracao de variaveis...                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
PRIVATE aRotina :=	MenuDef()

PRIVATE cCadastro 	:= "Comissoes por Produto"
PRIVATE lVigente     := .F.
Pergunte("PLV905",.F.)
lVigente := If(mv_par01 == 1, .T., .F.)

SetKey(VK_F12,{|a,b| (Pergunte("PLV905",.T.), lVigente := If(mv_par01 == 1, .T., .F.)) })

BWR->(mBrowse(06,01,350,256,"BWR",,,20))

SET KEY VK_F12 TO

Return Nil
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砅L168AMov � Autor � Paulo Carnelossi      � Data � 06.06.03 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Modulo de Manutencao da Comissao por Produto               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅L168AMov(cAlias,nReg,nOpc)                                 潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PL168Mov(cAlias,nReg,nOpc)
Local I__f := 0
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define variaveis...                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Local nOpca := 0
Local oDlg, ni

Local oFont
Local lLock := .F.


Local oEncBWR
Local oFolder

Local nOpcx        := nOpc
Local oDlgFolder
Local bBrwBWQ := {||M->BWQ_QTDVLR := M->BWR_QTDVLR, M->BWQ_QTDPAR := M->BWR_QTDPAR,;
                    oBrwBWQ:Acols[oBrwBWQ:Linha()][oBrwBWQ:FieldPos("BWQ_QTDPAR")] := M->BWR_QTDPAR,;
                    oBrwBWQ:Acols[oBrwBWQ:Linha()][oBrwBWQ:FieldPos("BWQ_QTDVLR")] := M->BWR_QTDVLR,;
}           

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Comissao por Operadora/Produto                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Local aCabBWQ := {}
Local aDadBWQ := {}
Local aTrbBWQ := {}

PRIVATE aHeader      := {}
PRIVATE aCols        := {}
PRIVATE oBrwBWQ

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
M->BWR_QTDPAR := " "
M->BWR_QTDVLR := " "
M->BWQ_QTDPAR := " "
M->BWQ_QTDVLR := " "

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Comissoes por Operadora/Produto                                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Store Header "BWQ" TO aCabBWQ For .T.
If nOpcx == K_Incluir
   Store COLS Blank "BWQ" TO aDadBWQ FROM aCabBWQ
Else
   BWQ->(DbSetOrder(1))
   If ! BWQ->(DbSeek(xFilial("BWQ")+BWR->BWR_CODINT+BWR->BWR_CODPRO))
       Store COLS Blank "BWQ" TO aDadBWQ FROM aCabBWQ
   Else
       Store COLS "BWQ" TO aDadBWQ FROM aCabBWQ VETTRAB aTrbBWQ ;
       FOR If(lVigente .And. nOpcx <> K_Excluir, BWQ->(Empty(BWQ_VIGATE) .OR. BWQ_VIGATE >= dDataBase ), .T.);
       While BWQ->(BWQ_FILIAL+BWQ_CODINT+BWQ_CODPRO) == xFilial("BWQ")+BWR->BWR_CODINT+BWR->BWR_CODPRO
   Endif
   If Len(aDadBWQ) == 0
      Store COLS Blank "BWQ" TO aDadBWQ FROM aCabBWQ
   EndIf
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define dialogo...                                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� ENCHOICE (BWR)                                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

If nOpcx == K_Incluir
   Copy "BWR" TO Memory Blank
Else
   Copy "BWR" TO Memory 
   If nOpc == K_Alterar .Or. nOpc == K_Excluir
      If ! BWR->(RecLock("BWR",.F.))
         Return
      Else
         lLock := .T.
      Endif   
   Endif
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� MSMGET -> Operadora/Produto                                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

cAlias:="BWR"
nReg:=BWR->(RecNo())
oEncBWR := MSMGet():New(cAlias,nReg,nOpcx,,,,,{015,005,075,350},,,,,,oDlgFolder,,,.F.)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� TPLSBWQ -> COMISSOES DA EQUIPE DE VENDEDORES...                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//bFilter := {||.T.}
oBrwBWQ := TPLSBrw():New(080,005,350,190,nil,oDlgFolder,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBWQ,aDadBWQ,.F.,"BWQ",nOpcx,"Comissao por Produto",nil,nil,nil,aTrbBWQ,,,)
//oBrwBWQ:cVldLine := 'PLSXANAFAI( {},"BWQ_QUANTP","BWQ_QTDATE")'
oBrwBWQ:bGotFocus := {||If(!Obrigatorio(oEncBWR:aGets, oEncBWR:aTela),oEncBWR:SetFocus(),(Eval(bBrwBWQ),oBrwBWQ:Atualiza(),.T.))}
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Ativa o dialogo...                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{|| If( P168TudoOk(nOpcx) ,(PlsEndBrw(),nOpca := 1,oDlgFolder:End()),.F.)},{|| PlsEndBrw(), nOpca :=2 , oDlgFolder:End() },K_MsgDel)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Trata atualizacao dos dados...                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If nOpca == K_OK
  
   If nOpcx <> K_Visualizar 
      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
      //� Operadora+Produto                                                   �
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
      PLUPTENC("BWR",nOpc,!lLock)

      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
      //� Comissao da Operadora/Produto                                       �
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
      aChave := {}
      aadd(aChave,{"BWQ_CODINT",M->BWR_CODINT})
      aadd(aChave,{"BWQ_CODPRO",M->BWR_CODPRO})
      oBrwBWQ:Grava(aChave)

   Endif   

Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Fim da Rotina Principal...                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

Return


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � P168TudoOk � Autor � Marco Paulo         � Data � 03.10.01 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Faz a checagem dos campos e pastas obrigatorias            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � P168Tudook(nOpc)                                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nOpc - Opcao do aRotina                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function P168TudoOk(nOpc)
Local lRet := .T.

BWR->(DbSetOrder(1))
BWR->(DbSeek(xFilial()+M->BWR_CODINT+M->BWR_CODPRO))
If nOpc == K_Incluir .and. !BWR->(Eof()) // SE FOR INCLUSAO VERIFICA SE O CODIGO JA ESTA GRAVADO NO ARQUIVO E NAO DEIXA CONTINUAR
   Help("",1,"JAGRAVADO")
   Return .F.
EndIf

If ! (oBRWBWQ:TudoOk())
  	lRet    := .F.
EndIf 

Return lRet
   

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅LSA168   篈utor  砅aulo Carnelossi    � Data �  06/06/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矨ltera vigencia e copia para nova tabela vigente            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP6                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PL168Vig(cAlias,nReg,nOpc)
Local aRecords, aRecAux, nCtd, nX, nZ
Local aCabBWQ := {}, aDadBWQ := {}, aTrbBWQ := {}, oBrwBWQ
Local	oDlgFolder, oFont
Local nOpcx := nOpc, nOpca := 0

PRIVATE aHeader      := {}
PRIVATE aCols        := {}

If Pergunte("PLS905",.T.)
   dbSelectArea("BWQ")
   dbSetOrder(1)
   
   dbSeek(xFilial("BWQ")+BWR->BWR_CODINT+BWR->BWR_CODPRO)
   aRecords := {}
   
   While ! EOF() .And. BWQ_FILIAL = xFilial("BWQ") .AND. BWQ_CODINT == BWR->BWR_CODINT .And. ;
                 BWQ_CODPRO == BWR->BWR_CODPRO
   
      If Empty(BWQ->BWQ_VIGATE)
         aRecAux := {}
         For nCtd := 1 TO FCOUNT()
         	aAdd(aRecAux, {Recno(), FieldName(nCtd), FieldGet(nCtd), BWR->BWR_QTDPAR, BWR->BWR_QTDVLR})
         Next
         aAdd(aRecords, aRecAux)
   	EndIf
   	
   	dbSelectArea("BWQ")
	   dbSkip()

   End
   If Len(aRecords) > 0
	   Store Header "BWQ" TO aCabBWQ For .T.
	   BWQ->(DbSetOrder(1))
		If ! BWQ->(DbSeek(xFilial("BWQ")+BWR->BWR_CODINT+BWR->BWR_CODPRO)) 
	     	Store COLS Blank "BWQ" TO aDadBWQ FROM aCabBWQ
	   Else
	    	Store COLS "BWQ" TO aDadBWQ FROM aCabBWQ VETTRAB aTrbBWQ FOR Empty(BWQ->BWQ_VIGATE);
	    	 While BWQ->(BWQ_FILIAL+BWQ_CODINT+BWQ_CODPRO) == xFilial("BWQ")+BWR->BWR_CODINT+BWR->BWR_CODPRO
	   Endif                                  
		
		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Define dialogo...                                                   �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		DEFINE MSDIALOG oDlgFolder TITLE "Comissao por Produto: "+BWR->BWR_CODINT+"/"+BWR->BWR_CODPRO+"-"+Padr(Posicione("BA0",1,xFilial("BA0")+BWR->BWR_CODINT,"BA0_NOMINT"),20)+"/"+Alltrim(Padr(Posicione("BI3",1,xFilial("BI3")+BWR->BWR_CODINT+BWR->BWR_CODPRO,"BI3_DESCRI"),30)) FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Define Folder...PRINCIPAL (PAI)                                     �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		oBrwBWQ := TPLSBrw():New(015,005,350,190,nil,oDlgFolder,nil,{||.t.},nil,nil,nil,.T.,nil,.T.,nil,aCabBWQ,aDadBWQ,.F.,"BWQ",K_Visualizar,"Comissao por Produto",nil,nil,nil,aTrbBWQ,,,)
		
		ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{|| (PlsEndBrw(),nOpca := 1,oDlgFolder:End())},{|| PlsEndBrw(), nOpca :=2 , oDlgFolder:End() },K_MsgDel)
	
		If nOpca == 1
	      For nCtd := 1 TO Len(aRecords)
	          dbSelectArea("BWQ")
	          For nX := 1 TO LEN(aRecords[nCtd])
	              dbGoto(aRecords[nCtd][nX][1])
	              RecLock("BWQ", .F.)
	              BWQ->BWQ_VIGATE := mv_par01
	              MsUnLock()
	          Next                 			
	      Next
	      // {Recno(), FieldName(nCtd), FieldGet(nCtd)})	
	      If mv_par02 == 1  //copia para nova Tabela
	         For nCtd := 1 TO Len(aRecords)
	         	dbSelectArea("BWQ")
              	RecLock("BWQ", .T.)
	          	For nX := 1 TO LEN(aRecords[nCtd])
              	   
              	   cFieldName := aRecords[nCtd][nX][2]
              	   nPosCpo := FIELDPOS(cFieldName)
              	   
              	   If cFieldName == "BWQ_QTDPAR"
              	    	 FieldPut(nPosCpo, Str(mv_par03,1))
              	    	 If BWQ->BWQ_QTDPAR != aRecords[nCtd][nX][4]
              	    	    dbSelectArea("BWR")
              	    	    RecLock("BWR", .F.)
              	    	    BWR->BWR_QTDPAR := BWQ->BWQ_QTDPAR
              	    	    MsUnLock()
              	    	    dbSelectArea("BWQ")
              	    	 EndIf      
              	    ElseIf cFieldName == "BWQ_QTDVLR"
              	       If mv_par03 == 2 //somente grava mv_par04 qdo por qtde
              	          FieldPut(nPosCpo, Str(mv_par04,1))
              	       Else
              	          FieldPut(nPosCpo, "")
              	       EndIf
              	       If BWQ->BWQ_QTDVLR != aRecords[nCtd][nX][5]
              	    	    dbSelectArea("BWR")
              	          RecLock("BWR", .F.)
              	          BWR->BWR_QTDVLR := BWQ->BWQ_QTDVLR
              	          MsUnLock()
              	    	    dbSelectArea("BWQ")
              	    	 EndIf      

              	   Else
	              	   If cFieldName == "BWQ_VIG_DE"
	              	     	FieldPut(nPosCpo, mv_par01+1)
	              	   Else
	 	            		FieldPut(nPosCpo, aRecords[nCtd][nX][3])
	 	            	EndIf	
 	            	EndIf
            		
	          	Next
	          	MsUnLock()
	      	Next
	      EndIf
	   EndIf
	Else
		Aviso( "SEM VIGENCIA", "N鉶 existem registros para determinar vigencia.", { "Ok" }, 2 ) 
   EndIf
EndIf

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅LSA168   篈utor  矼icrosiga           � Data �  06/03/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �                                                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP6                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function PL168Imp(cAlias,nReg,nOpc)
Rel_Comiss()
Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯退屯屯屯脱屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砇el_Comiss 篈utor  砅aulo Carnelossi   � Data �  09/06/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯屯拖屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矷mprime relacao com cadastro de comiss鉶 por operadora /    罕�
北�          砅roduto                                                     罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function Rel_Comiss()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define Variaveis                                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir os cadastros"
Local cDesc2 := "de comissoes por Operadora/Produto."
Local cDesc3 := ""
Local cString := "BWQ"
Local Tamanho := "G"

PRIVATE cTitulo:= "Cadastro de Comissoes por Operadora/Produto"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLS168"
Private nomeprog:= "PLA168" 
Private nLastKey:=0

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Definicao dos cabecalhos                                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cabec1:= "                                                                                                                                                     +------Faixa------+   +------Vigencia------+"
cabec2:= "Operadora                                        Produto                                            Parcela/Qtde   Qtd.Plano/Faixa  Perc.     Valor   Inicial     Final       Inicio    Termino  "

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Envia controle para a funcao SETPRINT                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
wnrel := "PLA168"

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

RptStatus({|lEnd| ComissImp(@lEnd,wnRel,cString)},cTitulo)
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪履哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北� Fun噮o    � ComissImp� Autor � Paulo Carnelossi      � Data � 09/06/03 潮�
北媚哪哪哪哪哪拍哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北� Descri噮o � Impressao Cadastro de Comiss鉶 P/ Operadora/Produto        潮�
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Sintaxe   � ComissImp(lEnd,wnRel,cString)                              潮�
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso       �                                                            潮�
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Static Function ComissImp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local tamanho:= "G"
Local nTipo 
Local cChave, cOperadora, cProduto,lTitulo, cCodProd
Local bCondProd := {||BWQ->BWQ_CODPRO >= mv_par03 .And. BWQ->BWQ_CODPRO <= mv_par04}
Local aQtdPar := {}, aQtdVlr := {}

QNCCBOX("BWQ_QTDPAR",aQtdPar)
QNCCBOX("BWQ_QTDVLR",aQtdVlr)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=GetMv("MV_COMP")

dbSelectArea("BWQ")
SetRegua(RecCount())
dbSeek(xFilial("BWQ")+mv_par01, .T.)

While BWQ->(! Eof() .And. BWQ_FILIAL == xFilial("BWQ") .And. BWQ_CODINT <= mv_par02)
	
	IncRegua()
	
	IF li > 58
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	End
   
	cCodPro     := BWQ_CODPRO
	cChave 		:= xFilial("BWQ")+BWQ_CODINT+BWQ_CODPRO
	lTitulo 		:= .T.
	
	While  BWQ->(! EOF() .And. BWQ_FILIAL+BWQ_CODINT+BWQ_CODPRO == cChave)
	
		If Eval(bCondProd)
			IF li > 58
				cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			End
			
			If lTitulo
	
				cOperadora  := BWQ_CODINT+" - "+Padr(Posicione("BA0",1,xFilial("BA0")+BWQ->BWQ_CODINT,"BA0_NOMINT"),40)
				cProduto   	:= BWQ_CODPRO+" - "+Padr(Posicione("BI3",1,cChave,"BI3_DESCRI"),40)
	
				@li,001 PSAY cOperadora
				@li,050 PSAY cProduto
				lTitulo := .F.
				
	      EndIf
	         
		   @ li, 100 PSAY Padr(aQtdPar[Val(BWQ_QTDPAR)],15)
		   @ li, 115 PSAY Padr(If(!EMPTY(BWQ_QTDVLR),aQtdVlr[Val(BWQ_QTDVLR)],""),15)
		   @ li, 131 PSAY TRANSFORM(BWQ_PERCON,"@R 9999 %")
		   @ li, 137 PSAY TRANSFORM(BWQ_VALCON,"@EZ 999,999.99")
		   @ li, 147 PSAY Str(BWQ_QTD_DE,10)
		   @ li, 157 PSAY Str(BWQ_QTDATE,10)
		   @ li, 174 PSAY DTOC(BWQ_VIG_DE)
		   @ li, 184 PSAY DTOC(BWQ_VIGATE)
	
			li++
			
      EndIf
   	
   	BWQ->(dbSkip())
		
	End
	
End

IF li != 80
	roda(cbcont,cbtxt,tamanho)
End
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Recupera a Integridade dos dados                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
dbSelectArea("BWQ")

Set Device To Screen

If aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Darcio R. Sporl       � Data �27/12/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北�          �                                                            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados           潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01	,'AxPesqui'	, 0 ,K_Pesquisar 	,0 ,.F.},;
                   		{ STRPL02,'PL168Mov'	, 0 ,K_Visualizar	,0 ,Nil},;
             					{ STRPL03		,'PL168Mov'	, 0 ,K_Incluir   	,0 ,Nil},;
	      			  			{ STRPL04		,'PL168Mov'	, 0 ,K_Alterar   	,0 ,Nil},;
                     	{ STRPL05		,'PL168Mov'	, 0 ,K_Excluir   	,0 ,Nil},;
											{ "viG阯cia"	,'PL168Vig'	, 0 ,K_Alterar 		,0 ,Nil},;
											{ "imprimir"	,'PL168Imp'	, 0 ,K_Alterar 		,0 ,Nil} }
Return(aRotina)