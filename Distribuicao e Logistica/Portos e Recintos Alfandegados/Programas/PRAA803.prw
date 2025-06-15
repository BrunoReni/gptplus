#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PRAA803.CH"

#define INFO_ZOOM_TIPO_EXECUCAO_SQL   1

Static cConfirmar := 'Sim'
Static cCancelar  := 'Não' 

//-----------------------------------
/*{Protheus.doc}
Atualizar eventos da programacao

@author Luan Oliveira
@version P12
@Since	26/11/13
@obs Atualizar eventos da programacao
*/
//-----------------------------------
Function PRAA803(cProg_ID, cModal_ID, cModal_DS, cOp_DS, cSub_DS, l_Val)

	Local aCoors := FWGetDialogSize(oMainWnd) //Coordenada da janela
	Local oTPanel := nil
	Local oLayer := nil
	Local oTPanelMiddle := nil
	Local oTPanelBottom := nil
	Local oFont := nil
	
	Local oSayEve_ID := nil
	Local oGetEve_ID := nil	
	Local oGetEve_DS := nil
	Local oBtnAlterar := nil
	Local oBtnCancelar := nil

	Local aFields    := {}                        //Campos de pesquisa		
	Local oBrowseBottom := nil
	Local oColumns := nil		
	
	Local nMarginL := 2
	Local nMarginT := 2	
    
    Local aRet := {}
    Local cRet := ""
    
    Private cProgID := cProg_ID
    Private cModalID := cModal_ID
    Private cEve_ID := ""    
    Private cEve_DS := ""
        
	Private oDlgPrincipal := nil 
	Private oDlgAttr := nil
   Private cAliasHst := SGetNAlias()              //Tabela temporária
   Private cAliasAux := ""
      
    Private aStructHst := {}
	Private aStructDHst := {} 
   	Private nColSizeR := 0    	
	Private lResult := .F.
	Private lPermiteAlterar := .F.
	Private cUsuario := ""
    
    /* Tela de Atributos */
    Private aBrwAttrInput := {}
    Private aBrwAttrMensagem := {}
    Private oBrwAttr := nil 
    Private cAliasAttr := ""
    /* Tela de Atributos */
    
    cUsuario := RET_USER()
		
	DEFINE MSDIALOG oDlgPrincipal PIXEL TITLE STR0001 FROM 0,0 TO 600,800 PIXEL //aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]   
    
	oLayer := FWLayer():new()
	oLayer:Init(oDlgPrincipal, .T.)
	oLayer:addCollumn('Col01',100,.F.)	
	oLayer:addWindow('Col01','C1_Win01',STR0003 + cProg_ID, 20,.T.,.F.,,,)
	oLayer:addWindow('Col01','C1_Win02',STR0004, 80,.T.,.F.,,,)				
    
    oFont := TFont():New('Arial',,14,.T.)


    //Campos 'Alteração de Evento'
    oTPanelMiddle := oLayer:getWinPanel('Col01','C1_Win01')
    oSayEve_ID := TSay():Create( oTPanelMiddle, {||STR0009 }, nMarginT, nMarginL,,oFont,,,,.T.,CLR_BLACK,CLR_RED,500,500)
	oGetEve_ID := TGet():Create( oTPanelMiddle,{||cEve_ID},  nMarginT-1,  47+nMarginL, 30, 009, "!@" ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cEve_ID,,,, )
	oGetEve_DS := TGet():Create( oTPanelMiddle,{||cEve_DS},  nMarginT-1,  82+nMarginL, 156, 009, "!@" ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cEve_DS,,,, )    
    oBtnZoomEV := TButton():Create( oTPanelMiddle, nMarginT-1,240+nMarginL,'Zoom Evento' ,{|| A803ZMEV() },45,11,,,,.T.,,,,,,)
    
    oBtnAlterar := TButton():Create( oTPanelMiddle,13+nMarginT,102+nMarginL, STR0010,{|| A803CONFIRM() },65,11,,,,.T.,,,,,,)
    oBtnCancelar := TButton():Create( oTPanelMiddle,13+nMarginT,172+nMarginL,STR0011,{|| A803CANCEL() },65,11,,,,.T.,,,,,,)    
        
    //Campos 'Histórico de eventos'       
    oTPanelBottom := oLayer:getWinPanel('Col01','C1_Win02')           
            	    		
    A803GridHst(oTPanelBottom)
    
	ACTIVATE MSDIALOG oDlgPrincipal CENTER
	
	SDelTb(cAliasHst)
	
Return lResult 

//----------------------------------------------
/*{Protheus.doc}
Criar estrutura de array do histórico de eventos

@author Luan Oliveira
@version P12
@Since	10/12/13
@obs Criar estrutura de array do histórico de eventos
*/
//----------------------------------------------
Static Function A802CTHST()
	aStructDHst := {  ;
	    {STR0012, 15},;
		{STR0013, 20},;
		{STR0014, 20},;
		{STR0015, 20},;
		{STR0016, 20};
	}

	aStructHst := {    ;
	    {'CP1'    ,'C',100 ,0}, ;
	    {'CP2'    ,'C',100 ,0}, ;
	    {'CP3'    ,'C',100 ,0}, ;
	    {'CP4'    ,'C',100 ,0}, ;
	    {'CP5'    ,'C',100 ,0}  ;
	    }

	SDelTb(cAliasHst)
	SCriaTb(cAliasHst, aStructHst)
	
return aStructDHst

//----------------------------------------------
/*{Protheus.doc}
Criar grid histórico de eventos

@author Luan Oliveira
@version P12
@Since	10/12/13
@obs Criar grid histórico de eventos
*/
//----------------------------------------------
Static Function A803GridHst(oTPanelBottom)
	Local cQuery      := ""
	Local nMax        := 0
	Local oColumn
	Local nI          := 0
	Local cMsg := ""
	Local cRet := ''
	Local cCampo := ''
 
    A802CTHST()

    oBrowseBottom := SCBROWSE(oTPanelBottom, cAliasHst, nil)
    oBrowseBottom:Activate()
    
    nColSizeHst := Len(oBrowseBottom:aColumns)

	for nI := 1 to nColSizeHst
		oBrowseBottom:DelColumn(nI)
	next

    nColSizeHst := 3
    
	for nI := 1 to nColSizeHst
		oColumn := nil

		cCampo := STransType(aStructHst[nI][1])
		cCampo := "{|| "+cCampo+"}"

		oColumn := FWBrwColumn():New()
		oColumn:SetData(  &(cCampo) )
		oColumn:SetTitle( aStructDHst[nI][1]   )
		oColumn:SetSize(  aStructDHst[nI][2]   )

		oBrowseBottom:SetColumns({oColumn})
	next        
	
	(cAliasHst)->(dbCloseArea())
	    
    cQuery = " insert into " + cAliasHst + " " 
    cQuery += " select convert(varchar, a.dt_inicio , 103) as dt_inicio, "      
    cQuery += "        convert(varchar, a.dt_inicio , 108) as hr_inicio, "
    cQuery += "        b.eve_desc, "
    cQuery += "        a.eve_prog_id, "
    cQuery += "        a.eve_id, "
    cQuery += " ' ' as D_E_L_E_T, "
    cQuery += " ROW_NUMBER() OVER(ORDER BY dt_inicio ASC) AS R_E_C_N_O_ "
    cQuery += "   from tab_programacao_eventos a "
    cQuery += "  inner join tab_agen_eventos b "
    cQuery += "     on a.eve_id = b.eve_id "
	cQuery += "  where a.prog_id = " + AllTrim(cProgId)           

	TcSqlExec(cQuery)
	TcRefresh(cAliasHst)
	DbUseArea(.T.,'TOPCONN',cAliasHst,cAliasHst,.T.,.F.)
	
	oBrowseBottom:UpdateBrowse()

Return .T.   

//----------------------------------------------
/*{Protheus.doc}
Zoom de eventos

@author Luan Oliveira
@version P12
@Since	10/12/13
@obs Zoom de eventos
*/
//----------------------------------------------
Static Function A803ZMEV()
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.
	Local aRet := {}	
	
	aZoom := SZoomEV(cModalId)
    aRetZoom := PRAC938(aZoom, '', @lRet)
		
	if !SEmpty(aRetZoom)
	   aRet := A803PESQEV(STransType(aRetZoom[1],"C"))
	   if !SEmpty(aRet)
	      cEve_ID := aRet[1]
	      cEve_DS := aRet[2]
	   else
	      cEve_ID := '                         '
	      cEve_DS := '                         '	 	      
	   endif
	else
	   cEve_ID := '                         '
	   cEve_DS := '                         '	   
	endif	
		
Return .T.

//-----------------------------------
/*{Protheus.doc}
Zoom de eventos

@author LUAN ELI OLIVEIRA
@version P12
@Since	12/04/13
@obs Monta zoom campo evento
*/
//-----------------------------------
static Function SZoomEV(cModal)

   Local aRet := {}
   Local aFields := {}
   Local cSql

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   cSql := " SELECT EVE_SEQ, EVE_ID, EVE_DESC, CASE WHEN EVE_OBRIGATORIO = 0 THEN 'NAO' ELSE 'SIM' END AS EVE_OBRIGATORIO"
   cSql += "   FROM TAB_AGEN_EVENTOS "
   cSql += "  WHERE EVE_MODAL = '"+cModal+"' "
   cSql += "    AND EVE_ATIVO = 1"

   Aadd(aRet, cSql)
   Aadd(aRet, ' ORDER BY EVE_SEQ')

              //aFields,   cCampo           ,  cDesc        , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "EVE_SEQ"          , "Sequência"        , "N"  , 10      , 0        , ""      , .T.     , .F., .T., 1)
   SAddPField(@aFields , "EVE_ID"           , "Cod. Evento"      , "N"  , 10      , 0        , ""      , .F.     , .T.)
   SAddPField(@aFields , "EVE_DESC"         , "Descrição"        , "C"  , 50      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "EVE_OBRIGATORIO"  , "Obrigatório?"     , "C"  , 3       , 0        , ""      , .T.     , .F.)

	Aadd(aRet, aFields)

Return aRet

//-----------------------------------
/*{Protheus.doc}
Retorna o Usuario

@author Luan Eli Oliveira
@version P12
@Since	03/12/13
@obs Retorna Usuario
*/
//-----------------------------------
Static Function RET_USER()
   Local cCodUsr := ''
   Local tTabUser := GetNextAlias()

   cQuery := " SELECT USU_ID FROM TAB_USUARIOS WHERE USU_ID = 'c" + StrTran(SCodUsr(),'ECPF','',1,1) + "'"
   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),tTabUser,.F.,.T.)

   cCodUsr := AllTrim((tTabUser)->USU_ID)
   (tTabUser)->(DbCloseArea())
Return cCodUsr

//-----------------------------------
/*{Protheus.doc}
Verificar se é permitido alterar o evento

@author Luan Eli Oliveira
@version P12
@Since	03/12/13
@obs Verificar se é permitido alterar o evento
*/
//-----------------------------------
Static Function A803PESQEV(cEve_ID)	 
   Local cAliasEvento := GetNextAlias()
   Local cSql := ''
   Local aRet := {}
   
   cSql := " SELECT A.EVE_ID, "
   cSql += "        A.EVE_DESC, "
   cSql += "        CASE WHEN A.EVE_OBRIGATORIO = 0 THEN " 
   cSql += "                'NAO' "
   cSql += "             ELSE " 
   cSql += "                'SIM' "
   cSql += "        END AS EVE_OBRIGATORIO "
   cSql += "   FROM TAB_AGEN_EVENTOS A "
   cSql += "  WHERE A.EVE_ID = "+cEve_ID+" "

   DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),cAliasEvento,.F.,.T.)
   DBSelectArea(cAliasEvento)
   
   if !SEmpty( (cAliasEvento)->(Fieldget(1)) )
      aAdd(aRet, cValtoChar((cAliasEvento)->(Fieldget(1))))
      aAdd(aRet, cValtoChar((cAliasEvento)->(Fieldget(2))))
      aAdd(aRet, cValtoChar((cAliasEvento)->(Fieldget(3))))
   endif
   (cAliasEvento)->(DbCloseArea())
	
   SDelTb(cAliasEvento)
	
Return aRet

//-----------------------------------
/*{Protheus.doc}
Verificar se a programação possui um evento

@author Luan Eli Oliveira
@version P12
@Since	03/12/13
@obs Verificar se a programação possui um evento
*/
//-----------------------------------
Static Function A803PESQPROGEV(cProgID)	 
   Local cAlias := GetNextAlias()
   Local cSql := ''
   Local cRet := ''
   
   cSql := " SELECT A.EVE_ID "        
   cSql += "   FROM TAB_PROGRAMACAO A "
   cSql += "  WHERE A.PROG_ID = "+cProgID+" "

   DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),cAlias,.F.,.T.)
   DBSelectArea(cAlias)
	
   cRet := cValtoChar((cAlias)->(Fieldget(1)))   
	
   (cAlias)->(DbCloseArea())
	
   SDelTb(cAlias)
	
Return cRet

//-----------------------------------
/*{Protheus.doc}
Ação que é executada ao clicar em confirmar a alteração

@author Luan Eli Oliveira
@version P12
@Since	03/12/13
@obs Ação que é executada ao clicar em confirmar a alteração
*/
//-----------------------------------
Static Function A803CONFIRM()
    /*
    if !lPermiteAlterar
       MsgAlert(STR0017)
       Return
    endif */ 		
    
	if A803ADDEVENT()
		lResult := .T.
		oDlgPrincipal:End()    	      
	endif		
	
Return 

//-----------------------------------
/*{Protheus.doc}
Ação que é executada ao clicar em cancelar a alteração

@author Luan Eli Oliveira
@version P12
@Since	03/12/13
@obs Ação que é executada ao clicar em cancelar a alteração
*/
//-----------------------------------
Static Function A803CANCEL()
	
	lResult := .F. 	
	oDlgPrincipal:End()
	
Return lResult

//-----------------------------------
/*{Protheus.doc}
Validacao da alteracao do evento

@author Luan Eli Oliveira
@version P12
@Since	03/12/13
@obs Validacao da alteracao do evento
*/
//-----------------------------------
Static Function A803ADDEVENT()
   Local cErro := ""
   Local lRet := .T.
   
   if AllTrim(cEve_ID) == ""
      MsgAlert(STR0018)
      Return .F.
   endif
   
   if AllTrim(cEve_DS) == ""
      MsgAlert(STR0019)
      Return .F.
   endif
      
   aResult := {}
   aResult := TCSPExec( "PROC_ALTERA_EVENTO_W", Val(cProgID), Val(cEve_ID), cModalID, cUsuario, 1 )   
   
	if Empty(aResult)
		cErro := STR0020 + Chr(13) + AllTrim(TCSQLError())
	else
	   if AllTrim(aResult[1]) <> ''
	      cErro := aResult[1]                  
	   endif
	endif
	   
	if AllTrim(cErro) <> ''
	   MsgAlert(cErro)  
	   lRet := .F.
	else
		aResult := {}
      
		if A803ATTR()
		   aResult := TCSPExec( "PROC_ALTERA_EVENTO_W", Val(cProgID), Val(cEve_ID), cModalID, cUsuario, 0 )
	   
		   if Empty(aResult)
		      cErro := STR0020 + Chr(13) + AllTrim(TCSQLError())
	   	   else
				if AllTrim(aResult[1]) <> ''
	           	cErro := aResult[1]                  
	      		endif
	   		endif
	   
	   		if AllTrim(cErro) <> ''
	      		MsgAlert(cErro)  
	      		lRet := .F.
	   		endif
		else
    		lRet := .F.
		endif
	endif      
	
Return lRet

//-----------------------------------
/*{Protheus.doc}
Tela de Atributos referentes ao evento alterado

@author Luan Eli Oliveira
@version P12
@Since	03/12/13
@obs Tela de Atributos referentes ao evento alterado
*/
//-----------------------------------
Static Function A803ATTR()  
	Local cSql := ""
	Local aStructA := {}
	Local oOK   := LoadBitmap(GetResources(),'FWSTD_LOOKUP.PNG')   
	Local oNO   := LoadBitmap(GetResources(),'br_vermelho.png') 
    Local aHeader := {}      
    Local lFlag
    Local nI := 0 
    Local cValorAtr := ''  
    Local cTipoAttr  := '' 
        
    lRetAttr := .F.
                                                                                                                                                
    cAliasAttr := SGetNAlias() 
         
	aStructA := {;
	    {'CP1' ,'C',100 ,1}, ;
	    {'CP2' ,'C',100 ,1}, ;
	    {'CP3' ,'C',100 ,1}, ;
	    {'CP4' ,'C',100 ,1}, ;
	    {'CP5' ,'C',100 ,1}, ;
	    {'CP6' ,'C',100 ,1}, ;
	    {'CP7' ,'C',1000 ,1}, ;
	    {'CP8' ,'C',100 ,1}, ;
	    {'CP9' ,'C',100 ,1}, ;
	    {'CP10' ,'C',2000 ,1}  ;
	    }

	SDelTb(cAliasAttr)
	SCriaTb(cAliasAttr, aStructA)
	
	(cAliasAttr)->(dbCloseArea())
	    
    cSql := " create table  #tmp_atributo_apresenta (atr_id int, apresenta bit) "
    cSql += " exec sp_apresenta_atributo_programacao " + AllTrim(cEve_ID) +" , " + AllTrim(cProgID)	    
    cSql += " insert into " + cAliasAttr + " " 
    cSql += " select a.atr_id, "
	cSql += "        a.atr_descricao,   "   
	cSql += "       a.atr_ordem, "  
    cSql += "        a.atr_tipo, "
    cSql += "        isnull(a.atr_tipo_campo, 0), "
    cSql += "        isnull(a.atr_tamanho, 1), "
    cSql += "        isnull(a.atr_precisao,0), "
    cSql += "        isnull(a.atr_comando_sql, ''), "      
	cSql += "        a.atr_obrigatorio, "
	cSql += "        isnull(RTrim(LTrim(b.atr_valor)), ''),"
    cSql += "        ' ' as D_E_L_E_T, "
    cSql += "        ROW_NUMBER() OVER(ORDER BY a.atr_ordem ASC) AS R_E_C_N_O_"
    cSql += "   from tab_atributos a "
    cSql += "   left join tab_prog_atributo b on a.atr_id = b.atr_id and b.prog_id = " + AllTrim(cProgID)
    cSql += "   inner join #tmp_atributo_apresenta c on a.atr_id = c.atr_id "
	cSql += "  where a.eve_id = " + AllTrim(cEve_ID)
	cSql += "  and a.ativado = 0 " 
	cSql += "  and c.apresenta = 1 "
    cSql += "  drop table #tmp_atributo_apresenta "
  
	TcSqlExec(cSql)
	
	cSql := "select * from "+cAliasAttr+" order by R_E_C_N_O_"
	
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),cAliasAttr,.T.,.F.)  

	aAdd( aHeader, STR0022 )
	aAdd( aHeader, STR0023)
	aAdd( aHeader, '' )       
    
    dbSelectArea(cAliasAttr)
    (cAliasAttr)->(DbGoTop())
    while (cAliasAttr)->(!EOF())
       if Empty( (cAliasAttr)->CP8 )
          lFlag := .F.
       else
          lFlag := .T.
       endif
       
       cValorAtr := STrim((cAliasAttr)->CP10)
       
       if AllTrim( (cAliasAttr)->CP4 ) == "A"
           cTipoAttr := AllTrim((cAliasAttr)->CP4)
           
	       aAdd( aBrwAttrInput, { ;
	       	                   AllTrim((cAliasAttr)->CP2),;  //Atributo | Descrição
	       	                   cValorAtr + Space(2000 - Len(cValorAtr)),;
	       	                   (cAliasAttr)->CP1,;  //Atributo | Código      	                   
	       	                   (cAliasAttr)->CP4,;  //Atributo | Tipo
	       	                   (cAliasAttr)->CP5,;  //Atributo | Tipo Campo
	       	                   (cAliasAttr)->CP6,;  //Atributo | Tamanho
	       	                   (cAliasAttr)->CP7,;  //Atributo | Precisao
	       	                   (cAliasAttr)->CP8,;  //Atributo | Comando SQL
	       	                   (cAliasAttr)->CP9,;  //Atributo | Obrigatorio
	       	                   lFlag})  
	       	                   
		   DEFINE MSDIALOG oDlgAttr PIXEL TITLE STR0024  FROM 0,0 TO 500,500 PIXEL   
	
	
	       //oBrwAttr := TWBrowse():New( 01,01,250,220,,aHeader,{25,10,10},oDlgAttr,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    
	       oBrwAttr := TWBrowse():New( 01,01,250,220,,aHeader,{},oDlgAttr,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	       oBrwAttr:SetArray(aBrwAttrInput)       
	       oBrwAttr:bLine := { || {aBrwAttrInput[oBrwAttr:nAt,1], aBrwAttrInput[oBrwAttr:nAt,2], If(aBrwAttrInput[oBrwAttr:nAt,10],oOK,oNO)} }                                    
	       oBrwAttr:bLDblClick := { || oBrwAttr:DrawSelect(), EditaCell(@aBrwAttrInput) }
	    
	
		   oBrwAttr:addColumn(TCColumn():new(STR0022 ,{|| aBrwAttrInput[oBrwAttr:nAt,1]             },"@!",,,"LEFT"  ,110,.F.,.F.,,/*bValid*/,,,))
		   oBrwAttr:addColumn(TCColumn():new(STR0023 ,{|| aBrwAttrInput[oBrwAttr:nAt,2]             },"@!",,,"LEFT"  ,100,.F.,.F.,,/*bValid*/,,,))    
		   oBrwAttr:addColumn(TCColumn():new(""      ,{|| If(aBrwAttrInput[oBrwAttr:nAt,10],oOK,oNO)},""  ,,,"CENTER",10,.T.,.F.,,/*bValid*/,,,))    
	    
   	       oBtnAttrOK := TButton():Create( oDlgAttr,230, 5,STR0025,{|| A803ATTRCONFIRM(cTipoAttr) },65,11,,,,.T.,,,,,,)
	       oBtnAttrNO := TButton():Create( oDlgAttr,230,75,STR0026,{|| A803ATTRCANCEL() },65,11,,,,.T.,,,,,,)
	    
	       ACTIVATE DIALOG oDlgAttr CENTER	  
	       
	       aBrwAttrInput := {}  
	       
	       oDlgAttr := Nil 
	       oBrwAttr := Nil 
	       
	       if AllTrim( (cAliasAttr)->CP9 ) == "0"
	         lRetAttr := .T.
	       end if 
	       
	        nI++   

           if (!lRetAttr)
             exit
           endif 	                   
	       	                   	
       endif
       if AllTrim( (cAliasAttr)->CP4 ) == "C"
           cTipoAttr := AllTrim( (cAliasAttr)->CP4 )
	       aAdd( aBrwAttrMensagem, { ;
	       	                   AllTrim((cAliasAttr)->CP2),;  //Atributo | Descrição
	       	                    cValorAtr + Replicate(" ", 2000 - Len(cValorAtr)),;
	       	                   (cAliasAttr)->CP1,;  //Atributo | Código      	                   
	       	                   (cAliasAttr)->CP4,;  //Atributo | Tipo
	       	                   (cAliasAttr)->CP5,;  //Atributo | Tipo Campo
	       	                   (cAliasAttr)->CP6,;  //Atributo | Tamanho
	       	                   (cAliasAttr)->CP7,;  //Atributo | Precisao
	       	                   (cAliasAttr)->CP8,;  //Atributo | Comando SQL
	       	                   (cAliasAttr)->CP9,;  //Atributo | Obrigatorio
	       	                   lFlag})  	
           
           A803ATTRCONFIRM(cTipoAttr)	
              
           aBrwAttrMensagem := {}   
           
           if AllTrim( (cAliasAttr)->CP9 ) == "0"
	         lRetAttr := .T.
	       end if 
	       
	        nI++   
          
           if (!lRetAttr)
             exit
           endif 	
                  	                   
       endif       	       	                     
       (cAliasAttr)->(DbSkip())         	                        	                        
    enddo
    
    if nI = 0
    	lRetAttr := .T.
       Return lRetAttr
    endif    

    
    SDelTb(cAliasAttr)    
    
Return lRetAttr

Static Function EditaCell(aArr)
	Local cVal := ""

	if oBrwAttr:ColPos() == 3 .AND. aArr[oBrwAttr:nAt,10] == .T.
		cVal := A803ZOOMSQL( aArr[oBrwAttr:nAt,8] )
		cVal := AllTrim(STransType(cVal))
		aArr[oBrwAttr:nAt,2] :=  cVal + Space(2000 - Len(cVal))
		oBrwAttr:Refresh() 
	endif
	   
	if oBrwAttr:ColPos() == 2
		if aArr[oBrwAttr:nAt,10] == .F.
			cVal := aArr[oBrwAttr:nAt,2]
			lEditCell(@aArr, oBrwAttr, "", 2)
		endif
	endif
Return .T.

//-----------------------------------
/*{Protheus.doc}
Ação do click ao confirmar a inclusao dos atributos do evento.

@author Luan Eli Oliveira
@version P12
@Since	03/12/13
@obs Ação do click ao confirmar a inclusao dos atributos do evento.
*/
//-----------------------------------
static function A803ATTRCONFIRM(cTipoAttr)
    Default cTipoAttr := '' 
    lRetAttr := .F.
    if A803ATTRVALIDACOES(cTipoAttr)
       lRetAttr := .T.
       if oDlgAttr != nil
       	oDlgAttr:End()
       endif       
    endif	           
Return lRetAttr

static function A803ATTRCANCEL()
    lRetAttr := .F.	
	oDlgAttr:End()		
Return lRetAttr

static function A803ATTRVALIDACOES(cTipoAttr)	
   Local nI
   Local nTamanho
   Local cDescricao := ""
   Local cCodigo := ""
   Local cTipo := ""
   Local cTipoCampo := ""
   Local cTamanho := ""
   Local cPrecisao := ""
   Local cComandoSQL := ""
   Local cObrigatorio := "" 
   
   Default cTipoAttr := ''  
   
   cAliasAux := ""
   
   for nI := 1 to Len(aBrwAttrInput)
	  cDescricao := aBrwAttrInput[nI][1]
	  cValor := aBrwAttrInput[nI][2]
	  cCodigo := aBrwAttrInput[nI][3]
	  cTipo := aBrwAttrInput[nI][4]
	  cTipoCampo := aBrwAttrInput[nI][5]
	  cTamanho := aBrwAttrInput[nI][6]
	  cPrecisao := aBrwAttrInput[nI][7]
	  cComandoSQL := aBrwAttrInput[nI][8]
	  cObrigatorio := aBrwAttrInput[nI][9]

      if ( AllTrim( cObrigatorio ) == "1" ) .And. Empty( AllTrim( cValor ) ) 
          MsgAlert(STR0027 + AllTrim( cDescricao ) + STR0028)
          Return .F.              
      endif
      
      //Verifica se o campo é obrigatorio
      if !Empty(AllTrim( cValor ))         
         do case
            case AllTrim( cTipoCampo ) == "1" //Valida String
               if !A803VALIDSTRING( AllTrim( cValor ) )
                  MsgAlert(STR0027 + AllTrim( cDescricao ) + STR0029 + STR0034)                                     
                  Return .F.
               endif
            case AllTrim( cTipoCampo ) == "2" //Valida Numerico
               if !A803VALIDNUMBER( AllTrim( cValor ) )
                  MsgAlert(STR0027 + AllTrim( cDescricao ) + STR0030 + STR0034)
                  Return .F.
               endif              
            case AllTrim( cTipoCampo ) == "3" //Valida Date
               if !A803VALIDDATE( AllTrim( cValor ) )
                  MsgAlert(STR0027 + AllTrim( cDescricao ) + STR0031 + STR0034)
                  Return .F.
               endif                 
            case AllTrim( cTipoCampo ) == "4" //Valida Datetime
               if !A803VALIDDATE( AllTrim( cValor ) )
                  MsgAlert(STR0027 + AllTrim( cDescricao ) + STR0032 + STR0034)
                  Return .F.
               endif                
            case AllTrim( cTipoCampo ) == "5" //Valida Boolean
               if !A803VALIDBOOLEAN( AllTrim( cValor ) )
                  MsgAlert(STR0027 + AllTrim( cDescricao ) + STR0033 + STR0034)                                     
                  Return .F.
               endif	              
            otherwise //Não possui tipo	              
         endcase
                  
         if !Empty(AllTrim( cTamanho ))
            nTamanho := Val(cTamanho)
            if (((AllTrim( cTipoCampo ) == "5") .OR. (AllTrim( cTipoCampo ) == "2") .OR. (AllTrim( cTipoCampo ) == "1")) .AND. (nTamanho < Len(AllTrim(cValor))))
                MsgAlert(STR0027 + AllTrim( cDescricao ) + STR0035 + AllTrim(cTamanho) + STR0036 + STR0034)
                Return .F.            
            endif   
         endif          
                       
      endif                 
   next
   
   //Salva as Informacoes na Tab_prog_atributo
   if !A803SALVAATTR(aBrwAttrInput)
      Return .F.   
   endif
   
   for nI := 1 to Len(aBrwAttrMensagem)
	  cDescricao := aBrwAttrMensagem[nI][1]
	  cValor := aBrwAttrMensagem[nI][2]
	  cCodigo := aBrwAttrMensagem[nI][3]
	  cTipo := aBrwAttrMensagem[nI][4]
	  cTipoCampo := aBrwAttrMensagem[nI][5]
	  cTamanho := aBrwAttrMensagem[nI][6]
	  cPrecisao := aBrwAttrMensagem[nI][7]
	  cComandoSQL := aBrwAttrMensagem[nI][8]
	  cObrigatorio := aBrwAttrMensagem[nI][9]
	  
	  if ( AllTrim( cTipo ) ) == "C"  //Atributo | Mensagem
	  
	  	//if MSGYESNO( cDescricao, "" )
//			  if !Empty( AllTrim(cComandoSQL) )
		     	cComandoSQL := StrTran(cComandoSQL, ":prog_id", cProgID, 1, nil)	  
			    cComandoSQL := StrTran(cComandoSQL, ":usu_id", cUsuario, 1, nil)
				  if A803TCONF(cDescricao, cComandoSQL, cTipoAttr)
				  	aBrwAttrMensagem[nI][2] := 'S'
				  else
				  	aBrwAttrMensagem[nI][2] := 'N'
				  	Return .F. 
				  endif
//			 endif
	  //endif
	 endif
	    
   next  
   
   if !A803SALVAATTR(aBrwAttrMensagem)   
      Return .F.   
   endif
   
Return .T.

static function A803TCONF(cPergunta, cComandoSQL, cTipoAttr)
	Local cTBTabelas  := GetNextAlias()
	Local cTBTemp     := GetNextAlias()
	Local aCampos := {}
	Local aCamposTb := {}
	LOcal cCampo := ""
	Local cAliasBrowse := ''
	Local lError := .F.
	Local oBrowse := nil
	Local nStart      := 0
	Local nMax        := 0
	Local oColumn
	Local bError := errorBlock({|e| SMSGERRO( e, @lError ) })
	Local oPnlTOP := nil
	Local oPnlBotton := nil
	Local oSayPerg := nil
	Local oFont := nil
	Private oDlgConf := nil
	
	Default cTipoAttr := ''
	
	DEFINE MSDIALOG oDlgConf PIXEL TITLE 'Confirmação'  FROM 0,0 TO 500,500 PIXEL
	
	oPnlBotton  := TPanel():Create(oDlgConf,01,102,"",,,,,,30,30)
    oPnlBotton:Align := 4

	oPnlTOP  := TPanel():Create(oDlgConf,01,102,"",,,,,,50,50)
    oPnlTOP:Align := 5	 
	
	cAliasBrowse := SCriaTbTmp({{{'CP1', 'C', 1, 0}}, {'CP1'}})
	oBrowse := FWBrowse():new(oPnlTOP)
	oBrowse:SetDataTable()
	oBrowse:SetAlias(cAliasBrowse)
	oBrowse:Activate()
	
	BEGIN SEQUENCE
		
		if UPPER(SUBSTR(LTRIM(cComandoSQL),1,4)) = 'EXEC'
		   SPrintCon(cComandoSQL+","+"'"+SGetDBOwner()+cTBTabelas+"'", 'PRAA803')
		   TCSqlExec(cComandoSQL+","+"'"+SGetDBOwner()+cTBTabelas+"'")
		elseIf(!Empty(cComandoSQL))	
		   SPrintCon('SELECT * INTO '+cTBTabelas+ ' FROM ('+cComandoSQL+') AS T', 'PRAA803')
		   TCSqlExec('SELECT * INTO '+cTBTabelas+ ' FROM ('+cComandoSQL+') AS T')
		endif	

        If(!Empty(cComandoSQL))	
			SPrintCon("exec proc_altera_col_sql_din_w '"+cTBTabelas+"'", 'PRAA803')
			TCSqlExec("exec proc_altera_col_sql_din_w '"+cTBTabelas+"'")
	
			SPrintCon("select * from "+cTBTabelas, 'PRAA803')
	        
			dbUseArea(.T., 'TOPCONN', TCGenQry(,,"select * from "+cTBTabelas),cTBTemp, .F., .F.)
			TCSqlExec('drop table '+cTBTabelas) 
		EndIf
		
	END SEQUENCE	
	
	if ((!lError) .And. (!Empty(cComandoSQL)))

		aCampos := (cTBTemp)->(DBSTRUCT())
		nMax := Len(aCampos)
		for nStart := 1 to nMax
			Aadd(aCamposTb, {'CP'+STrim(Str(nStart)) , aCampos[nStart][2], aCampos[nStart][3], aCampos[nStart][4]})
		next

		(cAliasBrowse)->(dbclosearea())
		SDelTbTmp(cAliasBrowse)
		SCriaTbTmp({aCamposTb, {'CP1'}}, cAliasBrowse)

		nMax := len(aCampos)

		(cTBTemp)->(DBGoTop())
		While (cTBTemp)->(!Eof())
			RecLock( cAliasBrowse, .T. )

			for nStart := 1 to nMax
				If aCampos[nStart][2] == "N"
					(cAliasBrowse)->(FieldPut(nStart,val(Str((cTBTemp)->(FieldGet(nStart)),aCampos[nStart][3],aCampos[nStart][4]))))
				Else
					(cAliasBrowse)->(FieldPut(nStart,STrim((cTBTemp)->(Fieldget(nStart)))))
				EndIf

			next
			(cAliasBrowse)->(MsUnlock())
			
			(cTBTemp)->(dbskip())			
		enddo
		(cTBTemp)->(dbCloseArea())

		//(cAliasBrowse)->(dbgotop())

		nColSize := Len(oBrowse:aColumns)
		for nStart := 1 to nColSize
			oBrowse:DelColumn(nStart)
		next

		nMax := Len(aCampos)
		for nStart := 1 to nMax
			oColumn := nil

			oColumn := FWBrwColumn():New()
			cCampo := 'CP'+STrim(Str(nStart))
			cCampo := "{|| "+cCampo+"}"
			oColumn:SetData(  &(cCampo) )

			oColumn:SetTitle(aCampos[nStart][1])
			oColumn:SetSize(aCampos[nStart][3])

			oBrowse:SetColumns({oColumn})
		next

		oBrowse:updateBrowse()

		if Select(cTBTemp) > 0
			(cTBTemp)->(dbCloseArea())
		endif
	else
		if Select(cTBTemp) > 0
			(cTBTemp)->(dbCloseArea())
		endif
	endif	
	
	If(cTipoAttr == "A")
	    cConfirmar := STR0025
	    cCancelar  := STR0026 
	EndIf
	    
	  
    oFont := TFont():New('Arial',,14,.T.)
	oSayPerg := TSay():Create( oPnlBotton, {||cPergunta }, 5, 5,,oFont,,,,.T.,CLR_BLACK,CLR_RED,500,500)	    
	oBtnAttrOK := TButton():Create( oPnlBotton,15, 5,cConfirmar,{|| A803CONFCONFIRM() },65,11,,,,.T.,,,,,,)
	oBtnAttrNO := TButton():Create( oPnlBotton,15,75,cCancelar,{|| A803CONFCANCEL() },65,11,,,,.T.,,,,,,)	  
	  	  
	  
	ACTIVATE DIALOG oDlgConf CENTER
	  
	SDelTbTmp(cAliasBrowse)
	SDelTbTmp(cTBTemp)
	  
return lRetAttr

static function A803CONFCONFIRM()
    lRetAttr := .T.
    oDlgConf:End()                  
Return .T.

static function A803CONFCANCEL()
    lRetAttr := .F.	
	oDlgConf:End()		
Return .T.

static function A803SALVAATTR(aArray)
   Local nI
   Local cCodigo := ""
   Local cValor := ""
   Local cErro := ""
   Local aResult := {}
   Local lRet := .T.
   
   for nI := 1 to Len(aArray)
      cCodigo := aArray[nI][3]
      cValor := aArray[nI][2]       
	  aResult := TCSPExec( "PROC_DIU_TAB_PROG_ATRIBUTO_W", 2, Val(cProgID), Val(cCodigo), AllTrim(cValor) )	   
	  if Empty(aResult)
	     cErro := STR0037 + Chr(13) + AllTrim(TCSQLError())
	  else
	     if AllTrim(aResult[1]) <> ''
	        cErro := aResult[1]         
	     endif
	  endif	   
	  if AllTrim(cErro) <> ''
	     MsgAlert(cErro)  
	     lRet := .F.   
	  endif            
   next

Return lRet

static function A803VALIDSTRING(cValue)
Return iif(!TEXTO(cValue), .F., .T. )

static function A803VALIDBOOLEAN(cValue)
Return iif( ( Alltrim(cValue) <> "S" ) .AND. ( Alltrim(cValue) <> "N" ), .F., .T.) 

static function A803VALIDDATE(cValue)
   Local dVal  
   dVal := cToD(cValue)   
Return iif(Empty(dVal), .F., .T.)

static function A803VALIDNUMBER(cValue)  
   Local nVal   
   nVal := Val(cValue)
Return iif(Empty(nVal), .F., .T.)   

Function A803ZOOMSQL(cSQL)
   Local n        := 1
   Local aRet     := {}
   Local aFields  := {}
   Local aStruct  := {}
   Local aRetZoom := {}
   Local cAliasZoom := SGetNAlias()
   Local lRet
   Local cQuery := ""
   Local bError         := { |e| oError := e , Break(e) }
   Local bErrorBlock    := ErrorBlock( bError )        
   Local oError
   
   cQuery := StrTran(cSQL, ":prog_id", cProgID, 1, nil)           
   
   if (TCSQLExec(cQuery) < 0)
      MsgAlert(STR0038)
      Return
   endif   
   
   DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasZoom, .F., .F.)
   
   aStruct := (cAliasZoom)->(DbStruct())      
   DbCloseArea()  

   Aadd(aRet, 1)
   Aadd(aRet, cQuery)
   Aadd(aRet, '')

   for n := 1 to len(aStruct)
      lRet := iif ( n == 1, .T., .F. )
      SAddPField(@aFields , aStruct[n][1] , aStruct[n][1]  , aStruct[n][2]  , aStruct[n][3]  , 0  , ""  , .T.   , lRet)   
   next

   aadd(aRet, aFields)

   aRetZoom := PRAC938(aRet)

 Return iif( SEmpty(aRetZoom), " ", aRetZoom[1] ) 
