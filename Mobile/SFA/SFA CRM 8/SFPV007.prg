#INCLUDE "SFPV007.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � Pedido  de Venda 2  �Autor - Cleber M.    � Data �21/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Modulo de Pedidos        					 			  ���
���			 � InitPV2 -> Inicia o Mod. de Pedidos Versao 2	 			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SFA CRM 6.0.1                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�NOperacao 1- Inclusao /2 - Alteracao / 3 - Ult.Pedido(Cons.)���
���			 �4 - Ult.Pedido (Gerar Novo Pedido)   	     		 		  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#include "eADVPL.ch"

Function InitPV2(aCabPed,aItePed,aCond,aTab,aColIte)
Local oDlg,oCab,oFldProd,oObs,oObj,oBrwProd,oPrecos,oPVDesc
Local aObj := { {},{},{},{},{} }
Local aCmpPag:={},aIndPag:={},aCmpTab:={},aIndTab:={},aCmpTra:={},aIndTra:={},aCmpFpg:={},aIndFpg:={}
Local cCliente:="", cManTes :="", cCond := "", cTabPrc := "", cManPrc := "", cTransp := "", cManDte := ""
Local nItePed:=0, nOpIte := 1
Local cSfaInd := "", cBloqPrc := "", cCondInt := "", cProDupl := "", cSfaFpg := "", cSfaFpgIni := ""
Local cFrete := "", cSfaFre := "", aTpFrete := {"CIF", "FOB"}, nOpcFre := If(aCabPed[16,1]="C",1,2)
Local aPrdPrefix := {}, cPsqGrp := ""
Local nPos := 0, oUp,oDown,oLeft,oRight
Local oCol,oBtnTes,oTxtTes,oBtnOK,oBtnExcluir
Local cDesc := "", cCod := "", oGrupo
Local cDescD := ""
Local cUN := "", nQTD := 0, nEnt := 0, nDescMax := 0
Local nICM := 0, nIPI := 0, cEst := space(40), nPrc:=0.00 , oBrw
Local oCtrl, oCtrlPsq, aControls := { {},{},{} }
Local oDet, oCod, oDesc, cPesq := Space(40), lCodigo:=.t., lDesc:=.f.
Local aPrecos := {}, nTop := 0
Local aCmpTes:={},aIndTes:={}
Local cFolderDes	:=	""
#IFNDEF __PALM__
Local oKeyDown, oKeyUp
#ENDIF
// Configura parametros
SetParam(aCabPed[3,1],aCabPed[4,1], cCliente, cCond, cTransp, cFrete, cTabPrc, cManTes, cManPrc, cBloqPrc, cCondInt, cProDupl, cSfaFpg, cSfaFpgIni, aPrdPrefix, cPsqGrp, lCodigo, cManDte)

// Atualiza variavel de pesquisa de produtos
lDesc := !lCodigo

//Prepara/inicia arrays
PVMontaColIte(aColIte)
PVMontaArrays(aCmpPag,aIndPag,aCmpTab,aIndTab,aCmpTra,aIndTra,aCmpFpg,aIndFpg,aCmpTes,aIndTes)
aSize(aProduto,0)

If aCabPed[2,1] = 1 .Or. aCabPed[2,1] = 4
	DEFINE DIALOG oDlg TITLE STR0001 //"Inclus�o"
	//Inicia campos: cond. pagto, tab. de preco e transportadora padrao do cliente (qdo. novo pedido)
	If aCabPed[2,1] = 1
		aCabPed[7,1] := cCond
		aCabPed[8,1] := cTabPrc
		aCabPed[13,1]:= cTransp
		aCabPed[15,1]:= cSfaFpgIni
		aCabPed[16,1]:= cFrete
		nOpcFre      := If(aCabPed[16,1]="C",1,2)
	Endif
ElseIf aCabPed[2,1] = 5
	DEFINE DIALOG oDlg TITLE STR0038 //"Visualizacao"
Else 
	DEFINE DIALOG oDlg TITLE STR0002 //"Altera��o"
EndIf

//Folder Principal (Cabec. do Pedido)
ADD FOLDER oCab CAPTION STR0003 OF oDlg //"Principal"
@ 35,01 TO 139,158 CAPTION STR0003 OF oCab //"Principal"
@ 18,03 GET oObj VAR cCliente SIZE 150,12 READONLY MULTILINE OF oCab
AADD(aObj[1],oObj) // 1 - Label Cliente
@ 125,71 BUTTON oObj CAPTION STR0004  ACTION PVGravarPed(aCabPed,aItePed,aColIte,cCondInt,cSfaInd,cSfaFpg,aObj) SIZE 40,12 OF oCab //"Gravar"
AADD(aObj[1],oObj) // 2 - Botao Gravar
@ 125,116 BUTTON oObj CAPTION STR0005 ACTION PVFecha(aCabPed[2,1],aCabPed) SIZE 40,12 OF oCab //"Cancelar"
AADD(aObj[1],oObj) // 3 - Botao Cancelar
@ 125,2 SAY "T:"  of oCab
#ifdef __PALM__
	@ 125,12 GET oObj VAR aCabPed[12,1] PICTURE "@E 9,999,999.99" READONLY SIZE 52,12 of oCab
	AADD(aObj[1],oObj) // 4 - Label Total
#else
	@ 125,12 GET oObj VAR aCabPed[12,1] PICTURE "@E 9,999,999.99" READONLY SIZE 59,12 of oCab
	AADD(aObj[1],oObj) // 4 - Label Total
#endif

// Condicao de Pagamento
@ 40,42 GET oObj VAR aCabPed[7,1] READONLY SIZE 30,12 of oCab
AADD(aObj[2],oObj) // 1 - Get Condicao
@ 40,03 BUTTON oObj CAPTION STR0006 SIZE 34,10 ACTION PVCond(aCabPed,aObj,aCmpPag,aIndPag,aColIte,aItePed,cCondInt) of oCab  //"Pagto:"
AADD(aObj[2],oObj) // 2 - Labelt Condicao
// Tabela de Preco
@ 40,119 GET oObj VAR aCabPed[8,1] READONLY SIZE 30,12 of oCab
AADD(aObj[2],oObj) // 3 - Get Tabela
@ 40,80 BUTTON oObj CAPTION STR0007 SIZE 34,10 ACTION PVTrocaTab(aCabPed,aObj,aCmpTab,aIndTab,aColIte,aItePed,cCondInt,2) of oCab //"Tabela:"
AADD(aObj[2],oObj)// 4 - Label Tabela

// Data de Entrega
@ 54,42 GET oObj VAR aCabPed[10,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj) // 5 - Get Entrega
If cManDte == "S"
	@ 54,03 BUTTON oObj CAPTION STR0008 SIZE 34,10 ACTION PVDtEntr(aCabPed[10,1],aObj[2,5]) of oCab //"Entrg.:"
Else
	@ 54,03 BUTTON oObj CAPTION STR0008 SIZE 34,10 of oCab //"Entrg.:"
EndIf
AADD(aObj[2],oObj) // 6 - Label Entrega
// Transportadora
@ 68,42 GET oObj VAR aCabPed[13,1] READONLY SIZE 50,12 of oCab
AADD(aObj[2],oObj) // 7 - Get Transportadora
@ 68,03 BUTTON oObj CAPTION STR0009 SIZE 34,10 ACTION PVTrocaTra("HA4",aCmpTra,aIndTra,aCabPed,aObj) of oCab //"Transp:"
AADD(aObj[2],oObj) // 8 - Label Transportadora


// Habilita o folder de descontos de acordo com o conteudo do parametro MV_SFLDDES
dbSelectArea("HCF")
if dbSeek(RetFilial("HCF") + "MV_SFLDDES")
    cFolderDes := Upper(AllTrim(HCF->HCF_VALOR))
Endif
If cFolderDes == "T"
	ADD FOLDER oPVDesc CAPTION STR0037 OF oDlg
	PVFldDesc(@oPVDesc,@aObj,@oObj,@aCabPed,@cCliente)//Chamada de uma funcao para criacao do folder de desconto pois o segmento para o fonte j� estourou
EndIf
If cSfaFpg = "T"
	//Forma de Pagto.
	@ 82,03 BUTTON oObj CAPTION STR0010 SIZE 34,10 ACTION SFConsPadrao("HTP",aCabPed[15,1],aObj[2,10],aCmpFpg,aIndFpg,) of oCab //"F.Pagto"
	AADD(aObj[2],oObj) // 9 - Get F.Pagto
	@ 82,42 GET oObj VAR aCabPed[15,1] SIZE 50,12 of oCab
	AADD(aObj[2],oObj) // 10 - Label F.Pagto
Else
	AADD(aObj[2],"") // 9 - Get F.Pagto
	AADD(aObj[2],"") // 10 - Label F.Pagto
EndIf

If ExistBlock("SFAPV002")
	ExecBlock("SFAPV002", .F., .F., {oCab, aCabPed, oDlg})
EndIf
// Indenizacao
HCF->(dbSetOrder(1))
If HCF->(dbSeek(RetFilial("HCF") + "MV_SFAIND"))
	cSfaInd := AllTrim(HCF->HCF_VALOR)
Else 
	cSfaInd := "F"
EndIf	

If cSfaInd == "T"
	@ 96,03 SAY STR0011 OF oCab //"Inden:"
	AADD(aObj[2],oObj) // 11 - Label Indenizacao
	@ 96,42 GET oObj VAR aCabPed[14,1] VALID ChkIndeni(aCabPed) SIZE 50,12 of oCab
	//VALID (aCabPed[14,1] < aCabPed[11,1])
	AADD(aObj[2],oObj) // 12 - Get Indenizacao
Else
	AADD(aObj[2],"") // 11 - Label Indenizacao
	AADD(aObj[2],"") // 12 - Getl Indenizacao
EndIf

// Tipo de Frete
HCF->(dbSetOrder(1))
If HCF->(dbSeek(RetFilial("HCF") + "MV_SFAFRE"))
	cSfaFre := AllTrim(HCF->HCF_VALOR)
Else 
	cSfaFre := "F"
EndIf	

If cSfaFre == "T"
	@ 110,03 SAY STR0012 OF oCab //"Frete:"
	AADD(aObj[2],oObj)// 13 - Label Frete
	@ 110,30 COMBOBOX oObj VAR nOpcFre ITEMS aTpFrete ACTION UpdTpFrete(aCabPed, aTpFrete, nOpcFre) SIZE 30,40 of oCab
	AADD(aObj[2],oObj) // 14 - Get Frete
Else
	AADD(aObj[2],"")// 13 - Label Frete
	AADD(aObj[2],"") // 14 - Get Frete
EndIf

//Peso do Pedido
If 	cSfaPeso == "T"
	@ 110,80 SAY STR0013 OF oCab //"Peso:"
	AADD(aObj[2],oObj) // 15 - Label Peso
	@ 110,110 GET oObj VAR aCabPed[17,1] PICTURE "@E 999,999.99" READONLY SIZE 49,12 of oCab
	AADD(aObj[2],oObj)// 16 - Get Peso
Else
	AADD(aObj[2],"") // 15 - Label Peso
	AADD(aObj[2],"")// 16 - Get Peso
EndIf


//Folder (Browse de Itens/Produtos)
ADD FOLDER oFldProd CAPTION STR0014 ON ACTIVATE PVFocarBrowse(oBrwProd) OF oDlg //"Itens"
If cPsqGrp = "S"
	@ 18,03 SAY STR0015 OF oFldProd //"Grupo:"
	@ 18,32 COMBOBOX oGrupo VAR nGrupo ITEM aGrupo ACTION PVGrupo(aGrupo,nGrupo,oBrwProd,@nTop,aItePed,.t.,lCodigo,aObj) SIZE 125,50 OF oFldProd
Else
	@ 18,03 SAY "Prod.: " OF oFldProd
	@ 18,27 GET oCtrlPsq VAR cPesq SIZE 60,13 OF oFldProd
	@ 18,89 CHECKBOX oCod VAR lCodigo CAPTION STR0027 ACTION SetFocus(oCtrlPsq) OF oFldProd //"C�digo"
	@ 15,144 BUTTON oCtrl CAPTION BTN_BITMAP_SEARCH SYMBOL ACTION PVFind(cPesq,lCodigo,aGrupo,@nGrupo,aPrdPrefix,oBrwProd,aItePed,@nTop, aObj) OF oFldProd //"Buscar"
EndIf

@ 30,03 BROWSE oBrwProd SIZE 140,60 NO SCROLL ACTION PVSeleciona(oBrwProd,aColIte,aItePed,@nItePed,aCabPed,aObj,cManPrc,cManTes,@nOpIte,aGrupo,nGrupo,@nTop,lCodigo) of oFldProd
SET BROWSE oBrwProd ARRAY aProduto            
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0016 WIDTH 135 //"Descr."
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0017 WIDTH 60 //"Produto"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 3 HEADER STR0018 WIDTH 35 ALIGN RIGHT //"Qtde"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 4 HEADER STR0019 WIDTH 35 ALIGN RIGHT //"Preco"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 5 HEADER STR0020 WIDTH 35 ALIGN RIGHT //"Desc."
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 6 HEADER STR0021 WIDTH 40 ALIGN RIGHT //"Sub Tot."
AADD(aObj[3],oBrwProd) // 1 - Browse de Produtos

@ 32,144 BUTTON oUp CAPTION UP_ARROW SYMBOL SIZE 12,10 ACTION PVSobe(aGrupo,nGrupo,oBrwProd,@nTop,aItePed,lCodigo,aObj) OF oFldProd
@ 47,144 BUTTON oLeft CAPTION LEFT_ARROW SYMBOL SIZE 12,10 ACTION GridLeft(oBrwProd) OF oFldProd
@ 62,144 BUTTON oRight CAPTION RIGHT_ARROW SYMBOL SIZE 12,10 ACTION GridRight(oBrwProd) OF oFldProd
@ 77,144 BUTTON oDown CAPTION DOWN_ARROW SYMBOL  SIZE 12,10 ACTION PVDesce(aGrupo,nGrupo,oBrwProd,@nTop,aItePed,lCodigo,aObj) OF oFldProd

@ 92,03 BUTTON oObj CAPTION STR0022 ACTION PVQTde(aObj[3,3]) SIZE 30,11 of oFldProd //"Qtde."
AADD(aObj[3],oObj) // 2 - Botao Quantidade
@ 92,40 GET oObj VAR aColIte[4,1] SIZE 35,15 of oFldProd
AADD(aObj[3],oObj) // 3 - Get Quantidade

If cBloqPrc == "S"	//Bloqueia campo Preco
	@ 92,080 BUTTON oObj CAPTION STR0023 SIZE 33,11 of oFldProd //"Pre�o"
	AADD(aObj[3],oObj) // 4 - Botao Preco
	@ 92,115 GET oObj VAR aColIte[6,1] PICTURE "@E 9,999.99" READONLY SIZE 40,15 of oFldProd
	AADD(aObj[3],oObj) // 5 - Get Preco
Else
	@ 92,080 BUTTON oObj CAPTION STR0023 ACTION PVPrc(aObj[3,5]) SIZE 33,11 of oFldProd //"Pre�o"
	AADD(aObj[3],oObj) // 4 - Botao Preco
	@ 92,115 GET oObj VAR aColIte[6,1] PICTURE "@E 9,999.99" VALID PVValidaPrc(aObj[3,5],aColIte,aCabPed,cBloqPrc,aObj[3,7],.T.) SIZE 40,15 of oFldProd
	AADD(aObj[3],oObj) // 5 - Get Preco                                                            
Endif
@ 107,03 BUTTON oObj CAPTION STR0024 ACTION PVDesc(aObj[3,7]) SIZE 30,11 of oFldProd //"Desc"
AADD(aObj[3],oObj) // 6 - Botao Desconto
@ 107,40 GET oObj VAR aColIte[7,1] PICTURE "@E 9,999.99" VALID PVCalcDesc(aColIte,aObj,aCabPed,cBloqPrc, 2) SIZE 35,15 of oFldProd
AADD(aObj[3],oObj) // 7 - Get Desconto

If cManTes == "S"	//Permite a manipulacao da TES
	@ 107,080 BUTTON oBtnTes CAPTION STR0025 ACTION SFConsPadrao("HF4",aColIte[8,1],aObj[3,9],aCmpTes,aIndTes,) SIZE 33,11 of oFldProd //"Tes"
	@ 107,115 GET oTxtTes VAR aColIte[8,1] READONLY SIZE 35,15 of oFldProd
	AADD(aObj[3],oBtnTes) // 8 - Botao TES
	AADD(aObj[3],oTxtTes) // 9 - Get TES
	@ 01,075 BUTTON oBtnOK CAPTION "+" SIZE 22,10 ACTION PVGrvIte(aColIte,aItePed, nItePed, aCabPed,aObj,@cManTes,cProDupl,nOpIte,2,@nTop) of oFldProd
	@ 01,125 BUTTON oBtnExcluir CAPTION "-" SIZE 22,10 ACTION PVExcIte(aItePed,@nItePed,aCabPed,aObj,.F.,2) of oFldProd
Else
	AADD(aObj[3],"") // 8 - Botao TES
	AADD(aObj[3],"") // 9 - Get TES
	@ 107,085 BUTTON oBtnOK CAPTION "+" SIZE 22,10 ACTION PVGrvIte(aColIte,aItePed, nItePed, aCabPed,aObj,@cManTes,cProDupl,nOpIte,2,@nTop) of oFldProd
	@ 107,130 BUTTON oBtnExcluir CAPTION "-" SIZE 22,10 ACTION PVExcIte(aItePed,@nItePed,aCabPed,aObj,.F.,2) of oFldProd	
Endif
	
@ 122,3 GET oObj VAR aColIte[2,1] MULTILINE READONLY NO UNDERLINE SIZE 150,22 OF oFldProd
AADD(aObj[3],oObj) // 10 - Get Descricao

PVGrupo(aGrupo,1,oBrwProd,@nTop,aItePed,.f.,lCodigo) //Carrega o 1o. grupo automat.

//Folder (Detalhes do produto)
ADD FOLDER oDet CAPTION STR0026 ON ACTIVATE PVSetDetalhes(oBrwProd,aControls,aCabPed,@cCod,cDescD,cUN,nQTD,nEnt,nICM,nIPI,cEst,nDescMax) Of oDlg //"Detalhe"
PVFldDetalhe(oBrwProd,aItePed,@nTop,oDet,aControls,oCtrl,cCod,cDescD,cUN,nQTD,nEnt,nICM,nIPI,cEst,nDescMax,aPrdPrefix)

//Pesquisa produto
@ 18,3 GET oCtrl VAR cPesq SIZE 150,13 OF oDet
AADD(aControls[3],oCtrl) // 1 - Get Pesquisa
@ 32,3 CHECKBOX oCod VAR lCodigo CAPTION STR0027 ACTION PVOrderFind(aControls,@lCodigo, @lDesc,.t.) OF oDet //"C�digo"
AADD(aControls[3],oCod) // 2 - CheckBox Codigo
@ 32,55 CHECKBOX oDesc VAR lDesc CAPTION STR0028 ACTION PVOrderFind(aControls,@lCodigo, @lDesc ,.f.) OF oDet //"Descri��o"
AADD(aControls[3],oDesc) // 3 - CheckBox Descricao
@ 32,115 BUTTON oCtrl CAPTION STR0029 ACTION PVFind(cPesq,lCodigo,aGrupo,@nGrupo,aPrdPrefix,oBrwProd,aItePed,@nTop,oFldProd, oDlg, aObj) OF oDet //"Buscar"
AADD(aControls[3],oCtrl) // 4- Botao Buscar

//Folder Observacoes
ADD FOLDER oObs CAPTION STR0030 ON ACTIVATE SetFocus(aObj[4,1]) OF oDlg //"Obs"
@ 30,01 TO 127,158 CAPTION STR0031 OF oObs //"Observa��o"
@ 40,05 GET oObj VAR aCabPed[9,1] MULTILINE VSCROLL SIZE 140,80 of oObs
AADD(aObj[4],oObj)

//Folder (Precos de Tabela)
ADD FOLDER oPrecos CAPTION STR0032 ON ACTIVATE PVSetPrecos(aObj,aControls,aPrecos) Of oDlg //"Pre�os"
PVFldPrecos(oPrecos,oCtrl,aControls,oBrw,aPrecos,oCol,nPrc)
If ExistBlock("SFAPV005")
	ExecBlock("SFAPV005", .F., .F., {oDlg, oFldProd, aObj[3], aColIte})
EndIf
// Ponto de Entrada no Final da monstagem da DIALOG do Pedido de Vendas
If ExistBlock("SFAPV007")
	ExecBlock("SFAPV007", .F., .F., {oCab, aCabPed, aObj, oFldProd, aItePed, aPrdPrefix, nTop, oDlg})
EndIf
#IFNDEF __PALM__
SET KEY VK_UP 	TO PvKeyMove(1, aObj, aGrupo,1,oBrwProd,@nTop,aItePed,.f.,lCodigo) IN oBrwProd OBJ oKeyUp
SET KEY VK_DOWN TO PvKeyMove(2, aObj, aGrupo,1,oBrwProd,@nTop,aItePed,.f.,lCodigo) IN oBrwProd OBJ oKeyDown
#ENDIF

PVGrupo(aGrupo,1,oBrwProd,@nTop,aItePed,.f.,lCodigo,aObj) //Carrega o 1o. grupo automat.

If aCabPed[2,1] = 5
	DisableControl(oBtnOK)
	DisableControl(oBtnExcluir)
	HideControl(aObj[1,2])
EndIf

ACTIVATE DIALOG oDlg

Return Nil
