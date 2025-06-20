#Include "PROTHEUS.CH"
#Include "QIPA170.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA170  � Autor � Cleber Souza          � Data � 22/07/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Skip-Teste Individual           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { 		{OemToAnsi(STR0001) ,"AxPesqui"    , 0 , 1,,.F.},;  //"Pesquisar" 
						{OemToAnsi(STR0002) ,"QIP170PROC"  , 0 , 2},;  //"Visualizar"
						{OemToAnsi(STR0003) ,"QIP170PROC"  , 0 , 3},;  //"Incluir"
						{OemToAnsi(STR0004) ,"QIP170PROC"  , 0 , 4},;  //"Alterar" 
						{OemToAnsi(STR0005) ,"QIP170PROC"  , 0 , 5 , 3 } } //"Excluir" 

Return aRotina

Function QIPA170
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro   := OemtoAnsi(STR0006) //"Skip-Teste Individual"
PRIVATE lFase3      := ChkFile("QQ4") 
PRIVATE __cPRODUTO  := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
PRIVATE lProduto    := .F.

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//�    6 - Nao permite inclusao na getdados                      �
//����������������������������������������������������������������
PRIVATE aRotina:= MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QPH")

Return .T.  

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIP170PROC� Autor � Cleber Souza          � Data � 22/07/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao Skip-Teste Individual              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIP170PROC(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIP170PROC(cAlias,nReg,nOpc)

Local oDlg
Local oGetProd
Local oGetDesc
Local oGetRot  
Local oGroup1
Local oGroup2
Local oGetHis
Local oSize
Local nX            := 0   
Local nOpcA         := 1  
Local cWhile  := '' 
Local cSeek 	:= ''    
Local aPosObj		:= {}    
Local aPosGet		:= {}

Private oGet
Private aHeader     := {}
Private aCols       := {} 
Private aHistorico  := {}                              
Private nPosEns		:= 0
Private nPosSkT		:= 0
Private nPosOper	:= 0
Private nPosChave	:= 0
Private nUsado		:= 0
Private nHisAnt     := 1
Private cCod		:= ""
Private cGetHis     := ""
Private cProduto	:= Space(TamSX3("QPH_PRODUT")[1])
Private cDesPro  	:= Space(TamSX3("B1_DESC")[1])
Private cRoteiro	:= Space(TamSX3("QPH_CODREC")[1]) 
Private cEspecie	:= "QIPA170 "   //Utilizado para gravacao de textos




FillGetDados(	nOpc,; 							// numero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
               	"QPH",;       					// area a ser utilizada;
               	1,;      						// nOrdem - ordem correspondente a chave de �ndice para preencher o  acols;
               	Iif((nOpc == 3),"",&cSeek),;  	// chave utilizada no posicionamento da �rea para preencher o acols; 
               	{|| &cWhile},; 					// bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While. 
               	{|| .T.},;  					// uSeekFor
               	,;  						 	// aNoFields - array contendo os campos que n�o estarao no aHeader;
               	,;  							// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      						// se verdadeiro, exibe apenas os campos de usu�rio;
                '',;      						// cQuery - query a ser executada para preencher o acols;
               	,;    				   			// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpc == 3),.T.,.F.),;  	// lEmpty 
               	,; 								// aHeaderAux
               	,; 		   						// aColsAux
               	,; 								// bAfterCols
               	,; 								// bBeforeCols
               	,; 								// bAfterHeader
               	'') 							// cAliasQry
               	
nUsado := Len(aHeader)

//��������������������������������������������������������������Ŀ
//� Guarda as posicoes dos campos p/ posterior consistencia      �
//����������������������������������������������������������������
nPosEns		:= Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_ENSAIO' } )
nPosSkT		:= Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_SKPTES' } )
nPosOper		:= Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_OPERAC' } )
nPosChave		:= Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_CHAVE'  } )
nPosAliWT		:= Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_ALI_WT' } )
nPosRecWT		:= Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPH_REC_WT' } )

If nOpc # 3
	cProduto := QPH->QPH_PRODUT 
	cRoteiro := QPH->QPH_CODREC
	cDesPro  := QIPXDePr(cProduto)
	QP170ENSA(nOpc)
EndIF	

oSize := FwDefSize():New(.T.) 
                 
oSize:AddObject( "CABECALHO" ,  100, 35, .T.,.F.)
oSize:AddObject( "GETDADOS1" ,  100, 35, .T.,.T.) 
oSize:AddObject( "GETDADOS2" ,  100, 30, .T.,.T.)     
           
oSize:aMargins := { 3, 3, 0, 3 }

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; // "Plano de Amostragem por Ensaio"	 
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

@ oSize:GetDimension('CABECALHO'  , 'LININI'),oSize:GetDimension('CABECALHO'  , 'COLINI') GROUP oGroup1 TO ;
  oSize:GetDimension('CABECALHO'  , 'LINEND'),oSize:GetDimension('CABECALHO'  , 'COLEND')-5	LABEL "" OF oDlg PIXEL      
@ oSize:GetDimension('GETDADOS2'  , 'LININI'),oSize:GetDimension('GETDADOS2'  , 'COLINI') GROUP oGroup2 TO ;
  oSize:GetDimension('GETDADOS2'  , 'LINEND'),oSize:GetDimension('GETDADOS2'  , 'COLEND')-5	LABEL OemToAnsi(STR0012) OF oDlg PIXEL  //"Historico"


@ oSize:GetDimension('CABECALHO'  , 'LININI')+5,10 SAY TitSX3("QPH_PRODUT")[1] SIZE 35,7 OF oDlg PIXEL	//"Produto"
@ oSize:GetDimension('CABECALHO'  , 'LININI')+5,45 MSGET oGetProd VAR cProduto PICTURE PesqPict("QPH","QPH_PRODUT"); 
					VALID IIF(ExistCpo("QP6",cProduto),(cDesPro:= QIPXDePr(cProduto),oGetDesc:Refresh()),.F.);	
					When nOpc==3 F3 "QP6" SIZE 136,10 OF oDlg PIXEL
@ oSize:GetDimension('CABECALHO'  , 'LININI')+5,185 SAY OemToAnsi(STR0007)  SIZE 35,7 OF oDlg PIXEL		    //"C�d. Roteiro"
@ oSize:GetDimension('CABECALHO'  , 'LININI')+5,220 MSGET oGetRot VAR cRoteiro PICTURE PesqPict("QPH","QPH_CODREC");
					VALID QP170ENSA(nOpc) When nOpc==3 SIZE 13,10 OF oDlg PIXEL			
@ oSize:GetDimension('CABECALHO'  , 'LININI')+20,10 SAY OemToAnsi(STR0017)  SIZE 35,7 OF oDlg PIXEL		    //Descricao
@ oSize:GetDimension('CABECALHO'  , 'LININI')+20,45 MSGET oGetDesc VAR cDesPro	PICTURE PesqPict("QPH","QPH_PRODUT") When .F. SIZE 180,10 OF oDlg PIXEL	


oGet:= MSGetDados():New(oSize:GetDimension('GETDADOS1'  , 'LININI')+5,oSize:GetDimension('GETDADOS1'  , 'COLINI')+5,;
							oSize:GetDimension('GETDADOS1'  , 'LINEND')-5,oSize:GetDimension('GETDADOS1'  , 'COLEND')-5,;
							nOpc,"AllwaysTrue","AllWaysTrue","",.T.,,,,Len(aCols))    
oGet:oBrowse:bChange    := {|| IIF(Len(aHistorico)>0,(aHistorico[nHisAnt] := cGetHis, cGetHis:=aHistorico[N],nHisAnt:=N,oGetHis:Refresh()),.T.)}  


@ oSize:GetDimension('GETDADOS2'  , 'LININI')+10,oSize:GetDimension('GETDADOS2'  , 'COLINI')+5;
	GET oGetHis VAR cGetHis MEMO NO VSCROLL VALID .T. Size oSize:GetDimension('GETDADOS2'  , 'XSIZE')-20,oSize:GetDimension('GETDADOS2'  , 'YSIZE')-15;
	 When .T. Of oDlg Pixel 	


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||oDlg:End(),;
							IIF(oGet:TudoOK(),(nOpcA:=1,aHistorico[n]:=cGetHis),nOpcA:=2)},{||nOpcA:=2,oDlg:End()})

If nOpcA == 1
	A170GrvAll(nOpc)	
EndIf

Return  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QP170Ens  � Autor � Marcelo Pimentel      � Data � 16/03/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QP170Ens(ExpN1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1: Opcao selecionada                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function QP170ENSA(nOpc)

Local nCnt		:= 0
Local nY        := 0 
Local nX        := 0 
Local nTamLin	:= TamSX3("QA2_TEXTO")[1]
Local cGrupo	:= ''
Local lRetu		:= .T.
Local lGrupo	:= .F.
Local axtextos	:= {}			//Vetor que contem os textos dos Produtos 

If nOpc == 3
	If QPH->(dbSeek(xFilial("QPH")+cProduto+cRoteiro))
		MsgAlert(OemToAnsi(STR0013),OemToAnsi(STR0009)) //"Ja existe Skip Teste definido para esse Produto x Roteiro." ###"Atencao"
		lRetu := .F.
	EndIF
EndIF	

If !Empty(cProduto) .And. !Empty(cRoteiro) .And. lRetu
	aCols:={}
	//�����������������������������������������������������������������Ŀ
	//� Identifica a revisao vigente do Produto                         �
	//�������������������������������������������������������������������
	cRevi := QA_UltRevEsp(cProduto,,,,"QIP")	
	
	//�����������������������������������������������������������������Ŀ
	//� Alimenta vetor aCols com os Ensaios associados ao Produto       �
	//�������������������������������������������������������������������
	// Identifica o Grupo do Produto, se houver
	QPA->(dbSetOrder(2))
	If QPA->(dbSeek(xFilial("QPA")+cProduto))
		cGrupo := QPA->QPA_GRUPO		
	EndIf
	QPA->(dbSetOrder(1))

	//Ensaios mensuraveis
	dbSelectArea("QP7")
	dbSetOrder(1)
	dbSeek( xFilial("QP7")+cProduto+cRevi+cRoteiro)
	While !Eof() .And. QP7_FILIAL+QP7_PRODUT+QP7_REVI+QP7_CODREC == xFilial("QP7")+cProduto+cRevi+cRoteiro
		//�����������������������������������������������������������������Ŀ
		//� Verifica se existe operacoes por grupo relacionadas com o prod. �
		//�������������������������������������������������������������������
		If QQK->(dbSeek(xFilial("QQK")+Padr(cGrupo,15)+QP7->QP7_REVI+cRoteiro+QP7->QP7_OPERAC))
			lGrupo := .T.
		EndIf
		
		aadd(aCols,Array(nUsado+1))	// Cria novo elemento no acols
		nCnt := Len(aCols)
		
		//	Alimenta o aCols
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_ENSAIO'})] := QP7->QP7_ENSAIO
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_DESENS'})] := QIPXDeEn(QP7->QP7_ENSAIO)
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_OPERAC'})] := QP7->QP7_OPERAC
		
		If QPH->(dbSeek(xFilial("QPH")+cProduto+cRoteiro+QP7->QP7_OPERAC+QP7->QP7_ENSAIO))
			aCols[nCnt,nPosSkT]		:= QPH->QPH_SKPTES
			aCols[nCnt,nPosChave]	:= QPH->QPH_CHAVE
		Else
			aCols[nCnt,nPosSkT] := 0
		EndIf
		If QPI->(dbSeek( xFilial("QPI")+QPA->QPA_GRUPO+cRoteiro+QP7->QP7_OPERAC+QP7->QP7_ENSAIO))
			aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_SKPGRU'})] := QPI->QPI_SKPTES
		Else
			aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_SKPGRU'})] := 0
		EndIf 
		
		For nY:=1 to Len(aHeader)
			If Empty(aCols[nCnt,nY])
				If !Empty(GetSX3Cache(aHeader[nY,2],"X3_CAMPO"))
					If Empty(aCols[nCnt,nPosSkT])
						If Empty(GetSx3Cache(aHeader[nY,2], "X3_RELACAO"))         
					 		If GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "C"
					   	    		aCols[nCnt,nY] := Space(GetSx3Cache(aHeader[nY,2], "X3_TAMANHO"))
						   	Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "N"
					   	    		aCols[nCnt,nY] := 0
						    Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "D"
						        aCols[nCnt,nY] := dDataBase
						   	Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "M"
						        aCols[nCnt,nY] := ""
						    Else
						  	    aCols[nCnt,nY] := .F.
						    EndIf         
					 	Else
					 		aCols[nCnt,nY] :=InitPad(GetSx3Cache(aHeader[nY,2], "X3_RELACAO"))
					 	EndIF
					Else 
						If GetSx3Cache(aHeader[nY,2], "X3_CONTEXT")#"V" .and. GetSx3Cache(aHeader[nY,2], "X3_PROPRI") == "U"
							aCols[nCnt,nY] := &("QPH->"+aHeader[nY,2])
						EndIF
					EndIF
				EndIf
			EndIF	
		Next nY
		aCOLS[nCnt,nUsado+1] := .F.
		If nPosAliWT > 0
			aCols[nCnt,nPosAliWT] := "QPH"
		EndIf
		If nPosRecWT > 0
			If nOpc # 3
				aCols[nCnt,nPosRecWT] := QPH->(RecNo())
			Else
				aCols[nCnt,nPosRecWT] := 0
			EndIf
		EndIf
		dbSelectArea("QP7")
		dbSkip()
	Enddo
	//Ensaios Texto
	dbSelectArea("QP8")
	dbSeek( xFilial("QP8")+cProduto+cRevi+cRoteiro)
	While !Eof() .And. QP8_FILIAL+QP8_PRODUT+QP8_REVI+QP8_CODREC == xFilial("QP8")+cProduto+cRevi+cRoteiro
		aadd(aCols,Array(nUsado+1))	// Cria novo elemento no acols

		If QQK->( dbSeek( xFilial("QQK")+Padr(cGrupo,15)+QP8->QP8_REVI+cRoteiro+QP8->QP8_OPERAC ) )
			lGrupo := .T.
		EndIf
		
		nCnt := Len(aCols)
		// Alimenta o aCols
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_ENSAIO'})]:=QP8->QP8_ENSAIO
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_DESENS'})]:=QIPXDeEn(QP8->QP8_ENSAIO)
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_OPERAC'})]:=QP8->QP8_OPERAC
		
		If QPH->(dbSeek(xFilial("QPH")+cProduto+cRoteiro+QP8->QP8_OPERAC+QP8->QP8_ENSAIO))
			aCols[nCnt,nPosSkT]		:= QPH->QPH_SKPTES
			aCols[nCnt,nPosChave]	:= QPH->QPH_CHAVE
		Else
			aCols[nCnt,nPosSkT] := 0
		EndIf
		If QPI->(dbSeek( xFilial("QPI")+QPA->QPA_GRUPO+cRoteiro+QP8->QP8_OPERAC+QP8->QP8_ENSAIO))
			aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_SKPGRU'})] := QPI->QPI_SKPTES
		Else
			aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPH_SKPGRU'})] := 0
		EndIf 
		
		For nY:=1 to Len(aHeader)
			If Empty(aCols[nCnt,nY])
				
				If ( !Empty(GetSx3Cache(aHeader[nY,2], "X3_RELACAO")) )
					If Empty(aCols[nCnt,nPosSkT])
						If Empty(GetSx3Cache(aHeader[nY,2], "X3_RELACAO"))         
					 		If GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "C"
					   	    		aCols[nCnt,nY] := Space(GetSx3Cache(aHeader[nY,2], "X3_TAMANHO"))
						   	Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "N"
					   	    		aCols[nCnt,nY] := 0
						    Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "D"
						        aCols[nCnt,nY] := dDataBase
						   	Elseif  GetSx3Cache(aHeader[nY,2], "X3_TIPO") == "M"
						        aCols[nCnt,nY] := ""
						    Else
						  	    aCols[nCnt,nY] := .F.
						    EndIf         
					 	Else
					 		aCols[nCnt,nY] :=InitPad(GetSx3Cache(aHeader[nY,2], "X3_RELACAO"))
					 	EndIF
					Else 
						If GetSx3Cache(aHeader[nY,2], "X3_CONTEXT")#"V" .and. GetSx3Cache(aHeader[nY,2], "X3_PROPRI") == "U"
							aCols[nCnt,nY] := &("QPH->"+aHeader[nY,2])
						EndIF
					EndIF
				EndIf
			EndIF	
		Next nY
		aCOLS[nCnt,nUsado+1] := .F. 
		If nPosAliWT > 0
			aCols[nCnt,nPosAliWT] := "QPH"
		EndIf
		If nPosRecWT > 0
			If nOpc # 3
				aCols[nCnt,nPosRecWT] := QPH->(RecNo())
			Else
				aCols[nCnt,nPosRecWT] := 0
			EndIf
		EndIf		
		dbSelectArea("QP8")
		dbSkip()
	Enddo
	//��������������������������������������������������������������Ŀ
	//� Ordena Ensaios de acordo com o campo Ensaio                  �
	//����������������������������������������������������������������
	aCols := asort(aCols,,, { | x,y | x[nPosOper]+x[nPosEns] < y[nPosOper]+x[nPosEns]})
	
	// Posiciona o arquivo de Skip-Teste Individual
	dbSelectArea("QPH")
	dbseek(xFilial()+cProduto)
EndIf	

If lRetu
	//��������������������������������������������������������������Ŀ
	//� Monta Array com os Historicos relacionados aos Ensaios.		 �
	//����������������������������������������������������������������
	If Len(aCols) > 0
		
		For nX:=1 to Len(aCols)
			//����������������������������������������������������������Ŀ
			//� Gera/obtem a chave de ligacao com o texto do Produto/Rv  �
			//������������������������������������������������������������
			If Empty(aCols[nX,nPosChave])
				AADD(aHistorico,"")
			Else
				AADD(aHistorico,QA_RecTxt(aCols[nX,nPosChave],cEspecie))
			EndIf
		Next nX
		cGetHis := aHistorico[1]
		
	EndIF
	
	If Len(aCols) == 0 .Or. lGrupo
		If lGrupo
			MsgAlert(OemToAnsi(STR0010),OemToAnsi(STR0009)) //"Seq.Opera��o est� relacionada com roteiro por grupo."###"Aten��o"
		Else
			MsgAlert(OemToAnsi(STR0011),OemToAnsi(STR0009)) //"Produto/Revis�o n�o tem ensaios relacionados."###"Aten��o"
		EndIf
		lRetu:= .F.
	Else
		If nOpc == 3		//Inclus�o
			n:=1
			oGet:ForceRefresh()
		EndIf
	EndIf
	
EndIf

Return(lRetu)  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A170GrvST � Autor � Marcelo Pimentel      � Data � 16/03/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os Skip-Testes Individuais                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A170GrvAll(nOpc)
Local nx ,ny , nMaxArray:=Len(aCols)
Local cChvQPY
Local axtextos	:= {}			//Vetor que contem os textos dos Produtos
Local nDel:= len(aheader)+1

If ExistBlock("QP170GRV")
	ExecBlock("QP170GRV",.F.,.F.,{cProduto,cRoteiro})
Endif

//���������������������������������������Ŀ
//� Grava o arquivo QPH                   �
//�����������������������������������������
For nX := 1 to nMaxArray
	If nMaxArray == 1 .And. aCols[nX,nPosSkT] == 0 .And. aCols[nX,ndel] == .F. .And. (nOpc == 4 .Or. nOpc == 3)
		msgalert(OemToAnsi(STR0016),OemToAnsi(STR0009))
	Endif
	dbSelectArea("QPH")
	axTextos := {}
	If !Acols[nX,nUsado+1] .And. nOpc#5
		If !Empty(aCols[nX,nPosSkT]).And. aCols[nX,nPosSkT] <> 0 .And.!Empty(cProduto).And.;
			!Empty(cRoteiro) .And. !Empty(aCols[nX,nPosEns]) 
			
			If Empty(aCols[nX,nPosChave]) .and. !Empty(aHistorico[nX])
				aCols[nX,nPosChave] := QA_CvKey(xFilial("QPH")+cProduto+cRoteiro+aCols[nX,nPosOper]+aCols[nX,nPosEns],"QPH", 3)
			EndIF
			
			//���������������������������������������Ŀ
			//� Grava Historico.				      �
			//����������������������������������������� 
			If !Empty(aCols[nX,nPosChave])
				Aadd(axTextos,{1,aHistorico[nX]})
				Qa_GrvTxt(aCols[nX,nPosChave],cEspecie,1,axTextos)   
			EndIf

			If dbSeek(xFilial("QPH")+cProduto+cRoteiro+aCols[nX,nPosOper]+aCols[nX,nPosEns])
				RecLock("QPH",.F.)   // Lock
				QPH->QPH_SKPTES := aCols[nX,4]
				QPH->QPH_CHAVE  := aCols[nX,nPosChave]
			Else
				RecLock("QPH",.T.)   // Append
				QPH->QPH_FILIAL := xFilial("QPH")
				QPH->QPH_PRODUT := cProduto
				QPH->QPH_ENSAIO := aCols[nX,nPosEns]
				QPH->QPH_CODREC := cRoteiro
				QPH->QPH_OPERAC := aCols[nX,nPosOper]
				QPH->QPH_SKPTES := aCols[nX,nPosSkT]   
				QPH->QPH_CHAVE  := aCols[nX,nPosChave]
			Endif
		
			For ny := 1 to Len(aHeader)
				If aHeader[ny,10] <> "V"
					cVar := alltrim(aHeader[ny,2])
					Replace &cVar. With aCols[nx,ny]
				Endif 
			Next ny 
			MsUnlock()
		EndIf	
	Else			//Se cancelou ou alterou para zero
		//���������������������������������������Ŀ
		//� Cancela o Skip-Teste do Ensaio        �
		//�����������������������������������������
		If dbSeek(xFilial("QPH")+cProduto+cRoteiro+aCols[nX,nPosOper]+aCols[nX,nPosEns])
			RecLock("QPH",.F.)
			dbDelete()

			//���������������������������������������������������������������Ŀ
			//� Deleta o Controle Skip-Teste Individual                       �
			//�����������������������������������������������������������������
			If QPN->(dbSeek(xFilial("QPN")+cProduto+cRoteiro+aCols[nX,nPosOper]+aCols[nX,nPosEns]))
				RecLock("QPN", .F.)
				QPN->(dbDelete()) 
			EndIf
			
			//���������������������������������������������������������������Ŀ
			//� Deleta o Historico Skip-Teste do Ensaio                       �
			//�����������������������������������������������������������������
			cChvQPY := QPH->QPH_PRODUT+cRoteiro+aCols[nX,nPosOper]+QPH->QPH_ENSAIO
			QPY->(dbSetOrder(2))
			QPY->(dbSeek(xFilial("QPY")+cChvQPY))
			While QPY->QPY_FILIAL+QPY->QPY_PRODUT+QPY->QPY_CODREC+QPY->QPY_OPERAC+QPY->QPY_ENSAIO ==;
				xFilial("QPY")+cChvQPY .And. !QPY->(Eof())
				RecLock("QPY", .F.)
				QPY->(dbDelete())
				QPY->(dbSkip())
			Enddo
			QPY->(dbSetOrder(1))
		EndIf
	EndIf
Next nx
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A170WhST � Autor � Marcelo Pimentel      � Data � 16/03/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Define a clausula WHEN para o campo Skip-Teste             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A170WhST()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A170WhST()
Local lRetu := .t.

//�����������������������������������������������������Ŀ
//� Verifica se j� definiu o skip-teste por grupo       �
//�������������������������������������������������������
QPA->(dbSetOrder(2))
If QPA->(dbSeek(xFilial("QPA")+cProduto))
	If QPI->(dbSeek( xFilial("QPI")+QPA->QPA_GRUPO+cRoteiro+aCols[n,nPosOper]+aCols[n,nPosEns]))
		MsgInfo(OemToAnsi(STR0008),OemToAnsi(STR0009))	// "O Skip-Teste referente a ensaio est� definido por grupo."###"Aten��o"
		lRetu := .F.
	EndIf
EndIf
QPA->(dbSetOrder(1))
Return(lRetu) 

