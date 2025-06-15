#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC936.CH"

/*/{Protheus.doc} PRAC936
@author   Marcio Franklin Carvalho de Noronha
@version  P12
@since    27/07/2012
@obs      DAC
/*/

Function PRAC936()
	Local oDlg       := nil                       //Janela
	Local aFields    := {}                        //Campos de pesquisa
	Local oPanel     := nil                       //Painel
	Local oLayer     := nil                       //Layout
	Local aFilParser := {}                        //Configuração dos filtros
	Local aCoors     := FWGetDialogSize(oMainWnd) //Coordenada da janela
	Local oBrowse    := nil                       //GRID

	Private cAliasTb := ''                        //Tabela temporária
	Private nColSize := 0                         //Quantidade de registros
	Private nTipoDoc := '-1'
	Private aStructDesc
	Private aStruct
	Private cCli := ''
	Private cNrDac := ''

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayer := FWLayer():new() //Cria uma camada na janela
		oLayer:init(oDlg,.F.)
		oLayer:addColumn('Col01',100,.F.) //Adiciona uma coluna na camada
		oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,) //Adiciona um componente de windows na camada e coluna

		oPanel  := oLayer:getWinPanel('Col01','C1_Win01') //Recupera o objeto do Window

		//Adiciona no array os campos de filtro da tela
						         //Campo, Descricao   , Tipo, Tamanho, Alias, Mascara            , Nil, Zoom            , Validacao                          , ValorPadrao
		/* 03 */ Aadd(aFields, {"P1"  , STR0002     , "C" , 30     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 06 */ Aadd(aFields, {"P2"  , STR0014     , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 09 */ Aadd(aFields, {"P3"  , STR0015     , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})

		/* 12 */ Aadd(aFields, {"P4"  , STR0003     , "C" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 15 */ Aadd(aFields, {"P5"  , STR0014     , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 18 */ Aadd(aFields, {"P6"  , STR0015     , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})

		/* 21 */ Aadd(aFields, {"P7"  , STR0004     , "C" , 30     , nil  , ""                 , nil, ""              ,nil                                , nil})
		/* 24 */ Aadd(aFields, {"P8"  , STR0016     , "C" , 20     , nil  , ""                 , nil, "C936ZOOMP(o, 1)", {|xConteud, o| C936VLCDA(xConteud, o)}   , nil})

		/* 27 */ Aadd(aFields, {"P9"  , STR0005     , "C" , 40     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 30 */ Aadd(aFields, {"P10"  ,STR0016     , "C" , 20     , nil  , ""                 , nil, "C936ZOOMP(o, 1)", {|xConteud, o| C936VLCDA(xConteud, o)}   , nil})

		/* 33 */ Aadd(aFields, {"P11"  , STR0006    , "C" , 40     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 36 */ Aadd(aFields, {"P12"  , STR0014    , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 39 */ Aadd(aFields, {"P13"  , STR0015    , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})

		/* 42 */ Aadd(aFields, {"P14"  , STR0007    , "C" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 45 */ Aadd(aFields, {"P15"  , STR0013    , "C" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 48 */ Aadd(aFields, {"P16"  , STR0014    , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 51 */ Aadd(aFields, {"P17"  , STR0015    , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 54 */ Aadd(aFields, {"P18"  , STR0017    , "C" , 5     , nil  , ""                  , nil, ""              , nil                               , nil})
		/* 57 */ Aadd(aFields, {"P19"  , STR0018    , "C" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})

		/* 60 */ Aadd(aFields, {"P20"  , STR0008    , "C" , 40     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 63 */ Aadd(aFields, {"P21"  , STR0019    , "C" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})

		/* 66 */ Aadd(aFields, {"P22"  , STR0009    , "C" , 40     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 69 */ Aadd(aFields, {"P23"  , STR0016    , "C" , 20     , nil  , ""                 , nil, "C936ZOOMP(o, 1)", {|xConteud, o| C936VLCDA(xConteud, o)}   , nil})

		/* 72 */ Aadd(aFields, {"P24"  , STR0010    , "C" , 30     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 75 */ Aadd(aFields, {"P25"  , STR0014    , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 78 */ Aadd(aFields, {"P26"  , STR0015    , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})

		/* 81 */ Aadd(aFields, {"P27"  , STR0011    , "C" , 40     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 84 */ Aadd(aFields, {"P28"  , STR0019    , "C" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})

		/* 87 */ Aadd(aFields, {"P29"  , STR0012    , "C" , 40     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 90 */ Aadd(aFields, {"P30"  , STR0013    , "C" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 93 */ Aadd(aFields, {"P31"  , STR0014    , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 96 */ Aadd(aFields, {"P32"  , STR0015    , "D" , 20     , nil  , ""                 , nil, ""              , nil                               , nil})
		/* 99 */ Aadd(aFields, {"P33"  , STR0020    , "C" , 20     , nil  , ""                 , nil, "C936ZOOMP(o, 3)", nil                               , nil})
		/*102 */ Aadd(aFields, {"P34"  , STR0021    , "C" , 20     , nil  , ""                 , nil, "C936ZOOMP(o, 2)", {|xConteud, o| C936VLCLI(xConteud, o)}   , nil})

		/*105 */ Aadd(aFields, {"P35"  , "Opcao"    , "C" , 1      , nil  , ""                 , nil, nil             , nil                               , nil})

		CAliasTb := SCTBTMPG()

		//Cria um componente de browse no window
		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","NULL",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","NULL",@aFilParser)
		SAddFilPar("P23","==","NULL",@aFilParser)
		SAddFilPar("P24","==","NULL",@aFilParser)
		SAddFilPar("P25","==","NULL",@aFilParser)
		SAddFilPar("P26","==","NULL",@aFilParser)
		SAddFilPar("P27","==","NULL",@aFilParser)
		SAddFilPar("P28","==","NULL",@aFilParser)
		SAddFilPar("P29","==","NULL",@aFilParser)
		SAddFilPar("P30","==","NULL",@aFilParser)
		SAddFilPar("P31","==","NULL",@aFilParser)
		SAddFilPar("P32","==","NULL",@aFilParser)
		SAddFilPar("P33","==","NULL",@aFilParser)
		SAddFilPar("P34","==","NULL",@aFilParser)
		SAddFilPar("P35","==","1"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0002, "P1==NULL .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22==NULL .AND. P23==NULL .AND. P24==NULL .AND. P25==NULL .AND. P26==NULL .AND. P27==NULL .AND. P28==NULL .AND. P29==NULL .AND. P30==NULL .AND. P31==NULL .AND. P32==NULL .AND. P33==NULL .AND. P34==NULL .AND. P35=='1'", .F., .F.,nil,.T., aFilParser, '1')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","%P5%",@aFilParser)
		SAddFilPar("P6","==","%P6%",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","NULL",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","NULL",@aFilParser)
		SAddFilPar("P23","==","NULL",@aFilParser)
		SAddFilPar("P24","==","NULL",@aFilParser)
		SAddFilPar("P25","==","NULL",@aFilParser)
		SAddFilPar("P26","==","NULL",@aFilParser)
		SAddFilPar("P27","==","NULL",@aFilParser)
		SAddFilPar("P28","==","NULL",@aFilParser)
		SAddFilPar("P29","==","NULL",@aFilParser)
		SAddFilPar("P30","==","NULL",@aFilParser)
		SAddFilPar("P31","==","NULL",@aFilParser)
		SAddFilPar("P32","==","NULL",@aFilParser)
		SAddFilPar("P33","==","NULL",@aFilParser)
		SAddFilPar("P34","==","NULL",@aFilParser)
		SAddFilPar("P35","==","2"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0003, "P1==NULL .AND. P2=='NULL' .AND. P3=='NULL' .AND. P4==NULL .AND. P5=='%P5%' .AND. P6=='%P6%' .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22==NULL .AND. P23==NULL .AND. P24==NULL .AND. P25==NULL .AND. P26==NULL .AND. P27==NULL .AND. P28==NULL .AND. P29==NULL .AND. P30==NULL .AND. P31==NULL .AND. P32==NULL .AND. P33==NULL .AND. P34==NULL .AND. P35=='2'", .F., .F.,nil,.T., aFilParser, '2')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","%P8%",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","NULL",@aFilParser)
		SAddFilPar("P23","==","NULL",@aFilParser)
		SAddFilPar("P24","==","NULL",@aFilParser)
		SAddFilPar("P25","==","NULL",@aFilParser)
		SAddFilPar("P26","==","NULL",@aFilParser)
		SAddFilPar("P27","==","NULL",@aFilParser)
		SAddFilPar("P28","==","NULL",@aFilParser)
		SAddFilPar("P29","==","NULL",@aFilParser)
		SAddFilPar("P30","==","NULL",@aFilParser)
		SAddFilPar("P31","==","NULL",@aFilParser)
		SAddFilPar("P32","==","NULL",@aFilParser)
		SAddFilPar("P33","==","NULL",@aFilParser)
		SAddFilPar("P34","==","NULL",@aFilParser)
		SAddFilPar("P35","==","3"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0004 , "P1==NULL .AND. P2=='NULL' .AND. P3=='NULL' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8=='%P8%' .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22==NULL .AND. P23==NULL .AND. P24==NULL .AND. P25==NULL .AND. P26==NULL .AND. P27==NULL .AND. P28==NULL .AND. P29==NULL .AND. P30==NULL .AND. P31==NULL .AND. P32==NULL .AND. P33==NULL .AND. P34==NULL .AND. P35=='3'", .F., .F.,nil,.T., aFilParser, '3')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","NULL",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		SAddFilPar("P10","==","%P10%",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","NULL",@aFilParser)
		SAddFilPar("P23","==","NULL",@aFilParser)
		SAddFilPar("P24","==","NULL",@aFilParser)
		SAddFilPar("P25","==","NULL",@aFilParser)
		SAddFilPar("P26","==","NULL",@aFilParser)
		SAddFilPar("P27","==","NULL",@aFilParser)
		SAddFilPar("P28","==","NULL",@aFilParser)
		SAddFilPar("P29","==","NULL",@aFilParser)
		SAddFilPar("P30","==","NULL",@aFilParser)
		SAddFilPar("P31","==","NULL",@aFilParser)
		SAddFilPar("P32","==","NULL",@aFilParser)
		SAddFilPar("P33","==","NULL",@aFilParser)
		SAddFilPar("P34","==","NULL",@aFilParser)
		SAddFilPar("P35","==","4"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0005, "P1==NULL .AND. P2=='NULL' .AND. P3=='NULL' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10=='%P10%' .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22==NULL .AND. P23==NULL .AND. P24==NULL .AND. P25==NULL .AND. P26==NULL .AND. P27==NULL .AND. P28==NULL .AND. P29==NULL .AND. P30==NULL .AND. P31==NULL .AND. P32==NULL .AND. P33==NULL .AND. P34==NULL .AND. P35=='4'", .F., .F.,nil,.T., aFilParser, '4')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","NULL",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","%P12%",@aFilParser)
		SAddFilPar("P13","==","%P13%",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","NULL",@aFilParser)
		SAddFilPar("P23","==","NULL",@aFilParser)
		SAddFilPar("P24","==","NULL",@aFilParser)
		SAddFilPar("P25","==","NULL",@aFilParser)
		SAddFilPar("P26","==","NULL",@aFilParser)
		SAddFilPar("P27","==","NULL",@aFilParser)
		SAddFilPar("P28","==","NULL",@aFilParser)
		SAddFilPar("P29","==","NULL",@aFilParser)
		SAddFilPar("P30","==","NULL",@aFilParser)
		SAddFilPar("P31","==","NULL",@aFilParser)
		SAddFilPar("P32","==","NULL",@aFilParser)
		SAddFilPar("P33","==","NULL",@aFilParser)
		SAddFilPar("P34","==","NULL",@aFilParser)
		SAddFilPar("P35","==","5"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0006, "P1==NULL .AND. P2=='NULL' .AND. P3=='NULL' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12=='%P12%' .AND. P13=='%P13%' .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22==NULL .AND. P23==NULL .AND. P24==NULL .AND. P25==NULL .AND. P26==NULL .AND. P27==NULL .AND. P28==NULL .AND. P29==NULL .AND. P30==NULL .AND. P31==NULL .AND. P32==NULL .AND. P33==NULL .AND. P34==NULL .AND. P35=='5'", .F., .F.,nil,.T., aFilParser, '5')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","NULL",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","%P16%",@aFilParser)
		SAddFilPar("P17","==","%P17%",@aFilParser)
		SAddFilPar("P18","==","%P18%",@aFilParser)
		SAddFilPar("P19","==","%P19%",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","NULL",@aFilParser)
		SAddFilPar("P23","==","NULL",@aFilParser)
		SAddFilPar("P24","==","NULL",@aFilParser)
		SAddFilPar("P25","==","NULL",@aFilParser)
		SAddFilPar("P26","==","NULL",@aFilParser)
		SAddFilPar("P27","==","NULL",@aFilParser)
		SAddFilPar("P28","==","NULL",@aFilParser)
		SAddFilPar("P29","==","NULL",@aFilParser)
		SAddFilPar("P30","==","NULL",@aFilParser)
		SAddFilPar("P31","==","NULL",@aFilParser)
		SAddFilPar("P32","==","NULL",@aFilParser)
		SAddFilPar("P33","==","NULL",@aFilParser)
		SAddFilPar("P34","==","NULL",@aFilParser)
		SAddFilPar("P35","==","6"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0007, "P1==NULL .AND. P2=='NULL' .AND. P3=='NULL' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16=='%P16%' .AND. P17=='%P17%' .AND. P18=='%P18%' .AND. P19=='%P19%' .AND. P20==NULL .AND. P21==NULL .AND. P22==NULL .AND. P23==NULL .AND. P24==NULL .AND. P25==NULL .AND. P26==NULL .AND. P27==NULL .AND. P28==NULL .AND. P29==NULL .AND. P30==NULL .AND. P31==NULL .AND. P32==NULL .AND. P33==NULL .AND. P34==NULL .AND. P35=='6'", .F., .F.,nil,.T., aFilParser, '6')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","NULL",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","NULL",@aFilParser)
		SAddFilPar("P23","==","NULL",@aFilParser)
		SAddFilPar("P24","==","NULL",@aFilParser)
		SAddFilPar("P25","==","NULL",@aFilParser)
		SAddFilPar("P26","==","NULL",@aFilParser)
		SAddFilPar("P27","==","NULL",@aFilParser)
		SAddFilPar("P28","==","NULL",@aFilParser)
		SAddFilPar("P29","==","NULL",@aFilParser)
		SAddFilPar("P30","==","NULL",@aFilParser)
		SAddFilPar("P31","==","NULL",@aFilParser)
		SAddFilPar("P32","==","NULL",@aFilParser)
		SAddFilPar("P33","==","NULL",@aFilParser)
		SAddFilPar("P34","==","NULL",@aFilParser)
		SAddFilPar("P35","==","7"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0008, "P1==NULL .AND. P2=='NULL' .AND. P3=='NULL' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22==NULL .AND. P23==NULL .AND. P24==NULL .AND. P25==NULL .AND. P26==NULL .AND. P27==NULL .AND. P28==NULL .AND. P29==NULL .AND. P30==NULL .AND. P31==NULL .AND. P32==NULL .AND. P33==NULL .AND. P34==NULL .AND. P35=='7'", .F., .F.,nil,.T., aFilParser, '7')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","NULL",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","NULL",@aFilParser)
		SAddFilPar("P23","==","%P23%",@aFilParser)
		SAddFilPar("P24","==","NULL",@aFilParser)
		SAddFilPar("P25","==","NULL",@aFilParser)
		SAddFilPar("P26","==","NULL",@aFilParser)
		SAddFilPar("P27","==","NULL",@aFilParser)
		SAddFilPar("P28","==","NULL",@aFilParser)
		SAddFilPar("P29","==","NULL",@aFilParser)
		SAddFilPar("P30","==","NULL",@aFilParser)
		SAddFilPar("P31","==","NULL",@aFilParser)
		SAddFilPar("P32","==","NULL",@aFilParser)
		SAddFilPar("P33","==","NULL",@aFilParser)
		SAddFilPar("P34","==","NULL",@aFilParser)
		SAddFilPar("P35","==","8"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0009, "P1==NULL .AND. P2=='NULL' .AND. P3=='NULL' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22==NULL .AND. P23=='%P23%' .AND. P24==NULL .AND. P25==NULL .AND. P26==NULL .AND. P27==NULL .AND. P28==NULL .AND. P29==NULL .AND. P30==NULL .AND. P31==NULL .AND. P32==NULL .AND. P33==NULL .AND. P34==NULL .AND. P35=='8'", .F., .F.,nil,.T., aFilParser, '8')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","NULL",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","NULL",@aFilParser)
		SAddFilPar("P23","==","NULL",@aFilParser)
		SAddFilPar("P24","==","NULL",@aFilParser)
		SAddFilPar("P25","==","%P25%",@aFilParser)
		SAddFilPar("P26","==","%P26%",@aFilParser)
		SAddFilPar("P27","==","NULL",@aFilParser)
		SAddFilPar("P28","==","NULL",@aFilParser)
		SAddFilPar("P29","==","NULL",@aFilParser)
		SAddFilPar("P30","==","NULL",@aFilParser)
		SAddFilPar("P31","==","NULL",@aFilParser)
		SAddFilPar("P32","==","NULL",@aFilParser)
		SAddFilPar("P33","==","NULL",@aFilParser)
		SAddFilPar("P34","==","NULL",@aFilParser)
		SAddFilPar("P35","==","9"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0010, "P1==NULL .AND. P2=='NULL' .AND. P3=='NULL' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22==NULL .AND. P23==NULL .AND. P24==NULL .AND. P25=='%P25%' .AND. P26=='%P26%' .AND. P27==NULL .AND. P28==NULL .AND. P29==NULL .AND. P30==NULL .AND. P31==NULL .AND. P32==NULL .AND. P33==NULL .AND. P34==NULL .AND. P35=='9'", .F., .F.,nil,.T., aFilParser, '9')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","NULL",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","NULL",@aFilParser)
		SAddFilPar("P23","==","NULL",@aFilParser)
		SAddFilPar("P24","==","NULL",@aFilParser)
		SAddFilPar("P25","==","NULL",@aFilParser)
		SAddFilPar("P26","==","NULL",@aFilParser)
		SAddFilPar("P27","==","NULL",@aFilParser)
		SAddFilPar("P28","==","NULL",@aFilParser)
		SAddFilPar("P29","==","NULL",@aFilParser)
		SAddFilPar("P30","==","NULL",@aFilParser)
		SAddFilPar("P31","==","NULL",@aFilParser)
		SAddFilPar("P32","==","NULL",@aFilParser)
		SAddFilPar("P33","==","NULL",@aFilParser)
		SAddFilPar("P34","==","NULL",@aFilParser)
		SAddFilPar("P35","==","10"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0011, "P1==NULL .AND. P2=='NULL' .AND. P3=='NULL' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22==NULL .AND. P23==NULL .AND. P24==NULL .AND. P25==NULL .AND. P26==NULL .AND. P27==NULL .AND. P28==NULL .AND. P29==NULL .AND. P30==NULL .AND. P31==NULL .AND. P32==NULL .AND. P33==NULL .AND. P34==NULL .AND. P35=='10'", .F., .F.,nil,.T., aFilParser, '10')

		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","NULL",@aFilParser)
		SAddFilPar("P8","==","NULL",@aFilParser)
		SAddFilPar("P9","==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","NULL",@aFilParser)
		SAddFilPar("P23","==","NULL",@aFilParser)
		SAddFilPar("P24","==","NULL",@aFilParser)
		SAddFilPar("P25","==","NULL",@aFilParser)
		SAddFilPar("P26","==","NULL",@aFilParser)
		SAddFilPar("P27","==","NULL",@aFilParser)
		SAddFilPar("P28","==","NULL",@aFilParser)
		SAddFilPar("P29","==","NULL",@aFilParser)
		SAddFilPar("P30","==","NULL",@aFilParser)
		SAddFilPar("P31","==","%P31%",@aFilParser)
		SAddFilPar("P32","==","%P32%",@aFilParser)
		SAddFilPar("P33","==","%P33%",@aFilParser)
		SAddFilPar("P34","==","%P34%",@aFilParser)
		SAddFilPar("P35","==","11"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0012, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22==NULL .AND. P23==NULL .AND. P24==NULL .AND. P25==NULL .AND. P26==NULL .AND. P27==NULL .AND. P28==NULL .AND. P29==NULL .AND. P30==NULL .AND. P31=='%P31%' .AND. P32=='%P32%' .AND. P33=='%P33%' .AND. P34=='%P34%' .AND. P35=='11'", .F., .F.,nil,.T., aFilParser, '11')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
		oBrowse:oFWFilter:SetExecute({||C936FILTER(oBrowse)})
		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)
Return

Static Function C936FILTER(oBrowse)
	Local cQuery      := "proc_rfb_pesq_dac_w "
	Local cParams     := ""
	Local nMax        := 0
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cRet := ''
	Local cCampo := ''

	if !SVALFILTRO(oFilter)
		alert(STR0074)
		return
	endif

	aFilter := oFilter:GetFilter(.T.)

	if (!C936GF(aFilter, @cParams, @cMsg))
		if (!SEmpty(cMsg))
			alert(cMsg)
		endif
		return
	endif

	cQuery += " " + cParams

	TcSqlExec(cQuery)
	TcRefresh(cAliasTb) 

	(cAliasTb)->(dbCloseArea())
	DbUseArea(.T.,'TOPCONN',cAliasTb,cAliasTb,.T.,.F.)

	nColSize := Len(oBrowse:aColumns)

	for nI := 1 to nColSize
		oBrowse:DelColumn(nI)
	next
	nColSize := Len(aStruct)

	for nI := 1 to nColSize
		oColumn := nil

		cCampo := STransType(aStruct[nI][1])
		cCampo := "{|| "+cCampo+"}"

		oColumn := FWBrwColumn():New()
		oColumn:SetData(  &(cCampo) )
		oColumn:SetTitle( aStructDesc[nI][1]   )
		oColumn:SetSize(  aStructDesc[nI][2]   )

		oBrowse:SetColumns({oColumn})
	next

	oBrowse:updateBrowse()

Return .T.

static function C936GF(aFilter, cParams, cMsg)
	Local i := 1
	Local cOpcao := '0'
	Local cCampo1
	Local cCampo2
	Local cCampo3
	Local cCampo4

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cParams := ""
	cOpcao := STransType(aFilter[i][4][105][1])
	cParams += cOpcao+","
	
	cPessoa := STrim(aFilter[i][4][99][1])

    C936CTB(cOpcao)

	if cOpcao == "1" //Entrada de Mercadorias
	    cCampo1 := STrim(aFilter[i][4][6][1])
	    cCampo2 := STrim(aFilter[i][4][9][1])

		if SEmpty(cCampo1) .OR. STransType(cCampo1) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if SEmpty(cCampo2) .OR. STransType(cCampo2) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if cCampo1 > cCampo2
		    cMsg := STR0077
		    return .F.
	    endif

		cParams += "'"+SDBDate(cCampo1,'00:00:00')+"',"
		cParams += "'"+SDBDate(cCampo2,'23:59:59')+"',"
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL"
	elseif cOpcao == "2" //Saída de Mercadorias
	   cCampo1 := STrim(aFilter[i][4][15][1])
	   cCampo2 := STrim(aFilter[i][4][18][1])

		if SEmpty(cCampo1) .OR. STransType(cCampo1) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if SEmpty(cCampo2) .OR. STransType(cCampo2) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if cCampo1 > cCampo2
		    cMsg := STR0077
		    return .F.
	    endif

		cParams += "'"+SDBDate(cCampo1,'00:00:00')+"',"
		cParams += "'"+SDBDate(cCampo2,'23:59:59')+"',"
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL"
	elseif cOpcao == "3" //Eventos por CDA
	   cCampo1 := STrim(cNrDac)

		if SEmpty(cCampo1)
		    cMsg := STR0075
		    return .F.
	    endif

		cParams += "NULL,NULL,NULL,NULL,'"+cCampo1+"',NULL,NULL,NULL,NULL"
	elseif cOpcao == "4" //Localização de Mercadorias
	   cCampo1 := STrim(cNrDac)

		if SEmpty(cCampo1)
		    cMsg := STR0075
		    return .F.
	    endif

		cParams += "NULL,NULL,NULL,NULL,'"+cCampo1+"',NULL,NULL,NULL,NULL"
	elseif cOpcao == "5" //Mercadorias submetidas ao regime
	   cCampo1 := STrim(aFilter[i][4][36][1])
	   cCampo2 := STrim(aFilter[i][4][39][1])

		if SEmpty(cCampo1) .OR. STransType(cCampo1) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if SEmpty(cCampo2) .OR. STransType(cCampo2) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if cCampo1 > cCampo2
		    cMsg := STR0077
		    return .F.
	    endif

		cParams += "'"+SDBDate(cCampo1,'00:00:00')+"',"
		cParams += "'"+SDBDate(cCampo2,'23:59:59')+"',"
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL"
	elseif cOpcao == "6" //DDE
	   cCampo1 := STrim(aFilter[i][4][48][1])
	   cCampo2 := STrim(aFilter[i][4][51][1])
	   cCampo3 := STrim(aFilter[i][4][54][1])
	   cCampo4 := STrim(aFilter[i][4][57][1])

		if SEmpty(cCampo1) .OR. STransType(cCampo1) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if SEmpty(cCampo2) .OR. STransType(cCampo2) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if SEmpty(cCampo3) == .F.
		    if SEmpty(cCampo4)
			    cMsg := STR0075
			    return .F.
		    endif
	    endif

	    if SEmpty(cCampo3)
	    	cCampo3 := 'NULL'
	    else
	    	cCampo3 := "'"+cCampo3+"'"
	    endif

	    if SEmpty(cCampo4)
	    	cCampo4 := 'NULL'
	    else
	    	cCampo4 := "'"+cCampo4+"'"
	    endif

	    if cCampo1 > cCampo2
		    cMsg := STR0077
		    return .F.
	    endif

		cParams += "'"+SDBDate(cCampo1,'00:00:00')+"',"
		cParams += "'"+SDBDate(cCampo2,'23:59:59')+"',"
		cParams += +cCampo3+","+cCampo4+",NULL,NULL,NULL,NULL,NULL"
	elseif cOpcao == "7" //Mercadorias em abono
	    cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL"
	elseif cOpcao == "8" //Substituição de CDA
	   cCampo1 := STrim(cNrDac)

		if SEmpty(cCampo1)
		    cMsg := STR0075
		    return .F.
	    endif

		cParams += "NULL,NULL,NULL,NULL,'"+cCampo1+"',NULL,NULL,NULL,NULL"
	elseif cOpcao == "9" //CDAs extintos
	   cCampo1 := STrim(aFilter[i][4][75][1])
		cCampo2 := STrim(aFilter[i][4][78][1])

		if SEmpty(cCampo1) .OR. STransType(cCampo1) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if SEmpty(cCampo2) .OR. STransType(cCampo2) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if cCampo1 > cCampo2
		    cMsg := STR0077
		    return .F.
	    endif

		cParams += "'"+SDBDate(cCampo1,'00:00:00')+"',"
		cParams += "'"+SDBDate(cCampo2,'23:59:59')+"',"
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL"
	elseif cOpcao == "10" //CDAs pendentes de conclusão
		cParams += "NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL"
	elseif cOpcao == "11" //Comprador, vendedor e Mandatário
		cCampo1 := STrim(aFilter[i][4][93][1])
		cCampo2 := STrim(aFilter[i][4][96][1])
		cCampo3 := STrim(aFilter[i][4][99][1])
		
		if trim(cCli) = ''
		   cCli := cCampo3
		endIf

		cCampo4 := STrim(cCli)

		if SEmpty(cCampo1) .OR. STransType(cCampo1) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if SEmpty(cCampo2) .OR. STransType(cCampo2) == "  /  /    "
		    cMsg := STR0075
		    return .F.
	    endif

	    if SEmpty(cCampo3)
		    cMsg := STR0075
		    return .F.
	    endif

	    if SEmpty(cCampo4)
		    cMsg := STR0075
		    return .F.
	    endif

	    if cCampo1 > cCampo2
		    cMsg := STR0077
		    return .F.
	    endif

	    if STrim(cCampo3) != '0' .AND. STrim(cCampo3) != '1' .AND. STrim(cCampo3) != '2'
	       cMsg := STR0078
	       return .F.
	    endif

		cParams += "'"+SDBDate(cCampo1,'00:00:00')+"',"
		cParams += "'"+SDBDate(cCampo2,'23:59:59')+"',"

		if cCampo3 == '0'
		   cParams += "NULL,NULL,NULL,"+STransType(cCampo3)+",'"+cCampo4+"',NULL,NULL"
		elseif cCampo3 == '1'
		   cParams += "NULL,NULL,NULL,"+STransType(cCampo3)+",NULL,'"+cCampo4+"',NULL"
		elseif cCampo3 == '2'
		   cParams += "NULL,NULL,NULL,"+STransType(cCampo3)+",NULL,NULL,'"+cCampo4+"'"
		endif
	endif

	cParams += ",'"+SGetDBOwner()+cAliasTb+"'"
return .T.

function C936ZOOMP(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

	if nTipoZoom == 1 //CDA
		aZoom := SZoomCDA(.T.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
			cNrDac := STransType(aRetZoom[2],"C")
		else
			oObj:cText := '                                        '
			cNrDac := ''
		endif
	elseif nTipoZoom == 2 //Cliente
       aZoom := SZoomCli(.T., .T., .F., .T.)
       aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[2],"C")
			cCli := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                                        '
			cCli := ''
		endif
	elseif nTipoZoom == 3 //Tipo de Beneficiário
	   	aZoom := SZoomTpBen()
       aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                                        '
		endif
	endif

return lRet

function C936VLCDA(xConteud, o)
	if !SEmpty(xConteud)
		if C936ZOOMP(o, 1)
			return .T.
		else
			Alert(STR0076)
			return .F.
		end
	end
return .T.

function C936VLCLI(xConteud, o)
	cCli := ''
	if !SEmpty(xConteud)
		if C936ZOOMP(o, 2)
			return .T.
		else
			Alert(STR0076)
			return .F.
		end
	end
return .T.

static function C936CTB(cOpcao)
   if cOpcao == '1'
      aStructDesc := {  ;
	    {STR0022, 15},;
		{STR0023, 20},;
		{STR0024, 15},;
		{STR0025, 40},;
		{STR0026, 15},;
		{STR0027, 15},;
		{STR0028, 15}, ;
		{STR0029, 15}, ;
		{STR0030, 40}, ;
		{STR0031, 40}, ;
		{STR0032, 40},;
		{STR0033, 40};
      }

      aStruct := {    ;
      	{'CP1'    ,'C',100 ,0}, ;
	    {'CP2'    ,'C',100 ,0}, ;
	    {'CP3'    ,'C',100 ,0}, ;
	    {'CP4'    ,'C',250 ,0}, ;
	    {'CP5'    ,'C',100 ,0}, ;
	    {'CP6'    ,'C',100 ,0}, ;
	    {'CP7'    ,'C',100 ,0}, ;
	    {'CP8'    ,'C',100 ,0}, ;
	    {'CP9'    ,'C',100 ,0}, ;
	    {'CP10'   ,'C',100 ,0}, ;
	    {'CP11'   ,'C',100 ,0}, ;
	    {'CP12'   ,'C',100 ,0}  ;
      }
   elseif cOpcao == '2'
      aStructDesc := {  ;
      	{STR0022, 15},;
		{STR0034, 15},;
		{STR0035, 20},;
		{STR0036, 15},;
		{STR0037, 20}, ;
		{STR0038, 15}, ;
		{STR0025, 30}, ;
		{STR0026, 15}, ;
		{STR0027, 15},;
		{STR0028, 15},;
		{STR0029, 15},;
		{STR0030, 40},;
		{STR0031, 40},;
		{STR0033, 40},;
		{STR0039, 15} ;
      }

		aStruct := {    ;
		 {'CP1'    ,'C',100 ,0}, ;
	     {'CP2'    ,'C',100 ,0}, ;
	     {'CP3'    ,'C',100 ,0}, ;
	     {'CP4'    ,'C',100 ,0}, ;
	     {'CP5'    ,'C',100 ,0}, ;
	     {'CP6'    ,'C',100 ,0}, ;
	     {'CP7'    ,'C',250 ,0}, ;
	     {'CP8'    ,'C',100 ,0}, ;
	     {'CP9'    ,'C',100 ,0}, ;
	     {'CP10'    ,'C',100 ,0}, ;
	     {'CP11'    ,'C',100 ,0}, ;
	     {'CP12'    ,'C',100 ,0}, ;
	     {'CP13'    ,'C',100 ,0}, ;
	     {'CP14'    ,'C',100 ,0}, ;
	     {'CP15'    ,'C',100 ,0}  ;
		}

   elseif cOpcao == '3'
      aStructDesc := {  ;
      	{STR0022, 15}, ;
		{STR0024, 15}, ;
		{STR0025, 40}, ;
		{STR0040, 15},;
		{STR0041, 15},;
		{STR0030, 40},;
		{STR0031, 40},;
		{STR0033, 40},;
		{STR0034, 15},;
		{STR0035, 20}, ;
		{STR0036, 15}, ;
		{STR0037, 20}, ;
		{STR0043, 15}, ;
		{STR0044, 15},;
		{STR0045, 15},;
		{STR0046, 15},;
		{STR0047, 15} ;
      }

      aStruct := {    ;
      	{'CP1'    ,'C',100 ,0}, ;
      	{'CP2'    ,'C',100 ,0}, ;
      	{'CP3'    ,'C',250 ,0}, ;
      	{'CP4'    ,'C',100 ,0}, ;
      	{'CP5'    ,'C',100 ,0}, ;
      	{'CP6'    ,'C',100 ,0}, ;
      	{'CP7'    ,'C',100 ,0}, ;
      	{'CP8'    ,'C',100 ,0}, ;
      	{'CP9'    ,'C',100 ,0}, ;
      	{'CP10'    ,'C',100 ,0}, ;
      	{'CP11'    ,'C',100 ,0}, ;
      	{'CP12'    ,'C',100 ,0}, ;
      	{'CP13'    ,'C',100 ,0}, ;
      	{'CP14'    ,'C',100 ,0}, ;
      	{'CP15'    ,'C',100 ,0}, ;
      	{'CP16'    ,'C',100 ,0}, ;
      	{'CP17'    ,'C',100 ,0}  ;
      }
   elseif cOpcao == '4'
      aStructDesc := {  ;
      	{STR0022, 15},;
		{STR0024, 15},;
		{STR0025, 30}, ;
		{STR0048, 15}, ;
		{STR0029, 15}, ;
		{STR0049, 10}, ;
		{STR0050, 10},;
		{STR0051, 10},;
		{STR0052, 30},;
		{STR0053, 10},;
		{STR0054, 10},;
		{STR0055, 10} ;
      }

      aStruct := {    ;
      	{'CP1'    ,'C',100 ,0}, ;
      	{'CP2'    ,'C',100 ,0}, ;
      	{'CP3'    ,'C',250 ,0}, ;
      	{'CP4'    ,'C',100 ,0}, ;
      	{'CP5'    ,'C',100 ,0}, ;
      	{'CP6'    ,'C',100 ,0}, ;
      	{'CP7'    ,'C',100 ,0}, ;
      	{'CP8'    ,'C',100 ,0}, ;
      	{'CP9'    ,'C',100 ,0}, ;
      	{'CP10'    ,'C',100 ,0}, ;
      	{'CP11'    ,'C',100 ,0}, ;
      	{'CP12'    ,'C',100 ,0}  ;
      }
   elseif cOpcao == '5'
      aStructDesc := {  ;
      	{STR0022, 15}, ;
		{STR0056, 20}, ;
		{STR0030, 40}, ;
		{STR0031, 40}, ;
		{STR0033, 40},;
		{STR0024, 15},;
		{STR0025, 30},;
		{STR0048, 15},;
		{STR0057, 15},;
		{STR0049, 10},;
		{STR0050, 10}, ;
		{STR0051, 10}, ;
		{STR0052, 10}, ;
		{STR0053, 10}, ;
		{STR0054, 10},;
		{STR0055, 10} ;
      }

      aStruct := {    ;
      	{'CP1'    ,'C',100 ,0}, ;
      	{'CP2'    ,'C',100 ,0}, ;
      	{'CP3'    ,'C',100 ,0}, ;
      	{'CP4'    ,'C',100 ,0}, ;
      	{'CP5'    ,'C',100 ,0}, ;
      	{'CP6'    ,'C',100 ,0}, ;
      	{'CP7'    ,'C',250 ,0}, ;
      	{'CP8'    ,'C',100 ,0}, ;
      	{'CP9'    ,'C',100 ,0}, ;
      	{'CP10'    ,'C',100 ,0}, ;
      	{'CP11'    ,'C',100 ,0}, ;
      	{'CP12'    ,'C',100 ,0}, ;
      	{'CP13'    ,'C',100 ,0}, ;
      	{'CP14'    ,'C',100 ,0}, ;
      	{'CP15'    ,'C',100 ,0}, ;
      	{'CP16'    ,'C',100 ,0}  ;
      }
   elseif cOpcao == '6'
      aStructDesc := {  ;
      	{STR0018, 15},;
		{STR0022, 15},;
		{STR0059, 15},;
		{STR0060, 15} ;
      }

      aStruct := {    ;
      	{'CP1'    ,'C',100 ,0}, ;
      	{'CP2'    ,'C',100 ,0}, ;
      	{'CP3'    ,'C',100 ,0}, ;
      	{'CP4'    ,'C',100 ,0}  ;
      }
   elseif cOpcao == '7'
      aStructDesc := {  ;
      	{STR0022, 20}, ;
		{STR0056, 15}  ;
      }

      aStruct := {    ;
      	{'CP1'    ,'C',100 ,0}, ;
      	{'CP2'    ,'C',100 ,0}  ;
      }
   elseif cOpcao == '8'
      aStructDesc := {  ;
      	{STR0061, 15}, ;
		{STR0062, 15}, ;
		{STR0063, 15},;
		{STR0064, 20},;
		{STR0057, 15} ;
      }

      aStruct := {    ;
      	{'CP1'    ,'C',100 ,0}, ;
      	{'CP2'    ,'C',100 ,0}, ;
      	{'CP3'    ,'C',100 ,0}, ;
      	{'CP4'    ,'C',100 ,0}, ;
      	{'CP5'    ,'C',100 ,0}  ;
      }
   elseif cOpcao == '9'
      aStructDesc := {  ;
      	{STR0022, 15},;
		{STR0023, 20},;
		{STR0069, 20},;
		{STR0045, 15}  ;
      }

      aStruct := {    ;
      	{'CP1'    ,'C',100 ,0}, ;
      	{'CP2'    ,'C',100 ,0}, ;
      	{'CP3'    ,'C',100 ,0}, ;
      	{'CP4'    ,'C',100 ,0}  ;
      }
   elseif cOpcao == '10'
      aStructDesc := {  ;
      	{STR0022, 15}, ;
		{STR0023, 20}, ;
		{STR0056, 20}, ;
		{STR0034, 15},;
		{STR0065, 20},;
		{STR0045, 15},;
		{STR0066, 20} ;
      }

      aStruct := {    ;
      	{'CP1'    ,'C',100 ,0}, ;
      	{'CP2'    ,'C',100 ,0}, ;
      	{'CP3'    ,'C',100 ,0}, ;
      	{'CP4'    ,'C',100 ,0}, ;
      	{'CP5'    ,'C',100 ,0}, ;
      	{'CP6'    ,'C',100 ,0}, ;
      	{'CP7'    ,'C',100 ,0}  ;
      }
   elseif cOpcao == '11'
        if cPessoa == '0' 
          aStructDesc := {  ;
      	   {STR0022, 15},;
		   {STR0067, 15},;
		   {STR0031, 40},;
		   {STR0068, 20}, ;
		   {STR0069, 20}, ;
		   {STR0070, 30}, ;
		   {STR0071, 30}, ;
		   {STR0072, 10}, ;
		   {STR0073, 20}  ;
          }
       elseif cPessoa == '1'
          aStructDesc := {  ;
      	   {STR0022, 15},;
		   {STR0067, 15},;
		   {"Vendedor", 40},;
		   {STR0068, 20}, ;
		   {STR0069, 20}, ;
		   {STR0070, 30}, ;
		   {STR0071, 30}, ;
		   {STR0072, 10}, ;
		   {STR0073, 20}  ;
          }       
       elseif cPessoa == '2'
          aStructDesc := {  ;
      	   {STR0022, 15},;
		   {STR0067, 15},;
		   {"Mandatário", 40},;
		   {STR0068, 20}, ;
		   {STR0069, 20}, ;
		   {STR0070, 30}, ;
		   {STR0071, 30}, ;
		   {STR0072, 10}, ;
		   {STR0073, 20}  ;
          }       
       end 

      aStruct := {    ;
      	{'CP1'    ,'C',100 ,0}, ;
      	{'CP2'    ,'C',100 ,0}, ;
      	{'CP3'    ,'C',100 ,0}, ;
      	{'CP4'    ,'C',100 ,0}, ;
      	{'CP5'    ,'C',100 ,0}, ;
      	{'CP6'    ,'C',100 ,0}, ;
      	{'CP7'    ,'C',100 ,0}, ;
      	{'CP8'    ,'C',100 ,0}, ;
      	{'CP9'    ,'C',100 ,0}  ;
      }
   end

   SDelTb(cAliasTb)
   SCriaTb(cAliasTb, aStruct)
return aStructDesc
