#INCLUDE "protheus.ch"                                                                                    
#INCLUDE "UPDGHPAD.ch"
#INCLUDE "TOPCONN.CH"
         
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � UPDGH112  � Autor � Saude                 � Data � 24/07/12 ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualizacao das tabelas do PLS   				           ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Plano de Saude, RDC                                         ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                      ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

User Function UPDGH112()

//����������������������������������������������������������������������������Ŀ
//� Inicializa variaveis                                                       |
//������������������������������������������������������������������������������
Local nOpca			:= 0
Local aSays			:= {}, aButtons := {}
Local aRecnoSM0		:= {}
Local lOpen     	:= .F.
Private nModulo 	:= 33 // modulo SIGAPLS
Private cMessage
Private aArqUpd		:= {}
Private aREOPEN		:= {}
Private oMainWnd
Private cCadastro	:= STR0001 // "Compatibilizador de Dicion�rios x Banco de dados"
Private cCompat		:= "UPDGH112"
Private cFnc		:= "M_PLSINO14: Requisito - 002544"
Private cRef		:= "Melhoria Relatorio Grafico da Anamnese"
Set Dele On
//����������������������������������������������������������������������������Ŀ
//� Monta texto para janela de processamento                                   �
//������������������������������������������������������������������������������
aadd(aSays,STR0002)  //"Esta rotina ir� efetuar a compatibiliza��o dos dicion�rios e banco de dados,"
aadd(aSays,STR0003)//"e demais ajustes referentes a FNC abaixo:"
aadd(aSays,"   Requisito: " + cFnc)
aadd(aSays,STR0004 + cRef)  //"   Refer�ncia: "
aadd(aSays," ")
aadd(aSays, STR0005)   //"Aten��o: efetuar backup dos dicion�rios e do banco de dados previamente "
//����������������������������������������������������������������������������Ŀ
//� Monta botoes para janela de processamento                                  �
//������������������������������������������������������������������������������
aadd(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
aadd(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )
//����������������������������������������������������������������������������Ŀ
//� Exibe janela de processamento                                              �
//������������������������������������������������������������������������������
FormBatch( cCadastro, aSays, aButtons,, 230 )
//����������������������������������������������������������������������������Ŀ
//� Processa calculo                                                           �
//������������������������������������������������������������������������������
If  nOpca == 1
	If  Aviso(STR0006, STR0007, {STR0041,STR0042}) == 1 // "Sim" ### "N�o"
		Processa({||UpdEmp(aRecnoSM0,lOpen)},STR0008,STR0009,.F.)
	Endif
Endif
//����������������������������������������������������������������������������Ŀ
//� Fim do programa                                                            |
//������������������������������������������������������������������������������

Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun??o    �ProcATU   � Autor �                       � Data �  /  /    ���
�������������������������������������������������������������������������Ĵ��
���Descri??o � Funcao de processamento da gravacao dos arquivos           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Baseado na funcao criada por Eduardo Riera em 01/02/2002   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function ProcATU(lEnd,aRecnoSM0,lOpen)
Local cTexto    	:= ""
Local cFile     	:= ""
Local cMask     	:= STR0043 + " (*.TXT) |*.txt|" // "Arquivos Texto"
Local nRecno    	:= 0
Local nI        	:= 0
Local nX        	:= 0
Local cCodigo		:= ""


ProcRegua(1)
IncProc(STR0010)//"Verificando integridade dos dicion�rios...."

If lOpen

	lSel:=.F.
	For nI := 1 To Len(aRecnoSM0)
		DbSelectArea("SM0")
		DbGotop()
		SM0->(dbGoto(aRecnoSM0[nI,9]))

		If !aRecnoSM0[nI,1]
			loop
		Endif
		lSel:=.T.

		RpcSetType(2)
		RpcSetEnv(  SM0->M0_CODIGO, SM0->M0_CODFIL)

		nModulo := 51 // modulo SIGAHSP
		lMsFinalAuto := .F.
		cTexto += Replicate("-",128)+CHR(13)+CHR(10)
		cTexto += STR0025 + aRecnoSM0[nI][2]//"Grupo Empresa: "

		ProcRegua(8)


		If  SM0->M0_CODIGO <> cCodigo   //S� ir� executar manuten��o no SX se For Grupo Empresas Diferentes
			
			conout( "Fun��es descontinuadas pelo SGBD: GeraSX2(),GeraSX3(),GeraSIX() E GeraSXB()" )


			cCodigo := SM0->M0_CODIGO
		Endif

		__SetX31Mode(.F.)
		For nX := 1 To Len(aArqUpd)
			IncProc(STR0016 +"["+aArqUpd[nx]+"]")
			If Select(aArqUpd[nx])>0
				dbSelecTArea(aArqUpd[nx])
				dbCloseArea()
			EndIf
			X31UpdTable(aArqUpd[nx])
			If __GetX31Error()
				Alert(__GetX31Trace())
				Aviso(STR0017,STR0019 + aArqUpd[nx] + STR0018 ,{STR0030},2) //"Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : " //". Verifique a integridade do dicionario e da tabela."  // "Continuar"
				cTexto += STR0019 +aArqUpd[nx] +CHR(13)+CHR(10) //"Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "
			EndIf
			dbSelectArea(aArqUpd[nx])
		Next nX

		RpcClearEnv()
		If !( lOpen := MyOpenSm0Ex() )
			Exit
		EndIf
	Next nI

	If lOpen

		cTexto 				:= STR0020 + CHR(13) + CHR(10) + cTexto //"Log da atualizacao "

		If !lSel
			cTexto+= STR0026//"N�o foram selecionadas nenhuma empresa para Atualiza��o"
		Endif
		__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)

		DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
		DEFINE MSDIALOG oDlg TITLE STR0021+" ["+cFnc+"]"+ STR0022  From 3,0 to 340,417 PIXEL  //"Atualizador   Atualizacao concluida."
		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
		DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
		ACTIVATE MSDIALOG oDlg CENTER

	EndIf

EndIf
Return(Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun??o    �MyOpenSM0Ex� Autor �Sergio Silveira       � Data �07/01/2003���
�������������������������������������������������������������������������Ĵ��
���Descri??o � Efetua a abertura do SM0 exclusivo                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Atualizacao FIS                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function MyOpenSM0Ex()

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	openSM0( cNumEmp,.F. )
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex("SIGAMAT.IND")
		Exit
	EndIf
	Sleep( 500 )
Next nLoop

If !lOpen
	Aviso( STR0017, STR0023, { "Ok" }, 2 ) //Aten��o , "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !"
EndIf

Return( lOpen )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun?ao    � GeraSX2  � Autor � Saude                 � Data �04/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri?ao � Funcao generica para copia de dicionarios                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function GeraSX2()
Local aArea 		:= GetArea()
Local i      		:= 0
Local j      		:= 0
Local aRegs  		:= {}
Local cTexto 		:= ''
Local lInclui		:= .F.

AADD(aRegs,{"GTU","","GTU130  ","Faixa Crescimento Grafico Ananm.","Faixa Crescimento Grafico Ananm.","Faixa Crescimento Grafico Ananm."," ","E","E","E",00," ","GTU_FILIAL+GTU_ITEM ","S",51," "})
dbSelectArea("SX2")
dbSetOrder(1)

For i := 1 To Len(aRegs)

	dbSetOrder(1)
	lInclui := !DbSeek(aRegs[i, 1])

	cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")

	RecLock("SX2", lInclui)
	For j := 1 to FCount()
		If j <= Len(aRegs[i])
			If allTrim(Field(j)) == "X2_ARQUIVO"
				aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
			EndIf
			If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
				Loop
			Else
				FieldPut(j,aRegs[i,j])
			EndIf
		Endif
	Next
	MsUnlock()
Next i

RestArea(aArea)
Return('SX2 : ' + cTexto  + CHR(13) + CHR(10))

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun?ao    � GeraSX3  � Autor � MICROSIGA             � Data �26/04/2011���
�������������������������������������������������������������������������Ĵ��
���Descri?ao � Funcao generica para copia de dicionarios                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function GeraSX3()
Local aArea		:= GetArea()
Local i      	:= 0
Local j      	:= 0
Local aHelp		:= {}
Local aHelpE	:= {}
Local aHelpI	:= {}
Local cHelp		:= ''
Local aRegs  	:= {}
Local cTexto 	:= ''
Local lInclui	:= .F.

aRegs  := {}
AADD(aRegs,{"GTU","01","GTU_FILIAL","C",FWSizeFilial(),00,"Filial      ","Sucursal    ","Branch      ","Filial do Sistema        ","Sucursal                 ","Branch of the System     ","@!","","���������������","","      ",01,"��"," "," ","U","N","A","R"," "," ","","","","","","","033"," "," ","          ","          "," ","N","N","               ","N","N","N"})
AADD(aRegs,{"GTU","02","GTU_ITEM  ","C",06,00,"Item Crescim","Item Crescim","Item Crescim","Itens do Crescimento Graf","Itens do Crescimento Graf","Itens do Crescimento Graf","@!","","���������������","IIF(INCLUI, GETSXENUM('GTU','GTU_ITEM',, 1),GTU->GTU_ITEM) ","      ",01,"��"," "," ","U","S","V","R"," ","        ","        ","        ","   ","","","","   "," "," ","  ","  "," ","N","N","  ","N","N","N"})
AADD(aRegs,{"GTU","05","GTU_PERCEN","C",06,00,"Faixa Percen","Faixa Percen","Faixa Percen","Faixa Percentil          ","Faixa Percentil          ","Faixa Percentil          ","@!","","���������������"," ","      ",01,"��"," "," ","U","S","A","R"," ",""," ","","        ","","","","   "," "," ","          ","          "," ","N","N","   ","N","N","N"})
AADD(aRegs,{"GTU","04","GTU_PERGUN","C",06,00,"Pergunta Ana","Pergunta Ana","Pergunta Ana","Pergunta da Anamne       ","Pergunta da Anamne       ","Pergunta da Anamne       ","@!","","���������������"," ","GCH   ",01,"��"," "," ","U","S","A","R"," ",""," ","","        ","","","","   "," "," ","          ","          "," ","N","N","  ","N","N","N"})
AADD(aRegs,{"GTU","03","GTU_SEXO  ","C",01,00,"Sexo   ","Sexo   ","Sexo   ","Sexo Faixa Crescimento ","Sexo Faixa Crescimento ","Sexo Faixa Crescimento ","@!","Pertence('012')","���������������"," ","      ",01,"��"," "," ","U","S","A","R"," ","","0=Masculino;1=Feminino;2=Ambos","        ","        ","","","","   "," "," ","  ","  "," ","N","N","  ","N","N","N"})
AADD(aRegs,{"GTU","06","GTU_VALORE","C",250,00,"Val.Sequenci","Val.Sequenci","Val.Sequenci","Valores Sequenciais      ","Valores Sequenciais      ","Valores Sequenciais      ","@!","","���������������"," ","      ",01,"��"," "," ","U","S","A","R"," ","","   ","","   ","","","","   "," "," ","          ","          "," ","N","N","  ","N","N","N"})
AADD(aRegs,{"GCH","35","GCH_TEMPO ","C",01,00,"Perg. Tempo ","Perg. Tempo ","Perg. Tempo ","Pergunta Tempo Rel Grafic","Pergunta Tempo Rel Grafic","Pergunta Tempo Rel Grafic","@!","Pertence('01')","���������������","'0'","      ",00,"��"," "," ","U","S","A","R"," ","        ","0=Nao;1=Sim ","        ","        ","","","'0' ","   "," "," ","  "," "," ","N","N","  ","N","N","N"})


dbSelectArea("SX3")
dbSetOrder(1)

For i := 1 To Len(aRegs)

	If(Ascan(aArqUpd, aRegs[i,1]) == 0)
		aAdd(aArqUpd, aRegs[i,1])
	EndIf

	dbSetOrder(2)
	lInclui := !DbSeek(aRegs[i, 3])

	cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")

	RecLock("SX3", lInclui)
	For j := 1 to FCount()
		If j <= Len(aRegs[i])
			If allTrim(Field(j)) == "X2_ARQUIVO"
				aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
			EndIf
			If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
				Loop
			Else
				FieldPut(j,aRegs[i,j])
			EndIf
		Endif
	Next
	MsUnlock()
Next i

//HELP - "GTU_FILIAL"
aHelp := { "Indica a Filial do Sistema."}
cHelp := "GTU_FILIAL"
PutHelp("P"+cHelp,aHelp,aHelpI,aHelpE,.T.)

//HELP - "GTU_ITEM"
aHelp := { "Indica o codigo sequencial do Grafico Padronizado."}
cHelp := "GTU_ITEM"
PutHelp("P"+cHelp,aHelp,aHelpI,aHelpE,.T.)

//HELP - "GTU_PERCEN"
aHelp := { "Informe o codigo Percentil da Linha a ser exibida  ",;
			" na  medida padronizada, seriada e comparada com um padr�o",;
			" de crescimento no Relat�rio Gr�fico da Anamnese"}
cHelp := "GTU_PERCEN"
PutHelp("P"+cHelp,aHelp,aHelpI,aHelpE,.T.)

//HELP - "GTU_PERGUN"
aHelp := { "Informe a Pergunta que  exibir�  ",;
			"a medida padronizada no Relatorio Gr�fico da Anamnese"}
cHelp := "GTU_PERGUN"
PutHelp("P"+cHelp,aHelp,aHelpI,aHelpE,.T.)

//HELP - "GTU_SEXO"
aHelp := { "Informe o Sexo o qual ser� ",;
	" exibido os valores de Medida Padronizada."}
cHelp := "GTU_SEXO"
PutHelp("P"+cHelp,aHelp,aHelpI,aHelpE,.T.)

//HELP - "GTU_VALORE"
aHelp := { "Informe os valores padronizados",;
	" acompanhados de Ponto e Virgula(;)",;
	" para o Percentil Cadastrado"}
cHelp := "GTU_VALORE"
PutHelp("P"+cHelp,aHelp,aHelpI,aHelpE,.T.)

//HELP - "GCH_TEMPO"
aHelp := { "Informe  se a pergunta � do tipo Tempo  ",;
	"se for igual a 1=Sim ",;
	"ser� considerado no Filtro do Relat�rio Grafico da anamnese  " ,;
	"conforme Pergunta, Perg. Tempo ? "}
cHelp := "GCH_TEMPO"
PutHelp("P"+cHelp,aHelp,aHelpI,aHelpE,.T.)



Return('SX3 : ' + cTexto  + CHR(13) + CHR(10))

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GeraSIX  � Autor � MICROSIGA             � Data �   /  /   ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao generica para copia de dicionarios                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GeraSIX()
Local aArea 			:= GetArea()
Local i      		:= 0
Local j      		:= 0
Local aRegs  		:= {}
Local cTexto 		:= ''
Local lInclui		:= .F.

aRegs  := {}
AADD(aRegs,{"GTU","1","GTU_FILIAL+GTU_ITEM+GTU_PERGUN                                                                                                                                  ","Item Crescim+Pergunta Ana                                             ","Item Crescim+Pergunta Ana                                             ","Item Crescim+Pergunta Ana                                             ","U","                                                                                                                                                                ","          ","N"})
AADD(aRegs,{"GTU","2","GTU_FILIAL+GTU_PERGUN+GTU_SEXO                                                                                                                                  ","Pergunta Ana+Tipo Sexo                                                ","Pergunta Ana+Tipo Sexo                                                ","Pergunta Ana+Tipo Sexo                                                ","U","                                                                                                                                                                ","          ","N"})

dbSelectArea("SIX")
dbSetOrder(1)

For i := 1 To Len(aRegs)

 If(Ascan(aArqUpd, aRegs[i,1]) == 0)
 	aAdd(aArqUpd, aRegs[i,1])
 EndIf

 dbSetOrder(1)
 lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2])
 If !lInclui
  TcInternal(60,RetSqlName(aRegs[i, 1]) + "|" + RetSqlName(aRegs[i, 1]) + aRegs[i, 2])
 Endif

 cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")

 RecLock("SIX", lInclui)
  For j := 1 to FCount()
   If j <= Len(aRegs[i])
   	If allTrim(Field(j)) == "X2_ARQUIVO"
   		aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
   	EndIf
    If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
     Loop
    Else
     FieldPut(j,aRegs[i,j])
    EndIf
   Endif
  Next
 MsUnlock()
Next i


RestArea(aArea)
Return('SIX : ' + cTexto  + CHR(13) + CHR(10))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun??o    � UpdEmp   � Autor � Luciano Aparecido     � Data � 15.05.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri??o � Trata Empresa. Verifica as Empresas para Atualizar         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Atualizacao PLS                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

static function  UpdEmp(aRecnoSM0,lOpen)

	Local cVar     := Nil
	Local oDlg     := Nil
	Local cTitulo  := STR0027  //"Escolha a(s) Empresa(s) que ser�(�o) Atualizada(s)"
	Local lMark    := .F.
	Local oOk      := LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Local oNo      := LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Local oChk     := Nil
	Local bCode := {||oDlg:End(),Processa({|lEnd| ProcATU(@lEnd,aRecnoSM0,lOpen)},STR0008,STR0009,.F.)} //"Processando","Aguarde, processando prepara��o dos arquivos"
	Local nI :=0
	Local aRecSM0 :={}

	Private lChk     := .F.
	Private oLbx := Nil


	If ( lOpen := MyOpenSm0Ex() )
		dbSelectArea("SM0")


/////////////////////////////////////////
//| Carrega o vetor conforme a condicao |/
//////////////////////////////////////////
		dbGotop()

		aRecSM0:=FWLoadSM0()


		For nI := 1 to  len(aRecSM0)
			Aadd(aRecnoSM0,{lMark,aRecSM0[nI][1],aRecSM0[nI][6],aRecSM0[nI][2],aRecSM0[nI][3],aRecSM0[nI][4],aRecSM0[nI][5],aRecSM0[nI][7],aRecSM0[nI][12]})
		Next nI

///////////////////////////////////////////////////
//| Monta a tela para usuario visualizar consulta |
///////////////////////////////////////////////////
		If Len( aRecnoSM0 ) == 0
			Aviso( cTitulo, STR0028, {"Ok"} ) //"Nao existe bancos a consultar"
			Return
		Endif

		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,700 PIXEL

		@ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER ;
			" ","Grupo Emp","Descricao", "Codigo","Empresa","Unidade","Filial","Descricao","Recno" ;
			SIZE 335,095 OF oDlg PIXEL ON dblClick(aRecnoSM0[oLbx:nAt,1] := !aRecnoSM0[oLbx:nAt,1],oLbx:Refresh())

		oLbx:SetArray( aRecnoSM0)
		oLbx:bLine := {|| {Iif(aRecnoSM0[oLbx:nAt,1],oOk,oNo),;
			aRecnoSM0[oLbx:nAt,2],;
			aRecnoSM0[oLbx:nAt,3],;
			aRecnoSM0[oLbx:nAt,4],;
			aRecnoSM0[oLbx:nAt,5],;
			aRecnoSM0[oLbx:nAt,6],;
			aRecnoSM0[oLbx:nAt,7],;
			aRecnoSM0[oLbx:nAt,8],;
			Alltrim(Str(aRecnoSM0[oLbx:nAt,9]))}}

////////////////////////////////////////////////////////////////////
//| Para marcar e desmarcar todos existem duas op�oes, acompanhe...
////////////////////////////////////////////////////////////////////


		@ 110,10 CHECKBOX oChk VAR lChk PROMPT  STR0029 SIZE 60,007 PIXEL OF oDlg ; //"Marca/Desmarca"
		ON CLICK(aEval(aRecnoSM0,{|x| x[1]:=lChk}),oLbx:Refresh())

		DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION Eval(bCode) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTER
	Endif

	Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GeraSXB  � Autor � MICROSIGA             � Data �   /  /   ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao generica para copia de dicionarios                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GeraSXB()
Local aArea 			:= GetArea()
Local i      		:= 0
Local j      		:= 0
Local aRegs  		:= {}
Local cTexto 		:= ''
Local lInclui		:= .F.

aRegs  := {}
AADD(aRegs,{"GCH01 ","1","01","DB","Pergunta Rel Grafico","Pergunta Rel Grafico","Pergunta Rel Grafico","GCH                                                                                                                                                                                                                                                       ",""})
AADD(aRegs,{"GCH01 ","2","01","01","Codigo Perg         ","Codigo Preg.        ","Quest.code          ","",""})
AADD(aRegs,{"GCH01 ","4","01","01","Codigo perg         ","Codigo preg.        ","Quest.Code          ","GCH_CODPER                                                                                                                                                                                                                                                ",""})
AADD(aRegs,{"GCH01 ","4","01","02","Titulo              ","Titulo              ","Bill                ","GCH_DESPER                                                                                                                                                                                                                                                ",""})
AADD(aRegs,{"GCH01 ","5","01","  ","                    ","                    ","                    ","GCH->GCH_CODPER                                                                                                                                                                                                                                           ",""})
AADD(aRegs,{"GCH01 ","6","01","  ","                    ","                    ","                    ","GCH_TEMPO = '1'                                                                                                                                                                                                                                           ",""})

dbSelectArea("SXB")
dbSetOrder(1)

For i := 1 To Len(aRegs)

 dbSetOrder(1)
 lInclui := !DbSeek(aRegs[i, 1] + aRegs[i, 2] + aRegs[i, 3] + aRegs[i, 4])

 cTexto += IIf( aRegs[i,1] $ cTexto, "", aRegs[i,1] + "\")

 RecLock("SXB", lInclui)
  For j := 1 to FCount()
   If j <= Len(aRegs[i])
   	If allTrim(Field(j)) == "X2_ARQUIVO"
   		aRegs[i,j] := SubStr(aRegs[i,j], 1, 3) + SM0->M0_CODIGO + "0"
   	EndIf
    If !lInclui .AND. AllTrim(Field(j)) == "X3_ORDEM"
     Loop
    Else
     FieldPut(j,aRegs[i,j])
    EndIf
   Endif
  Next
 MsUnlock()
Next i


RestArea(aArea)
Return('SXB : ' + cTexto  + CHR(13) + CHR(10))
