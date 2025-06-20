#include "Protheus.ch"
#INCLUDE "VEIVA290.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VEIVA290 � Autor � Manoel                � Data � 03/06/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Acoes de Venda                                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VEIVA290()
nOpc  := 0
nOpcD := 0
Private cAlias := "VZ5"
Private cCadastro := STR0006 // Acoes de Venda
Private aRotina := MenuDef()
Private cTipAva := ""

aCores := {	{'VZ5->VZ5_DATFIN >= dDataBase','BR_VERDE'   },;
			{'VZ5->VZ5_DATFIN <  dDataBase','BR_VERMELHO'}}

dbSelectArea("VZ5")
dbSetOrder(3)

mBrowse( 6, 1,22,75,"VZ5",,,,,,aCores)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FS_Va290  � Autor � Manoel                � Data � 03/06/05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Monta tela da Acao de Venda                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_Va290(nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor  := 0
Local _ni      := 0

Local cGetDNView := "VZ6_CODACV,VZ6_COMPAG,VZ6_TIPORC,VZ6_TIPTIT,VZ6_TIPTEM,VZ6_GRUITE,VZ6_CODITE,VZ6_TIPSER,VZ6_GRUSER,VZ6_CODSER,VZ6_CODSEC,VZ6_DEPINT,VZ6_QTDENT,"

Private oAuxEnchoice
Private oAuxGetDados
Private oAuxDlg
Private aAlter :={}

nOpcD := 0
If nOpc == 6
	nOpcD := 6
	nOpc  := 4
Endif

If nOpc == 5
	Return(VEIVA290EX(nOpc))
EndIf

//��������������������������������������������������������������Ŀ
//� Opcoes de acesso para a Modelo 3                             �
//����������������������������������������������������������������
Do Case
	Case nOpc == 3 && Incluir
		nOpcE:=3
		nOpcG:=3
		Inclui := .t.
		Altera := .f.
	Case nOpc == 4 && Alterar
		nOpcE:=4
		nOpcG:=4
		Inclui := .f.
		Altera := .t.
	Case nOpc == 2 && Visualizar
		nOpcE:=2
		nOpcG:=2
		Inclui := .f.
		Altera := .f.
	Otherwise
		nOpcE:=5
		nOpcG:=5
EndCase

//��������������������������������������������������������������Ŀ
//� Cria variaveis M->????? da Enchoice                          �
//����������������������������������������������������������������
//RegToMemory("VZ5",.T.)
aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VZ5")
While !Eof().and.(x3_arquivo=="VZ5")
	If X3USO(x3_usado).and.x3_nivel>0
		AADD(aCpoEnchoice,x3_campo)
	Endif
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
End

If !(Inclui)
	DbSelectArea("VZ5")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//��������������������������������������������������������������Ŀ
//� Cria aHeader e aCols da GetDados                             �
//����������������������������������������������������������������
nUsado:=0
dbSelectArea("SX3")
dbSeek("VZ6")
aAuxaHeader:={}

While !Eof().And.(x3_arquivo=="VZ6")
	
	If X3USO(x3_usado).And.cNivel>=x3_nivel.and.!( alltrim(x3_campo) $ cGetDNView )
		nUsado := nUsado + 1
		Aadd(aAuxAHeader, {AllTrim(X3Titulo()), SX3->X3_CAMPO , SX3->X3_PICTURE, SX3->X3_TAMANHO ,;
		SX3->X3_DECIMAL , SX3->X3_VALID       , SX3->X3_USADO , SX3->X3_TIPO   , SX3->X3_F3       ,;
		SX3->X3_CONTEXT , X3CBOX()            , SX3->X3_RELACAO })
		
		If SX3->X3_VISUAL <> "V"
			Aadd(aAlter,SX3->X3_CAMPO)
		EndIf
		
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	EndIf
	
	dbSkip()
End

If nOpc == 3
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aAuxaHeader[_ni,2])
	Next
Else
	aCols:={}
	dbSelectArea("VZ6")
	dbSetOrder(1)
	dbSeek(xFilial("VZ6")+M->VZ5_CODACV)
	While !Eof() .and. VZ6->VZ6_FILIAL == xFilial("VZ6") .and. VZ6_CODACV ==  M->VZ5_CODACV
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=If(aAuxaHeader[_ni,10] # "V",FieldGet(FieldPos(aAuxaHeader[_ni,2])),CriaVar(aAuxaHeader[_ni,2]))
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSkip()
	Enddo
	If Len(aCols) == 0
		aCols:={Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For _ni:=1 to nUsado
			aCols[1,_ni]:=CriaVar(aAuxaHeader[_ni,2])
		Next
	Endif
Endif


If Len(aAuxaHeader)>0
	//��������������������������������������������������������������Ŀ
	//� Executa a Modelo 3                                           �
	//����������������������������������������������������������������
	cTitulo       := STR0006 //Acoes de Venda
	nOpcE         := nOpc
	nOpcG         := nOpc
	cAliasEnchoice:="VZ5"
	cAliasGetD    :="VZ6"
	cLinOk        :="AllwaysTrue()"
	cTudOk        :="AllwaysTrue()"
	cFieldOk      :=" VEIVA290VAL('A')"
	aTela      	  := {}
	aGets         := {}
	
	// Boby - 13/04/10
	//              1         2             3             4     5      6         7        8      9   10 11   12  13   14     15      16          17             18     19      20    21 22  23 24 25 26  27
	FM_Mod3(cTitulo,cAliasEnchoice,cAliasGetD,@aCpoEnchoice,,@aAuxaHeader,@aCols,cFieldOk,cLinOk, , ,nOpcE,nOpcG,,oMainWnd,@oAuxDlg,@oAuxEnchoice,@oAuxGetDados,  ,cGetDNView,  ,  ,  ,  ,  ,  ,aAlter)
	
	If nOpcD == 6 // Duplicar
		FS_GrvVa290()
		ACTIVATE MSDIALOG oAuxDlg ON INIT oAuxDlg:End()
		Return
	Endif
	
	oAuxGetDados:oBrowse:bDelete := {|| VEIVA290VAL("D"), oAuxGetDados:oBrowse:Refresh() }
	oAuxGetDados:oBrowse:bChange := {|| FG_MEMVAR(aAuxaHeader,oAuxGetDados:aCols,oAuxGetDados:nAt) }
	
	ACTIVATE MSDIALOG oAuxDlg ON INIT (EnchoiceBar(oAuxDlg, {|| If(VEIVA290OBR(nOpc) .AND. FS_GrvVa290(),oAuxDlg:End(),.f.) },{||oAuxdlg:End()}))
	
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FS_GrvVa290� Autor � Manoel               � Data � 03/06/05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Grava Acao de Venda                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvVa290()

Local i_

lMSHelpAuto := .f.
lMSErroAuto := .f.

Begin Transaction

If nOpcD == 6 // Duplicar
	M->VZ5_CODACV := GetSXENum("VZ5","VZ5_CODACV")
	nOpc := 4
	Altera := .t.
	Inclui := .f.
Endif

DbSelectArea("VZ5")
dbSetOrder(1)
DbSeek(xFilial("VZ5")+M->VZ5_CODACV)
Reclock("VZ5",!Found())
FG_Gravar("VZ5")
MsUnlock()
ConfirmSx8()

DbSelectArea("VZ6")
DbSetOrder(1)

For i_ :=1 to len(oAuxGetDados:aCols)
	
	dbSeek(xFilial("VZ6")+M->VZ5_CODACV+oAuxGetDados:aCols[i_,FG_POSVAR("VZ6_ITECAM","aAuxaHeader")])
	
	if oAuxGetDados:aCols[i_,len(aAuxaHeader)+1]
		If Found()
			Reclock("VZ6",.f.,.t.)
			DbDelete()
			MsUnlock()
			WriteSx2("VZ6")
			Loop
		Endif
	Endif
	
	if !recLock("VZ6",!found())
		Help("  ",1,"REGNLOCK")
		DisarmTransaction()
		Break
	Endif
	FG_GRAVAR("VZ6",oAuxGetDados:aCols,aAuxaHeader,i_)
	VZ6->VZ6_FILIAL := xFilial("VZ6")
	VZ6->VZ6_CODACV := M->VZ5_CODACV
	MsUnlock()
Next

End Transaction

if lMsErroAuto
	MostraErro()
	lMSHelpAuto := .f.
	lMSErroAuto := .f.
	lDeleta := .t.
	Return .f.
Endif

lMsHelpAuto := .f.

Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FS_VERACAO� Autor � Manoel                � Data � 03/06/05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Valida a digitacao do Modelo e do Chassi                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_VERACAO(cPar)

If cPar == "C" // Chassi
	If Empty(M->VZ5_CHASSI)
		return .t.
	Endif
	DbSelectArea("VZ5")
	dbSetOrder(1)
	If DbSeek(xFilial("VZ5")+M->VZ5_CODACV)
		If Empty(VZ5->VZ5_CHASSI)
			MsgInfo(STR0008+CHR(10)+" "+STR0009,STR0007) //Este codigo de Acao de Venda ja foi usado para uma Acao Generica (por Modelo) //-// Nao pode ser utilizada individualmente para um Chassi! / Atencao...
			Return .f.
		Endif
		If VZ5->VZ5_CHASSI != M->VZ5_CHASSI
			MsgInfo(STR0010,STR0007) //Nao e' permitido alterar o Chassi! Crie uma nova Acao de Venda para o Chassi desejado! / Atencao...
			Return .f.
		Endif
	Endif
	DbSelectArea("VV1")
	dbSetOrder(2)
	If DbSeek(xFilial("VV1")+M->VZ5_CHASSI)
		If !(VV1->VV1_SITVEI $ "03")
			MsgInfo(STR0011,STR0007)  //O Chassi informado nao esta no Estoque! / Atencao...
			Return .f.
		Endif
	Else
		MsgInfo(STR0012,STR0007) //Chassi nao encontrado! / Atencao...
		Return .f.
	Endif
ElseIf cPar == "G" // Grupo do Modelo
	DbSelectArea("VZ5")
	dbSetOrder(1)
	If DbSeek(xFilial("VZ5")+M->VZ5_CODACV)
		If VZ5->VZ5_GRUMOD != M->VZ5_GRUMOD
			MsgInfo(STR0015,STR0007) //Nao e' permitido alterar o Grupo do Modelo! Crie uma nova Acao de Venda para o Grupo de Modelo desejado! / Atencao...
			Return .f.
		Endif
	Endif
ElseIf cPar == "M" // Modelo
	DbSelectArea("VZ5")
	dbSetOrder(1)
	If DbSeek(xFilial("VZ5")+M->VZ5_CODACV)
		If VZ5->VZ5_MODVEI != M->VZ5_MODVEI
			MsgInfo(STR0013,STR0007) //Nao e' permitido alterar o Modelo! Crie uma nova Acao de Venda para o Modelo desejado! / Atencao...
			Return .f.
		Endif
	Endif
	If !Empty(M->VZ5_MODVEI)
		If M->VZ5_GRUMOD <> VV2->VV2_GRUMOD
			MsgInfo(STR0017,STR0007) //Modelo do Veiculo nao relacionado ao Grupo de Modelo! / Atencao...
			Return .f.
		EndIf
	EndIf
Endif
Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FS_AATUGRP� Autor � Andre Luis Almeida    � Data � 28/04/09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valid SX3 - VEICULO Atualiza Acoes de venda do veiculo     ���
���          � automaticamente apos funcao FG_POSSB1()                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_AATUGRP()
oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ6_GRUITE","aAuxaHeader")] := M->VZ6_GRUITE := SB1->B1_GRUPO
Return(.t.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_SRVTEM �Autor  �Fabio               � Data �  07/07/00   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se o tipo de servico esta relacionado com o tipo   ���
���          �de tempo.                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_SRVTEM(cTipSer,cTipTem,lMensagem,lTpo)
Default cTipSer   := M->VZ6_TIPSER
Default cTipTem   := M->VZ6_TIPTEM
Default lMensagem := .t.
Default lTpo      := .t.
//
// Retirar a valida��o. Alexandre. Por Luis Delorme
//
return .t.
//
DbSelectArea("VOX")
DbSetOrder(1)
lConsidera := .t.
if VOI->(FieldPos("VOI_CONVOX")) > 0
	VOI->(DbSetOrder(1))
	VOI->(DbSeek( xFilial("VOI") + cTipTem ))
	if VOI->VOI_CONVOX == "0"
		lConsidera := .f.
	endif
endif
If !DbSeek( xFilial("VOX") + cTipSer + cTipTem ) .and. lConsidera
	
	If lMensagem
		Help(1,"  ","TPSERTEM")
	EndIf
	
	Return(.f.)
	
EndIf
Return(.t.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_SERN   �Autor  �Fabio               � Data �  12/28/99   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se o servico esta ativo ou nao.                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_SERN(cCodMar_,cCodSer_,cGruser_)

Private cCodMar:=cCodMar_,cCodSer:=cCodSer_,cGruser:=cGruser_

Default cGruSer_ := M->VZ6_GRUSER

cGruser:=cGruser_
If !FG_Seek("VO6","FG_MARSRV(cCodMar,cCodSer)+cGruSer+cCodSer",3,.f.,"VO4_DESSER","VO6_DESSER")
	If ( !Empty(cGruSer) .Or. !FG_Seek("VO6","FG_MARSRV(cCodMar,cCodSer)+cCodSer",2,.f.,"VO4_DESSER","VO6_DESSER") )
		Return(.f.)
	EndIf
EndIf

If VO6->VO6_SERATI == "0"
	Help(" ",1,"SERINATIVO")
	Return(.f.)
EndIf

Return(.t.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Manoel                � Data � 03/06/05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta aRotina (Menu)                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := { 	{ STR0001 ,"AxPesqui()" , 0 , 1 },;				// Pesquisar
					{ STR0002 ,"FS_VA290(2)", 0 , 2 },;				// Visualizar
					{ STR0003 ,"FS_VA290(3)", 0 , 3 },;		 		// Incluir
					{ STR0004 ,"FS_VA290(4)", 0 , 4 },;				// Alterar
					{ STR0014 ,"FS_VA290(5)", 0 , 5 },;				// Excluir
					{ STR0005 ,"FS_VA290(6)", 0 , 6 },;				// Duplicar
					{ STR0018 ,"VA290LEG"   , 0 , 4 , 2 , .f. }}	// Legenda
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VA290LEG � Autor � Andre Luis Almeida    � Data � 30/03/10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Legenda - VEIVA290                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VA290LEG()
Local aLegenda := {	{'BR_VERDE'   , STR0019 },; // Acao de Venda dentro do periodo
					{'BR_VERMELHO', STR0020 }}  // Acao de Venda fora do periodo
BrwLegenda(cCadastro,STR0018,aLegenda) // Legenda
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �VEIVA290EX� Autor � Andre Luis Almeida    � Data � 21/07/09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida se pode ser feito a exclusao                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VEIVA290EX(nOpc)
Local nReg := VZ5->(RecNo())
Local lRet := .t.
Local aArquivos := {}
Local cAcaoVda := VZ5->VZ5_CODACV
aadd(aArquivos,{"VZ7","VZ7_CODACV",VZ5->VZ5_CODACV,})
If FG_DELETA(aArquivos)
	If AxDeleta("VZ5",nReg,nOpc) == 2
		DbSelectArea("VZ6")
		DbSetOrder(1)
		DbSeek( xFilial("VZ6") + cAcaoVda )
		While VZ6->VZ6_FILIAL == xFilial("VZ6") .and. VZ6->VZ6_CODACV == cAcaoVda
			RecLock("VZ6",.F.)
			Dbdelete()
			WriteSx2("VZ6")
			MsUnlock()
			DbSkip()
		EndDo
	EndIf
EndIf
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao   �VEIVA290VAL� Autor � Andre Luis Almeida    � Data � 21/07/09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao� Valida duplicidade (ITENS DE CAMPANHA) na aCols             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � FNC  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Otavio      �08/09/09�18394 �Implementacao de validacao de duplicidade ���
���			   |		|	   |de pecas digitadas em uma mesma acao de	  ���
���			   |		|	   |vendas.			                          ���
���            �        �      �                                          ���
���            �        �      �                                          ���
���            �        �      �                                          ���
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function VEIVA290VAL(cTip)
Local ni       	:= 0
Local lRet     	:= .t.
Local cCodItem 	:= M->VZ6_ITECAM
If cTip == "A" // Alterar
	For ni := 1 to len(oAuxGetDados:aCols)
		If !oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])] .and. oAuxGetDados:nAt <> ni
			if readVar()== "M->VZ6_ITECAM"
				If oAuxGetDados:aCols[ni,FG_POSVAR("VZ6_ITECAM","aAuxaHeader")] == cCodItem
					lRet := .f.
					MsgStop(STR0016,STR0007) // Item ja digitado! / Atencao...
					Exit
				Endif
			EndIf
		EndIf
	Next
ElseIf cTip == "D" // Deletar
	If oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])]
		oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := .f.
	Else
		oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := .t.
	EndIf
	If !oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])]
		For ni := 1 to len(oAuxGetDados:aCols)
			If !oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])]
				If  oAuxGetDados:aCols[ni,FG_POSVAR("VZ6_ITECAM","aAuxaHeader")] == oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ6_ITECAM","aAuxaHeader")] .and. ni <> oAuxGetDados:nAt
					lRet := .f.
					MsgStop(STR0016,STR0007) // Item ja digitado! / Atencao...
					oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := .t.
					Exit
				EndIf
			EndIf
		Next
	EndIf
EndIf
Return(lRet)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o   �VEIVA290OBR� Autor � Rafael Goncalves       � Data � 21/07/09 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o� VALIDA PERENCHIMENTO DOS CAMPOS OBRIGATORIOS                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function VEIVA290OBR(nOpc)
Local ni := 0
If nOpc==3 .or. nOpc==4 // Inclusao ou alteracao
	For ni:=1 to Len(aCpoEnchoice) // Verifica campos obrigatorios
		If X3Obrigat(aCpoEnchoice[ni]) .and. Empty(&("M->"+aCpoEnchoice[ni]))
			Help(" ",1,"OBRIGAT",,RetTitle(aCpoEnchoice[ni])+space(50),3,0 )
			Return .f.
		EndIf
	Next
EndIf
Return .t.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FS_V290PES� Autor � Rafael Goncalves      � Data �26/10/2009���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para preencher campos automaticamente               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 1-Grupo Modelo / 2-Modelo / 3- Chassi                      ���
�������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � FNC  � Manutencao Efetuada                    ���
�������������������������������������������������������������������������Ĵ��
���              �  /  /  �      �                                        ���
���              �  /  /  �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function FS_V290PES(cTip)
Local cQuery  	:= ""
Local cQuery2  	:= ""
Local cQuery3  	:= ""
Local cQVVR 	:= "SQLVVR"
Local cQVV2 	:= "SQLVV2"
Local cQVV1 	:= "SQLVV1"
If cTip == '1'//Grupo de Modelo - Preenche a Marca automaticamente
	If Empty(M->VZ5_CODMAR)
		cQuery := "SELECT VVR_CODMAR , VVR_DESCRI FROM " + RetSqlName("VVR")+" VVR "
		cQuery += " WHERE VVR_FILIAL='"+xFilial("VVR")+"' AND VVR_GRUMOD= '" + Alltrim(M->VZ5_GRUMOD) + "' AND VVR.D_E_L_E_T_= ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQVVR, .F., .T. )
		If !((cQVVR)->(Eof()))
			M->VZ5_CODMAR := (cQVVR)->(VVR_CODMAR)
			M->VZ5_DESGRU := (cQVVR)->(VVR_DESCRI)
		EndIf
		(cQVVR)->(DbCloseArea())
	EndIF
ElseIf cTip == '2'//Modelo - Preenche Grupo Modelo e Marca automaticamente
	If Empty(M->VZ5_GRUMOD) .or. Empty(M->VZ5_CODMAR)
		cQuery2 := "SELECT VV2_GRUMOD , VV2_DESMOD FROM " + RetSqlName("VV2")+" VV2 "
		cQuery2 += " WHERE VV2_FILIAL='"+xFilial("VV2")+"' AND VV2_MODVEI= '" + Alltrim(M->VZ5_MODVEI) + "' AND VV2.D_E_L_E_T_= ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ), cQVV2, .F., .T. )
		If !((cQVV2)->(Eof()))
			M->VZ5_GRUMOD := (cQVV2)->(VV2_GRUMOD)
			M->VZ5_DESMOD := (cQVV2)->(VV2_DESMOD)
			M->VZ5_CODMAR := ""
		EndIf
		(cQVV2)->(DbCloseArea())
		FS_V290PES("1")//chama a funcao novamente para preencher a marca.
	EndIF
ElseIf cTip == '3'//Chassi - Preenche Modelo, Grupo Modelo e Marca automaticamente
	If Empty(M->VZ5_GRUMOD) .or. Empty(M->VZ5_CODMAR) .or. Empty(M->VZ5_MODVEI)
		cQuery3 := "SELECT VV1_MODVEI , VV1_ESTVEI FROM " + RetSqlName("VV1")+" VV1 "
		cQuery3 += " WHERE VV1_FILIAL='"+xFilial("VV1")+"' AND VV1_CHASSI= '" + Alltrim(M->VZ5_CHASSI) + "' AND VV1.D_E_L_E_T_= ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery3 ), cQVV1, .F., .T. )
		If !((cQVV1)->(Eof()))
			M->VZ5_MODVEI := (cQVV1)->(VV1_MODVEI)
			M->VZ5_ESTVEI := (cQVV1)->(VV1_ESTVEI)
		EndIf
		(cQVV1)->(DbCloseArea())
		FS_V290PES("2")//chama a funcao novamente para preencher o modelo.
	EndIF
EndIf
DbSelectArea("VZ5")
Return .t.


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FM_VEA290 � Autor � Rafael Goncalves      � Data �09/09/2010���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para preencher campos automaticamente               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � descricao e valor                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function FM_VEA290()
Local lRet := .f.
DbSelectArea("VZX")
DbSetOrder(1)
if DbSeek(xFilial("VZX")+M->VZ6_ITECAM)
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ6_DESCAM","aAuxaHeader")] := VZX->VZX_DESCAM
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ6_VALITE","aAuxaHeader")] := VZX->VZX_VALOR
	M->VZ6_DESCAM := VZX->VZX_DESCAM
	M->VZ6_VALITE := VZX->VZX_VALOR
	oAuxGetDados:oBrowse:Refresh()
	lRet := .t.
EndIF
Return(lRet)