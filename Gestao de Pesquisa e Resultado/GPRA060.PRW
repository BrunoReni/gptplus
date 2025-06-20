#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"                          
#INCLUDE "GPRA060.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPRA060    �Autor  � Henry Fila           � Data � 20/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Sub-Grupos                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K.�24/08/04�710   �-Notacao, Sintaxe e Logica                  ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function GPRA060(aRotAuto,nOpc)

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Private cCadastro := STR0001			   // Cadastro de Subgrupos de Pesquisas

Private aRotina   := MenuDef()

//��������������������������������������������������������������Ŀ
//� Definicao de variaveis para rotina de inclusao automatica    �
//����������������������������������������������������������������
Private l060Auto := ( aRotAuto <> NIL )

If (nOpc == NIL)
	nOpc :=  3
Endif	

//�������������������������Ŀ
//�Se for entrada automatica�
//���������������������������
DbSelectArea("SKF")
DbSetOrder(1)
If l060Auto
   MsRotAuto(nOpc,aRotAuto,"SKF")
Else
   mBrowse(6,1,22,75,"SKF")
Endif   
                            
Return(.T.)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 13.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0002 ,"AxPesqui"	,0 ,1 ,0 ,.F.},;   //Pesquisar
						{STR0003 ,"GPRA060Man"	,0 ,2 ,0 ,.T.},;   //Visualizar
						{STR0004 ,"GPRA060Man"	,0 ,3 ,0 ,.T.},;   //Incluir
						{STR0005 ,"GPRA060Man"	,0 ,4 ,0 ,.T.},;   //Alterar
						{STR0006 ,"GPRA060Man"	,0 ,5 ,0 ,.T.} }   //Excluir
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPRA060Man �Autor  � Henry Fila           � Data � 09/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Inclusao/Cadastro de Sub-Grupos                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gpra060Man(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Conrado Q.|29/01/07�115968|- Montagem do aCols e aHeader atrav�s       ���
���          �        �      |da rotina FillGetDados.                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpra060Man(cAlias,nReg,nOpc)

Local aHeaderSKF:= {}						//aHeader do subgrupo
Local aColsSKF	:= {}						//aCols do subgrupo
Local aRecnoSKF	:= {}						//Recno de subgrupos
Local aGet		:= {}						//Array de descricao dos campos
Local aPosObj	:= {}						//Array de dimensoes da tela
Local aObjects	:= {}						//Array de dimensoes da tela                        
Local aSize		:= MsAdvSize( .F. )			//Array de dimensoes da tela             
Local aArea		:= GetArea()				//Area atual              
Local aButtons	:= { { "S4WB011N"   , { || GdSeek(oGetdSKF,STR0012) }, STR0012, STR0013 } } //"Busca avancada"

Local nOpcao	:= 0						// Retorno da gravacao OK ou CANCELA
Local cCpoEdit	:= "KF_CODGRP|KF_DESCGRP"	// Campos que nao aparecerao no acols
Local cDescGrupo:= ""						// Descricao do grupo

Local lProcessa	:= .T.						// Validacao de delecao 

Local nOpca		:= 0						//Controle de confirmacao da tela
Local nSaveSx8	:= GetSx8Len()				//Controle de semaforo 

Local oFolder	:= Nil

Local cSeek		:= ""						// Seek para montagem do aCols
Local cWhile	:= ""						// While para montagem do aCols
Local aNoFields	:= {}						// Campos que n�o ser�o adicionados no aHeaders

Private cGrupo	:= IIf (!Inclui,SKF->KF_CODGRP,CriaVar("KF_CODGRP")) //Grupo de questoes, esta variavel deve ser private devido as validacoes SX3

If nOpc == 5
	lProcessa := Gpr060CDel( SKF->KF_CODGRP, SKF->KF_CODSUBG, .T. )
Endif	

If lProcessa

	//��������������������������������������������������������������Ŀ
	//� Pega a descricao padrao do campo do cabecalho                �
	//����������������������������������������������������������������
	dbSelectArea("SX3")
	dbSetOrder(2)
	DbSeek("KF_CODGRP")
	aadd(aGet,{X3Titulo(),SX3->X3_PICTURE,SX3->X3_F3})
	
	dbSelectArea("SX3")
	dbSetOrder(2)
	DbSeek("KF_DESCGRP")
	aadd(aGet,{X3Titulo(),SX3->X3_PICTURE,SX3->X3_F3})
	
	//�����������������������Ŀ
	//�Pega descricao do Grupo�
	//�������������������������
	dbSelectArea("SKE")
	dbSetOrder(1)
	If !Inclui .And. DbSeek( xFilial("SKE")+cGrupo )
		cDescGrupo := SKE->KE_DESC 
	Endif	                                                          
	
	//���������������������������������������������Ŀ
	//� Monta aHeader e aCols das Regras da Pesquisa�
	//�����������������������������������������������
	aHeader		:= {}
	aCols		:= {}
	aNoFields	:= { "KF_CODGRP", "KF_DESCGRP" }	
	
	If !INCLUI
		cSeek 	:= xFilial("SKF")+cGrupo
		cWhile	:= "SKF->KF_FILIAL+SKF->KF_CODGRP"
	
		FillGetDados(	nOpc			,"SKF"			,1											,cSeek				,;
		   				{|| &cWhile }	,{|| .T. }		,aNoFields								,/*aYesFields*/		,; 
		   				/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/								,/*lEmpty*/			,;
		   				/*aHeaderAux*/	,/*aColsAux*/	,{|| GPR060AfterCols( "SKF", aRecnoSKF ) }	,/*bBeforeCols*/	)
				   				
	Else
		FillGetDados(	nOpc			,"SKF"		,1				,/*cSeek*/		,;
						/*{||&cWhile}*/	,{|| .T. }	,aNoFields		,/*aYesFields*/	,; 
						/*lOnlyYes*/	,/*cQuery*/	,/*bMontCols*/	,.T.			)
	EndIf
	
	aHeaderSKF	:= aClone( aHeader )
	aColsSKF	:= aClone( aCols )
	
	//��������������������������������������������������������������Ŀ
	//� Dimensionamnto da tela                                       �
	//����������������������������������������������������������������
	AAdd( aObjects, { 100,  095, .T., .F. } )
	AAdd( aObjects, { 100,  100, .T., .T. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 } 
	aPosObj := MsObjSize( aInfo, aObjects ) 
	
	//��������������������������������������������������������������Ŀ
	//� Exibicao da janela                                           �
	//����������������������������������������������������������������
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd PIXEL
		
		//��������������������������������������������������������������Ŀ
		//� Get do grupo                                                 �
		//����������������������������������������������������������������
		@ aPosObj[1,1] + 35,005 SAY aGet[1][1] SIZE 50,7 OF oDlg PIXEL	
		@ aPosObj[1,1] + 35,030 MsGet cGrupo PICTURE aGet[1][2] F3 "SKE" WHEN Inclui VALID Gpr060Vld(cGrupo,@cDescGrupo,oDesc) SIZE 30,7 OF oDlg PIXEL	
		@ aPosObj[1,1] + 35,075 MsGet oDesc Var cDescGrupo PICTURE "@!" WHEN .F. SIZE 280,7 OF oDlg PIXEL	
		
		//��������������������������������������������������������������Ŀ
		//� aCols dos subgrupos                                          �
		//����������������������������������������������������������������
		dbSelectArea("SKF")		
		oGetdSKF := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],IIF(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE,0),"Gpr060LOk()","Gpr060TOk()",,,,999,,,,,aHeaderSKF,aColsSKF)
		
	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| nOpcA := 1, aColsSKF:=oGetdSKF:aCols,If( oGetDSKF:TudoOk(), oDlg:End(),nOpca := 0 ) },{||oDlg:End()},,aButtons) )
	
	If nOpca == 1
	
		//��������������������������������������������������������������Ŀ
		//� Efetua a gravacao dos subgrupos                              �
		//����������������������������������������������������������������
		Begin Transaction
			lGravou := Gpr060Grv(nOpc-2,aHeaderSKF,aColsSKF,aRecnoSKF,cGrupo)
			If ( lGravou )       
			
				If ExistBlock("GPR060GRV")
					ExecBlock("GPR060GRV",.F.,.F.,{nOpc-2})
				Endif	
	
				//��������������������������������������������������������������Ŀ
				//� Controle de semaforos                                        �
				//����������������������������������������������������������������
				EvalTrigger()
				While ( GetSx8Len() > nSaveSx8 )
					ConfirmSx8()
				End
			EndIf
		End Transaction
	
	Endif

Endif
	
RestArea( aArea )

DbSelectarea( cAlias )
Return(.T.)

/*
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr060Grv  �Autor  � Henry Fila           � Data � 23/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao dos subgrupos                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gpr060Grv()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1: Opcao de processo                                   ���
���          � ExpA2: aHeader de subgrupos                                ���
���          � ExpA3: aCols de subgrupos                                  ���
���          � ExpA4: Registros para controle de gravacao                 ���
���          � ExpA5: Grupo de questoes                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Validacao da variavel cGrupo                               ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���         .�        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpr060Grv(	nOpcao,	aHeaderSKF,	aColsSKF,	aRecnoSKF,;
					cGrupo)

Local aArea     := GetArea()              //Area atual                      
Local bCampo 	:= {|nCPO| Field(nCPO) }  //Bloco de codigo de campo
Local lTravou   := .F.                    //Variavel de controle gravacao
Local nX        := 0                      //Contador For
Local nY        := 0                      //Contador For
Local nUsado    := Len(aHeaderSKF)        //Dimensoes das colunas      

//��������������������������������������������������������������Ŀ
//� Verifica se e inclusao ou alteracao                          �
//����������������������������������������������������������������
If nOpcao <> 3

	Begin Transaction

		//��������������������������������������������������������������Ŀ
		//� Varre as linhas dos subgrupos                                �
		//����������������������������������������������������������������
		For nX := 1 To Len(aColsSKF)
                                            
			lTravou := .F.
			If nX <= Len(aRecnoSKF)		
				dbSelectArea("SKF")
				dbGoto(aRecnoSKF[nX])
				RecLock("SKF")
				lTravou := .T.
			EndIf
			
			If ( !aColsSKF[nX][nUsado+1] )
				If !lTravou 
					RecLock("SKF",.T.)			
				EndIf
				
				SKF->KF_FILIAL := xFilial("SKF")
				SKF->KF_CODGRP := cGrupo
				
				For nY := 1 to Len(aHeaderSKF)
					If aHeaderSKF[nY][10] <> "V"
						SKF->(FieldPut(FieldPos(aHeaderSKF[nY][2]),aColsSKF[nX][nY]))
					EndIf
				Next nY
				MsUnLock()                   
				
				lGravou := .T.
			Else
				If lTravou        
					RecLock("SKF")
						SKF->(dbDelete())
					MsUnlock()
				Endif				
			EndIf
			MsUnLock()
			
		Next	

	End Transaction                 
Else

	//��������������������������������������������������������������Ŀ
	//�Exclui as alternativas                                        �
	//����������������������������������������������������������������
	SKF->( dbSetOrder(1) )
	If SKF->( DbSeek(xFilial( "SKF" ) + cGrupo ) )
		While SKF->( !Eof() ) .And. SKF->KF_FILIAL == xFilial("SKF") .And.;	
									SKF->KF_CODGRP == cGrupo 
			RecLock("SKF")
				dbDelete()	
			MsUnlock()	

			SKF->(dbSkip())								
		End	
	Endif	
	
Endif

Return( .T. )

/*
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr060CDel �Autor  � Henry Fila           � Data � 23/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se algum determinado grupo ou subgrupo podem ser    ���
���          � ser excluidos                                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gpr060CDel(cGrupo,cSubGrupo)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo do grupo                                      ���
���          �ExpC2: Codigo do subgrupo                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAGPR                                                     ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���         .�        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpr060CDel( cGrupo,cSubGrupo,lHelp )

Local aArea  := GetArea() //Area atual
Local lRet   := .T.       //Retorno da funcao

//�������������������������������������������������������������������Ŀ
//�Verifica se existe o subgrupo no cadastro de questoes              �
//���������������������������������������������������������������������
SKG->( dbSetOrder( 2 ) )
If SKG->( DbSeek( xFilial( "SKG" )+ cGrupo + cSubGrupo ) )
	Help( " ", 1, "GPR060QST" ) //Este subgrupo nao podera ser excluido pois existem questoes relacionadas a este grupo/subgrupo
	lRet := .F.
Endif

If lRet
	//�������������������������������������������������������������������Ŀ
	//�Verifica se existe o subgrupo no cadastro de questionarios         �
	//���������������������������������������������������������������������
	SKR->( dbSetOrder( 3 ) )
	If SKR->( DbSeek( xFilial( "SKR" )+ cGrupo + cSubGrupo ) )                                                                     
		Help( " ", 1, "GPR060QUE" ) //Este subgrupo nao podera ser excluido pois existem questionarios relacionadas a este grupo/subgrupo
		lRet := .F.
	Endif
Endif
	
//�������������������������������������������������������������������Ŀ
//�Restaura a area atual                                              �
//���������������������������������������������������������������������
RestArea( aArea )

Return( lRet )                        

/*
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr060LOk  �Autor  � Henry Fila           � Data � 23/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da linha                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gpr060Lok()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAGPR                                                     ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���         .�        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpr060LOk()

Local lRet     := .T. //Retorno da funcao

Local nX       := 0   //Contador for
Local nPosSGru := aScan(aHeader,{|x| AllTrim(x[2])=="KF_CODSUBG"})
Local nPosDesc := aScan(aHeader,{|x| AllTrim(x[2])=="KF_CODSUBG"})
Local nUsado   := Len(aHeader)

If lRet

	For nX := 1 to Len( aCols )
	
		//��������������������������������������������������������������Ŀ
		//� Verifica se o registro nao esta deletado                     �
		//����������������������������������������������������������������
		If !aCols[nX][nUsado+1]
			If nX <> n .And. aCols[nX][nPosSGru] == aCols[n][nPosSGru]
				Help(" ",1,"JAGRAVADO")
				lRet := .F.
			Endif
		Endif	
	Next
Endif

Return( lRet )

/*
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr060TOk  �Autor  � Henry Fila           � Data � 23/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao geral da tela                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gpr060Tok()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAGPR                                                     ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���         .�        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpr060TOk()

Local aArea    := GetArea()

Local lRet     := .T. //Retorno da funcao

Local nX       := 0   //Contador for
Local nPosSGru := aScan(aHeader,{|x| AllTrim(x[2])=="KF_CODSUBG"})
Local nPosDesc := aScan(aHeader,{|x| AllTrim(x[2])=="KF_CODSUBG"})
Local nUsado   := Len(aHeader)

For nX := 1 to Len( aCols )
	If aCols[nX][nUsado+1] 
		SKG->( dbSetOrder( 2 ) )
		If SKG->( DbSeek( xFilial( "SKG" )+ cGrupo + aCols[nX][nPosSGru] ) )
			Help( " ", 1, "GPR060QST" ) //Este subgrupo nao podera ser excluido pois existem questoes relacionadas a este grupo/subgrupo
			lRet := .F.                                      
			Exit
		Endif
	Endif	
Next
                           
RestArea( aArea )

Return( lRet )

/*
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr060Vld  �Autor  � Henry Fila           � Data � 23/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do grupo                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gpr060Vld()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Grupo de questoes                                   ���
���          � ExpC1: Descricao do grupo                                  ���
���          � ExpO1: Objeto da descricao do grupo para refresh           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Validacao da variavel cGrupo                               ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���         .�        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpr060Vld(cGrupo,cDescGrupo,oDesc)

Local aArea  := GetArea()  //Area atual
Local lRet   := .T.        //Array de retorno

//��������������������������������������������������������������Ŀ
//� Verifica se o campo esta em branco                           �
//����������������������������������������������������������������
If Empty( cGrupo )
	Help(" ",1,"NVAZIO")
	lRet := .F.
Endif

//��������������������������������������������������������������Ŀ
//� Verifica a existencia do grupo                               �
//����������������������������������������������������������������
If lRet
	lRet := ExistCpo( "SKE", cGrupo )                                                                            
Endif	

//��������������������������������������������������������������Ŀ
//� Atualiza a descricao com refresh                             �
//����������������������������������������������������������������
If lRet       
	cDescGrupo := SKE->KE_DESC
	oDesc:Refresh()
Else	
	cDescGrupo := ""
	oDesc:Refresh()
Endif	

//��������������������������������������������������������������Ŀ
//� Restaura a area padrao                                       �
//����������������������������������������������������������������
RestArea( aArea )

Return( lRet )

/*
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr060SGrp �Autor  � Henry Fila           � Data � 23/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do Subgrupo                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gpra060Grp()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Validacao no campo SX3 KF_CODSUBG                          ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Henry    .�20/07/05� 811  �Ajuste da variavel de busca caso seja chama ���
���          �        �      �do de um F3                                 ���
�������������������������������������������������������������������������Ĵ��
���Tatiana   �28/09/06� 811  �Ajuste a variavel para inclusao de subgrupos���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpr060SGrp(cGrupo)

Local aArea := GetArea()  //Area de trabalho
Local lRet := .T.         // Retorno da funcao

//�������������������������������������������������������������������
//�Verifica se a variavel da tela padrao existe, caso contrario esta�
//�sendo chamado de um F3                                           �
//�������������������������������������������������������������������

If ValType(cGrupo) = "U"
	cGrupo := SKF->KF_CODGRP
Endif	

//��������������������������������������������������������������Ŀ
//� Verifica se ja existe este subgrupo para este grupo          �
//����������������������������������������������������������������
dbSelectArea("SKF")
dbSetOrder(1)
If DbSeek(xFilial("SKF")+ cGrupo + M->KF_CODSUBG)
	Help("",1,"JAGRAVADO")
	lRet := .F.
Endif	

//��������������������������������������������������������������Ŀ
//� Restaura a area de trabalho                                  �
//����������������������������������������������������������������
RestArea(aArea)

Return(lRet) // Retorno um valor logico esperado pela funcao

/*
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPRA060FKF �Autora � Solange Zanardi      � Data � 03/11/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Montando o filtro de subgrupos SKF                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPRA060FKF()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR - CONSULTA PADRAO                                  ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K.�24/08/04�710   �-Notacao, Sintaxe e Logica                  ���
���Michel M. �09/04/07�912   �Bops: 123262 - Quando chamado pelo cadastro ���
���          �        �      �de questoes nao estava levando em conta o   ���
���          �        �      �grupo que o usuario havia selecionado.      ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpra060Fkf(cGrupo)

Local lRet := .F.		// Retorno da funcao

//�����������������������������������������������������������������������������Ŀ
//� Se for chamado do cadastro de subgrupos, filtro a variavel da tabela SKF    �
//�������������������������������������������������������������������������������
If FunName() $ "GPRA060" 
	If (SKF->KF_CODGRP == SKF->KF_CODSUBG)
		lRet := .T.
	Endif                

//����������������������������������������������������������������������������������������Ŀ
//� Se for chamado do cadastro de questoes,  filtro a variavel de memoria da tabela SKF    �
//������������������������������������������������������������������������������������������
ElseIf FunName() $ "GPRA030" 	
	If (SKF->KF_CODGRP == M->KG_CODGRP)
		lRet := .T.
	Endif
//�����������������������������������������������������������������������������Ŀ
//� Se for chamado do cadastro de subgrupos, filtra a variavel da tabela SKG    �
//�������������������������������������������������������������������������������
Else
	If (SKF->KF_CODGRP == SKG->KG_CODGRP)
		lRet := .T.
	Endif
Endif

Return(lRet) // Retorna um valor logico esperado pela fun��o

/*
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr060FGrp �Autor  � Henry Fila           � Data � 23/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Montando o filtro de subgrupos quando utilizado no questio ���
���          � nario                                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gpr060FGrp()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR - CONSULTA PADRAO                                  ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpr060FGrp()

Local lRet     := .F.                                               // Retorno da funcao
Local nPosCod  := aScan(aHeader,{|x| AllTrim(x[2])=="KR_CODGRU"})  //Posicao do grupo no aCols de Questionarios

If nPosCod > 0
	//��������������������������������������������������������������Ŀ
	//� Verifica se o subgrupo pertence ao grupo                     �
	//����������������������������������������������������������������
	If aCols[n][nPosCod] == SKF->KF_CODGRP
		lRet := .T.
	Endif	
Endif                                                


Return(lRet) // Retorno um valor logico esperado pela funcao


/*
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr060FGr2 �Autor  � Henry Fila           � Data � 23/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Montando o filtro de subgrupos quando utilizado no questio ���
���          � nario                                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gpr060FGr2()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR - CONSULTA PADRAO                                  ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Tatiana   �11/10/06�      �Chamada da variavel cGrupo, validacao do F3 ���
���          �110046  �811   �para subgrupos                              ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpr060FGr2()  

Local lRet 		:= .F.  // Retorno da funcao

//��������������������������������������������������������������Ŀ
//� Verifica se o subgrupo pertence ao grupo                     �
//����������������������������������������������������������������
If Type('cGrupo') <> 'U' //Se private cGrupo estiver na stack
	If cGrupo == SKF->KF_CODGRP
		lRet := .T.
	Endif	
EndIf

Return(lRet) // Retorno um valor logico esperado pela funcao

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GPR060AfterCols � Autor � Conrado Q.      � Data � 29/01/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina executada durante a montagem do aCols                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �GPR060AfterCols( ExpC1, ExpA2 )                               ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias da tabela utilizada no FillGetDados              ���
���          �ExpA2: Array de registros utilizados                          ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Pesquisa e Resultado                                         ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GPR060AfterCols( cAlias, aRecnoArray )
	If ( Alias() == cAlias )
		aAdd( aRecnoArray, (cAlias)->( Recno() ) )
	EndIf
Return .T.