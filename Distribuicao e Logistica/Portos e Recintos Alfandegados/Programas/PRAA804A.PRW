#INCLUDE "PRAC809.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

Function PRAA804A(cCodViagem) 
	Local cQuery
	Local cAliasTmp := GetNextAlias()
	Private lAlterou := .F.
	Private lLiberado
	Private dData
	Private cHora
	Private cViagem :=cCodViagem
	Private cSituacao := ''
	
	cQuery := " select CONVERT(VARCHAR, vf_dt_liberacao ,103) data_dt_liberacao, CONVERT(VARCHAR, vf_dt_liberacao ,108) hora_dt_liberacao from tab_viagem_ferroviaria where vf_id = '" + cViagem + "'"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasTmp, .F., .T.)
   if alltrim((cAliasTmp)->data_dt_liberacao) <> ''
   		dData := ctod(alltrim((cAliasTmp)->data_dt_liberacao))
		cHora := substr(alltrim((cAliasTmp)->hora_dt_liberacao),1,5)
   		lLiberado := .T.
   	else
   		dData := date()
		cHora := substr(time(),1,5)
		lLiberado := .F.
   endif
   (cAliasTmp)->(dbCloseArea())
	//-------------------------------------------------------------------
	// Define a janela do Browse
	//-------------------------------------------------------------------
	DEFINE MSDIALOG oDlgLib Title STR0001 FROM 0,0 TO 175,320 PIXEL
	
	oLayer := FWLayer():new()
	oLayer:Init(oDlgLib,.F.)
	
	oLayer:addLine('LinhaSuperior',100,.F.,)
	
	oLayer:addColumn('ColSuperior',100,.F.,'LinhaSuperior')
	
	oLayer:addWindow('ColSuperior','C1_Win01',"Liberação da viagem ferroviária " + cViagem  ,100,.F.,.F.,,'LinhaSuperior',)
	
	oTopGrid2   := oLayer:getwinpanel('ColSuperior','C1_Win01','LinhaSuperior')
	
	oFont := TFont():New('Arial',,15,.T.)	
	oSay1 := TSay():Create(oTopGrid2,{||STR0003},4 ,0,,oFont,,,,.T.,CLR_BLACK,CLR_RED,50,50)
	
	@ 2,20 MSGET oData VAR dData PICTURE "@D" SIZE 45, 10 OF oTopGrid2 PIXEL HASBUTTON

	
	oSay2 := TSay():Create(oTopGrid2,{||STR0004},25 ,0,,oFont,,,,.T.,CLR_BLACK,CLR_RED,50,50)
      
	@ 23,20 MSGET oData VAR cHora PICTURE "@E 99:99" SIZE 15, 10 OF oTopGrid2 PIXEL HASBUTTON
	
	oTButtonOK     := TButton():Create(  oLayer:getColPanel('ColSuperior','LinhaSuperior'),65,5,'Liberar'     ,{||A804AOK()},40,10,,,,.T.,,,,{||!lLiberado},,)
	oTButtonEST    := TButton():Create(  oLayer:getColPanel('ColSuperior','LinhaSuperior'),65,55,'Estornar' ,{||A804AEST()},40,10,,,,.T.,,,,{||lLiberado},,)
	oTButtonSAIR    := TButton():Create(  oLayer:getColPanel('ColSuperior','LinhaSuperior'),65,105,'Sair'  ,{||oDlgLib:End()},40,10,,,,.T.,,,,,,)
	//oTButtonCancel := TButton():Create(  oLayer:getColPanel('ColSuperior','LinhaSuperior'),65,155,'Fechar'  ,{||A809CAN()},40,10,,,,.T.,,,,,,)
	
	ACTIVATE MSDIALOG oDlgLib CENTERED
	
Return {lAlterou,dData,cHora,cSituacao}

Static Function A804AOK()
	Local cHoraAlterado := ''
	Local cData
	Local cQuery
	
	cData := dtoc(dData)
	cHoraAlterado := strtran(substring(cHora,1,5),':','')
	
	if alltrim(cData) = '/  /'
		alert(STR0007)		
	elseif  alltrim(cHoraAlterado) = ':'
		alert(STR0008)
	elseif  len(alltrim(cHoraAlterado)) != 4 
		alert(STR0009)
	elseif (val(alltrim(cHoraAlterado)) > 2459)  .or. (val(alltrim(cHoraAlterado)) < 0)
		alert(STR0009)
	else
		cQuery := " update tab_viagem_ferroviaria set vf_situacao = 'L', vf_dt_liberacao = '" + SDBDate(dData,alltrim(cHora) )+ "' where vf_id = '" + cViagem + "'"
		cSituacao := 'L'
		TCSqlexec(cQuery)
		lLiberado := .T.
		lAlterou := .T.
		MsgInfo("A viagem foi liberada com sucesso.")
		oDlgLib:End()
	endif
Return

static function A804AEST()
	Local cQuery := ''
	
	cQuery := " update tab_viagem_ferroviaria set vf_dt_liberacao = null, vf_situacao = 'R' where vf_id = '" + cViagem + "'"
	cSituacao := 'R'
	TCSqlexec(cQuery)
	
	cHora := '  :  '
	dData := ctod('  /  /    ')
	
	lLiberado := .F.
	lAlterou := .T.
	MsgInfo("A viagem foi estornada com sucesso.")
	oDlgLib:End()
	
return