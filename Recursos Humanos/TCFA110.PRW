#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCFA110.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TCFA110  � Autor � Cristina Ogura        � Data � 13.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Responsaveis e Responsabilidades.              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TCFA110                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�24/07/14�TQEA22�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TCFA110()
Local cFiltraRh			//Variavel para filtro
Local cFiltra			//Variavel para filtro

Return(NIL)

Private aIndexRBA	:= {}		//Variavel Para Filtro
Private bFiltraBrw := {|| Nil}	//Variavel para Filtro

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa 	 �
//� ----------- Elementos contidos por dimensao ------------	 �
//� 1. Nome a aparecer no cabecalho 							 �
//� 2. Nome da Rotina associada 								 �
//� 3. Usado pela rotina										 �
//� 4. Tipo de Transa��o a ser efetuada 						 �
//�    1 - Pesquisa e Posiciona em um Banco de Dados			 �
//�    2 - Simplesmente Mostra os Campos						 �
//�    3 - Inclui registros no Bancos de Dados					 �
//�    4 - Altera o registro corrente							 �
//�    5 - Remove o registro corrente do Banco de Dados 		 �
//����������������������������������������������������������������
Private aRotina := {	{ STR0001,"PesqBrw", 0 , 1},; 		//"Pesquisar"
                    	{ STR0002,"Tc110Rot", 0 , 2},; 	//"Visualizar"
                    	{ STR0003,"Tc110Rot", 0 , 3},; 	//"Incluir"
                    	{ STR0004,"Tc110Rot", 0 , 4},; 	//"Alterar"
                    	{ STR0005,"Tc110Rot", 0 , 5}}  	//"Excluir"                 

Private cCadastro := OemToAnsi(STR0006) //"Cadastro de Responsaveis e suas Responsabilidades"

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
cFiltra 	:= CHKRH(FunName(),"RBA","1")
bFiltraBrw 	:= {|| FilBrowse("RBA",@aIndexRBA,@cFiltraRh) }
Eval(bFiltraBrw)       

//������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE 						 �
//��������������������������������������������������������
dbSelectArea("RBA")
dbGotop()

mBrowse(6, 1, 22, 75,"RBA")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RBA",aIndexRBA)

dbSelectArea("RBB")
dbSetOrder(1)

dbSelectArea("RBA")
dbSetOrder(1)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tc110Rot � Autor � Cristina Ogura        � Data � 13.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para controle dos cad responsaveis e responsal//e.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tc110Rot(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo 								  ���
��� 		 � ExpN1 = Numero do registro							   	  ���
��� 		 � ExpN2 = Numero da opcao Selecionada					   	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � TCFA110  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tc110Rot(cAlias,nReg,nOpcx)

Local bCampo
Local cAuxAlias:= Alias()     
Local cChave:= ""
Local nRecno:= Recno()
Local nOrdem:= IndexOrd()
Local ni
Local nOpca:=0
Local nGrava:= 0  
Local lTrDel:= If(nOpcx=2.Or.nOpcx=5,.F.,.T.)
Local lGetd := .F.
Local oFont, oGet
Local oEnchoice
Local oDlgMain
Local aPos := {15,1,65,312 }
Local aFields:={}, aAlter:={}
Local nLoop
Local nLoops

Private cArqNtx := ""
Private nOpcao:= nOpcx
Private aCols:= {}, aHeader := {}
Private aAuxCols:={}, aAuxHeader:={}
Private aTELA[0][0],aGETS[0]
bCampo := {|nCPO| Field(nCPO) }

If nOpcao == 3			//Inclusao
	cChave := CriaVar("RBA_FILIAL")+CriaVar("RBA_CODRES")
	nLoops := FCount()
	FOR nLoop := 1 TO nLoops
		DbSelectArea(cAlias)
		cCampo := EVAL(bCampo,nLoop)
		lInit := .f.
		If ExistIni(cCampo)
			lInit := .t.
			M->&(cCampo) := InitPad(SX3->X3_RELACAO)
			If ValType(M->&(cCampo)) = "C"
				M->&(cCampo) := PADR(M->&(cCampo),SX3->X3_TAMANHO)
			EndIf
			If M->&(cCampo) == NIL
				lInit := .f.
			EndIf
		EndIf
		If !lInit
			M->&(cCampo) := FieldGet(nLoop)
			If ValType(M->&(cCampo)) = "C"
				M->&(cCampo) := SPACE(LEN(M->&(cCampo)))
			ElseIf ValType(M->&(cCampo)) = "N"
				M->&(cCampo) := 0
			ElseIf ValType(M->&(cCampo)) = "D"
				M->&(cCampo) := CtoD("  /  /  ")
			ElseIf ValType(M->&(cCampo)) = "L"
				M->&(cCampo) := .F.
			EndIf
		EndIf
	Next nLoop
Else           
	cChave := RBA->RBA_FILIAL+RBA->RBA_CODRES
	nLoops := FCount()
	FOR nLoop := 1 TO nLoops
		M->&(EVAL(bCampo,nLoop)) := FieldGet(nLoop)
	NEXT nLoop
EndIf	
	
If nOpcx # 2 .And. nOpcx # 5		// Visual/Excluir
	lGetD :=.T.
EndIf

// Campos que devem aparecer na Enchoice            
Aadd(aFields,"RBA_CODRES")
Aadd(aFields,"RBA_NOME")
Aadd(aFields,"RBA_MAT")
Aadd(aFields,"RBA_EMAIL")
Aadd(aFields,"RBA_CC")
Aadd(aFields,"RBA_DESCCC")
Aadd(aFields,"RBA_DEPTO")
Aadd(aFields,"RBA_DESCDTO")
Aadd(aFields,"RBA_CODSUP")
Aadd(aFields,"RBA_SENHA")

// Verifica campos de usuario que devem aparecer na Enchoice
Tc110Usuario(@aFields)

// Campos que nao podem aparecer na getdados
Aadd(aAlter,"RBB_FILIAL")
Aadd(aAlter,"RBB_CODRESP")
                          
// Monta aHeader da GetDados
TrmHeader(@aAuxHeader,aAlter,"RBB")

// Monta o aCols da GetDados
Tc110aCols(@aAuxCols,nOpcx,"RBB","RBB->RBB_FILIAL+RBB->RBB_CODRES",cChave,aAuxHeader,1)

aCols 	:= aAuxCols
aHeader	:= aAuxHeader

SETAPILHA()
DEFINE MSDIALOG oDlgMain FROM	8.5,0 TO 28,80 TITLE cCadastro OF oMainWnd

	Zero()
	oEnchoice:=	MsMGet():New("RBA", nReg, nOpcx,,,,aFields,aPos, , , , , , , , ,.T. ) 

	oGet := MSGetDados():New(70,1,140,312,nOpcx,"Tc110LOk","Tc110TOk","+RBB_SEQ",lTrDel,,1,,300,,,,,oDlgMain)
	oGet:oBrowse:Default()
			
ACTIVATE DIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain,{|| If(oGet:TudoOk(),(nGrava:= 1,oDlgMain:End()),.F.) }, {|| nGrava:=2,oDlgMain:End()} )
SETAPILHA()

If nGrava == 1
	If nOpcao # 2	// Se nao visual
		Begin Transaction
			If nOpcao == 3			// Inclusao
				If __lSX8
					ConfirmSX8()
				EndIf
			EndIf	
			Tc110Grava()
			EvalTrigger()
		End Transaction
	EndIf        
Else	
	If nOpcao == 3 		//Inclusao
		If __lSX8
			RollBackSX8()
		EndIf
	EndIf	
EndIf	                 

dbSelectArea(cAuxAlias)
dbSetOrder(nOrdem)
dbGoTo(nRecNo)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tc110Usuar � Autor � Cristina Ogura       � Data � 14.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica no SX3 se o usuario criou algum campo		  	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Tc110Usuar(aFields)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpA1 := Array com os campos       			 			  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �TCFA110   												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tc110Usuario(aFields)
Local cAlias:= Alias()
Local nOrdem:= IndexOrd()
Local nReg:= RecNo()

dbSelectArea("SX3")
dbSeek("RBA")
While !Eof() .And. (X3_ARQUIVO == "RBA")
	If X3_PROPRI == "U"
		Aadd(aFields,X3_CAMPO)
	EndIf	
	dbSkip()
EndDo

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbGoto(nReg)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tc110Grava � Autor � Cristina Ogura       � Data � 14.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Atualiza os arquivos RBA (responsaveis) e RBB responsabille ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TC110Grava()     				                       	 	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �TCFA110   												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TC110Grava()  
Local bCampo
Local aAnterior := {}
Local cCodRes	:= M->RBA_CODRES
Local nSeq := 0			                 
Local cFiL
Local nX
Local nY
Local lFound                 
Local nLoop
Local nLoops

bCampo := {|nCPO| Field(nCPO) }

If nOpcao == 5				//Exclusao
	Tc110Dele(cCodRes)
ElseIf 	nOpcao == 3			// Inclusao
    
	// Gravar os dados do responsaveis
	RecLock("RBA",.T.)
		nLoops := FCount()
		For nLoop := 1 TO nLoops
			If "_FILIAL"$Field(nLoop)
				FieldPut(nLoop,cFilial)
			Else
				FieldPut(nLoop,M->&(EVAL(bCampo,nLoop)))
			EndIf
		Next nLoop
	MsUnlock()	

	nSeq := 0
	For nX = 1 to Len(aCols)
		nSeq:= nSeq + 1
		If !aCols[nX][Len(aCols[nX])]		// Deletado
			RecLock("RBB",.T.)
				For nY = 1 to Len(aHeader)
					If 	aHeader[nY][10] # "V"
						cVar := Trim(aHeader[nY][2])
						Replace &cVar. With aCols[nX][nY]
					EndIf
				Next nY
				
				Replace RBB_FILIAL 	WITH xFilial("SQV")
				Replace RBB_CODRES	WITH cCodRes
				Replace RBB_SEQ		WITH StrZero(nSeq,2)
				
			MsUnlock()
		EndIf
	Next nX
ElseIf nOpcao == 4								// Alteracao
                                      
	// Grava os dados dos responsaveis
	RecLock("RBA",.F.)
		nLoops := FCount()
		For nLoop := 1 TO nLoops
			FieldPut(nLoop,M->&(EVAL(bCampo,nLoop)))
		Next nLoop
    MsUnlock()

	// Grava as responsabilidade dos responsaveis
	aAnterior	:={}
	nSeq 		:= 0
	cFil 		:= If(Empty(xFilial("RBB")),Space(FWGETTAMFILIAL),xFilial("RBB"))
	dbSelectArea("RBB")
	dbSetOrder(1)
	If	dbSeek(cFil+cCodRes)
		While !Eof() .And. RBB_FILIAL+RBB_CODRES == cFil+cCodRes
			Aadd(aAnterior,RecNo())
			dbSkip()
		EndDo
	EndIf
	For nX:=1 To Len(aCols)
		If 	Len(aAnterior) >= nX				// Alteracao
			Go aAnterior[nX]
			If aCols[nX][Len(aCols[nX])]		// Deletado
				RecLock("RBB",.F.)
					dbDelete()
				MsUnlock()
			Else
				lFound:=.F.					// Atualiza os ja existentes
			EndIf
		Else									// Inclusao de mais dados
			lFound:= .T.
		EndIf

		If !aCols[nX][Len(aCols[nX])]			// Deletado
			nSeq := nSeq + 1
			RecLock("RBB",lFound)
				For nY = 1 to Len(aHeader)
					If 	aHeader[nY][10] # "V"
						cVar := Trim(aHeader[nY][2])
						Replace &cVar. WITH aCols[nX][nY]
					EndIf
				Next nY
				
				If 	lFound
					Replace RBB_FILIAL 	WITH xFilial("RBB")
					Replace RBB_CODRES	WITH cCodRes
				EndIf                              
				
			MsUnlock()
		EndIf
	Next nX
EndIf                   

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tc110LOk � Autor � Cristina Ogura        � Data � 30.05.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da linha da getdados                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TC110LOk()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � TCFA110  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tc110LOk()
Local nPosNivel	:= Ascan(aHeader,{ |x| Alltrim(x[2]) = "RBB_NIVEL"})
Local nPosFiltro:= Ascan(aHeader,{ |x| Alltrim(x[2]) = "RBB_FILTRO"})
Local lRet := .T.
Local nX

If !aCols[n,Len(aCols[n])]
	If nPosNivel >0 .And. Empty(aCols[n][nPosNivel])
		Help("",1,"Tc110NIVEL")		// Falta digitar o nivel hierarquico de responsabilidade
		lRet := .F.	
	ElseIf nPosFiltro >0 .And. Empty(aCols[n][nPosFiltro])
		Help("",1,"Tc110FILTRO")		// Falta digitar o filtro de respon.
		lRet := .F.
	EndIf

	If lRet
		For nX:=1 To Len(aCols)
			If 	aCols[n][nPosNivel] 	== aCols[nX][nPosNivel] .And.;
				aCols[n][nPosFiltro]	== aCols[nX][nPosFiltro] .And.;
				!aCols[nX][Len(aCols[nX])] .And.;
				n # nX
				Help(" ",1,"Tc110JAEX")	// Codigo de responsabilidade ja existente
				lRet:= .F.
				Exit
			EndIf
		Next nX
	EndIf
EndIf     

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tc110TOK � Autor � Cristina Ogura        � Data � 30.05.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida toda a getdados                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tc110TOk()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � TCFA110  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tc110TOk() 
Local lDel := .T.
Local nPosNivel	:= Ascan(aHeader,{ |x| Alltrim(x[2]) = "RBB_NIVEL"})
Local nPosFiltro:= Ascan(aHeader,{ |x| Alltrim(x[2]) = "RBB_FILTRO"})
Local lRet := .T.
Local nX

If !aCols[n,Len(aCols[n])]
	If nPosNivel >0 .And. Empty(aCols[n][nPosNivel])
		Help("",1,"Tc110RESP")		// Falta digitar o nivel hierarquico de responsabilidade
		lRet := .F.	
	ElseIf nPosFiltro >0 .And. Empty(aCols[n][nPosFiltro])
		Help("",1,"Tc110FILTRO")		// Falta digitar o filtro de respon.
		lRet := .F.
	EndIf
EndIf
     
If 	lRet
	// Verificar se todos as responsabilidades estao deletados
	For nX:= 1 To Len(aCols)
		If 	!aCols[nX][Len(aCols[nX])] 
			lDel := .F.
			Exit
		EndIf
	Next nX
EndIf	

If 	lDel
	Help("",1,"Tc110TDel")	//Todos as responsabilidades estao deletadas.Verifique.
	Return .F.
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TC110aCols� Autor � Cristina Ogura        � Data � 30.05.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta o acols da getdados                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TC110aCols()                                                ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �TCFA110   												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tc110aCols(aAuxCols,nOpcx,cAlias,cCond,cChave,aAuxHeader,nOrdem)
Local nAcols:= 0
Local nCntFor := 0
Local nUsado  := Len(aAuxHeader)
Local nAuxOrdem
Local nAuxReg  

dbSelectArea(cAlias)
nAuxOrdem 	:= IndexOrd()
nAuxReg		:= RecNo()

dbSetOrder(nOrdem)
If 	dbSeek(cCHAVE)
    While !Eof() .And. &cCond == cChave
		Aadd(aAuxCols,Array(nUsado+If(nOpcx#2.And.nOpcx#5,1,0)))
		nAcols := Len(aAuxCols)
		For nCntFor := 1 To Len(aAuxHeader)
			If ( aAuxHeader[nCntFor][10] != "V")
				aAuxCols[nAcols][nCntFor] := FieldGet(FieldPos(aAuxHeader[nCntFor][2]))
			Else
				aAuxCols[nAcols][nCntFor] := CriaVar(aAuxHeader[nCntFor][2],.T.)
			EndIf
		Next nCntFor
		If nOpcx # 2 .And. nOpcx # 5
			aAuxCols[nAcols][nUsado+1] := .F.
		EndIf
		dbSelectArea(cAlias)
		dbSkip()
	EndDo
Else
	dbSelectArea("SX3")
	dbSeek(cAlias)
	aadd(aAuxCols,Array(nUsado+If(nOpcx#2.And.nOpcx#5,1,0)))
	nAcols := Len(aAuxCols)
	For nCntFor := 1 To Len(aAuxHeader)
		If 	X3_TIPO == "C" .And. Trim(aAuxHeader[nCntFor][2]) $ "RBB_SEQ"
			aAuxCols[1][nCntFor] := Repl("0",aAuxHeader[nCntFor][4]-1)+"1"
		Else
			aAuxCols[nAcols][nCntFor] := CriaVar(aAuxHeader[nCntFor][2],.T.)
		EndIf	
	Next nCntFor
	If nOpcx # 2 .And. nOpcx # 5
		aAuxCols[1][nUsado+1] := .F.
	EndIf	
EndIf                     

                  
// Volto a posicao do RBB
dbSelectArea("RBB")
dbSetOrder(nAuxOrdem)
dbGoto(nAuxReg)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tc110Dele � Autor � Cristina Ogura        � Data � 30.05.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de exclusao dos responsaveis e responsabilidades     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Tc110Dele()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �TcfA110   												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tc110Dele(cCodRes)
                     
// Apaga os dados do RBA - Responsaveis 
cFil := If(Empty(xFilial("RBA")),Space(FWGETTAMFILIAL),xFilial("RBA"))
dbSelectArea("RBA")
dbSetOrder(1)
If	dbSeek(cFil+cCodRes)
	RecLock("RBA",.F.)
		dbDelete()
	MsUnlock()
EndIf	

// Apaga os dados do RBB - Responsabilidades
cFil := If(Empty(xFilial("RBB")),Space(FWGETTAMFILIAL),xFilial("RBB"))
dbSelectArea("RBB")
dbSetOrder(1)
dbSeek(cFil+cCodRes)
While !Eof() .And. RBB_FILIAL+RBB_CODRES == cFil+cCodRes
	RecLock("RBB",.F.)
		dbDelete()
	MsUnlock()
	dbSkip()
EndDo

Return .T.                       

Function Tc110Desc()
Local aArea:= GetArea()
Local cVar := &(ReadVar())
Local nPosNivel	:= Ascan(aHeader,{ |x| Alltrim(x[2]) = "RBB_DESCNI"})

dbSelectArea("RB9")
dbSetOrder(1)
If 	dbSeek(xFilial("RB9")+cVar)
	aCols[n][nPosNivel] := RB9->RB9_DESCRI
EndIf

RestArea(aArea)
Return .T.