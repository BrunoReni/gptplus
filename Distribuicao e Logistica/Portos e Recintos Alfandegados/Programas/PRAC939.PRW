#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC939.CH"

#define __CAM_ID__             1
#define __CAM_DESC__           2
#define __DIRECAO_VEIC__       3
#define __NUMERO__             4
#define __NUMERO_CONFIRMADO__  5
#define __DIVERGENCIA__        6
#define __PATH_IMAGEM__        7

//#INCLUDE "PRAC939.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRAC939
@author   Luan Eli Oliveira
@version  P12
@since    02/04/2013
@obs      Consulta de Imagem
/*/
//-------------------------------------------------------------------
Function PRAC939(cCesv)

	Private oDlg       := nil
 	Private oLayer     := nil
 	Private oPanelC1   := nil
 	Private oPanelC2   := nil
 	Private oBrowse    := nil
 	Private oColumns   := nil
 	Private oBitmap    := nil

 	Private cQuery  := ''
 	Private cAlias  := GetNextAlias()
	Private cMV_SARAOCR := SuperGetMv('MV_SARAOCR', .T., '\IMAGENS_OCR\')

	Private aArrayGrid := {}

	cQuery := ""
	cQuery += "  select b.cam_id, "
	cQuery += "         b.cam_desc, "
	cQuery += "         a.direcao_veic, "
	cQuery += "         a.numero, "
	cQuery += "         a.numero_confirmado, "
	cQuery += "         case  "
	cQuery += "           when (a.numero <> a.numero_confirmado) then "
 	cQuery += "             'Sim' "
 	cQuery += "           else  "
 	cQuery += "             'Não' "
 	cQuery += "         end divergencia, "
 	cQuery += "         a.path_imagem    "
 	cQuery += "    from rel_cesv_imagem_portaria a "
 	cQuery += "   inner join tab_portaria_camera b   "
 	cQuery += "      on a.cam_id = b.cam_id "
 	cQuery += "   where cesv_id =  '" + cCesv + "'"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)

 	i := 1

   While (cAlias)->(!EOF())
   		aAdd(aArrayGrid, {;
   			STrim((cAlias)->(FieldGet(__CAM_ID__))),;
   			STrim((cAlias)->(FieldGet(__CAM_DESC__))),;
   			STrim((cAlias)->(FieldGet(__DIRECAO_VEIC__))),;
   			STrim((cAlias)->(FieldGet(__NUMERO__))),;
   			STrim((cAlias)->(FieldGet(__NUMERO_CONFIRMADO__))),;
   			STrim((cAlias)->(FieldGet(__DIVERGENCIA__))),;
   			STrim((cAlias)->(FieldGet(__PATH_IMAGEM__))),;
   			})
          (cAlias)->(dbSkip())
          i++
	EndDo

	If i == 1
		Return
	Endif

	//DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]
	DEFINE DIALOG oDlg TITLE STR0001 FROM 180,180 TO 700,950 PIXEL

		oLayer := FWLayer():new()
		oLayer:init(oDlg,.F.)

		oLayer:addColumn('Col01',40,.F.)
		oLayer:addColumn('Col02',60,.F.)
		oLayer:addWindow('Col01','C1_Win01',STR0002, 100,.F.,.F.,,,)
		oLayer:addWindow('Col02','C2_Win01',STR0003, 100,.F.,.F.,,,)

		oPanelC1  := oLayer:getWinPanel('Col01','C1_Win01')
		oPanelC2  := oLayer:getWinPanel('Col02','C2_Win01')

		oBitmap := TBitmap():Create(oPanelC2,01,01,300,300,,"",.T.,,,.T.,.T.,,,.F.,,.T.,,.F.)
		oBitmap:Align := CONTROL_ALIGN_ALLCLIENT

		oBrowse:= FWBrowse():New(oPanelC1)
		oBrowse:DisableConfig()
		oBrowse:DisableReport()
		oBrowse:SetDataArray()
		oBrowse:SetArray(aArrayGrid)
		oBrowse:SetChange({|| C939CHNGLN(oBitmap) })

		//ID Camera
		oColumns := FWBrwColumn():New()
       oColumns:SetData( &(" { || aArrayGrid[oBrowse:At(),1]}") )
		oColumns:SetTitle(STR0004)
		oColumns:SetSize(4)
		oBrowse:SetColumns({oColumns})

		//Descrição
		oColumns := FWBrwColumn():New()
       oColumns:SetData( &(" { || aArrayGrid[oBrowse:At(),2]}") )
		oColumns:SetTitle(STR0005)
		oColumns:SetSize(15)
		oBrowse:SetColumns({oColumns})

		//Direção
		oColumns := FWBrwColumn():New()
       oColumns:SetData( &(" { || aArrayGrid[oBrowse:At(),3]}") )
		oColumns:SetTitle(STR0006)
		oColumns:SetSize(4)
		oBrowse:SetColumns({oColumns})

		//Placa OCR
		oColumns := FWBrwColumn():New()
       oColumns:SetData( &(" { || aArrayGrid[oBrowse:At(),4]}") )
		oColumns:SetTitle(STR0007)
		oColumns:SetSize(10)
		oBrowse:SetColumns({oColumns})

		//Valor Confirmado
		oColumns := FWBrwColumn():New()
       oColumns:SetData( &(" { || aArrayGrid[oBrowse:At(),5]}") )
		oColumns:SetTitle(STR0008)
		oColumns:SetSize(10)
		oBrowse:SetColumns({oColumns})

		//Houve divergência?
		oColumns := FWBrwColumn():New()
       oColumns:SetData( &(" { || aArrayGrid[oBrowse:At(),6]}") )
		oColumns:SetTitle(STR0009)
		oColumns:SetSize(10)
		oBrowse:SetColumns({oColumns})

		//Path Imagem
		oColumns := FWBrwColumn():New()
       oColumns:SetData( &(" { || aArrayGrid[oBrowse:At(),7]}") )
		oColumns:SetTitle(STR0003)
		oColumns:SetSize(20)
		oBrowse:SetColumns({oColumns})

		oBrowse:Activate()


	ACTIVATE MSDIALOG oDlg CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C939CHNGLN
@author   Luan Eli Oliveira
@version  P12
@since    02/04/2013
@obs      Função que carregam a imagem
/*/
//-------------------------------------------------------------------
Static Function C939CHNGLN(oBmp)
	Local nPosBrowse := 0
	Local cImage := ''

	nPosBrowse := oBrowse:At()
	cImage := aArrayGrid[nPosBrowse][__PATH_IMAGEM__]

	If (GetRemoteType() == 5)
		CpyS2TW(AllTrim(cMV_SARAOCR + cImage), .F.)
	EndIf

	If oBmp:Load( , cMV_SARAOCR + cImage ) == .F.
		oBmp:SetEmpty()
	Endif

Return