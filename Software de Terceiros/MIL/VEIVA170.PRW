// 浜様様様曜様様様様�
// � Versao � 004    �
// 藩様様様擁様様様様�
#INCLUDE "veiva170.ch"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VEIVA170 � Autor �  Andre                � Data � 22/06/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Cadastro de Indices de Convers�o                           咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVA170

PRIVATE cCadastro := OemToAnsi(STR0001) //"Indices de Convers�o"
PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
mBrowse( 6, 1,22,75,"VVI")

Return

Function Vei170V(cAlias,nReg,nOpc)

CpoVei170()
AxVisual(cAlias,nReg,nOpc,aCampos)

Return


********************************
Function Vei170I(cAlias,nReg,nOpc)

CpoVei170()
AxInclui(cAlias,nReg,nOpc,aCampos)

Return

********************************
Function Vei170A(cAlias,nReg,nOpc)

CpoVei170()
nOpca1 := AxAltera(cAlias,nReg,nOpc,aCampos)

if nOpca1 == 1
   RecLock("VVI",.f.)
   VVI->VVI_DATUSU := dTos(dDataBase) + "-" + __cUserID
   MsUnlock()
Endif

Return

********************
Function CpoVei170()

DbSelectArea("SX3") 
dbSetOrder(1)
dbseek("VVI")
aCampos := {}

Do While !eof() .and. x3_arquivo == "VVI"
	if X3USO(x3_usado).and.cNivel>=x3_nivel
       aadd(aCampos,x3_campo)
    Endif
    dbskip()
Enddo
DbSelectArea("VVI")

Return .T.

Static Function MenuDef()
Local aRotina := {{ OemToAnsi(STR0002) ,"AxPesqui", 0 , 1},;    // Pesquisar
                  { OemToAnsi(STR0003) ,"Vei170V" , 0 , 2},;    // Visualizar
                  { OemToAnsi(STR0004) ,"Vei170I" , 0 , 3},;    // Incluir
                  { OemToAnsi(STR0005) ,"Vei170A" , 0 , 4},;  	// Alterar
                  { OemToAnsi(STR0006) ,"AxDeleta", 0 , 5}}  	// Excluir
Return aRotina
