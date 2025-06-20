#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDA035.CH"

Static aList := {} //Para trazer os campos da ListBox da tabela MA6 (Cache)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CRDA035   � Autor � Fernando Salvatori � Data �  23/06/2003 ���
�������������������������������������������������������������������������͹��
���Descricao � Layout para geracao do arquivo de controle grafico de      ���
���          � cartoes.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.           ���
�������������������������������������������������������������������������͹��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������͹��
���MONAEL RIBEIRO�30/01/04�DADALT�Inclus�o da Op��o Delimitador           ���
���Machima       �04/07/05�081261�Acerto no titulo do aHeader para o campo���
���              �        �      �Posicao. Considerar dois digitos para a ���
���              �        �      �posicao do campo no arquivo texto       ���
���Conrado Q.    �26/02/07�119542�Retirado ajustes de dicion�rio.         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDA035
Local nOpc 			:= 0
Private cFileGer 	:= ""
Private cFileBk  	:= ""

//"Layout para controle gr�fico de cart�es" ### "Selecione o tipo de arquivo que deseja configurar: " ### "&Enviar" ### "&Receber"
nOpc := Aviso( STR0001, STR0030, { STR0031, STR0032 } )

If nOpc == 1
	cFileGer := "ENVCART.CRD"
	cFileBk  := "ENVCART.OLD"

	If !Pergunte("CRDA31", .T.)
		Return
	EndIf
	
	CA035Man(Iif(mv_par01==1, .T., .F.))
ElseIf nOpc == 2
	cFileGer := "RECCART.CRD"
	cFileBk  := "RECCART.OLD"
	
	If !Pergunte("CRDA32", .T.)
		Return
	EndIf
	
	CA035Man(Iif(mv_par01==1, .T., .F.))
EndIf
                   
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ChkDelimit�Autor  �MONAEL P. RIBEIRO   � Data �  12/02/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Checa se o campo relacionamento � Delimitador e bloqueia   ���
���          � acesso a quem tiver essa fun��o na posi��o Valid           ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA035                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ChkDelimit()
Local lRet := .T.
	If aCols[n][04] == "3"
		MsgStop( STR0033, STR0034 )		// "Op��o invalida para tipo relat�rio Delimitador" ### "Op��o invalida"
		lRet := .F.
	EndIf
Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CA035Man  �Autor  �Fernando Salvatori  � Data �  25/06/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa de Layout para geracao do Arquivo de Layout de    ���
���          � confeccao de cartao.                                       ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.           ���
�������������������������������������������������������������������������͹��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������͹��
���MONAEL RIBEIRO�30/01/04�DADALT�Inclus�o da Op��o Delimitador           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CA035Man(lDelimit)
Local aSize      := MsAdvSize()  		 //Size da tela.
Local aObjects   := {}  				 //Objetos da tela
Local aPosObj    := {}  				 //Posicoes do objeto
Local aInfo      := {}  				 //Posicoes do objeto
Local aHeader    := {}  				 //aHeader da msgetdados
Local aCols      := {}  				 //aCols da Msgetdados
Local nGd_Insert := 1  					 //Insert
Local nGd_UpDate := 2  					 //Update
Local nGd_Delete := 4                    //Delete
Local lR5        := GetRpoRelease("R5")  // Indica se o release e 11.5
Local aButtons 	 := {}

Private cCadastro := STR0001 //"Layout para controle gr�fico de cart�es" //Variavel principal da dialog
Private oDlg      //Objeto da dialog
Private oGetDados //Objeto da msgetdados
Private oBtCan    //Objeto do botao de cancelar
Private oBtSal    //Objeto do botao de salvar
Private oBtCon    //Objeto do botao de consultar

//�������������������������������������������������������������������������Ŀ
//� Montagem do Header.                                                     �
//���������������������������������������������������������������������������
If lDelimit
	AAdd(aHeader,{ STR0039, "nPos"  , "9999", 004, 0 , ".T." , "�" , "N", "", "", NIL}) 	//"Posi��o
Else
	AAdd(aHeader,{ STR0002, "nPosIni", "9999", 004, 0 , ".T." , "�" , "N", "", "", NIL})  //"Pos. Inicial"
	AAdd(aHeader,{ STR0003, "nTamam" , "9999", 004, 0 , ".T." , "�" , "N", " ", " ", NIL}) 	//"Tamanho"
EndIf
AAdd(aHeader,{ STR0004, "cRetorno" , "@!"  , 030, 0 , ".T." , "�" , "C", " ", " ", NIL}) 	//"Retorno"
If lDelimit
	AAdd(aHeader,{STR0005,"cRelac"   ,"@!"  ,001,0 ,".T." ,"�" ,"C","","", STR0035, "2"})//"Utiliza Relacionamento?" ### "1=Sim;2=N�o;3=Delimitador"
Else
	AAdd(aHeader,{STR0005,"cRelac"   ,"@!"  ,001,0 ,".T." ,"�" ,"C","","", STR0036, "2"})//"Utiliza Relacionamento?" ### "1=Sim;2=N�o"
EndIf
AAdd(aHeader,{STR0006,"cAliasSec","@!"  ,003,0 ,"ChkDelimit() .And. (Vazio() .Or. ExistCpo('SX2'))" ,"�" ,"C",""," ",NIL})//"Alias"
AAdd(aHeader,{STR0007,"nOrdemSec","99"  ,002,0 ,"ChkDelimit()" ,"�" ,"N"," "," ",NIL})//"Ordem"
AAdd(aHeader,{STR0008,"cRegra"   ,"@!"  ,150,0 ,"ChkDelimit()" ,"�" ,"C"," "," ",NIL})//"Regra"   
                                                          
//����������������������������������������������������Ŀ  
//�Posicao dos campos do aCols:                        � 
//�                                                    � 
//�1 - Posicao Inicial da geracao do arquivo           � 
//�2 - Posicao Final da geracao do arquivo             �
//�3 - Retorno do campo desejado para o arquivo        �
//�4 - Flag que verifica se deseja fazer relacionamento�
//�5 - Alias secundario do relacionamento              �
//�6 - Ordem utilizada no relacionamento               �
//�7 - Regra de pesquisa ( Seek ) para o relacionamento�
//������������������������������������������������������

//�������������������������������������������������������������������������Ŀ
//� Faz o preenchimento do aCols.                                           �
//���������������������������������������������������������������������������
aCols := aClone( CA035Abrir(Nil, lDelimit) )

If valType(aCols) != "U"
	If !Empty(aCols) .And. valType(aCols[1]) == "C" .And. aCols[1] == "FIM"
		Return
	EndIf
EndIf

//�������������������������������������������������������������������������Ŀ
//� Define as posicoes da GetDados e Paineis.                               �
//���������������������������������������������������������������������������
AAdd( aObjects, {  100, 100, .T., .T. } )      //GetDados
aInfo 	 := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
aPosObj  := MsObjSize( aInfo, aObjects, .T. , .F. )

//�������������������������������������������������������������������������Ŀ
//� Montagem da tela.                                                       �
//���������������������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL

//�������������������������������������������������������������������������Ŀ
//� MsGetDados.                                                             �
//���������������������������������������������������������������������������
oGetDados := MsNewGetDados():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4],;
GD_INSERT+nGD_DELETE+nGD_UPDATE,"CA035LinOk()",,"",,,120,,,;
,oDlg,aHeader,aCols)
  
//�������������������������������������������������������������������������Ŀ
//� Caso seja Vers�o 11.5 exibe a EnchoiceBar, na parte inferior da tela    � 
//���������������������������������������������������������������������������
If lR5
	Aadd( aButtons, {"EDIT"	 , {|| CA035Consulta()}, STR0022, STR0022 , {|| .T.}} ) 	//"Consulta de Campos (Ctrl + C)"
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| IIf(CA035TudoOk(),(CA035Salvar(lDelimit),oDlg:End()) ,NIL)},{||oDlg:End()},,@aButtons))
Else	
	ACTIVATE MSDIALOG oDlg ON INIT ( CA035ChoiceBar(lDelimit),CA035SetKeys(.T.) )
EndIf	

//�������������������������������������������������������������������������Ŀ
//� Limpando Keys para retorno ao menu principal.                           �
//���������������������������������������������������������������������������
CA035SetKeys(.F.)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CA035TudoO�Autor  �Fernando Salvatori  � Data �  23/06/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     � Checa se as informacoes de gravacao esta ok.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA035                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CA035TudoOk()
Local nX := 0 //Contador

//�������������������������������������������������������������������������Ŀ
//� Faz a consistencia do campo de Retorno.                                 �
//���������������������������������������������������������������������������
For nX := 1 to Len( oGetDados:aCols )
	If !aTail(oGetDados:aCols[nX]) .And. Empty( oGetDados:aCols[nX][3] )
		MsgStop(STR0009,STR0010  )//"Selecione um campo para o retorno"//"Aten��o"
		Return .F.
	EndIf
Next nX

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CA035Salva�Autor  �Fernando Salvatori  � Data �  06/23/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Salva as informacoes do aCols para o arquivo CARTAO.CRD    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA035                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CA035Salvar(lDelimit)
Local nX := 0                                  //Contador do sistema
Local aBkCols := {}                            //BackUp do aCols para limpeza do mesmo
Local nHdl                                     //Handle do TXT
Local cArq    := "\"+CurDir()+cFileGer         //Arquivo do sistema
Local cArqOld := "\"+CurDir()+cFileBk          //Arquivo Backup
Local cLin    := ""                            //Linha do TXT
Local cConteudo := ""                          //Conteudo do aCols para tratamento antes de grava-lo no txt

//�������������������������������������������������������������������������Ŀ
//� Solicita confirmacao da gravacao.                                       �
//���������������������������������������������������������������������������
If !MsgYesNo(STR0011,STR0010)//"Confirma as altera��es?"//"Aten��o"
	Return .F.
EndIf

//�������������������������������������������������������������������������Ŀ
//� Seleciona os registros do aCols que estejam disponiveis para geracao.   �
//���������������������������������������������������������������������������
For nX := 1 to Len( oGetDados:aCols )
	If ! aTail( oGetDados:aCols[nX] )
		AAdd( aBkCols, oGetDados:aCols[nX] )
	EndIf
Next nX

//�������������������������������������������������������������������������Ŀ
//� Se todos os registros estiverem apagados, remover o arquivo CARTAO.CRD  �
//���������������������������������������������������������������������������
If Empty( aBkCols )
	AAdd( aBkCols,Array(8) )
	
	If lDelimit
		aBkCols[1][1] := 0000
		aBkCols[1][2] := Space(30)
		aBkCols[1][3] := "2"
		aBkCols[1][4] := Space(3)
		aBkCols[1][5] := 0
		aBkCols[1][6] := Space(100)
		aBkCols[1][7] := .F.
		aBkCols[1][8] := .F.
	Else
		aBkCols[1][1] := 0000
		aBkCols[1][2] := 0000
		aBkCols[1][3] := Space(30)
		aBkCols[1][4] := "2"
		aBkCols[1][5] := Space(3)
		aBkCols[1][6] := 0
		aBkCols[1][7] := Space(100)
		aBkCols[1][8] := .F.
	EndIf
	
	//�������������������������������������������������������������������������Ŀ
	//� Atualiza aCols.                                                         �
	//���������������������������������������������������������������������������
	oGetDados:aCols := aClone( aBkCols )
	oGetDados:oBrowse:Refresh()
	
	//�������������������������������������������������������������������������Ŀ
	//� Caso exista o arquivo, faz um Backup e logo em seguida, apago.          �
	//���������������������������������������������������������������������������
	If File(cArq)
		If File(cArqOld)
			FErase(cArqOld)
		EndIf
		__CopyFile( cArq, cArqOld )
		FErase(cArq)
	EndIf
EndIf

//�������������������������������������������������������������������������Ŀ
//� Atualiza aCols.                                                         �
//���������������������������������������������������������������������������
oGetDados:aCols := aClone( aBkCols )
oGetDados:oBrowse:Refresh()

//�������������������������������������������������������������������������Ŀ
//� Caso exista o arquivo, faz um Backup e logo em seguida, apago.          �
//���������������������������������������������������������������������������
If File(cArq)
	If File(cArqOld)
		FErase(cArqOld)
	EndIf
	__CopyFile( cArq, cArqOld )
	FErase(cArq)
EndIf

//�������������������������������������������������������������������������Ŀ
//� Crio o arquivo .CRD                                                     �
//���������������������������������������������������������������������������
nHdl := FCreate(cArq)

//�������������������������������������������������������������������������Ŀ
//� Verifico sua integridade.                                               �
//���������������������������������������������������������������������������
If nHdl == -1
	//"Existem problemas para gera��o do arquivo: "
	//" no servidor da aplica��o, contate o administrador do sistema !"
	//"Aten��o"
	MsgAlert(STR0012 +cArq+ STR0013,STR0010)
	__CopyFile( cArqOld, cArq )
	Return
Endif

If lDelimit
	If valtype(mv_par01) != "U" .And. mv_par01 == 1
	  	If valtype(mv_par02) == "C" .And. valtype(mv_par03) == "C".And. valtype(mv_par04) == "N"
			cLin := "Delimited"+AllTrim(mv_par02)+AllTrim(mv_par03)+AllTrim(Str(mv_par04))+Chr(13)+Chr(10)
		Else
			cLin := "Delimited"+Chr(13)+Chr(10)
		EndIf
	EndIf
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgYesNo(STR0014,STR0010)//"Aten��o"//"Ocorreu um erro na grava��o do arquivo. Continua?"
			FClose(nHdl)
			Return .T.
		Endif
	EndIf
Else
	cLin := "Undelimited"+Chr(13)+Chr(10)
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgYesNo(STR0014,STR0010)//"Aten��o"//"Ocorreu um erro na grava��o do arquivo. Continua?"
			FClose(nHdl)
			Return .T.
		Endif
	EndIf
EndIf

//�������������������������������������������������������������������������Ŀ
//� Realizo a gravacao do arquivo TXT.                                      �
//���������������������������������������������������������������������������
For nX := 1 to Len( oGetDados:aCols )
	
	cLin := ""
	
	If lDelimit
		cConteudo := Alltrim(Str(oGetDados:aCols[nX][1]))
		cLin += PadR( cConteudo ,004 )
	
		cConteudo := oGetDados:aCols[nX][2]
		cLin += PadR( cConteudo ,030 )
	
		cConteudo := oGetDados:aCols[nX][3]
		cLin += PadR( cConteudo ,001 )
	
		cConteudo := oGetDados:aCols[nX][4]
		cLin += PadR( cConteudo ,003 )
	
		cConteudo := AllTrim(Str(oGetDados:aCols[nX][5]))
		cLin += PadR( cConteudo ,002 )
	
		cConteudo := oGetDados:aCols[nX][6]
		cLin += PadR( cConteudo ,150 )
	
	Else
		cConteudo := Alltrim(Str(oGetDados:aCols[nX][1]))
		cLin += PadR( cConteudo ,004 )
	
		cConteudo := Alltrim(Str(oGetDados:aCols[nX][2]))
		cLin += PadR( cConteudo ,004 )
	
		cConteudo := oGetDados:aCols[nX][3]
		cLin += PadR( cConteudo ,030 )
	
		cConteudo := oGetDados:aCols[nX][4]
		cLin += PadR( cConteudo ,001 )
	
		cConteudo := oGetDados:aCols[nX][5]
		cLin += PadR( cConteudo ,003 )
	
		cConteudo := Alltrim(Str(oGetDados:aCols[nX][6]))
		cLin += PadR( cConteudo ,002 )
	
		cConteudo := oGetDados:aCols[nX][7]
		cLin += PadR( cConteudo ,150 )
	EndIf
	
	cLin += Chr(13)+Chr(10)
	
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgYesNo(STR0014,STR0010)//"Aten��o"//"Ocorreu um erro na grava��o do arquivo. Continua?"
			Exit
		Endif
	Endif
	
Next nX

//�������������������������������������������������������������������������Ŀ
//� Finalizo a gravacao.                                                    �
//���������������������������������������������������������������������������
FClose(nHdl)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CA035Abrir�Autor  �Fernando Salvatori  � Data �  24/06/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     � Faco a abertura do arquivo .CRD                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA035                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CA035Abrir(cFile, lArg, aRecDelimit)   
Local cArq    := "\"+CurDir()               //Arquivo .CRD
Local aRet    := {}                         //Retorno da Funcao
Local cLinha  := ""                         //Linha do arquivo
Local lDelimited := .F.
Local nPosRet := 0
Local cSepara := ""
Local cDelimit := ""

//�������������������������������������������������������������������������Ŀ
//� Compatibilidade com outros programas.                                   �
//���������������������������������������������������������������������������
If Type("cFileGer") == "C"
	cFile := cFileGer
EndIf                

cArq += cFile

//�������������������������������������������������������������������������Ŀ
//� Se o arquivo nao existe, inicializo um novo registro no aCols.          �
//���������������������������������������������������������������������������
If !File(cArq)
	Return aRet
EndIf

//�������������������������������������������������������������������������Ŀ
//� Faco a abertura do arquivo TXT.                                         �
//���������������������������������������������������������������������������
FT_FUSE( cArq )

//�������������������������������������������������������������������������Ŀ
//� Avanco para a primeira linha.                                           �
//���������������������������������������������������������������������������
FT_FGOTOP()

//�������������������������������������������������������������������������Ŀ
//� Carrego todos os registros do TXT para o aCols.                         �
//���������������������������������������������������������������������������
Do While !FT_FEOF()
	cLinha := FT_FREADLN() //Leitura da linha
	If AllTrim(Upper(SubStr(cLinha, 1, 9))) == 'DELIMITED' .OR. AllTrim(Upper(cLinha)) == 'UNDELIMITED'
		If AllTrim(Upper(SubStr(cLinha, 1, 9))) == 'DELIMITED'
			lDelimited := .T.
			cDelimit := SubStr(cLinha, 11, 1)
			cSepara := SubStr(cLinha, 10, 1)
			nPosRet := Val(SubStr(cLinha, 12, 2))
		EndIf
		If FunName() == "CRDA035"
			If lDelimited != lArg
				If MsgYesNo( STR0037 + Chr(13) + STR0038 ) //"O arquivo de layout � incompativel com a op��o 'Usa Delimitador'." ### "Deseja desenhar um novo lay-out ?"
		 			FT_FUSE()			
					return
				Else
					return ( { "FIM" } )
				EndIf
			EndIf
		EndIf
		FT_FSKIP()
		cLinha := FT_FREADLN() //Leitura da linha
	EndIf
	
	AAdd( aRet,Array(9) )
	
	If lDelimited
		aRet[ Len(aRet) ][1] := Val(SubStr( cLinha,001,004 ))
		If Empty(cLinha)
			aRet[ Len(aRet) ][2] := Space(100)
		Else
			aRet[ Len(aRet) ][2] := SubStr( cLinha,005,030 )
		EndIf
		aRet[ Len(aRet) ][3] := SubStr( cLinha,035,001 )
		aRet[ Len(aRet) ][4] := SubStr( cLinha,036,003 )
		aRet[ Len(aRet) ][5] := Val(SubStr( cLinha,039,002 ))
		aRet[ Len(aRet) ][6] := SubStr( cLinha,041,150 )
		aRet[ Len(aRet) ][8] := lDelimited
		aRet[ Len(aRet) ][9] := .F.
	Else
		aRet[ Len(aRet) ][1] := Val(SubStr( cLinha,001,004 ))
		aRet[ Len(aRet) ][2] := Val(SubStr( cLinha,005,004 ))
		If Empty(cLinha)
			aRet[ Len(aRet) ][3] := Space(100)
		Else
			aRet[ Len(aRet) ][3] := SubStr( cLinha,009,030 )
		EndIf
		aRet[ Len(aRet) ][4] := SubStr( cLinha,039,001 )
		aRet[ Len(aRet) ][5] := SubStr( cLinha,040,003 )
		aRet[ Len(aRet) ][6] := Val(SubStr( cLinha,043,002 ))
		aRet[ Len(aRet) ][7] := SubStr( cLinha,045,150 )
		aRet[ Len(aRet) ][8] := lDelimited
		aRet[ Len(aRet) ][9] := .F.
	EndIf
	
	FT_FSKIP()
EndDo

//�������������������������������������������������������������������������Ŀ
//� Faco o fechamento do arquivo em uso.                                    �
//���������������������������������������������������������������������������
FT_FUSE()
If valtype(aRecDelimited) == "A"
	Aadd(aRecDelimit, lDelimited)
	Aadd(aRecDelimit, cSepara)
	Aadd(aRecDelimit, cDelimit)
	Aadd(aRecDelimit, nPosRet)
EndIf
Return aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CA035Choic�Autor  �Fernando Salvatori  � Data �  06/23/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta a enchoice do sistema.                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA035                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CA035ChoiceBar(lDelimit)
Local oBar   //Objeto do Bar.

//�������������������������������������������������������������������������Ŀ
//� Faz a definicao da EnchoiceBar.                                         �
//���������������������������������������������������������������������������
DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar ACTION NaoDisp() TOOLTIP STR0015//"Recortar..."
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar ACTION NaoDisp() TOOLTIP STR0016//"Copiar..."
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar ACTION NaoDisp() TOOLTIP STR0017//"Colar..."
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP STR0018
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar ACTION Agenda() TOOLTIP STR0019//"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool() TOOLTIP STR0020//"Gerenciador de Impress�o..."
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar GROUP  ACTION HelProg() TOOLTIP STR0021//"Help de Programa..."

//�������������������������������������������������������������������������Ŀ
//� Carrego todos os registros do TXT para o aCols.                         �
//���������������������������������������������������������������������������
DEFINE BUTTON oBtCon RESOURCE "EDIT"   OF oBar ACTION ( CA035Consulta() ) TOOLTIP STR0022//"Consulta de Campos (Ctrl + C)"
DEFINE BUTTON oBtSal RESOURCE "SALVAR" OF oBar ACTION ( IIf(CA035TudoOk(),CA035Salvar(lDelimit),NIL) ) TOOLTIP STR0023//"Salvar (Ctrl + G)"
DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ACTION ( oDlg:End() ) TOOLTIP STR0024//"Sair (Ctrl + S)"

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CA035LinOk�Autor  �Fernando Salvatori  � Data �  24/06/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     � Faz a inconsistencia da linha do aCols.                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA035                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CA035LinOk()

//�������������������������������������������������������������������������Ŀ
//� Verifica o campo Retorno do sistema.                                    �
//���������������������������������������������������������������������������
If !aTail( aCols[N] ) .And. Empty( aCols[N][3] )
	MsgStop( STR0009, STR0010 )//"Selecione um campo para o retorno"//"Aten��o"
	Return .F.
EndIf                    

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CA035Consu�Autor  �Fernando Salvatori  � Data �  24/06/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     � Efetua a consulta do dicionario de campos do MA6           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA035                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CA035Consulta()
Local nX := 0    //Contador do sistema
Local oDlgCons   //Dialog da Listbox
Local oListBox   //Objeto da listbox

//�������������������������������������������������������������������������Ŀ
//� Caso a Array estatica aList esteja em branco, faz o preenchimento, esta �
//� Array tem por objetivo, fazer o <Cache> dos campos da tabela MA6.       �
//���������������������������������������������������������������������������
If Empty( aList )
	dbSelectArea( "SX3" )
	dbSetOrder( 1 )
	dbSeek( "MA6" )
	
	//�������������������������������������������������������������������������Ŀ
	//� Faz a montagem da estrutura do MA6                                      �
	//���������������������������������������������������������������������������
	Do While !Eof() .And. X3_ARQUIVO == "MA6"
		If X3USO( X3_USADO )
			AAdd( aList,{X3_TITULO,X3_CAMPO,X3_TAMANHO,X3_DECIMAL} )
		EndIf
		dbSkip()
	EndDo
	
EndIf

//�������������������������������������������������������������������������Ŀ
//� Montagem da Tela.                                                       �
//���������������������������������������������������������������������������
DEFINE MSDIALOG oDlgCons TITLE STR0025 FROM 9,0 TO 30,52 OF oMainWnd//"Estrutura do arquivo MA6 - Confec��o de Cart�es"

//�������������������������������������������������������������������������Ŀ
//� Botao de saida.                                                         �
//���������������������������������������������������������������������������
DEFINE SBUTTON FROM 004,170 TYPE 2 ACTION (oDlgCons:End()) ENABLE OF oDlgCons

//�������������������������������������������������������������������������Ŀ
//� Listbox.                                                                �
//���������������������������������������������������������������������������
@ .5,.7 LISTBOX oListBox VAR cListBox Fields HEADER STR0026,STR0027,STR0028,STR0029 SIZE 155,145//"Nome"//"T�tulo"//"Tamanho"//"Decimais"

//�������������������������������������������������������������������������Ŀ
//� Faz a configuracao da ListBox.                                          �
//���������������������������������������������������������������������������
oListBox:SetArray(aList)
oListBox:bLine := { || { aList[oListBox:nAt,1],aList[oListBox:nAt,2],aList[oListBox:nAt,3],aList[oListBox:nAt,4]} }

ACTIVATE MSDIALOG oDlgCons CENTERED

Return
      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRDA035   �Autor  �Microsiga           � Data �  25/06/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ativa-Desativa as SetKeys                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA035                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CA035SetKeys(lUsaKeys)
Default lUsaKeys := .F.

If lUsaKeys
	SetKey(3,oBtCon:bAction)
	SetKey(19,oBtCan:bAction)
	SetKey(7,oBtSal:bAction)
Else
	SetKey(3,NIL)
	SetKey(19,NIL)
	SetKey(7,NIL)
EndIf

Return
