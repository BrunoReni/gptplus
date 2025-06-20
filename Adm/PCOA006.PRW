#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "PCOA006.Ch"

Function PCOA006 ()

Private VISUAL := .F.
Private INCLUI := .F.
Private ALTERA := .F.
Private DELETA := .F.

Private aRotina := {}
Private cTitulo := STR0001 //"Fases do Planejamento Or�ament�rio"
Private lIncEven:= .f.

aAdd( aRotina ,{STR0002,"AxPesqui" ,0,1}) //"Pesquisar"
aAdd( aRotina ,{STR0003,"PC06MANUT",0,2}) //"Visualizar"
aAdd( aRotina ,{STR0004,"PC06MANUT",0,3}) //"Incluir"
aAdd( aRotina ,{STR0005,"PC06MANUT",0,4}) //"Alterar"
aAdd( aRotina ,{STR0006,"PC06MANUT",0,5}) //"Excluir"

mBrowse(,,,,"AMG")

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PC06MANUT	� Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Manuten��es do Cadastro de fases de Planejamento				 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PC06MANUT( cAlias, nRec, nOpc ) 

Local aCoors	:= FWGetDialogSize( oMainWnd )
Local oFWLayer	:= FWLayer():new()
Local oButt1 	:= FWButtonBar():new()
Local oButt2 	:= FWButtonBar():new()

//Declaracoes para montagen da MsNewGetDados 
Local cArqQry  := "AMH"  
Local aNoFields:= {"AMH_CODFAS"}
Local cSeek  	:= ""
Local bWhile 	:= ""
Local bAfterCols:= {|aC,aH|TrataMemo(aC,aH)}
Local nOpcA		:= 0 
Local nCntFor
Local aRet

Private	nop		:= nopc 
Private 	oDlg

Private 	aHeader	:=	{} 
Private 	aCols		:=	{} 
Private 	n

Private 	cCadastro:= STR0007 //"Manutencao de Fases do Planejamento"
Private 	oNewGet
Private	oGetDados
Private 	oPanel1								// Enchoice dos dados do 	CADASTRO DAS FASES			(AMG)
Private 	oPanel3								// Enchoice dos dados do	CADASTRO DAS FASES x ACOES	(AMH) 

DEFINE MSDIALOG oDlg FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] TITLE cCadastro OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL 

//Popula aHeader e Acols da NewGetdados das FASE x ACOES
aHeader	:=	{} 
aCols		:=	{}

// Cria RegToMemory da Enchoice
If Alltrim(Str(nop)) == "3" 	
	RegToMemory("AMG", .T.)
	RegToMemory("AMH", .T.) 	
Else
	RegToMemory("AMG", .F.,,, FunName())
	RegToMemory("AMH", .F.,,, FunName())
EndIF

cSeek  := xFilial()+ M->AMG_COD
bWhile := {|| AMH->AMH_FILIAL+AMH->AMH_CODFAS }
FILLGETDADOS(nop,"AMH",1,cSeek,bWhile,/*{{bCond,bAction1,bAction2}}*/,aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,INCLUI==.T.,/*aHeaderAux*/,/*aColsAux*/,bAfterCols,/*bBeforeCols*/,/*bAfterHeader*/,"AMH")  

If nOpc == 3
	PopAcols()
Endif

//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o bot�o de fechar
oFWLayer:init(oDlg,.T.)
//Cria as colunas do Layer
oFWLayer:addCollumn('Col01',100,.F.)

//COLUNA 1 - JANELA 1 	- Enchoice - FASES
oFWLayer:addWindow('Col01','C1_Win01',STR0001,40,.T.,.T.,/*{|| ClickWin1() }*/,,/*{|| FocoWin1() }*/) // "Fases do Planejamento Or�ament�rio"
oPanel1:=oFWLayer:getWinPanel('Col01','C1_Win01')
oPanel1:FreeChildren()

oGetDados:=MsMget():New("AMG",nRec,nop,,,,,{ 0, 0, 50, 50 },,3,,,,oPanel1,,.t.)
M->AMG_MSG:= MSMM(AMG->AMG_CODMEM,TamSx3("AMG_MSG")[1])   
oGetDados:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT   

// BUTTONS
oButt1:Init(oPanel1, 015, 015, CONTROL_ALIGN_BOTTOM, .T. )
oButt1:addBtnImage( "PESQUISA.PNG", STR0008,	{|| PC06PesqFa() },, .T., CONTROL_ALIGN_LEFT) //"Pesquisa Fase"

//COLUNA 1 - JANELA 2   - NewGet - FASS x ACOES 
oFWLayer:addWindow('Col01','C1_Win02',STR0009,050,.T.,.F.,/*{|| ClickWin2() }*/,,/*{|| FocoWin2() }*/) //'Rela��o Fases X A��es'
oPanel3:=oFWLayer:getWinPanel('Col01','C1_Win02')
oPanel3:FreeChildren()

oNewGet:= MsNewGetDados():New(0,0,200,200,GD_INSERT+GD_UPDATE+GD_DELETE,"PC06LinhOk()","PC06Tudok()",/*inicpos*/,,/*freeze*/,50,/*fieldok*/,/*superdel*/,/*delok*/,oPanel3,aHeader,aCols)
oNewGet:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
oNewGet:oBrowse:bDelete := {|| VldLinDel()} 

// BUTTONS
oButt2:Init(oPanel3, 015, 015, CONTROL_ALIGN_BOTTOM, .T. )
oButt2:addBtnImage( "PESQUISA.PNG", STR0010,	{|| PC06PesACa()		},, .T., CONTROL_ALIGN_LEFT) // "Pesquisa A��o"
                     

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA:=1,If(PC06Tudok(),oDlg:End(),nOpca:=0)},{||nOpca:=0,RollBackSX8(),oDlg:End()})

If nOpcA == 1 .And. (nop == 3 .Or. nop == 4)	   //INCLUSAO E ALTERACAO 
   
	Begin Transaction
		GrvFases()
		EvalTrigger()
		ConfirmSX8()
	End Transaction
		
Elseif nOpcA == 1 .And. nop == 5		// EXCLUSAO

	aRet:=FunRetPadr (M->AMG_COD)	//Verifica se Fase e Padrao	
	If aRet[1]  
		MsgBox(STR0011) // "A Fase em quest�o � padr�o e n�o pode ser excluida."
		Return
	Endif 
  
	Begin Transaction
	
		If (Aviso(STR0012,STR0013 + Alltrim(AMG->AMG_DESCRI) + STR0014,{STR0015,STR0016})) == 1 	    //"Aten��o" // "Deseja realmente Excluir a Fase " // " do Planejamento?" //"Sim" //"N�o"
			For nCntFor := 1 To Len( oNewGet:aCOLS )   
				cCodEvt := GdFieldPos("AMH_CODEVT")		
			  	If	!GDDeleted( nCntFor,oNewGet:aHeader,oNewGet:aCOLS ) 				
					If AMH->(DbSeek(xFilial()+ M->AMG_COD + oNewGet:aCOLS[nCntFor,cCodEvt]))			
						AMH->(RecLock("AMH",.F.))
						AMH->(DbDelete())
						AMH->(MsUnlock())   	
				  Endif				
				EndIf	
			Next nCntFor		
			AMG->(RecLock("AMG",.F.))
			AMG->(DbDelete())
			AMG->(MsUnlock()) 		
		Endif  
		
	End Transaction
	  	
Endif

Return


Static Function PopAcols()
 
Local nCols	
Local nPosCe
Local nPosPe
Local aHeadAux := {}
Local nx

nCols	:= 1
nPosCe:= AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "AMH_CODEVT" })
nPosPe:= AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "AMH_PERMIT" }) 
nPosDe:= AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "AMH_DESC" }) 


AMI->(DbSetOrder(1))
AMI->(DbSeek(xFilial('AMI')))
While AMI->(!EOF())	
	aCOLS[nCOLS,nPosCe]:= AMI->AMI_CODEVT
	aCOLS[nCOLS,nPosDe]:= AMI->AMI_DESCRI
	aCOLS[nCOLS,nPosPe]:= "1"	
	aCOLS[nCOLS, Len(aHeader )+1 ] := .F.	
	TrataMemo(aCOLS,aHeader)
	AMI->(dbSkip())	
	nCols++
	If AMI->(!EOF())	
		AAdd(aCOLS, Array(Len(aHeader) + 1 ))
	Endif
EndDo   

Return 


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PC06LinhOk� Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida linhas dab GetDados das Fases							���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PC06LinhOk ()

Local lRet		:= .T.        
Local aArea		:= GetArea()

//-- Analisa se ha itens duplicados na GetDados. 
If!GDDeleted(oNewGet:nAt,oNewGet:aHeader,oNewGet:aCOLS) 
	lRet := MaCheckCols(oNewGet:aHeader,oNewGet:aCols,oNewGet:nAt)
EndIf    

RestArea(aArea)

Return lRet


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PC06Tudok � Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Manutencao das Fases											 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PC06Tudok () 

Local cMsg:= ""
Local nErro:= 0
Local cCodEvt 
Local cPermit
Local lRet:= .t.
Local	nRecAtu:= 0
Local nok

If !INCLUI .And. !ALTERA 
	Return .T.
Endif 

If Len(oNewGet:aCols) == 0
	Msgbox(STR0017) //"O Evento deve estar associado a no m�nimo uma a��o."
  	Return .f.
Endif

For nok:= 1 to Len(oNewGet:aCols)
	oNewGet:nAt:= nok
	If ! PC06LinhOk () 
		Return .f.
	Endif
Next

nRecAtu:= AMG->(Recno())

If Empty(M->AMG_COD)
	nErro++
	cMsg:= Strzero(nErro,2) + STR0018 + CRLF //" - O C�digo do Evento deve ser declarado."
	lRet:=.f.
Endif 

AMG->(dbSetOrder(1)) //Filial + Codigo
If AMG->(DbSeek(xFilial()+ M->AMG_COD)) .And. nRecAtu <> AMG->(Recno())
	nErro++
	cMsg+= Strzero(nErro,2) + STR0019 + CRLF //" - O C�digo do evento ja existe."
	lRet:=.f. 
Endif  

If Empty(M->AMG_DESCRI) 
	nErro++
	cMsg+= Strzero(nErro,2) + STR0020 + CRLF //" - O Evento deve ter uma descri��o."
	lRet:=.f.
Endif

AMG->(dbSetOrder(2)) //Filial + Descricao 
If AMG->(DbSeek(xFilial()+ Upper(M->AMG_DESCRI))) .And. nRecAtu <> AMG->(Recno())
	nErro++
	cMsg+= Strzero(nErro,2) + STR0021 + CRLF // " - A descri��o declarada para o evento ja existe."
	lRet:=.f. 
Endif

If Empty(M->AMG_CORBRW)
	nErro++
	cMsg+= Strzero(nErro,2) + STR0022 + CRLF //" - Declare uma cor para o evento."
	lRet:=.f.
Endif 
 		
cCodEvt := GdFieldPos("AMH_CODEVT")						
If Len(oNewGet:aCOLS ) == 1 .And. Empty(oNewGet:aCOLS[oNewGet:oBrowse:nAt,cCodEvt]) 		 
	nErro++
	cMsg+= Strzero(nErro,2) + STR0023 + CRLF // " - O Evento deve estar associado a no m�nimo uma a��o."
	lRet:=.f.
Endif

cPermit := GdFieldPos("AMH_PERMIT")						
If Len(oNewGet:aCOLS ) == 1 .And. Empty(oNewGet:aCOLS[oNewGet:oBrowse:nAt,cPermit]) 		 
	nErro++
	cMsg+= Strzero(nErro,2) + STR0024 + CRLF // " - O Campo Permite deve ser declarado na Grade Fase X A��es."
	lRet:=.f.
Endif 

cMemo := GdFieldPos("AMH_MSG")						
If oNewGet:aCOLS[oNewGet:oBrowse:nAt,cPermit] == "2" .And. Empty(oNewGet:aCOLS[oNewGet:oBrowse:nAt,cMemo]) .And. Empty(M->AMG_MSG)		 
	nErro++
	cMsg+= Strzero(nErro,2) + STR0025 + CRLF // " - Uma Mensagem de Aten��o � obrigat�ria quando A��o n�o permitida."
	lRet:=.f.
Endif

If !lRet
	MsgBox(cMsg)
Endif

AMG->(DbGoto(nRecAtu))

Return lRet


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �VldLinDel � Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Exclusao da Linha das Fases X Acoes						 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function VldLinDel () 

Local cCodEvt:= GdFieldPos("AMH_CODEVT")
Local aRet:= {}

If !INCLUI .And. !ALTERA
	Return
Endif

If !AMH->(DbSeek(xFilial()+ M->AMG_COD + oNewGet:aCOLS[oNewGet:nAt,cCodEvt]))
   Return
Endif

aRet:=FunRetPadr (M->AMG_COD,oNewGet:aCOLS[oNewGet:nAt,cCodEvt])	//Verifica se Fase e Acao e Padrao

If aRet[1] .And. aRet[2] 
	MsgBox(STR0026) // "A Rela��o Fase X Acao � padr�o e n�o pode ser excluida"
	Return .f.
Endif

If !MsgYesNo(STR0027 + oNewGet:aCOLS[oNewGet:nAt,cCodEvt]+ STR0028 + Alltrim(M->AMG_COD) ,STR0029) //"Confirma excluir a A��o: " //" da Fase " //"Exclus�o"
	Return .f.
Endif

//Deleta linha   
If AMH->(DbSeek(xFilial()+ M->AMG_COD + oNewGet:aCOLS[oNewGet:nAt,cCodEvt]))
	RecLock('AMH',.F.)
	AMH->(dbDelete())
	AMH->(MsUnLock())
EndIf
	
aDel(oNewGet:aCols,oNewGet:nAt)
aSize(oNewGet:aCols,Len(oNewGet:aCols)-1)																				
oNewGet:Refresh()
	
Return .t. 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �TrataMemo � Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Trata campos MEMO na criacao da ACOLS								 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function TrataMemo(aCol,aHead)

Local nLin:= Len(aCol)
Local nPMem:= aScan(aHead,{|x|AllTrim(x[2]) == "AMH_MSG"})

If nPMem > 0
	aCol[nLin][nPMem]:= MSMM(AMH->AMH_CODMEM,TamSx3("AMH_MSG")[1])
EndIf

Return .T.   

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOIncFase� Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Habilita a inclusao de Fase, solicitada pelo usuario.	    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function PCOIncFase()

If !INCLUI .And. !ALTERA
	Return
Endif

RegToMemory("AMH", .T.)

Aadd(oNewGet:aCols,Array(Len(oNewGet:aHeader)+1))
oNewGet:aCols[Len(oNewGet:aCols)][Len(oNewGet:aHeader)+1]:= .F.  

//Inicializa Cada Coluna do ACols da Nova linha 
aEval(oNewGet:aHeader,{ |x,y| oNewGet:aCols[Len(oNewGet:aCols)][y] := If( "_WT" $ x[2],Iif("REC"$x[2],0,"AMH"),	CriaVar(x[2],.T.) )})
																	
oNewGet:oBrowse:nAt:= Len(oNewGet:Acols) 
oNewGet:oBrowse:colpos:=1
oNewGet:oBrowse:Refresh(.t.)
oNewGet:oBrowse:SetFocus() 
n:=Len(oNewGet:Acols)  
Acols:= Aclone(oNewGet:Acols)

Return


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GrvFases	� Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Manuten��es do Cadastro de fases de Planejamento				���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function GrvFases() 

Local cCodEvt
Local nHdr		:= 0
Local nCntFor	:= 0
Local nCntFo1	:= 0    
Local nValNovo	:= 0
Local nValOri	:= 0 
Local lRet		:=.T.
  
//-- GRAVA FASE - Enchoice (MsMGet) 

If nop == 3 			//Inclusao 
	AMG->(RecLock("AMG",.t.)) 
	MSMM(,TamSx3("AMG_MSG")[1],,M->AMG_MSG,1,,, "AMG", "AMG_CODMEM" )
Elseif nop == 4		//Alteracao
	AMG->(RecLock("AMG",.f.))
	MSMM(AMG->AMG_CODMEM, TamSx3('AMG_MSG')[1],,M->AMG_MSG,1,,, "AMG", "AMG_CODMEM" )
Endif
			
aEval(AMG->(dbStruct()),{|aFieldName,nI|FieldPut(nI,If('FILIAL' $ aFieldName[1],xFilial("AMG"),M->&(aFieldName[1])))})					
AMG->(MsUnLock()) 
	
//-- GRAVA FASE X ACAO - MsNewGetDados  

DbSelectArea("AMH")
AMH->(DbSetOrder(1)) 

For nCntFor := 1 To Len( oNewGet:aCOLS )
   
	cCodEvt := GdFieldPos("AMH_CODEVT")
		
	If	!GDDeleted( nCntFor,oNewGet:aHeader,oNewGet:aCOLS ) 
	   
		nHdr:= aScan( aHeader, {|x| Trim( x[ 2 ] ) == "AMH_MSG"})
				
		If AMH->(DbSeek(xFilial()+ M->AMG_COD + oNewGet:aCOLS[nCntFor,cCodEvt]))
   		AMH->(RecLock("AMH",.F.))
   		MSMM(AMH->AMH_CODMEM, TamSx3('AMH_MSG')[1],,oNewGet:aCOLS[nCntFor,nHdr],1,,, "AMH", "AMH_CODMEM" )
		Else
			AMH->(RecLock("AMH",.T.))
			MSMM(,TamSx3("AMH_MSG")[1],,oNewGet:aCOLS[nCntFor,nHdr],1,,,"AMH","AMH_CODMEM" )
			AMH->AMH_CODFAS:= AMG->AMG_COD
		Endif	
 																		
		//Grava Campos que est�o na GetDados
		For nCntFo1 := 1 To Len(aHeader)                                 		
			If	aHeader[nCntFo1,10] != 'V'
				FieldPut(FieldPos(aHeader[nCntFo1,2]), oNewGet:aCols[nCntFor,nCntFo1]) 
			EndIf
		Next 
		
		AMH->AMH_CODFAS:= M->AMG_COD
		             
		AMH->(MsUnLock())
			
	EndIf
	
Next nCntFor

Return .T. 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PC6IniPad � Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a Descricao da ACAO no campo Virtual AMH_DES.			 ���
���			 � Utilizado no Inicializador Padrao do Campo, tabela AMH.		 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PC6IniPad () 

Local cDesc 

IF !INCLUI
	cDesc:= POSICIONE("AMI",1,AMH->AMH_FILIAL+AMH->AMH_CODEVT,"AMI_DESCRI") 
Else
	cDesc:= POSICIONE("AMI",1,M->AMH_FILIAL+M->AMH_CODEVT,"AMI_DESCRI")
Endif                                              

Return cDesc

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PCO6VldEdi� Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a edicao da coluna codigo do Evento(AMI) na manutencao���
���			 � do cadastro de FasesXEvento (AMH).			 						 ���
���			 � Utilizado no X3_WHEN do campo AMH_CODEVT.	 						 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PCO6VldEdi 

Return oNewGet:aCOLS[oNewGet:nAt,gdfieldpos("AMH_REC_WT")] == 0 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOEdiFase� Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se a Alteracao do campo e permitida considerando os ���
���			 � codigos padroes das FASES.						 						 ���
���			 � Utilizado no X3_WHEN do campo AMG_COD.								 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PCOEdiFase()

Local aRet
Local lRet:= .F.  

If ALTERA

	aRet:= FunRetPadr (M->AMG_COD)	//Verifica se Fase Padrao
	lRet:=aRet[1] 
	
	//Verifica se ja esta sendo utilizado para evento (Acao X Fase)	
	AMH->(DbSetOrder(1)) 
	If AMH->(DbSeek(xFilial()+ M->AMG_COD))
		lRet:=.T.
	Endif
	
Endif

Return lRet

 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PC06PesqFa� Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pesquisa especifica da Fase											 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PC06PesqFa ()

Local aNoFields:= {"AMH_CODFAS"}
Local cSeek  	:= ""
Local bWhile 	:= ""
Local bAfterCols:= {|aC,aH|TrataMemo(aC,aH)}

Local nReg:= AMG->(Recno())

DbSelectArea("AMG")
AxPesqui()

If nReg <> AMG->(Recno())
	//Atualiza Enchoice da Fase em quetao	
	oGetDados:Refresh()
	//Atualiza Acols da GetDados das Fases X Acoes		
	oNewGet:Acols:={}	 	
	RegToMemory("AMG", .F.,,, FunName())
	RegToMemory("AMH", .F.,,, FunName())
	M->AMG_MSG:= MSMM(AMG->AMG_CODMEM,TamSx3("AMG_MSG")[1])
	cSeek  := xFilial()+ M->AMG_COD
	bWhile := {|| AMH->AMH_FILIAL+AMH->AMH_CODFAS }
	aHeader	:=	{} 
	aCols		:=	{}
	FILLGETDADOS(nop,"AMH",1,cSeek,bWhile,/*{{bCond,bAction1,bAction2}}*/,aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,INCLUI==.T.,/*aHeaderAux*/,/*aColsAux*/,bAfterCols,/*bBeforeCols*/,/*bAfterHeader*/,"AMH")  
	oNewGet:Acols:= Aclone(aCols)
	oNewGet:oBrowse:Refresh()
Endif																		

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PC06PesAca� Autor � Luiz Enrique	        � Data � 22/07/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pesquisa especifica da Acao.											 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PC06PesACa ()

Local npos:= 0 

DbSelectArea("AMI")
AxPesqui()
    
If (npos:= Ascan(oNewGet:aCols, { |x| AllTrim(x[1]) == Alltrim(AMI->AMI_CODEVT)})) > 0
	oNewGet:oBrowse:nAt:= npos
	oNewGet:oBrowse:colpos:=3
	oNewGet:oBrowse:Refresh()
	oNewGet:oBrowse:SetFocus()
Else
	MsgBox(STR0030) //"A��o referida n�o se encontra relacionada a esta Fase."
Endif																	

Return 
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOManVldG� Autor � Luiz Enrique	        � Data � 02-08-2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Valida conforme a ACAO e a FASE, a manutencao de uma GetDados.���
���������������������������������������������������������������������������Ĵ�� 
���Parametro �nManu informa qual acao da GetDados: 1 = lInsert  2= lUpdate  ��� 
���			 �3 = lDelete													��� 
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PCOManVldG(nManu) 

Local lret:= .T.


Do Case 
	//Validacoes se a ACAO pode ser Executado em Relacao a Fase Atual.
	Case nManu == 1	// Validacao para Inclusao na NewGetDados
		lret: 	PCOvldFase("AMH",ALV->ALV_FASE,"0003",.f.)					// 0003 -> Ver Cadastro de ACAO (AMI)
	Case nManu == 2	// Validacao para Alteracao na NewGetDados
		lret:=	PCOvldFase("AMH",ALV->ALV_FASE,"0004",.f.)					// 0004 -> Ver Cadastro de ACAO (AMI)	
	Case nManu == 3	// Validacao para Exclusao na NewGetDados 
		lret:= 	PCOvldFase("AMH",ALV->ALV_FASE,"0005",.f.)					// 0005 -> Ver Cadastro de ACAO (AMI) 
EndCase


Return lret                            	

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PCO06Fase � Autor � Luiz Enrique	        � Data � 02-08-2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para Alteracao das Fases do Planejamento				���
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function PCO06Fase()

Local clFaseAnt:= ALV->ALV_FASE
Local clFase	:= clFaseAnt
Local clDescri	:= ""		
Local lOk		:= .F.	
Local alList	:= {}	
Local oGetF		:= Nil	
Local oSayNew	:= Nil	
Local olDlgF	:= Nil
Local olList	:= Nil
Local olColor	:= Nil
Local olColor2	:= Nil 
Local aButtons	:= {}
Local lPermit := FVldUs()

//Valida��o de Usu�rio para altera��o de fase - Kazoolo 08/09/2010
If !lPermit
	If clFaseAnt == "003"
		Aviso(STR0012,STR0031,{STR0032}) //"Aten��o !!!" //"N�o � possiveol alterar fase, a mesma encontra-se encerrada" //"Ok"
		Return()
	EndIf
EndIf

AMG->(dbSetOrder(1))
AMG->(DbSeek(xFilial()+ ALV->ALV_FASE))
clDescri	:= Alltrim(AMG->AMG_DESCRI)

AMH->(dbSetOrder(1))
AMI->(dbSetOrder(1))    

If AMH->(DbSeek(xFilial()+ ALV->ALV_FASE))
	While AMH->(!EOF()) .And. AMH->AMH_CODFAS == ALV->ALV_FASE
		AMI->(DbSeek(xFilial()+ AMH->AMH_CODEVT))
		olColor	:= FColor(AMH->AMH_PERMIT)
		olColor2	:= FColor(AMH->AMH_PERMIT)
		aadd(alList,{olColor,olColor2,AMI->AMI_CODEVT,AMI->AMI_DESCRI})
		AMH->(dbSkip())
	EndDo
Else
	Aviso(STR0012,STR0033,{STR0034},2,STR0035) //"Aten��o !!!" //"Fase n�o declarada no Planejamento." //"Voltar" //"Declara���o da Fase"	
	Return
EndIf

//Adiciona botoes na enchoicebar:
aadd(aButtons,{"PMSCOLOR",{||PCO6LegFas()}, STR0036}) //"Legenda"

DEFINE MSDIALOG olDlgF TITLE STR0001 + Alltrim(clDescri)+"."  OF oMainWnd PIXEL FROM 0,0 TO 400,500 

	@ 015,2 to 32,248  PIXEL  
	@ 018,008 Say STR0002  Size 055,008 COLOR CLR_BLACK PIXEL OF olDlgF
	@ 017,040 MsGet oGetF Var clFase Size 028,009  F3 'AMG' Valid Iif(clFase <> clFaseAnt,Iif(ExistCpo('AMG',clFase,1),FNewFase(@clFase,@clFaseAnt,@clDescri,@oSayNew,@alList,@olList),.F.),.T.) COLOR CLR_BLACK Picture "@!" PIXEL OF olDlgF HASBUTTON
	@ 020,075 Say oSayNew Var clDescri Size 200,008 COLOR CLR_HBLUE PIXEL OF olDlgF SHADOW
	
	@ 35,2 to 198,248  LABEL STR0003 PIXEL  
	olList := TWBrowse():New( 45,5,240,150,,{"  ","  ",STR0004,STR0005},{10,10,50,90},olDlgF,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) 
	olList:SetArray(alList)
	olList:bLine := {|| alList[olList:nAT] }
		
ACTIVATE MSDIALOG olDlgF ON INIT EnchoiceBar(olDlgF,{|| lOk:=.T.,olDlgF:End()},{|| lOk:=.F.,olDlgF:End()},,aButtons) CENTERED

//Altera a Fase
If lOk
	ALV->(RecLock("ALV",.f.))
	ALV->ALV_FASE:= AllTrim(clFase)
	ALV->(MsUnlock())
EndIf


Return()

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FColor		� Autor � Luiz Enrique	        � Data � 02-08-2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para atualizacao do array que contem o eventos conforme���
���			 �a altera��o da fase.				  									    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function FColor(clCor)
	
Local olCor	:= Nil

olCor:=	If(clCor == "1",LoadBitmap( GetResources(), "BR_VERDE" ),LoadBitmap( GetResources(), "BR_VERMELHO" ))
	
Return(olCor)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FNewFase	� Autor � Luiz Enrique	        � Data � 02-08-2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Altera cor da Legenda da Fase.										    ��� 
���������������������������������������������������������������������������Ĵ��
���Parametro �clFase     : Codigo da Atual.   									    ���  
���			 �clFaseAnt	 : Codigo da Fase Anterior.				  				 ���
���			 �clDescri	 : Descri��o da Fase.				  						 ���
���			 �oSayNew    : Objeto da descri��o da fase.				  			 ���
���			 �alList     : Array contendo os eventos.							    ���
���			 �olList     : Obejto dos eventos.									    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/   
Static Function FNewFase(clFase,clFaseAnt,clDescri,oSayNew,alList,olList)

Local nlI	:= 1
   
AMH->(dbSetOrder(1))
AMG->(dbSetOrder(1))
	
If AMH->(DbSeek(xFilial()+ clFase))
	While AMH->(!EOF()) .And. AMH->AMH_CODFAS == clFase
		alList[nlI][2]	:= FColor(AMH->AMH_PERMIT)
		nlI++
		AMH->(dbSkip())
	EndDo
EndIf

clFaseAnt:= clFase
	    
AMG->(DbSeek(xFilial()+ clFase))			
clDescri	:= Alltrim(AMG->AMG_DESCRI)

oSayNew:Refresh()
olList:Refresh()
    
Return() 

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PCO6LegFas� Autor � Luiz Enrique	        � Data � 02-08-2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Mostra legenda da permiss�o de Execucao da Acao na Fase.		 ���
���			 �a altera��o da fase.				  									    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPCO                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/

Function PCO6LegFas()

Local aLegenda	:= {	{ "BR_VERDE"	, "Permite Executar" },;
							{ "BR_VERMELHO", "N�o Permite Executar"}}

BrwLegenda(STR0037,STR0036,aLegenda) // "Execu��o da A��a na Fase"//"Legenda"

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FVldUs	�Autor  �Microsiga           � Data �  10/22/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica acesso de edi��o do projeto                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPCO                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FVldUs()
	Local lRet		:= .F.          
	Local alUser	:= Separa(GetMv("MV_PCOPRO",,"000000"),";")	
	If aScan(alUser,{|x| Alltrim(x) == __cUserId}) <> 0
		lRet := .T.
	EndIf
Return lRet  