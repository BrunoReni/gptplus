#INCLUDE "PLSA108.ch"
#INCLUDE "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA108 � Autor 砇egiane Rocha Barreira� Data � 22.01.2007 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Prorroga玢o de di醨ias por lote						      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PLSA108

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Monta matriz com as opcoes do browse...                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
PRIVATE aRotina		:=	{	{ STR0001	,'AxPesqui'  , 0 , K_Pesquisar  },; //"Pesquisar"
							{ STR0002	,'PLSA108VIS', 0 , K_Visualizar },; //"Visualizar"
							{ STR0003	,'PLSA108INC', 0 , K_Incluir    } } //"Incluir"


PRIVATE cCadastro	:= STR0004	// "Prorroga玢o de di醨ias por lote"

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Starta mBrowse...                                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
B38->(DBSetOrder(1))
B38->(mBrowse(06,01,22,75,'B38',,,,,,,,,,, .T. ))

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Fim da Rotina...                                                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪穆哪哪穆哪哪哪哪哪勘�
北矲uncao    � PLSA108VIS � Autor 砇egiane Rocha Barreira� Data�22.01.2007潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪牧哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Visualizacao                                               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PLSA108VIS(cAlias,nReg,nOpc)

Local I__f		:= 0
Local oDlg
Local oEnc
Local oGetB39
Local nOpca		:= 0
Local aHeaderB39:= {}
Local aColsB39	:= {}
Local aVetTrab	:= {}
Local aPosObj   := {}
Local aObjects	:= {}
Local aSize     := {}
Local aInfo     := {}

Private n := 1

Copy cAlias To Memory Blank
Store Header "B39" to aHeaderB39 For .T.

DbSelectArea("B39")
DbSetOrder(1)	//B39_FILIAL+B39_CODOPE+B39_LOTE+B39_SEQ

If MsSeek(xFilial("B39")+B38->(B38_CODOPE+B38_LOTE))
	Store COLS "B39" TO aColsB39 FROM aHeaderB39 VETTRAB aVetTrab While xFilial("B39") == B39->B39_FILIAL .and. B39->(B39_CODOPE+B39_LOTE) == B38->(B38_CODOPE+B38_LOTE)
Else
	Store COLS Blank "B39" TO aColsB39 FROM aHeaderB39
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define dialogo...                                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1,  1, .T., .T., .F. } )
AAdd( aObjects, { 1, 120, .T., .F., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Enchoice...                                                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
oEnc := B38->(MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.))

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Getdados...                                                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
oGetB39 := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil  ,oDlg,nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeaderB39,aColsB39,.F.,"B39",nOpc,STR0005,nil,nil,nil,aVetTrab,,,,{|a,b,c| PLSA108COR(a,b,c,0) })	//"Itens do Lote"

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Ativa o dialogo...                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},.F.,{}) Center

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Fim da Rotina...                                                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪穆哪哪穆哪哪哪哪哪勘�
北矲uncao	 � PLSA108INC � Autor 砇egiane Rocha Barreira� Data�22.01.2007潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪牧哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Inclusao 	                                              潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PLSA108INC(cAlias,nReg,nOpc)

Local I__f 		:= 0
Local oDlg
Local oEnc
Local aRet   
Local nOpca
Local cSQL		:= ""
Local bOK		:= {|| nOpca := 1, oDlg:End() }
Local bCancel	:= {|| nOpca := 0, oDlg:End() }
Local _nH
LOCAL nX		:= 0
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
LOCAL aCabBE4 	:= {}
LOCAL aDadBE4 	:= {}
LOCAL aStruBE4	:= BE4->(dbStruct())

PRIVATE oLista

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Abre semaforo...                                                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁			
_nH := PLSAbreSem("PLSA108.SMF",.F.)

If _nH == 0
	msgalert(STR0006) //"Rotina em uso por outro usuario. Tente novamente."
	Return()
Endif    

TCREFRESH(RetSqlName("B38"))

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define dialogo...                                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Enchoice...                                                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Copy cAlias To Memory Blank
oEnc := B38->(MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.))

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Ativa o dialogo...                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,{}) Center

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Inclui movimento...                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If nOpca = K_OK

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Inicio da transacao...                                                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	BEGIN TRANSACTION
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Carrega tabela BE4														 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	Store Header "BEA" TO aCabBE4 For (SX3->X3_CAMPO $ "BEA_OPEPEG,BEA_CODLDP,BEA_CODPEG,BEA_NUMGUI")
	
	cSQL := " SELECT BEA.BEA_OPEPEG, BEA.BEA_CODLDP, BEA.BEA_CODPEG, BEA.BEA_NUMGUI, BE4.R_E_C_N_O_ AS BE4RECNO"
	cSQL += " FROM " + RetSQLName("BEA") + " BEA, " + RetSQLName("BE4") + " BE4 "
	cSQL += " WHERE BEA.BEA_FILIAL = '" + xFilial("BEA") + "' AND "
	cSQL += " 		BEA.BEA_OPEPEG = '" + M->B38_CODOPE + "' AND "
	cSQL += " 		BEA.BEA_CODEMP BETWEEN '" + M->B38_EMPDE + "' AND '"+  M->B38_EMPATE +"' AND "
	cSQL += " 		BEA.BEA_CODRDA BETWEEN '" + M->B38_RDADE + "' AND '"+  M->B38_RDAATE +"' AND "
	cSQL += " 		BEA.BEA_DATPRO BETWEEN '" + DTOS(M->B38_INTDE) + "' AND '"+ DTOS(M->B38_INTATE) +"' AND "
	cSQL += " 		BEA.D_E_L_E_T_ = ' ' AND "
		
	cSQL += " 		BE4.BE4_FILIAL = '" + xFilial("BE4") + "' AND "		
	cSQL += " 		BE4.BE4_CODOPE = BEA.BEA_OPEPEG AND "
	cSQL += "		BE4.BE4_CODLDP = BEA.BEA_CODLDP AND "
	cSQL += "		BE4.BE4_CODPEG = BEA.BEA_CODPEG AND "
	cSQL += "		BE4.BE4_NUMERO = BEA.BEA_NUMGUI AND "
	cSQL += " 		BE4.BE4_DTALTA = '" + Space(8) + "' AND "
	cSQL += " 		BE4.D_E_L_E_T_ = ' ' "

 	PLSQuery(cSQL,"TrbBE4")

	TrbBE4->(DbGoTop())
	
	While ! TrbBE4->(Eof())
		Aadd(aDadBE4,Array(Len(aCabBE4)+2))
			
		For nX := 1 To (Len(aCabBE4)+ 1)
			If nX = (Len(aCabBE4)+ 1)
				aDadBE4[Len(aDadBE4)][nX] :=TrbBE4->BE4RECNO
			Else				
				If ( aCabBE4[nX,10] !=  "V" )
					aDadBE4[Len(aDadBE4)][nX] := TrbBE4->(FieldGet(FieldPos(aCabBE4[nX,2])))
				Else
					aDadBE4[Len(aDadBE4)][nX] := CriaVar(aCabBE4[nX,2],.T.)
				EndIf
			EndIf
		Next nX
		aDadBE4[Len(aDadBE4)][Len(aCabBE4)+2] := .F.
			
		TrbBE4->(DbSkip())
	EndDo

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Fecha Temporario... 						                        �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	TrbBE4->(DbCloseArea())

	If Len(aDadBE4) > 0
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� MarkBrowse do BE4 - Interna珲es											 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		MarkBBE4(aDadBE4,aCabBE4,020,020,oDlg,oLista,040,020,280,100)
	Else
	    msgalert(STR0007) //"N鉶 existem intern珲es dentro dos parametros informados."
	EndIf

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//矲im da transacao...                                                       �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	END TRANSACTION    
Endif

TCREFRESH(RetSqlName("B38"))

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fecha semaforo...                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
PLSFechaSem(_nH,"PLSA108.SMF")

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Fim da Rotina...                                                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪穆哪哪穆哪哪哪哪哪勘�
北矲uncao    � MarkBBE4   � Autor 砇egiane Rocha Barreira� Data�23.01.2007潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪牧哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Cria um markbrowse dinamicamente                           潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function MarkBBE4(aLinha,aCabecalho,nCheLi,nCheCo,oDlg,oLista,nPosLI,nPosCI,nPosCF,nPosLF)

	Static objCENFUNLGP := CENFUNLGP():New()

LOCAL nFor
LOCAL bBlock
LOCAL nOpca    	:= 0
LOCAL bOK      	:= { || nOpca := 1, oDlg:End() }
LOCAL bCancel  	:= { || nOpca := 0, oDlg:End() }
LOCAL lCheck 	:= .T. 
LOCAL oCheck
LOCAL aButtons	:= {}
LOCAL aDadRDA	:= {}
LOCAL aDadUsr	:= {}
LOCAL cRegAte	:= ""
LOCAL aRetFun	:= {}
LOCAL aDadBEA	:= {}
LOCAL aHisCri	:= {}
LOCAL nY		:= 0
LOCAL nZ		:= 0
LOCAL cStatus	:= ""
LOCAL nSeq		:= 0
LOCAL cLPEGG	:= ""
LOCAL aHeaderBQV:= {}
LOCAL aColsBQV  := {}
LOCAL nInterna	:= 0
LOCAL aCampos	:= {}

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define dialogo...                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
DEFINE MSDIALOG oDlg TITLE STR0008 FROM 030,020 TO 050,100 OF GetWndDefault() //"Interna珲es"

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Checkbox para marcar e desmarcar todos														�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	@ nCheLi,nCheCo CHECKBOX oCheck VAR lCheck PROMPT STR0009 OF oDlg SIZE 100,8 //"Marca e Desmarca todos"
	oCheck:bChange := {|| MsAguarde( {|| MarcaLinha('',aLinha,lCheck),oLista:Refresh() } ) }   

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Monta o TcBrowse																			�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oLista := TcBrowse():New( nPosLI,nPosCI,nPosCF,nPosLF,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Adiciona o BitMap de marcado e desmarcado													�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	add COLUMN To oLista BitMap Data { || LoadBitMap( GetResources(), Iif(!aLinha[oLista:nAt,Len(aLinha[oLista:nAt])] ,EVal({|| lCheck := .F.,"LBNO"}),"LBOK" ) )} Title "" WIDTH 015 NOHILITE
	aadd(aCampos , .F.)
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Carrega o cabecalho																			�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	For nFor := 1 to Len(aCabecalho)
	     bBlock := "{ || aLinha[oLista:nAt, "+Str(nFor,4)+"] }"
	     bBlock := &bBlock
		 aadd(aCampos , aCabecalho[nFor,2])
	     oLista:AddColumn(TcColumn():New(aCabecalho[nFor,1],bBlock,aCabecalho[nFor,3],Nil,Nil,Nil,IiF(Len(aCabecalho[nFor,1]) > aCabecalho[nFor,4],Len(aCabecalho[nFor,1])*3.6,aCabecalho[nFor,4]*3.6),.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	Next

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oLista:aObfuscatedCols := aBls
	endif


	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Carrega os dados																			�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oLista:SetArray(aLinha)   

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Duploclick na linha																			�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
    oLista:BLDBLCLICK := { || MarcaLinha(oLista:nAt,aLinha,lCheck) , oLista:Refresh() }

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta botoes da enchoicebar...                                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	aadd(aButtons,{"RELATORIO",{|| PLSVisAut(oLista:nAt,aLinha) },STR0011,STR0011} )

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Ativa a dialogo...                                                       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁 
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons) CENTER

If nOpca = K_OK
	
	For nFor := 1 to Len(aLinha)	
		If aLinha[nFor,(Len(aCabecalho)+2)]	//LINHA MARCADA
			nInterna += 1
		EndIf
	Next nFor

	If nInterna > 0	//Internacao selecionada
	
		If MsgYesNo(Str(nInterna) + "  " + STR0010)		//"Interna珲es ser鉶 prorrogadas. Confirma?"
			
			For nFor := 1 to Len(aLinha)
				
				If aLinha[nFor,(Len(aCabecalho)+2)]	//LINHA MARCADA
					BE4->(dbGoTo(aLinha[nFor,5]))
					
					aDadRDA := PLSDADRDA(BE4->BE4_OPERDA,BE4->BE4_CODRDA,"1",dDataBase,BE4->BE4_CODLOC,BE4->BE4_CODESP,M->B38_CODPAD,M->B38_CODPRO)
					
					aDadUsr := PLSDADUSR(BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO),"1",.T.,dDataBase,nil,nil,BE4->BE4_VIACAR)
					
					cRegAte := IIF(PLSUSRINTE(aDadUsr[2],dDataBase,Subs(StrTran(Time(),":",""),1,4))[1],"1","2")
					
					aRetFun := PLSAUTP(dDataBase,;
								Subs(StrTran(Time(),":",""),1,4),;
								M->B38_CODPAD,;
								M->B38_CODPRO,;
								M->B38_QTDPRO,;
								aDadUsr,;
								0,;
								aDadRDA,;
								"1",;
								IIf(GetNewPar("MV_PLSMODA","1")=="0",.F.,.T.),;
								BE4->BE4_CID,;
								.T.,;
								"1",;
								.T.,;
								BE4->BE4_OPESOL,;
								BE4->BE4_CDPFSO,;
								BE4->BE4_ANOPAG,;
								BE4->BE4_MESPAG,;
								BE4->BE4_PADINT,;
								BE4->BE4_PADCON,;
								cRegAte,;
								.T.,;
								"",;
								"",;
								0,;
								nil,;
								NIL,;
								"0",;
								BE4->BE4_NRAOPE,;
								BE4->BE4_NRAEMP,;
								"",;
								nil,;
								nil,;
								"1",;
								"",;
								NIL,;
								NIL,;
								"",;
								"",;
								NIL,;
								"",;
								"")
					
					cLPEGG := aLinha[nFor,PLRETPOS("BEA_OPEPEG",aCabecalho)]+aLinha[nFor,PLRETPOS("BEA_CODLDP",aCabecalho)]+aLinha[nFor,PLRETPOS("BEA_CODPEG",aCabecalho)]+aLinha[nFor,PLRETPOS("BEA_NUMGUI",aCabecalho)]
					
					If aRetFun[1]
						cStatus := "1"	//Prorrogada
	
						//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
						//� Monta aHeader e aCols																		�
						//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
						Store Header "BQV" TO aHeaderBQV For .T.
	
						Aadd(aColsBQV,Array(Len(aHeaderBQV)))
						For nZ := 1 TO Len(aHeaderBQV)
							If aHeaderBQV[nZ,8] = "C"
								aColsBQV[Len(aColsBQV)][nZ] := ""
							ElseIf aHeaderBQV[nZ,8] = "N"
								aColsBQV[Len(aColsBQV)][nZ] := 0
							Else
								aColsBQV[Len(aColsBQV)][nZ] := CTOD("  /  /  ")
							EndIf
						Next nZ
						
						aColsBQV[1,GdFieldPos("BQV_CODPRO",aHeaderBQV)] := M->B38_CODPRO
						aColsBQV[1,GdFieldPos("BQV_CODPAD",aHeaderBQV)] := M->B38_CODPAD
						aColsBQV[1,GdFieldPos("BQV_QTDPRO",aHeaderBQV)] := M->B38_QTDPRO
						aColsBQV[1,GdFieldPos("BQV_TIPDIA",aHeaderBQV)] := "1"
						
						//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
						//� Monta o aDadBEA																				�
						//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
						BEA->(dbSetOrder(12))
						BEA->(DbSeek(xFilial("BEA")+cLPEGG))
						
						aadd(aDadBEA,{"BEA_ORIMOV",BEA->BEA_ORIMOV})
						aadd(aDadBEA,{"BEA_TIPO"  ,BEA->BEA_TIPO})
						aadd(aDadBEA,{"BEA_OPERDA",BEA->BEA_OPERDA})
						aadd(aDadBEA,{"BEA_CID   ",BEA->BEA_CID})
						aadd(aDadBEA,{"BEA_DESCID",BEA->BEA_DESCID})
						aadd(aDadBEA,{"BEA_DATPRO",BEA->BEA_DATPRO})
						aadd(aDadBEA,{"BEA_HORPRO",BEA->BEA_HORPRO})
						aadd(aDadBEA,{"BEA_CDPFSO",BEA->BEA_CDPFSO})
						aadd(aDadBEA,{"BEA_ANOPAG",BEA->BEA_ANOPAG})
						aadd(aDadBEA,{"BEA_MESPAG",BEA->BEA_MESPAG})
						aadd(aDadBEA,{"BEA_NUMIMP",BEA->BEA_NUMIMP})
						aadd(aDadBEA,{"BEA_MATANT",BEA->BEA_MATANT})
						aadd(aDadBEA,{"BEA_MATUSA",BEA->BEA_MATUSA})
						aadd(aDadBEA,{"BEA_PACOTE",BEA->BEA_PACOTE})
						aadd(aDadBEA,{"BEA_VLRPAC",BEA->BEA_VLRPAC})
						aadd(aDadBEA,{"BEA_GUIORI",BEA->BEA_GUIORI})
						aadd(aDadBEA,{"BEA_MSG01" ,BEA->BEA_MSG01})
						aadd(aDadBEA,{"BEA_MSG02" ,BEA->BEA_MSG02})
						aadd(aDadBEA,{"BEA_MSG03" ,BEA->BEA_MSG03})
						aadd(aDadBEA,{"BEA_GUIACO",BEA->BEA_GUIACO})
						aadd(aDadBEA,{"BEA_TIPPRE",BEA->BEA_TIPPRE})
						aadd(aDadBEA,{"BEA_QUACOB",BEA->BEA_QUACOB})
						aadd(aDadBEA,{"BEA_PAGATO",BEA->BEA_PAGATO})
						aadd(aDadBEA,{"BEA_CODCLI",BEA->BEA_CODCLI})
						aadd(aDadBEA,{"BEA_LOJA  ",BEA->BEA_LOJA  })
						aadd(aDadBEA,{"BEA_VALOR ",BEA->BEA_VALOR })
						aadd(aDadBEA,{"BEA_HHDIGI",BEA->BEA_HHDIGI})
						aadd(aDadBEA,{"BEA_DTDIGI",BEA->BEA_DTDIGI})
						aadd(aDadBEA,{"BEA_USUOPE",BEA->BEA_USUOPE})
						aadd(aDadBEA,{"BEA_DESOPE",BEA->BEA_DESOPE})
						aadd(aDadBEA,{"BEA_NUMATE",BEA->BEA_NUMATE})
						//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
						//� Rede de Atendimento...                                                   �
						//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
						aadd(aDadBEA,{"BEA_CODRDA",BEA->BEA_CODRDA})
						aadd(aDadBEA,{"BEA_NOMRDA",BEA->BEA_NOMRDA})
						aadd(aDadBEA,{"BEA_SIGLA" ,BEA->BEA_SIGLA})
						aadd(aDadBEA,{"BEA_ESTSOL",BEA->BEA_ESTSOL})
						aadd(aDadBEA,{"BEA_REGSOL",BEA->BEA_REGSOL})
						aadd(aDadBEA,{"BEA_NOMSOL",BEA->BEA_NOMSOL})
						aadd(aDadBEA,{"BEA_ESTEXE",BEA->BEA_ESTEXE})
						aadd(aDadBEA,{"BEA_REGEXE",BEA->BEA_REGEXE})
						aadd(aDadBEA,{"BEA_NOMEXE",BEA->BEA_NOMEXE})
						aadd(aDadBEA,{"BEA_SIGEXE",BEA->BEA_SIGEXE})
						//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
						//� Local de Atendimento...                                                  �
						//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
						aadd(aDadBEA,{"BEA_CODLOC",BEA->BEA_CODLOC})
						aadd(aDadBEA,{"BEA_LOCAL ",BEA->BEA_CODLOC})
						aadd(aDadBEA,{"BEA_DESLOC",BEA->BEA_DESLOC})
						aadd(aDadBEA,{"BEA_ENDLOC",BEA->BEA_ENDLOC})
						//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
						//� Especialidade...                                                         �
						//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
						aadd(aDadBEA,{"BEA_CODESP",BEA->BEA_CODESP})
						aadd(aDadBEA,{"BEA_DESESP",BEA->BEA_DESESP})
						//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
						//� Usuario...                                                               �
						//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
						aadd(aDadBEA,{"BEA_OPEUSR",BEA->BEA_OPEUSR})
						aadd(aDadBEA,{"BEA_CODEMP",BEA->BEA_CODEMP})
						aadd(aDadBEA,{"BEA_MATRIC",BEA->BEA_MATRIC})
						aadd(aDadBEA,{"BEA_TIPREG",BEA->BEA_TIPREG})
						aadd(aDadBEA,{"BEA_MATVID",BEA->BEA_MATVID})
						aadd(aDadBEA,{"BEA_NOMUSR",BEA->BEA_NOMUSR})
						aadd(aDadBEA,{"BEA_NOMTIT",BEA->BEA_NOMTIT})
						aadd(aDadBEA,{"BEA_CONEMP",BEA->BEA_CONEMP})
						aadd(aDadBEA,{"BEA_VERCON",BEA->BEA_VERCON})
						aadd(aDadBEA,{"BEA_SUBCON",BEA->BEA_SUBCON})
						aadd(aDadBEA,{"BEA_VERSUB",BEA->BEA_VERSUB})
						aadd(aDadBEA,{"BEA_CPFUSR",BEA->BEA_CPFUSR})
						aadd(aDadBEA,{"BEA_IDUSR",BEA->BEA_IDUSR})
						aadd(aDadBEA,{"BEA_DATNAS",BEA->BEA_DATNAS})
						aadd(aDadBEA,{"BEA_DIGITO",BEA->BEA_DIGITO})
						
						//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
						//� Grava BQV/BD6/BD7																		    �
						//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
						PLSAGRVEVO(PlsPtuGet("BEA_NRTROL",aDadBEA),aColsBQV,aHeaderBQV,{},{},PlsPtuGet("BEA_MSG03",aDadBEA),.F.)
	
						aHeaderBQV:= {}
						aColsBQV  := {}
						aDadBEA	  := {}
					Else
						cStatus := "0"	//Nao prorrogada
						
						//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
						//� Monta matriz com as criticas...			                            �
						//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
						AaDd(aHisCri,{cLPEGG,aRetFun[2][1][1],aRetFun[2][1][2]})	//"Local/PEG/Guia"###"Cod. Cri"###"Des. Cri"
						
						For nY := 2 To Len(aRetFun[2])
							AaDd(aHisCri,{"",aRetFun[2][nY][1],aRetFun[2][nY][2]+aRetFun[2][nY][3]})
						Next nY
					EndIf
					
					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					//� Grava Itens do Lote de Prorrogacao de Diarias B39...                �
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					nSeq ++
					B39->(RecLock("B39",.T.))
					B39->B39_FILIAL	:= xFilial("B39")
					B39->B39_CODOPE	:= M->B38_CODOPE
					B39->B39_LOTE	:= M->B38_LOTE
					B39->B39_SEQ	:= StrZero(nSeq,4)
					B39->B39_CODLDP	:= aLinha[nFor,PLRETPOS("BEA_CODLDP",aCabecalho)]
					B39->B39_CODPEG	:= aLinha[nFor,PLRETPOS("BEA_CODPEG",aCabecalho)]
					B39->B39_NUMERO	:= aLinha[nFor,PLRETPOS("BEA_NUMGUI",aCabecalho)]
					B39->B39_STATUS	:= cStatus
					B39->(MsUnLock())
				EndIf
			Next nFor
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Grava Lote de Prorrogacao de Diarias B38...                         �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			B38->(RecLock("B38",.T.))
			B38->B38_FILIAL	:= xFilial("B38")
			B38->B38_CODOPE	:= M->B38_CODOPE
			B38->B38_LOTE	:= GetSx8Num("B38","B38_LOTE")	//M->B38_LOTE
			B38->B38_DATGER	:= dDataBase
			B38->B38_HORA	:= Time()
			B38->B38_USUOPE	:= M->B38_USUOPE
			B38->B38_EMPDE	:= M->B38_EMPDE
			B38->B38_EMPATE	:= M->B38_EMPATE
			B38->B38_RDADE	:= M->B38_RDADE
			B38->B38_RDAATE	:= M->B38_RDAATE
			B38->B38_INTDE	:= M->B38_INTDE
			B38->B38_INTATE	:= M->B38_INTATE
			B38->B38_CODPAD	:= M->B38_CODPAD
			B38->B38_CODPRO	:= M->B38_CODPRO
			B38->B38_QTDPRO	:= M->B38_QTDPRO
			B38->(MsUnLock())
			
			B38->(ConfirmSX8())
	
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Exibe as criticas													     �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			If Len(aHisCri) > 0
				PLSCRIGEN(aHisCri,{ {STR0012,"@C",20},{STR0013,"@C",160},{STR0014,"@C",100} },STR0015)	//"Local/PEG/Guia"###"Cod. Cri"###"Des. Cri"###"Criticas"
			EndIf
		Else
			RollBackSX8()
		EndIf
	Else
		msgalert(STR0016) //"Nenhuma interna玢o foi selecionada."
	EndIf
EndIf

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪穆哪哪穆哪哪哪哪哪勘�
北矲uncao    � MarkBBE4   � Autor 砇egiane Rocha Barreira� Data�23.01.2007潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪牧哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Cria um markbrowse dinamicamente                           潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PLSVisAut(nLinha, aLinha)

Local aArea := GetArea()

BEA->(dbSetOrder(12))
BEA->(DbSeek(xFilial("BEA")+aLinha[nLinha,1]+aLinha[nLinha,2]+aLinha[nLinha,3]+aLinha[nLinha,4]))

PLSA092Mov("BEA",BEA->(RECNO()), K_Visualizar)

RestArea(aArea)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina															 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砅LSA108COR� Autor � Regiane R. Barreira   � Data � 01.02.07 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Muda a cor de acordo com o status... 				      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function PLSA108Cor(nLinha,aHeaderB39,aColsB39)

LOCAL nPos := PLRETPOS("B39_IMGSTA",aHeaderB39,.F.)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Internacoes																 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If nPos > 0
   aColsB39[nLinha,nPos] := If(GdFieldPos("B39_STATUS",aHeaderB39)=="1","ENABLE","DISABLE")
Endif   
                           
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina															 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return