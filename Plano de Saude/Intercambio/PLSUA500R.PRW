#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "FWMVCDEF.CH"
 
static cCodInt := ""

function PLSUA500R()
local cGridFilter := ""
local lRet := .T.
private oBrwBTO := nil
cCodInt	:= plsintpad()

//abre a tela de filtro
cGridFilter := PTU500RFIL()
//setKey(VK_F2 ,{|| cGridFilter := PTU500RFIL() })

If !Empty(cGridFilter)

	oBrwBTO := FWMBrowse():New()
	oBrwBTO:SetAlias('BTO')
	oBrwBTO:SetDescription('PTU A500 Reapresenta��o')
	oBrwBTO:SetFilterDefault(cGridFilter)
	oBrwBTO:SetMenuDef("PLSUA500R")
	oBrwBTO:Activate()

Else 

	lRet := .F.

Endif

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author    Thiago Rodrigues
@version   V12
@since     19/08/2022
/*/
Static function ModelDef()
local oModel
local oStrBTO:= FWFormStruct(1,'BTO'  ,{ |cCampo| PLSEXIBTO(cCampo) })// cria as estruturas a serem usadas no modelo de dados

oModel := MPFormModel():New( 'PLSUA500R' , , {||} , , {||} ) // cria o objeto do modelo de dados

oModel:addFields('MasterBTO',/*cOwner*/, oStrBTO)  // adiciona ao modelo um componente de formul�rio

oModel:GetModel('MasterBTO'):SetDescription("PTU A500 Reapresenta��o") // adiciona a descri��o do modelo de dados

// define chave prim�ria do model
oModel:SetPrimaryKey( {"BTO_FILIAL", "BTO_NUMERO", "BTO_REGPRI"} )

Return oModel // Retorna o modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author    Thiago Rodrigues
@version   V12
@since     19/08/2022
/*/
Static function ViewDef()
local oView  // interface de visualiza��o constru�da
local oModel := FWLoadModel( 'PLSUA500R' ) // cria as estruturas a serem usadas na View
local oStrBTO:= FWFormStruct(2, 'BTO' ,{ |cCampo| PLSEXIBTO(cCampo) })

oView := FWFormView():New() // cria o objeto de View

oView:SetModel(oModel)		// define qual Modelo de dados ser� utilizado

oView:AddField('ViewBTO' , oStrBTO,'MasterBTO' ) // adiciona no nosso View um controle do tipo formul�rio

oView:EnableTitleView( 'ViewBTO', 'PTU A500 Reapresenta��o')

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} menuDef
fun��o para criar o menu da tela

@author    Thiago Rodrigues
@version   V12
@since     08/2022
/*/
static function menuDef()
private aRotina := {}

Add Option aRotina Title 'Visualizar'  					Action 'VIEWDEF.PLSUA500R' 	Operation 2 Access 0 // Visualizar
Add Option aRotina Title 'Reapresentar'  				Action 'PTUREAPRE()' 		Operation 4 Access 0 // Reapresentar

return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} PTU500FIL
Filtro

@author    PLS TEAM
@version   V12
@since     19/08/2022
/*/
function PTU500RFIL()

local cFilter 	:= ""
local cTempBTO := getNextAlias()
local cSql := ""
local cRecnoE := ""
Local cRecnoN := ""

cSql := " SELECT R_E_C_N_O_ RECNO, 
cSql += " BTO_NUMERO,"
cSql += " BTO_CHTIT1,"
cSql += " BTO_CHTIT2,"
cSql += " BTO_CHTITF"
cSql += " FROM " + retSqlName("BTO") + " BTO "
cSql += " WHERE BTO_OK = '" + oMBrw:cMark + "'" 
cSql += " AND BTO_FILIAL = '" + xfilial("BTO") + "'"	
cSql += " AND BTO_CODOPE = '" + cCodInt + "'"	
cSql += " AND BTO_STATUS = '1' "	
cSql += " AND BTO_ENV500 = '1' "	
cSql += " AND ( BTO_TPMOV = '2' OR (BTO_TPMOV = '3' AND BTO_TPCOB = '1')) "	

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cTempBTO,.F.,.T.)

If !Empty((cTempBTO)->(RECNO))

	(cTempBTO)->(DBGOTOP())

	While (cTempBTO)->(!eof())

		//Posso reapresentar se tiver alguma das finaliza��es 
		//BTO_CHTIT1 - T�tulo parcial = 1, BTO_CHTIT2 = T�tulo parcial 2,  BTO_CHTITF = T�tulo Fechamento
		If ((cTempBTO)->(BTO_CHTIT1) <> ' ') .OR. ((cTempBTO)->(BTO_CHTIT2) <> ' ') .OR. ((cTempBTO)->(BTO_CHTITF) <> ' ')
			cRecnoE += "'" + CValToChar((cTempBTO)->(RECNO)) + "'," 
		Else
			cRecnoN += CValToChar((cTempBTO)->(BTO_NUMERO)) + "," 
		Endif		

		(cTempBTO)->(dbSkip())

	Enddo

	Do Case

	 	Case Empty(cRecnoE) .AND. !Empty(cRecnoN)

			help(" ",1,"Aten��o",nil,"O(s) lote(s) "+Left(cRecnoN,Len(cRecnoN)-1)+" n�o possui(em) reapresenta��o.",1,0,)

		Case !Empty(cRecnoE) .AND. !Empty(cRecnoN)

			//Informo lotes que n�o possuem reaporesenta��o
			help(" ",1,"Aten��o",nil,"O(s) lote(s) "+Left(cRecnoN,Len(cRecnoN)-1)+" n�o possui(em) reapresenta��o.",1,0,)

			//Sigo com o filtro, pois existe lote para reapresenta��o
			cFilter += "@R_E_C_N_O_ IN ("
			cFilter += Left(cRecnoE,Len(cRecnoE)-1)
			cFilter += " ) "
		
		OtherWise 

			cFilter += "@R_E_C_N_O_ IN ("
			cFilter += Left(cRecnoE,Len(cRecnoE)-1)
			cFilter += " ) "

	EndCase

Else 

	help(" ",1,"Aten��o",nil,"Selecionar ao menos um lote para reapresenta��o.",1,0,)

Endif

return cFilter

/*/{Protheus.doc} PTUREAPRE
	(Clona uma guia para reapresentar no A500)
	@type  Static Function
	@author Thiago 
	@since 19/08/2022
	@see (links_or_references)
/*/
Function PTUREAPRE()
local cAlias  := ""
Local nI      := 1 
local cLotedi := ""
local aGuias  := {}

cLotedi := BTO->BTO_NUMERO

aGuias := PLMARKREA(cLotedi)

if len(aGuias) == 0
	MsgAlert("Nenhuma guia selecionada","Aten��o")
else 
	for nI := 1 to len(aGuias)

		//Verifica o tipo de guia e Posiciona no cabe�alho da guia Original
		BCI->(DbSetOrder(1))
		if BCI->(MsSeek(xfilial("BCI") + Substr(Alltrim(aGuias[nI]),1,16)))
			cAlias = iif(BCI->BCI_TIPGUI =='05','BE4','BD5')
		else
			MsgAlert("PEG: "+ Substr(Alltrim(aGuias[nI]),9,8) +" n�o encontrada","Aten��o")
			loop
		endif

		(cAlias)->(DbSetOrder(1))
		if (cAlias)->(MsSeek(xfilial(cAlias) + Alltrim((cAlias)->(aGuias[nI]))))
			if !empty((cAlias)->&(cAlias+"_GUESTO")) 
				MsgAlert("N�o foi poss�vel realizar o clone pois esta guia j� foi clonada, chave do clone: "+ (cAlias)->&(cAlias+"_GUESTO"),"Aten��o")
				loop
			endif
		else 
			MsgAlert("Cabe�alho da guia n�o encontrado","Aten��o")
			loop
		endif
			
		//Faz o clone da guia e devolve posicionado no BD5/BE4 original
		PLSA500CLO(cAlias,(cAlias)->(RECNO()),,3,nil,.t.)
		
		IF !empty((cAlias)->&(cAlias+"_GUESTO")) //Se o Clone foi conclu�do
			Begin Transaction
				//Cria o BX6 da guia clonada
				PlCriaBX6(cAlias) 

				//ajustes da guia clone 
				PlAjuClone(cAlias)

				//Cria Lote de 'intercambio'  BTF e BTO
				PlCriaLote(cAlias)
			end Transaction	
		endif	

	(cAlias)->(DBCloseArea())
     BCI->(DBCloseArea())
	next			
endif

Return 


/*/{Protheus.doc} PlCriBX6
	 Cria o BX6 da guia clonada 
	@type  Static Function
	@author Thiago Rodrigues
	@since 25/08/2022
	@see (links_or_references)
/*/
Static Function PlCriaBX6(cAlias)
local cSql     :=""
local AliasBX6 := ""
local ObjQuery := FWPreparedStatement():New()

//Busca o BX6 Original, pois sera necess�rio informa��es do ID unico e SEQPTU
cSql = " SELECT BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_SEQUEN,BD6_CODPAD,BD6_CODPRO, "
cSql += " BX6.BX6_IDUNIC,BX6.BX6_SEQPTU "
cSql += " FROM " + retSqlName("BX6") + " BX6 " 
cSql += " INNER JOIN " + retSqlName("BD6") + " BD6 "
cSql += " ON  BD6_FILIAL =  ? "
cSql += " AND BD6_CODOPE = BX6_CODOPE "
cSql += " AND BD6_CODLDP = BX6_CODLDP "
cSql += " AND BD6_CODPEG = BX6_CODPEG "
cSql += " AND BD6_NUMERO = BX6_NUMERO "
cSql += " AND BD6_SEQUEN = BX6_SEQUEN "	
cSql += " AND BD6.D_E_L_E_T_ = ' ' "  
cSql += " WHERE BX6_FILIAL = ? "
cSql += " AND BD6_CODOPE   = ? "
cSql += " AND BD6_CODLDP   = ?"
cSql += " AND BD6_CODPEG   = ? "
cSql += " AND BD6_NUMERO   = ? "
cSql += " AND BX6.D_E_L_E_T_ = ' ' "

ObjQuery:SetQuery(cSql)
ObjQuery:SetString(1, xFilial("BD6"))
ObjQuery:SetString(2, xFilial("BX6"))
ObjQuery:SetString(3, &(cAlias+"->"+cAlias+"_CODOPE"))
ObjQuery:SetString(4, &(cAlias+"->"+cAlias+"_CODLDP"))
ObjQuery:SetString(5, &(cAlias+"->"+cAlias+"_CODPEG"))
ObjQuery:SetString(6, &(cAlias+"->"+cAlias+"_NUMERO"))


cSql := ObjQuery:GetFixQuery()
AliasBX6 := MpSysOpenQuery(cSql)

While !(AliasBX6)->(eof())	
	//Cria o clone do BX6 com os dados da guia original, mudando o: n�mero,codpeg e codldp que devem ser da guia clone	
	BX6->(RecLock("BX6",.t.))
	BX6->BX6_FILIAL := xfilial("BX6")
	BX6->BX6_CODOPE := (AliasBX6)->BD6_CODOPE
	BX6->BX6_CODLDP := Alltrim(SubStr(&(cAlias+"->"+cAlias+"_GUESTO"), 5,4 ))
	BX6->BX6_CODPEG := Alltrim(SubStr(&(cAlias+"->"+cAlias+"_GUESTO"), 9,8 ))
	BX6->BX6_NUMERO := Alltrim(SubStr(&(cAlias+"->"+cAlias+"_GUESTO"), 17,8 ))
	BX6->BX6_ORIMOV := (AliasBX6)->BD6_ORIMOV
	BX6->BX6_SEQUEN := (AliasBX6)->BD6_SEQUEN
	BX6->BX6_CODPAD := (AliasBX6)->BD6_CODPAD
	BX6->BX6_CODPRO := (AliasBX6)->BD6_CODPRO
	BX6->BX6_IDUNIC := (AliasBX6)->BX6_IDUNIC
	BX6->BX6_SEQPTU := (AliasBX6)->BX6_SEQPTU
	BX6->(MsUnLock())
	
	(AliasBX6)->(dbskip())
Enddo

(AliasBX6)->(dbCloseArea())
Return

/*/{Protheus.doc} PlAjuClone
	Realiza ajustes na guia clone
	@type  Static Function
	@author Thiago Rodrigues
	@since 25/08/2022
	@see (links_or_references)
/*/
Static Function PlAjuClone(cAliasCab)
local cAlias   := getNextAlias()
local aAreaC   := (cAliasCab)->(GetArea())
local cCodOpe  := Alltrim(SubStr(&(cAliasCab+"->"+cAliasCab+"_GUESTO"), 1,4))
local cCodLdp  := Alltrim(SubStr(&(cAliasCab+"->"+cAliasCab+"_GUESTO"), 5,4))
local cCodPeg  := Alltrim(SubStr(&(cAliasCab+"->"+cAliasCab+"_GUESTO"), 9,8))
local cNumero  := Alltrim(SubStr(&(cAliasCab+"->"+cAliasCab+"_GUESTO"), 17,8))

//Atualiza cabe�alho
if (cAliasCab)->(MsSeek(xfilial(cAliasCab)+cCodOpe+cCodLdp+cCodPeg+cNumero))
	(cAliasCab)->(RecLock((cAliasCab),.F.))
		&(cAliasCab+"->"+cAliasCab+"_SEQPF") := 'R00001' //Precisa de um SEQPF no BD5 pois alterar a guia replica esse dado do BD5 para o BD6
	(cAliasCab)->(MsUnLock())
endif 
RestArea(aAreaC)

//Atualiza o evento e composi�ao
BeginSQL Alias cAlias
    SELECT R_E_C_N_O_ RECNO
        FROM %Table:BD6%
        WHERE BD6_FILIAL = %XFilial:BD6% 
        AND   BD6_CODOPE = %Exp:cCodOpe% 
        AND   BD6_CODLDP = %Exp:cCodLdp% 
        AND   BD6_CODPEG = %Exp:cCodPeg% 
        AND   BD6_NUMERO = %Exp:cNumero% 
        AND   %NotDel%
EndSQL

//Faz o bloqueio de pagamento do BD6 e BD7
while !(cAlias)->(eof())
	BD6->(DBGoTo((cAlias)->RECNO))

	BD6->(RecLock("BD6",.F.))
		BD6->BD6_CONPAG := '0' //Considera para pagamento ?
		BD6->BD6_CONSOL := '0' //Consolida?
		BD6->BD6_CONCOB := '0' //Considera para cobranca ?
		BD6->BD6_SEQPF  := 'R00001' //Precisa de um SEQPF por conta da estrutura de exporta��o do PTU (tem base no BDH)
		BD6->BD6_VLRMAN :=  0
		BD6->BD6_VLRGLO :=  0
		BD6->BD6_VLRPAG :=  0
		BD6->BD6_VALORI :=  0
		BD6->BD6_VLTXAP :=  0
		BD6->BD6_PRTXPG :=  0
		BD6->BD6_VLTXPG :=  0
		BD6->BD6_VLRGTX :=  0
		BD6->BD6_PEINPT :=  0
		BD6->BD6_VLINPT :=  0
		BD6->BD6_GLINPT :=  0
	BD6->(MsUnLock())

	BD7->(dbSetOrder(1))
	if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
		while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
			xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)

			BD7->(RecLock("BD7",.F.))
				BD7->BD7_CONPAG := '0' //Considera para pagamento ?
				BD7->BD7_CONCOB := '0'
				BD7->BD7_VLRMAN := 0
				BD7->BD7_VLRGLO := 0
				BD7->BD7_VLRPAG := 0
				BD7->BD7_VALORI := 0
				BD7->BD7_VLTXAP := 0
				BD7->BD7_PRTXPG := 0
				BD7->BD7_VLRGTX := 0
				BD7->BD7_PEINPT := 0
				BD7->BD7_VLINPT := 0
				BD7->BD7_GLINPT := 0
			BD7->(MsUnLock())

			BD7->(dbSkip())
		enddo
	endif 

	(cAlias)->(dbSkip())
Enddo

(cAlias)->(DbCloseArea())
return

/*/{Protheus.doc} PLMARKREA
	Monta o Browse para sele��o das guias 
	devolve as guias selecionadas em um array
	@type  Static Function
	@author Thiago Rodrigues
	@since 02/09/2022
	@see (links_or_references)
/*/
Static Function  PLMARKREA(cLote)
Local aCpos		:= {}
Local aCampos	:= {}
local aTam      := {}
local cFiltro   := ""
local cAliasGui := GetNextAlias()
local oTempTab  := nil
local nOpca     := 1
Local bConfirma := {||nOpca := 1, oPrinWnd:oOwner:End()}
Local bCancela  := {||nOpca := 0, oPrinWnd:oOwner:End()}
Local cComandBD := Iif(AllTrim(TCGetDB()) $ "ORACLE|DB2|POSTGRES", "SUBSTR", "SUBSTRING")
local aBotoes   := {}
local aRet      := {}
local cSql      := ""

Private aRotina		:= {}

//Campos da tabela temporaria
aTam := TamSx3("B2A_CHKBD6")
aAdd(aCpos,   {"CHAVEBD6"    	,"C", aTam[1]	, aTam[2]})

aTam := TamSx3("B2A_FILIAL")
aAdd(aCpos,   {"FILIAL"			,"C", aTam[1]	, aTam[2]})
aAdd(aCampos, {"Filial"			,"FILIAL"		,"C","@!",1,aTam[1],aTam[2]})

aTam := TamSx3("BD6_CODPEG")
aAdd(aCpos,   {"PEG"		,"C", aTam[1]	   , aTam[2]})
aAdd(aCampos, {"Cod. PEG"		,"PEG"	   ,"C","@!",1,aTam[1],aTam[2]})

aTam := TamSx3("BD6_NUMERO")
aAdd(aCpos,   {"NUMERO"		,"C", aTam[1]	   , aTam[2]})
aAdd(aCampos, {"Num. Guia"		,"NUMERO"    ,"C","@!",1,aTam[1],aTam[2]})

aTam := {02,00}
aAdd(aCpos,   {"IDMARK"			,"C", aTam[1], aTam[2]})

//Cria��o da tabela tempor�ria
oTempTab := FWTemporaryTable():New( cAliasGui )  
oTempTab:SetFields(aCpos) 
oTempTab:Create()

//Inser��o dos dados na tabela tempor�ria
cSql := " Insert Into " +  oTempTab:getrealName() 
cSql += " (CHAVEBD6, FILIAL, PEG, NUMERO)
cSql += " SELECT DISTINCT "+ cComandBD +"(B2A_CHKBD6,1,24) CHAVEBD6," 
cSql += " B2A_FILIAL FILIAL, " 
cSql +=  cComandBD +"(B2A_CHKBD6,9,8)  PEG, "
cSql +=  cComandBD +"(B2A_CHKBD6,17,8) NUMERO "
cSql +=  " FROM " + Retsqlname("B2A")
cSql +=  " WHERE B2A_LOTE = '" + cLote + "'"
cSql +=  " AND D_E_L_E_T_  = ' '"

PLSCOMMIT(cSql)

//Cria��o da Modal
oPrinWnd := FWDialogModal():New()
oPrinWnd:SetBackground(.t.)
oPrinWnd:SetTitle("Guias do Lote")
oPrinWnd:SetFreeArea(475, 225)
oPrinWnd:EnableFormBar(.t.)
oPrinWnd:SetEscClose(.t.)
oPrinWnd:CreateDialog()

Aadd(aBotoes, {"", "Confirmar", bConfirma, , , .T., .F.}) 
Aadd(aBotoes, {"", "Fechar", bCancela, , , .T., .F.})
oPrinWnd:AddButtons(aBotoes)
oPainel := oPrinWnd:getPanelMain()

oFwCamada := FwLayer():New()
oFwCamada:init(oPainel,.F.)
oFwCamada:AddLine( "LINSUP",100, .F.)
oLINSUP  := oFwCamada:GetLinePanel("LINSUP")

oBrowse:=FWMarkBrowse():NEW()		// Cria o objeto oMark - MarkBrowse
oBrowse:setOwner(oLINSUP)           //Indica o container para cria��o do Browse
oBrowse:SetMenuDef("")              //Indica o programa que ser� utilizado para a carga do menu funcional
oBrowse:SetAlias(cAliasGui)		    // Define a tabela do MarkBrowse
oBrowse:SetDescription("")	        // Define o titulo do MarkBrowse
oBrowse:SetFieldMark("IDMARK")   	// Define o campo utilizado para a marcacao
oBrowse:SetFilterDefault(cFiltro)	// Define o filtro a ser aplicado no MarkBrowse
oBrowse:SetFields(aCampos)		    // Define os campos a serem mostrados no MarkBrowse
oBrowse:SetSemaphore(.F.)			// Define se utiliza marcacao exclusiva
oBrowse:SetWalkThru(.F.)			// Desabilita a opcao de WalkThru
oBrowse:DisableReport()			   // Desabilita a opcao de imprimir
oBrowse:SetAllMark({|| REAMarkAll(oBrowse)})

oBrowse:Activate()
oPrinWnd:Activate()

If nOpca = 1
	cSql:= " SELECT CHAVEBD6 "
	cSql+= " FROM " + oTempTab:getrealName() 
	cSql+= " WHERE IDMARK = '" + oBrowse:cMark + "' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBGUI",.F.,.T.)

	While !TRBGUI->(eof()) 
		Aadd(aRet, TRBGUI->CHAVEBD6)
		TRBGUI->(DbSkip())
	enddo

	TRBGUI->(DbCloseArea())
endif	

Return aRet




//------------------------------------------------------------------------------------------
/*/{Protheus.doc} REAMarkAll
marcar e desmarcar todos da MarkBrowse
Este metodo respeita o controle de semaphoro.
@author Thiago
@since 09/2022
@version P12
/*/
//------------------------------------------------------------------------------------------
function REAMarkAll(oBrowse)
Local lRet		:= .T.                       
Local aAreaTmp	:= (oBrowse:Alias())->(GetArea())	  						

(oBrowse:Alias())->(DbGoTop()) 
While (oBrowse:Alias())->(!Eof())
	oBrowse:MarkRec()
	(oBrowse:Alias())->(DbSkip())
EndDo

RestArea(aAreaTmp)  
oBrowse:Refresh(.t.)

Return lRet


/*/{Protheus.doc} PlCriaLote
	(Cria um lote na BTF e BTO para guia de reapresenta��o)
	@type  Static Function
	@author Thiago Rodrigues
	@since 09/09/2022
	@version version
/*/
Static Function PlCriaLote(cAlias)
Local cNum      := BTF->(GETSX8NUM("BTF","BTF_NUMERO"))
local cCodOpe   := (cAlias)->&(cAlias+"_CODOPE")
local dData     := date()
local cInter    := GetNewPar("MV_PLSGEIN","0050")
local cOpeOri   := BuscaOpOri(cAlias)
local cAliasBCI := getNextAlias()
local aAreaBCI  := BCI->(GetArea())
local cTpMov    := BTO->BTO_TPMOV
local cTpCob    := BTO->BTO_TPCOB

BTF->(DbSetOrder(1))
BTO->(DbSetOrder(1))

if !BTF->(MsSeek(xFilial("BTF")+cCodOpe+cNum))
	BTF->(RecLock("BTF",.T.))
		BTF->BTF_FILIAL := xFilial("BTF")
		BTF->BTF_CODOPE := (cAlias)->&(cAlias+"_CODOPE")
		BTF->BTF_NUMERO := cNum 
		BTF->BTF_DATGER := dData
		BTF->BTF_USUOPE := UsrRetName(RetCodUsr())
		BTF->BTF_HORA   := Time()
		BTF->BTF_ANOINI := substr(Dtos(dDatabase),1,4)
		BTF->BTF_MESINI := SubStr(Dtos(dDataBase),5,2)
		BTF->BTF_VENCTO := LastDate(dData)
		BTF->BTF_TIPCOB := '1'
		BTF->BTF_CODINT := cInter
		BTF->BTF_OPEGER := 1
		BTF->BTF_DTEMIS  := dData
		BTF->BTF_TIPPAC := iif((cAlias) == 'BD5',(cAlias)->&(cAlias+"_TIPPAC"),'1')
	BTF->(MsUnLock())
endif 

if !BTO->(MsSeek(xFilial("BTO")+cCodOpe+cNum)) .and. BTF->(MsSeek(xFilial("BTF")+cCodOpe+cNum))
	BTO->( RecLock("BTO",.T.) )
		BTO->BTO_FILIAL := 	xFilial("BTO")
		BTO->BTO_CODOPE := BTF->BTF_CODOPE
		BTO->BTO_OPEORI := cOpeOri
		BTO->BTO_NUMERO := BTF->BTF_NUMERO
		BTO->BTO_DATGER := BTF->BTF_DATGER
		BTO->BTO_USUOPE := BTF->BTF_USUOPE
		BTO->BTO_HORA   := BTF->BTF_HORA
		BTO->BTO_ANOINI := BTF->BTF_ANOINI
		BTO->BTO_MESINI := BTF->BTF_MESINI
		BTO->BTO_CODINT := BTF->BTF_CODOPE
		BTO->BTO_QTDEVE :=  1
		BTO->BTO_TPCOB  := cTpCob
		BTO->BTO_TPMOV  := cTpMov
		BTO->BTO_REAPRE := "1"
		BTO->BTO_STATUS := "1"
	BTO->(MsUnLock())
endif

BeginSQL Alias cAliasBCI
    SELECT R_E_C_N_O_ RECNO
        FROM %Table:BCI%
        WHERE BCI_FILIAL = %XFilial:BCI% 
        AND   BCI_CODOPE = %Exp:Alltrim(SubStr(&(cAlias+"->"+cAlias+"_GUESTO"), 1,4))% 
        AND   BCI_CODLDP = %Exp:Alltrim(SubStr(&(cAlias+"->"+cAlias+"_GUESTO"), 5,4))% 
        AND   BCI_CODPEG = %Exp:Alltrim(SubStr(&(cAlias+"->"+cAlias+"_GUESTO"), 9,8))% 
        AND   %NotDel%
EndSQL

if !(cAliasBCI)->(eof())
	BCI->(DbGoTo((cAliasBCI)->RECNO))
	BCI->(RecLock("BCI", .F.))
		BCI->BCI_LOTEDI:='BTO|'+ BTF->BTF_NUMERO
	BCI->(MsUnlock())
endif 

BTF->(DbCloseArea())
BTO->(DbCloseArea())
(cAliasBCI)->(DbCloseArea())
RestArea(aAreaBCI)//Reposiciona no BCI da guia original
Return

/*/{Protheus.doc} BusOpeOri
	(Busca Operadora Origem)
	@type  Static Function
	@author Thiago Rodrigues
	@since 12/09/2022
/*/
Static Function BuscaOpOri(cAlias)
local cSql 	   := ""
local AliasBD6 := ""
local ObjQuery := FWPreparedStatement():New()
local cRet     := ""

//Busca do BD6 Original mesmo, pois a operadora origem n�o pode mudar no clone.
cSql = " SELECT BD6_OPEORI "
cSql += " FROM " + retSqlName("BD6") + " BD6 " 
cSql += " WHERE BD6_FILIAL = ? "
cSql += " AND BD6_CODOPE   = ? "
cSql += " AND BD6_CODLDP   = ? "
cSql += " AND BD6_CODPEG   = ? "
cSql += " AND BD6_NUMERO   = ? "
cSql += " AND D_E_L_E_T_   = ' '"

ObjQuery:SetQuery(cSql)
ObjQuery:SetString(1, xFilial("BD6"))
ObjQuery:SetString(2, &(cAlias+"->"+cAlias+"_CODOPE"))
ObjQuery:SetString(3, &(cAlias+"->"+cAlias+"_CODLDP"))
ObjQuery:SetString(4, &(cAlias+"->"+cAlias+"_CODPEG"))
ObjQuery:SetString(5, &(cAlias+"->"+cAlias+"_NUMERO"))

cSql := ObjQuery:GetFixQuery()
AliasBD6 := MpSysOpenQuery(cSql)

if !(AliasBD6)->(eof())
	cRet:=(AliasBD6)->BD6_OPEORI
endif 
Return cRet
