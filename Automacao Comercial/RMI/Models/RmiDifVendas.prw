#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#include 'parmtype.ch'
#include 'fileio.ch'
#INCLUDE 'RMIDIFVENDAS.CH'

//--------------------------------------------------------
/*/{Protheus.doc} RmiDifVen
Comparar por meio de arquivos CSV gerado no CHEF, se as vendas 
do tipo NFC-e são encontradas na base Protheus(Tabela SL1) e gerar 
relatório com as vendas não encontradas

@param      Nao ha
@author  	Everson S P Junior
@version 	1.0
@since      16/09/2020
@return	    Nao ha
/*/
//--------------------------------------------------------
Function RmiDifVen()

If AmIIn(12)// Acesso apenas para modulo e licença do Varejo
    If ArqCsv()
        Processa({|| TelaProc() } ,"Lendo o Arquivo " + cArq ,,.F.) 
    EndIf
Else
    MSGALERT(STR0001)// "Esta rotina deve ser executada somente pelo módulo 12 (Controle de Lojas)"
EndIf

Return


//-------------------------------------------------------------------
/*{Protheus.Doc} ArqCsv    
Seleção do arquivo *.CSV
@author  Everson S P Junior
@version P12 
@since   23/09/2020  
@menu	 SIGALOJA                                                            
*/ 
//-------------------------------------------------------------------
Static Function ArqCsv()                   
Local   lRet  := .T.
Local   cTipo := "Arquivo(*.csv) |*.csv | "

Public  cArq  := '' 

cArq := cGetFile( cTipo ,STR0002,0,'C:',.T.,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY) )//Selecione a planilha

IF !Empty( cArq )
	IF !Upper( Subst( AllTrim( cArq), - 3 ) ) == Upper( AllTrim( "csv" ) )
		MsgAlert( STR0003 )//"Arquivo Invalido!"
	    lRet  := .F.
		Return
	EndIF
Else                
    lRet  := .F.
	Return //Seleção cancelada
Endif

nHdl  := FT_FUse(cArq,68)
If nHdl == -1
    MsgAlert(STR0004+cArq+STR0005,STR0006)//"O arquivo de nome "//" nao pode ser aberto! Verifique os parametros."//"Atencao!"
    lRet  := .F.
Endif

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.Doc} TelaProc    
Seleciona a tipo de execução
@author  Everson S P Junior
@version P12
@since   23/09/2020  
@menu	 Loja                                                            
*/ 
//-------------------------------------------------------------------
Static Function TelaProc()
Local lRet  	:= .F.
Local dDataIni	:= cTod("  /  /  ") 
Local dDataFim	:= cTod("  /  /  ")
Local bOk     	:= {||lRet := .T.,oDlg:End()}  
Local bCancel 	:= {||oDlg:End()}  
Local cTitcab 	:= STR0007// Ajusta o Arquivo
Local aCombo		:= {'1 - CHEF Arquivo 065 '}
Local cCombo		:= "1- CHEF Arquivo 065 "	    
Local oDlg        
Local oCombo
Local lWhen     := .F.
Local nSelec    := 0
Local lExit	    := .T.

Private lCheck3 := .F.   
Private lCancel	:= .F.
Private oCheck3
Private aDados  := {}
Private cFilArq := ''

While !FT_FEOF() .AND. lExit 
    
    If lCancel
		FT_FUSE()
		Return
	EndIf
    cLine   := FT_FReadLn() // Retorna a linha corrente
    aDados  := StrTokArr(cLine,";") 
    If !Empty(aDados)
        If UPPER('Data Inicial') $ UPPER(aDados[1]) .AND. Empty(dDataIni)
            dDataIni := cTod(Alltrim(Substr(aDados[1], At(":", aDados[1])+1,Len(aDados[1]) )))
        elseIf UPPER('Data Final') $ UPPER(aDados[1]) .AND. Empty(dDataFim) 
            dDataFim := cTod(Alltrim(Substr(aDados[1], At(":", aDados[1])+1,Len(aDados[1]) )))
        EndIf

        If UPPER('Loja') $ UPPER(aDados[1])
            If EMPTY(cFilArq)
                cFilArq := Alltrim(Substr(aDados[1], At(":", aDados[1])+1,Len(aDados[1]) ))
                cFilArq := RmiDePaRet("CHEF", "SM0", cFilArq, .F.)
                If EMPTY(cFilArq)
                    lExit := .F.
                    MSGALERT(STR0015+aDados[1] )//" Não encontrado o cadastro de De/para na tabela MHM. Verifique qual filial no Protheus corresponde a -> "
                    FT_FUSE()
                    Return
                EndIf
           EndIF
        EndIf
    EndIf
    FT_FSKIP()
EndDo

If lExit
	If Empty(dDataFim) .Or. Empty(dDataIni)	 
		MSGINFO(STR0025)//"Layout invalido! mais informações sobre o Layout acesse: https://tdn.totvs.com/x/AgcrIw"
		lExit := .F. 
	EndIf
EndIf

If lExit
	DEFINE MSDIALOG oDlg TITLE cTitcab FROM 9,0 TO 24,60 OF oMainWnd  

		@ 35,025 SAY STR0009 OF oDlg PIXEL 		//"Ini Periodo:"
		@ 35,080 MSGET oData VAR dDataIni   PICTURE "@D"  SIZE 50,10 WHEN lWhen OF oDlg PIXEL HASBUTTON
		@ 55,025 SAY STR0010 PIXEL //"Fim Periodo:"
		@ 55,080 MSGET oData VAR dDataFim PICTURE "@D"   SIZE 50,10 WHEN lWhen OF oDlg PIXEL HASBUTTON                                                   
		@ 75,025 SAY STR0011 PIXEL	   	  //"Tipo de Movimento:"
		@ 75,080 COMBOBOX oCombo  VAR cCombo ITEMS aCombo 		SIZE 075, 010 OF oDlg COLORS 0, 16777215 PIXEL
		//@ 85,095 CHECKBOX oCheck3 VAR lCheck3 PROMPT "STR0080"  SIZE 050, 010 OF oDlg PIXEL 
		
			
			
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)
		
		If lRet                                                                     
			nSelec := Val(SubStr(cCombo,1,1))
			If nSelec == 1
				Processa({|| Comparar(nSelec,cCombo,@dDataIni,@dDataFim) } ,STR0012,,lCancel) //"Gerando Diferenca..."
			EndIf	  
		Else
			MSGINFO(STR0013)//"Dados informados inválidos."
		Endif
EndIf

return
//-------------------------------------------------------------------
/*{Protheus.Doc} Comparar    
Gera arquivo e busca da diferença.
@author  Everso S P Junior
@version P12 
@since   23/09/2020  
@menu	 LOJA                                                            
*/ 
//-------------------------------------------------------------------
Static Function Comparar(nSelec,cDesc,dDataIni,dDataFim)                   
Local cLine  	:= 0
Local nY     	:= 6
Local cTmpPam  	:= GetNextAlias()
Local cQuery  	:= ""
Local cLineU 	:= ''
Local aRet		:= {} 
Local aChef  	:= {}
Local aProtheus := {}
Local lExit		:= .F.
Local cTitulo   := "Protocolo NF-e"
Local nPos		:= 0
Local aCabExcel	:= ""
Local lContinua := .T.


Private dIni    := ''
Private dFim    := ''

//'1 - Chef'
If nSelec = 1
	cQuery += " SELECT L1_EMISSAO,L1_ESPECIE,L1_KEYNFCE "
	cQuery += " FROM "+ RetSqlName( 'SL1' )+ " SL1 "
	cQuery += " WHERE SL1.L1_EMISSAO BETWEEN '"+dTos(dDataIni)+"' AND '"+dTos(dDataFim)+"' "
	cQuery += " AND SL1.L1_ESPECIE IN ('NFCE') AND SL1.D_E_L_E_T_ <>'*' "
    cQuery += " AND SL1.L1_FILIAL = '"+cFilArq+"' "
	cQuery += " ORDER BY L1_EMISSAO "
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPam,.T.,.T.)


Do While (cTmpPam)->(!EOF()) .AND. !lCancel
	IncProc(STR0023)//"Aguarde Gerando Dados do Protheus!"
	AADD(aProtheus,{(cTmpPam)->L1_KEYNFCE}) 
	(cTmpPam)->(DbSkip())
EndDo
(cTmpPam)->(dbCloseArea())

If Empty(aProtheus)
	MSGALERT( STR0020+ "("+cFilArq+") Data - "+dToc(dDataIni)+" até "+dToc(dDataFim),STR0006 )//"Não foi encontrado dados no Protheus para Filial "   	
	lContinua := .F.
EndIf 

If lContinua
	FT_FGoTop()
	While !FT_FEOF() .AND. !lExit 
		IncProc(STR0014)//"Gerando dados"
		cLine  := DecodeUTF8(FT_FReadLn(), "cp1252") // Retorna a linha corrente
		cLine  := StrTran(cLine,";;",";'';",1,16) //SUBSTITUIR ";;" 
		cLine  := StrTran(cLine,";;",";'';",1,16) //SUBSTITUIR ";;" 
		aRet   := StrTokArr(cLine,";") 
		nPos   := aScan(aRet,{|x| AllTrim(x) == AllTrim(cTitulo)})
		If nPos > 0
			aCabExcel := aclone(aRet)
			FT_FSKIP()// desce uma linha do cabeçalho
			lExit := .T.
		EndIf 
		FT_FSKIP()
	EndDo	

	If !lExit
		MSGALERT( STR0021,STR0006 )//" Coluna Protocolo NF-e não encontrada no arquivo!"
		lContinua := .F.
	EndIf
	If lContinua
		ProcRegua(FT_FLastRec())
		While !FT_FEOF() .AND. !lCancel 
			 
			If lCancel
				FT_FUSE()
				Return
			EndIf
			IncProc(STR0016)//"Busca dados"
			cLine   := FT_FReadLn() // Retorna a linha corrente
			cLineU  := StrTran(cLine,";;",";'';",1,16) //SUBSTITUIR ";;" POR ";0;" EM TODO O TXT
			cLineU  := StrTran(cLineU,";;",";'';",1,16) //SUBSTITUIR ";;" POR ";0;" EM TODO O TXT
			aRet    := StrTokArr(+";''"+cLineU,";") // Layout +";''"+ na primeira posição está com ';' deposicionando o array
 			cLin	:= Alltrim(Str(nY++))
			If aScan(aProtheus,{|x| AllTrim(x[1]) == AllTrim(aRet[nPos])}) <= 0 .AND. Alltrim(aRet[nPos]) <> "''"
				aRet[nPos] := "'"+AllTrim(aRet[nPos]) //incluindo aspas simples para que o excel não gere o campo com formula
				AADD(aChef,aRet)		
			EndIf
			FT_FSKIP()
		EndDo           
		//Fecha o Arquivo.
		FT_FUSE()

		If !Empty(aChef)
			Processa({|| GrvArqCsv(aCabExcel,aChef,cDesc,dToc(dDataIni),dToc(dDataFim)) } ,STR0017) //"Buscando Dados Live X Protheus..."
		else
			MSGALERT( STR0022,STR0006 )//"Não foi encontrado diferenças!"	
		EndIf	  

	EndIf	
EndIf

FT_FUSE()
Return

//-------------------------------------------------------------------
/*{Protheus.Doc} GrvArqCsv    
Gera o arquivo .csv com as diferenças encontradas.
@project MAN00000330101_EF_002     
@author  Everson S P Junior
@version P12
@since   23/09/2020  
@menu	 Loja                                                            
*/ 
//-------------------------------------------------------------------
Static Function GrvArqCsv(aCabExcel,aVetor,cNome,cDataIni,cDataFim) 
Local cTitulo	  := STR0018+" - "+"Data da Pesquisa - "+cDataIni+ " Até "+ cDataFim + " Filial - "+cFilArq 
Default aCabExcel := {}

DlgToExcel({{"ARRAY",cTitulo,aCabExcel,aVetor} }) //"VENDAS NÃO ENCONTRADAS"

MSGINFO("",STR0024) //"Relatório com as vendas não encontradas no Protheus foi gerado com sucesso."
Return
