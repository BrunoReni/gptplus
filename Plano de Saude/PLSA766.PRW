
#include "PLSMGER.CH"
#include "PROTHEUS.CH"

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA766 � Autor � Antonio / Tulio Byte � Data � 13.12.2002 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cria as vidas                                              潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�            	
/*/
Function PLSA766
LOCAL nQtd   := 0
LOCAL nTotal := 0
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define ordem padrao pelo CPF...                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
BA1->(DbSetOrder(4))
BA1->(MsSeek(xFilial("BA1")))
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Navega por todos os usuarios da base de dados...                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
While ! BA1->(Eof())
      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
      //� Acumula qtd...                                                           �
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
      nQtd   ++    
      nTotal ++
      
      If nQtd == 100
         nQtd := 0
      Endif                                            
      
     PLSA766ANV()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Grava a vida nova ou posicionada...                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
BA1->(RecLock("BA1",.F.))                         
BA1->BA1_MATVID := BTS->BTS_MATVID
BA1->(MsUnlock())
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Navega para outro usuario...                                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
BA1->(DbSkip())
Enddo
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina...                                                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  砅LSA766Vid� Autor � Antonio / Tulio Byte � Data � 13.12.2002 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cria as vidas                                              潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/                                                                                                  
Function PLSA766Vid(cAlias)
LOCAL cCodVid := ''
DEFAULT cAlias := 'BA1'
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Busca o novo codigo de vida...                                           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cCodVid := BTS->(GetSx8Num("BTS","BTS_MATVID"))
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� grava a vida fisicamente...                                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
BTS->(RecLock("BTS",.T.)) 
BTS->BTS_FILIAL := xFilial("BTS")
BTS->BTS_MATVID := cCodVid
BTS->BTS_NOMUSR := &(cAlias+"->BA1_NOMUSR")
BTS->BTS_NOMCAR := &(cAlias+"->BA1_NOMUSR")
BTS->BTS_SEXO   := &(cAlias+"->BA1_SEXO")
BTS->BTS_ESTCIV := &(cAlias+"->BA1_ESTCIV")
BTS->BTS_CPFUSR := &(cAlias+"->BA1_CPFUSR")
BTS->BTS_DRGUSR := &(cAlias+"->BA1_DRGUSR")
BTS->BTS_ORGEM  := &(cAlias+"->BA1_ORGEM" )
BTS->BTS_CEPUSR := &(cAlias+"->BA1_CEPUSR")
BTS->BTS_ENDERE := &(cAlias+"->BA1_ENDERE")
BTS->BTS_NR_END := &(cAlias+"->BA1_NR_END")
BTS->BTS_COMEND := &(cAlias+"->BA1_COMEND")
BTS->BTS_BAIRRO := &(cAlias+"->BA1_BAIRRO")
BTS->BTS_MUNICI := &(cAlias+"->BA1_MUNICI")                                                        
BTS->BTS_ESTADO := &(cAlias+"->BA1_ESTADO")
BTS->BTS_TELEFO := &(cAlias+"->BA1_TELEFO")
BTS->BTS_DATNAS := &(cAlias+"->BA1_DATNAS")
BTS->BTS_UNIVER := &(cAlias+"->BA1_UNIVER")
BTS->BTS_MAE    := &(cAlias+"->BA1_MAE")
BTS->BTS_PAI    := &(cAlias+"->BA1_PAI")
BTS->BTS_INTERD := "0"
BTS->BTS_CORNAT := "6"
BTS->BTS_SANGUE := &(cAlias+"->BA1_SANGUE")
BTS->BTS_CODMUN := &(cAlias+"->BA1_CODMUN")

If BTS->(FieldPos("BTS_TIPDOC")) > 0 .And. BA1->(FieldPos("BA1_TIPDOC")) > 0
   BTS->BTS_TIPDOC := &(cAlias+"->BA1_TIPDOC")
Endif

If BTS->(FieldPos("BTS_DRGUSR")) > 0 .And. BA1->(FieldPos("BA1_TIPDOC")) > 0
   BTS->BTS_DRGUSR := &(cAlias+"->BA1_DRGUSR")
Endif

If BA1->(FieldPos("BA1_NRCRNA")) > 0 
   BTS->BTS_NRCRNA := &(cAlias+"->BA1_NRCRNA")
Endif 

BTS->(MsUnlock())
ConfirmSX8()       

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Ponto de entrada para gravar novos dados na tabela BTS                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock("PLS766GRV") 
    ExecBlock("PLS766GRV",.F.,.F.)    
EndIf    
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina...                                                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  砅LSA766ANV� Autor � Antonio / Tulio Byte� Data � 13.12.2002 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cria as vidas                                              潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA766ANV(lDireto,lPergVid)
LOCAL cNomUsr 	:= ''
LOCAL cDatNas 	:= cTod('')
LOCAL nRegBTS	:= 0
LOCAL aVidas	:= {}

DEFAULT lDireto := .F.     
DEFAULT lPergVid := .T.

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� << CPF >> Procura pelo CPF...                                            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
BTS->(DBSetOrder(3))
If BTS->(MsSeek(xFilial("BTS")+BA1->BA1_CPFUSR)) .And. ! Empty(BA1->BA1_CPFUSR) .And. Subs(BA1->BA1_CPFUSR,1,11) <> "00000000000" .And. dtos(BA1->BA1_DATNAS) == dtos(BTS->BTS_DATNAS)
	
Else
	If !lDireto
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� << NOME + DATA DE NASCIMENTO >>                                          �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		BTS->(DbSetOrder(5))
		If BTS->(MsSeek(xFilial("BTS")+BA1->BA1_NOMUSR+dTos(BA1->BA1_DATNAS)))
			cNomUsr := BTS->BTS_NOMUSR
			cDatNas := BTS->BTS_DATNAS
			nRegBTS := BTS->( Recno() )
			
			While !BTS->( Eof() ) .and. BTS->BTS_NOMUSR == cNomUsr .and.;
				dTos(BTS->BTS_DATNAS) == dTos(cDatNas)
				
				Aadd(aVidas, {BTS->BTS_MATVID, BTS->BTS_NOMUSR,;
				BTS->BTS_DATNAS, BTS->BTS_MAE, BTS->(Recno())} )
				
				BTS->( dbSkip() )
			Enddo
			
			If lPergVid .And. PLS766BRW(aVidas)
			Else
				//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
				//� Caso nao seja selecionada nenhuma vida pelo browse...                    �
				//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
				PLSA766VID()
			Endif
		Else
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Nao existe na vida agora vou incluir pela primeira vez na vida...        �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			PLSA766VID()
		EndIf
	Else
		PLSA766VID()
	Endif
Endif

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅LS766BRW 篈utor  矴eraldo Felix Junior� Data �  14/04/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Mostra browse com as vidas de mesmo nome e mesma data de   罕�
北�          � nascimento para relecao de uma delas.                      罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function PLS766BRW(aVidas)
LOCAL oDlgUsu
LOCAL oListaUsr                      
LOCAL lRet := .F.
LOCAL bOk 		:= {|| lRet := .T., BTS->( dbGoto(aVidas[oListaUsr:nAt][5]) ), oDlgUsu:End() }
LOCAL bCancel   := {|| Iif(MsgYesNo("Cancelando a selecao, sera criada uma nova vida!"),;
						(lRet := .F., oDlgUsu:End()), .T.) }

// variaveis lgpd 
local objCENFUNLGP  := CENFUNLGP():New()
local aCamposCen  	:= {}
local aBls  		:= {}

DEFINE MSDIALOG oDlgUsu TITLE "Vidas" FROM 012,005 TO 28, 100 

oListaUsr := TcBrowse():New( 013, 002, 372, 062,,,, oDlgUsu,,,,,,,,,,,, .F.,, .T.,, .F., )
oListaUsr:SetArray(aVidas)

oListaUsr:AddColumn(TcColumn():New("Matricula ",nil,;
nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
oListaUsr:ACOLUMNS[1]:BDATA     := { || aVidas[oListaUsr:nAt,1] }

oListaUsr:AddColumn(TcColumn():New("Nome",nil,;
nil,nil,nil,nil,125,.F.,.F.,nil,nil,nil,.F.,nil))
oListaUsr:ACOLUMNS[2]:BDATA     := { || aVidas[oListaUsr:nAt,2] }

oListaUsr:AddColumn(TcColumn():New("Data de nasc",nil,;
nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
oListaUsr:ACOLUMNS[3]:BDATA     := { || aVidas[oListaUsr:nAt,3] }

oListaUsr:AddColumn(TcColumn():New("Nome da mae",nil,;
nil,nil,nil,nil,100,.F.,.F.,nil,nil,nil,.F.,nil))
oListaUsr:ACOLUMNS[4]:BDATA     := { || aVidas[oListaUsr:nAt,4] }

if objCENFUNLGP:isLGPDAt()
	aCamposCen := {"BTS_MATVID", "BTS_NOMUSR", "BTS_DATNAS", "BTS_MAE"}
	aBls := objCENFUNLGP:getTcBrw(aCamposCen)

	oListaUsr:aObfuscatedCols := aBls
endif

oListaUsr:BLDBLCLICK := bOk

TButton():New(090,105,"Confirmar",,bOK    ,030,010,,,,.T.) //Bot鉶 Confirmar
TButton():New(090,150,"Cancelar" ,,bCancel,030,010,,,,.T.) //Bot鉶 Cancelar

ACTIVATE MSDIALOG oDlgUsu /*ON INIT Eval({||EnChoiceBar(oDlgUsu,{||Eval(bOk)},{||Eval(bCancel)},.F.)} )*/

Return(lRet)


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  砅L766VALD	� Autor � Daher				  � Data � 23.02.2005 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Verifica duplicidade no cadst de vidas                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PL766VALD
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Declaracao de variaveis...                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
LOCAL aSays     := {}
LOCAL aButtons  := {}
LOCAL cPerg     := "PLS766"
LOCAL cCadastro := "Verifica玢o de duplicidade no cadastro de vidas"

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta texto para janela de processamento                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
AADD(aSays,"Programa que lista as duplicidades encontradas no cadastro de vidas (BTS).")
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta botoes para janela de processamento                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| MsAguarde({|| PL766VALPro(cPerg)}, "", "Processando...", .T.),FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Exibe janela de processamento                                            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
FormBatch( cCadastro, aSays, aButtons,, 160 )
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina Principal...                                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return     

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  PL766VALPro| Autor � Daher				  � Data � 23.02.2005 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Processa duplicidade no cadst de vidas                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/                              
Function PL766VALPro(cPerg)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Busca dados dos parametros...                                       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
  
LOCAL aDados  := {}
LOCAL aCabec  := { {"Matric. Vida","@!",30},{"Nome Vida","@!",100},{"Data Nasc.","@D",030},{"CPF","@C",050},{"Qtd de Duplicidades","@C",050}}
LOCAL cTitulo := "Duplicidades Encontradas"      
LOCAL nOrdBTS := BTS->(IndexOrd())
LOCAL nRecBTS := BTS->(Recno())        
LOCAL i		  := 1                  
PRIVATE cNomeUs
PRIVATE cMatric
PRIVATE dDatNas
PRIVATE cCPFusu                  
PRIVATE nRecAux      
PRIVATE nNome   
PRIVATE nDatN 
PRIVATE nCPF       
PRIVATE lWhile := .F.

Pergunte(cPerg,.F.) 
nNome := 1
nDatN := mv_par01
nCPF  := mv_par02
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Sempre ordeno por NOME												�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
BTS->(DbSetOrder(2))
BTS->(DbGoTop())   
                   

while !BTS->(EOF()) 
	cNomeUs := BTS->BTS_NOMUSR
	cMatric := BTS->BTS_MATVID
	dDatNas := BTS->BTS_DATNAS
	cCPFusu := BTS->BTS_CPFUSR 
	i 		:= 0
	BTS->(DbSkip())
	MontaWhile()	
	while !BTS->(EOF()) .AND. lWhile 
		i++
		BTS->(DbSkip())
		MontaWhile()
	enddo       
	
	if i > 0
	      aadd(aDados,{cMatric,cNomeUs,dDatNas,cCPFusu,i})
	endif      
	lWhile  := .F.	       
enddo                          

PLSCRIGEN(aDados,aCabec,cTitulo)

BTS->(DbSetOrder(nOrdBTS))
BTS->(DbGoTo(nRecBTS))

return                      

static Function MontaWhile()
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Considera nome ?                                                    |
	//| se eh pra considerar o nome e o nome jah eh diferente entao retorno |
	//| direto, e por ai vai ...											�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	if nNome == 1
	     if BTS->BTS_NOMUSR == cNomeUs
	     	lWhile := .T.
	     else
	     	lWhile := .F. 
	     	return
	     endif
	endif     
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Considera dt nasc ?													�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	if nDatN == 1  
	     if BTS->BTS_DATNAS == dDatNas
	     	lWhile := .T.
	     else
	     	lWhile := .F.
	     	return
	     endif
	endif       
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Considera cpf	 ?													�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	if nCPF == 1 
		if BTS->BTS_CPFUSR == cCPFusu
		    lWhile := .T.
		else
			lWhile := .F.
			return
		endif
	endif                 
	
return 