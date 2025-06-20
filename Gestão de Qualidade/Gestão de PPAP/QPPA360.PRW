#INCLUDE "QPPA360.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPA360  � Autor � Robson Ramiro A. Olive� Data � 29.10.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � VDA Amostras Iniciais                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA360(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PPAP                                                       ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 0, 1,,.F.},; 	//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA360Roti", 0, 2},;		 	//"Visualizar"
					{ OemToAnsi(STR0003), "PPA360Roti", 0, 3},;		 	//"Incluir"
					{ OemToAnsi(STR0004), "PPA360Roti", 0, 4},;		 	//"Alterar"
					{ OemToAnsi(STR0005), "PPA360Roti", 0, 5},;		 	//"Excluir"
					{ OemToAnsi(STR0006), "QPPR360(.T.)", 0, 6,,.T.} }	//"Imprimir"

Return aRotina

Function QPPA360(xAutoCab,xAutoItens,nOpcAuto)

//���������������������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                                �
//�����������������������������������������������������������������������������
Private cCadastro 	:= OemToAnsi(STR0007) //"VDA Amostras Iniciais"
Private lPPA360Auto	:= .F.

Private aRotina := MenuDef()

DbSelectArea("QL2")
DbSetOrder(1)

If (xAutoCab <> Nil .and. xAutoItens <> Nil)
	lPPA360Auto			:= .T.
	Private aAutoCab	:= xAutoCab
	Private aAutoItens	:= xAutoItens
	Default nOpcAuto	:= 3
	mBrowseAuto(nOpcAuto,aClone(aAutoCab),"QL2")
Else
	mBrowse( 6, 1, 22, 75,"QL2",,,,,,)
Endif

Return


/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �PPA360Roti  � Autor � Robson Ramiro A.Olivei� Data �29.10.03  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Manutencao dos Dados                             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void PPA360Incl(ExpC1,ExpN1,ExpN2)                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � QPPA360                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PPA360Roti(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aButtons	:= {}
Local aPosObj		:= {}
Local oSize		:= NIL

Local nLinIni   	:= 0
Local nColIni		:= 0
Local nLinEnd		:= 0
Local nColEnd		:= 0

Local nLinIni2  	:= 0
Local nColIni2	:= 0
Local nLinEnd2	:= 0
Local nColEnd2	:= 0

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private aGETS   := {}
Private aTELA   := {}

If nOpc == 2 .or. nOpc == 5
	aButtons := { { "BMPVISUAL", { || QPPR360()}, OemToAnsi(STR0008), OemToAnsi(STR0010) } } //"Visualizar/Imprimir"###"Vis/Prn"
Elseif nOpc == 3 .or. nOpc == 4
	aButtons := { { "EDIT", { || QPP360APRO()}, OemToAnsi(STR0009), OemToAnsi(STR0011) } } //"Aprovar / Limpar"###"Apr/Limp"
Endif

If nOpc == 4
	If !QPPVldAlt(QL2->QL2_PECA,QL2->QL2_REV,QL2->QL2_APROVA)
		Return
	Endif
Endif

If nOpc == 5
	If !QPPVldExc(QL2->QL2_REV,QL2->QL2_APROVA)
		Return
	Endif
Endif

RegToMemory("QL2",(nOpc == 3))

A360aHead("QL3")
A360aCols(nOpc)

DbSelectArea(cAlias)

If lPPA360AUTO
	If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)}) .and. MsGetDAuto(aAutoItens,"PP360LinOk","PP360TudOk",aAutoCab)
		lOk := .T.
	Endif
Else
	//��������������������������������������������������������������Ŀ
	//� Cordenadas para criar a tela                                 �
	//����������������������������������������������������������������
	oSize := FwDefSize():New()                
	oSize:AddObject( "CABECALHO",  100, 30,.T.,.T. ) // Totalmente dimensionavel
	oSize:AddObject( "GETDADOS" ,  100, 70,.T.,.T. ) // Totalmente dimensionavel         
	oSize:aMargins := { 3, 3, 3, 3 }
	oSize:Process() // Dispara os calculos 
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) ; //"VDA Amostras Iniciais"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

	nLinIni:= oSize:GetDimension("CABECALHO","LININI")
	nColIni:= oSize:GetDimension("CABECALHO","COLINI")
	nLinEnd:= oSize:GetDimension("CABECALHO","LINEND")
	nColEnd:= oSize:GetDimension("CABECALHO","COLEND")
	
	nLinIni2:= oSize:GetDimension("GETDADOS","LININI")
	nColIni2:= oSize:GetDimension("GETDADOS","COLINI")
	nLinEnd2:= oSize:GetDimension("GETDADOS","LINEND")
	nColEnd2:= oSize:GetDimension("GETDADOS","COLEND")
	
				
	Enchoice("QL2",nReg,nOpc, , , , ,{nLinIni,nColIni,nLinEnd,nColEnd}, , , , ,)

	oGet := MSGetDados():New(nLinIni2,nColIni2,nLinEnd2,nColEnd2, nOpc,"PP360LinOk","PP360TudOk","+QL3_ITEM",.T.)
	


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP360TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) CENTERED
Endif

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	PPA360Grav(nOpc)
Endif

If nOpc == 5 .and. lOk
	A360Dele()
Endif

Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA360Grav� Autor � Robson Ramiro A Olivei� Data � 29.10.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Gravacao VDA Amostras Iniciais - Incl./Alter.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA360Grav(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA360                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA360Grav(nOpc)

Local nIt
Local nNumItem
Local nPosDel	:= Len(aHeader) + 1
Local lGraOk	:= .T.
Local nCpo
Local bCampo	:= { |nCPO| Field(nCPO) }
Local nCont

DbSelectArea("QL2")
DbSetOrder(1)
	
Begin Transaction

If INCLUI
	RecLock("QL2",.T.)
Else
	RecLock("QL2",.F.)
Endif

For nCont := 1 To FCount()

	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QL2"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif

Next nCont

QL2->QL2_REVINV := Inverte(M->QL2_REV)

MsUnLock()
FKCOMMIT()

DbSelectArea("QL3")
DbSetOrder(1)

nNumItem := 1  // Contador para os Itens
	
For nIt := 1 To Len(aCols)

	If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

		If ALTERA
		
			If DbSeek(xFilial("QL3")+ M->QL2_PECA + M->QL2_REV + StrZero(nIt,Len(QL3->QL3_ITEM)))
				RecLock("QL3",.F.)
			Else
				RecLock("QL3",.T.)
			Endif
		Else	                   
			RecLock("QL3",.T.)
		Endif
			
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
				QL3->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			EndIf
		Next nCpo

		//��������������������������������������������������������������Ŀ
		//� Campos Chave nao informados                                  �
		//����������������������������������������������������������������
		QL3->QL3_FILIAL	 := xFilial("QL3")
		QL3->QL3_PECA 	 := M->QL2_PECA
		QL3->QL3_REV 	 := M->QL2_REV
		QL3->QL3_REVINV	 := Inverte(QL2->QL2_REV)
                                                                              
		//��������������������������������������������������������������Ŀ
		//� Controle de itens do acols                                   �
		//����������������������������������������������������������������
		QL3->QL3_ITEM := StrZero(nNumItem,Len(QL3->QL3_ITEM))

		nNumItem++

		MsUnlock()
		FKCOMMIT()
    Else
		If DbSeek(xFilial("QL3")+ M->QL2_PECA + M->QL2_REV + StrZero(nIt,Len(QL3->QL3_ITEM)))
			RecLock("QL3",.F.)
			DbDelete()
			MsUnlock()
			FKCOMMIT()
		Endif
	Endif

Next nIt

End Transaction
		
Return lGraOk

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    �PP360TudOk � Autor � Robson Ramiro A. Olive� Data � 29.10.03 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para inclusao/alteracao geral                  ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP360TudOk                                                  ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                        ���
��������������������������������������������������������������������������Ĵ��
���Uso       � QPPA360                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PP360TudOk

Local lReturn	:= .T.

lReturn := PP360LinOk()

If Empty(M->QL2_PECA) .or. Empty(M->QL2_REV)
	lReturn := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If INCLUI
	If !ExistChav("QL2",M->QL2_PECA+M->QL2_REV)
		lReturn := .F.
	Endif
	If !ExistCpo("QK1",M->QL2_PECA+M->QL2_REV)
		lReturn := .F.
	Endif
Endif

Return lReturn

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    �PP360LinOk � Autor � Robson Ramiro A. Olive� Data � 30.10.03 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para troca de linha                            ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP360LinOk                                                  ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                        ���
��������������������������������������������������������������������������Ĵ��
���Uso       � QPPA360                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PP360LinOk

Local nX		:= 0
Local lReturn	:= .T.
Local nCont		:= 0
Local nPosDel	:= Len(aHeader) + 1

If !aCols[n, nPosDel]
	For nX := 2 To (nPosDel - 1)
		If !Empty(aCols[n, nX])
			nCont++
		Endif
	Next nX
	
	If nCont == 0
		Help( " ", 1, "QPPAOBRIG")
		lReturn := .F.
	Endif
Endif
	
Return lReturn
	

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A360Dele � Autor � Robson Ramiro A Olivei� Data � 29.10.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fucao para exclusao                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A360Dele()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA360                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A360Dele()

DbSelectArea("QL3")
DbSetOrder(1)

Begin Transaction	

If DbSeek(xFilial("QL3")+ QL2->QL2_PECA + QL2->QL2_REV)

	Do While !Eof() .and. ;
		QL3->QL3_PECA + QL3->QL3_REV == QL2->QL2_PECA + QL2->QL2_REV
		
		RecLock("QL3",.F.)
		DbDelete()
		MsUnLock()
		FKCOMMIT()		
		DbSkip()
		
	Enddo

Endif

DbSelectArea("QL2")

RecLock("QL2",.F.)
DbDelete()
MsUnLock()

End Transaction

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A360Acols� Autor � Robson Ramiro A. Olive� Data � 29.10.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A150Acols()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA360                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A360Acols(nOpc)

Local nI, nPos

//������������������������������������������������������Ŀ
//� Montagem do aCols               					 �
//��������������������������������������������������������

If nOpc == 3

	aCols := Array(1,nUsado+1)

	For nI = 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			aCols[1,nI] := Space(aHeader[nI,4])
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := dDataBase
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI

	nPos			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QL3_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.	

Else
	
	DbSelectArea("QL3")
	DbSetOrder(1)
	DbSeek(xFilial()+QL2->QL2_PECA+QL2->QL2_REV)

		Do While QL3->(!Eof()) .and. xFilial() == QL3->QL3_FILIAL .and.;
			 QL3->QL3_PECA+QL3->QL3_REV == QL2->QL2_PECA+QL2->QL2_REV

		aAdd(aCols,Array(nUsado+1))
	
		For nI := 1 to nUsado
   	
			If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Else										// Campo Virtual
				cCpo := AllTrim(Upper(aHeader[nI,2]))
				aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])				
  			Endif
 			
		Next nI
  			
		aCols[Len(aCols),nUsado+1] := .F.
    	
		DbSkip()

	Enddo
		
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A360Ahead� Autor � Robson Ramiro A. Olive� Data � 29.10.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta Ahead para aCols                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A150Ahead()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA360                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A360Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)

	If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL")
		nUsado++
 		aAdd(aHeader,{ Trim(QAGetX3Tit(aStruAlias[nX,1])),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_CAMPO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_PICTURE'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_TAMANHO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_DECIMAL'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_VALID'),;              
		              GetSx3Cache(aStruAlias[nX,1],'X3_USADO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_TIPO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_ARQUIVO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_CONTEXT')})
	Endif	
Next nX 

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP360APRO� Autor � Robson Ramiro A.Olivei� Data � 29.10.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Aprova / Limpa                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP360APRO()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void         											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA360                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP360APRO
DbSelectArea("QAA")
DbSetOrder(6)
If Dbseek(Upper(cUserName))
	M->QL2_DTAPRO := Iif(Empty(M->QL2_DTAPRO), dDataBase, CtoD(" / / "))
	M->QL2_APROVA := Iif(Empty(M->QL2_APROVA), cUserName, Space(15)) 
Else
	messagedlg(STR0012) //"O usu�rio logado n�o est� cadastrado no cadastro de usu�rios do m�dulo, portanto n�o poder� ser o aprovador"
	
Endif

Return .T.

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MyQPPA360 � Autor � Robson Ramiro Oliveira� Data �31.10.2003 ���
��������������������������������������������������������������������������Ĵ��
���          �Rotina de teste da rotina automatica do programa QPPA360     ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Void                                                         ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Void                                                         ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo efetuar testes na rotina       ���
���          �automatica QPPA360                                           ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Quality                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function MyQPPA360()

Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local nX     := 0
Local lOk    := .T.

Private lMsErroAuto := .F.

//��������������������������������������������������������������Ŀ
//| Abertura do ambiente                                         |
//����������������������������������������������������������������
//ConOut(Repl("-",80))
//ConOut(PadC("Teste de Rotina Automatica - VDA amostra Inicial",80))

PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "PPAP"

If lOk
	//ConOut("Inicio: "+Time())
	aCabec := {}
	aItens := {}
	aadd(aCabec,{"QL2_PECA", PadR("A",40), Nil})
	aadd(aCabec,{"QL2_REV", "99", Nil})
	For nX := 1 To 3
		aLinha := {}
		aadd(aLinha,{"QL3_ITEM",StrZero(nX,3), Nil})
		aadd(aLinha,{"QL3_NPEMAT","ITEM "+StrZero(nX,3), Nil})
		aadd(aItens,aLinha)
	Next nX

	//��������������������������������������������������������������Ŀ
	//| Teste de Inclusao                                            |
	//����������������������������������������������������������������
	QPPA360(aCabec,aItens,4)
	If !lMsErroAuto
		//ConOut("Incluido com sucesso!")	
	Else
		//ConOut("Erro na inclusao!")
	EndIf
	//ConOut("Fim  : "+Time())

Endif

RESET ENVIRONMENT

Return .T.