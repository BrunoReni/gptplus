#Include "PROTHEUS.CH"
#Include "QIPA190.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA190  � Autor � Cleber Souza          � Data � 22/07/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Skip-Teste por Grupo            ���
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

Local aRotina := { 	{OemToAnsi(STR0001) ,"AxPesqui"    , 0 , 1,,.F.},;  //"Pesquisar" 
					{OemToAnsi(STR0002) ,"QIP190PROC"  , 0 , 2},;  //"Visualizar"
					{OemToAnsi(STR0003) ,"QIP190PROC"  , 0 , 3},;  //"Incluir"
					{OemToAnsi(STR0004) ,"QIP190PROC"  , 0 , 4},;  //"Alterar" 
					{OemToAnsi(STR0005) ,"QIP190PROC"  , 0 , 5 , 3 } } //"Excluir" 

Return aRotina

Function QIPA190
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006) //"Skip-Teste Grupo"  
PRIVATE __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
PRIVATE lProduto   := .F.


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
mBrowse( 6, 1,22,75,"QPI")

Return .T.  

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIP190PROC� Autor � Cleber Souza          � Data � 22/07/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao Skip-Teste por Grupo               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIP190PROC(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIP190PROC(cAlias,nReg,nOpc)

Local oDlg
Local oGetGru
Local oGetDesc
Local oGetRot  
Local oGroup1
Local oGroup2
Local oGetHis
Local nX            := 0   
Local nOpcA         := 1
Local cWhile  		:= '' 
Local cSeek 		:= ''                

Private oGet
Private aHeader     := {}
Private aCols       := {} 
Private aHistorico  := {} 
Private aEnsaios	:= {}
Private nPosEns		:= 0
Private nPosSkT		:= 0
Private nPosOper	:= 0
Private nPosChave	:= 0  
Private nPosAliWT   := 0
Private nPosRecWT   := 0
Private nUsado		:= 0
Private nHisAnt     := 1
Private cCod		:= ""
Private cGetHis     := ""
Private cGrupo   	:= Space(TamSX3("QPI_GRUPO")[1])
Private cDesGru  	:= Space(TamSX3("B1_DESC")[1])
Private cRoteiro	:= Space(TamSX3("QPI_CODREC")[1]) 
Private cEspecie	:= "QIPA190 "   //Utilizado para gravacao de textos

//��������������������������������������������������������������Ŀ
//� Monta vetor Aheader a ser utilizado na getdados              �
//����������������������������������������������������������������
FillGetDados(	nOpc,; 							// numero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
               	"QPI",;       					// area a ser utilizada;
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
nPosEns		:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPI_ENSAIO' } )
nPosSkT		:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPI_SKPTES' } )
nPosOper	:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPI_OPERAC' } )
nPosChave	:= ascan(aHeader, { |x| AllTrim(x[2]) == 'QPI_CHAVE'  } )
nPosAliWT   := Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPI_ALI_WT' } )
nPosRecWT   := Ascan(aHeader, { |x| AllTrim(x[2]) == 'QPI_REC_WT' } )

If nOpc # 3
	cGrupo   := QPI->QPI_GRUPO 
	cRoteiro := QPI->QPI_CODREC
	cDesGru  := POSICIONE('QP3',1,xFilial('QP3')+cGrupo,'QP3_DESCRI')
	QP190ENSA(nOpc)
EndIF	

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 150,3 TO 613,750 OF oMainWnd PIXEL //"Skip-Teste Grupo"
oDlg:lMaximized := .T.
                                                                                                          
@ 040,003 GROUP oGroup1 TO 075,605	LABEL "" OF oDlg PIXEL    
@ 130,003 GROUP oGroup2 TO 307,605	LABEL OemToAnsi(STR0010) OF oDlg PIXEL  //"Historico"

@ 045,010	SAY TitSX3("QPI_GRUPO")[1]	   SIZE 25,7 OF oDlg PIXEL	//"Produto"
@ 060,010	SAY OemToAnsi(STR0007)  SIZE 35,7 OF oDlg PIXEL  //"C�d. Roteiro"

@ 042,045	MSGET oGetGru VAR cGrupo	PICTURE PesqPict("QPI","QPI_GRUPO");
			VALID IIF(ExistCpo("QQC",cGrupo),(cDesGru:= POSICIONE('QP3',1,xFilial('QP3')+cGrupo,'QP3_DESCRI'),oGetDesc:Refresh()),.F.) ;
			When nOpc==3 F3 "QQC01" SIZE 66,10 OF oDlg PIXEL 

@ 042,116	MSGET oGetDesc VAR cDesGru	PICTURE PesqPict("QPI","QPI_GRUPO");
			When .F. SIZE 180,10 OF oDlg PIXEL

@ 057,045	MSGET oGetRot VAR cRoteiro PICTURE PesqPict("QPI","QPI_CODREC") VALID QP190ENSA(nOpc);
			When nOpc==3 SIZE 13,10 OF oDlg PIXEL

oGet:= MSGetDados():New(80,3,124,605,nOpc,"AllwaysTrue","AllWaysTrue","",.T.,,,,Len(aCols))    
oGet:oBrowse:bChange    := {|| IIF(Len(aHistorico)>0,(aHistorico[nHisAnt] := cGetHis, cGetHis:=aHistorico[N],nHisAnt:=N,oGetHis:Refresh()),.T.)}  
 
@ 138,007 GET oGetHis VAR cGetHis MEMO NO VSCROLL VALID .T. Size 595,168 When .T. Of oDlg Pixel 

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||oDlg:End(),IIF(oGet:TudoOK(),(nOpcA:=1,aHistorico[n]:=cGetHis),nOpcA:=2)},{||nOpcA:=2,oDlg:End()})

If nOpcA == 1
	QP190GrvAll(nOpc)	
EndIf

Return  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QP190Ens  � Autor � Marcelo Pimentel      � Data � 16/03/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QP190Ens(ExpN1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1: Opcao selecionada                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function QP190ENSA(nOpc)

Local nCnt		:= 0
Local nY        := 0 
Local nX        := 0 
Local nTamLin	:= TamSX3("QA2_TEXTO")[1]
Local nI	    := 0
Local nPos	    := 0
Local lRet 		:= .T.
Local lGrupo	:= .F.
Local aEnsAux   := aClone(aEnsaios)
Local aColsAux  := aClone(aCols)
Local axtextos	:= {}			//Vetor que contem os textos dos Produtos

If nOpc == 3
	If QPI->(dbSeek(xFilial("QPI")+cGrupo+cRoteiro))
		MsgAlert(OemToAnsi(STR0011),OemToAnsi(STR0009)) //"Ja existe Skip Teste definido para esse Produto x Roteiro." ###"Atencao"
		lRet := .F.
	EndIF
EndIF	

aEnsaios:= {}

//��������������������������������������������������������������Ŀ
//� Seleciona os Ensaios comuns dos Produtos deste Grupo         �
//����������������������������������������������������������������
If !Empty(cGrupo) .And. !Empty(cRoteiro) .and. lRet
	If QPA->(dbSeek(xFilial("QPA")+cGrupo))
		While QPA->QPA_FILIAL+QPA->QPA_GRUPO == xFilial("QPA")+cGrupo .And. !QPA->(Eof())
			
			//�������������������������������������������������������Ŀ
			//� Identifica a revis�o vigente do Produto               �
			//���������������������������������������������������������
			cRevi :=  QA_UltRevEsp(QPA->QPA_PRODUT,,,,"QIP")
			
			//�������������������������������������������������������Ŀ
			//� Identifica os ensaios mensur�veis.                    �
			//���������������������������������������������������������
			If QP7->(dbSeek(xFilial("QP7")+QPA->QPA_PRODUT+cRevi))
				While QP7->QP7_FILIAL+QP7->QP7_PRODUT+QP7->QP7_REVI+QP7->QP7_CODREC == ;
					xFilial("QP7")+QPA->QPA_PRODUT+cRevi+cRoteiro .And. !QP7->(Eof())
					
					nPos := Ascan(aEnsaios, { |x| x[1] == QP7->QP7_ENSAIO })
					If nPos == 0
						Aadd(aEnsaios,{QP7->QP7_ENSAIO,1,0,QP7->QP7_OPERAC})	//Ensaio/ocorr. / S.T. Indiv/OPERACAO
						nPos := Len(aEnsaios)
					Else
						aEnsaios[nPos,2]++
					EndIf
					If QPH->(dbSeek( xFilial("QPH")+QPA->QPA_PRODUT+cRoteiro+QP7->QP7_OPERAC+QP7->QP7_ENSAIO))
						aEnsaios[nPos,3] := QPH->QPH_SKPTES
					EndIf
					QP7->(dbSkip())
				EndDo
			EndIf
			
			//�������������������������������������������������������Ŀ
			//� Identifica os ensaios texto                           �
			//���������������������������������������������������������
			If QP8->(dbSeek(xFilial("QP8")+QPA->QPA_PRODUT+cRevi+cRoteiro))
				While QP8->QP8_FILIAL+QP8->QP8_PRODUT+QP8->QP8_REVI+QP8->QP8_CODREC == ;
					xFilial("QP8")+QPA->QPA_PRODUT+cRevi+cRoteiro .And. !QP8->(Eof())
					nPos := Ascan(aEnsaios, { |x| x[1] == QP8->QP8_ENSAIO})
					If nPos == 0
						Aadd(aEnsaios, { QP8->QP8_ENSAIO, 1, 0 ,QP8->QP8_OPERAC })	// Ensaio/ocorr. / S.T. Indiv/OPERACAO
						nPos := Len(aEnsaios)
					Else
						aEnsaios[nPos,2]++
					EndIf
					If QPH->(dbSeek( xFilial("QPH")+QPA->QPA_PRODUT+cRoteiro+QP8->QP8_OPERAC+QP8->QP8_ENSAIO))
						aEnsaios[nPos,3] := QPH->QPH_SKPTES
					EndIf
					QP8->(dbSkip())
				EndDo
			EndIf
			QPA->(dbSkip())
		EndDo
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Inicializa o aCols                                           �
	//����������������������������������������������������������������
	aCols := {}
	
	//������������������������������������������������������������������Ŀ
	//� Alimenta vetor aCols com os Ensaios comuns do Grupo              �
	//��������������������������������������������������������������������
	For nI := 1 to Len(aEnsaios)
		aadd(aCols,Array(nUsado+1))	// Cria novo elemento no acols
		nCnt := Len(aCols)
		// Alimenta o aCols
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPI_OPERAC'})] := aEnsaios[nI,4]
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPI_ENSAIO'})] := aEnsaios[nI,1]
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPI_DESENS'})] := QIPXDeEn(aEnsaios[nI,1])
		aCols[nCnt,ascan(aHeader,{|x| alltrim(x[2])=='QPI_SKPIND'})] := aEnsaios[nI,3]
		
		If QPI->(dbSeek(xFilial("QPI")+cGrupo+cRoteiro+aEnsaios[nI,4]+aEnsaios[nI,1]))
			aCols[nCnt,nPosSkT] := QPI->QPI_SKPTES
			aCols[nCnt,nPosChave]:= QPI->QPI_CHAVE
		Else
			aCols[nCnt,nPosSkT] := 0
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
							aCols[nCnt,nY] := &("QPI->"+aHeader[nY,2])
						EndIF
					EndIF
				EndIf
			EndIF	
		Next nY	
		If nPosAliWT > 0
			aCols[nCnt,nPosAliWT] := "QPI"
		EndIf
		If nPosRecWT > 0
			aCols[nCnt,nPosRecWT] := 0
			If aCols[nCnt,nPosSkT] > 0
				aCols[nCnt,nPosRecWT] := QPI->(RecNo())
			EndIf
		EndIf
		aCOLS[nCnt,nUsado+1] := .F.
	Next nI
	
	If Len(acols) > 0
		//��������������������������������������������������������������Ŀ
		//� Ordena Ensaios de acordo com o campo Ensaio                  �
		//����������������������������������������������������������������
		aCols := asort(aCols,,, { | x,y | x[nPosOper]+x[nPosEns] < y[nPosOper]+x[nPosEns]})
		If nOpc == 3 			//Inclus�o
			n   := 1
			oGet:ForceRefresh()
			oGet:oBrowse:SetFocus()
		EndIf
	
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
	
	Else
		lRet := .F.
	EndIf
EndIf

If !lRet
	MsgAlert(OemToAnsi(STR0008),OemToAnsi(STR0009))		//"Grupo de Produtos n�o tem ensaios em comum."###"Aten��o"
	aCols    := aClone(aColsAux)
	aEnsaios := aClone(aEnsAux)
EndIf

Return lRet

Return(lRet)  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A190GrvST � Autor � Cleber Souza          � Data � 10/08/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os Skip-Testes por Grupo                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QP190GrvAll(nOpc)
Local nx ,ny , nMaxArray := Len(aCols)
Local cChvQPZ
Local axtextos	:= {}			//Vetor que contem os textos dos Produtos

//���������������������������������������Ŀ
//� Grava o arquivo QPI                   �
//�����������������������������������������
For nX := 1 to nMaxArray
	dbSelectArea("QPI")
	axTextos := {}
	If !Acols[nX,nUsado+1]	.And.	!Empty(aCols[nX,nPosEns])  .And. ;
		!Empty(aCols[nX,nPosSkT]) .And. nOpc#5 
		
		If Empty(aCols[nX,nPosChave]) .and. !Empty(aHistorico[nX])
			aCols[nX,nPosChave] := QA_CvKey(xFilial("QPI")+cGrupo+cRoteiro+aCols[nX,nPosOper]+aCols[nX,nPosEns],"QPI", 3)
		EndIF
			
		//���������������������������������������Ŀ
		//� Grava Historico.				      �
		//����������������������������������������� 
		If !Empty(aCols[nX,nPosChave])
			Aadd(axTextos,{1,aHistorico[nX]})
			Qa_GrvTxt(aCols[nX,nPosChave],cEspecie,1,axTextos)   
		EndIf
		
		
		If dbSeek(xFilial("QPI")+cGrupo+cRoteiro+aCols[nX,nposOper]+aCols[nX,nPosEns])
			RecLock("QPI",.F.)   // Lock
		Else
			RecLock("QPI",.T.)   // Append
			QPI->QPI_FILIAL := xFilial("QPI")
			QPI->QPI_GRUPO  := cGrupo
			QPI->QPI_ENSAIO := aCols[nX,nPosEns]
			QPI->QPI_CODREC := cRoteiro
			QPI->QPI_OPERAC := aCols[nX,nPosOper]
		Endif

		For ny := 1 to Len(aHeader)
			If aHeader[ny,10] <> "V"
				cVar := alltrim(aHeader[ny,2])
				Replace &cVar. With aCols[nx,ny]
			Endif 
		Next ny
	Else	// Se cancelou ou alterou para zero
		//���������������������������������������Ŀ
		//� Cancela o Skip-Teste do Ensaio        �
		//�����������������������������������������
		If dbSeek(xFilial("QPI")+cGrupo+cRoteiro+aCols[nX,nPosOper]+aCols[nX,nPosEns])
			RecLock("QPI",.F.)
			dbDelete()
 
			//���������������������������������������������������������������Ŀ
			//� Deleta o Controle Skip-Teste por Grupo                        �
			//�����������������������������������������������������������������
			If QPO->(dbSeek(xFilial("QPO")+cGrupo+cRoteiro+aCols[nX,nPosOper]+aCols[nX,nPosEns]))
				RecLock("QPO", .F.)
				QPO->(dbDelete())
			EndIf

			//���������������������������������������������������������������Ŀ
			//� Deleta o Historico Skip-Teste do Ensaio                       �
			//�����������������������������������������������������������������
			cChvQPZ := QPI->QPI_GRUPO+cRoteiro+QPI->QPI_OPERAC+QPI->QPI_ENSAIO
			QPZ->(dbSetOrder(2))
			QPZ->(dbSeek(xFilial("QPZ")+cChvQPZ))
			While QPZ->QPZ_FILIAL+QPZ->QPZ_GRUPO+QPZ->QPZ_CODREC+QPZ->QPZ_OPERAC+QPZ->QPZ_ENSAIO ==;
					xFilial("QPZ")+cChvQPZ .And. !QPZ->(Eof())
				RecLock("QPZ", .F.)
				QPZ->(dbDelete())
				QPZ->(dbSkip())
			Enddo
			QPZ->(dbSetOrder(1))
		EndIf
	EndIf
Next nx

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A190WhST � Autor � Marcelo Pimentel      � Data � 16/03/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Define a clausula WHEN para o campo Skip-Teste             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A190WhST()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A190WhST()
Local lRetu := .t.,nPos 

//�����������������������������������������������������Ŀ
//� Verifica se j� definiu o skip-teste individual      �
//�������������������������������������������������������
If Len(aEnsaios) > 0
	nPos := Ascan(aEnsaios, { |x| x[1] == aCols[n,nPosEns] })
	If aEnsaios[nPos,3] <> 0
		Help(" ",1,"A130SKTIND")	//"Existe skip-teste individual definido para este ensaio"
		lRetu := .F.
	EndIf
EndIf
Return(lRetu)

