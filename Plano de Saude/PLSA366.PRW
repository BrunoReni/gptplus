
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA366   �Autor  �Paulo Carnelossi    � Data �  03/07/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para Inclusao de Formas de Pagamento para RDA de     ���
���          �acordo com local de atendimento x especialidade             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA366()        
//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis...                                          �
//�����������������������������������������������������������������������
PRIVATE aRotina     := MenuDef()							
PRIVATE cCadastro 	:= Fundesc()
PRIVATE aHeader     := {}
PRIVATE aCols       := {}
PRIVATE n           := 1

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
���Programa  �PLSA366FPG�Autor  �Paulo Carnelossi    � Data �  05/07/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro das formas de pagamento da RDA/Local/Especialidade ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA366FPG(cAlias, nReg, nOpc)
Local oDlg
Local oBrwBAX
Local oBrwBCD
Local oFolder
Local nOpcx := If(nOpc==K_Visualizar,K_Visualizar,0)
Local nOpca := 0

Local aHeaderBAX, cVar:="", nCtd
Local bCodOpe, bCodEsp, bCodLoc

Local aAuxCabBAX, aCabBAX := {}
Local aAuxDadBAX, aDadBAX := {}
Local aVetBAX := {}

Local aCabBCD 	:= {}
Local aDadBCD 	:= {}
Local aTrbBCD 	:= {}
Local bAtuBCD

Local bCancel := {|| PlsEndBrw(), oDlg:End() }
Local bTudoOk := {|| If(PLSA366TOK(), (nOpca := K_OK,PlsEndBrw(), oDlg:End()), nOpca := 0) }


//��������������������������������������������������������������������������Ŀ
//� Define fonte...                                                          �
//����������������������������������������������������������������������������
Local oFont
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aDifSize:= {,,,,35,3,,}//array com dimen��es para corre��o de telas na vers�o 12

PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aHeader := {}
PRIVATE aCols := {}
PRIVATE n
PRIVATE BAX_CODINT
PRIVATE BAX_CODLOC
PRIVATE BAX_CODESP
PRIVATE BAX_DESESP
						
bAtuBCD	:= {||	M->BAX_CODINT := oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_CODINT")],;
						M->BAX_CODLOC := oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_CODLOC")],;
						M->BAX_CODESP := oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_CODESP")],;
						M->BAX_DESESP := oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_NOMESP")],;
						}

cCadastro 	:= BAU->BAU_CODIGO+"-"+BAU->BAU_NOME

//��������������������������������������������������������������������������Ŀ
//� Define fontes utilizadas somente nesta funcao...                         �
//����������������������������������������������������������������������������
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
//monta browse que ira funcionar como listbox
BAX->(DbSetOrder(1))
aHeaderBAX := {"BAX_CODINT", "BAX_CODLOC", "BAX_CODESP"}
aCabBAX := FunHeader("BAX", aHeaderBAX)

If ! BAX->(DbSeek(xFilial("BAX")+BAU->(BAU_CODIGO))) 
    MsgStop("N�o ha Especialidade cadastrada para esta RDA!")
    Return
Else
	RegToMemory("BAX",.F.)
   Store COLS "BAX" TO aDadBAX FROM aCabBAX VETTRAB aVetBAX ;
   While BAX->(BAX_FILIAL+BAX_CODIGO) == xFilial("BAX")+BAU->BAU_CODIGO
Endif

//preserva os valores originais para utilizacao na execucao dos code blocks
aAuxCabBAX := ACLONE(aCabBAX)
aAuxDadBAX := ACLONE(aDadBAX)

//Operadora
bCodOpe := {|nCtd|cVar := aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODINT"})],;
				Padr(Posicione("BA0",1, xFilial("BA0")+cVar,"BA0_NOMINT"),30)}

InsColuna(aCabBAX, aDadBAX, 2, "BAX", "Desc.Operadora", "BAX_NOMINT", bCodOpe)

//Localidade
bCodLoc := {|nCtd|cVar := BAU->BAU_CODIGO, ;
				cVar += aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODINT"})],;
				cVar += aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODLOC"})],;
				Padr(Posicione("BB8",1, xFilial("BB8")+cVar,"BB8_DESLOC"),30)}

InsColuna(aCabBAX, aDadBAX, 4, "BAX", "Desc.Local", "BAX_NOMLOC", bCodLoc)

//Especialidade
bCodEsp := {|nCtd|cVar := aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODINT"})],;
				cVar += aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODESP"})],;
				Padr(Posicione("BAQ",1, xFilial("BAQ")+cVar,"BAQ_DESCRI"),30)}

InsColuna(aCabBAX, aDadBAX, 6, "BAX", "Desc.Especialidade", "BAX_NOMESP", bCodEsp)


//monta browse para cadastrar as formas de pagamento para RDAxOperadoraxLocalxEspecial.
//���������������������������������������������������������������������Ŀ
//� Formas de Pagamento RDAxOperadoraxLocalidadexEspecialidade          �
//�����������������������������������������������������������������������
Store Header "BCD" TO aCabBCD For .T.
BCD->(DbSetOrder(1))
If ! BCD->(DbSeek(xFilial("BCD")+BAU->BAU_CODIGO))
   If nOpcx == K_Visualizar
      MsgStop("Formas de Pagamento n�o cadastrada!")
      Return
   EndIf   
	Store COLS Blank "BCD" TO aDadBCD FROM aCabBCD
	nOpcx := K_Incluir
	lInclui := .T.
	lAltera := .F.
Else
	Store COLS "BCD" TO aDadBCD FROM aCabBCD VETTRAB aTrbBCD ;
	While BCD->(BCD_FILIAL+BCD_CODIGO) == xFilial("BCD")+BAU->BAU_CODIGO
	If nOpcx != K_Visualizar
		nOpcx := K_Alterar
		lInclui := .F.
		lAltera := .T.
	EndIf	
Endif
If Len(aDadBCD) == 0 
   If nOpcx == K_Visualizar
      MsgStop("Formas de Pagamento n�o cadastrada!")
      Return
   EndIf   
	Store COLS Blank "BCD" TO aDadBCD FROM aCabBCD
	nOpcx := K_Incluir
	lInclui := .T.
	lAltera := .F.
EndIf
						
//���������������������������������������������������������������������Ŀ
//� Define dialogo...                                                   �
//�����������������������������������������������������������������������
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, Round(aSize[ 3 ] * 0.18, 2), .T., .F., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

SetEnch("")
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

oBrwBAX := BAX->(TPLSBrw():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][4],aPosObj[1][3],nil,oDlg,nil,{||.t.},nil,nil,nil,.T.,nil,.T.,nil,aCabBAX,aDadBAX,.F.,"BAX",K_Visualizar,"Formas Pagamento RDA",nil,nil,nil,aVetBAX,,,))
oBrwBAX:bGotFocus 	:= {||Eval(oBrwBAX:bLostFocus), oBrwBCD:ForceRefresh(oBrwBAX)}
oBrwBAX:bLostFocus 	:= {||Eval(bAtuBCD)}
oBrwBAX:bChange 		:= {||Eval(oBrwBAX:bLostFocus), oBrwBCD:ForceRefresh(oBrwBAX)} 

@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL PROMPTS "Formas de Pagamento"

//���������������������������������������������������������������������Ŀ
//� TPLSBCD -> FORMAS DE PAGAMENTO                                      �
//�����������������������������������������������������������������������

bFilter := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BCD_CODINT",aHeader)] == M->BAX_CODINT .And. ;
				aCols[nLine,GdFieldPos("BCD_CODLOC",aHeader)] == M->BAX_CODLOC .And. ;
				aCols[nLine,GdFieldPos("BCD_CODESP",aHeader)] == M->BAX_CODESP }
if Val(GetVersao(.F.)) >= 12 //Valida vers�o 12
	oBrwBCD := TPLSBrw():New(003,003,aPosObj[2][3]-5,aPosObj[2][4]-15,nil,oFolder:aDialogs[1],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBCD,aDadBCD,.F.,"BCD",nOpcx,"Formas de Pagamento",nil,nil,nil,aTrbBCD,,,bFilter,,,,,,,,,,aDifSize)
Else
	oBrwBCD := TPLSBrw():New(003,003,aPosObj[2][3]-5,aPosObj[2][4]-15,nil,oFolder:aDialogs[1],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBCD,aDadBCD,.F.,"BCD",nOpcx,"Formas de Pagamento",nil,nil,nil,aTrbBCD,,,bFilter)
Endif


oBrwBCD:oPai    := oBrwBAX
oBrwBCD:aOrigem := {"BAX_CODINT","BAX_CODLOC","BAX_CODESP"}
oBrwBCD:aRelac  := {"BCD_CODINT","BCD_CODLOC","BCD_CODESP"}                      
//oBrwBCD:cVldLine := ''

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bTudoOk,bCancel,K_MsgDel)

If nOpca == K_OK .And. nOpcx != K_Visualizar
	aChave := {}
	aadd(aChave,{"BCD_CODIGO",BAU->BAU_CODIGO})
	oBrwBCD:Grava(aChave)
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
Static Function InsColuna(aCab, aDad, nPos, cAlias, cTitle, cCampo, bRotFun)
Local nTamCpo, nCtd

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
aAdd(aCab[nPos], "@!")
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

Static Function PLSA366TOK()

Return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PLSA366C �Autor  �Helio F. R. Lecchi  � Data �  24/10/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se e para calcular com ou sem UTV                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA366C()
Local nRetC := 0

If M->BCE_TIPPAG=="2" 
	If AllTrim(M->BCD_UNICON) $ PLSCHMP()
		nRetC := M->BCE_QTDAPT * M->BCE_VLRPAG * Posicione("BFM",1,xFilial("BFM")+M->BCE_CODINT+M->BCE_ANOPAG+M->BCE_MESPAG,"BFM_VALRDA")   
	Else
		nRetC := M->BCE_QTDAPT * M->BCE_VLRPAG   
	Endif	
Else
	nRetC := M->BCE_VLRPAG
Endif

Return(nRetC)

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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
Private aRotina := {	{ STRPL01	    ,'AxPesqui'			, 0 ,K_Pesquisar , 0, .F.},;
						{ "Vis.Formas Pg"	,'PLSA366FPG'		, 0 ,K_Visualizar, 0, Nil},;
						{ "Formas Pagto"	,'PLSA366FPG'		, 0 ,K_Alterar   , 0, Nil} }

//���������������������������������������������������������������������Ŀ
//� Ponto de Entrada p/ incluir nova op��o do usu�rio no aRotina        �
//����������������������������������������������������������������������� 
If ExistBlock("PL366BOT")
	aRotAdic := ExecBlock("PL366BOT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIF
EndIF

Return(aRotina)