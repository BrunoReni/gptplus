#INCLUDE "CNTA010.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "MSOLE.CH"
#INCLUDE "GCTXDEF.CH"

Static cRetChave := ""

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CNTA010  � Autor � Marcelo Custodio      � Data �22.11.2005���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Manutencao dos tipos de revisoes de contratos              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CNTA010()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CNTA010()
Private cCadastro	:= STR0001 //Tipos de Revisoes de Contrato
Private aRotina 	:= MenuDef()

mBrowse(6,1,22,75,"CN0",,,,,, CoresLegen(1))

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN010Esp  � Autor � Marcelo Custodio      � Data �22.11.2005���
��������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao da especie do contrato                            ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN010Esp()                                                  ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                                                             ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA010                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function CN010Esp()
Local lRet := .T.

Do Case
	Case(M->CN0_TIPO = DEF_REV_ADITI)
		lRet := (M->CN0_ESPEC = "1" .or. M->CN0_ESPEC = "3" .or. M->CN0_ESPEC = "4")
		if(!lRet)
			Help( " ", 1, "CNTA010_03" )
		EndIF
	Case(M->CN0_TIPO = DEF_REV_REAJU)
		lRet := !Empty(M->CN0_RETRO)
		If !lRet
			Help( " ", 1, "CNTA010RETRO" )
		Endif
	Case(M->CN0_TIPO = DEF_REV_REALI)
		lRet := (M->CN0_ESPEC = "2")
		IF(!lRet)
			Help( " ", 1, "CNTA010_04" )
		EndIF
	Case(M->CN0_TIPO = DEF_REV_READE)
		lRet := (M->CN0_ESPEC = "1")
		IF(!lRet)
			Help( " ", 1, "CNTA010_05" )
		EndIF
	Case(M->CN0_TIPO <> DEF_REV_RENOV .And. M->CN0_TIPO <> DEF_REV_ORCGS .And. M->CN0_TIPO <> DEF_REV_ABERT) .AND. M->CN0_ESPEC == "5"
		lRet := .F.
		If(!lRet)
			Help( " ", 1, "CNTA010_07" ) // Tipo de revis�o inv�lida para a esp�cie selecionada. ###Para o Esp�cie 5-Todos, o campo Tipo aceita apenas a op��o: C-Renova��o.
		EndIf
EndCase

If	lRet .And. Empty(M->CN0_MODO) .And.;
	(M->CN0_TIPO == DEF_REV_ADITI .Or. M->CN0_TIPO == DEF_REV_REALI .Or. M->CN0_TIPO == DEF_REV_READE .Or. M->CN0_TIPO == DEF_REV_CONTA .Or. M->CN0_TIPO == DEF_REV_ABERT)
	lRet := .F.
	Aviso( OemToAnsi(STR0001), OemToAnsi(STR0016), { "OK" } )
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN010DEL � Autor � Marcelo Custodio      � Data �22.11.2005���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao da exclusao do tipo de revisao                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN010DEL(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CN010DEL(cAlias,nReg,nOpc)
Local lRet	:= .T.
Local aArea := GetArea()

dbSelectArea("CN9")
dbSetOrder(4) //Tipo de Revisao

//�������������������������������������������������������������������������Ŀ
//�Valida a existencia do registro no cadastro de contratos                 �
//���������������������������������������������������������������������������
If MsSeek(xFilial('CN9')+CN0->CN0_CODIGO, .F.)
	lRet := .F.
	Help( " ", 1, "CNTA010_01" )
EndIf

If lRet
	dbSelectArea("CN0")
	dbgoto(nReg)
	Begin Transaction
		AxDeleta(cAlias,nReg,nOpc)
	End Transaction
Endif

RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN010INC � Autor � Marcelo Custodio      � Data �22.11.2005���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Inclusao do tipo de revisao  				                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN010INC(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CN010INC(cAlias,nReg,nOpc)

AxInclui(cAlias,nReg,nOpc,,,,"CN010Esp()")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN010ALT � Autor � Marcelo Custodio      � Data �22.11.2005���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Alteracao do tipo de revisao 			                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN010ALT(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CN010ALT(cAlias,nReg,nOpc)

AxAltera( cAlias,nReg,nOpc,,,,,"CN010Esp()" )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN010LEG � Autor � Marcos V. Ferreira    � Data �02/03/2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Cria uma janela contendo a legenda da mBrowse              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN010LEG()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CN010lEG()
BrwLegenda(cCadastro,OemToAnsi(STR0007),CoresLegen(2)) //"Legenda"
Return


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �27/10/2006���
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
PRIVATE aRotina	:= { 	{ OemToAnsi(STR0002), "AxPesqui"	, 0, 1, 0, .F.},; 	 //"Pesquisar"
					   	{ OemToAnsi(STR0003), "AxVisual"	, 0, 2, 0, nil},;	 //"Visualizar"
			  	  		{ OemToAnsi(STR0004), "CN010INC"	, 0, 3, 0, nil},; 	 //"Incluir"
			  	  		{ OemToAnsi(STR0005), "CN010ALT"	, 0, 4, 0, nil},; 	 //"Alterar"
		  		  		{ OemToAnsi(STR0006), "CN010DEL"	, 0, 5, 0, nil},; 	 //"Excluir"
		  	  			{ OemToAnsi(STR0007), "CN010LEG"	, 0, 5, 0, .F.}} 	 //"Legenda"

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("CTA010MNU")
	ExecBlock("CTA010MNU",.F.,.F.)
EndIf
Return(aRotina)

//===================================================================================================
/*/{Protheus.doc} Cn010F3Tip()
Constru��o de consulta especifica para tipo de revis�o (CN0_TIPO), que dever� mostrar o tipo
cau��o somente se o parametro MV_CNRVCAU estiver ativo.

@author Israel.Escorizza
@since 13/06/2016
@version P12.1.12
@return lRet
/*/
//===================================================================================================
Function Cn010F3Tip()
Local lRet 		:= .F.
Local aArea		:= GetArea()
Local aSaveLines	:= FwSaveRows()

Local lRevCauc	:= SuperGetMV("MV_CNRVCAU",.F.,.F.)
Local cAliasX5	:= GetNextAlias()
Local cQuery		:= ""

Local oBrowse		:= NIL
Local oDlgTela	:= NIL
Local oView		:= NIL

Local aIndex		:= {"X5_CHAVE"}
Local aSeek 		:= {{"Chave", {{"Chave","C",TamSX3("X5_CHAVE")[1],0,"",,}} }}

cQuery +=	" SELECT "
cQuery +=	" X5_CHAVE, X5_DESCRI "
cQuery += 	" FROM "+RetSqlName('SX5')+" "
cQuery += 	" WHERE "
cQuery += 	" X5_FILIAL = '"+xFilial('SX5')+"' "
cQuery += 	" AND "
cQuery += 	" X5_TABELA = 'GC' "
If !lRevCauc
	cQuery +=	" AND "
	cQuery +=	" X5_CHAVE <> 'E' "
EndIf
cQuery	+=	" ORDER BY X5_CHAVE "

DEFINE MSDIALOG oDlgTela TITLE STR0001 FROM 0,0 TO 460,800 PIXEL

oBrowse := FWFormBrowse():New()
oBrowse:SetAlias(cAliasX5)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cQuery)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({|| cRetChave := (oBrowse:Alias())->X5_CHAVE, lRet := .T., oDlgTela:End()})

oBrowse:AddButton( OemTOAnsi(STR0034), {|| cRetChave  := (oBrowse:Alias())->X5_CHAVE, lRet := .T., oDlgTela:End() } ,, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0035), {|| cRetChave  := "", oDlgTela:End() } ,, 2 ) //"Cancelar"
oBrowse:DisableDetails()

oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek({||.T.},aSeek)

ADD COLUMN oColumn DATA {|| X5_CHAVE 	} TITLE OemTOAnsi(STR0036)	SIZE TamSX3('X5_CHAVE')[1]  OF oBrowse //"Chave"
ADD COLUMN oColumn DATA {|| X5_DESCRI	} TITLE OemTOAnsi(STR0037) 	SIZE TamSX3('X5_DESCRI')[1] OF oBrowse //"Descri��o"

oBrowse:Activate()
ACTIVATE MSDIALOG oDlgTela CENTERED

FWRestRows(aSaveLines)
RestArea(aArea)
Return lRet

//===================================================================================================
/*/{Protheus.doc} C010RetTip()
Retorno da consulta especifica Cn010F3Tip.

@author Israel.Escorizza
@since 13/06/2016
@version P12.1.12
@return lRet
/*/
//===================================================================================================
Function C010RetTip()
Return cRetChave

//-------------------------------------------------------------------
/*/{Protheus.doc} A010VldEsp()
Valid do campo Esp�cie (CN0_ESPEC)
@author israel.escorizza
@since 24/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function A010VldEsp()
Local lRet := .T.
//1=Quantidade;2=Preco;3=Prazo;4=Quant/Prazo;5=Todos
If  M->CN0_TIPO == "1" .AND. !(M->CN0_ESPEC $ "1|3|4")
	lRet = .F.
	Help(" ",1,"A010VLDESP")//"Especie invalida para o tipo de revis�o selecionado."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A010SetEsp()
When do campo Esp�cie (CN0_ESPEC)
@author israel.escorizza
@since 24/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function A010SetEsp()
Local lRet  := .F.
Local nTipo := M->CN0_TIPO

DO CASE
   CASE nTipo == DEF_REV_ADITI //-Aditivo;
   		 If Empty(M->CN0_ESPEC)
   		 	M->CN0_ESPEC	:= "1"
   		 EndIf
   		 lRet 	:= .T.

   CASE nTipo == DEF_REV_REALI //- Realinhamento (Pre�o)
   		 M->CN0_ESPEC := "2"
   		 lRet	:= .F.

   CASE nTipo == DEF_REV_READE //- Readequa��o (Quantidade)
   		 M->CN0_ESPEC := "1"
   		 lRet	:= .F.

   CASE nTipo == DEF_REV_RENOV //- Renova��o (Todos)
   	   	 M->CN0_ESPEC := "5"
   		 lRet	:= .F.

  	CASE nTipo == DEF_REV_ORCGS	//- Or�amento de Servi�os (Todos)
   	   	 M->CN0_ESPEC := "5"
   		 lRet	:= .F.
   
   	CASE nTipo == DEF_REV_ABERT //- Aberta (Todos)
   		 M->CN0_ESPEC := "5"
   		 lRet  := .F.
ENDCASE

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A010RetrW()

Fun��o When do campo Retroativo

@author alexandre.gimenez
@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A010RetrW()

Local lRet:= .F.

If M->CN0_TIPO $ "2*3*G"
	lRet := .T.
Else
	M->CN0_RETRO := ""
Endif

Return lRet

/*/{Protheus.doc} CoresLegen
	Retorna um array com as cores, descri��o e condicao das legendas
@author philipe.pompeu
@since 22/10/2020
@return aCores, vetor, lista com as cores
/*/
Static Function CoresLegen(nTipo as numeric) as Array
	Local aCores	:= {}
	Local bConv		:= Nil		
	Default nTipo	:= 1

	aCores := {  {	'CN0_TIPO=="1"', 'BR_VERDE'		,STR0008	},;//Aditivo
				 {	'CN0_TIPO=="2"', 'BR_VERMELHO'	,STR0009	},;//Reajuste
				 {	'CN0_TIPO=="3"', 'BR_AZUL'		,STR0010  	},;//Realinhamento
				 {	'CN0_TIPO=="4"', 'BR_LARANJA'	,STR0011	},;//Readequacao
				 {	'CN0_TIPO=="5"', 'BR_MARROM'	,STR0012 	},;//Paralisacao
				 {	'CN0_TIPO=="6"', 'BR_PRETO'		,STR0013 	},;//Reinicio
				 {	'CN0_TIPO=="7"', 'BR_PINK'		,STR0014   	},;//Alteracao de Clausulas
				 {	'CN0_TIPO=="8"', 'BR_AMARELO'	,STR0015	},;//Alteracao Cronograma cont�bil
				 {	'CN0_TIPO=="9"', 'BR_AZUL_CLARO',STR0017	},;//Indice
				 {	'CN0_TIPO=="A"', 'BR_BRANCO'	,STR0018    },;//Fornecedor
				 {	'CN0_TIPO=="B"', 'BR_CINZA'		,STR0032	},;//Grupos de Aprova��o
				 {	'CN0_TIPO=="C"', 'BR_VIOLETA'	,STR0031	},;//Renova��o
				 {	'CN0_TIPO=="G"', 'BR_PRETO_0'	,STR0040	},;//Aberta
				 {	'CN0_TIPO=="F"', 'BR_CANCEL'	,STR0039	},;//'Or�amento de Servi�os
				 {	'CN0_TIPO=="D"', 'BR_VERDE_ESCURO',STR0033	},;//Multa/Bonifica��o
				 {	'CN0_TIPO=="E"', 'BR_MARRON_OCEAN',STR0038	}}//Cau��o
	
	If nTipo == 1
		bConv := {|x| aSize(x,2) }
	Else
		bConv := {|x| aDel(x, 1), aSize(x,2) }
	EndIf
	aEval(aCores, bConv)
Return aCores
