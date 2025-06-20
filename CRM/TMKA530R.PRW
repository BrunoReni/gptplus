#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA530R.CH"
#DEFINE MAXITENS 500

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �TMKA530R  � Autor � Vendas Cliente        � Data � 26/05/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Servicos de SLA                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKA530R()

Private cCadastro	:= STR0001 		//"Servicos de SLA"
Private aRotina		:= MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("SUI")
dbSetOrder(1)
mBrowse(6,1,22,75,"SUI")

dbSelectArea("SUI")
dbSetOrder(1)

Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Vendas Cliente        � Data � 26.05.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMKA530R                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
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
	//�    6 - Alteracao sem inclusao de registro                    �
	//����������������������������������������������������������������
	Local aRotina := {	{ STR0002	,"AxPesqui"  	,0	,1	,0	,.F.	}	,;	//"Pesquisar"
						{ STR0003	,"Tk530RVisua"	,0	,2	,0	,.T.	}	,;	//"Visualizar"
						{ STR0004	,"Tk530RInclu"	,0	,3	,0	,.T.	}	,;	//"Incluir"
						{ STR0005	,"Tk530RAlter"	,0	,4	,0	,.T.	}	,;	//"Alterar"
						{ STR0006	,"Tk530RDelet"	,0	,5	,0	,.T.	} 	}	//"Excluir"
Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Tk530RIncl� Autor � Vendas Cliente        � Data �26/05/08  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclusao do Servico de SLA                            	  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Tk530RInclu(cAlias,nReg,nOpc)
Local lGravou		:= .F.
Local nOpcA			:= 0
Local oDlg			:= Nil
Local oGetD			:= Nil
Local nSaveSX8		:= GetSX8Len()
Local aPosObj   	:= {}										//Array com posicao dos objetos
Local aObjects  	:= {}										//Array com as coordenadas da tela
Local aSize     	:= {}										//Array com as dimensoes retornadas pelo MsAdvSize()
Local aInfo     	:= {}										//Array de informacoes de tela

Private aCols		:= {}
Private aHeader		:= {}

RegToMemory( "SUI", .T. )

//�����������������������Ŀ
//�Montagem aHeader/aCols �
//�������������������������
If Len(aHeader) == 0 .AND. Len(aCols) == 0
	FillGetDados(	nOpc			,"SUJ"			,1				,/*cSeek*/		,;
					/*{||cWhile}*/	,{|| .T. }		,/*aNoFields*/	,/*aYesFields*/	,; 
					/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/	,.T.			,;
					/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/	,/*bBeforeCols*/)
Endif

//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
aSize := MsAdvSize()
aAdd( aObjects, { 100, 100, .T., .T. } )
aAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects, .T.)
	
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

EnChoice( "SUI", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.F. )

oGetd := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Tk530RLINOK","Tk530RTUDOK",NIL,.T.,,,,MAXITENS)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(oGetd:TudoOk().And.Tk530RIncOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()})

If ( nOpcA == 1 )
	Begin Transaction
		lGravou := Tk530RGrava(1)
		If ( lGravou )
			EvalTrigger()
			While ( GetSX8Len() > nSaveSx8 )
				ConfirmSx8()
			EndDo
		EndIf
	End Transaction
EndIf

While ( GetSX8Len() > nSaveSx8 )
	RollBackSx8()
EndDo

Return(lGravou)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Tk530RAlte� Autor � Vendas Cliente        � Data �26/05/08  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Alteracao do Servico de SLA                            	  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Tk530RAlter(cAlias,nReg,nOpc)

Local lGravou		:= .F.
Local nOpcA			:= 0
Local oDlg			:= Nil
Local oGetD			:= Nil
Local nSaveSX8		:= GetSX8Len()
Local cSeek			:= ""			// Seek para montagem da aCols
Local cWhile		:= ""			// While para montagem da aHeader

Local aPosObj   	:= {}			//Array com posicao dos objetos
Local aObjects  	:= {}			//Array com as coordenadas da tela
Local aSize     	:= {}			//Array com as dimensoes retornadas pelo MsAdvSize()
Local aInfo     	:= {}			//Array de informacoes de tela

Private aCols		:= {}
Private aHeader		:= {}

//������������������������������������������������������Ŀ
//� Cria Variaveis de Memoria da Enchoice                �
//��������������������������������������������������������
RegToMemory( "SUI", .F. ) 

//�����������������������Ŀ
//�Montagem aHeader, aCols�
//�������������������������
cSeek	:= xFilial("SUJ")+M->UI_CODIGO
cWhile	:= "SUJ->UJ_FILIAL+SUJ->UJ_CODIGO"

If Len(aHeader) == 0 .AND. Len(aCols) == 0
	FillGetDados(	nOpc			,"SUJ"		   	,1				,cSeek				,;
	   		  		{|| &cWhile }	,{|| .T. }		,/*aNoFields*/	,/*aYesFields*/		,; 
					/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/	,/*lEmpty*/			,;
					/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/	,/*bBeforeCols*/	)
Endif

//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
aSize := MsAdvSize()
aAdd( aObjects, { 100, 100, .T., .T. } )
aAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
//DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
EnChoice( "SUI", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.T. )
				
oGetd := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Tk530RLINOK","Tk530RTUDOK",NIL,.T.,,,,MAXITENS)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(oGetd:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()})

If ( nOpcA == 1 )
	Begin Transaction
		lGravou := Tk530RGrava(2)
		If ( lGravou )
			EvalTrigger()
			While ( GetSX8Len() > nSaveSx8 )
				ConfirmSx8()
			EndDo
		EndIf
	End Transaction
EndIf

While ( GetSX8Len() > nSaveSx8 )
	RollBackSx8()
EndDo                

Return(lGravou)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Tk530RDele� Autor � Vendas Cliente        � Data �26/05/08  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exclusao do Servico de SLA	                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Tk530RDelet(cAlias,nReg,nOpc)
Local nOpcA			:= 0
Local oDlg			:= Nil
Local oGetD			:= Nil
Local nSaveSX8		:= GetSX8Len()
Local cSeek			:= ""			// Seek para montagem da aCols
Local cWhile		:= ""			// While para montagem da aHeader

Local aPosObj   	:= {}			//Array com posicao dos objetos
Local aObjects  	:= {}			//Array com as coordenadas da tela
Local aSize     	:= {}			//Array com as dimensoes retornadas pelo MsAdvSize()
Local aInfo     	:= {}			//Array de informacoes de tela

Private aCols		:= {}
Private aHeader		:= {}

//������������������������������������������������������Ŀ
//� Cria Variaveis de Memoria da Enchoice                �
//��������������������������������������������������������
RegToMemory( "SUI", .F. ) 

//�����������������������Ŀ
//�Montagem aHeader, aCols�
//�������������������������
cSeek	:= xFilial("SUJ")+M->UI_CODIGO
cWhile	:= "SUJ->UJ_FILIAL+SUJ->UJ_CODIGO"

If Len(aHeader) == 0 .AND. Len(aCols) == 0
	FillGetDados(	nOpc			,"SUJ"		   	,1				,cSeek				,;
	   		  		{|| &cWhile }	,{|| .T. }		,/*aNoFields*/	,/*aYesFields*/		,; 
					/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/	,/*lEmpty*/			,;
					/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/	,/*bBeforeCols*/	)
Endif

//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
aSize := MsAdvSize()
aAdd( aObjects, { 100, 100, .T., .T. } )
aAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

EnChoice( "SUI", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.T. )

//oGetd := MsGetDados():New(034,005,138,314,nOpc,"AllwaysTrue","AllwaysTrue","",.F.,NIL,NIL,NIL,MAXITENS)
oGetd := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","",.F.,NIL,NIL,NIL,MAXITENS)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()})

If ( nOpcA == 1 )
	Begin Transaction
		Tk530RGrava(3)
        EvalTrigger()
		While ( GetSX8Len() > nSaveSx8 )
			ConfirmSx8()
		EndDo
	End Transaction
EndIf
	
While ( GetSX8Len() > nSaveSx8 )
	RollBackSx8()
EndDo

Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Tk530RVisu� Autor � Vendas Cliente        � Data �26/05/08  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Visualizacao do Servico de SLA                       	  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Tk530RVisua(cAlias,nReg,nOpc)
Local nOpcA			:= 0
Local oDlg			:= Nil
Local oGetD			:= Nil
Local cSeek			:= ""			// Seek para montagem da aCols
Local cWhile		:= ""			// While para montagem da aHeader

Local aPosObj   	:= {}			//Array com posicao dos objetos
Local aObjects  	:= {}			//Array com as coordenadas da tela
Local aSize     	:= {}			//Array com as dimensoes retornadas pelo MsAdvSize()
Local aInfo     	:= {}			//Array de informacoes de tela

Private aCols		:= {}
Private aHeader		:= {}

//������������������������������������������������������Ŀ
//� Cria Variaveis de Memoria da Enchoice                �
//��������������������������������������������������������     
RegToMemory( "SUI", .F. ) 

//�����������������������Ŀ
//�Montagem aHeader, aCols�
//�������������������������
cSeek	:= xFilial("SUJ")+M->UI_CODIGO
cWhile	:= "SUJ->UJ_FILIAL+SUJ->UJ_CODIGO"

If Len(aHeader) == 0 .AND. Len(aCols) == 0
	FillGetDados(	nOpc			,"SUJ"		   	,1				,cSeek				,;
	   		  		{|| &cWhile }	,{|| .T. }		,/*aNoFields*/	,/*aYesFields*/		,; 
					/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/	,/*lEmpty*/			,;
					/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/	,/*bBeforeCols*/	)
Endif

//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
aSize := MsAdvSize()
aAdd( aObjects, { 100, 100, .T., .T. } )
aAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

EnChoice( cAlias,nReg, nOpc,,,,,aPosObj[1], , 3 , , , , , ,.T. )
oGetd := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","",.F.,NIL,NIL,NIL,MAXITENS)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Tk530RGrav� Autor � Vendas Cliente        � Data � 26/05/08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gravacao do Servico de SLA                             	  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Indica se a gravacao foi efetuada ou nao                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Tk530RGrava(nOpcao)

Local nCntFor := 0
Local nUsado  := Len(aHeader)
Local nCntFor2:= 0
Local lGravou := .F.
Local bCampo  := {|x| FieldName(x) }
Local nPosEnt := aScan(aHeader,{|x| AllTrim(x[2]) == "UJ_ENTIDA" })
Local nRecnoSUI := 0
		
Do Case
	Case ( nOpcao <> 3 )
		
		//�������������������������������������������������������Ŀ
		//� Verifica se existe um item valido no acols            �
		//���������������������������������������������������������
		lGravou := !Empty( Ascan( aCols, { |x| !x[nUsado+1] .AND. !Empty(x[nPosEnt]) } ) )
				
		DbSelectArea("SUI") 
		DbSetOrder(1)
		If DbSeek(xFilial("SUI")+M->UI_CODIGO)
			nRecnoSUI := SUI->( Recno() ) 
		EndIf 	

		//�������������������������������������������������������Ŀ
		//� Grava arquivo SUI (Cabecalho do servico de SLA)       �
		//���������������������������������������������������������
		If ( lGravou )
			RecLock("SUI",!Found())
			For nCntFor := 1 To FCount()
				If ( "FILIAL"$Field(nCntFor) )
					SUI->(FieldPut(nCntFor,xFilial("SUI")))
				Else
					SUI->(FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor))))
				EndIf
			Next nCntFor
            
			nRecnoSUI := SUI->( Recno() ) 
			MsUnLock()
			SUI->( FKCommit() ) 
		EndIf 	
		
		For nCntFor := 1 To Len(aCols)
			If ( !aCols[nCntFor][nUsado+1] )
				dbSelectArea("SUJ")
				dbSetOrder(1)
				If ( dbSeek(xFilial("SUJ") + M->UI_CODIGO + aCols[nCntFor][nPosEnt]) )
					RecLock("SUJ",.F.)
				Else
					RecLock("SUJ",.T.)
				EndIf
				For nCntFor2 := 1 To nUsado
					If ( aHeader[nCntFor2][10] <> "V" )
						SUJ->(FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				SUJ->UJ_FILIAL 	:= xFilial("SUJ")
				SUJ->UJ_CODIGO 	:= M->UI_CODIGO
				lGravou := .T.
				MsUnLock()
				SUJ->( FKCommit() ) 
			Else
				dbSelectArea("SUJ")
				dbSetOrder(1)
				If ( dbSeek(xFilial("SUJ") + M->UI_CODIGO + aCols[nCntFor][nPosEnt]) )
					RecLock("SUJ")
					dbDelete()
				EndIf
			EndIf
		Next nCntFor

	OtherWise	//Exclusao

		//��������������������������������Ŀ
		//� Deleta itens do servico de SLA �
		//����������������������������������
		For nCntFor := 1 To Len(aCols)
			dbSelectArea("SUJ")
			dbSetOrder(1)
			If ( dbSeek(xFilial("SUJ") + M->UI_CODIGO + aCols[nCntFor][nPosEnt]) )
				RecLock("SUJ")
				dbDelete()
			EndIf
		Next
		
		//�����������������������������������������������������Ŀ
		//� Deleta Cabecalho do Servico de SLA                  �
		//�������������������������������������������������������
		DbSelectArea("SUI")
		RecLock("SUI")
		DbDelete()
EndCase

Return(lGravou)


/*     	
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Tk530RLinO� Autor � Vendas Cliente        � Data � 26/05/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da LinhaOk                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Tk530RLinOk()

Local nUsado 	:= Len(aHeader)
Local nCntFor	:= 1
Local lRetorno	:= .T.
Local nPosEnt	:= aScan(aHeader,{|x| AllTrim(x[2])=="UJ_ENTIDA"})
Local nPosVlr	:= aScan(aHeader,{|x| AllTrim(x[2])=="UJ_VALOR"})

If ( !aCols[n][nUsado+1] )
	If ( (Empty(aCols[n][nPosEnt]) .AND. Len(aCols)==1) .OR.;
			Empty(aCols[n][nPosVlr]) )

		//Help(" ",1,"Tk530RLIN01")
		MsgAlert(STR0008, STR0007)		//"Os campos Entidade e Valor devem ser preenchidos" ### "Aviso"
		lRetorno := .F.
	EndIf
	
	If (lRetorno)
		For nCntFor := 1 To Len(aCols)
			If ( aCols[n][nPosEnt] == aCols[nCntFor][nPosEnt] .AND.;
				 n <> nCntFor .AND. !aCols[nCntFor][nUsado+1] )

				MsgAlert(STR0009, STR0007)		//"Esta Entidade ja foi incluida em outro item!" ### "Aviso"
				lRetorno := .F.
			EndIf
		Next nCntFor	
	EndIf
	
EndIf

//��������������������������������������������������������������Ŀ
//� P.E. para permitir validacao do Usuario                      �
//����������������������������������������������������������������
If ExistBlock( "TK530RLOK" ) 
   lRetorno := ExecBlock( "TK530RLOK", .F., .F., { lRetorno } ) 
EndIf 	   

Return(lRetorno)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Tk530RTudO� Autor � Vendas Cliente        � Data � 26/05/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da TudoOk                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Tk530RTudOk()
Return( .T. ) 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Tk530RIncO� Autor � Vendas Cliente        � Data �26/05/08  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da inclusao                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpL1 := Tk530RIncOk()                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 -> Validacao                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/       
Function Tk530RIncOk() 
LOCAL lRet := .T.       

//������������������������������������������������������������������������Ŀ
//� Verifica se ja existe na base                                          �
//��������������������������������������������������������������������������
SUI->( dbSetOrder( 1 ) ) 
If SUI->( dbSeek( xFilial( "SUI" ) + M->UI_CODIGO ) ) 
   lRet := .F.
   Help( " ", 1, "JAGRAVADO" ) 
EndIf 

Return( lRet )            