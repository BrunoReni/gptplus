// 浜様様様曜様様様様�
// � Versao � 10     �
// 藩様様様擁様様様様�

#include "VEIXA001.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  27/09/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007368_1"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳堕陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Funcao   � VEIXA001 � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 咳�
臼団陳陳陳陳田陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descricao� Entrada de Veiculos por Compra                                         咳�
臼団陳陳陳陳田陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳調臼
臼�Uso      � Veiculos                                                               咳�
臼青陳陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function VEIXA001()
Local cFiltro     := ""
Local lTIPMOV     := ( VVF->(FieldPos("VVF_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Private cCadastro := STR0001						// Entrada de Veiculos por Compra
Private aRotina   := MenuDef()
Private aCores    := {;
					{'VVF->VVF_SITNFI == "1"','BR_VERDE'},;		// Valida
					{'VVF->VVF_SITNFI == "0"','BR_VERMELHO'},;	// Cancelada
					{'VVF->VVF_SITNFI == "2"','BR_PRETO'}}		// Devolvida
Private cSitVei := " 18" 					// COMPATIBILIDADE COM O SXB - Consulta V11
//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
dbSelectArea("VVF")
dbSetOrder(1)
//
Set Key VK_F12 To VXA001Ativa()
//
cFiltro := " VVF_OPEMOV='0' " // Filtra as Compras
If lTIPMOV
	cFiltro += "AND ( VVF_TIPMOV=' ' OR VVF_TIPMOV='0' ) "
EndIf
//
mBrowse( 6, 1,22,75,"VVF",,,,,,aCores,,,,,,,,cFiltro)

SetKey(VK_F12,Nil)

//
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VXA001_X � Autor � Andre Luis Almeida                � Data � 06/06/14 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Chamada das Funcoes de Inclusao e Visualizacao e Cancelamento          咳�
臼�          � forcando a variavel nOpc                                               咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VXA001_2(cAlias,nReg,nOpc)
VXA001(cAlias,nReg,2)
Return .t.
Function VXA001_3(cAlias,nReg,nOpc)
VXA001(cAlias,nReg,3)
Return .t.
Function VXA001_5(cAlias,nReg,nOpc)
VXA001(cAlias,nReg,5)
Return .t.

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳堕陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Funcao   � VXA001   � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 咳�
臼団陳陳陳陳田陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descricao� Montagem da Janela de Entrada de Veiculos por Compra                   咳�
臼団陳陳陳陳田陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳調臼
臼�Uso      � Veiculos                                                               咳�
臼青陳陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function VXA001(cAlias,nReg,nOpc)
//
DBSelectArea("VVF")
VEIXX000(,,,nOpc,"0")
//
return .t.
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳堕陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Funcao   � MenuDef  � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 咳�
臼団陳陳陳陳田陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descricao� Menu (AROTINA) - Entrada de Veiculos por Compra                        咳�
臼団陳陳陳陳田陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳調臼
臼�Uso      � Veiculos                                                               咳�
臼青陳陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Static Function MenuDef()
Local aRecebe := {}
Local aRotina := {}

aAdd(aRotina,{ STR0002 ,"AxPesqui" 	, 0 , 1}) // Pesquisar
aAdd(aRotina,{ STR0003 ,"VXA001_2"  , 0 , 2}) // Visualizar
aAdd(aRotina,{ STR0004 ,"VXA001_3"  , 0 , 3}) // Incluir
aAdd(aRotina,{ STR0011 ,"VX001BCO"  , 0 , 4}) // Banco de conhecimento
aAdd(aRotina,{ STR0005 ,"VXA001_5"  , 0 , 5}) // Cancelar
aAdd(aRotina,{ STR0006 ,"VXA001LEG"	, 0 , 7}) // Legenda
aAdd(aRotina,{ STR0016 ,"VXA001CAD"	, 0 , 8}) // Cadastrar Ve�culo
If FindFunction("U_IMPXMLV")
	aAdd(aRotina,{ STR0017 , "U_IMPXMLV" , 0 , 3}) // Importar XML
EndIf
If FindFunction("U_IXMLVJD")
	aAdd(aRotina,{ STR0017+" JD" , "U_IXMLVJD" , 0 , 3}) // Importar XML JD
EndIf
aAdd(aRotina,{ STR0007 ,"FGX_PESQBRW('E','0')" , 0 , 2}) // Pesq.Avancada   
If FindFunction("MDeMata103") // Mesmo IF do MATA103

	aRotinaM  := {	{STR0019,"VXA001MNF",0,2,0,nil},;		//"210200 - Confirma艫o da Opera艫o"
					{STR0020,"VXA001MNF",0,2,0,nil}}		//"210210 - Ci�ncia da Opera艫o"

	aAdd(aRotina,{STR0018, aRotinaM, 0 , 2, 0, nil})//"Manifestar" - //DSERTSS1-177 inclusao de um submenu

Endif	

If ExistBlock("VA01AROT")
	aRecebe := ExecBlock("VA01AROT",.f.,.f.,{aRotina} )
	If Valtype(aRecebe) == "A"
		aRotina := aClone(aRecebe)
	Endif
Endif

Return aRotina

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳堕陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Funcao   �VXA001LEG � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 咳�
臼団陳陳陳陳田陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descricao� Legenda - Entrada de Veiculos por Compra                               咳�
臼団陳陳陳陳田陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳調臼
臼�Uso      � Veiculos                                                               咳�
臼青陳陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function VXA001LEG()
Local aLegenda := {;
{'BR_VERDE',STR0008},;		// Valida
{'BR_VERMELHO',STR0009},;	// Cancelada
{'BR_PRETO',STR0010}}		// Devolvida
//
BrwLegenda(cCadastro,STR0006,aLegenda)
//
Return


/*/{Protheus.doc} VXA001MNF
	Chamada da Funcao para Manifestar NFe MATA103

	@author Andre Luis Almeida
	@since 27/09/2017
/*/
Function VXA001MNF(cAlias,nReg,nOpcx)

Local cSFunName := FunName() // Salvar o FUNNAME

DbSelectArea("SF1")
DbSetOrder(1) // F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA
If DbSeek( xFilial("SF1") + VVF->VVF_NUMNFI + VVF->VVF_SERNFI + VVF->VVF_CODFOR + VVF->VVF_LOJA )
	//
	nModulo := 2 // Setar Modulo 2 Compras
	SetFunName("MATA103") // Setar FUNNAME com MATA103
	//
	A103Manif(cAlias,nReg,nOpcx) // Funcao de Manifestar NFe esta dentro do MATA103
	//
	nModulo := 11 // Voltar Modulo 11 Veiculos
	SetFunName(cSFunName) // Voltar o FUNNAME
	//
EndIf
DbSelectArea("VVF")
Return()

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳陳陳娠�
臼|Programa  � VX001BCO | Autor � Thiago	         | Data �  28/10/13   |臼
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳陳陳官�
臼|Descricao � Chamada da funcao Banco de conhecimento.                   |臼
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VX001BCO(cAlias,nReg,nOpc)
FGX_MSDOC(cAlias,nReg,nOpc)
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VXA001Ativa � Autor � Thiago		        � Data � 13.05.14 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Chama a pergunte do mata103                                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function VXA001Ativa()
Pergunte("MTA103",.T.)
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VXA001CAD � Autor � Thiago		        � Data � 18.05.14 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Criacao do veiculo no SB1 e VV1.                           咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VXA001CAD(cAlias,nReg,nOpc)
// 
Local nOpcA := 0
Private cChassi	   := space(TamSX3("VV1_CHASSI")[1])
Private cChassiDig := space(TamSX3("VV1_CHASSI")[1])
Private aCampos    := {}
Private inclui     := .t.
&& Define a tela
DEFINE MSDIALOG oDlgV TITLE STR0012 From 9,0 to 15,64	of oMainWnd    
	
	
@ 008,003 SAY STR0013 OF oDlgV PIXEL COLOR CLR_BLUE   
@ 008,033 MSGET oVeic VAR cChassiDig PICTURE "@!" SIZE 200,4 OF oDlgV PIXEL COLOR CLR_BLUE
	
DEFINE SBUTTON oBtOk     FROM 025,101 TYPE 1 ACTION (nOpcA:=1,oDlgV:End()) ENABLE OF oDlgV
DEFINE SBUTTON oBtCancel FROM 025,141 TYPE 2 ACTION (nOpcA:=2,oDlgV:End()) ENABLE OF oDlgV
		
ACTIVATE MSDIALOG oDlgV CENTER     

if nOpcA == 1                      

	cChassi 	:= cChassiDig 			// preenchimento da variavel de integracao

	// TENTA PROCURAR O CHASSI NO CADASTRO SE ENCONTRAR VERIFICA SE JA NAO ESTA NO
	// ESTOQUE CASO CONTRARIO CADASTRA O VEICULO CHAMANDO A FUNCAO DO VEIVA010
	if !Empty(cChassi) 
		M->VV1_CHASSI := cChassi 			// preenchimento da variavel de integracao
		lAchou := FG_POSVEI("cChassi","VV1->VV1_CHASSI")
		If !lAchou
			cTmpVarObs := ""
			cChassiPre :=  cChassi
			VXA010I("VV1",,3)
		Else
			MSGStop(STR0014)
		EndIf
	Else
		MSGStop(STR0015)
	Endif
Endif
	     
Return
