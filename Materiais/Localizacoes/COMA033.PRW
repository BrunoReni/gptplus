#INCLUDE "PROTHEUS.CH"
#INCLUDE "COMA033.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � COMA033  � Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de Vias de Transporte - SIGACOM Intenacional       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGACOM Internacional                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                        
Function COMA033()                         

Local lImportOk  := SuperGetMv("MV_COMPINT") == .T. .And. SuperGetMv("MV_EASY") == "N" .And. cPaisLoc <> "BRA"

Private aRotina  := MenuDef()
Private cCadastro:= STR0001 //"Vias de Transporte"

//��������������������������������������������������������������Ŀ
//� Se as condicoes de uso das funcionalidades de importacao     �
//� estiverem ok endereca a funcao de BROWSE.                    �
//����������������������������������������������������������������
If lImportOk
	mBrowse(006,001,022,075,"DBF")  
Else
	Help(" ",1,"COMPINT") 
EndIf

Return .T.     
                
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C033Visual� Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Vias de Transporte              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C033Visual(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � COMA033                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C033Visual(cAlias,nReg,nOpc)

Local aArea	   := GetArea()
Local nOpcA    := 0      
Local aButtons := {}
Local aUsrBut  := {}

//��������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo        �
//����������������������������������������������
Private aTELA[0][0],aGETS[0]

If ExistBlock( "CA033BUT" ) 
	If Valtype( aUsrBut := Execblock( "CA033BUT", .F., .F., {nOpc} ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIF 
EndIf 		

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA := AxVisual("DBF",nReg,nOpc,,,,,aButtons)

RestArea(aArea)

Return Nil
      
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C033Inclui� Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Vias de Transporte              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C033Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � COMA033                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C033Inclui(cAlias,nReg,nOpc)

Local aArea	   := GetArea()
Local aButtons := {}
Local aUsrBut  := {}
Local nOpcA    := 0
Local lAutomato	:= isBlind()
Local aAuto 	:= {} 

//��������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo        �
//����������������������������������������������
Private aTELA[0][0],aGETS[0]

If ExistBlock( "CA033BUT" )
	If Valtype( aUsrBut := Execblock( "CA033BUT", .F., .F., {nOpc} ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } )
	EndIF
EndIf

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
If lAutomato
	If FindFunction("GetParAuto")
		aRetAuto	:= GetParAuto("COMA033TESTCASE")
		aAuto 		:= aRetAuto[1]
	Endif
	nOpcA := AxInclui("DBF",nReg,nOpc,,,,,,,aButtons,,aAuto )
Else
	nOpcA := AxInclui("DBF",nReg,nOpc,,,,,,,aButtons )
Endif
If nOpcA == 1
	If ExistBlock( "CA033INC" )
		Execblock( "CA033INC", .F., .F.)
	EndIf
EndIf

RestArea(aArea)

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C033Altera� Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Vias de Transporte              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C033Altera(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � COMA033                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C033Altera(cAlias,nReg,nOpc)

Local aArea	   := GetArea()
Local aButtons := {}
Local aUsrBut  := {}
Local nOpcA:=0
Local lAutomato	:= isBlind()
Local aAuto 	:= {} 

//��������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo        �
//����������������������������������������������
Private aTELA[0][0],aGETS[0]
                                        
If ExistBlock( "CA033BUT" )
	If Valtype( aUsrBut := Execblock( "CA033BUT", .F., .F., {nOpc} ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } )
	EndIF
EndIf

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
If lAutomato
	If FindFunction("GetParAuto")
		aRetAuto	:= GetParAuto("COMA033TESTCASE")
		aAuto 		:= aRetAuto[1]
	Endif
	nOpcA := AxAltera( "DBF", nReg, nOpc, , , , ,,,,aButtons,,aAuto)
Else
	nOpcA := AxAltera( "DBF", nReg, nOpc, , , , ,,,,aButtons)
Endif

If nOpcA == 1
	If ExistBlock( "CA033ALT" )
		Execblock( "CA033ALT", .F., .F. )
	EndIf
EndIf

RestArea(aArea)

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C033Deleta� Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Vias de Transporte              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C033Deleta(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � COMA033                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C033Deleta(cAlias,nReg,nOpc)

Local aArea	   := GetArea()
Local aButtons := {}
Local aUsrBut  := {}
Local nOpcA    := 0  
Local oDlg
Local aObjects := {}                  
Local aSize    := {} 
Local aInfo    := {}
Local lAutomato	:= isBlind()

//��������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo        �
//����������������������������������������������
Private aTELA[0][0],aGETS[0]

If ExistBlock( "CA033BUT" ) 
	If Valtype( aUsrBut := Execblock( "CA033BUT", .F., .F., {nOpc} ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIF 
EndIf 		

If SoftLock("DBF") 
	//�������������������������������������������������Ŀ
	//� Ajusta a largura para o tamanho padrao Protheus �
	//���������������������������������������������������
	aSize := MsAdvSize()       
	aSize[5] := 1155      
	aSize[3] := 318
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo    := { aSize[1], aSize[2], aSize[3], aSize[4], 2, 2 } 
	aPosObj := MsObjSize( aInfo, aObjects ) 
	
	If !lAutomato
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL	
		nOpcA:=Enchoice( "DBF", nReg, nOpc,,,,,aPosObj[1])
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 0,oDlg:End()},,aButtons)
	Else 
		nOpca := 1
	EndIf
	
	If nOpcA == 1  
		//��������������������������������������������������������������Ŀ
		//� Apos passar por todas as verificacoes , deleta o registro    �
		//����������������������������������������������������������������
		If COMA033Ex()   // Se for necessario desenvolver funcao para validacao de exclusao                         
			Begin Transaction          
			dbSelectArea("DBF") 
			RecLock("DBF",.F.)
			dbDelete()
			End Transaction
		EndIf
	EndIf

	MsUnLockAll()
	
EndIf

RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �COMA033EX � Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se pode ser feita a exclusao                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function COMA033Ex()

Local aArea	:= GetArea()
Local lRet	:= .T.

//��������������������������������������������������������������������Ŀ
//� Se necessario desenvolver validacao para excluir ou nao o registro.�
//� Help(" ",1,"C033DELE")                                             �
//����������������������������������������������������������������������

If lRet
	If (ExistBlock("CA033EXC"))
		lRet := ExecBlock("CA033EXC",.F.,.F.)
		If Valtype( lRet ) <> "L"
			lRet := .T.
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �COMA033Vld� Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao de dicionario de dados da tabela DBF             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Dicionario da tabela DBF do COMA033                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function COMA033Vld()

Local cX5_DESC

If !Empty(cX5_DESC:=Tabela("Y3",LEFT(M->DBF_CODVIA,1)))
   M->DBF_CODVIA := Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
Else
   M->DBF_CODVIA := Space(15)
   Return .F.
EndIf

lRefresh:=.T.

Return .T.

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()     

Private aRotina	:= { 	{STR0005,"AxPesqui"  , 0 , 1, 0, .F.},;    // "Pesquisar"
						{STR0006,"C033Visual", 0 , 2, 0, nil},;    // "Visualizar"
						{STR0007,"C033Inclui", 0 , 3, 0, nil},;    // "Incluir"
						{STR0008,"C033Altera", 0 , 4, 0, nil},;    // "Alterar"
						{STR0009,"C033Deleta", 0 , 5, 3, nil}}     // "Excluir"	

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("CMA033MNU")
	ExecBlock("CMA033MNU",.F.,.F.)
EndIf

Return(aRotina) 