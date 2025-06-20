#include "Protheus.ch"
#INCLUDE "CSAA020.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSAA020  � Autor � Cristina Ogura        � Data � 13.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro dos Indices de Reajustes                          ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�07/07/14�TPZVTW�Incluido o fonte da 11 para a 12 e        ���
���            �        �      �efetuada a limpeza.                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CSAA020                                                 
Local cFiltra	:= ""	//Variavel para filtro
Local cFiltraRB3:= ""	//Variavel para filtro

Private aIndexRB3	:= {}			//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}	//Variavel para Filtro

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
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0006)	//"Cadastro de Indices de Reajustes"  

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("RB3")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RB3","1")  
cFiltraRB3	:= ''		// Criar campo de Sequencia na Proxima versao
If !Empty(cFiltra)
	cFiltraRB3 += ".And." + cFiltra
EndIf
bFiltraBrw 	:= {|| FilBrowse("RB3",@aIndexRB3,@cFiltraRB3) }
Eval(bFiltraBrw)

dbSelectArea("RB3")
dbGotop()

mBrowse(6, 1, 22, 75, "RB3")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RB3",aIndexRB3)

dbSelectArea("RB3")
dbSetOrder(1)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Cs020Rot � Autor � Cristina Ogura        � Data � 13.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de tratamento da aRotina                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cs020Rot(cExpC1,nExpN1,nExpN2)                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs020Rot(cAlias,nReg,nOpc)
Local oDlg, oGet
Local cCadastro := "Indice de Reajuste"       
Local lCsDel	:= If(nOpc=2.Or.nOpc=5,.F.,.T.)
Local nOpca		:= 1                   
Local aFields	:= {"RB3_FILIAL","RB3_INDICE","RB3_DESCRI"}
     
//��������������������������������������������������������������Ŀ
//� Variaveis para Dimensionar Tela		                         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

Private aHeader		:= {}
Private aCols		:= {}
Private cReajuste	:= ""
Private cDescr		:= ""
Private nOpcx 		:= nOpc
         
//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RB3",aIndexRB3)
aIndexRB3 := {}
dbGoto(nReg)

If nOpcx # 3		// Inclusao
	cReajuste 	:= RB3->RB3_INDICE
	cDescr		:= RB3->RB3_DESCRI
Else
	cReajuste	:= CriaVar("RB3_INDICE")
	cDescr		:= CriaVar("RB3_DESCRI")
EndIf

// Monta aHeader
TrmHeader(@aHeader,aFields,"RB3")

// Monta aCols
Cs020aCols()
         
/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
 
aGdCoord	:= { (aObjSize[1,1]+5), (aObjSize[1,2]+5)	, (aObjSize[1,3]-5), (aObjSize[1,4]-5) }	

DEFINE MSDIALOG oDlg TITLE cCadastro FROM  aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	@ aGdCoord[1]+6,aGdCoord[2]+5	SAY OemToAnsi(STR0007)		PIXEL	//"Cod. Indice: "
	
	@ aGdCoord[1]+5, aGdCoord[2]+50 MSGET cReajuste	 	VALID Cs020Ver();
									WHEN  nOpcx == 3;
									SIZE 8,7 	PIXEL	
	@ aGdCoord[1]+5,aGdCoord[2]+70	MSGET cDescr		VALID NaoVazio(cDescr);
									PICTURE "@!";
									WHEN nOpcx == 3;
									SIZE 230,7 PIXEL
										
	oGet   := MSGetDados():New(aGdCoord[1]+20, aGdCoord[2], aGdCoord[3], aGdCoord[4], nOpcx,"Cs020Ok","Cs020TOk","",lCsDel,,1,,300,,,,,oDlg)
	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=2,If(oGet:TudoOK(),oDlg:End(),nOpca:=1)},{|| nOpca:=1,oDlg:End()})

If nOpca == 2
	Cs020Grava()
	If __lSX8 .And. nOpc == 3		// Inclusao
		ConfirmSX8()
	EndIf
Else                    
	If __lSX8
		RollBackSX8()
	EndIf
EndIf		

Eval(bFiltraBrw)
If nOpc == 3
	dbGoBottom()
Else
	dbGoto(nReg)
EndIf

Return .T.
/*	
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs020Grava� Autor � Cristina Ogura        � Data � 13.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava os dados dos reajustes dos indices                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cs020Rot(cExpC1,nExpN1,nExpN2)                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs020Grava()
Local cIndCond	:= ""
Local cArqNtx	:= ""         
Local aAnterior	:= {}
Local nTam		:= Len(aCols)
Local nt		:= 0
Local nx		:= 0

If nOpcx == 2		// Visual
	Return .T.
ElseIf nOpcx == 3 .Or. nOpcx== 4		// Inclusao ou Alteracao
	Begin Transaction 
		dbSelectArea("RB3")
		dbSetOrder(1)
		If dbSeek(xFilial("RB3")+cReajuste)
			While !Eof() .And. xFilial("RB3")+cReajuste ==;
					RB3->RB3_FILIAL+RB3->RB3_INDICE
					Aadd(aAnterior, RecNo())
				dbSkip()
			EndDo
		EndIf
	
		For nx:=1 to nTam
			If nx <= Len(aAnterior)
				dbGoto(aAnterior[nx])
				RecLock("RB3",.F.)
				//--Verifica se esta deletado
				If aCols[nx][Len(aCols[nx])]
					dbDelete()
					Loop    
				Else 
					RecLock("RB3",.F.)				
				EndIf
			Else                             
				//--Verifica se esta deletado			
				If 	aCols[nx][Len(aCols[nx])]
					Loop    
				EndIf
				RecLock("RB3",.T.)	
				Replace RB3->RB3_FILIAL 	With xFilial("RB3")
				Replace RB3->RB3_INDICE		With cReajuste
				Replace RB3->RB3_DESCRI		With cDescr
			EndIf
		                
			For nt := 1 To Len(aHeader)
				If aHeader[nt][10] # "V"
					cCampo	 := Trim(aHeader[nt][2])
					xConteudo := aCols[nx][nt]
					Replace &cCampo With xConteudo
				EndIf
			Next nt      
		
			MsUnlock() 
    	Next nx	              
	End Transaction 	    
ElseIf nOpcx == 5	// Excluir
	// Verifica se existe esta indice em alguma pesquisa
	cIndCond:= "RB1->RB1_FILIAL+RB1->RB1_INDICE"		
	cArqNtx := CriaTrab(NIL,.F.)
	IndRegua("RB1",cArqNtx,cIndCond,,,STR0008)		// "Selecionando Registros..."	
	nIndex := RetIndex("RB1")

	dbSetOrder(nIndex+1)               
	If dbSeek(xFilial("RB1")+cReajuste)
		Help("",1,"Cs020NPODE")		// Nao posso excluir este participante pois existem Pesquisa salarial para este participante
		Return .F.
	EndIf                                      

	Begin Transaction       
		dbSelectArea("RB3")
		dbSetOrder(1)
		If dbSeek(xFilial("RB3")+cReajuste)
			While !Eof() .And. xFilial("RB3")+cReajuste ==; 
						    RB3->RB3_FILIAL+RB3->RB3_INDICE
						    
				RecLock("RB3",.F.,.T.)
					dbDelete()
				MsUnlock()		
				WriteSX2("RB3",1)
				dbSkip()
			EndDo
		EndIf			
	End Transaction	
EndIf

dbSelectArea("RB3")

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Cs020Ver � Autor � Cristina Ogura        � Data � 13.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se ja existe o codigo do reajuste                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cs020Ver()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs020Ver()
Local aSaveArea := GetArea()
Local lRet 		:= .T.

dbSelectArea("RB3")
dbSetOrder(1)
If dbSeek(xFilial("RB3")+cReajuste)
	Help("",1,"Cs020JAEXIST")			// Reajuste ja cadastrado
	lRet := .F.
EndIf

If lRet .And. !FreeForUse("RB3",cReajuste)
	lRet := .F.
EndIf
          
RestArea(aSaveArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Cs020aCols � Autor � Cristina Ogura      � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria array aCols com os dados dos indices de reajuste      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cs020aCols()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs020aCols()
Local nCntFor := 0
Local nUsado  := Len(aHeader)
Local nAcols  := 0
Local cChave  := ""

aCols 	:= {}
cChave	:= xFilial("RB3")+cReajuste
dbSelectArea("RB3")
dbSetOrder(1)
If dbSeek(cChave)
	While !Eof() .And.	RB3->RB3_FILIAL+RB3->RB3_INDICE==;
						cChave
		Aadd(aCols,Array(nUsado+1))
		nAcols := Len(aCols)
		For nCntFor := 1 To Len(aHeader)
			If aHeader[nCntFor][10] != "V"
				aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
			Else	
				aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
			EndIf	
		Next nCntFor

		aCols[nAcols][nUsado+1] := .F.
		dbSelectArea("RB3")
		dbSkip()
	EndDo
Else
	dbSelectArea("SX3")
	dbSeek("RB3")
	Aadd(aCols,Array(nUsado+1))
	nAcols := Len(aCols)
	For nCntFor := 1 To Len(aHeader)
		aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
	Next nCntFor
	aCols[1][nUsado+1] := .F.
EndIf	
	
Return Nil
       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Cs020OK    � Autor � Cristina Ogura      � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a linha da getdados - Linha Ok                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cs020OK()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs020Ok()
Local nPosData 	:= GdFieldPos("RB3_DATA")
Local nPosVal  	:= GdFieldPos("RB3_VALOR")
Local i			:= 0

If 	(nPosData>0 .And. nPosVal > 0) .And.;
	!aCols[n][Len(aCols[n])] .And.;
	(Empty(aCols[n][nPosData]) .Or. Empty(aCols[n][nPosVal]))
	Help("",1,"Cs020VERIF")		// Verificar os campos data e valor nao podem ser brancos
	Return .F.
EndIf      

If 	nPosData > 0 .And.;              
	!aCols[n][Len(aCols[n])] .And.;
	Val(Alltrim(Substr(aCols[n][nPosData],3,4))) < 1900
	Help("",1,"Cs020VERIF")		// Verificar os campos data e valor nao podem ser brancos	
	Return .F.
EndIf	

For i:= 1 To Len(aCols)
	If 	aCols[n][nPosData] == aCols[i][nPosData] .And.;
		!aCols[n][Len(aCols[n])] .And.;
		!aCols[i][Len(aCols[i])] .And.;
		n # i
		Help("",1,"Cs020IGUAL")	// Este mes/ano ja existe.
		Return .F.
	EndIf	
Next i

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Cs020TOK   � Autor � Cristina Ogura      � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao do Tudo OK                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cs020TOK()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs020TOk()
Local nPosData 	:= GdFieldPos("RB3_DATA")
Local nPosVal  	:= GdFieldPos("RB3_VALOR") 
Local i			:= 0
  
For i:= 1 To Len(aCols)
	If 	(nPosData>0 .And. nPosVal>0 ) .And.;
		(Empty(aCols[i][nPosData]) .Or. Empty(aCols[i][nPosVal])).And.;
		 !aCols[i][Len(aCols[i])]
		Help("",1,"Cs020VERIF")		// Verificar os campos data e valor nao podem ser brancos
		Return .F.
	EndIf	
Next i

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Cs020Data  � Autor � Cristina Ogura      � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica o mes e ano digitado                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cs020Data()                                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs020Data()
Local cVar	:= &(ReadVar())
Local nMes	:= 0
Local nAno	:= 0

nMes := Val(Substr(cVar,1,2))
nAno := Val(Substr(cVar,3,4))

If nMes < 1 .Or. nMes > 12
	Help("",1,"Cs020Mes")			// Mes Invalido
	Return .F.
EndIf	

If nAno == 0
	Help("",1,"Cs020Ano")
	Return .F.
EndIf	

Return .T.                           


/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �27/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �RSPA020                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

 Local aRotina := { 	{ STR0001, 'PesqBrw', 0, 1,,.F.}, ;	//'Pesquisar'
						{ STR0002, 'Cs020Rot', 0, 2}, ;	//'Visualizar'
						{ STR0003, 'Cs020Rot', 0, 3}, ;	//'Incluir'
						{ STR0004, 'Cs020Rot', 0, 4}, ;	//'Alterar'
						{ STR0005, 'Cs020Rot', 0, 5,3} }	//'Excluir'

Return aRotina