#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'                              
#INCLUDE "PLSMGER.CH"

#define K_RetCP    3
#define K_RevCP    4
#define K_RetFas   6
#define K_RevPag   7
#define K_RetCob   8
#define K_AnaGlo   9

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSA499 � Autor � Totvs		          � Data � 11.12.2012 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Controle de protocolos em um Processo					  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
function PLSA499()        
LOCAL cAlias		:= "BRI"
LOCAL bAjustBrw		:= {|| oBrw := GetObjBrow()}

PRIVATE _cFiltro 	:= "@BRI_FILIAL = '"+xFilial("BRI")+"' and BRI_CODOPE = '"+PLSINTPAD()+"' and D_E_L_E_T_ = ' '"
PRIVATE aRotina  	:= menuDef()                        
PRIVATE cCadastro	:= "Processo agrupamento de PEG(s)"
//���������������������������������������������������������������������������
//� Filtro
//���������������������������������������������������������������������������
BRI->(dbSetOrder(1)) //BRI_FILIAL + BRI_CODINT + BRI_CODIGO
dbSelectArea("BRI")
SET FILTER TO &_cFiltro
//���������������������������������������������������������������������������
//� Browse
//���������������������������������������������������������������������������
BRI->(msSeek(xFilial(cAlias)))
BRI->(mBrowse(06,01,22,75,cAlias,,nil,nil,nil,4,,nil,nil,nil,bAjustBrw,.f.,nil) )
BRI->(dbClearFilter())
//���������������������������������������������������������������������������
//� Fim da Rotina
//���������������������������������������������������������������������������
return(nil)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �menuDef   � Autor � Totvs			        � Data �13.04.2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
static function menuDef()
LOCAL aRot := {}
Local aButtonUsr := {}
Local nI := 0
aadd(aRot,{ "Pesquisar" 			,'PLSA498PES("BCI",BCI->(recno()),0,.t.)'	, 0 ,	K_Pesquisar	 , 0, nil})
aadd(aRot,{ "Visualizar"			,'PLSA499VIS'								, 0 ,	K_Visualizar , 0, nil})
aadd(aRot,{ "Incluir"				,'PLSA499MOV'								, 0 ,	K_Incluir	 , 0, nil})
aadd(aRot,{ "Alterar"				,'PLSA499MOV'								, 0 ,	K_Alterar	 , 0, nil})
aadd(aRot,{ "Excluir"				,'PLSA499EXC'								, 0 ,	K_Excluir	 , 0, nil})
aadd(aRot,{ "Selecionar"			,'PLSA499SEL'								, 0 ,	0			 , 0, nil})
aadd(aRot,{ "Mudanca Fase"			,'PLSA499FAS'								, 0 ,	K_RetFas 	 , 0, nil})
aadd(aRot,{ "Retorno Fase"			,'PLSA499RGR'								, 0 ,	K_RetFas 	 , 0, nil})
aadd(aRot,{ "Revalor. Pagto"		,'PLSA499RGR'								, 0 ,	K_RevPag 	 , 0, nil})
aadd(aRot,{ "Revalor. Cobr."		,'PLSA499RGR'								, 0 ,	K_RetCob 	 , 0, nil})
aadd(aRot,{ "Rev.Cobr./Pagto"		,'PLSA499RGR'								, 0 ,	K_RetCP 	 , 0, nil})
aadd(aRot,{ "Status do Processo"	,'PLSA499STP("BRI",BRI->(recno()),0,.t.)'	, 0 ,	0 	 		 , 0, nil})
aadd(aRot,{ "Gerenciar Processo"	,'PLSA499RES'								, 0	,	0		 	 , 0, nil})
aadd(aRot,{ "Imp. Capa Processo"	,'PLSA499IMP'								, 0 ,	0 	 		 , 0, nil})

If ExistBlock("PL499BUT")
    
   	aButtonUsr := Execblock("PL499BUT",.F.,.F.)
	If ValType(aButtonUsr) == "A"
		For nI   := 1  To  Len(aButtonUsr)
			Aadd(aRot,aClone(aButtonUsr[nI]))
		Next nI
	EndIf
    
Endif

//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//��������������������������������������������������������������������������� 
return(aRot)                                
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSA499VIS � Autor � Totvs		      � Data � 13.04.2012 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizar                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
function PLSA499VIS(cAlias,nReg,nOpc)
(cAlias)->(axVisual(cAlias,nReg,nOpc))
return(nil)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSA499MOV � Autor � Totvs		      � Data � 17.04.2012 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclusao de peg											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
function PLSA499MOV(cAlias,nReg,nOpc)
LOCAL nOpcA         := 0

PRIVATE oDlg		:= nil
PRIVATE oEnchoice   := nil
PRIVATE bOK         := {|| nOpca := 1,iIf(obrigatorio(oEnchoice:aGets,oEnchoice:aTela),oDlg:End(),nOpca:=2),IIF(nOpca==1,oDlg:End(),.F.) }
PRIVATE bCancel  	:= {|| BRI->(rollBackSX8()),oDlg:end()}
PRIVATE aChave      := {}   
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
//���������������������������������������������������������������������������
//� tela
//���������������������������������������������������������������������������
aSize := MsAdvSize()

aObjects := {}       
aadd( aObjects, { 100, 200, .T., .T., .F. } )

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
//���������������������������������������������������������������������������
//� Inicia a construcao do Dialogo com usuario...                            
//���������������������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
//���������������������������������������������������������������������������
//� Monta M->????                                                            
//���������������������������������������������������������������������������
regToMemory(cAlias,nOpc==K_Incluir)  
//���������������������������������������������������������������������������
//� Monta Enchoice...                                                        
//���������������������������������������������������������������������������
oEnchoice := msMGET():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,.T.)
//���������������������������������������������������������������������������
//� Ativa o Dialogo...                                                       
//���������������������������������������������������������������������������
ACTIVATE MSDIALOG oDlg CENTERED ON INIT eval({|| enChoiceBar(oDlg,bOK,bCancel,.F.,{}) })
//���������������������������������������������������������������������������
//� Tratamento para atualizacoes...                                          
//���������������������������������������������������������������������������
if nOpcA == K_OK
	//���������������������������������������������������������������������������
	//� manutencao de dados
	//���������������������������������������������������������������������������
	if ( nOpc == K_Incluir .Or. nOpc == K_Alterar .Or. nOpc == K_Excluir )
	
		BRI->(confirmSx8())
		
		PLUPTENC("BRI",nOpc)
	endIf
endIf	
//���������������������������������������������������������������������������
//� FILTRO
//���������������������������������������������������������������������������
dbSelectArea("BRI")
SET FILTER TO &_cFiltro
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//��������������������������������������������������������������������������� 
return(nil)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSA499SEL � Autor � Totvs 		      � Data � 17.04.2012 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Recebe do mBrowse e chama a funcao correta...              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
function PLSA499SEL()
LOCAL aArea	:= BCI->(getArea())
//���������������������������������������������������������������������������
//� Verifica se e o operador de gerenciamento
//��������������������������������������������������������������������������� 
if !PLSVEROPE(.f.)
	return
endIf
//���������������������������������������������������������������������������
//� abre a BCI filtrada com este processo
//���������������������������������������������������������������������������
PLSA498(BRI->BRI_CODIGO)

BCI->(restArea(aArea))
//���������������������������������������������������������������������������
//� Fim da Rotina Principal...                                               
//���������������������������������������������������������������������������
return(nil)
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSA499STP� Autor � Totvs					� Data � 15/10/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Muda status do peg conforme status das guias				  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
function PLSA499STP(cAlias,nReg,nOpc,lMsg)  
LOCAL aArea	:= BCI->(getArea())
LOCAL cFase := "1"
Local nIndUt:= 0
Local nInd1 := 0
DEFAULT lMsg:= .t.
//���������������������������������������������������������������������������
//� Verifica se e o operador de gerenciamento
//��������������������������������������������������������������������������� 
if !PLSVEROPE(.f.)
	return
endIf
//���������������������������������������������������������������������������
//� verifica o status dos peg's do processo 1=Em digitacao;2=Em conferencia;3=Pronto;4=Faturada 
//��������������������������������������������������������������������������� 
//BCI->(dbSetOrder(13))//BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE
If nInd1 == 0
	nIndUt := PLSBUIND("BCI","BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE") /// Busca da Ordem do indice pela descri��o 
	nInd1 :=nIndUt
Endif
BCI->( DbSetOrder(nInd1) )//BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE

if !BCI->(msSeek(xFilial("BCI")+BRI->(BRI_CODOPE+BRI_CODIGO)+cFase))
	cFase := "2"
	if !BCI->(msSeek(xFilial("BCI")+BRI->(BRI_CODOPE+BRI_CODIGO)+cFase))
		cFase := "3"
		if !BCI->(msSeek(xFilial("BCI")+BRI->(BRI_CODOPE+BRI_CODIGO)+cFase))
			cFase := "4"
			if !BCI->(msSeek(xFilial("BCI")+BRI->(BRI_CODOPE+BRI_CODIGO)+cFase))
				cFase := "1"
			endIf
		endIf
	endIf
endif
//����������������������������������������������������������������������
//� Atualiza peg...
//����������������������������������������������������������������������
BRI->(recLock("BRI",.F.))
	BRI->BRI_FASE := cFase
BRI->(msUnLock())
//���������������������������������������������������������������������������
//� Alerta
//��������������������������������������������������������������������������� 
if lMsg
	msgAlert("Status atualizado!")
endIf	

BCI->(restArea(aArea))
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//��������������������������������������������������������������������������� 
return(nil)
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSA499FAS� Autor � Totvs					� Data � 15/10/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Muda fase dos peg's de um processo						  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
function PLSA499FAS(cAlias,nReg,nOpc)  
LOCAL aArea	:= BCI->(getArea()) 
LOCAL nIndUt:=	0
LOCAL nInd1	:= 0
//���������������������������������������������������������������������������
//� Verifica se e o operador de gerenciamento
//��������������������������������������������������������������������������� 
if !PLSVEROPE(.f.)
	return
endIf
//���������������������������������������������������������������������������
//� posiciona no peg
//��������������������������������������������������������������������������� 
//BCI->(dbSetOrder(13))//BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE
If nInd1 == 0
	nIndUt := PLSBUIND("BCI","BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE") /// Busca da Ordem do indice pela descri��o 
	nInd1  := nIndUt
Endif
BCI->( DbSetOrder(nInd1) )//BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE

if BCI->(msSeek(xFilial("BCI")+BRI->(BRI_CODOPE+BRI_CODIGO)))

	processa( {|| PLSMF(nOpc) }, "Processo", "Mudando fase...", .f.)
	
	msgAlert("Verifique o status de cada PEG para ver o resultado da mudan�a de fase.")
else
	aviso("Aten��o","N�o existe PEG para este PROCESSO",{"Ok"},1)
endIf	

BCI->(restArea(aArea))
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//��������������������������������������������������������������������������� 
return(nil)
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSMF     � Autor � Totvs					� Data � 15/10/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Executa mudanca de fase									  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
static function PLSMF(nOpc)  
LOCAL aProc := {}
LOCAL nCont := 1
//���������������������������������������������������������������������������
//� proc regua
//��������������������������������������������������������������������������� 
procRegua(recCount())
//���������������������������������������������������������������������������
//� muda fase
//��������������������������������������������������������������������������� 
dbSelectArea("BCI")
dbSetOrder(13)

if dbSeek(xFilial("BCI")+BRI->(BRI_CODOPE+BRI_CODIGO))
	while !BCI->(eof()) .AND. BCI->(BCI_FILIAL+BCI_CODOPE+BCI_PROCES) == BRI->(BRI_FILIAL+BRI_CODOPE+BRI_CODIGO)
		AaDd(aProc, BCI->(Recno()))
		BCI->(dbSkip())
	EndDo
EndIf

BCI->(dbGoTo(aProc[nCont]))

while !BCI->(eof()) .and. BCI->(BCI_FILIAL+BCI_PROCES) == xFilial("BCI")+BRI->BRI_CODIGO
	
	incProc("Mudando fase da PEG ["+BCI->BCI_CODPEG+"]")
	PLSA175FAS("BCI",BCI->(recno()),nOpc,"",.f.,/*aFiltro*/,/*lAutori*/,/*nTotEventos*/,/*aThreads*/,/*nCont*/,/*cNameUser*/,/*aPLS475*/)
	
	If nCont < len(aProc) 
		BCI->(dbGoTo(aProc[nCont+1]))
		nCont++
	Else
		EXIT
	EndIf
endDo     
//���������������������������������������������������������������������������
//� atualiza o status do processo
//��������������������������������������������������������������������������� 
PLSA499STP(,,,.f.)                  
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//��������������������������������������������������������������������������� 
return(nil)
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSA499RGR� Autor � Totvs					� Data � 15/10/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Retorna fase dos peg's de um processo					  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
function PLSA499RGR(cAlias,nReg,nOpc)  
LOCAL aArea	:= BCI->(getArea())
LOCAL cMsg	:= ""
LOCAL nIndUt:=	0
LOCAL nInd1 := 0
//���������������������������������������������������������������������������
//� Verifica se e o operador de gerenciamento
//��������������������������������������������������������������������������� 
if !PLSVEROPE(.f.)
	return
endIf
//���������������������������������������������������������������������������
//� posiciona no peg
//��������������������������������������������������������������������������� 
//BCI->(dbSetOrder(13))//BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE
If nInd1 == 0
	nIndUt := PLSBUIND("BCI","BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE") /// Busca da Ordem do indice pela descri��o 
	nInd1  := nIndUt
Endif

BCI->( DbSetOrder(nInd1) )//BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE

if BCI->(msSeek(xFilial("BCI")+BRI->(BRI_CODOPE+BRI_CODIGO)))

	if PLSRETROT(nOpc) == K_RetFas
		cMsg := "Retorna fase"
	elseIf PLSRETROT(nOpc) == K_RevPag
		cMsg := "Revaloriza pagamento"
	elseIf PLSRETROT(nOpc) == K_RetCob
		cMsg := "Revaloriza cobran�a"
	elseIf PLSRETROT(nOpc) == K_RevCP .or. PLSRETROT(nOpc) == K_RetCP
		cMsg := "Revaloriza cobran�a/pagamento"
	endif       
	//���������������������������������������������������������������������������
	//� processa
	//��������������������������������������������������������������������������� 
	processa( {|| PLSRFCP(nOpc,cMsg) }, "Processo", cMsg+"...", .f.)
	//���������������������������������������������������������������������������
	//� mensagem 
	//��������������������������������������������������������������������������� 
	if PLSRETROT(nOpc) == K_RetFas
		//���������������������������������������������������������������������������
		//� atualiza o status do processo
		//��������������������������������������������������������������������������� 
		PLSA499STP(,,,.f.)                  
		
		msgAlert("Retorno de fase realizado com sucesso")
	elseIf PLSRETROT(nOpc) == K_RevPag
		msgAlert("Revaloriza��o de pagamento realizado com sucesso")
	elseIf PLSRETROT(nOpc) == K_RetCob
		msgAlert("Revaloriza��o de cobran�a realizado com sucesso")
	elseIf PLSRETROT(nOpc) == K_RevCP .or. PLSRETROT(nOpc) == K_RetCP
		msgAlert("Revaloriza��o de cobran�a/pagamento realizado com sucesso")
	endif       
else
	aviso("Aten��o","N�o existe PEG para este PROCESSO",{"Ok"},1)
endIf	

BCI->(restArea(aArea))
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//��������������������������������������������������������������������������� 
return(nil)
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSRFCP   � Autor � Totvs					� Data � 15/10/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Executa retorno de fase e revalorizacao pag e cob		  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
static function PLSRFCP(nOpc,cMsg)  
//���������������������������������������������������������������������������
//� proc regua
//��������������������������������������������������������������������������� 
procRegua(recCount())
//���������������������������������������������������������������������������
//� retorna fase, revaloriza pagamento, cobranca
//��������������������������������������������������������������������������� 
while !BCI->(eof()) .and. BCI->(BCI_FILIAL+BCI_PROCES) == xFilial("BCI")+BRI->BRI_CODIGO
	
	incProc(cMsg + " do PEG ["+BCI->BCI_CODPEG+"]")
	
	PLSA175RGR("BCI",BCI->(recno()),nOpc,"",.f.,/*aFiltro*/,/*nTotEventos*/,/*aThreads*/,/*nCont*/,/*cOriMov*/,/*cNameUsr*/,/*cTipo*/,/*nDifUs*/,/*nVlrDifUs*/,/*aPLS475*/)

BCI->(dbSkip())
endDo
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//��������������������������������������������������������������������������� 
return(nil)
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSA499VIN� Autor � Totvs					� Data � 15/10/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Vincular peg's a um protocolo							  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
function PLSA499VIN()  
LOCAL aAreaBCI	:= BCI->(getArea())
LOCAL aAreaBRI	:= BRI->(getArea())
LOCAL cFase		:= '4'
LOCAL cCodOpe 	:= BRI->BRI_OPERES
LOCAL cProcesso	:= BRI->BRI_CODIGO
LOCAL nQtdPEG	:= 0
LOCAL nVlrApr 	:= 0
LOCAL nI		:= 0
LOCAL nPos		:= 0
LOCAL nPosRec	:= 0
LOCAL nPosFase	:= 0
LOCAL nPosPro	:= 0
LOCAL nPosVlr	:= 0
LOCAL lOk		:= .f.
LOCAL lAtu		:= .f.
LOCAL aMatCol 	:= {}
LOCAL aMatLin 	:= {}
//���������������������������������������������������������������������������
//� Cabecalho
//��������������������������������������������������������������������������� 
aadd(aMatCol,{"Operadora"	,'@!',040,.f.} )
aadd(aMatCol,{"Local"		,'@!',040,.f.} )
aadd(aMatCol,{"PEG"			,'@!',050,.t.} )
aadd(aMatCol,{"Fase"		,'@!',050,.f.} )
aadd(aMatCol,{"Tot. Apr"	,'@!',070,.f.} )
aadd(aMatCol,{"Cod. Rda"	,'@!',040,.t.} )
aadd(aMatCol,{"Nome da Rda"	,'@!',200,.t.} )         
aadd(aMatCol,{"Respons�vel"	,'@!',070,.f.} )     
   
if P499Query(.t.)
	// monta matriz de linha
	while !EXPEGBCI->(eof())
	
        if (empty(EXPEGBCI->BCI_OPERES) .or. EXPEGBCI->BCI_OPERES == cCodOpe .or. FWIsAdmin()) 
			aadd(aMatLin,{EXPEGBCI->BCI_CODOPE, EXPEGBCI->BCI_CODLDP, EXPEGBCI->BCI_CODPEG, x3Combo("BCI_FASE",EXPEGBCI->BCI_FASE), allTrim(transform(EXPEGBCI->BCI_VLRGUI,'@E 99,999,999,999,999.99')),;
			     EXPEGBCI->BCI_CODRDA, EXPEGBCI->BCI_NOMRDA, usrRetName(BCI->BCI_OPERES), EXPEGBCI->BCI_PROCES, EXPEGBCI->BCI_FASE, EXPEGBCI->REC, iIf(EXPEGBCI->BCI_PROCES == cProcesso,.t.,.f.)})
		endIf	

		EXPEGBCI->(dbSkip())
	endDo
	//���������������������������������������������������������������������������
	//� Monta browse
	//��������������������������������������������������������������������������� 
	lOk := PLSSELOPT("Sele��o de PEG(s)","Marca e Desmarca todos",aMatLin,aMatCol,K_Incluir,.t.,.t.,.f.)
	//���������������������������������������������������������������������������
	//� se confimou
	//��������������������������������������������������������������������������� 
	if lOk .and. len(aMatLin)>0
		//���������������������������������������������������������������������������
		//� pega a posicao marca desmarca
		//��������������������������������������������������������������������������� 
		nPos 	:= len(aMatLin[1])         
		nPosRec := (nPos-1)
		nPosFase:= (nPos-2)
		nPosPro := (nPos-3)
		nPosVlr := (nPos-7)
		//���������������������������������������������������������������������������
		//� verifica quais foram selecionadas
		//��������������������������������������������������������������������������� 
		for nI:=1 to len(aMatLin)
			//���������������������������������������������������������������������������
			//� fase
			//��������������������������������������������������������������������������� 
			if aMatLin[nI,nPos]
				if val(aMatLin[nI,nPosFase]) < val(cFase)
					cFase := aMatLin[nI,nPosFase]
				endIf       
				//���������������������������������������������������������������������������
				//� Atualizo valor e quantidade da peg de acordo com os registros selecionados
				//��������������������������������������������������������������������������� 
				nQtdPEG++
				nVlrApr += val(StrTran(StrTran(aMatLin[nI,nPosVlr],".",""),",","."))
			endIf	
			//���������������������������������������������������������������������������
			//� coloca o processo no selecionado que ainda nao tem processo
			//��������������������������������������������������������������������������� 
			if aMatLin[nI,nPos] .and. empty(aMatLin[nI,nPosPro])
			
				lAtu := .t.
				
				BCI->(dbGoTo(aMatLin[nI,nPosRec]))
				if !BCI->(eof())
					BCI->(recLock("BCI",.f.))
						BCI->BCI_PROCES := cProcesso
						//���������������������������������������������������������������������������
						//� se for o administrador do sistema manipulando o processo ao selecionar
						//� qualquer peg o responsavel passa a ser o mesmo do processo.
						//��������������������������������������������������������������������������� 
						if FWIsAdmin()
							BCI->BCI_OPERES := BRI->BRI_OPERES
						endIf
						
					BCI->(msUnLock())
				endIf
			//���������������������������������������������������������������������������
			//� retira o processo para o desmarcado que tem processo
			//��������������������������������������������������������������������������� 
			elseIf !aMatLin[nI,nPos] .and. !empty(aMatLin[nI,nPosPro])
			
				lAtu := .t.
				
				BCI->(dbGoTo(aMatLin[nI,nPosRec]))
				if !BCI->(eof())
					BCI->(recLock("BCI",.f.))
						BCI->BCI_PROCES := ""
					BCI->(msUnLock())
				endIf
				
			endIf
		next
		//���������������������������������������������������������������������������
		//� atualiza processo
		//��������������������������������������������������������������������������� 
		if lAtu
			BRI->(recLock("BRI",.f.))
				BRI->BRI_QTDPEG := nQtdPEG
				BRI->BRI_VLRAPR := nVlrApr
				BRI->BRI_FASE   := If(nQtdPEG>0,cFase,'1')
			BRI->(msUnLock())
		endIf	
	endIf
else
	aviso("Aten��o","N�o existe PEG para esta rede de atendimento",{"Ok"},1)
endIf	                            

// Fecho a query BCI e atualiza o GRID de processo somente com as PEGs que foram selecionadas.
P499Query(.f.)
BCI->(dbSetOrder(13))
BCI->(dbSeek(xFilial("BCI")+BRI->BRI_CODOPE+cProcesso))

BRI->(restArea(aAreaBRI))
RestArea(aAreaBCI)

return(nil)


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSA499EXC� Autor � Totvs					� Data � 15/10/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Excluir processo e desvincula do peg					  	    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
function PLSA499EXC()
LOCAL aArea	:= BCI->(getArea())
LOCAL nIndUt:=	0
LOCAL nInd1	:= 0

	//���������������������������������������������������������������������������
	//� Verifica se o processo esta sendo gerenciado por outro usu�rio. 
	//���������������������������������������������������������������������������
	If !PLSVEROPE(.f.)
		Return
	EndIf
	
	//���������������������������������������������������������������������������
	//� posiciona na peg do processo
	//��������������������������������������������������������������������������� 
	//	BCI->(dbSetOrder(13))//BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE 
	If nInd1 == 0
	   nIndUt := PLSBUIND("BCI","BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE") /// Busca da Ordem do indice pela descri��o 
	   nInd1  := nIndUt
	Endif
	
	//���������������������������������������������������������������������������
	//� Verifica se existe PEGs vinculadas ao processo, antes da exclusao.
	//��������������������������������������������������������������������������� 
	BCI->( DbSetOrder(nInd1) )//BCI_FILIAL + BCI_CODOPE + BCI_PROCES + BCI_FASE
	
	if BCI->(msSeek(xFilial("BCI")+BRI->(BRI_CODOPE+BRI_CODIGO)))
		HELP('PLSA499EXC',, 'PLSA499EXC',, "Existe PEGs vinculadas a este processo.", 1, 0) 
		Return
	EndIf

if msgYesNo("Confirma a exclus�o do processo [ "+BRI->BRI_CODIGO+" ]")

	if BCI->(msSeek(xFilial("BCI")+BRI->(BRI_CODOPE+BRI_CODIGO)))
		//���������������������������������������������������������������������������
		//� Inicio da transacao
		//��������������������������������������������������������������������������� 
		begin transaction
		//���������������������������������������������������������������������������
		//� desvincula peg do processo
		//��������������������������������������������������������������������������� 
		while !BCI->(eof()) .and. (BCI->(BCI_FILIAL+BCI_PROCES) == xFilial("BCI")+BRI->BRI_CODIGO .or. BCI->(msSeek(xFilial("BCI")+BRI->(BRI_CODOPE+BRI_CODIGO))))
	
			BCI->(recLock("BCI",.f.))
				BCI->BCI_PROCES := ""
			BCI->(msUnLock())
	
		BCI->(dbSkip())
		endDo
		//���������������������������������������������������������������������������
		//� deleta processo
		//��������������������������������������������������������������������������� 
		BRI->(recLock("BRI",.f.))
			BRI->(dbDelete())
		BRI->(msUnLock())
		//���������������������������������������������������������������������������
		//� Fim da transacao
		//��������������������������������������������������������������������������� 
		end transaction
	else
		//���������������������������������������������������������������������������
		//� deleta processo
		//��������������������������������������������������������������������������� 
		BRI->(recLock("BRI",.f.))
			BRI->(dbDelete())
		BRI->(msUnLock())
	endIf	
endIf

BCI->(restArea(aArea))
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//��������������������������������������������������������������������������� 
return(nil)
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSA499IMP� Autor � Totvs					� Data � 15/10/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Imprimi capa do processo									  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
function PLSA499IMP()

if msgYesNo("Confirma a impress�o da capa de lote numero [ "+BRI->BRI_CODIGO+" ]")
	processa( {|| PLSRCPRO(BRI->(BRI_CODOPE+BRI_CODIGO+BRI_CODRDA)) }, "Impress�o", "Imprimindo capa de lote...", .t.)
endIf
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//��������������������������������������������������������������������������� 
return(nil)
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSA499RES� Autor � Totvs					� Data � 15/10/12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � gerenciamento do processo								  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
function PLSA499RES()
LOCAL cCodOpe := PLSRtCdUsr()
//���������������������������������������������������������������������������
//� verificar se e administrador do sistema
//��������������������������������������������������������������������������� 
if BRI->(fieldPos("BRI_OPERES")) > 0
	//���������������������������������������������������������������������������
	//� se sou administrador e ja tem operador gerenciando
	//��������������������������������������������������������������������������� 
	if !empty(BRI->BRI_OPERES) .and. FWIsAdmin()
	
		if msgYesNo("PROCESSO sendo gerenciado pelo operador ["+allTrim(usrRetName(BRI->BRI_OPERES))+"], confirma a libera��o?")
			BRI->(reclock("BRI",.f.))
				BRI->BRI_OPERES	:= ""
			BRI->(msUnlock()) 
		endIf	
	//���������������������������������������������������������������������������
	//� e o mesmo operador que esta gerenciando
	//��������������������������������������������������������������������������� 
	elseif BRI->BRI_OPERES == cCodOpe
	
		if msgYesNo("Confirma a libera��o do PROCESSO numero ["+BRI->BRI_CODIGO+"]")	
			BRI->(reclock("BRI",.f.))
				BRI->BRI_OPERES	:= "" 
			BRI->(msUnlock()) 
		endIf                        
	//���������������������������������������������������������������������������
	//� vai pegar para gerenciamento
	//��������������������������������������������������������������������������� 
	elseif empty(BRI->BRI_OPERES)
	
		if msgYesNo("Confirma o gerenciamento do PROCESSO numero ["+BRI->BRI_CODIGO+"]")	
			BRI->(reclock("BRI",.F.))
				BRI->BRI_OPERES	:= cCodOpe 
			BRI->(msUnlock()) 
		endIf
	//���������������������������������������������������������������������������
	//� nao e o operador do peg
	//��������������������������������������������������������������������������� 
	else
		aviso("Aten��o","Outro operador esta fazendo o gerenciamento do PROCESSO ["+BRI->BRI_CODIGO+"]",{"Ok"},1)
	endIf	
endIf	
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//��������������������������������������������������������������������������� 
return(nil)


/*//-------------------------------------------------------------------
{Protheus.doc} P499Query.
Abre ou fecha a �rea com os resultados da query da BCI, para sele��o do usu�rio
@since    08/2021
//-------------------------------------------------------------------*/
static function P499Query(lAbreQry)
local cSql 			:= ""
local lTemDado		:= .f.
default lAbreQry 	:= .f.

if lAbreQry 
	cSql := " SELECT BCI.BCI_CODOPE, BCI.BCI_CODLDP, BCI.BCI_CODPEG, BCI.BCI_FASE, BCI.BCI_VLRGUI, BCI.BCI_CODRDA, BCI.BCI_NOMRDA, 
	cSql += "   BCI.BCI_OPERES, BCI.BCI_PROCES, BCI.BCI_TIPGUI, BCL.BCL_DESCRI, BCI.R_E_C_N_O_ REC "
	cSql += "     FROM " + RetSqlName("BCI") + " BCI "
	cSql += "     INNER JOIN " + RetSqlName("BCL") + " BCL   ON "
    cSql += "        BCL.BCL_FILIAL = BCI.BCI_FILIAL AND "
    cSql += "        BCL.BCL_CODOPE = BCI.BCI_CODOPE AND "
    cSql += "        BCL.BCL_TIPGUI = BCI.BCI_TIPGUI AND "
	cSql += "	     BCL.D_E_L_E_T_ = ' ' "
	cSql += "     WHERE BCI.BCI_FILIAL = '" + xFilial("BCI") + "' AND "
	cSql += "       BCI.BCI_OPERDA = '" + BRI->BRI_CODOPE + "' AND "
	cSql += "       BCI.BCI_CODRDA = '" + BRI->BRI_CODRDA + "' AND "
	cSql += "		( (BCI.BCI_PROCES = '" + BRI->BRI_CODIGO + "') OR (BCI_PROCES = ' ') ) AND " 
	cSql += "    	BCI.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"EXPEGBCI",.F.,.T.)
	lTemDado :=  !EXPEGBCI->(eof())
else
	EXPEGBCI->(dbclosearea())
endif	

return lTemDado
