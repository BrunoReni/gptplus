#INCLUDE "PLSA367.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"
#define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA367   �Autor  �Paulo Carnelossi    � Data �  05/07/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para Apontamento de Formas de Pagamento para RDA de  ���
���          �acordo com local de atendimento x especialidade             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA367()        
//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis...                                          �
//�����������������������������������������������������������������������
PRIVATE aRotina 	:= MenuDef()							
PRIVATE cCadastro 	:= __cNameBAU

//���������������������������������������������������������������������Ŀ
//� Starta mBrowse...                                                   �
//�����������������������������������������������������������������������
BAU->(DBSetOrder(2))
BAU->(mBrowse(06,01,22,75,"BAU",,,20))

//���������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                          �
//�����������������������������������������������������������������������
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA367FPG�Autor  �Paulo Carnelossi    � Data �  05/07/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro das formas de pagamento da RDA/Local/Especialidade ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA367FPG(cAlias, nReg, nOpc)
Local oDlg
Local oBrwBCD
Local oBrwBCE
Local oFolder
Local nOpcx := If(nOpc==K_Visualizar,K_Visualizar,0)
Local nOpca := 0

Local aHeaderBCD, cVar:="", nCtd
Local bCodOpe, bCodEsp, bCodLoc

Local aAuxCabBCD, aCabBCD := {}
Local aAuxDadBCD, aDadBCD := {}
Local aVetBCD := {}

Local aCabBCE 	 := {}
Local aDadBCE 	 := {}
Local aTrbBCE 	 := {}
Local bAtuBCE
Local bCancel    := {|| PlsEndBrw(), oDlg:End() }
Local bTudoOk    := {|| If(PLSA367TOK() .And. PL367CKLT(oBrwBCE:aCols,oBrwBCE:aHeader), (nOpca := K_OK, PlsEndBrw(), oDlg:End()), nOpca := 0) }
Local aPosObj    := {}
Local aObjects   := {}
Local aSize      := {}
Local aInfo      := {}
Local aUsButtons := {} 
Local nPosESP    := 0
Local nPosFPG    := 0
Local lTrocESP   := .F. 
Local lTrocFPG   := .F. 
//��������������������������������������������������������������������������Ŀ
//� Define fonte...                                                          �
//����������������������������������������������������������������������������
Local oFont
Local I

PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aHeader := {}
PRIVATE aCols := {}
PRIVATE n
PRIVATE BCD_CODINT
PRIVATE BCD_CODLOC
PRIVATE BCD_CODESP
PRIVATE BCD_CODPAG
PRIVATE BCD_DESESP
PRIVATE BAX_DESESP

bAtuBCE	:= {||	cVar := oBrwBCD:aCols[oBrwBCD:Linha(),oBrwBCD:FieldPos("BCD_CODINT")],;
						cVar += oBrwBCD:aCols[oBrwBCD:Linha(),oBrwBCD:FieldPos("BCD_CODLOC")],;
						cVar += oBrwBCD:aCols[oBrwBCD:Linha(),oBrwBCD:FieldPos("BCD_CODESP")],;
						cVar += oBrwBCD:aCols[oBrwBCD:Linha(),oBrwBCD:FieldPos("BCD_CODPAG")],;
						BCD->(dbSeek(xFilial("BCD")+BAU->BAU_CODIGO+cVar)),;
						M->BAX_DESESP := oBrwBCD:aCols[oBrwBCD:Linha(),oBrwBCD:FieldPos("BCD_NOMESP")],;
						RegToMemory("BCD",.F.),;
						M->BCD_DESESP := oBrwBCD:aCols[oBrwBCD:Linha(),oBrwBCD:FieldPos("BCD_NOMESP")];
						}

cCadastro 	:= BAU->BAU_CODIGO+"-"+BAU->BAU_NOME

//��������������������������������������������������������������������������Ŀ
//� Define fontes utilizadas somente nesta funcao...                         �
//����������������������������������������������������������������������������
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
//monta browse que ira funcionar como listbox
BCD->(DbSetOrder(1))
aHeaderBCD := {"BCD_CODINT", "BCD_CODLOC", "BCD_CODESP", "BCD_CODPAG"}
aCabBCD := FunHeader("BCD", aHeaderBCD)

If ! BCD->(DbSeek(xFilial("BCD")+BAU->(BAU_CODIGO))) 
    MsgStop(STR0001) //"N�o ha Forma de Pagamento cadastrada para esta RDA!"
    Return
Else
	RegToMemory("BCD",.F.)
   Store COLS "BCD" TO aDadBCD FROM aCabBCD VETTRAB aVetBCD ;
   While BCD->(BCD_FILIAL+BCD_CODIGO) == xFilial("BCD")+BAU->BAU_CODIGO
Endif

//preserva os valores originais para utilizacao na execucao dos code blocks
aAuxCabBCD := ACLONE(aCabBCD)
aAuxDadBCD := ACLONE(aDadBCD)

//Operadora
bCodOpe := {|nCtd|cVar := aAuxDadBCD[nCtd][ASCAN(aAuxCabBCD,{|aVal| aVal[2] == "BCD_CODINT"})],;
				Padr(Posicione("BA0",1, xFilial("BA0")+cVar,"BA0_NOMINT"),30)}

InsColuna(aCabBCD, aDadBCD, 2, "BCD", STR0002, "BCD_NOMINT", bCodOpe) //"Desc.Operadora"

//Localidade
bCodLoc := {|nCtd|cVar := BAU->BAU_CODIGO, ;
				cVar += aAuxDadBCD[nCtd][ASCAN(aAuxCabBCD,{|aVal| aVal[2] == "BCD_CODINT"})],;
				cVar += aAuxDadBCD[nCtd][ASCAN(aAuxCabBCD,{|aVal| aVal[2] == "BCD_CODLOC"})],;
				Padr(Posicione("BB8",1, xFilial("BB8")+cVar,"BB8_DESLOC"),30)}

InsColuna(aCabBCD, aDadBCD, 4, "BCD", STR0003, "BCD_NOMLOC", bCodLoc) //"Desc.Local"

//Especialidade
bCodEsp := {|nCtd|cVar := aAuxDadBCD[nCtd][ASCAN(aAuxCabBCD,{|aVal| aVal[2] == "BCD_CODINT"})],;
				cVar += aAuxDadBCD[nCtd][ASCAN(aAuxCabBCD,{|aVal| aVal[2] == "BCD_CODESP"})],;
				Padr(Posicione("BAQ",1, xFilial("BAQ")+cVar,"BAQ_DESCRI"),30)}

InsColuna(aCabBCD, aDadBCD, 6, "BCD", STR0004, "BCD_NOMESP", bCodEsp) //"Desc.Especialidade"

//Forma de Pagamento
bCodPag := {|nCtd|cVar := aAuxDadBCD[nCtd][ASCAN(aAuxCabBCD,{|aVal| aVal[2] == "BCD_CODPAG"})],;
				Padr(Posicione("BBB",1, xFilial("BBB")+cVar,"BBB_DESCRI"),30)}

InsColuna(aCabBCD, aDadBCD, 8, "BCD", STR0005, "BCD_NOMPAG", bCodPag) //"Desc.Forma Pagto."

//monta browse para cadastrar as formas de pagamento para RDAxOperadoraxLocalxEspecial.
//���������������������������������������������������������������������Ŀ
//� Formas de Pagamento RDAxOperadoraxLocalidadexEspecialidade          �
//�����������������������������������������������������������������������
Store Header "BCE" TO aCabBCE For .T.  

//Retira o Virtual dos Campos para realizar o CriaVar quando Inclus�o aCols Blank
nPosESP:= AScan(aCabBCE,{|aCab|aCab[2]=="BCE_DESESP" }) // Descricao Especialidade
nPosFPG:= AScan(aCabBCE,{|aCab|aCab[2]=="BCE_DESPAG" }) // Descri��o Forma Pagto
IF nPosESP > 0
	aCabBCE[nPosESP,10]:= "" 
	lTrocESP := .T.
Endif
If nPosFPG > 0 
	aCabBCE[nPosFPG,10]:= "" 
	lTrocFPG := .T.
Endif

BCE->(DbSetOrder(1))
If ! BCE->(DbSeek(xFilial("BCE")+BAU->BAU_CODIGO))
   If nOpcx == K_Visualizar
      MsgStop(STR0006) //"Apontamento por formas de pagamento n�o existente!"
      Return
   EndIf   
	Store COLS Blank "BCE" TO aDadBCE FROM aCabBCE
	nOpcx := K_Incluir
	Inclui := .T.
	Altera := .F.
Else
	Store COLS "BCE" TO aDadBCE FROM aCabBCE VETTRAB aTrbBCE ;
	While BCE->(BCE_FILIAL+BCE_CODIGO) == xFilial("BCE")+BAU->BAU_CODIGO
	If nOpcx != K_Visualizar
		nOpcx := K_Alterar
		Inclui := .F.
		Altera := .T.
	EndIf
	Inclui:=.T.	
Endif
If Len(aDadBCE) == 0 
   If nOpcx == K_Visualizar
      MsgStop(STR0006) //"Apontamento por formas de pagamento n�o existente!"
      Return
   EndIf   	Store COLS Blank "BCE" TO aDadBCE FROM aCabBCE
	nOpcx := K_Incluir
	Inclui := .T.
	Altera := .F.
EndIf
						
//���������������������������������������������������������������������Ŀ
//� Define dialogo...                                                   �
//�����������������������������������������������������������������������
SetEnch("")

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

oBrwBCD := TPLSBrw():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][4],aPosObj[1][3],nil,oDlg,nil,{||.t.},nil,nil,nil,.T.,nil,.T.,nil,aCabBCD,aDadBCD,.F.,"BCD",K_Visualizar,STR0007,nil,nil,nil,aVetBCD,,,) //"Formas Pagamento RDA"
oBrwBCD:bGotFocus 	:= {||Eval(oBrwBCD:bLostFocus) , oBrwBCE:ForceRefresh(oBrwBCD)}
oBrwBCD:bLostFocus 	:= {||Eval(bAtuBCE)}
oBrwBCD:bChange 	:= {||Eval(oBrwBCD:bLostFocus), oBrwBCE:ForceRefresh(oBrwBCD)} 
 
@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL PROMPTS STR0008 //"Apontamento Por Forma de Pagamento"

//���������������������������������������������������������������������Ŀ
//� TPLSBCE -> FORMAS DE PAGAMENTO                                      �
//�����������������������������������������������������������������������

bFilter := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BCE_CODINT",aHeader)] == M->BCD_CODINT .And. ;
				aCols[nLine,GdFieldPos("BCE_CODLOC",aHeader)] == M->BCD_CODLOC .And. ;
				aCols[nLine,GdFieldPos("BCE_CODPAG",aHeader)] == M->BCD_CODPAG .And. ;
				aCols[nLine,GdFieldPos("BCE_CODESP",aHeader)] == M->BCD_CODESP }

oBrwBCE := TPLSBrw():New(003,003,aPosObj[1][4]-7,aPosObj[1][3] * 0.75,nil,oFolder:aDialogs[1],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBCE,aDadBCE,.F.,"BCE",nOpcx,STR0009,nil,nil,nil,aTrbBCE,,,bFilter) //"Formas de Pagamento"

oBrwBCE:oPai    := oBrwBCD
oBrwBCE:aOrigem := {"BCD_CODINT","BCD_CODLOC","BCD_CODESP", "BCD_CODPAG"}
oBrwBCE:aRelac  := {"BCE_CODINT","BCE_CODLOC","BCE_CODESP", "BCE_CODPAG"}                      

//������������������������������������������������������������������������Ŀ
//� ponto de entrada p/ adicionar botoes do usuario na EnchoiceBar         �
//��������������������������������������������������������������������������
If ExistBlock( "PL367BUT" ) 
	aUsButtons := ExecBlock("PL367BUT", .F., .F. ) 	 	
EndIf 	

//fim ponto de entrada

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bTudoOk,bCancel,K_MsgDel,aUsButtons)

If nOpca == K_OK .And. nOpcx != K_Visualizar
	aChave := {}
	aadd(aChave,{"BCE_CODIGO",BAU->BAU_CODIGO})
	
	// Retorna o Virtual do Campo antes de chamar a rotina de Grava��o
	If lTrocESP
		aCabBCE[nPosESP,10]:= "V" 
		oBrwBCE:aHeader[nPosESP,10]:= "V"
	Endif
	If lTrocFPG
		aCabBCE[nPosFPG,10]:= "V" 
		oBrwBCE:aHeader[nPosFPG,10]:= "V"
	Endif
	
	oBrwBCE:Grava(aChave)
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �InsColuna �Autor  �Paulo Carnelossi    � Data �  03/07/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inserir uma coluna nos arrays aCabAlias, aDadAlias para uso ���
���          �na browse da classe plsbrw                                  ���
���          �somente colunas caracteres, criando campo virtual - Visual  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function InsColuna(aCab, aDad, nPos, cAlias, cTitle, cCampo, bRotFun, lBitMap)
Local nTamCpo, nCtd
DEFAULT lBitMap := .F.

ASIZE(aCab,Len(aCab)+1)
AINS(aCab, nPos)

For nCtd := 1 TO LEN(aDad)
	ASIZE(aDad[nCtd], Len(aDad[nCtd])+1)
	AINS(aDad[nCtd], nPos)
	aDad[nCtd][nPos] := Eval(bRotFun, nCtd)
	nTamCpo := Len(aDad[nCtd][nPos])
Next	

/*
[ 1] := SX3->X3_TITULO
[ 2] := SX3->X3_CAMPO
[ 3] := SX3->X3_PICTURE
[ 4] := SX3->X3_TAMANHO
[ 5] := SX3->X3_DECIMAL
[ 6] := SX3->X3_VALID
[ 7] := SX3->X3_USADO
[ 8] := SX3->X3_TIPO
[ 9] := SX3->X3_ARQUIVO
[10] := SX3->X3_CONTEXT
*/

aCab[nPos] := {}
aAdd(aCab[nPos], cTitle)
aAdd(aCab[nPos], cCampo)
aAdd(aCab[nPos], If(lBitMap,"@BMP","@!"))
aAdd(aCab[nPos], nTamCpo)
aAdd(aCab[nPos], 0)
aAdd(aCab[nPos], "")
aAdd(aCab[nPos], "")
aAdd(aCab[nPos], "C")
aAdd(aCab[nPos], cAlias)
aAdd(aCab[nPos], "V")

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FunHeader �Autor  �Paulo Carnelossi    � Data �  03/07/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Devolver um array contendo somente os campos desejados no   ���
���          �alias determinado com array enviado como argumento          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FunHeader(cAlias, aHeader)
Local aAuxCab, nPos, cCampo, nCtd
Local aCab := {}

Store Header cAlias TO aAuxCab For .T.

For nCtd := 1 TO Len(aHeader)
    cCampo := aHeader[nCtd]
    nPos := ASCAN(aAuxCab,{|aVal| aVal[2] == cCampo})
    If nPos > 0
    	aAdd(aCab, aAuxCab[nPos])
    EndIf
Next

Return(aCab)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO2     �Autor  �Microsiga           � Data �  07/05/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PLSA367TOK()
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLRELAFORM�Autor  �Luciano Aparecido   � Data �  14/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Tratar o Rela��o do campo BCE_DESPAG						  ���
���          �Se Inclus�o passa o M->BCD_CODPAG, senao BCE->BCE_CODPAG    ���
�������������������������������������������������������������������������͹��
���Uso       � Plano de Sa�de                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLRELAFORM(cCodPag)
Local cDescr    := ""
Default cCodPag := ""

If Inclui
	cDescr:=Posicione("BBB",1,xFilial("BBB")+Alltrim(cCodPag),"BBB_DESCRI") 
Else
	cDescr:=Posicione("BBB",1,xFilial("BBB")+Alltrim(cCodPag),"BBB_DESCRI") 
Endif

Return cDescr

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �04/01/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Private aRotina := {	{ STR0010	,'AxPesqui'			, 0 ,K_Pesquisar , 0, .F.},; //"Pesquisar"
						{ STR0011	,'PLSA367FPG'		, 0 ,K_Visualizar, 0, Nil},; //"Vis.Apontamentos"
						{ STR0012	,'PLSA367FPG'		, 0 ,K_Alterar   , 0, Nil}} //"Apontamentos"
								                                                             
//���������������������������������������������������������������������Ŀ
//� Ponto de Entrada para incluir rotinas novas pelo usuario            �
//�����������������������������������������������������������������������
								
If ExistBlock("PL367ROT")
	aRotAdic := ExecBlock("PL367ROT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIF
EndIF

//Fim do Ponto de Entrada								
Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PL367CKLT � Autor � Victor	            � Data �12/11/2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se o apontamento possui lote de cobranca          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � PLSA367													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL367CKLT(aColsBCE,aHeaderBCE)

Local 	nI
Local 	nAux1
Local 	nAux2
Local 	nAux3
Local 	nAux4
Local 	nAux5
Local 	cMsg 		:= ""
Local 	cAlerta 	:= ""
Local	aAuxBCE		:= {}
Default aColsBCE 	:= {}
Default aHeaderBCE	:= {}

If Len (aHeaderBCE) >= 1
	For nI := 1 to Len(aHeaderBCE)
		aAdd(aAuxBCE,aHeaderBCE[nI][2])
	Next nI
	
	nAux1 := aScan(aAuxBCE,"BCE_NUMLOT")
	nAux2 := aScan(aAuxBCE,"BCE_ANOPAG")
	nAux3 := aScan(aAuxBCE,"BCE_MESPAG")
	nAux4 := aScan(aAuxBCE,"BCE_SEQPAG")
	nAux5 := aScan(aAuxBCE,"BCE_DESESP")
Else
	Return (.T.)	
Endif

If Len(aColsBCE) >= 1
	nAux6 := Len(aColsBCE[1])
	For nI := 1 to Len(aColsBCE)
		If !Empty(aColsBCE[nI][nAux1]) .And. aColsBCE[nI][nAux6]
			cMsg += STR0016+Alltrim(aColsBCE[nI][nAux5])					//"Espec.: ######"
			cMsg += STR0017+aColsBCE[nI][nAux2]+"/"+aColsBCE[nI][nAux3]	//" - Refer�ncia: ####/##"
			cMsg += STR0018+aColsBCE[nI][nAux4]						   		//" - Seq/Pagto: ###"
			cMsg += CRLF
		Endif
	Next nI
Else
	Return(.T.)
Endif

If !Empty(cMsg)
	cAlerta := STR0014 + CRLF + CRLF + cMsg + CRLF + STR0015//"O(s) seguinte(s) apontamento(s) possui(em) Lote de Pagamento:","N�o foi poss�vel realizar a exclus�o"
	MsgInfo(cAlerta,STR0013) //Anten��o
	Return(.F.)
Endif

Return (.T.)