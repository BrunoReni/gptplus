#include "PROTHEUS.CH"
#include "QIEA020.CH"
                                                                                                                         
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QIEA020	� Autor � Cleber Souza          � Data � 28/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Ensaios						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �  			                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001)   , "AxPesqui", 0, 1,,.F.},;  //"Pesquisar"	
					 {OemToAnsi(STR0002)   , "QE020Ens", 0, 2},;  //"Visualizar"	
					 {OemToAnsi(STR0003)   , "QE020Ens", 0, 3},;  //"Incluir"		
					 {OemToAnsi(STR0004)   , "QE020Ens", 0, 4},;  //"Alterar"		
					 {OemToAnsi(STR0005)   , "QE020Ens", 0, 5, 3} }  //"Excluir"

Return aRotina

Function QIEA020

//��������������������������������������������������������������Ŀ
//� Define Variaveis 										     �
//����������������������������������������������������������������
Private cEspecie := "QIEA020 "   // Para gravacao de textos
Private cFilDep  := xFilial("QAD") // Utilizada no SXB

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes	                 �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Ensaios"

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa 	 �
//� ----------- Elementos contidos por dimensao ------------	 �
//� 1. Nome a aparecer no cabecalho 							 �
//� 2. Nome da Rotina associada									 �
//� 3. Usado pela rotina										 �
//� 4. Tipo de Transa��o a ser efetuada							 �
//�	 1 - Pesquisa e Posiciona em um Banco de Dados				 �
//�	 2 - Simplesmente Mostra os Campos							 �
//�	 3 - Inclui registros no Bancos de Dados					 �
//�	 4 - Altera o registro corrente								 �
//�	 5 - Remove o registro corrente do Banco de Dados			 �
//����������������������������������������������������������������
PRIVATE aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE								     �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QE1")

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QE020Ens � Autor � Cleber Souza          � Data � 28/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Ensaios - Inclusao/Alteracao	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QE020Ens(ExpC1,ExpN1,ExpN2)								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo									  ���
���			 � ExpN1 = Numero do registro 								  ���
���			 � ExpN2 = Opcao selecionada								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEA020													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION QE020Ens(cAlias,nReg,nOpc)

Local nOpcA:=0  

Local oDlg
Local oEnsaio
Local oFont
Local oGroup1
Local oGroup2 
Local oTexto  
Local aAltera	:= {} 
Local nSeq		:= 0
Local aAreaAnt:= {}   
Local lCont	:= .F.
Local oSize

Private oGetNC
Private cTexto   := "" 
Private nPosNC   := 0
Private nPosCla  := 0
Private nPosDNC  := 0
Private nPosDCl  := 0    
Private lDuplDoc := .T.
Private lQE020EXE:= ExistBlock("QE020EXE")
Private nSaveSX8 := GetSX8Len()

RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.T.)

If !Empty(M->QE1_ENSAIO)
	nSeq := M->QE1_ENSAIO
Else
	nSeq := QA_SXESXF("QE1","QE1_ENSAIO",,1)
EndIf

If !Empty(QE1->QE1_CHAVE) .and. nOpc<>3
	cTexto := QA_RecTxt( QE1->QE1_CHAVE, cEspecie )
EndIf

// Validar se pode alterar ou excluir ensaio
If nOpc==4 .Or. nOpc==5
	If ExistBlock("QE020AENS") 
		lcont := Execblock("QE020AENS",.F.,.F.)	// PE para Permitir a altera��o do Ensaio mesmo existindo medi��es
	Endif
	If !lCont
		aAreaAnt := GetArea()
		DbSelectArea("QER")
		QER->(dbSetOrder(2))
		If QER->(dbSeek(xFilial("QER")+M->QE1_ENSAIO))
			Help(" ",1,"A020ENSMED")   // "Ensaio apresenta medicoes cadastradas"
			Return
		EndIf
		RestArea(aAreaAnt)
	EndIf
Endif

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo							 �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]
Private aHeader := {}
Private aCols	:= {}

oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"  ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS1" ,  100, 35, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS2" ,  100, 35, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE cCadastro ;//"Ensaios"
							FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

oEnsaio := MsMGet():New(cAlias,nReg,nOpc,,,,,;
							{oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI"),;
						 	oSize:GetDimension("ENCHOICE","LINEND") ,oSize:GetDimension("ENCHOICE","COLEND")};
						 	,,,,,,oDlg,,.T.,,,,,,,.T.)

/* Documenta��o dos parametros do Metodo FillGetDados
FillGetDados  (nOpc,; 			// numero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
               Alias,       	// area a ser utilizada;
               nOrdem,      	// ordem correspondente a chave de �ndice para preencher o  acols;
               cSeek,       	// chave utilizada no posicionamento da �rea para preencher o acols; 
               bSeekWhile,  	// bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While. 
               uSeekFor,    	// pode ser utilizados de duas maneiras:
							 	   1 - bloco-de-codigo, condicao a ser utilizado para executar o Loop no While;
							 	   2 - array bi-dimensional contendo N condicoes, em que o 1 elemento o bloco condicional, o 2 bloco a ser executado se verdadeiro e o 3 e bloco a ser executado se falso:
							 	   Exemplo:
							 	   {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
               aNoFields,   	// array contendo os campos que n�o estar�o no aHeader;
               aYesFields,  	// array contendo somente os campos que estar�o no aHeader;
               lOnlyYes,    	// se verdadeiro, exibe apenas os campos de usu�rio;
               cQuery,      	// query a ser executada para preencher o acols;
               bMontCols,    	// bloco contendo funcao especifica para preencher o aCols; 
               lEmpty,       	// 
               aHeaderAux,   	// 
               aColsAux,     	// 
               bAfterCols,   	// 
               bBeforeCols,  	// 
               bAfterHeader,    // 
               cAliasQry)       // 
*/

cWhile  := Alltrim(RetSIX("QE2","1",.T.,{"QE2_NAOCON"}))
cSeek 	:= RetSIX("QE1","1",.T.)

FillGetDados(	nOpc,; 							// numero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
               	"QE2",;       					// area a ser utilizada;
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

//����������������������������������������������������������������������Ŀ
//� Verifica a posicao dos campos no aHeadAux p/ posterior consistencia	 �
//������������������������������������������������������������������������
nPosNC  := Ascan(aHeader,{|x| x[2] = "QE2_NAOCON"})
nPosCla := Ascan(aHeader,{|x| x[2] = "QE2_CLASSE"})
nPosDNC := Ascan(aHeader,{|x| x[2] = "QE2_DESNCO"})
nPosDCl := Ascan(aHeader,{|x| x[2] = "QE2_DESCLA"})

QE020AfCols(  aHeader, @aCols, nOpc, nSeq )

@ oSize:GetDimension("GETDADOS1","LININI")+3,oSize:GetDimension("GETDADOS1","COLINI") GROUP oGroup1 TO ; //"Nao Conformidades"
			oSize:GetDimension("GETDADOS1","LINEND")-5,oSize:GetDimension("GETDADOS1","COLEND")-1 LABEL STR0007  OF oDlg PIXEL    
oGroup1:oFont:= oFont

oGetNC := MsNewGetDados():New(oSize:GetDimension("GETDADOS1","LININI")+10,oSize:GetDimension("GETDADOS1","COLINI")+3,;
						 oSize:GetDimension("GETDADOS1","LINEND")-6,oSize:GetDimension("GETDADOS1","COLEND")-5,;
						 Iif(nOpc==3 .Or. nOpc==4, GD_INSERT+GD_DELETE+GD_UPDATE, 0),"QE020LOk","QE020TOk","",,,,,,,oDlg,aHeader,aCols)

@ oSize:GetDimension("GETDADOS2","LININI"),oSize:GetDimension("GETDADOS2","COLINI") GROUP oGroup2 TO ; //"Metodo" 
				 oSize:GetDimension("GETDADOS2","LINEND"),oSize:GetDimension("GETDADOS2","COLEND")-1 LABEL STR0008  OF oDlg PIXEL    
oGroup2:oFont:= oFont

oTexto := TMultiGet():New(oSize:GetDimension("GETDADOS2","LININI")+7,oSize:GetDimension("GETDADOS2","COLINI")+4,;
									{|u| if(Pcount()>0,cTexto:=u,cTexto)} ,oDlg,oSize:GetDimension("GETDADOS2","XSIZE")-7,oSize:GetDimension("GETDADOS2","YSIZE")-11,,,,,,.T.,,,,,,IIf( nOpc==4 .Or. nOpc==3,.F.,.T.),,,,,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(Obrigatorio(aGets,aTela) .and. QE020VLDEL(nOpc) .and. FQIE020(),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{|| nOpcA:=0,oDlg:End()})

If nOpcA==1 .and. nOpc<>2
	QE020GrvAll(nOpc)
Else
	While (GetSX8Len() > nSaveSx8)
	    RollBackSX8()
	EndDo
EndIf

If lQE020EXE
	Execblock("QE020EXE",.F.,.F.,{"2",nOpc,nOpcA,nSeq})	
Endif

Return 
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �QE020AfCols �Autor  �Cicero Cruz         � Data �  17/01/04   ���
���������������������������������������������������������������������������͹��
���Desc.     � Rotina que carrega o aHeader e aCols da GetDados.            ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array com o Cabecalho da GetDados				    ���
���			 � ExpA2 = Array com as linhas da GetDados					    ���
���			 � ExpN1 = Opcao selecionada								    ���
���			 � ExpN2 = Sequencia do Ensaio								    ���
���������������������������������������������������������������������������Ĵ��
���Uso       � QIEA020                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function QE020AfCols( aHeader, aCols, nOpc, nSeq )
Local nLinha := 0

For nLinha := 1 to Len(aCols)
	aCols[nLinha,nPosDNC] := Iif(!Empty(aCols[nLinha,nPosNC]),A020DNCo(aCols[nLinha,nPosNC]),"")
	aCols[nLinha,nPosDCl] := Iif(!Empty(aCols[nLinha,nPosCla]),A040DCla(aCols[nLinha,nPosCla]),"")  
Next

//Ponto de entrada para codigo sequencial do ensaio
If ExistBlock("QE020EXE") 
	Execblock("QE020EXE",.F.,.F.,{"1",nOpc,If(INCLUI,3,4),nSeq})
Endif

Return  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QE020LOk � Autor � Cleber Souza           � Data � 28/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado. 						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QieA020													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QE020LOk(o)

Local lRet     := .T.
Local nAchou   := 0
Local aCols    := oGetNC:aCols
Local n        := oGetNC:nAT
Local cProcura := aCols[n,nPosNC]
Local nDel     := Len(oGetNC:aHeader)+1
                   
If !(aCols[n,nDel])

	//�������������������������������������������������������������Ŀ
	//� Verifica se campo NC esta' preenchido                       �
	//���������������������������������������������������������������
	If Empty(aCols[n,nPosNC])
		Help(" ",1,"QA_CPOOBR")
		lRet:=.F.	
	EndIf

	If lRet
		//�������������������������������������������������Ŀ
		//� Verifica se a NC ja' existe                     �
		//���������������������������������������������������
		nAchou := Ascan(aCols,{|x| x[nPosNC] == cProcura .And. !(x[Len(aCols[n])])})
		If nAchou > 0 .And. nAchou # n
			Help(" ",1,"A020EXINCE")
			lRet:=.F.
		EndIf
	EndIf

	//�������������������������������������������������Ŀ
	//� Verifica se a NC esta' cadastrada               �
	//���������������������������������������������������
	If lRet
		If ! ExistCpo("SAG",aCols[n,nPosNC])
			aCols[n,nPosNC] := Space(TamSX3("QP9_NAOCON")[1])
			lRet := .f.
		EndIf
	EndIf

	//�������������������������������������������������Ŀ
	//� Verifica se a Classe da NC esta' cadastrada     �
	//���������������������������������������������������
	If lRet
		If ! ExistCpo("QEE",aCols[n,nPosCla])
			lRet := .f.
		EndIf
	EndIf

EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QE020TOk� Autor � Cleber Souza            � Data � 28/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se toda a getdados esta' Ok                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado. 						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QieA020													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QE020TOk(o)
Local nI, lRet := .t.

For nI := 1 to Len(aCols)
	If ! QE020LOk(o)
		lRet := .f.
		Exit
	EndIf
Next

Return(lRet)  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QE020GrvAll �Autor  �Cleber Souza      � Data �  25/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de grava��o dos Ensaios, N�o Conformidade e Metodo. ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao selecionada								  ���
�������������������������������������������������������������������������͹��
���Uso       � QIEA020                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QE020GrvAll(nOpc)       

Local nX      := 0 
Local nY      := 0
Local cVar    := ""
Local nDel    := Len(oGetNC:aHeader)+1
Local aCols   := oGetNC:aCols
Local aHeader := oGetNC:aHeader  
Local cChave  := "" 
Local aTexto  := {}
Local aStruct

//��������������������������������������������������������������Ŀ
//� Atualiza os dados referentes ao Ensaio                       �
//����������������������������������������������������������������
RecLock("QE1",If(nOpc==3,.T.,.F.))
If (nOpc == 3 .Or. nOpc == 4) //Inclusao ou Alteracao
	
	aStruct := FWFormStruct(3,"QE1")[3] // Busca os campos usados (X3_USADO) da tabela
	For nX := 1 to Len(aStruct)
		If GetSx3Cache(aStruct[nX,1],"X3_CONTEXT") # "V"
			FieldPut(FieldPos(AllTrim(aStruct[nX,1])),&("M->"+aStruct[nX,1]))
		EndIf
	Next nX
	
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()   // Atualiza o ultimo roteiro em SX8
	Enddo
EndIf

If (nOpc == 3) //Inclusao
	QE1->QE1_FILIAL := xFilial("QE1")
	QE1->QE1_DTCAD  := dDataBase
EndIf
MsUnlock()

//��������������������������������������������������������������Ŀ
//� Grava Nao Conformidades Relacionadas ao Ensaio               �
//���������������������������������������������������������������� 

//����������������������������Ŀ
//� Grava o arquivo QE2 	   �
//������������������������������
For nX := 1 to Len(oGetNC:aCols)
	If !Empty(aCols[nX,nPosNC]) // Cod. NC nao vazio
		If !Acols[nX,nDel] .and. (nOpc==3 .or. nOpc==4)// Nao esta deletado 
			dbSelectArea("QE2")
			dbSetOrder(1)
			If dbSeek(xFilial("QE2") + QE1->QE1_ENSAIO + aCols[nX,nPosNC])         
				RecLock("QE2",.F.)   // Lock
			Else
				RecLock("QE2",.T.)   // Append
				QE2->QE2_FILIAL := xFilial("QE2")
				QE2->QE2_ENSAIO := QE1->QE1_ENSAIO
			Endif
			For nY := 1 to Len(aHeader)
				If aHeader[ny,10] # "V"
					cVar := Trim(aHeader[ny,2])
					Replace &cVar. With aCols[nx,ny]
				Endif
			Next nY
		Else
			//���������������������������������������Ŀ
			//� Cancela a NC no QE2 				  �
			//�����������������������������������������
			dbSelectArea("QE2")
			dbSetOrder(1)
			If dbSeek(xFilial("QE2") + QE1->QE1_ENSAIO + aCols[nX,nPosNC])         
				RecLock("QE2",.F.)
				dbDelete()
			EndIf
		EndIf
		MsUnlock()
	EndIf
Next nX        

//��������������������������������������������������������������Ŀ
//� Grava Metodo Informado.						                 �
//����������������������������������������������������������������
If  nOpc==3 .or. nOpc==4
	AADD(aTexto,{1,cTexto})
	If !Empty(cTexto)
		//��������������������������������������������������Ŀ
		//� Gera/Obtem a chave ligacao com o Texto do Ensaio �
		//����������������������������������������������������
		If Empty(QE1->QE1_CHAVE)
			cChave := QA_CvKey(xFilial("QE1")+QE1_ENSAIO,"QE1",2)
			// Grava a chave gerada
			RecLock("QE1",.F.)
			QE1->QE1_CHAVE := cChave
			MsUnLock()
		Else
			cChave := QE1->QE1_CHAVE
		Endif
		
		//����������������������������������������������������������Ŀ
		//� Grava Texto do Ensaio no QA2 							 �
		//������������������������������������������������������������
		QA_GrvTxt(cChave,cEspecie,1,aTexto) 	// QAXFUN
	Else
		If !Empty(QE1->QE1_CHAVE)
			QA_GrvTxt(QE1->QE1_CHAVE,cEspecie,1,aTexto) 	// QAXFUN
		EndIF
	EndIF
EndIf 


//�������������������������������������������������������������Ŀ
//� Na Rotina de exlus�o, Ensaio tem de ser excluido por ultimo �
//���������������������������������������������������������������
If (nOpc == 5)	
	dbSelectArea("QE1")
	RecLock("QE1",.F.)
	QE1->(dbDelete())
	MsUnlock()
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Qie020VqTd� Autor � Vera Lucia S. Simoes  � Data � 28.10.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o campo Qtde na entrada de dados					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � X3_VALID do campo QE1_QTDE 								  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qie020VqTd(cCarta,nQtde)

local lRetu := .t.
if cCarta $ 'HIS.XBR.XBS.XMR.IND'
	if nQtde < 2 .or. nQtde > 10
		lRetu := .f.
		Help(" ",1,"A020CARTAX")
	endif
elseif cCarta $ 'NP .C  '
	if nQtde == 0
		lRetu := .f.
		Help(" ",1,"A020CARTAC")
		M->QE1_QTDE := 1
	endif
else
	if nQtde <> 0
		lRetu := .f.
		Help(" ",1,"A020CARTAP")
		M->QE1_QTDE := 0
	endif
endif
return(lRetu)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Qie020VlNc� Autor � Vera Lucia S. Simoes  � Data � 09/12/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Nao Conformidade 							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Qie020VlNc(ExpC1)										  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Nao Conformidade						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico - E' chamada no X3_VALID do cpo. QE?_NAOCON - SX3 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qie020VlNc(cNC)
Local lRetu := .t., nI,;
		cVar := &(readvar()) // Conteudo da variavel do campo NC

//����������������������������������������������������������������Ŀ
//� Verifica se mudou a NC (Alterou o campo ja' digitado)          �
//������������������������������������������������������������������
If !Empty(aCols[n][nPosNC]) .and. !Empty(cVar) .and. aCols[n][nPosNC] <> cVar
	Help(" ",1,"A010ALTCHA")   // Campo nao pode ser alterado
	lRetu := .f.
EndIf

If lRetu
	//�������������������������������������������������Ŀ
	//� Verifica se a NC esta' cadastrada               �
	//���������������������������������������������������
	aCols[n][nPosNC] := cNc
	
	SAG->(dbSetOrder(1))
	If SAG->(dbSeek(xFilial("SAG")+cNc))
		aCols[n][nPosCla] := SAG->AG_CLASSE
	Else
		aCols[n][nPosNC] := Space(TamSX3("QE9_NAOCON")[1])
		lRetu := .f.
	EndIf
	
EndIf

//�������������������������������������������������Ŀ
//� Verifica se a NC ja' existe                     �
//���������������������������������������������������
If lRetu
	For nI := 1 to len(aCols)
		If cVar == acols[nI][nPosNC] .and. nI <> n // Se ja' existir este cod. NC
			Help(" ",1,"A020EXINCE")
			lRetu := .f.
		EndIf
	Next nI
EndIf

//�������������������������������������������������Ŀ
//� Preenche a Descricao da NC						�
//���������������������������������������������������
If lRetu
	aCols[n][nPosDNC] := A020DNCo(aCols[n][nPosNC])
EndIf

//�������������������������������������������������Ŀ
//� Preenche a Descricao da Classe					�
//���������������������������������������������������
If lRetu
	aCols[n][nPosDCl] := A040DCla(aCols[n][nPosCla])
EndIf

Return(lRetu)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Qie020VlCl� Autor � Vera Lucia S. Simoes  � Data � 09/12/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Classe da Nao Conformidade					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Qie020VlNc(ExpC1)										  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Classe da Nao Conformidade						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico - E' chamada no X3_VALID do cpo. QE?_CLASSE - SX3 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qie020VlCl(cClasse)
Local lRetu := .t.

//�������������������������������������������������Ŀ
//� Verifica se a Classe da NC esta' cadastrada     �
//���������������������������������������������������
aCols[n][nPosCla] := cClasse
If ! ExistCpo("QEE",aCols[n][nPosCla])
	lRetu := .f.
EndIf

//�������������������������������������������������Ŀ
//� Preenche a Descricao da Classe					�
//���������������������������������������������������
If lRetu
	aCols[n][nPosDCl] := A040DCla(aCols[n][nPosCla])
EndIf

Return(lRetu)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A020DNCo � Autor � Vera Lucia S. Simoes  � Data � 09.12.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a descricao da NC								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A020DNCo(cCodNC)
SAG->(dbSetOrder(1))
SAG->(dbSeek(xFilial("SAG") + cCodNC)) // NC posicionada na getdados
Return(SAG->AG_DESCPO)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Qie020WhQt� Autor � Vera Lucia S. Simoes  � Data � 09/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Determina X3_WHEN do campo QTDE de acordo com a Carta 	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QieA020 - Chamada pelo cpo. QE1_QTDE - X3_WHEN			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qie020WhQt()
Local lRetu := .t.

//�������������������������������������������������Ŀ
//� Verifica se a Carta permite entrada da Qtde 	�
//���������������������������������������������������
If ReadVar() == "M->QE1_QTDE"
	If M->QE1_CARTA $ 'P  .U  .TXT'
		lRetu := .f.
	EndIf

	//����������������������������������������������������������������Ŀ
	//� Se houver medicoes p/ o ensaio, nao altera a Qtde.			   �
	//������������������������������������������������������������������
	If lRetu
		QER->(dbSetOrder(2))
		If QER->(dbSeek(xFilial("QER")+M->QE1_ENSAIO))
			Help(" ",1,"A020ENSMED")   // "Ensaio apresenta medicoes cadastradas"
			lRetu := .f.
		EndIf
		QER->(dbSetOrder(1))
	EndIf
EndIf
Return(lRetu)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Qie020IqTd� Autor � Vera Lucia S. Simoes  � Data � 28.10.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa o campo Qtde na entrada de dados (X3_RELACAO)   ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Gatilho do campo QE1_QTDE, a partir do QE1_CARTA			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qie020IqTd(cCarta)

Local nQtde := nRetu := M->QE1_QTDE

If Empty(nQtde)
	//��������������������������������������������������������������Ŀ
	//� Se campo Qtde vazio, sugere as Qtdes defaults				 �
	//����������������������������������������������������������������
	If cCarta == 'IND'
		nRetu := 2
	ElseIf cCarta $ 'HIS.XBR.XBS.XMR'
		nRetu := 5
	ElseIf cCarta $ 'NP .C  '
		nRetu := 1
	Endif
EndIf

//������������������������������������������������������������Ŀ
//� Consiste o campo Qtde, porque pode ter alterado a Carta    �
//��������������������������������������������������������������
if cCarta $ 'HIS.XBR.XBS.XMR.IND'
	if nQtde < 2 .or. nQtde > 10
		nRetu := Iif(cCarta == 'IND',2,5)
	endif
elseif cCarta $ 'NP .C  '
	if nQtde == 0
		nRetu := 1
	endif
else
	if nQtde <> 0
		nRetu := 0
	endif
endif
Return(nRetu)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Qie020dCar� Autor � Vera Lucia S. Simoes  � Data � 28.01.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gatilho para preencher a descricao da Carta do Ensaio 	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Qie020dCar(ExpC1,ExpL1)									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Carta 									  ���
���			 � ExpL1 = Indica se e' gatilho                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico-Cham. no X3_RELACAO,X3_INIBRW e gat. (QE1_CARTA)  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qie020dCar(cCodCa,lGatilho)
lGatilho := Iif(lGatilho == NIL,.t.,lGatilho)

IF !Inclui .or. lGatilho	// Se Inic. Padrao ou gatilho a partir do cod. equipe
	Return(Tabela("Q4",cCodCa))
Else
	Return(Space(Len(X5Descri())))
Endif

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Qie020EnsC� Autor � Paulo Emidio de Barros� Data �16/04/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � habilita o campo somente para as cartas Individuais		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Qie020EnsC()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � X3_WHEN do QE1_TIPO										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qie020EnsC()
Local lRetorno := .F.

If M->QE1_CARTA $ "XBR/XBS/XMR/IND/HIS"  
	lRetorno := .T.   
Else
	M->QE1_TIPO := 	'2'
EndIf 

Return(lRetorno)   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QE020VLDEL� Autor � Cleber Souza          � Data �28/05/04  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � habilita o campo somente para as cartas Individuais		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Qie020EnsC()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao Selecionada								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEA020													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QE020VLDEL(nOpc)

Local lRet       := .T.
Local aFiliais   := {}
Local nY         := 0
Local cFilQE1    := xFilial("QE1")
Local lGestEmp   := ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() )

If nOpc == 5  
	
	If FWModeAccess("QE6") == "E"
		aFiliais := QA_RetFilEmp(SM0->M0_CODIGO) //Retorna as Filiais associadas a Empresa Atual	
	Else 
		AADD(aFiliais,{Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial()),Space(FWSizeFilial())}) //Space(2)
	EndIF                                                     
	If !(lGestEmp)
		For nY:=1 to Len(aFiliais)  
		    If aFiliais[nY,2]==cFilQE1 .or. FWModeAccess("QE1") == "C" //Empty(cFilQE1)
				dbSelectArea('QE7')  // Ensaios Mensuraveis do Produto
				dbSetOrder(3)
				dbSeek(aFiliais[nY,2] + QE1->QE1_ENSAIO)
				dbSetOrder(1)
				If Found()
					HELP(" ",1,"A020DENSPR",,QE7->QE7_PRODUT+' - '+QE7->QE7_REVI,3,1)
					dbSelectArea("QE1")
					lRet := .F. 
					Exit
				EndIf
			EndIf    
		Next nY
		
		If lRet
			For nY:=1 to Len(aFiliais)  
			    If aFiliais[nY,2]==cFilQE1 .or. FWModeAccess("QE1") == "C" //Empty(cFilQE1)
					dbSelectArea('QE8')  // Ensaios Textos do Produto
					dbSetOrder(3)
					dbSeek(aFiliais[nY,2] + QE1->QE1_ENSAIO)
					dbSetOrder(1)
					If Found()
						HELP(" ",1,"A020DENSPR",,QE8->QE8_PRODUT+' - '+QE8->QE8_REVI,3,1)
						dbSelectArea("QE1")
						lRet := .F. 
						Exit
					EndIf
				EndIF
			Next nY
		EndIf
	Else		
		dbSelectArea('QE7')  // Ensaios Mensuraveis do Produto
		dbSetOrder(3)
		dbSeek(cFilQE1 + QE1->QE1_ENSAIO)
		dbSetOrder(1)
		If Found()
			HELP(" ",1,"A020DENSPR",,QE7->QE7_PRODUT+' - '+QE7->QE7_REVI,3,1)
			dbSelectArea("QE1")
			lRet := .F. 
		EndIf		
		If lRet
			dbSelectArea('QE8')  // Ensaios Textos do Produto
			dbSetOrder(3)
			dbSeek(cFilQE1 + QE1->QE1_ENSAIO)
			dbSetOrder(1)
			If Found()
				HELP(" ",1,"A020DENSPR",,QE8->QE8_PRODUT+' - '+QE8->QE8_REVI,3,1)
				dbSelectArea("QE1")
				lRet := .F. 
			EndIf
		EndIf
	Endif 	
EndIf

Return(lRet)

/*/{Protheus.doc} FQIE020
Fun��o que valida a existencia de aspas simples no campo Ensaio 
@type function
@version  
@author thiago.rover
@since 15/04/2021
@return return_type, return_description
/*/
Static Function FQIE020()
Local lRet := .T.
Local nI   := 0

	If At('??',M->QE1_ENSAIO) != 0 // Foi identificado que com duas interroga��es, ocorre erro na gera��o de querys
		lRet := .F.  
	Else
		For nI:= 1 to len(M->QE1_ENSAIO)
			If cValTOChar(ASC(Substr(M->QE1_ENSAIO,nI,1)) ) $ '37|39' // ASC(" ' ") Aspas simples
				lRet := .F.  
				exit
			EndIf
		Next nI
	EndIf
	
	If !lRet
		Help("", 1, STR0009, NIL, STR0010, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011}) //#"ATEN��O" //#"Foi digitado algum caracter de controle" //#"Utilize outro caracter, evite aspas simples, caracteres especiais e operadores"
		Return .F. 
	EndIf


Return .T.
