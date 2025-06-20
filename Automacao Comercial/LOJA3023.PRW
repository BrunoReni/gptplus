#INCLUDE "loja3023.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �LJ3023Tree     �Autor  �Microsiga           � Data �  05/09/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Apresentar arvore para sele��o de produtos atraves das categorias���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Function LJ3023Tree(nProd)

Local oDlgCat 		:= Nil   			//objeto dialog
Local oLayer  		:= FWLayer():new() //objeto FwLayer
Local nRight  		:= oMainWnd:nRight - 200 //posi��o fina da dialog
Local nBottom 		:= oMainWnd:nBottom - 200//posi��o fina da dialog
Local oWinL			:= Nil 	//container window esquerdo da dialog
Local oWinR			:= Nil 	//container window direito da dialog
Local oPnLUP		:= Nil 	//painel superior
Local oPnLDown		:= Nil 	//painel inferior
Local oPnRUP		:= Nil 	//painel superior direito
Local oPnRMiddle	:= Nil 	//painel intermediario direito
Local oPnRDown		:= Nil  //painel inferior direito
Local oGetL			:= Nil  //objeto get esquerdo
Local oGetR			:= Nil  //objeto get direito
Local oSayL			:= Nil  //objeto say esquerdo
Local oSayR			:= Nil  //objeto say direito
Local oSayPrd		:= Nil  //objeto say inferior esquerdo
Local oSayTot		:= Nil  //objeto say total inferior esquerdo
Local oButL			:= Nil  //bot�o lado esquerdo
Local oButR			:= Nil  //bot�o lado direto
Local cPesqL 		:= space(TAMSX3("B1_COD")[1]) //variavel para armazenar conteudo get lado esquerdo
Local cPesqR 		:= space(TAMSX3("B1_COD")[1]) //variavel para armazenar conteudo get lado direito
Local oPnlBottom	:= Nil //painel inferior
Local oBtnOk		:= Nil //bot�o Ok
Local oBtnCancel	:= Nil //bot�o cancelar
Local oTree  		:= Nil //objeto tree
Local aTree  		:= LjRetCatPr() //vetor com itens para a tree
Local oBrw   		:= Nil //objeto TWBrowse
Local aBrw   		:= {STR0001,STR0002}  //"Codigo"###"Descricao"
Local aDados 		:= {{"",""}} //dados da TWBrowse
Local lOk    		:= .F. 	//variavel de controle bot�o OK
Local aPrd   		:= {}  	//Vetor com produtos selecionados
Local nX			:= 0  	//contador
Local nXX			:= 0	//contador
Local nTam			:= 95 	//tamanho que a linha do Layer ira ocupar da tela
Local nPCodPro 		:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_CODPRO"})	//nPCodPro
Local nPCatego 	 	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_CATEGO"}) //nPCatego
Local lRet			:= .T.

Default nProd 		:= 0	// nProd

If M->MEI_TPIMPD <> "I"
	MsgAlert(STR0015,STR0016)  //"Dispon�vel somente para Regra de Desconto por Item!"###"Aten��o"
	lRet := .F.
EndIf

If lRet
	DEFINE MSDIALOG oDlgCat TITLE STR0003 FROM 000,000 TO nBottom, nRight  Pixel of oMainWnd PIXEL  //"Categoria de produtos"

	oGetD:Refresh()

	oLayer:init(oDlgCat,.T.)
	oLayer:addLine ('UP',nTam, .T. )
	oLayer:addCollumn('Left' ,50,.F.,'UP')
	oLayer:addWindow('Left', 'WLeft',STR0004 , 100, .F., .F., , 'UP' )  //"Categorias"

	oWinL := oLayer:getWinPanel ( 'Left', 'WLeft', 'UP' )
	oPnLUP := TPanel():New( 0,0, , oWinL, , , , , RGB(230,230,230), 0, 30, .F., .F. )
	oPnLUP:Align := CONTROL_ALIGN_TOP

	oSayL := TSay():New( 5 , 5,{|| STR0005 },oPnLUP,,,,,,.T.)   //"Produto/Categoria"
	oGetL := TGet():New( 15, 5,{|u| if(PCount()>0,cPesqL:=u,cPesqL)} , oPnLUP, (oPnLUP:nClientWidth/2) - 80, 10, , , , , , , , .T., , , /*bWhen*/, , , , , , , , , , , , )
	oButL := TButton():New( 15, (oPnLUP:nClientWidth/2) - 70, STR0006, oPnLUP, {|| TreeSeek(oTree,RTrim(cPesqL))}, 60, 10, , , , .T. )   //"Pesquisar"

	oPnLDown := TPanel():New( 0,0, , oWinL, , , , , , 0, 0, .F., .F. )
	oPnLDown:Align := CONTROL_ALIGN_ALLCLIENT

	oTree := Xtree():New(0, 0, 0, 0, oPnLDown)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT

	oLayer:addCollumn('Right',50,.F.,'UP')
	oLayer:addWindow('Right', 'WRight', STR0007, 100, .F., .F., , 'UP' )  //"Produtos selecionados"

	oWinR := oLayer:getWinPanel ( 'Right', 'WRight', 'UP' )

	oPnRUP := TPanel():New( 0,0, , oWinR, , , , , RGB(230,230,230), 0, 30, .T., .T. )
	oPnRUP:Align := CONTROL_ALIGN_TOP

	oSayR := TSay():New( 5 , 5,{|| STR0008},oPnRUP,,,,,,.T.)  //"Produto:"
	oGetR := TGet():New( 15, 5,{|u| if(PCount()>0,cPesqR:=u,cPesqR)} , oPnRUP, (oPnRUP:nClientWidth/2) - 80, 10, , , , , , , , .T., , , /*bWhen*/, , , , , , , , , , , , )
	oButR := TButton():New( 15, (oPnRUP:nClientWidth/2) - 70, STR0006, oPnRUP, {|| FindPrd(oBrw,cPesqR)}, 60, 10, , , , .T. )  // //"Pesquisar"

	oPnRMiddle := TPanel():New( 0,0, , oWinR, , , , , , 0, 0, .F., .F. )
	oPnRMiddle:Align := CONTROL_ALIGN_ALLCLIENT

	oBrw := TwBrowse():New(0,0,0,0,,aBrw,,oPnRMiddle,,,,,,,,,,,,,,.T.)
	oBrw:lHScroll := .F.
	oBrw:Align := CONTROL_ALIGN_ALLCLIENT
	oBrw:setArray(aDados)
	oBrw:bLine := {||{ aDados[oBrw:nAt,1],;
	aDados[oBrw:nAt,2] } }

	oPnRDown := TPanel():New( 0,0, , oWinR, , , , , RGB(230,230,230), 0, 15, .T., .T. )
	oPnRDown:Align := CONTROL_ALIGN_BOTTOM

	oSayPrd := TSay():New(05,05,{|| STR0009},oPnRDown,,,,,,.T.)  //"Produtos selecionados:"
	oSayTot := TSay():New(05,80,{|| "0"},oPnRDown,"@E 99999",,,,,.T.)//,,,50,20)

	addNode(oTree,aTree,oBrw,oSayTot,nProd)
	oTree:Refresh()

	oLayer:addLine ("DOWN",10, .T. )
	oPnlBottom := oLayer:getLinePanel("DOWN")

	oSayR      := TSay():New( 5 , 5,{|| "F5 - Marcar/Desmarcar"},oPnlBottom,,,,,,.T.)
	oBtnOk     := TButton():New( 2, (oPnlBottom:nClientWidth/2) - 120, STR0010      , oPnlBottom, {|| lOk := .T., oDlgCat:End()}, 50, 12, , , , .T. )   //"OK"
	oBtnCancel := TButton():New( 2, (oPnlBottom:nClientWidth/2) - 60 , STR0011, oPnlBottom, {|| oDlgCat:End()}, 50, 12, , , , .T. )   //"Cancelar"

	//Teclas de atalho
	SetKEY(VK_F5,{|| dblClick(oTree,oBrw,oSayTot,nProd)})

	ACTIVATE MSDIALOG oDlgCat Centered
EndIf

SetKEY(VK_F5, Nil)

If lOk
	For nX := 1 to Len(aDados)
		aAdd(aPrd,aDados[nX,1])
	Next
EndIf

If lOk  /// carrega o Grid com Itens da arvore. oGetD
	
	
	For nX := 1 to Len(aDados)
		nLinhasAcols 	:= Len(oGetD:acols)
		nUltimaRef		:= oGetD:acols[nLinhasAcols,1]     /// valor do ultimo item do ARRAY (item)
		nProxRef := val(nUltimaRef) + 1
		
		lGravar := .T.
		If nProd == 1
			For nXX := 1 to Len(oGetD:acols)    /// Procura no Acols o CODIGO DO PRODUTO , se encontrar nao grava outro (para n�o duplicar)
				If oGetD:acols[nXX,nPCodPro] == aDados[nX,1]
					lGravar := .F.
				Endif
			Next
		else
			For nXX := 1 to Len(oGetD:acols)    /// Procura no Acols o CODIGO DO GRUPO , se encontrar nao grava outro (para n�o duplicar)
				If oGetD:acols[nXX,nPCatego] == aDados[nX,1]
					lGravar := .F.
				Endif
			Next
		Endif
		
		If lGravar == .T.   // se verdadeiro insere novo PRODUTO ao acols.
			If nProd == 1   // se UM � produto, Dois - Categorias
				
				If Empty(oGetD:acols[nLinhasAcols][nPCodPro]) .AND. Empty(oGetD:acols[nLinhasAcols][nPCatego])   // Veririca se ultima linha � Branco , e nao ADD nova
					oGetD:acols[nLinhasAcols][nPCodPro] :=aDados[nX,1]  // Codigo de produto 									 	
					oGetD:acols[nLinhasAcols][3] :=aDados[nX,2]	// Descri��o 	
				else
					aAdd(oGetD:acols,{StrZero(nProxRef,Len(MB8->MB8_REFGRD)),aDados[nX,1],aDados[nX,2],""         ,0,0,"MB8","","",0,"","","",0,.F.})
				Endif
			Else
				If Empty(oGetD:acols[nLinhasAcols][nPCodPro]) .AND. Empty(oGetD:Acols[nLinhasAcols][nPCatego])   // Veririca se ultima linha � Branco , e nao ADD nova
					oGetD:acols[nLinhasAcols][nPCatego] :=aDados[nX,1]  // Categoria de produtos.	
				else
					aAdd(oGetD:acols,{StrZero(nProxRef,Len(MB8->MB8_REFGRD)),""         ,""          ,aDados[nX,1],0,0,"MB8","","",0,"","","",0,.F.})
				Endif
				
			Endif
		Endif
	Next
Endif

Return aClone(aPrd)

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �TreeSeek       �Autor  �Microsiga           � Data �  05/09/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Procura um no na arvore                                          ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat/ Sigaloja                                                ���
������������������������������������������������������������������������������͹��
���Parametros� oTree  - objeto xTree  		    							   ���
���          � cPesq  - ID do no                                               ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function TreeSeek( oTree, cPesq)

Local nPos	:= 0 // Posicao do produto no vetor

Default oTree := Nil 		// oTree
Default cPesq := ""			// cPesq

If !Empty(cPesq)
	//Procura pelo produto
	nPos := aScan(oTree:aNodes,{|x| Upper(RTrim(cPesq)) ==  Upper(subStr(x[4],1,at("-",x[4] ) - 1)) } )
	
	//Procura pela categoria
	If nPos == 0
		nPos := aScan(oTree:aNodes,{|x| Upper(RTrim(cPesq)) $  Upper(RTrim(x[4])) } )
	EndIf
	
	If nPos > 0
		oTree:TreeSeek(oTree:aCargo[nPos,1])
	Else
		Alert(STR0012)  //"Digite o codigo do produto ou categoria para pesquisar."
	EndIf
Else
	Alert(STR0013) //"Nao encontrado"
EndIf

Return (Nil)

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �FindPrd        �Autor  �Microsiga           � Data �  05/09/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Procura um produto no TwBrowse								   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                          ���
������������������������������������������������������������������������������͹��
���Parametros� oBrw   - objeto TWBrowse                                        ���
���          � cPesq  - c�digo do produto a ser localizado                     ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FindPrd( oBrw, cPesq)  

Local nPos := 0 		// Posicao do produto no TwBrose

Default oBrw 	:=	""  // oBrw
Default cPesq   :=  ""  // cPesq

nPos := aScan(oBrw:aArray,{|x| RTrim(x[1]) == RTrim(cPesq)})

If nPos == 0
	nPos := aScan(oBrw:aArray,{|x|  RTrim(cPesq) $ RTrim(x[2]) })
EndIf

If nPos > 0
	oBrw:nAt := nPos
	oBrw:Refresh()
Else
	Alert(STR0014)  //"Produto n�o encontrado"
EndIf

Return  (Nil)

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �addNode        �Autor  �Microsiga           � Data �  05/09/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Chamada da fun��o recursiva addItem                              ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                          ���
������������������������������������������������������������������������������͹��
���Parametros� oTree  - objeto xTree  		    							   ���
���          � aAux   - Vetor com dados do novo n�   	 					   ���
���          � oBrw   - Objeto TWBrowse   									   ���
���          � oSayTot- Objeto TSay 	     								   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function addNode( oTree, aAux, oBrw, oSayTot, nProd ) 

Local nX := 1 						// Contador 
Local nY := 1 						// Contador 

Default oTree		:= Nil			// oTree
Default aAux		:= {}			// aAux
Default	oBrw		:= Nil			// oBrw
Default	oSayTot		:= Nil			// oSayTot
Default	nProd		:= 0			// nProd


For nX := 1 to Len(aAux)
	If Len(aAux[nX]) >= 3
		For nY := 1 to Len(aAux[nX][3])
			If ValType(aAux[nX][3]) == "A" .And. Len(aAux[nX][3]) > 0
				addItem(oTree,aAux[nX,3,nY],oBrw,oSayTot,nProd)
			EndIf
		Next
	EndIf
Next  

Return (Nil)

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �addItem        �Autor  �Microsiga           � Data �  05/09/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Fun��o recursiva para adicionar o n� e seus filhos               ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                          ���
������������������������������������������������������������������������������͹��
���Parametros� oTree  - objeto xTree  		    							   ���
���          � aAux   - Vetor com dados do novo n�   	 					   ���
���          � oBrw   - Objeto TWBrowse   									   ���
���          � oSayTot- Objeto TSay 	     								   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function addItem(oTree, aAux, oBrw, oSayTot, nProd)    

Local nX := 0   //contador

Default oTree		:= Nil			// oTree
Default aAux		:= {}			// aAux
Default	oBrw		:= Nil			// oBrw
Default	oSayTot		:= Nil			// oSayTot
Default	nProd		:= 0			// nProd

If ValType(aAux[3]) == "A" .And. Len(aAux[3]) > 0
	//Adiciona produto pai
	oTree:addTree( aAux[2], "LBNO", "LBNO", aAux[1],, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot,nProd)} )
	For nX := 1 to Len(aAux[3])
		//Adiciona produtos filhos, que possuem n�s abaixo dele
		addItem(oTree,aAux[3,nX],oBrw,oSayTot,nProd)
	Next nX
	
	iF nProd == 1   // se clic no Botao Arvore PRODUTOS � igual a UM   /// NOVO FLAVIO.
		addPrdTree(oTree,aAux[1],oBrw,oSayTot,nProd)
	Endif
	
	oTree:EndTree()
ElseIf ValType(aAux[3]) == "A"
	//adiciona produtos filhos
	oTree:addTree( aAux[2], "LBNO", "LBNO", aAux[1],, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot,nProd)} )
	
	iF nProd == 1   // se clic no Botao Arvore PRODUTOS � igual a UM   /// NOVO FLAVIO.
		addPrdTree(oTree,aAux[1],oBrw,oSayTot,nProd)
	Endif
	
	oTree:EndTree()
EndIf

Return (Nil)

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �dblClick       �Autor  �Microsiga           � Data �  05/09/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Fun��o de a��o de dois cliques marca/desmarca um item            ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                          ���
������������������������������������������������������������������������������͹��
���Parametros� oTree  - objeto xTree  		    							   ���
���          � oBrw   - Objeto TWBrowse   									   ���
���          � oSayTot- Objeto TSay 	     								   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function dblClick(oTree, oBrw, oSayTot, nProd) 

Local cCargo := oTree:GetCargo()   //ID do no selecionado
Local nPos	 := aScan(oTree:aCargo,{|x| RTrim(x[1]) == RTrim(cCargo)}) //posic�o do n� no vetor
Local cResource := '' 	//imagem a ser adicionada no n�
Local bCode := Nil     	//Utilizado para informar se o n� est� com flag ou n�o
Local cPai := ''      	//ID do produto pai

Default oTree		:= Nil			// oTree   
Default	oBrw		:= Nil			// oBrw
Default	oSayTot		:= Nil			// oSayTot
Default	nProd		:= 0			// nProd

If nPos > 0
	If Eval(oTree:aCargo[nPos,3]) //o Flag do checkBox ser� desmarcado
		cResource := "LBNO"
		bCode	  := {|| .F.}
		oTree:aCargo[nPos,3] := {|| .F.}
		
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.F.,nProd)
		
		//Adiciona produtos selecionados
	Else //o Flag do checkBox ser� marcado
		cResource := "LBTIK"
		bCode	  := {|| .T.}
		oTree:aCargo[nPos,3] := {|| .T.}
		
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.T.,nProd)
		//Remove produtos selecionados
	EndIf
	oTree:ChangeBmp(cResource,cResource,cCargo)
	cPai := oTree:aNodes[nPos,2]
	MarkAllSon(oTree,cPai,cResource,bCode,oBrw,oSayTot,nProd)
EndIf

oBrw:Refresh()

Return (Nil)

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �MarkAllSon     �Autor  �Microsiga           � Data �  05/09/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Marca todos os filhos de um n�                                   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                          ���
������������������������������������������������������������������������������͹��
���Parametros� oTree  - objeto xTree  		    							   ���
���          � cPai   - ID do n� Pai								           ���
���          � cResource - nome da imagem que o n� ir� apresentar              ���
���          � bCode     - Indicar� se o n� est� marcado ou n�o                ���
���          � oBrw      - objeto TWBrowse                                     ���
���          � oSayTot- Objeto TSay 	     								   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MarkAllSon(oTree, cPai, cResource, bCode, oBrw, oSayTot, nProd)  

Local aFilhos := {} //Vetor com n�s filhos
Local nPos 	  := 0  //posic�o do n� na arvore
Local nX 	  := 0  //contador
Local cCargo  := '' //ID do no

Default oTree		:= Nil			// oTree   
Default	cPai		:= ""			// cPai
Default	cResource	:= ""			// cResource
Default	bCode		:= Nil			// bCode
Default oBrw		:= Nil			// oBrw   
Default	oSayTot		:= Nil			// oSayTot
Default	nProd		:= 0			// nProd

aEval(oTree:aNodes, {|x| If(RTrim(x[1]) == RTrim(cPai),aAdd(aFilhos,x[2]) , ) } )

For nX := 1 to Len(aFilhos)
   	nPos   := aScan(oTree:aNodes, {|x| RTrim(x[2]) == RTrim(aFilhos[nX]) } )
	cCargo := oTree:aCargo[nPos,1]
	oTree:aCargo[nPos,3] := bCode
	oTree:ChangeBmp(cResource,cResource,cCargo)
	If Eval(bCode)
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.T.,nProd)
	Else
		AtuPrdBrw(oTree,oBrw,oSayTot,nPos,.F.,nProd)
	EndIf
	MarkAllSon(oTree,aFilhos[nX],cResource,bCode,oBrw,oSayTot,nProd)
Next  

Return (Nil)

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �addPrdTree     �Autor  �Microsiga           � Data �  05/09/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Adiciona um produto a arvore                                     ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                          ���
������������������������������������������������������������������������������͹��
���Parametros� oTree  - objeto xTree  		    							   ���
���          � ID     - ID do n� Pai								           ���
���          � oBrw      - objeto TWBrowse                                     ���
���          � oSayTot- Objeto TSay 	     								   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function addPrdTree( oTree, cID, oBrw, oSayTot, nProd )

Local cFil := xFilial("ACV") //Filial
 
Default oTree		:= Nil			// oTree   
Default cID	   		:= ""			// cID 
Default	oBrw		:= Nil			// oBrw
Default	oSayTot		:= Nil			// oSayTot
Default	nProd		:= 0			// nProd

ACV->(dbSetOrder(1))
ACV->(dbSeek(xFilial("ACV")+cID))

While ACV->(!EOF()) .And. RTrim(ACV->ACV_CATEGO) == RTrim(cID) .And. ACV->ACV_FILIAL == cFil
	If !Empty(ACV->ACV_CODPRO)
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+ACV->ACV_CODPRO))
		oTree:addTreeItem( RTrim(SB1->B1_COD)+"-"+SB1->B1_DESC, "LBNO", RTrim(SB1->B1_COD)+"-P-",, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot,nProd)} )
	ElseIf !Empty(ACV->ACV_GRUPO)
		SB1->(dbSetOrder(4))
		SB1->(dbSeek(xFilial("SB1")+ACV->ACV_GRUPO))
		While SB1->(!EOF()) .And. ACV->ACV_GRUPO == SB1->B1_GRUPO
			oTree:addTreeItem( RTrim(SB1->B1_COD)+"-"+SB1->B1_DESC, "LBNO", RTrim(SB1->B1_COD)+"-G-",, {|| .F.},{|oTree| dblClick(oTree,oBrw,oSayTot,nProd)})
			SB1->(dbSkip())
		EndDo
	EndIf
	ACV->(dbSkip())
EndDo

Return (Nil)

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    �AtuPrdBrw      �Autor  �Microsiga           � Data �  05/09/10   ���
������������������������������������������������������������������������������͹��
���Desc.     �Adiciona um produto a arvore                                     ���
������������������������������������������������������������������������������͹��
���Uso       �SigaFat                                                          ���
������������������������������������������������������������������������������͹��
���Parametros� oTree  - objeto xTree  		    							   ���
���          � oBrw   - objeto TWBrowse                                        ���
���          � oSayTot- Objeto TSay 	     								   ���
���          � nPos   - Posi��o do n�                                          ���
���          � lAdd   - indica se est� adicionando ou retirando um item        ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function AtuPrdBrw( oTree, oBrw, oSayTot, nPos, lAdd, nProd ) 

Local aBrw := oBrw:aArray 			//Vetor do objeto TWBrowse com produtos selecionados
Local cPrd := oTree:aCargo[nPos,1] //Produto selecionado

Default oTree		:= Nil			// oTree   
Default	oBrw		:= Nil			// oBrw
Default	oSayTot		:= Nil			// oSayTot 
Default	nPos		:= 0			// nPos
Default	lAdd		:= .F.			// lAdd
Default	nProd		:= 0			// nProd

If nProd ==1 /// se Nprod = 1 add produtos a Direita, senao add Categorias....
	
	//Verifica se e produto, e se ele existe
	If SB1->(dbSeek(xFilial("SB1")+ substr(cPrd,1,Len(cPrd)-3)))
		If lAdd .and. substr(cPrd,Len(cPrd)-1,1) == "P"
			If Len(aBrw) == 1 .And. Empty(aBrw[1,1])
				aBrw[1,1] := SB1->B1_COD
				aBrw[1,2] := SB1->B1_DESC
			ElseIf aScan(aBrw,{|x| RTrim(x[1]) == RTrim(substr(cPrd,1,Len(cPrd)-3))}) == 0
				aAdd(aBrw,{SB1->B1_COD,SB1->B1_DESC})	
			EndIf
		Else
			nPos := aScan(aBrw,{|x| RTrim(x[1]) == RTrim(substr(cPrd,1,Len(cPrd)-3))})
			If nPos > 0
				aDel(aBrw,nPos)
				aSize(aBrw,Len(aBrw)-1)
			EndIf
		EndIf
		oSayTot:SetText(AllTrim(Str(Len(aBrw))))
  	  	If Len(aBrw) == 0
			aAdd(aBrw,{"",""})
 		EndIf
		aSort(aBrw)
	EndIf
Else /// senao add Categorias.
	
	If ACU->(dbSeek(xFilial("ACU")+substr(cPrd,1,6)))
		If lAdd .and. substr(cPrd,8,1) <> "P"
			If Len(aBrw) == 1 .And. Empty(aBrw[1,1])
				aBrw[1,1] := ACU->ACU_COD
				aBrw[1,2] := ACU->ACU_DESC
			ElseIf aScan(aBrw,{|x| RTrim(x[1]) == RTrim(substr(cPrd,1,6))}) == 0
				aAdd(aBrw,{ACU->ACU_COD,ACU->ACU_DESC})
			EndIf
		Else
			nPos := aScan(aBrw,{|x| RTrim(x[1]) == RTrim(substr(cPrd,1,6))})
			If nPos > 0
				aDel(aBrw,nPos)
				aSize(aBrw,Len(aBrw)-1)
			EndIf
		EndIf
		oSayTot:SetText(AllTrim(Str(Len(aBrw))))
		If Len(aBrw) == 0
			aAdd(aBrw,{"",""})
		EndIf
		aSort(aBrw)
	EndIf
	
Endif


oBrw:nAt := 1
oBrw:Refresh()

Return (Nil)


//----------------------------------------------------------------
/*/{Protheus.doc} LjRetCatPr()
Retorna todas as categorias e suas categorias pai
Baseado na fun��o RetCatPrd() do Mata325.prw

@author  marisa.cruz
@version P12.1.27
@since   18.03.2021

@param	 nil

@return	 aClone(aTree), Array, a �rvore montada em categorias
/*/
//------------------------------------------------------------------
Function LjRetCatPr()
Local aTree     := {} //vetor com itens para a arvore                                             
Local aOrd      := ACU->(GetArea()) //armazena ordem atual da tabela   
Local cCod		:= ""

ACU->(dbSetOrder(1))		//ACU_FILIAL+ACU_COD
If ACU->(dbSeek(xFilial("ACU")))		//Pegar� sempre o come�o da categoria
	While ACU->(!Eof())
		If Empty(ACU->ACU_CODPAI)		//Somente categorias Grau Superior, sem marca��o de c�digo PAI
			cCod := ACU->ACU_COD
			aAdd(aTree,{ACU->ACU_COD,ACU->ACU_DESC,{}})
			addNodeTree(aTree[Len(aTree)][3],cCod)               	
		EndIf
		ACU->(DbSkip())
	EndDo
EndIf
    
RestArea(aOrd) 

Return aClone(aTree)


//----------------------------------------------------------------
/*/{Protheus.doc} AddNodeTree
Localizaremos c�digos categoria filho a partir dos c�digos pai, para na fun��o AddPrdTree(), atribuir todos os produtos na categ. filho
Baseado na fun��o Static AddNodeTree() do Mata325.prw

@author  marisa.cruz
@version P12.1.27
@since   18.03.2021

@param	 aTree, 		Array, 	�rvore Categoria/Produto - Vetor que ser� adicionado as �rvores filhas, e posteriormente em AddPrdTree(), os produtos
@param	 cCodPai,		String,	Receber� do LjCatRetPr() o c�digo corrente e se comportar� como c�digo pai no Tree

@return	 nil
/*/
//------------------------------------------------------------------
Static Function addNodeTree(aTree,cCodPai)
Local aOrd := ACU->(GetArea()) //armazena ordem atual da tabela

ACU->(dbSetOrder(2))		//ACU_FILIAL+ACU_CODPAI
//Iremos localizar c�digos categoria filho a partir dos c�digos pai, para na fun��o AddPrdTree(), atribuir todos os produtos na categ. filho
If (ACU->(dbSeek(xFilial("ACU")+cCodPai)))
	While !ACU->(EOF()) .AND. RTrim(ACU->ACU_CODPAI) == RTrim(cCodPai)
		aAdd(aTree,{ACU->ACU_COD,ACU->ACU_DESC,{}})
		addNodeTree(aTree[Len(aTree)][3],ACU->ACU_COD)                 
		ACU->(dbSkip())
	EndDo	
EndIf      
   
RestArea(aOrd)

Return nil
