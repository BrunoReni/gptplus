#include "PLSA515.CH"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"
#IFDEF TOP
       #include "TOPCONN.CH"
#ENDIF       

#Define C_ALIAS 		1 //X3_ALIAS
#Define C_CAMPO 		2 //X3_CAMPO
#Define C_TIPO 			3 //X3_TIPO
#Define C_TAMANHO 		4 //X3_TAMANHO
#Define C_SUB 			5 //lSub
#Define C_TITLE 		6 //X3Title()
#Define C_PICTURE 		7 //X3_PICTURE
#Define C_CAB 			8 //lCab
#Define C_CBOX 			9 //CBOX

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSA515 � Autor � Paulo Carnelossi	  � Data � 09/02/04   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Operadora x Valor Padrao de Co-Participacao    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA515()
//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis...                                          �
//�����������������������������������������������������������������������
PRIVATE aRotina :=	MenuDef()

PRIVATE cCadastro 	:= Fundesc()

BWK->(mBrowse(06,01,350,256,"BWK",,,20))

SET KEY VK_F12 TO

Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PL515AMov � Autor � Paulo Carnelossi      � Data � 09/02/04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Modulo de Manutencao OperadoraxValor Padrao Co-Participacao���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �PL515AMov(cAlias,nReg,nOpc)                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PL515Mov(cAlias,nReg,nOpc)
Local I__f := 0
//���������������������������������������������������������������������Ŀ
//� Define variaveis...                                                 �
//�����������������������������������������������������������������������

LOCAL aPosObj   := {}
LOCAL aObjects  := {}
LOCAL aSize     := {}
LOCAL aInfo     := {}

Local nOpca := 0
Local oDlg, ni

Local oFont
Local lLock := .F.


Local oEncBWK
Local oFolder

Local nOpcx        := nOpc
Local oDlgFolder

//���������������������������������������������������������������������Ŀ
//� Operadora x Valor para coo-participacao                             �
//�����������������������������������������������������������������������
Local aCabBWW := {}
Local aDadBWW := {}
Local aTrbBWW := {}

PRIVATE aHeader      := {}
PRIVATE aCols        := {}
PRIVATE oBrwBWW

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

//���������������������������������������������������������������������Ŀ
//� Operadora x Valor para coo-participacao                              �
//�����������������������������������������������������������������������
Store Header "BWW" TO aCabBWW For .T.   

If nOpcx == K_Incluir
   Store COLS Blank "BWW" TO aDadBWW FROM aCabBWW
Else
   BWW->(DbSetOrder(1))
   If ! BWW->(DbSeek(xFilial("BWW")+BWK->BWK_CODINT+BWK->BWK_ANO+BWK->BWK_MES))
       Store COLS Blank "BWW" TO aDadBWW FROM aCabBWW
   Else
       Store COLS "BWW" TO aDadBWW FROM aCabBWW VETTRAB aTrbBWW ;
       While BWW->(BWW_FILIAL+BWW_CODINT+BWW_ANO+BWW_MES) == xFilial("BWW")+BWK->BWK_CODINT+BWK->BWK_ANO+BWK->BWK_MES
   Endif
   If Len(aDadBWW) == 0
      Store COLS Blank "BWW" TO aDadBWW FROM aCabBWW
   EndIf
Endif

//���������������������������������������������������������������������Ŀ
//� Define dialogo...                                                   �
//�����������������������������������������������������������������������

aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )

DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
//���������������������������������������������������������������������Ŀ
//� ENCHOICE (BWK)                                                      �
//�����������������������������������������������������������������������

If nOpcx == K_Incluir
   Copy "BWK" TO Memory Blank
Else
   Copy "BWK" TO Memory 
Endif

//���������������������������������������������������������������������Ŀ
//� MSMGET -> Operadora/Produto                                         �
//�����������������������������������������������������������������������

cAlias:="BWK"
nReg:=BWK->(RecNo())
oEncBWK := MSMGet():New(cAlias,nReg,nOpcx,,,,,aPosObj[1],,,,,,oDlgFolder,,,.F.)

//���������������������������������������������������������������������Ŀ
//� Browse para Itens do cad. Oper. x Vlr Padrao Co-Participacao        �
//�����������������������������������������������������������������������
oBrwBWW := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil,oDlgFolder,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBWW,aDadBWW,.F.,"BWW",nOpcx,"Operadora x Valor Padrao de Co-Participacao",nil,nil,nil,aTrbBWW,'PlsVldBWW',,)
oBrwBWW:bGotFocus := {||If(!Obrigatorio(oEncBWK:aGets, oEncBWK:aTela),oEncBWK:SetFocus(),.T.)}
//���������������������������������������������������������������������Ŀ
//� Ativa o dialogo...                                                  �
//�����������������������������������������������������������������������

ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{|| If( P515TudoOk(nOpcx) ,(PlsEndBrw(),nOpca := 1,oDlgFolder:End()),.F.)},{|| PlsEndBrw(), nOpca :=2 , oDlgFolder:End() },K_MsgDel)

//���������������������������������������������������������������������Ŀ
//� Trata atualizacao dos dados...                                      �
//�����������������������������������������������������������������������
If nOpca == K_OK
  
   If nOpcx <> K_Visualizar 
      //���������������������������������������������������������������������Ŀ
      //� Operadora+Produto                                                   �
      //�����������������������������������������������������������������������
      
      BWK->(DbGoTo(nReg))
      PLUPTENC("BWK",nOpc)
      //���������������������������������������������������������������������Ŀ
      //� Comissao da Operadora/Produto                                       �
      //�����������������������������������������������������������������������
      aChave := {}
      aadd(aChave,{"BWW_CODINT"	,M->BWK_CODINT})
      aadd(aChave,{"BWW_ANO"	,M->BWK_ANO})
      aadd(aChave,{"BWW_MES"	,M->BWK_MES})
      oBrwBWW:Grava(aChave)

   Endif   

Endif

//���������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                          �
//�����������������������������������������������������������������������

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � P515TudoOk � Autor � Marco Paulo         � Data � 03.10.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Faz a checagem dos campos e pastas obrigatorias            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � P515Tudook(nOpc)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nOpc - Opcao do aRotina                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function P515TudoOk(nOpc)
Local lRet := .T.

BWK->(DbSetOrder(1))
BWK->(DbSeek(xFilial()+M->BWK_CODINT+M->BWK_ANO+M->BWK_MES))
If nOpc == K_Incluir .and. !BWK->(Eof()) // SE FOR INCLUSAO VERIFICA SE O CODIGO JA ESTA GRAVADO NO ARQUIVO E NAO DEIXA CONTINUAR
   Help("",1,"JAGRAVADO")
   Return .F.
EndIf

If ! (oBRWBWW:TudoOk())
  	lRet    := .F.
EndIf 

Return lRet
   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA515   �Autor  �Microsiga           � Data �  06/03/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PL515Imp(cAlias,nReg,nOpc)
PLR515()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLR515     �Autor  �Paulo Carnelossi   � Data �  09/02/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Imprime relacao com cadastro de Operadoras x Valora para    ���
���          �Coo-Participacao                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PLR515()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir os cadastros"
Local cDesc2 := "de Operadoras x Valor Padrao de Co-Participacao."
Local cDesc3 := ""
Local cString := "BWW"
Local Tamanho := "G"

PRIVATE cTitulo:= "Cadastro de Operadoras x Valor Padrao de Co-Participacao"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLR515"
Private nomeprog:= "PLR515" 
Private nLastKey:=0
//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel := "PLR515"

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

RptStatus({|lEnd| R515Imp(@lEnd,wnRel,cString)},cTitulo)
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � R515Imp  � Autor � Paulo Carnelossi      � Data � 09/02/04 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Impressao Cadastro de OperxValor Padrao de co-participacao ���
��������������������������������������������������������������������������Ĵ��
��� Sintaxe   � R515Imp(lEnd,wnRel,cString)                                ���
��������������������������������������������������������������������������Ĵ��
��� Uso       �                                                            ���
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R515Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local tamanho:= "G"
Local nTipo 
Local cChave, cOperadora, cProduto,lTitulo, cAnoMes
Local bCond := {||BWW->BWW_ANO+BWW->BWW_MES >= mv_par02+mv_par03 .And. BWW->BWW_ANO+BWW->BWW_MES <= mv_par04+mv_par05}

Local aCpos, aAuxCab, nZ
Local aExcCpo := {}
Local aExcTam := {}
//��������������������������������������������������������������Ŀ
//� Definicao dos cabecalhos                                     �
//����������������������������������������������������������������
aCpos  := Cpos_PLSR515()

aAuxCab := Linha_Cabec("BWW", aCpos, aExcTam)  
cabec1 := aAuxCab[1]
cabec2 := aAuxCab[2]

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=GetMv("MV_COMP")

dbSelectArea("BWW")
SetRegua(RecCount())
dbSeek(xFilial("BWW")+mv_par01)

While BWW->(! Eof() .And. BWW_FILIAL == xFilial("BWW") .And. BWW_CODINT == mv_par01)
	
	IncRegua()
	
	cAnoMes     := BWW_ANO+BWW_MES
	cChave 		:= xFilial("BWW")+BWW_CODINT+BWW_ANO+BWW_MES
	lTitulo 		:= .T.
	
	While  BWW->(! EOF() .And. BWW_FILIAL+BWW_CODINT+BWW_ANO+BWW_MES == cChave)
	
		If Eval(bCond)
			IF li > 58
				cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			End
			
			If lTitulo
	
				cOperadora  := BWW_CODINT+" - "+Padr(Posicione("BA0",1,xFilial("BA0")+BWW->BWW_CODINT,"BA0_NOMINT"),40)
				@ li,000 PSAY cOperadora
				li++
				@ li,000 PSAY PLRETMES(Val(Right(cAnoMes,2)))+"/"+Left(cAnoMes,4)
				li++
				lTitulo := .F.
				
	        EndIf
	         
			Impr_Linha("BWW", aCpos, 000)
		
    	EndIf
   	
   		BWW->(dbSkip())
		
	End
	
	li++
	
End

roda(cbcont,cbtxt,tamanho)

//��������������������������������������������������������������Ŀ
//� Recupera a Integridade dos dados                             �
//����������������������������������������������������������������
dbSelectArea("BWW")

Set Device To Screen

If aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �PLSA515WHE� Autor � Tulio Cesar          � Data � 14.01.2003 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � When de diversos campo do siga...                           ���
���          � nao cabe no X3_WHEN ai coloca em uma funcao                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA515Whe(cTipo)
LOCAL lPode := .F.

If     cTipo == "01" //BWW_PERCOP
       lPode := ( M->BWW_VLRCOP == 0 )
ElseIf cTipo == "02" //BWW_VLRCOP
       lPode := ( M->BWW_PERCOP == 0 .And. M->BWW_VALUS == 0 )       
ElseIf cTipo == "03" //BWW_VALUS
       lPode := ( M->BWW_VLRCOP == 0 )       
Endif
                                        
Return(lPode)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Cpos_PLSR515 �Autor  �Paulo Carnelossi   � Data � 09/01/04  ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta array com campos a serem impresso no                 ���
���Desc.     � relatorio Autor.Negadas POS                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Cpos_PLSR515()
Local aCpoImp := {}, aCampos := {}, nX
Local lTit := .F., aCpoTit := {}, aAlias := {"BWW"}
Local lSub := .F., aCpoSub := {}

aAdd(aCpoTit, "BWW_FILIAL")
aAdd(aCpoTit, "BWW_CODINT")
aAdd(aCpoTit, "BWW_ANO")
aAdd(aCpoTit, "BWW_MES")

dbSelectArea("SX3")
dbSetOrder(1)

For nX := 1 TO Len(aAlias)
    If dbSeek(aAlias[nX])
    	While SX3->(!Eof() .And. X3_ARQUIVO == aAlias[nX]) .and. X3_CONTEXT != 'V'
			aAdd(aCpoImp, Alltrim(SX3->X3_CAMPO))
            SX3->(dbSkip())
   		End
   EndIf
Next

dbSelectArea("SX3")
dbSetOrder(2)

For nX := 1 TO Len(aCpoImp)
	lTit := .F.
	lSub := .F.
    If dbSeek(aCpoImp[nX])
        lTit := ASCAN(aCpoTit, aCpoImp[nX]) > 0
        lSub := ASCAN(aCpoSub, aCpoImp[nX]) > 0
    	aAdd(aCampos, { X3_ARQUIVO, X3_CAMPO, X3_TIPO, X3_TAMANHO, lSub, X3_TITULO, X3_PICTURE, lTit, X3_CBOX })
    EndIf
Next

Return(aCampos)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Linha_Cabec �Autor  �Paulo Carnelossi  � Data �  09/01/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta Linha Cabec para Relatorio                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Linha_Cabec(cAlias, aCampos, aExcTam)
Local nX, aLinCabec, cLinCabec1 := "", cLinCabec2 := "", cTitle, aAuxText
Local nZ, aComboBox, nMaiorTam := 0

For nX := 1 TO Len(aCampos)

	If aCampos[nX][C_ALIAS] == cAlias .And. ! aCampos[nX][C_CAB]
        
        cTitle := AllTrim(aCampos[nX][C_TITLE])
        
		If aCampos[nX][C_TIPO] == "N"
		
       		If Len(cTitle) <= aCampos[nX][C_TAMANHO]
				cLinCabec1 += PadL(cTitle, aCampos[nX][C_TAMANHO])
				cLinCabec2 += Space(aCampos[nX][C_TAMANHO])
			Else
				aAuxText := R515QbTexto(cTitle, aCampos[nX][C_TAMANHO], Space(1))
				cLinCabec1 += PadL(aAuxText[1], aCampos[nX][C_TAMANHO])
				If Len(aAuxText) > 1
					cLinCabec2 += PadL(aAuxText[2], aCampos[nX][C_TAMANHO])
				EndIf	
			EndIf
			cLinCabec1 += Space(1)
			cLinCabec2 += Space(1)
			
       	Else

       		If  (nPosTam := ASCAN(aExcTam, {|aVal| aVal[1] == aCampos[nX][C_CAMPO]})) > 0
       			aCampos[nX][C_TAMANHO] := aExcTam[nPosTam][2]
       		EndIf
       		
       		If ! EMPTY(aCampos[nX][C_CBOX]) // COMBO BOX
       		    aComboBox := RetSX3Box(aCampos[nX][C_CBOX],,,1)
       		    nMaiorTam := aCampos[nX][C_TAMANHO]
       		    AEVAL(aComboBox, {|cValue, nZ|nMaiorTam := If(Len(aComboBox[nZ][1]) > nMaiorTam, Len(aComboBox[nZ][1]), nMaiorTam)} )
       			aCampos[nX][C_TAMANHO] := nMaiorTam
       	    EndIf
       	    
       		If Len(cTitle) <= aCampos[nX][C_TAMANHO]
				cLinCabec1 += PadR(cTitle, aCampos[nX][C_TAMANHO])
				cLinCabec2 += Space(aCampos[nX][C_TAMANHO])
			Else
				aAuxText := R515QbTexto(cTitle, aCampos[nX][C_TAMANHO], Space(1))
				cLinCabec1 += PadR(aAuxText[1], aCampos[nX][C_TAMANHO])
				If Len(aAuxText) > 1
					cLinCabec2 += PadR(aAuxText[2], aCampos[nX][C_TAMANHO])
				EndIf	
			EndIf
			cLinCabec1 += Space(1)
			cLinCabec2 += Space(1)

       	EndIf
       
	EndIf
	
Next

aLinCabec := { cLinCabec1, cLinCabec2 }

Return(aLinCabec)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Impr_Linha  �Autor  �Paulo Carnelossi  � Data �  09/01/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Imprime Linha de dados                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Impr_Linha(cAlias, aCampos, nCol, aChvImp, lQuebraLinha)
Local nX, xContCpo, aComboBox, nZ, cValue, cCombo, cCampo, nPosCpo
Local aLinSobra := {}, aAuxCont, aSobra := {}

DEFAULT aChvImp := {}
DEFAULT lQuebraLin := .F.

For nX := 1 TO Len(aCampos)
    
	If aCampos[nX][C_ALIAS] == cAlias .And. ! aCampos[nX][C_CAB]
        
        nPosCpo := (cAlias)->(FieldPos(aCampos[nX][C_CAMPO]))
        If nPosCpo > 0 
        	xContCpo := (cAlias)->(FieldGet(nPosCpo))
       	Else
        	cCampo   :=aCampos[nX][C_CAMPO]
        	xContCpo := &cCampo
        EndIf
        
		If aCampos[nX][C_TIPO] == "N"
		    If Empty(aChvImp) .OR. ASCAN(aChvImp, aCampos[nX][C_CAMPO]) == 0
				@ li, nCol PSay PadL(Transform(xContCpo, aCampos[nX][C_PICTURE]), aCampos[nX][C_TAMANHO])
			EndIf	
       	Else
       		If aCampos[nX][C_TIPO] == "D"
       			xContCpo := DTOC(xContCpo)
       		EndIf
       		
       		If ! EMPTY(aCampos[nX][C_CBOX]) // COMBO BOX
       		    aComboBox := RetSX3Box(aCampos[nX][C_CBOX],,,1)
       		    cCombo := NIL
       		    For nZ := 1 To Len(aComboBox)
	       		    If aComboBox[nZ][2] == xContCpo
	       		    	cCombo := aComboBox[nZ][1]
       		    	    Exit
       		    	EndIf
       		    Next	    
       		    xContCpo := If(cCombo == NIL, xContCpo, cCombo)
       	    EndIf
       		
       		If Empty(aChvImp) .OR. ASCAN(aChvImp, aCampos[nX][C_CAMPO]) == 0
				@ li, nCol PSay PadR(xContCpo, aCampos[nX][C_TAMANHO])
			EndIf
			
			If lQuebraLinha .And. aCampos[nX][C_TIPO] == "C" .And. Len(xContCpo) > aCampos[nX][C_TAMANHO]
				aAdd(aLinSobra, {li,nCol, xContCpo, aCampos[nX][C_TAMANHO]})
			EndIf

       	EndIf

		nCol += aCampos[nX][C_TAMANHO]+1  //1->separador
        
    EndIf
    
Next

li++

If lQuebraLinha
	aSobra := {}
	For nX := 1 TO Len(aLinSobra)
	    //O STRTRAN E USADO PARA EXTRAIR XCONTCPO O JA IMPRESSO
		xContCpo := AllTrim(StrTran(aLinSobra[nX][3], PadR(aLinSobra[nX][3], aLinSobra[nX][4]), ""))
		If Len(xContCpo) > 0
			aAuxCont := R515QbTexto( xContCpo, aLinSobra[nX][4], Space(1) )
			For nZ := 1 TO Len(aAuxCont)
				aAdd(aSobra, { aLinSobra[nX][1]+nZ, aLinSobra[nX][2], aAuxCont[nZ] })
			Next
		EndIf
	Next
EndIf

If Len(aSobra) > 0 
   //coloca em ordem de linha/coluna
   aSobra := ASORT(aSobra,,, { |x, y| x[1] < y[1] .And. x[2] < y[2] })

   For nX := 1 TO Len(aSobra)
		@ aSobra[nX][1], aSobra[nX][2] PSay aSobra[nX][3]
   Next
   li := aSobra[Len(aSobra)][1]
   li++
EndIf

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �R515QbTexto �Autor �Paulo Carnelossi   � Data �  02/09/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Quebra o Texto de acordo com tamnho e separador informado   ���
���          �devolvendo um array com a string quebrada                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R515QbTexto(cTexto, nTamanho, cSeparador)
Local aString := {}, nTamAux := nTamanho
Local nPos, nCtd, nTamOri := Len(cTexto), cAuxTexto

If Len(Trim(cTexto)) > 0

   If Len(Trim(cTexto)) <= nTamanho

      If Len(Trim(cTexto)) > 0
	      aAdd(aString, AllTrim(cTexto) )
      EndIf

   Else
	
		If (nPos := At(cSeparador, cTexto)) != 0
		   
			For nCtd := 1 TO nTamOri STEP nTamAux
		
				cAuxTexto := Subs(cTexto, nCtd, nTamanho)
			
			   If nCtd+nTamanho < nTamOri
				   While Len(Subs(cAuxTexto, Len(cAuxTexto), 1)) > 0 .And. ;
				   				Subs(cAuxTexto, Len(cAuxTexto), 1) <> cSeparador
				   
			   		cAuxTexto := Subs(cAuxTexto, 1, Len(cAuxTexto)-1)
			   		
			      End
			   EndIf
			      
		      If Len(cAuxTexto) > 0
			      cAuxTexto 	:= Subs(cTexto, nCtd, Len(cAuxTexto))
			      nTamAux 		:= Len(cAuxTexto)
		      Else
		      	cAuxTexto := Subs(cTexto, nCtd, nTamanho)
			      nTamAux 		:= nTamanho
		      EndIf
		
		      If Len(Trim(cAuxTexto)) > 0
			      aAdd(aString, Alltrim(cAuxTexto))
		      EndIf
		   Next
		
		Else
		
			For nCtd := 1 TO nTamOri STEP nTamanho
			   If Len(Subs(cTexto, nCtd, nTamanho)) > 0 
			      If Len(Trim(Subs(cTexto, nCtd, nTamanho))) > 0
						aAdd(aString, AllTrim(Subs(cTexto, nCtd, nTamanho)))
					EndIf	
				EndIf	
			Next
		
		EndIf
		
	EndIf
Else
	aAdd(aString, Space(nTamanho))	
EndIf

Return aString

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �05/01/2007���
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
Private aRotina := {	{ STRPL01	,'AxPesqui'	, 0 ,K_Pesquisar 	, 0, .F.},;
                   		{ STRPL02	,'PL515Mov'	, 0 ,K_Visualizar	, 0, Nil},;
             			{ STRPL03		,'PL515Mov'	, 0 ,K_Incluir   	, 0, Nil},;
	      	  			{ STRPL04		,'PL515Mov'	, 0 ,K_Alterar  	, 0, Nil},;
                     	{ STRPL05		,'PL515Mov'	, 0 ,K_Excluir  	, 0, Nil},;
						{ "impRimir"	,'PL515Imp'	, 0 ,K_Alterar 	 	, 0, Nil} }
Return(aRotina)      

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PlsVldBWW �Autor  �Microsiga           � Data �  18/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funca de validacao das datas de vigencia, chamada no       ���
���          � botao de OK da Rotina Cobertura / Co-Participacao.         ���
���          � Tabela - BVF - Familia x Proced x Co-Part  				  ���
�������������������������������������������������������������������������͹��
���Uso       � PLS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function PlsVldBWW()
Local lRet     := .T.
LOCAL aChave   := {}
Local aArea	   := GetArea()      

If BWW->( FieldPos("BWW_FINATE") ) > 0 
	aChave := {'01',M->BWW_TIPO+cValToChar(M->BWW_QTD)+M->BWW_CODTAB+M->BWW_FINATE,'BWW_TIPO+BWW_QTD+BWW_CODTAB+BWW_FINATE'}
Else
	aChave := {'01',M->BWW_TIPO+cValToChar(M->BWW_QTD)+M->BWW_CODTAB,'BWW_TIPO+BWW_QTD+BWW_CODTAB'}
Endif

If  BWW->( FieldPos("BWW_VIGINI") ) > 0 .And. BWW->( FieldPos("BWW_VIGFIN") ) > 0
	cDatDe   := "BWW_VIGINI"
	cDatAte  := "BWW_VIGFIN"

	If !Empty(M->BWW_VIGINI)
		lRet := PLSVLDVIG("BWW",0,oBrwBWW,cDatDe,cDatAte,aChave)
	EndIf
EndIf	

RestArea(aArea)

Return(lRet)   

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSQTDBWW �Autor  �Microsiga           � Data �  08/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida a quantidade quando nao existe data de vigencia     ���
���          � Informada e nao permite quantidade duplicada.              ���
�������������������������������������������������������������������������͹��
���Uso       � PLS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function PLSQTDBWW()
Local lRet := .F. 
Local nX   := 0     
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""   
Local aArea	  := GetArea()  
Local nUsado  := Len(oBrwBWW:aHeader)

nQTD    := Ascan(oBrwBWW:aHeader,{|x| Alltrim(x[2])=="BWW_QTD"})  

If BWW->( FieldPos("BWW_VIGINI") ) > 0 .And. BWW->( FieldPos("BWW_VIGFIN") ) > 0
	nPosIni := Ascan(oBrwBWW:aHeader,{|x| Alltrim(x[2])=="BWW_VIGINI"})
	nPosFin := Ascan(oBrwBWW:aHeader,{|x| Alltrim(x[2])=="BWW_VIGFIN"})
	
	For nX := 1 To Len(oBrwBWW:aCols)
		If !oBrwBWW:aCols[nX][nUsado+1]
			If nX < n
				If M->BWW_VIGINI == CTOD(" / / ") .And. M->BWW_VIGFIN == CTOD(" / / ")
					If M->BWW_QTD == oBrwBWW:aCols[nX][nQTD] .And. Empty(oBrwBWW:aCols[nX][nPosIni]) .And. Empty(oBrwBWW:aCols[nX][nPosFin])
						PLSVLDCOL({"BWW_TIPO","BWW_QTD"})     
						Return lRet := .T.
					Endif
				Endif
			Endif
		Endif
	Next nX 
Else	
	PLSVLDCOL({"BWW_TIPO","BWW_QTD"})     
	Return lRet := .T.
EndIf

RestArea(aArea)

Return lRet                                                                                           