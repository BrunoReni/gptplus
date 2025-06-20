#INCLUDE "CTBA007.CH"
#INCLUDE "PROTHEUS.CH"
// Define dos modos das rotinas
#DEFINE VISUALIZAR	2
#DEFINE INCLUIR	  	3
#DEFINE ALTERAR	   	4
#DEFINE EXCLUIR	   	5
#DEFINE OK		   	1
#DEFINE CANCELA		2
#DEFINE  ENTER 		Chr(13)+Chr(10)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBA007   �Autor  �Alvaro Camillo Neto � Data �  19/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Dados Auxiliares CTB                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTB                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTBA007()
Private cCadastro  		:= STR0001 			// Titulo   //"Dados Auxiliares CTB"
Private cAlias  		:= "CW0"			// Dados Auxiliares CTB
Private aRotina    		:= MenuDef()		// Vetor com as op��es da MBrowse

dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(1)) // CW0_FILIAL+CW0_TABELA+CW0_CHAVE
(cAlias)->(dbGotop())
mBrowse(,,,,cAlias)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTA007MAN �Autor  �Alvaro Camillo Neto � Data �  19/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o de manutn��o Dados Auxiliares CTB                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTB                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTA007MAN(cAlias,nRecNo,nOpc)

Local aHeader 		:= {}
Local aCols   		:= {}
Local cCPOs			:= ""		// Campos que aparecer�o na getdados
Local cChav			:= ""
Private oEnch		:= Nil
Private oDlg		:= Nil
Private oGet		:= Nil

//��������������������������������������Ŀ
//� Variaveis internas para a MsMGet()   �
//����������������������������������������
Private aTELA[0][0]
Private aGETS[0]

//��������������������������������������Ŀ
//�Variaveis para a MsAdvSize e MsObjSize�
//����������������������������������������
Private lEnchBar   		:= .F. // Se a janela de di�logo possuir� enchoicebar (.T.)
Private lPadrao    		:= .F. // Se a janela deve respeitar as medidas padr�es do Protheus (.T.) ou usar o m�ximo dispon�vel (.F.)
Private nMinY	      	:= 400 // Altura m�nima da janela

Private aSize	   		:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Private aInfo	 	   	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Private aObjects	   	:= {}
Private aPosObj	   	:= {}

aAdd(aObjects,{50,50,.T.,.F.})	   		// Definicoes para a Enchoice
aAdd(aObjects,{150,150,.T.,.F.})		// Definicoes para a Getdados
aAdd(aObjects,{100,015,.T.,.F.})

aPosObj := MsObjSize(aInfo,aObjects)	// Mantem proporcao - Calcula Horizontal


// Valida��o da inclus�o
If (cAlias)->(RecCount()) == 0 .And. !(nOpc==INCLUIR)
	Return .T.
Endif

cCPOs := "CW0_FILIAL/CW0_TABELA"
cChav := IIF( (cAlias)->CW0_TABELA == "00", (cAlias)->CW0_CHAVE, (cAlias)->CW0_TABELA)
cChav	:= Alltrim(cChav)

aHeader	:= CriaHeader(NIL,cCPOs,aHeader)
aCols		:= CriaAcols(aHeader,cAlias,1,xFilial("CW0")+cChav,nOpc,aCols)
MontaTela(aHeader,aCols,nRecNo,nOpc)

Return nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaHeader�Autor  �Alvaro Camillo Neto � Data �  19/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria o Aheader da getdados                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTB                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaHeader(cCampos,cExcessao,aHeader)
Local   aArea		:= (cAlias)->(GetArea())
Default aHeader 	:= {}
DEFAULT cCampos 	:= "" // Campos a serem conciderados
DEFAULT cExcessao	:= "" // Campos que n�o conciderados

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAlias
	If (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessao)) .And. (X3USO(SX3->X3_USADO))
		aAdd( aHeader, { AlLTrim( X3Titulo() ), ; // 01 - Titulo
		SX3->X3_CAMPO	, ;			// 02 - Campo
		SX3->X3_Picture	, ;			// 03 - Picture
		SX3->X3_TAMANHO	, ;			// 04 - Tamanho
		SX3->X3_DECIMAL	, ;			// 05 - Decimal
		SX3->X3_Valid  	, ;			// 06 - Valid
		SX3->X3_USADO  	, ;			// 07 - Usado
		SX3->X3_TIPO   	, ;			// 08 - Tipo
		SX3->X3_F3		, ;	 		// 09 - F3
		SX3->X3_CONTEXT , ;      	// 10 - Contexto
		SX3->X3_CBOX	, ; 	 	// 11 - ComboBox
		SX3->X3_RELACAO , } )	 	// 12 - Relacao
	Endif
	SX3->(dbSkip())
End
RestArea(aArea)
Return(aHeader)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaAcols �Autor  �Alvaro Camillo Neto � Data �  19/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Func�a que cria Acols                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�aHeader : aHeader aonde o aCOls ser� baseado                ���
���          �cAlias  : Alias da tabela                                   ���
���          �nIndice : Indice da tabela que sera usado para              ���
���          �cComp   : Informacao dos Campos para ser comparado no While ���
���          �nOpc    : Op��o do Cadastro                                 ���
���          �aCols   : Opcional caso queira iniciar com algum elemento   ���
�������������������������������������������������������������������������͹��
���Uso       � CTB                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaAcols(aHeader,cAlias,nIndice,cComp,nOpc,aCols)
Local 	nX			:= 0
Local 	nCols     	:= 0
Local   aArea		:= (cAlias)->(GetArea())
DEFAULT aCols 		:= {}

IF nOpc == INCLUIR
	aAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 To Len(aHeader)
		aCols[1][nX] := CriaVar(aHeader[nX][2])
	Next nX
	aCols[1][Len(aHeader)+1] := .F.
Else
	(cAlias)->(dbSetOrder(nIndice))
	(cAlias)->(dbSeek(cComp))
	While (cAlias)->(!Eof()) .And. ALLTRIM((cAlias)->(CW0_FILIAL+CW0_TABELA)) == ALLTRIM(cComp)
		aAdd(aCols,Array(Len(aHeader)+1))
		nCols ++
		For nX := 1 To Len(aHeader)
			If ( aHeader[nX][10] != "V")
				aCols[nCols][nX] := (cAlias)->(FieldGet(FieldPos(aHeader[nX][2])))
			Else
				aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
			Endif
		Next nX
		aCols[nCols][Len(aHeader)+1] := .F.
		(cAlias)->(dbSkip())
	End
EndIf
RestArea(aArea)
Return(aCols)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MontaTela �Autor  �Alvaro Camillo Neto � Data �  19/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Func��o respons�vel por montar a tela                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTB                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MontaTela(aHeader,aCols,nReg,nOpc)
//�����������������������������������Ŀ
//� Variaveis da MsNewGetDados()      �
//�������������������������������������
Local nOpcX		  	:= 0               		// Op��o da MsNewGetDados
Local cLinhaOk     	:= "CT007LOK()" 		// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue()" 		// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""                   // Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              	// Campos estaticos na GetDados.
Local nMax         	:= 999              	// Numero maximo de linhas permitidas.
Local aAlter    	:= {}               	// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"		// Funcao executada na validacao do campo
Local cSuperDel     := "AllwaysTrue" 		// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk        := "AllwaysTrue"  		// Funcao executada para validar a exclusao de uma linha do aCols
//�����������������������������������Ŀ
//� Variaveis da MsMGet()             �
//�������������������������������������

Local aAlterEnch	:= {}				 	// Campos que podem ser editados na Enchoice
Local aPos		  	:= {000,000,080,400}	// Dimensao da MsMget em relacao ao Dialog  (LinhaI,ColunaI,LinhaF,ColunaF)
Local nModelo		:= 3     			 	// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros
Local lF3 		  	:= .F.				 	// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria
Local lMemoria		:= .T.	   	 	 		// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao
Local lColumn		:= .F.			  		// Indica se a apresentacao dos campos sera em forma de coluna
Local caTela 		:= "" 				 	// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela
Local lNoFolder		:= .F.			 		// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)
Local lProperty		:= .F.			 		// Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes

//�����������������������������������Ŀ
//� Variaveis da EnchoiceBar()        �
//�������������������������������������
Local nOpcA			:= 0					// Bot�o Ok ou Cancela
Local nCont			:= 0
Local aArea			:= GetArea()
Local lExistGet

Local oTabela		:= Nil
Local oDescric		:= Nil

Private cTabela 	:= ""
Private cDescric	:= ""

If nOpc != INCLUIR
	cTabela := IIF( (cAlias)->CW0_TABELA == "00", (cAlias)->CW0_CHAVE, (cAlias)->CW0_TABELA)
	cTabela	:= Alltrim(cTabela)
	cDescric	:= GetAdvFVal("CW0","CW0_DESC01",xFilial("CW0") +"00"+cTabela ) 
Else
	cTabela 	:= CriaVar("CW0_TABELA")
	cDescric	:= CriaVar("CW0_DESC01")
EndIf

//����������������������������������������������������������������������
//�Adiciona os campos a serem atualizados pelo usuario na MsNewGetDados�
//����������������������������������������������������������������������
For nCont := 1 to Len(aHeader)
	If ( aHeader[nCont][10] != "V") .And. X3USO(aHeader[nCont,7])
		aAdd(aAlter,aHeader[nCont,2])
	EndIf
Next nCont

//����������������������������������������������������������������������
//�Defini��od dos Objetos                                              �
//����������������������������������������������������������������������
oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],cCadastro,,,,,,,,,.T.)

If nOpc == INCLUIR .Or. nOpc == ALTERAR
	nOpcX	:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nOpcX	:= 0
EndIf

oTPane1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,16,.T.,.F.)
oTPane1:Align := CONTROL_ALIGN_TOP

@ 4, 006 SAY STR0003	  	SIZE 70,7 PIXEL OF oTPane1  //"Tabela:"
@ 4, 062 SAY STR0004	  	SIZE 70,7 PIXEL OF oTPane1  //"Descricao:"

@ 3, 026 MSGET oTabela 	 VAR cTabela 	 Picture "@!" When INCLUI Valid ValidCpo(cTabela) .And. CT007Tab(cTabela)  SIZE 30,7 PIXEL OF oTPane1
@ 3, 090 MSGET oDescric  VAR cDescric    Picture "@!" When INCLUI .OR. ALTERA Valid ValidCpo(cDescric) SIZE 150,7 PIXEL OF oTPane1

//����������������������������������������������������������������������
//�MsNewGetDados                                                       �
//����������������������������������������������������������������������
oGet			:= MsNewGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],nOpcX,;
cLinhaOk ,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDLG,aHeader,aCols)

oGet:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oDlg:bInit 		:= EnchoiceBar(oDlg,{||IIF( IIF(nOpc == INCLUIR .Or. nOpc == ALTERAR, CTA007TOK() , .T.) ,(nOpcA:=1,oDlg:End()), )},{|| oDlg:End()})
oDlg:lCentered	:= .T.
oDlg:Activate()

If nOpcA == OK .AND. !(nOpc == VISUALIZAR)
	Begin Transaction
	CT007Grava(nOpc)
	End Transaction
Endif

RestArea(aArea)
Return(nOpcA)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CT007Grava�Autor  �Alvaro Camillo Neto � Data �  19/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para efetuar a grava��o nas tabelas                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTB                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CT007Grava(nOpc)
Local nX				:= 0
Local nI 			:= 0
Local nPosChav		:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==Upper("CW0_CHAVE")})
Local lGrava		:= .F.

If nOpc == INCLUIR .Or. nOpc == ALTERAR	
	//���������������������������Ŀ
	//�Grava o cabe�alho da tabela�
	//�����������������������������
	lGrava := ( (cAlias)->(dbSeek(xFilial(cAlias)+"00"+cTabela)) )
	RecLock(cAlias,!lGrava)
	(cAlias)->CW0_FILIAL := xFilial(cAlias)
	(cAlias)->CW0_TABELA := "00"
	(cAlias)->CW0_CHAVE	:= cTabela
	(cAlias)->CW0_DESC01	:= cDescric
	
	MsUnLock()
	
	//������������������������Ŀ
	//�Grava os Itens da Tabela�
	//��������������������������
	(cAlias)->(dbSetOrder(1))  // CW0_FILIAL + CW0_TABELA + CW0_CHAVE
	For nX:= 1 to Len(oGet:aCols)
		lGrava := ( (cAlias)->(dbSeek(xFilial(cAlias)+cTabela+oGet:Acols[nX,nPosChav])) )
		If oGet:Acols[nX,Len(oGet:aHeader)+1] .And. lGrava .And. CT007LOK(nX,.F.)
			RecLock(cAlias,!lGrava)
			( cAlias )->( dbDelete() )
			MsUnlock()
		ElseIf !oGet:Acols[nX,Len(oGet:aHeader)+1]
			RecLock(cAlias,!lGrava)
			(cAlias)->CW0_FILIAL := xFilial(cAlias)
			(cAlias)->CW0_TABELA := cTabela
			For nI:= 1 to Len(oGet:aHeader)
				(cAlias)->(FieldPut(FieldPos(Trim(oGet:aHeader[nI,2])),oGet:aCols[nX,nI]))
			Next nI
			MsUnLock()
		EndIf
	Next nX
	
ElseIf nOpc == EXCLUIR
	//���������������Ŀ
	//�Deleta os Itens�
	//�����������������
	(cAlias)->(dbSetOrder(1)) // CW0_FILIAL + CW0_TABELA + CW0_CHAVE
	If (cAlias)->(dbSeek(xFilial(cAlias)+ "00" + cTabela))
		RecLock(cAlias,.F.)
		( cAlias )->( dbDelete() )
		MsUnlock()
	EndIf
	
	(cAlias)->(dbSeek(xFilial(cAlias)+cTabela))
	While (cAlias)->(!EOF()) .And. (cAlias)->(CW0_FILIAL + CW0_TABELA ) == xFilial(cAlias)+cTabela
		RecLock(cAlias,.F.)
		( cAlias )->( dbDelete() )
		MsUnlock()
		(cAlias)->(dbSkip())
	EndDo
	
EndIf

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTA007TOK �Autor  �Alvaro Camillo Neto � Data �  20/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o TudoOK da rotina                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTB                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTA007TOK(nOpc)
Local lRet 			:= .T.
Local nX	  		:= 0
Local aCols 		:= oGet:aCols
Local aHeader		:= oGet:aHeader
Local nPosChav		:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("CW0_CHAVE")})
Local nItens		:= 0
Local nPos			:= 0

lRet := NaoVazio(cTabela) .And. NaoVazio(cDescric) .And. CT007Tab(cTabela)

If lRet
	For nX:= 1 to Len(aCols)
		If !aCols[nX][Len(aHeader)+1]
			If !CT007LOK(nX)
				lRet := .F.
				Exit
			ElseIF !Empty(aCols[nX][nPosChav])
				nItens++
			EndIf
		EndIf
	Next nX
EndIf

If lRet .And. nItens == 0
	Help(" ",1,"CW0NOLIN" , , STR0005 ,3,0 ) //"Por favor, crie pelo menos um item"
	lRet := .F.
EndIf

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTA007LOK �Autor  �Alvaro Camillo Neto � Data �  20/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o LinOK da rotina                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTB                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CT007LOK(nLinha,lHelp)
Local lRet 			:= .T.
Local nX	  		:= 0
Local aCols 		:= oGet:aCols
Local aHeader		:= oGet:aHeader
Local nPosChav		:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("CW0_CHAVE")})

Default nLinha := oGet:nAt
Default lHelp := .T.

For nX:= 1 to Len(aCols)
	If !aCols[nX][Len(aHeader)+1] .And. nX != nLinha .And. ALLTRIM(aCols[nX][nPosChav]) == ALLTRIM(aCols[nLinha][nPosChav])
		If lHelp
			Help(" ",1,"CW0LINDUP" , , STR0006 ,3,0 ) //"Linha Duplicada"
		EndIf
		lRet := .F.
		Exit
	EndIf
Next nX

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CT007Tab  �Autor  �Alvaro Camillo Neto � Data �  20/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao para o campo CW0_TABELA                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTB                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CT007Tab(cTabela)
Local lRet	:= .T.

If lRet .And. cTabela == "00"
	Help(" ",1,"CW0TAB00" , , STR0007 ,3,0 )     //"Tabela 00 exclusivo para o sistema"
	lRet := .F.
EndIf

If lRet
	lRet := ExistChav("CW0","00" + cTabela )
EndIf

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Alvaro Camillo Neto    � Data �19/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina ,{ STR0008	  		, "AxPesqui"		,0,1 }) //"Pesquisar"
aAdd( aRotina ,{ STR0009	 		, "CTA007MAN"		,0,2 }) //"Visualizar"
aAdd( aRotina ,{ STR0010	 		, "CTA007MAN"		,0,3 }) //"Incluir"
aAdd( aRotina ,{ STR0011	   		, "CTA007MAN"		,0,4 }) //"Alterar"
aAdd( aRotina ,{ STR0012	   		, "CTA007MAN"		,0,5 }) //"Excluir"

Return aRotina 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidCpo  �Autor  �TOTVS				 � Data �  04/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � 							                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTB                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function  ValidCpo(cCampo)
Local lRet := .F.

oGet:Refresh()

lRet := NaoVazio(cCampo)

Return lRet