#Include "plsm153.ch"
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH"
#Include "COLORS.CH"

Static	aRecSE2 := {}

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSm153 � Autor 矼骴ulo Plano de Sa鷇e � Data � 23.05.2008 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Exclusao de titulos no financeiro...                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSM153() 

Local   n
Local 	cPrefixo    := &(GetMv("MV_3DUPREF"))
Private aRotina     := MenuDef()                           
Private cCadastro 	:= Fundesc() //"Exclus鉶 de T韙ulos a Pagar"
Private cMarcaE2
Private lIntegracao := IF(GetMV("MV_EASY")=="S",.T.,.F.) 
Private lF050Auto   := .T.    

#IFDEF TOP
       PRIVATE cFiltro := "@E2_FILIAL = '"+xFilial("SE2")+"' "
               cFiltro += " AND E2_PREFIXO = '"+cPrefixo+"' AND D_E_L_E_T_ = ' '"
#ELSE
       PRIVATE cFiltro := "E2_FILIAL = '"+xFilial("SE2")+"' "
               cFiltro += " .AND. E2_PREFIXO = '"+cPrefixo+"' AND D_E_L_E_T_ = ' '"
#ENDIF 
              
cMarcaE2 := GetMark()

DbSelectArea("SE2")
SET FILTER TO &cFiltro
SE2->( dbGotop() )
SE2->( dbSeek(xFilial("SE2")) )

MarkBrow("SE2","E2_OK","(E2_SALDO <> E2_VALOR .OR. E2_LA == 'S' .OR. E2_NUMBOR <> '"+Space(6)+"')",,,cMarcaE2,,,,,"A153Mark()")

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Desmasca os registros caso a rotina seja abortada com titulos marcados...		  |
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
For n := 1 To Len(aRecSE2)
	If aRecSE2[n] > 0
		SE2->( dbGoto(aRecSE2[n]) )
		If !SE2->( Eof() )
			SE2->( RecLock("SE2", .F.) )
				SE2->E2_OK := Space(Len(SE2->E2_OK))
			SE2->( MsUnlock() )
		EndIf
	EndIf
Next

SE2->(DbClearFilter())

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Fim da Rotina Principal...                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Return Nil 
                                           

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSM153VIS 矨utor矼骴ulo Plano de Sa鷇e � Data � 23.05.2008潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � VIsualiza玢o de T韙ulos a serem exclu韉os                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function PLSM153Vis()

Local cOldCad := cCadastro

cCadastro := STR0003  //"Visualiza玢o do Titulo a Pagar"

Fa050Visua( "SE2",SE2->(Recno()),K_Visualizar )

cCadastro := cOldCad

Return      


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � A153MARK   矨utor矼骴ulo Plano de Sa鷇e � Data � 23.05.2008潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Valida玢o para Sele玢o de T韙ulo para Exclus鉶             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function A153Mark()

Local lREt := .F.
Local nPos := 0

If Alltrim(SE2->E2_ORIGEM) # 'PLSMPAG' .AND. Alltrim(SE2->E2_ORIGEM) # 'PLSM152'
	MsgStop(STR0004) //"Este T韙ulo n鉶 foi gerado pelo modulo SIGAPLS e n鉶 poder� ser excluido por esta rotina."
ElseIf SE2->E2_LA == "S"
	MsgStop(STR0005) //"Este T韙ulo foi contabilizado e n鉶 poder� ser exclu韉o por esta rotina."
ElseIf SE2->E2_SALDO <> SE2->E2_VALOR 
	MsgStop(STR0006) //"Este T韙ulo foi Baixado e n鉶 poder� ser excluido por esta rotina."
ElseIf SE2->E2_NUMBOR <> Space(6)
	MsgStop(STR0007+" "+SE2->E2_NUMBOR+" "+STR0008)	 //"Este T韙ulo faz parte do Border� "###" e n鉶 poder� ser excluido por esta rotina."
Else
	SE2->( RecLock("SE2", .F.) )
		If Empty(SE2->E2_OK)
			SE2->E2_OK := cMarcaE2
			
			// Atualiza matriz para desmarcar os registros caso seja necessario.
			If (nPos := Ascan(aRecSE2, SE2->( Recno() ))) == 0
				Aadd(aRecSE2, SE2->( Recno() ))
			EndIf
		Else
			SE2->E2_OK := Space(Len(SE2->E2_OK))
			
			// Remove registro da matriz
			If (nPos := Ascan(aRecSE2, SE2->( Recno() ))) # 0
				Adel(aRecSE2, nPos)				
				If Len(aRecSE2) > 1
					ASize(aRecSE2, (Len(aRecSE2)-1))
				Else
					aRecSE2 := {}
				EndIf
			EndIf
		EndIf
	SE2->( MsUnlock() )
EndIf

Return(lRet)


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  砅LSM153EXC  矨utor矼骴ulo Plano de Sa鷇e � Data � 23.05.2008潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Exclus鉶 de T韙ulos de Comissionamento                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSM153EXC()

MsAguarde({|| PLS153EXC() }, cCadastro, "", .T.) // Exibe dialogo padrao...

Return      


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  砅LS153EXC  矨utor矼骴ulo Plano de Sa鷇e � Data � 23.05.2008潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Exclus鉶 de T韙ulos de Comissionamento                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLS153EXC ()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Inicializa variaveis                                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Local aErro    := {}
Local nI       := 0
Local nX       := 0
Local bOrdem   := {|x,y| x>y}
Local cSql     := ""
Local cBXQ     := RetSqlName("BXQ")
Local lExclSE2 := .F.
Local lExc	   := .F.
Local aRecBXQ  := {}

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Confirma a exclusao dos titulos marcados...                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If  Aviso(STR0009,STR0010,{"Sim","Nao"}) == 2 //"Confirmacao de exclusao"###"Deseja realmente excluir todos os titulos marcados?"
	Return(.F.)
EndIf
                  
aSort(aRecSE2,,,bOrdem)

Begin Transaction
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Processa os regsitros marcados...                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
For nI:=1 To Len(aRecSE2)                               

	lExc := .F.
	SE2->(dbGoto(aRecSE2[nI]))
	
	If  SE2->( EoF() )
		Loop
	EndIf   
	
	MsProcTxt(STR0012)	 //"Atualizando C醠culo da Comiss鉶"

	cSql := " SELECT R_E_C_N_O_ RECBXQ "
	cSql += " FROM "+cBXQ+" " 
	cSql += " WHERE BXQ_FILIAL = '"+xFilial("BXQ")+"' "
	cSql += "    AND BXQ_E2PREF = '"+SE2->E2_PREFIXO+"' " 
	cSql += "    AND BXQ_E2NUM = '"+SE2->E2_NUM+"' " 
	cSql += "    AND BXQ_E2PARC = '"+SE2->E2_PARCELA+"' " 
	cSql += "    AND BXQ_E2TIPO = '"+SE2->E2_TIPO+"' " 
	cSql += "    AND D_E_L_E_T_ = '' "
	
	cSql := ChangeQuery(cSql)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),"TRBBXQ",.T.,.T.)		

	While !TRBBXQ->(EoF())
		AaDd(aRecBXQ,TRBBXQ->RECBXQ)		
        lExc := .T.
		TRBBXQ->(Dbskip())
	Enddo		
	
	TRBBXQ->(DbCloseArea()) 
	
	If !lExc
		aadd(aErro,{SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO,STR0014}) //"T韙ulo n鉶 esta vinculado e nenhum Pagto de Comiss鉶"		 
	ElseIf !(lExclSE2 := PLCANCRE()[1])
        aadd(aErro,{SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO,STR0011}) //"T韙ulo nao pode ser Exclu韉o Verifique a condi玢o do mesmo no M骴ulo Financeiro"	
    Else
    	For nX := 1 to Len(aRecBXQ)
	    	BXQ->(DbGoTo(aRecBXQ[nX]))
	    	RecLock("BXQ", .F.)
		        BXQ->BXQ_DTGER  := cTod('')
		        BXQ->BXQ_E2PREF := ""
		        BXQ->BXQ_E2NUM  := ""
		        BXQ->BXQ_E2PARC := ""
		        BXQ->BXQ_E2TIPO := ""
		        BXQ->BXQ_E2FORN := ""
		        BXQ->BXQ_E2LOJA := ""
	        BXQ->(MsUnLock())
	     Next nX
	EndIf
Next nI

End Transaction

If  Len(aErro) > 0
    PLSCRIGEN(aErro,{ {"Chave (conteudo)","@C",60 } , {"Mensagem","@C",40 } } , STR0013) //"Ocorr阯cias na exclus鉶 dos T韙ulos selecionados"
EndIf

aRecSE2 := {}

Return     


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Darcio R. Sporl       � Data �22/12/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北�          �                                                            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �	  1 - Pesquisa e Posiciona em um Banco de Dados           潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function MenuDef()

Private aRotina   := { 	{ STRPL01        ,'AxPesqui' , 0 ,K_Pesquisar   ,0 , .F.  },; // Pesquisar
						{ STR0000   	 ,'PLSM153VIS' , 0 ,K_Visualizar,0 , Nil  },; //"Visualizar"
                       	{ STR0001	     ,'PLSM153EXC' , 0 ,K_Excluir   ,0 , Nil  }} //"Excluir"


Return(aRotina)
