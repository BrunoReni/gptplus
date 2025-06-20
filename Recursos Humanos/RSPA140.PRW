#include "Protheus.ch"
#include "font.ch"
#include "colors.ch"
#include "RSPA140.CH"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � RSPA140  � Autor � Cristina Ogura          � Data � 12.11.98 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Processo Seletivo                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSPA140                                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � RSPA140                                                      ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���Cecilia Car.�29/07/2014�TQENN4�Incluido o fonte da 11 para a 12 e efetua-���
���            �          �      �da a limpeza.                             ���
���Matheus M  .�02/02/2016�TUBJ78�Reealizado valida��o no momento da exclu- ���
���            �          �      �s�o do processo, para verificar se o mesmo���
���            �          �      �est� v�nculado � uma vaga.				���
���Caio C. F.  �06/07/2017�MPRIMESP-10572� Ajuste para n�o gerar error.log  ���
���            �          �      �ao visualizar um processo seletivo na     ���
���            �          �      �consulta(F3) de uma aprova��o de processo.���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function RSPA140

LOCAL cFiltraSQE	:= ""			//Variavel para filtro

Private aIndexSQE	:= {}			//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}		//Variavel para Filtro

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0006) //"Processo Seletivo"

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("SQE")
dbSetOrder(1)
cFiltraRh 	:= "QE_ITEM == '01'"
bFiltraBrw 	:= {|| FilBrowse("SQE",@aIndexSQE,@cFiltraRH) }
Eval(bFiltraBrw)

dbSelectArea("SQE")
dbGotop()  

mBrowse(6, 1, 22, 75, "SQE")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("SQE",aIndexSQE)
      
dbSelectArea("SQE") 
dbSetOrder(1)

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Rs140Rot  � Autor � Cristina Ogura       � Data � 12.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta o calendario dos treinamentos                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1  : Alias do arquivo                                  ���
���          � ExpN1  : Registro do arquivo                               ���
���          � ExpN2  : Opcao do aRotina                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RSPA140	     �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Rs140Rot(cAlias,nReg,nOpcx)
Local oDlgMain, oGet
Local lRsDel	:= If(nOpcx=2 .Or. nOpcx==5 ,.F.,.T.)
Local aAlter	:= {}
Local cProcesso	:= ""
Local cDescri	:= ""
Local cChave	:= ""
Local cFil		:= ""
Local nOpca		:= 0

//��������������������������������������������������������������Ŀ
//� Variaveis para Dimensionar Tela		                         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

//Variaveis para Walk Thru
Local aNoFields := {"QE_FILIAL","QE_PROCESS","QE_DESCRIC","QE_ITEM"}
Local cCond		:= "SQE->QE_FILIAL+SQE->QE_PROCESS"
Local nSqeOrd	:= RetOrdem("SQE",cCond)
Local bSeekWhile:= {|| SQE->QE_FILIAL + SQE->QE_PROCESS }

// Private da Getdados
Private aCols  		:= {}
Private aHeader		:= {}

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("SQE",aIndexSQE)
aIndexSQE := {}
dbGoto(nReg)

// Verifica os campos que podem ser alterados
Rs140Alter(@aAlter)

If nOpcx # 3				// Diferente de Inclusao
	cChave 		:= SQE->QE_FILIAL+SQE->QE_PROCESS
	cProcesso	:= SQE->QE_PROCESS
	cDescri		:= SQE->QE_DESCRIC
Else
	cFil 		:= xFilial("SQE")           
	cProcesso	:= CriaVar("QE_PROCESS")
	cChave 		:= cFil+cProcesso
	cDescri		:= CriaVar("QE_DESCRIC")
EndIf
              
//==> Monta FilGetDados para Walk Thru
FillGetDados(nOpcx					,; //1-nOpcx - n�mero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
			 "SQE"					,; //2-cAlias - area a ser utilizada;
			 nSqeOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			 cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			 bSeekWhile				,; //5-bSeekWhile - bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While.
			 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-c�digo, condi��o a ser utilizado para executar o Loop no While;2� - array bi-dimensional contendo N.. condi��es, em que o 1� elemento � o bloco condicional, o 2� � bloco a ser executado se verdadeiro e o 3� � bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
			 aNoFields				,; //7-aNoFields - array contendo os campos que n�o estar�o no aHeader;
			 NIL					,; //8-aYesFields - array contendo somente os campos que estar�o no aHeader;
			 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usu�rio;
			 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
			 NIL					,; //11-bMontCols - bloco contendo fun��o especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
			 nOpcx==3				,;	//nOpcx==3 12-lEmpty � Caso True ( default � false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclus�o).
			 NIL					,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como vari�veis locais ( v�rias getdados por exemplo; uso da MSNewgetdados )
			 NIL					)  //14-aColsAux eh Caso necessite tratar o aheader e acols como vari�veis locais ( v�rias getdados por exemplo; uso da MSNewgetdados )


/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 025 , .T. , .F. } )					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL

@ aObjSize[1,1],	aObjSize[1,2] 	TO aObjSize[1,3],aObjSize[1,4] OF oDlgMain PIXEL
@ aObjSize[1,1]+10,	aObjSize[1,2]+5		SAY OemToAnsi(STR0007) 			SIZE 150,7 PIXEL		//"Processo: "
@ aObjSize[1,1]+10, aObjSize[1,2]+38 	MSGET cProcesso VALID Rs140Ver(cProcesso) SIZE 20,7 PIXEL WHEN nOpcx == 3
@ aObjSize[1,1]+10, aObjSize[1,2]+65 	MSGET cDescri   PICTURE "@!"	SIZE 200,7 PIXEL WHEN nOpcx == 3 .Or. nOpcx == 4

oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,"Rs140LinOK","Rs140LinOk","",lRsDel,aAlter, , ,900,,,,,oDlgMain)

ACTIVATE MSDIALOG oDlgMain ON INIT (EnchoiceBar(oDlgMain,{||If(oGet:TudoOK() .And. Rs140tok(cDescri),(nOpca:=1,oDlgMain:End()),nOpca:=2)},{|| nOpca := 2,oDlgMain:End()}))

If nOpca == 1
	If nOpcx # 2	// Se nao for visualizacao
		Begin Transaction
			Rs140Grava("SQE",nReg,nOpcx,cProcesso,cDescri)
			If __lSX8
				ConfirmSx8()
			EndIf
			EvalTrigger()
		End Transaction
	EndIf
Else
	If __lSX8
		RollBackSX8()
	EndIf
EndIf 

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
Eval(bFiltraBrw)
dbGoto(nReg)

Return(Nil)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs140Grava� Autor � Cristina Ogura        � Data � 20.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava os registros referente ao treinamentos                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias do arquivo                                   ���
���          � ExpN1 : Registro do arquivo                                ���
���          � ExpN2 : Opcao do aRotina                                   ���
���          � ExpC2 : Processo selecionado                               ���
���          � ExpC3 : Descricao do processo                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �RSPA140                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Rs140Grava(cAlias,nReg,nOpcx,cProcesso,cDescri)
Local nPosRec			:= GdfieldPos("QE_REC_WT")
Local nx				:= 0
Local ny				:= 0 
Local nItem				:= 0  
Local lChkDelOk 		:= .F.
Local lVld				:= .F.
Local lTravou

If nOpcx == 2		// Visualizacao
	Return .T.
Else
	dbSelectArea(cAlias) 
	For nx :=1 to Len(aCols)
		Begin Transaction 
			If aCols[nx][nPosRec]>0
				MsGoto(aCols[nX][nPosRec])
				If nOpcx == 5
					( cAlias )->( MsGoto( nReg ) )
						lChkDelOk	:=  		ChkDelRegs(	cAlias				,;	//Alias do Arquivo Principal
							nReg				,;	//Registro do Arquivo Principal
							NIL					,;	//Opcao para a AxDeleta
							NIL					,;	//Filial do Arquivo principal para Delecao
							NIL					,;	//Chave do Arquivo Principal para Delecao
							NIL					,;	//Array contendo informacoes dos arquivos a serem pesquisados
							NIL					,;	//Mensagem para MsgYesNo
							NIL					,;	//Titulo do Log de Delecao
							NIL					,;	//Mensagem para o corpo do Log
							.F.				 	,;	//Se executa AxDeleta
							.T.     			,;	//Se deve Mostrar o Log
							NIL					,;	//Array com o Log de Exclusao
							NIL				 	,;	//Array com o Titulo do Log
							NIL					,;	//Bloco para Posicionamento no Arquivo
							NIL					,;	//Bloco para a Condicao While
							NIL					,;	//Bloco para Skip/Loop no While
							NIL					,;	//Verifica os Relacionamentos no SX9
							Nil					,;	//Alias que nao deverao ser Verificados no SX9
							NIL				 	,;	//Se faz uma checagem soft
							NIL			 		;  //Se esta executando rotina automatica
						)
																	
						If lChkDelOk 
							RecLock(cAlias,.F.)
								DbDelete()
							MsUnlock()		
						Else
							lVld := .T.
						EndIF
					lTravou:=.F.
				Else
					RecLock(cAlias,.F.)
					lTravou:=.T.
				EndIf
			Else
			    If !(aCols[nX][Len(aCols[nX])])
					RecLock(cAlias,.T.)
					lTravou:=.T.
				EndIf
			EndIf
			If lTravou   
				//--Verifica se esta deletado
				If aCols[nx][Len(aCols[nx])] 
					lChkDelOk	:= ChkDelRegs(cAlias)
					If lChkDelOk
						DbDelete()
					EndIF
		        Else  
		        	nItem++
					Replace SQE->QE_FILIAL 	With xFilial(cAlias)
					Replace SQE->QE_PROCESS	With cProcesso			
					Replace SQE->QE_DESCRIC	With cDescri
					Replace SQE->QE_ITEM	With Strzero(nItem,TamSx3("QE_ITEM")[1])				
					For ny := 1 To Len(aHeader)
						If aHeader[ny][10] <> "V"
							SQE->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nx][ny]))
						EndIf	
					Next nY
				EndIf
				MsUnlock()  
				lTravou:=.F.
			EndIf	
    	End Transaction
    	If nOpcx == 5 
    		If lVld 
    			Exit
    		ElseIF lTravou == .F.
    			Exit
    		EndIF 
    	EndIF   	
	Next nx
EndIf

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Rs140Alter � Autor � Cristina Ogura      � Data � 12.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica os campos que podem ser alterados na getdados     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Rs140Alter                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 : Array com os campos                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RSPA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Rs140Alter(aAlter)
Local aSaveArea	:= GetArea()

Aadd(aAlter,"QE_TPPROCE")
Aadd(aAlter,"QE_DESCTP")
Aadd(aAlter,"QE_TESTE")
Aadd(aAlter,"QE_DESCTES")

dbSelectArea("SX3")
dbSeek("SQE")
While !Eof() .And. (X3_ARQUIVO == "SQE")
	If X3_PROPRI == "U"
		Aadd(aAlter,X3_CAMPO)
	EndIf
	dbSkip()
EndDo

RestArea(aSaveArea)

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Rs140Linok� Autor � Cristina Ogura       � Data � 12.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Linha Ok da getdados                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       �RSPA140        �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Rs140LinOk()
Local nPosTp 	:= GdFieldPos("QE_TPPROCE")
Local nPosTeste := GdFieldPos("QE_TESTE")
Local nUsa		:= Len(aCols[n])
Local nCont		:= 0

If aCols[n,nUsa] == .F.
	Aeval(aCols,{ |X| If( X[nPosTp]+X[nPosTeste] == aCols[N,nPosTp]+aCols[N,nPosTeste].And.;
	x[nUsa] == .F. , nCont ++,nCont )})
EndIf  

//Verifica se tipo do processo seletivo foi preenchido
If ( nPosTp > 0 .And. Empty(aCols[n][nPosTp]) )
	AVISO(OemToAnsi(STR0008),OemToAnsi(STR0011),{"OK"})	//"Atencao","O Tipo do Processo Seletivo deve ser preenchido."
	Return .F.
EndIf
	
If nCont > 1
	Help("",1,"Rs140Tp")			// Tipo de processo ja cadastrado neste processo
	Return .F.
EndIf

Return .T.  


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Rs140Desc � Autor � Cristina Ogura       � Data � 12.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a descricao dos campos                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 : Opcao para retornar a descricao                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       �RSPA140        �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Rs140Desc(nQual)
Local aSaveArea	:= GetArea()
Local nPosTp 	:= GdFieldPos("QE_DESCTP")
Local nPosTeste := GdFieldPos("QE_DESCTES")
Local cVar		:= &(ReadVar())
Local cRet		:= Space(30)

If nQual == 1			// Descricao do Tipo de Processo
	dbSelectArea("SX5")
	If dbSeek(xFilial("SX5")+"R9"+cVar)
		cRet := Substr(X5Descri(),1,30)
		aCols[n][nPosTp] := cRet
	EndIf
ElseIf nQual == 2		// Descricao do Teste
	If !Empty(cVar)
		dbSelectArea("SQQ")
		dbSetOrder(1)
		If dbSeek(xFilial("SQQ")+cVar)
			cRet := Substr(SQQ->QQ_DESCRIC,1,30)
		EndIf
	EndIf
	aCols[n][nPosTeste]:= cRet
EndIf

RestArea(aSaveArea)

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Rs140Ver � Autor � Emerson Grassi Rocha  � Data � 09/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica Validacao do Codigo do Processo Seletivo.         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Rs140Ver()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RSPA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Rs140Ver(cProcesso)
Local aSaveArea := GetArea()

If Empty(cProcesso)
	Aviso(STR0008, STR0010, {"Ok"})	// "Atencao"###"Codigo do Processo deve ser informado"
	RestArea(aSaveArea)
	Return .F.
EndIf

dbSelectArea("SQE") 
dbSetOrder(1)
If dbSeek(xFilial("SQE")+cProcesso)
	Aviso(STR0008, STR0009, {"Ok"})	// "Atencao"###"Processo Seletivo ja cadastrado"
	RestArea(aSaveArea)
	Return .F.
EndIf

If !FreeForUse("SQE",cProcesso)
	RestArea(aSaveArea)
	Return .F.
EndIf
          
RestArea(aSaveArea)
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Rs140tok  � Autor � Eduardo Ju            � Data � 09.12.04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Verifica se campo descricao esta preenchido.                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Rs140tok                                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       �RSPA140                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Rs140tok(cDescri)

Local aSaveArea:= GetArea()
Local lRet		:= .T.

If Empty(cDescri)
	AVISO(OemToAnsi(STR0008),OemToAnsi(STR0012),{"OK"})	//"Atencao","A Descri��o do Processo Seletivo deve ser preenchida."
	lRet := .F.
EndIf			
               
RestArea(aSaveArea)

Return lRet			


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �Rs140Sx3Des�Autor  �Tania Bronzeri      � Data � 19/12/2006  ���
��������������������������������������������������������������������������͹��
���Desc.     �Busca descricao dos campos para Get Dados                    ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �SIGARSP                                                      ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function Rs140Sx3Des(cAliasSx3,cCampo,cDesc,cBusca,cTab)
Local nPos			:= 0
Local cRet			:= ""           
Default cAliasSx3	:= "SQE"
Default cTab		:= ""                

If Type("aHeader") != "U"
	nPos	:= GdFieldPos(cCampo)
EndIf

If Type("aCols") != "U" .And. Len(aCols)>0 .And. nPos > 0 .And. Empty(aCols[Len(aCols)][nPos])
	cRet	:= CriaVar(cDesc,.F.)
Else
	cRet	:= FDesc(cBusca,cTab+&((cAliasSx3)->(cCampo)),cDesc)
EndIf

Return cRet


/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �15/01/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �RSPA140                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

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
//����������������������������������������������������������������

Local aRotina 	:= {	    { STR0001, 'PesqBrw', 0, 1,,.F.}, ; 	//'Pesquisar' - c/ Filtro
							{ STR0002, 'Rs140Rot', 0, 2}, ;  	//'Visualizar'
							{ STR0003, 'Rs140Rot', 0, 3}, ;  	//'Incluir'
							{ STR0004, 'Rs140Rot', 0, 4}, ;  	//'Alterar'
							{ STR0005, 'Rs140Rot', 0, 5,3} } 	//'Excluir'

Return aRotina 
