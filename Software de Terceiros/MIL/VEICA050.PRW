// 浜様様様曜様様様様�
// � Versao � 04     �
// 藩様様様擁様様様様�

#INCLUDE "PROTHEUS.CH"
#INCLUDE "VEICA050.CH"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VEICA050 � Autor � Andre Luis Almeida    � Data � 15/07/13 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Cadastro de Fases da Oportunidade de Negocios              咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEICA050()

Private cCadastro := STR0001 // Fases da Oportunidade de Negocios
Private aCampos := {}
Private aRotina := MenuDef()

DbSelectArea("VDK")
oBrowse:= FWMBrowse():New()
oBrowse:SetAlias('VDK')
oBrowse:SetDescription(cCadastro) //  Etapas do Funil de Venda
oBrowse:DisableDetails()
If VDK->(FieldPos("VDK_TIPFAS")) > 0
	oBrowse:AddLegend( "Empty(VDK_TIPFAS) .or. VDK_TIPFAS == '1'" , "BR_BRANCO"  , STR0017 ) // Veiculos/Maquinas
	oBrowse:AddLegend( "VDK_TIPFAS == '2'"                        , "BR_AMARELO" , STR0018 ) // Pe�as Balc�o
	oBrowse:AddLegend( "VDK_TIPFAS == '3'"                        , "BR_LARANJA" , STR0019 ) // Pe�as/Servi�os Oficina
EndIf
oBrowse:Activate()

Return .T.

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �VA050V    �Autor  �Thiago              � Data �  29/04/14   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Visualiza                                                   艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VA050V(cAlias,nReg,nOpc)

Private cVDK_TIPFAS := VDK->VDK_TIPFAS // Utilizado no F3 do VQT
CAMPO050(nOpc)
AxVisual(cAlias,nReg,nOpc,aCampos)

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �VA050I    �Autor  �Thiago              � Data �  29/04/14   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Incluir                                                     艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VA050I(cAlias,nReg,nOpc)
Local nAviso := Aviso(STR0004,STR0020+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				"1 - "+STR0017+CHR(13)+CHR(10)+;
				"2 - "+STR0018+CHR(13)+CHR(10)+;
				"3 - "+STR0019,;
				{"1","2","3",STR0021},3) // Incluir / Qual tipo de Fase ? / Veiculos/Maquinas / Pecas Balcao / Pecas/Servicos Oficina / Cancelar
Private cVDK_TIPFAS := strzero(nAviso,1) // Utilizado no F3 do VQT
If nAviso > 0 .and. nAviso < 4 // Opcoes Validas
	CAMPO050(nOpc)
	If AxInclui(cAlias,nReg,nOpc,aCampos) == 1 // OK
		RecLock("VDK",.f.)
		VDK->VDK_TIPFAS := cVDK_TIPFAS
		MsUnLock()
	EndIf
EndIf

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �VA050A    �Autor  �Thiago              � Data �  29/04/14   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Alterar                                                     艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VA050A(cAlias,nReg,nOpc)

Private cVDK_TIPFAS := VDK->VDK_TIPFAS // Utilizado no F3 do VQT
CAMPO050(nOpc)
AxAltera(cAlias,nReg,nOpc,aCampos)

// Corrigir o passado - campo em branco //
If Empty(VDK->VDK_TIPFAS)
	RecLock("VDK",.f.)
	VDK->VDK_TIPFAS := "1" // Veiculo/Maquinas - default
	MsUnLock()
EndIf

Return  

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �VA050E    �Autor  �Thiago              � Data �  29/04/14   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Excluir                                                    艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VA050E(cAlias,nReg,nOpc)

Private cVDK_TIPFAS := VDK->VDK_TIPFAS // Utilizado no F3 do VQT
CAMPO050(nOpc)
AxDeleta(cAlias,nReg,nOpc,,aCampos)
 
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �CPOVA050  �Autor  �Thiago              � Data �  29/04/14   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Adiciona campos.                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function CAMPO050(nOpc)
Local cCposDesc := ""
Default nOpc    := 3 // Default INCLUIR

If nOpc == 3 // INCLUIR
	cCposDesc += "VDK_TIPFAS/" // Campos Desconsiderar
EndIf

If cVDK_TIPFAS $ "2/3" // Se Balcao ou Oficina
	cCposDesc += "VDK_FIMFAS/VDK_OBRCLI/VDK_AUTFAS/" // Campos Desconsiderar
EndIf

DbSelectArea("SX3")
DbSetOrder(1)
dbseek("VDK")
aCampos := {}
do While !Eof() .and. x3_arquivo == "VDK"
	If X3USO(x3_usado).And.cNivel>=x3_nivel .and. !( x3_campo $ cCposDesc )
		aadd(aCampos,x3_campo)
	EndIf   
	DbSkip()
EndDo

DbSelectArea("VDK")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VCA050FIM� Autor � Andre Luis Almeida    � Data � 10/10/13 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Valid do campo VDK_FIMFAS - coloca Cliente como obrigatorio咳�
臼�          � e retira Fase Automatica quando nao for Fase Final         咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VCA050FIM()
If M->VDK_FIMFAS == "1" // Fase Final? (1=Sim)
	M->VDK_OBRCLI := "1" // Cliente tem que ser obrigatorio/cadastrado no SA1! (1=Sim)
Else
	M->VDK_AUTFAS := "0" // Nao � Fase Automatica
EndIf
Return .t.

/*/{Protheus.doc} MenuDef()
	MenuDef

	@author Andre Luis Almeida
	@since 10/10/2013
/*/
Static Function MenuDef()
Local aRotina := {	{ STR0002 ,"AxPesqui", 0 , 1},; // Pesquisar
					{ STR0003 ,"VA050V"  , 0 , 2},; // Visualizar
					{ STR0004 ,"VA050I"  , 0 , 3},; // Incluir
					{ STR0005 ,"VA050A"  , 0 , 4},; // Alterar
					{ STR0006 ,"VA050E"  , 0 , 5},; // Excluir
					{ STR0008 ,"VCA050011_FasesAutomaticasRelacionarComStatusAtendimento"  , 0 , 6},; // Status do Atendimento x Fase Autom�tica
					{ STR0007 ,"OFIOA560('031')"  , 0 , 6}}   // Fases de Financiamento
Return aRotina

/*/{Protheus.doc} VCA050011_FasesAutomaticasRelacionarComStatusAtendimento()
	Ajusta a Data de Compra (1a.Compra)

	@author Andre Luis Almeida
	@since 23/10/2018
/*/
Function VCA050011_FasesAutomaticasRelacionarComStatusAtendimento()
Local nCntFor     := 0
Local cQuery      := ""
Local cQAlSQL     := "SQLAUX"
Local aParamBox   := {}
Local aVQL        := {"","","","","","",""}
Local aFasesA     := {""}
Local aFasesX     := {""}
//
Local nRecVQL  := 0
Local nTCodFas := TamSX3("VDK_CODFAS")[1]
cQuery := "SELECT R_E_C_N_O_ "
cQuery += "  FROM "+RetSqlName("VQL")
cQuery += " WHERE VQL_FILIAL = '"+xFilial("VQL")+"'"
cQuery += "   AND VQL_AGROUP = 'DE->PARA'"
cQuery += "   AND VQL_TIPO   = 'ATEND->OPORT'"
cQuery += "   AND VQL_FILORI = '" + xFilial("VDK") + "'"
cQuery += "   AND D_E_L_E_T_=' '"
nRecVQL := FM_SQL(cQuery)
If nRecVQL == 0
	DbSelectArea("VQL")
	RecLock("VQL",.t.)
	VQL->VQL_FILIAL := xFilial('VQL')
	VQL->VQL_CODIGO := GetSxeNum("VQL",'VQL_CODIGO')
	VQL->VQL_AGROUP := 'DE->PARA'
	VQL->VQL_TIPO   := 'ATEND->OPORT'"
	VQL->VQL_DADOS  := "/A="+space(nTCodFas)+; // Status A Atend.Aberto
	                   "/P="+space(nTCodFas)+; // Status P Atend.Pend.Aprova艫o
	                   "/O="+space(nTCodFas)+; // Status O Atend.Pr�-Aprovado
	                   "/L="+space(nTCodFas)+; // Status L Atend.Aprovado
	                   "/R="+space(nTCodFas)+; // Status R Atend.Reprovado
	                   "/F="+space(nTCodFas)+; // Status F Atend.Finalizado
	                   "/C="+space(nTCodFas)   // Status C Atend.Cancelado
	VQL->VQL_FILORI := xFilial("VDK")
	VQL->VQL_DATAI  := dDatabase
	VQL->VQL_HORAI  := VAL(STRTRAN(SUBSTR(TIME(),1,5),":",""))
	VQL->VQL_DATAF  := dDatabase
	VQL->VQL_HORAF  := VAL(STRTRAN(SUBSTR(TIME(),1,5),":",""))
	msunlock()
	ConfirmSx8()
	nRecVQL := VQL->(RecNo())
EndIf
DbSelectArea("VQL")
DbGoto(nRecVQL)
For nCntFor := 1 to 7
	aVQL[nCntFor] := substr(VQL->VQL_DADOS,4+((nTCodFas+3)*(nCntFor-1)),nTCodFas)
Next
//
If VDK->(FieldPos("VDK_AUTFAS")) > 0
	cQuery := "SELECT VDK_CODFAS ,"
	cQuery += "       VDK_DESFAS ,"
	cQuery += "       VDK_AUTFAS  "
	cQuery += "  FROM "+RetSqlName("VDK")
	cQuery += " WHERE VDK_FILIAL = '"+xFilial("VDK")+"'"
	cQuery += "   AND VDK_FIMFAS = '1'"
	cQuery += "   AND VDK_ATIVO  = '1'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	Do While !( cQAlSQL )->( Eof() )
		If ( cQAlSQL )->( VDK_AUTFAS ) <> "1"
			aAdd( aFasesA , ( cQAlSQL )->( VDK_CODFAS )+"="+Alltrim(( cQAlSQL )->( VDK_DESFAS )) )
		Else
			aAdd( aFasesX , ( cQAlSQL )->( VDK_CODFAS )+"="+Alltrim(( cQAlSQL )->( VDK_DESFAS )) )
		EndIf
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("VDK")
EndIf
aAdd(aParamBox,{2,STR0009,aVQL[1],aFasesA,120,"",.f.,""}) // Status A Atend.Aberto
aAdd(aParamBox,{2,STR0010,aVQL[2],aFasesX,120,"",.f.,""}) // Status P Atend.Pend.Aprova艫o
aAdd(aParamBox,{2,STR0011,aVQL[3],aFasesX,120,"",.f.,""}) // Status O Atend.Pr�-Aprovado
aAdd(aParamBox,{2,STR0012,aVQL[4],aFasesX,120,"",.f.,""}) // Status L Atend.Aprovado
aAdd(aParamBox,{2,STR0013,aVQL[5],aFasesX,120,"",.f.,""}) // Status R Atend.Reprovado
aAdd(aParamBox,{2,STR0014,aVQL[6],aFasesX,120,"",.f.,""}) // Status F Atend.Finalizado
aAdd(aParamBox,{2,STR0015,aVQL[7],aFasesX,120,"",.f.,""}) // Status C Atend.Cancelado
cCadastro := ""
If ParamBox(aParamBox,STR0016+" - "+STR0008,@aVQL,,,,,,,,.f.) // Relacionar - Status do Atendimento x Fase Autom�tica
	DbSelectArea("VQL")
	DbGoto(nRecVQL)
	RecLock("VQL",.f.)
		VQL->VQL_DADOS := "/A="+padr(aVQL[1],nTCodFas)+; // Status A Atend.Aberto
		                  "/P="+padr(aVQL[2],nTCodFas)+; // Status P Atend.Pend.Aprova艫o
		                  "/O="+padr(aVQL[3],nTCodFas)+; // Status O Atend.Pr�-Aprovado
		                  "/L="+padr(aVQL[4],nTCodFas)+; // Status L Atend.Aprovado
		                  "/R="+padr(aVQL[5],nTCodFas)+; // Status R Atend.Reprovado
		                  "/F="+padr(aVQL[6],nTCodFas)+; // Status F Atend.Finalizado
		                  "/C="+padr(aVQL[7],nTCodFas)   // Status C Atend.Cancelado
	MsUnLock()
EndIf
cCadastro := STR0001 // Fases da Oportunidade de Negocios
Return

/*/{Protheus.doc} VCA050021_CODETAPA()
	Valida艫o no Codigo da Etapa

	@author Andre Luis Almeida
	@since 07/02/2019
/*/
Function VCA050021_CODETAPA()
Local lRet := .t.
If !Empty(M->VDK_CODETA)
	lRet := .f.
	VQT->(DbSetOrder(1))
	If VQT->(dbseek(xFilial("VQT")+M->VDK_CODETA))
		If Empty(VQT->VQT_TIPETA) .or. VQT->VQT_TIPETA == "1"
			If cVDK_TIPFAS $ " /1"
				lRet := .t.
			EndIf
		ElseIf VQT->VQT_TIPETA == cVDK_TIPFAS
			lRet := .t.
		EndIf
	EndIf
EndIf
Return lRet