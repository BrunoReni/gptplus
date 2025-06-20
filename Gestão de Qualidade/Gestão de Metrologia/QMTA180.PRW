#include "QMTA180.CH" 
#include "PROTHEUS.CH"
            
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QMTA180   � Autor � Eduardo Riera         � Data � 08.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Coleta do MSA (Avaliacao do Sistema de Medicao)            ���
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
Static Function MenuDef()

Local aRotina := {{ STR0001 	,"AxPesqui"  	, 0 , 1,,.F.},;	 //"Pesquisar"
					{ STR0002	,"Qmt180Visu"  	, 0 , 2},;	 //"Visual"
					{ STR0003   ,"Qmt180Incl" 	, 0 , 3},;	 //"Inclui"
					{ STR0004   ,"Qmt180Alte"	,0 	, 4},;	 //"Altera"
					{ STR0005   ,"Qmt180Excl"	,0 	, 5, 3},;//"Exclui"
					{ STR0007   ,"Qmt180Impo"	,0 	, 3}} 	 //"Importa"

Return aRotina

Function QMTA180()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private oGet
Private oGetE
Private cCadastro := OemtoAnsi(STR0006)		//"Aval.do Sist. de Medi��o"
Private aPos   := {  15,  1, 70, 315 }

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
PRIVATE aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("QMU")
dbSetOrder(1)
dbSeek(xFilial())
mBrowse( 6, 1,22,75,"QMU")

Return

/*/
antigo a180Inclui
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Qmt180Incl� Autor � Eduardo Riera         � Data � 10.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclusao do MSA                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhuma                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Qmt180Incl(cAlias,nReg,nOpc)


Local nOpca    := 0
Local nUsado   := 0
Local nCntFor  := 0
Local nCntFor1 := 0
Local nPosCiclo:= 0
Local nSaveSX8 := GetSX8Len()     

Local aPosObj := {}  
Local aObjects:= {}   
Local aInfo   := {}      
Local aSize   := {}

Local aStruQMU := FWFormStruct(3, "QMU",,.F.)[3]
Local nX

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0],aGets[0]
Private bCampo := { |nField| Field(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP   

//��������������������������������������������Ŀ
//� Define tamanho da tela                     �
//����������������������������������������������
aSize := MsAdvSize(, .F., 400 )
AAdd( aObjects, { 100, 600, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. })

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

//������������������������������������������������������Ŀ
//� Cria Variaveis de Memoria da Enchoice                �
//��������������������������������������������������������
dbSelectArea("QMU")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := CriaVar(Eval(bCampo,nCntFor),.T.)
Next nCntFor
//������������������������������������������������������������������������Ŀ
//�Monta o aHeader                                                         �
//��������������������������������������������������������������������������
For nX := 1 To Len(aStruQMU)
	If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS#QMU_ITEM" ) 
		aadd(aHeader, Q180GetSX3(aStruQMU[nX,1], "", "") )
		nUsado++
		If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS" )
			nPosCiclo := nUsado
		EndIf
	EndIf
Next nX

//������������������������������������������������������������������������Ŀ
//�Monta o aCols                                                           �
//��������������������������������������������������������������������������
aadd(aCols,Array(nUsado+1))
aCols[1][nUsado+1] := .F.
For nCntFor := 1 To nUsado
	aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2],.T.)
	If ( AllTrim(aHeader[nCntFor,2]) $ "QMU_ITEM" )
		aCols[1,nCntFor] := "01"
	EndIf
Next nCntFor

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
oGetE:=MsMGet():New(cAlias, nReg, nOpc,,,,,aPosObj[1],,,,,,oDlg)
oGet := MSGetDados():New( aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpc, "qmt180Cicl", "Qmt180tOk", "+QMU_ITEM", .T.,,,.F.,999)   

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,If(Obrigatorio(aGets,aTela).And.Qmt180tOk(),oDlg:End(),nOpcA:=0)},{||nOpca:=0,oDlg:End()}) CENTERED

dbSelectArea(cAlias)
dbGoto(nReg)
If ( nOpca==1 )
	Begin Transaction
	For nCntFor := 1 To Len(aCols)
		If ( !aCols[nCntFor,nUsado+1] .And. !Empty(aCols[nCntFor,nPosCiClo]))
			dbSelectArea("QMU")
			RecLock("QMU",.T.)
			For nCntFor1 := 1 To FCount()
				FieldPut(nCntFor1,M->&(FieldName(nCntFor1)))
			Next nCntFor1
			For nCntFor1 := 1 To Len(aHeader)
				FieldPut(FieldPos(aHeader[nCntFor1,2]),aCols[nCntFor,nCntFor1])
			Next nCntFor1
			QMU->QMU_FILIAL := xFilial()
			QMU->QMU_FILRES := cFilAnt
		EndIf
	Next nCntFor
	EvalTrigger()
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End
	End Transaction
EndIf
Return(nOpcA)

/*/
antigo a180Pc
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �q180Pc    � Autor � Eduardo Riera         � Data � 10.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � PictVar                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Picture                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function q180Pc(cCampo)

Return( QA_PICT(cCampo,M->&(cCampo)) )


/*/
antiga a180Ciclos
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �qmt180Cicl� Autor � Eduardo Riera         � Data � 10.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao dos Valores de Referencia                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QMT180Cicl()

Local nValor := ReadVar()
Local lRetorno := .T.
Local nValor2:= 0
Local nValor3:= 0

If ( !Empty(nValor) )
	nValor := &nValor
Else
	nValor :=  aCols[n,aScan(aHeader,{|x| x[2]$"QMU_CICLOS" })]
EndIf

nValor2 := SuperVal(M->QMU_TOLER)
nValor3 := -1*(nValor2)
nValor2 += SuperVal(M->QMU_REFER)
nValor3 += SuperVal(M->QMU_REFER)

If ( ValType(nValor)=="C" )
	nValor := SuperVal(nValor)
EndIf
If (nValor+nValor2+nValor3==0.And.n==1.And.INCLUI)
	lRetorno := .T.
Else
	If ( nValor > nValor2 .Or.;
		nValor < nValor3 )
		Help(" ",1,"QA180CICLO")
		lRetorno := .F.
	EndIf
EndIf
Return(lRetorno)

/*/
antigo a180TudOk
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Qmt180tOk � Autor � Eduardo               � Data � 10.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da GetDados                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Qmt180tOk()

Local nCntFor 	:= 1
Local nCont		:= 0
Local nUsado   	:= Len(aHeader)+1
Local lRetorno 	:= .T.
Local lErrmas	:= (X3USO(POSICIONE("SX3",2,"QMU_ERRMAS","X3_USADO")))

For nCntFor := 1 To Len(aCols)
	If ( !aCols[nCntFor,nUsado] )
		nCont++
	EndIf
Next

If ( nCont < 2 .And. nCont != 0 .And. !Empty(M->QMU_REFER) )
	Help(" ",1,"QQmt180tOk")
	lRetorno := .F.
EndIf
If (M->QMU_TPMSA == "2") .AND. lRetorno 
	If (lErrmas .and. VAL(M->QMU_ERRMAS) < 1 ) .or. (!lErrmas .and. VAL(M->QMU_ERRMSA) < 1 )
		MsgAlert(OemToAnsi(STR0016)) //"O Erro Amostral maior ou igual a 1 e requerido para alguns tipos de Grafico e Calculos do MSA 3 Edicao"
	Endif
EndIf
Return(lRetorno)

/*/
antigo a180Altera
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Qmt180Alte� Autor � Eduardo Riera         � Data � 10.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Alteracao do MSA                                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhuma                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Qmt180Alte(cAlias,nReg,nOpc)

Local nOpca     := 0
Local nUsado    := 0
Local nCntFor   := 0
Local nCntFor1  := 0
Local nPosCiclo := 0
Local cChave    := ""
Local nPosItem  := 0
Local nSaveSX8	:= GetSX8Len()  

Local aPosObj   := {}  
Local aObjects  := {}   
Local aInfo     := {}      
Local aSize     := {}

Local aStruQMU := FWFormStruct(3, "QMU",,.F.)[3]
Local nX

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0],aGets[0]
Private bCampo := { |nField| FieldName(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP

//��������������������������������������������Ŀ
//� Define tamanho da tela                     �
//����������������������������������������������
aSize := MsAdvSize(, .F., 400 )
AAdd( aObjects, { 100, 600, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. })

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )


//������������������������������������������������������Ŀ
//� Cria Variaveis de Memoria da Enchoice                �
//��������������������������������������������������������
dbSelectArea("QMU")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next nCntFor
//������������������������������������������������������������������������Ŀ
//�Monta o aHeader                                                         �
//��������������������������������������������������������������������������
For nX := 1 To Len(aStruQMU)
	If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS#QMU_ITEM" ) 
		aadd(aHeader, Q180GetSX3(aStruQMU[nX,1], "", "") )
		nUsado++
		If ( AllTrim(aStruQMU[nX,1])$"QMU_ITEM" )
			nPosItem := nUsado
		EndIf
		If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS" )
			nPosCiclo := nUsado
		EndIf
	EndIf
Next nX

//������������������������������������������������������������������������Ŀ
//�Monta o aCols                                                           �
//��������������������������������������������������������������������������
//cChave := xFilial("QMU")+QMU->QMU_TIPO+QMU->QMU_INSTR+QMU->QMU_REVINS+Dtos(QMU->QMU_DATA)+QMU_REFER
cChave := xFilial("QMU")+QMU->QMU_INSTR+QMU->QMU_REVINS+Dtos(QMU->QMU_DATA)+QMU_REFER
dbSelectArea("QMU")
dbSetOrder(1)
dbSeek(cChave)
While ( !Eof() .And. cChave==;
	QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+;
	Dtos(QMU->QMU_DATA)+QMU->QMU_REFER )
	aadd(aCols,Array(nUsado+1))
	aCols[Len(aCols),nUsado+1] := .F.
	For nCntFor := 1 To Len(aHeader)
		If ( aHeader[nCntFor,10] != "V" )
			aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
		Else
			aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
		EndIf
	Next
	dbSkip()
EndDo
dbSelectArea(cAlias)
dbGoto(nReg)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
oGetE:=MsMGet():New(cAlias, nReg, nOpc,,,,,aPosObj[1],,,,,,oDlg)
oGet := MSGetDados():New(  aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpc, "qmt180Cicl", "Qmt180tOk", "+QMU_ITEM", .T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,If(Obrigatorio(aGets,aTela).And.Qmt180tOk(),oDlg:End(),nOpcA:=0)},{||nOpca:=0,oDlg:End()}) CENTERED
If ( nOpca==1 )
	Begin Transaction
	For nCntFor := 1 To Len(aCols)
		If ( !aCols[nCntFor,nUsado+1] .And. !Empty(aCols[nCntFor,nPosCiClo]))
			dbSelectArea("QMU")
			dbSetOrder(1)
			If ( dbSeek(cChave+aCols[nCntFor,nPosItem]) )
				RecLock("QMU",.F.)
			Else
				RecLock("QMU",.T.)
			EndIf
			For nCntFor1 := 1 To FCount()
				FieldPut(nCntFor1,M->&(FieldName(nCntFor1)))
			Next nCntFor1
			For nCntFor1 := 1 To Len(aHeader)
				FieldPut(FieldPos(aHeader[nCntFor1,2]),aCols[nCntFor,nCntFor1])
			Next nCntFor1
			QMU->QMU_FILIAL := xFilial("QMU")
			QMU->QMU_FILRES := cFilAnt
		Else
			dbSelectArea("QMU")
			dbSetOrder(1)
			If ( dbSeek(cChave+aCols[nCntFor,nPosItem]) )
				RecLock("QMU",.F.)
				dbDelete()
			EndIf
		EndIf
	Next nCntFor
	EvalTrigger()
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End
	End Transaction
EndIf
dbSelectArea(cAlias)
dbGoto(nReg)
Return(nOpcA)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Qmt180Visu� Autor � Eduardo Riera         � Data � 10.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizacao do MSA                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhuma                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Qmt180Visu(cAlias,nReg,nOpc)

Local nOpca     := 0
Local nUsado    := 0
Local nCntFor   := 0
Local cChave    := ""
Local nPosItem  := 0    

Local aPosObj := {}  
Local aObjects:= {}   
Local aInfo   := {}      
Local aSize   := {}

Local aStruQMU := FWFormStruct(3, "QMU",,.F.)[3]
Local nX

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0],aGets[0]
Private bCampo := { |nField| FieldName(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP  

//��������������������������������������������Ŀ
//� Define tamanho da tela                     �
//����������������������������������������������
aSize := MsAdvSize(, .F., 400 )
AAdd( aObjects, { 100, 600, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. })

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

//������������������������������������������������������Ŀ
//� Cria Variaveis de Memoria da Enchoice                �
//��������������������������������������������������������
dbSelectArea("QMU")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next nCntFor
//������������������������������������������������������������������������Ŀ
//�Monta o aHeader                                                         �
//��������������������������������������������������������������������������
For nX := 1 To Len(aStruQMU)
	If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS#QMU_ITEM" ) 
		aadd(aHeader, Q180GetSX3(aStruQMU[nX,1], "", "") )
		nUsado++
		If ( AllTrim(aStruQMU[nX,1])$"QMU_ITEM" )
			nPosItem := nUsado
		EndIf
	EndIf
Next nX

//������������������������������������������������������������������������Ŀ
//�Monta o aCols                                                           �
//��������������������������������������������������������������������������
cChave := xFilial("QMU")+QMU->QMU_INSTR+QMU->QMU_REVINS+Dtos(QMU->QMU_DATA)+QMU_REFER
dbSelectArea("QMU")
dbSetOrder(1)
dbSeek(cChave)
While ( !Eof() .And. cChave==;
	QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+;
	Dtos(QMU->QMU_DATA)+QMU->QMU_REFER )
	aadd(aCols,Array(nUsado))
	For nCntFor := 1 To Len(aHeader)
		If ( aHeader[nCntFor,10] != "V" )
			aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
		Else
			aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
		EndIf
	Next
	dbSkip()
EndDo
dbSelectArea(cAlias)
dbGoto(nReg)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
oGetE:=MsMGet():New(cAlias, nReg, nOpc,,,,,aPosObj[1],,,,,,oDlg)
oGet := MSGetDados():New(  aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"qmt180Cicl","Qmt180tOk","+QMU_ITEM",.F.,,,.F.,999)   
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()}) CENTERED
dbSelectArea(cAlias)
dbGoto(nReg)
Return(nOpcA)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Qmt180Excl� Autor � Eduardo Riera         � Data � 10.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exclusao do MSA                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhuma                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Qmt180Excl(cAlias,nReg,nOpc)

Local nOpcA     := 0
Local nUsado    := 0
Local nCntFor   := 0
Local cChave    := ""
Local nPosItem  := 0  

Local aPosObj := {}  
Local aObjects:= {}   
Local aInfo   := {}      
Local aSize   := {}

Local aStruQMU := FWFormStruct(3, "QMU",,.F.)[3]
Local nX

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0],aGets[0]
Private bCampo := { |nField| FieldName(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP  

//��������������������������������������������Ŀ
//� Define tamanho da tela                     �
//����������������������������������������������
aSize := MsAdvSize(, .F., 400 )
AAdd( aObjects, { 100, 600, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. })

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

//������������������������������������������������������Ŀ
//� Cria Variaveis de Memoria da Enchoice                �
//��������������������������������������������������������
dbSelectArea("QMU")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next nCntFor
//������������������������������������������������������������������������Ŀ
//�Monta o aHeader                                                         �
//��������������������������������������������������������������������������
For nX := 1 To Len(aStruQMU)
	If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS#QMU_ITEM" ) 
		aadd(aHeader, Q180GetSX3(aStruQMU[nX,1], "", "") )
		nUsado++
		If ( AllTrim(aStruQMU[nX,1])$"QMU_ITEM" )
			nPosItem := nUsado
		EndIf
	EndIf
Next nX

//������������������������������������������������������������������������Ŀ
//�Monta o aCols                                                           �
//��������������������������������������������������������������������������
cChave := xFilial("QMU")+QMU->QMU_INSTR+QMU->QMU_REVINS+Dtos(QMU->QMU_DATA)+QMU_REFER
dbSelectArea("QMU")
dbSetOrder(1)
dbSeek(cChave)
While ( !Eof() .And. cChave==;
	QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+;
	Dtos(QMU->QMU_DATA)+QMU->QMU_REFER )
	aadd(aCols,Array(nUsado))
	For nCntFor := 1 To Len(aHeader)
		If ( aHeader[nCntFor,10] != "V" )
			aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
		Else
			aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
		EndIf
	Next
	dbSkip()
EndDo
dbSelectArea(cAlias)
dbGoto(nReg)
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
oGetE:=MsMGet():New(cAlias, nReg, nOpc,,,,,aPosObj[1],,,,,,oDlg)
oGet := MSGetDados():New(  aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"qmt180Cicl","Qmt180tOk","+QMU_ITEM",.F.,,,.F.,999)   
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=2,oDlg:End()},{||nOpca:=0,oDlg:End()}) CENTERED
If ( nOpcA==2 )
	Begin Transaction
	dbSelectArea("QMU")
	dbSetOrder(1)
	dbSeek(cChave)
	While ( !Eof() .And. cChave==;
		QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+;
		Dtos(QMU->QMU_DATA)+QMU->QMU_REFER )
		
		RecLock("QMU",.F.)
		dbDelete()
		dbSkip()
	EndDo
	End Transaction
EndIf
dbSelectArea(cAlias)
dbGoto(nReg)
Return(nOpcA)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Qmt180Impo� Autora� Iuri Seto             � Data � 23/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Importa��o de Medi��es da Calibra��o                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
��� 20/06/00 � Iuri Seto     �Inclusao do tipo de calibracao Relogio.     ���
���          �               �(TIPAFE = "9")                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Qmt180Impo()                                 

Local cImportou
Local nItem := 0        
Local lMsgToler := .F.

cImportou := "1"	// Calibra��o n�o encontrada

If Pergunte("QMA180",.T.)
	               
	QMU->( dbSetOrder(1) )
	If QMU->(DbSeek(xFilial('QMU')+' '+mv_par01+mv_par02+DTOS(mv_par03)))
		Help(" ",1,"JAGRAVADO")
		Return(Nil)
	EndIf 

	dbSelectArea("QM6")
	QM6->( DbSetOrder(1) )

	dbSelectArea("QM7")
	QM7->( DbSetOrder(1) )

	If QM6->(DbSeek(xFilial("QM6")+mv_par01+mv_par02+DTOS(mv_par03))) .and.;
	   QM7->(DbSeek(xFilial("QM7")+mv_par01+mv_par02+DTOS(mv_par03)))		
		
		Begin Transaction 
	    
			While ! eof() .and. xFilial('QM7') == QM7->QM7_FILIAL .and.;
				QM7->QM7_INSTR == mv_par01 .and.; 
			    QM7->QM7_REVINS == mv_par02 .and.;
				DTOS(QM7->QM7_DATA) == DTOS(mv_par03)	
	            
				// Busca a tolerancia do processo //
				dbSelectArea("QMR")
				QMR->( DbSetOrder(1) )
				QMR->(DbSeek(xFilial('QMR')+mv_par01+mv_par02+QM7->QM7_ESCALA))

				// Busca o Tipo de Calibra��o //
				dbSelectArea("QM9")
				QM9->( DbSetOrder(1) )
				QM9->(DbSeek(xFilial('QM9')+QM7->QM7_ESCALA+Inverte(QM7->QM7_REVESC)))

				dbSelectArea("QM8")
				QM8->( DbSetOrder(1) )
				
				If QM8->(DbSeek(xFilial('QM8')+mv_par01+mv_par02+DTOS(mv_par03)+QM7->QM7_CSEQ+;
					QM7->QM7_ESCALA+QM7->QM7_REVESC+QM7->QM7_PONTO+QM7->QM7_REVPAD))		
					
					nItem := 1					
					
					While !Eof() .and. xFilial('QM8') == QM8->QM8_FILIAL .and.;
						QM8->QM8_INSTR == mv_par01 .and.; 
					   	QM8->QM8_REVINS == mv_par02 .and.;
					   	DTOS(QM8->QM8_DATA) == DTOS(mv_par03) .and.; 
					   	QM8->QM8_CSEQ == QM7->QM7_CSEQ .and.; 
					   	QM7->QM7_ESCALA == QM8->QM8_ESCALA .and.; 
					   	QM7->QM7_REVESC == QM8->QM8_REVESC .and.;
					   	QM7->QM7_PONTO == QM8->QM8_PADRAO .and.;
					   	QM7->QM7_REVPAD == QM8->QM8_REVPAD
 
						If (QM9->QM9_TIPAFE $ "12359")	
							// Se for tipo de afericao (1)Simples, (2)Completo, (3)Pressao , (5)Soma e (9)Relogio
							dbSelectArea("QM3")
							QM3->( DbSetOrder(1) )
							If QM3->(DbSeek(xFilial('QM3')+QM7->QM7_PONTO+Inverte(QM7->QM7_REVPAD))) .and.;
								QM3->QM3_TIPPAD = "A"
		  			  			cImportou := "4"	// Padr�o do Tipo Atributo n�o � importado.
					  			Exit
						   	EndIf                    
						Endif

						If EMPTY(QM8->QM8_VLRFIM)
	  			  			cImportou := "5"	// Medi��o n�o encontrada.
						EndIf
						If Empty(QMR->QMR_TOLPRO)
				  			lMsgToler := .T.
						EndIf
						
						dbSelectArea("QMU")
						QMU->( DbSetOrder(1) )
						If !QMU->(DbSeek(xFilial('QMU')+mv_par01+mv_par02+;
							DTOS(mv_par03)+QM7->QM7_ESPEC+QM8->QM8_NUMMED))		

							RecLock("QMU",.T.)
							QMU->QMU_FILIAL := QM6->QM6_FILIAL		  					
							QMU->QMU_INSTR  := QM6->QM6_INSTR		  					
							QMU->QMU_REVINS := QM6->QM6_REVINS		  					
							QMU->QMU_DATA   := QM6->QM6_DATA		  					
							QMU->QMU_FILRES := cFilAnt
							QMU->QMU_RESP   := QM6->QM6_RESP		  					
							QMU->QMU_REFER  := QM7->QM7_ESPEC		  					
							QMU->QMU_TOLER  := QMR->QMR_TOLPRO		  					
							QMU->QMU_ITEM   := StrZero(nItem++,2)
							If (QM9->QM9_TIPAFE $ "3,9")		// Pressao ou Relogio
								QMU->QMU_CICLOS := QM8->QM8_VLRFID		  					
							Else								
								QMU->QMU_CICLOS := QM8->QM8_VLRFIM		  					
							EndIf								
							MsUnLock()

							cImportou := "2"	// Importa��o conclu�da
							
	  						dbSelectArea("QM8")
				  			QM8->(DbSkip()) 
	  			  		Else
	  			  			cImportou := "3"	// Medi��o j� cadastrada
				  			Exit
		    	  		EndIf 
		    	  	EndDo     
		    	  	           
					dbSelectArea("QM7")
		    	  	QM7->(DbSkip())
		    	  	
		    	  	If cImportou == "3"		// Medi��o j� cadastrada
		    	  		Exit
		    	  	EndIf
		    	  	
		    	EndIf 
	   		EndDo
		End Transaction			
   	EndIf 
   	            
   	Do Case
   	Case cImportou == "1"
		MsgInfo( STR0010, STR0009 ) // "Calibra��o n�o encontrada !!!" ### "Importa��o de Medi��es"
	Case cImportou == "2" 
		MsgInfo( STR0008, STR0009 ) // "Importa��o Conclu�da !!!" ### "Importa��o de Medi��es"  
		If lMsgToler
			MsgAlert( STR0014 ) //"Alguma medicoes foram importadas sem tolerancia, informe a Tolerancia. Atencao, o sistema so permite informar a tolerancia uma unica vez."
		EndIf
	Case cImportou == "3"
		MsgInfo( STR0011, STR0009 ) // "Medi��o j� cadastrada !!!" ### "Importa��o de Medi��es"
	Case cImportou == "4"
		MsgInfo( STR0012, STR0009 ) // "Padr�o do Tipo Atributo n�o � importado !!!" ### "Importa��o de Medi��es"
	Case cImportou == "5"
		MsgInfo( STR0013, STR0009 ) // "Medi��o n�o encontrada !!!" ### "Importa��o de Medi��es"
	EndCase
EndIf 

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Qmt180HTol� Autora� Cicero Cruz           � Data � 23/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Habilita o campo de Tolerancia na  alteracao               ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���4    
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Qmt180HTol()                                 
Local lRet := .F.
If INCLUI .OR. Empty(QMU->QMU_TOLER)
   lRet:=.T.
EndIf
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} Q180GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 16/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q180GetSX3(cCampo, cTitulo, cWhen)
Local aHeaderTmp := {}
aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
				GetSx3Cache(cCampo,'X3_CAMPO'),;
				GetSx3Cache(cCampo,'X3_PICTURE'),;
				GetSx3Cache(cCampo,'X3_TAMANHO'),;
				GetSx3Cache(cCampo,'X3_DECIMAL'),;
				GetSx3Cache(cCampo,'X3_VALID'),;
				GetSx3Cache(cCampo,'X3_USADO'),;
				GetSx3Cache(cCampo,'X3_TIPO'),;
				GetSx3Cache(cCampo,'X3_F3'),;
				GetSx3Cache(cCampo,'X3_CONTEXT') } 
Return aHeaderTmp