#INCLUDE "PONA430.CH"
#INCLUDE "PROTHEUS.CH"

Static lPort1510 	:= Port1510() 	//Verifica se Portaria 1510/2009 esta em vigor.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PONA430  � Autor � Leandro Drumond       � Data � 28/10/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Motivos para Desconsideracao                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PONA430()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � FNC  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia C.  �20/05/14�TPQAN3�Incluido o fonte da 11 para a 12 e efetu- ���
���            �        �      �ada a limpeza.                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function PONA430

Local aArea			:= GetArea()

Private cCadastro  := OemToAnsi( STR0009 ) // "Cadastro de Motivos"

//--Inclui registros padroes na RFD
GeraRFD()

/*
��������������������������������������������������������������Ŀ
� So Executa se os Modos de Acesso dos Arquivos Relacionados es�
� tiverm OK.											  	   �
����������������������������������������������������������������*/
IF ValidArqPon()

	Private aRotina := MenuDef()
	
	/*
	��������������������������������������������������������������Ŀ
	� Endereca a funcao de BROWSE                                  �
	����������������������������������������������������������������*/
	dbSelectArea ( "RFD" )
	dbGoTop()
	mBrowse( 6 , 1 , 22 ,75 , "RFD")
	
EndIF
	
RestArea( aArea )

Return( NIL )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Pona430Inc		�Autor�Leandro Drumond    � Data �28/10/2009�
�����������������������������������������������������������������������Ĵ
�Descri��o �Chamada a AxInclui com Validacao no TudoOk                  �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �PONA430                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �NIL															�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Function Pona430Inc( cAlias , nReg , nOpcx )
Return( AxInclui( cAlias , nReg , nOpcx , NIL , NIL , NIL , "Pona430TudOk()" ) )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Pona430Alt		�Autor�Leandro Drumond    � Data �28/10/2009�
�����������������������������������������������������������������������Ĵ
�Descri��o �Chamada a AxAltera com Validacao no TudoOk                  �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �PONA430                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �NIL															�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Function Pona430Alt( cAlias , nReg , nOpcx )

Local aAlter := NIL

If RFD->RFD_SISTEM == '1'
	aAlter := {"RFD_DESC"}
EndIf

Return( AxAltera( cAlias , nReg , nOpcx , NIL , aAlter , NIL , NIL , NIL ) ) 

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Pona430Del		�Autor�Leandro Drumond    � Data �06/11/2009�
�����������������������������������������������������������������������Ĵ
�Descri��o �Chamada a AxDeleta com Validacao no TudoOk                  �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �PONA430                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �NIL															�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Function Pona430Del( cAlias , nReg , nOpcx )

IF RFD->RFD_SISTEM == '1'
	MsgAlert( STR0010 , STR0011 ) //"Registros de uso exclusivo do sistema n�o podem ser deletados." # "Aten��o"
	Return(.F.)
EndIf

Return( AxDeleta( cAlias , nReg , nOpcx  ) )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Pona430TudOk	�Autor�Leandro Drumond    � Data �28/10/2009�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valida o Conteudo da Enchoice                               �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �PONA430                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �NIL															�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Function Pona430TudOk()

Local lTudoOk	:= .T.

Return( lTudoOk )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GeraRFD  � Autor � Leandro Drumond       � Data � 04/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de processamento da gravacao do RFD                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Processamento do Compatibilizador                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraRFD()

Local aRFD   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0

//���������������������������������������������������������������������������������������������������Ŀ
//� Preencha a matriz aRCB com os relacionamentos a serem criados. Utilize a mesma ordem indicada na  �
//� matriz aEstrut                                                             		                  �
//�����������������������������������������������������������������������������������������������������
				
If (cPaisLoc == "BRA")

	aEstrut := {"RFD_FILIAL","RFD_CODIGO","RFD_APLIC","RFD_TIPO","RFD_DESC","RFD_SISTEM"}
	
	Aadd(aRFD,{xFilial("RFD"),"01","1","1","INCLUSAO MANUAL"	,"1"})
	Aadd(aRFD,{xFilial("RFD"),"02","1","2","EXCLUSAO MANUAL"	,"1"})
	Aadd(aRFD,{xFilial("RFD"),"03","1","3","REJEICAO AUTOMATICA","1"})
	Aadd(aRFD,{xFilial("RFD"),"04","1","4","INCLUSAO AUTOMATICA","1"})

	dbSelectArea("RFD")
	RFD->( dbSetOrder( RetOrdem( "RFD" , "RFD_FILIAL+RFD_CODIGO+RFD_APLIC+RFD_TIPO" ) ) )

	For i:= 1 To Len(aRFD)
		If !Empty(aRFD[i][2])
			If !RFD->( dbSeek(aRFD[i,1]+aRFD[i,2]+aRFD[i,3]+aRFD[i,4] ) )
				RecLock("RFD",.T.)
				
				For j:=1 To Len(aRFD[i])
					If !Empty(FieldName(FieldPos(aEstrut[j])))
						FieldPut(FieldPos(aEstrut[j]),aRFD[i,j])
					EndIf
				Next j
				
				MsUnLock("RFD")
				dbCommit()
			EndIf
		EndIf
	Next i

EndIf

Return(Nil)

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Leandro Drumond  � Data �28/10/2009�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �PONA430                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/

Static Function MenuDef()
 
 Local aRotina := {;
							{ STR0004	, "PesqBrw"			, 0 , 1, ,.F. } ,; // "Pesquisar"
	                    	{ STR0005	, "AxVisual"		, 0 , 2 } ,; // "Visualizar"  
	                    	{ STR0006	, "Pona430Inc"		, 0 , 3 } ,; // "Incluir" 
	                     	{ STR0007	, "Pona430Alt"		, 0 , 4 } ,; // "Alterar"     
	                     	{ STR0008	, "Pona430Del"		, 0 , 5 }  ; // "Excluir"
	                    }  
	                    
Return aRotina
