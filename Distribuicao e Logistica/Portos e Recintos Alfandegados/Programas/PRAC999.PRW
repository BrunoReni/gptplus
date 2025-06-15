#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"

Function PRAC999
	Local oDlg
	Local oPanelFiltro
	Local oPanelBottom
	Local oList
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local aItems := {}
	Local nList := 1
	Local oTButtonAbrir
	Local oTButtonSair

	Aadd(aItems,'1.1 Entrada/Saída de pessoas')
	Aadd(aItems,'1.2 Entrada/Saída de veículos de carga')
	Aadd(aItems,'1.3 Entrada/Saída de lote de carga')
	Aadd(aItems,'1.4 Relação de notas fiscais - RNF')
	Aadd(aItems,'1.5 Armazenagem de carga não desunitizada')
	Aadd(aItems,'1.6 Desunitização de carga')
	Aadd(aItems,'1.7 Unitização de carga')
	Aadd(aItems,'1.8 Consolidação/Desconsolidação de lote de carga')
	Aadd(aItems,'1.9 Transferencia de local de armazenamento')
	Aadd(aItems,'1.10 Mudança de situação aduaneira de lote de carga')
	Aadd(aItems,'1.10A Situação de lote de carga para verificação física')
	Aadd(aItems,'1.11 Relação de transferencia de mercadoria - RTM')
	Aadd(aItems,'1.20 Registro de mudança de regime aduaneiro')
	Aadd(aItems,'1.23 Registro de avarias')

	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,500 PIXEL

		oPanelBottom  := TPanel():Create(oDlg,01,01,"",,,,,,10,15)
		oPanelBottom:Align := 4 //CONTROL_ALIGN_BOTTOM

		oPanelAllClient  := TPanel():Create(oDlg,01,102,"",,,,,,100,100)
		oPanelAllClient:Align := 5 //CONTROL_ALIGN_ALLCLIENT

		oList:= tListBox():New(10,10,{|u|if(Pcount()>0,nList:=u,nList)} ,aItems,100,100,,oPanelAllClient,,,,.T.,,{||C999ABRIR(nList)})
		oList:Align := 5 //CONTROL_ALIGN_ALLCLIENT

		oTButtonAbrir := TButton():Create( oPanelBottom,01,01,"Abrir",{||C999ABRIR(nList)},40,10,,,,.T.,,,,,,)
		oTButtonSair  := TButton():Create( oPanelBottom,01,42,"Sair" ,{||oDlg:end()}      ,40,10,,,,.T.,,,,,,)

	ACTIVATE MSDIALOG oDlg CENTERED

	oList := nil
	aItems := nil
Return

Static function C999ABRIR(nList)
	DO CASE
		CASE nList == 1
			PRAC907()
		CASE nList == 2
			PRAC908()
		CASE nList == 3
			PRAC909()
		CASE nList == 4
			PRAC910()
		CASE nList == 5
			PRAC911()
		CASE nList == 6
			PRAC912()
		CASE nList == 7
			PRAC913()
		CASE nList == 8
			PRAC914()
		CASE nList == 9
			PRAC915()
		CASE nList == 10
			PRAC916()
		CASE nList == 11
			PRAC917()
		CASE nList == 12
			PRAC918()
		CASE nList == 13
			PRAC941()
		CASE nList == 14
			PRAC919()
	ENDCASE
return .T.