#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC931.CH"

/*/{Protheus.doc} PRAC931
@author   Felipe Machado de Oliveira
@version  P12
@since    31/07/2012
@obs      PRAC931 - 2.2.18 c) Usuarios e perfils de acesso -> Usuarios e perfils de acesso
/*/

Function PRAC931()
	Local oDlg            := nil
	Local aCoors          := FWGetDialogSize(oMainWnd)
	Local oLayer          := nil
	Local oPanelTop       := nil
	Local oPanelBottom    := nil
	Local oTButtonSearch  := nil
	Local oTButSearch2    := nil
	Local oSay            := nil
	Local oSay2           := nil
	Local oColumnT        := nil
	Local oColumnB        := nil
	Local cVarUsuario
	Local cVarCPF
	Local lAtivo          := .T.
	Local aCamposT        := {}
	Local aCamposB        := {}
	Local i               := 0
	Private cUsrNome      := ''
	Private cUserPer      := ''
	private oBrowseTop    := nil
	Private oBrowseBottom := nil
	Private aArrayTop     := {}
	Private aArrayBottom  := {}

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayer := FWLayer():new()
      	oLayer:init(oDlg,.F.)
      	oLayer:addColumn('Col01',100,.F.)
      	oLayer:addWindow('Col01','C1_Win01',STR0001,30,.T.,.F.,,,)
      	oLayer:addWindow('Col01','C1_Win02',STR0002,70,.T.,.F.,,,)

      	oPanelTop    := oLayer:getWinPanel('Col01','C1_Win01')
      	oPanelBottom := oLayer:getWinPanel('Col01','C1_Win02')

      	oTPanelTop  := TPanel():Create(oPanelTop,01,01,"",,,,,,10,15)
		oTPanelTop:Align := 3

		oSay := tSay():New(01,01,{|| ''},oTPanelTop,,,,,,.T.,CLR_RED,CLR_WHITE,40,10)
		oSay:SetText(STR0003)

		cVarUsuario := '                                                  '

		oVarUsuario := TGet():New( 01,22,{|u| if(PCount()>0,cVarUsuario := u,cVarUsuario)},;
		oTPanelTop,70,10,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cVarUsuario,,,,)

		oSay2 := tSay():New(01,95,{|| ''},oTPanelTop,,,,,,.T.,CLR_RED,CLR_WHITE,40,10)
		oSay2:SetText(STR0004)

		cVarCPF := '               '

		oVarCPF := TGet():New( 01,107,{|u| if(PCount()>0,cVarCPF := u,cVarCPF)},;
		oTPanelTop,45,10,'999.999.999-99',,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cVarCPF,,,,)

		oVarCheck := TCheckBox():New(01,157,STR0005,{|u|if( pcount()>0,lAtivo:=u,lAtivo)},oTPanelTop,100,210,,,,,,,,.T.,,,)
		oVarCheck:CtrlRefresh()

		oTButtonSearch := TButton():Create( oTPanelTop,01,187,STR0006,{|| C931LArray(cVarCPF,cVarUsuario,lAtivo,.T.,oLayer)},40,10,,,,.T.,,,,,,)

		oTPanelBottom := TPanel():Create(oPanelTop,01,01,"",,,,,,10,15)
		oTPanelBottom:Align := 4

		oTButSearch2 := TButton():Create( oTPanelBottom,01,01,'Mostra as permissões',{|| C931ShowP(oPanelBottom,oLayer)},60,10,,,,.T.,,,,,,)

		C931LArray('NULL','NULL',.T.,.F.,oLayer)
		C931Field(@aCamposT,@aCamposB)

		oBrowseTop := FWBrowse():New(oPanelTop)
		oBrowseTop:DisableConfig()
		oBrowseTop:DisableReport()
		oBrowseTop:SetDataArray()
		oBrowseTop:SetChange({|| C931SUser(aArrayTop[oBrowseTop:At(),3],aArrayTop[oBrowseTop:At(),2])})
		oBrowseTop:SetArray(aArrayTop)

		oBrowseBottom := FWBrowse():New(oPanelBottom)
		oBrowseBottom:SetDataArray()
		oBrowseBottom:SetArray(aArrayBottom)

		for i := 1 to 6

			oColumnT := FWBrwColumn():New()
			oColumnT:SetData( &(" { || aArrayTop[oBrowseTop:At(),"+STransType(i)+"]}") )
			oColumnT:SetTitle(aCamposT[i][1])
			oColumnT:SetSize(aCamposT[i][2])
			oBrowseTop:SetColumns({oColumnT})

			oColumnB := FWBrwColumn():New()
			oColumnB:SetData( &(" { || aArrayBottom[oBrowseBottom:At(),"+STransType(i)+"]}") )
			oColumnB:SetTitle(aCamposB[i][1])
			oColumnB:SetSize(aCamposB[i][2])
			oBrowseBottom:SetColumns({oColumnB})

		next

		oBrowseTop:Activate()
		oBrowseBottom:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED

return

Static Function C931Field(aCamposT,aCamposB)

	Aadd(aCamposT, {STR0004 , 10})
	Aadd(aCamposT, {STR0003 , 40})
	Aadd(aCamposT, {STR0007 , 15})
	Aadd(aCamposT, {STR0008 ,  5})
	Aadd(aCamposT, {STR0009 , 13})
	Aadd(aCamposT, {STR0010 , 13})

	Aadd(aCamposB, {STR0011 , 20})
	Aadd(aCamposB, {STR0012 , 20})
	Aadd(aCamposB, {STR0013 , 20})
	Aadd(aCamposB, {STR0014 , 20})
	Aadd(aCamposB, {STR0015 , 20})
	Aadd(aCamposB, {STR0016 , 20})

return

Function C931LArray(pUsuId,pUsuNome,pUsuStatus,bUpdate)
	Local cQuery
	Local cAliasQy := SGetNAlias()
	Local cCPF     := ""

	aArrayTop := {}

	if pUsuStatus
		pUsuStatus := 1
	else
		pUsuStatus := 0
	endif

	if Asc(pUsuId) == 32
		pUsuId := 'NULL'
	else
		if pUsuId != 'NULL'
			cCPF   := pUsuId
			pUsuId := SCrtSpec(pUsuId)
			pUsuId := "c"+pUsuId
		endif
	endif

	if Asc(pUsuNome) == 32
		pUsuNome := 'NULL'
	endif

	cQuery := "exec proc_s_usuario_perfil_w '"+pUsuId+"','"+STrim(pUsuNome)+"',"+STransType(pUsuStatus)

	cQuery := StrTran(cQuery,"'NULL'","NULL")

	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasQy,.T.,.F.)
	(cAliasQy)->(DbGotop())
	while (cAliasQy)->(!EOF())
		Aadd(aArrayTop, {(cAliasQy)->(Fieldget(1)), ;
							(cAliasQy)->(Fieldget(2)), ;
							(cAliasQy)->(Fieldget(6)), ;
							(cAliasQy)->(Fieldget(5)), ;
							(cAliasQy)->(Fieldget(3)), ;
							(cAliasQy)->(Fieldget(4))})

		IF !empty((cAliasQy)->(Fieldget(2)))
		   cUsrNome := (cAliasQy)->(Fieldget(2))
		else 
		   cUsrNome := ''
		endif
		(cAliasQy)->(DbSkip())
	EndDo
	(cAliasQy)->(dbCloseArea())

	if bUpdate
		oBrowseTop:SetArray(aArrayTop)
		oBrowseTop:UpdateBrowse()
	endif

return

Function C931SUser(cParam,cParam2)

	cUserPer  := cParam
	cUsrNome := cParam2

return

Function C931ShowP(oPanelBottom,oLayer)
	Local cQuery   := ''
	Local cAliasQy := SGetNAlias()

	aArrayBottom := {}

	oLayer:setWinTitle('Col01','C1_Win02',STR0002+STrim(cUsrNome))

	cQuery := "exec proc_s_permissoes_perfil '"+cUserPer+"'"

	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasQy,.T.,.F.)
	(cAliasQy)->(DbGotop())
	while (cAliasQy)->(!EOF())
		Aadd(aArrayBottom, {(cAliasQy)->(Fieldget(1)), ;
							   (cAliasQy)->(Fieldget(2)), ;
							   (cAliasQy)->(Fieldget(3)), ;
							   (cAliasQy)->(Fieldget(4)), ;
		 					   (cAliasQy)->(Fieldget(5)), ;
							   (cAliasQy)->(Fieldget(6))})
		(cAliasQy)->(DbSkip())
	EndDo
	(cAliasQy)->(dbCloseArea())

	oBrowseBottom:SetArray(aArrayBottom)
	oBrowseBottom:UpdateBrowse()

return